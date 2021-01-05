boolean L2_mosquito()
{
	if (internalQuestStatus("questL02Larva") < 0 || internalQuestStatus("questL02Larva") > 1)
	{
		return false;
	}
	if (canBurnDelay($location[The Spooky Forest]))
	{
		// Arboreal Respite choice adventure has a delay of 5 adventures.
		return false;
	}
	auto_log_info("Trying to find a mosquito.", "blue");
	if (autoAdv($location[The Spooky Forest])) {
		if (internalQuestStatus("questL02Larva") > 0 || item_amount($item[mosquito larva]) > 0)
		{
			council();
			if (in_koe())
			{
				cli_execute("refresh quests");
			}
		}
		return true;
	}
	return false;
}
