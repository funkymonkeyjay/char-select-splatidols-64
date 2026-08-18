-- name: [CS+PET] Spla\\#7DFF32\\t\\#DCDCDC\\Idol\\#7DFF32\\s \\#FF4CBD\\64
-- description: \\#FF8000\\Splatoon\\#dcdcdc\\'s very own beloved idols; the charming \\#FF7BD0\\Squid \\#97FF67\\Sisters\\#dcdcdc\\, the hip\n\\#FF99CF\\Off t\\#3FFF9F\\he Hook\\#dcdcdc\\, and the rowdiest of the bunch...\\#8888ff\\De\\#ffff88\\ep \\#888888\\Cut\\#dcdcdc\\, are all here to bring some color to the airwaves all around the Mushroom Kingdom~!\n\n* Play as each member of the\n\\#FF8000\\Now or Never Seven\\#dcdcdc\\!\n* Splatoon-styled \\#FF8000\\HUD elements\\#dcdcdc\\!\n* Includes \\#ffff80\\[PET] Smallfry\\#dcdcdc\\!\n* \\#FF8000\\Custom Music\\#dcdcdc\\ can be turned [ON/OFF], [ON] by default!\n\n\"Splatoon\" is owned by \\#ff7777\\Nintendo, Ltd.\\#dcdcdc\\,\nwith Voices/Music sourced from most of the series' catalog of games.\n\n\\#FF8000\\Character Select & WiddlePets are recommended to access certain features, but not required!
-- category: characters

-- ** SMALLFRY [WIDDLEPETS] **

if _G.wpets then
	local E_MODEL_SMALLFRY = smlua_model_util_get_id('smallfry_geo')

	local smallFryPetID = _G.wpets.add_pet({
		name = "Smallfry Salmonid", credit = "@funkymonkeyjay",
		description = "Rarely do young Salmonid turn up lost and hungry... Do you think it likes mushrooms?",
		modelID = E_MODEL_SMALLFRY,
		scale = 0.775, yOffset = 0, flying = false
	})

	_G.wpets.set_pet_anims(smallFryPetID, {
		idle = 'SMALLFRY_IDLE',
		follow = 'SMALLFRY_FOLLOW',
		petted = 'SMALLFRY_PET',
		dance = 'SMALLFRY_DANCE'
	})

	_G.wpets.set_pet_sounds(smallFryPetID, {
		spawn = 'SMALLFRY_SPAWN.ogg',
		happy = 'SMALLFRY_HAPPY.ogg',
		vanish = 'SMALLFRY_VANISH.ogg',
		step = SOUND_OBJ2_SCUTTLEBUG_WALK
	})
	
	-- Alternate Hairstyles!
	for i = 1, 6 do
		_G.wpets.add_pet_alt(smallFryPetID, E_MODEL_SMALLFRY) -- Done to avoid having to add similar models.
	end
	
	function splatIdolSmallfryHair_JJJ(node, matStackIndex) -- Made to optimize Smallfry's model.
		local switchCase = cast_graph_node(node)
		local o = geo_get_current_object()
		if not (switchCase or o) then return end
		local _, altID = _G.wpets.get_obj_pet_id(o)
		switchCase.selectedCase = altID
	end
end

if incompatibilityCond then return end

-- ** OTHER VARS **

local savedHealth = 0

function splatIdolMouth_JJJ(node, matStackIndex)
	local asSwitchNode = cast_graph_node(node)
	local m = geo_get_mario_state()
	asSwitchNode.selectedCase = gPlayerSyncTable[m.playerIndex].splatIdolMouthState_JJJ
end

function splatIdolEyebrow_JJJ(node, matStackIndex)
	local asSwitchNode = cast_graph_node(node)
	local m = geo_get_mario_state()
	asSwitchNode.selectedCase = gPlayerSyncTable[m.playerIndex].splatIdolEyebrowState_JJJ
end

for i = 0, (MAX_PLAYERS - 1) do
	gPlayerSyncTable[i].splatIdolTentacle_JJJ = {}
	for j = 1, 3 do
		gPlayerSyncTable[i].splatIdolTentacle_JJJ[j] = {}
		gPlayerSyncTable[i].splatIdolTentacle_JJJ[j].y = 0
		gPlayerSyncTable[i].splatIdolTentacle_JJJ[j].z = 0
	end
	gPlayerSyncTable[i].splatIdolMouthState_JJJ = 0
	gPlayerSyncTable[i].splatIdolEyebrowState_JJJ = 0
	gPlayerSyncTable[i].splatIdolGlassesState_JJJ = math.floor(random_float() * 2.99)
	gPlayerSyncTable[i].splatIdolOldAnim_JJJ = 0
end

-- Function specifically made to allow two peace hands (Only used on the left hand) for Shiver and Frye.
function splatIdolDeepCutHand_JJJ(node, matStackIndex)
    local switchCase = cast_graph_node(node)
	local m = geo_get_mario_state()
    local bodyState = geo_get_body_state()

	if bodyState.handState == MARIO_HAND_FISTS then
		switchCase.selectedCase = (m.action & ACT_FLAG_SWIMMING_OR_FLYING) ~= 0 and MARIO_HAND_OPEN or MARIO_HAND_FISTS
	else
		local selectCase
		if switchCase.parameter == 0 then
			if bodyState.handState < 5 then selectCase = bodyState.handState else selectCase = MARIO_HAND_OPEN end
		else
			if bodyState.handState < 3 then selectCase = bodyState.handState else selectCase = MARIO_HAND_FISTS end -- Accounting for peace hand.
		end
		switchCase.selectedCase = selectCase
	end
	
    return
end

function math.clamp(n, low, high) return math.min(math.max(n, low), high) end

function splatIdolTentacle_JJJ(node, matStackIndex)
	local m = geo_get_mario_state()
	local upperTentacle = cast_graph_node(node.next)
	local lowerTentacle = cast_graph_node(node.next.children.children)
	local currentNode = cast_graph_node(node)
	
	if not (m and upperTentacle and lowerTentacle and currentNode) then return end
	
	local parameter = currentNode.parameter + 1
	local tentacle = gPlayerSyncTable[m.playerIndex].splatIdolTentacle_JJJ
	local paramSwitch = parameter == 1 and -1 or 1
	local fullRotation = get_area_update_counter() * 840

	-- *** UPPER TENTACLE ***
	local headRot = {x = 0, y = 0, z = 0}
	get_mario_anim_part_rot(m, MARIO_ANIM_PART_HEAD, headRot)
	
	local trueVelY = m.pos.y ~= m.floorHeight and m.vel.y or 0
	local velX, velY, velZ = m.vel.x / 32, trueVelY / 75, m.vel.z / 32
	local forceLateral = math.sqrt((velX * velX) + (velZ  * velZ))
	local forceY = -math.clamp(velY, -1, 1)
	
	local climbCond = m.action == ACT_CLIMBING_POLE or m.action == ACT_HOLDING_POLE or m.action == ACT_GRAB_POLE_SLOW
					or m.action == ACT_GRAB_POLE_FAST or m.action == ACT_TOP_OF_POLE_TRANSITION or m.action == ACT_TOP_OF_POLE
					or m.action == ACT_EXIT_LAND_SAVE_DIALOG
	local movementForce = climbCond and 0 or radians_to_sm64(math.clamp(forceY + (forceLateral / 2), -1, 1))
	
	local headActRotate = ((m.action == ACT_READING_NPC_DIALOG or m.action == ACT_READING_AUTOMATIC_DIALOG) and m.marioBodyState.headAngle.x) or (m.action == ACT_FIRST_PERSON and m.statusForCamera.headRotation.x) or 0
	local toLerpUpper = movementForce + (parameter ~= 3 and -headRot.z or headRot.z) - headActRotate
	
	upperTentacle.rotation.z = (sins(fullRotation * 2) * 750 * paramSwitch) + toLerpUpper
	upperTentacle.rotation.y = sins(fullRotation) * 1500 * paramSwitch
	
	-- *** LOWER TENTACLE ***
	local intendedDYaw = m.intendedYaw - m.faceAngle.y
	local toLerpLateral = (m.action == ACT_LONG_JUMP and -1 or 1) * (5461.3335 * m.intendedMag / 24 * sins(intendedDYaw))
	
	local checkVel = math.abs(m.vel.x) > 10 or math.abs(m.vel.z) > 10 or math.abs(climbCond and 0 or m.vel.y) > 25
	if checkVel then
		local trueMovementForce = (m.action == ACT_BUTT_SLIDE or m.action == ACT_RIDING_SHELL_GROUND) and 0 or movementForce
		tentacle[parameter].y, tentacle[parameter].z = approach_f32(tentacle[parameter].y, toLerpLateral, 1000, 1000), approach_f32(tentacle[parameter].z, trueMovementForce, 375, 375)
	else
		tentacle[parameter].y, tentacle[parameter].z = approach_f32(tentacle[parameter].y, 0, 150, 150), approach_f32(tentacle[parameter].z, 0, 150, 150)
	end
	
	lowerTentacle.rotation.y = (-coss(fullRotation) * 2000 * paramSwitch) + ((not checkVel and sins(fullRotation * 2) or 1) * tentacle[parameter].y)
	lowerTentacle.rotation.z = ((-coss(fullRotation * 2) * 1000 * paramSwitch) + ((not checkVel and sins(fullRotation * 2) or 1) * tentacle[parameter].z)) * (parameter == 3 and -1 or 1)
end

function splatIdolTail_JJJ(node, matStackIndex) -- For Big Man
	local m = geo_get_mario_state()
	local tailBase = cast_graph_node(node.next)
	local tailMiddle = cast_graph_node(node.next.children.next.children)
	local tailEnd = cast_graph_node(node.next.children.next.children.children.next.children)
	
	if not (m and tailBase and tailMiddle and tailEnd) then return end
	
	local currAnim = m.marioObj.header.gfx.animInfo.animID
	
	local fullRotation = get_area_update_counter() * 840
	
	local buttRot = {x = 0, y = 0, z = 0}
	get_mario_anim_part_rot(m, MARIO_ANIM_PART_BUTT, buttRot)
	
	local slope = m.pos.y == m.floorHeight and find_floor_slope(m, 0) or 0
	
	-- *** TAIL BASE ***
	local intendedDYaw = m.intendedYaw - m.faceAngle.y
	local toLerpLateral = ((m.action == ACT_LONG_JUMP and 1) or ((m.action & ACT_FLAG_AIR ~= 0) and 0) or -1) * (5461.3335 * m.intendedMag / 12 * sins(intendedDYaw))
	
	local buttAngle = -buttRot.x + degrees_to_sm64(100)
	local currAnim = m.marioObj.header.gfx.animInfo.animID
	if currAnim == CHAR_ANIM_TRIPLE_JUMP or currAnim == CHAR_ANIM_BACKFLIP or currAnim == CHAR_ANIM_SIDE_FLIP or m.action == ACT_FORWARD_ROLLOUT
	or currAnim == CHAR_ANIM_TRIPLE_JUMP_FLY or currAnim == CHAR_ANIM_FORWARD_SPINNING or currAnim == CHAR_ANIM_FORWARD_SPINNING_FLIP
	or currAnim == CHAR_ANIM_START_GROUND_POUND or currAnim == CHAR_ANIM_FORWARD_SPINNING or currAnim == CHAR_ANIM_AIRBORNE_ON_STOMACH or currAnim == CHAR_ANIM_FINAL_BOWSER_WING_CAP_TAKE_OFF or currAnim == CHAR_ANIM_DIVE then
		buttAngle = 0
	end

	local forceY = -math.clamp((m.pos.y ~= m.floorHeight and m.vel.y or 0) / 75, -1, 1)
	local lerpZ = (buttAngle + (forceY * 12000) - (slope * 0.5)) - 5000
	
	local tail = gPlayerSyncTable[m.playerIndex].splatIdolTentacle_JJJ
	tailBase.rotation.x, tailBase.rotation.z = approach_f32(tail[1].y, toLerpLateral, 250, 250), approach_f32(tail[1].z, lerpZ, 1000, 1000)
	tail[1].y, tail[1].z = tailBase.rotation.x, tailBase.rotation.z
	
	-- *** OTHER TAIL BITS ***
	local middleLerpLateral = toLerpLateral ~= 0 and toLerpLateral or coss(fullRotation) * 5000
	tailMiddle.rotation.x, tailMiddle.rotation.z = approach_f32(tail[2].y, middleLerpLateral, 500, 500), 2500 + (forceY * 3750)
	tail[2].y = tailMiddle.rotation.x
	
	local endlerpLateral = middleLerpLateral ~= 0 and middleLerpLateral or -coss(fullRotation * 1.25) * 10000
	tailEnd.rotation.x, tailEnd.rotation.z = approach_f32(tail[3].y, endlerpLateral, 750, 750), 1250 + (forceY * 1875)
	tail[3].y = tailEnd.rotation.x
end

function splatIdolSwim_JJJ(node, matStackIndex)
	local switchCase = cast_graph_node(node)
	local m = geo_get_mario_state()
	
	if not (switchCase or m) then return end
	
	local currAnim = m.marioObj.header.gfx.animInfo.animID
	local currFrame = m.marioObj.header.gfx.animInfo.animFrame
	if currAnim == CHAR_ANIM_CROUCHING or currAnim == CHAR_ANIM_CRAWLING or currAnim == CHAR_ANIM_STOP_CRAWLING or currAnim == CHAR_ANIM_START_CRAWLING or (currAnim == CHAR_ANIM_START_CROUCHING and is_anim_at_end(m) == 1)
	or (currAnim == CHAR_ANIM_SHIVERING_WARMING_HAND and is_anim_at_end(m) == 1) or (currAnim == CHAR_ANIM_SHIVERING and m.action == ACT_SHIVERING)
	or (currAnim == CHAR_ANIM_WATER_IDLE or currAnim == CHAR_ANIM_SWIM_PART1 or currAnim == CHAR_ANIM_SWIM_PART2 or currAnim == CHAR_ANIM_FLUTTERKICK
	or currAnim == CHAR_ANIM_WATER_ACTION_END or currAnim == CHAR_ANIM_WATER_STAR_DANCE or currAnim == CHAR_ANIM_RETURN_FROM_WATER_STAR_DANCE) or currAnim == CHAR_ANIM_DIVE then
		switchCase.selectedCase = 1
		return
	else
		switchCase.selectedCase = 0
	end
end

function splatIdolGlasses_JJJ(node, matStackIndex) -- For Hypno-Callie.
	local switchCase = cast_graph_node(node)
	local m = geo_get_mario_state()
	
	local glassState = gPlayerSyncTable[m.playerIndex].splatIdolGlassesState_JJJ
	
	if not (switchCase or m) then return end
	
	local gAreaUpdateCounter = math.floor(get_area_update_counter() / 2.5)
	local currIndex = (gAreaUpdateCounter % 9) + (glassState * 9)
	--blinkFrame = ((switchCase->numCases * 32 + gAreaUpdateCounter) >> 1) & 0x1F;
	switchCase.selectedCase = currIndex
end

-- ** INITIALIZATION **

local function run_func_or_get_var(x, ...) if type(x) == "function" then return x(...) else return x end end

if _G.charSelectExists then
	local SPLATIDOLS_TOKID_SOUND =       audio_sample_load("TOKID.ogg")
	local SPLATIDOLS_TOSQUID_SOUND =     audio_sample_load("TOSQUID.ogg")
	local SPLATIDOLS_SUPERJUMP_SOUND =   audio_sample_load("SUPERJUMP.ogg")
	local SPLATIDOLS_DIVE_SOUND =        {audio_sample_load("DIVE1.ogg"), audio_sample_load("DIVE2.ogg")}
	local SPLATIDOLS_HOP_SOUND =         audio_sample_load("HOP.ogg")
	local SPLATIDOLS_LAND_SOUND =        audio_sample_load("LAND.ogg")
	local SPLATIDOLS_STEP_SOUND =        {audio_sample_load("STEP1.ogg"), audio_sample_load("STEP2.ogg"), audio_sample_load("STEP3.ogg"), audio_sample_load("STEP4.ogg"), audio_sample_load("STEP5.ogg"), audio_sample_load("STEP6.ogg"), audio_sample_load("STEP7.ogg"), audio_sample_load("STEP8.ogg")}
	local SPLATIDOLS_STEP_BIGMAN_SOUND = {audio_sample_load("STEP_BIGMAN_1.ogg"), audio_sample_load("STEP_BIGMAN_2.ogg")}
	
	function play_splatidols_sound(snd, pos, vol)
		if is_game_paused() or _G.charSelect.is_menu_open() then return end
		return audio_sample_play(snd, pos, vol or 1)
	end

	local SCALE_SPEED = 0.03125
	local function bhv_ink_loop(o)
		cur_obj_update_floor_height()
		if o.oTimer == 0 then
			o.oAngleVelPitch = (random_float() - 0.5) * 0x1000
			o.oAngleVelRoll = (random_float() - 0.5) * 0x1000
			o.oTreeSnowOrLeafUnkF8 = 4
			o.oTreeSnowOrLeafUnkFC = random_float() * 0x400 + 0x600
		end
		
		o.header.gfx.scale.x = approach_f32(o.header.gfx.scale.x, 0, SCALE_SPEED, SCALE_SPEED)
		o.header.gfx.scale.y = approach_f32(o.header.gfx.scale.y, 0, SCALE_SPEED, SCALE_SPEED)
		o.header.gfx.scale.z = approach_f32(o.header.gfx.scale.z, 0, SCALE_SPEED, SCALE_SPEED)
		
		if (o.header.gfx.scale.x <= 0 and o.header.gfx.scale.y <= 0 and o.header.gfx.scale.z <= 0) then
			obj_mark_for_deletion(o)
		end
		
		o.oVelY = o.oVelY - 3
		if o.oVelY < -16 then
			o.oVelY = -16
		end
		
		if o.oForwardVel > 0 then
			o.oForwardVel = o.oForwardVel - 0.3
		else
			o.oForwardVel = 0
		end

		o.oTreeSnowOrLeafUnkF4 = o.oTreeSnowOrLeafUnkF4 + o.oTreeSnowOrLeafUnkFC
		o.oVelX = o.oForwardVel * sins(o.oMoveAngleYaw)
		o.oVelZ = o.oForwardVel * coss(o.oMoveAngleYaw)

		o.oPosX = o.oPosX + o.oVelX
		o.oPosY = o.oPosY + o.oVelY
		o.oPosZ = o.oPosZ + o.oVelZ
		
		obj_update_gfx_pos_and_angle(o)
	end
	id_bhvSplatIdolsInk_JJJ = hook_behavior(nil, OBJ_LIST_UNIMPORTANT, true, function (o) end, bhv_ink_loop, "bhvSplatIdolsInk_JJJ")
	
	E_MODEL_INK_CAP = smlua_model_util_get_id("ink_cap_geo")
	E_MODEL_INK_HAIR = smlua_model_util_get_id("ink_hair_geo")
	E_MODEL_INK_EMBLEM = smlua_model_util_get_id("ink_emblem_geo")

	local function spawnInkParticles(m, inkType, partScale, velY)
		if m.playerIndex ~= 0 then return end
		local scale = partScale or 0
		local ink = (inkType == 1 and E_MODEL_INK_CAP) or (inkType == 2 and E_MODEL_INK_EMBLEM) or E_MODEL_INK_HAIR
		for i = 1, 2 + scale do
			spawn_sync_object(id_bhvSplatIdolsInk_JJJ, ink, m.pos.x, m.pos.y + 50, m.pos.z, function(o)
				o.globalPlayerIndex = m.marioObj.globalPlayerIndex -- Allows for color!
				obj_scale(o, 0.5 + (scale * 0.125))
				o.oMoveAngleYaw = random_u16()
				o.oForwardVel = (random_float() * 10) + 5
				if velY then
					o.oVelY = (velY/math.abs(velY)) * (math.abs(velY) + random_float() * 20)
				else
					o.oVelY = (random_float() * 20 * (partScale or 1)) + 10
				end
				
				obj_set_billboard(o)
			end)
		end
	end

	hook_event(HOOK_BEFORE_SET_MARIO_ACTION, function (m, incomingAction, actionArg)
		local idx = m.playerIndex
		local modelId = _G.charSelect.character_get_current_number(idx)
		local currAnim = m.marioObj.header.gfx.animInfo.animID
		
		if (modelId == callieCharID or modelId == marieCharID or modelId == pearlCharID or modelId == marinaCharID or modelId == shiverCharID or modelId == fryeCharID or modelId == bigmanCharID) then
			
			-- For Hypno-Callie, meant to randomize the glasses animation
			if not _G.charSelect.is_menu_open() then gPlayerSyncTable[m.playerIndex].splatIdolGlassesState_JJJ = math.floor(random_float() * 2.99) end
			
			-- Sunshine Dive!
			local restrictedMoves = _G.charSelect.are_movesets_restricted() or _G.charSelect.get_options_status(6) == 0
			if not restrictedMoves and incomingAction == ACT_FORWARD_ROLLOUT and m.action == ACT_DIVE_SLIDE and (m.input & INPUT_A_PRESSED) == 0 and find_floor_slope(m, 0) < 5000 then
				local forwardVel = m.forwardVel + 15
				if forwardVel > 48 then
					forwardVel = 48
				end
				m.forwardVel = forwardVel
				m.vel.y = 22.5
				m.marioObj.header.gfx.animInfo.animID = modelId == bigmanCharID and 15 or 0
				local inkType = (modelId == callieCharID or modelId == marieCharID or modelId == marinaCharID or modelId == bigmanCharID) and 1 or (modelId == pearlCharID and 2) or 0
				local sound = random_float() > 0.5 and 1 or 2
				play_splatidols_sound(SPLATIDOLS_DIVE_SOUND[sound], m.pos, 1.375)
				spawnInkParticles(m, inkType, 2, 13)
				set_mario_action(m, ACT_DIVE, 1)
				return 1
			end
			
			if modelId == bigmanCharID then
				if incomingAction == ACT_START_CROUCHING then
					play_splatidols_sound(SPLATIDOLS_STEP_BIGMAN_SOUND[1], m.pos, 2.5)
				elseif incomingAction == ACT_STOP_CROUCHING then
					play_splatidols_sound(SPLATIDOLS_STEP_BIGMAN_SOUND[2], m.pos, 3)
				end
			end
			
			-- New Yawning Action!
			if incomingAction == ACT_START_SLEEPING then return ACT_YAWN_SPLATIDOLS_JJJ end
		end
	end)
	
	local stepCounts = {}
	for i = 0, MAX_PLAYERS - 1 do stepCounts[i] = 1 end
	
	hook_event(HOOK_ON_PLAY_SOUND, function (soundBits, pos)
		for i = 0, MAX_PLAYERS - 1 do
			local m = gMarioStates[i]
			local modelId = _G.charSelect.character_get_current_number(m.playerIndex)
			local charCond = modelId == callieCharID or modelId == marieCharID or modelId == pearlCharID or modelId == marinaCharID or modelId == shiverCharID or modelId == fryeCharID or modelId == bigmanCharID
			local checkPos = pos.x == m.marioObj.header.gfx.cameraToObject.x and pos.y == m.marioObj.header.gfx.cameraToObject.y and pos.z == m.marioObj.header.gfx.cameraToObject.z -- Shoutouts to "EmilyEmmi" for giving me advice on how to accomplish step sounds!

			if charCond and checkPos then
				local allowedSoundBits = {
					SOUND_TERRAIN_DEFAULT << 16, 
					SOUND_TERRAIN_STONE << 16, 
					SOUND_TERRAIN_ICE << 16
				}
				local allowed = false
				for i = 1, #allowedSoundBits do
					if m.terrainSoundAddend == allowedSoundBits[i] then allowed = true end
				end
				if not allowed then return end
				if m.action == ACT_CRAWLING and modelId ~= bigmanCharID then return NO_SOUND end
				if soundBits == SOUND_ACTION_TERRAIN_JUMP or soundBits == SOUND_ACTION_TERRAIN_JUMP + m.terrainSoundAddend then
					play_splatidols_sound(SPLATIDOLS_HOP_SOUND, m.pos, 1.5)
					return NO_SOUND
				elseif soundBits == SOUND_ACTION_TERRAIN_LANDING or soundBits == SOUND_ACTION_TERRAIN_LANDING + m.terrainSoundAddend or soundBits == SOUND_ACTION_TERRAIN_BODY_HIT_GROUND or soundBits == SOUND_ACTION_TERRAIN_BODY_HIT_GROUND + m.terrainSoundAddend then
					if modelId == bigmanCharID then
						play_splatidols_sound(SPLATIDOLS_STEP_BIGMAN_SOUND[1], m.pos, 2.25)
					else
						play_splatidols_sound(SPLATIDOLS_LAND_SOUND, m.pos, 1.25)
					end
					return NO_SOUND
				elseif soundBits == SOUND_ACTION_TERRAIN_STEP or soundBits == SOUND_ACTION_TERRAIN_STEP + m.terrainSoundAddend or soundBits == SOUND_ACTION_TERRAIN_STEP_TIPTOE or soundBits == SOUND_ACTION_TERRAIN_STEP_TIPTOE + m.terrainSoundAddend then
					if modelId == bigmanCharID then
						play_splatidols_sound(SPLATIDOLS_STEP_BIGMAN_SOUND[stepCounts[i]], m.pos, 1.5)
						stepCounts[i] = stepCounts[i] + 1
						if stepCounts[i] > 2 then stepCounts[i] = 1 end
					else
						local randSound = math.floor(random_float() * 8) + 1
						play_splatidols_sound(SPLATIDOLS_STEP_SOUND[randSound], m.pos, modelId == fryeCharID and 0.225 or 0.45)
					end
					return NO_SOUND
				end
			end
		end
	end)

	hook_event(HOOK_BEFORE_MARIO_UPDATE, function (m) -- Uses one animation for idle, original code by "Baconator2558", edited to fit modifications.
		local idx = m.playerIndex
		local modelId = _G.charSelect.character_get_current_number(idx)
		gPlayerSyncTable[idx].splatIdolOldAnim_JJJ = m.marioObj.header.gfx.animInfo.animID
		if (modelId == callieCharID or modelId == marieCharID or modelId == pearlCharID or modelId == marinaCharID or modelId == shiverCharID or modelId == fryeCharID or modelId == bigmanCharID) then
			local restrictedMoves = _G.charSelect.are_movesets_restricted() or _G.charSelect.get_options_status(6) == 0
			if not restrictedMoves and (m.action == ACT_PUNCHING or m.action == ACT_MOVE_PUNCHING) then
				if m.actionArg == 6 then
					m.actionArg = 0
				end
			end
			if (m.action == ACT_IDLE or m.action == ACT_METAL_WATER_STANDING) then
				if charSelect.is_menu_open() then
					m.actionTimer = 0
				elseif m.marioObj.header.gfx.animInfo.animFrame >= 10 then
					m.actionTimer = m.actionTimer + 1
				end
				local animLimit = (modelId == callieCharID and 870 or 900) -- 29 * 3 * 10, 30 * 3 * 10, made specifically for Callie's animations, which use only 29 frames, much to my own dismay.
				if m.actionTimer > animLimit and m.action ~= ACT_METAL_WATER_STANDING then
					m.actionState = 3
				else
					m.actionState = 0
				end
			end
		end
	end)

	local hasZoomed = false
	hook_event(HOOK_MARIO_UPDATE, function (m)
		local idx = m.playerIndex
		local modelId = _G.charSelect.character_get_current_number(idx)
		local currAnim = m.marioObj.header.gfx.animInfo.animID
		local oldAnim = gPlayerSyncTable[idx].splatIdolOldAnim_JJJ
		
		if not (modelId == callieCharID or modelId == marieCharID or modelId == pearlCharID or modelId == marinaCharID or modelId == shiverCharID or modelId == fryeCharID or modelId == bigmanCharID) then return end
		
		-- In order to prevent the wrong animation being played during petting, we're going to assume the petting action is played, if so, then replace it with our own.
		local widdlePetsCheck = _G.wpets and currAnim == MARIO_ANIM_SHIVERING and m.action ~= ACT_SHIVERING and modelId ~= bigmanCharID and not _G.charSelect.is_menu_open()
		if widdlePetsCheck then
			set_mario_action(m, ACT_PET_SPLATIDOLS_JJJ, 0)
		end
		
		-- Force the "Right Hand Open" state during credits pose, much easier than having to assign the animation through the override table.
		if currAnim == CHAR_ANIM_CREDITS_PEACE_SIGN and m.marioBodyState.handState == MARIO_HAND_PEACE_SIGN then
			m.marioBodyState.handState = MARIO_HAND_RIGHT_OPEN
		end
		
		-- Force the open hands during peace sign.
		if (modelId == callieCharID or modelId == marieCharID or modelId == pearlCharID or modelId == marinaCharID) and m.marioBodyState.handState == MARIO_HAND_PEACE_SIGN then
			m.marioBodyState.handState = MARIO_HAND_OPEN
		end
		
		-- Add ink particles to special triple jump.
		local inkType = (modelId == callieCharID or modelId == marieCharID or modelId == marinaCharID or modelId == bigmanCharID) and 1 or (modelId == pearlCharID and 2) or 0
		if idx == 0 then
			if m.action == ACT_SPECIAL_TRIPLE_JUMP and m.actionState == 0 then
				m.actionTimer = m.actionTimer + 1
				if m.actionTimer % 4 == 0 then
					spawnInkParticles(m, inkType, 5, -m.vel.y)
				end
			end
		end
		
		-- I REALLY don't want to animate the key to align with the characters.
		local nearestCourseExitKey = obj_get_nearest_object_with_behavior_id(o, id_bhvBowserKeyCourseExit)
		if nearestCourseExitKey and (nearestCourseExitKey.oPosX == m.pos.x and nearestCourseExitKey.oPosY == m.pos.y and nearestCourseExitKey.oPosZ == m.pos.z) and currAnim == CHAR_ANIM_THROW_CATCH_KEY then
			m.actionState = (m.flags & MARIO_CAP_ON_HEAD) == 0 and 2 or 3
			obj_mark_for_deletion(nearestCourseExitKey)
		end
		
		-- Big Man looks really weird whenever he's looking up at an NPC like Bowser or Mama Penguin.
		if modelId == bigmanCharID then
			local HEAD_LIMIT = -4096
			if m.marioBodyState.headAngle.x < HEAD_LIMIT then
				m.marioBodyState.headAngle.x = HEAD_LIMIT
			end
		end
		
		-- Debug code, makes Final Bowser easy to beat. 
		-- local nearestBowser = obj_get_nearest_object_with_behavior_id(o, id_bhvBowser)
		-- if nearestBowser then
			-- nearestBowser.oHealth = 1
		-- end
		
		-- Making sure the Y-offset for the characters don't make them sink into the ground during Jumbo Star animation, don't use Corrective Scale, kids, that industry's a SCAM!
		if m.action == ACT_JUMBO_STAR_CUTSCENE and m.actionArg == 1 then
			local posValues = {
				[callieCharID] = 12,
				[marieCharID] = 7, 
				[pearlCharID] = 5, 
				[marinaCharID] = 24, 
				[shiverCharID] = 7, 
				[fryeCharID] = 10, 
				[bigmanCharID] = -3, 
			}
			m.marioObj.header.gfx.pos.y = m.pos.y + posValues[modelId]
		end
		
		-- A failsafe for when you're in the Swim state, for some reason the closed eyes anim plays over when swimming.
		local canFallEmote = true
		local newCheck = currAnim == CHAR_ANIM_CROUCHING or currAnim == CHAR_ANIM_CRAWLING or currAnim == CHAR_ANIM_STOP_CRAWLING or currAnim == CHAR_ANIM_START_CRAWLING or currAnim == CHAR_ANIM_START_CROUCHING or currAnim == CHAR_ANIM_SHIVERING_WARMING_HAND or (currAnim == CHAR_ANIM_SHIVERING and m.action == ACT_SHIVERING)
						 or currAnim == CHAR_ANIM_WATER_IDLE or currAnim == CHAR_ANIM_SWIM_PART1 or currAnim == CHAR_ANIM_SWIM_PART2 or currAnim == CHAR_ANIM_FLUTTERKICK or currAnim == CHAR_ANIM_WATER_ACTION_END or currAnim == CHAR_ANIM_WATER_STAR_DANCE or currAnim == CHAR_ANIM_RETURN_FROM_WATER_STAR_DANCE or currAnim == CHAR_ANIM_DIVE
		if modelId ~= bigmanCharID and newCheck and not currAnim == CHAR_ANIM_START_CROUCHING then
			m.marioBodyState.eyeState = (currAnim == CHAR_ANIM_SHIVERING and m.action == ACT_SHIVERING) and MARIO_EYES_CLOSED or MARIO_EYES_BLINK
			canFallEmote = false
		end
		
		if canFallEmote and not gPlayerSyncTable[m.playerIndex].trailerFaceEdit then -- "trailerFaceEdit" was meant for the mod's trailer, it doesn't serve much purpose outside it.
			-- Long fall faces, inspired by those obnoxious SM64 CoopDX character showcase videos with AI slop thumbnails.
			if (m.vel.y < 0 and (m.pos.y ~= m.floorHeight and (m.action & ACT_FLAG_INVULNERABLE) == 0 and (m.action & ACT_FLAG_SWIMMING) == 0 and m.action ~= ACT_TWIRLING and m.action ~= ACT_FLYING) and (m.peakHeight - m.pos.y) > 1150) or m.action == ACT_BUBBLED then
				m.marioBodyState.eyeState = m.action == ACT_BUBBLED and (modelID == bigmanCharID and 11 or MARIO_EYES_HALF_CLOSED) or 9
				gPlayerSyncTable[idx].splatIdolMouthState_JJJ = 4
				gPlayerSyncTable[idx].splatIdolEyebrowState_JJJ = 1
				return
			end
			
			-- Based on original "Character Select" code by Squishy, made to provide compatibility with mouth and eyebrow states.
			local characterAnims
			local animIndexes = {
				[callieCharID] = splatIdolAnims_JJJ[1], 
				[marieCharID] =  splatIdolAnims_JJJ[2], 
				[pearlCharID] =  splatIdolAnims_JJJ[3], 
				[marinaCharID] = splatIdolAnims_JJJ[4], 
				[shiverCharID] = splatIdolAnims_JJJ[5], 
				[fryeCharID] =   splatIdolAnims_JJJ[6], 
				[bigmanCharID] = splatIdolAnims_JJJ[7], 
			}
			characterAnims = animIndexes[modelId]
			
			local animInfo = m.marioObj.header.gfx.animInfo
			
			gPlayerSyncTable[idx].splatIdolMouthState_JJJ = 0
			local mouthState = characterAnims.mouth and run_func_or_get_var(characterAnims.mouth[animInfo.animID], m, animInfo.animFrame)
			if mouthState then
				gPlayerSyncTable[idx].splatIdolMouthState_JJJ = mouthState
			end
			gPlayerSyncTable[idx].splatIdolEyebrowState_JJJ = 0
			local eyebrowState = characterAnims.eyebrows and run_func_or_get_var(characterAnims.eyebrows[animInfo.animID], m, animInfo.animFrame)
			if eyebrowState then
				gPlayerSyncTable[idx].splatIdolEyebrowState_JJJ = eyebrowState
			end
		end
		
		-- Keep the swim form from going into slopes visually.
		if (m.action == ACT_CROUCHING or m.action == ACT_START_CRAWLING or m.action == ACT_CRAWLING or m.action == ACT_STOP_CRAWLING) or (modelId == bigmanCharID and m.action == ACT_SLIDE_KICK_SLIDE) then
			align_with_floor(m)
		end
		
		-- Avoids having the transition anim play after the first person anim.
		if ((oldAnim == CHAR_ANIM_FIRST_PERSON or oldAnim == CHAR_ANIM_RETURN_FROM_STAR_DANCE) and (currAnim == CHAR_ANIM_IDLE_HEAD_LEFT or currAnim == CHAR_ANIM_IDLE_HEAD_CENTER or currAnim == CHAR_ANIM_IDLE_HEAD_RIGHT))
		or ((m.action ~= ACT_INTRO_CUTSCENE and not (m.action == ACT_READING_NPC_DIALOG and oldAnim == CHAR_ANIM_GENERAL_LAND)) and (oldAnim ~= CHAR_ANIM_FIRST_PERSON and currAnim == CHAR_ANIM_FIRST_PERSON)) then -- Specifically for the intro cutscene.
			set_anim_to_frame(m, 10)
		end
		
		if m.action == ACT_SHIVERING and currAnim == CHAR_ANIM_SHIVERING and oldAnim ~= CHAR_ANIM_SHIVERING then
			set_anim_to_frame(m, 1)
		end
		
		local oldCheck = oldAnim == CHAR_ANIM_CROUCHING or oldAnim == CHAR_ANIM_CRAWLING or oldAnim == CHAR_ANIM_STOP_CRAWLING or oldAnim == CHAR_ANIM_START_CRAWLING or oldAnim == CHAR_ANIM_START_CROUCHING or oldAnim == CHAR_ANIM_SHIVERING_WARMING_HAND or (oldAnim == CHAR_ANIM_SHIVERING and m.action == ACT_SHIVERING)
						 or oldAnim == CHAR_ANIM_WATER_IDLE or oldAnim == CHAR_ANIM_SWIM_PART1 or oldAnim == CHAR_ANIM_SWIM_PART2 or oldAnim == CHAR_ANIM_FLUTTERKICK or oldAnim == CHAR_ANIM_WATER_ACTION_END or oldAnim == CHAR_ANIM_WATER_STAR_DANCE or oldAnim == CHAR_ANIM_RETURN_FROM_WATER_STAR_DANCE or oldAnim == CHAR_ANIM_DIVE

		if modelId ~= bigmanCharID then
			-- Swim form sounds/effects.
			if oldCheck and not newCheck then
				spawnInkParticles(m, inkType)
				if currAnim == CHAR_ANIM_BACKFLIP then
					spawnInkParticles(m, inkType, 2)
					m.particleFlags = m.particleFlags | PARTICLE_BREATH
					play_splatidols_sound(SPLATIDOLS_SUPERJUMP_SOUND, m.pos, 1)
				else
					play_splatidols_sound(SPLATIDOLS_TOKID_SOUND, m.pos, 0.625)
				end
			elseif newCheck and not oldCheck then
				spawnInkParticles(m, inkType)
				play_splatidols_sound(SPLATIDOLS_TOSQUID_SOUND, m.pos, 0.5)
			end
		end

		if idx == 0 then
			-- Replicating the original FOV zoom for sleeping actions.
			local fov = get_current_fov()
			if m.action == ACT_YAWN_SPLATIDOLS_JJJ then
				hasZoomed = true
				set_override_fov(fov - ((fov - 30) / 30))
			elseif hasZoomed then
				local fovDist = fov - ((fov - 45) / 30)
				set_override_fov(fovDist)
				if fovDist >= 44.93 then
					set_override_fov(0)
					hasZoomed = false
				end
			end
			
			if modelId == bigmanCharID then
				-- I don't think it'd make sense for a sea creature to run out of air... in water!
				if (m.action & ACT_FLAG_SWIMMING) ~= 0 and m.health <= savedHealth and not (currAnim == MARIO_ANIM_WATER_FORWARD_KB or currAnim == MARIO_ANIM_BACKWARDS_WATER_KB) then
					m.health = savedHealth
				else
					savedHealth = m.health
				end
			end
			oldAnim = 0
		end
    end)
	
	-- Preventing any probably cases of weird tentacle/tail stuff when switching chracters.
	_G.charSelect.hook_on_character_change(function (currChar, prevChar)
		local m = gMarioStates[0]
		for i = 1, 3 do
			gPlayerSyncTable[m.playerIndex].splatIdolTentacle_JJJ[i].y = 0
			gPlayerSyncTable[m.playerIndex].splatIdolTentacle_JJJ[i].z = 0
		end
	end)

	-- ** LOADING CHARACTERS **
	
	local CATEGORY_NAME = "Splatoon"
	local RETRO_NAME = "So Retro!"
	local CREATOR = "@funkymonkeyjay"
	
	-- Callie
	local TEX_CALLIE = get_texture_info("callie-icon")
	local TEX_GRAFFITI_CALLIE = get_texture_info("graffiti-callie")
	local E_MODEL_CALLIE = smlua_model_util_get_id("callie_geo")
	local CALLIE_PALETTE = {[PANTS] = "FF00A0", [SHIRT] = "8989FF", [GLOVES] = "FFFFFF", [SHOES] = "000000", [HAIR] = "210021", [SKIN] = "FFB88A", [EMBLEM] = "FF00A0", [CAP] = "FF00A0"}
	local CAPTABLE_CALLIE = {
		normal = smlua_model_util_get_id("callie_cap_geo"),
		wing = smlua_model_util_get_id("callie_cap_wing_geo"),
		metal = smlua_model_util_get_id("callie_cap_metal_geo"),
		metalWing = smlua_model_util_get_id("callie_cap_metal_wing_geo"),
	}
	local CALLIE_DESC = "\"Hey there! I'm Callie from the Squid Sisters!...It's another great day, so let's give it our best! Yeah!\" - Voice clips originally preformed by \"keity.pop\" - Character by Nintendo."
	callieCharID = _G.charSelect.character_add("Callie", CALLIE_DESC, "@funkymonkeyjay", "FF00A0", E_MODEL_CALLIE, CT_MARIO, TEX_CALLIE, 1.075)
	_G.charSelect.character_add_voice(E_MODEL_CALLIE, splatIdolAnims_JJJ[1].voice)
	_G.charSelect.character_add_caps(E_MODEL_CALLIE, CAPTABLE_CALLIE)
	_G.charSelect.character_add_palette_preset(E_MODEL_CALLIE, CALLIE_PALETTE)
	_G.charSelect.character_add_animations(E_MODEL_CALLIE, splatIdolAnims_JJJ[1].anims, splatIdolAnims_JJJ[1].eyeState, splatIdolAnims_JJJ[1].hands)
	_G.charSelect.character_set_category(callieCharID, CATEGORY_NAME, true)
	
	if not retroCharAPI then -- Kinda redundant to have costumes when the sprites don't even change except for their colors, don't you think?
		-- Callie (Costume - Casual)
		local E_MODEL_CALLIE_CASUAL = smlua_model_util_get_id("callie_casual_geo")
		local CALLIE_CASUAL_PALETTE = {[PANTS] = "000000", [SHIRT] = "ffffff", [GLOVES] = "FF3F6C", [SHOES] = "721C0E", [HAIR] = "210021", [SKIN] = "FFB88A", [EMBLEM] = "FFCF00", [CAP] = "FF00A0"}
		callieCasualCostumeID = _G.charSelect.character_add_costume(callieCharID, "Callie (Agent 1)", CALLIE_DESC, CREATOR, "FF00A0", E_MODEL_CALLIE_CASUAL, CT_MARIO, TEX_CALLIE, 1.075)
		_G.charSelect.character_add_voice(E_MODEL_CALLIE_CASUAL, splatIdolAnims_JJJ[1].voice)
		_G.charSelect.character_add_palette_preset(E_MODEL_CALLIE_CASUAL, CALLIE_CASUAL_PALETTE)
		_G.charSelect.character_add_animations(E_MODEL_CALLIE_CASUAL, splatIdolAnims_JJJ[1].anims, splatIdolAnims_JJJ[1].eyeState, splatIdolAnims_JJJ[1].hands)
		_G.charSelect.character_add_caps(E_MODEL_CALLIE_CASUAL, CAPTABLE_CALLIE)
		
		-- Callie (Costume - Hypno)
		local E_MODEL_CALLIE_HYPNO = smlua_model_util_get_id("callie_hypno_geo")
		local CALLIE_HYPNO_PALETTE = {[PANTS] = "FF00A0", [SHIRT] = "18121D", [GLOVES] = "18121D", [SHOES] = "18121D", [HAIR] = "210021", [SKIN] = "FFB88A", [EMBLEM] = "FF00A0", [CAP] = "FF00A0"}
		callieHypnoCostumeID = _G.charSelect.character_add_costume(callieCharID, "Callie (Hypno)", CALLIE_DESC, CREATOR, "FF00A0", E_MODEL_CALLIE_HYPNO, CT_MARIO, TEX_CALLIE, 1.075)
		_G.charSelect.character_add_voice(E_MODEL_CALLIE_HYPNO, splatIdolAnims_JJJ[1].voice)
		_G.charSelect.character_add_palette_preset(E_MODEL_CALLIE_HYPNO, CALLIE_HYPNO_PALETTE)
		_G.charSelect.character_add_animations(E_MODEL_CALLIE_HYPNO, splatIdolAnims_JJJ[1].anims, splatIdolAnims_JJJ[1].eyeState, splatIdolAnims_JJJ[1].hands)
		_G.charSelect.character_add_caps(E_MODEL_CALLIE_HYPNO, CAPTABLE_CALLIE)
	end
	
	local CALLIE_RETRO_PALETTE = {[PANTS] = "B4217B", [SHIRT] = "B4217B", [GLOVES] = "B4217B", [SHOES] = "000000", [HAIR] = "000000", [SKIN] = "FFCDC4", [EMBLEM] = "B4217B", [CAP] = "B4217B"}
	_G.charSelect.character_add_palette_preset(E_MODEL_CALLIE, CALLIE_RETRO_PALETTE, RETRO_NAME)
	
	_G.charSelect.character_add_menu_instrumental(callieCharID, audio_stream_load("abc_menu_callie.ogg"))
	_G.charSelect.character_add_graffiti(callieCharID, TEX_GRAFFITI_CALLIE)
	
	-- Marie
	local TEX_MARIE = get_texture_info("marie-icon")
	local TEX_GRAFFITI_MARIE = get_texture_info("graffiti-marie")
	local E_MODEL_MARIE = smlua_model_util_get_id("marie_geo")
	local MARIE_PALETTE = {[PANTS] = "50FF00", [SHIRT] = "8989FF", [GLOVES] = "FFFFFF", [SHOES] = "000000", [HAIR] = "929992", [SKIN] = "FFBD8A", [EMBLEM] = "50FF00", [CAP] = "50FF00"}
	local CAPTABLE_MARIE = {
		normal = smlua_model_util_get_id("marie_cap_geo"),
		wing = smlua_model_util_get_id("marie_cap_wing_geo"),
		metal = smlua_model_util_get_id("marie_cap_metal_geo"),
		metalWing = smlua_model_util_get_id("marie_cap_metal_wing_geo"),
	}
	local MARIE_DESC = "\"Hey. I'm Marie of the Squid Sisters. I know you're probably a bit starstruck, but I need you to get over it.\" - Voice clips originally preformed by \"Mari Kikuma\" - Character by Nintendo."
	marieCharID = _G.charSelect.character_add("Marie", MARIE_DESC, CREATOR, "50FF00", E_MODEL_MARIE, CT_MARIO, TEX_MARIE, 1.115)
	_G.charSelect.character_add_voice(E_MODEL_MARIE, splatIdolAnims_JJJ[2].voice)
	_G.charSelect.character_add_caps(E_MODEL_MARIE, CAPTABLE_MARIE)
	_G.charSelect.character_add_palette_preset(E_MODEL_MARIE, MARIE_PALETTE)
	_G.charSelect.character_add_animations(E_MODEL_MARIE, splatIdolAnims_JJJ[2].anims, splatIdolAnims_JJJ[2].eyeState, splatIdolAnims_JJJ[2].hands)
	_G.charSelect.character_set_category(marieCharID, CATEGORY_NAME, true)
	
	if not retroCharAPI then
		-- Marie (Costume - Casual)
		local E_MODEL_MARIE_CASUAL = smlua_model_util_get_id("marie_casual_geo")
		local MARIE_CASUAL_PALETTE = {[PANTS] = "50FF00", [SHIRT] = "000000", [GLOVES] = "196400", [SHOES] = "000000", [HAIR] = "929992", [SKIN] = "FFBD8A", [EMBLEM] = "FFFFFF", [CAP] = "50FF00"}
		marieCasualCostumeID = _G.charSelect.character_add_costume(marieCharID, "Marie (Agent 2)", MARIE_DESC, CREATOR, "50FF00", E_MODEL_MARIE_CASUAL, CT_MARIO, TEX_MARIE, 1.075)
		_G.charSelect.character_add_voice(E_MODEL_MARIE_CASUAL, splatIdolAnims_JJJ[2].voice)
		_G.charSelect.character_add_palette_preset(E_MODEL_MARIE_CASUAL, MARIE_CASUAL_PALETTE)
		_G.charSelect.character_add_animations(E_MODEL_MARIE_CASUAL, splatIdolAnims_JJJ[2].anims, splatIdolAnims_JJJ[2].eyeState, splatIdolAnims_JJJ[2].hands)
		_G.charSelect.character_add_caps(E_MODEL_MARIE_CASUAL, CAPTABLE_MARIE)
	end
	
	local MARIE_RETRO_PALETTE = {[PANTS] = "0A930C", [SHIRT] = "0A930C", [GLOVES] = "FFFFFF", [SHOES] = "000000", [HAIR] = "FFFFFF", [SKIN] = "E59B26", [EMBLEM] = "0A930C", [CAP] = "0A930C"}
	_G.charSelect.character_add_palette_preset(E_MODEL_MARIE, MARIE_RETRO_PALETTE, RETRO_NAME)
	
	_G.charSelect.character_add_menu_instrumental(marieCharID, audio_stream_load("abc_menu_marie.ogg"))
	_G.charSelect.character_add_graffiti(marieCharID, TEX_GRAFFITI_MARIE)
	
	-- Pearl
	local TEX_PEARL = get_texture_info("pearl-icon")
	local TEX_GRAFFITI_PEARL = get_texture_info("graffiti-pearl")
	local E_MODEL_PEARL = smlua_model_util_get_id("pearl_geo")
	local PEARL_PALETTE = {[PANTS] = "FE6BCD", [SHIRT] = "FFFFFF", [GLOVES] = "000000", [SHOES] = "FFFFFF", [HAIR] = "E5BF7E", [SKIN] = "FFC89B", [EMBLEM] = "FE6BCD", [CAP] = "FFFFFF"}
	local CAPTABLE_PEARL = {
		normal = smlua_model_util_get_id("pearl_cap_geo"),
		wing = smlua_model_util_get_id("pearl_cap_wing_geo"),
		metal = smlua_model_util_get_id("pearl_cap_metal_geo"),
		metalWing = smlua_model_util_get_id("pearl_cap_metal_wing_geo"),
	}
	local PEARL_DESC = "\"AYO! One two, one two! It's ya girl Pearl from Off the Hook!\" - Voice clips originally preformed by \"Rina Itou\" - Character by Nintendo."
	pearlCharID = _G.charSelect.character_add("Pearl", PEARL_DESC, CREATOR, "FF70B9", E_MODEL_PEARL, CT_MARIO, TEX_PEARL, 0.975)
	_G.charSelect.character_add_voice(E_MODEL_PEARL, splatIdolAnims_JJJ[3].voice)
	_G.charSelect.character_add_caps(E_MODEL_PEARL, CAPTABLE_PEARL)
	_G.charSelect.character_add_palette_preset(E_MODEL_PEARL, PEARL_PALETTE)
	_G.charSelect.character_add_animations(E_MODEL_PEARL, splatIdolAnims_JJJ[3].anims, splatIdolAnims_JJJ[3].eyeState, splatIdolAnims_JJJ[3].hands)
	_G.charSelect.character_set_category(pearlCharID, CATEGORY_NAME)
	
	if not retroCharAPI then
		-- Pearl (Costume - Octo)
		local E_MODEL_PEARL_OCTO = smlua_model_util_get_id("pearl_octo_geo")
		local PEARL_OCTO_PALETTE = {[PANTS] = "FFFFFF", [SHIRT] = "FF70B9", [GLOVES] = "DEFA8F", [SHOES] = "B3BCBC", [HAIR] = "E5BF7E", [SKIN] = "FFC89B", [EMBLEM] = "FF70B9", [CAP] = "FFFFFF"}
		pearlOctoCostumeID = _G.charSelect.character_add_costume(pearlCharID, "Pearl (Octo)", PEARL_DESC, CREATOR, "FF70B9", E_MODEL_PEARL_OCTO, CT_MARIO, TEX_PEARL, 1.025)
		_G.charSelect.character_add_voice(E_MODEL_PEARL_OCTO, splatIdolAnims_JJJ[3].voice)
		_G.charSelect.character_add_palette_preset(E_MODEL_PEARL_OCTO, PEARL_OCTO_PALETTE)
		_G.charSelect.character_add_animations(E_MODEL_PEARL_OCTO, splatIdolAnims_JJJ[3].anims, splatIdolAnims_JJJ[3].eyeState, splatIdolAnims_JJJ[3].hands)
		_G.charSelect.character_add_caps(E_MODEL_PEARL_OCTO, CAPTABLE_PEARL)
	end
	
	local PEARL_RETRO_PALETTE = {[PANTS] = "FE6BCD", [SHIRT] = "FFFFFF", [GLOVES] = "FE6BCD", [SHOES] = "FFFFFF", [HAIR] = "FFFFFF", [SKIN] = "FFCDC4", [EMBLEM] = "FE6BCD", [CAP] = "FFFFFF"}
	_G.charSelect.character_add_palette_preset(E_MODEL_PEARL, PEARL_RETRO_PALETTE, RETRO_NAME)
	
	_G.charSelect.character_add_menu_instrumental(pearlCharID, audio_stream_load("abc_menu_pearl.ogg"))
	_G.charSelect.character_add_graffiti(pearlCharID, TEX_GRAFFITI_PEARL)
	
	-- Marina
	local TEX_MARINA = get_texture_info("marina-icon")
	local TEX_GRAFFITI_MARINA = get_texture_info("graffiti-marina")
	local E_MODEL_MARINA = smlua_model_util_get_id("marina_geo")
	local MARINA_PALETTE = {[PANTS] = "00FF89", [SHIRT] = "000000", [GLOVES] = "000000", [SHOES] = "000000", [HAIR] = "300000", [SKIN] = "572E0E", [EMBLEM] = "293030", [CAP] = "00FF89"}
	local CAPTABLE_MARINA = {
		normal = smlua_model_util_get_id("marina_cap_geo"),
		wing = smlua_model_util_get_id("marina_cap_wing_geo"),
		metal = smlua_model_util_get_id("marina_cap_metal_geo"),
		metalWing = smlua_model_util_get_id("marina_cap_metal_wing_geo"),
	}
	local MARINA_DESC = "\"Hey, I'm Marina from Off the Hook! Nice to meet you!\" - Voice clips originally preformed by \"Alice Peralta\" - Character by Nintendo."
	marinaCharID = _G.charSelect.character_add("Marina", MARINA_DESC, CREATOR, "00FF89", E_MODEL_MARINA, CT_MARIO, TEX_MARINA, 1.175)
	_G.charSelect.character_add_voice(E_MODEL_MARINA, splatIdolAnims_JJJ[4].voice)
	_G.charSelect.character_add_caps(E_MODEL_MARINA, CAPTABLE_MARINA)
	_G.charSelect.character_add_palette_preset(E_MODEL_MARINA, MARINA_PALETTE)
	_G.charSelect.character_add_animations(E_MODEL_MARINA, splatIdolAnims_JJJ[4].anims, splatIdolAnims_JJJ[4].eyeState, splatIdolAnims_JJJ[4].hands)
	_G.charSelect.character_set_category(marinaCharID, CATEGORY_NAME)
	
	if not retroCharAPI then
		-- Marina (Costume - Octo)
		local E_MODEL_MARINA_OCTO = smlua_model_util_get_id("marina_octo_geo")
		local MARINA_OCTO_PALETTE = {[PANTS] = "7CAA90", [SHIRT] = "FFFFFF", [GLOVES] = "898989", [SHOES] = "FFFFFF", [HAIR] = "300000", [SKIN] = "572E0E", [EMBLEM] = "293030", [CAP] = "00FF89"}
		marinaOctoCostumeID = _G.charSelect.character_add_costume(marinaCharID, "Marina (Octo)", MARINA_DESC, CREATOR, "00FF89", E_MODEL_MARINA_OCTO, CT_MARIO, TEX_MARINA, 1.175)
		_G.charSelect.character_add_voice(E_MODEL_MARINA_OCTO, splatIdolAnims_JJJ[4].voice)
		_G.charSelect.character_add_palette_preset(E_MODEL_MARINA_OCTO, MARINA_OCTO_PALETTE)
		_G.charSelect.character_add_animations(E_MODEL_MARINA_OCTO, splatIdolAnims_JJJ[4].anims, splatIdolAnims_JJJ[4].eyeState, splatIdolAnims_JJJ[4].hands)
		_G.charSelect.character_add_caps(E_MODEL_MARINA_OCTO, CAPTABLE_MARINA)
	end
	
	local MARINA_RETRO_PALETTE = {[PANTS] = "017A8B", [SHIRT] = "000000", [GLOVES] = "017A8B", [SHOES] = "000000", [HAIR] = "000000", [SKIN] = "9B4903", [EMBLEM] = "000000", [CAP] = "017A8B"}
	_G.charSelect.character_add_palette_preset(E_MODEL_MARINA, MARINA_RETRO_PALETTE, RETRO_NAME)
	
	_G.charSelect.character_add_menu_instrumental(marinaCharID, audio_stream_load("abc_menu_marina.ogg"))
	_G.charSelect.character_add_graffiti(marinaCharID, TEX_GRAFFITI_MARINA)
	
	-- Shiver
	local TEX_SHIVER = get_texture_info("shiver-icon")
	local TEX_GRAFFITI_SHIVER = get_texture_info("graffiti-shiver")
	local E_MODEL_SHIVER = smlua_model_util_get_id("shiver_geo")
	local SHIVER_PALETTE = {[PANTS] = "000000", [SHIRT] = "FFFFFF", [SHOES] = "FF0000", [HAIR] = "3F3FFF", [SKIN] = "F3BC95", [EMBLEM] = "0000FF", [CAP] = "0000FF", [GLOVES] = "FF0000"}
	local CAPTABLE_SHIVER = {
		normal = smlua_model_util_get_id("shiver_cap_geo"),
		wing = smlua_model_util_get_id("shiver_cap_wing_geo"),
		metal = smlua_model_util_get_id("shiver_cap_metal_geo"),
		metalWing = smlua_model_util_get_id("shiver_cap_metal_wing_geo"),
	}
	local SHIVER_DESC = "\"You think you're cool? Sharks call ME cold-blooded. But you can call me Shiver!...Surely you know me from Deep Cut, the freshest pop sensation in the Splatlands.\" - Voice clips originally preformed by \"Anna Sato\" - Character by Nintendo."
	shiverCharID = _G.charSelect.character_add("Shiver", SHIVER_DESC, CREATOR, "3F3FFF", E_MODEL_SHIVER, CT_MARIO, TEX_SHIVER)
	_G.charSelect.character_add_voice(E_MODEL_SHIVER, splatIdolAnims_JJJ[5].voice)
	_G.charSelect.character_add_caps(E_MODEL_SHIVER, CAPTABLE_SHIVER)
	_G.charSelect.character_add_palette_preset(E_MODEL_SHIVER, SHIVER_PALETTE)
	
	_G.charSelect.character_add_animations(E_MODEL_SHIVER, splatIdolAnims_JJJ[5].anims, splatIdolAnims_JJJ[5].eyeState, splatIdolAnims_JJJ[5].hands)
	_G.charSelect.character_set_category(shiverCharID, CATEGORY_NAME)
	
	if not retroCharAPI then
		-- Shiver (Costume - Raiders)
		local E_MODEL_SHIVER_RAIDER = smlua_model_util_get_id("shiver_raider_geo")
		local SHIVER_RAIDER_PALETTE = {[PANTS] = "2C2C4D", [SHIRT] = "27272C", [SHOES] = "FF0000", [HAIR] = "3F3FFF", [SKIN] = "F3BC95", [CAP] = "00FF63", [GLOVES] = "FF0000", [EMBLEM] = "FFFFE1"}
		shiverRaiderCostumeID = _G.charSelect.character_add_costume(shiverCharID, "Shiver (Raiders)", SHIVER_DESC, CREATOR, "3F3FFF", E_MODEL_SHIVER_RAIDER, CT_MARIO, TEX_SHIVER, 1.1)
		_G.charSelect.character_add_voice(E_MODEL_SHIVER_RAIDER, splatIdolAnims_JJJ[5].voice)
		_G.charSelect.character_add_palette_preset(E_MODEL_SHIVER_RAIDER, SHIVER_RAIDER_PALETTE)
		_G.charSelect.character_add_animations(E_MODEL_SHIVER_RAIDER, splatIdolAnims_JJJ[5].anims, splatIdolAnims_JJJ[5].eyeState, splatIdolAnims_JJJ[5].hands)
		_G.charSelect.character_add_caps(E_MODEL_SHIVER_RAIDER, CAPTABLE_SHIVER)
	end
	
	local SHIVER_RETRO_PALETTE = {[PANTS] = "017A8B", [SHIRT] = "B43021", [SHOES] = "B43021", [HAIR] = "017A8B", [SKIN] = "FFCDC4", [EMBLEM] = "017A8B", [CAP] = "017A8B", [GLOVES] = "B43021"}
	_G.charSelect.character_add_palette_preset(E_MODEL_SHIVER, SHIVER_RETRO_PALETTE, RETRO_NAME)
	
	_G.charSelect.character_add_menu_instrumental(shiverCharID, audio_stream_load("abc_menu_shiver.ogg"))
	_G.charSelect.character_add_graffiti(shiverCharID, TEX_GRAFFITI_SHIVER)
	
	-- Frye
	local TEX_FRYE = get_texture_info("frye-icon")
	local TEX_GRAFFITI_FRYE = get_texture_info("graffiti-frye")
	local E_MODEL_FRYE = smlua_model_util_get_id("frye_geo")
	local FRYE_PALETTE = {[PANTS] = "FFFFFF", [SHIRT] = "FFFF00", [SHOES] = "FFFFFF",[HAIR] = "FFFF00", [SKIN] = "955900", [CAP] = "FF8900", [EMBLEM] = "FFFF00", [GLOVES] = "8819FF"}
	local CAPTABLE_FRYE = {
		normal = smlua_model_util_get_id("frye_cap_geo"),
		wing = smlua_model_util_get_id("frye_cap_wing_geo"),
		metal = smlua_model_util_get_id("frye_cap_metal_geo"),
		metalWing = smlua_model_util_get_id("frye_cap_metal_wing_geo"),
	}
	local FRYE_DESC = "\"Say it with sizzle...I'm Frye, from Deep Cut, ready for battle! Repping the Splatlands...we drip ink while the suckers lip-synch. Booyah!\" - Voice clips originally preformed by \"Laura Yokozawa\" - Character by Nintendo."
	fryeCharID = _G.charSelect.character_add("Frye", FRYE_DESC, CREATOR, "FFFF00", E_MODEL_FRYE, CT_MARIO, TEX_FRYE, 1.0375)
	_G.charSelect.character_add_voice(E_MODEL_FRYE, splatIdolAnims_JJJ[6].voice)
	_G.charSelect.character_add_caps(E_MODEL_FRYE, CAPTABLE_FRYE)
	_G.charSelect.character_add_palette_preset(E_MODEL_FRYE, FRYE_PALETTE)
	_G.charSelect.character_add_animations(E_MODEL_FRYE, splatIdolAnims_JJJ[6].anims, splatIdolAnims_JJJ[6].eyeState, splatIdolAnims_JJJ[6].hands)
	_G.charSelect.character_set_category(fryeCharID, CATEGORY_NAME)
	
	if not retroCharAPI then
		-- Frye (Costume - Raiders)
		local E_MODEL_FRYE_RAIDER = smlua_model_util_get_id("frye_raider_geo")
		local FRYE_RAIDER_PALETTE = {[PANTS] = "27272C", [SHIRT] = "27272C", [SHOES] = "FFFFFF", [HAIR] = "FFFF00", [SKIN] = "955900", [CAP] = "FFFFFF", [EMBLEM] = "FFFF00", [GLOVES] = "8819FF"}
		fryeRaiderCostumeID = _G.charSelect.character_add_costume(fryeCharID, "Frye (Raiders)", FRYE_DESC, CREATOR, "FFFF00", E_MODEL_FRYE_RAIDER, CT_MARIO, TEX_FRYE, 1.175)
		_G.charSelect.character_add_voice(E_MODEL_FRYE_RAIDER, splatIdolAnims_JJJ[6].voice)
		_G.charSelect.character_add_palette_preset(E_MODEL_FRYE_RAIDER, FRYE_RAIDER_PALETTE)
		_G.charSelect.character_add_animations(E_MODEL_FRYE_RAIDER, splatIdolAnims_JJJ[6].anims, splatIdolAnims_JJJ[6].eyeState, splatIdolAnims_JJJ[6].hands)
		_G.charSelect.character_add_caps(E_MODEL_FRYE_RAIDER, CAPTABLE_FRYE)
	end
	
	local FRYE_RETRO_PALETTE = {[PANTS] = "E59B26", [SHIRT] = "E59B26", [SHOES] = "E59B26", [HAIR] = "E59B26", [SKIN] = "9B4903", [CAP] = "9B4903", [EMBLEM] = "E59B26", [GLOVES] = "004149"}
	_G.charSelect.character_add_palette_preset(E_MODEL_FRYE, FRYE_RETRO_PALETTE, RETRO_NAME)
	
	_G.charSelect.character_add_menu_instrumental(fryeCharID, audio_stream_load("abc_menu_frye.ogg"))
	_G.charSelect.character_add_graffiti(fryeCharID, TEX_GRAFFITI_FRYE)
	
	-- Big Man
	local TEX_BIGMAN = get_texture_info("bigman-icon")
	local TEX_GRAFFITI_BIGMAN = get_texture_info("graffiti-bigman")
	local E_MODEL_BIGMAN = smlua_model_util_get_id("bigman_geo")
	local BIGMAN_PALETTE = {[SKIN] = "FFEDED", [CAP] = "FF5A5E", [PANTS] = "414341", [SHIRT] = "FF5A5E", [HAIR] = "FF5A5E", [EMBLEM] = "AC8C8C", [GLOVES] = "EADADA"}
	local CAPTABLE_BIGMAN = {
		normal = smlua_model_util_get_id("bigman_cap_geo"),
		wing = smlua_model_util_get_id("bigman_cap_wing_geo"),
		metal = smlua_model_util_get_id("bigman_cap_metal_geo"),
		metalWing = smlua_model_util_get_id("bigman_cap_metal_wing_geo"),
	}
	local BIGMAN_DESC = "\"Ay! (Make money! Get fish quick!)...Ay! (Big Man in the house!) Ay. (It's super nice to meet you.)\" - Character by Nintendo."
	bigmanCharID = _G.charSelect.character_add("Big Man", BIGMAN_DESC, CREATOR, "FF5A5E", E_MODEL_BIGMAN, CT_MARIO, TEX_BIGMAN, 1.4)
	_G.charSelect.character_add_voice(E_MODEL_BIGMAN, splatIdolAnims_JJJ[7].voice)
	_G.charSelect.character_add_caps(E_MODEL_BIGMAN, CAPTABLE_BIGMAN)
	_G.charSelect.character_add_palette_preset(E_MODEL_BIGMAN, BIGMAN_PALETTE)
	_G.charSelect.character_add_animations(E_MODEL_BIGMAN, splatIdolAnims_JJJ[7].anims, splatIdolAnims_JJJ[7].eyeState, splatIdolAnims_JJJ[7].hands)
	_G.charSelect.character_set_category(bigmanCharID, CATEGORY_NAME)
	
	if not retroCharAPI then
		-- Big Man (Costume - Raiders)
		local E_MODEL_BIGMAN_RAIDER = smlua_model_util_get_id("bigman_raider_geo")
		local BIGMAN_RAIDER_PALETTE = {[SKIN] = "EDFFED", [PANTS] = "27272C", [SHIRT] = "FF5A5E", [CAP] = "30FFB0", [HAIR] = "FF5A5E", [EMBLEM] = "AC8C8C", [GLOVES] = "EADADA"}
		bigmanRaiderCostumeID = _G.charSelect.character_add_costume(bigmanCharID, "Big Man (Raiders)", BIGMAN_DESC, CREATOR, "FF5A5E", E_MODEL_BIGMAN_RAIDER, CT_MARIO, TEX_BIGMAN, 1.4)
		_G.charSelect.character_add_voice(E_MODEL_BIGMAN_RAIDER, splatIdolAnims_JJJ[7].voice)
		_G.charSelect.character_add_palette_preset(E_MODEL_BIGMAN_RAIDER, BIGMAN_RAIDER_PALETTE)
		_G.charSelect.character_add_animations(E_MODEL_BIGMAN_RAIDER, splatIdolAnims_JJJ[7].anims, splatIdolAnims_JJJ[7].eyeState, splatIdolAnims_JJJ[7].hands)
		_G.charSelect.character_add_caps(E_MODEL_BIGMAN_RAIDER, CAPTABLE_BIGMAN)
	else
		local BIGMAN_RETRO_PALETTE = {[SKIN] = "FFFFFF", [CAP] = "B43021", [PANTS] = "ACACAC", [SHIRT] = "B43021", [HAIR] = "B43021", [EMBLEM] = "ACACAC", [GLOVES] = "FFFFFF"}
		_G.charSelect.character_add_palette_preset(E_MODEL_BIGMAN, BIGMAN_RETRO_PALETTE, RETRO_NAME)
	end

	_G.charSelect.character_add_menu_instrumental(bigmanCharID, audio_stream_load("abc_menu_bigman.ogg"))
	_G.charSelect.character_add_graffiti(bigmanCharID, TEX_GRAFFITI_BIGMAN)
	
	-- ** HUD TEXTURES **
	local charList = {
		callieCharID, 
		marieCharID, 
		pearlCharID, 
		marinaCharID, 
		shiverCharID, 
		fryeCharID, 
		bigmanCharID, 
	}
	local hudIcons = {
		{"texture_hud_char_0",            get_texture_info("splat-0")}, 
		{"texture_hud_char_1",            get_texture_info("splat-1")}, 
		{"texture_hud_char_2",            get_texture_info("splat-2")}, 
		{"texture_hud_char_3",            get_texture_info("splat-3")}, 
		{"texture_hud_char_4",            get_texture_info("splat-4")}, 
		{"texture_hud_char_5",            get_texture_info("splat-5")}, 
		{"texture_hud_char_6",            get_texture_info("splat-6")}, 
		{"texture_hud_char_7",            get_texture_info("splat-7")}, 
		{"texture_hud_char_8",            get_texture_info("splat-8")}, 
		{"texture_hud_char_9",            get_texture_info("splat-9")}, 
		{"texture_hud_char_A",            get_texture_info("splat-a")}, 
		{"texture_hud_char_B",            get_texture_info("splat-b")}, 
		{"texture_hud_char_C",            get_texture_info("splat-c")}, 
		{"texture_hud_char_D",            get_texture_info("splat-d")}, 
		{"texture_hud_char_E",            get_texture_info("splat-e")}, 
		{"texture_hud_char_F",            get_texture_info("splat-f")}, 
		{"texture_hud_char_G",            get_texture_info("splat-g")}, 
		{"texture_hud_char_H",            get_texture_info("splat-h")}, 
		{"texture_hud_char_I",            get_texture_info("splat-i")}, 
		{"texture_hud_char_K",            get_texture_info("splat-k")}, 
		{"texture_hud_char_L",            get_texture_info("splat-l")}, 
		{"texture_hud_char_M",            get_texture_info("splat-m")}, 
		{"texture_hud_char_N",            get_texture_info("splat-n")}, 
		{"texture_hud_char_O",            get_texture_info("splat-o")}, 
		{"texture_hud_char_P",            get_texture_info("splat-p")}, 
		{"texture_hud_char_R",            get_texture_info("splat-r")}, 
		{"texture_hud_char_S",            get_texture_info("splat-s")}, 
		{"texture_hud_char_T",            get_texture_info("splat-t")}, 
		{"texture_hud_char_U",            get_texture_info("splat-u")}, 
		{"texture_hud_char_W",            get_texture_info("splat-w")}, 
		{"texture_hud_char_Y",            get_texture_info("splat-y")}, 
		{"texture_hud_char_camera",       get_texture_info("splat-camera")}, 
		{"texture_hud_char_coin",         get_texture_info("splat-coin")}, 
		{"texture_hud_char_multiply",     get_texture_info("splat-dash")}, 
		{"texture_hud_char_lakitu",       get_texture_info("splat-lakitu")}, 
		{"texture_hud_char_no_camera",    get_texture_info("splat-nocam")}, 
		{"texture_hud_char_arrow_up",     get_texture_info("splat-pointer")}, 
		{"texture_hud_char_arrow_down",   get_texture_info("splat-pointer-down")}, 
		{"texture_hud_char_star",         get_texture_info("splat-star")}, 
		{"texture_hud_char_double_quote", get_texture_info("splat-double-quote")}, 
		{"texture_hud_char_apostrophe",   get_texture_info("splat-apostrophe")}, 
	}
	local courseSymbol = {
		top = get_texture_info("splat-course-top"), 
		bottom = get_texture_info("splat-course-bottom"), 
	}
	
	local healthMeter = get_texture_info("splat-health-base")
	local healthHeart = get_texture_info("splat-health-icon")
	local healthSquid, healthOctopus = get_texture_info("health-squid"), get_texture_info("health-octopus")
	local healthPie = {
		[1] = get_texture_info("splat-pie-1"), 
		[2] = get_texture_info("splat-pie-2"), 
		[3] = get_texture_info("splat-pie-3"), 
		[4] = get_texture_info("splat-pie-4"), 
		[5] = get_texture_info("splat-pie-5"), 
		[6] = get_texture_info("splat-pie-6"), 
		[7] = get_texture_info("splat-pie-7"), 
		[8] = get_texture_info("splat-pie-8"), 
	}

	local MATH_DIVIDE_16, MATH_DIVIDE_32, MATH_DIVIDE_64 = 1/16, 1/32, 1/64
	local function healthRenderFunction(localIndex, health, prevX, prevY, prevScaleX, prevScaleY, x, y, scaleX, scaleY) -- Pretty much almost a copy of the original health meter rendering code by Squishy.
		local modelId = _G.charSelect.character_get_current_number(localIndex)
		
		-- Health meter base.
		local healthPart = health >> 8
		djui_hud_render_texture(healthMeter, x, y, scaleX / (healthMeter.width * MATH_DIVIDE_64) * MATH_DIVIDE_64, scaleY / (healthMeter.height * MATH_DIVIDE_64) * MATH_DIVIDE_64)
		if modelId == marinaCharID or modelId == shiverCharID then -- Renders an Octopus icon for Marina and Shiver.
			djui_hud_render_texture(healthOctopus, x, y, scaleX / (healthOctopus.width * MATH_DIVIDE_32) * MATH_DIVIDE_64, scaleY / (healthOctopus.height * MATH_DIVIDE_32) * MATH_DIVIDE_64)
		else
			djui_hud_render_texture(healthSquid, x, y, scaleX / (healthSquid.width * MATH_DIVIDE_32) * MATH_DIVIDE_64, scaleY / (healthSquid.height * MATH_DIVIDE_32) * MATH_DIVIDE_64)
		end
		
		-- Pie, yum!
        if healthPart > 0 then
			local tex = healthPie[healthPart]
            djui_hud_render_texture(tex, x + 15*scaleX*MATH_DIVIDE_64, y + 16*scaleY*MATH_DIVIDE_64, scaleX / (tex.width * MATH_DIVIDE_32) * MATH_DIVIDE_64, scaleY / (tex.height * MATH_DIVIDE_32) * MATH_DIVIDE_64)
        end
		
		-- Heart icon, based on player "ink" color.
		local inkType = (modelId == callieCharID or modelId == marieCharID or modelId == marinaCharID or modelId == bigmanCharID) and CAP or (modelId == pearlCharID and EMBLEM) or HAIR
		local color = network_player_get_override_palette_color(gNetworkPlayers[0], inkType)
		djui_hud_set_color(color.r, color.g, color.b, 255)
		djui_hud_render_texture(healthHeart, x + 23*scaleX*MATH_DIVIDE_64, y + 25*scaleY*MATH_DIVIDE_64, scaleX / (healthHeart.width * MATH_DIVIDE_16) * MATH_DIVIDE_64, scaleY / (healthHeart.height * MATH_DIVIDE_16) * MATH_DIVIDE_64)
		djui_hud_set_color(255, 255, 255, 255)
	end
	
	for i = 1, #charList do
		local currChar = charList[i]
		for j = 1, #hudIcons do
			local hudIcon = hudIcons[j]
			_G.charSelect.character_add_texture_replacement(currChar, hudIcon[1], hudIcon[2])
		end
		if currChar == marinaCharID or currChar == shiverCharID then
			_G.charSelect.character_add_texture_replacement(currChar, "texture_transition_mario", get_texture_info("octopus-trans.ia8"))
		else
			_G.charSelect.character_add_texture_replacement(currChar, "texture_transition_mario", get_texture_info("squid-trans.ia8"))
		end
		_G.charSelect.character_add_course_texture(currChar, courseSymbol)
		_G.charSelect.character_add_health_meter(currChar, healthRenderFunction)
	end
	
	-- Adding course symbol to costumes, don't know why this has to be done for costumes, but, y'know, eh.
	_G.charSelect.character_add_costume_course_texture(callieCharID, callieHypnoCostumeID, courseSymbol)
	_G.charSelect.character_add_costume_course_texture(callieCharID, callieCasualCostumeID, courseSymbol)
	_G.charSelect.character_add_costume_course_texture(marieCharID, marieCasualCostumeID, courseSymbol)
	_G.charSelect.character_add_costume_course_texture(pearlCharID, pearlOctoCostumeID, courseSymbol)
	_G.charSelect.character_add_costume_course_texture(marinaCharID, marinaOctoCostumeID, courseSymbol)
	_G.charSelect.character_add_costume_course_texture(shiverCharID, shiverRaiderCostumeID, courseSymbol)
	_G.charSelect.character_add_costume_course_texture(fryeCharID, fryeRaiderCostumeID, courseSymbol)
	_G.charSelect.character_add_costume_course_texture(bigmanCharID, bigmanRaiderCostumeID, courseSymbol)
	
	local inkTex = get_texture_info("ink-splatter")
	hook_event(HOOK_ON_HUD_RENDER_BEHIND, function ()
		local modelId = _G.charSelect.character_get_current_number(0)
		
		if not (modelId == callieCharID or modelId == marieCharID or modelId == pearlCharID or modelId == marinaCharID or modelId == shiverCharID or modelId == fryeCharID or modelId == bigmanCharID) then return end
		if _G.charSelect.get_options_status(_G.charSelect.optionTableRef.localVisuals) == 0 or hud_is_hidden() or (hud_get_value(HUD_DISPLAY_FLAGS) & HUD_DISPLAY_FLAG_LIVES) == 0 or gHudDisplay.flags == HUD_DISPLAY_NONE then return end
		
		local scale, x, y = djui_hud_get_screen_height() / 240, 22, 15
		local inkType = (modelId == callieCharID or modelId == marieCharID or modelId == marinaCharID or modelId == bigmanCharID) and CAP or (modelId == pearlCharID and EMBLEM) or HAIR
		local color = network_player_get_override_palette_color(gNetworkPlayers[0], inkType)
		
		djui_hud_set_color(color.r, color.g, color.b, 255)
		djui_hud_render_texture(inkTex, (x - 8) * scale, (y - 8) * scale, scale, scale)
		djui_hud_set_color(255, 255, 255, 255)
		_G.charSelect.character_render_life_icon(0, x * scale, y * scale, scale)
	end)
	
	-- Credits, specific to "[CS] Now or Never Seven"
	local MOD_NAME = "SplatIdols 64"
	_G.charSelect.credit_add(MOD_NAME, "VioletSM64", "Idle Trans. Help")
	_G.charSelect.credit_add(MOD_NAME, "Wasarety", "Raiders Models Ref.")
	_G.charSelect.credit_add(MOD_NAME, "VentiVR", "Raiders Models Help")
	_G.charSelect.credit_add(MOD_NAME, "Morishiko", "Swim Form Model Help")
	_G.charSelect.credit_add(MOD_NAME, "Inkipedia", "Splatoon Assets")
end