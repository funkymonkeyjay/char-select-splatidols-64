if incompatibilityCond then return end

ACT_YAWN_SPLATIDOLS_JJJ = allocate_mario_action(ACT_FLAG_STATIONARY | ACT_FLAG_IDLE | ACT_FLAG_ALLOW_FIRST_PERSON | ACT_FLAG_PAUSE_EXIT)

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

if _G.charSelectExists then
	hook_mario_action(ACT_YAWN_SPLATIDOLS_JJJ, {every_frame = splatIdolYawnAct_JJJ, gravity = function (m) end})
end

