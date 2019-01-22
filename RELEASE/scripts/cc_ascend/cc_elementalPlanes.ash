script "cc_elementalPlanes.ash"

boolean getDiscoStyle();
boolean getDiscoStyle(int choice);
item[element] getCharterIndexable();
boolean elementalPlanes_initializeSettings();
boolean elementalPlanes_access(element ele);
boolean elementalPlanes_takeJob(element ele);
boolean dinseylandfill_garbageMoney();
boolean volcano_bunkerJob();
boolean volcano_lavaDogs();			//See code before using this!


item[element] getCharterIndexable()
{
	item[element] charters;
	charters[$element[cold]] = $item[Airplane Charter: The Glaciest];
	charters[$element[hot]] = $item[Airplane Charter: That 70s Volcano];
	charters[$element[sleaze]] = $item[Airplane Charter: Spring Break Beach];
	charters[$element[spooky]] = $item[Airplane Charter: Conspiracy Island];
	charters[$element[stench]] = $item[Airplane Charter: Dinseylandfill];
	return charters;
}

boolean elementalPlanes_initializeSettings()
{
	string temp = "";
	item[element] charters = getCharterIndexable();

	if(!get_property("sleazeAirportAlways").to_boolean() && is_unrestricted(charters[$element[sleaze]]))
	{
		temp = visit_url("place.php?whichplace=airport_sleaze&intro=1");
		if(contains_text(temp, "you take a short, turbulence-free flight to Spring Break Beach."))
		{
			print("We have access to Spring Break Beach. Woo.", "green");
			set_property("sleazeAirportAlways", true);
		}
	}

	if(!get_property("spookyAirportAlways").to_boolean() && is_unrestricted(charters[$element[spooky]]))
	{
		temp = visit_url("place.php?whichplace=airport_spooky&intro=1");
		if(contains_text(temp, "Your flight to Conspiracy Island is nasty, brutish and short."))
		{
			print("We have access to Conspiracy Island. Boo.", "green");
			set_property("spookyAirportAlways", true);
		}
	}

	if(!get_property("stenchAirportAlways").to_boolean() && is_unrestricted(charters[$element[stench]]))
	{
		temp = visit_url("place.php?whichplace=airport_stench&intro=1");
		if(contains_text(temp, "You get in line with the thousands of other passengers bound for Dinseylandfill."))
		{
			print("We have access to Dinseylandfill. Eww.", "green");
			set_property("stenchAirportAlways", true);
		}
	}

	if(!get_property("hotAirportAlways").to_boolean() && is_unrestricted(charters[$element[hot]]))
	{
		temp = visit_url("place.php?whichplace=airport_hot&intro=1");
		if(contains_text(temp, "After a convenient, comfortable and dignified ticketing and boarding process"))
		{
			print("We have access to That 70s Volcano. Groovy.", "green");
			set_property("hotAirportAlways", true);
		}
	}

	if(!get_property("coldAirportAlways").to_boolean() && is_unrestricted(charters[$element[cold]]))
	{
		temp = visit_url("place.php?whichplace=airport_cold&intro=1");
		if(contains_text(temp, "The local temperature is about a million degrees below zero"))
		{
			print("We can go to The Glaciest. Great prices everyday!", "green");
			set_property("coldAirportAlways", true);
		}
	}
	return true;
}


boolean elementalPlanes_access(element ele)
{
	item[element] charters = getCharterIndexable();
	return get_property(ele + "AirportAlways").to_boolean() && is_unrestricted(charters[ele]);
}

boolean elementalPlanes_takeJob(element ele)
{
	if(!elementalPlanes_access(ele))
	{
		return false;
	}

	if((ele == $element[spooky]) && elementalPlanes_access(ele))
	{
		visit_url("place.php?whichplace=airport_spooky&action=airport2_radio");
		visit_url("choice.php?pwd&whichchoice=984&option=1", true);
		return true;
	}
	else if((ele == $element[stench]) && elementalPlanes_access(ele))
	{
		string page = visit_url("place.php?whichplace=airport_stench&action=airport3_kiosk");
		int choice = 1;
		int at = index_of(page, "Available Assignments");
		if(at == -1)
		{
			return false;
		}

		int sustenance = index_of(page, "Guest Sustenance Assurance", at);
		boolean[string] jobs = $strings[Racism Reduction, Compulsory Fun, Waterway Debris Removal, Bear Removal, Electrical Maintenance, Track Maintenance, Sexism Reduction];

		if(sustenance != -1)
		{
			print("Trying to avoid Guest Sustenance Assurance Dinseylandfill job.", "blue");
			foreach job in jobs
			{
				int newAt = index_of(page, job, at);
				if(newAt != -1)
				{
					print("Found new job option: " + job, "blue");
					if(newAt < sustenance)
					{
						choice = 1;
					}
					else
					{
						choice = 2;
					}
				}
			}
		}

		visit_url("choice.php?pwd=&whichchoice=1066&option=" + choice,true);
		return true;
	}
	else if((ele == $element[cold]) && elementalPlanes_access(ele))
	{
		if(get_property("_walfordQuestStartedToday").to_boolean())
		{
			return false;
		}

		string page = visit_url("place.php?whichplace=airport_cold&action=glac_walrus");

		matcher bucket = create_matcher("I'll get you some (\\w+)", page);

		int choice = 0;
		int best = 0;

		boolean[string] jobs = $strings[balls, blood, bolts, chum, ice, milk, moonbeams, chicken, rain];
		int at = 1;
		while(bucket.find())
		{
			at = at + 1;
			print("Found bucket " + bucket.group(1) + ".", "blue");
			int i = 0;
			foreach job in jobs
			{
				i = i + 1;
				if((bucket.group(1) == job) && (i > best))
				{
					print("Considering job " + job, "blue");
					best = i;
					choice = at;
				}
			}
		}

		visit_url("choice.php?pwd=&whichchoice=1114&option=" + choice,true);
		return true;
	}
	return false;
}



boolean dinseylandfill_garbageMoney()
{
	if(!elementalPlanes_access($element[stench]))
	{
		return false;
	}
	if(get_property("_dinseyGarbageDisposed").to_boolean())
	{
		return false;
	}
	if(!get_property("cc_getDinseyGarbageMoney").to_boolean())
	{
		return false;
	}
	if(item_amount($item[Bag of Park Garbage]) > 0)
	{
		visit_url("place.php?whichplace=airport_stench&action=airport3_tunnels");
		visit_url("choice.php?pwd=&whichchoice=1067&option=6",true);
		visit_url("main.php");
		cli_execute("refresh inv");
		return true;
	}
	else
	{
		return false;
	}

	return false;
}

boolean getDiscoStyle(int choice)
{
	if(getDiscoStyle())
	{
		visit_url("place.php?whichplace=airport_hot&action=airport4_zone1");
		run_choice(choice);
		return true;
	}
	return false;
}

boolean getDiscoStyle()
{
	if(!elementalPlanes_access($element[hot]))
	{
		return false;
	}
	if(get_property("_infernoDiscoVisited").to_boolean())
	{
		return false;
	}

	if(item_amount($item[Smooth Velvet Hanky]) > 0)
	{
		equip($slot[acc1], $item[Smooth Velvet Hanky]);
	}
	if(item_amount($item[Smooth Velvet Pocket Square]) > 0)
	{
		equip($slot[acc2], $item[Smooth Velvet Pocket Square]);
	}
	if(item_amount($item[Smooth Velvet Socks]) > 0)
	{
		equip($slot[acc3], $item[Smooth Velvet Socks]);
	}
	if(item_amount($item[Smooth Velvet Hat]) > 0)
	{
		equip($item[Smooth Velvet Hat]);
	}
	if(item_amount($item[Smooth Velvet Pants]) > 0)
	{
		equip($item[Smooth Velvet Pants]);
	}
	if(item_amount($item[Smooth Velvet Shirt]) > 0)
	{
		equip($item[Smooth Velvet Shirt]);
	}
	else if(item_amount($item[Smooth Velvet Bra]) > 0)
	{
		equip($item[Smooth Velvet Bra]);
	}
	return true;
}

boolean volcano_lavaDogs()
{
	# This function expects calderaVolcoino to be set with we hit the Lava Dogs adventure.
	# We will check the queue and set it ourselves as a backup but that is not full-proof.
	# This is not a concern on the author\'s side but is a warning to anyone who uses this.
	if(!elementalPlanes_access($element[hot]))
	{
		return false;
	}
	if(!(cc_get_campground() contains $item[Haunted Doghouse]))
	{
		return false;
	}

	if($location[The Bubblin\' Caldera].turns_spent >= 15)
	{
		print("Could not find Caldera Volcoino... uh oh...", "red");
		return false;
	}

	if(!get_property("calderaVolcoino").to_boolean())
	{
		if(contains_text($location[The Bubblin\' Caldera].noncombat_queue, "Lava Dogs"))
		{
			set_property("calderaVolcoino", true);
			return false;
		}

		//If we have instant kill effects, we do not want to use them. They are just wasted here.
		//Or if we have free wanderers....
		ccAdv($location[The Bubblin\' Caldera]);

		if(get_property("lastAdventure") == "Lava Dogs")
		{
			set_property("calderaVolcoino", true);
			return false;
		}
		return true;
	}
	return false;
}

boolean volcano_bunkerJob()
{
	if(!elementalPlanes_access($element[hot]))
	{
		return false;
	}
	if(get_property("_volcanoItemRedeemed").to_boolean())
	{
		return false;
	}
	if(get_property("_volcanoItem1").to_int() == 0)
	{
		string temp = visit_url("place.php?whichplace=airport_hot&action=airport4_questhub");
	}

	int ticketValue = cc_mall_price($item[One-Day Ticket To That 70s Volcano]) / 3;
	int option = 0;
	int optionCost = 999999999;

	foreach goal in $strings[_volcanoItem1, _volcanoItem2, _volcanoItem3]
	{
		int index = substring(goal, 12).to_int();
		item it = to_item(get_property("_volcanoItem" + index).to_int());
		int currentCost = 999999999;
		if($items[Gooey Lava Globs, New Age Healing Crystal, SMOOCH Bottlecap, Superduperheated Metal] contains it)
		{
			currentCost = cc_mall_price(it) * get_property("_volcanoItemCount" + index).to_int();
		}
		else if(it == $item[Smooth Velvet Bra])
		{
			currentCost = 3 * cc_mall_price($item[Unsmoothed Velvet]) * get_property("_volcanoItemCount" + index).to_int();
		}
		else if(it == $item[SMOOCH Bracers])
		{
			currentCost = 5 * cc_mall_price($item[Superheated Metal]) * get_property("_volcanoItemCount" + index).to_int();
		}

		if(currentCost < optionCost)
		{
			optionCost = currentCost;
			option = index;
		}
	}


	if((option != 0) && ((optionCost * 1.5) < ticketValue))
	{
		item it = to_item(get_property("_volcanoItem" + option).to_int());
		if($items[Gooey Lava Globs, New Age Healing Crystal, SMOOCH Bottlecap, Superduperheated Metal] contains it)
		{
			buy(get_property("_volcanoItemCount" + option).to_int(), it, cc_mall_price(it)*2);
		}
		else if(it == $item[Smooth Velvet Bra])
		{
			buy(get_property("_volcanoItemCount" + option).to_int() * 3, $item[Unsmoothed Velvet], cc_mall_price($item[Unsmoothed Velvet])*2);
			cli_execute("make 3 " + it);
		}
		else if(it == $item[SMOOCH Bracers])
		{
			buy(get_property("_volcanoItemCount" + option).to_int() * 5, $item[Superheated Metal], cc_mall_price($item[Superheated Metal])*2);
			cli_execute("make 3 " + it);
		}


		string temp = visit_url("place.php?whichplace=airport_hot&action=airport4_questhub");
		run_choice(option);
		return true;
	}
	return false;
}




