script "relay_soolascend.ash";

// Thanks to relay_cheeseascend.ash for a starting point here.

record setting {
	string name;
	string type;
	string description;
};

setting[string][int] s;
string[string] fields;
boolean success;

void write_styles()
{
	# This function provided by Zen00.
	writeln("<style type='text/css'>"+
	"body {"+
	"width: 95%;"+
	"margin: auto;"+
	"background: #EAEAEA;"+
	"text-align:center;" +
	"padding:0;"+
	"cursor:default;"+
	"user-select: none;"+
	"-webkit-user- select: none;"+
	"-moz-user-select: text;}"+

	"h1 {"+
	"font-family:times;" +
	"font-size:125%;"+
	"color:#000;}"+

	"table, th, td {"+
	"border: 1px solid black;}"+
	"</style>");
}


void handleSetting(string type, int x)
{
	string color = "white";
	switch(type)
	{
	case "any":		color = "#00ffff";		break;
	case "pre":		color = "#ffff00";		break;
	case "post":	color = "#00ff00";		break;
	case "action":	color = "#af6fbf";		break;
	case "sharing":	color = "#ff6644";		break;
	default:		color = "#ffffff";		break;
	}

	setting set = s[type][x];
	switch(set.type)
	{
	case "boolean":
		write("<tr bgcolor="+color+"><td align=center>"+set.name+"</td><td align=center><select name='"+set.name+"'>");
		if(get_property(set.name) == "true")
		{
			write("<option value='true' selected='selected'>true</option><option value='false'>false</option>");
		}
		else
		{
			write("<option value='true'>true</option><option value='false' selected='selected'>false</option>");
		}
		writeln("</td><td>"+set.description+"</td></tr>");
		break;
	default:
		writeln("<tr bgcolor="+color+"><td align=center>"+set.name+"</td><td><input type='text' name='"+set.name+"' value='"+get_property(set.name)+"' /></td><td>"+set.description+"</td></tr>");
		break;
	}
	writeln("<input type='hidden' name='"+set.name+"_didchange' value='"+get_property(set.name)+"' />");
}

void generateTrackingData(string tracked, boolean hasSkill)
{
	int day = 0;
	string[int] tracking = split_string(get_property(tracked), ",");
	if(get_property(tracked) == "")
	{
		return;
	}
	foreach x in tracking
	{
		if(tracking[x] == "")
		{
			continue;
		}
		matcher paren = create_matcher("[()]", tracking[x]);
		tracking[x] = replace_all(paren, "");
		matcher asdon = create_matcher("Asdon Martin:", tracking[x]);
		tracking[x] = replace_all(asdon, "Asdon Martin -");
		string[int] current = split_string(tracking[x], ":");
		int curDay = to_int(current[0]);
		string enemy = current[1];

		string skillUsed = "";
		int turns = 0;

		if(hasSkill)
		{
			skillUsed = current[2];
			turns = to_int(current[3]);
		}
		else
		{
			turns = to_int(current[2]);
		}
		if(curDay > day)
		{
			day = curDay;
			if(day > 1)
			{
				writeln("<br><br>");
			}
			writeln("Day " + day + ": ");
		}
		if(hasSkill)
		{
			writeln("(" + enemy + ":" + skillUsed + ":" + turns + "), ");
		}
		else
		{
			writeln("(" + enemy + ":" + turns + "), ");
		}
	}
}

void main()
{
	write_styles();
	writeln("<html><head><title>soolascend Crapulent Manager</title>");
	writeln("</head><body><h1>soolascend Manager</h1>");

	file_to_map("auto_ascend_settings.txt", s);

	boolean dickstab = false;
	writeln("<form action='' method='post'>");
	writeln("<input type='hidden' name='auto_interrupt' value='true'/>");
	writeln("<input type='submit' name='' value='Interrupt Script'/></form>");


	fields = form_fields();
	if(count(fields) > 0)
	{
		foreach x in fields
		{
			if(contains_text(x, "_didchange"))
			{
				continue;
			}

			string oldSetting = form_field(x + "_didchange");
			if(oldSetting == fields[x])
			{
				if(get_property(x) != fields[x])
				{
					writeln("You did not change setting " + x + ". It changed since you last loaded the page, ignoring.<br>");
				}
				continue;
			}
#			else
#			{
#				writeln("Property " + x + " had: " + oldSetting + " now: " + fields[x] + "<br>");
#			}

			if(x == "auto_dickstab")
			{
				if((fields[x] != get_property("auto_dickstab")) && (fields[x] == "true"))
				{
					dickstab = true;
				}
			}
			if(get_property(x) != fields[x])
			{
				writeln("Changing setting " + x + " to " + fields[x] + "<br>");
				set_property(x, fields[x]);
			}
		}
	}

	if(dickstab)
	{
		writeln("auto_dickstab was just set to true<br>");
		writeln("Your warranty has been declared void.<br>");
		set_property("auto_voidWarranty", "rekt");
		writeln("Togging incompatible settings. You can re-enabled them here if you so desire. This resetting only takes effect upon setting auto_dickstab to true.<br><br>");
#		if(get_property("auto_getDinseyGarbageMoney").to_boolean())
#		{
#			set_property("auto_getDinseyGarbageMoney", false);
#			writeln("Disabled auto_getDinseyGarbageMoney.<br>");
#		}
		if(get_property("auto_hippyInstead").to_boolean())
		{
			set_property("auto_hippyInstead", false);
			writeln("Disabled auto_hippyInstead.<br>");
		}
		if(get_property("auto_ignoreFlyer").to_boolean())
		{
			set_property("auto_ignoreFlyer", false);
			writeln("Disabled auto_ignoreFlyer.<br>");
		}
		if(!get_property("auto_delayHauntedKitchen").to_boolean())
		{
			set_property("auto_delayHauntedKitchen", true);
			writeln("Enabled auto_delayHauntedKitchen.<br>");
		}
	}


	writeln("<form action='' method='post'>");
	writeln("<table><tr><th width=20%>Setting</th><th width=20%>Value</th><th width=60%>Description</th></tr>");
	foreach x in s["any"]
	{
		handleSetting("any", x);
	}
	foreach x in s["pre"]
	{
		handleSetting("pre", x);
	}
	foreach x in s["post"]
	{
		handleSetting("post", x);
	}
	foreach x in s["action"]
	{
		handleSetting("action", x);
	}
	foreach x in s["sharing"]
	{
		if(get_property("auto_allowSharingData").to_boolean())
		{
			handleSetting("sharing", x);
		}
	}
	writeln("<tr><td align=center colspan='3'><input type='submit' name='' value='Save Changes'/></td></tr></table></form>");

	writeln("<table><tr><th>Settings Color Codings</th></tr>");
	writeln("<tr bgcolor=#00ffff><td>Anytime: This setting can be changed at any time and takes effect immediately.</td></tr>");
	writeln("<tr bgcolor=#ffff00><td>Pre: This setting takes effect on the next run that is started with the script.</td></tr>");
	writeln("<tr bgcolor=#00ff00><td>Post: This setting is set by the first run of the script but can be overrode after that. Translation: Run script on day 1, after first adventure, set these however you like.</td></tr>");
	writeln("<tr bgcolor=#af6fbf><td>Action: This causes something to immediately (or when reasonable) happen.</td></tr>");
	if(get_property("auto_allowSharingData").to_boolean())
	{
		writeln("<tr bgcolor=#ff6644><td>Sharing: Allows sharing game data. This causes something to immediately (or when reasonable) happen.</td></tr>");
	}
	writeln("</table>");

	writeln("<br>Handle <a href=\"slascend_quests.php\">Quest Tracker</a><br>");

	writeln("<h2>Banishes</h2>");
	generateTrackingData("auto_banishes", true);

	writeln("<h2>Yellow Rays <img src=\"images/itemimages/eyes.gif\"></h2>");
	generateTrackingData("auto_yellowRays", true);

	writeln("<h2>Sniffing</h2>");
	generateTrackingData("auto_sniffs", true);

	writeln("<h2>Copies</h2>");
	generateTrackingData("auto_copies", true);

	writeln("<h2>Instakills</h2>");
	generateTrackingData("auto_instakill", true);

	writeln("<h2>Eated</h2>");
	generateTrackingData("auto_eaten", false);

	writeln("<h2>Drinkenated</h2>");
	generateTrackingData("auto_drunken", false);

	writeln("<h2>Chewed</h2>");
	generateTrackingData("auto_chewed", false);

	// Don't want to show if they can't make wishes, but maybe they can with pocket wishes
	if(get_property("auto_wishes") != "" || item_amount($item[genie bottle]) > 0)
	{
		writeln("<h2>Wishes</h2>");
		generateTrackingData("auto_wishes", true);
	}

	if(my_class() == $class[Ed])
	{
		writeln("<h2>Lash of the Cobra <img src=\"images/itemimages/cobrahead.gif\"></h2>");
		generateTrackingData("auto_lashes", false);

		writeln("<h2>Talisman of Renenutet <img src=\"images/itemimages/tal_r.gif\"></h2>");
		generateTrackingData("auto_renenutet", false);
	}

	if(my_path() == "One Crazy Random Summer")
	{
		writeln("<h2>One Crazy Random Summer Fun-o-meter!</h2>");
		generateTrackingData("auto_funTracker", true);
	}

	if(!in_hardcore())
	{
		writeln("<h2>Pulls</h2>");
		generateTrackingData("auto_pulls", false);
	}

	writeln("<h2>Other Stuff</h2>");
	generateTrackingData("auto_otherstuff", true);


	writeln("<h2>Info</h2>");
	writeln("Ascension: " + my_ascensions() + "<br>");
	writeln("Day: " + my_daycount() + "<br>");
	writeln("Turns Played: " + my_turncount() + "<br>");
	writeln("Tavern: " + get_property("tavernLayout") + "<br>");
	if(my_class() == $class[Ed])
	{
		writeln("Combats: " + get_property("auto_edCombatCount") + "<br>");
		writeln("Combat Rounds: " + get_property("auto_edCombatRoundCount") + "<br>");
	}
	writeln("Version (auto_ascend): " + svn_info("soolar-auto_ascend-trunk-RELEASE").last_changed_rev + "<br>");

	writeln("</body></html>");
}
