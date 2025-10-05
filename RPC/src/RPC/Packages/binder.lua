--!strict

--# Variables

local ReplicatedStorage=game:GetService('ReplicatedStorage')
local RunService=game:GetService("RunService")
local Players=game:GetService("Players")

local binder={}

local remove=table.remove
local insert=table.insert

--# Types

export type Constructor={
	BindPlayerAdded:()->Signal;
	BindCharacterAdded:()->Signal
}
type Signal={
	_connections:{(...any)									->()};

	Disconnect:()->();

	Connect:(self:Signal,fn:(...any)						->())->{Disconnect:()->()};
	Fire:(self:Signal,...any)								->();
}

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

--# Binder

function binder.BindPlayerAdded()
	local new=signal.new()

	Players.PlayerAdded:Connect(function(plr)
		new:Fire(plr,true)
	end)
	Players.PlayerRemoving:Connect(function(plr)
		new:Fire(plr,false)
	end)

	for _,plr in Players:GetPlayers()do
		new:Fire(plr,true)

		task.wait()
	end

	return new
end
function binder.BindCharacterAdded()
	local added={}
	local new=signal.new()

	binder.BindPlayerAdded():Connect(function(player,state)
		if state==false then
			if added[player] then
				added[player]:Disconnect()
				added[player]=nil
			end
		else
			new:Fire(player,(player.Character or player.CharacterAdded:Wait()))

			added[player]=player.CharacterAdded:Connect(function(char)
				new:Fire(player,char)
			end)
		end
	end)

	return new
end

return table.freeze(binder::Constructor)