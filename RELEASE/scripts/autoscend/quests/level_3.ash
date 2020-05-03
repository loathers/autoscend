script "level_3.ash"

boolean L3_tavern()
{
	if (internalQuestStatus("questL03Rat") < 0 || internalQuestStatus("questL03Rat") > 2)
	{
		return false;
	}

	if (internalQuestStatus("questL03Rat") < 1)
	{
		visit_url("tavern.php?place=barkeep");
	}

	int mpNeed = 0;
	if(have_skill($skill[The Sonata of Sneakiness]) && (have_effect($effect[The Sonata of Sneakiness]) == 0))
	{
		mpNeed = mpNeed + 20;
	}
	if(have_skill($skill[Smooth Movement]) && (have_effect($effect[Smooth Movements]) == 0))
	{
		mpNeed = mpNeed + 10;
	}

	boolean enoughElement = (numeric_modifier("cold damage") >= 20) && (numeric_modifier("hot damage") >= 20) && (numeric_modifier("spooky damage") >= 20) && (numeric_modifier("stench damage") >= 20);

	boolean delayTavern = false;

	if (isActuallyEd())
	{
		set_property("choiceAdventure1000", "1"); // Everything in Moderation: turn on the faucet (completes quest)
		set_property("choiceAdventure1001", "2"); // Hot and Cold Dripping Rats: Leave it alone (don't fight a rat)
	}
	else if(!enoughElement || (my_mp() < mpNeed))
	{
		if((my_daycount() <= 2) && (my_level() <= 11))
		{
			delayTavern = true;
		}
	}

	if(my_level() == get_property("auto_powerLevelLastLevel").to_int())
	{
		delayTavern = false;
	}

	if(get_property("auto_forceTavern").to_boolean())
	{
		delayTavern = false;
	}

	if(delayTavern)
	{
		return false;
	}

	auto_log_info("Doing Tavern", "blue");

	if((my_mp() > 60) || considerGrimstoneGolem(true))
	{
		handleBjornify($familiar[Grimstone Golem]);
	}

	auto_setMCDToCap();

	if (auto_tavern())
	{
		return true;
	}

	if (internalQuestStatus("questL03Rat") > 1)
	{
		visit_url("tavern.php?place=barkeep");
		council();
		return true;
	}
	return false;
}