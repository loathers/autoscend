boolean in_gnoob()
{
	return my_class() == $class[Gelatinous Noob];
}

void jello_startAscension(string page)
{
	if(contains_text(page, "Welcome to the Kingdom, Gelatinous Noob"))
	{
		auto_log_info("In starting Jello Adventure", "blue");
		matcher my_skillPoints = create_matcher("You can pick <span class=\"num\">(\\d\+)</span> more skill", page);
		if(my_skillPoints.find())
		{
			int skillPoints = to_int(my_skillPoints.group(1));
			auto_log_info("Found " + skillPoints + " skillpoints", "blue");
			boolean [int] skills = $ints[50, 49, 48, 47, 46, 55, 45, 70, 60, 69, 30, 29, 95, 54, 105, 75, 35, 10, 20, 68, 53, 52, 51, 44, 43, 42, 85, 83, 93, 34, 58, 28, 57, 84, 8, 56, 6, 18, 17, 37, 7, 9, 67, 59, 39, 74, 73, 72, 40, 66, 77, 78, 38];

			string goal = "";
			foreach idx in skills
			{
				if(contains_text(page, "name=\"skills[]\" value=\"" + idx + "\""))
				{
					goal += "&skills[]=" + idx;
					skillPoints--;
				}
				if(skillPoints == 0)
				{
					break;
				}
			}

			page = visit_url("choice.php?pwd=&option=1&whichchoice=1230" + goal);
		}
	}
}

int gnoobAbsorbCost(item it)
{
	//estimates the cost of absorbing an item as a gnoob for the specific purpose of sorting which item we prefer to use.
	//this uses the price we have to pay to acquire it rather than the market value of an item.
	//do not check if we already have the item here. as that could result in multiple items of price 0 and not knowing which is better.
	
	int retval = 999999;
	if(is_npc_item(it))
	{
		retval = npc_price(it);
	}
	if(is_tradeable(it))
	{
		int mall_price = auto_mall_price(it);
		if(retval > 0)
		{
			retval = min(retval, mall_price);
		}
		else
		{
			retval = mall_price;
		}
	}
	
	if(!can_interact())	//do not have unrestricted mall access. meaning ronin or hardcore
	{
		if(auto_have_skill($skill[Summon Clip Art]) && get_property("_clipartSummons").to_int() < 3 && isClipartItem(it))
		{
			retval = 18;		//the price to acquire it is only 2 MP which we can highball as 18 meat at galaktik pricing.
		}
		if(item_amount(it) > 0 && retval < 20000)
		{
			retval = 0;		//set item price to 0 since we have it and it is not unreasonably expensive
		}
	}
	
	if(retval == 999999)
	{
		auto_log_debug("gnoobAbsorbCost tried to find absorb price of the item [" + it + "] and could not find a means to acquire it. Returned a massively high price to prevent errors. This should get fixed");
	}
	if(retval < 0)
	{
		retval = 999999;
		auto_log_debug("gnoobAbsorbCost tried to find absorb price of the item [" + it + "] and somehow got a result lower than 0. Which is probably indicative of the item being incorrectly listed as tradeable. Returned a massively high price to prevent errors.");
	}
	
	return retval;
}

void jello_buySkills()
{
	//Need to consider skill orders, how to handle when we have starting skills.

	boolean[item] blacklist;
	
	if(item_amount($item[Pick-O-Matic lockpicks]) == 1)
	{
		blacklist[$item[Pick-O-Matic lockpicks]] = true;	//do not absorb our last lockpick. could have more than 1 in postronin
	}
	if(internalQuestStatus("questL10Garbage") < 2 && item_amount($item[Enchanted Bean]) == 1)
	{
		blacklist[$item[Enchanted Bean]] = true;	//need to keep our only enchanted bean to be planted
	}

	string[item] available = jello_lister();
	int starting_absorb_count = my_absorbs();
	int earlyTerm = max(5, get_property("_noobSkillCount").to_int() + ((my_daycount() - 1) * min(my_level()+2, 15))) + get_property("noobPoints").to_int() + 2;

	foreach sk in $skills[Large Intestine, Small Intestine, Stomach-Like Thing, Rudimentary Alimentary Canal, Central Hypothalamus, Arrogance, Sense of Pride, Sense of Purpose, Retractable Toes, Bendable Knees, Ink Gland, Anger Glands, Basic Self-Worth, Work Ethic, Visual Cortex, Saccade Reflex, Frown Muscles, Powerful Vocal Chords, Optic Nerves, Right Eyeball, Left Eyeball, Thumbs, Index Fingers, Middle Fingers, Ring Fingers, Pinky Fingers, Hot Headedness, Sunglasses, Sense of Sarcasm, Beating Human Heart, Oversized Right Kidney, Anterior Cruciate Ligaments, Achilles Tendons, Kneecaps, Ankle Joints, Hamstrings, Pathological Greed, Sense of Entitlement, Business Acumen, Financial Ambition, The Concept of Property, Bravery Gland, Subcutaneous Fat, Adrenal Gland, Nasal Septum, Hyperactive Amygdala, Nasal Lamina Propria, Right Eyelid, Pinchable Nose, Left Eyelid, Nose Hair, Overalls, Rigid Rib Cage, Rigid Headbone]
	{
		if(have_skill(sk))
		{
			continue;	//no need to do anything for a skill you already have. do not decrement earlyTerm either.
		}
		earlyTerm --;
		if(earlyTerm <= 0)
		{
			auto_log_debug("jello_buySkills checked too many skills without getting any. terminating loop early");
			break;
		}
		if(jello_absorbsLeft() <= 0)
		{
			break;
		}
			
		item[int] possible;
		int count = 0;
		foreach it in available
		{
			if(!blacklist[it] && it.noob_skill == sk)
			{
				possible[count(possible)] = it;
			}
		}
		int bound = count(possible);
		if(bound == 0)	//we do not have any item that could get us the desired skill
		{
			continue;
		}

		sort possible by gnoobAbsorbCost(value);

		auto_log_info("Trying to acquire skill " + sk + " and considering: " , "green");
		for(int i=0; i<bound; i++)
		{
			auto_log_info(possible[i] + ": " + gnoobAbsorbCost(possible[i]) + " meat", "blue");
		}

		//get the skill
		for(int i=0; (i<bound) && !have_skill(sk); i++)
		{
			if(item_amount(possible[i]) == 0)
			{
				retrieve_item(1,possible[i]);
				if(item_amount(possible[i]) == 0)
				{
					auto_log_info("Failed to acquire [" + possible[i] + "] for jello_buySkills");
					continue;
				}
			}
			cli_execute("absorb " + possible[i]);
			if(starting_absorb_count == my_absorbs())
			{
				abort("Tried and failed to absorb [" + possible[i] + "]. this should not have happened and needs to be fixed");
			}
			else
			{
				available = jello_lister();		//recheck item availability now that one was consumed. necessary for tome handling and NPC stores.
			}
		}
	}
	
	//absorb potted cactus for adventures
	if(jello_absorbsLeft() > 0 && my_adventures() <= 1 + auto_advToReserve() && my_level() >= 12)
	{
		buyUpTo(1, $item[Potted Cactus]);
		if(item_amount($item[Potted Cactus]) > 0)
		{
			cli_execute("absorb Potted Cactus");
		}
	}
}


string[item] jello_lister(string goal)
{
	string[item] retval;
	foreach it in $items[]
	{
		boolean canGet = item_amount(it) > 0 || creatable_amount(it) > 0;
		if(npc_price(it) > 0 && my_meat() >= npc_price(it))
		{
			canGet = true;
		}
		if(isSpeakeasyDrink(it))	//speakeasy drinks are instantly drank which does not work for gnoob
		{
			canGet = false;
		}
		if(canGet && (it.noob_skill != $skill[none]) && !have_skill(it.noob_skill))
		{
			string result = string_modifier(it.noob_skill, "Modifiers");
			if($skills[Anger Glands, Bendable Knees, Frown Muscles, Ink Gland, Powerful Vocal Chords, Retractable Toes] contains it.noob_skill)
			{
				result = "Combat Rate";
			}
			if(contains_text(result, goal))
			{
				retval[it] = result;
			}
		}
	}
	return retval;
}

int jello_absorbsLeft()
{
	if(!in_gnoob())
	{
		return 0;
	}
	int absorbs = min(my_level() + 2, 15);
	return absorbs - my_absorbs();
}

string[item] jello_lister()
{
	return jello_lister("");
}

boolean LM_jello()
{
	if(!in_gnoob())
	{
		return false;
	}
	jello_buySkills();
	return false;
}
