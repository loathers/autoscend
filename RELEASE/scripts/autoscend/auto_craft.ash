boolean is_foldable(item target)
{
	//mafia does not provide an easy means of checking if an item possesses the foldable property.
	//This function checks if the item possesses that property. It does not care if you actually have it
	return count(get_related(target, "fold")) > 1;
}

int foldable_amount(item target)
{
	//counts how many copies we can fold of a certain item.
	if(!is_foldable(target))
	{
		return 0;
	}
	int retval = 0;
	foreach it in get_related(target, "fold")
	{
		retval += item_amount(it);
	}
	return retval;
}

boolean auto_fold(item target)
{
	//fold an item using mafia fold cli command. with checks to ensure everything worked as expected.
	if(!is_foldable(target))
	{
		auto_log_debug("[" +target+ "] is not foldable");
		return false;
	}
	if(item_amount(target) > 0)
	{
		return true;	//we already have the desired item
	}
	if(foldable_amount(target) == 0)
	{
		auto_log_debug("Can not fold [" +target+ "] because we do not possess the required items");
		return false;
	}
	auto_log_debug("folding [" +target+ "]");
	int start_amt = item_amount(target);
	cli_execute("fold " +target);
	if(item_amount(target) == start_amt+1)
	{
		return true;
	}
	abort("Mysteriously failed to fold [" +target+ "]. please fold it manually and run me again");
	return false;
}

boolean untinkerable(item target)
{
	//does the item target possess the untinkerable property. this does not care if we actually have it or can untinker. only the property.
	//exceptions that can be untinkered even though they are no longer pasteable
	if($items[31337 scroll] contains target)
	{
		return true;
	}	
	//exceptions that can not be untinkered even though they are pasteable exist.
	//most return craft_type of "Meatpasting (not untinkerable)" and as such need no special handling.
	//this is special handling for those whom mafia incorrectly returns "Meatpasting" for
	if($items[chaos popcorn, cold clusterbomb, hot clusterbomb, sleaze clusterbomb, spooky clusterbomb, stench clusterbomb] contains target)
	{
		return false;
	}	
	return craft_type(target) == "Meatpasting";
}

boolean canUntinker()
{
	//do we possess the means to untinker.
	if(hasLegionKnife() && auto_is_valid($item[Loathing Legion universal screwdriver]))
	{
		return true;		//universal screwdriver can be used to untinker items
	}
	return get_property("questM01Untinker") == "finished";
}

boolean canUntinker(item target)
{
	if(!canUntinker())
	{
		auto_log_debug("We can not untinker [" +target+ "] because we can not untinker anything right now");
		return false;
	}
	if(item_amount(target) == 0)
	{
		auto_log_debug("We can not untinker [" +target+ "] because we do not have any");
		return false;
	}
	return untinkerable(target);
}

boolean untinker(item target)
{
	return untinker(1, target);
}

boolean untinker(int amount, item target)
{
	if(!canUntinker(target))
	{
		return false;
	}
	if(amount < 1)
	{
		auto_log_debug("Attempted to untinker [" +target+ "] and detected an invalid desired untinker amount of " +amount);
		return false;
	}
	if(item_amount(target) < amount)
	{
		auto_log_warning("Attempted to untinker " +amount+ " [" +target+ "] but we only have " +item_amount(target)+ ". which is how many we will untinker instead");
		amount = item_amount(target);		//we can not untinker more than we have
	}
	
	boolean untinker_all = amount == item_amount(target);
	auto_log_debug("Attempted to untinker " +amount+ " [" +target+ "]");
	int start_amt = item_amount(target);
	item LLUS = $item[Loathing Legion universal screwdriver];

	if(get_property("questM01Untinker") == "finished")
	{
		if(untinker_all)
		{
			visit_url("place.php?whichplace=forestvillage&action=fv_untinker&pwd=&preaction=untinker&whichitem=" +target.to_int()+ "&untinkerall=on");
		}
		else for i from 1 to amount
		{
			visit_url("place.php?whichplace=forestvillage&action=fv_untinker&pwd=&preaction=untinker&whichitem=" +target.to_int());
		}
	}
	else if(hasLegionKnife() && auto_is_valid(LLUS) && auto_fold(LLUS))
	{
		if(untinker_all)
		{
			visit_url("inv_use.php?pwd=" +my_hash()+ "&whichitem=4926&action=screw&dowhichitem=" +target.to_int()+ "&untinkerall=on", false);
		}
		else for i from 1 to amount
		{
			visit_url("inv_use.php?pwd=" +my_hash()+ "&whichitem=4926&action=screw&dowhichitem=" +target.to_int(), false);
		}
	}
	
	int success_amt = start_amt - item_amount(target);
	if(success_amt == amount)
	{
		return true;
	}
	auto_log_warning("Untinkering " +amount+ " [" +target+ "] mysteriously failed. Only " +success_amt+ " were untinkered");
	return false;
}
