local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local LocalPlayer = game.Players.LocalPlayer
local Remotes = ReplicatedStorage:WaitForChild("events") -- Assuming the events are under 'events'

local AutoCastEnabled = true
local LastCastAttempt = 0
local CastDelay = 5  -- Adjust this to the desired time between casts

local function AutoCast()
	if AutoCastEnabled then
		local CurrentTool = LocalPlayer.Character:FindFirstChildOfClass("Tool")
		if not CurrentTool then return end

		local Values = CurrentTool:FindFirstChild("values")
		if not Values then return end

		local Events = CurrentTool:FindFirstChild("events")
		if not Events then return end

		-- Check if we are ready to cast
		if Values.casted.Value == false and tick() - LastCastAttempt > CastDelay then
			LastCastAttempt = tick()

			-- Trigger the cast animation
			local AnimationFolder = ReplicatedStorage:WaitForChild("resources"):WaitForChild("animations")
			local CastAnimation = LocalPlayer.Character:FindFirstChild("Humanoid"):LoadAnimation(AnimationFolder.fishing.throw)
			CastAnimation.Priority = Enum.AnimationPriority.Action3
			CastAnimation:Play()

			-- Fire the cast event to the server
			Events.cast:FireServer(100, 1)

			-- Play waiting animation after the cast is finished
			CastAnimation.Stopped:Once(function()
				CastAnimation:Destroy()

				local WaitingAnimation = LocalPlayer.Character:FindFirstChild("Humanoid"):LoadAnimation(AnimationFolder.fishing.waiting)
				WaitingAnimation.Priority = Enum.AnimationPriority.Action3
				WaitingAnimation:Play()

				-- Stop waiting animation when the cast is unequipped
				Values.casted.Changed:Once(function()
					WaitingAnimation:Stop()
					WaitingAnimation:Destroy()
				end)
			end)
		end
	end
end

-- Call AutoCast every 0.3 seconds
RunService.Heartbeat:Connect(function()
	AutoCast()
end)
