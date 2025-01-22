# This is meant for items that have a date of 2024

import <c2t_apron.ash>// used in consumeBlackAndWhiteApronKit()

boolean consumeBlackAndWhiteApronKit()
{
	item apronKit = $item[Black and White Apron Meal Kit];
	if(fullness_left() < 3)
	{
		return false;
	}
	if(item_amount(apronKit) < 1)
	{
		return false;
	}

	if(!git_exists("C2Talon-c2t_apron-master"))
	{
		abort("script c2t_apron didn't install properly. Fix and run autoscend again.");
	}
	
	// default ingredient allow list. Allow all but:
	// Potentially quest relevant: Blackberry, Bubblin' crude, enchanted bean
	// Extra cold damage: grapefruit
	// 20ml: dill
	string allowList = "3489,1356,1560,2525,3490,748,1562,1557,1561,3491,\
	1122,1559,2094,183,182,2338,237,787,1004,238,328,1005,2583,1006,589,672,2524,304,6724,\
	1462,161,158,358,2589,55,302,332,170,2532,187,357,245,242,4956,830,165,1003,8,786,1558,\
	246,4,159,209";

	// allow quest items if no longer needed
	if(possessEquipment($item[Blackberry Galoshes]) || item_amount($item[Blackberry]) > 3)
	{
		allowList += ",2063";
	}
	int oilProgress = get_property("twinPeakProgress").to_int();
	if(((oilProgress & 4) == 1) || item_amount($item[Jar Of Oil]) > 0 || item_amount($item[Bubblin\' Crude]) > 12)
	{
		allowList += ",5789";
	}
	if(item_amount($item[Enchanted Bean]) > 1 || internalQuestStatus("questL10Garbage") >= 1)
	{
		allowList += ",186";
	}
	set_property("c2t_apron_allowlist",allowList);
	
	// consume the apron kit using c2t's script
	// this will default to consuming food for our current mainstat
	// https://github.com/C2Talon/c2t_apron
	return c2t_apron();
}

boolean auto_haveSpringShoes()
{
	if(auto_is_valid($item[spring shoes]) && available_amount($item[spring shoes]) > 0 )
	{
		return true;
	}
	return false;
}

boolean auto_haveAprilingBandHelmet()
{
	if(auto_is_valid($item[Apriling band helmet]) && available_amount($item[Apriling band helmet]) > 0 )
	{
		return true;
	}
	return false;
}

boolean auto_getAprilingBandItems()
{
	if(!auto_haveAprilingBandHelmet()) {return false;}
	boolean have_sax  = available_amount($item[Apriling band saxophone]) > 0;
	boolean have_tuba = available_amount($item[Apriling band tuba]     ) > 0;
	int instruments_so_far = get_property("_aprilBandInstruments").to_int();
	if (!have_tuba && instruments_so_far < 2) { cli_execute("aprilband item tuba"); }
	instruments_so_far = get_property("_aprilBandInstruments").to_int();
	if (!have_sax && instruments_so_far < 2) { cli_execute("aprilband item saxophone"); }
	
	have_sax  = available_amount($item[Apriling band saxophone]) > 0;
	have_tuba = available_amount($item[Apriling band tuba]     ) > 0;
	
	return have_sax && have_tuba;
}

boolean auto_playAprilSax()
{
	cli_execute("aprilband play saxophone");
	return have_effect($effect[Lucky!]).to_boolean();
}

boolean auto_playAprilTuba()
{
	cli_execute("aprilband play tuba");
	return get_property("noncombatForcerActive").to_boolean();
}

boolean auto_setAprilBandNonCombat()
{
	if(have_effect($effect[Apriling Band Patrol Beat]).to_boolean()) {return true;}
	if(!auto_haveAprilingBandHelmet()) {return false;}
	cli_execute("aprilband effect nc");
	return have_effect($effect[Apriling Band Patrol Beat]).to_boolean();
}

boolean auto_setAprilBandCombat()
{
	if(have_effect($effect[Apriling Band Battle Cadence]).to_boolean()) {return true;}
	if(!auto_haveAprilingBandHelmet()) {return false;}
	cli_execute("aprilband effect c");
	return have_effect($effect[Apriling Band Battle Cadence]).to_boolean();
}

boolean auto_setAprilBandDrops()
{
	if(have_effect($effect[Apriling Band Celebration Bop]).to_boolean()) {return true;}
	if(!auto_haveAprilingBandHelmet()) {return false;}
	cli_execute("aprilband effect drop");
	return have_effect($effect[Apriling Band Celebration Bop]).to_boolean();
}

int auto_AprilSaxLuckyLeft()
{
	if(!auto_haveAprilingBandHelmet()) {return 0;}
	if(available_amount($item[Apriling band saxophone]) == 0) {return 0;}
	return 3-get_property("_aprilBandSaxophoneUses").to_int();
}

int auto_AprilTubaForcesLeft()
{
	if(!auto_haveAprilingBandHelmet()) {return 0;}
	if(available_amount($item[Apriling band tuba]) == 0) {return 0;}
	return 3-get_property("_aprilBandTubaUses").to_int();
}

boolean auto_haveDarts()
{
	if(auto_is_valid($item[Everfull Dart Holster]) && possessEquipment($item[Everfull Dart Holster]))
	{
		return true;
	}
	return false;
}

void dartChoiceHandler(int choice, string[int] options)
{
	auto_log_info("dartChoiceHandler Running choice " + choice, "blue");
	
	int dcchoice = 0;
	foreach idx, str in options
	{
		auto_log_info("choice " + idx + " is " + str, "blue");
	}
	foreach perk in $strings[impress,better,targeting,butt] //Ranked as 1. Shorter ELR CD, 2. bullseye chance, 3. Butt Awareness, 4. Everything else
	{
		foreach idx, str in options
		{
			if(contains_text(str.to_lower_case(),perk))
			{
				dcchoice = idx;
				break;
			}
		}
		if(dcchoice != 0) break;
	}
	if(dcchoice == 0) dcchoice = 1; //if choice is not set, just choose the 1st option
	run_choice(dcchoice);
}

int dartBullseyeChance()
{
	string[int] perks;
	int chance = 25; // base bullseye chance is 25%
	perks = split_string(get_property("everfullDartPerks").to_string().to_lower_case(), ",");
	foreach perk in perks
	{
		if (contains_text(perks[perk], "better") || contains_text(perks[perk], "targeting"))
		{
			chance += 25;
		}	
	}
	return chance;
}

int dartELRcd()
{
	string[int] perks;
	int cd = 50; // base cd is 50 turns
	perks = split_string(get_property("everfullDartPerks").to_string().to_lower_case(), ",");
	foreach perk in perks
	{
		if (contains_text(perks[perk], "impress"))
		{
			cd -= 10;
		}	
	}
	return cd;
}

skill dartSkill()
{
	string[int] curDartboard;
	curDartboard = split_string(get_property("_currentDartboard").to_string().to_lower_case(), ",");
	foreach sk in curDartboard
	{
		if(contains_text(curDartboard[sk], "butt")) // get more items
		{
			auto_log_info("Going for the butt", "blue");
			return to_skill(substring(curDartboard[sk],0,4).to_int());
		}
		else if(contains_text(curDartboard[sk], "torso") || contains_text(sk, "pseudopod")) //get more meat
		{
			auto_log_info("Going for the chest", "blue");
			return to_skill(substring(curDartboard[sk],0,4).to_int());
		}
	}
	return to_skill(7513); // If there aren't any darts available return the Darts: Throw at %PART1
}

boolean dartEleDmg()
{
	string perks = get_property("everfullDartPerks").to_string().to_lower_case();
	if(contains_text(perks, "add ")) // Only ele dmg perks have "add " in their perk description so as long as we have 1, we are good
	{
		return true;
	}	
	return false;
}

boolean auto_haveMayamCalendar()
{
	if(!in_lol() && auto_is_valid($item[Mayam Calendar]) && available_amount($item[Mayam Calendar]) > 0 )
	{
		return true;
	}
	return false;
}

boolean auto_MayamIsUsed(string glyph)
{
	string[int] used = split_string(get_property("_mayamSymbolsUsed"),",");
	foreach idx,str in used
	{
		if (glyph==str)
		{
			return true;
		}
	}
	return false;
}

boolean auto_MayamAllUsed()
{
	// mayam is currently fully used if all 3 ring1 symbols have been used
	return auto_MayamIsUsed("yam4") && auto_MayamIsUsed("clock") && auto_MayamIsUsed("explosion");
}

boolean auto_MayamClaimStinkBomb()
{
	if(!auto_haveMayamCalendar())
	{
		return false;
	}
	if(auto_MayamIsUsed("vessel") ||
	   auto_MayamIsUsed("yam2")   ||
	   auto_MayamIsUsed("cheese") ||
	   auto_MayamIsUsed("explosion") )
	{
		return false;
	}
	cli_execute("mayam rings vessel yam cheese explosion");
	return true;
}

boolean auto_MayamClaimBelt()
{
	if(!auto_haveMayamCalendar())
	{
		return false;
	}
	if(auto_MayamIsUsed("yam1") ||
	   auto_MayamIsUsed("meat")   ||
	   auto_MayamIsUsed("eyepatch") ||
	   auto_MayamIsUsed("yam4") )
	{
		return false;
	}
	cli_execute("mayam rings yam meat eyepatch yam");
	return true;
}

boolean auto_MayamClaimWhatever()
{
	if(!auto_haveMayamCalendar())
	{
		return false;
	}
	string ring1 = "BAD_VALUE";
	string ring2 = "BAD_VALUE";
	string ring3 = "BAD_VALUE";
	string ring4 = "BAD_VALUE";
	boolean failure = false;
	
	if      (!auto_MayamIsUsed("chair") && auto_haveCincho())   { ring1 = "chair"; }
	// todo: add support for giving appropriate fam 100xp with fur option
	else if (!auto_MayamIsUsed("eye"))    { ring1 = "eye"; }
	else if (!auto_MayamIsUsed("vessel")) { ring1 = "vessel"; }
	else { failure = true; }
	
	if      (!auto_MayamIsUsed("wood") && (lumberCount() < 30 || fastenerCount() < 30))   { ring2 = "wood"; }
	else if (!auto_MayamIsUsed("lightning"))   { ring2 = "lightning"; }
	else if (!auto_MayamIsUsed("meat"))   { ring2 = "meat"; }
	else { failure = true; }
	
	boolean going_to_use_mouthwash = my_level()<13 && remainingEmbers() >= 2;
	if (going_to_use_mouthwash && !auto_MayamIsUsed("wall")) { ring3 = "wall"; }
	else if (!auto_MayamIsUsed("yam3"))   { ring3 = "yam"; }
	else if (!auto_MayamIsUsed("cheese")) { ring3 = "cheese"; }
	else if (!auto_MayamIsUsed("wall"))   { ring3 = "wall"; }
	else { failure = true; }
	
	if      (!auto_MayamIsUsed("yam4"))      { ring4 = "yam"; }
	else if (!auto_MayamIsUsed("clock"))     { ring4 = "clock"; }
	else if (!auto_MayamIsUsed("explosion")) { ring4 = "explosion"; }
	else { failure = true; }
	if (failure)
	{
		return false;
	}
	
	cli_execute("mayam rings "+ring1+" "+ring2+" "+ring3+" "+ring4);
	return true;
}

boolean auto_MayamClaimAll()
{
	if(!auto_haveMayamCalendar())
	{
		return false;
	}
	if(auto_MayamAllUsed())
	{
		return false;
	}
	auto_log_info("Claiming mayam calendar items");
	auto_MayamClaimStinkBomb();
	auto_MayamClaimBelt();
	auto_MayamClaimWhatever();
	auto_MayamClaimWhatever();
	auto_MayamClaimWhatever();
	return true;
}

boolean auto_haveRoman()
{
	if(auto_is_valid($item[Roman Candelabra]) && possessEquipment($item[Roman Candelabra]))
	{
		return true;
	}
	return false;
}

boolean auto_haveBatWings()
{
	if(auto_is_valid($item[Bat Wings]) && possessEquipment($item[Bat Wings]))
	{
		return true;
	}
	return false;
}

boolean auto_canLeapBridge()
{
	// bat wings allow for us to leap bridge at 5/6 progress (25 of 30)
	if(!auto_haveBatWings())
	{
		return false;
	}
	if(fastenerCount() < 25 || lumberCount() < 25)
	{
		return false;
	}
	return true;
}

boolean auto_haveSeptEmberCenser()
{
	if(auto_is_valid($item[Sept-Ember Censer]) && available_amount($item[Sept-Ember Censer]) > 0 )
	{
		return true;
	}
	return false;
}

int remainingEmbers()
{
	if(!auto_haveSeptEmberCenser())
	{
		return 0;
	}
	if(!get_property("_septEmberBalanceChecked").to_boolean())
	{
		// go to ember shop to check our balance
		use($item[Sept-Ember Censer]);
	}
	return get_property("availableSeptEmbers").to_int();
}

void auto_buyFromSeptEmberStore()
{
	if(!auto_haveSeptEmberCenser())
	{
		return;
	}
	if(remainingEmbers() == 0)
	{
		return;
	}

	// mouthwash for leveling
	item mouthwash = $item[Mmm-brr! brand mouthwash];
	boolean disregard_karma = get_property("auto_disregardInstantKarma").to_boolean();
	auto_openMcLargeHugeSkis(); // make sure our skis are open for cold res
	for (int imw = 0 ; imw < 3 ; imw++) // We can use up to 3 mouthwash
	{
		// If we have at least 4 embers remaining, don't overlevel, they can be used for something else
		boolean happy_to_overlevel = disregard_karma && remainingEmbers() < 4;
		boolean want_to_mouthwash_level = (my_level() < 13 || happy_to_overlevel);
		// Even disregarding karma, never level above 15 using mouthwash as a sanity limit
		want_to_mouthwash_level = want_to_mouthwash_level && my_level()<15;
		if (remainingEmbers() >= 2 && want_to_mouthwash_level)
		{
			// get as much cold res as possible
			int [element] resGoal;
			resGoal[$element[cold]] = 100;
			// get cold res. Use noob cave as generic place holder
			
			// get 1 bembershoot to support mouthwash leveling or general quest help
			item bember = $item[bembershoot];
			if (remainingEmbers() % 2 == 1 && !possessEquipment(bember) && auto_is_valid(bember))
			{
				buy($coinmaster[Sept-Ember Censer], 1, bember);
			}
			
			provideResistances(resGoal, $location[noob cave], true);
			equipMaximizedGear();
			
			// We could have left-hand if our off-hand is strong enough
			float cold_res_from_oh = numeric_modifier(equipped_item($slot[off-hand]),$modifier[cold resistance]);
			// McHugeLarge outfit off-hand is +3 cold res when whole outfit equipped, but not reported by Mafia with above check
			boolean using_mchugelarge_oh = equipped_item($slot[off-hand]) == $item[McHugeLarge left pole];
			if (using_mchugelarge_oh || cold_res_from_oh > 2.9)
			{
				skill lefty = $skill[Aug. 13th: Left/Off Hander's Day!];
				if(canUse(lefty) && !get_property("_aug13Cast").to_boolean())
				{
					use_skill(lefty);
				}
			}
			
			if (expected_level_after_mouthwash()<13) // use a wish if really need it
			{
				auto_wishForEffectIfNeeded($effect[Fever From the Flavor]);
			}
			// buy mouthwash and use it
			buy($coinmaster[Sept-Ember Censer], 1, mouthwash);
			auto_log_debug(`Using mouthwash with {numeric_modifier($modifier[cold resistance])} cold resistance`);
			use(mouthwash);
		}
	}
	
	auto_log_debug("Have " + remainingEmbers() + " embers(s) to buy from Sept-Ember Censer. Let's spend them!");
	// get structural ember if can't cross bridge
	item itemConsidering = $item[Structural ember];
	if(remainingEmbers() >= 4 && get_property("chasmBridgeProgress").to_int() < bridgeGoal() && 
		!get_property("_structuralEmberUsed").to_boolean() && auto_is_valid(itemConsidering))
	{
		buy($coinmaster[Sept-Ember Censer], 1, itemConsidering);
		use(itemConsidering);
	}
	
	// Spend any remaining pairs on Septapus summoning charms
	while (remainingEmbers() >= 2)
	{
		buy($coinmaster[Sept-Ember Censer], 1, $item[Septapus summoning charm]);
	}
	
	// if still have embers, get hat for mp regen
	itemConsidering = $item[Hat of remembering];
	if(remainingEmbers() >= 1 && !possessEquipment(itemConsidering) && auto_is_valid(itemConsidering))
	{
		buy($coinmaster[Sept-Ember Censer], 1, itemConsidering);
	}
	
	return;
}

float expected_mouthwash_main_substat()
{
	return expected_mouthwash_main_substat(numeric_modifier($modifier[cold resistance]));
}

float expected_mouthwash_main_substat(float cold_res)
{
	float boost_factor = 1+stat_exp_percent(my_primestat())/100;
	return boost_factor * 14 * (cold_res**1.7) / 2;
}

float expected_level_after_mouthwash()
{
	return expected_level_after_mouthwash(1, numeric_modifier($modifier[cold resistance]));
}

float expected_level_after_mouthwash(int n_mouthwash)
{
	return expected_level_after_mouthwash(n_mouthwash,numeric_modifier($modifier[cold resistance]));
}

float expected_level_after_mouthwash(int n_mouthwash, float cold_res)
{
	float gained_main_substats = n_mouthwash * expected_mouthwash_main_substat(cold_res);
	int old_main_substats = my_basestat(stat_to_substat(my_primestat()));
	float new_main_substats = old_main_substats + gained_main_substats;
	float level = substat_to_level(new_main_substats);
	return level;
}


boolean auto_haveTearawayPants()
{
	if(auto_is_valid($item[Tearaway Pants]) && available_amount($item[Tearaway Pants]) > 0 )
	{
		return true;
	}
	return false;
}

boolean auto_haveTakerSpace()
{
	return auto_get_campground() contains $item[TakerSpace letter of Marque] && auto_is_valid($item[TakerSpace letter of Marque]);
}

void auto_checkTakerSpace()
{
	if(!auto_haveTakerSpace()) return;
	static item ts_letter = $item[TakerSpace letter of Marque];
	if(!get_property("_takerSpaceSuppliesDelivered").to_boolean()) {
		// visit the workshed to get the supplies
		visit_url("campground.php?action=workshed");
	}
	// unlock the island if we can (6 turn save)
	if(get_property("lastIslandUnlock").to_int() < my_ascensions() && item_amount($item[pirate dinghy]) == 0 && creatable_amount($item[pirate dinghy]) > 0) {
		if (create(1, $item[pirate dinghy])) {
			handleTracker(to_string(ts_letter),$item[pirate dinghy],"auto_iotm_claim");
		}
	}
	// deft pirate hook would be worth it but hard for autoscend to use
	// anchor bomb is a free banish but only for 30 turns, if we have Spring Kick we won't use it
	if(!(auto_haveSpringShoes() && auto_is_valid($skill[Spring Kick])) && creatable_amount($item[anchor bomb]) > 0) {
		if (create(1, $item[anchor bomb])) {
			handleTracker(to_string(ts_letter),$item[anchor bomb],"auto_iotm_claim");
		}
	}
	// goldschlepper is EPIC booze
	int createable = creatable_amount($item[tankard of spiced Goldschlepper]);
	if(createable > 0) {
		if (create(1, $item[tankard of spiced Goldschlepper])) {
			handleTracker(to_string(ts_letter),$item[tankard of spiced Goldschlepper],"auto_iotm_claim");
		}
	}
	// tankard of spiced rum is awesome booze
	createable = creatable_amount($item[tankard of spiced rum]);
	if(createable > 0) {
		if (create(1, $item[tankard of spiced rum])) {
			handleTracker(to_string(ts_letter),$item[tankard of spiced rum],"auto_iotm_claim");
		}
	}
	// cursed Aztec tamale is awesome food, and only uses spices
	createable = creatable_amount($item[cursed Aztec tamale]);
	if(createable > 0) {
		if (create(1, $item[cursed Aztec tamale])) {
			handleTracker(to_string(ts_letter),$item[cursed Aztec tamale],"auto_iotm_claim");
		}
	}
}

boolean auto_haveClanPhotoBoothHere()
{
	if(available_amount($item[Clan VIP Lounge Key]) == 0)
	{
		return false;
	}
	if(!auto_is_valid($item[photo booth sized crate]))
	{
		return false;
	}
	return auto_get_clan_lounge() contains $item[photo booth sized crate];
}

boolean auto_haveClanPhotoBooth()
{
	if(available_amount($item[Clan VIP Lounge Key]) == 0)
	{
		return false;
	}
	if(!auto_is_valid($item[photo booth sized crate]))
	{
		return false;
	}
	boolean bafh_available = isWhitelistedToBAFH() && canReturnToCurrentClan(); // bafh has it fully stocked
	return bafh_available || auto_haveClanPhotoBoothHere();
}

boolean auto_isClanPhotoBoothItem(item it)
{
	switch (it)
	{
		case $item[photo booth supply list]:
		case $item[fake arrow-through-the-head]:
		case $item[fake huge beard]:
		case $item[astronaut helmet]:
		case $item[cheap plastic pipe]:
		case $item[oversized monocle on a stick]:
		case $item[giant bow tie]:
		case $item[feather boa]:
		case $item[Sheriff badge]:
		case $item[Sheriff pistol]:
		case $item[Sheriff moustache]:
			return true;
	}
	return false;
}

boolean auto_thisClanPhotoBoothHasItem(item it)
{
	// This should work but it's not implemented by Mafia, sounds like it won't be
	//~ return (auto_get_clan_lounge() contains it)
	
	// Instead just assume BAFH has everything, everyone else has nothing that needs unlocking
	if (get_clan_id() == getBAFHID())
	{
		return auto_isClanPhotoBoothItem(it);
	}
	switch (it)
	{
		case $item[photo booth supply list]:
		case $item[fake arrow-through-the-head]:
		case $item[fake huge beard]:
		case $item[astronaut helmet]:
			return true;
	}
	return false;
}

boolean auto_thisClanPhotoBoothHasItems(boolean[item] its)
{
	boolean success = true;
	foreach it,b in its
	{
		success = success && auto_thisClanPhotoBoothHasItem(it);
	}
	return false;
}

boolean auto_getClanPhotoBoothDefaultItems()
{
	if (!auto_haveClanPhotoBooth())
	{
		return false;
	}
	boolean[item] items_to_claim = $items[fake arrow-through-the-head, astronaut helmet, oversized monocle on a stick];
	int orig_clan_id = get_clan_id();
	boolean in_bafh = orig_clan_id == getBAFHID();
	boolean bafh_available = isWhitelistedToBAFH() && canReturnToCurrentClan(); // bafh has it fully stocked
	if (bafh_available && !in_bafh && !auto_thisClanPhotoBoothHasItems(items_to_claim))
	{
		changeClan();
	}
	boolean success = true;
	foreach it,b in items_to_claim
	{
		success = success && auto_getClanPhotoBoothItem(it);
	}
	if (orig_clan_id != get_clan_id())
	{
		changeClan(orig_clan_id);
	}
	return success;
}

boolean auto_getClanPhotoBoothItem(item it)
{
	if (!auto_haveClanPhotoBooth())
	{
		return false;
	}
	if (!auto_isClanPhotoBoothItem(it))
	{
		return false;
	}
	if (available_amount(it)>0)
	{
		return true;
	}
	// Handle whether we want to jump to BAFH for the item
	int orig_clan_id = get_clan_id();
	boolean in_bafh = orig_clan_id == getBAFHID();
	boolean bafh_available = isWhitelistedToBAFH() && canReturnToCurrentClan(); // bafh has it fully stocked
	if (bafh_available && !in_bafh && !auto_thisClanPhotoBoothHasItem(it))
	{
		changeClan();
	}
	
	// Actually claim the item
	cli_execute("photobooth item "+to_string(it));
	handleTracker("Clan Photo Booth","Claimed "+it, "auto_iotm_claim");
	
	// Go home if we BAFH'd it
	if (orig_clan_id != get_clan_id())
	{
		changeClan(orig_clan_id);
	}
	
	if (available_amount(it)>0)
	{
		return true;
	}
	return false;
}

int auto_remainingClanPhotoBoothEffects()
{
	if (!auto_haveClanPhotoBooth())
	{
		return 0;
	}
	return 3-get_property("_photoBoothEffects").to_int();
}

string auto_getClanPhotoBoothEffectString(effect ef)
{
	switch(ef)
	{
		case $effect[Wild and Westy!]:
			return "wild";
		case $effect[Towering Muscles]:
			return "tower";
		case $effect[Spaced Out]:
			return "space";
	}
	return "none";
}

boolean auto_getClanPhotoBoothEffect(effect ef)
{
	return auto_getClanPhotoBoothEffect(ef,1);
}

boolean auto_getClanPhotoBoothEffect(effect ef, int n_times)
{
	string effect_string = auto_getClanPhotoBoothEffectString(ef);
	if (effect_string == "none")
	{
		auto_log_error("Invalid effect for photo booth "+ef.to_string());
		return false;
	}
	return auto_getClanPhotoBoothEffect(effect_string);
}

boolean auto_getClanPhotoBoothEffect(string ef_string)
{
	return auto_getClanPhotoBoothEffect(ef_string,1);
}

boolean auto_getClanPhotoBoothEffect(string ef_string, int n_times)
{
	if(available_amount($item[Clan VIP Lounge Key]) == 0)
	{
		return false;
	}
	if(!auto_is_valid($item[photo booth sized crate]))
	{
		return false;
	}
	
	n_times = min(n_times,auto_remainingClanPhotoBoothEffects());
	if (n_times < 1)
	{
		return false;
	}
	
	// Handle whether we want to jump to BAFH
	int orig_clan_id = get_clan_id();
	boolean in_bafh = orig_clan_id == getBAFHID();
	boolean bafh_available = isWhitelistedToBAFH() && canReturnToCurrentClan(); // bafh has it fully stocked
	
	if (!auto_haveClanPhotoBoothHere() && bafh_available)
	{
		changeClan(); // Jump to BAFH
	}
	
	boolean success = false;
	effect west_ef  = $effect[Wild and Westy!];
	effect tower_ef = $effect[Towering Muscles];
	effect space_ef = $effect[Spaced Out];
	string west_string  = to_lower_case(to_string(west_ef ));
	string tower_string = to_lower_case(to_string(tower_ef));
	string space_string = to_lower_case(to_string(space_ef));
	switch(to_lower_case(ef_string))
	{
		case "wild":
		case west_string:
			for (int i = 0 ; i < n_times ; i++)
			{
				cli_execute("photobooth effect wild");
				handleTracker("Clan Photo Booth","Claimed "+west_ef, "auto_iotm_claim");
			}
			success = to_boolean(have_effect(west_ef));
			break;
		case "tower":
		case tower_string:
			for (int i = 0 ; i < n_times ; i++)
			{
				cli_execute("photobooth effect tower");
				handleTracker("Clan Photo Booth","Claimed "+tower_ef, "auto_iotm_claim");
			}
			success = to_boolean(have_effect(tower_ef));
			break;
		case "space":
		case space_string:
			for (int i = 0 ; i < n_times ; i++)
			{
				cli_execute("photobooth effect space");
				handleTracker("Clan Photo Booth","Claimed "+space_ef, "auto_iotm_claim");
			}
			success = to_boolean(have_effect(space_ef));
			break;
	}
	// Go home if we BAFH'd it
	if (orig_clan_id != get_clan_id())
	{
		changeClan(orig_clan_id);
	}
	
	if (success)
	{
		return true;
	}
	auto_log_error("Invalid effect string for photo booth "+ef_string);
	return false;
}
