local env = {};

local function define(name, func)
	if func then
		env[name] = func;
	else
		return env[name];
	end
end

local function undef(name)
	env[name] = nil;
end

return {
	define = define,
	undef  = undef,
};
