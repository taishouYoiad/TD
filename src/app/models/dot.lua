local dot = class("dot",function() return display.newSprite("dot.png") end)

function dot:ctor(x,y,driect)
	self:setPosition(x,y)
	self:initData(driect)
end

function dot:initData(driect)
	self._driect = {x = driect[1],y = driect[2]}
end

function dot:remove()
	self:removeSelf()
end

return dot