//2012 iotm and ioty handling

string auto_combat_nanorhinoBuff(int round, monster enemy, string text)
{
	//nanorhino familiar buff acquisition. Must be the first action taken in combat.
	//done after puzzle bosses. if puzzle bosses get a random buff that is ok, we would rather beat the puzzle boss.
	if(my_familiar() != $familiar[Nanorhino] || combat_status_check("nanorhino_buffed"))
	{
		return "";
	}
	if(get_property("_nanorhinoCharge").to_int() < 100)
	{
		return "";
	}

	skill target = $skill[none];
	boolean target_mark = false;
	
	switch(my_primestat())
	{
		case $stat[muscle]:				//get [Nanobrawny]: Muscle +25%, Weapon Damage +10, Regenerate 4-8 HP per Adventure
			if(target == $skill[none] && in_glover() && canUse($skill[Lunge Smack]) && canSurvive(4.0))
			{
				target = $skill[Lunge Smack];
			}
			if(target == $skill[none] && canUse($skill[Shell Up]))
			{
				target = $skill[Shell Up];	//6MP. bonus based on blessing. blocks enemy this round even if they are immune to stagger
			}
			if(target == $skill[none] && stunnable(enemy) && canUse($skill[Club Foot]) && my_class() == $class[Seal Clubber] && my_mp() > 25)
			{
				target = $skill[Club Foot];	//8MP. 3-5 enemy defense debuff. seal clubbers also stuns enemy
			}
			if(target == $skill[none] && canSurvive(4.0))		//choose the cheapest skill available
			{
				foreach sk in $skills[Toss, Clobber, Lunge Smack, Thrust-Smack, Headbutt, Kneebutt, Lunging Thrust-Smack, Club Foot, Shieldbutt, Spirit Snap, Cavalcade Of Fury, Northern Explosion, Spectral Snapper]
				{
					if(canUse(sk))
					{
						target = sk;
					}
				}
			}
			break;
		case $stat[mysticality]:			//get [Nanobrainy]: Mysticality +50%, Spell Damage +20, Regenerate 2-4 MP per Adventure
			//TODO
			break;
		case $stat[moxie]:					//get [Nanoballsy]: Moxie +25%, +20% Combat Initiative, +30% Pickpocket Chance
			if(target == $skill[none] && my_class() == $class[disco bandit] && auto_have_skill($skill[Disco State of Mind]) && auto_have_skill($skill[Flashy Dancer]) && stunnable(enemy))
			{
				//disco bandits can stun with a dance. and generally benefit from dancing
				foreach sk in $skills[Disco Dance of Doom, Disco Dance II: Electric Boogaloo, Disco Dance 3: Back in the Habit]
				{
					if(canUse(sk))
					{
						target = sk;
					}
				}
			}
			if(target == $skill[none] && canUse($skill[Accordion Bash]))
			{
				//stunner that deals no damage
				target = $skill[Accordion Bash];
				target_mark = true;
			}			
			if(!canSurvive(4.0))
			{
				break;		//too risky to continue
			}
			if(target == $skill[none] && canUse($skill[Cadenza]))
			{
				target = $skill[Cadenza];		//costs 0MP.
				target_mark = true;
			}
			if(target == $skill[none])			//choose the cheapest skill available
			{
				foreach sk in $skills[Sing, Suckerpunch, Disco Eye-Poke, Dissonant Riff]
				{
					if(canUse(sk))
					{
						target = sk;
					}
				}
			}
			break;
	}
	
	//regardless of whether we found a suitable skill or not, we only want to try once per combat.
	combat_status_add("nanorhino_buffed");
	if(target != $skill[none])
	{
		return useSkill(target, target_mark);
	}
	return "";
}
