# Odoo Deployment Tool

**Copyright (c) 2023-2025 Gilson Rincón &lt;gilson.rincon@gmail.com&gt;**  
**Solutto Consulting LLC - https://www.soluttoconsulting.com**

*Licensed under the Solutto Consulting LLC Custom License. See [LICENSE](LICENSE) file for complete terms and conditions.*

---

A comprehensive automation tool for deploying Odoo ERP instances with Docker, Apache configuration, and SSL support. This tool streamlines the process of setting up production-ready Odoo environments from templates.

## 📋 License and Usage

This software is developed by **Gilson Rincón** for **Solutto Consulting LLC**. You may use, modify, and distribute this software under the terms specified in the [LICENSE](LICENSE) file. 

**Important Notes:**
- ⚠️ **No Warranty**: This software is provided "AS IS" without warranty of any kind
- 🔍 **User Responsibility**: You are responsible for testing and validating the code before use
- 💼 **Commercial Use**: Proper attribution is required for commercial use (see LICENSE file)
- 📖 **Please read the [LICENSE](LICENSE) file** for complete terms and conditions

## 🚀 Quick Start

**Before you begin, ensure you meet these requirements:**

### ✅ Pre-flight Checklist

1. **📋 Create Configuration File**:
   ```bash
   cp setup-template.json setup.json
   # Edit setup.json with your values
   ```

2. **🔐 Ensure Root Access**: Script must be run with sudo privileges
   ```bash
   sudo ./setup.sh
   ```

3. **🚀 Set Execute Permissions**:
   ```bash
   chmod +x setup.sh
   ```

4. **📦 Install Dependencies**:
   ```bash
   sudo apt-get install jq docker.io docker-compose
   ```

**👉 Ready to deploy? Jump to [Setup Process](#️-setup-process)**

---

## 🚀 Overview

This deployment tool automates the creation of Odoo instances by processing configuration templates and generating all necessary files for a complete deployment. It handles Docker Compose configurations, Apache virtual hosts, and Odoo application settings through a simple JSON configuration file.

### Key Features

- **Template-based deployment**: Uses reusable templates for consistent deployments
- **JSON configuration**: Single configuration file for all deployment parameters
- **Automated file generation**: Creates all necessary configuration files automatically
- **Directory structure creation**: Sets up proper folder hierarchy for Odoo data
- **Apache integration**: Generates virtual host configurations
- **SSL-ready**: Prepares configurations for SSL certificate integration
- **Enterprise support**: Includes enterprise addons and themes mounting

## 📁 Project Structure

```
apps/soluttoconsulting.com/
├── setup.json                    # Main configuration file
├── setup.sh                      # Deployment automation script
├── docker-compose-template.yml   # Docker Compose template
├── apache-hvost-template.conf     # Apache virtual host template
├── backup/
│   ├── backup.sh                 # Automated backup script
│   └── restore.sh                # Automated restore script
└── config/
    └── odoo-template.conf         # Odoo application configuration template
```

## 📋 Templates Description

### 1. Docker Compose Template (`docker-compose-template.yml`)

This template defines the complete Docker environment for your Odoo deployment:

- **PostgreSQL Database Service**: Configures the database container with proper credentials and volume mounting
- **Odoo Application Service**: Sets up the main Odoo container with all necessary environment variables
- **Volume Mapping**: Maps local directories for data persistence, backups, addons, and configuration
- **Network Configuration**: Sets up internal networking between services
- **Port Mapping**: Configures external access ports for web interface and longpolling

**Key placeholders:**
- `{db_container_name}` - Database container identifier
- `{odoo_container_name}` - Odoo application container identifier
- `{db_password}` - PostgreSQL database password
- `{odoo_port}` - Main application port (default: 8069)
- `{longpolling_port}` - Real-time communication port (default: 8072)
- `{odoo_version}` - Odoo Docker image version
- `{postgres_version}` - PostgreSQL Docker image version

### 2. Apache Virtual Host Template (`apache-hvost-template.conf`)

This template creates a complete Apache configuration for your Odoo instance:

- **HTTP to HTTPS Redirect**: Automatically redirects all HTTP traffic to HTTPS
- **SSL Configuration**: Pre-configured for SSL certificates (Let's Encrypt compatible)
- **Proxy Configuration**: Properly configured reverse proxy to Docker containers
- **Security Headers**: Includes security headers and CORS configuration
- **Static File Handling**: Optimized serving of static assets
- **Logging Configuration**: Separate access and error logs per instance

**Key placeholders:**
- `{hostname}` - The domain name for the deployment
- `{log_prefix}` - Prefix for log files
- `{odoo_port}` - Main application port for proxy configuration
- `{longpolling_port}` - Longpolling port for WebSocket support

### 3. Odoo Configuration Template (`config/odoo-template.conf`)

This template configures the Odoo application itself:

- **Database Connection**: Sets up connection to PostgreSQL container
- **Proxy Mode**: Enables proper handling of forwarded headers from Apache
- **Addons Path**: Configures paths for enterprise, community, and custom addons
- **Security Settings**: Admin password and database filtering
- **Performance Settings**: Optimized for containerized deployment

**Key placeholders:**
- `{db_host}` - Database container hostname
- `{db_password}` - Database connection password
- `{admin_passwd}` - Odoo master/admin password
- `{db_name}` - Default database name

## ⚙️ Setup Process

### Prerequisites

- **Docker and Docker Compose**: For containerized deployment
- **jq**: Command-line JSON processor
  - Ubuntu/Debian: `sudo apt-get install jq`
  - RHEL/CentOS: `sudo yum install jq`
  - Fedora: `sudo dnf install jq`
  - macOS: `brew install jq`
- **Apache Web Server**: For reverse proxy (if using Apache configuration)
- **Root/Sudo Access**: Required for running the setup script

### ⚠️ Important Requirements Before Starting

**🔑 CRITICAL: These steps are mandatory for successful deployment:**

1. **📁 Create Configuration File**: 
   ```bash
   # Copy the template and create your configuration file
   cp setup-template.json setup.json
   ```

2. **✏️ Edit Configuration**: Open `setup.json` and fill in all required values (see Step 1 below)

3. **🔐 Root Privileges Required**: The setup script **MUST** be run with sudo privileges:
   ```bash
   # The script requires root access for directory permissions and ownership
   sudo ./setup.sh
   ```

4. **🚀 Set Execute Permissions**: Ensure the script has execution permissions:
   ```bash
   chmod +x setup.sh
   ```

### Step 1: Configure Deployment

**First, copy the template and create your configuration file:**

```bash
cp setup-template.json setup.json
```

**Then edit the `setup.json` file with your deployment parameters:**

```json
{
  "placeholders": {
    "hostname": "mycompany.example.com",
    "log_prefix": "mycompany",
    "db_container_name": "mycompany_db",
    "odoo_container_name": "mycompany_odoo",
    "db_password": "secure_database_password",
    "admin_passwd": "odoo_master_password",
    "odoo_port": "8069",
    "longpolling_port": "8072",
    "odoo_version": "18.0",
    "postgres_version": "16",
    "db_host": "mycompany_db",
    "db_name": "odoo"
  }
}
```

**Required fields:**
- `hostname` - Your domain name
- `db_password` - Database password
- `admin_passwd` - Odoo admin password

**Optional fields with defaults:**
- Container names will be auto-generated if not provided
- Ports, versions, and database name have sensible defaults

### Step 2: Run Deployment Script

**⚠️ IMPORTANT: Run with sudo privileges and ensure execute permissions are set:**

```bash
# Set execute permissions (if not already set)
chmod +x setup.sh

# Run the script with sudo privileges (REQUIRED)
sudo ./setup.sh
```

**Why sudo is required:**
- Creates directories with specific ownership (user 100:101 for Odoo containers)
- Sets proper file permissions for Docker volume mounting
- Ensures secure file handling for production deployment

The script will:
1. Validate your configuration
2. Create the target directory structure with proper permissions
3. Generate all configuration files from templates
4. Provide next steps for manual configuration

### Step 3: Manual Configuration Steps

After running the script, complete these manual steps:

1. **Generate SSL Certificates**:
   ```bash
   sudo certbot certonly --apache -d mycompany.example.com
   ```

2. **Move Apache Virtual Host**:
   ```bash
   sudo cp ../mycompany.example.com/mycompany.example.com.conf /etc/apache2/sites-available/
   sudo a2ensite mycompany.example.com
   sudo systemctl reload apache2
   ```

3. **Start Services**:
   ```bash
   cd ../mycompany.example.com
   docker-compose up -d
   ```

## 🔐 SSL Certificate Setup with Certbot

SSL certificates are essential for secure HTTPS connections. This section covers installing Certbot and generating Let's Encrypt certificates for your Apache configuration.

### Prerequisites for SSL

- **Domain properly configured**: DNS must point to your server
- **Apache virtual host**: Generated Apache configuration file must be installed
- **Port 80 accessible**: Certbot needs HTTP access for domain validation
- **Port 443 available**: HTTPS traffic port

### Installing Certbot

#### Ubuntu/Debian:
```bash
# Update package list
sudo apt update

# Install Certbot and Apache plugin
sudo apt install certbot python3-certbot-apache

# Verify installation
certbot --version
```

#### RHEL/CentOS/Fedora:
```bash
# RHEL/CentOS 8+
sudo dnf install certbot python3-certbot-apache

# RHEL/CentOS 7
sudo yum install certbot python2-certbot-apache

# Fedora
sudo dnf install certbot python3-certbot-apache
```

#### Alternative: Snap Installation (Universal):
```bash
# Install snapd if not already installed
sudo apt install snapd  # Ubuntu/Debian
sudo dnf install snapd  # Fedora

# Install Certbot via snap
sudo snap install --classic certbot

# Create symbolic link
sudo ln -s /snap/bin/certbot /usr/bin/certbot
```

### Generating SSL Certificates

#### Method 1: Automatic Apache Configuration (Recommended)
```bash
# Generate certificate and automatically configure Apache
sudo certbot --apache -d mycompany.example.com

# For multiple domains/subdomains
sudo certbot --apache -d mycompany.example.com -d www.mycompany.example.com
```

**What this does:**
- Validates domain ownership
- Generates SSL certificate
- Automatically modifies Apache virtual host
- Sets up HTTP to HTTPS redirect
- Configures SSL settings

#### Method 2: Certificate Only (Manual Apache Configuration)
```bash
# Generate certificate without modifying Apache config
sudo certbot certonly --apache -d mycompany.example.com

# Alternative: Use webroot method
sudo certbot certonly --webroot -w /var/www/html -d mycompany.example.com
```

### Certificate Information

#### Certificate Locations:
```bash
# Certificate files are stored in:
/etc/letsencrypt/live/mycompany.example.com/

# Key files:
cert.pem        # SSL certificate
chain.pem       # Intermediate certificate
fullchain.pem   # Certificate + intermediate chain
privkey.pem     # Private key (keep secure!)
```

#### Manual Apache SSL Configuration:
If using `certonly`, add to your Apache virtual host:
```apache
<VirtualHost *:443>
    ServerName mycompany.example.com
    
    # SSL Configuration
    SSLEngine on
    SSLCertificateFile /etc/letsencrypt/live/mycompany.example.com/cert.pem
    SSLCertificateKeyFile /etc/letsencrypt/live/mycompany.example.com/privkey.pem
    SSLCertificateChainFile /etc/letsencrypt/live/mycompany.example.com/chain.pem
    
    # Modern SSL configuration
    SSLProtocol all -SSLv3 -TLSv1 -TLSv1.1
    SSLCipherSuite ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384
    SSLHonorCipherOrder off
    SSLSessionTickets off
    
    # Your existing proxy configuration...
</VirtualHost>
```

### Certificate Renewal

#### Automatic Renewal Setup:
```bash
# Test renewal process
sudo certbot renew --dry-run

# Setup automatic renewal (usually installed by default)
sudo systemctl enable certbot.timer
sudo systemctl start certbot.timer

# Check timer status
sudo systemctl status certbot.timer
```

#### Manual Renewal:
```bash
# Renew all certificates
sudo certbot renew

# Renew specific certificate
sudo certbot renew --cert-name mycompany.example.com

# Renew and reload Apache
sudo certbot renew --post-hook "systemctl reload apache2"
```

#### Cron Job for Renewal (Alternative):
```bash
# Add to crontab
sudo crontab -e

# Add this line (runs twice daily)
0 0,12 * * * /usr/bin/certbot renew --quiet --post-hook "systemctl reload apache2"
```

### Testing SSL Configuration

#### Verify Certificate Installation:
```bash
# Check certificate details
openssl x509 -in /etc/letsencrypt/live/mycompany.example.com/cert.pem -text -noout

# Test SSL connection
openssl s_client -connect mycompany.example.com:443 -servername mycompany.example.com

# Check certificate expiration
sudo certbot certificates
```

#### Online SSL Testing:
- **[SSL Labs Test](https://www.ssllabs.com/ssltest/)**: Comprehensive SSL configuration analysis
- **[SSL Checker](https://www.sslshopper.com/ssl-checker.html)**: Quick certificate validation

### Troubleshooting SSL Issues

#### Common Problems:

**Certificate Generation Fails**:
```bash
# Check if domain resolves to your server
nslookup mycompany.example.com

# Verify Apache is running and accessible
curl -I http://mycompany.example.com

# Check Apache error logs
sudo tail -f /var/log/apache2/error.log
```

**Rate Limiting Issues**:
```bash
# Let's Encrypt has rate limits (5 certificates per week per domain)
# Use staging environment for testing:
sudo certbot --apache --staging -d mycompany.example.com

# Remove staging certificate before generating production certificate
sudo certbot delete --cert-name mycompany.example.com
```

**Apache Configuration Conflicts**:
```bash
# Test Apache configuration
sudo apache2ctl configtest

# Reload Apache configuration
sudo systemctl reload apache2

# Check Apache virtual hosts
sudo apache2ctl -S
```

**Port Access Issues**:
```bash
# Check if ports 80 and 443 are open
sudo netstat -tlnp | grep :80
sudo netstat -tlnp | grep :443

# Check firewall settings
sudo ufw status
sudo firewall-cmd --list-all  # For RHEL/CentOS
```

### Security Best Practices

#### SSL Configuration Hardening:
```apache
# Add to your virtual host
Header always set Strict-Transport-Security "max-age=63072000; includeSubDomains; preload"
Header always set X-Content-Type-Options nosniff
Header always set X-Frame-Options DENY
Header always set X-XSS-Protection "1; mode=block"
Header always set Referrer-Policy "strict-origin-when-cross-origin"
```

#### Certificate Monitoring:
```bash
# Monitor certificate expiration
sudo certbot certificates

# Set up monitoring alerts (example with simple script)
cat > /usr/local/bin/check-ssl-expiry.sh << 'EOF'
#!/bin/bash
DOMAIN="mycompany.example.com"
EXPIRY_DATE=$(openssl x509 -in /etc/letsencrypt/live/$DOMAIN/cert.pem -noout -enddate | cut -d= -f2)
EXPIRY_TIMESTAMP=$(date -d "$EXPIRY_DATE" +%s)
CURRENT_TIMESTAMP=$(date +%s)
DAYS_UNTIL_EXPIRY=$(( ($EXPIRY_TIMESTAMP - $CURRENT_TIMESTAMP) / 86400 ))

if [ $DAYS_UNTIL_EXPIRY -lt 30 ]; then
    echo "WARNING: SSL certificate for $DOMAIN expires in $DAYS_UNTIL_EXPIRY days"
    # Add notification logic here (email, Slack, etc.)
fi
EOF

chmod +x /usr/local/bin/check-ssl-expiry.sh

# Add to crontab for daily checks
echo "0 9 * * * /usr/local/bin/check-ssl-expiry.sh" | sudo crontab -
```

### Wildcard Certificates (Advanced)

For wildcard certificates (*.example.com), you need DNS validation:

```bash
# Requires DNS API access or manual DNS record creation
sudo certbot certonly \
  --manual \
  --preferred-challenges dns \
  -d "*.mycompany.example.com" \
  -d "mycompany.example.com"

# Follow prompts to create DNS TXT records
# Verify DNS propagation before pressing Enter
dig TXT _acme-challenge.mycompany.example.com
```

## 💾 Backup and Restore

The deployment tool includes comprehensive backup and restore scripts located in the `backup/` directory that handle both database and file backups automatically.

### Backup Script (`backup/backup.sh`)

The backup script creates complete backups of your Odoo deployment including database and/or filestore data.

#### Features:
- **Flexible Backup Options**: Backup database only, files only, or both
- **Docker Integration**: Works seamlessly with Docker containers
- **Automatic Compression**: Creates timestamped ZIP archives
- **Clean Temporary Files**: Automatically removes temporary files after backup
- **Parameter Validation**: Validates required parameters before execution

#### Usage Examples:

**Database Only Backup**:
```bash
cd backup/
./backup.sh --db mycompany_db --db-container mycompany_db --db-user odoo
```

**Files Only Backup**:
```bash
cd backup/
./backup.sh --odoo-container mycompany_odoo --filedir /var/lib/odoo
```

**Complete Backup (Database + Files)**:
```bash
cd backup/
./backup.sh \
  --db mycompany_db \
  --db-container mycompany_db \
  --db-user odoo \
  --odoo-container mycompany_odoo \
  --filedir /var/lib/odoo
```

**Output**: Creates a timestamped ZIP file like `backup_mycompany_db_20250712_143000.zip`

#### Automated Daily Backups:

Create a cron job for automated backups:
```bash
# Edit crontab
crontab -e

# Add daily backup at 2 AM
0 2 * * * cd /path/to/your/deployment/backup && ./backup.sh --db mycompany_db --db-container mycompany_db --db-user odoo --odoo-container mycompany_odoo --filedir /var/lib/odoo

# Weekly cleanup of old backups (keep last 30 days)
0 3 * * 0 find /path/to/your/deployment/backup -name "backup_*.zip" -mtime +30 -delete
```

### Restore Script (`backup/restore.sh`)

The restore script handles complete restoration from backup ZIP files with intelligent database clearing and file restoration.

#### Features:
- **Selective Restoration**: Restore database only, files only, or both
- **Intelligent Database Clearing**: Efficiently clears existing database content
- **File Ownership Management**: Sets proper permissions for restored files
- **Container Integration**: Works directly with Docker containers
- **Safe Extraction**: Uses temporary directories for safe file handling

#### Usage Examples:

**Database Only Restore**:
```bash
cd backup/
./restore.sh \
  --zip backup_mycompany_db_20250712_143000.zip \
  --db mycompany_db \
  --db-container mycompany_db \
  --db-user odoo
```

**Files Only Restore**:
```bash
cd backup/
./restore.sh \
  --zip backup_mycompany_db_20250712_143000.zip \
  --db mycompany_db \
  --odoo-container mycompany_odoo \
  --filedir /var/lib/odoo
```

**Complete Restore (Database + Files)**:
```bash
cd backup/
./restore.sh \
  --zip backup_mycompany_db_20250712_143000.zip \
  --db mycompany_db \
  --db-container mycompany_db \
  --db-user odoo \
  --odoo-container mycompany_odoo \
  --filedir /var/lib/odoo
```

#### Migration to New Server:

```bash
# 1. On source server - create backup
cd backup/
./backup.sh --db oldserver_db --db-container oldserver_db --db-user odoo --odoo-container oldserver_odoo --filedir /var/lib/odoo

# 2. Transfer backup file to new server
scp backup_oldserver_db_*.zip user@newserver:/path/to/new/deployment/backup/

# 3. On destination server - setup new deployment
./setup.sh  # Configure with new server details

# 4. Start containers first
cd ../newserver.example.com
docker-compose up -d

# 5. Restore from backup
cd backup/
./restore.sh \
  --zip backup_oldserver_db_*.zip \
  --db newserver_db \
  --db-container newserver_db \
  --db-user odoo \
  --odoo-container newserver_odoo \
  --filedir /var/lib/odoo
```

### Backup Best Practices:

1. **Regular Automated Backups**: Set up daily automated backups using cron
2. **Offsite Storage**: Copy backups to external storage (S3, Google Drive, etc.)
3. **Test Restores**: Regularly test restore procedures on staging environments
4. **Monitor Backup Size**: Keep track of backup file sizes and storage usage
5. **Retention Policy**: Implement automatic cleanup of old backups

### Troubleshooting Backup/Restore:

**Permission Issues**:
```bash
# If restore fails with permission errors
docker exec mycompany_odoo chown -R odoo:odoo /var/lib/odoo
```

**Large Database Restore**:
```bash
# For very large databases, increase PostgreSQL memory settings temporarily
docker exec mycompany_db psql -U odoo -c "SET shared_buffers = '256MB'; SET work_mem = '32MB';"
```

**Container Not Running**:
```bash
# Ensure containers are running before backup/restore
docker-compose ps
docker-compose up -d  # Start if not running
```

## 🔧 Directory Structure Created

```
../mycompany.example.com/
├── docker-compose.yml          # Generated Docker Compose file
├── mycompany.example.com.conf   # Generated Apache virtual host
├── addons/
│   └── README.md              # Custom addons directory documentation
├── backup/
│   └── README.md              # Backup directory documentation
├── config/
│   ├── README.md              # Configuration directory documentation
│   └── odoo.conf              # Generated Odoo configuration
├── data/
│   └── README.md              # Data directory documentation (Odoo filestore)
└── db/
    └── README.md              # Database directory documentation (PostgreSQL data)
```

Each directory includes its own README.md file explaining its purpose and contents.

## 🛠️ Troubleshooting

### Setup Script Issues

**❌ "Permission denied" or "Operation not permitted" errors:**
```bash
# SOLUTION: Run the script with sudo privileges
sudo ./setup.sh

# The script requires root access to:
# - Create directories with specific ownership (100:101)
# - Set proper permissions for Docker volumes
# - Ensure secure file handling
```

**❌ "setup.json not found" error:**
```bash
# SOLUTION: Create setup.json from template first
cp setup-template.json setup.json

# Then edit setup.json with your configuration values
nano setup.json  # or use your preferred editor
```

**❌ "bash: ./setup.sh: Permission denied":**
```bash
# SOLUTION: Set execute permissions on the script
chmod +x setup.sh

# Then run with sudo
sudo ./setup.sh
```

**❌ "jq: command not found":**
```bash
# SOLUTION: Install jq JSON processor
# Ubuntu/Debian:
sudo apt-get install jq

# RHEL/CentOS:
sudo yum install jq

# Fedora:
sudo dnf install jq
```

**❌ Script runs but creates wrong permissions:**
```bash
# ISSUE: Script was run without sudo
# SOLUTION: Remove the created directory and run with sudo
rm -rf ../your-hostname.com
sudo ./setup.sh
```

### Common Runtime Issues

**Port conflicts**:
```bash
# Check if ports are in use
sudo netstat -tulpn | grep :8069
sudo netstat -tulpn | grep :8072
```

**Database connection issues**:
```bash
# Check database logs
docker logs mycompany_db

# Check Odoo logs
docker logs mycompany_odoo
```

**Permission issues**:
```bash
# Fix file permissions
sudo chown -R 101:101 ./data
sudo chown -R 999:999 ./db
```

## 📈 Scaling and Performance

### Horizontal Scaling
- Use Docker Swarm or Kubernetes for multi-node deployment
- Implement external PostgreSQL for database clustering
- Use Redis for session storage in multi-instance setups

### Performance Optimization
- Adjust worker configuration in odoo.conf
- Implement nginx for static file serving
- Use PostgreSQL connection pooling
- Monitor with tools like Prometheus + Grafana

## 🤝 Contributing

Contributions are welcome! Please follow these guidelines:

1. Fork the repository
2. Create a feature branch
3. Test your changes thoroughly
4. Submit a pull request with detailed description

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 👤 Credits

**Developer**: Gilson Rincón  
**Company**: Solutto Consulting

### About Solutto Consulting

Solutto Consulting is a digital transformation company that helps businesses of all sizes streamline operations and scale with confidence. We specialize in implementing innovative, open-source solutions that address complex business challenges while maintaining budget-friendly approaches.

**Our Services:**

- **Odoo ERP Implementation**: Complete setup and customization of Odoo systems to unify finance, sales, inventory, and operations into seamless workflows
- **AI Chatbots & Business Process Automation (BPA)**: Smart automation solutions that reduce manual tasks and boost response times through intelligent workflow integration
- **AppSheet No-Code Apps**: Custom no-code applications for logistics, inspections, approvals, and specialized business processes
- **Managed Hosting**: Secure, fast, and scalable hosting solutions for Odoo and Moodle platforms with enterprise-grade performance

Whether you're a startup with big plans or an established enterprise looking to modernize, Solutto Consulting delivers ERP, e-learning, automation, and AI solutions that are fast, flexible, and built to last.

**Contact Information:**
- Website: [soluttoconsulting.com](https://soluttoconsulting.com)
- Email: info@soluttoconsulting.com
- Phone: +1 786 840 0476
- Location: Orlando, FL, United States

---

*Built with ❤️ for the Odoo community*

## 🌐 Recommended Hosting: Hetzner Cloud

**Deploy your Odoo instance on reliable, high-performance infrastructure!**

We recommend **Hetzner Cloud** for hosting your Odoo deployment. Hetzner offers exceptional value with powerful VPS instances, dedicated servers, and enterprise-grade infrastructure at competitive prices.

### Why Choose Hetzner?

- ⚡ **High Performance**: State-of-the-art hardware with AMD EPYC processors and NVMe SSDs
- 🌍 **Global Locations**: Data centers in Germany, Finland, USA, and Singapore
- 💰 **Competitive Pricing**: Cloud servers starting from €3.79/month, dedicated servers from €37.30/month
- 🔒 **Security & Reliability**: ISO 27001 certified with 99.9% uptime SLA
- 🚀 **Scalable**: Easily scale resources up or down as your business grows
- 🛠️ **Developer Friendly**: Full API access, Docker support, and extensive documentation

### Perfect for Odoo Deployments

Hetzner Cloud provides the ideal environment for containerized Odoo deployments:
- **Docker-optimized instances** with excellent performance
- **Flexible storage options** for growing databases and filestores
- **Reliable network** for consistent user experience
- **Snapshot and backup capabilities** for data protection

### Get Started with €20 FREE Credit! 🎁

**[👉 Sign up with Hetzner Cloud here](https://hetzner.cloud/?ref=wXmhFZiVG5Ev)** and receive **€20 in free credits** to test and deploy your Odoo instance!

*This referral link supports the development of this deployment tool while giving you free credits to get started.*

#### Recommended Specifications for Odoo:

**Small Business (1-10 users)**:
- **CX21**: 2 vCPUs, 4 GB RAM, 40 GB SSD - €4.51/month
- Suitable for basic Odoo deployments with light usage

**Medium Business (10-50 users)**:
- **CX31**: 2 vCPUs, 8 GB RAM, 80 GB SSD - €8.21/month
- Recommended for standard Odoo deployments

**Large Business (50+ users)**:
- **CX41**: 4 vCPUs, 16 GB RAM, 160 GB SSD - €15.51/month
- Ideal for production environments with heavy usage

**[Start your free trial today →](https://hetzner.cloud/?ref=wXmhFZiVG5Ev)**
