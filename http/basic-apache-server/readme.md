# Apache Web Server Configuration

This README provides instructions for setting up and configuring an Apache web server with PHP support in a Linux environment, specifically for the linuxcbt.internal domain.

## Overview

This guide covers the essential steps to deploy a functional Apache web server with:
- Basic Apache HTTP server installation
- PHP support with common extensions
- Firewall configuration
- SELinux security settings
- DNS integration
- Basic testing procedures

## Prerequisites

- RHEL/CentOS-based Linux distribution
- Root or sudo privileges
- Network connectivity
- DNS server configuration (as detailed in companion documentation)

## Installation Steps

### 1. Package Installation

The configuration requires installation of:
- Apache HTTP Server (httpd)
- SSL/TLS support (mod_ssl, openssl)
- PHP with common extensions:
  - Core PHP functionality
  - MySQL/MariaDB connectivity
  - GD graphics library
  - XML processing
  - Internationalization (mbstring)
  - Remote connectivity (curl)
  - Archive handling (zip)
  - Web services (soap)

### 2. Service Configuration

The setup enables and starts:
- Apache HTTP server (httpd)
- DNS services (named)
- Firewall service (firewalld)

### 3. Firewall Configuration

Security settings allow:
- HTTP traffic (port 80/TCP)
- HTTPS traffic (port 443/TCP)
- DNS services (port 53/TCP and UDP)

### 4. SELinux Security Settings

SELinux boolean values are configured to:
- Allow network connections from web applications
- Enable memory execution for certain applications
- Allow NFS access from Apache
- Enable CGI script execution
- Permit user content access
- Allow network relabeling operations

### 5. Host and DNS Configuration

The setup includes:
- Local host file entries for internal servers
- DNS resolver configuration
  - Search domain: linuxcbt.internal
  - Primary and secondary nameserver entries

### 6. Testing Procedure

The configuration includes:
- Creation of a basic PHP test page
- Verification methods using curl and text browser (elinks)
- URL access testing for site1.linuxcbt.internal

## Server Information

| Server Name | IP Address | Role |
|-------------|------------|------|
| linuxcbtserv3 | 172.31.43.107 | Web Server |
| site1 | 172.31.44.229 | Web Site Host |
| linuxcbtserv2 | 172.31.35.154 | DNS Server |
| linuxcbtserv1 | 172.31.44.229 | DNS Server |

## Best Practices

- Back up configuration files before making changes
- Test changes incrementally
- Verify services are running after configuration changes
- Check logs for errors after modifications
- Use appropriate security settings for production environments

## Troubleshooting

Common issues and solutions:
- If web pages don't load, check Apache service status
- For PHP processing issues, verify PHP module installation
- For access problems, check firewall and SELinux settings
- For name resolution failures, verify DNS configuration
- Use Apache logs (/var/log/httpd/) to identify specific errors
