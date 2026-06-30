# res://src/shared/views/party/roster_management_ui.gd
extends Control

var selected_hero: HeroInstance = null

func _ready() -> void:
	rebuild_roster_list()
	%RosterList.item_selected.connect(_on_hero_selected)
	%TabContainer.tab_changed.connect(_refresh_active_tab)
	
	# Connect processing signals from mutated equipment or food screens
	%EquipmentTab.action_processed.connect(commit_data_change_and_refresh)
	%FeedingTab.action_processed.connect(commit_data_change_and_refresh)
	
	if %RosterList.item_count > 0:
		%RosterList.select(0)
		_on_hero_selected(0)

func rebuild_roster_list() -> void:
	%RosterList.clear()
	if not SaveManager.current_save or SaveManager.current_save.roster.is_empty(): return
		
	for hero in SaveManager.current_save.roster:
		var base = hero.get_static_data()
		var display_name = base.hero_name if base else hero.hero_id
		var status_text = "[Bench]" if hero.status == HeroInstance.AssignmentStatus.BENCHED else "[Active]"
		if hero.status == HeroInstance.AssignmentStatus.DEAD: status_text = "[DEAD]"
		%RosterList.add_item("%s %s (Lvl %d)" % [status_text, display_name, hero.level])

func _on_hero_selected(index: int) -> void:
	if index < 0 or index >= SaveManager.current_save.roster.size(): return
	selected_hero = SaveManager.current_save.roster[index]
	_refresh_active_tab(%TabContainer.current_tab)

func _refresh_active_tab(tab_index: int) -> void:
	if not selected_hero: return
	match tab_index:
		0: %InfoTab.display_hero(selected_hero)
		1: %EquipmentTab.display_hero(selected_hero)
		2: %FeedingTab.display_hero(selected_hero)
		3: %LoreTab.display_hero(selected_hero)

func commit_data_change_and_refresh() -> void:
	SaveManager.save_game()
	var current_idx = SaveManager.current_save.roster.find(selected_hero)
	rebuild_roster_list()
	if current_idx != -1:
		%RosterList.select(current_idx)
		_refresh_active_tab(%TabContainer.current_tab)
