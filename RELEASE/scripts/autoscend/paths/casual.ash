boolean inCasual()
{
	// remove this once mafia has a in_casual() function.
	if (get_property("auto_isAFilthyCasual") == "")
	{
		string page = visit_url("api.php?what=status&for=4", false);
		set_property("auto_isAFilthyCasual", page.contains_text(`"casual":"1"`));
	}
	if (get_property("auto_isAFilthyCasual").to_boolean())
	{
		if (get_property("_casualAscension") == "")
		{
			set_property("_casualAscension", my_ascensions());
		}
		return true;
	}
	return false;
}

boolean inAftercore()
{
	return get_property("kingLiberated").to_boolean();
}

boolean inPostRonin()
{
	//can interact means you are not in ronin and not in hardcore. It returns true in casual, aftercore, and postronin
	if(can_interact() && !inCasual() && !inAftercore())
	{
		return true;
	}
	return false;
}

boolean L8_slopeCasual()
{
	//casual and postronin should mallbuy everything needed to skip this zone
	if(!can_interact())
	{
		return false;	//does not have unrestricted mall access. we are not in casual or postronin
	}
	foreach it in $items[Ninja Carabiner, Ninja Crampons, Ninja Rope,		//ninja climbing gear needed to climb the slope
	eXtreme scarf, eXtreme mittens, snowboarder pants]						//outfit ensures you can reach 5 cold res needed
	{
		if(!buyUpTo(1, it))	//try to buy it or verify we already own it. if fails then do as below
		{
			if(my_meat() < mall_price(it))
			{
				auto_log_info("Can not afford to buy [" +it+ "] to climb the slope. Go do something else", "red");
				return false;
			}
			abort("Mysteriously failed to buy [" +it+ "]. Buy it manually and run me again");
		}
	}
	if(L8_trapperPeak())	//try to unlock peak
	{
		return true;	//successfully finished this part of the quest
	}
	abort("Mysteriously failed to unlock the mountain peak in trapper quest in casual or postronin. please unlock it and run me again");
	return false;
}

void acquireFamiliarRagamuffinImp()
{
	//attack familiar that is very easy to get. one per account. some people prefer to display instead of hatch. require user opt in.
	if(!get_property("auto_hatchRagamuffinImp").to_boolean())
	{
		return;		//user did not opt in.
	}
	if(!pathHasFamiliar() || !pathAllowsChangingFamiliar())
	{
		return;	//we can not hatch familiars in a path that does not use them. nor properly check the terrarium's contents.
	}
	if(!checkTerrarium())
	{
		return;
	}
	if(!can_interact())
	{
		return;	//we are neither in casual nor postronin
	}
	if(have_familiar($familiar[Ragamuffin Imp]))
	{
		return;		//already have it
	}
	if(item_amount($item[pile of smoking rags]) == 0)
	{
		//only one copy allowed per account.
		if(closet_amount($item[pile of smoking rags]) > 0)
		{
			auto_log_warning("Your [pile of smoking rags] is in your closet. We will leave it there. If you actually want the familiar [Ragamuffin Imp] then you need to uncloset it", "red");
		}
		else if(display_amount($item[pile of smoking rags]) > 0)
		{
			auto_log_warning("Your [pile of smoking rags] is in your display case. We will leave it there. If you actually want the familiar [Ragamuffin Imp] then you need to take it out", "red");
		}
		else if(!get_property("demonSummoned").to_boolean() &&		//can only summon one demon a day
			internalQuestStatus("questL11MacGuffin") > 2 &&			//must have read your father diary
			internalQuestStatus("questL11Manor") > 3)				//must have killed lord spookyraven
		{
			cli_execute("summon Tatter");
		}
	}
	hatchFamiliar($familiar[Ragamuffin Imp]);
}

void acquireFamiliarsCasual()
{
	//casual and postronin specific function which acquires hatchlings for important or easy to get familiars and then hatches them.
	//use is_unrestricted instead of auto_is_valid because familiar hatching is not using an item and ignores most restrictions.
	if(!pathHasFamiliar() || !pathAllowsChangingFamiliar())
	{
		return;	//we can not hatch familiars in a path that does not use them. nor properly check the terrarium's contents.
	}
	if(!checkTerrarium())
	{
		return;
	}
	if(!can_interact())
	{
		return;	//we are neigher in casual nor postronin
	}
	
	//Gelatinous Cubeling familiar costs 27 fat loot tokens and significantly improves doing daily dungeon in run.
	//if you do not have it already then you are most likely a new and poor account and thus want to get it from vending machine and not the mall.
	if(!have_familiar($familiar[Gelatinous Cubeling]) && item_amount($item[dried gelatinous cube]) == 0 && item_amount($item[fat loot token]) > 26)
	{
		buy($coinmaster[Vending Machine], 1, $item[dried gelatinous cube]);
	}
	hatchFamiliar($familiar[Gelatinous Cubeling]);
	
	//Levitating Potato blocks enemy attacks and is very cheap. if your account is new enough to not have it then you are poor enough to want to get it via token rather than mallbuy.
	if(have_familiar($familiar[Gelatinous Cubeling]) &&		//cubeling uses same token to buy. so only buy potato if you already have cubeling
	!have_familiar($familiar[Levitating Potato]) && item_amount($item[potato sprout]) == 0 && item_amount($item[fat loot token]) > 0)
	{
		buy($coinmaster[Vending Machine], 1, $item[potato sprout]);
	}
	hatchFamiliar($familiar[Levitating Potato]);
	
	//cheap attack familiar
	if(!have_familiar($familiar[Howling Balloon Monkey]) && item_amount($item[balloon monkey]) == 0 && my_meat() > 10000)
	{
		retrieve_item(1, $item[balloon monkey]);		//will likely buy ingredients to craft. or it might mallbuy if cheaper
	}
	hatchFamiliar($familiar[Howling Balloon Monkey]);

	//stat gains cheaply. scaling. better at high levels
	if(!have_familiar($familiar[hovering sombrero]) && item_amount($item[hovering sombrero]) == 0 && my_meat() > 10000)
	{
		retrieve_item(1, $item[hovering sombrero]);		//will most likely buy ingredients to meatpaste
	}
	hatchFamiliar($familiar[hovering sombrero]);
	
	//delevel enemy cheaply
	if(!have_familiar($familiar[barrrnacle]) && item_amount($item[Barrrnacle]) == 0 && auto_mall_price($item[Barrrnacle]) < 1000 && my_meat() > 10000)
	{
		retrieve_item(1, $item[Barrrnacle]);			//will mallbuy it
	}
	hatchFamiliar($familiar[Barrrnacle]);
	
	//meat, MP/HP, confuse, or attack enemy. cheap
	if(!have_familiar($familiar[Cocoabo]) && item_amount($item[cocoa egg]) == 0)
	{
		retrieve_item(1, $item[cocoa egg]);				//will most likely buy ingredients to craft. might buy directly.
	}
	hatchFamiliar($familiar[Cocoabo]);
	
	//+initiative for Standard restricted runs. cheap
	if(!have_familiar($familiar[Oily Woim]) && item_amount($item[woim]) == 0)
	{
		retrieve_item(1, $item[woim]);					//will most likely buy ingredients to craft. might buy directly.
	}
	hatchFamiliar($familiar[Oily Woim]);
	
	//IOTM derivative. +1 liver while equipped allowing better rollover drinking
	if(!have_familiar($familiar[Stooper]) && item_amount($item[Stooper]) == 0)
	{
		int price = auto_mall_price($item[Stooper]);
		if(price < 20000 && price < my_meat())
		{
			retrieve_item($item[Stooper]);
		}
		else if(price < my_meat())
		{
			auto_log_info("You should consider buying [Stooper] from the mall. it only costs " +price+ " meat and gives you +1 liver space", "blue");
		}
	}
	hatchFamiliar($familiar[Stooper]);
	
	//IOTM derivative. +initiative, +hot damage. out of standard
	if(!have_familiar($familiar[Cute Meteor]) && item_amount($item[cute meteoroid]) == 0)
	{
		int price = auto_mall_price($item[cute meteoroid]);
		if(price < 20000 && price < my_meat())
		{
			retrieve_item($item[cute meteoroid]);
		}
	}
	hatchFamiliar($familiar[Cute Meteor]);
}

boolean LX_acquireFamiliarLeprechaun()
{
	//unlike other acquire familiar functions this one actually spends adventures. and also stomach space.
	//+meat familiar. If you do not have leprechaun you are a new account so poor that it is worth spending resources to get.
	//only return true if we spent an adventure and want to restart the loop.
	if(!pathHasFamiliar() || !pathAllowsChangingFamiliar())
	{
		return false;	//we can not hatch familiars in a path that does not use them. nor properly check the terrarium's contents.
	}
	if(!checkTerrarium())
	{
		return false;
	}
	if(!can_interact())
	{
		return false;	//we are neigher in casual nor postronin
	}
	if(have_familiar($familiar[Leprechaun]))
	{
		return false;	//already have it
	}
	if(item_amount($item[leprechaun hatchling]) == 0 && my_meat() > 10000)
	{
		int price_hatch = auto_mall_price($item[leprechaun hatchling]);
		int price_bowl = auto_mall_price($item[bowl of lucky charms]);
		if(price_hatch < 8000)		//at this price we might as well mallbuy the hatchling
		{
			retrieve_item(1, $item[leprechaun hatchling]);
		}
		else if(auto_is_valid($item[bowl of lucky charms]))		//try to get hatchling via eating bowl of lucky charms.
		{
			if(item_amount($item[bowl of lucky charms]) == 0)
			{
				if(price_bowl < 3000)
				{
					retrieve_item(1, $item[bowl of lucky charms]);		//just mallbuy it at this price
				}
				else if(zone_available($location[The Spooky Forest]))	//spend 1 adv and one clover to get it instead.
				{
					retrieve_item(1, $item[Ten-Leaf Clover]);
					if(item_amount($item[Ten-Leaf Clover]) > 0)
					{
						cloverUsageInit();
						boolean adventure = autoAdv($location[The Spooky Forest]);
						cloverUsageFinish();
						if(adventure) return true;
					}
				}
			}
			if(item_amount($item[bowl of lucky charms]) > 0 && fullness_left() > 0)
			{
				int initial = fullness_left();
				eat(1, $item[bowl of lucky charms]);	//uses 1 stomach space to give 50% chance of recieving the hatchling.
				if(initial == fullness_left())
				{
					auto_log_warning("Mysteriously failed to eat [bowl of lucky charms]", "red");
				}
				else if(item_amount($item[leprechaun hatchling]) == 0)
				{
					return true;	//ate a bowl of lucky charms but failed to get hatchling. restart loop to try again.
				}
			}
		}
	}
	hatchFamiliar($familiar[Leprechaun]);
	return false;
}

boolean LM_canInteract()
{
	//this function is called early once every loop of doTasks() in autoscend.ash to do things when we have unlimited mall access
	//which indicates postronin or casual or aftercore. currently won't get called in aftercore
	if(!can_interact())
	{
		return false;
	}
	
	if(get_property("lastEmptiedStorage").to_int() != my_ascensions())
	{
		cli_execute("pull all");
	}
	acquireFamiliarsCasual();
	acquireFamiliarRagamuffinImp();
	if(LX_acquireFamiliarLeprechaun()) return true;
	
	return false;
}
