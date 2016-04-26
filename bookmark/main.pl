#!/usr/bin/perl

# Name: main.pl - Handles main functionality
#  Rev: 2
# Date: November 7, 2001
#   By: Andrew L. Ayers

require "cgi-lib.pl";

require "common.pl";
require "show.pl";
require "sid.pl";
require "db.pl";
require "html.pl";
require "error.pl";

sub main
{
	# System Main Page
	
	# Usage: main($session_ID)

	# $session_ID - param0 - session ID or null

	# Get common values based on parameters passed in via
	# arguments and form values, setting $sid, $op, and $auth
	
	common_getvalues(@_);
	
	if ($op eq "show")
	{
		if ($auth ne "")
		{
			# It is valid, so display main page based on auth level

			show_main($auth, $sid);
		
			exit(1);
		}
		else
		{
			# Invalid session ID, show login page with error message
		
			show_ilogin();
	
			exit(1);
		}
	}
 	else
	{
		# Invalid operation
		
		error_show("main.pl", $err_INVALID_OP, "[".$op."]");
		
		exit(1);
	}	
}

main;

1;
