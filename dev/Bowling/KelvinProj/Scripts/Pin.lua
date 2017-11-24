local ChildrenScriptsBus = require "Scripts/Gamely/ChildrenScriptsBus"

local Pin = 
{
	Properties = 
	{
		terminalVelocityThreshold = {default = 0.5}
	},
}


function Pin:IsMoving()
	local v3Velocity = PhysicsComponentRequestBus.Event.GetVelocity(self.entityId)

	local isAtTerminalVelocity = ( 	v3Velocity.x > -self.Properties.terminalVelocityThreshold and v3Velocity.x < self.Properties.terminalVelocityThreshold and
									v3Velocity.y > -self.Properties.terminalVelocityThreshold and v3Velocity.y < self.Properties.terminalVelocityThreshold and
									v3Velocity.z > -self.Properties.terminalVelocityThreshold and v3Velocity.z < self.Properties.terminalVelocityThreshold )			
	return not isAtTerminalVelocity
end

function Pin:IsStanding()
	local rotation = self:EulerDegreesRotation()
	--Debug.Log("Standing check for Entity #" .. tostring(self.entityId))
	--Debug.Log(tostring(rotation))
	
	local tiltThreshold = 10
	
	return (rotation.x < self.standingRotation.x + tiltThreshold and rotation.x > self.standingRotation.x - tiltThreshold and
			rotation.y < self.standingRotation.y + tiltThreshold and rotation.y > self.standingRotation.y - tiltThreshold and
			rotation.z < self.standingRotation.z + tiltThreshold and rotation.z > self.standingRotation.z - tiltThreshold )
end

function Pin:OnActivate()
	self.standingRotation = self:EulerDegreesRotation()
	self.startTransform = TransformBus.Event.GetWorldTM(self.entityId)
	
	local parentEntityId = TransformBus.Event.GetParentId(self.entityId)
	ChildrenScriptsBus.Event:Add(parentEntityId,self,"arrayName")
	
	local id = GameplayNotificationId(EntityId(), "Reset")
	self.gameplayBus = GameplayNotificationBus.Connect(self, id)
end

function Pin:OnEventBegin(value)
	if(value == "Reset") then
		Debug.Log("Resetting.")
		TransformBus.Event.SetWorldTM(self.entityId, self.startTransform)
	end
end

function Pin:EulerDegreesRotation()
	local radianEulerRotation = TransformBus.Event.GetEulerRotation(self.entityId)
	return Vector3( Math.RadToDeg(radianEulerRotation.x), Math.RadToDeg(radianEulerRotation.y), Math.RadToDeg(radianEulerRotation.z) )
end


return Pin