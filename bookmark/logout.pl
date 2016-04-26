#!/usr/bin/perl

# Name: logout.pl - Handles logout functionality
#  Rev: 1
# Date: October 3, 2001
#   By: Andrew L. Ayers

require "cgi-lib.pl";

require "common.pl";
require "show.pl";
require "sid.pl";
require "db.pl";
require "html.pl";
require "error.pl";

sub logout
{
	# Get session ID passed in as a parameter
	
	my (@valu) = @_;
	
	my $session_id = $valu[0];

	# System Logout Page
	
	# Usage: logout($session_ID)

	# $session_ID - param0 - session ID or null
	
	# First, read values from form (if they exist)

	&ReadParse;

	# Get form variables:
	#
	#  $sid = session ID
	
	my $sid = $in{'sid'};

	# Logout
	
	if ($session_id eq "")
	{
		if ($sid eq "")
		{
			# Invalid session ID, exception!!!
	
			error_show("logout.pl", $err_EXCEPTION, "[No SID passed]");

			exit(1);
		}
	}
	else
	{
		$sid = $session_id;
	}
	
	# Check to see if SID is on DB and requesting IP
	# is still the same
	
	my $auth = sid_check($sid);
	
	if ($auth ne "")
	{
		# It is valid, so clear session ID ($sid)
		# and IP on DB
		
		my $unum = sid_getunum($sid);
		my $user = sid_getuser($sid);
		my $pass = sid_getpass($sid);

 		my $line = $unum."]".$user."]".$pass."]".$auth."]]";
	
		# Update DB with SID and IP for user
	
		if (db_update_line($db_users, $unum, $line) == 1)
		{
			show_logout($user);
			
			exit(1);
		}
	
		# Exception!!!

		error_show("logout.pl", $err_EXCEPTION, "[Invalid DB Update]");
	}
	else
	{
		# Invalid session ID, exception!!!

		error_show("logout.pl", $err_EXCEPTION, "[No SID found]");
	}
	
	exit(1);
}

logout;

1;
