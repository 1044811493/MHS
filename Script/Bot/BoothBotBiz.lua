-- @作者: CoderM
-- @邮箱:  coderm@qq.com
-- @创建时间:   2020-05-29 20:37:05
-- @最后修改来自: CoderM
-- @Last Modified time: 2020-06-06 02:02:32

local BoothBotBiz = class()


function BoothBotBiz:初始化(bot)
	self.bot = bot
	self.bot.x = bot.地图数据.x
	self.bot.y = bot.地图数据.y
	self.itemTable = {}
	self.bbTable = {}
	self:initTable(bot)
end

function BoothBotBiz:initTable(bot)
	self:setItemTable(BoothDb:getItemBoothById(bot.itemTable))
	self:setBBTable(BoothDb:getBBBoothById(bot.BBTable))
end

function BoothBotBiz:setItemTable(source)
	self.itemTable = ItemTableBiz.创建(table.loadstring(table.tostring(source)))
end

function BoothBotBiz:setBBTable(source)
	self.bbTable = BBTableBiz.创建(table.loadstring(table.tostring(source)))
end

function BoothBotBiz:getMapId( )
	return self.bot.地图数据.编号
end

function BoothBotBiz:getItemTable()
	return self.itemTable.item
end

function BoothBotBiz:getBBTable()
	return self.bbTable.bb
end

return BoothBotBiz