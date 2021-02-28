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
# Entity constants
###

const KeyId = {
	KEY_1 = "KEY_1",
	KEY_2 = "KEY_2"
}

const ChestId = {
	CHEST_1 = "CHEST_1",
	CHEST_2 = "CHEST_2",
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
