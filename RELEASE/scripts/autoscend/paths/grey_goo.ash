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
