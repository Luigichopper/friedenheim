extends MarginContainer

signal action_processed

var hero: HeroInstance = null

func _ready() -> void:
	%StashFoodList.item_selected.connect(_on_food_selected)
	%FeedActionBtn.pressed.connect(_on_feed_pressed)

func display_hero(h: HeroInstance) -> void:
	hero = h
	var base = hero.get_static_data()
	if not base: return
	
	%SaturationBar.max_value = 100
	%SaturationBar.value = hero.mood_morale
	%MoodBar.max_value = 100
	%MoodBar.value = hero.mood_morale
	
	%ProfileLabel.text = "[b]Dietary Preferences for %s[/b]\nLikes: %s\nDislikes: %s" % [
		base.hero_name, ", ".join(base.dietary_likes) if not base.dietary_likes.is_empty() else "None",
		", ".join(base.dietary_dislikes) if not base.dietary_dislikes.is_empty() else "None"
	]
	
	%StashFoodList.clear()
	%NutritionForecastLabel.text = "Highlight food item to forecast nutrition response..."
	%FeedActionBtn.disabled = true
	
	for item in InventoryManager.get_items_by_category("food"):
		if item.quantity <= 0: continue
		%StashFoodList.add_item("%s (x%d)" % [item.data.item_name, item.quantity])
		%StashFoodList.set_item_metadata(%StashFoodList.item_count - 1, item)

func _on_food_selected(index: int) -> void:
	var item = %StashFoodList.get_item_metadata(index) as InventoryItem
	if not item or not hero: return
	var food_data = item.data as ConsumableData
	var base_hero = hero.get_static_data()
	
	var base_sat = food_data.saturation_value
	var morale_mod = 0
	var note = ""
	
	for tag in food_data.dietary_tags:
		if tag in base_hero.dietary_likes:
			morale_mod += 15
			note = " (Loved Food!)"
		elif tag in base_hero.dietary_dislikes:
			morale_mod -= 20
			note = " (Disliked Food...)"
			
	%NutritionForecastLabel.text = "Forecast: Saturation +%d | Morale Modifier: %s%d%s" % [base_sat, "+" if morale_mod >= 0 else "", morale_mod, note]
	%FeedActionBtn.disabled = false

func _on_feed_pressed() -> void:
	var selected = %StashFoodList.get_selected_items()
	if selected.is_empty(): return
	var item = %StashFoodList.get_item_metadata(selected[0]) as InventoryItem
	if not item: return
	var food_data = item.data as ConsumableData
	var base_hero = hero.get_static_data()
	
	hero.mood_morale = clampi(hero.mood_morale + food_data.saturation_value, 0, 100)
	for tag in food_data.dietary_tags:
		if tag in base_hero.dietary_likes: hero.mood_morale = clampi(hero.mood_morale + 15, 0, 100)
		elif tag in base_hero.dietary_dislikes: hero.mood_morale = clampi(hero.mood_morale - 20, 0, 100)
		
	# FIXED: Cleanly routed deletion sequence through global InventoryManager 
	InventoryManager.remove_item(item.item_id, 1)
	
	action_processed.emit()
