script "autoscend/auto_equipment.ash";

void equipBaseline();
void equipRollover();
void ensureSealClubs();
void makeStartingSmiths();
int equipmentAmount(item equipment);

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
// made for Antique Machete, mainly
boolean autoForceEquip(slot s, item it)
{
	if(!possessEquipment(it) || !auto_can_equip(it))
	{
		return false;
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
	return autoForceEquip(it.to_slot(), it);
}

boolean autoOutfit(string toWear)
{
	if(!have_outfit(toWear))
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

boolean tryAddItemToMaximize(slot s, item it)
{
	if(!($slots[hat, back, shirt, weapon, off-hand, pants, acc1, acc2, acc3, familiar] contains s))
	{
		auto_log_error("But " + s + " is an invalid equip slot... What?", "red");
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

string defaultMaximizeStatement()
{
	string res = "5item,meat";

	// combat is completely different in pokefam, so most stuff doesn't matter there
	if(auto_my_path() != "Pocket Familiars")
	{
		res += ",0.5initiative,0.1da 1000max,dr,0.5all res,1.5mainstat,mox,-fumble";
		if(my_class() == $class[Vampyre])
		{
			res += ",0.8hp,3hp regen";
		}
		else
		{
			res += ",0.4hp,0.2mp 1000max";
			res += isActuallyEd() ? ",6mp regen" : ",3mp regen";
		}

		if(!in_zelda())
		{
			if(my_primestat() == $stat[Mysticality])
			{
				res += ",0.25spell damage,1.75spell damage percent";
			}
			else
			{
				res += ",1.5weapon damage,-0.75weapon damage percent,1.5elemental damage";
			}
		}

		if(auto_have_familiar($familiar[mosquito]))
		{
			res += ",2familiar weight";
			if(my_familiar().familiar_weight() < 20)
			{
				res += ",5familiar exp";
			}
		}
		if (in_zelda())
		{
			res += ",-ml";
		}
	}

	if(!in_zelda() && ((my_level() < 13) || (get_property("auto_disregardInstantKarma").to_boolean())))
	{
		res += ",10exp,5" + my_primestat() + " experience percent";
	}

	return res;
}

void resetMaximize()
{
	string res = get_property("auto_maximize_baseline");
	if (res == "" || res.to_lower_case() == "default" || res.to_lower_case() == "disabled")
	{
		res = defaultMaximizeStatement();
	}
	foreach it in $items[hewn moon-rune spoon, makeshift garbage shirt, broken champagne bottle, snow suit]
	{
		if (possessEquipment(it))
		{
			if(res != "")
			{
				res += ",";
			}
			// don't want to equip these items automatically
			// spoon breaks mafia, and the others have limited charges
			res += "-equip " + it;
		}
	}
	set_property("auto_maximize_current", res);
	auto_log_debug("Resetting auto_maximize_current to " + res, "gold");

	foreach s in $slots[hat, back, shirt, weapon, off-hand, pants, acc1, acc2, acc3, familiar]
	{
		set_property(getMaximizeSlotPref(s), "");
	}
}

void finalizeMaximize()
{
	if(auto_wantToEquipPowerfulGlove())
	{
		auto_forceEquipPowerfulGlove();
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
	if(!in_zelda() && get_property(getMaximizeSlotPref($slot[weapon])) == "" && !maximizeContains("-weapon") && my_primestat() != $stat[Mysticality])
	{
		addToMaximize("effective");
	}
}

void addToMaximize(string add)
{
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
	finalizeMaximize();
	boolean res = autoMaximize(get_property("auto_maximize_current"), true);
	set_property("auto_maximize_current", backup);
	return res;
}

boolean simMaximizeWith(string add)
{
	addToMaximize(add);
	auto_log_debug("Simulating: " + get_property("auto_maximize_current"), "gold");
	boolean res = simMaximize();
	removeFromMaximize(add);
	return res;
}

float simValue(string modifier)
{
	return numeric_modifier("Generated:_spec", modifier);
}

void equipMaximizedGear()
{
	finalizeMaximize();
	auto_log_info("Maximizing: " + get_property("auto_maximize_current"), "blue");
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
			s = $slot[acc1];
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
				if(s == $slot[acc1])
				{
					s = $slot[acc2];
				}
				else if(s == $slot[acc2])
				{
					s = $slot[acc3];
				}
				else
				{
					break;
				}
			}
		}
	}
}

void makeStartingSmiths()
{
	if(!auto_have_skill($skill[Summon Smithsness]))
	{
		return;
	}

	if(item_amount($item[Lump of Brituminous Coal]) == 0)
	{
		if(my_mp() < (3 * mp_cost($skill[Summon Smithsness])))
		{
			auto_log_warning("You don't have enough MP for initialization, it might be ok but probably not.", "red");
		}
		use_skill(3, $skill[Summon Smithsness]);
	}

	if(knoll_available())
	{
		buyUpTo(1, $item[maiden wig]);
	}

	switch(my_class())
	{
	case $class[Seal Clubber]:
		if(!possessEquipment($item[Meat Tenderizer is Murder]))
		{
			autoCraft("smith", 1, $item[lump of Brituminous coal], $item[seal-clubbing club]);
		}
		if(!possessEquipment($item[Vicar\'s Tutu]) && (item_amount($item[Lump of Brituminous Coal]) > 0) && knoll_available())
		{
			buy(1, $item[Frilly Skirt]);
			autoCraft("smith", 1, $item[Lump of Brituminous Coal], $item[Frilly Skirt]);
		}
		break;
	case $class[Turtle Tamer]:
		if(!possessEquipment($item[Work is a Four Letter Sword]))
		{
			buyUpTo(1, $item[Sword Hilt]);
			autoCraft("smith", 1, $item[lump of Brituminous coal], $item[sword hilt]);
		}
		if(!possessEquipment($item[Ouija Board\, Ouija Board]))
		{
			autoCraft("smith", 1, $item[lump of Brituminous coal], $item[turtle totem]);
		}
		break;
	case $class[Sauceror]:
		if(!possessEquipment($item[Saucepanic]))
		{
			autoCraft("smith", 1, $item[lump of Brituminous coal], $item[Saucepan]);
		}
		if(!possessEquipment($item[A Light that Never Goes Out]) && (item_amount($item[Lump of Brituminous Coal]) > 0))
		{
			autoCraft("smith", 1, $item[Lump of Brituminous Coal], $item[Third-hand Lantern]);
		}
		break;
	case $class[Pastamancer]:
		if(!possessEquipment($item[Hand That Rocks the Ladle]))
		{
			autoCraft("smith", 1, $item[lump of Brituminous coal], $item[Pasta Spoon]);
		}
		break;
	case $class[Disco Bandit]:
		if(!possessEquipment($item[Frankly Mr. Shank]))
		{
			autoCraft("smith", 1, $item[lump of Brituminous coal], $item[Disco Ball]);
		}
		break;
	case $class[Accordion Thief]:
		if(!possessEquipment($item[Shakespeare\'s Sister\'s Accordion]))
		{
			autoCraft("smith", 1, $item[lump of Brituminous coal], $item[Stolen Accordion]);
		}
		break;
	}

	if(knoll_available() && !possessEquipment($item[Hairpiece on Fire]) && (item_amount($item[lump of Brituminous Coal]) > 0))
	{
		autoCraft("smith", 1, $item[lump of Brituminous coal], $item[maiden wig]);
	}
	buffMaintain($effect[Merry Smithsness], 0, 1, 10);
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

boolean handleBjornify(familiar fam)
{
	if(in_hardcore())
	{
		return false;
	}

	if((equipped_item($slot[back]) != $item[buddy bjorn]) || (my_bjorned_familiar() == fam))
	{
		return false;
	}

	if(autoForbidFamiliarChange() && (fam == my_familiar()))
	{
		return false;
	}

	if(have_familiar(fam))
	{
		bjornify_familiar(fam);
	}
	else
	{
		if(have_familiar($familiar[El Vibrato Megadrone]))
		{
			bjornify_familiar($familiar[El Vibrato Megadrone]);
		}
		else
		{
			if((my_familiar() != $familiar[Grimstone Golem]) && have_familiar($familiar[Grimstone Golem]))
			{
				bjornify_familiar($familiar[Grimstone Golem]);
			}
			else if(have_familiar($familiar[Adorable Seal Larva]))
			{
				bjornify_familiar($familiar[Adorable Seal Larva]);
			}
			else
			{
				return false;
			}
		}
	}
	if(my_familiar() == $familiar[none])
	{
		if(my_bjorned_familiar() == $familiar[Grimstone Golem])
		{
			handleFamiliar("stat");
		}
		else if(my_bjorned_familiar() == $familiar[Grim Brother])
		{
			handleFamiliar("item");
		}
		else
		{
			handleFamiliar("item");
		}
	}
	return true;
}

void equipBaseline()
{
	if(my_daycount() == 1)
	{
		if(have_familiar($familiar[grimstone golem]))
		{
			if(get_property("_grimFairyTaleDropsCrown").to_int() >= 1)
			{
				handleBjornify($familiar[El Vibrato Megadrone]);
			}
		}
		else
		{
			handleBjornify($familiar[El Vibrato Megadrone]);
		}
	}
	if(my_daycount() == 2)
	{
		handleBjornify($familiar[El Vibrato Megadrone]);
	}

	if(get_property("auto_diceMode").to_boolean())
	{
		autoEquip($slot[acc1], $item[Dice Ring]);
		autoEquip($slot[acc2], $item[Dice Belt Buckle]);
		autoEquip($slot[acc3], $item[Dice Sunglasses]);
		autoEquip($slot[hat], $item[Dice-Print Do-Rag]);
		autoEquip($slot[back], $item[Dice-Shaped Backpack]);
		autoEquip($slot[pants], $item[Dice-Print Pajama Pants]);
		autoEquip($slot[familiar], $item[Kill Screen]);
	}
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

void removeNonCombat()
{
	addToMaximize("-50combat");
}

void removeCombat()
{
	addToMaximize("50combat");
}

void equipRollover()
{
	if(my_class() == $class[Gelatinous Noob])
	{
		return;
	}

	if(auto_have_familiar($familiar[Trick-or-Treating Tot]) && !possessEquipment($item[Li\'l Unicorn Costume]) && (my_meat() > 3000 + npc_price($item[Li\'l Unicorn Costume])) && auto_is_valid($item[Li\'l Unicorn Costume]) && auto_my_path() != "Pocket Familiars")
	{
		cli_execute("buy Li'l Unicorn Costume");
	}

	auto_log_info("Putting on pajamas...", "blue");

	string to_max = "-tie,adv";
	if(hippy_stone_broken())
		to_max += ",0.3fites";
	if(auto_have_familiar($familiar[Trick-or-Treating Tot]))
		to_max += ",switch Trick-or-Treating Tot";

	maximize(to_max, false);

	if(!in_hardcore())
	{
		auto_log_info("Done putting on jammies, if you pulled anything with a rollover effect you might want to make sure it's equipped before you log out.", "red");
	}
}
