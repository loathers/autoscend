boolean in_lol()
{
	return my_path() == $path[Legacy of Loathing];
}

void lol_initializeSettings()
{
	if(!in_lol())
	{
		return;
	}
	set_property("auto_wandOfNagamar", true);		//wand  used in this path
}

boolean lol_buyReplicas()
{
	if(!in_lol())
	{
		return false;
	}

	if(item_amount($item[replica mr. accessory]) > 0)
	{
		abort("go spend the mr. replica!");
	}
}
