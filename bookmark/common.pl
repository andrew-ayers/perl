#!/usr/bin/perl

# Name: common.pl - Global "constants" for system
#  Rev: 3
# Date: February 5, 2003
#   By: Andrew L. Ayers

require "cgi-lib.pl";

##################
# System Globals #
##################

$bm_path  = "./";				# Path to BOOKmark system

####################
# Database Globals #
####################

$db_path  = "./datafiles/";  			# Path (relative or absolute)
						# to DB files						
$db_users = $db_path . "users.txt";   		# User DB filename
$db_cats  = $db_path . "categories.txt";	# Category DB filename
$db_lnks  = $db_path . "links.txt";		# Links DB filename

####################
# Template Globals #
####################

$template_path = "./templates/"; 	 	# Path (relative or absolute)
						# to html templates
						
####################
# Graphics Globals #
####################

$bkg_path = "./graphics/bg.jpg";
$rat_path = "./graphics/star.gif";

#########################################
# Error Message Globals - DO NOT MODIFY #
#########################################

$err_INVALID_OP = "Invalid Operation";		# Defines Invalid Operation
$err_EXCEPTION  = "Unexpected Exception"; 	# Defines Unexpected Exception
$err_INVALID_AUTH = "Invalid Authorization";	# Defines Invalid Authorization

########################################
# Boolean flag globals - DO NOT MODIFY #
########################################
 
$bTRUE = -1;					# Defines TRUE
$bFALSE = 0;					# Defines FALSE

############################
# TAB Indent global (fake) #
############################

$tab_INDENT = "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;"; # Fakie TAB indent for HTML

################################

sub common_getvalues
{
	# Retrieve common values - first from parameters
	
	my (@valu) = @_;
	
	$session_id = $valu[0];

	# Then, read common values from the form (if they exist)

	&ReadParse;

	# Get variables:
	#
	#  $op = operation to act on
	#  $sid = session ID
	
	$op = $in{'op'};
	$sid = $in{'sid'};

	# Form variable session ID has precedence over argument SID
	
	if ($session_id ne "")
	{
		$sid = $session_id;
	}
	
	# Check to see if SID is on DB, and requesting IP
	# is still the same - if so, set auth level, else $auth=""
	
	$auth = sid_check($sid);	
}

sub common_striplf
{
	# Retrieve parameters
	
	my (@valu) = @_;
	
	return (substr $valu[0],0,(length $valu[0])-1);	
}

sub common_evalflag2word
{
	# Retrieve parameters
	
	my (@valu) = @_;
	
	my $flag_id = $valu[0];
	my @flag_list = split(/]/,$valu[1]);
	my @flag_words = split(/]/,$valu[2]);
	my $flag_default = $valu[3];
	my $test_word = "";

	for (my $i = 0; $i <= $#flag_list; $i++)
	{
		my $test_flag = $flag_list[$i];
		
		if ($test_flag eq $flag_id)
		{
			$test_word = $flag_words[$i];
			
			last;
		}
	}

	if ($test_word eq "")
	{
		$test_word = $flag_default;
	}
	
	return($test_word);
}

sub common_evalword2flag
{
	# Retrieve parameters
	
	my (@valu) = @_;
	
	my $word_id = $valu[0];
	my @word_list = split(/]/,$valu[1]);
	my @word_flags = split(/]/,$valu[2]);
	my $word_default = $valu[3];
	my $test_flag = "";

	for (my $i = 0; $i <= $#word_list; $i++)
	{
		my $test_word = $word_list[$i];
		
		if ($test_word eq $word_id)
		{
			$test_flag = $word_flags[$i];
			
			last;
		}
	}

	if ($test_flag eq "")
	{
		$test_flag = $word_default;
	}
	
	return($test_flag);
}

sub common_getusernum
{
	my (@valu) = @_;	

	my $uname = $valu[0];
	my $upass = $valu[1];
	my $uauth = $valu[2];

	# Check to see if user name ($uname), password ($upass), and
	# authorization ($uauth) is on the database.
	#
	# If these criteria are met, return user number
	
	my @login_list = db_load($db_users);
	
	for ($i = 0; $i <= $#login_list; $i++)
	{
		my @test = split(/]/,$login_list[$i]);

		my $db_nam = $test[1];
		my $db_pwd = $test[2];
		my $db_aut = $test[3];
		
		if (($db_nam eq $uname) && ($db_pwd eq $upass) && ($db_aut eq $uauth))
		{
			my $unum = $test[0];
			
			return($unum);
		}
	}
	
	return("");
}

1;
