# Security Guidelines

## 🔒 Security Best Practices

### 1. Environment Configuration
- **Never commit `.env` files** containing sensitive data
- Use strong passwords for database and services
- Change default credentials before deployment
- Set `APP_ENV=production` in production environments

### 2. Network Security
- Services bind to `127.0.0.1` in production
- Use the production compose file: `docker-compose -f docker-compose.yml -f docker-compose.prod.yml up -d`
- Implement reverse proxy (nginx, cloudflare) for public access
- Use SSL/TLS certificates for HTTPS

### 3. Database Security
- Change default MariaDB root password
- Create application-specific database users
- Enable slow query logging to detect suspicious activity
- Regular backups with encryption
- Disable remote root login in production

### 4. PHP Security
- Disable PHP error display in production (`PHP_DISPLAY_ERRORS=0`)
- Enable error logging (`PHP_LOG_ERRORS=1`)
- Hide PHP version (`PHP_EXPOSE_PHP=0`)
- Use latest PHP versions when possible
- Configure OPcache properly for production

### 5. Nginx Security
- Hide server version (`server_tokens off`)
- Implement rate limiting
- Security headers (HSTS, XSS Protection, etc.)
- Deny access to sensitive files (.env, .git, etc.)
- Regular security updates

### 6. File Permissions
```bash
# Recommended permissions
chmod 755 projects/ db/ logs/ etc/
chmod 644 etc/nginx/*.conf
chmod 600 etc/ssl/*.key
chmod 644 etc/ssl/*.crt
chmod 600 .env
```

### 7. Container Security
- Run containers as non-root users when possible
- Use read-only file systems where applicable
- Resource limits to prevent DoS
- Regular image updates
- Security scanning with tools like Trivy

### 8. Monitoring & Logging
- Enable and monitor access logs
- Set up log rotation
- Monitor for suspicious patterns
- Use centralized logging (ELK stack, etc.)
- Regular security audits

### 9. Backup Security
- Encrypt backup files
- Store backups in secure locations
- Test backup restoration procedures
- Implement backup retention policies

### 10. Development vs Production
- Use separate configurations for dev/prod
- Never use development tools in production
- Disable debug modes in production
- Use different SSL certificates

## 🚨 Security Checklist

### Before Deployment:
- [ ] Updated all default passwords
- [ ] Configured `.env` with production values
- [ ] SSL certificates installed and configured
- [ ] Security headers implemented
- [ ] Rate limiting configured
- [ ] File permissions set correctly
- [ ] Debug modes disabled
- [ ] Security scanning completed
- [ ] Backup strategy implemented
- [ ] Monitoring configured

### Regular Maintenance:
- [ ] Update Docker images monthly
- [ ] Review access logs weekly
- [ ] Test backups monthly
- [ ] Security patch updates
- [ ] SSL certificate renewal
- [ ] Password rotation (quarterly)

## 🔧 Security Tools

### Recommended Tools:
- **Trivy**: Container vulnerability scanning
- **OWASP ZAP**: Web application security testing
- **Fail2ban**: Intrusion prevention
- **Lynis**: System security auditing
- **ClamAV**: Antivirus scanning

### Docker Security:
```bash
# Scan images for vulnerabilities
docker run --rm -v /var/run/docker.sock:/var/run/docker.sock \
  aquasec/trivy image webstack-php84

# Check container security
docker run --rm -it --name docker-bench-security \
  --pid host --userns host --cap-add audit_control \
  -v /etc:/etc:ro -v /usr/bin/containerd:/usr/bin/containerd:ro \
  -v /usr/bin/runc:/usr/bin/runc:ro -v /usr/lib/systemd:/usr/lib/systemd:ro \
  -v /var/lib:/var/lib:ro -v /var/run/docker.sock:/var/run/docker.sock:ro \
  docker/docker-bench-security
```

## 📞 Incident Response

### If Security Breach Suspected:
1. **Immediate Actions:**
   - Stop affected containers: `docker-compose stop`
   - Preserve logs for forensics
   - Change all passwords
   - Revoke API keys/tokens

2. **Investigation:**
   - Review access logs
   - Check for unauthorized changes
   - Identify attack vectors
   - Document timeline

3. **Recovery:**
   - Restore from clean backups
   - Apply security patches
   - Update security configurations
   - Monitor for continued threats

4. **Prevention:**
   - Update security measures
   - Staff security training
   - Review and update procedures

## 📋 Compliance

### Data Protection:
- GDPR compliance for EU users
- Data encryption at rest and in transit
- User consent management
- Data retention policies
- Right to deletion procedures

### Industry Standards:
- OWASP Top 10 compliance
- CIS Docker Benchmark
- NIST Cybersecurity Framework
- ISO 27001 principles

## 🔗 Resources

- [OWASP Docker Security](https://owasp.org/www-project-docker-top-10/)
- [CIS Docker Benchmark](https://www.cisecurity.org/benchmark/docker)
- [Docker Security Best Practices](https://docs.docker.com/engine/security/)
- [PHP Security Guide](https://www.php.net/manual/en/security.php)
- [Nginx Security](https://nginx.org/en/docs/http/securing_web_applications.html)
