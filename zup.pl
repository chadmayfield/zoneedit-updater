#!/usr/bin/perl

# zup - update your zoneedit ip with the detected wan ip address of
# the host machine.  specifically for dynamic dns users. should be
# run from a cronjob for best results.
#
# Chad R Mayfield (http://www.chadmayfield.com/) July 2009 GPLv3

use strict;
use warnings;

use LWP::UserAgent;
use LWP::Simple;

########## start user variables ##########
my $debug = "0"; # not heavily implemented yet
my $user = "username";
my $pass = "password";
my $zones = "first.domain.com,second.domain.com"; #seperate with comma
my $logfile = "/tmp/ip.log";
my $ipfile = "/tmp/ip.txt";
#my $ip_site = "http://dynamic.zoneedit.com/checkip.html"; #kinda slow
my $ip_site = "http://checkip.dyndns.com/";
########## end user variables ##########

#+-- initialize just in case (our, for bug fix on mac)
our $oldip = 0; 
my $wanip = 0;
my $failed = 0;

#+-- define logging function
sub flog {
	open(FILE, ">>$logfile") or
		die flog("ERROR: Unable to open: $logfile. $!") && exit 1;
	print FILE join(" ", my $timestamp = localtime , ":" , @_ ,"\n");
	close(FILE);
}

flog("===================="); #+-- instance seperator for logfile

if (! -e $ipfile ) {
	flog("ERROR: File does not exist: $ipfile");
	exit(1);
}

if (( ! -w $ipfile ) || ( ! -r $ipfile )) {
	flog("ERROR: File is not read/writable: $ipfile");
	exit(1);
}

#+-- check for current wan ip
sub current_ip {
	my $ip = get($ip_site) or 
		die flog("ERROR: Unable to retreive page!") && exit 1;
	if ($ip =~ /(\d{1,3}.\d{1,3}.\d{1,3}.\d{1,3})/) {
		$wanip = $1;
	}
}

#+-- check for older, stored wan ip
sub stored_ip {
	open(STORIP, $ipfile) or 
		die flog("ERROR: Unable to open $ipfile!");
	chomp($oldip = <STORIP>);
	close(STORIP);
}

current_ip();
flog("New WAN IP address: " . $wanip);
stored_ip();
flog("Old WAN IP address: " . $oldip);

if ( $wanip ne $oldip ) {
	flog("It appears that the WAN IP has changed!");

	#+-- connect to zoneedit and update ip
	my $ua = new LWP::UserAgent;
	$ua->agent('Mozilla/5.0 (compatible; Sexbot/1.0; +http://zoneedit.com)'); 
	$ua->credentials('dynamic.zoneedit.com:80', 'DNS Access', $user, $pass);
	my $request = new HTTP::Request('GET', "http://dynamic.zoneedit.com/auth/dynamic.html?zones=$zones");
	my $response = $ua->request($request);	
	
	#+-- store http response for later use
	my $zeresponse = $response->content();
	chomp($zeresponse);

	#+-- print the unformmated http response
	if($debug == 1) {
		flog($zeresponse);
	}

	flog("~~~~~");

	my @sresponse = split(/</, $zeresponse);
	shift @sresponse;
	my $sresponse;

	foreach $sresponse (@sresponse) {
		if ($debug == 1) {
			flog($sresponse);
		}	
		my @fresponse = split(/"/, $sresponse);
		my $fresponse; 
		my $e = 0; #start an array element counter
		
		foreach $fresponse (@fresponse) {
			if ($e =~ m/[1357]/) {
				flog($fresponse[$e]);
			}
			$e = $e + 1;
		}
	}

	flog("~~~~~");

	#+-- if debugging, show the whole http::request unformatter
	if($response->is_success) {
		flog("Successfully updated WAN IP with ZoneEdit.");
	} else {
		flog("ERROR: Unable to update WAN IP with ZoneEdit!");
		$failed = 1; # set fail since we will not want to update the storedip
	}

	#+-- cleanup stored ip and/or change wan ip in file
	if($failed != 1) {
		open(STORIP, ">$ipfile") or 
			die flog("ERROR: Unable to open $ipfile!") && exit 1;
		print STORIP $wanip , "\n";
		close(STORIP);
		flog("Stored new WAN IP $wanip to $ipfile");
	}
} else {
	flog("WAN IP unchanged.  No update necessary.");
	exit 0
}
#EOF
