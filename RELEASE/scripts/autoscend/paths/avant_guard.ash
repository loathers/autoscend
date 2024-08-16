boolean in_ag()
{
	return my_path() == $path[Avant Guard];
}

void ag_initializeSettings()
{
	if(in_ag())
	{
		backupSetting("auto_100familiar", "Burly Bodyguard");
	}
}

