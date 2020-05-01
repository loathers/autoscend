script "auto_tcrs.ash"

boolean in_tcrs()
{
	return my_path() == "36" || my_path() == "Two Crazy Random Summer";
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
