getIP () {
	ifconfig en0 | grep netmask | awk '{print "lan: "$2}'
	ifconfig en1 | grep netmask | awk '{print "wifi: "$2}'
}