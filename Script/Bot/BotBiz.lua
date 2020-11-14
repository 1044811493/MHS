-- @作者: CoderM
-- @邮箱:  coderm@qq.com
-- @创建时间:   2020-05-29 20:36:44
-- @最后修改来自: CoderM
-- @Last Modified time: 2020-06-07 14:07:22
-- 机器人的基础类

local BotBiz = class()

-- {
-- 	称谓 = "", 等级 = 60, 名称 = "普通假人1", 造型 = "飞燕女", 地图数据 = {
-- 		y = 1540,
-- 		x = 1980,
-- 		编号 = 1044
-- 	}, 渡劫开关 = false, 光环 = "", 名称特效 = "", 武器数据 = {
-- 		等级 = 120,
-- 		强化 = 1,
-- 		名称 = "别情离恨",
-- 		类别 = "环"
-- 	}, 摊位名称 = "", 队长 = false, 锦衣 = "", 门派 = "大唐官府", 染色 = {
-- 		b = 0,
-- 		c = 0,
-- 		a = 0
-- 	}, 足迹 = "", 战斗 = 0, id = 999999
-- }


-- 初始化创建一个Bot
function BotBiz:初始化(bot)
	self.bot = bot

	-- 随机跑动时间的计数
	self.target_run = 0
	-- 随机开始战斗的计数
	self.target_fight_begin = 0
	-- 随机计数战斗的计数
	self.target_fight_end = 0

	self.timeCnt = 0
end

-- 获取地图ID编号
function BotBiz:getMapId()
	return self.bot.地图数据.编号
end

-- 是否是队长
function BotBiz:isCaptain()
	return  self.bot.队长
end

-- 是否处于战斗状态
function BotBiz:isFight()
	return self.bot.战斗 == 1
end

function BotBiz:isOpenFight( ... )
	return self.bot.开启战斗 or false
end

-- 不带战斗的逻辑处理,wait就是一直等着
function BotBiz:logic_noFight( ... )
	local state = {}
	-- 不带战斗就好说了,到达时间则重新生成跑路时间,返回
	if self.timeCnt == self.target_run then
		state.type = "run"
		local pos = self:getRandomPos()
		state.x = pos.x
		state.y = pos.y
		self.target_run = BotCtrl:getTime_run()
		self:run(pos.x,pos.y)
	else
		state.type = "wait"
		if self.target_run == 0 then
			self.target_run = BotCtrl:getTime_run()
		end
	end
	return state
end

-- 带战斗的逻辑处理
function BotBiz:logic_fight()
	local state = {}
	if self:isFight() then
		-- 当前整处于战斗中,判断是不是到了战斗结束的时间了
		if self.target_fight_end == 0 then
			-- 开始生成战斗结束的时间
			state.type = "wait" --这种操作状态不做任何操作
			self.target_fight_end = BotCtrl:getTime_fight_end()
		elseif self.target_fight_end == self.timeCnt then
		    -- 到了战斗结束的时候了,这里开始准备结束战斗
		    state.type = "fightEnd"
		    self:fightEnd()
		    -- 生成跑动时间
		    self.target_run = BotCtrl:getTime_run()
		else
		    state.type = "wait"
		end
	else
		if self.target_run == 0 and self.target_fight_begin==0 then
			-- 准备生成跑路信息
			state.type = "wait"
			self.target_run = BotCtrl:getTime_run()
		elseif self.target_run==self.timeCnt then
		    state.type = "run"
		    local pos = self:getRandomPos()
			state.x = pos.x
			state.y = pos.y
			self:run(pos.x,pos.y)
			self.target_run = 0
			-- 开始生成战斗开始的时间
			self.target_fight_begin = BotCtrl:getTime_fight_begin()
		elseif self.target_fight_begin==self.timeCnt then
		    -- 发送战斗开始信息
		    state.type = "fightBegin"
		    self.target_fight_begin = 0
		    self:fightBegin()
		    -- 生成等待战斗结束的消息
		    self.target_fight_end = BotCtrl:getTime_fight_end()
		else
		    state.type = "wait"
		end
	end
	return state
end

-- 时间循环
function BotBiz:timeLoop(time)
	self.timeCnt = time
	-- 状态机主要是为了给队伍假人做兼容用的
	local state = {}

	if not self:isOpenFight() then
		return self:logic_noFight()
	else
		return self:logic_fight()
	end
end

-- 战斗开始
function BotBiz:fightBegin()
	self.bot.战斗开关 = true
	BotCtrl:sendMsg2Map(4014,{id=self.bot.id,逻辑=true},self.bot.地图数据.编号)
end

-- 战斗结束
function BotBiz:fightEnd()
	self.bot.战斗开关 = false
	BotCtrl:sendMsg2Map(4014,{id=self.bot.id,逻辑=false},self.bot.地图数据.编号)
end

-- 机器人跑动
function BotBiz:run(t_x,t_y)
	if t_x==nil then t_x = math.random(self.bot.地图数据.x-50,self.bot.地图数据.x+50) end
	if t_y==nil then t_y = math.random(self.bot.地图数据.y-50,self.bot.地图数据.y+50) end
	local x = t_x
	local y = t_y
	if x < 0 then x = 0 end
	if y < 0 then y = 0 end
	-- 假人位置如果写死了,那么生成坐标点的时候,有可能客户端会报错
	-- self.bot.地图数据.x = x
	-- self.bot.地图数据.y = y
	local ctx = {
		路径 = {
			x = math.floor(x/20),
			y = math.floor(y/20),
		序号 = 1002,
		距离= 0,
		数字id = self.bot.id
		},
		数字id= self.bot.id
	}
	BotCtrl:sendMsg2Map(1008,ctx,self.bot.地图数据.编号)
end

-- 获取一个随机坐标
function BotBiz:getRandomPos()
	local pos = {}
	pos.x = math.random(self.bot.地图数据.x-500,self.bot.地图数据.x+500)
	pos.y = math.random(self.bot.地图数据.y-500,self.bot.地图数据.y+500)
	return pos
end

-- 机器人停止跑动
function BotBiz:stopRun()
	local ctx = {
		id = self.bot.id,
		文本 = self.bot.id
	}
	-- BotCtrl:sendMsg2Map(1006,ctx,self.bot.地图数据.编号)
end

return BotBiz