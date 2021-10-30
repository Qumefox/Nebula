//A storage item intended to be used by other items to provide storage functionality.
//Types that use this should consider overriding emp_act() and hear_talk(), unless they shield their contents somehow.
/obj/item/storage/internal
	var/obj/item/master_item

/obj/item/storage/internal/Initialize()
	. = ..()
	master_item = loc
	name = master_item.name
	verbs -= /obj/item/verb/verb_pickup

/obj/item/storage/internal/Destroy()
	master_item = null
	. = ..()

/obj/item/storage/internal/attack_hand()
	return		//make sure this is never picked up

/obj/item/storage/internal/mob_can_equip()
	return FALSE //make sure this is never picked up

//Helper procs to cleanly implement internal storages - storage items that provide inventory slots for other items.
//These procs are completely optional, it is up to the master item to decide when it's storage get's opened by calling open()
//However they are helpful for allowing the master item to pretend it is a storage item itself.
//If you are using these you will probably want to override attackby() as well.
//See /obj/item/clothing/suit/storage for an example.

//items that use internal storage have the option of calling this to emulate default storage handle_mouse_drop behaviour.
//returns 1 if the master item's parent's handle_mouse_drop() should be called, 0 otherwise. It's strange, but no other way of
//doing it without the ability to call another proc's parent, really.
/obj/item/storage/internal/proc/handle_storage_internal_mouse_drop(mob/user, obj/over_object)
	if (ishuman(user) || issmall(user)) //so monkeys can take off their backpacks -- Urist

		if(over_object == user && Adjacent(user)) // this must come before the screen objects only block
			src.open(user)
			return 0

		if (!( istype(over_object, /obj/screen/inventory) ))
			return 1

		//makes sure master_item is equipped before putting it in hand, so that we can't drag it into our hand from miles away.
		//there's got to be a better way of doing this...
		if (!user.isEquipped(master_item))
			return 0

		if(!user.incapacitated())
			var/obj/screen/inventory/inv = over_object
			master_item.add_fingerprint(user)
			if(user.unEquip(master_item))
				user.equip_to_slot_if_possible(master_item, inv.slot_id)
			return 0
	return 0

//items that use internal storage have the option of calling this to emulate default storage attack_hand behaviour.
//returns 1 if the master item's parent's attack_hand() should be called, 0 otherwise.
//It's strange, but no other way of doing it without the ability to call another proc's parent, really.
/obj/item/storage/internal/proc/handle_attack_hand(mob/user)

	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if(H.l_store == master_item && !H.get_active_hand())	//Prevents opening if it's in a pocket.
			H.put_in_hands(master_item)
			H.l_store = null
			return 0
		if(H.r_store == master_item && !H.get_active_hand())
			H.put_in_hands(master_item)
			H.r_store = null
			return 0

	src.add_fingerprint(user)
	if (master_item.loc == user)
		src.open(user)
		return 0

	for(var/mob/M in range(1, master_item.loc))
		if (M.s_active == src)
			src.close(M)
	return 1

/obj/item/storage/internal/Adjacent(var/atom/neighbor)
	return master_item.Adjacent(neighbor)

// Used by webbings, coat pockets, etc
/obj/item/storage/internal/pockets/Initialize(mapload, var/slots, var/slot_size)
	storage_slots = slots
	max_w_class = slot_size
	. = ..()

/obj/item/storage/internal/pouch/Initialize(mapload, var/storage_space)
	max_storage_space = storage_space
	. = ..()