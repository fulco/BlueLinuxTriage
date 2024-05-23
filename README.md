# BlueLinuxTriage

## Overview

This script is designed to perform a forensic triage on Ubuntu-style Linux operating systems. It collects various types of system information, logs, and other relevant data that can be used for initial forensic analysis.

## Collected Data

### System Information

- **Date and Time:** Current date and time of the system.
- **Uptime:** System uptime.
- **Hostname:** System's hostname.
- **Kernel Version:** Version of the Linux kernel.
- **System Information:** Hardware and system information.

### User Information

- **Current Users:** Users currently logged into the system.
- **Logged in Users:** List of users currently logged in.
- **Last Logins:** History of user logins.
- **User List:** List of all user accounts on the system.
- **User Groups:** List of all user groups and their members.
- **Sudoers Configuration:** Contents of the sudoers file.

### Process Information

- **Running Processes:** List of all running processes.
- **Top Processes:** Snapshot of the top processes by resource usage.

### Network Information

- **Network Interfaces:** Configuration and status of network interfaces.
- **Active Connections:** List of active network connections and listening ports.
- **ARP Cache:** ARP cache entries.
- **Routing Table:** System's routing table.
- **Firewall Rules (iptables):** Current iptables rules.
- **Firewall Rules (ufw):** Current ufw rules.

### File System Information

- **Mounted File Systems:** Information about mounted file systems.
- **Disk Usage:** Disk usage summary for user directories.
- **Open Files:** List of all open files on the system.
- **Recently Modified Files:** List of recently modified files in critical directories.
- **Large Files:** List of large files on the system.

### Log Files

- **System Log:** `/var/log/syslog`
- **Authentication Log:** `/var/log/auth.log`
- **Kernel Log:** `/var/log/kern.log`
- **Message Buffer Log:** `/var/log/dmesg`
- **Secure Log:** `/var/log/secure`
- **Failed Login Log:** `/var/log/faillog`

### Scheduled Tasks

- **Cron Jobs:** List of scheduled cron jobs for all users.
- **Cron Directories:** Contents of cron directories.

### System Configuration

- **Network Configuration:** Network interfaces configuration (`/etc/network/interfaces`).
- **Hosts File:** System hosts file (`/etc/hosts`).
- **DNS Resolver Configuration:** DNS resolver configuration (`/etc/resolv.conf`).
- **Services:** Status of all services on the system.
- **Loaded Kernel Modules:** List of currently loaded kernel modules.
- **Systemd Services:** List and status of systemd services.

### Application-Specific Logs

- **Apache Logs:** Logs from Apache web server.
- **Nginx Logs:** Logs from Nginx web server.
- **MySQL Logs:** Logs from MySQL database.
- **PostgreSQL Logs:** Logs from PostgreSQL database.

### Security and Authentication

- **PAM Configuration:** Pluggable Authentication Modules (PAM) configuration.
- **Failed Login Attempts:** Detailed logs of failed login attempts.

### SSH Configuration

- **SSH Configuration:** Contents of SSH configuration files.

## Usage

1. Save the script to a file, e.g., `forensics_triage.sh`.
2. Make the script executable:

   ```bash
   chmod +x triage.sh
   ```

3. Run the script with sudo to ensure it has the necessary permissions:

   ```bash
   sudo ./triage.sh
   ```

## Output

The script saves the collected data in a directory named `forensics_YYYYMMDDHHMMSS` located in `/tmp`, where `YYYYMMDDHHMMSS` is the timestamp of when the script was run. All collected data is stored in this directory for further analysis.

## Disclaimer

This script is intended for use in a controlled forensic investigation environment. Use it responsibly and ensure you have appropriate permissions to collect and analyze system data.
