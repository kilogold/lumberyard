local BallController =
{
	Properties =
	{
		fired = false
	}
}

function BallController:OnActivate()
	local fireID = GameplayNotificationId(self.entityId, "ShootBall")
    self.fireHandler = GameplayNotificationBus.Connect(self, fireID)
end


function BallController:OnEventBegin(value)
	-- Input event
	if(self.Properties.fired == false) then
		self.Properties.fired = true
		local vec = Vector3(-200,0,0)
		PhysicsComponentRequestBus.Event.AddImpulse(self.entityId, vec)
	end 
end

return BallController