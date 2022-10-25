#!/bin/sh
# Copyright (C) 2022 Topias Mariapori (topias@mariapori.fi)
# Permission to copy and modify is granted under the MIT license
# Last revised 25.10.2022
#
## Usage: install [applicationPath] [appName] [appPort] [domain]
##
echo "Creating nginx site"
echo "server {
    server_name $4;

    location / {
       proxy_pass http://localhost:$3;
       proxy_http_version 1.1;
       proxy_set_header   Upgrade \$http_upgrade;
       proxy_set_header   Connection keep-alive;
       proxy_set_header   Host \$host;
       proxy_cache_bypass \$http_upgrade;
       proxy_set_header   X-Forwarded-For \$proxy_add_x_forwarded_for;
       proxy_set_header   X-Forwarded-Proto \$scheme;
    }

    listen 80;
}" > /etc/nginx/sites-enabled/$2
echo "Restart nginx"
systemctl restart nginx
echo "nginx configured"
echo "Creating systemd service"
echo "[Unit]
Description=$2

[Service]
WorkingDirectory=$1
ExecStart=dotnet $1/$2.dll
Restart=always
# Restart service after 10 seconds if the dotnet service crashes:
RestartSec=10
KillSignal=SIGINT
SyslogIdentifier=$2
User=ubuntu
Environment=ASPNETCORE_ENVIRONMENT=Production
Environment=DOTNET_PRINT_TELEMETRY_MESSAGE=false

[Install]
WantedBy=multi-user.target
" > /etc/systemd/system/$2.service
echo "enabling service"
systemctl enable $2.service
echo "service enabled"

echo "Done!"
