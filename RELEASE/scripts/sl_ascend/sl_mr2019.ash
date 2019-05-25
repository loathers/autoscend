script "sl_mr2019.ash"

# This is meant for items that have a date of 2019

int sl_sausageEaten()
{
	return get_property("_sausagesEaten").to_int();
}

int sl_sausageLeftToday()
{
	return 23 - sl_sausageEaten();
}

int sl_sausageUnitsNeededForSausage(int numSaus)
{
	return 111 * numSaus;
}

int sl_sausageMeatPasteNeededForSausage(int numSaus)
{
	return ceil(sl_sausageUnitsNeededForSausage(numSaus).to_float() / 10.0);
}

int sl_sausageFightsToday()
{
	return get_property("_sausageFights").to_int();
}

boolean sl_sausageGrind(int numSaus)
{
	return sl_sausageGrind(numSaus, false);
}

boolean sl_sausageGrind(int numSaus, boolean failIfCantMakeAll)
{
	// Some paths are pretty meat-intensive early. Just in case...
	boolean canDesert = (get_property("lastDesertUnlock").to_int() == my_ascensions());
	if(my_turncount() < 90 || !canDesert)
	{
		return false;
	}

	if(in_tcrs()) return false;

	int casingsOwned = item_amount($item[magical sausage casing]);

	if(casingsOwned == 0)
		return false;

	if(numSaus <= 0)
		return false;

	if(casingsOwned < numSaus)
	{
		if(failIfCantMakeAll)
		{
			return false;
		}
		numSaus = casingsOwned;
	}

	int sausMade = get_property("_sausagesMade").to_int();
	int pastesNeeded = 0;
	int pastesAvail = item_amount($item[meat paste]);
	int meatToSave = 5000;
	if(sl_my_path() == "Community Service")
		meatToSave = 500;
	for i from 1 to numSaus
	{
		int sausNum = i + sausMade;
		int pastesForThisSaus = sl_sausageMeatPasteNeededForSausage(sausNum);
		if((pastesNeeded + pastesForThisSaus - pastesAvail) * 10 + meatToSave > my_meat())
		{
			if(failIfCantMakeAll)
			{
				return false;
			}
			if(i == 1)
			{
				return false;
			}
			numSaus = i - 1;
			break;
		}
		pastesNeeded += pastesForThisSaus;
	}

	print("Let's grind some sausage!", "blue");
	if(!create(numSaus, $item[magical sausage]))
	{
		print("Something went wrong while grinding sausage...", "red");
		return false;
	}
	loopHandlerDelayAll();

	return true;
}

boolean sl_sausageEatEmUp(int maxToEat)
{
	if(in_tcrs()) return false;

	// if maxToEat is 0, eat as many sausages as possible while respecting the reserve
	boolean noMP = my_class() == $class[Vampyre];
	int sausage_reserve_size = noMP ? 0 : 3;
	if (maxToEat == 0)
	{
		maxToEat = sl_sausageLeftToday();
	}
	else
	{
		sausage_reserve_size = 0;
	}

	if(item_amount($item[magical sausage]) <= sausage_reserve_size || get_property("sl_saveMagicalSausage").to_boolean())
		return false;

	if(sl_sausageLeftToday() <= 0)
		return false;

	int originalMp = my_maxmp();
	if(!noMP)
	{
		print("We're gonna slurp up some sausage, let's make sure we have enough max mp", "blue");
		cli_execute("checkpoint");
		maximize("mp,-tie", false);
	}
	// I could optimize this a little more by eating more sausage at once if you have enough max mp...
	// but meh.
	while(maxToEat > 0 && item_amount($item[magical sausage]) > sausage_reserve_size)
	{
		if(sl_sausageLeftToday() <= 0)
			break;
		if(!noMP)
		{
			int desiredMp = max(my_maxmp() - 999, 0);
			int mpToBurn = max(my_mp() - desiredMp, 0);
			if(mpToBurn > 0)
				cli_execute("burn " + mpToBurn);
		}
		if(!eat(1, $item[magical sausage]))
		{
			print("Somehow failed to eat a sausage! What??", "red");
			return false;
		}
		maxToEat--;
	}

	// burn any mp that'll go away when equipment switches back
	if(!noMP)
	{
		int mpToBurn = max(my_mp() - originalMp, 0);
		if(mpToBurn > 0)
			cli_execute("burn " + mpToBurn);
		cli_execute("outfit checkpoint");
	}

	return true;
}

boolean sl_sausageEatEmUp() {
	return sl_sausageEatEmUp(0);
}

boolean pirateRealmAvailable()
{
	if(!is_unrestricted($item[PirateRealm membership packet]))
	{
		return false;
	}
	if((get_property("prAlways").to_boolean() || get_property("_prToday").to_boolean()))
	{
		return true;
	}
	return false;
}

boolean LX_unlockPirateRealm()
{
	if(!pirateRealmAvailable())                       return false;
	if(possessEquipment($item[PirateRealm eyepatch])) return false;
	if(my_adventures() < 40)                          return false;

	visit_url("place.php?whichplace=realm_pirate&action=pr_port");
	return true;
}

boolean sl_saberChoice(string choice)
{
	if(!is_unrestricted($item[Fourth of May Cosplay Saber]))
	{
		return false;
	}
	if(!possessEquipment($item[Fourth of May Cosplay Saber]))
	{
		return false;
	}
	if(get_property("_saberMod").to_int() != 0)
	{
		return false;
	}

	int choiceNum = 5; // Maybe Later
	switch(choice)
	{
	case "mp regen":
	case "mp":
		choiceNum = 1;
		break;
	case "ml":
	case "monster level":
		choiceNum = 2;
		break;
	case "res":
	case "resistance":
		choiceNum = 3;
		break;
	case "fam":
	case "fam weight":
	case "familiar weight":
	case "weight":
		choiceNum = 4;
		break;
	}

	string page = visit_url("main.php?action=may4", false);
	page = visit_url("choice.php?pwd=&whichchoice=1386&option=" + choiceNum);
	return true;
}
