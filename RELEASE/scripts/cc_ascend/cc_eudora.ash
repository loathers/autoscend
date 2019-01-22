script "cc_eudora.ash"

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
		if((contains_text(eudora, "GameInformPowerDailyPro Magazine")) && is_unrestricted($item[GameInformPowerDailyPro Subscription Card]))
		{
			retval[$item[GameInformPowerDailyPro Subscription Card]] = true;
		}
		if((contains_text(eudora, "Xi Receiver Unit")) && is_unrestricted($item[Xi Receiver Unit]))
		{
			retval[$item[Xi Receiver Unit]] = true;
		}
		if((contains_text(eudora, "Pen Pal")) && is_unrestricted($item[My Own Pen Pal Kit]))
		{
			retval[$item[My Own Pen Pal Kit]] = true;
		}
		if((contains_text(eudora, "New-You Club")) && is_unrestricted($item[New-You Club Membership Form]))
		{
			retval[$item[New-You Club Membership Form]] = true;
		}
	}
	return retval;
}

item eudora_current()
{
	if(eudora_available())
	{
		string eudora = visit_url("account.php?tab=correspondence");
		if((contains_text(eudora, "selected\' value=\"2")) && is_unrestricted($item[GameInformPowerDailyPro Subscription Card]))
		{
			return $item[GameInformPowerDailyPro Subscription Card];
		}
		if((contains_text(eudora, "selected\' value=\"3")) && is_unrestricted($item[Xi Receiver Unit]))
		{
			return $item[Xi Receiver Unit];
		}
		if((contains_text(eudora, "selected\' value=\"1")) && is_unrestricted($item[My Own Pen Pal Kit]))
		{
			return $item[My Own Pen Pal Kit];
		}
		if((contains_text(eudora, "selected\' value=\"4")) && is_unrestricted($item[New-You Club Membership Form]))
		{
			return $item[New-You Club Membership Form];
		}
	}
	return $item[none];
}

int[item] eudora_xiblaxian()
{
	int[item] retval;
	if((item_amount($item[Xiblaxian 5D Printer]) > 0) && is_unrestricted($item[Xiblaxian 5D Printer]))
	{
		string canMake = visit_url("shop.php?whichshop=5dprinter");
		int polymer = item_amount($item[Xiblaxian Polymer]);
		int crystal = item_amount($item[Xiblaxian Crystal]);
		int circuitry = item_amount($item[Xiblaxian Circuitry]);
		int alloy = item_amount($item[Xiblaxian Alloy]);
		if(contains_text(canMake, "Xiblaxian xeno-detection goggles"))
		{
			retval[$item[Xiblaxian xeno-detection goggles]] = min(polymer/4, crystal/2);
		}
		if(contains_text(canMake, "Xiblaxian stealth cowl"))
		{
			retval[$item[Xiblaxian Stealth Cowl]] = min(circuitry/4, min(polymer/9, alloy/5));
		}
		if(contains_text(canMake, "Xiblaxian stealth trousers"))
		{
			retval[$item[Xiblaxian Stealth Trousers]] = min(circuitry/9, min(polymer/4, alloy/5));
		}
		if(contains_text(canMake, "Xiblaxian stealth vest"))
		{
			retval[$item[Xiblaxian Stealth Vest]] = min(circuitry/5, min(polymer/4, alloy/9));
		}
		if(contains_text(canMake, "Xiblaxian ultraburrito"))
		{
			retval[$item[Xiblaxian Ultraburrito]] = min(circuitry/1, min(polymer/1, alloy/3));
		}
		if(contains_text(canMake, "Xiblaxian space-whiskey"))
		{
			retval[$item[Xiblaxian Space-Whiskey]] = min(circuitry/3, min(polymer/1, alloy/1));
		}
		if(contains_text(canMake, "Xiblaxian residence-cube"))
		{
			retval[$item[Xiblaxian Residence-Cube]] = min(min(circuitry/11, crystal/3), min(polymer/11, alloy/11));
		}
	}
	return retval;
}