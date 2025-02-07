# This is meant for items that have a date of 2025

boolean auto_haveMcHugeLargeSkis()
{
	if(auto_is_valid($item[McHugeLarge duffel bag]) && available_amount($item[McHugeLarge duffel bag]) > 0 )
	{
		return true;
	}
	return false;
}

boolean auto_canEquipAllMcHugeLarge()
{
	if (!auto_haveMcHugeLargeSkis())
	{
		return false;
	}
	boolean success = true;
	foreach it in $items[McHugeLarge duffel bag,McHugeLarge right pole,McHugeLarge left pole,McHugeLarge right ski,McHugeLarge left ski]
	{
		success = can_equip(it) && success;
	}
	return success;
}

boolean auto_equipAllMcHugeLarge()
{
	if (!auto_haveMcHugeLargeSkis())
	{
		return false;
	}
	if (!possessEquipment($item[McHugeLarge right pole]))
	{
		auto_openMcLargeHugeSkis();
	}
	autoForceEquip($slot[back]    , $item[McHugeLarge duffel bag]);
	autoForceEquip($slot[weapon]  , $item[McHugeLarge right pole]);
	autoForceEquip($slot[off-hand], $item[McHugeLarge left pole]);
	autoForceEquip($slot[acc1]    , $item[McHugeLarge left ski]);
	autoForceEquip($slot[acc2]    , $item[McHugeLarge right ski]);
	return true;
}

boolean auto_openMcLargeHugeSkis()
{
	if (!auto_haveMcHugeLargeSkis())
	{
		return false;
	}
	if(possessEquipment($item[McHugeLarge right pole]))
	{
		return true;
	}
	//~ use($item[McHugeLarge duffel bag]); // does not work - need Mafia CLI tool?
	visit_url("inventory.php?action=skiduffel");
	return possessEquipment($item[McHugeLarge right pole]);
}

int auto_McLargeHugeForcesLeft()
{
	if (!auto_haveMcHugeLargeSkis())
	{
		return 0;
	}
	int used = get_property("_mcHugeLargeAvalancheUses").to_int();
	return 3-used;
}

int auto_McLargeHugeSniffsLeft()
{
	if (!auto_haveMcHugeLargeSkis())
	{
		return 0;
	}
	int used = get_property("_mcHugeLargeSlashUses").to_int();
	return 3-used;
}

boolean auto_haveCupidBow()
{
	item bow = $item[toy cupid bow];
	return (auto_is_valid(bow) && possessEquipment(bow));
}
