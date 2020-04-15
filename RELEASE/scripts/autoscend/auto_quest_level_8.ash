script "auto_quest_level_8.ash"

boolean L8_trapperStart()
{
	if (internalQuestStatus("questL08Trapper") < 0 || internalQuestStatus("questL08Trapper") > 0)
	{
		return false;
	}

	auto_log_info("Let's meet the trapper.", "blue");

	visit_url("place.php?whichplace=mclargehuge&action=trappercabin");
	return true;
}

boolean L8_mineOre(item oreGoal, boolean simulate) {

	// If you want to test this in-run, use the following on the gCLI.
	// ash import <autoscend.ash> L8_mineOre(get_property("trapperOre").to_item(), true);
	// It will print the square it would mine.
	// (which you should then go mine manually otherwise subsequent calls will be useless because our tracking will be all messed up).

	// This isn't written to continue mining an already half-mined cavern.
	// Only use it for a new cavern otherwise it'll probably do weird stuff (aka undefined behaviour).

	if (!is_wearing_outfit("Mining Gear"))
	{
		return false;
	}

	item[int] parseMineLayout() {

		string[int] splitted = split_string(get_property("mineLayout1").substring(1), "#");

		item[int] minedCells;
		foreach iter, str in splitted {
			if (str.contains_text("asbestos ore")) {
				minedCells[str.substring(0,2).to_int()] = $item[asbestos ore];
			} else if (str.contains_text("chrome ore")) {
				minedCells[str.substring(0,2).to_int()] = $item[chrome ore];
			} else if (str.contains_text("linoleum ore")) {
				minedCells[str.substring(0,2).to_int()] = $item[linoleum ore];
			} else if (str.contains_text("loadstone")) {
				minedCells[str.substring(0,2).to_int()] = $item[loadstone];
			} else if (str.contains_text("lump of diamond")) {
				minedCells[str.substring(0,2).to_int()] = $item[lump of diamond];
			} else if (str.contains_text("meat stack")) {
				minedCells[str.substring(0,2).to_int()] = $item[meat stack];
			} else if (str.contains_text("stone of eXtreme power")) {
				minedCells[str.substring(0,2).to_int()] = $item[stone of eXtreme power];
			}
		}
		return minedCells;
	}

	int[4] getOrthogonals(int cell) {
		// starting at the cell above, going clockwise
		int[4] orthogonals; 
		orthogonals[0] = cell - 8;
		orthogonals[1] = cell + 1;
		orthogonals[2] = cell + 8;
		orthogonals[3] = cell - 1;
		return orthogonals;
	}

	boolean canMine(int cellToCheck, int rowLimit) {
		// this is basically bounds checking for cells
		// set rowLimit = 6 to not care about rows (there is no row 7)
		if (get_property("auto_minedCells").contains_text(to_string(cellToCheck))) {
			return false;
		}
		int column = cellToCheck % 8;
		if (column < 1 || column > 6 )
		{
			return false;
		}
		int row = cellToCheck / 8;
		if (row < 1 || row > 6 || row > rowLimit) {
			return false;
		}
		return true;
	}

	// https://kol.coldfront.net/thekolwiki/index.php/Inside_of_Itznotyerzitz_Mine

	// the mine is an 8*7 grid starting at 0,0 in the top left and each cell has an incrementing identifier starting at 0.
	// however all of row 0, column 0 and column 7 cannot be mined (so it's really a 6*6 grid with really confusing cell ids).
	// hence to translate from the grid to the cell we multiply the row by 8 and add the column
	// e.g. 4,6 becomes 4 + (6 * 8) = 52

	// trapper ores are predominantly found in the top 3 rows (1-3) and occasionally the 4th row.

	// annoyingly the preference mineLayout1 doesn't list empty cells so we have to track the cells we mined ourselves.

	int cell = 0; // this is the cell we will mine.
	string mineLayout = visit_url("mining.php?mine=1");
	if (get_property("auto_minedCells") == "") {
		// pick a random column to start between 2-5
		cell = 50 + random(4); // using 50 as we're in row 6 to start and random returns from 0 to range-1. Hence 6 * 8 + 2
	} else {
		string[int] previously_mined = split_string(get_property("auto_minedCells"), ",");
		int num_prev_mined = count(previously_mined);
		int lastCell = previously_mined[num_prev_mined - 1].to_int();
		if (num_prev_mined < 4 && (lastCell > 32 && lastCell < 55)) {
			// mine the square directly above it
			cell = lastCell - 8;
		} else {
			// we've got to row 3 or above. Start the search for ores.
			item[int] minedCells = parseMineLayout();
			int[int] oreSeen;
			int seenCount = 0;
			foreach cell, ore in minedCells {
				if (ore == oreGoal) {
					oreSeen[seenCount] = cell;
					seenCount++;
				}
			}
			if (count(oreSeen) == 0) {
				// not found any ore that we're looking for yet
				if (lastCell > 24 && lastCell < 31) {
					// get to row 2 as our probability of hitting ore we're looking for is higher.
					cell = lastCell - 8;
				} else {
					// find all the sparkling tiles in the top 2 rows
					matcher mr_sparkle = create_matcher("Promising Chunk of Wall \\((\\d),([12])\\)", mineLayout);
					int[int] potentialCells;
					int potentialCount = 0;
					while (mr_sparkle.find()) {
						int sparkleCell = mr_sparkle.group(1).to_int() + (mr_sparkle.group(2).to_int() * 8);
						boolean foundSparkle = false;
						foreach iter, potential in potentialCells {
							if (potential == sparkleCell)  {
								foundSparkle = true;
							}
						}
						if (!foundSparkle)
						{
							potentialCells[potentialCount] = sparkleCell;
							potentialCount++;
						}
					}
					// pick a random cell we can reach in the top 2 rows
					if (count(potentialCells) > 1)
					{
						cell = potentialCells[random(count(potentialCells))];
					} else if (count(potentialCells) == 1) {
						cell = potentialCells[0];
					}
				}
			} else {
				// find all the sparkling tiles
				matcher mr_sparkle = create_matcher("Promising Chunk of Wall \\((\\d),([123])\\)", mineLayout);
				string sparklingCells;
				while (mr_sparkle.find()) {
					int sparkleCell = mr_sparkle.group(1).to_int() + (mr_sparkle.group(2).to_int() * 8);
					if (!sparklingCells.contains_text(to_string(sparkleCell)))
					{
						sparklingCells = sparklingCells + sparkleCell.to_string() + ",";
					}
				}
				// search orthogonally from the cells we found our required ore in as ore is always contiguous
				int[int] potentialCells;
				int potentialCount = 0;
				foreach orePos, cell in oreSeen {
					int[4] orthogonals = getOrthogonals(cell);
					foreach orthoPos, orthoCell in orthogonals {
						if (canMine(orthoCell, 3) && sparklingCells.contains_text(to_string(orthoCell))) {
							// if we haven't already mined it and it's in one of the top 3 rows, add it to the list
							potentialCells[potentialCount] = orthoCell;
							potentialCount++;
						}
					}
				}
				if (count(potentialCells) > 1)
				{
					// TODO: Add some handling for if we exhaust all the possible cells in rows 1-3 when we've hit ore
					// As the wiki says ore can sometimes be found in row 4 and we could get unlucky where 2/4 are not in rows 1-3
					cell = potentialCells[random(count(potentialCells))];
				} else if (count(potentialCells) == 1) {
					cell = potentialCells[0];
				}
			}
		}
	}
	if (cell != 0) {
		set_property("auto_minedCells", get_property("auto_minedCells") + cell.to_string() + ",");
		if (!simulate) {
			visit_url("mining.php?mine=1&which=" + cell.to_string() + "&pwd");
		} else {
			auto_log_info("Would mine cell " + cell.to_string() + " (" + to_string(cell % 8) + "," + to_string(cell / 8) + ")");
		}
		return true;
	}
	return false;
}

void auto_testMining(item oreGoal) {
	// use this to test in aftercore. Will mine 3 ores of whatever type you pass e.g.
	// ash import <autoscend.ash> auto_testMining($item[linoleum ore]);
	// I'd recommend equipping some HP regen stuff in slots not needed by the Mining Gear
	// Shark Jumper & 1-3 Heart of the Volcano works well
	if (!possessOutfit("Mining Gear"))
	{
		return;
	}
	outfit("Mining Gear");
	int startingAmount = item_amount(oreGoal);
	remove_property("auto_minedCells");

	matcher openCheck = create_matcher("Open Cavern \\(\\d,6\\)", visit_url("mining.php?mine=1"));
	if (openCheck.find()) {
		auto_log_info("Resetting mine (doesn't cost an adventure)");
		visit_url("mining.php?mine=1&reset=1&pwd");
	}

	while (item_amount(oreGoal) < startingAmount + 3) {
		if (!L8_mineOre(oreGoal, false)) {
			auto_log_info("Something went wrong.");
			break;
		}
		if (my_hp() == 0) {
			acquireHP(1);
		}
	}
}

boolean L8_trapperGround()
{
	if (internalQuestStatus("questL08Trapper") < 0 || internalQuestStatus("questL08Trapper") > 1)
	{
		return false;
	}

	item oreGoal = get_property("trapperOre").to_item();

	if((item_amount(oreGoal) >= 3) && (item_amount($item[Goat Cheese]) >= 3))
	{
		auto_log_info("Giving Trapper goat cheese and " + oreGoal, "blue");
		visit_url("place.php?whichplace=mclargehuge&action=trappercabin");
		return true;
	}

	if(item_amount($item[Goat Cheese]) < 3)
	{
		auto_log_info("Yay for goat cheese!", "blue");
		handleFamiliar("item");
		if(get_property("_sourceTerminalDuplicateUses").to_int() == 0)
		{
			auto_sourceTerminalEducate($skill[Extract], $skill[Duplicate]);
		}
		autoAdv($location[The Goatlet]);
		auto_sourceTerminalEducate($skill[Extract], $skill[Portscan]);
		return true;
	}

	if((my_rain() > 50) && (have_effect($effect[Ultrahydrated]) == 0) && (auto_my_path() == "Heavy Rains") && have_skill($skill[Rain Man]))
	{
		auto_log_info("Trying to summon a mountain man", "blue");
		set_property("auto_mountainmen", "1");
		return rainManSummon("mountain man", false, false);
	}
	else if(auto_my_path() == "Heavy Rains")
	{
		#Do pulls instead if we don't possess rain man?
		auto_log_info("Need Ore but not enough rain", "blue");
		return false;
	}
	else if(!in_hardcore())
	{
		if(pulls_remaining() >= (3 - item_amount(oreGoal)))
		{
			pullXWhenHaveY(oreGoal, 3 - item_amount(oreGoal), item_amount(oreGoal));
			return true;
		}
	}
	else if (canGenieCombat() && (get_property("auto_useWishes").to_boolean()) && (catBurglarHeistsLeft() >= 2))
	{
		auto_log_info("Trying to wish for a mountain man, which the cat will then burgle, hopefully.");
		handleFamiliar("item");
		handleFamiliar($familiar[cat burglar]);
		return makeGenieCombat($monster[mountain man]);
	}
	else if((my_level() >= 12) && in_hardcore())
	{
		int numCloversKeep = 0;
		if(get_property("auto_wandOfNagamar").to_boolean())
		{
			numCloversKeep = 1;
			if(get_property("auto_powerLevelLastLevel").to_int() == my_level())
			{
				numCloversKeep = 0;
			}
		}
		if(auto_my_path() == "Nuclear Autumn")
		{
			if(cloversAvailable() <= numCloversKeep)
			{
				handleBarrelFullOfBarrels(false);
				string temp = visit_url("barrel.php");
				temp = visit_url("choice.php?whichchoice=1099&pwd=&option=2");
				handleBarrelFullOfBarrels(false);
				return true;
			}
		}
		if(cloversAvailable() > numCloversKeep)
		{
			cloverUsageInit();
			autoAdvBypass(270, $location[Itznotyerzitz Mine]);
			cloverUsageFinish();
			return true;
		}
	} else if (get_property("auto_mineForOres").to_boolean()) {
		if (!possessOutfit("Mining Gear")) {
			auto_log_info("Getting Mining Gear.", "blue");
			providePlusNonCombat(25);
			handleFamiliar("item");
			return autoAdv($location[Itznotyerzitz Mine]);
		} else if (possessOutfit("Mining Gear", true)) {
			outfit("Mining Gear");
			auto_log_info("GOLD, gold, Gold, Gold GOLD, Gold...", "blue");
			boolean mineResult = L8_mineOre(oreGoal, false);
			acquireHP(1);
			return mineResult;
		}
	}
	return false;
}

boolean L8_trapperExtreme()
{
	if(get_property("currentExtremity").to_int() >= 3)
	{
		return false;
	}
	if (internalQuestStatus("questL08Trapper") != 2)
	{
		return false;
	}
	if(get_property("_sourceTerminalDigitizeMonster") == $monster[Ninja Snowman Assassin])
	{
		return false;
	}

	if (possessOutfit("eXtreme Cold-Weather Gear", true)) {
		autoOutfit("eXtreme Cold-Weather Gear");
	} else if (possessOutfit("eXtreme Cold-Weather Gear")) {
		auto_log_warning("I can not wear the eXtreme Gear, I'm just not awesome enough :(", "red");
		return false;
	}

	auto_log_info("Penguin Tony Hawk time. Extreme!! SSX Tricky!!", "blue");
	providePlusNonCombat(25);
	handleFamiliar("item");
	return autoAdv($location[The eXtreme Slope]);
}

boolean L8_trapperNinjaLair()
{
	if (internalQuestStatus("questL08Trapper") != 2)
	{
		return false;
	}

	if(!have_skill($skill[Rain Man]) && (pulls_remaining() >= 3) && (internalQuestStatus("questL08Trapper") < 3))
	{
		foreach it in $items[Ninja Carabiner, Ninja Crampons, Ninja Rope]
		{
			pullXWhenHaveY(it, 1, 0);
		}
	}

	if((item_amount($item[Ninja Rope]) >= 1) && (item_amount($item[Ninja Carabiner]) >= 1) && (item_amount($item[Ninja Crampons]) >= 1))
	{
		return false;
	}

	if(get_property("_sourceTerminalDigitizeMonster") == $monster[Ninja Snowman Assassin])
	{
		if(loopHandler("_auto_digitizeAssassinTurn", "_auto_digitizeAssassinCounter", "Potentially unable to do anything while waiting on digitized Ninja Snowman Assassin.", 10))
		{
			auto_log_info("Have a digitized Ninja Snowman Assassin, let's put off the Ninja Snowman Lair", "blue");
		}
		return false;
	}

	if(in_hardcore())
	{
		if (isActuallyEd())
		{
			if((have_effect($effect[Taunt of Horus]) == 0) && (item_amount($item[Talisman of Horus]) == 0))
			{
				return false;
			}
		}
		if((have_effect($effect[Thrice-Cursed]) > 0) || (have_effect($effect[Twice-Cursed]) > 0) || (have_effect($effect[Once-Cursed]) > 0))
		{
			return false;
		}

		handleFamiliar("item");
		asdonBuff($effect[Driving Obnoxiously]);
		if(!providePlusCombat(25))
		{
			auto_log_warning("Could not uneffect for ninja snowmen, delaying", "red");
			return false;
		}

		if (isActuallyEd() && !elementalPlanes_access($element[spooky]))
		{
			adjustEdHat("myst");
		}

		if(numeric_modifier("Combat Rate") <= 9.0)
		{
			autoEquip($slot[Back], $item[Carpe]);
		}

		if(numeric_modifier("Combat Rate") <= 0.0)
		{
			auto_log_warning("Something is keeping us from getting a suitable combat rate, we have: " + numeric_modifier("Combat Rate") + " and Ninja Snowmen.", "red");
			equipBaseline();
			return false;
		}

		if(!autoAdv(1, $location[Lair of the Ninja Snowmen]))
		{
			auto_log_warning("Seems like we failed the Ninja Snowmen unlock, reverting trapper setting", "red");
		}
		return true;
	}
	return false;
}

boolean L8_trapperGroar()
{
	if (internalQuestStatus("questL08Trapper") < 2 || internalQuestStatus("questL08Trapper") > 5)
	{
		// if we haven't returned the goat cheese and ore
		// to the trapper yet, don't try to ascend the peak.
		return false;
	}

	boolean canGroar = false;

	if((item_amount($item[Ninja Rope]) >= 1) && (item_amount($item[Ninja Carabiner]) >= 1) && (item_amount($item[Ninja Crampons]) >= 1))
	{
		canGroar = true;
		//If we can not get enough cold resistance, maybe we need to do extreme path.
	}
	if((internalQuestStatus("questL08Trapper") == 2) && (get_property("currentExtremity").to_int() == 3))
	{
		// TODO: There are some reports of this breaking in TCRS, when cold-weather
		// gear is not sufficient to have 5 cold resistance. Use a maximizer statement?
		if(outfit("eXtreme Cold-Weather Gear"))
		{
			string temp = visit_url("place.php?whichplace=mclargehuge&action=cloudypeak");
			return true;
		}
	}
	if((internalQuestStatus("questL08Trapper") >= 3) && (get_property("currentExtremity").to_int() == 0))
	{
		canGroar = true;
	}

	// Just in case
	cli_execute("refresh quests");

	//What is our potential +Combat score.
	//TODO: Use that instead of the Avatar/Hound Dog checks.

	if(!canGroar && in_hardcore() && ((auto_my_path() == "Avatar of Sneaky Pete") || !auto_have_familiar($familiar[Jumpsuited Hound Dog]) || forbidFamChange($familiar[Jumpsuited Hound Dog])))
	{
		if(L8_trapperExtreme())
		{
			return true;
		}
	}
	if(get_property("auto_powerLevelAdvCount").to_int() > 8)
	{
		if(L8_trapperExtreme())
		{
			return true;
		}
	}

	if((item_amount($item[Groar\'s Fur]) > 0) || (item_amount($item[Winged Yeti Fur]) > 0) || (internalQuestStatus("questL08Trapper") == 5))
	{
		visit_url("place.php?whichplace=mclargehuge&action=trappercabin");
		if(item_amount($item[Dense Meat Stack]) >= 5)
		{
			auto_autosell(5, $item[Dense Meat Stack]);
		}
		council();
		return true;
	}

	if(canGroar)
	{
		int [element] resGoal;
		resGoal[$element[cold]] = 5;
		// try getting resistance without equipment before bothering to change gear
		if(provideResistances(resGoal, false) || provideResistances(resGoal, true))
		{
			if (internalQuestStatus("questL08Trapper") == 2)
			{
				set_property("auto_ninjasnowmanassassin", "1");
				visit_url("place.php?whichplace=mclargehuge&action=trappercabin");
				visit_url("place.php?whichplace=mclargehuge&action=cloudypeak");
			}

			auto_log_info("Time to take out Gargle, sure, Gargle (Groar)", "blue");
			if (item_amount($item[Groar\'s Fur]) == 0 && item_amount($item[Winged Yeti Fur]) == 0)
			{
				addToMaximize("2000cold resistance 5max");
				//If this returns false, we might have finished already, can we check this?
				boolean retval = autoAdv(1, $location[Mist-shrouded Peak]);
				removeFromMaximize("2000cold resistance 5max");
				return retval;
			}
			else
			{
				visit_url("place.php?whichplace=mclargehuge&action=trappercabin");
				auto_autosell(5, $item[dense meat stack]);
				council();
			}
			return true;
		}
	}
	return false;
}
