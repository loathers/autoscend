script "cc_zone.ash"

//All functions should fail if the king is liberated?
//Zone functions come here.

generic_t zone_needItem(location loc);
generic_t zone_difficulty(location loc);
generic_t zone_combatMod(location loc);
generic_t zone_delay(location loc);
generic_t zone_available(location loc);
location[int] zone_list();
int[location] zone_delayable();
boolean zone_isAvailable(location loc);
location[int] zones_available();
monster[int] mobs_available();
item[int] drops_available();
item[int] hugpocket_available();

boolean zone_isAvailable(location loc)
{
	return zone_available(loc)._boolean;
}

int[location] zone_delayable()
{
	location[int] locs = zone_list();
	int[location] retval;
	foreach idx, loc in locs
	{
		generic_t locValue = zone_delay(loc);
		if(locValue._boolean && zone_isAvailable(loc))
		{
			retval[loc] = locValue._int;
		}
	}
	return retval;
}

/*
record generic_t
{
	boolean _error;
	boolean _boolean;
	int _int;
	float _float;
	string _string;
	item _item;
	location _location;
	class _class;
	stat _stat;
	skill _skill;
	effect _effect;
	familiar _familiar;
	slot _slot;
	monster _monster;
	element _element;
	phylum _phylum;
};
*/

generic_t zone_needItem(location loc)
{
	generic_t retval;
	float value = 0.0;
	switch(loc)
	{
	case $location[The Oasis]:
		value = 30.0;
		break;
	case $location[The Middle Chamber]:
		value = 20.0;
		break;
	case $location[The Deep Machine Tunnels]:
		value = 30.0;			#Just a guess.
		break;
	case $location[The Haunted Laundry Room]:
	case $location[The Haunted Wine Cellar]:
		value = 5.0;
		break;
	case $location[The Hidden Park]:
	case $location[The Hidden Apartment Building]:
	case $location[The Hidden Office Building]:
		if((get_property("hiddenTavernUnlock").to_int() < my_ascensions()) && !contains_text(get_property("banishedMonsters"), $monster[Pygmy Janitor]))
		{
			value = 20.0;
		}
		break;
	case $location[The Hidden Bowling Alley]:
		// Should actually check if we have used 4/5 already.
		if(item_amount($item[Bowling Ball]) == 0)
		{
			value = 40.0;
		}
		//Once we have completed the Bowling Alley, we do not care about this anymore.
		if((get_property("hiddenTavernUnlock").to_int() < my_ascensions()) && !contains_text(get_property("banishedMonsters"), $monster[Pygmy Janitor]))
		{
			value = 20.0;
		}
		break;
	case $location[The Hidden Temple]:
		//Only if we need stone wool manually for some reason.
		//Or via the semi-rare!		(100/50/20 for SR, 25 Sheep)
		break;
	case $location[8-Bit Realm]:
		value = 60.0;
		break;
	case $location[The Black Forest]:
		//Is it possible we want blackberries?
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
	case $location[Inside the Palindome]:
		if((item_amount($item[Stunt Nuts]) == 0) && (item_amount($item[Wet Stew]) == 0))
		{
			value = 32.0;
		}
		break;
	case $location[Whitey\'s Grove]:
		if(((item_amount($item[Lion Oil]) == 0) || (item_amount($item[Bird Rib]) == 0)) && (item_amount($item[Wet Stew]) == 0) && (item_amount($item[Wet Stunt Nut Stew]) == 0) && (internalQuestStatus("questL11Palindome") < 5))
		{
			value = 25.0;
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
		if(!have_outfit("Knob Goblin Harem Girl Disguise"))
		{
			value = 20.0;
		}
		break;
	case $location[The Dark Neck of the Woods]:
	case $location[The Dark Heart of the Woods]:
	case $location[The Dark Elbow of the Woods]:
	case $location[Pandamonium Slums]:
		if(item_amount($item[Hot Wing]) < 3)
		{
			value = 30.0;
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
	case $location[The Defiled Nook]:
		// Handle for a gravy boat?
		if(get_property("cyrptNookEvilness").to_int() > 26)
		{
			value = 20.0;
		}
		break;
	case $location[Barrrney\'s Barrr]:
		if(item_amount($item[Cocktail Napkin]) == 0)
		{
			value = 10.0;
		}
		break;
	case $location[The F\'c\'le]:
		if((item_amount($item[Ball Polish]) == 0) || (item_amount($item[Mizzenmast Mop]) == 0) ||(item_amount($item[Rigging Shampoo]) == 0))
		{
			value = 30.0;
		}
		break;
	case $location[The Hatching Chamber]:
	case $location[The Feeding Chamber]:
	case $location[The Royal Guard Chamber]:
		value = 10.0;
		break;
	case $location[The Smut Orc Logging Camp]:
		if(item_amount($item[Ten-Leaf Clover]) == 0)
		{
			value = 10.0;
		}
		break;
	case $location[A-Boo Peak]:
		{
			int progress = get_property("booPeakProgress").to_int();
			progress -= (30 * item_amount($item[A-Boo Clue]));
			if(get_property("cc_aboopending").to_int() != 0)
			{
				progress -= 30;
			}
			if(progress > 4)
			{
				value = 15.0;
			}
		}
		break;
	case $location[Twin Peak]:
		value = 15.0;
		break;
	case $location[Oil Peak]:
		// Should probably also check for Twin Peak completion here.
		if((item_amount($item[Bubblin\' Crude]) < 12) && (item_amount($item[Jar Of Oil])  == 0))
		{
			if(monster_level_adjustment() > 100)
			{
				value = 10.0;
			}
			else if(monster_level_adjustment() > 50)
			{
				value = 30.0;
			}
		}
		break;
	case $location[Itznotyerzitz Mine]:
		if(item_amount($item[Ten-Leaf Clover]) == 0)
		{
			value = 10.0;
		}
		break;
	case $location[The Goatlet]:
		value = 40.0;
		break;

	case $location[The Extreme Slope]:
		if(!have_outfit("extreme cold-weather gear"))
		{
			value = 10.0;
		}

	case $location[The Penultimate Fantasy Airship]:
		if(!possessEquipment($item[Amulet Of Extreme Plot Significance]) && !possessEquipment($item[Titanium Assault Umbrella]))
		{
			value = 10.0;
		}
		if(!possessEquipment($item[Mohawk Wig]))
		{
			value = 10.0;
		}
		break;
	case $location[The Castle in the Clouds in the Sky (Basement)]:
		//Should we care about Heavy D?
		break;
	case $location[The Castle in the Clouds in the Sky (Top Floor)]:
		//Should we care about Thin Black Candles?
		break;
	case $location[The Hole in the Sky]:
		if((item_amount($item[Star]) < 8) || (item_amount($item[Line]) < 7))
		{
			value = 30.0;
		}
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
		if((cc_my_path() == "Community Service") && (item_amount($item[Tomato]) < 2) && have_skill($skill[Advanced Saucecrafting]))
		{
			retval._float = 59.4;
		}
		break;
	case $location[The Skeleton Store]:
		if((cc_my_path() == "Community Service") && have_skill($skill[Advanced Saucecrafting]) && ((item_amount($item[Cherry]) < 1) || (item_amount($item[Grapefruit]) < 1) || (item_amount($item[Lemon]) < 1)))
		{	//No idea, should spade this for great justice.
			retval._float = 33.0;
		}
		break;
	case $location[The Secret Government Laboratory]:
		if((cc_my_path() == "Community Service") && (item_amount($item[Experimental Serum G-9]) < 2))
		{	//No idea, assume it is low.
			retval._float = 10.0;
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

		if(cc_my_path() == "Live. Ascend. Repeat.")
		{
			retval._float = 5000.0/value;
		}
		retval._float -= 100.0;
	}
	return retval;
}

generic_t zone_combatMod(location loc)
{
	generic_t retval;
	generic_t delay = zone_delay(loc);
	int value = 0;
	switch(loc)
	{
	case $location[The Upper Chamber]:
		value = -85;
		break;
	case $location[Super Villain\'s Lair]:
		if(!get_property("_villainLairColorChoiceUsed").to_boolean() || !get_property("_villainLairDoorChoiceUsed").to_boolean() || !get_property("_villainLairSymbologyChoiceUsed").to_boolean())
		{
			value = -70;
		}
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
	case $location[The Typical Tavern Cellar]:
		//We could cut it off early if the Rat Faucet is the last one
		//And marginally if we know the 3rd/6th square are forced events.
		value = -75;
		break;
	case $location[Through the Spacegate]:
	case $location[The Cheerless Spire (Level 5)]:
		value = 5;
		break;
	case $location[The Cheerless Spire (Level 4)]:
	case $location[The Cheerless Spire (Level 3)]:
	case $location[The Cheerless Spire (Level 2)]:
	case $location[The Cheerless Spire (Level 1)]:
		value = -85;
		break;
	case $location[The Spooky Forest]:
		if(delay._int == 0)
		{
			value = -85;
		}
		break;
	case $location[The Hidden Temple]:
		if(cc_my_path() == "G-Lover")
		{
			value = -90;
		}
		break;
	case $location[The Copperhead Club]:
	case $location[A Mob Of Zeppelin Protesters]:
	case $location[The Red Zeppelin]:
		value = -70;
		break;

	case $location[The Black Forest]:
		if(internalQuestStatus("questL13Final") < 5)
		{
			value = 5;
		}
		else if(internalQuestStatus("questL13Final") == 5)
		{
			value = -95;
		}
		break;
	case $location[Monorail Work Site]:
		value = 25;
		break;
	case $location[Inside the Palindome]:
		if((item_amount($item[Photograph Of A Red Nugget]) == 0) || (item_amount($item[Photograph Of An Ostrich Egg]) == 0) || (item_amount($item[Photograph Of God]) == 0))
		{
			value = -70;
		}
		break;
	case $location[Whitey\'s Grove]:
		if(((item_amount($item[Lion Oil]) == 0) || (item_amount($item[Bird Rib]) == 0)) && (item_amount($item[Wet Stew]) == 0) && (item_amount($item[Wet Stunt Nut Stew]) == 0) && (internalQuestStatus("questL11Palindome") < 5))
		{
			value = 15;
		}
		break;
	case $location[The Dark Neck of the Woods]:
		value = -85;
		break;
	case $location[The Dark Heart of the Woods]:
		value = -85;
		break;
	case $location[The Dark Elbow of the Woods]:
		value = -85;
		break;
	case $location[The Defiled Cranny]:
		value = -85;
		break;
	case $location[The Defiled Alcove]:
		value = -85;
		break;
	case $location[Barrrney\'s Barrr]:
		if(internalQuestStatus("questM12Pirate") >= 0)
		{
			value = 20;
		}
		break;
	case $location[The F\'c\'le]:
		if((item_amount($item[Ball Polish]) == 0) || (item_amount($item[Mizzenmast Mop]) == 0) ||(item_amount($item[Rigging Shampoo]) == 0))
		{
			value = 20;
		}
		break;
	case $location[The Poop Deck]:
		value = -80;
		break;
	case $location[Wartime Hippy Camp (Frat Disguise)]:
		value = -80;
		break;
	case $location[The Extreme Slope]:
		value = -95;
		break;
	case $location[Lair of the Ninja Snowmen]:
		value = 80;
		break;
	case $location[Sonofa Beach]:
		value = 90;
		break;
	case $location[Twin Peak]:
		value = -80;
		break;
	case $location[A Maze of Sewer Tunnels]:
		// I guess there is not a preference for this?
		value = -95;
		break;
	case $location[The Ice Hotel]:
		value = -85;
		break;
	case $location[The Obligatory Pirate\'s Cove]:
		if(internalQuestStatus("questM12Pirate") < 2)
		{
			value = -60;
		}
		else if(numPirateInsults() < 6)
		{
			value = 40;
		}
		else if(numPirateInsults() <= 7)
		{
			value = -10;
		}
		else
		{
			value = -60;
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
		value = -95;
		break;
	case $location[The Castle in the Clouds in the Sky (Ground Floor)]:
		if(internalQuestStatus("questL13Final") == 8)
		{
			value = -95;
		}
		break;
	case $location[The Castle in the Clouds in the Sky (Top Floor)]:
		value = -95;
		break;
	case $location[The Hidden Park]:
		if(item_amount($item[Bowling Ball]) < 3)
		{
			value = -85;
		}
		break;
	default:
		retval._error = true;
		break;
	}

	if(cc_my_path() == "Live. Ascend. Repeat.")
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
	switch(loc)
	{
	case $location[The Oasis]:
		if(get_property("desertExploration").to_int() < 100)
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
	case $location[The Haunted Bedroom]:
		value = 6 - loc.turns_spent;
		break;
	case $location[The Haunted Ballroom]:
		value = 5 - loc.turns_spent;
		break;
	case $location[The Hidden Park]:
		if(!possessEquipment($item[Antique Machete]) && !possessEquipment($item[Muculent Machete]))
		{
			value = 6 - loc.turns_spent;
		}
		break;
	case $location[The Hidden Apartment Building]:
		value = 8 - loc.turns_spent;
		retval._item = $item[Clara\'s Bell];
		//Special case this
		break;
	case $location[The Hidden Office Building]:
		value = 10 - loc.turns_spent;
		retval._item = $item[Clara\'s Bell];
		//Special case?
		break;
	case $location[The Spooky Forest]:
		value = 5 - loc.turns_spent;
		break;
	case $location[The Boss Bat\'s Lair]:
		value = 4 - loc.turns_spent;
		break;
	case $location[The Outskirts of Cobb\'s Knob]:
		value = 10 - loc.turns_spent;
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

generic_t zone_available(location loc)
{
	generic_t retval;

	switch(loc)
	{
	case $location[The Copperhead Club]:
	case $location[A Mob Of Zeppelin Protesters]:
		if(internalQuestStatus("questL11Shen") >= 0)
		{
			retval._boolean = true;
		}
	case $location[The Red Zeppelin]:
		if(internalQuestStatus("questL11Ron") >= 2)
		{
			retval._boolean = true;
		}

	case $location[Super Villain\'s Lair]:
		if((cc_my_path() == "License to Adventure") && (get_property("_villainLairProgress").to_int() < 999) && (get_property("_cc_bondBriefing") == "started"))
		{
			retval._boolean = true;
		}
		break;
	case $location[South of The Border]:
	case $location[The Shore\, Inc. Travel Agency]:
		if(get_property("lastDesertUnlock").to_int() == my_ascensions())
		{
			retval._boolean = true;
		}
		break;
	case $location[The Arid\, Extra-Dry Desert]:
		if(internalQuestStatus("questL11Desert") >= 0)
		{
			retval._boolean = true;
		}
		break;
	case $location[The Oasis]:
		if($location[The Arid\, Extra-Dry Desert].turns_spent > 0)
		{
			retval._boolean = true;
		}
		break;
	case $location[The Upper Chamber]:
		if(internalQuestStatus("questL11Pyramid") >= 0)
		{
			retval._boolean = true;
		}
		break;
	case $location[The Middle Chamber]:
		retval._boolean = get_property("middleChamberUnlock").to_boolean();
		break;
	case $location[The Lower Chambers]:
		retval._boolean = get_property("lowerChamberUnlock").to_boolean();
		break;
	case $location[The Daily Dungeon]:
		retval._boolean = !get_property("dailyDungeonDone").to_boolean();
		break;
	case $location[The Overgrown Lot]:
		if(internalQuestStatus("questM24Doc") >= 0)
		{
			retval._boolean = true;
		}
		break;
	case $location[The Skeleton Store]:
		if(internalQuestStatus("questM23Meatsmith") >= 0)
		{
			retval._boolean = true;
		}
		break;
	case $location[Madness Bakery]:
		if(internalQuestStatus("questM25Armorer") >= 0)
		{
			retval._boolean = true;
		}
		break;
	case $location[The Deep Machine Tunnels]:
		if(have_familiar($familiar[Machine Elf]) || (have_effect($effect[Inside The Snowglobe]) > 0))
		{
			retval._boolean = true;
		}
		break;
	case $location[The Haunted Pantry]:
	case $location[The Haunted Kitchen]:
	case $location[The Haunted Conservatory]:
		if(internalQuestStatus("questM20Necklace") >= 0)
		{
			retval._boolean = true;
		}
		break;
	case $location[The Haunted Gallery]:
	case $location[The Haunted Bathroom]:
	case $location[The Haunted Bedroom]:
		if(internalQuestStatus("questM21Dance") >= 1)
		{
			retval._boolean = true;
		}
		break;
	case $location[The Haunted Billiards Room]:
		if(item_amount($item[Spookyraven Billiards Room Key]) > 0)
		{
			retval._boolean = true;
		}
		break;
	case $location[The Haunted Library]:
		if(item_amount($item[[7302]Spookyraven Library Key]) > 0)
		{
			retval._boolean = true;
		}
		break;
	case $location[The Haunted Ballroom]:
		if(internalQuestStatus("questM21Dance") >= 3)
		{
			retval._boolean = true;
		}
		break;
	case $location[The Haunted Boiler Room]:
	case $location[The Haunted Laundry Room]:
	case $location[The Haunted Wine Cellar]:
		if(internalQuestStatus("questL11Manor") >= 1)
		{
			retval._boolean = true;
		}
		break;
	case $location[Summoning Chamber]:
		if(internalQuestStatus("questL11Manor") >= 11)
		{
			retval._boolean = true;
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
			retval._boolean = true;
		}
		break;
	case $location[The Hidden Apartment Building]:
		if(internalQuestStatus("questL11Curses") >= 0)
		{
			retval._boolean = true;
		}
		break;
	case $location[The Hidden Hospital]:
		if(internalQuestStatus("questL11Doctor") >= 0)
		{
			retval._boolean = true;
		}
		break;
	case $location[The Hidden Office Building]:
		if(internalQuestStatus("questL11Business") >= 0)
		{
			retval._boolean = true;
		}
		break;
	case $location[The Hidden Bowling Alley]:
		if(internalQuestStatus("questL11Spare") >= 0)
		{
			retval._boolean = true;
		}
		break;
	case $location[The Typical Tavern Cellar]:
		if(internalQuestStatus("questL03Rat") >= 0)
		{
			retval._boolean = true;
		}
		break;
	case $location[The Spooky Forest]:
		if((internalQuestStatus("questL02Larva") >= 0) || (internalQuestStatus("questG02Whitecastle") >= 0))
		{
			retval._boolean = true;
		}
		break;
	case $location[The Hidden Temple]:
		if(get_property("lastTempleUnlock").to_int() == my_ascensions())
		{
			retval._boolean = true;
		}
		break;
	case $location[8-Bit Realm]:
		if(possessEquipment($item[Continuum Transfunctioner]) && ((internalQuestStatus("questL02Larva") >= 0) || (internalQuestStatus("questG02Whitecastle") >= 0)))
		{
			retval._boolean = true;
		}
		break;
	case $location[The Black Forest]:
		if(internalQuestStatus("questL11MacGuffin") >= 0)
		{
			retval._boolean = true;
		}
		break;
	case $location[The Bat Hole Entrance]:
		if(internalQuestStatus("questL04Bat") >= 0)
		{
			retval._boolean = true;
		}
		break;
	case $location[Guano Junction]:
		if((elemental_resist($element[stench]) >= 1) && (internalQuestStatus("questL04Bat") >= 0))
		{
			retval._boolean = true;
		}
		break;
	case $location[The Batrat And Ratbat Burrow]:
		if(internalQuestStatus("questL04Bat") >= 1)
		{
			retval._boolean = true;
		}
		break;
	case $location[The Beanbat Chamber]:
		if(internalQuestStatus("questL04Bat") >= 2)
		{
			retval._boolean = true;
		}
		break;
	case $location[The Boss Bat\'s Lair]:
		if(internalQuestStatus("questL04Bat") >= 3)
		{
			retval._boolean = true;
		}
		break;
	case $location[The VERY Unquiet Garves]:
		if(get_property("questL07Cyrptic") == "finished")
		{
			retval._boolean = true;
		}
		break;
	case $location[Whitey\'s Grove]:
		if((internalQuestStatus("questG02Whitecastle") >= 0) || (internalQuestStatus("questL11Palindome") >= 3))
		{
			retval._boolean = true;
		}
		break;
	case $location[Inside the Palindome]:
		if(possessEquipment($item[Talisman O\' Namsilat]))
		{
			retval._boolean = true;
		}
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
		if(internalQuestStatus("questL05Goblin") >= 1)
		{
			retval._boolean = true;
		}
		break;
	case $location[The Dark Neck of the Woods]:
	case $location[The Dark Heart of the Woods]:
	case $location[The Dark Elbow of the Woods]:
		if((internalQuestStatus("questL06Friar") >= 0) && (get_property("questL06Friar") != "finished"))
		{
			retval._boolean = true;
		}
		break;
	case $location[The Defiled Nook]:
	case $location[The Defiled Cranny]:
	case $location[The Defiled Alcove]:
	case $location[The Defiled Niche]:
		if(internalQuestStatus("questL07Cyrptic") >= 0)
		{
			retval._boolean = true;
		}
		break;
	case $location[Pandamonium Slums]:
	case $location[The Laugh Floor]:
	case $location[Infernal Rackets Backstage]:
		if(internalQuestStatus("questL06Friar") >= 10)
		{
			retval._boolean = true;
		}
		break;
	case $location[The Obligatory Pirate\'s Cove]:
		if(get_property("lastIslandUnlock").to_int() == my_ascensions())
		{
			if((get_property("questL12War") == "unstarted") || (get_property("questL12War") == "finished"))
			{
				retval._boolean = true;
			}
		}
		break;
	case $location[Barrrney\'s Barrr]:
		if((have_outfit("swashbuckling getup") || possessEquipment($item[Pirate Fledges])) && (get_property("lastIslandUnlock").to_int() == my_ascensions()))
		{
			if((get_property("questL12War") == "unstarted") || (get_property("questL12War") == "finished"))
			{
				retval._boolean = true;
			}
		}
		break;
	case $location[The F\'c\'le]:
		if((have_outfit("swashbuckling getup") || possessEquipment($item[Pirate Fledges])) && (get_property("lastIslandUnlock").to_int() == my_ascensions()) && (internalQuestStatus("questM12Pirate") >= 5))
		{
			if((get_property("questL12War") == "unstarted") || (get_property("questL12War") == "finished"))
			{
				retval._boolean = true;
			}
		}
		break;
	case $location[The Poop Deck]:
		if((have_outfit("swashbuckling getup") || possessEquipment($item[Pirate Fledges])) && (get_property("lastIslandUnlock").to_int() == my_ascensions()) && (internalQuestStatus("questM12Pirate") >= 6) && (get_property("cc_mcmuffin") != ""))
		{
			if((get_property("questL12War") == "unstarted") || (get_property("questL12War") == "finished"))
			{
				retval._boolean = true;
			}
		}
		break;
	case $location[Belowdecks]:
		if((have_outfit("swashbuckling getup") || possessEquipment($item[Pirate Fledges])) && (get_property("lastIslandUnlock").to_int() == my_ascensions()) && (get_property("questM12Pirate") == "finished") && (get_property("cc_mcmuffin") != ""))
		{
			if((get_property("questL12War") == "unstarted") || (get_property("questL12War") == "finished"))
			{
				retval._boolean = true;
			}
		}
		break;
	case $location[The Smut Orc Logging Camp]:
		if(internalQuestStatus("questL09Topping") >= 0)
		{
			retval._boolean = true;
		}
		break;
	case $location[A-Boo Peak]:
	case $location[Twin Peak]:
	case $location[Oil Peak]:
		if(internalQuestStatus("questL09Topping") >= 1)
		{
			retval._boolean = true;
		}
		break;
	case $location[Wartime Hippy Camp (Frat Disguise)]:
		if((internalQuestStatus("questL12War") == 0) && have_outfit("frat warrior fatigues"))
		{
			retval._boolean = true;
		}
		break;
	case $location[The Battlefield (Frat Uniform)]:
		if((internalQuestStatus("questL12War") >= 1) && (get_property("hippiesDefeated").to_int() < 1000) && have_outfit("frat warrior fatigues") && (get_property("questL12War") != "finished"))
		{
			retval._boolean = true;
		}
		break;
	case $location[Next to that Barrel with Something Burning in it]:
	case $location[Near an Abandoned Refrigerator]:
	case $location[Over Where the Old Tires Are]:
	case $location[Out by that Rusted-Out Car]:
		if((internalQuestStatus("questL12War") >= 1) && (get_property("sidequestJunkyardCompleted") == "none") && (get_property("questL12War") != "finished"))
		{
			retval._boolean = true;
		}
		break;
	case $location[Sonofa Beach]:
		if(internalQuestStatus("questL12War") >= 1)
		{
			retval._boolean = true;
		}
		break;
	case $location[The Themthar Hills]:
		if((internalQuestStatus("questL12War") >= 1) && (get_property("sidequestNunsCompleted") == "none") && (get_property("questL12War") != "finished"))
		{
			retval._boolean = true;
		}
		break;
	case $location[The Hatching Chamber]:
		if((internalQuestStatus("questL12War") >= 1) && (get_property("sidequestOrchardCompleted") == "none") && (get_property("questL12War") != "finished"))
		{
			retval._boolean = true;
		}
		break;
	case $location[The Feeding Chamber]:
		if((internalQuestStatus("questL12War") >= 1) && (get_property("sidequestOrchardCompleted") == "none") && (have_effect($effect[Filthworm Larva Stench]) > 0) && (get_property("questL12War") != "finished"))
		{
			retval._boolean = true;
		}
		break;
	case $location[The Royal Guard Chamber]:
		if((internalQuestStatus("questL12War") >= 1) && (get_property("sidequestOrchardCompleted") == "none") && (have_effect($effect[Filthworm Drone Stench]) > 0) && (get_property("questL12War") != "finished"))
		{
			retval._boolean = true;
		}
		break;
	case $location[The Filthworm Queen\'s Chamber]:
		if((internalQuestStatus("questL12War") >= 1) && (get_property("sidequestOrchardCompleted") == "none") && (item_amount($item[Heart Of The Filthworm Queen]) == 0) && (have_effect($effect[Filthworm Guard Stench]) > 0) && (get_property("questL12War") != "finished"))
		{
			retval._boolean = true;
		}
		break;
	case $location[Itznotyerzitz Mine]:
	case $location[The Goatlet]:
		if(internalQuestStatus("questL08Trapper") >= 1)
		{
			retval._boolean = true;
		}
		break;
	case $location[The Extreme Slope]:
	case $location[Lair of the Ninja Snowmen]:
		if(internalQuestStatus("questL08Trapper") >= 2)
		{
			retval._boolean = true;
		}
		break;
	case $location[Mist-Shrouded Peak]:
		if(internalQuestStatus("questL08Trapper") >= 3)
		{
			retval._boolean = true;
		}
		break;
	case $location[The Icy Peak]:
		if(internalQuestStatus("questL08Trapper") >= 6)
		{
			retval._boolean = true;
		}
		break;
	case $location[The Penultimate Fantasy Airship]:
		if(internalQuestStatus("questL10Garbage") >= 1)
		{
			retval._boolean = true;
		}
		break;
	case $location[The Castle in the Clouds in the Sky (Basement)]:
		if(item_amount($item[S.O.C.K.]) > 0)
		{
			retval._boolean = true;
		}
		break;
	case $location[The Castle in the Clouds in the Sky (Ground Floor)]:
		if(get_property("lastCastleGroundUnlock").to_int() == my_ascensions())
		{
			retval._boolean = true;
		}
		break;
	case $location[The Castle in the Clouds in the Sky (Top Floor)]:
		if(get_property("lastCastleTopUnlock").to_int() == my_ascensions())
		{
			retval._boolean = true;
		}
		break;
	case $location[The Hole in the Sky]:
		if(item_amount($item[Steam-Powered Model Rocketship]) > 0)
		{
			retval._boolean = true;
		}
		break;
	case $location[Fastest Adventurer Contest]:
		if(get_property("nsContestants1").to_int() > 0)
		{
			retval._boolean = true;
		}
		break;
	case $location[The Enormous Greater-Than Sign]:
		if(get_property("lastPlusSignUnlock").to_int() < my_ascensions())
		{
			retval._boolean = true;
		}
		break;
	case $location[The Dungeons of Doom]:
		if(get_property("lastPlusSignUnlock").to_int() == my_ascensions())
		{
			retval._boolean = true;
		}
		break;
	case $location[The Limerick Dungeon]:
	case $location[The Sleazy Back Alley]:
	case $location[The Haiku Dungeon]:
		retval._boolean = true;
		break;
	case $location[Smartest Adventurer Contest]:
	case $location[Strongest Adventurer Contest]:
	case $location[Smoothest Adventurer Contest]:
		if(get_property("nsContestants2").to_int() > 0)
		{
			retval._boolean = true;
		}
		break;
	case $location[Coldest Adventurer Contest]:
	case $location[Hottest Adventurer Contest]:
	case $location[Sleaziest Adventurer Contest]:
	case $location[Spookiest Adventurer Contest]:
	case $location[Stinkiest Adventurer Contest]:
		if(get_property("nsContestants3").to_int() > 0)
		{
			retval._boolean = true;
		}
		break;
	case $location[Barf Mountain]:
	case $location[Pirates of the Garbage Barges]:
	case $location[Uncle Gator\'s Country Fun-Time Liquid Waste Sluice]:
	case $location[The Toxic Teacups]:
		retval._boolean = get_property("stenchAirportAlways").to_boolean() || get_property("_stenchAirportToday").to_boolean();
		break;
	case $location[The Fun-Guy Mansion]:
	case $location[The Sunken Party Yacht]:
	case $location[Sloppy Seconds Diner]:
		retval._boolean = get_property("sleazeAirportAlways").to_boolean() || get_property("_sleazeAirportToday").to_boolean();
		break;
	case $location[The Secret Government Laboratory]:
	case $location[The Deep Dark Jungle]:
	case $location[The Mansion of Dr. Weirdeaux]:
		retval._boolean = get_property("spookyAirportAlways").to_boolean() || get_property("_spookyAirportToday").to_boolean();
		break;
	case $location[The Ice Hotel]:
	case $location[VYKEA]:
	case $location[The Ice Hole]:
		retval._boolean = get_property("coldAirportAlways").to_boolean() || get_property("_coldAirportToday").to_boolean();
		break;
	case $location[The SMOOCH Army HQ]:
	case $location[LavaCo&trade; Lamp Factory]:
	case $location[The Velvet / Gold Mine]:
	case $location[The Bubblin\' Caldera]:
		retval._boolean = get_property("hotAirportAlways").to_boolean() || get_property("_hotAirportToday").to_boolean();
		break;
	case $location[The X-32-F Combat Training Snowman]:
		retval._boolean = get_property("snojoAvailable").to_boolean();
		break;
	case $location[Through the Spacegate]:
		retval._boolean = get_property("spacegateAlways").to_boolean() || get_property("_spacegateToday").to_boolean();
		break;

	case $location[The Old Landfill]:
		if(internalQuestStatus("questM19Hippy") >= 0)
		{
			retval._boolean = true;
		}
		break;

	case $location[The Red Queen\'s Garden]:
		if(have_effect($effect[Down the Rabbit Hole]) > 0)
		{
			retval._boolean = true;
		}
		break;

	case $location[The Bugbear Pen]:
		if(internalQuestStatus("questM03Bugbear") >= 0)
		{
			retval._boolean = true;
		}
		break;
	case $location[The Spooky Gravy Burrow]:
		//May need to be corrected
		if(internalQuestStatus("questM03Bugbear") >= 99)
		{
			retval._boolean = true;
		}
		break;
	case $location[Investigating A Plaintive Telegram]:
		if((item_amount($item[Plaintive Telegram]) > 0) && (internalQuestStatus("questLTTQuestByWire") >= 0))
		{
			retval._boolean = true;
		}
		break;
	case $location[Drunken Stupor]:
		if(inebriety_left() < 0)
		{
			retval._boolean = true;
		}
		break;

	case $location[Thugnderdome]:
		if(get_property("lastDesertUnlock").to_int() == my_ascensions())
		{
			retval._boolean = gnomads_available();
		}
		break;
	case $location[The Thinknerd Warehouse]:
		if(internalQuestStatus("questM22Shirt") >= 0)
		{
			retval._boolean = true;
		}
		break;

	case $location[Gingerbread Upscale Retail District]:
		if(get_property("gingerRetailUnlocked").to_boolean())
		{
			retval._boolean = get_property("gingerbreadCityAvailable").to_boolean() || get_property("_gingerbreadCityToday").to_boolean();
		}
		break;
	case $location[Gingerbread Sewers]:
		if(get_property("gingerSewersUnlocked").to_boolean())
		{
			retval._boolean = get_property("gingerbreadCityAvailable").to_boolean() || get_property("_gingerbreadCityToday").to_boolean();
		}
		break;
	case $location[Gingerbread Civic Center]:
	case $location[Gingerbread Industrial Zone]:
	case $location[Gingerbread Train Station]:
		retval._boolean = get_property("gingerbreadCityAvailable").to_boolean() || get_property("_gingerbreadCityToday").to_boolean();
		break;

	case $location[The Bandit Crossroads]:
		retval._boolean = get_property("_frAreasUnlocked").contains_text(loc);
		break;
	case $location[The Towering Mountains]:
		retval._boolean = get_property("_frAreasUnlocked").contains_text(loc);
		break;
	case $location[The Mystic Wood]:
		retval._boolean = get_property("_frAreasUnlocked").contains_text(loc);
		break;
	case $location[The Putrid Swamp]:
		retval._boolean = get_property("_frAreasUnlocked").contains_text(loc);
		break;
	case $location[The Cursed Village]:
		retval._boolean = get_property("_frAreasUnlocked").contains_text(loc);
		break;
	case $location[The Sprawling Cemetery]:
		retval._boolean = get_property("_frAreasUnlocked").contains_text(loc);
		break;

	case $location[Monorail Work Site]:
		retval._boolean = false;
		break;


	//Special cases that we are not going to worry too much about.
	case $location[A Maze of Sewer Tunnels]:
		if(my_adventures() >= 10)
		{
			retval._boolean = true;
		}
		break;

#	This is just to do a mass test.
#	default:
#		abort("Can't find " + loc);
#		break;
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
	case $location[8-Bit Realm]:
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

location[int] zone_list()
{
	return List($locations[8-Bit Realm, A-Boo Peak, The Arid\, Extra-Dry Desert, The Bandit Crossroads, Barf Mountain, Barrrney\'s Barrr, The Bat Hole Entrance, The Batrat And Ratbat Burrow, The Battlefield (Frat Uniform), The Beanbat Chamber, Belowdecks, The Black Forest, The Boss Bat\'s Lair, The Bubblin\' Caldera, The Bugbear Pen, The Castle in the Clouds in the Sky (Basement), The Castle in the Clouds in the Sky (Ground Floor), The Castle in the Clouds in the Sky (Top Floor), Cobb\'s Knob Barracks, Cobb\'s Knob Harem, Cobb\'s Knob Kitchens, Cobb\'s Knob Treasury, Coldest Adventurer Contest, The Copperhead Club, The Cursed Village, The Daily Dungeon, The Dark Elbow of the Woods, The Dark Heart of the Woods, The Dark Neck of the Woods, The Deep Dark Jungle, The Deep Machine Tunnels, The Defiled Alcove, The Defiled Cranny, The Defiled Niche, The Defiled Nook, Drunken Stupor, The Dungeons of Doom, The Enormous Greater-Than Sign, The Extreme Slope, The F\'c\'le, Fastest Adventurer Contest, The Feeding Chamber, The Filthworm Queen\'s Chamber, The Fun-Guy Mansion, Gingerbread Civic Center, Gingerbread Industrial Zone, Gingerbread Sewers, Gingerbread Train Station, Gingerbread Upscale Retail District, The Goatlet, Guano Junction, The Haiku Dungeon, The Hatching Chamber, The Haunted Ballroom, The Haunted Bathroom, The Haunted Bedroom, The Haunted Billiards Room, The Haunted Boiler Room, The Haunted Conservatory, The Haunted Gallery, The Haunted Kitchen, The Haunted Laundry Room, The Haunted Library, The Haunted Pantry, The Haunted Wine Cellar, The Hidden Apartment Building, The Hidden Bowling Alley, The Hidden Hospital, The Hidden Office Building, The Hidden Park, The Hidden Temple, The Hole in the Sky, Hottest Adventurer Contest, The Ice Hole, The Ice Hotel, The Icy Peak, Infernal Rackets Backstage, Inside the Palindome, Investigating A Plaintive Telegram, Itznotyerzitz Mine, Lair of the Ninja Snowmen, LavaCo&trade; Lamp Factory, The Laugh Floor, The Limerick Dungeon, The Lower Chambers, Madness Bakery, The Mansion of Dr. Weirdeaux, A Massive Ziggurat, A Maze Of Sewer Tunnels, The Middle Chamber, Mist-Shrouded Peak, A Mob Of Zeppelin Protesters, Monorail Work Site, The Mystic Wood, Near an Abandoned Refrigerator, Next to that Barrel with Something Burning in it, Noob Cave, The Oasis, The Obligatory Pirate\'s Cove, Oil Peak, The Old Landfill, Out by that Rusted-Out Car, The Outskirts of Cobb\'s Knob, Over Where the Old Tires Are, The Overgrown Lot, An Overgrown Shrine (Northeast), An Overgrown Shrine (Northwest), An Overgrown Shrine (Southeast), An Overgrown Shrine (Southwest), Pandamonium Slums, The Penultimate Fantasy Airship, Pirates of the Garbage Barges, The Poop Deck, The Putrid Swamp, The Red Queen\'s Garden, The Red Zeppelin, The Royal Guard Chamber, The Secret Government Laboratory, The Shore\, Inc. Travel Agency, The Skeleton Store, Sleaziest Adventurer Contest, The Sleazy Back Alley, Sloppy Seconds Diner, The Skeleton Store, Smartest Adventurer Contest, The SMOOCH Army HQ, Smoothest Adventurer Contest, South of the Border, Spookiest Adventurer Contest, The Spooky Gravy Burrow, The Sprawling Cemetery, Stinkiest Adventurer Contest, Strongest Adventurer Contest, The Smut Orc Logging Camp, Sonofa Beach, The Spooky Forest, Summoning Chamber, The Sunken Party Yacht, Super Villain\'s Lair, The Themthar Hills, The Thinknerd Warehouse, Throne Room, Through the Spacegate, Thugnderdome, The Towering Mountains, The Toxic Teacups, Twin Peak, The Typical Tavern Cellar, Uncle Gator\'s Country Fun-Time Liquid Waste Sluice, The Upper Chamber, The Velvet / Gold Mine, The VERY Unquiet Garves, VYKEA, The X-32-F Combat Training Snowman, Wartime Hippy Camp (Frat Disguise), Whitey\'s Grove]);
}

location[int] zones_available()
{
	location[int] retval;
	foreach idx, loc in zone_list()
	{
		if(zone_isAvailable(loc))
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
