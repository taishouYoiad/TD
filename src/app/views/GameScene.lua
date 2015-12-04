local GameScene = class("GameScene",cc.load("mvc").ViewBase)

local BuildMenu = require("app.views.BuildMenu")
local Dot = require("app.models.dot")
local towerA = require("app.models.towerA")
local monsterA = require("app.models.monsterA")

local DOT_SPEED = 150

local MAX_HEIGHT_NUM = math.ceil(display.height / 10)
local MAX_WIDTH_NUM = math.ceil(display.width / 10)

local MONSTER_DURATION = 0.8

local TYPE_EMPTY = 0
local TYPE_TOWER = 1
local TYPE_ROAD = 2

function GameScene:ctor()
	print(string.format("----------Memory Used: %0.2f KB", collectgarbage("count")))
	self:initMap()
	self:initMainData()
	self:initOtherUI()
	self:startTimer()
	display.newLayer():onTouch(handler(self,self.onTouched),1,1):addTo(self)
	cc.exports.WndManager.MainWnd = self
end

function GameScene:initMap()
	local mBg = display.newSprite(cc.exports.MapManager.map[cc.exports.MainData.lev].png)
	mBg:setPosition(display.cx,display.cy)
	mBg:addTo(self)
end

function GameScene:initMainData()
	self._tower = cc.exports.MainData.tower
	self._canFrieTower = {}
	self._monster = {}
	self._dot = {}
	self._monsterSum = 10
	self._monsterTime = 0
	--monsterLev
	self._monsterLev = cc.exports.MainData.lev
	--initMapData
	self._map = {}
	for i = 1,MAX_HEIGHT_NUM do
		self._map[i] = {}
		for j = 1,MAX_WIDTH_NUM do
			self._map[i][j] = TYPE_EMPTY
		end
	end
end

function GameScene:initOtherUI()
	self._gold = cc.Label:createWithSystemFont("剩余金钱"..cc.exports.MainData.gold,"Marker Felt",40)
	self._gold:setTextColor({0})
	self._gold:setPosition(display.cx - 150,display.height - 50)
	self._gold:addTo(self)
	self._life = cc.Label:createWithSystemFont("剩余生命"..cc.exports.MainData.life,"Marker Felt",40)
	self._life:setTextColor({0})
	self._life:setPosition(display.cx + 150,display.height - 50)
	self._life:addTo(self)
end

function GameScene:startTimer()
	self:scheduleUpdate(handler(self,self.updateStep))
end

function GameScene:updateStep(dt)
	self:createMonster(dt)
	self:updateCanFrieTower()
	self:createDot(dt)
	self:updateDot(dt)
	self:updateMonster(dt)
	self:checkNext()
end

function GameScene:createMonster(dt)
	self._monsterTime = self._monsterTime - dt
	if self._monsterTime <= 0 then
		-- if #self._monster == 0 then
		-- 	-- self._monsterLev = self._monsterLev + 1
		-- 	-- self._monsterSum = 10
		-- 	cc.exports.WndManager.StartWnd:nextLev()
		-- end
		if self._monsterSum <= 0 then
			return
		end
		local mMonster = monsterA:create(20,display.height):addTo(self)
		mMonster:updateLev(self._monsterLev)
		table.insert(self._monster,mMonster)
		self._monsterTime = MONSTER_DURATION
		self._monsterSum = self._monsterSum - 1
	end
end

function GameScene:updateCanFrieTower()
	self:clearCanFrieTower()
	if type(self._tower) ~= "table" or type(self._monster) ~= "table" then
		return 
	end
	for i,tower in pairs(self._tower) do
		for j,monster in pairs(self._monster) do
			if #tower._shootList < tower._dotNum then
				self:insertIntoFrieList(tower,monster)
			end
		end
	end
end

function GameScene:clearCanFrieTower()
	for index,tower in pairs(self._canFrieTower) do
		tower._shootList = {}
	end
	self._canFrieTower = {}
end

function GameScene:insertIntoFrieList(tower,monster)
	local tX,tY = tower:getPosition()
	local mX,mY = monster:getPosition()
	if (tX - mX) * (tX - mX) + (tY - mY) * (tY -mY) > (tower._frieRange * tower._frieRange) then
		return
	end
	if tX > mX then
		tower._shootDriect = {-1,-(mY - tY) / (mX - tX)}
	elseif tX < mX then
		tower._shootDriect = {1,(mY -tY) / (mX - tX)}
	elseif tY > mY then
		tower._shootDriect = {0,-1}
	else
		tower._shootDriect = {0,1}
	end
	table.insert(tower._shootList,tower._shootDriect)
	table.insert(self._canFrieTower,tower)
end

function GameScene:createDot(dt)
	if type(self._canFrieTower) ~= "table" then
		return
	end
	for i,canFrieTower in pairs(self._canFrieTower) do
		canFrieTower._duration = canFrieTower._duration - dt
		if canFrieTower._duration <= 0 then
			self:createDotByTower(canFrieTower)
			canFrieTower._duration = 0.5
		end
	end
end

function GameScene:createDotByTower(tower)
	if not tower or tower == nil or tower._shootDriect == nil then
		return
	end
	local tX,tY = tower:getPosition()
	for index,shotDriect in pairs(tower._shootList) do
		local mDot = Dot:create(tX,tY,shotDriect)
		mDot._parent = tower
		mDot._speed = tower._speed
		mDot:addTo(self)
		table.insert(self._dot,mDot)
	end
end

function GameScene:updateDot(dt)
	if type(self._dot) ~= "table" then
		return
	end
	for i,dot in pairs(self._dot) do
		self:updateDotPos(i,dot,dt)
	end
end

function GameScene:updateDotPos(index,dot,dt)
	if not dot or dot == nil then
		return
	end
	local dX,dY = dot:getPosition()
	if self:checkCollision(dot) == 1 then
		dot:removeSelf()
		table.remove(self._dot,index)
	else
		dot:setPosition(dX + dt * dot._speed * dot._driect.x,dY + dt * dot._speed * dot._driect.y)
	end
end

function GameScene:checkCollision(dot)
	local dX,dY = dot:getPosition()
	if dX >= display.width or dX <= 0 or dY >= display.height or dY <= 0 then
		return 1
	end
	for i,monster in pairs(self._monster) do
		local mX,mY = monster:getPosition()
		if (dX - 2) > (mX + 10) or (dX + 2) < (mX -10) or (dY - 2) > (mY + 10) or (dY + 2) < (mY - 10) then
		else
			monster:hitted()
			if monster:isDead() == 1 then
				if dot._parent ~= nil and dot._parent.updateExp ~= nil then
					dot._parent:updateExp()
				end
				monster:remove()
				table.remove(self._monster,i)
			end
			return 1
		end
	end
end

function GameScene:updateMonster(dt)
	if type(self._monster) ~= "table" then
		return
	end
	for i,monster in pairs(self._monster) do
		self:updateMonsterPos(monster,dt,i)
	end
end

function GameScene:updateMonsterPos(monster,dt,index)
	if not monster or monster == nil then
		return
	end
	monster:step(dt)
	local mX,mY = monster:getPosition()
	if mY <= 0 then
		monster:remove()
		table.remove(self._monster,index)
		self:updateLife(-1)
	end
end

function GameScene:canBuildTower(tower)
	if cc.exports.MainData.gold < tower._cost then
		return 0
	end
	self:updateGold(tower._cost * -1)
	return 1
end

function GameScene:buildTower(x,y)
	local i,j = generateIJByPos(x,y)
	if self._map[i][j] ~= TYPE_EMPTY then
		return
	end
	local tX,tY = generatePosByIJ(i,j)
	local mTower = towerA:create(tX,tY)
	if self:canBuildTower(mTower) == 1 then
		mTower:addTo(cc.exports.WndManager.StartWnd,10)
		mTower._pos = {i = i,j = j}
		table.insert(self._tower,mTower)
		self._map[i][j] = TYPE_TOWER
	end
end

function GameScene:destoryTower(x,y)
	local i,j = generateIJByPos(x,y)
	if self._map[i][j] ~= TYPE_TOWER then
		return
	end
	for index,tower in pairs(self._tower) do
		if tower._pos.i == i and tower._pos.j == j then
			self:updateGold(tower._cost / 2)
			tower:remove()
			table.remove(self._tower,index)
			self._map[i][j] = TYPE_EMPTY
			break
		end
	end
end

function GameScene:updateGold(delta)
	cc.exports.MainData.gold = cc.exports.MainData.gold + delta
	self._gold:setString("剩余金钱"..cc.exports.MainData.gold)
end

function GameScene:updateLife(delta)
	cc.exports.MainData.life = cc.exports.MainData.life + delta
	self._life:setString("剩余生命"..cc.exports.MainData.life)
	if cc.exports.MainData.life <= 0 then
		print("DEAD!!!!!!!!!")
	end
end

function GameScene:onTouched(event)
	if event.name == "began" then
		self:showBuildMenu(event.x,event.y)
	end
end

function GameScene:showBuildMenu(x,y)
	if cc.exports.WndManager.BuildWnd == nil then
		BuildMenu.new(x,y):addTo(self)
	end
end

function GameScene:checkNext()
	if #self._monster <= 0 then
		self:unscheduleUpdate()
		for index,dot in pairs(self._dot) do
			dot:remove()
			table.remove(self._dot,index)
		end
		-- for index,tower in pairs(self._tower) do
		-- 	tower:remove()
		-- 	table.remove(self._tower,index)
		-- end
		cc.exports.MainData.tower = self._tower 
		cc.exports.WndManager.StartWnd:nextLev()
	end
end

function GameScene:remove()
	cc.exports.WndManager.MainWnd = nil
	self:removeSelf()
end


return GameScene