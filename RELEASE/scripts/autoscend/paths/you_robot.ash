boolean in_robot()
{
	return my_path() == "You, Robot";
}

void robot_initializeSettings()
{
	if(!in_robot())
	{
		return;
	}
	set_property("auto_wandOfNagamar", false);		//wand not used in this path
	set_property("auto_getSteelOrgan", false);		//robots do not have organs
}

boolean LX_robot_get_energy()
{
	//collect energy in the scrap heap. costs 1 adv. gives 25 energy. decreased by 15% per use today.
	//first use each day grants bonus based on number of robot ascensions. to a max of 37
	if(!in_robot())
	{
		return false;
	}
	if(my_adventures() < 1)
	{
		return false;
	}
	int start = get_property("_energyCollected").to_int();
	visit_url("place.php?whichplace=scrapheap&action=sh_getpower");
	if(start + 1 != get_property("_energyCollected").to_int())
	{
		abort("Collect Energy mysteriously failed. Beep Boop.");
	}
	return true;
}

boolean LM_robot()
{
	if(!in_robot())
	{
		return false;
	}
	
	
	
	abort("temporary abort for you robot. will be removed once the LM function is finished");
	return false;
}
