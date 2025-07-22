# AGENT.md - Docker Web Stack (Updated)

## Build/Run Commands
- Start stack: `docker compose up -d`
- Stop stack: `docker compose stop`
- Rebuild containers: `docker compose build`
- View logs: `docker compose logs [service_name]`
- Access container: `docker compose exec [service_name] bash`
- Environment setup: `cp .env.example .env` (edit as needed)

## Architecture (Updated Structure)
- **Stack**: LEMP + Redis (Linux, Nginx, MariaDB, PHP, Redis)
- **Services**: webserver (nginx), database (mariadb), cache (redis), php56/php70/php71/php72/php73/php74/php80/php81/php82/php83/php84
- **Network**: webstack-network bridge
- **Multi-PHP**: Support for PHP 5.6, 7.0, 7.1, 7.2, 7.3, 7.4, 8.0, 8.1, 8.2, 8.3, 8.4 simultaneously
- **Environment**: Configurable via .env file

## Folder Structure (OS Consistent)
- `projects/`: Web projects location
- `db/`: Database persistence (mariadb, redis)
- `logs/`: All service logs (nginx, php, mariadb)
- `etc/nginx/`: Nginx configurations
- `etc/php/`: Shared PHP configuration
- `etc/php/[version]/`: Version-specific PHP configs (optional)
- `etc/php/[version]/php-fpm.d/`: Version-specific PHP-FPM pools
- `etc/mariadb/`: Database configurations
- `etc/ssl/`: SSL certificates
- `php-stack-*/`: PHP Dockerfile directories

## PHP Version Management
- Multiple PHP versions run simultaneously
- Config hierarchy: `etc/php/[version]/` overrides `etc/php/php.ini`
- Create `etc/php/8.4/php.ini` for version-specific settings
- PHP-FPM pools: `etc/php/[version]/php-fpm.d/` for pool configs
- Each version has isolated sessions/uploads volumes
- Access via: `docker compose exec php[version] bash`
- Composer: `docker compose exec php84 composer [command]`

## Installed Tools & Extensions
- **Composer**: Pre-installed in all PHP versions (version-appropriate)
- **Xdebug**: Configured for development in all versions
- **Laravel Support**: All required extensions (mbstring, tokenizer, etc.)
- **Database**: MySQL/MariaDB drivers (pdo_mysql, mysqli)
- **Image Processing**: GD extension with WebP support (PHP 7.4+)
- **Cache**: Redis extension installed
- **Node.js**: Latest LTS for Laravel Mix

## Configuration Management
- **Nginx**: Full config mapping (nginx.conf, sites, fastcgi_params)
- **PHP**: Hierarchical config with FPM pool support
- **Read-only configs**: Config files mounted as read-only for security
- **Performance**: Optimized with health checks and resource limits

## Environment Configurations
- **Development**: `docker-compose.override.yml` (auto-loaded)
- **Production**: `docker compose -f docker-compose.yml -f docker-compose.prod.yml up -d`
- **Security**: See SECURITY.md for comprehensive security guidelines

## Management Scripts
- **Setup**: `./scripts/setup.sh` - Initial setup and configuration
- **Backup**: `./scripts/backup.sh` - Backup databases and configurations
- **NTP Sync**: `./scripts/ntp-sync.sh` - Time synchronization with SIRIM NTP
- **Security**: Follow SECURITY.md guidelines for hardening

## Project Structure
```
docker-webstack/
├── db/                     # Database persistence
├── etc/                    # Configuration files
│   ├── nginx/             # Nginx configs
│   ├── php/               # PHP configs (shared + version-specific)
│   ├── mariadb/           # MariaDB configs
│   ├── redis/             # Redis configs
│   └── ssl/               # SSL certificates
├── logs/                  # Service logs
├── projects/              # Web projects
├── scripts/               # Management scripts
├── docker-compose.yml     # Main compose file
├── docker-compose.override.yml  # Development overrides
├── docker-compose.prod.yml      # Production configuration
├── .env.example          # Environment template
└── SECURITY.md           # Security guidelines
```
