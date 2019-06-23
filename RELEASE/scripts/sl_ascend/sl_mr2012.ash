script "sl_mr2012.ash"

boolean sl_reagnimatedGetPart()
{
	// UNTESTED, DON'T ACTUALLY CALL UNTIL TESTED
	if(!sl_have_familiar($familiar[Reagnimated Gnome]))
	{
		return false;
	}

	use_familiar($familiar[Reagnimated Gnome]);
	foreach part in $items[gnomish housemaid's kgnee, gnomish coal miner's lung, gnomish athlete's foot, gnomish tennis elbow, gnomish swimmer's ears]
	{
		if(possessEquipment(part))
		{
			continue;
		}

		int selection = part.to_int() - $item[gnomish swimmer's ears].to_int() + 1;
		set_property("choiceAdventure597", selection);
		visit_url("arena.php");

		return possessEquipment(part);
	}

	return false;
}
