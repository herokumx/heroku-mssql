#!/bin/bash -eu
#
# Microsoft(R) SQL Server(R) for Linux. Private preview
# repository configuration tool.
#

VERBOSE=${VERBOSE:-}
USER_URL="${1:-}";
OUTPUT_DIR=$(mktemp -d)
CONFIG_FILENAME="$OUTPUT_DIR/config.tar.gz"
CERT_FILENAME="c$OUTPUT_DIR/client.private-repo.microsoft.com.pem"
APT_CONF_FILENAME="$OUTPUT_DIR/99microsoft-private-repo-auth.conf"
RHEL7_REPO_LIST_FILENAME="$OUTPUT_DIR/private-repo.microsoft.com.repo"
UBUNTU_REPO_LIST_FILENAME="$OUTPUT_DIR/private-repo.microsoft.com.list"
REPO_KEYS_URL="$OUTPUT_DIR/dpgswdist.v1.asc"

grep -i ubuntu /etc/os-release >& /dev/null && os=ubuntu

# Unpack repository configuration
echo "Unpacking repository configuration..."
tar -zxf $CONFIG_FILENAME -C $OUTPUT_DIR/
rm $CONFIG_FILENAME

if [ "$os" == "ubuntu" ]; then
  # Copy the repository authentication certificate
  echo "Copying repository authentication certificate to /etc/ssl/apt..."
  mkdir -p /etc/ssl/apt
  cp $OUTPUT_DIR/$CERT_FILENAME /etc/ssl/apt
  chmod -R 700 /etc/ssl/apt
  id _apt >& /dev/null && chown -R _apt /etc/ssl/apt

  # Copy the APT configuration file
  echo "Copying APT configuration to /etc/apt/apt.conf.d/..."
  cp $OUTPUT_DIR/$APT_CONF_FILENAME /etc/apt/apt.conf.d/

  # Copy the repository list file
  echo "Copying repository configuration to /etc/apt/sources.list.d/..."
  cp $OUTPUT_DIR/$UBUNTU_REPO_LIST_FILENAME /etc/apt/sources.list.d/

  # Add the repository signing key
  echo "Adding repository signing key..."
  curl $CURL_OPTIONS -sf $REPO_KEYS_URL | apt-key add - >& /dev/null || echo "Failed to add repository signing key, error $?"
fi

if [ "$os" == "rhel7" ]; then
  # Copy the repository authentication certificate
  echo "Copying repository authentication certificate to /etc/ssl/yum..."
  mkdir -p /etc/ssl/yum
  cp $OUTPUT_DIR/$CERT_FILENAME /etc/ssl/yum
  chmod -R 700 /etc/ssl/yum

  # Copy the repository list file
  echo "Copying repository configuration to /etc/yum.repos.d/..."
  cp $OUTPUT_DIR/$RHEL7_REPO_LIST_FILENAME /etc/yum.repos.d/
fi

echo ""
echo "Repository configuration completed successfully."

# Clean-up
rm -rf $OUTPUT_DIR
rm -rf $CONFIG_FILENAME
