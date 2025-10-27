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
	if(weapon_hands(equipped_item($slot[weapon])) > 1)
	{
		//if a 2 handed weapon is equipped, unequip it
		equip($item[none], $slot[weapon]);
	}
	return autoForceEquip($item[April Shower Thoughts Shield], true);
}

boolean auto_unequipAprilShieldBuff()
{
	//Because Empathy gets replaced by Thoughtful Empathy when cast with the Shield equipped,
	//we need to make sure this is unequipped if we want to have both Empathy and Thoughtful Empathy
	if(have_equipped($item[April Shower Thoughts Shield]))
	{
		return autoForceEquip($slot[off-hand], $item[none], true);
	}
	return true;
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
	if(get_property("_aprilShowerNorthernExplosion").to_boolean())
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

boolean[monster] peridotManuallyDesiredMonsters()
{
	// manually specify some favoured monsters
	boolean[monster] desired_monsters;
	desired_monsters[$monster[lobsterfrogman]] = true;
	desired_monsters[$monster[black panther]] = true;
	desired_monsters[$monster[white lion]] = true;
	desired_monsters[$monster[monstrous boiler]] = true;
	desired_monsters[$monster[modern zmobie]] = true;
	desired_monsters[$monster[dairy goat]] = true;
	desired_monsters[$monster[writing desk]] = true;
	// Quest gremlins need IDs because there's multiple
	desired_monsters[$monster[547]] = true; // erudite gremlin (tool) 
	desired_monsters[$monster[549]] = true; // batwinged gremlin (tool)
	desired_monsters[$monster[551]] = true; // vegetable gremlin (tool)
	desired_monsters[$monster[553]] = true; // spider gremlin (tool)

	return desired_monsters;
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
		// Manual monster specifications
		if (peridotManuallyDesiredMonsters() contains monOpts[i])
		{
			bestmon = i;
			break; // if we've got a force desired monster, don't bother with the rankings any more
		}
		if(zoneRank(monOpts[i], loc) <= zoneRank(monOpts[bestmon], loc)) 
		{
			bestmon = i;
		}
		i += 1;
	}
	popChoice = monOpts[bestmon];
	if(popChoice.to_int() == 0) //still nothing found so just peace out
	{
		handleTracker($item[Peridot of Peril], loc.to_string(), "Peace out", "auto_mapperidot");
		run_choice(2); //if no match is found, hit the exit choice
		return;
	}
	handleTracker($item[Peridot of Peril], loc.to_string(), popChoice.to_string(),"auto_mapperidot");
	run_choice(1, "bandersnatch=" + popChoice.to_int());
	return;
}

boolean haveUsedPeridot(int loc)
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

boolean haveUsedPeridot(location loc)
{
	return haveUsedPeridot(loc.to_int());
}

boolean auto_havePrismaticBeret()
{
	item pb = $item[Prismatic Beret];
	return (auto_is_valid(pb) && possessEquipment(pb));
}

boolean canBusk()
{
	if(get_property("_beretBuskingUses").to_int() < 5)
	{
		return true;
	}
	return false;
}

int[string] beretPower(item[int] allHats, item[int] allShirts, item[int] allPants)
{
	int[slot] multipliers = powerMultipliers();
	int[int] hatPowers;
	hatPowers[0] = 0;
	int[int] pantPowers;
	pantPowers[0] = 0;
	int[int] shirtPowers;
	shirtPowers[0] = 0;
	int[string] powers;
	//possible power calculations
	if(!in_hattrick())
	{
		if(auto_have_familiar($familiar[Mad Hatrack]))
		{
			//prismatic beret on the hatrack and another hat on you
			foreach i, h in allHats
			{
				hatPowers[count(hatPowers)] = get_power(h) * multipliers[$slot[hat]];
			}
		}
		else
		{
			hatPowers[0] = get_power($item[Prismatic Beret]) * multipliers[$slot[hat]];
		}
	}
	else
	{
		foreach i, h in allHats
		{
			if(equipped_amount(h) >= 1)
			{
				hatPowers[0] += get_power(h) * multipliers[$slot[hat]];
			}
		}
	}
	foreach i, p in allPants
	{
		pantPowers[count(pantPowers)] = get_power(p) * multipliers[$slot[pants]];
	}
	foreach i, s in allShirts
	{
		shirtPowers[count(shirtPowers)] = get_power(s);
	}
	foreach i, hp in hatPowers
	{
		foreach i, pp in pantPowers
		{
			foreach i, sp in shirtPowers
			{
				string concat = (auto_have_familiar($familiar[Mad Hatrack]) ? (hp / multipliers[$slot[hat]]).to_string() + "," : "") + (pp / multipliers[$slot[pants]]).to_string() + "," + sp.to_string();
				powers[concat] = hp + pp + sp;
			}
		}
	}
	return powers;
}

string bestBusk(int[string] powers, string effectMultiplier)
{
	//effectMultiplier string should be in format of "modifier1:float;modifier2:float;..." if multiple modifiers
	//if single modifier, does not need a multiplier
	//Do not use an ending ; for effectMultiplier
	if(!auto_havePrismaticBeret())
	{
		return 0;
	}
	int busksUsed = get_property("_beretBuskingUses").to_int();
	float score;
	float highScore = 0.0;
	string highScoreString;
	float[string] effMulti;
	string[int] numMod;
	if(effectMultiplier=="")
	{
		//based on default maximizer string
		effMulti = {
			"item drop": 5,
			"meat drop": 1,
			"initiative": 0.5,
			"damage absorption": 0.1,
			"damage resistance": 1,
			"Cold Resistance": 0.5,
			"Hot Resistance": 0.5,
			"Sleaze Resistance": 0.5,
			"Stench Resistance": 0.5,
			"Spooky Resistance": 0.5,
			my_primestat().to_string(): 1.5,
			"fumble": -1,
			"hp": 0.4,
			"mp": 0.2,
			"mp regen": 3,
			"familiar weight": 2,
			"familiar experience": 5};
	}
	else
	{
		if(contains_text(effectMultiplier, ";"))
		{
			//split effectMultiplier into multiple effects if needed
			foreach i, str in split_string(effectMultiplier,";")
			{
				numMod = split_string(str,":");
				effMulti[numMod[1]] = numMod[0].to_float();
			}
		}
		else if(contains_text(effectMultiplier, ":"))
		{
			numMod = split_string(effectMultiplier, ":");
			effMulti[numMod[1]]  = numMod[0].to_float();
		}
		else
		{
			effMulti[effectMultiplier] = 5.0;
		}
	}
	int[effect] buskingEffects;
	foreach powerstring, power in powers
	{
		//Evaluate all power combinations calculated in beretPower to find the highest scoring one after multiplier is applied
		score = 0.0;
		buskingEffects = beret_busking_effects(power.to_int(), busksUsed);
		foreach eff, i in buskingEffects
		{
			if(eff != $effect[none])
			{
				foreach mod, multi in effMulti
				{
					score += numeric_modifier(eff, mod) * multi;
				}
			}
		}
		if(score > highScore)
		{
			highScore = score;
			highScoreString = powerstring;
		}
	}
	if(highScore > 0)
	{
		return highScoreString;
	}
	return "";
}

boolean beretBusk(string effectMultiplier)
{
	if(!auto_havePrismaticBeret() || !canBusk())
	{
		return false;
	}
	int[slot] multipliers = powerMultipliers();
	item[int] allHats;
	item[int] allShirts;
	item[int] allPants;
	int bestBuskHROffset = (auto_have_familiar($familiar[Mad Hatrack]) ? 0 : 1);
	int buskPower = 0;
	foreach it in $items[]
	{
		//only record items we have
		if(possessEquipment(it))
		{
			switch(to_slot(it))
			{
				case $slot[hat]:
					allHats[count(allHats)] = it;
					break;
				case $slot[shirt]:
					allShirts[count(allShirts)] = it;
					break;
				case $slot[pants]:
					allPants[count(allPants)] = it;
					break;
				default:
					continue;
			}
		}
	}
	int[string] powers = beretPower(allHats, allShirts, allPants);
	string bestBuskPowers = bestBusk(powers, effectMultiplier);
	if(bestBuskPowers == "")
	{
		return false;
	}
	string[int] bestBuskPowersSplit = split_string(bestBuskPowers, ",");
	if(!in_hattrick())
	{
		if(auto_have_familiar($familiar[Mad Hatrack]))
		{
			foreach i, hat in allHats
			{
				if(get_power(hat) == bestBuskPowersSplit[0].to_int() && hat != $item[prismatic beret])
				{
					//equip the hat and put the beret on the Hatrack to be able to busk
					autoForceEquip(hat, true);
					buskPower += get_power(hat) * multipliers[$slot[hat]];
					if(use_familiar($familiar[Mad Hatrack]))
					{
						//Force the beret to the Hatrack if we were able to use the Hatrack.
						autoForceEquip($slot[familiar], $item[prismatic beret], true);
					}
					break;
				}
				else if(hat == $item[prismatic beret])
				{
					//don't equip the beret yet, in case there is another 10 power hat to wear
					continue;
				}
			}
		}
		if(!have_equipped($item[prismatic beret]))
		{
			//equip the beret if it is not equipped anywhere else
			autoForceEquip($slot[hat],$item[prismatic beret], true);
			buskPower += get_power($item[prismatic beret]) * multipliers[$slot[hat]];
		}
	}
	else
	{
		//get the power of all hats equipped in Hat Trick
		foreach i, h in allHats
		{
			if(equipped_amount(h) > 0)
			{
				buskPower += get_power(h) * multipliers[$slot[hat]];
			}
		}
	}
	if(count(allPants) > 0) //only check if we have pants available
	{
		if(bestBuskPowersSplit[1 - bestBuskHROffset].to_int() == 0)
		{
			autoForceEquip($slot[pants], $item[none], true);
		}
		else
		{
			foreach i, pant in allPants
			{
				if(get_power(pant) == bestBuskPowersSplit[1 - bestBuskHROffset].to_int())
				{
					autoForceEquip(pant, true);
					buskPower += get_power(pant) * multipliers[$slot[pants]];
					break;
				}
			}
		}
	}
	if(count(allShirts) > 0) //only check if we have shirts available
	{
		if(bestBuskPowersSplit[2 - bestBuskHROffset].to_int() == 0)
		{
			autoForceEquip($slot[shirt], $item[none], true);
		}
		else
		{
			foreach i, shirt in allShirts
			{
				if(get_power(shirt) == bestBuskPowersSplit[2 - bestBuskHROffset].to_int())
				{
					autoForceEquip(shirt, true);
					buskPower += get_power(shirt);
					break;
				}
			}
		}
	}

	if(use_skill(1, $skill[beret busking]))
	{
		handleTracker($item[prismatic beret], my_location().to_string(), "Beret busk " + get_property("_beretBuskingUses") + " at " + buskPower + " power", "auto_otherstuff");
		return true;
	}

	return false;
}

boolean beretBusk()
{
	return beretBusk("");
}

boolean auto_haveCoolerYeti()
{
	if(auto_have_familiar($familiar[Cooler Yeti]))
	{
		return true;
	}
	return false;
}
