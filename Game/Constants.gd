class_name Constants

###
# Light flags
###

enum LightType {
	Normal = 1 << 0,
	Spectral = 1 << 1
}
const LightTypeAll = LightType.Normal | LightType.Spectral

###
# Entity unique ids used for keeping track of a given entity (chest # opened, key # picked up, ...)
#
# Exit the editor before modifying one of these enums
# Be eloquent about the entity origin (DO: KEY_MANSION_ENTRANCE_TO_KITCHEN, DON'T: KEY_1)
# Prefix every entry with the name of the enum (DO: KEY_MANSION_ENTRANCE_TO_KITCHEN, DON'T: MANSION_ENTRANCE_TO_KITCHEN)
#
# You can rename an entry, but *NEVER REMOVE ONE* as it would *BREAK* every ids:
# 	- If an entry is no longer used, rename it to something "REMOVED_WAS_" + old name
#	- You can recycle no longer used entry for another entity: REMOVED_WAS_KEY_CLOSET to KEY_KITCHEN_OVEN1
###

enum KeyId {
	KEY_DYNAMIC, # this key is generated, and won't ever be saved as picked up
	KEY_DEBUG_1,
	REMOVED_WAS_KEY_CLOSET,
	KEY_MANSION_ENTRANCE_TO_KITCHEN
}

enum ChestId {
	CHEST_DYNAMIC, # this chest is generated, and won't ever be saved as opened
	CHEST_DEBUG_1,
	REMOVED_WAS_CHEST_WITH_KEY_CLOSET
	CHEST_WITH_KEY_MANSION_ENTRANCE_TO_KITCHEN,
}

###
# Physics constants
###

const PhysicsSleepLength := 5.0

###
# File namings conventions
###

# A_* => anims
# T_* => texture
# TA_* => texture atlas
# TS_* => tileset
# MUS_* => musics
# SND_* => sounds
# No prefix => scenes

###
# File structure convention
###

# /Player
# -> /Scenes
# -> /Scenes/Player.tscn <- base scene
# -> /Scripts
# -> /Scripts/Player.gd <- base class
# -> /Textures
# -> /Textures/T_Luigi.png
