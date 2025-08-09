
int[item] eudora_xiblaxian()
{
	int[item] retval;
	if((item_amount($item[Xiblaxian 5D Printer]) > 0) && is_unrestricted($item[Xiblaxian 5D Printer]))
	{
		string canMake = visit_url("shop.php?whichshop=5dprinter");
		int polymer = item_amount($item[Xiblaxian Polymer]);
		int crystal = item_amount($item[Xiblaxian Crystal]);
		int circuitry = item_amount($item[Xiblaxian Circuitry]);
		int alloy = item_amount($item[Xiblaxian Alloy]);
		if(contains_text(canMake, "Xiblaxian xeno-detection goggles"))
		{
			retval[$item[Xiblaxian xeno-detection goggles]] = min(polymer/4, crystal/2);
		}
		if(contains_text(canMake, "Xiblaxian stealth cowl") && !in_hattrick())
		{
			retval[$item[Xiblaxian Stealth Cowl]] = min(circuitry/4, min(polymer/9, alloy/5));
		}
		if(contains_text(canMake, "Xiblaxian stealth trousers"))
		{
			retval[$item[Xiblaxian Stealth Trousers]] = min(circuitry/9, min(polymer/4, alloy/5));
		}
		if(contains_text(canMake, "Xiblaxian stealth vest"))
		{
			retval[$item[Xiblaxian Stealth Vest]] = min(circuitry/5, min(polymer/4, alloy/9));
		}
		if(contains_text(canMake, "Xiblaxian ultraburrito"))
		{
			retval[$item[Xiblaxian Ultraburrito]] = min(circuitry/1, min(polymer/1, alloy/3));
		}
		if(contains_text(canMake, "Xiblaxian space-whiskey"))
		{
			retval[$item[Xiblaxian Space-Whiskey]] = min(circuitry/3, min(polymer/1, alloy/1));
		}
		if(contains_text(canMake, "Xiblaxian residence-cube"))
		{
			retval[$item[Xiblaxian Residence-Cube]] = min(min(circuitry/11, crystal/3), min(polymer/11, alloy/11));
		}
	}
	return retval;
}

void auto_useWardrobe()
{
	if(!auto_is_valid($item[wardrobe-o-matic]))
	{
		return;
	}
	if(item_amount($item[wardrobe-o-matic]) == 0)
	{
		return;
	}
	// check one of the 3 prefs which get set when wardrobe is used each day
	if(get_property("_futuristicHatModifier") != "")
	{
		return;
	}
	// wait for level 5 to get an upgraded wardrobe
	if(my_level() < 5)
	{
		return;
	}
	// Zooto will be at 10 in very few turns
	if(my_level() < 10 && in_zootomist())
	{
		return;
	}
	// wait for level 15 if close and not at NS tower
	if(my_level() == 14 && internalQuestStatus("questL13Final") < 0)
	{
		return;
	}
	// only need to use it so we get the hat, shirt, fam equip
	// let maximizer handle if any of it is worth equipping
	use($item[wardrobe-o-matic]);
}

boolean auto_haveARB()
{
    return possessEquipment($item[Allied Radio Backpack]) && auto_is_valid($item[Allied Radio Backpack]);
}

boolean auto_canARBSupplyDrop()
{
    return auto_ARBSupplyDropsLeft() > 0;
}

int auto_ARBSupplyDropsLeft()
{
    if (!auto_is_valid($item[Allied Radio Backpack]))
    {
        return 0;
    }
    int n_backpack_left = auto_haveARB() ? 3-get_property("_alliedRadioDropsUsed").to_int() : 0;
    return n_backpack_left + item_amount($item[handheld Allied radio]);
}

boolean ARBSupplyDrop(string req)
{
    if(!auto_canARBSupplyDrop())
    {
        return false;
    }
    string radio;
    switch(req)
    {
        case "non-combat":
        case "nc":
        case "sniper support":
            radio = "sniper support";
            break;
        case "item drop":
        case "item":
        case "materiel intel":
            if(get_property("_alliedRadioMaterielIntel").to_boolean())
            {
                return false;
            }
            radio = "materiel intel";
            break;
        case "res":
        case "wsb":
            if(get_property("_alliedRadioWildsunBoon").to_boolean())
            {
                return false;
            }
            radio = "wildsun boon";
            break;
        case "food":
        case "rations":
            radio = "rations";
            break;
        case "drink":
        case "fuel":
            radio = "fuel";
            break;
        case "ellipsoidtine":
            radio = "ellipsoidtine";
            break;
        case "radio":
        default:
            radio = "radio";
            break;
    }
    if (allied_radio(radio))
    {
        handleTracker($item[Allied Radio Backpack], radio, "auto_iotm_claim");
        return true;
    }

    return false;
}
