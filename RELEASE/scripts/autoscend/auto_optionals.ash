script "auto_optionals.ash"

// All prototypes for this code described in autoscend_header.ash

boolean LX_artistQuest()
{
	if((get_property("auto_doArtistQuest").to_boolean()) && (get_property("questM02Artist") != "finished"))
	{
		if(get_property("questM02Artist") == "unstarted")
		{
			visit_url("place.php?whichplace=town_wrong&action=townwrong_artist_noquest");
			visit_url("place.php?whichplace=town_wrong&action=townwrong_artist_noquest&getquest=1");
			visit_url("place.php?whichplace=town_wrong&action=townwrong_artist_quest");
		}
		if(get_property("questM02Artist") == "started")
		{
			if(item_amount($item[Pretentious Paintbrush]) == 0)
			{
				autoAdv($location[The Outskirts of Cobb\'s Knob]);
			}
			else if(item_amount($item[Pretentious Palette]) == 0)
			{
				autoAdv($location[The Haunted Pantry]);
			}
			else if(item_amount($item[Pail of Pretentious Paint]) == 0)
			{
				autoAdv($location[The Sleazy Back Alley]);
			}
			else
			{
				visit_url("place.php?whichplace=town_wrong&action=townwrong_artist_quest");
			}
			return true;
		}
		else
		{
			auto_log_warning("Failed starting artist quest, rejecting completely.", "red");
			set_property("auto_doArtistQuest", false);
			return false;
		}
	}
	return false;
}

boolean LX_dinseylandfillFunbucks()
{
	if(!get_property("auto_getDinseyGarbageMoney").to_boolean())
	{
		return false;
	}
	if(!elementalPlanes_access($element[stench]))
	{
		return false;
	}
	if(get_property("auto_dinseyGarbageMoney").to_int() == my_daycount())
	{
		return false;
	}
	if((my_adventures() == 0) || (my_level() < 6))
	{
		return false;
	}
	if(item_amount($item[Bag of Park Garbage]) > 0 && !can_interact())
	{
		return dinseylandfill_garbageMoney();
	}
	// Abort if we've already gotten our easy funbucks.
	// If we don't do this, we get stuck in a loop of getting garbage, using it, and doing BARF more.
	if(get_property("_dinseyGarbageDisposed").to_boolean()){
		return false;
	}
	if((my_daycount() >= 3) && (my_adventures() > 5))
	{
		# We do this after the item check since we may have an extra bag and we should turn that in.
		return false;
	}
	buffMaintain($effect[How to Scam Tourists], 0, 1, 1);
	autoAdv(1, $location[Barf Mountain]);
	return true;
}
