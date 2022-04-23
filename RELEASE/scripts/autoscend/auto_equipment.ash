string getMaximizeSlotPref(slot s)
{
	return "_auto_maximize_equip_" + s.to_string();
}

item getTentativeMaximizeEquip(slot s)
{
	return get_property(getMaximizeSlotPref(s)).to_item();
}

boolean autoEquip(slot s, item it)
{
	if(!possessEquipment(it) || !auto_can_equip(it))
	{
		return false;
	}

	if(s == $slot[acc3] &&
		(it.to_string() == get_property("_auto_maximize_equip_acc1")) ||
		(it.to_string() == get_property("_auto_maximize_equip_acc2")) ||
		(it.to_string() == get_property("_auto_maximize_equip_acc3")))
	{
		auto_log_warning("Ignoring duplicate equip of accessory " + it);
		return true;
	}

	// This logic lets us force the equipping of multiple accessories with minimal conflict
	boolean acc1_empty = ("" == get_property("_auto_maximize_equip_acc1")) && !contains_text(get_property("auto_maximize_current"), "acc1");
	boolean acc2_empty = ("" == get_property("_auto_maximize_equip_acc2")) && !contains_text(get_property("auto_maximize_current"), "acc2");
	boolean acc3_empty = ("" == get_property("_auto_maximize_equip_acc3")) && !contains_text(get_property("auto_maximize_current"), "acc3");
	if((item_type(it) == "accessory") && s == $slot[acc3] && !acc3_empty)
	{
		if(acc2_empty)
		{
			s = $slot[acc2];
		}
		else if(acc1_empty)
		{
			s = $slot[acc1];
		}
		else
		{
			auto_log_warning("We can not equip " + it + " because our slots are all full.", "red");
			return false;
		}
	}

	auto_log_info("Equipping " + it + " to slot " + s, "gold");

	return tryAddItemToMaximize(s, it);
}

boolean autoEquip(item it)
{
	return autoEquip(it.to_slot(), it);
}

// specifically intended for forcing something in to a specific slot,
// instead of just forcing it to be equipped in general
// mostly for the Antique Machete and unstable fulminate
boolean autoForceEquip(slot s, item it)
{
	if(!possessEquipment(it) || !auto_can_equip(it))
	{
		return false;
	}
	if($slot[off-hand] == s)
	{
		if (weapon_hands(equipped_item($slot[weapon])) > 1)
		{
			removeFromMaximize("+equip " + equipped_item($slot[weapon]));
			equip($slot[weapon], $item[none]);
		}
		removeFromMaximize("-equip " + it);
		addToMaximize("-off-hand, 1hand");
		return equip($slot[off-hand], it);
	}
	if(equip(s, it))
	{
		removeFromMaximize("-equip " + it);
		addToMaximize("-" + s);
		return true;
	}
	return false;
}

boolean autoForceEquip(item it)
{
	// Maximizer will put its preferred accessories in order acc1,acc2,acc3
	// So for accessories, use acc3 for a force as that will get the best remaining maximizer score.
	if (it.to_slot()==$slot[acc1])
	{
		return autoForceEquip($slot[acc3], it);
	}
	return autoForceEquip(it.to_slot(), it);
}

boolean autoOutfit(string toWear)
{
	if(!possessOutfit(toWear, true))
	{
		return false;
	}

	// yes I could use +outfit instead here but this makes it simpler to avoid failed maximize calls
	auto_log_debug('Adding outfit "' + toWear + '" to maximizer statement', "gold");

	// Accessory items from outfits we commonly wear
	boolean[item] CommonOutfitAccessories = $items[eXtreme mittens, bejeweled pledge pin, round purple sunglasses, Oscus\'s pelt, Stuffed Shoulder Parrot];

	boolean pass = true;
	foreach i,it in outfit_pieces(toWear)
	{
		// Keep required accessories in acc3 slot to preserve our format
		if(CommonOutfitAccessories contains it)
		{
			pass = pass && autoEquip($slot[acc3], it);
		}
		else
		{
			pass = pass && autoEquip(it);
		}
	}
	return pass;
}

boolean autoStripOutfit(string toRemove) {
	// removes an outfit if you have it equipped

	item[int] outfit_pieces = outfit_pieces(toRemove);
	if (count(outfit_pieces) == 0 || !is_wearing_outfit(toRemove)) {
		return false;
	}
	auto_log_info(`Removing your {toRemove} outfit as requested.`, "blue");
	foreach _, piece in outfit_pieces {
		if (to_slot(piece) != $slot[acc1]) {
			equip(to_slot(piece), $item[none]);
		} else {
			foreach accSlot in $slots[acc1, acc2, acc3] {
				if (equipped_item(accSlot) == piece) {
					equip(accSlot, $item[none]);
					break;
				}
			}
		}
	}
	return is_wearing_outfit(toRemove);
}

boolean tryAddItemToMaximize(slot s, item it)
{
	if(!($slots[hat, back, shirt, weapon, off-hand, pants, acc1, acc2, acc3, familiar] contains s))
	{
		auto_log_error("But " + s + " is an invalid equip slot... What?");
		return false;
	}
	switch(s)
	{
		case $slot[weapon]:
			if(it.weapon_hands() > 1)
			{
				set_property(getMaximizeSlotPref($slot[off-hand]), "");
			}
			break;
		case $slot[off-hand]:
			if(getTentativeMaximizeEquip($slot[weapon]).weapon_hands() > 1)
			{
				set_property(getMaximizeSlotPref($slot[weapon]), "");
			}
			// TODO: Ranged/melee mismatch handling
			break;
	}

	string itString = it.to_string();
	// maximizer uses commas, so can't have a comma in an item name
	// fortunately fuzzy matching means just stripping out the comma is fine
	itString = itString.replace_string(",", "");
	set_property(getMaximizeSlotPref(s), itString);
	return true;
}

item[slot] speculatedMaximizerEquipment(string statement)
{
	//make maximizer simulate with the given statement then return the list of equipment it has chosen
	item [slot] res;
	boolean weaponPicked;
	boolean offhandPicked;
	foreach i,entry in maximize(statement,0,0,true,true)	//can't use autoMaximize "Aggregate reference expected"
	{
		if(i>15)
		{
			//there should not be more than 9 or 10 equipment slots and equipment entries come first. so equipment list is done
			break;
		}
		item maximizerItem = entry.item;
		if(maximizerItem == $item[none]) continue;
		slot maximizerItemSlot = maximizerItem.to_slot();
		if(maximizerItemSlot == $slot[none]) continue;
		slot overrideSlot;
		if(maximizerItemSlot == $slot[weapon])
		{
			if(weaponPicked && offhandPicked)
			{
				//this must be familiar weapon
				overrideSlot = $slot[familiar];
			}
			else if(weaponPicked)
			{
				//this must be offhand weapon
				overrideSlot = $slot[off-hand];
				offhandPicked = true;
			}
			else
			{
				weaponPicked = true;
				if(weapon_hands(maximizerItem) > 1)	offhandPicked = true;
			}
		}
		else if(maximizerItemSlot == $slot[off-hand])
		{
			if(offhandPicked)
			{
				//this must be familiar offhand
				overrideSlot = $slot[familiar];
			}
			else
			{
				offhandPicked = true;
			}
		}
		else if(maximizerItemSlot == $slot[acc1] && res[$slot[acc1]] != $item[none])
		{
			//accessory to slot always returns acc1 and has to be switched if more than one, go from 1 to 3 because that is the equip order the maximizer will use
			if(res[$slot[acc2]] != $item[none])
			{
				overrideSlot = $slot[acc3];
			}
			else
			{
				overrideSlot = $slot[acc2];
			}
		}
		if(overrideSlot != $slot[none])
		{
			maximizerItemSlot = overrideSlot;
		}
		if(res[maximizerItemSlot] != $item[none])
		{
			auto_log_debug("Duplicate entry skipped for slot " + maximizerItemSlot.to_string() + " in speculatedMaximizerEquipment, something must be wrong", "gold");
			continue;
		}
		res[maximizerItemSlot] = maximizerItem;
	}
	return res;
}

void equipStatgainIncreasers(boolean[stat] increaseThisStat, boolean alwaysEquip)
{
	//want to equip best equipment that increases specified stat gains including out of combat
	//should be frequently called by consume actions so try not to lose HP or MP, but will equip anyway if argument alwaysEquip is true
	string maximizerStatement;
	foreach st in increaseThisStat
	{
		if(!increaseThisStat[st])	continue;
		string statWeight = "";
		if(st == my_primestat())
		{
			if(disregardInstantKarma())
			{
				statWeight = "2";
			}
		}
		else if(my_basestat(my_primestat()) > 122 && my_basestat(st) < 70)
		{
			//>= level 12 or almost there, more offstat experience may be needed for the war outfit (requires 70 mox and 70 mys)
			if(st == $stat[mysticality] || st == $stat[moxie])
			{
				statWeight = "3";
			}
		}
		maximizerStatement += statWeight + st.to_string() + " experience percent,";
	}
	item [slot] simulatedEquipment = speculatedMaximizerEquipment(maximizerStatement);	//simulate and get list of relevant equipment
	boolean canIncreaseStatgains = false;
	foreach st in increaseThisStat
	{
		if(!increaseThisStat[st])	continue;
		string modifierString = st.to_string() + " experience percent";
		if(simValue(modifierString) > numeric_modifier(modifierString))
		{
			canIncreaseStatgains = true;
			break;
		}
	}
	if(!canIncreaseStatgains)
	{
		return;
	}
	
	//list only the maximized equipment that increases statgain
	item [slot] statgainIncreasers;
	foreach sl in simulatedEquipment
	{
		foreach st in increaseThisStat
		{
			if(!increaseThisStat[st])	continue;
			if(numeric_modifier(simulatedEquipment[sl],st.to_string() + " experience percent") != 0)
			{
				statgainIncreasers[sl] = simulatedEquipment[sl];
				break;
			}
		}
	}
	
	//equipment would be equipped in the order it was listed. check if HP or MP would be lost by equipping
	int HPlost;	int mostHPlost;
	int MPlost;	int mostMPlost;
	string speculateOneItem;
	string speculateAllItems;
	foreach sl in statgainIncreasers
	{
		speculateOneItem = "equip " + sl.to_string() + " " + statgainIncreasers[sl].to_string() + "; ";
		cli_execute("speculate quiet; " + speculateOneItem);
		HPlost = my_hp() - simValue("Buffed HP Maximum");
		MPlost = my_mp() - simValue("Buffed MP Maximum");
		if(HPlost <= 0 && MPlost <= 0)
		{	equip(statgainIncreasers[sl],sl);	//causes no loss so it can be equipped right now
			continue;
		}
		speculateAllItems += speculateOneItem;	//otherwise speculate with all items that have been left out
		if(speculateAllItems != speculateOneItem)
		{
			cli_execute("speculate quiet; " + speculateAllItems);
			HPlost = my_hp() - simValue("Buffed HP Maximum");
			MPlost = my_mp() - simValue("Buffed MP Maximum");
		}
		if(HPlost > mostHPlost)	mostHPlost = HPlost;
		if(MPlost > mostMPlost)	mostMPlost = MPlost;
	}
	if(mostHPlost == 0 && mostMPlost == 0)
	{
		auto_log_debug("Done increasing incoming stat gains using equipment", "gold");
		return;
	}

	//else try to prevent the HP or MP loss by increasing max HP and MP first using remaining slots
	int targetedHP = my_hp()+mostHPlost;
	int targetedMP = my_mp()+mostMPlost;
	maximizerStatement = "HP " + targetedHP + "min " + targetedHP + "max, MP " + targetedMP + "min " + targetedMP + "max,";
	foreach sl in statgainIncreasers
	{
		maximizerStatement += "-" + sl.to_string() + ",";	//ignore slots where statgain increasers should be equipped
		if(statgainIncreasers[sl].to_slot() == $slot[weapon])	//ignore slots that will be incompatible
		{
			if(weapon_hands(statgainIncreasers[sl]) > 1)		maximizerStatement += "-off-hand,";
			if(weapon_type(statgainIncreasers[sl]) == $stat[moxie])	maximizerStatement += "-melee,";
			else							maximizerStatement += "+melee,";
		}
		if(sl == $slot[off-hand] && statgainIncreasers[$slot[weapon]] == $item[none])
		{
			maximizerStatement += "1handed,";		//ignore incompatible weapons
		}
	}
	if(!maximize(maximizerStatement,true))
	{
		if(!alwaysEquip)
		{	//can't do it, give up
			return;
		}
	}
	auto_log_info("Trying to put on some more equipment first to avoid losing HP or MP before equipping to increase incoming statgains", "blue");
	clear(simulatedEquipment);
	simulatedEquipment = speculatedMaximizerEquipment(maximizerStatement);
	foreach sl in simulatedEquipment
	{
		speculateOneItem = "equip " + sl.to_string() + " " + simulatedEquipment[sl].to_string() + "; ";
		cli_execute("speculate quiet; " + speculateOneItem);
		if(simValue("Buffed HP Maximum") < my_hp())	continue;	//skip on collateral loss
		if(simValue("Buffed MP Maximum") < my_mp())	continue;
		equip(simulatedEquipment[sl],sl);
	}
	boolean doEquips;
	if(my_maxhp() >= targetedHP && my_maxmp() >= targetedMP)
	{
		//finished raising max HP and MP so can now equip all statgain equipment hopefully with no HP or MP loss
		doEquips = true;
	}
	else if(alwaysEquip)
	{
		catch cli_execute("burn " + (targetedMP - my_maxmp()));
		doEquips = true;
	}
	
	if(doEquips)
	{
		foreach sl in statgainIncreasers
		{
			equip(statgainIncreasers[sl],sl);
		}
	}
}

void equipStatgainIncreasers(stat increaseThisStat, boolean alwaysEquip)
{
	boolean[stat] increaseThisStatAggregate;
	increaseThisStatAggregate[increaseThisStat] = true;
	equipStatgainIncreasers(increaseThisStatAggregate, alwaysEquip);
}

void equipStatgainIncreasers()
{
	if(!disregardInstantKarma())	//exclude primestat if level 13
	{
		if(my_primestat() == $stat[muscle])
		{
			equipStatgainIncreasers($stats[mysticality,moxie],false);
			return;
		}
		else if(my_primestat() == $stat[mysticality])
		{
			equipStatgainIncreasers($stats[muscle,moxie],false);
			return;
		}
		else if(my_primestat() == $stat[moxie])
		{
			equipStatgainIncreasers($stats[muscle,mysticality],false);
			return;
		}
	}
	equipStatgainIncreasers($stats[muscle,mysticality,moxie],false);
}

void equipStatgainIncreasersFor(item it)
{
	//check what stats a consumable will give and equip increasers for it
	boolean [stat] increaseThisStat;
	stat excludedStat = disregardInstantKarma() ? $stat[none] : my_primestat();	//exclude primestat if level 13
	if(it.muscle != "" && excludedStat != $stat[muscle])			increaseThisStat[$stat[muscle]] = true;
	if(it.mysticality != "" && excludedStat != $stat[mysticality])		increaseThisStat[$stat[mysticality]] = true;
	if(it.moxie != "" && excludedStat != $stat[moxie])			increaseThisStat[$stat[moxie]] = true;

	if(count(increaseThisStat) != 0)
	{
		equipStatgainIncreasers(increaseThisStat,false);
	}
}

string defaultMaximizeStatement()
{
	if(in_pokefam())
	{
		return pokefam_defaultMaximizeStatement();
	}
	if(in_robot())
	{
		return robot_defaultMaximizeStatement();
	}
	
	string res = "5item,meat,0.5initiative,0.1da 1000max,dr,0.5all res,1.5mainstat,-fumble";
	if(my_primestat() != $stat[Moxie])
	{
		res += ",mox";
	}

	if(in_darkGyffte())
	{
		res += ",0.8hp,3hp regen";
	}
	else
	{
		res += ",0.4hp,0.2mp 1000max";
		res += isActuallyEd() ? ",6mp regen" : ",3mp regen";
	}

	//weapon handling
	if(is_boris())
	{
		borisTrusty();						//forceequip trusty. the modification it makes to the maximizer string will be lost so also do next line
		res +=	",-weapon,-offhand";		//we do not want maximizer trying to touch weapon or offhand slot in boris
	}
	else if(!in_plumber())
	{
		if(my_primestat() == $stat[Mysticality])
		{
			res += ",0.25spell damage,1.75spell damage percent";
		}
		else
		{
			res += ",1.5weapon damage,0.75weapon damage percent,1.5elemental damage";
		}
	}

	if(pathHasFamiliar())
	{
		res += ",2familiar weight";
		if(my_familiar().familiar_weight() < 20)
		{
			res += ",5familiar exp";
		}
	}
	if(in_wildfire())
	{
		res += ",water,hot res";
	}
	if(in_plumber())
	{
		res += ",plumber,-ml";
	}
	else if((my_level() < 13) || (get_property("auto_disregardInstantKarma").to_boolean()))
	{
		res += ",10exp,5" + my_primestat() + " experience percent";
	}

	return res;
}

void resetMaximize()
{
	string res = get_property("auto_maximize_baseline");	//user configured override baseline statement.
	if (res == "" || res.to_lower_case() == "default" || res.to_lower_case() == "disabled")
	{
		res = defaultMaximizeStatement();		//automatically generated baseline statement
	}
	
	void exclude(item it)
	{
		if(res != "")
		{
			res += ",";
		}
		res += "-equip " + it;
	}
	
	// don't want to equip these items automatically
	// snow suit bonus drops every 5 combats so is best saved for important things
	// sword, and staph are text scramblers which cause errors in mafia tracking
	// bathysphere gives -20 lbs familiar weight. under certain circumstances maximizer decides to equip it
	foreach it in $items[sword behind inappropriate prepositions, staph of homophones, snow suit, little bitty bathysphere]
	{
		if (possessEquipment(it))
		{
			exclude(it);
		}
	}
	//IOTM [january's garbage tote] specific handling.
	if(isjanuaryToteAvailable())
	{
		//preserve leftover charges, prevent mafia halting automation for confirmation.
		if(!get_property("_garbageItemChanged").to_boolean())	//did not change tote item today
		{
			foreach it in $items[Deceased Crimbo Tree, Broken Champagne Bottle, Tinsel Tights, Wad Of Used Tape, Makeshift Garbage Shirt]
			{
				exclude(it);
			}
		}
		//preserve current charges
		else foreach it in $items[Deceased Crimbo Tree, Broken Champagne Bottle, Makeshift Garbage Shirt]
		{
			if(januaryToteTurnsLeft(it) > 0)
			{
				exclude(it);
			}
		}
	}
	else if (item_amount($item[January\'s Garbage Tote]) > 0 && in_bhy())
	{
		// workaround mafia bug with the maximizer where it tries to equip tote items even though the tote is unusable
		foreach it in $items[Deceased Crimbo Tree, Broken Champagne Bottle, Tinsel Tights, Wad Of Used Tape, Makeshift Garbage Shirt]
		{
			exclude(it);
		}
	}
	
	set_property("auto_maximize_current", res);
	auto_log_debug("Resetting auto_maximize_current to " + res, "gold");

	foreach s in $slots[hat, back, shirt, weapon, off-hand, pants, acc1, acc2, acc3, familiar]
	{
		set_property(getMaximizeSlotPref(s), "");
	}
}

void addBonusToMaximize(item it, int amt)
{
	if(possessEquipment(it) && auto_can_equip(it))
		addToMaximize("+" + amt + "bonus " + it);
}

void finalizeMaximize(boolean speculative)
{
	if (possessEquipment($item[miniature crystal ball]))
	{
		// until we add support for this, we shouldn't allow the maximizer to equip it
		// I noticed it being worn in preference to the astral pet sweater which is a waste
		addToMaximize(`-equip {$item[miniature crystal ball].to_string()}`);
	}

	if (auto_haveKramcoSausageOMatic())
	{
		// Save the first 8 sausage goblins for delay burning
		boolean saveGoblinForDelay = (auto_sausageFightsToday() < 8 && solveDelayZone() != $location[none]);
		// don't interfere with backups unless they're equivalent or worse
		boolean dontSausageBackups = auto_backupTarget() && !($monsters[sausage goblin,eldritch tentacle] contains get_property("lastCopyableMonster").to_monster());
		// also don't equip Kramco when using Map the Monsters as sausage goblins override the NC
		if (saveGoblinForDelay || dontSausageBackups || get_property("mappingMonsters").to_boolean())
		{
			addToMaximize("-equip " + $item[Kramco Sausage-o-Matic&trade;].to_string());
		}
	}
	if (possessEquipment($item[Cursed Magnifying Glass]))
	{
		if (get_property("cursedMagnifyingGlassCount").to_int() == 13)
		{
			if(get_property("mappingMonsters").to_boolean() || auto_backupTarget() || (get_property("_voidFreeFights").to_int() >= 5 && !in_hardcore()))
			{
				// don't equip for non free fights in softcore? (pending allowed conditions like delay zone && none of the monsters in the zone is a sniff/YR target?)
				// don't interfere with backups or Map the Monsters
				addToMaximize("-equip " + $item[Cursed Magnifying Glass].to_string());
			}
			else if(get_property("_voidFreeFights").to_int() < 5)
			{
				// add bonus if next fight is a free void monster
				addBonusToMaximize($item[Cursed Magnifying Glass], 1000);
			}
		}
		else if(get_property("_voidFreeFights").to_int() < 5 && solveDelayZone() != $location[none])
		{
			// add bonus to charge free fights
			addBonusToMaximize($item[Cursed Magnifying Glass], 200);
		}
	}
	foreach s in $slots[hat, back, shirt, weapon, off-hand, pants, acc1, acc2, acc3, familiar]
	{
		string pref = getMaximizeSlotPref(s);
		string toEquip = get_property(pref);
		if(toEquip != "")
		{
			removeFromMaximize("-equip " + toEquip);
			addToMaximize("+equip " + toEquip);
		}
	}
	if(auto_wantToEquipPowerfulGlove())
	{
		addBonusToMaximize($item[Powerful Glove], 1000); // pixels
	}
	// Vampyre autogenerates scraps because of some weird ensorcel interaction. Even without ensorcel active.
	if(pathHasFamiliar() || in_darkGyffte())
	{
		addBonusToMaximize($item[familiar scrapbook], 200); // scrap generation for banish/exp
	}
	addBonusToMaximize($item[mafia thumb ring], 200); // 4% chance +1 adventure
	if(possessEquipment($item[carnivorous potted plant]))
	{
		if(get_property("mappingMonsters").to_boolean() || auto_backupTarget())
		{
			// don't interfere with backups or Map the Monsters
			// should also block equipping if support is added for Feel Nostalgic, Lecture on relativity, or fax for YR or other special combat actions
			addToMaximize("-equip " + $item[carnivorous potted plant].to_string());
		}
		else if(get_property("auto_MLSafetyLimit") == "" || get_property("auto_MLSafetyLimit").to_int() >= 25)
		{
			addBonusToMaximize($item[carnivorous potted plant], 200); // 4% chance free kill but also 25 ML
		}
	}
	addBonusToMaximize($item[Mr. Screege\'s spectacles], 100); // meat stuff
	addBonusToMaximize($item[can of mixed everything], 100); // random stuff
	if(have_effect($effect[blood bubble]) == 0)
	{
		// blocks first hit, but doesn't stack with blood bubble
		addBonusToMaximize($item[Eight Days a Week Pill Keeper], 100);
	}
	if(!in_plumber() && get_property(getMaximizeSlotPref($slot[weapon])) == "" && !maximizeContains("-weapon") && my_primestat() != $stat[Mysticality])
	{
		if (my_class() == $class[Seal Clubber] && in_glover())
		{
			addToMaximize("club");
		}
		else
		{
			addToMaximize("effective");
		}
	}
}
		 
void finalizeMaximize()
{
	finalizeMaximize(false);
}

void addToMaximize(string add)
{
	if(maximizeContains(add))	//skip if trying to add duplicate
	{
		auto_log_debug('Tried to add a duplicate of "' + add + '" to current maximizer statement... skipping', "gold");
		return;
	}
	auto_log_debug('Adding "' + add + '" to current maximizer statement', "gold");
	string res = get_property("auto_maximize_current");
	boolean addHasComma = add.starts_with(",");
	if(res != "" && !addHasComma)
	{
		res += ",";
	}
	else if(res == "" && addHasComma)
	{
		// maximizer fails on a leading comma
		add = add.substring(1);
	}
	res += add;
	set_property("auto_maximize_current", res);
}

void removeFromMaximize(string rem)
{
	auto_log_debug('Removing "' + rem + '" from current maximizer statement', "gold");
	string res = get_property("auto_maximize_current");
	res = res.replace_string(rem, "");
	// let's be safe here
	res = res.replace_string(" ,", ",");
	res = res.replace_string(", ", ",");
	res = res.replace_string(",,", ",");
	if(res.ends_with(","))
	{
		res = res.substring(0, res.length() - 1);
	}
	if(res.starts_with(","))
	{
		res = res.substring(1);
	}
	set_property("auto_maximize_current", res);
}

boolean maximizeContains(string check)
{
	return get_property("auto_maximize_current").contains_text(check);
}

boolean simMaximize()
{
	string backup = get_property("auto_maximize_current");
	finalizeMaximize(true);
	boolean res = autoMaximize(get_property("auto_maximize_current"), true);
	set_property("auto_maximize_current", backup);
	return res;
}

boolean simMaximize(location loc)
{
	boolean res;
	if (my_location() != loc)
	{
		//set the simulated location while maximizing
		location locCache = my_location();
		set_location(loc);
		res = simMaximize();
		set_location(locCache);
	}
	else
	{
		res = simMaximize();
	}
	return res;
}

boolean simMaximizeWith(location loc, string add)
{
	string backup = get_property("auto_maximize_current");
	addToMaximize(add);
	auto_log_debug("Simulating: " + get_property("auto_maximize_current"), "gold");
	boolean res = simMaximize(loc);
	set_property("auto_maximize_current", backup);
	return res;
}

boolean simMaximizeWith(string add)
{
	return simMaximizeWith(my_location(), add);
}

float simValue(string modifier)
{
	return numeric_modifier("Generated:_spec", modifier);
}

void equipMaximizedGear()
{
	finalizeMaximize();
	maximize(get_property("auto_maximize_current"), 2500, 0, false);
}

void equipOverrides()
{
	foreach slot_str in $strings[hat, back, shirt, weapon, off-hand, pants, acc]
	{
		string overrides = get_property("auto_equipment_override_" + slot_str);
		if(overrides == "")
		{
			continue;
		}

		slot s;
		if(slot_str == "acc")
		{
			s = $slot[acc3];
		}
		else
		{
			s = slot_str.to_slot();
		}

		string [int] overrides_split = overrides.split_string(";");
		foreach i,item_str in overrides_split
		{
			item it = item_str.to_item();
			if(it == $item[none])
			{
				auto_log_warning('"' + item_str + '" does not properly convert to an item (found in auto_equipment_override_' + slot_str + ')', "red");
				continue;
			}
			if(autoEquip(s, it))
			{
				// if equipping to accessories, now move on to the next slot
				// otherwise, stop equipping, since items are listed from highest
				// to lowest priority
				// Run from acc3 to acc1, since maximizer prioritises the other way.
				if(s == $slot[acc3])
				{
					s = $slot[acc2];
				}
				else if(s == $slot[acc2])
				{
					s = $slot[acc1];
				}
				else
				{
					break;
				}
			}
		}
	}
}

int equipmentAmount(item equipment)
{
	if(equipment == $item[none])
	{
		return 0;
	}

	int amount = item_amount(equipment) + equipped_amount(equipment);

	if (get_related($item[broken champagne bottle], "fold") contains equipment)
	{
		amount = item_amount($item[January\'s Garbage Tote]);
	}

	if(item_type(equipment) == "familiar equipment")
	{
		foreach fam in $familiars[]
		{
			if(fam != my_familiar() && familiar_equipped_equipment(fam) == equipment)
			{
				amount++;
			}
		}
	}

	return amount;
}

boolean possessEquipment(item equipment)
{
	return equipmentAmount(equipment) > 0;
}

boolean possessUnrestricted(item it)
{
	return possessEquipment(it) && is_unrestricted(it);
}

boolean possessOutfit(string outfitToCheck, boolean checkCanEquip) {
	// have_outfit will report false if you're wearing some of the items
	// it will only report true if you have all in inventory or are wearing the whole thing
	// hence this now exists.
	if (count(outfit_pieces(outfitToCheck)) == 0) {
		auto_log_warning(outfitToCheck + " is not a valid outfit!");
		return false;
	}
	
	foreach key, piece in outfit_pieces(outfitToCheck) {
		if (!possessEquipment(piece))
		{
			return false;
		}
		if(checkCanEquip && !can_equip(piece))
		{
			return false;
		}
	}
	return true;
}

boolean possessOutfit(string outfitToCheck) {
	return possessOutfit(outfitToCheck, false);	
}

void equipBaseline()
{
	equipMaximizedGear();
}

void ensureSealClubs()
{
	cli_execute("acquire 1 seal-clubbing club");
	foreach club in $items[Meat Tenderizer Is Murder, Lead Pipe, Porcelain Police Baton, Stainless STeel Shillelagh, Frozen Seal Spine, Ghast Iron Cleaver, Oversized Pipe, Curmudgel, Elegant Nightstick, Maxwell's Silver Hammer, Red-Hot Poker, Giant Foam Finger, Hilarious Comedy Prop, Infernal Toilet Brush, Mannequin Leg, Gnawed-Up Dog Bone, Severed Flipper, Spiked Femur, Corrupt Club of Corrupt Corruption, Kneecapping Stick, Orcish frat-paddle, Flaming Crutch, Corrupt Club of Corruption, Skeleton Bone, Remaindered Axe, Club of Corruption, Gnollish Flyswatter, Seal-Clubbing Club]
	{
		if(possessEquipment(club))
		{
			autoForceEquip(club);
			return;
		}
	}
}

void equipRollover(boolean silent)
{
	if(in_gnoob())
	{
		return;
	}

	if(auto_have_familiar($familiar[Trick-or-Treating Tot]) && !possessEquipment($item[Li\'l Unicorn Costume]) && (my_meat() > 3000 + npc_price($item[Li\'l Unicorn Costume])) && auto_is_valid($item[Li\'l Unicorn Costume]) && !in_pokefam())
	{
		cli_execute("buy Li'l Unicorn Costume");
	}

	if(!silent)
	{
		auto_log_info("Putting on pajamas...", "blue");
	}

	string to_max = "-tie,adv";
	if(hippy_stone_broken() && my_path() != "Oxygenarian" && get_property("auto_bedtime_pulls_pvp_multi").to_float() > 0)
	{
		to_max += "," +get_property("auto_bedtime_pulls_pvp_multi")+ "fites";
	}
	if(auto_have_familiar($familiar[Trick-or-Treating Tot]))
		to_max += ",switch Trick-or-Treating Tot";
	if(auto_have_familiar($familiar[Left-Hand Man]))
		to_max += ",switch Left-Hand Man";
	if(my_familiar() == $familiar[none] && auto_have_familiar($familiar[Mosquito]))
		to_max += ",switch Mosquito";

	maximize(to_max, false);

	if(!in_hardcore() && !silent)
	{
		auto_log_info("Done putting on jammies, if you pulled anything with a rollover effect you might want to make sure it's equipped before you log out.", "red");
	}
}

boolean auto_forceEquipSword() {
	item swordToEquip = $item[none];
	// use the ebony epee if we have it
	if (possessEquipment($item[ebony epee]))
	{
		swordToEquip = $item[ebony epee];
	}

	if (swordToEquip == $item[none])
	{
		// check for some swords that we might have acquired in run already. Yes machetes are actually swords.
		foreach it in $items[antique machete, black sword, broken sword, cardboard katana, cardboard wakizashi,
		drowsy sword, knob goblin deluxe scimitar, knob goblin scimitar, lupine sword, muculent machete,
		ridiculously huge sword, serpentine sword, vorpal blade, white sword, sweet ninja sword]
		{
			if (possessEquipment(it) && auto_can_equip(it))
			{
				swordToEquip = it;
				break;
			}
		}
	}

	if (swordToEquip == $item[none] && isArmoryAndLeggeryStoreAvailable() && my_meat() > 49)
	{
		// if we still don't have a sword available, buy one for a trivial amount of meat.
		// we must check availability first. retrieve_item does not return false on failure. it aborts on failure.
		if (retrieve_item(1, $item[sweet ninja sword])) // costs 50 meat from the armorer and leggerer
		{
			swordToEquip = $item[sweet ninja sword];
		}
	}
	
	if (swordToEquip == $item[none])	//we do not want to force equip none and then report success.
	{
		return false;
	}

	return autoForceEquip($slot[weapon], swordToEquip);
}

boolean is_watch(item it)
{
	//watches are accessories that conflict with each other. you can only equip one watch total.
	return $items[dead guy's memento, dead guy's watch, Counterclockwise Watch, glow-in-the-dark wristwatch, grandfather watch, imitation nice watch, wristwatch of the white knight, Crimbolex watch, Sasq&trade; watch] contains it;
}
