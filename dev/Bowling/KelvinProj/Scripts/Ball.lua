local Ball = 
{
	Properties = 
	{
		gutterWall = { default = EntityId() },
		pinSetup = { default = EntityId() },
		fired = false
	},
}

function Ball:OnActivate()
	local fireID = GameplayNotificationId(self.entityId, "ShootBall")
    self.fireHandler = GameplayNotificationBus.Connect(self, fireID)

	local resetId = GameplayNotificationId(EntityId(), "Reset")
	self.gameplayBus = GameplayNotificationBus.Connect(self, resetId)
	
	-- Table vars
	self.physicsHandler = PhysicsComponentNotificationBus.Connect(self, self.entityId)
	self.startPosition = TransformBus.Event.GetWorldTM(self.entityId)
end

function Ball:OnCollision(collision)
	if(collision.entity == self.Properties.gutterWall) then
		self.physicsHandler:Disconnect() -- only hit it once
		local id = GameplayNotificationId(EntityId(), "Goal")
		GameplayNotificationBus.Event.OnEventBegin(id, nil)
	end
end

function Ball:OnDeactivate()
	self.fireHandler:Disconnect()
	self.physicsHandler:Disconnect()
	self.gameplayBus:Disconnect()
end

function Ball:OnEventBegin(value)
	if(value == "Reset") then
		TransformBus.Event.SetWorldTM(self.entityId, self.startPosition)
		self.Properties.fired = false
		self.physicsHandler:Connect(self.entityId)
	else 
		-- Input event
		if(self.Properties.fired == false) then
			self.Properties.fired = true
			local vec = Vector3(0,1000,0)
			PhysicsComponentRequestBus.Event.AddImpulse(self.entityId, vec)
		end 
	end
end

function Ball:OnEventEnd(value)
end

return Ball;