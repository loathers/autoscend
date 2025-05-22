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
        //don't equip the following because they can mess us up later in the run (+/- combat and Thorns)
        foreach bl in $items[crown of thorns, Brogre bucket hat, Xiblaxian stealth cowl, silent beret,
        sombrero-mounted sparkler, porkpie-mounted popper, Mer-kin sneakmask, very pointy crown,
        marble mariachi hat, parasitic headgnawer, petrified wood whoopie panama]
        {
            if(it == bl)
            {
                skip = true;
            }
        }
        //Only check to not equip these if MLSafetyLimit is not set or is not set low (-ML hats)
        if(get_property("auto_MLSafetyLimit") == "" || get_property("auto_MLSafetyLimit").to_int() >= 25)
        {
            foreach bl in $items[imposing pilgrim's hat, nasty rat mask]
            {
                if(it == bl)
                {
                    skip = true;
                }
            }
        }
        //Only check to not equip these if MLSafetyLimit is set low (+ML hats)
        if(get_property("auto_MLSafetyLimit").to_int() < 25)
        {
            foreach bl in $items[Boris's Helm (askew), fedora-mounted fountain, hemlock helm,
            marble mariachi hat, Mer-kin headguard, mushroom cap, mutant crown, spiky turtle helmet,
            Team Wrath cap, The Jokester's wig, Uncle Hobo's stocking cap, wolfskull mask]
            {
                if(it == bl)
                {
                    skip = true;
                }
            }
        }
        if(!skip && auto_can_equip(it))
        {
            equip(it);
        }
    }
    return false;
}
