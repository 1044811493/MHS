-- @作者: CoderM
-- @邮箱:  coderm@qq.com
-- @创建时间:   2020-05-29 20:39:23
-- @最后修改来自: CoderM
-- @Last Modified time: 2020-05-30 18:17:28

-- 保存队伍的数据


local TeamBotBiz = class()


function TeamBotBiz:初始化(botList)
	-- syslog(json.encode(botList))
	--  单独保存队长
	self.captainBot = nil
	-- 保存队员
	self.teamList = {}

	for i=1,#botList do
		local t_b = BotBiz.创建(botList[i])
		if t_b:isCaptain() then
			self.captainBot = t_b
		else
		    self.teamList[#self.teamList+1] = t_b
		end
	end

	-- 时间计数
	self.timeCnt = 0
end

function TeamBotBiz:timeLoop(time)
	self.timeCnt = time
	local state = self.captainBot:timeLoop(time)
	if state.type == "run" then
		for i=1,#self.teamList do
			self.teamList[i]:run(math.random(state.x-100,state.x+100),math.random(state.y-100,state.y+100))
		end
	elseif state.type == "fightBegin" then
	    for i=1,#self.teamList do
			self.teamList[i]:fightBegin()
		end
	elseif state.type == "fightEnd" then
	    for i=1,#self.teamList do
			self.teamList[i]:fightEnd()
		end
	end
end

function TeamBotBiz:getMapId()
	return self.captainBot.bot.地图数据.编号
end

function TeamBotBiz:getAllBot()
	local arr = {}
	arr[#arr+1] = self.captainBot.bot
	for i=1,#self.teamList do
	 	arr[#arr+1] = self.teamList[i].bot
	end
	return arr
end

return TeamBotBiz