script "cc_list.ash"

# familiar, int, item, effect, location defined. Define the rest at some point.

#	All lists have the construct type[int] and are 0-indexed, like nature intended.
#	Types: familiar, item
# 	Replace TYPE with types above
#	TYPE[int] TYPEList();							Empty List Construction
#	TYPE[int] List(boolean[TYPE]);					Create from existing map
#	TYPE[int] List(TYPE[int]);						Create from existing int map
#	TYPE[int] ListRemove(TYPE[int], TYPE);			Remove all elements matching what
#	TYPE[int] ListRemove(TYPE[int], TYPE, int);		Remove all elements matching what, starting from index
#	TYPE[int] ListErase(TYPE[int], int);			Remove element at index
#	TYPE[int] ListInsertFront(TYPE[int], TYPE);		Insert at start of list
#	TYPE[int] ListInsert(TYPE[int], TYPE);			Insert at end of list
#	TYPE[int] ListInsertAt(TYPE[int], TYPE, int);	Insert at a given index, push all elements at index forward
#	TYPE[int] ListInsertInorder(TYPE[int], TYPE);	Insert inorder based on string value, assumes invariant
#	int ListFind(TYPE[int], TYPE);					Returns location of element, -1 otherwise
#	int ListFind(TYPE[int], TYPE, int);				Returns location of element, -1 otherwise, starting from index
#	ListOutput(TYPE[int]);							Prints a comma-separated version of the list

# Printer
string ListOutput(familiar[int] list);

# Default Constructors
familiar[int] familiarList();

# Explicit Constructors (from map boolean[type])
familiar[int] List(boolean[familiar] data);

# Explicit Constructors (from map type[int])
familiar[int] List(familiar[int] data);

# Removal element/index
familiar[int] ListRemove(familiar[int] list, familiar what);
familiar[int] ListRemove(familiar[int] list, familiar what, int idx);
familiar[int] ListErase(familiar[int] list, int index);

# Insertion head/tail/at/inorder
familiar[int] ListInsertFront(familiar[int] list, familiar what);
familiar[int] ListInsert(familiar[int] list, familiar what);
familiar[int] ListInsertAt(familiar[int] list, familiar what, int idx);
familiar[int] ListInsertInorder(familiar[int] list, familiar what);

# Searching
int ListFind(familiar[int] list, familiar what);
int ListFind(familiar[int] list, familiar what, int idx);

familiar[int] List()
{
	familiar[int] retval;
	return retval;
}

familiar[int] List(boolean[familiar] data)
{
	familiar[int] retval;
	int index = 0;

	foreach el in data
	{
		retval[index] = el;
		index = index + 1;
	}
	return retval;
}

familiar[int] List(familiar[int] data)
{
	familiar[int] retval;

	//To handle constants if they are passed by const
	familiar[int] temp;
	foreach idx, el in data
	{
		temp[idx] = el;
	}
#	print(ListOutput(data), "red");
#	print(ListOutput(temp), "gray");
	sort temp by index;

	int index = 0;
	foreach idx, el in temp
	{
		retval[index] = el;
		index = index + 1;
	}

	return retval;
}

int ListFind(familiar[int] list, familiar what)
{
	return ListFind(list, what, 0);
}

int ListFind(familiar[int] list, familiar what, int idx)
{
	if(idx < 0)
	{
		abort("Attempted index out of bounds: " + idx);
	}
	familiar[int] retval = List(list);
	int at = idx;
	while(at < count(retval))
	{
		if(what == retval[at])
		{
			return at;
		}
		at = at + 1;
	}
	return -1;
}


familiar[int] ListRemove(familiar[int] list, familiar what)
{
	return ListRemove(list, what, 0);
}

familiar[int] ListRemove(familiar[int] list, familiar what, int idx)
{
	familiar[int] retval = List(list);
#	print(ListOutput(list), "red");
#	print(ListOutput(retval), "gray");
	foreach at, el in retval
	{
		if((el == what) && (at >= idx))
		{
			remove retval[at];
		}
	}
	return List(retval);
}

familiar[int] ListErase(familiar[int] list, int index)
{
	familiar[int] retval = List(list);
#	print(ListOutput(list), "red");
#	print(ListOutput(retval), "gray");
	remove retval[index];
	return List(retval);
}

familiar[int] ListInsertFront(familiar[int] list, familiar what)
{
	familiar[int] retval = List(list);
	retval[-1] = what;
	return List(retval);
}

familiar[int] ListInsert(familiar[int] list, familiar what)
{
	familiar[int] retval = List(list);
	retval[count(retval)] = what;
	return List(retval);
}

familiar[int] ListInsertAt(familiar[int] list, familiar what, int idx)
{
	if((idx < 0) || (idx >= count(list)))
	{
		abort("List index " + idx + " out of bounds: " + count(list));
	}
	familiar[int] retval = List(list);
	int shift = count(retval);
	while(shift > idx)
	{
		retval[shift] = retval[shift-1];
		shift = shift - 1;
	}
	retval[idx] = what;
	return retval;
}

familiar[int] ListInsertInorder(familiar[int] list, familiar what)
{
	familiar[int] retval = List(list);
	if(to_string(what) < to_string(retval[0]))
	{
		return ListInsertAt(list, what, 0);
	}
	int shift = count(retval);
	while(shift > 0)
	{
		if(to_string(what) > to_string(retval[shift-1]))
		{
			retval[shift] = what;
			return retval;
		}
		retval[shift] = retval[shift-1];
		shift = shift - 1;
	}
	if(shift == 0)
	{
		abort("Inorder Insertion Failure");
	}
	return retval;
}

string ListOutput(familiar[int] list)
{
	string retval;
	if(count(list) > 0)
	{
		retval = to_string(list[0]);
		int index = 1;
		while(index < count(list))
		{
			retval = retval + ", " + to_string(list[index]);
			index = index + 1;
		}
	}

	return retval;
}


void main()
{
	boolean[familiar] test = $familiars[Slimeling, Puck Man, Baby Gravy Fairy, Intergnat, Mosquito];
	familiar[int] list = List(test);

	print("First list", "green");
	print(ListOutput(list), "blue");

	print("Deleting Baby Gravy Fairy, (2)", "green");
	list = ListRemove(list, $familiar[Baby Gravy Fairy]);
	print(ListOutput(list), "blue");

	print("Deleting Element 1 (Puck Man)", "green");
	list = ListErase(list, 1);
	print(ListOutput(list), "blue");

	print("Inserting at Front (Exotic Parrot)", "green");
	list = ListInsertFront(list, $familiar[Exotic Parrot]);
	print(ListOutput(list), "blue");

	print("Inserting at End (Leprechaun)", "green");
	list = ListInsert(list, $familiar[Leprechaun]);
	print(ListOutput(list), "blue");

	print("Inserting at 2 (Artistic Goth Kid)", "green");
	list = ListInsertAt(list, $familiar[Artistic Goth Kid], 2);
	print(ListOutput(list), "blue");

	print("Inserting at 0 (Artistic Goth Kid)", "green");
	list = ListInsertAt(list, $familiar[Artistic Goth Kid], 0);
	print(ListOutput(list), "blue");

	print("Inserting inorder weirdness (Bulky Buddy Box)", "green");
	list = ListInsertInorder(list, $familiar[Bulky Buddy Box]);
	print(ListOutput(list), "blue");

	print("Inserting inorder weirdness (Xiblaxian Holo-Companion)", "green");
	list = ListInsertInorder(list, $familiar[Xiblaxian Holo-Companion]);
	print(ListOutput(list), "blue");

	int index = 0;
	while(index < count(list))
	{
		print(index + ": " + list[index] + ": " + ListFind(list, list[index]), "blue");
		index = index + 1;
	}
	print(3 + ": " + list[3] + ": " + list.ListFind(list[3], 1), "blue");
	print(3 + ": " + list[3] + ": " + list.ListFind(list[3], 2), "blue");
	print(3 + ": " + list[3] + ": " + list.ListFind(list[3], 3), "blue");
	print(3 + ": " + list[3] + ": " + list.ListFind(list[3], 4), "blue");
}

// start of int[int]

string ListOutput(int[int] list);

int[int] intList();

int[int] List(boolean[int] data);

int[int] List(int[int] data);

int[int] ListRemove(int[int] list, int what);
int[int] ListRemove(int[int] list, int what, int idx);
int[int] ListErase(int[int] list, int index);

int[int] ListInsertFront(int[int] list, int what);
int[int] ListInsert(int[int] list, int what);
int[int] ListInsertAt(int[int] list, int what, int idx);
int[int] ListInsertInorder(int[int] list, int what);

int ListFind(int[int] list, int what);
int ListFind(int[int] list, int what, int idx);

int[int] intList()
{
	int[int] retval;
	return retval;
}

int[int] List(boolean[int] data)
{
	int[int] retval;
	int index = 0;

	foreach el in data
	{
		retval[index] = el;
		index = index + 1;
	}
	return retval;
}

int[int] List(int[int] data)
{
	int[int] retval;

	int[int] temp;
	foreach idx, el in data
	{
		temp[idx] = el;
	}
	sort temp by index;

	int index = 0;
	foreach idx, el in temp
	{
		retval[index] = el;
		index = index + 1;
	}

	return retval;
}

int ListFind(int[int] list, int what)
{
	return ListFind(list, what, 0);
}

int ListFind(int[int] list, int what, int idx)
{
	if(idx < 0)
	{
		abort("Attempted index out of bounds: " + idx);
	}
	int[int] retval = List(list);
	int at = idx;
	while(at < count(retval))
	{
		if(what == retval[at])
		{
			return at;
		}
		at = at + 1;
	}
	return -1;
}


int[int] ListRemove(int[int] list, int what)
{
	return ListRemove(list, what, 0);
}

int[int] ListRemove(int[int] list, int what, int idx)
{
	int[int] retval = List(list);
	foreach at, el in retval
	{
		if((el == what) && (at >= idx))
		{
			remove retval[at];
		}
	}
	return List(retval);
}

int[int] ListErase(int[int] list, int index)
{
	int[int] retval = List(list);
	remove retval[index];
	return List(retval);
}

int[int] ListInsertFront(int[int] list, int what)
{
	int[int] retval = List(list);
	retval[-1] = what;
	return List(retval);
}

int[int] ListInsert(int[int] list, int what)
{
	int[int] retval = List(list);
	retval[count(retval)] = what;
	return List(retval);
}

int[int] ListInsertAt(int[int] list, int what, int idx)
{
	if((idx < 0) || (idx >= count(list)))
	{
		abort("List index " + idx + " out of bounds: " + count(list));
	}
	int[int] retval = List(list);
	int shift = count(retval);
	while(shift > idx)
	{
		retval[shift] = retval[shift-1];
		shift = shift - 1;
	}
	retval[idx] = what;
	return retval;
}

int[int] ListInsertInorder(int[int] list, int what)
{
	int[int] retval = List(list);
	if(to_string(what) < to_string(retval[0]))
	{
		return ListInsertAt(list, what, 0);
	}
	int shift = count(retval);
	while(shift > 0)
	{
		if(to_string(what) > to_string(retval[shift-1]))
		{
			retval[shift] = what;
			return retval;
		}
		retval[shift] = retval[shift-1];
		shift = shift - 1;
	}
	if(shift == 0)
	{
		abort("Inorder Insertion Failure");
	}
	return retval;
}

string ListOutput(int[int] list)
{
	string retval;
	if(count(list) > 0)
	{
		retval = to_string(list[0]);
		int index = 1;
		while(index < count(list))
		{
			retval = retval + ", " + to_string(list[index]);
			index = index + 1;
		}
	}

	return retval;
}


//End of int[int]
//start of item[int]

string ListOutput(item[int] list);

item[int] itemList();

item[int] List(boolean[item] data);

item[int] List(item[int] data);

item[int] ListRemove(item[int] list, item what);
item[int] ListRemove(item[int] list, item what, int idx);
item[int] ListErase(item[int] list, int index);

item[int] ListInsertFront(item[int] list, item what);
item[int] ListInsert(item[int] list, item what);
item[int] ListInsertAt(item[int] list, item what, int idx);
item[int] ListInsertInorder(item[int] list, item what);

int ListFind(item[int] list, item what);
int ListFind(item[int] list, item what, int idx);

item[int] itemList()
{
	item[int] retval;
	return retval;
}

item[int] List(boolean[item] data)
{
	item[int] retval;
	int index = 0;

	foreach el in data
	{
		retval[index] = el;
		index = index + 1;
	}
	return retval;
}

item[int] List(item[int] data)
{
	item[int] retval;

	item[int] temp;
	foreach idx, el in data
	{
		temp[idx] = el;
	}
	sort temp by index;

	int index = 0;
	foreach idx, el in temp
	{
		retval[index] = el;
		index = index + 1;
	}

	return retval;
}

int ListFind(item[int] list, item what)
{
	return ListFind(list, what, 0);
}

int ListFind(item[int] list, item what, int idx)
{
	if(idx < 0)
	{
		abort("Attempted index out of bounds: " + idx);
	}
	item[int] retval = List(list);
	int at = idx;
	while(at < count(retval))
	{
		if(what == retval[at])
		{
			return at;
		}
		at = at + 1;
	}
	return -1;
}


item[int] ListRemove(item[int] list, item what)
{
	return ListRemove(list, what, 0);
}

item[int] ListRemove(item[int] list, item what, int idx)
{
	item[int] retval = List(list);
	foreach at, el in retval
	{
		if((el == what) && (at >= idx))
		{
			remove retval[at];
		}
	}
	return List(retval);
}

item[int] ListErase(item[int] list, int index)
{
	item[int] retval = List(list);
	remove retval[index];
	return List(retval);
}

item[int] ListInsertFront(item[int] list, item what)
{
	item[int] retval = List(list);
	retval[-1] = what;
	return List(retval);
}

item[int] ListInsert(item[int] list, item what)
{
	item[int] retval = List(list);
	retval[count(retval)] = what;
	return List(retval);
}

item[int] ListInsertAt(item[int] list, item what, int idx)
{
	if((idx < 0) || (idx >= count(list)))
	{
		abort("List index " + idx + " out of bounds: " + count(list));
	}
	item[int] retval = List(list);
	int shift = count(retval);
	while(shift > idx)
	{
		retval[shift] = retval[shift-1];
		shift = shift - 1;
	}
	retval[idx] = what;
	return retval;
}

item[int] ListInsertInorder(item[int] list, item what)
{
	item[int] retval = List(list);
	if(to_string(what) < to_string(retval[0]))
	{
		return ListInsertAt(list, what, 0);
	}
	int shift = count(retval);
	while(shift > 0)
	{
		if(to_string(what) > to_string(retval[shift-1]))
		{
			retval[shift] = what;
			return retval;
		}
		retval[shift] = retval[shift-1];
		shift = shift - 1;
	}
	if(shift == 0)
	{
		abort("Inorder Insertion Failure");
	}
	return retval;
}

string ListOutput(item[int] list)
{
	string retval;
	if(count(list) > 0)
	{
		retval = to_string(list[0]);
		int index = 1;
		while(index < count(list))
		{
			retval = retval + ", " + to_string(list[index]);
			index = index + 1;
		}
	}

	return retval;
}
//end of item[int]
//start of effect[int]

string ListOutput(effect[int] list);

effect[int] effectList();

effect[int] List(boolean[effect] data);

effect[int] List(effect[int] data);

effect[int] ListRemove(effect[int] list, effect what);
effect[int] ListRemove(effect[int] list, effect what, int idx);
effect[int] ListErase(effect[int] list, int index);

effect[int] ListInsertFront(effect[int] list, effect what);
effect[int] ListInsert(effect[int] list, effect what);
effect[int] ListInsertAt(effect[int] list, effect what, int idx);
effect[int] ListInsertInorder(effect[int] list, effect what);

int ListFind(effect[int] list, effect what);
int ListFind(effect[int] list, effect what, int idx);

effect[int] effectList()
{
	effect[int] retval;
	return retval;
}

effect[int] List(boolean[effect] data)
{
	effect[int] retval;
	int index = 0;

	foreach el in data
	{
		retval[index] = el;
		index = index + 1;
	}
	return retval;
}

effect[int] List(effect[int] data)
{
	effect[int] retval;

	effect[int] temp;
	foreach idx, el in data
	{
		temp[idx] = el;
	}
	sort temp by index;

	int index = 0;
	foreach idx, el in temp
	{
		retval[index] = el;
		index = index + 1;
	}

	return retval;
}

int ListFind(effect[int] list, effect what)
{
	return ListFind(list, what, 0);
}

int ListFind(effect[int] list, effect what, int idx)
{
	if(idx < 0)
	{
		abort("Attempted index out of bounds: " + idx);
	}
	effect[int] retval = List(list);
	int at = idx;
	while(at < count(retval))
	{
		if(what == retval[at])
		{
			return at;
		}
		at = at + 1;
	}
	return -1;
}


effect[int] ListRemove(effect[int] list, effect what)
{
	return ListRemove(list, what, 0);
}

effect[int] ListRemove(effect[int] list, effect what, int idx)
{
	effect[int] retval = List(list);
	foreach at, el in retval
	{
		if((el == what) && (at >= idx))
		{
			remove retval[at];
		}
	}
	return List(retval);
}

effect[int] ListErase(effect[int] list, int index)
{
	effect[int] retval = List(list);
	remove retval[index];
	return List(retval);
}

effect[int] ListInsertFront(effect[int] list, effect what)
{
	effect[int] retval = List(list);
	retval[-1] = what;
	return List(retval);
}

effect[int] ListInsert(effect[int] list, effect what)
{
	effect[int] retval = List(list);
	retval[count(retval)] = what;
	return List(retval);
}

effect[int] ListInsertAt(effect[int] list, effect what, int idx)
{
	if((idx < 0) || (idx >= count(list)))
	{
		abort("List index " + idx + " out of bounds: " + count(list));
	}
	effect[int] retval = List(list);
	int shift = count(retval);
	while(shift > idx)
	{
		retval[shift] = retval[shift-1];
		shift = shift - 1;
	}
	retval[idx] = what;
	return retval;
}

effect[int] ListInsertInorder(effect[int] list, effect what)
{
	effect[int] retval = List(list);
	if(to_string(what) < to_string(retval[0]))
	{
		return ListInsertAt(list, what, 0);
	}
	int shift = count(retval);
	while(shift > 0)
	{
		if(to_string(what) > to_string(retval[shift-1]))
		{
			retval[shift] = what;
			return retval;
		}
		retval[shift] = retval[shift-1];
		shift = shift - 1;
	}
	if(shift == 0)
	{
		abort("Inorder Insertion Failure");
	}
	return retval;
}

string ListOutput(effect[int] list)
{
	string retval;
	if(count(list) > 0)
	{
		retval = to_string(list[0]);
		int index = 1;
		while(index < count(list))
		{
			retval = retval + ", " + to_string(list[index]);
			index = index + 1;
		}
	}

	return retval;
}
//end of effect[int]
//start of location[int]
location ListOutput(location[int] list);

location[int] locationList();

location[int] List(boolean[location] data);

location[int] List(location[int] data);

location[int] ListRemove(location[int] list, location what);
location[int] ListRemove(location[int] list, location what, int idx);
location[int] ListErase(location[int] list, int index);

location[int] ListInsertFront(location[int] list, location what);
location[int] ListInsert(location[int] list, location what);
location[int] ListInsertAt(location[int] list, location what, int idx);
location[int] ListInsertInorder(location[int] list, location what);

int ListFind(location[int] list, location what);
int ListFind(location[int] list, location what, int idx);

location ListOutput(location[int] list);

location[int] locationList()
{
	location[int] retval;
	return retval;
}

location[int] List(boolean[location] data)
{
	location[int] retval;
	int index = 0;

	foreach el in data
	{
		retval[index] = el;
		index = index + 1;
	}
	return retval;
}

location[int] List(location[int] data)
{
	location[int] retval;

	location[int] temp;
	foreach idx, el in data
	{
		temp[idx] = el;
	}
	sort temp by index;

	int index = 0;
	foreach idx, el in temp
	{
		retval[index] = el;
		index = index + 1;
	}

	return retval;
}

int ListFind(location[int] list, location what)
{
	return ListFind(list, what, 0);
}

int ListFind(location[int] list, location what, int idx)
{
	if(idx < 0)
	{
		abort("Attempted index out of bounds: " + idx);
	}
	location[int] retval = List(list);
	int at = idx;
	while(at < count(retval))
	{
		if(what == retval[at])
		{
			return at;
		}
		at = at + 1;
	}
	return -1;
}


location[int] ListRemove(location[int] list, location what)
{
	return ListRemove(list, what, 0);
}

location[int] ListRemove(location[int] list, location what, int idx)
{
	location[int] retval = List(list);
	foreach at, el in retval
	{
		if((el == what) && (at >= idx))
		{
			remove retval[at];
		}
	}
	return List(retval);
}

location[int] ListErase(location[int] list, int index)
{
	location[int] retval = List(list);
	remove retval[index];
	return List(retval);
}

location[int] ListInsertFront(location[int] list, location what)
{
	location[int] retval = List(list);
	retval[-1] = what;
	return List(retval);
}

location[int] ListInsert(location[int] list, location what)
{
	location[int] retval = List(list);
	retval[count(retval)] = what;
	return List(retval);
}

location[int] ListInsertAt(location[int] list, location what, int idx)
{
	if((idx < 0) || (idx >= count(list)))
	{
		abort("List index " + idx + " out of bounds: " + count(list));
	}
	location[int] retval = List(list);
	int shift = count(retval);
	while(shift > idx)
	{
		retval[shift] = retval[shift-1];
		shift = shift - 1;
	}
	retval[idx] = what;
	return retval;
}

location[int] ListInsertInorder(location[int] list, location what)
{
	location[int] retval = List(list);
	if(to_string(what) < to_string(retval[0]))
	{
		return ListInsertAt(list, what, 0);
	}
	int shift = count(retval);
	while(shift > 0)
	{
		if(to_string(what) > to_string(retval[shift-1]))
		{
			retval[shift] = what;
			return retval;
		}
		retval[shift] = retval[shift-1];
		shift = shift - 1;
	}
	if(shift == 0)
	{
		abort("Inorder Insertion Failure");
	}
	return retval;
}

string ListOutput(location[int] list)
{
	string retval;
	if(count(list) > 0)
	{
		retval = to_string(list[0]);
		int index = 1;
		while(index < count(list))
		{
			retval = retval + ", " + to_string(list[index]);
			index = index + 1;
		}
	}

	return retval;
}

//end of location[int]