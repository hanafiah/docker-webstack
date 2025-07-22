#!/bin/bash
# NTP Synchronization Script for Docker Web Stack

set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Load environment variables
if [ -f .env ]; then
    export $(cat .env | grep -v '#' | xargs)
fi

# Default NTP servers (SIRIM Malaysia)
NTP_SERVER=${NTP_SERVER:-ntp.sirim.my}
NTP_SERVER_BACKUP=${NTP_SERVER_BACKUP:-ntp1.sirim.my}
NTP_SERVER_FALLBACK=${NTP_SERVER_FALLBACK:-pool.ntp.org}

log() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')] $1${NC}"
}

warn() {
    echo -e "${YELLOW}[$(date +'%Y-%m-%d %H:%M:%S')] WARNING: $1${NC}"
}

error() {
    echo -e "${RED}[$(date +'%Y-%m-%d %H:%M:%S')] ERROR: $1${NC}"
}

# Check NTP server connectivity
check_ntp_server() {
    local server=$1
    log "Checking NTP server: $server"
    
    if ntpdate -q $server > /dev/null 2>&1; then
        log "✓ NTP server $server is reachable"
        return 0
    else
        warn "✗ NTP server $server is not reachable"
        return 1
    fi
}

# Sync time with NTP server
sync_time() {
    local server=$1
    log "Synchronizing time with $server..."
    
    if command -v ntpdate >/dev/null 2>&1; then
        if sudo ntpdate -s $server; then
            log "✓ Time synchronized successfully with $server"
            return 0
        else
            error "✗ Failed to sync time with $server"
            return 1
        fi
    elif command -v chrony >/dev/null 2>&1; then
        if sudo chronyd -q "server $server iburst"; then
            log "✓ Time synchronized successfully with $server using chrony"
            return 0
        else
            error "✗ Failed to sync time with $server using chrony"
            return 1
        fi
    else
        warn "No NTP client found (ntpdate or chrony)"
        return 1
    fi
}

# Sync containers time
sync_containers() {
    log "Synchronizing time in Docker containers..."
    
    # Get list of running containers
    containers=$(docker compose ps -q 2>/dev/null || echo "")
    
    if [ -z "$containers" ]; then
        warn "No running containers found"
        return 1
    fi
    
    for container in $containers; do
        container_name=$(docker inspect --format='{{.Name}}' $container | sed 's/^.//')
        log "Syncing time in container: $container_name"
        
        # Restart container to sync time (Docker shares host time)
        docker restart $container > /dev/null
    done
    
    log "✓ All containers restarted for time synchronization"
}

# Main function
main() {
    log "Starting NTP synchronization for Docker Web Stack"
    log "Using SIRIM Malaysia NTP servers as primary"
    
    # Check host system time sync
    log "Current system time: $(date)"
    
    # Try primary NTP server (SIRIM)
    if check_ntp_server $NTP_SERVER; then
        if sync_time $NTP_SERVER; then
            log "✓ Successfully synchronized with primary NTP server: $NTP_SERVER"
        else
            warn "Failed to sync with primary server, trying backup..."
            
            # Try backup SIRIM server
            if check_ntp_server $NTP_SERVER_BACKUP && sync_time $NTP_SERVER_BACKUP; then
                log "✓ Successfully synchronized with backup NTP server: $NTP_SERVER_BACKUP"
            else
                warn "Failed to sync with backup server, trying fallback..."
                
                # Try fallback server
                if check_ntp_server $NTP_SERVER_FALLBACK && sync_time $NTP_SERVER_FALLBACK; then
                    log "✓ Successfully synchronized with fallback NTP server: $NTP_SERVER_FALLBACK"
                else
                    error "Failed to synchronize with any NTP server"
                    exit 1
                fi
            fi
        fi
    else
        error "Primary NTP server $NTP_SERVER is not reachable"
        exit 1
    fi
    
    # Show updated time
    log "Updated system time: $(date)"
    
    # Sync Docker containers
    if docker compose version >/dev/null 2>&1; then
        sync_containers
    else
        warn "docker compose not found, skipping container sync"
    fi
    
    log "NTP synchronization completed successfully!"
    
    # Show timezone info
    log "System timezone: $(timedatectl show --property=Timezone --value 2>/dev/null || echo $TIMEZONE)"
    log "NTP status: $(timedatectl show --property=NTPSynchronized --value 2>/dev/null || echo 'Unknown')"
}

# Check if running as root for time sync
if [ "$EUID" -ne 0 ] && ! groups | grep -q sudo; then
    error "This script requires root privileges or sudo access for time synchronization"
    echo "Please run: sudo $0"
    exit 1
fi

# Run main function
main "$@"
