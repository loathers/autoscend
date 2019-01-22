script "cc_util.ash";

// Public Prototypes
void debugMaximize(string req, int meat);			//This function will be removed.
boolean ccMaximize(string req, boolean simulate);
boolean ccMaximize(string req, int maxPrice, int priceLevel, boolean simulate);
aggregate ccMaximize(string req, int maxPrice, int priceLevel, boolean simulate, boolean includeEquip);
int doNumberology(string goal);
int doNumberology(string goal, string option);
int doNumberology(string goal, boolean doIt);
int doNumberology(string goal, boolean doIt, string option);
boolean handleBarrelFullOfBarrels(boolean daily);
boolean canYellowRay();
string yellowRayCombatString();
int solveCookie();
boolean use_barrels();
int ccCraft(string mode, int count, item item1, item item2);
int[item] cc_get_campground();
int towerKeyCount();
boolean haveSpleenFamiliar();
boolean considerGrimstoneGolem(boolean bjornCrown);
float elemental_resist_value(int resistance);
int elemental_resist(element goal);
boolean uneffect(effect toRemove);
boolean organsFull();
boolean set_property_ifempty(string setting, string change);
boolean restore_property(string setting, string source);
boolean clear_property_if(string setting, string cond);
int doRest();
boolean acquireMP(int goal);
boolean acquireMP(int goal, boolean buyIt);
boolean acquireGumItem(item it);
boolean acquireHermitItem(item it);
boolean isHermitAvailable();
boolean isGeneralStoreAvailable();
boolean isGalaktikAvailable();
boolean isUnclePAvailable();
boolean isFreeMonster(monster mon);
boolean isProtonGhost(monster mon);
boolean isGhost(monster mon);
boolean instakillable(monster mon);
boolean in_ronin();
boolean cc_autosell(int quantity, item toSell);
boolean forceEquip(slot sl, item it);
item whatHiMein();
int maxSealSummons();
string statCard();
effect whatStatSmile();
void tootGetMeat();
boolean ovenHandle();
boolean isGuildClass();
boolean handleCopiedMonster(item itm);
boolean handleCopiedMonster(item itm, string option);
boolean handleSealNormal(item it);
boolean handleSealNormal(item it, string option);
boolean handleSealAncient();
boolean handleSealAncient(string option);
boolean handleSealElement(element flavor);
boolean handleSealElement(element flavor, string option);
void handleTracker(item used, string tracker);
void handleTracker(monster enemy, string tracker);
void handleTracker(monster enemy, skill toTrack, string tracker);
void handleTracker(monster enemy, string toTrack, string tracker);
void handleTracker(monster enemy, item toTrack, string tracker);
int internalQuestStatus(string prop);
string runChoice(string page_text);
int turkeyBooze();
int amountTurkeyBooze();
int numPirateInsults();
int fastenerCount();
int lumberCount();
skill preferredLibram();
boolean playwith(item toy, string prop);
boolean playwith(skill sk, string prop);
boolean ok_skill(skill sk, string prop);
boolean haveAny(boolean[item] array);
boolean have_skills(boolean[skill] array);
int spleen_left();
int stomach_left();
int fullness_left();
int inebriety_left();
void pullAll(item it);
void pullAndUse(item it, int uses);
boolean pullXWhenHaveY(item it, int howMany, int whenHave);
effect[item] allBangPotions();
int numPotionsFound(effect need);
item bangPotionNeeded(effect need);
boolean solveBangPotion(effect need);
boolean pulverizeThing(item it);
boolean buy_item(item it, int quantity, int maxprice);
string tryBeerPong();
boolean useCocoon();
boolean hasShieldEquipped();
void shrugAT();
void shrugAT(effect anticipated);
boolean buyUpTo(int num, item it);
boolean buyUpTo(int num, item it, int maxprice);
boolean buffMaintain(effect buff, int mp_min, int casts, int turns);
effect effectNeededFirstGate(string data);
boolean buyableMaintain(item toMaintain, int howMany);
boolean buyableMaintain(item toMaintain, int howMany, int meatMin);
boolean buyableMaintain(item toMaintain, int howMany, int meatMin, boolean condition);
int ns_crowd1();
stat ns_crowd2();
element ns_crowd3();
element ns_hedge1();
element ns_hedge2();
element ns_hedge3();
void woods_questStart();			//From Bale\'s woods.ash relay mod.
int howLongBeforeHoloWristDrop();
boolean is_avatar_potion(item it);	//From Veracity\'s "avatar potion" post
boolean lastAdventureSpecialNC();
//boolean zoneNonCombat(location loc);
//boolean zoneCombat(location loc);
//boolean zoneMeat(location loc);
//boolean zoneItem(location loc);
boolean backupSetting(string setting, string newValue);
boolean restoreSetting(string setting);
boolean restoreAllSettings();
int[monster] banishedMonsters();
boolean isBanished(monster enemy);
boolean startArmorySubQuest();
boolean startMeatsmithSubQuest();
boolean startGalaktikSubQuest();
string trim(string input);
boolean isOverdueDigitize();
boolean isOverdueArrow();
boolean isExpectingArrow();
boolean setAdvPHPFlag();
boolean loopHandler(string turnSetting, string counterSetting, string abortMessage, int threshold);
boolean loopHandler(string turnSetting, string counterSetting, int threshold);
boolean loopHandlerDelay(string counterSetting);
boolean loopHandlerDelay(string counterSetting, int threshold);
boolean is100FamiliarRun();
boolean is100FamiliarRun(familiar thisOne);
boolean fightScienceTentacle(string option);
boolean fightScienceTentacle();
boolean evokeEldritchHorror(string option);
boolean evokeEldritchHorror();
boolean cc_change_mcd(int mcd);
boolean providePlusCombat(int amt);
boolean providePlusNonCombat(int amt);
boolean providePlusCombat(int amt, boolean doEquips);
boolean providePlusNonCombat(int amt, boolean doEquips);
boolean basicAdjustML();


// Private Prototypes
boolean buffMaintain(item source, effect buff, int uses, int turns);
boolean buffMaintain(skill source, effect buff, int mp_min, int casts, int turns);
string beerPong(string page);
boolean beehiveConsider();
string safeString(string input);
string safeString(skill input);
string safeString(item input);
string safeString(monster input);
location provideAdvPHPZone();

// Function Definitions


boolean ccMaximize(string req, boolean simulate)
{
	if(!simulate)
	{
		debugMaximize(req, 0);
#		user_confirm("Beep");
	}
	return maximize(req, simulate);
}

boolean ccMaximize(string req, int maxPrice, int priceLevel, boolean simulate)
{
	if(!simulate)
	{
		debugMaximize(req, maxPrice);
#		user_confirm("Beep");
	}
	return maximize(req, maxPrice, priceLevel, simulate);
}

aggregate ccMaximize(string req, int maxPrice, int priceLevel, boolean simulate, boolean includeEquip)
{
	if(!simulate)
	{
		debugMaximize(req, maxPrice);
#		user_confirm("Beep");
	}
	return maximize(req, maxPrice, priceLevel, simulate, includeEquip);
}

void debugMaximize(string req, int meat)
{
	if(req.index_of("-tie") == -1)
	{
		req = req + " -tie";
		print("Added -tie to maximize", "red");
	}
	print("Desired maximize: " + req, "blue");
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
		print(output, "blue");
		print(display, "green");
	}

	tableDo += "</table>";
	tableDont += "</table>";
	print_html(tableDo);
	print_html(tableDont);

	if(get_property("cc_shareMaximizer").to_boolean() && get_property("cc_allowSharingData").to_boolean())
	{
		print("Sharing Maximizer data.", "blue");
		#print("http://cheesellc.com/kol/sharing.php?type=maximizer&data="+url_encode(tableDo + tableDont), "red");
		string temp = visit_url("http://cheesellc.com/kol/sharing.php?type=maximizer&data="+url_encode(tableDo + tableDont));
		if(contains_text(temp, "success"))
		{
			print("Data shared successfully", "green");
		}
		else
		{
			print("Data share failed", "green");
		}
	}

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

void handleTracker(monster enemy, skill toTrack, string tracker)
{
	string cur = get_property(tracker);
	if(cur != "")
	{
		cur = cur + ", ";
	}
	cur = cur + "(" + my_daycount() + ":" + safeString(enemy) + ":" + safeString(toTrack) + ":" + my_turncount() + ")";
	set_property(tracker, cur);
}

void handleTracker(monster enemy, string toTrack, string tracker)
{
	string cur = get_property(tracker);
	if(cur != "")
	{
		cur = cur + ", ";
	}
	cur = cur + "(" + my_daycount() + ":" + safeString(enemy) + ":" + safeString(toTrack) + ":" + my_turncount() + ")";
	set_property(tracker, cur);
}

void handleTracker(monster enemy, item toTrack, string tracker)
{
	string cur = get_property(tracker);
	if(cur != "")
	{
		cur = cur + ", ";
	}
	cur = cur + "(" + my_daycount() + ":" + safeString(enemy) + ":" + safeString(toTrack) + ":" + my_turncount() + ")";
	set_property(tracker, cur);
}

void handleTracker(monster enemy, string tracker)
{
	string cur = get_property(tracker);
	if(cur != "")
	{
		cur = cur + ", ";
	}
	cur = cur + "(" + my_daycount() + ":" + safeString(enemy) + ":" + my_turncount() + ")";
	set_property(tracker, cur);
}

void handleTracker(item used, string tracker)
{
	string cur = get_property(tracker);
	if(cur != "")
	{
		cur = cur + ", ";
	}
	cur = cur + "(" + my_daycount() + ":" + safeString(used) + ":" + my_turncount() + ")";
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
	file_to_map("defaults.txt", defaults);

	int found = 0;
	string oldValue = "";
	foreach domain, name, value in defaults
	{
		if(name == setting)
		{
			found = 1;
			oldValue = get_property(name);
			#print(domain + " " + name + " " + value);
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

		if(get_property("cc_backup_" + setting) == "")
		{
			set_property("cc_backup_" + setting, oldValue);
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
	file_to_map("defaults.txt", defaults);

	boolean retval = false;
	foreach domain, name, value in defaults
	{
		retval |= restoreSetting(name);
	}

	return retval;
}

boolean restoreSetting(string setting)
{
	if(get_property("cc_backup_" + setting) != "")
	{
		if(get_property("cc_backup_" + setting) == "__BLANK__")
		{
			set_property(setting, "");
		}
		else
		{
			set_property(setting, get_property("cc_backup_" + setting));
		}
		remove_property("cc_backup_" + setting);
		return true;
	}

	return false;
}

boolean startArmorySubQuest()
{
	if(cc_my_path() == "Nuclear Autumn")
	{
		if(item_amount($item[Hypnotic Breadcrumbs]) > 0)
		{
			use(1, $item[Hypnotic Breadcrumbs]);
			return true;
		}
		return false;
	}

	if(internalQuestStatus("questM25Armorer") == -1)
	{
		string temp = visit_url("shop.php?whichshop=armory");
		temp = visit_url("shop.php?whichshop=armory&action=talk");
		temp = visit_url("choice.php?pwd=&whichchoice=1065&option=1");
		return true;
	}
	return false;
}

boolean startMeatsmithSubQuest()
{
	if(cc_my_path() == "Nuclear Autumn")
	{
		if(item_amount($item[Bone With a Price Tag On It]) > 0)
		{
			use(1, $item[Bone With a Price Tag On It]);
			return true;
		}
		return false;
	}
	if(internalQuestStatus("questM23Meatsmith") == -1)
	{
		string temp = visit_url("shop.php?whichshop=meatsmith");
		temp = visit_url("shop.php?whichshop=meatsmith&action=talk");
		temp = visit_url("choice.php?pwd=&whichchoice=1059&option=1");
		return true;
	}
	return false;
}

boolean startGalaktikSubQuest()
{
	if(cc_my_path() == "Nuclear Autumn")
	{
		if(item_amount($item[Map to a Hidden Booze Cache]) > 0)
		{
			use(1, $item[Map to a Hidden Booze Cache]);
			return true;
		}
		return false;
	}
	if(internalQuestStatus("questM24Doc") == -1)
	{
		string temp = visit_url("shop.php?whichshop=doc");
		temp = visit_url("shop.php?whichshop=doc&action=talk");
		temp = visit_url("choice.php?pwd=&whichchoice=1064&option=1");
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

boolean hasSpookyravenLibraryKey()
{
	return ((item_amount($item[1764]) > 0) || (item_amount($item[7302]) > 0));
}
boolean hasILoveMeVolI()
{
	return ((item_amount($item[2258]) > 0) || (item_amount($item[7262]) > 0));
}
boolean useILoveMeVolI()
{
	if(item_amount($item[2258]) > 0)
	{
		return use(1, $item[2258]);
	}
	else if(item_amount($item[7262]) > 0)
	{
		return use(1, $item[7262]);
	}
	return false;
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

boolean is100FamiliarRun()
{
	if(get_property("cc_100familiar") == $familiar[Egg Benedict])
	{
		if(have_familiar($familiar[Mosquito]))
		{
			return false;
		}
	}

	if(get_property("cc_100familiar") == $familiar[none])
	{
		return false;
	}
	if(get_property("cc_100familiar") == "")
	{
		return false;
	}
	return true;
}

boolean is100FamiliarRun(familiar thisOne)
{
	if(is100FamiliarRun())
	{
		if(get_property("cc_100familiar") == thisOne)
		{
			return false;
		}
		return true;
	}
	return false;
}


boolean setAdvPHPFlag()
{
	location toAdv = provideAdvPHPZone();
	if(toAdv == $location[none])
	{
		return false;
	}
	ccAdv(toAdv);
	return true;

}

boolean isOverdueDigitize()
{
	if(get_property("_sourceTerminalDigitizeUses").to_int() == 0)
	{
		return false;
	}
	if(get_counters("Digitize Monster", 1, 200) == "Digitize Monster")
	{
		return false;
	}
	if(contains_text(get_property("_tempRelayCounters"), "Digitize Monster"))
	{
		return false;
	}
	if(get_counters("Digitize Monster", 0, 0) == "Digitize Monster")
	{
		return true;
	}
	return false;
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

int ccCraft(string mode, int count, item item1, item item2)
{
	if((mode == "combine") && !knoll_available())
	{
		if(my_meat() < (10 * count))
		{
			print("Count not combine " + item1 + " and " + item2 + " due to lack of meat paste.", "red");
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
			set_property("cc_cookie", my_turncount() + i);
			break;
		}
		i = i + 1;
	}

	return get_property("cc_cookie").to_int();
}


boolean needOre()
{
	if((get_property("cc_trapper") == "yeti") || (get_property("cc_trapper") == "finished"))
	{
		return false;
	}
	item oreGoal = to_item(get_property("trapperOre"));
	if(item_amount(oreGoal) >= 3)
	{
		return false;
	}
	if((item_amount($item[Asbestos Ore]) >= 3) && (item_amount($item[Linoleum Ore]) >= 3) && (item_amount($item[Chrome Ore]) >= 3))
	{
		return false;
	}
	return true;
}


int spleen_left()
{
	return spleen_limit() - my_spleen_use();
}


int stomach_left()
{
	return fullness_limit() - my_fullness();
}

int fullness_left()
{
	return stomach_left();
}

int inebriety_left()
{
	return inebriety_limit() - my_inebriety();
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
	if(cc_my_path() == "Heavy Rains")
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
	if(cc_get_campground() contains $item[Source Terminal])
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

	if(get_property("lastSecondFloorUnlock").to_int() < my_ascensions())
	{
		int need = 5 - get_property("writingDesksDefeated").to_int();
		targets[count(targets)].target = $monster[Writing Desk];
		targets[count(targets)].amt = need;
	}

	//	Racecar Bob 5, Gaudy Pirate 2* (Special Case when we have extra)
	//	Pygmy Bowler 5+, Mountain Man 2+ (Special Case, when we have extra)
	//	Frat Warrior for Outfit 1+ (Numberology)


	//Should we do a zero check on amt just in case, probably.

	//	Targets (all)
	//	Lobsterfrogman 5, Ninja Snowman Assassin 3, Writing Desk 5, Racecar Bob 5, Gaudy Pirate 2*
	//	Ghost 6+, Pygmy Bowler 5+, Mountain Man 2+, Skin Flute 4+, Astronomer 1+
	//	Frat Warrior for Outfit 1+


	return false;
}

boolean canYellowRay()
{
	# Use this to determine if it is safe to enter a yellow ray combat.
	if((cc_get_campground() contains $item[Asdon Martin Keyfob]) && (get_fuel() >= fuel_cost($skill[Asdon Martin: Missile Launcher])) && !get_property("_missileLauncherUsed").to_boolean())
	{
		return true;
	}
	if(have_effect($effect[Everything Looks Yellow]) > 0)
	{
		return false;
	}
	if((item_amount($item[Mayo Lance]) > 0) && (get_property("mayoLevel").to_int() > 0) && glover_usable($item[Mayo Lance]))
	{
		return true;
	}
	foreach it in $items[Golden Light, Unbearable Light, Pumpkin Bomb, Yellowcake Bomb, Viral Video]
	{
		if((item_amount(it) > 0) && glover_usable(it))
		{
			return true;
		}
	}
	# We might not have Flash Headlight outside of combat, will need to check that.
	if((get_property("peteMotorbikeHeadlight") == "Ultrabright Yellow Bulb") && have_skill($skill[Flash Headlight]) && (my_mp() >= mp_cost($skill[Flash Headlight])))
	{
		return true;
	}
	if(have_skill($skill[Wrath of Ra]) && (my_mp() >= mp_cost($skill[Wrath of Ra])))
	{
		return true;
	}
	if(have_skill($skill[Ball Lightning]) && (my_lightning() >= lightning_cost($skill[Ball Lightning])))
	{
		return true;
	}
	if((my_familiar() == $familiar[Crimbo Shrub]) || (!is100FamiliarRun($familiar[Crimbo Shrub]) && have_familiar($familiar[Crimbo Shrub])))
	{
		if(get_property("shrubGifts") == "yellow")
		{
			return true;
		}
		if(!get_property("_shrubDecorated").to_boolean())
		{
			string temp = visit_url("inv_use.php?pwd=&which=3&whichitem=7958");
			temp = visit_url("choice.php?pwd=&whichchoice=999&option=1&topper=1&lights=1&garland=1&gift=1");
			if(get_property("shrubGifts") == "yellow")
			{
				return true;
			}
		}
	}
	if(!get_property("_internetViralVideoBought").to_boolean() && (item_amount($item[BACON]) >= 20) && glover_usable($item[Viral Video]))
	{
		cli_execute("make " + $item[Viral Video]);
		if(item_amount($item[Viral Video]) > 0)
		{
			return true;
		}
	}
	if(have_skill($skill[Disintegrate]) && (my_mp() >= mp_cost($skill[Disintegrate])))
	{
		return true;
	}
	if(have_skill($skill[Unleash Cowrruption]) && (have_effect($effect[Cowrruption]) >= 30))
	{
		return true;
	}
	# Pulled Yellow Taffy	- How do we handle the underwater check?
	# He-Boulder?			- How do we do this?
	return false;
}

string banisherCombatString(monster enemy, location loc)
{
	if(get_property("kingLiberated").to_boolean())
	{
		return "";
	}

	//Check that we actually want to banish this thing.


	// Is it a special banish? (cocktail napkin?)

	if(!($monsters[Animated Mahogany Nightstand, Animated Possessions, Animated Rustic Nightstand, Bubblemint Twins, Bullet Bill, Burly Sidekick, Chatty Pirate, Clingy Pirate (Female), Clingy Pirate (Male), Coaltergeist, Crusty Pirate, Doughbat, Drunk Goat, Evil Olive, Flock Of Stab-Bats, Knob Goblin Harem Guard, Knob Goblin Madam, Mad Wino, Mismatched Twins, Natural Spider, Plaid Ghost, Possessed Laundry Press, Procrastination Giant, Protagonist, Pygmy Headhunter, Pygmy Janitor, Pygmy Orderlies, Pygmy Witch Lawyer, Pygmy Witch Nurse, Sabre-Toothed Goat, Senile Lihc, Slick Lihc, Skeletal Sommelier, Snow Queen, Steam Elemental, Taco Cat, Tan Gnat, Tomb Asp, Tomb Servant, Wardr&ouml;b Nightstand, Warehouse Janitor, Upgraded Ram] contains enemy))
	{
		return "";
	}

	if((enemy == $monster[Knob Goblin Madam]) && (item_amount($item[Knob Goblin Perfume]) == 0))
	{
		return "";
	}
	if((enemy == $monster[Burly Sidekick]) && !possessEquipment($item[Mohawk Wig]))
	{
		return "";
	}
	if((enemy == $monster[Pygmy Janitor]) && (get_property("hiddenTavernUnlock").to_int() < my_ascensions()))
	{
		return "";
	}

	string banished = get_property("banishedMonsters");
	string[int] banishList = split_string(banished, ":");
	monster[int] atLoc = get_monsters(loc);

	//src/net/sourceforge/kolmafia/session/BanishManager.java
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

	if(cc_have_skill($skill[Give Your Opponent The Stinkeye]) && !get_property("_stinkyCheeseBanisherUsed").to_boolean() && (my_mp() >= mp_cost($skill[Give Your Opponent The Stinkeye])))
	{
		return "skill " + $skill[Give Your Opponent The Stinkeye];
	}

#	What is the preference for this?
#	if(have_skill($skill[Creepy Grin]) && !get_property("_creepyGrinUsed").to_boolean() && (my_mp() >= mp_cost($skill[Creepy Grin])))
#	{
#		return "skill " + $skill[Creepy Grin];
#	}

	if(cc_have_skill($skill[Thunder Clap]) && (my_thunder() >= thunder_cost($skill[Thunder Clap])) && (!(used contains "thunder clap")))
	{
		return "skill " + $skill[Thunder Clap];
	}
	if(cc_have_skill($skill[Asdon Martin: Spring-Loaded Front Bumper]) && (get_fuel() >= fuel_cost($skill[Asdon Martin: Spring-Loaded Front Bumper])) && (!(used contains "Spring-Loaded Front Bumper")))
	{
		if(!contains_text(get_property("banishedMonsters"), "Spring-Loaded Front Bumper"))
		{
			return "skill " + $skill[Asdon Martin: Spring-Loaded Front Bumper];
		}
	}
	if(cc_have_skill($skill[Curse Of Vacation]) && (my_mp() > mp_cost($skill[Curse Of Vacation])) && (!(used contains "curse of vacation")))
	{
		return "skill " + $skill[Curse Of Vacation];
	}

	if(cc_have_skill($skill[Show Them Your Ring]) && !get_property("_mafiaMiddleFingerRingUsed").to_boolean() && (my_mp() >= mp_cost($skill[Show Them Your Ring])))
	{
		return "skill " + $skill[Show Them Your Ring];
	}
	if(cc_have_skill($skill[Breathe Out]) && (my_mp() >= mp_cost($skill[Breathe Out])) && (!(used contains "breathe out")))
	{
		return "skill " + $skill[Breathe Out];
	}
	if(cc_have_skill($skill[Batter Up!]) && (my_fury() >= 5) && (item_type(equipped_item($slot[weapon])) == "club") && (!(used contains "batter up!")))
	{
		return "skill " + $skill[Batter Up!];
	}

	if(cc_have_skill($skill[Banishing Shout]) && (my_mp() > mp_cost($skill[Banishing Shout])) && (!(used contains "banishing shout")))
	{
		return "skill " + $skill[Banishing Shout];
	}
	if(cc_have_skill($skill[Walk Away From Explosion]) && (my_mp() > mp_cost($skill[Walk Away From Explosion])) && (have_effect($effect[Bored With Explosions]) == 0) && (!(used contains "walk away from explosion")))
	{
		return "skill " + $skill[Walk Away From Explosion];
	}

	if(cc_have_skill($skill[Talk About Politics]) && (get_property("_pantsgivingBanish").to_int() < 5) && have_equipped($item[Pantsgiving]) && (!(used contains "pantsgiving")))
	{
		return "skill " + $skill[Talk About Politics];
	}
	if(cc_have_skill($skill[KGB Tranquilizer Dart]) && (get_property("_kgbTranquilizerDartUses").to_int() < 3) && (my_mp() >= mp_cost($skill[KGB Tranquilizer Dart])) && (!(used contains "KGB tranquilizer dart")))
	{
		boolean useIt = true;
		if((get_property("cc_gremlins") == "finished") && (my_daycount() >= 2) && (get_property("_kgbTranquilizerDartUses").to_int() >= 2))
		{
			useIt = false;
		}

		if(useIt)
		{
			return "skill " + $skill[KGB Tranquilizer Dart];
		}
	}
	if(cc_have_skill($skill[Snokebomb]) && (get_property("_snokebombUsed").to_int() < 3) && ((my_mp() - 20) >= mp_cost($skill[Snokebomb])) && (!(used contains "snokebomb")))
	{
		return "skill " + $skill[Snokebomb];
	}
	if(cc_have_skill($skill[Beancannon]) && (get_property("_beancannonUses").to_int() < 5) && ((my_mp() - 20) >= mp_cost($skill[Beancannon])) && (!(used contains "beancannon")))
	{
		if($items[Frigid Northern Beans, Heimz Fortified Kidney Beans, Hellfire Spicy Beans, Mixed Garbanzos and Chickpeas, Pork \'n\' Pork \'n\' Pork \'n\' Beans, Shrub\'s Premium Baked Beans, Tesla\'s Electroplated Beans, Trader Olaf\'s Exotic Stinkbeans, World\'s Blackest-Eyed Peas] contains equipped_item($slot[Off-hand]))
		{
			return "skill " + $skill[Beancannon];
		}
	}
	if(cc_have_skill($skill[Breathe Out]) && (!(used contains "breathe out")))
	{
		return "skill " + $skill[Breathe Out];
	}

	//We want to limit usage of these much more than the others.
	if(!($monsters[Natural Spider, Tan Gnat, Tomb Servant, Upgraded Ram] contains enemy))
	{
		return "";
	}

	int keep = 1;
	if(get_property("cc_gremlins") == "finished")
	{
		keep = 0;
	}

	if((item_amount($item[Louder Than Bomb]) > keep) && (!(used contains "louder than bomb")))
	{
		return "item " + $item[Louder Than Bomb];
	}
	if((item_amount($item[Tennis Ball]) > keep) && (!(used contains "tennis ball")))
	{
		return "item " + $item[Tennis Ball];
	}
	if((item_amount($item[Deathchucks]) > keep) && (!(used contains "deathchucks")))
	{
		return "item " + $item[Deathchucks];
	}


	return "";
}

string yellowRayCombatString()
{
	if(have_effect($effect[Everything Looks Yellow]) > 0)
	{
		if((cc_get_campground() contains $item[Asdon Martin Keyfob]) && (get_fuel() >= fuel_cost($skill[Asdon Martin: Missile Launcher])) && !get_property("_missileLauncherUsed").to_boolean())
		{
			return "skill " + $skill[Asdon Martin: Missile Launcher];
		}
		return "";
	}
	if(!canYellowRay())
	{
		return "";
	}

	if(cc_have_skill($skill[Disintegrate]) && (my_mp() >= (100 + mp_cost($skill[Disintegrate]))))
	{
		return "skill " + $skill[Disintegrate];
	}
	if((item_amount($item[Yellowcake Bomb]) > 0) && glover_usable($item[Yellowcake Bomb]))
	{
		return "item " + $item[Yellowcake Bomb];
	}
	if(cc_have_skill($skill[Ball Lightning]) && (my_lightning() >= lightning_cost($skill[Ball Lightning])))
	{
		return "skill " + $skill[Ball Lightning];
	}
	if(cc_have_skill($skill[Wrath of Ra]) && (my_mp() >= mp_cost($skill[Wrath of Ra])))
	{
		return "skill " + $skill[Wrath of Ra];
	}
	if((item_amount($item[Mayo Lance]) > 0) && (get_property("mayoLevel").to_int() > 0) && glover_usable($item[Mayo Lance]))
	{
		return "item " + $item[Mayo Lance];
	}
	if(have_familiar($familiar[Crimbo Shrub]) && (get_property("shrubGifts") == "yellow"))
	{
		return "skill " + $skill[Open a Big Yellow Present];
	}
	if((get_property("peteMotorbikeHeadlight") == "Ultrabright Yellow Bulb") && cc_have_skill($skill[Flash Headlight]) && (my_mp() >= mp_cost($skill[Flash Headlight])))
	{
		return "skill " + $skill[Flash Headlight];
	}
	foreach it in $items[Golden Light, Pumpkin Bomb, Unbearable Light, Viral Video]
	{
		if((item_amount(it) > 0) && glover_usable(it))
		{
			return "item " + it;
		}
	}
	if(cc_have_skill($skill[Disintegrate]) && (my_mp() >= mp_cost($skill[Disintegrate])))
	{
		return "skill " + $skill[Disintegrate];
	}
	if(cc_have_skill($skill[Unleash Cowrruption]) && (have_effect($effect[Cowrruption]) >= 30))
	{
		return "skill " + $skill[Unleash Cowrruption];
	}

	if((cc_get_campground() contains $item[Asdon Martin Keyfob]) && (get_fuel() >= fuel_cost($skill[Asdon Martin: Missile Launcher])) && !get_property("_missileLauncherUsed").to_boolean() && cc_have_skill($skill[Asdon MArtin: Missile Launcher]))
	{
		return "skill " + $skill[Asdon Martin: Missile Launcher];
	}
	return "";
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
	return have_skill($skill[Torso Awaregness]) || have_skill($skill[Best Dressed]);
}

boolean isGuildClass()
{
	return ($classes[Seal Clubber, Turtle Tamer, Sauceror, Pastamancer, Disco Bandit, Accordion Thief] contains my_class());
}

float elemental_resist_value(int resistance)
{
	float bonus = 0;
	if((my_class() == $class[Pastamancer]) || (my_class() == $class[Sauceror]) || (my_class() == $class[Ed]))
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
#	string page = to_lower_case(visit_url("charsheet.php"));
#	matcher my_element = create_matcher(to_string(goal) + " protection:(.*?)((\\d\+)\)", page);
#	if(my_element.find())
#	{
#		return to_int(my_element.group(2));
#	}
#	return 0;
}

boolean uneffect(effect toRemove)
{
	if(have_effect(toRemove) == 0)
	{
		return true;
	}
	if(($effects[Driving Intimidatingly, Driving Obnoxiously, Driving Observantly, Driving Quickly, Driving Recklessly, Driving Safely, Driving Stealthily, Driving Wastefully, Driving Waterproofly] contains toRemove) && (cc_get_campground() contains $item[Asdon Martin Keyfob]))
	{
		string temp = visit_url("campground.php?pwd=&preaction=undrive");
		return true;
	}

	if(cli_execute("uneffect " + toRemove))
	{
		//Either we don\'t have the effect or it is shruggable.
		return true;
	}

	if(item_amount($item[Soft Green Echo Eyedrop Antidote]) > 0)
	{
		visit_url("uneffect.php?pwd=&using=Yep.&whicheffect=" + to_int(toRemove));
		print("Effect removed by Soft Green Echo Eyedrop Antidote.", "blue");
		return true;
	}
	else if(item_amount($item[Ancient Cure-All]) > 0)
	{
		visit_url("uneffect.php?pwd=&using=Yep.&whicheffect=" + to_int(toRemove));
		print("Effect removed by Ancient Cure-All.", "blue");
		return true;
	}
	return false;
}

int ns_crowd1()
{
	if(get_property("nsContestants1").to_int() != 0)
	{
		print("Default Test: Initiative", "red");
	}
	return 1;
}
stat ns_crowd2()
{
	if(get_property("nsContestants2").to_int() != 0)
	{
		print("Off-Stat Test: " + get_property("nsChallenge1"), "red");
	}
	return to_stat(get_property("nsChallenge1"));
}
element ns_crowd3()
{
	if(get_property("nsContestants3").to_int() != 0)
	{
		print("Elemental Test: " + get_property("nsChallenge2"), "red");
	}
	return to_element(get_property("nsChallenge2"));
}
element ns_hedge1()
{
	print("Hedge Maze 1: " + get_property("nsChallenge3"), "red");
	return to_element(get_property("nsChallenge3"));
}
element ns_hedge2()
{
	print("Hedge Maze 2: " + get_property("nsChallenge4"), "red");
	return to_element(get_property("nsChallenge4"));
}
element ns_hedge3()
{
	print("Hedge Maze 3: " + get_property("nsChallenge5"), "red");
	return to_element(get_property("nsChallenge5"));
}

skill preferredLibram()
{
	if(have_skill($skill[Summon Brickos]) && (get_property("_brickoEyeSummons").to_int() < 3))
	{
		return $skill[Summon Brickos];
	}
	if(have_skill($skill[Summon Party Favor]) && (get_property("_favorRareSummons").to_int() < 3))
	{
		return $skill[Summon Party Favor];
	}
	if(have_skill($skill[Summon Resolutions]))
	{
		return $skill[Summon Resolutions];
	}
	if(have_skill($skill[Summon Taffy]))
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

int doRest()
{
	if(chateaumantegna_available())
	{
		cli_execute("outfit save Backup");
		chateaumantegna_nightstandSet();

		boolean[item] restBonus = chateaumantegna_decorations();
		stat bonus = $stat[none];
		if(restBonus contains $item[Electric Muscle Stimulator])
		{
			bonus = $stat[Muscle];
		}
		else if(restBonus contains $item[Foreign Language Tapes])
		{
			bonus = $stat[Mysticality];
		}
		else if(restBonus contains $item[Bowl of Potpourri])
		{
			bonus = $stat[Moxie];
		}

		boolean closet = false;
		item grab = $item[none];
		item replace = $item[none];
		switch(bonus)
		{
		case $stat[Muscle]:
			replace = equipped_item($slot[off-hand]);
			grab = $item[Fake Washboard];
			if(can_equip($item[LOV Eardigan]) && (item_amount($item[LOV Eardigan]) > 0))
			{
				equip($slot[shirt], $item[LOV Eardigan]);
			}
			break;
		case $stat[Mysticality]:
			replace = equipped_item($slot[off-hand]);
			grab = $item[Basaltamander Buckler];
			if(can_equip($item[LOV Epaulettes]) && (item_amount($item[LOV Epaulettes]) > 0))
			{
				equip($slot[back], $item[LOV Epaulettes]);
			}
			break;
		case $stat[Moxie]:
			replace = equipped_item($slot[weapon]);
			grab = $item[Backwoods Banjo];
			if(can_equip($item[LOV Earrings]) && (item_amount($item[LOV Earrings]) > 0))
			{
				equip($slot[acc1], $item[LOV Earrings]);
			}
			break;
		}

		if((grab != $item[none]) && possessEquipment(grab) && (replace != grab) && can_equip(grab))
		{
			equip(grab);
		}
		if(!possessEquipment(grab) && (replace != grab) && (closet_amount(grab) > 0) && can_equip(grab))
		{
			closet = true;
			take_closet(1, grab);
			equip(grab);
		}

		visit_url("place.php?whichplace=chateau&action=chateau_restbox");

		if((replace != grab) && (replace != $item[none]))
		{
			equip(replace);
		}
		cli_execute("outfit Backup");
		if(closet)
		{
			if(item_amount(grab) > 0)
			{
				put_closet(1, grab);
			}
		}

	}
	else
	{
		set_property("restUsingChateau", false);
		cli_execute("rest");
		set_property("restUsingChateau", true);
	}
	return get_property("timesRested").to_int();
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

void tootGetMeat()
{
	cc_autosell(min(5, item_amount($item[hamethyst])), $item[hamethyst]);
	cc_autosell(min(5, item_amount($item[baconstone])), $item[baconstone]);
	cc_autosell(min(5, item_amount($item[porquoise])), $item[porquoise]);
}


boolean ovenHandle()
{
	if((cc_get_campground() contains $item[Dramatic&trade; range]) && !get_property("cc_haveoven").to_boolean())
	{
		if((cc_get_campground() contains $item[Certificate of Participation]) && (my_class() == $class[Ed]))
		{
			print("Mafia reports we have an oven but we do not. Logging back in will resolve this.", "red");
		}
		else
		{
			print("Oven found! We can cook!", "blue");
			set_property("cc_haveoven", true);
		}
	}

	if(!get_property("cc_haveoven").to_boolean() && (my_meat() > 4000) && isGeneralStoreAvailable())
	{
		buyUpTo(1, $item[Dramatic&trade; range]);
		use(1, $item[Dramatic&trade; range]);
		set_property("cc_haveoven", true);
	}
	return get_property("cc_haveoven").to_boolean();
}

boolean isGhost(monster mon)
{
	boolean[monster] ghosts = $monsters[Ancient Ghost, Banshee Librarian, Battlie Knight Ghost, Bettie Barulio, Chalkdust Wraith, Claybender Sorcerer Ghost, Coaltergeist, Cold Ghost, Contemplative Ghost, Dusken Raider Ghost, Ghost, Ghost Actor, Ghost Miner, Ghost of Elizabeth Spookyraven, Hot Ghost, Hustled Spectre, Lovesick Ghost, Marcus Macurgeon, Marvin J. Sunny, Mayor Ghost, Mer-kin Specter, Model Skeleton, Mortimer Strauss, Plaid Ghost, Protector Spectre, Restless Ghost, Sexy Sorority Ghost, Sheet Ghost, Sleaze Ghost, Space Tourist Explorer Ghost, Spooky Ghost, Stench Ghost, The Ghost of Phil Bunion, The Unknown Accordion Thief, The Unknown Disco Bandit, The Unknown Pastamancer, The Unknown Sauceror, The Unknown Seal Clubber, The Unknown Turtle Tamer, Whatsian Commando Ghost, Wonderful Winifred Wongle];
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

boolean acquireMP(int goal)
{
	return acquireMP(goal, false);
}

boolean acquireMP(int goal, boolean buyIt)
{
	if(goal > my_maxmp())
	{
		return false;
	}

	item[int] recovers = List($items[Holy Spring Water, Spirit Beer, Sacramental Wine, Magical Mystery Juice, Black Cherry Soda, Doc Galaktik\'s Invigorating Tonic, Carbonated Soy Milk, Natural Fennel Soda, Grogpagne, Bottle Of Monsieur Bubble, Tiny House, Marquis De Poivre Soda, Cloaca-Cola, Phonics Down, Psychokinetic Energy Blob]);
	int at = 0;
	while((at < count(recovers)) && (my_mp() < goal))
	{
		item it = recovers[at];
		int expectedMP = (it.minmp + it.maxmp) / 2;
		int overage = (my_mp() + expectedMP) - goal;
		if(overage > 0)
		{
			float waste = overage / expectedMP;
			if(waste > 0.35)
			{
				at++;
				continue;
			}
		}

		if(!glover_usable(it))
		{
			at++;
			continue;
		}

		if(item_amount(it) > 0)
		{
			int count = item_amount(it);
			use(1, it);
			if(count == item_amount(it))
			{
				print("Failed using item " + it + "!", "red");
				return false;
			}
			continue;
		}
		at++;
	}

	while(buyIt && (my_mp() < goal))
	{
		boolean gLoverBlock = (cc_my_path() == "G-Lover");
		item goal = $item[none];

		if(($classes[Pastamancer, Sauceror] contains my_class()) && guild_store_available() && (my_level() >= 5))
		{
			goal = $item[Magical Mystery Juice];
		}
		else if((get_property("questM24Doc") == "finished") && isGeneralStoreAvailable() && (my_meat() > npc_price($item[Doc Galaktik\'s Invigorating Tonic])))
		{
			goal = $item[Doc Galaktik\'s Invigorating Tonic];
		}
		else if(black_market_available() && (my_meat() > npc_price($item[Black Cherry Soda])) && !gLoverBlock)
		{
			goal = $item[Black Cherry Soda];
		}
		else if(isGeneralStoreAvailable() && (my_meat() > npc_price($item[Doc Galaktik\'s Invigorating Tonic])))
		{
			goal = $item[Doc Galaktik\'s Invigorating Tonic];
		}

		if(goal != $item[none])
		{
			buyUpTo(1, goal, 100);
		}

		if(item_amount(goal) > 0)
		{
			int have = item_amount(goal);
			use(1, goal);
			if(have == item_amount(goal))
			{
				print("Failed using item " + goal + "!", "red");
				return false;
			}
		}
		else
		{
			break;
		}
	}

	return (my_mp() >= goal);
}

int cloversAvailable()
{
	int retval = item_amount($item[Disassembled Clover]);
	retval += item_amount($item[Ten-Leaf Clover]);
	retval += closet_amount($item[Ten-Leaf Clover]);

	if(cc_my_path() == "G-Lover")
	{
		retval -= item_amount($item[Disassembled Clover]);
	}

	return retval;
}

boolean cloverUsageInit()
{
	if(cloversAvailable() == 0)
	{
		abort("Called cloverUsageInit but have no clovers");
	}

	if(item_amount($item[Ten-Leaf Clover]) > 0)
	{
		return true;
	}

	if(item_amount($item[Disassembled Clover]) > 0)
	{
		if(cc_my_path() != "G-Lover")
		{
			use(1, $item[Disassembled Clover]);
		}
	}
	if(item_amount($item[Ten-Leaf Clover]) > 0)
	{
		return true;
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
	backupSetting("cloverProtectActive", false);
	return false;
}

boolean cloverUsageFinish()
{
	restoreSetting("cloverProtectActive");
	if(item_amount($item[Ten-Leaf Clover]) > 0)
	{
		print("Wandering adventure interrupted our clover adventure (" + my_location() + "), boo. Gonna have to do this again.");
		if(cc_my_path() == "G-Lover")
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
	print("Gum acquistion of: " + it, "green");
	while((have == item_amount(it)) && (my_meat() >= npc_price($item[Chewing Gum on a String])))
	{
		buyUpTo(1, $item[Chewing Gum on a String]);
		use(1, $item[Chewing Gum on a String]);
	}

	return (have + 1) == item_amount(it);
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
	print("Hermit acquistion of: " + it, "green");
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
					print("Invalid clover count from hermit behavior, reporting failure.", "red");
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
	if(cc_my_path() == "Nuclear Autumn")
	{
		return false;
	}
	if(cc_my_path() == "Zombie Master")
	{
		return false;
	}
	return true;
}

boolean isGalaktikAvailable()
{
	if(cc_my_path() == "Nuclear Autumn")
	{
		return false;
	}
	if(cc_my_path() == "Zombie Master")
	{
		return false;
	}
	return true;
}

boolean isGeneralStoreAvailable()
{
	if(cc_my_path() == "Nuclear Autumn")
	{
		return false;
	}
	if(cc_my_path() == "Zombie Master")
	{
		return false;
	}
	return true;
}

boolean isUnclePAvailable()
{
	if(cc_my_path() == "Nuclear Autumn")
	{
		return false;
	}
	if(cc_my_path() == "Zombie Master")
	{
		return false;
	}
	return true;
}

questRecord questRecord(string prop, string mprop, int type, string func)
{
	questRecord retval;
	retval.prop = prop;
	retval.mprop = mprop;
	retval.type = type;
	retval.func = func;
	return retval;
}

questRecord[int] questDatabase()
{
	questRecord[int] retval;
	retval[0] = questRecord("cc_mosquito", "questL02Larva", 0, "L2_mosquito");
	retval[1] = questRecord("cc_tavern", "questL03Rat", 0, "L3_tavern");
	retval[2] = questRecord("cc_bat", "questL04Bat", 0, "L4_batCave");
	return retval;
}

int questsLeft()
{
	int retval = 0;
	foreach idx, quest in questDatabase()
	{
		if((quest.type == 0) && (get_property(quest.prop) != "finished"))
		{
			retval++;
		}
	}
	return retval;
}


boolean instakillable(monster mon)
{
	if(mon.boss)
	{
		return false;
	}

	boolean[monster] timeSpinner = $monsters[Ancient Skeleton with Skin still on it, Apathetic Tyrannosaurus, Assembly Elemental, Cro-Magnon Gnoll, Krakrox the Barbarian, Wooly Duck];

	boolean[monster] lovetunnel = $monsters[LOV Enforcer, LOV Engineer, LOV Equivocator];

	if($monster[Sssshhsssblllrrggghsssssggggrrgglsssshhssslblgl] == mon)
	{
		return false;
	}

	if(timeSpinner contains mon)
	{
		return false;
	}

	if(lovetunnel contains mon)
	{
		return false;
	}

	return true;
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

	boolean[monster] other = $monsters[giant rubber spider, God Lobster, lynyrd, time-spinner prank, Travoltron];

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
		print("Declined " + count + " trades.", "blue");
		return true;
	}
	return false;
}

boolean cc_deleteMail(kmailObject msg)
{
	if((msg.fromid == 0) && (contains_text(msg.message, "We found this telegram at the bottom of an old bin of mail.")))
	{
		return true;
	}
	if((msg.fromid == 0) && (contains_text(msg.message, "One of my agents found a copy of a telegram in the Council\'s fileroom")))
	{
		return true;
	}
	if((msg.fromid == 3038166) && (contains_text(msg.message, "CheeseFax completed your relationship fortune test")) && get_property("cc_hideAdultery").to_boolean())
	{
		return true;
	}

	if(contains_text(msg.message, "I have opted to let you know that I have chosen to run &lt;snapshot.ash&gt;.  Thanks for writing this script"))
	{
		return true;
	}
	if(contains_text(msg.message, "I have opted to let you know that I have chosen to run &lt;cc_ascend.ash&gt;.  Thanks for writing this script"))
	{
		return true;
	}
	if(contains_text(msg.message, "I have opted to let you know that I have chosen to run &lt;batfellow.ash&gt;.  Thanks for writing this script"))
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
		return ccAdvBypass("inv_use.php?pwd&which=3&whichitem=" + id, $location[Noob Cave], option);
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


boolean providePlusCombat(int amt)
{
	return providePlusCombat(amt, true);
}
boolean providePlusNonCombat(int amt)
{
	return providePlusNonCombat(amt, true);
}

boolean providePlusCombat(int amt, boolean doEquips)
{
	if(amt == 0)
	{
		return true;
	}
	if(have_effect($effect[Become Superficially Interested]) > 0)
	{
		string temp = visit_url("charsheet.php?pwd=&action=newyouinterest");
	}

//	foreach eff in $effects[Driving Stealthily, The Sonata of Sneakiness, Patent Invisibility, Shelter of Shed]
	foreach eff in $effects[Driving Stealthily, The Sonata of Sneakiness]
	{
		if(!uneffect(eff))
		{
			return false;
		}
	}

	if(numeric_modifier("Combat Rate").to_int() >= amt)
	{
		return true;
	}

	shrugAT($effect[Carlweather\'s Cantata Of Confrontation]);
	foreach eff in $effects[Musk of the Moose, Carlweather\'s Cantata of Confrontation, Blinking Belly, Song of Battle, Frown, Angry, Screaming! \ SCREAMING! \ AAAAAAAH!]
	{
		buffMaintain(eff, 0, 1, 1);
		if(numeric_modifier("Combat Rate").to_int() >= amt)
		{
			return true;
		}
	}

	foreach eff in $effects[Taunt of Horus, Hippy Stench, High Colognic, Celestial Saltiness, Everything Must Go!, Patent Aggression, Lion in Ambush]
	{
		buffMaintain(eff, 0, 1, 1);
		if(numeric_modifier("Combat Rate").to_int() >= amt)
		{
			return true;
		}
	}

	if(doEquips)
	{
		if(have_familiar($familiar[Grim Brother]) && possessEquipment($item[Buddy Bjorn]))
		{
			if(equipped_item($slot[back]) != $item[Buddy Bjorn])
			{
				equip($slot[Back], $item[Buddy Bjorn]);
			}
			handleBjornify($familiar[Grim Brother]);
		}
		removeNonCombat();
		if(have_familiar($familiar[Jumpsuited Hound Dog]))
		{
			handleFamiliar($familiar[Jumpsuited Hound Dog]);
		}
	}

	if(numeric_modifier("Combat Rate").to_int() < amt)
	{
		asdonBuff($effect[Driving Obnoxiously]);
	}
	return true;
}
boolean providePlusNonCombat(int amt, boolean doEquips)
{
	if(amt == 0)
	{
		return true;
	}
	amt = -1 * amt;

	if(have_effect($effect[Become Intensely Interested]) > 0)
	{
		string temp = visit_url("charsheet.php?pwd=&action=newyouinterest");
	}


	foreach eff in $effects[Carlweather\'s Cantata Of Confrontation, Driving Obnoxiously]
	{
		if(!uneffect(eff))
		{
			return false;
		}
		if(numeric_modifier("Combat Rate").to_int() <= amt)
		{
			return true;
		}
	}

	foreach eff in $effects[Patent Invisibility]
	{
		buffMaintain(eff, 0, 1, 1);
		if(numeric_modifier("Combat Rate").to_int() <= amt)
		{
			return true;
		}
	}

	shrugAT($effect[The Sonata of Sneakiness]);
	//Assumes that Rev Engine was taken with Extra-Quite Muffler.
	foreach eff in $effects[Shelter Of Shed, Brooding, Muffled, Smooth Movements, The Sonata of Sneakiness, Song of Solitude, Inked Well, Bent Knees, Extended Toes, Ink Cloud, Patent Invisibility]
	{
		buffMaintain(eff, 0, 1, 1);
		if(numeric_modifier("Combat Rate").to_int() <= amt)
		{
			return true;
		}
	}

	if(doEquips)
	{
		if(have_familiar($familiar[Grimstone Golem]) && possessEquipment($item[Buddy Bjorn]))
		{
			if(equipped_item($slot[back]) != $item[Buddy Bjorn])
			{
				equip($slot[Back], $item[Buddy Bjorn]);
			}
			handleBjornify($familiar[Grimstone Golem]);
		}
		removeCombat();
	}

	if(numeric_modifier("Combat Rate").to_int() > amt)
	{
		asdonBuff($effect[Driving Stealthily]);
	}
	return true;
}

boolean cc_have_familiar(familiar fam)
{
	if(cc_my_path() == "License to Adventure")
	{
		return false;
	}
	if($classes[Avatar Of Boris, Avatar Of Jarlsberg, Avatar Of Sneaky Pete, Ed] contains my_class())
	{
		return false;
	}
	if(!glover_usable(fam))
	{
		return false;
	}
	return have_familiar(fam);
}

boolean basicAdjustML()
{
	if((monster_level_adjustment() > 150) && (monster_level_adjustment() <= 160))
	{
		int base = (monster_level_adjustment() - current_mcd());
		if(base <= 150)
		{
			int canhave = 150 - base;
			cc_change_mcd(canhave);
		}
	}
	else
	{
		if(((get_property("flyeredML").to_int() >= 10000) || get_property("cc_ignoreFlyer").to_boolean()) && (my_level() >= 13))
		{
			cc_change_mcd(0);
		}
		else if((monster_level_adjustment() + (10 - current_mcd())) <= 150)
		{
			cc_change_mcd(10);
		}
	}
	return false;
}

boolean cc_change_mcd(int mcd)
{
	int best = 10;
	if($strings[Mongoose, Vole, Wallaby] contains my_sign())
	{
		if(item_amount($item[Detuned Radio]) == 0)
		{
			return false;
		}
		if(cc_my_path() == "G-Lover")
		{
			return false;
		}
	}
	if($strings[Blender, Packrat, Wombat] contains my_sign())
	{
		if(get_property("lastDesertUnlock").to_int() < my_ascensions())
		{
			return false;
		}
	}
	if($strings[Marmot, Opossum, Platypus] contains my_sign())
	{
		best = 11;
	}
	if(my_sign() == "Bad Moon")
	{
		best = 11;
	}

	int handicap = 10 - get_property("cc_beatenUpCount").to_int();
	if(my_level() >= 13)
	{
		if((get_property("questL12War") == "finished") || (get_property("sidequestArenaCompleted") != "none") || (get_property("flyeredML").to_int() >= 10000) || get_property("cc_ignoreFlyer").to_boolean())
		{
			mcd = 0;
		}
	}
	mcd = min(mcd, best);
	int next = max(0,min(mcd, handicap));
	if(next == current_mcd())
	{
		return true;
	}
	return change_mcd(next);
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
	return ccAdvBypass(0, pages, $location[Noob Cave], option);
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
	return ccAdvBypass(0, pages, $location[Noob Cave], option);

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
		return ccAdvBypass("inv_use.php?pwd=&whichitem=" + to_int(it) + "&checked=1", $location[Noob Cave], option);
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
		return ccAdvBypass("inv_use.php?pwd=&whichitem=3905&checked=1", $location[Noob Cave], option);
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
	return ccAdvBypass(page, $location[Noob Cave], option);
}



int towerKeyCount()
{
	return towerKeyCount(true);
}

int towerKeyCount(boolean effective)
{
	if(my_class() == $class[Ed])
	{
		return 3;
	}

	int tokens = item_amount($item[Fat Loot Token]);
	if((item_amount($item[Boris\'s Key]) > 0) || contains_text(get_property("nsTowerDoorKeysUsed"), $item[Boris\'s Key]))
	{
		tokens = tokens + 1;
	}
	if((item_amount($item[Jarlsberg\'s Key]) > 0) || contains_text(get_property("nsTowerDoorKeysUsed"), $item[Jarlsberg\'s Key]))
	{
		tokens = tokens + 1;
	}
	if((item_amount($item[Sneaky Pete\'s Key]) > 0) || contains_text(get_property("nsTowerDoorKeysUsed"), $item[Sneaky Pete\'s Key]))
	{
		tokens = tokens + 1;
	}
	if(effective && (item_amount($item[Daily Dungeon Malware]) > 0) && !get_property("_dailyDungeonMalwareUsed").to_boolean() && !get_property("dailyDungeonDone").to_boolean() && (get_property("_lastDailyDungeonRoom").to_int() < 14) && (cc_my_path() != "Pocket Familiars"))
	{
		tokens = tokens + 1;
	}
	return tokens;
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
			print("Found mimic in slot: " + slotID, "red");
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
	if(get_property("kingLiberated").to_boolean())
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
	equip(sl, it);
	return true;
}

boolean cc_autosell(int quantity, item toSell)
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

int turkeyBooze()
{
	return get_property("_turkeyBooze").to_int();
}

int amountTurkeyBooze()
{
	if(is_unrestricted($item[Fist Turkey Outline]))
	{
		return item_amount($item[Agitated Turkey]) + item_amount($item[Ambitious Turkey]) + item_amount($item[Friendly Turkey]);
	}
	return 0;
}

int numPirateInsults()
{
	int retval = 0;
	int i = 1;
	while(i <= 8)
	{
		if(get_property("lastPirateInsult"+i) == "true")
		{
			retval = retval + 1;
		}
		i = i + 1;
	}
	return retval;
}


int fastenerCount()
{
	int base = get_property("chasmBridgeProgress").to_int();
	base = base + item_amount($item[Morningwood Plank]);
	base = base + item_amount($item[Raging Hardwood Plank]);
	base = base + item_amount($item[Weirdwood Plank]);

	return base;
}
int lumberCount()
{
	int base = get_property("chasmBridgeProgress").to_int();
	base = base + item_amount($item[Thick Caulk]);
	base = base + item_amount($item[Long Hard Screw]);
	base = base + item_amount($item[Messy Butt Joint]);

	return base;
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
	if(!cc_have_skill($skill[Calculate the Universe]))
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
			print("Found option for Numberology: " + current + " (" + goal + ")" , "blue");
			if(!doIt)
			{
				return i;
			}

			if(goal == "battlefield")
			{
				string[int] pages;
				pages[0] = "runskillz.php?pwd&action=Skillz&whichskill=144&quantity=1";
				pages[1] = "choice.php?whichchoice=1103&pwd=&option=1&num=" + i;
				ccAdvBypass(0, pages, $location[Noob Cave], option);
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

boolean cc_have_skill(skill sk)
{
	if(!glover_usable(sk) && !sk.passive)
	{
		return false;
	}

	return have_skill(sk);
}

boolean have_skills(boolean[skill] array)
{
	foreach sk in array
	{
		if(!cc_have_skill(sk))
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

boolean in_ronin()
{
	return !can_interact();
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

int cc_mall_price(item it)
{
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
	if(cc_my_path() == "Community Service")
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
	if(!is_unrestricted(it) && !get_property("kingLiberated").to_boolean())
	{
		return false;
	}
	if(pulls_remaining() == 0)
	{
		return false;
	}
	if((item_amount(it) + equipped_amount(it)) == whenHave)
	{
		int lastStorage = storage_amount(it);
		while(storage_amount(it) < howMany)
		{
			int oldPrice = historical_price(it) * 1.2;
			int curPrice = cc_mall_price(it);
			int meat = my_storage_meat();
			boolean getFromStorage = true;
			if(can_interact() && (meat < curPrice))
			{
				meat = my_meat() - 5000;
				getFromStorage = false;
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
					print("Price of " + it + " may have been mall manipulated. Expected to pay at most: " + oldPrice, "red");
				}
				if(my_storage_meat() < curPrice)
				{
					print("Do not have enough meat in Hagnk's to buy " + it + ". Need " + curPrice + " have " + my_storage_meat() + ".", "blue");
					if(curPrice > 10000000)
					{
						print("You must be a poor meatbag.", "green");
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
			print("Can not pull what we don't have. Sorry");
			return false;
		}

		print("Trying to pull " + howMany + " of " + it, "blue");
		boolean retval = take_storage(howMany, it);
		if(item_amount(it) != (howMany + whenHave))
		{
			print("Failed pulling " + howMany + " of " + it, "red");
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
	if(get_property("kingLiberated") != "false")
	{
		take_storage(storage_amount(it), it);
	}
	while((item_amount(it) < quantity) && (cc_mall_price(it) < maxprice))
	{
		if(cc_mall_price(it) > my_meat())
		{
			abort("Don't have enough meat to restock, big sad");
		}
		if(buy(1, it, maxprice) == 0)
		{
			print("Price of " + it + " exceeded expected mall price of " + maxprice + ".", "blue");
			return false;
		}
	}
	if(item_amount(it) < quantity)
	{
		if(cc_mall_price(it) >= maxprice)
		{
			print("Price of " + it + " exceeded expected mall price of " + maxprice + ".", "blue");
		}
		return false;
	}
	return true;
}

//Thanks, Rinn!
string beerPong(string page)
{
	record r {
		string insult;
		string retort;
	};

	r [int] insults;
	insults[1].insult="Arrr, the power of me serve'll flay the skin from yer bones!";
	insults[1].retort="Obviously neither your tongue nor your wit is sharp enough for the job.";
	insults[2].insult="Do ye hear that, ye craven blackguard?  It be the sound of yer doom!";
	insults[2].retort="It can't be any worse than the smell of your breath!";
	insults[3].insult="Suck on <i>this</i>, ye miserable, pestilent wretch!";
	insults[3].retort="That reminds me, tell your wife and sister I had a lovely time last night.";
	insults[4].insult="The streets will run red with yer blood when I'm through with ye!";
	insults[4].retort="I'd've thought yellow would be more your color.";
	insults[5].insult="Yer face is as foul as that of a drowned goat!";
	insults[5].retort="I'm not really comfortable being compared to your girlfriend that way.";
	insults[6].insult="When I'm through with ye, ye'll be crying like a little girl!";
	insults[6].retort="It's an honor to learn from such an expert in the field.";
	insults[7].insult="In all my years I've not seen a more loathsome worm than yerself!";
	insults[7].retort="Amazing!  How do you manage to shave without using a mirror?";
	insults[8].insult="Not a single man has faced me and lived to tell the tale!";
	insults[8].retort="It only seems that way because you haven't learned to count to one.";

	while(!page.contains_text("victory laps"))
	{
		string old_page = page;

		if(!page.contains_text("Insult Beer Pong"))
		{
			abort("You don't seem to be playing Insult Beer Pong.");
		}

		if(page.contains_text("Phooey"))
		{
			print("Looks like something went wrong and you lost.", "lime");
			return page;
		}

		foreach i in insults
		{
			if(page.contains_text(insults[i].insult))
			{
				if(page.contains_text(insults[i].retort))
				{
					print("Found appropriate retort for insult.", "lime");
					print("Insult: " + insults[i].insult, "lime");
					print("Retort: " + insults[i].retort, "lime");
					page = visit_url("beerpong.php?value=Retort!&response=" + i);
					break;
				}
				else
				{
					print("Looks like you needed a retort you haven't learned.", "red");
					print("Insult: " + insults[i].insult, "lime");
					print("Retort: " + insults[i].retort, "lime");

					// Give a bad retort
					page = visit_url("beerpong.php?value=Retort!&response=9");
					return page;
				}
			}
		}

		if(page == old_page)
		{
			abort("String not found. There may be an error with one of the insult or retort strings.");
		}
	}

	print("You won a thrilling game of Insult Beer Pong!", "lime");
	return page;
}

boolean useCocoon()
{
	int mpCost = 0;
	int casts = 1;
	skill cocoon = $skill[none];
	if(have_skill($skill[Cannelloni Cocoon]))
	{
		cocoon = $skill[Cannelloni Cocoon];
		mpCost = mp_cost(cocoon);
	}
	else if(have_skill($skill[Shake It Off]))
	{
		cocoon = $skill[Shake It Off];
		mpCost = mp_cost(cocoon);
	}
	else if(have_skill($skill[Gelatinous Reconstruction]))
	{
		cocoon = $skill[Gelatinous Reconstruction];
		mpCost = mp_cost(cocoon);
		int hpNeed = (my_maxhp() - my_hp()) / 15;
		int maxCasts = my_mp() / mpCost;
		int worst = min(hpNeed, maxCasts);
		casts = min(worst, 7);
	}
	if(cocoon == $skill[none])
	{
		return false;
	}
	if(my_hp() < my_maxhp())
	{
		if((have_effect($effect[Beaten Up]) > 0) && have_skill($skill[Tongue Of The Walrus]))
		{
			casts++;
		}

		if(my_mp() >= (mpCost * casts))
		{
			if((have_effect($effect[Beaten Up]) > 0) && have_skill($skill[Tongue Of The Walrus]))
			{
				use_skill(1, $skill[Tongue Of The Walrus]);
			}
			use_skill(casts, cocoon);
			return true;
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

boolean needStarKey()
{
	if(contains_text(get_property("nsTowerDoorKeysUsed"),"star key"))
	{
		return false;
	}
	if(item_amount($item[Richard\'s Star Key]) > 0)
	{
		return false;
	}
	if((item_amount($item[Star Chart]) > 0) && (item_amount($item[Star]) >= 8) && (item_amount($item[Line]) >= 7))
	{
		return false;
	}

	return true;
}

boolean needDigitalKey()
{
	if(contains_text(get_property("nsTowerDoorKeysUsed"),"digital key"))
	{
		return false;
	}
	if(item_amount($item[Digital Key]) > 0)
	{
		return false;
	}
	if(whitePixelCount() >= 30)
	{
		return false;
	}

	return true;
}

int whitePixelCount()
{
	int count = item_amount($item[White Pixel]);

	int extra = min(item_amount($item[Red Pixel]), item_amount($item[Blue Pixel]));
	extra = min(extra, item_amount($item[Green Pixel]));
	return count + extra;
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
gaudy pirate 
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

boolean beehiveConsider()
{
	if(in_hardcore())
	{
		if(have_skill($skill[Shell Up]) && have_skill($skill[Sauceshell]))
		{
			set_property("cc_getBeehive", false);
		}
		else
		{
			set_property("cc_getBeehive", true);
		}
	}
	else
	{
		if(have_skill($skill[Shell Up]) || have_skill($skill[Sauceshell]))
		{
			set_property("cc_getBeehive", false);
		}
		else
		{
			set_property("cc_getBeehive", true);
		}
	}
	return true;
}


void shrugAT()
{
	shrugAT($effect[none]);
}

void shrugAT(effect anticipated)
{
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
	if(have_skill($skill[Mariachi Memory]))
	{
		maxSongs += 1;
	}


	int count = 1;
	#Put these in priority of keeping.
	boolean[effect] songs = $effects[Inigo\'s Incantation of Inspiration, The Ballad of Richie Thingfinder, Chorale of Companionship, Ode to Booze, Ur-Kel\'s Aria of Annoyance, Carlweather\'s Cantata of Confrontation, The Sonata of Sneakiness, Aloysius\' Antiphon of Aptitude, Fat Leon\'s Phat Loot Lyric, Polka of Plenty, Donho\'s Bubbly Ballad, Prelude of Precision, Elron\'s Explosive Etude, Benetton\'s Medley of Diversity, Dirge of Dreadfulness, Stevedave\'s Shanty of Superiority, Psalm of Pointiness, Brawnee\'s Anthem of Absorption, Jackasses\' Symphony of Destruction, Power Ballad of the Arrowsmith, Cletus\'s Canticle of Celerity, Cringle\'s Curative Carol, The Magical Mojomuscular Melody, The Moxious Madrigal];

	foreach song in songs
	{
		if(have_effect(song) > 0)
		{
			count += 1;
			if(count > maxSongs)
			{
				uneffect(song);
			}
		}
	}
}

string cc_my_path()
{
	// This is for handling the situation briefly after a new path is created so that we can
	// attempt to use proper names.
	// Most of the time, it is just a pointless wrapper.
	// This is only needed in mainline files, path specific files have already been supported.
	return my_path();
}

boolean considerGrimstoneGolem(boolean bjornCrown)
{
	if(!have_familiar($familiar[Grimstone Golem]))
	{
		return false;
	}

	if(bjornCrown && (get_property("_grimstoneMaskDropsCrown").to_int() != 0))
	{
		return false;
	}

	if((get_property("desertExploration").to_int() >= 70) && (get_property("chasmBridgeProgress").to_int() >= 29))
	{
		return false;
	}

	if(get_property("chasmBridgeProgress").to_int() >= 29)
	{
		if(!get_property("cc_grimstoneOrnateDowsingRod").to_boolean())
		{
			return false;
		}
	}

	if(get_property("desertExploration").to_int() >= 70)
	{
		if(!get_property("cc_grimstoneFancyOilPainting").to_boolean())
		{
			return false;
		}
	}

	return true;
}

boolean haveSpleenFamiliar()
{
	boolean [familiar] spleenies = $familiars[Baby Sandworm, Rogue Program, Pair of Stomping Boots, Bloovian Groose, Unconscious Collective, Grim Brother, Golden Monkey];

	int[familiar] blacklist;
	if(get_property("cc_blacklistFamiliar") != "")
	{
		string[int] noFams = split_string(get_property("cc_blacklistFamiliar"), ";");
		foreach index, fam in noFams
		{
			blacklist[to_familiar(trim(fam))] = 1;
		}
	}

	foreach fam in spleenies
	{
		if(have_familiar(fam) && !(blacklist contains fam))
		{
			return true;
		}
	}
	return false;
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

int [item] cc_get_campground()
{
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

	if((campItems contains $item[Source Terminal]) && !get_property("cc_haveSourceTerminal").to_boolean())
	{
		set_property("cc_haveSourceTerminal", true);
	}

	static boolean didCheck = false;
	if((cc_my_path() == "Nuclear Autumn") && !didCheck)
	{
		didCheck = true;
		string temp = visit_url("place.php?whichplace=falloutshelter&action=vault_term");
		if(contains_text(temp, "Source Terminal"))
		{
			set_property("cc_haveSourceTerminal", true);
		}
	}

	if(!(campItems contains $item[Dramatic&trade; range]) && get_property("cc_haveoven").to_boolean())
	{
		campItems[$item[Dramatic&trade; range]] = 1;
	}
	if(!(campItems contains $item[Source Terminal]) && get_property("cc_haveSourceTerminal").to_boolean())
	{
		campItems[$item[Source Terminal]] = 1;
	}

	return campItems;
}

//Thanks, Rinn!
string tryBeerPong()
{
	string page = visit_url("adventure.php?snarfblat=157");
	if(contains_text(page, "Arrr You Man Enough?"))
	{
		page = beerPong(visit_url("choice.php?pwd&whichchoice=187&option=1"));
	}
	return page;
}

boolean buyUpTo(int num, item it)
{
	return buyUpTo(num, it, 20000);
}

boolean buyUpTo(int num, item it, int maxprice)
{
	if(($items[Ben-Gal&trade; Balm, Hair Spray] contains it) && !isGeneralStoreAvailable())
	{
		return false;
	}
	if(($items[Blood of the Wereseal, Cheap Wind-Up Clock, Turtle Pheromones] contains it) && !guild_store_available())
	{
		return false;
	}

	int orig = num;
	num = num - item_amount(it);
	if(num > 0)
	{
		buy(num, it, maxprice);
		if(item_amount(it) < num)
		{
			print("Could not buyUpTo(" + orig + ") of " + it + ". Maxprice: " + maxprice, "red");
		}
	}
	return (item_amount(it) >= num);
}

boolean buffMaintain(skill source, effect buff, int mp_min, int casts, int turns)
{
	if(!glover_usable(buff))
	{
		return false;
	}

	if(!have_skill(source) || (have_effect(buff) >= turns))
	{
		return false;
	}

	if((my_mp() < mp_min) || (my_mp() < (casts * mp_cost(source))))
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
	use_skill(casts, source);
	return true;
}

boolean buffMaintain(item source, effect buff, int uses, int turns)
{
	if(!glover_usable(buff))
	{
		return false;
	}
	if(!glover_usable(source))
	{
		return false;
	}

	if(have_effect(buff) >= turns)
	{
		return false;
	}
	if(!is_unrestricted(source))
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
	use(uses, source);
	return true;
}

boolean buffMaintain(effect buff, int mp_min, int casts, int turns)
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
	case $effect[Ashen Burps]:					useItem = $item[ash soda];						break;
	case $effect[Astral Shell]:					useSkill = $skill[Astral Shell];				break;
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
	case $effect[Berry Elemental]:				useItem = $item[Tapioc Berry];					break;
	case $effect[Berry Statistical]:			useItem = $item[Snarf Berry];					break;
	case $effect[Big]:							useSkill = $skill[Get Big];						break;
	case $effect[Big Meat Big Prizes]:			useItem = $item[Meat-Inflating Powder];			break;
	case $effect[Biologically Shocked]:			useItem = $item[glowing syringe];				break;
	case $effect[Bitterskin]:					useItem = $item[Bitter Pill];					break;
	case $effect[Black Eyes]:					useItem = $item[Black Eye Shadow];				break;
	case $effect[Blackberry Politeness]:		useItem = $item[Blackberry Polite];				break;
	case $effect[Blessing of Serqet]:			useSkill = $skill[Blessing of Serqet];			break;
	case $effect[Blinking Belly]:				useSkill = $skill[Firefly Abdomen];				break;
	case $effect[Blood-Gorged]:					useItem = $item[Vial Of Blood Simple Syrup];	break;
	case $effect[Bloody Potato Bits]:			useSkill = $skill[none];						break;
	case $effect[Bloodstain-Resistant]:			useItem = $item[Bloodstain Stick];				break;
	case $effect[Blubbered Up]:					useSkill = $skill[Blubber Up];					break;
	case $effect[Blue Swayed]:					useItem = $item[Pulled Blue Taffy];				break;
	case $effect[Bone Springs]:					useSkill = $skill[Bone Springs];				break;
	case $effect[Boon of She-Who-Was]:			useSkill = $skill[Spirit Boon];					break;
	case $effect[Boon of the Storm Tortoise]:	useSkill = $skill[Spirit Boon];					break;
	case $effect[Boon of the War Snapper]:		useSkill = $skill[Spirit Boon];					break;
	case $effect[Bounty of Renenutet]:			useSkill = $skill[Bounty of Renenutet];			break;
	case $effect[Bow-Legged Swagger]:			useSkill = $skill[Bow-Legged Swagger];			break;
	case $effect[Brawnee\'s Anthem of Absorption]:useSkill = $skill[Brawnee\'s Anthem of Absorption];break;
	case $effect[Brilliant Resolve]:			useItem = $item[Resolution: Be Smarter];		break;
	case $effect[Brooding]:						useSkill = $skill[Brood];						break;
	case $effect[Browbeaten]:					useItem = $item[Old Eyebrow Pencil];			break;
	case $effect[Busy Bein\' Delicious]:		useItem = $item[Crimbo fudge];					break;
	case $effect[Butt-Rock Hair]:				useItem = $item[Hair Spray];					break;
	case $effect[Carlweather\'s Cantata of Confrontation]:useSkill = $skill[Carlweather\'s Cantata of Confrontation];break;
	case $effect[Cautious Prowl]:				useSkill = $skill[Walk: Cautious Prowl];		break;
	case $effect[Celestial Camouflage]:			useItem = $item[Celestial Squid Ink];			break;
	case $effect[Celestial Saltiness]:			useItem = $item[Celestial Au Jus];				break;
	case $effect[Celestial Sheen]:				useItem = $item[Celestial Olive Oil];			break;
	case $effect[Cinnamon Challenger]:			useItem = $item[Pulled Red Taffy];				break;
	case $effect[Cletus\'s Canticle of Celerity]:	useSkill = $skill[Cletus\'s Canticle of Celerity];break;
	case $effect[Clyde\'s Blessing]:			useItem = $item[The Legendary Beat];			break;
	case $effect[Chalky Hand]:					useItem = $item[Handful of Hand Chalk];			break;
	case $effect[Cranberry Cordiality]:			useItem = $item[Cranberry Cordial];				break;
	case $effect[Cold Hard Skin]:				useItem = $item[Frost-Rimed Seal Hide];			break;
	case $effect[Contemptible Emanations]:		useItem = $item[Cologne of Contempt];			break;
	case $effect[The Cupcake of Wrath]:			useItem = $item[Green-Frosted Astral Cupcake];	break;
	case $effect[Curiosity of Br\'er Tarrypin]:	useSkill = $skill[Curiosity of Br\'er Tarrypin];break;
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
	case $effect[Ear Winds]:					useSkill = $skill[Flappy Ears];					break;
	case $effect[Eau D\'enmity]:				useItem = $item[Perfume of Prejudice];			break;
	case $effect[Eau de Tortue]:				useItem = $item[Turtle Pheromones];				break;
	case $effect[Egged On]:						useItem = $item[Robin\'s Egg];					break;
	case $effect[Eldritch Alignment]:			useItem = $item[Eldritch Alignment Spray];		break;
	case $effect[Elemental Saucesphere]:		useSkill = $skill[Elemental Saucesphere];		break;
	case $effect[Empathy]:
		if(have_familiar($familiar[Mosquito]))
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
	case $effect[Far Out]:						useItem = $item[Patchouli Incense Stick];		break;
	case $effect[Fat Leon\'s Phat Loot Lyric]:	useSkill = $skill[Fat Leon\'s Phat Loot Lyric];	break;
	case $effect[Feeling Punchy]:				useItem = $item[Punching Potion];				break;
	case $effect[Feroci Tea]:					useItem = $item[cuppa Feroci tea];				break;
	case $effect[Fire Inside]:					useItem = $item[Hot Coal];						break;
	case $effect[Fishy\, Oily]:
		if(cc_my_path() == "Heavy Rains")
		{
			useItem = $item[Gourmet Gourami Oil];
		}																						break;
	case $effect[Fishy Fortification]:			useItem = $item[Fish-Liver Oil];				break;
	case $effect[Fishy Whiskers]:
		if(cc_my_path() == "Heavy Rains")
		{
			useItem = $item[Catfish Whiskers];
		}																						break;
	case $effect[Flame-Retardant Trousers]:		useItem = $item[Hot Powder];					break;
	case $effect[Flaming Weapon]:				useItem = $item[Hot Nuggets];					break;
	case $effect[Flamibili Tea]:				useItem = $item[cuppa Flamibili Tea];			break;
	case $effect[Flexibili Tea]:				useItem = $item[cuppa Flexibili Tea];			break;
	case $effect[Flimsy Shield of the Pastalord]:useSkill = $skill[Shield of the Pastalord];	break;
	case $effect[Florid Cheeks]:				useItem = $item[Henna Face Paint];				break;
	case $effect[Football Eyes]:				useItem = $item[Black Facepaint];				break;
	case $effect[Fortunate Resolve]:			useItem = $item[Resolution: Be Luckier];		break;
	case $effect[Frigidalmatian]:				useSkill = $skill[Frigidalmatian];				break;
	case $effect[Frog in Your Throat]:			useItem = $item[Frogade];						break;
	case $effect[From Nantucket]:				useItem = $item[Ye Olde Bawdy Limerick];		break;
	case $effect[Frost Tea]:					useItem = $item[cuppa Frost tea];				break;
	case $effect[Frostbeard]:					useSkill = $skill[Beardfreeze];					break;
	case $effect[Frosty]:						useItem = $item[Frost Flower];					break;
	case $effect[Frown]:						useSkill = $skill[Frown Muscles];				break;
	case $effect[Funky Coal Patina]:			useItem = $item[Coal Dust];						break;
	case $effect[Gelded]:						useItem = $item[Chocolate Filthy Lucre];		break;
	case $effect[Ghostly Shell]:				useSkill = $skill[Ghostly Shell];				break;
	case $effect[The Glistening]:				useItem = $item[Vial of the Glistening];		break;
	case $effect[Glittering Eyelashes]:			useItem = $item[Glittery Mascara];				break;
	case $effect[Go Get \'Em\, Tiger!]:			useItem = $item[Ben-gal&trade; Balm];			break;
	case $effect[Got Milk]:						useItem = $item[Milk of Magnesium];				break;
	case $effect[Gothy]:						useItem = $item[Spooky Eyeliner];				break;
	case $effect[Gr8tness]:						useItem = $item[Potion of Temporary Gr8tness];	break;
	case $effect[Graham Crackling]:				useItem = $item[Heather Graham Cracker];		break;
	case $effect[Greasy Peasy]:					useItem = $item[Robot Grease];					break;
	case $effect[Greedy Resolve]:				useItem = $item[Resolution: Be Wealthier];		break;
	case $effect[Gummed Shoes]:					useItem = $item[Shoe Gum];						break;
	case $effect[Gummi-Grin]:					useItem = $item[Gummi Turtle];					break;
	case $effect[Hairy Palms]:					useItem = $item[Orcish Hand Lotion];			break;
	case $effect[Ham-Fisted]:					useItem = $item[Vial of Hamethyst Juice];		break;
	case $effect[Hardened Fabric]:				useItem = $item[Fabric Hardener];				break;
	case $effect[Hardened Sweatshirt]:			useSkill = $skill[Magic Sweat];					break;
	case $effect[Hardly Poisoned At All]:		useSkill = $skill[Disco Nap];					break;
	case $effect[Healthy Blue Glow]:			useItem = $item[gold star];						break;
	case $effect[Heavy Petting]:				useItem = $item[Knob Goblin Pet-Buffing Spray];	break;
	case $effect[Heightened Senses]:			useItem = $item[airborne mutagen];				break;
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
	case $effect[Hyphemariffic]:				useItem = $item[Black Eyedrops];				break;
	case $effect[Icy Glare]:					useSkill = $skill[Icy Glare];					break;
	case $effect[Impeccable Coiffure]:			useSkill = $skill[Self-Combing Hair];			break;
	case $effect[Inigo\'s Incantation of Inspiration]:useSkill = $skill[Inigo\'s Incantation of Inspiration];break;
	case $effect[Incredibly Hulking]:			useItem = $item[Ferrigno\'s Elixir of Power];	break;
	case $effect[Industrial Strength Starch]:	useItem = $item[Industrial Strength Starch];	break;
	case $effect[Ink Cloud]:					useSkill = $skill[Ink Gland];						break;
	case $effect[Inked Well]:					useSkill = $skill[Squid Glands];				break;
	case $effect[Inscrutable Gaze]:				useSkill = $skill[Inscrutable Gaze];			break;
	case $effect[Insulated Trousers]:			useItem = $item[Cold Powder];					break;
	case $effect[Intimidating Mien]:			useSkill = $skill[Intimidating Mien];			break;
	case $effect[Irresistible Resolve]:			useItem = $item[Resolution: Be Sexier];			break;
	case $effect[Jackasses\' Symphony of Destruction]:useSkill = $skill[Jackasses\' Symphony of Destruction];	break;
	case $effect[Jalape&ntilde;o Saucesphere]:	useSkill = $skill[Jalape&ntilde;o Saucesphere];	break;
	case $effect[Jingle Jangle Jingle]:			useSkill = $skill[Jingle Bells];				break;
	case $effect[Joyful Resolve]:				useItem = $item[Resolution: Be Happier];		break;
	case $effect[Juiced and Jacked]:			useItem = $item[Pumpkin Juice];					break;
	case $effect[Juiced and Loose]:				useSkill = $skill[Steroid Bladder];				break;
	case $effect[Leash of Linguini]:
		if(have_familiar($familiar[Mosquito]))
		{
			useSkill = $skill[Leash of Linguini];
		}																						break;
	case $effect[Leisurely Amblin\']:			useSkill = $skill[Walk: Leisurely Amble];		break;
	case $effect[Lion in Ambush]:				useItem = $item[Lion Musk];						break;
	case $effect[Liquidy Smoky]:				useItem = $item[Liquid Smoke];					break;
	case $effect[Lit Up]:						useItem = $item[Bottle of Lighter Fluid];		break;
	case $effect[Litterbug]:					useItem = $item[Old Candy Wrapper];				break;
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
	case $effect[Muffled]:						useSkill = $skill[Rev Engine];					break;
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
	case $effect[Ode to Booze]:					useSkill = $skill[The Ode to Booze];			break;
	case $effect[Of Course It Looks Great]:		useSkill = $skill[Check Hair];					break;
	case $effect[Oiled Skin]:					useItem = $item[Skin Oil];						break;
	case $effect[Oiled-Up]:						useItem = $item[Pec Oil];						break;
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
	case $effect[Peeled Eyeballs]:				useItem = $item[Knob Goblin Eyedrops];			break;
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
	case $effect[Reptilian Fortitude]:			useSkill = $skill[Reptilian Fortitude];			break;
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
	case $effect[Shield of the Pastalord]:		useSkill = $skill[Shield of the Pastalord];		break;
	case $effect[Shelter of Shed]:				useSkill = $skill[Shelter of Shed];				break;
	case $effect[Shrieking Weasel]:				useItem = $item[Shrieking Weasel Holo-Record];	break;
	case $effect[Simmering]:					useSkill = $skill[Simmer];						break;
	case $effect[Simply Irresistible]:			useItem = $item[Irresistibility Potion];		break;
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
	case $effect[Spice Haze]:					useSkill = $skill[Bind Spice Ghost];			break;
	case $effect[Spiky Hair]:					useItem = $item[Super-Spiky Hair Gel];			break;
	case $effect[Spiky Shell]:					useSkill = $skill[Spiky Shell];					break;
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
	case $effect[Sweet\, Nuts]:					useItem = $item[Crimbo Candied Pecan];			break;
	case $effect[Sweetbreads Flamb&eacute;]:	useItem = $item[Greek Fire];					break;
	case $effect[Takin\' It Greasy]:			useSkill = $skill[Grease Up];					break;
	case $effect[Taunt of Horus]:				useItem = $item[Talisman of Horus];				break;
	case $effect[Temporary Lycanthropy]:		useItem = $item[Blood of the Wereseal];			break;
	case $effect[Tenacity of the Snapper]:		useSkill = $skill[Tenacity of the Snapper];		break;
	case $effect[There is a Spoon]:				useItem = $item[Dented Spoon];					break;
	case $effect[This is Where You\'re a Viking]:useItem = $item[VYKEA woadpaint];				break;
	case $effect[Throwing Some Shade]:			useItem = $item[Shady Shades];					break;
	case $effect[Ticking Clock]:				useItem = $item[Cheap wind-up Clock];			break;
	case $effect[Toad in the Hole]:				useItem = $item[Anti-anti-antidote];			break;
	case $effect[Tomato Power]:					useItem = $item[Tomato Juice of Powerful Power];break;
	case $effect[Tortious]:						useItem = $item[Mocking Turtle];				break;
	case $effect[Truly Gritty]:					useItem = $item[True Grit];						break;
	case $effect[Twen Tea]:						useItem = $item[cuppa Twen tea];				break;
	case $effect[Twinkly Weapon]:				useItem = $item[Twinkly Nuggets];				break;
	case $effect[Unrunnable Face]:				useItem = $item[Runproof Mascara];				break;
	case $effect[Unusual Perspective]:			useItem = $item[Unusual Oil];					break;
	case $effect[Ur-Kel\'s Aria of Annoyance]:	useSkill = $skill[Ur-Kel\'s Aria of Annoyance];	break;
	case $effect[Using Protection]:				useItem = $item[Orcish Rubber];					break;
	case $effect[Visions of the Deep Dark Deeps]:useSkill = $skill[Deep Dark Visions];			break;
	case $effect[Vital]:						useItem = $item[Doc Galaktik\'s Vitality Serum];break;
	case $effect[Vitali Tea]:					useItem = $item[cuppa Vitali tea];				break;
	case $effect[Walberg\'s Dim Bulb]:			useSkill = $skill[Walberg\'s Dim Bulb];			break;
	case $effect[WAKKA WAKKA WAKKA]:			useItem = $item[Yellow Pixel Potion];			break;
	case $effect[Wasabi Sinuses]:				useItem = $item[Knob Goblin Nasal Spray];		break;
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

	boolean[effect] falloutEffects = $effects[Drunk and Avuncular, Lucky Struck, Ministrations in the Dark, Power\, Man, Record Hunger, Shrieking Weasel, Superdrifting];
	if(falloutEffects contains buff)
	{
		if(!possessEquipment($item[Wrist-Boy]))
		{
			return false;
		}
		if($effects[Drunk and Avuncular, Record Hunger] contains buff)
		{
			if(get_property("kingLiberated").to_boolean())
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

	if(!is_unrestricted(useItem))
	{
		return false;
	}

	if(useItem != $item[none])
	{
		return buffMaintain(useItem, buff, casts, turns);
	}
	if((useSkill != $skill[none]) && have_skill(useSkill))
	{
		return buffMaintain(useSkill, buff, mp_min, casts, turns);
	}
	return true;
}

location solveDelayZone()
{
	int[location] delayableZones = zone_delayable();
	int amt = count(delayableZones);
	location burnZone = $location[Noob Cave];
	if(zone_isAvailable($location[Barf Mountain]))
	{
		burnZone = $location[Barf Mountain];
	}
	if(amt != 0)
	{
		int index = 0;
		if(amt > 1)
		{
			index = random(amt);
		}
		foreach idx in delayableZones
		{
			if(index == 0)
			{
				burnZone = idx;
			}
			index--;
		}
	}
	return burnZone;
}
