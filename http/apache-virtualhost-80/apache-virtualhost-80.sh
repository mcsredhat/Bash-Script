#!/bin/bash

### Global Variables ###
PACKAGES=(httpd mod_ssl openssl openssl-devel ca-certificates php php-cli php-mysqlnd php-gd php-xml php-mbstring php-curl php-zip php-soap)
SERVICES=(httpd firewalld named)
FIREWALL_PORTS=("80/tcp" "443/tcp" "53/tcp" "53/udp")
FIREWALL_SERVICES=(http https dns)
SELINUX_BOOLEANS=(httpd_can_network_connect httpd_execmem httpd_use_nfs httpd_read_user_content httpd_can_network_relabel httpd_enable_cgi)
HOST_ENTRIES=("172.31.43.107 linuxcbtserv3.linuxcbt.internal linuxcbtserv3"
              "172.31.44.229 site1.linuxcbt.internal"
              "172.31.35.154 linuxcbtserv2.linuxcbt.internal linuxcbtserv2"
              "172.31.44.229 linuxcbtserv1.linuxcbt.internal linuxcbtserv1")
RESOLV_CONF_CONTENT=("search linuxcbt.internal"
                     "nameserver 172.31.44.229"
                     "nameserver 172.31.35.154"
                     "nameserver 172.31.108.225")
ZONE_FILE="/var/named/linuxcbt.internal"
ZONE_ENTRIES=('$TTL 60'
              "@   IN SOA  linuxcbt.internal. vdns-admin.linuxcbt.internal. ("
              "               2017121506  ; serial"
              "               1D          ; refresh"
              "               1H          ; retry"
              "               1W          ; expire"
              "               3H )        ; minimum"
              "           IN NS   linuxcbtserv2.linuxcbt.internal."
              "           IN NS   linuxcbtserv3.linuxcbt.internal."
              "linuxcbtserv1   IN A    172.31.108.225"
              "linuxcbtserv2   IN A    172.31.97.38"
              "linuxcbtserv3   IN A    172.31.43.107"
              "www             IN A    172.31.97.38"
              "www             IN A    172.31.43.107"
              "                IN MX  2    linuxcbtserv1.linuxcbt.internal."
              "@               IN NS   linuxcbtserv1.linuxcbt.internal."
              "@               IN NS   linuxcbtserv2.linuxcbt.internal."
              "@               IN NS   linuxcbtserv3.linuxcbt.internal."
              "site1           IN A    172.31.108.225")

### Function Definitions ###

# Function to check if the previous command ran successfully
check_status() {
    if [ $? -ne 0 ]; then
        echo "Error executing: $1"
        exit 1
    fi
}

# Function to install required packages
install_packages() {
    echo "Installing required packages..."
    sudo yum install -y "${PACKAGES[@]}"
    check_status "Package installation"
}

# Function to enable and start services
enable_start_services() {
    echo "Enabling and starting services..."
    for service in "${SERVICES[@]}"; do
        sudo systemctl enable "$service" && sudo systemctl start "$service"
        check_status "$service enable/start"
    done
}

# Function to configure firewall rules
configure_firewall() {
    echo "Configuring firewall rules..."
    for port in "${FIREWALL_PORTS[@]}"; do
        sudo firewall-cmd --permanent --add-port="$port"
        check_status "Adding port $port to firewall"
    done
    for service in "${FIREWALL_SERVICES[@]}"; do
        sudo firewall-cmd --permanent --add-service="$service"
        check_status "Adding service $service to firewall"
    done
    sudo firewall-cmd --reload
    check_status "Reloading firewall"
}

# Function to configure SELinux booleans
configure_selinux() {
    echo "Configuring SELinux boolean settings..."
    for bool in "${SELINUX_BOOLEANS[@]}"; do
        sudo setsebool -P "$bool" on
        check_status "Setting SELinux boolean $bool"
    done
}

# Function to ensure each entry in HOST_ENTRIES is in /etc/hosts
configure_hosts_file() {
    echo "Configuring /etc/hosts..."
    for entry in "${HOST_ENTRIES[@]}"; do
        if ! grep -q "$entry" /etc/hosts; then
            echo "$entry" | sudo tee -a /etc/hosts
            check_status "Adding host entry $entry"
        else
            echo "Host entry '$entry' already present."
        fi
    done
}

# Function to configure resolv.conf
configure_resolv_conf() {
    echo "Configuring /etc/resolv.conf..."
    for line in "${RESOLV_CONF_CONTENT[@]}"; do
        if ! grep -q "$line" /etc/resolv.conf; then
            echo "$line" | sudo tee -a /etc/resolv.conf
            check_status "Adding line '$line' to resolv.conf"
        else
            echo "Line '$line' already in resolv.conf"
        fi
    done
}

# Function to configure Apache virtual host
create_virtual_host() {
    echo "Creating Apache virtual host..."
    local vhost_file="/etc/httpd/conf.d/site1.linuxcbt.internal.conf"
    if [ ! -f "$vhost_file" ]; then
        cat <<EOF | sudo tee "$vhost_file"
<VirtualHost *:80>
    ServerAdmin ansible@linuxcbtserv2.linuxcbt.internal
    ServerName site1.linuxcbt.internal
    DocumentRoot /var/www/site1.linuxcbt.internal
    <Directory /var/www/site1.linuxcbt.internal>
        Order allow,deny
        Allow from all
    </Directory>
</VirtualHost>
EOF
        check_status "Creating virtual host configuration"
    else
        echo "Virtual host file already exists."
    fi
    sudo apachectl configtest
    check_status "Apache configuration test"
}

# Function to configure DNS zone file
configure_dns_zone_file() {
    echo "Configuring DNS zone file $ZONE_FILE..."
    sudo cp "$ZONE_FILE" "$ZONE_FILE.bak"
    for entry in "${ZONE_ENTRIES[@]}"; do
        if ! grep -q "$entry" "$ZONE_FILE"; then
            echo "$entry" | sudo tee -a "$ZONE_FILE"
            check_status "Adding zone entry '$entry'"
        else
            echo "Zone entry '$entry' already present."
        fi
    done
    sudo chown named:named "$ZONE_FILE"
    sudo chmod 640 "$ZONE_FILE"
    check_status "Setting permissions on DNS zone file"
}

# Function to verify and reload services
verify_and_reload_services() {
    echo "Verifying DNS and reloading services..."
    sudo named-checkzone linuxcbt.internal "$ZONE_FILE"
    sudo named-checkconf /etc/named.conf
    check_status "DNS configuration checks"
    sudo systemctl restart named.service
    check_status "Restarting named service"
    sudo systemctl reload httpd.service
    check_status "Reloading httpd service"
}

# Main function to execute all steps
main() {
    install_packages
    enable_start_services
    configure_firewall
    configure_selinux
    configure_hosts_file
    configure_resolv_conf
    create_virtual_host
    configure_dns_zone_file
    verify_and_reload_services
    echo "All configurations completed successfully."
}

# Run the main function
main
