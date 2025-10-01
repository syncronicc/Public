--@class boot.lua
--@brief: simple server-only framework for basic stuff.
--!native

--# Services

local AnalyticsService=game:GetService("AnalyticsService")
local Players=game:GetService('Players')

--# Misc

local actor=script.Parent

--# Folders

local Services=actor.Parent.Parent.Services
local Kernel=script.Parent.Parent
local Parent=actor.Parent.Parent
local Assets=Parent.Assets
local Shared=Assets.Shared

--# Modules

local Dictionary=require(Shared.Dictionary)

local send_actor=require(Kernel.send_actor).new(actor)
local config=require(Parent.config)

local boot={}

function boot.init(startupTick,config)
	local FinishedLoading=false
	local dict=Dictionary.create(1,'loaded',true)
	
	local function __AddService(name:string,contents)
		if contents.Name==nil then
			return
		end
		if Dictionary.find(dict,name)then
			return
		end
		
		Dictionary.insert(dict,contents.Name,Dictionary.create(1,'__content',contents))
		
		local init=(type(contents)=="table")and(type(contents["init"])=="function")
		local success,res=xpcall(function()
			return contents['init'](send_actor)
		end,function()
			return warn(`Failed to create service: {name}!!`)
		end)
	end
	local function __GetService(name:string,__signal)
		if FinishedLoading~=true then
			repeat task.wait()until FinishedLoading==true
		end
		
		local service=Dictionary.find(dict,_,name)

		if service==nil then
			__signal:Fire(setmetatable({},{
				__index=function()
					return nil
				end,
				__call=function()
					return nil
				end,
			}),false)
		end
		
		__signal:Fire(service.__content or service,true)
	end

	--# Actor Methods
	actor:BindToMessageParallel('AddService',__AddService)
	actor:BindToMessageParallel('GetService',__GetService)
		
	--# Returning the loader.
	return function()
		
		--# Loader

		for _,module in(config.deep and Services:GetDescendants())or Services:GetChildren()do
			if not module:IsA('ModuleScript')then
				continue
			end

			task.defer(__AddService,module.Name,require(module)) -- anti-yield method + protected call.
		end
		
		task.wait()
		FinishedLoading=true
	end
end

return table.freeze(boot)