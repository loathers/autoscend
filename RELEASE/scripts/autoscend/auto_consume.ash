#
#	Handler for in-run consumption
#

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
	float parse()
	{
		if (!it.adventures.contains_text("-")) return it.adventures.to_int();
		string[int] s = split_string(it.adventures, "-");
		return (s[1].to_int() + s[0].to_int())/2.0;
	}
	float expected = parse();
	if(auto_have_skill($skill[Saucemaven]) && saucemavenApplies(it))
	{
		if ($classes[Sauceror, Pastamancer] contains my_class()) expected += 5;
		else expected += 3;
	}
	//if (item_amount($item[black label]) > 0 && $items[bottle of gin, bottle of rum, bottle of tequila, bottle of vodka or bottle of whiskey] contains it)
	//	expected += 3.5;
	return expected;
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

boolean autoDrink(int howMany, item toDrink)
{
	return autoDrink(howMany, toDrink, false);
}

boolean autoDrink(int howMany, item toDrink, boolean silent)
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

	if(canOde(toDrink) && auto_have_skill($skill[The Ode to Booze]))
	{
		shrugAT($effect[Ode to Booze]);
		// get enough turns of ode
		while(acquireMP(mp_cost($skill[The Ode to Booze]), 0) && buffMaintain($effect[Ode to Booze], mp_cost($skill[The Ode to Booze]), 1, expectedInebriety))
			/*do nothing, the loop condition is doing the work*/;
	}

	boolean retval = false;
	while(howMany > 0)
	{
		if(!isSpeakeasy)
		{
			if(silent)
			{
				retval = drinksilent(1, toDrink);
			}
			else
			{
				retval = drink(1, toDrink);
			}
		}
		else
		{
			retval = drinkSpeakeasyDrink(toDrink);
		}

		if(retval)
		{
			handleTracker(toDrink, "auto_drunken");
		}
		howMany = howMany - 1;
	}

	if(equipped_item($slot[Acc3]) != it)
	{
		equip($slot[Acc3], it);
	}

	return retval;
}

boolean autoOverdrink(int howMany, item toOverdrink)
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
	default: abort("autoDrinkCafe does not recognize item id: " + id);
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
	default: abort("autoDrinkCafe does not recognize item id: " + id);
	}
	return "";
}

boolean autoDrinkCafe(int howmany, int id)
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
		handleTracker(name, "auto_drunken");
	}
	return true;
}

boolean autoEatCafe(int howmany, int id)
{
	if(!canadia_available()) return false;

	string name = cafeFoodName(id);
	for (int i=0; i<howmany; i++)
	{
		// TODO: What if we run out of meat?
		visit_url("cafe.php?cafeid=1");
		visit_url("cafe.php?pwd="+my_hash()+"&phash="+my_hash()+"&cafeid=1&whichitem="+id+"&action=CONSUME!");
		handleTracker(name, "auto_eaten");
	}
	return true;
}

boolean autoChew(int howMany, item toChew)
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
			handleTracker(toChew, "auto_chewed");
		}
	}

	return retval;
}

boolean autoEat(int howMany, item toEat)
{
	return autoEat(howMany, toEat, true);
}

boolean autoEat(int howMany, item toEat, boolean silent)
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
	acquireMilkOfMagnesiumIfUnused(true);
	consumeMilkOfMagnesiumIfUnused();

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
		if((auto_get_campground() contains $item[Portable Mayo Clinic]) && (my_meat() > 11000) && (get_property("mayoInMouth") == "") && auto_is_valid($item[Portable Mayo Clinic]))
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
			handleTracker(toEat, "auto_eaten");
		}
		howMany = howMany - 1;
	}
	return retval;
}



boolean acquireMilkOfMagnesiumIfUnused(boolean useAdv)
{
	if(in_tcrs())
	{
		return true;
	}

	if(item_amount($item[Milk Of Magnesium]) > 0)
	{
		return true;
	}
	if(get_property("_milkOfMagnesiumUsed").to_boolean())
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

boolean consumeMilkOfMagnesiumIfUnused()
{
	if(get_property("_milkOfMagnesiumUsed").to_boolean() || item_amount($item[Milk Of Magnesium]) < 1)
	{
		return false;
	}
	return use(1, $item[Milk of Magnesium]);
}

boolean canDrink(item toDrink, boolean checkValidity)
{
	if(!can_drink())
	{
		return false;
	}
	if(!auto_is_valid(toDrink) && checkValidity)
	{
		return false;
	}
	if (my_class() == $class[Avatar of Jarlsberg])
	{
		return contains_text(craft_type(toDrink), "Jarlsberg's Kitchen");
	}
	if((auto_my_path() == "Nuclear Autumn") && (toDrink.inebriety != 1))
	{
		return false;
	}
	if((auto_my_path() == "Dark Gyffte") != ($items[vampagne, dusty bottle of blood, Red Russian, mulled blood, bottle of Sanguiovese] contains toDrink))
	{
		return false;
	}
	if(in_kolhs())
	{
		if(!($items[Can of the Cheapest Beer, Bottle of Fruity &quot;Wine&quot;, Single Swig of Vodka, fountain \'soda\', stepmom\'s booze, Steel Margarita] contains toDrink))
		{
			return false;
		}
	}
	if(auto_my_path() == "License to Adventure")
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

	if(toDrink.levelreq >= 13 && !can_interact())
	{
		return false;
	}

	return true;
}

boolean canDrink(item toDrink)
{
	return canDrink(toDrink, true);
}

boolean canEat(item toEat, boolean checkValidity)
{
	if(!can_eat())
	{
		return false;
	}
	if(!auto_is_valid(toEat) && checkValidity)
	{
		return false;
	}
	if (my_class() == $class[Avatar of Jarlsberg])
	{
		return contains_text(craft_type(toEat), "Jarlsberg's Kitchen");
	}
	if((auto_my_path() == "Nuclear Autumn") && (toEat.fullness != 1))
	{
		return false;
	}
	if((auto_my_path() == "Dark Gyffte") && (toEat == $item[magical sausage]))
	{
		// the one thing you can eat as Vampyre AND other classes
		return true;
	}
	if((auto_my_path() == "Dark Gyffte") != ($items[blood-soaked sponge cake, blood roll-up, blood snowcone, actual blood sausage, bloodstick] contains toEat))
	{
		return false;
	}
	if(auto_my_path() == "Zombie Slayer")
	{
		return ($items[crappy brain, decent brain, good brain, boss brain, hunter brain, brains casserole, fricasseed brains, steel lasagna] contains toEat);
	}

	if(my_level() < toEat.levelreq)
	{
		return false;
	}

	if(toEat.levelreq >= 13 && !can_interact())
	{
		return false;
	}

	return true;
}

boolean canEat(item toEat)
{
	return canEat(toEat, true);
}


boolean canChew(item toChew)
{
	if(!auto_is_valid(toChew))
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
	auto_sausageGrind(23 - get_property("_sausagesMade").to_int());
	auto_sausageEatEmUp();

	if (get_property("auto_limitConsume").to_boolean())
	{
		return;
	}

	if (bat_consumption())
	{
		return;
	}
	if (inAftercore())
	{
		return;
	}
	if(auto_my_path() == "Community Service")
	{
		cs_eat_spleen();
		return;
	}
	if(in_kolhs())
	{
		kolhs_consume();
		return;
	}

	// fills up spleen for Ed.
	if (ed_eatStuff())
	{
		return;
	}

	// Try to get Fortune Cookie numbers
	if (consumeFortune())
	{
		return;
	}

	boolean edSpleenCheck = (isActuallyEd() && my_level() < 11 && spleen_left() > 0); // Ed should fill spleen first
	
	if (my_adventures() < 10 && fullness_left() > 0 && in_boris())
	{
		borisDemandSandwich(true);
	}

	if (my_adventures() < 10 && !edSpleenCheck)
	{
		// Stop drinking at 10 drunk if spookyraven billiards room isn't completed, unless no fullness is available
		if (inebriety_left() > 0)
		{
			if (my_familiar() == $familiar[Stooper] && to_familiar(get_property("auto_100familiar")) != $familiar[Stooper] 
			&& pathAllowsChangingFamiliar()) //check path allows changing of familiars
			{
				use_familiar($familiar[Mosquito]);
			}
			boolean shouldDrink = true;
			if (!hasSpookyravenLibraryKey() && my_inebriety() >= 10)
			{
				auto_log_info("Will not drink to maintain pool skill for Haunted Billiards room.");
				shouldDrink = false;
				if (fullness_left() == 0)
				{
					auto_log_warning("Need to drink as no fullness is available, pool skill will suffer.");
					shouldDrink = true;
				}
			}
			if (shouldDrink && auto_autoConsumeOne("drink", false))
			{
				return;
			}
		}
		if (fullness_left() > 0)
		{
			if (auto_autoConsumeOne("eat", false))
			{
				return;
			}
		}
	}
}

boolean consumeFortune()
{
	if (contains_text(get_counters("Fortune Cookie", 0, 200), "Fortune Cookie"))
	{
		return false;
	}

	// Don't get lucky numbers for the first semi-rare if we still need to adventure in the outskirts
	if (my_turncount() < 80 && (internalQuestStatus("questL05Goblin") < 1 && item_amount($item[Knob Goblin encryption key]) < 1) && !isActuallyEd())
	{
		return false;
	}

	// Try to consume a Lucky Lindy
	if (inebriety_left() > 0 && canDrink($item[Lucky Lindy]) && my_meat() >= npc_price($item[Lucky Lindy]))
	{
		if (autoDrink(1, $item[Lucky Lindy]))
		{
			return true;
		}
	}
	
	// Try to consume a Fortune Cookie
	if (fullness_left() > 0 && canEat($item[Fortune Cookie]) && my_meat() >= npc_price($item[Fortune Cookie]))
	{
		// Eat a spaghetti breakfast if still consumable
		if (my_fullness() == 0)
		{
			if (canEat($item[Spaghetti Breakfast]) && item_amount($item[Spaghetti Breakfast]) > 0 && my_level() >= 10)
			{
				if (!autoEat(1, $item[Spaghetti Breakfast]))
				{
					return false;
				}
			}
			else
			{
				foreach muffin in $items[blueberry muffin, bran muffin, chocolate chip muffin]
				{
					if (canEat(muffin) && item_amount(muffin) > 0)
					{
						if (!autoEat(1, muffin))
						{
							return false;
						}
					}
				}
			}
		}

		buyUpTo(1, $item[Fortune Cookie], npc_price($item[Fortune Cookie]));
		if (autoEat(1, $item[Fortune Cookie]))
		{
			return true;
		}
	}

	return false;
}

int SL_ORGAN_STOMACH = 1;
int SL_ORGAN_LIVER   = 2;

int SL_OBTAIN_NULL  = 100;
int SL_OBTAIN_CRAFT = 101;
int SL_OBTAIN_PULL  = 102;
int SL_OBTAIN_BUY   = 103;

// Used internally for knapsack optimization.
record ConsumeAction
{
	// exactly one of these is non-none
	item it;
	int cafeId;

	int size;           // how much of organ is used
	float adventures;   // expected adv from (thing)

	float desirability; // adv count that will be used for optimization
	                    // (lower for pulls, higher for buffs/tower keys)

	int organ;          // SL_ORGAN_*
	int howToGet;       // SL_OBTAIN_*
};

string consumable_name(ConsumeAction action)
{
	string name = "<name not found>";
	if (action.it != $item[none]) name = to_string(action.it);
	else if (action.organ == SL_ORGAN_LIVER) name = cafeDrinkName(action.cafeId);
	else if (action.organ == SL_ORGAN_STOMACH) name = cafeFoodName(action.cafeId);
	return name;
}

string to_pretty_string(ConsumeAction action)
{
	string organ_name = action.organ == SL_ORGAN_STOMACH ? "fullness" : "inebriety";
	string logline = consumable_name(action) + " for " + action.adventures + " base adv (" + action.size + " " + organ_name + ")";
	if (action.howToGet == SL_OBTAIN_PULL)
	{
		logline += " [PULL]";
	}
	if (action.howToGet == SL_OBTAIN_CRAFT)
	{
		logline += " [CRAFT]";
	}
	if (action.howToGet == SL_OBTAIN_BUY)
	{
		logline += " [BUY]";
	}
	return logline;
}

string to_debug_string(ConsumeAction action)
{
	string ret = "";
	ret += "ConsumeAction(it="+action.it;
	ret += ",cafeId="+action.cafeId;
	ret += ",size="+action.size;
	ret += ",adventures="+action.adventures;
	ret += ",desirability="+action.desirability;
	ret += ",organ="+action.organ;
	ret += ",howToGet="+action.howToGet;
	ret += ")";
	return ret;
}

ConsumeAction MakeConsumeAction(item it)
{
	int organ = it.inebriety > 0 ? SL_ORGAN_LIVER : SL_ORGAN_STOMACH;
	int size = max(it.inebriety, it.fullness);
	float adv = expectedAdventuresFrom(it);
	return new ConsumeAction(it, 0, size, adv, adv, organ, SL_OBTAIN_NULL);
}

boolean autoPrepConsume(ConsumeAction action)
{
	auto_log_info(to_debug_string(action));
	if(action.howToGet == SL_OBTAIN_PULL)
	{
		auto_log_info("autoPrepConsume: Pulling a " + action.it, "blue");
		action.howToGet = SL_OBTAIN_NULL;
		return pullXWhenHaveY(action.it, 1, item_amount(action.it));
	}
	else if(action.howToGet == SL_OBTAIN_CRAFT)
	{
		auto_log_info("autoPrepConsume: Crafting a " + action.it, "blue");
		action.howToGet = SL_OBTAIN_NULL;
		return create(1, action.it);
	}
	else if(action.howToGet == SL_OBTAIN_BUY)
	{
		auto_log_info("autoPrepConsume: Buying a " + action.it, "blue");
		action.howToGet = SL_OBTAIN_NULL;
		return buy(1, action.it);
	}
	else if (action.howToGet == SL_OBTAIN_NULL)
	{
		auto_log_info("autoPrepConsume: Doing nothing to get a " + action.it, "blue");
	}
	return true;
}

boolean autoConsume(ConsumeAction action)
{
	if (action.howToGet != SL_OBTAIN_NULL)
	{
		abort("ConsumeAction not prepped: " + to_debug_string(action));
	}

	if (action.organ == SL_ORGAN_LIVER)
	{
		buffMaintain($effect[Ode to Booze], 20, 1, action.size);
	}
	if(action.cafeId != 0)
	{
		if (action.organ == SL_ORGAN_LIVER)
		{
			return autoDrinkCafe(1, action.cafeId);
		}
		else if (action.organ == SL_ORGAN_STOMACH)
		{
			return autoEatCafe(1, action.cafeId);
		}
	}
	else if(action.it != $item[none])
	{
		if (action.organ == SL_ORGAN_LIVER)
		{
			return autoDrink(1, action.it);
		}
		else if (action.organ == SL_ORGAN_STOMACH)
		{
			return autoEat(1, action.it);
		}
		else
		{
			abort("autoConsume: Unrecognized organ " + action.organ);
		}
	}
	abort("autoConsume: exited with nothing");
	return false;
}

boolean loadConsumables(string _type, ConsumeAction[int] actions)
{
	// Just in case!
	if(auto_my_path() == "Dark Gyffte")
	{
		abort("We shouldn't be calling loadConsumables() in Dark Gyffte. Please report this.");
	}

	cli_execute("refresh inv");

	if ((item_amount($item[unremarkable duffel bag]) > 0) && (pulls_remaining() != -1))
	{
		use(item_amount($item[unremarkable duffel bag]), $item[unremarkable duffel bag]);
	}
	if ((item_amount($item[van key]) > 0) && (pulls_remaining() != -1))
	{
		use(item_amount($item[van key]), $item[van key]);
	}
	if ((item_amount($item[Knob Goblin lunchbox]) > 0) && (pulls_remaining() != -1))
	{
		use(item_amount($item[Knob Goblin lunchbox]), $item[Knob Goblin lunchbox]);
	}

	// type is "eat" or "drink"
	int type  = 0;
	if (_type == "eat")   type = SL_ORGAN_STOMACH;
	else if (_type == "drink") type = SL_ORGAN_LIVER;
	else return false;

	boolean canConsume(item it, boolean checkValidity)
	{
		if(checkValidity && isClipartItem(it) && !auto_is_valid($skill[summon clip art]) && !can_interact())
		{
			//workaround for this mafia bug https://kolmafia.us/threads/g-lovers-clip-art-create-function-failure.26007/
			return false;
		}
		return type == SL_ORGAN_STOMACH ? canEat(it, checkValidity) : canDrink(it, checkValidity);
	}

	boolean canConsume(item it)
	{
		return canConsume(it, true);
	}

	int organLeft()
	{
		return type == SL_ORGAN_STOMACH ? fullness_left() : inebriety_left();
	}

	int organCost(item it)
	{
		return type == SL_ORGAN_STOMACH ? it.fullness : it.inebriety;
	}

	int[item] pullables;
	int[item] small_owned;
	int[item] buyables;
	int[item] large_owned;
	int[item] craftables;

	boolean[item] blacklist = $items[Cursed Punch, Unidentified Drink];
	boolean[item] craftable_blacklist;

	// If we have 2 sticks of firewood, the current knapsack-solver
	// tries to get one of everything. So we blacklist everything other
	// than the 'campfire hot dog'
	foreach it in $items[
		campfire hot dog, campfire beans, campfire coffee, campfire stew, campfire s'more,
	]
	{
		craftable_blacklist[it] = true;
	}

	// Blacklist all but the item we can make the most of.
	// This is mostly a workaround for limitations in the knapsack solver.

	// NB: This is obviously incorrect: what if you have 2 perfect ice
	// cubes, but can only make 1 of each type of perfect drink? This
	// optimizer will make 1 of exactly 1 drink type. Oh no. Suboptimal.
	// I declare that bug Not My Problem.
	void add_mutex_craftables(boolean[item] items)
	{

		item best_it = $item[none];
		int best_amount = 0;
		foreach it in items
		{
			if (creatable_amount(it) > best_amount)
			{
				best_it = it;
				best_amount = max(0, creatable_amount(it) - auto_reserveCraftAmount(it));
			}
		}
		foreach it in items
		{
			if (it != best_it)
			{
				craftable_blacklist[it] = true;
			}
		}
	}

	add_mutex_craftables($items[perfect cosmopolitan, perfect old-fashioned, perfect mimosa, perfect dark and stormy, perfect paloma, perfect negroni]);

	boolean[item] KEY_LIME_PIES = $items[Boris's key lime pie, Jarlsberg's key lime pie, Sneaky Pete's key lime pie];

	foreach it in $items[]
	{
		if (
			!(blacklist contains it) &&
			canConsume(it) &&
			(organCost(it) > 0) &&
			(it.fullness == 0 || it.inebriety == 0) &&
			auto_is_valid(it) &&
			(historical_price(it) <= 20000 || (KEY_LIME_PIES contains it && historical_price(it) < 40000)))
		{
			if((it == $item[astral pilsner] || it == $item[Cold One] || it == $item[astral hot dog]) && my_level() < 11) continue;
			if((it == $item[Spaghetti Breakfast]) && (my_level() < 11 || my_fullness() > 0 || get_property("_spaghettiBreakfastEaten").to_boolean())) continue;

			int howmany = 1 + organLeft()/organCost(it);
			// Only one Spaghetti Breakfast can be eaten
			if(it == $item[Spaghetti Breakfast]) howmany = 1;
			if (item_amount(it) > 0 && organCost(it) <= 5)
			{
				small_owned[it] = min(max(item_amount(it) - auto_reserveAmount(it), 0), howmany);
			}
			// don't add speakeasy drinks, because they can't actually be bought as items
			if (npc_price(it) > 0 && !isSpeakeasyDrink(it))
			{
				buyables[it] = min(howmany, my_meat() / npc_price(it));
			}
			else if (buy_price($coinmaster[hermit], it) > 0)
			{
				buyables[it] += min(howmany, my_meat() / 500);
			}
			if (item_amount(it) > 0 && organCost(it) > 5)
			{
				large_owned[it] = min(max(item_amount(it) - auto_reserveAmount(it), 0), howmany);
			}
			if (!(craftable_blacklist contains it) && creatable_amount(it) > 0)
			{
				craftables[it] = min(howmany, max(0, creatable_amount(it) - auto_reserveCraftAmount(it)));
			}
			// speakeasy drinks are not available as items and will cause a crash here if not excluded.
			if (is_tradeable(it) && !isSpeakeasyDrink(it))
			{
				pullables[it] = min(howmany, pulls_remaining());
			}
			if ((KEY_LIME_PIES contains it) && !(pullables contains it) && !in_hardcore())
			{
				pullables[it] = 1;
			}
		}
	}

	boolean wantBorisPie = false;
	boolean wantJarlsbergPie = false;
	boolean wantPetePie = false;

	if (towerKeyCount() < 3 && !get_property("auto_dontConsumeKeyLimePies").to_boolean())
	{
		if(item_amount($item[Boris\'s key]) == 0 && item_amount($item[fat loot token]) < 3)
			wantBorisPie = true;
		if(item_amount($item[Jarlsberg\'s key]) == 0 && item_amount($item[fat loot token]) < 2)
			wantJarlsbergPie = true;
		if(item_amount($item[Sneaky Pete\'s key]) == 0 && item_amount($item[fat loot token]) < 1)
			wantPetePie = true;
	}

	void add(item it, int obtain_mode, int howmany)
	{
		for (int i = 0; i < howmany; i++)
		{
			int n = count(actions);
			actions[n] = MakeConsumeAction(it);
			if (obtain_mode == SL_OBTAIN_PULL)
			{
				actions[n].desirability -= 5.0;
				float user_desirability = get_property("auto_consumePullDesirability").to_float();
				if (user_desirability > 0.0)
				{
					actions[n].desirability -= user_desirability;
				}
			}
			if (type == SL_ORGAN_STOMACH && auto_is_valid($item[special seasoning]))
			{
				actions[n].desirability += min(1.0, item_amount($item[special seasoning]).to_float() * it.fullness / fullness_left());
			}
			if ((obtain_mode == SL_OBTAIN_PULL) && (i == 0) &&
					((it == $item[Boris\'s key lime pie] && wantBorisPie) ||
					(it == $item[Jarlsberg\'s key lime pie] && wantJarlsbergPie) ||
					(it == $item[Sneaky Pete\'s key lime pie] && wantPetePie)))
			{
				auto_log_info("If we pulled and ate a " + it + " we could skip getting a fat loot token...");
				actions[n].desirability += 25;
			}
			if (obtain_mode == SL_OBTAIN_NULL)
			{
				if (it == $item[Spaghetti Breakfast])
				{
					if (get_property("_spaghettiBreakfastEaten").to_boolean() || my_fullness() > 0)
					{
						actions[n].desirability -= 50;
					}
					else
					{
						auto_log_info("Spaghetti Breakfast available, we should eat that first.");
						actions[n].desirability += 50;
					}
				}
				else if ($items[blueberry muffin, bran muffin, chocolate chip muffin] contains it)
				{
					if (my_fullness() == 0 && my_level() < 13)
					{
						auto_log_info(`{it.to_string()} available, we should eat that first.`);
						actions[n].desirability += 50;
					}
				}
			}
			if (obtain_mode == SL_OBTAIN_CRAFT)
			{
				int turns_to_craft = creatable_turns(it, i + 1, false) - creatable_turns(it, i, false);
				actions[n].desirability -= turns_to_craft;
			}
			actions[n].howToGet = obtain_mode;
		}
	}

	foreach it, howmany in pullables
	{
		add(it, SL_OBTAIN_PULL, howmany);
	}
	foreach it, howmany in small_owned
	{
		add(it, SL_OBTAIN_NULL, howmany);
	}
	foreach it, howmany in buyables
	{
		add(it, SL_OBTAIN_BUY, howmany);
	}
	foreach it, howmany in large_owned
	{
		add(it, SL_OBTAIN_NULL, howmany);
	}
	foreach it, howmany in craftables
	{
		add(it, SL_OBTAIN_CRAFT, howmany);
	}

	// Now, to load cafe consumables. This has some TCRS-specific code.

	if(type == SL_ORGAN_LIVER && !gnomads_available()) return false;
	if(type == SL_ORGAN_STOMACH && !canadia_available()) return false;

	// Add daily special
	if (daily_special() != $item[none] && canConsume(daily_special(), false)) // specials are always consumable even if they would be restricted as regular consumables.
	{
		int daily_special_limit = 1 + min(my_meat()/get_property("_dailySpecialPrice").to_int(), organLeft()/organCost(daily_special()));
		for (int i=0; i < daily_special_limit; i++)
		{
			int n = count(actions);
			actions[n] = MakeConsumeAction(daily_special());
			actions[n].cafeId = daily_special().to_int();
			actions[n].it = $item[none];
		}
	}

	if(!in_tcrs())
	{
		// write in hard-coded adventure values for IPA, the best one
		if(type == SL_ORGAN_LIVER)
		{
			// Gnomish Microbrewery has a single best drink
			int limit = 1 + min(my_meat()/100, inebriety_left()/3);
			for (int i=0; i < limit; i++)
			{
				int size = 3;
				float adv = 11.0/3.0;
				actions[count(actions)] = new ConsumeAction($item[none], -3, size, adv, adv, SL_ORGAN_LIVER, SL_OBTAIN_NULL);
			}
		}
		if(type == SL_ORGAN_STOMACH)
		{
			// Chez Snootee does not have a single best food

			// Peche a la Frog
			int limit = 1 + min(my_meat()/50, fullness_left()/3);
			for (int i=0; i < limit; i++)
			{
				int size = 3;
				float adv = 3.5;
				actions[count(actions)] = new ConsumeAction($item[none], -1, size, adv, adv, SL_ORGAN_LIVER, SL_OBTAIN_NULL);
			}

			// As Jus Gezund Heit
			limit = 1 + min(my_meat()/75, fullness_left()/4);
			for (int i=0; i < limit; i++)
			{
				int size = 4;
				float adv = 5.0;
				actions[count(actions)] = new ConsumeAction($item[none], -2, size, adv, adv, SL_ORGAN_LIVER, SL_OBTAIN_NULL);
			}

			// As Jus Gezund Heit
			limit = 1 + min(my_meat()/100, fullness_left()/4);
			for (int i=0; i < limit; i++)
			{
				int size = 5;
				float adv = 7.0;
				actions[count(actions)] = new ConsumeAction($item[none], -3, size, adv, adv, SL_ORGAN_LIVER, SL_OBTAIN_NULL);
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
	if (type == SL_ORGAN_LIVER)
		filename = "TCRS_" + my_class().to_string().replace_string(" ", "_") + "_" + my_sign() + "_cafe_booze.txt";
	else if (type == SL_ORGAN_STOMACH)
		filename = "TCRS_" + my_class().to_string().replace_string(" ", "_") + "_" + my_sign() + "_cafe_food.txt";

	auto_log_info("Loading " + filename, "blue");
	if(!file_to_map(filename, cafe_stuff))
	{
		auto_log_error("Something went wrong while trying to load " + filename + ". Maybe run 'tcrs load'?", "red");
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
				int size = r.space;
				float adv = r.space * tcrs_expectedAdvPerFill(r.quality);
				actions[count(actions)] = new ConsumeAction($item[none], -3, size, adv, adv, SL_ORGAN_LIVER, SL_OBTAIN_NULL);
			}
		}
	}
	return true;
}

ConsumeAction auto_bestNightcap()
{
	ConsumeAction[int] actions;
	loadConsumables("drink", actions);

	boolean have_ode = auto_have_skill($skill[The Ode to Booze]);
	float desirability(int i)
	{
		float ret = actions[i].desirability;
		if (have_ode) ret += actions[i].size;
		return ret;
	}

	int best = 0;
	for(int i=1; i < count(actions); i++)
	{
		if(desirability(i) > desirability(best)) best = i;
	}

	return actions[best];
}

void auto_printNightcap()
{
	if(my_path() == "Dark Gyffte")
	{
		return;		//disable it for now. TODO make a custom function for vampyre nightcap drinking specifically
	}
	auto_log_info("Nightcap is: " + to_pretty_string(auto_bestNightcap()), "blue");
}

void auto_drinkNightcap()
{
	//function to overdrink a nightcap at the end of day
	if(get_property("auto_skipNightcap").to_boolean() || get_property("auto_limitConsume").to_boolean())
	{
		return;
	}
	if(my_path() == "Dark Gyffte")
	{
		return;		//disable it for now. TODO make a custom function for vampyre nightcap drinking specifically
	}
	if(!can_drink())
	{
		return;		//current path cannot drink booze at all
	}
	if(auto_freeCombatsRemaining() > 0)
	{
		return;		//do not overdrink if we still have free fights we want to do. undesireable free fights are not counted by that function
	}
	//you can't overdrink if already overdrunk. TODO account for green beer on cinco de mayo
	if(auto_have_familiar($familiar[Stooper]))
	{
		if($familiar[Stooper] == my_familiar() && inebriety_left() < 0) return;		//stooper is current familiar and overdrunk
		else if(inebriety_left() < -1) return;		//stooper not current familiar. but will be overdrunk even if switching to it
	}
	else if(inebriety_left() < 0) return;	//we can not use stooper and are overdrunk
	
	familiar start_fam = my_familiar();
	if(auto_have_familiar($familiar[Stooper]) //drinking does not break 100fam runs so do not use canChangeToFamiliar
	&& start_fam != $familiar[Stooper] && pathAllowsChangingFamiliar()) //check if path allows changing familiar
	{
		use_familiar($familiar[Stooper]);
	}
	
	//fill up remaining liver first. such as stooper space.
	while(inebriety_left() > 0 && auto_autoConsumeOne("drink", false));
	
	//drink your nightcap to become overdrunk
	ConsumeAction target = auto_bestNightcap();
	if(!autoPrepConsume(target))
	{
		abort("Unexpectedly couldn't prep " + to_pretty_string(target));
	}
	autoDrink(1, target.it, true); // added a silent flag to autoDrink to avoid the overdrink confirmation popup
	
	if(start_fam != my_familiar() && pathAllowsChangingFamiliar())	//familiar can change when crafting the drink in QT
	{
		use_familiar(start_fam);
	}
}

boolean auto_autoConsumeOne(string type, boolean simulate)
{
	int organLeft()
	{
		if (type == "eat") return fullness_left();
		if (type == "drink") 
		{
			if (in_quantumTerrarium() && my_familiar() == $familiar[Stooper])
			{
				// we can't change familiars so don't drink to full liver as we'll be overdrunk when it changes familiar.
				return (my_inebriety() < inebriety_limit() ? inebriety_left() - 1 : 0);
			}
			else
			{
				return inebriety_left();
			}
		}
		abort("Unrecognized organ type: should be 'eat' or 'drink', was " + type);
		return 0;
	}
	if (organLeft() == 0) return false;

	ConsumeAction[int] actions;
	loadConsumables(type, actions);

	int remaining_space = organLeft();

	float[int] desirability;
	int[int] space;
	for (int i=0; i<count(actions); i++)
	{
		desirability[i] = actions[i].desirability;
		space[i] = actions[i].size;
	}

	boolean[int] result = knapsack(remaining_space, count(space), space, desirability);

	float best_desirability_per_fill = 0.0;
	float best_adv_per_fill = 0.0;
	int best = -1;
	foreach i in result
	{
		float tentative_desirability_per_fill = actions[i].desirability/actions[i].size;
		if (tentative_desirability_per_fill > best_desirability_per_fill)
		{
			best_desirability_per_fill = tentative_desirability_per_fill;
			best_adv_per_fill = actions[i].adventures/actions[i].size;
			best = i;
		}
	}

	if (best == -1)
	{
		auto_log_info("auto_autoConsumeOne: Nothing found to consume", "blue");
		return false;
	}

	auto_log_info("auto_autoConsumeOne: Planning to execute " + type + " " + to_pretty_string(actions[best]), "blue");
	if (best_adv_per_fill < get_property("auto_consumeMinAdvPerFill").to_float())
	{
		auto_log_warning("auto_autoConsumeOne: Will not consume, min adventures per full " + best_adv_per_fill + " is less than auto_consumeMinAdvPerFill " + get_property("auto_consumeMinAdvPerFill"));
		return false;
	}

	if(!simulate)
	{
		if (!autoPrepConsume(actions[best])) return false;
		return autoConsume(actions[best]);
	}
	else
	{
		return true;
	}
}

boolean auto_knapsackAutoConsume(string type, boolean simulate)
{
	// TODO: does not consider mime army shotglass

	if(in_zelda())
	{
		auto_log_warning("Skipping eating, you'll have to do this manually.", "red");
		return false;
	}

	int organLeft()
	{
		if (type == "eat") return fullness_left();
		if (type == "drink") return inebriety_left();
		abort("Unrecognized organ type: should be 'eat' or 'drink', was " + type);
		return 0;
	}
	if (organLeft() == 0) return false;

	ConsumeAction[int] actions;
	loadConsumables(type, actions);

	// Non-pulled, non-cafe consumables
	int[item] normal_consumables;

	int remaining_space = organLeft();

	float[int] desirability;
	int[int] space;
	for (int i=0; i<count(actions); i++)
	{
		desirability[i] = actions[i].desirability;
		space[i] = actions[i].size;
	}

	boolean[int] result = knapsack(remaining_space, count(space), space, desirability);

	string organ_name = (type == "eat") ? "fullness" : "inebriety";
	auto_log_info("Knapsack " + type + " plan for " + remaining_space + " " + organ_name + ":", "blue");
	float total_adv = 0.0;
	int consumable_count = 0;
	int sum_space = 0;
	foreach i in result
	{
		string name = consumable_name(actions[i]);
		if (actions[i].it != $item[none] && actions[i].howToGet != SL_OBTAIN_PULL)
		{
			normal_consumables[actions[i].it] += 1;
		}
		consumable_count++;
		sum_space += actions[i].size;
		auto_log_info(to_pretty_string(actions[i]), "blue");
		total_adv += actions[i].adventures;
	}
	if (type == "eat")
	{
		int applicable_seasoning = min(item_amount($item[special seasoning]), consumable_count);
		auto_log_info("(+" + applicable_seasoning + " from special seasoning ("+ item_amount($item[special seasoning]) + " available)", "blue");
		total_adv += applicable_seasoning;
	}
	if (type == "eat")
	{
		// TODO: and can obtain milk of magnesium? It's just logging...
		auto_log_info("(+" + 5 + " from Milk of Magnesium)", "blue");
		total_adv += 5;
	}
	if (type == "drink" && auto_have_skill($skill[The Ode to Booze]))
	{
		auto_log_info("(+" + sum_space + " from Ode to Booze)", "blue");
		total_adv += sum_space;
	}
	auto_log_info("For a total of: " + total_adv + " adventures.", "blue");

	if(count(result) == 0)
	{
		auto_log_warning("Couldn't find a way of finishing off our " + type + " space exactly.", "red");
		return false;
	}

	if(!canSimultaneouslyAcquire(normal_consumables))
	{
		auto_log_warning("It looks like I can't simultaneously get everything that I want to " + type + ". I'll wait and see if I get unconfused - otherwise, please " + type + " manually.", "red");
		return false;
	}

	if(simulate) return true;

	// Craft everything before getting Milk of Magnesium, since
	// we might be using non-free crafting turns.
	foreach i in result
	{
		if (!autoPrepConsume(actions[i]))
		{
			abort("Unexpectedly couldn't prep " + to_debug_string(actions[i]));
		}
	}

	if(type == "eat")
	{
		acquireMilkOfMagnesiumIfUnused(true);
		consumeMilkOfMagnesiumIfUnused();
	}

	int pre_adventures = my_adventures();

	auto_log_info("Consuming " + count(result) + " things...", "blue");
	foreach i in result
	{
		autoConsume(actions[i]);
	}

	auto_log_info("Expected " + total_adv + " adventures, got " + (my_adventures() - pre_adventures), "blue");
	return true;
}

boolean auto_breakfastCounterVisit() {
	if (item_amount($item[earthenware muffin tin]) > 0 ||
	    (!get_property("_muffinOrderedToday").to_boolean() && 
			$items[blueberry muffin, bran muffin, chocolate chip muffin, earthenware muffin tin] contains get_property("muffinOnOrder").to_item())) {
		auto_log_info("Going to the breakfast counter to grab/order a breakfast muffin.");
		visit_url("place.php?whichplace=monorail&action=monorail_downtown");
		run_choice(7); // Visit the Breakfast Counter
		if (get_property("muffinOnOrder") != "" && item_amount(get_property("muffinOnOrder").to_item()) > 0)
		{
			// workaround mafia not clearing the property occasionally
			// see https://kolmafia.us/threads/ordering-a-muffin-at-the-breakfast-counter-doesnt-always-set-the-muffinonorder-property.26072/
			set_property("muffinOnOrder", "");
		}
		if (!get_property("_muffinOrderedToday").to_boolean() && item_amount($item[earthenware muffin tin]) > 0) {
			auto_log_info("Ordering a bran muffin for tomorrow to keep you regular.");
			run_choice(2); // Order a bran muffin
		}
		run_choice(1); // Back to the Platform!
		run_choice(8); // Nevermind
	}
	return false; // not adventuring, no need to restart doTasks loop.
}

item still_targetToOrigin(item target)
{
	//Nash Crosby's Still can convert Origin item into Target item. This function takes a target and tells us which origin it needs.
	static item[item] originNeeded = {
	$item[bottle of Calcutta Emerald]:		$item[bottle of gin],
	$item[bottle of Lieutenant Freeman]:	$item[bottle of rum],
	$item[bottle of Jorge Sinsonte]:		$item[bottle of tequila],
	$item[bottle of Definit]:				$item[bottle of vodka],
	$item[bottle of Domesticated Turkey]:	$item[bottle of whiskey],
	$item[boxed champagne]:					$item[boxed wine],
	$item[bottle of Pete\'s Sake]:			$item[bottle of sake],
	$item[bottle of Ooze-O]:				$item[bottle of sewage schnapps],
	$item[tangerine]:						$item[grapefruit],
	$item[kiwi]:							$item[lemon],
	$item[cocktail onion]:					$item[olive],
	$item[kumquat]:							$item[orange],
	$item[raspberry]:						$item[strawberry],
	$item[tonic water]:						$item[soda water]
	};
	if(originNeeded contains target)
	{
		return originNeeded[target];
	}
	else
	{
		auto_log_debug("still_targetToOrigin failed to lookup the item [" +target+ "]");
	}
	return $item[none];
}

boolean stillReachable()
{
	//can we reach Nash Crosby's Still.
	//stills_available() insufficient. it returns 0 if your class can not unlock still and 10 if your class can unlock it but did not.
	if(my_class() == $class[Avatar of Sneaky Pete])
	{
		return true;
	}
	return guild_store_available() && $classes[Accordion Thief, Disco Bandit] contains my_class();
}

boolean distill(item target)
{
	//use Nash Crosby's Still to create target
	auto_log_debug("distill(item target) called to create [" +target+ "]");
	if(!stillReachable())
	{
		auto_log_warning("distill(item target) tried to create [" +target+ "] but Nash Crosby's Still is not reachable");
		return false;
	}
	if(stills_available() == 0)
	{
		auto_log_warning("distill(item target) tried to create [" +target+ "] but Nash Crosby's Still is out of uses");
		return false;
	}
	int start_amount = item_amount(target);
	create(1, target);			//use the still to create target
	if(start_amount + 1 == item_amount(target))
	{
		return true;
	}
	auto_log_warning("distill(item target) mysteriously failed to create [" +target+ "]");
	return false;
}
