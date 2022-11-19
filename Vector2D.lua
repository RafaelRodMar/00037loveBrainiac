Vector2D = {}

Vector2D_mt = { __index = Vector2D }

function Vector2D:new(x,y)
    local entity = {}
    setmetatable(entity, Vector2D_mt)
    
    entity.x = x
    entity.y = y
    
    return entity
end