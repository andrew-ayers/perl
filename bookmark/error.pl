#!/usr/bin/perl

# Name: error.pl - Handles errors
#  Rev: 2
# Date: October 3, 2001
#   By: Andrew L. Ayers

require "common.pl";
require "html.pl";

sub error_show
{
	# Builds and prints an HTML error display page
	
	# Usage: error_show($module, $description, $extra)

	# $module      - param0 - module name which threw error
	# $description - param1 - error description
	# $extra       - param2 - error extra (optional)
	
	my (@valu) = @_;
	
	html_clear();
	html_header();
	html_line("<b>Error:</b> " . $valu[0] . " - " . $valu[1] . " " . $valu[2] . "<p>");
	html_footer();
	html_show();
}

1;
