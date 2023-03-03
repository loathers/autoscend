boolean in_aosol()
{
	return my_path() == $path[Avatar of Shadows Over Loathing];
}

boolean aosol_initializeSettings()
{
	if(in_aosol())
	{
		set_property("auto_aosolLastSkill", 0);
		set_property("auto_wandOfNagamar", false);
	}
	return false;
}

void aosol_unCurse()
{
	//Only care about using these 2 because of the massive weakening they do while Cursed
	//Cursed Blanket is -Fam Weight, but if we are using it for Prismatic Res, we probably don't care about Fam Weight at that time
	//Cursed Arcane Orb is -Item Drop, but if we are using it for Prismatic Dmg, we probably don't care about Item Drop at that time
	//Cursed Dragon Wishbone is -Meat Drop, but if we are using it for Item Drop, we probably don't care about Meat Drop at that time
	if(get_property("auto_aosol_dontUnCurse").to_boolean()) return;
	if(item_amount($item[Cursed Goblin Cape]) > 0) //-15% combat and vulnerability to 2 elements
	{
		visit_url("inv_use.php?pwd&which=2&whichitem=11149"); //-5% combat after uncursing
		cli_execute("refresh inventory");
	}
	if(item_amount($item[Cursed Bat Paw]) > 0) //+ML and -Attributes
	{
		visit_url("inv_use.php?pwd&which=2&whichitem=11147"); //-25 ML after uncursing
		cli_execute("refresh inventory");
	}
	if(item_amount($item[Cursed Stats]) > 0) //+5 stats but limits stats to NIIIIICCCCEE (69)
	{
		visit_url("inv_use.php?pwd&which=2&whichitem=11153");
		cli_execute("refresh inventory");
	}
	if(item_amount($item[Cursed Machete]) > 0) //+50% meat, but cut yourself every turn
	{
		visit_url("inv_use.php?pwd&which=2&whichitem=11157"); //+20% meat after uncursing
		cli_execute("refresh inventory");
	}
	if(item_amount($item[Cursed Medallion]) > 0) //+100% initiative, but -50% Weapon Dmg and -50% Spell Dmg
	{
		visit_url("inv_use.php?pwd&which=2&whichitem=11161"); //+25% Initiative after uncursing
		cli_execute("refresh inventory");
	}
}

boolean aosol_buySkills()
{
	if(!in_aosol())
	{
		return false;
	}

	if(get_property("auto_aosolLastSkill").to_int() < my_level())
	{
		if(my_class() == $class[Pig Skinner])
		{
			string page = visit_url("inv_use.php?pwd&which=3&whichitem=11163");

			//Check if there are already skill points
			matcher my_skillPoints = create_matcher("You have <b>(\\d+)<\\/b> skill", page);
			if(my_skillPoints.find())
			{
				int skillPoints = to_int(my_skillPoints.group(1));
				auto_log_info("Skill points found: " + skillPoints);
				while(skillPoints > 0)
				{
					if(!have_skill($skill[Punt])) //Banish for the day
					{
						page = visit_url("choice.php?pwd&option=1&whichchoice=1495&use=points&whichsk=21", true);
					}
					if(!have_skill($skill[Second Wind])) //Restore 50% max HP during combat
					{
						page = visit_url("choice.php?pwd&option=1&whichchoice=1495&use=points&whichsk=16", true);
					}
					if(!have_skill($skill[Free-For-All])) //Free kill
					{
						page = visit_url("choice.php?pwd&option=1&whichchoice=1495&use=points&whichsk=19", true);
					}
					if(!have_skill($skill[Hot Foot])) //Deal Mys in Fire Dmg and set enemy on fire
					{
						page = visit_url("choice.php?pwd&option=1&whichchoice=1495&use=points&whichsk=15", true);
					}
					if(!have_skill($skill[Competitive Instincts])) //+100% Meat
					{
						page = visit_url("choice.php?pwd&option=1&whichchoice=1495&use=points&whichsk=10", true);
					}
					if(!have_skill($skill[Noogie])) //Weaken and stun enemy
					{
						page = visit_url("choice.php?pwd&option=1&whichchoice=1495&use=points&whichsk=14", true);
					}
					if(!have_skill($skill[Fancy Footwork])) //25% Item Drops
					{
						page = visit_url("choice.php?pwd&option=1&whichchoice=1495&use=points&whichsk=6", true);
					}
					if(!have_skill($skill[Cheerlead])) //Cheerled (10 advs, +50% all stats)
					{
						page = visit_url("choice.php?pwd&option=1&whichchoice=1495&use=points&whichsk=18", true);
					}
					if(!have_skill($skill[Strong Back])) //Passive Mus +20
					{
						page = visit_url("choice.php?pwd&option=1&whichchoice=1495&use=points&whichsk=3", true);
					}
					if(!have_skill($skill[Stop Hitting Yourself])) //Deal Moxie in phys dmg and stun
					{
						page = visit_url("choice.php?pwd&option=1&whichchoice=1495&use=points&whichsk=17", true);
					}
					if(!have_skill($skill[Ball Throw])) //Deal your Mus in Phys Dmg
					{
						page = visit_url("choice.php?pwd&option=1&whichchoice=1495&use=points&whichsk=13", true);
					}
					if(!have_skill($skill[Anatomy Expertise])) //Damaging skills have chance to double dmg
					{
						page = visit_url("choice.php?pwd&option=1&whichchoice=1495&use=points&whichsk=5", true);
					}
					if(!have_skill($skill[Overconfidence])) //+3 Mus Stats per Fight
					{
						page = visit_url("choice.php?pwd&option=1&whichchoice=1495&use=points&whichsk=4", true);
					}
					if(!have_skill($skill[Blasted Glutes])) //max hp +50%
					{
						page = visit_url("choice.php?pwd&option=1&whichchoice=1495&use=points&whichsk=2", true);
					}
					if(!have_skill($skill[Taut Hamstrings])) //Passive +50% Initiative
					{
						page = visit_url("choice.php?pwd&option=1&whichchoice=1495&use=points&whichsk=7", true);
					}
					if(!have_skill($skill[Head in the Game])) //+50% chance of Crit
					{
						page = visit_url("choice.php?pwd&option=1&whichchoice=1495&use=points&whichsk=9", true);
					}
					if(!have_skill($skill[Ripped Triceps])) //Damaging skills deal 25% more dmg
					{
						page = visit_url("choice.php?pwd&option=1&whichchoice=1495&use=points&whichsk=8", true);
					}
					if(!have_skill($skill[Matter Over Mind])) //+25% Max MP
					{
						page = visit_url("choice.php?pwd&option=1&whichchoice=1495&use=points&whichsk=11", true);
					}
					if(!have_skill($skill[Ribald Memories])) //passive sleaze res and sleaze dmg
					{
						page = visit_url("choice.php?pwd&option=1&whichchoice=1495&use=points&whichsk=1", true);
					}
					if(!have_skill($skill[Stretch])) //Stretched (10 advs, +75% Initiative)
					{
						page = visit_url("choice.php?pwd&option=1&whichchoice=1495&use=points&whichsk=12", true);
					}
					if(!have_skill($skill[Tape Up])) //Taped Up (10 advs, +100% Max HP, +100 DA, Regen 8-10 HP)
					{
						page = visit_url("choice.php?pwd&option=1&whichchoice=1495&use=points&whichsk=20", true);
					}
					skillPoints -= 1;
				}
			}
			//If there are no skill points, we still want to buy skills outright
			if(!have_skill($skill[Ribald Memories]) && my_level()>=1 && my_meat()>100) //passive sleaze res and sleaze dmg
			{
				page = visit_url("choice.php?pwd&whichchoice=1495&option=1&whichsk=1", true);
				set_property("auto_aosolLastSkill", 1);
			}
			if(!have_skill($skill[Blasted Glutes]) && my_level()>=2 && my_meat()>200) //max hp +50%
			{
				page = visit_url("choice.php?pwd&whichchoice=1495&option=1&whichsk=2", true);
				set_property("auto_aosolLastSkill", 1);
			}
			if(!have_skill($skill[Stretch]) && my_level()>=2 && my_meat()>200) //Stretched (10 advs, +75% Initiative)
			{
				page = visit_url("choice.php?pwd&whichchoice=1495&option=1&whichsk=12", true);
				set_property("auto_aosolLastSkill", 2);
			}
			if(!have_skill($skill[Ball Throw]) && my_level()>=3 && my_meat()>300) //Deal your Mus in Phys Dmg
			{
				page = visit_url("choice.php?pwd&whichchoice=1495&option=1&whichsk=13", true);
				set_property("auto_aosolLastSkill", 2);
			}
			if(!have_skill($skill[Strong Back]) && my_level()>=3 && my_meat()>300) //Passive Mus +20
			{
				page = visit_url("choice.php?pwd&whichchoice=1495&option=1&whichsk=3", true);
				set_property("auto_aosolLastSkill", 3);
			}
			if(!have_skill($skill[Noogie]) && my_level()>=4 && my_meat()>400) //Weaken and stun enemy
			{
				page = visit_url("choice.php?pwd&whichchoice=1495&option=1&whichsk=14", true);
				set_property("auto_aosolLastSkill", 3);
			}
			if(!have_skill($skill[Overconfidence]) && my_level()>=4 && my_meat()>400) //+3 Mus Stats per Fight
			{
				page = visit_url("choice.php?pwd&whichchoice=1495&option=1&whichsk=4", true);
				set_property("auto_aosolLastSkill", 4);
			}
			if(!have_skill($skill[Anatomy Expertise]) && my_level()>=5 && my_meat()>500) //Damaging skills have chance to double dmg
			{
				page = visit_url("choice.php?pwd&whichchoice=1495&option=1&whichsk=5", true);
				set_property("auto_aosolLastSkill", 4);
			}
			if(!have_skill($skill[Hot Foot]) && my_level()>=5 && my_meat()>500) //Deal Mys in Hot Dmg and set enemy on fire
			{
				page = visit_url("choice.php?pwd&whichchoice=1495&option=1&whichsk=15", true);
				set_property("auto_aosolLastSkill", 5);
			}
			if(!have_skill($skill[Fancy Footwork]) && my_level()>=6 && my_meat()>600) //25% Item Drops
			{
				page = visit_url("choice.php?pwd&whichchoice=1495&option=1&whichsk=6", true);
				set_property("auto_aosolLastSkill", 5);
			}
			if(!have_skill($skill[Second Wind]) && my_level()>=6 && my_meat()>600) //Restore 50% max HP during combat
			{
				page = visit_url("choice.php?pwd&whichchoice=1495&option=1&whichsk=16", true);
				set_property("auto_aosolLastSkill", 6);
			}
			if(!have_skill($skill[Stop Hitting Yourself]) && my_level()>=7 && my_meat()>700) //Deal Moxie in phys dmg and stun
			{
				page = visit_url("choice.php?pwd&whichchoice=1495&option=1&whichsk=17", true);
				set_property("auto_aosolLastSkill", 6);
			}
			if(!have_skill($skill[Taut Hamstrings]) && my_level()>=7 && my_meat()>700) //Passive +50% Initiative
			{
				page = visit_url("choice.php?pwd&whichchoice=1495&option=1&whichsk=7", true);
				set_property("auto_aosolLastSkill", 7);
			}
			if(!have_skill($skill[Cheerlead]) && my_level()>=8 && my_meat()>800) //Cheerled (10 advs, +50% all stats)
			{
				page = visit_url("choice.php?pwd&whichchoice=1495&option=1&whichsk=18", true);
				set_property("auto_aosolLastSkill", 7);
			}
			if(!have_skill($skill[Ripped Triceps]) && my_level()>=8 && my_meat()>800) //Damaging skills deal 25% more dmg
			{
				page = visit_url("choice.php?pwd&whichchoice=1495&option=1&whichsk=8", true);
				set_property("auto_aosolLastSkill", 8);
			}
			if(!have_skill($skill[Free-For-All]) && my_level()>=9 && my_meat()>900) //Free kill
			{
				page = visit_url("choice.php?pwd&whichchoice=1495&option=1&whichsk=19", true);
				set_property("auto_aosolLastSkill", 8);
			}
			if(!have_skill($skill[Head in the Game]) && my_level()>=9 && my_meat()>900) //+50% chance of Crit
			{
				page = visit_url("choice.php?pwd&whichchoice=1495&option=1&whichsk=9", true);
				set_property("auto_aosolLastSkill", 9);
			}
			if(!have_skill($skill[Competitive Instincts]) && my_level()>=10 && my_meat()>1000) //+100% Meat
			{
				page = visit_url("choice.php?pwd&whichchoice=1495&option=1&whichsk=10", true);
				set_property("auto_aosolLastSkill", 9);
			}
			if(!have_skill($skill[Tape Up]) && my_level()>=10 && my_meat()>1000) //Taped Up (10 advs, +100% Max HP, +100 DA, Regen 8-10 HP)
			{
				page = visit_url("choice.php?pwd&whichchoice=1495&option=1&whichsk=20", true);
				set_property("auto_aosolLastSkill", 10);
			}
			if(!have_skill($skill[Matter Over Mind]) && my_level()>=11 && my_meat()>1100) //+25% Max MP
			{
				page = visit_url("choice.php?pwd&whichchoice=1495&option=1&whichsk=11", true);
				set_property("auto_aosolLastSkill", 10);
			}
			if(!have_skill($skill[Punt]) && my_level()>=11 && my_meat()>1100) //Banish for the day
			{
				page = visit_url("choice.php?pwd&whichchoice=1495&option=1&whichsk=21", true);
				set_property("auto_aosolLastSkill", 100);
			}
		}
		if(my_class() == $class[Cheese Wizard])
		{
			string page = visit_url("inv_use.php?pwd&which=3&whichitem=11164");

			//Check if there are already skill points
			matcher my_skillPoints = create_matcher("You have <b>(\\d+)<\\/b> skill", page);
			if(my_skillPoints.find())
			{
				int skillPoints = to_int(my_skillPoints.group(1));
				auto_log_info("Skill points found: " + skillPoints);
				while(skillPoints > 0)
				{
					if(!have_skill($skill[Fondeluge])) //50 turn yellow ray
					{
						page = visit_url("choice.php?pwd&whichchoice=1495&option=1&use=points&whichsk=21", true);
					}
					if(!have_skill($skill[Peccorino Bravado])) //+20% all stats
					{
						page = visit_url("choice.php?pwd&whichchoice=1495&option=1&use=points&whichsk=6", true);
					}
					if(!have_skill($skill[Fingers of Fontina])) //+50% item drops
					{
						page = visit_url("choice.php?pwd&whichchoice=1495&option=1&use=points&whichsk=11", true);
					}
					if(!have_skill($skill[Quick Wit])) //Passive Mys +20
					{
						page = visit_url("choice.php?pwd&whichchoice=1495&option=1&use=points&whichsk=3", true);
					}
					if(!have_skill($skill[Gather Cheese-Chi])) //Heal +30HP and stun enemy
					{
						page = visit_url("choice.php?pwd&whichchoice=1495&option=1&use=points&whichsk=14", true);
					}
					if(!have_skill($skill[Parmesan Missile])) //Deal your Mys in Stench, Hot, or Phys Dmg
					{
						page = visit_url("choice.php?pwd&whichchoice=1495&option=1&use=points&whichsk=13", true);
					}
					if(!have_skill($skill[Crack Knuckles])) //Deal Mus in phys Dmg and weaken enemy
					{
						page = visit_url("choice.php?pwd&whichchoice=1495&option=1&use=points&whichsk=15", true);
					}
					if(!have_skill($skill[Emmental Elemental])) //Deal Moxie in cold dmg and heal for same amt
					{
						page = visit_url("choice.php?pwd&whichchoice=1495&option=1&use=points&whichsk=17", true);
					}
					if(!have_skill($skill[Stilton Splatter])) //Deal mys in phys dmg and +fam exp
					{
						page = visit_url("choice.php?pwd&whichchoice=1495&option=1&use=points&whichsk=19", true);
					}
					if(!have_skill($skill[Bleu Brilliance])) //Cheese spells deal 50% more damage
					{
						page = visit_url("choice.php?pwd&whichchoice=1495&option=1&use=points&whichsk=8", true);
					}
					if(!have_skill($skill[Wisdom of Jarlsberg])) //+3 Mys stats per fight
					{
						page = visit_url("choice.php?pwd&whichchoice=1495&option=1&use=points&whichsk=7", true);
					}
					if(!have_skill($skill[Subcutaneous Gouda])) //passive DA +75, DR +5
					{
						page = visit_url("choice.php?pwd&whichchoice=1495&option=1&use=points&whichsk=2", true);
					}
					if(!have_skill($skill[Limberger Limberness])) //Passive +75% Initiative
					{
						page = visit_url("choice.php?pwd&whichchoice=1495&option=1&use=points&whichsk=4", true);
					}
					if(!have_skill($skill[Gorgonzola\'s Guile])) //+25% Item Drops
					{
						page = visit_url("choice.php?pwd&whichchoice=1495&option=1&use=points&whichsk=9", true);
					}
					if(!have_skill($skill[Medical Manchego])) //passive +20% max HP, regen 3-5 HP per adv
					{
						page = visit_url("choice.php?pwd&whichchoice=1495&option=1&use=points&whichsk=10", true);
					}
					if(!have_skill($skill[Swiss Cunning])) //-3mp to use skills
					{
						page = visit_url("choice.php?pwd&whichchoice=1495&option=1&use=points&whichsk=5", true);
					}
					if(!have_skill($skill[Mind Over Muenster])) //max mp +30%, regen 3-4 mp per adv
					{
						page = visit_url("choice.php?pwd&whichchoice=1495&option=1&use=points&whichsk=1", true);
					}
					if(!have_skill($skill[Mind Melt])) //Deal your Mys in hot damage and stun enemy
					{
						page = visit_url("choice.php?pwd&whichchoice=1495&option=1&use=points&whichsk=16", true);
					}
					if(!have_skill($skill[Reality Shift])) //Shifted Reality (10 advs, +3 prismatic res)
					{
						page = visit_url("choice.php?pwd&whichchoice=1495&option=1&use=points&whichsk=18", true);
					}
					if(!have_skill($skill[Cheddarmor])) //Cheddarmored (10 advs, +10 max HP, +50 DA, +3 DR)
					{
						page = visit_url("choice.php?pwd&whichchoice=1495&option=1&use=points&whichsk=12", true);
					}
					if(!have_skill($skill[Queso Fustulento])) //Queso Fustulento (10 advs, Stench dmg each round)
					{
						page = visit_url("choice.php?pwd&whichchoice=1495&option=1&use=points&whichsk=20", true);
					}
					skillPoints -= 1;
				}
			}
			//If there are no skill points, we still want to buy skills outright
			if(!have_skill($skill[Mind Over Muenster]) && my_level()>=1 && my_meat()>100) //max mp +30%, regen 3-4 mp per adv
			{
				page = visit_url("choice.php?pwd&whichchoice=1495&option=1&whichsk=1", true);
				set_property("auto_aosolLastSkill", 1);
			}
			if(!have_skill($skill[Cheddarmor]) && my_level()>=2 && my_meat()>200) //Cheddarmored (10 advs, +10 max HP, +50 DA, +3 DR)
			{
				page = visit_url("choice.php?pwd&whichchoice=1495&option=1&whichsk=12", true);
				set_property("auto_aosolLastSkill", 1);
			}
			if(!have_skill($skill[Subcutaneous Gouda]) && my_level()>=2 && my_meat()>200) //passive DA +75, DR +5
			{
				page = visit_url("choice.php?pwd&whichchoice=1495&option=1&whichsk=2", true);
				set_property("auto_aosolLastSkill", 2);
			}
			if(!have_skill($skill[Parmesan Missile]) && my_level()>=3 && my_meat()>300) //Deal your Mys in Stench, Hot, or Phys Dmg
			{
				page = visit_url("choice.php?pwd&whichchoice=1495&option=1&whichsk=13", true);
				set_property("auto_aosolLastSkill", 2);
			}
			if(!have_skill($skill[Quick Wit]) && my_level()>=3 && my_meat()>300) //Passive Mys +20
			{
				page = visit_url("choice.php?pwd&whichchoice=1495&option=1&whichsk=3", true);
				set_property("auto_aosolLastSkill", 3);
			}
			if(!have_skill($skill[Gather Cheese-Chi]) && my_level()>=4 && my_meat()>400) //Heal +30HP and stun enemy
			{
				page = visit_url("choice.php?pwd&whichchoice=1495&option=1&whichsk=14", true);
				set_property("auto_aosolLastSkill", 3);
			}
			if(!have_skill($skill[Limberger Limberness]) && my_level()>=4 && my_meat()>400) //Passive +75% Initiative
			{
				page = visit_url("choice.php?pwd&whichchoice=1495&option=1&whichsk=4", true);
				set_property("auto_aosolLastSkill", 4);
			}
			if(!have_skill($skill[Swiss Cunning]) && my_level()>=5 && my_meat()>500) //-3mp to use skills
			{
				page = visit_url("choice.php?pwd&whichchoice=1495&option=1&whichsk=5", true);
				set_property("auto_aosolLastSkill", 4);
			}
			if(!have_skill($skill[Crack Knuckles]) && my_level()>=5 && my_meat()>500) //Deal Mus in phys Dmg and weaken enemy
			{
				page = visit_url("choice.php?pwd&whichchoice=1495&option=1&whichsk=15", true);
				set_property("auto_aosolLastSkill", 5);
			}
			if(!have_skill($skill[Peccorino Bravado]) && my_level()>=6 && my_meat()>600) //+20% all stats
			{
				page = visit_url("choice.php?pwd&whichchoice=1495&option=1&whichsk=6", true);
				set_property("auto_aosolLastSkill", 5);
			}
			if(!have_skill($skill[Mind Melt]) && my_level()>=6 && my_meat()>600) //Deal your Mys in hot damage and stun enemy
			{
				page = visit_url("choice.php?pwd&whichchoice=1495&option=1&whichsk=16", true);
				set_property("auto_aosolLastSkill", 6);
			}
			if(!have_skill($skill[Emmental Elemental]) && my_level()>=7 && my_meat()>700) //Deal Moxie in cold dmg and heal for same amt
			{
				page = visit_url("choice.php?pwd&whichchoice=1495&option=1&whichsk=17", true);
				set_property("auto_aosolLastSkill", 6);
			}
			if(!have_skill($skill[Wisdom of Jarlsberg]) && my_level()>=7 && my_meat()>700) //+3 Mys stats per fight
			{
				page = visit_url("choice.php?pwd&whichchoice=1495&option=1&whichsk=7", true);
				set_property("auto_aosolLastSkill", 7);
			}
			if(!have_skill($skill[Reality Shift]) && my_level()>=8 && my_meat()>800) //Shifted Reality (10 advs, +3 prismatic res)
			{
				page = visit_url("choice.php?pwd&whichchoice=1495&option=1&whichsk=18", true);
				set_property("auto_aosolLastSkill", 7);
			}
			if(!have_skill($skill[Bleu Brilliance]) && my_level()>=8 && my_meat()>800) //Cheese spells deal 50% more damage
			{
				page = visit_url("choice.php?pwd&whichchoice=1495&option=1&whichsk=8", true);
				set_property("auto_aosolLastSkill", 8);
			}
			if(!have_skill($skill[Stilton Splatter]) && my_level()>=9 && my_meat()>900) //Deal mys in phys dmg and +fam exp
			{
				page = visit_url("choice.php?pwd&whichchoice=1495&option=1&whichsk=19", true);
				set_property("auto_aosolLastSkill", 8);
			}
			if(!have_skill($skill[Gorgonzola\'s Guile]) && my_level()>=9 && my_meat()>900) //+25% Item Drops
			{
				page = visit_url("choice.php?pwd&whichchoice=1495&option=1&whichsk=9", true);
				set_property("auto_aosolLastSkill", 9);
			}
			if(!have_skill($skill[Medical Manchego]) && my_level()>=10 && my_meat()>1000) //passive +20% max HP, regen 3-5 HP per adv
			{
				page = visit_url("choice.php?pwd&whichchoice=1495&option=1&whichsk=10", true);
				set_property("auto_aosolLastSkill", 9);
			}
			if(!have_skill($skill[Queso Fustulento]) && my_level()>=10 && my_meat()>1000) //Queso Fustulento (10 advs, Stench dmg each round)
			{
				page = visit_url("choice.php?pwd&whichchoice=1495&option=1&whichsk=20", true);
				set_property("auto_aosolLastSkill", 10);
			}
			if(!have_skill($skill[Fingers of Fontina]) && my_level()>=11 && my_meat()>1100) //+50% item drops
			{
				page = visit_url("choice.php?pwd&whichchoice=1495&option=1&whichsk=11", true);
				set_property("auto_aosolLastSkill", 10);
			}
			if(!have_skill($skill[Fondeluge]) && my_level()>=11 && my_meat()>1100) //50 turn yellow ray
			{
				page = visit_url("choice.php?pwd&whichchoice=1495&option=1&whichsk=21", true);
				set_property("auto_aosolLastSkill", 100);
			}
		}
		if(my_class() == $class[Jazz Agent])
		{
			string page = visit_url("inv_use.php?pwd&which=3&whichitem=11165");

			//Check if there are already skill points
			matcher my_skillPoints = create_matcher("You have <b>(\\d+)<\\/b> skill", page);
			if(my_skillPoints.find())
			{
				int skillPoints = to_int(my_skillPoints.group(1));
				auto_log_info("Skill points found: " + skillPoints);
				while(skillPoints > 0)
				{
					if(!have_skill($skill[Motif])) //25 turn blue ray (olfaction-esque)
					{
						page = visit_url("choice.php?pwd&whichchoice=1495&option=1&use=points&whichsk=21", true);
					}
					if(!have_skill($skill[Air of Mystery])) //First attack against you always misses
					{
						page = visit_url("choice.php?pwd&whichchoice=1495&option=1&use=points&whichsk=6", true);
					}
					if(!have_skill($skill[C Sharp Eyes])) //+50% item drop, +50% meat drop
					{
						page = visit_url("choice.php?pwd&whichchoice=1495&option=1&use=points&whichsk=5", true);
					}
					if(!have_skill($skill[Fashion Sense])) //Mox +20
					{
						page = visit_url("choice.php?pwd&whichchoice=1495&option=1&use=points&whichsk=3", true);
					}
					if(!have_skill($skill[Knife In The Darkness])) //Deal 50% of your foe's HP and gives 10 adv In The Darkness (-10% combat)
					{
						page = visit_url("choice.php?pwd&whichchoice=1495&option=1&use=points&whichsk=14", true);
					}
					if(!have_skill($skill[Orchestra Strike])) //Deal your Mox in Phys Dmg, Weaken Enemy
					{
						page = visit_url("choice.php?pwd&whichchoice=1495&option=1&use=points&whichsk=13", true);
					}
					if(!have_skill($skill[Venomous Riff])) //Deal Mys in dmg and poison foe
					{
						page = visit_url("choice.php?pwd&whichchoice=1495&option=1&use=points&whichsk=15", true);
					}
					if(!have_skill($skill[Sax of Violence])) //Deal Mus in Sleaze dmg
					{
						page = visit_url("choice.php?pwd&whichchoice=1495&option=1&use=points&whichsk=17", true);
					}
					if(!have_skill($skill[Grit Teeth])) //In combat 20 HP heal
					{
						page = visit_url("choice.php?pwd&whichchoice=1495&option=1&use=points&whichsk=19", true);
					}
					if(!have_skill($skill[Perfect Embrouchre])) //Musical skills deal 33% more damage
					{
						page = visit_url("choice.php?pwd&whichchoice=1495&option=1&use=points&whichsk=8", true);
					}
					if(!have_skill($skill[Virtuosity])) //+3 Moxie Stats per fight
					{
						page = visit_url("choice.php?pwd&whichchoice=1495&option=1&use=points&whichsk=10", true);
					}
					if(!have_skill($skill[Thick Calluses])) //DA +50, DR +3
					{
						page = visit_url("choice.php?pwd&whichchoice=1495&option=1&use=points&whichsk=1", true);
					}
					if(!have_skill($skill[Impeccable Timing])) //passive +100% combat initiative
					{
						page = visit_url("choice.php?pwd&whichchoice=1495&option=1&use=points&whichsk=2", true);
					}
					if(!have_skill($skill[Improv Muscles])) //+25% Max HP, +25% Initiatve
					{
						page = visit_url("choice.php?pwd&whichchoice=1495&option=1&use=points&whichsk=9", true);
					}
					if(!have_skill($skill[Rhythm In Your Blood])) //+20% Max HP
					{
						page = visit_url("choice.php?pwd&whichchoice=1495&option=1&use=points&whichsk=11", true);
					}
					if(!have_skill($skill[Rhythmic Precision])) //-3 MP to use skills
					{
						page = visit_url("choice.php?pwd&whichchoice=1495&option=1&use=points&whichsk=7", true);
					}
					if(!have_skill($skill[Jazz Hands])) //Regen 4-5 mp per adv
					{
						page = visit_url("choice.php?pwd&whichchoice=1495&option=1&use=points&whichsk=4", true);
					}
					if(!have_skill($skill[Drum Roll]) && my_level()>=6 && my_meat()>600) //Stun enemy for a few rounds
					{
						page = visit_url("choice.php?pwd&whichchoice=1495&option=1&use=points&whichsk=16", true);
					}
					if(!have_skill($skill[Tricky Timpani])) //Tricky Timpani (10 advs, +5 prismatic dmg)
					{
						page = visit_url("choice.php?pwd&whichchoice=1495&option=1&use=points&whichsk=18", true);
					}
					if(!have_skill($skill[Call For Backup])) //Reliable Backup (10 advs, +10 Fam Weight, Familiar acts more often)
					{
						page = visit_url("choice.php?pwd&whichchoice=1495&option=1&use=points&whichsk=12", true);
					}
					if(!have_skill($skill[Soothing Flute])) //Soothing Flute (10 advs, +5 fam weight, regen 8-10 hp per adv)
					{
						page = visit_url("choice.php?pwd&whichchoice=1495&option=1&use=points&whichsk=20", true);
					}
					skillPoints -= 1;
				}
			}
			//If there are no skill points, we still want to buy skills outright
			if(!have_skill($skill[Thick Calluses]) && my_level()>=1 && my_meat()>100) //DA +50, DR +3
			{
				page = visit_url("choice.php?pwd&whichchoice=1495&option=1&whichsk=1", true);
				set_property("auto_aosolLastSkill", 1);
			}
			if(!have_skill($skill[Call For Backup]) && my_level()>=2 && my_meat()>200) //Reliable Backup (10 advs, +10 Fam Weight, Familiar acts more often)
			{
				page = visit_url("choice.php?pwd&whichchoice=1495&option=1&whichsk=12", true);
				set_property("auto_aosolLastSkill", 1);
			}
			if(!have_skill($skill[Virtuosity]) && my_level()>=2 && my_meat()>200) //+3 Moxie Stats per fight
			{
				page = visit_url("choice.php?pwd&whichchoice=1495&option=1&whichsk=10", true);
				set_property("auto_aosolLastSkill", 2);
			}
			if(!have_skill($skill[Orchestra Strike]) && my_level()>=3 && my_meat()>300) //Deal your Mox in Phys Dmg, Weaken Enemy
			{
				page = visit_url("choice.php?pwd&whichchoice=1495&option=1&whichsk=13", true);
				set_property("auto_aosolLastSkill", 2);
			}
			if(!have_skill($skill[Fashion Sense]) && my_level()>=3 && my_meat()>300) //Mox +20
			{
				page = visit_url("choice.php?pwd&whichchoice=1495&option=1&whichsk=3", true);
				set_property("auto_aosolLastSkill", 3);
			}
			if(!have_skill($skill[Knife In The Darkness]) && my_level()>=4 && my_meat()>400) //Deal 50% of your foe's HP and gives 10 adv In The Darkness (-10% combat)
			{
				page = visit_url("choice.php?pwd&whichchoice=1495&option=1&whichsk=14", true);
				set_property("auto_aosolLastSkill", 3);
			}
			if(!have_skill($skill[Jazz Hands]) && my_level()>=4 && my_meat()>400) //Regen 4-5 mp per adv
			{
				page = visit_url("choice.php?pwd&whichchoice=1495&option=1&whichsk=4", true);
				set_property("auto_aosolLastSkill", 4);
			}
			if(!have_skill($skill[C Sharp Eyes]) && my_level()>=5 && my_meat()>500) //+50% item drop, +50% meat drop
			{
				page = visit_url("choice.php?pwd&whichchoice=1495&option=1&whichsk=5", true);
				set_property("auto_aosolLastSkill", 4);
			}
			if(!have_skill($skill[Venomous Riff]) && my_level()>=5 && my_meat()>500) //Deal Mys in dmg and poison foe
			{
				page = visit_url("choice.php?pwd&whichchoice=1495&option=1&whichsk=15", true);
				set_property("auto_aosolLastSkill", 5);
			}
			if(!have_skill($skill[Air of Mystery]) && my_level()>=6 && my_meat()>600) //First attack against you always misses
			{
				page = visit_url("choice.php?pwd&whichchoice=1495&option=1&whichsk=6", true);
				set_property("auto_aosolLastSkill", 5);
			}
			if(!have_skill($skill[Drum Roll]) && my_level()>=6 && my_meat()>600) //Stun enemy for a few rounds
			{
				page = visit_url("choice.php?pwd&whichchoice=1495&option=1&whichsk=16", true);
				set_property("auto_aosolLastSkill", 6);
			}
			if(!have_skill($skill[Sax of Violence]) && my_level()>=7 && my_meat()>700) //Deal Mus in Sleaze dmg
			{
				page = visit_url("choice.php?pwd&whichchoice=1495&option=1&whichsk=17", true);
				set_property("auto_aosolLastSkill", 6);
			}
			if(!have_skill($skill[Rhythmic Precision]) && my_level()>=7 && my_meat()>700) //-3 MP to use skills
			{
				page = visit_url("choice.php?pwd&whichchoice=1495&option=1&whichsk=7", true);
				set_property("auto_aosolLastSkill", 7);
			}
			if(!have_skill($skill[Tricky Timpani]) && my_level()>=8 && my_meat()>800) //Tricky Timpani (10 advs, +5 prismatic dmg)
			{
				page = visit_url("choice.php?pwd&whichchoice=1495&option=1&whichsk=18", true);
				set_property("auto_aosolLastSkill", 7);
			}
			if(!have_skill($skill[Perfect Embrouchre]) && my_level()>=8 && my_meat()>800) //Musical skills deal 33% more damage
			{
				page = visit_url("choice.php?pwd&whichchoice=1495&option=1&whichsk=8", true);
				set_property("auto_aosolLastSkill", 8);
			}
			if(!have_skill($skill[Grit Teeth]) && my_level()>=9 && my_meat()>900) //In combat 20 HP heal
			{
				page = visit_url("choice.php?pwd&whichchoice=1495&option=1&whichsk=19", true);
				set_property("auto_aosolLastSkill", 8);
			}
			if(!have_skill($skill[Improv Muscles]) && my_level()>=9 && my_meat()>900) //+25% Max HP, +25% Initiatve
			{
				page = visit_url("choice.php?pwd&whichchoice=1495&option=1&whichsk=9", true);
				set_property("auto_aosolLastSkill", 9);
			}
			if(!have_skill($skill[Impeccable Timing]) && my_level()>=10 && my_meat()>1000) //passive +100% combat initiative
			{
				page = visit_url("choice.php?pwd&whichchoice=1495&option=1&whichsk=2", true);
				set_property("auto_aosolLastSkill", 9);
			}
			if(!have_skill($skill[Soothing Flute]) && my_level()>=10 && my_meat()>1000) //Soothing Flute (10 advs, +5 fam weight, regen 8-10 hp per adv)
			{
				page = visit_url("choice.php?pwd&whichchoice=1495&option=1&whichsk=20", true);
				set_property("auto_aosolLastSkill", 10);
			}
			if(!have_skill($skill[Rhythm In Your Blood]) && my_level()>=11 && my_meat()>1100) //+20% Max HP
			{
				page = visit_url("choice.php?pwd&whichchoice=1495&option=1&whichsk=11", true);
				set_property("auto_aosolLastSkill", 10);
			}
			if(!have_skill($skill[Motif]) && my_level()>=11 && my_meat()>1100) //25 turn blue ray (olfaction-esque)
			{
				page = visit_url("choice.php?pwd&whichchoice=1495&option=1&whichsk=21", true);
				set_property("auto_aosolLastSkill", 100);
			}
		}
	}
	else
	{
		return false;
	}
	
	return false;
}

boolean pigSkinnerAcquireHP(int goal)
{
	while (my_hp() < goal)
	{
		break;
	}
	return goal >= my_hp();
}