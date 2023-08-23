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
	//todo
	// 250 mainstat dread stuff
	// sea stuff??
}
