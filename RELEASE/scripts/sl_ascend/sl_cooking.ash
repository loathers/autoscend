script "sl_cooking.ash"

#
#	Handler for in-run consumption
#

void consumeStuff();
boolean makePerfectBooze();
item getAvailablePerfectBooze();
boolean dealWithMilkOfMagnesium(boolean useAdv);
boolean slEat(int howMany, item toEat);
boolean slEat(int howMany, item toEat, boolean silent);
boolean slDrink(int howMany, item toDrink);
boolean slOverdrink(int howMany, item toOverdrink);
boolean slChew(int howMany, item toChew);
boolean tryPantsEat();
boolean tryCookies();
boolean canDrink(item toDrink);
boolean canEat(item toEat);
boolean sl_maximizedConsumeStuff();

boolean keepOnTruckin()
{
	if(get_property("sl_limitConsume").to_boolean())
	{
		return false;
	}

	if(in_hardcore())
	{
		return false;
	}

	if(pulls_remaining() == 0)
	{
		return false;
	}

	if(!in_tcrs())
	{
		foreach it in $items[Hacked Gibson, Browser Cookie, Popular Tart, Spaghetti With Skullheads, Crudles, Corpsedriver, Corpsetini, Corpse Island Iced Tea, Corpse On The Beach, Bungle In The Jungle, Mon Tiki, Yellow Brick Road, Divine, Gimlet, Neuromancer, Prussian Cathouse, Ye Olde Meade]
		{
			if(!is_unrestricted(it))
			{
				continue;
			}
			if(fullness_left() < it.fullness)
			{
				continue;
			}
			if((it.fullness > 0) && !canEat(it))
			{
				continue;
			}
			if((it.inebriety > 0) && !canDrink(it))
			{
				continue;
			}
			if(inebriety_left() < it.inebriety)
			{
				continue;
			}
			if(my_level() < it.levelreq)
			{
				continue;
			}
			int filling = it.fullness + it.inebriety;
			if(mall_price(it) > (1250 * filling))
			{
				continue;
			}
			if(item_amount(it) > 0)
			{
				//We already have it and should probably eat it or something.
				break;
			}
			if(pullXWhenHaveY(it, 1, 0))
			{
				break;
			}
		}
	}
	consumeStuff();
	return true;
}

boolean saucemavenApplies(item it)
{
	static boolean[item] saucy_foods = $items[Cold hi mein,
		Devil hair pasta,
		Fettris,
		Fettucini Inconnu,
		Fleetwood mac 'n' cheese,
		Fusillocybin,
		Gnocchetti di Nietzsche,
		Haunted Hell ramen,
		Hell ramen,
		Hot hi mein,
		Libertagliatelle,
		Linguini immondizia bianco,
		Linguini of the sea,
		Prescription noodles,
		Shells a la shellfish,
		Sleazy hi mein,
		Spagecialetti,
		Spaghetti con calaveras,
		Spaghetti with Skullheads,
		Spooky hi mein,
		Stinky hi mein,
		Turkish mostaccioli];
	return saucy_foods contains it;
}

float expectedAdventuresFrom(item it)
{
	if(it == $item[magical sausage]) return 1;

	float parse()
	{
		if (!it.adventures.contains_text("-")) return it.adventures.to_int();
		string[int] s = split_string(it.adventures, "-");
		return (s[1].to_int() + s[0].to_int())/2.0;
	}
	float expected = parse();
	if(sl_have_skill($skill[Saucemaven]) && saucemavenApplies(it))
	{
		if ($classes[Sauceror, Pastamancer] contains my_class()) expected += 5;
		else expected += 3;
	}
	//if (item_amount($item[black label]) > 0 && $items[bottle of gin, bottle of rum, bottle of tequila, bottle of vodka or bottle of whiskey] contains it)
	//	expected += 3.5;
	return expected;
}

item getAvailablePerfectBooze()
{
	if(!is_unrestricted($item[Perfect Old-Fashioned]))
	{
		return $item[none];
	}
	switch(my_primestat())
	{
	case $stat[Muscle]:
		foreach booze in $items[Perfect Old-Fashioned, Perfect Cosmopolitan, Perfect Paloma, Perfect Mimosa, Perfect Negroni, Perfect Dark and Stormy]
		{
			if(item_amount(booze) > 0)
			{
				return booze;
			}
		}
		break;
	case $stat[Mysticality]:
		foreach booze in $items[Perfect Dark and Stormy, Perfect Mimosa, Perfect Negroni, Perfect Cosmopolitan, Perfect Paloma, Perfect Old-Fashioned]
		{
			if(item_amount(booze) > 0)
			{
				return booze;
			}
		}
		break;
	case $stat[Moxie]:
		foreach booze in $items[Perfect Paloma, Perfect Negroni, Perfect Old-Fashioned, Perfect Dark and Stormy, Perfect Cosmopolitan, Perfect Mimosa]
		{
			if(item_amount(booze) > 0)
			{
				return booze;
			}
		}
		break;
	}
	return $item[none];
}

boolean makePerfectBooze()
{
	if(!is_unrestricted($item[Perfect Old-Fashioned]))
	{
		return false;
	}
	if(item_amount($item[Perfect Ice Cube]) == 0)
	{
		return false;
	}

	int starting = item_amount($item[Perfect Ice Cube]);

	switch(my_primestat())
	{
	case $stat[Muscle]:
		if(item_amount($item[Bottle of Whiskey]) > 0)
		{
			cli_execute("make " + $item[Perfect Old-Fashioned]);
		}
		else if(item_amount($item[Bottle of Vodka]) > 0)
		{
			cli_execute("make " + $item[Perfect Cosmopolitan]);
		}
		else if(item_amount($item[Bottle of Tequila]) > 0)
		{
			cli_execute("make " + $item[Perfect Paloma]);
		}
		else if(item_amount($item[Boxed Wine]) > 0)
		{
			cli_execute("make " + $item[Perfect Mimosa]);
		}
		else if(item_amount($item[Bottle of Gin]) > 0)
		{
			cli_execute("make " + $item[Perfect Negroni]);
		}
		else if(item_amount($item[Bottle of Rum]) > 0)
		{
			cli_execute("make " + $item[Perfect Dark and Stormy]);
		}
		break;
	case $stat[Mysticality]:
		if(item_amount($item[Bottle of Rum]) > 0)
		{
			cli_execute("make " + $item[Perfect Dark and Stormy]);
		}
		else if(item_amount($item[Boxed Wine]) > 0)
		{
			cli_execute("make " + $item[Perfect Mimosa]);
		}
		else if(item_amount($item[Bottle of Gin]) > 0)
		{
			cli_execute("make " + $item[Perfect Negroni]);
		}
		else if(item_amount($item[Bottle of Vodka]) > 0)
		{
			cli_execute("make " + $item[Perfect Cosmopolitan]);
		}
		else if(item_amount($item[Bottle of Tequila]) > 0)
		{
			cli_execute("make " + $item[Perfect Paloma]);
		}
		else if(item_amount($item[Bottle of Whiskey]) > 0)
		{
			cli_execute("make " + $item[Perfect Old-Fashioned]);
		}
		break;
	case $stat[Moxie]:
		if(item_amount($item[Bottle of Tequila]) > 0)
		{
			cli_execute("make " + $item[Perfect Paloma]);
		}
		else if(item_amount($item[Bottle of Gin]) > 0)
		{
			cli_execute("make " + $item[Perfect Negroni]);
		}
		else if(item_amount($item[Bottle of Whiskey]) > 0)
		{
			cli_execute("make " + $item[Perfect Old-Fashioned]);
		}
		else if(item_amount($item[Bottle of Rum]) > 0)
		{
			cli_execute("make " + $item[Perfect Dark and Stormy]);
		}
		else if(item_amount($item[Bottle of Vodka]) > 0)
		{
			cli_execute("make " + $item[Perfect Cosmopolitan]);
		}
		else if(item_amount($item[Boxed Wine]) > 0)
		{
			cli_execute("make " + $item[Perfect Mimosa]);
		}
		break;
	}

	return !(starting == item_amount($item[Perfect Ice Cube]));
}


boolean tryCookies()
{
	string cookie = get_counters("Fortune Cookie", 0, 200);
	if(contains_text(cookie, "Fortune Cookie"))
	{
		return true;
	}
	if(my_fullness() < 12)
	{
		return false;
	}
	if(!canEat($item[Fortune Cookie]))
	{
		return false;
	}
	if((sl_my_path() == "Heavy Rains") && (get_property("sl_orchard") == "finished"))
	{
		return false;
	}
	while((fullness_limit() - my_fullness()) > 0)
	{
		buyUpTo(1, $item[Fortune Cookie]);
		if((item_amount($item[Mayoflex]) > 0) && (sl_get_campground() contains $item[Portable Mayo Clinic]))
		{
			use(1, $item[Mayoflex]);
		}
		buffMaintain($effect[Song of the Glorious Lunch], 10, 1, 1);
		slEat(1, $item[Fortune Cookie]);
		cookie = get_counters("Fortune Cookie", 0, 200);
		if(contains_text(cookie, "Fortune Cookie"))
		{
			return true;
		}
	}
	return false;
}

boolean tryPantsEat()
{
	if(fullness_left() > 0)
	{
		foreach it in $items[Tasty Tart, Deviled Egg, Actual Tapas, Cold Mashed Potatoes, Dinner Roll, Whole Turkey Leg, Can of Sardines, High-Calorie Sugar Substitute, Pat of Butter]
		{
			if(!canEat(it))
			{
				continue;
			}
			if((it == $item[Actual Tapas]) && (my_level() < 11))
			{
				continue;
			}

			if(item_amount(it) > 0)
			{
				cli_execute("refresh inv");
				if(item_amount(it) == 0)
				{
					print("Error, mafia thought you had " + it + " but you didn't....", "red");
					return false;
				}
				if((get_property("mayoInMouth") == "") && (sl_get_campground() contains $item[Portable Mayo Clinic]))
				{
					if((item_amount($item[Mayoflex]) == 0) && (my_meat() > 12000))
					{
						buy(1, $item[Mayoflex]);
					}
					if(item_amount($item[Mayoflex]) > 0)
					{
						use(1, $item[Mayoflex]);
					}
				}
				buffMaintain($effect[Song of the Glorious Lunch], 10, 1, 1);
				slEat(1, it);
				return true;
			}
		}
	}
	return false;
}

boolean canOde(item toDrink)
{
	if(in_tcrs())
	{
		return true;
	}
	if($items[Steel Margarita, 5-hour acrimony, beery blood, slap and slap again, used beer, shot of flower schnapps] contains toDrink)
	{
		return false;
	}

	return true;
}

boolean slDrink(int howMany, item toDrink)
{
	if((toDrink == $item[none]) || (howMany <= 0))
	{
		return false;
	}
	boolean isSpeakeasy = isSpeakeasyDrink(toDrink);
	if(isSpeakeasy && !canDrinkSpeakeasyDrink(toDrink))
	{
		return false;
	}
	if(item_amount(toDrink) < howMany && !isSpeakeasy)
	{
		return false;
	}
	if(!canDrink(toDrink))
	{
		return false;
	}

	int expectedInebriety = toDrink.inebriety * howMany;

	item it = equipped_item($slot[Acc3]);
	if((it != $item[Mafia Pinky Ring]) && (item_amount($item[Mafia Pinky Ring]) > 0) && ($items[Bucket of Wine, Psychotic Train Wine, Sacramento Wine, Stale Cheer Wine] contains toDrink) && can_equip($item[Mafia Pinky Ring]))
	{
		equip($slot[Acc3], $item[Mafia Pinky Ring]);
	}

	if(canOde(toDrink) && possessEquipment($item[Wrist-Boy]) && (my_meat() > 6500))
	{
		if((have_effect($effect[Drunk and Avuncular]) < expectedInebriety) && (item_amount($item[Drunk Uncles Holo-Record]) == 0))
		{
			buyUpTo(1, $item[Drunk Uncles Holo-Record]);
		}
		buffMaintain($effect[Drunk and Avuncular], 0, 1, expectedInebriety);
	}

	if(canOde(toDrink) && sl_have_skill($skill[The Ode to Booze]))
	{
		shrugAT($effect[Ode to Booze]);
		// get enough turns of ode
		while(acquireMP(mp_cost($skill[The Ode to Booze]), true) && buffMaintain($effect[Ode to Booze], mp_cost($skill[The Ode to Booze]), 1, expectedInebriety))
			/*do nothing, the loop condition is doing the work*/;
	}

	boolean retval = false;
	while(howMany > 0)
	{
		if(!isSpeakeasy)
		{
			retval = drink(1, toDrink);
		}
		else
		{
			retval = drinkSpeakeasyDrink(toDrink);
		}

		if(retval)
		{
			handleTracker(toDrink, "sl_drunken");
		}
		howMany = howMany - 1;
	}

	if(equipped_item($slot[Acc3]) != it)
	{
		equip($slot[Acc3], it);
	}

	return retval;
}

boolean slOverdrink(int howMany, item toOverdrink)
{
	if(!canDrink(toOverdrink))
	{
		return false;
	}
	return overdrink(howMany, toOverdrink);
}

string cafeFoodName(int id)
{
	if (id == daily_special().to_int())
	{
		return daily_special().to_string();
	}
	switch(id)
	{
	case -1: return "Peche a la Frog";
	case -2: return "As Jus Gezund Heit";
	case -3: return "Bouillabaise Coucher Avec Moi";
	default: abort("slDrinkCafe does not recognize item id: " + id);
	}
	return "";
}

string cafeDrinkName(int id)
{
	if (id == daily_special().to_int())
	{
		return daily_special().to_string();
	}
	switch(id)
	{
	case -1: return "Petite Porter";
	case -2: return "Scrawny Stout";
	case -3: return "Infinitesimal IPA";
	default: abort("slDrinkCafe does not recognize item id: " + id);
	}
	return "";
}

boolean slDrinkCafe(int howmany, int id)
{
	// Note that caller is responsible for calling Ode to Booze,
	// since we might be in TCRS and not know how many adventures
	// we'll get from the drink.
	if(!gnomads_available()) return false;

	string name = cafeDrinkName(id);
	for (int i=0; i<howmany; i++)
	{
		// TODO: What if we run out of meat?
		visit_url("cafe.php?cafeid=2");
		visit_url("cafe.php?pwd="+my_hash()+"&phash="+my_hash()+"&cafeid=2&whichitem="+id+"&action=CONSUME!");
		handleTracker(name, "sl_drunken");
	}
	return true;
}

boolean slEatCafe(int howmany, int id)
{
	if(!canadia_available()) return false;

	string name = cafeFoodName(id);
	for (int i=0; i<howmany; i++)
	{
		// TODO: What if we run out of meat?
		visit_url("cafe.php?cafeid=1");
		visit_url("cafe.php?pwd="+my_hash()+"&phash="+my_hash()+"&cafeid=2&whichitem="+id+"&action=CONSUME!");
		handleTracker(name, "sl_eaten");
	}
	return true;
}

boolean slChew(int howMany, item toChew)
{
	if(!canChew(toChew))
	{
		return false;
	}
	if(spleen_left() < toChew.spleen * howMany)
	{
		return false;
	}
	if(item_amount(toChew) < howMany)
	{
		return false;
	}

	boolean retval = chew(howMany, toChew);

	if(retval)
	{
		for(int i = 0; i < howMany; ++i)
		{
			handleTracker(toChew, "sl_chewed");
		}
	}

	return retval;
}

boolean slEat(int howMany, item toEat)
{
	return slEat(howMany, toEat, true);
}

boolean slEat(int howMany, item toEat, boolean silent)
{
	if((toEat == $item[none]) || (howMany <= 0))
	{
		return false;
	}
	if(item_amount(toEat) < howMany)
	{
		return false;
	}
	if(!canEat(toEat))
	{
		return false;
	}

	int expectedFullness = toEat.fullness * howMany;
	if(expectedFullness >= 15)
	{
		dealwithMilkOfMagnesium(true);
	}

	if(expectedFullness >= 10)
	{
		buffMaintain($effect[Got Milk], 0, 1, expectedFullness);
	}

	if(possessEquipment($item[Wrist-Boy]) && (my_meat() > 6500))
	{
		if((have_effect($effect[Record Hunger]) < expectedFullness) && (item_amount($item[The Pigs Holo-Record]) == 0))
		{
			buyUpTo(1, $item[The Pigs Holo-Record]);
		}
		buffMaintain($effect[Record Hunger], 0, 1, expectedFullness);
	}

	boolean retval = false;
	while(howMany > 0)
	{
		buffMaintain($effect[Song of the Glorious Lunch], 10, 1, toEat.fullness);
		if((sl_get_campground() contains $item[Portable Mayo Clinic]) && (my_meat() > 11000) && (get_property("mayoInMouth") == "") && is_unrestricted($item[Portable Mayo Clinic]))
		{
			buyUpTo(1, $item[Mayoflex], 1000);
			use(1, $item[Mayoflex]);
		}
		if(silent)
		{
			retval = eatsilent(1, toEat);
		}
		else
		{
			retval = eat(1, toEat);
		}
		if(retval)
		{
			handleTracker(toEat, "sl_eaten");
		}
		howMany = howMany - 1;
	}
	return retval;
}

boolean dealWithMilkOfMagnesium(boolean useAdv)
{
	if(in_tcrs())
	{
		return true;
	}

	if(item_amount($item[Milk Of Magnesium]) > 0)
	{
		return true;
	}
	if(fullness_left() == 0)
	{
		return false;
	}

	ovenHandle();
	if((item_amount($item[Glass Of Goat\'s Milk]) > 0) && have_skill($skill[Advanced Saucecrafting]))
	{
		if((item_amount($item[Scrumptious Reagent]) == 0) && (my_mp() >= mp_cost($skill[Advanced Saucecrafting])))
		{
			if(get_property("reagentSummons").to_int() == 0)
			{
				use_skill(1, $skill[Advanced Saucecrafting]);
			}
		}

		if(item_amount($item[Scrumptious Reagent]) > 0)
		{
			if(useAdv)
			{
				cli_execute("make " + $item[Milk Of Magnesium]);
			}
			else if((freeCrafts() > 0) && have_skill($skill[Rapid Prototyping]))
			{
				cli_execute("make " + $item[Milk Of Magnesium]);
			}
		}
	}
	pullXWhenHaveY($item[Milk Of Magnesium], 1, 0);
	return true;
}

boolean canDrink(item toDrink)
{
	if(!can_drink())
	{
		return false;
	}
	if(!sl_is_valid(toDrink))
	{
		return false;
	}
	if((sl_my_path() == "Nuclear Autumn") && (toDrink.inebriety != 1))
	{
		return false;
	}
	if((sl_my_path() == "Dark Gyffte") != ($items[vampagne, dusty bottle of blood, Red Russian, mulled blood, bottle of Sanguiovese] contains toDrink))
	{
		return false;
	}
	if(sl_my_path() == "KOLHS")
	{
		if(!($items[Bottle of Fruity &quot;Wine&quot;, Can of the Cheapest Beer, Single Swig of Vodka, Steel Margarita] contains toDrink))
		{
			return false;
		}
	}
	if(sl_my_path() == "License to Adventure")
	{
		item [int] martinis = bondDrinks();
		boolean found = false;
		foreach idx, it in martinis
		{
			if(it == toDrink)
			{
				found = true;
			}
		}
		if(!found)
		{
			return false;
		}
	}

	if(my_level() < toDrink.levelreq)
	{
		return false;
	}

	return true;
}

boolean canEat(item toEat)
{
	if(!can_eat())
	{
		return false;
	}
	if(!sl_is_valid(toEat))
	{
		return false;
	}
	if((sl_my_path() == "Nuclear Autumn") && (toEat.fullness != 1))
	{
		return false;
	}
	if((sl_my_path() == "Dark Gyffte") && (toEat == $item[magical sausage]))
	{
		// the one thing you can eat as Vampyre AND other classes
		return true;
	}
	if((sl_my_path() == "Dark Gyffte") != ($items[blood-soaked sponge cake, blood roll-up, blood snowcone, actual blood sausage, bloodstick] contains toEat))
	{
		return false;
	}
	if(sl_my_path() == "Zombie Slayer")
	{
		return ($items[crappy brain, decent brain, good brain, boss brain, hunter brain, brains casserole, fricasseed brains, steel lasagna] contains toEat);
	}

	if(my_level() < toEat.levelreq)
	{
		return false;
	}

	return true;
}

boolean canChew(item toChew)
{
	if(!sl_is_valid(toChew))
	{
		return false;
	}
	if(my_level() < toChew.levelreq)
	{
		return false;
	}

	return true;
}

void consumeStuff()
{
	// grind and eat any sausage that you can
	sl_sausageGrind(23 - get_property("_sausagesMade").to_int());
	sl_sausageEatEmUp();

	if (get_property("sl_limitConsume").to_boolean())
	{
		return;
	}

	if(tcrs_consumption() || ed_eatStuff() || bat_consumption())
	{
		return;
	}
	if(get_property("kingLiberated") != false)
	{
		return;
	}
	if(sl_my_path() == "Community Service")
	{
		cs_eat_spleen();
		return;
	}

	if (sl_beta() && !get_property("sl_legacyConsumeStuff").to_boolean())
	{
		sl_maximizedConsumeStuff();
		return;
	}
	else
	{
		// print("Using old hard-coded consumption strategies. 'set sl_legacyConsumeStuff=false' to use the knapsack-solver consumption strategy.", "red");
	}

	int mpForOde = mp_cost($skill[The Ode to Booze]);
	if(!sl_have_skill($skill[The Ode to Booze]))
	{
		mpForOde = 0;
	}

	if(!have_skill($skill[Advanced Saucecrafting]) && canEat($item[Pixel Lemon]))
	{
		if((fullness_left() >= 5) && (inebriety_left() >= 2) && is_unrestricted($item[Yellow Puck]))
		{
			if((item_amount($item[Yellow Pixel]) >= 10) && (item_amount($item[Pixel Lemon]) == 0))
			{
				cli_execute("make " + $item[Pixel Lemon]);
			}
			if(item_amount($item[Pixel Lemon]) > 0)
			{
				slEat(1, $item[Pixel Lemon]);
			}
		}
	}

	if((my_inebriety() <= 8) || (my_adventures() < 20) || hasSpookyravenLibraryKey() || (get_property("questM20Necklace") == "finished"))
	{
		if((inebriety_left() >= 3) && (my_mp() >= mpForOde) && (my_level() >= 5) && canDrink($item[Perfect Mimosa]))
		{
			makePerfectBooze();
			item booze = getAvailablePerfectBooze();
			if(booze != $item[none])
			{
				slDrink(1, booze);
			}
		}

		if((inebriety_left() >= 2) && (my_mp() < mpForOde) && (my_maxmp() > mpForOde))
		{
			boolean pixelCondition = false;
			boolean robinCondition = false;
			boolean witchessCondition = false;

			if(is_unrestricted($item[Yellow Puck]) && canDrink($item[Pixel Daiquiri]))
			{
				if((item_amount($item[Yellow Pixel]) >= 10) || (item_amount($item[Pixel Daiquiri]) > 0))
				{
					pixelCondition = true;
				}
			}
			if(is_unrestricted($item[Basking Robin]) && canDrink($item[Robin Nog]))
			{
				if(item_amount($item[Robin Nog]) > 0)
				{
					robinCondition = true;
				}
			}
			if(is_unrestricted($item[Witchess Set]) && canDrink($item[Sacramento Wine]))
			{
				if(item_amount($item[Sacramento Wine]) > 0)
				{
					witchessCondition = true;
				}
			}

			if(pixelCondition || robinCondition || witchessCondition)
			#if((item_amount($item[Yellow Pixel]) >= 10) || (item_amount($item[Pixel Daiquiri]) > 0) || (item_amount($item[Robin Nog]) > 0) || (item_amount($item[Sacramento Wine]) > 0))
			#if((item_amount($item[Yellow Pixel]) >= 10) || (item_amount($item[Pixel Daiquiri]) > 0) || (item_amount($item[Robin\'s Egg]) > 0) || (item_amount($item[Robin Nog]) > 0) || (item_amount($item[Sacramento Wine]) > 0)))
			{
				if(my_meat() > 10000)
				{
					while(my_mp() < mpForOde)
					{
						if(((my_class() == $class[Sauceror]) || (my_class() == $class[Pastamancer])) && guild_store_available() && (my_level() >= 6) && (my_meat() > npc_price($item[Magical Mystery Juice])))
						{
							buyUpTo(1, $item[Magical Mystery Juice]);
							use(1, $item[Magical Mystery Juice]);
						}
						else if(my_meat() > npc_price($item[Magical Mystery Juice]))
						{
							buyUpTo(1, $item[Doc Galaktik\'s Invigorating Tonic]);
							use(1, $item[Doc Galaktik\'s Invigorating Tonic]);
						}
					}
				}
			}
		}

		if(((my_inebriety() + item_amount($item[Sacramento Wine])) <= inebriety_limit()) && (my_mp() >= mpForOde) && is_unrestricted($item[Witchess Set]) && canDrink($item[Sacramento Wine]))
		{
			if(item_amount($item[Sacramento Wine]) > 0)
			{
				slDrink(min(item_amount($item[Sacramento Wine]), have_effect($effect[Ode to Booze])), $item[Sacramento Wine]);
			}
		}
		if((inebriety_left() >= 2) && (my_mp() >= mpForOde) && is_unrestricted($item[Yellow Puck]) && canDrink($item[Pixel Daiquiri]))
		{
			if((item_amount($item[Yellow Pixel]) >= 10) && (item_amount($item[Pixel Daiquiri]) == 0))
			{
				cli_execute("make " + $item[Pixel Daiquiri]);
			}
			if(item_amount($item[Pixel Daiquiri]) > 0)
			{
				slDrink(1, $item[Pixel Daiquiri]);
			}
		}
		if((inebriety_left() >= 2) && (my_mp() >= mpForOde) && is_unrestricted($item[Basking Robin]) && canDrink($item[Robin Nog]))
		{
			if((item_amount($item[Robin\'s Egg]) >= 10) && (item_amount($item[Robin Nog]) == 0) && (my_meat() >= npc_price($item[Fermenting Powder])) && isGeneralStoreAvailable())
			{
				cli_execute("make " + $item[Robin Nog]);
			}
			if(item_amount($item[Robin Nog]) > 0)
			{
				slDrink(1, $item[Robin Nog]);
			}
		}
	}

	if((my_inebriety() <= 6) || (my_adventures() < 20) || hasSpookyravenLibraryKey() || (get_property("questM20Necklace") == "finished"))
	{
		if((inebriety_left() >= 4) && (my_mp() < mpForOde) && (my_maxmp() > mpForOde) && canDrink($item[Hacked Gibson]))
		{
			if((item_amount($item[Hacked Gibson]) > 0) && (my_level() >= 4) && is_unrestricted($item[Source Terminal]))
			{
				if(my_meat() > 10000)
				{
					while(my_mp() < mpForOde)
					{
						if(((my_class() == $class[Sauceror]) || (my_class() == $class[Pastamancer])) && guild_store_available() && (my_level() >= 6) && (my_meat() > npc_price($item[Magical Mystery Juice])))
						{
							buyUpTo(1, $item[Magical Mystery Juice]);
							use(1, $item[Magical Mystery Juice]);
						}
						else if(my_meat() > npc_price($item[Magical Mystery Juice]))
						{
							buyUpTo(1, $item[Doc Galaktik\'s Invigorating Tonic]);
							use(1, $item[Doc Galaktik\'s Invigorating Tonic]);
						}
					}
				}
			}
		}

		if((inebriety_left() >= 4) && (my_mp() >= mpForOde) && (item_amount($item[Hacked Gibson]) > 0) && (my_level() >= 4) && is_unrestricted($item[Source Terminal]) && canDrink($item[Hacked Gibson]))
		{
			slDrink(1, $item[Hacked Gibson]);
		}
	}

	if((fullness_left() >= 4) && (my_level() >= 4) && is_unrestricted($item[Browser Cookie]) && canEat($item[Browser Cookie]))
	{
		int browserCookies = min(fullness_left()/4, item_amount($item[Browser Cookie]));
		slEat(browserCookies, $item[Browser Cookie]);
	}


	if(my_daycount() == 1)
	{
		if((my_spleen_use() == 0) && (item_amount($item[Grim Fairy Tale]) > 0))
		{
			slChew(1, $item[Grim Fairy Tale]);
		}

		if(!contains_text(get_counters("Fortune Cookie", 0, 200), "Fortune Cookie") && (my_turncount() < 70) && (fullness_left() > 0) && (my_meat() >= npc_price($item[Fortune Cookie])) && (item_amount($item[Deck of Every Card]) == 0) && (item_amount($item[Stone Wool]) < 2) && !(sl_get_clan_lounge() contains $item[Clan Speakeasy]))
		{
			buyUpTo(1, $item[Fortune Cookie], npc_price($item[Fortune Cookie]));
			slEat(1, $item[Fortune Cookie]);
		}

		//	Try to drink more on day 1 please!

		if((my_meat() > 400) && (item_amount($item[Handful of Smithereens]) == 3) && (get_property("sl_mosquito") == "finished") && (internalQuestStatus("questL03Rat") >= 0) && canDrink($item[Paint A Vulgar Pitcher]))
		{
			cli_execute("make 3 " + $item[Paint A Vulgar Pitcher]);
		}

		if((inebriety_left() >= 2) && (my_mp() >= mpForOde) && (item_amount($item[Agitated Turkey]) >= 2) && is_unrestricted($item[Fist Turkey Outline]) && canDrink($item[Agitated Turkey]))
		{
			slDrink(2, $item[Agitated Turkey]);
		}

		if((inebriety_left() >= 1) && (my_mp() >= mpForOde) && (item_amount($item[Cold One]) >= 1) && (my_level() >= 11) && canDrink($item[Cold One]))
		{
			slDrink(1, $item[Cold One]);
		}

		if((my_mp() > mpForOde) && (my_level() >= 3) && (item_amount($item[Paint a Vulgar Pitcher]) > 0) && ((my_inebriety() + 2) <= inebriety_limit()) && is_unrestricted($item[The Smith\'s Tome]) && canDrink($item[Paint A Vulgar Pitcher]))
		{
			slDrink(1, $item[Paint A Vulgar Pitcher]);
			if((item_amount($item[Paint A Vulgar Pitcher]) > 0) && ((my_inebriety() + 2) <= inebriety_limit()))
			{
				slDrink(1, $item[Paint A Vulgar Pitcher]);
			}
		}

		if((my_mp() > mpForOde) && is100FamiliarRun() && (my_inebriety() == 0) && (my_meat() >= 500) && (item_amount($item[Clan VIP Lounge Key]) > 0) && is_unrestricted($item[Clan Speakeasy]))
		{
			if(inebriety_left() >= 1)
			{
				slDrink(1, $item[Lucky Lindy]);
			}

			if((inebriety_left() >= 4) && canDrink($item[Ice Island Long Tea]))
			{
				pullXWhenHaveY($item[Ice Island Long Tea], 1, 0);
				if(item_amount($item[Ice Island Long Tea]) > 0)
				{
					slDrink(1, $item[Ice Island Long Tea]);
				}
			}
		}

		if((my_mp() > mpForOde) && is100FamiliarRun() && (my_inebriety() == 13) && (item_amount($item[Cold One]) > 0) && (my_level() >= 10) && canDrink($item[Cold One]))
		{
			slDrink(1, $item[Cold One]);
		}

		if((my_mp() > mpForOde) && (amountTurkeyBooze() >= 2) && (my_inebriety() == 0) && (my_meat() >= 500) && (item_amount($item[Clan VIP Lounge Key]) > 0) && is_unrestricted($item[Fist Turkey Outline]) && canDrink($item[Friendly Turkey]))
		{
			slDrink(1, $item[Lucky Lindy]);
			while((amountTurkeyBooze() > 0) && (my_inebriety() < 3) && (inebriety_left() > 0))
			{
				if((item_amount($item[Friendly Turkey]) > 0) && (inebriety_left() >= 1))
				{
					slDrink(1, $item[Friendly Turkey]);
				}
				else if((item_amount($item[Agitated Turkey]) > 0) && (inebriety_left() >= 1))
				{
					slDrink(1, $item[Agitated Turkey]);
				}
				else if((item_amount($item[Ambitious Turkey]) > 0) && (inebriety_left() >= 1))
				{
					slDrink(1, $item[Ambitious Turkey]);
				}
			}
		}

		if((my_mp() > mpForOde) && (turkeyBooze() >= 5) && (amountTurkeyBooze() >= 3) && (my_inebriety() < 6) && is_unrestricted($item[Fist Turkey Outline]) && canDrink($item[Friendly Turkey]))
		{
			while((amountTurkeyBooze() > 0) && (my_inebriety() < 6) && (inebriety_left() > 0))
			{
				if((item_amount($item[Friendly Turkey]) > 0) && (inebriety_left() >= 1))
				{
					slDrink(1, $item[Friendly Turkey]);
				}
				else if((item_amount($item[Agitated Turkey]) > 0) && (inebriety_left() >= 1))
				{
					slDrink(1, $item[Agitated Turkey]);
				}
				else if((item_amount($item[Ambitious Turkey]) > 0) && (inebriety_left() >= 1))
				{
					slDrink(1, $item[Ambitious Turkey]);
				}
			}
		}

		if((get_property("sl_ballroomsong") == "finished") && (inebriety_left() >= 2) && (get_property("_speakeasyDrinksDrunk").to_int() == 1) && (my_mp() >= (mpForOde+30)) && ((my_inebriety() + 2) <= inebriety_limit()) && !($classes[Avatar of Boris, Ed] contains my_class()))
		{
			if(item_amount($item[Clan VIP Lounge Key]) > 0)
			{
				slDrink(1, $item[Sockdollager]);
			}
			while(acquireHermitItem($item[Ten-leaf Clover]));
		}

		if((my_adventures() < 4) && (my_fullness() == 0) && (my_level() >= 7) && !in_hardcore() && can_eat())
		{
			dealWithMilkOfMagnesium(true);
			if((item_amount($item[Spaghetti Breakfast]) > 0) && (fullness_left() >= 1) && canEat($item[Spaghetti Breakfast]))
			{
				buffMaintain($effect[Got Milk], 0, 1, 1);
				buffMaintain($effect[Song of the Glorious Lunch], 10, 1, 1);
				slEat(1, $item[Spaghetti Breakfast]);
			}
			if((fullness_left() >= 10) && canEat(whatHiMein()))
			{
				pullXWhenHaveY(whatHiMein(), 2, 0);
			}
			if((item_amount(whatHiMein()) >= 2) && (fullness_left() >= 10) && canEat(whatHiMein()))
			{
				buffMaintain($effect[Song of the Glorious Lunch], 10, 1, 1);
				buffMaintain($effect[Got Milk], 0, 1, 1);
				slEat(2, whatHiMein());
			}
			if((item_amount($item[Digital Key Lime Pie]) > 0) && (fullness_left() >= 4) && canEat($item[Digital Key Lime Pie]))
			{
				buffMaintain($effect[Song of the Glorious Lunch], 10, 1, 1);
				buffMaintain($effect[Got Milk], 0, 1, 1);
				slEat(1, $item[Digital Key Lime Pie]);
				tryPantsEat();
			}
			else
			{
				if((fullness_left() == 5) && canEat(whatHiMein()))
				{
					pullXWhenHaveY(whatHiMein(), 1, 0);
					if(item_amount(whatHiMein()) > 0)
					{
						buffMaintain($effect[Song of the Glorious Lunch], 10, 1, 1);
						buffMaintain($effect[Got Milk], 0, 1, 1);
						slEat(1, whatHiMein());
					}
				}
				else if((fullness_left() >= 4) && canEat($item[Digital Key Lime Pie]))
				{
					pullXWhenHaveY($item[Digital Key Lime Pie], 1, 0);
					if(item_amount($item[Digital Key Lime Pie]) > 0)
					{
						buffMaintain($effect[Got Milk], 0, 1, 1);
						buffMaintain($effect[Song of the Glorious Lunch], 10, 1, 1);
						slEat(1, $item[Digital Key Lime Pie]);
					}
				}
			}
		}

		if(in_hardcore() && isGuildClass() && have_skill($skill[Pastamastery]))
		{
			int canEat = (fullness_limit() - my_fullness()) / 5;
			boolean[item] toEat;
			boolean[item] toPrep;

			if(have_skill($skill[Advanced Saucecrafting]))
			{
				toPrep = $items[Bubblin\' Crude, Ectoplasmic Orbs, Salacious Crumbs, Pestopiary, Goat Cheese];
				toEat = $items[Fettucini Inconnu, Crudles, Spaghetti with Ghost Balls, Agnolotti Arboli, Suggestive Strozzapreti];
			}
			else //Pastamastery was checked before we entered this block.
			{
				toPrep = $items[Bubblin\' Crude, Ectoplasmic Orbs, Salacious Crumbs, Pestopiary];
				toEat = $items[Crudles, Spaghetti with Ghost Balls, Agnolotti Arboli, Suggestive Strozzapreti];
			}

			int haveToEat = 0;
			foreach it in toEat
			{
				if(canEat(it))
				{
					haveToEat = haveToEat + item_amount(it);
				}
			}

			int haveToPrep = 0;
			foreach it in toPrep
			{
				if(is_unrestricted(it))
				{
					haveToPrep = haveToPrep + item_amount(it);
				}
			}

			if((canEat > 0) && ((haveToEat + haveToPrep) > canEat))
			{
				if(haveToEat < canEat)
				{
					ovenHandle();
				}
				while(haveToEat < canEat)
				{
					haveToEat = haveToEat + 1;
					if((item_amount($item[Bubblin\' Crude]) > 0) && (item_amount($item[Dry Noodles]) > 0))
					{
						slCraft("cook", 1, $item[Dry Noodles], $item[Bubblin\' Crude]);
					}
					else if((item_amount($item[Goat Cheese]) > 0) && (item_amount($item[Scrumptious Reagent]) > 0) && (item_amount($item[Dry Noodles]) > 0))
					{
						slCraft("cook", 1, $item[Goat Cheese], $item[Scrumptious Reagent]);
						slCraft("cook", 1, $item[Dry Noodles], $item[Fancy Schmancy Cheese Sauce]);
					}
					else if((item_amount($item[Ectoplasmic Orbs]) > 0) && (item_amount($item[Dry Noodles]) > 0))
					{
						slCraft("cook", 1, $item[Dry Noodles], $item[Ectoplasmic Orbs]);
					}
					else if((item_amount($item[Pestopiary]) > 0) && (item_amount($item[Dry Noodles]) > 0))
					{
						slCraft("cook", 1, $item[Dry Noodles], $item[Pestopiary]);
					}
					else if((item_amount($item[Salacious Crumbs]) > 0) && (item_amount($item[Dry Noodles]) > 0))
					{
						slCraft("cook", 1, $item[Dry Noodles], $item[Salacious Crumbs]);
					}
				}
				dealWithMilkOfMagnesium(!in_hardcore());
				foreach it in toEat
				{
					while((canEat > 0) && (item_amount(it) > 0) && (fullness_left() >= 5) && canEat(it))
					{
						buffMaintain($effect[Got Milk], 0, 1, 1);
						buffMaintain($effect[Song of the Glorious Lunch], 10, 1, 1);
						slEat(1, it);
						canEat = canEat - 1;
					}
				}
			}
		}

		if((my_adventures() < 4) && (fullness_left() >= 12) && (my_level() >= 6) && (item_amount($item[Boris\'s Key Lime Pie]) > 0) && (item_amount($item[Jarlsberg\'s Key Lime Pie]) > 0) && (item_amount($item[Sneaky Pete\'s Key Lime Pie]) > 0) && !in_hardcore() && canEat($item[Boris\'s Key Lime Pie]))
		{
			dealWithMilkOfMagnesium(true);
			buffMaintain($effect[Got Milk], 0, 1, 1);
			buffMaintain($effect[Song of the Glorious Lunch], 10, 1, 1);
			slEat(1, $item[Boris\'s Key Lime Pie]);
			slEat(1, $item[Jarlsberg\'s Key Lime Pie]);
			slEat(1, $item[Sneaky Pete\'s Key Lime Pie]);
			tryPantsEat();
			tryPantsEat();
			tryPantsEat();
		}

		if((fullness_limit() > 15) && (fullness_left() > 0))
		{
			tryCookies();
			if((my_adventures() < 5) && (spleen_left() <= 3) && (my_inebriety() >= 14))
			{
				tryPantsEat();
			}
		}

		if((my_spleen_use() == 4) && (spleen_left() == 11) && (item_amount($item[carrot nose]) > 0))
		{
			use(1, $item[carrot nose]);
			slChew(1, $item[carrot juice]);
		}

		if(in_hardcore())
		{
			while((spleen_left() >= 4) && (item_amount($item[Unconscious Collective Dream Jar]) > 0))
			{
				slChew(1, $item[Unconscious Collective Dream Jar]);
			}
			while((spleen_left() >= 4) && (item_amount($item[Powdered Gold]) > 0))
			{
				slChew(1, $item[Powdered Gold]);
			}
			while((spleen_left() >= 4) && (item_amount($item[Grim Fairy Tale]) > 0))
			{
				slChew(1, $item[Grim Fairy Tale]);
			}
		}
	}
	else if(my_daycount() == 2)
	{
		if((my_level() >= 7) && (my_fullness() == 0) && ((my_adventures() < 10) || (get_counters("Fortune Cookie", 0, 5) == "Fortune Cookie") || (get_counters("Fortune Cookie", 0, 200) != "Fortune Cookie") || (get_property("middleChamberUnlock").to_boolean())) && !in_hardcore())
		{
			dealWithMilkOfMagnesium(true);

			if(towerKeyCount() == 3)
			{
				if((item_amount(whatHiMein()) >= 3) && (fullness_left() >= 15) && canEat(whatHiMein()))
				{
					buffMaintain($effect[Song of the Glorious Lunch], 10, 1, 1);
					buffMaintain($effect[Got Milk], 0, 1, 1);
					slEat(3, whatHiMein());
				}
			}
			if(get_property("sl_useCubeling").to_boolean())
			{
				int count = towerKeyCount();
				if(get_property("sl_phatloot").to_int() < my_daycount())
				{
					count = count + 1;
				}
				if(count >= 2)
				{
					if((item_amount($item[Spaghetti Breakfast]) > 0) && (fullness_left() > 0) && canEat($item[Spaghetti Breakfast]))
					{
						buffMaintain($effect[Song of the Glorious Lunch], 10, 1, 1);
						buffMaintain($effect[Got Milk], 0, 1, 1);
						if((item_amount($item[Mayoflex]) > 0) && (sl_get_campground() contains $item[Portable Mayo Clinic]))
						{
							use(1, $item[Mayoflex]);
						}
						slEat(1, $item[Spaghetti Breakfast]);
					}
					if((fullness_left() >= 4) && canEat($item[Boris\'s Key Lime Pie]))
					{
						pullXWhenHaveY($item[Boris\'s Key Lime Pie], 1, 0);
					}
					if((item_amount($item[Boris\'s Key Lime Pie]) > 0) && (fullness_left() >= 4) && canEat($item[Boris\'s Key Lime Pie]))
					{
						buffMaintain($effect[Song of the Glorious Lunch], 10, 1, 1);
						buffMaintain($effect[Got Milk], 0, 1, 1);
						if((item_amount($item[Mayoflex]) > 0) && (sl_get_campground() contains $item[Portable Mayo Clinic]))
						{
							use(1, $item[Mayoflex]);
						}
						slEat(1, $item[Boris\'s Key Lime Pie]);
					}
					if((fullness_left() >= 10) && canEat(whatHiMein()))
					{
						pullXWhenHaveY(whatHiMein(), 2, 0);
					}
					if((item_amount(whatHiMein()) > 0) && (fullness_left() >= 5) && canEat(whatHiMein()))
					{
						buffMaintain($effect[Song of the Glorious Lunch], 10, 1, 1);
						buffMaintain($effect[Got Milk], 0, 1, 1);
						if((item_amount($item[Mayoflex]) > 0) && (sl_get_campground() contains $item[Portable Mayo Clinic]))
						{
							use(1, $item[Mayoflex]);
						}
						slEat(1, whatHiMein());
					}
					if((item_amount(whatHiMein()) > 0) && (fullness_left() >= 5) && canEat(whatHiMein()))
					{
						buffMaintain($effect[Song of the Glorious Lunch], 10, 1, 1);
						buffMaintain($effect[Got Milk], 0, 1, 1);
						if((item_amount($item[Mayoflex]) > 0) && (sl_get_campground() contains $item[Portable Mayo Clinic]))
						{
							use(1, $item[Mayoflex]);
						}
						slEat(1, whatHiMein());
					}
				}
			}
			else if(!get_property("sl_useCubeling").to_boolean())
			{
				if(((item_amount($item[Boris\'s Key Lime Pie]) > 0) || (item_amount($item[Jarlsberg\'s Key Lime Pie]) > 0) || (item_amount($item[Sneaky Pete\'s Key Lime Pie]) > 0)) && (fullness_left() >= 4) && canEat($item[Boris\'s Key Lime Pie]))
				{
					buffMaintain($effect[Song of the Glorious Lunch], 10, 1, 1);
					buffMaintain($effect[Got Milk], 0, 1, 1);
				}
				if((item_amount($item[Boris\'s Key Lime Pie]) > 0) && (fullness_left() >= 4) && canEat($item[Boris\'s Key Lime Pie]))
				{
					slEat(1, $item[Boris\'s Key Lime Pie]);
				}
				if((item_amount($item[Jarlsberg\'s Key Lime Pie]) > 0) && (fullness_left() >= 4) && canEat($item[Jarlsberg\'s Key Lime Pie]))
				{
					slEat(1, $item[Jarlsberg\'s Key Lime Pie]);
				}
				if((item_amount($item[Sneaky Pete\'s Key Lime Pie]) > 0) && (fullness_left() >= 4) && canEat($item[Sneaky Pete\'s Key Lime Pie]))
				{
					slEat(1, $item[Sneaky Pete\'s Key Lime Pie]);
				}
				#cli_execute("eat 1 video games hot dog");
				if(fullness_left() > 0)
				{
					tryPantsEat();
					tryPantsEat();
					tryPantsEat();
				}
			}
		}

		if(in_hardcore() && isGuildClass() && have_skill($skill[Pastamastery]))
		{
			int canEat = fullness_left() / 5;
			boolean[item] toEat;
			boolean[item] toPrep;

			if(have_skill($skill[Advanced Saucecrafting]))
			{
				toPrep = $items[Bubblin\' Crude, Ectoplasmic Orbs, Salacious Crumbs, Pestopiary, Goat Cheese];
				toEat = $items[Fettucini Inconnu, Crudles, Spaghetti with Ghost Balls, Agnolotti Arboli, Suggestive Strozzapreti];
			}
			else //Pastamastery was checked before we entered this block.
			{
				toPrep = $items[Bubblin\' Crude, Ectoplasmic Orbs, Salacious Crumbs, Pestopiary];
				toEat = $items[Crudles, Spaghetti with Ghost Balls, Agnolotti Arboli, Suggestive Strozzapreti];
			}

			int haveToEat = 0;
			foreach it in toEat
			{
				haveToEat = haveToEat + item_amount(it);
			}

			int haveToPrep = 0;
			foreach it in toPrep
			{
				haveToPrep = haveToPrep + item_amount(it);
			}

			if((canEat > 0) && ((haveToEat + haveToPrep) > canEat))
			{
				if(haveToEat < canEat)
				{
					ovenHandle();
				}
				while(haveToEat < canEat)
				{
					haveToEat = haveToEat + 1;
					if((item_amount($item[Bubblin\' Crude]) > 0) && (item_amount($item[Dry Noodles]) > 0))
					{
						slCraft("cook", 1, $item[Dry Noodles], $item[Bubblin\' Crude]);
					}
					else if((item_amount($item[Goat Cheese]) > 0) && (item_amount($item[Scrumptious Reagent]) > 0) && (item_amount($item[Dry Noodles]) > 0))
					{
						slCraft("cook", 1, $item[Goat Cheese], $item[Scrumptious Reagent]);
						slCraft("cook", 1, $item[Dry Noodles], $item[Fancy Schmancy Cheese Sauce]);
					}
					else if((item_amount($item[Ectoplasmic Orbs]) > 0) && (item_amount($item[Dry Noodles]) > 0))
					{
						slCraft("cook", 1, $item[Dry Noodles], $item[Ectoplasmic Orbs]);
					}
					else if((item_amount($item[Pestopiary]) > 0) && (item_amount($item[Dry Noodles]) > 0))
					{
						slCraft("cook", 1, $item[Dry Noodles], $item[Pestopiary]);
					}
					else if((item_amount($item[Salacious Crumbs]) > 0) && (item_amount($item[Dry Noodles]) > 0))
					{
						slCraft("cook", 1, $item[Dry Noodles], $item[Salacious Crumbs]);
					}
				}
				dealWithMilkOfMagnesium(true);
				foreach it in toEat
				{
					while((canEat > 0) && (item_amount(it) > 0) && (fullness_left() >= 5) && canEat(it))
					{
						buffMaintain($effect[Song of the Glorious Lunch], 10, 1, 1);
						buffMaintain($effect[Got Milk], 0, 1, 1);
						slEat(1, it);
						canEat = canEat - 1;
					}
				}
			}
		}

		if((fullness_limit() >= 15) && (fullness_left() > 0))
		{
			tryCookies();
			if((my_adventures() < 5) && (spleen_left() == 0) && (my_inebriety() >= 14))
			{
				tryPantsEat();
			}
		}

		if((my_inebriety() == 0) && (my_mp() >= mpForOde) && (my_meat() > 300) && (item_amount($item[Handful of Smithereens]) >= 2) && (internalQuestStatus("questL03Rat") >= 0) && canDrink($item[Paint A Vulgar Pitcher]))
		{
			cli_execute("make 2 " + $item[Paint A Vulgar Pitcher]);
			slDrink(2, $item[Paint A Vulgar Pitcher]);
		}

		if((my_inebriety() == 4) && (my_mp() >= mpForOde) && (my_meat() > 150) && (item_amount($item[Handful of Smithereens]) >= 1) && (internalQuestStatus("questL03Rat") >= 0) && canDrink($item[Paint A Vulgar Pitcher]))
		{
			cli_execute("make 1 " + $item[Paint A Vulgar Pitcher]);
			slDrink(1, $item[Paint A Vulgar Pitcher]);
		}

		if((inebriety_left() >= 5) && (my_adventures() < 10) && (my_meat() > 150) && (my_mp() >= mpForOde) && (sl_my_path() != "KOLHS") && (sl_my_path() != "Nuclear Autumn"))
		{
			if(((item_amount($item[Handful Of Smithereens]) > 0) && (internalQuestStatus("questL03Rat") >= 0)) || ((get_property("_speakeasyDrinksDrunk").to_int() < 3) && is_unrestricted($item[Clan Speakeasy]) && (item_amount($item[Clan VIP Lounge Key]) > 0)))
			{
				if((item_amount($item[Handful Of Smithereens]) > 0) && canDrink($item[Paint A Vulgar Pitcher]))
				{
					cli_execute("make 1 " + $item[Paint A Vulgar Pitcher]);
					slDrink(1, $item[Paint A Vulgar Pitcher]);
				}
				else if((my_meat() > 35000) && is_unrestricted($item[Clan Speakeasy]) && (item_amount($item[Clan VIP Lounge Key]) > 0))
				{
					slDrink(1, $item[Flivver]);
				}
			}
		}

		if(in_hardcore() && (my_mp() > mpForOde) && (item_amount($item[Pixel Daiquiri]) > 0) && (inebriety_left() >= 2) && is_unrestricted($item[Yellow Puck]) && canDrink($item[Pixel Daiquiri]))
		{
			slDrink(1, $item[Pixel Daiquiri]);
		}
		if(in_hardcore() && (my_mp() > mpForOde) && (item_amount($item[Dinsey Whinskey]) > 0) && (inebriety_left() >= 2) && is_unrestricted($item[Airplane Charter: Dinseylandfill]) && canDrink($item[Dinsey Whinskey]))
		{
			slDrink(1, $item[Dinsey Whinskey]);
		}

		if((my_level() >= 11) && (my_mp() > mpForOde) && (item_amount($item[Cold One]) > 1) && (inebriety_left() >= 2) && canDrink($item[Cold One]))
		{
			slDrink(2, $item[Cold One]);
		}

		if((my_inebriety() >= 6) && (my_inebriety() <= 11) && (get_property("sl_orchard") == "finished") && (my_mp() >= mpForOde) && is_unrestricted($item[Fist Turkey Outline]))
		{
			if((get_property("sl_nuns") != "finished") && (get_property("sl_nuns") != "done") && (get_property("currentNunneryMeat").to_int() == 0))
			{
				if((item_amount($item[Ambitious Turkey]) > 0) && canDrink($item[Ambitious Turkey]))
				{
					slDrink(1, $item[Ambitious Turkey]);
				}
			}
		}

		if((sl_my_path() == "Picky") && (my_mp() > mpForOde) && (my_meat() > 150) && (item_amount($item[Paint A Vulgar Pitcher]) > 0) && ((my_inebriety() + 2) <= inebriety_limit()) && canDrink($item[Paint A Vulgar Pitcher]))
		{
			slDrink(1, $item[Paint A Vulgar Pitcher]);
		}


		if((sl_my_path() == "Picky") && (my_mp() > mpForOde) && (my_meat() > 150) && (item_amount($item[Ambitious Turkey]) > 0) && ((my_inebriety() + 1) <= inebriety_limit()) && canDrink($item[Ambitious Turkey]))
		{
			slDrink(1, $item[Ambitious Turkey]);
		}

		if((sl_my_path() == "Picky") && (my_mp() > mpForOde) && (inebriety_left() > 0) && (my_meat() > 500) && (get_property("_speakeasyDrinksDrunk").to_int() < 3) && (item_amount($item[Clan VIP Lounge Key]) > 0))
		{
			# We could check for good drinks here but I don't know what would be good checks
			int canDrink = inebriety_left();
			#Consider Ish Kabibble for A-Boo Peak (2)

			item toDrink = $item[none];
			if(canDrink >= 2)
			{
				toDrink = $item[Bee\'s Knees];
			}
			else if(canDrink >= 1)
			{
				toDrink = $item[glass of &quot;milk&quot;];
			}

			if(toDrink != $item[none])
			{
				slDrink(1, toDrink);
			}
		}

/*****	This section needs to merge into a "Standard equivalent"		*****/
		if((sl_my_path() == "Standard") && (my_mp() >= mpForOde) && (my_meat() > 150) && (item_amount($item[Paint A Vulgar Pitcher]) > 0) && ((my_inebriety() + 2) <= inebriety_limit()) && is_unrestricted($item[The Smith\'s Tome]) && canDrink($item[Paint A Vulgar Pitcher]))
		{
			slDrink(1, $item[Paint A Vulgar Pitcher]);
		}


		if((sl_my_path() == "Standard") && (my_mp() >= mpForOde) && (item_amount($item[Ambitious Turkey]) > 0) && ((my_inebriety() + 1) <= inebriety_limit()) && is_unrestricted($item[Fist Turkey Outline]) && canDrink($item[Ambitious Turkey]))
		{
			slDrink(1, $item[Ambitious Turkey]);
		}

		if((sl_my_path() == "Standard") && (my_mp() >= mpForOde) && (my_inebriety() <= inebriety_limit()) && (my_meat() > 500) && (get_property("_speakeasyDrinksDrunk").to_int() < 3))
		{
			# We could check for good drinks here but I don't know what would be good checks
#			int canDrink = inebriety_limit() - my_inebriety();

			#Consider Ish Kabibble for A-Boo Peak (2)
#			visit_url("clan_viplounge.php?action=speakeasy");

			#item toDrink = $item[none];
#			string toDrink = "";
#			if(canDrink >= 2)
#			{
#				toDrink = "Bee's Knees";
#			}
#			else if(canDrink >= 1)
#			{
#				toDrink = "glass of \"milk\"";
#			}

			#if(toDrink != $item[none])
#			if(toDrink != "")
#			{
#				shrugAT($effect[Ode to Booze]);
#				buffMaintain($effect[Ode to Booze], 50, 1, 4);
#				cli_execute("drink 1 " + toDrink);
#				print("drink 1 " + toDrink);
#			}
		}


/*****	End of Standard equivalent secton								*****/
	}
	else if(my_daycount() == 3)
	{
		if((my_level() >= 7) && (my_fullness() == 0) && (my_adventures() < 10) && canEat($item[Star Key Lime Pie]))
		{
			dealWithMilkOfMagnesium(true);

			if((item_amount($item[Star Key Lime Pie]) >= 3) && (fullness_left() >= 12) && canEat($item[Star Key Lime Pie]))
			{
				buffMaintain($effect[Song of the Glorious Lunch], 10, 1, 1);
				buffMaintain($effect[Got Milk], 0, 1, 1);
				slEat(3, $item[Star Key Lime Pie]);
				tryPantsEat();
				tryPantsEat();
				tryPantsEat();
			}
			else
			{
				if((fullness_left() >= 15) && canEat(whatHiMein()))
				{
					pullXWhenHaveY(whatHiMein(), 3, 0);
				}
				if((item_amount(whatHiMein()) >= 3) && (fullness_left() >= 15) && canEat(whatHiMein()))
				{
					buffMaintain($effect[Song of the Glorious Lunch], 10, 1, 1);
					buffMaintain($effect[Got Milk], 0, 1, 1);
					slEat(3, whatHiMein());
				}
			}
		}

		if((item_amount($item[Handful Of Smithereens]) > 0) && (my_meat() > 300) && canDrink($item[Paint A Vulgar Pitcher]) && (internalQuestStatus("questL03Rat") >= 0))
		{
			cli_execute("make " + $item[Paint A Vulgar Pitcher]);
		}

		if((sl_my_path() == "Picky") && (my_mp() > mpForOde) && (item_amount($item[Paint A Vulgar Pitcher]) > 0) && ((my_inebriety() + 2) <= inebriety_limit()) && canDrink($item[Paint A Vulgar Pitcher]))
		{
			slDrink(1, $item[Paint A Vulgar Pitcher]);
		}

		if((sl_my_path() == "Picky") && (my_mp() > mpForOde) && (item_amount($item[Ambitious Turkey]) > 0) && ((my_inebriety() + 1) <= inebriety_limit()) && canDrink($item[Ambitious Turkey]))
		{
			slDrink(1, $item[Ambitious Turkey]);
		}
	}
}

boolean loadConsumables(string _type, item[int] item_backmap, int[int] cafe_backmap, float[int] adv, int[int] space)
{
	// Just in case!
	if(sl_my_path() == "Dark Gyffte")
	{
		abort("We shouldn't be calling loadConsumables() in Dark Gyffte. Please report this.");
	}

	// type is "eat" or "drink"
	int EAT   = 3;
	int DRINK = 5;
	int type  = 0;
	if (_type == "eat")   type = EAT;
	else if (_type == "drink") type = DRINK;
	else return false;

	boolean canConsume(item it)
	{
		return type == EAT ? canEat(it) : canDrink(it);
	}

	int organLeft()
	{
		return type == EAT ? fullness_left() : inebriety_left();
	}

	int organCost(item it)
	{
		return type == EAT ? it.fullness : it.inebriety;
	}

	int[item] small_owned;
	int[item] buyables;
	int[item] large_owned;
	int[item] craftables;

	foreach it in $items[]
	{
		if (canConsume(it) && (organCost(it) > 0) && is_unrestricted(it) && historical_price(it) <= 20000)
		{
			if((it == $item[astral pilsner] || it == $item[Cold One]) && my_level() < 11) continue;
			if((it == $item[astral hot dog] || it == $item[Spaghetti Breakfast]) && my_level() < 11) continue;

			int howmany = 1 + organLeft()/organCost(it);
			if (item_amount(it) > 0 && organCost(it) <= 5)
			{
				small_owned[it] = min(max(item_amount(it) - sl_reserveAmount(it), 0), howmany);
			}
			if (npc_price(it) > 0)
			{
				howmany = min(howmany, my_meat() / npc_price(it));
				buyables[it] = min(howmany, my_meat() / npc_price(it));
			}
			else if (buy_price($coinmaster[hermit], it) > 0)
			{
				buyables[it] += min(howmany, my_meat() / 500);
			}
			if (item_amount(it) > 0 && organCost(it) > 5)
			{
				large_owned[it] = min(max(item_amount(it) - sl_reserveAmount(it), 0), howmany);
			}
			if (creatable_amount(it) > 0)
			{
				howmany = min(howmany, max(0, creatable_amount(it) - sl_reserveCraftAmount(it)));
				craftables[it] = howmany;
			}
		}
	}

	void add(item it, boolean crafting, int howmany)
	{
		for (int i = 0; i < howmany; i++)
		{
			int n = count(space);
			space[n] = organCost(it);
			adv[n] = expectedAdventuresFrom(it);
			if (type == EAT && is_unrestricted($item[special seasoning]))
			{
				adv[n] += min(1.0, item_amount($item[special seasoning]).to_float() * it.fullness / fullness_left());
			}
			if (crafting)
			{
				int turns_to_craft = creatable_turns(it, i + 1, false) - creatable_turns(it, i, false);
				adv[n] -= turns_to_craft;
			}
			item_backmap[n] = it;
		}
	}

	foreach it, howmany in small_owned
	{
		add(it, false, howmany);
	}
	foreach it, howmany in buyables
	{
		add(it, false, howmany);
	}
	foreach it, howmany in large_owned
	{
		add(it, false, howmany);
	}
	foreach it, howmany in craftables
	{
		add(it, true, howmany);
	}

	// Now, to load cafe consumables. This has some TCRS-specific code.

	if(type == DRINK && !gnomads_available()) return false;
	if(type == EAT && !canadia_available()) return false;

	// Add daily special
	if (daily_special() != $item[none] && canConsume(daily_special()))
	{
		int daily_special_limit = 1 + min(my_meat()/(3*min(35, autosell_price(daily_special()))), organLeft()/organCost(daily_special()));
		for (int i=0; i < daily_special_limit; i++)
		{
			int n = count(space);
			space[n] = organCost(daily_special());
			adv[n] = expectedAdventuresFrom(daily_special());
			cafe_backmap[n] = daily_special().to_int();
		}
	}

	if(!in_tcrs()) 
	{
		// write in hard-coded adventure values for IPA, the best one
		if(type == DRINK)
		{
			// Gnomish Microbrewery has a single best drink
			int limit = 1 + min(my_meat()/100, inebriety_left()/3);
			for (int i=0; i < limit; i++)
			{
				int n = count(space);
				space[n] = 3;
				adv[n] = 11.0/3.0;
				cafe_backmap[n] = -3;
			}
		}
		if(type == EAT)
		{
			// Chez Snootee does not have a single best food

			// Peche a la Frog
			int limit = 1 + min(my_meat()/50, fullness_left()/3);
			for (int i=0; i < limit; i++)
			{
				int n = count(space);
				space[n] = 3;
				adv[n] = 3.5;
				cafe_backmap[n] = -1;
			}

			// As Jus Gezund Heit
			limit = 1 + min(my_meat()/75, fullness_left()/4);
			for (int i=0; i < limit; i++)
			{
				int n = count(space);
				space[n] = 4;
				adv[n] = 5.0;
				cafe_backmap[n] = -2;
			}

			// As Jus Gezund Heit
			limit = 1 + min(my_meat()/100, fullness_left()/4);
			for (int i=0; i < limit; i++)
			{
				int n = count(space);
				space[n] = 5;
				adv[n] = 7.0;
				cafe_backmap[n] = -3;
			}
		}
		return true;
	}

	record _CAFE_CONSUMABLE_TYPE {
		string name;
		int space;
		string quality;
	};

	_CAFE_CONSUMABLE_TYPE [int] cafe_stuff;
	string filename = "";
	if (type == DRINK)
		filename = "TCRS_" + my_class().to_string().replace_string(" ", "_") + "_" + my_sign() + "_cafe_booze.txt";
	else if (type == EAT)
		filename = "TCRS_" + my_class().to_string().replace_string(" ", "_") + "_" + my_sign() + "_cafe_food.txt";

	print("Loading " + filename, "blue");
	if(!file_to_map(filename, cafe_stuff))
	{
		print("Something went wrong while trying to load " + filename + ". Maybe run 'tcrs load'?", "red");
		abort();
	}
	foreach i, r in cafe_stuff
	{
		// Always-available cafe items have item ids -1, -2, -3
		if (i >= -3 && r.space > 0)
		{
			int limit = 1 + min(my_meat()/100, organLeft()/r.space);
			for (int j=0; j<limit; j++)
			{
				int n = count(space);
				space[n] = r.space;
				adv[n] = r.space * tcrs_expectedAdvPerFill(r.quality);
				cafe_backmap[n] = i;
			}
		}
	}
	return true;
}

void sl_autoDrinkNightcap(boolean simulate)
{
	int[int] inebriety;
	float[int] adv;
	item[int] item_backmap;
	int[int] cafe_backmap;

	loadConsumables("drink", item_backmap, cafe_backmap, adv, inebriety);

	boolean have_ode = sl_have_skill($skill[The Ode to Booze]);
	float advs_from(int i)
	{
		float ret = adv[i];
		if (have_ode) ret += inebriety[i];
		return ret;
	}

	int best = 0;
	int n = count(item_backmap);
	for (int i=1; i < n; i++)
	{
		if (advs_from(i) > advs_from(best)) best = i;
	}

	string name = (cafe_backmap contains best) ? cafeDrinkName(cafe_backmap[best]) : item_backmap[best];
	print("Nightcap is a " + name + " for " + advs_from(best) + " adventures.");

	if (simulate) return;

	if (item_backmap contains best)
	{
		slDrink(1, item_backmap[best]);
	}
	else
	{
		buffMaintain($effect[Ode to Booze], 20, 1, inebriety[best]);
		slDrinkCafe(1, cafe_backmap[best]);
	}
}

boolean sl_autoDrinkOne(boolean simulate)
{
	if (inebriety_left() == 0) return false;

	int[int] inebriety;
	float[int] adv;

	int [int] cafe_backmap;
	item[int] item_backmap;
	loadConsumables("drink", item_backmap, cafe_backmap, adv, inebriety);

	int[item] normal_drinks;
	int[int] cafe_drinks;

	float best_adv_per_drunk = 0.0;
	int best_index = -1;
	int n = count(inebriety);
	for (int i=0; i<n; i++)
	{
		float tentative_adv_per_drunk = adv[i]/inebriety[i];
		if (tentative_adv_per_drunk > best_adv_per_drunk)
		{
			best_adv_per_drunk = tentative_adv_per_drunk;
			best_index = i;
		}
	}


	if(!simulate)
	{
		if (cafe_backmap contains best_index)
		{
			print("Drinking from the cafe...", "blue");
			buffMaintain($effect[Ode to Booze], 20, 1, inebriety[best_index]);
			return slDrinkCafe(1, cafe_backmap[best_index]);
		}
		else
		{
			print("Drinking a " + item_backmap[best_index] + "...", "blue");
			retrieve_item(1, item_backmap[best_index]);
			return slDrink(1, item_backmap[best_index]);
		}
	}
	else
	{
		string name = (cafe_backmap contains best_index) ? cafeDrinkName(cafe_backmap[best_index]) : item_backmap[best_index];
		print("Would have drunk a " + name + " for " + adv[best_index] + " adventures and " + inebriety[best_index] + " inebriety.", "blue");
		return true;
	}
}

boolean sl_knapsackAutoConsume(string type, boolean simulate)
{
	// TODO: does not consider mime army shotglass

	int organLeft()
	{
		if (type == "eat") return fullness_left();
		if (type == "drink") return inebriety_left();
		abort("Unrecognized organ type: should be 'eat' or 'drink', was " + type);
		return 0;
	}
	if (organLeft() == 0) return false;

	if (item_amount($item[unremarkable duffel bag]) > 0)
	{
		use(item_amount($item[unremarkable duffel bag]), $item[unremarkable duffel bag]);
	}
	if (item_amount($item[van key]) > 0)
	{
		use(item_amount($item[van key]), $item[van key]);
	}

	int[int] space;
	float[int] adv;

	int [int] cafe_backmap;
	item[int] item_backmap;
	loadConsumables(type, item_backmap, cafe_backmap, adv, space);

	int[item] normal_consumables;

	int remaining_space = organLeft();
	print("Space: " + remaining_space);
	boolean[int] result = knapsack(remaining_space, count(space), space, adv);

	print("Knapsack " + type + " plan:", "blue");
	float total_adv = 0.0;
	int consumable_count = 0;
	int sum_space = 0;
	foreach i in result
	{
		string name;
		if (cafe_backmap contains i)
		{
			name = (type == "eat") ? cafeFoodName(cafe_backmap[i]) : cafeDrinkName(cafe_backmap[i]);
		}
		else
		{
			name = to_string(item_backmap[i]);
			normal_consumables[item_backmap[i]] += 1;
		}
		consumable_count++;
		sum_space += space[i];
		string organ_name = (type == "eat") ? "fullness" : "inebriety";
		print(adv[i] + " adventures from " + name + " (" + space[i] + " " + organ_name + ")", "blue");
		total_adv += adv[i];
	}
	if (type == "eat")
	{
		print("(including +" + min(item_amount($item[special seasoning]), consumable_count) + " from special seasoning ("+ item_amount($item[special seasoning]) + " available)", "blue");
	}
	if (type == "drink" && sl_have_skill($skill[The Ode to Booze]))
	{
		print("(+" + sum_space + " from Ode to Booze)", "blue");
		total_adv += sum_space;
	}
	print("For a total of: " + total_adv + " adventures.", "blue");

	if(count(result) == 0)
	{
		print("Couldn't find a way of finishing off our " + type + " space exactly.", "red");
		return false;
	}

	if(!canSimultaneouslyAcquire(normal_consumables))
	{
		print("It looks like I can't simultaneously get everything that I want to " + type + ". I'll wait and see if I get unconfused - otherwise, please " + type + " manually.", "red");
		return false;
	}

	if(simulate) return true;

	// Craft everything before getting Milk of Magnesium, since
	// we might be using non-free crafting turns.
	foreach it, howmany in normal_consumables
	{
		retrieve_item(howmany, it);
	}

	if(type == "eat")
	{
		if (in_tcrs() && get_property("sl_useWishes").to_boolean() && (0 == have_effect($effect[Got Milk])))
		{
			// +15 adv is worth it for daycount
			// TODO: Some folks have requested a setting to turn this off.
			makeGenieWish($effect[Got Milk]);
		}
		else dealwithMilkOfMagnesium(true);
	}

	foreach i in result
	{
		if (cafe_backmap contains i)
		{
			int what = cafe_backmap[i];
			if(type == "drink")
			{
				buffMaintain($effect[Ode to Booze], 20, 1, inebriety_left());
				slDrinkCafe(1, what);
			}
			else if (type == "eat")
			{
				slEatCafe(1, what);
			}
		}
		else
		{
			item what = item_backmap[i];
			if (type == "drink")
				slDrink(1, what);
			else if (type == "eat")
				slEat(1, what);
		}
	}
	return true;
}

boolean sl_maximizedConsumeStuff()
{
	if(my_adventures() < 10)
	{
		if(my_inebriety() < 8 && inebriety_left() > 0)
		{
			// just drink, like, anything, whatever
			// find the best and biggest thing we can and drink it
			return sl_autoDrinkOne(false);
		}
		if(inebriety_left() > 0)
		{
			use_familiar($familiar[none]);
			return sl_knapsackAutoConsume("drink", false);
		}
		if(fullness_left() > 0)
		{
			return sl_knapsackAutoConsume("eat", false);
		}
	}
	return false;
}
