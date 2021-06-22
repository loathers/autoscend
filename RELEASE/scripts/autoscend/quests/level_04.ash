boolean L4_batCave()
{
	if (internalQuestStatus("questL04Bat") < 0 || internalQuestStatus("questL04Bat") > 4)
	{
		return false;
	}

	auto_log_info("In the bat hole!", "blue");

	if(considerGrimstoneGolem(true))
	{
		handleBjornify($familiar[Grimstone Golem]);
	}
	buffMaintain($effect[Fishy Whiskers], 0, 1, 1);

	int batStatus = internalQuestStatus("questL04Bat");
	if(batStatus < 3)
	{
		boolean can_use_biscuit = auto_is_valid($item[Sonar-In-A-Biscuit]);
		if(can_use_biscuit && item_amount($item[Sonar-In-A-Biscuit]) > 0)
		{
			if(use(1, $item[Sonar-In-A-Biscuit]))
			{
				return true;
			}
			else
			{
				auto_log_warning("Failed to use [Sonar-In-A-Biscuit] for some reason. refreshing inventory and skipping", "red");
				visit_url("place.php?whichplace=bathole");
				cli_execute("refresh inv");
			}
		}
		else if(can_use_biscuit && can_interact())
		{
			//if in post ronin or in casual, buy and use [Sonar-In-A-Biscuit] if cheaper than 500 meat.
			if(buyUpTo(1, $item[Sonar-In-A-Biscuit], 500))
			{
				if(use(1, $item[Sonar-In-A-Biscuit])) return true;
			}
		}
	}

	if(batStatus >= 4)
	{
		if (item_amount($item[Enchanted Bean]) == 0 && internalQuestStatus("questL10Garbage") < 1 && !isActuallyEd())
		{
			return autoAdv($location[The Beanbat Chamber]);
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
		autoAdv($location[The Boss Bat\'s Lair]);
		# POCKET FAMILIARS remove once mafia tracks this
		if(item_amount($item[Batskin Belt]) != batskinBelt)
		{
			auto_badassBelt(); // mafia doesn't make this any more even if autoCraft = true for some random reason so lets do it manually.
		}
		// TODO: Mafia currently does not advance the quest tracker when the Plumber boss is defeated.
		// This breaks that infinite loop, while "refresh quests" apparently doesn't. Who knows?
		visit_url("place.php?whichplace=bathole");
		return true;
	}
	if(batStatus >= 2)
	{
		bat_formBats();
		if (item_amount($item[Enchanted Bean]) == 0 && internalQuestStatus("questL10Garbage") < 2 && !isActuallyEd())
		{
			autoAdv($location[The Beanbat Chamber]);
			return true;
		}
		if (shenShouldDelayZone($location[The Batrat and Ratbat Burrow]))
		{
			auto_log_debug("Delaying Batrat Burrow in case of Shen.");
			return false;
		}
		autoAdv($location[The Batrat and Ratbat Burrow]);
		return true;
	}
	if(batStatus >= 1)
	{
		if (shenShouldDelayZone($location[The Batrat and Ratbat Burrow]))
		{
			auto_log_debug("Delaying Batrat Burrow in case of Shen.");
			return false;
		}
		bat_formBats();
		autoAdv($location[The Batrat and Ratbat Burrow]);
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

	if (cloversAvailable() > 0 && batStatus <= 1 && !in_bhy())
	{
		if(my_hp() < 6)	//we will be taking 5 damage from this
		{
			if(my_maxhp() < 6)
			{
				auto_log_warning("How did I end up in [Guano Junction] with less than 6 max HP? skipping until maxHP > 5", "blue");
				return false;
			}
			if(isActuallyEd())
			{
				auto_log_warning("Ed wanted to clover [Guano Junction] but does not have enough HP. skipping until HP > 5", "blue");
				return false;
			}
			if(!acquireHP(6))	//try to restore HP to avoid beaten up
			{
				auto_log_warning("Tried to restore HP to 6 to clover [Guano Junction] but failed to do so. skipping until HP > 5", "blue");
				return false;
			}
		}
		cloverUsageInit();
		autoAdvBypass(31, $location[Guano Junction]);
		cloverUsageFinish();
		return true;
	}

	bat_formBats();
	return autoAdv($location[Guano Junction]);
}
