local ChildrenScriptsBus = require "Scripts/Gamely/ChildrenScriptsBus"

local PinStatus = 
{
	Properties = 
	{
		IsCalculatingRound = {default = false},
	},
}

function PinStatus:OnActivate()
	local id = GameplayNotificationId(EntityId(), "Goal")
	self.gameplayBus = GameplayNotificationBus.Connect(self,id)
	ChildrenScriptsBus:Connect(self,false)
end

function PinStatus:OnDeactivate()
end



function PinStatus:OnTick(deltaTime, timePoint)

	if( self.Properties.IsCalculatingRound ) then
	
		if(self:ArePinsMoving() == false) then
			self.tickHandler:Disconnect()
					
			self.Properties.IsCalculatingRound = false
			local standingPins = self:StandingPinsCount()
			local totalPins = #self.arrayName
			local knockedPins = (totalPins - standingPins)
			Debug.Log("Knocked over " .. knockedPins .. (knockedPins > 1 and " pins" or " pin"))

			
			-- Signal reset		
			local id = GameplayNotificationId(EntityId(), "Reset")
			GameplayNotificationBus.Event.OnEventBegin(id, "Reset")
		end
		
	end
	
end

function PinStatus:OnEventBegin(value)
		self:CalculateRound()	
end

function PinStatus:ArePinsMoving()
	for Index, Value in pairs( self.arrayName ) do
		if(Value:IsMoving()) then
			--Debug.Log("Pins still moving")
			return true
		end
	end
	
	--Debug.Log("No pins moving.")
	return false
end 


function PinStatus:CalculateRound()
	self.tickHandler = TickBus.Connect(self, self.entityId)
	self.Properties.IsCalculatingRound = true
end

function PinStatus:StandingPinsCount()
	local standingCount = 0
	
	for Index, Value in pairs( self.arrayName ) do
		if(Value:IsStanding()) then
			standingCount = standingCount + 1
		end
	end
	
	return standingCount
end


return PinStatus