# Database Directory

This directory contains PostgreSQL database files and is managed entirely by the database container.

## 📁 What's Stored Here

### PostgreSQL Data:
- **Database files**: Core PostgreSQL data files (.db, .dat, etc.)
- **Transaction logs**: Write-ahead logs (WAL) for data integrity
- **Configuration**: PostgreSQL-specific configuration files
- **Indexes**: Database indexes for query performance
- **Statistics**: Query optimization statistics

### Directory Structure:
```
db/
├── base/              # Database cluster base directory
├── global/            # Cluster-wide tables
├── pg_wal/            # Write-ahead logs
├── pg_stat/           # Statistics files
├── pg_tblspc/         # Tablespace directory
└── postgresql.conf    # PostgreSQL configuration
```

## 🔒 Security & Permissions

- **Owner**: Files are owned by the `postgres` user (UID 999 in container)
- **Permissions**: Managed automatically by PostgreSQL
- **Access**: Only the database container should access these files directly

## ⚠️ Critical Warnings

### NEVER DO:
- ❌ **Edit files directly**: Will corrupt the database
- ❌ **Delete this directory**: Will cause complete data loss
- ❌ **Copy while running**: Can create inconsistent backups
- ❌ **Change permissions**: Can prevent PostgreSQL from starting
- ❌ **Access from host**: Always use database commands through container

### Database Operations:
- ✅ **Use pg_dump**: For logical backups (handled by backup script)
- ✅ **Stop container first**: Before any file-level operations
- ✅ **Use PostgreSQL tools**: pg_basebackup for physical backups
- ✅ **Monitor space**: Database can grow significantly

## 💾 Backup Strategy

### Logical Backups (Recommended):
```bash
# Use the provided backup script
cd backup/
./backup.sh --db [database_name] --db-container [db_container] --db-user odoo
```

### Physical Backups (Advanced):
```bash
# Stop services first
docker-compose stop

# Create physical backup
tar -czf db_physical_backup.tar.gz db/

# Restart services
docker-compose start
```

## 🔧 Maintenance

### Regular Tasks:
- **Monitor disk space**: Database files can grow large
- **Check logs**: Look for errors in PostgreSQL logs
- **Vacuum database**: Regular maintenance for performance
- **Update statistics**: Keep query planner statistics current

### Performance Monitoring:
```bash
# Check database size
docker exec [db_container] psql -U odoo -c "SELECT pg_size_pretty(pg_database_size('odoo'));"

# Check connection count
docker exec [db_container] psql -U odoo -c "SELECT count(*) FROM pg_stat_activity;"
```

## 🚨 Disaster Recovery

### If Database Won't Start:
1. Check container logs: `docker logs [db_container]`
2. Verify file permissions and ownership
3. Check available disk space
4. Look for corruption in PostgreSQL logs

### Database Corruption:
1. **Stop all services immediately**
2. **Do not attempt repairs** without expertise
3. **Restore from latest backup** using restore script
4. **Contact PostgreSQL expert** if backup is unavailable

### Recovery Steps:
```bash
# Stop all services
docker-compose down

# Remove corrupted database (DANGER!)
sudo rm -rf db/*

# Restore from backup
cd backup/
./restore.sh --zip [backup_file] --db [database] --db-container [container] --db-user odoo

# Start services
docker-compose up -d
```

## 📊 Monitoring & Alerts

### Key Metrics:
- **Disk usage**: Monitor available space
- **Connection count**: Track concurrent connections
- **Query performance**: Monitor slow queries
- **Backup success**: Verify regular backups complete

### Useful Commands:
```bash
# Database size
docker exec [db_container] psql -U odoo -c "\\l+"

# Table sizes
docker exec [db_container] psql -U odoo -d odoo -c "SELECT schemaname,tablename,pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) as size FROM pg_tables ORDER BY pg_total_relation_size(schemaname||'.'||tablename) DESC LIMIT 10;"

# Active connections
docker exec [db_container] psql -U odoo -c "SELECT datname, count(*) FROM pg_stat_activity GROUP BY datname;"
```

## 🔄 Version Upgrades

When upgrading PostgreSQL:
1. **Backup database first** (logical backup with pg_dump)
2. **Test upgrade** on staging environment
3. **Follow PostgreSQL upgrade procedures**
4. **Verify data integrity** after upgrade
5. **Update connection strings** if needed

---

## 🌐 Need Hosting? Try Hetzner Cloud!

Deploy your PostgreSQL database on reliable, enterprise-grade infrastructure with **Hetzner Cloud**.

**[Get €20 FREE credit with Hetzner →](https://hetzner.cloud/?ref=wXmhFZiVG5Ev)**

Perfect for database workloads with high-performance NVMe SSDs, guaranteed resources, and 99.9% uptime SLA starting from just €3.79/month.
