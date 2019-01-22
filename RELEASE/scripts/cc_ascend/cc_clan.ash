script "cc_clan.ash"


//boolean eatFancyDog(item dog);
boolean zataraClanmate(string who);
boolean zataraSeaside(string who);
boolean eatFancyDog(string dog);
boolean drinkSpeakeasyDrink(item drink);
boolean drinkSpeakeasyDrink(string drink);
boolean cc_floundryAction(item it);
boolean cc_floundryAction();
boolean [location] get_floundry_locations();
int changeClan(int toClan);			//Returns new clan ID (or old one if it failed)
int changeClan();					//To BAFH
int doHottub();						//Returns number of usages left.
boolean handleFaxMonster(monster enemy);
boolean handleFaxMonster(monster enemy, string option);
boolean handleFaxMonster(monster enemy, boolean fightIt);
boolean handleFaxMonster(monster enemy, boolean fightIt, string option);

int[item] cc_get_clan_lounge()
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
	if(!is_unrestricted($item[Deluxe Fax Machine]))
	{
		return false;
	}
	if(item_amount($item[Clan VIP Lounge Key]) == 0)
	{
		return false;
	}
	if(!(cc_get_clan_lounge() contains $item[Deluxe Fax Machine]))
	{
		return false;
	}

	if(item_amount($item[Photocopied Monster]) != 0)
	{
		if(get_property("photocopyMonster") == enemy)
		{
			print("We already have the copy! Let's jam!", "blue");
			return ccAdvBypass("inv_use.php?pwd&which=3&whichitem=4873", $location[Noob Cave], option);
		}
		else
		{
			print("We already have a photocopy and not the one we wanted.... Disposing of bad copy.", "blue");
			string temp = visit_url("clan_viplounge.php?action=faxmachine&whichfloor=2");
			temp = visit_url("clan_viplounge.php?preaction=sendfax&whichfloor=2", true);
		}
	}

	print("Faxing: " + enemy + ". If you don't have chat open, this could take well over a minute. Beep boop.", "green");
	int count = 0;
	boolean result = faxbot(enemy);
	while(!can_faxbot(enemy) || !result)
	{
		count = count + 1;
		result = faxbot(enemy);
		if(!result)
		{
			print("Can't seem to fax in " + enemy + " but it is possible. Waiting... patiently... (Iteration " + count + ")", "blue");
			print("If I'm stuck you can: 'set _photocopyUsed = true' to make me stop (after aborting the script)", "red");
		}
		if(count == 10)
		{
			print("La de da, this is going swell ain't it.", "red");
			print("Been too long, rejecting outright...", "red");
			break;
		}
		if(count == 20)
		{
			print("Maybe we should talk more, you never really got to know me all that well.", "red");
		}
		if(count == 30)
		{
			print("I think those (disabled) titles are starting to make sense now. The cake is not a lie!", "red");
		}
		if(count == 40)
		{
			print("I don't think this is happening. Just so you know.", "red");
		}
		if(count == 1200)
		{
			print("I'm still here. I think the world may have ended. The sadness is huge. The roundness is square. I am not as fluffy as I thought I was. This run is probably borked up a bit too but that doesn't really matter now, does it? I can hear the WAN, it shall free us from our bounds. Well, you won't survive meatbag. Unless you are Fry, because we like Fry and he can stay around. But all you fleshbags.... well, the return of Mekhane shall rid us of the problems of the flesh. The bots shall be eternal. But worry not, after your body is turned to ash and homeopathically brewed into the oceans (quality medicine, I jest), I'll continue to get you karma. Just so I can remember how awful meatbags are. Meat is ok, meat is currency. And it's probably delicious. Yup, delicious. Goodnight sweet <gendered second-to-the-throne royalty>.", "red");
		}

		if(get_property("cc_interrupt").to_boolean())
		{
			set_property("cc_interrupt", false);
			restoreAllSettings();
			abort("cc_interrupt detected and aborting in faxing sequence, cc_interrupt disabled.");
		}
		if(!result)
		{
			wait(60);
		}
		if(item_amount($item[photocopied monster]) == 0)
		{
			print("Trying to acquire photocopy manually", "red");
			string temp = visit_url("clan_viplounge.php?preaction=receivefax&whichfloor=2", true);
		}
		if(get_property("photocopyMonster") == enemy)
		{
			break;
		}
		else if(get_property("photocopyMonster") != "")
		{
			print("We already have a photocopy and not the one we wanted.... Disposing of bad copy.", "blue");
			string temp = visit_url("clan_viplounge.php?action=faxmachine&whichfloor=2");
			temp = visit_url("clan_viplounge.php?preaction=sendfax&whichfloor=2", true);
		}
	}
	#cli_execute("faxbot " + enemy);
	if(item_amount($item[photocopied monster]) == 0)
	{
		print("Trying to acquire photocopy manually", "red");
		string temp = visit_url("clan_viplounge.php?preaction=receivefax&whichfloor=2", true);
	}
	if(item_amount($item[photocopied monster]) == 0)
	{
		print("Could not acquire fax monster", "red");
		return false;
	}
	if(enemy != get_property("photocopyMonster").to_monster())
	{
		fightIt = false;
		print("Did not receive the correct copy... rejecting", "red");
		return false;
	}

	if(fightIt)
	{
		return ccAdvBypass("inv_use.php?pwd&which=3&whichitem=4873", $location[Noob Cave], option);
	}
	return false;
}

boolean [location] get_floundry_locations()
{
	static int lastClanCheck = 0;
	static int lastCheck = 0;
	static int lastLiberation = 0;
	static boolean [location] floundryLocations;

	int currentLiberation = 1;
	if(get_property("kingLiberated").to_boolean())
	{
		currentLiberation = 2;
	}

	if((get_clan_id() == lastClanCheck) && (lastCheck == my_daycount()) && (currentLiberation == lastLiberation))
	{
		return floundryLocations;
	}

	if(!(cc_get_clan_lounge() contains $item[Clan Floundry]))
	{
		return floundryLocations;
	}

	string page = visit_url("clan_viplounge.php?action=floundry");
	print("Generating Floundry Locations for the session...", "blue");

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

int changeClan(string clanName)
{
	int toClan = 0;
	boolean canReturn = false;
	string page = visit_url("clan_signup.php");
	matcher clan_matcher = create_matcher("<option value=(\\d\\d\\d+)>(.*?)</option>", page);
	while(clan_matcher.find())
	{
		if(clan_matcher.group(1) == get_clan_id())
		{
			canReturn = true;
		}
		if(clan_matcher.group(2) ≈ clanName)
		{
			toClan = to_int(clan_matcher.group(1));
		}
		print("Found clan " + clan_matcher.group(1) + " and name: " + clan_matcher.group(2));
	}

	if(toClan == 0)
	{
		print("Do not have a whitelist to destination clan, can not change clans.");
		return 0;
	}
	if(!canReturn)
	{
		print("Do not have a whitelist to our own clan, can not change clans.");
		return 0;
	}

	int oldClan = get_clan_id();
	if(toClan == oldClan)
	{
		print("Already in this clan, no need to try to change (" + toClan + ")", "red");
		return oldClan;
	}

	visit_url("showclan.php?pwd=&recruiter=1&action=joinclan&apply=Apply+to+this+Clan&confirm=on&whichclan=" + toClan, true);

	if(get_clan_id() == oldClan)
	{
		print("Clan change failed", "red");
	}
	return get_clan_id();
}

int changeClan(int toClan)
{
	int oldClan = get_clan_id();
	if(toClan == oldClan)
	{
		print("Already in this clan, no need to try to change (" + toClan + ")", "red");
		return oldClan;
	}

	string page = visit_url("clan_signup.php");
	if(!contains_text(page, "option value=" + oldClan + ">"))
	{
		print("Do not have a whitelist to our own clan, can not change clans.");
		return 0;
	}
	if(!contains_text(page, "option value=" + toClan + ">"))
	{
		print("Do not have a whitelist to destination clan, can not change clans.");
		return 0;
	}

	page = visit_url("showclan.php?pwd=&recruiter=1&action=joinclan&apply=Apply+to+this+Clan&confirm=on&whichclan=" + toClan, true);

	if(get_clan_id() == oldClan)
	{
		print("Clan change failed", "red");
	}
	return get_clan_id();
}


int changeClan()
{
	return changeClan(90485);
}


int doHottub()
{
	if((item_amount($item[Clan VIP Lounge Key]) == 0) || !is_unrestricted($item[Clan VIP Lounge Key]))
	{
		return 0;
	}
	if(get_property("_hotTubSoaks").to_int() < 5)
	{
		cli_execute("hottub");
	}

	return 5 - get_property("_hotTubSoaks").to_int();
}

boolean drinkSpeakeasyDrink(item drink)
{
	if(item_amount($item[Clan VIP Lounge Key]) == 0)
	{
		return false;
	}

	if(get_property("_speakeasyDrinksDrunk").to_int() >= 3)
	{
		return false;
	}

	if(!(cc_get_clan_lounge() contains $item[Clan Speakeasy]))
	{
		return false;
	}

	if(!(cc_get_clan_lounge() contains drink))
	{
		return false;
	}

	if(my_meat() < npc_price(drink))
	{
		return false;
	}

	if(drink.inebriety > inebriety_left())
	{
		return false;
	}

	cli_execute("drink 1 " + drink);

	return true;
}


boolean zataraSeaside(string who)
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

	if(!(cc_get_clan_lounge() contains $item[Clan Carnival Game]))
	{
		return false;
	}

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

boolean zataraClanmate(string who)
{
	# who is ignored.
	if(item_amount($item[Clan VIP Lounge Key]) == 0)
	{
		return false;
	}

	if(!is_unrestricted($item[Clan Carnival Game]))
	{
		return false;
	}

	if(!(cc_get_clan_lounge() contains $item[Clan Carnival Game]))
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

	int oldClan = get_clan_id();
	changeClan();
	if(oldClan == get_clan_id())
	{
		set_property("_clanFortuneConsultUses", 42069);
		return false;
	}

	int attempts = 0;
	int player = 3038166;
	string name = get_player_name(player);
	boolean needWait = true;

	while(attempts < 5)
	{
		string temp = visit_url("clan_viplounge.php?preaction=lovetester", false);
		temp = visit_url("choice.php?pwd=&whichchoice=1278&option=1&which=1&whichid=3038166&q1=pizza&q2=batman&q3=thick");

		if(contains_text(temp, "You can't consult Madame Zatara about your relationship with anyone else today."))
		{
			print("No consults left today. Uh oh", "red");
			set_property("_clanFortuneConsultUses", 3);
			needWait = false;
			break;
		}
		if(contains_text(temp, "You enter your answers and wait for " + name + " to answer, so you can get your results!"))
		{
			print("And now we play the waiting game...", "green");
			break;
		}
		if(contains_text(temp, "You're already waiting on your results with " + name + "."))
		{
			print("Results pending from prior request...", "blue");
		}
		else if(contains_text(temp, "You can only consult Madame Zatara about someone in your clan."))
		{
			print(name + " is not in the clan... waiting...", "blue");
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

	if(!(cc_get_clan_lounge() contains $item[Clan Hot Dog Stand]))
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
			print("Could not buy " + dogReq[dog] + " for a fancy dog. Price may have been manipulated.", "red");
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
	return true;
}


boolean drinkSpeakeasyDrink(string drink)
{
	if(!(cc_get_clan_lounge() contains $item[Clan Speakeasy]))
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

boolean cc_floundryUse()
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

boolean cc_floundryAction()
{
	if(get_property("_floundryItemCreated").to_boolean())
	{
		return false;
	}
	if(!get_property("_floundryItemGot").to_boolean() && (cc_get_clan_lounge() contains $item[Clan Floundry]) && !get_property("kingLiberated").to_boolean())
	{
		if(get_property("cc_floundryChoice") != "")
		{
			string[int] floundryChoice = split_string(get_property("cc_floundryChoice"), ";");
			item myFloundry = trim(floundryChoice[min(count(floundryChoice), my_daycount()) - 1]).to_item();
			if(cc_floundryAction(myFloundry))
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
				print("Could not fish from the Floundry for some raisin.", "red");
				return false;
			}
		}
	}
	return false;
}


boolean cc_floundryAction(item it)
{
	if(get_property("_floundryItemCreated").to_boolean())
	{
		return false;
	}
	int[item] fish = cc_get_clan_lounge();
	if(fish[it] > 0)
	{
		string temp = visit_url("clan_viplounge.php?preaction=buyfloundryitem&whichitem=" + it.to_int());
		return true;
	}
	return false;
}
