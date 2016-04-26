#!/usr/bin/perl

# Name: login.pl - Handles login functionality
#  Rev: 3
# Date: February 5, 2003
#   By: Andrew L. Ayers

require "cgi-lib.pl";

require "common.pl";
require "show.pl";
require "sid.pl";
require "db.pl";
require "html.pl";
require "error.pl";

sub login
{
	# System Login Main Page
	
	# Usage: login($session_ID)

	# $session_ID - param0 - session ID or null
	
	# Get common values based on parameters passed in via
	# arguments and form values, setting $sid, $op, and $auth
	
	common_getvalues(@_);
	
	# Get "other" values from form variables:
	#
	#  $user = user name
	#  $pass = password
	
	my $user = $in{'user'};
	my $pass = $in{'pass'};

	# Check operation for sequence to take
	
	if ($op eq "")
	{
		# Login

		show_login();

		exit(1);
	}
	elsif ($op eq "verify")
	{
		# Verify username and password entered against DB
		# If valid, get authorization level
		
		my $auth = "";

		my @login_list = db_load($db_users);

		# Use entered username/password values to find
		# find user and privileges
	
		for ($i = 0; $i <= $#login_list; $i++)
		{
			my @test = split(/]/,$login_list[$i]);

		 	if (($user eq $test[1]) && ($pass eq $test[2]))		
			{
				$auth = $test[3];
				last;
			}
		}
		
		if ($auth ne "")
		{
			# Valid login returned, so generate new SID
			
			my $sid = sid_generate($user, $pass, $auth);
			
			if ($sid ne "")
			{
				# Call main with new SID
				
				show_main($auth, $sid);
			
				exit(1);
			}
		}

		# Invalid session ID, show login page with error message
			
		show_ilogin();

		exit(1);
	}
 	else
	{
		# Invalid operation
		
		error_show("login.pl", $err_INVALID_OP, "[".$op."]");
		
		exit(1);
	}
}

login;

1;
