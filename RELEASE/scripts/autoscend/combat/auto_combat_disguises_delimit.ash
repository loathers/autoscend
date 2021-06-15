//Path specific combat handling for disguises delimit

void dd_combat_helper(int round, monster enemy, string text)
{
	//identify mask worn during disguises delimit path
	if(my_path() != "Disguises Delimit")
	{
		return;
	}
	//note that mafia has a function my_mask().
	//TODO compare if it is more reliable than our own mask matcher to see if we should switch
	int majora = -1;
	matcher maskMatch = create_matcher("mask(\\d+).png", text);
	if(maskMatch.find())
	{
		majora = maskMatch.group(1).to_int();
		if(round == 0)
		{
			auto_log_info("Found mask: " + majora, "green");
		}
	}
	else if(enemy == $monster[Your Shadow])	//matcher fails on your shadow and it always wears mask 1.
	{
		majora = 1;
		auto_log_info("Found mask: 1", "green");
	}
	else
	{
		abort("Failed to identify the mask worn by the monster [" + enemy + "]. Finish this combat manually then run me again");
	}
	set_property("_auto_combatDisguisesDelimitMask", majora);
}

string auto_combatDisguisesStage1(int round, monster enemy, string text)
{
	##stage 1 = 1st round actions: puzzle boss, pickpocket, duplicate, things that are only allowed if they are the first action you take.
	if(my_path() != "Disguises Delimit")
	{
		return "";
	}
	
	//some masks are treated like puzzle bosses. requiring either an immediate swap or special action handling
	int majora = get_property("_auto_combatDisguisesDelimitMask").to_int();
	//mask 7 = bandit mask = +300% enemy defense
	if(majora == 7 && canUse($skill[Swap Mask]))
	{
		return useSkill($skill[Swap Mask]);
	}
	//mask 3 = protest mask = +30ML. can only attack with weapon or change mask. if changed can only use items or attack with weapon
	if(majora == 3)
	{
		if(canSurvive(1.5))
		{
			return "attack with weapon";
		}
		abort("May not be able to survive combat. Is swapping protest mask still not allowing us to do anything?");
	}
	//this is code is unreachable. it needs fixing.
	if(my_mask() == "protest mask" && canUse($skill[Swap Mask]))
	{
		return useSkill($skill[Swap Mask]);
	}
	
	return "";
}

string auto_combatDisguisesStage5(int round, monster enemy, string text)
{
	##stage 5 = kill
	if(my_path() != "Disguises Delimit")
	{
		return "";
	}
	
	int majora = get_property("_auto_combatDisguisesDelimitMask").to_int();
	if(majora == 13)	//welding mask
	{
		//reflect damage from spells back to player. kept if mask is changed
		//some spells actually damage the monster too.
		//saucegeyser confirmed to not damage the monster. saucestorm confirmed to damage the monster.
		if(enemy.physical_resistance >= 80)
		{
			if(my_hp() > monster_hp() + 150 && canUse($skill[Saucestorm], false))
			{
				return useSkill($skill[Saucestorm], false);
			}
			//TODO check if our physical attack can deal elemental damage.
			else abort("Not sure how to handle a physically resistent enemy wearing a welding mask.");
		}
		if(canSurvive(1.5) && round < 10)
		{
			return "attack with weapon";
		}
		abort("Not sure how to handle welding mask.");
	}
	if(majora == 25)	//tiki mask
	{
		//triples HP and hard caps damage at 10 per source. kept if mask is changed
		//seal clubbers have ways to increase this damage but its overly complicated to calculate. simplified calculation is used.
		int hot_dmg = min(10,numeric_modifier("hot damage"));
		int cold_dmg = min(10,numeric_modifier("cold damage"));
		int stench_dmg = min(10,numeric_modifier("stench damage"));
		int sleaze_dmg = min(10,numeric_modifier("sleaze damage"));
		int spooky_dmg = min(10,numeric_modifier("spooky damage"));
		int attack_dmg = 10 + hot_dmg + cold_dmg + stench_dmg + sleaze_dmg + spooky_dmg;
		
		if(attack_dmg > 20)
		{
			return "attack with weapon";
		}
		if(canUse($skill[Saucestorm], false))
		{
			return useSkill($skill[Saucestorm], false);
		}
	}
	
	return "";
}
