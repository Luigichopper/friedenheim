# res://src/core/inventory/inventory_screen.gd
extends Control

## Real (non-debug) inventory UI. Skyrim-style: select a row, see a larger
## icon + lore description in a detail panel. Pokémon-style: items grouped
## into category tabs by item_type, quantity shown per row.
##
## This screen only ever displays what's in the PartyInventory passed to it —
## it never invents quantities and never talks to a registry-as-truth. The
## item registry is used purely to resolve item_id -> ItemData (name, icon,
## lore, type) for display; PartyInventory is the only source of "how many."

const ITEM_REGISTRY_PATH := "res://src/data/registries/item_registry.tres"

# Tab order maps directly to ItemData.Type values, so tab index == enum value.
const TAB_TYPES: Array[ItemData.Type] = [
	ItemData.Type.WEAPON,
	ItemData.Type.ARMOR,
	ItemData.Type.CONSUMABLE,
	ItemData.Type.MATERIAL,
]
const TAB_NAMES := ["Weapons", "Armor", "Consumables", "Materials"]

@onready var category_tabs: TabBar = %CategoryTabs
@onready var item_list_container: VBoxContainer = %ItemListContainer
@onready var detail_icon: TextureRect = %DetailIcon
@onready var detail_name: Label = %DetailName
@onready var detail_quantity: Label = %DetailQuantity
@onready var detail_lore: Label = %DetailLore
@onready var detail_stats: Label = %DetailStats

var _all_items: Dictionary = {}  # StringName -> ItemData
var _inventory: PartyInventory
var _selected_item_id: StringName = &""


func _ready() -> void:
	for tab_name in TAB_NAMES:
		category_tabs.add_tab(tab_name)
	category_tabs.tab_selected.connect(_on_tab_selected)

	_load_item_registry()
	_clear_detail_panel()


## Call this to bind the screen to a real inventory instance — e.g. the
## player's actual save-loaded PartyInventory. Re-render happens immediately.
func set_inventory(inventory: PartyInventory) -> void:
	_inventory = inventory
	_render_current_tab()


func _load_item_registry() -> void:
	if not ResourceLoader.exists(ITEM_REGISTRY_PATH):
		push_warning("InventoryScreen: item registry not found at %s" % ITEM_REGISTRY_PATH)
		return

	var registry: Registry = load(ITEM_REGISTRY_PATH)
	if registry == null:
		push_warning("InventoryScreen: failed to load item registry resource.")
		return

	_all_items = registry.load_all_blocking()


func _on_tab_selected(_tab_index: int) -> void:
	_render_current_tab()


func _render_current_tab() -> void:
	for child in item_list_container.get_children():
		child.queue_free()

	if _inventory == null:
		return

	var current_type: ItemData.Type = TAB_TYPES[category_tabs.current_tab]
	var owned_ids: Array[StringName] = InventorySystem.get_owned_item_ids(_inventory)

	var matching_ids: Array[StringName] = []
	for item_id in owned_ids:
		var item: ItemData = _all_items.get(item_id)
		if item != null and item.item_type == current_type:
			matching_ids.append(item_id)

	if matching_ids.is_empty():
		var empty_label := Label.new()
		empty_label.text = "(nothing here)"
		empty_label.modulate.a = 0.6
		item_list_container.add_child(empty_label)
		return

	for item_id in matching_ids:
		_add_item_row(item_id, _all_items[item_id])


func _add_item_row(item_id: StringName, item: ItemData) -> void:
	var button := Button.new()
	button.flat = true
	button.alignment = HORIZONTAL_ALIGNMENT_LEFT
	var quantity := InventorySystem.get_quantity(_inventory, item_id)
	button.text = "%s  x%d" % [item.item_name, quantity]
	button.pressed.connect(_on_item_row_selected.bind(item_id))
	item_list_container.add_child(button)


func _on_item_row_selected(item_id: StringName) -> void:
	_selected_item_id = item_id
	var item: ItemData = _all_items.get(item_id)
	if item == null:
		_clear_detail_panel()
		return

	detail_icon.texture = item.icon
	detail_name.text = item.item_name
	detail_quantity.text = "Owned: %d" % InventorySystem.get_quantity(_inventory, item_id)
	detail_lore.text = item.lore_description

	var stats_text := ""
	if item.item_type == ItemData.Type.WEAPON:
		stats_text = "Attack power: %d" % item.power_value
	elif item.item_type == ItemData.Type.ARMOR:
		stats_text = "Defense power: %d" % item.power_value
	elif item.item_type == ItemData.Type.CONSUMABLE and not item.dietary_tags.is_empty():
		stats_text = "Tags: %s" % ", ".join(item.dietary_tags)
	detail_stats.text = stats_text


func _clear_detail_panel() -> void:
	_selected_item_id = &""
	detail_icon.texture = null
	detail_name.text = "Select an item"
	detail_quantity.text = ""
	detail_lore.text = ""
	detail_stats.text = ""
