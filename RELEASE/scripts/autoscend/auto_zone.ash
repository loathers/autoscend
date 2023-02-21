//All functions should fail if the king is liberated?
//Zone functions come here.

boolean zone_unlock(location loc){

	boolean unlocked = false;
	if(loc == $location[The Thinknerd Warehouse]){
		unlocked = LX_unlockThinknerdWarehouse(false);
	} else{
		auto_log_debug("Don't know how to unlock " + loc);
		return false;
	}

	if(!unlocked){
		auto_log_debug("Wasnt able to unlock " + loc);
	}

	return unlocked;
}

boolean zone_isAvailable(location loc, boolean unlockIfPossible){

	if(zone_available(loc)){
		return true;
	}

	if(unlockIfPossible){
		zone_unlock(loc);
	}

	return zone_available(loc);
}

boolean zone_isAvailable(location loc)
{
	return zone_isAvailable(loc, true);
}

int[location] zone_delayable()
{
	int[location] retval;
	foreach loc in $locations[]
	{
		generic_t locValue = zone_delay(loc);
		if(locValue._boolean && zone_isAvailable(loc))
		{
			retval[loc] = locValue._int;
		}
	}
	return retval;
}

// generic_t is defined in autoscend_record.ash

generic_t zone_needItem(location loc)
{
	// attempting to list these in descending order in relation to the quest they relate to
	// (so L13 quest stuff first then L12 then L11 and so on).
	generic_t retval;
	float value = 0.0;
	switch(loc)
	{
	case $location[Hero\'s Field]:
		// bonus points cap at +400% item. Equivalent to a 20% item drop
		value = 20.0;
		break;
	case $location[The Hole in the Sky]:
		if (item_amount($item[Star]) < 8 || item_amount($item[Line]) < 7) {
			value = 30.0;
		}
		break;
	case $location[Frat House]:
	case $location[Hippy Camp]:
			value = 5.0;
		break;
	case $location[Wartime Frat House]:
		if (!possessOutfit("Frat Warrior Fatigues")
		&& !is_wearing_outfit("War Hippy Fatigues")) {	//already in the other war outfit means only there to start the war
			value = 5.0;
		}
		break;
	case $location[Wartime Hippy Camp]:
		if (!possessOutfit("War Hippy Fatigues")
		&& !is_wearing_outfit("Frat Warrior Fatigues")) {	//already in the other war outfit means only there to start the war
			value = 5.0;
		}
		break;
	case $location[The Battlefield (Frat Uniform)]:
	case $location[The Battlefield (Hippy Uniform)]:
			value = 5.0;
		break;
	case $location[The Hatching Chamber]:
	case $location[The Feeding Chamber]:
	case $location[The Royal Guard Chamber]:
		value = 10.0;
		break;
	case $location[The Oasis]:
		if(have_effect($effect[Ultrahydrated]) > 0)
		{
			value = 30.0;
		}
		break;
	case $location[The Middle Chamber]:
		value = 20.0;
		break;
	case $location[The Haunted Library]:
		if (item_amount($item[killing jar]) < 1 && (get_property("gnasirProgress").to_int() & 4) == 0 && get_property("desertExploration").to_int() < 100) {
			value = 10.0;
		}
		break;
	case $location[The Haunted Laundry Room]:
		value = 5.0 * (1.0 + get_property("auto_cabinetsencountered").to_float());
		break;
	case $location[The Haunted Wine Cellar]:
		value = 5.0 * (1.0 + get_property("auto_wineracksencountered").to_float());
		break;
	case $location[The Hidden Park]:
		if (get_property("hiddenTavernUnlock").to_int() < my_ascensions()) {
			value = 20.0;
		}
		break;
	case $location[The Hidden Bowling Alley]:
		if (item_amount($item[Bowling Ball]) == 0 && get_property("hiddenBowlingAlleyProgress").to_int() < 5) {
			value = 40.0;
		}
		break;
	case $location[The Hidden Temple]:
		//Only if we need stone wool manually for some reason.
		//Or via the semi-rare!		(100/50/20 for SR, 25 Sheep)
		if (have_effect($effect[Stone-Faced]) == 0) {
			value = 20.0;
		}
		break;
	case $location[The Black Forest]:
		if (!possessEquipment($item[blackberry galoshes])) {
			value = 20.0;
		}
		break;
	case $location[Inside the Palindome]:
		if (item_amount($item[Stunt Nuts]) == 0 && item_amount($item[Wet Stunt Nut Stew]) == 0) {
			value = 30.0;
		}
		break;
	case $location[Whitey\'s Grove]:
		if(((item_amount($item[Lion Oil]) == 0) || (item_amount($item[Bird Rib]) == 0)) && (item_amount($item[Wet Stew]) == 0) && (item_amount($item[Wet Stunt Nut Stew]) == 0) && (internalQuestStatus("questL11Palindome") < 5))
		{
			value = 25.0;
		}
		break;
	case $location[The Copperhead Club]:
	case $location[A Mob of Zeppelin Protesters]:
		if(internalQuestStatus("questL11Ron") >= 1) {
			value = 15.0;
		}
		break;
	case $location[The Red Zeppelin]:
		value = 30.0;
		break;
	case $location[The Penultimate Fantasy Airship]:
		if(!possessEquipment($item[Amulet Of Extreme Plot Significance]))
		{
			value = 10.0;
		}
		if(!possessEquipment($item[Mohawk Wig]))
		{
			value = 10.0;
		}
		break;
	case $location[The Castle in the Clouds in the Sky (Basement)]:
		value = 40.0;
		break;
	case $location[The Castle in the Clouds in the Sky (Ground Floor)]:
		value = 20.0;
		break;
	case $location[The Smut Orc Logging Camp]:
		if(get_property("chasmBridgeProgress").to_int() < 30)
		{
			value = 10.0;
		}
		break;
	case $location[A-Boo Peak]:
		if(get_property("auto_aboopending").to_int() == 0)
		{
			value = 15.0;
		}
		break;
	case $location[Twin Peak]:
		value = 15.0;
		break;
	case $location[Oil Peak]:
		if ((get_property("twinPeakProgress").to_int() & 4) == 0 && item_amount($item[Bubblin\' Crude]) < 12 && item_amount($item[Jar Of Oil]) < 1) {
			if (monster_level_adjustment() > 100) {
				value = 10.0;
			} else if(monster_level_adjustment() > 50) {
				value = 30.0;
			} else if (monster_level_adjustment() > 20) {
				value = 10.0;
			}
		}
		break;
	case $location[The Valley of Rof L\'m Fao]:
		if(item_amount($item[lowercase N]) == 0 && item_amount($item[ND]) == 0 && item_amount($item[Wand of Nagamar]) == 0 && get_property("auto_wandOfNagamar").to_boolean())
		{
			value = 30.0;
		}
	case $location[Itznotyerzitz Mine]:
		if (!possessOutfit("Mining Gear") && cloversAvailable() == 0)
		{
			value = 10.0;
		}
		break;
	case $location[The Goatlet]:
		boolean getMilk = (have_skill($skill[Advanced Saucecrafting]) || (my_class() == $class[Sauceror] && (guild_available() || !get_property('auto_skipUnlockGuild').to_boolean()))) && fullness_limit() != 0;
		int milksPerMilk = (my_class() == $class[Sauceror]) ? 3 : 1;
		int milkUsed = (get_property("_milkOfMagnesiumUsed").to_boolean() || fullness_left() == 0) ? 1 : 0;
		if((item_amount($item[Milk Of Magnesium]) + milksPerMilk * item_amount($item[Glass Of Goat\'s Milk]) + milkUsed) >= 3)
		{	
			getMilk = false;
		}
		if(getMilk)
		{
			value = 20.0;
		}
		else
		{
			value = 40.0;
		}
		break;
	case $location[The Extreme Slope]:
		if(!possessOutfit("eXtreme Cold-Weather Gear"))
		{
			value = 10.0;
		}
	case $location[The Defiled Nook]:
		// Handle for a gravy boat?
		if(get_property("cyrptNookEvilness").to_int() > 14)
		{
			value = 20.0;
		}
		break;
	case $location[The Dark Neck of the Woods]:
	case $location[The Dark Heart of the Woods]:
	case $location[The Dark Elbow of the Woods]:
	case $location[Pandamonium Slums]:
		if(LX_doingPirates() && item_amount($item[hot wing]) < 3 && internalQuestStatus("questM12Pirate") <= 2)
		{
			value = 30;
		}
		break;
	case $location[Cobb\'s Knob Barracks]:
		if(!have_outfit("Knob Goblin Elite Guard Uniform"))
		{
			value = 10.0;
		}
		break;
	case $location[Cobb\'s Knob Harem]:
		if(item_amount($item[Knob Goblin Perfume]) == 0)
		{
			value = 25.0;
		}
		if (!possessOutfit("Knob Goblin Harem Girl Disguise")) {
			value = 20.0;
		}
		break;
	case $location[The Beanbat Chamber]:
		if(item_amount($item[Enchanted Bean]) == 0)
		{
			value = 50.0;
		}
		if(internalQuestStatus("questL04Bat") < 3)
		{
			value = 10.0;
		}
		break;
	case $location[The Batrat And Ratbat Burrow]:
		if(internalQuestStatus("questL04Bat") < 3)
		{
			value = 15.0;
		}
		break;
	case $location[The Bat Hole Entrance]:
	case $location[Guano Junction]:
		if(internalQuestStatus("questL04Bat") < 3)
		{
			value = 10.0;
		}
		break;
	case $location[The Laugh Floor]:
		if(item_amount($item[Imp Air]) < 5)
		{
			value = 15.0;
		}
		break;
	case $location[Infernal Rackets Backstage]:
		if(item_amount($item[Bus Pass]) < 5)
		{
			value = 15.0;
		}
		break;
	case $location[Barrrney\'s Barrr]:
		if(item_amount($item[Cocktail Napkin]) == 0)
		{
			value = 10.0;
		}
		break;
	case $location[The F\'c\'le]:
		if (item_amount($item[Ball Polish]) == 0 || item_amount($item[Mizzenmast Mop]) == 0 || item_amount($item[Rigging Shampoo]) == 0) {
			if (!possessEquipment($item[pirate fledges])) {
				value = 30.0;
			}
		}
		break;
	case $location[The Obligatory Pirate\'s Cove]:
		if(!possessOutfit("Swashbuckling Getup") && !possessEquipment($item[pirate fledges])) {
			value = 10.0;
		}
	case $location[The Old Landfill]:
		value = 5.0 * (1.0 + get_property("auto_junkspritesencountered").to_float());
		break;
	case $location[The Deep Machine Tunnels]:
		value = 30.0;			#Just a guess.
		break;
	case $location[Barf Mountain]:
		retval._float = 15.0;
		break;
	case $location[The Velvet / Gold Mine]:
		if(!canYellowRay())
		{	//Just a guess
			retval._float = 10.0;
		}
		break;
	case $location[The Haunted Pantry]:
		if(in_community() && (item_amount($item[Tomato]) < 2) && have_skill($skill[Advanced Saucecrafting]))
		{
			retval._float = 59.4;
		}
		break;
	case $location[The Skeleton Store]:
		if(in_community() && have_skill($skill[Advanced Saucecrafting]) && ((item_amount($item[Cherry]) < 1) || (item_amount($item[Grapefruit]) < 1) || (item_amount($item[Lemon]) < 1)))
		{	//No idea, should spade this for great justice.
			retval._float = 33.0;
		}
		break;
	case $location[The Secret Government Laboratory]:
		if(in_community() && (item_amount($item[Experimental Serum G-9]) < 2))
		{	//No idea, assume it is low.
			retval._float = 10.0;
		}
		break;
	// Bugbear Invasion Locations
	case $location[Waste Processing]:
		if (!possessEquipment($item[bugbear communicator badge]))
		{
			retval._float = 20.0;
		}
		break;
	case $location[Science Lab]:
		retval._float = 30.0;
		break;
	case $location[Engineering]:
		retval._float = 50.0;
		break;
	// End Bugbear Invasion Locations
	default:
		retval._error = true;
		break;
	}

	if(expectGhostReport() && (loc == get_property("ghostLocation").to_location()) && (get_property("questPAGhost") == "started"))
	{
		value = 0.0;
	}


	if(value != 0.0)
	{
		retval._boolean = true;
		retval._float = 10000.0/value;

		if(in_lar())
		{
			retval._float = 5000.0/value;
		}
		retval._float -= 100.0;
	}
	return retval;
}

generic_t zone_needItemBooze(location loc)
{
	// these matching a location case in zone_needItem will be called if the general item bonus could not be reached
	generic_t retval;
	float value = 0.0;
	switch(loc)
	{
	case $location[The Haunted Wine Cellar]:
		value = 5.0 * (1.0 + get_property("auto_wineracksencountered").to_float());
		break;
	default:
		retval._error = true;
		break;
	}

	if(expectGhostReport() && (loc == get_property("ghostLocation").to_location()) && (get_property("questPAGhost") == "started"))
	{
		value = 0.0;
	}


	if(value != 0.0)
	{
		retval._boolean = true;
		retval._float = 10000.0/value;

		if(in_lar())
		{
			retval._float = 5000.0/value;
		}
		retval._float -= 100.0;
	}
	return retval;
}

generic_t zone_needItemFood(location loc)
{
	// these matching a location case in zone_needItem will be called if the general item bonus could not be reached
	generic_t retval;
	float value = 0.0;
	switch(loc)
	{
	case $location[The Haunted Laundry Room]:
		value = 5.0 * (1.0 + get_property("auto_cabinetsencountered").to_float());
		break;
	case $location[Inside the Palindome]:
		if (item_amount($item[Stunt Nuts]) == 0 && item_amount($item[Wet Stunt Nut Stew]) == 0) {
			value = 30.0;
		}
		break;
	case $location[Whitey\'s Grove]:
		if(((item_amount($item[Lion Oil]) == 0) || (item_amount($item[Bird Rib]) == 0)) && (item_amount($item[Wet Stew]) == 0) && (item_amount($item[Wet Stunt Nut Stew]) == 0) && (internalQuestStatus("questL11Palindome") < 5))
		{
			value = 25.0;
		}
		break;
	case $location[The Goatlet]:
		boolean getMilk = (have_skill($skill[Advanced Saucecrafting]) || (my_class() == $class[Sauceror] && (guild_available() || !get_property('auto_skipUnlockGuild').to_boolean()))) && fullness_limit() != 0;
		int milksPerMilk = (my_class() == $class[Sauceror]) ? 3 : 1;
		int milkUsed = (get_property("_milkOfMagnesiumUsed").to_boolean() || fullness_left() == 0) ? 1 : 0;
		if((item_amount($item[Milk Of Magnesium]) + milksPerMilk * item_amount($item[Glass Of Goat\'s Milk]) + milkUsed) >= 3)
		{	
			getMilk = false;
		}
		if(getMilk)
		{
			value = 20.0;
		}
		else
		{
			value = 40.0;
		}
		break;
	case $location[The Dark Neck of the Woods]:
	case $location[The Dark Heart of the Woods]:
	case $location[The Dark Elbow of the Woods]:
	case $location[Pandamonium Slums]:
		if(LX_doingPirates() && item_amount($item[hot wing]) < 3 && internalQuestStatus("questM12Pirate") <= 2)
		{
			value = 30;
		}
		break;
	case $location[The Haunted Pantry]:
		if(in_community() && (item_amount($item[Tomato]) < 2) && have_skill($skill[Advanced Saucecrafting]))
		{
			retval._float = 59.4;
		}
		break;
	case $location[The Skeleton Store]:
		if(in_community() && have_skill($skill[Advanced Saucecrafting]) && ((item_amount($item[Cherry]) < 1) || (item_amount($item[Grapefruit]) < 1) || (item_amount($item[Lemon]) < 1)))
		{	//No idea, should spade this for great justice.
			retval._float = 33.0;
		}
		break;
	default:
		retval._error = true;
		break;
	}

	if(expectGhostReport() && (loc == get_property("ghostLocation").to_location()) && (get_property("questPAGhost") == "started"))
	{
		value = 0.0;
	}


	if(value != 0.0)
	{
		retval._boolean = true;
		retval._float = 10000.0/value;

		if(in_lar())
		{
			retval._float = 5000.0/value;
		}
		retval._float -= 100.0;
	}
	return retval;
}

generic_t zone_combatMod(location loc)
{
	// attempting to list these in descending order in relation to the quest they relate to
	// (so L13 quest stuff first then L12 then L11 and so on).
	generic_t retval;
	generic_t delay = zone_delay(loc);
	int value = 0;
	switch(loc)
	{
	case $location[Frat House]:
	case $location[Hippy Camp]:
		if (my_level() >= 9) {
			value = -85;
		}
		break;
	case $location[Wartime Frat House]:
	case $location[Wartime Hippy Camp]:
		value = -80;
		break;
	case $location[Sonofa Beach]:
		//when wanderer replacing strategy is about to be used, combat modifier is useless. these are the replaced wanderers
		if(auto_voteMonster())
		{	foreach sl in $slots[acc3,acc2,acc1]
			{	if(get_property("_auto_maximize_equip_" + sl.to_string()) == to_string($item[&quot;I voted!&quot; sticker]))
				{	value = 0;
					break;
				}
			}
		}
		if(auto_sausageGoblin() && get_property("_auto_maximize_equip_off-hand") == to_string($item[Kramco Sausage-o-Matic&trade;]))
		{	value = 0;
			break;
		}
		//otherwise if no wanderer replace
		value = 90;
		break;
	case $location[The Upper Chamber]:
		value = -85;
		break;
	case $location[The Haunted Billiards Room]:
		value = -85;
		break;
	case $location[The Haunted Gallery]:
		if((delay._int == 0) || (!contains_text(get_property("relayCounters"), "Garden Banished")))
		{
			value = -80;
		}
		break;
	case $location[The Haunted Bathroom]:
		if(delay._int == 0)
		{
			value = -90;
		}
		break;
	case $location[The Haunted Ballroom]:
		if((delay._int == 0) && (loc.turns_spent > 0))
		{
			value = -90;
		}
		break;
	case $location[The Hidden Park]:
		value = -85;
		break;
	case $location[The Hidden Temple]:
		if (have_effect($effect[Stone-Faced]) == 0) {
			value = -90;
		}
		break;
	case $location[A Mob Of Zeppelin Protesters]:
		if(internalQuestStatus("questL11Ron") >= 1) {
			value = -70;
		}
		break;
	case $location[The Black Forest]:
		if (internalQuestStatus("questL13Final") < 6) {
			value = 5;
		} else if (internalQuestStatus("questL13Final") == 6) {
			value = -95;
		}
		break;
	case $location[Inside the Palindome]:
		if(((item_amount($item[Photograph Of A Red Nugget]) == 0) || (item_amount($item[Photograph Of An Ostrich Egg]) == 0) || (item_amount($item[Photograph Of God]) == 0)) && internalQuestStatus("questL11Palindome") <= 2)
		{
			value = -70;
		}
		else if (3 <= internalQuestStatus("questL11Palindome") && internalQuestStatus("questL11Palindome") <= 4)
		{
			value = 25;
		}
		break;
	case $location[Whitey\'s Grove]:
		if(((item_amount($item[Lion Oil]) == 0) || (item_amount($item[Bird Rib]) == 0)) && (item_amount($item[Wet Stew]) == 0) && (item_amount($item[Wet Stunt Nut Stew]) == 0) && (internalQuestStatus("questL11Palindome") < 5))
		{
			value = 15;
		}
		break;
	case $location[The Penultimate Fantasy Airship]:
		if(delay._int == 0)
		{
			value = -80;
		}
		else
		{
			//Let us not worry about throttling the Airship
			#value = 20;
		}
		break;
	case $location[The Castle in the Clouds in the Sky (Basement)]:
	case $location[The Castle in the Clouds in the Sky (Ground Floor)]:
	case $location[The Castle in the Clouds in the Sky (Top Floor)]:
		value = -95;
		break;
	case $location[Twin Peak]:
		value = -85;
		break;
	case $location[The Extreme Slope]:
		value = -95;
		break;
	case $location[Itznotyerzitz Mine]:
		if (!possessOutfit("Mining Gear") && cloversAvailable() == 0) {
			value = -90;
		}
		break;
	case $location[Lair of the Ninja Snowmen]:
		if(internalQuestStatus("questL08Trapper") < 3 &&
		(item_amount($item[Ninja Carabiner]) == 0 || item_amount($item[Ninja Crampons]) == 0 || item_amount($item[Ninja Rope]) == 0))
		{
			value = 80;
		}
		break;
	case $location[The Dark Neck of the Woods]:
	case $location[The Dark Heart of the Woods]:
	case $location[The Dark Elbow of the Woods]:
		value = -95;
		break;
	case $location[The Defiled Cranny]:
	case $location[The Defiled Alcove]:
		value = -85;
		break;
	case $location[The Outskirts of Cobb\'s Knob]:
		value = 20;
		break;
	case $location[The Typical Tavern Cellar]:
		//We could cut it off early if the Rat Faucet is the last one
		//And marginally if we know the 3rd/6th square are forced events.
		//actual desired value for combat or non combat is decided by level_03.ash based on elemental damage bonus
		break;
	case $location[The Spooky Forest]:
		if(delay._int == 0)
		{
			value = -85;
		}
		break;
	case $location[The Laugh Floor]:
		if (item_amount($item[Azazel's lollipop]) < 1) {
			value = 15.0;
		}
		break;
	case $location[Infernal Rackets Backstage]:
		if (item_amount($item[Azazel's unicorn]) < 1) {
			value = -70;
		}
		break;
	case $location[Barrrney\'s Barrr]:
		if (numPirateInsults() >= 6) {
			value = -80;
		} else {
			value = 20;
		}
		break;
	case $location[The F\'c\'le]:
		if(!possessEquipment($item[pirate fledges]))
		{
			value = 20;
		}
		break;
	case $location[The Poop Deck]:
		value = -80;
		break;
	case $location[The Obligatory Pirate\'s Cove]:
		if(!possessOutfit("Swashbuckling Getup")) {
			if(item_amount($item[The Big Book Of Pirate Insults]) > 0 && numPirateInsults() < 3) {
				value = 0; // fights can give both outfit pieces and insults. better not start avoiding fights until first insults learned
			} else {
				value = -60;
			}
		} else if (numPirateInsults() < 8) {
			value = 40;
		}
		break;
	case $location[The Knob Shaft]:
		value = 15;
		break;
	case $location[South of The Border]:
		value = 50;
		break;
	case $location[The Icy Peak]:
		value = 15;
		break;
	case $location[Pandamonium Slums]:
		value = 5;
		break;
	case $location[The Haunted Pantry]:
		value = 20;
		break;
	case $location[Cobb\'s Knob Treasury]:
		value = 15;
		break;
	case $location[The VERY Unquiet Garves]:
		if (item_amount($item[Wand of Nagamar]) == 0 && internalQuestStatus("questL13Final") == 12 && !in_koe()) {
			value = -100;
		}
		break;
	case $location[Super Villain\'s Lair]:
		if(!get_property("_villainLairColorChoiceUsed").to_boolean() || !get_property("_villainLairDoorChoiceUsed").to_boolean() || !get_property("_villainLairSymbologyChoiceUsed").to_boolean())
		{
			value = -70;
		}
		break;
	case $location[Through the Spacegate]:
		value = 5;
		break;
	case $location[The Ice Hotel]:
		value = -85;
		break;
	// Bugbear Invasion Locations
	case $location[Sonar]:
		value = -70;
		break;
	case $location[Morgue]:
		if (item_amount($item[bugbear autopsy tweezers]) > 0)
		{
			value = -70;
		}
		break;
	// End Bugbear Invasion Locations
	default:
		retval._error = true;
		break;
	}

	if(in_lar())
	{
		value = 0;
	}

	if(expectGhostReport() && (loc == get_property("ghostLocation").to_location()) && (get_property("questPAGhost") == "started"))
	{
		value = 0;
	}


	if(value != 0)
	{
		retval._boolean = true;
		retval._int = value;
	}
	return retval;
}

generic_t zone_delay(location loc)
{
	generic_t retval;
	int value = 0;
	int[location] shenZones = getShenZonesTurnsSpent();
	switch(loc)
	{
	case $location[The Oasis]:
		// Superlikely adventures take priority over all wanderers now.
		if(get_property("desertExploration").to_int() < 100 && have_effect($effect[Ultrahydrated]) > 0)
		{
			value = 5 - loc.turns_spent;
		}
		break;
	case $location[The Upper Chamber]:
		value = 5 - loc.turns_spent;
		break;
	case $location[The Middle Chamber]:
		value = 10 - loc.turns_spent;
		break;
	case $location[The Haunted Gallery]:
		value = 5 - loc.turns_spent;
		break;
	case $location[The Haunted Bathroom]:
		value = 5 - loc.turns_spent;
		break;
	case $location[The Haunted Ballroom]:
		value = 5 - loc.turns_spent;
		break;
	case $location[The Hidden Park]:
		if(!possessEquipment($item[Antique Machete]) && !possessEquipment($item[Muculent Machete]) && in_hardcore())
		{
			value = 6 - loc.turns_spent;
		}
		break;
	case $location[The Hidden Apartment Building]:
		if (internalQuestStatus("questL11Curses") < 2) {
			if (loc.turns_spent < 9) {
				value = 8 - loc.turns_spent;
			} else {
				value = 7 - (loc.turns_spent - 9) % 8;
			}
		}
		break;
	case $location[The Hidden Office Building]:
		if (internalQuestStatus("questL11Business") < 2) {
			if (loc.turns_spent < 6) {
				value = 5 - loc.turns_spent;
			} else {
				value = 4 - (loc.turns_spent - 6) % 5;
			}
		}
		break;
	case $location[The Spooky Forest]:
		value = 5 - loc.turns_spent;
		break;
	case $location[The Boss Bat\'s Lair]:
		value = 4 - loc.turns_spent;
		break;
	case $location[The Outskirts of Cobb\'s Knob]:
		if (internalQuestStatus("questL05Goblin") < 1)
		{
			value = 10 - loc.turns_spent;
		}
		else
		{
			retval._error = true;
		}
		break;
	case $location[The Penultimate Fantasy Airship]:
		if(get_property("questL10Garbage") == "step2")
		{
			value = 5 - loc.turns_spent;
		}
		else if(get_property("questL10Garbage") == "step3")
		{
			value = 10 - loc.turns_spent;
		}
		else if(get_property("questL10Garbage") == "step4")
		{
			value = 15 - loc.turns_spent;
		}
		else if(get_property("questL10Garbage") == "step5")
		{
			value = 20 - loc.turns_spent;
		}
		else if(get_property("questL10Garbage") == "step6")
		{
			value = 25 - loc.turns_spent;
		}
		break;
	case $location[The Castle in the Clouds in the Sky (Ground Floor)]:
		value = 10 - loc.turns_spent;
		break;
	case $location[The Haunted Pantry]:
		if (isGuildClass() && my_primestat() == $stat[mysticality] && !get_property('auto_skipUnlockGuild').to_boolean())
		{
			value = 5 - loc.turns_spent;
		}
		break;
	case $location[The Sleazy Back Alley]:
		if (isGuildClass() && my_primestat() == $stat[moxie] && !get_property('auto_skipUnlockGuild').to_boolean())
		{
			value = 5 - loc.turns_spent;
		}
		break;
	case $location[The Smut Orc Logging Camp]:
		if (shenZones contains loc && get_property("chasmBridgeProgress").to_int() >= 30)
		{
			value = 3 - (loc.turns_spent - shenZones[loc]);
		}
		break;
	case $location[The Hole in the Sky]:
		if (shenZones contains loc && !needStarKey())
		{
			value = 3 - (loc.turns_spent - shenZones[loc]);
		}
		break;
	case $location[The Unquiet Garves]:
	case $location[The Castle in the Clouds in the Sky (Top Floor)]:
	case $location[Lair of the Ninja Snowmen]:
	case $location[The Batrat and Ratbat Burrow]:
		if (shenZones contains loc)
		{
			value = 3 - (loc.turns_spent - shenZones[loc]);
		}
		break;
	case $location[The Copperhead Club]:
		if (internalQuestStatus("questL11Shen") > 0 && internalQuestStatus("questL11Shen") < 8)
		{
			value = 5 - (loc.turns_spent - get_property("auto_lastShenTurn").to_int());
		}
		break;
	case $location[The Hallowed Halls]:
	case $location[Art Class]:
	case $location[Chemistry Class]:
	case $location[Shop Class]:
		if(kolhs_mandatorySchool())		//KOLHS path specific delay locations
		{
			value = 40 - get_property("_kolhsAdventures").to_int();		//shared counter of 40 adv between all 4 zones
		}
		break;
	default:
		retval._error = true;
		break;
	}

	if(value > 0)
	{
		retval._boolean = true;
		retval._int = value;
	}
	return retval;
}

boolean zone_available(location loc)
{
	boolean retval = false;
	
	if(kolhs_mandatorySchool())		//kolhs path specifically blocks non school zones until school is done.
	{
		if($locations[The Hallowed Halls, Art Class, Chemistry Class, Shop Class] contains loc)
		{
			retval = true;
		}
		return retval;
	}

	switch(loc)
	{
	case $location[The Copperhead Club]:
	case $location[A Mob Of Zeppelin Protesters]:
		if(internalQuestStatus("questL11Shen") >= 0)
		{
			retval = true;
		}
		break;
	case $location[The Red Zeppelin]:
		if(internalQuestStatus("questL11Ron") >= 2)
		{
			retval = true;
		}
		break;
	case $location[Super Villain\'s Lair]:
		if(in_lta() && (get_property("_villainLairProgress").to_int() < 999) && (get_property("_auto_bondBriefing") == "started"))
		{
			retval = true;
		}
		break;
	case $location[South of The Border]:
	case $location[The Shore\, Inc. Travel Agency]:
		if(isDesertAvailable())
		{
			retval = true;
		}
		break;
	case $location[The Arid\, Extra-Dry Desert]:
		if(internalQuestStatus("questL11Desert") >= 0)
		{
			retval = true;
		}
		break;
	case $location[The Oasis]:
		if($location[The Arid\, Extra-Dry Desert].turns_spent > 0)
		{
			retval = true;
		}
		break;
	case $location[The Upper Chamber]:
		if(internalQuestStatus("questL11Pyramid") >= 0)
		{
			retval = true;
		}
		break;
	case $location[The Middle Chamber]:
		retval = get_property("middleChamberUnlock").to_boolean();
		break;
	case $location[The Lower Chambers]:
		retval = get_property("lowerChamberUnlock").to_boolean();
		break;
	case $location[The Daily Dungeon]:
		retval = !get_property("dailyDungeonDone").to_boolean();
		break;
	case $location[The Overgrown Lot]:
		if(internalQuestStatus("questM24Doc") >= 0)
		{
			retval = true;
		}
		break;
	case $location[The Skeleton Store]:
		if(internalQuestStatus("questM23Meatsmith") >= 0)
		{
			retval = true;
		}
		break;
	case $location[Madness Bakery]:		//can also be unlocked via hypnotic breadcrumbs. which matter in koe and nuclear autumn. but currently not tracked
		if(internalQuestStatus("questM25Armorer") >= 0)
		{
			retval = true;
		}
		break;
	case $location[The Deep Machine Tunnels]:
		if(have_familiar($familiar[Machine Elf]) || (have_effect($effect[Inside The Snowglobe]) > 0))
		{
			retval = true;
		}
		break;
	case $location[The Haunted Pantry]:
	case $location[The Haunted Kitchen]:
	case $location[The Haunted Conservatory]:
		if(internalQuestStatus("questM20Necklace") >= 0)
		{
			retval = true;
		}
		break;
	case $location[The Haunted Gallery]:
	case $location[The Haunted Bathroom]:
	case $location[The Haunted Bedroom]:
		if(internalQuestStatus("questM21Dance") >= 1)
		{
			retval = true;
		}
		break;
	case $location[The Haunted Billiards Room]:
		if(item_amount($item[Spookyraven Billiards Room Key]) > 0)
		{
			retval = true;
		}
		break;
	case $location[The Haunted Library]:
		if(item_amount($item[[7302]Spookyraven Library Key]) > 0)
		{
			retval = true;
		}
		break;
	case $location[The Haunted Ballroom]:
		if(internalQuestStatus("questM21Dance") >= 3)
		{
			retval = true;
		}
		break;
	case $location[The Haunted Boiler Room]:
	case $location[The Haunted Laundry Room]:
	case $location[The Haunted Wine Cellar]:
		if(internalQuestStatus("questL11Manor") >= 1)
		{
			retval = true;
		}
		break;
	case $location[Summoning Chamber]:
		if(internalQuestStatus("questL11Manor") >= 11)
		{
			retval = true;
		}
		break;
	case $location[The Hidden Park]:
	case $location[An Overgrown Shrine (Northwest)]:
	case $location[An Overgrown Shrine (Southwest)]:
	case $location[An Overgrown Shrine (Northeast)]:
	case $location[An Overgrown Shrine (Southeast)]:
	case $location[A Massive Ziggurat]:
		if(internalQuestStatus("questL11Worship") >= 3)
		{
			retval = true;
		}
		break;
	case $location[The Hidden Apartment Building]:
		if(internalQuestStatus("questL11Curses") >= 0)
		{
			retval = true;
		}
		break;
	case $location[The Hidden Hospital]:
		if(internalQuestStatus("questL11Doctor") >= 0)
		{
			retval = true;
		}
		break;
	case $location[The Hidden Office Building]:
		if(internalQuestStatus("questL11Business") >= 0)
		{
			retval = true;
		}
		break;
	case $location[The Hidden Bowling Alley]:
		if(internalQuestStatus("questL11Spare") >= 0)
		{
			retval = true;
		}
		break;
	case $location[The Typical Tavern Cellar]:
		if(internalQuestStatus("questL03Rat") >= 0)
		{
			retval = true;
		}
		break;
	case $location[The Spooky Forest]:
		if((internalQuestStatus("questL02Larva") >= 0) || (internalQuestStatus("questG02Whitecastle") >= 0))
		{
			retval = true;
		}
		break;
	case $location[The Hidden Temple]:
		if(get_property("lastTempleUnlock").to_int() == my_ascensions())
		{
			retval = true;
		}
		break;
	case $location[Vanya\'s Castle]:
	case $location[The Fungus Plains]:
	case $location[Megalo-City]:
	case $location[Hero\'s Field]:
		if(possessEquipment($item[Continuum Transfunctioner]) && ((internalQuestStatus("questL02Larva") >= 0) || (internalQuestStatus("questG02Whitecastle") >= 0)))
		{
			retval = true;
		}
		break;
	case $location[The Black Forest]:
		if(internalQuestStatus("questL11MacGuffin") >= 0)
		{
			retval = true;
		}
		break;
	case $location[The Bat Hole Entrance]:
		if(internalQuestStatus("questL04Bat") >= 0)
		{
			retval = true;
		}
		break;
	case $location[Guano Junction]:
		if((elemental_resist($element[stench]) >= 1) && (internalQuestStatus("questL04Bat") >= 0))
		{
			retval = true;
		}
		break;
	case $location[The Batrat And Ratbat Burrow]:
		if(internalQuestStatus("questL04Bat") >= 1)
		{
			retval = true;
		}
		break;
	case $location[The Beanbat Chamber]:
		if(internalQuestStatus("questL04Bat") >= 2)
		{
			retval = true;
		}
		break;
	case $location[The Boss Bat\'s Lair]:
		if(internalQuestStatus("questL04Bat") == 3 )
		{
			retval = true;
		}
		break;
	case $location[The VERY Unquiet Garves]:
		if(get_property("questL07Cyrptic") == "finished")
		{
			retval = true;
		}
		break;
	case $location[Whitey\'s Grove]:
		if((internalQuestStatus("questG02Whitecastle") >= 0) || (internalQuestStatus("questL11Palindome") >= 3))
		{
			retval = true;
		}
		break;
	case $location[Inside the Palindome]:
		if(possessEquipment($item[Talisman O\' Namsilat]))
		{
			retval = true;
		}
		break;
	case $location[Noob Cave]:
	case $location[The Outskirts of Cobb\'s Knob]:
		retval = true;
		break;
	case $location[Cobb\'s Knob Barracks]:
	case $location[Cobb\'s Knob Kitchens]:
	case $location[Cobb\'s Knob Harem]:
	case $location[Cobb\'s Knob Treasury]:
	case $location[Throne Room]:
		if(internalQuestStatus("questL05Goblin") >= 1)
		{
			retval = true;
		}
		break;
	case $location[The Dark Neck of the Woods]:
	case $location[The Dark Heart of the Woods]:
	case $location[The Dark Elbow of the Woods]:
		if((internalQuestStatus("questL06Friar") >= 0) && (get_property("questL06Friar") != "finished"))
		{
			retval = true;
		}
		break;
	case $location[The Defiled Nook]:
	case $location[The Defiled Cranny]:
	case $location[The Defiled Alcove]:
	case $location[The Defiled Niche]:
		if(internalQuestStatus("questL07Cyrptic") >= 0)
		{
			retval = true;
		}
		break;
	case $location[Pandamonium Slums]:
	case $location[The Laugh Floor]:
	case $location[Infernal Rackets Backstage]:
		if(internalQuestStatus("questL06Friar") >= 10)
		{
			retval = true;
		}
		break;
	case $location[The Obligatory Pirate\'s Cove]:
		if(get_property("lastIslandUnlock").to_int() == my_ascensions())
		{
			if((get_property("questL12War") == "unstarted") || (get_property("questL12War") == "finished"))
			{
				retval = true;
			}
		}
		break;
	case $location[Barrrney\'s Barrr]:
		if((have_outfit("swashbuckling getup") || possessEquipment($item[Pirate Fledges])) && (get_property("lastIslandUnlock").to_int() == my_ascensions()))
		{
			if((get_property("questL12War") == "unstarted") || (get_property("questL12War") == "finished"))
			{
				retval = true;
			}
		}
		break;
	case $location[The F\'c\'le]:
		if((have_outfit("swashbuckling getup") || possessEquipment($item[Pirate Fledges])) && (get_property("lastIslandUnlock").to_int() == my_ascensions()) && (internalQuestStatus("questM12Pirate") >= 5))
		{
			if((get_property("questL12War") == "unstarted") || (get_property("questL12War") == "finished"))
			{
				retval = true;
			}
		}
		break;
	case $location[The Poop Deck]:
		if((have_outfit("swashbuckling getup") || possessEquipment($item[Pirate Fledges])) && (get_property("lastIslandUnlock").to_int() == my_ascensions()) && (internalQuestStatus("questM12Pirate") >= 6))
		{
			if((get_property("questL12War") == "unstarted") || (get_property("questL12War") == "finished"))
			{
				retval = true;
			}
		}
		break;
	case $location[Belowdecks]:
		if((have_outfit("swashbuckling getup") || possessEquipment($item[Pirate Fledges])) && (get_property("lastIslandUnlock").to_int() == my_ascensions()) && (get_property("questM12Pirate") == "finished"))
		{
			if((get_property("questL12War") == "unstarted") || (get_property("questL12War") == "finished"))
			{
				retval = true;
			}
		}
		break;
	case $location[The Smut Orc Logging Camp]:
		if(internalQuestStatus("questL09Topping") >= 0)
		{
			retval = true;
		}
		break;
	case $location[A-Boo Peak]:
	case $location[Twin Peak]:
	case $location[Oil Peak]:
		if(internalQuestStatus("questL09Topping") >= 1)
		{
			retval = true;
		}
		break;
	case $location[Frat House]:
	case $location[Hippy Camp]:
		if(get_property("lastIslandUnlock").to_int() == my_ascensions())
		{
			retval = true;
		}
		break;
	case $location[Frat House (Frat Disguise)]:
		if(get_property("lastIslandUnlock").to_int() == my_ascensions() && 
		have_outfit("Frat Boy Ensemble") &&
		internalQuestStatus("questL12War") != 0 &&	//mafia always calls location Wartime with L12 quest
		internalQuestStatus("questL12War") != 1)	//mafia always calls location Wartime with L12 quest
		{
			retval = true;
		}
		break;
	case $location[Hippy Camp (Hippy Disguise)]:
		if(get_property("lastIslandUnlock").to_int() == my_ascensions() && 
		have_outfit("Filthy Hippy Disguise") &&
		internalQuestStatus("questL12War") != 0 &&	//mafia always calls location Wartime with L12 quest
		internalQuestStatus("questL12War") != 1)	//mafia always calls location Wartime with L12 quest
		{
			retval = true;
		}
		break;
	case $location[Wartime Hippy Camp (Frat Disguise)]:
		if((internalQuestStatus("questL12War") == 0) && have_outfit("frat warrior fatigues"))
		{
			retval = true;
		}
		break;
	case $location[The Battlefield (Frat Uniform)]:
		if((internalQuestStatus("questL12War") >= 1) && (get_property("hippiesDefeated").to_int() < 1000) && have_outfit("frat warrior fatigues") && (get_property("questL12War") != "finished"))
		{
			retval = true;
		}
		break;
	case $location[Wartime Frat House (Hippy Disguise)]:
		if((internalQuestStatus("questL12War") == 0) && have_outfit("war hippy fatigues"))
		{
			retval = true;
		}
		break;
	case $location[The Battlefield (Hippy Uniform)]:
		if((internalQuestStatus("questL12War") >= 1) && (get_property("fratboysDefeated").to_int() < 1000) && have_outfit("war hippy fatigues") && (get_property("questL12War") != "finished"))
		{
			retval = true;
		}
		break;
	case $location[Next to that Barrel with Something Burning in it]:
	case $location[Near an Abandoned Refrigerator]:
	case $location[Over Where the Old Tires Are]:
	case $location[Out by that Rusted-Out Car]:
		if((internalQuestStatus("questL12War") >= 1) && (get_property("sidequestJunkyardCompleted") == "none" || get_property("flyeredML").to_int() < 10000) && (get_property("questL12War") != "finished"))
		{
			retval = true;
		}
		break;
	case $location[Sonofa Beach]:
		if(internalQuestStatus("questL12War") >= 1)
		{
			retval = true;
		}
		break;
	case $location[The Themthar Hills]:
		if((internalQuestStatus("questL12War") >= 1) && (get_property("sidequestNunsCompleted") == "none") && (get_property("questL12War") != "finished"))
		{
			retval = true;
		}
		break;
	case $location[The Hatching Chamber]:
		if((internalQuestStatus("questL12War") >= 1) && (get_property("sidequestOrchardCompleted") == "none") && (get_property("questL12War") != "finished"))
		{
			retval = true;
		}
		break;
	case $location[The Feeding Chamber]:
		if((internalQuestStatus("questL12War") >= 1) && (get_property("sidequestOrchardCompleted") == "none") && (have_effect($effect[Filthworm Larva Stench]) > 0) && (get_property("questL12War") != "finished"))
		{
			retval = true;
		}
		break;
	case $location[The Royal Guard Chamber]:
		if((internalQuestStatus("questL12War") >= 1) && (get_property("sidequestOrchardCompleted") == "none") && (have_effect($effect[Filthworm Drone Stench]) > 0) && (get_property("questL12War") != "finished"))
		{
			retval = true;
		}
		break;
	case $location[The Filthworm Queen\'s Chamber]:
		if((internalQuestStatus("questL12War") >= 1) && (get_property("sidequestOrchardCompleted") == "none") && (item_amount($item[Heart Of The Filthworm Queen]) == 0) && (have_effect($effect[Filthworm Guard Stench]) > 0) && (get_property("questL12War") != "finished"))
		{
			retval = true;
		}
		break;
	case $location[Itznotyerzitz Mine]:
	case $location[The Goatlet]:
		if(internalQuestStatus("questL08Trapper") >= 1)
		{
			retval = true;
		}
		break;
	case $location[The Extreme Slope]:
	case $location[Lair of the Ninja Snowmen]:
		if(internalQuestStatus("questL08Trapper") >= 2)
		{
			retval = true;
		}
		break;
	case $location[Mist-Shrouded Peak]:
		if(internalQuestStatus("questL08Trapper") >= 3)
		{
			retval = true;
		}
		break;
	case $location[The Icy Peak]:
		if(internalQuestStatus("questL08Trapper") >= 6)
		{
			retval = true;
		}
		break;
	case $location[The Penultimate Fantasy Airship]:
		if(internalQuestStatus("questL10Garbage") >= 1)
		{
			retval = true;
		}
		break;
	case $location[The Castle in the Clouds in the Sky (Basement)]:
		if(item_amount($item[S.O.C.K.]) > 0)
		{
			retval = true;
		}
		break;
	case $location[The Castle in the Clouds in the Sky (Ground Floor)]:
		if(get_property("lastCastleGroundUnlock").to_int() == my_ascensions())
		{
			retval = true;
		}
		break;
	case $location[The Castle in the Clouds in the Sky (Top Floor)]:
		if(get_property("lastCastleTopUnlock").to_int() == my_ascensions())
		{
			retval = true;
		}
		break;
	case $location[The Hole in the Sky]:
		if(item_amount($item[Steam-Powered Model Rocketship]) > 0 || in_koe())
		{
			retval = true;
		}
		break;
	case $location[The Tunnel of L.O.V.E.]:
		if(get_property("loveTunnelAvailable").to_boolean() && !get_property("_loveTunnelUsed").to_boolean())
		{
			retval = true;
		}
		break;
	case $location[Fastest Adventurer Contest]:
		if(get_property("nsContestants1").to_int() > 0)
		{
			retval = true;
		}
		break;
	case $location[The Enormous Greater-Than Sign]:
		if(get_property("lastPlusSignUnlock").to_int() < my_ascensions())
		{
			retval = true;
		}
		break;
	case $location[The Dungeons of Doom]:
		if(get_property("lastPlusSignUnlock").to_int() == my_ascensions())
		{
			retval = true;
		}
		break;
	case $location[The Limerick Dungeon]:
	case $location[The Sleazy Back Alley]:
	case $location[The Haiku Dungeon]:
		retval = true;
		break;
	case $location[Smartest Adventurer Contest]:
	case $location[Strongest Adventurer Contest]:
	case $location[Smoothest Adventurer Contest]:
		if(get_property("nsContestants2").to_int() > 0)
		{
			retval = true;
		}
		break;
	case $location[Coldest Adventurer Contest]:
	case $location[Hottest Adventurer Contest]:
	case $location[Sleaziest Adventurer Contest]:
	case $location[Spookiest Adventurer Contest]:
	case $location[Stinkiest Adventurer Contest]:
		if(get_property("nsContestants3").to_int() > 0)
		{
			retval = true;
		}
		break;

	case $location[Tower Level 1]:
		if(get_property("questL13Final") == "step6")
		{
			retval = true;
		}
		break;
	case $location[Tower Level 2]:
		if(get_property("questL13Final") == "step7")
		{
			retval = true;
		}
		break;
	case $location[Tower Level 3]:
		if(get_property("questL13Final") == "step8")
		{
			retval = true;
		}
		break;
	case $location[Tower Level 4]:
		if(get_property("questL13Final") == "step9")
		{
			retval = true;
		}
		break;
	case $location[Tower Level 5]:
		if(get_property("questL13Final") == "step10")
		{
			retval = true;
		}
		break;
	case $location[The Naughty Sorceress\' Chamber]:
		if(get_property("questL13Final") == "step11")
		{
			retval = true;
		}
		break;
	case $location[Barf Mountain]:
	case $location[Pirates of the Garbage Barges]:
	case $location[Uncle Gator\'s Country Fun-Time Liquid Waste Sluice]:
	case $location[The Toxic Teacups]:
		retval = get_property("stenchAirportAlways").to_boolean() || get_property("_stenchAirportToday").to_boolean();
		break;
	case $location[The Fun-Guy Mansion]:
	case $location[The Sunken Party Yacht]:
	case $location[Sloppy Seconds Diner]:
		retval = get_property("sleazeAirportAlways").to_boolean() || get_property("_sleazeAirportToday").to_boolean();
		break;
	case $location[The Secret Government Laboratory]:
	case $location[The Deep Dark Jungle]:
	case $location[The Mansion of Dr. Weirdeaux]:
		retval = get_property("spookyAirportAlways").to_boolean() || get_property("_spookyAirportToday").to_boolean();
		break;
	case $location[The Ice Hotel]:
	case $location[VYKEA]:
	case $location[The Ice Hole]:
		retval = get_property("coldAirportAlways").to_boolean() || get_property("_coldAirportToday").to_boolean();
		break;
	case $location[The SMOOCH Army HQ]:
	case $location[LavaCo&trade; Lamp Factory]:
	case $location[The Velvet / Gold Mine]:
	case $location[The Bubblin\' Caldera]:
		retval = get_property("hotAirportAlways").to_boolean() || get_property("_hotAirportToday").to_boolean();
		break;
	case $location[The X-32-F Combat Training Snowman]:
		retval = get_property("snojoAvailable").to_boolean();
		break;
	case $location[Through the Spacegate]:
		retval = get_property("spacegateAlways").to_boolean() || get_property("_spacegateToday").to_boolean();
		break;

	case $location[The Old Landfill]:
		if(internalQuestStatus("questM19Hippy") >= 0)
		{
			retval = true;
		}
		break;

	case $location[Cobb\'s Knob Laboratory]:
	case $location[The Knob Shaft]:
		if (item_amount($item[Cobb\'s Knob Lab Key]) > 0)
		{
			retval = true;
		}
		break;
	case $location[Cobb\'s Knob Menagerie, Level 1]:
	case $location[Cobb\'s Knob Menagerie, Level 2]:
	case $location[Cobb\'s Knob Menagerie, Level 3]:
		if (item_amount($item[Cobb\'s Knob Menagerie key]) > 0)
		{
			retval = true;
		}
		break;

	case $location[The Red Queen\'s Garden]:
		if(have_effect($effect[Down the Rabbit Hole]) > 0)
		{
			retval = true;
		}
		break;

	case $location[The Bugbear Pen]:
		if(internalQuestStatus("questM03Bugbear") >= 0)
		{
			retval = true;
		}
		break;
	case $location[The Spooky Gravy Burrow]:
		//May need to be corrected
		if(internalQuestStatus("questM03Bugbear") >= 99)
		{
			retval = true;
		}
		break;
	case $location[Investigating A Plaintive Telegram]:
		if((item_amount($item[Plaintive Telegram]) > 0) && (internalQuestStatus("questLTTQuestByWire") >= 0))
		{
			retval = true;
		}
		break;
	case $location[Drunken Stupor]:
		if(inebriety_left() < 0)
		{
			retval = true;
		}
		break;

	case $location[Thugnderdome]:
		if(isDesertAvailable())
		{
			retval = gnomads_available();
		}
		break;

	// We go here to get the Logging Hatchet
	case $location[Camp Logging Camp]:
		if((!in_koe()) && (canadia_available()))
		{
			retval = true;
		}
		break;

	case $location[The Thinknerd Warehouse]:
		if(internalQuestStatus("questM22Shirt") >= 0)
		{
			retval = true;
		}
		break;

	case $location[Gingerbread Upscale Retail District]:
		if(get_property("gingerRetailUnlocked").to_boolean())
		{
			retval = get_property("gingerbreadCityAvailable").to_boolean() || get_property("_gingerbreadCityToday").to_boolean();
		}
		break;
	case $location[Gingerbread Sewers]:
		if(get_property("gingerSewersUnlocked").to_boolean())
		{
			retval = get_property("gingerbreadCityAvailable").to_boolean() || get_property("_gingerbreadCityToday").to_boolean();
		}
		break;
	case $location[Gingerbread Civic Center]:
	case $location[Gingerbread Industrial Zone]:
	case $location[Gingerbread Train Station]:
		retval = get_property("gingerbreadCityAvailable").to_boolean() || get_property("_gingerbreadCityToday").to_boolean();
		break;

	case $location[The Bandit Crossroads]:
		retval = get_property("_frAreasUnlocked").contains_text(loc);
		break;
	case $location[The Towering Mountains]:
		retval = get_property("_frAreasUnlocked").contains_text(loc);
		break;
	case $location[The Mystic Wood]:
		retval = get_property("_frAreasUnlocked").contains_text(loc);
		break;
	case $location[The Putrid Swamp]:
		retval = get_property("_frAreasUnlocked").contains_text(loc);
		break;
	case $location[The Cursed Village]:
		retval = get_property("_frAreasUnlocked").contains_text(loc);
		break;
	case $location[The Sprawling Cemetery]:
		retval = get_property("_frAreasUnlocked").contains_text(loc);
		break;

	case $location[Monorail Work Site]:
		retval = false;
		break;

	case $location[Your Mushroom Garden]:
		retval = (auto_canFightPiranhaPlant() || auto_canTendMushroomGarden());
		break;
	}

	// compare our result with Mafia's native function, log a warning if theres a difference. Ideally we can see if there are any differences between our code and Mafia's, and if not remove all of ours in favor of Mafia's
	boolean canAdvRetval = can_adventure(loc);
	if(canAdvRetval != retval){
		auto_log_debug("Uh oh, autoscend and mafia's can_adventure() dont agree on whether we can adventure at " + loc + " (autoscend: "+retval+", can_adventure(): "+canAdvRetval+"). Will assume locaiton available if either is true.");
		retval = retval || canAdvRetval;
	}

	return retval;
}

generic_t zone_difficulty(location loc)
{
	generic_t retval;

	//Should we handle when we are expecting a wanderer?

	retval._int = 0;
	retval._monster = $monster[none];

	boolean[monster] mobs = get_location_monsters(loc);
	if(count(mobs) > 0)
	{
		foreach mon in mobs
		{
			retval._int = mon.base_defense;
			retval._monster = mon;
			break;
		}
	}

	switch(loc)
	{
	case $location[The Shore\, Inc. Travel Agency]:
		retval._int = 0;
		break;
	case $location[Super Villain\'s Lair]:
		break;
	case $location[South of The Border]:
		break;
	case $location[The Arid\, Extra-Dry Desert]:
		break;
	case $location[The Oasis]:
		if(have_effect($effect[Ultrahydrated]) == 0)
		{
			retval._int = 0;
		}
		break;
	case $location[The Upper Chamber]:
		break;
	case $location[The Middle Chamber]:
		break;
	case $location[The Lower Chambers]:
		break;
	case $location[The Daily Dungeon]:
		break;
	case $location[The Overgrown Lot]:
		break;
	case $location[The Skeleton Store]:
		break;
	case $location[Madness Bakery]:
		break;
	case $location[The Deep Machine Tunnels]:
		break;
	case $location[The Haunted Pantry]:
		break;
	case $location[The Haunted Kitchen]:
		break;
	case $location[The Haunted Conservatory]:
		break;
	case $location[The Haunted Gallery]:
	case $location[The Haunted Bathroom]:
	case $location[The Haunted Bedroom]:
		break;
	case $location[The Haunted Billiards Room]:
		break;
	case $location[The Haunted Library]:
		break;
	case $location[The Haunted Ballroom]:
		break;
	case $location[The Haunted Boiler Room]:
	case $location[The Haunted Laundry Room]:
	case $location[The Haunted Wine Cellar]:
		break;
	case $location[Summoning Chamber]:
		break;
	case $location[The Hidden Park]:
		break;
	case $location[An Overgrown Shrine (Northwest)]:
	case $location[An Overgrown Shrine (Southwest)]:
	case $location[An Overgrown Shrine (Northeast)]:
	case $location[An Overgrown Shrine (Southeast)]:
		if($items[Antique Machete, Muculent Machete] contains equipped_item($slot[Weapon]))
		{
			retval._int = 0;
		}
		break;
	case $location[A Massive Ziggurat]:
		break;
	case $location[The Hidden Apartment Building]:
		break;
	case $location[The Hidden Hospital]:
		break;
	case $location[The Hidden Office Building]:
		break;
	case $location[The Hidden Bowling Alley]:
		break;
	case $location[The Typical Tavern Cellar]:
		break;
	case $location[The Spooky Forest]:
		break;
	case $location[The Hidden Temple]:
		break;
	case $location[The Black Forest]:
		break;
	case $location[The Bat Hole Entrance]:
		break;
	case $location[Guano Junction]:
		break;
	case $location[The Batrat And Ratbat Burrow]:
		break;
	case $location[The Beanbat Chamber]:
		break;
	case $location[The Boss Bat\'s Lair]:
		break;
	case $location[The VERY Unquiet Garves]:
		break;
	case $location[Whitey\'s Grove]:
		break;
	case $location[Inside the Palindome]:
		break;
	case $location[Noob Cave]:
	case $location[The Outskirts of Cobb\'s Knob]:
		retval._boolean = true;
		break;
	case $location[Cobb\'s Knob Barracks]:
	case $location[Cobb\'s Knob Kitchens]:
	case $location[Cobb\'s Knob Harem]:
	case $location[Cobb\'s Knob Treasury]:
	case $location[Throne Room]:
		break;
	case $location[The Dark Neck of the Woods]:
	case $location[The Dark Heart of the Woods]:
	case $location[The Dark Elbow of the Woods]:
		break;
	case $location[The Defiled Nook]:
	case $location[The Defiled Cranny]:
	case $location[The Defiled Alcove]:
	case $location[The Defiled Niche]:
		break;
	case $location[Pandamonium Slums]:
	case $location[The Laugh Floor]:
	case $location[Infernal Rackets Backstage]:
		break;
	case $location[The Obligatory Pirate\'s Cove]:
		break;
	case $location[Barrrney\'s Barrr]:
		break;
	case $location[The F\'c\'le]:
		break;
	case $location[The Poop Deck]:
		break;
	case $location[Belowdecks]:
		break;
	case $location[The Smut Orc Logging Camp]:
		break;
	case $location[A-Boo Peak]:
	case $location[Twin Peak]:
	case $location[Oil Peak]:
		break;
	case $location[Wartime Hippy Camp (Frat Disguise)]:
		break;
	case $location[The Battlefield (Frat Uniform)]:
		break;
	case $location[Next to that Barrel with Something Burning in it]:
	case $location[Near an Abandoned Refrigerator]:
	case $location[Over Where the Old Tires Are]:
	case $location[Out by that Rusted-Out Car]:
		break;
	case $location[Sonofa Beach]:
		break;
	case $location[The Themthar Hills]:
		break;
	case $location[The Hatching Chamber]:
		break;
	case $location[The Feeding Chamber]:
		break;
	case $location[The Royal Guard Chamber]:
		break;
	case $location[The Filthworm Queen\'s Chamber]:
		break;
	case $location[Itznotyerzitz Mine]:
	case $location[The Goatlet]:
		break;
	case $location[The Extreme Slope]:
	case $location[Lair of the Ninja Snowmen]:
		break;
	case $location[Mist-Shrouded Peak]:
		break;
	case $location[The Icy Peak]:
		break;
	case $location[The Penultimate Fantasy Airship]:
		break;
	case $location[The Castle in the Clouds in the Sky (Basement)]:
		break;
	case $location[The Castle in the Clouds in the Sky (Ground Floor)]:
		break;
	case $location[The Castle in the Clouds in the Sky (Top Floor)]:
		break;
	case $location[The Hole in the Sky]:
		break;
	case $location[Fastest Adventurer Contest]:
		break;
	case $location[The Enormous Greater-Than Sign]:
		break;
	case $location[The Dungeons of Doom]:
		break;
	case $location[The Limerick Dungeon]:
	case $location[The Sleazy Back Alley]:
	case $location[The Haiku Dungeon]:
		break;
	case $location[Smartest Adventurer Contest]:
	case $location[Strongest Adventurer Contest]:
	case $location[Smoothest Adventurer Contest]:
		break;
	case $location[Coldest Adventurer Contest]:
	case $location[Hottest Adventurer Contest]:
	case $location[Sleaziest Adventurer Contest]:
	case $location[Spookiest Adventurer Contest]:
	case $location[Stinkiest Adventurer Contest]:
		break;
	case $location[Barf Mountain]:
	case $location[Pirates of the Garbage Barges]:
	case $location[Uncle Gator\'s Country Fun-Time Liquid Waste Sluice]:
	case $location[The Toxic Teacups]:
		break;
	case $location[The Fun-Guy Mansion]:
	case $location[The Sunken Party Yacht]:
	case $location[Sloppy Seconds Diner]:
		break;
	case $location[The Secret Government Laboratory]:
	case $location[The Deep Dark Jungle]:
	case $location[The Mansion of Dr. Weirdeaux]:
		break;
	case $location[The Ice Hotel]:
	case $location[VYKEA]:
	case $location[The Ice Hole]:
		break;
	case $location[The SMOOCH Army HQ]:
	case $location[LavaCo&trade; Lamp Factory]:
	case $location[The Velvet / Gold Mine]:
	case $location[The Bubblin\' Caldera]:
		break;
	case $location[The X-32-F Combat Training Snowman]:
		break;
	case $location[Through the Spacegate]:
		break;
	case $location[The Old Landfill]:
		break;
	case $location[The Red Queen\'s Garden]:
		break;
	case $location[The Bugbear Pen]:
		break;
	case $location[The Spooky Gravy Burrow]:
		break;
	case $location[Investigating A Plaintive Telegram]:
		break;
	case $location[Drunken Stupor]:
		retval._int = 0;
		break;
	case $location[Thugnderdome]:
		break;
	case $location[The Thinknerd Warehouse]:
		break;
	case $location[Gingerbread Upscale Retail District]:
		break;
	case $location[Gingerbread Sewers]:
		break;
	case $location[Gingerbread Civic Center]:
	case $location[Gingerbread Industrial Zone]:
	case $location[Gingerbread Train Station]:
		break;
	case $location[Monorail Work Site]:
		break;
	case $location[A Maze of Sewer Tunnels]:
		break;

#	This is just to do a mass test.
#	default:
#		abort("Can't find " + loc);
#		break;
	}

	return retval;
}

boolean zone_hasLuckyAdventure(location loc)
{
	if ($locations[Vanya's Castle, The Fungus Plains, Megalo-City, Hero's Field, A Maze of Sewer Tunnels,A Mob of Zeppelin Protesters,A-Boo Peak,An Octopus's Garden,Art Class,
	Battlefield (Cloaca Uniform),Battlefield (Dyspepsi Uniform),Battlefield (No Uniform),Burnbarrel Blvd.,Camp Logging Camp,Chemistry Class,
	Cobb's Knob Barracks,Cobb's Knob Harem,Cobb's Knob Kitchens,Cobb's Knob Laboratory,Cobb's Knob Menagerie\, Level 2,Cobb's Knob Treasury,
	Elf Alley,Exposure Esplanade,Frat House,Frat House (Frat Disguise),Guano Junction,Hippy Camp,Hippy Camp (Hippy Disguise),Itznotyerzitz Mine,
	Lair of the Ninja Snowmen,Lemon Party,Madness Reef,Oil Peak,Outskirts of Camp Logging Camp,Pandamonium Slums,Shop Class,South of the Border,
	The "Fun" House,The Ancient Hobo Burial Ground,The Batrat and Ratbat Burrow,The Black Forest,The Brinier Deepers,The Briny Deeps,The Bugbear Pen,
	The Castle in the Clouds in the Sky (Basement),The Castle in the Clouds in the Sky (Ground Floor),The Castle in the Clouds in the Sky (Top Floor),
	The Copperhead Club,The Dark Elbow of the Woods,The Dark Heart of the Woods,The Dark Neck of the Woods,The Dive Bar,The Goatlet,The Hallowed Halls,
	The Haunted Ballroom,The Haunted Billiards Room,The Haunted Boiler Room,The Haunted Conservatory,The Haunted Gallery,The Haunted Kitchen,
	The Haunted Library,The Haunted Pantry,The Haunted Storage Room,The Heap,The Hidden Park,The Hidden Temple,The Icy Peak,The Knob Shaft,
	The Limerick Dungeon,The Mer-Kin Outpost,The Oasis,The Obligatory Pirate's Cove,The Outskirts of Cobb's Knob,The Poker Room,The Primordial Soup,
	The Purple Light District,The Red Zeppelin,The Roulette Tables,The Sleazy Back Alley,The Smut Orc Logging Camp,The Spectral Pickle Factory,
	The Spooky Forest,The Spooky Gravy Burrow,The Unquiet Garves,The VERY Unquiet Garves,The Valley of Rof L'm Fao,The Wreck of the Edgar Fitzsimmons,
	Thugnderdome,Tower Ruins,Twin Peak,Vanya's Castle Chapel,Whitey's Grove,Ye Olde Medievale Villagee] contains loc)
	{
		return true;
	}
	return false;
}

location[int] zones_available()
{
	location[int] retval;
	foreach loc in $locations[]
	{
		if(zone_isAvailable(loc, false))
		{
			retval[count(retval)] = loc;
		}
	}
	return retval;
}

monster[int] mobs_available()
{
	boolean[monster] list;
	monster[int] retval;
	foreach idx, loc in zones_available()
	{
		foreach idx, mob in get_monsters(loc)
		{
			list[mob] = true;
		}
	}
	foreach mob in list
	{
		retval[count(retval)] = mob;
	}
	return retval;
}

item[int] drops_available()
{
	boolean[item] list;
	item[int] retval;
	foreach idx, mob in mobs_available()
	{
		foreach it in item_drops(mob)
		{
			list[it] = true;
		}
	}
	foreach it in list
	{
		retval[count(retval)] = it;
	}
	return retval;
}


item[int] hugpocket_available()
{
	boolean[item] list;
	item[int] retval;
	foreach idx, mob in mobs_available()
	{
		foreach idx, drop in item_drops_array(mob)
		{
			if(drop.type == "0")
			{
				list[drop.drop] = true;
			}
			else if((drop.rate > 0) && (drop.type != "n") && (drop.type != "c") && (drop.type != "b"))
			{
				list[drop.drop] = true;
			}
		}
	}
	foreach it in list
	{
		retval[count(retval)] = it;
	}
	return retval;
}

boolean is_ghost_in_zone(location loc)
{
	//special location handling
	int totalTurnsSpent;
	int delayForNextNoncombat;
	if(have_effect($effect[Lucky!]) > 0)
	{
		return false;		//we are grabbing a Lucky! so we will not encounter a ghost unless it is a wandering monster
	}
	switch(loc)
	{
	case $location[A-Boo Peak]:
		if(get_property("booPeakProgress").to_int() == 0 && !get_property("booPeakLit").to_boolean())
		{
			//forced noncombat of lighting the peak
			return false;
		}
		if(get_property("auto_aboopending").to_int() != 0)	//internal tracking by autoscend
		{
			//our next visit to the peak will be The Horror NC adventure
			return false;
		}
		return true;
		
	case $location[the haunted gallery]:
		//special case for [ghost of Elizabeth Spookyraven] which only appears in [the haunted gallery] at the culmination of lights out quest
		//TODO implement doing the quest and then return true when the quest is at the right stage for her to appear
		return false;
		
	case $location[Summoning Chamber]:
		//special case for King Boo
		return in_plumber();
		
	case $location[The Hidden Hospital]:
		//if liana cleared then we can encounter ghost
		return get_property("hiddenHospitalProgress").to_int() > 0 && get_property("hiddenHospitalProgress").to_int() < 7;
		
	case $location[The Hidden Office Building]:
		boolean hasMcCluskyFile = $item[McClusky file (complete)].available_amount() > 0;
		totalTurnsSpent = $location[the hidden office building].turns_spent;
		delayForNextNoncombat = 4 - (totalTurnsSpent - 1) % 5;
		if(auto_haveQueuedForcedNonCombat())
		{
			delayForNextNoncombat = 0;
		}
		return hasMcCluskyFile && delayForNextNoncombat == 0;
		
	case $location[The Hidden Apartment Building]:
		boolean cursed = have_effect($effect[Thrice-Cursed]) > 0;
		totalTurnsSpent = $location[the hidden apartment building].turns_spent;
		delayForNextNoncombat = 7 - (totalTurnsSpent - 9) % 8;
		if(totalTurnsSpent < 9)
		{
			delayForNextNoncombat = 8 - totalTurnsSpent;
		}
		if(auto_haveQueuedForcedNonCombat())
		{
			delayForNextNoncombat = 0;
		}
		return cursed && delayForNextNoncombat == 0;
		
	case $location[The Hidden Bowling Alley]:
		//if tracker is 6 we used just the right amount of bowling bowls
		return get_property("hiddenBowlingAlleyProgress").to_int() == 6 && $item[bowling ball].available_amount() > 0;
		
	case $location[a massive ziggurat]:
		//massive ziggurat
		if(in_robot())
		{
			return false;		//[Protector_S._P._E._C._T._R._E.] has 0 phys res and 100% all element res
		}
		return $location[a massive Ziggurat].liana_cleared() && $item[stone triangle].available_amount() == 4;
		
	default:
		//for all other zones
		foreach idx, mob in get_monsters(loc)
		{
			if (mob.physical_resistance >= 80)
			{
				return true;
			}
		}
	}

	return false;
}

boolean[location] monster_to_location(monster target)
{
	boolean[location] retval;
	foreach loc in $locations[]		//check all locations in the game
	{
		foreach idx, mon in get_monsters(loc) if (target == mon)
		{
			retval[loc] = true;
			break;
		}
	}
	return retval;
}


/*
	case $location[The Oasis]:
	case $location[The Arid\, Extra-Dry Desert]:
	case $location[The Shore\, Inc. Travel Agency]:
	case $location[The Upper Chamber]:
	case $location[The Middle Chamber]:
	case $location[The Lower Chambers]:
	case $location[The Daily Dungeon]:
	case $location[The Skeleton Store]:
	case $location[Madness Bakery]:
	case $location[The Deep Machine Tunnels]:
	case $location[Super Villain\'s Lair]:
	case $location[The Haunted Kitchen]:
	case $location[The Haunted Conservatory]:
	case $location[The Haunted Gallery]:
	case $location[The Haunted Bathroom]:
	case $location[The Haunted Bedroom]:
	case $location[The Haunted Ballroom]:
	case $location[The Haunted Boiler Room]:
	case $location[The Haunted Laundry Room]:
	case $location[The Haunted Wine Cellar]:
	case $location[Summoning Chamber]:
	case $location[The Hidden Park]:
	case $location[The Hidden Apartment Building]:
	case $location[The Hidden Hospital]:
	case $location[The Hidden Office Building]:
	case $location[The Hidden Bowling Alley]:
	case $location[An Overgrown Shrine (Northwest)]:
	case $location[An Overgrown Shrine (Southwest)]:
	case $location[An Overgrown Shrine (Northeast)]:
	case $location[An Overgrown Shrine (Southeast)]:
	case $location[A Massive Ziggurat]:
	case $location[The Typical Tavern Cellar]:
	case $location[The Spooky Forest]:
	case $location[The Hidden Temple]:
	case $location[8-Bit Realm]:
	case $location[The Black Forest]:
	case $location[The Beanbat Chamber]:
	case $location[The Bat Hole Entrance]:
	case $location[The Batrat And Ratbat Burrow]:
	case $location[Guano Junction]:
	case $location[The Boss Bat\'s Lair]:
	case $location[The VERY Unquiet Garves]:
	case $location[Inside the Palindome]:
	case $location[The Outskirts of Cobb\'s Knob]:
	case $location[Cobb\'s Knob Harem]:
	case $location[Cobb\'s Knob Treasury]:
	case $location[Throne Room]:
	case $location[The Dark Neck of the Woods]:
	case $location[The Dark Heart of the Woods]:
	case $location[The Dark Elbow of the Woods]:
	case $location[Pandamonium Slums]:
	case $location[The Laugh Floor]:
	case $location[Infernal Rackets Backstage]:
	case $location[The Defiled Nook]:
	case $location[The Defiled Cranny]:
	case $location[The Defiled Alcove]:
	case $location[The Defiled Niche]:
	case $location[Barrrney\'s Barrr]:
	case $location[The F\'c\'le]:
	case $location[The Poop Deck]:
	case $location[Belowdecks]:
	case $location[The Battlefield (Frat Uniform)]:
	case $location[Wartime Hippy Camp (Frat Disguise)]:
	case $location[Next to that Barrel with Something Burning in it]:
	case $location[Near an Abandoned Refrigerator]:
	case $location[Over Where the Old Tires Are]:
	case $location[Out by that Rusted-Out Car]:
	case $location[The Extreme Slope]:
	case $location[Lair of the Ninja Snowmen]:
	case $location[Sonofa Beach]:
	case $location[The Themthar Hills]:
	case $location[The Hatching Chamber]:
	case $location[The Feeding Chamber]:
	case $location[The Royal Guard Chamber]:
	case $location[The Filthworm Queen\'s Chamber]:
	case $location[Noob Cave]:
	case $location[The Smut Orc Logging Camp]:
	case $location[A-Boo Peak]:
	case $location[Twin Peak]:
	case $location[Oil Peak]:
	case $location[Itznotyerzitz Mine]:
	case $location[The Goatlet]:
	case $location[Mist-Shrouded Peak]:
	case $location[The Icy Peak]:
	case $location[The Penultimate Fantasy Airship]:
	case $location[The Castle in the Clouds in the Sky (Basement)]:
	case $location[The Castle in the Clouds in the Sky (Ground Floor)]:
	case $location[The Castle in the Clouds in the Sky (Top Floor)]:
	case $location[The Hole in the Sky]:
	case $location[Fastest Adventurer Contest]:
	case $location[Smartest Adventurer Contest]:
	case $location[Hottest Adventurer Contest]:
	case $location[Barf Mountain]:
	case $location[The Bubblin\' Caldera]:
	case $location[The X-32-F Combat Training Snowman]:
	case $location[Through the Spacegate]:
	case $location[A Maze of Sewer Tunnels]:
	case $location[The Ice Hotel]:
	case $location[Whitey\'s Grove]:
	case $location[Gingerbread Upscale Retail District]:
	case $location[The Haiku Dungeon]:
	case $location[The Limerick Dungeon]:
	case $location[The Skeleton Store]:
	case $location[The Overgrown Lot]:
	case $location[The Secret Government Laboratory]:
	case $location[The Velvet / Gold Mine]:
	case $location[The Copperhead Club]:
	case $location[A Mob Of Zeppelin Protesters]:
	case $location[The Red Zeppelin]:
	case $location[The Bandit Crossroads]:
	case $location[The Towering Mountains]:
	case $location[The Mystic Wood]:
	case $location[The Putrid Swamp]:
	case $location[The Cursed Village]:
	case $location[The Sprawling Cemetary]:
	default:


*/
