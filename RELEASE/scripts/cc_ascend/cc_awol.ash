script "cc_awol.ash"

boolean awol_initializeSettings()
{
	if(my_path() == "Avatar of West of Loathing")
	{
		set_property("cc_awolLastSkill", 0);
		set_property("cc_getBeehive", true);
		set_property("cc_getStarKey", true);
		set_property("cc_holeinthesky", true);
		set_property("cc_wandOfNagamar", true);
	}
	return false;
}

void awol_useStuff()
{
	if(my_path() == "Avatar of West of Loathing")
	{
		if(have_skill($skill[Patent Medicine]))
		{
			if(item_amount($item[Patent Invisibility Tonic]) < 3)
			{
				if((item_amount($item[Eldritch Oil]) > 0) && (item_amount($item[Snake Oil]) > 0))
				{
					ccCraft("cook", 1, $item[Eldritch Oil], $item[Snake Oil]);
				}
			}
			if(item_amount($item[Patent Avarice Tonic]) == 0)
			{
				if((item_amount($item[Unusual Oil]) > 0) && (item_amount($item[Skin Oil]) > 0))
				{
					ccCraft("cook", 1, $item[Unusual Oil], $item[Skin Oil]);
				}
			}
			if(item_amount($item[Patent Aggression Tonic]) == 0)
			{
				if((item_amount($item[Unusual Oil]) > 0) && (item_amount($item[Snake Oil]) > 0))
				{
					ccCraft("cook", 1, $item[Unusual Oil], $item[Snake Oil]);
				}
			}
			if(item_amount($item[Patent Preventative Tonic]) == 0)
			{
				if((item_amount($item[Skin Oil]) > 0) && (item_amount($item[Snake Oil]) > 0))
				{
					ccCraft("cook", 1, $item[Skin Oil], $item[Snake Oil]);
				}
			}
		}

		if((item_amount($item[Snake Oil]) > 0) && (get_property("awolMedicine").to_int() < 30) && (get_property("awolVenom").to_int() < 30))
		{
			use(1, $item[Snake Oil]);
		}

		if((my_class() == $class[Cow Puncher]) && (have_effect($effect[Cowrruption]) < 150))
		{
			if(item_amount($item[Corrupted Marrow]) > 0)
			{
				use(1, $item[Corrupted Marrow]);
			}
		}
	}
}


effect awol_walkBuff()
{
	//We have none Walk Buffs
	if(!have_skill($skill[Walk: Leisurely Amble]) && !have_skill($skill[Walk: Prideful Strut]) && !have_skill($skill[Walk: Cautious Prowl]))
	{
		return $effect[none];
	}

	//If we only have one skill, might as well use that one
	if(have_skill($skill[Walk: Leisurely Amble]) && !have_skill($skill[Walk: Prideful Strut]) && !have_skill($skill[Walk: Cautious Prowl]))
	{
		return $effect[Leisurely Amblin\'];
	}
	if(!have_skill($skill[Walk: Leisurely Amble]) && have_skill($skill[Walk: Prideful Strut]) && !have_skill($skill[Walk: Cautious Prowl]))
	{
		return $effect[Prideful Strut];
	}
	if(!have_skill($skill[Walk: Leisurely Amble]) && !have_skill($skill[Walk: Prideful Strut]) && have_skill($skill[Walk: Cautious Prowl]))
	{
		return $effect[Cautious Prowl];
	}

	if(have_skill($skill[Walk: Leisurely Amble]) && have_skill($skill[Walk: Prideful Strut]) && !have_skill($skill[Walk: Cautious Prowl]))
	{
		if($locations[The Boss Bat\'s Lair, The Hidden Temple, The Themthar Hills] contains my_location())
		{
			return $effect[Leisurely Amblin\'];
		}
		if(my_level() < 13)
		{
			return $effect[Prideful Strut];
		}
		return $effect[Leisurely Amblin\'];
	}

	if(have_skill($skill[Walk: Leisurely Amble]) && !have_skill($skill[Walk: Prideful Strut]) && have_skill($skill[Walk: Cautious Prowl]))
	{
		if($locations[The Boss Bat\'s Lair, The Hidden Temple, The Themthar Hills] contains my_location())
		{
			return $effect[Leisurely Amblin\'];
		}
		return $effect[Cautious Prowl];
	}

	if(!have_skill($skill[Walk: Leisurely Amble]) && have_skill($skill[Walk: Prideful Strut]) && have_skill($skill[Walk: Cautious Prowl]))
	{
		if(my_level() <= 6)
		{
			return $effect[Prideful Strut];
		}
		return $effect[Cautious Prowl];
	}

	//We have all three skills

	if($locations[The Boss Bat\'s Lair, The Hidden Temple, The Themthar Hills] contains my_location())
	{
		return $effect[Leisurely Amblin\'];
	}
	if(my_level() <= 6)
	{
		return $effect[Prideful Strut];
	}
	return $effect[Cautious Prowl];
}

boolean awol_buySkills()
{
	if(get_property("cc_awolLastSkill").to_int() == 0)
	{
		//Catch that Mafia does not see our second/third skillbook at ascension start
		cli_execute("refresh inv");
	}

	if(get_property("cc_awolLastSkill").to_int() < my_level())
	{
		set_property("cc_awolLastSkill", my_level());
	}
	else
	{
		return false;
	}

	if(item_amount($item[Tales of the West: Cow Punching]) > 0)
	{
		string page = visit_url("inv_use.php?pwd=&which=3&whichitem=8955");

		#The rest of the book is too filled<br>with jargon for you to be able<br>to understand it.
		matcher slang = create_matcher("The rest of the book is too filled", page);
		boolean cowSlang = !slang.find();

		matcher my_skillPoints = create_matcher("You can learn (\\d\+) more skill", page);
		if(my_skillPoints.find())
		{
			int skillPoints = to_int(my_skillPoints.group(1));
			print("Cow points found: " + skillPoints);
			while(skillPoints > 0)
			{
				if(my_class() == $class[Cow Puncher])
				{
					if(!have_skill($skill[Rugged Survivalist]))
					{
						page = visit_url("choice.php?pwd=&option=1&whichchoice=1177&whichskill=5", true);
					}
					else if(!have_skill($skill[Larger Than Life]))
					{
						page = visit_url("choice.php?pwd=&option=1&whichchoice=1177&whichskill=6", true);
					}
					else if(!have_skill($skill[Cowcall]))
					{
						page = visit_url("choice.php?pwd=&option=1&whichchoice=1177&whichskill=1", true);
					}
					else if(!have_skill($skill[Hard Drinker]) && cowSlang)
					{
						page = visit_url("choice.php?pwd=&option=1&whichchoice=1177&whichskill=8", true);
					}
					else if(!have_skill($skill[One-Two Punch]))
					{
						page = visit_url("choice.php?pwd=&option=1&whichchoice=1177&whichskill=0", true);
					}
					else if(!have_skill($skill[Pistolwhip]))
					{
						page = visit_url("choice.php?pwd=&option=1&whichchoice=1177&whichskill=2", true);
					}
					else if(!have_skill($skill[Walk: Cautious Prowl]) && cowSlang)
					{
						page = visit_url("choice.php?pwd=&option=1&whichchoice=1177&whichskill=9", true);
					}
					else if(!have_skill($skill[Hogtie]))
					{
						page = visit_url("choice.php?pwd=&option=1&whichchoice=1177&whichskill=3", true);
					}
					else if(!have_skill($skill[True Outdoorsperson]))
					{
						page = visit_url("choice.php?pwd=&option=1&whichchoice=1177&whichskill=4", true);
					}
					else if(!have_skill($skill[Unleash Cowrruption]) && cowSlang)
					{
						page = visit_url("choice.php?pwd=&option=1&whichchoice=1177&whichskill=7", true);
					}
				}
				else
				{
					if(!have_skill($skill[Hard Drinker]) && cowSlang)
					{
						page = visit_url("choice.php?pwd=&option=1&whichchoice=1177&whichskill=8", true);
					}
					else if(!have_skill($skill[Rugged Survivalist]))
					{
						page = visit_url("choice.php?pwd=&option=1&whichchoice=1177&whichskill=5", true);
					}
					else if(!have_skill($skill[Walk: Cautious Prowl]) && cowSlang)
					{
						page = visit_url("choice.php?pwd=&option=1&whichchoice=1177&whichskill=9", true);
					}
					else if(!have_skill($skill[Larger Than Life]))
					{
						page = visit_url("choice.php?pwd=&option=1&whichchoice=1177&whichskill=6", true);
					}
					else if(!have_skill($skill[Cowcall]))
					{
						page = visit_url("choice.php?pwd=&option=1&whichchoice=1177&whichskill=1", true);
					}
					else if(!have_skill($skill[One-Two Punch]))
					{
						page = visit_url("choice.php?pwd=&option=1&whichchoice=1177&whichskill=0", true);
					}
					else if(!have_skill($skill[Pistolwhip]))
					{
						page = visit_url("choice.php?pwd=&option=1&whichchoice=1177&whichskill=2", true);
					}
					else if(!have_skill($skill[Hogtie]))
					{
						page = visit_url("choice.php?pwd=&option=1&whichchoice=1177&whichskill=3", true);
					}
					else if(!have_skill($skill[True Outdoorsperson]))
					{
						page = visit_url("choice.php?pwd=&option=1&whichchoice=1177&whichskill=4", true);
					}
					else if(!have_skill($skill[Unleash Cowrruption]) && cowSlang)
					{
						page = visit_url("choice.php?pwd=&option=1&whichchoice=1177&whichskill=7", true);
					}
				}
				skillPoints -= 1;
			}
		}
	}
	if(item_amount($item[Tales of the West: Beanslinging]) > 0)
	{
		string page = visit_url("inv_use.php?pwd=&which=3&whichitem=8956");

		matcher slang = create_matcher("The rest of the book is too filled", page);
		boolean beanSlang = !slang.find();

		matcher my_skillPoints = create_matcher("You can learn (\\d\+) more skill", page);
		if(my_skillPoints.find())
		{
			int skillPoints = to_int(my_skillPoints.group(1));
			print("Bean points found: " + skillPoints);
			while(skillPoints > 0)
			{
				if(my_class() == $class[Beanslinger])
				{
					if(!have_skill($skill[Beanstorm]))
					{
						page = visit_url("choice.php?pwd=&option=1&whichchoice=1178&whichskill=6", true);
					}
					else if(!have_skill($skill[Beanscreen]))
					{
						page = visit_url("choice.php?pwd=&option=1&whichchoice=1178&whichskill=3", true);
					}
					else if(!have_skill($skill[Canhandle]))
					{
						page = visit_url("choice.php?pwd=&option=1&whichchoice=1178&whichskill=2", true);
					}
					else if(!have_skill($skill[Prodigious Appetite]) && beanSlang)
					{
						page = visit_url("choice.php?pwd=&option=1&whichchoice=1178&whichskill=8", true);
					}
					else if(!have_skill($skill[Lavafava]))
					{
						page = visit_url("choice.php?pwd=&option=1&whichchoice=1178&whichskill=0", true);
					}
					else if(!have_skill($skill[Bean Runner]))
					{
						page = visit_url("choice.php?pwd=&option=1&whichchoice=1178&whichskill=4", true);
					}
					else if(!have_skill($skill[Beancannon]) && beanSlang)
					{
						page = visit_url("choice.php?pwd=&option=1&whichchoice=1178&whichskill=7", true);
					}
					else if(!have_skill($skill[Walk: Prideful Strut]) && beanSlang)
					{
						page = visit_url("choice.php?pwd=&option=1&whichchoice=1178&whichskill=9", true);
					}
					else if(!have_skill($skill[Beanweaver]))
					{
						page = visit_url("choice.php?pwd=&option=1&whichchoice=1178&whichskill=5", true);
					}
					else if(!have_skill($skill[Pungent Mung]))
					{
						page = visit_url("choice.php?pwd=&option=1&whichchoice=1178&whichskill=1", true);
					}
				}
				else
				{
					if(!have_skill($skill[Prodigious Appetite]) && beanSlang)
					{
						page = visit_url("choice.php?pwd=&option=1&whichchoice=1178&whichskill=8", true);
					}
					else if(!have_skill($skill[Walk: Prideful Strut]) && beanSlang)
					{
						page = visit_url("choice.php?pwd=&option=1&whichchoice=1178&whichskill=9", true);
					}
					else if(!have_skill($skill[Bean Runner]))
					{
						page = visit_url("choice.php?pwd=&option=1&whichchoice=1178&whichskill=4", true);
					}
					else if(!have_skill($skill[Beanscreen]))
					{
						page = visit_url("choice.php?pwd=&option=1&whichchoice=1178&whichskill=3", true);
					}
					else if(!have_skill($skill[Canhandle]))
					{
						page = visit_url("choice.php?pwd=&option=1&whichchoice=1178&whichskill=2", true);
					}
					else if(!have_skill($skill[Lavafava]))
					{
						page = visit_url("choice.php?pwd=&option=1&whichchoice=1178&whichskill=0", true);
					}
					else if(!have_skill($skill[Beanstorm]))
					{
						page = visit_url("choice.php?pwd=&option=1&whichchoice=1178&whichskill=6", true);
					}
					else if(!have_skill($skill[Beancannon]) && beanSlang)
					{
						page = visit_url("choice.php?pwd=&option=1&whichchoice=1178&whichskill=7", true);
					}
					else if(!have_skill($skill[Beanweaver]))
					{
						page = visit_url("choice.php?pwd=&option=1&whichchoice=1178&whichskill=5", true);
					}
					else if(!have_skill($skill[Pungent Mung]))
					{
						page = visit_url("choice.php?pwd=&option=1&whichchoice=1178&whichskill=1", true);
					}
				}
				skillPoints -= 1;
			}
		}
	}
	if(item_amount($item[Tales of the West: Snake Oiling]) > 0)
	{
		string page = visit_url("inv_use.php?pwd=&which=3&whichitem=8957");

		matcher slang = create_matcher("The rest of the book is too filled", page);
		boolean snakeSlang = !slang.find();

		matcher my_skillPoints = create_matcher("You can learn (\\d\+) more skill", page);
		if(my_skillPoints.find())
		{
			int skillPoints = to_int(my_skillPoints.group(1));
			print("Snake points found: " + skillPoints);
			while(skillPoints > 0)
			{
				if(my_class() == $class[Snake Oiler])
				{
					if(!have_skill($skill[Good Medicine]))
					{
						page = visit_url("choice.php?pwd=&option=1&whichchoice=1179&whichskill=6", true);
					}
					else if(!have_skill($skill[Bad Medicine]))
					{
						page = visit_url("choice.php?pwd=&option=1&whichchoice=1179&whichskill=3", true);
					}
					else if(!have_skill($skill[Extract Oil]))
					{
						page = visit_url("choice.php?pwd=&option=1&whichchoice=1179&whichskill=2", true);
					}
					else if(!have_skill($skill[Tolerant Constitution]) && snakeSlang)
					{
						page = visit_url("choice.php?pwd=&option=1&whichchoice=1179&whichskill=8", true);
					}
					else if(!have_skill($skill[Snakewhip]))
					{
						page = visit_url("choice.php?pwd=&option=1&whichchoice=1179&whichskill=0", true);
					}
					else if(!have_skill($skill[Patent Medicine]))
					{
						page = visit_url("choice.php?pwd=&option=1&whichchoice=1179&whichskill=4", true);
					}
					else if(!have_skill($skill[Long Con]) && snakeSlang)
					{
						page = visit_url("choice.php?pwd=&option=1&whichchoice=1179&whichskill=7", true);
					}
					else if(!have_skill($skill[Walk: Leisurely Amble]) && snakeSlang)
					{
						page = visit_url("choice.php?pwd=&option=1&whichchoice=1179&whichskill=9", true);
					}
					else if(!have_skill($skill[Well-Oiled Guns]))
					{
						page = visit_url("choice.php?pwd=&option=1&whichchoice=1179&whichskill=5", true);
					}
					else if(!have_skill($skill[Fan Hammer]))
					{
						page = visit_url("choice.php?pwd=&option=1&whichchoice=1179&whichskill=1", true);
					}
				}
				else
				{
					if(!have_skill($skill[Tolerant Constitution]) && snakeSlang)
					{
						page = visit_url("choice.php?pwd=&option=1&whichchoice=1179&whichskill=8", true);
					}
					else if(!have_skill($skill[Long Con]) && snakeSlang)
					{
						page = visit_url("choice.php?pwd=&option=1&whichchoice=1179&whichskill=7", true);
					}
					else if(!have_skill($skill[Good Medicine]))
					{
						page = visit_url("choice.php?pwd=&option=1&whichchoice=1179&whichskill=6", true);
					}
					else if(!have_skill($skill[Snakewhip]))
					{
						page = visit_url("choice.php?pwd=&option=1&whichchoice=1179&whichskill=0", true);
					}
					else if(!have_skill($skill[Bad Medicine]))
					{
						page = visit_url("choice.php?pwd=&option=1&whichchoice=1179&whichskill=3", true);
					}
					else if(!have_skill($skill[Extract Oil]))
					{
						page = visit_url("choice.php?pwd=&option=1&whichchoice=1179&whichskill=2", true);
					}
					else if(!have_skill($skill[Patent Medicine]))
					{
						page = visit_url("choice.php?pwd=&option=1&whichchoice=1179&whichskill=4", true);
					}
					else if(!have_skill($skill[Walk: Leisurely Amble]) && snakeSlang)
					{
						page = visit_url("choice.php?pwd=&option=1&whichchoice=1179&whichskill=9", true);
					}
					else if(!have_skill($skill[Well-Oiled Guns]))
					{
						page = visit_url("choice.php?pwd=&option=1&whichchoice=1179&whichskill=5", true);
					}
					else if(!have_skill($skill[Fan Hammer]))
					{
						page = visit_url("choice.php?pwd=&option=1&whichchoice=1179&whichskill=1", true);
					}
				}
				skillPoints -= 1;
			}
		}
	}

	return false;
}
