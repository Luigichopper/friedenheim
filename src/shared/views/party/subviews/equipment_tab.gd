extends MarginContainer

signal action_processed

var hero: HeroInstance = null
var current_slot: int = -2

func _ready() -> void:
	%WeaponSlotButton.pressed.connect(func(): _on_slot_clicked(-1))
	%HeadSlotButton.pressed.connect(func(): _on_slot_clicked(0))
	%ChestSlotButton.pressed.connect(func(): _on_slot_clicked(1))
	%LegsSlotButton.pressed.connect(func(): _on_slot_clicked(2))
	%NeckSlotButton.pressed.connect(func(): _on_slot_clicked(3))
	%EligibleStashList.item_selected.connect(_on_item_selected)

func display_hero(h: HeroInstance) -> void:
	hero = h
	_update_slot(%WeaponSlotButton, "Weapon", hero.equipped_weapon_id)
	_update_slot(%HeadSlotButton, "Head Armor", hero.equipped_armor.get(0, ""))
	_update_slot(%ChestSlotButton, "Chest Armor", hero.equipped_armor.get(1, ""))
	_update_slot(%LegsSlotButton, "Legs Armor", hero.equipped_armor.get(2, ""))
	_update_slot(%NeckSlotButton, "Necklace", hero.equipped_armor.get(3, ""))
	%EligibleStashList.clear()
	current_slot = -2

func _update_slot(btn: Button, slot_title: String, item_id: String) -> void:
	if item_id == "": btn.text = "%s: [Empty]" % slot_title
	else:
		var asset = DB.get_item(item_id)
		btn.text = "%s: %s" % [slot_title, asset.item_name if asset else item_id]

func _on_slot_clicked(slot_id: int) -> void:
	if not hero: return
	current_slot = slot_id
	%EligibleStashList.clear()
	%EligibleStashList.add_item("[Unequip Slotted Item]")
	
	for inv_item in InventoryManager.stash:
		var d = inv_item.data
		if not d or inv_item.quantity <= 0: continue
		if slot_id == -1 and d is WeaponData:
			%EligibleStashList.add_item("%s (Qty: %d)" % [d.item_name, inv_item.quantity])
			%EligibleStashList.set_item_metadata(%EligibleStashList.item_count - 1, inv_item.item_id)
		elif slot_id >= 0 and d is ArmorData and d.armor_type == slot_id:
			%EligibleStashList.add_item("%s (Qty: %d)" % [d.item_name, inv_item.quantity])
			%EligibleStashList.set_item_metadata(%EligibleStashList.item_count - 1, inv_item.item_id)

func _on_item_selected(index: int) -> void:
	if not hero or current_slot == -2: return
	var unequipped_id = ""
	var new_target_id = %EligibleStashList.get_item_metadata(index) if index > 0 else ""
	
	if current_slot == -1:
		unequipped_id = hero.equipped_weapon_id
		hero.equipped_weapon_id = new_target_id
	else:
		unequipped_id = hero.equip_armor_piece(current_slot, new_target_id)
		
	if new_target_id != "": _remove_one(new_target_id)
	if unequipped_id != "": InventoryManager.add_item(unequipped_id, 1)
	action_processed.emit()

func _remove_one(id: String) -> void:
	for item in InventoryManager.stash:
		if item.item_id == id:
			item.quantity -= 1
			if item.quantity <= 0: InventoryManager.stash.erase(item)
			break
