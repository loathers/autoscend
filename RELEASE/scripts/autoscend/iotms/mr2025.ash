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

boolean auto_haveMobiusRing()
{
	item ring = $item[M&ouml;bius ring];
	return (auto_is_valid(ring) && possessEquipment(ring));
}

int auto_paradoxicity()
{
	// we either need to visit the charpane or status.php to update this
	visit_url("charpane.php", false);
	return my_paradoxicity();
}

boolean auto_timeIsAStripPossible()
{
	if(!auto_haveMobiusRing())
	{
		return false;
	}

	return turns_until_mobius_noncombat_available() == 0;
}

void mobiusChoiceHandler(int choice, string page)
{
	if(!auto_haveMobiusRing())
	{
		run_choice(1); //should never get here but might as well mitigate
	}

	string[int] choices = available_choice_options();
	int[string] choiceMap;
	foreach idx, text in choices
	{
		choiceMap[text] = idx;
	}

	void mobiusChoice(string opt) {
			int num = choiceMap[opt];
			handleTracker($item[M&ouml;bius ring], opt, "auto_otherstuff"); 
			run_choice(num);
	}

	string pos;
	// we want to get +15 paradoxicity for more time cops and the 13-paradoxicity +item effect
	// in a single day, we'll hit the NC maybe 9 times
	// we can't guarantee we'll be able to use the effects, but the items are good
	// taking the long odds would be good if we can definitely remove the effect / handle the HP loss

	if (isAboutToPowerlevel()) {
		// if we're going to powerlevel, we want the +stat%, +stat and direct stat options
		pos = "Bake Susie a cupcake";
		if (choiceMap contains pos) {
			mobiusChoice(pos);
			return;
		}
		pos = "Draw a goatee on yourself";
		if (choiceMap contains pos) {
			mobiusChoice(pos);
			return;
		}
		switch (my_primestat())
		{
			case $stat[Muscle]:
				pos = "Lift yourself up by your bootstraps";
				if (choiceMap contains pos) {
					mobiusChoice(pos);
					return;
				}
				break;
			case $stat[Mysticality]:
				pos = "Mind your own business";
				if (choiceMap contains pos) {
					mobiusChoice(pos);
					return;
				}
				break;
			case $stat[Moxie]:
				pos = "Shoot yourself in the foot";
				if (choiceMap contains pos) {
					mobiusChoice(pos);
					return;
				}
				break;
		}
	}

	// cupcake is 5-7 adv for 1 full, +1 paradox
	if (canEat($item[Susie's cupcake])) {
		pos = "Steal a cupcake from young Susie";
		if (choiceMap contains pos) {
			mobiusChoice(pos);
			return;
		}
	}

	// first clock per day gives 3 adventures, second gives 2
	if (get_property("_clocksUsed").to_int() < 2) {
		pos = "Go back and set an alarm";
		if (choiceMap contains pos) {
			mobiusChoice(pos);
			if(item_amount($item[clock]) > 0)
			{
				use(1, $item[clock]);
			}
			return;
		}
		// gives +15 myst, +30 MP: rarely useful but sets up the clock
		pos = "Go back and take a 20-year-long nap";
		if (choiceMap contains pos) {
			mobiusChoice(pos);
			return;
		}
	}

	// 100 turns of +5 fam xp is worth refreshing
	if (have_effect($effect[Lifted by your Bootstraps]) == 0) {
		pos = "Let yourself get lifted up by your bootstraps";
		if (choiceMap contains pos) {
			mobiusChoice(pos);
			return;
		}
	}

	if (auto_paradoxicity() < 15) {
		// take paradox-increasing options without negative effects in approximate utility order
		// some would have been taken earlier, so taking them here implies they're less useful
		foreach str in $strings[
			Stop your arch-nemesis as a baby,
			Borrow meat from your future,
			Hey\, free gun!,
			Shoot yourself in the foot,
			Mind your own business,
			Lift yourself up by your bootstraps,
			Draw a goatee on yourself,
			Go for a nature walk,
			Steal a cupcake from young Susie,
			Plant some trees and harvest them in the future,
			Borrow a cup of sugar from yourself,
			Steal a club from the past,
			Go back and take a 20-year-long nap,
			Plant some seeds in the distant past,
			Go back and write a best-seller.,
			Defend yourself,
			Play Schroedinger's Prank on yourself,
			Peek in on your future,
			Give your past self investment tips,
		] {
			if (choiceMap contains str) {
				mobiusChoice(str);
				return;
			}
		}
	}

	// we've done everything we care about, find a loop
	if (canEat($item[Susie's cupcake])) {
		pos = "Steal a cupcake from young Susie";
		if (choiceMap contains pos) {
			mobiusChoice(pos);
			return;
		}
		pos = "Bake Susie a cupcake";
		if (choiceMap contains pos) {
			mobiusChoice(pos);
			return;
		}
	}

	// meat is normally useful
	pos = "Borrow meat from your future";
	if (choiceMap contains pos) {
		mobiusChoice(pos);
		return;
	}
	pos = "Repay yourself in the past";
	if (choiceMap contains pos) {
		mobiusChoice(pos);
		return;
	}

	run_choice(1);
	return;
}

int auto_timeCopFights()
{
	return get_property("_timeCopsFoughtToday").to_int();
}

boolean auto_haveMonodent()
{
	item dent = $item[Monodent of the Sea];
	return (auto_is_valid(dent) && possessEquipment(dent));
}

boolean auto_waveTheZone()
{
	if(!auto_haveMonodent())
	{
		return false;
	}

	//Already Summoned a Wave today
	if(get_property("_seadentWaveUsed").to_boolean())
	{
		return false;
	}

	boolean waveTheZone = false;

	//Force the Monodent of the Sea when adventuring in a zone that we might want to Summon a Wave in
	//Get Fishy turns from free fights
	if($locations[Shadow Rift (The Ancient Buried Pyramid), Shadow Rift (The Hidden City), Shadow Rift (The Misspelled Cemetary),
	Cyberzone 1, Cyberzone 2, Cyberzone 3] contains my_location() && my_path() == $path[11,037 Leagues Under the Sea])
	{
		autoForceEquip($item[Monodent of the Sea], true);
		waveTheZone = true;
	}
	//Get 30% more meat drop. Only useful if weapon slot has < 30% meat drop
	if(my_location() == $location[The Themthar Hills] && numeric_modifier(equipped_item($slot[weapon]), $modifier[Meat Drop]) < 30.0)
	{
		autoForceEquip($item[Monodent of the Sea], true);
		waveTheZone = true;
	}
	if(waveTheZone)
	{
		if(use_skill(1, $skill[Sea *dent: Summon a Wave]))
		{
			handleTracker($item[Monodent of the Sea], my_location().to_string(), "Summon a Wave", "auto_otherstuff");
			return true;
		}
	}
	return false;
}

boolean auto_talkToSomeFish(location loc, monster enemy)
{
	// returns true if we want to cast Talk to Some Fish. Not intended to exhaustivly list all valid targets
	// also, this is not actually a free fight, but this is a safe listing of targets

	if(!auto_haveMonodent()) return false;
	if(!auto_is_valid($skill[Sea *dent: Talk to Some Fish])) return false;
	// don't use Talk to Some Fish against inherently free fights
	if (isFreeMonster(enemy, loc)) { return false; }
	// need hippy / frat kills
	if(loc == $location[The Battlefield (Frat Uniform)] || loc == $location[The Battlefield (Hippy Uniform)])
	{
		return false;
	}
	// need chained fights
	if(loc == $location[The Haunted Bedroom])
	{
		return false;
	}
	// some fish has no meat drop, so this doesn't take familiar meat modifiers into account
	if(loc == $location[The Fungus Plains])
	{
		return false;
	}
	
	return auto_wantToFreeKillWithNoDrops(loc, enemy);
}

boolean auto_haveBCZ()
{
	if(possessEquipment($item[blood cubic zirconia]))
	{
		return true;
	}
	return false;
}

boolean auto_wantToBCZ(skill sk)
{
	if(!auto_haveBCZ() || !(canUse(sk)))
	{
		return false;
	}
	int bloodBathCasts = get_property("_bczBloodBathCasts").to_int();
	int bloodGeyserCasts = get_property("_bczBloodGeyserCasts").to_int();
	int bloodThinnerCasts = get_property("_bczBloodThinnerCasts").to_int();
	int dialItUpCasts = get_property("_bczDialitupCasts").to_int();
	int pheromoneCocktailCasts = get_property("_bczPheromoneCocktailCasts").to_int();
	int refractedGazeCasts = get_property("_bczRefractedGazeCasts").to_int();
	int spinalTapasCasts = get_property("_bczSpinalTapasCasts").to_int();
	int sweatBulletsCasts = get_property("_bczSweatBulletsCasts").to_int();
	int sweatEquityCasts = get_property("_bczSweatEquityCasts").to_int();

	int auto_bczCastMath(int cast)
	{
		if(cast == 12) return 420000;
		int castMath = cast;
		if(cast > 12) castMath -= 1;
		int castMathFloor = floor(castMath/3);
		if(cast > 12) castMathFloor += 1;
		int castMathModulo = (castMath % 3);
		int substatBase = 0;
		
		switch(castMathModulo)
		{
			case 0:
				substatBase = 11;
				break;
			case 1:
				substatBase = 23;
				break;
			case 2:
				substatBase = 37;
				break;
		}
		return substatBase * 10 ** castMathFloor;
		//11, 23, 37, 110, 230, 370, etc. 13th cast follows a different pattern but we will never get there but better to be safe than sorry
	}

	boolean statChange(stat st, int casts)
	{
		int level = my_level();
		if(my_level() >= 13)
		{
			level = 13;
		}
		int diff;
		if(st == my_primestat())
		{
			//Don't want to use so many substats we go down too many levels or we have cast more than we really need to/should
			//Don't go beneath our current level or level 13 if we cast the skill
			return my_basestat(stat_to_substat(st)) - level_to_min_substat(level) > auto_bczCastMath(casts);
		}
		//don't go below 70 of the other stats
		return ((my_basestat(st) ** 2) - 70 ** 2) > auto_bczCastMath(casts);
	}

	switch(sk)
	{
		//Muscle Casts
		case $skill[BCZ: Blood Geyser]:
			return (statChange($stat[muscle], bloodGeyserCasts) && (bloodGeyserCasts <= 6));
		case $skill[BCZ: Blood Bath]:
			return (statChange($stat[muscle], bloodBathCasts) && (bloodBathCasts <= 6));
		case $skill[BCZ: Create Blood Thinner]: //should never be cast, but if we want to support in the future, we can
			return (statChange($stat[muscle], bloodThinnerCasts) && (bloodThinnerCasts == 0));
		//Mysticality Casts
		case $skill[BCZ: Dial it up to 11]:
			return (statChange($stat[mysticality], dialItUpCasts) && (dialItUpCasts <= 3));
		case $skill[BCZ: Refracted Gaze]:
			return (statChange($stat[mysticality], refractedGazeCasts) && (refractedGazeCasts <= 6));
		case $skill[BCZ: Prepare Spinal Tapas]:
			return (statChange($stat[mysticality], spinalTapasCasts) && (spinalTapasCasts <= 3));
		//Moxie Casts
		case $skill[BCZ: Sweat Bullets]:
			return (statChange($stat[moxie], sweatBulletsCasts) && (sweatBulletsCasts <= 6));
		case $skill[BCZ: Sweat Equity]:
			return (statChange($stat[moxie], sweatEquityCasts) && (sweatEquityCasts <= 2));
		case $skill[BCZ: Craft a Pheromone Cocktail]:
			return (statChange($stat[moxie], pheromoneCocktailCasts) && (pheromoneCocktailCasts <= 6));
		default:
			return false;
	}
}

boolean auto_bczRefractedGaze()
{
	if(!auto_haveBCZ())
	{
		return false;
	}
	if(auto_havePeridot() && !haveUsedPeridot(my_location()))
	{
		//Will undoubtedly want Peridot in these locations
		//Other sources of issue (pocket wishes/mimic eggs) are fought in Noob Cave
		//Don't have support for the Crepe Paper Parachute Cape but that also causes issues
		return false;
	}
	if((my_location() == $location[The Smut Orc Logging Camp] && lumberCount() < bridgeGoal() && fastenerCount() < bridgeGoal()) ||
	(my_location() == $location[The Penultimate Fantasy Airship] && item_amount($item[Mohawk Wig]) < 1 && item_amount($item[Amulet of extreme plot significance]) < 1) ||
	(my_location() == $location[The Battlefield (Frat Uniform)]) ||
	(my_location() == $location[A-Boo Peak] && item_amount($item[A-Boo Clue]) * 30 < get_property("booPeakProgress").to_int()) ||
	(my_location() == $location[Cobb\'s Knob Harem]) ||
	(my_location() == $location[Twin Peak] && item_amount($item[Rusty Hedge Trimmers]) < 4) ||
	(my_location() == $location[The Black Forest] && !(black_market_available()) && item_amount($item[Reassembled Blackbird]) == 0 && monster_phylum() != $phylum[Beast]) || 
	(my_location() == $location[Whitey's Grove] && (item_amount($item[Lion Oil]) == 0 && item_amount($item[Bird Rib]) == 0 && item_amount($item[Wet Stew]) == 0 && item_amount($item[wet stunt nut stew]) == 0) && monster_phylum() != $phylum[Beast]) ||
	(my_location() == $location[The Hidden Apartment Building] && last_monster() == $monster[pygmy shaman]) ||
	(my_location() == $location[The Defiled Nook] && last_monster() == $monster[party skelteon])
	)
	{
		return true;
	}
	return false;
}

void auto_getBCZItems()
{
	if(!auto_haveBCZ())
	{
		return;
	}
	
	if(auto_wantToBCZ($skill[BCZ: Craft a Pheromone Cocktail]))
	{
		handleTracker($item[Blood Cubic Zirconia], $item[Pheromone Cocktail],"auto_iotm_claim");
		use_skill(1, $skill[BCZ: Craft a Pheromone Cocktail]);
	}
	if(auto_wantToBCZ($skill[BCZ: Prepare Spinal Tapas]))
	{
		handleTracker($item[Blood Cubic Zirconia], $item[Spinal Tapas],"auto_iotm_claim");
		use_skill(1, $skill[BCZ: Prepare Spinal Tapas]);
	}

	return;
}

boolean auto_haveShrunkenHead()
{
	if(get_property("hasShrunkenHead").to_boolean() && auto_is_valid($item[shrunken head]))
	{
		return true;
	}
	return false;
}

boolean auto_wantToShrunkenHead(monster enemy)
{
	if(!auto_haveShrunkenHead())
	{
		return false;
	}

	if(!(canUse($skill[Prepare to reanimate your Foe])))
	{
		return false;
	}

	if (!enemy.copyable)
	{
		return false;
	}

	// as the created zombie doesn't die, get one that gives +item and no passive damage
	boolean hasItem = false;
	foreach i, bonus in shrunken_head_zombie(enemy)
	{
		if(bonus.contains_text("Attack"))
		{
			return false;
		}
		if(bonus.contains_text("Item Drop"))
		{
			hasItem = true;
		}
	}

	return hasItem;
}

boolean auto_wantToShrunkenHead(location place)
{
	if(!auto_haveShrunkenHead())
	{
		return false;
	}

	monster next = get_property("auto_nextEncounter").to_monster();
	if(next != $monster[none])
	{
		//next monster is forced by zone mechanics or some other mechanism
		return auto_wantToShrunkenHead(next);
	}
	else
	{
		foreach i,mon in get_monsters(place)
		{
			if(appearance_rates(place)[mon] > 0)
			{
				if (auto_wantToShrunkenHead(mon))
				{
					return true;
				}
			}
		}
	}
	return false;
}

boolean auto_haveCrimboSkeleton()
{
	if(auto_have_familiar($familiar[Skeleton of Crimbo Past]))
	{
		return true;
	}
	return false;
}

void auto_wantSoCP()
{
	if(!auto_haveCrimboSkeleton())
	{
		return;
	}
	set_property("auto_preferSoCP", true);
	if(get_property("_knuckleboneDrops").to_int() == 100)
	{
		set_property("auto_preferSoCP", false);
		return;
	}
	float amt = 0;
	foreach phyl in $phylums[constellation, elemental, hippy, horror, mer-kin, plant, slime, bug]
	{
		amt += auto_zonePhylumPercent(my_location(), phyl);
	}
	if(amt > 0.1)
	{
		//want 10% or fewer of the available mobs to be knucklebone eligible, otherwise why bother with this guy vs fairychauns/fairyballs/fairyeverythings?
		set_property("auto_preferSoCP", false);
		return;
	}
	
	return;
}
