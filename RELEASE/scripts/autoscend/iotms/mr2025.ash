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
