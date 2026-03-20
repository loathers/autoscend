boolean amw_wanttoPP(monster enemy)
{
	if(!in_amw()){
		return "";
	}
	if(!auto_have_skill($skill[Chicken Fingers]))
	{
		return false;
	}
	// cannot autosell for meat so pickpocketing is less profitable
	// maybe exempt certain monsters?
	if(!canSurvive(8.0))
	{
		return false;
	}
	return true;
}

string auto_combatMeatGolemStage3(int round, monster enemy, string text)
{
	if(!in_amw()){
		return "";
	}

	// this delevel also might deal lots of damage
	// Skip if monster would die quickly, before stage 4 might finish
	if((monster_hp() - my_buffedstat($stat[muscle]))/monster_hp()<0.55){return "";}
	// since meat = adv, don't want to delevel if not necessary
	// also skipping if we might die after delevel
	if(!canSurvive(8.0) && canSurvive(0.7) && canUse($skill[Meat Cleaver], true, true))
	{
		return useSkill($skill[Meat Cleaver]);
	}

	return "";
}

string auto_combatMeatGolemStage5(int round, monster enemy, string text)
{
	if(!in_amw())
	{
		return "";
	}

	// make sure to heal if possible; consider restoring "!canSurvive(1.4) &&" if mafia's autoheal behavior is fixed
	if(canUse($skill[Chew the Fat], false) && my_hp() < my_maxhp() * 0.95){
		return(useSkill($skill[Chew the Fat], false));
	}

	boolean enemy_physical_resistant = enemy.physical_resistance > 70;

	if(enemy_physical_resistant && canUse($skill[Spicy Meatball], False)) // one elemental attack confirmed
	{
		// if we have no other choice or the monster is sleazy, we want hot for sure
		if(!canUse($skill[Bacon Ray], false) || (enemy.defense_element == $element[sleaze])){
			return(useSkill($skill[SpicyMeatball], false));
		}
		// multiplied myst to penalize bacon ray taking 2x long (at half cost)
		if ((my_buffedstat($stat[moxie]) > 1.8*my_buffedstat($stat[mysticality])) || (enemy.defense_element == $element[hot])){
			return(useSkill($skill[Bacon Ray], false));
		}
		return(useSkill($skill[SpicyMeatball], false));
	}
	else if(enemy_physical_resistant){
		if(canUse($skill[Bacon Ray], false)){
			return(useSkill($skill[Bacon Ray], false));
		}
		else {return "";} // nothing we can do from a class perspective now
	}

	if(have_equipped($item[Everfull Dart Holster]) && get_property("_dartsLeft").to_int() > 0)
	{
		return useSkill(dartSkill());
	}

	// non elemental damage, case 1 sleaze, case 2 hot, case 3 neither
	if(!enemy_physical_resistant && enemy.defense_element == $element[sleaze])
	{
		if((my_buffedstat($stat[muscle]) > my_buffedstat($stat[mysticality]) || !canUse($skill[Spicy Meatball])) && canUse($skill[Beef Shank], false)){
			return useSkill($skill[Beef Shank], false);
		}
		else if(canUse($skill[Spicy Meatball])){
			return useSkill($skill[Spicy Meatball], false);
		}
	}
	if(!enemy_physical_resistant && enemy.defense_element == $element[hot])
	{
		if((my_buffedstat($stat[muscle]) > 1.8*my_buffedstat($stat[moxie]) || !canUse($skill[Bacon Ray])) && canUse($skill[Beef Shank], false)){
			return useSkill($skill[Beef Shank], false);
		}
		else if(canUse($skill[Spicy Meatball])){
			return useSkill($skill[Bacon Ray], false);
		}
	}
	if(!enemy_physical_resistant)
	{
		// beef shank available
		if(canUse($skill[Beef Shank]) && (my_buffedstat($stat[muscle]) > my_buffedstat($stat[mysticality]) || !canUse($skill[Spicy Meatball]))){
			if((my_buffedstat($stat[muscle]) > 1.8*my_buffedstat($stat[moxie]) || !canUse($skill[Bacon Ray]))){
				return useSkill($skill[Beef Shank], false);
			}
		}
		if(canUse($skill[Spicy Meatball], False))
		{
			// if we have no other choice or the monster is sleazy, we want hot for sure
			if(!canUse($skill[Bacon Ray], false) || (enemy.defense_element == $element[sleaze])){
				return(useSkill($skill[SpicyMeatball], false));
			}
			if ((my_buffedstat($stat[moxie]) > 1.8*my_buffedstat($stat[mysticality])) || (enemy.defense_element == $element[hot])){
				return(useSkill($skill[Bacon Ray], false));
			}
			return(useSkill($skill[SpicyMeatball], false));
		}

		if(canUse($skill[Bacon Ray], false)){
			return(useSkill($skill[Bacon Ray], false));
		}
	}
	return "";
}