function generateIJByPos(x,y)
	local i = math.ceil(x / 20)
	local j = math.ceil(y / 20)
	return i,j
end

function generatePosByIJ(i,j)
	local x = (i - 1) * 20 + 10
	local y = (j - 1) * 20 + 10
	return x,y
end
