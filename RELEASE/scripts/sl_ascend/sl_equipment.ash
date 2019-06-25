script "sl_ascend/sl_equipment.ash";

void equipBaseline();
void equipRollover();
void ensureSealClubs();
void makeStartingSmiths();
void equipBaselineGear();
int equipmentAmount(item equipment);

boolean useMaximizeToEquip()
{
	//return get_property("sl_maximize_baseline") != "";
	return false;
}

void resetMaximize()
{
	string res = get_property("sl_maximize_baseline");
	res += ",-equip hewn moon-rune spoon"; // Breaks mafia
	res += ",-equip garbage shirt"; // Don't want this to come up automatically
	res += ",-equip broken champagne bottle"; // Don't want to use this automatically
	set_property("sl_maximize_current", res);
}

void addToMaximize(string add)
{
	string res = get_property("sl_maximize_current");
	boolean addHasComma = add.substring(0, 1) == ",";
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
	set_property("sl_maximize_current", res);
}

void removeFromMaximize(string rem)
{
	string res = get_property("sl_maximize_current");
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
	set_property("sl_maximize_current", res);
}

boolean simMaximizeWith(string add)
{
	addToMaximize(add);
	boolean res = slMaximize(get_property("sl_maximize_current"), true);
	removeFromMaximize(add);
	return res;
}

void equipMaximizedGear()
{
	if(!useMaximizeToEquip())
	{
		return;
	}

	slMaximize(get_property("sl_maximize_current"), false);
}

void equipBaselineGear()
{
	if(useMaximizeToEquip())
	{
		return;
	}

	string [string,int,string] equipment_text;
	if(!file_to_map("sl_ascend_equipment.txt", equipment_text))
		print("Could not load sl_ascend_equipment.txt. This is bad!", "red");
	item [slot] [int] equipment;
	boolean considerGearOption(string item_str, string slot_str, string conds)
	{
		item it = to_item(item_str);
		if(it == $item[none] && item_str != "none")
			abort('"' + item_str + '" does not properly convert to an item!');

		slot eq_slot = $slot[none];
		if(slot_str == "acc")
			eq_slot = $slot[acc1];
		else
		{
			eq_slot = slot_str.to_slot();
			if(eq_slot == $slot[none])
				abort('"' + eq_slot + '" could not be properly converted to a slot!');
		}
		// might as well make sure we can even equip it before looking at conditions
		if(!sl_can_equip(it, eq_slot))
			return false;
		// also we need to have it for it to be equippable, obviously
		if(equipmentAmount(it) == 0)
			return false;

		string ignore = get_property("sl_ignoreCombat");
		if(get_property("sl_beatenUpCount").to_int() >= 7)
			ignore += "(ml)";
		if(ignore != "")
		{
			if(contains_text(ignore, "(noncombat)") && (numeric_modifier(it, "Combat Rate") < 0))
				return false;
			if(contains_text(ignore, "(combat)") && (numeric_modifier(it, "Combat Rate") > 0))
				return false;
			if(contains_text(ignore, "(ml)") && (numeric_modifier(it, "Monster Level") > 0))
				return false;
			if(contains_text(ignore, "(seal)") && (eq_slot == $slot[weapon]) && (item_type(it) != "club"))
				return false;
		}

		if(!sl_check_conditions(conds))
			return false;
		// The item is approved! In to the list it goes.
		equipment[eq_slot][equipment[eq_slot].count()] = it;
		return true;
	}
	boolean [string] ignore_slots;
	foreach slot_str in $strings[hat, back, shirt, weapon, off-hand, pants, acc]
	{
		string override = get_property("sl_equipment_override_" + slot_str);
		if(override == "")
			continue;
		ignore_slots[slot_str] = true;
		string [int] options = override.split_string(";");
		foreach i,item_str in options
			considerGearOption(item_str, slot_str, "");
	}
	foreach slot_str, pri, item_str, conds in equipment_text
	{
		if(!ignore_slots[slot_str])
			considerGearOption(item_str, slot_str, conds);
	}

	item [slot] gear_to_equip;
	int [item] amount_to_equip;
	slot [int] slots_to_equip;
	foreach sl in $slots[hat, back, shirt, weapon, off-hand, pants, acc1, acc2, acc3]
		slots_to_equip[slots_to_equip.count()] = sl;
	if(my_familiar() != $familiar[none])
		slots_to_equip[slots_to_equip.count()] = $slot[familiar];
	if($classes[Cow Puncher, Beanslinger, Snake Oiler] contains my_class())
		slots_to_equip[slots_to_equip.count()] = $slot[holster];
	foreach _,sl in slots_to_equip
	{
		slot list_slot = ($slots[acc2, acc3] contains sl) ? $slot[acc1] : sl;
		foreach i,it in equipment[list_slot]
		{
			if(it == $item[none]) // for way of the surprising fist only so far...
				break;
			if(amount_to_equip[it] > 0 && it.boolean_modifier("Single Equip"))
				continue;
			if(amount_to_equip[it] >= equipmentAmount(it))
				continue;
			if(sl == $slot[off-hand])
			{
				if(gear_to_equip[$slot[weapon]].weapon_hands() > 1)
					break;
				if(gear_to_equip[$slot[weapon]].weapon_type() == $stat[Moxie] && !($stats[Moxie, none] contains it.weapon_type()))
					continue;
			}

			gear_to_equip[sl] = it;
			amount_to_equip[it]++;
			break;
		}
	}

	foreach _,sl in slots_to_equip
	{
		item to_equip = gear_to_equip[sl];
		equip(sl, to_equip);
	}
}

void makeStartingSmiths()
{
	if(!sl_have_skill($skill[Summon Smithsness]))
	{
		return;
	}

	if(item_amount($item[Lump of Brituminous Coal]) == 0)
	{
		if(my_mp() < (3 * mp_cost($skill[Summon Smithsness])))
		{
			print("You don't have enough MP for initialization, it might be ok but probably not.", "red");
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
			slCraft("smith", 1, $item[lump of Brituminous coal], $item[seal-clubbing club]);
		}
		if(!possessEquipment($item[Vicar\'s Tutu]) && (item_amount($item[Lump of Brituminous Coal]) > 0) && knoll_available())
		{
			buy(1, $item[Frilly Skirt]);
			slCraft("smith", 1, $item[Lump of Brituminous Coal], $item[Frilly Skirt]);
		}
		break;
	case $class[Turtle Tamer]:
		if(!possessEquipment($item[Work is a Four Letter Sword]))
		{
			buyUpTo(1, $item[Sword Hilt]);
			slCraft("smith", 1, $item[lump of Brituminous coal], $item[sword hilt]);
		}
		if(!possessEquipment($item[Ouija Board\, Ouija Board]))
		{
			slCraft("smith", 1, $item[lump of Brituminous coal], $item[turtle totem]);
		}
		break;
	case $class[Sauceror]:
		if(!possessEquipment($item[Saucepanic]))
		{
			slCraft("smith", 1, $item[lump of Brituminous coal], $item[Saucepan]);
		}
		if(!possessEquipment($item[A Light that Never Goes Out]) && (item_amount($item[Lump of Brituminous Coal]) > 0))
		{
			slCraft("smith", 1, $item[Lump of Brituminous Coal], $item[Third-hand Lantern]);
		}
		break;
	case $class[Pastamancer]:
		if(!possessEquipment($item[Hand That Rocks the Ladle]))
		{
			slCraft("smith", 1, $item[lump of Brituminous coal], $item[Pasta Spoon]);
		}
		break;
	case $class[Disco Bandit]:
		if(!possessEquipment($item[Frankly Mr. Shank]))
		{
			slCraft("smith", 1, $item[lump of Brituminous coal], $item[Disco Ball]);
		}
		break;
	case $class[Accordion Thief]:
		if(!possessEquipment($item[Shakespeare\'s Sister\'s Accordion]))
		{
			slCraft("smith", 1, $item[lump of Brituminous coal], $item[Stolen Accordion]);
		}
		break;
	}

	if(knoll_available() && !possessEquipment($item[Hairpiece on Fire]) && (item_amount($item[lump of Brituminous Coal]) > 0))
	{
		slCraft("smith", 1, $item[lump of Brituminous coal], $item[maiden wig]);
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

	if(is100FamiliarRun() && (fam == my_familiar()))
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
	equipBaselineGear();

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

	if(get_property("sl_diceMode").to_boolean())
	{
		if(item_amount($item[Dice Ring]) > 0)
		{
			equip($slot[acc1], $item[Dice Ring]);
		}
		if(item_amount($item[Dice Belt Buckle]) > 0)
		{
			equip($slot[acc2], $item[Dice Belt Buckle]);
		}
		if(item_amount($item[Dice Sunglasses]) > 0)
		{
			equip($slot[acc3], $item[Dice Sunglasses]);
		}
		if(item_amount($item[Dice-Print Do-Rag]) > 0)
		{
			equip($slot[hat], $item[Dice-Print Do-Rag]);
		}
		if(item_amount($item[Dice-Shaped Backpack]) > 0)
		{
			equip($slot[back], $item[Dice-Shaped Backpack]);
		}
		if(item_amount($item[Dice-Print Pajama Pants]) > 0)
		{
			equip($slot[pants], $item[Dice-Print Pajama Pants]);
		}
		if((item_amount($item[Kill Screen]) > 0) && (my_familiar() != $familiar[none]))
		{
			equip($slot[familiar], $item[Kill Screen]);
		}
	}
}

void ensureSealClubs()
{
	string ignore = get_property("sl_ignoreCombat");
	set_property("sl_ignoreCombat", ignore + "(seal)");
	equipBaseline();
	set_property("sl_ignoreCombat", ignore);
}

void removeNonCombat()
{
	string ignore = get_property("sl_ignoreCombat");
	set_property("sl_ignoreCombat", ignore + "(noncombat)");
	equipBaseline();
	set_property("sl_ignoreCombat", ignore);
}

void removeCombat()
{
	string ignore = get_property("sl_ignoreCombat");
	set_property("sl_ignoreCombat", ignore + "(combat)");
	equipBaseline();
	set_property("sl_ignoreCombat", ignore);
}

void equipRollover()
{
	if(my_class() == $class[Gelatinous Noob])
	{
		return;
	}

	if(sl_have_familiar($familiar[Trick-or-Treating Tot]) && !possessEquipment($item[Li'l Unicorn Costume]) && (my_meat() > 3000 + npc_price($item[Li'l Unicorn Costume])) && sl_is_valid($item[Li'l Unicorn Costume]) && sl_my_path() != "Pocket Familiars")
	{
		cli_execute("buy Li'l Unicorn Costume");
	}

	print("Putting on pajamas...", "blue");

	string to_max = "-tie,adv";
	if(hippy_stone_broken())
		to_max += ",0.3fites";
	if(sl_have_familiar($familiar[Trick-or-Treating Tot]))
		to_max += ",switch Trick-or-Treating Tot";
	
	maximize(to_max, false);

	if(!in_hardcore())
	{
		print("Done putting on jammies, if you pulled anything with a rollover effect you might want to make sure it's equipped before you log out.", "red");
	}
}
