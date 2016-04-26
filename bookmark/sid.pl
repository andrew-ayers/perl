#!/usr/bin/perl

# Name: sid.pl - Handles session ID (sid) functionality
#  Rev: 2
# Date: February 5, 2003
#   By: Andrew L. Ayers

require "cgi-lib.pl";

require "common.pl";
require "db.pl";
require "html.pl";
require "error.pl";

sub sid_check
{
	my (@valu) = @_;	

	my $sid = $valu[0];

	# Check to see if SID ($sid) is:
	#
	# 	a) On the database
	#	b) Requesting IP same as last time
	#
	# If these criteria are met, return authorization level:
	#
	# 	g = guest
	#	u = user
	#	a = admin
	
	my @login_list = db_load($db_users);
	
	for ($i = 0; $i <= $#login_list; $i++)
	{
		my @test = split(/]/,$login_list[$i]);

		my $db_sid = $test[4];
		my $db_ip = substr($test[5],0,-1);
		
		if (($db_sid eq $sid) && ($db_ip eq $ENV{"REMOTE_ADDR"}))
		{
			# Set auth variable
			#  $auth = authorization level
			# For later use
		
			my $auth = $test[3];
			
			return($auth);
		}
	}
	
	return("");
}

sub sid_generate
{
	my (@valu) = @_;	

	my $user = $valu[0];
	my $pass = $valu[1];
	my $auth = $valu[2];

	# Build session ID (SID) from username/password
	
	my $sid = $user."_".time.".".rand;

	# Get user number based on login information
	
	my $unum = common_getusernum($user, $pass, $auth);
	
	# Build user update line
	
	my $line = $unum."]".$user."]".$pass."]".$auth."]".$sid."]".$ENV{"REMOTE_ADDR"};
	
	# Update DB with SID and IP for user
	
	if (db_update_line($db_users, $unum, $line) == 1)
	{
		return($sid);
	}
	
	return("");
}

sub sid_getunum
{
	my (@valu) = @_;	

	my $sid = $valu[0];

	# Check to see if SID ($sid) is:
	#
	# 	a) On the database
	#	b) Requesting IP same as last time
	#
	# If these criteria are met, return user number
	
	my @login_list = db_load($db_users);
	
	for ($i = 0; $i <= $#login_list; $i++)
	{
		my @test = split(/]/,$login_list[$i]);

		my $db_sid = $test[4];
		my $db_ip = substr($test[5],0,-1);
		
		if (($db_sid eq $sid) && ($db_ip eq $ENV{"REMOTE_ADDR"}))
		{
			my $unum = $test[0];
			
			return($unum);
		}
	}
	
	return("");
}

sub sid_getuser
{
	my (@valu) = @_;	

	my $sid = $valu[0];

	# Check to see if SID ($sid) is:
	#
	# 	a) On the database
	#	b) Requesting IP same as last time
	#
	# If these criteria are met, return user name
	
	my @login_list = db_load($db_users);
	
	for ($i = 0; $i <= $#login_list; $i++)
	{
		my @test = split(/]/,$login_list[$i]);

		my $db_sid = $test[4];
		my $db_ip = substr($test[5],0,-1);
		
		if (($db_sid eq $sid) && ($db_ip eq $ENV{"REMOTE_ADDR"}))
		{
			my $user = $test[1];
			
			return($user);
		}
	}
	
	return("");
}

sub sid_getpass
{
	my (@valu) = @_;	

	my $sid = $valu[0];

	# Check to see if SID ($sid) is:
	#
	# 	a) On the database
	#	b) Requesting IP same as last time
	#
	# If these criteria are met, return user password
	
	my @login_list = db_load($db_users);
	
	for ($i = 0; $i <= $#login_list; $i++)
	{
		my @test = split(/]/,$login_list[$i]);

		my $db_sid = $test[4];
		my $db_ip = substr($test[5],0,-1);
		
		if (($db_sid eq $sid) && ($db_ip eq $ENV{"REMOTE_ADDR"}))
		{
			my $pass = $test[2];
			
			return($pass);
		}
	}
	
	return("");
}

1;
