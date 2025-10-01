-- FULL CREDITS TO: https://github.com/Naketm/Dictionary-module/blob/main/Dictionary_Module.luau
-- he king fr

--!str

local dict = {}
local frozenDicts = setmetatable({}, { __mode = "k"})

-- SERVICES
local RunService = game:GetService("RunService")

-- TYPES
type Dictionary<K, V> = {[K]: V}
type Func<K, V, R> = (K, V) -> R
type FilterFunc<K, V> = (K, V) -> boolean

-- CLASSES
local signal = {}
signal.__index = signal

function signal.new()
	return setmetatable({_connections = {}}, signal)
end

function signal:Connect(fn)
	table.insert(self._connections, fn)
	return {
		Disconnect = function()
			for i, v in self._connections do
				if v == fn then
					table.remove(self._connections, i)
				end
			end
		end
	}
end

function signal:Fire(...)
	for _, fn in self._connections do
		fn(...)
	end
end

-- DOCUMENTATION
-- MADE BY [NAKETM] on discord or [jax0518] on roblox!!
-- Contact if any issues

-- Binding will attach the module to your dictionary, basically super-powering it!

-- weakMode has three statements, key, value and key & value. 
-- This applies robloxs weak table to it and allows it to be automatically cleaned up next GC to avoid memory leaks
-- IT WILL ONLY CLEAN UP WHAT YOU TELL IT TO CLEAN UP!! setting it to [K] will apply weak to only the keys.

-- You are able to get onChanged signals to detect when the Dictionary has been changed, 
-- REMEMBER TO USE RAWSET TO AVOID INFINITE LOOPS OR IF YOU DON'T WANT IT TO BE DETECTED!!!
-- It will return the key and the value being changed!

-- current functions..

--[[
i have binding, find, merge, clear, clone, concat_key, concat_value, create, 
maxn, insert, min, move, reconcile, remove, freeze, unfreeze, len, filter, 
map, map_key, filter_key, isWeak, weak, reverse, difference, slice, rawset,
mapParallel, filterParallel

You must input the function as a string for both mapParallel and filterParallel as they use loadstring
]]

--[[
EXAMPLE CODE

local dict = require(script.Dictionary)

local Data = {
	["Hello_World_1"] = 1,
	["Hello_World_2"] = 2,
	["Hello_World_3"] = 3,
	["Hello_World_4"] = 4,
	["Hello_World_5"] = 5,
	["Hello_World_6"] = 6,
	["Hello_World_7"] = 7,
	["Hello_World_8"] = 8,
}

dict.bind(Data)

Data.Changed:Connect(function(k,v)
	print(k,v)
end)

print(Data)

Data.Hello_World_1 = 10

VERY SORRY INTELLISENSE USERS!!

]]

--[[

You must use double brackets to input functions as they must be represented as a string. 

local dict = require(script.Dictionary)
local data = {}

for i = 1, 10000 do
	data["Player" .. i] = {
		level = math.random(1, 100),
		coins = math.random(100, 10000),
		score = math.random(1000, 50000)
	}
end

local EvenPlayers = dict.filterParallel(data, 
	function(name, pdata)
		return pdata.level % 2 == 0
	end
, 4)

local squared_players = dict.mapParallel(data,
	function(name, pdata)
		return {
			pdata.level ^ 2,
			pdata.coins,
			pdata.score
		}
	end
, 4)

print(EvenPlayers)
print(squared_players)

]]

local WorkerTemplate = script.DictionaryWorker

local function UndoSlice(slice: {{any}}): Dictionary<any, any>
	local dict = {}
	for _, pair in slice do
		local key, value = pair[1], pair[2]
		if key ~= nil and value ~= nil then
			dict[key] = value
		end
	end

	return dict
end

function dict.processParallel(tbl: Dictionary<K, V>, fnString: string, operation: string, n: number)
	local slices = dict.slice(tbl, n)
	local shared_results = SharedTable.new()
	local actors = {}
	local chunks = {}
	local completed = 0

	for i, slice in slices do

		local actor = Instance.new("Actor")
		actor.Name = "Dictionary_Actor_" .. i
		actor.Parent = script

		local worker = WorkerTemplate:Clone()
		worker.Name = "Worker_" .. i
		worker.Parent = actor
		worker.Enabled = true
		worker:SetAttribute("Operation", operation)

		table.insert(actors, actor)
	end

	task.wait()

	for i, actor in actors do
		local chunk = UndoSlice(slices[i])
		actor:SendMessage("Work", chunk, fnString, i, shared_results)
	end

	repeat task.wait() until dict.len(shared_results) == #slices

	local results = {}

	for sliceIndex, slice_result in shared_results do
		actors[sliceIndex]:Destroy()
		for k, v in slice_result do
			results[k] = v
		end
	end

	print("All slices completed. Merged results count:", dict.len(results))
	return results
end

function dict.mapParallel(tbl: Dictionary<any, any>, fn: string, n: number?)
	return dict.processParallel(tbl, fn, "map", n or math.min(#tbl, 8))
end

function dict.filterParallel(tbl: Dictionary<any, any>, fn: string, n: number?)
	return dict.processParallel(tbl, fn, "filter", n or math.min(#tbl, 8))
end

function dict.bind(tbl: Dictionary<K, V>?, weakMode: "k"|"v"|"kv"?): Dictionary<K, V>
	local raw = tbl or {} :: Dictionary<K, V>

	local mt = {
		__index = function(self, key: K)
			if key == 'Changed' then
				if not rawget(self, '_ChangedSignal') then
					rawset(self, '_ChangedSignal', signal.new())
				end
				return rawget(self, '_ChangedSignal')
			elseif key == 'rawset' then
				return function(_, k, v)
					rawset(self, k, v)
				end
			end
			return rawget(self, key)
		end,
		__newindex = function(self, key: K, value: V)
			if frozenDicts[self] then
				error("frozen dictionary", 2)
			end
			rawset(self, key, value)
			local changedSignal = rawget(self, '_ChangedSignal')
			if changedSignal then
				changedSignal:Fire(key, value)
			end
		end,
	}

	if weakMode then
		mt.__mode = weakMode
	end

	setmetatable(raw, mt)
	return raw :: Dictionary<K, V>
end

function dict.find(tbl: Dictionary<K, V>, v:any, key_check: string): string
	for name, key in tbl do
		if key == v then
			return name
		elseif name == key_check then
			return key
		end
	end

	return nil
end

function dict.merge(merge_table_1: Dictionary<K, V>, merge_table_2: Dictionary<K, V>): Dictionary<K, V>
	for i, v in merge_table_2 do
		merge_table_1[i]  = v
	end
end

function dict.clear(tbl: Dictionary<K, V>): ()
	for i,v in tbl do
		v = nil
	end
end

function dict.clone(tbl: Dictionary<K, V>): Dictionary<K, V>
	local copied_tbl = {} :: Dictionary<K, V>

	for i, v in tbl do
		copied_tbl[i] = v
	end

	return copied_tbl
end

-- ignore the concat functions, i have to rework these to accept all parameters but they are partially functionable
function dict.concat_key(tbl: Dictionary<K, V>, sep: string, i: number, j: number): string
	local start: string = 1 or i
	local finish: number | nil = nil or j
	local increment: number = 1 
	local concat = {}

	for i, v in tbl do
		if increment ~= start then
			increment += 1
			continue
		elseif finish ~= nil then
			if increment <= finish then
				start += 1
				increment += 1

				table.insert(concat,i)
			else
				break
			end
		elseif finish == nil then
			increment += 1
			start += 1

			table.insert(concat,i)
		end
	end


	return table.concat(concat, sep)
end

function dict.concat_value(tbl: Dictionary<K, V>, sep: string, i: number, j: number): string
	local start: string = 1 or i
	local finish: number | nil = nil or j
	local increment: number = 1
	local concat = {}

	for i, v in tbl do
		if increment ~= start then
			increment += 1
			continue
		elseif finish ~= nil then
			if increment <= finish then
				start += 1
				increment += 1

				table.insert(concat,i)
			else
				break
			end
		elseif finish == nil then
			increment += 1
			start += 1

			table.insert(concat,v)
		end
	end


	return table.concat(concat, sep)
end

function dict.create(count: number, key: string, value: any): {}
	local dictionary: Dictionary<K, V> = {}

	for i = 1, count do
		dictionary[key] = value
	end
	
	return dictionary
end

function dict.insert(tbl: Dictionary<K, V>, key: string, value: any): ()
	tbl[key] = value
	return tbl
end

function dict.maxn(tbl: table): number
	local Highest_Number: number? = nil


	for i, v in tbl do
		if type(v) == "number" then
			if Highest_Number == nil or Highest_Number < v then
				Highest_Number = v
			end
		end
	end

	return Highest_Number
end

function dict.min(tbl: table): number
	local Lowest_Number: number? = nil


	for i, v in tbl do
		if type(v) == "number" then
			if Lowest_Number == nil or Lowest_Number > v then
				Lowest_Number = v
			end
		end
	end

	return Lowest_Number
end

function dict.move(src: Dictionary<K, V>, keys: table, dst: Dictionary<K, V>): Dictionary<K, V>
	for i, v in src do
		if dict.find(keys,i) then
			dst[i] = v
		end
	end
end

function dict.reconcile(src: Dictionary<K, V>, defaults: Dictionary<K, V>): Dictionary<K, V>
	for k, v in defaults do
		if src[k] == nil then
			t[k] = v
		end
	end
end

function dict.remove(tbl: Dictionary<K, V>, key: string)
	tbl[key] = nil
end

function dict.freeze(tbl: Dictionary<K, V>)
	frozenDicts[tbl] = true
end

function dict.unfreeze(tbl: Dictionary<K, V>)
	frozenDicts[tbl] = false
end

function dict.len(tbl: Dictionary<K, V>): number?
	function dict.len(tbl)
		if typeof(tbl) == "table" then
			local increment = 0

			for _ in tbl do 
				increment += 1 
			end

			return increment
		elseif typeof(tbl) == "SharedTable" then
			return SharedTable.size(tbl)
		end
	end
end

function dict.filter<K, V>(tbl: Dictionary<K, V>, fn: FilterFunc<K, V> ): Dictionary<K,V>
	local result = {} :: Dictionary<K, V>
	for k, v in tbl do
		if fn(k, v) then
			result[k] = v
		end
	end
	return result
end

function dict.map<K, V, R>(tbl: Dictionary<K, V>, fn: Func<K, V, R>): Dictionary<K, R>
	local result = {} :: Dictionary<K, V>
	for k, v in tbl do
		result[k] = fn(k, v)
	end
	return result
end

function dict.mapKeys(tbl: Dictionary<K, V>, fn: Func<K, V, R>): Dictionary<K, R>
	local result = {} :: Dictionary<K, V>
	for k,v in tbl do
		result[fn(k)] = v
	end
	return result
end

function dict.filterKeys(tbl: Dictionary<K, V>, fn: FilterFunc<K, V>): Dictionary<K, V>
	local result = {} :: Dictionary<K, V>
	for k,v in tbl do
		if fn(k) then 
			result[k] = v 
		end
	end
	return result
end

function dict.isWeak(tbl: Dictionary<K, V>): any
	local mt = getmetatable(tbl)
	return mt and mt.__mode or false
end

function dict.reverse(tbl: Dictionary<K, V>): Dictionary<K, V>
	for i, v in tbl do
		local p_v = v
		local p_i = i

		tbl[i] = nil

		tbl[p_v] = p_i
	end
end

function dict.difference(tbl: Dictionary<K, V>, tbl2: Dictionary<K, V>): Dictionary<K, V>
	local result = {} :: Dictionary<K,V>

	for i,v in tbl do
		if table.find(tbl2, v) then
			continue
		else
			result[i] = v
		end
	end

	return result
end

function dict.slice(tbl: Dictionary<K, V>, actor_count: number): {{any}}
	assert(actor_count >= 1, "Actor count must be over 1")
	local slices = {}
	for j = 1, actor_count do
		slices[j] = {}
	end

	local i = 1
	for k, v in tbl do
		local chunk = slices[i]
		chunk[#chunk+1] = {k, v}

		i += 1
		if i > actor_count then 
			i = 1 
		end
	end

	return slices
end

return dict