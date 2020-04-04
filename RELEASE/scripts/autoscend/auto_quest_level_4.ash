script "auto_quest_level_4.ash"

boolean L4_batCave()
{
	if (internalQuestStatus("questL04Bat") < 0 || internalQuestStatus("questL04Bat") > 4)
	{
		return false;
	}

	auto_log_info("In the bat hole!", "blue");
	visit_url("place.php?whichplace=bathole"); // ensure quest status is updated.
	if(considerGrimstoneGolem(true))
	{
		handleBjornify($familiar[Grimstone Golem]);
	}
	buffMaintain($effect[Fishy Whiskers], 0, 1, 1);

	int batStatus = internalQuestStatus("questL04Bat");
	if((item_amount($item[Sonar-In-A-Biscuit]) > 0) && (batStatus < 3))
	{
		if(use(1, $item[Sonar-In-A-Biscuit]))
		{
			return true;
		}
		else
		{
			auto_log_warning("Failed to use [Sonar-In-A-Biscuit] for some reason. refreshing inventory and skipping", "red");
			cli_execute("refresh inv");
		}
	}

	if(batStatus >= 4)
	{
		if (item_amount($item[Enchanted Bean]) == 0 && internalQuestStatus("questL10Garbage") < 2 && !isActuallyEd())
		{
			autoAdv(1, $location[The Beanbat Chamber]);
			return true;
		}
		council();
		if (in_koe())
		{
			cli_execute("refresh quests");
		}
		return true;
	}
	
	if(batStatus >= 3)
	{
		buffMaintain($effect[Polka of Plenty], 15, 1, 1);
		bat_formWolf();
		addToMaximize("10meat");
		int batskinBelt = item_amount($item[Batskin Belt]);
		auto_change_mcd(4); // get the pants from the Boss Bat.
		autoAdv(1, $location[The Boss Bat\'s Lair]);
		# DIGIMON remove once mafia tracks this
		if(item_amount($item[Batskin Belt]) != batskinBelt)
		{
			auto_badassBelt(); // mafia doesn't make this any more even if autoCraft = true for some random reason so lets do it manually.
		}
		return true;
	}
	if(batStatus >= 2)
	{
		bat_formBats();
		if (item_amount($item[Enchanted Bean]) == 0 && internalQuestStatus("questL10Garbage") < 2 && !isActuallyEd())
		{
			autoAdv(1, $location[The Beanbat Chamber]);
			return true;
		}
		autoAdv(1, $location[The Batrat and Ratbat Burrow]);
		return true;
	}
	if(batStatus >= 1)
	{
		bat_formBats();
		autoAdv(1, $location[The Batrat and Ratbat Burrow]);
		return true;
	}

	int [element] resGoal;
	resGoal[$element[stench]] = 1;
	// try to get the stench res without equipment, but use equipment if we must
	if(!provideResistances(resGoal, false) && !provideResistances(resGoal, true))
	{
		auto_log_warning("I can nae handle the stench of the Guano Junction!", "green");
		return false;
	}

	if (cloversAvailable() > 0 && batStatus <= 1)
	{
		cloverUsageInit();
		autoAdvBypass(31, $location[Guano Junction]);
		cloverUsageFinish();
		return true;
	}

	bat_formBats();
	autoAdv(1, $location[Guano Junction]);
	return true;
}