//Path specific combat handling for One Crazy Random Summer

monster ocrs_combat_helper(string page)
{
	if(!in_ocrs())
	{
		auto_log_error("Should not be in ocrs_combat_helper if not on the path!");
	}

	string combatState = get_property("auto_combatHandler");

	//	ghostly				physical resistance
	//	untouchable			damage reduced to 5, instant kills still good (much less of an issue now

	/*
		For no staggers, don\'t use staggers
		For blocks skills/combat items, we can probably set them all to used as well.
	*/

	if(isFreeMonster(last_monster()))
	{
		if((!contains_text(combatState, "cleesh")) && auto_have_skill($skill[cleesh]) && (my_mp() > 10))
		{
			set_property("auto_useCleesh", false);
			set_property("auto_combatHandler", combatState + "(cleesh)");
		}
	}

	if(last_monster().random_modifiers["unstoppable"])
	{
		if(!contains_text(combatState, "unstoppable"))
		{
			set_property("auto_combatHandler", combatState + "(DNA)(air dirty laundry)(ply reality)(indigo cup)(love mosquito)(blue balls)(love gnats)(unstoppable)(micrometeorite)");
			#Block weaksauce and pocket crumbs?
		}
	}

	if(last_monster().random_modifiers["annoying"])
	{
		if(contains_text(page, "makes the most annoying noise you've ever heard, stopping you in your tracks."))
		{
			auto_log_warning("Last action failed, uh oh! Trying to undo!", "olive");
			set_property("auto_combatHandler", get_property("auto_funCombatHandler"));
		}
		set_property("auto_funCombatHandler", get_property("auto_combatHandler"));
	}

	if(last_monster().random_modifiers["restless"])
	{
		if(contains_text(page, "moves out of the way"))
		{
			auto_log_warning("Last action failed, uh oh! Trying to undo!", "olive");
			set_property("auto_combatHandler", get_property("auto_funCombatHandler"));
		}
		if(contains_text(page, "quickly moves out of the way"))
		{
			auto_log_warning("Last action failed, uh oh! Trying to undo!", "olive");
			set_property("auto_combatHandler", get_property("auto_funCombatHandler"));
		}
		if(contains_text(page, "will have moved by the time"))
		{
			auto_log_warning("Last action failed, uh oh! Trying to undo!", "olive");
			set_property("auto_combatHandler", get_property("auto_funCombatHandler"));
		}

		set_property("auto_funCombatHandler", get_property("auto_combatHandler"));
	}

	if(last_monster().random_modifiers["phase-shifting"])
	{
		if(contains_text(page, "blinks out of existence before"))
		{
			auto_log_warning("Last action failed, uh oh! Trying to undo!", "olive");
			set_property("auto_combatHandler", get_property("auto_funCombatHandler"));
		}
		set_property("auto_funCombatHandler", get_property("auto_combatHandler"));
	}

	if(last_monster().random_modifiers["cartwheeling"])
	{
		if(contains_text(page, "cartwheels out of the way"))
		{
			auto_log_warning("Last action failed, uh oh! Trying to undo!", "olive");
			set_property("auto_combatHandler", get_property("auto_funCombatHandler"));
		}
		set_property("auto_funCombatHandler", get_property("auto_combatHandler"));
	}

	set_property("auto_useCleesh", false);
	if(last_monster().random_modifiers["ticking"])
	{
		if((!contains_text(combatState, "cleesh")) && auto_have_skill($skill[cleesh]) && (my_mp() > 10))
		{
			set_property("auto_useCleesh", true);
		}
	}
	if(last_monster().random_modifiers["untouchable"])
	{
		if((!contains_text(combatState, "cleesh")) && auto_have_skill($skill[cleesh]) && (my_mp() > 10))
		{
			set_property("auto_useCleesh", true);
		}
	}
	return last_monster();
}
