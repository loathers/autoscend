script "cc_boris.ash"

void boris_initializeSettings()
{
	if(my_path() == "Avatar of Boris")
	{
		set_property("cc_100familiar", $familiar[Egg Benedict]);
		set_property("cc_ballroomsong", "finished");
		set_property("cc_borisSkills", -1);
#		set_property("cc_crackpotjar", "done");
		set_property("cc_cubeItems", false);
		set_property("cc_getStarKey", true);
		set_property("cc_grimstoneOrnateDowsingRod", false);
		set_property("cc_holeinthesky", true);
		set_property("cc_useCubeling", false);
		set_property("cc_wandOfNagamar", false);

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
	if(day == 1)
	{
		if(get_property("cc_day1_init") != "finished")
		{
			#set_property("cc_day1_init", "finished");
		}
	}
	else if(day == 2)
	{
		equipBaseline();
		ovenHandle();

		if(get_property("cc_day2_init") == "")
		{

			if(get_property("cc_dickstab").to_boolean() && chateaumantegna_available())
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

			#set_property("cc_day2_init", "finished");
		}
	}
	else if(day == 3)
	{
		if(get_property("cc_day3_init") == "")
		{
			while(acquireHermitItem($item[Ten-Leaf Clover]));
			set_property("cc_day3_init", "finished");
		}
	}
	else if(day == 4)
	{
		if(get_property("cc_day4_init") == "")
		{
			while(acquireHermitItem($item[Ten-Leaf Clover]));
			set_property("cc_day4_init", "finished");
		}
	}
}

boolean boris_buySkills()
{
	if(my_class() != $class[Avatar of Boris])
	{
		return false;
	}
	if(my_level() <= get_property("cc_borisSkills").to_int())
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
		print("Skill points found: " + skillPoints);
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
			if(!have_skill($skill[Ferocity]))
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

	set_property("cc_borisSkills", my_level());
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
