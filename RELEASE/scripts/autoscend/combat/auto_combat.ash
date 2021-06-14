import <autoscend/combat/auto_combat_header.ash>					//header file for combat
import <autoscend/combat/auto_combat_util.ash>						//combat utilities
import <autoscend/combat/auto_combat_default_stage1.ash>			//default stage 1 = 1st round actions
import <autoscend/combat/auto_combat_default_stage2.ash>			//default stage 2 = debuff
import <autoscend/combat/auto_combat_default_stage3.ash>			//default stage 3 = prekill actions
import <autoscend/combat/auto_combat_default_stage4.ash>			//default stage 4 = kill
import <autoscend/combat/auto_combat_awol.ash>						//path = avatar of west of loathing
import <autoscend/combat/auto_combat_bees_hate_you.ash>				//path = bees hate you
import <autoscend/combat/auto_combat_community_service.ash>			//path = community service
import <autoscend/combat/auto_combat_heavy_rains.ash>				//path = heavy rains
import <autoscend/combat/auto_combat_jarlsberg.ash>					//path = avatar of jarlsberg
import <autoscend/combat/auto_combat_disguises_delimit.ash>			//path = disguises delimit
import <autoscend/combat/auto_combat_ed.ash>						//path = actually ed the undying
import <autoscend/combat/auto_combat_gelatinous_noob.ash>			//path = gelatinous noob
import <autoscend/combat/auto_combat_kingdom_of_exploathing.ash>	//path = kingdom of exploathing
import <autoscend/combat/auto_combat_ocrs.ash>						//path = one crazy random summer
import <autoscend/combat/auto_combat_pete.ash>						//path = avatar of sneaky pete
import <autoscend/combat/auto_combat_plumber.ash>					//path = path of the plumber
import <autoscend/combat/auto_combat_the_source.ash>				//path = the source
import <autoscend/combat/auto_combat_quest.ash>						//quest specific handling

//	Advance combat round, nothing happens.
//	/goto fight.php?action=useitem&whichitem=1

string auto_combatHandler(int round, monster enemy, string text)
{
	if(round > 25)
	{
		abort("Some sort of problem occurred, it is past round 25 but we are still in non-gremlin combat...");
	}
	string retval;
	
	#Yes, round 0, really.
	boolean blocked = contains_text(text, "(STUN RESISTED)");
	if(round == 0)
	{
		auto_log_info("auto_combatHandler: " + round, "brown");

		switch(enemy)
		{
			case $monster[Government Agent]:
				set_property("_portscanPending", false);
				break;
			case $monster[possessed wine rack]:
				set_property("auto_wineracksencountered", get_property("auto_wineracksencountered").to_int() + 1);
				break;
			case $monster[cabinet of Dr. Limpieza]:
				set_property("auto_cabinetsencountered", get_property("auto_cabinetsencountered").to_int() + 1);
				break;
			case $monster[junksprite bender]:
			case $monster[junksprite melter]:
			case $monster[junksprite sharpener]:
				set_property("auto_junkspritesencountered", get_property("auto_junkspritesencountered").to_int() + 1);
				break;
		}

		set_property("auto_combatHandler", "");
		set_property("auto_funCombatHandler", "");				//ocrs specific tracker
		set_property("auto_funPrefix", "");						//ocrs specific tracker
		set_property("auto_combatHandlerThunderBird", "0");
		set_property("auto_combatHandlerFingernailClippers", "0");
		set_property("auto_combatHP", my_hp());
	}
	else
	{
		set_property("auto_combatHP", my_hp());
	}

	set_property("auto_diag_round", round);

	if(my_path() == "One Crazy Random Summer")
	{
		enemy = ocrs_combat_helper(text);
		enemy = last_monster();
	}
	if(my_path() == "Avatar of West of Loathing")
	{
		awol_combat_helper(text);
	}

	int majora = -1;
	if(my_path() == "Disguises Delimit")
	{
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
		
		if((majora == 7) && canUse($skill[Swap Mask]))
		{
			return useSkill($skill[Swap Mask]);
		}
		if(majora == 3)
		{
			if(canSurvive(1.5))
			{
				return "attack with weapon";
			}
			abort("May not be able to survive combat. Is swapping protest mask still not allowing us to do anything?");
		}
		if(my_mask() == "protest mask" && canUse($skill[Swap Mask]))
		{
			return useSkill($skill[Swap Mask]);
		}
	}

	if(get_property("auto_combatDirective") != "")
	{
		string[int] actions = split_string(get_property("auto_combatDirective"), ";");
		int idx = 0;
		if(round == 0)
		{
			if(actions[0] != "start")
			{
				set_property("auto_combatDirective", "");
				idx = -1;
			}
			else
			{
				idx = 1;
			}
		}
		if(idx >= 0)
		{
			string doThis = actions[idx];
			while(contains_text(doThis, "(") && contains_text(doThis, ")") && (idx < count(actions)))
			{
				set_property("auto_combatHandler", get_property("auto_combatHandler") + doThis);
				idx++;
				if(idx >= count(actions))
				{
					break;
				}
				doThis = actions[idx];
			}
			string restore = "";
			for(int i=idx+1; i<count(actions); i++)
			{
				restore += actions[i];
				if((i+1) < count(actions))
				{
					restore += ";";
				}
			}
			set_property("auto_combatDirective", restore);
			if(idx < count(actions))
			{
				return doThis;
			}
		}
	}
	
	##stage 1 = 1st round actions: puzzle boss, pickpocket, banish, escape, instakill, etc. things that need to be done before delevel
	retval = auto_combatDefaultStage1(round, enemy, text);
	if(retval != "") return retval;
	
	##stage 2 = debuff: delevel, stun, curse, damage over time
	retval = auto_combatDefaultStage2(round, enemy, text);
	if(retval != "") return retval;
	
	##stage 3 = prekill. copy, sing along, flyer and other things that need to be done after delevel but before killing
	retval = auto_combatDefaultStage3(round, enemy, text);
	if(retval != "") return retval;

	//Ensorcel is a Dark Gyffte specific skill that lets you mind control an enemy to becoming a minion 3/day.
	//mechanically it is a free runaway that also gives you a vampyre specific pet based on the phylum of the monster you are facing.
	if(bat_shouldEnsorcel(enemy) && canUse($skill[Ensorcel]) && get_property("auto_bat_ensorcels").to_int() < 3)
	{
		set_property("auto_bat_ensorcels", get_property("auto_bat_ensorcels").to_int() + 1);
		handleTracker(enemy, $skill[Ensorcel], "auto_otherstuff");
		return useSkill($skill[Ensorcel]);
	}
	
	if((my_location() == $location[Super Villain\'s Lair]) && (auto_my_path() == "License to Adventure") && canSurvive(2.0) && (enemy == $monster[Villainous Minion]))
	{
		if(!get_property("_villainLairCanLidUsed").to_boolean() && (item_amount($item[Razor-Sharp Can Lid]) > 0))
		{
			return "item " + $item[Razor-Sharp Can Lid];
		}
		if(!get_property("_villainLairWebUsed").to_boolean() && (item_amount($item[Spider Web]) > 0))
		{
			return "item " + $item[Spider Web];
		}
		if(!get_property("_villainLairFirecrackerUsed").to_boolean() && (item_amount($item[Knob Goblin Firecracker]) > 0))
		{
			return "item " + $item[Knob Goblin Firecracker];
		}
	}
	
	//source terminal iotm source path specific action. provokes an agent into attacking you next turn 3/day
	if(canUse($skill[Portscan]) && (my_location().turns_spent < 8) && (get_property("_sourceTerminalPortscanUses").to_int() < 3) && !get_property("_portscanPending").to_boolean())
	{
		if($locations[The Castle in the Clouds in the Sky (Ground Floor), The Haunted Bathroom, The Haunted Gallery] contains my_location())
		{
			set_property("_portscanPending", true);
			return useSkill($skill[Portscan]);
		}
	}

	##stage 4 = kill
	retval = auto_combatDefaultStage4(round, enemy, text);
	if(retval != "") return retval;
	
	abort("We reached the end of combat script without finding anything to do");
	return "";
}
