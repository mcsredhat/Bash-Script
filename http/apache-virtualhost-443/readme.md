# Apache HTTPS Virtual Host Setup Guide

This guide outlines the process for setting up an Apache web server with SSL/TLS configuration for secure HTTPS connections.

## Overview

This documentation covers the complete setup process for configuring an Apache web server with SSL certificates for the domain `site1.linuxcbt.internal` on a Linux system.

## Prerequisites

- CentOS/RHEL-based Linux distribution
- Root or sudo access
- Basic understanding of web servers and DNS

## Installation Steps Summary

1. **Install Required Packages**
   - Apache HTTP Server (httpd)
   - PHP and necessary modules
   - SSL/TLS tools and libraries

2. **Enable and Start Services**
   - Apache (httpd)
   - Named (DNS)
   - Firewalld

3. **Configure Firewall**
   - Open necessary ports (80, 443, 53)
   - Enable required services (http, https, dns)

4. **Configure SELinux**
   - Set appropriate boolean values for Apache

5. **Network Configuration**
   - Configure hosts file
   - Set up DNS resolution
   - Configure named service for DNS zones

6. **SSL Certificate Generation**
   - Create private key
   - Generate Certificate Signing Request (CSR)
   - Create self-signed certificate
   - Verify certificate

7. **Apache Configuration**
   - Set up virtual host for HTTPS (port 443)
   - Configure SSL certificate paths
   - Set security headers
   - Configure document root

8. **Advanced Configuration with .htaccess**
   - URL rewriting
   - HTTP to HTTPS redirection
   - IP-based access control
   - Custom error pages
   - Directory index settings
   - Password protection

9. **Testing and Verification**
   - Syntax checking
   - Service restart
   - Connection testing

## File Locations

- **Web root directory**: `/var/www/site1.linuxcbt.internal/`
- **SSL certificate**: `/etc/pki/tls/certs/site1.linuxcbt.internal.crt`
- **SSL private key**: `/etc/pki/tls/private/site1.linuxcbt.internal.key`
- **Apache config**: `/etc/httpd/conf.d/site1.ssl.linuxcbt.internal.conf`
- **DNS zone file**: `/var/named/linuxcbt.internal`

## Security Considerations

- HTTPS Strict Transport Security (HSTS) implementation
- Certificate validity (365 days)
- SELinux configuration for enhanced security
- IP-based access restrictions

## Troubleshooting

- Check Apache error logs: `/var/log/httpd/site1.ssl_error_log`
- Verify configuration syntax: `apachectl configtest`
- Test connectivity: `curl -k https://site1.linuxcbt.internal`

## Additional Notes

This setup uses a self-signed certificate which is suitable for development or internal environments. For production environments, obtain a certificate from a trusted Certificate Authority (CA).
