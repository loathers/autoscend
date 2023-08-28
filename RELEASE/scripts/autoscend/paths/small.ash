boolean in_small()
{
	return my_path() == $path[A Shrunken Adventurer Am I];
}

void small_initializeSettings()
{
	if(!in_small())
	{
		return;
	}
	set_property("auto_wandOfNagamar", true);		//wand  used in this path
}

void auto_SmallPulls()
{
	// small path ignores stat requirements for gear so can pull high end stuff
	// attempt to pull seal clubber dread hat
	if(my_class() == $class[Seal Clubber])
	{
		pullXWhenHaveY($item[Great Wolf\'s headband], 1, 0);
	}
	// if can't get clubber dread hat (not SC or don't have it), then get nurse's hat
	if(item_amount($item[Great Wolf\'s headband]) == 0)
	{
		pullXWhenHaveY($item[nurse\'s hat], 1, 0);
	}
	// pull sea salt scrubs in small path if aware of torso
	if(hasTorso())
	{
		pullXWhenHaveY($item[Sea salt scrubs], 1, 0);
	}
	// always attempt to pull jeans of loathing in small path
	pullXWhenHaveY($item[Jeans of Loathing], 1, 0);


}
