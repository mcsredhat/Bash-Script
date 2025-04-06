# NFS Server and Client Setup Guide

This guide provides instructions for setting up an NFS (Network File System) server and client between two Linux servers named **linuxcbtserv1** and **linuxcbtserv2**.

## Overview

Network File System (NFS) allows a system to share directories and files with others over a network. This guide covers setting up an NFS server on **linuxcbtserv2** and mounting the shared directory on an NFS client named **linuxcbtserv1**.

## Server Configuration (linuxcbtserv2)

### Prerequisites
- NFS utilities package
- Running rpcbind service

### Installation Steps
1. Install required NFS packages
2. Enable and start the NFS server and rpcbind services
3. Verify NFS server status and initialization scripts

### Configuration
1. Create the directory to be shared: `/projectx`
2. Configure the `/etc/exports` file to define shared directories
3. Export the NFS directories
4. Verify exported shares

### Network and Security Configuration
1. Open necessary firewall ports (2049/tcp, 111/tcp)
2. Enable required firewall services (nfs, rpc-bind)
3. Configure SELinux boolean values for NFS
4. Verify network ports and settings

## Client Configuration (linuxcbtserv1)

### Prerequisites
- NFS utilities package
- Running rpcbind service

### Installation Steps
1. Install required NFS packages
2. Enable and start the required services

### Mounting NFS Shares
1. Mount the remote NFS share temporarily: `/projectx`
2. Verify the mounted filesystem
3. Configure automatic mounting at boot via `/etc/fstab`
4. Test automatic mounting

### Network and Security Configuration
1. Configure firewall settings for NFS client
2. Set appropriate SELinux boolean values
3. Configure host resolution in `/etc/hosts`

### Testing and Verification
1. Create and modify files on the mounted directory
2. Check file permissions and access
3. Verify disk space usage on the mounted filesystem
4. Test unmounting and remounting the share

## Troubleshooting
- Verify NFS service status on both servers
- Check firewall configurations
- Ensure SELinux is properly configured
- Verify network connectivity between servers
- Check exported shares on the server
- Examine system logs for errors

## Additional Notes
- The examples use IP address 172.31.44.225 for the NFS server
- The shared directory is `/projectx` with read-write permissions
- Consider security implications when configuring NFS shares
