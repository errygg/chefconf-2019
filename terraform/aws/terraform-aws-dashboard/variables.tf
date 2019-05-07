# Required
// variable "cloudflare_email" {
//   description = "The cloudflare email"
// }

# Required
// variable "cloudflare_token" {
//   description = "The cloudflare token"
// }

variable "region" {
  description = "The region to create resources."
  default     = "us-west-2"
}

variable "servers" {
  description = "The number of servers to create."
  default     = "3"
}

variable "clients" {
  description = "The number of clients to create."
  default     = "3"
}

variable "consul_version" {
  description = "The version of Consul to install (server and client)."
  default     = "1.4.4"
}

variable "namespace" {
  description = "The namespace under which to create resources."
  default     = "chefconf2019"
}

variable "vpc_cidr_block" {
  description = "The top-level CIDR block for the VPC."
  default     = "10.1.0.0/16"
}

variable "cidr_blocks" {
  description = "The CIDR blocks in which to create the instances."
  default     = ["10.1.1.0/24", "10.1.2.0/24"]
}

variable "public_key_path" {
  description = "The absolute path on disk to the SSH public key."
  default     = "~/.ssh/id_rsa.pub"
}
