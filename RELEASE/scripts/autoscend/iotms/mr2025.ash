# This is meant for items that have a date of 2025

boolean auto_haveCyberRealm()
{
	if(!is_unrestricted($item[server room key]))
	{
		return false;
	}
	if((get_property("crAlways").to_boolean() || get_property("_crToday").to_boolean()))
	{
		return true;
	}
	return false;
}

boolean auto_haveMcHugeLargeSkis()
{
	if(auto_is_valid($item[McHugeLarge duffel bag]) && available_amount($item[McHugeLarge duffel bag]) > 0 )
	{
		return true;
	}
	return false;
}

boolean auto_canEquipAllMcHugeLarge()
{
	if (!auto_haveMcHugeLargeSkis())
	{
		return false;
	}
	boolean success = true;
	foreach it in $items[McHugeLarge duffel bag,McHugeLarge right pole,McHugeLarge left pole,McHugeLarge right ski,McHugeLarge left ski]
	{
		success = can_equip(it) && success;
	}
	return success;
}

boolean auto_equipAllMcHugeLarge()
{
	if (!auto_haveMcHugeLargeSkis())
	{
		return false;
	}
	if (!possessEquipment($item[McHugeLarge right pole]))
	{
		auto_openMcLargeHugeSkis();
	}
	autoForceEquip($slot[back]    , $item[McHugeLarge duffel bag]);
	autoForceEquip($slot[weapon]  , $item[McHugeLarge right pole]);
	autoForceEquip($slot[off-hand], $item[McHugeLarge left pole]);
	autoForceEquip($slot[acc1]    , $item[McHugeLarge left ski]);
	autoForceEquip($slot[acc2]    , $item[McHugeLarge right ski]);
	return true;
}

boolean auto_openMcLargeHugeSkis()
{
	if (!auto_haveMcHugeLargeSkis())
	{
		return false;
	}
	if(possessEquipment($item[McHugeLarge right pole]))
	{
		return true;
	}
	//~ use($item[McHugeLarge duffel bag]); // does not work - need Mafia CLI tool?
	visit_url("inventory.php?action=skiduffel");
	return possessEquipment($item[McHugeLarge right pole]);
}

int auto_McLargeHugeForcesLeft()
{
	if (!auto_haveMcHugeLargeSkis())
	{
		return 0;
	}
	int used = get_property("_mcHugeLargeAvalancheUses").to_int();
	return 3-used;
}

int auto_McLargeHugeSniffsLeft()
{
	if (!auto_haveMcHugeLargeSkis())
	{
		return 0;
	}
	int used = get_property("_mcHugeLargeSlashUses").to_int();
	return 3-used;
}

boolean auto_haveCupidBow()
{
	item bow = $item[toy cupid bow];
	return (auto_is_valid(bow) && possessEquipment(bow));
}

boolean auto_haveLeprecondo()
{
	return auto_is_valid($item[leprecondo]) && available_amount($item[leprecondo])>0;
}

boolean auto_haveDiscoveredLeprecondoFurniture(int furn)
{
	string[int] discovered_furn = split_string(get_property("leprecondoDiscovered"),",");
	foreach i,s in discovered_furn
	{
		if (furn==to_int(s))
		{
			return true;
		}
	}
	return false;
}

boolean auto_setLeprecondo()
{
	if (!auto_haveLeprecondo())
	{
		return false;
	}
	// This is a toy.
	// We'll replace this with real logic once the Mafia CLI tool exists.
	// Don't complain about optimality, only complain if it literally breaks.
	// Low priority spleeners because we're not using them
	string installed = get_property("leprecondoInstalled");
	if (installed=="" || installed == "0,0,0,0")
	{
		auto_log_info("Setting Leprecondo","blue");
		int[int] priority = {
			 1: 25, // omnipot
			 2:  9, // cupcake treadmill
			 3: 18, // couch and flatscreen
			 4: 12, // internet connected laptop
			 5: 26, // wet bar (last need, anything below this point will likely be overridden if it gets installed)
			 6: 22, // home workout
			 7: 14, // whiskeybed
			 8: 21, // programmable blender
			 9: 23, // classics library
			10: 24, // retro video games
			11: 11, // weight bench
			12:  1, // crap
			13:  2, // crap
			14:  3, // crap
			15:  4, // crap
			16:  5, // crap
			17:  6  // crap
		};

		int[int] picks;
		int n_picks = 0;
		foreach i,f in priority
		{
			if (n_picks == 4) { break; }
			// Ignore the Fam Exp buffs in some paths
			if ( (in_avantGuard() || !pathHasFamiliar()) && (f==9 || f==18) )
			{
				continue;
			}
			if (auto_haveDiscoveredLeprecondoFurniture(f))
			{
				picks[n_picks++] = f;
			}
		}
		visit_url("inv_use.php?whichitem="+to_int($item[Leprecondo]));
		string url = `choice.php?whichchoice=1556&option=1&r0={picks[3]}&r1={picks[2]}&r2={picks[1]}&r3={picks[0]}`;
		auto_log_debug("Condo set URL: "+url, "blue");
		visit_url(url);
	}
	return true;
}

boolean auto_useLeprecondoDrops()
{
	while (available_amount($item[crafting plans])>0 && free_crafts() < 2)
	{
		use($item[crafting plans]);
	}
	return true;
}

int auto_punchOutsLeft()
{
	return to_int(get_property("preworkoutPowderUses"));
}

int auto_afterimagesLeft()
{
	return to_int(get_property("phosphorTracesUses"));
}

boolean auto_haveAprilShowerShield()
{
	item shield = $item[April Shower Thoughts shield];
	return (auto_is_valid(shield) && possessEquipment(shield));
}

boolean auto_getGlobs()
{
	if(!auto_haveAprilShowerShield())
	{
		return false;
	}
	//if breakfast hasn't run yet or they haven't been manually collected
	if(!get_property("_aprilShowerGlobsCollected").to_boolean())
	{
		visit_url('inventory.php?action=shower');
		return true;
	}
	return false;
}

boolean auto_equipAprilShieldBuff()
{
	if(!auto_haveAprilShowerShield())
	{
		return false;
	}
	//force equip the shield if this is called
	return equip($item[April Shower Thoughts Shield]);
}

boolean auto_canNorthernExplosionFE()
{
	//Northern Explosion becomes Feel Envy-adjacent once per day
	if(!auto_haveAprilShowerShield())
	{
		return false;
	}
	if(!auto_have_skill($skill[Northern Explosion]))
	{
		return false;
	}
	if(get_property("_autoNorthernExplosionFEUsed").to_boolean()) //update this once Mafia has the preference
	{
		return false;
	}
	return true;
}
boolean auto_havePeridot()
{
	item pop = $item[Peridot of Peril];
	return (auto_is_valid(pop) && possessEquipment(pop));
}

void peridotChoiceHandler(int choice, string page)
{
	if(!auto_havePeridot())
	{
		run_choice(2); //should never get here but might as well mitigate
	}
	monster popChoice;
	location loc = my_location();
	matcher mons = create_matcher("bandersnatch\" value=\"(\\d+)", page);
	monster[int] monOpts;
	int i = 0;
	int bestmon = 0;
	while(find(mons))
	{
		//record the possible monsters and identify the best one to target
		monOpts[i] = mons.group(1).to_int().to_monster();
		if(zoneRank(monOpts[i], loc) <= zoneRank(monOpts[bestmon], loc)) 
		{
			bestmon = i;
		}
		i += 1;
	}
	popChoice = monOpts[bestmon];
	if(popChoice.to_int() == 0) //still nothing found so just peace out
	{
		handleTracker($item[Peridot of Peril], loc.to_string(), "Peace out", "auto_otherstuff");
		run_choice(2); //if no match is found, hit the exit choice
		return;
	}
	if(zoneRank(popChoice, loc) != 4) handleTracker($item[Peridot of Peril], loc.to_string(), popChoice.to_string(),"auto_otherstuff");
	run_choice(1, "bandersnatch=" + popChoice.to_int());
	return;
}

boolean inperilLocations(int loc)
{
	string[int] perilLocs = split_string(get_property("_perilLocations"),",");
	foreach i, str in perilLocs
	{
		if (loc == to_int(str))
		{
			return true;
		}
	}
	return false;
}