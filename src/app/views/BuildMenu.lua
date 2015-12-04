local BuildMenu = class("BuildMenu",cc.load("mvc").ViewBase)

function BuildMenu:ctor(x,y)
	local bg = display.newSprite("buildBG.png")
	local lSize = bg:getContentSize()
	bg:setPosition(x,y + lSize.height / 2):addTo(self)
	local bBtn = cc.MenuItemImage:create("build.png","build.png"):setPosition(-55,0):onClicked(function() print("Build") self:buildTower(x,y)	end)
	local dBtn = cc.MenuItemImage:create("destory.png","destory.png"):setPosition(0,0):onClicked(function() print("Destory") self:destoryTower(x,y)  end)
	local cBtn = cc.MenuItemImage:create("cancel.png","cancel.png"):setPosition(55,0):onClicked(function() print("Cancel") self:remove() end)
	local mMenu = cc.Menu:createWithItem(bBtn,dBtn,cBtn):move(x,y + lSize.height / 2):addTo(self)
	-- display.newLayer():onTouch(handler(self,self.onTouched),1,1):addTo(self)
	cc.exports.WndManager.BuildWnd = self
end

function BuildMenu:buildTower(x,y)
	cc.exports.WndManager.MainWnd:buildTower(x,y)
	self:remove()
end

function BuildMenu:destoryTower(x,y)
	cc.exports.WndManager.MainWnd:destoryTower(x,y)
	self:remove()
end

function BuildMenu:remove()
	cc.exports.WndManager.BuildWnd = nil
	self:removeSelf()
end

return BuildMenu