DNS Cache-Only Server Setup
Overview
This repository contains scripts and documentation for setting up and configuring a caching-only DNS server using BIND (Berkeley Internet Name Domain) on Linux systems. A caching-only DNS server improves network performance by storing previously requested DNS information locally, reducing external DNS queries.
Contents

bind-cache-only.sh: Main script for setting up a BIND caching DNS server
Caching-only-adv.sh: Advanced configuration script with additional options
Caching-Only-DNS-Server.txt: Commands and reference documentation

Prerequisites

A Linux server (tested on RHEL/CentOS)
Root or sudo privileges
Internet connectivity to download packages

Installation
Automatic Installation
Run the main setup script:
bashCopysudo ./bind-cache-only.sh
