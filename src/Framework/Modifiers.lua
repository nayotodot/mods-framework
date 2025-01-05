local Task          = require "Framework.Task";
local PlayerOptions = require "Helper.PlayerOptions";

local function Callback(
	Children,
	DeltaTime,
	DurationBeat,
	DurationTime,
	Percent,
	Frame,
	--
	Mods,
	PlayerNumber
)
	if PlayerNumber then
		PlayerOptions[PlayerNumber]:FromString(Mods);
	else
		for i = 1, #PlayerOptions do
			PlayerOptions[i]:FromString(Mods);
		end
	end
end

--- Modifiers
--- @class Modifiers
--- @field Callback function
--- @field Create function
--- @field Interval function
return Task("Modifiers", Callback);
