terraform {
  required_version = "~> 0.11"
}

provider "aws" {
  region = "${var.region}"
}

// provider "cloudflare" {
//   email = "${var.cloudflare_email}"
//   token = "${var.cloudflare_token}"
// }

data "aws_ami" "ubuntu-1604" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-xenial-16.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

data "aws_availability_zones" "available" {}

data "template_file" "server-base" {
  count    = "${var.servers}"
  template = "${file("${path.module}/templates/shared/base.sh")}"

  vars {
    hostname = "${var.namespace}-consul-server-${count.index}"
  }
}

data "template_file" "server-consul" {
  count    = "${var.servers}"
  template = "${file("${path.module}/templates/server/consul.sh")}"

  vars {
    servers        = "${var.servers}"
    consul_version = "${var.consul_version}"
    hostname       = "${var.namespace}-consul-server-${count.index}"

  }
}

data "template_file" "client-base" {
  count    = "${var.clients}"
  template = "${file("${path.module}/templates/shared/base.sh")}"

  vars {
    hostname = "${var.namespace}-client-${count.index}"
  }
}

data "template_file" "client-consul" {
  count    = "${var.clients}"
  template = "${file("${path.module}/templates/client/consul.sh")}"

  vars {
    hostname       = "${var.namespace}-client-${count.index}"
    consul_version = "${var.consul_version}"
  }
}

resource "aws_vpc" "demo" {
  cidr_block           = "${var.vpc_cidr_block}"
  enable_dns_hostnames = true

  tags {
    "Name" = "${var.namespace}"
  }
}

resource "aws_internet_gateway" "demo" {
  vpc_id = "${aws_vpc.demo.id}"

  tags {
    "Name" = "${var.namespace}"
  }
}

resource "aws_route" "internet_access" {
  route_table_id         = "${aws_vpc.demo.main_route_table_id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.demo.id}"
}

resource "aws_subnet" "demo" {
  count                   = "${length(var.cidr_blocks)}"
  vpc_id                  = "${aws_vpc.demo.id}"
  availability_zone       = "${data.aws_availability_zones.available.names[count.index]}"
  cidr_block              = "${var.cidr_blocks[count.index]}"
  map_public_ip_on_launch = true

  tags {
    "Name" = "${var.namespace}"
  }
}

resource "aws_security_group" "demo" {
  name_prefix = "${var.namespace}"
  vpc_id      = "${aws_vpc.demo.id}"

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_key_pair" "demo" {
  key_name   = "${var.namespace}"
  public_key = "${file("${var.public_key_path}")}"
}

resource "aws_iam_role" "consul-join" {
  name               = "${var.namespace}-consul-join"
  assume_role_policy = "${file("${path.module}/templates/policies/assume-role.json")}"
}

resource "aws_iam_policy" "consul-join" {
  name        = "${var.namespace}-consul-join"
  description = "Allows Consul nodes to describe instances for joining."
  policy      = "${file("${path.module}/templates/policies/describe-instances.json")}"
}

resource "aws_iam_policy_attachment" "consul-join" {
  name       = "${var.namespace}-consul-join"
  roles      = ["${aws_iam_role.consul-join.name}"]
  policy_arn = "${aws_iam_policy.consul-join.arn}"
}

resource "aws_iam_instance_profile" "consul-join" {
  name = "${var.namespace}-consul-join"
  role = "${aws_iam_role.consul-join.name}"
}

resource "aws_instance" "server" {
  count = "${var.servers}"

  ami           = "${data.aws_ami.ubuntu-1604.id}"
  instance_type = "r3.xlarge"
  key_name      = "${aws_key_pair.demo.id}"

  subnet_id              = "${element(aws_subnet.demo.*.id, count.index)}"
  iam_instance_profile   = "${aws_iam_instance_profile.consul-join.name}"
  vpc_security_group_ids = ["${aws_security_group.demo.id}"]

  tags {
    "Name"   = "${var.namespace}-consul-server-${count.index}"
    "consul" = "consul"
  }

  user_data = "${join("\n",
    list(
      element(data.template_file.server-base.*.rendered, count.index),
      element(data.template_file.server-consul.*.rendered, count.index),
      file("templates/shared/cleanup.sh"),
    )
  )}"
}

resource "aws_instance" "client" {
  count = "${var.clients}"

  ami           = "${data.aws_ami.ubuntu-1604.id}"
  instance_type = "r3.xlarge"
  key_name      = "${aws_key_pair.demo.id}"

  subnet_id              = "${element(aws_subnet.demo.*.id, count.index)}"
  iam_instance_profile   = "${aws_iam_instance_profile.consul-join.name}"
  vpc_security_group_ids = ["${aws_security_group.demo.id}"]

  tags {
    "Name"   = "${var.namespace}-client-${count.index}"
    "consul" = "consul"
  }

  user_data = "${join("\n",
    list(
      element(data.template_file.client-base.*.rendered, count.index),
      file("templates/client/habitat.sh"),
      element(data.template_file.client-consul.*.rendered, count.index),
      file("templates/shared/cleanup.sh"),
    )
  )}"

  connection {
    user = "ubuntu"
  }
}

resource "aws_alb" "demo" {
  name = "${var.namespace}-demo"

  security_groups = ["${aws_security_group.demo.id}"]
  subnets         = ["${aws_subnet.demo.*.id}"]

  tags {
    Name = "${var.namespace}-demo"
  }
}

resource "aws_alb_target_group" "demo" {
  name     = "${var.namespace}-demo"
  port     = "80"
  vpc_id   = "${aws_vpc.demo.id}"
  protocol = "HTTP"

  health_check {
    interval          = "5"
    timeout           = "2"
    path              = "/"
    port              = "80"
    protocol          = "HTTP"
    healthy_threshold = 2
  }
}

resource "aws_alb_listener" "demo" {
  load_balancer_arn = "${aws_alb.demo.arn}"

  port     = "80"
  protocol = "HTTP"

  default_action {
    target_group_arn = "${aws_alb_target_group.demo.arn}"
    type             = "forward"
  }
}

resource "aws_alb_target_group_attachment" "demo" {
  count            = "${var.clients}"
  target_group_arn = "${aws_alb_target_group.demo.arn}"
  target_id        = "${element(aws_instance.client.*.id, count.index)}"
  port             = "80"
}

// resource "cloudflare_record" "demo" {
//   domain  = "${var.domain}"
//   type    = "CNAME"
//   name    = "consul-web-dashboard"
//   value   = "${aws_alb.demo.dns_name}"
//   ttl     = "1"
//   proxied = "1"
// }

output "servers" {
  value = ["${aws_instance.server.*.public_ip}"]
}
