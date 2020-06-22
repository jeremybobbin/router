#!/bin/sh -e
tmpdir="$(mktemp -d)"
#DESTDIR=${}
SUBNET=10.0.1.0
NETMASK=255.255.255.0
DOMAIN_NAME=jer.sh

# offsets
NS=1
DHCP=1

# subnet - turn IP addresses of stdin into the subnet addresses
# given $NETMASK or $1
#
# $ echo 10.0.1.4 | subnet 255.255.255.0
# 10.0.1.0
subnet() {
	awk 'BEGIN { FS=OFS="."; $0="'${1:-"$NETMASK"}'"; for (i=1; i <= NF; i++) a[i]=$i }
		{ for (i=1; i <= NF; i++) { $i = and(a[i], $i) } print }'
}

to_digit() {
	awk -F. '{ for (i=1; i <= NF; i++) { s = lshift(s, 8) + $i } print s }'
}

to_ip() {
	awk 'BEGIN { OFS="." } { while ($1 > 0) { a[++i] = and(0xff, $1); $1 = rshift($1, 8) } 
			while (i > 0) { $(++j) = a[i--] } print }'
}

ip_add() {
	echo $1 | to_digit | (read digit; echo $((digit + 2)) )
}

in_subnet() {
	echo "$1" | subnet | if read subnet; then 
		[ $1 != $SUBNET ] && [ $subnet = $SUBNET ]
	fi
}

file() {
	for src; do
		dest="${DESTDIR}/${src%.*}"
		case $type in
			d|dir|directory) : "${src}" | install -d ${dest} \
				-g ${group:-'root'} -o ${owner:-'root'} -m ${mode:-'755'};;
			f|file|*) 
				suffix="${src##*.}"
				[ -z "$preproc" ] && case "$suffix" in
					m4) preproc=m4;;
					*) preproc=cat;;
				esac
				"${preproc}" "${src}" | install -D /dev/stdin ${dest} \
					-g ${group:-'root'} -o ${owner:-'root'} -m ${mode:-'644'};;
		esac
		unset preproc type mode
	done
}

#
# TODO: move this segment to makefile?
#
mode=640 file etc/hostapd/*.conf
systemctl enable hostapd@wlp3s0 hostapd@wlp4s0
systemctl restart hostapd@wlp3s0 hostapd@wlp4s0

file etc/netctl/lan
netctl enable lan
netctl restart lan

mode=755 file usr/local/bin/*

groupadd -f dns-dhcp
rndc-confgen -a -b 512
chown :dns-dhcp "${DESTDIR}/etc/rndc.key"
group=named file etc/named.conf.m4
group=named type=dir mode=770 file var/named
mode=640 file var/named/*.zone
systemctl enable named
systemctl restart named

owner=dhcp group=dhcp file etc/dhcpd.conf.m4
systemctl enable dhcpd4
systemctl restart dhcpd4

