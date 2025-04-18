import <autoscend/combat/auto_combat_header.ash>					//header file for combat
import <autoscend/combat/auto_combat_util.ash>						//combat utilities
import <autoscend/combat/auto_combat_default_stage1.ash>			//default stage 1 = 1st round actions
import <autoscend/combat/auto_combat_default_stage2.ash>			//default stage 2 = enders
import <autoscend/combat/auto_combat_default_stage3.ash>			//default stage 3 = debuff
import <autoscend/combat/auto_combat_default_stage4.ash>			//default stage 4 = prekill actions
import <autoscend/combat/auto_combat_default_stage5.ash>			//default stage 5 = kill
import <autoscend/combat/auto_combat_awol.ash>						//path = avatar of west of loathing
import <autoscend/combat/auto_combat_bees_hate_you.ash>				//path = bees hate you
import <autoscend/combat/auto_combat_fall_of_the_dinosaurs.ash>		//path = fall of the dinosaurs
import <autoscend/combat/auto_combat_heavy_rains.ash>				//path = heavy rains
import <autoscend/combat/auto_combat_dark_gyffte.ash>				//path = dark gyffte
import <autoscend/combat/auto_combat_disguises_delimit.ash>			//path = disguises delimit
import <autoscend/combat/auto_combat_ed.ash>						//path = actually ed the undying
import <autoscend/combat/auto_combat_gelatinous_noob.ash>			//path = gelatinous noob
import <autoscend/combat/auto_combat_kingdom_of_exploathing.ash>	//path = kingdom of exploathing
import <autoscend/combat/auto_combat_license_to_adventure.ash>		//path = license to adventure
import <autoscend/combat/auto_combat_ocrs.ash>						//path = one crazy random summer
import <autoscend/combat/auto_combat_pete.ash>						//path = avatar of sneaky pete
import <autoscend/combat/auto_combat_plumber.ash>					//path = path of the plumber
import <autoscend/combat/auto_combat_the_source.ash>				//path = the source
import <autoscend/combat/auto_combat_wereprofessor.ash>				//path = wereprofessor
import <autoscend/combat/auto_combat_wildfire.ash>					//path = wildfire
import <autoscend/combat/auto_combat_you_robot.ash>					//path = you, robot
import <autoscend/combat/auto_combat_zombie_slayer.ash>				//path = zombie slayer
import <autoscend/combat/auto_combat_quest.ash>						//quest specific handling
import <autoscend/combat/auto_combat_mr2012.ash>					//2012 iotm and ioty handling

//	Advance combat round, nothing happens.
//	/goto fight.php?action=useitem&whichitem=1

void auto_combatInitialize(int round, monster enemy, string text)
{
	//reset settings for combat at the start of every combat
	if(round != 0)	//Yes round 0, really.
	{
		return;
	}

	switch(enemy)
	{
		case $monster[Government Agent]:
			set_property("_portscanPending", false);
			stop_counter("portscan.edu");
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

	remove_property("_auto_combatState");
	remove_property("auto_funCombatHandler");				//ocrs specific tracker
	remove_property("auto_funPrefix");						//ocrs specific tracker
	set_property("auto_combatHandlerThunderBird", "0");
	set_property("_auto_combatTracker_MortarRound", -1);		//tracks which round we used Stuffed Mortar Shell in.
	
	//log some important info.
	//some stuff is redundant to the pre_adventure function print_footer() so it will not be logged here
	string tolog = "auto_combat initialized fighting [" +enemy+
	"]: atk = " +monster_attack()+
	". def = " +monster_defense()+
	". HP = " +monster_hp()+
	". LA = " +monster_level_adjustment();
	if(in_wildfire())
	{
		tolog += ". fire = " +my_location().fire_level;
	}
	auto_log_info(tolog, "blue");
}

string auto_combatHandler(int round, monster enemy, string text)
{
	if(round > 25 && !($monsters[The Man, The Big Wisniewski] contains enemy))	//war bosses can go to round 50
	{
		if (canUse($skill[Implode Universe]))
		{
			return useSkill($skill[Implode Universe], true);
		}
		abort("Some sort of problem occurred, it is past round 25 but we are still in non-gremlin combat...");
	}

	if(round > 45)
	{
		abort("Some sort of problem occurred, it is past round 45 but we are still in a combat with a war boss...");
	}

	auto_combatInitialize(round, enemy, text);		//reset properties on round 0 of a new combat
	string retval;
	boolean blocked = contains_text(text, "(STUN RESISTED)");
	set_property("auto_combatHP", my_hp());
	set_property("auto_diag_round", round);

	if(in_ocrs())
	{
		enemy = ocrs_combat_helper(text);
		enemy = last_monster();
	}

	if(in_awol())
	{
		awol_combat_helper(text);
	}

	if(in_pokefam())
	{
		if(git_exists("Ezandora-Helix-Fossil"))
		{
		auto_log_info("Combat via Ezandora:", "green");
		boolean ignore = cli_execute("Pocket Familiars");
		return "";		//does not matter what it returns here. the cli_execute above does the entire combat
		}
	}

	//If in Avant Guard, want to make sure the enemy is set correctly to the bodyguard
	//If waffle has been used ignore and just use enemy as set in combat handler
	if(in_avantGuard() && ag_is_bodyguard() && get_property("_auto_combatState") != "(it11311)")
	{
		enemy = to_monster(substring(get_property("lastEncounter"), 0, index_of(get_property("lastEncounter"), " acting as")));
	}
	
	disguises_combat_helper(round, enemy, text);		//disguise delimit mask identification
	fotd_combat_helper();				//fall of the dinosaurs dino identification

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
				combat_status_add(doThis);
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
	
	// stage 1 = 1st round actions: puzzle boss, pickpocket, duplicate, things that are only allowed if they are the first action you take.
	retval = auto_combatDefaultStage1(round, enemy, text);
	if(retval != "") return retval;
	
	// stage 2 = enders: escape, replace, instakill, yellowray and other actions that instantly end combat
	retval = auto_combatDefaultStage2(round, enemy, text);
	if(retval != "") return retval;
	
	// stage 3 = debuff: delevel, stun, curse, damage over time
	retval = auto_combatDefaultStage3(round, enemy, text);
	if(retval != "") return retval;
	
	// stage 4 = prekill. copy, sing along, flyer and other things that need to be done after delevel but before killing
	retval = auto_combatDefaultStage4(round, enemy, text);
	if(retval != "") return retval;

	// stage 5 = kill
	retval = auto_combatDefaultStage5(round, enemy, text);
	if(retval != "") return retval;
	
	abort("We reached the end of combat script without finding anything to do");
	return "";
}
