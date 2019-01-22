script "cc_zlib.ash"

/*
	This is a snippet of the zlib script, to provide the process_kmail function only (as cc_process_kmail to avoid conflicts)
*/



/******************************************************************************
                                  ZLib
                    supporting functions for scripts
*******************************************************************************

   Want to say thanks?  Send me (Zarqon) a bat! (Or bat-related item)

   For a list of included functions, check out
   http://kolmafia.us/showthread.php?t=2072

******************************************************************************/

/*
//Now defined in cc_ascend_header.ash
record kmailObject
{
	int id;                   // message id
	string type;              // possible values observed thus far: normal, giftshop
	int fromid;               // sender\'s playerid (0 for npcs)
	int azunixtime;           // KoL server\'s unix timestamp
	string message;           // message (not including items/meat)
	int[item] items;          // items included in the message
	int meat;                 // meat included in the message
	string fromname;          // sender\'s playername
	string localtime;         // your local time according to your KoL account, human-readable string
};
*/
void cc_process_kmail(string functionname)
{
	// calls a function designed to parse a kmail.  It must accept a single kmailObject parameter,
	// and return a boolean -- true if it wants the kmail to be deleted afterwards
	kmailObject[int] mail;

	//heeheehee\'s JSON matcher: loads all of your inbox (up to 100) into the "mail"
	string page = visit_url("api.php?pwd&what=kmail&count=100&for="+url_encode("ZLib(modified)-powered-script"));
	matcher k = create_matcher('"id":"(\\d+)","type":"(.+?)","fromid":"(-?\\d+)","azunixtime":"(\\d+)","message":"(.+?)","fromname":"(.+?)","localtime":"(.+?)"', page);
	int n;
	while(k.find())
	{
		n = count(mail);
		mail[n].id = to_int(k.group(1));
		mail[n].type = k.group(2);
		mail[n].fromid = to_int(k.group(3));
		mail[n].azunixtime = to_int(k.group(4));
		matcher mbits = create_matcher("(.*?)\\<center\\>(.+?)$",k.group(5).replace_string("\\'","'"));
		if(mbits.find())
		{
			mail[n].meat = extract_meat(mbits.group(2));
			mail[n].items = extract_items(mbits.group(2));
			mail[n].message = mbits.group(to_int(mail[n].meat > 0 || count(mail[n].items) > 0));
		}
		else
		{
			mail[n].message = k.group(5);
		}
		mail[n].fromname = k.group(6);
		mail[n].localtime = replace_string(k.group(7),"\\","");
	}

	boolean[int] processed;
	foreach i,m in mail
	{
		if(call boolean functionname(m))
		{
			processed[m.id] = true;
			remove mail[i];
		}
	}

	//delete successfully processed mail
	if(count(processed) > 0)
	{
		print("Deleting processed mail...", "blue");
		string del = "messages.php?the_action=delete&box=Inbox&pwd";
		foreach k in processed
		{
			del += "&sel"+k+"=on";
		}
		del = visit_url(del);
		if(contains_text(del,count(processed)+" message"+(count(processed) > 1 ? "s" : "")+" deleted."))
		{
			print(count(processed)+" message"+(count(processed) > 1 ? "s" : "")+" deleted.", "blue");
		}
		else
		{
			print("There was a problem deleting the processed mail.  Check your inbox.", "red");
		}
	}
}
