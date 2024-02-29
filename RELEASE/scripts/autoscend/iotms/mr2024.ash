# This is meant for items that have a date of 2024

boolean auto_hasSpringShoes()
{
	// check for normal version
	static item springShoes = $item[spring shoes];
	if(auto_is_valid(springShoes) && (item_amount(springShoes) > 0 || have_equipped(springShoes)))
	{
		return true;
	}
}
