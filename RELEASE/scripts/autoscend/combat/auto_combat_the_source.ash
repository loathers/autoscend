//Path specific combat handling for The Source

string auto_combatTheSourceStage1(int round, monster enemy, string text)
{
	##stage1 = 1st round actions: puzzle boss, banish, escape, pickpocket, etc. things that need to be done before debuff
	
	if($monsters[One Thousand Source Agents, Source Agent] contains enemy)
	{
		if(auto_have_skill($skill[Data Siphon]))
		{
			if(my_mp() < 50)
			{
				if(auto_have_skill($skill[Source Punch]) && (my_mp() >= mp_cost($skill[Source Punch])))
				{
					return useSkill($skill[Source Punch], false);
				}
			}
			else if(my_mp() > 125)
			{
				if(canUse($skill[Reboot]) && ((have_effect($effect[Latency]) > 0) || ((my_hp() * 2) < my_maxhp())))
				{
					return useSkill($skill[Reboot]);
				}
				if(canUse($skill[Humiliating Hack]))
				{
					return useSkill($skill[Humiliating Hack]);
				}
				if(canUse($skill[Disarmament]))
				{
					return useSkill($skill[Disarmament]);
				}
				if(canUse($skill[Big Guns]) && (my_hp() < 100))
				{
					return useSkill($skill[Big Guns]);
				}

			}
			else if(my_mp() > 100)
			{
				if(canUse($skill[Humiliating Hack]))
				{
					return useSkill($skill[Humiliating Hack]);
				}
				if(canUse($skill[Disarmament]))
				{
					return useSkill($skill[Disarmament]);
				}
			}

			if(canUse($skill[Source Kick], false))
			{
				return useSkill($skill[Source Kick], false);
			}
		}

		if(canUse($skill[Big Guns]))
		{
			return useSkill($skill[Big Guns]);
		}
		if(canUse($skill[Source Punch], false))
		{
			return useSkill($skill[Source Punch], false);
		}
		return "runaway";
	}
	
	return "";
}

string auto_combatTheSourceStage4(int round, monster enemy, string text)
{
	##stage 4 = prekill. copy, sing along, flyer and other things that need to be done after delevel but before killing
	
	//source terminal iotm source path specific action. provokes an agent into attacking you next turn 3/day
	//is turn referring to combat round or next adv? this is placed in stage 4 on the assumption it means next adv. if it means next combat round then it should be moved to stage 2
	if(canUse($skill[Portscan]) && (my_location().turns_spent < 8) && (get_property("_sourceTerminalPortscanUses").to_int() < 3) && !get_property("_portscanPending").to_boolean())
	{
		if($locations[The Castle in the Clouds in the Sky (Ground Floor), The Haunted Bathroom, The Haunted Gallery] contains my_location())
		{
			set_property("_portscanPending", true);
			return useSkill($skill[Portscan]);
		}
	}
	
	return "";
}
