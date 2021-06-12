//Path specific combat handling for disguises delimit

string auto_combatDisguisesStage4(int round, monster enemy, string text)
{
	//stage 4 killing the enemy. disguises delimit specific
	
	int majora = get_property("_auto_combatDisguisesDelimitMask").to_int();
	if(majora == 13)	//welding mask
	{
		//reflect damage from spells back to player. kept if mask is changed
		//some spells actually damage the monster too.
		//saucegeyser confirmed to not damage the monster. saucestorm confirmed to damage the monster.
		if(enemy.physical_resistance >= 80)
		{
			if(my_hp() > monster_hp() + 150 && canUse($skill[Saucestorm], false))
			{
				return useSkill($skill[Saucestorm], false);
			}
			//TODO check if our physical attack can deal elemental damage.
			else abort("Not sure how to handle a physically resistent enemy wearing a welding mask.");
		}
		if(canSurvive(1.5) && round < 10)
		{
			return "attack with weapon";
		}
		abort("Not sure how to handle welding mask.");
	}
	if(majora == 25)	//tiki mask
	{
		//triples HP and hard caps damage at 10 per source. kept if mask is changed
		//seal clubbers have ways to increase this damage but its overly complicated to calculate. simplified calculation is used.
		int hot_dmg = min(10,numeric_modifier("hot damage"));
		int cold_dmg = min(10,numeric_modifier("cold damage"));
		int stench_dmg = min(10,numeric_modifier("stench damage"));
		int sleaze_dmg = min(10,numeric_modifier("sleaze damage"));
		int spooky_dmg = min(10,numeric_modifier("spooky damage"));
		int attack_dmg = 10 + hot_dmg + cold_dmg + stench_dmg + sleaze_dmg + spooky_dmg;
		
		if(attack_dmg > 20)
		{
			return "attack with weapon";
		}
		if(canUse($skill[Saucestorm], false))
		{
			return useSkill($skill[Saucestorm], false);
		}
	}
	
	return "";
}
