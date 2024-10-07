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

		// attempt to buy 2023 IOTMs first as if you one them, they are immediately available
		// then attempt to buy sequentially year by year starting with 2004
		// note with enough progress, can a second option up to year 2012
		if(contains_text(page, "cincho")) //2023
		{
			buy($coinmaster[Replica Mr. Store], 1, $item[replica Cincho de Mayo]);
		}
		if(contains_text(page, "2002")) //2023
		{
			buy($coinmaster[Replica Mr. Store], 1, $item[Replica 2002 Mr. Store Catalog]);
			auto_buyFrom2002MrStore();
		}
		if(contains_text(page, "patriotic eagle") && !is100FamRun()) //If this isn't a 100% familiar run, go ahead and get another familiar
		{	
			buy($coinmaster[Replica Mr. Store], 1, $item[replica sleeping patriotic eagle]);
			use(1, $item[replica sleeping patriotic eagle]); // put in terrarium
		}
		if(contains_text(page, "august scepter")) //2023
		{
			buy($coinmaster[Replica Mr. Store], 1, $item[replica August Scepter]);
			auto_scepterSkills();
		}
		
		//End of 2023 "Always Available" IoTMs and starting legacy "one at a time" IoTMs
		if(contains_text(page, "<b>2004</b>"))
		{
			if(have_familiar($familiar[Jill-O-Lantern]) || have_familiar($familiar[Hand Turkey]))
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
			if(available_amount($item[replica wax lips]) == 0)
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
			if(available_amount($item[replica jewel-eyed wizard hat]) == 0)
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
			if(available_amount($item[replica navel ring of navel gazing]) == 0)
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
			if(available_amount($item[replica haiku katana]) == 0)
			{
				buy($coinmaster[Replica Mr. Store], 1, $item[replica haiku katana]);
			}
			else
			{
				if(!is100FamRun()) //If this isn't a 100% familiar run, go ahead and get another familiar
				{	
					buy($coinmaster[Replica Mr. Store], 1, $item[replica cotton candy cocoon]);
					use(1, $item[replica cotton candy cocoon]); // put in terrarium
				}
				else //This is a 100% familiar run, no need to buy another familiar
				{ 
					buy($coinmaster[Replica Mr. Store], 1, $item[Replica little box of fireworks]);
				} 
			}
		}
		else if(contains_text(page, "<b>2009</b>"))
		{

			if(is100FamRun())//If on a 100% Fam Run, will get sunglasses on the first time around
			{
				if(item_amount($item[replica Elvish sunglasses])<1)
				{
					buy($coinmaster[Replica Mr. Store], 1, $item[replica Elvish sunglasses]);
				}
				else 
				{
					buy($coinmaster[Replica Mr. Store], 1, $item[replica Apathargic Bandersnatch]);
					use(1, $item[replica Apathargic Bandersnatch]); // put in terrarium
				}
			}
			else if(!have_familiar($familiar[Frumious Bandersnatch]))
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
			if(available_amount($item[replica greatest american pants]) == 0)
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

			if(is100FamRun())//If on a 100% Fam Run, will get non-familiars
			{
				if(contains_text(page, "replica Operation Patriot Shield"))
				{
					buy($coinmaster[Replica Mr. Store], 1, $item[replica Operation Patriot Shield]);
				}
				else
				{
					buy($coinmaster[Replica Mr. Store], 1, $item[replica plastic vampire fangs]);	
				}
			}
			else if(!have_familiar($familiar[Obtuse Angel]))

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
			if(item_amount($item[replica libram of resolutions]) == 0)
			{
				buy($coinmaster[Replica Mr. Store], 1, $item[replica Libram of Resolutions]);
				use(1, $item[replica Libram of Resolutions]); // get items
			}
			else
			{
				if(!is100FamRun()) //If this isn't a 100% familiar run, go ahead and get another familiar
				{	
					buy($coinmaster[Replica Mr. Store], 1, $item[replica deactivated nanobots]);
					use(1, $item[replica deactivated nanobots]); // put in terrarium
				}
				else //This is a 100% familiar run, no need to buy another familiar
				{ 
					buy($coinmaster[Replica Mr. Store], 1, $item[replica Camp Scout backpack]);
				} 
			}
		}
		else if(contains_text(page, "<b>2013</b>"))
		{
			buy($coinmaster[Replica Mr. Store], 1, $item[replica Smith\'s Tome]);
			use(1, $item[replica Smith\'s Tome]); // get items
		}
		else if(contains_text(page, "<b>2014</b>"))
		{
			if(!is100FamRun())//If this isn't a 100% familiar run, go ahead and get another familiar
			{ 
				buy($coinmaster[Replica Mr. Store], 1, $item[replica Crimbo sapling]);
				use(1, $item[replica Crimbo sapling]); // put in terrarium
			}
			else //This is a 100% familiar run, no need to buy another familiar
			{ 
				buy($coinmaster[Replica Mr. Store], 1, $item[replica Little Geneticist DNA-Splicing Lab]);
				use(1, $item[replica Little Geneticist DNA-Splicing Lab]); // put in workshed

			} 			
		}
		else if(contains_text(page, "<b>2015</b>"))
		{
			buy($coinmaster[Replica Mr. Store], 1, $item[replica Deck of Every Card]);
		}
		else if(contains_text(page, "<b>2016</b>"))
		{
			buy($coinmaster[Replica Mr. Store], 1, $item[replica Source terminal]);
			use(1, $item[replica Source terminal]); // put in campsite
			// initialize
			auto_sourceTerminalEducate($skill[Extract], $skill[Digitize]);
			if(contains_text(get_property("sourceTerminalEnquiryKnown"), "familiar.enq") && pathHasFamiliar())
			{
				auto_sourceTerminalRequest("enquiry familiar.enq");
			}
			else if(contains_text(get_property("sourceTerminalEnquiryKnown"), "stats.enq"))
			{
				auto_sourceTerminalRequest("enquiry stats.enq");
			}
			else if(contains_text(get_property("sourceTerminalEnquiryKnown"), "protect.enq"))
			{
				auto_sourceTerminalRequest("enquiry protect.enq");
			}
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
			if(!is100FamRun()) //If this isn't a 100% familiar run, go ahead and get another familiar
			{	
				buy($coinmaster[Replica Mr. Store], 1, $item[replica baby camelCalf]);
				use(1, $item[replica baby camelCalf]); // put in terrarium
			}
			else //This is a 100% familiar run, no need to buy another familiar
			{ 
				buy($coinmaster[Replica Mr. Store], 1, $item[replica Powerful Glove]);
			}
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

void auto_LegacyOfLoathingDailies()
{
	if(item_amount($item[replica Libram of Resolutions]) > 0)
	{
		use(1, $item[replica Libram of Resolutions]); // get items
	}

	if(item_amount($item[replica Smith\'s Tome]) > 0)
	{
		use(1, $item[replica Smith\'s Tome]); // get items
	}
}

item auto_ItemToReplica(item it)
{
	switch(it)
	{
		case $item[mr. accessory]:
			return $item[replica mr. accessory];
		case $item[crimbo elfling]:
			return $item[replica crimbo elfling];
		case $item[Dark Jill-O-Lantern]:
			return $item[replica Dark Jill-O-Lantern];
		case $item[hand turkey outline]:
			return $item[replica hand turkey outline];
		case $item[miniature gravy-covered maypole]:
			return $item[replica miniature gravy-covered maypole];
		case $item[pygmy bugbear shaman]:
			return $item[replica pygmy bugbear shaman];
		case $item[wax lips]:
			return $item[replica wax lips];
		case $item[jewel-eyed wizard hat]:
			return $item[replica jewel-eyed wizard hat];
		case $item[plastic pumpkin bucket]:
			return $item[replica plastic pumpkin bucket];
		case $item[Tome of Snowcone Summoning]:
			return $item[replica Tome of Snowcone Summoning];
		case $item[bottle-rocket crossbow]:
			return $item[replica bottle-rocket crossbow];
		case $item[navel ring of navel gazing]:
			return $item[replica navel ring of navel gazing];
		case $item[V for Vivala mask]:
			return $item[replica V for Vivala mask];
		case $item[cotton candy cocoon]:
			return $item[replica cotton candy cocoon];
		case $item[haiku katana]:
			return $item[replica haiku katana];
		case $item[little box of fireworks]:
			return $item[replica little box of fireworks];
		case $item[Apathargic Bandersnatch]:
			return $item[replica Apathargic Bandersnatch];
		case $item[Elvish sunglasses]:
			return $item[replica Elvish sunglasses];
		case $item[squamous polyp]:
			return $item[replica squamous polyp];
		case $item[Greatest American Pants]:
			return $item[replica Greatest American Pants];
		case $item[Juju Mojo Mask]:
			return $item[replica Juju Mojo Mask];
		case $item[organ grinder]:
			return $item[replica organ grinder];
		case $item[a cute angel]:
			return $item[replica cute angel];
		case $item[Operation Patriot Shield]:
			return $item[replica Operation Patriot Shield];
		case $item[plastic vampire fangs]:
			return $item[replica plastic vampire fangs];
		case $item[Camp Scout backpack]:
			return $item[replica Camp Scout backpack];
		case $item[deactivated nanobots]:
			return $item[replica deactivated nanobots];
		case $item[Libram of Resolutions]:
			return $item[replica Libram of Resolutions];
		case $item[Order of the Green Thumb Order Form]:
			return $item[replica Order of the Green Thumb Order Form];
		case $item[over-the-shoulder Folder Holder]:
			return $item[replica over-the-shoulder Folder Holder];
		case $item[The Smith\'s Tome]:
			return $item[replica Smith\'s Tome];
		case $item[Crimbo sapling]:
			return $item[replica Crimbo sapling];
		case $item[Little Geneticist DNA-Splicing Lab]:
			return $item[replica Little Geneticist DNA-Splicing Lab];
		case $item[still grill]:
			return $item[replica still grill];
		case $item[Chateau Mantegna room key]:
			return $item[replica Chateau Mantegna room key];
		case $item[Deck of Every Card]:
			return $item[replica Deck of Every Card];
		case $item[Witchess Set]:
			return $item[replica Witchess Set];
		case $item[disconnected intergnat]:
			return $item[replica disconnected intergnat];
		case $item[Source terminal]:
			return $item[replica Source terminal];
		case $item[yellow puck]:
			return $item[replica yellow puck];
		case $item[genie bottle]:
			return $item[replica genie bottle];
		case $item[space planula]:
			return $item[replica space planula];
		case $item[unpowered Robortender]:
			return $item[replica unpowered Robortender];
		case $item[God Lobster Egg]:
			return $item[replica God Lobster Egg];
		case $item[January\'s Garbage Tote]:
			return $item[replica January\'s Garbage Tote];
		case $item[Neverending Party invitation envelope]:
			return $item[replica Neverending Party invitation envelope];
		case $item[Fourth of May Cosplay Saber]:
			return $item[replica Fourth of May Cosplay Saber];
		case $item[hewn moon-rune spoon]:
			return $item[replica hewn moon-rune spoon];
		case $item[Kramco Sausage-o-Matic&trade;]:
			return $item[replica Kramco Sausage-o-Matic&trade;];
		case $item[baby camelCalf]:
			return $item[replica baby camelCalf];
		case $item[Cargo Cultist Shorts]:
			return $item[replica Cargo Cultist Shorts];
		case $item[Powerful Glove]:
			return $item[replica Powerful Glove];
		case $item[emotion chip]:
			return $item[replica emotion chip];
		case $item[industrial fire extinguisher]:
			return $item[replica industrial fire extinguisher];
		case $item[miniature crystal ball]:
			return $item[replica miniature crystal ball];
		case $item[designer sweatpants]:
			return $item[replica designer sweatpants];
		case $item[grey gosling]:
			return $item[replica grey gosling];
		case $item[Jurassic Parka]:
			return $item[replica Jurassic Parka];
		case $item[Cincho de Mayo]:
			return $item[replica Cincho de Mayo];
		case $item[2002 Mr. Store Catalog]:
			return $item[Replica 2002 Mr. Store Catalog];
		case $item[August Scepter]:
			return $item[replica August Scepter];
	}
	return it;
}
