-- should really be called GameState...
local init =
{
	Properties =
	{
		EnableCursor = {default = true},
		PinSpawner = {default = EntityId()}
	}
}

function init:OnActivate()
	LyShineLua.ShowMouseCursor(self.Properties.EnableCursor)
end

return init