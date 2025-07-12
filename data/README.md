# Data Directory

This directory contains the Odoo filestore - all user-uploaded files and attachments.

## 📁 What's Stored Here

### File Types:
- **Document Attachments**: Files uploaded to records (invoices, contracts, etc.)
- **Product Images**: Photos and images for products and services
- **User Avatars**: Profile pictures for users and contacts
- **Report Templates**: Custom report templates and letterheads
- **Website Assets**: Images and files used on Odoo websites
- **Email Attachments**: Files attached to emails sent/received through Odoo

### Directory Structure:
```
data/
├── filestore/           # Main filestore (organized by database name)
│   └── [database_name]/
│       ├── 00/         # File storage (organized in hex subdirectories)
│       ├── 01/
│       ├── 02/
│       └── ...
└── sessions/           # User session data (temporary)
```

## 🔒 Security & Permissions

- **Owner**: Files should be owned by the `odoo` user (UID 101 in container)
- **Permissions**: Directory should have `755` permissions, files `644`
- **Backup Critical**: This data is **essential** and should be backed up regularly

## 💾 Backup Considerations

### What to Backup:
- ✅ **Include in backups**: All filestore data is critical
- ✅ **Regular backups**: Files change frequently with user activity
- ⚠️ **Large size**: Can grow significantly with usage

### Backup Methods:
- Use the provided `backup.sh` script for automated backups
- Includes both database and filestore in a single ZIP archive
- Consider incremental backups for large filestores

## 🚨 Important Warnings

### DO NOT:
- ❌ **Delete this directory**: Will cause loss of all uploaded files
- ❌ **Modify files directly**: Can corrupt attachments and break references
- ❌ **Change ownership**: Can prevent Odoo from accessing files
- ❌ **Move files manually**: File references are stored in the database

### Safe Operations:
- ✅ **Backup regularly**: Use automated backup scripts
- ✅ **Monitor disk space**: Filestore can grow large
- ✅ **Restore from backups**: Use provided restore scripts only

## 🔧 Troubleshooting

### Permission Issues:
```bash
# Fix ownership if Odoo can't access files
docker exec [odoo_container] chown -R odoo:odoo /var/lib/odoo
```

### Disk Space Issues:
```bash
# Check filestore size
du -sh data/

# Check largest files (if needed for cleanup)
find data/ -type f -size +100M -ls
```

### File Not Found Errors:
- Usually indicates missing files or permission issues
- Check Odoo logs for specific file paths
- Restore from backup if files are actually missing

## 📊 Monitoring

### Regular Checks:
- **Disk usage**: Monitor available space
- **File count**: Track growth over time
- **Backup success**: Verify backups include filestore
- **Access permissions**: Ensure Odoo can read/write files

## 🔄 Migration

When migrating to a new server:
1. Use the backup script to create a complete backup
2. Transfer the backup file to the new server
3. Use the restore script to restore both database and filestore
4. Verify file permissions after restoration

---

## 🌐 Need Hosting? Try Hetzner Cloud!

Deploy your Odoo filestore on reliable, high-performance infrastructure with **Hetzner Cloud**.

**[Get €20 FREE credit with Hetzner →](https://hetzner.cloud/?ref=wXmhFZiVG5Ev)**

Perfect for Odoo deployments with fast NVMe SSDs, automatic backups, and scalable storage starting from just €3.79/month.
