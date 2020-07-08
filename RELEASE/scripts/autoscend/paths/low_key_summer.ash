script "low_key_summer.ash"

// These are listed in the order they will be iterated (item id ascending) to make debugging easier.
location[item] lowKeys;
lowKeys[$item[Clown car key]] = $location[The \"Fun\" House];
lowKeys[$item[Batting cage key]] = $location[The Bat Hole Entrance];
lowKeys[$item[aqu&iacute;]] = $location[South of the Border];
lowKeys[$item[Knob labinet key]] = $location[Cobb\'s Knob Laboratory];
lowKeys[$item[Weremoose key]] = $location[Cobb\'s Knob Menagerie, Level 2];
lowKeys[$item[Peg key]] = $location[The Obligatory Pirate\'s Cove];
lowkeys[$item[Kekekey]] = $location[The Valley of Rof L\'m Fao];
lowKeys[$item[Rabbit\'s foot key]] = $location[The Dire Warren];
lowKeys[$item[knob shaft skate key]] = $location[The Knob Shaft];
lowKeys[$item[Ice Key]] = $location[The Icy Peak];
lowKeys[$item[Anchovy can key]] = $location[The Haunted Pantry];
lowKeys[$item[cactus key]] = $location[The Arid\, Extra-Dry Desert];
lowKeys[$item[F\'c\'le sh\'c\'le k\'y]] = $location[The F\'c\'le];
lowKeys[$item[Treasure chest key]] = $location[Belowdecks];
lowKeys[$item[Demonic key]] = $location[Pandamonium Slums];
lowKeys[$item[Key sausage]] = $location[Cobb\'s Knob Kitchens];
lowKeys[$item[Knob treasury key]] = $location[Cobb\'s Knob Treasury];
lowKeys[$item[scrap metal key]] = $location[The Old Landfill];
lowKeys[$item[Black rose key]] = $location[The Haunted Conservatory];
lowKeys[$item[Actual skeleton key]] = $location[The Skeleton Store];
lowKeys[$item[Music Box Key]] = $location[The Haunted Nursery];
lowKeys[$item[Deep-fried key]] = $location[Madness Bakery];
lowKeys[$item[Discarded bike lock key]] = $location[The Overgrown Lot];

boolean in_lowkeysummer()
{
	return auto_my_path() == "Low Key Summer";
}

void lowkey_initializeSettings()
{
	if (!in_lowkeysummer())
	{
		return;
	}

	// TODO?
}

boolean lowkey_needKey(item key)
{
	if (internalQuestStatus("questL13Final") != 5)
	{
		return false;
	}

	return key.available_amount() == 0 && !contains_text(get_property("nsTowerDoorKeysUsed"), key);
}

int lowkey_keyDelayRemaining(location loc)
{
	if (!in_lowkeysummer())
	{
		return 0;
	}

	return max(11 - loc.turns_spent, 0);
}

int lowkey_keysRemaining()
{
	if (!in_lowkeysummer())
	{
		return 0;
	}

	int found = 0;
	foreach key in lowKeys
	{
		location loc = lowKeys[key];
		if (!lowkey_needKey(key))
		{
			found++;
		}
	}

	return 23 - found;
}

// order is subjective
location lowkey_nextKeyLocation(boolean checkAvailable)
{
	if (!in_lowkeysummer())
	{
		return $location[none];
	}

	foreach key in lowKeys
	{
		location loc = lowKeys[key];
		if (lowkey_needKey(key))
		{
			if (!checkAvailable || zone_isAvailable(loc))
			{
				return lowKeys[key];
			}
		}
	}

	return $location[none];
}

location lowkey_nextKeyLocation()
{
	return lowkey_nextKeyLocation(false);
}

location lowkey_nextAvailableKeyLocation()
{
	return lowkey_nextKeyLocation(true);
}

location lowkey_nextAvailableKeyDelayLocation()
{
	if (!in_lowkeysummer())
	{
		return $location[none];
	}

	foreach key in lowKeys
	{
		location loc = lowKeys[key];
		if (lowkey_needKey(key) && zone_isAvailable(loc) && lowkey_keyDelayRemaining(loc) > 0)
		{
			return lowKeys[key];
		}
	}

	return $location[none];
}

boolean lowkey_keyAdv(item key)
{
	if (!lowkey_needKey(key))
	{
		return false;
	}

	location loc = lowKeys[key];
	if (!zone_isAvailable(loc))
	{
		return false;
	}

	// Pirate equipment
	if ($locations[The F\'c\'le, Belowdecks] contains loc)
	{
		if (possessEquipment($item[pirate fledges]))
		{
			autoEquip($item[pirate fledges]);
		}
		else if (have_outfit("swashbuckling getup"))
		{
			autoEquip($item[eyepatch]);
			autoEquip($item[swashbuckling pants]);
			autoEquip($item[stuffed shoulder parrot]);
		}
		else
		{
			// Shouldn't get here due to zone_isAvailable check
			return false;
		}
	}

	return autoAdv(1, loc);
}

boolean lowkey_zoneUnlocks()
{
	if (startHippyBoatmanSubQuest())
	{
		// opens The Old Landfill for scrap metal key (+20% to all Moxie Gains)
		return true;
	}

	if (startArmorySubQuest())
	{
		// opens Madness Bakery for deep-fried key (+3 sleaze res, +15 sleaze dmg, +30 sleaze spell dmg)
		return true;
	}

	if (startGalaktikSubQuest() || finishGalaktikSubQuest())
	{
		// opens The Overgrown Lot for discarded bike lock key (+10 MP, 4-5 MP regen)
		return true;
	}

	if (startMeatsmithSubQuest() || finishMeatsmithSubQuest()) {
		// opens The Skeleton Store for actual skeleton key (100 DA, 10 DR)
		return true;
	}

	return false;
}

boolean LX_findHelpfulLowKey()
{
	if (!in_lowkeysummer())
	{
		return false;
	}

	if (internalQuestStatus("questL13Final") != 5)
	{
		return false;
	}

	if (lowkey_zoneUnlocks())
	{
		return true;
	}

	// mainstat
	if (my_level() < 13)
	{
		// needs knob lab access
		if (my_primestat() == $stat[Muscle] && lowkey_keyAdv($item[Knob labinet key])) { return true; }
		// needs accept landfil quest
		if (my_primestat() == $stat[Moxie] && (LX_hippyBoatman() || lowkey_keyAdv($item[scrap metal key]))) { return true; }
		// Needs Pandamonium access
		if (my_primestat() == $stat[Mysticality] && lowkey_keyAdv($item[Demonic key])) { return true; }
	}

	// familiar weight
	if (lowkey_keyAdv($item[Black rose key])) { return true; }

	// -combat. Key sausage needs Cobb's Knob Access
	if (lowkey_keyAdv($item[Key sausage])) { return true; }

	// +item
	// Treasure chest key needs Belowdecks access
	if (lowkey_keyAdv($item[Treasure chest key])) { return true; }

	// +meat. Knob treasury key needs Cobb's Knob Access. Kekekey needs The Valley of Rof L'm Fao access.
	if (lowkey_keyAdv($item[Kekekey])) { return true; }
	if (my_primestat() != $stat[Mysticality] || possessEquipment($item[Demonic key])) {
		// all these locations unlock at the same time but for a myst class we should only get
		//  the -combat key from Cobb's Knob (above) to speed up the friars before we have the +20% myst xp key
		if (lowkey_keyAdv($item[Knob treasury key])) { return true; }

		// +adv. Knob shaft skate key needs Cobb's Knob lab key for access to Knob Shaft
		if (lowkey_keyAdv($item[Knob shaft skate key])) { return true; }

		// Knob labinet key to unlock Menagerie. needs Cobb's Knob lab key for access to the lab
		if (item_amount($item[Cobb\'s Knob Menagerie key]) < 1 && lowkey_keyAdv($item[Knob labinet key])) { return true; }
	}

	if (internalQuestStatus("questL09Topping") > 0 && internalQuestStatus("questL09Topping") < 3) {
		// +ml (before oil peak)
		// F'c'le sh'c'le k'y needs F'c'le access
		if (lowkey_keyAdv($item[F\'c\'le sh\'c\'le k\'y])) { return true; }
		// Clown car key needs "Fun" house access
		if (lowkey_keyAdv($item[Clown car key])) { return true; }
		// cold res before aboo. Needs Icy Peak Access
		if (lowkey_keyAdv($item[Ice Key])) { return true; }
		// spooky res before aboo. Needs Menagerie access.
		if (lowkey_keyAdv($item[Weremoose key])) { return true; }
	}

	// sleaze damage before red zeppelin
	if (internalQuestStatus("questL11Ron") > -1 && internalQuestStatus("questL11Ron") < 2) {
		if (lowkey_keyAdv($item[Deep-fried key])) { return true; }
		// Clown car key needs "Fun" house access
		if (lowkey_keyAdv($item[Clown car key])) { return true; }
	}

	// cold spell damage before orcs. Ice Key needs The Icy Peak access
	if (internalQuestStatus("questL09Topping") == 0 && get_property("chasmBridgeProgress").to_int() < 30)
	{
		if (lowkey_keyAdv($item[Ice Key])) { return true; }
	}

	// +combat before sonofa. Music Box Key needs Spookyraven Manor third floor access
	if (internalQuestStatus("questL12War") == 1 && get_property("sidequestLighthouseCompleted") == "none")
	{
		if (lowkey_keyAdv($item[Music Box Key])) { return true; }
	}

	// Attributes. This is a nowander zone so burning delay here is unlikely.
	//if (lowkey_keyAdv($item[Rabbit\'s foot key])) { return true; }

	// food drops?
	//if (lowkey_keyAdv($item[Anchovy can key])) { return true; }

	return false;
}

boolean L13_sorceressDoorLowKey()
{
	if (!in_lowkeysummer())
	{
		return false;
	}

	if (internalQuestStatus("questL13Final") != 5)
	{
		return false;
	}

	location loc = lowkey_nextAvailableKeyLocation();

	if (loc == $location[none])
	{
		int remaining = lowkey_keysRemaining();
		if (remaining > 0)
		{
			auto_log_warning("Unable to adventure for remaining low keys");
			foreach key in lowKeys
			{
				if (lowkey_needKey(key))
				{
					auto_log_warning(lowKeys[key] + ": " + key);
				}
			}
			abort("Please unlock zones manually and try again.");
		}
		// Unlock door
		if (tower_door()) {
			return true;
		}
		return false;
	}

	return autoAdv(1, loc);
}

boolean LX_lowkeySummer() {

	if (!in_lowkeysummer()) { return false; }

	// Guild access
	if (LX_guildUnlock()) { return true; }

	// Find keys that help us save adventures in quests.
	if (LX_findHelpfulLowKey()) { return true; }

	// Cobb's Knob unlocks a lot of zones which contain generally useful keys for all classes (-combat, +meat, +adv).
	// Also the +20% to all Muscle Gains key unlocks here.
	if (L5_getEncryptionKey() || L5_findKnob()) { return true; }

	if (my_primestat() == $stat[Mysticality] && possessEquipment($item[Key sausage])) {
		// Myst classes want access to Pandamonium Slums to find the demonic key (+20% to all Mysticality Gains).
		// Get the -combat key first.
		if (L6_friarsGetParts()) { return true; }
	}

	// Island access for all classes. also farm the +20% to all Moxie Gains key
	// (adventuring will be handled by LX_findHelpfulLowKey() for moxie classes but this'll complete the quest)
	if (LX_hippyBoatman()) { return true; }

	// Desert access, Daily Dungeon and other early random stuff.
	if (LX_loggingHatchet() || LX_unlockDesert() || LX_lockPicking() || LX_phatLootToken()) { return true; }

	// Get the Steel Organ if the user wants it (probably good in this path since turnbloat).
	if (LX_steelOrgan()) { return true; }
	
	// Get the -combat key before attempting the Friars or the Spooky Forest. Also high priority to unlock the hidden temple for SR.
	if (possessEquipment($item[Key sausage])) {
		if (L6_friarsGetParts()
			|| L2_mosquito()
			|| LX_unlockHiddenTemple()
			|| LX_unlockHauntedLibrary()
			|| LX_getLadySpookyravensDancingShoes()
			|| LX_getLadySpookyravensPowderPuff()) { return true; }
	} else {
		// Make sure Cobb's Knob is open so we can get the key.
		if (L5_getEncryptionKey() || L5_findKnob()) { return true; }
	}

	if (internalQuestStatus("questL12War") > -1) {
		// Don't start the war unless we've acquired the key from Belowdecks first as it gives +item.
		if (possessEquipment($item[Treasure Chest key])) {
			if (L12_preOutfit() || L12_getOutfit() || L12_startWar() || L12_flyerFinish()) { return true; }
		} else {
			// Make sure Belowdecks is open so we can get the key.
			if (LX_pirateQuest()) { return true; }
		}

		// Get the +combat key before attempting Sonofa Beach.
		if (possessEquipment($item[Music Box Key])) {
			if (L12_sonofaBeach() || L12_sonofaFinish()) { return true; }
		} else {
			// Make sure Spookyraven Third Floor is open so we can get the key.
			if (LX_spookyravenManorFirstFloor() || LX_spookyravenManorSecondFloor()) { return true; }
		}

		// Get the +meat keys before attempting Themthar Hills.
		if (possessEquipment($item[Knob treasury key]) && possessEquipment($item[Kekekey])) {
			if (L12_themtharHills()) { return true; }
		} else {
			// Make sure Cobb's Knob is open so we can get the key.
			if (L5_getEncryptionKey() || L5_findKnob()) { return true; }
			// Make sure The Valley is open so we can get the key.
			if (L9_chasmBuild() || L9_highLandlord()) { return true; }
		}

		// Do the rest of the war. Should have the +item key already before we start the war.
		if (L12_gremlins() || L12_filthworms() || L12_orchardFinalize() || L12_farm() || L12_finalizeWar()) { return true; }
	}

	// Start the macguffin quest as we need it to unlock Belowdecks.
	if (L11_blackMarket() || L11_forgedDocuments() || L11_mcmuffinDiary() || L11_getBeehive()) { return true; }

	// Lock in the Shen zones as soon as we can.
	if (L11_shenStartQuest()) { return true; }

	if (internalQuestStatus("questL09Topping") > -1) {
		// Get the Cold Damage key before doing the Orcs
		// This gets blocked by the Shen softlock so do it as soon as we feasibly can as one of the +meat keys requires the L9 quest finished.
		if (possessEquipment($item[Ice Key])) {
			if (L9_chasmBuild()) { return true; }
		} else {
			// Make sure the Icy Peak is available so we can get the key
			if (L8_trapperQuest()) { return true; }
		}
		// Get the ML keys before doing Oil peak and Spooky Res key before doing Aboo Peak (should have Cold Res key already for the Orc Chasm).
		if (possessEquipment($item[F\'c\'le sh\'c\'le k\'y]) 
				&& possessEquipment($item[Clown car key])
				&& possessEquipment($item[Weremoose key])) {
			if (L9_highLandlord()) { return true; }
		} else {
			// Make sure the F'c'le is open so we can get the key
			if (LX_pirateOutfit() || LX_joinPirateCrew()) { return true; }
			// Make sure the "Fun" House is open so we can get the key
			if (LX_acquireEpicWeapon()) { return true; }
		}
	}

	if (internalQuestStatus("questL11MacGuffin") > -1) {
		// open the hidden city up.
		if (L11_nostrilOfTheSerpent() || L11_unlockHiddenCity()) { return true; }

		// +item helps with getting fulminate ingredients, Hidden City drops and Copperhead/Zeppelin.
		if (possessEquipment($item[Treasure Chest key])) {
			if (L11_talismanOfNam() || L11_mauriceSpookyraven()) { return true; }
		} else {
			// Make sure Belowdecks is open so we can get the key.
			if (LX_pirateQuest()) { return true; }
		}

		// Dance with lady spookyraven so we can go murder her undead husband and take the Eye of Ed
		if (LX_spookyravenManorFirstFloor() || LX_spookyravenManorSecondFloor()) { return true; }

		// Murder pygmies for the ancient amulet.
		if (L11_hiddenCityZones() || L11_hiddenCity()) { return true; }

		// Finish the other Macguffin zones so we can beat Ed to death repeatedly and waste all his Ka coins.
		if (L11_palindome() || L11_aridDesert() || L11_unlockPyramid()) { return true; }
		// should do the tavern before trying to do the pyramid so we can use any tangles we get lucky with.
		if (internalQuestStatus("questL03Rat") > 2) {
			if (L11_unlockEd() || L11_defeatEd()) { return true; }
		} else {
			set_property("auto_forceTavern", true);
			if (L3_tavern()) { return true; }
		}
	}

	// Open up the top of the beanstalk.
	if (L10_plantThatBean()) { return true; }

	// Should have the -combat key long before level 10 but lets just make sure.
	if (possessEquipment($item[Key sausage])) {
		if (L10_airship() || L10_basement() || L10_ground() || L10_topFloor() || L10_holeInTheSkyUnlock()) { return true; }
	} else {
		// Make sure Cobb's Knob is open so we can get the key.
		if (L5_getEncryptionKey() || L5_findKnob()) { return true; }
	}

	// Ascend the peak.
	if (L8_trapperQuest()) { return true; }

	// -combat and ML keys help with 2 of these zones but this quest is a monolithic function.
	// TODO: split it up into zones then guard with possession of keys.
	if (L7_crypt()) { return true; }

	// Finish off the Goblin King.
	if (L5_slayTheGoblinKing()) { return true; }

	// Show the Boss bat who's boss.
	if (L4_batCave()) { return true; }

	// Fix that dripping tap.
	if (L3_tavern()) { return true; }

	// this quest and these zones are open either from the start or level 4.
	// so lets do this if we have nothing better to do yet.
	if (possessEquipment($item[aqu&iacute;]) && possessEquipment($item[batting cage key])) {
		if (LX_unlockHauntedBilliardsRoom()) { return true; }
	} else {
		// hot res for the Haunted Kitchen. aquí needs Desert Beach Access
		if (lowkey_keyAdv($item[aqu&iacute;])) { return true; }
		// stench res for the Haunted Kitchen
		if (lowkey_keyAdv($item[batting cage key])) { return true; }
	}

	// Spookyraven quest steps that don't need -combat or resists, just monster killin' (or dancing with a ghost for stats).
	if (LX_danceWithLadySpookyraven() || LX_getLadySpookyravensFinestGown() || LX_unlockManorSecondFloor()) { return true; }

	if (L12_clearBattlefield()) { return true; } // This is a mess and if it's not last, it screws up the war massively.

	// Stuff we need to do in this path to unlock key zones.
	if (LX_pirateQuest()) { return true; }
	if (LX_acquireEpicWeapon()) { return true; }

	// If literally nothing better to do, go find some of the keys we don't actually care about but have to find anyway.
	location loc = lowkey_nextAvailableKeyLocation();
	if (loc != $location[none] && autoAdv(loc)) { return true; }

	// unlock the door, climb the tower, commit sorceresscide.
	if (L13_sorceressDoor() || L13_towerNSTower() || L13_towerNSNagamar() || L13_towerNSFinal()) { return true; }

	// Release the softblock on quests that are waiting for Shen quest.
	if (my_level() > get_property("auto_shenSkipLastLevel").to_int() && get_property("questL11Shen") != "finished") {
		auto_log_warning("I was trying to avoid zones that Shen might need, but I've run out of stuff to do.", "red");
		set_property("auto_shenSkipLastLevel", my_level());
		return true;
	}

	if (LX_attemptPowerLevel()) { return true; }
	
	return false;
}