boolean in_underTheSea()
{
    return my_path() == $path[11,037 Leagues Under the Sea];
}

void sea_store()
{
    if(!in_underTheSea())
    {
        return;
    }
    
    int pennies = item_amount($item[sand penny]);
    if(pennies >= 100 && possessEquipment($item[undersea surveying goggles]))
    {
        //abort("Buy undersea surveying goggles from Wet Crap For Sale!");
        buy($coinmaster[Wet Crap For Sale], 1, $item[undersea surveying goggles]);
    }

    return;
}

void sea_pulls()
{
    if(!in_underTheSea())
    {
        return;
    }

    foreach it in $items[Mer-kin knucklebone, Mer-kin scholar mask, Mer-kin scholar tailpiece,
    Mer-kin gladiator mask, Mer-kin gladiator tailpiece, Mer-kin Prayerbeads, sea lasso, sea cowbell,
    sea chaps, sea cowboy hat, shark jumper, scale-mail underwear, comb jelly]
    {
        pullXWhenHaveY(it,1,0);
    }

    return;
}

boolean LM_underTheSea()
{
    if(!in_underTheSea())
    {
        return false;
    }

    visit_url("place.php?whichplace=sea_oldman&action=oldman_oldman");

    return false;
}