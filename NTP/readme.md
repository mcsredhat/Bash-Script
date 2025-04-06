# NTP Client and Server Setup Guide

This guide provides instructions for setting up Network Time Protocol (NTP) on Linux systems using both Chrony and NTP daemon implementations.

## Overview

Network Time Protocol (NTP) enables computers to synchronize their time with reference time servers. This document covers both server and client configurations using two popular implementations: Chrony and traditional NTP daemon.

## Prerequisites

Before setting up NTP services, verify the installation of required packages:
- chrony package (recommended for modern systems)
- ntp package (traditional implementation)
- ntpstat package (optional for status checking)

## NTP Server Configuration

### Basic Server Setup
1. Verify installation of required packages
2. Configure the NTP server to use upstream time sources
3. Configure the local clock as a fallback time source
4. Set timezone settings
5. Enable and start the time synchronization service
6. Configure firewall to allow NTP traffic

### Advanced Server Options
1. Allow synchronization from specific network ranges
2. Configure peer relationships with other NTP servers
3. Set stratum levels for local clock sources
4. Verify server status and synchronization

## NTP Client Configuration

### Basic Client Setup
1. Verify installation of required packages
2. Configure the client to use specific NTP servers
3. Set appropriate timezone
4. Enable and start the time synchronization service
5. Configure firewall to allow NTP traffic
6. Verify synchronization status

### Configuration Options
1. Add multiple server sources for redundancy
2. Configure pool servers from public NTP pools
3. Set specific synchronization options

## Configuration File Locations
- Chrony configuration: `/etc/chrony.conf`
- NTP daemon configuration: `/etc/ntp.conf`
- Timezone configuration: System-dependent, managed with `timedatectl`

## Service Management

### Chrony Service
- Enable/disable service at boot
- Start/stop/restart service
- Check service status
- View synchronization sources

### NTP Daemon Service
- Enable/disable service at boot
- Start/stop/restart service
- Check service status
- View synchronization peers

## Firewall Configuration
- Configure firewall to allow UDP port 123 for NTP traffic
- Different methods for firewalld and iptables

## Verification and Troubleshooting
- Check synchronization status
- View active time sources
- Verify client connections
- Resolve NTP pool domain names
- Check current system time

## Additional Resources
- Use `chronyc sources` to view synchronization sources for Chrony
- Use `ntpq -np` to view synchronization sources for NTP daemon
- Use `timedatectl` to manage system time and timezone information
