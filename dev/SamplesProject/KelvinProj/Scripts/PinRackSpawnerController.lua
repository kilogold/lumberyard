local PinRackSpawnerController =
{
	Properties =
	{
	}
}

function PinRackSpawnerController:OnActivate()
	self.spawnHandler = SpawnerComponentNotificationBus.Connect(self, self.entityId)
end

function PinRackSpawnerController:OnDeactivate()
	self.spawnHandler:Disconnect()
end

function PinRackSpawnerController:OnEntitySpawned(ticket, spawnedEntityId)
	local entityName = GameEntityContextRequestBus.Broadcast.GetEntityName(spawnedEntityId)
	local isPinRack = TagComponentRequestBus.Event.HasTag(spawnedEntityId, Crc32("PinRack"))
	
 	if (isPinRack) then
		Debug.Log("Found pin rack with entity name: " .. entityName)
		local notificationID = GameplayNotificationId(EntityId(),"PinSpawn")
		GameplayNotificationBus.Event.OnEventBegin(notificationID, spawnedEntityId)
	end
	
end

return PinRackSpawnerController