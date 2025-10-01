--!native

--[[
	GPT made this readme :3
    -----------------
    Author: KTS, Romania
    Description:
        This Roblox project leverages a **parallel loader** to optimize
        module and asset initialization, improving game startup performance.
        It also integrates various **open-source tools** to streamline development
        and provide additional functionality.
--]]

--[[ 
    Features:
    - Parallel Loader:
        Loads modules, assets, and scripts concurrently to minimize startup time.
    - Open-Source Integration:
        Utilizes community-supported libraries and tools for enhanced functionality.
    - Modular Design:
        Modules can be added or removed easily without modifying core scripts.
    - Lightweight & Efficient:
        Optimized for performance with minimal overhead.
--]]

--[[ 
    Notes:
    - This project is intended for personal and private use.
    - Moral rights are reserved by KTS, Romania.
--]]

local RunService=game:GetService("RunService")
if RunService:IsServer()then
	script.kernel.Actor.boot.loader.Enabled=true -- simple signal loader;
end

return{}