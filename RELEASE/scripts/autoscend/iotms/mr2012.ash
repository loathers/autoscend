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

boolean auto_rainDohCanCopy()
{
	if(item_amount($item[Rain-Doh black box]) == 0)
	{
		return false;
	}

	if(item_amount($item[Rain-Doh box full of monster]) > 0)
	{
		return false;
	}

	if (get_property("_raindohCopiesMade").to_int() == 5)
	{
		return false;
	}

	if (item_amount($item[spooky putty sheet]) > 0 || item_amount($item[spooky putty monster]) > 0)
	{
		return (6 - get_property("spookyPuttyCopiesMade").to_int() + get_property("_raindohCopiesMade").to_int()) > 0;
	}

	return (5 - get_property("_raindohCopiesMade").to_int()) > 0;
}
