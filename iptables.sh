# Add these to your firewall script on your host if required
#
/sbin/iptables -N SIP
/sbin/iptables -N SIPREG
/sbin/iptables -N SIPINV
/sbin/iptables -A INPUT -p udp -m udp --dport 5060 -j SIP

# Enable Asterisk webserver for uptime monitoring
/sbin/iptables -A INPUT -p tcp --dport 8088 -m state --state NEW -j ACCEPT

# Enable RTP port range
/sbin/iptables -A INPUT -p udp -m udp --dport 16384:17000 -j ACCEPT

# Drop script kiddie scans
/sbin/iptables -A SIP -p udp -m udp --dport 5060 -m string --string "sundayddr" --algo bm --to 1500 -j DROP
/sbin/iptables -A SIP -p udp -m udp --dport 5060 -m string --string "sipsak" --algo bm --to 1500-j DROP
/sbin/iptables -A SIP -p udp -m udp --dport 5060 -m string --string "sipvicious" --icase --algo bm --to 1500 -j DROP
/sbin/iptables -A SIP -p udp -m udp --dport 5060 -m string --string "sipcli" --algo bm --to 1500 -j DROP
/sbin/iptables -A SIP -p udp -m udp --dport 5060 -m string --string "friendly-scanner" --algo bm --to 1500 -j DROP
/sbin/iptables -A SIP -p udp -m udp --dport 5060 -m string --string "iWar" --algo bm --to 1500 -j DROP
/sbin/iptables -A SIP -p udp -m udp --dport 5060 -m string --string "sip-scan" --algo bm --to 1500 -j DROP
/sbin/iptables -A SIP -p udp -m udp --dport 5060 -m string --string "eyeBeam" --algo bm --to 1500 -j DROP
/sbin/iptables -A SIP -p udp -m udp --dport 5060 -m string --string "VaxSIPUserAgent" --algo bm --to 1500 -j DROP
/sbin/iptables -A SIP -p udp -m udp --dport 5060 -m string --string "sip:nm@nm" --algo bm --to 1500 -j DROP
/sbin/iptables -A SIP -p udp -m udp --dport 5060 -m string --string "sip:nm2@nm2" --algo bm --to 1500 -j DROP
/sbin/iptables -A SIP -p udp -m udp --dport 5060 -m string --string "sip:n@n" --algo bm --to 1500 -j DROP

# Rate limit INVITE and REGISTER messages
/sbin/iptables -A SIP -p udp -m udp --dport 5060 -m string --string "INVITE" --algo bm --from 23 --to 28 -j SIPINV
/sbin/iptables -A SIP -p udp -m udp --dport 5060 -m string --string "REGISTER" --algo bm --from 23 --to 30 -j SIPREG
/sbin/iptables -A SIP -p udp -m udp --dport 5060 -m string --string "OPTIONS" --algo bm --from 23 --to 30 -j SIPOPT
/sbin/iptables -A SIP -j ACCEPT

# The limits of these rules may have to be changed. While testing, it's best to disable them.
/sbin/iptables -A SIPINV -m hashlimit --hashlimit-upto 4/min --hashlimit-burst 4 --hashlimit-mode srcip,dstip,dstport --hashlimit-name sip-rateinv --hashlimit-srcmask 24 -j ACCEPT
/sbin/iptables -A SIPINV -m limit --limit 10/min -j LOG --log-prefix "SIPINV DROP: "
/sbin/iptables -A SIPINV -j REJECT

/sbin/iptables -A SIPREG -m hashlimit --hashlimit-upto 6/hour --hashlimit-burst 6 --hashlimit-mode srcip,dstip,dstport --hashlimit-name sip-ratereg --hashlimit-srcmask 24 -j ACCEPT
/sbin/iptables -A SIPREG -m limit --limit 10/min -j LOG --log-prefix "SIPREG DROP: "
/sbin/iptables -A SIPREG -j REJECT

/sbin/iptables -A SIPOPT -m hashlimit --hashlimit-upto 6/hour --hashlimit-burst 6 --hashlimit-mode srcip,dstip,dstport --hashlimit-name sip-rateopt --hashlimit-srcmask 24 -j ACCEPT
/sbin/iptables -A SIPOPT -m limit --limit 10/min -j LOG --log-prefix "SIPOPT DROP: "
/sbin/iptables -A SIPOPT -j REJECT
