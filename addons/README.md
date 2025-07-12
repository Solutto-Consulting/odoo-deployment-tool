# Addons Directory

This directory contains custom Odoo addons (modules) specific to your deployment.

## 📁 Purpose

The `addons` directory is mounted into the Odoo container at `/mnt/extra-addons` and is included in the addons path configuration. This allows you to:

- **Install custom modules**: Place your own developed modules here
- **Add third-party modules**: Install community or purchased modules
- **Override existing modules**: Customize standard Odoo functionality
- **Develop locally**: Create and test new modules during development

## 📂 Directory Structure

```
addons/
├── my_custom_module/          # Example custom module
│   ├── __manifest__.py        # Module manifest file
│   ├── __init__.py           # Module initialization
│   ├── models/               # Data models
│   ├── views/                # XML views and templates
│   ├── static/               # CSS, JS, images
│   └── security/             # Access rights and rules
├── another_module/
└── README.md                 # This documentation
```

## 🔧 Adding Modules

### Method 1: Manual Installation
1. **Download/develop** your module
2. **Extract/place** the module folder in this directory
3. **Restart Odoo container**: `docker-compose restart [odoo_container]`
4. **Update module list** in Odoo: Apps → Update Apps List
5. **Install module** through Odoo interface

### Method 2: Git Submodules (Recommended)
```bash
# Add a module as git submodule
git submodule add https://github.com/user/odoo-module.git addons/module_name

# Update submodules
git submodule update --init --recursive
```

### Method 3: Development Modules
```bash
# Create new module structure
mkdir -p addons/my_new_module/{models,views,static,security}
cd addons/my_new_module

# Create manifest file
cat > __manifest__.py << 'EOF'
{
    'name': 'My New Module',
    'version': '18.0.1.0.0',
    'depends': ['base'],
    'data': [
        'security/ir.model.access.csv',
        'views/views.xml',
    ],
    'installable': True,
    'auto_install': False,
}
EOF
```

## 🔒 Security & Permissions

- **Owner**: Files should be readable by the `odoo` user (UID 101)
- **Permissions**: Directories `755`, files `644`
- **Security files**: Always include proper access control files

```bash
# Fix permissions if needed
sudo chown -R 101:101 addons/
sudo find addons/ -type d -exec chmod 755 {} \;
sudo find addons/ -type f -exec chmod 644 {} \;
```

## 📋 Module Requirements

### Essential Files:
- ✅ **`__manifest__.py`**: Module declaration and dependencies
- ✅ **`__init__.py`**: Python package initialization
- ✅ **`security/ir.model.access.csv`**: Access rights (if needed)

### Optional Files:
- **`models/`**: Python model definitions
- **`views/`**: XML view definitions
- **`static/`**: Web assets (CSS, JS, images)
- **`data/`**: Default data files
- **`demo/`**: Demo data for testing
- **`i18n/`**: Translation files

## ⚠️ Important Notes

### Module Dependencies:
- **Check dependencies**: Ensure all required modules are available
- **Version compatibility**: Verify modules are compatible with your Odoo version
- **Community vs Enterprise**: Some modules require Odoo Enterprise

### Best Practices:
- ✅ **Test in staging**: Always test new modules before production
- ✅ **Backup before changes**: Create backups before installing modules
- ✅ **Version control**: Use git for custom module development
- ✅ **Document changes**: Keep track of installed custom modules

### Avoid:
- ❌ **Modifying core modules**: Never edit standard Odoo modules directly
- ❌ **Unsafe modules**: Only install modules from trusted sources
- ❌ **Missing dependencies**: Always install required dependencies first

## 🔄 Module Management

### Installing Modules:
```bash
# Restart Odoo to recognize new modules
docker-compose restart [odoo_container]

# Or update apps list via CLI
docker exec [odoo_container] odoo -d [database] -u base --stop-after-init
```

### Updating Modules:
```bash
# Update specific module
docker exec [odoo_container] odoo -d [database] -u module_name --stop-after-init

# Update all modules
docker exec [odoo_container] odoo -d [database] -u all --stop-after-init
```

### Uninstalling Modules:
1. **Uninstall via Odoo interface**: Apps → Installed → Uninstall
2. **Remove module files** from addons directory
3. **Restart container** to clean module list

## 🛠️ Development Tips

### Creating Custom Modules:
- Use **Odoo scaffold** for module templates
- Follow **OCA guidelines** for code quality
- Implement proper **error handling**
- Include **comprehensive documentation**

### Testing Modules:
```bash
# Run Odoo with test mode
docker exec [odoo_container] odoo -d test_db --test-enable --stop-after-init
```

### Debugging:
- Enable **developer mode** in Odoo
- Check **server logs** for errors
- Use **pdb** for Python debugging
- Test in **separate database** first

## 📦 Popular Module Sources

### Community Resources:
- **[OCA (Odoo Community Association)](https://github.com/OCA)**: High-quality community modules
- **[Odoo Apps Store](https://apps.odoo.com)**: Official and community modules
- **[GitHub](https://github.com/search?q=odoo+modules)**: Open source modules

### Enterprise Modules:
- Available through **Odoo Enterprise** subscription
- Include advanced features and support
- Automatically updated with Odoo releases

## 🔍 Troubleshooting

### Module Not Appearing:
1. Check file permissions
2. Verify `__manifest__.py` syntax
3. Restart Odoo container
4. Update apps list in Odoo

### Installation Errors:
1. Check module dependencies
2. Review Odoo logs for specific errors
3. Verify database permissions
4. Test module in isolation

### Performance Issues:
1. Monitor resource usage during installation
2. Check for conflicting modules
3. Review module code for inefficiencies
4. Consider module loading order

---

## 🌐 Need Hosting? Try Hetzner Cloud!

Deploy your Odoo addons on reliable, high-performance infrastructure with **Hetzner Cloud**.

**[Get €20 FREE credit with Hetzner →](https://hetzner.cloud/?ref=wXmhFZiVG5Ev)**

Perfect for development and production Odoo deployments with fast Docker support, flexible scaling, and developer-friendly features starting from just €3.79/month.
