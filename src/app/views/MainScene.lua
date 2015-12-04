local MainScene = class("MainScene",cc.load("mvc").ViewBase)
local GameScene = require("app.views.GameScene")

local MAX_LEV = 4
function MainScene:ctor()
	cc.exports.MainData.lev = 1
	cc.exports.MainData.gold = 200
	cc.exports.MainData.life = 50
	cc.exports.MainData.tower = {}
	self._gamescene = GameScene:create():addTo(self,1)
	cc.exports.WndManager.StartWnd = self
end

function MainScene:nextLev()
	cc.exports.MainData.lev = cc.exports.MainData.lev + 1
	cc.exports.WndManager.BuildWnd = nil
	cc.exports.WndManager.MainWnd = nil
	-- self._gamescene:remove()  remove报错？？？？？？
	self._gamescene = nil
	if cc.exports.MainData.lev <= MAX_LEV then
		self._gamescene = GameScene:create():addTo(self,1)
	end
end

return MainScene