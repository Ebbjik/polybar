#!/bin/bash
echo "$(date): clicked" >>/tmp/polybar-click.log
export DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/1000/bus"
exec blueman-manager
