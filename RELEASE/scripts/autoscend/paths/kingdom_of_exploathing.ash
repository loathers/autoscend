boolean in_koe()
{
	return my_path() == "37" || my_path() == "Kingdom of Exploathing";
}

boolean koe_initializeSettings()
{
	if(in_koe())
	{
		set_property("auto_bruteForcePalindome", in_hardcore());
		set_property("auto_holeinthesky", false);
		set_property("auto_paranoia", 3);
		set_property("auto_skipL12Farm", "true");
		set_property("auto_grimstoneOrnateDowsingRod", false);		//location not reachable in koe
		set_property("auto_grimstoneFancyOilPainting", false);		//location not reachable in koe
		return true;
	}
	return false;
}

int koe_rmi_count()
{
	//counts how much [rare meat isotopes] you effectively have. since you can convert meat to rmi with no limit at a 1000 to 1 ratio
	return item_amount($item[rare Meat Isotope]) + (my_meat()/1000);
}

boolean LX_koeInvaderHandler()
{
	if(!in_koe())
	{
		return false;
	}
	if (internalQuestStatus("questL13Final") < 3 || get_property("spaceInvaderDefeated").to_boolean())
	{
		// invader drops 10 white pixels so fight it before we do the hedge maze
		// as we need elemental resists for both and we may be able to get enough
		// pixels for the digital key if we still require them.
		return false;
	}

	if(have_effect($effect[Flared Nostrils]) > 0)
		doHottub();
	uneffect($effect[Flared Nostrils]);
	if(have_effect($effect[Flared Nostrils]) > 0)
	{
		// Delay until after the rest of the tower, I suppose
		return false;
	}

	buffMaintain($effect[Astral Shell], 10, 1, 1);
	buffMaintain($effect[Elemental Saucesphere], 10, 1, 1);
	buffMaintain($effect[Scarysauce], 10, 1, 1);

	resetMaximize();

	if(acquireOrPull($item[meteorb]))
	{
		autoEquip($slot[off-hand], $item[meteorb]);
	}

	simMaximizeWith("200 all res");

	float damagePerRound = 0.0;
	float baseDamage = 1.0 - 0.1 * my_daycount();
	foreach el in $elements[cold, hot, sleaze, spooky, stench]
	{
		float offset = auto_canBeachCombHead(el) ? 3.0 : 0.0;
		damagePerRound += baseDamage * (100.0 - elemental_resist_value(offset + simValue(el + " Resistance")))/100.0;
	}
	auto_log_info("The Invader: Expecting to take " + damagePerRound + " damage per round", "blue");
	int turns = ceil(0.95 / damagePerRound);

	int damageCap = 100 * my_daycount();

	// How many damage sources do we need?
	if(have_skill($skill[Weapon of the Pastalord]) && auto_is_valid($skill[Weapon of the Pastalord]))
	{
		int sources = 2;
		if(acquireOrPull($item[meteorb])) sources++;
		if(sources * turns * damageCap >= 1000)
		{
			foreach el in $elements[cold, hot, sleaze, spooky, stench]
			{
				auto_beachCombHead(el);
			}
			// Meteorb is going to add +hot, so remove that
			setFlavour($element[cold]);
			buffMaintain($effect[Carol of the Hells], 50, 1, 1);
			buffMaintain($effect[Song of Sauce], 150, 1, 1);
			buffMaintain($effect[Glittering Eyelashes], 0, 1, 1);
			acquireMP(100, 0);

			// Use maximizer now that we are for sure fighting the Invader
			addToMaximize("200 all res");

			set_property("choiceAdventure1393", 1); // Take care of it...
			boolean ret = autoAdv(1, $location[The Invader]);
			if(have_effect($effect[Beaten Up]) > 0)
			{
				abort("We died to the invader. Do it manually please?");
			}
			return ret;
		}
	}
	auto_log_warning("I don't think we're ready to kill the invader yet.", "blue");
	return false;
}

item koe_L12FoodSelect()
{
	//selects a desireable food item to toss at enemies during L12 war quest battlefield in koe
	item food_item = $item[none];
	foreach it in $items[pie man was not meant to eat, spaghetti with Skullheads, gnocchetti di Nietzsche, Spaghetti con calaveras, space chowder, Spaghetti with ghost balls, Crudles, Agnolotti arboli, Shells a la shellfish, Linguini immondizia bianco, Fettucini Inconnu, ghuol guolash, suggestive strozzapreti, Fusilli marrownarrow]
	{
		if(item_amount(it) > 0)
		{
			food_item = it;
			break;
		}
	}
	return food_item;
}

void koe_RationingOutDestruction()
{
	//this function handles choiceAdventure1391 Rationing out Destruction.
	//a koe specific event where you sacrifice food items to score battlefield kills during the L12 quest.
	item food_item = koe_L12FoodSelect();
	if(food_item == $item[none])
	{
		abort("I am at the choice adventure and do not know what food I should kill my enemies with during L12 war quest");
	}
	run_choice(1,"tossid=" +food_item.to_int());
}

boolean L12_koe_clearBattlefield()
{
	//kingdom of exploathing specific handling for clearing the battlefield.
	if(!in_koe())
	{
		return false;
	}
	if(internalQuestStatus("questL12HippyFrat") != 0)
	{
		//questL12War is used in most paths. but not used in koe
		//questL12HippyFrat is used exclusively in koe. it only has the values of: unstarted, started, finished.
		return false;
	}
	if(get_property("hippiesDefeated").to_int() >= 333 || get_property("fratboysDefeated").to_int() >= 333)
	{
		return false;
	}
	if(!haveWarOutfit())
	{
		return false;
	}
	
	//turn in the quest if done
	if(item_amount($item[solid gold bowling ball]) > 0)
	{
		council();
		if(internalQuestStatus("questL12HippyFrat") > 1)
		{
			return true;
		}
		else cli_execute("refresh quests");
		if(internalQuestStatus("questL12HippyFrat") < 2)
		{
			abort("Could not finish the L12 war quest for some reason");
		}
	}
	
	//prepare food to kill enemies with in the war. always keep a space chowder on hand if possible before going further. just in case.
	if(item_amount($item[space chowder]) == 0 && koe_rmi_count() > 4)
	{
		retrieve_item(1, $item[space chowder]);
	}
	if(koe_L12FoodSelect() == $item[none])
	{
		abort("I was unable to acquire a good food item to kill my enemies with in the L12 war quest");
	}

	//equip yourself for the war
	warOutfit(false);
	item warKillDoubler = my_primestat() == $stat[mysticality] ? $item[Jacob\'s rung] : $item[Haunted paddle-ball];
	pullXWhenHaveY(warKillDoubler, 1, 0);
	if(possessEquipment(warKillDoubler))
	{
		autoEquip($slot[weapon], warKillDoubler);
	}

	return autoAdv($location[The Exploaded Battlefield]);
}

boolean L12_koe_finalizeWar()
{
	if(!in_koe())
	{
		return false;
	}
	if(internalQuestStatus("questL12HippyFrat") != 0)
	{
		//questL12War is used in most paths. but not used in koe
		//questL12HippyFrat is used exclusively in koe. it only has the values of: unstarted, started, finished.
		return false;
	}
	if(get_property("hippiesDefeated").to_int() < 333 && get_property("fratboysDefeated").to_int() < 333)
	{
		return false;	//there are 333 of each enemy in koe. if either side had all 333 defeated then this will not return false here.
	}
	
	//koe does not have coin masters. there is nothing to sell here.
	warOutfit(false);
	acquireHP();
	acquireMP(60);
	auto_log_info("Let's fight the final boss of the frat-hippy war!", "blue");
	return autoAdv($location[The Exploaded Battlefield]);
}
