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
