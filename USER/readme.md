# Linux User and Group Management

This README provides an overview of Linux user and group management commands. The commands are organized by category for easy reference.

## Table of Contents
- [User Management](#user-management)
  - [Creating Users](#creating-users)
  - [Modifying Users](#modifying-users)
  - [User Information](#user-information)
  - [Password Management](#password-management)
  - [Deleting Users](#deleting-users)
- [Group Management](#group-management)
  - [Creating Groups](#creating-groups)
  - [Modifying Groups](#modifying-groups)
  - [Group Membership](#group-membership)
  - [Group Passwords](#group-passwords)
- [System Information](#system-information)
  - [Login Information](#login-information)
  - [System Configuration Files](#system-configuration-files)
- [User Switching](#user-switching)

## User Management

### Creating Users
- `useradd`: Create new users with various options
  - Set UID, home directory, default shell
  - Copy skeleton files from /etc/skel
- `useradd -D`: Display or modify default useradd configuration

### Modifying Users
- `usermod`: Modify user accounts
  - Change username, home directory, shell
  - Add to groups, change primary group
  - Lock/unlock accounts
  - Set account expiration dates
- `chsh`: Change login shell
- `chfn`: Change finger information

### User Information
- `id`: Display real and effective user IDs
- `grep username /etc/passwd`: Search for user information in /etc/passwd

### Password Management
- `passwd`: Set or change user passwords
- `chage`: Manage password aging policies
  - Set minimum/maximum password age
  - Set password expiration dates
  - Display password aging information
- `pwconv`: Convert to shadow passwords

### Deleting Users
- `userdel`: Delete user accounts
  - `-r` option removes home directory

## Group Management

### Creating Groups
- `groupadd`: Create new groups
  - Set GID
  - `-o` option allows non-unique GIDs

### Modifying Groups
- `groupmod`: Modify group information
  - Rename groups
  - Change GID

### Group Membership
- `usermod -G`: Set supplementary groups
- `usermod -a -G`: Add to supplementary groups without removing existing
- `gpasswd -a/-d`: Add/remove users from groups
- `gpasswd -M`: Set group members
- `gpasswd -A`: Set group administrators
- `newgrp`: Switch to a new group

### Group Passwords
- `gpasswd`: Set group passwords
- `gpasswd -r`: Remove group password
- `grpconv`: Convert to shadow group format

## System Information

### Login Information
- `who`: Show who is logged in
- `last`: Show listing of last logged in users
- `last reboot`: Show system reboot history
- `lastlog`: Display last login times for all users
- `faillog`: Display failed login attempts

### System Configuration Files
- `/etc/passwd`: User account information
- `/etc/shadow`: Secure user account information
- `/etc/group`: Group information
- `/etc/login.defs`: Shadow password suite configuration
- `/etc/profile`, `/etc/bashrc`: System-wide shell configuration
- `/etc/profile.d/*`: System-wide shell configuration scripts
- `~/.bashrc`, `~/.bash_profile`, `~/.bash_logout`: User-specific shell configuration

## User Switching
- `su`: Switch user
- `su ~username`: Switch to user's home directory
