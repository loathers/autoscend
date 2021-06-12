//Path specific combat handling for Heavy Rains

string auto_combatHeavyRainsStage1(int round, monster enemy, string text)
{
	##stage 1 = 1st round actions: puzzle boss, pickpocket, banish, escape, instakill, etc. things that need to be done before delevel
	
	// Unique Heavy Rains Enemy that Reflects Spells.
	if(enemy.to_string() == "Gurgle")
	{
		if(canUse($skill[Summon Love Stinkbug]))
		{
			return useSkill($skill[Summon Love Stinkbug]);
		}
		return "attack with weapon";
	}
	
	// Unique Heavy Rains Enemy that reduces Spells damage to 1 and caps non spell damage at 39 per source and type
	// Has low enough HP it can be defeated in 10 combat turns using simple melee attacks that deal only physical damage
	if(enemy.to_string() == "Dr. Aquard")
	{
		if(canUse($skill[Curse of Weaksauce]))
		{
			return useSkill($skill[Curse of Weaksauce]);
		}
		if(canUse($skill[Micrometeorite]))
		{
			return useSkill($skill[Micrometeorite]);
		}
		if(canUse($skill[Summon Love Stinkbug]))
		{
			return useSkill($skill[Summon Love Stinkbug]);
		}
		return "attack with weapon";
	}
	
	return "";
}

string auto_combatHeavyRainsStage2(int round, monster enemy, string text)
{
	##stage 2 = delevel & stun
	
	//Heavy Rain bosses delevel & stun. we only do this to the tougher bosses
	if($monsters[Big Wisnaqua, The Aquaman, The Rain King] contains enemy)
	{
		//During round 1 against late bosses set how many [Thunder Bird] we plan to cast during this combat
		if(round == 1 && get_property("auto_combatHandlerThunderBird").to_int() == 0)
		{
			int targetThunderBird = 3;
			if(monster_level_adjustment() > 80)
			{
				targetThunderBird++;
			}
			if(monster_level_adjustment() > 110)
			{
				targetThunderBird++;
			}
			if(monster_level_adjustment() > 150)
			{
				targetThunderBird++;
			}
			set_property("auto_combatHandlerThunderBird", targetThunderBird);
		}
	
		//These bosses are actually stunable. unless their ML is over 150
		if(monster_level_adjustment() > 150)		//not stunable
		{
			//30% delevel each crayon shavings, making each 1 superior to 2 casts of [Thunder Bird]
			if(item_amount($item[crayon shavings]) > 1 && auto_have_skill($skill[Ambidextrous Funkslinging]))
			{
				set_property("auto_combatHandlerThunderBird", get_property("auto_combatHandlerThunderBird").to_int() - 4);
				return "item " + $item[crayon shavings] + ", " + $item[crayon shavings];
			}
			if(item_amount($item[crayon shavings]) > 0)
			{
				set_property("auto_combatHandlerThunderBird", get_property("auto_combatHandlerThunderBird").to_int() - 2);
				return "item " + $item[crayon shavings];
			}
		}
		else		//stunable
		{
			if(canUse($skill[Micrometeorite]))
			{
				//stun and delevel 10% (or theoretically up to 25% if it was not used constantly)
				set_property("auto_combatHandlerThunderBird", get_property("auto_combatHandlerThunderBird").to_int() - 1);
				return useSkill($skill[Micrometeorite]);
			}
			if(canUse($skill[Curse Of Weaksauce]) && my_mp() >= 50 && auto_have_skill($skill[Itchy Curse Finger]))
			{
				//every round delevel 3% of original attack value
				return useSkill($skill[Curse Of Weaksauce]);
			}
			if(canUse($skill[Thunderstrike]) && my_thunder() >= 5)
			{
				//Once per combat multiround stun ability that does not delevel
				return useSkill($skill[Thunderstrike]);
			}
			if(canUse($skill[Curse Of Weaksauce]) && my_mp() >= 50)
			{
				//rely on thunderstrike stun if you do not have [Itchy Curse Finger]
				return useSkill($skill[Curse Of Weaksauce]);
			}
		}
		
		//once done with stunnning, use [Thunder Bird] which delevels but does not stun.
		if(my_thunder() == 0 && get_property("auto_combatHandlerThunderBird").to_int() > 0)
		{
			set_property("auto_combatHandlerThunderBird", 0);
		}
		if(get_property("auto_combatHandlerThunderBird").to_int() > 0 && canUse($skill[Thunder Bird], false))
		{
			set_property("auto_combatHandlerThunderBird", get_property("auto_combatHandlerThunderBird").to_int() - 1);
			return useSkill($skill[Thunder Bird], false);
		}
	}
	
	return "";
}

string auto_combatHeavyRainsStage4(int round, monster enemy, string text)
{
	##stage 4 = kill
	
	// Heavy Rains Final Boss. strips you of positive effects every time it hits you. Capped at 40 damage per source per element.
	if(enemy.to_string() == "The Rain King")
	{
		if(get_property("auto_rain_king_combat") == "attack")
		{
			if(canUse($skill[Lunging Thrust-Smack], false))
			{
				return useSkill($skill[Lunging Thrust-Smack], false);
			}
			if(canUse($skill[Thrust-Smack], false))
			{
				return useSkill($skill[Thrust-Smack], false);
			}
			if(canUse($skill[Lunge Smack], false))
			{
				return useSkill($skill[Lunge Smack], false);
			}
			return "attack with weapon";
		}
		if(get_property("auto_rain_king_combat") == "saucestorm" && canUse($skill[Saucestorm], false))
		{
			return useSkill($skill[Saucestorm], false);
		}
		if(get_property("auto_rain_king_combat") == "weapon_of_the_pastalord" && canUse($skill[Weapon of the Pastalord], false))
		{
			return useSkill($skill[Weapon of the Pastalord], false);
		}
		if(get_property("auto_rain_king_combat") == "turtleini" && canUse($skill[Turtleini], false))
		{
			return useSkill($skill[Turtleini], false);
		}
		abort("I am not sure how to finish this battle");
	}
	
	//[Storm Cow] drops [lightning milk] which gives a heavy rains lightning skill
	if((enemy == $monster[Storm Cow]) && (auto_have_skill($skill[Unleash The Greash])))
	{
		return useSkill($skill[Unleash The Greash], false);
	}
	
	return "";
}
