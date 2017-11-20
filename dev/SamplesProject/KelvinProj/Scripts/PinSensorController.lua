local PinSensorController =
{
	Properties =
	{
		BallSpawner = EntityId(),
		PinRackSpawner = EntityId(),
		ActivePosition = Vector3(0,0,0),
		InactivePosition = Vector3(0,0,0)
	}
}

function PinSensorController:OnEventBegin(value)
	Debug.Log("                                 GameplayBus is working")

	if(self.pinSpawnEventID == GameplayNotificationBus.GetCurrentBusId()) then 
		Debug.Log("Registering PinRack dynamic slice with PinSensor.")
		self.currentPinRackDynSliceEntityID = value
	
	elseif (self.pinSensorEnableEventID == GameplayNotificationBus.GetCurrentBusId()) then
		Debug.Log("Activating Pin Sensor")
		-- Move the pin sensor into place
		TransformBus.Event.SetWorldTranslation(self.entityId, self.Properties.ActivePosition)

		-- Begin the sensing timer
		self.tickHandler = TickBus.Connect(self, self.entityId)
		self.MaxBetweenPinDetectionTime = 1.0 -- Timeout before concluding we've detected all pin stats.
		self.BetweenPinDetectionTime = self.MaxBetweenPinDetectionTime 
		self.PinsStanding = 0
	end 
	
end

function PinSensorController:OnActivate()

	-- EventIDs
	self.pinSensorEnableEventID = GameplayNotificationId(EntityId(),"PinSensorEnable")
	self.pinSpawnEventID = GameplayNotificationId(EntityId(),"PinSpawn")
	
	-- EventHandlers
	self.pinSensorEnableHandler = GameplayNotificationBus.Connect(self, self.pinSensorEnableEventID)
	self.pinSpawnHandler = GameplayNotificationBus.Connect(self, self.pinSpawnEventID)
	self.triggerHandler = TriggerAreaNotificationBus.Connect(self, self.entityId)
end

function PinSensorController:OnDeactivate()
    self.triggerHandler:Disconnect()
	self.pinSpawnHandler:Disconnect()
	self.pinSensorEnableHandler:Disconnect()
end

function PinSensorController:OnTriggerAreaEntered(entityId)
	self.PinsStanding = self.PinsStanding + 1
	self.BetweenPinDetectionTime = self.MaxBetweenPinDetectionTime 
end

function PinSensorController:OnTriggerAreaExited(entityId)
end


-- TODO: Maybe I need to listen to when a dynamic slice is spawned and cache the entityid.
function PinSensorController:OnTick(deltaTime, timePoint)
	self.BetweenPinDetectionTime = self.BetweenPinDetectionTime - deltaTime
	if(self.BetweenPinDetectionTime <= 0) then
		Debug.Log("Knocked over " .. self.PinsStanding .. (self.PinsStanding > 1 and " pins" or " pin"))
		
		-- Stop sensing new pins by moving out of place.
		Debug.Log("De-activating Pin Sensor")
		TransformBus.Event.SetWorldTranslation(self.entityId, self.Properties.InactivePosition)
		self.tickHandler:Disconnect()

		-- Eliminate current pins				
		GameEntityContextRequestBus.Broadcast.DestroyDynamicSliceByEntity(self.currentPinRackDynSliceEntityID)
			
		-- Respawn
		SpawnerComponentRequestBus.Event.Spawn(self.Properties.BallSpawner)
		SpawnerComponentRequestBus.Event.Spawn(self.Properties.PinRackSpawner)
	end	
end

return PinSensorController