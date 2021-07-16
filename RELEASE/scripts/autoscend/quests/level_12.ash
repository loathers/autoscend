string auto_warSide()
{
	//returns the side you are fighting for in the form of a string.
	//this is used to check checking mafia's sidequest tracking, as they use these string values to indicate which side completed which quest.
	if(get_property("auto_hippyInstead").to_boolean())
	{
		return "hippy";
	}
	else
	{
		return "fratboy";
	}
}

int auto_warSideQuestsDone()
{
	//counts how many sidequests you have completed for the side for which you are fighting in the war.

	int sidequests_done = 0;
	
	if(get_property("sidequestArenaCompleted") == auto_warSide())
	{
		sidequests_done++;
	}
	if(get_property("sidequestJunkyardCompleted") == auto_warSide())
	{
		sidequests_done++;
	}
	if(get_property("sidequestLighthouseCompleted") == auto_warSide())
	{
		sidequests_done++;
	}
	if(get_property("sidequestOrchardCompleted") == auto_warSide())
	{
		sidequests_done++;
	}
	if(get_property("sidequestNunsCompleted") == auto_warSide())
	{
		sidequests_done++;
	}
	if(get_property("sidequestFarmCompleted") == auto_warSide())
	{
		sidequests_done++;
	}
	
	return sidequests_done;
}

WarPlan auto_warSideQuestsState()
{
	// Returns a record indicating current completion state of the war sidequests.

	WarPlan ret;
	ret.do_arena = get_property("sidequestArenaCompleted") == auto_warSide();
	ret.do_junkyard = get_property("sidequestJunkyardCompleted") == auto_warSide();
	ret.do_lighthouse = get_property("sidequestLighthouseCompleted") == auto_warSide();
	ret.do_orchard = get_property("sidequestOrchardCompleted") == auto_warSide();
	ret.do_nuns = get_property("sidequestNunsCompleted") == auto_warSide();
	ret.do_farm = get_property("sidequestFarmCompleted") == auto_warSide();
	return ret;
}

int auto_warEnemiesRemaining()
{
	// Returns the number of enemies left to defeat in the fratboy-hippy war.
	
	int enemiesRemaining = 1000;
	if(in_pokefam())
	{
		//Pokefam only has 500 total to defeat with all 6 sidequests immediately accessible.
		//TODO: find out if pokefam starts with 500 enemies defeated out of 1000 total. or 0 defeated out of 500 total
		//current code assumes it starts with 0 defeated out of 500 total. this is a guess.
		if(auto_warSide() == "hippy")
		{
			enemiesRemaining = 500 - get_property("fratboysDefeated").to_int();
		}
		else
		{
			enemiesRemaining = 500 - get_property("hippiesDefeated").to_int();
		}
	}
	else
	{
		if(auto_warSide() == "hippy")
		{
			enemiesRemaining = 1000 - get_property("fratboysDefeated").to_int();
		}
		else
		{
			enemiesRemaining = 1000 - get_property("hippiesDefeated").to_int();
		}
	}
	return enemiesRemaining;
}

int auto_warKillsPerBattle()
{
	// returns how many enemies you will kill per battle at hippy-fratboy war at your current number of sidequests done.
	return auto_warKillsPerBattle(auto_warSideQuestsDone());
}

int auto_warKillsPerBattle(int sidequests)
{
	// returns how many enemies you will kill per battle at hippy-fratboy war at a specified number of sidequests done.
	
	int kills = 2**sidequests;
		
	// Avatar of Sneaky Pete has a motorbike mod that gives +3 kills/battle.
	if(get_property("peteMotorbikeCowling") == "Rocket Launcher")
	{
		kills += 3;
	}
	
	//License to Adventure Path specific check
	//TODO add it. it deals +3 kills per battle
	
	return kills;
}

int auto_estimatedAdventuresForChaosButterfly()
{
	// Returns an ESTIMATE of how many adventures it will take to acquire a chaos butterfly.
	
	if(get_property("chaosButterflyThrown").to_boolean() || item_amount($item[chaos butterfly]) > 0)
	{
		return 0;
	}
	if(canPull($item[chaos butterfly]))
	{
		return 0;
	}
	// 4 enemies in [The Castle in the Clouds in the Sky (Ground Floor)] ~25% chance to encounter the one we want.
	// roughly estimate 4 turns per possibility giant encounter. at base drop this means ~20 adv needed.
	int expected_turns_until_fight = 4;
	if(canYellowRay())
	{
		return expected_turns_until_fight;
	}

	// This function is called frequently (especially by auto_bestWarPlan), so
	// to avoid adding a maximizer call to every single adventure at the war
	// sidequests, estimate this value the first time this function is called
	// during each execution of the script.

	static float expectedItemDropMulti;
	static {
		auto_log_info("Estimating adventures needed to obtain chaos butterfly.", "green");
		handleFamiliar("item");
		simMaximizeWith("20 item");
		expectedItemDropMulti = 1 + simValue("Item Drop")/100;
	}

	float butterfly_drop_rate = 0.2;
	float expected_fights_until_drop = max(1.0, 1.0/(expectedItemDropMulti * butterfly_drop_rate));

	int ret = ceil(expected_turns_until_fight * expected_fights_until_drop);
	auto_log_info("I estimate it will take " + ret + " fights for a chaos butterfly to drop.", "green");
	return ret;
}

int auto_estimatedAdventuresForDooks()
{
	int advCost = 40;
	
	//TODO account for having done free fights in those zones
	advCost -= $location[McMillicancuddy's Barn].turns_spent;
	advCost -= $location[McMillicancuddy's Pond].turns_spent;
	advCost -= $location[McMillicancuddy's Back 40].turns_spent;
	advCost -= $location[McMillicancuddy's Other Back 40].turns_spent;
	
	//these paths cannot use butterfly
	if(in_bhy() || in_pokefam())
	{
		return advCost;
	}
	
	//chaos butterfly calculations
	int advToGetCB = auto_estimatedAdventuresForChaosButterfly();
	if(get_property("chaosButterflyThrown").to_boolean() || item_amount($item[chaos butterfly]) > 0)
	{
		advCost -= 15;
	}
	else if(advToGetCB < 15)
	{
		advCost = advCost - 15 + advToGetCB;
	}
	
	return advCost;
}

WarPlan warplan_from_bitmask(int mask)
{
	WarPlan ret;
	if(auto_warSide() == "fratboy")
	{
		ret.do_arena      = to_boolean((mask>>0)&1);
		ret.do_junkyard   = to_boolean((mask>>1)&1);
		ret.do_lighthouse = to_boolean((mask>>2)&1);
		ret.do_orchard    = to_boolean((mask>>3)&1);
		ret.do_nuns       = to_boolean((mask>>4)&1);
		ret.do_farm       = to_boolean((mask>>5)&1);
	}
	else
	{
		ret.do_arena      = to_boolean((mask>>5)&1);
		ret.do_junkyard   = to_boolean((mask>>4)&1);
		ret.do_lighthouse = to_boolean((mask>>3)&1);
		ret.do_orchard    = to_boolean((mask>>2)&1);
		ret.do_nuns       = to_boolean((mask>>1)&1);
		ret.do_farm       = to_boolean((mask>>0)&1);
	}
	return ret;
}

int bitmask_from_warplan(WarPlan plan)
{
	int bitmask;
	if(auto_warSide() == "fratboy")
	{
		bitmask |= plan.do_arena.to_int()      << 0;
		bitmask |= plan.do_junkyard.to_int()   << 1;
		bitmask |= plan.do_lighthouse.to_int() << 2;
		bitmask |= plan.do_orchard.to_int()    << 3;
		bitmask |= plan.do_nuns.to_int()       << 4;
		bitmask |= plan.do_farm.to_int()       << 5;
	}
	else
	{
		bitmask |= plan.do_arena.to_int()      << 5;
		bitmask |= plan.do_junkyard.to_int()   << 4;
		bitmask |= plan.do_lighthouse.to_int() << 3;
		bitmask |= plan.do_orchard.to_int()    << 2;
		bitmask |= plan.do_nuns.to_int()       << 1;
		bitmask |= plan.do_farm.to_int()       << 0;
	}
	return bitmask;
}

WarPlan auto_bestWarPlan()
{
	if(in_koe())
	{
		WarPlan do_nothing;
		return do_nothing;
	}
	
	//if a sidequest is done already then consider it as planned.
	WarPlan plan = auto_warSideQuestsState();
	
	//Path specific blocks where a sidequest is not possible or really bad.
	boolean considerArena = true;
	boolean considerJunkyard = true;
	boolean considerLighthouse = true;
	boolean considerOrchard = true;
	boolean considerNuns = true;
	boolean considerFarm = true;
	
	if(in_bhy() || in_pokefam())
	{
		considerArena = false;
		considerJunkyard = false;
	}
	if(auto_my_path() == "Way of the Surprising Fist")
	{
		considerNuns = false;
	}
	if(in_tcrs())
	{
		considerNuns = false;
		considerOrchard = false;
	}
	if (in_glover())
	{
		considerArena = false;
	}
	
	// Calculate the adventure cost of doing each sidequest.
	int advCostArena = 0;		//Arena actual cost is 0 adventures... unless you mess it up. TODO: check if messed up.
	int advCostJunkyard = 10;	//placeholder estimate. TODO actual math
	int advCostLighthouse = 10;	//placeholder estimate. TODO actual math
	int advCostOrchard = 10;	//placeholder estimate. TODO actual math
	int advCostNuns = 20;		//placeholder estimate. TODO actual math
	int advCostFarm = auto_estimatedAdventuresForDooks();

	// Start with the sidequests already completed.
	// Greedily add the sidequest that saves the most adventures, breaking
	// early if no sidequest saves any adventures.
	for (int i=0; i<6; i++)
	{
		WarPlan bestPlan;
		int bestQuestProfit = 0;
		int profit = 0;

		if(considerFarm)
		{
			WarPlan plan_doing_farm;
			plan_doing_farm.do_farm = true;
			profit = auto_warTotalBattles(plan) - auto_warTotalBattles(plan_doing_farm) - advCostFarm;
			if(profit > bestQuestProfit)
			{
				bestQuestProfit = profit;
				bestPlan = plan_doing_farm;
			}
		}
		
		if(considerNuns)
		{
			WarPlan plan_doing_nuns;
			plan_doing_nuns.do_nuns = true;
			profit = auto_warTotalBattles(plan) - auto_warTotalBattles(plan_doing_nuns) - advCostNuns;
			if(profit > bestQuestProfit)
			{
				bestQuestProfit = profit;
				bestPlan = plan_doing_nuns;
			}
		}

		if(considerOrchard)
		{
			WarPlan plan_doing_orchard;
			plan_doing_orchard.do_orchard = true;
			profit = auto_warTotalBattles(plan) - auto_warTotalBattles(plan_doing_orchard) - advCostOrchard;
			if(profit > bestQuestProfit)
			{
				bestPlan = plan_doing_orchard;
				bestQuestProfit = profit;
			}
		}

		if(considerLighthouse)
		{
			WarPlan plan_doing_lighthouse;
			plan_doing_lighthouse.do_lighthouse = true;
			profit = auto_warTotalBattles(plan) - auto_warTotalBattles(plan_doing_lighthouse) - advCostLighthouse;
			if(profit > bestQuestProfit)
			{
				bestPlan = plan_doing_lighthouse;
				bestQuestProfit = profit;
			}
		}

		if(considerJunkyard)
		{
			WarPlan plan_doing_junkyard;
			plan_doing_junkyard.do_junkyard = true;
			profit = auto_warTotalBattles(plan) - auto_warTotalBattles(plan_doing_junkyard) - advCostJunkyard;
			if(profit > bestQuestProfit)
			{
				bestPlan = plan_doing_junkyard;
				bestQuestProfit = profit;
			}
		}

		// Currently not implemented properly for hippies.
		// TODO(taltamir) implement it and then remove this guard
		if(considerArena && auto_warSide() != "hippy")
		{
			WarPlan plan_doing_arena;
			plan_doing_arena.do_arena = true;
			profit = auto_warTotalBattles(plan) - auto_warTotalBattles(plan_doing_arena) - advCostArena;
			if(profit > bestQuestProfit)
			{
				bestPlan = plan_doing_arena;
				bestQuestProfit = profit;
			}
		}

		if(bestPlan == plan)
		{
			break;
		}
		plan = bestPlan;
	}

	return plan;
}

int __auto_warTotalBattles(int plan, int remaining)
{
	// Prefer to use the version of this function that uses a WarPlan.
	// This is not meant to be used externally.

    // |plan| is a 6-bit bitmask where the lowest bit is a 1
    // if we finish the first quest, etc.
 
    // E.g. 39 is (32+0+0+4+2+1), meaning we are planning
    // to finish quests 1, 2, 3, 6.
 
    int total_battles = 0;
    int completed_quests = 0;
 
    void fightUntilRemaining(int target_remaining)
    {
        int to_kill = max(0, remaining-target_remaining);
        int kills_per_battle = auto_warKillsPerBattle(completed_quests);
        int battles = ceil(to_kill.to_float()/kills_per_battle);
 
        total_battles += battles;
        remaining -= battles * kills_per_battle;
    }
 
    // 3 quests are accessible simultaneously.
    completed_quests += plan&1;
    completed_quests += (plan>>1)&1;
    completed_quests += (plan>>2)&1;
 
    fightUntilRemaining(1000-64);
 
    // Mark newly accessible quest completed, fight until next quest is available.
    completed_quests += (plan>>3)&1;
    fightUntilRemaining(1000-192);
 
    completed_quests += (plan>>4)&1;
    fightUntilRemaining(1000-458);
 
    completed_quests += (plan>>5)&1;
    fightUntilRemaining(0);
 
    return total_battles;
}

int auto_warTotalBattles(WarPlan plan, int remaining)
{
	return __auto_warTotalBattles(bitmask_from_warplan(plan), remaining);
}
 
int auto_warTotalBattles(WarPlan plan)
{
    return auto_warTotalBattles(plan, auto_warEnemiesRemaining());
}

void equipWarOutfit()
{
	equipWarOutfit(true);
}

void equipWarOutfit(boolean lock)
{
	//equip the war outfit suitable for your side of the war. due to problem with maximizer we use autoForceEquip
	//lock means we want to lock the maximizer slots in question for the rest of the current loop (aka the next autoAdv).
	//sometimes we wear the outfit. visit url. fail and want to continue on to do another quest instead of aborting or returning true.
	//in such cases we want lock to be false
	
	boolean[item] parts;
	if(auto_warSide() == "hippy")
	{
		parts = $items[Reinforced Beaded Headband, Bullet-proof Corduroys, Round Purple Sunglasses];
	}
	else
	{
		parts = $items[Beer Helmet, Distressed Denim Pants, Bejeweled Pledge Pin];
	}
	foreach it in parts
	{
		if(item_amount(it) == 0 && equipped_amount(it) == 0)
		{
			if(closet_amount(it) > 0)
			{
				take_closet(1, it);
			}
			else abort("I mysteriously do not have [" +it+ "] which is needed for the war outfit");
		}
		if(lock)
		{
			autoForceEquip(it);
		}
		else
		{
			equip(it);
		}
	}
}

boolean haveWarOutfit(boolean canWear)
{
	if(!get_property("auto_hippyInstead").to_boolean())
	{
		return possessOutfit("Frat Warrior Fatigues", canWear);
	}
	else
	{
		return possessOutfit("War Hippy Fatigues", canWear);
	}
	return true;
}

boolean haveWarOutfit() {
	return haveWarOutfit(false);
}

boolean warAdventure()
{
	if(auto_have_familiar($familiar[Space Jellyfish]) && (get_property("_spaceJellyfishDrops").to_int() < 3))
	{
		handleFamiliar($familiar[Space Jellyfish]);
	}

	if(!get_property("auto_hippyInstead").to_boolean())
	{
		if(!autoAdv(1, $location[The Battlefield (Frat Uniform)]))
		{
			set_property("hippiesDefeated", get_property("hippiesDefeated").to_int() + 1);
			string temp = visit_url("island.php");
		}
	}
	else
	{
		if(!autoAdv(1, $location[The Battlefield (Hippy Uniform)]))
		{
			set_property("fratboysDefeated", get_property("fratboysDefeated").to_int() + 1);
			string temp = visit_url("island.php");
		}
	}
	return true;
}

boolean L12_getOutfit()
{
	if (internalQuestStatus("questL12War") != 0)
	{
		return false;
	}

	// if you already have the war outfit we don't need to do anything now
	if (haveWarOutfit())
	{
		return false;
	}
	
	//heavy rains softcore pull handling
	if(!in_hardcore() && (auto_my_path() == "Heavy Rains"))
	{
		// auto_warhippyspy indicates rainman was already used to copy a war hippy spy in heavy rains. if it failed to YR pull missing items
		if(get_property("auto_warhippyspy") == "done" && get_property("auto_hippyInstead").to_boolean())
		{
			pullXWhenHaveY($item[Reinforced Beaded Headband], 1, 0);
			pullXWhenHaveY($item[Round Purple Sunglasses], 1, 0);
			pullXWhenHaveY($item[Bullet-proof Corduroys], 1, 0);			
		}
		// auto_orcishfratboyspy indicates rainman was already used to copy an orcish frat boy in heavy rains. if it failed to YR pull missing items
		if(get_property("auto_orcishfratboyspy") == "done" && !get_property("auto_hippyInstead").to_boolean())
		{
			pullXWhenHaveY($item[Beer Helmet], 1, 0);
			pullXWhenHaveY($item[Bejeweled Pledge Pin], 1, 0);
			pullXWhenHaveY($item[Distressed Denim Pants], 1, 0);
		}
	}

	//softcore pull handling for all other paths
	if(!in_hardcore() && (auto_my_path() != "Heavy Rains"))
	{
		if(get_property("auto_hippyInstead").to_boolean())
		{
			pullXWhenHaveY($item[Reinforced Beaded Headband], 1, 0);
			pullXWhenHaveY($item[Round Purple Sunglasses], 1, 0);
			pullXWhenHaveY($item[Bullet-proof Corduroys], 1, 0);			
		}
		else
		{
			pullXWhenHaveY($item[Beer Helmet], 1, 0);
			pullXWhenHaveY($item[Bejeweled Pledge Pin], 1, 0);
			pullXWhenHaveY($item[Distressed Denim Pants], 1, 0);
		}
	}

	// if you have war outfit now then you just pulled it. so this time we return true as something changed
	if(haveWarOutfit())
	{
		return true;
	}
	// if you reached this point you are either in hardcore or are in softcore but ran out of pulls
	// if really in softcore and out of pulls then returning false here lets you skip it until tomorrow
	if(!in_hardcore())
	{
		return false;
	}
	
	// if outfit could not be pulled and have a [Filthy Hippy Disguise] outfit then wear it and adventure in Frat House to get war outfit
	if (!get_property("auto_hippyInstead").to_boolean() && possessOutfit("Filthy Hippy Disguise"))
	{
		autoOutfit("Filthy Hippy Disguise");
		return autoAdv(1, $location[Wartime Frat House]);
	}
	
	// if outfit could not be pulled and have a [Frat Boy Ensemble] outfit then wear it and adventure in Hippy Camp to get war outfit
	if (get_property("auto_hippyInstead").to_boolean() && possessOutfit("Frat Boy Ensemble"))
	{
		autoOutfit("Frat Boy Ensemble");
		return autoAdv(1, $location[Wartime Hippy Camp]);
	}
	
	if(L12_preOutfit())
	{
		return true;
	}
	return false;
}

boolean L12_preOutfit()
{
	if(get_property("lastIslandUnlock").to_int() != my_ascensions())
	{
		return false;
	}
	
	// in softcore you will pull the war outfit, no need to get pre outfit
	if(!in_hardcore())
	{
		return false;
	}
	
	if(my_level() < 9)
	{
		return false;
	}
	
	if(haveWarOutfit())
	{
		return false;
	}
	
	// if siding with frat and already own [Filthy Hippy Disguise] outfit needed to get the frat boy war outfit
	if (!get_property("auto_hippyInstead").to_boolean() && possessOutfit("Filthy Hippy Disguise"))
	{
		return false;
	}
	
	// if siding with hippies and already own [Frat Boy Ensemble] outfit needed to get the hippy war outfit
	if (get_property("auto_hippyInstead").to_boolean() && possessOutfit("Frat Boy Ensemble"))
	{
		return false;
	}
	
	if (isActuallyEd())
	{
		if(!canYellowRay() && (my_level() < 12))
		{
			return false;
		}
	}

	if(have_skill($skill[Calculate the Universe]) && my_daycount() == 1 && get_property("_universeCalculated").to_int() < get_property("skillLevel144").to_int())
	{
		return false;
	}

	if(in_gnoob() && auto_have_familiar($familiar[Robortender]))
	{
		if(!have_skill($skill[Ink Gland]) && (item_amount($item[Shot of Granola Liqueur]) == 0))
		{
			handleFamiliar($familiar[Robortender]);
		}
	}

	boolean adventure_status = false;
	// fighting for fratboys, adventure in hippy camp for [filthy hippy disguise] outfit to then adventure in frat house for frat war outfit
	if(!get_property("auto_hippyInstead").to_boolean())
	{
		auto_log_info("Trying to acquire a filthy hippy outfit", "blue");
		if(internalQuestStatus("questL12War") == -1)
		{
			adventure_status = autoAdv(1, $location[Hippy Camp]);
		}
		else
		{
			adventure_status = autoAdv(1, $location[Wartime Hippy Camp]);
		}
	}
	// fighting for hippies, adventure in orcish frat house for [Frat Boy Ensemble] outfit to then adventure in hippy camp for hippy war outfit
	else
	{
		auto_log_info("Trying to acquire a frat boy ensemble", "blue");
		if(internalQuestStatus("questL12War") == -1)
		{
			adventure_status = autoAdv(1, $location[Frat House]);
		}
		else
		{
			adventure_status = autoAdv(1, $location[Wartime Frat House]);
		}
	}
	// We check the adventure status to avoid an infinite loop if we can't access any of these zones.
	if(adventure_status)
	{
		return true;
	}
	else
	{
		auto_log_critical("Please report this. L12 war pre outfit acquisition mysteriously failed... skipping", "red");
		return false;
	}
}

boolean L12_startWar()
{
	if (internalQuestStatus("questL12War") != 0)
	{
		return false;
	}

	if (in_koe())
	{
		return false;
	}

	if (!haveWarOutfit(true))
	{
		return false;
	}

	if(get_property("lastIslandUnlock").to_int() < my_ascensions())
	{
		return false;
	}

	if((my_mp() > 60) || considerGrimstoneGolem(true))
	{
		handleBjornify($familiar[Grimstone Golem]);
	}
	
	if((my_path() != "Dark Gyffte") && (my_mp() > 50) && have_skill($skill[Incredible Self-Esteem]) && !get_property("_incredibleSelfEsteemCast").to_boolean())
	{
		use_skill(1, $skill[Incredible Self-Esteem]);
	}

	// wear the appropriate war outfit based on auto_hippyInstead
	equipWarOutfit();

	// start the war when siding with frat boys
	if(!get_property("auto_hippyInstead").to_boolean())
	{
		auto_log_info("Must save the ferret!!", "blue");
		autoAdv(1, $location[Wartime Hippy Camp]);
		
		//if war started, accept flyer quest for fratboys.
		//this is only started here and only for frat.
		//move this to dedicated function that can start it for both sides as appropriate
		if(internalQuestStatus("questL12War") == 1)
		{
			visit_url("bigisland.php?place=concert&pwd");	
		}
	}
	// start the war when siding with hippies
	else
	{
		auto_log_info("Must save the goldfish!!", "blue");
		autoAdv(1, $location[Wartime Frat House]);
	}
		
	return true;
}

boolean L12_filthworms()
{
	if (internalQuestStatus("questL12War") != 1 || get_property("sidequestOrchardCompleted") != "none")
	{
		return false;
	}
	if (in_tcrs() || in_koe())
	{
		return false;
	}
	if(item_amount($item[Heart of the Filthworm Queen]) > 0)
	{
		return false;
	}

	auto_log_info("Doing the orchard.", "blue");
	
	//can fight filthworms early as fratboys so long as you do not wear a frat outfit. 
	//maximizer can accidentally end up wearing the outfit and cause infinite loop.
	//might want to fight filthworms early to flyer. determining exactly when is overly complex so we are just assuming always.
	//the frat outfits are pretty weak and as such its no big loss if we don't wear it when doing it early.
	if(auto_warSide() == "fratboy" && get_property("hippiesDefeated").to_int() < 64)
	{
		//helmet is least useful with +40 max MP enchantment.
		if(possessOutfit("frat warrior fatigues"))
		{
			addToMaximize("-equip beer helmet");
		}
		//pants and hat are identical, randomly selected hat for exclusion
		if(possessOutfit("frat boy ensemble"))
		{
			addToMaximize("-equip orcish baseball cap");
		}
	}
	
	//use the stench glands to unlock the next step of the quest.
	if(item_amount($item[Filthworm Hatchling Scent Gland]) > 0)
	{
		use(1, $item[Filthworm Hatchling Scent Gland]);
	}
	if(item_amount($item[Filthworm Drone Scent Gland]) > 0)
	{
		use(1, $item[Filthworm Drone Scent Gland]);
	}
	if(item_amount($item[Filthworm Royal Guard Scent Gland]) > 0)
	{
		use(1, $item[Filthworm Royal Guard Scent Gland]);
	}

	//if we can kill the queen we don't care about gland drops anymore. kill her and finish this
	if(have_effect($effect[Filthworm Guard Stench]) > 0)
	{
		return autoAdv(1, $location[The Filthworm Queen\'s Chamber]);
	}

	//if we can guarentee stealing the stench gland then no point in buffing item drop
	if(auto_have_skill($skill[Lash of the Cobra]) && get_property("_edLashCount").to_int() < 30)
	{
		auto_log_info("Ed will steal stench glands using [Lash of the Cobra]");
	}
//	else if(auto_have_skill($skill[Smash & Graaagh]))
//	{
//		//only 30 per day, can't find mafia tracking for it so it can't be implemented yet.
//		//Needs to be implemented in auto_combat.ash too before uncommenting this block
//		auto_log_info("Zombie Master will steal stench glands using [Smash & Graaagh]");
//	}
	else if(get_property("_xoHugsUsed").to_int() < 10 && canChangeToFamiliar($familiar[XO Skeleton]))
	{
		auto_log_info("Will steal stench glands using [XO Skeleton]");
		handleFamiliar($familiar[XO Skeleton]);
	}
	//TODO add IOTM cat burglar stealing support here with another else if
	// or if we're about to yellow ray
	else if(canYellowRay())
	{
		auto_log_info("We're going to yellow ray the stench glands.");
	}
	else		//could not guarentee stealing. buff item drops instead
	{
		buffMaintain($effect[Joyful Resolve], 0, 1, 1);
		buffMaintain($effect[Kindly Resolve], 0, 1, 1);
		buffMaintain($effect[Fortunate Resolve], 0, 1, 1);
		buffMaintain($effect[One Very Clear Eye], 0, 1, 1);
		buffMaintain($effect[Human-Fish Hybrid], 0, 1, 1);
		buffMaintain($effect[Human-Human Hybrid], 0, 1, 1);
		buffMaintain($effect[Human-Machine Hybrid], 0, 1, 1);
		buffMaintain($effect[Unusual Perspective], 0, 1, 1);
		buffMaintain($effect[Eagle Eyes], 0, 1, 1);
		buffMaintain($effect[Heart of Lavender], 0, 1, 1);
		asdonBuff($effect[Driving Observantly]);
		bat_formBats();

		if(get_property("auto_dickstab").to_boolean())
		{
			buffMaintain($effect[Wet and Greedy], 0, 1, 1);
		}
		buffMaintain($effect[Frosty], 0, 1, 1);
		
		//craft IOTM derivative that gives high item bonus
		if((!possessEquipment($item[A Light That Never Goes Out])) && (item_amount($item[Lump of Brituminous Coal]) > 0))
		{
			buyUpTo(1, $item[third-hand lantern]);
			autoCraft("smith", 1, $item[Lump of Brituminous Coal], $item[third-hand lantern]);
		}

		if (!canChangeToFamiliar($familiar[XO Skeleton]) && catBurglarHeistsLeft() < 1) {
			//fold and remove maximizer block on using IOTM with 9 charges a day that doubles item drop chance
			januaryToteAcquire($item[Broken Champagne Bottle]);
		}

		if(auto_my_path() == "Live. Ascend. Repeat.")
		{
			equipMaximizedGear();
			if(item_drop_modifier() < 400.0)
			{
				abort("Can not handle item drop amount for the Filthworms, deja vu!! Either get us to +400% and rerun or do it yourself.");
			}
		}
	}

	if (auto_cargoShortsOpenPocket(343)) // skip straight to the Royal Guard Chamber
	{
		handleTracker($item[Cargo Cultist Shorts], $effect[Filthworm Drone Stench], "auto_otherstuff");
	}
	
	boolean retval = false;
	if(have_effect($effect[Filthworm Drone Stench]) > 0)
	{
		retval = autoAdv(1, $location[The Royal Guard Chamber]);
	}
	else if(have_effect($effect[Filthworm Larva Stench]) > 0)
	{
		retval = autoAdv(1, $location[The Feeding Chamber]);
	}
	else
	{
		retval = autoAdv(1, $location[The Hatching Chamber]);
	}

	return retval;
}

boolean L12_orchardFinalize()
{
	if (get_property("hippiesDefeated").to_int() < 64 && !get_property("auto_hippyInstead").to_boolean())
	{
		return false;
	}
	if (get_property("sidequestOrchardCompleted") != "none" || item_amount($item[Heart of the Filthworm Queen]) == 0)
	{
		return false;
	}
	if(item_amount($item[A Light that Never Goes Out]) == 1)
	{
		pulverizeThing($item[A Light that Never Goes Out]);
	}
	equipWarOutfit();
	visit_url("bigisland.php?place=orchard&action=stand&pwd=");
	visit_url("shop.php?whichshop=hippy");
	return true;
}

void gremlinsFamiliar()
{
	//when fighting gremlins we want to minimize the familiar ability to cause damage.
	//maximizer will try to force an equip into familiar slot. So disable maximizer switching of familiar equipment
	addToMaximize("-familiar");
	
	familiar hundred_fam = to_familiar(get_property("auto_100familiar"));
	boolean strip_familiar = true;
	if(hundred_fam != $familiar[none] && (isAttackFamiliar(hundred_fam) || hundred_fam.block))	//in 100% familiar run with an attack or block familiar
	{
		set_property("_auto_bad100Familiar", true);			//do not buff bad familiar
		
		if(get_property("questS01OldGuy") == "unstarted" && !get_property("_auto_seaQuestStartedToday").to_boolean())
		{
			//easier to track if we tried today than to track if it is allowed in current path
			set_property("_auto_seaQuestStartedToday", true);
			visit_url("place.php?whichplace=sea_oldman&action=oldman_oldman");	//get bathysphere by starting the sea quest
		}
		if(possessEquipment($item[little bitty bathysphere]))
		{
			equip($slot[familiar], $item[little bitty bathysphere]);
			strip_familiar = false;
		}
	}
	if(strip_familiar)
	{
		equip($slot[familiar], $item[none]);	//strip familiar equipment if not in 100% run to avoid passive dmg
	}
}

boolean L12_gremlins()
{
	if (internalQuestStatus("questL12War") != 1 || get_property("sidequestJunkyardCompleted") != "none")
	{
		return false;
	}
	if (in_koe() || in_pokefam() || in_bhy())
	{
		return false;
	}
	if(get_property("auto_hippyInstead").to_boolean() && (get_property("fratboysDefeated").to_int() < 192))
	{
		return false;
	}
	if(in_glover())
	{
		int need = 30 - item_amount($item[Doc Galaktik\'s Pungent Unguent]);
		if((need > 0) && (item_amount($item[Molybdenum Pliers]) == 0))
		{
			int meatNeed = need * npc_price($item[Doc Galaktik\'s Pungent Unguent]);
			if(my_meat() < meatNeed)
			{
				return false;
			}
			buyUpTo(30, $item[Doc Galaktik\'s Pungent Unguent]);
		}
	} else {
		if (item_amount($item[Seal Tooth]) == 0) {
			acquireHermitItem($item[Seal Tooth]);
			if (item_amount($item[Seal Tooth]) == 0) {
				abort("We don't have a seal tooth. Stasising Gremlins is not going to go well if you lack something to stasis them with.");
			}
		}
	}

	if(0 < have_effect($effect[Curse of the Black Pearl Onion])) {
		uneffect($effect[Curse of the Black Pearl Onion]);
	}

	if(item_amount($item[molybdenum magnet]) == 0)
	{
		//if fighting for frat immediately grab it
		if(!get_property("auto_hippyInstead").to_boolean())
		{
			equipWarOutfit();
			visit_url("bigisland.php?action=junkman&pwd");
		}
		
		//if fighting for hippies grab magnet when enough fratboys killed
		if(get_property("auto_hippyInstead").to_boolean() && (get_property("fratboysDefeated").to_int() >= 192))
		{
			equipWarOutfit();
			visit_url("bigisland.php?action=junkman&pwd");
		}
		
		//if still don't have magnet something went wrong
		if(item_amount($item[molybdenum magnet]) == 0)
		{
			abort("We don't have the molybdenum magnet but should... please get it and rerun the script");
		}
		else return true;
	}

	if(auto_my_path() == "Disguises Delimit")
	{
		abort("Do gremlins manually, sorry. Or set sidequestJunkyardCompleted=fratboy and we will just skip them");
	}

	// Avoid killing the tool gremlins using familiar damage.
	gremlinsFamiliar();

	auto_log_info("Doing them gremlins", "blue");
	addToMaximize("20dr,1da 1000max,3hp,-3ml");
	acquireHP();
	if(!bat_wantHowl($location[over where the old tires are]))
	{
		bat_formMist();
	}
	songboomSetting("dr");
	if(item_amount($item[molybdenum hammer]) == 0)
	{
		autoAdv(1, $location[Next to that barrel with something burning in it], "auto_JunkyardCombatHandler");
		return true;
	}

	if(item_amount($item[molybdenum screwdriver]) == 0)
	{
		autoAdv(1, $location[Out by that rusted-out car], "auto_JunkyardCombatHandler");
		return true;
	}

	if(item_amount($item[molybdenum crescent wrench]) == 0)
	{
		autoAdv(1, $location[over where the old tires are], "auto_JunkyardCombatHandler");
		return true;
	}

	if(item_amount($item[Molybdenum Pliers]) == 0)
	{
		autoAdv(1, $location[near an abandoned refrigerator], "auto_JunkyardCombatHandler");
		return true;
	}
	equipWarOutfit();
	visit_url("bigisland.php?action=junkman&pwd");
	return true;
}

boolean L12_sonofaBeach()
{
	if (internalQuestStatus("questL12War") != 1 || get_property("sidequestLighthouseCompleted") != "none")
	{
		return false;
	}
	if (in_koe())
	{
		return false;
	}
	if(!get_property("auto_hippyInstead").to_boolean())
	{
		if (get_property("sidequestJunkyardCompleted") == "none")
		{
			return false;
		}
	}
	if((get_property("fratboysDefeated").to_int() < 64) && get_property("auto_hippyInstead").to_boolean())
	{
		return false;
	}
	if(item_amount($item[barrel of gunpowder]) >= 5)
	{
		return false;
	}

	if(in_pokefam())
	{
		if(contains_text($location[Sonofa Beach].combat_queue, to_string($monster[Lobsterfrogman])))
		{
			if(timeSpinnerCombat($monster[Lobsterfrogman], ""))
			{
				return true;
			}
		}
	}

	if(chateaumantegna_havePainting() && !get_property("chateauMonsterFought").to_boolean() && (get_property("chateauMonster") == $monster[Lobsterfrogman]))
	{
		auto_sourceTerminalEducate($skill[Extract], $skill[Digitize]);
		if(chateaumantegna_usePainting())
		{
			return true;
		}
	}

	if (isActuallyEd() && item_amount($item[Talisman of Horus]) == 0 && have_effect($effect[Taunt of Horus]) == 0)
	{
		return false;
	}
	if(ed_DelayNC(100.0))	//zerg rush can deal 100% of maxHP in damage
	{
		return false;	//ed is not prepared. delay
	}

	//Seriously? http://alliancefromhell.com/viewtopic.php?t=1338
	if(item_amount($item[Wool Hat]) == 1)
	{
		pulverizeThing($item[Wool Hat]);
	}
	if(item_amount($item[Goatskin Umbrella]) == 1)
	{
		pulverizeThing($item[Goatskin Umbrella]);
	}

	if(auto_my_path() != "Live. Ascend. Repeat.")
	{
		if (providePlusCombat(25, true, true) < 0.0)
		{
			auto_log_warning("Something is keeping us from getting a suitable combat rate, we have: " + numeric_modifier("Combat Rate") + " and Lobsterfrogmen.", "red");
			equipBaseline();
			return false;
		}
	}

	if(item_amount($item[barrel of gunpowder]) < 4)
	{
		set_property("auto_doCombatCopy", "yes");
	}

	boolean retval = autoAdv($location[Sonofa Beach]);
	
	set_property("auto_doCombatCopy", "no");
	edAcquireHP();
	
	return retval;
}

boolean L12_sonofaPrefix()
{
	// this appears to be a copy & paste of L12_sonofaBeach() with some small changes
	// for Vote Monster/Macrometeor shenanigans. Refactor this so only the relevant code remains.

	if (internalQuestStatus("questL12War") != 1 || get_property("sidequestLighthouseCompleted") != "none")
	{
		return false;
	}
	if(L12_sonofaFinish())
	{
		return true;
	}

	if(in_koe())
	{
		return false;
	}

	if(get_property("_sourceTerminalDigitizeMonster") == $monster[Lobsterfrogman])
	{
		return false;
	}
	if(item_amount($item[barrel of gunpowder]) >= 4 && !auto_voteMonster())
	{
		return false;
	}
	if(item_amount($item[barrel of gunpowder]) >= 5)
	{
		return false;
	}

	if(chateaumantegna_havePainting() && !get_property("chateauMonsterFought").to_boolean() && (get_property("chateauMonster") == $monster[Lobsterfrogman]))
	{
		auto_sourceTerminalEducate($skill[Extract], $skill[Digitize]);
		if(chateaumantegna_usePainting())
		{
			return true;
		}
	}

	if(!(auto_get_campground() contains $item[Source Terminal]))
	{
		if((auto_voteMonster() || auto_sausageGoblin()) && adjustForReplaceIfPossible())
		{
			try
			{
				if(item_amount($item[barrel of gunpowder]) < 4)
				{
					set_property("auto_doCombatCopy", "yes");
				}
				if (auto_voteMonster() && !auto_voteMonster(true))
				{
					auto_voteMonster(false, $location[Sonofa Beach], "");
					return true;
				}
				else if (auto_sausageGoblin() && !auto_haveVotingBooth())
				{
					auto_sausageGoblin($location[Sonofa Beach], "");
					return true;
				}
			}
			finally
			{
				set_property("auto_combatDirective", "");
				set_property("auto_doCombatCopy", "no");
			}
		}
		return false;
	}

	if (isActuallyEd() && item_amount($item[Talisman of Horus]) == 0 && have_effect($effect[Taunt of Horus]) == 0)
	{
		return false;
	}

	if(in_koe())
	{
		return false;
	}

	//Seriously? http://alliancefromhell.com/viewtopic.php?t=1338
	if(item_amount($item[Wool Hat]) == 1)
	{
		pulverizeThing($item[Wool Hat]);
	}
	if(item_amount($item[Goatskin Umbrella]) == 1)
	{
		pulverizeThing($item[Goatskin Umbrella]);
	}

	if(auto_my_path() != "Live. Ascend. Repeat.")
	{
		if(equipped_item($slot[acc1]) == $item[over-the-shoulder folder holder])
		{
			if((item_amount($item[Ass-Stompers of Violence]) > 0) && (equipped_item($slot[acc1]) != $item[Ass-Stompers of Violence]) && can_equip($item[Ass-Stompers of Violence]))
			{
				equip($slot[acc1], $item[Ass-Stompers of Violence]);
			}
			else
			{
				equip($slot[acc1], $item[bejeweled pledge pin]);
			}
		}
		if(item_amount($item[portable cassette player]) > 0)
		{
			equip($slot[acc2], $item[portable cassette player]);
		}
		if(numeric_modifier("Combat Rate") <= 9.0)
		{
			if(possessEquipment($item[Carpe]))
			{
				equip($slot[Back], $item[Carpe]);
			}
		}
		if(numeric_modifier("Combat Rate") < 0.0)
		{
			auto_log_warning("Something is keeping us from getting a suitable combat rate, we have: " + numeric_modifier("Combat Rate") + " and Lobsterfrogmen.", "red");
			equipBaseline();
			return false;
		}
	}

	if(item_amount($item[barrel of gunpowder]) < 4)
	{
		set_property("auto_doCombatCopy", "yes");
	}

	if((my_mp() < mp_cost($skill[Digitize])) && (auto_get_campground() contains $item[Source Terminal]) && is_unrestricted($item[Source Terminal]) && (get_property("_sourceTerminalDigitizeMonster") != $monster[Lobsterfrogman]) && (get_property("_sourceTerminalDigitizeUses").to_int() < 3))
	{
		equipBaseline();
		return false;
	}

	if(possessEquipment($item[&quot;I voted!&quot; sticker]) && (my_adventures() > 15))
	{
		if(have_skill($skill[Meteor Lore]) && (get_property("_macrometeoriteUses").to_int() < 10))
		{
			if(auto_voteMonster())
			{
				set_property("auto_combatDirective", "start;skill macrometeorite");
				autoEquip($slot[acc3], $item[&quot;I voted!&quot; sticker]);
			}
			else
			{
				return false;
			}
		}
	}

	auto_sourceTerminalEducate($skill[Extract], $skill[Digitize]);

	boolean retval = autoAdv($location[Sonofa Beach]);
	
	set_property("auto_combatDirective", "");
	set_property("auto_doCombatCopy", "no");
	edAcquireHP();
	
	return retval;
}

boolean L12_sonofaFinish()
{
	if (internalQuestStatus("questL12War") != 1 || get_property("sidequestLighthouseCompleted") != "none")
	{
		return false;
	}
	if (in_koe())
	{
		return false;
	}
	if(item_amount($item[barrel of gunpowder]) < 5)
	{
		return false;
	}
	if(!haveWarOutfit())
	{
		return false;
	}
	if((get_property("fratboysDefeated").to_int() < 64) && get_property("auto_hippyInstead").to_boolean())
	{
		return false;
	}

	equipWarOutfit();
	visit_url("bigisland.php?place=lighthouse&action=pyro&pwd");
	visit_url("bigisland.php?place=lighthouse&action=pyro&pwd");
	return true;
}

boolean L12_flyerBackup()
{
	if (internalQuestStatus("questL12War") != 1)
	{
		return false;
	}
	if(get_property("flyeredML").to_int() >= 10000)
	{
		return false;
	}
	if((item_amount($item[Rock Band Flyers]) == 0) && (item_amount($item[Jam Band Flyers]) == 0))
	{
		return false;
	}
	if(get_property("choiceAdventure1003").to_int() >= 3)
	{
		return false;
	}
	if(get_property("auto_ignoreFlyer").to_boolean())
	{
		return false;
	}

	return LX_freeCombats(true);
}

boolean L12_lastDitchFlyer()
{
	if(get_property("auto_ignoreFlyer").to_boolean())
	{
		return false;
	}
	if (internalQuestStatus("questL12War") != 1 || get_property("sidequestArenaCompleted") != "none" || get_property("flyeredML").to_int() >= 10000)
	{
		return false;
	}
	if((item_amount($item[Rock Band Flyers]) == 0) && (item_amount($item[Jam Band Flyers]) == 0))
	{
		return false;
	}

	auto_log_info("Not enough flyer ML but we are ready for the war... uh oh", "blue");

	if (needStarKey())
	{
		if (!zone_isAvailable($location[The Hole in the Sky]))
		{
			return (L10_topFloor() || L10_holeInTheSkyUnlock());
		}
		else
		{
			if(LX_getStarKey())
			{
				return true;
			}
		}
	} else if (needDigitalKey()) {
		if (LX_getDigitalKey()) {
			return true;
		}
	}
	else
	{
		auto_log_warning("Should not have so little flyer ML at this point", "red");
		wait(1);
		if(!LX_attemptFlyering())
		{
			abort("Need more flyer ML but don't know where to go :(");
		}
		return true;
	}
	return false;
}

boolean LX_attemptFlyering()
{
	if(elementalPlanes_access($element[stench]) && auto_have_skill($skill[Summon Smithsness]))
	{
		return autoAdv(1, $location[Uncle Gator\'s Country Fun-Time Liquid Waste Sluice]);
	}
	else if(elementalPlanes_access($element[spooky]))
	{
		return autoAdv(1, $location[The Deep Dark Jungle]);
	}
	else if(elementalPlanes_access($element[cold]))
	{
		return autoAdv(1, $location[VYKEA]);
	}
	else if(elementalPlanes_access($element[stench]))
	{
		return autoAdv(1, $location[Uncle Gator\'s Country Fun-Time Liquid Waste Sluice]);
	}
	else if(elementalPlanes_access($element[sleaze]))
	{
		return autoAdv(1, $location[Sloppy Seconds Diner]);
	}
	else if(neverendingPartyAvailable())
	{
		return neverendingPartyCombat();
	}
	else
	{
		int flyer = get_property("flyeredML").to_int();
		boolean retval = autoAdv($location[Near an Abandoned Refrigerator]);
		if (flyer == get_property("flyeredML").to_int())
		{
			abort("Trying to flyer but failed to flyer");
		}
		set_property("auto_newbieOverride", true);
		return retval;
	}
	return false;
}

boolean L12_flyerFinish()
{
	if (internalQuestStatus("questL12War") != 1)
	{
		return false;
	}
	if((item_amount($item[Rock Band Flyers]) == 0) && (item_amount($item[Jam Band Flyers]) == 0))
	{
		return false;
	}
	if(get_property("flyeredML").to_int() < 10000)
	{
		if(get_property("sidequestArenaCompleted") != "none")
		{
			auto_log_warning("Sidequest Arena detected as completed but flyeredML is not appropriate, fixing.", "red");
			set_property("flyeredML", 10000);
		}
		else
		{
			return false;
		}
	}
	if(get_property("auto_ignoreFlyer").to_boolean())
	{
		return false;
	}
	auto_log_info("Done with this Flyer crap", "blue");
	equipWarOutfit(false);
	visit_url("bigisland.php?place=concert&pwd");

	cli_execute("refresh inv");
	if((item_amount($item[Rock Band Flyers]) == 0) && (item_amount($item[Jam Band Flyers]) == 0))
	{
		return true;
	}
	auto_log_warning("We thought we had enough flyeredML, but we don't. Big sadness, let's try that again.", "red");
	set_property("flyeredML", 9999);
	return false;
}

boolean L12_themtharHills()
{
	if (internalQuestStatus("questL12War") != 1 || get_property("sidequestNunsCompleted") != "none")
	{
		return false;
	}

	if (in_tcrs() || in_koe() || auto_my_path() == "Way of the Surprising Fist")
	{
		return false;
	}

	if ((get_property("hippiesDefeated").to_int() < 192 && !get_property("auto_hippyInstead").to_boolean()) || get_property("auto_skipNuns").to_boolean())
	{
		return false;
	}
	else
	{
		auto_log_info("Themthar Nuns!", "blue");
	}

	if((get_property("sidequestArenaCompleted") == "fratboy") && !get_property("concertVisited").to_boolean() && (have_effect($effect[Winklered]) == 0))
	{
		outfit("Frat Warrior Fatigues");
		cli_execute("concert 2");
	}

	handleBjornify($familiar[Hobo Monkey]);
	if((equipped_item($slot[off-hand]) != $item[Half a Purse]) && !possessEquipment($item[Half a Purse]) && (item_amount($item[Lump of Brituminous Coal]) > 0))
	{
		buyUpTo(1, $item[Loose Purse Strings]);
		autoCraft("smith", 1, $item[Lump of Brituminous Coal], $item[Loose purse strings]);
	}

	autoEquip($item[Half a Purse]);
	if(auto_my_path() == "Heavy Rains")
	{
		autoEquip($item[Thor\'s Pliers]);
	}
	autoEquip($item[Miracle Whip]);

	shrugAT($effect[Polka of Plenty]);
	if (isActuallyEd())
	{
		if(!have_skill($skill[Gift of the Maid]) && ($servant[Maid].experience >= 441))
		{
			visit_url("charsheet.php");
			if(have_skill($skill[Gift of the Maid]))
			{
				auto_log_warning("Gift of the Maid not properly detected until charsheet refresh.", "red");
			}
		}
	}
	buffMaintain($effect[Purr of the Feline], 10, 1, 1);
	songboomSetting("meat");
	handleFamiliar("meat");
	addToMaximize("200meat drop");

	if(get_property("auto_useWishes").to_boolean())
	{
		makeGenieWish($effect[Frosty]);
	}
	buffMaintain($effect[Greedy Resolve], 0, 1, 1);
	buffMaintain($effect[Disco Leer], 10, 1, 1);
	buffMaintain($effect[Polka of Plenty], 8, 1, 1);
	#Handle for familiar weight change.
	buffMaintain($effect[Kindly Resolve], 0, 1, 1);
	buffMaintain($effect[Heightened Senses], 0, 1, 1);
	buffMaintain($effect[Big Meat Big Prizes], 0, 1, 1);
	buffMaintain($effect[Human-Machine Hybrid], 0, 1, 1);
	buffMaintain($effect[Human-Constellation Hybrid], 0, 1, 1);
	buffMaintain($effect[Human-Humanoid Hybrid], 0, 1, 1);
	buffMaintain($effect[Human-Fish Hybrid], 0, 1, 1);
	buffMaintain($effect[Cranberry Cordiality], 0, 1, 1);
	buffMaintain($effect[Patent Avarice], 0, 1, 1);
	buffMaintain($effect[Car-Charged], 0, 1, 1);
	buffMaintain($effect[Heart of Pink], 0, 1, 1);
	buffMaintain($effect[Sweet Heart], 0, 1, 20);
		
	if(item_amount($item[body spradium]) > 0 && !in_tcrs() && have_effect($effect[Boxing Day Glow]) == 0)
	{
		autoChew(1, $item[body spradium]);
	}
	if(have_effect($effect[meat.enh]) == 0)
	{
		if(auto_sourceTerminalEnhanceLeft() > 0)
		{
			auto_sourceTerminalEnhance("meat");
		}
	}
	if(have_effect($effect[Synthesis: Greed]) == 0)
	{
		rethinkingCandy($effect[Synthesis: Greed]);
	}
	asdonBuff($effect[Driving Observantly]);

	if(available_amount($item[Li\'l Pirate Costume]) > 0 && canChangeToFamiliar($familiar[Trick-or-Treating Tot]) && (auto_my_path() != "Heavy Rains"))
	{
		use_familiar($familiar[Trick-or-Treating Tot]);
		autoEquip($item[Li\'l Pirate Costume]);
		handleFamiliar($familiar[Trick-or-Treating Tot]);
	}

	if(auto_my_path() == "Heavy Rains")
	{
		buffMaintain($effect[Sinuses For Miles], 0, 1, 1);
	}
	// Target 1000 + 400% = 5000 meat per brigand. Of course we want more, but don\'t bother unless we can get this.
	float meat_need = 400.00;
	if(item_amount($item[Mick\'s IcyVapoHotness Inhaler]) > 0)
	{
		meat_need = meat_need - 200;
	}
	if((my_class() == $class[Vampyre]) && have_skill($skill[Wolf Form]) && (0 == have_effect($effect[Wolf Form])))
	{
		meat_need = meat_need - 150;
	}
	if(zataraAvailable() && (0 == have_effect($effect[Meet the Meat])))
	{
		meat_need = meat_need - 100;
	}

	if(canChangeFamiliar()) {
		// if we're in a 100% run, this property returns "none" which will unequip our familiar and ruin a 100% run.
		use_familiar(to_familiar(get_property("auto_familiarChoice")));
	}
	equipMaximizedGear();
	float meatDropHave = meat_drop_modifier();

	if (isActuallyEd() && have_skill($skill[Curse of Fortune]) && item_amount($item[Ka Coin]) > 0)
	{
		meatDropHave = meatDropHave + 200;
	}
	if(meatDropHave < meat_need)
	{
		auto_log_warning("Meat drop (" + meatDropHave+ ") is pretty low, (we want: " + meat_need + ") probably not worth it to try this.", "red");

		float minget = 800.00 * (meatDropHave / 100.0);
		int meatneed = 100000 - get_property("currentNunneryMeat").to_int();
		auto_log_info("The min we expect is: " + minget + " and we need: " + meatneed, "blue");

		if(minget < meatneed)
		{
			int curMeat = get_property("currentNunneryMeat").to_int();
			int advs = $location[The Themthar Hills].turns_spent;
			int needMeat = 100000 - curMeat;

			boolean failNuns = true;
			if(advs < 25)
			{
				int advLeft = 25 - $location[The Themthar Hills].turns_spent;
				float needPerAdv = needMeat / advLeft;
				if(minget > needPerAdv)
				{
					auto_log_info("We don't have the desired +meat but should be able to complete the nuns to our advantage", "green");
					failNuns = false;
				}
			}

			if(failNuns)
			{
				set_property("auto_skipNuns", "true");
				return false;
			}
		}
		else
		{
			auto_log_info("The min should be enough! Doing it!!", "purple");
		}
	}


	buffMaintain($effect[Disco Leer], 10, 1, 1);
	buffMaintain($effect[Polka of Plenty], 8, 1, 1);
	buffMaintain($effect[Sinuses For Miles], 0, 1, 1);
	buffMaintain($effect[Greedy Resolve], 0, 1, 1);
	buffMaintain($effect[Kindly Resolve], 0, 1, 1);
	buffMaintain($effect[Heightened Senses], 0, 1, 1);
	buffMaintain($effect[Big Meat Big Prizes], 0, 1, 1);
	buffMaintain($effect[Fortunate Resolve], 0, 1, 1);
	buffMaintain($effect[Human-Machine Hybrid], 0, 1, 1);
	buffMaintain($effect[Human-Constellation Hybrid], 0, 1, 1);
	buffMaintain($effect[Human-Humanoid Hybrid], 0, 1, 1);
	buffMaintain($effect[Human-Fish Hybrid], 0, 1, 1);
	buffMaintain($effect[Cranberry Cordiality], 0, 1, 1);
	buffMaintain($effect[Car-Charged], 0, 1, 1);
	buffMaintain($effect[Heart of Pink], 0, 1, 1);
	buffMaintain($effect[Sweet Heart], 0, 1, 20);
	bat_formWolf();
	zataraSeaside("meat");

	{
		equipWarOutfit();

		int lastMeat = get_property("currentNunneryMeat").to_int();
		int myLastMeat = my_meat();
		auto_log_info("Meat drop to start: " + meat_drop_modifier(), "blue");
		if(!autoAdv(1, $location[The Themthar Hills]))
		{
			//Maybe we passed it!
			string temp = visit_url("bigisland.php?place=nunnery");
		}
		if(last_monster() != $monster[dirty thieving brigand])
		{
			return true;
		}
		if(get_property("lastEncounter") != $monster[Dirty Thieving Brigand])
		{
			return true;
		}

		int curMeat = get_property("currentNunneryMeat").to_int();
		if(lastMeat == curMeat)
		{
			int diffMeat = my_meat() - myLastMeat;
			set_property("currentNunneryMeat", diffMeat);
		}

		int advs = $location[The Themthar Hills].turns_spent + 1;

		int diffMeat = curMeat - lastMeat;
		int needMeat = 100000 - curMeat;
		int average = curMeat / advs;
		auto_log_info("Cur Meat: " + curMeat + " Average: " + average, "blue");

		diffMeat = diffMeat * 1.2;
		average = average * 1.2;
	}
	return true;
}

boolean LX_obtainChaosButterfly()
{
	if(in_bhy() || in_pokefam())
	{
		return false;
	}
	if(get_property("chaosButterflyThrown").to_boolean())
	{
		return false;
	}
	if(!is_unrestricted($item[chaos butterfly]))
	{
		return false;
	}
	if(internalQuestStatus("questL10Garbage") < 8)
	{
		return false;
	}
	
	// Softcore pull
	if(canPull($item[chaos butterfly]) && !get_property("chaosButterflyThrown").to_boolean() && item_amount($item[chaos butterfly]) == 0)
	{
		if(pullXWhenHaveY($item[chaos butterfly], 1, 0))
		{
			return true;
		}
		else
		{
			auto_log_warning("failed to pull [chaos butterfly] for some reason", "red");
		}
	}
	
	// Fight possibility giant for chaos butterfly if profitable.
	if(!get_property("chaosButterflyThrown").to_boolean() && item_amount($item[chaos butterfly]) == 0 && (auto_estimatedAdventuresForChaosButterfly() < 15))
	{
		if(autoAdv(1, $location[The Castle in the Clouds in the Sky (Ground Floor)]))
		{
			return true;
		}
		else
		{
			auto_log_warning("For some reason failed to adventure in [The Castle in the Clouds in the Sky (Ground Floor)] for a [chaos butterfly]... skipping", "red");
		}
	}
	
	// Special-case using chaos butterfly in the Barn right after acquiring it,
	// to avoid any funny business where we don't use the chaos butterfly,
	// adventure somewhere else, our CCS uses the chaos butterfly, and we
	// suddenly realize that we want to complete dooks after all.
	if(!get_property("chaosButterflyThrown").to_boolean() && item_amount($item[chaos butterfly]) > 0 && !in_pokefam())
	{
		if($location[McMillicancuddy's Barn].turns_spent > 0)
		{
			auto_log_warning("I seem to have spent turns in [McMillicancuddy's Barn] without using the [chaos butterfly] which I have. Something is not right...", "red");
		}
		else
		{
			auto_log_warning("Looks like I should use the [chaos butterfly] in [McMillicancuddy's Barn]", "blue");
			return autoAdv(1, $location[McMillicancuddy's Barn]);
		}
	}
	
	return false;
}

boolean L12_farm()
{
	if(get_property("auto_skipL12Farm").to_boolean())
	{
		return false;
	}
	if(get_property("sidequestFarmCompleted") != "none")
	{
		set_property("auto_skipL12Farm", "true");
		return false;
	}
	if(internalQuestStatus("questL12War") != 1)
	{
		return false;
	}
	
	//Does fratboy side have access to farm yet?
	//TODO verify this works with pocket familiar. And if not then make special handling for pokefam
	if(auto_warSide() == "fratboy" && get_property("hippiesDefeated").to_int() < 458)
	{
		return false;
	}
	
	WarPlan plan = auto_bestWarPlan();
	if(!plan.do_farm)
	{
		return false;
	}
		
	// Acquire and use chaos butterfly if needed and desired
	if(LX_obtainChaosButterfly())
	{
		return true;
	}
	
	auto_log_info("Save McMillicancuddy's Farm from the Dooks", "blue");

	// There is no mafia tracking for stages of this sidequest
	// Because Mafia's adventures spent count also increments on a free fight, we cannot
	// rely on adventures spent count to see if a zone is clear.

	// Instead, we use the internal property auto_L12FarmStage to determine
	// which section of the farm is available.

	// Note that this code uses switch fall-through, and does not use breaks.

	switch(get_property("auto_L12FarmStage").to_int())
	{
	case 0:
		if(autoAdv(1, $location[McMillicancuddy's Barn]))
		{
			return true;
		}
		set_property("auto_L12FarmStage", "1");
	case 1:
		if(autoAdv(1, $location[McMillicancuddy's Pond]))
		{
			return true;
		}
		set_property("auto_L12FarmStage", "2");
	case 2:
		if(autoAdv(1, $location[McMillicancuddy's Back 40]))
		{
			return true;
		}
		set_property("auto_L12FarmStage", "3");
	case 3:
		if(autoAdv(1, $location[McMillicancuddy's Other Back 40]))
		{
			return true;
		}
		set_property("auto_L12FarmStage", "4");
	case 4:
		equipWarOutfit();
		visit_url("bigisland.php?place=farm&action=farmer&pwd");
		if(get_property("sidequestFarmCompleted") != "none")
		{
			return true;
		}
		abort("Failed to turn in L12 Farm sidequest. please finish it manually and run me again");
	}
	// This really should not happen. Maybe if auto_L12FarmStage is in an invalid state (not 0-4).
	abort("I am confused about where I am in the dooks. Please report this. auto_L12FarmStage="+get_property("auto_L12FarmStage"));
	return false;
}

boolean L12_clearBattlefield()
{
	if(!inAftercore() && (my_inebriety() < inebriety_limit()) && !get_property("_gardenHarvested").to_boolean())
	{
		int[item] camp = auto_get_campground();
		if((camp contains $item[Packet of Thanksgarden Seeds]) && (camp contains $item[Cornucopia]) && (camp[$item[Cornucopia]] > 0) && (internalQuestStatus("questL12War") >= 1) && is_unrestricted($item[packet of thanksgarden seeds]))
		{
			cli_execute("garden pick");
		}
	}

	if(in_koe())
	{
		return L12_koe_clearBattlefield();
	}

	if (internalQuestStatus("questL12War") != 1)
	{
		return false;
	}

	WarPlan sideQuests = auto_warSideQuestsState();
	boolean nunsCheck = (get_property("auto_skipNuns").to_boolean() ? true : sideQuests.do_nuns);
	// don't adventure on the battlefield if we haven't completed all 3 available sidequests.
	// this may need some exceptions for paths added where certain sidequests are not possible.
	if (auto_warSide() == "fratboy")
	{
		if (!sideQuests.do_arena || !sideQuests.do_junkyard || !sideQuests.do_lighthouse)
		{
			return false;
		}
	}
	else
	{
		if (!sideQuests.do_orchard || !nunsCheck || !sideQuests.do_farm)
		{
			return false;
		}
	}

	if (get_property("hippiesDefeated").to_int() < 64 && get_property("fratboysDefeated").to_int() < 64)
	{
		auto_log_info("First 64 combats. To orchard/lighthouse", "blue");
		if((item_amount($item[Stuffing Fluffer]) == 0) && (item_amount($item[Cashew]) >= 3))
		{
			cli_execute("make 1 stuffing fluffer");
		}
		if((item_amount($item[Stuffing Fluffer]) == 0) && (item_amount($item[Cornucopia]) > 0) && glover_usable($item[Cornucopia]))
		{
			use(1, $item[Cornucopia]);
			if((item_amount($item[Stuffing Fluffer]) == 0) && (item_amount($item[Cashew]) >= 3))
			{
				cli_execute("make 1 stuffing fluffer");
			}
			return true;
		}
		if(item_amount($item[Stuffing Fluffer]) > 0)
		{
			use(1, $item[Stuffing Fluffer]);
			return true;
		}
		equipWarOutfit();
		return warAdventure();
	}

	if (auto_warSide() == "fratboy")
	{
		if (!sideQuests.do_orchard)
		{
			return false;
		}
	}
	else
	{
		if (!sideQuests.do_lighthouse)
		{
			return false;
		}
	}

	if (get_property("hippiesDefeated").to_int() < 192 && get_property("fratboysDefeated").to_int() < 192)
	{
		auto_log_info("Getting to the nunnery/junkyard", "blue");
		equipWarOutfit();
		return warAdventure();
	}

	if (auto_warSide() == "fratboy")
	{
		if (!nunsCheck)
		{
			return false;
		}
	}
	else
	{
		if (!sideQuests.do_junkyard)
		{
			return false;
		}
	}

	if (get_property("hippiesDefeated").to_int() < 1000 && get_property("fratboysDefeated").to_int() < 1000)
	{
		auto_log_info("Doing the wars.", "blue");
		equipWarOutfit();
		return warAdventure();
	}
	return false;
}

boolean L12_finalizeWar()
{
	if(in_koe())
	{
		return L12_koe_finalizeWar();
	}
	if (internalQuestStatus("questL12War") != 1)
	{
		return false;
	}

	if (get_property("hippiesDefeated").to_int() < 1000 && get_property("fratboysDefeated").to_int() < 1000)
	{
		return false;
	}

	if(possessOutfit("War Hippy Fatigues"))
	{
		auto_log_info("Getting dimes.", "blue");
		outfit("War Hippy Fatigues");
		foreach it in $items[padl phone, red class ring, blue class ring, white class ring]
		{
			sell(it.buyer, item_amount(it), it);
		}
		foreach it in $items[beer helmet, distressed denim pants, bejeweled pledge pin]
		{
			sell(it.buyer, item_amount(it) - 1, it);
		}
		if (isActuallyEd())
		{
			foreach it in $items[kick-ass kicks, perforated battle paddle, bottle opener belt buckle, keg shield, giant foam finger, war tongs, energy drink IV, Elmley shades, beer bong]
			{
				sell(it.buyer, item_amount(it), it);
			}
		}
	}
	if(possessOutfit("Frat Warrior Fatigues"))
	{
		auto_log_info("Getting quarters.", "blue");
		outfit("Frat Warrior Fatigues");
		foreach it in $items[pink clay bead, purple clay bead, green clay bead, communications windchimes]
		{
			sell(it.buyer, item_amount(it), it);
		}
		foreach it in $items[bullet-proof corduroys, round purple sunglasses, reinforced beaded headband]
		{
			sell(it.buyer, item_amount(it) - 1, it);
		}
		if (isActuallyEd())
		{
			foreach it in $items[hippy protest button, Lockenstock&trade; sandals, didgeridooka, wicker shield, oversized pipe, fire poi, Gaia beads, hippy medical kit, flowing hippy skirt, round green sunglasses]
			{
				sell(it.buyer, item_amount(it), it);
			}
		}
	}

	// Just in case we need the extra turngen to complete this day
	if (my_class() == $class[Vampyre])
	{
		int have = item_amount($item[monstar energy beverage]) + item_amount($item[carbonated soy milk]);
		if(have < 5)
		{
			int need = 5 - have;
			if(!get_property("auto_hippyInstead").to_boolean())
			{
				need = min(need, $coinmaster[Quartersmaster].available_tokens / 3);
				cli_execute("make " + need + " Monstar energy beverage");
			}
			else
			{
				need = min(need, $coinmaster[Dimemaster].available_tokens / 3);
				cli_execute("make " + need + " carbonated soy milk");
			}
		}
	}

	int have = item_amount($item[filthy poultice]) + item_amount($item[gauze garter]);
	if (have < 10 && !isActuallyEd())
	{
		int need = 10 - have;
		if(!get_property("auto_hippyInstead").to_boolean())
		{
			need = min(need, $coinmaster[Quartersmaster].available_tokens / 2);
			cli_execute("make " + need + " gauze garter");
		}
		else
		{
			need = min(need, $coinmaster[Dimemaster].available_tokens / 2);
			cli_execute("make " + need + " filthy poultice");
		}
	}

	if(possessOutfit("War Hippy Fatigues"))
	{
		while($coinmaster[Dimemaster].available_tokens >= 5)
		{
			cli_execute("make " + $coinmaster[Dimemaster].available_tokens/5 + " fancy seashell necklace");
		}
		while($coinmaster[Dimemaster].available_tokens >= 2)
		{
			cli_execute("make " + $coinmaster[Dimemaster].available_tokens/2 + " filthy poultice");
		}
		while($coinmaster[Dimemaster].available_tokens >= 1)
		{
			cli_execute("make " + $coinmaster[Dimemaster].available_tokens + " water pipe bomb");
		}
	}

	if(possessOutfit("Frat Warrior Fatigues"))
	{
		while($coinmaster[Quartersmaster].available_tokens >= 5)
		{
			cli_execute("make " + $coinmaster[Quartersmaster].available_tokens/5 + " commemorative war stein");
		}
		while($coinmaster[Quartersmaster].available_tokens >= 2)
		{
			cli_execute("make " + $coinmaster[Quartersmaster].available_tokens/2 + " gauze garter");
		}
		while($coinmaster[Quartersmaster].available_tokens >= 1)
		{
			cli_execute("make " + $coinmaster[Quartersmaster].available_tokens + " beer bomb");
		}
	}

	if(my_mp() < 40)
	{
		// fyi https://kol.coldfront.net/thekolwiki/index.php/Chateau_Mantegna states you wont get pantsgiving benefits resting there (presumably campsite as well)
		// so not sure this is doing much
		if(possessEquipment($item[Pantsgiving]))
		{
			equip($item[pantsgiving]);
		}
		doRest();
	}
	equipWarOutfit();
	acquireHP();
	auto_log_info("Let's fight the boss!", "blue");

	location bossFight = $location[Noob Cave];

	if(auto_have_familiar($familiar[Machine Elf]))
	{
		handleFamiliar($familiar[Machine Elf]);
	}
	string[int] pages;
	pages[0] = "bigisland.php?place=camp&whichcamp=1";
	pages[1] = "bigisland.php?place=camp&whichcamp=2";
	pages[2] = "bigisland.php?action=bossfight&pwd";
	if(!autoAdvBypass(0, pages, bossFight, ""))
	{
		auto_log_warning("Boss already defeated, ignoring", "red");
	}

	if(in_pokefam())
	{
		string temp = visit_url("island.php");
		council();
	}

	cli_execute("refresh quests");
	if (internalQuestStatus("questL12War") == 1)
	{
		abort("Failing to complete the war.");
	}
	council();
	return true;
}

void warChoiceHandler(int choice)
{
	auto_log_debug("void warChoiceHandler(int choice)");

	switch (choice)
	{
		case 139:
			run_choice(3);		//fight a War Hippy (space) cadet for outfit pieces
			break;
		case 140:
			run_choice(3);		//fight a War Hippy drill sergeant for outfit pieces
			break;
		case 141: // Blockin' Out the Scenery (wearing Frat Boy Ensemble) 
			run_choice(1);		//get 50 mysticality
			break;
		case 142: // Blockin' Out the Scenery (wearing Frat Warrior Fatigues)
			run_choice(3);		//starts the war. skips adventure if already started.
			break;
		case 143:
			run_choice(3);		//fight a War Pledgefor outfit pieces
			break;
		case 144:
			run_choice(3);		//fight a Frat Warrior drill sergeant for outfit pieces
			break;
		case 145: // Fratacombs (wearing Filthy Hippy Disguise) 
			run_choice(1);		//get 50 muscle
			break;
		case 146: // Fratacombs (wearing War Hippy Fatigues)
			run_choice(3);		//starts the war. skips adventure if already started.
			break;
		case 147:
			run_choice(3);		//open the pond
			break;
		case 148:
			run_choice(1);		//open the back 40
			break;
		case 149:
			run_choice(2);		//open the other back 40
			break;
		default:
			auto_log_warning("void warChoiceHandler(int choice) somehow hit default. this should not happen");
			break;
	}
}

boolean L12_islandWar()
{
	if (internalQuestStatus("questL12War") == 0 && get_property("lastIslandUnlock").to_int() != my_ascensions())
	{
		return LX_islandAccess();
	}
	if (L12_preOutfit() || L12_getOutfit() || L12_startWar())
	{
		return true;
	}
	if (L12_gremlins() || L12_flyerFinish() || L12_sonofaBeach() || L12_sonofaFinish() || L12_filthworms() || L12_orchardFinalize() || L12_themtharHills() || L12_farm())
	{
		return true;
	}
	if (L12_clearBattlefield() || L12_finalizeWar())
	{
		return true;
	}
	return false;
}
