#!/usr/bin/perl

# Name: pgrab_inc.pl - Constants for pgrab
#  Rev: 1
# Date: October 12, 2001
#   By: Andrew L. Ayers

#
# List of improvements to make:
#
#   Image delete capability (on camera and download dir)
#   Changing download dir
#   Modding and saving of user prefs
#   Checking to see if file exists before download or delete
#   Cleanup of redundant code
#   Better error handling
#   Speed up download of all pics
#   Allow showing of download dir on single image download
#


# Define gphoto command line defaults

$gp_port = "serial:/dev/ttyS1";	# gphoto port to use
$gp_sped = "115200";		# gphoto speed to use for port
#$gp_sped = "57600";		# gphoto speed to use for port
#$gp_sped = "38400";		# gphoto speed to use for port
#$gp_sped = "19200";		# gphoto speed to use for port
#$gp_sped = "9600";		# gphoto speed to use for port
$gp_camr = "Kodak DC3200";	# gphoto camera to use
$gp_fold = "/DCIM/100K3200";	# gphoto default camera folder

# Define base gphoto command line

$gp_cmd = "gphoto2 --port " . $gp_port . " --speed " . $gp_sped . " --camera '" . $gp_camr . "'";

# Define gphoto command line to get number of pictures

$gp_cnt = $gp_cmd . " -f " . $gp_fold . " -n"; # Number of pictures

# Define pgrab defaults

$pg_titl = "pGrab";		# pgrab title
$pg_vers = "1.0 Beta";		# pgrab version info
$pg_prfx = "pg_";		# pgrab image file prefix
$pg_sufx = "jpg";		# pgrab image file suffix
$pg_clear = `clear`;		# Clear screen

# Start application

ShowMainMenu();

sub ShowMainMenu()
{
	my $error_flag = 0;
	
	while (1==1)
	{
		print $pg_clear;
	
		print "\n " . $pg_titl . " - Version " . $pg_vers . " - Main Menu\n\n";
	
		print "   1. Show Current Settings\n";
		print "   2. Get Image Count\n";
		print "   3. Download Single Image\n";
		print "   4. Download All Images\n";
		print "   5. Show Download Directory\n";
		print "   6. About " . $pg_titl . "\n";
		print "   7. Quit\n\n";

		if ($error_flag == 1)
		{
			print "\a Invalid input...";
		}
		else
		{
			print " ";
		}

		print "Please select (1-7) : ";
	
		$inp = <>; # Read from standard input
	
		if ($inp eq "1\n")
		{
			ShowCurrentSettings();
		}
		elsif ($inp eq "2\n")
		{
			ShowImageCount();
		}
		elsif ($inp eq "3\n")
		{
			DownloadSingleImage();
		}
		elsif ($inp eq "4\n")
		{
			DownloadAllImages();
		}
		elsif ($inp eq "5\n")
		{
			ShowDirectory();
		}
		elsif ($inp eq "6\n")
		{
			ShowAbout();
		}
		elsif ($inp eq "7\n")
		{
			print $pg_clear;
			print "Thank you for using " . $pg_titl . "\n\n";
			exit(1);
		}
		else
		{
			$error_flag = 1;
		}
	}
}

sub ShowAbout()
{
	print $pg_clear;

	print "\n " . $pg_titl . " - Version " . $pg_vers . " - About\n\n";

	print "   " . $pg_titl . " - Version " . $pg_vers ."\n";
	print "   Copyright (C) 2001 by Andrew L. Ayers\n";
	print "   To be released under the GPL\n\n";

	print " Press [RETURN] to continue : ";
	
	$inp = <>;
	
	print $pg_clear;

}

sub ShowDirectory()
{
	print $pg_clear;

	print "\n " . $pg_titl . " - Version " . $pg_vers . " - Show Download Directory\n\n";
	
	$test = `ls -ls`;
	
	print " Contents :\n\n " . $test . "\n";

	print " Press [RETURN] to continue : ";
	
	$inp = <>;
	
	print $pg_clear;


}
sub ShowImageCount()
{
	print $pg_clear;
 	
	print "\n " . $pg_titl . " - Version " . $pg_vers . " - Image Count\n\n";

        print " Please wait...";

	$count = GetImageCount();
	
	if ($count > 0)
	{
		print $pg_clear;
 	
		print "\n " . $pg_titl . " - Version " . $pg_vers . " - Image Count\n\n";

		print " Current folder on " . $gp_camr . " : " . $gp_fold . "\n\n";
		
		print " Number of images : " . $count . "\n\n";
	}
	else
	{
		# Error!!!

		print $pg_clear;

		print "\n " . $pg_titl . " - Version " . $pg_vers . " - Image Count\n\n";

		print "\a ERROR : Please check camera and try again...\n\n";
	}

	print " Press [RETURN] to continue : ";
	
	$inp = <>;
	
	print $pg_clear;
}

sub GetImageCount()
{
	sleep 5;
	
        my $count = `$gp_cnt`;

	@test = split(" ", $count);

	if ($test[0] eq "Number")
	{
		@count = split(": ", $count);
		
		$count = $count[1];
		
		chop $count;
	}
	else
	{
		# Error!!!
		
		$count = -1;
	}
	
	return ($count);
}

sub DownloadImage
{
	my (@valu) = @_;
	
	my $num = $valu[0];

	sleep 6;
	
	my $filename = sprintf("%s%03s%s%s", $pg_prfx, $num, ".", $pg_sufx);
	
	print " Downloading : " . $filename;

       	$test = $gp_cmd . " -f " . $gp_fold . " -p " . $num . " --filename '" . $filename . "'";		
	
	$test = `$test`;
	
	print " - finished.\n";
}

sub DownloadSingleImage()
{
	print $pg_clear;
 	
	print "\n " . $pg_titl . " - Version " . $pg_vers . " - Download Single Image\n\n";
	
	my $count = GetImageCount();

	if ($count == -1)
	{
		# Error

		print $pg_clear;

		print "\n " . $pg_titl . " - Version " . $pg_vers . " - Download Single Image\n\n";

		print "\a ERROR : Please check camera and try again...\n\n";
	
		print " Press [RETURN] to continue : ";
	}
	else
	{
	        print " Current folder on " . $gp_camr . " : " . $gp_fold . "\n\n";
		
		$inp = 0;
	
		while ($inp eq 0)
		{
			print " Enter image number (1-" . $count .") to download : ";
	
			$inp = <>;
	
			chop $inp;
		
			if ($inp < 1 || $inp > $count)
			{
				$inp = 0;
				next;
			}
		}
		continue
		{
			if ($inp == 0)
			{
				print "\n >>> Invalid Number <<< \n\n";
			}
		}
	
		print "\n";
	
		DownloadImage($inp);

		print "\n Download complete - Press [RETURN] to continue : ";
	}
	
	$inp = <>;
	
	print $pg_clear;	
}

sub DownloadAllImages()
{
	print $pg_clear;
 	
	print "\n " . $pg_titl . " - Version " . $pg_vers . " - Download All Images\n\n";
	
	my $count = GetImageCount();

	if ($count == -1)
	{
		# Error

		print $pg_clear;

		print "\n " . $pg_titl . " - Version " . $pg_vers . " - Download Single Image\n\n";

		print "\a ERROR : Please check camera and try again...\n\n";
	
		print " Press [RETURN] to continue : ";
	}
	else
	{	
	        print " Current folder on " . $gp_camr . " : " . $gp_fold . "\n\n";
		
		print " Number of images to download : " . $count . "\n\n";
	
		for ($i = 1; $i <= $count; $i++)
		{
			DownloadImage($i);
		}

		print "\n Download complete - Press [RETURN] to continue : ";
	}
	
	$inp = <>;
	
	print $pg_clear;
}

sub ShowCurrentSettings()
{
	print $pg_clear;
 	
	print "\n " . $pg_titl . " - Version " . $pg_vers . " - Settings\n\n";

	print "   GPhoto Port   : " . $gp_port . "\n";
	print "   GPhoto Speed  : " . $gp_sped . "\n";
	print "   GPhoto Camera : " . $gp_camr . "\n";
	print "   GPhoto Folder : " . $gp_fold . "\n\n";
	
	print "   " . $pg_titl . " Prefix  : " . $pg_prfx . "\n";
	print "   " . $pg_titl . " Suffix  : " . $pg_sufx . "\n\n";

	print " Press [RETURN] to continue : ";
	
	$inp = <>;
	
	print $pg_clear;
}
