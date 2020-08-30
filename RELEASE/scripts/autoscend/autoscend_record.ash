//A record is a data structure for storing a fixed number of elements. It is similar to a structure in C language.
//If we want to have a function return a custom data structure we need to first define it before the function.
//To avoid conflict with our unified header (define cross-dependent functions without circular importing) we first define all records here.
//We then import them to the very begining of autoscend_header.ash
//Note that we only do this for cross dependent functions. If a record is only going to be used in a single file, define it inside that file.
########################################################################################

// Used in autoscend/quests/level_12.ash
record WarPlan
{
	boolean do_arena;
	boolean do_junkyard;
	boolean do_lighthouse;
	boolean do_orchard;
	boolean do_nuns;
	boolean do_farm;
};

//From Zlib Stuff
record kmailObject {
	int id;                   // message id
	string type;              // possible values observed thus far: normal, giftshop
	int fromid;               // sender\'s playerid (0 for npcs)
	int azunixtime;           // KoL server\'s unix timestamp
	string message;           // message (not including items/meat)
	int[item] items;          // items included in the message
	int meat;                 // meat included in the message
	string fromname;          // sender\'s playername
	string localtime;         // your local time according to your KoL account, human-readable string
};

//Record from autoscend/auto_zone.ash
record generic_t
{
	boolean _error;
	boolean _boolean;
	int _int;
	float _float;
	string _string;
	item _item;
	location _location;
	class _class;
	stat _stat;
	skill _skill;
	effect _effect;
	familiar _familiar;
	slot _slot;
	monster _monster;
	element _element;
	phylum _phylum;
};
