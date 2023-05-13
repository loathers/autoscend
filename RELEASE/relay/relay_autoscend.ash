import <autoscend.ash>

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
		string checked = "";
		if(get_property(set.name) == "true")
		{
			checked = " checked";
		}
		write("<tr bgcolor="+color+"><td align=center>"+set.name+"</td><td align=center>"
				+ "<input type='checkbox' name='"+set.name+"' value='true'"+checked+">");
		writeln("</td><td>"+set.description+"</td></tr>");
		break;
	default:
		writeln("<tr bgcolor="+color+"><td align=center>"+set.name+"</td><td><input type='text' name='"+set.name+"' value='"+get_property(set.name)+"' /></td><td>"+set.description+"</td></tr>");
		break;
	}
	writeln("<input type='hidden' name='"+set.name+"_oldvalue' value='"+get_property(set.name)+"' />");
}

void generateTrackingData(string tracked)
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
		matcher cheat = create_matcher("CHEAT CODE:", tracking[x]);
		tracking[x] = replace_all(cheat, "CHEAT CODE -");
		string[int] current = split_string(tracking[x], ":");
		int curDay = to_int(current[0]);
		if(curDay > day)
		{
			day = curDay;
			if(day > 1)
			{
				writeln("<br><br>");
			}
			writeln("Day " + day + ": ");
		}
		string toWrite = "(";
		for i from 1 to count(current) - 1
		{
			toWrite = toWrite + current[i];
			if (i != count(current) - 1)
			{
				toWrite = toWrite + ":";
			}
		}
		toWrite = toWrite + "),";
		writeln(toWrite);
	}
}

void write_familiar()
{
	//display current 100% familiar. and options related to it.
	familiar hundred_fam = to_familiar(get_property("auto_100familiar"));
	string to_write;
	if(hundred_fam != $familiar[none])			//we already have a 100% familiar set for this ascension
	{
		if(turns_played() == 0)
		{
			to_write = "100% familiar is set to = " +hundred_fam+ ". Turns played is at 0 so it might be possible to change this. So long as you have not done any free fights<br>";
			writeln(to_write);
			writeln("<form action='' method='post'>");
			writeln("<input type='hidden' name='auto_100familiar' value='none'/>");
			writeln("<input type='submit' name='' value='Disable 100% familiar run'/></form>");
		}
		else
		{
			to_write = "100% familiar is set to = " +hundred_fam+ "<br>";
			writeln(to_write);
		}
	}
	else										//100% familiar not set.
	{
		if(turns_played() == 0)
		{
			writeln("100% familiar has not been set. Turns played is at 0 so it might be possible to change this. So long as you have not done any free fights<br>");
			writeln("<form action='' method='post'>");
			writeln("<input type='hidden' name='auto_100familiar' value='" +my_familiar()+ "'/>");
			writeln("<input type='submit' name='' value='Set current familiar as 100% target'/></form>");
		}
		//we could use an else to report that we are not in a 100% familiar run and it is too late to change it. but there is no need to.
	}
}

void write_settings_key()
{
	//display the key to the settings table.
	writeln("<table><tr><th>Settings Color Codings</th></tr>");
	writeln("<tr bgcolor=#00ffff><td>Anytime: This setting can be changed at any time and takes effect immediately.</td></tr>");
	writeln("<tr bgcolor=#ffff00><td>Pre: Next time we initialize settings for autoscend this will be used to determine what we should set some Post type settings to.</td></tr>");
	writeln("<tr bgcolor=#00ff00><td>Post: settings for current ascension. Automatically reconfigured each ascension when we initialize setting for that ascension. After settings have been initialized you may change this. Under some circumstances they will be automatically changed mid ascension</td></tr>");
	writeln("<tr bgcolor=#af6fbf><td>Action: This causes something to immediately (or when reasonable) happen.</td></tr>");
	writeln("<tr bgcolor=#ff6644><td>Sharing: Allows sharing game data.</td></tr>");
	writeln("</table>");
}

void main()
{
	auto_settings();			//runs every time. upgrades old settings to newest format, delete obsolete settings, and configures defaults.
	initializeSettings();		//runs once per ascension. should not handle anything other than intialising settings for this ascension.
	
	write_styles();
	writeln("<html><head><title>autoscend manager</title>");
	writeln("</head><body><h1>autoscend manager</h1>");

	//button to interrupt script
	writeln("<form action='' method='post'>");
	writeln("<input type='hidden' name='auto_interrupt' value='true'/>");
	writeln("<input type='hidden' name='auto_interrupt_oldvalue' value='false'/>");
	writeln("<input type='submit' name='' value='Safely Stop Autoscend'/></form>");
	
	//TODO add button to run autoscend
	
	write_familiar();		//display current 100% familiar. and options related to it.
	
	if(my_ascensions() == get_property("auto_doneInitialize").to_int())
	{
		writeln("Settings have been initialized for current ascension. You may change Post type settings<br>");
	}
	else
	{
		writeln("Settings have not been initialized for current ascension. Do not change Post type settings<br>");
	}
	
	writeln("<br><a href=\"autoscend_settings_extra.php\">For extra settings click here</a><br><br>");

	//generate settings table
	file_to_map("autoscend_settings.txt", s);
	boolean dickstab = false;	//used to detect if we just enabled dickstab
	fields = form_fields();
	if(count(fields) > 0)
	{
		foreach x in fields
		{
			//Checkboxes that are false are not supplied, so we have to look at the *_oldvalue
			//fields to see whether there is a "false" checkbox we're not seeing.  So, ignore
			//the fields that don't end in _ignore.
			if(! contains_text(x, "_oldvalue"))
			{
				continue;
			}
			
			//Recover name of property and its value.
			//If new value field doesn't exist, it's a "false" checkbox
			string prop = substring(x, 0, length(x)-9);
			string newSetting = fields[prop];
			if(! (fields contains prop)) 
			{
				//writeln("Empty checkbox for " + prop + "<br>");
				newSetting = "false";
			}

			string oldSetting = form_field(x);
			if(oldSetting == newSetting)
			{
				if(get_property(prop) != newSetting)
				{
					writeln("You did not change setting " + prop + ". It changed since you last loaded the page, ignoring.<br>");
				}
				continue;
			}
			if(get_property(prop) != newSetting)
			{
				writeln("Changing setting " + prop + " to " + newSetting + "<br>");
				set_property(prop, newSetting);
			}
			
			if(prop == "auto_dickstab")	//used to detect if we just enabled dickstab
			{
				if((newSetting != get_property("auto_dickstab")) && (newSetting == "true"))
				{
					dickstab = true;
				}
			}
		}
	}

	if(dickstab)
	{
		writeln("auto_dickstab was just set to true<br>");
		writeln("Your warranty has been declared void.<br>");
		writeln("Togging incompatible settings. You can re-enabled them here if you so desire. This resetting only takes effect upon setting auto_dickstab to true.<br><br>");
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
		handleSetting("sharing", x);
	}
	writeln("<tr><td align=center colspan='3'><input type='submit' name='' value='Save Changes'/></td></tr></table></form>");

	write_settings_key();		//display the key to the settings table

	writeln("<h2>Banishes</h2>");
	generateTrackingData("auto_banishes");

	writeln("<h2>Free Runaways</h2>");
	generateTrackingData("auto_freeruns");

	writeln("<h2>Yellow Rays <img src=\"images/itemimages/eyes.gif\"></h2>");
	generateTrackingData("auto_yellowRays");

	writeln("<h2>Sniffing</h2>");
	generateTrackingData("auto_sniffs");

	writeln("<h2>Copies</h2>");
	generateTrackingData("auto_copies");

	writeln("<h2>Replaces</h2>");
	generateTrackingData("auto_replaces");

	writeln("<h2>Instakills</h2>");
	generateTrackingData("auto_instakill");
	
	writeln("<h2>Beaten Up</h2>");
	writeln(get_property("auto_beatenUpLocations"));

	writeln("<h2>Forced Noncombats</h2>");
	generateTrackingData("auto_forcedNC");

	writeln("<h2>Eated</h2>");
	generateTrackingData("auto_eaten");

	writeln("<h2>Drinkenated</h2>");
	generateTrackingData("auto_drunken");

	writeln("<h2>Chewed</h2>");
	generateTrackingData("auto_chewed");

	// Don't want to show if they can't make wishes, but maybe they can with pocket wishes
	if(get_property("auto_wishes") != "" || item_amount($item[genie bottle]) > 0)
	{
		writeln("<h2>Wishes</h2>");
		generateTrackingData("auto_wishes");
	}

	if(isActuallyEd())
	{
		writeln("<h2>Lash of the Cobra <img src=\"images/itemimages/cobrahead.gif\"></h2>");
		generateTrackingData("auto_lashes");

		writeln("<h2>Talisman of Renenutet <img src=\"images/itemimages/tal_r.gif\"></h2>");
		generateTrackingData("auto_renenutet");
	}

	if(in_ocrs())
	{
		writeln("<h2>One Crazy Random Summer Fun-o-meter!</h2>");
		generateTrackingData("auto_funTracker");
	}

	if(!in_hardcore())
	{
		writeln("<h2>Pulls</h2>");
		generateTrackingData("auto_pulls");
	}

	if (auto_hasPowerfulGlove())
	{
		writeln("<h2>Powerful Glove</h2>");
		generateTrackingData("auto_powerfulglove");
	}

	writeln("<h2>Other Stuff</h2>");
	generateTrackingData("auto_otherstuff");

	writeln("<h2>Info</h2>");
	writeln("Ascension: " + my_ascensions() + "<br>");
	writeln("Day: " + my_daycount() + "<br>");
	writeln("Turns Played: " + my_turncount() + "<br>");
	writeln("Tavern: " + get_property("tavernLayout") + "<br>");
	if(isActuallyEd())
	{
		writeln("Combats: " + get_property("auto_edCombatCount") + "<br>");
		writeln("Combat Rounds: " + get_property("auto_edCombatRoundCount") + "<br>");
	}

	//TODO: need way to track version independent of svn branch since you can have different branches checked out
	writeln("Autoscend Version: " + autoscend_current_version() + "<br>");

	writeln("<br>");
	writeln("</body></html>");
}
