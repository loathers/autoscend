boolean in_glover()
{
	return auto_my_path() == "G-Lover";
}

void glover_initializeDay(int day)
{
	if (!in_glover()) 
	{
		return;
	}
}

void glover_initializeSettings()
{
	if(in_glover())
	{
		set_property("auto_getBeehive", true);
		set_property("auto_getBoningKnife", true);
		set_property("auto_dakotaFanning", true);
		set_property("auto_ignoreFlyer", true);
		set_property("gnasirProgress", get_property("gnasirProgress").to_int() | 16);

		//Buy Crude Oil Congealer and um... A-Boo Glues.
		if(item_amount($item[Crude Oil Congealer]) == 0)
		{
			cli_execute("make " + $item[Crude Oil Congealer]);
		}
		while((item_amount($item[A-Boo Glue]) < 3) && (item_amount($item[G]) > 0))
		{
			cli_execute("make " + $item[A-Boo Glue]);
		}

	}
}

boolean glover_usable(string it)
{
	if(!in_glover())
	{
		return true;
	}
	if(contains_text(it, "g"))
	{
		return true;
	}
	if(contains_text(it, "G"))
	{
		return true;
	}
	item checkItem = it.to_item();
	if (checkItem != $item[none] && $items[ninja Carabiner, ninja Crampons, ninja Rope,
	eXtreme scarf, snowboarder pants, eXtreme mittens, linoleum ore, chrome ore, asbestos ore,
	loadstone, amulet of extreme plot significance, titanium assault umbrella, antique machete,
	half-size scalpel, head mirror, wet stew, UV-resistant compass, Talisman o' Namsilat, Unstable Fulminate,
	Orcish baseball cap, Orcish frat-paddle, filthy knitted dread sack, filthy corduroys,
	beer helmet, distressed denim pants, reinforced beaded headband, bullet-proof corduroys] contains checkItem)
	{
		// these are all used for quest furthering porpoises so they still "work" even though they don't contain G's
		return true;
	}
	return false;
}

boolean glover_usable(effect eff)
{
	if(!in_glover())
	{
		return true;
	}
	if($effects[Stone-Faced] contains eff)
	{
		return true;	//explicit exceptions that work in glover despite not having G in the name
	}
	return glover_usable(eff.to_string());
}

boolean LM_glover()
{
	if(!in_glover())
	{
		return false;
	}
	foreach it in $items[Chaos Butterfly, Cornucopia, Disassembled Clover, Filthy Poultice, Metal Meteoroid, Oil Of Parrrlay, Pec Oil, Polysniff Perfume, Smut Orc Keepsake Box, Sonar-In-A-Biscuit, T.U.R.D.S. Key, Ten-Leaf Clover, Tonic Djinn, Turtle Wax]
	{
		if(item_amount(it) > 0)
		{
			put_closet(item_amount(it), it);
		}
	}

	if(((my_maxhp() - my_hp()) > 40) && have_skill($skill[Tongue Of The Walrus]) && (my_mp() > 100))
	{
		use_skill(1, $skill[Tongue Of The Walrus]);
	}

	return false;
}
