# MySQL Setup and Management Guide

This guide provides a comprehensive overview of MySQL installation, configuration, and basic database management operations.

## Installation

- Checking for existing MySQL packages
- Finding available MySQL packages in the repository
- Installing MySQL server
- Configuring firewall to allow MySQL service
- Setting SELinux boolean for network connections
- Enabling and starting MySQL service

## Login and Basic Operations

- Logging into MySQL server as root user
- Viewing existing databases
- Selecting and using databases
- Listing tables within a database
- Examining table structures
- Viewing user information and privileges
- Exiting the MySQL shell

## User and Password Management

- Changing the MySQL root password
- Logging in with the new password
- Setting user passwords for specific hosts
- Viewing user information after changes
- Applying privilege changes
- Securely exiting the MySQL shell

## Database and Table Management

### Creating and Managing Databases
- Creating a new database (example: addressBook)
- Switching to the newly created database

### Table Operations
- Creating tables with specific fields and primary keys
- Listing tables in a database
- Viewing table structure

### Data Manipulation
- Inserting records into tables
- Selecting and viewing data
- Updating existing records
- Deleting records from tables

## Best Practices

- Always use passwords for database accounts
- Regularly flush privileges after making user changes
- Use primary keys when creating tables
- Back up databases before making significant changes

## Notes

This guide assumes a CentOS/RHEL-based Linux distribution. Commands may vary slightly on other distributions.
