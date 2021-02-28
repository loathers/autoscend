# This is meant for items that have a date of 2020

boolean auto_haveBirdADayCalendar() {
	return (item_amount($item[Bird-a-Day calendar]) > 0 && auto_is_valid($item[Bird-a-Day calendar]));
}

boolean auto_birdOfTheDay() {
	if (auto_haveBirdADayCalendar() && get_property("_birdOfTheDay") == "") {
		auto_log_info("What a beautiful morning! What's today's bird?");
		return use(1, $item[Bird-a-Day calendar]);
	}
	return false;
}

boolean auto_birdIsValid()
{
	// can't seek a bird if you can't use or don't own the calendar
	if (!auto_haveBirdADayCalendar()) {
		return false;
	}

	// don't want to overwrite favorite bird automatically
	// however, if they already overwrote favorite bird manually today
	// and we somehow have enough mp to continue casting
	// it might as well be an option
	// hence == 0 and not <= 0
	if(auto_birdsLeftToday() == 0)
	{
		return false;
	}

	if(!get_property("_canSeekBirds").to_boolean())
	{
		use(1, $item[Bird-a-Day calendar]);
	}

	return true;
}

float auto_birdModifier(string mod)
{
	if(!auto_birdIsValid())
	{
		return 0;
	}

	return numeric_modifier($effect[Blessing of the Bird], mod);
}

float auto_favoriteBirdModifier(string mod)
{
	return numeric_modifier($effect[Blessing of Your Favorite Bird], mod);
}

int auto_birdsSought()
{
	return get_property("_birdsSoughtToday").to_int();
}

int auto_birdsLeftToday()
{
	return 6 - auto_birdsSought();
}

boolean auto_birdCanSeek()
{
	if(!auto_birdIsValid())
	{
		return false;
	}

	return auto_have_skill($skill[Seek Out a Bird]);
}

boolean auto_favoriteBirdCanSeek()
{
	// can't seek out your favorite if you already did today
	if(get_property("_favoriteBirdVisited").to_boolean())
	{
		return false;
	}

	return auto_have_skill($skill[Visit Your Favorite Bird]);
}

boolean auto_hasPowerfulGlove()
{
	return possessEquipment($item[Powerful Glove]) && 
		auto_is_valid($item[mint-in-box Powerful Glove]);
}

int auto_powerfulGloveCharges()
{
	if (!auto_hasPowerfulGlove()) return 0;
	return 100 - get_property("_powerfulGloveBatteryPowerUsed").to_int();
}

boolean auto_powerfulGloveNoncombatSkill(skill sk)
{
	if (!auto_hasPowerfulGlove() || !auto_is_valid(sk)) return false;

	if (auto_powerfulGloveCharges() < 5) return false;

	item old;
	if (!have_equipped($item[Powerful Glove]))
	{
		old = equipped_item($slot[Acc3]);
		equip($slot[Acc3], $item[Powerful Glove]);
	}

	boolean ret = use_skill(1, sk);

	if (old != $item[none])
	{
		equip($slot[Acc3], old);
	}

	if (ret)
	{
		handleTracker(sk, "auto_powerfulglove");
	}
	else
	{
		// if we fail to cast a skill, odds are something has gone wrong with
		// mafia's tracking. Let's check to make sure, then make sure we stop
		// attempting to use more cheats in vain if so.
		string page = visit_url("desc_item.php?whichitem=991142661");
		if(page.contains_text("The Glove's battery is fully depleted."))
		{
			auto_log_error("Mafia's Powerful Glove battery tracking was wrong, correcting.");
			set_property("_powerfulGloveBatteryPowerUsed", 100);
		}
	}

	return ret;
}

// Returns if replaces are available, optionally only if the Powerful Glove is equipped
int auto_powerfulGloveReplacesAvailable(boolean inCombat)
{
	if (!auto_hasPowerfulGlove()) return 0;

	if (inCombat && !have_equipped($item[Powerful Glove])) return 0;

	return (auto_powerfulGloveCharges() / 10).to_int();
}

// Returns if replaces are available if the Powerful Glove was equipped
int auto_powerfulGloveReplacesAvailable()
{
	return auto_powerfulGloveReplacesAvailable(false);
}

boolean auto_powerfulGloveNoncombat()
{
	if (0 < have_effect($effect[Invisible Avatar])) return false;

	return auto_powerfulGloveNoncombatSkill($skill[CHEAT CODE: Invisible Avatar]);
}

boolean auto_powerfulGloveStats()
{
	return auto_powerfulGloveNoncombatSkill($skill[CHEAT CODE: Triple Size]);
}

boolean auto_wantToEquipPowerfulGlove()
{
	if (!auto_hasPowerfulGlove()) return false;

	if (in_zelda() && !zelda_nothingToBuy()) return true;

	int pixels = whitePixelCount();
	if (contains_text(get_property("nsTowerDoorKeysUsed"), "digital key"))
	{
		pixels += 30;
	}

	return pixels < 30;
}

boolean auto_willEquipPowerfulGlove()
{
	foreach s in $slots[acc1, acc2, acc3]
	{
		string pref = getMaximizeSlotPref(s);
		string toEquip = get_property(pref);
		if(toEquip == $item[Powerful Glove])
		{
			return true;
		}
	}

	return false;
}

boolean auto_forceEquipPowerfulGlove()
{
	if (!auto_hasPowerfulGlove()) return false;

	if(auto_willEquipPowerfulGlove())
	{
		return true;
	}

	return autoEquip($slot[acc3], $item[Powerful Glove]);
}

void auto_burnPowerfulGloveCharges()
{
	while (auto_hasPowerfulGlove() && auto_powerfulGloveCharges() >= 5)
	{
		auto_powerfulGloveStats();
	}
}

boolean auto_canFightPiranhaPlant()
{
	int numMushroomFights = (in_zelda() ? 5 : 1);
	if (auto_is_valid($item[packet of mushroom spores]) &&
			get_campground() contains $item[packet of mushroom spores] &&
			get_property("_mushroomGardenFights").to_int() < numMushroomFights)
	{
		return true;
	}
	return false;
}

boolean auto_canTendMushroomGarden()
{
	if (auto_is_valid($item[packet of mushroom spores]) &&
			get_campground() contains $item[packet of mushroom spores] &&
			!get_property("_mushroomGardenVisited").to_boolean())
	{
		return true;
	}
	return false;
}

int auto_piranhaPlantFightsRemaining()
{
	if (auto_canFightPiranhaPlant())
	{
		int numMushroomFights = (in_zelda() ? 5 : 1);
		return (numMushroomFights - get_property("_mushroomGardenFights").to_int());
	}
	return 0;
}

boolean auto_mushroomGardenHandler()
{
	if (auto_piranhaPlantFightsRemaining() > 0)
	{
		return autoAdv($location[Your Mushroom Garden]);
	}
	else if (auto_canTendMushroomGarden())
	{
		autoAdv($location[Your Mushroom Garden]);
		// TODO: Malibu Stacey - move all this to a more central location after refactor
		use(item_amount($item[colossal free-range mushroom]), $item[colossal free-range mushroom]);
		use(item_amount($item[immense free-range mushroom]), $item[immense free-range mushroom]);
		use(item_amount($item[giant free-range mushroom]), $item[giant free-range mushroom]);
		use(item_amount($item[bulky free-range mushroom]), $item[bulky free-range mushroom]);
		use(item_amount($item[plump free-range mushroom]), $item[plump free-range mushroom]);
		use(item_amount($item[free-range mushroom]), $item[free-range mushroom]);
		return true;
	}
	return false;
}

void mushroomGardenChoiceHandler(int choice)
{
	if (choice == 1410)
	{
		string growth = get_property("auto_mushroomGardenGrowth");
		int pick = 1;
		if (growth != "")
		{
			// limit to growth of 11 for colossal free-range mushroom as any further growth is wasted.
			pick = min(growth.to_int(), 11);
		}
		if (get_property("mushroomGardenCropLevel").to_int() >= pick)
		{
			run_choice(2); // pick the mushroom.
		}
		else
		{
			run_choice(1); // fertilise the mushroom
		}
	}
	else
	{
		abort("unhandled choice in mushroomGardenChoiceHandler");
	}
}

boolean auto_getGuzzlrCocktailSet()
{
	if (possessEquipment($item[Guzzlr tablet]) && auto_is_valid($item[Guzzlr tablet]) && !get_property("auto_skipGuzzlrCocktailSet").to_boolean())
	{
		if (get_property("guzzlrGoldDeliveries").to_int() >= 5
		&& get_property("questGuzzlr") == "unstarted"
		&& get_property("_guzzlrPlatinumDeliveries").to_int() == 0
		&& !get_property("_guzzlrQuestAbandoned").to_boolean())
		{
			auto_log_info("Getting a Guzzlr Cocktail Set (for all the good it will do).");
			visit_url("inventory.php?tap=guzzlr", false);
			run_choice(4); // take platinum quest
			wait(1); // mafia's tracking breaks occasionally if you go too fast.
			visit_url("inventory.php?tap=guzzlr", false);
			run_choice(1); // abandon
			run_choice(5); // leave the choice.
			return true; // ponder on what else you could've spent the Mr. Accessory on instead.
		}
	}
	return false;
}

boolean auto_canCamelSpit()
{
	return canChangeToFamiliar($familiar[Melodramedary]) && get_property("camelSpit").to_int() == 100;
}

boolean auto_latheHardwood(item toLathe)
{
	// can't lathe if lathe is out of standard (or otherwise unusable)
	if(!auto_is_valid($item[SpinMaster&trade; lathe]))
		return false;

	// can't lathe... without a lathe
	if(item_amount($item[SpinMaster&trade; lathe]) < 1)
		return false;

	// if breakfast hasn't run and you haven't grabbed it manually, we won't
	// see the scrap if we don't go grab it ourself. So do that, if needed.
	if(!get_property("_spinmasterLatheVisited").to_boolean())
		visit_url("shop.php?whichshop=lathe");

	// can't lathe without hardwood
	if(item_amount($item[flimsy hardwood scraps]) < 1)
		return false;

	// can't lathe things that aren't made of hardwood
	if(!($items[
		beechwood blowgun,
		birch battery,
		ebony epee,
		maple magnet,
		weeping willow wand,
	] contains toLathe))
		return false;

	return buy($coinmaster[Your SpinMaster&trade; lathe], 1, toLathe);
}

boolean auto_latheAppropriateWeapon()
{
	item toLathe;

	switch(my_primestat())
	{
		case $stat[Muscle]:
			toLathe = $item[ebony epee];
			break;
		case $stat[Mysticality]:
			toLathe = $item[weeping willow wand];
			break;
		case $stat[Moxie]:
			toLathe = $item[beechwood blowgun];
			break;
	}

	switch(my_class())
	{
		// autoscend likes Plumber to go for moxie, so let's make sure it
		// does even if another stat is ahead at the start of the day.
		case $class[Plumber]:
			toLathe = $item[beechwood blowgun];
			break;
		// If any future classes also have a variable mainstat, specify the desired item here
	}

	// don't want to accidentally use a second scrap in casual or something
	if(possessEquipment(toLathe))
		return false;

	return auto_latheHardwood(toLathe);
}

boolean auto_hasCargoShorts()
{
	return possessEquipment($item[Cargo Cultist Shorts]) && 
		auto_is_valid($item[Bagged Cargo Cultist Shorts]);
}

boolean auto_cargoShortsCanOpenPocket()
{
	if (!auto_hasCargoShorts())
		return false;
	
	return !get_property("_cargoPocketEmptied").to_boolean();
}

boolean auto_cargoShortsCanOpenPocket(int pocket)
{
	if (!auto_cargoShortsCanOpenPocket())
		return false;
	
	if (pocket <= 0 || pocket > 666)
		return false;

	boolean[int] picked = picked_pockets();
	if (picked[pocket])
		return false;
	
	return true;
}

boolean auto_cargoShortsCanOpenPocket(item i)
{
	if (!auto_cargoShortsCanOpenPocket())
		return false;

	return available_pocket(i) != 0;
}

boolean auto_cargoShortsCanOpenPocket(monster m)
{
	if (!auto_cargoShortsCanOpenPocket())
		return false;

	return available_pocket(m) != 0;
}

boolean auto_cargoShortsCanOpenPocket(effect e)
{
	if (!auto_cargoShortsCanOpenPocket())
		return false;
	
	return available_pocket(e) != 0;
}

boolean auto_cargoShortsCanOpenPocket(stat s)
{
	if (!auto_cargoShortsCanOpenPocket())
		return false;

	return available_pocket(s) != 0;
}

boolean auto_cargoShortsCanOpenPocket(string s)
{
	if (!auto_cargoShortsCanOpenPocket())
		return false;

	// to_int errors if not an int, check with regex first
	matcher m = create_matcher("^\d+$", s);
	if (m.find())
		return auto_cargoShortsCanOpenPocket(s.to_int());
	else if (s.to_item() != $item[none])
		return auto_cargoShortsCanOpenPocket(s.to_item());
	else if (s.to_monster() != $monster[none])
		return auto_cargoShortsCanOpenPocket(s.to_monster());
	else if (s.to_effect() != $effect[none])
		return auto_cargoShortsCanOpenPocket(s.to_effect());
	else if (s.to_stat() != $stat[none])
		return auto_cargoShortsCanOpenPocket(s.to_stat());

	return false;
}

boolean auto_cargoShortsOpenPocket(int pocket)
{
	if (!auto_cargoShortsCanOpenPocket(pocket))
		return false;

	return pick_pocket(pocket);
}

boolean auto_cargoShortsOpenPocket(item i)
{
	if (!auto_cargoShortsCanOpenPocket(i))
		return false;

	return pick_pocket(available_pocket(i));
}

boolean auto_cargoShortsOpenPocket(monster m)
{
	if (!auto_cargoShortsCanOpenPocket(m))
		return false;

	return pick_pocket(available_pocket(m));
}

boolean auto_cargoShortsOpenPocket(effect e)
{
	if (!auto_cargoShortsCanOpenPocket(e))
		return false;

	return pick_pocket(available_pocket(e));
}

boolean auto_cargoShortsOpenPocket(stat s)
{
	if (!auto_cargoShortsCanOpenPocket(s))
		return false;

	return pick_pocket(available_pocket(s));
}

boolean auto_cargoShortsOpenPocket(string s)
{
	if (!auto_cargoShortsCanOpenPocket(s))
		return false;

	// to_int errors if not an int, check with regex first
	matcher m = create_matcher("^\d+$", s);
	if (m.find())
		return auto_cargoShortsOpenPocket(s.to_int());
	else if (s.to_item() != $item[none])
		return auto_cargoShortsOpenPocket(s.to_item());
	else if (s.to_monster() != $monster[none])
		return auto_cargoShortsOpenPocket(s.to_monster());
	else if (s.to_effect() != $effect[none])
		return auto_cargoShortsOpenPocket(s.to_effect());
	else if (s.to_stat() != $stat[none])
		return auto_cargoShortsOpenPocket(s.to_stat());

	return false;
}

boolean auto_canMapTheMonsters()
{
	if (have_skill($skill[Map the Monsters]) && auto_is_valid($skill[Map the Monsters]))
	{
		return get_property("_monstersMapped").to_int() < 3;
	}
	return false;
}

boolean auto_mapTheMonsters()
{
	if (get_property("mappingMonsters").to_boolean())
	{
		auto_log_warning("Trying to cast map the monsters but we already have an unused cast pending, skipping.", "red");
		return true;
	}
	if (auto_canMapTheMonsters())
	{
		return use_skill(1, $skill[Map the Monsters]);
	}
	return false;
}

monster auto_monsterToMap(location loc)
{
	monster enemy = $monster[none];
	switch (loc)
	{
		case $location[8-Bit Realm]:
			enemy = $monster[Blooper];
			break;
		case $location[The Haunted Library]:
			enemy = $monster[writing desk];
			break;
		case $location[The Defiled Niche]:
			enemy = $monster[dirty old lihc];
			break;
		case $location[The Goatlet]:
			enemy = $monster[dairy goat];
			break;
		case $location[Twin Peak]:
			enemy = $monster[bearpig topiary animal];
			break;
		case $location[A Mob of Zeppelin Protesters]:
			enemy = $monster[blue oyster cultist];
			break;
		case $location[The Red Zeppelin]:
			enemy = $monster[red butler];
			break;
		case $location[Inside the Palindome]:
			enemy = $monster[Bob Racecar];
			break;
		case $location[The Hidden Bowling Alley]:
			enemy = $monster[Pygmy Bowler];
			break;
		case $location[The Hidden Hospital]:
			enemy = $monster[Pygmy Witch Surgeon];
			break;
		case $location[The Haunted Laundry Room]:
			enemy = $monster[cabinet of dr. limpieza];
			break;
		case $location[The Haunted Wine Cellar]:
			enemy = $monster[possessed wine rack];
			break;
		case $location[The Middle Chamber]:
			enemy = $monster[tomb rat];
			break;
		case $location[Sonofa Beach]:
			enemy = $monster[lobsterfrogman]; // not implemented yet (will be used to saber copy in 2021)
			break;
	}
	return enemy;
}

void cartographyChoiceHandler(int choice)
{
	auto_log_info("cartographyChoiceHandler Running choice " + choice, "blue");
	if (choice == 1427) // Hidden Junction (Guano Junction)
	{
		run_choice(1); // fight the screambat.
	}
	else if (choice == 1428) // Your Neck of the Woods (The Dark Neck of the Woods)
	{
		run_choice(2); // skip first 2 quest non-combats
	}
	else if (choice == 1429) // No Nook Unknown (The Defiled Nook)
	{
			run_choice(1); // acquire 2 evil eyes
	}
	else if (choice == 1430) // Ghostly Memories (A-boo Peak)
	{
		run_choice(1); // If we are adventuring in the peak we are trying to clear the peak, go to the horror
	}
	else if (choice == 1431) // Choice 1431 is Here There Be Giants (Cartography)
	{
		if (internalQuestStatus("questL10Garbage") == 9)
		{
			if (item_amount($item[model airship]) > 0)
			{
				run_choice(1); // go to steampunk choice to complete the quest
			}
			else if (have_equipped($item[mohawk wig]))
			{
				run_choice(4); // go to the punk rock choice to complete the quest
			}
			else
			{
				run_choice(3); // go to the raver choice to get the record?
			}
		}
		else
		{
			run_choice(1); // go to steampunk choice to open the hole in the sky.
		}
	}
	else if (choice == 1432) // Mob Maptality (A Mob of Zeppelin Protesters)
	{
		float fire_protestors = item_amount($item[Flamin\' Whatshisname]) > 0 ? 10 : 3;
		float sleaze_amount = numeric_modifier("sleaze damage") + numeric_modifier("sleaze spell damage");
		float sleaze_protestors = square_root(sleaze_amount);
		float lynyrd_protestors = have_effect($effect[Musky]) > 0 ? 6 : 3;
		foreach it in $items[lynyrdskin cap, lynyrdskin tunic, lynyrdskin breeches]
		{
			if (equipped_amount(it) > 0)
			{
				lynyrd_protestors += 5;
			}
		}
		float best_protestors = max(fire_protestors, max(sleaze_protestors, lynyrd_protestors));
		if (best_protestors == lynyrd_protestors)
		{
			run_choice(2);
		}
		else if (best_protestors == sleaze_protestors)
		{
			run_choice(1);
		}
		else if (best_protestors == fire_protestors)
		{
			run_choice(3);
		}
	}
	else if (choice == 1433) // Sneaky Sneaky (The Hippy Camp (Verge of War))
	{
		run_choice(3); // start the war
	}
	else if (choice == 1434) // Sneaky Sneaky (Orcish Frat House (Verge of War))
	{
		run_choice(2); // start the war
	}
	else if (choice == 1435) // Leading Yourself Right to Them (Map the Monsters)
	{
		monster enemy = auto_monsterToMap(my_location());
		if (enemy != $monster[none])
		{
			handleTracker($skill[Map the Monsters], enemy, "auto_otherstuff");
			run_choice(1, `heyscriptswhatsupwinkwink={enemy.to_int()}`);
		}
		else
		{
			abort("trying to map a monster but don't know which monster to map!");
		}
	}
	else if (choice == 1436) // Billiards Room Options (The Haunted Billiards Room)
	{
		if (poolSkillPracticeGains() == 1 || currentPoolSkill() > 15)
		{
			run_choice(2);		//try to win the key. on failure still gain 1 pool skill
		}
		else
		{
			run_choice(1);		//acquire the pool cue
		}
	}
	else
	{
		abort("unhandled choice in cartographyChoiceHandler");
	}
}

boolean auto_hasRetrocape()
{
	return possessEquipment($item[unwrapped knock-off retro superhero cape]) && auto_is_valid($item[unwrapped knock-off retro superhero cape]);
}

boolean auto_configureRetrocape(string hero, string tag)
{
	if (!auto_hasRetrocape())
	{
		return false;
	}

	// store the requested settings in a property so we can handle them later
	string settings = hero + "," + tag;
	set_property("auto_retrocapeSettings", settings);

	// cut down potential server hits by telling the maximizer to not consider it.
	addToMaximize("-equip unwrapped knock-off retro superhero cape");
	return true;
}

boolean auto_handleRetrocape()
{
	if (!auto_hasRetrocape())
	{
		return false;
	}

	string settingsProperty = get_property("auto_retrocapeSettings");
	if (settingsProperty == "")
	{
		return false;
	}

	string[int] settings = split_string(settingsProperty, ",");
	if (count(settings) != 2)
	{
		return false;
	}

	string hero = settings[0];
	string tag = settings[1];

	if (hero != "muscle" &&
			hero != "mysticality" &&
			hero != "moxie" &&
			hero != "vampire" &&
			hero != "heck" &&
			hero != "robot")
	{
		return false;
	}
	if (tag != "hold" &&
			tag != "thrill" &&
			tag != "kiss" &&
			tag != "kill")
	{
		return false;
	}
	string tempHero = hero;
	if (hero == "muscle")
	{
		tempHero = "vampire";
	}
	if (hero == "mysticality")
	{
		tempHero = "heck";
	}
	if (hero == "moxie")
	{
		tempHero = "robot";
	}

	// avoid uselessly reconfiguring the cape
	if (get_property("retroCapeSuperhero") != tempHero || get_property("retroCapeWashingInstructions") != tag)
	{
		// retrocape [muscle | mysticality | moxie | vampire | heck | robot] [hold | thrill | kiss | kill]
		cli_execute(`retrocape {tempHero} {tag}`); // configures and equips
	}
	else
	{
		equip($item[unwrapped knock-off retro superhero cape]); // already configured, just equip
	}
	return get_property("retroCapeSuperhero") == tempHero && get_property("retroCapeWashingInstructions") == tag && have_equipped($item[unwrapped knock-off retro superhero cape]);
}

boolean auto_buyCrimboCommerceMallItem()
{
	if (!auto_is_valid($familiar[Ghost of Crimbo Commerce]))
	{
		return false;
	}

	string ghostItemString = get_property("commerceGhostItem");
	if (ghostItemString == "")
	{
		// haven't triggered the greedy ghost message at least once yet.
		return false;
	}

	if (get_property("auto_boughtCommerceGhostItem") == ghostItemString)
	{
		// already bought the item.
		return false;
	}

	auto_log_info(`Commerce Ghost wants us to buy a {ghostItemString} which will give us roughly {my_level()*25} substats in the next combat with it.`);

	string output = cli_execute_output(`buy from mall [{ghostItemString.to_item().to_int()}]`);
	if (!output.contains_text("Purchases complete."))
	{
		abort(`Something went wrong buying {ghostItemString} from the mall.`);
	}
	else
	{
		set_property("auto_boughtCommerceGhostItem", ghostItemString);
	}
	return true;
}
