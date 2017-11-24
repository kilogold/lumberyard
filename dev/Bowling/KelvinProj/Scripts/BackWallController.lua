local BackWallController =
{
	Properties =
	{
		PinSensorEntity = EntityId()
	}
}

function BackWallController:OnActivate()
	self.triggerHandler = TriggerAreaNotificationBus.Connect(self, self.entityId)
end

function BackWallController:OnDeactivate()
    self.triggerHandler:Disconnect()
end

function BackWallController:OnTriggerAreaEntered(entityId)
end

function BackWallController:OnTriggerAreaExited(entityId)
	Debug.Log("Ball is out of bounds.")
	
	-- Destroy the current ball
	GameEntityContextRequestBus.Broadcast.DestroyGameEntity(entityId)

	-- Move the pin sensor into place
	GameplayNotificationBus.Event.OnEventBegin(GameplayNotificationId(EntityId(),"PinSensorEnable"), nil)
end

return BackWallController