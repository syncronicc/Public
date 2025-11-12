--!nonstrict
--!optimize 1
--!native

local ContentProvider=game:GetService('ContentProvider')

return{
	--@class Animate.lua
	--@params Model:Model
	new=function(model:Model)
		local Animations:{Animation}=model:FindFirstChild('Animations')
		local Animation:Animation=Animations:FindFirstChild('idle')
		local Animator:Animator?=
			model:FindFirstChild('AnimationController')and model:FindFirstChild('AnimationController'):FindFirstChild('Animator')or
			model:FindFirstChild('Humanoid')and model:FindFirstChild('Humanoid'):FindFirstChild('Animator')
		
		if ContentProvider:GetAssetFetchStatus(Animation.AnimationId)==Enum.AssetFetchStatus.Failure then
			return
		end
		if Animator and Animator:IsA('Animator')then
			local loaded=Animator:LoadAnimation(Animation)do
				loaded:Play()
			end
			
			return loaded
		end
	end,
	
	--@class Animate.lua
	--@method getAnimator
	--@desc Returns the Animator Instance
	--@return Animator
	getAnimator=function(model:Model):Animator
		return--@return Instance:Animator
			model:FindFirstChild('AnimationController')and model:FindFirstChild('AnimationController'):FindFirstChild('Animator')or
			model:FindFirstChild('Humanoid')and model:FindFirstChild('Humanoid'):FindFirstChild('Animator')
	end,
	
	--@class Animate.lua
	--@method cancel
	--@desc Cancels all playing animations
	--@return void
	cancel=function(model:Model)
		local Animator:Animator?=
			model:FindFirstChild('AnimationController')and model:FindFirstChild('AnimationController'):FindFirstChild('Animator')or
			model:FindFirstChild('Humanoid')and model:FindFirstChild('Humanoid'):FindFirstChild('Animator')
		if not Animator then
			return
		end
		
		for _,track in Animator:GetPlayingAnimationTracks()do
			track:Stop()
		end
	end,
}
