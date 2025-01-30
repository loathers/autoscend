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
	return my_path() == $path[Low Key Summer];
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

int lowkey_levelNeededToUnlockZone(location loc)
{
	// returns level under which it is normal for the key zones not to be accessible in the path
	switch (loc)
	{
		case $location[The Arid\, Extra-Dry Desert]:
			return 11;
		case $location[Belowdecks]:
			return 11;
		case $location[The Valley of Rof L\'m Fao]:
			return 9;
		case $location[The Icy Peak]:
			return 8;
		case $location[The Old Landfill]:
			return 6;
		case $location[Cobb\'s Knob Laboratory]:
			return 5;
		case $location[Cobb\'s Knob Menagerie, Level 2]:
			return 5;
		case $location[The Knob Shaft]:
			return 5;
		case $location[Cobb\'s Knob Kitchens]:
			return 5;
		case $location[Cobb\'s Knob Treasury]:
			return 5;
		case $location[The Bat Hole Entrance]:
			return 4;
		default:
			return 1;
	}
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
		if (lowkey_needKey(key) && zone_isAvailable(loc) && lowkey_keyDelayRemaining(loc) > 0 && loc.wanderers)
		{
			return loc;
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
	if(!possessEquipment($item[Black rose key]))
	{
		if (my_buffedstat($stat[moxie]) < monster_attack($monster[skeletal cat]))
		{
			//conservatory is available when very underleveled so going there this early can be dangerous
			buffMaintain($effect[Vital]);
		}
		if (lowkey_keyAdv($item[Black rose key])) { return true; }
	}

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
		
		// +adv. Knob shaft skate key needs Cobb's Knob lab key for access to Knob Shaft
		if (lowkey_keyAdv($item[Knob shaft skate key])) { return true; }
		
		//will probably get Cobb's Knob lab key here if still missing it
		if (lowkey_keyAdv($item[Knob treasury key])) { return true; }

		// Knob labinet key to unlock Menagerie. needs Cobb's Knob lab key for access to the lab
		if (item_amount($item[Cobb\'s Knob Menagerie key]) < 1 && lowkey_keyAdv($item[Knob labinet key])) { return true; }
	}
	
	if (internalQuestStatus("questL08Trapper") == 1 && item_amount($item[Goat Cheese]) < 3) {
		// food drop key for Goatlet
		if (lowkey_keyAdv($item[Anchovy can key])) { return true; }
	}

	if (internalQuestStatus("questL09Topping") > 0 && internalQuestStatus("questL09Topping") < 3) {
		// +ml (before oil peak)
		// F'c'le sh'c'le k'y needs F'c'le access
		if (lowkey_keyAdv($item[F\'c\'le sh\'c\'le k\'y])) { return true; }
		// Clown car key needs "Fun" house access, may be delayed for shen
		if (lowkey_keyAdv($item[Clown car key])) { return true; }
		// cold res before aboo. Needs Icy Peak Access
		if (lowkey_keyAdv($item[Ice Key])) { return true; }
		// spooky res before aboo. Needs Menagerie access.
		if (lowkey_keyAdv($item[Weremoose key])) { return true; }
	}

	// sleaze damage before red zeppelin
	if (internalQuestStatus("questL11Ron") > -1 && internalQuestStatus("questL11Ron") < 2) {
		if (lowkey_keyAdv($item[Deep-fried key])) { return true; }
		// Clown car key needs "Fun" house access, may be delayed for shen
		if (lowkey_keyAdv($item[Clown car key])) { return true; }
	}

	// cold spell damage before orcs. Ice Key needs The Icy Peak access
	if (internalQuestStatus("questL09Topping") == 0 && get_property("chasmBridgeProgress").to_int() < bridgeGoal())
	{
		if (lowkey_keyAdv($item[Ice Key])) { return true; }
	}

	// +combat before sonofa or pirate insults. Music Box Key needs Spookyraven Manor third floor access
	if (internalQuestStatus("questM12Pirate") == 4 && numPirateInsults() < 6)
	{
		if (lowkey_keyAdv($item[Music Box Key])) { return true; }
	}
	//unlocking third floor access and Music Box Key will both be called directly when about to do sonofa

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
			boolean needHigherLevelForKey = true;
			foreach key in lowKeys
			{
				if (lowkey_needKey(key))
				{
					auto_log_warning(lowKeys[key] + ": " + key);
					if (my_level() >= lowkey_levelNeededToUnlockZone(lowKeys[key]))
					{
						needHigherLevelForKey = false;
					}
				}
			}
			if (my_level() < 11 && needHigherLevelForKey)
			{
				return false;
			}
			else
			{
				abort("Please unlock zones manually and try again.");
			}
		}
		// Unlock door
		council(); // make sure all quests have been handed in or turning the door knob will be blocked.
		if (get_property("questL11MacGuffin") != "finished" || get_property("questL12War") != "finished")
		{
			// should not start consuming the keys if any quests got held up somehow
			return false;
		}
		if (tower_door()) {
			return true;
		}
		return false;
	}

	return autoAdv(1, loc);
}

boolean LX_lowkeySummer() {

	if (!in_lowkeysummer()) { return false; }
	
	// Copied out of task order default.dat
	if (LX_freeCombatsTask        ()) { return true; }
	if (woods_questStart          ()) { return true; }
	if (LX_unlockPirateRealm      ()) { return true; }
	if (catBurglarHeist           ()) { return true; }
	if (auto_breakfastCounterVisit()) { return true; }
	if (chateauPainting           ()) { return true; }
	if (LX_setWorkshed            ()) { return true; }
	if (LX_galaktikSubQuest       ()) { return true; }
	if (L9_leafletQuest           ()) { return true; }
	if (L5_findKnob               ()) { return true; }
	if (L12_sonofaPrefix          ()) { return true; }
	if (LX_burnDelay              ()) { return true; }
	if (LX_summonMonster          ()) { return true; }
	// Lock in the Shen zones as soon as we can as it (potentially) unlocks a bunch of stuff.
	if (L11_shenStartQuest()) { return true; }
	// If we have everything to start the war instantly, just do it so we can start flyering.
	if (L12_opportunisticWarStart()) { return true; }
	// Build the Bridge when we have enough parts as we may want to spend daily resources at the peaks.
	if (finishBuildingSmutOrcBridge()) { return true; }
	// Call quest handlers based on current state if applicable
	if (auto_earlyRoutingHandling()) { return true; }

	// Guild access
	if (LX_guildUnlock()) { return true; }

	// Find keys that help us save adventures in quests.
	if (LX_findHelpfulLowKey()) { return true; }

	// Cobb's Knob unlocks a lot of zones which contain generally useful keys for all classes (-combat, +meat, +adv).
	// Also the +20% to all Muscle Gains key unlocks here.
	if (L5_getEncryptionKey() || L5_findKnob()) { return true; }
	
	if (my_level() < 12) {
		if (my_primestat() == $stat[Mysticality] && possessEquipment($item[Key sausage])) {
			// Myst classes want access to Pandamonium Slums to find the demonic key (+20% to all Mysticality Gains).
			// Get the -combat key first.
			if(!possessEquipment($item[Demonic key]) && my_buffedstat($stat[moxie]) < monster_attack($monster[Hellion])) {
				//starting the level 6 quest as early as possible can be dangerous?
				buffMaintain($effect[Vital]);
			}
			if (L6_friarsGetParts()) { return true; }
		}
		else if (my_primestat() == $stat[Muscle] && item_amount($item[Cobb\'s Knob Lab Key]) == 0) {
			// Mus classes want access to the laboratory to find the Knob labinet key (+20% to all Muscle Gains).
			// Have already gone after Key sausage and Knob treasury key by now, if still missing lab key give priority to the Knob
			if (L5_slayTheGoblinKing()) { return true; }
		}
	}

	// Island access for all classes. also farm the +20% to all Moxie Gains key
	// (adventuring will be handled by LX_findHelpfulLowKey() for moxie classes but this'll complete the quest)
	if (LX_hippyBoatman()) { return true; }

	// Desert access, Daily Dungeon and other early random stuff.
	if (LX_loggingHatchet() || LX_unlockDesert() || LX_lockPicking() || LX_fatLootToken()) { return true; }

	// Get the Steel Organ if the user wants it (probably good in this path since turnbloat).
	if (LX_steelOrgan()) { return true; }
	
	// Get the -combat key before attempting the Friars or the Spooky Forest. Unlocking hidden temple is only a priority for possible rollover lucky lindy since SemiRare no longer exist
	if (possessEquipment($item[Key sausage])) {
		if (L6_friarsGetParts()
			|| L2_mosquito()
			|| LX_unlockHauntedLibrary()
			|| (canDrinkSpeakeasyDrink($item[Lucky Lindy]) && LX_unlockHiddenTemple())
			|| LX_getLadySpookyravensDancingShoes()
			|| LX_getLadySpookyravensPowderPuff()) { return true; }
	}

	// If we have the resources to do the Haunted Kitchen in the minimum adventures, we should do it sooner 
	// TODO this is bugged because it can exit the path file, but fixing directly can result in resistance provider constantly switching familiars and wasting a ton of time
	if (internalQuestStatus("questM20Necklace") == 0) {
		return LX_unlockHauntedBilliardsRoom(true);
	}

	if (internalQuestStatus("questL12War") > -1) {
		// Don't start the war unless we've acquired the key from Belowdecks first as it gives +item.	
		// TODO these aren't the full L12 tasks, could filthworms earlier here if Yellow Ray available
		if (possessEquipment($item[Treasure Chest key])) {
			if (L12_preOutfit() || L12_getOutfit() || L12_startWar()) { return true; }
		} else {
			// Make sure Belowdecks is open so we can get the key.
			if (LX_pirateQuest()) { return true; }
		}
		
		L12_flyerFinish(); // Finish flyers whenever possible.
		
		// Get the +combat key before attempting Sonofa Beach.
		if (possessEquipment($item[Music Box Key])) {
			if (L12_sonofaBeach() || L12_sonofaFinish()) { return true; }
		} else {
			// Make sure Spookyraven Third Floor is open so we can get the key.
			if (LX_spookyravenManorFirstFloor() || LX_spookyravenManorSecondFloor()) { return true; }
			if (internalQuestStatus("questL12War") == 1 && get_property("sidequestLighthouseCompleted") == "none")
			{
				if (lowkey_keyAdv($item[Music Box Key])) { return true; }
			}
		}

		// Check our meat accessories, grab +meat keys before attempting Themthar Hills if they'll help.
		int n_meat_drop_acc_50plus = 0;
		foreach it,n in auto_getAllEquipabble($slot[acc1]) {
			if (numeric_modifier(it,$modifier[meat drop])>=45 || it==$item[backup camera]) { // backup camera isn't always meat 
				n_meat_drop_acc_50plus += n;
			}
		}
		if (n_meat_drop_acc_50plus>=2) {
			if (L12_themtharHills()) { return true; }
		} else if(!get_property("auto_skipNuns").to_boolean() && (get_property("hippiesDefeated").to_int() >= 192 || get_property("auto_hippyInstead").to_boolean())) {
			// about to do nuns. Make sure The Valley is open so we can get the Kekekey.
			// opening Cobb's Knob so we can get the treasury key is already done at higher priority
			if (L9_chasmBuild() || L9_highLandlord()) { return true; }
		}

		// Do the rest of the war. Should have the +item key already before we start the war.
		if (L12_gremlins() || L12_filthworms() || L12_orchardFinalize() || L12_farm() || L12_clearBattlefield() || L12_finalizeWar()) { return true; }
	}

	// Start the macguffin quest as we need it to unlock Belowdecks.
	if (L11_blackMarket() || L11_forgedDocuments() || L11_mcmuffinDiary() || L11_getBeehive()) { return true; }

	// Lock in the Shen zones as soon as we can.
	if (L11_shenStartQuest()) { return true; }
	// Shen can still block Clown car key after zones are locked in if we don't chase the Snakeleton here
	if (internalQuestStatus("questG04Nemesis") < 5 && shenShouldDelayZone($location[The Unquiet Garves]) && L11_shenCopperhead()) { return true; }
	// If the +item key is within reach before the Peaks open Belowdecks for it
	if (internalQuestStatus("questL11MacGuffin") >= 2 && LX_pirateQuest()) { return true; }

	if (internalQuestStatus("questL09Topping") > -1) {
		// Get the Sleaze res key before doing the Orcs for better Blech
		if (lowkey_keyAdv($item[Deep-fried key])) { return true; }
		// Get the Cold Damage key before doing the Orcs
		// This gets blocked by the Shen softlock so do it as soon as we feasibly can as one of the +meat keys requires the L9 quest finished.
		if (possessEquipment($item[Ice Key])) {
			if (L9_chasmBuild()) { return true; }
		} else {
			// Make sure the Icy Peak is available so we can get the key
			if (L8_trapperQuest()) { return true; }
		}
		// Get the ML keys before doing Oil peak and Spooky Res key before doing Aboo Peak (should have Cold Res key already for the Orc Chasm).
		// Get +item key before the Peaks if questL11MacGuffin already allows it
		if (possessEquipment($item[F\'c\'le sh\'c\'le k\'y]) 
				&& possessEquipment($item[Clown car key])
				&& possessEquipment($item[Weremoose key])) {
			if (L9_highLandlord()) { return true; }
		} else {
			// Make sure the F'c'le is open so we can get the key. Once gathering insults do it on the way to the Peg key before doing it in the barrr
			if (LX_pirateOutfit() || (item_amount($item[The Big Book Of Pirate Insults]) > 0 && lowkey_keyAdv($item[Peg key])) || LX_joinPirateCrew()) { return true; }
			// Make sure the "Fun" House is open so we can get the key
			if (LX_acquireEpicWeapon()) { return true; }
		}
	}

	if (internalQuestStatus("questL11MacGuffin") > -1) {
		// +item helps with getting fulminate ingredients, Hidden City drops and Copperhead/Zeppelin.
		if (!possessEquipment($item[Treasure Chest key])) {
			// Make sure Belowdecks is open so we can get the key.
			if (LX_pirateQuest()) { return true; }
		}
		
		// open the hidden temple if it hasn't been done yet
		if (LX_unlockHiddenTemple()) { return true; }

		// open the hidden city up.
		if (L11_unlockHiddenCity()) { return true; }

		// Dance with lady spookyraven so we can go murder her undead husband and take the Eye of Ed
		if (LX_spookyravenManorFirstFloor() || LX_spookyravenManorSecondFloor()) { return true; }
		// food drop key before Eye of Ed for the blasting soda
		if (lowkey_keyAdv($item[Anchovy can key])) { return true; }
		
		// Murder pygmies for the ancient amulet.
		if (L11_hiddenCityZones() || L11_hiddenCity()) { return true; }

		// Finish the other Macguffin zones so we can beat Ed to death repeatedly and waste all his Ka coins.
		if (L11_aridDesert()) { return true; }
		if (possessEquipment($item[Treasure Chest key])) {
			if (L11_talismanOfNam() || L11_mauriceSpookyraven() || L11_palindome() || L11_unlockPyramid()) { return true; }
		}
		// should do the tavern before trying to do the pyramid so we can use any tangles we get lucky with.
		// Clown car key for tavern noncombats. needs "Fun" house access
		if (lowkey_keyAdv($item[Clown car key])) { return true; }
		if (internalQuestStatus("questL03Rat") > 2) {
			if (L11_unlockEd() || L11_defeatEd()) { return true; }
		} else {
			set_property("auto_forceTavern", true);
			if (L3_tavern()) { return true; }
		}
	}

	// Open up the top of the beanstalk.
	if (L10_plantThatBean()) { return true; }	//tries L4_batCave() itself if it needs to

	// Should have the -combat key long before level 10 but lets just make sure.
	if (possessEquipment($item[Key sausage])) {
		if (L10_airship() || L10_basement() || L10_ground() || L10_topFloor() || L10_holeInTheSkyUnlock()) { return true; }
	}  // Make sure Cobb's Knob is open so we can get the key is already done at higher priority

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
	// Clown car key for tavern noncombats. needs "Fun" house access, may be delayed for shen
	if (lowkey_keyAdv($item[Clown car key])) { return true; }
	else if (LX_acquireEpicWeapon()) { return true; }
	if (L3_tavern()) { return true; }

	// this quest and these zones are open either from the start or level 4.
	// so lets do this if we have nothing better to do yet.
	if (possessEquipment($item[aqu&iacute;]) && possessEquipment($item[batting cage key])) {
		if (LX_unlockHauntedBilliardsRoom()) { return true; }
	} else {
		if (internalQuestStatus("questM20Necklace") == 0) {
			// hot res for the Haunted Kitchen. aquí needs Desert Beach Access
			if (lowkey_keyAdv($item[aqu&iacute;])) { return true; }
			// stench res for the Haunted Kitchen
			if (lowkey_keyAdv($item[batting cage key])) { return true; }
		}
	}
	// open the hidden temple if not already done at higher priority and not still waiting for the -combat key
	if (possessEquipment($item[Key sausage]) && LX_unlockHiddenTemple()) { return true; }

	// Spookyraven quest steps that don't need -combat or resists, just monster killin' (or dancing with a ghost for stats).
	if (LX_danceWithLadySpookyraven() || LX_getLadySpookyravensFinestGown() || LX_unlockManorSecondFloor()) { return true; }

	if (L12_clearBattlefield()) { return true; } // This is a mess and if it's not last, it screws up the war massively.

	// Stuff we need to do in this path to unlock key zones.
	if (LX_pirateQuest()) { return true; }
	if (LX_acquireEpicWeapon()) { return true; }

	// If literally nothing better to do, go find some of the keys we don't actually care about but have to find anyway.
	location loc = lowkey_nextAvailableKeyLocation();
	if (loc != $location[none] && autoAdv(loc)) { return true; }

	// Make sure to unlock Menagerie if it wasn't done while getting Knob labinet key
	if (LX_unlockKnobMenagerie()) { return true; }

	// Make sure to go to war
	if (L12_lastDitchFlyer()) { return true; }

	// unlock the door, climb the tower, commit sorceresscide.
	if (L13_sorceressDoor() || L13_towerNSTower() || L13_towerNSNagamar() || L13_towerNSFinal()) { return true; }

	if (my_level() < 12)	//level 13 not needed for sorceress access
	{
		if (LX_attemptPowerLevel()) { return true; }
	}
	
	
	auto_log_warning("Reached the end of LX_lowkeySummer task without managing to do anything. This should probably never happen.", "red");
	return false;
}
