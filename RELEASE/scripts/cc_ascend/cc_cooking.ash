script "cc_cooking.ash"

#
#	Handler for in-run consumption
#

void consumeStuff();
boolean makePerfectBooze();
item getAvailablePerfectBooze();
boolean dealWithMilkOfMagnesium(boolean useAdv);
boolean ccEat(int howMany, item toEat);
boolean ccEat(int howMany, item toEat, boolean silent);
boolean ccDrink(int howMany, item toDrink);
boolean ccOverdrink(int howMany, item toOverdrink);
boolean ccChew(int howMany, item toChew);
boolean tryPantsEat();
boolean tryCookies();
boolean canDrink(item toDrink);
boolean canEat(item toEat);

boolean keepOnTruckin()
{
	if(get_property("cc_limitConsume").to_boolean())
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

	consumeStuff();
	return true;
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
	if((cc_my_path() == "Heavy Rains") && (get_property("cc_orchard") == "finished"))
	{
		return false;
	}
	while((fullness_limit() - my_fullness()) > 0)
	{
		buyUpTo(1, $item[Fortune Cookie]);
		if((item_amount($item[Mayoflex]) > 0) && (cc_get_campground() contains $item[Portable Mayo Clinic]))
		{
			use(1, $item[Mayoflex]);
		}
		buffMaintain($effect[Song of the Glorious Lunch], 10, 1, 1);
		ccEat(1, $item[Fortune Cookie]);
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
				if((get_property("mayoInMouth") == "") && (cc_get_campground() contains $item[Portable Mayo Clinic]))
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
				ccEat(1, it);
				return true;
			}
		}
	}
	return false;
}

boolean ccDrink(int howMany, item toDrink)
{
	if((toDrink == $item[none]) || (howMany <= 0))
	{
		return false;
	}
	if(item_amount(toDrink) < howMany)
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

	if(possessEquipment($item[Wrist-Boy]) && (my_meat() > 6500))
	{
		if((have_effect($effect[Drunk and Avuncular]) < expectedInebriety) && (item_amount($item[Drunk Uncles Holo-Record]) == 0))
		{
			buyUpTo(1, $item[Drunk Uncles Holo-Record]);
		}
		buffMaintain($effect[Drunk and Avuncular], 0, 1, expectedInebriety);
	}

	boolean retval = false;
	while(howMany > 0)
	{
		retval = drink(1, toDrink);
		if(retval)
		{
			handleTracker(toDrink, "cc_drunken");
		}
		howMany = howMany - 1;
	}

	if(equipped_item($slot[Acc3]) != it)
	{
		equip($slot[Acc3], it);
	}

	return retval;
}

boolean ccOverdrink(int howMany, item toOverdrink)
{
	if(!canDrink(toOverdrink))
	{
		return false;
	}
	return overdrink(howMany, toOverdrink);
}

boolean ccChew(int howMany, item toChew)
{
	return chew(howMany, toChew);
}

boolean ccEat(int howMany, item toEat)
{
	return ccEat(howMany, toEat, true);
}

boolean ccEat(int howMany, item toEat, boolean silent)
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
		if((cc_get_campground() contains $item[Portable Mayo Clinic]) && (my_meat() > 11000) && (get_property("mayoInMouth") == "") && is_unrestricted($item[Portable Mayo Clinic]))
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
			handleTracker(toEat, "cc_eaten");
		}
		howMany = howMany - 1;
	}
	return retval;
}

boolean dealWithMilkOfMagnesium(boolean useAdv)
{
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
	if(!is_unrestricted(toDrink))
	{
		return false;
	}
	if((cc_my_path() == "Nuclear Autumn") && (toDrink.inebriety != 1))
	{
		return false;
	}
	if(cc_my_path() == "KOLHS")
	{
		if(!($items[Bottle of Fruity &quot;Wine&quot;, Can of the Cheapest Beer, Single Swig of Vodka, Steel Margarita] contains toDrink))
		{
			return false;
		}
	}
	if(cc_my_path() == "License to Adventure")
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

	if(!glover_usable(toDrink))
	{
		return false;
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
	if(!is_unrestricted(toEat))
	{
		return false;
	}
	if((cc_my_path() == "Nuclear Autumn") && (toEat.fullness != 1))
	{
		return false;
	}

	if(!glover_usable(toEat))
	{
		return false;
	}

	if(my_level() < toEat.levelreq)
	{
		return false;
	}

	return true;
}

void consumeStuff()
{
	if(ed_eatStuff())
	{
		return;
	}
	if(get_property("kingLiberated") != false)
	{
		return;
	}
	if(cc_my_path() == "Community Service")
	{
		cs_eat_spleen();
		return;
	}

	int mpForOde = 50;
	if(!have_skill($skill[The Ode to Booze]))
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
				ccEat(1, $item[Pixel Lemon]);
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
				shrugAT($effect[Ode to Booze]);
				buffMaintain($effect[Ode to Booze], 50, 1, 3);
				ccDrink(1, booze);
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
				shrugAT($effect[Ode to Booze]);
				buffMaintain($effect[Ode to Booze], 50, 1, 3);
				ccDrink(min(item_amount($item[Sacramento Wine]), have_effect($effect[Ode to Booze])), $item[Sacramento Wine]);
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
				shrugAT($effect[Ode to Booze]);
				buffMaintain($effect[Ode to Booze], 50, 1, 3);
				ccDrink(1, $item[Pixel Daiquiri]);
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
				shrugAT($effect[Ode to Booze]);
				buffMaintain($effect[Ode to Booze], 50, 1, 3);
				ccDrink(1, $item[Robin Nog]);
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
			shrugAT($effect[Ode to Booze]);
			buffMaintain($effect[Ode to Booze], 50, 1, 3);
			ccDrink(1, $item[Hacked Gibson]);
		}
	}

	if((fullness_left() >= 4) && (my_level() >= 4) && is_unrestricted($item[Browser Cookie]) && canEat($item[Browser Cookie]))
	{
		int browserCookies = min(fullness_left()/4, item_amount($item[Browser Cookie]));
		ccEat(browserCookies, $item[Browser Cookie]);
	}


	if(my_daycount() == 1)
	{
		if((my_spleen_use() == 0) && (item_amount($item[Grim Fairy Tale]) > 0))
		{
			chew(1, $item[Grim Fairy Tale]);
		}

		if(!contains_text(get_counters("Fortune Cookie", 0, 200), "Fortune Cookie") && (my_turncount() < 70) && (fullness_left() > 0) && (my_meat() >= npc_price($item[Fortune Cookie])) && (item_amount($item[Deck of Every Card]) == 0) && (item_amount($item[Stone Wool]) < 2) && !(cc_get_clan_lounge() contains $item[Clan Speakeasy]))
		{
			buyUpTo(1, $item[Fortune Cookie], npc_price($item[Fortune Cookie]));
			ccEat(1, $item[Fortune Cookie]);
		}

		//	Try to drink more on day 1 please!

		if((my_meat() > 400) && (item_amount($item[Handful of Smithereens]) == 3) && (get_property("cc_mosquito") == "finished") && (internalQuestStatus("questL03Rat") >= 0) && canDrink($item[Paint A Vulgar Pitcher]))
		{
			cli_execute("make 3 " + $item[Paint A Vulgar Pitcher]);
		}

		if((inebriety_left() >= 2) && (my_mp() >= mpForOde) && (item_amount($item[Agitated Turkey]) >= 2) && is_unrestricted($item[Fist Turkey Outline]) && canDrink($item[Agitated Turkey]))
		{
			shrugAT($effect[Ode to Booze]);
			buffMaintain($effect[Ode to Booze], 50, 1, 2);
			ccDrink(2, $item[Agitated Turkey]);
		}

		if((inebriety_left() >= 1) && (my_mp() >= mpForOde) && (item_amount($item[Cold One]) >= 1) && (my_level() >= 11) && canDrink($item[Cold One]))
		{
			shrugAT($effect[Ode to Booze]);
			buffMaintain($effect[Ode to Booze], 50, 1, 2);
			ccDrink(1, $item[Cold One]);
		}

		if((my_mp() > mpForOde) && (my_level() >= 3) && (item_amount($item[Paint a Vulgar Pitcher]) > 0) && ((my_inebriety() + 2) <= inebriety_limit()) && is_unrestricted($item[The Smith\'s Tome]) && canDrink($item[Paint A Vulgar Pitcher]))
		{
			shrugAT($effect[Ode to Booze]);
			buffMaintain($effect[Ode to Booze], 50, 1, 2);
			ccDrink(1, $item[Paint A Vulgar Pitcher]);
			if((item_amount($item[Paint A Vulgar Pitcher]) > 0) && ((my_inebriety() + 2) <= inebriety_limit()))
			{
				ccDrink(1, $item[Paint A Vulgar Pitcher]);
			}
		}

		if((my_mp() > mpForOde) && is100FamiliarRun() && (my_inebriety() == 0) && (my_meat() >= 500) && (item_amount($item[Clan VIP Lounge Key]) > 0) && is_unrestricted($item[Clan Speakeasy]))
		{
			shrugAT($effect[Ode to Booze]);

			if(inebriety_left() >= 1)
			{
				buffMaintain($effect[Ode to Booze], 50, 1, 1);
				#cli_execute("drink 1 lucky lindy");
				drinkSpeakeasyDrink($item[Lucky Lindy]);
			}

			if((inebriety_left() >= 4) && canDrink($item[Ice Island Long Tea]))
			{
				pullXWhenHaveY($item[Ice Island Long Tea], 1, 0);
				if(item_amount($item[Ice Island Long Tea]) > 0)
				{
					ccDrink(1, $item[Ice Island Long Tea]);
				}
			}
		}

		if((my_mp() > mpForOde) && is100FamiliarRun() && (my_inebriety() == 13) && (item_amount($item[Cold One]) > 0) && (my_level() >= 10) && canDrink($item[Cold One]))
		{
			shrugAT($effect[Ode to Booze]);
			buffMaintain($effect[Ode to Booze], 50, 1, 1);
			ccDrink(1, $item[Cold One]);
		}

		if((my_mp() > mpForOde) && (amountTurkeyBooze() >= 2) && (my_inebriety() == 0) && (my_meat() >= 500) && (item_amount($item[Clan VIP Lounge Key]) > 0) && is_unrestricted($item[Fist Turkey Outline]) && canDrink($item[Friendly Turkey]))
		{
			shrugAT($effect[Ode to Booze]);
			buffMaintain($effect[Ode to Booze], 50, 1, 3);
			drinkSpeakeasyDrink($item[Lucky Lindy]);
#			cli_execute("drink 1 lucky lindy");
			while((amountTurkeyBooze() > 0) && (my_inebriety() < 3) && (inebriety_left() > 0))
			{
				if((item_amount($item[Friendly Turkey]) > 0) && (inebriety_left() >= 1))
				{
					ccDrink(1, $item[Friendly Turkey]);
				}
				else if((item_amount($item[Agitated Turkey]) > 0) && (inebriety_left() >= 1))
				{
					ccDrink(1, $item[Agitated Turkey]);
				}
				else if((item_amount($item[Ambitious Turkey]) > 0) && (inebriety_left() >= 1))
				{
					ccDrink(1, $item[Ambitious Turkey]);
				}
			}
		}

		if((my_mp() > mpForOde) && (turkeyBooze() >= 5) && (amountTurkeyBooze() >= 3) && (my_inebriety() < 6) && is_unrestricted($item[Fist Turkey Outline]) && canDrink($item[Friendly Turkey]))
		{
			shrugAT($effect[Ode to Booze]);
			buffMaintain($effect[Ode to Booze], 50, 1, 3);
			while((amountTurkeyBooze() > 0) && (my_inebriety() < 6) && (inebriety_left() > 0))
			{
				if((item_amount($item[Friendly Turkey]) > 0) && (inebriety_left() >= 1))
				{
					ccDrink(1, $item[Friendly Turkey]);
				}
				else if((item_amount($item[Agitated Turkey]) > 0) && (inebriety_left() >= 1))
				{
					ccDrink(1, $item[Agitated Turkey]);
				}
				else if((item_amount($item[Ambitious Turkey]) > 0) && (inebriety_left() >= 1))
				{
					ccDrink(1, $item[Ambitious Turkey]);
				}
			}
		}

		if((get_property("cc_ballroomsong") == "finished") && (inebriety_left() >= 2) && (get_property("_speakeasyDrinksDrunk").to_int() == 1) && (my_mp() >= (mpForOde+30)) && ((my_inebriety() + 2) <= inebriety_limit()) && !($classes[Avatar of Boris, Ed] contains my_class()))
		{
			if(item_amount($item[Clan VIP Lounge Key]) > 0)
			{
				shrugAT($effect[Ode to Booze]);
				buffMaintain($effect[Ode to Booze], 50, 1, 2);
				drinkSpeakeasyDrink($item[Sockdollager]);
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
				ccEat(1, $item[Spaghetti Breakfast]);
			}
			if((fullness_left() >= 10) && canEat(whatHiMein()))
			{
				pullXWhenHaveY(whatHiMein(), 2, 0);
			}
			if((item_amount(whatHiMein()) >= 2) && (fullness_left() >= 10) && canEat(whatHiMein()))
			{
				buffMaintain($effect[Song of the Glorious Lunch], 10, 1, 1);
				buffMaintain($effect[Got Milk], 0, 1, 1);
				ccEat(2, whatHiMein());
			}
			if((item_amount($item[Digital Key Lime Pie]) > 0) && (fullness_left() >= 4) && canEat($item[Digital Key Lime Pie]))
			{
				buffMaintain($effect[Song of the Glorious Lunch], 10, 1, 1);
				buffMaintain($effect[Got Milk], 0, 1, 1);
				ccEat(1, $item[Digital Key Lime Pie]);
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
						ccEat(1, whatHiMein());
					}
				}
				else if((fullness_left() >= 4) && canEat($item[Digital Key Lime Pie]))
				{
					pullXWhenHaveY($item[Digital Key Lime Pie], 1, 0);
					if(item_amount($item[Digital Key Lime Pie]) > 0)
					{
						buffMaintain($effect[Got Milk], 0, 1, 1);
						buffMaintain($effect[Song of the Glorious Lunch], 10, 1, 1);
						ccEat(1, $item[Digital Key Lime Pie]);
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
						ccCraft("cook", 1, $item[Dry Noodles], $item[Bubblin\' Crude]);
					}
					else if((item_amount($item[Goat Cheese]) > 0) && (item_amount($item[Scrumptious Reagent]) > 0) && (item_amount($item[Dry Noodles]) > 0))
					{
						ccCraft("cook", 1, $item[Goat Cheese], $item[Scrumptious Reagent]);
						ccCraft("cook", 1, $item[Dry Noodles], $item[Fancy Schmancy Cheese Sauce]);
					}
					else if((item_amount($item[Ectoplasmic Orbs]) > 0) && (item_amount($item[Dry Noodles]) > 0))
					{
						ccCraft("cook", 1, $item[Dry Noodles], $item[Ectoplasmic Orbs]);
					}
					else if((item_amount($item[Pestopiary]) > 0) && (item_amount($item[Dry Noodles]) > 0))
					{
						ccCraft("cook", 1, $item[Dry Noodles], $item[Pestopiary]);
					}
					else if((item_amount($item[Salacious Crumbs]) > 0) && (item_amount($item[Dry Noodles]) > 0))
					{
						ccCraft("cook", 1, $item[Dry Noodles], $item[Salacious Crumbs]);
					}
				}
				dealWithMilkOfMagnesium(!in_hardcore());
				foreach it in toEat
				{
					while((canEat > 0) && (item_amount(it) > 0) && (fullness_left() >= 5) && canEat(it))
					{
						buffMaintain($effect[Got Milk], 0, 1, 1);
						buffMaintain($effect[Song of the Glorious Lunch], 10, 1, 1);
						ccEat(1, it);
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
			ccEat(1, $item[Boris\'s Key Lime Pie]);
			ccEat(1, $item[Jarlsberg\'s Key Lime Pie]);
			ccEat(1, $item[Sneaky Pete\'s Key Lime Pie]);
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
			chew(1, $item[carrot juice]);
		}

		if(in_hardcore())
		{
			while((spleen_left() >= 4) && (item_amount($item[Unconscious Collective Dream Jar]) > 0))
			{
				chew(1, $item[Unconscious Collective Dream Jar]);
			}
			while((spleen_left() >= 4) && (item_amount($item[Powdered Gold]) > 0))
			{
				chew(1, $item[Powdered Gold]);
			}
			while((spleen_left() >= 4) && (item_amount($item[Grim Fairy Tale]) > 0))
			{
				chew(1, $item[Grim Fairy Tale]);
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
					ccEat(3, whatHiMein());
				}
			}
			if(get_property("cc_useCubeling").to_boolean())
			{
				int count = towerKeyCount();
				if(get_property("cc_phatloot").to_int() < my_daycount())
				{
					count = count + 1;
				}
				if(count >= 2)
				{
					if((item_amount($item[Spaghetti Breakfast]) > 0) && (fullness_left() > 0) && canEat($item[Spaghetti Breakfast]))
					{
						buffMaintain($effect[Song of the Glorious Lunch], 10, 1, 1);
						buffMaintain($effect[Got Milk], 0, 1, 1);
						if((item_amount($item[Mayoflex]) > 0) && (cc_get_campground() contains $item[Portable Mayo Clinic]))
						{
							use(1, $item[Mayoflex]);
						}
						ccEat(1, $item[Spaghetti Breakfast]);
					}
					if((fullness_left() >= 4) && canEat($item[Boris\'s Key Lime Pie]))
					{
						pullXWhenHaveY($item[Boris\'s Key Lime Pie], 1, 0);
					}
					if((item_amount($item[Boris\'s Key Lime Pie]) > 0) && (fullness_left() >= 4) && canEat($item[Boris\'s Key Lime Pie]))
					{
						buffMaintain($effect[Song of the Glorious Lunch], 10, 1, 1);
						buffMaintain($effect[Got Milk], 0, 1, 1);
						if((item_amount($item[Mayoflex]) > 0) && (cc_get_campground() contains $item[Portable Mayo Clinic]))
						{
							use(1, $item[Mayoflex]);
						}
						ccEat(1, $item[Boris\'s Key Lime Pie]);
					}
					if((fullness_left() >= 10) && canEat(whatHiMein()))
					{
						pullXWhenHaveY(whatHiMein(), 2, 0);
					}
					if((item_amount(whatHiMein()) > 0) && (fullness_left() >= 5) && canEat(whatHiMein()))
					{
						buffMaintain($effect[Song of the Glorious Lunch], 10, 1, 1);
						buffMaintain($effect[Got Milk], 0, 1, 1);
						if((item_amount($item[Mayoflex]) > 0) && (cc_get_campground() contains $item[Portable Mayo Clinic]))
						{
							use(1, $item[Mayoflex]);
						}
						ccEat(1, whatHiMein());
					}
					if((item_amount(whatHiMein()) > 0) && (fullness_left() >= 5) && canEat(whatHiMein()))
					{
						buffMaintain($effect[Song of the Glorious Lunch], 10, 1, 1);
						buffMaintain($effect[Got Milk], 0, 1, 1);
						if((item_amount($item[Mayoflex]) > 0) && (cc_get_campground() contains $item[Portable Mayo Clinic]))
						{
							use(1, $item[Mayoflex]);
						}
						ccEat(1, whatHiMein());
					}
				}
			}
			else if(!get_property("cc_useCubeling").to_boolean())
			{
				if(((item_amount($item[Boris\'s Key Lime Pie]) > 0) || (item_amount($item[Jarlsberg\'s Key Lime Pie]) > 0) || (item_amount($item[Sneaky Pete\'s Key Lime Pie]) > 0)) && (fullness_left() >= 4) && canEat($item[Boris\'s Key Lime Pie]))
				{
					buffMaintain($effect[Song of the Glorious Lunch], 10, 1, 1);
					buffMaintain($effect[Got Milk], 0, 1, 1);
				}
				if((item_amount($item[Boris\'s Key Lime Pie]) > 0) && (fullness_left() >= 4) && canEat($item[Boris\'s Key Lime Pie]))
				{
					ccEat(1, $item[Boris\'s Key Lime Pie]);
				}
				if((item_amount($item[Jarlsberg\'s Key Lime Pie]) > 0) && (fullness_left() >= 4) && canEat($item[Jarlsberg\'s Key Lime Pie]))
				{
					ccEat(1, $item[Jarlsberg\'s Key Lime Pie]);
				}
				if((item_amount($item[Sneaky Pete\'s Key Lime Pie]) > 0) && (fullness_left() >= 4) && canEat($item[Sneaky Pete\'s Key Lime Pie]))
				{
					ccEat(1, $item[Sneaky Pete\'s Key Lime Pie]);
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
						ccCraft("cook", 1, $item[Dry Noodles], $item[Bubblin\' Crude]);
					}
					else if((item_amount($item[Goat Cheese]) > 0) && (item_amount($item[Scrumptious Reagent]) > 0) && (item_amount($item[Dry Noodles]) > 0))
					{
						ccCraft("cook", 1, $item[Goat Cheese], $item[Scrumptious Reagent]);
						ccCraft("cook", 1, $item[Dry Noodles], $item[Fancy Schmancy Cheese Sauce]);
					}
					else if((item_amount($item[Ectoplasmic Orbs]) > 0) && (item_amount($item[Dry Noodles]) > 0))
					{
						ccCraft("cook", 1, $item[Dry Noodles], $item[Ectoplasmic Orbs]);
					}
					else if((item_amount($item[Pestopiary]) > 0) && (item_amount($item[Dry Noodles]) > 0))
					{
						ccCraft("cook", 1, $item[Dry Noodles], $item[Pestopiary]);
					}
					else if((item_amount($item[Salacious Crumbs]) > 0) && (item_amount($item[Dry Noodles]) > 0))
					{
						ccCraft("cook", 1, $item[Dry Noodles], $item[Salacious Crumbs]);
					}
				}
				dealWithMilkOfMagnesium(true);
				foreach it in toEat
				{
					while((canEat > 0) && (item_amount(it) > 0) && (fullness_left() >= 5) && canEat(it))
					{
						buffMaintain($effect[Song of the Glorious Lunch], 10, 1, 1);
						buffMaintain($effect[Got Milk], 0, 1, 1);
						ccEat(1, it);
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
			shrugAT($effect[Ode to Booze]);
			buffMaintain($effect[Ode to Booze], 50, 1, 4);
			cli_execute("make 2 " + $item[Paint A Vulgar Pitcher]);
			ccDrink(2, $item[Paint A Vulgar Pitcher]);
		}

		if((my_inebriety() == 4) && (my_mp() >= mpForOde) && (my_meat() > 150) && (item_amount($item[Handful of Smithereens]) >= 1) && (internalQuestStatus("questL03Rat") >= 0) && canDrink($item[Paint A Vulgar Pitcher]))
		{
			shrugAT($effect[Ode to Booze]);
			cli_execute("make 1 " + $item[Paint A Vulgar Pitcher]);
			buffMaintain($effect[Ode to Booze], 50, 1, 2);
			ccDrink(1, $item[Paint A Vulgar Pitcher]);
		}

		if((inebriety_left() >= 5) && (my_adventures() < 10) && (my_meat() > 150) && (my_mp() >= mpForOde) && (cc_my_path() != "KOLHS") && (cc_my_path() != "Nuclear Autumn"))
		{
			if(((item_amount($item[Handful Of Smithereens]) > 0) && (internalQuestStatus("questL03Rat") >= 0)) || ((get_property("_speakeasyDrinksDrunk").to_int() < 3) && is_unrestricted($item[Clan Speakeasy]) && (item_amount($item[Clan VIP Lounge Key]) > 0)))
			{
				shrugAT($effect[Ode to Booze]);
				buffMaintain($effect[Ode to Booze], 50, 1, 4);
				if((item_amount($item[Handful Of Smithereens]) > 0) && canDrink($item[Paint A Vulgar Pitcher]))
				{
					cli_execute("make 1 " + $item[Paint A Vulgar Pitcher]);
					ccDrink(1, $item[Paint A Vulgar Pitcher]);
				}
				else if((my_meat() > 35000) && is_unrestricted($item[Clan Speakeasy]) && (item_amount($item[Clan VIP Lounge Key]) > 0))
				{
					drinkSpeakeasyDrink($item[Flivver]);
				}
			}
		}

		if((get_property("cc_nunsTrick") == "got") && (get_property("currentNunneryMeat").to_int() < 100000) && is_unrestricted($item[Fist Turkey Outline]))
		{
			if((get_property("cc_mcmuffin") == "ed") || (get_property("cc_mcmuffin") == "finished"))
			{
				if((my_inebriety() >= 6) && (my_inebriety() <= 11) && (my_mp() >= mpForOde) && canDrink($item[Ambitious Turkey]))
				{
					if(item_amount($item[ambitious turkey]) > 0)
					{
						shrugAT($effect[Ode to Booze]);
						buffMaintain($effect[Ode to Booze], 50, 1, 1);
						ccDrink(1, $item[Ambitious Turkey]);
					}
				}
			}
		}


		if(in_hardcore() && (my_mp() > mpForOde) && (item_amount($item[Pixel Daiquiri]) > 0) && (inebriety_left() >= 2) && is_unrestricted($item[Yellow Puck]) && canDrink($item[Pixel Daiquiri]))
		{
			shrugAT($effect[Ode to Booze]);
			buffMaintain($effect[Ode to Booze], 50, 1, 2);
			ccDrink(1, $item[Pixel Daiquiri]);
		}
		if(in_hardcore() && (my_mp() > mpForOde) && (item_amount($item[Dinsey Whinskey]) > 0) && (inebriety_left() >= 2) && is_unrestricted($item[Airplane Charter: Dinseylandfill]) && canDrink($item[Dinsey Whinskey]))
		{
			shrugAT($effect[Ode to Booze]);
			buffMaintain($effect[Ode to Booze], 50, 1, 2);
			ccDrink(1, $item[Dinsey Whinskey]);
		}

		if((my_level() >= 11) && (my_mp() > mpForOde) && (item_amount($item[Cold One]) > 1) && (inebriety_left() >= 2) && canDrink($item[Cold One]))
		{
			shrugAT($effect[Ode to Booze]);
			buffMaintain($effect[Ode to Booze], 50, 1, 2);
			ccDrink(2, $item[Cold One]);
		}

		if((my_inebriety() >= 6) && (my_inebriety() <= 11) && (get_property("cc_orchard") == "finished") && (my_mp() >= mpForOde) && is_unrestricted($item[Fist Turkey Outline]))
		{
			if((get_property("cc_nuns") != "finished") && (get_property("cc_nuns") != "done") && (get_property("currentNunneryMeat").to_int() == 0))
			{
				if((item_amount($item[Ambitious Turkey]) > 0) && canDrink($item[Ambitious Turkey]))
				{
					shrugAT($effect[Ode to Booze]);
					buffMaintain($effect[Ode to Booze], 50, 1, 1);
					ccDrink(1, $item[Ambitious Turkey]);
				}
			}
		}

		if((cc_my_path() == "Picky") && (my_mp() > mpForOde) && (my_meat() > 150) && (item_amount($item[Paint A Vulgar Pitcher]) > 0) && ((my_inebriety() + 2) <= inebriety_limit()) && canDrink($item[Paint A Vulgar Pitcher]))
		{
			shrugAT($effect[Ode to Booze]);
			buffMaintain($effect[Ode to Booze], 50, 1, 2);
			ccDrink(1, $item[Paint A Vulgar Pitcher]);
		}


		if((cc_my_path() == "Picky") && (my_mp() > mpForOde) && (my_meat() > 150) && (item_amount($item[Ambitious Turkey]) > 0) && ((my_inebriety() + 1) <= inebriety_limit()) && canDrink($item[Ambitious Turkey]))
		{
			shrugAT($effect[Ode to Booze]);
			buffMaintain($effect[Ode to Booze], 50, 1, 1);
			ccDrink(1, $item[Ambitious Turkey]);
		}

		if((cc_my_path() == "Picky") && (my_mp() > mpForOde) && (inebriety_left() > 0) && (my_meat() > 500) && (get_property("_speakeasyDrinksDrunk").to_int() < 3) && (item_amount($item[Clan VIP Lounge Key]) > 0))
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
				shrugAT($effect[Ode to Booze]);
				buffMaintain($effect[Ode to Booze], 50, 1, 4);
				drinkSpeakeasyDrink(toDrink);
			}
		}

/*****	This section needs to merge into a "Standard equivalent"		*****/
		if((cc_my_path() == "Standard") && (my_mp() >= mpForOde) && (my_meat() > 150) && (item_amount($item[Paint A Vulgar Pitcher]) > 0) && ((my_inebriety() + 2) <= inebriety_limit()) && is_unrestricted($item[The Smith\'s Tome]) && canDrink($item[Paint A Vulgar Pitcher]))
		{
			shrugAT($effect[Ode to Booze]);
			buffMaintain($effect[Ode to Booze], 50, 1, 2);
			ccDrink(1, $item[Paint A Vulgar Pitcher]);
		}


		if((cc_my_path() == "Standard") && (my_mp() >= mpForOde) && (item_amount($item[Ambitious Turkey]) > 0) && ((my_inebriety() + 1) <= inebriety_limit()) && is_unrestricted($item[Fist Turkey Outline]) && canDrink($item[Ambitious Turkey]))
		{
			shrugAT($effect[Ode to Booze]);
			buffMaintain($effect[Ode to Booze], 50, 1, 1);
			ccDrink(1, $item[Ambitious Turkey]);
		}

		if((cc_my_path() == "Standard") && (my_mp() >= mpForOde) && (my_inebriety() <= inebriety_limit()) && (my_meat() > 500) && (get_property("_speakeasyDrinksDrunk").to_int() < 3))
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
				ccEat(3, $item[Star Key Lime Pie]);
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
					ccEat(3, whatHiMein());
				}
			}
		}

		if((item_amount($item[Handful Of Smithereens]) > 0) && (my_meat() > 300) && canDrink($item[Paint A Vulgar Pitcher]) && (internalQuestStatus("questL03Rat") >= 0))
		{
			cli_execute("make " + $item[Paint A Vulgar Pitcher]);
		}

		if((cc_my_path() == "Picky") && (my_mp() > mpForOde) && (item_amount($item[Paint A Vulgar Pitcher]) > 0) && ((my_inebriety() + 2) <= inebriety_limit()) && canDrink($item[Paint A Vulgar Pitcher]))
		{
			shrugAT($effect[Ode to Booze]);
			buffMaintain($effect[Ode to Booze], 50, 1, 2);
			ccDrink(1, $item[Paint A Vulgar Pitcher]);
		}

		if((cc_my_path() == "Picky") && (my_mp() > mpForOde) && (item_amount($item[Ambitious Turkey]) > 0) && ((my_inebriety() + 1) <= inebriety_limit()) && canDrink($item[Ambitious Turkey]))
		{
			shrugAT($effect[Ode to Booze]);
			buffMaintain($effect[Ode to Booze], 50, 1, 1);
			ccDrink(1, $item[Ambitious Turkey]);
		}
	}
}
