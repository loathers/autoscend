boolean in_small()
{
	return my_path() == $path[A Shrunken Adventurer Am I];
}

void small_initializeSettings()
{
	if(!in_small())
	{
		return;
	}
	set_property("auto_wandOfNagamar", true);		//wand  used in this path
	set_property("auto_getBeehive", true);			//wall is too difficult without it
	set_property("auto_getBoningKnife", true);		//wall is too difficult without it
	set_property("auto_getSteelOrgan", false);		//can only consume size 1 drinks
	if(in_hardcore())
	{
		//having vastly lower stats and no easy solutions in hardcore means you always die from flyering
		//should be replaced with a more elegant solution where detailed estimation / calculation is done.
		//set_property("auto_ignoreFlyer", true);

		//cap ML to 50 to help avoid getting beaten up
		int MLCap = 50;
		string MLSafetyLimit = get_property("auto_MLSafetyLimit");
		if(MLSafetyLimit == "")
		{
			set_property("auto_MLSafetyLimitBackup","empty");
			set_property("auto_MLSafetyLimit",MLCap);
		}
		if(MLSafetyLimit.to_int() > MLCap)
		{
			// record existing MLSafetyLimit so it can be restored at end of run
			set_property("auto_MLSafetyLimitBackup",MLSafetyLimit);
			set_property("auto_MLSafetyLimit",MLCap);
		}

		// don't disregard instant karma either. Helps keep ML low
		string disregardKarma = get_property("auto_disregardInstantKarma");
		if(disregardKarma == "true")
		{
			set_property("auto_disregardInstantKarmaBackup","true");
			set_property("auto_disregardInstantKarma", "false");
		}
	}
}

void auto_SmallPulls()
{
	if(!in_small())
	{
		return;
	}
	// small path ignores stat requirements for gear so can pull high end stuff
	// attempt to pull seal clubber dread hat
	if(my_class() == $class[Seal Clubber])
	{
		pullXWhenHaveY($item[Great Wolf\'s headband], 1, 0);
	}
	// if can't get clubber dread hat (not SC or don't have it), then get nurse's hat
	if(item_amount($item[Great Wolf\'s headband]) == 0)
	{
		pullXWhenHaveY($item[nurse\'s hat], 1, 0);
	}
	// pull sea salt scrubs in small path if aware of torso
	if(hasTorso())
	{
		pullXWhenHaveY($item[Sea salt scrubs], 1, 0);
	}

}

boolean auto_smallCampgroundGear()
{
	if(!in_small())
	{
		return false;
	}

	// don't get campground gear in in Normal and haven't gotten beaten up
	int beatenUpCount = get_property("auto_beatenUpCount").to_int();
	if(!in_hardcore() && beatenUpCount == 0)
	{
		return false;
	}

	boolean [item] dirtGear = $items[mesquito proboscis, ncle leg, rutabuga bag, senate fly thorax];
	boolean [item] tallGrassGear = $items[birdybug antenna, daddy shortlegs leg, kilopede skull];
	boolean [item] veryTallGrassGear = $items[beetle antenna, mantis skull, spider leg];
	boolean haveGear(boolean [item] gear)
	{
		foreach it in gear
		{
			if(item_amount(it) == 0 && !have_equipped(it))
			{
				return false;
			}
		}
		return true;
	}

	// get drops from dirt if we can survive at least 2 rounds of getting hit
	// always get dirt drops in HC small
	if(!haveGear(dirtGear))
	{
		return autoAdv($location[Fight in the Dirt]);
	}
	// get tall grass drops if we have gotten beaten up and can survive at least 2 rounds of getting hit
	else if(beatenUpCount > 0 && !haveGear(tallGrassGear) && (my_maxhp() > expected_damage($monster[kilopede]) * 2))
	{
		return autoAdv($location[Fight in the Tall Grass]);
	}

/*
	// monsters here need spading. Don't know details of how they scale. Uncomment when mafia gets this info
	// get tall grass drops if we have gotten beaten up twice and can survive at least 2 rounds of getting hit
	else if(beatenUpCount > 0 && !haveGear(veryTallGrassGear) && (my_maxhp() > expected_damage($monster[flagellating mantis]) * 2))
	{
		return autoAdv($location[Fight in the Very Tall Grass]);
	}
*/
	return false;
}
