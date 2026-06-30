# res://src/data/classes/hero_instance.gd
extends Resource
class_name HeroInstance

enum AssignmentStatus {
	BENCHED,   # At base, resting, available to be put into the next venture
	DEPLOYED,  # Currently selected for the active 4-hero venture squad
	DEAD       # Slain on a previous run; requires revival at base
}

@export_group("Identifier")
## The unique YARD identifier string (e.g., "eisen", "vyr") used to pull static properties.
@export var hero_id: String = ""

@export_group("Progression State")
@export var level: int = 1
@export var current_exp: int = 0
@export var bond_rank: int = 1
@export var mood_morale: int = 100

@export_group("Venture Management")
@export var status: AssignmentStatus = AssignmentStatus.BENCHED

@export_group("Equipment Slots")
@export var equipped_weapon_id: String = ""
## Maps ArmorData.ArmorType (cast to int) -> YARD String ID of the equipped armor piece.
@export var equipped_armor: Dictionary[int, String] = {}

@export_group("Vitals")
@export var current_hp: int = 50


# --- DYNAMIC YARD REGISTRY LOOKUPS ---

## Helper function to safely resolve the static structural layout from our DB autoload wrapper.
func get_static_data() -> HeroData:
	if hero_id == "":
		return null
	return DB.get_hero(hero_id)


## Derives maximum hit points dynamically based on the underlying YARD stats + level modifier.
func get_max_hp() -> int:
	var base = get_static_data()
	if not base: 
		return 50
	return base.base_hp + ((level - 1) * 10)


## Loops through all equipped armor references to aggregate the total actual defensive capability.
func get_current_defense() -> int:
	var base = get_static_data()
	if not base: 
		return 0
	
	# Start with the template's base defense stat + level scaling
	var total_defense: int = base.base_defense + ((level - 1) * 1)
	
	# Query YARD for each slot's armor piece
	for slot in equipped_armor:
		var armor_id: String = equipped_armor[slot]
		if armor_id == "": 
			continue
		
		var armor_asset = DB.get_item(armor_id) as ArmorData
		if armor_asset:
			total_defense += armor_asset.base_defense
			
	return total_defense


# --- LIFECYCLE & INVENTORY LOGIC ---

## Equips an armor piece into its designated slot. 
## Returns the YARD ID of the item that was unequipped (if any), so it can go back to stash.
func equip_armor_piece(armor_type: int, target_armor_id: String) -> String:
	var unequipped_id: String = ""
	
	if equipped_armor.has(armor_type):
		unequipped_id = equipped_armor[armor_type]
		
	if target_armor_id == "":
		equipped_armor.erase(armor_type) # Clears the slot completely if stripping gear
	else:
		equipped_armor[armor_type] = target_armor_id
		
	return unequipped_id


## Creates a completely isolated, standalone clone of this object for volatile runtime tracking.
func duplicate_for_venture() -> HeroInstance:
	var copy = HeroInstance.new()
	copy.hero_id = self.hero_id
	copy.level = self.level
	copy.current_exp = self.current_exp
	copy.bond_rank = self.bond_rank
	copy.mood_morale = self.mood_morale
	copy.status = self.status
	copy.equipped_weapon_id = self.equipped_weapon_id
	copy.current_hp = self.current_hp
	
	# Deep-duplicate the equipment dictionary to avoid shared reference bugs mid-run
	copy.equipped_armor = self.equipped_armor.duplicate()
	
	return copy
