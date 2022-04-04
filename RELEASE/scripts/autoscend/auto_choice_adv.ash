import<autoscend.ash>

boolean auto_run_choice(int choice, string page)
{
	if(robot_choice_adv(choice, page)) return true; // an override function for You, Robot path.
	
	auto_log_debug("Running auto_choice_adv.ash");
	string[int] options = available_choice_options();
	
	switch(choice)
	{
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
		case 21: // Under the Knife (The Sleazy Back Alley)
			run_choice(2); // skip
			break;
		case 22: // The Arrrbitrator (The Obligatory Pirate's Cove)
		case 23: // Barrie Me at Sea (The Obligatory Pirate's Cove)
		case 24: // Amatearrr Night (The Obligatory Pirate's Cove)
			piratesCoveChoiceHandler(choice);
			break;
		case 89: // Out in the Garden (The Haunted Gallery)
			if(isActuallyEd() && (!possessEquipment($item[serpentine sword]) || !possessEquipment($item[snake shield])))
			{
				run_choice(2); // fight the snake knight (should non-Ed classes/paths do this too?)
			}
			else
			{
				run_choice(4); // ignore the NC & banish it for 10 adv
			}
			break;
		case 90: // Curtains (The Haunted Ballroom)
			run_choice(3); // skip
			break;
		case 105: // Having a Medicine Ball (The Haunted Bathroom)
			if(my_primestat() == $stat[Mysticality])
			{
				run_choice(1); // get mysticality substats
			}
			else
			{
				run_choice(2); // go to Bad Medicine is What You Need (#107)
			}
			break;
		case 106: // Strung-Up Quartet (The Haunted Ballroom)
			run_choice(3); // +5% item drops everywhere
			break;
		case 107: // Bad Medicine is What You Need (The Haunted Bathroom)
			run_choice(4); // skip
			break;
		case 108: // Aww, Craps (The Sleazy Back Alley)
			run_choice(4); // skip
			break;
		case 109: // Dumpster Diving (The Sleazy Back Alley)
			run_choice(1); // fight a drunken half-orc hobo
			break;
		case 110: // The Entertainer (The Sleazy Back Alley)
			run_choice(4); // skip
			break;
		case 111: // Malice in Chains (Outskirts of Cobb's Knob)
			run_choice(3); // fight a sleeping Knob Goblin guard
			break;
		case 112: // Please, Hammer (The Sleazy Back Alley)
			run_choice(2); // skip
			break;
		case 113: // Knob Gobin BBQ (Outskirts of Cobb's Knob)
			run_choice(2); // fight a Knob Goblin Barbecue Team
			break;
		case 114: // The Baker's Dilemma (The Haunted Pantry)
			run_choice(2); // skip
			break;
		case 115: // Oh No, Hobo (The Haunted Pantry)
			run_choice(1); // fight a drunken half-orc hobo
			break;
		case 116: // The Singing Tree (Rustling) (The Haunted Pantry)
			run_choice(4); // skip
			break;
		case 117: // Trespasser (The Haunted Pantry)
			run_choice(1); // fight a Knob Goblin Assistant Chef
			break;
		case 118: // When Rocks Attack (Outskirts of Cobb's Knob)
			run_choice(2); // skip
			break;
		case 120: // Ennui is Wasted on the Young (Outskirts of Cobb's Knob)
			run_choice(4); // skip
			break;
		case 123: // At Least It's Not Full Of Trash (The Hidden Temple)
		case 125: // No Visible Means of Support (The Hidden Temple)
			hiddenTempleChoiceHandler(choice, page);
			break;
		case 139: // Bait and Switch (The Hippy Camp (Verge of War))
			run_choice(3); // fight a War Hippy (space) cadet for outfit pieces
			break;
		case 140: // The Thin Tie-Dyed Line (The Hippy Camp (Verge of War))
			run_choice(3); // fight a War Hippy drill sergeant for outfit pieces
			break;
		case 141: // Blockin' Out the Scenery (The Hippy Camp (Verge of War) wearing Frat Boy Ensemble)
			run_choice(1); // get 50 mysticality
			break;
		case 142: // Blockin' Out the Scenery (The Hippy Camp (Verge of War) wearing Frat Warrior Fatigues)
			run_choice(3); // starts the war. skips adventure if already started.
			break;
		case 143: // Catching Some Zetas (Orcish Frat House (Verge of War))
			run_choice(3); // fight a War Pledge for outfit pieces
			break;
		case 144: // One Less Room Than In That Movie (Orcish Frat House (Verge of War))
			run_choice(3); // fight a Frat Warrior drill sergeant for outfit pieces
			break;
		case 145: // Fratacombs (Orcish Frat House (Verge of War) wearing Filthy Hippy Disguise)
			run_choice(1); // get 50 muscle
			break;
		case 146: // Fratacombs (Orcish Frat House (Verge of War) wearing War Hippy Fatigues)
			run_choice(3); // starts the war. skips adventure if already started.
			break;
		case 147: // Cornered! (McMillicancuddy's Barn)
			run_choice(3); // open the pond
			break;
		case 148: // Cornered Again! (McMillicancuddy's Barn)
			run_choice(1); // open the back 40
			break;
		case 149: // How Many Corners Does this Stupid Barn Have!? (McMillicancuddy's Barn)
			run_choice(2); // open the other back 40
			break;
		case 153: // Turn Your Head and Coffin (The Defiled Alcove)
		case 155: // Skull, Skull, Skull (The Defiled Nook)
		case 157: // Urning Your Keep (The Defiled Niche)
			cyrptChoiceHandler(choice);
			break;
		case 163: // Melvil Dewey Would Be Ashamed (The Haunted Library)
			if(in_lar())
			{
				set_property("_LAR_skipNC163", my_turncount());	// NC in LAR path forced to reoccur if we skip it. Go do something else.
			}
			run_choice(4); // skip
			break;
		case 178: // Hammering the Armory (The Penultimate Fantasy Airship)
			if(in_lar())
			{
				set_property("_LAR_skipNC178", my_turncount());	// NC in LAR path forced to reoccur if we skip it. Go do something else.
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
			if(is_wearing_outfit("Frat Boy Ensemble"))
			{
				run_choice(1);
			}
			else if(equipped_amount($item[mullet wig]) == 1 && item_amount($item[briefcase]) > 0)
			{
				run_choice(2);
			}
			else if(equipped_amount($item[frilly skirt]) == 1 && item_amount($item[hot wing]) > 2)
			{
				run_choice(3);
			}
			else abort("I tried to infiltrate the orcish frat house without being equipped for the job");
			break;
		case 189: // O Cap'm, My Cap'm (The Poop Deck)
			run_choice(2); // skip
			break;
		case 191: // Chatterboxing (The F'c'le)
			fcleChoiceHandler(choice);
			break;
		case 330: // A Shark's Chum (The Haunted Billiards Room, semi-rarely)
			if(get_property("poolSharkCount").to_int() < 25)
			{
				run_choice(1); // train pool skill
			}
			else
			{
				run_choice(2); // fight hustled spectre for cube of billiard chalk
			}
			break;
		case 502: // Arboreal Respite (The Spooky Forest)
		case 503: // The Road Less Traveled (The Spooky Forest)
		case 504: // Tree's Last Stand (The Spooky Forest)
		case 505: // Consciousness of a Stream (The Spooky Forest)
		case 506: // Through Thicket and Thinnet (The Spooky Forest)
		case 507: // O Lith, Mon (The Spooky Forest)
			spookyForestChoiceHandler(choice);
			break;
		case 523: // Death Rattlin' (The Defiled Cranny)
		case 527: // The Haert of Darkness (The Cyrpt)
			cyrptChoiceHandler(choice);
			break;
		case 542: // Now's Your Pants! I Mean... Your Chance! (The Sleazy Back Alley)
		case 543: // Up In Their Grill (Outskirts of Cobb's Knob)
		case 544: // A Sandwich Appears! (The Haunted Pantry)
			run_choice(1); // always finish guild task via choice 1
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
		case 588: // Machines! (Bugbear Mothership Sonar)
			if(!page.contains_text("name=pingvalue size=5 value=2"))
			{
				run_choice(1, "pingvalue=2");
			}
			else if(!page.contains_text("name=whurmvalue size=5 value=4"))
			{
				run_choice(2, "whurmvalue=4");
			}
			else if(!page.contains_text("name=boomchuckvalue size=5 value=8"))
			{
				run_choice(3, "boomchuckvalue=8");
			}
			break;
		case 589: // Autopsy Auturvy (Bugbear Mothership Morgue)
			if(item_amount($item[bugbear autopsy tweezers]) > 0)
			{
				// choices 1-5, do these change? or get removed?
				for i from 1 to 5
				{
					if(options contains i)
					{
						run_choice(i);
						break;
					}
				}
			}
			else
			{
				run_choice(6);
			}
			break;
		case 590: // Not Alone In The Dark (Bugbear Mothership Special Ops)
			if(options contains 2)
			{
				run_choice(2);
			}
			else
			{
				run_choice(1);
			}
			break;
		case 591: // The Beginning of the Beginning of the End (Bugbear Mothership Bridge)
		case 592: // The Middle of the Beginning of the End (Bugbear Mothership Bridge)
		case 593: // The End of the Beginning of the End (Bugbear Mothership Bridge)
			run_choice(1);
			break;
		case 597: // When visiting the Cake-Shaped Arena with a Reagnimated Gnome
			auto_reagnimatedGetPart(choice);
			break;
		case 604: // Welcome to the Great Overlook Lodge (Twin Peak Part 1)
		case 605: // Welcome to the Great Overlook Lodge (Twin Peak Part 2)
		case 607: // Room 237 (Lost in the Great Overlook Lodge)
		case 608: // Go Check It Out! (Lost in the Great Overlook Lodge)
		case 609: // There's Always Music In the Air (Lost in the Great Overlook Lodge)
		case 610: // To Catch a Killer (Lost in the Great Overlook Lodge)
		case 616: // He Is the Arm, and He Sounds Like This (Lost in the Great Overlook Lodge)
			run_choice(1); // always advance to next option via choice 1
			break;
		case 618: // Cabin Fever (Twin Peak)
			run_choice(2); // finish twin peak quest the long way
			break;
		case 669: // The Fast and the Furry-ous (The Castle in the Clouds in the Sky (Basement))
		case 670: // You Don't Mess Around with Gym (The Castle in the Clouds in the Sky (Basement))
		case 671: // Out in the Open Source (The Castle in the Clouds in the Sky (Basement))
			castleBasementChoiceHandler(choice);
			break;
		case 672: // There's No Ability Like Possibility (Castle in the Clouds in the Sky (Ground Floor))
		case 673: // Putting Off Is Off-Putting (Castle in the Clouds in the Sky (Ground Floor))
		case 674: // Huzzah! (Castle in the Clouds in the Sky (Ground Floor))
			run_choice(3); // always skip via choice 3
			break;
		case 675: // Melon Collie and the Infinite Lameness (The Castle in the Clouds in the Sky (Top Floor))
		case 676: // Flavor of a Raver (The Castle in the Clouds in the Sky (Top Floor))
		case 677: // Copper Feel (The Castle in the Clouds in the Sky (Top Floor))
		case 678: // Yeah, You're for Me, Punk Rock Giant (The Castle in the Clouds in the Sky (Top Floor))
		case 679: // Keep On Turnin' the Wheel in the Sky (The Castle in the Clouds in the Sky (Top Floor))
		case 680: // Are you a Man or a Mouse? (The Castle in the Clouds in the Sky (Top Floor))
			castleTopFloorChoiceHandler(choice);
			break;
		case 689: // The Final Reward (Daily Dungeon 15th room)
		case 690: // The First Chest Isn't the Deepest. (Daily Dungeon 5th room)
		case 691: // Second Chest (Daily Dungeon 10th room)
		case 692: // I Wanna Be a Door (Daily Dungeon)
		case 693: // It's Almost Certainly a Trap (Daily Dungeon)
			dailyDungeonChoiceHandler(choice, options);
			break;
		case 700: // Delirium in the Cafeterium (KOLHS 22nd adventure every day)
			kolhsChoiceHandler(choice);
			break;
		case 763: // It's Kind of a Big Deal (BIG!)
			run_choice(1); // approach the booth to get big pants
			break;
		case 768: // The Littlest Identity Crisis (Mini-adventurer initialization)
			if(in_quantumTerrarium())
			{
				if(my_location() == $location[The Themthar Hills])
				{
					run_choice(4); // Sauceror is a lep and starfish
				}
				else if(my_level() < 13)
				{
					run_choice(2); // Turtle Tamer is a volleyball and a starfish at level 5
				}
				else
				{
					run_choice(6); // Accordion Thief is a fairy and ghoul whelp, with some free buffs.
				}
			}
			else
			{
				run_choice(2); // Turtle Tamer is a decent fallback pick.
			}
			break;
		case 772: // Saved by the Bell (KOLHS after school)
			kolhsChoiceHandler(choice);
			break;
		case 780: // Action Elevator (The Hidden Apartment Building)
		case 781: // Earthbound and Down (An Overgrown Shrine (Northwest))
		case 783: // Water You Dune (An Overgrown Shrine (Southwest))
		case 784: // You, M. D. (The Hidden Hospital)
		case 785: // Air Apparent (An Overgrown Shrine (Northeast))
		case 786: // Working Holiday (The Hidden Office Building)
		case 787: // Fire When Ready (An Overgrown Shrine (Southeast))
		case 788: // Life is Like a Cherry of Bowls (The Hidden Bowling Alley)
		case 789: // Where Does The Lone Ranger Take His Garbagester? (The Hidden Park)
		case 791: // Legend of the Temple in the Hidden City (A Massive Ziggurat)
			hiddenCityChoiceHandler(choice);
			break;
		case 793: // The Shore, Inc. Travel Agency. doing a vacation
			if(my_primestat() == $stat[Muscle])
			{
				run_choice(1); // muscle stats
			}
			else if(my_primestat() == $stat[Mysticality])
			{
				run_choice(2); // myst stats
			}
			else // if no prime stat we still want moxie
			{
				run_choice(3); // moxie stats
			}
			break;
		case 794: // Once More Unto the Junk (The Old Landfill)
		case 795: // The Bathroom of Ten Men (The Old Landfill)
		case 796: // The Den of Iquity (The Old Landfill)
		case 797: // Let's Workshop This a Little (The Old Landfill)
			oldLandfillChoiceHandler(choice);
			break;
		case 822: // The Prince's Ball (In the Restroom)
		case 823: // The Prince's Ball (On the Dance Floor)
		case 824: // The Prince's Ball (The Kitchen)
		case 825: // The Prince's Ball (On the Balcony)
		case 826: // The Prince's Ball (The Lounge)
			run_choice(1); // pickup odd silver coin
			break;
		case 829: // We All Wear Masks (Grimstone Mask Choice)
			run_choice(1); // choose step mother. we want [Ornate Dowsing Rod]
			break;
		case 875: // Welcome To Our ool Table (The Haunted Billiards Room).
			if(poolSkillPracticeGains() == 1 || currentPoolSkill() > 15)
			{
				run_choice(1); // try to win the key. on failure still gain 1 pool skill
			}
			else
			{
				run_choice(2); // practice pool skill
			}
			break;
		case 876: // One Simple Nightstand (The Haunted Bedroom)
		case 877: // One Mahogany Nightstand (The Haunted Bedroom)
		case 878: // One Ornate Nightstand (The Haunted Bedroom)
		case 879: // One Rustic Nightstand (The Haunted Bedroom)
		case 880: // One Elegant Nightstand (The Haunted Bedroom)
			hauntedBedroomChoiceHandler(choice, options);
			break;
		case 881: // Never Gonna Make You Up (The Haunted Bathroom)
			run_choice(1); // fight the cosmetics wraith
			break;
		case 882: // Off the Rack (The Haunted Bathroom)
			run_choice(1); // take the towel
			break;
		case 884: // Chasin' Babies (Laboratory) (The Haunted Laboratory)
		case 885: // Chasin' Babies (Nursery) (The Haunted Nursery)
		case 886: // Chasin' Babies (Storage Room) (The Haunted Storage Room)
			run_choice(6); // skip
			break;
		case 888: // Take a Look, it's in a Book! (Rise) (The Haunted Library)
			run_choice(4); // skip
			break;
		case 889: // Take a Look, it's in a Book! (Fall) (The Haunted Library)
			if(item_amount($item[dictionary]) == 0 && get_property("auto_getDictionary").to_boolean())
			{
				run_choice(4); // get the dictionary
			}
			else
			{
				run_choice(5); // skip
			}
			break;
		case 921: // We'll All Be Flat (The Haunted Ballroom)
			run_choice(1); // unlock Spookyraven Manor Cellar 
			break;
		case 923: // All Over the Map (The Black Forest)
		case 924: // You Found Your Thrill (The Black Forest)
		case 925: // The Blackest Smith (The Black Forest)
		case 926: // Be Mine (The Black Forest)
		case 927: // Sunday Black Sunday (The Black Forest)
		case 928: // You Found Your Thrill (The Black Forest)
			blackForestChoiceHandler(choice);
			break;
		case 976: // Ed the Undrowning (Heavy Rains)
			run_choice(1); // fight Ed in a Heavy Rains run
			break;
		case 1000: // Everything in Moderation (The Typical Tavern Cellar as Ed)
			run_choice(1); // turn off the faucet as Ed, complete quest
			break;
		case 1001: // Hot and Cold Dripping Rats (The Typical Tavern Cellar as Ed)
			run_choice(2); // choose to not fight a rat 
			break;
		case 1002: // Temple of the Legend in the Hidden City (A Massive Ziggurat/Actually Ed the Undying)
			hiddenCityChoiceHandler(choice);
			break;
		case 1018: // Bee Persistent (The Black Forest)
		case 1019: // Bee Rewarded (The Black Forest)
			blackForestChoiceHandler(choice);
			break;
		case 1023: // Like a Bat Into Hell (Actually Ed the Undying)
		case 1024: // Like a Bat out of Hell (Actually Ed the Undying)
			edUnderworldChoiceHandler(choice);
			break;
		case 1026: // Home on the Free Range (Castle in the Clouds in the Sky (Ground Floor))
			if(item_amount($item[electric boning knife]) > 0 ||
			isActuallyEd() || in_bugbear() || in_pokefam()) // paths that don't require a boning knife for the tower
			{
				run_choice(3); // skip
			}
			else
			{
				run_choice(2); // get Electric Boning Knife
			}
			break;
		case 1056: // Now It's Dark (Lost in the Great Overlook Lodge)
			run_choice(1); // finish init portion of quest
			break;
		case 1060: // Temporarily Out of Skeletons (The Skeleton Store)
			if(item_amount($item[Skeleton Store office key]) == 0)
			{
				run_choice(1); // Skeleton Store office key
			}
			else if(internalQuestStatus("questM23Meatsmith") < 1)
			{
				run_choice(4); // fight The former owner of the Skeleton Store
			}
			else
			{
				run_choice(2); // get ring of telling skeletons what to do or 300 meat
			}
			break;
		case 1061: // Heart of Madness (Madness Bakery Quest)
			if(internalQuestStatus("questM25Armorer") <= 2)
			{
				run_choice(1); // try to open door or open the door to fight Cake Lord
			}
			else
			{
				run_choice(5); // myst stats as best default option
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
			else if(can_drink() && !is_boris()) // prefer food in boris
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
		case 1074: // Welcome to the Copperhead Club (The Copperhead Club)
			run_choice(1); // approach Shen's table
			break;
		case 1082: // The "Rescue" (post-Cake Lord in Madness Bakery)
			run_choice(1); // move to next part of quest
			break;
		case 1083: // Cogito Ergot Sum (post-post-Cake Lord in Madness Bakery)
			run_choice(1); // get the no-handed pie and complete quest
			break;
		case 1106: // Wooof! Wooooooof! (Ghost Dog)
		case 1107: // Playing Fetch (Ghost Dog)
		case 1108: // Your Dog Found Something Again (Ghost Dog)
			doghouseChoiceHandler(choice);
			break;
		case 1115: // VYKEA! (VYKEA)
			if(!get_property("_VYKEACafeteriaRaided").to_boolean() && !in_community())
			{
				run_choice(1); // get consumables
			}
			else if(!get_property("_VYKEALoungeRaided").to_boolean())
			{
				run_choice(4); // get Wal-Mart gift certificates
			}
			else
			{
				run_choice(6); // skip
			}
			break;
		case 1119: // Blue Sideways In Time (Machine Elf)
			run_choice(1); // acquire some abstractions
			break;
		case 1258: // Daily Briefing (License to Adventure)
			run_choice(2); // visit LI-11 HQ
			break;
		case 1261: // Which Door? (Super Villain's Lair)
			if(my_meat() > 1000)
			{
				run_choice(1); // spend 1000 meat to eliminate 10 minions
			}
			else
			{
				run_choice(4); // if can't afford door 1, choose none
			}
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
		case 1393: // The Invader (Kingdom of Exploathing)
			run_choice(1); // fight the invader
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
		if(!ret)
		{
			auto_log_error("Error running auto_choice_adv.ash, setting auto_interrupt=true");
			set_property("auto_interrupt", true);
		}
	}
}
