boolean in_ag()
{
	return my_path() == $path[Avant Guard];
}

void ag_initializeSettings()
{
	if(in_ag())
	{
		set_property("auto_100familiar", "Burly Bodyguard");
		set_property("auto_skipNuns", true);
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

void ag_bgChat()
{
	if(!in_ag())
	{
		return;
	}
	string bgChat = visit_url("main.php?talktobg=1");
	if(contains_text(bgChat, "Chatting with your Burly Bodyguard"))
	{
		run_choice(1, false, "bgid=78"); //knob goblin harem girl proof of concept
	}
}