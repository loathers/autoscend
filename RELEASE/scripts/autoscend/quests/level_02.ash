void spookyForestChoiceHandler(int choice)
{
	if(choice == 502) // Arboreal Respite (The Spooky Forest)
	{
		if(internalQuestStatus("questL02Larva") == 0 && item_amount($item[mosquito larva]) == 0)
		{
			// need the mosquito larva
			run_choice(2); // go to Consciousness of a Stream (#505)
		}
		else if(!hidden_temple_unlocked())
		{
			if(item_amount($item[Tree-Holed Coin]) == 0 && item_amount($item[Spooky Temple map]) == 0)
			{
				// need the tree-holed coin
				run_choice(2); // go to Consciousness of a Stream (#505)
			}
			else if(item_amount($item[Spooky Temple map]) == 0 || item_amount($item[Spooky-Gro Fertilizer]) == 0)
			{
				// have the coin, need the spooky temple map and spooky-gro fertilizer
				run_choice(3); // go to Through Thicket and Thinnet (#506)
			}
			else
			{
				// need the spooky sapling
				run_choice(1); // go to The Road Less Traveled (#503)
			}
		}
		else
		{
			auto_log_warning("In Arboreal Respite for some reason but we don't need a mosquito larva or to unlock the hidden temple!");
			run_choice(2); // go to Consciousness of a Stream (#505)
		}
	}
	else if(choice == 503) // The Road Less Traveled (The Spooky Forest)
	{
		run_choice(3); // go to Tree's Last Stand (#504)
	}
	else if(choice == 504) // Tree's Last Stand (The Spooky Forest)
	{
		if(item_amount($item[bar skin]) > 1)
		{
			run_choice(2); // sell all bar skins (doesn't leave choice)
		}
		else if(item_amount($item[bar skin]) == 1)
		{
			run_choice(1); // sell bar skin (doesn't leave choice)
		}
		else if(!hidden_temple_unlocked() && item_amount($item[Spooky Sapling]) == 0 && my_meat() > 100)
		{
			run_choice(3); // get the spooky sapling (doesn't leave choice)
		}
		else
		{
			run_choice(4); // leave the choice
		}
	}
	else if(choice == 505) // Consciousness of a Stream (The Spooky Forest)
	{
		if(internalQuestStatus("questL02Larva") == 0 && item_amount($item[mosquito larva]) == 0)
		{
			run_choice(1); // Get the mosquito larva
		}
		else
		{
			run_choice(2); // Get the tree-holed coin or skip
		}
	}
	else if(choice == 506) // Through Thicket and Thinnet (The Spooky Forest)
	{
		if(!hidden_temple_unlocked() && item_amount($item[Spooky-Gro Fertilizer]) == 0)
		{
			run_choice(2); // get the spooky-gro fertilizer
		}
		else
		{
			run_choice(3); // go to O Lith, Mon (#507)
		}
	}
	else if(choice == 507) // O Lith, Mon (The Spooky Forest)
	{
		if(!hidden_temple_unlocked() && item_amount($item[Tree-Holed Coin]) > 0 && item_amount($item[Spooky Temple map]) == 0)
		{
			run_choice(1); // get the spooky temple map
		}
		else
		{
			run_choice(3); // skip
		}
	}
	else
	{
		abort("unhandled choice in spookyForestChoiceHandler");
	}
}

boolean L2_mosquito()
{
	if(internalQuestStatus("questL02Larva") < 0 || internalQuestStatus("questL02Larva") > 1)
	{
		return false;
	}
	if(canBurnDelay($location[The Spooky Forest]))
	{
		// Arboreal Respite choice adventure has a delay of 5 adventures.
		return false;
	}
	auto_log_info("Trying to find a mosquito.", "blue");
	if(autoAdv($location[The Spooky Forest]))
	{
		if(internalQuestStatus("questL02Larva") > 0 || item_amount($item[mosquito larva]) > 0)
		{
			council();
			if(in_koe())
			{
				cli_execute("refresh quests");
			}
		}
		return true;
	}
	return false;
}
