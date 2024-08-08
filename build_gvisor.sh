#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Install necessary dependencies
sudo apt-get update
sudo apt-get install -y build-essential git wget unzip

# Define variables
GO_VERSION="1.19"
GO_TAR="go${GO_VERSION}.linux-amd64.tar.gz"
GVISOR_VERSION="release-20210125.0"
GVISOR_DIR="gvisor-${GVISOR_VERSION}"
GVISOR_URL="https://github.com/google/gvisor/archive/refs/tags/${GVISOR_VERSION}.zip"
INSTALL_DIR="/usr/local/bin"

# Download and install Go
wget https://golang.org/dl/${GO_TAR}
sudo tar -C /usr/local -xzf ${GO_TAR}
export PATH=$PATH:/usr/local/go/bin

# Download gVisor source code
wget ${GVISOR_URL} -O ${GVISOR_VERSION}.zip

# Unzip the downloaded file
unzip ${GVISOR_VERSION}.zip

# Change to the gVisor directory
cd ${GVISOR_DIR}

# Modify go.mod to use an older version of rules_go
sed -i 's/github.com\/bazelbuild\/rules_go v0.49.0/github.com\/bazelbuild\/rules_go v0.23.3/' go.mod

# Build the runsc binary using Go directly
cd runsc
export GO111MODULE=on
go get -d ./...
go build -o runsc .

# Move the runsc binary to the install directory
sudo mv runsc ${INSTALL_DIR}

# Optionally, remove the source code directory to clean up
cd ../..
rm -rf ${GVISOR_DIR}
rm ${GVISOR_VERSION}.zip
rm ${GO_TAR}

# Verify installation
echo "gVisor runsc installed at ${INSTALL_DIR}/runsc"
${INSTALL_DIR}/runsc --version

# End of script
