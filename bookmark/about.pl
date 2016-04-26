#!/usr/bin/perl

# Name: about.pl - Handles "about" functionality
#  Rev: 1
# Date: November 15, 2001
#   By: Andrew L. Ayers

require "cgi-lib.pl";

require "common.pl";
require "show.pl";
require "sid.pl";
require "db.pl";
require "html.pl";
require "error.pl";

sub about
{
	# About display
	
	# Usage: about($session_ID)

	# $session_ID - param0 - session ID or null

	# Get common values based on parameters passed in via
	# arguments and form values, setting $sid, $op, and $auth
	
	common_getvalues(@_);
	
        # Main

	if ($op eq "show")
	{	
		if ($auth eq "a" || $auth eq "s" || $auth eq "u" || $auth eq "g")
		{
			# It is valid, so display main page based on auth level

			show_about($auth, $sid);
		
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
		
		error_show("about.pl", $err_INVALID_OP, "[".$op."]");
		
		exit(1);
	}
}

about;

1;
