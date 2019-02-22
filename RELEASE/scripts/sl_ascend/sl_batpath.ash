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

void bat_initializeDay(int day)
{
	if(my_path() == "Dark Gyffte")
	{
		set_property("sl_bat_bloodBank", 0); // 0: no blood yet, 1: base blood, 2: intimidating blood
		set_property("sl_bat_ensorcels", 0);
		set_property("sl_bat_howls", 0);
		set_property("sl_bat_howled", "");
		bat_reallyPickSkills(20);
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

int bat_baseHP()
{
	return 20 * get_property("darkGyfftePoints").to_int() + my_basestat($stat[Muscle]) + 20;
}

int bat_remainingBaseHP()
{
	int baseHP = bat_baseHP();
	foreach sk in $skills[]
	{
		// important that this uses have_skill and not sl_have_skill, as sl_have_skill would
		// report incorrectly if any form intrinsics are active
		if(have_skill(sk))
			baseHP -= bat_maxHPCost(sk);
	}
	return baseHP;
}

// to be called when already in Torpor
skill [int] bat_pickSkills(int hpLeft)
{
	int costSoFar = 0;
	int baseHP = bat_baseHP();
	skill [int] picks;

	boolean addPick(skill sk)
	{
		if(baseHP - costSoFar - bat_maxHPCost(sk) < hpLeft)
			return false;
		costSoFar += bat_maxHPCost(sk);
		picks[picks.count()] = sk;
		return true;
	}

	if(get_property("sl_bat_bloodBank") != "2")
		addPick($skill[Intimidating Aura]);

	// no forms JUST yet
	foreach sk in $skills[
		Chill of the Tomb,
		Blood Chains,
		Madness of Untold Aeons,
		Sinister Charm,
		Spot Weakness,
		Preternatural Strength,
		Blood Cloak,
		Baleful Howl,
		Perceive Soul,
		Ensorcel,
		Sharp Eyes,
		Batlike Reflexes,
		Sanguine Magnetism,
		Macabre Cunning,
		Ferocity,
		Flesh Scent,
		Savage Bite,
		Ceaseless Snarl,
		Spectral Awareness,
		Piercing Gaze,
		Blood Spike,
	]
	{
		addPick(sk);
	}
	return picks;
}

void bat_reallyPickSkills(int hpLeft)
{
	visit_url("main.php"); // check if we're already in Torpor
	if(last_choice() != 1342)
		visit_url("campground.php?action=coffin");

	skill [int] picks = bat_pickSkills(hpLeft);
	string url = "choice.php?whichchoice=1342&option=2&pwd=" + my_hash();
	foreach i,sk in picks
	{
		url += "&sk[]=";
		url += sk.to_int() - 24000;
	}
	visit_url(url);
	visit_url("choice.php?whichchoice=1342&option=1&pwd=" + my_hash());
}

boolean bat_shouldPickSkills(int hpLeft)
{
	skill [int] picks = bat_pickSkills(hpLeft);

	foreach sk in $skills[]
	{
		if(sk.bat_maxHPCost() == 0)
			continue;

		boolean found = false;

		foreach i,pick in picks
		{
			if(sk == pick)
			{
				found = true;
				break;
			}
		}

		if(found != have_skill(sk))
			return true;
	}

	return false;
}

boolean bat_shouldEnsorcel(monster m)
{
	if(my_class() != $class[Vampyre] || !sl_have_skill($skill[Ensorcel]))
		return false;

	// until we have a way to tell what we already have as an ensorcelee, just ensorcel goblins
	// to help avoid getting beaten up...
	if(m.monster_phylum() == $phylum[goblin] && !isFreeMonster(m))
		return true;

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

boolean bat_skillValid(skill sk)
{
	if($skills[Savage Bite, Crush, Baleful Howl, Ceaseless Snarl] contains sk && have_effect($effect[Bats Form]) + have_effect($effect[Mist Form]) > 0)
		return false;

	if($skills[Blood Spike, Blood Chains, Chill of the Tomb, Blood Cloak] contains sk && have_effect($effect[Wolf Form]) + have_effect($effect[Bats Form]) > 0)
		return false;

	if($skills[Piercing Gaze, Perceive Soul, Ensorcel, Spectral Awareness] contains sk && have_effect($effect[Wolf Form]) + have_effect($effect[Mist Form]) > 0)
		return false;

	return true;
}

boolean LM_batpath()
{
	if(my_class() != $class[Vampyre])
		return false;

	if(bat_remainingBaseHP() >= 70 && bat_shouldPickSkills(20))
	{
		bat_reallyPickSkills(20);
		return true;
	}

	int bloodBank = get_property("sl_bat_bloodBank").to_int();
	if(bloodBank == 0 || (bloodBank == 1 && have_skill($skill[Intimidating Aura])))
	{
		visit_url("place.php?whichplace=town_right&action=town_bloodbank");
		set_property("sl_bat_bloodBank", (have_skill($skill[Intimidating Aura]) ? 2 : 1));
	}

	return false;
}
