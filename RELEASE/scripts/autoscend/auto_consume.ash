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

	equipStatgainIncreasersFor(toDrink);

	item it = equipped_item($slot[Acc3]);
	if((it != $item[Mafia Pinky Ring]) && (item_amount($item[Mafia Pinky Ring]) > 0) && ($items[Bucket of Wine, Psychotic Train Wine, Sacramento Wine, Stale Cheer Wine] contains toDrink) && can_equip($item[Mafia Pinky Ring]))
	{
		equip($slot[Acc3], $item[Mafia Pinky Ring]);
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

	equipStatgainIncreasersFor(id.to_item());

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

	equipStatgainIncreasersFor(id.to_item());

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

	equipStatgainIncreasersFor(toChew);

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

	equipStatgainIncreasersFor(toEat);

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
	boolean wasReadyToEat = false;
	while(howMany > 0)
	{
		buffMaintain($effect[Song of the Glorious Lunch], 10, 1, toEat.fullness);
		if((auto_get_campground() contains $item[Portable Mayo Clinic]) && (my_meat() > 11000) && (get_property("mayoInMouth") == "") && auto_is_valid($item[Portable Mayo Clinic]))
		{
			buyUpTo(1, $item[Mayoflex], 1000);
			use(1, $item[Mayoflex]);
		}
		if(have_effect($effect[Ready to Eat]) > 0)
		{
			wasReadyToEat = true;
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
			if(wasReadyToEat && have_effect($effect[Ready to Eat]) <= 0)
			{
				handleTracker(toEat,"Red Rocketed!", "auto_eaten");
				wasReadyToEat = false;
			}
			else
			{
				handleTracker(toEat, "auto_eaten");
			}		
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
	if(get_property("_milkOfMagnesiumUsed").to_boolean() || get_property("milkOfMagnesiumActive").to_boolean())
	{
		return true;
	}
	if(fullness_limit() == 0)
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
			else if(freeCrafts() > 0)
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
	if(get_property("_milkOfMagnesiumUsed").to_boolean() || get_property("milkOfMagnesiumActive").to_boolean() || item_amount($item[Milk Of Magnesium]) < 1)
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
	if(is_jarlsberg() && toDrink != $item[Steel Margarita])
	{
		return contains_text(craft_type(toDrink), "Jarlsberg's Kitchen");
	}
	if(in_nuclear() && (toDrink.inebriety != 1))
	{
		return false;
	}
	if(in_darkGyffte() != ($items[vampagne, dusty bottle of blood, Red Russian, mulled blood, bottle of Sanguiovese] contains toDrink))
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
	if(in_lta())
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
	if(is_jarlsberg())
	{
		return contains_text(craft_type(toEat), "Jarlsberg's Kitchen");
	}
	if(in_nuclear() && (toEat.fullness != 1))
	{
		return false;
	}
	if(in_darkGyffte() && (toEat == $item[magical sausage]))
	{
		// the one thing you can eat as Vampyre AND other classes
		return true;
	}
	if(in_darkGyffte() != ($items[blood-soaked sponge cake, blood roll-up, blood snowcone, actual blood sausage, bloodstick] contains toEat))
	{
		return false;
	}
	if(in_zombieSlayer())
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

float consumptionProgress()
{
	// returns indicative ratio of adventure organs used
	
	// if not allowed to consume then consider maximum progress is already reached
	if (get_property("auto_limitConsume").to_boolean())
	{
		return 1;
	}
	
	int organs_used;
	int organs_max;
	
	if (can_eat())
	{
		organs_used += my_fullness();
		organs_max += fullness_limit();
	}
	if (can_drink())
	{
		organs_used += my_inebriety();
		organs_max += inebriety_limit();
	}
	
	// don't consider spleen as a significant adventure organ in most paths
	if (isActuallyEd() || my_path() == "Oxygenarian")
	{
		organs_used += my_spleen_use();
		organs_max += spleen_limit();
	}
	// if(my_path() == "Community Service"), autoscend does try to use spleen for adventures but also for buffs
	// if(my_path() == "Avatar of Sneaky Pete"), autoscend doesn't try to use molotov soda or create Hate to produce them
	
	if (organs_max == 0)
	{
		return 1;
	}
	else
	{
		float used_organ_ratio = min(organs_used.to_float() / organs_max.to_float(), 1);
		return used_organ_ratio;
	}
}

void consumeStuff()
{
	if (auto_haveKramcoSausageOMatic())
	{
		auto_sausageWanted();
	}

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
	if(in_community())
	{
		cs_eat_spleen();
		return;
	}
	if(in_kolhs())
	{
		kolhs_consume();
		return;
	}
	if(in_robot())
	{
		robot_get_adv();
		return;
	}

	// fills up spleen for Ed.
	if (ed_eatStuff())
	{
		return;
	}

	boolean edSpleenCheck = (isActuallyEd() && my_level() < 11 && spleen_left() > 0); // Ed should fill spleen first
	
	if (my_adventures() < 10 && fullness_left() > 0 && is_boris())
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
			if (shouldDrink && auto_autoConsumeOne("drink"))
			{
				return;
			}
		}
		if (fullness_left() > 0)
		{
			if (auto_autoConsumeOne("eat"))
			{
				return;
			}
		}
	}
	
	//if stomach and liver are full and out of adv then chew size 4 iotm derivative spleen items that give 1.875 adv/size.
	if (auto_chewAdventures())
	{
		return;
	}
}


int AUTO_ORGAN_STOMACH = 1;
int AUTO_ORGAN_LIVER   = 2;

int AUTO_OBTAIN_NULL  = 100;
int AUTO_OBTAIN_CRAFT = 101;
int AUTO_OBTAIN_PULL  = 102;
int AUTO_OBTAIN_BUY   = 103;

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

	int organ;          // AUTO_ORGAN_*
	int howToGet;       // AUTO_OBTAIN_*
};

string consumable_name(ConsumeAction action)
{
	string name = "<name not found>";
	if (action.it != $item[none]) name = to_string(action.it);
	else if (action.organ == AUTO_ORGAN_LIVER) name = cafeDrinkName(action.cafeId);
	else if (action.organ == AUTO_ORGAN_STOMACH) name = cafeFoodName(action.cafeId);
	return name;
}

string to_pretty_string(ConsumeAction action)
{
	string organ_name = action.organ == AUTO_ORGAN_STOMACH ? "fullness" : "inebriety";
	string logline = consumable_name(action) + " for " + action.adventures + " base adv (" + action.size + " " + organ_name + ")";
	if (action.howToGet == AUTO_OBTAIN_PULL)
	{
		logline += " [PULL]";
	}
	if (action.howToGet == AUTO_OBTAIN_CRAFT)
	{
		logline += " [CRAFT]";
	}
	if (action.howToGet == AUTO_OBTAIN_BUY)
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
	int organ = it.inebriety > 0 ? AUTO_ORGAN_LIVER : AUTO_ORGAN_STOMACH;
	int size = max(it.inebriety, it.fullness);
	float adv = expectedAdventuresFrom(it);
	return new ConsumeAction(it, 0, size, adv, adv, organ, AUTO_OBTAIN_NULL);
}

boolean autoPrepConsume(ConsumeAction action)
{
	auto_log_info(to_debug_string(action));
	if(action.howToGet == AUTO_OBTAIN_PULL)
	{
		auto_log_info("autoPrepConsume: Pulling a " + action.it, "blue");
		action.howToGet = AUTO_OBTAIN_NULL;
		return pullXWhenHaveY(action.it, 1, item_amount(action.it));
	}
	else if(action.howToGet == AUTO_OBTAIN_CRAFT)
	{
		auto_log_info("autoPrepConsume: Crafting a " + action.it, "blue");
		action.howToGet = AUTO_OBTAIN_NULL;
		return create(1, action.it);
	}
	else if(action.howToGet == AUTO_OBTAIN_BUY)
	{
		auto_log_info("autoPrepConsume: Buying a " + action.it, "blue");
		action.howToGet = AUTO_OBTAIN_NULL;
		return buy(1, action.it);
	}
	else if (action.howToGet == AUTO_OBTAIN_NULL)
	{
		auto_log_info("autoPrepConsume: Doing nothing to get a " + action.it, "blue");
	}
	return true;
}

boolean autoConsume(ConsumeAction action)
{
	if (action.howToGet != AUTO_OBTAIN_NULL)
	{
		abort("ConsumeAction not prepped: " + to_debug_string(action));
	}

	if (action.organ == AUTO_ORGAN_LIVER)
	{
		buffMaintain($effect[Ode to Booze], 20, 1, action.size);
	}
	if(action.cafeId != 0)
	{
		if (action.organ == AUTO_ORGAN_LIVER)
		{
			return autoDrinkCafe(1, action.cafeId);
		}
		else if (action.organ == AUTO_ORGAN_STOMACH)
		{
			return autoEatCafe(1, action.cafeId);
		}
	}
	else if(action.it != $item[none])
	{
		if (action.organ == AUTO_ORGAN_LIVER)
		{
			return autoDrink(1, action.it);
		}
		else if (action.organ == AUTO_ORGAN_STOMACH)
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
	if(in_darkGyffte())
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
	if (_type == "eat")   type = AUTO_ORGAN_STOMACH;
	else if (_type == "drink") type = AUTO_ORGAN_LIVER;
	else return false;

	boolean canConsume(item it, boolean checkValidity)
	{
		if(checkValidity && isClipartItem(it) && !auto_is_valid($skill[summon clip art]) && !can_interact())
		{
			//workaround for this mafia bug https://kolmafia.us/threads/g-lovers-clip-art-create-function-failure.26007/
			return false;
		}
		return type == AUTO_ORGAN_STOMACH ? canEat(it, checkValidity) : canDrink(it, checkValidity);
	}

	boolean canConsume(item it)
	{
		return canConsume(it, true);
	}

	int organLeft()
	{
		return type == AUTO_ORGAN_STOMACH ? fullness_left() : inebriety_left();
	}

	int organCost(item it)
	{
		return type == AUTO_ORGAN_STOMACH ? it.fullness : it.inebriety;
	}

	int[item] pullables;
	int[item] small_owned;
	int[item] buyables;
	int[item] large_owned;
	int[item] craftables;

	boolean[item] blacklist = $items[Cursed Punch, Unidentified Drink, FantasyRealm turkey leg, FantasyRealm mead];
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

	foreach it in $items[]
	{
		if (
			!(blacklist contains it) &&
			canConsume(it) &&
			(organCost(it) > 0) &&
			(it.fullness == 0 || it.inebriety == 0) &&
			auto_is_valid(it))
		{
			boolean value_allowed = (historical_price(it) < get_property("autoBuyPriceLimit").to_int()) ||
									($items[blueberry muffin, bran muffin, chocolate chip muffin] contains it && item_amount(it) > 0 && //muffins are expensive but renewable
									my_path() != "Grey You"); //Grey You should not even get to here if ever supported but it consumes the tin so blocked just in case
									
			if(!value_allowed)	continue;
			if((it == $item[astral pilsner] || it == $item[Cold One] || it == $item[astral hot dog]) && my_level() < 11) continue;
			if((it == $item[Spaghetti Breakfast]) && (my_level() < 11 || my_fullness() > 0 || get_property("_spaghettiBreakfastEaten").to_boolean())) continue;

			int howmany = (it.inebriety > 0) ? 1 : 0;	//can consider a drink action past inebriety limit. but not food past fullness limit
			howmany += organLeft()/organCost(it);
			if(howmany < 1)	continue;
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
			if (is_tradeable(it) && !isSpeakeasyDrink(it) && canPull(it))
			{
				if(!can_interact())
				{
					pullables[it] = 1;
				}
				else
				{	//pullable amount here was coded before the change to daily limit of 1 pull each
					//now pulling more than 1 is only possible out of ronin. is storage ever not completely pulled already in this case?
					pullables[it] = min(howmany, pulls_remaining());
				}
			}
		}
	}

	float keyLimePieDesirabilityBonus;
	string keyLimePieDesirabilityBonusType;
	boolean wantBorisPie = false;
	boolean wantJarlsbergPie = false;
	boolean wantPetePie = false;
	int missingHeroKeys = 3 - towerKeyCount();
	int keysObtainableWithoutPie;
	int keysObtainableFromDailyDungeon;
	int dailyDungeonTurnEstimate;
	int keyObtainableFromFR;
	int fantasyRealmTurnEstimate;

	if (missingHeroKeys > 0 && !get_property("auto_dontConsumeKeyLimePies").to_boolean())
	{
		//will add desirability to consumption and pulling of key lime pies
		void considerNextPie()
		{
			//missing at least 1 key/token, in case it will be only one first consider mainstat pie if possible
			if(my_primestat() == $stat[muscle] && item_amount($item[Boris\'s key]) == 0)
				wantBorisPie = true;
			else if(my_primestat() == $stat[mysticality] && item_amount($item[Jarlsberg\'s key]) == 0)
				wantJarlsbergPie = true;
			else if(!wantPetePie && item_amount($item[Sneaky Pete\'s key]) == 0)
				wantPetePie = true;
			else if(!wantJarlsbergPie && item_amount($item[Jarlsberg\'s key]) == 0)
				wantJarlsbergPie = true;
			else if(!wantBorisPie && item_amount($item[Boris\'s key]) == 0)
				wantBorisPie = true;
		}
		for (int i=0; i<missingHeroKeys; i++)
		{
			considerNextPie();
		}
		
		//estimate cost of obtaining keys
		keysObtainableFromDailyDungeon = get_property("dailyDungeonDone").to_boolean() ? 0 : 1;
		if(keysObtainableFromDailyDungeon > 0)
		{
			if((item_amount($item[Daily Dungeon Malware]) > 0) && !get_property("_dailyDungeonMalwareUsed").to_boolean() && (get_property("_lastDailyDungeonRoom").to_int() < 14) && (!in_pokefam()))
			{
				keysObtainableFromDailyDungeon += 1;
			}
			dailyDungeonTurnEstimate = estimateDailyDungeonAdvNeeded();
		}
		if(fantasyRealmAvailable())
		{
			keyObtainableFromFR = 1;
			fantasyRealmTurnEstimate = 5;
			if(contains_text(get_property("_frMonstersKilled"), "fantasy bandit"))
			{
				foreach idx, it in split_string(get_property("_frMonstersKilled"), ",")
				{
					if(contains_text(it, "fantasy bandit"))
					{
						int count = to_int(split_string(it, ":")[1]);
						if(count >= 5)
						{
							keyObtainableFromFR = 0;
						}
						else
						{
							fantasyRealmTurnEstimate -= count;
						}
					}
				}
			}
		}
		keysObtainableWithoutPie = keysObtainableFromDailyDungeon + keyObtainableFromFR;
		
		//bonus desirability to give to key lime pie
		if(my_daycount() > 1 && missingHeroKeys > keysObtainableWithoutPie)
		{
			keyLimePieDesirabilityBonusType = "full";
		}
		else if(missingHeroKeys == keysObtainableWithoutPie)
		{
			//all keys can be obtained today without pies so bonus value of pie is the turn cost it would otherwise take to get a key
			if(missingHeroKeys == 1)
			{
				//for only 1 key missing the bonus value of pie is the smallest turn cost to obtain a key
				keyLimePieDesirabilityBonusType = "min";
			}
			else	//missing 2 or 3 keys
			{
				if(keysObtainableFromDailyDungeon == 2)
				{
					dailyDungeonTurnEstimate = dailyDungeonTurnEstimate / 2.0;
					keyLimePieDesirabilityBonus = dailyDungeonTurnEstimate;
					if(missingHeroKeys == 3)
					{
						//only source for 3 keys is both DailyDungeon and FR so bonus value of pie is whichever source costs more turns
						keyLimePieDesirabilityBonusType = "max";
					}
				}
				else
				{
					//only source for 2 keys is both DailyDungeon and FR so bonus value of pie is whichever source costs more turns
					keyLimePieDesirabilityBonusType = "max";
				}
			}
		}
		else if(my_daycount() == 1)
		{
			//first day and not all pies can be obtained
			if(missingHeroKeys - keysObtainableWithoutPie >= 2)
			{
				//can only obtain one key a day without pie. use full desirability bonus for the first pie
				keyLimePieDesirabilityBonusType = "full";
			}
			else
			{
				//remaining keys can be obtained by tomorrow without pie so bonus value of pie is whichever source costs more turns
				keyLimePieDesirabilityBonusType = "max";
			}
		}
		
		if(keyLimePieDesirabilityBonusType == "full")
		{
			keyLimePieDesirabilityBonus = 25;		//keep existing arbitrary large bonus value
		}
		else
		{
			if(keysObtainableFromDailyDungeon > 0)
			{
				if(keyObtainableFromFR > 0)
				{
					if(keyLimePieDesirabilityBonusType == "min")
					{
						keyLimePieDesirabilityBonus = min(dailyDungeonTurnEstimate,fantasyRealmTurnEstimate);
					}
					if(keyLimePieDesirabilityBonusType == "max")
					{
						keyLimePieDesirabilityBonus = max(dailyDungeonTurnEstimate,fantasyRealmTurnEstimate);
					}
				}
				else
				{
					keyLimePieDesirabilityBonus = dailyDungeonTurnEstimate;
				}
			}
			else if(keyObtainableFromFR > 0)
			{
				keyLimePieDesirabilityBonus = fantasyRealmTurnEstimate;
			}
		}
	}

	void add(item it, int obtain_mode, int howmany)
	{
		for (int i = 0; i < howmany; i++)
		{
			int n = count(actions);
			actions[n] = MakeConsumeAction(it);
			if (obtain_mode == AUTO_OBTAIN_PULL)
			{
				actions[n].desirability -= 5.0;
				float user_desirability = get_property("auto_consumePullDesirability").to_float();
				if (user_desirability > 0.0)
				{
					actions[n].desirability = -user_desirability;
				}
			}
			if (type == AUTO_ORGAN_STOMACH && auto_is_valid($item[special seasoning]))
			{
				actions[n].desirability += min(1.0, item_amount($item[special seasoning]).to_float() * it.fullness / fullness_left());
			}
			if (obtain_mode == AUTO_OBTAIN_NULL)
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
					if (my_fullness() == 0 && my_level() < 13 && (get_property("auto_consumeMinAdvPerFill").to_float() <= actions[n].adventures/actions[n].size))
					{
						if(!in_hardcore() && my_level() >= 12 && auto_have_skill($skill[Saucemaven]))
						{
							//eating it at 12 would probably mean having to pull something smaller than a hi mein and missing out on Saucemaven?
						}
						else
						{
							auto_log_info(`{it.to_string()} available, we should eat that first.`);
							actions[n].desirability += 50;
						}
					}
				}
			}
			if (obtain_mode == AUTO_OBTAIN_CRAFT)
			{
				int turns_to_craft = creatable_turns(it, i + 1, false) - creatable_turns(it, i, false);
				actions[n].desirability -= turns_to_craft;
			}
			else
			{
				if ( (i == 0) &&
					((it == $item[Boris\'s key lime pie] && wantBorisPie) ||
					(it == $item[Jarlsberg\'s key lime pie] && wantJarlsbergPie) ||
					(it == $item[Sneaky Pete\'s key lime pie] && wantPetePie)))
				{
					auto_log_info("If we ate a " + it + " we could skip getting a fat loot token...");
					actions[n].desirability += keyLimePieDesirabilityBonus;
				}
			}
			actions[n].howToGet = obtain_mode;
		}
	}

	foreach it, howmany in pullables
	{
		add(it, AUTO_OBTAIN_PULL, howmany);
	}
	foreach it, howmany in small_owned
	{
		add(it, AUTO_OBTAIN_NULL, howmany);
	}
	foreach it, howmany in buyables
	{
		add(it, AUTO_OBTAIN_BUY, howmany);
	}
	foreach it, howmany in large_owned
	{
		add(it, AUTO_OBTAIN_NULL, howmany);
	}
	foreach it, howmany in craftables
	{
		add(it, AUTO_OBTAIN_CRAFT, howmany);
	}

	// Now, to load cafe consumables. This has some TCRS-specific code.

	if(type == AUTO_ORGAN_LIVER && !gnomads_available()) return false;
	if(type == AUTO_ORGAN_STOMACH && !canadia_available()) return false;

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
		if(type == AUTO_ORGAN_LIVER)
		{
			// Gnomish Microbrewery has a single best drink
			int limit = 1 + min(my_meat()/100, inebriety_left()/3);
			for (int i=0; i < limit; i++)
			{
				int size = 3;
				float adv = 11.0/3.0;
				actions[count(actions)] = new ConsumeAction($item[none], -3, size, adv, adv, AUTO_ORGAN_LIVER, AUTO_OBTAIN_NULL);
			}
		}
		if(type == AUTO_ORGAN_STOMACH)
		{
			// Chez Snootee does not have a single best food

			// Peche a la Frog
			int limit = 1 + min(my_meat()/50, fullness_left()/3);
			for (int i=0; i < limit; i++)
			{
				int size = 3;
				float adv = 3.5;
				actions[count(actions)] = new ConsumeAction($item[none], -1, size, adv, adv, AUTO_ORGAN_LIVER, AUTO_OBTAIN_NULL);
			}

			// As Jus Gezund Heit
			limit = 1 + min(my_meat()/75, fullness_left()/4);
			for (int i=0; i < limit; i++)
			{
				int size = 4;
				float adv = 5.0;
				actions[count(actions)] = new ConsumeAction($item[none], -2, size, adv, adv, AUTO_ORGAN_LIVER, AUTO_OBTAIN_NULL);
			}

			// As Jus Gezund Heit
			limit = 1 + min(my_meat()/100, fullness_left()/4);
			for (int i=0; i < limit; i++)
			{
				int size = 5;
				float adv = 7.0;
				actions[count(actions)] = new ConsumeAction($item[none], -3, size, adv, adv, AUTO_ORGAN_LIVER, AUTO_OBTAIN_NULL);
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
	if (type == AUTO_ORGAN_LIVER)
		filename = "TCRS_" + my_class().to_string().replace_string(" ", "_") + "_" + my_sign() + "_cafe_booze.txt";
	else if (type == AUTO_ORGAN_STOMACH)
		filename = "TCRS_" + my_class().to_string().replace_string(" ", "_") + "_" + my_sign() + "_cafe_food.txt";

	auto_log_info("Loading " + filename, "blue");
	if(!file_to_map(filename, cafe_stuff))
	{
		abort("Something went wrong while trying to load " + filename + ". Maybe run 'tcrs load'?");
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
				actions[count(actions)] = new ConsumeAction($item[none], -3, size, adv, adv, AUTO_ORGAN_LIVER, AUTO_OBTAIN_NULL);
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
	int greenBeersDrinkable;
	int greenBeerAdv;
	if(contains_text(holiday(),"St\. Sneaky Pete's Day") && gnomads_available() && daily_special() == $item[green beer])
	{
		int disposableBeerMeat = max(0,my_meat()-meatReserve());
		greenBeersDrinkable = min(ceil(10.0/$item[green beer].inebriety), disposableBeerMeat/get_property("_dailySpecialPrice").to_int());
		if (greenBeersDrinkable > 0)
		{
			auto_log_info("May pick a smaller nightcap tonight since we could balance up to " + greenBeersDrinkable + " green beers on top of it", "blue");
			greenBeerAdv = expectedAdventuresFrom($item[green beer]) + (have_ode ? $item[green beer].inebriety : 0);
		}
	}
	
	float desirability(int i)
	{
		float ret = actions[i].desirability;
		if (have_ode) ret += actions[i].size;
		if (greenBeersDrinkable > 0)
		{
			//on Sneaky Pete's Day smaller drink action leaves more space for green beers
			int greenBeerabilityBonus = greenBeerAdv * min(greenBeersDrinkable, max(0,10 - actions[i].size));
			ret += greenBeerabilityBonus;
			if(actions[i].it == $item[astral pilsner])
			{	//astral pilsner's extra advs could make it barely beat larger pulls today due to beers but would still have as much value tomorrow
				ret -= min(5,greenBeerabilityBonus);
			}
		}
		return ret;
	}

	int best = 0;
	float current_best_desirability;
	for(int i=1; i < count(actions); i++)
	{
		if(desirability(i) < current_best_desirability)
		{
			// This consumable is less desirable than the best consumable found so far
			continue;
		}

		if(desirability(i) == current_best_desirability && historical_price(actions[i].it) >= historical_price(actions[best].it))
		{
			// This consumable is just as desirable as the best consumable, but it is more expensive
			continue;
		}

		// This consumable is either more desirable or equally desirable and cheaper
		best = i;
		current_best_desirability = desirability(best);
	}

	return actions[best];
}

void auto_printNightcap()
{
	if(in_darkGyffte())
	{
		return;		//disable it for now. TODO make a custom function for vampyre nightcap drinking specifically
	}
	auto_log_info("Nightcap is: " + to_pretty_string(auto_bestNightcap()), "blue");
}

void auto_overdrinkGreenBeers()
{
	//called after nightcap, auto_drinkNightcap() needs to have already made the necessary checks
	if(!contains_text(holiday(),"St\. Sneaky Pete's Day") || !canDrink($item[green beer], false))
	{
		return;
	}
	familiar start_fam = my_familiar();
	if(auto_have_familiar($familiar[Stooper]) //drinking does not break 100fam runs so do not use canChangeToFamiliar
	&& start_fam != $familiar[Stooper] && pathAllowsChangingFamiliar()) //check if path allows changing familiar
	{
		use_familiar($familiar[Stooper]);
	}
	
	int negativeLiver = inebriety_left();
	if(negativeLiver >= -10 && negativeLiver < 0)
	{
		auto_log_info("It's St. Sneaky Pete's Day, can we sneak in any green beers?", "blue");
		
		if(gnomads_available())
		{
			if (daily_special() == $item[green beer])
			{
				ConsumeAction greenBeerAction = MakeConsumeAction(daily_special());
				greenBeerAction.cafeId = daily_special().to_int();
				greenBeerAction.it = $item[none];
				int daily_special_limit = min(my_meat()/get_property("_dailySpecialPrice").to_int(), (inebriety_left()+11)/(daily_special().inebriety));
				for (int i=0; i < daily_special_limit; i++)
				{
					autoConsume(greenBeerAction);
				}
			}
		}
		
		//TODO craft green beer?
		
		int greenbeer_limit = min(item_amount($item[green beer]), (inebriety_left()+11)/($item[green beer].inebriety));
		if(greenbeer_limit > 0)
		{
			autoDrink(greenbeer_limit, $item[green beer]);
		}
		
		if(inebriety_left() == negativeLiver)
		{
			auto_log_info("Could not overdrink any green beer", "blue");
		}
		else if(inebriety_left() >= -10)
		{
			auto_log_info("Still have " + (11 + inebriety_left()) + " green beer liver space that could not be filled", "blue");
		}
	}
	if(start_fam != my_familiar() && pathAllowsChangingFamiliar())
	{
		use_familiar(start_fam);
	}
}

void auto_drinkNightcap()
{
	//function to overdrink a nightcap at the end of day
	if(get_property("auto_skipNightcap").to_boolean() || get_property("auto_limitConsume").to_boolean())
	{
		return;
	}
	if(in_darkGyffte())
	{
		return;		//disable it for now. TODO make a custom function for vampyre nightcap drinking specifically
	}
	if(!can_drink())
	{
		return;		//current path cannot drink booze at all
	}
	if(auto_freeCombatsRemaining() > 0)
	{
		auto_log_info("Not drinking a nightcap because of " + auto_freeCombatsRemaining() + " remaining free fights", "blue");
		return;		//do not overdrink if we still have free fights we want to do. undesireable free fights are not counted by that function
	}
	boolean overdrunk()
	{
		if(auto_have_familiar($familiar[Stooper]))
		{
			if($familiar[Stooper] == my_familiar() && inebriety_left() < 0) return true;		//stooper is current familiar and overdrunk
			else if(inebriety_left() < -1) return true;		//stooper not current familiar. but will be overdrunk even if switching to it
		}
		else if(inebriety_left() < 0) return true;	//we can not use stooper and are overdrunk
		return false;
	}
	if(overdrunk())
	{
		//you can't overdrink if already overdrunk. except for green beer on cinco de mayo
		auto_overdrinkGreenBeers();
		return;
	}
	
	
	familiar start_fam = my_familiar();
	if(auto_have_familiar($familiar[Stooper]) //drinking does not break 100fam runs so do not use canChangeToFamiliar
	&& start_fam != $familiar[Stooper] && pathAllowsChangingFamiliar()) //check if path allows changing familiar
	{
		use_familiar($familiar[Stooper]);
	}
	
	if(item_amount($item[Steel Margarita]) > 0)
	{
		//LX_steelOrgan may wait to drink the Steel Margarita for Billiards, if drunkenness never went over 12 it could have been skipped
		//this should only be possible in Avatar of West of Loathing?
		boolean wontBeOverdrunk = inebriety_left() >= $item[Steel Margarita].inebriety - 5;
		if(wontBeOverdrunk)
		{
			autoDrink(1, $item[Steel Margarita]);
		}
	}
	
	//fill up remaining liver first. such as stooper space.
	while(inebriety_left() > 0 && auto_autoConsumeOne("drink"));
	
	//drink your nightcap to become overdrunk
	ConsumeAction target = auto_bestNightcap();
	if(!autoPrepConsume(target))
	{
		abort("Unexpectedly couldn't prep " + to_pretty_string(target));
	}
	autoDrink(1, target.it, true); // added a silent flag to autoDrink to avoid the overdrink confirmation popup
	
	if(overdrunk())
	{
		//another round? (green beers)
		auto_overdrinkGreenBeers();
	}
	
	if(start_fam != my_familiar() && pathAllowsChangingFamiliar())	//familiar can change when crafting the drink in QT
	{
		use_familiar(start_fam);
	}
}

ConsumeAction auto_findBestConsumeAction(string type)
{
	int organLeft()
	{
		if (type == "eat") return fullness_left();
		if (type == "drink") 
		{
			if(in_quantumTerrarium() && my_familiar() == $familiar[Stooper])
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
	if (organLeft() == 0) return MakeConsumeAction($item[none]);

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

	if(best == -1)
	{
		return MakeConsumeAction($item[none]);
	}
	else
	{
		return actions[best];
	}
}

boolean auto_autoConsumeOne(string type)
{
	
	ConsumeAction bestAction = auto_findBestConsumeAction(type);

	if (bestAction.it == $item[none] && bestAction.cafeId == 0)
	{
		auto_log_info("auto_autoConsumeOne: Nothing found to consume", "blue");
		return false;
	}

	int best_adv_per_fill = bestAction.adventures / bestAction.size;
	if($items[Boris\'s key lime pie,Jarlsberg\'s key lime pie,Sneaky Pete\'s key lime pie] contains bestAction.it)
	{
		//the turn value of key lime pie is an exception so use its desirability instead of base adventures, after cancelling any effects of obtention method
		if (bestAction.howToGet == AUTO_OBTAIN_PULL)	best_adv_per_fill = (bestAction.desirability + 5) / bestAction.size;
		else if (bestAction.howToGet == AUTO_OBTAIN_CRAFT)	best_adv_per_fill = (bestAction.desirability + 1) / bestAction.size;
		else	best_adv_per_fill = bestAction.desirability / bestAction.size;
	}
	auto_log_info("auto_autoConsumeOne: Planning to execute " + type + " " + to_pretty_string(bestAction), "blue");
	if (best_adv_per_fill < get_property("auto_consumeMinAdvPerFill").to_float())
	{
		auto_log_warning("auto_autoConsumeOne: Will not consume, min adventures per full " + best_adv_per_fill + " is less than auto_consumeMinAdvPerFill " + get_property("auto_consumeMinAdvPerFill"));
		return false;
	}

	if (!autoPrepConsume(bestAction)) 
	{
		return false;
	}
	return autoConsume(bestAction);
}

// Need separate function to simulate since return type is different
// For simulation, want to know what would be consumes instead of actually consuming it
item auto_autoConsumeOneSimulation(string type)
{
	ConsumeAction bestAction = auto_findBestConsumeAction(type);
	if(bestAction.it == $item[none]) return bestAction.cafeId.to_item();	//this can only find an existing item for daily specials
	return bestAction.it;
}

boolean auto_knapsackAutoConsume(string type, boolean simulate)
{
	// TODO: does not consider mime army shotglass

	if(in_plumber() && my_level() < 13)
	{
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
		if (actions[i].it != $item[none] && actions[i].howToGet != AUTO_OBTAIN_PULL)
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

int auto_spleenFamiliarAdvItemsPossessed() 
{
	//returns how many size 4 items from spleen familiars in possession
	
	int spleenFamiliarAdvItemsCount = 0;
	
	foreach it in $items[Unconscious Collective Dream Jar, Grim Fairy Tale, Powdered Gold, Groose Grease, beastly paste, bug paste, cosmic paste, oily paste, demonic paste, gooey paste, elemental paste, Crimbo paste, fishy paste, goblin paste, hippy paste, hobo paste, indescribably horrible paste, greasy paste, Mer-kin paste, orc paste, penguin paste, pirate paste, chlorophyll paste, slimy paste, ectoplasmic paste, strange paste, Agua De Vida]
	{
		if(item_amount(it) > 0 && auto_is_valid(it) && mall_price(it) < get_property("autoBuyPriceLimit").to_int())	//even when not mallbuying them we do not want to use exceptionally expensive items
		{
			spleenFamiliarAdvItemsCount += item_amount(it);
		}
	}
	
	return spleenFamiliarAdvItemsCount;
}

boolean auto_chewAdventures()
{
	//tries to chew a size 4 familiar spleen item that gives adventures. All are IOTM derivatives with 1.875 adv/size
	boolean liver_check = my_inebriety() < inebriety_limit() && !in_kolhs();	//kolhs has special drinking. liver often unfilled
	if(liver_check || my_fullness() < fullness_limit() || my_adventures() > 1+auto_advToReserve())
	{
		return false;	//1.875 A/S is bad. only chew if 1 adv remains
	}
	if(isActuallyEd())
	{
		return false;	//these consumables are very bad for ed, who has a path specific spleen consumable shop.
	}
	if(spleen_left() < 4)
	{
		return false;	//they are all size 4
	}
	
	item target = $item[none];
	int target_value = 0;
	
	void chooseCheapestTarget(item it)
	{
		if(item_amount(it) > 0 && auto_is_valid(it) &&
		mall_price(it) < get_property("autoBuyPriceLimit").to_int())	//do not chew very expensive items even if already in inv
		{
			if(target == $item[none] || mall_price(it) < target_value)
			{
				target = it;
				target_value = mall_price(it);
			}
		}
	}
	
	//first the ones without the level 4 requirement because they give more stats
	foreach it in $items[Unconscious Collective Dream Jar, Grim Fairy Tale, Powdered Gold, Groose Grease]
	{
		chooseCheapestTarget(it);
	}
	if(my_level() >= 4 && target == $item[none])
	{
		foreach it in $items[beastly paste, bug paste, cosmic paste, oily paste, demonic paste, gooey paste, elemental paste, Crimbo paste, fishy paste, goblin paste, hippy paste, hobo paste, indescribably horrible paste, greasy paste, Mer-kin paste, orc paste, penguin paste, pirate paste, chlorophyll paste, slimy paste, ectoplasmic paste, strange paste, Agua De Vida]
		{
			chooseCheapestTarget(it);
		}
	}
	
	int oldSpleenUse = my_spleen_use();
	if(target != $item[none])
	{
		if(!autoChew(1, target))	//the actual chewing attempt
		{
			auto_log_warning("Mysteriously failed to chew [" +target+ "]", "red");
		}
	}
	return oldSpleenUse != my_spleen_use();
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

boolean prepare_food_xp_multi()
{
	//prepare as big an XP multi as possible for the next food item eaten
	if(fullness_left() < 1 || !can_eat())
	{
		return false;
	}
	
	//[Ready to Eat] is gotten by using a red rocket from fireworks shop in VIP clan. it gives +400% XP on next food item
	if(have_fireworks_shop() &&
	have_effect($effect[Everything Looks Red]) <= 0 &&
	have_effect($effect[Ready to Eat]) <= 0 &&
	auto_is_valid($item[red rocket]))
	{
		if(item_amount($item[red rocket]) == 0 && my_meat() > npc_price($item[red rocket]))
		{
			//this is a more aggressive buying function than the one in pre_adv
			retrieve_item(1, $item[red rocket]);
		}
		if(item_amount($item[red rocket]) > 0)
		{
			return false;	//go use [red rocket] in combat before eating for XP
		}
	}
	
	//get [That's Just Cloud-Talk, Man] +25% all stats experience is already done by dailyEvents()
	
	equipStatgainIncreasers($stats[muscle,mysticality,moxie],true);
	
	pullXWhenHaveY($item[Special Seasoning], 1, 0);		//automatically consumed with food and gives extra XP
	return true;
}
