# Code here is supplementary handlers and specialized handlers

boolean in_picky()
{
	return my_path() == "Picky";
}

void picky_pulls()
{
	if(in_picky())
	{
		if(my_daycount() == 3)
		{
			#pullXWhenHaveY($item[Wand of Nagamar], 1, 0);		//Pull made obsolete by Questificaton
			#pullXWhenHaveY($item[Star Key Lime Pie], 3, 0);
			pullXWhenHaveY($item[Cold Hi Mein], 3, 0);
		}

	}
}

void picky_startAscension()
{
	auto_log_info("In Being Picky Adventure", "blue");
	if((my_class() == $class[Turtle Tamer]) || (my_class() == $class[Seal Clubber]))
	{
		auto_log_info("Selecting skills", "blue");
		string page = visit_url("choice.php?pwd&whichchoice=995&pwd=&option=1&familiar=188", true);
		if(contains_text(page, "<option value=\"165\""))
		{
			visit_url("choice.php?pwd&whichchoice=995&pwd=&option=1&familiar=165", true);
		}
		else
		{
			visit_url("choice.php?pwd&whichchoice=995&pwd=&option=1&familiar=140", true);
		}
		visit_url("choice.php?pwd&whichchoice=995&pwd=&option=1&familiar=178", true);

		# Olfaction, Torso
		visit_url("choice.php?pwd&whichchoice=995&pwd=&option=2&skill=19", true);
		visit_url("choice.php?pwd&whichchoice=995&pwd=&option=2&skill=12", true);

		# Pulverize, Astral Shell, Hero of the Half Shell, Cannelloni Cocoon
		visit_url("choice.php?pwd&whichchoice=995&pwd=&option=2&skill=1016", true);
		visit_url("choice.php?pwd&whichchoice=995&pwd=&option=2&skill=2012", true);
		visit_url("choice.php?pwd&whichchoice=995&pwd=&option=2&skill=2020", true);
		visit_url("choice.php?pwd&whichchoice=995&pwd=&option=2&skill=3012", true);

		# Elemental Saucesphere, Mad Looting Skillz, Smooth Movement
		visit_url("choice.php?pwd&whichchoice=995&pwd=&option=2&skill=4007", true);
		visit_url("choice.php?pwd&whichchoice=995&pwd=&option=2&skill=5006", true);
		visit_url("choice.php?pwd&whichchoice=995&pwd=&option=2&skill=5017", true);

		# Fat Leon's Phat Loot Lyric, The Sonata of Sneakiness
		visit_url("choice.php?pwd&whichchoice=995&pwd=&option=2&skill=6010", true);
		visit_url("choice.php?pwd&whichchoice=995&pwd=&option=2&skill=6015", true);
		visit_url("choice.php?pwd&whichchoice=995&pwd=&option=3&submit=I Am Done Picking", true);
	}
}
