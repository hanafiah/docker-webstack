#!/bin/bash
# Docker Web Stack Setup Script

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')] $1${NC}"
}

warn() {
    echo -e "${YELLOW}[$(date +'%Y-%m-%d %H:%M:%S')] WARNING: $1${NC}"
}

error() {
    echo -e "${RED}[$(date +'%Y-%m-%d %H:%M:%S')] ERROR: $1${NC}"
}

info() {
    echo -e "${BLUE}[$(date +'%Y-%m-%d %H:%M:%S')] INFO: $1${NC}"
}

# Check if Docker is installed
check_docker() {
    if ! command -v docker &> /dev/null; then
        error "Docker is not installed. Please install Docker first."
        exit 1
    fi
    
    if ! docker compose version &> /dev/null; then
        error "Docker Compose is not available. Please install Docker Compose plugin."
        exit 1
    fi
    
    log "Docker and Docker Compose are installed."
}

# Create environment file
setup_env() {
    if [ ! -f .env ]; then
        log "Creating .env file from template..."
        cp .env.example .env
        warn "Please review and update the .env file with your settings."
    else
        info ".env file already exists."
    fi
}

# Create necessary directories
create_directories() {
    log "Creating necessary directories..."
    
    # Database directories
    mkdir -p db/mariadb db/mariadb-slave db/redis
    
    # Log directories  
    mkdir -p logs/{nginx,mariadb,mariadb-slave,php,php56,php70,php71,php72,php73,php74,php80,php81,php82,php83,php84}
    
    # SSL directory
    mkdir -p etc/ssl
    
    # Projects directory
    mkdir -p projects
    
    # Backup directory
    mkdir -p backups
    
    log "Directories created successfully."
}

# Set proper permissions
set_permissions() {
    log "Setting proper permissions..."
    
    # Make scripts executable
    chmod +x scripts/*.sh 2>/dev/null || true
    
    # Set permissions for data directories
    chmod 755 db logs etc projects
    chmod -R 644 etc/ 2>/dev/null || true
    chmod -R 755 etc/ 2>/dev/null || true
    
    log "Permissions set successfully."
}

# Generate self-signed SSL certificate
generate_ssl() {
    if [ ! -f etc/ssl/server.crt ] || [ ! -f etc/ssl/server.key ]; then
        log "Generating self-signed SSL certificate..."
        openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
            -keyout etc/ssl/server.key \
            -out etc/ssl/server.crt \
            -subj "/C=MY/ST=KL/L=KualaLumpur/O=WebStack/OU=IT/CN=localhost" \
            2>/dev/null
        log "SSL certificate generated."
    else
        info "SSL certificate already exists."
    fi
}

# Build and start containers
start_stack() {
    log "Building and starting Docker containers..."
    
    # Pull latest images
    docker compose pull
    
    # Build custom images
    docker compose build --no-cache
    
    # Start services
    docker compose up -d
    
    log "Docker stack started successfully."
}

# Wait for services to be ready
wait_for_services() {
    log "Waiting for services to be ready..."
    
    # Wait for database
    until docker compose exec -T database mysqladmin ping -h localhost -u root -p${DB_ROOT_PASSWORD:-12345} &> /dev/null; do
        info "Waiting for database..."
        sleep 5
    done
    
    # Wait for Redis
    until docker compose exec -T cache redis-cli ping &> /dev/null; do
        info "Waiting for Redis..."
        sleep 2
    done
    
    # Wait for nginx
    until curl -s http://localhost/nginx-health &> /dev/null; do
        info "Waiting for Nginx..."
        sleep 2
    done
    
    log "All services are ready!"
}

# Show status
show_status() {
    log "Docker Web Stack Setup Complete!"
    echo
    info "Services Status:"
    docker compose ps
    echo
    info "Access URLs:"
    echo "  - Web Server: http://localhost"
    echo "  - PHPInfo: http://localhost/phpinfo"
    echo "  - Database Master: 127.0.0.1:3306 (Read/Write)"
    echo "  - Database Slave: 127.0.0.1:3307 (Read-Only)"
    echo "  - Adminer (dev): http://localhost:8081"
    echo "  - Redis Commander (dev): http://localhost:8082"
    echo
    info "Management Commands:"
    echo "  - View logs: docker compose logs -f [service_name]"
    echo "  - Stop stack: docker compose stop"
    echo "  - Restart: docker compose restart"
    echo "  - Backup: ./scripts/backup.sh"
    echo "  - NTP Sync: ./scripts/ntp-sync.sh"
    echo
    info "Time Configuration:"
    echo "  - Timezone: ${TIMEZONE:-Asia/Kuala_Lumpur}"
    echo "  - NTP Server: ${NTP_SERVER:-ntp.sirim.my} (SIRIM Malaysia)"
    echo "  - System Time: $(date)"
    echo
    warn "Remember to:"
    echo "  1. Review and update .env file"
    echo "  2. Configure your projects in the projects/ directory"
    echo "  3. Set up proper SSL certificates for production"
    echo "  4. Run ./scripts/ntp-sync.sh to synchronize time"
}

# Main setup process
main() {
    log "Starting Docker Web Stack setup..."
    
    check_docker
    setup_env
    create_directories
    set_permissions
    generate_ssl
    start_stack
    wait_for_services
    show_status
}

# Run main function
main "$@"
