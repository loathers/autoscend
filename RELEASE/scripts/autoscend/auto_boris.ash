script "auto_boris.ash"

boolean in_boris()
{
	return my_class() == $class[Avatar of Boris];
}

boolean borisAdjustML()
{
	//set target ML boosts for boris.
	if(!in_boris())
	{
		return false;
	}
	
	if(my_buffedstat($stat[muscle]) < 30)
	{
		return auto_change_mcd(0);
	}
	
	boolean strong = auto_have_skill($skill[Barrel Chested]);
	
	if(!strong)
	{
		auto_change_mcd(0);
	}
	else
	{
		auto_change_mcd(11);
	}
	
	//Overconfident is an intrinsic +30 ML. By the time you are strong enough to use it it can be turned on and left on
	if(strong && my_buffedstat($stat[muscle]) > 100 && have_skill($skill[Pep Talk]) && have_effect($effect[Overconfident]) == 0)
	{
		use_skill(1, $skill[Pep Talk]);
	}
	
	return true;
}

void boris_initializeSettings()
{
	if(in_boris())
	{
		auto_log_info("Initializing Avatar of Boris settings", "blue");
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
	if(!in_boris())
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

void boris_buySkills()
{
	if(!in_boris())
	{
		return;
	}
	if(my_level() <= get_property("auto_borisSkills").to_int())
	{
		return;
	}
	//if you have these 3 skills then you have all skills
	if(have_skill($skill[Bifurcating Blow]) && have_skill($skill[Banishing Shout]) && have_skill($skill[Gourmand]))
	{
		return;
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

			//skills are listed in reverse order. from last to first to buy.
			//Correct Boris strat is super easy. get all feasting, then all shouting, then fighting last.
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

	set_property("auto_borisSkills", my_level());
}

boolean borisDemandSandwich(boolean immediately)
{
	//Boris can summon a sandwich 3 times per day at cost of 5 MP each
	if(!in_boris())
	{
		return false;
	}
	if(get_property("_demandSandwich").to_int() > 2) 		//max 3 uses a day
	{
		return false;
	}
	if(my_maxmp() < 5)		//can't cast even a single time
	{
		return false;
	}
	
	int remainingDaily()
	{
		return 3 - get_property("_demandSandwich").to_int();
	}

	//if can get best sandwich and is forced to get them all now. use ongoing MP regen to get best sandwich
	if(!immediately && my_level() > 8) 
	{
		int cast_count = min(remainingDaily(), floor(my_mp()/5));
		if(cast_count > 0)
		{
			return use_skill(cast_count, $skill[Demand Sandwich]);
		}
	}
	
	//if we are forced to get them all right now then we don't care about level nor MP regen. We will restore MP as needed.
	if(immediately)
	{
		int total_cost = remainingDaily() * 5;
		if(my_maxmp() >= total_cost)
		{
			if(my_mp() < total_cost && !acquireMP(total_cost))		//can't afford it AND failed to restore
			{
				abort("failed to acquire the MP needed to cast [Demand Sandwich], aborting to prevent diet mishap");
			}
			return use_skill(remainingDaily(), $skill[Demand Sandwich]);
		}
		else while(remainingDaily() > 0)
		{
			if(acquireMP(5))
			{
				use_skill(remainingDaily(), $skill[Demand Sandwich]);
			}
			else
			{
				abort("failed to acquire the MP needed to cast [Demand Sandwich], aborting to prevent diet mishap");
			}
		}
	}
	
	return false;
}

void borisWastedMP()
{
	//Check for wasted MP regeneration and use it up. primarily called towards the end of auto_pre_adv.ash
	//Mostly the MP regen would come from clancy
	if(!in_boris())
	{
		return;
	}
	
	float max_potential_mp_regen = numeric_modifier("MP Regen Max");
	float missing_mp = my_maxmp() - my_mp();
	float potential_mp_wasted = 0;
	if(max_potential_mp_regen > missing_mp)
	{
		potential_mp_wasted = max_potential_mp_regen - missing_mp;
	}
	
	//Laugh it off costs 1 MP to cast and gives either 1 or 2 HP randomly.
	while(my_hp() < my_maxhp() && potential_mp_wasted > 0)
	{
		//multi use without risking wastage. Need to loop a few times because we can't predict what we actually roll for healing.
		int missingHP = my_maxhp() - my_hp();
		int castAmount = min(potential_mp_wasted, missingHP / 2);
		
		//at exactly 1 HP missing there is a 50% chance of wasting 1 point of HP healed. Better than 100% chance of wasting MP though, so do it.
		//also this prevents an infinite loop at 1HP missing. Keep that in mind if you remove this
		if(missingHP == 1)	
		{
			castAmount = 1;
		}
		
		potential_mp_wasted = potential_mp_wasted - castAmount;		
		use_skill(castAmount, $skill[Laugh it Off]);
	}
}

boolean LM_boris()
{
	//this function is called early once every loop of doTasks() in autoscend.ash
	//if something in this function returns true then it will restart the loop and get called again.
	
	if(!in_boris())
	{
		return false;
	}
	
	borisDemandSandwich(false);
	boris_buySkills();

	return false;
}