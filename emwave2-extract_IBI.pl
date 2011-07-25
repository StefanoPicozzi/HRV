#!/usr/bin/perl
#
#


# emwave2-extract_IBI.pl
#
# Created by Stefano Picozzi on 2011-07-25.
# Copyright (c) 2011 emergitect.com All rights reserved.
# 

if (length($ARGV[0]) > 0) {
	$InFile = $ARGV[0];
} else {
	$InFile = "session.json";
}

open (InFile, $InFile);

$i = 1;
$skip = -1;
$foundIBI = -1;
while (<InFile>) {

	chomp;
	$str = $_;

	$LeftSquareBracket = index($str, "[", 0);
	$RightSquareBracket = index($str, "]", 0);
	$LeftCurlyBracket = index($str, "{", 0);
	$RightCurlyBracket = index($str, "}", 0);

	$LiveIBI = index($str, "LiveIBI", 0);
	$IBIEndTime = index($str, "IBIEndTime", 0);
	$IBIStartTime = index($str, "IBIStartTime", 0);

	if ($LeftSquareBracket == 0) {
		next;
	}

	if ($RightSquareBracket == 0) {
		break;
	}

	if ($LeftCurlyBracket != -1) {
		next;
	}

	if ($IBIEndTime != -1) {
		$colon = index($str, ":", 0);
		$time = substr($str, $colon+2, length($str) - $colon);
		$endTime = gmtime($time);
		($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = gmtime($time);
		$year += 1900;
		$mon = zeroPad($mon);
		$mday =	zeroPad($mday);
		$sec = zeroPad($sec);
		$min = zeroPad($min);
		$hour = zeroPad($hour);
		print "Extracting IBI from $year/$mon/$mday $hour:$min:$sec to ";
		$end = "$hour$min$sec";
	}

	if ($IBIStartTime != -1) {
		$colon = index($str, ":", 0);
		$time = substr($str, $colon+2, length($str) - $colon);
		$startTime = gmtime($time);
		($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = gmtime($time);
		$year += 1900;
		$mon = zeroPad($mon);
		$mday =	zeroPad($mday);
		$sec = zeroPad($sec);
		$min = zeroPad($min);
		$hour = zeroPad($hour);
		print "$year/$mon/$mday $hour:$min:$sec\n";
		$start = "$year$mon$mday $hour$min$sec"; 
	}

	if ($LiveIBI != -1) {
		if ($foundIBI != 1) {
			$RRFile = "IBI $start-$end.dat";
			open (RRFile, ">", $RRFile);
		}
		$foundIBI = 1;
		next;
	}
		
	if ($foundIBI == 1) {
		if ($RightSquareBracket != -1) {
			$foundIBI = -1;
			close(RRFile);
			next;
		}
		if (index($str, ",", 0) != -1) {
			$strip = substr($str, 0, length($str)-1);
		} else {
			$strip = substr($str, 0, length($str));		
		}
		print RRFile "$strip\n";
	}
	
}

close(InFile);

sub zeroPad {
	my $in = $_[0];
	$l = length($in);
	if ($l < 2) {
		return "0$in";
	}
	return $in;
}