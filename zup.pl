#!/usr/bin/perl

# zoneedit ip update - updates your zoneedit ip with the detect wan
# ip address for dynamic ip addresses
# 
# Author: Chad R Mayfield (http://chadmayfield.com)
# Date: 07/10/2009
# License: GPLv3
#
# INFO: http://zoneedit.com/doc/dynamic.html?
# INFO: http://zoneedit.com/doc/dynamic/
# http://www.zoneedit.com/doc/dynamic/ReturnCodes.txt

use strict;
use warnings;

use LWP::UserAgent;
use LWP::Simple;

### start user variables ###
my $debug = "0"; # not heavily implemented yet
my $user = "username";
my $pass = "password";
my $zones = "first.domain.com,second.domain.com";
my $logfile = "/tmp/ip.log";
my $ipfile = "/tmp/ip.txt";
#my $ip_site = "http://dynamic.zoneedit.com/checkip.html"; #kinda slow
my $ip_site = "http://checkip.dyndns.com/";
### end user variables ###

#+-- initialize just in case
my $oldip = 0; 
my $wanip = 0;

#+-- check for current wan ip
sub current_ip {
	my $ip = get($ip_site) or 
		die flog("ERROR: Unable to retreive page!") && exit 1;
	if ($ip =~ /(\d{1,3}.\d{1,3}.\d{1,3}.\d{1,3})/) {
		$wanip = $1;
		if ($debug == 1) {
			print "WAN IP Adress: " , $wanip , "\n";
		}
	}
}

#+-- check for older, stored wan ip
sub stored_ip {
	open(STORIP, $ipfile) or 
		die flog("ERROR: Unable to open $ipfile!");
	chomp($oldip = <STORIP>);
	close(STORIP);
}

#+-- define logging
sub flog {
	open(FILE, ">>$logfile") or 
		die flog("ERROR: Unable to open: $logfile. $!") && exit 1;
	print FILE join(" ", my $timestamp = localtime , ":" , @_ ,"\n");
	close(FILE);
}

flog("====================");
current_ip();
flog("New WAN IP address: $wanip");
stored_ip();
flog("Old WAN IP address: $oldip");

if ( $wanip ne $oldip ) {
	flog("It appears that the WAN IP has changed!");

#TODO
#	Check response codes and dynamically create updated list
#	###703 707 707 704 701 200 201 702 705
#	###(20[01]|70[123457])
#	my @response_codes = get("http://www.zoneedit.com/doc/dynamic/ReturnCodes.txt");
#	foreach (@response_codes) {
#		chomp($_);
#		if($_ ne  "") {
#			flog("$_\n");
#		}
#	}


	#+-- connect to zoneedit and update ip
	my $ua = new LWP::UserAgent;
	$ua->agent('Mozilla/5.0 (compatible; Sexbot/1.0; +http://zoneedit.com)'); 
	$ua->credentials('dynamic.zoneedit.com:80', 'DNS Access', $user, $pass);
	#my $ip = get("http://dynamic.zoneedit.com/auth/dynamic.html?host=$zones") or 
	#	die flog("ERROR: Unable to update zones!") && exit 1:w;
	my $request = new HTTP::Request('GET', "http://dynamic.zoneedit.com/auth/dynamic.html?zones=$zones");
	my $response = $ua->request($request);	
	#+-- store http response for later use
	my $zeresponse = $response->content();
	chomp($zeresponse);
	flog($zeresponse);
	#+-- show the whole error
	if($response->is_success) {
		flog("Successfully updated WAN IP with ZoneEdit.");
		if($debug == 1) {
			flog($zeresponse);
		}
	} else {
		flog("ERROR: Unable to update WAN IP with ZoneEdit!");
		flog($zeresponse);
	}
	#+-- cleanup stored ip and/or change wan ip in file
	open(STORIP, ">$ipfile") or 
		die flog("ERROR: Unable to open $ipfile!") && exit 1;
	print STORIP $wanip , "\n";
	close(STORIP);
	flog("Stored new WAN IP $wanip to $ipfile");
} else {
	flog("WAN IP unchanged.  No update necessary.");
	exit 0
}
#EOF