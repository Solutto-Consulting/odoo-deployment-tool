# Config Directory

This directory contains configuration files for your Odoo deployment.

## 📁 Contents

### `odoo.conf`
The main Odoo configuration file that controls how your Odoo instance operates.

**Key Settings:**
- **Database Connection**: PostgreSQL connection parameters (host, user, password)
- **Proxy Configuration**: Settings for running behind Apache/nginx reverse proxy
- **Addons Path**: Locations where Odoo looks for additional modules
- **Security**: Admin password and database filtering rules
- **Performance**: Worker processes and memory settings

**Generated from**: `config/odoo-template.conf` using the setup script

## 🔧 Customization

You can modify `odoo.conf` after generation to adjust:
- Database settings
- Worker configuration for performance
- Logging levels
- Additional addons paths
- Security settings

## ⚠️ Important Notes

- **Backup before changes**: Always backup this file before making modifications
- **Restart required**: Changes require restarting the Odoo container
- **Version compatibility**: Some settings may vary between Odoo versions
- **Security**: Keep admin passwords secure and use strong credentials

## 🔄 Regeneration

To regenerate this configuration:
1. Update `setup.json` with new values
2. Run `./setup.sh` from the template directory
3. The script will create a new configuration file

## 📖 Reference

For complete Odoo configuration options, see:
- [Odoo Configuration Documentation](https://www.odoo.com/documentation/18.0/administration/install/deploy.html)
- [Docker Deployment Guide](https://hub.docker.com/_/odoo)

---

## 🌐 Need Hosting? Try Hetzner Cloud!

Deploy your Odoo configuration on reliable, high-performance infrastructure with **Hetzner Cloud**.

**[Get €20 FREE credit with Hetzner →](https://hetzner.cloud/?ref=wXmhFZiVG5Ev)**

Perfect for Odoo deployments with Docker support, scalable resources, and enterprise-grade reliability starting from just €3.79/month.
