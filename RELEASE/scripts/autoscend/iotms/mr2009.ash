boolean auto_spookyPuttyCanCopy()
{
	if(item_amount($item[spooky putty sheet]) == 0)
	{
		return false;
	}

	if(item_amount($item[spooky putty monster]) > 0)
	{
		return false;
	}

	if (get_property("spookyPuttyCopiesMade").to_int() == 5)
	{
		return false;
	}

	if (item_amount($item[Rain-Doh black box]) > 0 || item_amount($item[Rain-Doh box full of monster]) > 0)
	{
		return (6 - get_property("spookyPuttyCopiesMade").to_int() + get_property("_raindohCopiesMade").to_int()) > 0;
	}

	return (5 - get_property("spookyPuttyCopiesMade").to_int()) > 0;
}