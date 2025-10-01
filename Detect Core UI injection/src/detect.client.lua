----
--# Made by kts on 2/4/2023; Place in player scripts!
----

local ContentProvider=game:GetService("ContentProvider")
local CoreUI=game:GetService("CoreGui")

local VoiceChatEnabled=false
local Ignoreable={"rbxassetid://10066921516","rbxassetid://11702779409"}-- removing these will cause the player to get kicked [ ~ 90% ]

ContentProvider:PreloadAsync({CoreUI},function(assetid,status)
	if not table.find(Ignoreable,assetid)and assetid:find("rbxassetid://")then
		local assetId = assetid:gsub("rbxassetid://","")
		if assetId and not VoiceChatEnabled then
			print(assetId)
			print("Anticheat flag: Coregui Script Detected x51823z")
			return
		elseif VoiceChatEnabled and assetId then
			print("Anticheat flag: Possible Coregui Script x9182455")
			return
		end
	end
end)
