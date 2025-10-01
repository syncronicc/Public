local actor = script.Parent
local operation = script:GetAttribute("Operation") or "filter"

actor:BindToMessageParallel("Work", function(chunk, fnSource, SliceIndex, SharedResults)
	local success, err = pcall(function() return loadstring("return "..fnSource)() end)
	if not success or type(err) ~= "function" then
		warn("Loadstring failed", success, tostring(err))
		SharedResults[SliceIndex] = {}
		return
	end

	local output = {}
	if operation == "map" then
		for k, v in chunk do
			output[k] = err(k, v)
		end
	else
		for k, v in chunk do
			if err(k, v) then
				output[k] = v
			end
		end
	end

	task.synchronize()
	SharedResults[SliceIndex] = output
end)