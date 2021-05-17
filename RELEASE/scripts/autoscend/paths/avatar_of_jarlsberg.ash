boolean isJarlsberg()
{
    return my_class() = 
}

void jarlsberg_initializeSettings()
{
    	if(isJarlsberg())
	{
		auto_log_info("Initializing Avatar of Jarlsberg settings", "blue");
		set_property("auto_jarlsbergSkills", -1);
		set_property("auto_wandOfNagamar", false);

		# Mafia r16876 does not see the Boris Helms in storage and will not pull them.
		# We have to force the issue.
		string temp = visit_url("storage.php?action=pull&whichitem1=5648&howmany1=1&pwd");
		temp = visit_url("storage.php?action=pull&whichitem1=5650&howmany1=1&pwd");
	}
}

void jarlsberg_initializeDay(int day)
{
	if(!isJarlsberg())
	{
		return;
	}
	if(day == 2)
	{
		equipBaseline(); //What Do
		ovenHandle(); //What Do

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
			//pullXWhenHaveY(whatHiMein(), 1, 0); -> Not including as Jarlsberg can't eat "common" food
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

void jarlsberg_buySkills() //Skills logic to be done later once have a multi in class
{
	if(!isJarlsberg())
	{
		return;
	}
	if(my_level() <= get_property("auto_jarlsbergSkills").to_int())
	{
		return;
	}
	//if you have these 16 skills then you have all skills
	if(have_skill($skill[Coffeesphere]) && have_skill($skill[The Most Important Meal]) && have_skill($skill[Egg Man]) && have_skill($skill[Early Riser])
    && have_skill($skill[Radish Horse]) && have_skill($skill[Conjure Cheese]) && have_skill($skill[Working Lunch]) && have_skill($skill[Oilsphere])
    && have_skill($skill[Food Coma]) && have_skill($skill[Hippotatomous]) && have_skill($skill[Never Late for Dinner]) && have_skill($skill[Gristlesphere])
    && have_skill($skill[Best Served Cold]) && have_skill($skill[Nightcap]) && have_skill($skill[Blend]) && have_skill($skill[Chocolatesphere]))
	{
		return;
	}


	string page = visit_url("da.php?place=gate2");
	matcher my_skillPoints = create_matcher("<b>(\\d\+)</b> skill point", page);
	if(my_skillPoints.find())
	{
		int skillPoints = to_int(my_skillPoints.group(1));
		auto_log_info("Skill points found: " + skillPoints);

		while(skillPoints > 0)
		{
			skillPoints = skillPoints - 1;
			int tree = 1;

            //Jarlsberg skills are super odd. Need to ascend and see how the choices work.

			//skills are listed in reverse order. from last to first to buy.
			//Correct strat is super easy. get all feasting, then all shouting, then fighting last.
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

			visit_url("da.php?pwd&whichtree=" + tree + "&action=borisskill");
		}
	}

	set_property("auto_jarlsbergSkills", my_level());
}

boolean LM_jarlsberg()
{
	//this function is called early once every loop of doTasks() in autoscend.ash
	//if something in this function returns true then it will restart the loop and get called again.
	
	if(!isJarlsberg())
	{
		return false;
	}
	

	jarlsberg_buySkills();

	return false;
}