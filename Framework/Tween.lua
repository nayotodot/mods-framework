local Buffer         = require "Framework.Buffer";
local Task           = require "Framework.Task";
local ApplyModifiers = require "Helper.ApplyModifiers";

local pairs        = pairs;
local rawset       = rawset;
local setmetatable = setmetatable;
local type         = type;

local huge   = math.huge;

local unpack = table.unpack or unpack;

local function lerp(x, l, h)
	return x * (h - l) + l;
end

local function copy(orig)
	if type(orig) ~= "table" then
		return orig;
	end
	local res = {};
	for k, v in pairs(orig) do
		rawset(res, k, v);
	end
	return res;
end

local function merge(dst, src)
	for k, v in pairs(src) do
		rawset(dst, k, copy(v));
	end
	return dst;
end

local function linear(t) return t; end

local function Callback(
	Children,
	DeltaTime,
	DurationBeat,
	DurationTime,
	Percent,
	Frame,
	--
	Easing,
	From,
	To,
	PlayerNumber
)
	for k, v in pairs(To) do
		ApplyModifiers(PlayerNumber, k, lerp(Easing(Percent), From[k] or 0, v), huge);
	end
end

local Tween = Task("Tween", Callback);
local TweenMT = {
	__index = Tween,
	__call  = function(self, ...)
		return self:Create(unpack(arg));
	end,
};

function Tween:Create(Param)
	local t = setmetatable({}, TweenMT);
	t.Beat     = Param.Beat;
	t.Time     = Param.Time;
	t.Tweens   = Buffer(0x100);
	t.Current  = {};
	t.Args     = {};
	t.Callback = Param.Callback or self.Callback;
	for i = 1, #Param do
		t.Args[i] = Param[i];
	end
	return t;
end

function Tween:Default(Param)
	self.Current = Param;
	for i = 1, #Param do
		self.Args[i] = Param[i];
	end
	return self;
end

function Tween:DestTweenState()
	local T = self.Tweens;
	if T:empty() then
		return self.Current;
	else
		return T:back().State;
	end
end

function Tween:BeginTweening(Time, Easing)
	local T = self.Tweens;
	T:push{
		State = copy(self:DestTweenState()),
		Info  = {},
	};
	local i = T:size();
	local TS = T:back().State;
	local TI = T:back().Info;
	if i > 1 then
		merge(TS, T:at(i - 1).State);
	else
		merge(TS, self.Current);
	end
	TI.Easing = Easing or linear;
	TI.Time   = Time;
	-- TI.Remain = Time;
	return self;
end

function Tween:Easing(Time, Easing)
	self:BeginTweening(Time, Easing);
	return self;
end

function Tween:Delay(Time)
	self:BeginTweening(Time);
	self:BeginTweening(0);
	return self;
end

function Tween:To(Param)
	local TS = self:DestTweenState();
	merge(TS, Param);
	return self;
end

function Tween:Finish()
	local Tweens = self.Tweens;
	local IsFirst = true;
	while not Tweens:empty() do
		local Param = {};
		local T = Tweens:pop();
		if IsFirst then
			Param.Time = self.Time;
			Param.Beat = self.Beat;
			IsFirst = false;
		end
		Param.Len = T.Info.Time;
		Param[#Param + 1] = T.Info.Easing;
		Param[#Param + 1] = self.Current;
		Param[#Param + 1] = T.State;
		for i = 1, #self.Args do
			Param[#Param + 1] = self.Args[i];
		end
		Task.Create(self, Param);
		self.Current = T.State;
	end
	return self;
end

return Tween;
