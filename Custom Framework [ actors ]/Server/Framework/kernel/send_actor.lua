local Parent=script.Parent.Parent
local Shared=Parent.Assets.Shared

local Signal=require(Shared.Signal)

local sender={}
sender.__index=sender

export type constructor={
	__actor:Actor;
}

function sender.new(actor:Actor)
	local self=setmetatable({},sender)do
		self.__actor=actor
	end
	
	--# Methods
	
	function self.GetService(self:constructor,name:string)
		local signal=Instance.new('BindableEvent')
		
		self.__actor:SendMessage('GetService',name,signal)
		
		return signal.Event:Wait()
	end
	function self.AddService(self:constructor,name:string,required)
		self.__actor:SendMessage('AddService',name,required)
	end
	
	--# Returning the sender.
	return table.freeze(self::constructor)-- table.freeze -> security purposes
end

return sender