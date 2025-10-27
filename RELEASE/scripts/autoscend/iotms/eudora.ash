boolean eudora_available()
{
	if(contains_text(visit_url("account.php"),"tab=correspondence"))
	{
		return true;
	}
	return false;
}

boolean[item] eudora_initializeSettings()
{
	boolean[item] retval;
	if(eudora_available())
	{
		string eudora = visit_url("account.php?tab=correspondence");
		if((contains_text(eudora, "Pen Pal")) && is_unrestricted($item[My Own Pen Pal Kit]))
		{
			retval[$item[My Own Pen Pal Kit]] = true;
		}
		if((contains_text(eudora, "GameInformPowerDailyPro Magazine")) && is_unrestricted($item[GameInformPowerDailyPro Subscription Card]))
		{
			retval[$item[GameInformPowerDailyPro Subscription Card]] = true;
		}
		if((contains_text(eudora, "Xi Receiver Unit")) && is_unrestricted($item[Xi Receiver Unit]))
		{
			retval[$item[Xi Receiver Unit]] = true;
		}
		if((contains_text(eudora, "New-You Club")) && is_unrestricted($item[New-You Club Membership Form]))
		{
			retval[$item[New-You Club Membership Form]] = true;
		}
		if((contains_text(eudora, "Our Daily Candles")) && is_unrestricted($item[Our Daily Candles&trade; order form]))
		{
			retval[$item[Our Daily Candles&trade; order form]] = true;
		}
	}
	return retval;
}

item eudora_current()
{
	if(eudora_available())
	{
		string eudora = visit_url("account.php?tab=correspondence");
		if((contains_text(eudora, "selected\' value=\"1")) && is_unrestricted($item[My Own Pen Pal kit]))
		{
			return $item[My Own Pen Pal kit];
		}
		if((contains_text(eudora, "selected\' value=\"2")) && is_unrestricted($item[GameInformPowerDailyPro subscription card]))
		{
			return $item[GameInformPowerDailyPro subscription card];
		}
		if((contains_text(eudora, "selected\' value=\"3")) && is_unrestricted($item[Xi Receiver Unit]))
		{
			return $item[Xi Receiver Unit];
		}
		if((contains_text(eudora, "selected\' value=\"4")) && is_unrestricted($item[New-You Club Membership Form]))
		{
			return $item[New-You Club Membership Form];
		}
		if((contains_text(eudora, "selected\' value=\"5")) && is_unrestricted($item[Our Daily Candles&trade; order form]))
		{
			return $item[Our Daily Candles&trade; order form];
		}
	}
	return $item[none];
}
