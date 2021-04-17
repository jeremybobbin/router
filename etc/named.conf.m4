// vim:set ts=4 sw=4 et:

acl internals {
    localhost;
    localnets;
};

options {
    directory "/var/named";
    dump-file "/var/named/named_dump.db";

    pid-file "/run/named/named.pid";

    listen-on { 10.0.1.1; };

    recursion yes;
    //forward only;
    allow-query { internals; };
    allow-query-cache { internals; };
    allow-recursion { internals; };
    allow-transfer { internals; };
    allow-update { internals; };

    include "/etc/forwarders.conf";

    version none;
    hostname none;
    server-id none;
    auth-nxdomain no;
    querylog yes;
};

include "/etc/rndc.key";

zone "jer.sh" IN {
    type master;
    file "/var/named/jer.sh.zone";
    allow-update { key rndc-key; };
};

zone "1.0.10.in-addr.arpa" IN {
    type master;
    file "/var/named/jer.sh.rev.zone";
    allow-update { key rndc-key; };
};

logging {
        channel query_logging {
                file "/var/log/querylog";
                severity debug 3;
                print-time yes;
        };
 
        category queries {
                query_logging;
        };
};
