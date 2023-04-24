//A file full of utility functions which we import into autoscend.ash

boolean autoMaximize(string req, boolean simulate)
{
	if(!simulate)
	{
		debugMaximize(req, 0);
		tcrs_maximize_with_items(req);
	}
	return maximize(req, simulate);
}

boolean autoMaximize(string req, int maxPrice, int priceLevel, boolean simulate)
{
	if(!simulate)
	{
		debugMaximize(req, maxPrice);
		tcrs_maximize_with_items(req);
	}
	return maximize(req, maxPrice, priceLevel, simulate);
}

aggregate autoMaximize(string req, int maxPrice, int priceLevel, boolean simulate, boolean includeEquip)
{
	if(!simulate)
	{
		debugMaximize(req, maxPrice);
		tcrs_maximize_with_items(req);
	}
	return maximize(req, maxPrice, priceLevel, simulate, includeEquip);
}

void debugMaximize(string req, int meat)	//This function will be removed.
{
	if(req.index_of("-tie") == -1)
	{
		req = req + " -tie";
		auto_log_debug("Added -tie to maximize", "red");
	}
	auto_log_info("Desired maximize: " + req, "blue");
	string situation = " " + my_class() + " " + my_path().name + " " + my_sign();
	if(in_hardcore())
	{
		situation = "Hardcore" + situation;
	}
	else
	{
		situation = "Softcore" + situation;
	}
	situation += " " + today_to_string() + " " + time_to_string();
	boolean[effect] acquired;
	acquired[$effect[none]] = true;
	string tableDo = "<table border=1><tr><td colspan=3>Accepted: Maximizing: " + req + "</td><td colspan=3>" + situation + "</td></tr>";
	string tableDont = "<table border=1><tr><td colspan=3>Rejected: Maximizing: " + req + "</td><td colspan=3>" + situation + "</td></tr>";
	tableDo += "<tr><td>Score</td><td>Effect</td><td>Command</td><td>Skill</td><td>Item</td><td>Display</td></tr>";
	tableDont += "<tr><td>Score</td><td>Effect</td><td>Command</td><td>Skill</td><td>Item</td><td>Display</td></tr>";

	foreach it, entry in maximize(req, 0, 0, true, true)
	{
		string output = "";

		entry.display = replace_string(entry.display, "<html>", "");
		entry.display = replace_string(entry.display, "</html>", "");

		if(entry.skill != $skill[none])
		{
			output += "Skill(" + entry.skill + ") ";
		}
		if(entry.command != "")
		{
			output += "Command(" + entry.command + ") ";
		}
		string display = "Display(" + entry.display + ") ";
		if(entry.item != $item[none])
		{
			output += "Item(" + entry.item + ") ";
		}
		if(entry.effect != $effect[none])
		{
			output += "Effect(" + entry.effect + ") ";
		}
		output += "Score(" + entry.score + ")";

		boolean doThis = true;
		if(entry.score <= 0)
		{
			doThis = false;
		}
		if(entry.command.index_of("uneffect ") == 0)
		{
			doThis = false;
		}
		if(entry.display.index_of("uneffect ") == 0)
		{
			doThis = false;
		}
		if(entry.display.index_of("<font color=gray>") != -1)
		{
			doThis = false;
		}
		if(entry.skill != $skill[none])
		{
			if(turns_per_cast(entry.skill) <= 0)
			{
				doThis = false;
			}
			if(adv_cost(entry.skill) > 0)
			{
				doThis = false;
			}
			if(lightning_cost(entry.skill) > my_lightning())
			{
				doThis = false;
			}
			if(mp_cost(entry.skill) > my_mp())
			{
				doThis = false;
			}
			if(rain_cost(entry.skill) > my_rain())
			{
				doThis = false;
			}
			if(soulsauce_cost(entry.skill) > my_soulsauce())
			{
				doThis = false;
			}
			if(thunder_cost(entry.skill) > my_thunder())
			{
				doThis = false;
			}
		}
		else
		{
			//If not a skill, is it an item?
			if(entry.item != $item[none])
			{
				if(entry.display.index_of("drink ") == 0)
				{
					doThis = false;
				}
				if(entry.display.index_of("eat ") == 0)
				{
					doThis = false;
				}
				if(entry.display.index_of("play ") == 0)
				{
					doThis = false;
				}
				if(entry.display.index_of("bind ") == 0)
				{
					doThis = false;
				}
				if(entry.display.index_of("cast 1 Bind ") == 0)
				{
					doThis = false;
				}
				if(entry.display.index_of("chew ") == 0)
				{
					doThis = false;
				}
#				if(entry.display.index_of("...or ") == 0)
#				{
#					doThis = false;
#				}

				//Mafia likes to recommend pirate Ephemera that we can not buy.
				if(($items[Pirate Tract, Pirate Pamphlet, Pirate Brochure] contains entry.item) && ((my_ascensions() != get_property("lastPirateEphemeraReset").to_int()) || (entry.item != to_item(get_property("lastPirateEphemera"))) ))
				{
					doThis = false;
				}

				if(entry.display.index_of("make ") == 0)
				{
					//We can this make item.
					doThis = false;
				}
				if(entry.display.index_of("use ") == 0)
				{
					//We have this item
				}
				if(entry.display.index_of("buy ") == 0)
				{
					//We can buy this item
					if(npc_price(entry.item) > meat)
					{
						doThis = false;
					}
				}
			}
			else
			{
				//Not a skill or item, what is it?
				if(entry.display.index_of("telescope ") == 0)
				{}
				else if(entry.display.index_of("grim init ") == 0)
				{}
				else if(entry.display.index_of("unequip ") == 0)
				{}
				else if(entry.display.index_of("familiar ") == 0)
				{}
				else if(entry.display.index_of("bjorn ") == 0)
				{}
				else
				{
					doThis = false;
				}
			}
		}

		if((acquired contains entry.effect) && (entry.effect != $effect[none]))
		{
			dothis = false;
		}
		if((entry.effect != $effect[none]) && (have_effect(entry.effect) > 0))
		{
			doThis = false;
		}

		string curTable = "<td>" + entry.score + "</td>";
		curTable += "<td>" + entry.effect + "</td>";
		curTable += "<td>&nbsp;" + entry.command + "</td>";
		curTable += "<td>" + entry.skill + "</td>";
		curTable += "<td>" + entry.item + "</td>";
		curTable += "<td>&nbsp;" + entry.display + "</td>";

		if(doThis)
		{
			#use_skill(1, entry.skill);
			acquired[entry.effect] = true;
			output = "USE: " + output;
			tableDo += "<tr>" + curTable + "</tr>";
		}
		else
		{
			output = "REJECT: " + output;
			tableDont += "<tr>" + curTable + "</tr>";
		}
		auto_log_info(output, "blue");
		auto_log_info(display, "green");
	}

	tableDo += "</table>";
	tableDont += "</table>";
	print_html(tableDo);
	print_html(tableDont);


	//	A successive print will help make the table readable in cases where it is not rendered properly
	//cli_execute("ashref get_inventory");

}

string trim(string input)
{
	matcher whitespace = create_matcher("(\\A\\s+)|(\\s+\\z)", input);
	return replace_all(whitespace, "");
}


string safeString(string input)
{
	matcher comma = create_matcher("[,]", input);
	input = replace_all(comma, ".");
	matcher colon = create_matcher("[:]", input);
	input = replace_all(colon, ".");
	return input;
}

string safeString(skill input)
{
	return safeString("" + input);
}

string safeString(item input)
{
	return safeString("" + input);
}
string safeString(monster input)
{
	return safeString("" + input);
}

void handleTracker(string used, string tracker)
{
	string cur = get_property(tracker);
	if(cur != "")
	{
		cur = cur + ", ";
	}
	cur = cur + "(" + my_daycount() + ":" + safeString(used) + ":" + my_turncount() + ")";
	set_property(tracker, cur);
}

void handleTracker(string used, string detail, string tracker)
{
	string cur = get_property(tracker);
	if(cur != "")
	{
		cur = cur + ", ";
	}
	cur = cur + "(" + my_daycount() + ":" + safeString(used) + ":" + safeString(detail) + ":" + my_turncount() + ")";
	set_property(tracker, cur);
}

boolean organsFull()
{
	if(my_fullness() < fullness_limit())
	{
		return false;
	}
	if(my_inebriety() < inebriety_limit())
	{
		return false;
	}
	if(my_spleen_use() < spleen_limit())
	{
		return false;
	}
	return true;
}

boolean backupSetting(string setting, string newValue)
{
	string[string,string] defaults;
	file_to_map("data/defaults.txt", defaults);

	int found = 0;
	string oldValue = "";
	foreach domain, name, value in defaults
	{
		if(name == setting)
		{
			found = 1;
			oldValue = get_property(name);
		}
	}

	if(oldValue == "")
	{
		oldValue = "__BLANK__";
	}

	if(found == 1)
	{
		if(get_property(setting) == newValue)
		{
			return false;
		}

		if(get_property("auto_backup_" + setting) == "")
		{
			set_property("auto_backup_" + setting, oldValue);
		}
		set_property(setting, newValue);
		return true;
	}
	set_property(setting, newValue);
	return false;
}

boolean restoreAllSettings()
{
	string[string,string] defaults;
	file_to_map("data/defaults.txt", defaults);

	boolean retval = false;
	foreach domain, name, value in defaults
	{
		retval |= restoreSetting(name);
	}

	return retval;
}

boolean restoreSetting(string setting)
{
	if(get_property("auto_backup_" + setting) != "")
	{
		if(get_property("auto_backup_" + setting) == "__BLANK__")
		{
			set_property(setting, "");
		}
		else
		{
			set_property(setting, get_property("auto_backup_" + setting));
		}
		remove_property("auto_backup_" + setting);
		return true;
	}

	return false;
}

location provideAdvPHPZone()
{
	if(elementalPlanes_access($element[stench]))
	{
		if(($location[Barf Mountain].turns_spent <= 5) && !contains_text($location[Barf Mountain].noncombat_queue, "Welcome to Barf Mountain"))
		{
			return $location[Barf Mountain];
		}
		if(($location[Pirates of the Garbage Barges].turns_spent <= 5) && !contains_text($location[Pirates of the Garbage Barges].noncombat_queue, "Dead Men Smell No Tales"))
		{
			return $location[Pirates of the Garbage Barges];
		}
	}
	if(elementalPlanes_access($element[sleaze]))
	{
		if(($location[Sloppy Seconds Diner].turns_spent <= 5) && !contains_text($location[Sloppy Seconds Diner].noncombat_queue, "Nothing Could Be Finer"))
		{
			return $location[Sloppy Seconds Diner];
		}
		if(($location[The Fun-Guy Mansion].turns_spent <= 5) && !contains_text($location[The Fun-Guy Mansion].noncombat_queue, "A Fungible Fun Experience"))
		{
			return $location[The Fun-Guy Mansion];
		}
	}
	if(elementalPlanes_access($element[spooky]))
	{
		if(($location[The Secret Government Laboratory].turns_spent <= 5) && !contains_text($location[The Secret Government Laboratory].noncombat_queue, "See What's on the Slab"))
		{
			return $location[The Secret Government Laboratory];
		}
		if(($location[The Mansion of Dr. Weirdeaux].turns_spent <= 5) && !contains_text($location[The Mansion of Dr. Weirdeaux].noncombat_queue, "Ready, Set, Geaux!"))
		{
			return $location[The Mansion of Dr. Weirdeaux];
		}
		if(($location[The Deep Dark Jungle].turns_spent <= 5) && !contains_text($location[The Deep Dark Jungle].noncombat_queue, "Fun and Games!"))
		{
			return $location[The Deep Dark Jungle];
		}
	}
	if(elementalPlanes_access($element[cold]))
	{
		if(($location[VYKEA].turns_spent <= 5) && !contains_text($location[VYKEA].noncombat_queue, "Just Some Oak and Some Pine and a Handful of Norsemen"))
		{
			return $location[VYKEA];
		}
		if(($location[The Ice Hotel].turns_spent <= 5) && !contains_text($location[The Ice Hotel].noncombat_queue, "Lending a Hand (and a Foot)"))
		{
			return $location[The Ice Hotel];
		}
	}
	if(elementalPlanes_access($element[hot]))
	{
		if(($location[LavaCo&trade; Lamp Factory].turns_spent <= 5) && !contains_text($location[LavaCo&trade; Lamp Factory].noncombat_queue, "LavaCo&trade; Welcomes You"))
		{
			return $location[LavaCo&trade; Lamp Factory];
		}
		if(($location[The SMOOCH Army HQ].turns_spent <= 5) && !contains_text($location[The SMOOCH Army HQ].noncombat_queue, "An Introductory SMOOCH"))
		{
			return $location[The SMOOCH Army HQ];
		}
		if(($location[The Bubblin\' Caldera].turns_spent <= 5) && !contains_text($location[The Bubblin\' Caldera].noncombat_queue, "Caldera Air"))
		{
			return $location[The Bubblin\' Caldera];
		}
	}
	if(elementalPlanes_access($element[stench]))
	{
		if(($location[Uncle Gator\'s Country Fun-Time Liquid Waste Sluice].turns_spent <= 5) && !contains_text($location[Uncle Gator\'s Country Fun-Time Liquid Waste Sluice].noncombat_queue, "Gator Done"))
		{
			return $location[Uncle Gator\'s Country Fun-Time Liquid Waste Sluice];
		}
	}
	return $location[none];
}

boolean loopHandler(string turnSetting, string counterSetting, string abortMessage, int threshold)
{
	if(my_turncount() == get_property(turnSetting).to_int())
	{
		set_property(counterSetting, get_property(counterSetting).to_int() + 1);
		if(get_property(counterSetting).to_int() > threshold)
		{
			abort(abortMessage);
		}
		return true;
	}
	else
	{
		set_property(turnSetting, my_turncount());
		set_property(counterSetting, 0);
	}
	return false;
}

boolean loopHandler(string turnSetting, string counterSetting, int threshold)
{
	string abortMessage = "Infinite loop possibly detected for setting: " + counterSetting + ". Use up a turn to get us to consider this loop broken. This may be a more severe issue.";
	return loopHandler(turnSetting, counterSetting, abortMessage, threshold);
}

boolean loopHandlerDelay(string counterSetting)
{
	return loopHandlerDelay(counterSetting, 3);
}

boolean loopHandlerDelay(string counterSetting, int threshold)
{
	if(get_property(counterSetting).to_int() >= threshold)
	{
		set_property(counterSetting, get_property(counterSetting).to_int() - 1);
		return true;
	}
	return false;
}

boolean loopHandlerDelayAll()
{
	boolean boo = loopHandlerDelay("_auto_lastABooCycleFix");
	boolean digitize = loopHandlerDelay("_auto_digitizeAssassinCounter");
	return boo || digitize;
}

string reverse(string s)
{
	string ret;
	for(int i=length(s)-1; i>=0; i--)
	{
		ret += char_at(s, i);
	}
	return ret;
}

boolean setAdvPHPFlag()
{
	location toAdv = provideAdvPHPZone();
	if(toAdv == $location[none])
	{
		return false;
	}
	autoAdv(toAdv);
	return true;

}

boolean isOverdueArrow()
{
	if(get_property("_romanticFightsLeft").to_int() == 0)
	{
		return false;
	}
	if(get_counters("Romantic Monster window end", 1, 200) == "Romantic Monster window end")
	{
		return false;
	}
	if(contains_text(get_property("_tempRelayCounters"), "Romantic Monster window end"))
	{
		return false;
	}
	if(get_counters("Romantic Monster window end", 0, 0) == "Romantic Monster window end")
	{
		return true;
	}
	return false;
}

boolean isExpectingArrow()
{
	if(get_property("_romanticFightsLeft").to_int() == 0)
	{
		return false;
	}
	if(get_counters("Romantic Monster window end", 1, 200) == "Romantic Monster window end")
	{
		if(get_counters("Romantic Monster window start", 0, 0) == "Romantic Monster window start")
		{
			return true;
		}
		if(get_counters("Romantic Monster window end", 0, 200) == "")
		{
			return true;
		}

		return false;
	}
	if(contains_text(get_property("_tempRelayCounters"), "Romantic Monster window end"))
	{
		return false;
	}
	if(get_counters("Romantic Monster window end", 0, 0) == "Romantic Monster window end")
	{
		return true;
	}
	return false;
}

int[monster] banishedMonsters()
{
	int[monster] retval;
	string[int] data = split_string(get_property("banishedMonsters"), ":");

	if(get_property("banishedMonsters") == "")
	{
		return retval;
	}

	int i=0;
	while(i<count(data))
	{
		retval[to_monster(data[i])] = to_int(data[i+2]);
		i += 3;
	}

	return retval;
}

boolean isBanished(monster enemy)
{
	return (banishedMonsters() contains enemy);
}

boolean is_avatar_potion(item it)
{
	#From Veracity\'s "avatar potion" post
	#http://kolmafia.us/showthread.php?19302-Add-quot-avatar-potion-quot-as-an-item_type%28%29&p=129243&viewfull=1#post129243
	effect e = effect_modifier(it, "Effect");
	if(e == $effect[none])
	{
		return false;
	}
	string avatar = string_modifier(e, "Avatar");
	return (avatar != "");
}

int autoCraft(string mode, int count, item item1, item item2)
{
	if((mode == "combine") && !knoll_available())
	{
		if(my_meat() < (10 * count))
		{
			auto_log_warning("Count not combine " + item1 + " and " + item2 + " due to lack of meat paste.", "red");
			return 0;
		}
		int need = max(0, count - item_amount($item[Meat Paste]));
		if(need > 0)
		{
			cli_execute("make " + need + " meat paste");
		}
	}
	return craft(mode, count, item1, item2);
}

int internalQuestStatus(string prop)
{
	string status = get_property(prop);
	if(status == "unstarted")
	{
		return -1;
	}
	if(status == "started")
	{
		return 0;
	}
	if(status == "finished")
	{
		//Does not handle quests with over 9998 steps. That\'s the Gnome letter quest, yes?
		return 9999;
	}
	matcher my_element = create_matcher("step(\\d+)", status);
	if(my_element.find())
	{
		return to_int(my_element.group(1));
	}
	return -1;
}

int estimatedTurnsLeft()
{
	//Probably will try bother to try dealing with milk, glorious lunch, ode, at least not now.
	int turns = my_adventures();
	if(can_eat())
	{
		turns += fullness_left() * 4.5;
	}
	if(can_drink())
	{
		turns += inebriety_left() * 4.75;
	}
	if(haveSpleenFamiliar())
	{
		turns += spleen_left() * 1.8;
	}

	return turns;
}

boolean canYellowRay(monster target)
{
	# Use this to determine if it is safe to enter a yellow ray combat.

	if(in_pokefam())
	{	
		return false;
	}

	if(have_effect($effect[Everything Looks Yellow]) <= 0)
	{
		
		// first, do any necessary prep to use a yellow ray
		if(item_amount($item[Clan VIP Lounge Key]) > 0 &&	// Need VIP access
			get_property("_fireworksShop").to_boolean() &&	// in a clan that has the Underground Fireworks Shop
			item_amount($item[yellow rocket]) == 0 &&		// Don't buy if we already have one
			auto_is_valid($item[yellow rocket]) &&			// or if it's not valid
			my_meat() > npc_price($item[yellow rocket]) + meatReserve())
		{
			cli_execute("acquire " + $item[yellow rocket]);
		}

		// parka has 100 turn cooldown, but is a free-kill and has 0 meat cost, so prioritised over yellow rocket
		if(auto_hasParka() && auto_is_valid($skill[Spit jurassic acid]) && hasTorso())
		{
			return yellowRayCombatString(target, false, $monsters[bearpig topiary animal, elephant (meatcar?) topiary animal, spider (duck?) topiary animal, Knight (Snake)] contains target) != "";
		}

		// Yellow rocket has the lowest cooldown, and is unlimited, so prioritize over other sources
		if (item_amount($item[yellow rocket]) > 0 &&
			auto_is_valid($item[yellow rocket]) &&
			yellowRayCombatString(target, false, $monsters[bearpig topiary animal, elephant (meatcar?) topiary animal, spider (duck?) topiary animal, Knight (Snake)] contains target) != "")
		{
			return true;
		}

		if(auto_hasRetrocape())
		{
			return yellowRayCombatString(target, false, $monsters[bearpig topiary animal, elephant (meatcar?) topiary animal, spider (duck?) topiary animal, Knight (Snake)] contains target) != "";
		}

		if(canChangeToFamiliar($familiar[Crimbo Shrub]))
		{
			if(item_amount($item[box of old Crimbo decorations]) == 0)
			{
				familiar curr = my_familiar();
				use_familiar($familiar[Crimbo Shrub]);
				use_familiar(curr);
			}
			if(get_property("shrubGifts") != "yellow" && !get_property("_shrubDecorated").to_boolean())
			{
				string temp = visit_url("inv_use.php?pwd=&which=3&whichitem=7958");
				temp = visit_url("choice.php?pwd=&whichchoice=999&option=1&topper=1&lights=1&garland=1&gift=1");
			}
		}

		if(!get_property("_internetViralVideoBought").to_boolean() &&	//can only buy 1 per day
			(item_amount($item[BACON]) >= 20) &&	//it costs 20 bacon
			auto_is_valid($item[Viral Video]) &&	//do not bother buying it if it is not valid
			!in_koe())	//bacon store is unreachable in kingdom of exploathing
		{
			create(1, $item[Viral Video]);
		}
	}
	# Pulled Yellow Taffy	- How do we handle the underwater check?
	# He-Boulder?			- How do we do this?
	return yellowRayCombatString(target, false, $monsters[bearpig topiary animal, elephant (meatcar?) topiary animal, spider (duck?) topiary animal, Knight (Snake)] contains target) != "";
}

boolean canYellowRay()
{
	return canYellowRay($monster[none]);
}

boolean[string] auto_banishesUsedAt(location loc)
{
	boolean[string] auto_reallyBanishesUsedAt(location loc)
	{
		string banished = get_property("banishedMonsters");
		string[int] banishList = split_string(banished, ":");
		monster[int] atLoc = get_monsters(loc);
		boolean[string] used;

		for(int i=0; (i+1)<count(banishList); i = i + 3)
		{
			monster curMon = to_monster(banishList[i]);
			string curUsed = banishList[i+1];

			for(int j=0; j<count(atLoc); j++)
			{
				if(atLoc[j] == curMon)
				{
					used[curUsed] = true;
				}
			}
		}
		return used;
	}
	
	if($locations[Next To That Barrel With Something Burning In It, Out By That Rusted-Out Car, Over Where The Old Tires Are, Near an Abandoned Refrigerator] contains loc)
	{
		boolean[string] gremlinBanishes;
		foreach l in $locations[Next To That Barrel With Something Burning In It, Out By That Rusted-Out Car, Over Where The Old Tires Are, Near an Abandoned Refrigerator]
		{
			boolean[string] used = auto_reallyBanishesUsedAt(l);
			foreach s in used
			{
				gremlinBanishes[s] = true;
			}
		}
		return gremlinBanishes;
	}
	return auto_reallyBanishesUsedAt(loc);
}

boolean auto_wantToBanish(monster enemy, location loc)
{
	if(appearance_rates(loc,true)[enemy] <= 0)
	{
		return false;
	}
	location locCache = my_location();
	set_location(loc);
	boolean [monster] monstersToBanish = auto_getMonsters("banish");
	set_location(locCache);
	return monstersToBanish[enemy];
}

boolean canBanish(monster enemy, location loc)
{
	return banisherCombatString(enemy, loc) != "";
}

boolean adjustForBanish(string combat_string)
{
	if(combat_string == "skill " + $skill[Throw Latte on Opponent])
	{
		return autoEquip($item[latte lovers member\'s mug]);
	}
	if(combat_string == "skill " + $skill[Give Your Opponent The Stinkeye])
	{
		return autoEquip($item[stinky cheese eye]);
	}
	if(combat_string == "skill " + $skill[Creepy Grin])
	{
		return autoEquip($item[V for Vivala mask]);
	}
	if(combat_string == "skill " + $skill[Show Them Your Ring])
	{
		return autoEquip($item[Mafia middle finger ring]);
	}
	if(combat_string == "skill " + $skill[Batter Up!])
	{
		cli_execute("acquire 1 seal-clubbing club");
		ensureSealClubs();
		return true;
	}
	if(combat_string == "skill " + $skill[Talk About Politics])
	{
		return autoEquip($item[Pantsgiving]);
	}
	if(combat_string == "skill " + $skill[Reflex Hammer])
	{
		return autoEquip($item[Lil\' Doctor&trade; bag]);
	}
	if(combat_string == "skill " + $skill[Show Your Boring Familiar Pictures])
	{
		return autoEquip($item[familiar scrapbook]);
	}
	if(combat_string == ("skill " + $skill[Use the Force]))
	{
		return autoEquip($slot[weapon], $item[Fourth of May cosplay saber]);
	}
	if(combat_string == "skill " + $skill[KGB Tranquilizer Dart])
	{
		return autoEquip($item[Kremlin\'s Greatest Briefcase]);
	}
	if(combat_string == "skill " + $skill[Beancannon])
	{
		foreach beancan in $items[Frigid Northern Beans, Heimz Fortified Kidney Beans, Hellfire Spicy Beans, Mixed Garbanzos and Chickpeas, Pork 'n' Pork 'n' Pork 'n' Beans, Shrub's Premium Baked Beans, Tesla's Electroplated Beans, Trader Olaf's Exotic Stinkbeans, World's Blackest-Eyed Peas]
		{
			if(autoEquip(beancan))
			{
				return true;
			}
		}
		return false;
	}
	return true;
}

boolean adjustForBanishIfPossible(monster enemy, location loc)
{
	if(canBanish(enemy, loc))
	{
		string banish_string = banisherCombatString(enemy, loc);
		auto_log_info("Adjusting to have banisher available for " + enemy + ": " + banish_string, "blue");
		return adjustForBanish(banish_string);
	}
	return false;
}

boolean adjustForYellowRay(string combat_string)
{
	//Adjust equipment/familiars to have access to the desired Yellow Ray
	if(combat_string == ("skill " + $skill[Open a Big Yellow Present]))
	{
		handleFamiliar("yellowray");
		return true;
	}
	if(combat_string == ("skill " + $skill[Use the Force]))
	{
		return autoEquip($slot[weapon], $item[Fourth of May cosplay saber]);
	}
	if(combat_string == ("skill " + $skill[Spit jurassic acid]))
	{
		auto_configureParka("acid");
	}
	if(combat_string == ("skill " + $skill[Unleash the Devil's Kiss]))
	{
		auto_configureRetrocape("heck", "kiss");
	}
	// craft and consume 9-volt battery if we are using shocking lick and don't have any charges already
	if(combat_string == ("skill " + $skill[Shocking Lick]) && get_property("shockingLickCharges").to_int() < 1)
	{
		if(auto_getBattery($item[battery (9-Volt)]))
		{
			use(1, $item[battery (9-Volt)]);		
		}
		else
		{
			auto_log_error("Failed to prepare a yellow ray. yellowRayCombatString thinks we can craft a 9-volt battery but we actually could not");
		}
	}
	return true;
}

boolean adjustForYellowRayIfPossible(monster target)
{
	if(canYellowRay(target))
	{
		string yr_string = yellowRayCombatString(target, false, $monsters[bearpig topiary animal, elephant (meatcar?) topiary animal, spider (duck?) topiary animal, Knight (Snake)] contains target);
		auto_log_info("Adjusting to have YR available for " + target + ": " + yr_string, "blue");
		return adjustForYellowRay(yr_string);
	}
	return false;
}

boolean adjustForYellowRayIfPossible()
{
	return adjustForYellowRayIfPossible($monster[none]);
}

boolean canReplace(monster target)
{
	//Use this to determine if it is safe to enter a replace monster combat.
	return replaceMonsterCombatString(target) != "";
}

boolean canReplace()
{
	return canReplace($monster[none]);
}

boolean adjustForReplace(string combat_string)
{
	//Adjust equipment/familiars to have access to the desired replace monster
	if(combat_string == ("skill " + $skill[Macrometeorite]))
	{
		return true;
	}
	if(combat_string == ("skill " + $skill[CHEAT CODE: Replace Enemy]))
	{
		return auto_forceEquipPowerfulGlove();
	}
	return false;
}

boolean adjustForReplaceIfPossible(monster target)
{
	if(canReplace(target))
	{
		string rep_string = replaceMonsterCombatString(target);
		auto_log_info("Adjusting to have replace available for " + target + ": " + rep_string, "blue");
		return adjustForReplace(rep_string);
	}
	return false;
}

boolean adjustForReplaceIfPossible()
{
	return adjustForReplaceIfPossible($monster[none]);
}

boolean canSniff(monster enemy, location loc)
{
	if(!auto_wantToSniff(enemy, loc))
	{
		return false;
	}
	return getSniffer(enemy, false) != $skill[none];
}

boolean adjustForSniffingIfPossible(monster target)
{
	skill sniffer = getSniffer(target, false);
	if(sniffer != $skill[none])
	{
		return acquireMP(sniffer.mp_cost());
	}
	return false;
}

boolean adjustForSniffingIfPossible()
{
	return adjustForSniffingIfPossible($monster[none]);
}

string statCard()
{
	switch(my_primestat())
	{
	case $stat[Muscle]:
		return "68";
	case $stat[Mysticality]:
		return "70";
	case $stat[Moxie]:
		return "69";
	}
	return "";
}

boolean hasTorso()
{
	return have_skill($skill[Torso Awareness]) || have_skill($skill[Best Dressed]) || robot_cpu(9,false);
}

boolean isGuildClass()
{
	return ($classes[Seal Clubber, Turtle Tamer, Sauceror, Pastamancer, Disco Bandit, Accordion Thief] contains my_class());
}

float elemental_resist_value(int resistance)
{
	float bonus = 0;
	if (my_class() == $class[Pastamancer] || my_class() == $class[Sauceror] || isActuallyEd())
	{
		bonus = 5;
	}
	if(resistance <= 3)
	{
		return ((10.0 * resistance) + bonus);
	}
	float scale = 1.0;
	resistance = resistance - 4;
	while(resistance > 0)
	{
		scale = scale * 5.0/6.0;
		resistance = resistance - 1;
	}
	return (90.0 - (50.0 * scale) + bonus);
}

int elemental_resist(element goal)
{
	return numeric_modifier(goal + " resistance");
}

skill preferredLibram()
{
	if(auto_have_skill($skill[Summon Brickos]) && (get_property("_brickoEyeSummons").to_int() < 3))
	{
		return $skill[Summon Brickos];
	}
	if(auto_have_skill($skill[Summon Party Favor]) && (get_property("_favorRareSummons").to_int() < 3))
	{
		return $skill[Summon Party Favor];
	}
	if(auto_have_skill($skill[Summon Resolutions]))
	{
		return $skill[Summon Resolutions];
	}
	if(auto_have_skill($skill[Summon Taffy]))
	{
		return $skill[Summon Taffy];
	}
	return $skill[none];
}


boolean lastAdventureSpecialNC()
{
	if(my_class() == $class[Turtle Tamer])
	{
		if($strings[Nantucket Snapper, Blue Monday, Capital!, Training Day, Boxed In, Duel Nature, Slow Food, A Rolling Turtle Gathers No Moss, The Horror..., Slow Road to Hell, C\'mere\, Little Fella, The Real Victims, Like That Time in Tortuga, Cleansing your Palette, Harem Scarum, Turtle in peril, No Man\, No Hole, Slow and Steady Wins the Brawl, Stormy Weather, Turtles of the Universe, O Turtle Were Art Thou, Allow 6-8 Weeks For Delivery, Kick the Can, Turtles All The Way Around, More eXtreme Than Usual, Jewel in the Rough, The worst kind of drowning, Even Tamer Than Usual, Never Break the Chain, Close\, but Yes Cigar, Armchair Quarterback, This Turtle Rocks!, Really Sticking Her Neck Out, It Came from Beneath the Sewer? Great!, Don\'t Be Alarmed\, Now, Puttin\' it on Wax, More Like... Hurtle, Musk! Musk! Musk!, Silent Strolling] contains get_property("lastEncounter"))
		{
			return true;
		}
	}

	//I suppose we really do not need to validate that we have a Haunted Doghouse actually.
	if($strings[Wooof! Wooooooof!, Playing Fetch*, Your Dog Found Something Again, Dog Diner Afternoon, Labrador Conspirator, Doggy Heaven, Lava Dogs, Fruuuuuuuit, Boooooze Hound, Baker\'s Dogzen, Dog Needs Food Badly, Ratchet-catcher, Something About Hot Wings, Seeing-Eyes Dog, Carpenter Dog, Are They Made of Real Dogs?, Gunbowwowder, It Isn\'t a Poodle] contains get_property("lastEncounter"))
	{
		return true;
	}

	return false;
}

effect whatStatSmile()
{
	switch(my_class())
	{
	case $class[Seal Clubber]:
	case $class[Turtle Tamer]:
		return $effect[Patient Smile];
	case $class[Sauceror]:
	case $class[Pastamancer]:
		if(have_skill($skill[Inscrutable Gaze]))
		{
			return $effect[Inscrutable Gaze];
		}
		return $effect[Wry Smile];
	case $class[Disco Bandit]:
	case $class[Accordion Thief]:
		return $effect[Knowing Smile];
	}
	return $effect[none];
}

item whatHiMein()
{
	if(my_level() < 8)
	{
		return $item[none];
	}
	if(my_level() < 9)
	{
		return $item[Fettucini Inconnu];
	}

	if(!in_hardcore() && (my_level() >= 12) && (pulls_remaining() > 0))
	{
		switch(my_class())
		{
		case $class[Seal Clubber]:
		case $class[Turtle Tamer]:
			return $item[Cold Hi Mein];
		case $class[Sauceror]:
		case $class[Pastamancer]:
		case $class[Ed the Undying]:
			return $item[Spooky Hi Mein];
		case $class[Disco Bandit]:
		case $class[Accordion Thief]:
			return $item[Sleazy Hi Mein];
		}
	}

	return $item[crudles];
}

boolean ovenHandle()
{
	if((auto_get_campground() contains $item[Dramatic&trade; range]) && !get_property("auto_haveoven").to_boolean())
	{
		if (auto_get_campground() contains $item[Certificate of Participation] && isActuallyEd())
		{
			auto_log_error("Mafia reports we have an oven but we do not. Logging back in will resolve this.");
		}
		else
		{
			auto_log_info("Oven found! We can cook!", "blue");
			set_property("auto_haveoven", true);
		}
	}

	if(!get_property("auto_haveoven").to_boolean() && (my_meat() >= (npc_price($item[Dramatic&trade; range]) + 1000)) && isGeneralStoreAvailable())
	{
		buyUpTo(1, $item[Dramatic&trade; range]);
		use(1, $item[Dramatic&trade; range]);
		set_property("auto_haveoven", true);
	}
	return get_property("auto_haveoven").to_boolean();
}

boolean isGhost(monster mon)
{
	boolean[monster] ghosts = $monsters[Ancient Ghost, Angry Ghost, Banshee Librarian, Battlie Knight Ghost, Bettie Barulio, Chalkdust Wraith, Claybender Sorcerer Ghost, Coaltergeist, Cold Ghost, Contemplative Ghost, Dusken Raider Ghost, Ghost, Ghost Actor, Ghost Miner, Ghost of Elizabeth Spookyraven, Hot Ghost, Hustled Spectre, Lovesick Ghost, Marcus Macurgeon, Marvin J. Sunny, Mayor Ghost, Mer-kin Specter, Model Skeleton, Mortimer Strauss, Plaid Ghost, Protector Spectre, Restless Ghost, Sexy Sorority Ghost, Sheet Ghost, Sleaze Ghost, Space Tourist Explorer Ghost, Spooky Ghost, Stench Ghost, The Ghost of Phil Bunion, The Unknown Accordion Thief, The Unknown Disco Bandit, The Unknown Pastamancer, The Unknown Sauceror, The Unknown Seal Clubber, The Unknown Turtle Tamer, Whatsian Commando Ghost, Wonderful Winifred Wongle];
	if((ghosts contains mon) && !mon.boss)
	{
		return true;
	}
	return isProtonGhost(mon);
}

boolean isProtonGhost(monster mon)
{
	boolean[monster] ghosts = $monsters[Boneless Blobghost, Emily Koops\, A Spooky Lime, The Ghost of Ebenoozer Screege, The Ghost of Jim Unfortunato, The Ghost of Lord Montague Spookyraven, The Ghost of Monsieur Baguelle, The Ghost of Oily McBindle, The Ghost of Richard Cockingham, The Ghost of Sam McGee, The Ghost of Vanillica \"Trashblossom\" Gorton, The Ghost of Waldo the Carpathian, The Headless Horseman, The Icewoman];
	if(ghosts contains mon)
	{
		return true;
	}
	return false;
}

int cloversAvailable()
{
	//count 11-leaf clovers
	int retval = 0; 

	if(!in_glover())
	{
		retval += available_amount($item[11-Leaf Clover]);
		//if none on hand, try to buy from hermit
		if(retval == 0)
		{
			acquireHermitItem($item[11-Leaf Clover]);
			retval += item_amount($item[11-Leaf Clover]);
		}
		//if none at hermit, try to pull one
		if(retval == 0)
		{
			pullXWhenHaveY($item[11-Leaf Clover], 1, item_amount($item[11-Leaf Clover]));
			retval += item_amount($item[11-Leaf Clover]);
		}
	}

	//count Astral Energy Drinks which we have room to chew. Must specify ID since there are now 2 items with this name
	retval += min(available_amount($item[[10883]Astral Energy Drink]), floor(spleen_left() / 5));

	//other known sources which aren't counted here:
	// Lucky Lindy, Optimal Dog, Pillkeeper

	return retval;
}

boolean cloverUsageInit()
{
	if(cloversAvailable() == 0)
	{
		abort("Called cloverUsageInit but have no clovers");
	}
	//do we already have Lucky!?
	if(have_effect($effect[Lucky!]) > 0)
	{
		return true;
	}

	//use a clover if we have one in inventory or closet
	if(item_amount($item[11-Leaf Clover]) < 1)
	{
		//try to get one out of closet, catch to avoid an error being thrown
		catch retrieve_item(1, $item[11-Leaf Clover]);	
	}
	if(item_amount($item[11-Leaf Clover]) > 0)
	{
		use(1, $item[11-Leaf Clover]);
		if(have_effect($effect[Lucky!]) > 0)
		{
			auto_log_info("Clover usage initialized");
			return true;
		}
		else
		{
			auto_log_warning("Did not acquire Lucky! after using an 11-Leaf Clover");
		}
	}
	
	//use Astral Energy Drinks if we have room
	if(spleen_left() >= 5)
	{
		if(item_amount($item[[10883]Astral Energy Drink]) < 1)
		{
			//try to get one out of closet
			retrieve_item(1, $item[[10883]Astral Energy Drink]);		
		}
		if(item_amount($item[[10883]Astral Energy Drink]) > 0)
		{
			chew(1, $item[[10883]Astral Energy Drink]);
			if(have_effect($effect[Lucky!]) > 0)
			{
				auto_log_info("Clover usage initialized");
				return true;
			}
			else
			{
				auto_log_warning("Did not acquire Lucky! after drinking an Astral Energy Drink");
			}
		}
	}

	abort("We tried to initialize clover usage but was unable to get Lucky!");
	return false;
}

boolean cloverUsageRestart()
{
	if(have_effect($effect[Lucky!]) == 0)
	{
		return false;
	}
	if(equipped_amount($item[June cleaver]) > 0 && $strings[Poetic Justice, Aunts not Ants, Beware of Aligator, Beware of Alligator, Teacher\'s Pet, Lost and Found, Summer Days, Bath Time, Delicious Sprouts, Hypnotic Master] contains get_property("lastEncounter"))
	{
		//got interrupted and should adventure again in same location
		return true;
	}
	return false;
}

boolean cloverUsageFinish()
{
	if(have_effect($effect[Lucky!]) > 0)
	{
		abort("Wandering adventure interrupted our clover adventure (" + my_location() + ").");
	}
	return true;
}

boolean isHermitAvailable()
{
	if(in_nuclear())
	{
		return false;
	}
	if(in_zombieSlayer())
	{
		return false;
	}
	if(in_koe())
	{
		return false;
	}
	return true;
}

boolean isGalaktikAvailable()
{
	if(in_nuclear())
	{
		return false;
	}
	if(in_zombieSlayer())
	{
		return false;
	}
	if(in_koe())
	{
		return false;
	}
	return true;
}

boolean isGeneralStoreAvailable()
{
	if(in_nuclear())
	{
		return false;
	}
	if(in_zombieSlayer())
	{
		return false;
	}
	return true;
}

boolean isArmoryAndLeggeryStoreAvailable()
{
	if(in_nuclear())
	{
		return false;
	}
	if(in_zombieSlayer())
	{
		return false;
	}
	if(in_koe())
	{
		return false;
	}
	return true;
}

boolean isMusGuildStoreAvailable()
{
	if ($classes[seal clubber, turtle tamer] contains my_class() && guild_store_available())
	{
		return true;
	}
	if (my_class() == $class[accordion thief] && my_level() >= 9 && guild_store_available())
	{
		return true;
	}
	return false;
}

boolean isMystGuildStoreAvailable() {
	if ($classes[Pastamancer, Sauceror] contains my_class() && guild_store_available()) {
		return true;
	}
	if (my_class() == $class[Accordion Thief] && my_level() >= 9 && guild_store_available()) {
		return true;
	}
	return false;
}

boolean isArmoryAvailable()
{
	if(in_nuclear())
	{
		return false;
	}
	if(in_zombieSlayer())
	{
		return false;
	}
	if(in_koe())
	{
		return false;
	}
	return true;
}

boolean isUnclePAvailable()
{
	if(in_nuclear())
	{
		return false;
	}
	if(in_zombieSlayer())
	{
		return false;
	}
	string page_text = visit_url("place.php?whichplace=desertbeach");
	return !page_text.contains_text("You don't know where a desert beach is");
}

boolean isDesertAvailable()
{
	//Is this workaround still needed or is mafia correctly recognizing desert is available in koe?
	if(in_koe())
	{
		auto_log_info("The desert exploded so no need to build a meatcar...");
		set_property("lastDesertUnlock", my_ascensions());
	}
	
	return get_property("lastDesertUnlock").to_int() == my_ascensions();
}

boolean inKnollSign()
{
	return $strings[Mongoose, Vole, Wallaby] contains my_sign();
}

boolean inCanadiaSign()
{
	return $strings[Marmot, Opossum, Platypus] contains my_sign();
}

boolean inGnomeSign()
{
	return $strings[Blender, Packrat, Wombat] contains my_sign();
}

boolean allowSoftblockShen()
{
	//Some quests have a softblock on doing them because shen might need them. When we run out of things to do this softblock is released.
	//Return true means the softblock is active. Return false means the softblock is released.
	if(get_property("questL11Shen") == "finished")
	{
		return false;		//shen quest is over. softblock not needed
	}
	
	//We tell users to disable the shen softblock by setting auto_shenSkipLastLevel to 999.
	//This is why we want to return < my_level() and not != my_level()
	return get_property("auto_shenSkipLastLevel").to_int() < my_level();
}

boolean setSoftblockShen()
{
	auto_log_warning("I was trying to avoid zones that Shen might need, but I've run out of stuff to do. Releasing softblock.", "red");
	set_property("auto_shenSkipLastLevel", my_level());
	return true;
}

boolean instakillable(monster mon)
{
	if(mon.boss)
	{
		return false;
	}

	static boolean[monster] not_instakillable = $monsters[
		// Cyrpt bosses
		conjoined zmombie, gargantulihc, giant skeelton, huge ghuol,
		
		// crowd of adventurers bosses at the tower tests
		Tasmanian Dervish, Mr. Loathing, The Mastermind, Seannery the Conman, The Lavalier, Leonard, Arthur Frankenstein, Mrs. Freeze, Odorous Humongous,

		// time-spinner
		Ancient Skeleton with Skin still on it, Apathetic Tyrannosaurus, Assembly Elemental, Cro-Magnon Gnoll, Krakrox the Barbarian, Wooly Duck,

		// Love Tunnel
		LOV Enforcer, LOV Engineer, LOV Equivocator,

		// ancient protector spirits
		Protector Spectre, ancient protector spirit, ancient protector spirit (The Hidden Apartment Building), ancient protector spirit (The Hidden Hospital), ancient protector spirit (The Hidden Office Building), ancient protector spirit (The Hidden Bowling Alley),

		// Macguffin snakes
		Batsnake, Frozen Solid Snake, Burning Snake of Fire, The Snake With Like Ten Heads, The Frattlesnake, Snakeleton,

		// Voting monsters
		slime blob, terrible mutant, government bureaucrat, angry ghost, annoyed snake,

		// Tentacles
		Sssshhsssblllrrggghsssssggggrrgglsssshhssslblgl, Eldritch Tentacle,

		// Other Monsters that Mafia returns as instakillable (or not a boss), that really aren't
		cosmetics wraith, Drunken Rat King, booty crab
	];

	if(not_instakillable contains mon)
	{
		return false;
	}

	return true;
}


boolean stunnable(monster mon)
{
	if (mon.random_modifiers contains "unstoppable")
	{
		return false;
	}
	if (mon.random_modifiers contains "rabbit mask")
	{
		return false;
	}
	// Incomplete, because challenge paths are a thing
	boolean[monster] unstunnable_monsters = $monsters[
		// Standard
			Wall of Skin,
			Wall of Bones,
			Eldritch Tentacle,
		// Cargo Cultist Shorts
			Astrologer of Shub-Jigguwatt,
			Burning Daughter,
			Chosen of Yog-Urt,
			Herald of Fridgr,
			Tentacle of Sssshhsssblllrrggghsssssggggrrgglsssshhssslblgl,
		// Vampyre
			Your Lack of Reflection,
			%alucard%,
		// Heavy Rains
			storm cow,
		// Witchess Monsters
			Witchess Witch,
			Witchess Queen,
			Witchess King,
		// Other
			Cyrus the Virus,
			broctopus,
			cocktail shrimp,
	];
	
	if($monsters[Naughty Sorceress, Naughty Sorceress (2)] contains mon && !get_property("auto_confidence").to_boolean())
	{
		return false;
	}

	return !(unstunnable_monsters contains mon);
}
					    
float combatItemDamageMultiplier()
{
	float retval = 1;
	if(auto_have_skill($skill[Deft Hands]))
	{
		retval += 0.25;
	}
	if(have_effect($effect[Mathematically Precise]) > 0)
	{
		retval += 0.50;
	}
	if(have_equipped($item[V for Vivala mask]))
	{
		retval += 0.50;
	}
	return retval;
}

float MLDamageToMonsterMultiplier()
{
	//Positive ML gives monsters damage resistance
	//Negative ML increases the damage inflicted on monsters
	float retval = 1 - 0.004*monster_level_adjustment();
	if(retval < 0.5)
	{
		//damage resistance is capped at 50%
		retval = 0.5;
	}
	return retval;
}

int freeCrafts()
{
	int retval = 0;
	if(have_skill($skill[Rapid Prototyping]) && is_unrestricted($item[Crimbot ROM: Rapid Prototyping]))
	{
		retval += 5 - get_property("_rapidPrototypingUsed").to_int();
	}
	if(have_skill($skill[Expert Corner-Cutter]) && is_unrestricted($item[LyleCo Contractor\'s Manual]))
	{
		retval += 5 - get_property("_expertCornerCutterUsed").to_int();
	}
	retval += have_effect($effect[Inigo\'s Incantation Of Inspiration]) / 5;
	retval += get_property("homebodylCharges").to_int();
#	if(have_skill($skill[Inigo\'s Incantation Of Inspiration]))
#	{
#		if(my_mp() > mp_cost($skill[Inigo\'s Incantation Of Inspiration]))
#		{
#			retval += 2;
#		}
#		else if(have_effect($effect[Inigo\'s Incantation Of Inspiration]) >= 5)
#		{
#			retval += 1;
#		}
#	}

	return retval;
}

boolean isFreeMonster(monster mon)
{
	if ($monsters[Angry Ghost, Annoyed Snake, Government Bureaucrat, Slime Blob, Terrible Mutant] contains mon && get_property("_voteFreeFights").to_int() < 3)
	{
		return true;
	}

	if ($monsters[biker, burnout, jock, party girl, "plain" girl] contains mon && get_property("_neverendingPartyFreeTurns").to_int() < 10)
	{
		return true;
	}

	if ($monsters[Perceiver of Sensations, Performer of Actions, Thinker of Thoughts] contains mon)
	{
		if (my_familiar() == $familiar[Machine Elf] && get_property("_machineTunnelsAdv").to_int() < 5 && my_location() == $location[The Deep Machine Tunnels])
		{
			return true;
		}
	}

	if ($monster[X-32-F Combat Training Snowman] == mon && get_property("_snojoFreeFights").to_int() < 10)
	{
		return true;
	}

	if ($monsters[void guy, void slab, void spider] contains mon && get_property("_voidFreeFights").to_int() < 5)
	{
		return true;
	}

	if ($monster[Drunk Pygmy] == mon && item_amount($item[Bowl of Scorpions]) > 0)
	{
		return true;
	}

	if (mon.random_modifiers["optimal"])
	{
		return true;
	}

	if (mon.attributes.to_lower_case().contains_text("free"))
	{
		return true;
	}

	return false;
}

boolean declineTrades()
{
	int count = 0;
	string trades = visit_url("makeoffer.php");
	string digit = "(\\d*)";
	matcher trade_matcher = create_matcher("makeoffer.php[?]action=decline&whichoffer=" + digit, trades);
	while(trade_matcher.find())
	{
		string temp = visit_url("makeoffer.php?action=decline&whichoffer=" + trade_matcher.group(1), false);
		count++;
	}
	if(count > 0)
	{
		auto_log_info("Declined " + count + " trades.", "blue");
		return true;
	}
	return false;
}

boolean auto_deleteMail(kmailObject msg)
{
	if((msg.fromid == 0) && (contains_text(msg.message, "We found this telegram at the bottom of an old bin of mail.")))
	{
		return true;
	}
	if((msg.fromid == 0) && (contains_text(msg.message, "One of my agents found a copy of a telegram in the Council\'s fileroom")))
	{
		return true;
	}
	if (get_property("auto_consultChoice") != ""){
		int id = get_player_id(get_property("auto_consultChoice")).to_int();
		if( msg.fromid == id && (contains_text(msg.message, "completed your relationship fortune test")) && get_property("auto_hideAdultery").to_boolean())
		{
			return true;
		}
	}
	if((msg.fromid == 3038166) && (contains_text(msg.message, "completed your relationship fortune test")) && get_property("auto_hideAdultery").to_boolean())
	{
		return true;
	}

	if((msg.fromid == -1) && (contains_text(msg.message, "Your dedication to helping me fight crime in Gotpork city almost makes me forget about the fact that crime in Gotpork city cost me my parents.")))
	{
		return true;
	}

	if(msg.fromname == "Lady Spookyraven\\'s Ghost")
	{
		return true;
	}
	if(msg.fromname == "Lady Spookyraven\'s Ghost")
	{
		return true;
	}
	return false;
}

boolean LX_summonMonster()
{
	// summon screambat if we are at last wall to knock down and don't have a sonar-in-a-biscuit
	if(internalQuestStatus("questL04Bat") == 2 && (!auto_is_valid($item[Sonar-In-A-Biscuit]) || item_amount($item[Sonar-In-A-Biscuit]) == 0) &&
		canSummonMonster($monster[screambat]))
	{
		if(summonMonster($monster[screambat])) return true;
	}

	// summon mountain man if we know the ore we need and still need 2 or more
	// don't summon if we have model train set as it is an easy source of ore
	item oreGoal = to_item(get_property("trapperOre"));
	if(internalQuestStatus("questL08Trapper") < 2 && get_workshed() != $item[model train set] && oreGoal != $item[none] && 
		item_amount(oreGoal) < 2 && canYellowRay() && canSummonMonster($monster[mountain man]))
	{
		adjustForYellowRayIfPossible();
		if(summonMonster($monster[mountain man])) return true;
	}

	// only summon NSA if in hardcore as we will pull items in normal runs
	if(internalQuestStatus("questL08Trapper") < 3 && in_hardcore() && my_level() >= 8 && !get_property("auto_L8_extremeInstead").to_boolean())
	{
		auto_log_debug("Thinking about summoning ninja snowman assassin");
		boolean wantSummonNSA = item_amount($item[ninja rope]) < 1 || 
			item_amount($item[ninja carabiner]) < 1 || 
			item_amount($item[ninja crampons]) < 1;
		if(wantSummonNSA && canSummonMonster($monster[Ninja Snowman Assassin]))
		{
			if(summonMonster($monster[Ninja Snowman Assassin])) return true;
		}
	}

	if(auto_is_valid($item[Smut Orc Keepsake Box]) && item_amount($item[Smut Orc Keepsake Box]) == 0 && my_level() >= 9 && 
		(lumberCount() < 30 || fastenerCount() < 30) && canSummonMonster($monster[smut orc pervert]))
	{
		// summon pervert here but handling of L9 quest will open box
		if(auto_haveGreyGoose()){
			handleFamiliar($familiar[Grey Goose]);
		}
		if(summonMonster($monster[smut orc pervert])) return true;
	}

	// summon LFM if don't have autumnaton since that guarantees 1 turn to get 5 barrels
	if(item_amount($item[barrel of gunpowder]) < 5 && get_property("sidequestLighthouseCompleted") == "none" && 
	my_level() >= 12 && !auto_hasAutumnaton() && canSummonMonster($monster[lobsterfrogman]))
	{
		if(summonMonster($monster[lobsterfrogman])) return true;
	}

	// get war outfit if have yr available. 
	// check for lvl 9 as that is when "L12_preOutfit" will try to get the prewar outfit. Better to summon and skip to war outfit
	if(!possessOutfit("Frat Warrior Fatigues") && auto_warSide() == "fratboy" && canYellowRay() && my_level() >= 9 &&
		(canSummonMonster($monster[War Frat 151st Infantryman]) || 
		canSummonMonster($monster[War Frat Mobile Grill Unit]) ||
		canSummonMonster($monster[orcish frat boy spy])))
	{
		adjustForYellowRayIfPossible();
		// attempt to use calculate the universe
		if(summonMonster($monster[War Frat 151st Infantryman])) return true;
		// attempt to summon other sources of outfit
		if(summonMonster($monster[War Frat Mobile Grill Unit])) return true;
		if(summonMonster($monster[orcish frat boy spy])) return true;
	}
	if(!possessOutfit("War Hippy Fatigues") && auto_warSide() == "hippy" && canYellowRay() && my_level() >= 12 &&
		(canSummonMonster($monster[War Hippy Airborne Commander]) || 
		canSummonMonster($monster[war hippy spy])))
	{
		adjustForYellowRayIfPossible();
		if(summonMonster($monster[War Hippy Airborne Commander])) return true;
		if(summonMonster($monster[war hippy spy])) return true;
	}

	// summon astronomer if only missing star chart for star key
	if(needStarKey() && item_amount($item[Star]) >= 8 && item_amount($item[Line]) >= 7 && canSummonMonster($monster[Astronomer]))
	{
		if(summonMonster($monster[Astronomer])) return true;
	}

	return false;
}

boolean canSummonMonster(monster mon)
{
	return summonMonster(mon, true);
}

boolean summonMonster(monster mon)
{
	return summonMonster(mon, false);
}

boolean summonMonster(monster mon, boolean speculative)
{
	auto_log_debug((speculative ? "Checking if we can" : "Trying to") + " summon " + mon, "blue");
	// methods which require specific circumstances
	if(mon == $monster[War Frat 151st Infantryman])
	{	
		// calculate the universe's only summon we want, so prioritize using it
		if(LX_calculateTheUniverse(speculative))
		{
			auto_log_debug((speculative ? "Can" : "Did") + " summon " + mon, "blue");
			return true;
		}
	}
	if(timeSpinnerCombat(mon, speculative))
	{
		return true;
	}
	// methods which can only summon monsters should be attempted first
	if(auto_fightLocketMonster(mon, speculative))
	{
		auto_log_debug((speculative ? "Can" : "Did") + " summon " + mon, "blue");
		return true;
	}
	if(handleFaxMonster(mon, !speculative))
	{
		auto_log_debug((speculative ? "Can" : "Did") + " summon " + mon, "blue");
		return true;
	}
	// methods which can do more than summon monsters
	if(auto_cargoShortsOpenPocket(mon, speculative))
	{
		auto_log_debug((speculative ? "Can" : "Did") + " summon " + mon, "blue");
		return true;
	}
	if(auto_shouldUseWishes())
	{
		if(speculative && canGenieCombat())
		{
			auto_log_debug("Can summon " + mon, "blue");
			return true;
		}
		else if(!speculative && makeGenieCombat(mon))
		{
			auto_log_debug("Did summon " + mon, "blue");
			return true;
		}
	}

	//todo
	// add support for rainManSummon(). Look to routineRainManHandler()

	return false;
}

boolean handleCopiedMonster(item itm)
{
	return handleCopiedMonster(itm, "");
}

boolean handleCopiedMonster(item itm, string option)
{
	int id = 0;
	switch(itm)
	{
	case $item[Rain-Doh Black Box]:
		return handleCopiedMonster($item[Rain-Doh Box Full of Monster], option);
	case $item[Spooky Putty Sheet]:
		return handleCopiedMonster($item[Spooky Putty Monster], option);
	case $item[4-D Camera]:
		return handleCopiedMonster($item[Shaking 4-D Camera], option);
	case $item[Unfinished Ice Sculpture]:
		return handleCopiedMonster($item[Ice Sculpture], option);
	case $item[Print Screen Button]:
		return handleCopiedMonster($item[Screencapped Monster], option);
	case $item[Rain-Doh Box Full of Monster]:
		if(get_property("rainDohMonster") == "")
		{
			abort(itm + " has no monster so we can't use it");
		}
		id = to_int(itm);
		break;
	case $item[Spooky Putty Monster]:
		if(get_property("spookyPuttyMonster") == "")
		{
			abort(itm + " has no monster so we can't use it");
		}
		id = to_int(itm);
		break;
	case $item[Shaking 4-D Camera]:
		if(get_property("cameraMonster") == "")
		{
			abort(itm + " has no monster so we can't use it");
		}
		if(get_property("_cameraUsed").to_boolean())
		{
			abort(itm + " already used today. We can not continue");
		}
		id = to_int(itm);
		break;
	case $item[Ice Sculpture]:
		if(item_amount(itm) == 0)
		{
			abort("We do not have any " + itm);
		}
		if(get_property("iceSculptureMonster") == "")
		{
			abort(itm + " has no monster so we can't use it");
		}
		if(get_property("_iceSculptureUsed").to_boolean())
		{
			abort(itm + " already used today. We can not continue");
		}
		id = to_int(itm);
		break;
	case $item[Screencapped Monster]:
		if(get_property("screencappedMonster") == "")
		{
			abort(itm + " has no monster so we can't use it");
		}
		id = to_int(itm);
		break;
	}
	if(id != 0)
	{
		return autoAdvBypass("inv_use.php?pwd&which=3&whichitem=" + id, $location[Noob Cave], option);
	}
	return false;
}

int maxSealSummons()
{
	if(item_amount($item[Claw of the Infernal Seal]) > 0)
	{
		return 10;
	}
	return 5;
}


boolean acquireCombatMods(int amt)
{
	return acquireCombatMods(amt, true);
}

boolean acquireCombatMods(int amt, boolean doEquips)
{
	if(amt < 0)
	{
		return providePlusNonCombat(min(25, -1 * amt), doEquips);
	}
	else if(amt > 0)
	{
		return providePlusCombat(min(25, amt), doEquips);
	}
	return true;
}

boolean basicAdjustML()
{
	if(is_boris()) return borisAdjustML();
	if(in_plumber())
	{
		// We don't get many stats from combat - no point running ML.
		auto_change_mcd(0);
		return false;
	}
	if((monster_level_adjustment() > 150) && (monster_level_adjustment() <= 160))
	{
		int base = (monster_level_adjustment() - current_mcd());
		if(base <= 150)
		{
			int canhave = 150 - base;
			auto_change_mcd(canhave);
		}
	}
	else
	{
		if(((get_property("flyeredML").to_int() >= 10000) || get_property("auto_ignoreFlyer").to_boolean()) && (my_level() >= 13) && (!get_property("auto_disregardInstantKarma").to_boolean()))
		{
			auto_change_mcd(0);
		}
		else if((monster_level_adjustment() + (10 - current_mcd())) <= 150)
		{
			auto_change_mcd(11);
		}
	}
	return false;
}

int highest_available_mcd()
{
	if(in_koe()) return 0;
	
	if(knoll_available() && item_amount($item[Detuned Radio]) > 0)
	{
		if(in_glover())
		{
			return 0;
		}
		else
		{
			return 10;
		}
	}
	else if(inGnomeSign() && gnomads_available())
	{
		return 10;
	}
	else if(canadia_available())
	{
		return 11;
	}
	//in_bad_moon() availability is special since it costs a turn and highest is 8 to 11 by RNG
	
	return current_mcd();
}

boolean auto_change_mcd(int mcd)
{
	return auto_change_mcd(mcd, false);
}

boolean auto_change_mcd(int mcd, boolean immediately)
{
	int best = highest_available_mcd();
	if(in_bad_moon())
	{
		best = 11;
	}
	//under level 13 we want to level up. level 14+ we already missed the instant karma, no point in holding back anymore.
	if(my_level() == 13 && !get_property("auto_disregardInstantKarma").to_boolean())
	{
		if((get_property("questL12War") == "finished") || (get_property("sidequestArenaCompleted") != "none") || (get_property("flyeredML").to_int() >= 10000) || get_property("auto_ignoreFlyer").to_boolean())
		{
			mcd = 0;
		}
	}
	mcd = min(mcd, best);
	int next = max(0, mcd);
	
	set_property("auto_mcd_target", next); // if we return without setting this, we will flip-flop the mcd every adventure...

	if(next == current_mcd())
	{
		return true;
	}
	
	if(immediately)
	{
		return change_mcd(next);
	}
	//for non immediate changes we still return true because the mafia setting was changed and MCD will be changed later.
	return true;
}

boolean evokeEldritchHorror(string option)
{
	if(!have_skill($skill[Evoke Eldritch Horror]))
	{
		return false;
	}
	if(get_property("_eldritchHorrorEvoked").to_boolean())
	{
		return false;
	}
	if(my_mp() < mp_cost($skill[Evoke Eldritch Horror]))
	{
		return false;
	}

	string[int] pages;
	pages[0] = "runskillz.php?pwd=&targetplayer" + my_id() + "&quantity=1&whichskill=168";
	return autoAdvBypass(0, pages, $location[Noob Cave], option);
}

boolean evokeEldritchHorror()
{
	return evokeEldritchHorror("");
}

boolean fightScienceTentacle(string option)
{
	if(get_property("_eldritchTentacleFought").to_boolean())
	{
		return false;
	}

	if (!handleServant($servant[Scribe]))
	{
		handleServant($servant[Cat]);
	}

	string temp = visit_url("place.php?whichplace=forestvillage&action=fv_scientist");

	string[int] choices = available_choice_options();
	int abortChoice = 0;
	foreach idx, text in choices
	{
		if(text == "Great!")
		{
			abortChoice = idx;
			break;
		}
	}

	if((choices[1] != "Can I fight that tentacle you saved for science?") || (abortChoice == 0))
	{
		set_property("_eldritchTentacleFought", true);
		temp = visit_url("choice.php?whichchoice=1201&pwd=&option=" + abortChoice);
		return false;
	}

	temp = visit_url("choice.php?whichchoice=1201&pwd=&option=" + abortChoice);
	set_property("auto_nextEncounter","Eldritch Tentacle");
	string[int] pages;
	pages[0] = "place.php?whichplace=forestvillage&action=fv_scientist";
	pages[1] = "choice.php?whichchoice=1201&pwd=&option=1";
	return autoAdvBypass(0, pages, $location[Noob Cave], option);

}

boolean fightScienceTentacle()
{
	return fightScienceTentacle("");
}


boolean handleSealNormal(item it)
{
	return handleSealNormal(it, "");
}

boolean handleSealNormal(item it, string option)
{
	int candles = 0;
	int level = 0;
	switch(it)
	{
	case $item[Figurine of an Armored Seal]:			candles = 10;		level = 9;		break;
	case $item[Figurine of a Cute Baby Seal]:			candles = 5;		level = 5;		break;
	case $item[Figurine of a Wretched-Looking Seal]:	candles = 1;		level = 1;		break;
	}

	if(candles == 0)
	{
		return false;
	}

	if((get_property("_sealsSummoned").to_int() < maxSealSummons()) && (item_amount(it) > 0) && (item_amount($item[seal-blubber candle]) >= candles) && (my_level() >= level))
	{
		ensureSealClubs();
		return autoAdvBypass("inv_use.php?pwd=&whichitem=" + to_int(it) + "&checked=1", $location[Noob Cave], option);
	}
	else
	{
		abort("Can't use " + it + " for some raisin");
	}
	return false;
}
boolean handleSealAncient()
{
	return handleSealAncient("");
}
boolean handleSealAncient(string option)
{
	if((get_property("_sealsSummoned").to_int() < maxSealSummons()) && (item_amount($item[figurine of an ancient seal]) > 0) && (item_amount($item[seal-blubber candle]) >= 3))
	{
		return autoAdvBypass("inv_use.php?pwd=&whichitem=3905&checked=1", $location[Noob Cave], option);
	}
	else
	{
		abort("Can't use an Ancient Seal for some raisin");
	}
	return false;
}
boolean handleSealElement(element flavor)
{
	return handleSealElement(flavor, "");
}
boolean handleSealElement(element flavor, string option)
{
	string page = "";
	if((flavor == $element[hot]) && (get_property("_sealsSummoned").to_int() < maxSealSummons()) && (item_amount($item[figurine of a charred seal]) > 0) && (item_amount($item[imbued seal-blubber candle]) > 0))
	{
		page = "inv_use.php?pwd=&whichitem=3909&checked=1";
	}
	if((flavor == $element[cold]) && (get_property("_sealsSummoned").to_int() < maxSealSummons()) && (item_amount($item[figurine of a cold seal]) > 0) && (item_amount($item[imbued seal-blubber candle]) > 0))
	{
		page = "inv_use.php?pwd=&whichitem=3910&checked=1";
	}
	if((flavor == $element[sleaze]) && (get_property("_sealsSummoned").to_int() < maxSealSummons()) && (item_amount($item[figurine of a slippery seal]) > 0) && (item_amount($item[imbued seal-blubber candle]) > 0))
	{
		page = "inv_use.php?pwd=&whichitem=3911&checked=1";
	}
	if((flavor == $element[spooky]) && (get_property("_sealsSummoned").to_int() < maxSealSummons()) && (item_amount($item[figurine of a shadowy seal]) > 0) && (item_amount($item[imbued seal-blubber candle]) > 0))
	{
		page = "inv_use.php?pwd=&whichitem=3907&checked=1";
	}
	if((flavor == $element[stench]) && (get_property("_sealsSummoned").to_int() < maxSealSummons()) && (item_amount($item[figurine of a stinking seal]) > 0) && (item_amount($item[imbued seal-blubber candle]) > 0))
	{
		page = "inv_use.php?pwd=&whichitem=3908&checked=1";
	}
	return autoAdvBypass(page, $location[Noob Cave], option);
}

boolean handleBarrelFullOfBarrels(boolean daily)
{
	if(!get_property("barrelShrineUnlocked").to_boolean())
	{
		return false;
	}
	if(daily && get_property("_didBarrelBustToday").to_boolean())
	{
		return false;
	}
	if(!is_unrestricted($item[Shrine to the Barrel God]))
	{
		return false;
	}

	string page = visit_url("barrel.php");

	if(!contains_text(page, "The Barrel Full of Barrels"))
	{
		return false;
	}

	boolean [string] locations;
	int smashed = 0;
	matcher mimic_matcher = create_matcher("<div class=\"ex\">((?:<div class=\"mimic\">!</div>)|)<a class=\"spot\" href=\"choice.php[?]whichchoice=1099[&]pwd=(?:.*?)[&]option=1[&]slot=(\\d\\d)\"><img title=\"(.*?)\"", page);
	while(mimic_matcher.find())
	{
		string mimic = mimic_matcher.group(1);
		string slotID = mimic_matcher.group(2);
		string label = mimic_matcher.group(3);

		if(mimic != "")
		{
			auto_log_warning("Found mimic in slot: " + slotID, "red");
		}
		else if(label == "A barrel")
		{
			smashed = smashed + 1;
			visit_url("choice.php?whichchoice=1099&pwd&option=1&slot=" + slotID);
		}
	}
	set_property("_didBarrelBustToday", true);
	return (smashed > 0);
}

boolean use_barrels()
{
	if(!get_property("barrelShrineUnlocked").to_boolean())
	{
		return false;
	}
	if(inAftercore())
	{
		return false;
	}
	if(in_bhy())
	{
		return false;
	}

	boolean [item] barrels = $items[little firkin, normal barrel, big tun, weathered barrel, dusty barrel, disintegrating barrel, moist barrel, rotting barrel, mouldering barrel, barnacled barrel];

	boolean retval = false;
	foreach it in barrels
	{
		if(item_amount(it) < 10)
		{
			retval = retval | (item_amount(it) > 0);
			use(item_amount(it), it);
		}
	}
	return retval;
}

boolean forceEquip(slot sl, item it)
{
	if(!possessEquipment(it))
	{
		return false;
	}
	if(equipped_item(sl) == it)
	{
		return true;
	}
	autoEquip(sl, it);
	return true;
}

boolean auto_autosell(int quantity, item toSell)
{
	if(my_meat() > 100000)
	{
		return false;
	}

	if(item_amount(toSell) < quantity)
	{
		return false;
	}

	if(!in_wotsf())
	{
		return autosell(quantity, toSell);
	}
	if(get_property("totalCharitableDonations").to_int() < 1000000)
	{
		return autosell(quantity, toSell);
	}
	return false;
}

string runChoice(string page_text)
{
	while(contains_text(page_text , "choice.php"))
	{
		## Get choice adventure number
		int begin_choice_adv_num = index_of(page_text , "whichchoice value=") + 18;
		int end_choice_adv_num = index_of(page_text , "><input" , begin_choice_adv_num);
		string choice_adv_num = substring(page_text , begin_choice_adv_num , end_choice_adv_num);

		string choice_adv_prop = "choiceAdventure" + choice_adv_num;
		string choice_num = get_property(choice_adv_prop);
		if(choice_num == "")
		{
			abort("Unsupported Choice Adventure!");
		}

		string url = "choice.php?pwd&whichchoice=" + choice_adv_num + "&option=" + choice_num;
		page_text = visit_url(url);
	}
	return page_text;
}

boolean set_property_ifempty(string setting, string change)
{
	if(get_property(setting) == "")
	{
		set_property(setting, change);
		return true;
	}
	return false;
}

boolean restore_property(string setting, string source)
{
	string data = get_property(source);
	set_property(setting, data);
	set_property(source, "");
	return (data != "");
}

boolean clear_property_if(string setting, string cond)
{
	if(get_property(setting) == cond)
	{
		set_property(setting, "");
		return true;
	}
	return false;
}

int doNumberology(string goal)
{
	return doNumberology(goal, true, "");
}

int doNumberology(string goal, string option)
{
	return doNumberology(goal, true, option);
}

int doNumberology(string goal, boolean doIt)
{
	return doNumberology(goal, doIt, "");
}

int doNumberology(string goal, boolean doIt, string option)
{
	if(!auto_have_skill($skill[Calculate the Universe]))
	{
		return -1;
	}
	if(get_property("_universeCalculated").to_int() >= min(3, get_property("skillLevel144").to_int()))
	{
		return -1;
	}
	if(my_mp() < 2)
	{
		return -1;
	}

	int numberwang = 69; // default to adventures3
	if (goal == "battlefield") {
		numberwang = 51;
	}

	int[int] numberology = reverse_numberology();

	if (numberology contains numberwang) {
		auto_log_info("Found option for Numberology: " + numberwang + " (" + goal + ")" , "blue");
		if(!doIt)
		{
			return numberology[numberwang];
		}

		if(goal == "battlefield")
		{
			string[int] pages;
			pages[0] = "runskillz.php?pwd&action=Skillz&whichskill=144&quantity=1";
			pages[1] = "choice.php?whichchoice=1103&pwd=&option=1&num=" + numberology[numberwang];
			autoAdvBypass(0, pages, $location[Noob Cave], option);
			handleTracker($monster[War Frat 151st Infantryman], $skill[Calculate the Universe], "auto_copies");
		}
		else
		{
			visit_url("runskillz.php?pwd&action=Skillz&whichskill=144&quantity=1", true);
			visit_url("choice.php?whichchoice=1103&pwd=&option=1&num=" + numberology[numberwang]);
		}
		return numberology[numberwang];
	}
	return -1;
}

boolean auto_have_skill(skill sk)
{
	return auto_is_valid(sk) && have_skill(sk);
}

boolean have_skills(boolean[skill] array)
{
	foreach sk in array
	{
		if(!auto_have_skill(sk))
		{
			return false;
		}
	}
	return true;
}

//From Bale\'s woods.ash relay script.
void woods_questStart()
{
	if(available_amount($item[Continuum Transfunctioner]) > 0)
	{
		return;
	}
	visit_url("place.php?whichplace=woods");
	visit_url("place.php?whichplace=forestvillage&action=fv_mystic");
	visit_url("choice.php?pwd=&whichchoice=664&option=1&choiceform1=Sure%2C+old+man.++Tell+me+all+about+it.");
	visit_url("choice.php?pwd=&whichchoice=664&option=1&choiceform1=Against+my+better+judgment%2C+yes.");
	visit_url("choice.php?pwd=&whichchoice=664&option=1&choiceform1=Er,+sure,+I+guess+so...");
	if(knoll_available())
	{
		visit_url("place.php?whichplace=knoll_friendly&action=dk_innabox");
		visit_url("place.php?whichplace=forestvillage&action=fv_untinker");
	}
	else
	{
		visit_url("place.php?whichplace=forestvillage&preaction=screwquest&action=fv_untinker_quest");
	}
}

int howLongBeforeHoloWristDrop()
{
	int drops = get_property("_holoWristDrops").to_int() + 1;
	int need = (drops * ((drops * 5) + 17)) / 2;
	drops = drops - 1;
	need = need - (drops * ((drops * 5) + 17)) / 2;
	return need - get_property("_holoWristProgress").to_int();
}

boolean hasShieldEquipped()
{
	return item_type(equipped_item($slot[off-hand])) == "shield";
}

boolean careAboutDrops(monster mon)
{
	if($monsters[Astronomer, Axe Wound, Beaver, Box, Burrowing Bishop, Bush, Camel\'s Toe, Family Jewels, Flange, Honey Pot, Hooded Warrior, Junk, Little Man in the Canoe, Muff, One-Eyed Willie, Pork Sword, Skinflute, Trouser Snake, Twig and Berries] contains mon)
	{
		if(!needStarKey())
		{
			return false;
		}
		if(($monster[Astronomer] == mon) && (item_amount($item[Star Chart]) > 0))
		{
			return false;
		}
		//We could refine this to get rid of all the all stars / lines mobs but meh.
		if(($monster[Astronomer] != mon) && ((item_amount($item[Star]) < 8) || (item_amount($item[Line]) < 7)))
		{
			return true;
		}
		return false;
	}

/*
pygmy bowler
pygmy witch accountant
white lion
white snake


baseball bat
briefcase bat
doughbat
perpendicular bat
skullbat
vampire bat
batrat
ratbat
beanbat
banshee librarian
knob Goblin Harem Girl
spiny skelelton
toothy sklelton
sassy pirate
smarmy pirate
swarthy pirate
tetchy pirate
toothy pirate
tipsy pirate
chatty pirate
cleanly pirate
clingy pirate
creamy pirate
crusty pirate
curmudgeonly pirate
dairy goat
ninja snowman assassin
smut orc jacker
smut orc nailer
smut orc pervert
smut orc pipelayer
smut orc screwer
Whatsian Commando Ghost
Space Tourist Explorer Ghost
Dusken Raider Ghost
Claybender Sorcerer Ghost
Battlie Knight Ghost
bearpig topiary animal
elephant (meatcar?) topiary animal
spider (duck?) topiary animal
oil cartel
oil baron
oil tycoon
Burly Sidekick
Quiet Healer
lobsterfrogman
possessed wine rack
cabinet of Dr. Limpieza
*/
	return false;
}

float effectiveDropChance(item it, float baseDropRate)
{
	//0 to 100 chance to drop at end of fight
	float retval;
	float item_modifier = item_drop_modifier();
	
	if(baseDropRate > 0)
	{
		if(it.item_type() == "food")
		{
			//todo? cooking ingredients
			item_modifier += numeric_modifier("Food Drop");
		}
		if(it.item_type() == "booze")
		{
			//todo? cocktailcrafting ingredients
			item_modifier += numeric_modifier("Booze Drop");
		}
		if(it.candy)
		{
			item_modifier += numeric_modifier("Candy Drop");
		}
		if(it.to_slot() != $slot[none] && $slots[hat,shirt,weapon,off-hand,pants,acc1,acc2,acc3,back] contains it.to_slot())
		{
			item_modifier += numeric_modifier("Gear Drop");
			
			if(it.to_slot() == $slot[hat])
			{
				item_modifier += numeric_modifier("Hat Drop");
			}
			if(it.to_slot() == $slot[shirt])
			{
				item_modifier += numeric_modifier("Shirt Drop");
			}
			if(it.to_slot() == $slot[weapon])
			{
				item_modifier += numeric_modifier("Weapon Drop");
			}
			if(it.to_slot() == $slot[off-hand])
			{
				item_modifier += numeric_modifier("Offhand Drop");
			}
			if(it.to_slot() == $slot[pants])
			{
				item_modifier += numeric_modifier("Pants Drop");
			}
			if($slots[acc1,acc2,acc3] contains it.to_slot())
			{
				item_modifier += numeric_modifier("Accessory Drop");
			}
		}
	}
	
	retval = baseDropRate *  (100 + item_modifier) / 100.0;
	retval = min(100,retval);		//final drop chance % before special modifiers
	
	if(retval > 0)
	{
		if(in_lar())
		{
			if(retval*2 >= 100)
			{
				retval = 100;
			}
			else
			{
				retval = 0;
			}
		}
		
		if(in_heavyrains())
		{
			int depth = my_location().water_level + numeric_modifier("Water Level");
			depth = max(1,depth);
			depth = min(6,depth);
			float heavyrainsWashChance = (5.0*depth/100);
			if(have_effect($effect[Fishy Whiskers]) > 0)
			{
				heavyrainsWashChance -= 0.1;
			}
			if(equipped_amount($item[fishbone catcher's mitt]) > 0)
			{
				//todo exact rate?
				heavyrainsWashChance -= 0.1;
			}
			retval = retval * (1 - max(0,heavyrainsWashChance));
		}
		
		if(in_wildfire())
		{
			float wildfireBurnChance;
			switch(my_location().fire_level)
			{
				case 5:
					wildfireBurnChance = 1;
				case 4:
					wildfireBurnChance = 0.768;
				case 3:
					wildfireBurnChance = 0.361;
				case 2:
					wildfireBurnChance = 0.109;
				default:
					wildfireBurnChance = 0;
			}
			retval = retval * (1 - wildfireBurnChance);
		}
		
		if(my_familiar() == $familiar[Black Cat])
		{
			//todo actual chance to lose drop?
			retval = retval * 0.75;
		}
		else if(my_familiar() == $familiar[O.A.F.])
		{
			//todo actual chance to lose drop?
			retval = retval * 0.75;
		}
	}
	
	return max(0,retval);
}

boolean[effect] ATSongList()
{
	// This List contains ALL AT songs in order from Most to Least Important as to determine what effect to shrug off.
	boolean[effect] songs = $effects[
		Inigo\'s Incantation of Inspiration,
		The Ballad of Richie Thingfinder,
		Chorale of Companionship,
		Ode to Booze,
		Ur-Kel\'s Aria of Annoyance,
		Carlweather\'s Cantata of Confrontation,
		The Sonata of Sneakiness,
		Fat Leon\'s Phat Loot Lyric,
		Polka of Plenty,
		Psalm of Pointiness,
		Aloysius\' Antiphon of Aptitude,
		Paul\'s Passionate Pop Song,
		Donho\'s Bubbly Ballad,
		Prelude of Precision,
		Elron\'s Explosive Etude,
		Benetton\'s Medley of Diversity,
		Dirge of Dreadfulness (Remastered),
		Dirge of Dreadfulness,
		Stevedave\'s Shanty of Superiority,
		Brawnee\'s Anthem of Absorption,
		Jackasses\' Symphony of Destruction,
		Power Ballad of the Arrowsmith,
		Cletus\'s Canticle of Celerity,
		Cringle\'s Curative Carol,
		The Magical Mojomuscular Melody,
		The Moxious Madrigal,
	];

	return songs;
}

void shrugAT()
{
	shrugAT($effect[none]);
}

void shrugAT(effect anticipated)
{
	if(is_boris() || is_jarlsberg() || is_pete() || isActuallyEd() || in_darkGyffte() || in_plumber())
	{
		return;
	}

	//If you think we are handling song overages, you are cray cray....
	if(have_effect(anticipated) > 0)
	{
		//We have the effect, we do not need to shrug it, just let it propagate.
		return;
	}
	
	if(!auto_have_skill(to_skill(anticipated)))
	{	//We don't know that song anyway
		return;
	}

	int maxSongs = 3;
	if(have_equipped($item[Brimstone Beret]) || have_equipped($item[Operation Patriot Shield]) || have_equipped($item[Plexiglass Pendant]) || have_equipped($item[Scandalously Skimpy Bikini]) || have_equipped($item[Sombrero De Vida]) || have_equipped($item[Super-Sweet Boom Box]))
	{
		maxSongs = 4;
	}

	if(have_equipped($item[La Hebilla del Cintur&oacute;n de Lopez]))
	{
		maxSongs += 1;
	}
	if(have_equipped($item[Zombie Accordion]))
	{
		maxSongs += 1;
	}
	if(auto_have_skill($skill[Mariachi Memory]))
	{
		maxSongs += 1;
	}

	int count = 1;
	
	effect last = $effect[none];
	foreach ATsong in ATSongList()
	{
		if(have_effect(ATsong) > 0)
		{
			count += 1;
			if(count > maxSongs)
			{
				auto_log_info("Shrugging song: " + ATsong, "blue");
				uneffect(ATsong);
			}
		}
	}
	auto_log_info("I think we're good to go to apply " + anticipated, "blue");
}

boolean acquireTransfunctioner()
{
	if(available_amount($item[Continuum Transfunctioner]) > 0)
	{
		return false;
	}
	if(!zone_isAvailable($location[The Spooky Forest]))
	{
		return false;
	}
	//From Bale\'s Woods.ash
	visit_url("place.php?whichplace=forestvillage&action=fv_mystic");
	visit_url("choice.php?pwd="+my_hash()+"&whichchoice=664&option=1&choiceform1=Sure%2C+old+man.++Tell+me+all+about+it.");
	visit_url("choice.php?pwd="+my_hash()+"&whichchoice=664&option=1&choiceform1=Against+my+better+judgment%2C+yes.");
	visit_url("choice.php?pwd="+my_hash()+"&whichchoice=664&option=1&choiceform1=Er,+sure,+I+guess+so...");
	visit_url("place.php?whichplace=forestvillage&preaction=screwquest&action=fv_untinker_quest");

	return true;
}

int [item] auto_get_campground()
{
	//Wrapper for get_campground(), primarily deals with the oven issue in Ed.
	//Also uses Garden item as identifier for the garden in addition to what get_campground() does
	
	if (isActuallyEd())
	{
		int [item] empty;
		return empty;
	}
	int [item] campItems = get_campground();

	if(campItems contains $item[Ice Harvest])
	{
		campItems[$item[packet of winter seeds]] = 1;
	}
	if(campItems contains $item[Frost Flower])
	{
		campItems[$item[packet of winter seeds]] = 1;
	}
	if(campItems contains $item[handful of barley])
	{
		campItems[$item[packet of beer seeds]] = 1;
	}
	if(campItems contains $item[fancy beer label])
	{
		campItems[$item[packet of beer seeds]] = 1;
	}
	if(campItems contains $item[skeleton])
	{
		campItems[$item[packet of dragon\'s teeth]] = 1;
	}
	if(campItems contains $item[giant candy cane])
	{
		campItems[$item[Peppermint Pip Packet]] = 1;
	}
	if(campItems contains $item[peppermint sprout])
	{
		campItems[$item[Peppermint Pip Packet]] = 1;
	}
	if(campItems contains $item[ginormous pumpkin])
	{
		campItems[$item[packet of pumpkin seeds]] = 1;
	}
	if(campItems contains $item[huge pumpkin])
	{
		campItems[$item[packet of pumpkin seeds]] = 1;
	}
	if(campItems contains $item[pumpkin])
	{
		campItems[$item[packet of pumpkin seeds]] = 1;
	}
	if(campItems contains $item[cornucopia])
	{
		campItems[$item[packet of thanksgarden seeds]] = 1;
	}
	if(campItems contains $item[megacopia])
	{
		campItems[$item[packet of thanksgarden seeds]] = 1;
	}
	if(campItems contains $item[Pok&eacute;-Gro fertilizer])
	{
		campItems[$item[packet of tall grass seeds]] = 1;
	}

	if((campItems contains $item[Source Terminal]) && !get_property("auto_haveSourceTerminal").to_boolean())
	{
		set_property("auto_haveSourceTerminal", true);
	}

	static boolean didCheck = false;
	if(in_nuclear() && !didCheck)
	{
		didCheck = true;
		string temp = visit_url("place.php?whichplace=falloutshelter&action=vault_term");
		if(contains_text(temp, "Source Terminal"))
		{
			set_property("auto_haveSourceTerminal", true);
		}
	}

	if(!(campItems contains $item[Dramatic&trade; range]) && get_property("auto_haveoven").to_boolean())
	{
		campItems[$item[Dramatic&trade; range]] = 1;
	}
	if(!(campItems contains $item[Source Terminal]) && get_property("auto_haveSourceTerminal").to_boolean())
	{
		campItems[$item[Source Terminal]] = 1;
	}

	return campItems;
}

location solveDelayZone()
{
	int[location] delayableZones = zone_delayable();
	int amt = count(delayableZones);
	location burnZone = $location[none];
	if (count(delayableZones) != 0) {
		// find the delayable zone with the lowest delay left.
		foreach loc, delay in delayableZones {
			if (burnZone == $location[none] || delay < delayableZones[burnZone]) {
				burnZone = loc;
			}
			if (loc == $location[The Spooky Forest] && delay == delayableZones[burnZone])
			{
				// prioritise the Spooky Forest when its delay remaining equals the lowest delay zone
				burnZone = loc;
			}
		}
	}

	if(burnZone != $location[none])
	{
		return burnZone;
	}

	// These are locations that aren't 1:1 turn savings, but can still be useful

	// Shorten the time before finding Gnasir, so that we can start acquiring desert pages sooner
	if(zone_isAvailable($location[The Arid\, Extra-Dry Desert]) && $location[The Arid\, Extra-Dry Desert].turns_spent >= 1 && $location[The Arid\, Extra-Dry Desert].turns_spent < 10)
	{
		burnZone = $location[The Arid\, Extra-Dry Desert];
	}

	// Shorten the time until the first "burn a food or drink" noncombat
	// There's some opportunity to be clever here, but this is probably good enough.
	// If we didn't check turns_spent we'd have to be careful to equip the war outfit,
	// just in case the noncombat shows up.
	if(in_koe() && $location[The Exploaded Battlefield].turns_spent < 5)
	{
		burnZone = $location[The Exploaded Battlefield];
	}

	if(in_lowkeysummer())
	{
		burnZone = lowkey_nextAvailableKeyDelayLocation();
	}

	return burnZone;
}

boolean allowSoftblockDelay()
{
	return get_property("auto_delayLastLevel").to_int() < my_level();
}

boolean setSoftblockDelay()
{
	auto_log_warning("I was trying to avoid delay zones, but I've run out of stuff to do. Releasing softblock.", "red");
	set_property("auto_delayLastLevel", my_level());
	return true;
}

boolean canBurnDelay(location loc)
{
	// TODO: Add Digitize (Portscan?) & LOV Enamorang
	if (!zone_delay(loc)._boolean || !allowSoftblockDelay())
	{
		return false;
	}
	if (auto_haveBackupCamera() && auto_backupUsesLeft() > 0)
	{
		return true;
	}
	else if (auto_haveKramcoSausageOMatic() && auto_sausageFightsToday() < 9)
	{
		return true;
	}
	else if (auto_haveVotingBooth() && get_property("_voteFreeFights").to_int() < 3)
	{
		return true;
	}
	else if (my_daycount() < 2 && (auto_haveVotingBooth() || auto_haveKramcoSausageOMatic() || auto_haveBackupCamera()))
	{
		return true;
	}
	return false;
}

boolean auto_is_valid(item it)
{
	if(!glover_usable(it))
	{
		if(it != $item[Protonic Accelerator Pack])
			return false;
		else if(!expectGhostReport() && !haveGhostReport())
			return false;
	}
	if(it == $item[Grimstone Mask])
	{
		if(!isGuildClass())		//it seems like all non core classes are disallowed. need to spade this to verify if any class is exempt
			return false;
	}
	if(in_bhy())
	{
		return bhy_is_item_valid(it);
	}
	if(my_class() == $class[Pig Skinner]) //want to ignore Red Rocket in PS because Free-For-All is more important
	{
		if(it == $item[Red Rocket]) return false;
	}
	
	return is_unrestricted(it);
}

boolean auto_is_valid(familiar fam)
{
	if(is100FamRun())
	{
		return to_familiar(get_property("auto_100familiar")) == fam;
	}
	return bhy_usable(fam.to_string()) && glover_usable(fam.to_string()) && zombieSlayer_usable(fam) && is_unrestricted(fam);
}

boolean auto_is_valid(skill sk)
{
	//do not check check for B in bees hate you path. it only restricts items and not skills.
	return (glover_usable(sk.to_string()) || sk.passive) && bat_skillValid(sk) && plumber_skillValid(sk) && is_unrestricted(sk);
}

boolean auto_is_valid(effect eff)
{
	return glover_usable(eff.to_string());
}

void auto_log(string s, string color, int log_level)
{
	if(log_level > get_property("auto_log_level").to_int())
	{
		return;
	}
	switch(log_level)
	{
		case 1:
			print("[WARNING] " + s, color);
			break;
		case 2:
			print("[INFO] " + s, color);
			break;
		case 3:
			print("[DEBUG] " + s, color);
			break;
	}
}

void auto_log_error(string s)
{
	print("[ERROR] " +s, "red");
}

void auto_log_warning(string s, string color)
{
	auto_log(s, color, 1);
}

void auto_log_warning(string s)
{
	auto_log(s, "orange", 1);
}

void auto_log_info(string s, string color)
{
	auto_log(s, color, 2);
}

void auto_log_info(string s)
{
	auto_log(s, "blue", 2);
}

void auto_log_debug(string s, string color)
{
	auto_log(s, color, 3);
}

void auto_log_debug(string s)
{
	auto_log(s, "black", 3);
}

boolean auto_can_equip(item it)
{
	return auto_can_equip(it, it.to_slot());
}

boolean auto_can_equip(item it, slot s)
{
	if(s == $slot[shirt] && !hasTorso())
		return false;

	if(s == $slot[off-hand] && it.to_slot() == $slot[weapon] && !auto_have_skill($skill[Double-Fisted Skull Smashing]))
		return false;
	
	if((s == $slot[weapon] || s == $slot[off-hand]) && (in_wotsf() || (is_boris() && it != $item[Trusty])))
		return false;

	if(it.item_type() == "chefstaff" && (!(auto_have_skill($skill[Spirit of Rigatoni]) || (my_class() == $class[Sauceror] && equipped_amount($item[special sauce glove]) > 0) || my_class() == $class[Avatar of Jarlsberg]) || s != $slot[weapon]))
		return false;

	return auto_is_valid(it) && can_equip(it);
}

// Conditionals are formatted as "<condition type>:<data>"
// Multiple conditionals can be added separated by a semicolon (;) with NO SPACES
// Conditionals can be prepended with a ! to indicate that they must be FALSE
// See the switch statement for valid condition types and a description of their data
boolean auto_check_conditions(string conds)
{
	if(conds == "")
		return true;

	string [int] conditions = conds.split_string(";");
	boolean failure = false;

	boolean compare_numbers(int num1, int num2, string comparison)
	{
		switch(comparison)
		{
			case "=":
			case "==":
				return num1 == num2;
			case ">":
				return num1 > num2;
			case "<":
				return num1 < num2;
			case ">=":
				return num1 >= num2;
			case "<=":
				return num1 <= num2;
			default:
				abort('"' + comparison + '" is not a valid comparison operator!');
		}
		return false;
	}

	// does not account for !, the loop does that
	boolean check_condition(string cond)
	{
		matcher m = create_matcher("^(\\w+):(.+)$", cond);
		if(!m.find())
			abort('"' + cond + '" is not proper condition formatting!');
		string condition_type = m.group(1);
		string condition_data = m.group(2);
		switch(condition_type)
		{
			// data: The text name of the class, as used by to_class()
			// You must be the given class
			// As a precaution, autoscend aborts if to_class returns $class[none]
			case "class":
				class req_class = to_class(condition_data);
				if(req_class == $class[none])
					abort('"' + condition_data + '" does not properly convert to a class!');
				return req_class == my_class();
			// data: The text name of the mainstat, as used by to_stat()
			// Your mainstat must be the given stat
			// As a precaution, autoscend aborts if to_stat returns $stat[none]
			case "mainstat":
				stat req_mainstat = to_stat(condition_data);
				if(req_mainstat == $stat[none])
					abort('"' + condition_data + '" does not properly convert to a stat!');
				return req_mainstat == my_primestat();
			// data: The text name of the path, as returned by my_path().name
			// You must be currently on that path
			// No safety checking possible here, so hopefully you don't misspell anything
			case "path":
				return condition_data == my_path().name;
			// data: The int id name of the path, as returned by my_path().id
			// You must be currently on that path
			// As a precaution, autoscend aborts if to_int returns 0
			case "pathid":
				int req_pathid = to_int(condition_data);
				if(req_pathid == 0)
					abort('"' + condition_data + '" does not properly convert to a path id!');
				return req_pathid == my_path().id;
			// data: Text name of the skill, as used by to_skill()
			// You must have the given skill
			// As a precaution, autoscend aborts if to_skill returns $skill[none]
			case "skill":
				skill req_skill = to_skill(condition_data);
				if(req_skill == $skill[none])
					abort('"' + condition_data + '" does not properly convert to a skill!');
				return auto_have_skill(req_skill);
			// data: Text name of the effect, as used by to_effect()
			// You must have at least one turn of the given effect
			// As a precaution, autoscend aborts if to_effect returns $effect[none]
			case "effect":
				effect req_effect = to_effect(condition_data);
				if(req_effect == $effect[none])
					abort('"' + condition_data + '" does not properly convert to an effect!');
				return have_effect(req_effect) > 0;
			// data: <item name><comparison operator><value>
			// The number of that item you have must compare properly
			// As a precaution, autoscend aborts if to_item returns $item[none]
			case "item":
				matcher m5 = create_matcher("([^=<>]+)([=<>]+)(.+)", condition_data);
				if(!m5.find())
					abort('"' + condition_data + '" is not a proper item condition format!');
				item req_item = to_item(m5.group(1));
				if(req_item == $item[none])
					abort('"' + m5.group(1) + '" does not properly convert to an item!');
				return compare_numbers(item_amount(req_item) + equipped_amount(req_item), m5.group(3).to_int(), m5.group(2));
			// data: <value><equal sign separator><item name>
			// The chance of getting the item at the end of the fight from that base drop rate value must be 100
			// As a precaution, autoscend aborts if to_item returns $item[none]
			case "itemdropcapped":
				matcher m7 = create_matcher("([^=<>]+)=(.+)", condition_data);
				if(!m7.find())
					abort('"' + condition_data + '" is not a proper item condition format!');
				item todrop_item = to_item(m7.group(2));
				float base_drop_chance = to_float(m7.group(1));
				if(todrop_item == $item[none])
					abort('"' + m7.group(1) + '" does not properly convert to an item!');
				return (effectiveDropChance(todrop_item,base_drop_chance) >= 100);
			// data: The outfit name as used by have_outfit
			// You must have the given outfit
			// No safety checking here possible, at least not conveniently
			case "outfit":
				return have_outfit(condition_data);
			// data: Text name of the familiar, as used by to_familiar()
			// You must be currently using this familiar
			// As a precaution, autoscend aborts if to_familiar returns $familiar[none]
			// Unless the text is literall "none" (case sensitive)
			case "familiar":
				familiar req_familiar = to_familiar(condition_data);
				if(req_familiar == $familiar[none] && condition_data != "none")
					abort('"' + condition_data + '" does not properly convert to a familiar!');
				return my_familiar() == req_familiar;
			// data: Text name of the familiar, as used by to_familiar()
			// You must own this familiar, and it must be legal
			// As a precaution, autoscend aborts if to_familiar returns $familiar[none]
			case "havefamiliar":
				familiar havefamiliar = to_familiar(condition_data);
				if(havefamiliar == $familiar[none])
					abort('"' + condition_data + '" does not properly convert to a familiar!');
				return auto_have_familiar(havefamiliar);
			// data: Text name of the location, as used by to_location()
			// You must be in this location (if you want to check for elsewhere, temporarily set_location)
			// As a precaution, autoscend aborts if to_location returns $location[none]
			case "loc":
				location req_loc = to_location(condition_data);
				if(req_loc == $location[none])
					abort('"' + condition_data + '" does not properly convert to a location!');
				return my_location() == req_loc;
			// data: <location><comparison operator><integer value>
			// As a precaution, autoscend aborts if to_location returns $location[none]
			case "turnsspent":
				matcher m6 = create_matcher("([^=<>]+)([=<>]+)(.+)", condition_data);
				if(!m6.find())
					abort('"' + condition_data + '" is not a proper turnsspent condition format!');
				location loc = to_location(m6.group(1));
				if(loc == $location[none])
					abort('"' + condition_data + '" does not properly convert to a location!');
				if(!($strings[=,==] contains m6.group(2)))
					return compare_numbers(loc.turns_spent, m6.group(3).to_int(), m6.group(2));
				return loc.turns_spent == m6.group(3).to_int();
			// data: <propname><comparison operator><value>
			// >/</>=/<= only supported for integer properties!
			case "prop":
				matcher m2 = create_matcher("([^=<>]+)([=<>]+)(.+)", condition_data);
				if(!m2.find())
					abort('"' + condition_data + '" is not a proper prop condition format!');
				string prop = get_property(m2.group(1));
				if(!($strings[=,==] contains m2.group(2)))
					return compare_numbers(prop.to_int(), m2.group(3).to_int(), m2.group(2));
				return prop == m2.group(3);
			// data: <propname>
			// gets propname and converts to a boolean
			case "prop_boolean":
				return get_property(condition_data).to_boolean();
			// data: <questpropname><comparison operator><value>
			// like prop, but with > and < and >= and <= and uses internalQuestStatus
			// the value to compare to should always be an integer
			case "quest":
				matcher m3 = create_matcher("([^=<>]+)([=<>]+)(.+)", condition_data);
				if(!m3.find())
					abort('"' + condition_data + '" is not a proper quest condition format!');
				int quest_state = internalQuestStatus(m3.group(1));
				int compare_to = to_int(m3.group(3));
				return compare_numbers(quest_state, compare_to, m3.group(2));
			// data: Text name of the monster, as used by to_monster()
			// True if that monster has been sniffed by any olfaction-like
			// As a precaution, autoscend will abort if to_monster returns $monster[none]
			case "sniffed":
				monster check_sniffed = to_monster(condition_data);
				if(check_sniffed == $monster[none])
					abort('"' + condition_data + '" does not properly convert to a monster!');
				if(have_effect($effect[On The Trail]) > 0 && get_property("olfactedMonster").to_monster() == check_sniffed)
					return true;
				if(isActuallyEd() && get_property("stenchCursedMonster").to_monster() == check_sniffed)
					return true;
				if(is_pete() && get_property("makeFriendsMonster").to_monster() == check_sniffed)
					return true;
				if($classes[Cow Puncher, Beanslinger, Snake Oiler] contains my_class() && get_property("longConMonster").to_monster() == check_sniffed)
					return true;
				if(in_darkGyffte() && get_property("auto_bat_soulmonster").to_monster() == check_sniffed)
					return true;
				if(get_property("_gallapagosMonster").to_monster() == check_sniffed)
					return true;
				if(get_property("_latteMonster").to_monster() == check_sniffed)
					return true;
				if(get_property("motifMonster").to_monster() == check_sniffed)
					return true;
				return false;
			// data: Doesn't matter, but put something so I don't have to support dataless conditions
			// True when you expect a protonic ghost report
			// Pretty much just for the protonic accelerator pack
			case "expectghostreport":
				return expectGhostReport();
			// data: Doesn't matter, but put something so I don't have to support dataless conditions
			// True when there is a latte unlock available in the area (that you don't have, of course)
			// Pretty much just for the latte
			case "latte":
				return auto_latteDropAvailable(my_location());
			// data: Doesn't matter, but put something so I don't have to support dataless conditions
			// True if the hidden tavern has been unlocked this ascension
			case "tavern":
				return get_property("hiddenTavernUnlock").to_int() >= my_ascensions();
			// data: The number of sgeeas you want to have
			// True if you have at least that many sgeeas at your disposal
			case "sgeea":
				int sgeeas = to_int(condition_data);
				return item_amount($item[soft green echo eyedrop antidote]) >= sgeeas;
			// data: The day to check for
			// True if we are currently on that day
			case "day":
				int day = to_int(condition_data);
				return my_daycount() == day;
			case "ML":
				matcher m4 = create_matcher("([=<>]+)(.+)", condition_data);
				if(!m4.find())
					abort('"' + condition_data + '" is not a proper ML condition format!');
				return compare_numbers(monster_level_adjustment(), to_int(m4.group(2)), m4.group(1));
			// data: eat\drink\chew
			// True if we can eat\drink\chew anything today
			case "consume":
				switch (condition_data)
				{
					case "eat": return fullness_left() > 0;
					case "drink": return inebriety_left() > 0;
					case "chew": return spleen_left() > 0;
					default:
						abort('Invalid consume type "' + condition_type + '" found!');
				}
			default:
				abort('Invalid condition type "' + condition_type + '" found!');
		}
		return false;
	}

	foreach i, cond in conditions
	{
		matcher m = create_matcher("^(!?)(.+)$", cond);
		if(!m.find())
			abort('"' + cond + '" is not a proper condition!');
		boolean invert = m.group(1) == "!";
		boolean success = check_condition(m.group(2));

		if(success == invert)
			return false;
	}

	return true;
}

boolean [monster] auto_getMonsters(string category)
{
	boolean [monster] res;
	string [string,int,string] monsters_text;
	if(!file_to_map("autoscend_monsters.txt", monsters_text))
		auto_log_error("Could not load autoscend_monsters.txt. This is bad!");
	foreach i,name,conds in monsters_text[category]
	{
		monster thisMonster = name.to_monster();
		if(thisMonster == $monster[none])
		{
			auto_log_warning('"' + name + '" does not convert to a monster properly!', "red");
			continue;
		}
		if(!auto_check_conditions(conds))
			continue;
		res[thisMonster] = true;
	}
	return res;
}

boolean auto_wantToSniff(monster enemy, location loc)
{
	location locCache = my_location();
	set_location(loc);
	boolean [monster] toSniff = auto_getMonsters("sniff");
	if(toSniff[enemy] && appearance_rates(loc)[enemy] < 100)
	{
		set_location(locCache);
		return true;
	}
	set_location(locCache);
	return false;
}

boolean auto_wantToYellowRay(monster enemy, location loc)
{
	location locCache = my_location();
	set_location(loc);
	boolean [monster] toSniff = auto_getMonsters("yellowray");
	set_location(locCache);
	return toSniff[enemy];
}

boolean auto_wantToReplace(monster enemy, location loc)
{
	location locCache = my_location();
	set_location(loc);
	boolean [monster] toReplace = auto_getMonsters("replace");
	set_location(locCache);
	return toReplace[enemy];
}

int total_items(boolean [item] items)
{
	int total = 0;
	foreach it in items
	{
		total += item_amount(it);
	}
	return total;
}

boolean auto_badassBelt()
{
	if ((item_amount($item[Batskin Belt]) > 0 || equipped_amount($item[Batskin Belt]) > 0) && (item_amount($item[Skull of the Bonerdagon]) > 0 || equipped_amount($item[Skull of the Bonerdagon]) > 0))
	{
		if (have_equipped($item[Skull of the Bonerdagon]))
		{
			equip($slot[off-hand], $item[none]);
		}
		if (have_equipped($item[Batskin Belt]))
		{
			if (equipped_item($slot[acc1]) == $item[Batskin Belt])
			{
				equip($slot[acc1], $item[none]);
			}
			else if (equipped_item($slot[acc2]) == $item[Batskin Belt])
			{
				equip($slot[acc2], $item[none]);
			}
			else if (equipped_item($slot[acc3]) == $item[Batskin Belt])
			{
				equip($slot[acc3], $item[none]);
			}
		}
		return create(1, $item[Badass Belt]);
	}
	else
	{
		return false;
	}
}

void auto_interruptCheck(boolean debug)
{
	if(get_property("auto_interrupt").to_boolean())
	{
		set_property("auto_interrupt", false);
		restoreAllSettings();
		abort("auto_interrupt detected and aborting, auto_interrupt disabled.");
	}
	else if (get_property("auto_debugging").to_boolean() && debug)
	{
		set_property("auto_interrupt", true);
		auto_log_info("auto_debugging detected, auto_interrupt enabled.");
	}
}

void auto_interruptCheck()
{
	//we check for interrupt at multiple locations. but we only want to set it once per loop in debug mode.
	auto_interruptCheck(true);
}

element currentFlavour()
{
	if(have_effect($effect[Spirit of Peppermint]) != 0)
	{
		return $element[cold];
	}
	if(have_effect($effect[Spirit of Bacon Grease]) != 0)
	{
		return $element[sleaze];
	}
	if(have_effect($effect[Spirit of Garlic]) != 0)
	{
		return $element[stench];
	}
	if(have_effect($effect[Spirit of Cayenne]) != 0)
	{
		return $element[hot];
	}
	if(have_effect($effect[Spirit of Wormwood]) != 0)
	{
		return $element[spooky];
	}

	return $element[none];
}

boolean setFlavour(element ele)
{
	if(!auto_have_skill($skill[Flavour of Magic]))
	{
		return false;
	}
	set_property("_auto_tunedElement", ele);
	return true;
}

boolean executeFlavour()
{
	if(!auto_have_skill($skill[Flavour of Magic]))
	{
		return false;
	}

	if(get_property("_auto_tunedElement") == "")
	{
		autoFlavour(my_location());
	}
	if(get_property("_auto_tunedElement") == "")
	{
		return false;
	}
	element ele = get_property("_auto_tunedElement").to_element();
	if(ele != currentFlavour())
	{
		switch(ele)
		{
			case $element[none]:
				return use_skill(1, $skill[Spirit of Nothing]);
			case $element[hot]:
				return use_skill(1, $skill[Spirit of Cayenne]);
			case $element[cold]:
				return use_skill(1, $skill[Spirit of Peppermint]);
			case $element[stench]:
				return use_skill(1, $skill[Spirit of Garlic]);
			case $element[spooky]:
				return use_skill(1, $skill[Spirit of Wormwood]);
			case $element[sleaze]:
				return use_skill(1, $skill[Spirit of Bacon Grease]);
		}
	}

	return true;
}

boolean autoFlavour(location place)
{
	if(!auto_have_skill($skill[Flavour of Magic]))
	{
		return false;
	}

	switch(place)
	{
		case $location[Hobopolis Town Square]:
			// don't mess with scare hobos
			return false;
		case $location[dreadsylvanian woods]:
		case $location[dreadsylvanian castle]:
		case $location[dreadsylvanian village]:
			// dread is complicated
			return setFlavour($element[none]);
	}

	if(in_ocrs())
	{
		// monsters can randomly be any element in OCRS
		setFlavour($element[none]);
		return true;
	}

	switch(place)
	{
		case $location[The Ancient Hobo Burial Ground]: // Everything here is immune to elemental damage
			setFlavour($element[none]);
			return true;
		case $location[The Ice Hotel]:
			if(get_property("walfordBucketItem") == "rain" && equipped_item($slot[off-hand]) == $item[Walford\'s bucket])
			{
				setFlavour($element[hot]); // doing 100 hot damage in a fight will fill bucket faster
				return true;
			}
			// INTENTIONAL LACK OF BREAK
		case $location[VYKEA]:
			if(get_property("walfordBucketItem") == "ice" && equipped_item($slot[off-hand]) == $item[Walford\'s bucket])
			{
				setFlavour($element[cold]);
				return true;
			}
			break;
	}

	float [element] superEffective;
	boolean [element] perfect;
	float [element] ineffective;

	foreach ele in $elements[cold, hot, sleaze, spooky, stench, none]
	{
		superEffective[ele] = 0;
		ineffective[ele] = 0;
		perfect[ele] = true;
	}

	boolean [element] weaknesses(element ele)
	{
		switch(ele)
		{
			case $element[cold]: return $elements[hot, spooky];
			case $element[spooky]: return $elements[hot, stench];
			case $element[hot]: return $elements[stench, sleaze];
			case $element[stench]: return $elements[sleaze, cold];
			case $element[sleaze]: return $elements[cold, spooky];
			default: return $elements[none];
		}
	}

	void handle_monster(monster mon, float chance)
	{
		if(chance == 0 || mon == $monster[none])
			return;

		foreach ele in $elements[cold, hot, sleaze, spooky, stench]
		{
			if(ele == monster_element(mon))
				ineffective[ele] += chance;

			if(weaknesses(monster_element(mon)) contains ele)
			{
				superEffective[ele] += chance;
			}
			else
			{
				perfect[ele] = false;
			}
		}
	}

	foreach mon,chance in appearance_rates(place, true)
	{
		handle_monster(mon, chance);
	}

	if(equipped_amount($item[Kramco Sausage-o-Matic&trade;]) > 0)
	{
		handle_monster($monster[sausage goblin], 0.5);
	}

	element flavour = $element[none];
	float bestScore = -1;
	float bestSpellDamage = -99999;

	foreach ele in $elements[cold, hot, sleaze, spooky, stench]
	{
		float spellDamage = numeric_modifier(ele.to_string() + " Spell Damage");
		float scoreDiff = superEffective[ele] - bestScore;
		scoreDiff = scoreDiff < 0 ? -scoreDiff : scoreDiff;
		if(ineffective[ele] == 0 && ((superEffective[ele] > bestScore) || (scoreDiff < 0.00001  && spellDamage > bestSpellDamage)))
		{
			flavour = ele;
			bestScore = superEffective[ele];
			bestSpellDamage = spellDamage;
		}
	}

	return setFlavour(flavour);
}

boolean canSimultaneouslyAcquire(int[item] needed)
{
	// The Knapsack solver can provide invalid solutions - for example, if we
	// have 2 perfect ice cubes and 6 organ space, it might suggest two distinct
	// perfect drinks.
	// Checks that a set of items isn't impossible to acquire because of
	// conflicting crafting dependencies.

	int[item] alreadyUsed;
	int meatUsed;

	boolean failed = false;
	void addToAlreadyUsed(int amount, item toAdd)
	{
		int needToCraft = alreadyUsed[toAdd] + amount - item_amount(toAdd);
		alreadyUsed[toAdd] += amount;
		if(needToCraft > 0)
		{
			if(get_property("autoSatisfyWithStorage").to_boolean() && pulls_remaining() == -1)
			{
				return;
			}
			if (count(get_ingredients(toAdd)) == 0 && npc_price(toAdd) == 0 && buy_price($coinmaster[hermit], toAdd) == 0)
			{
				// not craftable
				auto_log_warning("canSimultaneouslyAcquire failing on " + toAdd, "red");
				failed = true;
			}
			else if (npc_price(toAdd) > 0)
			{
				meatUsed += npc_price(toAdd);
			}

			foreach ing,ingAmount in get_ingredients(toAdd)
			{
				addToAlreadyUsed(ingAmount * needToCraft, ing);
			}
		}
	}

	foreach it, amt in needed
	{
		addToAlreadyUsed(amt, it);
	}

	return !failed && meatUsed <= my_meat();
}

boolean[int] knapsack(int maxw, int n, int[int] weight, float[int] val)
{
	/*
	 * standard implementation of 0-1 Knapsack problem with dynamic programming
	 * Time complexity: O(maxw * n)
	 * For 16k items on a 2017 laptop, took about 5 seconds and 60Mb of RAM
	 *
	 * Parameters:
	 *   maxw is the desired sum-of-weights (e.g. fullness_left())
	 *   n is the number of elements
	 *   weight is the (e.g. a map from i=1..n => fullness of i-th food)
	 *   val is the value to maximize (e.g. a map from i=1..n => adventures of i-th food)
	 * Returns: a set of indices that were taken
	 */

	boolean[int] empty;

	if(n*maxw >= 100000)
	{
		auto_log_warning("Solving a Knapsack instance with " + n + " elements and " + maxw + " total weight, this might be slow and memory-intensive.");
	}

	/* V[i][w] is "with only the first i items, what is the maximum
	 * sum-of-vals we can generate with total weight w?
	 */
	float [int][int] V;

	for (int i = 0; i <= n; i++)
	{
		for (int w = 0; w <= maxw; w++)
		{
			if (i==0 || w==0)
				V[i][w] = 0;
			else if (weight[i-1] <= w)
				V[i][w] = max(val[i-1] + V[i-1][w-weight[i-1]], V[i-1][w]);
			else
				V[i][w] = V[i-1][w];
		}
	}

	// Catch unreachable case (e.g. only 2-fullness foods, targeting 15 stomach)
	if (V[n][maxw] == 0.0)
	{
		return empty;
	}

	boolean[int] ret;
	// backtrack
	int i = n;
	int w = maxw;
	while (i > 0 || w > 0)
	{
		if(i < 0) return empty;
		// Did this item change our mind about how many adventures we could generate?
		// If so, we took this item.
		if (V[i][w] != V[i-1][w])
		{
			ret[i-1] = true;
			w -= weight[i-1];
			i -= 1;
		}
		else
		{
			// do not take element
			i -= 1;
		}
	}
	// This can be somewhat memory-intensive.
	// I'm not sure if this actually does anything, but it makes me feel better.
	cli_execute("gc");
	return ret;
}

int auto_reserveAmount(item it)
{
	string [string,int,string] itemdata;
	if(!file_to_map("autoscend_items.txt", itemdata))
		auto_log_error("Could not load autoscend_items.txt! This is bad!");
	foreach i,counteditem,conds in itemdata["reserve"]
	{
		matcher m = create_matcher("(\\-?\\d+) (.+)", counteditem);
		if(!m.find())
		{
			auto_log_warning('"' + counteditem + '" is not in the format "# itemname"!', "red");
			continue;
		}
		item curr = m.group(2).to_item();
		if(curr == $item[none])
		{
			auto_log_warning('"' + m.group(2) + '" does not convert to an item properly!', "red");
			continue;
		}
		if(curr != it)
			continue;
		if(!auto_check_conditions(conds))
			continue;
		return m.group(1).to_int();
	}
	return 0;
}

int auto_reserveCraftAmount(item orig_it)
{
	// Detect infinite loops
	boolean [item] its;

	int inner(item it)
	{
		if (its contains it)
		{
			auto_log_warning("Found dependency loop involving " + it + " when trying to craft " + orig_it + ", consider adding to reserve list.", "red");
			auto_log_warning("Dependencies (in no particular order):", "red");
			foreach iit in its
			{
				auto_log_warning("> " + iit, "red");
			}
			return 9999999;
		}
		its[it] = true;
		int reserve = 0;
		foreach ing,amt in get_ingredients(it)
		{
			int ingReserve = auto_reserveAmount(ing);
			if(ingReserve == -1)
			{
				return 0;
			}
			else if(ingReserve == 0)
			{
				ingReserve = inner(ing);
			}
			if(ingReserve * amt > reserve)
			{
				reserve = ingReserve * amt;
			}
		}
		remove its[it];
		return reserve;
	}
	return inner(orig_it);
}



// ML MANAGEMENT FUNCTIONS
// Gives us the number we need when comparing to a desired ML or entering a value into a maximizer string.
int auto_convertDesiredML(int DML)
{
	int DesiredML = get_property("auto_MLSafetyLimit").to_int();

	if(get_property("auto_MLSafetyLimit") == "")
	{
		DesiredML = DML;
	}

	return DesiredML;
}

// Uses MCD in the constraints of a Cap
boolean auto_setMCDToCap()
{
	int targetMcd = 0;

	if(get_property("auto_MLSafetyLimit") == "")
	{
		// No ML limit was given, so use the max MCD value
		targetMcd = 11;
	}
	else
	{
		// monster_level_adjustment includes the current MCD value, so it must be removed before calculating the new MCD
		int currentMlWithoutMcd = monster_level_adjustment() - current_mcd();
		int mlSafetyLimit = get_property("auto_MLSafetyLimit").to_int();

		if(currentMlWithoutMcd < mlSafetyLimit)
		{
			// ML is below the cap. Add as much ML with the MCD as possible without exceeding the cap.
			targetMcd = mlSafetyLimit - currentMlWithoutMcd;
		}
		else
		{
			// ML is already at the cap or exceeded it. Don't add any more ML with the MCD.
			targetMcd = 0;
		}
	}

	return auto_change_mcd(targetMcd);
}

// We use this function to determine the suitability of using Ur-Kel's
boolean UrKelCheck(int UrKelToML, int UrKelUpperLimit, int UrKelLowerLimit)
{
	if(!auto_have_skill($skill[Ur-Kel\'s Aria of Annoyance]))
	{
		return false;
	}

	if((have_effect($effect[Ur-Kel\'s Aria of Annoyance]) == 0) && ((monster_level_adjustment() + (2 * my_level())) <= auto_convertDesiredML(UrKelToML)))
	{
		if((get_property("auto_MLSafetyLimit") == "") || (((2 * my_level()) <= UrKelUpperLimit) && ((2 * my_level()) >= UrKelLowerLimit)))
		{
			shrugAT($effect[Ur-Kel\'s Aria of Annoyance]);
			buffMaintain($effect[Ur-Kel\'s Aria of Annoyance], 0, 1, 10);
		}
	}

	return true;
}

// We use this function to determine the suitability of using angry agates
boolean angryAgateCheck(int angryAgateToML, int angryAgateUpperLimit, int angryAgateLowerLimit)
{
	if(item_amount($item[angry agate]) == 0 || !auto_is_valid($item[angry agate]))
	{
		return false;
	}

	if((have_effect($effect[misplaced rage]) == 0) && ((monster_level_adjustment() + (3 * my_level())) <= auto_convertDesiredML(angryAgateToML)))
	{
		if((get_property("auto_MLSafetyLimit") == "") || (((3 * my_level()) <= angryAgateUpperLimit) && ((3 * my_level()) >= angryAgateLowerLimit)))
		{
			uneffect($effect[misplaced rage]);
			buffMaintain($effect[misplaced rage]);
		}
	}

	return true;
}

// Handle intelligently increasing ML for both pre-adv and in Quests
//	doAltML is a variable that will be referenced when increasing ML via alternative methods such as Asdon Martin, they should be entered in their respective order
//		Ur-kel's may need new entries in this case due to its variance
boolean auto_MaxMLToCap(int ToML, boolean doAltML)
{
	void tryEffects(boolean [effect] effects)
	{
		foreach eff in effects
		{
			if(monster_level_adjustment() + numeric_modifier(eff, "Monster Level") <= auto_convertDesiredML(ToML))
			{
				buffMaintain(eff);
			}
		}
	}

// ToML >= U >= 30
	UrKelCheck(ToML, auto_convertDesiredML(ToML), 30);
	angryAgateCheck(ToML, auto_convertDesiredML(ToML), 30);

// 30
	// Start with the biggest and drill down for max ML
	tryEffects($effects[Ceaseless Snarling, Punchable Face, Zomg WTF]);

// 29 >= U >= 25
	UrKelCheck(ToML, 29, 25);
	angryAgateCheck(ToML, 29, 25);



// 25
	if((doAltML) && ((monster_level_adjustment() + 25) <= auto_convertDesiredML(ToML)))
	{
		asdonBuff($effect[Driving Recklessly]);
	}
	if(doAltML)
	{
		tryEffects($effects[Litterbug, Sweetbreads Flamb&eacute;]);
	}


// 24 >= U >= 10
	UrKelCheck(ToML, 24, 10);
	angryAgateCheck(ToML, 24, 10);

// 20
	if (isActuallyEd() && !get_property("auto_needLegs").to_boolean())
	{
		tryEffects($effects[Blessing of Serqet]);
	}

// 10
	tryEffects($effects[Pride of the Puffin, Drescher's Annoying Noise]);
	if(doAltML)
	{
		tryEffects($effects[Tortious]);
	}

// <10
	//If we can't get 10 turns of Ur-Kel's, and we aren't being forced to pile on the ML, it probably isn't worth it.
	if((doAltML) || (auto_predictAccordionTurns() >= 10))
	{
		UrKelCheck(ToML, 9, 2);
	}
	angryAgateCheck(ToML, 9, 3);

// Customizable - For variable effects that we can use to fill in the corners
	// Fill in the remainder with MCD
	if (!($locations[The Boss Bat\'s Lair, Haert of the Cyrpt, Throne Room] contains my_location()))
	{
	  auto_setMCDToCap();
	}

	return true;
}


// ADVENTURE FORCING FUNCTIONS
boolean _auto_forceNextNoncombat(location loc, boolean speculative)
{
	// Use stench jelly or other item to set the combat rate to zero until the next noncombat.

	boolean ret = false;
	if(auto_pillKeeperFreeUseAvailable())
	{
		if(speculative) return true;
		ret = auto_pillKeeper("noncombat");
		if(ret) {
			set_property("auto_forceNonCombatSource", "pillkeeper");
		}
	}
	else if(!get_property("_claraBellUsed").to_boolean() && (item_amount($item[Clara\'s Bell]) > 0) && auto_is_valid($item[Clara\'s Bell]))
	{
		if(speculative) return true;
		ret = use(1, $item[Clara\'s Bell]);
		if(ret) {
			set_property("auto_forceNonCombatSource", "clara's bell");
		}
	}
	else if(auto_hasParka() && get_property("_spikolodonSpikeUses") < 5 && hasTorso())
	{
		if(speculative) return true;
		// parka spikes require a combat to active
		// this property will cause the parka to be eqipped and spikes deployed next combat
		set_property("auto_forceNonCombatSource", "jurassic parka");
		// track desired NC location so we know where to go when parka spikes are preped
		set_property("auto_forceNonCombatLocation", loc);
		ret = true;
	}
	else if(item_amount($item[stench jelly]) > 0 && auto_is_valid($item[stench jelly]) && !isActuallyEd()
		&& spleen_left() >= $item[stench jelly].spleen)
	{
		if(speculative) return true;
		ret = autoChew(1, $item[stench jelly]);
		if(ret) {
			set_property("auto_forceNonCombatSource", "stench jelly");
		}
	}
	else if(auto_pillKeeperAvailable() && !isActuallyEd() && spleen_left() >= 3) // don't use Spleen as Ed, it's his main source of adventures.
	{
		if(speculative) return true;
		ret = auto_pillKeeper("noncombat");
		if(ret) {
			set_property("auto_forceNonCombatSource", "pillkeeper");
		}
	}

	if(ret)
	{
		set_property("auto_forceNonCombatTurn", my_turncount());
	}
	return ret;
}

boolean auto_canForceNextNoncombat()
{
	return _auto_forceNextNoncombat($location[none], true);
}

boolean _auto_forceNextNoncombat(location loc)
{
	return _auto_forceNextNoncombat(loc, false);
}

boolean auto_forceNextNoncombat(location loc)
{
	if(auto_haveQueuedForcedNonCombat())
	{
		auto_log_warning("Trying to force a noncombat adventure, but I think we've already forced one...", "red");
		return true;
	}
	if (_auto_forceNextNoncombat(loc))
	{	
		string forceNCMethod = get_property("auto_forceNonCombatSource");
		if(forceNCMethod == "jurassic parka")
		{
			auto_log_info("Next noncombat adventure will be forced with " + forceNCMethod, "blue");
		}
		else
		{
			auto_log_info("Next noncombat adventure has been forced with " + forceNCMethod, "blue");
		}
		return true;
	}
	return false;
}

boolean auto_haveQueuedForcedNonCombat()
{
	// This isn't always reset properly: see __MONSTERS_FOLLOWING_NONCOMBATS in auto_post_adv.ash
	string forceNCMethod = get_property("auto_forceNonCombatSource");
	if(forceNCMethod == "")
	{
		return false;
	}
	// if going to force with parka, but spikes haven't been deployed return false
	if(forceNCMethod == "jurassic parka" && !get_property("auto_parkaSpikesDeployed").to_boolean())
	{
		return false;
	}
	// for all other sources, simply return true
	return true;
}

boolean is_expectedForcedNonCombat(string encounterName)
{
	static boolean[string] expectedNCs = $strings[
		// dark neck of the woods
		How Do We Do It? Quaint and Curious Volume!,
		Strike One!,
		Olive My Love To You\, Oh.,
		The Oracle Will See You Now,
		Dodecahedrariffic!,

		// dark elbow of the woods
		Deep Imp Act,
		Imp Art\, Some Wisdom,
		A Secret\, But Not the Secret You're Looking For,
		Butter Knife? I'll Take the Knife,

		// dark heart of the woods
		Moon Over the Dark Heart,
		Running the Lode,
		I\, Martin,
		Imp Be Nimble\, Imp Be Quick,

		// The Castle in the Clouds in the Sky (Basement)
		You Don't Mess Around with Gym,
		Out in the Open Source,
		The Fast and the Furry-ous,

		// The Castle in the Clouds in the Sky (Top Floor)
		Copper Feel,
		Melon Collie and the Infinite Lameness,
		Yeah\, You're for Me\, Punk Rock Giant,
		Flavor of a Raver,

		// The Haunted Billiards Room
		Welcome To Our ool Table,

		// The Haunted Bathroom
		Never Gonna Make You Up,
		Having a Medicine Ball,
		Bad Medicine is What You Need,

		// The Black Forest
		All Over the Map,
		You Found Your Thrill,
		The Blackest Smith,
		Be Mine,
		Sunday Black Sunday,

		// The Hidden Apartment Building
		Action Elevator,

		// The Hidden Office Building
		Working Holiday,
	];
	return expectedNCs contains encounterName;
}
boolean is_superlikely(string encounterName)
{
	static boolean[string] __SUPERLIKELIES = $strings[
		Code Red,
		Screwdriver\, wider than a mile.,
		The Manor in Which You're Accustomed
		That's your cue
		Polo Tombstone,
		The Oracle Will See You Now,
		A Man in Black,
		Fitting In,
		You\, M.D.,
		We'll All Be Flat,
		Rod Nevada\, Vendor,
		Last Egg Gets Al,
		Do Geese See God?,
		Drawn Onward,
		Mr. Alarm\, I Presarm,
		Mega Gem,
		Dr. Awkward,
		Whee!,
		Adventurer\, $1.99,
		They Tried and Pailed,
		Brushed Off...,
		Shoe of Many Colors,
		Highway to Hey Deze,
	];
	return __SUPERLIKELIES contains encounterName;

}

// Function to Predict how many turns we will get from an AT buff
int auto_predictAccordionTurns()
{
	// List of all Accordions for AT usage
	boolean[item] All_Accordions = $items[accord ion, accordion file, Accordion of Jordion, Aerogel accordion, Antique accordion, accordionoid rocca, alarm accordion, autocalliope, bal-musette accordion, baritone accordion, beer-battered accordion, bone bandoneon, cajun accordion, calavera concertina, ghost accordion, guancertina, mama\'s squeezebox, non-Euclidean non-accordion, peace accordion, pentatonic accordion, pygmy concertinette, quirky accordion, Rock and Roll Legend, Shakespeare\'s Sister\'s Accordion, skipper\'s accordion, squeezebox of the ages, stolen accordion, the trickster\'s trikitixa, toy accordion, warbear exhaust manifold, zombie accordion];
	// List of Accordions that Non-AT classes can use
	boolean[item] NonAT_Accordions = $items[Aerogel accordion, Antique accordion, toy accordion];
	// Choose list to use based on Class
	boolean[item] accordions = (my_class() == $class[accordion thief]) ? All_Accordions : NonAT_Accordions;

	int expTurns = 0;
	int CurrentBestTurns = 0;

	foreach squeezebox in accordions
	{
		// Verify that we have the accordion and that it is allowed to be use in path
		if((equipmentAmount(squeezebox) > 0) && (auto_is_valid(squeezebox)))
		{
			expTurns = numeric_modifier(squeezebox, "Song Duration");

			if(expTurns > CurrentBestTurns)
			{
				CurrentBestTurns = expTurns;
			}
		}
	}

	return CurrentBestTurns;
}

boolean hasTTBlessing()
{
	//do you currently have a turtle blessing active? or if not turtle tamer then the buff?
	
	foreach eff in $effects[
	Blessing of the War Snapper,
	Grand Blessing of the War Snapper,
	Glorious Blessing of the War Snapper,
	Blessing of She-Who-Was,
	Grand Blessing of She-Who-Was,
	Glorious Blessing of She-Who-Was,
	Blessing of the Storm Tortoise,
	Grand Blessing of the Storm Tortoise,
	Glorious Blessing of the Storm Tortoise,
	Disdain of the War Snapper,
	Disdain of She-Who-Was,
	Disdain of the Storm Tortoise
	]
	{
		if(have_effect(eff) > 0)
		{
			return true;
		}
	}
	
	return false;	
}

void effectAblativeArmor(boolean passive_dmg_allowed)
{
	//when facing a boss that has a buff stripping mechanic that is limited on how many can be stripped per round.
	//then load up on as many reasonable buffs as you can taking cost into account.
	//avoid potentially undesireable effects such as +ML.
	//I am pretty sure non combat skills that give an effect count.
	//but I am labeling them seperate from buffs in case we ever need to split this function.
	
	//if you have something that reduces the cost of casting buffs, wear it now.
	maximize("-mana cost, -tie", false);
	
	//Passive damage
	if(passive_dmg_allowed)
	{
		buffMaintain($effect[Spiky Shell]);					//8 MP
		buffMaintain($effect[Jalape&ntilde;o Saucesphere]);	//5 MP
		buffMaintain($effect[Scariersauce]);				//10 MP
		buffMaintain($effect[Scarysauce]);						//10 MP
		if(in_aosol()){
			buffMaintain($effect[Queso Fustulento]);		//10 MP
			buffMaintain($effect[Tricky Timpani]);			//30 MP
		}
	}
	
	//1MP Non-Combat skills from each class
	buffMaintain($effect[Seal Clubbing Frenzy]);
	buffMaintain($effect[Patience of the Tortoise]);
	buffMaintain($effect[Pasta Oneness]);
	buffMaintain($effect[Saucemastery]);
	buffMaintain($effect[Disco State of Mind]);
	buffMaintain($effect[Mariachi Mood]);

	//Seal clubber Non-Combat skills
	buffMaintain($effect[Blubbered Up]);						//7 MP
	buffMaintain($effect[Rage of the Reindeer]);				//10 MP
	buffMaintain($effect[A Few Extra Pounds]);					//10 MP
	
	//Turtle Tamer Non-Combat skills
	if(!hasTTBlessing())
	{
		buffMaintain($effect[Blessing of the War Snapper]);	//15 MP. other blessings too expensive.
	}
	
	//Pastamancer Non-Combat skills
	buffMaintain($effect[Springy Fusilli]);					//10 MP
	buffMaintain($effect[Shield of the Pastalord]);			//20 MP
	buffMaintain($effect[Leash of Linguini]);					//12 MP
	
	//Sauceror Non-Combat skills
	buffMaintain($effect[Sauce Monocle]);						//20 MP

	//Disco Bandit Non-Combat skills
	buffMaintain($effect[Disco Fever]);						//10 MP
	
	//Turtle Tamer Buffs
	buffMaintain($effect[Ghostly Shell]);						//6 MP
	buffMaintain($effect[Tenacity of the Snapper]);			//8 MP
	buffMaintain($effect[Empathy]);							//15 MP
	buffMaintain($effect[Reptilian Fortitude]);				//8 MP
	buffMaintain($effect[Astral Shell]);						//10 MP
	buffMaintain($effect[Jingle Jangle Jingle]);				//5 MP
	buffMaintain($effect[Curiosity of Br\'er Tarrypin]);		//5 MP
	
	//Sauceror Buffs
	buffMaintain($effect[Elemental Saucesphere]);				//10 MP
	buffMaintain($effect[Antibiotic Saucesphere]);				//15 MP
	
	//Accordion Thief Buffs. We are not shrugging so it will only apply new ones if we have space for them
	buffMaintain($effect[The Moxious Madrigal]);				//2 MP
	buffMaintain($effect[The Magical Mojomuscular Melody]);	//3 MP
	buffMaintain($effect[Cletus\'s Canticle of Celerity]);		//4 MP
	buffMaintain($effect[Power Ballad of the Arrowsmith]);		//5 MP
	buffMaintain($effect[Polka of Plenty]);					//7 MP
	
	//Mutually exclusive effects
	if(have_effect($effect[Musk of the Moose]) == 0 && have_effect($effect[Hippy Stench]) == 0)
	{
		buffMaintain($effect[Smooth Movements]);				//10 MP
	}
	if(have_effect($effect[Smooth Movements]) == 0 && have_effect($effect[Fresh Scent]) == 0)
	{
		buffMaintain($effect[Musk of the Moose]);				//10 MP
	}	
	
	//TODO facial expressions, need to check you are not wearing one first and which ones you have
	//Maybe just not do facial expressions? too much complexity for a singular effect.
}

int currentPoolSkill() {
	// format of the cli 'poolskill' command return value is:
	// Pool Skill is estimated at : 12.
	// 0 from equipment, 0 from having 15 inebriety, 2 hustling training and 10 learning from 25 sharks.
	string [int] poolskill_command = split_string(cli_execute_output("poolskill"));
	return substring(poolskill_command[0], poolskill_command[0].last_index_of(":") + 2,  poolskill_command[0].length() - 1).to_int();
}

int poolSkillPracticeGains()
{
	//predict gains from choosing to practice your pool skill (choice 2) in noncombat adv 875 "Welcome To Our ool Table"
	int count = 1;
	if(have_effect($effect[chalky hand]) > 0) count += 1;
	if(equipped_amount($item[[2268]Staff of Fats]) > 0) count += 2;		//note that $item[[7964]Staff of Fats] does not help here.
	return count;
}

boolean hasUsefulShirt()
{
	int amtUsefulShirts = 0;
	foreach it in $items[January\'s Garbage Tote, astral shirt, Shoe ad T-shirt, Fresh coat of paint, tunac, jurassic parka]
	{
		if(item_amount(it) != 0 && is_unrestricted(it)) amtUsefulShirts += 1;
	}
	if(amtUsefulShirts > 0)
	{
		return true;
	}
	else
	{
		return false;
	}
}

int meatReserve()
{
	//the amount of meat we want to reserve for quest usage when performing a restore
	int reserve_extra = 0;		//extra reserved for various reasons
	if(in_kolhs())
	{
		reserve_extra += 100;
	}
	if(in_wildfire() && !get_property("wildfirePumpGreased").to_boolean() && item_amount($item[pump grease]) == 0)
	{
		reserve_extra += npc_price($item[pump grease]);
	}
	if(!hasTorso() && hasUsefulShirt() && !gnomads_available() && inGnomeSign())
	{
		reserve_extra +=5000 * npcStoreDiscountMulti(); //Going to need 5k anyway if we need torso so might as well start saving early. Worst case scenario we make a meatcar
	}
	if(!hasTorso() && gnomads_available() && hasUsefulShirt())
	{
		reserve_extra += 5000; //we want Torso ASAP if we have a useful shirt
	}
	
	if(my_level() < 10)		//meat income is pretty low and the quests that need the reserve far away. Use restores freely
	{
		if(!isDesertAvailable() && inKnollSign() && my_level() > 5 && my_turncount() > 50)
		{		//reason for both level and turncount being checked is that many iotms could level us on turn 1.
			return 500 + reserve_extra;		//reserve some meat for the bitchin' meatcar.
		}
		return reserve_extra;	
	}
	
	int reserve_gnasir = 0;		//used to track how much we need to reserve for black paint for gnasir
	int reserve_diary = 0;		//used to track how much we need to reserve to acquire [your father's MacGuffin diary] at L11 quest
	int reserve_zeppelin = 0;	//used to track how much we need to reserve for a zeppelin ticket
	int reserve_palindome = 0;	//used to track how much we need to reserve for palindome photographs
	int reserve_island = 0;		//used to track how much we need to reserve to unlock the mysterious island
	
	//how much do we reserve for gnasir?
	if(internalQuestStatus("questL11Desert") < 1 &&				//bitwise. desert exploration not yet finished
	(get_property("gnasirProgress").to_int() & 2) != 2)			//gnasir has not been given black paint yet
	{
		reserve_gnasir += 1000;
	}
	
	//how much do we reserve for [your father's MacGuffin diary]?
	if(item_amount($item[your father\'s MacGuffin diary]) == 0 &&		//you do not yet have diary
	!in_koe() &&														//diary is given by council for free in kingdom of exploathing
	!in_wotsf())															//costs 5 meat total in way of the surprising fist. no need to track that
	{
		reserve_diary += 500;		//1 vacation. no need to count script. we don't pull it or get it prematurely.
		
		//cannot just use npc_price() for [forged identification documents] because they are not always available. it would return 0.
		if(item_amount($item[forged identification documents]) == 0)
		{
			reserve_diary += 5000 * npcStoreDiscountMulti();
		}
	}
	
	//how much do we reserve for a zeppelin ticket?
	if(my_level() >= 11 && internalQuestStatus("questL11Ron") < 5 && item_amount($item[Red Zeppelin Ticket]) < 1)
	{	//the copperhead part tries for a priceless diamond, but if it's over without getting one
		if( (get_property("questL11Shen") == "finished" || $location[the copperhead club].turns_spent >= 15) && item_amount($item[priceless diamond])< 1)
			reserve_zeppelin += 5000 * npcStoreDiscountMulti();
	}	
	
	//how much do we reserve for palindome photographs?
	if(my_level() >= 11 && internalQuestStatus("questL11Palindome") < 1)
	{	
		if(item_amount($item[Photograph Of A Red Nugget]) < 1)
			reserve_palindome += 500;
		if(item_amount($item[Photograph Of God]) < 1)
			reserve_palindome += 500;
	}
	
	//how much do we reserve for unlocking mysterious island?
	if(get_property("lastIslandUnlock").to_int() < my_ascensions())		//need to unlock island
	{
		int price_vacation = 500;
		if(in_wotsf())
		{
		price_vacation = 5;  //yes really. just 5 meat each
		}
		//TODO: scrips. they may have been pulled manually, and one optional property does pull them
		reserve_island += price_vacation * 3;	//3 vacations
		
		if(item_amount($item[dingy planks]) == 0)
		{
			reserve_island += 400 * npcStoreDiscountMulti();
		}
	}
	
	return reserve_gnasir + reserve_diary + reserve_zeppelin + reserve_palindome + reserve_island + reserve_extra;
}
