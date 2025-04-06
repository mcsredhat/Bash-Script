# DNS Configuration Guide

This README explains how to set up a BIND DNS server configuration with primary and secondary servers for the domains linuxcbt.internal and linuxcbt.external.

## Overview

This setup demonstrates a complete DNS infrastructure with:
- Primary DNS server (linuxcbtserv2) for the linuxcbt.internal domain
- Secondary DNS server (linuxcbtserv1) for the linuxcbt.external domain
- DNS record types including A, NS, MX, and CNAME records
- Proper security configurations including firewall rules and SELinux settings
- SSH key-based authentication for secure server management

## Server Information

| Server Name | IP Address | Primary Domain |
|-------------|------------|----------------|
| linuxcbtserv2 | 172.31.97.38 | linuxcbt.internal |
| linuxcbtserv1 | 172.31.108.225 | linuxcbt.external |

## Configuration Steps

### Primary Server (linuxcbtserv2)

1. **BIND Installation and Configuration**
   - Install BIND DNS server
   - Configure named.conf with linuxcbt.internal zone definition
   - Create zone file with proper SOA, NS, A, MX records
   - Apply security settings (file permissions, SELinux context)
   - Configure firewall to allow DNS traffic (TCP/UDP port 53)
   - Verify configuration with named-checkconf and named-checkzone utilities

2. **DNS Records Created**
   - A records for linuxcbtserv1 and linuxcbtserv2
   - NS records pointing to both DNS servers
   - MX record for mail service
   - www A record for web service

3. **Verification Process**
   - Test DNS resolution using dig queries for all record types
   - Examine service logs for errors
   - Verify network listening state

### Secondary Server (linuxcbtserv1)

1. **BIND Installation and Configuration**
   - Install BIND packages
   - Configure named.conf with linuxcbt.external zone definition
   - Create zone file by modifying the internal zone file
   - Apply proper permissions

2. **SSH Configuration**
   - Generate SSH keys for secure server-to-server communication
   - Configure passwordless authentication between servers

## Testing and Validation

The following tests should be performed to validate the DNS setup:
- Query NS records for both domains
- Query A records for all hostnames
- Query MX records for mail routing
- Verify CNAME resolution
- Cross-server DNS resolution testing

## Troubleshooting

For troubleshooting DNS issues:
- Check daemon status with systemctl status named
- Review logs in data/named.run
- Verify zone file syntax with named-checkzone
- Confirm configuration syntax with named-checkconf
- Test DNS resolution with dig commands

## Security Considerations

The configuration includes several security measures:
- Proper file permissions (640) for zone files
- SELinux context settings for named files
- Firewall rules allowing only necessary traffic
- SSH key-based authentication for secure administration
