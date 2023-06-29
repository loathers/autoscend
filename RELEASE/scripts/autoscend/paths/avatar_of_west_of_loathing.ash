boolean in_awol()
{
	return my_path() == $path[Avatar of West of Loathing];
}

boolean awol_initializeSettings()
{
	if(in_awol())
	{
		set_property("auto_awolLastSkill", 0);
		set_property("auto_getBeehive", true);
	}
	return false;
}

void awol_useStuff()
{
	if(!in_awol())
	{
		return;
	}

	if(have_skill($skill[Patent Medicine]))
	{
		if(item_amount($item[Patent Invisibility Tonic]) < 3)
		{
			if((item_amount($item[Eldritch Oil]) > 0) && (item_amount($item[Snake Oil]) > 0))
			{
				autoCraft("cook", 1, $item[Eldritch Oil], $item[Snake Oil]);
			}
		}
		if(item_amount($item[Patent Avarice Tonic]) == 0)
		{
			if((item_amount($item[Unusual Oil]) > 0) && (item_amount($item[Skin Oil]) > 0))
			{
				autoCraft("cook", 1, $item[Unusual Oil], $item[Skin Oil]);
			}
		}
		if(item_amount($item[Patent Aggression Tonic]) == 0)
		{
			if((item_amount($item[Unusual Oil]) > 0) && (item_amount($item[Snake Oil]) > 0))
			{
				autoCraft("cook", 1, $item[Unusual Oil], $item[Snake Oil]);
			}
		}
		if(item_amount($item[Patent Preventative Tonic]) == 0)
		{
			if((item_amount($item[Skin Oil]) > 0) && (item_amount($item[Snake Oil]) > 0))
			{
				autoCraft("cook", 1, $item[Skin Oil], $item[Snake Oil]);
			}
		}
	}

	if((item_amount($item[Snake Oil]) > 0) && (get_property("awolMedicine").to_int() < 30) && (get_property("awolVenom").to_int() < 30))
	{
		use(1, $item[Snake Oil]);
	}

	if((my_class() == $class[Cow Puncher]) && (have_effect($effect[Cowrruption]) < 20))
	{
		if(item_amount($item[Corrupted Marrow]) > 0)
		{
			use(1, $item[Corrupted Marrow]);
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
	if(!in_awol())
	{
		return false;
	}
	
	if(get_property("auto_awolLastSkill").to_int() == 0)
	{
		//Catch that Mafia does not see our second/third skillbook at ascension start
		cli_execute("refresh inv");
	}

	if(get_property("auto_awolLastSkill").to_int() < my_level())
	{
		set_property("auto_awolLastSkill", my_level());
	}
	else
	{
		return false;
	}

	if(item_amount($item[Tales of the West: \ Cow Punching]) > 0)
	{
		string page = visit_url("inv_use.php?pwd=&which=3&whichitem=8955");

		#The rest of the book is too filled<br>with jargon for you to be able<br>to understand it.
		matcher slang = create_matcher("The rest of the book is too filled", page);
		boolean cowSlang = !slang.find();

		matcher my_skillPoints = create_matcher("You can learn (\\d\+) more skill", page);
		if(my_skillPoints.find())
		{
			int skillPoints = to_int(my_skillPoints.group(1));
			auto_log_info("Cow points found: " + skillPoints);
			while(skillPoints > 0)
			{
				if(my_class() == $class[Cow Puncher])
				{
					if(!have_skill($skill[Rugged Survivalist]))							//restore some HP/MP after combat
					{
						page = visit_url("choice.php?pwd=&option=1&whichchoice=1177&whichskill=5", true);
					}
					else if(!have_skill($skill[Larger Than Life]))						//+100% maxHP/maxMP
					{
						page = visit_url("choice.php?pwd=&option=1&whichchoice=1177&whichskill=6", true);
					}
					else if(!have_skill($skill[Cowcall]))								//10MP deal spooky damage
					{
						page = visit_url("choice.php?pwd=&option=1&whichchoice=1177&whichskill=1", true);
					}
					else if(!have_skill($skill[[18008]Hard Drinker]) && cowSlang)		//+5 max liver
					{
						page = visit_url("choice.php?pwd=&option=1&whichchoice=1177&whichskill=8", true);
					}
					else if(!have_skill($skill[One-Two Punch]))							//3MP two unarmed attacks
					{
						page = visit_url("choice.php?pwd=&option=1&whichchoice=1177&whichskill=0", true);
					}
					else if(!have_skill($skill[Pistolwhip]))							//3MP damage and stun enemy 1/fight
					{
						page = visit_url("choice.php?pwd=&option=1&whichchoice=1177&whichskill=2", true);
					}
					else if(!have_skill($skill[Walk: Cautious Prowl]) && cowSlang)		//40MP/20adv +50% item drop
					{
						page = visit_url("choice.php?pwd=&option=1&whichchoice=1177&whichskill=9", true);
					}
					else if(!have_skill($skill[Hogtie]))								//10MP stun for several rounds
					{
						page = visit_url("choice.php?pwd=&option=1&whichchoice=1177&whichskill=3", true);
					}
					else if(!have_skill($skill[True Outdoorsperson]))					//+3 all res
					{
						page = visit_url("choice.php?pwd=&option=1&whichchoice=1177&whichskill=4", true);
					}
					else if(!have_skill($skill[Unleash Cowrruption]) && cowSlang)		//yellow ray
					{
						page = visit_url("choice.php?pwd=&option=1&whichchoice=1177&whichskill=7", true);
					}
				}
				else
				{
					if(!have_skill($skill[[18008]Hard Drinker]) && cowSlang)			//+5 max liver
					{
						page = visit_url("choice.php?pwd=&option=1&whichchoice=1177&whichskill=8", true);
					}
					else if(!have_skill($skill[Rugged Survivalist]))					//restore some HP/MP after combat
					{
						page = visit_url("choice.php?pwd=&option=1&whichchoice=1177&whichskill=5", true);
					}
					else if(!have_skill($skill[Walk: Cautious Prowl]) && cowSlang)		//40MP/20adv +50% item drop
					{
						page = visit_url("choice.php?pwd=&option=1&whichchoice=1177&whichskill=9", true);
					}
					else if(!have_skill($skill[Larger Than Life]))						//+100% maxHP/maxMP
					{
						page = visit_url("choice.php?pwd=&option=1&whichchoice=1177&whichskill=6", true);
					}
					else if(!have_skill($skill[Cowcall]))								//10MP deal spooky damage
					{
						page = visit_url("choice.php?pwd=&option=1&whichchoice=1177&whichskill=1", true);
					}
					else if(!have_skill($skill[One-Two Punch]))							//3MP two unarmed attacks
					{
						page = visit_url("choice.php?pwd=&option=1&whichchoice=1177&whichskill=0", true);
					}
					else if(!have_skill($skill[Pistolwhip]))							//3MP damage and stun enemy 1/fight
					{
						page = visit_url("choice.php?pwd=&option=1&whichchoice=1177&whichskill=2", true);
					}
					else if(!have_skill($skill[Hogtie]))								//10MP stun for several rounds
					{
						page = visit_url("choice.php?pwd=&option=1&whichchoice=1177&whichskill=3", true);
					}
					else if(!have_skill($skill[True Outdoorsperson]))					//+3 all res
					{
						page = visit_url("choice.php?pwd=&option=1&whichchoice=1177&whichskill=4", true);
					}
					else if(!have_skill($skill[Unleash Cowrruption]) && cowSlang)		//yellow ray
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
			auto_log_info("Bean points found: " + skillPoints);
			while(skillPoints > 0)
			{
				if(my_class() == $class[Beanslinger])
				{
					if(!have_skill($skill[Lavafava]))									//3MP deal minor hot dmg twice
					{
						page = visit_url("choice.php?pwd=&option=1&whichchoice=1178&whichskill=0", true);
					}
					else if(!have_skill($skill[Walk: Prideful Strut]) && beanSlang)		//40MP/20adv +10 stats per fight
					{
						page = visit_url("choice.php?pwd=&option=1&whichchoice=1178&whichskill=9", true);
					}
					else if(!have_skill($skill[Bean Runner]))							//+75% init
					{
						page = visit_url("choice.php?pwd=&option=1&whichchoice=1178&whichskill=4", true);
					}
					else if(!have_skill($skill[Canhandle]))								//0MP shake offhand beans for heal or dmg and stagger
					{
						page = visit_url("choice.php?pwd=&option=1&whichchoice=1178&whichskill=2", true);
					}
					else if(!have_skill($skill[Prodigious Appetite]) && beanSlang)		//+5 max stomach
					{
						page = visit_url("choice.php?pwd=&option=1&whichchoice=1178&whichskill=8", true);
					}
					else if(!have_skill($skill[Beanstorm]))								//15MP AoE 2 hits high dmg.
					{
						page = visit_url("choice.php?pwd=&option=1&whichchoice=1178&whichskill=6", true);
					}
					else if(!have_skill($skill[Beanscreen]))							//10MP block 3 next attacks
					{
						page = visit_url("choice.php?pwd=&option=1&whichchoice=1178&whichskill=3", true);
					}
					else if(!have_skill($skill[Beancannon]) && beanSlang)				//banish
					{
						page = visit_url("choice.php?pwd=&option=1&whichchoice=1178&whichskill=7", true);
					}
					else if(!have_skill($skill[Beanweaver]))							//2x bean enchantment, +2adv +substats bean plates
					{
						page = visit_url("choice.php?pwd=&option=1&whichchoice=1178&whichskill=5", true);
					}
					else if(!have_skill($skill[Pungent Mung]))							//5MP moderate stench dmg
					{
						page = visit_url("choice.php?pwd=&option=1&whichchoice=1178&whichskill=1", true);
					}
				}
				else
				{
					if(!have_skill($skill[Prodigious Appetite]) && beanSlang)			//+5 max stomach
					{
						page = visit_url("choice.php?pwd=&option=1&whichchoice=1178&whichskill=8", true);
					}
					else if(!have_skill($skill[Walk: Prideful Strut]) && beanSlang)		//40MP/20adv +10 stats per fight
					{
						page = visit_url("choice.php?pwd=&option=1&whichchoice=1178&whichskill=9", true);
					}
					else if(!have_skill($skill[Bean Runner]))							//+75% init
					{
						page = visit_url("choice.php?pwd=&option=1&whichchoice=1178&whichskill=4", true);
					}
					else if(!have_skill($skill[Beanscreen]))							//10MP block 3 next attacks
					{
						page = visit_url("choice.php?pwd=&option=1&whichchoice=1178&whichskill=3", true);
					}
					else if(!have_skill($skill[Canhandle]))								//0MP shake offhand beans for heal or dmg and stagger
					{
						page = visit_url("choice.php?pwd=&option=1&whichchoice=1178&whichskill=2", true);
					}
					else if(!have_skill($skill[Lavafava]))								//3MP deal minor hot dmg twice
					{
						page = visit_url("choice.php?pwd=&option=1&whichchoice=1178&whichskill=0", true);
					}
					else if(!have_skill($skill[Beanstorm]))								//15MP AoE 2 hits high dmg.
					{
						page = visit_url("choice.php?pwd=&option=1&whichchoice=1178&whichskill=6", true);
					}
					else if(!have_skill($skill[Beancannon]) && beanSlang)				//banish
					{
						page = visit_url("choice.php?pwd=&option=1&whichchoice=1178&whichskill=7", true);
					}
					else if(!have_skill($skill[Beanweaver]))							//2x bean enchantment, +2adv +substats bean plates
					{
						page = visit_url("choice.php?pwd=&option=1&whichchoice=1178&whichskill=5", true);
					}
					else if(!have_skill($skill[Pungent Mung]))							//5MP moderate stench dmg
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
			auto_log_info("Snake points found: " + skillPoints);
			while(skillPoints > 0)
			{
				if(my_class() == $class[Snake Oiler])
				{
					if(!have_skill($skill[Good Medicine]))									//5MP heal and stagger
					{
						page = visit_url("choice.php?pwd=&option=1&whichchoice=1179&whichskill=6", true);
					}
					else if(!have_skill($skill[Bad Medicine]))								//5MP big debuff
					{
						page = visit_url("choice.php?pwd=&option=1&whichchoice=1179&whichskill=3", true);
					}
					else if(!have_skill($skill[Extract Oil]))								//10MP extract oil. 15/day max
					{
						page = visit_url("choice.php?pwd=&option=1&whichchoice=1179&whichskill=2", true);
					}
					else if(!have_skill($skill[Tolerant Constitution]) && snakeSlang)		//+5 spleen
					{
						page = visit_url("choice.php?pwd=&option=1&whichchoice=1179&whichskill=8", true);
					}
					else if(!have_skill($skill[Snakewhip]))									//3MP physical dmg + poison
					{
						page = visit_url("choice.php?pwd=&option=1&whichchoice=1179&whichskill=0", true);
					}
					else if(!have_skill($skill[Patent Medicine]))							//craft oils and tonics.
					{
						page = visit_url("choice.php?pwd=&option=1&whichchoice=1179&whichskill=4", true);
					}
					else if(!have_skill($skill[Long Con]) && snakeSlang)					//sniff monster 5/day
					{
						page = visit_url("choice.php?pwd=&option=1&whichchoice=1179&whichskill=7", true);
					}
					else if(!have_skill($skill[Walk: Leisurely Amble]) && snakeSlang)		//40MP/20adv +100% meat drop
					{
						page = visit_url("choice.php?pwd=&option=1&whichchoice=1179&whichskill=9", true);
					}
					else if(!have_skill($skill[Well-Oiled Guns]))							//all sixgun skills more effective
					{
						page = visit_url("choice.php?pwd=&option=1&whichchoice=1179&whichskill=5", true);
					}
					else if(!have_skill($skill[Fan Hammer]))								//3 attacks with gun
					{
						page = visit_url("choice.php?pwd=&option=1&whichchoice=1179&whichskill=1", true);
					}
				}
				else
				{
					if(!have_skill($skill[Tolerant Constitution]) && snakeSlang)			//+5 spleen
					{
						page = visit_url("choice.php?pwd=&option=1&whichchoice=1179&whichskill=8", true);
					}
					else if(!have_skill($skill[Long Con]) && snakeSlang)					//sniff monster 5/day
					{
						page = visit_url("choice.php?pwd=&option=1&whichchoice=1179&whichskill=7", true);
					}
					else if(!have_skill($skill[Good Medicine]))								//5MP heal and stagger
					{
						page = visit_url("choice.php?pwd=&option=1&whichchoice=1179&whichskill=6", true);
					}
					else if(!have_skill($skill[Snakewhip]))									//3MP physical dmg + poison
					{
						page = visit_url("choice.php?pwd=&option=1&whichchoice=1179&whichskill=0", true);
					}
					else if(!have_skill($skill[Bad Medicine]))								//5MP big debuff
					{
						page = visit_url("choice.php?pwd=&option=1&whichchoice=1179&whichskill=3", true);
					}
					else if(!have_skill($skill[Extract Oil]))								//10MP extract oil. 15/day max
					{
						page = visit_url("choice.php?pwd=&option=1&whichchoice=1179&whichskill=2", true);
					}
					else if(!have_skill($skill[Patent Medicine]))							//craft oils and tonics.
					{
						page = visit_url("choice.php?pwd=&option=1&whichchoice=1179&whichskill=4", true);
					}
					else if(!have_skill($skill[Walk: Leisurely Amble]) && snakeSlang)		//40MP/20adv +100% meat drop
					{
						page = visit_url("choice.php?pwd=&option=1&whichchoice=1179&whichskill=9", true);
					}
					else if(!have_skill($skill[Well-Oiled Guns]))							//all sixgun skills more effective
					{
						page = visit_url("choice.php?pwd=&option=1&whichchoice=1179&whichskill=5", true);
					}
					else if(!have_skill($skill[Fan Hammer]))								//3 attacks with gun
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
