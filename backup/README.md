# Backup Directory

This directory stores backup files created by the automated backup scripts and serves as the working directory for backup and restore operations.

## 📁 Purpose

The `backup` directory serves multiple functions:
- **Storage location** for automated backup files
- **Working directory** for backup and restore scripts
- **Staging area** for backup transfers and migrations
- **Archive location** for historical backups

## 📂 Directory Contents

```
backup/
├── README.md                           # This documentation
├── backup_[database]_[timestamp].zip   # Automated backup files
├── manual_backup_[date].zip            # Manual backup files
└── temp_restore_files/                 # Temporary files during restore (auto-cleaned)
```

## 💾 Backup Files

### Automated Backups:
- **Naming convention**: `backup_[database_name]_YYYYMMDD_HHMMSS.zip`
- **Contents**: Database dump + filestore (if specified)
- **Compression**: ZIP format for easy transfer and storage
- **Timestamps**: UTC timestamps for consistency

### Example Files:
```
backup_mycompany_db_20250712_143000.zip    # Complete backup
backup_mycompany_db_20250711_020000.zip    # Previous day backup
backup_production_20250710_143000.zip      # Different database backup
```

## 🔧 Backup Operations

### Creating Backups:

**Database Only**:
```bash
./backup.sh --db mycompany_db --db-container mycompany_db --db-user odoo
```

**Complete Backup (Database + Files)**:
```bash
./backup.sh \
  --db mycompany_db \
  --db-container mycompany_db \
  --db-user odoo \
  --odoo-container mycompany_odoo \
  --filedir /var/lib/odoo
```

**Files Only**:
```bash
./backup.sh --odoo-container mycompany_odoo --filedir /var/lib/odoo
```

### Restore Operations:

**Complete Restore**:
```bash
./restore.sh \
  --zip backup_mycompany_db_20250712_143000.zip \
  --db mycompany_db \
  --db-container mycompany_db \
  --db-user odoo \
  --odoo-container mycompany_odoo \
  --filedir /var/lib/odoo
```

## 📋 Backup Scripts

### `backup.sh`
**Features**:
- Flexible backup options (database, files, or both)
- Docker container integration
- Automatic compression and timestamping
- Parameter validation and error handling
- Cleanup of temporary files

**Parameters**:
- `--db`: Database name to backup
- `--db-container`: PostgreSQL container name
- `--db-user`: Database user for pg_dump
- `--odoo-container`: Odoo container name (for file backup)
- `--filedir`: Directory path in container to backup

### `restore.sh`
**Features**:
- Selective restoration options
- Intelligent database clearing
- File ownership management
- Safe temporary file handling
- Comprehensive error checking

**Parameters**:
- `--zip`: Backup file to restore from
- `--db`: Target database name
- `--db-container`: PostgreSQL container name
- `--db-user`: Database user for restore
- `--odoo-container`: Odoo container name (for file restore)
- `--filedir`: Target directory path in container

## 🔒 Security & Permissions

### File Security:
- **Backup files contain sensitive data**: Protect with appropriate permissions
- **Database dumps**: Include user data and potentially sensitive information
- **File backups**: May contain uploaded documents and attachments

### Recommended Permissions:
```bash
# Secure backup directory
chmod 750 backup/
chmod 640 backup/*.zip

# Ensure proper ownership
chown -R user:backup-group backup/
```

### Access Control:
- **Limit access** to backup files to authorized personnel only
- **Use encryption** for backups stored on external systems
- **Implement retention policies** to automatically remove old backups

## 📊 Backup Management

### Automated Cleanup:
```bash
# Remove backups older than 30 days
find backup/ -name "backup_*.zip" -mtime +30 -delete

# Keep only last 10 backups
ls -t backup/backup_*.zip | tail -n +11 | xargs rm -f
```

### Cron Job Example:
```bash
# Daily backup at 2 AM
0 2 * * * cd /path/to/deployment/backup && ./backup.sh --db mycompany_db --db-container mycompany_db --db-user odoo --odoo-container mycompany_odoo --filedir /var/lib/odoo

# Weekly cleanup (keep 30 days)
0 3 * * 0 find /path/to/deployment/backup -name "backup_*.zip" -mtime +30 -delete
```

### Monitoring:
```bash
# Check backup sizes
du -sh backup/*.zip

# Count backup files
ls -1 backup/backup_*.zip | wc -l

# Check latest backup
ls -lt backup/backup_*.zip | head -1
```

## 🌐 Offsite Storage

### Cloud Storage Integration:
```bash
# AWS S3 sync
aws s3 sync backup/ s3://my-odoo-backups/mycompany/

# Google Drive (using rclone)
rclone copy backup/ gdrive:OdooBackups/mycompany/

# rsync to remote server
rsync -av backup/ user@backup-server:/backups/odoo/mycompany/
```

### Encryption for Transport:
```bash
# Encrypt backup before transfer
gpg --cipher-algo AES256 --compress-algo 1 --symmetric backup_file.zip

# Decrypt when needed
gpg --decrypt backup_file.zip.gpg > backup_file.zip
```

## ⚠️ Important Notes

### Backup Validation:
- **Test restores regularly**: Ensure backups are actually restorable
- **Verify file integrity**: Check ZIP file integrity after creation
- **Monitor backup sizes**: Unusual size changes may indicate issues

### Storage Considerations:
- **Disk space**: Monitor available space in backup directory
- **Growth rate**: Database and filestore grow over time
- **Retention policy**: Balance storage costs with recovery requirements

### Disaster Recovery:
- **Document procedures**: Keep restore procedures documented
- **Test scenarios**: Practice restore in non-production environments
- **Multiple locations**: Store backups in multiple geographic locations

## 🔄 Migration Workflows

### Server Migration:
1. **Create complete backup** on source server
2. **Transfer backup file** to destination server
3. **Setup new deployment** with updated configuration
4. **Restore backup** on new server
5. **Verify functionality** and update DNS

### Environment Promotion:
```bash
# Promote staging to production
./backup.sh --db staging_db --db-container staging_db --db-user odoo --odoo-container staging_odoo --filedir /var/lib/odoo
./restore.sh --zip backup_staging_db_*.zip --db production_db --db-container production_db --db-user odoo --odoo-container production_odoo --filedir /var/lib/odoo
```

## 🛠️ Troubleshooting

### Backup Failures:
1. **Check disk space**: Ensure sufficient space for backup files
2. **Verify container status**: Ensure Docker containers are running
3. **Check permissions**: Verify script has necessary permissions
4. **Review logs**: Check container logs for database errors

### Restore Issues:
1. **Validate ZIP file**: Ensure backup file is not corrupted
2. **Check target containers**: Ensure destination containers are running
3. **Verify parameters**: Double-check container names and paths
4. **Monitor resources**: Large restores may require time and memory

### Performance Optimization:
```bash
# Compress backups more efficiently
zip -r -9 backup.zip files/  # Maximum compression

# Parallel compression for large files
pigz -p 4 large_backup.sql   # Use 4 CPU cores
```

---

## 🌐 Need Hosting? Try Hetzner Cloud!

Store your Odoo backups securely on reliable, enterprise-grade infrastructure with **Hetzner Cloud**.

**[Get €20 FREE credit with Hetzner →](https://hetzner.cloud/?ref=wXmhFZiVG5Ev)**

Perfect for backup storage with additional Storage Boxes, automated snapshots, and scalable infrastructure starting from just €3.79/month.
