boolean needOre()
{
	// Determines if we need ore for the trapper or not.
	
	if(internalQuestStatus("questL08Trapper") > 2)
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

int getCellToMine(item oreGoal)
{

	// the mine is an 8*7 grid starting at 0,0 in the top left and each cell has an incrementing identifier starting at 0.
	// however all of row 0, column 0 and column 7 cannot be mined (so it's really a 6*6 grid with really confusing cell ids).
	// hence to translate from the grid to the cell we multiply the row by 8 and add the column
	// e.g. 4,6 becomes 4 + (6 * 8) = 52

	// trapper ores are predominantly found in the top 3 rows (1-3) and occasionally the 4th row.
	// See https://kol.coldfront.net/thekolwiki/index.php/Inside_of_Itznotyerzitz_Mine

	// the information we need is spread between the page (unmined sparkling cells) and the mineLayout1 property (what we got when mined the cell).

	if(!is_wearing_outfit("Mining Gear"))
	{
		return 0;
	}

	item[int] parseMineLayout()
	{
		item[int] minedCells;
		string mineLayout = get_property("mineLayout1");
		if(mineLayout != "")
		{
			foreach iter, str in split_string(mineLayout.substring(1), "#")
			{
				if(str.contains_text("asbestos ore"))
				{
					minedCells[str.substring(0,2).to_int()] = $item[asbestos ore];
				}
				else if(str.contains_text("chrome ore"))
				{
					minedCells[str.substring(0,2).to_int()] = $item[chrome ore];
				}
				else if(str.contains_text("linoleum ore"))
				{
					minedCells[str.substring(0,2).to_int()] = $item[linoleum ore];
				}
				else if(str.contains_text("loadstone"))
				{
					minedCells[str.substring(0,2).to_int()] = $item[loadstone];
				}
				else if(str.contains_text("lump of diamond"))
				{
					minedCells[str.substring(0,2).to_int()] = $item[lump of diamond];
				}
				else if(str.contains_text("meat stack"))
				{
					minedCells[str.substring(0,2).to_int()] = $item[meat stack];
				}
				else if(str.contains_text("stone of eXtreme power"))
				{
					minedCells[str.substring(0,2).to_int()] = $item[stone of eXtreme power];
				}
			}
		}
		return minedCells;
	}

	int[int] findSparklingCells(string minePage)
	{
		int[int] sparkles;
		matcher mrSparkle = create_matcher("title='Promising Chunk of Wall \\((\\d),(\\d)\\)", minePage);
		while (mrSparkle.find())
		{
			int sparkleCell = mrSparkle.group(1).to_int() + (mrSparkle.group(2).to_int() * 8);
			sparkles[sparkleCell] = 1; // don't actually care about the value. Just want the cells as keys so we can use contains
		}
		return sparkles;
	}

	int[4] getOrthogonals(int cell)
	{
		// starting at the cell above, going clockwise
		int[4] orthogonals; 
		orthogonals[0] = cell - 8;
		orthogonals[1] = cell + 1;
		orthogonals[2] = cell + 8;
		orthogonals[3] = cell - 1;
		return orthogonals;
	}

	boolean canMine(int cellToCheck, int rowLimit)
	{
		// this is basically bounds checking for cells
		// set rowLimit = 6 to not care about rows (there is no row 7)
		int column = cellToCheck % 8;
		if(column < 1 || column > 6 )
		{
			return false;
		}
		int row = cellToCheck / 8;
		if(row < 1 || row > 6 || row > rowLimit)
		{
			return false;
		}
		return true;
	}

	boolean isInSideColumn(int cellToCheck)
	{
		int column = cellToCheck % 8;
		if(column == 1 || column == 6)
		{
			return true;
		}
		return false;
	}

	// - Simplest case, a fresh mine cavern
	string mineLayout = visit_url("mining.php?mine=1");
	if(get_property("auto_minedCells") == "")
	{
		// pick a random column to start between 2-5
		return 50 + random(4); // using 50 as we're in row 6 to start and random returns from 0 to range-1. Hence 6 * 8 + 2
	}

	// - If we have started mining a cavern, lets continue mining the same column upwards until row 3
	string[int] previously_mined = split_string(get_property("auto_minedCells"), ",");
	int num_prev_mined = count(previously_mined);
	int lastCell = previously_mined[num_prev_mined - 1].to_int();
	if(num_prev_mined < 4 && (lastCell > 32 && lastCell < 55))
	{
		// mine the square directly above it
		return lastCell - 8;
	}

	// - If we've got to row 3 or above, start searching for ores.
	item[int] minedCells = parseMineLayout();
	int[int] oreSeen;
	foreach oreCell, oreType in minedCells
	{
		if(oreType == oreGoal)
		{
			oreSeen[oreCell] = 1; // value doesn't matter, just want to count and iterate the keys
		}
	}
	int[int] sparklingCells = findSparklingCells(mineLayout);
	int[int] potentialCells;
	int potentialCount = 0;
	if(count(oreSeen) == 0)
	{
		// - Not found any ore that we're looking for yet
		if(lastCell > 24 && lastCell < 31)
		{
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
		while (count(potentialCells) == 0 && rowLimit < 5)
		{
			foreach sparkleCell in sparklingCells
			{
				if(canMine(sparkleCell, rowLimit))
				{
					if(!isInSideColumn(sparkleCell) || !avoidSides)
					{
						potentialCells[potentialCount] = sparkleCell;
						potentialCount++;
					}
				}
			}
			rowLimit++;
			if(avoidSides && rowLimit == 5 && count(potentialCells) == 0)
			{
				avoidSides = false;
				rowLimit = 2;
			}
		}
	}
	else
	{
		// - Found at least one ore that we're looking for!
		// search orthogonally from the cells we found our required ore in as ore is always contiguous
		// limit our search to the top 3 rows to begin, if we don't find any cells that meet the criteria
		// increase the limit to the top 4 rows and check again.
		int rowLimit = 3;
		while (count(potentialCells) == 0 && rowLimit < 5)
		{
			foreach oreCell in oreSeen
			{
				int[4] orthogonals = getOrthogonals(oreCell);
				foreach _, orthoCell in orthogonals
				{
					if(canMine(orthoCell, rowLimit) && sparklingCells contains orthoCell)
					{
						potentialCells[potentialCount] = orthoCell;
						potentialCount++;
					}
				}
			}
			rowLimit++;
		}
		if(count(potentialCells) == 0)
		{
			// we could be in a situation where the loadstone replaced one of our ores and we still need 1 or 2 ores
			// but have exhausted all the twinkling cells adjacent to the ores we've found
			// first lets find the loadstone cell
			int loadstoneCell;
			foreach oreCell, oreType in minedCells
			{
				if(oreType == $item[loadstone])
				{
					loadstoneCell = oreCell;
				}
			}
			// now add all twinkling cells adjacent to the loadstone in the top 4 rows to the potential cells
			int[4] orthogonals = getOrthogonals(loadstoneCell);
			foreach _, orthoCell in orthogonals
			{
				if(canMine(orthoCell, 4) && sparklingCells contains orthoCell)
				{
					potentialCells[potentialCount] = orthoCell;
					potentialCount++;
				}
			}
		}
	}
	int numPotentials = count(potentialCells);
	// only found one potential, just return it
	if(numPotentials == 1)
	{
		return potentialCells[0];
	}
	else if(numPotentials == 0)
	{
		abort("Glitch in the matrix. Please report this to the dev team (preferably with a log and screenshot of your mine");
	}
	// found 2 or more potentials, return a random one of them
	return potentialCells[random(numPotentials)];
}

boolean L8_getGoatCheese()
{
	if(internalQuestStatus("questL08Trapper") != 1) // step1 = we spoke to trapper to unlock goatlet
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
	if(auto_haveGreyGoose() && item_amount($item[Goat Cheese]) >= 2){
		auto_log_info("Bringing the Grey Goose to emit some drones at a Dairy Goat for cheese, Gromit.");
		handleFamiliar($familiar[Grey Goose]);
	}
	if(canSniff($monster[Dairy Goat], $location[The Goatlet]) && auto_mapTheMonsters())
	{
		auto_log_info("Attemping to use Map the Monsters to olfact a Dairy Goat.");
	}
	auto_lostStomach(true);
	
	boolean retval = autoAdv($location[The Goatlet]);
	auto_sourceTerminalEducate($skill[Extract], $skill[Portscan]);
	return retval;
}

boolean L8_getMineOres()
{
	if(internalQuestStatus("questL08Trapper") != 1) // step1 = we spoke to trapper to learn what ores he wants
	{
		return false;
	}

	item oreGoal = get_property("trapperOre").to_item();

	if(item_amount(oreGoal) >= 3)
	{
		return false;
	}

	if(get_property("chateauMonster").to_monster() == $monster[Mountain Man])
	{
		// apparently this is a thing some people do. Lets add the most basic of support.
		return false;
	}

	// in softcore we want to pull an ore
	if(canPull(oreGoal))
	{
		pullXWhenHaveY(oreGoal, 1, item_amount(oreGoal));
		if(item_amount(oreGoal) == 3)
		{
			return true;// pulled successfully the last ore
		}
	}

	if(auto_haveTrainSet() && item_amount(oreGoal) < 3)
	{
		return false; //will get ore organically through the train set so no need to adventure for it
	}
	
	// use a summon if we can guarentee it will be enough via cat burglar
	if(canSummonMonster($monster[mountain man]) && catBurglarHeistsLeft() > 1)
	{
		auto_log_info("Trying to summon a mountain man, which the cat will then burgle, hopefully.");
		handleFamiliar($familiar[cat burglar]);
		return summonMonster($monster[mountain man]);
	}
	
	// try to clover for the ore
	if (autoLuckyAdv($location[Itznotyerzitz Mine]))
	{
		return true;
	}

	if(isAboutToPowerlevel())
	{
		if(!possessOutfit("Mining Gear"))
		{
			auto_log_info("Getting Mining Gear.", "blue");
			return autoAdv($location[Itznotyerzitz Mine]);
		}
		else if(possessOutfit("Mining Gear", true))
		{
			equipMaximizedGear();
			outfit("Mining Gear");
			acquireHP(1);
			auto_log_info("Mining in Itznotyerzitz Mine for Trapper ore", "blue");
			int cell = getCellToMine(oreGoal);
			if(cell != 0)
			{
				set_property("auto_minedCells", get_property("auto_minedCells") + cell.to_string() + ",");
				visit_url("mining.php?mine=1&which=" + cell.to_string() + "&pwd");
				return true;
			}
		}
	}
	
	return false;
}

void itznotyerzitzMineChoiceHandler(int choice)
{
	auto_log_info("itznotyerzitzMineChoiceHandler Running choice " + choice, "blue");
	if(choice == 18) // A Flat Miner
	{
		if(possessEquipment($item[miner\'s pants]))
		{
			if(possessEquipment($item[7-Foot Dwarven mattock]))
			{
				run_choice(3); // get 100 Meat.
			}
			else
			{
				run_choice(2); // get 7-Foot Dwarven mattock
			}
		}
		else
		{
			run_choice(1); // get miner's pants
		}
	}
	else if(choice == 19) // 100% Legal
	{	
		if(possessEquipment($item[miner\'s helmet]))
		{
			if(possessEquipment($item[miner\'s pants]))
			{
				run_choice(3); // get 100 Meat.
			}
			else
			{
				run_choice(2); // get miner's pants
			}
		}
		else
		{
			run_choice(1); // get miner's helmet
		}
	}
	else if(choice == 20) // See You Next Fall
	{
		if(possessEquipment($item[miner\'s helmet]))
		{
			if(possessEquipment($item[7-Foot Dwarven mattock]))
			{
				run_choice(3); // get 100 Meat.
			}
			else
			{
				run_choice(2); // get 7-Foot Dwarven mattock
			}
		}
		else
		{
			run_choice(1); // get miner's helmet
		}
	}
	else if(choice == 556) // More Locker Than Morlock
	{
		if(!possessOutfit("Mining Gear"))
		{
			run_choice(1); // get an outfit piece
		}
		else
		{
			run_choice(2); // skip
		}
	}
	else
	{
		abort("unhandled choice in itznotyerzitzMineChoiceHandler");
	}
}

boolean L8_trapperExtreme()
{
	if(internalQuestStatus("questL08Trapper") != 2)
	{
		return false;
	}
	if(L8_trapperPeak()) // try to unlock peak
	{
		return true; //successfully finished this part of the quest
	}
	
	// First choice is the MtLargeHuge IOTM equipment
	if(auto_haveMcHugeLargeSkis())
	{
		auto_equipAllMcHugeLarge();
	}
	// we should equip the extreme outfit if we have it
	else if(possessOutfit("eXtreme Cold-Weather Gear", true)) // own and can equip
	{
		autoOutfit("eXtreme Cold-Weather Gear");
	}
	else if(possessOutfit("eXtreme Cold-Weather Gear")) // just own. thanks to else can not equip
	{
		auto_log_warning("I can not wear the eXtreme Gear, I'm just not awesome enough :(", "red");
		return false;
	}
	
	// We don't need to force the first NC, it''s superlikely. The other two we can.
	int currentExtremity = get_property("currentExtremity").to_int();
	if (currentExtremity == 1 || currentExtremity == 2)
	{
		boolean NCForced = auto_forceNextNoncombat($location[The eXtreme Slope]);
		auto_log_info("Trying to force NC at extreme slope: "+NCForced.to_string(), "blue");
	}
	
	// try to get extreme points
	auto_log_info("Penguin Tony Hawk time. Extreme!! SSX Tricky!!", "blue");
	return autoAdv($location[The eXtreme Slope]);
}

void theeXtremeSlopeChoiceHandler(int choice)
{
	auto_log_info("theeXtremeSlopeChoiceHandler Running choice " + choice, "blue");
	if(choice == 15) // Yeti Nother Hippy
	{
		if(possessEquipment($item[eXtreme mittens]))
		{
			if(possessEquipment($item[eXtreme scarf]))
			{
				run_choice(3); // get 200 Meat.
			}
			else
			{
				run_choice(2); // get eXtreme scarf
			}
		}
		else
		{
			run_choice(1); // get eXtreme mittens
		}
	}
	else if(choice == 16) // Saint Beernard
	{
		if(possessEquipment($item[snowboarder pants]))
		{
			if(possessEquipment($item[eXtreme scarf]))
			{
				run_choice(3); // get 200 Meat.
			}
			else
			{
				run_choice(2); // get eXtreme scarf
			}
		}
		else
		{
			run_choice(1); // get snowboarder pants
		}
	}
	else if(choice == 17) // Generic Teen Comedy Snowboarding Adventure
	{
		if(possessEquipment($item[eXtreme mittens]))
		{
			if(possessEquipment($item[snowboarder pants]))
			{
				run_choice(3); // get 200 Meat.
			}
			else
			{
				run_choice(2); // get snowboarder pants
			}
		}
		else
		{
			run_choice(1); // get eXtreme mittens
		}
	}
	else if(choice == 575) // Duffel on the Double
	{
		if (have_equipped($item[Candy Cane Sword Cane]))
		{
			run_choice(5); // get mittens and pants and lucky pill
		}
		else if(!possessOutfit("eXtreme Cold-Weather Gear"))
		{
			run_choice(1); // get an outfit piece
		}
		else
		{
			if(isActuallyEd()) // add other paths which don't want to waste spleen (if any) here.
			{
				run_choice(3); // skip
			}
			else
			{
				run_choice(4); // Lucky Pill. (Clover for 1 spleen, worth?)
			}
		}
	}
	else
	{
		abort("unhandled choice in theeXtremeSlopeChoiceHandler");
	}
}

boolean L8_trapperNinjaLair()
{
	// adventure in the lair of the ninja snowmen to find and fight ninja snowman assassins.
	// usually this would only occur in hardcore
	if(internalQuestStatus("questL08Trapper") != 2)
	{
		return false;
	}
	if(L8_trapperPeak()) // try to unlock peak
	{
		return true; // successfully finished this part of the quest
	}
	if(get_property("auto_L8_extremeInstead").to_boolean()) // we want to do extreme path instead
	{
		return false;	
	}
	if(get_property("auto_L8_ninjaAssassinFail").to_boolean()) // we cannot survive against assassins
	{
		set_property("auto_L8_extremeInstead", true);
		return false;
	}
	// we must use two variables because there are too many special cases. maybe we can survive assassins but not encounter them due to +combat being too low. Copiers and pulls complicate matters. We could copy an assassin even if we cannot encounter it in the lair
	
	//check if we can survive a hit or get the jump on NSA
	if((my_maxhp() <= expected_damage($monster[ninja snowman assassin]) * 1.2) && jump_chance($monster[ninja snowman assassin]) < 100 )
	{
		if(isAboutToPowerlevel())
		{
			//if we can't survive and we are powerleveling, do extreme path
			set_property("auto_L8_ninjaAssassinFail", true);
			return true;
		}
		else
		{
			auto_log_warning("Can't survive against ninja snowman assassin. Will delay and try again later", "red"); 
			return false;
		}
	}

	if(have_effect($effect[Thrice-Cursed]) > 0 || have_effect($effect[Twice-Cursed]) > 0 || have_effect($effect[Once-Cursed]) > 0)
	{
		return false;
	}

	if(shenShouldDelayZone($location[Lair of the Ninja Snowmen]))
	{
		auto_log_debug("Delaying Lair of the Ninja Snowmen in case of Shen.");
		return false;
	}

	// can we provide enough combat bonus to encounter snowman assassins?
	if(providePlusCombat(auto_combatModCap(), $location[Lair of the Ninja Snowmen], true, true) <= 0.0) // ninja snowman does not show up if +combat is not greater than 0
	{
		if(isAboutToPowerlevel())
		{
			auto_log_info("Something is keeping us from getting a suitable combat rate for ninja snowman assassin. we can only reach: " + numeric_modifier("Combat Rate") + ". Switching to extreme slope route", "red");
			set_property("auto_L8_extremeInstead", true);
			return true;
		}
		else
		{
			auto_log_warning("Something is keeping us from getting a suitable combat rate for ninja snowman assassin. we can only reach: " + numeric_modifier("Combat Rate") + ". Will delay and try again later", "red");
		}
		return false;
	}
	
	// buff
	if(isActuallyEd() && !elementalPlanes_access($element[spooky]))
	{
		adjustEdHat("myst");
	}
	
	if(autoAdv($location[Lair of the Ninja Snowmen]))
	{
		return true;
	}
	auto_log_warning("Mysteriously failed to adventure in [Lair of the Ninja Snowmen]", "red");
	return false;
}

boolean L8_trapperGroar()
{
	// do the peak portion of L8 trapper quest.
	if(internalQuestStatus("questL08Trapper") < 3 || internalQuestStatus("questL08Trapper") > 4)
	{
		return false; // peak not yet unlocked or we are done with groar
	}
	if(get_property("_auto_skip_L8_trapperGroar").to_boolean())
	{
		auto_log_warning("Skipping L8_trapperGroar() today as per _auto_skip_L8_trapperGroar");
		return false;
	}
	
	// error catching for if we are actually on step5 and mafia did not notice.
	if(item_amount($item[Groar\'s Fur]) > 0 || item_amount($item[Winged Yeti Fur]) > 0 || item_amount($item[Cursed Blanket]) > 0)
	{
		auto_log_info("Quest tracking error detected. Mafia thinks we are in step4 of questL08Trapper but we are in fact in step5. Correcting. Current Path = " +my_path().name, "red");
		set_property("questL08Trapper", "step5");
		return true;
	}
	
	if(wildfire_groar_check())
	{
		return false;
	}
	if(is_professor())
	{
		return false; //don't try for Groar as Professor
	}
	
	// we need 5 cold res to be allowed to adventure in [Mist-shrouded Peak]
	int [element] resGoal;
	resGoal[$element[cold]] = 5;
	// try getting resistance without equipment before bothering to change gear
	
	boolean retval = false;
	int initial_adv = my_session_adv();
	if(provideResistances(resGoal, $location[Mist-shrouded Peak], false) || provideResistances(resGoal, $location[Mist-shrouded Peak], true))
	{
		auto_log_info("Time to take out Gargle, sure, Gargle (Groar)", "blue");
		equipMaximizedGear();
		//AoSOL buffs
		if(in_aosol())
		{
			buffMaintain($effect[Queso Fustulento], 10, 1, 10);
			buffMaintain($effect[Tricky Timpani], 30, 1, 10);
		}
		if($location[Mist-shrouded Peak].turns_spent >= 3)	//does not account for possible defeats
		{
			set_property("auto_nextEncounter","Groar");
		}
		else
		{
			set_property("auto_nextEncounter","panicking Knott Yeti");
		}
		set_property("auto_nonAdvLoc", true);
		retval = autoAdv($location[Mist-shrouded Peak]);
	}
	if(retval && initial_adv == my_session_adv())
	{
		//several inf loops can occur here
		auto_log_debug("Adventured without spending an adv in [Mist-shrouded Peak]. Checking for problems", "blue");
		
		int initial_step = internalQuestStatus("questL08Trapper");
		string initial_s = get_property("questL08Trapper");
		cli_execute("refresh quests");
		int current_step = internalQuestStatus("questL08Trapper");
		string current_s = get_property("questL08Trapper");
		boolean track_error = initial_step != current_step;
		
		if(track_error)		//quest tracking was wrong and fixed.
		{
			if(current_step > 4)	//boss is actually dead now
			{
				// if boss is dead [Mist-shrouded Peak] becomes [The Icy Peak].
				// common tracking issue which casue inf loop. already fixed by the quest refresh.
				auto_log_warning("questL08Trapper value was incorrect. Boss is already dead. This has been fixed to prevent inf loop", "blue");
			}
			else auto_log_warning("questL08Trapper value was incorrect. This has been fixed", "blue");
		}
		else auto_log_debug("questL08Trapper value was correct despite oddity with adv spent");

		if(current_step == 3 || current_step == 4)
		{
			// boss is still alive yet no adv was spent. most likely scenario is that our cold res was too low. maybe free combat?
			if(get_property("_auto_inf_counter").to_int() > 5)
			{
				print("We are stuck trying to adventure in [Mist-shrouded Peak] and failing repeatedly","red");
				print("Probably a problem with cold res. Please report this issue.","red");
				print("Finish the peak yourself then run autoscend again","red");
				print("If you wish to have autoscend ignore this and go do other stuff then enter in gCLI:","red");
				print("set _auto_skip_L8_trapperGroar = true","red");
				abort();
			}
		}
	}
	return retval;
}

boolean L8_trapperPeak()
{
	// unlock the peak in the trapper quest
	if(internalQuestStatus("questL08Trapper") != 2)
	{
		return false;
	}
	
	// unlock peak using ninja climbing gear
	if(item_amount($item[Ninja Rope]) > 0 && item_amount($item[Ninja Carabiner]) > 0 && item_amount($item[Ninja Crampons]) > 0)
	{
		int [element] resGoal;
		resGoal[$element[cold]] = 5;
		if(provideResistances(resGoal, $location[Mist-shrouded Peak], true))
		{
			equipMaximizedGear();
			visit_url("place.php?whichplace=mclargehuge&action=cloudypeak"); // unlock peak. advancing to step 4.
			set_property("auto_ninjasnowmanassassin", true); // heavy rains. are we done copying them
		}
		else
		{
			// TODO get outfit
			// TODO does TCRS have a problem with the outfit still not being enough? look into it
			return false; // we are unable to provide 5 cold res
		}
		
		if(internalQuestStatus("questL08Trapper") == 3)
		{
			return true; // successfully unlocked peak
		}
		else
		{
			abort("Mysteriously failed to climb the slope using ninja climbing gear");
		}
	}
	
	// unlock peak using extremeness
	if(get_property("currentExtremity").to_int() >= 3)
	{
		if (auto_haveMcHugeLargeSkis())
		{
			equip($slot[back]    , $item[McHugeLarge duffel bag]);
			equip($slot[weapon]  , $item[McHugeLarge right pole]);
			equip($slot[off-hand], $item[McHugeLarge left pole]);
			equip($slot[acc1]    , $item[McHugeLarge left ski]);
			equip($slot[acc2]    , $item[McHugeLarge right ski]);
			visit_url("place.php?whichplace=mclargehuge&action=cloudypeak");
			return true;
		}
		// TODO: There are some reports of this breaking in TCRS, when cold-weather
		// gear is not sufficient to have 5 cold resistance. Use a maximizer statement?
		if(outfit("eXtreme Cold-Weather Gear"))
		{
			visit_url("place.php?whichplace=mclargehuge&action=cloudypeak");
			return true;
		}
	}
	
	return false;
}

boolean L8_forceExtremeInstead()
{
	// If for some reason we've already got 2 ninja items, no need to get forcey
	if(available_amount($item[ninja crampons]) > 0) { return false; }
	// Set the variable if we're doing McHugeLarge items
	if (auto_canEquipAllMcHugeLarge()) { set_property("auto_L8_extremeInstead", true); }
	return get_property("auto_L8_extremeInstead").to_boolean();
}

boolean L8_trapperSlope()
{
	// climb the slope and reach the peak in L8 trapper quest. either via ninja snowmen lair or via the extreme slope
	
	if(internalQuestStatus("questL08Trapper") != 2)
	{
		return false; // climbing the slope is step2 of the quest. when you unlock the peak it advances to step3
	}
	if(can_interact()) // casual and postronin special handling
	{
		return L8_slopeCasual(); // mallbuy everything. or go do something else if too poor to do so
	}
	if(L8_trapperPeak()) // try to finish step2 of the quest.
	{
		return true;
	}
	// hardcore handling
	if(robot_delay("outfit"))
	{
		return false; // delay for You, Robot path
	}
	// Checks for McHugeLarge skis
	if (L8_forceExtremeInstead())
	{
		if(L8_trapperExtreme()) return true; // try to climb slope via extreme path
	}
	if(get_property("auto_L8_extremeInstead").to_boolean()) // we decided we do not want to adventure in the ninja lair
	{
		if(L8_trapperExtreme()) return true; // try to climb slope via extreme path
	}
	if(L8_trapperNinjaLair()) return true; // try to climb slope via ninja path
	
	return false;
}

boolean L8_trapperTalk()
{
	// talk to the trapper to advance the L8 quest.
	int initial_step = internalQuestStatus("questL08Trapper");
	if(initial_step != 0 && initial_step != 1 && initial_step != 5)
	{
		return false; // only need to talk to trapper at steps 0, 1, and 5
	}

	if(initial_step == 0) // step0 == quest started. we do not know what ores we need yet.
	{
		auto_log_info("Talkint to the trapper to find out what kind of Ore he wants", "blue");
		visit_url("place.php?whichplace=mclargehuge&action=trappercabin"); // talk to the trapper to advance quest
	}
	if(initial_step == 1) // step1 == we know what ore to get. so go get ore and cheese
	{
		if(item_amount(get_property("trapperOre").to_item()) >= 3 && item_amount($item[Goat Cheese]) >= 3)
		{
			// turn in ore and cheese to advance from step1 to step2
			auto_log_info("Giving Trapper goat cheese and " + get_property("trapperOre").to_item(), "blue");
			visit_url("place.php?whichplace=mclargehuge&action=trappercabin"); // talk to the trapper to advance quest
		}
		else
		{
			return false; // not enough cheese or ore yet. go get them
		}
	}
	if(initial_step == 5)
	{
		// finish the quest
		visit_url("place.php?whichplace=mclargehuge&action=trappercabin");
		council();
	}
	
	// error checking
	if(initial_step == internalQuestStatus("questL08Trapper")) // we failed to advance. try refreshing quests
	{
		auto_log_info("we visited trapper but failed to advance the quest from step" +initial_step+ ". Refreshing quests", "red");
		cli_execute("refresh quests");
	}
	if(initial_step == internalQuestStatus("questL08Trapper")) // refreshing quests did not solve the problem
	{
		abort("We were unable to advance the quest when talking to the trapper for some reason");
	}
	return true;
}

boolean L8_trapperQuest()
{
	// do the entire L8 trapper quest
	if(internalQuestStatus("questL08Trapper") < 0 || internalQuestStatus("questL08Trapper") > 5)
	{
		return false;
	}

	if(L8_trapperTalk())
	{
		return true;
	}

	//at end of day last chance to get milk could be more valuable for characters with a stomach than not cancelling banishes used in L7
	if(my_adventures() < 7 && !get_property("_milkOfMagnesiumUsed").to_boolean() && fullness_limit() != 0 && have_skill($skill[Advanced Saucecrafting]) && 
	L8_getGoatCheese())
	{
		return true;
	}
	else if(L7_override())	//if any olfaction or banishes used in an earlier area finish there first
	{
		return true;
	}

	if(L8_getGoatCheese() || L8_getMineOres() || L8_trapperSlope() || L8_trapperGroar())
	{
		return true;
	}
	return false;
}
