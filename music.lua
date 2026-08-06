local VERSION_REQUIRED = 41
local HAS_CHAR_SELECT = _G.charSelectExists
if VERSION_NUMBER < VERSION_REQUIRED then return end

-- ** LOADING CONDITIONS **

local MOD_NAME = "\"Spla\\#7DFF32\\t\\#D9D9D9\\Idol\\#7DFF32\\s \\#FF4CBD\\64\\#ffffff\\\""
local musConfigName = "splatIdolsMusicCond_JJJ" -- Can custom music be played?
if mod_storage_exists(musConfigName) then
	splatIdolsMusicCond = mod_storage_load_bool(musConfigName)
else
	splatIdolsMusicCond = true -- Set to "true" on startup.
	mod_storage_save_bool(musConfigName, true)
end

local oldStarConfigName = "splatIdolsStarCond_JJJ" -- Does the Splatoon (2015) "Onward!" theme play whenever a star is collected?
if mod_storage_exists(oldStarConfigName) then
	splatIdolsOldStarCond = mod_storage_load_bool(oldStarConfigName)
else
	splatIdolsOldStarCond = false -- Set to "false" on startup.
	mod_storage_save_bool(oldStarConfigName, false)
end

if HAS_CHAR_SELECT then
	local onlyIdolsConfigName = "splatIdolsOnlyIdolsCond_JJJ" -- Do the custom songs only play for the Now or Never Seven?
	if mod_storage_exists(onlyIdolsConfigName) then
		splatIdolsOnlyIdolsCond = mod_storage_load_bool(onlyIdolsConfigName)
	else
		splatIdolsOnlyIdolsCond = true -- Set to "true" on startup.
		mod_storage_save_bool(onlyIdolsConfigName, true)
	end
else
	splatIdolsOnlyIdolsCond = false
end

-- ** CHAT COMMANDS **

local function splatIdolsMusicToggleChat()
	splatIdolsMusicCond = not splatIdolsMusicCond
	if splatIdolsMusicCond then
		djui_chat_message_create("\\#50FF00\\Agent 2\\#FFFFFF\\: Radio override activated!\n(Custom Beats are \\#FF8000\\ON\\#FFFFFF\\.)")
	else
		djui_chat_message_create("\\#FF00A0\\Agent 1\\#FFFFFF\\: Radio override...deactivated?\n(Custom Beats are \\#FF8000\\OFF\\#FFFFFF\\.)")
	end
	mod_storage_save_bool(musConfigName, splatIdolsMusicCond)
	return true
end

local function splatIdolsOnwardToggleChat()
	if not splatIdolsMusicCond then
		djui_chat_message_create("\\#FF00A0\\Agent 1\\#FFFFFF\\: Shoot! Radio's been off this whole time.\n(Custom Beats need to be turned \\#FF8000\\ON\\#FFFFFF\\ beforehand.)")
		return true
	end
	splatIdolsOldStarCond = not splatIdolsOldStarCond
	if splatIdolsOldStarCond then
		djui_chat_message_create("\\#FF00A0\\Agent 1\\#FFFFFF\\: Going with \\#FF8000\\Team Past\\#FFFFFF\\? Good choice!\n\\#50FF00\\Agent 2\\#FFFFFF\\: Can't go wrong with that.\n(\"\\#FF8000\\Onward! (2015)\\#FFFFFF\\\" will now play on Star collect.)")
	else
		djui_chat_message_create("\\#50FF00\\Agent 2\\#FFFFFF\\: So...\\#FF8000\\Team Future\\#FFFFFF\\, huh?\n\\#FFFF00\\Frye\\#FFFFFF\\: Ooh, count me in!\n\\#50FF00\\Agent 2\\#FFFFFF\\: ?!\n(\"\\#FF8000\\Onward! (64MIX)\\#FFFFFF\\\" will now play on Star collect.)")
	end
	mod_storage_save_bool(oldStarConfigName, splatIdolsOldStarCond)
	return true
end

local function splatIdolsOnlyIdolsToggleChat()
	if not splatIdolsMusicCond then
		djui_chat_message_create("\\#FF00A0\\Agent 1\\#FFFFFF\\: Shoot! Radio's been off this whole time.\n(Custom Beats need to be turned \\#FF8000\\ON\\#FFFFFF\\ beforehand.)")
		return true
	end
	splatIdolsOnlyIdolsCond = not splatIdolsOnlyIdolsCond
	if splatIdolsOnlyIdolsCond then
		djui_chat_message_create("\\#FF5A5E\\Big Man\\#FFFFFF\\: Ay, ay...? (Guess we keep the music all to ourselves again, then...?)\n\\#3F3FFF\\Shiver\\#FFFFFF\\: As it should be.\n(You can now play \"\\#FF8000\\SplatIdols 64\\#FFFFFF\\\" music ONLY with its respective characters.)")
	else
		djui_chat_message_create("\\#00FF89\\DJ_Hyperfresh\\#FFFFFF\\: Here, now you can listen to our music!\n\\#FF70B9\\MC.Princess\\#FFFFFF\\: You don't even have to be one of us, yo!\n(You can now play \"\\#FF8000\\SplatIdols 64\\#FFFFFF\\\" music regardless of character.)")
	end
	mod_storage_save_bool(onlyIdolsConfigName, splatIdolsOnlyIdolsCond)
	return true
end

local statusFrameCount = 0
hook_chat_command("splat-mus", "- Set \\#FF8000\\Custom Beats\\#FFFFFF\\ for " .. MOD_NAME, splatIdolsMusicToggleChat)
hook_chat_command("splat-star", "- Set \"\\#FF8000\\Onward!\\#FFFFFF\\\" Theme for " .. MOD_NAME, splatIdolsOnwardToggleChat)
if HAS_CHAR_SELECT then hook_chat_command("splat-char", "- Set \\#FF8000\\Custom Beat\\#FFFFFF\\ availability for all characters", splatIdolsOnlyIdolsToggleChat) end
hook_chat_command("splat-status", "- View current config status for " .. MOD_NAME, function() statusFrameCount = 0 return true end)

hook_event(HOOK_UPDATE, function ()
	if statusFrameCount < 6 then statusFrameCount = statusFrameCount + 1 end
	if statusFrameCount == 5 then
		local baseText = "~ SPLA\\#7DFF32\\T\\#D9D9D9\\IDOL\\#7DFF32\\S \\#FF4CBD\\64\\#ffffff\\ ~\n\nCustom Music - [ \\#FF8000\\" .. (splatIdolsMusicCond and "ON" or "OFF") .. "\\#FFFFFF\\ ]\nStar Theme - [ \\#FF8000\\Onward! " .. (splatIdolsOldStarCond and "(2015)" or "(64MIX)") .. "\\#FFFFFF\\ ]"
		local charOnlyText = "\nBeats For All - [ \\#FF8000\\" .. (splatIdolsOnlyIdolsCond and "OFF" or "ON") .. "\\#FFFFFF\\ ]"
		djui_popup_create(baseText .. (HAS_CHAR_SELECT and charOnlyText or ""), HAS_CHAR_SELECT and 5 or 4)
	end
end)

-- ** MENU BUTTONS **
-- I probably could've hooked all of this to CS using "add_option", but there needed to be compatibility for when you don't have CS activated, which is why these are here, sorry, I'll do better next time!
hook_mod_menu_text("Configure your taste in \\#FF8000\\music\\#FFFFFF\\!")
hook_mod_menu_button("Toggle \\#FF8000\\Custom Beats\\#FFFFFF\\", splatIdolsMusicToggleChat)
hook_mod_menu_button("Toggle \\#FF8000\\\"Onward!\" Theme\\#FFFFFF\\", splatIdolsOnwardToggleChat)
if HAS_CHAR_SELECT then hook_mod_menu_button("Toggle Custom Beats for \\#FF8000\\ALL Characters", splatIdolsOnlyIdolsToggleChat) end
hook_mod_menu_button("Show \\#FF8000\\Current Status\\#FFFFFF\\", function () statusFrameCount = 0 end)

-- ** LOADING CUSTOM MUSIC **
local musicList = {
	[SEQ_LEVEL_BOSS_KOOPA_FINAL] = 1, 
	[SEQ_EVENT_CUTSCENE_COLLECT_STAR] = 2,
	[SEQ_MENU_STAR_SELECT] = 7, 
	[SEQ_EVENT_POWERUP] = 8, 
	[SEQ_EVENT_METAL_CAP] = 9, 
}

local cusMusic = {
	audio_stream_load("abc_calamari_inkantation_64.ogg"), -- Calamari Inkantation 64MIX
	audio_stream_load("abc_star_collect.ogg"), -- Star Collect 64MIX
	audio_stream_load("abc_star_collect_old.ogg"), -- Star Collect (Onwards! - Splatoon)
	audio_stream_load("abc_key_ss.ogg"), -- Key Collect (Splatfest Results - Splatoon)
	audio_stream_load("abc_key_oth.ogg"), -- Key Collect (Splatfest Results - Splatoon 2)
	audio_stream_load("abc_key_dc.ogg"), -- Key Collect (Splatfest Results - Splatoon 3)
	audio_stream_load("abc_star_select.ogg"), -- Star Select
	audio_stream_load("abc_wing_ss.ogg"), -- Powerful Idol (Squid Sisters)
	audio_stream_load("abc_metal_ss.ogg"), -- Metal Idol (Squid Sisters)
	audio_stream_load("abc_wing_oth.ogg"), -- Powerful Idol (Off the Hook)
	audio_stream_load("abc_metal_oth.ogg"), -- Metal Idol (Off the Hook)
	audio_stream_load("abc_wing_dc.ogg"), -- Powerful Idol (Deep Cut)
	audio_stream_load("abc_metal_dc.ogg"), -- Metal Idol (Deep Cut)
}

-- ** SETTING LOOPS **
audio_stream_set_looping(cusMusic[1], true) -- Calamari Inkantation 64
audio_stream_set_looping(cusMusic[8], true) -- Powerful Idol (Squid Sisters)
audio_stream_set_looping(cusMusic[9], true) -- Metal Idol (Squid Sisters)
audio_stream_set_looping(cusMusic[10], true) -- Powerful Idol (Off the Hook)
audio_stream_set_looping(cusMusic[11], true) -- Metal Idol (Off the Hook)
audio_stream_set_looping(cusMusic[12], true) -- Powerful Idol (Deep Cut)
audio_stream_set_looping(cusMusic[13], true) -- Metal Idol (Deep Cut)

-- ** LOOPING POINTS **
audio_stream_set_loop_points(cusMusic[1], 18.799*22050, 114.796*22050) -- Calamari Inkantation 64
audio_stream_set_loop_points(cusMusic[8], 7.4*22050, 29.538*22050) -- Powerful Idol (Squid Sisters)
audio_stream_set_loop_points(cusMusic[9], 14.556*22050, 47.002*22050) -- Metal Idol (Squid Sisters)
audio_stream_set_loop_points(cusMusic[11], 2.219*22050, 25.223*22050) -- Metal Idol (Off the Hook)
audio_stream_set_loop_points(cusMusic[13], 4.894*22050, 41.231*22050) -- Metal Idol (Deep Cut)

local cusMusHasStarted = false
local cusMusPausePos = 0
local cusMusIndex = 1

local originalMusic = 0
local hasFaded = false

hook_event(HOOK_ON_SEQ_LOAD, function (p, seq)
	hasFaded = false
	
	local m, n = gMarioStates[0], gNetworkPlayers[0]
	local modelId
	if HAS_CHAR_SELECT then
		modelId = _G.charSelect.character_get_current_number(0)
		if (splatIdolsOnlyIdolsCond and not (modelId == callieCharID or modelId == marieCharID or modelId == pearlCharID or modelId == marinaCharID or modelId == shiverCharID or modelId == fryeCharID or modelId == bigmanCharID)) then return end
	end

	local nearestBowser = obj_get_nearest_object_with_behavior_id(o, id_bhvBowser)
	
	if p == SEQ_PLAYER_LEVEL or seq == SEQ_EVENT_CUTSCENE_COLLECT_STAR or seq == SEQ_EVENT_CUTSCENE_COLLECT_STAR or seq == SEQ_EVENT_CUTSCENE_COLLECT_KEY then -- Don't stop custom music when the player isn't "SEQ_PLAYER_LEVEL".
		if seq ~= 0 then
			for i = 1, #cusMusic do
				if audio_stream_get_looping(cusMusic[i]) or i == 7 then
					audio_stream_stop(cusMusic[i])
				end
			end
			cusMusHasStarted = false
			cusMusPausePos = 0
			cusMusIndex = 1
		end
	end
	
	if splatIdolsMusicCond then
		if seq == SEQ_EVENT_CUTSCENE_COLLECT_KEY and m.action == ACT_STAR_DANCE_EXIT then
			if splatIdolsOnlyIdolsCond then
				if modelId == callieCharID or modelId == marieCharID then
					audio_stream_play(cusMusic[4], false, 1)
				elseif modelId == pearlCharID or modelId == marinaCharID then
					audio_stream_play(cusMusic[5], false, 1)
				elseif modelId == shiverCharID or modelId == fryeCharID or modelId == bigmanCharID then
					audio_stream_play(cusMusic[6], false, 1)
				else
					audio_stream_play(cusMusic[splatIdolsOldStarCond and 3 or 2], false, 1)
				end
			else
				audio_stream_play(cusMusic[splatIdolsOldStarCond and 3 or 2], false, 1)
			end
			return -1
		elseif musicList[seq] then
			cusMusIndex = musicList[seq]
			
			local charCond = false
			if HAS_CHAR_SELECT then
				charCond = modelId == callieCharID or modelId == marieCharID or modelId == pearlCharID or modelId == marinaCharID or modelId == shiverCharID or modelId == fryeCharID or modelId == bigmanCharID
			end
			if cusMusIndex > 7 and not charCond then
				return
			end
			
			-- "Better Coins" compatibility for giggles!
			local betterCoinsCheck = _G.betterCoins and ((m.flags & MARIO_WING_CAP) ~= 0 and (m.flags & MARIO_VANISH_CAP) ~= 0 and (m.flags & MARIO_METAL_CAP) ~= 0)
			if (cusMusIndex == 1 and n.currLevelNum == LEVEL_BOWSER_3) -- Play "Calamari Inkantation 64MIX" only during Final Bowser.
			or ((cusMusIndex == 2 or cusMusIndex == 3) and (m.action & ACT_FLAG_INTANGIBLE) == 0) -- Play "Onward!" only during star dance.
			or (cusMusIndex == 6 and obj_get_first_with_behavior_id(id_bhvActSelector)) -- Play "Star Select" only during... Star Select!
			or (cusMusIndex > 7 and (m.capTimer == 0 or betterCoinsCheck)) then -- Play cap themes only when any cap is on AND the characters are idols.
				return 
			end

			audio_stream_play(cusMusic[cusMusIndex], false, 1)
			if audio_stream_get_looping(cusMusic[cusMusIndex]) then
				cusMusHasStarted = true
				cusMusPausePos = 0
				if cusMusIndex == 1 then audio_stream_set_position(cusMusic[cusMusIndex], 0.591) end -- Too lazy to cut out the empty section of the Calamari Inkantation.
			end
			return cusMusIndex > 7 and SEQ_SOUND_PLAYER or -1 -- Couldn't use SEQ_SOUND_PLAYER because that'd break for the non-exit star themes, specifically the original background music itself.
		end
	end
end)

hook_event(HOOK_UPDATE, function () -- function meant to handle custom streamed music.
	musicList[SEQ_EVENT_CUTSCENE_COLLECT_STAR] = splatIdolsOldStarCond and 3 or 2 -- Sets "Star Collect" theme.
	
	if HAS_CHAR_SELECT then
		local modelId = _G.charSelect.character_get_current_number(0)
		local idolID = ((modelId == shiverCharID or modelId == fryeCharID or modelId == bigmanCharID) and 4) or ((modelId == pearlCharID or modelId == marinaCharID) and 2) or 0 -- Sets Power-Up theme.
		musicList[SEQ_EVENT_POWERUP] = 8 + idolID
		musicList[SEQ_EVENT_METAL_CAP] = 9 + idolID
	end
	
	local currMusic = cusMusic[cusMusIndex]
	
	if not cusMusHasStarted then return end
	
	local m = gMarioStates[0]
	local nearestBowser = obj_get_nearest_object_with_behavior_id(o, id_bhvBowser)
	local fadeMusicCond = (cusMusIndex == 1 and nearestBowser and nearestBowser.oHealth <= 0) or (cusMusIndex > 7 and m.capTimer <= 60) or false
	
	if not fadeMusicCond then
		if (HAS_CHAR_SELECT and _G.charSelect.is_menu_open()) or is_game_paused() then -- Is [CS] menu open or is the game paused?
			audio_stream_pause(currMusic)
			if cusMusPausePos == 0 then
				cusMusPausePos = audio_stream_get_position(currMusic) -- Have to "pause" this way because normal pausing just restarts the song for some reason.
			end
		elseif cusMusPausePos ~= 0 then
			audio_stream_play(currMusic, false, 1)
			audio_stream_set_position(currMusic, cusMusPausePos)
			cusMusPausePos = 0
		end
	else
		local currVolume = audio_stream_get_volume(currMusic)
		if currVolume > 0 then
			if cusMusIndex == 1 then -- Replicates a similar effect from when you defeat DJ Octavio in Splatoon 1.
				if currVolume == 1 then
					cusMusPausePos = audio_stream_get_position(currMusic)
				end
				audio_stream_set_volume(currMusic, currVolume - 0.00625) -- Fade audio.
				if audio_stream_get_position(currMusic) > cusMusPausePos + (0.2 * audio_stream_get_volume(currMusic)) then
					audio_stream_set_position(currMusic, cusMusPausePos)
				end
			else
				audio_stream_set_volume(currMusic, currVolume - 0.0166666667) -- Fade audio.
			end
		else
			audio_stream_stop(currMusic)
		end
	end
end)