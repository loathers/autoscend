script "auto_boris.ash"

void boris_initializeSettings()
{
	if(my_path() == "Avatar of Boris")
	{
		set_property("auto_borisSkills", -1);
		set_property("auto_cubeItems", false);
		set_property("auto_grimstoneOrnateDowsingRod", false);
		set_property("auto_useCubeling", false);
		set_property("auto_wandOfNagamar", false);

		# Mafia r16876 does not see the Boris Helms in storage and will not pull them.
		# We have to force the issue.
		string temp = visit_url("storage.php?action=pull&whichitem1=5648&howmany1=1&pwd");
		temp = visit_url("storage.php?action=pull&whichitem1=5650&howmany1=1&pwd");
	}
}




void boris_initializeDay(int day)
{
	if(my_path() != "Avatar of Boris")
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
			while(acquireHermitItem($item[Ten-Leaf Clover]));
			pullXWhenHaveY($item[hand in glove], 1, 0);
			pullXWhenHaveY($item[blackberry galoshes], 1, 0);
			pullXWhenHaveY(whatHiMein(), 1, 0);
		}
	}
	else if(day == 3)
	{
		if(get_property("auto_day_init").to_int() < 3)
		{
			while(acquireHermitItem($item[Ten-Leaf Clover]));
			set_property("auto_day_init", 3);
		}
	}
	else if(day == 4)
	{
		if(get_property("auto_day_init").to_int() < 4)
		{
			while(acquireHermitItem($item[Ten-Leaf Clover]));
			set_property("auto_day_init", 4);
		}
	}
}

boolean boris_buySkills()
{
	if(my_class() != $class[Avatar of Boris])
	{
		return false;
	}
	if(my_level() <= get_property("auto_borisSkills").to_int())
	{
		return false;
	}
	if(have_skill($skill[Bifurcating Blow]) && have_skill($skill[Banishing Shout]) && have_skill($skill[Gourmand]))
	{
		return false;
	}

	int possBorisPoints = 0;

	string page = visit_url("da.php?place=gate1");
	matcher my_skillPoints = create_matcher("You can learn (\\d\+) more skill", page);
	if(my_skillPoints.find())
	{
		int skillPoints = to_int(my_skillPoints.group(1));
		auto_log_info("Skill points found: " + skillPoints);
		possBorisPoints = skillPoints - 1;

		while(skillPoints > 0)
		{
			skillPoints = skillPoints - 1;
			int tree = 1;

			if(!have_skill($skill[Bifurcating Blow]))
			{
				tree = 1;
			}
			if(!have_skill($skill[Legendary Impatience]))
			{
				tree = 1;
			}
			if(!have_skill($skill[Song of Cockiness]))
			{
				tree = 1;
			}
			if(!have_skill($skill[Legendary Luck]))
			{
				tree = 1;
			}
			if(!have_skill($skill[Throw Trusty]))
			{
				tree = 1;
			}
			if(!have_skill($skill[Pep Talk]))
			{
				tree = 1;
			}
			if(!have_skill($skill[Sick Pythons]))
			{
				tree = 1;
			}
			if(!have_skill($skill[Banishing Shout]))
			{
				tree = 2;
			}
			if(!have_skill($skill[Song of Battle]))
			{
				tree = 2;
			}
			if(!have_skill($skill[Louder Bellows]))
			{
				tree = 2;
			}
			if(!have_skill($skill[Song of Fortune]))
			{
				tree = 2;
			}
			if(!have_skill($skill[Good Singing Voice]))
			{
				tree = 2;
			}
			if(!have_skill($skill[Gourmand]))
			{
				tree = 3;
			}
			if(!have_skill($skill[Barrel Chested]))
			{
				tree = 3;
			}
			if(!have_skill($skill[More to Love]))
			{
				tree = 3;
			}
			if(!have_skill($skill[Hungry Eyes]))
			{
				tree = 3;
			}
			if(!have_skill($skill[Song of Solitude]))
			{
				tree = 2;
			}
			if(!have_skill($skill[Big Lungs]))
			{
				tree = 2;
			}
			if(!have_skill($skill[Song of Accompaniment]))
			{
				tree = 2;
			}
			if(!have_skill($skill[Legendary Bravado]))
			{
				tree = 2;
			}
			if(!have_skill($skill[Intimidating Bellow]))
			{
				tree = 2;
			}
			if(!have_skill($skill[Heroic Belch]))
			{
				tree = 3;
			}
			if(!have_skill($skill[Legendary Appetite]))
			{
				tree = 3;
			}
			if(!have_skill($skill[Big Boned]))
			{
				tree = 3;
			}
			if(!have_skill($skill[Song of the Glorious Lunch]))
			{
				tree = 3;
			}
			if(!have_skill($skill[Legendary Girth]))
			{
				tree = 3;
			}
			if(!have_skill($skill[Demand Sandwich]))
			{
				tree = 3;
			}

			if(!have_skill($skill[Broadside]))
			{
				tree = 1;
			}
			if(!have_skill($skill[[11002]Ferocity]))
			{
				tree = 1;
			}
			if(!have_skill($skill[Cleave]))
			{
				tree = 1;
			}

			visit_url("da.php?pwd&whichtree=" + tree + "&action=borisskill");
		}
	}

	set_property("auto_borisSkills", my_level());
	return true;
}


boolean LM_boris()
{
	if(my_path() != "Avatar of Boris")
	{
		return false;
	}

	boris_buySkills();

	return false;
}
