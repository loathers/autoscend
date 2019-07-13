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

boolean[int] knapsack(int maxw, int n, int[int] weight, int[int] val)
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

	boolean[int] ret;
	// backtrack
	int i = n;
	int w = maxw;
	while (i > 0 || w > 0)
	{
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

int [item] knapsack_pick_food()
{
	int[int] fullness;
	int[int] adv;
	item[int] items;

	foreach it in $items[]
	{
		if ((it.quality == "awesome" || it.quality == "EPIC") && canEat(it) && (it.fullness > 0) && is_unrestricted(it) && historical_price(it) <= 20000)
		{
			int amount = available_amount(it) + creatable_amount(it);
			int limit = min(amount, fullness_left()/it.fullness);
			for (int i=0; i<limit; i++)
			{
				int n = count(fullness);
				fullness[n] = it.fullness;
				adv[n] = expectedAdventuresFrom(it);
				items[n] = it;
			}
		}
	}
	int[item] ret;
	foreach i in knapsack(fullness_left(), count(fullness), fullness, adv)
	{
		ret[items[i]] += 1;
	}
	return ret;
}

boolean[item] knapsack_pick_drinks()
{
	int[int] inebriety;
	int[int] adv;
	item[int] items;

	foreach it in $items[]
	{
		if ((it.quality == "awesome" || it.quality == "EPIC") && canDrink(it) && (it.inebriety > 0) && is_unrestricted(it) && historical_price(it) <= 20000)
		{
			int amount = available_amount(it) + creatable_amount(it);
			int limit = min(amount, inebriety_left()/it.inebriety);
			for (int i=0; i<limit; i++)
			{
				int n = count(inebriety);
				inebriety[n] = it.inebriety;
				adv[n] = expectedAdventuresFrom(it);
				items[n] = it;
			}
		}
	}
	boolean[item] ret;
	foreach i in knapsack(inebriety_left(), count(inebriety), inebriety, adv)
	{
		ret[items[i]] = true;
	}
	return ret;
}

boolean tcrs_consumption()
{
	if(!in_tcrs())
		return false;

	if(get_property("sl_beta").to_boolean())
	{
		if((inebriety_left() > 0) && my_adventures() < 10)
		{
			// just drink, like, anything, whatever
		}
		if((fullness_left() > 0) && my_adventures() < 10)
		{
			int[item] foods = knapsack_pick_food();
			if(get_property("sl_useWishes").to_boolean() && (0 == have_effect($effect[Got Milk])))
			{
				makeGenieWish($effect[Got Milk]); // +15 adv is worth it for daycount
			}
			foreach what, howmany in foods
			{
				slEat(howmany, what);
			}
		}
	}

	if(my_class() == $class[Sauceror] && my_sign() == "Blender")
	{
		boolean canDesert = (get_property("lastDesertUnlock").to_int() == my_ascensions());
		if((inebriety_left() >= 4) && canDesert && (my_meat() >= 75))
		{
			buffMaintain($effect[Ode to Booze], 20, 1, 4);
			visit_url("cafe.php?cafeid=2");
			visit_url("cafe.php?pwd="+my_hash()+"&phash="+my_hash()+"&cafeid=2&whichitem=-2&action=CONSUME!");
			handleTracker("Scrawny Stout", "sl_drunken");
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
