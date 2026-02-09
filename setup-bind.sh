#!/bin/bash
# ======================================================
# Script: setup-bind.sh
# Autor: Fernando Rodriguez
# Descripción:
# Configuración completa de servidor DNS BIND9
# para el dominio uno.net
# ======================================================

set -e

# ========================
# VARIABLES DEL LAB
# ========================
DNS_IP="192.168.1.10"
DOMAIN="uno.net"

S1_IP="192.168.1.20"
S2_IP="192.168.1.21"
S3_IP="192.168.1.22"

INTERFACE=$(ip -o -4 route show to default | awk '{print $5}')

echo "[+] Interfaz detectada: $INTERFACE"

# ========================
# CONFIGURAR RED ESTÁTICA
# ========================
echo "[+] Configurando red estática..."

cat > /etc/network/interfaces <<EOF
auto lo
iface lo inet loopback

auto $INTERFACE
iface $INTERFACE inet static
    address $DNS_IP
    netmask 255.255.255.0
    gateway 192.168.1.1
EOF

systemctl restart networking

# ========================
# INSTALAR BIND
# ========================
echo "[+] Instalando BIND9..."

apt update
apt install -y bind9 bind9-utils dnsutils

# ========================
# CONFIGURACIÓN DE BIND
# ========================
echo "[+] Configurando BIND..."

cat > /etc/bind/named.conf.options <<EOF
options {
    directory "/var/cache/bind";

    recursion yes;
    allow-query { any; };

    listen-on { any; };
    listen-on-v6 { none; };

    forwarders {
        8.8.8.8;
        8.8.4.4;
    };

    dnssec-validation auto;
};
EOF

cat > /etc/bind/named.conf.local <<EOF
zone "$DOMAIN" {
    type master;
    file "/etc/bind/db.$DOMAIN";
};
EOF

# ========================
# ARCHIVO DE ZONA
# ========================
echo "[+] Creando zona DNS..."

cat > /etc/bind/db.$DOMAIN <<EOF
\$TTL    604800
@       IN      SOA     bind.$DOMAIN. admin.$DOMAIN. (
                        2026020601
                        604800
                        86400
                        2419200
                        604800 )

@       IN      NS      bind.$DOMAIN.

bind    IN      A       $DNS_IP
www     IN      A       $S1_IP
db1     IN      A       $S2_IP
db2     IN      A       $S3_IP
EOF

chown root:bind /etc/bind/db.$DOMAIN
chmod 644 /etc/bind/db.$DOMAIN

# ========================
# VALIDACIONES
# ========================
echo "[+] Validando configuración..."

named-checkconf
named-checkzone $DOMAIN /etc/bind/db.$DOMAIN

# ========================
# REINICIAR BIND
# ========================
echo "[+] Reiniciando BIND..."

systemctl restart bind9
systemctl enable bind9

# ========================
# CONFIGURAR DNS LOCAL
# ========================
echo "[+] Configurando DNS local..."

echo "nameserver 127.0.0.1" > /etc/resolv.conf

# ========================
# PRUEBA FINAL
# ========================
echo "[+] Prueba DNS local:"
dig @127.0.0.1 www.$DOMAIN +short

echo "[✓] Servidor DNS BIND configurado correctamente"
