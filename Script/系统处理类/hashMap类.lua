map = {}

local this = map

function this:new()
    o = {}
    setmetatable(o,self)
    self.__index = self
    self.count = 0
    return o
end

function this:insert(k,v)

    if nil == self[k] then
        --table.insert(self,{a = b})
        self[k] = v
        self.count = self.count + 1
    end
    -- print("insert end")
end

function this:remove(k)
    if nil ~= self[k] then
        self[k] = nil
        if self.count >0 then
            self.count = self.count - 1
        end
    end
end

function this:getpair(k)
    local value = nil
    if nil ~= self[k] then
        value = self[k]
    end
    return value
end

function this:clear()
    for k,_ in pairs(self) do
        if nil ~= self[k] then
            self[k] = nil
        end
    end
    self.count = 0
end

