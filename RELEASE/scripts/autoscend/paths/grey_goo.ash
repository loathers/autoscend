boolean in_ggoo()
{
	return auto_my_path() == "Grey Goo";
}

void grey_goo_initializeSettings()
{
	if(!in_ggoo())
	{
		return;
	}
	set_property("auto_paranoia", 1);		//greygoo has broken tracking verified for questL02Larva && questM19Hippy. probably more things
}

void grey_goo_initializeDay(int day)
{
	if(!in_ggoo())
	{
		return;
	}
}

boolean LA_grey_goo_tasks()
{
	if(!in_ggoo())
	{
		return false;
	}
	
	if(LX_galaktikSubQuest()) return true;			//only if user manually set auto_doGalaktik to true this ascension
	if(LX_armorySideQuest()) return true;			//only if user manually set auto_doArmory to true this ascension

	print("Adventuring in Grey Goo is not currently supported, or necessary. Have fun!");
	if (my_daycount() >= 3)
	{
		print("You made it beyond the dawn of the third day and can now ascend. Congratulations!", "blue");
		abort();
	}
	abort("Please come back in " + (3 - my_daycount()) + " days.");
	return true;
}
