#!/bin/bash

# Cleanup old docker system items
docker system prune -a -f

# Pull down required images
docker pull consul:latest
docker pull habitat:default-studio-x86_64-linux

# Remove old .hart files
pushd ../services/
find . -type d -name "results" -exec rm -rf {} +
popd

# Clean each service
pushd ../services/service-discovery/counter/
make clean
rm -rf src
popd

pushd ../services/service-discovery/dashboard/
make clean
rm -rf src
popd

pushd ../services/service-segmentation/counter-connect/
make clean
rm -rf src
popd

pushd ../services/service-segmentation/dashboard-connect/
make clean
rm -rf src
popd

