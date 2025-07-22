# Docker Web Stack

**Production-ready LEMP stack with multiple PHP versions for modern web development**

A comprehensive Docker-based development environment featuring Nginx, MariaDB, Redis, and 11 PHP versions (5.6 to 8.4) running simultaneously. Optimized for Laravel development with security hardening and performance tuning.

## 🚀 Features

- **Multi-PHP Support**: PHP 5.6, 7.0, 7.1, 7.2, 7.3, 7.4, 8.0, 8.1, 8.2, 8.3, 8.4
- **LEMP Stack**: Nginx, MariaDB, Redis
- **Laravel Ready**: All required extensions and tools pre-installed
- **Production Optimized**: Security headers, rate limiting, OPcache, health checks
- **Development Tools**: Xdebug, Composer, Node.js, Laravel installer
- **Time Sync**: SIRIM Malaysia NTP integration
- **Security Hardened**: Read-only configs, proper permissions, monitoring

## 📋 Requirements

- Docker & Docker Compose
- 2GB+ RAM recommended
- 10GB+ disk space

## ⚡ Quick Start

### 1. Clone and Setup

```bash
git clone https://github.com/hanafiah/docker-webstack.git
cd docker-webstack

# Automated setup
./scripts/setup.sh
```

### 2. Manual Setup

```bash
# Copy environment file
cp .env.example .env

# Edit configuration (optional)
vim .env

# Start all services
docker compose up -d
```

### 3. Setup Virtual Hosts

```bash
# Add development domains to hosts file (Linux/Mac)
echo "127.0.0.1 phpinfo.test" | sudo tee -a /etc/hosts
echo "127.0.0.1 myapp.test" | sudo tee -a /etc/hosts

# For Windows: Edit C:\Windows\System32\drivers\etc\hosts as Administrator
```

### 4. Verify Installation

```bash
# Check service status
docker compose ps

# Access web server
curl http://localhost

# View PHP info via virtual host
curl http://phpinfo.test
```

## 🏗️ Architecture

### Services

- **webserver**: Nginx with security optimizations
- **database**: MariaDB master with performance tuning
- **database-slave**: MariaDB read-only replica (port 3307)
- **cache**: Redis for session/cache storage
- **php56-php84**: Multiple PHP-FPM

### Project Structure

```
docker-webstack/
├── projects/              # Your web projects
│   └── phpinfo/          # Sample PHP info page
├── etc/                  # Configuration files
│   ├── nginx/           # Nginx configs
│   ├── php/             # PHP configs (shared + version-specific)
│   ├── mariadb/         # MariaDB optimization
│   ├── redis/           # Redis configuration
│   └── ssl/             # SSL certificates
├── db/                   # Database persistence
├── logs/                 # Service logs
├── scripts/              # Management scripts
└── php-stack-*/         # PHP Dockerfile directories
```

## 🔧 Usage

### Working with Projects

```bash
# Create new project
mkdir projects/myapp
echo "<?php phpinfo();" > projects/myapp/index.php

# Add project-specific nginx config
cat > projects/myapp/nginx.conf << 'EOF'
server {
    listen 80;
    server_name myapp.test;
    root /var/www/projects/myapp;
    index index.php index.html;

    location / {
        try_files $uri $uri/ /index.php?$query_string;
    }

    location ~ \.php$ {
        fastcgi_pass php84:9000;
        fastcgi_index index.php;
        include fastcgi_params;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
    }
}
EOF

# Restart nginx to load new config
docker compose restart webserver
```

### PHP Version Management

```bash
# Access specific PHP version
docker compose exec php84 bash
docker compose exec php74 bash
docker compose exec php56 bash

# Run composer in specific version
docker compose exec php84 composer install
docker compose exec php74 composer create-project laravel/laravel myapp

# Check PHP version and extensions
docker compose exec php84 php -v
docker compose exec php84 php -m
```

### Database Operations

#### Master Database (Read/Write)

```bash
# Access MariaDB Master
docker compose exec database mariadb -u root -p
# or use mysql command (MariaDB is compatible)
docker compose exec database mysql -u root -p

# Import database to master
docker compose exec -T database mysql -u root -p${DB_ROOT_PASSWORD} < backup.sql

# Create database backup from master
docker compose exec database mysqldump -u root -p${DB_ROOT_PASSWORD} --all-databases > backup.sql
```

#### Slave Database (Read-Only)

```bash
# Access MariaDB Slave (Read-Only)
docker compose exec database-slave mariadb -u root -p
# Port 3307 for external connections
mysql -h 127.0.0.1 -P 3307 -u root -p

# Check replication status
docker compose exec database-slave mysql -u root -p${DB_ROOT_PASSWORD} -e "SHOW SLAVE STATUS\G"

# Note: Slave is READ-ONLY - INSERT/UPDATE/DELETE operations are blocked
```

#### Database Replication Setup

```bash
# Environment variables in .env
DB_REPLICATION_USER=replicator
DB_REPLICATION_PASSWORD=repl123

# Master: 127.0.0.1:3306 (Read/Write)
# Slave:  127.0.0.1:3307 (Read-Only)
```

## 🔒 Security Features

- **Network Isolation**: Services bind to localhost in production
- **Read-only Configs**: Configuration files mounted as read-only
- **Database Replication**: Read-only slave with super-read-only enforcement
- **Security Headers**: HSTS, XSS protection, content type options
- **Rate Limiting**: API and login protection
- **Health Monitoring**: Container health checks
- **SSL Support**: Ready for HTTPS with custom certificates

## 📚 Management Scripts

```bash
# Initial setup (run once)
./scripts/setup.sh

# Backup databases and configs
./scripts/backup.sh

# Sync time with SIRIM Malaysia NTP
./scripts/ntp-sync.sh
```

## 🌍 Environment Configurations

### Development (Default)

```bash
docker compose up -d
# Includes:  Redis Commander, debug mode
```

### Production

```bash
docker compose -f docker-compose.yml -f docker-compose.prod.yml up -d
# Includes: Security hardening, performance optimization
```

## 🔧 Configuration

### Environment Variables (.env)

```bash
# Database Master/Slave
DB_ROOT_PASSWORD=secure_password
DB_NAME=myapp
DB_USER=myapp_user
DB_PASSWORD=secure_password

# Database Replication
DB_REPLICATION_USER=replicator
DB_REPLICATION_PASSWORD=secure_replication_password

# Performance Tuning (Master)
DB_INNODB_BUFFER_POOL_SIZE=1G
DB_MAX_CONNECTIONS=200

# Performance Tuning (Slave - Reduced)
DB_SLAVE_INNODB_BUFFER_POOL_SIZE=512M
DB_SLAVE_MAX_CONNECTIONS=100

# Time & Location
TIMEZONE=Asia/Kuala_Lumpur
NTP_SERVER=ntp.sirim.my

# Application
APP_ENV=production
```

### Virtual Hosts Setup

For development, we use `.test` domains for better local development experience.

#### Linux/Mac

```bash
# Edit hosts file
sudo vim /etc/hosts

# Add these entries
127.0.0.1 phpinfo.test
127.0.0.1 myapp.test
127.0.0.1 api.test
127.0.0.1 laravel.test
127.0.0.1 php74.test
127.0.0.1 php81.test
```

#### Windows

1. **Run Notepad as Administrator**
2. **Open hosts file**: `C:\Windows\System32\drivers\etc\hosts`
3. **Add these entries**:

```
127.0.0.1 phpinfo.test
127.0.0.1 myapp.test
127.0.0.1 api.test
127.0.0.1 laravel.test
```

4. **Save the file**

#### Quick Setup Script

```bash
# Linux/Mac - Add common development domains
echo "127.0.0.1 phpinfo.test" | sudo tee -a /etc/hosts
echo "127.0.0.1 myapp.test" | sudo tee -a /etc/hosts
echo "127.0.0.1 api.test" | sudo tee -a /etc/hosts
echo "127.0.0.1 laravel.test" | sudo tee -a /etc/hosts
echo "127.0.0.1 php74.test" | sudo tee -a /etc/hosts
echo "127.0.0.1 php81.test" | sudo tee -a /etc/hosts
```

## 📊 Monitoring & Logs

```bash
# View service logs
docker compose logs -f webserver
docker compose logs -f database
docker compose logs -f php84

# Monitor resource usage
docker stats

# Health check status
docker compose ps
```

## 🔍 Development Tools

### Access URLs

- **Web Server**: http://localhost or any configured `.test` domain
- **PHP Info**: http://phpinfo.test (after hosts setup)
- **Projects**: http://myapp.test, http://laravel.test
- **Database Master**: 127.0.0.1:3306 (Read/Write)
- **Database Slave**: 127.0.0.1:3307 (Read-Only)
- **Redis Commander** (dev): http://localhost:8082

### Debugging with Xdebug

Xdebug is pre-configured for all PHP versions:

- **PHP 5.6**: Xdebug 2.5.5 (port 9000)
- **PHP 7.4**: Xdebug 2.9.8 (port 9003)
- **PHP 8.4**: Xdebug 3.x (port 9003)

## ⚠️ Troubleshooting

### Common Issues

```bash
# Permission errors
sudo chown -R $USER:$USER projects/ logs/

# Port conflicts
sudo lsof -i :80 -i :3306 -i :6379

# Container health issues
docker compose logs [service_name]
docker compose restart [service_name]

# Time synchronization
./scripts/ntp-sync.sh
```

### Apple Silicon (M1/M2) Support

All images are multi-architecture compatible. For SQL Server support on ARM:

```yaml
# Add to docker-compose.override.yml
services:
  php84:
    platform: linux/amd64
```

## 📖 Documentation

- [Security Guidelines](SECURITY.md)
- [Development Guide](AGENT.md)
- [Wiki](https://github.com/hanafiah/docker-webstack/wiki)

## 🤝 Contributing

1. Fork the repository
2. Create feature branch (`git checkout -b feature/amazing-feature`)
3. Commit changes (`git commit -m 'Add amazing feature'`)
4. Push to branch (`git push origin feature/amazing-feature`)
5. Open Pull Request

## 📄 License

This project is open source and available under the [MIT License](LICENSE).

## 🙏 Acknowledgments

- Built for Malaysian developers with SIRIM NTP integration
- Optimized for Laravel framework requirements
- Security hardened for production deployment
