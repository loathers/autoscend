boolean in_aosol()
{
	return my_path() == $path[Avatar of Shadows Over Loathing];
}

void aosol_unCurse()
{
	//Only care about using these 2 because of the massive weakening they do while Cursed
	//Cursed Blanket is -Fam Weight, but if we are using it for Prismatic Res, we probably don't care about Fam Weight at that time
	//Cursed Arcane Orb is -Item Drop, but if we are using it for Prismatic Dmg, we probably don't care about Item Drop at that time
	//Cursed Dragon Wishbone is -Meat Drop, but if we are using it for Item Drop, we probably don't care about Meat Drop at that time
	/* if(item_amount($item[Cursed Cape]) > 0) //Vulnerability to 2 elements
	{
		use(1, $item[Cursed Cape]);
	}*/
	if(item_amount($item[Cursed Bat Paw]) > 0) //+ML and -Attributes
	{
		//use(1, $item[Cursed Bat Paw]);
		visit_url("inv_use.php?pwd=&which=2&whichitem=11147");
	}
	/*if(item_amount($item[Cursed Stats]) > 0) //+ML and -Attributes
	{
		use(1, $item[Cursed Stats]);
	}
	if(item_amount($item[Cursed Machete]) > 0) //+ML and -Attributes
	{
		use(1, $item[Cursed Machete]); 
	}*/ //Commented out until the items are in Mafia
}

boolean aosol_buySkills()
{
	if(!in_aosol())
	{
		return false;
	}
	if(my_class() == $class[Pig Skinner])
	{
		string page = visit_url("inv_use.php?pwd=&which=3&whichitem=11163");
		if(!have_skill($skill[Ribald Memories]) && my_level()>=1 && my_meat()>100) //passive sleaze res and sleaze dmg
		{
			page = visit_url("choice.php?pwd=&whichchoice=1495&option=1&whichsk=1", true);
		}
		if(!have_skill($skill[Blasted Glutes]) && my_level()>=2 && my_meat()>200) //max hp +50%
		{
			page = visit_url("choice.php?pwd=&whichchoice=1495&option=1&whichsk=2", true);
		}
		if(!have_skill($skill[Stretch]) && my_level()>=2 && my_meat()>200) //Stretched (10 advs, +75% Initiative)
		{
			page = visit_url("choice.php?pwd=&whichchoice=1495&option=1&whichsk=12", true);
		}
		if(!have_skill($skill[Ball Throw]) && my_level()>=3 && my_meat()>300) //Deal your Mus in Phys Dmg
		{
			page = visit_url("choice.php?pwd=&whichchoice=1495&option=1&whichsk=13", true);
		}
		if(!have_skill($skill[Strong Back]) && my_level()>=3 && my_meat()>300) //Passive Mus +20
		{
			page = visit_url("choice.php?pwd=&whichchoice=1495&option=1&whichsk=3", true);
		}
		if(!have_skill($skill[Noogie]) && my_level()>=4 && my_meat()>400) //Weaken and stun enemy
		{
			page = visit_url("choice.php?pwd=&whichchoice=1495&option=1&whichsk=14", true);
		}
		if(!have_skill($skill[Overconfidence]) && my_level()>=4 && my_meat()>400) //+3 Mus Stats per Fight
		{
			page = visit_url("choice.php?pwd=&whichchoice=1495&option=1&whichsk=4", true);
		}
		if(!have_skill($skill[Anatomy Expertise]) && my_level()>=5 && my_meat()>500) //Damaging skills have chance to double dmg
		{
			page = visit_url("choice.php?pwd=&whichchoice=1495&option=1&whichsk=5", true);
		}
		if(!have_skill($skill[Hot Foot]) && my_level()>=5 && my_meat()>500) //Deal Mys in Fire Dmg and set enemy on fire
		{
			page = visit_url("choice.php?pwd=&whichchoice=1495&option=1&whichsk=15", true);
		}
		if(!have_skill($skill[Fancy Footwork]) && my_level()>=6 && my_meat()>600) //25% Item Drops
		{
			page = visit_url("choice.php?pwd=&whichchoice=1495&option=1&whichsk=6", true);
		}
		if(!have_skill($skill[Second Wind]) && my_level()>=6 && my_meat()>600) //Restore 50% max HP during combat
		{
			page = visit_url("choice.php?pwd=&whichchoice=1495&option=1&whichsk=16", true);
		}
		if(!have_skill($skill[Stop Hitting Yourself]) && my_level()>=7 && my_meat()>700) //Deal Moxie in phys dmg and stun
		{
			page = visit_url("choice.php?pwd=&whichchoice=1495&option=1&whichsk=17", true);
		}
		if(!have_skill($skill[Taut Hamstrings]) && my_level()>=7 && my_meat()>700) //Passive +50% Initiative
		{
			page = visit_url("choice.php?pwd=&whichchoice=1495&option=1&whichsk=7", true);
		}
		if(!have_skill($skill[Cheerlead]) && my_level()>=8 && my_meat()>800) //Cheerled (10 advs, +50% all stats)
		{
			page = visit_url("choice.php?pwd=&whichchoice=1495&option=1&whichsk=18", true);
		}
		if(!have_skill($skill[Ripped Triceps]) && my_level()>=8 && my_meat()>800) //Damaging skills deal 25% more dmg
		{
			page = visit_url("choice.php?pwd=&whichchoice=1495&option=1&whichsk=8", true);
		}
		if(!have_skill($skill[Free-For-All]) && my_level()>=9 && my_meat()>900) //Free kill
		{
			page = visit_url("choice.php?pwd=&whichchoice=1495&option=1&whichsk=19", true);
		}
		if(!have_skill($skill[Head in the Game]) && my_level()>=9 && my_meat()>900) //+50% chance of Crit
		{
			page = visit_url("choice.php?pwd=&whichchoice=1495&option=1&whichsk=9", true);
		}
		if(!have_skill($skill[Competitive Instincts]) && my_level()>=10 && my_meat()>1000) //+100% Meat
		{
			page = visit_url("choice.php?pwd=&whichchoice=1495&option=1&whichsk=10", true);
		}
		if(!have_skill($skill[Tape Up]) && my_level()>=10 && my_meat()>1000) //Taped Up (10 advs, +100% Max HP, +100 DA, Regen 8-10 HP)
		{
			page = visit_url("choice.php?pwd=&whichchoice=1495&option=1&whichsk=20", true);
		}
		if(!have_skill($skill[Matter Over Mind]) && my_level()>=11 && my_meat()>1100) //+25% Max MP
		{
			page = visit_url("choice.php?pwd=&whichchoice=1495&option=1&whichsk=11", true);
		}
		if(!have_skill($skill[Punt]) && my_level()>=11 && my_meat()>1100) //Banish for the day
		{
			page = visit_url("choice.php?pwd=&whichchoice=1495&option=1&whichsk=21", true);
		}
	}
	return false;
}