//Path specific combat handling for Avatar of Jarlsberg

//AoJ spells have a hard DMG cap of 10*(MP Cost) before percentage modifiers are applied. 
//Things that change the MP costs will change said dmg cap.
//AoJ can **only** attack via spells / items
string auto_combatJarlsbergStage4(int round, monster enemy, string text)
{
	##stage 4 = kill
	if(!is_Jarlsberg())
	{
		return "";
	}
	
	//set the 0MP starting spell as base option
	string attackNoMP = useSkill($skill[Curdle], false);
	int costNoMP = mp_cost($skill[Curdle]);
	string attackMinor = useSkill($skill[Curdle], false);
	int costMinor = mp_cost($skill[Curdle]);
	string attackMajor = useSkill($skill[Curdle], false);
	int costMajor = mp_cost($skill[Curdle]);
	
	//NS replacement in AoJ - 50% Elemental Resistance, can block items
	if(enemy.to_string() == "The Avatar of Boris")
	{
		//Use the Physical Dmg Spells where possible
		if(canUse($skill[Chop]))
		{
			attackMinor = useSkill($skill[Chop], false);
			costMinor = mp_cost($skill[Chop]);
			attackMajor = useSkill($skill[Chop], false);
			costMajor = mp_cost($skill[Chop]);
		}

		if(canUse($skill[Slice]))
		{
			attackMajor = useSkill($skill[Slice], false);
			costMajor = mp_cost($skill[Slice]);
		}

	}


	if(my_mp() >= costMajor)
	{

		return attackMajor;
	}

	else if(my_mp() >= costMinor)
	{
		return attackMinor;
	}
	else
	{
		auto_log_warning("Uh-oh, I've run out of MP mid Combat", "red");
		return attackNoMP;
	}


}
