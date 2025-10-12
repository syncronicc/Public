---
--@class RoundSystem.lua
---

--# Types

export type Constructor={
	new:({[number]:{
		Name:string;
		Timer:number
	}}|{},Loop:boolean)->RoundManager
};

export type RoundManager={
	CurrentState:{
		Name:string;
		Timer:number
	};
	RoundData:{
		Timer:number;
		Title:string;
	};

	destroyed:boolean;
	looped:boolean;

	--signals
	
	StateBegan:Signal;
	StateEnded:Signal;
	
	RoundEnded:Signal;
	Ticked:Signal;

	--array+
	players:{Player}|{};
	
	--functions
	
	SetState:(self:RoundManager,StateValue:string)->boolean;
	GetState:(self:RoundManager)->{
		Name:string;
		Timer:number
	};
	Destroy:(self:RoundManager)->();
}
type Signal={
	_connections:{(...any)									->()};

	Disconnect:()->();

	Connect:(self:Signal,fn:(...any)						->())->{Disconnect:()->()};
	Fire:(self:Signal,...any)								->();
}

--# Services

local Players=game:GetService("Players")

--# Variables

local default=require(script.default)
local binder=require(script.binder)

local resume=coroutine.resume
local create=coroutine.create

local insert=table.insert
local remove=table.remove
local clear=table.clear
local sort=table.sort
local find=table.find

--# Helper Functions

local function GetIndexFromDict(dict,v)
	for dest,dict_value in dict do
		if dict_value==v or dict_value.Name==v then
			return dest
		end
	end
end
local function GetDictionaryAmount(dict)
	local total=0;
	for _ in dict do
		total+=1
	end
	return total
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

--# Manager Class

local manager={}
manager.__index=manager

function manager:__StartRunHandler()
	resume(create(function()
		task.wait(2)
		while true do
			if self.destroyed==true then
				break
			end

			self.StateBegan:Fire(self.CurrentState.Name)

			local currentState=self.CurrentState
			local current=self.__StateIndex

			local forced=false
			for i=currentState.Timer,0,-1 do
				if self.destroyed==true then
					forced=true
					break
				end
				if current~=self.__StateIndex then
					forced=true
					break
				end

				self.RoundData={
					Timer=i;
					Title=currentState.Name
				}

				self.Ticked:Fire(self.RoundData)

				task.wait(1)
			end

			if forced==false then
				--# Passing to the next state;

				if self.__StateIndex+1>GetDictionaryAmount(self.__States)then
					if self.looped==true then
						self.__StateIndex=1
					else
						if self.destroyed==true then
							break
						end
						
						self.RoundEnded:Fire()
						self:Destroy()
					end

				else
					self.__StateIndex+=1
				end

				self.CurrentState=self.__States[self.__StateIndex]
			end

			self.StateEnded:Fire(self.players,forced)
		end
	end))
end

function manager:SetState(name)
	local dest=GetIndexFromDict(self.__States,name)do
		if not dest then
			return false
		end
		
		self.__StateIndex=dest
		self.CurrentState=self.__States[dest]
	end
	
	return true
end
function manager:GetState()
	return self.CurrentState
end

function manager.new(states:{
		[number]:{
			Name:string;
			Timer:number;
	}},Loop:boolean):RoundManager
	
	local self=setmetatable({},manager)do
		--# Private Variables
		self.__StateIndex=1
		self.__States=(states==nil or next(states)==nil)and default or states
		
		self.__signals={
			self.RoundEnded;
			self.Ticked;
			self.StateBegan;
			self.StateEnded;
		}
		
		--# Public Variables
		self.CurrentState=self.__States[self.__StateIndex]
		self.RoundData={
			Timer=0;
			Title='N/A';
		}
		
		self.destroyed=false
		self.players={}
		self.looped=Loop
		
		--# Signals
		self.StateBegan=signal.new();
		self.StateEnded=signal.new();
		
		self.RoundEnded=signal.new();
		self.Ticked=signal.new();
	end
	
	for _,plr in Players:GetPlayers()do
		insert(self.players,plr)
	end
	
	self:__StartRunHandler()
	
	return self
end
function manager:Destroy()
	assert(self.destroyed==true,'The round system is already destroyed!')
	
	for _,signal in self.__signals do
		signal:Disconnect()
	end
	
	clear(self)
	self.destroyed=true
end

return table.freeze(manager::Constructor)