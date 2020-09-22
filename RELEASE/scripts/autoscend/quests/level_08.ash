boolean L8_trapperStart()
{
	if (internalQuestStatus("questL08Trapper") != 0)
	{
		return false;
	}

	auto_log_info("Let's meet the trapper.", "blue");

	visit_url("place.php?whichplace=mclargehuge&action=trappercabin");
	return true;
}

boolean needOre()
{
	//Determines if we need ore for the trapper or not.
	
	if (internalQuestStatus("questL08Trapper") > 2)
	{
		return false;
	}
	item oreGoal = to_item(get_property("trapperOre"));
	if(item_amount(oreGoal) >= 3)
	{
		return false;
	}
	if((item_amount($item[Asbestos Ore]) >= 3) && (item_amount($item[Linoleum Ore]) >= 3) && (item_amount($item[Chrome Ore]) >= 3))
	{
		return false;
	}
	return true;
}

int getCellToMine(item oreGoal) {

	// the mine is an 8*7 grid starting at 0,0 in the top left and each cell has an incrementing identifier starting at 0.
	// however all of row 0, column 0 and column 7 cannot be mined (so it's really a 6*6 grid with really confusing cell ids).
	// hence to translate from the grid to the cell we multiply the row by 8 and add the column
	// e.g. 4,6 becomes 4 + (6 * 8) = 52

	// trapper ores are predominantly found in the top 3 rows (1-3) and occasionally the 4th row.
	// See https://kol.coldfront.net/thekolwiki/index.php/Inside_of_Itznotyerzitz_Mine

	// the information we need is spread between the page (unmined sparkling cells) and the mineLayout1 property (what we got when mined the cell).

	if (!is_wearing_outfit("Mining Gear"))
	{
		return 0;
	}

	item[int] parseMineLayout() {
		
		item[int] minedCells;
		string mineLayout = get_property("mineLayout1");
		if (mineLayout != "") {
			foreach iter, str in split_string(mineLayout.substring(1), "#") {
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
		}
		return minedCells;
	}

	int[int] findSparklingCells(string minePage) {
		int[int] sparkles;
		matcher mrSparkle = create_matcher("title='Promising Chunk of Wall \\((\\d),(\\d)\\)", minePage);
		while (mrSparkle.find()) {
			int sparkleCell = mrSparkle.group(1).to_int() + (mrSparkle.group(2).to_int() * 8);
			sparkles[sparkleCell] = 1; // don't actually care about the value. Just want the cells as keys so we can use contains
		}
		return sparkles;
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

	boolean isInSideColumn(int cellToCheck) {
		int column = cellToCheck % 8;
		if (column == 1 || column == 6)
		{
			return true;
		}
		return false;
	}

	// - Simplest case, a fresh mine cavern
	string mineLayout = visit_url("mining.php?mine=1");
	if (get_property("auto_minedCells") == "") {
		// pick a random column to start between 2-5
		return 50 + random(4); // using 50 as we're in row 6 to start and random returns from 0 to range-1. Hence 6 * 8 + 2
	}

	// - If we have started mining a cavern, lets continue mining the same column upwards until row 3
	string[int] previously_mined = split_string(get_property("auto_minedCells"), ",");
	int num_prev_mined = count(previously_mined);
	int lastCell = previously_mined[num_prev_mined - 1].to_int();
	if (num_prev_mined < 4 && (lastCell > 32 && lastCell < 55)) {
		// mine the square directly above it
		return lastCell - 8;
	}

	// - If we've got to row 3 or above, start searching for ores.
	item[int] minedCells = parseMineLayout();
	int[int] oreSeen;
	foreach oreCell, oreType in minedCells {
		if (oreType == oreGoal) {
			oreSeen[oreCell] = 1; // value doesn't matter, just want to count and iterate the keys
		}
	}
	int[int] sparklingCells = findSparklingCells(mineLayout);
	int[int] potentialCells;
	int potentialCount = 0;
	if (count(oreSeen) == 0) {
		// - Not found any ore that we're looking for yet
		if (lastCell > 24 && lastCell < 31) {
			// get to row 2 as our probability of hitting ore we're looking for is higher.
			return lastCell - 8;
		}
		// find all the sparkling tiles in the top n rows
		// start from the top 2, if we haven't found any there,
		// increase the search space by 1 row and check again until we max out at the 4th row
		// avoid columns 1 and 6 as they limit the search space since we can't mine column 0 or 7.
		// unless we run into a situation where we've mined all the other sparkling cells.
		int rowLimit = 2;
		boolean avoidSides = true;
		while (count(potentialCells) == 0 && rowLimit < 5) {
			foreach sparkleCell in sparklingCells {
				if (canMine(sparkleCell, rowLimit)) {
					if (!isInSideColumn(sparkleCell) || !avoidSides) {
						potentialCells[potentialCount] = sparkleCell;
						potentialCount++;
					}
				}
			}
			rowLimit++;
			if (avoidSides && rowLimit == 5 && count(potentialCells) == 0) {
				avoidSides = false;
				rowLimit = 2;
			}
		}
	} else {
		// - Found at least one ore that we're looking for!
		// search orthogonally from the cells we found our required ore in as ore is always contiguous
		// limit our search to the top 3 rows to begin, if we don't find any cells that meet the criteria
		// increase the limit to the top 4 rows and check again.
		int rowLimit = 3;
		while (count(potentialCells) == 0 && rowLimit < 5) {
			foreach oreCell in oreSeen {
				int[4] orthogonals = getOrthogonals(oreCell);
				foreach _, orthoCell in orthogonals {
					if (canMine(orthoCell, rowLimit) && sparklingCells contains orthoCell) {
						potentialCells[potentialCount] = orthoCell;
						potentialCount++;
					}
				}
			}
			rowLimit++;
		}
		if (count(potentialCells) == 0) {
			// we could be in a situation where the loadstone replaced one of our ores and we still need 1 or 2 ores
			// but have exhausted all the twinkling cells adjacent to the ores we've found
			// first lets find the loadstone cell
			int loadstoneCell;
			foreach oreCell, oreType in minedCells {
				if (oreType == $item[loadstone]) {
					loadstoneCell = oreCell;
				}
			}
			// now add all twinkling cells adjacent to the loadstone in the top 4 rows to the potential cells
			int[4] orthogonals = getOrthogonals(loadstoneCell);
			foreach _, orthoCell in orthogonals {
				if (canMine(orthoCell, 4) && sparklingCells contains orthoCell) {
					potentialCells[potentialCount] = orthoCell;
					potentialCount++;
				}
			}
		}
	}
	int numPotentials = count(potentialCells);
	// only found one potential, just return it
	if (numPotentials == 1) {
		return potentialCells[0];
	} else if (numPotentials == 0) {
		abort("Glitch in the matrix. Please report this to the dev team (preferably with a log and screenshot of your mine");
	}
	// found 2 or more potentials, return a random one of them
	return potentialCells[random(numPotentials)];
}

boolean L8_trapperAdvance()
{
	if (internalQuestStatus("questL08Trapper") < 0 || internalQuestStatus("questL08Trapper") > 1)
	{
		return false;
	}
	if (item_amount(get_property("trapperOre").to_item()) >= 3 && item_amount($item[Goat Cheese]) >= 3)
	{
		auto_log_info("Giving Trapper goat cheese and " + get_property("trapperOre").to_item(), "blue");
		visit_url("place.php?whichplace=mclargehuge&action=trappercabin");
		return true;
	}
	return false;
}

boolean L8_getGoatCheese()
{
	if (internalQuestStatus("questL08Trapper") < 0 || internalQuestStatus("questL08Trapper") > 1)
	{
		return false;
	}

	if(item_amount($item[Goat Cheese]) >= 3)
	{
		return false;
	}

	auto_log_info("Yay for goat cheese!", "blue");
	if(get_property("_sourceTerminalDuplicateUses").to_int() == 0)
	{
		auto_sourceTerminalEducate($skill[Extract], $skill[Duplicate]);
	}
	boolean retval = autoAdv($location[The Goatlet]);
	auto_sourceTerminalEducate($skill[Extract], $skill[Portscan]);
	return retval;
}

boolean L8_getMineOres()
{
	if (internalQuestStatus("questL08Trapper") < 0 || internalQuestStatus("questL08Trapper") > 1)
	{
		return false;
	}

	item oreGoal = get_property("trapperOre").to_item();

	if (item_amount(oreGoal) >= 3) {
		return false;
	}

	if (get_property("chateauMonster").to_monster() == $monster[Mountain Man]) {
		// apparently this is a thing some people do. Lets add the most basic of support.
		return false;
	}

	//heavy rain copy handling.
	if(auto_my_path() == "Heavy Rains" && have_skill($skill[Rain Man]))
	{
		if(my_rain() < 50)
		{
			auto_log_info("Need Ore but not enough rain. Delaying ore for trapper", "blue");
			return false;
		}
		if(have_effect($effect[Ultrahydrated]) == 0 && my_rain() < 90)
		{
			auto_log_info("Do not waste ultrahydrated. Delaying ore for trapper", "blue");
			return false;
		}
		auto_log_info("Trying to summon a mountain man", "blue");
		set_property("auto_mountainmen", "1");
		return rainManSummon("mountain man", false, false);
	}
	
	//in softcore we want to pull the ores.
	if(!in_hardcore())
	{
		if(pulls_remaining() < (3 - item_amount(oreGoal)))
		{
			return false;	//if not enough pulls left wait until tomorrow
		}
		pullXWhenHaveY(oreGoal, 3 - item_amount(oreGoal), item_amount(oreGoal));
		if(item_amount(oreGoal) == 3)
		{
			return true;	//pulled successfully.
		}
		//do not return false if failed to pull despite having enough pulls left. It suggests there is some other issue preventing us from pulling so we should go forwards and acquire them.
	}
	
	//use 1 wish if we can guarentee it will be enough via cat burglar
	if(canGenieCombat() && get_property("auto_useWishes").to_boolean() && catBurglarHeistsLeft() > 1)
	{
		auto_log_info("Trying to wish for a mountain man, which the cat will then burgle, hopefully.");
		handleFamiliar($familiar[cat burglar]);
		return makeGenieCombat($monster[mountain man]);
	}
	
	//try to clover for the ore
	int numCloversKeep = 0;
	if(get_property("auto_wandOfNagamar").to_boolean())
	{
		numCloversKeep = 1;
		if(isAboutToPowerlevel())
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

	if(isAboutToPowerlevel()) {
		if (!possessOutfit("Mining Gear")) {
			auto_log_info("Getting Mining Gear.", "blue");
			return autoAdv($location[Itznotyerzitz Mine]);
		} else if (possessOutfit("Mining Gear", true)) {
			equipMaximizedGear();
			outfit("Mining Gear");
			acquireHP(1);
			auto_log_info("Mining in Itznotyerzitz Mine for Trapper ore", "blue");
			int cell = getCellToMine(oreGoal);
			if (cell != 0) {
				set_property("auto_minedCells", get_property("auto_minedCells") + cell.to_string() + ",");
				visit_url("mining.php?mine=1&which=" + cell.to_string() + "&pwd");
				return true;
			}
		}
	}
	
	return false;
}

void itznotyerzitzMineChoiceHandler(int choice) {
	auto_log_info("itznotyerzitzMineChoiceHandler Running choice " + choice, "blue");
	if (choice == 18) { // A Flat Miner
		if (possessEquipment($item[miner\'s pants])) {
			if (possessEquipment($item[7-Foot Dwarven mattock])) {
				run_choice(3); // get 100 Meat.
			} else {
				run_choice(2); // get 7-Foot Dwarven mattock
			}
		} else {
			run_choice(1); // get miner's pants
		}
	} else if (choice == 19) { // 100% Legal
		if (possessEquipment($item[miner\'s helmet])) {
			if (possessEquipment($item[miner\'s pants])) {
				run_choice(3); // get 100 Meat.
			} else {
				run_choice(2); // get miner's pants
			}
		} else {
			run_choice(1); // get miner's helmet
		}
	} else if (choice == 20) { // See You Next Fall
		if (possessEquipment($item[miner\'s helmet])) {
			if (possessEquipment($item[7-Foot Dwarven mattock])) {
				run_choice(3); // get 100 Meat.
			} else {
				run_choice(2); // get 7-Foot Dwarven mattock
			}
		} else {
			run_choice(1); // get miner's helmet
		}
	} else if (choice == 556) { // More Locker Than Morlock
		if (!possessOutfit("Mining Gear")) {
			run_choice(1); // get an outfit piece
		} else {
			run_choice(2); // skip
		}
	} else {
		abort("unhandled choice in itznotyerzitzMineChoiceHandler");
	}
}

boolean L8_trapperGround()
{
	if (internalQuestStatus("questL08Trapper") < 0 || internalQuestStatus("questL08Trapper") > 1)
	{
		return false;
	}
	if (L8_getGoatCheese() || L8_getMineOres() || L8_trapperAdvance())
	{
		return true;
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
	return autoAdv($location[The eXtreme Slope]);
}

void theeXtremeSlopeChoiceHandler(int choice) {
	auto_log_info("theeXtremeSlopeChoiceHandler Running choice " + choice, "blue");
	if (choice == 15) { // Yeti Nother Hippy
		if (possessEquipment($item[eXtreme mittens])) {
			if (possessEquipment($item[eXtreme scarf])) {
				run_choice(3); // get 200 Meat.
			} else {
				run_choice(2); // get eXtreme scarf
			}
		} else {
			run_choice(1); // get eXtreme mittens
		}
	} else if (choice == 16)  { // Saint Beernard
		if (possessEquipment($item[snowboarder pants])) {
			if (possessEquipment($item[eXtreme scarf])) {
				run_choice(3); // get 200 Meat.
			} else {
				run_choice(2); // get eXtreme scarf
			}
		} else {
			run_choice(1); // get snowboarder pants
		}
	} else if (choice == 17) { // Generic Teen Comedy Snowboarding Adventure
		if (possessEquipment($item[eXtreme mittens])) {
			if (possessEquipment($item[snowboarder pants])) {
				run_choice(3); // get 200 Meat.
			} else {
				run_choice(2); // get snowboarder pants
			}
		} else {
			run_choice(1); // get eXtreme mittens
		}
	} else if (choice == 575) { // Duffel on the Double
		if (!possessOutfit("eXtreme Cold-Weather Gear")) {
			run_choice(1); // get an outfit piece
		} else {
			if (isActuallyEd()) { // add other paths which don't want to waste spleen (if any) here.
				run_choice(3); // skip
			} else {
				run_choice(4); // Lucky Pill. (Clover for 1 spleen, worth?)
			}
		}
	} else {
		abort("unhandled choice in theeXtremeSlopeChoiceHandler");
	}
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

	if (in_hardcore()) {
		if((have_effect($effect[Thrice-Cursed]) > 0) || (have_effect($effect[Twice-Cursed]) > 0) || (have_effect($effect[Once-Cursed]) > 0))
		{
			return false;
		}

		if (shenShouldDelayZone($location[Lair of the Ninja Snowmen]))
		{
			auto_log_debug("Delaying Lair of the Ninja Snowmen in case of Shen.");
			return false;
		}

		if (isActuallyEd() && !elementalPlanes_access($element[spooky]))
		{
			adjustEdHat("myst");
		}

		if (providePlusCombat(25, true, true) <= 0.0) {
			auto_log_warning("Something is keeping us from getting a suitable combat rate, we have: " + numeric_modifier("Combat Rate") + " and Ninja Snowmen.", "red");
			return false;
		}

		if (autoAdv($location[Lair of the Ninja Snowmen])) {
			return true;
		}
		auto_log_warning("Seems like we failed the Ninja Snowmen unlock, reverting trapper setting", "red");
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

	if(!canGroar && in_hardcore() && ((auto_my_path() == "Avatar of Sneaky Pete") || !canChangeToFamiliar($familiar[Jumpsuited Hound Dog])))
	{
		if(L8_trapperExtreme())
		{
			return true;
		}
	}
	if(isAboutToPowerlevel())
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
				return autoAdv($location[Mist-shrouded Peak]);
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

boolean L8_trapperQuest() {
	if (internalQuestStatus("questL08Trapper") < 0 || internalQuestStatus("questL08Trapper") > 5)
	{
		return false;
	}
	if (L8_trapperStart() || L8_getGoatCheese() || L8_getMineOres() || L8_trapperAdvance() || L8_trapperNinjaLair() || L8_trapperGroar())
	{
		return true;
	}
	return false;
}
