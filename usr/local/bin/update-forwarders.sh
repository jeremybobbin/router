#!/bin/sh
# update /etc/forwarders name servers taken from dhcpcd
tmp="$(mktemp)"

{
	echo 'forwarders {';
	printf '\t%s;\n' ${new_domain_name_servers?};
	echo '};';
} > $tmp

# cmp returns fails when files differ.
if ! cmp "$tmp" /etc/forwarders.conf >/dev/null; then
	cp "$tmp" /etc/forwarders.conf 
fi

rndc reconfig
