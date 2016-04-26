#!/usr/bin/perl

#
# tnmake by Andrew L. Ayers
# 

my $tnsize=128;    # size of thumbnails
my $tnqual=50; # quality of thumbnails [0..100]

# possible image extensions (jpg, gif)
my @pics = (<*.jpg>,<*.JPG>,<*.gif>,<*.GIF>);

print "tnmake by Andrew L. Ayers\n";

# create a directory for the thumbnails
system ("mkdir tn") if (!-d "tn");

foreach $_ (sort @pics)
{
  print $_;

  system ("convert -geometry ".$tnsize."x".$tnsize." -quality $tnqual $_ tn/$_") == 0 
      || die "Problems with convert: $?\n";

  print " ... done\n";
}

print "Thumbnail creation complete...\n";
