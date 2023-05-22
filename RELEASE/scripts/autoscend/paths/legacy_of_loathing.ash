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
		else if(contains_text(page, "<b>2004</b>"))
		{
			buy($coinmaster[Replica Mr. Store], 1, $item[Replica Dark Jill-O-Lantern]);
			//visit_url("shop.php?whichshop=mrreplica&action=buyitem&quantity=1&whichrow=1319&pwd");
			use(1, $item[Replica Dark Jill-O-Lantern]); // put in terrarium
		}
		else if(contains_text(page, "<b>2005</b>"))
		{
			buy($coinmaster[Replica Mr. Store], 1, $item[replica wax lips]);
		}
		else if(contains_text(page, "<b>2006</b>"))
		{
			buy($coinmaster[Replica Mr. Store], 1, $item[replica jewel-eyed wizard hat]);
		}
		else if(contains_text(page, "<b>2007</b>"))
		{
			buy($coinmaster[Replica Mr. Store], 1, $item[replica navel ring of navel gazing]);
		}
		else if(contains_text(page, "<b>2008</b>"))
		{
			buy($coinmaster[Replica Mr. Store], 1, $item[replica haiku katana]);
		}
		else if(contains_text(page, "<b>2009</b>"))
		{
			buy($coinmaster[Replica Mr. Store], 1, $item[replica Elvish sunglasses]);
		}
		else if(contains_text(page, "<b>2010</b>"))
		{
			buy($coinmaster[Replica Mr. Store], 1, $item[replica Greatest American Pants]);
		}
		else if(contains_text(page, "<b>2011</b>"))
		{
			buy($coinmaster[Replica Mr. Store], 1, $item[replica cute angel]);
			use(1, $item[replica cute angel]); // put in terrarium
		}
		else if(contains_text(page, "<b>2012</b>"))
		{
			buy($coinmaster[Replica Mr. Store], 1, $item[replica Libram of Resolutions]); // todo - add support to use daily
		}
		else if(contains_text(page, "<b>2013</b>"))
		{
			buy($coinmaster[Replica Mr. Store], 1, $item[replica Smith\'s Tome]); // todo - add support to use daily
		}
		else if(contains_text(page, "<b>2014</b>"))
		{
			buy($coinmaster[Replica Mr. Store], 1, $item[replica Crimbo sapling]);
			use(1, $item[replica Crimbo sapling]); // put in terrarium
		}
		else if(contains_text(page, "<b>2015</b>"))
		{
			buy($coinmaster[Replica Mr. Store], 1, $item[replica Deck of Every Card]);
		}
		else if(contains_text(page, "<b>2016</b>"))
		{
			buy($coinmaster[Replica Mr. Store], 1, $item[replica Source terminal]);
			use(1, $item[replica Source terminal]); // put in campsite
		}
		else if(contains_text(page, "<b>2017</b>"))
		{
			buy($coinmaster[Replica Mr. Store], 1, $item[replica genie bottle]);
		}
		else if(contains_text(page, "<b>2018</b>"))
		{
			buy($coinmaster[Replica Mr. Store], 1, $item[replica January\'s Garbage Tote]);
		}
		else if(contains_text(page, "<b>2019</b>"))
		{
			buy($coinmaster[Replica Mr. Store], 1, $item[replica Kramco Sausage-o-Matic&trade;]);
		}
		else if(contains_text(page, "<b>2020</b>"))
		{
			buy($coinmaster[Replica Mr. Store], 1, $item[replica baby camelCalf]);
			use(1, $item[replica baby camelCalf]); // put in terrarium
		}
		else if(contains_text(page, "<b>2021</b>"))
		{
			buy($coinmaster[Replica Mr. Store], 1, $item[replica emotion chip]);
			use(1, $item[replica emotion chip]); // learn skills
		}
		else if(contains_text(page, "<b>2022</b>"))
		{
			buy($coinmaster[Replica Mr. Store], 1, $item[replica Jurassic Parka]);
		}
		//
		else if(item_amount($item[replica mr. accessory]) > 0)
		{
			abort("Didn't buy from replica Mr. Store even though we have a replica Mr. A. Report to devs");
		}
	}

	return true;
}
