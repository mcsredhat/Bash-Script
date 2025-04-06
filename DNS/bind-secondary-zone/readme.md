# Secondary DNS Zone Configuration

This README explains how to set up secondary (slave) DNS zone configurations between two DNS servers for both the linuxcbt.internal and linuxcbt.external domains.

## Overview

This guide demonstrates how to configure DNS master-slave relationships where:
- linuxcbtserv2 is the master for linuxcbt.internal and slave for linuxcbt.external
- linuxcbtserv1 is the master for linuxcbt.external and slave for linuxcbt.internal

This creates a complete DNS infrastructure with redundancy and load distribution.

## Server Information

| Server Name | IP Address | Primary Role | Secondary Role |
|-------------|------------|--------------|----------------|
| linuxcbtserv2 | 172.31.97.38 | Master for linuxcbt.internal | Slave for linuxcbt.external |
| linuxcbtserv1 | 172.31.108.225 | Master for linuxcbt.external | Slave for linuxcbt.internal |

## Configuration Steps

### Setting Up linuxcbtserv1 as Secondary for linuxcbt.internal

1. **Update the Master Server (linuxcbtserv2)**
   - Edit the linuxcbt.internal zone file to include the secondary name server
   - Add NS record for linuxcbtserv1.linuxcbt.internal

2. **Configure the Secondary Server (linuxcbtserv1)**
   - Edit named.conf to add the slave zone configuration
   - Specify the master server IP address (172.31.108.225)
   - Define the path for the slave zone file

3. **Verification Process**
   - Restart named services on both servers
   - Check log files for successful zone transfers
   - Verify DNS resolution using dig commands
   - Confirm slave zone files are created automatically

### Setting Up linuxcbtserv2 as Secondary for linuxcbt.external

1. **Configure the Secondary Server (linuxcbtserv2)**
   - Edit named.conf to add the slave zone configuration for linuxcbt.external
   - Specify the master server IP address (192.168.75.20)

2. **Update the Master Server (linuxcbtserv1)**
   - Edit the linuxcbt.external zone file to include the secondary name server
   - Add NS record for linuxcbtserv2.linuxcbt.external

3. **Verification Process**
   - Restart named services on both servers
   - Check log files for successful zone transfers
   - Test DNS resolution across domains and servers

## Additional Record Management

The configuration also demonstrates how to:

1. **Add and Propagate CNAME Records**
   - Add ftp, sftp, and mail CNAME records to linuxcbt.internal
   - Add sftp and mail CNAME records to linuxcbt.external
   - Verify proper zone transfer of new records

2. **Testing Record Propagation**
   - Query the master server for newly added records
   - Query the slave server to verify successful zone transfers
   - Validate cross-domain resolution

## Best Practices

- Always verify zone file syntax before restarting the named service
- Use named-checkconf to validate named.conf
- Use named-checkzone to validate zone files
- Check log files after configuration changes
- Test with dig from various sources to ensure proper DNS resolution

## Troubleshooting

For troubleshooting slave zone issues:
- Check that slave zone files are being created in the specified directory
- Verify master server is allowing zone transfers
- Examine named logs for transfer failures
- Confirm network connectivity between master and slave servers
- Verify proper NS records on both servers
