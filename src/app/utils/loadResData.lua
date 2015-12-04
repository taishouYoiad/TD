local loadResData = class("loadResData")
function loadResData:ctor()
	self:initData()
end
function loadResData:initData()
	local string = cc.FileUtils:getInstance():getStringFromFile("table/map.csv")
	local sArr = {}
	cc.exports.MapManager.map = {}
	for i,k in pairs(string.split(string,"\r\n")) do
		if i ~= 1 then
			sArr = string.split(k,",")
			for a,b in pairs(sArr) do
				print(a,b)
			end
			cc.exports.MapManager.map[i - 1] = {png = sArr[2]..".png"}
		end
	end
end
return loadResData