#!/bin/bash

rm -f /var/run/xrdp/xrdp*.pid /var/run/xrdp/sesman*.pid
rm -f /tmp/.X11-unix/X[0-9]*
mkdir -p /tmp/.X11-unix /var/run/xrdp /var/run/dbus
chmod 1777 /tmp/.X11-unix

service dbus start
for i in $(seq 1 20); do
    dbus-send --system --print-reply --dest=org.freedesktop.DBus \
        / org.freedesktop.DBus.ListNames >/dev/null 2>&1 && break
    sleep 0.5
done

touch /var/log/xrdp.log /var/log/xrdp-sesman.log
exec tail -F /var/log/xrdp.log /var/log/xrdp-sesman.log
