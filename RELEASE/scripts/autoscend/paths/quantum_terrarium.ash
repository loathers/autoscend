boolean in_quantumTerrarium()
{
	return auto_my_path() == "Quantum Terrarium";
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
	// TODO. Pathing goes here.
	return false;
}