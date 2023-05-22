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

	if(item_amount($item[replica mr. accessory]) == 0)
	{
		return false;
	}

	while(item_amount($item[replica mr. accessory]) > 0)
	{
		string page = visit_url("shop.php?whichshop=mrreplica");

		// check cincho first since it will be available immediately if you own the IOTM already
		if(contains_text(page, "Cincho")) //2023
		{
			buy($coinmaster[Replica Mr. Store], 1, $item[replica Cincho de Mayo]);
		}
		else if(contains_text(page, "— 2004 —"))
		{
			buy($coinmaster[Replica Mr. Store], 1, $item[Replica Dark Jill-O-Lantern]);
			//visit_url("shop.php?whichshop=mrreplica&action=buyitem&quantity=1&whichrow=1319&pwd");
			use(1, $item[Replica Dark Jill-O-Lantern]); // put in terrarium
		}
		else if(contains_text(page, "— 2005 —"))
		{
			buy($coinmaster[Replica Mr. Store], 1, $item[replica wax lips]);
		}
		else if(contains_text(page, "— 2006 —"))
		{
			buy($coinmaster[Replica Mr. Store], 1, $item[replica jewel-eyed wizard hat]);
		}
		else if(contains_text(page, "— 2007 —"))
		{
			buy($coinmaster[Replica Mr. Store], 1, $item[replica navel ring of navel gazing]);
		}
		else if(contains_text(page, "— 2008 —"))
		{
			buy($coinmaster[Replica Mr. Store], 1, $item[replica haiku katana]);
		}
		else if(contains_text(page, "— 2009 —"))
		{
			buy($coinmaster[Replica Mr. Store], 1, $item[replica Elvish sunglasses]);
		}
		else if(contains_text(page, "— 2010 —"))
		{
			buy($coinmaster[Replica Mr. Store], 1, $item[replica Greatest American Pants]);
		}
		else if(contains_text(page, "— 2011 —"))
		{
			buy($coinmaster[Replica Mr. Store], 1, $item[replica cute angel]);
			use(1, $item[replica cute angel]); // put in terrarium
		}
		else if(contains_text(page, "— 2012 —"))
		{
			buy($coinmaster[Replica Mr. Store], 1, $item[replica Libram of Resolutions]); // todo - add support to use daily
		}
		else if(contains_text(page, "— 2013 —"))
		{
			buy($coinmaster[Replica Mr. Store], 1, $item[replica Smith\'s Tome]); // todo - add support to use daily
		}
		else if(contains_text(page, "— 2014 —"))
		{
			buy($coinmaster[Replica Mr. Store], 1, $item[replica Crimbo sapling]);
			use(1, $item[replica Crimbo sapling]); // put in terrarium
		}
		else if(contains_text(page, "— 2015 —"))
		{
			buy($coinmaster[Replica Mr. Store], 1, $item[replica Deck of Every Card]);
		}
		else if(contains_text(page, "— 2016 —"))
		{
			buy($coinmaster[Replica Mr. Store], 1, $item[replica Source terminal]);
			use(1, $item[replica Source terminalg]); // put in campsite
		}
		else if(contains_text(page, "— 2017 —"))
		{
			buy($coinmaster[Replica Mr. Store], 1, $item[replica genie bottle]);
		}
		else if(contains_text(page, "— 2018 —"))
		{
			buy($coinmaster[Replica Mr. Store], 1, $item[replica January\'s Garbage Tote]);
		}
		else if(contains_text(page, "— 2019 —"))
		{
			buy($coinmaster[Replica Mr. Store], 1, $item[replica Kramco Sausage-o-Matic&trade;]);
		}
		else if(contains_text(page, "— 2020 —"))
		{
			buy($coinmaster[Replica Mr. Store], 1, $item[replica baby camelCalf]);
			use(1, $item[replica baby camelCalf]); // put in terrarium
		}
		else if(contains_text(page, "— 2021 —"))
		{
			buy($coinmaster[Replica Mr. Store], 1, $item[replica emotion chip]);
			use(1, $item[replica emotion chip]); // learn skills
		}
		else if(contains_text(page, "— 2022 —"))
		{
			buy($coinmaster[Replica Mr. Store], 1, $item[replica Jurassic Parka]);
		}



		if(item_amount($item[replica mr. accessory]) > 0)
		{
			abort("go spend the mr. replica! This year not supported yet");
		}
	}

	return true;
}
