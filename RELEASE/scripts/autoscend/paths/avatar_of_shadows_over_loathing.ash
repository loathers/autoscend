boolean in_aosol()
{
	return my_path() == $path[Avatar of Shadows Over Loathing];
}

boolean aosol_initializeSettings()
{
	if(in_aosol())
	{
		set_property("auto_aosolLastSkill", 0);
	}
	return false;
}

void aosol_unCurse()
{
	//Only care about using these 2 because of the massive weakening they do while Cursed
	//Cursed Blanket is -Fam Weight, but if we are using it for Prismatic Res, we probably don't care about Fam Weight at that time
	//Cursed Arcane Orb is -Item Drop, but if we are using it for Prismatic Dmg, we probably don't care about Item Drop at that time
	//Cursed Dragon Wishbone is -Meat Drop, but if we are using it for Item Drop, we probably don't care about Meat Drop at that time
	if(item_amount($item[Cursed Cape]) > 0) //Vulnerability to 2 elements
	{
		use(1, $item[Cursed Cape]);
	}
	if(item_amount($item[Cursed Paw]) > 0) //+ML and -Attributes
	{
		use(1, $item[Cursed Paw]);
	}
}

