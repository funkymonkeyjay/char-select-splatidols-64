if incompatibilityCond or not retroCharAPI then return end
local SMB_RED = retroCharAPI.SMB_RED
local SMB_WHITE = retroCharAPI.SMB_WHITE
local SMB_PINK = retroCharAPI.SMB_PINK
local SMB_GRAY = {r = 172, g = 172, b = 172}
local SMB_TURQUOISE = {r = 1, g = 122, b = 139}
local SMB_YELLOW = {r = 229, g = 155, b = 38}
local SMB_FRYE = {r = 254, g = 107, b = 205} -- For Fire Frye, having SMB_PINK turns it into SMB_RED for whatever reason, taken from Pearl's palette.
function setup_retro_sprites()
	retroCharAPI.add_cs_character_sprites(callieCharID, get_texture_info("retro-callie-small"), get_texture_info("retro-callie-big"))
	retroCharAPI.add_cs_character_sprites(marieCharID,  get_texture_info("retro-marie-small"),  get_texture_info("retro-marie-big"))
	retroCharAPI.add_cs_character_sprites(pearlCharID,  get_texture_info("retro-pearl-small"),  get_texture_info("retro-pearl-big"))
	retroCharAPI.add_cs_character_sprites(marinaCharID, get_texture_info("retro-marina-small"), get_texture_info("retro-marina-big"))
	retroCharAPI.add_cs_character_sprites(shiverCharID, get_texture_info("retro-shiver-small"), get_texture_info("retro-shiver-big"))
	retroCharAPI.add_cs_character_sprites(fryeCharID,   get_texture_info("retro-frye-small"),   get_texture_info("retro-frye-big"))
	retroCharAPI.add_cs_character_sprites(bigmanCharID, get_texture_info("retro-bigman-small"), get_texture_info("retro-bigman-big"), 24, 24, 3, 40, 32, 3, nil, nil, "BIGMAN")
	retroCharAPI.add_cs_character_palette(callieCharID, {SKIN, HAIR, CAP},     {SKIN, SMB_RED, SMB_FRYE}, 2, 3)
	retroCharAPI.add_cs_character_palette(marieCharID,  {SKIN, GLOVES, CAP},   {SKIN, GLOVES, SMB_RED}, 1, 2)
	retroCharAPI.add_cs_character_palette(pearlCharID,  {SKIN, SHIRT, EMBLEM}, {SKIN, SHIRT, SMB_RED}, 2, 3)
	retroCharAPI.add_cs_character_palette(marinaCharID, {SKIN, HAIR, CAP},     {SKIN, HAIR, SMB_PINK}, 1, 2)
	retroCharAPI.add_cs_character_palette(shiverCharID, {SKIN, HAIR, GLOVES},  {SKIN, SMB_RED, SMB_TURQUOISE}, 1, 2)
	retroCharAPI.add_cs_character_palette(fryeCharID,   {SKIN, HAIR, GLOVES},  {SKIN, SMB_FRYE, GLOVES}, 1, 2)
	retroCharAPI.add_cs_character_palette(bigmanCharID, {EMBLEM, GLOVES, CAP}, {SMB_YELLOW, GLOVES, CAP}, 1, 2)
end
hook_event(HOOK_ON_MODS_LOADED, setup_retro_sprites)

