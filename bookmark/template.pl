#!/usr/bin/perl

# Name: template.pl - Handles template functionality
#  Rev: 2
# Date: August 1, 2001
#   By: Andrew L. Ayers

require "common.pl";

sub template_load
{	
	# Load HTML template
	
	# Usage: $template = template_load($template)
	
	# param0 - template filename
	
	# return - template HTML data
	
	my (@valu) = @_;
	
	$tmpl_data = "";
	
	if ($valu[0] ne "")
	{
		open TMPL, "<" . $template_path . $valu[0];
		@template = <TMPL>;
		close TMPL;

		for ($i = 0; $i <= $#template; $i++)
		{
			$tmpl_data = $tmpl_data . $template[$i];
		}
	}
	
	return ($tmpl_data);
}

1;
