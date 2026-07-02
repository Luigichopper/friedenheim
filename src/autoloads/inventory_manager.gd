# res://src/autoloads/inventory_manager.gd
extends Node

signal inventory_updated

var stash: Array[InventoryItem]:
	get:
		if SaveManager.current_save: return SaveManager.current_save.shared_inventory
		return []


func add_item(item_id: String, qty: int = 1) -> void:
	var item_asset = DB.get_item(item_id)
	if not item_asset: return
	
	var new_item = InventoryItem.new()
	new_item.item_id = item_id
	new_item.quantity = qty
	if item_asset.has_method("has_durability") and item_asset.has_durability():
		if "base_durability" in item_asset:
			new_item.current_durability = item_asset.base_durability
			
	if not item_asset.has_method("has_durability") or not item_asset.has_durability():
		for existing_item in stash:
			if existing_item.can_stack_with(new_item):
				existing_item.quantity += qty
				inventory_updated.emit()
				return
				
	stash.append(new_item)
	inventory_updated.emit()



## UPDATED: Combines static vault storage + equipped hero weapons/armor items
func get_items_by_category(category_name: String) -> Array[InventoryItem]:
	var master_list: Array[InventoryItem] = []
	
	# 1. Grab everything sitting loose inside the base camp stash vault
	for item in stash:
		master_list.append(item)
		
	# 2. Parse through active hero assets to inject virtual equipped items
	if SaveManager.current_save:
		for hero in SaveManager.current_save.roster:
			var base_hero = hero.get_static_data()
			var hero_display_name = base_hero.hero_name if base_hero else hero.hero_id
			
			# --- FIXED WEAPON DURABILITY SYNC ---
			if hero.equipped_weapon_id != "":
				var eq_weapon = InventoryItem.new()
				eq_weapon.item_id = hero.equipped_weapon_id
				eq_weapon.quantity = 1
				eq_weapon.equipped_by_hero_name = hero_display_name
				
				# PULL LIVE STATE: If your HeroInstance tracks weapon durability, copy it here
				if "equipped_weapon_durability" in hero:
					eq_weapon.current_durability = hero.equipped_weapon_durability
				else:
					# Fallback to base data max if your system hasn't split variable tracking yet
					var asset = DB.get_item(hero.equipped_weapon_id)
					if asset and "base_durability" in asset:
						eq_weapon.current_durability = asset.base_durability
						
				master_list.append(eq_weapon)
				
			# --- FIXED ARMOR DURABILITY SYNC ---
			for slot_id in hero.equipped_armor:
				var armor_id = hero.equipped_armor[slot_id]
				if armor_id != "":
					var eq_armor = InventoryItem.new()
					eq_armor.item_id = armor_id
					eq_armor.quantity = 1
					eq_armor.equipped_by_hero_name = hero_display_name
					
					# PULL LIVE STATE: Look up the slot durability if tracked on the hero frame
					if "equipped_armor_durability" in hero and hero.equipped_armor_durability.has(slot_id):
						eq_armor.current_durability = hero.equipped_armor_durability[slot_id]
					else:
						# Fallback to item base profile max data defaults
						var asset = DB.get_item(armor_id)
						if asset and "base_durability" in asset:
							eq_armor.current_durability = asset.base_durability
							
					master_list.append(eq_armor)

	# 3. Apply your standard UI filter mapping rules
	if category_name.to_lower() == "all":
		return master_list
		
	var filtered: Array[InventoryItem] = []
	for item in master_list:
		if item.matches_type(category_name):
			filtered.append(item)
	return filtered
