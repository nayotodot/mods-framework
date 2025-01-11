local getmetatable, rawget, setmetatable, unpack
    = getmetatable, rawget, setmetatable, unpack;

--- Instance
--- @class Instance
--- @field prototype Instance
--- @field init function
--- @field __index function
--- @field __call function
local Instance = {};

--- __index
--- @param key any
--- @return Instance
function Instance:__index(key)
	return rawget(self.prototype, key);
end

--- __call
--- @param ... any
--- @return Instance
function Instance:__call(classname, ...)
	local class = setmetatable({}, getmetatable(self));
	class.classname = classname;
	class.prototype = self;
	if class.Init then
		return class:Init(unpack(arg));
	end
	return class;
end

---	__name
--- @return string
function Instance:__name()
	return rawget(self, "classname") or "Instance";
end

--- __tostring
--- @return string
function Instance:__tostring()
	return rawget(self, "classname") or "Instance";
end

return setmetatable(Instance, Instance);
