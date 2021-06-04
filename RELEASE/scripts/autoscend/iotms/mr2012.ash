#	This is meant for items that have a date of 2012

void auto_reagnimatedGetPart(int choice)
{
	if (available_amount($item[gnomish housemaid's kgnee]) == 0) // The housemaid's kgnee is the equipment that justified using the gnome.
	{
		run_choice(4);
	}
	else if (available_amount($item[gnomish coal miner's lung]) == 0) // May as well get the rest of these on subsequent days.
	{
		run_choice(2);
	}
	else if (available_amount($item[gnomish athlete's foot]) == 0)
	{
		run_choice(5);
	}
	else if (available_amount($item[gnomish tennis elbow]) == 0)
	{
		run_choice(3);
	}
	else if (available_amount($item[gnomish swimmer's ears]) == 0)
	{
		run_choice(1);
	}
	else
	{
		abort("unhandled choice in auto_reagnimatedGetPart");
	}
}

boolean handleRainDoh()
{
	if(item_amount($item[rain-doh box full of monster]) == 0)
	{
		return false;
	}
	if(my_level() <= 3)
	{
		return false;
	}
	if(have_effect($effect[ultrahydrated]) > 0)
	{
		return false;
	}

	monster enemy = to_monster(get_property("rainDohMonster"));
	auto_log_info("Black boxing: " + enemy, "blue");

	if(enemy == $monster[Ninja Snowman Assassin])
	{
		int count = item_amount($item[ninja rope]);
		count += item_amount($item[ninja crampons]);
		count += item_amount($item[ninja carabiner]);

		if((count <= 1) && (get_property("_raindohCopiesMade").to_int() < 5))
		{
			set_property("auto_doCombatCopy", "yes");
		}
		handleCopiedMonster($item[Rain-Doh Box Full of Monster]);
		if(last_monster() != $monster[ninja snowman assassin])
		{
			abort("Now sure what exploded, tried to summon copy of " + enemy + " but got " + last_monster() + " instead.");
		}
		set_property("auto_doCombatCopy", "no");
		if(count == 3)
		{
			set_property("auto_ninjasnowmanassassin", true);
		}
		return true;
	}
	if(enemy == $monster[Ghost])
	{
		int count = whitePixelCount();
		count += 30 * item_amount($item[digital key]);

		if((count <= 20) && (get_property("_raindohCopiesMade").to_int() < 5))
		{
			set_property("auto_doCombatCopy", "yes");
		}
		handleCopiedMonster($item[Rain-Doh Box Full of Monster]);
		if(last_monster() != $monster[ghost])
		{
			abort("Now sure what exploded, tried to summon copy of " + enemy + " but got " + last_monster() + " instead.");
		}
		set_property("auto_doCombatCopy", "no");
		if(count > 20)
		{
		}
		return true;
	}
	if(enemy == $monster[Lobsterfrogman])
	{
		if(have_skill($skill[Rain Man]) && (item_amount($item[barrel of gunpowder]) < 4))
		{
			set_property("auto_doCombatCopy", "yes");
		}
		handleCopiedMonster($item[Rain-Doh Box Full of Monster]);
		if(last_monster() != $monster[lobsterfrogman])
		{
			abort("Now sure what exploded, tried to summon copy of " + enemy + " but got " + last_monster() + " instead.");
		}
		set_property("auto_doCombatCopy", "no");
		return true;
	}
	if(enemy == $monster[Skinflute])
	{
		int stars = item_amount($item[star]);
		int lines = item_amount($item[line]);

		if((stars < 7) && (lines < 6)  & (get_property("_raindohCopiesMade").to_int() < 5))
		{
			set_property("auto_doCombatCopy", "yes");
		}
		handleCopiedMonster($item[Rain-Doh Box Full of Monster]);
		if(last_monster() != $monster[skinflute])
		{
			abort("Now sure what exploded, tried to summon copy of " + enemy + " but got " + last_monster() + " instead.");
		}
		set_property("auto_doCombatCopy", "no");
		return true;
	}

	/*	Should we check for an acceptable monster or just empty the box in that case?
	huge swarm of ghuol whelps, modern zmobie, mountain man
	*/
	//If doesn\'t match a special condition
	if(enemy != $monster[none])
	{
		handleCopiedMonster($item[Rain-Doh Box Full of Monster]);
		if(last_monster() != enemy)
		{
			abort("Now sure what exploded, tried to summon copy of " + enemy + " but got " + last_monster() + " instead.");
		}
		return true;
	}

	return false;
}
