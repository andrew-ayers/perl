#!/usr/bin/perl

# Name: links.pl - Handles link functionality
#  Rev: 1
# Date: February 7, 2003
#   By: Andrew L. Ayers

require "cgi-lib.pl";

require "common.pl";
require "show.pl";
require "sid.pl";
require "db.pl";
require "html.pl";
require "error.pl";

sub links
{
	# Link display and update
	
	# Usage: links($session_ID)

	# $session_ID - param0 - session ID or null

	# Get common values based on parameters passed in via
	# arguments and form values, setting $sid, $op, and $auth
	
	common_getvalues(@_);
	
	# Get "other" values from form variables:
	#
	#  $snum = selected link number
	#  $scat = selected category name
	#  $nnam = new "added" link name
	#  $ndsc = new "added" link description
	#  $nlnk = new "added" link url
	#  $nct# = new "added" link category (1-5)
	#  $naut = new "added" link auth
	#  $nrat = new "added" link rating

	my $snum = $in{'theLnk'};
	my $scat = $in{'theCat'};
	my $nnam = $in{'lnkname'};
	my $ndsc = $in{'lnkdesc'};
	my $nlnk = $in{'lnklink'};
	my $nct1 = $in{'catlst1'};
	my $nct2 = $in{'catlst2'};
	my $nct3 = $in{'catlst3'};
	my $nct4 = $in{'catlst4'};
	my $nct5 = $in{'catlst5'};
	my $naut = $in{'lnkauth'};
	my $nrat = $in{'lnkrate'};
	
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
		show_links($auth, $sid, $scat);
		
		exit(1);
	}
	elsif ($op eq "update")
	{	
		if ($snum ne "")
		{
			# Show selected link to modify
		
			show_mlink($auth, $sid, $snum, $scat);
		}
		else
		{
			error_show("links.pl", "Please select a link to update.", "");
		}
			
		exit(1);
	}
	elsif ($op eq "delete")
	{
		if ($snum ne "")
		{
			# Delete selected link
			
			db_delete_line($db_lnks, $snum);
			
			# Re-build and show link list

			show_links($auth, $sid, $scat);
		}
		else
		{
			error_show("links.pl", "Please select a link to delete.", "");
		}
		
		exit(1);
	}
	elsif ($op eq "add")
	{
		if ($snum ne "")
		{
			# Show new link to add
		
			show_alink($auth, $sid, $snum, $scat);
		}
		else
		{
			error_show("links.pl", "Please select a link to add.", "");
		}
			
		exit(1);
	}
	elsif ($op eq " Update ")
	{
		# Update modified link
		
		# Evaluate auth word and re-assign

		$naut = common_evalword2flag($naut,"Administrator]Superuser]User]Guest","a]s]u]g","g");

		# Verify link info
				
		if (links_verify($nnam, $nlnk, $naut) eq "1")
		{
			my $link_entry = $snum."]".$nnam."]".$ndsc."]".$nlnk."]";
			
			$link_entry = $link_entry.$nct1."|";
			$link_entry = $link_entry.$nct2."|";
			$link_entry = $link_entry.$nct3."|";
			$link_entry = $link_entry.$nct4."|";
			$link_entry = $link_entry.$nct5."]";
		
			$link_entry = $link_entry.$naut."]".$nrat;
		
			db_update_line($db_lnks, $snum, $link_entry);

			# Re-build and show link list

			show_links($auth, $sid, $scat);
		}
		
		exit(1);
	}
	elsif ($op eq " Add ")
	{
		# Add new link
				
		# Evaluate auth word and re-assign

		$naut = common_evalword2flag($naut,"Administrator]Superuser]User]Guest","a]s]u]g","g");

		# Verify link info
				
		if (links_verify($nnam, $nlnk, $naut) eq "1")
		{
			my $link_entry = $snum."]".$nnam."]".$ndsc."]".$nlnk."]";
			
			$link_entry = $link_entry.$nct1."|";
			$link_entry = $link_entry.$nct2."|";
			$link_entry = $link_entry.$nct3."|";
			$link_entry = $link_entry.$nct4."|";
			$link_entry = $link_entry.$nct5."]";
		
			$link_entry = $link_entry.$naut."]".$nrat;
		
			db_append_line($db_lnks, $link_entry);

			# Re-build and show link list

			show_links($auth, $sid, $scat);
		}
	}
	else
	{
		# Invalid operation
		
		error_show("links.pl", $err_INVALID_OP, "[".$op."]");
		
		exit(1);
	}
}

sub links_verify
{
	my (@valu) = @_;
	
	my $nname = $valu[0];
	my $nlink = $valu[1];
	my $nauth = $valu[2];
	
	# nname, nlink, and nauth must be set to something
	
	if ($nname eq "" || $nlink eq "" || $nauth eq "")
	{
		error_show("links.pl", "Link name, url and authorization MUST be set.", "");
		
		return(0);
	}

	return(1);
}

links;

1;
