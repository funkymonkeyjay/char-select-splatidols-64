if incompatibilityCond then return end

ACT_YAWN_SPLATIDOLS_JJJ = allocate_mario_action(ACT_FLAG_STATIONARY | ACT_FLAG_IDLE | ACT_FLAG_ALLOW_FIRST_PERSON | ACT_FLAG_PAUSE_EXIT)
ACT_PET_SPLATIDOLS_JJJ = allocate_mario_action(ACT_GROUP_AUTOMATIC | ACT_FLAG_STATIONARY)

function splatIdolYawnAct_JJJ(m)
	if check_common_idle_cancels(m) == 1 then
		return 1
	end
	
	if m.quicksandDepth > 30 then
		return set_mario_action(m, ACT_IN_QUICKSAND, 0)
	end

	if m.actionState == 0 then
		set_character_animation(m, CHAR_ANIM_START_SLEEP_IDLE)
		play_character_sound(m, CHAR_SOUND_IMA_TIRED)
		m.actionState = 1
	elseif m.actionState == 1 then
		if is_anim_at_end(m) == 1 then
			m.actionState = 2
		end
	elseif m.actionState == 2 then
		set_character_animation(m, CHAR_ANIM_IDLE_HEAD_LEFT)
		set_anim_to_frame(m, 10)
		return set_mario_action(m, ACT_IDLE, 0)
	end
	
	stationary_ground_step(m)
	return 0
end

local function splatIdolPetAct_JJJ(m) -- Credit to "wibblus" for this code, I just copied it because otherwise the incorrect animation would play, apologies if any trouble is caused by this.
	if m.actionTimer == 0 then
		set_mario_animation(m, SPLATIDOLS_PETTING)
		play_sound(SOUND_GENERAL_SHORT_STAR, m.marioObj.header.gfx.cameraToObject)
		set_mario_particle_flags(m, PARTICLE_SPARKLES, 0)
		mario_set_forward_vel(m, 0.0)
	elseif m.actionTimer < 60 then
		if m.input & (INPUT_NONZERO_ANALOG | INPUT_A_PRESSED | INPUT_B_PRESSED | INPUT_Z_PRESSED) ~= 0 then
			return set_mario_action(m, ACT_IDLE, 0)
		end
	else
		return set_mario_action(m, ACT_IDLE, 0)
	end

	perform_ground_step(m)
	m.actionTimer = m.actionTimer + 1
end

if _G.charSelectExists then
	hook_mario_action(ACT_YAWN_SPLATIDOLS_JJJ, {every_frame = splatIdolYawnAct_JJJ, gravity = function (m) end})
	hook_mario_action(ACT_PET_SPLATIDOLS_JJJ, {every_frame = splatIdolPetAct_JJJ, gravity = function (m) end})
end

