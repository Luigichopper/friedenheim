# res://src/data/classes/material_data.gd
extends ItemData
class_name MaterialData
# No extra fields yet — crafting/selling-only for now. Exists as its own
# class (not just "ItemData base") so the registry/type system stays
# consistent: every concrete item is a leaf subclass, none are bare ItemData.
