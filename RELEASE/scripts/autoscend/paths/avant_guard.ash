boolean in_ag()
{
	//return my_path() == $path[Avant Guard];
	return true;
}

void ag_initializeSettings()
{
	if(in_ag())
	{
		backupSetting("auto_100familiar", "Burly Bodyguard");
	}
}

void ag_pulls()
{
	if(in_ag())
	{
		//SUPER helpful for gremlins
		if(storage_amount($item[mini kiwi invisible dirigible]) > 0 && auto_is_valid($item[mini kiwi invisible dirigible]))
		{
			pullXWhenHaveY($item[mini kiwi invisible dirigible], 1, 0);
		}
	}
}