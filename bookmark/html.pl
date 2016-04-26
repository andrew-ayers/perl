#!/usr/bin/perl

# Name: html.pl - Handles html page building functionality
#  Rev: 2
# Date: October 2, 2001
#   By: Andrew L. Ayers

require "common.pl";
require "template.pl";

sub html_clear
{
	# Clear cookie header, standard header, page
	# and footer variables

	# Usage: html_clear();
		
	$html_head = "";
	$html_page = "";
	$html_foot = "";
}

sub html_header
{
	# Build html page header, optionally setting cookie
	
	# Usage: html_header();
        
	$html_head = "Content-type: text/html\n\n";	
	$html_head = $html_head . "<html>\n";
	$html_head = $html_head . template_load("header.htmt");
}

sub html_footer
{
	# Build html page footer
	
	# Usage: html_footer();
	
	$html_foot = template_load("footer.htmt");
	$html_foot = $html_foot . "</html>\n";
}

sub html_line
{
	# Append passed in line to page data
	
	# Usage: html_line($line);

	# $line - param0 - html data line
		
	my (@valu) = @_;
		
	$html_page = $html_page . $valu[0];
}

sub html_show
{
	# Build and show html page
	
	# Usage: html_show();
	
	if ($html_head ne "") {print $html_head;}
	if ($html_page ne "") {print $html_page;}
	if ($html_foot ne "") {print $html_foot;}
}

1;
