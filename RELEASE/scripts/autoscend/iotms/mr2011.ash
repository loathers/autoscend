#	This is meant for items that have a date of 2011

boolean isClipartItem(item it)
{
	return $items[Ur-Donut,
	The Bomb,
	box of Familiar Jacks,
	bucket of wine,
	ultrafondue,
	oversized snowflake,
	unbearable light,
	crystal skull,
	borrowed time,
	box of hammers,
	shining halo,
	furry halo,
	frosty halo,
	time halo,
	Lumineux Limnio,
	Morto Moreto,
	Temps Tempranillo,
	Bordeaux Marteaux,
	Fromage Pinotage,
	Beignet Milgranet,
	Muschat,
	cool jelly donut,
	shrapnel jelly donut,
	occult jelly donut,
	thyme jelly donut,
	frozen danish,
	smashed danish,
	forbidden danish,
	cool cat claw,
	blunt cat claw,
	shadowy cat claw,
	cheezburger,
	toasted brie,
	potion of the field gar,
	too legit potion,
	Bright Water,
	cold-filtered water,
	graveyard snowglobe,
	cool cat elixir,
	potion of the captain\'s hammer,
	potion of X-ray vision,
	potion of the litterbox,
	potion of animal rage,
	potion of punctual companionship,
	holy bomb\, batman,
	bobcat grenade,
	chocolate frosted sugar bomb,
	broken glass grenade,
	noxious gas grenade,
	skull with a fuse in it,
	boozebomb,
	4:20 bomb,
	blunt icepick,
	fluorescent lightbulb,
	blammer,
	clock-cleaning hammer,
	hammerus,
	broken clock,
	dethklok,
	glacial clock] contains it;
}

boolean hasLegionKnife()
{
	//checks if we have the [Loathing Legion knife] in any one of its foldable forms.
	if(!is_unrestricted($item[Loathing Legion knife]))	//not auto_is_valid as some paths might restrict specific forms only
	{
		return false;
	}
	if(in_hardcore())
	{
		return false;		//LLK specifically does not work in hardcore.
	}
	//we need to check all possible forms it might be in
	foreach it in get_related($item[Loathing Legion knife], "fold")
	{
		if(item_amount(it) > 0)
		{
			return true;
		}
	}
	return false;
}

boolean pullLegionKnife()
{
	//acquire the [Loathing Legion knife] if we do not already have it.
	if(!is_unrestricted($item[Loathing Legion knife]))	//not auto_is_valid as some paths might restrict specific forms only
	{
		return false;
	}
	if(in_hardcore())
	{
		return false;	//loathing legion knife is not usable in hardcore
	}
	if(hasLegionKnife())
	{
		return true;	//already have it
	}
	item target = $item[none];
	foreach it in get_related($item[Loathing Legion knife], "fold")
	{
		if(canPull(it))
		{
			target = it;
			break;
		}
	}
	if(target == $item[none])
	{
		return false;	//we do not have the item to pull
	}
	int start_amt = item_amount(target);
	pullXWhenHaveY(target, 1, 0);
	if(item_amount(target) == 1+start_amt)
	{
		return true;
	}
	auto_log_warning("Mysteriously failed to pull [" +target+ "]. even though we should have been able to get it", "red");
	return false;
}
