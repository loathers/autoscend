boolean in_plumber()
{
	return my_path() == "Path of the Plumber";
}

boolean plumber_initializeSettings()
{
	if(in_plumber())
	{
		set_property("auto_getBeehive", true);
		set_property("auto_wandOfNagamar", false);
		// TODO: Remove when quest handling is correct.
		set_property("auto_paranoia", 1);
	}
	return false;
}

boolean plumber_haveHammer()
{
	return possessEquipment($item[hammer]) || possessEquipment($item[heavy hammer]);
}

boolean plumber_equippedHammer()
{
	return equipped_item($slot[weapon]) == $item[hammer]
		|| equipped_item($slot[weapon]) == $item[heavy hammer];
}

boolean plumber_haveFlower()
{
	return possessEquipment($item[[10462]fire flower]) || possessEquipment($item[bonfire flower]);
}

boolean plumber_equippedFlower()
{
	return equipped_item($slot[weapon]) == $item[[10462]fire flower]
		|| equipped_item($slot[weapon]) == $item[bonfire flower];
}

boolean plumber_equippedBoots()
{
	return have_equipped($item[work boots])
		|| have_equipped($item[fancy boots]);
}

int plumber_numBadgesBought()
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


boolean plumber_buySkill(skill sk)
{
	if (have_skill(sk)) return false;

	int cost = 50 + 25 * plumber_numBadgesBought();
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

boolean plumber_buyEquipment(item it)
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

stat plumber_costume()
{
	return get_property("plumberCostumeWorn").to_stat();
}

boolean plumber_buyCostume(stat st)
{
	if (plumber_costume() == st) return false;

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

record plumber_buyable {
	item it;
	skill sk;
	stat costume;
};

plumber_buyable plumber_buyableItem(item it)
{
	plumber_buyable res;
	res.it = it;
	return res;
}

plumber_buyable plumber_buyableSkill(skill sk)
{
	plumber_buyable res;
	res.sk = sk;
	return res;
}

plumber_buyable plumber_buyableCostume(stat costume)
{
	plumber_buyable res;
	res.costume = costume;
	return res;
}

boolean plumber_buyableIsNothing(plumber_buyable zb)
{
	return zb.it == $item[none] && zb.sk == $skill[none] && zb.costume == $stat[none];
}

plumber_buyable plumber_nextBuyable()
{
	if (!have_skill($skill[Lucky Buckle]))
	{
		return plumber_buyableSkill($skill[Lucky Buckle]);
	}
	else if (!possessEquipment($item[[10462]fire flower]))
	{
		return plumber_buyableItem($item[[10462]fire flower]);
	}
	else if (!have_skill($skill[Secret Eye]))
	{
		return plumber_buyableSkill($skill[Secret Eye]);
	}
	else if (!have_skill($skill[[25006]Multi-Bounce]))
	{
		return plumber_buyableSkill($skill[[25006]Multi-Bounce]);
	}
	else if (!have_skill($skill[Power Plus]))
	{
		return plumber_buyableSkill($skill[Power Plus]);
	}
	else if (!possessEquipment($item[fancy boots]))
	{
		return plumber_buyableItem($item[fancy boots]);
	}
	else if (plumber_costume() != $stat[moxie])
	{
		return plumber_buyableCostume($stat[moxie]);
	}
	else if (!have_skill($skill[Lucky Pin]))
	{
		return plumber_buyableSkill($skill[Lucky Pin]);
	}
	else if (!have_skill($skill[Lucky Brooch]))
	{
		return plumber_buyableSkill($skill[Lucky Brooch]);
	}
	else if (!have_skill($skill[Lucky Insignia]))
	{
		return plumber_buyableSkill($skill[Lucky Insignia]);
	}
	else if (!have_skill($skill[Rainbow Shield]))
	{
		return plumber_buyableSkill($skill[Rainbow Shield]);
	}
	else if (!have_skill($skill[[25004]Fireball Barrage]))
	{
		return plumber_buyableSkill($skill[[25004]Fireball Barrage]);
	}
	else if (!possessEquipment($item[frosty button]))
	{
		return plumber_buyableItem($item[frosty button]);
	}
	else if (!have_skill($skill[Health Symbol]))
	{
		return plumber_buyableSkill($skill[Health Symbol]);
	}
	else if (!have_skill($skill[[25003]Juggle Fireballs]))
	{
		return plumber_buyableSkill($skill[[25003]Juggle Fireballs]);
	}
	else if (!possessEquipment($item[cape]))
	{
		return plumber_buyableItem($item[cape]);
	}
	else if (!possessEquipment($item[bony back shell]))
	{
		return plumber_buyableItem($item[bony back shell]);
	}
	else if (!possessEquipment($item[bonfire flower]))
	{
		return plumber_buyableItem($item[bonfire flower]);
	}

	plumber_buyable nothing;
	return nothing;
}

boolean plumber_nothingToBuy()
{
	plumber_buyable next = plumber_nextBuyable();
	return plumber_buyableIsNothing(next);
}

boolean plumber_buyStuff()
{
	plumber_buyable next = plumber_nextBuyable();
	if(next.sk != $skill[none])
	{
		return plumber_buySkill(next.sk);
	}
	else if(next.it != $item[none])
	{
		return plumber_buyEquipment(next.it);
	}
	else if (next.costume != $stat[none])
	{
		return plumber_buyCostume(next.costume);
	}
	else
	{
		return false;
	}
}

int plumber_ppCost(skill sk)
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

boolean plumber_canDealScalingDamage()
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

		level += to_int(plumber_costume() == st);

		if ((my_maxpp() >= 2) && have_skill(attacks_2pp[st])) return true;
		if (level >= 3 && have_skill(attacks_free[st])) return true;
	}

	return false;
}

boolean plumber_skillValid(skill sk)
{
	if(!in_plumber())
	{
		return true;
	}

	if($skills[Jump Attack, [25005]Spin Jump, [25006]Multi-Bounce] contains sk)
	{
		return plumber_equippedBoots();
	}
	else if($skills[Fireball Toss, [25003]Juggle Fireballs, [25004]Fireball Barrage] contains sk)
	{
		return plumber_equippedFlower();
	}
	else if($skills[Hammer Smash, [25001]Hammer Throw, [25002]Ultra Smash] contains sk)
	{
		return plumber_equippedHammer();
	}

	return true;
}

boolean plumber_equipTool(stat st)
{
	if (!in_plumber()) return false;

	boolean equipWithFallback(item to_equip, item fallback_to_equip)
	{
		if (possessEquipment(to_equip) && autoEquip(to_equip))
		{
			return true;
		}
		else if (possessEquipment(fallback_to_equip))
		{
			return autoEquip(fallback_to_equip);
		}
		else if (item_amount($item[coin]) >= 20)
		{
			// 20 coins to avoid doing clever re-routing? Yes please!
			retrieve_item(1, fallback_to_equip);
			return autoEquip(fallback_to_equip);
		}
		return false;
	}

	switch (st)
	{
		case $stat[muscle]: return equipWithFallback($item[heavy hammer], $item[hammer]);
		case $stat[mysticality]: return equipWithFallback($item[bonfire flower], $item[[10462]fire flower]);
		case $stat[moxie]: return equipWithFallback($item[fancy boots], $item[work boots]);
	}
	return false;
}
