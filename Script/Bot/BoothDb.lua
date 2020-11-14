-- @作者: CoderM
-- @邮箱:  coderm@qq.com
-- @创建时间:   2020-05-26 22:13:52
-- @最后修改来自: CoderM
-- @Last Modified time: 2020-06-07 18:19:36

-- 摊位数据类,这里保存了所有的摊位数据

local BoothDb = class()

function BoothDb:初始化()
	-- 道具摊位
	self.itemDb = {}
	-- 宠物摊位
	self.bbDb = {}

	-- 摊位对应地图的分类
	self.mapTable = {}

	-- 摊位ID列表
	self.boothIdTable = {}

	-- 摊位数组
	self.list_booth = {}

	-- 临时摊位数组
	self.temp_list_booth = {}

	self.boothNum = 0
end

function BoothDb:addBoothBot(srcArr)
	for i=1,#srcArr do
		local biz = BoothBotBiz.创建(srcArr[i])
		self.temp_list_booth[i] = biz
		self.boothIdTable[biz.bot.id] = true
		-- self.list_booth[biz.bot.id] = self.temp_list_booth[i]
		-- -- 根据mapId 给假人进行分类,减少循环次数
		-- local mapId =biz:getMapId()
		-- if self.mapTable[mapId] == nil then self.mapTable[mapId] = {} end
		-- local mapt = self.mapTable[mapId]
		-- mapt[#mapt+1] = biz
	end

	syslog("CoderM:添加了["..#self.temp_list_booth.."]个假人摊位")
end

function BoothDb:boothAdd(num)
	if (#self.temp_list_booth) == 0 then
		return
	end
	local arr = {}
	for i=1,num do
		self.boothNum = self.boothNum+1
		arr[i] = self.temp_list_booth[1]
		local biz = self.temp_list_booth[1]
		self.list_booth[biz.bot.id] = arr[i]
		table.remove(self.temp_list_booth,1)

		local mapId =biz:getMapId()
		if self.mapTable[mapId] == nil then self.mapTable[mapId] = {} end
		local mapt = self.mapTable[mapId]
		mapt[#mapt+1] = biz

		BoothCtrl:sendMsg2Map( 1006, arr[i].bot, arr[i].bot.地图数据.编号)
		if (#self.temp_list_booth) == 0 then
			break
		end
	end

	__S服务:输出("线性加载了["..#arr.."]个摆摊假人,当前摆摊假人总数为["..self.boothNum.."]")
end

-- 初始化所有摊位的道具数据
function BoothDb:initItemTable(srcArr)
	for i=1,#srcArr do
		self.itemDb[i] = srcArr[i]
	end
	syslog("CoderM:初始化了["..#self.itemDb.."]个道具橱窗")
end

-- 初始化所有摊位的宠物数据
function BoothDb:initBBTable(srcArr)
	for i=1,#srcArr do
		self.bbDb[i] = srcArr[i]
	end
	syslog("CoderM:初始化了["..#self.bbDb.."]个宠物橱窗")
end

-- 根据ID获取一个道具摊位
function BoothDb:getItemBoothById(id)
	if self.itemDb[id] == nil then
		return {}
	end
	return self.itemDb[id]
end

-- 根据ID获取一个宠物摊位
function BoothDb:getBBBoothById(id)
	if self.bbDb[id] == nil then
	    return {}
	end
	return self.bbDb[id]
end

function BoothDb:sendBoothBot(mapid,cid,userid)
	local botArr = self.mapTable[mapid]
	if botArr ~= nil then
		BoothCtrl:sendBotList2User(botArr,cid,userid)
	end
end

-- 根据ID获取一个用户的假人信息
function BoothDb:getBotById(id)
	return self.list_booth[id]
end

-- 向同一地图的玩家广播数据
function BoothDb:sendMsg2Map( 序号, 内容, 地图)
	for n, v in pairs(地图处理类.地图玩家[地图]) do
		发送数据(玩家数据[n].连接id,序号,内容)
	end
end

-- 向单一玩家发送所有机器人信息
function BoothDb:sendBotList2User( botArr ,id)
	for i=1,#botArr do
		发送数据(id,1006,botArr[i].bot)
	end
end

function BoothDb:isBot(id)
	return self.boothIdTable[id] == true
end


return BoothDb