#!/bin/bash

# Global Variables
PACKAGES=(httpd mod_ssl openssl openssl-devel ca-certificates php php-cli php-mysqlnd php-gd php-xml php-mbstring php-curl php-zip php-soap)
SERVICES=(httpd firewalld named)
FIREWALL_PORTS=("80/tcp" "443/tcp" "53/tcp" "53/udp")
FIREWALL_SERVICES=(http https dns)
SELINUX_BOOLEANS=(httpd_can_network_connect httpd_execmem httpd_use_nfs httpd_read_user_content httpd_can_network_relabel httpd_enable_cgi)
HOST_ENTRIES=("172.31.43.107 linuxcbtserv3.linuxcbt.internal linuxcbtserv3" "172.31.44.229 site1.linuxcbt.internal" "172.31.35.154 linuxcbtserv2.linuxcbt.internal linuxcbtserv2" "172.31.44.229 linuxcbtserv1.linuxcbt.internal linuxcbtserv1")
RESOLV_CONF_CONTENT=("search linuxcbt.internal" "nameserver 172.31.44.229" "nameserver 172.31.35.154" "nameserver 172.31.108.225")
ZONE_FILE="/var/named/linuxcbt.internal"
ZONE_ENTRIES=('$TTL 60' "@   IN SOA  linuxcbt.internal. vdns-admin.linuxcbt.internal. (" "2017121506  ; serial" "1D ; refresh" "1H ; retry" "1W ; expire" "3H ) ; minimum" "IN NS linuxcbtserv2.linuxcbt.internal." "IN NS linuxcbtserv3.linuxcbt.internal." "linuxcbtserv1 IN A 172.31.108.225" "linuxcbtserv2 IN A 172.31.97.38" "linuxcbtserv3 IN A 172.31.43.107" "www IN A 172.31.97.38" "www IN A 172.31.43.107" "IN MX 2 linuxcbtserv1.linuxcbt.internal." "site1 IN A 172.31.108.225" "site2 IN CNAME site1.linuxcbt.internal.")

# Function to check if the previous command was successful
check_status() {
    if [ $? -ne 0 ]; then
        echo "Error executing: $1"
        exit 1
    fi
}

# Function to install packages
install_packages() {
    echo "Installing packages..."
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

# Function to configure the firewall
configure_firewall() {
    echo "Configuring firewall..."
    for port in "${FIREWALL_PORTS[@]}"; do
        sudo firewall-cmd --permanent --add-port="$port"
        check_status "Adding port $port"
    done
    for service in "${FIREWALL_SERVICES[@]}"; do
        sudo firewall-cmd --permanent --add-service="$service"
        check_status "Adding service $service"
    done
    sudo firewall-cmd --reload
    check_status "Reload firewall"
}

# Function to configure SELinux booleans
configure_selinux() {
    echo "Configuring SELinux booleans..."
    for bool in "${SELINUX_BOOLEANS[@]}"; do
        sudo setsebool -P "$bool" on
        check_status "Setting SELinux boolean $bool"
    done
}

# Function to configure /etc/hosts file
configure_hosts_file() {
    echo "Updating /etc/hosts..."
    for entry in "${HOST_ENTRIES[@]}"; do
        if ! grep -q "$entry" /etc/hosts; then
            echo "$entry" | sudo tee -a /etc/hosts
            check_status "Adding $entry to /etc/hosts"
        fi
    done
}

# Function to configure /etc/resolv.conf
configure_resolv_conf() {
    echo "Configuring resolv.conf..."
    for line in "${RESOLV_CONF_CONTENT[@]}"; do
        if ! grep -q "$line" /etc/resolv.conf; then
            echo "$line" | sudo tee -a /etc/resolv.conf
            check_status "Adding $line to resolv.conf"
        fi
    done
}

# Function to configure DNS zone file
configure_dns_zone_file() {
    echo "Configuring DNS zone file..."
    sudo cp "$ZONE_FILE" "$ZONE_FILE.bak"
    for entry in "${ZONE_ENTRIES[@]}"; do
        if ! grep -q "$entry" "$ZONE_FILE"; then
            echo "$entry" | sudo tee -a "$ZONE_FILE"
            check_status "Adding $entry to zone file"
        fi
    done
    sudo chown named:named "$ZONE_FILE"
    sudo chmod 640 "$ZONE_FILE"
}

# Function to set up SSL and Apache virtual host
setup_ssl_certificate() {
    echo "Setting up SSL certificate..."
    sudo openssl genrsa -out /etc/pki/tls/private/site1.linuxcbt.internal.key 2048
    sudo openssl req -new -key /etc/pki/tls/private/site1.linuxcbt.internal.key -out /etc/pki/tls/certs/site1.linuxcbt.internal.csr -subj "/C=US/ST=CA/L=SanFrancisco/O=Example/OU=Org/CN=site1.linuxcbt.internal"
    sudo openssl x509 -req -days 365 -in /etc/pki/tls/certs/site1.linuxcbt.internal.csr -signkey /etc/pki/tls/private/site1.linuxcbt.internal.key -out /etc/pki/tls/certs/site1.linuxcbt.internal.crt
    check_status "SSL Certificate Setup"
}

# Function to configure Apache for SSL
configure_apache_ssl() {
    echo "Configuring Apache for SSL..."
    sudo cp /etc/httpd/conf.d/ssl.conf /etc/httpd/conf.d/site1.ssl.linuxcbt.internal.conf
    cat <<EOF | sudo tee /etc/httpd/conf.d/site1.ssl.linuxcbt.internal.conf
Listen 443 https

<VirtualHost *:443>
    DocumentRoot "/var/www/site1.linuxcbt.internal"
    ServerName site1.linuxcbt.internal:443
    ServerAdmin admin@site1.linuxcbt.internal

    <Directory /var/www/site1.linuxcbt.internal>
        Order allow,deny
        Allow from all
    </Directory>

    SSLEngine on
    SSLCertificateFile /etc/pki/tls/certs/site1.linuxcbt.internal.crt
    SSLCertificateKeyFile /etc/pki/tls/private/site1.linuxcbt.internal.key
</VirtualHost>
EOF
    sudo apachectl configtest
    check_status "Apache configuration test"
    sudo systemctl restart httpd
}

# Main Function
main() {
    install_packages
    enable_start_services
    configure_firewall
    configure_selinux
    configure_hosts_file
    configure_resolv_conf
    configure_dns_zone_file
    setup_ssl_certificate
    configure_apache_ssl
    echo "Configuration complete."
}

# Run the main function
main
