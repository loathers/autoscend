script "auto_zelda.ash"

boolean in_zelda()
{
	return my_path() == "Path of the Plumber";
}

boolean zelda_initializeSettings()
{
	if(in_zelda())
	{
		set_property("auto_getBeehive", true);
		set_property("auto_wandOfNagamar", false);
		set_property("auto_useCubeling", true);
		// TODO: Remove when quest handling is correct.
		set_property("auto_paranoia", 1);
	}
	return false;
}

boolean zelda_haveHammer()
{
	return possessEquipment($item[hammer]) || possessEquipment($item[heavy hammer]);
}

boolean zelda_equippedHammer()
{
	return equipped_item($slot[weapon]) == $item[hammer]
		|| equipped_item($slot[weapon]) == $item[heavy hammer];
}

boolean zelda_haveFlower()
{
	return possessEquipment($item[[10462]fire flower]) || possessEquipment($item[bonfire flower]);
}

boolean zelda_equippedFlower()
{
	return equipped_item($slot[weapon]) == $item[[10462]fire flower]
		|| equipped_item($slot[weapon]) == $item[bonfire flower];
}

boolean zelda_equippedBoots()
{
	return have_equipped($item[work boots])
		|| have_equipped($item[fancy boots]);
}

int zelda_numBadgesBought()
{
	return (have_skill($skill[[25001]Hammer Throw]).to_int() +
		have_skill($skill[[25002]Ultra Smash]).to_int() +
		have_skill($skill[[25003]Juggle Fireballs]).to_int() +
		have_skill($skill[[25004]Fireball Barrage]).to_int() +
		have_skill($skill[[25005]Spin Jump]).to_int() +
		have_skill($skill[[25006]Multi-Bounce]).to_int() +
		have_skill($skill[Power Plus]).to_int() +
		have_skill($skill[Secret Eye]).to_int() +
		have_skill($skill[Lucky Buckle]).to_int() +
		have_skill($skill[Rainbow Shield]).to_int() +
		have_skill($skill[Lucky Pin]).to_int() +
		have_skill($skill[Lucky Brooch]).to_int() +
		have_skill($skill[Lucky Insignia]).to_int() +
		have_skill($skill[Health Symbol]).to_int());
}


boolean zelda_buySkill(skill sk)
{
	if (have_skill(sk)) return false;

	int cost = 50 + 25 * zelda_numBadgesBought();
	if (item_amount($item[coin]) < cost) return false;

	visit_url("place.php?whichplace=mario&action=mush_badgeshop");

	int idx = 0;
	switch(sk)
	{
		case $skill[[25001]Hammer Throw]: idx=1; break;
		case $skill[[25002]Ultra Smash]: idx=2; break;
		case $skill[[25003]Juggle Fireballs]: idx=3; break;
		case $skill[[25004]Fireball Barrage]: idx=4; break;
		case $skill[[25005]Spin Jump]: idx=5; break;
		case $skill[[25006]Multi-Bounce]: idx=6; break;
		case $skill[Power Plus]: idx=7; break;
		case $skill[Secret Eye]: idx=8; break;
		case $skill[Lucky Buckle]: idx=9; break;
		case $skill[Rainbow Shield]: idx=10; break;
		case $skill[Lucky Pin]: idx=11; break;
		case $skill[Lucky Brooch]: idx=12; break;
		case $skill[Lucky Insignia]: idx=13; break;
		case $skill[Health Symbol]: idx=14; break;
		default: abort("Unrecognized skill");
	}

	run_choice(idx);

	return have_skill(sk);
}

boolean zelda_buyEquipment(item it)
{
	if (possessEquipment(it)) return false;

	int coins = item_amount($item[coin]);

	switch(it){
		case $item[hammer]:
		case $item[[10462]fire flower]:
			if (coins < 20) return false;
			break;
		case $item[frosty button]:
		case $item[back shell]:
		case $item[spiky back shell]:
		case $item[bony back shell]:
			if (coins < 100) return false;
			break;
		case $item[cape]:
			if (coins < 200) return false;
			break;
		case $item[heavy hammer]:
		case $item[bonfire flower]:
		case $item[fancy boots]:
		case $item[power pants]:
			if (coins < 300) return false;
			break;
		default:
			return false;
	}
	retrieve_item(1, it);
	return true;
}

stat zelda_costume()
{
	return get_property("plumberCostumeWorn").to_stat();
}

boolean zelda_buyCostume(stat st)
{
	if (zelda_costume() == st) return false;

	visit_url("place.php?whichplace=mario&action=mush_costumeshop");

	if (item_amount($item[coin]) < get_property("plumberCostumeCost").to_int())
	{
		return false;
	}

	switch(st)
	{
	case $stat[muscle]:
		run_choice(1);
		return true;
	case $stat[mysticality]:
		run_choice(2);
		return true;
	case $stat[moxie]:
		run_choice(3);
		return true;
	}
	return false;
}

record zelda_buyable {
	item it;
	skill sk;
	stat costume;
};

zelda_buyable zelda_buyableItem(item it)
{
	zelda_buyable res;
	res.it = it;
	return res;
}

zelda_buyable zelda_buyableSkill(skill sk)
{
	zelda_buyable res;
	res.sk = sk;
	return res;
}

zelda_buyable zelda_buyableCostume(stat costume)
{
	zelda_buyable res;
	res.costume = costume;
	return res;
}

boolean zelda_buyableIsNothing(zelda_buyable zb)
{
	return zb.it == $item[none] && zb.sk == $skill[none] && zb.costume == $stat[none];
}

zelda_buyable zelda_nextBuyable()
{
	if (!have_skill($skill[Lucky Buckle]))
	{
		return zelda_buyableSkill($skill[Lucky Buckle]);
	}
	else if (!possessEquipment($item[[10462]fire flower]))
	{
		return zelda_buyableItem($item[[10462]fire flower]);
	}
	else if (!have_skill($skill[Secret Eye]))
	{
		return zelda_buyableSkill($skill[Secret Eye]);
	}
	else if (!have_skill($skill[[25006]Multi-Bounce]))
	{
		return zelda_buyableSkill($skill[[25006]Multi-Bounce]);
	}
	else if (!have_skill($skill[Power Plus]))
	{
		return zelda_buyableSkill($skill[Power Plus]);
	}
	else if (!possessEquipment($item[fancy boots]))
	{
		return zelda_buyableItem($item[fancy boots]);
	}
	else if (zelda_costume() != $stat[moxie])
	{
		return zelda_buyableCostume($stat[moxie]);
	}
	else if (!have_skill($skill[Lucky Pin]))
	{
		return zelda_buyableSkill($skill[Lucky Pin]);
	}
	else if (!have_skill($skill[Lucky Brooch]))
	{
		return zelda_buyableSkill($skill[Lucky Brooch]);
	}
	else if (!have_skill($skill[Lucky Insignia]))
	{
		return zelda_buyableSkill($skill[Lucky Insignia]);
	}
	else if (!have_skill($skill[Rainbow Shield]))
	{
		return zelda_buyableSkill($skill[Rainbow Shield]);
	}
	else if (!have_skill($skill[[25004]Fireball Barrage]))
	{
		return zelda_buyableSkill($skill[[25004]Fireball Barrage]);
	}
	else if (!possessEquipment($item[frosty button]))
	{
		return zelda_buyableItem($item[frosty button]);
	}
	else if (!have_skill($skill[Health Symbol]))
	{
		return zelda_buyableSkill($skill[Health Symbol]);
	}
	else if (!have_skill($skill[[25003]Juggle Fireballs]))
	{
		return zelda_buyableSkill($skill[[25003]Juggle Fireballs]);
	}
	else if (!possessEquipment($item[cape]))
	{
		return zelda_buyableItem($item[cape]);
	}
	else if (!possessEquipment($item[bony back shell]))
	{
		return zelda_buyableItem($item[bony back shell]);
	}
	else if (!possessEquipment($item[bonfire flower]))
	{
		return zelda_buyableItem($item[bonfire flower]);
	}

	zelda_buyable nothing;
	return nothing;
}

boolean zelda_nothingToBuy()
{
	zelda_buyable next = zelda_nextBuyable();
	return zelda_buyableIsNothing(next);
}

boolean zelda_buyStuff()
{
	zelda_buyable next = zelda_nextBuyable();
	if(next.sk != $skill[none])
	{
		return zelda_buySkill(next.sk);
	}
	else if(next.it != $item[none])
	{
		return zelda_buyEquipment(next.it);
	}
	else if (next.costume != $stat[none])
	{
		return zelda_buyCostume(next.costume);
	}
	else
	{
		return false;
	}
}

int zelda_ppCost(skill sk)
{
	switch(sk)
	{
		case $skill[[25001]Hammer Throw]:
		case $skill[[25003]Juggle Fireballs]:
		case $skill[[25005]Spin Jump]:
			return 1;
		case $skill[[25002]Ultra Smash]:
		case $skill[[25004]Fireball Barrage]:
		case $skill[[25006]Multi-Bounce]:
			return 2;
		default:
			return 0;
	}
}

boolean zelda_canDealScalingDamage()
{
	item[stat] items_lv1 = {
		$stat[moxie]: $item[work boots],
		$stat[mysticality]: $item[[10462]fire flower],
		$stat[muscle]: $item[hammer],
	};

	item[stat] items_lv2 = {
		$stat[moxie]: $item[fancy boots],
		$stat[mysticality]: $item[bonfire flower],
		$stat[muscle]: $item[heavy hammer],
	};

	// These attacks deal scaling damage at level 1.
	skill[stat] attacks_2pp = {
		$stat[moxie]: $skill[[25006]Multi-Bounce],
		$stat[mysticality]: $skill[[25004]Fireball Barrage],
		$stat[muscle]: $skill[[25002]Ultra Smash],
	};

	// These attacks deal scaling damage at level 3.
	skill[stat] attacks_free = {
		$stat[moxie]: $skill[Jump Attack],
		$stat[mysticality]: $skill[Fireball Toss],
		$stat[muscle]: $skill[Hammer Smash],
	};

	// This is a pretty rough guesstimate.
	int expected_scaler_hp = my_buffedstat(my_primestat());

	foreach st in $stats[]
	{
		int level = 0;
		if (possessEquipment(items_lv2[st]))
		{
			level = 2;
		}
		else if (possessEquipment(items_lv1[st]))
		{
			level = 1;
		}
		else continue;

		// Discard stats that are wildly lower than our max stat.
		if (expected_scaler_hp >= 2 * my_buffedstat(st)) continue;

		level += to_int(zelda_costume() == st);

		if ((my_maxpp() >= 2) && have_skill(attacks_2pp[st])) return true;
		if (level >= 3 && have_skill(attacks_free[st])) return true;
	}

	return false;
}

boolean zelda_skillValid(skill sk)
{
	if(!in_zelda())
	{
		return true;
	}

	if($skills[Jump Attack, [25005]Spin Jump, [25006]Multi-Bounce] contains sk)
	{
		return zelda_equippedBoots();
	}
	else if($skills[Fireball Toss, [25003]Juggle Fireballs, [25004]Fireball Barrage] contains sk)
	{
		return zelda_equippedFlower();
	}
	else if($skills[Hammer Smash, [25001]Hammer Throw, [25002]Ultra Smash] contains sk)
	{
		return zelda_equippedHammer();
	}

	return true;
}

