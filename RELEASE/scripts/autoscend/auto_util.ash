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
	string situation = " " + my_class() + " " + my_path() + " " + my_sign();
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

int solveCookie()
{
	if(!contains_text(get_counters("Fortune Cookie", 0, 250), "Fortune Cookie"))
	{
		return -1;
	}
	int i=0;
	while(i < 250)
	{
		if(contains_text(get_counters("Fortune Cookie", 0, i), "Fortune Cookie"))
		{
			set_property("auto_cookie", my_turncount() + i);
			break;
		}
		i = i + 1;
	}

	return get_property("auto_cookie").to_int();
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

boolean summonMonster()
{
	return summonMonster("");
}

boolean summonMonster(string option)
{
	int turns_left = estimatedTurnsLeft();

	int bootyCalls = 0;
	int rainCalls = 0;
	if(item_amount($item[Genie Bottle]) > 0)
	{
		int wishesLeft = 3 - get_property("_genieWishesUsed").to_int();
		wishesLeft = max(wishesLeft, 3 - get_property("_genieFightsUsed").to_int());
		bootyCalls += wishesLeft;
	}
	if(item_amount($item[Clan VIP Lounge Key]) > 0)
	{
		if(!get_property("_photocopyUsed").to_boolean())
		{
			bootyCalls++;
		}
	}
	if(auto_my_path() == "Heavy Rains")
	{
		int rain = my_rain() + (turns_left * 0.85);
		rainCalls = rain / 50;
		bootyCalls += rainCalls;
	}

	boolean canWink = false;
	int winkPower = 0;
	monster winkMonster = $monster[none];
	if(have_familiar($familiar[Reanimated Reanimator]))
	{
		if(get_property("_badlyRomanticArrows").to_int() == 0)
		{
			canWink = true;
		}
		winkPower = 3 - get_property("_romanticFightsLeft").to_int();
		winkMonster = get_property("romanticTarget").to_monster();
	}

	int[8] digitizeArray = {0, 7, 27, 57, 97, 147, 207, 277};
	boolean canDigitize = false;
	int digitizeLeft = 0;
	int digitizePower = 0;
	boolean digitizeRedigitize = false;
	monster digitizeMonster = $monster[none];
	if(auto_get_campground() contains $item[Source Terminal])
	{
		digitizeLeft = 3 - get_property("_sourceTerminalDigitizeUses").to_int();

		if(get_property("_sourceTerminalDigitizeMonsterCount").to_int() >= 3)
		{
			//We possibly want to see if we can redigitize the monster on arrival of the last digitize.
			digitizeRedigitize = true;
			//Only the Ghost in HR is probably something we care about here.
		}
		if(digitizeLeft < 3)
		{
			digitizeMonster = get_property("_sourceTerminalDigitizeMonster").to_monster();
		}

		if(digitizeMonster == $monster[none])
		{
			digitizePower = 0;
			digitizeRedigitize = false;
		}
		if(digitizeLeft > 0)
		{
			canDigitize = true;
		}
	}

	//Copiers

	//print("Got bootycalls: " + bootyCalls);

	//	Booty calls are direct summons, of which we can wink/digitize/enamorang

	//	We need to take survival ability into account as well.

	//	Raincalls must be used by end of run, anything else can be saved.
	//		Note that rain man is handled already but may skip things.

	record target
	{
		monster target;
		int amt;
	};

	target[int] targets;

	if(needStarKey())
	{
		if((item_amount($item[star chart]) == 0) && (item_amount($item[richard\'s star key]) == 0))
		{
			targets[count(targets)].target = $monster[Astronomer];
			targets[count(targets)].amt = 1;
		}
		else
		{
			int stars = (9 - item_amount($item[Star])) / 2;
			int lines = (8 - item_amount($item[Line])) / 2;
			targets[count(targets)].target = $monster[Skinflute];
			targets[count(targets)].amt = max(stars, lines);
		}
	}
	if(needDigitalKey())
	{
		targets[count(targets)].target = $monster[Ghost];
		targets[count(targets)].amt = (34 - whitePixelCount()) / 5;
	}
	if(item_amount($item[Barrel Of Gunpowder]) < 5)
	{
		int need = 5 - item_amount($item[Barrel Of Gunpowder]);
		if(get_property("sidequestLighthouseCompleted") != "none")
		{
			need = 0;
		}
		if(need > 0)
		{
			targets[count(targets)].target = $monster[Lobsterfrogman];
			targets[count(targets)].amt = need;
		}
	}
	if(internalQuestStatus("questL08Trapper") < 3)
	{
		int have = min(item_amount($item[Ninja Rope]), 1);
		have += min(item_amount($item[Ninja Crampons]), 1);
		have += min(item_amount($item[Ninja Carabiner]), 1);
		int need = 3 - have;
		if(need > 0)
		{
			targets[count(targets)].target = $monster[Ninja Snowman Assassin];
			targets[count(targets)].amt = need;
		}
	}

#	if(get_property("lastSecondFloorUnlock").to_int() < my_ascensions())
#	{
#		int need = 5 - get_property("writingDesksDefeated").to_int();
#		targets[count(targets)].target = $monster[Writing Desk];
#		targets[count(targets)].amt = need;
#	}

	//	Racecar Bob 5
	//	Pygmy Bowler 5+, Mountain Man 2+ (Special Case, when we have extra)
	//	Frat Warrior for Outfit 1+ (Numberology)


	//Should we do a zero check on amt just in case, probably.

	//	Targets (all)
	//	Lobsterfrogman 5, Ninja Snowman Assassin 3, Racecar Bob 5
	//	Ghost 6+, Pygmy Bowler 5+, Mountain Man 2+, Skin Flute 4+, Astronomer 1+
	//	Frat Warrior for Outfit 1+


	return false;
}

boolean canYellowRay(monster target)
{
	# Use this to determine if it is safe to enter a yellow ray combat.

	// first, do any necessary prep to use a yellow ray
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
		cli_execute("make " + $item[Viral Video]);
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
	location locCache = my_location();
	set_location(loc);
	boolean [monster] monstersToBanish = auto_getMonsters("banish");
	set_location(locCache);
	return monstersToBanish[enemy];
}

boolean hasClubEquipped()
{
	return item_type(equipped_item($slot[weapon])) == "club" || (item_type(equipped_item($slot[weapon])) == "sword" && have_effect($effect[iron palms]) > 0);
}

string banisherCombatString(monster enemy, location loc, boolean inCombat)
{
	if(inAftercore())
	{
		return "";
	}

	//Check that we actually want to banish this thing.
	if(!auto_wantToBanish(enemy, loc))
		return "";

	if(inCombat)
		auto_log_info("Finding a banisher to use on " + enemy + " at " + loc, "green");

	//src/net/sourceforge/kolmafia/session/BanishManager.java
	boolean[string] used = auto_banishesUsedAt(loc);

	/*	If we have banished anything else in this zone, make sure we do not undo the banishing.
		mad wino:batter up!:378:skeletal sommelier:KGB tranquilizer dart:381
		We are not going to worry about turn costs, it probably only matters for older paths anyway.

		Thunder Clap: no limit, no turn limit
		Batter Up!: no limit, no turn limit
		Asdon Martin: Spring-Loaded Front Bumper: no limit
		Curse of Vacation: no limit? No turn limit?
		Walk Away Explosion: no limit, turn limited irrelavant.

		Banishing Shout: no turn limit
		Talk About Politics: no turn limit
		KGB Tranquilizer Dart: no turn limit
		Snokebomb: no turn limit

		Louder Than Bomb: item, no turn limit
		Beancannon: item, no turn limit, no limit
		Tennis Ball: item, no turn limit

		Breathe Out: per hot jelly usage
	*/

	//Peel out with Extra-Smelly Muffler, note 10 limit, increased to 30 with Racing Slicks

	if((inCombat ? auto_have_skill($skill[Throw Latte on Opponent]) : possessEquipment($item[latte lovers member\'s mug])) && !get_property("_latteBanishUsed").to_boolean() && !(used contains "Throw Latte on Opponent"))
	{
		return "skill " + $skill[Throw Latte on Opponent];
	}

	if((inCombat ? auto_have_skill($skill[Give Your Opponent The Stinkeye]) : possessEquipment($item[stinky cheese eye])) && !get_property("_stinkyCheeseBanisherUsed").to_boolean() && (my_mp() >= mp_cost($skill[Give Your Opponent The Stinkeye])))
	{
		return "skill " + $skill[Give Your Opponent The Stinkeye];
	}

	if((inCombat ? auto_have_skill($skill[Creepy Grin]) : possessEquipment($item[V for Vivala mask])) && !get_property("_vmaskBanisherUsed").to_boolean() && (my_mp() >= mp_cost($skill[Creepy Grin])))
	{
		return "skill " + $skill[Creepy Grin];
	}

	if(auto_have_skill($skill[Baleful Howl]) && my_hp() > hp_cost($skill[Baleful Howl]) && get_property("_balefulHowlUses").to_int() < 10 && !(used contains "baleful howl"))
	{
		loopHandlerDelayAll();
		return "skill " + $skill[Baleful Howl];
	}

	if(auto_have_skill($skill[Thunder Clap]) && (my_thunder() >= thunder_cost($skill[Thunder Clap])) && (!(used contains "thunder clap")))
	{
		return "skill " + $skill[Thunder Clap];
	}
	if(auto_have_skill($skill[Asdon Martin: Spring-Loaded Front Bumper]) && (get_fuel() >= fuel_cost($skill[Asdon Martin: Spring-Loaded Front Bumper])) && (!(used contains "Spring-Loaded Front Bumper")))
	{
		if(!contains_text(get_property("banishedMonsters"), "Spring-Loaded Front Bumper"))
		{
			return "skill " + $skill[Asdon Martin: Spring-Loaded Front Bumper];
		}
	}
	if(auto_have_skill($skill[Curse Of Vacation]) && (my_mp() > mp_cost($skill[Curse Of Vacation])) && (!(used contains "curse of vacation")))
	{
		return "skill " + $skill[Curse Of Vacation];
	}

	if((inCombat ? auto_have_skill($skill[Show Them Your Ring]) : possessEquipment($item[Mafia middle finger ring])) && !get_property("_mafiaMiddleFingerRingUsed").to_boolean() && (my_mp() >= mp_cost($skill[Show Them Your Ring])))
	{
		return "skill " + $skill[Show Them Your Ring];
	}
	if(auto_have_skill($skill[Breathe Out]) && (my_mp() >= mp_cost($skill[Breathe Out])) && (!(used contains "breathe out")))
	{
		return "skill " + $skill[Breathe Out];
	}
	if(auto_have_skill($skill[Batter Up!]) && (my_fury() >= 5) && (inCombat ? hasClubEquipped() : true) && (!(used contains "batter up!")))
	{
		return "skill " + $skill[Batter Up!];
	}

	if(auto_have_skill($skill[Banishing Shout]) && (my_mp() > mp_cost($skill[Banishing Shout])) && (!(used contains "banishing shout")))
	{
		return "skill " + $skill[Banishing Shout];
	}
	if(auto_have_skill($skill[Walk Away From Explosion]) && (my_mp() > mp_cost($skill[Walk Away From Explosion])) && (have_effect($effect[Bored With Explosions]) == 0) && (!(used contains "walk away from explosion")))
	{
		return "skill " + $skill[Walk Away From Explosion];
	}

	if((inCombat ? auto_have_skill($skill[Talk About Politics]) : possessEquipment($item[Pantsgiving])) && (get_property("_pantsgivingBanish").to_int() < 5) && have_equipped($item[Pantsgiving]) && (!(used contains "pantsgiving")))
	{
		return "skill " + $skill[Talk About Politics];
	}
	if((inCombat ? auto_have_skill($skill[Reflex Hammer]) : possessEquipment($item[Lil\' Doctor&trade; bag])) && get_property("_reflexHammerUsed").to_int() < 3 && !(used contains "Reflex Hammer"))
	{
		return "skill " + $skill[Reflex Hammer];
	}
	if((inCombat ? auto_have_skill($skill[Show Your Boring Familiar Pictures]) : possessEquipment($item[familiar scrapbook])) && (get_property("scrapbookCharges").to_int() >= 200 || (get_property("scrapbookCharges").to_int() >= 100 && my_level() >= 13)) && !(used contains "Show Your Boring Familiar Pictures"))
	{
		return "skill " + $skill[Show Your Boring Familiar Pictures];
	}
	
	if (auto_canFeelHatred() && !(used contains "Feel Hatred"))
	{
		return "skill " + $skill[Feel Hatred];
	}

	if ((inCombat ? have_equipped($item[Fourth of May cosplay saber]) : possessEquipment($item[Fourth of May cosplay saber])) && auto_saberChargesAvailable() > 0 && !(used contains "Saber Force")) {
		// can't use the force on uncopyable monsters
		if (enemy == $monster[none] || enemy.copyable) {
			return auto_combatSaberBanish();
		}
	}

	if((inCombat ? auto_have_skill($skill[KGB Tranquilizer Dart]) : possessEquipment($item[Kremlin\'s Greatest Briefcase])) && (get_property("_kgbTranquilizerDartUses").to_int() < 3) && (my_mp() >= mp_cost($skill[KGB Tranquilizer Dart])) && (!(used contains "KGB tranquilizer dart")))
	{
		boolean useIt = true;
		if (get_property("sidequestJunkyardCompleted") != "none" && my_daycount() >= 2 && get_property("_kgbTranquilizerDartUses").to_int() >= 2)
		{
			useIt = false;
		}

		if(useIt)
		{
			return "skill " + $skill[KGB Tranquilizer Dart];
		}
	}
	if(auto_have_skill($skill[Snokebomb]) && (get_property("_snokebombUsed").to_int() < 3) && ((my_mp() - 20) >= mp_cost($skill[Snokebomb])) && (!(used contains "snokebomb")))
	{
		return "skill " + $skill[Snokebomb];
	}
	if(auto_have_skill($skill[Beancannon]) && (get_property("_beancannonUses").to_int() < 5) && ((my_mp() - 20) >= mp_cost($skill[Beancannon])) && (!(used contains "beancannon")))
	{
		boolean haveBeans = false;
		foreach beancan in $items[Frigid Northern Beans, Heimz Fortified Kidney Beans, Hellfire Spicy Beans, Mixed Garbanzos and Chickpeas, Pork \'n\' Pork \'n\' Pork \'n\' Beans, Shrub\'s Premium Baked Beans, Tesla\'s Electroplated Beans, Trader Olaf\'s Exotic Stinkbeans, World\'s Blackest-Eyed Peas]
		{
			if(inCombat ? equipped_item($slot[off-hand]) == beancan : possessEquipment(beancan))
			{
				haveBeans = true;
				break;
			}
		}
		if(haveBeans)
		{
			return "skill " + $skill[Beancannon];
		}
	}
	if(auto_have_skill($skill[Breathe Out]) && (!(used contains "breathe out")))
	{
		return "skill " + $skill[Breathe Out];
	}

	if (item_amount($item[human musk]) > 0 && (!(used contains "human musk")) && auto_is_valid($item[human musk]) && get_property("_humanMuskUses").to_int() < 3)
	{
		return "item " + $item[human musk];
	}

	//We want to limit usage of these much more than the others.
	if(!($monsters[Natural Spider, Tan Gnat, Tomb Servant, Upgraded Ram] contains enemy))
	{
		return "";
	}

	int keep = 1;
	if (get_property("sidequestJunkyardCompleted") != "none")
	{
		keep = 0;
	}

	if((item_amount($item[Louder Than Bomb]) > keep) && (!(used contains "louder than bomb")) && auto_is_valid($item[Louder Than Bomb]))
	{
		return "item " + $item[Louder Than Bomb];
	}
	if((item_amount($item[Tennis Ball]) > keep) && (!(used contains "tennis ball")) && auto_is_valid($item[Tennis Ball]))
	{
		return "item " + $item[Tennis Ball];
	}
	if((item_amount($item[Deathchucks]) > keep) && (!(used contains "deathchucks")))
	{
		return "item " + $item[Deathchucks];
	}

	return "";
}

string banisherCombatString(monster enemy, location loc)
{
	return banisherCombatString(enemy, loc, false);
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

string yellowRayCombatString(monster target, boolean inCombat, boolean noForceDrop)
{
	if(have_effect($effect[Everything Looks Yellow]) <= 0)
	{
		if((item_amount($item[Yellowcake Bomb]) > 0) && auto_is_valid($item[Yellowcake Bomb]))
		{
			return "item " + $item[Yellowcake Bomb];
		}
		if(auto_have_skill($skill[Disintegrate]) && (my_mp() >= mp_cost($skill[Disintegrate])))
		{
			return "skill " + $skill[Disintegrate];
		}
		if(auto_have_skill($skill[Ball Lightning]) && (my_lightning() >= lightning_cost($skill[Ball Lightning])))
		{
			return "skill " + $skill[Ball Lightning];
		}
		if(auto_have_skill($skill[Wrath of Ra]) && (my_mp() >= mp_cost($skill[Wrath of Ra])))
		{
			return "skill " + $skill[Wrath of Ra];
		}
		if((item_amount($item[Mayo Lance]) > 0) && (get_property("mayoLevel").to_int() > 0) && auto_is_valid($item[Mayo Lance]))
		{
			return "item " + $item[Mayo Lance];
		}
		if((get_property("peteMotorbikeHeadlight") == "Ultrabright Yellow Bulb") && auto_have_skill($skill[Flash Headlight]) && (my_mp() >= mp_cost($skill[Flash Headlight])))
		{
			return "skill " + $skill[Flash Headlight];
		}
		foreach it in $items[Golden Light, Pumpkin Bomb, Unbearable Light, Viral Video, micronova]
		{
			if((item_amount(it) > 0) && auto_is_valid(it))
			{
				return "item " + it;
			}
		}
		if(auto_have_skill($skill[Unleash Cowrruption]) && (have_effect($effect[Cowrruption]) >= 30))
		{
			return "skill " + $skill[Unleash Cowrruption];
		}
		if((inCombat ? my_familiar() == $familiar[Crimbo Shrub] : auto_have_familiar($familiar[Crimbo Shrub])) && (get_property("shrubGifts") == "yellow"))
		{
			return "skill " + $skill[Open a Big Yellow Present];
		}
		if(inCombat ? have_skill($skill[Unleash the Devil's Kiss]) : possessEquipment($item[unwrapped knock-off retro superhero cape]))
		{
			return "skill " + $skill[Unleash the Devil's Kiss];
		}
	}

	if(asdonCanMissile())
	{
		return "skill " + $skill[Asdon Martin: Missile Launcher];
	}

	if (auto_canFeelEnvy())
	{
		return "skill " + $skill[Feel Envy];
	}

	if((inCombat ? have_equipped($item[Fourth of May cosplay saber]) : possessEquipment($item[Fourth of May cosplay saber])) && (auto_saberChargesAvailable() > 0))
	{
		// can't use the force on uncopyable monsters
		if(target == $monster[none] || (target.copyable && !noForceDrop))
		{
			return auto_combatSaberYR();
		}
	}

	return "";
}

string yellowRayCombatString(monster target, boolean inCombat)
{
	return yellowRayCombatString(target, inCombat, false);
}

string yellowRayCombatString(monster target)
{
	return yellowRayCombatString(target, false);
}

string yellowRayCombatString()
{
	return yellowRayCombatString($monster[none]);
}

/* Adjust equipment/familiars to have access to the desired Yellow Ray
 */
boolean adjustForYellowRay(string combat_string)
{
	if(combat_string == ("skill " + $skill[Open a Big Yellow Present]))
	{
		handleFamiliar("yellowray");
		return true;
	}
	if(combat_string == ("skill " + $skill[Use the Force]))
	{
		return autoEquip($slot[weapon], $item[Fourth of May cosplay saber]);
	}
	if(combat_string == ("skill " + $skill[Unleash the Devil's Kiss]))
	{
		auto_configureRetrocape("heck", "kiss");
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

string replaceMonsterCombatString(monster target, boolean inCombat)
{
	if (auto_macrometeoritesAvailable() > 0 && auto_is_valid($skill[Macrometeorite]))
	{
		return "skill " + $skill[Macrometeorite];
	}
	if (auto_powerfulGloveReplacesAvailable(inCombat) > 0 && auto_is_valid($skill[CHEAT CODE: Replace Enemy]))
	{
		return "skill " + $skill[CHEAT CODE: Replace Enemy];
	}
	return "";
}

string replaceMonsterCombatString(monster target)
{
	return replaceMonsterCombatString(target, false);
}

string replaceMonsterCombatString()
{
	return replaceMonsterCombatString($monster[none]);
}

# Use this to determine if it is safe to enter a replace monster combat.
boolean canReplace(monster target)
{
	return replaceMonsterCombatString(target) != "";
}

boolean canReplace()
{
	return canReplace($monster[none]);
}

/* Adjust equipment/familiars to have access to the desired replace monster
 */
boolean adjustForReplace(string combat_string)
{
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
	if (have_skill($skill[Transcendent Olfaction]) &&
	auto_is_valid($skill[Transcendent Olfaction]) &&
	get_property("olfactedMonster").to_monster() != enemy &&
	(have_effect($effect[On The Trail]) == 0 || item_amount($item[soft green echo eyedrop antidote]) > 0))
	{
		return auto_wantToSniff(enemy, loc);
	}
	return false;
}

boolean adjustForSniffingIfPossible(monster target)
{
	if (have_skill($skill[Transcendent Olfaction]) && auto_is_valid($skill[Transcendent Olfaction]))
	{
		if (get_property("olfactedMonster").to_monster() != target &&
				have_effect($effect[On the trail]) > 0 &&
				item_amount($item[soft green echo eyedrop antidote]) > 0)
		{
			auto_log_info("Uneffecting On the trail to have Transcendent Olfaction available for " + target, "blue");
			monster old_olfact = get_property("olfactedMonster").to_monster();
			string output = cli_execute_output("uneffect On the trail");
			if (output.contains_text("On the Trail removed."))
			{
				handleTracker($item[soft green echo eyedrop antidote], old_olfact, "auto_otherstuff");
				return true;
			}
			else
			{
				auto_log_info("Failed to Uneffect On the trail for some reason?", "blue");
			}
		}
		if (my_mp() < mp_cost($skill[Transcendent Olfaction]))
		{
			acquireMP(mp_cost($skill[Transcendent Olfaction]));
		}
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
	return have_skill($skill[Torso Awareness]) || have_skill($skill[Best Dressed]);
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

boolean buyableMaintain(item toMaintain, int howMany)
{
	return buyableMaintain(toMaintain, howMany, 0, true);
}

boolean buyableMaintain(item toMaintain, int howMany, int meatMin)
{
	return buyableMaintain(toMaintain, howMany, meatMin, true);
}

boolean buyableMaintain(item toMaintain, int howMany, int meatMin, boolean condition)
{
	if((!condition) || (my_meat() < meatMin) || (my_path() == "Way of the Surprising Fist"))
	{
		return false;
	}

	return buyUpTo(howMany, toMaintain);
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
		case $class[Ed]:
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
			auto_log_error("Mafia reports we have an oven but we do not. Logging back in will resolve this.", "red");
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
	int retval = item_amount($item[Disassembled Clover]);
	retval += item_amount($item[Ten-Leaf Clover]);
	retval += closet_amount($item[Ten-Leaf Clover]);

	if(in_glover() || in_bhy())
	{
		retval -= item_amount($item[Disassembled Clover]);
	}

	if(in_koe() && canChew($item[lucky pill]))
	{
		int pills = item_amount($item[rare Meat isotope])/20 - 2;
		pills = max(0, pills);
		pills = min(spleen_left(), pills);
		retval += pills;
	}

	return retval;
}

boolean cloverUsageInit()
{
	if(cloversAvailable() == 0)
	{
		abort("Called cloverUsageInit but have no clovers");
	}

	backupSetting("cloverProtectActive", false); // maybe set this before we return?
	if(item_amount($item[Ten-Leaf Clover]) > 0)
	{
		return true;
	}

	if(item_amount($item[Disassembled Clover]) > 0)
	{
		if(!in_glover() && !in_bhy())
		{
			use(1, $item[Disassembled Clover]);
		}
	}
	if(item_amount($item[Ten-Leaf Clover]) > 0)
	{
		return true;
	}

	if(in_koe() && spleen_left() > 1 && canChew($item[lucky pill]) && item_amount($item[rare Meat isotope]) >= 60)
	{
		retrieve_item(1, $item[lucky pill]);
		autoChew(1, $item[lucky pill]);
		use(1, $item[Disassembled Clover]);
	}

	if(closet_amount($item[Ten-Leaf Clover]) > 0)
	{
		take_closet(1, $item[Ten-Leaf Clover]);
	}
	if(item_amount($item[Ten-Leaf Clover]) > 0)
	{
		return true;
	}
	abort("We tried to initialize clover usage but do not appear to have a Ten-Leaf Clover");
	return false;
}

boolean cloverUsageFinish()
{
	restoreSetting("cloverProtectActive");
	if(item_amount($item[Ten-Leaf Clover]) > 0)
	{
		auto_log_debug("Wandering adventure interrupted our clover adventure (" + my_location() + "), boo. Gonna have to do this again.");
		if(in_glover() || in_bhy())
		{
			put_closet(item_amount($item[Ten-Leaf Clover]), $item[Ten-Leaf Clover]);
		}
		use(item_amount($item[Ten-Leaf Clover]), $item[Ten-Leaf Clover]);
		return false;
	}
	return true;
}

boolean acquireGumItem(item it)
{
	if(!isGeneralStoreAvailable())
	{
		return false;
	}

	if(!($items[Disco Ball, Disco Mask, Helmet Turtle, Hollandaise Helmet, Mariachi Hat, Old Sweatpants, Pasta Spoon, Ravioli Hat, Saucepan, Seal-Clubbing Club, Seal-Skull Helmet, Stolen Accordion, Turtle Totem, Worthless Gewgaw, Worthless Knick-Knack, Worthless Trinket] contains it))
	{
		return false;
	}

	int have = item_amount(it);
	auto_log_info("Gum acquistion of: " + it, "green");
	while((have == item_amount(it)) && (my_meat() >= npc_price($item[Chewing Gum on a String])))
	{
		buyUpTo(1, $item[Chewing Gum on a String]);
		use(1, $item[Chewing Gum on a String]);
	}

	return (have + 1) == item_amount(it);
}

boolean acquireTotem()
{
	//this function checks if you have a valid totem for casting turtle tamer buffs with. Returning true if you do. If you don't, it will attempt to acquire one in a reasonable manner.

	//check if there is a valid totem in inventory or equipped, return true if there is.
	//check the closet from best to worst. If found in closet, uncloset 1 and return true
	
	foreach totem in $items[primitive alien totem, flail of the seven aspects, chelonian morningstar, mace of the tortoise, ouija board\, ouija board, turtle totem]
	{
		if (possessEquipment(totem))
		{
			return true;
		}
		if (0 < closet_amount(totem))
		{
			take_closet(1, totem);
			return true;
		}
	}

	//try fishing in the sewer for a turtle totem
	
	if(acquireGumItem($item[turtle totem]))
	{
		return true;
	}
	
	//still could not get a totem. Give up
	return false;
}

boolean acquireHermitItem(item it)
{
	if(!isHermitAvailable())
	{
		return false;
	}
	if((item_amount($item[Hermit Permit]) == 0) && (my_meat() >= npc_price($item[Hermit Permit])))
	{
		buyUpTo(1, $item[Hermit Permit]);
	}
	if(item_amount($item[Hermit Permit]) == 0)
	{
		return false;
	}
	if(it == $item[Disassembled Clover])
	{
		it = $item[Ten-leaf Clover];
	}
	if(!($items[Banjo Strings, Catsup, Chisel, Figurine of an Ancient Seal, Hot Buttered Roll, Jaba&ntilde;ero Pepper, Ketchup, Petrified Noodles, Seal Tooth, Ten-Leaf Clover, Volleyball, Wooden Figurine] contains it))
	{
		return false;
	}
	if((it == $item[Figurine of an Ancient Seal]) && (my_class() != $class[Seal Clubber]))
	{
		return false;
	}
	if(!isGeneralStoreAvailable())
	{
		return false;
	}
	int have = item_amount(it);
	auto_log_info("Hermit acquistion of: " + it, "green");
	while((have == item_amount(it)) && ((my_meat() >= npc_price($item[Chewing Gum on a String])) || ((item_amount($item[Worthless Trinket]) + item_amount($item[Worthless Gewgaw]) + item_amount($item[Worthless Knick-knack])) > 0)))
	{
		if((item_amount($item[Worthless Trinket]) + item_amount($item[Worthless Gewgaw]) + item_amount($item[Worthless Knick-knack])) > 0)
		{
			if(it == $item[Ten-Leaf Clover])
			{
				have = item_amount($item[Disassembled Clover]);
			}
			if(!hermit(1, it))
			{
				return false;
			}
			if(it == $item[Ten-Leaf Clover])
			{
				if(have == item_amount($item[Disassembled Clover]))
				{
					return false;
				}
				else if((have + 1) == item_amount($item[Disassembled Clover]))
				{
					return true;
				}
				else
				{
					auto_log_warning("Invalid clover count from hermit behavior, reporting failure.", "red");
					return false;
				}
			}
		}
		else
		{
			buyUpTo(1, $item[Chewing Gum on a String]);
			use(1, $item[Chewing Gum on a String]);
		}
	}

	return (have + 1) == item_amount(it);
}

boolean isHermitAvailable()
{
	if(auto_my_path() == "Nuclear Autumn")
	{
		return false;
	}
	if(auto_my_path() == "Zombie Master")
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
	if(auto_my_path() == "Nuclear Autumn")
	{
		return false;
	}
	if(auto_my_path() == "Zombie Master")
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
	if(auto_my_path() == "Nuclear Autumn")
	{
		return false;
	}
	if(auto_my_path() == "Zombie Master")
	{
		return false;
	}
	return true;
}

boolean isArmoryAndLeggeryStoreAvailable()
{
	if(auto_my_path() == "Nuclear Autumn")
	{
		return false;
	}
	if(auto_my_path() == "Zombie Master")
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
	if(auto_my_path() == "Nuclear Autumn")
	{
		return false;
	}
	if(auto_my_path() == "Zombie Master")
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
	if(auto_my_path() == "Nuclear Autumn")
	{
		return false;
	}
	if(auto_my_path() == "Zombie Master")
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
			Naughty Sorceress,
		// Vampyre
			Your Lack of Reflection,
			// The final boss is handled separately
		// Witchess Monsters
			Witchess Witch,
			Witchess Queen,
			Witchess King,
		// Other
			Cyrus the Virus,
	];

	// Vampyre final boss has your name reversed, which is dumb.
	// I wonder if this will hit any unlucky people...
	if(reverse(my_name()) == mon.to_string())
	{
		return false;
	}

	return !(unstunnable_monsters contains mon);
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
	boolean[monster] classRevamp = $monsters[Box of Crafty Dinner, depressing french accordionist, Frozen Bag of Tortellini, lively cajun accordionist, Possessed Can of Creepy Pasta, Possessed Can of Linguine-Os, Possessed Jar of Alphredo&trade;, quirky indie-rock accordionist];

	boolean[monster] bricko = $monsters[BRICKO airship, BRICKO bat, BRICKO cathedral, BRICKO elephant, BRICKO gargantuchicken, BRICKO octopus, BRICKO ooze, BRICKO oyster, BRICKO python, BRICKO turtle, BRICKO vacuum cleaner];

	boolean[monster] gothKid = $monsters[Black Crayon Beast, Black Crayon Beetle, Black Crayon Constellation, Black Crayon Golem, Black Crayon Demon, Black Crayon Man, Black Crayon Elemental, Black Crayon Crimbo Elf, Black Crayon Fish, Black Crayon Goblin, Black Crayon Hippy, Black Crayon Hobo, Black Crayon Shambling Monstrosity, Black Crayon Manloid, Black Crayon Mer-kin, Black Crayon Frat Orc, Black Crayon Penguin, Black Crayon Pirate, Black Crayon Flower, Black Crayon Slime, Black Crayon Undead Thing, Black Crayon Spiraling Shape];

	boolean[monster] hipster = $monsters[angry bassist, blue-haired girl, evil ex-girlfriend, peeved roommate, random scenester];

	boolean[monster] infernalSeals = $monsters[Broodling Seal, Centurion of Sparky, Hermetic Seal, Spawn of Wally, Heat Seal, Navy Seal, Servant of Grodstank, Shadow of Black Bubbles, Watertight Seal, Wet Seal];

	boolean[monster] witchess = $monsters[Witchess Bishop, Witchess King, Witchess Knight, Witchess Ox, Witchess Pawn, Witchess Queen, Witchess Rook, Witchess Witch];

	boolean[monster] halloween = $monsters[kid who is too old to be Trick-or-Treating, suburban security civilian, vandal kid];

	boolean[monster] lovecrate = $monsters[LOV Enforcer, LOV Engineer, LOV Equivocator];

	boolean[monster] neverland = $monsters[biker, burnout, jock, party girl, "plain" girl];

	boolean[monster] voting = $monsters[Angry Ghost, Annoyed Snake, Government Bureaucrat, Slime Blob, Terrible Mutant];

	boolean[monster] other = $monsters[giant rubber spider, God Lobster, lynyrd, time-spinner prank, Travoltron, sausage goblin];

	//boolean[monster] protonGhosts: See isProtonGhost, we want to detect these separately as well so we\'ll functionalize it here.

	if(classRevamp contains mon)
	{
		return true;
	}
	if(bricko contains mon)
	{
		return true;
	}
	if(gothKid contains mon)
	{
		return true;
	}
	if(hipster contains mon)
	{
		return true;
	}
	if(infernalSeals contains mon)
	{
		return true;
	}
	if(witchess contains mon)
	{
		return true;
	}
	if(halloween contains mon)
	{
		return true;
	}
	if(lovecrate contains mon)
	{
		return true;
	}
	if(other contains mon)
	{
		return true;
	}
	if(isProtonGhost(mon))
	{
		return true;
	}

	if(voting contains mon)
	{
		if(get_property("_voteFreeFights").to_int() < 3)
		{
			return true;
		}
	}

	if(neverland contains mon)
	{
		if(get_property("_neverendingPartyFreeTurns").to_int() < 10)
		{
			return true;
		}
	}

	if($monsters[Perceiver of Sensations, Performer of Actions, Thinker of Thoughts] contains mon)
	{
		if((my_familiar() == $familiar[Machine Elf]) && (get_property("_machineTunnelsAdv").to_int() < 5) && (my_location() == $location[The Deep Machine Tunnels]))
		{
			return true;
		}
	}

	if($monster[X-32-F Combat Training Snowman] == mon)
	{
		if(get_property("_snojoFreeFights").to_int() < 10)
		{
			return true;
		}
	}

	if(($monster[Eldritch Tentacle] == mon) && (have_effect($effect[Eldritch Attunement]) > 0))
	{
		return true;
	}

	if($monster[Eldritch Tentacle] == mon)
	{
		return true;
	}

	if(($monster[Drunk Pygmy] == mon) && (item_amount($item[Bowl of Scorpions]) > 0))
	{
		return true;
	}

	if(mon.random_modifiers["optimal"])
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
	if(in_boris()) return borisAdjustML();
	if (in_zelda())
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

boolean auto_change_mcd(int mcd)
{
	return auto_change_mcd(mcd, false);
}

boolean auto_change_mcd(int mcd, boolean immediately)
{
	if (in_koe()) return false;

	int best = 10;
	if(knoll_available())
	{
		if(item_amount($item[Detuned Radio]) == 0)
		{
			return false;
		}
		if(in_glover())
		{
			return false;
		}
	}
	if(inGnomeSign() && !gnomads_available())
	{
		return false;
	}
	if(canadia_available())
	{
		best = 11;
	}
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

	if(my_path() != "Way of the Surprising Fist")
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

boolean zoneNonCombat(location loc)
{
	return false;
}
boolean zoneCombat(location loc)
{
	return false;
}
boolean zoneMeat(location loc)
{
	return false;
}
boolean zoneItem(location loc)
{
	return false;
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
	if(get_property("_universeCalculated").to_int() >= get_property("skillLevel144").to_int())
	{
		return -1;
	}
	if(my_mp() < 2)
	{
		return -1;
	}

	static int [string] signs;
	signs["Mongoose"] = 1;
	signs["Wallaby"] = 2;
	signs["Vole"] = 3;
	signs["Platypus"] = 4;
	signs["Opossum"] = 5;
	signs["Marmot"] = 6;
	signs["Wombat"] = 7;
	signs["Blender"] = 8;
	signs["Packrat"] = 9;
	signs["Bad Moon"] = 10; #Derp Mode? Derp Mode.

	static string [int] numberwang;
	numberwang[0] = "meat";
	numberwang[1] = "muscle";
	numberwang[2] = "sleepy";
	numberwang[3] = "confused";
	numberwang[4] = "embarrassed";
	numberwang[5] = "far out";
	numberwang[6] = "wings";
	numberwang[7] = "beaten up";
	numberwang[8] = "poisoned";
	numberwang[9] = "perfume";
	numberwang[10] = "steroid";
	numberwang[11] = "inebriety";
	numberwang[12] = "gnoll";
	numberwang[13] = "???";
	numberwang[14] = "moxieweed";
	numberwang[15] = "meat";
	numberwang[16] = "magicalness-in-a-can";
	numberwang[17] = "adventures";
	numberwang[18] = "booze";
	numberwang[19] = "+moxie";
	numberwang[20] = "-moxie";
	numberwang[21] = "fites";
	numberwang[22] = "phone";
	numberwang[23] = "muscle";
	numberwang[27] = "moxie";
	numberwang[30] = "ghuol";
	numberwang[33] = "magicalness-in-a-can";
	numberwang[34] = "+moxie";
	numberwang[35] = "-muscle";
	numberwang[36] = "adventures2";
	numberwang[37] = "fites3";
	numberwang[38] = "+myst";
	numberwang[40] = "meat";
	numberwang[44] = "booze";
	numberwang[48] = "butt";
	numberwang[51] = "battlefield";
	numberwang[58] = "teleportitis";
	numberwang[69] = "adventures3";
	numberwang[75] = "booze";
	numberwang[98] = "myst";
	numberwang[99] = "booze";

	# seed + ascensions + moonsign * (spleen + level) + turns
	int melancholy = my_spleen_use() + my_level();
	int score = my_adventures() + (melancholy * (my_ascensions() + signs[my_sign()]));

	score = score % 100;
	int i=0;
	while(i < 100)
	{
		int current = (score + (melancholy * i)) % 100;
		if(numberwang[current] == goal)
		{
			auto_log_info("Found option for Numberology: " + current + " (" + goal + ")" , "blue");
			if(!doIt)
			{
				return i;
			}

			if(goal == "battlefield")
			{
				string[int] pages;
				pages[0] = "runskillz.php?pwd&action=Skillz&whichskill=144&quantity=1";
				pages[1] = "choice.php?whichchoice=1103&pwd=&option=1&num=" + i;
				autoAdvBypass(0, pages, $location[Noob Cave], option);
				handleTracker($monster[War Frat 151st Infantryman], $skill[Calculate the Universe], "auto_copies");
			}
			else
			{
				visit_url("runskillz.php?pwd&action=Skillz&whichskill=144&quantity=1", true);
				visit_url("choice.php?whichchoice=1103&pwd=&option=1&num=" + i);
			}
			return i;
		}
		i = i + 1;
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

boolean haveAny(boolean[item] array)
{
	foreach thing in array
	{
		if(item_amount(thing) > 0)
		{
			return true;
		}
	}
	return false;
}

boolean acquireOrPull(item it)
{
	//this function is for when you want to make sure you have 1 of an item
	//if you have one it returns true. if you don't it will craft one. if it can't it will pull it.
	
	if(possessEquipment(it)) return true;
	if(item_amount(it) > 0)  return true;
	if(retrieve_item(1, it)) return true;
	if(canPull(it))
	{
		if(pullXWhenHaveY(it, 1, 0)) return true;
	}
	
	//special handling via pulling 1 ingredient to craft the item desired
	if($items[asteroid belt, meteorb, shooting morning star, meteorite guard, meteortarboard, meteorthopedic shoes] contains it)
	{
		if(canPull($item[metal meteoroid]))
		{
			if(pullXWhenHaveY($item[metal meteoroid], 1, 0))
			{
				if(retrieve_item(1, it)) return true;
			}
		}
	}
	
	return false;
}

boolean canPull(item it)
{
	if(in_hardcore())
	{
		return false;
	}
	if(it == $item[none])
	{
		return false;
	}
	if(!is_unrestricted(it))
	{
		return false;
	}
	if(pulls_remaining() == 0)
	{
		return false;
	}
	
	if(storage_amount(it) > 0)
	{
		return true;
	}

	int meat = my_storage_meat();
	if(can_interact())
	{
		meat = max(meat, my_meat() - 5000);
	}
	int curPrice = auto_mall_price(it);
	if (curPrice >= 20000)
	{
		return false;
	}
	else if (curPrice < meat)
	{
		return true;
	}
	
	return false;
}

void pullAll(item it)
{
	if(storage_amount(it) > 0)
	{
		take_storage(storage_amount(it), it);
	}
}

void pullAndUse(item it, int uses)
{
	pullAll(it);
	while((item_amount(it) > 0) && (uses > 0))
	{
		use(1, it);
		uses = uses - 1;
	}
}

int auto_mall_price(item it)
{
	if(isSpeakeasyDrink(it))
	{
		return -1;	//speakeasy drinks are marked as tradeable but cannot be acquired as a physical item to trade.
	}
	if(is_tradeable(it))
	{
		int retval = mall_price(it);
		if(retval == -1)
		{
			abort("Failed getting mall price for " + it + ", aborting to prevent problems");
		}
		return retval;
	}
	return -1;
}

boolean pullXWhenHaveY(item it, int howMany, int whenHave)
{
	if(auto_my_path() == "Community Service")
	{
		return false;
	}
	if(in_hardcore())
	{
		return false;
	}
	if(it == $item[none])
	{
		return false;
	}
	if(!is_unrestricted(it) && !inAftercore())
	{
		return false;
	}
	if(pulls_remaining() == 0)
	{
		return false;
	}
	if (!auto_is_valid(it))
	{
		return false;
	}
	if((item_amount(it) + equipped_amount(it)) == whenHave)
	{
		int lastStorage = storage_amount(it);
		while(storage_amount(it) < howMany)
		{
			int oldPrice = historical_price(it) * 1.2;
			int curPrice = auto_mall_price(it);
			int meat = my_storage_meat();
			boolean getFromStorage = true;
			if(can_interact() && (meat < curPrice))
			{
				meat = my_meat() - 5000;
				getFromStorage = false;
			}
			if (curPrice >= 30000)
			{
				auto_log_warning(it + " is too expensive at " + curPrice + " meat, we're gonna skip buying one in the mall.", "red");
				break;
			}
			if((curPrice <= oldPrice) && (curPrice < 30000) && (meat >= curPrice))
			{
				if(getFromStorage)
				{
					buy_using_storage(howMany - storage_amount(it), it, curPrice);
				}
				else
				{
					howMany -= buy(howMany - storage_amount(it), it, curPrice);
				}
			}
			else
			{
				if(curPrice > oldPrice)
				{
					auto_log_warning("Price of " + it + " may have been mall manipulated. Expected to pay at most: " + oldPrice, "red");
				}
				if(my_storage_meat() < curPrice)
				{
					auto_log_warning("Do not have enough meat in Hagnk's to buy " + it + ". Need " + curPrice + " have " + my_storage_meat() + ".", "blue");
					if(curPrice > 10000000)
					{
						auto_log_warning("You must be a poor meatbag.", "green");
					}
				}
			}
			if(lastStorage == storage_amount(it))
			{
				break;
			}
			lastStorage = storage_amount(it);
		}

		if(storage_amount(it) < howMany)
		{
			auto_log_warning("Can not pull what we don't have. Sorry");
			return false;
		}

		auto_log_info("Trying to pull " + howMany + " of " + it, "blue");
		boolean retval = take_storage(howMany, it);
		if(item_amount(it) != (howMany + whenHave))
		{
			auto_log_warning("Failed pulling " + howMany + " of " + it, "red");
		}
		else
		{
			for(int i = 0; i < howMany; ++i)
			{
				handleTracker(it, "auto_pulls");
			}
		}
		return retval;
	}
	return false;
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


boolean pulverizeThing(item it)
{
	if(!have_skill($skill[Pulverize]))
	{
		return false;
	}
	if(item_amount($item[Tenderizing Hammer]) == 0)
	{
		if(my_meat() < npc_price($item[Tenderizing Hammer]))
		{
			return false;
		}
	}

	if(item_amount(it) == 0)
	{
		if(closet_amount(it) == 0)
		{
			return false;
		}
		take_closet(1, it);
	}
	if(item_amount(it) == 0)
	{
		return false;
	}
	cli_execute("pulverize 1 " + it);
	return true;
}

boolean buy_item(item it, int quantity, int maxprice)
{
	take_closet(closet_amount(it), it);
	if(inAftercore())
	{
		take_storage(storage_amount(it), it);
	}
	while((item_amount(it) < quantity) && (auto_mall_price(it) < maxprice))
	{
		if(auto_mall_price(it) > my_meat())
		{
			abort("Don't have enough meat to restock, big sad");
		}
		if(buy(1, it, maxprice) == 0)
		{
			auto_log_info("Price of " + it + " exceeded expected mall price of " + maxprice + ".", "blue");
			return false;
		}
	}
	if(item_amount(it) < quantity)
	{
		if(auto_mall_price(it) >= maxprice)
		{
			auto_log_info("Price of " + it + " exceeded expected mall price of " + maxprice + ".", "blue");
		}
		return false;
	}
	return true;
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
			return false;
		}
		return true;
	}

	if($monsters[Blooper, Ghost] contains mon)
	{
		if(!needDigitalKey())
		{
			return false;
		}
		return true;
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

boolean[skill] ATSongList()
{
	// This List contains ALL AT songs in order from Most to Least Important as to determine what effect to shrug off.
	boolean[skill] songs = $skills[
		Inigo\'s Incantation of Inspiration,
		The Ballad of Richie Thingfinder,
		Chorale of Companionship,
		The Ode to Booze,
		Ur-Kel\'s Aria of Annoyance,
		Carlweather\'s Cantata of Confrontation,
		The Sonata of Sneakiness,
		Fat Leon\'s Phat Loot Lyric,
		The Polka of Plenty,
		The Psalm of Pointiness,
		Aloysius\' Antiphon of Aptitude,
		Paul\'s Passionate Pop Song,
		Donho\'s Bubbly Ballad,
		Prelude of Precision,
		Elron\'s Explosive Etude,
		Benetton\'s Medley of Diversity,
		Dirge of Dreadfulness,
		Stevedave\'s Shanty of Superiority,
		Brawnee\'s Anthem of Absorption,
		Jackasses\' Symphony of Destruction,
		The Power Ballad of the Arrowsmith,
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
	if ($classes[Avatar of Boris, Avatar of Jarlsberg, Avatar of Sneaky Pete, Ed, Vampyre, Plumber] contains my_class())
	{
		return;
	}

	//If you think we are handling song overages, you are cray cray....
	if(have_effect(anticipated) > 0)
	{
		//We have the effect, we do not need to shrug it, just let it propagate.
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
		if(have_effect(to_effect(ATsong)) > 0)
		{
			count += 1;
			if(count > maxSongs)
			{
				auto_log_info("Shrugging song: " + ATsong, "blue");
				uneffect(to_effect(ATsong));
			}
		}
	}
	auto_log_info("I think we're good to go to apply " + anticipated, "blue");
}


string auto_my_path()
{
	// This is for handling the situation briefly after a new path is created so that we can
	// attempt to use proper names.
	// Most of the time, it is just a pointless wrapper.
	// This is only needed in mainline files, path specific files have already been supported.
	return my_path();
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
	if((auto_my_path() == "Nuclear Autumn") && !didCheck)
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

boolean buyUpTo(int num, item it)
{
	return buyUpTo(num, it, 20000);
}

boolean buyUpTo(int num, item it, int maxprice)
{
	if(item_amount(it) >= num)
	{
		return true;	//we already have the target amount
	}
	if(($items[Ben-Gal&trade; Balm, Hair Spray] contains it) && !isGeneralStoreAvailable())
	{
		return false;
	}
	if(($items[Blood of the Wereseal, Cheap Wind-Up Clock, Turtle Pheromones] contains it) && !isMusGuildStoreAvailable())
	{
		return false;
	}

	int missing = num - item_amount(it);
	if(can_interact() && shop_amount(it) > 0 && mall_price(it) < maxprice)	//prefer to buy from yourself
	{
		take_shop(min(missing, shop_amount(it)), it);
		missing = num - item_amount(it);
	}
	if(missing > 0)
	{
		buy(missing, it, maxprice);
		if(item_amount(it) < num)
		{
			auto_log_warning("Could not buyUpTo(" + num + ") of " + it + ". Maxprice: " + maxprice, "red");
		}
	}
	return (item_amount(it) >= num);
}

boolean buffMaintain(skill source, effect buff, int mp_min, int casts, int turns, boolean speculative)
{
	if(!glover_usable(buff))
	{
		return false;
	}

	if(!auto_have_skill(source) || (have_effect(buff) >= turns))
	{
		return false;
	}

	if((my_mp() < mp_min) || (my_mp() < (casts * mp_cost(source))))
	{
		return false;
	}
	if(my_hp() <= (casts * hp_cost(source)))
	{
		return false;
	}
	if(my_adventures() < (casts * adv_cost(source)))
	{
		return false;
	}
	if(my_lightning() < (casts * lightning_cost(source)))
	{
		return false;
	}
	if(my_rain() < (casts * rain_cost(source)))
	{
		return false;
	}
	if(my_soulsauce() < (casts * soulsauce_cost(source)))
	{
		return false;
	}
	if(my_thunder() < (casts * thunder_cost(source)))
	{
		return false;
	}
	if(!speculative)
		use_skill(casts, source);
	return true;
}

boolean buffMaintain(item source, effect buff, int uses, int turns, boolean speculative)
{
	if(in_tcrs())
	{
		auto_log_debug("We want to use " + source + " but are in 2CRS.", "blue");
		return false;
	}

	if(!glover_usable(buff))
	{
		return false;
	}
	if(!auto_is_valid(source))
	{
		return false;
	}

	if(have_effect(buff) >= turns)
	{
		return false;
	}
	if((item_amount(source) < uses) && (my_path() != "Way of the Surprising Fist"))
	{
		if(historical_price(source) < 2000)
		{
			buy(uses - item_amount(source), source, 1000);
		}
	}
	if(item_amount(source) < uses)
	{
		return false;
	}
	if(!speculative)
		use(uses, source);
	return true;
}

boolean buffMaintain(effect buff, int mp_min, int casts, int turns, boolean speculative)
{
	skill useSkill = $skill[none];
	item useItem = $item[none];

	if(buff == $effect[none])
	{
		return false;
	}

	switch(buff)
	{
	#Jalapeno Saucesphere
	case $effect[A Few Extra Pounds]:			useSkill = $skill[Holiday Weight Gain];			break;
	case $effect[A Little Bit Poisoned]:		useSkill = $skill[Disco Nap];					break;
	case $effect[Adorable Lookout]:				useItem = $item[Giraffe-Necked Turtle];			break;
	case $effect[Alacri Tea]:					useItem = $item[cuppa Alacri Tea];				break;
	case $effect[All Fired Up]:					useItem = $item[Ant Agonist];					break;
	case $effect[All Glory To The Toad]:		useItem = $item[Colorful Toad];					break;
	case $effect[All Revved Up]:				useSkill = $skill[Rev Engine];					break;
	case $effect[Almost Cool]:					useItem = $item[Mostly-Broken Sunglasses];		break;
	case $effect[Aloysius\' Antiphon of Aptitude]:useSkill = $skill[Aloysius\' Antiphon of Aptitude];break;
	case $effect[Amazing]:						useItem = $item[Pocket Maze];					break;
	case $effect[Angry]:						useSkill = $skill[Anger Glands];					break;
	case $effect[Antibiotic Saucesphere]:		useSkill = $skill[Antibiotic Saucesphere];		break;
	case $effect[Arched Eyebrow of the Archmage]:useSkill = $skill[Arched Eyebrow of the Archmage];break;
	case $effect[Armor-Plated]:					useItem = $item[Bent Scrap Metal];				break;
	case $effect[Ashen]:					useItem = $item[pile of ashes];						break;
	case $effect[Ashen Burps]:					useItem = $item[ash soda];						break;
	case $effect[Astral Shell]:
		if(acquireTotem())
		{
			useSkill = $skill[Astral Shell];
		}																						break;
	case $effect[Baconstoned]:
		if(item_amount($item[Vial of Baconstone Juice]) > 0)
		{
			useItem = $item[Vial of Baconstone Juice];
		}
		else if(item_amount($item[Flask of Baconstone Juice]) > 0)
		{
			useItem = $item[Flask of Baconstone Juice];
		}
		else
		{
			useItem = $item[Jug of Baconstone Juice];
		}																						break;
	case $effect[Baited Hook]:					useItem = $item[Wriggling Worm];				break;
	case $effect[Balls of Ectoplasm]:			useItem = $item[Ectoplasmic Orbs];				break;
	case $effect[Bandersnatched]:				useItem = $item[Tonic O\' Banderas];			break;
	case $effect[Barbecue Saucy]:				useItem = $item[Dollop of Barbecue Sauce];		break;
	case $effect[Be A Mind Master]:				useItem = $item[Daily Affirmation: Be A Mind Master];	break;
	case $effect[Become Superficially Interested]:	useItem = $item[Daily Affirmation: Be Superficially Interested];	break;
	case $effect[Bendin\' Hell]:					useSkill = $skill[Bend Hell];					break;
	case $effect[Bent Knees]:					useSkill = $skill[Bendable Knees];					break;
	case $effect[Benetton\'s Medley of Diversity]:	useSkill = $skill[Benetton\'s Medley of Diversity];		break;
	case $effect[Berry Elemental]:				useItem = $item[Tapioc Berry];					break;
	case $effect[Berry Statistical]:			useItem = $item[Snarf Berry];					break;
	case $effect[Big]:							useSkill = $skill[Get Big];						break;
	case $effect[Big Meat Big Prizes]:			useItem = $item[Meat-Inflating Powder];			break;
	case $effect[Biologically Shocked]:			useItem = $item[glowing syringe];				break;
	case $effect[Bitterskin]:					useItem = $item[Bitter Pill];					break;
	case $effect[Black Eyes]:					useItem = $item[Black Eye Shadow];				break;
	case $effect[Blackberry Politeness]:		useItem = $item[Blackberry Polite];				break;
	case $effect[Blessing of Serqet]:			useSkill = $skill[Blessing of Serqet];			break;
	case $effect[Blessing of the Bird]:
		if(auto_birdCanSeek())
		{
			useSkill = $skill[Seek Out a Bird];
		}																						break;
	case $effect[Blessing of Your Favorite Bird]:
		if(auto_favoriteBirdCanSeek())
		{
			useSkill = $skill[Visit Your Favorite Bird];
		}																						break;
	case $effect[Blinking Belly]:				useSkill = $skill[Firefly Abdomen];				break;
	case $effect[Blood-Gorged]:					useItem = $item[Vial Of Blood Simple Syrup];	break;
	case $effect[Blood Bond]:					useSkill = $skill[Blood Bond];					break;
	case $effect[Blood Bubble]:					useSkill = $skill[Blood Bubble];				break;
	case $effect[Bloody Potato Bits]:			useSkill = $skill[none];						break;
	case $effect[Bloodstain-Resistant]:			useItem = $item[Bloodstain Stick];				break;
	case $effect[Blooper Inked]:				useItem = $item[Blooper Ink];					break;
	case $effect[Blubbered Up]:					useSkill = $skill[Blubber Up];					break;
	case $effect[Blue Swayed]:					useItem = $item[Pulled Blue Taffy];				break;
	case $effect[Bone Springs]:					useSkill = $skill[Bone Springs];				break;
	case $effect[Boner Battalion]:				useSkill = $skill[Summon &quot;Boner Battalion&quot;];	break;
	case $effect[Boon of She-Who-Was]:			useSkill = $skill[Spirit Boon];					break;
	case $effect[Boon of the Storm Tortoise]:	useSkill = $skill[Spirit Boon];					break;
	case $effect[Boon of the War Snapper]:		useSkill = $skill[Spirit Boon];					break;
	case $effect[Bounty of Renenutet]:			useSkill = $skill[Bounty of Renenutet];			break;
	case $effect[Bow-Legged Swagger]:			useSkill = $skill[Bow-Legged Swagger];			break;
	case $effect[Bram\'s Bloody Bagatelle]:		useSkill = $skill[Bram\'s Bloody Bagatelle];		break;
	case $effect[Brawnee\'s Anthem of Absorption]:useSkill = $skill[Brawnee\'s Anthem of Absorption];break;
	case $effect[Brilliant Resolve]:			useItem = $item[Resolution: Be Smarter];		break;
	case $effect[Brooding]:						useSkill = $skill[Brood];						break;
	case $effect[Browbeaten]:					useItem = $item[Old Eyebrow Pencil];			break;
	case $effect[Busy Bein\' Delicious]:		useItem = $item[Crimbo fudge];					break;
	case $effect[Butt-Rock Hair]:				useItem = $item[Hair Spray];					break;
	case $effect[Can\'t Smell Nothin\']:	useItem = $item[Dogsgotnonoz pills];	break;
	case $effect[Car-Charged]:	useItem = $item[Battery (car)];	break;
	case $effect[Carlweather\'s Cantata of Confrontation]:useSkill = $skill[Carlweather\'s Cantata of Confrontation];break;
	case $effect[Carol Of The Bulls]: useSkill = $skill[Carol Of The Bulls]; break;
	case $effect[Carol Of The Hells]: useSkill = $skill[Carol Of The Hells]; break;
	case $effect[Carol Of The Thrills]: useSkill = $skill[Carol Of The Thrills]; break;
	case $effect[Cautious Prowl]:				useSkill = $skill[Walk: Cautious Prowl];		break;
	case $effect[Ceaseless Snarling]: useSkill = $skill[Ceaseless Snarl]; break;
	case $effect[Celestial Camouflage]:			useItem = $item[Celestial Squid Ink];			break;
	case $effect[Celestial Saltiness]:			useItem = $item[Celestial Au Jus];				break;
	case $effect[Celestial Sheen]:				useItem = $item[Celestial Olive Oil];			break;
	case $effect[Celestial Vision]:				useItem = $item[Celestial Carrot Juice];			break;
	case $effect[Cinnamon Challenger]:			useItem = $item[Pulled Red Taffy];				break;
	case $effect[Cletus\'s Canticle of Celerity]:	useSkill = $skill[Cletus\'s Canticle of Celerity];break;
	case $effect[Cloak of Shadows]: useSkill = $skill[Blood Cloak]; break;
	case $effect[Clyde\'s Blessing]:			useItem = $item[The Legendary Beat];			break;
	case $effect[Chalky Hand]:					useItem = $item[Handful of Hand Chalk];			break;
	case $effect[Chocolatesphere]:					useSkill = $skill[Chocolatesphere];			break;
	case $effect[Cranberry Cordiality]:			useItem = $item[Cranberry Cordial];				break;
	case $effect[Coffeesphere]:				useSkill = $skill[Coffeesphere];			break;
	case $effect[Cold Hard Skin]:				useItem = $item[Frost-Rimed Seal Hide];			break;
	case $effect[Contemptible Emanations]:		useItem = $item[Cologne of Contempt];			break;
	case $effect[The Cupcake of Wrath]:			useItem = $item[Green-Frosted Astral Cupcake];	break;
	case $effect[Curiosity of Br\'er Tarrypin]:
		if(acquireTotem())
		{
			useSkill = $skill[Curiosity of Br\'er Tarrypin];
		}																						break;
	case $effect[Dance of the Sugar Fairy]:		useItem = $item[Sugar Fairy];					break;
	case $effect[Destructive Resolve]:			useItem = $item[Resolution: Be Feistier];		break;
	case $effect[Dexteri Tea]:					useItem = $item[cuppa Dexteri tea];				break;
	case $effect[Digitally Converted]:			useItem = $item[Digital Underground Potion];	break;
	case $effect[The Dinsey Look]:				useItem = $item[Dinsey Face Paint];				break;
	case $effect[Dirge of Dreadfulness]:		useSkill = $skill[Dirge of Dreadfulness];		break;
	case $effect[Disco Fever]:					useSkill = $skill[Disco Fever];					break;
	case $effect[Disco Leer]:					useSkill = $skill[Disco Leer];					break;
	case $effect[Disco Smirk]:					useSkill = $skill[Disco Smirk];					break;
	case $effect[Disco State of Mind]:			useSkill = $skill[Disco Aerobics];				break;
	case $effect[Disdain of She-Who-Was]:		useSkill = $skill[Blessing of She-Who-Was];		break;
	case $effect[Disdain of the Storm Tortoise]:useSkill = $skill[Blessing of the Storm Tortoise];break;
	case $effect[Disdain of the War Snapper]:	useSkill = $skill[Blessing of the War Snapper];	break;
	case $effect[Drenched With Filth]:			useItem = $item[Concentrated Garbage Juice];	break;
	case $effect[Drescher\'s Annoying Noise]:	useSkill = $skill[Drescher\'s Annoying Noise];	break;
	case $effect[Drunk and Avuncular]:			useItem = $item[Drunk Uncles Holo-Record];		break;
	case $effect[Eagle Eyes]:					useItem = $item[eagle feather];					break;
	case $effect[Ear Winds]:					useSkill = $skill[Flappy Ears];					break;
	case $effect[Eau D\'enmity]:				useItem = $item[Perfume of Prejudice];			break;
	case $effect[Eau de Tortue]:				useItem = $item[Turtle Pheromones];				break;
	case $effect[Egged On]:						useItem = $item[Robin\'s Egg];					break;
	case $effect[Eldritch Alignment]:			useItem = $item[Eldritch Alignment Spray];		break;
	case $effect[Elemental Saucesphere]:		useSkill = $skill[Elemental Saucesphere];		break;
	case $effect[Empathy]:
		if(pathHasFamiliar() && acquireTotem())
		{
			useSkill = $skill[Empathy of the Newt];
		}																						break;
	case $effect[Erudite]:						useItem = $item[Black Sheepskin Diploma];		break;
	case $effect[Expert Oiliness]:				useItem = $item[Oil of Expertise];				break;
	case $effect[Experimental Effect G-9]:		useItem = $item[Experimental Serum G-9];		break;
	case $effect[Extended Toes]:				useSkill = $skill[Retractable Toes];			break;
	case $effect[Extra Backbone]:				useItem = $item[Really Thick Spine];			break;
	case $effect[Extreme Muscle Relaxation]:	useItem = $item[Mick\'s IcyVapoHotness Rub];	break;
	case $effect[Everything Must Go!]:			useItem = $item[Violent Pastilles];				break;
	case $effect[Eyes All Black]:				useItem = $item[Delicious Candy];				break;
	case $effect[Faboooo]:						useItem = $item[Fabiotion];						break;
	case $effect[Far Out]:						useItem = $item[Patchouli Incense Stick];		break;
	case $effect[Fat Leon\'s Phat Loot Lyric]:	useSkill = $skill[Fat Leon\'s Phat Loot Lyric];	break;
	case $effect[Feeling Lonely]:					useSkill = $skill[none];						break;
	case $effect[Feeling Excited]:					useSkill = $skill[none];						break;
	case $effect[Feeling Nervous]:					useSkill = $skill[none];						break;
	case $effect[Feeling Peaceful]:					useSkill = $skill[none];						break;
	case $effect[Feeling Punchy]:				useItem = $item[Punching Potion];				break;
	case $effect[Feroci Tea]:					useItem = $item[cuppa Feroci tea];				break;
	case $effect[Fever From the Flavor]:	useItem = $item[bottle of antifreeze];	break;
	case $effect[Fireproof Lips]:					useItem = $item[SPF 451 lip balm];			break;
	case $effect[Fire Inside]:					useItem = $item[Hot Coal];						break;
	case $effect[Fishy\, Oily]:
		if(auto_my_path() == "Heavy Rains")
		{
			useItem = $item[Gourmet Gourami Oil];
		}																						break;
	case $effect[Fishy Fortification]:			useItem = $item[Fish-Liver Oil];				break;
	case $effect[Fishy Whiskers]:
		if(auto_my_path() == "Heavy Rains")
		{
			useItem = $item[Catfish Whiskers];
		}																						break;
	case $effect[Flame-Retardant Trousers]:		useItem = $item[Hot Powder];					break;
	case $effect[Flaming Weapon]:				useItem = $item[Hot Nuggets];					break;
	case $effect[Flamibili Tea]:				useItem = $item[cuppa Flamibili Tea];			break;
	case $effect[Flexibili Tea]:				useItem = $item[cuppa Flexibili Tea];			break;
	case $effect[Flimsy Shield of the Pastalord]:
		useSkill = $skill[Shield of the Pastalord];
		if(my_class() == $class[Pastamancer])
		{
			buff = $effect[Shield of the Pastalord];
		}
		break;
	case $effect[Float Like a Butterfly, Smell Like a Bee]:
		if(in_bhy())
		{
			useItem = $item[honeypot];
		}																						break;
	case $effect[Florid Cheeks]:				useItem = $item[Henna Face Paint];				break;
	case $effect[Football Eyes]:				useItem = $item[Black Facepaint];				break;
	case $effect[Fortunate Resolve]:			useItem = $item[Resolution: Be Luckier];		break;
	case $effect[Frenzied, Bloody]:				useSkill = $skill[Blood Frenzy];				break;
	case $effect[Fresh Scent]:					useItem = $item[deodorant];						break;
	case $effect[Frigidalmatian]:				useSkill = $skill[Frigidalmatian];				break;
	case $effect[Frog in Your Throat]:			useItem = $item[Frogade];						break;
	case $effect[From Nantucket]:				useItem = $item[Ye Olde Bawdy Limerick];		break;
	case $effect[Frost Tea]:					useItem = $item[cuppa Frost tea];				break;
	case $effect[Frostbeard]:					useSkill = $skill[Beardfreeze];					break;
	case $effect[Frosty]:						useItem = $item[Frost Flower];					break;
	case $effect[Frown]:						useSkill = $skill[Frown Muscles];				break;
	case $effect[Funky Coal Patina]:			useItem = $item[Coal Dust];						break;
	case $effect[Gelded]:						useItem = $item[Chocolate Filthy Lucre];		break;
	case $effect[Ghostly Shell]:
		if(acquireTotem())
		{
			useSkill = $skill[Ghostly Shell];
		}																						break;
	case $effect[The Glistening]:				useItem = $item[Vial of the Glistening];		break;
	case $effect[Glittering Eyelashes]:			useItem = $item[Glittery Mascara];				break;
	case $effect[Go Get \'Em\, Tiger!]:			useItem = $item[Ben-gal&trade; Balm];			break;
	case $effect[Got Milk]:						useItem = $item[Milk of Magnesium];				break;
	case $effect[Gothy]:						useItem = $item[Spooky Eyeliner];				break;
	case $effect[Gr8ness]:						useItem = $item[Potion of Temporary Gr8ness];	break;
	case $effect[Graham Crackling]:				useItem = $item[Heather Graham Cracker];		break;
	case $effect[Greasy Peasy]:					useItem = $item[Robot Grease];					break;
	case $effect[Greedy Resolve]:				useItem = $item[Resolution: Be Wealthier];		break;
	case $effect[Gristlesphere]:				useSkill = $skill[Gristlesphere];		break;
	case $effect[Gummed Shoes]:					useItem = $item[Shoe Gum];						break;
	case $effect[Gummi-Grin]:					useItem = $item[Gummi Turtle];					break;
	case $effect[Hairy Palms]:					useItem = $item[Orcish Hand Lotion];			break;
	case $effect[Ham-Fisted]:					useItem = $item[Vial of Hamethyst Juice];		break;
	case $effect[Hardened Fabric]:				useItem = $item[Fabric Hardener];				break;
	case $effect[Hardened Sweatshirt]:			useSkill = $skill[Magic Sweat];					break;
	case $effect[Hardly Poisoned At All]:		useSkill = $skill[Disco Nap];					break;
	case $effect[Healthy Blue Glow]:			useItem = $item[gold star];						break;
	case $effect[Heightened Senses]:			useItem = $item[airborne mutagen];				break;
	case $effect[Heart of Green]:			useItem = $item[green candy heart];				break;
	case $effect[Heart of Lavender]:			useItem = $item[lavender candy heart];				break;
	case $effect[Heart of Orange]:			useItem = $item[orange candy heart];				break;
	case $effect[Heart of Pink]:			useItem = $item[pink candy heart];				break;
	case $effect[Heart of White]:			useItem = $item[white candy heart];				break;
	case $effect[Heart of Yellow]:			useItem = $item[yellow candy heart];				break;
	case $effect[Hide of Sobek]:				useSkill = $skill[Hide of Sobek];				break;
	case $effect[High Colognic]:				useItem = $item[Musk Turtle];					break;
	case $effect[Hippy Stench]:					useItem = $item[reodorant];						break;
	case $effect[How to Scam Tourists]:			useItem = $item[How to Avoid Scams];			break;
	case $effect[Human-Beast Hybrid]:			useItem = $item[Gene Tonic: Beast];				break;
	case $effect[Human-Constellation Hybrid]:	useItem = $item[Gene Tonic: Constellation];		break;
	case $effect[Human-Demon Hybrid]:			useItem = $item[Gene Tonic: Demon];				break;
	case $effect[Human-Elemental Hybrid]:		useItem = $item[Gene Tonic: Elemental];			break;
	case $effect[Human-Fish Hybrid]:			useItem = $item[Gene Tonic: Fish];				break;
	case $effect[Human-Human Hybrid]:			useItem = $item[Gene Tonic: Dude];				break;
	case $effect[Human-Humanoid Hybrid]:		useItem = $item[Gene Tonic: Humanoid];			break;
	case $effect[Human-Machine Hybrid]:			useItem = $item[Gene Tonic: Construct];			break;
	case $effect[Human-Mer-kin Hybrid]:			useItem = $item[Gene Tonic: Mer-kin];			break;
	case $effect[Human-Pirate Hybrid]:			useItem = $item[Gene Tonic: Pirate];			break;
	case $effect[Hyperoffended]:						useItem = $item[donkey flipbook];		break;
	case $effect[Hyphemariffic]:				useItem = $item[Black Eyedrops];				break;
	case $effect[Icy Glare]:					useSkill = $skill[Icy Glare];					break;
	case $effect[Impeccable Coiffure]:			useSkill = $skill[Self-Combing Hair];			break;
	case $effect[Inigo\'s Incantation of Inspiration]:useSkill = $skill[Inigo\'s Incantation of Inspiration];break;
	case $effect[Incredibly Hulking]:			useItem = $item[Ferrigno\'s Elixir of Power];	break;
	case $effect[Industrial Strength Starch]:	useItem = $item[Industrial Strength Starch];	break;
	case $effect[Ink Cloud]:					useSkill = $skill[Ink Gland];						break;
	case $effect[Inked Well]:					useSkill = $skill[Squid Glands];				break;
	case $effect[Inky Camouflage]:	useItem = $item[Vial of Squid Ink];	break;
	case $effect[Inscrutable Gaze]:				useSkill = $skill[Inscrutable Gaze];			break;
	case $effect[Insulated Trousers]:			useItem = $item[Cold Powder];					break;
	case $effect[Intimidating Mien]:			useSkill = $skill[Intimidating Mien];			break;
	case $effect[Invisible Avatar]:					useSkill = $skill[none];						break;
	case $effect[Irresistible Resolve]:			useItem = $item[Resolution: Be Sexier];			break;
	case $effect[Jackasses\' Symphony of Destruction]:useSkill = $skill[Jackasses\' Symphony of Destruction];	break;
	case $effect[Jalape&ntilde;o Saucesphere]:	useSkill = $skill[Jalape&ntilde;o Saucesphere];	break;
	case $effect[Jingle Jangle Jingle]:
		if(acquireTotem())
		{
			useSkill = $skill[Jingle Bells];
		}																						break;
	case $effect[Joyful Resolve]:				useItem = $item[Resolution: Be Happier];		break;
	case $effect[Juiced and Jacked]:			useItem = $item[Pumpkin Juice];					break;
	case $effect[Juiced and Loose]:				useSkill = $skill[Steroid Bladder];				break;
	case $effect[Leash of Linguini]:
		if(pathHasFamiliar())
		{
			useSkill = $skill[Leash of Linguini];
		}																						break;
	case $effect[Leisurely Amblin\']:			useSkill = $skill[Walk: Leisurely Amble];		break;
	case $effect[Lion in Ambush]:				useItem = $item[Lion Musk];						break;
	case $effect[Liquidy Smoky]:				useItem = $item[Liquid Smoke];					break;
	case $effect[Lit Up]:						useItem = $item[Bottle of Lighter Fluid];		break;
	case $effect[Litterbug]:					useItem = $item[Old Candy Wrapper];				break;
	case $effect[Living Fast]:					useSkill = $skill[Live Fast];						break;
	case $effect[Locks Like the Raven]:			useItem = $item[Black No. 2];					break;
	case $effect[Loyal Tea]:					useItem = $item[cuppa Loyal Tea];				break;
	case $effect[Lucky Struck]:					useItem = $item[Lucky Strikes Holo-Record];		break;
	case $effect[Lycanthropy\, Eh?]:			useItem = $item[Weremoose Spit];				break;
	case $effect[Kindly Resolve]:				useItem = $item[Resolution: Be Kinder];			break;
	case $effect[Knob Goblin Perfume]:			useItem = $item[Knob Goblin Perfume];			break;
	case $effect[Knowing Smile]:				useSkill = $skill[Knowing Smile];				break;
	case $effect[Macaroni Coating]:				useSkill = $skill[none];						break;
	case $effect[The Magic Of LOV]:				useItem = $item[LOV Elixir #6];					break;
	case $effect[The Magical Mojomuscular Melody]:useSkill = $skill[The Magical Mojomuscular Melody];break;
	case $effect[Magnetized Ears]:				useSkill = $skill[Magnetic Ears];				break;
	case $effect[Majorly Poisoned]:				useSkill = $skill[Disco Nap];					break;
	case $effect[Manbait]:						useItem = $item[The Most Dangerous Bait];		break;
	case $effect[Mariachi Mood]:				useSkill = $skill[Moxie of the Mariachi];		break;
	case $effect[Marinated]:					useItem = $item[Bowl of Marinade];				break;
	case $effect[Mathematically Precise]:
		if(is_unrestricted($item[Crimbot ROM: Mathematical Precision]))
		{
			useSkill = $skill[Mathematical Precision];
		}																						break;
	case $effect[Mayeaugh]:						useItem = $item[Glob of Spoiled Mayo];			break;
	case $effect[Memories of Puppy Love]:		useItem = $item[Old Love Note];					break;
	case $effect[Merry Smithsness]:				useItem = $item[Flaskfull of Hollow];			break;
	case $effect[Mind Vision]:					useSkill = $skill[Intracranial Eye];			break;
	case $effect[Ministrations in the Dark]:	useItem = $item[EMD Holo-Record];				break;
	case $effect[The Moxie Of LOV]:				useItem = $item[LOV Elixir #9];					break;
	case $effect[The Moxious Madrigal]:			useSkill = $skill[The Moxious Madrigal];		break;
	case $effect[Muffled]:
		if(get_property("peteMotorbikeMuffler") == "Extra-Quiet Muffler")
		{
			useSkill = $skill[Rev Engine];
		}																						break;
	case $effect[Musk of the Moose]:			useSkill = $skill[Musk of the Moose];			break;
	case $effect[Musky]:						useItem = $item[Lynyrd Musk];					break;
	case $effect[Mutated]:						useItem = $item[Gremlin Mutagen];				break;
	case $effect[Mysteriously Handsome]:		useItem = $item[Handsomeness Potion];			break;
	case $effect[Mystically Oiled]:				useItem = $item[Ointment of the Occult];		break;
	case $effect[Nearly All-Natural]:			useItem = $item[bag of grain];					break;
	case $effect[Nearly Silent Hunting]:		useSkill = $skill[Silent Hunter];				break;
	case $effect[Neuroplastici Tea]:			useItem = $item[cuppa Neuroplastici tea];		break;
	case $effect[Neutered Nostrils]:			useItem = $item[Polysniff Perfume];				break;
	case $effect[Newt Gets In Your Eyes]:		useItem = $item[eyedrops of newt];				break;
	case $effect[Nigh-Invincible]:				useItem = $item[pixel star];					break;
	case $effect[Notably Lovely]:				useItem = $item[Confiscated Love Note];			break;
	case $effect[Obscuri Tea]:					useItem = $item[cuppa Obscuri tea];				break;
	case $effect[Ode to Booze]:					shrugAT($effect[Ode to Booze]);
												useSkill = $skill[The Ode to Booze];			break;
	case $effect[Of Course It Looks Great]:		useSkill = $skill[Check Hair];					break;
	case $effect[Oiled Skin]:					useItem = $item[Skin Oil];						break;
	case $effect[Oiled-Up]:						useItem = $item[Pec Oil];						break;
	case $effect[Oilsphere]:						useSkill = $skill[Oilsphere];						break;
	case $effect[OMG WTF]:						useItem = $item[Confiscated Cell Phone];		break;
	case $effect[One Very Clear Eye]:			useItem = $item[Cyclops Eyedrops];				break;
	case $effect[Orange Crusher]:				useItem = $item[Pulled Orange Taffy];			break;
	case $effect[Paging Betty]:					useItem = $item[Bettie Page];					break;
	case $effect[Pasta Eyeball]:				useSkill = $skill[none];						break;
	case $effect[Pasta Oneness]:				useSkill = $skill[Manicotti Meditation];		break;
	case $effect[Patent Aggression]:			useItem = $item[Patent Aggression Tonic];		break;
	case $effect[Patent Alacrity]:				useItem = $item[Patent Alacrity Tonic];			break;
	case $effect[Patent Avarice]:				useItem = $item[Patent Avarice Tonic];			break;
	case $effect[Patent Invisibility]:			useItem = $item[Patent Invisibility Tonic];		break;
	case $effect[Patent Prevention]:			useItem = $item[Patent Preventative Tonic];		break;
	case $effect[Patent Sallowness]:			useItem = $item[Patent Sallowness Tonic];		break;
	case $effect[Patience of the Tortoise]:		useSkill = $skill[Patience of the Tortoise];	break;
	case $effect[Patient Smile]:				useSkill = $skill[Patient Smile];				break;
	case $effect[Paul\'s Passionate Pop Song]:				useSkill = $skill[Paul\'s Passionate Pop Song];				break;
	case $effect[Penne Fedora]:					useSkill = $skill[none];						break;
	case $effect[Peppermint Bite]:				useItem = $item[Crimbo Peppermint Bark];		break;
	case $effect[Peppermint Twisted]:			useItem = $item[Peppermint Twist];				break;
	case $effect[Perceptive Pressure]:			useItem = $item[Pressurized Potion of Perception];	break;
	case $effect[Perspicacious Pressure]:		useItem = $item[Pressurized Potion of Perspicacity];break;
	case $effect[Phorcefullness]:				useItem = $item[Philter of Phorce];				break;
	case $effect[Physicali Tea]:				useItem = $item[cuppa Physicali tea];			break;
	case $effect[Pill Power]:
		if(item_amount($item[miniature power pill]) > 0)
		{
			useItem = $item[miniature power pill];
		}
		else
		{
			useItem = $item[power pill];
		}																						break;
	case $effect[Pill Party!]:					useItem = $item[Pill Cup];						break;
	case $effect[Pisces in the Skyces]:			useItem = $item[tobiko marble soda];			break;
	case $effect[Psalm of Pointiness]:			shrugAT($effect[Psalm of Pointiness]);
												useSkill = $skill[The Psalm of Pointiness];		break;
	case $effect[Prayer of Seshat]:				useSkill = $skill[Prayer of Seshat];			break;
	case $effect[Pride of the Puffin]:			useSkill = $skill[Pride of the Puffin];			break;
	case $effect[Polar Express]:				useItem = $item[Cloaca Cola Polar];				break;
	case $effect[Polka of Plenty]:				useSkill = $skill[The Polka of Plenty];			break;
	case $effect[Polonoia]:						useItem = $item[Polo Trophy];					break;
	case $effect[Power\, Man]:					useItem = $item[Power-Guy 2000 Holo-Record];	break;
	case $effect[Power Ballad of the Arrowsmith]:useSkill = $skill[The Power Ballad of the Arrowsmith];break;
	case $effect[Power of Heka]:				useSkill = $skill[Power of Heka];				break;
	case $effect[The Power Of LOV]:				useItem = $item[LOV Elixir #3];					break;
	case $effect[Prideful Strut]:				useSkill = $skill[Walk: Prideful Strut];		break;
	case $effect[Predjudicetidigitation]:	useItem = $item[worst candy];break;
	case $effect[Protection from Bad Stuff]:	useItem = $item[scroll of Protection from Bad Stuff];break;
	case $effect[Provocative Perkiness]:		useItem = $item[Libation of Liveliness];		break;
	case $effect[Puddingskin]:					useItem = $item[scroll of Puddingskin];			break;
	case $effect[Pulchritudinous Pressure]:		useItem = $item[Pressurized Potion of Pulchritude];break;
	case $effect[Punchable Face]:				useSkill = $skill[Extremely Punchable Face];	break;
	case $effect[Purity of Spirit]:				useItem = $item[cold-filtered water];			break;
	case $effect[Purr of the Feline]:			useSkill = $skill[Purr of the Feline];			break;
	case $effect[Purple Reign]:					useItem = $item[Pulled Violet Taffy];			break;
	case $effect[Puzzle Fury]:					useItem = $item[37x37x37 puzzle cube];			break;
	case $effect[Pyromania]:					useSkill = $skill[Pyromania];					break;
	case $effect[Quiet Desperation]:			useSkill = $skill[Quiet Desperation];			break;
	case $effect[Quiet Determination]:			useSkill = $skill[Quiet Determination];			break;
	case $effect[Quiet Judgement]:				useSkill = $skill[Quiet Judgement];				break;
	case $effect[\'Roids of the Rhinoceros]:	useItem = $item[Bottle of Rhinoceros Hormones];	break;
	case $effect[Rad-Pro Tected]:				useItem = $item[Rad-Pro (1 oz.)];				break;
	case $effect[Radiating Black Body&trade;]:	useItem = $item[Black Body&trade; Spray];		break;
	case $effect[Rage of the Reindeer]:			useSkill = $skill[Rage of the Reindeer];		break;
	case $effect[Rainy Soul Miasma]:
		if(item_amount($item[Thin Black Candle]) > 0)
		{
			useItem = $item[Thin Black Candle];
		}
		else if(item_amount($item[Drizzlers&trade; Black Licorice]) > 0)
		{
			useItem = $item[Drizzlers&trade; Black Licorice];
		}																						break;
	case $effect[Ready to Snap]:				useItem = $item[Ginger Snaps];					break;
	case $effect[Really Quite Poisoned]:		useSkill = $skill[Disco Nap];					break;
	case $effect[Record Hunger]:				useItem = $item[The Pigs Holo-Record];			break;
	case $effect[Red Lettered]:					useItem = $item[Red Letter];					break;
	case $effect[Red Door Syndrome]:			useItem = $item[Can of Black Paint];			break;
	case $effect[Reptilian Fortitude]:
		if(acquireTotem())
		{
			useSkill = $skill[Reptilian Fortitude];
		}																						break;
	case $effect[A Rose by Any Other Material]:	useItem = $item[Squeaky Toy Rose];				break;
	case $effect[Rosewater Mark]:				useItem = $item[Old Rosewater Cream];			break;
	case $effect[Rotten Memories]:				useSkill = $skill[Rotten Memories];				break;
	case $effect[Ruthlessly Efficient]:
		if(is_unrestricted($item[Crimbot ROM: Ruthless Efficiency]))
		{
			useSkill = $skill[Ruthless Efficiency];
		}																						break;
	case $effect[Salamander in Your Stomach]:	useItem = $item[Salamander Slurry];				break;
	case $effect[Saucemastery]:					useSkill = $skill[Sauce Contemplation];			break;
	case $effect[Sauce Monocle]:				useSkill = $skill[Sauce Monocle];				break;
	case $effect[Savage Beast Inside]:			useItem = $item[jar of &quot;Creole Lady&quot; marrrmalade];break;
	case $effect[Scarysauce]:					useSkill = $skill[Scarysauce];					break;
	case $effect[Scowl of the Auk]:				useSkill = $skill[Scowl of the Auk];			break;
	case $effect[Screaming! \ SCREAMING! \ AAAAAAAH!]:useSkill = $skill[Powerful Vocal Chords];			break;
	case $effect[Seal Clubbing Frenzy]:			useSkill = $skill[Seal Clubbing Frenzy];		break;
	case $effect[Sealed Brain]:					useItem = $item[Seal-Brain Elixir];				break;
	case $effect[Seeing Colors]:				useItem = $item[Funky Dried Mushroom];			break;
	case $effect[Sepia Tan]:					useItem = $item[Old Bronzer];					break;
	case $effect[Serendipi Tea]:				useItem = $item[cuppa Serendipi tea];			break;
	case $effect[Seriously Mutated]:			useItem = $item[Extra-Potent Gremlin Mutagen];	break;
	case $effect[Shield of the Pastalord]:
		useSkill = $skill[Shield of the Pastalord];
		if(my_class() != $class[Pastamancer])
		{
			buff = $effect[Flimsy Shield of the Pastalord];
		}
		break;
	case $effect[Shelter of Shed]:				useSkill = $skill[Shelter of Shed];				break;
	case $effect[Shrieking Weasel]:				useItem = $item[Shrieking Weasel Holo-Record];	break;
	case $effect[Simmering]:					useSkill = $skill[Simmer];						break;
	case $effect[Simply Invisible]:			useItem = $item[Invisibility Potion];		break;
	case $effect[Simply Irresistible]:			useItem = $item[Irresistibility Potion];		break;
	case $effect[Simply Irritable]:			useItem = $item[Irritability potion];		break;
	case $effect[Singer\'s Faithful Ocelot]:	useSkill = $skill[Singer\'s Faithful Ocelot];	break;
	case $effect[Sinuses For Miles]:			useItem = $item[Mick\'s IcyVapoHotness Inhaler];break;
	case $effect[Sleaze-Resistant Trousers]:	useItem = $item[Sleaze Powder];					break;
	case $effect[Sleazy Hands]:					useItem = $item[Lotion of Sleaziness];			break;
	case $effect[Slightly Larger Than Usual]:	useItem = $item[Giant Giant Moth Dust];			break;
	case $effect[Slinking Noodle Glob]:			useSkill = $skill[none];						break;
	case $effect[Smelly Pants]:					useItem = $item[Stench Powder];					break;
	case $effect[Smooth Movements]:				useSkill = $skill[Smooth Movement];				break;
	case $effect[Snarl of the Timberwolf]:		useSkill = $skill[Snarl of the Timberwolf];		break;
	case $effect[Snow Shoes]:					useItem = $item[Snow Cleats];					break;
	case $effect[Somewhat Poisoned]:			useSkill = $skill[Disco Nap];					break;
	case $effect[Song of Accompaniment]:		useSkill = $skill[Song of Accompaniment];		break;
	case $effect[Song of Battle]:				useSkill = $skill[Song of Battle];				break;
	case $effect[Song of Bravado]:				useSkill = $skill[Song of Bravado];				break;
	case $effect[Song of Cockiness]:			useSkill = $skill[Song of Cockiness];			break;
	case $effect[Song of Fortune]:				useSkill = $skill[Song of Fortune];				break;
	case $effect[Song of the Glorious Lunch]:	useSkill = $skill[Song of the Glorious Lunch];	break;
	case $effect[Song of the North]:			useSkill = $skill[Song of the North];			break;
	case $effect[Song of Sauce]:				useSkill = $skill[Song of Sauce];				break;
	case $effect[Song of Slowness]:				useSkill = $skill[Song of Slowness];			break;
	case $effect[Song of Solitude]:				useSkill = $skill[Song of Solitude];			break;
	case $effect[Song of Starch]:				useSkill = $skill[Song of Starch];				break;
	case $effect[The Sonata of Sneakiness]:		useSkill = $skill[The Sonata of Sneakiness];	break;
	case $effect[Soulerskates]:					useSkill = $skill[Soul Rotation];				break;
	case $effect[Sour Softshoe]:				useItem = $item[pulled yellow taffy];			break;
	case $effect[Spectral Awareness]: useSkill = $skill[Spectral Awareness]; break;
	case $effect[Spice Haze]:					useSkill = $skill[Bind Spice Ghost];			break;
	case $effect[Spiky Hair]:					useItem = $item[Super-Spiky Hair Gel];			break;
	case $effect[Spiky Shell]:
		if(acquireTotem())
		{
			useSkill = $skill[Spiky Shell];
		}																						break;
	case $effect[Spiritually Awake]:			useItem = $item[Holy Spring Water];				break;
	case $effect[Spiritually Aware]:			useItem = $item[Spirit Beer];					break;
	case $effect[Spiritually Awash]:			useItem = $item[Sacramental Wine];				break;
	case $effect[Spiro Gyro]:					useItem = $item[Programmable Turtle];			break;
	case $effect[Spooky Hands]:					useItem = $item[Lotion of Spookiness];			break;
	case $effect[Spooky Weapon]:				useItem = $item[Spooky Nuggets];				break;
	case $effect[Spookypants]:					useItem = $item[Spooky Powder];					break;
	case $effect[Springy Fusilli]:				useSkill = $skill[Springy Fusilli];				break;
	case $effect[Squatting and Thrusting]:		useItem = $item[Squat-Thrust Magazine];			break;
	case $effect[Stabilizing Oiliness]:			useItem = $item[Oil of Stability];				break;
	case $effect[Standard Issue Bravery]:		useItem = $item[CSA Bravery Badge];				break;
	case $effect[Steely-Eyed Squint]:			useSkill = $skill[Steely-Eyed Squint];			break;
	case $effect[Steroid Boost]:				useItem = $item[Knob Goblin Steroids];			break;
	case $effect[Stevedave\'s Shanty of Superiority]:useSkill = $skill[Stevedave\'s Shanty of Superiority];			break;
	case $effect[Stickler for Promptness]:		useItem = $item[Potion of Punctual Companionship];	break;
	case $effect[Stinky Hands]:					useItem = $item[Lotion of Stench];				break;
	case $effect[Stinky Weapon]:				useItem = $item[Stench Nuggets];				break;
	case $effect[Stone-Faced]:					useItem = $item[Stone Wool];					break;
	case $effect[Strong Grip]:					useItem = $item[Finger Exerciser];				break;
	case $effect[Strong Resolve]:				useItem = $item[Resolution: Be Stronger];		break;
	case $effect[Sugar Rush]:
		foreach it in $items[Crimbo Fudge, Crimbo Peppermint Bark, Crimbo Candied Pecan, Breath Mint, Tasty Fun Good Rice Candy, That Gum You Like, Angry Farmer Candy]
		{
			if(item_amount(it) > 0)
			{
				useItem = it;
			}
		}																						break;
	case $effect[Superdrifting]:				useItem = $item[Superdrifter Holo-Record];		break;
	case $effect[Superheroic]:					useItem = $item[Confiscated Comic Book];		break;
	case $effect[Superhuman Sarcasm]:			useItem = $item[Serum of Sarcasm];				break;
	case $effect[Suspicious Gaze]:				useSkill = $skill[Suspicious Gaze];				break;
	case $effect[Sweet Heart]:					useItem = $item[love song of sugary cuteness];			break;
	case $effect[Sweet\, Nuts]:					useItem = $item[Crimbo Candied Pecan];			break;
	case $effect[Sweetbreads Flamb&eacute;]:	useItem = $item[Greek Fire];					break;
	case $effect[Takin\' It Greasy]:			useSkill = $skill[Grease Up];					break;
	case $effect[Taunt of Horus]:				useItem = $item[Talisman of Horus];				break;
	case $effect[Temporary Lycanthropy]:		useItem = $item[Blood of the Wereseal];			break;
	case $effect[Tenacity of the Snapper]:
		if(acquireTotem())
		{
			useSkill = $skill[Tenacity of the Snapper];
		}																						break;
	case $effect[There is a Spoon]:				useItem = $item[Dented Spoon];					break;
	case $effect[This is Where You\'re a Viking]:useItem = $item[VYKEA woadpaint];				break;
	case $effect[Throwing Some Shade]:			useItem = $item[Shady Shades];					break;
	case $effect[Ticking Clock]:				useItem = $item[Cheap wind-up Clock];			break;
	case $effect[Toad in the Hole]:				useItem = $item[Anti-anti-antidote];			break;
	case $effect[Tomato Power]:					useItem = $item[Tomato Juice of Powerful Power];break;
	case $effect[Tortious]:						useItem = $item[Mocking Turtle];				break;
	case $effect[Triple-Sized]:					useSkill = $skill[none];						break;
	case $effect[Truly Gritty]:					useItem = $item[True Grit];						break;
	case $effect[Twen Tea]:						useItem = $item[cuppa Twen tea];				break;
	case $effect[Twinkly Weapon]:				useItem = $item[Twinkly Nuggets];				break;
	case $effect[Unmuffled]:
		if(get_property("peteMotorbikeMuffler") == "Extra-Loud Muffler")
		{
			useSkill = $skill[Rev Engine];
		}																						break;
	case $effect[Unrunnable Face]:				useItem = $item[Runproof Mascara];				break;
	case $effect[Unusual Perspective]:			useItem = $item[Unusual Oil];					break;
	case $effect[Ur-Kel\'s Aria of Annoyance]:	useSkill = $skill[Ur-Kel\'s Aria of Annoyance];	break;
	case $effect[Using Protection]:				useItem = $item[Orcish Rubber];					break;
	case $effect[Visions of the Deep Dark Deeps]:useSkill = $skill[Deep Dark Visions];			break;
	case $effect[Vital]:						useItem = $item[Doc Galaktik\'s Vitality Serum];break;
	case $effect[Vitali Tea]:					useItem = $item[cuppa Vitali tea];				break;
	case $effect[Walberg\'s Dim Bulb]:			useSkill = $skill[Walberg\'s Dim Bulb];			break;
	case $effect[WAKKA WAKKA WAKKA]:			useItem = $item[Yellow Pixel Potion];			break;
	case $effect[Wasabi With You]:				useItem = $item[Wasabi Marble Soda];			break;
	case $effect[Well-Oiled]:					useItem = $item[Oil of Parrrlay];				break;
	case $effect[Well-Swabbed Ear]:				useItem = $item[Swabbie&trade; Swab];			break;
	case $effect[Wet and Greedy]:				useItem = $item[Goblin Water];					break;
	case $effect[Whispering Strands]:			useSkill = $skill[none];						break;
	case $effect[Wisdom of Thoth]:				useSkill = $skill[Wisdom of Thoth];				break;
	case $effect[Wit Tea]:						useItem = $item[cuppa Wit tea];					break;
	case $effect[Woad Warrior]:					useItem = $item[Pygmy Pygment];					break;
	case $effect[Wry Smile]:					useSkill = $skill[Wry Smile];					break;
	case $effect[Yoloswagyoloswag]:				useItem = $item[Yolo&trade; Chocolates];		break;
	case $effect[You Read the Manual]:			useItem = $item[O\'Rly Manual];					break;
	case $effect[Your Fifteen Minutes]:			useSkill = $skill[Fifteen Minutes of Flame];	break;
	default: abort("Effect (" + buff + ") is not known to us. Beep.");							break;
	}

	if(my_class() != $class[Pastamancer])
	{
		switch(buff)
		{
		case $effect[Bloody Potato Bits]:		useSkill = $skill[Bind Vampieroghi];			break;
		case $effect[Macaroni Coating]:			useSkill = $skill[Bind Undead Elbow Macaroni];	break;
		case $effect[Pasta Eyeball]:			useSkill = $skill[Bind Lasagmbie];				break;
		case $effect[Penne Fedora]:				useSkill = $skill[Bind Penne Dreadful];			break;
		case $effect[Slinking Noodle Glob]:		useSkill = $skill[Bind Vermincelli];			break;
		case $effect[Spice Haze]:				useSkill = $skill[Bind Spice Ghost];			break;
		case $effect[Whispering Strands]:		useSkill = $skill[Bind Angel Hair Wisp];		break;
		}
	}

	if(my_class() == $class[Turtle Tamer])
	{
		switch(buff)
		{
		case $effect[Boon of the War Snapper]:
			useSkill = $skill[Spirit Boon];
			if((have_effect($effect[Glorious Blessing of the War Snapper]) == 0) && (have_effect($effect[Grand Blessing of the War Snapper]) == 0) && (have_effect($effect[Blessing of the War Snapper]) == 0))
			{
				useSkill = $skill[none];
			}
			break;
		case $effect[Boon of She-Who-Was]:
			useSkill = $skill[Spirit Boon];
			if((have_effect($effect[Glorious Blessing of She-Who-Was]) == 0) && (have_effect($effect[Grand Blessing of She-Who-Was]) == 0) && (have_effect($effect[Blessing of She-Who-Was]) == 0))
			{
				useSkill = $skill[none];
			}
			break;
		case $effect[Boon of the Storm Tortoise]:
			useSkill = $skill[Spirit Boon];
			if((have_effect($effect[Glorious Blessing of the Storm Tortoise]) == 0) && (have_effect($effect[Grand Blessing of the Storm Tortoise]) == 0) && (have_effect($effect[Blessing of the Storm Tortoise]) == 0))
			{
				useSkill = $skill[none];
			}
			break;

		case $effect[Disdain of the War Snapper]:
			useSkill = $skill[none];
			if((have_effect($effect[Glorious Blessing of the War Snapper]) == 0) && (have_effect($effect[Grand Blessing of the War Snapper]) == 0) && (have_effect($effect[Blessing of the War Snapper]) == 0))
			{
				useSkill = $skill[Blessing of the War Snapper];
			}
			if((have_effect($effect[Glorious Blessing of the Storm Tortoise]) != 0) || (have_effect($effect[Grand Blessing of the Storm Tortoise]) != 0) || (have_effect($effect[Blessing of the Storm Tortoise]) != 0))
			{
				useSkill = $skill[none];
			}
			if((have_effect($effect[Glorious Blessing of She-Who-Was]) != 0) || (have_effect($effect[Grand Blessing of She-Who-Was]) != 0) || (have_effect($effect[Blessing of She-Who-Was]) != 0))
			{
				useSkill = $skill[none];
			}
			break;
		case $effect[Disdain of She-Who-Was]:
			useSkill = $skill[none];
			if((have_effect($effect[Glorious Blessing of She-Who-Was]) == 0) && (have_effect($effect[Grand Blessing of She-Who-Was]) == 0) && (have_effect($effect[Blessing of She-Who-Was]) == 0))
			{
				useSkill = $skill[Blessing of She-Who-Was];
			}
			if((have_effect($effect[Glorious Blessing of the Storm Tortoise]) != 0) || (have_effect($effect[Grand Blessing of the Storm Tortoise]) != 0) || (have_effect($effect[Blessing of the Storm Tortoise]) != 0))
			{
				useSkill = $skill[none];
			}
			break;
		case $effect[Disdain of the Storm Tortoise]:
			useSkill = $skill[none];
			if((have_effect($effect[Glorious Blessing of the Storm Tortoise]) == 0) && (have_effect($effect[Grand Blessing of the Storm Tortoise]) == 0) && (have_effect($effect[Blessing of the Storm Tortoise]) == 0))
			{
				useSkill = $skill[Blessing of the Storm Tortoise];
			}
			break;
		}
	}
	else
	{
		switch(buff)
		{
		case $effect[Disdain of She-Who-Was]:
			useSkill = $skill[Blessing of She-Who-Was];
			if(have_effect($effect[Disdain of the War Snapper]) > 0)
			{
				useSkill = $skill[none];
			}
			break;
		case $effect[Disdain of the Storm Tortoise]:
			useSkill = $skill[Blessing of the Storm Tortoise];
			if((have_effect($effect[Disdain of She-Who-Was]) > 0) || (have_effect($effect[Disdain of the War Snapper]) > 0))
			{
				useSkill = $skill[none];
			}
			break;
		case $effect[Disdain of the War Snapper]:
			useSkill = $skill[Blessing of the War Snapper];
			break;
		}
	}

	if (buff == $effect[Triple-Sized])
	{
		if (speculative)
		{
			return auto_powerfulGloveCharges() >= 5;
		}
		else
		{
			return auto_powerfulGloveStats();
		}
	}

	if (buff == $effect[Invisible Avatar])
	{
		if (speculative)
		{
			return auto_powerfulGloveCharges() >= 5;
		}
		else
		{
			return auto_powerfulGloveNoncombat();
		}
	}

	if ($effects[Feeling Lonely, Feeling Excited, Feeling Nervous, Feeling Peaceful] contains buff && auto_haveEmotionChipSkills())
	{
		skill feeling = buff.to_skill();
		if (speculative)
		{
			return feeling.timescast < feeling.dailylimit;
		}
		else if (feeling.timescast < feeling.dailylimit)
		{
			useSkill = buff.to_skill();
			handleTracker(useSkill, "auto_otherstuff");
		}
		else
		{
			return false;
		}
	}

	boolean[effect] falloutEffects = $effects[Drunk and Avuncular, Lucky Struck, Ministrations in the Dark, Power\, Man, Record Hunger, Shrieking Weasel, Superdrifting];
	if(falloutEffects contains buff)
	{
		if(!possessEquipment($item[Wrist-Boy]))
		{
			return false;
		}
		if($effects[Drunk and Avuncular, Record Hunger] contains buff)
		{
			if(inAftercore())
			{
				return false;
			}
			if(have_effect(buff) >= 3)
			{
				return false;
			}
		}
		foreach ef in falloutEffects
		{
			if((have_effect(ef) > 0) && (ef != buff))
			{
				uneffect(ef);
			}
		}
	}

	if(useItem != $item[none])
	{
		return buffMaintain(useItem, buff, casts, turns, speculative);
	}
	if(useSkill != $skill[none])
	{
		return buffMaintain(useSkill, buff, mp_min, casts, turns, speculative);
	}
	return false;
}

boolean buffMaintain(effect buff, int mp_min, int casts, int turns)
{
	return buffMaintain(buff, mp_min, casts, turns, false);
}

// Checks to see if we are already wearing a facial expression before using buffMaintain
//	if an expression is REQUIRED force it using buffMaintain
boolean auto_faceCheck(string face)
{
	boolean[effect] FacialExpressions = $effects[Snarl of the Timberwolf, Scowl of the Auk, Stiff Upper Lip, Patient Smile, Quiet Determination, Arched Eyebrow of the Archmage, Wizard Squint, Quiet Judgement, Icy Glare, Wry Smile, Disco Leer, Disco Smirk, Suspicious Gaze, Knowing Smile, Quiet Desperation, Inscrutable Gaze];
	boolean CanEmote = true;

	foreach FExp in FacialExpressions
	{
		if(have_effect(FExp) > 0)
		{
			CanEmote = false;
		}
	}

	if(CanEmote)
	{
		buffMaintain(to_effect(face), 0, 1, 1);
	}
	else
	{
		auto_log_debug("Can not get " + face + " expression as we are already emoting.");
		return false;
	}

	return true;
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
	if (auto_haveKramcoSausageOMatic() && auto_sausageFightsToday() < 9)
	{
		return true;
	}
	else if (auto_haveVotingBooth() && get_property("_voteFreeFights").to_int() < 3)
	{
		return true;
	}
	else if (my_daycount() < 2 && (auto_haveVotingBooth() || auto_haveKramcoSausageOMatic()))
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
	
	return is_unrestricted(it);
}

boolean auto_is_valid(familiar fam)
{
	if(is100FamRun()){
		return to_familiar(get_property("auto_100familiar")) == fam;
	}
	return bees_hate_usable(fam.to_string()) && glover_usable(fam.to_string()) && is_unrestricted(fam);
}

boolean auto_is_valid(skill sk)
{
	//do not check check for B in bees hate you path. it only restricts items and not skills.
	return (glover_usable(sk.to_string()) || sk.passive) && bat_skillValid(sk) && zelda_skillValid(sk) && is_unrestricted(sk);
}

string auto_log_level_threshold(){
	static string logging_property = "auto_logLevel";
	if(!property_exists(logging_property)){
		set_property(logging_property, "info");
	}
	return get_property(logging_property);
}

int auto_log_level(string level){
	static int[string] log_levels = {
		"critical": 1,
		"crit": 1,
		"error": 2,
		"err": 2,
		"warning": 3,
		"warn": 3,
		"info": 4,
		"debug": 5,
		"trace": 6
	};

	level = level.to_lower_case();
	if(log_levels contains level){
		return log_levels[level];
	} else{
		return log_levels["info"];
	}
}

boolean auto_log(string s, string color, string log_level){
	int threshold = auto_log_level(auto_log_level_threshold());
	int level = auto_log_level(log_level);
	if(level <= threshold){
		print("["+log_level.to_upper_case()+"] - " + s, color);
		return true;
	}
	return false;
}

boolean auto_log_critical(string s, string color){
	return auto_log(s, color, "critical");
}

boolean auto_log_critical(string s){
	return auto_log(s, "red", "critical");
}

boolean auto_log_error(string s, string color){
	return auto_log(s, color, "critical");
}

boolean auto_log_error(string s){
	return auto_log(s, "red", "error");
}

boolean auto_log_warning(string s, string color){
	return auto_log(s, color, "warning");
}

boolean auto_log_warning(string s){
	return auto_log(s, "orange", "warning");
}

boolean auto_log_info(string s, string color){
	return auto_log(s, color, "info");
}

boolean auto_log_info(string s){
	return auto_log(s, "blue", "info");
}

boolean auto_log_debug(string s, string color){
	return auto_log(s, color, "debug");
}

boolean auto_log_debug(string s){
	return auto_log(s, "black", "debug");
}

boolean auto_log_trace(string s, string color){
	return auto_log(s, color, "trace");
}

boolean auto_log_trace(string s){
	return auto_log(s, "black", "trace");
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
			// data: The text name of the path, as returned by my_path()
			// You must be currently on that path
			// No safety checking possible here, so hopefully you don't misspell anything
			case "path":
				return condition_data == auto_my_path();
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
				if(my_class() == $class[Avatar of Sneaky Pete] && get_property("makeFriendsMonster").to_monster() == check_sniffed)
					return true;
				if($classes[Cow Puncher, Beanslinger, Snake Oiler] contains my_class() && get_property("longConMonster").to_monster() == check_sniffed)
					return true;
				if(my_class() == $class[Vampyre] && get_property("auto_bat_soulmonster").to_monster() == check_sniffed)
					return true;
				if(get_property("_gallapagosMonster").to_monster() == check_sniffed)
					return true;
				if(get_property("_latteMonster").to_monster() == check_sniffed)
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
		auto_log_error("Could not load autoscend_monsters.txt. This is bad!", "red");
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
	set_location(locCache);
	return toSniff[enemy];
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



void auto_interruptCheck()
{
	if(get_property("auto_interrupt").to_boolean())
	{
		set_property("auto_interrupt", false);
		restoreAllSettings();
		abort("auto_interrupt detected and aborting, auto_interrupt disabled.");
	}
	else if (get_property("auto_debugging").to_boolean())
	{
		set_property("auto_interrupt", true);
		auto_log_info("auto_debugging detected, auto_interrupt enabled.");
	}
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

	if(auto_my_path() == "One Crazy Random Summer")
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
			if(get_property("walfordBucketItem") == "rain" && equipped_item($slot[off-hand]) == $item[Walford's bucket])
			{
				setFlavour($element[hot]); // doing 100 hot damage in a fight will fill bucket faster
				return true;
			}
			// INTENTIONAL LACK OF BREAK
		case $location[VYKEA]:
			if(get_property("walfordBucketItem") == "ice" && equipped_item($slot[off-hand]) == $item[Walford's bucket])
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
		auto_log_error("Could not load autoscend_items.txt! This is bad!", "red");
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
	// This just does the math for comparing vs. the Cap. If no cap is set then ML is virtually unlimited.
	int remainingMLToCap()
	{
		int MLToCap = 0;

		if(get_property("auto_MLSafetyLimit") == "")
		{
			MLToCap = 999999;
		}
		else if(monster_level_adjustment() < get_property("auto_MLSafetyLimit").to_int())
		{
			MLToCap = get_property("auto_MLSafetyLimit").to_int() - monster_level_adjustment();
		}

		return MLToCap;
	}

	// Don't try to set the MCD if in KoE
	if(!in_koe())
	{
		if (current_mcd() > remainingMLToCap())
		{
			auto_change_mcd(remainingMLToCap());
		}
		else
		{
			auto_change_mcd(11);
		}
	}

	return true;
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
				buffMaintain(eff, 0, 1, 1);
			}
		}
	}

// ToML >= U >= 30
	UrKelCheck(ToML, auto_convertDesiredML(ToML), 30);

// 30
	// Start with the biggest and drill down for max ML
	tryEffects($effects[Ceaseless Snarling, Punchable Face]);

// 29 >= U >= 25
	UrKelCheck(ToML, 29, 25);


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

// Customizable - For variable effects that we can use to fill in the corners
	// Fill in the remainder with MCD
	if (!($locations[The Boss Bat\'s Lair, Haert of the Cyrpt, Throne Room] contains my_location()))
	{
	  auto_setMCDToCap();
	}

	return true;
}

// Called in PreAdv right before equipping to make sure that any ML Limit we have specified is in the maximize string IF +/-ML is not in string already
boolean enforceMLInPreAdv()
{
	if((get_property("auto_MLSafetyLimit") != "") && (!contains_text(get_property("auto_maximize_current"), "ml")))
	{
		addToMaximize("ml " + get_property("auto_MLSafetyLimit").to_int() + "max");
	}

	return true;
}



// ADVENTURE FORCING FUNCTIONS
boolean auto_canForceNextNoncombat()
{
	if (isActuallyEd())
	{
		return auto_pillKeeperFreeUseAvailable()
		|| (!get_property("_claraBellUsed").to_boolean() && (item_amount($item[Clara\'s Bell]) > 0) && auto_is_valid($item[Clara\'s Bell]));
	}
	return auto_pillKeeperAvailable()
	|| (!get_property("_claraBellUsed").to_boolean() && (item_amount($item[Clara\'s Bell]) > 0) && auto_is_valid($item[Clara\'s Bell]))
	|| (item_amount($item[stench jelly]) > 0 && auto_is_valid($item[stench jelly]) && spleen_left() < $item[stench jelly].spleen);
}

boolean _auto_forceNextNoncombat()
{
	// Use stench jelly or other item to set the combat rate to zero until the next noncombat.

	boolean ret = false;
	if(auto_pillKeeperFreeUseAvailable())
	{
		ret = auto_pillKeeper("noncombat");
		if(ret) {
			set_property("auto_forceNonCombatSource", "pillkeeper");
		}
	}
	else if(!get_property("_claraBellUsed").to_boolean() && (item_amount($item[Clara\'s Bell]) > 0))
	{
		ret = use(1, $item[Clara\'s Bell]);
		if(ret) {
			set_property("auto_forceNonCombatSource", "clara's bell");
		}
	}
	else if(item_amount($item[stench jelly]) > 0 && auto_is_valid($item[stench jelly]))
	{
		ret = autoChew(1, $item[stench jelly]);
		if(ret) {
			set_property("auto_forceNonCombatSource", "stench jelly");
		}
	}
	else if(auto_pillKeeperAvailable() && !isActuallyEd()) // don't use Spleen as Ed, it's his main source of adventures.
	{
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

boolean auto_forceNextNoncombat()
{
	if(auto_haveQueuedForcedNonCombat())
	{
		auto_log_warning("Trying to force a noncombat adventure, but I think we've already forced one...", "red");
		return true;
	}
	if (_auto_forceNextNoncombat())
	{
		auto_log_info("Next noncombat adventure has been forced...", "blue");
		return true;
	}
	return false;
}

boolean auto_haveQueuedForcedNonCombat()
{
	// This isn't always reset properly: see __MONSTERS_FOLLOWING_NONCOMBATS in auto_post_adv.ash
	return get_property("auto_forceNonCombatSource") != "";
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
		if((item_amount(squeezebox) > 0) && (auto_is_valid(squeezebox)))
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
		buffMaintain($effect[Spiky Shell], 0, 1, 1);					//8 MP
		buffMaintain($effect[Jalape&ntilde;o Saucesphere], 0, 1, 1);	//5 MP
		buffMaintain($effect[Scarysauce], 0, 1, 1);						//10 MP
	}
	
	//1MP Non-Combat skills from each class
	buffMaintain($effect[Seal Clubbing Frenzy], 0, 1, 1);
	buffMaintain($effect[Patience of the Tortoise], 0, 1, 1);
	buffMaintain($effect[Pasta Oneness], 0, 1, 1);
	buffMaintain($effect[Saucemastery], 0, 1, 1);
	buffMaintain($effect[Disco State of Mind], 0, 1, 1);
	buffMaintain($effect[Mariachi Mood], 0, 1, 1);

	//Seal clubber Non-Combat skills
	buffMaintain($effect[Blubbered Up], 0, 1, 1);						//7 MP
	buffMaintain($effect[Rage of the Reindeer], 0, 1, 1);				//10 MP
	buffMaintain($effect[A Few Extra Pounds], 0, 1, 1);					//10 MP
	
	//Turtle Tamer Non-Combat skills
	if(!hasTTBlessing())
	{
		buffMaintain($effect[Blessing of the War Snapper], 0, 1, 1);	//15 MP. other blessings too expensive.
	}
	
	//Pastamancer Non-Combat skills
	buffMaintain($effect[Springy Fusilli], 0, 1, 1);					//10 MP
	buffMaintain($effect[Shield of the Pastalord], 0, 1, 1);			//20 MP
	buffMaintain($effect[Leash of Linguini], 0, 1, 1);					//12 MP
	
	//Sauceror Non-Combat skills
	buffMaintain($effect[Sauce Monocle], 0, 1, 1);						//20 MP

	//Disco Bandit Non-Combat skills
	buffMaintain($effect[Disco Fever], 0, 1, 1);						//10 MP
	
	//Turtle Tamer Buffs
	buffMaintain($effect[Ghostly Shell], 0, 1, 1);						//6 MP
	buffMaintain($effect[Tenacity of the Snapper], 0, 1, 1);			//8 MP
	buffMaintain($effect[Empathy], 0, 1, 1);							//15 MP
	buffMaintain($effect[Reptilian Fortitude], 0, 1, 1);				//8 MP
	buffMaintain($effect[Astral Shell], 0, 1, 1);						//10 MP
	buffMaintain($effect[Jingle Jangle Jingle], 0, 1, 1);				//5 MP
	buffMaintain($effect[Curiosity of Br\'er Tarrypin], 0, 1, 1);		//5 MP
	
	//Sauceror Buffs
	buffMaintain($effect[Elemental Saucesphere], 0, 1, 1);				//10 MP
	buffMaintain($effect[Antibiotic Saucesphere], 0, 1, 1);				//15 MP
	
	//Accordion Thief Buffs. We are not shrugging so it will only apply new ones if we have space for them
	buffMaintain($effect[The Moxious Madrigal], 0, 1, 1);				//2 MP
	buffMaintain($effect[The Magical Mojomuscular Melody], 0, 1, 1);	//3 MP
	buffMaintain($effect[Cletus\'s Canticle of Celerity], 0, 1, 1);		//4 MP
	buffMaintain($effect[Power Ballad of the Arrowsmith], 0, 1, 1);		//5 MP
	buffMaintain($effect[Polka of Plenty], 0, 1, 1);					//7 MP
	
	//Mutually exclusive effects
	if(have_effect($effect[Musk of the Moose]) == 0 && have_effect($effect[Hippy Stench]) == 0)
	{
		buffMaintain($effect[Smooth Movements], 0, 1, 1);				//10 MP
	}
	if(have_effect($effect[Smooth Movements]) == 0 && have_effect($effect[Fresh Scent]) == 0)
	{
		buffMaintain($effect[Musk of the Moose], 0, 1, 1);				//10 MP
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

float npcStoreDiscountMulti()
{
	//calculates a multiplier to be applied to store prices for our current discount for NPC stores.
	//does not bother with sleaze jelly or Post-holiday sale coupon
	
	float retval = 1.0;
	
	if(auto_have_skill($skill[Five Finger Discount]))
	{
		retval -= 0.05;
	}
	if(possessEquipment($item[Travoltan trousers]) && auto_is_valid($item[Travoltan trousers]))
	{
		retval -= 0.05;
	}
	
	return retval;
}

int meatReserve()
{
	//the amount of meat we want to reserve for quest usage when performing a restore
	int reserve_extra = 0;		//extra reserved for various reasons
	if(in_kolhs())
	{
		reserve_extra += 100;
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
	my_path() != "Way of the Surprising Fist")							//costs 5 meat total in way of the surprising fist. no need to track that
	{
		reserve_diary += 500;		//1 vacation. no need to count script. we don't pull it or get it prematurely.
		
		//cannot just use npc_price() for [forged identification documents] because they are not always available. it would return 0.
		if(item_amount($item[forged identification documents]) == 0)
		{
			reserve_diary += 5000 * npcStoreDiscountMulti();
		}
	}
	
	//how much do we reserve for unlocking mysterious island?
	if(get_property("lastIslandUnlock").to_int() < my_ascensions())		//need to unlock island
	{
		reserve_island += 1500;		//3 vacations. no need to count script. we don't pull it or get it prematurely.
		if(item_amount($item[dingy planks]) == 0)
		{
			reserve_island += 400 * npcStoreDiscountMulti();
		}
	}
	
	return reserve_gnasir + reserve_diary + reserve_island + reserve_extra;
}

// Check to see if we can untinker.
boolean canUntinker()
{
   return get_property("questM01Untinker") == "finished";
}
