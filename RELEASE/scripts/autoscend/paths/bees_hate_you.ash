script "bees_hate_you.ash"


void bhy_initializeSettings()
{
	if(auto_my_path() == "Bees hate You")
	{
		set_property("auto_abooclover", false);
		set_property("auto_wandOfNagamar", false);
		set_property("auto_hippyInstead", false);
		set_property("auto_getBeehive", true);
		set_property("auto_getBoningKnife", true);
		set_property("auto_ignoreFlyer", true);
	}
}

boolean bees_hate_usable(string str)
{
	if(auto_my_path() != "Bees Hate You")
	{
		return true;
	}

	switch(str)
	{
	case "Cobb's Knob map":
	case "ball polish":
	case "black market map":
	case "boring binder clip":
	case "beehive":
	case "electric boning knife":
	case "Ninja carabiner":
	case "reinforced beaded headband":
	case "bullet-proof corduroys":
	case "round purple sunglasses":

		return true;
	}

	if(contains_text(str, "b"))
	{
		return false;
	}
	if(contains_text(str, "B"))
	{
		return false;
	}
	return true;
}

boolean LM_bhy()
{
	if(auto_my_path() != "Bees hate You")
	{
		return false;
	}
	// maximizer tries to use garbage tote to make unwieldable items and then bombs when equipping them
	// we can't turn disassembled clovers back into ten-leaf ones
	foreach it in $items[January's Garbage Tote,Ten-Leaf Clover]
	{
		if(item_amount(it) > 0)
		{
			put_closet(item_amount(it), it);
		}
	}

	return false;
}