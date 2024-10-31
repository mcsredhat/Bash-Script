# Install BIND package
yum install -y bind bind-utils

# Configure named.conf for external zone
cat <<EOT >> /etc/named.conf
zone "linuxcbt.external" IN {
    type master;
    file "linuxcbt.external";
    allow-update { none; };
};
EOT

# check the configuration file /etc/named.conf 
sudo named-checkconf /etc/named.conf


# create the copied zone file and rename it
cat <<EOT > /var/named/linuxcbt.external
\$TTL 60
@   IN SOA  linuxcbt.external. vdns-admin.linuxcbt.external. (
               2017121506  ; serial
               1D          ; refresh
               1H          ; retry
               1W          ; expire
               3H )        ; minimum
@          IN NS    linuxcbtserv2.linuxcbt.external.
@          IN NS    linuxcbtserv1.linuxcbt.external.
@          IN MX 2  linuxcbtserv1.linuxcbt.external.

linuxcbtserv2   IN A     $PRIMARY_SERVER_IP
linuxcbtserv1   IN A     $SECONDARY_SERVER_IP
www             IN CNAME linuxcbtserv2.linuxcbt.external.

EOT


# check configuration zone  /var/named/linuxcbt.external##
named-checkzone linuxcbt.external /var/named/linuxcbt.external


# Change ownership of the zone file
chown root:named /var/named/linuxcbt.external

# Restart the named service
systemctl restart named.service

# Query the DNS server for linuxcbt.external
dig @localhost linuxcbtserv1.linuxcbt.external
dig @$SECONDARY_SERVER_IP linuxcbt.external
dig @$SECONDARY_SERVER_IP www.linuxcbt.external
dig @$SECONDARY_SERVER_IP linuxcbt.external MX

EOF

echo "BIND DNS configuration completed successfully."


