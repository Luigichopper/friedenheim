extends MarginContainer

func display_hero(hero: HeroInstance) -> void:
	var base = hero.get_static_data()
	if not base: return
	%HeroPortraitRect.texture = base.portrait
	%BiographyLabel.text = base.lore_description
