#!/system/bin/sh

# custom busybox installation shortcut
bb=/sbin/bb/busybox;

# Set TCP westwood
echo "westwood" > /proc/sys/net/ipv4/tcp_congestion_control

# Apply fq pie packet sched
tc qdisc add dev wlan0 root fq_pie
tc qdisc add dev rmnet_data0 root fq_pie
