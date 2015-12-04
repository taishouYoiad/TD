
local MyApp = class("MyApp", cc.load("mvc").AppBase)
cc.exports.WndManager = {}
cc.exports.MapManager = {}
cc.exports.MainData = {}
cc.exports.MainData.count = 1

local loadData = require("app.utils.loadResData")

function MyApp:onCreate()
    math.randomseed(os.time())
    loadData:create()
end

return MyApp
