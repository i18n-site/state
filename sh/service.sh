#!/usr/bin/env bash

DIR=$(realpath $0) && DIR=${DIR%/*/*}
cd $DIR
set -ex

workdir=$DIR/lib
exe="bash -c 'source /etc/profile && exec $(which mise) exec -- ./main.js'"

service_name=state

service_file="/etc/systemd/system/$service_name.service"

cat >"$service_file" <<EOF
[Unit]
Description=$service_name
After=network.target

[Service]
Type=simple
ExecStart=$exe
Restart=on-failure
RestartSec=3
StartLimitBurst=9
StartLimitIntervalSec=600
WorkingDirectory=$workdir

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable --now $service_name
systemctl restart $service_name
