-- \ Fly \ --

-- Please read the following explanation about how to use this utility:

--[[ To use this, loadstring it and make it a variable, the variable will be a table containing the following:
    IsFlyEnabled: A boolean indicating if fly is currently enabled.
    BodyGyro: A BodyGyro instance in the HumanoidRootPart, created when Fly:Start() is called, otherwise nil.
    BodyVelocity: A BodyVelocity instance in the HumanoidRootPart, created when Fly:Start() is called, otherwise nil.
    Connection: Connection to the RunService.RenderStepped signal, this connection handles the actual flying.
    FlySpeed: Fly speed, defaults to 30. If you have a slider for this, make sure to update Fly.FlySpeed with the slider accordingly.
    SpaceShiftEnabled: If Space should make the player go straight up and if Left Shift should do the opposite. This can be disabled.
    ShouldPlatformStand: If Humanoid.PlatformStand should be on when fly is on, and off when fly is off.
    Fly:Start(): A function that, when called, will turn flying on.
    Fly:Stop(): A function that, when called, will turn flying off.
    Fly:Toggle(): A function toggling the current state of flying (e.g if it was previously off, calling Fly:Toggle() would turn it on).
    Fly:Set(value: boolean): A function that enables or disables flying depending on the value given.
--]]

--[[ Read this:
   This fly wasn't made to be all that much.
   The good scripts with Fly generally use MoveVector, I was too lazy to do that. This is a side-project I made for a private GUI.
]]

if getgenv().Divined and getgenv().Divined.Fly then
     return getgenv().Divined.Fly
end

local Players: Players = cloneref(game:GetService("Players"))
local RunService: RunService = cloneref(game:GetService("RunService"))
local UserInputService: UserInputService = cloneref(game:GetService("UserInputService"))
local LocalPlayer = Players.LocalPlayer
local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local HRP = char:WaitForChild("HumanoidRootPart", math.huge)
local Camera = workspace.CurrentCamera
local Fly = {
	IsFlyEnabled = false,
	BodyGyro = nil,
	BodyVelocity = nil,
	Connection = nil,
	FlySpeed = 30,
	SpaceShiftEnabled = true,
	ShouldPlatformStand = false,
}
local Toggling, Setting = false, false
function Fly:Start()
	if self.IsFlyEnabled and (not Toggling and not Setting) then
		return
	end

	self.IsFlyEnabled = true

	self.BodyGyro = Instance.new("BodyGyro", HRP)
	self.BodyVelocity = Instance.new("BodyVelocity", HRP)
	self.BodyGyro.P = 9e4
	self.BodyGyro.MaxTorque = Vector3.one * 9e9
	self.BodyGyro.CFrame = Camera.CFrame
	self.BodyVelocity.Velocity = Vector3.zero
	self.BodyVelocity.MaxForce = Vector3.one * 9e9

	self.Connection = RunService.RenderStepped:Connect(function()
		if not self.IsFlyEnabled then
			self.Connection:Disconnect()
		end

		if self.ShouldPlatformStand then
			char.Humanoid.PlatformStand = true
		end
		local direction = Vector3.new(0, 0, 0)

		if not UserInputService:GetFocusedTextBox() then
			if UserInputService:IsKeyDown(Enum.KeyCode.W) then
				direction += (Camera.CFrame.LookVector * self.FlySpeed)
			end

			if UserInputService:IsKeyDown(Enum.KeyCode.S) then
				direction -= (Camera.CFrame.LookVector * self.FlySpeed)
			end

			if UserInputService:IsKeyDown(Enum.KeyCode.A) then
				direction -= (Camera.CFrame.RightVector * self.FlySpeed)
			end

			if UserInputService:IsKeyDown(Enum.KeyCode.D) then
				direction += (Camera.CFrame.RightVector * self.FlySpeed)
			end

			if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) and self.SpaceShiftEnabled then
				direction -= (Camera.CFrame.UpVector * self.FlySpeed)
			end

			if UserInputService:IsKeyDown(Enum.KeyCode.Space) and self.SpaceShiftEnabled then
				direction += (Camera.CFrame.UpVector * self.FlySpeed)
			end
		end

		self.BodyVelocity.Velocity = direction
		self.BodyGyro.CFrame = Camera.CFrame
	end)
end

function Fly:Stop()
	self.IsFlyEnabled = false

	if self.Connection then
		self.Connection:Disconnect()
	end

	if self.BodyGyro then
		self.BodyGyro:Destroy()
		self.BodyGyro = nil
	end

	if self.BodyVelocity then
		self.BodyVelocity:Destroy()
		self.BodyVelocity = nil
	end

	if self.ShouldPlatformStand then
		char.Humanoid.PlatformStand = false
	end
end

function Fly:Toggle()
	self.IsFlyEnabled = not self.IsFlyEnabled
	Toggling = true

	if self.IsFlyEnabled then
		Fly:Start()
	else
		Fly:Stop()
	end

	Toggling = false
end

function Fly:Set(value: boolean)
	self.IsFlyEnabled = value
	Setting = true
	if value then
		Fly:Start()
	else
		Fly:Stop()
	end
	Setting = false
end
print("[Divined's Fly]: Loaded successfully!")
if not getgenv().Divined then
	getgenv().Divined = {} -- I plan on making more public utilities
end
getgenv().Divined.Fly = Fly
return Fly
