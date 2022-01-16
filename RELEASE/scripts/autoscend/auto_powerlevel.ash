boolean isAboutToPowerlevel() {
	return get_property("auto_powerLevelLastLevel").to_int() == my_level();
}

boolean LX_attemptPowerLevel()
{
	if (!isAboutToPowerlevel())		//determined that the softblock on quests waiting for optimal conditions is still on
	{
		auto_log_warning("Hmmm, we need to stop being so feisty about quests...", "red");
		set_property("auto_powerLevelLastLevel", my_level());		//release softblock until you level up
		set_property("auto_powerLevelAdvCount", 0);
		return true;		//restart the main loop to give those quests a chance to run now that the softblock is released.
	}
	
	if(in_robot())
	{
		return LX_robot_powerlevel();		//leveling works very differently in You, Robot path
	}
	if (my_level() > 12)
	{
		return false;
	}

	auto_log_warning("I've run out of stuff to do. Time to powerlevel, I suppose.", "red");

	set_property("auto_powerLevelAdvCount", get_property("auto_powerLevelAdvCount").to_int() + 1);
	set_property("auto_powerLevelLastAttempted", my_turncount());
	
	handleFamiliar("stat");
	addToMaximize("100 exp");
	
	auto_log_warning("I need to powerlevel", "red");
	int delay = get_property("auto_powerLevelTimer").to_int();
	if(delay == 0)
	{
		delay = 10;
	}
	wait(delay);

	if(LX_freeCombats(true)) return true;
	
	if(chateaumantegna_available() && haveFreeRestAvailable() && !in_theSource())
	{
		doFreeRest();
		cli_execute("scripts/autoscend/auto_post_adv.ash");
		loopHandlerDelayAll();
		return true;
	}
	
	//The Source path specific powerleveling
	LX_attemptPowerLevelTheSource();

	if (LX_getDigitalKey() || LX_getStarKey())
	{
		return true;
	}

	//scaling damage zones
	if(elementalPlanes_access($element[stench]) && auto_have_skill($skill[Summon Smithsness]) && (get_property("auto_beatenUpCount").to_int() == 0))
	{
		if(autoAdv($location[Uncle Gator\'s Country Fun-Time Liquid Waste Sluice])) return true;
	}
	if(elementalPlanes_access($element[spooky]))
	{
		if(autoAdv($location[The Deep Dark Jungle])) return true;
	}
	if(elementalPlanes_access($element[cold]))
	{
		if(autoAdv($location[VYKEA])) return true;
	}
	if(elementalPlanes_access($element[sleaze]))
	{
		if(autoAdv($location[Sloppy Seconds Diner])) return true;
	}
	if (elementalPlanes_access($element[hot]))
	{
		if(autoAdv($location[The SMOOCH Army HQ])) return true;
	}
	if (neverendingPartyAvailable())
	{
		if(neverendingPartyCombat()) return true;
	}
	if(timeSpinnerAdventure()) return true;
	//do not use the scaling zone [The Thinknerd Warehouse] here.
	//it has low stat caps on the scaling, resulting in <30 substats per adv
	
	if (internalQuestStatus("questM21Dance") > 3)
	{
		int goal_count = 0;
		if(my_primestat() == $stat[Muscle])
		{
			goal_count++;
		}
		if(my_primestat() == $stat[Mysticality] || my_basestat($stat[Mysticality]) < 70)	//war outfit requires 70 base mys
		{
			goal_count++;
		}
		if(my_primestat() == $stat[Moxie] ||
		my_basestat($stat[Moxie]) < 70 || 	//war outfit requires 70 base mox
		get_property("auto_beatenUpCount").to_int() > 5)	//if we are getting beaten up we should raise moxie
		{
			goal_count++;
		}
		if(my_meat() < meatReserve() + 1000)
		{
			goal_count++;
		}
		boolean prefer_bedroom = false;
		if(goal_count > 1) //for multiple targets then haunted bedroom is best
		{
			prefer_bedroom = true;
		}
		else if(providePlusNonCombat(25, true, true) < 15)	//only perform the simulation if goal_count is 1
		{
			prefer_bedroom = true;	//for one target it depends on your noncombat. bad -combat prefers bedroom. otherwise prefer haunted gallery
		}
		
		if(prefer_bedroom)
		{
			if(autoAdv($location[The Haunted Bedroom])) return true;
		}
		else		//do [The Haunted Gallery] instead
		{
			switch (my_primestat())		//we only ever do the haunted gallery if the sole stat we want is primestat.
			{
				case $stat[Muscle]:
					backupSetting("louvreDesiredGoal", "4"); // get Muscle stats
					break;
				case $stat[Mysticality]:
					backupSetting("louvreDesiredGoal", "5"); // get Myst stats
					break;
				case $stat[Moxie]:
					backupSetting("louvreDesiredGoal", "6"); // get Moxie stats
					break;
			}
			providePlusNonCombat(25, true);
			if(autoAdv($location[The Haunted Gallery])) return true;
		}		
	}
	return false;
}

boolean disregardInstantKarma()
{
	//do we want to ignore the instant karma you get for defeating the naughty sorceress at exactly level 13. Used to tweak our XP gains.
	if(inAftercore())
	{
		return true;
	}
	if(my_level() != 13)
	{
		//under level 13 we wan to get max XP gains. level 14+ we already missed the insta karma, no need to hold back anymore.
		return true;
	}
	//auto_disregardInstantKarma is a user configured setting
	return get_property("auto_disregardInstantKarma").to_boolean();
}

int auto_freeCombatsRemaining()
{
	return auto_freeCombatsRemaining(false);
}

int auto_freeCombatsRemaining(boolean print_remaining_fights)
{

	void logRemainingFights(string msg)
	{
	  if (!print_remaining_fights) return;
	  print(msg, "red");
	}

	int count = 0;
	
	logRemainingFights("Remaining Free Fights:");
	if(!in_koe() && canChangeToFamiliar($familiar[Machine Elf]))
	{
		int temp = 5-get_property("_machineTunnelsAdv").to_int();
		count += temp;
		logRemainingFights("Machine Elf = " + temp);
	}
	if(snojoFightAvailable())
	{
		int temp = 10-get_property("_snojoFreeFights").to_int();
		count += temp;
		logRemainingFights("Snojo = " + temp);
	}
	if(canChangeToFamiliar($familiar[God Lobster]) && disregardInstantKarma())
	{
		int temp = 3-get_property("_godLobsterFights").to_int();
		count += temp;
		logRemainingFights("God Lobster = " + temp);
	}
	if(neverendingPartyRemainingFreeFights() > 0)
	{
		int temp = neverendingPartyRemainingFreeFights();
		count += temp;
		logRemainingFights("Neverending Party = " + temp);
	}
	if(get_property("_eldritchTentacleFought").to_boolean() == false)
	{
		count++;
		logRemainingFights("Tent Tentacle = 1");
	}
	if(auto_have_skill($skill[Evoke Eldritch Horror]) && get_property("_eldritchHorrorEvoked").to_boolean() == false)
	{
		count++;
		logRemainingFights("Evoke Eldritch = 1");
	}

	if (auto_canFightPiranhaPlant()) {
		int temp = auto_piranhaPlantFightsRemaining();
		count += temp;
		logRemainingFights("Piranha Plant Fights = " + temp);
	}

	if (auto_canTendMushroomGarden()) {
		count++;
		logRemainingFights("Tend to Mushroom Garden = 1"); //Not actually a free fight, but included to ensure carried out at bedtime.
	}

	return count;
}

boolean LX_freeCombats()
{
	return LX_freeCombats(disregardInstantKarma());
}

boolean LX_freeCombats(boolean powerlevel)
{
	if(auto_freeCombatsRemaining() == 0)
	{
		auto_log_debug("Could not use free combats because you have none");
		return false;
	}
	
	if(my_inebriety() > inebriety_limit())
	{
		auto_log_debug("Could not use free combats because you are overdrunk");
		return false;
	}
	
	if(my_adventures() == 0)
	{
		auto_log_warning("Could not use free combats because you are out of adventures", "red");
		return false;
	}
	
	if(my_adventures() < 2)
	{
		auto_freeCombatsRemaining(true);		//print remaining free combats.
		auto_log_warning("Too few adventures to safely automate free combats", "red");
		auto_log_warning("If we lose your last adv on a free combat the remaining free combats are wasted", "red");
		auto_log_warning("This error should only occur if you lost a free fight. If you did not then please report this", "red");
		abort("Please perform the remaining free combats manually then run me again");
	}
	
	auto_log_debug("LX_freeCombats active with powerlevel set to " + powerlevel);
	
	resetMaximize();
	if(disregardInstantKarma())
	{
		handleFamiliar("stat");
	}

	if (auto_canFightPiranhaPlant() || auto_canTendMushroomGarden()) {
		auto_log_debug("LX_freeCombats is calling auto_mushroomGardenHandler()");
		return auto_mushroomGardenHandler();
	}

	if(neverendingPartyRemainingFreeFights() > 0)
	{
		if(powerlevel)
		{
			auto_log_debug("LX_freeCombats is calling neverendingPartyCombat()");
			if(neverendingPartyCombat()) return true;
		}
		else
		{
			auto_log_debug("LX_freeCombats is calling neverendingPartyCombat()");
			if (handleFamiliar($familiar[Red-Nosed Snapper]))
			{
				auto_changeSnapperPhylum($phylum[dude]);
			}
			if(neverendingPartyCombat()) return true;
		}
	}
	
	boolean adv_done = false;

	if(!in_koe() && get_property("_machineTunnelsAdv").to_int() < 5 && canChangeToFamiliar($familiar[Machine Elf]))
	{
		auto_log_debug("LX_freeCombats is adventuring in [The Deep Machine Tunnels]");

		familiar bjorn = my_bjorned_familiar();
		if(bjorn == $familiar[Machine Elf])
		{
			handleBjornify($familiar[Grinning Turtle]);
		}
		adv_done = autoAdv(1, $location[The Deep Machine Tunnels]);
		if(bjorn == $familiar[Machine Elf])
		{
			handleBjornify(bjorn);
		}

		loopHandlerDelayAll();
		if(adv_done) return true;
	}

	if(snojoFightAvailable())
	{
		auto_log_debug("LX_freeCombats is adventuring in [The Snojo]");
		adv_done = autoAdv(1, $location[The X-32-F Combat Training Snowman]);
		loopHandlerDelayAll();
		if(adv_done) return true;
	}

	if(powerlevel)
	{
		auto_log_debug("LX_freeCombats is calling godLobsterCombat()");
		if(godLobsterCombat()) return true;
	}
	
	if(get_property("_eldritchTentacleFought").to_boolean() == false)
	{
		auto_log_debug("LX_freeCombats is calling fightScienceTentacle()");
		if(fightScienceTentacle()) return true;
	}
	
	if(auto_have_skill($skill[Evoke Eldritch Horror]) && get_property("_eldritchHorrorEvoked").to_boolean() == false)
	{
		auto_log_debug("LX_freeCombats is calling evokeEldritchHorror()");
		if(evokeEldritchHorror()) return true;
	}
	
	if(auto_freeCombatsRemaining() == 0)
	{
		auto_log_debug("I reached the end of LX_freeCombats() but I think the following free combats were not used for some reason:");
		auto_freeCombatsRemaining(true);		//print remaining free combats.
	}

	return false;
}

boolean LX_freeCombatsTask()
{
	if (my_adventures() == (1 + auto_advToReserve()) && inebriety_left() == 0 && stomach_left() < 1)
	{
		auto_log_debug("Only 1 non reserved adv remains for main loop so doing free combats");
		return LX_freeCombats();
	}
	if(in_theSource() && my_adventures() < 10 && inebriety_left() == 0 && stomach_left() < 1)
	{
		auto_log_debug("Less than 10 adv remaining today. We should do free fights now in case any of them get replaced with a non free agent fight");
		return LX_freeCombats();
	}
	return false;
}
