local monsterA = class("monsterA",function() return display.newSprite("monster.png") end)

function monsterA:ctor(x,y)
	self:setPosition(x,y)
	self:initData()
end

function monsterA:initData()
	self._hp = 20
	self._speed = 50
	local hpLabel = cc.Label:createWithSystemFont(self._hp,"Marker Felt",14)
	hpLabel:setTextColor({0})
	hpLabel:setPosition(10,10)
	hpLabel:addTo(self)
	self._hpLabel = hpLabel
	self._lev = 1
end

function monsterA:hitted()
	self._hp = self._hp - 1
	self:updateLabel()
end

function monsterA:updateLabel()
	self._hpLabel:setString(self._hp)
end
function monsterA:updateLev(lev)
	self._lev = lev
	self._hp = self._hp + self._lev * 10
	self:updateLabel()
end

function monsterA:isDead()
	if self._hp <= 0 then
		return 1
	end
	return 0
end

function monsterA:step(dt)
	local mX,mY = self:getPosition()
	local driect = {{1,0},{-1,0},{0,1},{0,-1}}
	if (mX <= 50 and mX >= 10 and mY >= display.cy) or (mX >= display.width - 20) then
		self:setPosition(mX,mY + dt * self._speed * driect[4][2])
	else
		self:setPosition(mX + dt * self._speed * driect[1][1],mY)
	end
end

function monsterA:remove()
	self:removeSelf()
end
return monsterA