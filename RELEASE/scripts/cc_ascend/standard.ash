script "standard.ash"

import<cc_util.ash>
# Code here is supplementary handlers and specialized handlers

void standard_dnaPotions()
{
	if(my_path() == "Standard")
	{
		return;
	}
	if(!is_unrestricted($item[Little Geneticist DNA-Splicing Lab]))
	{
		return;
	}
	if(get_property("dnaSyringe") == "construct")
	{
		if((get_property("_dnaPotionsMade").to_int() == 0) && (my_daycount() == 1))
		{
			cli_execute("camp dnapotion");
		}
		if((get_property("_dnaPotionsMade").to_int() == 1) && (my_daycount() == 1))
		{
			cli_execute("camp dnapotion");
		}
	}

	if(get_property("dnaSyringe") == "humanoid")
	{
		if((get_property("_dnaPotionsMade").to_int() == 2) && (my_daycount() == 1))
		{
			cli_execute("camp dnapotion");
		}
		if((get_property("_dnaPotionsMade").to_int() == 2) && (my_daycount() == 2))
		{
			cli_execute("camp dnapotion");
		}
	}

	if(get_property("dnaSyringe") == "plant")
	{
		if((get_property("_dnaPotionsMade").to_int() == 2) && (my_daycount() == 1))
		{
			cli_execute("camp dnapotion");
		}
	}

	if(get_property("dnaSyringe") == "constellation")
	{
		if((get_property("_dnaPotionsMade").to_int() == 0) && (my_daycount() == 2))
		{
			cli_execute("camp dnapotion");
		}
	}

	if(get_property("dnaSyringe") == "dude")
	{
		if((get_property("_dnaPotionsMade").to_int() == 1) && (my_daycount() == 2))
		{
			cli_execute("camp dnapotion");
		}
	}
}


void standard_initializeSettings()
{
	if(my_path() == "Standard")
	{
		set_property("cc_getStarKey", true);
		set_property("cc_holeinthesky", true);
		set_property("cc_wandOfNagamar", true);
		set_property("cc_useCubeling", true);
	}
}

void standard_pulls()
{
	if(my_path() == "Standard")
	{
		if(my_daycount() == 3)
		{
			#pullXWhenHaveY($item[Wand of Nagamar], 1, 0);		//Pull made obsolete by Questificaton
			#pullXWhenHaveY($item[Star Key Lime Pie], 3, 0);
			pullXWhenHaveY($item[Boris\'s Key Lime Pie], 1, 0);
			pullXWhenHaveY($item[Cold Hi Mein], 2, 0);
		}

	}
}
