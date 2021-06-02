import <relay_autoscend.ash>

void main()
{
	write_styles();
	writeln("<html><head><title>autoscend extra settings</title>");
	writeln("</head><body><h1>autoscend extra settings</h1>");

	file_to_map("autoscend_settings_extra.txt", s);

	writeln("<br><a href=\"relay_autoscend.php\">Return to main autoscend page</a><br><br>");

	//generate settings table
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
	
	writeln("</body></html>");
}
