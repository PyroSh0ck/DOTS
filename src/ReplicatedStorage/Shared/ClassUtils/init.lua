local ClassUtils = {}
ClassUtils.Utility = require(script.Utility)

function ClassUtils:__call(...)
    local obj = {}
    setmetatable(obj, self)

    if self.__init then
        self.__init(obj, ...)
    end

    return obj
end

function ClassUtils:__index(index)
    if rawget(self, "__super") then
        return self.__super[index]
    end
    return nil
end

function ClassUtils.class(newClass)
    newClass.__index = newClass
    return setmetatable(newClass, ClassUtils)
end

return ClassUtils
