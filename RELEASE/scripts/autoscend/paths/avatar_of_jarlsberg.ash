boolean is_Jarlsberg()
{
	return (my_class() == $class[Avatar of Jarlsberg] || my_path() == "Avatar of Jarlsberg");
}

void jarlsberg_initializeSettings()
{
    	if(is_Jarlsberg())
	{
		auto_log_info("Initializing Avatar of Jarlsberg settings", "blue");
		set_property("auto_wandOfNagamar", false);
	}
}

void jarlsberg_initializeDay(int day)
{
	if(!is_Jarlsberg())
	{
		return;
	}
	if(day == 2)
	{
		equipBaseline(); 
		ovenHandle(); 

		if(get_property("auto_day_init").to_int() < 2)
		{

			if(get_property("auto_dickstab").to_boolean() && chateaumantegna_available())
			{
				boolean[item] furniture = chateaumantegna_decorations();
				if(!furniture[$item[Ceiling Fan]])
				{
					chateaumantegna_buyStuff($item[Ceiling Fan]);
				}
			}

			if(item_amount($item[gym membership card]) > 0)
			{
				use(1, $item[gym membership card]);
			}

			if(item_amount($item[Seal Tooth]) == 0)
			{
				acquireHermitItem($item[Seal Tooth]);
			}
			while(acquireHermitItem($item[Ten-Leaf Clover]));
			pullXWhenHaveY($item[hand in glove], 1, 0);
			pullXWhenHaveY($item[blackberry galoshes], 1, 0); 
		}
	}
	else if(day == 3)
	{
		if(get_property("auto_day_init").to_int() < 3)
		{
			while(acquireHermitItem($item[Ten-Leaf Clover]));
			set_property("auto_day_init", 3);
		}
	}
	else if(day == 4)
	{
		if(get_property("auto_day_init").to_int() < 4)
		{
			while(acquireHermitItem($item[Ten-Leaf Clover]));
			set_property("auto_day_init", 4);
		}
	}
}

void jarlsberg_buySkills() //Not certain of Skill Priority Order. Current is a good start, will see how it goes.
{
	if(!is_Jarlsberg())
	{
		return;
	}
	if(my_level() <= get_property("_auto_jarlsbergSkills").to_int())
	{
		return;
		
	}
	if(get_property("_auto_completedJarlsbergSkillTree").to_boolean()) //Prevent us from running through the full list of skills checks more than once per day if we already have all skills
	{
		return;
	}

	string page = visit_url("da.php?place=gate2");
	matcher my_skillPoints = create_matcher("<b>(\\d\+)</b> skill point", page);
	if(my_skillPoints.find())
	{
		int skillPoints = to_int(my_skillPoints.group(1));
		auto_log_info("Skill points found: " + skillPoints);

		while(skillPoints > 0)
		{
			skillPoints = skillPoints - 1;
			int skillid = 0;

			//skills are listed in reverse order. from last to first to buy..

			foreach sk in $skills[Radish Horse, Working Lunch, Gristlesphere, Oilsphere, Coffeesphere, Chocolatesphere, Cream Puff, Blend, 
			Nightcap, Conjure Cream, Early Riser, Fry, Conjure Dough, Lunch Like A King, Slice, Conjure Cheese, 
			Egg man, Conjure Eggs, Food Coma, Chop, Grill, Best Served Cold, Never Late For Dinner, Conjure Meat Product, 
			Conjure Vegetables, Hippotatomous, Conjure Potato, Bake, Freeze, Conjure Fruit, The Most Important Meal, Boil]
			{
				if(!have_skill(sk))
				{
					skillid = to_int(sk);
				}
			}

			if( skillid != 0)
			{
				visit_url("jarlskills.php?action=getskill&skid=" + skillid);
			}
			else
			{
				set_property("_auto_completedJarlsbergSkillTree", true);
				return;
			}

		}
	}

	set_property("_auto_jarlsbergSkills", my_level());
}

boolean LM_jarlsberg()
{
	//this function is called early once every loop of doTasks() in autoscend.ash
	//if something in this function returns true then it will restart the loop and get called again.
	
	if(!is_Jarlsberg())
	{
		return false;
	}
	

	jarlsberg_buySkills();

	return false;
}
