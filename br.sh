brctl addbr br0
brctl stp br0 off
brctl addif br0 eno1
ifconfig eno1 down
ifconfig eno1 0.0.0.0 up
ifconfig br0 10.10.0.10 up
ifconfig br0 netmask 255.255.255.0
route add default gw 10.10.0.1 br0
