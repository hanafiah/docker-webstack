#!/bin/bash
# Docker Web Stack Backup Script

set -e

# Configuration
BACKUP_DIR="/backups"
DATE=$(date +%Y%m%d_%H%M%S)
COMPOSE_FILE="docker-compose.yml"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Logging function
log() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')] $1${NC}"
}

warn() {
    echo -e "${YELLOW}[$(date +'%Y-%m-%d %H:%M:%S')] WARNING: $1${NC}"
}

error() {
    echo -e "${RED}[$(date +'%Y-%m-%d %H:%M:%S')] ERROR: $1${NC}"
}

# Create backup directory
mkdir -p "$BACKUP_DIR"

log "Starting backup process..."

# Backup database (Master)
log "Backing up MariaDB Master database..."
docker compose exec -T database mysqldump -u root -p${DB_ROOT_PASSWORD:-12345} --all-databases \
    --single-transaction --routines --triggers > "$BACKUP_DIR/mariadb_master_${DATE}.sql"

# Backup database (Slave) - for verification
log "Backing up MariaDB Slave database..."
docker compose exec -T database-slave mysqldump -u root -p${DB_ROOT_PASSWORD:-12345} --all-databases \
    --single-transaction --routines --triggers > "$BACKUP_DIR/mariadb_slave_${DATE}.sql" 2>/dev/null || warn "Slave backup failed (normal if slave is not ready)"

# Backup Redis data
log "Backing up Redis data..."
docker compose exec -T cache redis-cli BGSAVE
sleep 5
docker cp $(docker compose ps -q cache):/data/dump.rdb "$BACKUP_DIR/redis_${DATE}.rdb"

# Backup configuration files
log "Backing up configuration files..."
tar -czf "$BACKUP_DIR/configs_${DATE}.tar.gz" etc/ docker-compose.yml .env 2>/dev/null || true

# Backup project files
log "Backing up project files..."
tar -czf "$BACKUP_DIR/projects_${DATE}.tar.gz" projects/ 2>/dev/null || true

# Clean old backups (keep last 7 days)
log "Cleaning old backups..."
find "$BACKUP_DIR" -name "*.sql" -mtime +7 -delete 2>/dev/null || true
find "$BACKUP_DIR" -name "*.rdb" -mtime +7 -delete 2>/dev/null || true
find "$BACKUP_DIR" -name "*.tar.gz" -mtime +7 -delete 2>/dev/null || true

log "Backup completed successfully!"
log "Backup files saved to: $BACKUP_DIR"
ls -la "$BACKUP_DIR" | grep "$DATE"
