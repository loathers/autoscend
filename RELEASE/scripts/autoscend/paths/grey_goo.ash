boolean in_ggoo()
{
	return my_path() == $path[Grey Goo];
}

boolean LA_grey_goo_tasks()
{
	if(!in_ggoo())
	{
		return false;
	}
	
	print("Adventuring in Grey Goo is not currently supported, or necessary. Have fun!");
	if (my_daycount() >= 3)
	{
		print("You made it beyond the dawn of the third day and can now ascend. Congratulations!", "blue");
		abort();
	}
	abort("Please come back in " + (3 - my_daycount()) + " days.");
	return true;
}
