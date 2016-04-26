#!/usr/bin/perl

# Name: db.pl - Database operation functionality
#  Rev: 2
# Date: October 26, 2001
#   By: Andrew L. Ayers

require "common.pl";

sub db_load
{	
	# Load and return array of database lines
	
	# Usage: @array = db_load($filepath)
	
	# param0 - file path to database file
	
	# return - array of lines
	
	my (@valu) = @_;
	
	my $db_name = $valu[0];
	
	open DB, "<" . $db_name;
	
	my @db_list = <DB>;
	
	close DB;
	
	return(@db_list);
}

sub db_update_line
{
	# Update a line in a database
	
	# Usage: db_update_line($db_name, $key, $line)
	
	# $db_name - param0 - file path to database file
	# $key - param1 - key for row to update
	# $line - param2 - line to update row with
	
	# return - 1=completed OK, 0=failed
	
	my (@valu) = @_;
	
	my $db_name = $valu[0];
	my $key = $valu[1];
	my $line = $valu[2];
	my $found = 0;
	
	if ($db_name eq $db_users || $db_name eq $db_cats || $db_name eq $db_lnks)
	{
		# Read DB file into an array
		
		open DB, "<" . $db_name;
	
		my @db_list = <DB>;
	
		close DB;

		# Find line based on unique "key", and update line
		
		for ($i = 0; $i <= $#db_list; $i++)
		{	
			my @test_key = split(/]/, $db_list[$i]);
			
			if ($key eq $test_key[0])
			{
				$db_list[$i] = $line."\n";
				$found = 1;
				last;
			}
		}
		
		# Write array back to DB file
		
		open DB, ">" . $db_name;#."test";
		
		flock(DB, 2);
		
		for ($i = 0; $i <= $#db_list; $i++)
		{	
			print DB $db_list[$i]; 
		}
		
		close DB;
		
		return($found);
	}
	
	return($found);
}

sub db_update_field
{
	# Update a field in a database
	
	# Usage: db_update_field($db_name, $key, $field, $info)
	
	# $db_name - param0 - file path to database file
	# $key - param1 - key for row to update
	# $field - param2 - field number of row to update
	# $info - param3 - value to update field with
	
	# return - 1=completed OK, 0=failed
	
	my (@valu) = @_;
	
	my $db_name = $valu[0];
	my $key = $valu[1];
	my $field = $valu[2];
	my $info = $valu[3];
	my $found = 0;
	
	if ($db_name eq $db_users)
	{
		# Read DB file into an array
		
		open DB, "<" . $db_name;
	
		my @db_list = <DB>;
	
		close DB;

		# Find line based on unique "key"
		
		for ($i = 0; $i <= $#db_list; $i++)
		{	
			my @test_key = split(/]/, $db_list[$i]);
			
			if ($key eq $test_key[0])
			{
				# Update field in line
				
				$test_key[$field] = $info;
				
				# Build replacement line with fields
				
				$db_list[$i] = $test_key[0];
				
				for ($ii = 1; $ii <= $#test_key; $ii++)
				{
					$db_list[$i] = $db_list[$i]."]".$test_key[$ii];
				}
				
				$db_list[$i] = $db_list[$i]."\n";
				$found = 1;
				last;
			}
		}
		
		# Write array back to DB file
		
		open DB, ">" . $db_name;#."test";
		
		flock(DB, 2);
		
		for ($i = 0; $i <= $#db_list; $i++)
		{	
			print DB $db_list[$i]; 
		}
		
		close DB;
		
		return($found);
	}
	
	return($found);
}

sub db_append_line
{
	# Append a line in a database
	
	# Usage: db_append_line($db_name, $line)
	
	# $db_name - param0 - file path to database file
	# $line - param1 - new line to add
	
	# return - 1=completed OK, 0=failed
	
	my (@valu) = @_;
	
	my $db_name = $valu[0];
	my $line = $valu[1];
	
	if ($db_name eq $db_users || $db_name eq $db_cats || $db_name eq $db_lnks)
	{
		# Add new line to DB file
		
		open DB, ">>" . $db_name;#."test";
		
		flock(DB, 2);
		
		print DB $line."\n";
		
		close DB;
		
		return(1);
	}
	
	return(0);
}

sub db_delete_line
{
	# Delete a line in a database
	
	# Usage: db_delete_line($db_name, $key)
	
	# $db_name - param0 - file path to database file
	# $key - param1 - key for row to delete
	
	# return - 1=completed OK, 0=failed
	
	my (@valu) = @_;
	
	my $db_name = $valu[0];
	my $key = $valu[1];
	my $found = 0;
	
	if ($db_name eq $db_users || $db_name eq $db_cats || $db_name eq $db_lnks)
	{
		# Read DB file into an array
		
		open DB, "<" . $db_name;
	
		my @db_list = <DB>;
	
		close DB;

		# Find line based on unique "key", and mark it
		
		for ($i = 0; $i <= $#db_list; $i++)
		{	
			my @test_key = split(/]/, $db_list[$i]);
			
			if ($key eq $test_key[0])
			{
				$db_list[$i] = "\n";
				$found = 1;
				last;
			}
		}
		
		# Write array back to DB file, skipping marked line
		
		open DB, ">" . $db_name;#."test";
		
		flock(DB, 2);
		
		for ($i = 0; $i <= $#db_list; $i++)
		{	
			if ($db_list[$i] ne "\n")
			{
				print DB $db_list[$i]; 
			}
		}
		
		close DB;
		
		return($found);
	}
	
	return($found);
}

sub db_get_field
{
	# Return the value of a field on a line in a database
	
	# Usage: db_get_field($db_name, $key, $field)
	
	# $db_name - param0 - file path to database file
	# $key - param1 - key for row to find field in
	# $field - param2 - number of field to return value of	
	
	# return - 1=completed OK, 0=failed
	
	my (@valu) = @_;
	
	my $db_name = $valu[0];
	my $key = $valu[1];
	my $field = $valu[2];
	
	return(0);
}

1;
