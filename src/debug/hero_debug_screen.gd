# res://src/debug/hero_debug_screen.gd
extends Control

## Minimal debug viewer. Loads every HeroData entry from the hero registry,
## pairs each with a freshly-created HeroState, and dumps both side by side.
## Also exposes a feeding panel (consumables -> mood) and an equipment panel
## (weapons/armor -> effective attack/defense). No styling, no save/load —
## this exists purely to validate that HeroData/HeroState/ItemData wiring,
## FeedingSystem, and CombatStats are all correct before anything else gets
## built on top of them.

# Adjust these paths once registries exist via the YARD editor tab.
const HERO_REGISTRY_PATH := "res://src/data/registries/hero_registry.tres"
const ITEM_REGISTRY_PATH := "res://src/data/registries/item_registry.tres"

@onready var list_container: VBoxContainer = %HeroListContainer
@onready var hero_selector: OptionButton = %HeroSelector
@onready var consumables_container: VBoxContainer = %ConsumablesContainer
@onready var equipment_container: VBoxContainer = %EquipmentContainer
@onready var inventory_rows_container: VBoxContainer = %InventoryRowsContainer

const HERO_CLASS_NAMES := ["Swordsman", "Ranger", "Cleric"]
const MOOD_NAMES := ["Happy", "Neutral", "Sad", "Upset"]
# Referencing the enum directly rather than hardcoding ints — safe even if
# ItemData.Type's declared order changes later.
const CONSUMABLE_TYPE := ItemData.Type.CONSUMABLE
const WEAPON_TYPE := ItemData.Type.WEAPON
const ARMOR_TYPE := ItemData.Type.ARMOR

# Keeps every loaded hero's data+state alive together, keyed by string id,
# so the feeding/equip panels and the card list all mutate the same instances.
# Debug-only — a real game would source this from wherever party state lives.
var _hero_table: Dictionary = {}  # StringName -> {data: HeroData, state: HeroState}
var _all_items: Dictionary = {}  # StringName -> ItemData, every item in the registry
var _consumable_items: Dictionary = {}  # StringName -> ItemData, filtered subset
var _equipment_items: Dictionary = {}  # StringName -> ItemData, filtered subset

# Debug-only PartyInventory, populated entirely through the grant/revoke
# buttons below. NOT connected to feeding/equipping yet — those still pull
# straight from the item registry with infinite supply. Wiring them to
# actually consume from this inventory is a follow-up step, not done here.
var _debug_inventory := PartyInventory.new()


func _ready() -> void:
	_load_heroes()
	_refresh_hero_cards()
	_populate_hero_selector()
	_load_items()
	_display_consumables()
	_display_equipment()
	_display_inventory_debug_rows()


func _load_heroes() -> void:
	if not ResourceLoader.exists(HERO_REGISTRY_PATH):
		_add_error_label(
			"Hero registry not found at %s\n— Create it in the YARD editor tab first." % HERO_REGISTRY_PATH
		)
		return

	var registry: Registry = load(HERO_REGISTRY_PATH)
	if registry == null:
		_add_error_label("Failed to load hero registry resource (wrong type or corrupt file).")
		return

	var all_heroes: Dictionary = registry.load_all_blocking()

	if all_heroes.is_empty():
		_add_error_label("Hero registry loaded but contains zero entries.")
		return

	for string_id: StringName in all_heroes.keys():
		var hero: HeroData = all_heroes[string_id]
		_hero_table[string_id] = {
			"data": hero,
			"state": _create_fresh_state(string_id, hero),
		}


## Builds a brand-new HeroState for debug display only. Once a save system
## exists, this is replaced by an actual load-from-save call — this function
## should not be relied on outside this debug screen.
func _create_fresh_state(string_id: StringName, hero: HeroData) -> HeroState:
	var state := HeroState.new()
	state.hero_id = string_id
	state.current_hp = hero.base_hp
	return state


## Clears and rebuilds every hero card from _hero_table's current contents.
## Called after any state mutation (e.g. feeding) so changes are visible
## immediately without needing a manual refresh.
func _refresh_hero_cards() -> void:
	for child in list_container.get_children():
		child.queue_free()

	if _hero_table.is_empty():
		return

	for string_id: StringName in _hero_table.keys():
		var entry: Dictionary = _hero_table[string_id]
		_add_hero_card(string_id, entry["data"], entry["state"])


func _populate_hero_selector() -> void:
	hero_selector.clear()
	for string_id: StringName in _hero_table.keys():
		var hero: HeroData = _hero_table[string_id]["data"]
		hero_selector.add_item(hero.hero_name)
		# OptionButton only stores int ids natively, so we keep the matching
		# string_id in metadata on the item we just added.
		hero_selector.set_item_metadata(hero_selector.item_count - 1, string_id)


func _load_items() -> void:
	if not ResourceLoader.exists(ITEM_REGISTRY_PATH):
		_add_error_label_to(
			consumables_container,
			"Item registry not found at %s\n— Create it in the YARD editor tab first." % ITEM_REGISTRY_PATH
		)
		return

	var registry: Registry = load(ITEM_REGISTRY_PATH)
	if registry == null:
		_add_error_label_to(consumables_container, "Failed to load item registry resource.")
		return

	_all_items = registry.load_all_blocking()

	for string_id: StringName in _all_items.keys():
		var item: ItemData = _all_items[string_id]
		if item.item_type == CONSUMABLE_TYPE:
			_consumable_items[string_id] = item
		elif item.item_type == WEAPON_TYPE or item.item_type == ARMOR_TYPE:
			_equipment_items[string_id] = item


func _display_consumables() -> void:
	for child in consumables_container.get_children():
		child.queue_free()

	if _consumable_items.is_empty():
		_add_error_label_to(consumables_container, "No CONSUMABLE-type items found in item registry.")
		return

	for string_id: StringName in _consumable_items.keys():
		_add_consumable_row(string_id, _consumable_items[string_id])


func _display_equipment() -> void:
	for child in equipment_container.get_children():
		child.queue_free()

	if _equipment_items.is_empty():
		_add_error_label_to(equipment_container, "No WEAPON or ARMOR items found in item registry.")
		return

	for string_id: StringName in _equipment_items.keys():
		_add_equipment_row(string_id, _equipment_items[string_id])


func _display_inventory_debug_rows() -> void:
	for child in inventory_rows_container.get_children():
		child.queue_free()

	if _all_items.is_empty():
		_add_error_label_to(inventory_rows_container, "No items loaded — check item registry.")
		return

	for string_id: StringName in _all_items.keys():
		_add_inventory_debug_row(string_id, _all_items[string_id])


func _add_inventory_debug_row(item_id: StringName, item: ItemData) -> void:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)

	var quantity_label := Label.new()
	quantity_label.text = "%s  x%d" % [item.item_name, InventorySystem.get_quantity(_debug_inventory, item_id)]
	quantity_label.size_flags_horizontal = SIZE_EXPAND_FILL
	quantity_label.name = "QtyLabel"
	row.add_child(quantity_label)

	var minus_button := Button.new()
	minus_button.text = "-1"
	minus_button.pressed.connect(_on_inventory_revoke_pressed.bind(item_id, quantity_label))
	row.add_child(minus_button)

	var plus_button := Button.new()
	plus_button.text = "+1"
	plus_button.pressed.connect(_on_inventory_grant_pressed.bind(item_id, quantity_label))
	row.add_child(plus_button)

	inventory_rows_container.add_child(row)


func _on_inventory_grant_pressed(item_id: StringName, quantity_label: Label) -> void:
	InventorySystem.add_item(_debug_inventory, item_id, 1)
	_refresh_inventory_row_label(item_id, quantity_label)


func _on_inventory_revoke_pressed(item_id: StringName, quantity_label: Label) -> void:
	InventorySystem.remove_item(_debug_inventory, item_id, 1)
	_refresh_inventory_row_label(item_id, quantity_label)


func _refresh_inventory_row_label(item_id: StringName, quantity_label: Label) -> void:
	var item: ItemData = _all_items[item_id]
	quantity_label.text = "%s  x%d" % [item.item_name, InventorySystem.get_quantity(_debug_inventory, item_id)]


func _add_consumable_row(string_id: StringName, item: ItemData) -> void:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)

	var label := Label.new()
	label.text = "%s  [tags: %s]" % [item.item_name, ", ".join(item.dietary_tags)]
	label.size_flags_horizontal = SIZE_EXPAND_FILL
	row.add_child(label)

	var feed_button := Button.new()
	feed_button.text = "Feed"
	feed_button.pressed.connect(_on_feed_pressed.bind(string_id))
	row.add_child(feed_button)

	consumables_container.add_child(row)


const ITEM_TYPE_NAMES := ["Weapon", "Armor", "Consumable", "Material"]


func _add_equipment_row(string_id: StringName, item: ItemData) -> void:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)

	var label := Label.new()
	label.text = "%s  [%s, power %d]" % [
		item.item_name,
		ITEM_TYPE_NAMES[item.item_type],
		item.power_value,
	]
	label.size_flags_horizontal = SIZE_EXPAND_FILL
	row.add_child(label)

	var equip_button := Button.new()
	equip_button.text = "Equip"
	equip_button.pressed.connect(_on_equip_pressed.bind(string_id))
	row.add_child(equip_button)

	equipment_container.add_child(row)


func _on_feed_pressed(item_id: StringName) -> void:
	var selected_index := hero_selector.selected
	if selected_index < 0:
		_add_error_label_to(consumables_container, "No hero selected — pick one from the dropdown first.")
		return

	var hero_id: StringName = hero_selector.get_item_metadata(selected_index)
	if not _hero_table.has(hero_id):
		_add_error_label_to(consumables_container, "Selected hero id not found in hero table: %s" % hero_id)
		return

	var item: ItemData = _consumable_items.get(item_id)
	if item == null:
		_add_error_label_to(consumables_container, "Selected item id not found: %s" % item_id)
		return

	var entry: Dictionary = _hero_table[hero_id]
	var hero: HeroData = entry["data"]
	var state: HeroState = entry["state"]

	FeedingSystem.feed(hero, item, state)
	_refresh_hero_cards()


func _on_equip_pressed(item_id: StringName) -> void:
	var selected_index := hero_selector.selected
	if selected_index < 0:
		_add_error_label_to(equipment_container, "No hero selected — pick one from the dropdown first.")
		return

	var hero_id: StringName = hero_selector.get_item_metadata(selected_index)
	if not _hero_table.has(hero_id):
		_add_error_label_to(equipment_container, "Selected hero id not found in hero table: %s" % hero_id)
		return

	var item: ItemData = _equipment_items.get(item_id)
	if item == null:
		_add_error_label_to(equipment_container, "Selected item id not found: %s" % item_id)
		return

	var entry: Dictionary = _hero_table[hero_id]
	var state: HeroState = entry["state"]

	# equip() itself enforces "only WEAPON/ARMOR equipment can be equipped, and
	# it always replaces whatever was already in that one matching slot" — this
	# IS the structural enforcement of "1 weapon + 1 armor", not extra logic here.
	var equipped := state.equip(item_id, item)
	if not equipped:
		_add_error_label_to(equipment_container, "%s has no valid equip slot." % item.item_name)
		return

	_refresh_hero_cards()


func _add_hero_card(string_id: StringName, hero: HeroData, state: HeroState) -> void:
	var card := PanelContainer.new()
	var vbox := VBoxContainer.new()
	card.add_child(vbox)

	_add_line(vbox, "id: %s" % string_id, true)

	_add_section_label(vbox, "— HeroData (template) —")
	_add_line(vbox, "name: %s" % hero.hero_name)
	_add_line(vbox, "class: %s" % HERO_CLASS_NAMES[hero.hero_class])
	_add_line(vbox, "lore: %s" % hero.lore_description)
	_add_line(vbox, "base_hp: %d   base_accuracy: %d   base_grit: %d" % [
		hero.base_hp, hero.base_accuracy, hero.base_grit
	])
	_add_line(vbox, "base_attack: %d   base_defense: %d" % [hero.base_attack, hero.base_defense])
	_add_line(vbox, "dietary_likes: %s" % str(hero.dietary_likes))
	_add_line(vbox, "dietary_dislikes: %s" % str(hero.dietary_dislikes))
	_add_line(vbox, "combat_affinities: %s" % str(hero.combat_affinities))
	_add_line(vbox, "skills_by_bond_rank: %s" % str(hero.skills_by_bond_rank))

	_add_section_label(vbox, "— HeroState (runtime, freshly created) —")
	_add_line(vbox, "level: %d   xp: %d / %d" % [state.level, state.current_xp, state.xp_to_next_level])
	_add_line(vbox, "bond_rank: %d   bond_points: %d / %d" % [
		state.bond_rank, state.bond_points, state.bond_points_to_next_rank
	])
	_add_line(vbox, "unlocked_skills @ rank %d: %s" % [
		state.bond_rank, str(hero.get_unlocked_skill_ids(state.bond_rank))
	])
	_add_line(vbox, "mood: %s (%s)" % [
		MOOD_NAMES[state.current_mood],
		state.mood_reason if state.mood_reason != "" else "no reason set"
	])
	_add_line(vbox, "current_hp: %d / %d" % [state.current_hp, hero.base_hp])
	_add_line(vbox, "benched: %s" % ("yes — " + state.benched_reason if state.is_benched else "no"))

	var weapon: ItemData = _all_items.get(state.equipped_weapon_id)
	var armor: ItemData = _all_items.get(state.equipped_armor_id)
	_add_line(vbox, "equipped weapon: %s" % (weapon.item_name if weapon else "(none)"))
	_add_line(vbox, "equipped armor: %s" % (armor.item_name if armor else "(none)"))
	_add_line(vbox, "mood multiplier (base stats only): x%.2f" % CombatStats.get_mood_multiplier(state.current_mood))
	_add_line(vbox, "effective_attack: %d   effective_defense: %d" % [
		CombatStats.get_effective_attack(hero, weapon, state.current_mood),
		CombatStats.get_effective_defense(hero, armor, state.current_mood),
	])

	list_container.add_child(card)

	var spacer := Control.new()
	spacer.custom_minimum_size = Vector2(0, 12)
	list_container.add_child(spacer)


func _add_section_label(parent: VBoxContainer, text: String) -> void:
	var label := Label.new()
	label.text = text
	label.add_theme_color_override("font_color", Color.AQUA)
	parent.add_child(label)


func _add_line(parent: VBoxContainer, text: String, is_header: bool = false) -> void:
	var label := Label.new()
	label.text = text
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	if is_header:
		label.add_theme_color_override("font_color", Color.YELLOW)
	parent.add_child(label)


func _add_error_label(text: String) -> void:
	_add_error_label_to(list_container, text)


func _add_error_label_to(parent: VBoxContainer, text: String) -> void:
	var label := Label.new()
	label.text = "[DEBUG ERROR] " + text
	label.add_theme_color_override("font_color", Color.RED)
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	parent.add_child(label)
