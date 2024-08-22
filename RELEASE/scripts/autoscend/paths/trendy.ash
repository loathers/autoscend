boolean in_trendy()
{
	return my_path() == $path[Trendy];
}

boolean auto_is_trendy(string str)
{
	if(!in_trendy())
	{
		return true;
	}
	if(is_trendy(str))
	{
		return true;
	}
	return false;
}