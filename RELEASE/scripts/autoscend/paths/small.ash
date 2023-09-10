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
		set_property("auto_ignoreFlyer", true);

		//cap ML to 50 to help avoid getting beaten up
		int MLCap = 50;
		string MLSafetyLimit = get_property("auto_MLSafetyLimit");
		if (MLSafetyLimit == "" || MLSafetyLimit.to_int() > MLCap)
		{
			// record existing MLSafetyLimit so it can be restored at end of run
			set_property("auto_MLSafetyLimitBackup",MLSafetyLimit);
			set_property("auto_MLSafetyLimit",MLCap);
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
