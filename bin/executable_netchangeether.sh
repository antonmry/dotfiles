#! /bin/bash


## Ethernet
nmcli connection modify uuid d5d63572-ef3b-3abe-b881-c426b1c2a671 ipv6.route-metric 100
nmcli connection modify uuid d5d63572-ef3b-3abe-b881-c426b1c2a671 ipv4.route-metric 100
nmcli connection up uuid d5d63572-ef3b-3abe-b881-c426b1c2a671

## Wifi
nmcli connection modify uuid 95f1df3b-cca9-4c4c-902b-ed9642065bff ipv6.route-metric 1000
nmcli connection modify uuid 95f1df3b-cca9-4c4c-902b-ed9642065bff ipv4.route-metric 1000
nmcli connection up uuid 95f1df3b-cca9-4c4c-902b-ed9642065bff

## Mobile tethering
nmcli connection modify uuid 0f379466-91c6-3e15-b1bd-b0b0fc3bf01b ipv6.route-metric 500
nmcli connection modify uuid 0f379466-91c6-3e15-b1bd-b0b0fc3bf01b ipv4.route-metric 500
nmcli connection up uuid 0f379466-91c6-3e15-b1bd-b0b0fc3bf01b

ip route
