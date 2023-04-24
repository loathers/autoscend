boolean L4_batCave()
{
	if(internalQuestStatus("questL04Bat") < 0 || internalQuestStatus("questL04Bat") > 4)
	{
		return false;
	}

	auto_log_info("In the bat hole!", "blue");

	if(considerGrimstoneGolem(true))
	{
		handleBjornify($familiar[Grimstone Golem]);
	}
	buffMaintain($effect[Fishy Whiskers]);

	int batStatus = internalQuestStatus("questL04Bat");
	if(batStatus < 3)
	{
		if(auto_is_valid($item[Sonar-In-A-Biscuit]))
		{
			if(item_amount($item[Sonar-In-A-Biscuit]) == 0 && can_interact())
			{
				buyUpTo(1, $item[Sonar-In-A-Biscuit], get_property("valueOfAdventure").to_int());
			}
			if(item_amount($item[Sonar-In-A-Biscuit]) > 0)
			{
				if(use(1, $item[Sonar-In-A-Biscuit]))
				{
					return true;
				}
				else
				{
					auto_log_warning("Failed to use Sonar-In-A-Biscuit for some reason. refreshing inventory and skipping", "red");
					visit_url("place.php?whichplace=bathole");
					cli_execute("refresh inv");
					return false;
				}
			}
		}
	}

	if(batStatus >= 4)
	{
		if(item_amount($item[Enchanted Bean]) == 0 && internalQuestStatus("questL10Garbage") < 1 && !isActuallyEd())
		{
			return autoAdv($location[The Beanbat Chamber]);
		}
		council();
		if(in_koe())
		{
			cli_execute("refresh quests");
		}
		return true;
	}
	
	if(batStatus >= 3)
	{
		buffMaintain($effect[Polka of Plenty], 15, 1, 1);
		//AoSOL buffs
		if(in_aosol())
		{
			buffMaintain($effect[Queso Fustulento], 10, 1, 10);
			buffMaintain($effect[Tricky Timpani], 30, 1, 10);
			if(auto_haveGreyGoose() && $location[The Boss Bat's Lair].turns_spent >=4){
				handleFamiliar($familiar[Grey Goose]);
			}
		}
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
		// this breaks that infinite loop, while "refresh quests" apparently doesn't. Who knows?
		visit_url("place.php?whichplace=bathole");
		return true;
	}
	if(batStatus >= 2)
	{
		bat_formBats();
		if(item_amount($item[Enchanted Bean]) == 0 && internalQuestStatus("questL10Garbage") < 2 && !isActuallyEd())
		{
			autoAdv($location[The Beanbat Chamber]);
			return true;
		}
		if(shenShouldDelayZone($location[The Batrat and Ratbat Burrow]))
		{
			auto_log_debug("Delaying Batrat Burrow in case of Shen.");
			return false;
		}
		if(auto_haveGreyGoose()){
			handleFamiliar($familiar[Grey Goose]);
		}
		autoAdv($location[The Batrat and Ratbat Burrow]);
		return true;
	}
	if(batStatus >= 1)
	{
		if(shenShouldDelayZone($location[The Batrat and Ratbat Burrow]))
		{
			auto_log_debug("Delaying Batrat Burrow in case of Shen.");
			return false;
		}
		bat_formBats();
		if(auto_haveGreyGoose()){
			handleFamiliar($familiar[Grey Goose]);
		}
		autoAdv($location[The Batrat and Ratbat Burrow]);
		return true;
	}

	int [element] resGoal;
	resGoal[$element[stench]] = 1;
	// try to get the stench res without equipment, but use equipment if we must
	if(!provideResistances(resGoal, $location[Guano Junction], false) && !provideResistances(resGoal, $location[Guano Junction], true))
	{
		auto_log_warning("I can nae handle the stench of the Guano Junction!", "green");
		return false;
	}

	bat_formBats();
	if(auto_haveGreyGoose()){
		handleFamiliar($familiar[Grey Goose]);
	}
	return autoAdv($location[Guano Junction]);
}
