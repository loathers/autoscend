boolean in_ag()
{
	return my_path() == $path[Avant Guard];
}

void ag_initializeSettings()
{
	if(in_ag())
	{
		set_property("auto_100familiar", "Burly Bodyguard");
		set_property("auto_skipNuns", true);
	}
}

void ag_pulls()
{
	if(in_ag())
	{
		//SUPER helpful for gremlins
		if(storage_amount($item[mini kiwi invisible dirigible]) > 0 && auto_is_valid($item[mini kiwi invisible dirigible]))
		{
			pullXWhenHaveY($item[mini kiwi invisible dirigible], 1, 0);
		}
	}
}

void ag_bgChat()
{
	if(!in_ag())
	{
		return;
	}
	string bgChat = visit_url("main.php?talktobg=1");
	location place = my_location();
	monster mon;
	if(contains_text(bgChat, "Chatting with your Burly Bodyguard"))
	{
		switch(place)
		{
			case $location[Whitey's Grove]:
				if(item_amount($item[Wet Stunt Nut Stew]) == 0)
				{
					if(item_amount($item[Bird Rib]) == 0)
					{
						mon = $monster[whitesnake];
					}
					else if(item_amount($item[Lion Oil]) == 0)
					{
						mon = $monster[White Lion];
					}
					else if(item_amount($item[Stunt Nuts]) == 0)
					{
						mon = $monster[Bob Racecar];
					}
					else
					{
						mon = $monster[Knight in White Satin];
					}
					break;
				}
			case $location[Cobb's Knob Harem]:
				if(!have_outfit("Knob Goblin Harem Girl Disguise"))
				{
					mon = $monster[Knob Goblin Harem Girl];
					break;
				}
			default:
				mon = $monster[Knob Goblin Harem Girl];
				break;
		}
		auto_log_info("Making the next bodyguard a " + mon.to_string(), "blue");
		run_choice(1, "bgid=" + mon.id);
	}
}