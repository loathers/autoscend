boolean in_hattrick()
{
	return my_path() == $path[Hat Trick];
}

boolean ht_equip_hats()
{
    if(!in_hattrick())
    {
        return false;
    }
    int[item] availableHats = auto_getAllEquipabble($slot[hat]);
    foreach it, i in availableHats
    {
        boolean skip;
        //don't equip the following because they can mess us up later in the run or are useful for consumption (+/- combat and Thorns)
        foreach bl in $items[Mer-kin sneakmask, coconut shell]
        {
            if(it == bl)
            {
                skip = true;
            }
        }
        if(numeric_modifier(it, "Thorns") > 0)
        {
            skip = true;
        }
        if(numeric_modifier(it, "Combat Rate") != 0)
        {
            skip = true;
        }
        //Only check to not equip these if MLSafetyLimit is not set or is not set low (-ML hats)
        if(get_property("auto_MLSafetyLimit") == "" || get_property("auto_MLSafetyLimit").to_int() >= 25)
        {
            if(numeric_modifier(it, "Monster Level") < 0)
            {
                skip = true;
            }
        }
        //Only check to not equip these if MLSafetyLimit is set low (+ML hats)
        if(get_property("auto_MLSafetyLimit").to_int() < 25)
        {
            if(numeric_modifier(it, "Monster Level") > 0)
            {
                skip = true;
            }
        }
        if(equipped_amount(it) > 0)
        {
            skip = true;
        }
        if(!skip && auto_can_equip(it))
        {
            equip(it);
        }
    }
    return false;
}
