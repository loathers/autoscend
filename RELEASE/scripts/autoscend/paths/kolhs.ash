boolean in_kolhs()
{
	return auto_my_path() == "KOLHS";
}

boolean kolhs_mandatorySchool()
{
	//true means it is mandatory for you to attend school right now. All non school zones are unavailable. Summoning fights works though
	if(!in_kolhs())
	{
		return false;	//not in the path so we are not required to attend school
	}
	return get_property("_kolhsAdventures").to_int() < 40;
}

void kolhs_initializeSettings()
{
	if(!in_kolhs())
	{
		return;
	}
	
	set_property("kolhs_closetDrink", false);
}

void kolhs_closetDrink()
{
	//prevent kolhs issues in postronin (or drop to casual) caused by special drinks by closetting excess amount.
	//this function and related variables are needed because mafia does not track which is the last dropped kolhs combat drink.
	//we can pull leftovers/purchases. and we might have leveled since last combat when it dropped.
	if(!in_kolhs())
	{
		return;
	}
	if(!can_interact())
	{
		return;		//we are not in postronin/casual
	}
	if(get_property("kolhs_closetDrink").to_boolean())
	{
		return;		//already done this ascension
	}
	set_property("kolhs_closetDrink", true);
	
	//drink one first if needed so they continue to drop.
	item target = $item[can of the cheapest beer];
	if(my_level() > 8)
	{
		target = $item[single swig of vodka];
	}
	else if(my_level() > 4)
	{
		target = $item[bottle of fruity &quot;wine&quot;];
	}
	if(my_inebriety() < 10 && item_amount(target) > 0)
	{
		autoDrink(1, target);
	}
	
	//closet all the others
	foreach it in $items[single swig of vodka, bottle of fruity &quot;wine&quot;, can of the cheapest beer]
	{
		int amt = item_amount(it);
		if(amt > 0)
		{
			put_closet(amt, it);
		}
	}
}

void kolhs_consume()
{
	//handles consumption for KOLHS which has special drinking mechanics
	if(!in_kolhs())
	{
		return;
	}
	
	//KOLHS drinking mechanics is not tracked by mafia and is believed to work as per:
	//3 combat drinks drop at the end of combat, automatically costing 100 meat. not encountered in the school itself.
	//only encountered if you drank the last one that dropped today. and only if inebrity under 10.
	//this means we need to drink them as soon as they drop to allow the next one to drop. Or we end up with empty liver and out of adventures
	//[single swig of vodka] = level 9+. size 2. 2.75 adv/size
	//[bottle of fruity &quot;wine&quot;] = level 5-8. size 2. 2.5 adv/size
	//[can of the cheapest beer] = level 1-4. size 1. 2 adv/size
	
	if(my_inebriety() < 10)		//phase 1. drink these as soon as they drop. no return here because we want to eat too.
	{
		foreach it in $items[single swig of vodka, bottle of fruity &quot;wine&quot;, can of the cheapest beer]
		{
			if(item_amount(it) > 0)
			{
				autoDrink(1, it);
			}
		}
	}
	
	if(stomach_left() > 0)		//phase 2. fill up on food before we finish off liver
	{
		if(my_adventures() < 10)
		{
			auto_autoConsumeOne("eat", false);
			return;
		}
		else
		{
			return;		//if we fail to fill up stomach then do not auto consume booze in kolhs
		}
	}
	if(my_adventures() < 10)	//phase 3. final drinking now that our stomach is full
	{
		//TODO replace it with specific manual handling. autoConsumeOne says it cannot find anything to consume.
		auto_autoConsumeOne("drink", false);
		return;
	}
	
	//if stomach and liver are full and out of adv then chew size 4 iotm derivate spleen items that give 1.875 adv/size.
	if (auto_chewAdventures())
	{
		return;
	}
}

void kolhs_preadv(location place)
{
	if(!in_kolhs())
	{
		return;
	}
	
	//KOLHS path specific zones where hats are forbidden. wearing one fails to adv and causes infinite loop
	if($locations[The Hallowed Halls, Art Class, Chemistry Class, Shop Class] contains place)
	{
		addToMaximize("-hat");
		equip($slot[hat], $item[none]);
	}
	
	//prepare yearbook camera
	if(place == get_property("_yearbookCameraTargetLocation").to_location() && !get_property("yearbookCameraPending").to_boolean())
	{
		if(equipped_amount($item[Yearbook Club Camera]) == 0)
		{
			auto_log_warning("Tried to adventure in [" +place+ "] to do the yearbook camera quest without a [Yearbook Club Camera] equipped... correcting", "red");
			autoForceEquip($slot[acc2], $item[Yearbook Club Camera]);
			if(equipped_amount($item[Yearbook Club Camera]) == 0)
			{
				abort("Correction failed, please report this. Manually photograph a [" +get_property("yearbookCameraTarget")+ "] then run me again");
			}
		}
	}
}

boolean LX_kolhs_visitYearbookClub()
{
	//visit to yearbook club. You start the quest on one day and complete it the next day so no point in multiple visits in one day.
	//if you did not finish the quest then it changes. so you need to revisit every day regardless of completion status.
	//on first visit per ascension you acquire the camera. if you already maxed out camera no point in visiting again
	if(get_property("_yearbookClubVisitedToday").to_boolean())
	{
		return false;		//already visited today
	}
	if(get_property("_kolhsSavedByTheBell").to_int() > 2)
	{
		return false;		//we ran out of saved by the bell NC visits. so we cannot reach it today.
	}
	auto_log_info("Visiting the yearbook club", "blue");
	set_property("_NC772_directive", 3);				//NC772 [saved by the bell] should visit yearbook club
	return autoAdv($location[The Hallowed Halls]);		//goto NC772
}

boolean LX_kolhs_yearbookCameraGet()
{
	//grab the yearbook camera if you have not already done so.
	if(possessEquipment($item[Yearbook Club Camera]))
	{
		return false;	//already have the camera
	}
	if(kolhs_mandatorySchool())
	{
		return false;	//we have not yet unlocked [saved by the bell] today
	}
	return LX_kolhs_visitYearbookClub();	//grab the camera if you did not get it yet this ascension
}

boolean LX_kolhs_yearbookCameraQuest()
{
	//grab a yearbook camera. do sidequest to acquire permanent between ascensions upgrades for it
	if(kolhs_mandatorySchool())
	{
		return false;	//we have not yet unlocked [saved by the bell] today
	}
	
	if(LX_kolhs_yearbookCameraGet()) return true;	//grab the yearbook camera if you have not already done so.
	
	//do we actually need to do the quest?
	if(get_property("yearbookCameraAscensions").to_int() > 20)
	{
		return false;	//already maxed out permanent upgrades
	}
	if(my_ascensions() == get_property("lastYearbookCameraAscension").to_int())
	{
		return false;	//already upgraded once this ascension. only one upgrade per ascension can become permanent.
	}
	if(LX_kolhs_visitYearbookClub()) return true;		//start, restart, or finish quest.
	
	if(get_property("yearbookCameraPending").to_boolean())
	{
		return false;	 //we finished the quest today but must wait until tomorrow to turn it in
	}
	
	//try to get a photograph
	monster target = get_property("yearbookCameraTarget").to_monster();
	location adv_target;
	foreach loc in monster_to_location(target)
	{
		if(zone_isAvailable(loc, true))
		{
			adv_target = loc;
			break;
		}
	}
	set_property("_yearbookCameraTargetLocation", adv_target);		//used by pre_adv to verify camera is actually equipped
	if(adv_target == $location[none])
	{
		return false;		//just in case. should not be possible since it picks from reachable locations
	}

	autoEquip($item[Yearbook Club Camera]);
	return autoAdv(adv_target);
	
	return false;
}

boolean LX_kolhs_school()
{
	//adventure in school. mandatory for first 40 adv to be spent there.
	if(!kolhs_mandatorySchool())
	{
		return false;	//done for today
	}
	
	return autoAdv($location[The Hallowed Halls]);
	//TODO specific classes https://kol.coldfront.net/thekolwiki/index.php/KoL_High_School
	//TODO sniff wastoid in hallowed halls
}

void kolhsChoiceHandler(int choice)
{
	auto_log_debug("Running kolhsChoiceHandler");
	switch (choice)
	{
		case 700: // Delirium in the Cafeterium (KOLHS 22nd adventure every day)
			if(have_effect($effect[Jamming with the Jocks]) > 0)
			{
				run_choice(1); // get XP
			}
			else if(have_effect($effect[Nerd is the Word]) > 0)
			{
				run_choice(2); // get XP
			}
			else if(have_effect($effect[Greaser Lightnin\']) > 0)
			{
				run_choice(3); // get XP
			}
			else
			{
				auto_log_warning("I do not have the necessary intrinsic to gain xp in [Delirium in the Cafeterium]", "red");
				run_choice(3); // lose HP
			}
			break;
		case 772: // Saved by the Bell (KOLHS after school)
			//we use directive property. it both tells us what to do, and helps pre-adv do stuff. for example ensure we are not wearing a familiar that is blocking us
			int target = get_property("_NC772_directive").to_int();
			remove_property("_NC772_directive");		//remove it now in case we abort
			if(target == 0)
			{
				abort("We are in [saved by the bell] and do not know what to do because _NC772_directive is not valid or set. Leaving will waste this NC so do something manually");
			}
			if(available_choice_options() contains target)
			{
				if(target == 3)		//yearbook club should only be visited once daily
				{
					set_property("_yearbookClubVisitedToday", true);
				}
				run_choice(target);
			}
			else
			{
				abort("We are in [saved by the bell] and do not know what to do. Wanted to press button number " +target+ " but it mysteriously does not exist. Leaving will waste this NC so do something manually");
			}
			break;
		default:
			break;
	}
}

boolean LM_kolhs()
{
	//this function is called early once every loop of doTasks() in autoscend.ash to do things when we are in kolhs
	if(!in_kolhs())
	{
		return false;
	}
	
	familiar familiar_target_100 = get_property("auto_100familiar").to_familiar();
	if(familiar_target_100 != $familiar[none] && familiar_target_100 != $familiar[Steam-Powered Cheerleader])
	{
		set_property("auto_100familiar", $familiar[none]);
		abort("Detected an attempted 100% familiar run with [" +familiar_target_100+ "] in KOLHS. [Steam Powered Cheerleader] is the only valid 100% familiar run in KOLHS. 100% familiar run disabled. You can run autoscend again to continue");
	}
	
	kolhs_closetDrink();								//in postronin closet extra combat drop drinks to prevent issues
	
	if(LX_kolhs_school()) return true;					//mandatory for first 40 adv to be spent in school
	if(LX_kolhs_yearbookCameraGet()) return true;		//grab the yearbook camera if you have not already done so.
	if(my_level() < 9)									//important to rush level 9 for the superior drink drops
	{
		if(LX_freeCombats(true)) return true;
	}
	if(LX_kolhs_yearbookCameraQuest()) return true;		//gain permanent upgrades to yearbook camera
	
	//TODO other saved by the bell adventures as needed?
	
	return false;
}
