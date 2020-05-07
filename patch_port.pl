#!/usr/bin/perl

$| = 1;

if($#ARGV < 1) {
   print "Usage: patch_port <port> sockbind/sockbind_nothumb\n";
   exit;
}

$portnum = $ARGV[0];
$binfile = $ARGV[1];

local $/;   # which moron wrote perl?

open(BINFILE, $binfile) || die("Cannot open $binfile\n");
binmode(BINFILE);
$bindata = <BINFILE>;
close(BINFILE);

# The last 7 bytes of the binary are the Literal Pool
# PP PP 00 00 00 00 00
# Where PPPP is the 16 bit Port number

$bindata = substr($bindata, 0, -7);

$ip32bit = "\x00\x00\x00\x00"; # bind to 0.0.0.0
$port16bit = pack('n', $portnum);

$bindata = $bindata . $port16bit .$ip32bit . "\x00";

open(OUTPUT, ">$binfile") || die("Cannot write to $binfile\n");
binmode(OUTPUT);
print OUTPUT $bindata;
close(OUTPUT);
