void grey_goo_initializeSettings()
{
	if (my_path() != "Grey Goo")
	{
		return;
	}
}

void grey_goo_initializeDay(int day)
{
	if (my_path() != "Grey Goo")
	{
		return;
	}
}

boolean LA_grey_goo_tasks()
{
	if (my_path() != "Grey Goo")
	{
		return false;
	}

	print("Adventuring in Grey Goo is not currently supported, or necessary. Have fun!");

	if (my_daycount() >= 3)
	{
		abort("You made it beyond the dawn of the third day and can now ascend. Congratulations!");
	}
	
	abort("Please come back in " + (3 - my_daycount()) + " days.");
	return true;
}