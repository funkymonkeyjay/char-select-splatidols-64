incompatibilityCond = false
local messages = {}

local MOD_NAME = "\\#D9D9D9\\\"[CS+PET] Spla\\#7DFF32\\t\\#D9D9D9\\Idol\\#7DFF32\\s \\#FF4CBD\\64\\#D9D9D9\\\""
local VERSION_REQUIRED = 41
local CS_VERSION_REQUIRED = 16

if VERSION_NUMBER < VERSION_REQUIRED then
	table.insert(messages, "\n" .. MOD_NAME .. "\nRequires the latest version of\n\"SM64 Co-op DX\"!\n\nPlease update the Executable\nand Host a new Room!\\#FF7F7F\\\nVersion " .. tostring(VERSION_NUMBER) .. " < " .. tostring(VERSION_REQUIRED))
	incompatibilityCond = true
end

local csVersion = _G.charSelect and _G.charSelect.version_get_full()

if _G.charSelectExists and csVersion and csVersion.api == 1 and csVersion.major < CS_VERSION_REQUIRED then
	local verBase = tostring(csVersion.api) .. "." .. tostring(csVersion.major) .. "." .. tostring(csVersion.minor)
	local verWanted = "1." .. tostring(CS_VERSION_REQUIRED) .. ".0"
	table.insert(messages, "\n" .. MOD_NAME .. "\nRequires the latest version of \"Character Select\"!\n\nPlease update the Mod\nand Host a new Room!\\#FF7F7F\\\nVersion " .. verBase .. " < " .. verWanted)
	incompatibilityCond = true
end

if incompatibilityCond then
    local frameCount = 0
    hook_event(HOOK_UPDATE, function ()
        frameCount = frameCount + 1
        if frameCount == 5 then
			for i = 1, #messages do
				message = messages[i]
				djui_popup_create(message, 6)
			end
        end
    end)
	return 0
end
