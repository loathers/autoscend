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
		case 89: // Out in the Garden (The Haunted Gallery)
			if (isActuallyEd() && (!possessEquipment($item[serpentine sword]) || !possessEquipment($item[snake shield]))) {
				run_choice(2); // fight the snake knight (should non-Ed classes/paths do this too?)
			} else {
				run_choice(4); // ignore the NC & banish it for 10 adv
			}
			break;
		case 90: // Curtains (The Haunted Ballroom)
			run_choice(3); // skip;
			break;
		case 105: // Having a Medicine Ball (The Haunted Bathroom)
			if (my_primestat() == $stat[Mysticality]) {
				run_choice(1); // get mysticality substats
			} else {
				run_choice(2); // go to Bad Medicine is What You Need (#107)
			}
			break;
		case 106: // Strung-Up Quartet (The Haunted Ballroom)
			run_choice(3); // +5% item drops everywhere
			break;
		case 107: // Bad Medicine is What You Need (The Haunted Bathroom)
			run_choice(4); // skip
			break;
		case 163: // Melvil Dewey Would Be Ashamed (The Haunted Library)
			run_choice(4); // skip
			break;
		case 502: // Arboreal Respite (The Spooky Forest)
			if (internalQuestStatus("questL02Larva") == 0 && item_amount($item[mosquito larva]) == 0) {
				// need the mosquito larva
				run_choice(2); // go to Consciousness of a Stream (#505)
			} else if (!hidden_temple_unlocked()) {
				if (item_amount($item[Tree-Holed Coin]) == 0 && item_amount($item[Spooky Temple map]) == 0) {
					// need the tree-holed coin
					run_choice(2); // go to Consciousness of a Stream (#505)
				} else if (item_amount($item[Spooky Temple map]) == 0 || item_amount($item[Spooky-Gro Fertilizer]) == 0) {
					// have the coin, need the spooky temple map and spooky-gro fertilizer
					run_choice(3); // go to Through Thicket and Thinnet (#506)
				} else {
					// need the spooky sapling
					run_choice(1); // go to The Road Less Traveled (#503)
				}
			} else {
				auto_log_warning("In Arboreal Respite for some reason but we don't need a mosquito larva or to unlock the hidden temple!");
				run_choice(2); // go to Consciousness of a Stream (#505)
			}
			break;
		case 503: // The Road Less Traveled (The Spooky Forest)
			run_choice(3); // go to Tree's Last Stand (#504)
			break;
		case 504: // Tree's Last Stand (The Spooky Forest)
			if (item_amount($item[bar skin]) > 1) {
				run_choice(2); // sell all bar skins (doesn't leave choice)
			} else if (item_amount($item[bar skin]) == 1) {
				run_choice(1); // sell all bar skins (doesn't leave choice)
			}
			if (!hidden_temple_unlocked() && item_amount($item[Spooky Sapling]) == 0 && my_meat() > 100) {
				run_choice(3); // get the spooky sapling (doesn't leave choice)
			}
			run_choice(4); // leave the choice (skip).
			break;
		case 505: // Consciousness of a Stream (The Spooky Forest)
			if (internalQuestStatus("questL02Larva") == 0 && item_amount($item[mosquito larva]) == 0) {
				run_choice(1); // Get the mosquito larva
			} else {
				run_choice(2); // Get the tree-holed coin or skip
			}
			break;
		case 506: // Through Thicket and Thinnet (The Spooky Forest)
			if (!hidden_temple_unlocked() && item_amount($item[Spooky-Gro Fertilizer]) == 0) {
				run_choice(2); // get the spooky-gro fertilizer
			} else {
				run_choice(3); // go to O Lith, Mon (#507)
			}
			break;
		case 507: // O Lith, Mon (The Spooky Forest)
			if (!hidden_temple_unlocked() && item_amount($item[Tree-Holed Coin]) > 0 && item_amount($item[Spooky Temple map]) == 0) {
				run_choice(1); // get the spooky temple map
			} else {
				run_choice(3); // skip
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
		case 780: // Action Elevator (The Hidden Apartment Building)
			if (auto_my_path() == "Pocket Familiars" && get_property("relocatePygmyLawyer").to_int() != my_ascensions()) {
				run_choice(3); // relocate lawyers to park
			} else if (have_effect($effect[Thrice-Cursed]) > 0) {
				run_choice(1); // fight the spirit
			} else {
				run_choice(2); // get cursed
			}
			break;
		case 781: // Earthbound and Down (An Overgrown Shrine (Northwest))
			if (get_property("hiddenApartmentProgress").to_int() == 0) {
				run_choice(1); // unlock the Hidden Apartment Building
			} else if (item_amount($item[moss-covered stone sphere]) > 0) {
				run_choice(2); // get the stone triangle
			} else {
				run_choice(6); // skip
			}
			break;
		case 783: // Water You Dune (An Overgrown Shrine (Southwest))
			if (get_property("hiddenHospitalProgress").to_int() == 0) {
				run_choice(1); // unlock the Hidden Hospital
			} else if (item_amount($item[dripping stone sphere]) > 0) {
				run_choice(2); // get the stone triangle
			} else {
				run_choice(6); // skip
			}
			break;
		case 784: // You, M. D. (The Hidden Hospital)
			run_choice(1); // fight the spirit
			break;
		case 785: // Air Apparent (An Overgrown Shrine (Northeast))
			if (get_property("hiddenOfficeProgress").to_int() == 0) {
				run_choice(1); // unlock the Hidden Office Building
			} else if (item_amount($item[crackling stone sphere]) > 0) {
				run_choice(2); // get the stone triangle
			} else {
				run_choice(6); // skip
			}
			break;
		case 786: // Working Holiday (The Hidden Office Building)
			if (item_amount($item[McClusky File (Complete)]) > 0) {
				run_choice(1); // fight the spirit
			} else if (item_amount($item[Boring Binder Clip]) == 0) {
				run_choice(2); // get boring binder clip
			} else {
				run_choice(3); // fight an accountant
			}
			break;
		case 787: // Fire When Ready (An Overgrown Shrine (Southeast))
			if (get_property("hiddenBowlingAlleyProgress").to_int() == 0) {
				run_choice(1); // unlock the Hidden Bowling Alley
			} else if (item_amount($item[scorched stone sphere]) > 0) {
				run_choice(2); // get the stone triangle
			} else {
				run_choice(6); // skip
			}
			break;
		case 788: // Life is Like a Cherry of Bowls (The Hidden Bowling Alley)
			run_choice(1); // bowl for stats 4 times then fight the spirit on 5th occurrence
			break;
		case 789: // Where Does The Lone Ranger Take His Garbagester? (The Hidden Park)
			if (get_property("relocatePygmyJanitor").to_int() != my_ascensions()) {
				run_choice(2); // Relocate the Pygmy Janitor to the park
			} else {
				run_choice(1); // Get Hidden City zone items
			}
			break;
		case 791: // Legend of the Temple in the Hidden City (A Massive Ziggurat)
			if (item_amount($item[stone triangle]) == 4) {
				run_choice(1); // fight the Protector Spirit (or replacement)
			} else {
				run_choice(2); // skip
			}
			break;
		case 875: // Welcome To Our ool Table (The Haunted Billiards Room)
			if (currentPoolSkill() >= 18) {
				run_choice(1);
			} else {
				run_choice(2);
			}
			break;
		case 876: // One Simple Nightstand (The Haunted Bedroom)
			run_choice(2); // get muscle substats
			break;
		case 877: // One Mahogany Nightstand (The Haunted Bedroom)
			run_choice(1); // get half of a memo or old coin purse
			break;
		case 878: // One Ornate Nightstand (The Haunted Bedroom)
			boolean needSpectacles = (item_amount($item[Lord Spookyraven\'s Spectacles]) == 0 && internalQuestStatus("questL11Manor") < 2);
			if (in_boris() || auto_my_path() == "Way of the Surprising Fist" || (auto_my_path() == "Nuclear Autumn" && in_hardcore())) {
				needSpectacles = false;
			}
			if (needSpectacles) {
				run_choice(3); // get Lord Spookyraven's spectacles
			} else if (item_amount($item[disposable instant camera]) == 0 && internalQuestStatus("questL11Palindome") < 1) {
				run_choice(4); // get disposable instant camera
			} else {
				run_choice(2); // get mysticality substats
			}
			break;
		case 879: // One Rustic Nightstand (The Haunted Bedroom)
			run_choice(1); // get moxie substats
			break;
		case 880: // One Elegant Nightstand (The Haunted Bedroom)
			if (internalQuestStatus("questM21Dance") < 2 && item_amount($item[Lady Spookyraven\'s Finest Gown]) == 0) {
				run_choice(1); // get Lady Spookyraven's Gown
			} else {
				run_choice(2); // get elegant nightstick
			}
			break;
		case 881: // Never Gonna Make You Up (The Haunted Bathroom)
			run_choice(1); // fight the cosmetics wraith
			break;
		case 882: // Off the Rack (The Haunted Bathroom)
			run_choice(1); // take the towel
			break;
		case 888: // Take a Look, it's in a Book! (Rise) (The Haunted Library)
			run_choice(4); // skip
			break;
		case 889: // Take a Look, it's in a Book! (Fall) (The Haunted Library)
			if (item_amount($item[dictionary]) == 0 && get_property("auto_getDictionary").to_boolean()) {
				run_choice(4); // get the dictionary
			} else {
				run_choice(5); // skip
			}
			break;
		case 921: // We'll All Be Flat (The Haunted Ballroom)
			run_choice(1); // unlock Spookyraven Manor Cellar 
			break;
		case 923: // All Over the Map (The Black Forest)
			run_choice(1); // go to You Found Your Thrill (#924)
			break;
		case 924: // You Found Your Thrill (The Black Forest)
			if(get_property("auto_getBeehive").to_boolean() && my_adventures() > 3) {
				run_choice(3); // go to Bee Persistent (#1018)
			} else if (!possessEquipment($item[Blackberry Galoshes]) && item_amount($item[Blackberry]) >= 3 && my_class() != $class[Vampyre]) {
				run_choice(2); // go to The Blackberry Cobbler (#928)
			} else {
				run_choice(1); // Attack the bushes (fight blackberry bush)
			}
			break;
		case 928: // You Found Your Thrill (The Black Forest)
			if (!possessEquipment($item[Blackberry Galoshes]) && item_amount($item[Blackberry]) >= 3 && my_class() != $class[Vampyre]) {
				run_choice(4); // get Blackberry Galoshes
			} else {
				run_choice(5); // skip
			}
			break;
		case 1002: // Temple of the Legend in the Hidden City (A Massive Ziggurat/Actually Ed the Undying)
			if (item_amount($item[stone triangle]) == 4) {
				run_choice(1); // Put the Ancient Amulet back
			} else {
				run_choice(2); // skip
			}
			break;
		case 1018: // Bee Persistent (The Black Forest)
			if (get_property("auto_getBeehive").to_boolean() && my_adventures() > 2) {
				run_choice(1); // go to Bee Rewarded (#1019)
			} else {
				run_choice(2); // skip
			}
			break;
		case 1019: // Bee Rewarded (The Black Forest)
			if (get_property("auto_getBeehive").to_boolean()) {
				run_choice(1); // get the beehive
			} else {
				run_choice(2); // skip
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
		case 1414: // Lock Picking
			if(item_amount($item[Boris\'s Key]) == 0)
			{
				run_choice(1);
			}
			else if(item_amount($item[Jarlsberg\'s Key]) == 0)
			{
				run_choice(2);
			}
			else if(item_amount($item[Sneaky Pete\'s Key]) == 0)
			{
				run_choice(3);
			}
		default:
			break;
	}
}