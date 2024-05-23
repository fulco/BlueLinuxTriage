#!/bin/bash

# Define output directory
OUTPUT_DIR="/tmp/forensics_$(date +%Y%m%d%H%M%S)"
mkdir -p "$OUTPUT_DIR"

# Redirecting all outputs to log file
exec > "$OUTPUT_DIR/forensics.log" 2>&1

echo "Starting forensic triage..."

# System Information
echo "Collecting system information..."
echo "Date and Time:" > "$OUTPUT_DIR/system_info.txt"
date >> "$OUTPUT_DIR/system_info.txt"
echo "Uptime:" >> "$OUTPUT_DIR/system_info.txt"
uptime >> "$OUTPUT_DIR/system_info.txt"
echo "Hostname:" >> "$OUTPUT_DIR/system_info.txt"
hostname >> "$OUTPUT_DIR/system_info.txt"
echo "Kernel Version:" >> "$OUTPUT_DIR/system_info.txt"
uname -a >> "$OUTPUT_DIR/system_info.txt"
echo "System Information:" >> "$OUTPUT_DIR/system_info.txt"
lshw -short >> "$OUTPUT_DIR/system_info.txt"

# User Information
echo "Collecting user information..."
echo "Current Users:" > "$OUTPUT_DIR/users.txt"
w >> "$OUTPUT_DIR/users.txt"
echo "Logged in Users:" >> "$OUTPUT_DIR/users.txt"
who >> "$OUTPUT_DIR/users.txt"
echo "Last Logins:" >> "$OUTPUT_DIR/users.txt"
last >> "$OUTPUT_DIR/users.txt"
echo "User List:" >> "$OUTPUT_DIR/users.txt"
cat /etc/passwd >> "$OUTPUT_DIR/users.txt"
echo "User Groups:" >> "$OUTPUT_DIR/groups.txt"
getent group >> "$OUTPUT_DIR/groups.txt"
echo "Sudoers Configuration:" >> "$OUTPUT_DIR/sudoers.txt"
cat /etc/sudoers >> "$OUTPUT_DIR/sudoers.txt"

# Process Information
echo "Collecting process information..."
echo "Running Processes:" > "$OUTPUT_DIR/processes.txt"
ps aux >> "$OUTPUT_DIR/processes.txt"
echo "Top Processes:" >> "$OUTPUT_DIR/processes.txt"
top -b -n 1 >> "$OUTPUT_DIR/processes.txt"

# Network Information
echo "Collecting network information..."
echo "Network Interfaces:" > "$OUTPUT_DIR/network_info.txt"
ifconfig -a >> "$OUTPUT_DIR/network_info.txt"
echo "Active Connections:" >> "$OUTPUT_DIR/network_info.txt"
netstat -tulnp >> "$OUTPUT_DIR/network_info.txt"
echo "ARP Cache:" >> "$OUTPUT_DIR/network_info.txt"
arp -a >> "$OUTPUT_DIR/network_info.txt"
echo "Routing Table:" >> "$OUTPUT_DIR/network_info.txt"
route -n >> "$OUTPUT_DIR/network_info.txt"
echo "Firewall Rules (iptables):" >> "$OUTPUT_DIR/iptables_rules.txt"
iptables -L -v -n >> "$OUTPUT_DIR/iptables_rules.txt"
echo "Firewall Rules (ufw):" >> "$OUTPUT_DIR/ufw_status.txt"
ufw status verbose >> "$OUTPUT_DIR/ufw_status.txt"

# File System Information
echo "Collecting file system information..."
echo "Mounted File Systems:" > "$OUTPUT_DIR/filesystems.txt"
df -h >> "$OUTPUT_DIR/filesystems.txt"
echo "Disk Usage:" >> "$OUTPUT_DIR/filesystems.txt"
du -sh /home/* >> "$OUTPUT_DIR/filesystems.txt"
echo "Open Files:" >> "$OUTPUT_DIR/filesystems.txt"
lsof >> "$OUTPUT_DIR/filesystems.txt"
echo "Recently Modified Files:" > "$OUTPUT_DIR/recently_modified_files.txt"
find / -type f -mtime -7 -exec ls -lh {} \; >> "$OUTPUT_DIR/recently_modified_files.txt"
echo "Large Files:" > "$OUTPUT_DIR/large_files.txt"
find / -type f -size +100M -exec ls -lh {} \; >> "$OUTPUT_DIR/large_files.txt"

# Log Files
echo "Collecting log files..."
cp /var/log/syslog "$OUTPUT_DIR/"
cp /var/log/auth.log "$OUTPUT_DIR/"
cp /var/log/dmesg "$OUTPUT_DIR/"
cp /var/log/kern.log "$OUTPUT_DIR/"
cp /var/log/secure "$OUTPUT_DIR/"
cp /var/log/faillog "$OUTPUT_DIR/"

# Scheduled Tasks
echo "Collecting scheduled tasks..."
echo "Cron Jobs:" > "$OUTPUT_DIR/cron_jobs.txt"
crontab -l >> "$OUTPUT_DIR/cron_jobs.txt"
ls /etc/cron.* >> "$OUTPUT_DIR/cron_jobs.txt"

# System Configuration
echo "Collecting system configuration..."
echo "Network Configuration:" > "$OUTPUT_DIR/system_config.txt"
cat /etc/network/interfaces >> "$OUTPUT_DIR/system_config.txt"
echo "Hosts File:" >> "$OUTPUT_DIR/system_config.txt"
cat /etc/hosts >> "$OUTPUT_DIR/system_config.txt"
echo "Resolv.conf:" >> "$OUTPUT_DIR/system_config.txt"
cat /etc/resolv.conf >> "$OUTPUT_DIR/system_config.txt"
echo "Services:" >> "$OUTPUT_DIR/system_config.txt"
service --status-all >> "$OUTPUT_DIR/system_config.txt"
echo "Loaded Kernel Modules:" >> "$OUTPUT_DIR/kernel_modules.txt"
lsmod >> "$OUTPUT_DIR/kernel_modules.txt"
echo "Systemd Services:" >> "$OUTPUT_DIR/systemd_services.txt"
systemctl list-units --type=service --all >> "$OUTPUT_DIR/systemd_services.txt"

# Application-Specific Logs
mkdir -p "$OUTPUT_DIR/apache_logs"
cp /var/log/apache2/* "$OUTPUT_DIR/apache_logs/"
mkdir -p "$OUTPUT_DIR/nginx_logs"
cp /var/log/nginx/* "$OUTPUT_DIR/nginx_logs/"
mkdir -p "$OUTPUT_DIR/mysql_logs"
cp /var/log/mysql/* "$OUTPUT_DIR/mysql_logs/"
mkdir -p "$OUTPUT_DIR/postgresql_logs"
cp /var/log/postgresql/* "$OUTPUT_DIR/postgresql_logs/"

# SSH Configuration
echo "Collecting SSH configuration..."
echo "SSH Configurations:" > "$OUTPUT_DIR/ssh_config.txt"
cat /etc/ssh/sshd_config >> "$OUTPUT_DIR/ssh_config.txt"
cat /etc/ssh/ssh_config >> "$OUTPUT_DIR/ssh_config.txt"

# End of script
echo "Forensic triage completed. Data saved to $OUTPUT_DIR"

# Zip up the output directory
echo "Zipping up the output directory..."
zip -r "../$OUTPUT_DIR.zip" "$OUTPUT_DIR"
# Delete the output directory
echo "Deleting the output directory..."
rm -rf "$OUTPUT_DIR"
