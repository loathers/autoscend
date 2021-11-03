void tootOriole()
{
	//Toot Oriole must be visited each ascension to unlock other quests from the council
	if(get_property("questM05Toot") == "finished")
	{
		return;
	}
	
	//do quest
	visit_url("tutorial.php?action=toot");
	if(isActuallyEd())
	{
		use(item_amount($item[Letter to Ed the Undying]), $item[Letter to Ed the Undying]);
	}
	else
	{
		use(item_amount($item[Letter From King Ralph XI]), $item[Letter From King Ralph XI]);
	}
	//finishing toot quest is not correctly noticed by mafia. r20655 has workaround of correcting this by refreshing quests
	cli_execute("refresh quests");
	
	if(get_property("questM05Toot") == "finished")
	{
		use(item_amount($item[Pork Elf Goodies Sack]), $item[Pork Elf Goodies Sack]);
		council();
	}
	else abort("Failed to finish the Toot Oriole quest. This prevents us from getting other quests from council");
}

void tootGetMeat()
{
	if(can_interact() || in_wotsf()) // avoid selling gems in casual and way of the surprising fist
	{
		return;
	}
	auto_autosell(min(5, item_amount($item[hamethyst])), $item[hamethyst]);
	auto_autosell(min(5, item_amount($item[baconstone])), $item[baconstone]);
	auto_autosell(min(5, item_amount($item[porquoise])), $item[porquoise]);
}
