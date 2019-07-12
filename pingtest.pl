#!/usr/bin/perl

use strict;
use Getopt::Std;
use Data::Dumper;

sub HELP_MESSAGE {
##############################################################################
# ABOUT THIS SCRIPT ##########################################################
##############################################################################
        print <<EOF;
 
This script pings a host from a variety of interfaces and reports packet loss/rtt.
 
Usage example:
 
while true; do perl $0 -c 10 -I eth4,tun0,tun1 -d ping.ubnt.com; sleep 120; done
 
Optional Flags:
 
    -v              Verbose. Lots of debugging information.
    -h              This message.
    -c              Number of ICMP packets to send (default 10)
    -I              Interfaces to ping from (default eth4,tun0,tun1)
    -d              destination host (default ping.ubnt.com)
 
This is $0 version 0.0.
 
VERSION HISTORY
2019-04-01 
EOF
        exit();
}
 
##############################################################################
# TO DO/BUGS #################################################################
##############################################################################
#
# It may break if your ping implementation doesn't output in the expected 
# format. Use the -v flag to see what may need changing in the code.
# 
# To Do:
# * Log to syslog or twitter or someplace
# * Auto-fail from one tunnel to another
 
##############################################################################
# MAIN CODE ##################################################################
##############################################################################
 
# getopts('vhi:') means v and h are flags, and i is a parameter
getopts('vhc:I:d:');
HELP_MESSAGE() if ($main::opt_h);
$main::DEBUG = 1 if ($main::opt_v);
$main::COUNT = ($main::opt_c) ? ($main::opt_c) : 10;
$main::HOST = ($main::opt_d) ? ($main::opt_d) : 'ping.ubnt.com';
my @interfaces;
if ($main::opt_I) {
	die unless @interfaces = split /,/,$main::opt_I;
} else {
	@interfaces = ( 'eth4', 'tun0', 'tun1');

}
# debug("well hi there");
debug("we'll do $main::COUNT packets to $main::HOST");
print Dumper(@interfaces) if $main::DEBUG;

# /bin/ping -I tun0 -c10 -q -A ping.ubnt.com
# my $output = `date`; # or blank if using syslog
my $output = "";
chomp $output;

foreach (@interfaces) {
	my $command = "/bin/ping -q -I " . $_ . " -c" . $main::COUNT . " -A " . $main::HOST;
	debug($command);
	my $result = `$command` || die;  # everything in one string
	my @result = split /\n/, $result; # an array of lines
	print Dumper(@result) if $main::DEBUG;
	$result[3] =~ /(\d+)%/;
	my $packetloss = $1;
	debug("packetloss $packetloss");
	$result[4] =~ /(\S+) ms/;
	my @rtt = split /\//, $1; # min/avg/max/dev
	debug("rtt $rtt[1]");
	$rtt[1] = $rtt[1] ? $rtt[1] : "**** $_ DOWN ****";
	$output .= " $packetloss% $rtt[1] ms";
}

print $output . "\n";

##############################################################################
##### SUBROUTINES ############################################################
##############################################################################
 
sub debug {
        my $info = shift;
        print "DEBUG: " . $info . "\n" if $main::DEBUG;
}