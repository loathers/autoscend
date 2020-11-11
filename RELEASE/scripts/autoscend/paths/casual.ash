boolean inCasual()
{
	if(get_property("_casualAscension").to_int() >= my_ascensions())
	{
		return true;
	}
	return false;
}

boolean inAftercore()
{
	return get_property("kingLiberated").to_boolean();
}

boolean inPostRonin()
{
	//can interact means you are not in ronin and not in hardcore. It returns true in casual, aftercore, and postronin
	if(can_interact() && !inCasual() && !inAftercore())
	{
		return true;
	}
	return false;
}

boolean L8_slopeCasual()
{
	//casual and postronin should mallbuy everything needed to skip this zone
	if(!can_interact())
	{
		return false;	//does not have unrestricted mall access. we are not in casual or postronin
	}
	foreach it in $items[Ninja Carabiner, Ninja Crampons, Ninja Rope,		//ninja climbing gear needed to climb the slope
	eXtreme scarf, eXtreme mittens, snowboarder pants]						//outfit ensures you can reach 5 cold res needed
	{
		if(!buyUpTo(1, it))	//try to buy it or verify we already own it. if fails then do as below
		{
			if(my_meat() < mall_price(it))
			{
				auto_log_info("Can not afford to buy [" +it+ "] to climb the slope. Go do something else", "red");
				return false;
			}
			abort("Mysteriously failed to buy [" +it+ "]. Buy it manually and run me again");
		}
	}
	if(L8_trapperPeak())	//try to unlock peak
	{
		return true;	//successfully finished this part of the quest
	}
	abort("Mysteriously failed to unlock the mountain peak in trapper quest in casual or postronin. please unlock it and run me again");
	return false;
}

boolean LM_canInteract()
{
	//this function is called early once every loop of doTasks() in autoscend.ash to do things when we have unlimited mall access
	//which indicates postronin or casual or aftercore. currently won't get called in aftercore
	
	if(!can_interact())
	{
		return false;
	}
	
	if(get_property("lastEmptiedStorage").to_int() != my_ascensions())
	{
		cli_execute("pull all");
	}
	
	return false;
}
