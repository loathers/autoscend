# This is meant for items that have a date of 2024

boolean auto_haveSpringShoes()
{
	item springShoes = $item[Spring Shoes];
	return auto_is_valid(springShoes) && possessEquipment(springShoes);
}