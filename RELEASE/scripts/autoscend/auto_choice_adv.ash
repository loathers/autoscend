import<autoscend.ash>

boolean auto_run_choice(int choice, string page)
{
	auto_log_debug("Running auto_choice_adv.ash");
	string[int] options = available_choice_options();
	
	switch (choice){
		case 15: // Yeti Nother Hippy (The eXtreme Slope)
		case 16: // Saint Beernard (The eXtreme Slope)
		case 17: // Generic Teen Comedy Snowboarding Adventure (The eXtreme Slope)
			theeXtremeSlopeChoiceHandler(choice);
			break;
		case 18: // A Flat Miner (Itznotyerzitz Mine)
		case 19: // 100% Legal (Itznotyerzitz Mine)
		case 20: // See You Next Fall (Itznotyerzitz Mine)
			itznotyerzitzMineChoiceHandler(choice);
			break;
		case 22: // The Arrrbitrator (The Obligatory Pirate's Cove)
		case 23: // Barrie Me at Sea (The Obligatory Pirate's Cove)
		case 24: // Amatearrr Night (The Obligatory Pirate's Cove)
			piratesCoveChoiceHandler(choice);
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
		case 123: // At Least It's Not Full Of Trash (The Hidden Temple)
		case 125: // No Visible Means of Support (The Hidden Temple)
			hiddenTempleChoiceHandler(choice, page);
			break;
		case 139: // Bait and Switch (The Hippy Camp (Verge of War))
		case 140: // The Thin Tie-Dyed Line (The Hippy Camp (Verge of War))
		case 141: // Blockin' Out the Scenery (The Hippy Camp (Verge of War) wearing Frat Boy Ensemble) 
		case 142: // Blockin' Out the Scenery (The Hippy Camp (Verge of War) wearing Frat Warrior Fatigues)
		case 143: // Catching Some Zetas (Orcish Frat House (Verge of War))
		case 144: // One Less Room Than In That Movie (Orcish Frat House (Verge of War))
		case 145: // Fratacombs (Orcish Frat House (Verge of War) wearing Filthy Hippy Disguise) 
		case 146: // Fratacombs (Orcish Frat House (Verge of War) wearing War Hippy Fatigues)
		case 147: // Cornered! (McMillicancuddy's Barn)
		case 148: // Cornered Again! (McMillicancuddy's Barn)
		case 149: // How Many Corners Does this Stupid Barn Have!? (McMillicancuddy's Barn)
			warChoiceHandler(choice);
			break;
		case 163: // Melvil Dewey Would Be Ashamed (The Haunted Library)
			if(in_lar())
			{
				set_property("_LAR_skipNC163", my_turncount());	//NC in LAR path forced to reoccur if we skip it. Go do something else.
			}
			run_choice(4); // skip
			break;
		case 178: // Hammering the Armory (The Penultimate Fantasy Airship)
			if(in_lar())
			{
				set_property("_LAR_skipNC178", my_turncount());	//NC in LAR path forced to reoccur if we skip it. Go do something else.
			}
			run_choice(2); // skip
			break;
		case 182: // Random Lack of an Encounter (The Penultimate Fantasy Airship)
			if(item_amount($item[model airship]) == 0)
			{
				run_choice(4); // get the model airship
			}
			else
			{
				run_choice(1); // fight an opponent
			}
			break;
		case 184: // That Explains All The Eyepatches (Barrrney's Barrr)
		case 185: // Yes, You're a Rock Starrr (Barrrney's Barrr)
		case 186: // A Test of Testarrrsterone (Barrrney's Barrr)
			barrrneysBarrrChoiceHandler(choice);
			break;
			// Note: 187 is the Beer Pong NC and is currently handled differently.
		case 188: // The Infiltrationist (Orcish Frat House blueprints)
			if (is_wearing_outfit("Frat Boy Ensemble")) {
				run_choice(1);
			} else if (equipped_amount($item[mullet wig]) == 1 && item_amount($item[briefcase]) > 0) {
				run_choice(2);
			} else if (equipped_amount($item[frilly skirt]) == 1 && item_amount($item[hot wing]) > 2) {
				run_choice(3);
			} else abort("I tried to infiltrate the orcish frat house without being equipped for the job");
			break;
		case 189: // O Cap'm, My Cap'm (The Poop Deck)
			run_choice(2); // skip
			break;
		case 191: // Chatterboxing (The F'c'le)
			fcleChoiceHandler(choice);
			break;
		case 330: // A Shark's Chum (The Haunted Billiards Room, semi-rarely)
			if (get_property("poolSharkCount").to_int() < 25) {
				run_choice(1); // train pool skill
			} else {
				run_choice(2); // fight hustled spectre for cube of billiard chalk
			}
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
		case 523: // Death Rattlin' (The Cyrpt)
			if(in_darkGyffte()) // ADD BACK IN PILLS
			{
				run_choice(5); // skip adventure to farm more dieting pills in DG
			}
			else
			{
				run_choice(4); // fight swarm of ghuol whelps
			}
			break;
		case 527: // The Haert of Darkness (The Cyrpt)
			run_choice(1); // fight whichever version of the bonerdagon
			break;
		case 556: // More Locker Than Morlock (Itznotyerzitz Mine)
			itznotyerzitzMineChoiceHandler(choice);
			break;
		case 575: // Duffel on the Double (The eXtreme Slope)
			theeXtremeSlopeChoiceHandler(choice);
			break;
		case 579: // Such Great Heights (The Hidden Temple)
		case 580: // The Hidden Heart of the Hidden Temple (The Hidden Temple)
		case 581: // Such Great Depths (The Hidden Temple)
		case 582: // Fitting In (The Hidden Temple)
		case 583: // Confusing Buttons (The Hidden Temple)
		case 584: // Unconfusing Buttons (The Hidden Temple)
			hiddenTempleChoiceHandler(choice, page);
			break;
		case 597: // When visiting the Cake-Shaped Arena with a Reagnimated Gnome
			auto_reagnimatedGetPart(choice);
			break;
		case 669: // The Fast and the Furry-ous (The Castle in the Clouds in the Sky (Basement))
			if(possessEquipment($item[Titanium Assault Umbrella]) && can_equip($item[Titanium Assault Umbrella]))
			{
				run_choice(4); // if have and can equip umbrella, come back to this choice after equipping
			}
			else
			{
				run_choice(1); // in any other cases, go to Out in the Open Source 
			}
			break;
		case 670: // You Don't Mess Around with Gym (The Castle in the Clouds in the Sky (Basement))
			if(possessEquipment($item[Amulet of Extreme Plot Significance]) && can_equip($item[Amulet of Extreme Plot Significance]))
			{
				run_choice(5); // if have and can equip amulet, come back to this choice after equipping
			}
			else if(internalQuestStatus("questL10Garbage") < 8 && equipped_amount($item[Amulet of Extreme Plot Significance]) == 1)
			{
				run_choice(4); // with amulet equipped, open the ground floor
			}
			else
			{
				run_choice(1); // with no amulet, grab the dumbbell. will skip adventure if already have dumbbell
			}
			break;
		case 671: // Out in the Open Source (The Castle in the Clouds in the Sky (Basement))
			if(item_amount($item[Massive Dumbbell]) > 0)
			{
				run_choice(1); // with dumbbell, open the ground floor
			}
			else
			{
				run_choice(4); // without dumbbell, go to You Don't Mess Around with Gym
			}
			break;
		case 672: // There's No Ability Like Possibility (Castle in the Clouds in the Sky (Ground Floor))
			run_choice(3); // skip adventure
			break;
		case 673: // Putting Off Is Off-Putting (Castle in the Clouds in the Sky (Ground Floor))
			run_choice(1); // get very overdue library book then skip adventure
			break;
		case 674: // Huzzah! (Castle in the Clouds in the Sky (Ground Floor))
			run_choice(3); // skip adventure
			break;
		case 675: // Melon Collie and the Infinite Lameness (The Castle in the Clouds in the Sky (Top Floor))
			if(internalQuestStatus("questL10Garbage") < 10 && item_amount($item[Drum \'n\' Bass \'n\' Drum \'n\' Bass Record]) > 0)
			{
				run_choice(2); // if quest not done and have the record, complete the quest
			}
			else
			{
				run_choice(4); // moves to Copper Feel in all other scenarios
			}
			break;
		case 676: // Flavor of a Raver (The Castle in the Clouds in the Sky (Top Floor))
			if(internalQuestStatus("questL10Garbage") < 10 && possessEquipment($item[mohawk wig]))
			{
				run_choice(4); // if quest not done and have mohawk wig, move to Yeah, You're for Me, Punk Rock Giant
			}	
			else
			{
				run_choice(3); // if no mohawk wig, grab the drum n bass record. will skip adventure if already have record
			}
			break;
		case 677: // Copper Feel (The Castle in the Clouds in the Sky (Top Floor))
			if(internalQuestStatus("questL10Garbage") < 10 && item_amount($item[model airship]) > 0)
			{
				run_choice(1); // if quest not done and have model airship, complete quest
			}
			else if(internalQuestStatus("questL10Garbage") < 10 && item_amount($item[Drum \'n\' Bass \'n\' Drum \'n\' Bass Record]) > 0)
			{
				run_choice(4); // if quest not done and have the record, move to Copper Feel
			}
			else
			{
				run_choice(2); // grab steam-powered rocket ship.  will skip adventure if already have rocket
			}
			break;
		case 678: // Yeah, You're for Me, Punk Rock Giant (The Castle in the Clouds in the Sky (Top Floor))
			if(internalQuestStatus("questL10Garbage") < 10 && equipped_amount($item[mohawk wig]) == 1)
			{
				run_choice(1); // if quest not done and mohawk wig equipped, finish quest
			}
			else if(internalQuestStatus("questL10Garbage") < 10)
			{
				run_choice(4); // if wig not equipped and quest not done, go to Flavor of a Raver 
			}
			else
			{
				run_choice(3); // if quest is done, go to Copper Feel to guarantee skip adventure
			}
			break;
		case 679: // Keep On Turnin' the Wheel in the Sky (The Castle in the Clouds in the Sky (Top Floor))
			if(isActuallyEd())
			{
				run_choice(2); // ed advances via choice 2
			}
			else
			{
				run_choice(1); // everyone else advances via choice 1
			}
			break;
		case 680: // Are you a Man or a Mouse? (The Castle in the Clouds in the Sky (Top Floor))
			run_choice(1);
			break;
		case 689: // The Final Reward (Daily Dungeon 15th room)
		case 690: // The First Chest Isn't the Deepest. (Daily Dungeon 5th room)
		case 691: // Second Chest (Daily Dungeon 10th room)
		case 692: // I Wanna Be a Door (Daily Dungeon)
		case 693: // It's Almost Certainly a Trap (Daily Dungeon)
			dailyDungeonChoiceHandler(choice, options);
			break;
		case 700: // Delirium in the Cafeterium (KOLHS 22nd adventure every day)
		case 768: // The Littlest Identity Crisis (Mini-adventurer initialization)
			if(in_quantumTerrarium()) {
				if (my_location() == $location[The Themthar Hills]) {
					run_choice(4); // Sauceror is a lep and starfish
				}
				else if (my_level() < 13) {
					run_choice(2); // Turtle Tamer is a volleyball and a starfish at level 5
				}
				else {
					run_choice(6); // Accordion Thief is a fairy and ghoul whelp, with some free buffs.
				}
			}
			else {
				run_choice(2); // Turtle Tamer is a decent fallback pick.
			}
			break;
		case 772: // Saved by the Bell (KOLHS after school)
			kolhsChoiceHandler(choice);
			break;
		case 780: // Action Elevator (The Hidden Apartment Building)
			if(in_pokefam() && get_property("relocatePygmyLawyer").to_int() != my_ascensions()) {
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
				run_choice(6); // skip
			}
			break;
		case 793: // The Shore, Inc. Travel Agency. doing a vacation
			if(my_primestat() == $stat[Muscle])
			{
				run_choice(1);
			}
			else if(my_primestat() == $stat[Mysticality])
			{
				run_choice(2);
			}
			else	//if no prime stat we still want moxie
			{
				run_choice(3);
			}
			break;
		case 794: // Once More Unto the Junk (The Old Landfill)
		case 795: // The Bathroom of Ten Men (The Old Landfill)
		case 796: // The Den of Iquity (The Old Landfill)
		case 797: // Let's Workshop This a Little (The Old Landfill)
			oldLandfillChoiceHandler(choice);
			break;
		case 829: // We All Wear Masks (Grimstone Mask Choice)
			run_choice(1);			//choose step mother. we want [Ornate Dowsing Rod]
			break;
		case 822: //The Prince's Ball (In the Restroom)
		case 823: //The Prince's Ball (On the Dance Floor)
		case 824: //The Prince's Ball (The Kitchen)
		case 825: //The Prince's Ball (On the Balcony)
		case 826: //The Prince's Ball (The Lounge)
			run_choice(1);			//pickup odd silver coin
			break;
		case 875: // Welcome To Our ool Table (The Haunted Billiards Room).
			if(poolSkillPracticeGains() == 1 || currentPoolSkill() > 15)
			{
				run_choice(1);		//try to win the key. on failure still gain 1 pool skill
			}
			else
			{
				run_choice(2);		//practice pool skill
			}
			break;
		case 876: // One Simple Nightstand (The Haunted Bedroom)
			if(my_meat() < 1000 + meatReserve() && auto_is_valid($item[old leather wallet]) && !in_wotsf())
			{
				run_choice(1); //get old leather wallet worth ~500 meat
			}
			else if(item_amount($item[ghost key]) > 0 && my_primestat() == $stat[muscle] && my_buffedstat($stat[muscle]) < 150)
			{
				run_choice(3); // spend 1 ghost key for primestat, get ~200 muscle XP
			}
			else
			{
				run_choice(2); // get min(200,muscle) of muscle XP
			}
			break;
		case 877: // One Mahogany Nightstand (The Haunted Bedroom)
			run_choice(1); // get half of a memo or old coin purse
			break;
		case 878: // One Ornate Nightstand (The Haunted Bedroom)
			boolean needSpectacles = !possessEquipment($item[Lord Spookyraven\'s Spectacles]) && internalQuestStatus("questL11Manor") < 2;
			if (is_boris() || in_wotsf() || (in_nuclear() && in_hardcore())) {
				needSpectacles = false;
			}
			if (needSpectacles) {
				run_choice(3); // get Lord Spookyraven's spectacles
			} else if (item_amount($item[disposable instant camera]) == 0 && internalQuestStatus("questL11Palindome") < 1) {
				run_choice(4); // get disposable instant camera
			} else if (my_primestat() != $stat[mysticality] || my_meat() < 1000 + meatReserve()) {
				run_choice(1); // get ~500 meat
			} else if(item_amount($item[ghost key]) > 0 && my_primestat() == $stat[mysticality] && my_buffedstat($stat[mysticality]) < 150) {
				run_choice(5); // spend 1 ghost key for primestat, get ~200 mysticality XP
			} else {
				run_choice(2); // get min(200,mys) of mys XP
			}
			break;
		case 879: // One Rustic Nightstand (The Haunted Bedroom)
			if(options contains 4) {
				run_choice(4); // only shows up rarely. when this line was added it was worth 1.3 million in mall
			} if(in_bhy() && item_amount($item[Antique Hand Mirror]) < 1) {
				run_choice(3); // fight the remains of a jilted mistress for the antique hand mirror
			} else if(item_amount($item[ghost key]) > 0 && my_primestat() == $stat[moxie] && my_buffedstat($stat[moxie]) < 150) {
				run_choice(5); // spend 1 ghost key for primestat, get ~200 moxie XP
			} else {
				run_choice(1); // get moxie substats
			}
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
		case 885: // Chasin' Babies (Nursery) (The Haunted Nursery)
			run_choice(6); // skip
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
			} else if (!possessEquipment($item[Blackberry Galoshes]) && item_amount($item[Blackberry]) >= 3 && !in_darkGyffte()) {
				run_choice(2); // go to The Blackberry Cobbler (#928)
			} else {
				run_choice(1); // Attack the bushes (fight blackberry bush)
			}
			break;
		case 928: // You Found Your Thrill (The Black Forest)
			if (!possessEquipment($item[Blackberry Galoshes]) && item_amount($item[Blackberry]) >= 3 && !in_darkGyffte()) {
				run_choice(4); // get Blackberry Galoshes
			} else {
				run_choice(5); // skip
			}
			break;
		case 1002: // Temple of the Legend in the Hidden City (A Massive Ziggurat/Actually Ed the Undying)
			if (item_amount($item[stone triangle]) == 4) {
				run_choice(1); // Put the Ancient Amulet back
			} else {
				run_choice(6); // skip
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
		case 1024: // Like a Bat out of Hell (Actually Ed the Undying)
			edUnderworldChoiceHandler(choice);
			break;
		case 1026: // Home on the Free Range (Castle in the Clouds in the Sky (Ground Floor))
			if (isActuallyEd() || in_pokefam()) //paths that don't require a boning Knife for the tower - possibly add Bugbear Invasion if we add support for it?
			{
				run_choice(3); // skip adventure
			}
			else
			{
				run_choice(2); // get Electric Boning Knife then skip adventure
			}
			break;
		case 1060: // Temporarily Out of Skeletons (The Skeleton Store)
			if (item_amount($item[Skeleton Store office key]) == 0) {
				run_choice(1); // Skeleton Store office key
			} else if (internalQuestStatus("questM23Meatsmith") < 1) {
				run_choice(4); // fight The former owner of the Skeleton Store
			} else {
				run_choice(2); // get ring of telling skeletons what to do or 300 meat
			}
			break;
		case 1061: // Heart of Madness (Madness Bakery Quest)
			if(internalQuestStatus("questM25Armorer") <= 2) {
				run_choice(1);
			} else {
				run_choice(5);
			}
			break;
		case 1062: // Lots of Options (The Overgrown Lot)
			if(options contains 1)
			{
				run_choice(1); // get flowers for doc galaktik quest
			}
			else if(can_drink() && options contains 5)
			{
				run_choice(5); // get extra booze from map to a hidden booze cache
			}
			else if(can_drink() && !is_boris())		//prefer food in boris
			{
				run_choice(3); // get booze
			}
			else if(can_eat())
			{
				run_choice(2); // get food
			}
			else
			{
				run_choice(4); // get 15 moxie substat
			}
			break;
		case 1082: // The "Rescue" (post-Cake Lord in Madness Bakery)
			run_choice(1);
			break;
		case 1083: // Cogito Ergot Sum (post-post-Cake Lord in Madness Bakery)
			run_choice(1);
			break;
		case 1115: // VYKEA! (VYKEA)
			if (!get_property("_VYKEACafeteriaRaided").to_boolean() && !in_community()) {
				run_choice(1); // get consumables
			} else if (!get_property("_VYKEALoungeRaided").to_boolean()) {
				run_choice(4); // get Wal-Mart gift certificates
			} else {
				run_choice(6); // skip
			}
			break;
		case 1119: // Blue Sideways In Time (Machine Elf)
			run_choice(1); // acquire some abstractions
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

			int glchoice = 0;
			foreach idx, str in options
			{
				if(contains_text(str,search))
				{
					glchoice = idx;
				}
			}
			run_choice(glchoice);
			break;
		case 1322: // The Beginning of the Neverend (The Neverending Party)
		case 1323: // All Done! (The Neverending Party)
		case 1324: // It Hasn't Ended, It's Just Paused (The Neverending Party)
		case 1325: // A Room With a View... Of a Bed (The Neverending Party)
		case 1326: // Gone Kitchin' (The Neverending Party)
		case 1327: // Forward to the Back (The Neverending Party)
		case 1328: // Basement Urges (The Neverending Party)
			neverendingPartyChoiceHandler(choice);
			break;
		case 1393: // The Invader
			run_choice(1); // fight the invader
			break;
		case 1340: // Is There A Doctor In The House? (Lil' Doctor Bag™)
			auto_log_info("Accepting doctor quest, it's our job!");
			run_choice(1);
			break;
		case 1342: // Torpor (Dark Gyffte)
			bat_reallyPickSkills(20);
			break;
		case 1391: // Rationing out Destruction (Kingdom of Exploathing)
			koe_RationingOutDestruction();
			break;
		case 1410: // The Mushy Center (Your Mushroom Garden)
			mushroomGardenChoiceHandler(choice);
			break;
		case 1425: // Oh Yeah! (Cartography)
		case 1427: // The Hidden Junction (Cartography)
		case 1428: // Your Neck of the Woods (Cartography)
		case 1429: // No Nook Unknown (Cartography)
		case 1430: // Ghostly Memories (Cartography)
		case 1431: // Here There Be Giants (Cartography)
		case 1432: // Mob Maptality (Cartography)
		case 1433: // Sneaky, Sneaky (The Hippy Camp (Verge of War)) (Cartography)
		case 1434: // Sneaky, Sneaky (Orcish Frat House (Verge of War)) (Cartography)
		case 1435: // Leading Yourself Right to Them (Map the Monsters)
		case 1436: // Billiards Room Options (Cartography)
			cartographyChoiceHandler(choice);
			break;
		default:
			break;
	}

	return true;
}

void main(int choice, string page)
{
	boolean ret = false;
	try
	{
		ret = auto_run_choice(choice, page);
	}
	finally
	{
		if (!ret)
		{
			auto_log_error("Error running auto_choice_adv.ash, setting auto_interrupt=true");
			set_property("auto_interrupt", true);
		}
	}
}
