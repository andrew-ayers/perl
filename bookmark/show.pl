#!/usr/bin/perl

# Name: show.pl - Handles "show of page" functionality
#  Rev: 5
# Date: July 15, 2003
#   By: Andrew L. Ayers

require "common.pl";
require "sid.pl";
require "db.pl";
require "html.pl";
require "error.pl";

sub show_login
{
	# Show login form

	html_clear();
	html_header();	
	html_line(template_load("login.htmt"));
	html_footer();
	html_show();
}

sub show_ilogin
{
	# Show invalid login form

	html_clear();
	html_header();
	
	# Show invalid login message
		
	html_line("<font color = #ff0000>Invalid Login</font><br>\n");
	html_line("<br>\n");

	html_line(template_load("login.htmt"));
	html_footer();
	html_show();
}

sub show_main
{
	# Get auth and sid passed in as parameters
	
	my (@valu) = @_;
	
	my $auth = $valu[0];
	my $sid = $valu[1];

	# Build common header
	
	html_clear();
	html_header();
	
        # Build search line

	html_line('<center>');
	html_line('<form method="post" action="'.$bm_path.'search.pl">');
	html_line('<input type="hidden" name="op" value="search">');
	html_line('<input type="hidden" name="sid" value="' . $sid . '">');
	
	html_line('<table cols="10,10,10">');

	html_line('<tr><td>Search By:<td>'.show_getlist("CAT", "1", "", $auth).'<td>'.show_getlist("OP", "1", "", $auth)).'</td></tr>';
	html_line('<tr><td><td>'.show_getlist("CAT", "2", "", $auth).'<td>'.show_getlist("OP", "2", "", $auth)).'</td></tr>';
	html_line('<tr><td><td>'.show_getlist("CAT", "3", "", $auth).'<td>').'</td></tr>';

	html_line('<tr><td><input type="submit" value="Show All"><td><td><input type="submit" value="Search"></td></tr>');

	html_line('</table>');
	
	html_line('</form>');
	html_line('</center>');

	#build_favorites($auth, $sid);
	#build_main($auth, $sid);

	# Build action button bar
	
	if ($auth eq "a" || $auth eq "s")
	{
		# Show admin action line
		
		show_actionline("SRC", $auth, $sid);	
	}
	elsif ($auth ne "a" && $auth ne "s")
	{
		show_actionline("SRC", $auth, $sid);	
	}
	else
	{
		# Invalid auth exception

		error_show("main.pl", $err_INVALID_AUTH, "[".$auth."]");
		
		exit(1);
	}

	# Build common footer and display
	
	html_footer();
	html_show();
}

sub show_logout
{
	# Get sid passed in as a parameter
	
	my (@valu) = @_;
	
	my $user = $valu[0];

	html_clear();
	html_header();
	html_line('User "' . $user . '" has been logged out...<br><br>');
	html_line('[ <a href="'.$bm_path.'login.pl">Re-login</a> ]<br><br>');		
	html_footer();
	html_show();					
}

sub show_users
{
	# Get auth and sid passed in as parameters
	
	my (@valu) = @_;
	
	my $auth = $valu[0];
	my $sid = $valu[1];

	# Build common header
	
	html_clear();
	html_header();
	
	# Only allow admins into this function
	
	if ($auth eq "a" || $auth eq "s")
	{
	        # Build user list form
	
		html_line('<center>');

		# Build caption and heading table
	
		html_line('<table BORDER=1 CELLPADDING=2>');
		html_line('<tr><th colspan=6>User Listing');
		html_line('<tr><th width=120>Name<th width=120>Password<th width=150>Authorization<th width=100>Logged In?<th colspan=2 width=250>Actions');

		# Loop thru users building user list table on form
	
		my @usr_list = db_load($db_users);
	
		for ($i = 0; $i <= $#usr_list; $i++)
		{
			my @test = split(/]/,$usr_list[$i]);

			my $db_num = $test[0];
			my $db_usr = $test[1];
			my $db_pwd = $test[2];
			my $db_aut = $test[3];
			my $db_sid = $test[4];
			
			# Evaluate auth flag and re-assign

			$db_aut = common_evalflag2word($db_aut,"a]s]u]g","Administrator]Superuser]User]Guest","<font COLOR=FF0000>UNKNOWN</font>");

			# Evaluate sid to determine user status (logged in?)
		
			if ($db_sid ne "")
			{
				$db_sid = "Yes";
			}
			else
			{
				$db_sid = "&nbsp;";
			}
			
			# Build table line
		
  			html_line('<tr><td align=center>'.$db_usr);
			html_line('<td align=center>'.$db_pwd);
  			html_line('<td align=center>'.$db_aut);
			html_line('<td align=center>'.$db_sid);
			
			# Build action entries
			
			html_line('<td align=center><a href="'.$bm_path.'users.pl?op=update&sid='.$sid.'&theUsr='.$db_num.'">Update</a>');
			html_line('<td align=center><a href="'.$bm_path.'users.pl?op=delete&sid='.$sid.'&theUsr='.$db_num.'">Delete</a>');
			html_line('</td>');
		}

		my $next_num = sprintf('U%03d',$i+1);
	
		# Build final "add user" action entry

		html_line('<tr><td colspan=4>');
		html_line('<td align=center colspan=2><a href="'.$bm_path.'users.pl?op=add&sid='.$sid.'&theUsr='.$next_num.'">Add User</a>');
		html_line('</td>');

		html_line('</table><p>');	

		# Show action line

		show_actionline("CAT", $auth, $sid);	
		
		html_line('</center>');
	}
	else
	{
		# Invalid auth exception

		error_show("users.pl", $err_INVALID_AUTH, "[".$auth."]");
		
		exit(1);
	}
	
	# Build common footer and display
	
	html_footer();
	html_show();
}

sub show_muser
{
	# Get auth, sid and selected user info passed in as parameters
	
	my (@valu) = @_;
	
	my $auth = $valu[0];
	my $sid = $valu[1];
	my $snum = $valu[2];
	
	# Using selected user info, get all other info for user
	
	my $nunam = "";
	my $nupwd = "";
	my $nuaut = "";
	
	my @user_list = db_load($db_users);
	
	for ($i = 0; $i <= $#user_list; $i++)
	{
		my @test = split(/]/,common_striplf($user_list[$i]));

		my $db_unum = $test[0];
		my $db_unam = $test[1];
		my $db_upwd = $test[2];
		my $db_uaut = $test[3];
		my $db_usid = $test[4];
		
		if ($db_unum eq $snum)
		{
			$nunam = $db_unam;
			$nupwd = $db_upwd;
			$nuaut = $db_uaut;
			
			last;
		}
	}

	# Build common header
	
	html_clear();
	html_header();
	
	# Only allow admins into this function
	
	if ($auth eq "a" || $auth eq "s")
	{
		html_line('<center>');
		html_line('<b>Update Information for User "'.$nunam.'"</b><p>');

	        # Build user update form
	
		html_line('<form method="post" action="'.$bm_path.'users.pl">');
	
		html_line('<table>');	

		html_line('<input type="hidden" name="sid" value="' . $sid . '">');
		html_line('<input type="hidden" name="theUsr" value="'.$snum.'">');

		html_line('<tr><td WIDTH=120>Name : <td WIDTH=70><input type="text" name="usrname" value="'.$nunam.'"></tr>');

		html_line('<tr><td WIDTH=120>Password : <td WIDTH=70><input type="text" name="usrpass" value="'.$nupwd.'"></tr>');
		
		html_line('<tr><td WIDTH=120>Authorization : <td WIDTH=70><select name="usrauth">');
		
		if ($nuaut eq "g")
		{
			html_line('<option selected>Guest');
		}
		else
		{
			html_line('<option>Guest');
		}

		if ($nuaut eq "u")
		{
			html_line('<option selected>User');
		}
		else
		{
			html_line('<option>User');
		}
		
		if ($nuaut eq "s")
		{
			html_line('<option selected>Superuser');
		}
		else
		{
			html_line('<option>Superuser');
		}
		
		if ($nuaut eq "a")
		{
			html_line('<option selected>Administrator');
		}
		else
		{
			html_line('<option>Administrator');
		}
		
		html_line('</select></tr>');			

		html_line('</table>');	

		# Build action button

		html_line('<input type="submit" name="op" value=" Cancel ">');
		
		html_line('<input type="submit" name="op" value=" Update ">');
	
		html_line('</form>');
		html_line('</center>');

		# Show action line

		show_actionline("ALL", $auth, $sid);		
	}
	else
	{
		# Invalid auth exception

		error_show("users.pl", $err_INVALID_AUTH, "[".$auth."]");
		
		exit(1);
	}
	
	# Build common footer and display
	
	html_footer();
	html_show();
}

sub show_auser
{
	# Get auth, sid and selected user info passed in as parameters
	
	my (@valu) = @_;
	
	my $auth = $valu[0];
	my $sid = $valu[1];
	my $snum = $valu[2];

	# Build common header
	
	html_clear();
	html_header();
	
	# Only allow admins into this function
	
	if ($auth eq "a" || $auth eq "s")
	{
		html_line('<center>');
		html_line('<b>Update Information for New User</b><p>');

	        # Build user add form
	
		html_line('<form method="post" action="'.$bm_path.'users.pl">');
	
		html_line('<table>');	

		html_line('<input type="hidden" name="sid" value="' . $sid . '">');
		html_line('<input type="hidden" name="theUsr" value="'.$snum.'">');

		html_line('<tr><td WIDTH=120>Name : <td WIDTH=70><input type="text" name="usrname" value="'.$nunam.'"></tr>');

		html_line('<tr><td WIDTH=120>Password : <td WIDTH=70><input type="text" name="usrpass" value="'.$nupwd.'"></tr>');

		html_line('<tr><td WIDTH=120>Authorization : <td WIDTH=70><select name="usrauth">');
		
		html_line('<option>Guest');
		html_line('<option>User');
		html_line('<option>Superuser');
		html_line('<option>Administrator');
		
		html_line('</select></tr>');			

		html_line('</table>');	

		# Build action button

		html_line('<input type="submit" name="op" value=" Cancel ">');
		
		html_line('<input type="submit" name="op" value=" Add ">');
	
		html_line('</form>');
		html_line('</center>');

		# Show action line

		show_actionline("ALL", $auth, $sid);	
	}
	else
	{
		# Invalid auth exception

		error_show("users.pl", $err_INVALID_AUTH, "[".$auth."]");
		
		exit(1);
	}
	
	# Build common footer and display
	
	html_footer();
	html_show();
}

sub show_categories
{
	# Get auth and sid passed in as parameters
	
	my (@valu) = @_;
	
	my $auth = $valu[0];
	my $sid = $valu[1];

	# Build common header
	
	html_clear();
	html_header();
	
	# Only allow admins into this function
	
	if ($auth eq "a" || $auth eq "s")
	{
	        # Build category list form
	
		html_line('<center>');

		# Build caption and heading table
	
		html_line('<table BORDER=1 CELLPADDING=2>');
		html_line('<tr><th colspan=5>Category Listing');
		html_line('<tr><th width=120>Description<th width=150>Authorization<th colspan=3 width=250>Actions');

		# Loop thru categories building category list table on form
	
		my @cat_list = db_load($db_cats);
	
		for ($i = 0; $i <= $#cat_list; $i++)
		{
			my @test = split(/]/,$cat_list[$i]);

			my $db_num = $test[0];
			my $db_cat = $test[1];
			my $db_aut = common_striplf($test[2]);
			
			# Evaluate auth flag and re-assign

			$db_aut = common_evalflag2word($db_aut,"a]s]u]g","Administrator]Superuser]User]Guest","<font COLOR=FF0000>UNKNOWN</font>");
		
  			html_line('<tr><td align=center>'.$db_cat);
  			html_line('<td align=center>'.$db_aut);
			
			# Build action entries
			
			html_line('<td align=center><a href="'.$bm_path.'category.pl?op=update&sid='.$sid.'&theCat='.$db_num.'">Update</a>');
			html_line('<td align=center><a href="'.$bm_path.'category.pl?op=delete&sid='.$sid.'&theCat='.$db_num.'">Delete</a>');
			html_line('<td align=center><a href="'.$bm_path.'links.pl?op=show&sid='.$sid.'&theCat='.$db_cat.'">Links</a>');
			html_line('</td>');
		}

		my $next_num = sprintf('C%03d',$i+1);
	
		# Build final "add category" action entry

		html_line('<tr><td colspan=2>');
		html_line('<td align=center colspan=3><a href="'.$bm_path.'category.pl?op=add&sid='.$sid.'&theCat='.$next_num.'">Add Category</a>');
		html_line('</td>');

		html_line('</table><p>');	

		# Show action line

		show_actionline("USR", $auth, $sid);	
	}
	else
	{
		# Invalid auth exception

		error_show("category.pl", $err_INVALID_AUTH, "[".$auth."]");
		
		exit(1);
	}
	
	# Build common footer and display
	
	html_footer();
	html_show();
}

sub show_mcategory
{
	# Get auth, sid and selected category info passed in as parameters
	
	my (@valu) = @_;
	
	my $auth = $valu[0];
	my $sid = $valu[1];
	my $snum = $valu[2];
	
	# Using selected category info, get all other info for category
	
	my $ncnam = "";
	my $ncaut = "";
	
	my @category_list = db_load($db_cats);
	
	for ($i = 0; $i <= $#category_list; $i++)
	{
		my @test = split(/]/,common_striplf($category_list[$i]));

		my $db_cnum = $test[0];
		my $db_cnam = $test[1];
		my $db_caut = $test[2];
		
		if ($db_cnum eq $snum)
		{
			$ncnam = $db_cnam;
			$ncaut = $db_caut;
			
			last;
		}
	}

	# Build common header
	
	html_clear();
	html_header();
	
	# Only allow admins into this function
	
	if ($auth eq "a" || $auth eq "s")
	{
		html_line('<center>');
		html_line('<b>Update Information for Category "'.$ncnam.'"</b><p>');

	        # Build category update form
	
		html_line('<form method="post" action="'.$bm_path.'category.pl">');
	
		html_line('<table>');	

		html_line('<input type="hidden" name="sid" value="' . $sid . '">');
		html_line('<input type="hidden" name="theCat" value="'.$snum.'">');

		html_line('<tr><td WIDTH=120>Name : <td WIDTH=70><input type="text" name="catname" value="'.$ncnam.'"></tr>');
		
		html_line('<tr><td WIDTH=120>Authorization : <td WIDTH=70><select name="catauth">');
		
		if ($ncaut eq "g")
		{
			html_line('<option selected>Guest');
		}
		else
		{
			html_line('<option>Guest');
		}

		if ($ncaut eq "u")
		{
			html_line('<option selected>User');
		}
		else
		{
			html_line('<option>User');
		}
		
		if ($ncaut eq "s")
		{
			html_line('<option selected>Superuser');
		}
		else
		{
			html_line('<option>Superuser');
		}
		
		if ($ncaut eq "a")
		{
			html_line('<option selected>Administrator');
		}
		else
		{
			html_line('<option>Administrator');
		}
		
		html_line('</select></tr>');			

		html_line('</table>');	

		# Build action button

		html_line('<input type="submit" name="op" value=" Cancel ">');
		
		html_line('<input type="submit" name="op" value=" Update ">');
	
		html_line('</form>');
		html_line('</center>');

		# Show action line

		show_actionline("ALL", $auth, $sid);	
	}
	else
	{
		# Invalid auth exception

		error_show("category.pl", $err_INVALID_AUTH, "[".$auth."]");
		
		exit(1);
	}
	
	# Build common footer and display
	
	html_footer();
	html_show();
}

sub show_acategory
{
	# Get auth, sid and selected category info passed in as parameters
	
	my (@valu) = @_;
	
	my $auth = $valu[0];
	my $sid = $valu[1];
	my $snum = $valu[2];

	# Build common header
	
	html_clear();
	html_header();
	
	# Only allow admins into this function
	
	if ($auth eq "a" || $auth eq "s")
	{
		html_line('<center>');
		html_line('<b>Update Information for New Category</b><p>');

	        # Build category add form
	
		html_line('<form method="post" action="'.$bm_path.'category.pl">');
	
		html_line('<table>');	

		html_line('<input type="hidden" name="sid" value="' . $sid . '">');
		html_line('<input type="hidden" name="theCat" value="'.$snum.'">');

		html_line('<tr><td WIDTH=120>Name : <td WIDTH=70><input type="text" name="catname" value="'.$ncnam.'"></tr>');
		
		html_line('<tr><td WIDTH=120>Authorization : <td WIDTH=70><select name="catauth">');
		
		html_line('<option>Guest');
		html_line('<option>User');
		html_line('<option>Superuser');
		html_line('<option>Administrator');
		
		html_line('</select></tr>');			

		html_line('</table>');	

		# Build action button

		html_line('<input type="submit" name="op" value=" Cancel ">');
		
		html_line('<input type="submit" name="op" value=" Add ">');
	
		html_line('</form>');
		html_line('</center>');

		# Show action line

		show_actionline("ALL", $auth, $sid);		
	}
	else
	{
		# Invalid auth exception

		error_show("category.pl", $err_INVALID_AUTH, "[".$auth."]");
		
		exit(1);
	}
	
	# Build common footer and display
	
	html_footer();
	html_show();
}

sub show_links
{
	# Get auth, sid, and category passed in as parameters
	
	my (@valu) = @_;
	
	my $auth = $valu[0];
	my $sid = $valu[1];
	my $scat = $valu[2];

	# Build common header
	
	html_clear();
	html_header();
	
	# Only allow admins into this function
	
	if ($auth eq "a" || $auth eq "s")
	{
	        # Build user list form
	
		html_line('<center>');

		# Build caption and heading table
	
		html_line('<table BORDER=1 CELLPADDING=2>');
		html_line('<tr><th colspan=6>Link Listing for Category '.$scat);
		html_line('<tr><th width=120>Name<th width=120>URL<th width=150>Authorization<th width=100>Rating<th colspan=2 width=250>Actions');

		# Loop thru links building linkr list table on form
	
		my @lnk_list = db_load($db_lnks);
	
		for ($i = 0; $i <= $#lnk_list; $i++)
		{
			my @test = split(/]/,$lnk_list[$i]);

			my $db_num = $test[0];
			my $db_nam = $test[1];
			my $db_dsc = $test[2];
			my $db_url = $test[3];
			my $db_cat = $test[4];
			my $db_aut = $test[5];
			my $db_rat = $test[6];
			
			# Evaluate auth flag and re-assign

			$db_aut = common_evalflag2word($db_aut,"a]s]u]g","Administrator]Superuser]User]Guest","<font COLOR=FF0000>UNKNOWN</font>");

			# Display only links in selected category

			my @cat_list = split(/\|/,$db_cat);

			for ($t = 0; $t <= $#cat_list; $t++)
			{
				if ($scat eq $cat_list[$t])
				{			
					# Build table line
		
  					html_line('<tr><td align=center>'.$db_nam);
					html_line('<td align=center>'.$db_url);
  					html_line('<td align=center>'.$db_aut);
					html_line('<td align=center>'.$db_rat);
			
					# Build action entries
			
					html_line('<td align=center><a href="'.$bm_path.'links.pl?op=update&sid='.$sid.'&theLnk='.$db_num.'&theCat='.$scat.'">Update</a>');
					html_line('<td align=center><a href="'.$bm_path.'links.pl?op=delete&sid='.$sid.'&theLnk='.$db_num.'&theCat='.$scat.'">Delete</a>');
					html_line('</td>');
					
					last;
				}
			}
		}

		my $next_num = sprintf('L%05d',$i+1);
	
		# Build final "add link" action entry

		html_line('<tr><td colspan=4>');
		html_line('<td align=center colspan=2><a href="'.$bm_path.'links.pl?op=add&sid='.$sid.'&theLnk='.$next_num.'&theCat='.$scat.'">Add Link</a>');
		html_line('</td>');

		html_line('</table><p>');	

		# Show action line

		show_actionline("ALL", $auth, $sid);	
	}
	else
	{
		# Invalid auth exception

		error_show("links.pl", $err_INVALID_AUTH, "[".$auth."]");
		
		exit(1);
	}
	
	# Build common footer and display
	
	html_footer();
	html_show();
}

sub show_mlink
{
	# Get auth, sid and selected link info passed in as parameters
	
	my (@valu) = @_;
	
	my $auth = $valu[0];
	my $sid = $valu[1];
	my $snum = $valu[2];
	my $scat = $valu[3];
	
	# Using selected user info, get all other info for user

	my $db_lnum = "";
	my $db_lnam = "";
	my $db_ldsc = "";
	my $db_lurl = "";
	my $db_lcat = "";
	my $db_laut = "";
	my $db_lrat = "";
	
	my @lnk_list = db_load($db_lnks);
	
	for ($i = 0; $i <= $#lnk_list; $i++)
	{
		my @test = split(/]/,common_striplf($lnk_list[$i]));

		$db_lnum = $test[0];
		$db_lnam = $test[1];
		$db_ldsc = $test[2];
		$db_lurl = $test[3];
		$db_lcat = $test[4];
		$db_laut = $test[5];
		$db_lrat = $test[6];

		if ($db_lnum eq $snum)
		{
			last;
		}
	}

	# Build common header
	
	html_clear();
	html_header();
	
	# Only allow admins into this function
	
	if ($auth eq "a" || $auth eq "s")
	{
		html_line('<center>');
		html_line('<b>Update Information for Link "'.$db_lnam.'"</b><p>');

	        # Build link update form
	
		html_line('<form method="post" action="'.$bm_path.'links.pl">');
	
		html_line('<table>');	

		html_line('<input type="hidden" name="sid" value="' . $sid . '">');
		html_line('<input type="hidden" name="theCat" value="'.$scat.'">');
		html_line('<input type="hidden" name="theLnk" value="'.$snum.'">');

		html_line('<tr><td WIDTH=120>Name : <td WIDTH=140><input type="text" name="lnkname" value="'.$db_lnam.'">');

		html_line('<tr><td WIDTH=120>Description : <td WIDTH=140><textarea name="lnkdesc" ROWS=3 COLS=30>'.$db_ldsc.'</textarea>');

		html_line('<tr><td WIDTH=120>URL : <td WIDTH=140><input type="text" name="lnklink" value="'.$db_lurl.'">');

		# Build category selection lists
		
		my @cat_list = split(/\|/,$db_lcat);

		for ($t = 0; $t <= 4; $t++)
		{
			my $csel = show_getlist("CAT", $t + 1, $cat_list[$t], $auth);

			html_line('<tr><td WIDTH=120>Category '.($t + 1).' : <td WIDTH=70>'.$csel);
		}
		
		html_line('<tr><td WIDTH=120>Authorization : <td WIDTH=70><select name="lnkauth">');

		if ($db_laut eq "g")
		{
			html_line('<option selected>Guest');
		}
		else
		{
			html_line('<option>Guest');
		}

		if ($db_laut eq "u")
		{
			html_line('<option selected>User');
		}
		else
		{
			html_line('<option>User');
		}
		
		if ($db_laut eq "s")
		{
			html_line('<option selected>Superuser');
		}
		else
		{
			html_line('<option>Superuser');
		}
		
		if ($db_laut eq "a")
		{
			html_line('<option selected>Administrator');
		}
		else
		{
			html_line('<option>Administrator');
		}
		
		html_line('</select>');			

		html_line('<tr><td WIDTH=120>Rating : <td WIDTH=20><input type="text" name="lnkrate" value="'.$db_lrat.'">');

		html_line('</table>');	

		# Build action button

		html_line('<input type="submit" name="op" value=" Cancel ">');
		
		html_line('<input type="submit" name="op" value=" Update ">');
	
		html_line('</form>');
		html_line('</center>');

		# Show action line

		show_actionline("ALL", $auth, $sid);	
	}
	else
	{
		# Invalid auth exception

		error_show("links.pl", $err_INVALID_AUTH, "[".$auth."]");
		
		exit(1);
	}
	
	# Build common footer and display
	
	html_footer();
	html_show();
}

sub show_alink
{
	# Get auth, sid and selected link info passed in as parameters
	
	my (@valu) = @_;
	
	my $auth = $valu[0];
	my $sid = $valu[1];
	my $snum = $valu[2];
	my $scat = $valu[3];

	# Build common header
	
	html_clear();
	html_header();
	
	# Only allow admins into this function
	
	if ($auth eq "a" || $auth eq "s")
	{
		html_line('<center>');
		html_line('<b>Update Information for New Link in Category '.$scat.'</b><p>');

	        # Build link add form

		html_line('<form method="post" action="'.$bm_path.'links.pl">');
	
		html_line('<table>');	

		html_line('<input type="hidden" name="sid" value="' . $sid . '">');
		html_line('<input type="hidden" name="theCat" value="'.$scat.'">');
		html_line('<input type="hidden" name="theLnk" value="'.$snum.'">');

		html_line('<tr><td WIDTH=120>Name : <td WIDTH=140><input type="text" name="lnkname" value="">');

		html_line('<tr><td WIDTH=120>Description : <td WIDTH=140><textarea name="lnkdesc" ROWS=3 COLS=30></textarea>');

		html_line('<tr><td WIDTH=120>URL : <td WIDTH=140><input type="text" name="lnklink" value="">');

		# Build category selection lists

		my $csel = show_getlist("CAT", 1, $scat, $auth);

		html_line('<tr><td WIDTH=120>Category 1 : <td WIDTH=70>'.$csel);
		
		my @cat_list = split(/\|/,$db_lcat);

		for ($t = 1; $t <= 4; $t++)
		{
			my $csel = show_getlist("CAT", $t + 1, "", $auth);

			html_line('<tr><td WIDTH=120>Category '.($t + 1).' : <td WIDTH=70>'.$csel);
		}
		
		html_line('<tr><td WIDTH=120>Authorization : <td WIDTH=70><select name="lnkauth">');
		html_line('<option>Guest');
		html_line('<option>User');
		html_line('<option>Superuser');
		html_line('<option>Administrator');
		html_line('</select>');			

		html_line('<tr><td WIDTH=120>Rating : <td WIDTH=20><input type="text" name="lnkrate" value="">');

		html_line('</table>');	

		# Build action button

		html_line('<input type="submit" name="op" value=" Cancel ">');
		
		html_line('<input type="submit" name="op" value=" Add ">');
	
		html_line('</form>');
		html_line('</center>');

		# Show action line

		show_actionline("ALL", $auth, $sid);	
	}
	else
	{
		# Invalid auth exception

		error_show("links.pl", $err_INVALID_AUTH, "[".$auth."]");
		
		exit(1);
	}
	
	# Build common footer and display
	
	html_footer();
	html_show();
}

sub show_search
{
        # Build link search results form

	# Get auth, sid, category(s), and operator(s) passed
	# in as parameters
	
	my (@valu) = @_;
	
	my $auth = $valu[0];
	my $sid = $valu[1];
	my $cat1 = $valu[2];
	my $opr1 = $valu[3];
	my $cat2 = $valu[4];
	my $opr2 = $valu[5];
	my $cat3 = $valu[6];

	# Build common header
	
	html_clear();
	html_header();
	
	# Build caption and heading

	html_line('<b>Search Results:</b><br><br>');

	# Loop thru links building search results on form

	my $lcount = 0;
		
	my @lnk_list = db_load($db_lnks);

	for ($i = 0; $i <= $#lnk_list; $i++)
	{
		my @test = split(/]/,$lnk_list[$i]);

		my $db_num = $test[0];
		my $db_nam = $test[1];
		my $db_dsc = $test[2];
		my $db_url = $test[3];
		my $db_cat = $test[4];
		my $db_aut = $test[5];
		my $db_rat = $test[6];
		
		# Display only links matching selected category(s) and
		# operator(s)

		my $found1 = $bFALSE;
		my $found2 = $bFALSE;
		my $found3 = $bFALSE;

		my @cat_list = split(/\|/,$db_cat);
		
		for ($t = 0; $t <= $#cat_list; $t++)
		{
			if ($cat1 eq $cat_list[$t])
			{			
				$found1 = $bTRUE;
			}
			
			if ($cat2 eq $cat_list[$t])
			{			
				$found2 = $bTRUE;
			}
			
			if ($cat3 eq $cat_list[$t])
			{			
				$found3 = $bTRUE;
			}
		}

		# Match on selected category 1
		
		my $passed = $found1;
		
		# Apply selected logical evaluation for
		# selected category 2
		
		if ($opr1 eq "AND")
		{
			$passed = $passed && $found2;
		}
		elsif ($opr1 eq "OR")
		{
			$passed = $passed || $found2;
		}
		elsif ($opr1 eq "NOT")
		{
			if ($found2 eq $bTRUE)
			{
				$passed = $bFALSE;
			}
			else
			{
				$passed = $bTRUE;
			}
		}
		else
		{
		}

		# Apply selected logical evaluation for
		# selected category 3

		if ($opr2 eq "AND")
		{
			$passed = $passed && $found3;
		}
		elsif ($opr2 eq "OR")
		{
			$passed = $passed || $found3;
		}
		elsif ($opr2 eq "NOT")
		{
			if ($found3 eq $bTRUE)
			{
				$passed = $bFALSE;
			}
			else
			{
				$passed = $bTRUE;
			}
		}
		else
		{
		}

		# Only show links authorized for this users auth level
		# (need code)
		
		#if ($db_aut eq $auth)
		
		# If all checks pass, then show link
		
		if ($passed eq $bTRUE)
		{
			html_line($tab_INDENT.$tab_INDENT.'<a href="'.$db_url.'">'.$db_nam.'</a>');
			
			$lcount = $lcount + 1;
			
			# Build "rating" level bullets
			
			if ($db_rat > 0)
			{
				html_line($tab_INDENT);					
				
				for ($t = 1; $t <= $db_rat; $t++)
				{
					html_line('<img src="'.$rat_path.'"></img>');
				}
			}			
	
			html_line('<br>');

			if ($db_dsc ne "")
			{
				html_line('<br>');
				html_line($tab_INDENT.$tab_INDENT.$tab_INDENT.$tab_INDENT.$db_dsc.'<br>');
			}										

			html_line('<br>');
		}	
	}

	if ($lcount > 0)
	{
		html_line('<br>');
		html_line('Found '.$lcount.' link(s)...<br>');
	}
	else
	{
		html_line($tab_INDENT.$tab_INDENT.'<font color=ff0000>No links found in database...</font><br>');
	}
	
	html_line('<br>');

	# Show action line

	html_line('<center>');
	
	show_actionline("ALL", $auth, $sid);	
	
	# Build common footer and display
	
	html_footer();
	html_show();
}

sub show_about
{
	# Get auth and sid passed in as parameters
	
	my (@valu) = @_;
	
	my $auth = $valu[0];
	my $sid = $valu[1];

	# Build common header
	
	html_clear();
	html_header();

	html_line(template_load("about.htmt"));

	# Build action line
	
	show_actionline("ABT", $auth, $sid);	

	# Build common footer and display
	
	html_footer();
	html_show();
}

sub show_actionline
{
	my (@valu) = @_;
	
	my $type = $valu[0];
	my $auth = $valu[1];
	my $sid = $valu[2];

	html_line('<center>');
	html_line('<hr>');

	# Build and show action line

	if ($type ne "SRC")
	{		
		html_line('[ <a href="'.$bm_path.'main.pl?op=show&sid=' . $sid . '">Return to Search Page</a> ] ');
	}

	if ($auth eq "a" || $auth eq "s")
	{
		if ($type eq "CAT" || $type eq "SRC" || $type eq "ABT" || $type eq "ALL")
		{
			html_line('[ <a href="'.$bm_path.'category.pl?op=show&sid=' . $sid . '">Update Categories</a> ] ');
		}
	
		if ($type eq "USR" || $type eq "SRC" || $type eq "ABT" || $type eq "ALL")
		{
			html_line('[ <a href="'.$bm_path.'users.pl?op=show&sid=' . $sid . '">Update Users</a> ] ');
		}
	}
	
	html_line('[ <a href="'.$bm_path.'logout.pl?sid=' . $sid . '">Logoff</a> ] ');
	
	if ($type ne "ABT")
	{
		html_line('[ <a href="'.$bm_path.'about.pl?op=show&sid=' . $sid . '">About</a> ]');
	}

	html_line('</center>');
}

sub show_getlist
{
	my (@valu) = @_;
	
	my $ltyp = $valu[0];
	my $lidx = $valu[1];
	my $lsel = $valu[2];
	my $auth = $valu[3];
	
	my $list = '<select name="';
	
	if ($ltyp eq "CAT")
	{
    		my @cat_list = db_load($db_cats);
		
		$list = $list.'catlst'.$lidx.'">';
		
		$list = $list.'<option>';
		
		for ($i = 0; $i <= $#cat_list; $i++)
		{
			my @test = split(/]/,$cat_list[$i]);
			my $db_num = $test[0];
			my $db_cat = $test[1];
			my $db_aut = $test[2];
		
			if ($db_cat eq $lsel)
			{
				$list = $list.'<option selected>';
			}
			else
			{
				$list = $list.'<option>';
			}
			
			if ($auth eq 'g' && $db_aut eq 'g')
			{
				$list = $list.$db_cat;
			}
			elsif ($auth eq 'u' && ($db_aut eq 'g' || $db_aut eq 'u'))
			{
				$list = $list.$db_cat;
			}
			elsif ($auth eq 's' && ($db_aut eq 'g' || $db_aut eq 'u' || $db_aut eq 's'))
			{
				$list = $list.$db_cat;
			}
			elsif ($auth eq 'a')
			{
				$list = $list.$db_cat;
			}
		}
	}
	elsif ($ltyp eq "OP")
	{
		$list = $list.'oplist'.$lidx.'">';
		$list = $list.'<option>';
		$list = $list.'<option>AND';
		$list = $list.'<option>OR';
		$list = $list.'<option>NOT';
	}
		
	$list = $list.'</select>';
	
	return($list);
}

1;
