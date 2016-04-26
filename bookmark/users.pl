#!/usr/bin/perl

# Name: users.pl - Handles user functionality
#  Rev: 1
# Date: February 5, 2003
#   By: Andrew L. Ayers

require "cgi-lib.pl";

require "common.pl";
require "show.pl";
require "sid.pl";
require "db.pl";
require "html.pl";
require "error.pl";

sub users
{
	# User display and update
	
	# Usage: users($session_ID)

	# $session_ID - param0 - session ID or null

	# Get common values based on parameters passed in via
	# arguments and form values, setting $sid, $op, and $auth
	
	common_getvalues(@_);
	
	# Get "other" values from form variables:
	#
	#  $snum = selected user number
	#  $nusr = new "added" user name
	#  $npwd = new "added" user password
	#  $naut = new "added" user auth

	my $snum = $in{'theUsr'};
	my $nusr = $in{'usrname'};
	my $npwd = $in{'usrpass'};
	my $naut = $in{'usrauth'};
	
	# Check to see if user is an administrator

	if ($auth ne "a" && $auth ne "s")
	{
		# Invalid session ID, show login page with error message
	
		show_ilogin();
		
		exit(1);
	}
	
        # Main

	if ($op eq "show" || $op eq " Cancel ")
	{
		show_users($auth, $sid);
		
		exit(1);
	}
	elsif ($op eq "update")
	{	
		if ($snum ne "")
		{
			# Show selected user to modify
		
			show_muser($auth, $sid, $snum);
		}
		else
		{
			error_show("users.pl", "Please select a user to update.", "");
		}
			
		exit(1);
	}
	elsif ($op eq "delete")
	{
		my @user_list = db_load($db_users);
	
		for ($i = 0; $i <= $#user_list; $i++)
		{
			my @test = split(/]/,$user_list[$i]);

			my $db_unum = $test[0];
			my $db_user = $test[1];
			my $db_pass = $test[2];
			my $db_auth = $test[3];
			my $db_sid = $test[4];
	
			if ($db_user eq $suser && $db_sid eq $sid)
			{
				error_show("users.pl", "Cannot delete yourself.", "");
			
				exit(1);
			}
		}

		if ($snum ne "")
		{
			# Delete selected category
			
			db_delete_line($db_users, $snum);
			
			# Re-build and show user list

			show_users($auth, $sid);
		}
		else
		{
			error_show("users.pl", "Please select a user to delete.", "");
		}
		
		exit(1);
	}
	elsif ($op eq "add")
	{
		if ($snum ne "")
		{
			# Show new user to add
		
			show_auser($auth, $sid, $snum);
		}
		else
		{
			error_show("users.pl", "Please select a user to add.", "");
		}
			
		exit(1);
	}
	elsif ($op eq " Update ")
	{
		# Update modified user
		
		# Evaluate auth word and re-assign

		$naut = common_evalword2flag($naut,"Administrator]Superuser]User]Guest","a]s]u]g","g");

		# Verify username and password info
				
		if (users_verify($auth, $suser, $nusr, $npwd, $naut) eq "1")
		{
			db_update_line($db_users, $snum, $snum."]".$nusr."]".$npwd."]".$naut."]]");

			# Re-build and show user list

			show_users($auth, $sid);
		}
		
		exit(1);
	}
	elsif ($op eq " Add ")
	{
		# Add new user
				
		# Evaluate auth word and re-assign

		$naut = common_evalword2flag($naut,"Administrator]Superuser]User]Guest","a]s]u]g","g");

		# Verify username and password info
				
		if (users_verify($auth, $suser, $nusr, $npwd, $naut) eq "1")
		{
			db_append_line($db_users, $snum."]".$nusr."]".$npwd."]".$naut."]]");
		
			# Re-build and show user list

			show_users($auth, $sid);
		}
	}
	else
	{
		# Invalid operation
		
		error_show("users.pl", $err_INVALID_OP, "[".$op."]");
		
		exit(1);
	}
}

sub users_verify
{
	my (@valu) = @_;
	
	my $auth = $valu[0];
	my $suser = $valu[1];
	my $nuser = $valu[2];
	my $npass = $valu[3];
	my $nauth = $valu[4];
	
	# need to verify here that username is not already in use
	
	# nuser and npass must be set to something
	
	if ($nuser eq "" || $npass eq "")
	{
		error_show("users.pl", "Username and password MUST be set.", "");
		
		return(0);
	}

	# a superuser cannot update an administrator
	
	if ($auth eq "s" && $nauth eq "a")
	{
		error_show("users.pl", "Superusers CANNOT update Administrators.", "");
		
		return(0);
	}

	return(1);
}

users;

1;
