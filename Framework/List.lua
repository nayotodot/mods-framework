local setmetatable, unpack
    = setmetatable, unpack;

--- Node
--- @class Node
--- @field previous Node
--- @field next Node
--- @field data any

--- List
--- @class List
--- @field first Node
--- @field last Node
local List = {};

--- ListMT
--- @class ListMT
--- @field __index List
--- @field __call function
local ListMT = {
	__index = List,
	__call  = function(self, ...)
		return self:new(unpack(arg));
	end,
};

--- after
--- @param list List
--- @param node any
--- @param newnode any
local function after(list, node, newnode)
	newnode.previous = node;
	if node.next then
		newnode.next       = node.next;
		node.next.previous = newnode;
	else
		newnode.next = nil;
		list.last    = newnode;
	end
	node.next = newnode;
	return newnode;
end

--- before
--- @param list List
--- @param node any
--- @param newnode any
local function before(list, node, newnode)
	newnode.next = node;
	if node.previous then
		newnode.previous   = node.previous;
		node.previous.next = newnode;
	else
		newnode.previous = nil;
		list.first       = newnode;
	end
	node.previous = newnode;
	return newnode;
end

--- prepend
--- @param list List
--- @param newnode any
local function prepend(list, newnode)
	if list.first then
		before(list, list.first, newnode);
	else
		list.first = newnode;
		list.last  = newnode;
		newnode.previous = nil;
		newnode.next     = nil;
	end
	return newnode;
end

--- append
--- @param list List
--- @param newnode any
local function append(list, newnode)
	if list.last then
		after(list, list.last, newnode);
	else
		prepend(list, newnode);
	end
	return newnode;
end

--- remove
--- @param list List
--- @param node any
--- @return any
local function remove(list, node)
	if node.previous then
		node.previous.next = node.next;
	else
		list.first = node.next;
	end
	if node.next then
		node.next.previous = node.previous;
	else
		list.last = node.previous;
	end
	return node;
end

--- List:new
--- @return List
function List:new()
	return setmetatable({}, ListMT);
end

--- List:before
--- @param node Node
--- @param data any
function List:before(node, data)
	local newnode = {};
	newnode.data = data;
	return before(self, node, newnode);
end

--- List:after
--- @param node Node
--- @param data any
function List:after(node, data)
	local newnode = {};
	newnode.data = data;
	return after(self, node, newnode);
end

--- List:append
--- @param data any
function List:append(data)
	local newnode = {};
	newnode.data = data;
	return append(self, newnode);
end

--- List:prepend
--- @param data any
function List:prepend(data)
	local newnode = {};
	newnode.data = data;
	return prepend(self, newnode);
end

--- List:remove
--- @param node Node
function List:remove(node)
	return remove(self, node);
end

--- List:forwards
--- @return function: any, Node
function List:forwards()
	local node;
	local data;
	local next = self.first;
	return function()
		if next then
			node = next;
			data = node.data;
			next = node.next;
			return data, node;
		end
	end;
end

--- List:backwards
--- @return function: any, Node
function List:backwards()
	local node;
	local data;
	local next = self.last;
	return function()
		if next then
			node = next;
			data = node.data;
			next = node.previous;
			return data, node;
		end
	end;
end

return setmetatable({}, ListMT);
