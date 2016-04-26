#!/usr/bin/perl

# **************************************************
# *                                                *
# *           siteupdt.pl - Version 1.0            *
# *                                                *
# * Released under terms of the GNU Public License *
# *                                                *
# *     Copyright (c) 2003 by Andrew L. Ayers      *
# *                                                *
# **************************************************

# Set banner display flag (not needed for cron)
$banner = "Y"; # Set to "" for no banner
$debug = "";  # Set to "" for regular use

# Set local home path of site copy
$localhome = "";

# Set remote home path
$rmotehome = "~/";

# Set other remote variables
$rmoteserv = "server";
$rmoteuser = "username";
$rmotepass = "password";

# Set path of data files
$datpath = "./";

# Set binary/ascii extension switches

$bintype = "zip:jpg:gif:tgz";
$asctype = "txt:htm:html:dat";

# Set filenames of data files
$loglist = $datpath."loglist.dat"; # logging file for siteupdt.pl
				   # set to "" to send to stdout
$tmplist = $datpath."tmplist.dat"; # temp list of files
$oldlist = $datpath."oldlist.dat"; # old list of files
$newlist = $datpath."newlist.dat"; # new list of files
$wrklist = $datpath."wrklist.dat"; # work list of files
$ftplist = $datpath."ftplist.dat"; # work list processed into ftp script

# Update counts
$addcount = 0;
$updcount = 0;
$delcount = 0;

# Show banner (if needed)

if ($banner ne "")
{
	print "\n";
	print "**************************************************\n";
	print "*                                                *\n";
	print "*           siteupdt.pl - Version 1.0            *\n";
	print "*                                                *\n";
	print "* Released under terms of the GNU Public License *\n";
	print "*                                                *\n";
	print "*     Copyright (c) 2003 by Andrew L. Ayers      *\n";
	print "*                                                *\n";
	print "**************************************************\n\n";
}

# Build list of new files/paths, permissions and timestamp
UpdtLog("Building current list of local files");
#$fcmd = "find ".$localhome." -printf '%p:%C@:%m\n' > ".$tmplist;
$fcmd = "find ".$localhome." -printf '%p:%m";
$fcmd = $fcmd.":%C@\n' > ".$tmplist;
system $fcmd;

# Process $tmplist here from path:perm:time to path:type:perm:time
# (in $newlist), so that when it is copied, $oldlist becomes 
# newlist, and we are able to tell what type a deleted file/dir
# was (a F)ile or a D)irectory)

# Build new list of files/paths from temporary list
open (NEW, ">".$newlist);

# Process temp list of files/paths to determine types
open (TMP, $tmplist);

while ($tmpline = <TMP>)
{
	# Retrieve temp path/file and timestamp
	@tarray = split(':', $tmpline);
	
	$tmppath = @tarray[0];
	$tmpperm = @tarray[1];
	$tmptime = @tarray[2];

	# Find out whether path is a directory or a file	
	if (isDir($tmppath) eq "Y")
	{
		$tmptype = "D";
	}
	else
	{
		$tmptype = "F";
	}

	print NEW $tmppath.":".$tmptype.":".$tmpperm.":".$tmptime;
}
close TMP;
close NEW;

# Delete $tmplist

unlink $tmplist;

# Build work list of files/paths to update
UpdtLog("Building update work list");
open (WRK, ">".$wrklist);

# Process old list of files/paths for deletes to site
#
# The old list ($oldlist) is processed in reverse via a
# piped "tac". This is because deletes need to happen in
# reverse order from adds, since we may need to delete
# files from a directory, prior to deleting that directory
# (ie, a situation in which there are files in a directory,
# and the entire directory is deleted). The deletes from
# this are added first to the worklist, so that when the
# ftp list is built, the deletes will occur prior to adds
# and updates.

if (-f $oldlist)
{
	UpdtLog("Old list found from prior run");
	UpdtLog("Adding deleted files/paths to work list");
	open (OLD, "tac ".$oldlist."|");

	while ($oldline = <OLD>)
	{
		# Retrieve old path/file and timestamp
		@oarray = split(':', $oldline);
	
		$oldpath = @oarray[0];
		$oldtype = @oarray[1];
		$oldperm = @oarray[2];
		$oldtime = @oarray[3];
		$match = 0;

		# Check new list for matches to each new path/file	
		open (NEW, $newlist);
	
		while ($newline = <NEW>)
		{
			# Retrieve new path/file and timestamp
			@narray = split(':', $newline);
	
			$newpath = @narray[0];
			$newtype = @narray[1];
			$newperm = @narray[2];
			$newtime = @narray[3];
		
			# If the old path/file is found, then this
			# is not a delete
			if ($newpath eq $oldpath)
			{
				$match = 1;
				last;
			}
		}
		close NEW;

		# Remove local base path
		$modpath = substr($oldpath, (length $localhome), (length $oldpath));

		if ($match eq 0 && $modpath ne "")
		{
			print WRK "D:".$oldtype.":".$modpath.":".$oldperm."\n";
			$delcount += 1;
		}
	}
	close OLD;
}
else
{
	UpdtLog("Old list not found from prior run");
}

# Process new list of files/paths for updates and adds to site
UpdtLog("Adding file/path updates to work list");
open (NEW, $newlist);

while ($newline = <NEW>)
{
	# Retrieve new path/file and timestamp
	@narray = split(':', $newline);
	
	$newpath = @narray[0];
	$newtype = @narray[1];
	$newperm = @narray[2];
	$newtime = @narray[3];
	$match = 0;
	$wrkactn = "";

	# Check old list for matches to each new path/file	

	open (OLD, $oldlist);
	
	while ($oldline = <OLD>)
	{
		# Retrieve old path/file and timestamp
		@oarray = split(':', $oldline);
	
		$oldpath = @oarray[0];
		$oldtype = @oarray[1];
		$oldperm = @oarray[2];
		$oldtime = @oarray[3];
		
		# If the path/file matches, then path/file existed
		# before, and this might be an update
		if ($oldpath eq $newpath)
		{
			$match = 1;
			last;
		}
	}
	close OLD;

	# Maybe an update?
	if ($match eq 1)	
	{
		if ($oldtime ne $newtime)
		{
			# If the timestamps are different, then it is
			# a regular update
			$wrkactn = "U";

			if ($oldperm ne $newperm)
			{
				# If the permissions are different, then it is
				# a permissions update
				$wrkactn = "P";
			}
		}
		else
		{
			# Otherwise, there is no update
			$match = 0;
		}
	}
	else
	{
		# Must be an add since it didn't exist before
		$wrkactn = "A";
	}

	# Remove local base path
	$wrkpath = substr($newpath, (length $localhome), (length $newpath));

	if ($wrkactn eq "U" && $wrkpath ne "")
	{
		# If there is an Update, then type can only be a file,
		# Increment counts for update status message
		if ($newtype ne "D")
		{
			print WRK $wrkactn.":F:".$wrkpath.":".$newperm."\n";
			$updcount += 1;
		}
	}
	elsif ($wrkactn eq "P" && $wrkpath ne "")
	{
		# If there is a permissions update, then type can only be any
		# Increment counts for update status message
		print WRK $wrkactn.":".$newtype.":".$wrkpath.":".$newperm."\n";
		$updcount += 1;
	}
	elsif ($wrkactn eq "A" && $wrkpath ne "")
	{
		# Otherwise if it is an Add, then type can be anything.
		# Increment counts for update status message
		print WRK $wrkactn.":".$newtype.":".$wrkpath.":".$newperm."\n";		
		$addcount += 1;
	}
}
close NEW;
close WRK;

# Show status message
if ($addcount eq 0 && $updcount eq 0 && $delcount eq 0)
{
	# Delete work list
	UpdtLog("Deleting work list");
	if ($debug ne "Y"){unlink $wrklist;}

	UpdtLog("No site updates needed");
}
else
{
	UpdtLog("Site updates needed - creating FTP script from work list");

	# Process work list into ftp script

	$lastfldr = "X";
	$lasttype = "";

	open (FTP, ">".$ftplist);

	print FTP "open $rmoteserv\n";
	print FTP "user $rmoteuser $rmotepass\n";

	open (WRK, $wrklist);

	while ($wrkline = <WRK>)
	{
		@warray = split(':', $wrkline);
	
		$wrkactn = @warray[0]; # Action to perform (A=Add, U=Update, D=Delete)
		$wrktype = @warray[1]; # Type (F=File, D=Directory)
		$wrkpath = @warray[2]; # File path to perform action on/with
		$wrkperm = @warray[3]; # Permissions
		$wrkname = "";
	
		# Split the work path into path and name pieces
		# The name piece may be a folder or file
	
		@narray = split('/', $wrkpath);
	
		$wrkname = @narray[$#narray];

		# Remove carriage return at end of permissions
		$wrkperm = substr($wrkperm, 0, (length $wrkperm) - 1);
		$wrkfldr = "";

		for ($t = $#narray - 1; $t >= 0; $t--)
		{
			$wrkfldr = @narray[$t]."/".$wrkfldr;
		}
	
		$ftptype = GetFTPFileMode($wrkname);
	
		if ($wrkactn eq "A")
		{
			# If add:
		
			if ($wrktype eq "D")
			{
	  			# If path, prepend remote home base path to the work path
				# CD to the remote path
				# MKDIR the folder name
				# CHMOD permissions

				if ($wrkfldr ne $lastfldr)
				{			
	  				print FTP "lcd ".$localhome.$wrkfldr."\n";
					print FTP "cd ".$rmotehome.$wrkfldr."\n";
				}
			
				print FTP "mkdir ".$wrkname."\n";
				print FTP "chmod ".$wrkperm." ".$wrkname."\n";
			}
			else
			{
				# If file, prepend remote home base path to the work path.
				# Prepend local home base path to the work path.
				# CD to remote path, LCD to local path.
				# Check file type (asc/bin), and put from local to remote.
				# Update the permissions
			
				if ($wrkfldr ne $lastfldr)
				{			
	  				print FTP "lcd ".$localhome.$wrkfldr."\n";
					print FTP "cd ".$rmotehome.$wrkfldr."\n";
				}
			
				if ($ftptype ne $lasttype)
				{			
					print FTP $ftptype."\n";
				}
			
				print FTP "put ".$wrkname."\n";			
				print FTP "chmod ".$wrkperm." ".$wrkname."\n";
			}
		}
		elsif ($wrkactn eq "U")
		{
			# If update:
			#
			#   Prepend remote home base path to the work path.
			#   Prepend local home base path to the work path.
			#   CD to remote path, LCD to local path.
			#   Check file type (asc/bin), and put from local to remote.

			if ($wrkfldr ne $lastfldr)
			{			
	  			print FTP "lcd ".$localhome.$wrkfldr."\n";
				print FTP "cd ".$rmotehome.$wrkfldr."\n";
			}
		
			if ($ftptype ne $lasttype)
			{			
				print FTP $ftptype."\n";
			}

			print FTP "put ".$wrkname."\n";	
		}
		elsif ($wrkactn eq "P")
		{
			# If permissions update:
			#
			#   Prepend remote home base path to the work path.
			#   Prepend local home base path to the work path.
			#   CD to remote path, LCD to local path.
			#   Update permissions

			if ($wrkfldr ne $lastfldr)
			{			
	  			print FTP "lcd ".$localhome.$wrkfldr."\n";
				print FTP "cd ".$rmotehome.$wrkfldr."\n";
			}
		
			print FTP "chmod ".$wrkperm." ".$wrkname."\n";
		}
		elsif ($wrkactn eq "D")
		{
			# If delete:
			#
  			#   If path, prepend remote home base path to the work path
			#   CD to the remote path
			#   Delete the folder/file name

			if ($wrkfldr ne $lastfldr)
			{			
  				print FTP "lcd ".$localhome.$wrkfldr."\n";
				print FTP "cd ".$rmotehome.$wrkfldr."\n";
			}

			if ($wrktype eq "D")
			{
				# Delete folder
				print FTP "rmdir ".$wrkname."\n";
			}
			else
			{
				# Delete file
				print FTP "delete ".$wrkname."\n";
			}
		}
		else
		{
			# Invalid action flag (should *never* hit)
		}
	
		$lastfldr = $wrkfldr;
		$lasttype = $ftptype;
	}

	close WRK;

	print FTP "bye\n";

	close FTP;

	# Delete work list
	UpdtLog("Deleting work list");
	if ($debug ne "Y"){unlink $wrklist;}

	# Verify remote server is alive and FTP is up
	UpdtLog("Verifying remote server ".$rmoteserv." FTP is alive");
	if (IsAlive() eq "Y")
	{
		UpdtLog("Remote server is alive (responded to ping)");
		# Execute script on remote server
		UpdtLog("Executing FTP script against remote server ".$rmoteserv);
		if ($debug ne "Y"){RunFTPScript();}
		UpdtLog("Deleting FTP script");
		if ($debug ne "Y"){unlink $ftplist;}

		# Show update counts
		if ($addcount ne 0){UpdtLog($addcount." files/paths added");}
		if ($updcount ne 0){UpdtLog($updcount." files updated");}
		if ($delcount ne 0){UpdtLog($delcount." files/paths deleted");}

		UpdtLog("Site update complete");

		# Copy new list to old list, for future checking
		system "cp ".$newlist." ".$oldlist;
	}
	else
	{
		# Remote server is down in some manner
		UpdtLog("Remote server down (not responding to ping)");
		UpdtLog("Site update aborted");
	}
}

UpdtLog("*** END OF RUN ***");

# Exit back to system
exit;

sub isDir
{
	# Is passed-in path a file or directory?
	
	my (@valu) = @_;
	
	my $path = $valu[0];
	
	if (-d $path)
	{
		$mode = "Y";
	}
	elsif (-f $path)
	{
		$mode = "N";
	}
	else
	{
		$mode = "N";
	}
	
	return($mode);
}

sub GetFTPFileMode
{
	# Is passed-in file name ascii or binary?
	
	my (@valu) = @_;
	
	$ftpname = $valu[0];

	@narray = split('\.', $ftpname);	
	
	$ext = @narray[$#narray];

	# Check binary types
	
	@tarray = split(':', $bintype);
	
	for ($t = 0; $t <= $#tarray; $t++)
	{
		if ($ext eq @tarray[$t])
		{
			return("binary");
		}
	}

	# Check ascii types
	
	@tarray = split(':', $asctype);
	
	for ($t = 0; $t <= $#tarray; $t++)
	{
		if ($ext eq @tarray[$t])
		{
			return("ascii");
		}
	}

	# Return binary if not found
	
	return("binary");
}

sub IsAlive
{
	# Is remote server alive?

	# Open a pipe from the ping command. Set the number of tries
	# to 1, the number of seconds to wait to 2, and go to quiet
	# mode.	Redirect stderr to null (to supress "unknown host"
	# messages from ping)

	open (PNG, "ping -c 1 -w 2 -q ".$rmoteserv." 2>/dev/null |");

	@parray = <PNG>;
	
	close PNG;

	# Check last line in piped file to existance of the
	# words "round-trip", which only appear if ping was
	# successful

	if (substr(@parray[$#parray], 0, 10) eq "round-trip")
	{
		return("Y");
	}

	return("N");
}

sub UpdtLog
{
	# Add passed-in status line to log file
	
	my (@valu) = @_;
	
	$message = $valu[0];
	
	if ($loglist eq "")
	{
		# Stdout
		print $message."\n";
	}
	else
	{
		if (!-f $loglist)
		{
   			open (LOG, ">>".$loglist);
			print LOG GetTimeStamp()." - siteupdt.pl - New log file\n";
			print LOG GetTimeStamp()." - ***\n";
		}
		else
		{
			open (LOG, ">>".$loglist);
		}
		
		# Log file (append)
		print LOG GetTimeStamp()." - ".$message."\n";
		close LOG;
	}
}

sub GetTimeStamp
{
	my ($seconds,$minutes,$hour,$day,$month,$year) = localtime(time);
	
	$month++;
	
	if ($seconds < 10){$seconds = "0".$seconds;}
	if ($minutes < 10){$minutes = "0".$minutes;}
	if ($day < 10){$day = "0".$day;}
	if ($month < 10){$month = "0".$month;}

	$year = "20".substr($year,1,2);
	
	return($month."-".$day."-".$year." ".$hour.":".$minutes.":".$seconds);
}

sub RunFTPScript
{
	# Run the FTP against the remote server
	# Echo the commands to FTP via a pipe,
	# FTP has stderr redirected to /dev/null
	
	my $cmds = "";
	
	open (FTP, $ftplist);

	while ($ftpline = <FTP>)
	{
		$cmds = $cmds.$ftpline;
	}
	close FTP;
	
	system 'echo -e "'.$cmds.'" | ftp -i -n';
	#system 'echo -e "'.$cmds.'" | ftp -i -n 2>/dev/null';
}
