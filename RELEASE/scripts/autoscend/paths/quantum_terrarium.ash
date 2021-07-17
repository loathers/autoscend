boolean in_quantumTerrarium()
{
	return auto_my_path() == "Quantum Terrarium";
}

boolean qt_currentFamiliar(familiar fam)
{
	return in_quantumTerrarium() && my_familiar() == fam;
}

familiar qt_nextQuantumFamiliar()
{
	return get_property("nextQuantumFamiliar").to_familiar();
}

int qt_turnsToNextQuantumAlignment()
{
	return total_turns_played() - get_property("_nextQuantumAlignment").to_int();
}

boolean LX_quantumTerrarium()
{
	if (!in_quantumTerrarium())
	{
		return false;
	}

	switch(my_familiar())
	{
		// lets order this by familiar ID in ascending order
		case $familiar[Machine Elf]:
			// use free fights for experience and abstractions
			if (get_property("_machineTunnelsAdv").to_int() < 5)
			{
				return autoAdv(1, $location[The Deep Machine Tunnels]);
			}
			break;
		case $familiar[God Lobster]:
			// use free fights for experience
			if (auto_godLobsterFightsRemaining() > 0)
			{
				if (my_basestat(my_primestat()) < 70)
				{
					// 33 advs worth of +10 stats/combat is better than 1.5*70 to all 3 stats
					if (!possessEquipment($item[God Lobster's Scepter]))
					{
						// fight it with no equipment to get the Scepter
						return godLobsterCombat($item[none], 1);
					}
					else
					{
						// fight it with the Scepter for the stats buff
						return godLobsterCombat($item[God Lobster's Scepter], 2);
					}
				} else {
					// get experience
					return godLobsterCombat();
				}
			}
			break;
		default:
			break;
	}
	return false;
}

void qt_initializeSettings()
{
	if (in_quantumTerrarium())
	{
		set_property("auto_skipNuns", true);	//Remove when leprechaun swapping is supported at nuns.
	}
}

string qt_TerrariumPage = visit_url("qterrarium.php");

boolean qt_FamiliarAvailable (familiar fam)
{
	//Check to see if target familiar can be forced.
	string qt_FamiliarKey = "<option value=\"" + fam.to_int().to_string() + "\">";
	matcher qt_FamiliarSearch = create_matcher(qt_FamiliarKey, qt_TerrariumPage);

	if (qt_turnsToNextQuantumAlignment() > 1)
	{
		return false;
	}
	else if (find(qt_FamiliarSearch))
	{
		return true;
	}
	else 
	{
		return false;
	}
}

boolean qt_FamiliarSwap (familiar fam)
{
	//Swap/designate next familiar swap if possible.
	if (fam == $familiar[none])
	{
		print(fam.to_string() + " is not a valid familiar, weird behaviour.");
		return false;
	}
	else if (qt_FamiliarAvailable(fam))
	{
		visit_url("qterrarium.php?pwd=&action=fam&fid="+ fam.to_int());
		return true;
	}
	else
	{
		return false;
	}
}

boolean qt_EatSpleen()
{
	if(!in_quantumTerrarium())
	{
		return false;
	}
	
	//called to eat size 4 spleen items when adventures < 10 and we can't eat or drink anything
	
	int oldSpleenUse = my_spleen_use();
	
	//do we wait until the last adventure to chew spleen?
	boolean waitUntilLastAdventure = false;
	if(item_amount($item[stench jelly]) >= 2)
	{
		int spleenForStenchJelly = min(my_adventures(),item_amount($item[stench jelly]));
		//wait if chewing 4 spleen would take away the chance to use 2 or more stench jellies
		if (oldSpleenUse - spleenForStenchJelly <= 2)
		{
			waitUntilLastAdventure = true;
		}
	}
	if(auto_havePillKeeper() && spleen_left() == 6)
	{
		//if you have pill keeper maybe two force noncombat is better than chewing for adventures?
		waitUntilLastAdventure = true;
	}
	if(waitUntilLastAdventure && my_adventures() > 1)
	{
		return false;
	}
	
	if(spleen_left() >= 4)
	{
		//first the ones without the level 4 requirement because they give more stats
		foreach it in $items[Unconscious Collective Dream Jar, Grim Fairy Tale, Powdered Gold, Groose Grease]
		{
			if(item_amount(it) > 0)
			{
				autoChew(1, it);
				break;
			}
		}
		if(have_effect($effect[Just the Best Anapests])>0)
		{
			uneffect($effect[Just the Best Anapests]);
		}
		if(my_level() >= 4 && oldSpleenUse == my_spleen_use())
		{
			foreach it in $items[beastly paste, bug paste, cosmic paste, oily paste, demonic paste, gooey paste, elemental paste, Crimbo paste, fishy paste, goblin paste, hippy paste, hobo paste, indescribably horrible paste, greasy paste, Mer-kin paste, orc paste, penguin paste, pirate paste, chlorophyll paste, slimy paste, ectoplasmic paste, strange paste,Agua De Vida]
			{
				if(item_amount(it) > 0)
				{
					autoChew(1, it);
					break;
				}
			}
		}
	}

	return oldSpleenUse != my_spleen_use();
}
