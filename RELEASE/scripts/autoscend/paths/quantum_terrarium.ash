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
	if (in_quantumTerrarium())
	{
		// placeholder. Just spam the console with familiar info for now.
		auto_log_info(`In Quantum Terrarium. Current familiar = {my_familiar()}. Next familiar = {get_property("nextQuantumFamiliar")}`);
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

void finalizeMaximizeQTHotfix()
{
	//workaround for https://kolmafia.us/threads/quantum-familiar-support.26057/page-2#post-162544
	//where maximizer crashes autoscend when trying to take a foldable familiar equipment. It tries to steal it which does not work in QT.
	if(!in_quantumTerrarium())
	{
		return;
	}
	if(my_familiar() == $familiar[mini-hipster])			//temporary workaround manual handling of mini-hipster equipment
	{
		addToMaximize("-familiar");
		foreach it in $items[ironic moustache, fixed-gear bicycle]
		{
			if(equipped_amount(it) > 0)
			{
				cli_execute("fold chiptune guitar;");
			}
		}
		if(item_amount($item[chiptune guitar]) > 0 && equipped_amount($item[chiptune guitar]) == 0)
		{
			equip($item[chiptune guitar]);
		}
	}
	if(my_familiar() == $familiar[Baby Bugged Bugbear])		//temporary workaround manual handling of Baby Bugged Bugbear equipment
	{
		addToMaximize("-familiar");
		foreach it in $items[bugged balaclava, bugged b&Atilde;&para;n&plusmn;&Atilde;&copy;t]
		{
			if(equipped_amount(it) > 0)
			{
				cli_execute("fold bugged beanie;");
			}
		}
		if(item_amount($item[bugged beanie]) > 0 && equipped_amount($item[bugged beanie]) == 0)
		{
			equip($item[bugged beanie]);
		}
	}
}
