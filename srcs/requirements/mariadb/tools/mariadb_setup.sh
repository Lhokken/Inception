#!/bin/bash
set -e

# Assicura le directory di runtime e i permessi corretti
mkdir -p /run/mysqld
chown -R mysql:mysql /run/mysqld
chown -R mysql:mysql /var/lib/mysql

# Inizializza il database se la directory di sistema non esiste
if [ ! -d "/var/lib/mysql/mysql" ]; then
    mariadb-install-db --user=mysql --datadir=/var/lib/mysql > /dev/null
fi

# Configura database e utenti se il DB principale non è ancora stato creato
if [ ! -d "/var/lib/mysql/${MYSQL_DATABASE}" ]; then
    tmpfile=$(mktemp)

    cat << EOF > "$tmpfile"
USE mysql;
FLUSH PRIVILEGES;
ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';
FLUSH PRIVILEGES;
EOF

    # Esegue la configurazione iniziale in modalità bootstrap
    mysqld --user=mysql --bootstrap < "$tmpfile"
    rm -f "$tmpfile"
fi

# Avvia il server MariaDB in ascolto su tutte le interfacce di rete
exec mysqld --user=mysql --bind-address=0.0.0.0