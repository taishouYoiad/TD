local stageManager = class("stageManager")
local stageManager:stor()
	cc.exports.MainData.lev = 1
	
end
local stageManager:nextLev()
	cc.exports.MainData.lev = cc.exports.MainData.lev + 1

end
return stageManager