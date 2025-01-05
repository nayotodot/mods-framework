local Buffer       = require "Framework.Buffer";
local List         = require "Framework.List";
local Instance     = require "Framework.Instance";
local SongPosition = require "Helper.SongPosition";
local TimingData   = require "Helper.TimingData";

local collectgarbage = collectgarbage;
local setmetatable   = setmetatable;

local create         = coroutine.create;
local resume         = coroutine.resume;
local yield          = coroutine.yield;

local floor          = math.floor;
local min            = math.min;

local unpack         = table.unpack or unpack;

local GetSongBeatVisible     = SongPosition.GetSongBeatVisible;
local GetMusicSecondsVisible = SongPosition.GetMusicSecondsVisible;

local Task = Instance("Task");
local TaskMT = {
	__index = Task,
	__call  = function(self, ...)
		return self:Create(unpack(arg));
	end,
};

local Current    = {};
local Scheduled  = Buffer();
local Parallel   = List();
local TotalFrame = 0;

local function GetLast(Param, First)
	local Last;
	if Param.Len then
		Last = Param.Len + First;
	elseif Param.End then
		Last = Param.End;
	end
	return Last;
end

local function CreateMapTaskData(Param)
	local NewParam  = {};
	local UnitType  = Param.Beat and "Beat" or Param.Time and "Time" or Current.UnitType;
	local UseBeat   = UnitType == "Beat";
	local UseTime   = UnitType == "Time";
	local FirstBeat = UseBeat and (Param.Beat or Current.LastBeat);
	local FirstTime = UseTime and (Param.Time or Current.LastTime);
	local LastBeat  = UseBeat and (GetLast(Param, FirstBeat) or FirstBeat);
	local LastTime  = UseTime and (GetLast(Param, FirstTime) or FirstTime);
	NewParam.UnitType  = UnitType;
	NewParam.FirstBeat = UseBeat and FirstBeat or TimingData.GetBeatFromElapsedTimeNoOffset(FirstTime);
	NewParam.FirstTime = UseTime and FirstTime or TimingData.GetElapsedTimeFromBeatNoOffset(FirstBeat);
	NewParam.LastBeat  = UseBeat and LastBeat or TimingData.GetBeatFromElapsedTimeNoOffset(LastTime);
	NewParam.LastTime  = UseTime and LastTime or TimingData.GetElapsedTimeFromBeatNoOffset(LastBeat);
	NewParam.Args = {};
	for i = 1, #Param do
		NewParam.Args[i] = Param[i];
	end
	Current = NewParam;
	return NewParam;
end

function Task.Init(self, Callback)
	local t = setmetatable({}, TaskMT);
	t.Callback = Callback or self.Callback;
	return t;
end

function Task.Loader()
	while not Scheduled:empty() do
		local data  = Scheduled:pop();
		local state = resume(unpack(data));
		if state then
			Parallel:append(data[1]);
		end
	end
	collectgarbage();
end

function Task.Update(Children, DeltaTime)
	local CurrentBeat = GetSongBeatVisible();
	local CurrentTime = GetMusicSecondsVisible();
	for data, node in Parallel:forwards() do
		local state = resume(data, Children, DeltaTime, CurrentBeat, CurrentTime, floor(TotalFrame));
		if not state then
			Parallel:remove(node);
		end
	end
	TotalFrame = TotalFrame + DeltaTime * 60;
end

function Task.Interval(Callback, Param)
	local Children;
	local DeltaTime;
	local CurrentBeat;
	local CurrentTime;
	local Frame;
	local FirstBeat  = Param.FirstBeat;
	local FirstTime  = Param.FirstTime;
	local LastBeat   = Param.LastBeat;
	local LastTime   = Param.LastTime;
	local LengthBeat = LastBeat - FirstBeat;
	local LengthTime = LastTime - FirstTime;
	local Args       = Param.Args;
	repeat
		Children, DeltaTime, CurrentBeat, CurrentTime, Frame = yield();
		if FirstTime < CurrentTime then
			local DurationBeat = min(CurrentBeat - FirstBeat, LengthBeat);
			local DurationTime = min(CurrentTime - FirstTime, LengthTime);
			local Percent      = min(DurationTime / LengthTime, 1.0);
			Callback(
				Children,
				DeltaTime,
				DurationBeat,
				DurationTime,
				Percent,
				Frame,
				unpack(Args)
			);
		end
	until LastTime < CurrentTime
end

function Task.Create(self, Param)
	local Map = CreateMapTaskData(Param);
	local Array = {
		create(self.Interval),
		self.Callback,
		Map,
	};
	Scheduled:push(Array);
	return self;
end

return Task;
