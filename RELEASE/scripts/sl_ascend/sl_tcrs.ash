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

boolean tcrs_consumption()
{
	if(!in_tcrs())
		return false;

	if(get_property("sl_legacyConsumeStuff").to_boolean())
	{
		// print("Using a hard-coded consumption strategy for TCRS. 'set sl_legacyConsumeStuff=false' to use the new, cool automatic consumption strategy.", "red");
	}
	else
	{
		sl_maximizedConsumeStuff();
		return true;
	}

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
