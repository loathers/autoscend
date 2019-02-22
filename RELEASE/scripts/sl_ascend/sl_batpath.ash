script "sl_batpath.ash"

void bat_initializeSettings()
{
	if(my_path() == "Dark Gyffte")
	{
		set_property("sl_100familiar", $familiar[Egg Benedict]);
		set_property("sl_cubeItems", false);
		set_property("sl_getSteelOrgan", false);
		set_property("sl_grimstoneFancyOilPainting", false);
		set_property("sl_grimstoneOrnateDowsingRod", false);
		set_property("sl_useCubeling", false);
		set_property("sl_wandOfNagamar", false);
	}
}

int bat_maxHPCost(skill sk)
{
	switch(sk)
	{
		case $skill[Baleful Howl]:
		case $skill[Intimidating Aura]:
		case $skill[Mist Form]:
		case $skill[Sharp Eyes]:
			return 30;
		case $skill[Madness of Untold Aeons]:
			return 25;
		case $skill[Crush]:
		case $skill[Wolf Form]:
		case $skill[Blood Spike]:
		case $skill[Blood Cloak]:
		case $skill[Macabre Cunning]:
		case $skill[Piercing Gaze]:
		case $skill[Ensorcel]:
		case $skill[Flock of Bats Form]:
			return 20;
		case $skill[Ceaseless Snarl]:
		case $skill[Preternatural Strength]:
		case $skill[Blood Chains]:
		case $skill[Sanguine Magnetism]:
		case $skill[Perceive Soul]:
		case $skill[Sinister Charm]:
		case $skill[Batlike Reflexes]:
		case $skill[Spot Weakness]:
			return 15;
		case $skill[Savage Bite]:
		case $skill[Ferocity]:
		case $skill[Chill of the Tomb]:
		case $skill[Spectral Awareness]:
			return 10;
		case $skill[Flesh Scent]:
		case $skill[Hypnotic Eyes]:
			return 5;
		default:
			return 0;
	}
}

// to be called when already in Torpor
skill [int] bat_pickSkills(int hpLeft)
{
	int costSoFar = 0;
	int baseHP = 20 * get_property("darkGyfftePoints").to_int() + my_basestat($stat[Muscle]) + 23;
	skill [int] picks;

	boolean addPick(skill sk)
	{
		if(baseHP - costSoFar - bat_maxHPCost(sk) < hpLeft)
			return false;
		costSoFar += bat_maxHPCost(sk);
		picks[picks.count()] = sk;
		return true;
	}

	return picks;
}

boolean bat_shouldEnsorcel(monster m)
{
	if(my_class() != $class[Vampyre] || !sl_have_skill($skill[Ensorcel]))
		return false;

	// need a way to determine what the current ensorcelee is first...
	return false;
}

boolean bat_consumption()
{
	if(my_class() != $class[Vampyre])
		return false;

	boolean consume_first(boolean [item] its)
	{
		foreach it in its
		{
			if(creatable_amount(it) > 0)
			{
				create(1, it);
				if(it.fullness > 0)
					eat(1, it);
				else if(it.inebriety > 0)
					drink(1, it);
				else if(it.spleen > 0)
					chew(1, it);
				else
				{
					print("Woah, I made a " + it + " to consume, but you can't consume that?", "red");
					return false;
				}
				return true;
			}
		}
		return false;
	}

	while(item_amount($item[blood bag]) > 0 && my_fullness() < fullness_limit())
	{
		// don't auto consume bloodstick, only eat those if we're down to one adventure AFTER booze
		if(!consume_first($items[blood-soaked sponge cake, blood roll-up, blood snowcone, actual blood sausage, ]))
			break;
	}

	while(item_amount($item[blood bag]) > 0 && my_inebriety() < inebriety_limit())
	{
		// don't auto consume bottle of Sanguiovese, only drink those if we're down to one adventure
		if(!consume_first($items[vampagne, dusty bottle of blood, Red Russian, mulled blood]))
			break;
	}

	if(my_adventures() <= 1)
	{
		consume_first($items[bloodstick, bottle of Sanguiovese]);
	}

	return true;
}
