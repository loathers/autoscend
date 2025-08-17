int[item] auto_get_clan_lounge()
{
	int[item] retval;
	foreach it, val in get_clan_lounge()
	{
		if(is_unrestricted(it))
		{
			retval[it] = val;
		}
	}
	return retval;
}

boolean handleFaxMonster(monster enemy)
{
	return handleFaxMonster(enemy, true, "");
}

boolean handleFaxMonster(monster enemy, string option)
{
	return handleFaxMonster(enemy, true, option);
}

boolean handleFaxMonster(monster enemy, boolean fightIt)
{
	return handleFaxMonster(enemy, fightIt, "");
}

boolean handleFaxMonster(monster enemy, boolean fightIt, string option)
{
	if(get_property("_photocopyUsed").to_boolean())
	{
		return false;
	}
	if(!is_unrestricted($item[deluxe fax machine]))
	{
		return false;
	}
	if(is_boris() || is_jarlsberg() || is_pete() || in_glover())
	{
		return false;
	}
	if(item_amount($item[Clan VIP Lounge Key]) == 0)
	{
		return false;
	}
	if(!(auto_get_clan_lounge() contains $item[Deluxe Fax Machine]))
	{
		return false;
	}
	// don't try to fax unfaxable monsters
	if(!can_faxbot(enemy))
	{
		return false;
	}

	auto_log_info("Using fax machine to summon " + enemy.name, "blue");

	if(item_amount($item[Photocopied Monster]) != 0)
	{
		if(get_property("photocopyMonster") == enemy)
		{
			auto_log_info("We already have the copy! Let's jam!", "blue");
			if(fightIt)
			{
				handleTracker(enemy, $item[deluxe fax machine], "auto_copies");
				return autoAdvBypass("inv_use.php?pwd&which=3&whichitem=4873", $location[Noob Cave], option);
			}
			return true;
		}
		else
		{
			auto_log_info("We already have a photocopy and not the one we wanted. Disposing of bad copy.", "blue");
			cli_execute("fax send");
		}
	}

	auto_log_info("Faxing: " + enemy + ".", "green");
	faxbot(enemy);
	for(int i = 0; i < 3; i++)
	{
		//wait 10 seconds before trying to get fax
		wait(10);
		if(checkFax(enemy))
		{
			//got correct photocopied monster! Fight it now if desired
			auto_log_info("Sucessfully faxed " + enemy);
			if(fightIt)
			{
				handleTracker(enemy, $item[deluxe fax machine], "auto_copies");
				return autoAdvBypass("inv_use.php?pwd&which=3&whichitem=4873", $location[Noob Cave], option);
			}
			return true;
		}
		auto_interruptCheck();
	}

	auto_log_error("Failed to use clan Fax Machine to acquire a photocopied " + enemy);
	return false;
}

boolean checkFax(monster enemy)
{
	if(item_amount($item[photocopied monster]) == 0)
	{
		cli_execute("fax receive");
	}

	if(get_property("photocopyMonster") == enemy.to_string())
	{
		return true;
	}

	cli_execute("fax send");
	return false;
}

boolean [location] get_floundry_locations()
{
	static int lastClanCheck = 0;
	static int lastCheck = 0;
	static int lastLiberation = 0;
	static boolean [location] floundryLocations;

	int currentLiberation = 1;
	if(inAftercore())
	{
		currentLiberation = 2;
	}

	if((get_clan_id() == lastClanCheck) && (lastCheck == my_daycount()) && (currentLiberation == lastLiberation))
	{
		return floundryLocations;
	}

	if(!(auto_get_clan_lounge() contains $item[Clan Floundry]))
	{
		return floundryLocations;
	}

	string page = visit_url("clan_viplounge.php?action=floundry");
	auto_log_info("Generating Floundry Locations for the session...", "blue");

	matcher place_matcher = create_matcher("(?:carp|cod|trout|bass|hatchetfish|tuna):</b>\\s(.*?)<(?:br|/td)>", page);
	while(place_matcher.find())
	{
		floundryLocations[to_location(place_matcher.group(1))] = true;
	}

	lastClanCheck = get_clan_id();
	lastCheck = my_daycount();
	lastLiberation = currentLiberation;
	return floundryLocations;
}

int getBAFHID()
{
	return 90485;
}

boolean isWhitelistedToClan(int clanID)
{
	string page = visit_url("clan_signup.php");
	matcher clan_matcher = create_matcher("<option value=(\\d\\d\\d+)>(.*?)</option>", page);
	while(clan_matcher.find())
	{
		if(clan_matcher.group(1).to_int() == clanID)
		{
			#~ auto_log_debug("Found clan " + clanID + " and name: " + clan_matcher.group(2));
			return true;
		}
	}
	return false;
}

boolean isWhitelistedToBAFH()
{
	return isWhitelistedToClan(getBAFHID());
}

int whitelistedClanToID(string clanName)
{
	string page = visit_url("clan_signup.php");
	matcher clan_matcher = create_matcher("<option value=(\\d\\d\\d+)>(.*?)</option>", page);
	int clanID = 0;
	while(clan_matcher.find())
	{
		if(clan_matcher.group(2) ≈ clanName)
		{
			clanID = to_int(clan_matcher.group(1));
			auto_log_debug("Found clan " + clan_matcher.group(1) + " and name: " + clan_matcher.group(2));
			break;
		}
	}
	return clanID;
}

boolean canReturnToCurrentClan()
{
	return isWhitelistedToClan(get_clan_id());
}

int changeClan(string clanName)
{
	int toClan = 0;
	boolean canReturn = canReturnToCurrentClan();
	
	toClan = whitelistedClanToID(clanName);

	if(toClan == 0)
	{
		auto_log_warning("Do not have a whitelist to destination clan, can not change clans.");
		return 0;
	}
	if(!canReturn)
	{
		auto_log_warning("Do not have a whitelist to our own clan, can not change clans.");
		return 0;
	}

	int oldClan = get_clan_id();
	if(toClan == oldClan)
	{
		auto_log_debug("Already in this clan, no need to try to change (" + toClan + ")", "red");
		return oldClan;
	}

	visit_url("showclan.php?pwd=&recruiter=1&action=joinclan&apply=Apply+to+this+Clan&confirm=on&whichclan=" + toClan, true);

	if(get_clan_id() == oldClan)
	{
		auto_log_error("Clan change failed");
	}
	return get_clan_id();
}

int changeClan(int toClan)
{
	//Returns new clan ID (or old one if it failed)
	
	int oldClan = get_clan_id();
	if(toClan == oldClan)
	{
		auto_log_debug("Already in this clan, no need to try to change (" + toClan + ")", "red");
		return oldClan;
	}

	string page = visit_url("clan_signup.php");
	if(!contains_text(page, "option value=" + oldClan + ">"))
	{
		auto_log_warning("Do not have a whitelist to our own clan, can not change clans.");
		return 0;
	}
	if(!contains_text(page, "option value=" + toClan + ">"))
	{
		auto_log_warning("Do not have a whitelist to destination clan, can not change clans.");
		return 0;
	}

	page = visit_url("showclan.php?pwd=&recruiter=1&action=joinclan&apply=Apply+to+this+Clan&confirm=on&whichclan=" + toClan, true);

	if(get_clan_id() == oldClan)
	{
		auto_log_error("Clan change failed");
	}
	return get_clan_id();
}


int changeClan()		//To BAFH
{
	return changeClan(getBAFHID());
}


int hotTubSoaksRemaining(){
	return 5 - get_property("_hotTubSoaks").to_int();
}

boolean isHotTubAvailable(){
	return (item_amount($item[Clan VIP Lounge Key]) > 0) && is_unrestricted($item[Clan VIP Lounge Key]);
}

int doHottub()
{
	//Returns number of usages left.
	
	if(!(isHotTubAvailable() && hotTubSoaksRemaining() > 0))
	{
		return 0;
	}
	cli_execute("hottub");

	return hotTubSoaksRemaining();
}

boolean isSpeakeasyDrink(item drink)
{
	return $items[glass of &quot;milk&quot;, cup of &quot;tea&quot;, thermos of &quot;whiskey&quot;, Lucky Lindy, Bee's Knees, Sockdollager, Ish Kabibble, Hot Socks, Phonus Balonus, Flivver, Sloppy Jalopy] contains drink;
}

boolean canDrinkSpeakeasyDrink(item drink)
{
	if(!isSpeakeasyDrink(drink))
	{
		return false;
	}

	if(item_amount($item[Clan VIP Lounge Key]) == 0)
	{
		return false;
	}

	if(get_property("_speakeasyDrinksDrunk").to_int() >= 3)
	{
		return false;
	}

	if(!(auto_get_clan_lounge() contains $item[Clan Speakeasy]))
	{
		return false;
	}

	if(!(auto_get_clan_lounge() contains drink))
	{
		return false;
	}

	if(my_meat() < npc_price(drink))
	{
		return false;
	}

	if(inebriety_left() < 0)
	{
		return false;
	}

	return true;
}

boolean drinkSpeakeasyDrink(item drink)
{
	if(!canDrinkSpeakeasyDrink(drink))
	{
		return false;
	}

	return cli_execute("drink 1 " + drink);
}

boolean drinkSpeakeasyDrink(string drink)
{
	if(!(auto_get_clan_lounge() contains $item[Clan Speakeasy]))
	{
		return false;
	}

	item realDrink = to_item(drink);
	if(realDrink == $item[None])
	{
		return false;
	}
	return drinkSpeakeasyDrink(realDrink);
}

boolean zataraAvailable()
{
	if(item_amount($item[Clan VIP Lounge Key]) == 0)
	{
		return false;
	}
	if(get_property("_clanFortuneBuffUsed").to_boolean())
	{
		return false;
	}

	if(!is_unrestricted($item[Clan Carnival Game]))
	{
		return false;
	}

	if(!(auto_get_clan_lounge() contains $item[Clan Carnival Game]))
	{
		return false;
	}
	return true;
}

boolean zataraSeaside(string who)
{
	if(!zataraAvailable()) return false;

	who = to_lower_case(who);

	int id = 0;

	if((who == "susie") || (who == "familiar") || (who == "-1") || (who ≈ $effect[A Girl Named Sue]))
	{
		id = -1;
	}
	else if((who == "hagnk") || (who == "food") || (who == "booze") || (who == "item") || (who == "-2") || (who ≈ $effect[There\'s No N In Love]))
	{
		id = -2;
	}
	else if((who == "meatsmith") || (who == "gear") || (who == "meat") || (who == "-3") || (who ≈ $effect[Meet The Meat]))
	{
		id = -3;
	}
	else if((who == "gunther") || (who == "muscle") || (who == "hp") || (who == "-4") || (who ≈ $effect[Gunther Than Thou]))
	{
		id = -4;
	}
	else if((who == "gorgonzola") || (who == "myst") || (who == "mysticality") || (who == "mp") || (who == "-5") || (who ≈ $effect[Everybody Calls Him Gorgon]))
	{
		id = -5;
	}
	else if((who == "shifty") || (who == "moxie") || (who == "init") || (who == "-6") || (who ≈ $effect[They Call Him Shifty Because...]))
	{
		id = -6;
	}


	if(id == 0)
	{
		return false;
	}

	string temp = visit_url("clan_viplounge.php?preaction=lovetester", false);
	temp = visit_url("choice.php?pwd=&whichchoice=1278&option=1&which=" + id);
	set_property("_clanFortuneBuffUsed", true);
	return true;
}

boolean zataraClanmate()
{
	if(item_amount($item[Clan VIP Lounge Key]) == 0)
	{
		return false;
	}

	if(!is_unrestricted($item[Clan Carnival Game]))
	{
		return false;
	}

	if(!(auto_get_clan_lounge() contains $item[Clan Carnival Game]))
	{
		return false;
	}

	if(get_property("_clanFortuneConsultUses").to_int() >= 3)
	{
		return false;
	}

#	string page = visit_url("clan_viplounge.php");
#	if(!contains_text(page, "lovetester"))
#	{
#		set_property("_clanFortuneConsultUses", 3);
#		return false;
#	}
#	set_property("_clanFortuneConsultUses", get_property("_clanFortuneConsultUses").to_int() + 1);

	int attempts = 0;
	int player = 3690803;
	string consultOverrideName = get_property("auto_consultChoice");
	string name = get_player_name(player);
	if (consultOverrideName != "")
	{
		name = consultOverrideName;
		player = get_player_id(consultOverrideName).to_int();
	}

	if (!is_online(name))
	{
		// consult will not return in reasonable timeframe
		return false;
	}

	int oldClan = get_clan_id();
	string clanName = get_property("auto_consultClan");
	if (clanName != "")
	{
		changeClan(clanName);
	}
	else
	{
		clanName = "Bonus Adventures from Hell";
		changeClan();
	}
	if(get_clan_name() != clanName)
	{
		set_property("_clanFortuneConsultUses", 42069);
		return false;
	}

	boolean needWait = true;

	while(attempts < 5)
	{
		string temp = visit_url("clan_viplounge.php?preaction=lovetester", false);
		string choices = "&q1=pizza&q2=batman&q3=thick";
		if (get_property("auto_optimizeConsultsInRun").to_boolean() && my_path() != $path[none])
		{
			choices = "&q1=cake&q2=wonderwoman&q3=thick";
		}
		temp = visit_url("choice.php?pwd=&whichchoice=1278&option=1&which=1&whichid="+ player + choices);

		if(contains_text(temp, "You can't consult Madame Zatara about your relationship with anyone else today."))
		{
			auto_log_warning("No consults left today. Uh oh", "red");
			set_property("_clanFortuneConsultUses", 3);
			needWait = false;
			break;
		}
		if(contains_text(temp, "You enter your answers and wait for " + name + " to answer, so you can get your results!"))
		{
			auto_log_info("And now we play the waiting game...", "green");
			break;
		}
		if(contains_text(temp, "You're already waiting on your results with " + name + "."))
		{
			auto_log_info("Results pending from prior request...", "blue");
		}
		else if(contains_text(temp, "You can only consult Madame Zatara about someone in your clan."))
		{
			auto_log_info(name + " is not in the clan... waiting...", "blue");
		}

		attempts++;
		wait(5);
	}


	changeClan(oldClan);
	if(needWait)
	{
		wait(10);
	}
	return true;
}

boolean eatFancyDog(string dog)
{
	if(item_amount($item[Clan VIP Lounge Key]) == 0)
	{
		return false;
	}
	if(get_property("_fancyHotDogEaten").to_boolean() && (dog != "basic hot dog"))
	{
		return false;
	}

	if(!(auto_get_clan_lounge() contains $item[Clan Hot Dog Stand]))
	{
		return false;
	}

	dog = to_lower_case(dog);

	static int [string] dogFull;
	static item [string] dogReq;
	static int [string] dogAmt;
	static int [string] dogID;
	dogFull["basic hot dog"] = 1;
	dogFull["savage macho dog"] = 2;
	dogFull["one with everything"] = 2;
	dogFull["sly dog"] = 2;
	dogFull["devil dog"] = 3;
	dogFull["chilly dog"] = 3;
	dogFull["ghost dog"] = 3;
	dogFull["junkyard dog"] = 3;
	dogFull["wet dog"] = 3;
	dogFull["optimal dog"] = 1;
	dogFull["sleeping dog"] = 2;
	dogFull["video games hot dog"] = 3;

	dogReq["basic hot dog"] = $item[none];
	dogReq["savage macho dog"] = $item[furry fur];
	dogReq["one with everything"] = $item[cranberries];
	dogReq["sly dog"] = $item[skeleton bone];
	dogReq["devil dog"] = $item[hot wad];
	dogReq["chilly dog"] = $item[cold wad];
	dogReq["ghost dog"] = $item[spooky wad];
	dogReq["junkyard dog"] = $item[stench wad];
	dogReq["wet dog"] = $item[sleaze wad];
	dogReq["optimal dog"] = $item[tattered scrap of paper];
	dogReq["sleeping dog"] = $item[gauze hammock];
	dogReq["video games hot dog"] = $item[GameInformPowerDailyPro magazine];

	dogAmt["basic hot dog"] = 0;
	dogAmt["savage macho dog"] = 10;
	dogAmt["one with everything"] = 10;
	dogAmt["sly dog"] = 10;
	dogAmt["devil dog"] = 25;
	dogAmt["chilly dog"] = 25;
	dogAmt["ghost dog"] = 25;
	dogAmt["junkyard dog"] = 25;
	dogAmt["wet dog"] = 25;
	dogAmt["optimal dog"] = 25;
	dogAmt["sleeping dog"] = 10;
	dogAmt["video games hot dog"] = 3;

	dogID["basic hot dog"] = 0;
	dogID["savage macho dog"] = -93;
	dogID["one with everything"] = -94;
	dogID["sly dog"] = -95;
	dogID["devil dog"] = -96;
	dogID["chilly dog"] = -97;
	dogID["ghost dog"] = -98;
	dogID["junkyard dog"] = -99;
	dogID["wet dog"] = -100;
	dogID["optimal dog"] = -102;
	dogID["sleeping dog"] = -101;
	dogID["video games hot dog"] = -103;

	if(!(dogFull contains dog))
	{
		abort("Invalid hot dog: " + dog);
	}

	string page = visit_url("clan_viplounge.php?action=hotdogstand");
	if(!contains_text(page, dog))
	{
		return false;
	}

	if(fullness_left() < dogFull[dog])
	{
		return false;
	}

	int need = dogAmt[dog] - storage_amount(dogReq[dog]);
	if(need > 0)
	{
		if(buy_using_storage(need, dogReq[dog], min(1.5 * historical_price(dogReq[dog]), 30000)) == 0)
		{
			auto_log_warning("Could not buy " + dogReq[dog] + " for a fancy dog. Price may have been manipulated.", "red");
			wait(5);
			return false;
		}
	}

	if(storage_amount(dogReq[dog]) < dogAmt[dog])
	{
		return false;
	}

	visit_url("clan_viplounge.php?action=hotdogstand");

	if(dogAmt[dog] > 0)
	{
		visit_url("clan_viplounge.php?preaction=hotdogsupply&hagnks=1&whichdog=" + dogID[dog] + "&quantity=" + dogAmt[dog]);
	}

	visit_url("clan_viplounge.php?action=hotdogstand");

	cli_execute("eatsilent 1 " + dog);
	handleTracker(dog, "auto_eaten");
	return true;
}

boolean auto_floundryUse()
{
	if(!get_property("_floundryItemUsed").to_boolean())
	{
		foreach it in $items[Bass Clarinet, Codpiece, Fish Hatchet]
		{
			if(possessEquipment(it))
			{
				use(1, it);
				return true;
			}
		}
	}
	return false;
}

boolean auto_floundryAction()
{
	if(get_property("_floundryItemCreated").to_boolean())
	{
		return false;
	}
	
	// Handle whether we can jump to BAFH
	int orig_clan_id = get_clan_id();
	boolean in_bafh = orig_clan_id == getBAFHID();
	boolean bafh_available = isWhitelistedToBAFH() && canReturnToCurrentClan(); // bafh probably has it fully stocked
	
	if(!get_property("_floundryItemGot").to_boolean() && (auto_get_clan_lounge() contains $item[Clan Floundry]) && !inAftercore())
	{
		if(get_property("auto_floundryChoice") != "")
		{
			string[int] floundryChoice = split_string(get_property("auto_floundryChoice"), ";");
			item myFloundry = trim(floundryChoice[min(count(floundryChoice), my_daycount()) - 1]).to_item();
			boolean success = auto_floundryAction(myFloundry);
			if(!success)
			{
				if (bafh_available)
				{
					changeClan(); // Jump to BAFH
					success = auto_floundryAction(myFloundry);
					changeClan(orig_clan_id); // go home
				}
			}
			if (success)
			{
				if(($items[Bass Clarinet, Codpiece, Fish Hatchet] contains myFloundry) && !get_property("_floundryItemUsed").to_boolean() && (item_amount(myFloundry) > 0))
				{
					use(1, myFloundry);
				}
				set_property("_floundryItemGot", true);
				return true;
			}
			else
			{
				auto_log_warning("Could not fish from the Floundry for some raisin.", "red");
				return false;
			}
		}
	}
	return false;
}

boolean auto_floundryAction(item it)
{
	if(get_property("_floundryItemCreated").to_boolean())
	{
		return false;
	}
	int[item] fish = auto_get_clan_lounge();
	if(fish[it] > 0)
	{
		string temp = visit_url("clan_viplounge.php?preaction=buyfloundryitem&whichitem=" + it.to_int());
		return true;
	}
	return false;
}
