-- @作者: CoderM
-- @邮箱:  coderm@qq.com
-- @创建时间:   2020-05-26 22:07:48
-- @最后修改来自: CoderM
-- @Last Modified time: 2020-06-07 02:23:43
-- 机器人的数据源

local BotDb = class()
-- 引入两个基础机器人库

function BotDb:初始化()

	-- 闲逛用的机器人
	self.botList = {}

	-- 队伍列表
	self.teamList = {}

	-- 这里用一个临时的数据保存整个的假人列表,随着时间推移会加到正常数组里
	self.temp_botList = {}
	-- 这里用一个临时的数据保存整个的假人队伍列表
	self.temp_teamBotList = {}
end

-- 初始化队长和队员
function BotDb:initTeamDb(teamList)
	for i=1,#teamList do
		local t_b = TeamBotBiz.创建(teamList[i])
		self.temp_teamBotList[i] = t_b
	end
	__S服务:输出("加载了["..#self.temp_teamBotList.."]个组队假人")
end

-- 初始化单独假人
function BotDb:initAloneDb(botList)
	for i=1,#botList do
		local t_b = BotBiz.创建(botList[i])
		self.temp_botList[i] = t_b
	end
	__S服务:输出("加载了["..#self.temp_botList.."]个单独假人")
end

-- 按照数量增加假人
function BotDb:botAdd(num)
	if (#self.temp_botList) == 0 then
		return
	end
	local arr = {}
	for i=1,num do
		arr[i] = self.temp_botList[1]
		self.botList[#self.botList+1] = arr[i]
		arr[i].bot.x = arr[i].bot.地图数据.x
		arr[i].bot.y = arr[i].bot.地图数据.y
		table.remove(self.temp_botList,1)
		BotCtrl:sendMsg2Map( 1006, arr[i].bot, arr[i].bot.地图数据.编号)
		if (#self.temp_botList) == 0 then
			break
		end
	end
	__S服务:输出("线性加载了["..#arr.."]个单独假人,当前单独假人总数为["..#self.botList.."]")
end

-- 按照时间和数量增加队伍假人
function BotDb:teamBotAdd(num)
	if (#self.temp_teamBotList) == 0 then
		return
	end
	local arr = {}
	for i=1,num do
		arr[i] = self.temp_teamBotList[1]
		self.teamList[#self.teamList+1] = arr[i]
		table.remove(self.temp_teamBotList,1)
		local t_arr = arr[i]:getAllBot()
		for t=1,#t_arr do
			BotCtrl:sendMsg2Map( 1006, t_arr[t], t_arr[t].地图数据.编号)
		end
		if (#self.temp_teamBotList) == 0 then
			break
		end
	end
	__S服务:输出("线性加载了["..#arr.."]个组队假人,当前组队假人总数为["..#self.teamList.."]")
end

function BotDb:timeLoop( time )
	for i=1,#self.botList do
		self.botList[i]:timeLoop(time)
	end

	for i=1,#self.teamList do
		self.teamList[i]:timeLoop(time)
	end
end

-- 发送已经在线的假人到指定地图里
function BotDb:sendBotList2User(mapId,cid,userid)
	local arr = {}
	for i=1,#self.botList do
		if self.botList[i]:getMapId()==mapId then
			self.botList[i].bot.x = self.botList[i].bot.地图数据.x
			self.botList[i].bot.y = self.botList[i].bot.地图数据.y
			arr[#arr+1] = self.botList[i].bot
		end
	end
	BotCtrl:sendBotList2User(arr,cid,userid)
end

function BotDb:sendTeamBotList2User(mapId,cid,userid)
	local arr = {}
	for i=1,#self.teamList do
		if self.teamList[i]:getMapId()==mapId then
			local t_arr = self.teamList[i]:getAllBot()
			for t=1,#t_arr do
				arr[#arr+1] = t_arr[t]
			end
		end
	end
	BotCtrl:sendBotList2User(arr,cid,userid,true)
end


return BotDb