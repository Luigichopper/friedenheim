# res://src/shared/views/inventory_ui.gd
extends Control

@export_group("UI Layout Nodes")
@export var item_list: ItemList
@export var tab_container: Container # BoxContainer containing your tab buttons
@export var details_panel: PanelContainer
@export var details_panel_margin: MarginContainer

@export_group("Detail Display Fields")
@export var item_name_lbl: Label
@export var item_icon_rect: TextureRect
@export var lore_lbl: Label
@export var weight_lbl: Label
@export var generic_stats_lbl: Label # Catch-all for class traits

var current_category: String = "all"
var displayed_items: Array[InventoryItem] = []

func _ready() -> void:
	# Connect to changes in the inventory data
	InventoryManager.inventory_updated.connect(refresh_ui)
	item_list.item_selected.connect(_on_item_selected)
	
	# Connect your tab buttons. Ensure each button's name matches your categories 
	# e.g., a button named "Weapon", "Armor", "Consumable", "Material", "All"
	for button in tab_container.get_children():
		if button is Button:
			button.pressed.connect(func(): _on_tab_pressed(button.name))
			
	refresh_ui()

## Re-populates the list based on the chosen category tab
func refresh_ui() -> void:
	item_list.clear()
	details_panel_margin.hide()
	
	displayed_items = InventoryManager.get_items_by_category(current_category)
	
	for item in displayed_items:
		if not item or not item.data: continue
		
		var display_text = item.data.item_name
		
		# Append durability markers if applicable to weapons/armor/tools
		if item.data.has_method("has_durability") and item.data.has_durability():
			display_text += " [%d/%d]" % [item.current_durability, item.data.base_durability]
		
		# Append contextual assignment markers if item is attached to a hero body
		if "equipped_by_hero_name" in item and item.equipped_by_hero_name != "":
			display_text += " [Equipped by %s]" % item.equipped_by_hero_name
		elif item.quantity > 1:
			display_text += " (x%d)" % item.quantity
			
		item_list.add_item(display_text, item.data.icon)
		
func _on_tab_pressed(category_name: String) -> void:
	current_category = category_name
	refresh_ui()

## Dynamic inspection parser 
func _on_item_selected(index: int) -> void:
	var selected_slot = displayed_items[index]
	var d = selected_slot.data
	
	# 1. Map fundamental base properties
	item_name_lbl.text = d.item_name
	item_icon_rect.texture = d.icon
	lore_lbl.text = d.lore_description
	weight_lbl.text = "Weight: %.1f kg" % d.weight
	
	# 2. Map class-specific property extensions string-building style
	var stats_text = ""
	
	if d is WeaponData:
		stats_text += "Type: Weapon\n"
		stats_text += "ATK: %d\n" % d.attack_power
		stats_text += "Crit Rate: %.1f%%\n" % (d.crit_rate * 100.0)
		stats_text += "Crit Mult: %.1fx\n" % d.crit_damage_mult
		stats_text += "Durability: %d/%d\n" % [selected_slot.current_durability, d.base_durability]
		stats_text += "Classes: " + _format_classes(d.allowed_hero_classes)
		
	elif d is ArmorData:
		stats_text += "Type: Armor\n"
		stats_text += "DEF: %d\n" % d.defense_power
		stats_text += "Durability: %d/%d\n" % [selected_slot.current_durability, d.base_durability]
		stats_text += "Classes: " + _format_classes(d.allowed_hero_classes)
		
	elif d is ConsumableData:
		stats_text += "Type: Food/Consumable\n"
		stats_text += "Saturation: %d\n" % d.saturation_value
		stats_text += "Dietary Tags: %s" % ", ".join(d.dietary_tags)
		
	elif d is PotionData:
		stats_text += "Type: Potion\n"
		stats_text += "Is Cure: %s\n" % ("Yes" if d.is_cure else "No")
		if d.is_cure:
			stats_text += "Cures: %s" % d.cures_effect_id
			
	elif d is MaterialData:
		stats_text += "Type: Crafting Material\n"
		stats_text += "Value: %d Gold" % d.base_cost

	generic_stats_lbl.text = stats_text
	details_panel_margin.show()

## Decodes Enum arrays into readable strings
func _format_classes(classes_array: Array) -> String:
	if classes_array.is_empty():
		return "Any"
	# Converts your HeroData.HeroClass enum integers to their mapped string forms
	var names = classes_array.map(func(c): return HeroData.HeroClass.keys()[c])
	return ", ".join(names)
