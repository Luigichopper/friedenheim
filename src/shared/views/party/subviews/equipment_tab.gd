# res://src/shared/views/party/subviews/equipment_tab.gd
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
	if item_id == "":
		btn.text = "%s: [Empty]" % slot_title
	else:
		var asset = DB.get_item(item_id)
		var display_text = "%s: %s" % [slot_title, asset.item_name if asset else item_id]
		
		# UPDATED: Render dynamic durability properties cleanly directly on the slot row
		if asset and asset.has_method("has_durability") and asset.has_durability():
			display_text += " [Durability: %d/%d]" % [asset.base_durability, asset.base_durability]
			
		btn.text = display_text


func _on_slot_clicked(slot_id: int) -> void:
	if not hero: return
	current_slot = slot_id
	%EligibleStashList.clear()
	
	# Determine if the currently targeted slot has gear inside it
	var is_slot_occupied = false
	if slot_id == -1:
		is_slot_occupied = (hero.equipped_weapon_id != "")
	else:
		is_slot_occupied = (hero.equipped_armor.get(slot_id, "") != "")
		
	# UPDATED: The unequip action item line only generates if something is actively assigned here
	if is_slot_occupied:
		%EligibleStashList.add_item("[ Unequip Slotted Item ]")
		# Give it metadata marking it as a clear instruction
		%EligibleStashList.set_item_metadata(0, "__UNEQUIP__")
	
	# Populate matching vault inventory stashes
	for inv_item in InventoryManager.stash:
		var d = inv_item.data
		if not d or inv_item.quantity <= 0: continue
		
		if slot_id == -1 and d is WeaponData:
			# This line inside your equipment_tab.gd automatically draws the values:
			%EligibleStashList.add_item("%s [%d/%d]" % [d.item_name, inv_item.current_durability, d.base_durability])
			%EligibleStashList.set_item_metadata(%EligibleStashList.item_count - 1, inv_item.item_id)
		elif slot_id >= 0 and d is ArmorData and d.armor_type == slot_id:
			# This line inside your equipment_tab.gd automatically draws the values:
			%EligibleStashList.add_item("%s [%d/%d]" % [d.item_name, inv_item.current_durability, d.base_durability])
			%EligibleStashList.set_item_metadata(%EligibleStashList.item_count - 1, inv_item.item_id)


func _on_item_selected(index: int) -> void:
	if not hero or current_slot == -2: return
	
	var meta_instruction = %EligibleStashList.get_item_metadata(index)
	var unequipped_id = ""
	var new_target_id = ""
	
	# Check if the player explicitly triggered the context-aware unequip command
# Inside _on_item_selected() in equipment_tab.gd
	if meta_instruction == "__UNEQUIP__":
		if current_slot == -1:
			unequipped_id = hero.equipped_weapon_id
			hero.equipped_weapon_id = ""
		else:
			unequipped_id = hero.equip_armor_piece(current_slot, "")
	else:
		new_target_id = meta_instruction
		if current_slot == -1:
			unequipped_id = hero.equipped_weapon_id
			hero.equipped_weapon_id = new_target_id
		else:
			unequipped_id = hero.equip_armor_piece(current_slot, new_target_id)
			
		if new_target_id != "": 
			# FIXED: Routed through the unified InventoryManager pipeline
			InventoryManager.remove_item(new_target_id, 1)
			
	if unequipped_id != "": 
		InventoryManager.add_item(unequipped_id, 1)
		
	action_processed.emit()
