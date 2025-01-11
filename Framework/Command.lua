local Task = require "Framework.Task";

local error  = error;
local type   = type;
local unpack = table.unpack or unpack;

local MESSAGEMAN     = MESSAGEMAN;
local MessageManager = MessageManager;
local Broadcast      = MessageManager.Broadcast;

local function Callback(
	Children,
	DeltaTime,
	DurationBeat,
	DurationTime,
	Percent,
	Frame,
	--
	Cmd,
	...
)
	if type(Cmd) == "string" then
		Broadcast(MESSAGEMAN, Cmd);
	elseif type(Cmd) == "function" then
		Cmd(
			Children,
			DeltaTime,
			DurationBeat,
			DurationTime,
			Percent,
			Frame,
			unpack(arg)
		);
	else
		error("Command is missing.", 2);
	end
end

return Task("Command", Callback);
