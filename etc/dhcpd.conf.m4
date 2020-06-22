# dhcpd.conf
#
# Sample configuration file for ISC dhcpd
#

# option definitions common to all supported networks...
default-lease-time 600;
max-lease-time 7200;

# Use this to enble / disable dynamic dns updates globally.
ddns-updates on;
ddns-update-style standard;
authoritative;
include "/etc/rndc.key";

allow unknown-clients;
use-host-decl-names on;
default-lease-time 86400;
max-lease-time 86400;

# Use this to send dhcp log messages to a different log file (you also
# have to hack syslog.conf to complete the redirection).
log-facility local7;

zone jer.sh. {
	primary 10.0.1.1;
	key rndc-key;
}

zone 1.0.10.in-addr.arpa. {
	primary 10.0.1.1;
	key rndc-key;
}

# No service will be given on this subnet, but declaring it helps the 
# DHCP server to understand the network topology.

define(`defstation', `
    host $2
      {
        hardware ethernet $3;
        fixed-address $4;
      }')dnl
dnl

subnet 10.0.1.0 netmask 255.255.255.0 {
	range 10.0.1.10 10.0.1.254;
	option subnet-mask 255.255.255.0;
	option routers 10.0.1.1;
	option domain-name "ns.jer.sh";
	option domain-name-servers 10.0.1.1;
	ddns-domainname "jer.sh.";
	ddns-rev-domainname "in-addr.arpa.";


	defstation(1, `T420', `00:21:cc:4b:0f:20', 10.0.1.2)
	defstation(2, `Tensorbook', `80:fa:5b:66:10:c1', 10.0.1.4)
}

