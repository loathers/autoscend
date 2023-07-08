#	This is meant for items that have a date of 2007

boolean auto_hasNavelRing()
{
	// check for normal version
	static item navelRing = $item[Navel ring of navel gazing];
	if(auto_is_valid(navelRing) && (item_amount(navelRing) > 0 || have_equipped(navelRing)))
	{
		return true;
	}

	// check for replica in LoL path
	static item replicaNavelRing = $item[replica Navel ring of navel gazing];
	return auto_is_valid(replicaNavelRing) && (item_amount(replicaNavelRing) > 0 || have_equipped(replicaNavelRing));
}

int auto_navelFreeRunChance()
{
	// returns 0 - 100. 0 = 0% of a free run. 100 = 100% chance of a free run
	if(!auto_hasNavelRing())
	{
		return 0;
	}

	// https://kol.coldfront.net/thekolwiki/index.php/Navel_ring_of_navel_gazing
	int navelRunAways = get_property("_navelRunaways").to_int();
	if(navelRunAways < 3) return 100;
	if(navelRunAways < 6) return 80;
	if(navelRunAways < 9) return 50;
	return 20;
}