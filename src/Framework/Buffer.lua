local error, setmetatable
    = error, setmetatable;

local MAX_SIZE = 0x1000000;

local Buffer = {};
local BufferMT = {
	__len   = function(self)
		return self.length;
	end,
	__index = Buffer,
	__call  = function(self, ...)
		return self:new(unpack(arg));
	end,
};

function Buffer:new(maxsize)
	local self = setmetatable({}, BufferMT);
	self.buffer  = {};
	self.offset  = 0;
	self.length  = 0;
	self.maxsize = maxsize or MAX_SIZE;
	return self;
end

function Buffer:size()
	return self.length;
end

function Buffer:full()
	return self.length == self.maxsize;
end

function Buffer:empty()
	return self.length == 0;
end

function Buffer:first()
	return self.offset % self.maxsize + 1;
end

function Buffer:last()
	return (self.offset + self.length - 1) % self.maxsize + 1;
end

function Buffer:front()
	return self.buffer[self:first()];
end

function Buffer:back()
	return self.buffer[self:last()];
end

function Buffer:at(index)
	return self.buffer[(self.offset + ((index - 1) % self.length)) % self.maxsize + 1];
end

function Buffer:push(value)
	if self:full() then
		error("queue is full", 2);
	end
	local index = self:last() % self.maxsize + 1;
	self.buffer[index] = value;
	self.length        = self.length + 1;
end

function Buffer:pop()
	if self:empty() then
		error("queue is empty", 2);
	end
	local index = self:first();
	local value = self.buffer[index];
	self.offset = index;
	self.length = self.length - 1;
	return value;
end

function Buffer:next()
	local index   = -1;
	local buffer  = self.buffer;
	local offset  = self.offset;
	local length  = self.length;
	local maxsize = self.maxsize;
	return function()
		index = index + 1;
		if index < length then
			return buffer[(index + offset) % maxsize + 1];
		end
	end;
end

return setmetatable({}, BufferMT);
