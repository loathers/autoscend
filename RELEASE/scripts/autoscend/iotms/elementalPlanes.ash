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
			auto_log_info("Trying to avoid Guest Sustenance Assurance Dinseylandfill job.", "blue");
			foreach job in jobs
			{
				int newAt = index_of(page, job, at);
				if(newAt != -1)
				{
					auto_log_info("Found new job option: " + job, "blue");
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
			auto_log_info("Found bucket " + bucket.group(1) + ".", "blue");
			int i = 0;
			foreach job in jobs
			{
				i = i + 1;
				if((bucket.group(1) == job) && (i > best))
				{
					auto_log_info("Considering job " + job, "blue");
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
