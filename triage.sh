#!/bin/bash

# Check if script is run as root
if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root."
    exit 1
fi

# Define output directory
OUTPUTNM="forensics_$(date +%Y%m%d%H%M%S)"
OUTPUT_ROOT="/tmp"
OUTPUT_DIR="$OUTPUT_ROOT/$OUTPUTNM"
mkdir -p "$OUTPUT_DIR"

# Redirect all outputs to log file
exec > >(tee -i "$OUTPUT_DIR/forensics.log") 2>&1

echo "Starting forensic triage..."

# Initialize error array
ERRORS=()

function log_error {
    ERRORS+=("$1")
    echo "ERROR: $1"
}

# Function to collect system information
collect_system_info() {
    echo "Collecting system information..."
    {
        echo "Date and Time:"
        date
        echo "Uptime:"
        uptime
        echo "Hostname:"
        hostname
        echo "Kernel Version:"
        uname -a
        echo "System Information:"
        if command -v lshw >/dev/null 2>&1; then
            lshw -short
        else
            echo "lshw command not found."
            log_error "lshw command not found."
        fi
    } > "$OUTPUT_DIR/system_info.txt"
}

# Function to collect user information
collect_user_info() {
    echo "Collecting user information..."
    {
        echo "Current Users:"
        w
        echo "Logged in Users:"
        who
        echo "Last Logins:"
        last
        echo "User List:"
        cat /etc/passwd
    } > "$OUTPUT_DIR/users.txt"

    echo "User Groups:" > "$OUTPUT_DIR/groups.txt"
    if command -v getent >/dev/null 2>&1; then
        getent group >> "$OUTPUT_DIR/groups.txt"
    else
        echo "getent command not found."
        log_error "getent command not found."
    fi

    echo "Sudoers Configuration:" > "$OUTPUT_DIR/sudoers.txt"
    if [ -f /etc/sudoers ]; then
        cat /etc/sudoers >> "$OUTPUT_DIR/sudoers.txt"
    fi
    if [ -d /etc/sudoers.d ]; then
        cat /etc/sudoers.d/* >> "$OUTPUT_DIR/sudoers.txt" 2>/dev/null
    fi
}

# Function to collect process information
collect_process_info() {
    echo "Collecting process information..."
    {
        echo "Running Processes:"
        ps aux
        echo "Top Processes:"
        top -b -n 1 | head -n 20
    } > "$OUTPUT_DIR/processes.txt"
}

# Function to collect network information
collect_network_info() {
    echo "Collecting network information..."
    {
        echo "Network Interfaces:"
        if command -v ip >/dev/null 2>&1; then
            ip addr show
        elif command -v ifconfig >/dev/null 2>&1; then
            ifconfig -a
        else
            echo "Neither ip nor ifconfig commands are available."
            log_error "ip and ifconfig commands not found."
        fi

        echo "Active Connections:"
        if command -v ss >/dev/null 2>&1; then
            ss -tulnp
        elif command -v netstat >/dev/null 2>&1; then
            netstat -tulnp
        else
            echo "Neither ss nor netstat commands are available."
            log_error "ss and netstat commands not found."
        fi

        echo "ARP Cache:"
        if command -v ip >/dev/null 2>&1; then
            ip neigh show
        elif command -v arp >/dev/null 2>&1; then
            arp -a
        else
            echo "Neither ip nor arp commands are available."
            log_error "ip and arp commands not found."
        fi

        echo "Routing Table:"
        if command -v ip >/dev/null 2>&1; then
            ip route show
        elif command -v route >/dev/null 2>&1; then
            route -n
        else
            echo "Neither ip nor route commands are available."
            log_error "ip and route commands not found."
        fi
    } > "$OUTPUT_DIR/network_info.txt"

    echo "Firewall Rules (iptables):" > "$OUTPUT_DIR/iptables_rules.txt"
    if command -v iptables >/dev/null 2>&1; then
        iptables -L -v -n >> "$OUTPUT_DIR/iptables_rules.txt"
    else
        echo "iptables command not found."
        log_error "iptables command not found."
    fi

    echo "Firewall Rules (ufw):" > "$OUTPUT_DIR/ufw_status.txt"
    if command -v ufw >/dev/null 2>&1; then
        ufw status verbose >> "$OUTPUT_DIR/ufw_status.txt"
    else
        echo "ufw command not found."
        log_error "ufw command not found."
    fi
}

# Function to collect file system information
collect_filesystem_info() {
    echo "Collecting file system information..."
    {
        echo "Mounted File Systems:"
        df -h
        echo "Disk Usage:"
        du -sh /home/* 2>/dev/null
        echo "Open Files:"
        if command -v lsof >/dev/null 2>&1; then
            lsof
        else
            echo "lsof command not found."
            log_error "lsof command not found."
        fi
    } > "$OUTPUT_DIR/filesystems.txt"

    echo "Recently Modified Files:" > "$OUTPUT_DIR/recently_modified_files.txt"
    # Limiting search to specific directories to reduce execution time
    find /etc /var /home -type f -mtime -1 -exec ls -lh {} \; >> "$OUTPUT_DIR/recently_modified_files.txt" 2>/dev/null
}

# Function to collect log files
collect_log_files() {
    echo "Collecting log files..."
    LOG_FILES=(
        "/var/log/syslog"
        "/var/log/auth.log"
        "/var/log/dmesg"
        "/var/log/kern.log"
        "/var/log/secure"
        "/var/log/faillog"
    )
    for logfile in "${LOG_FILES[@]}"; do
        if [ -f "$logfile" ]; then
            cp "$logfile" "$OUTPUT_DIR/"
        else
            echo "$logfile not found."
            log_error "$logfile not found."
        fi
    done
}

# Function to collect scheduled tasks
collect_scheduled_tasks() {
    echo "Collecting scheduled tasks..."
    echo "Cron Jobs:" > "$OUTPUT_DIR/cron_jobs.txt"
    crontab -l >> "$OUTPUT_DIR/cron_jobs.txt" 2>/dev/null
    ls /etc/cron.* >> "$OUTPUT_DIR/cron_jobs.txt" 2>/dev/null
}

# Function to collect system configuration
collect_system_config() {
    echo "Collecting system configuration..."
    {
        echo "Network Configuration:"
        if [ -f /etc/network/interfaces ]; then
            cat /etc/network/interfaces
        else
            echo "/etc/network/interfaces not found."
            log_error "/etc/network/interfaces not found."
        fi

        echo "Hosts File:"
        cat /etc/hosts

        echo "Resolv.conf:"
        cat /etc/resolv.conf

        echo "Services:"
        if command -v service >/dev/null 2>&1; then
            service --status-all
        else
            echo "service command not found."
            log_error "service command not found."
        fi
    } > "$OUTPUT_DIR/system_config.txt"

    echo "Loaded Kernel Modules:" > "$OUTPUT_DIR/kernel_modules.txt"
    lsmod >> "$OUTPUT_DIR/kernel_modules.txt"

    echo "Systemd Services:" > "$OUTPUT_DIR/systemd_services.txt"
    if command -v systemctl >/dev/null 2>&1; then
        systemctl list-units --type=service --all >> "$OUTPUT_DIR/systemd_services.txt"
    else
        echo "systemctl command not found."
        log_error "systemctl command not found."
    fi
}

# Function to collect application-specific logs
collect_app_logs() {
    echo "Collecting application-specific logs..."
    declare -A APP_LOGS=(
        [apache_logs]="/var/log/apache2"
        [nginx_logs]="/var/log/nginx"
        [mysql_logs]="/var/log/mysql"
        [postgresql_logs]="/var/log/postgresql"
    )
    for dir in "${!APP_LOGS[@]}"; do
        mkdir -p "$OUTPUT_DIR/$dir"
        if [ -d "${APP_LOGS[$dir]}" ]; then
            cp -r "${APP_LOGS[$dir]}"/* "$OUTPUT_DIR/$dir/" 2>/dev/null
        else
            echo "Directory ${APP_LOGS[$dir]} not found."
            log_error "Directory ${APP_LOGS[$dir]} not found."
        fi
    done
}

# Function to collect SSH configuration
collect_ssh_config() {
    echo "Collecting SSH configuration..."
    echo "SSH Configurations:" > "$OUTPUT_DIR/ssh_config.txt"
    if [ -f /etc/ssh/sshd_config ]; then
        cat /etc/ssh/sshd_config >> "$OUTPUT_DIR/ssh_config.txt"
    else
        echo "/etc/ssh/sshd_config not found."
        log_error "/etc/ssh/sshd_config not found."
    fi

    if [ -f /etc/ssh/ssh_config ]; then
        cat /etc/ssh/ssh_config >> "$OUTPUT_DIR/ssh_config.txt"
    else
        echo "/etc/ssh/ssh_config not found."
        log_error "/etc/ssh/ssh_config not found."
    fi

    if [ -f /root/.ssh/authorized_keys ]; then
        cat /root/.ssh/authorized_keys >> "$OUTPUT_DIR/ssh_config.txt"
    else
        echo "/root/.ssh/authorized_keys not found."
        log_error "/root/.ssh/authorized_keys not found."
    fi
}

# Main execution
collect_system_info
collect_user_info
collect_process_info
collect_network_info
collect_filesystem_info
collect_log_files
collect_scheduled_tasks
collect_system_config
collect_app_logs
collect_ssh_config

# Log errors if any
if [ ${#ERRORS[@]} -gt 0 ]; then
    echo "Errors encountered during execution:" > "$OUTPUT_DIR/errors.log"
    for err in "${ERRORS[@]}"; do
        echo "$err" >> "$OUTPUT_DIR/errors.log"
    done
fi

echo "Forensic triage completed. Data saved to $OUTPUT_DIR"

# Zip up the output directory
echo "Zipping up the output directory..."
zip -r "$OUTPUT_ROOT/$OUTPUTNM.zip" "$OUTPUT_DIR" >/dev/null

# Optionally delete the output directory
# rm -rf "$OUTPUT_DIR"

echo "Forensic data collection is complete. Archive saved to $OUTPUT_ROOT/$OUTPUTNM.zip"
