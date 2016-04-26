#!/usr/bin/perl

# Name: search.pl - Handles search functionality
#  Rev: 1
# Date: February 26, 2003
#   By: Andrew L. Ayers

require "cgi-lib.pl";

require "common.pl";
require "show.pl";
require "sid.pl";
require "db.pl";
require "html.pl";
require "error.pl";

sub search
{
	# Search display
	
	# Usage: search($session_ID)

	# $session_ID - param0 - session ID or null

	# Get common values based on parameters passed in via
	# arguments and form values, setting $sid, $op, and $auth
	
	common_getvalues(@_);
	
	# Get "other" values from form variables:
	#
	#  $cat# = selected link category (1-3)
	#  $opr# = selected operator (AND, OR, NOT) (1-2)

	my $cat1 = $in{'catlst1'};
	my $opr1 = $in{'oplist1'};
	my $cat2 = $in{'catlst2'};
	my $opr2 = $in{'oplist2'};
	my $cat3 = $in{'catlst3'};
	
	# Check to see if user is an administrator

	if ($auth ne "a" && $auth ne "s")
	{
		# Invalid session ID, show login page with error message
	
		#show_ilogin();
		
		#exit(1);
	}
	
        # Main

	if ($op eq "search")
	{
		show_search($auth, $sid, $cat1, $opr1, $cat2, $opr2, $cat3);
		
		exit(1);
	}
	else
	{
		# Invalid operation
		
		error_show("search.pl", $err_INVALID_OP, "[".$op."]");
		
		exit(1);
	}
}

search;

1;
