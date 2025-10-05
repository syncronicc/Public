---
--@class RPC.lua
---

--!strict
--# Types
export type Constructor={
	Cache:{Signal};
	Purchases:{};
	TotalRobux:number;
	
	Purchase:(player:Player,name:string)->(Signal)
}

type Item=any

type RPC_Constructor={
	new:()->Constructor;
	Purchase:(new:Constructor,player:Player,name:string)->(Signal)
}

type PurchaseInfo={player:Instance,assetId:number,isPurchased:boolean}
type Purchase=(self:Constructor,player:Player,name:Item)	->();
type Signal={
	_connections:{(...any)									->()};
	
	Disconnect:()->();
	
	Connect:(self:Signal,fn:(...any)						->())->{Disconnect:()->()};
	Fire:(self:Signal,...any)								->();
}


--# Variables

local MarketplaceService=game:GetService("MarketplaceService")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local HttpService=game:GetService('HttpService')

local Monetization=script.Monetization
local Packages=script.Packages
local Client=script.Client

local insert=table.insert
local remove=table.remove

local ids={
	['Gamepasses']=require(Monetization.Gamepasses);
	['Products']=require(Monetization.Products);
}


--# Modules

local Callbacks=require(Monetization.Callbacks)

local PlayerBinder=require(Packages.binder)
local Promise=require(Packages.promise)


--# Init

local folder=ReplicatedStorage:FindFirstChild('__RPC_Remotes')or Instance.new('Folder')do
	folder.Parent=ReplicatedStorage
	folder.Name='__RPC_Remotes'
end

--# Utils

function Call(info:PurchaseInfo)
	if info.isPurchased==false then
		return false
	end

	local success,result=xpcall(function()
		return Promise.try(function(resolve,reject)
			if not Callbacks[info.assetId]then
				return false
			end
			
			Callbacks[info.assetId](info.player) 
			
			return true
		end)
	end,function()
		return warn('Failed to process receipt!')
	end)

	if not success then
		return false
	end

	return true
end

function FindItemByName(name:Item)
	for _,n in {'Gamepasses','Products'} do
		local category=ids[n]
		
		if not category then
			continue
		end
		
		for item,id in category do
			if item==name then
				return id,n::'Gamepasses'|'Products'|unknown
			end
		end
	end
	
	return nil
end


--# Signal Class

local signal={}
signal.__index=signal

function signal.new()
	return setmetatable({
		_connections={}::{(...any)->()};
		
		Disconnect=function(self:Signal)
			for i:number, v in self._connections do
				remove(self._connections,i)
			end
		end,
	}::Signal,signal)
end

function signal.Connect(self:Signal,fn)
	insert(self._connections, fn)
	
	return{
		Disconnect=function(self:Signal)
			for i:number, v in self._connections do
				if v == fn then
					remove(self._connections,i)
				end
			end
		end
	}
end

function signal.Fire(self:Signal,...:any)
	for _, callback in self._connections do
		callback(...)
	end
end


--# Constructor

local rpc={}
rpc.__index=rpc

function rpc.new():Constructor
	local self=setmetatable({
		Purchases={};
		Cache={};

		TotalRobux=0;
	},rpc)::Constructor
	
	local Connections={}::{RBXScriptConnection}
	
	local GUID:string=HttpService:GenerateGUID()
	local remote=Instance.new('RemoteEvent')do
		remote.Parent=folder
		remote.Name=GUID
	end
	

	PlayerBinder.BindPlayerAdded():Connect(function(player:Player,state)
		if state==false then
			return
		end

		local new=Client.__RPC_Client:Clone()do
			new.Parent=player.PlayerGui
			
			player:SetAttribute('__RPC_ID',GUID)

			new.Enabled=true
		end
	end)
	
	MarketplaceService.ProcessReceipt=function(info:PurchaseInfo)
		local success=Call(info)
		
		if not success then
			return Enum.ProductPurchaseDecision.NotProcessedYet
		end
		
		return Enum.ProductPurchaseDecision.PurchaseGranted
	end
	
	MarketplaceService.PromptGamePassPurchaseFinished:Connect(function(Player,id,isPurchased)
		local success=Call({
			player=Player;
			assetId=id;
			isPurchased=isPurchased
		})
		
		if success==true and self.Cache[id]then
			self.Cache[id]:Fire()
			self.Cache[id].Disconnect()
			
			self.Cache[id]=nil
		end
	end)
	
	return self
end
function rpc:Purchase(player:Player,name:Item):Signal|false
	if not player then
		task.wait(.1)
	end
	
	local item,category=FindItemByName(name)
	
	if not item then
		return false
	end
	
	local remote=folder:FindFirstChild(tostring(player:GetAttribute('__RPC_ID')))::RemoteEvent
	local new=signal.new()
	
	if not remote then
		local attempt,max=0,5
		
		repeat task.wait(1)attempt+=1 until attempt>=max or folder:FindFirstChild(player:GetAttribute("__RPC_ID"))
		
		if attempt>=max then
			return false
		else
			remote=folder:FindFirstChild(tostring(player:GetAttribute('__RPC_ID')))::RemoteEvent
		end
	end
	
	task.delay(.1,function()
		remote:FireClient(player,item,category)
	end)
	
	self.Cache[item]=new
	
	return new
end


return table.freeze(setmetatable({},rpc)::RPC_Constructor)