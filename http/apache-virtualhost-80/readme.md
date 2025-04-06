# Apache Virtual Host Configuration Guide

This README provides instructions for setting up an Apache web server with virtual hosting on a Linux system (CentOS/RHEL).

## Overview

This guide covers the complete process of configuring an Apache web server with virtual hosts for the domain `linuxcbt.internal`, including DNS configuration, firewall setup, and SELinux settings.

## Prerequisites

- CentOS/RHEL Linux server
- Root or sudo access
- Basic understanding of Linux system administration

## Installation Steps

### 1. Package Installation

Install required packages including Apache HTTP server (httpd), SSL modules, PHP and its extensions.

### 2. Service Configuration

Enable and start necessary services:
- Apache HTTP server (httpd)
- DNS server (named)
- Firewall service (firewalld)

### 3. Firewall Configuration

Configure the firewall to allow HTTP (80), HTTPS (443), and DNS (53) traffic.

### 4. SELinux Configuration

Set appropriate SELinux boolean values to allow Apache to function properly with the required permissions.

### 5. Host Configuration

Configure `/etc/hosts` file with IP addresses and hostnames for the internal network.

### 6. DNS Configuration

Configure DNS resolution with:
- `/etc/resolv.conf` setup
- BIND zone configuration for `linuxcbt.internal`
- DNS record creation for various hosts

### 7. Virtual Host Setup

Create a virtual host configuration for `site1.linuxcbt.internal` listening on port 80.

### 8. Web Content Directory

Create and configure the document root directory with proper permissions and ownership.

### 9. Testing & Verification

Verify the configuration using:
- Apache configuration test
- DNS zone validation
- Service restart verification
- Web page access testing

## File Locations

- Apache configuration: `/etc/httpd/conf/httpd.conf`
- Virtual host configuration: `/etc/httpd/conf.d/site1.linuxcbt.internal.conf`
- DNS zone file: `/var/named/linuxcbt.internal`
- Website files: `/var/www/site1.linuxcbt.internal/`

## Security Considerations

- SELinux context settings for web and DNS files
- Proper file permissions
- Firewall rules

## Troubleshooting

If issues arise, verify:
1. DNS resolution with `named-checkzone` and `named-checkconf`
2. Apache configuration with `apachectl configtest` and `httpd -S`
3. Service status with `systemctl status` commands
4. Proper SELinux contexts with `restorecon` and `chcon`

## Additional Resources

For more information on Apache virtual hosting, refer to the official Apache documentation.
