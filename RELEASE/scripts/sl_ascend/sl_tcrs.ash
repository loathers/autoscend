script "sl_tcrs.ash"

boolean in_tcrs()
{
	return my_path() == "36" || my_path() == "Two Crazy Random Summer";
}

boolean tcrs_initializeSettings()
{
	if(in_tcrs())
	{
		set_property("sl_spookyfertilizer", "");
		set_property("sl_getStarKey", true);
		set_property("sl_holeinthesky", true);
		set_property("sl_wandOfNagamar", true);
	}
	return true;
}

float tcrs_expectedAdvPerFill(string quality)
{
	switch(quality)
	{
	case "EPIC":    return 5;
	case "awesome": return 4;
	case "good":    return 3;
	case "decent":  return 2;
	case "crappy":  return 1;
	default:        abort("could not calculate expected adventures for quality " + quality + " in 2CRS");
	}
	return -1; // makes the compiler shut up
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
		print("Solving a Knapsack instance with " + n + " elements and " + maxw + " total weight, this might be slow and memory-intensive.");
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
			w -= weight[i-1];
			ret[i-1] = true;
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

boolean can_simultaneously_acquire(int[item] needed)
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
			if (count(get_ingredients(toAdd)) == 0 && npc_price(toAdd) == 0 && buy_price($coinmaster[hermit], toAdd) == 0)
			{
				// not craftable
				sl_debug_print("can_simultaneously_acquire failing on " + toAdd, "red");
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

boolean tcrs_loadCafeDrinks(int[int] cafe_backmap, float[int] adv, int[int] inebriety)
{
	if(!in_tcrs()) return false;
	if(!gnomads_available()) return false;

	record _CAFE_DRINK_TYPE {
		string name;
		int inebriety;
		string quality;
	};

	_CAFE_DRINK_TYPE [int] cafe_booze;
	string filename = "TCRS_" + my_class().to_string().replace_string(" ", "_") + "_" + my_sign() + "_cafe_booze.txt";
	print("Loading " + filename, "blue");
	file_to_map(filename, cafe_booze);
	foreach i, r in cafe_booze
	{
		// Gnomish Microbrewery has item ids -1, -2, -3
		if (i >= -3 && r.inebriety > 0)
		{
			int limit = 1 + min(my_meat()/100, inebriety_left()/r.inebriety);
			for (int j=0; j<limit; j++)
			{
				int n = count(inebriety);
				inebriety[n] = r.inebriety;
				adv[n] = r.inebriety * tcrs_expectedAdvPerFill(r.quality);
				cafe_backmap[n] = i;
			}
		}
	}
	return true;
}

boolean sl_knapsackAutoEat(boolean simulate)
{
	// TODO: Doesn't yet use Canadian cafe food.

	if(fullness_left() == 0) return false;

	if (item_amount($item[van key]) > 0)
	{
		use(item_amount($item[van key]), $item[van key]);
	}

	int[int] fullness;
	float[int] adv;

	// Since backtracking prioritizes the first elements in the input array,
	// we put small owned items, then buyables, then large owned, then craftables
	int[item] small_owned;
	int[item] buyables;
	int[item] large_owned;
	int[item] craftables;

	foreach it in $items[]
	{
		if ((it.quality == "awesome" || it.quality == "EPIC") && canEat(it) && (it.fullness > 0) && is_unrestricted(it) && historical_price(it) <= 20000)
		{
			int howmany = 1 + fullness_left()/it.fullness;
			if (item_amount(it) > 0 && it.fullness <= 5)
			{
				small_owned[it] = min(item_amount(it), howmany);
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
			if (item_amount(it) > 0 && it.fullness > 5)
			{
				large_owned[it] = min(item_amount(it), howmany);
			}
			if (creatable_amount(it) > 0)
			{
				howmany = min(howmany, creatable_amount(it));
				craftables[it] = howmany;
			}
		}
	}

	item[int] item_backmap;
	void add(item it, boolean crafting, int howmany)
	{
		for (int i = 0; i < howmany; i++)
		{
			int n = count(fullness);
			fullness[n] = it.fullness;
			adv[n] = expectedAdventuresFrom(it);
			adv[n] += min(1.0, item_amount($item[special seasoning]) * it.fullness / fullness_left());
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

	int[item] foods;
	float total_adv = 0.0;
	int total_foods = 0;
	print("Knapsack food plan:", "blue");
	foreach i in knapsack(fullness_left(), count(fullness), fullness, adv)
	{
		foods[item_backmap[i]] += 1;
		string name = item_backmap[i];
		print(adv[i] + " adventures from " + name + "(" + fullness[i] + " fullness)", "blue");
		total_adv += expectedAdventuresFrom(item_backmap[i]);
		total_foods += 1;
	}
	print("+" + min(item_amount($item[special seasoning]), total_foods) + " from special seasoning ("+ item_amount($item[special seasoning]) + " available)", "blue");
	total_adv += min(item_amount($item[special seasoning]), total_foods);
	print("For a total of: " + total_adv + " adventures.", "blue");

	if(count(foods) == 0)
	{
		print("Couldn't find a way of finishing off our stomach space exactly.", "red");
		return false;
	}

	if(!can_simultaneously_acquire(foods))
	{
		print("Looks like I can't simultaneously acquire all of those items. I'm a bit confused. I'll wait and see if I get unconfused - otherwise, please eat manually.", "red");
		return false;
	}

	if(simulate) return true;

	if (count(foods) > 0)
	{
		foreach what, howmany in foods
		{
			retrieve_item(howmany, what);
		}
		if (in_tcrs() && get_property("sl_useWishes").to_boolean() && (0 == have_effect($effect[Got Milk])))
		{
			// +15 adv is worth it for daycount
			// TODO: Some folks have requested a setting to turn this off.
			makeGenieWish($effect[Got Milk]);
		}
		else dealwithMilkOfMagnesium(true);

		foreach what, howmany in foods
		{
			slEat(howmany, what);
		}
		return true;
	}
	return false;
}

boolean loadDrinks(item[int] item_backmap, float[int] adv, int[int] inebriety)
{
	int[item] small_owned;
	int[item] buyables;
	int[item] large_owned;
	int[item] craftables;

	foreach it in $items[]
	{
		if ((it.quality == "awesome" || it.quality == "EPIC") && canEat(it) && (it.inebriety > 0) && is_unrestricted(it) && historical_price(it) <= 20000)
		{
			int howmany = 1 + inebriety_left()/it.inebriety;
			if (item_amount(it) > 0 && it.inebriety <= 5)
			{
				small_owned[it] = min(item_amount(it), howmany);
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
			if (item_amount(it) > 0 && it.inebriety > 5)
			{
				large_owned[it] = min(item_amount(it), howmany);
			}
			if (creatable_amount(it) > 0)
			{
				howmany = min(howmany, creatable_amount(it));
				craftables[it] = howmany;
			}
		}
	}

	void add(item it, boolean crafting, int howmany)
	{
		for (int i = 0; i < howmany; i++)
		{
			int n = count(inebriety);
			inebriety[n] = it.inebriety;
			adv[n] = expectedAdventuresFrom(it);
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
	return true;
}

item sl_bestNightcap()
{
	int[int] inebriety;
	float[int] adv;
	item[int] item_backmap;

	loadDrinks(item_backmap, adv, inebriety);

	int best = 0;
	int n = count(item_backmap);
	for (int i=1; i < n; i++)
	{
		if (adv[i] + inebriety[i] > adv[best] + inebriety[i]) best = i;
	}
	return item_backmap[best];
}

boolean sl_knapsackAutoDrink(boolean simulate)
{
	// TODO: does not consider mime army shotglass
	if (inebriety_left() == 0) return false;

	if (item_amount($item[unremarkable duffel bag]) > 0)
	{
		use(item_amount($item[unremarkable duffel bag]), $item[unremarkable duffel bag]);
	}

	int[int] inebriety;
	float[int] adv;

	int [int] cafe_backmap;
	tcrs_loadCafeDrinks(cafe_backmap, adv, inebriety);

	item[int] item_backmap;
	loadDrinks(item_backmap, adv, inebriety);

	int[item] normal_drinks;
	int[int] cafe_drinks;

	int liver_space = inebriety_left();
	boolean saving_for_stooper = sl_have_familiar($familiar[Stooper]) && my_familiar() != $familiar[Stooper];
	if (saving_for_stooper)
	{
		liver_space += 1;
	}

	boolean[int] result = knapsack(liver_space, count(inebriety), inebriety, adv);
	print("Knapsack drink plan:", "blue");
	float total_adv = 0.0;
	foreach i in result
	{
		string name;
		if (cafe_backmap contains i)
		{
			name = cafeDrinkName(cafe_backmap[i]);
			cafe_drinks[cafe_backmap[i]] += 1;
		}
		else
		{
			name = to_string(item_backmap[i]);
			normal_drinks[item_backmap[i]] += 1;
		}
		print(adv[i] + " adventures from " + name + "(" + inebriety[i] + " inebriety)", "blue");
		total_adv += adv[i];
	}
	foreach it, amt in normal_drinks
	{
		print(amt * expectedAdventuresFrom(it) + " adventures from " + amt + "x " + it + "(" + amt + " * " + it.inebriety + " inebriety)", "blue");
		total_adv += amt * expectedAdventuresFrom(it);
	}
	print("For a total of: " + total_adv + " adventures.", "blue");

	if(count(result) == 0)
	{
		print("Couldn't find a way of finishing off our liver space exactly.", "red");
		return false;
	}

	if(!can_simultaneously_acquire(normal_drinks))
	{
		print("It looks like I can't simultaneously get everything that I want to drink. I'll wait and see if I get unconfused - otherwise, please drink manually.", "red");
		return false;
	}

	if(simulate) return true;

	foreach i in result
	{
		if(inebriety[i] >= inebriety_left() && !get_property("_sl_saving_for_stooper").to_boolean())
		{
			print("Leaving some liver space left for Stooper...");
			set_property("_sl_saving_for_stooper", true);
			break;
		}

		if (cafe_backmap contains i)
		{
			int what = cafe_backmap[i];
			buffMaintain($effect[Ode to Booze], 20, 1, inebriety_left());
			slDrinkCafe(1, what);
		}
		else
		{
			item what = item_backmap[i];
			retrieve_item(1, what);
			slDrink(1, what);
		}
	}
	return true;
}

boolean sl_autoDrinkOne(boolean simulate)
{
	if (inebriety_left() == 0) return false;

	int[int] inebriety;
	float[int] adv;

	int [int] cafe_backmap;
	tcrs_loadCafeDrinks(cafe_backmap, adv, inebriety);

	item[int] item_backmap;
	loadDrinks(item_backmap, adv, inebriety);

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
			buffMaintain($effect[Ode to Booze], 20, 1, inebriety[best_index]);
			return slDrinkCafe(1, cafe_backmap[best_index]);
		}
		else
		{
			return slDrink(1, item_backmap[best_index]);
		}
	}
	else
	{
		string name = (cafe_backmap contains best_index) ? cafeDrinkName(cafe_backmap[best_index]) : item_backmap[best_index];
		print("Would have drunk a " + name + " for " + adv[best_index] + " adventures and " + inebriety[best_index] + "inebriety.", "blue");
		return true;
	}
}

boolean tcrs_consumption()
{
	if(!in_tcrs())
		return false;

	if(sl_beta() && my_adventures() < 5)
	{
		if(my_inebriety() < 8 && inebriety_left() > 0)
		{
			// just drink, like, anything, whatever
			// find the best and biggest thing we can and drink it
			sl_autoDrinkOne(false);
			return true;
		}
		if(inebriety_left() > 0 && !get_property("_sl_saving_for_stooper").to_boolean())
		{
			sl_knapsackAutoDrink(false);
			return true;
		}
		if(fullness_left() > 0)
		{
			sl_knapsackAutoEat(false);
			return true;
		}
		if(my_adventures() <= 1 && inebriety_left() > 0 && get_property("_sl_saving_for_stooper").to_boolean())
		{
			use_familiar($familiar[Stooper]);
			sl_knapsackAutoDrink(false);
			return true;
		}
	}

	if (sl_beta()) return true;

	if(my_class() == $class[Sauceror] && my_sign() == "Blender")
	{
		boolean canDesert = (get_property("lastDesertUnlock").to_int() == my_ascensions());
		if((inebriety_left() >= 4) && canDesert && (my_meat() >= 75))
		{
			buffMaintain($effect[Ode to Booze], 20, 1, 4);
			slDrinkCafe(1, -2); // Scrawny Stout;
		}
		if((my_adventures() <= 1) && (inebriety_left() == 3) && (my_meat() >= npc_price($item[used beer])))
		{
			buyUpTo(1, $item[used beer]);
			slDrink(1, $item[used beer]);
		}
		if((my_adventures() <= 1 || item_amount($item[glass of goat's milk]) > 0) && fullness_left() == 15)
		{
			if(get_property("sl_useWishes").to_boolean() && (0 == have_effect($effect[Got Milk])))
			{
				makeGenieWish($effect[Got Milk]); // +15 adv is worth it for daycount
			}
			buy(1, $item[fortune cookie]);
			buy(6, $item[pickled egg]);
			slEat(1, $item[fortune cookie]);
			slEat(6, $item[pickled egg]);
			if(item_amount($item[glass of goat's milk]) > 0)
			{
				slEat(1, $item[glass of goat's milk]);
			}
			else	 // 1 adventure left, better than wasting the Milk charge?
			{
				acquireHermitItem($item[Ketchup]);
				slEat(1, $item[Ketchup]);
			}
		}
	}
	else
	{
		print("Not eating or drinking anything, since we don't know what's good...");
	}
	return true;
}

boolean tcrs_maximize_with_items(string maximizerString)
{
	if (!in_tcrs()) return false;

	/* In TCRS, items give random effects. Instead of hard-coding a list of
	 * effects for each path/class combination, we look at what we got.
	 */
	boolean used_anything = false;
	foreach i, rec in maximize(maximizerString, 300, 0, true, false)
	{
		if((rec.item != $item[none])
		&& (rec.item.fullness == 0)
		&& (rec.item.inebriety == 0)
		&& (0 == have_effect(rec.effect))
		&& (mall_price(rec.item) <= 300)
		&& (rec.score > 0.1)) // sometimes maximizer gives spurious results
		{
			cli_execute(rec.command);
			used_anything = true;
		}
	}
	return used_anything;
}
