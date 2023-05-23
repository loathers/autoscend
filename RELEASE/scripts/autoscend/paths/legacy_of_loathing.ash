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
		string page = to_lower_case(visit_url("shop.php?whichshop=mrreplica"));

		// attempt to buy 2023 IOTM first as if you one them, they are immediately available
		// then attempt to buy sequentially year by year starting with 2004
		// note with enough progress, can a second option up to year 2012
		if(contains_text(page, "Cincho")) //2023
		{
			buy($coinmaster[Replica Mr. Store], 1, $item[replica Cincho de Mayo]);
		}
		else if(contains_text(page, "<b>2004</b>"))
		{
			if(!contains_text(page, "replica dark jill-o-lantern") || !contains_text(page, "replica hand turkey outline"))
			{
				// already bought one
				buy($coinmaster[Replica Mr. Store], 1, $item[replica crimbo elfling]);
				use(1, $item[replica crimbo elfling]); // put in terrarium
			}
			else if(item_amount($item[replica mr. accessory]) >= 6)
			{
				// buy hand turkey if can get bander t0
				buy($coinmaster[Replica Mr. Store], 1, $item[replica hand turkey outline]);
				use(1, $item[replica hand turkey outline]); // put in terrarium
			}
			else
			{
				buy($coinmaster[Replica Mr. Store], 1, $item[Replica Dark Jill-O-Lantern]);
				use(1, $item[Replica Dark Jill-O-Lantern]); // put in terrarium
			}
		}
		else if(contains_text(page, "<b>2005</b>"))
		{
			if(contains_text(page, "replica wax lips"))
			{
				buy($coinmaster[Replica Mr. Store], 1, $item[replica wax lips]);
			}
			else
			{
				buy($coinmaster[Replica Mr. Store], 1, $item[replica miniature gravy-covered maypole]);
			}
		}
		else if(contains_text(page, "<b>2006</b>"))
		{
			if(contains_text(page, "replica jewel-eyed wizard hat"))
			{
				buy($coinmaster[Replica Mr. Store], 1, $item[replica jewel-eyed wizard hat]);
			}
			else
			{
				buy($coinmaster[Replica Mr. Store], 1, $item[replica Tome of Snowcone Summoning]);
			}
		}
		else if(contains_text(page, "<b>2007</b>"))
		{
			if(contains_text(page, "replica navel ring of navel gazing"))
			{
				buy($coinmaster[Replica Mr. Store], 1, $item[replica navel ring of navel gazing]);
			}
			else
			{
				buy($coinmaster[Replica Mr. Store], 1, $item[replica V for Vivala mask]);
			}
		}
		else if(contains_text(page, "<b>2008</b>"))
		{
			if(contains_text(page, "replica haiku katana"))
			{
				buy($coinmaster[Replica Mr. Store], 1, $item[replica haiku katana]);
			}
			else
			{
				buy($coinmaster[Replica Mr. Store], 1, $item[replica cotton candy cocoon]);
				use(1, $item[replica cotton candy cocoon]); // put in terrarium
			}
		}
		else if(contains_text(page, "<b>2009</b>"))
		{
			if(contains_text(page, "replica apathargic bandersnatch"))
			{
				buy($coinmaster[Replica Mr. Store], 1, $item[replica Apathargic Bandersnatch]);
				use(1, $item[replica Apathargic Bandersnatch]); // put in terrarium
			}
			else
			{
				buy($coinmaster[Replica Mr. Store], 1, $item[replica squamous polyp]);
				use(1, $item[replica squamous polyp]); // put in terrarium
			}
		}
		else if(contains_text(page, "<b>2010</b>"))
		{
			if(contains_text(page, "replica greatest american pants"))
			{
				buy($coinmaster[Replica Mr. Store], 1, $item[replica Greatest American Pants]);
			}
			else
			{
				buy($coinmaster[Replica Mr. Store], 1, $item[replica organ grinder]);
			}
		}
		else if(contains_text(page, "<b>2011</b>"))
		{
			if(contains_text(page, "replica cute angel"))
			{
				buy($coinmaster[Replica Mr. Store], 1, $item[replica cute angel]);
				use(1, $item[replica cute angel]); // put in terrarium
			}
			else
			{
				buy($coinmaster[Replica Mr. Store], 1, $item[replica Operation Patriot Shield]);
			}
		}
		else if(contains_text(page, "<b>2012</b>"))
		{
			if(contains_text(page, "replica libram of resolutions"))
			{
				buy($coinmaster[Replica Mr. Store], 1, $item[replica Libram of Resolutions]); // todo - add support to use daily
				use(1, $item[replica Libram of Resolutions]); // get items
			}
			else
			{
				buy($coinmaster[Replica Mr. Store], 1, $item[replica deactivated nanobots]);
				use(1, $item[replica deactivated nanobots]); // put in terrarium
			}
		}
		else if(contains_text(page, "<b>2013</b>"))
		{
			buy($coinmaster[Replica Mr. Store], 1, $item[replica Smith\'s Tome]); // todo - add support to use daily
			use(1, $item[replica Smith\'s Tome]); // get items
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
