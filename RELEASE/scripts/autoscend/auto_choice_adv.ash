script "auto_choice_adv.ash";
import<autoscend.ash>

void main(int choice, string page)
{
	auto_log_debug("Running auto_choice_adv.ash");
	
	switch (choice) {
		case 15: // Yeti Nother Hippy (The eXtreme Slope)
			if (possessEquipment($item[eXtreme mittens])) {
				if (possessEquipment($item[eXtreme scarf])) {
					run_choice(3); // get 200 Meat.
				} else {
					run_choice(2); // get eXtreme scarf
				}
			} else {
				run_choice(1); // get eXtreme mittens
			}
			break;
		case 16: // Saint Beernard (The eXtreme Slope)
			if (possessEquipment($item[snowboarder pants])) {
				if (possessEquipment($item[eXtreme scarf])) {
					run_choice(3); // get 200 Meat.
				} else {
					run_choice(2); // get eXtreme scarf
				}
			} else {
				run_choice(1); // get snowboarder pants
			}
			break;
		case 17: // Generic Teen Comedy Snowboarding Adventure (The eXtreme Slope)
			if (possessEquipment($item[eXtreme mittens])) {
				if (possessEquipment($item[snowboarder pants])) {
					run_choice(3); // get 200 Meat.
				} else {
					run_choice(2); // get snowboarder pants
				}
			} else {
				run_choice(1); // get eXtreme mittens
			}
			break;
		case 18: // A Flat Miner (Itznotyerzitz Mine)
			if (possessEquipment($item[miner\'s pants])) {
				if (possessEquipment($item[7-Foot Dwarven mattock])) {
					run_choice(3); // get 100 Meat.
				} else {
					run_choice(2); // get 7-Foot Dwarven mattock
				}
			} else {
				run_choice(1); // get miner's pants
			}
			break;
		case 19: // 100% Legal (Itznotyerzitz Mine)
			if (possessEquipment($item[miner\'s helmet])) {
				if (possessEquipment($item[miner\'s pants])) {
					run_choice(3); // get 100 Meat.
				} else {
					run_choice(2); // get miner's pants
				}
			} else {
				run_choice(1); // get miner's helmet
			}
			break;
		case 20: // See You Next Fall (Itznotyerzitz Mine)
			if (possessEquipment($item[miner\'s helmet])) {
				if (possessEquipment($item[7-Foot Dwarven mattock])) {
					run_choice(3); // get 100 Meat.
				} else {
					run_choice(2); // get 7-Foot Dwarven mattock
				}
			} else {
				run_choice(1); // get miner's helmet
			}
			break;
		case 556: // More Locker Than Morlock (Itznotyerzitz Mine)
			if (!possessOutfit("Mining Gear")) {
				run_choice(1); // get an outfit piece
			} else {
				run_choice(2); // skip
			}
			break;
		case 575: // Duffel on the Double (The eXtreme Slope)
			if (!possessOutfit("eXtreme Cold-Weather Gear")) {
				run_choice(1); // get an outfit piece
			} else {
				if (isActuallyEd()) { // add other paths which don't want to waste spleen (if any) here.
					run_choice(3); // skip
				} else {
					run_choice(4); // Lucky Pill. (Clover for 1 spleen, worth?)
				}
			}
			break;
		case 1023: // Like a Bat Into Hell (Actually Ed the Undying)
			run_choice(1); // Enter the Underworld
			auto_log_info("Ed died in combat " + get_property("_edDefeats").to_int() + " time(s)", "blue");
			ed_shopping(); // "free" trip to the Underworld, may as well go shopping!
			visit_url("place.php?whichplace=edunder&action=edunder_leave");
			break;
		case 1024:  // Like a Bat out of Hell (Actually Ed the Undying)
			if (get_property("_edDefeats").to_int() < get_property("edDefeatAbort").to_int()) {
				// resurrecting is still free.
				run_choice(1, false); // UNDYING!
			} else {
				// resurrecting will cost Ka
				run_choice(2); // Accept the cold embrace of death (Return to the Pyramid)
				auto_log_info("Ed died in combat for reals!");
				set_property("auto_beatenUpCount", get_property("auto_beatenUpCount").to_int() + 1);
			}
			break;
		case 1061: // Heart of Madness(Madness Bakery Quest)
			if(internalQuestStatus("questM25Armorer") <= 1) {
				run_choice(1);
			} else {
				run_choice(5);
			}
			break;
		case 1082: // The "Rescue" (post-Cake Lord in Madness Bakery)
			run_choice(1);
			break;
		case 1083: // Cogito Ergot Sum (post-post-Cake Lord in Madness Bakery)
			run_choice(1);
			break;
		case 1310: // Granted a Boon (God Lobster)
			int goal = get_property("_auto_lobsterChoice").to_int();
			string search = "I'd like part of your regalia.";
			if(goal == 2)
			{
				search = "I'd like a blessing.";
			}
			else if(goal == 3)
			{
				search = "I'd like some experience.";
			}

			int choice = 0;
			foreach idx, str in available_choice_options()
			{
				if(contains_text(str,search))
				{
					choice = idx;
				}
			}
			run_choice(choice);
			break;
		case 1340: // Is There A Doctor In The House? (Lil' Doctor Bag™)
			auto_log_info("Accepting doctor quest, it's our job!");
			run_choice(1);
			break;
		case 1342: // Torpor (Dark Gyffte)
			bat_reallyPickSkills(20);
			break;
		case 1387: // Using the Force (Fourth of May Cosplay Saber)
			run_choice(get_property("_auto_saberChoice").to_int());
			break;
		default:
			break;
	}
}