boolean in_bugbear()
{
	return my_path() == "Bugbear Invasion";
}

void bugbear_InitializeSettings()
{
	if(in_bugbear())
	{
		// Lair is replaced
		set_property("auto_wandOfNagamar", false);
		set_property("auto_getBeehive", false);
		set_property("auto_holeinthesky", false);
		set_property("auto_getStarKey", false);
		set_property("nsTowerDoorKeysUsed", "Boris's key,Jarlsberg's key,Sneaky Pete's key,Richard's star key,skeleton key,digital key");
	}
}

boolean bugbear_IsWanderer(monster mon)
{
	return $monsters[scavenger bugbear, hypodermic bugbear, batbugbear, bugbear scientist, bugaboo, Black Ops Bugbear, Battlesuit Bugbear Type, ancient unspeakable bugbear, trendy bugbear chef] contains mon;
}

string bugbear_Status(location loc)
{
	if (loc.zone != "Mothership") abort("Invalid Mothership zone");
	return get_property("status" + loc.to_string().replace_string(" ", ""));
}

int bugbear_BioDataRemaining(location loc)
{
	string value = bugbear_Status(loc);
	if (value == "unlocked" || value == "open" || value == "cleared") return 0;
	switch (loc)
	{
		case $location[Waste Processing]:
		case $location[Medbay]:
		case $location[Sonar]:
			return 3 - value.to_int();
		case $location[Science Lab]:
		case $location[Morgue]:
		case $location[Special Ops]:
			return 6 - value.to_int();
		case $location[Engineering]:
		case $location[Navigation]:
		case $location[Galley]:
			return 9 - value.to_int();
		default:
			abort("Invalid Biodata location " + loc);
	}

	return 0;
}

boolean bugbear_ZoneOpen(location loc)
{
	string value = bugbear_Status(loc);
	return value == "open";
}

boolean bugbear_ZoneCleared(location loc)
{
	string value = bugbear_Status(loc);
	return value == "cleared";
}

boolean bugbear_UnlockMothership(location loc)
{
	int remaining = bugbear_BioDataRemaining(loc);
	if (remaining == 0) return false;

	location unlockLocation = $location[none];
	switch (loc)
	{
		case $location[Waste Processing]:
			unlockLocation = $location[The Sleazy Back Alley]; break;
		case $location[Medbay]:
			if (internalQuestStatus("questL02Larva") != 9999) return false;
			unlockLocation = $location[The Spooky Forest]; break;
		case $location[Sonar]:
			if (internalQuestStatus("questL04Bat") != 9999) return false;
			unlockLocation = $location[The Batrat and Ratbat Burrow]; break;
		case $location[Science Lab]:
			unlockLocation = $location[Cobb's Knob laboratory]; break;
		case $location[Morgue]:
			unlockLocation = $location[The VERY Unquiet Garves]; break;
		case $location[Special Ops]:
			if (internalQuestStatus("questL08Trapper") != 9999) return false;
			unlockLocation = $location[Lair of the Ninja Snowmen]; break;
		case $location[Engineering]:
			if (internalQuestStatus("questL10Garbage") != 9999) return false;
			unlockLocation = $location[The Penultimate Fantasy Airship]; break;
		case $location[Navigation]:
			if (internalQuestStatus("questL11Manor") != 9999) return false;
			unlockLocation = $location[The Haunted Gallery]; break;
		case $location[Galley]:
			unlockLocation = $location[The Hippy Camp (Bombed Back to the Stone Age)];
			if (zone_available(unlockLocation)) break;
			unlockLocation = $location[The Orcish Frat House (Bombed Back to the Stone Age)]; break;
		default:
			abort("Invalid Biodata location " + loc);
	}

	if (!zone_available(unlockLocation)) return false;

	if (item_amount($item[Key-o-tron]) == 0 && item_amount($item[BURT]) >= 5)
	{
		create(1, $item[Key-o-tron]);
		use(1, $item[Key-o-tron]);
	}

	if (!possessEquipment($item[bugbear detector]))
	{
		pullXWhenHaveY($item[bugbear detector], 1, 0);
	}

	if (!possessEquipment($item[bugbear detector]) && item_amount($item[BURT]) >= 25)
	{
		create(1, $item[bugbear detector]);
	}

	if (possessEquipment($item[bugbear detector]))
	{
		autoEquip($item[bugbear detector]);
	}

	if((get_property("_hipsterAdv").to_int() < 7) && is_unrestricted($familiar[Artistic Goth Kid]) && auto_have_familiar($familiar[Artistic Goth Kid]))
	{
		// TODO: Use crayon shavings to copy
		auto_log_info("Hipster Adv: " + get_property("_hipsterAdv"), "blue");
		handleFamiliar($familiar[Artistic Goth Kid]);
	}

	if (item_amount($item[Key-o-tron]) == 0)
	{
		auto_log_info("Need a Key-o-tron to scan bugbears", "blue");
	}
	else
	{
		auto_log_info("Scanning bugbears in " + unlockLocation + " to unlock " + loc, "blue");
	}

	// TODO: Backups and copies would be real good but
	// existing copying code is real bad

	return autoAdv(unlockLocation);
}

boolean LX_bugbearKeyOTron()
{
	if (item_amount($item[Key-o-tron]) != 0) return false;

	return bugbear_UnlockMothership($location[Waste Processing]);
}

boolean LX_bugbearWasteProcessing()
{
	location loc = $location[Waste Processing];
	if (bugbear_UnlockMothership(loc)) return true;
	if (bugbear_ZoneOpen(loc) == false || bugbear_ZoneCleared(loc)) return false;

	if (!possessEquipment($item[bugbear communicator badge]) && item_amount($item[handful of juicy garbage]) > 0)
	{
		use(1, $item[handful of juicy garbage]);
		return true;
	}

	if (possessEquipment($item[bugbear communicator badge]))
	{
		autoEquip($item[bugbear communicator badge]);
	}
	else
	{
		handleFamiliar("item");
	}

	auto_log_info("Clearing Bugbear Mothership - " + loc, "blue");

	return autoAdv(loc);
}

boolean LX_bugbearMedbay()
{
	location loc = $location[Medbay];
	if (bugbear_UnlockMothership(loc)) return true;
	if (bugbear_ZoneOpen(loc) == false || bugbear_ZoneCleared(loc)) return false;

	auto_log_info("Clearing Bugbear Mothership - " + loc, "blue");

	return autoAdv(loc);
}

boolean LX_bugbearSonar()
{
	location loc = $location[Sonar];
	if (bugbear_UnlockMothership(loc)) return true;
	if (bugbear_ZoneOpen(loc) == false || bugbear_ZoneCleared(loc)) return false;

	auto_log_info("Clearing Bugbear Mothership - " + loc, "blue");

	return autoAdv(loc);
}

boolean LX_bugbearScienceLab()
{
	location loc = $location[Science Lab];
	if (bugbear_UnlockMothership(loc)) return true;
	if (bugbear_ZoneOpen(loc) == false || bugbear_ZoneCleared(loc)) return false;

	handleFamiliar("item");

	auto_log_info("Clearing Bugbear Mothership - " + loc, "blue");

	return autoAdv(loc);
}

boolean LX_bugbearMorgue()
{
	location loc = $location[Morgue];
	if (bugbear_UnlockMothership(loc)) return true;
	if (bugbear_ZoneOpen(loc) == false || bugbear_ZoneCleared(loc)) return false;

	handleFamiliar("item");

	auto_log_info("Clearing Bugbear Mothership - " + loc, "blue");
	
	return autoAdv(loc);
}

boolean LX_bugbearSpecialOps()
{
	location loc = $location[Special Ops];
	if (bugbear_UnlockMothership(loc)) return true;
	if (bugbear_ZoneOpen(loc) == false || bugbear_ZoneCleared(loc)) return false;

	if (!possessEquipment($item[UV monocular]))
	{
		pullXWhenHaveY($item[UV monocular], 1, 0);
	}

	if (!possessEquipment($item[UV monocular]) && item_amount($item[BURT]) >= 50)
	{
		create(1, $item[UV monocular]);
	}

	if (!possessEquipment($item[UV monocular]))
	{
		return false;
	}

	if (!possessEquipment($item[fluorescent lightbulb]) && auto_have_skill($skill[Summon Clip Art]) && get_property("tomeSummons").to_int() < 3)
	{
		cli_execute("make fluorescent lightbulb");
	}

	autoEquip($item[UV monocular]);

	if (possessEquipment($item[fire]))
	{
		autoEquip($item[fire]);
	}

	if (possessEquipment($item[fluorescent lightbulb]))
	{
		autoEquip($item[fluorescent lightbulb]);
	}

	if (possessEquipment($item[Rain-Doh green lantern]))
	{
		autoEquip($item[Rain-Doh green lantern]);
	}
	else if (possessEquipment($item[magic lamp]))
	{
		autoEquip($item[magic lamp]);
	}
	else if (possessEquipment($item[oil lamp]))
	{
		autoEquip($item[oil lamp]);
	}

	auto_log_info("Clearing Bugbear Mothership - " + loc, "blue");

	return autoAdv(loc);

}

boolean LX_bugbearEngineering()
{
	location loc = $location[Engineering];
	if (bugbear_UnlockMothership(loc)) return true;
	if (bugbear_ZoneOpen(loc) == false || bugbear_ZoneCleared(loc)) return false;

	handleFamiliar("item");

	auto_log_info("Clearing Bugbear Mothership - " + loc, "blue");

	return autoAdv(loc);
}

boolean LX_bugbearNavigation()
{
	location loc = $location[Navigation];
	if (bugbear_UnlockMothership(loc)) return true;
	if (bugbear_ZoneOpen(loc) == false || bugbear_ZoneCleared(loc)) return false;

	if (have_effect($effect[N-Spatial vision]) > 0) return false;

	auto_log_info("Clearing Bugbear Mothership - " + loc, "blue");

	return autoAdv(loc);
}

boolean LX_bugbearNavigationForce()
{
	location loc = $location[Navigation];
	if (bugbear_UnlockMothership(loc)) return true;
	if (bugbear_ZoneOpen(loc) == false || bugbear_ZoneCleared(loc)) return false;

	if (have_effect($effect[N-Spatial vision]) > 0)
	{
		uneffect($effect[N-Spatial vision]);
	}

	if (have_effect($effect[N-Spatial vision]) > 0) return false;

	auto_log_info("Clearing Bugbear Mothership - " + loc, "blue");

	return autoAdv(loc);
}

boolean LX_bugbearGallery()
{
	location loc = $location[Galley];
	if (bugbear_UnlockMothership(loc)) return true;
	if (bugbear_ZoneOpen(loc) == false || bugbear_ZoneCleared(loc)) return false;

	addToMaximize("1000ml");

	auto_log_info("Clearing Bugbear Mothership - " + loc, "blue");

	return autoAdv(loc);
}

boolean LX_bugbearBridge()
{
	if (get_property("mothershipProgress").to_int() != 3) return false;

	if (internalQuestStatus("questL13Final") < 0 || internalQuestStatus("questL13Final") > 3)
	{
		return false;
	}

	if (get_property("auto_towerBreak").to_lower_case() == "naughty sorceress" || get_property("auto_towerBreak").to_lower_case() == "the naughty sorceress" || get_property("auto_towerBreak").to_lower_case() == "ns" || get_property("auto_towerBreak").to_lower_case() == "sorceress" || get_property("auto_towerBreak").to_lower_case() == "level 6" || get_property("auto_towerBreak").to_lower_case() == "chamber")
	{
		abort("auto_towerBreak set to abort here.");
	}

	auto_log_info("Clearing Bugbear Mothership - Bridge", "blue");

	if (item_amount($item[Jeff Goldblum larva]) == 0)
	{
		visit_url("council.php");
	}

	cli_execute("scripts/autoscend/auto_post_adv.ash");

	if(my_class() == $class[Turtle Tamer])
	{
		autoEquip($item[Ouija Board\, Ouija Board]);
	}

	if((pulls_remaining() == -1) || (pulls_remaining() > 0))
	{
		if(can_equip($item[Oscus\'s Garbage Can Lid]))
		{
			pullXWhenHaveY($item[Oscus\'s Garbage Can Lid], 1, 0);
		}
	}

	autoEquip($slot[Off-Hand], $item[Oscus\'s Garbage Can Lid]);

	handleFamiliar("boss");

	addToMaximize("10dr,3moxie,0.5da 1000max,-5ml,1.5hp,0item,0meat");

	boolean ret;
	if (item_amount($item[Jeff Goldblum larva]) > 0)
	{
		ret = autoAdvBypass("place.php?whichplace=bugbearship&action=bb_bridge");
	}

	ret = autoAdvBypass("place.php?whichplace=bugbearship&action=bb_bridge");

	if (get_property("auto_stayInRun").to_boolean())
	{
		abort("User wanted to stay in run (auto_stayInRun), we are done.");
	}

	visit_url("place.php?whichplace=nstower&action=ns_11_prism");
	if(!inAftercore())
	{
		abort("Yeah, so, I'm done. You might be stuck at the final boss, or just with a king in a prism. I don't know and quite frankly, after the last " + my_daycount() + " days, I don't give a damn. That's right, I said it. Bitches.");
	}

	return ret;
}

boolean LX_bugbearInvasion()
{
	if (!in_bugbear()) return false;

	if (LX_bugbearKeyOTron()) return true;

	if (item_amount($item[Key-o-tron]) == 0) return false;

	// First floor
	if (LX_bugbearWasteProcessing()) return true;
	if (LX_bugbearMedbay()) return true;
	if (LX_bugbearSonar()) return true;

	// Second floor
	if (LX_bugbearScienceLab()) return true;
	if (LX_bugbearMorgue()) return true;
	if (LX_bugbearSpecialOps()) return true;
	
	// Third floor
	if (LX_bugbearNavigation()) return true;
	if (LX_bugbearEngineering()) return true;
	if (LX_bugbearGallery()) return true;

	return false;
}

boolean LX_bugbearInvasionFinale()
{
	if (!in_bugbear()) return false;
	if (item_amount($item[Key-o-tron]) == 0) return false;

	if (internalQuestStatus("questL12War") >= 1 && LX_bugbearNavigationForce()) return true;
	if (LX_bugbearBridge()) return true;
	if (LX_attemptPowerLevel()) return true;

	abort("Bugbear Invasion tasks remain but can't figure out what to do.");
	return false;
}