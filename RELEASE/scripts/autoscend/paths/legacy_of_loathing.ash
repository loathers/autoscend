boolean in_lol()
{
	return my_path() == $path[Legacy of Loathing];
}

void lol_initializeSettings()
{
	if(!in_lol())
	{
		return;
	}
	set_property("auto_wandOfNagamar", true);		//wand  used in this path
}

boolean lol_buyReplicas()
{
	if(!in_lol())
	{
		return false;
	}

	while(item_amount($item[replica mr. accessory]) > 0)
	{
		string page = visit_url("shop.php?whichshop=mrreplica");

		// check 2023 first since they will be available if you own the IOTM already
		if(contains_text(page, "Cincho"))
		{
			abort("determine how to buy cincho");
			visit_url("shop.php?whichshop=mrreplica&action=buyitem&quantity=1&whichrow=1320&pwd");
		}
		else if(contains_text(page, "Dark Jill"))
		{
			visit_url("shop.php?whichshop=mrreplica&action=buyitem&quantity=1&whichrow=1319&pwd");
			use(1, $item[Replica Dark Jill-O-Lantern]);
		}
		if(item_amount($item[replica mr. accessory]) > 0)
		{
			abort("go spend the mr. replica! This year not supported yet");
		}
	}

	return true;
}
