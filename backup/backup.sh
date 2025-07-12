

# =========================================
# Odoo Backup Script
#
# This script creates a backup of an Odoo database and/or files from a running Docker environment.
# It supports backing up only the database, only the files, or both.
#
# Usage:
#   ./backup.sh [--db DB_NAME --db-container DB_CONTAINER --db-user DB_USER] [--odoo-container ODOO_CONTAINER --filedir FILEDIR] [--help]
#
# Parameters:
#   --db DB_NAME             Name of the database to backup (PostgreSQL)
#   --db-container NAME      Name of the PostgreSQL Docker container
#   --db-user USER           Database user for pg_dump
#   --odoo-container NAME    Name of the Odoo Docker container (required for file backup)
#   --filedir DIR            Absolute path in Odoo container to backup (e.g. /mnt/extra-addons)
#   --help                   Show this help message and exit
#
# Examples:
#   Backup only DB:
#     ./backup.sh --db mydb --db-container pg_container --db-user odoo
#   Backup only files:
#     ./backup.sh --odoo-container odoo_container --filedir /data/files
#   Backup both:
#     ./backup.sh --db mydb --db-container pg_container --db-user odoo --odoo-container odoo_container --filedir /data/files
# =========================================

# Parse parameters

SHOW_HELP=0
while [[ "$#" -gt 0 ]]; do
    key="$1"
    case $key in
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

# Check that at least one backup type is requested
if [[ -z "$DB_NAME" && -z "$FILEDIR" ]]; then
    echo "Error: You must specify at least --db (with --db-container and --db-user) or --filedir (with --odoo-container)."
    exit 1
fi


# -----------------------------------------
# Database backup (if requested)
# -----------------------------------------
if [[ -n "$DB_NAME" ]]; then
    # Check required DB parameters
    if [[ -z "$DB_CONTAINER" || -z "$DB_USER" ]]; then
        echo "Error: --db-container and --db-user are required for database backup."
        exit 1
    fi
    echo "Creating dump.sql from database $DB_NAME in container $DB_CONTAINER as user $DB_USER..."
    docker exec "$DB_CONTAINER" pg_dump -U "$DB_USER" "$DB_NAME" > dump.sql
    if [[ $? -ne 0 ]]; then
        echo "Error: Failed to create database dump."
        exit 1
    fi
    echo "Database dump created: dump.sql"
fi


# -----------------------------------------
# Files backup (if requested)
# -----------------------------------------


if [[ -n "$FILEDIR" ]]; then
    if [[ -z "$ODOO_CONTAINER" ]]; then
        echo "Error: --odoo-container parameter is required to copy files from filedir."
        exit 1
    fi
    # Always use a temporary folder to avoid name collisions
    TMP_FOLDER="__odoo_backup_tmp__"
    if [[ -d "$TMP_FOLDER" ]]; then
        rm -rf "$TMP_FOLDER"
    fi
    echo "Copying contents of $FILEDIR from container $ODOO_CONTAINER to temporary folder $TMP_FOLDER ..."
    docker cp "$ODOO_CONTAINER:$FILEDIR/." "$TMP_FOLDER/"
    if [[ $? -ne 0 ]]; then
        echo "Error: Failed to copy files from $FILEDIR in container $ODOO_CONTAINER."
        rm -rf "$TMP_FOLDER"
        exit 1
    fi
    echo "Files copied from $FILEDIR in container $ODOO_CONTAINER."
    # Move/copy contents to 'files' folder, flattening any single subfolder (db name or original folder)
    if [[ -d files ]]; then
        rm -rf files
    fi
    mkdir files
    shopt -s dotglob
    # If TMP_FOLDER contains a single subfolder, move its contents instead
    TMP_CONTENTS=("$TMP_FOLDER"/*)
    if [[ ${#TMP_CONTENTS[@]} -eq 1 && -d "${TMP_CONTENTS[0]}" ]]; then
        mv "${TMP_CONTENTS[0]}"/* files/ 2>/dev/null || true
    else
        mv "$TMP_FOLDER"/* files/ 2>/dev/null || true
    fi
    shopt -u dotglob
    rm -rf "$TMP_FOLDER"
    FOLDER_NAME="files"
fi

# -----------------------------------------
# Create zip file with available backup items
# -----------------------------------------
ZIP_ITEMS=()
if [[ -f dump.sql ]]; then
    ZIP_ITEMS+=(dump.sql)
fi
if [[ -n "$FILEDIR" ]]; then
    if [[ -n "$FOLDER_NAME" && -d "$FOLDER_NAME" ]]; then
        ZIP_ITEMS+=("$FOLDER_NAME")
    fi
fi

if [[ ${#ZIP_ITEMS[@]} -eq 0 ]]; then
    echo "Nothing to zip. Exiting."
    exit 1
fi

ZIPFILE="backup"
if [[ -n "$DB_NAME" ]]; then
    ZIPFILE+="_${DB_NAME}"
fi
ZIPFILE+="_$(date +%Y%m%d_%H%M%S).zip"

echo "Creating zip file: $ZIPFILE with: ${ZIP_ITEMS[*]} ..."
zip -r "$ZIPFILE" "${ZIP_ITEMS[@]}"
if [[ $? -ne 0 ]]; then
    echo "Error: Failed to create zip file."
    exit 1
fi
echo "Backup zip created: $ZIPFILE"

# Remove temporary files after successful zip
if [[ -f dump.sql ]]; then
    rm -f dump.sql
    echo "Removed dump.sql"
fi
if [[ -n "$FOLDER_NAME" && -d "$FOLDER_NAME" ]]; then
    rm -rf "$FOLDER_NAME"
    echo "Removed $FOLDER_NAME folder."
fi
