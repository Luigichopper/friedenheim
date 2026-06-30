extends MarginContainer

func display_hero(hero: HeroInstance) -> void:
	var base = hero.get_static_data()
	if not base: return
	
	%HeroNameLabel.text = base.hero_name
	%ClassLabel.text = "Class: " + HeroData.HeroClass.keys()[base.hero_class].capitalize()
	%LevelLabel.text = "Level %d" % hero.level
	
	%EXPBar.max_value = hero.level * 100
	%EXPBar.value = hero.current_exp
	%HPValueLabel.text = "%d / %d" % [hero.current_hp, hero.get_max_hp()]
	
	var weapon_bonus = 0
	if hero.equipped_weapon_id != "":
		var w_asset = DB.get_item(hero.equipped_weapon_id) as WeaponData
		if w_asset: weapon_bonus = w_asset.attack_power
	var base_atk = base.base_attack + ((hero.level - 1) * 2)
	%ATKValueLabel.text = "%d (Base: %d | Gear: +%d)" % [(base_atk + weapon_bonus), base_atk, weapon_bonus]
	
	var base_def = base.base_defense + ((hero.level - 1) * 1)
	var calc_def = hero.get_current_defense()
	%DEFValueLabel.text = "%d (Base: %d | Gear: +%d)" % [calc_def, base_def, (calc_def - base_def)]
