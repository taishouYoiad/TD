local towerA = class("towerA",function() return display.newSprite("tower.png") end)

function towerA:ctor(x,y)
	self:setPosition(x,y)
	self:initData()
end

function towerA:initData()
	self._lev = 1
	self._exp = 0
	self._frieRange = 100
	self._shootDriect = {}
	self._duration = 0.5
	self._cost = 20
	self._pos = {}
	self._shootList = {}
	self._dotNum = 2
	local levLabel = cc.Label:createWithSystemFont(self._lev,"Marker Felt",14)
	levLabel:setTextColor({0})
	levLabel:setPosition(10,10)
	levLabel:addTo(self)
	self._levLabel = levLabel
	self._speed = 150
end

function towerA:updateExp()
	self._exp = self._exp + 30
	if self._exp >= 100 then
		self:updateLev()
	end
end

function towerA:updateLev()
	self._lev = self._lev + 1
	self._exp = self._exp - 100
	self._frieRange = self._frieRange + 100
	-- self._dotNum = self._dotNum + 1 	
	self._speed = math.log(self._lev * 10) * 15 + 150
	self._duration = self._duration / self._lev
	self._levLabel:setString(self._lev)
end
function towerA:remove()
	self:removeSelf()
end
return towerA