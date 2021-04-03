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
	set_property("auto_paranoia", 1);		//greygoo has broken tracking verified for: questL02Larva && questM19Hippy. probably more things
	set_property("auto_doGalaktik", true);	//we are adventuring in greygoo for meat. this saves meat
}

void grey_goo_initializeDay(int day)
{
	if(!in_ggoo())
	{
		return;
	}
}

boolean greygoo_fortuneCollect()
{
	if(!contains_text(get_counters("Fortune Cookie", 0, 0), "Fortune Cookie"))
	{
		return false;	//semirare not currently about to happen
	}
	
	//Semi-rare Handler
	auto_log_info("Semi rare time!", "blue");
	cli_execute("counters");

	location goal;
	location lastsr = get_property("semirareLocation").to_location();
	
	if(lastsr != $location[The Sleazy Back Alley])		//can not get the same SR twice. so do not waste it
	{
		goal = $location[The Sleazy Back Alley];	//grab epic drink
	}
	else
	{
		goal = $location[The Haunted Pantry];		//grab epic food
	}
	
	return autoAdv(goal);
}

boolean greygoo_oddJobs()
{
	//spend all your remaining adv on the odd jobs board for ~100 meat per adv and some stats
	if(my_adventures() < 10)
	{
		while(my_meat() > 1000 && auto_autoConsumeOne("drink", false));		//try to fill up on drink
		while(my_meat() > 1000 && auto_autoConsumeOne("eat", false));		//try to fill up on food
		if((my_adventures() < 10 && my_daycount() < 3 ) || my_adventures() < 3)
		{
			return false;		//not enough adv left
		}
	}
	
	int target = 1;		//choice 1 == costs 3 adv and balanced stats
	if(my_adventures() > 9)
	{
		if($classes[Seal Clubber, Turtle Tamer] contains my_class())
		{
			target = 2;		//choice 2 == costs 10 adv and mus focus stats
		}
		if($classes[Pastamancer, Sauceror] contains my_class())
		{
			target = 3;		//choice 3 == costs 10 adv and mys focus stats
		}
		if($classes[Disco Bandit, Accordion Thief] contains my_class())
		{
			target = 4;		//choice 4 == costs 10 adv and mox focus stats
		}
	}
	return LX_oddJobs(target);
}

boolean LA_grey_goo_tasks()
{
	if(!in_ggoo())
	{
		return false;
	}
	
	if(greygoo_fortuneCollect()) return true;
	if(my_level() < 3)								//if just started a run do oddjobs to get some levels
	{
		if(greygoo_oddJobs()) return true;
	}
	if(my_meat() < 300)
	{
		if(greygoo_oddJobs()) return true;			//running out of money. so get some more
	}
	if(LX_galaktikSubQuest()) return true;			//will only do the quest if auto_doGalaktik is true
	if(LX_guildUnlock()) return true;
	
	//unlock [typical tavern]
	if(L2_mosquito()) return true;					//must do this quest to unlock typical tavern
	if(internalQuestStatus("questL03Rat") == 0)		//got the quest from council but yet to speak to bart ender
	{
		visit_url("tavern.php?place=barkeep");		//talk to him once to unlock his booze selling.
	}
	if(LX_armorySideQuest()) return true;			//unlock [madeline's baking supply] store while getting some food
	
	if(LX_freeCombats(true)) return true;
	if(greygoo_oddJobs()) return true;				//spend remaining adventures on getting meat and XP
	//fighting greygoo monsters for monster manuel entries will go here

	if(my_daycount() < 3)
	{
		print("You are currently on day " +my_daycount()+ " out of 3 of this grey goo run","red");
	}
	else
	{
		print("You are done with this grey goo ascension. please enter the astral gash","green");
	}	
	set_property("_auto_doneToday", true);		//skip doTasks() and go to doBedtime()
	return true;		//restart doTasks() loop so we can notice the above setting
}
