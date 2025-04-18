#	This is meant for items that have a date of 2015
#	Handling: shrine to the Barrel God, Chateau Mantegna Room Key, Deck of Every Card
#

boolean auto_haveLovebugs()
{
	return get_property("lovebugsUnlocked").to_boolean() && auto_is_valid($skill[Summon Love Stinkbug]);
}

boolean mayo_acquireMayo(item it)
{
	if(!is_unrestricted($item[Portable Mayo Clinic]))
	{
		return false;
	}
	if(!(auto_get_campground() contains $item[Portable Mayo Clinic]))
	{
		return false;
	}
	return true;
}

boolean auto_barrelPrayers()
{
	if(!is_unrestricted($item[Shrine to the Barrel God]))
	{
		return false;
	}
	if(get_property("_barrelPrayer").to_boolean())
	{
		return false;
	}
	if(!get_property("barrelShrineUnlocked").to_boolean())
	{
		string temp = visit_url("da.php");
		if(!get_property("barrelShrineUnlocked").to_boolean())
		{
			return false;
		}
	}
	if(inAftercore())
	{
		return false;
	}

	boolean[string] prayers;

	if(in_lta())
	{
		switch(my_daycount())
		{
		case 1:				prayers = $strings[Glamour, Protection, Vigor];		break;
		case 2:				prayers = $strings[Glamour, Vigor, Protection];		break;
		case 3:				prayers = $strings[Protection, Glamour, Vigor];		break;
		case 4:				prayers = $strings[Protection, Glamour, Vigor];		break;
		}
	}
	else if(in_nuclear())
	{
		switch(my_daycount())
		{
		case 1:				prayers = $strings[Vigor, Glamour];					break;
		case 2:				prayers = $strings[Vigor, Glamour];					break;
		case 3:				prayers = $strings[Glamour, Vigor];					break;
		case 4:				prayers = $strings[Glamour, Vigor];					break;
		}
	}
	else if(in_theSource())
	{
		switch(my_daycount())
		{
		case 1:				prayers = $strings[Glamour, Vigor, Protection];		break;
		case 2:				prayers = $strings[Protection, Glamour, Vigor];		break;
		case 3:				prayers = $strings[Protection, Glamour, Vigor];		break;
		case 4:				prayers = $strings[Protection, Glamour, Vigor];		break;
		}
	}
	else if(in_awol())
	{
		switch(my_daycount())
		{
		case 1:				prayers = $strings[Glamour, Vigor, Protection];		break;
		case 2:				prayers = $strings[Protection, Glamour, Vigor];		break;
		case 3:				prayers = $strings[Protection, Glamour, Vigor];		break;
		case 4:				prayers = $strings[Protection, Glamour, Vigor];		break;
		}
	}
	else if(is_boris())
	{
		switch(my_daycount())
		{
		case 1:				prayers = $strings[none];							break;
		case 2:				prayers = $strings[Glamour, Vigor];					break;
		case 3:				prayers = $strings[Glamour, Vigor];					break;
		case 4:				prayers = $strings[Glamour, Vigor];					break;
		}
	}
	else if(is_pete())
	{
		switch(my_daycount())
		{
		case 1:				prayers = $strings[Glamour, Vigor, Protection];		break;
		case 2:				prayers = $strings[Protection, Glamour, Vigor];		break;
		case 3:				prayers = $strings[Protection, Glamour, Vigor];		break;
		case 4:				prayers = $strings[Protection, Glamour, Vigor];		break;
		}
	}
	else if(is_jarlsberg())
	{
		switch(my_daycount())
		{
		case 1:				prayers = $strings[Glamour, Vigor, Protection];		break;
		case 2:				prayers = $strings[Protection, Glamour, Vigor];		break;
		case 3:				prayers = $strings[Protection, Glamour, Vigor];		break;
		case 4:				prayers = $strings[Protection, Glamour, Vigor];		break;
		}
	}
	else if(in_wotsf())
	{
		switch(my_daycount())
		{
		case 1:				prayers = $strings[none];							break;
		case 2:				prayers = $strings[Glamour, Vigor];					break;
		case 3:				prayers = $strings[Glamour, Vigor];					break;
		case 4:				prayers = $strings[Glamour, Vigor];					break;
		}
	}
	else if(in_heavyrains())
	{
		switch(my_daycount())
		{
		case 1:				prayers = $strings[Glamour, Vigor];					break;
		case 2:				prayers = $strings[Glamour, Vigor];					break;
		case 3:				prayers = $strings[Glamour, Vigor];					break;
		case 4:				prayers = $strings[Glamour, Vigor];					break;
		}
	}
	else if(isActuallyEd())
	{
		if((elementalPlanes_access($element[spooky])) && (get_property("edPoints").to_int() >= 2))
		{
			switch(my_daycount())
			{
			case 1:				prayers = $strings[Protection, Glamour, Vigor];		break;
			case 2:				prayers = $strings[Protection, Glamour, Vigor];		break;
			case 3:				prayers = $strings[Protection, Glamour, Vigor];		break;
			case 4:				prayers = $strings[Protection, Glamour, Vigor];		break;
			}
		}
		else
		{
			switch(my_daycount())
			{
			case 1:				prayers = $strings[Glamour, Vigor, Protection];		break;
			case 2:				prayers = $strings[Protection, Glamour, Vigor];		break;
			case 3:				prayers = $strings[Protection, Glamour, Vigor];		break;
			case 4:				prayers = $strings[Protection, Glamour, Vigor];		break;
			}
		}
	}
	else
	{
		switch(my_daycount())
		{
		case 1:				prayers = $strings[Glamour, Protection, Vigor];		break;
		case 2:				prayers = $strings[Protection, Glamour, Vigor];		break;
		case 3:				prayers = $strings[Protection, Glamour, Vigor];		break;
		case 4:				prayers = $strings[Protection, Glamour, Vigor];		break;
		}
	}

	foreach prayer in prayers
	{
		if(prayer == "none")
		{
			return false;
		}
		if(!get_property("prayedFor" + prayer).to_boolean())
		{
			boolean buff = cli_execute("barrelprayer " + prayer);
			return true;
		}
	}

	return false;
}


boolean auto_mayoItems()
{
	if(!is_unrestricted($item[Portable Mayo Clinic]))
	{
		return false;
	}
	if(get_property("_mayoDeviceRented").to_boolean())
	{
		return false;
	}
	if(inAftercore())
	{
		return false;
	}
	if(!(auto_get_campground() contains $item[Portable Mayo Clinic]))
	{
		return false;
	}
	if(my_meat() < 10000)
	{
		return false;
	}

	boolean haveYR = false;
	if(have_familiar($familiar[Crimbo Shrub]))
	{
		haveYR = true;
	}

	boolean[item] mayos;
	if(is_boris())
	{
		switch(my_daycount())
		{
		case 1:				mayos = $items[Tomayohawk-Style Reflex Hammer];		break;
		case 2:				mayos = $items[Mayo Lance];							break;
		case 3:				mayos = $items[Mayo Lance];							break;
		case 4:				mayos = $items[Mayo Lance];							break;
		}
	}
	else if(in_heavyrains() && !in_hardcore())
	{
		switch(my_daycount())
		{
		case 1:				mayos = $items[none];								break;
		case 2:				mayos = $items[Miracle Whip];						break;
		case 3:				mayos = $items[Sphygmayomanometer];					break;
		case 4:				mayos = $items[Sphygmayomanometer];					break;
		}
	}
	else if(in_gnoob())
	{
		switch(my_daycount())
		{
		default:			mayos = $items[none];								break;
		}
	}
	else if(in_lta())
	{
		switch(my_daycount())
		{
		default:			mayos = $items[none];								break;
		}
	}
	else
	{
		switch(my_daycount())
		{
		case 1:				mayos = $items[Mayo Lance];							break;
		case 2:				mayos = $items[Mayo Lance];							break;
		case 3:				mayos = $items[Mayo Lance];							break;
		case 4:				mayos = $items[Mayo Lance];							break;
		}
	}

	foreach mayo in mayos
	{
		if(mayo == $item[Mayo Lance])
		{
			if(have_familiar($familiar[Crimbo Shrub]))
			{
				continue;
			}
			if(have_familiar($familiar[Intergnat]))
			{
				continue;
			}
		}
		if(mayo == $item[none])
		{
			return false;
		}
		if(item_amount(mayo) == 0)
		{
			auto_buyUpTo(1, mayo);
			return true;
		}
	}

	return false;
}




boolean chateaumantegna_available()
{
	item chateau_key = wrap_item($item[Chateau Mantegna Room Key]);
	if(!in_lol() && get_property("chateauAvailable").to_boolean() && is_unrestricted(chateau_key))
	{
		return true;
	}
	if(in_lol() && get_property("replicaChateauAvailable").to_boolean() && is_unrestricted(chateau_key))
	{
		return true;
	}
	return false;
}

void chateaumantegna_useDesk()
{
	if(chateaumantegna_available())
	{
		string chateau = visit_url("place.php?whichplace=chateau");
		if(contains_text(chateau, "chateau_desk1"))
		{
			visit_url("place.php?whichplace=chateau&action=chateau_desk1");
		}
		else if(contains_text(chateau, "chateau_desk2"))
		{
			visit_url("place.php?whichplace=chateau&action=chateau_desk2");
		}
		else if(contains_text(chateau, "chateau_desk3"))
		{
			visit_url("place.php?whichplace=chateau&action=chateau_desk3");
		}
	}
}

boolean chateaumantegna_havePainting()
{
	if(chateaumantegna_available() && !contains_text(visit_url("place.php?whichplace=chateau"), "chateau_paintingnone"))
	{
		return !get_property("_chateauMonsterFought").to_boolean();
	}
	return false;
}



boolean chateaumantegna_usePainting(string option)
{
	if(!chateaumantegna_available())
	{
		return false;
	}
	if(get_property("_chateauMonsterFought").to_boolean())
	{
		return false;
	}

	if(get_property("chateauMonster") == $monster[lobsterfrogman])
	{
		if(item_amount($item[Barrel of Gunpowder]) >= 5)
		{
			return false;
		}
		if(get_property("sidequestLighthouseCompleted") != "none")
		{
			return false;
		}
	}
	if(get_property("chateauMonster") == $monster[Bram the Stoker])
	{
		if(have_equipped($item[Bram\'s Choker]) || (item_amount($item[Bram\'s Choker]) > 0))
		{
			return false;
		}
	}
	if(get_property("chateauMonster") == $monster[Mountain Man])
	{
		if(!needOre())
		{
			return false;
		}
	}
	if(chateaumantegna_available())
	{
		return autoAdvBypass("place.php?whichplace=chateau&action=chateau_painting", $location[Noob Cave], option);
	}
	return false;
}

boolean chateaumantegna_usePainting()
{
	return chateaumantegna_usePainting("");
}

boolean[item] chateaumantegna_decorations()
{
	boolean[item] retval;
	if(!chateaumantegna_available())
	{
		return retval;
	}
	string chateau = to_lower_case(visit_url("place.php?whichplace=chateau"));
	if(contains_text(chateau, "electric muscle stimulator"))
	{
		retval[$item[Electric Muscle Stimulator]] = true;
	}
	else if(contains_text(chateau, "foreign language tapes"))
	{
		retval[$item[Foreign Language Tapes]] = true;
	}
	else if(contains_text(chateau, "bowl of potpourri"))
	{
		retval[$item[Bowl of Potpourri]] = true;
	}
	if(contains_text(chateau, "antler chandelier"))
	{
		retval[$item[Antler Chandelier]] = true;
	}
	else if(contains_text(chateau, "artificial skylight"))
	{
		retval[$item[Artificial Skylight]] = true;
	}
	else if(contains_text(chateau, "ceiling fan"))
	{
		retval[$item[Ceiling Fan]] = true;
	}
	if(contains_text(chateau, "continental juice bar"))
	{
		retval[$item[Continental Juice Bar]] = true;
	}
	else if(contains_text(chateau, "fancy stationery set"))
	{
		retval[$item[Fancy Stationery Set]] = true;
	}
	else if(contains_text(chateau, "swiss piggy bank"))
	{
		retval[$item[Swiss Piggy Bank]] = true;
	}
	return retval;
}

void chateaumantegna_buyStuff(item toBuy)
{
	if(!chateaumantegna_available())
	{
		return;
	}

	if((toBuy == $item[Electric Muscle Stimulator]) && (my_meat() >= 500))
	{
		visit_url("shop.php?pwd=&whichshop=chateau&action=buyitem&whichrow=411&quantity=1", true);
	}
	if((toBuy == $item[Foreign Language Tapes]) && (my_meat() >= 500))
	{
		visit_url("shop.php?pwd=&whichshop=chateau&action=buyitem&whichrow=412&quantity=1", true);
	}
	if((toBuy == $item[Bowl of Potpourri]) && (my_meat() >= 500))
	{
		visit_url("shop.php?pwd=&whichshop=chateau&action=buyitem&whichrow=413&quantity=1", true);
	}

	if((toBuy == $item[Antler Chandelier]) && (my_meat() >= 1500))
	{
		visit_url("shop.php?pwd=&whichshop=chateau&action=buyitem&whichrow=415&quantity=1", true);
	}
	if((toBuy == $item[Artificial Skylight]) && (my_meat() >= 1500))
	{
		visit_url("shop.php?pwd=&whichshop=chateau&action=buyitem&whichrow=416&quantity=1", true);
	}
	if((toBuy == $item[Ceiling Fan]) && (my_meat() >= 1500))
	{
		visit_url("shop.php?pwd=&whichshop=chateau&action=buyitem&whichrow=414&quantity=1", true);
	}

	if((toBuy == $item[Continental Juice Bar]) && (my_meat() >= 2500))
	{
		visit_url("shop.php?pwd=&whichshop=chateau&action=buyitem&whichrow=418&quantity=1", true);
	}
	if((toBuy == $item[Fancy Calligraphy Pen]) && (my_meat() >= 2500))
	{
		visit_url("shop.php?pwd=&whichshop=chateau&action=buyitem&whichrow=419&quantity=1", true);
	}
	if((toBuy == $item[Swiss Piggy Bank]) && (my_meat() >= 2500))
	{
		visit_url("shop.php?pwd=&whichshop=chateau&action=buyitem&whichrow=417&quantity=1", true);
	}

	if((toBuy == $item[Alpine Watercolor Set]) && (my_meat() >= 5000))
	{
		visit_url("shop.php?pwd=&whichshop=chateau&action=buyitem&whichrow=420&quantity=1", true);
	}
}


boolean chateaumantegna_nightstandSet()
{
	if(!chateaumantegna_available())
	{
		return false;
	}

	stat myStat = my_primestat();
	if(myStat == $stat[none])
	{
		return false;
	}
	if(inAftercore())
	{
		return false;
	}
	if(my_level() >= 13)
	{
		if(get_property("nsContestants2").to_int() == -1)
		{
			myStat = get_property("nsChallenge1").to_stat();
		}
		else
		{
			return false;
		}
	}


	boolean[item] furniture = chateaumantegna_decorations();
	item need = $item[none];
	if(myStat == $stat[Muscle])
	{
		need = $item[Electric Muscle Stimulator];
	}
	else if(myStat == $stat[Mysticality])
	{
		need = $item[Foreign Language Tapes];
	}
	else if(myStat == $stat[Moxie])
	{
		need = $item[Bowl of Potpourri];
	}

	if(need == $item[none])
	{
		//If we do not have a telescope, this can happen.
		return false;
	}
	if(furniture[need])
	{
		return false;
	}
	if(my_meat() < npc_price(need))
	{
		return false;
	}
	auto_log_info("We have the wrong Chateau Nightstand item, replacing.", "blue");
	chateaumantegna_buyStuff(need);
	return true;
}

boolean chateauPainting()
{
	int paintingLevel = 8;
	if(in_ocrs())
	{
		paintingLevel = 9;
	}
	if(my_level() >= paintingLevel && chateaumantegna_havePainting() && !get_property("chateauMonsterFought").to_boolean() && isActuallyEd() && my_daycount() <= 3)
	{
		if(canYellowRay())
		{
			auto_sourceTerminalEducate($skill[Extract], $skill[Digitize]);
			if(chateaumantegna_usePainting())
			{
				return true;
			}
		}
	}

	if(organsFull() && my_adventures() < 10 && chateaumantegna_havePainting() && !get_property("chateauMonsterFought").to_boolean() && my_daycount() == 1 && !isActuallyEd())
	{
		auto_sourceTerminalEducate($skill[Extract], $skill[Digitize]);
		if(chateaumantegna_usePainting())
		{
			return true;
		}
	}
	if(my_level() >= 8 && chateaumantegna_havePainting() && !get_property("chateauMonsterFought").to_boolean() && my_daycount() == 2 && !isActuallyEd())
	{
		auto_sourceTerminalEducate($skill[Extract], $skill[Digitize]);
		if(chateaumantegna_usePainting())
		{
			return true;
		}
	}
	return false;
}


boolean deck_available()
{
	item deck = wrap_item($item[Deck of Every Card]);
	return ((item_amount(deck) > 0) && is_unrestricted(deck) && auto_is_valid(deck));
}

int deck_draws_left()
{
	if(!deck_available())
	{
		return 0;
	}
	if(my_hp() == 0)
	{
		return 0;
	}
	return 15 - get_property("_deckCardsDrawn").to_int();
}


boolean deck_draw()
{
	if(!deck_available())
	{
		return false;
	}
	if(deck_draws_left() <= 0)
	{
		return false;
	}
	if(my_hp() == 0)
	{
		return false;
	}
	item deck = wrap_item($item[Deck of Every Card]);
	string page = visit_url("inv_use.php?pwd=&which=3&whichitem="+deck.to_int());
	page = visit_url("choice.php?pwd=&whichchoice=1085&option=1", true);
	return true;
}

boolean deck_cheat(string cheat)
{
	if(!deck_available())
	{
		return false;
	}
	if(deck_draws_left() <= 0)
	{
		return false;
	}
	if(my_hp() == 0)
	{
		return false;
	}
	cheat = to_lower_case(cheat);
	static int [string] cards;
	cards["x of clubs"] = 1;
	cards["x of hearts"] = 2;
	cards["x of diamonds"] = 3;
	cards["x of spades"] = 4;
	cards["x of cups"] = 5;
	cards["x of wands"] = 6;
	cards["x of swords"] = 7;
	cards["x of coins"] = 8;
	cards["xiii - death"] = 9;
	cards["goblin sapper"] = 10;

	cards["the hive"] = 11;
	cards["hunky fireman card"] = 12;
	cards["v - the hierophant"] = 13;
	cards["xviii - the moon"] = 14;
	cards["werewolf"] = 15;
	cards["xv - the devil"] = 16;
	cards["fire elemental"] = 17;
	cards["slimer trading card"] = 18;
	cards["vii - the chariot"] = 19;
	cards["ii - the high priestess"] = 20;


	cards["xii - the hanged man"] = 21;
	cards["plantable greeting card"] = 22;
	cards["pirate birthday card"] = 23;
	cards["xiv - temperance"] = 24;
	cards["unstable portal"] = 25;
	cards["xvii - the star"] = 26;
	cards["suit warehouse discount card"] = 27;
	cards["christmas card"] = 28;
	cards["go fish"] = 29;
	cards["aquarius horoscope"] = 30;

	cards["plains"] = 31;
	cards["swamp"] = 32;
	cards["mountain"] = 33;
	cards["forest"] = 34;
	cards["island"] = 35;
	cards["healing salve"] = 36;
	cards["dark ritual"] = 37;
	cards["lightning bolt"] = 38;
	cards["giant growth"] = 39;
	cards["ancestral recall"] = 40;

	cards["gift card"] = 41;
	cards["x of papayas"] = 42;
	cards["x of salads"] = 43;
	cards["ix - the hermit"] = 44;
	cards["iv - the emperor"] = 45;
	cards["green card"] = 46;
	cards["xvi - the tower"] = 47;
	cards["the race card"] = 48;
	cards["0 - the fool"] = 49;
	cards["I - the magician"] = 50;

	cards["xi - strength"] = 51;
	cards["lead pipe"] = 52;
	cards["rope"] = 53;
	cards["wrench"] = 54;
	cards["candlestick"] = 55;
	cards["knife"] = 56;
	cards["revolver"] = 57;
	cards["1952 mickey mantle"] = 58;
	cards["spare tire"] = 59;
	cards["extra tank"] = 60;

	cards["sheep"] = 61;
	cards["year of plenty"] = 62;
	cards["mine"] = 63;
	cards["laboratory"] = 64;
	cards["x of kumquats"] = 65;
	cards["professor plum"] = 66;
	cards["x - the wheel of fortune"] = 67;
	cards["xxi - the world"] = 68;
	cards["vi - the lovers"] = 69;
	cards["iii - the empress"] = 70;

	cards["pvp"] = 1;
	cards["fites"] = 1;
	cards["spade"] = 4;
	cards["white mana"] = 31;
	cards["black mana"] = 32;
	cards["red mana"] = 33;
	cards["green mana"] = 34;
	cards["blue mana"] = 35;
	cards["key"] = 47;
	cards["tower"] = 47;
	cards["init"] = 48;
	cards["moxie buff"] = 49;
	cards["myst buff"] = 50;
	cards["mysticality buff"] = 50;
	cards["meat"] = 58;
	cards["muscle buff"] = 51;
	cards["stone wool"] = 61;
	cards["ore"] = 63;
	cards["items"] = 67;
	cards["muscle stat"] = 68;
	cards["moxie stat"] = 69;
	cards["myst stat"] = 70;
	cards["mysticality stat"] = 70;

	int card = cards[cheat];

	string[int] cheated = split_string(get_property("_deckCardsCheated"), ",");
	foreach idx, cheat in cheated
	{
		if(to_int(cheat) == card)
		{
			auto_log_warning("Already cheated this card, failing gracefully.", "red");
			return false;
		}
	}

	item deck = wrap_item($item[Deck of Every Card]);
	string page = visit_url("inv_use.php?cheat=1&pwd=&whichitem="+deck.to_int());

	// Check that a valid card was selected, otherwise this wastes 5 draws.
	if(card != 0)
	{
		string page = visit_url("choice.php?pwd=&option=1&whichchoice=1086&which=" + card, true);
		page = visit_url("choice.php?pwd=&whichchoice=1085&option=1", true);
		if(contains_text(page, "Combat"))
		{
			// Can we resolve this combat here? Should we?
			// Do we need to accept a combat filter?
		}
		
		handleTracker(deck,cheat, "auto_otherstuff");

		// If mafia is not tracking cheats, we can track them here.
		boolean found = false;
		string[int] cheated = split_string(get_property("_deckCardsCheated"), ",");
		foreach idx, cheat in cheated
		{
			if(to_int(cheat) == card)
			{
				found = true;
			}
		}
		if(!found)
		{
			if(get_property("_deckCardsCheated") == "")
			{
				set_property("_deckCardsCheated", card);
			}
			else
			{
				set_property("_deckCardsCheated", get_property("_deckCardsCheated") + "," + card);
			}
		}
		return true;
	}
	return false;
}


boolean deck_useScheme(string action)
{
	if(!deck_available())
	{
		return false;
	}
	if(deck_draws_left() < 15)
	{
		return false;
	}
	if(my_hp() == 0)
	{
		return false;
	}

	boolean[string] cards;

	if(action == "farming")
	{
		cards = $strings[Ancestral Recall, Island, 1952 Mickey Mantle];
	}
	else if(action == "turns")
	{
		cards = $strings[Ancestral Recall, Island];
		if(needOre())
		{
			cards = $strings[Ancestral Recall, Island, Mine];
		}
	}
	else
	{
		// First priority is grab a key if we need one.
		int missingHeroKeys = 3 - towerKeyCount();
		if (missingHeroKeys > 0)
		{
			cards["key"] = true;
		}
		// Next priority is ore, only if we don't have a train set installed
		if (!auto_haveTrainSet() && needOre())
		{
			cards["ore"] = true;
		}
		// Stats are higher priority early on in LoL where we're never gonna need stone wool day1
		if (in_lol() && my_level() < 4)
		{
			string mainstat = my_primestat().to_string().to_lower_case();
			cards[mainstat+" stat"] = true;
		}
		// Stone wool
		if (count(cards) < 3 && internalQuestStatus("questL11Worship") < 2 && item_amount($item[stone wool]) < 2)
		{
			cards["stone wool"] = true;
		}
		// Meat
	  if( count(cards) < 3 && my_meat() < 10000 && !in_wotsf()) {
			cards["1952 Mickey Mantle"] = true;
		}
		if( count(cards) < 3 && my_level() < 11 )
		{
			string mainstat = my_primestat().to_string().to_lower_case();
			cards[mainstat+" stat"] = true;
		}
	}

	if(count(cards) < 3)
	{
		cards["ancestral recall"] = true;
	}
	if(count(cards) < 3)
	{
		cards["blue mana"] = true;
	}

	if(count(cards) == 0)
	{
		return false;
	}

	int count = 0;
	foreach card in cards
	{
		if(possessEquipment($item[Bass Clarinet]) || possessEquipment($item[Fish Hatchet]) || possessEquipment($item[Dented Scepter]))
		{
			if($strings[Candlestick, Knight, Lead Pipe, Revolver, Rope, Wrench] contains card)
			{
				continue;
			}
		}

		if(card == "key")
		{
			if(towerKeyCount() >= 3)
			{
				continue;
			}
		}
		if(card == "ore")
		{
			if(!needOre())
			{
				continue;
			}
		}
		if(in_theSource() && (card == (my_primestat() + " stat")))
		{
			continue;
		}
		if(in_wotsf() && ($strings[Candlestick, Knife, Lead Pipe, Revolver, Rope, Wrench] contains card))
		{
			continue;
		}
		if((card == "1952 Mickey Mantle") && ((my_meat() >= 20000) || in_wotsf()))
		{
			continue;
		}
		if(count >= 3)
		{
			break;
		}
		if(deck_cheat(card))
		{
			count += 1;
		}
		else
		{
			auto_log_error("Could not draw card for some reason, we may be stuck in a choice adventure.");
			abort("Failure when drawing cards, if any were drawn, the rest will NOT be drawn. Draw them and resume.");
		}
	}

	if((action == "") && (my_meat() < 10000))
	{
		auto_autosell(min(1, item_amount($item[1952 Mickey Mantle Card])), $item[1952 Mickey Mantle Card]);
	}

	if((action == "farming") || (action == "turns"))
	{
		int count = item_amount($item[Blue Mana]);
		while((count > 0) && (get_property("_ancestralRecallCasts").to_int() < 10))
		{
			use_skill(1, $skill[Ancestral Recall]);
			count -= 1;
		}
	}

	return true;
}

boolean adjustEdHat(string goal)
{
	if(!possessEquipment($item[The Crown of Ed the Undying]))
	{
		return false;
	}
	int option = -1;
	goal = to_lower_case(goal);
	if(((goal == "muscle") || (goal == "bear")) && (get_property("edPiece") != "bear"))
	{
		option = 1;
	}
	else if(((goal == "myst") || (goal == "mysticality") || (goal == "owl")) && (get_property("edPiece") != "owl"))
	{
		option = 2;
	}
	else if(((goal == "moxie") || (goal == "puma")) && (get_property("edPiece") != "puma"))
	{
		option = 3;
	}
	else if(((goal == "ml") || (goal == "hyena")) && (get_property("edPiece") != "hyena"))
	{
		option = 4;
	}
	else if(((goal == "meat") || (goal == "item") || (goal == "items") || (goal == "drops") || (goal == "mouse")) && (get_property("edPiece") != "mouse"))
	{
		option = 5;
	}
	else if(((goal == "regen") || (goal == "regenerate") || (goal == "miss") || (goal == "dodge") || (goal == "weasel")) && (get_property("edPiece") != "weasel"))
	{
		option = 6;
	}
	else if(((goal == "breathe") || (goal == "underwater") || (goal == "fish")) && (get_property("edPiece") != "fish"))
	{
		option = 7;
	}

	item oldHat = equipped_item($slot[hat]);

	if(option != -1)
	{
		if(oldHat != $item[The Crown of Ed the Undying])
		{
			equip($slot[hat], $item[The Crown of Ed the Undying]);
		}
		visit_url("inventory.php?action=activateedhat");
		visit_url("choice.php?pwd=&whichchoice=1063&option=" + option, true);
		if(oldHat != $item[The Crown of Ed the Undying])
		{
			equip($slot[hat], oldHat);
		}
		return true;
	}
	return false;
}

boolean resolveSixthDMT()
{
	// In the Deep Machine Tunnels the sixth and every 50th visit after that in a single ascension will be a noncombat. This prepares for it and executes it.
	if(in_koe())
	{
		return false;
	}
	if(!canChangeToFamiliar($familiar[Machine Elf]))
	{
		return false;
	}
	if($location[The Deep Machine Tunnels].turns_spent != 5)
	// need to figure out the exact schedule for 2nd and later occurences then add it here.
	{
		return false;
	}

	handleFamiliar($familiar[Machine Elf]);
	return autoAdv($location[The Deep Machine Tunnels]);
}

void doghouseChoiceHandler(int choice)
{
	if(choice == 1106) // Wooof! Wooooooof! (Ghost Dog)
	{
		if((in_hardcore() && have_effect($effect[Adventurer\'s Best Friendship]) > 120) || ((have_effect($effect[Adventurer\'s Best Friendship]) > 30) && pathHasFamiliar()))
		{
			run_choice(3); // ghost dog chow
		}
		else
		{
			run_choice(2); // 30 turns of adventurer's best friendship
		}
	}
	else if(choice == 1107) // Playing Fetch (Ghost Dog)
	{
		run_choice(1); // get tennis ball
	}
	else if(choice == 1108) // Your Dog Found Something Again (Ghost Dog)
	{
		run_choice(3); // get other stuff as recommended by ASS
	}
	else
	{
		abort("unhandled choice in doghouseChoiceHandler");
	}
}
