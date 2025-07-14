
# Copyright (c) 2023-2025 Gilson Rincón <gilson.rincon@gmail.com>
# Solutto Consulting LLC - https://www.soluttoconsulting.com
#
# This script is developed by Gilson Rincón for Solutto Consulting LLC.
# 
# Licensed under the Solutto Consulting LLC Custom License.
# You may use, modify, and distribute this software under the terms specified in the LICENSE file.
# For commercial use, proper attribution is required. See LICENSE file for full terms.
# 
# DISCLAIMER: This software is provided "AS IS" without warranty. Users are responsible
# for testing and validating the code before use in any environment.
#
# Please read the LICENSE file in this repository for complete terms and conditions.
#
#!/bin/bash

# Odoo Deployment Setup Script
# This script generates deployment files from templates using setup.json configuration

set -e  # Exit on any error

# Ensure the script is run with sudo privileges
if [[ "$EUID" -ne 0 ]]; then
    echo -e "\033[0;31m[ERROR]\033[0m This script must be run as root or with sudo privileges."
    exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="$SCRIPT_DIR/setup.json"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if jq is installed
# jq is a lightweight command-line JSON processor for parsing and manipulating JSON data
if ! command -v jq &> /dev/null; then
    print_error "jq is required but not installed."
    echo
    echo "jq is a command-line JSON processor needed to read the setup.json configuration file."
    echo
    echo "To install jq:"
    echo "  Ubuntu/Debian: sudo apt-get install jq"
    echo "  RHEL/CentOS:   sudo yum install jq"
    echo "  Fedora:        sudo dnf install jq"
    echo "  macOS:         brew install jq"
    echo "  Or download from: https://stedolan.github.io/jq/download/"
    echo
    exit 1
fi

# Check if setup.json exists
if [[ ! -f "$CONFIG_FILE" ]]; then
    print_error "Configuration file not found: $CONFIG_FILE"
    exit 1
fi

print_status "Reading configuration from setup.json..."

# Read configuration values
HOSTNAME=$(jq -r '.placeholders.hostname' "$CONFIG_FILE")
LOG_PREFIX=$(jq -r '.placeholders.log_prefix' "$CONFIG_FILE")
DB_CONTAINER_NAME=$(jq -r '.placeholders.db_container_name' "$CONFIG_FILE")
ODOO_CONTAINER_NAME=$(jq -r '.placeholders.odoo_container_name' "$CONFIG_FILE")
DB_PASSWORD=$(jq -r '.placeholders.db_password' "$CONFIG_FILE")
ODOO_PORT=$(jq -r '.placeholders.odoo_port' "$CONFIG_FILE")
LONGPOLLING_PORT=$(jq -r '.placeholders.longpolling_port' "$CONFIG_FILE")
ODOO_VERSION=$(jq -r '.placeholders.odoo_version' "$CONFIG_FILE")
POSTGRES_VERSION=$(jq -r '.placeholders.postgres_version' "$CONFIG_FILE")
DB_HOST=$(jq -r '.placeholders.db_host' "$CONFIG_FILE")
ADMIN_PASSWD=$(jq -r '.placeholders.admin_passwd' "$CONFIG_FILE")
DB_NAME=$(jq -r '.placeholders.db_name' "$CONFIG_FILE")

# Validate required fields
if [[ -z "$HOSTNAME" || "$HOSTNAME" == "null" || "$HOSTNAME" == "" ]]; then
    print_error "hostname is required in setup.json"
    exit 1
fi

if [[ -z "$DB_PASSWORD" || "$DB_PASSWORD" == "null" || "$DB_PASSWORD" == "" ]]; then
    print_error "db_password is required in setup.json"
    exit 1
fi

if [[ -z "$ADMIN_PASSWD" || "$ADMIN_PASSWD" == "null" || "$ADMIN_PASSWD" == "" ]]; then
    print_error "admin_passwd is required in setup.json"
    exit 1
fi

# Set default values if empty
[[ -z "$LOG_PREFIX" || "$LOG_PREFIX" == "null" ]] && LOG_PREFIX=$(echo "$HOSTNAME" | cut -d'.' -f1)
[[ -z "$DB_CONTAINER_NAME" || "$DB_CONTAINER_NAME" == "null" ]] && DB_CONTAINER_NAME="${LOG_PREFIX}_soluttoconsulting_db"
[[ -z "$ODOO_CONTAINER_NAME" || "$ODOO_CONTAINER_NAME" == "null" ]] && ODOO_CONTAINER_NAME="${LOG_PREFIX}_soluttoconsulting_odoo"
[[ -z "$DB_HOST" || "$DB_HOST" == "null" ]] && DB_HOST="$DB_CONTAINER_NAME"

print_status "Configuration loaded for: $HOSTNAME"

# Create target directory
TARGET_DIR="../$HOSTNAME"
print_status "Creating target directory: $TARGET_DIR"
mkdir -p "$TARGET_DIR"/{addons,backup,config,data,db}

# Set ownership for specific directories
chown 100:101 -R "$TARGET_DIR/addons"
chown 100:101 -R "$TARGET_DIR/data"
chown root:root -R "$TARGET_DIR/db"

# Set permissions for specific directories
chmod 777 -R "$TARGET_DIR/data"
chmod 744 -R "$TARGET_DIR/addons"

# Function to replace placeholders in a file
replace_placeholders() {
    local input_file="$1"
    local output_file="$2"
    
    print_status "Processing: $input_file -> $output_file"
    
    sed -e "s/{hostname}/$HOSTNAME/g" \
        -e "s/{log_prefix}/$LOG_PREFIX/g" \
        -e "s/{db_container_name}/$DB_CONTAINER_NAME/g" \
        -e "s/{odoo_container_name}/$ODOO_CONTAINER_NAME/g" \
        -e "s/{db_password}/$DB_PASSWORD/g" \
        -e "s/{odoo_port}/$ODOO_PORT/g" \
        -e "s/{longpolling_port}/$LONGPOLLING_PORT/g" \
        -e "s/{odoo_version}/$ODOO_VERSION/g" \
        -e "s/{postgres_version}/$POSTGRES_VERSION/g" \
        -e "s/{db_host}/$DB_HOST/g" \
        -e "s/{admin_passwd}/$ADMIN_PASSWD/g" \
        -e "s/{db_name}/$DB_NAME/g" \
        "$input_file" > "$output_file"
}

# Generate docker-compose.yml
if [[ -f "docker-compose-template.yml" ]]; then
    replace_placeholders "docker-compose-template.yml" "$TARGET_DIR/docker-compose.yml"
else
    print_error "Template file not found: docker-compose-template.yml"
    exit 1
fi

# Generate odoo.conf
if [[ -f "config/odoo-template.conf" ]]; then
    replace_placeholders "config/odoo-template.conf" "$TARGET_DIR/config/odoo.conf"
else
    print_error "Template file not found: config/odoo-template.conf"
    exit 1
fi

# Generate Apache vhost file (but don't move it)
if [[ -f "apache-hvost-template.conf" ]]; then
    APACHE_OUTPUT="$TARGET_DIR/${HOSTNAME}.conf"
    replace_placeholders "apache-hvost-template.conf" "$APACHE_OUTPUT"
    print_warning "Apache vhost file generated at: $APACHE_OUTPUT"
    print_warning "You must manually move this file to your Apache sites-available directory and enable it."
else
    print_error "Template file not found: apache-hvost-template.conf"
    exit 1
fi

print_status "Setup completed successfully!"
print_status "Generated files in: $TARGET_DIR"
echo
print_warning "Next steps:"
echo "1. Move the Apache vhost file to your web server configuration"
echo "2. Generate SSL certificates using certbot"
echo "3. Start the services: cd $TARGET_DIR && docker-compose up -d"