#!/bin/bash

# =========================================
# Odoo Restore Script
#
# This script restores an Odoo database and/or files from a backup zip file to a running Docker environment.
# It supports restoring only the database, only the files, or both from a backup zip.
#
# Usage:
#   ./restore.sh --zip ZIPFILE [--db DB_NAME --db-container DB_CONTAINER --db-user DB_USER] [--odoo-container ODOO_CONTAINER --filedir FILEDIR] [--help]
#
# Parameters:
#   --zip ZIPFILE            Path to the backup zip file to restore from
#   --db DB_NAME             Name of the database to restore to (PostgreSQL)
#   --db-container NAME      Name of the PostgreSQL Docker container
#   --db-user USER           Database user for psql/createdb
#   --odoo-container NAME    Name of the Odoo Docker container (required for file restore)
#   --filedir DIR            Absolute path in Odoo container to restore files to (e.g. /mnt/extra-addons)
#   --help                   Show this help message and exit
#
# Examples:
#   Restore only DB:
#     ./restore.sh --zip backup_mydb_20250712_143000.zip --db mydb --db-container pg_container --db-user odoo
#   Restore only files (requires --db for destination folder):
#     ./restore.sh --zip backup_mydb_20250712_143000.zip --db mydb --odoo-container odoo_container --filedir /data/files
#   Restore both:
#     ./restore.sh --zip backup_mydb_20250712_143000.zip --db mydb --db-container pg_container --db-user odoo --odoo-container odoo_container --filedir /data/files
# =========================================

# Parse parameters
SHOW_HELP=0
while [[ "$#" -gt 0 ]]; do
    key="$1"
    case $key in
        --zip)
            ZIPFILE="$2"
            shift; shift
            ;;
        --db)
            DB_NAME="$2"
            shift; shift
            ;;
        --odoo-container)
            ODOO_CONTAINER="$2"
            shift; shift
            ;;
        --db-container)
            DB_CONTAINER="$2"
            shift; shift
            ;;
        --db-user)
            DB_USER="$2"
            shift; shift
            ;;
        --filedir)
            FILEDIR="$2"
            shift; shift
            ;;
        --help)
            SHOW_HELP=1
            shift
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

if [[ $SHOW_HELP -eq 1 ]]; then
    echo ""
    grep '^#' "$0" | sed 's/^# \{0,1\}//'
    exit 0
fi

# Check that zip file is provided and exists
if [[ -z "$ZIPFILE" ]]; then
    echo "Error: --zip parameter is required."
    exit 1
fi

if [[ ! -f "$ZIPFILE" ]]; then
    echo "Error: Zip file '$ZIPFILE' does not exist."
    exit 1
fi

# Check that at least one restore type is requested
if [[ -z "$DB_NAME" && -z "$FILEDIR" ]]; then
    echo "Error: You must specify at least --db (with --db-container and --db-user) or --filedir (with --odoo-container and --db for destination folder)."
    exit 1
fi

# If file restore is requested, DB_NAME is required for the destination path
if [[ -n "$FILEDIR" && -z "$DB_NAME" ]]; then
    echo "Error: --db parameter is required when using --filedir to determine the destination folder (filedir/db)."
    exit 1
fi

# Create temporary extraction directory
TEMP_DIR="restore_temp_$(date +%s)"
mkdir -p "$TEMP_DIR"

echo "Extracting backup zip file: $ZIPFILE to $TEMP_DIR..."
unzip -q "$ZIPFILE" -d "$TEMP_DIR"
if [[ $? -ne 0 ]]; then
    echo "Error: Failed to extract zip file."
    rm -rf "$TEMP_DIR"
    exit 1
fi

# -----------------------------------------
# Database restore (if requested)
# -----------------------------------------
if [[ -n "$DB_NAME" ]]; then
    # Check required DB parameters
    if [[ -z "$DB_CONTAINER" || -z "$DB_USER" ]]; then
        echo "Error: --db-container and --db-user are required for database restore."
        rm -rf "$TEMP_DIR"
        exit 1
    fi
    
    # Check if dump.sql exists in extracted files
    if [[ ! -f "$TEMP_DIR/dump.sql" ]]; then
        echo "Error: dump.sql not found in backup zip."
        rm -rf "$TEMP_DIR"
        exit 1
    fi
    
    echo "Checking if database $DB_NAME exists..."
    DB_EXISTS=$(docker exec "$DB_CONTAINER" psql -U "$DB_USER" -lqt | cut -d \| -f 1 | grep -w "$DB_NAME" | wc -l)
    
    if [[ $DB_EXISTS -eq 0 ]]; then
        echo "Database $DB_NAME does not exist. Creating it..."
        docker exec "$DB_CONTAINER" createdb -U "$DB_USER" "$DB_NAME"
        if [[ $? -ne 0 ]]; then
            echo "Error: Failed to create database $DB_NAME."
            rm -rf "$TEMP_DIR"
            exit 1
        fi
    else
        echo "Database $DB_NAME exists. Clearing all tables..."
        # Use a more efficient approach to clear the database
        # First, disable all triggers and constraints
        docker exec "$DB_CONTAINER" psql -U "$DB_USER" "$DB_NAME" -c "
        SET session_replication_role = replica;
        "
        
        # Drop all tables in batches to avoid memory issues
        echo "Dropping all tables..."
        docker exec "$DB_CONTAINER" psql -U "$DB_USER" "$DB_NAME" -c "
        DO \$\$ 
        DECLARE
            r RECORD;
            batch_count INTEGER := 0;
        BEGIN
            -- Drop tables in smaller batches
            FOR r IN (SELECT tablename FROM pg_tables WHERE schemaname = 'public' ORDER BY tablename) LOOP
                EXECUTE 'DROP TABLE IF EXISTS ' || quote_ident(r.tablename) || ' CASCADE';
                batch_count := batch_count + 1;
                -- Commit every 50 tables to free memory
                IF batch_count % 50 = 0 THEN
                    COMMIT;
                END IF;
            END LOOP;
        END \$\$;
        "
        
        # Drop sequences
        echo "Dropping all sequences..."
        docker exec "$DB_CONTAINER" psql -U "$DB_USER" "$DB_NAME" -c "
        DO \$\$ 
        DECLARE
            r RECORD;
        BEGIN
            FOR r IN (SELECT sequence_name FROM information_schema.sequences WHERE sequence_schema = 'public') LOOP
                EXECUTE 'DROP SEQUENCE IF EXISTS ' || quote_ident(r.sequence_name) || ' CASCADE';
            END LOOP;
        END \$\$;
        "
        
        # Drop views
        echo "Dropping all views..."
        docker exec "$DB_CONTAINER" psql -U "$DB_USER" "$DB_NAME" -c "
        DO \$\$ 
        DECLARE
            r RECORD;
        BEGIN
            FOR r IN (SELECT viewname FROM pg_views WHERE schemaname = 'public') LOOP
                EXECUTE 'DROP VIEW IF EXISTS ' || quote_ident(r.viewname) || ' CASCADE';
            END LOOP;
        END \$\$;
        "
        
        # Drop functions
        echo "Dropping all functions..."
        docker exec "$DB_CONTAINER" psql -U "$DB_USER" "$DB_NAME" -c "
        DO \$\$ 
        DECLARE
            r RECORD;
        BEGIN
            FOR r IN (SELECT proname, oidvectortypes(proargtypes) as argtypes 
                     FROM pg_proc p JOIN pg_namespace n ON p.pronamespace = n.oid 
                     WHERE n.nspname = 'public') LOOP
                EXECUTE 'DROP FUNCTION IF EXISTS ' || quote_ident(r.proname) || '(' || r.argtypes || ') CASCADE';
            END LOOP;
        END \$\$;
        "
        
        # Re-enable triggers
        docker exec "$DB_CONTAINER" psql -U "$DB_USER" "$DB_NAME" -c "
        SET session_replication_role = DEFAULT;
        "
        
        if [[ $? -ne 0 ]]; then
            echo "Error: Failed to clear tables from database $DB_NAME."
            rm -rf "$TEMP_DIR"
            exit 1
        fi
        echo "All database objects cleared from database $DB_NAME."
    fi
    
    echo "Restoring database $DB_NAME from dump.sql..."
    docker exec -i "$DB_CONTAINER" psql -U "$DB_USER" "$DB_NAME" < "$TEMP_DIR/dump.sql"
    if [[ $? -ne 0 ]]; then
        echo "Error: Failed to restore database from dump.sql."
        rm -rf "$TEMP_DIR"
        exit 1
    fi
    echo "Database $DB_NAME restored successfully."
fi

# -----------------------------------------
# Files restore (if requested)
# -----------------------------------------
if [[ -n "$FILEDIR" ]]; then
    if [[ -z "$ODOO_CONTAINER" ]]; then
        echo "Error: --odoo-container parameter is required to restore files to filedir."
        rm -rf "$TEMP_DIR"
        exit 1
    fi
    
    # Check required DB parameters for file restore (we need DB_NAME for the destination folder)
    if [[ -z "$DB_NAME" ]]; then
        echo "Error: --db parameter is required for file restore to determine destination folder."
        rm -rf "$TEMP_DIR"
        exit 1
    fi
    
    # Look for the "files" folder in extracted backup
    BACKUP_FOLDER=""
    if [[ -d "$TEMP_DIR/files" ]]; then
        BACKUP_FOLDER="$TEMP_DIR/files"
    else
        # Fallback: look for any directory in the extracted files
        for dir in "$TEMP_DIR"/*; do
            if [[ -d "$dir" && "$(basename "$dir")" != "." && "$(basename "$dir")" != ".." ]]; then
                BACKUP_FOLDER="$dir"
                break
            fi
        done
    fi
    
    if [[ -z "$BACKUP_FOLDER" || ! -d "$BACKUP_FOLDER" ]]; then
        echo "Error: No 'files' folder found in backup zip for restoring."
        rm -rf "$TEMP_DIR"
        exit 1
    fi
    
    # Define the destination path as filedir/db
    DEST_PATH="$FILEDIR/$DB_NAME"
    
    echo "Restoring files from $BACKUP_FOLDER to $DEST_PATH in container $ODOO_CONTAINER..."
    
    # Create the destination directory structure if it doesn't exist
    echo "Creating destination directory structure $DEST_PATH in container..."
    docker exec "$ODOO_CONTAINER" mkdir -p "$DEST_PATH"
    if [[ $? -ne 0 ]]; then
        echo "Error: Failed to create destination directory $DEST_PATH in container $ODOO_CONTAINER."
        rm -rf "$TEMP_DIR"
        exit 1
    fi
    
    # Remove existing content in the destination directory
    echo "Clearing existing content in $DEST_PATH..."
    docker exec "$ODOO_CONTAINER" rm -rf "$DEST_PATH"/*
    
    # Copy the contents of the files folder to the destination
    echo "Copying files content to $DEST_PATH..."
    docker cp "$BACKUP_FOLDER/." "$ODOO_CONTAINER:$DEST_PATH/"
    if [[ $? -ne 0 ]]; then
        echo "Error: Failed to copy files to $DEST_PATH in container $ODOO_CONTAINER."
        rm -rf "$TEMP_DIR"
        exit 1
    fi
    
    # Set proper ownership to odoo user
    echo "Setting proper ownership (odoo:odoo) for restored files..."
    docker exec "$ODOO_CONTAINER" chown -R odoo:odoo "$DEST_PATH"
    if [[ $? -ne 0 ]]; then
        echo "Warning: Failed to set ownership for $DEST_PATH. Files may have incorrect permissions."
    else
        echo "Ownership set successfully for $DEST_PATH."
    fi
    
    echo "Files restored to $DEST_PATH in container $ODOO_CONTAINER successfully."
fi

# Clean up temporary directory
echo "Cleaning up temporary files..."
rm -rf "$TEMP_DIR"

echo "Restore completed successfully!"