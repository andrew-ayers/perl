#!/usr/bin/perl

# Name: category.pl - Handles category functionality
#  Rev: 3
# Date: January 30, 2003
#   By: Andrew L. Ayers

require "cgi-lib.pl";

require "common.pl";
require "show.pl";
require "sid.pl";
require "db.pl";
require "html.pl";
require "error.pl";

sub category
{
	# Category display and update
	
	# Usage: category($session_ID)

	# $session_ID - param0 - session ID or null

	# Get common values based on parameters passed in via
	# arguments and form values, setting $sid, $op, and $auth
	
	common_getvalues(@_);
	
	# Get "other" values from form variables:
	#
	#  $snum = selected category number
	#  $ncat = new "added" category name
	#  $naut = new "added" category auth

	my $snum = $in{'theCat'};
	my $ncat = $in{'catname'};
	my $naut = $in{'catauth'};
	
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
		show_categories($auth, $sid);
		
		exit(1);
	}
	elsif ($op eq "update")
	{	
		if ($snum ne "")
		{
			# Show selected category to modify
		
			show_mcategory($auth, $sid, $snum);
		}
		else
		{
			error_show("category.pl", "Please select a category to update.", "");
		}
			
		exit(1);
	}
	elsif ($op eq "delete")
	{
		# Need to add code here to disallow delete if category
		# selected is still in use in the category tree table
		
		if ($snum ne "")
		{
			# Delete selected category
			
			db_delete_line($db_cats, $snum);
			
			# Re-build and show category list

			show_categories($auth, $sid);
		}
		else
		{
			error_show("category.pl", "Please select a category to delete.", "");
		}
		
		exit(1);
	}
	elsif ($op eq "add")
	{
		if ($snum ne "")
		{
			# Show new category to add
		
			show_acategory($auth, $sid, $snum);
		}
		else
		{
			error_show("category.pl", "Please select a category to add.", "");
		}
			
		exit(1);
	}
	elsif ($op eq " Update ")
	{
		# Update modified category
		
		# Need code here to disallow update if category has
		# assigned links
		
		# Evaluate auth word and re-assign

		$naut = common_evalword2flag($naut,"Administrator]Superuser]User]Guest","a]s]u]g","g");

		db_update_line($db_cats, $snum, $snum."]".$ncat."]".$naut);
		
		# Re-build and show category list

		show_categories($auth, $sid);
		
		exit(1);
	}
	elsif ($op eq " Add ")
	{
		# Add new category
				
		# Evaluate auth word and re-assign

		$naut = common_evalword2flag($naut,"Administrator]Superuser]User]Guest","a]s]u]g","g");

		# Verify category info
				
		if (category_verify($auth, $ncat) eq "1")
		{
			db_append_line($db_cats, $snum."]".$ncat."]".$naut);
		
			# Re-build and show category list

			show_categories($auth, $sid);
		}
	}
	else
	{
		# Invalid operation
		
		error_show("category.pl", $err_INVALID_OP, "[".$op."]");
		
		exit(1);
	}
}

sub category_verify
{
	my (@valu) = @_;
	
	my $auth = $valu[0];
	my $ncat = $valu[1];
	
	# ncat must be set to something
	
	if ($ncat eq "")
	{
		error_show("category.pl", "Category name MUST be set.", "");
		
		return(0);
	}
	
	# Category must be unique in table

	return(1);
}

category;

1;
