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
