#!/usr/bin/perl

$| = 1;

if($#ARGV < 2) {
   print "Usage: patch_ip <IP address> <port> sockconnect/sockconnect_nothumb\n";
   exit;
}

$ipaddress = $ARGV[0];
$portnum = $ARGV[1];
$binfile = $ARGV[2];

local $/;   # which moron wrote perl?

open(BINFILE, $binfile) || die("Cannot open $binfile\n");
binmode(BINFILE);
$bindata = <BINFILE>;
close(BINFILE);

# The last 7 bytes of the binary are the Literal Pool
# PP PP AA AA AA AA 00
# Where PPPP is the 16 bit Port number
# and AAAAAAAA is the 32 bit IP Address

$bindata = substr($bindata, 0, -7);

@ipbytes = split(/\./, $ipaddress);
$ip32bit = pack('CCCC', @ipbytes);
$port16bit = pack('n', $portnum);

$bindata = $bindata . $port16bit .$ip32bit . "\x00";

open(OUTPUT, ">$binfile") || die("Cannot write to $binfile\n");
binmode(OUTPUT);
print OUTPUT $bindata;
close(OUTPUT);
