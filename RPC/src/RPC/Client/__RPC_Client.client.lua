local MarketplaceService=game:GetService("MarketplaceService")
local ReplicatedStorage=game:GetService('ReplicatedStorage')
local Players=game:GetService("Players")

local Remotes=ReplicatedStorage:WaitForChild('__RPC_Remotes')

local player=Players.LocalPlayer

Remotes:WaitForChild(`{player:GetAttribute("__RPC_ID")}`).OnClientEvent:Connect(function(id,category)
	if category=='Gamepasses'then
		MarketplaceService:PromptGamePassPurchase(player,id)
	elseif category=='Products' then
		MarketplaceService:PromptProductPurchase(player,id)
	end
	
end)