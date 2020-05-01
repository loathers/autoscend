script "auto_mr2020.ash"

# This is meant for items that have a date of 2020

boolean auto_birdIsValid()
{
	// can't seek a bird if you can't use the calendar
	if(!auto_is_valid($item[Bird-a-Day calendar]))
	{
		return false;
	}

	// can't seek a bird if you don't own the calendar
	if(item_amount($item[Bird-a-Day calendar]) < 1)
	{
		return false;
	}

	// don't want to overwrite favorite bird automatically
	// however, if they already overwrote favorite bird manually today
	// and we somehow have enough mp to continue casting
	// it might as well be an option
	// hence == 0 and not <= 0
	if(auto_birdsLeftToday() == 0)
	{
		return false;
	}

	if(!get_property("_canSeekBirds").to_boolean())
	{
		use(1, $item[Bird-a-Day calendar]);
	}

	return true;
}

float auto_birdModifier(string mod)
{
	if(!auto_birdIsValid())
	{
		return 0;
	}

	return numeric_modifier($effect[Blessing of the Bird], mod);
}

float auto_favoriteBirdModifier(string mod)
{
	return numeric_modifier($effect[Blessing of Your Favorite Bird], mod);
}

int auto_birdsSought()
{
	return get_property("_birdsSoughtToday").to_int();
}

int auto_birdsLeftToday()
{
	return 6 - auto_birdsSought();
}

boolean auto_birdCanSeek()
{
	if(!auto_birdIsValid())
	{
		return false;
	}

	return auto_have_skill($skill[Seek Out a Bird]);
}

boolean auto_favoriteBirdCanSeek()
{
	// can't seek out your favorite if you already did today
	if(get_property("_favoriteBirdVisited").to_boolean())
	{
		return false;
	}

	return auto_have_skill($skill[Visit Your Favorite Bird]);
}

boolean auto_hasPowerfulGlove()
{
	return possessEquipment($item[Powerful Glove]) && 
		auto_is_valid($item[mint-in-box Powerful Glove]);
}

int auto_powerfulGloveCharges()
{
	if (!auto_hasPowerfulGlove()) return 0;
	return 100 - get_property("_powerfulGloveBatteryPowerUsed").to_int();
}

boolean auto_powerfulGloveNoncombatSkill(skill sk)
{
	if (!auto_hasPowerfulGlove()) return false;

	if (auto_powerfulGloveCharges() < 5) return false;

	item old;
	if (!have_equipped($item[Powerful Glove]))
	{
		old = equipped_item($slot[Acc3]);
		equip($slot[Acc3], $item[Powerful Glove]);
	}

	boolean ret = use_skill(1, sk);

	if (old != $item[none])
	{
		equip($slot[Acc3], old);
	}

	return ret;
}

// Returns if replaces are available, optionally only if the Powerful Glove is equipped
int auto_powerfulGloveReplacesAvailable(boolean inCombat)
{
	if (!auto_hasPowerfulGlove()) return 0;

	if (inCombat && !have_equipped($item[Powerful Glove])) return 0;

	return (auto_powerfulGloveCharges() / 10).to_int();
}

// Returns if replaces are available if the Powerful Glove was equipped
int auto_powerfulGloveReplacesAvailable()
{
	return auto_powerfulGloveReplacesAvailable(false);
}

boolean auto_powerfulGloveNoncombat()
{
	if (0 < have_effect($effect[Invisible Avatar])) return false;

	return auto_powerfulGloveNoncombatSkill($skill[CHEAT CODE: Invisible Avatar]);
}

boolean auto_powerfulGloveStats()
{
	return auto_powerfulGloveNoncombatSkill($skill[CHEAT CODE: Triple Size]);
}

boolean auto_wantToEquipPowerfulGlove()
{
	if (!auto_hasPowerfulGlove()) return false;

	if (in_zelda() && !zelda_nothingToBuy()) return true;

	int pixels = whitePixelCount();
	if (contains_text(get_property("nsTowerDoorKeysUsed"), "digital key"))
	{
		pixels += 30;
	}

	return pixels < 30;
}

boolean auto_willEquipPowerfulGlove()
{
	foreach s in $slots[acc1, acc2, acc3]
	{
		string pref = getMaximizeSlotPref(s);
		string toEquip = get_property(pref);
		if(toEquip == $item[Powerful Glove])
		{
			return true;
		}
	}

	return false;
}

boolean auto_forceEquipPowerfulGlove()
{
	if (!auto_hasPowerfulGlove()) return false;

	if(auto_willEquipPowerfulGlove())
	{
		return true;
	}

	return autoEquip($slot[acc3], $item[Powerful Glove]);
}

void auto_burnPowerfulGloveCharges()
{
	while (auto_powerfulGloveCharges() >= 5)
	{
		auto_powerfulGloveStats();
	}
}
