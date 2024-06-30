boolean in_iluh()
{
	return my_path() == $path[11 Things I Hate About U];
}

boolean iluh_foodConsumable(string str)
{
	if(!in_iluh())
	{
		return true;
	}

	//can't consume anything with a u in it. Must have an i in it
	if(contains_text(str, "u"))
	{
		return false;
	}
	if(contains_text(str, "U"))
	{
		return false;
	}
	if(contains_text(str, "i"))
	{
		return true;
	}
	if(contains_text(str, "I"))
	{
		return true;
	}
	
	return false;
}