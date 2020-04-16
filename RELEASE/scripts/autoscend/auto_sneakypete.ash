script "auto_sneakypete.ash"

void pete_initializeSettings()
{
	if(my_path() == "Avatar of Sneaky Pete")
	{
		set_property("auto_peteSkills", -1);
		set_property("auto_cubeItems", false);
		set_property("auto_grimstoneOrnateDowsingRod", false);
		set_property("auto_useCubeling", false);
		set_property("auto_wandOfNagamar", false);
	}
}


void pete_initializeDay(int day)
{
	if(my_path() != "Avatar of Sneaky Pete")
	{
		return;
	}
	if(day == 2)
	{
		equipBaseline();
		ovenHandle();

		if(get_property("auto_day_init").to_int() < 2)
		{

			if(get_property("auto_dickstab").to_boolean() && chateaumantegna_available())
			{
				boolean[item] furniture = chateaumantegna_decorations();
				if(!furniture[$item[Ceiling Fan]])
				{
					chateaumantegna_buyStuff($item[Ceiling Fan]);
				}
			}

			if(item_amount($item[gym membership card]) > 0)
			{
				use(1, $item[gym membership card]);
			}

			if(item_amount($item[Seal Tooth]) == 0)
			{
				acquireHermitItem($item[Seal Tooth]);
			}
			while(acquireHermitItem($item[Ten-leaf Clover]));
			pullXWhenHaveY($item[hand in glove], 1, 0);
			pullXWhenHaveY($item[blackberry galoshes], 1, 0);
			pullXWhenHaveY(whatHiMein(), 1, 0);
		}
	}
	else if(day == 3)
	{
		if(get_property("auto_day_init").to_int() < 3)
		{
			while(acquireHermitItem($item[Ten-leaf Clover]));
			set_property("auto_day_init", 3);
		}
	}
	else if(day == 4)
	{
		if(get_property("auto_day_init").to_int() < 4)
		{
			while(acquireHermitItem($item[Ten-leaf Clover]));
			set_property("auto_day_init", 4);
		}
	}
}

boolean pete_buySkills()
{
	if(my_class() != $class[Avatar of Sneaky Pete])
	{
		return false;
	}
	if(my_level() <= get_property("auto_peteSkills").to_int())
	{
		return false;
	}
	if(have_skill($skill[Natural Dancer]) && have_skill($skill[Flash Headlight]) && have_skill($skill[Walk Away From Explosion]) && (my_level() > 12))
	{
		return false;
	}

	string page = visit_url("da.php?place=gate3");
	matcher my_skillPoints = create_matcher("<b>(\\d\+)</b> skill point", page);
	if(my_skillPoints.find())
	{
		int skillPoints = to_int(my_skillPoints.group(1));
		auto_log_info("Skill points found: " + skillPoints);

		while(skillPoints > 0)
		{
			skillPoints = skillPoints - 1;
			int tree = 1;

			if(!have_skill($skill[Flash Headlight]))
			{
				tree = 2;
			}
			if(!have_skill($skill[Biker Swagger]))
			{
				tree = 2;
			}
			if(!have_skill($skill[Riding Tall]))
			{
				tree = 2;
			}
			if(!have_skill($skill[Check Mirror]))
			{
				tree = 2;
			}
			if(!have_skill($skill[Easy Riding]))
			{
				tree = 2;
			}

			if(!have_skill($skill[Walk Away From Explosion]))
			{
				tree = 3;
			}
			if(!have_skill($skill[Brood]))
			{
				tree = 3;
			}
			if(!have_skill($skill[Unrepentant Thief]))
			{
				tree = 3;
			}
			if(!have_skill($skill[[15025]Hard Drinker]))
			{
				tree = 3;
			}
			if(!have_skill($skill[Smoke Break]))
			{
				tree = 3;
			}
			if(!have_skill($skill[Animal Magnetism]))
			{
				tree = 3;
			}
			if(!have_skill($skill[Jump Shark]))
			{
				tree = 3;
			}
			if(!have_skill($skill[Incite Riot]))
			{
				tree = 3;
			}
			if(!have_skill($skill[Live Fast]))
			{
				tree = 3;
			}
			if(!have_skill($skill[Insult]))
			{
				tree = 3;
			}
			if(!have_skill($skill[Natural Dancer]))
			{
				tree = 1;
			}
			if(!have_skill($skill[Make Friends]))
			{
				tree = 1;
			}
			if(!have_skill($skill[Cocktail Magic]))
			{
				tree = 1;
			}
			if(!have_skill($skill[Check Hair]))
			{
				tree = 1;
			}
			if(!have_skill($skill[Shake It Off]))
			{
				tree = 1;
			}
			if(!have_skill($skill[Snap Fingers]))
			{
				tree = 1;
			}
			if(!have_skill($skill[Fix Jukebox]))
			{
				tree = 1;
			}
			if(!have_skill($skill[Throw Party]))
			{
				tree = 1;
			}
			if(!have_skill($skill[Mixologist]))
			{
				tree = 1;
			}
			if(!have_skill($skill[Catchphrase]))
			{
				tree = 1;
			}

			if(!have_skill($skill[Peel Out]))
			{
				tree = 2;
			}
			if(!have_skill($skill[Rowdy Drinker]))
			{
				tree = 2;
			}
			if(!have_skill($skill[Pop Wheelie]))
			{
				tree = 2;
			}
			if(!have_skill($skill[Born Showman]))
			{
				tree = 2;
			}
			if(!have_skill($skill[Rev Engine]))
			{
				tree = 2;
			}
			visit_url("choice.php?option=" + tree + "&whichchoice=867&pwd=");
		}
	}

	page = visit_url("main.php?action=motorcycle");
	matcher my_cyclePoints = create_matcher("Upping Your Grade", page);
	while(my_cyclePoints.find())
	{
		auto_log_info("Found Upping Your Grade", "blue");
		int firstChoice = -1;
		int secondChoice = -1;
		if(get_property("peteMotorbikeCowling") == "")
		{
			firstChoice = 4;
			secondChoice = 3;
		}
		else if(get_property("peteMotorbikeTires") == "")
		{
			firstChoice = 1;
			secondChoice = 1;
		}
		else if(get_property("peteMotorbikeMuffler") == "")
		{
			firstChoice = 5;
			secondChoice = 2;
		}
		else if(get_property("peteMotorbikeGasTank") == "")
		{
			firstChoice = 2;
			secondChoice = 2;
		}
		else if(get_property("peteMotorbikeHeadlight") == "")
		{
			firstChoice = 3;
			secondChoice = 3;
		}
		else if(get_property("peteMotorbikeSeat") == "")
		{
			firstChoice = 6;
			secondChoice = 1;
			run_choice(6);
		}

		if(firstChoice == -1)
		{
			break;
		}

		page = visit_url("choice.php?pwd=&whichchoice=859&option=" + firstChoice);

		if(last_choice() == 859)
		{
			abort("Mafia is not handling this correctly, sorry");
		}
		page = visit_url("choice.php?pwd=&whichchoice=" + last_choice() + "&option=" + secondChoice);

		page = visit_url("main.php?action=motorcycle");
		my_cyclePoints = create_matcher("Upping Your Grade", page);
	}

	set_property("auto_peteSkills", my_level());
	return true;
}


boolean LM_pete()
{
	if(my_path() != "Avatar of Sneaky Pete")
	{
		return false;
	}

	pete_buySkills();

	return false;
}
