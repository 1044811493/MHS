-- @作者: CoderM
-- @邮箱:  coderm@qq.com
-- @创建时间:   2020-05-26 22:08:14
-- @最后修改来自: CoderM
-- @Last Modified time: 2020-06-07 18:20:04



-- 机器人的实体控制类

local BotCtrl = class()


function BotCtrl:初始化( ... )
	-- 最小生成战斗时间
	self.time_fight_begin_min = 0
	-- 最大生成战斗时间
	self.time_fight_begin_max = 0
	-- 最小战斗结束时间
	self.time_fight_end_min = 0
	-- 最大战斗结束时间
	self.time_fight_end_max = 0
	-- 最小跑动时间间隔
	self.time_run_min = 0
	-- 最大时间跑动间隔
	self.time_run_max = 0

	-- 生成机器人的线性时间,基于分钟
	self.time_create = 0
	-- 单次增加多少机器人
	self.create_num = 0


	-- 秒钟时间计数
	self.timeCnt = 0

	-- 分钟计数
	self.minCnt = 0
	-- 等待给玩家发送的单独假人
	self.waitAloneBot = {
	-- [3213] = {1,2,3}
	}
end

-- 获取一个随机的战斗开始时间
function BotCtrl:getTime_fight_begin()
	return self.timeCnt+math.random(self.time_fight_begin_min,self.time_fight_begin_max)
end
-- 获取一个随机的战斗结束时间
function BotCtrl:getTime_fight_end()
	return self.timeCnt+math.random(self.time_fight_end_min,self.time_fight_end_max)
end
-- 获取一个随机的跑路时间
function BotCtrl:getTime_run()
	return self.timeCnt+math.random(self.time_run_min,self.time_run_max)
end

function BotCtrl:minLoop( )
	self.minCnt = self.minCnt + 1
	if self.minCnt % self.time_create == 0 then
		BotDb:botAdd(self.create_num)
		BotDb:teamBotAdd(self.create_num)
	end
end

-- 跑路机器人的时间循环
function BotCtrl:timeLoop()
	self.timeCnt = self.timeCnt + 1
	if self.timeCnt %60 == 0 then
		self:minLoop()
	end
	BotDb:timeLoop(self.timeCnt)
end


-- 初始化线性增长
function BotCtrl:initShowNumberCtrl(arr)
	self.time_create = arr[1]
	self.create_num = arr[2]
end

-- 初始化战斗时间序列
function BotCtrl:initFightTime(fightTime)
	self.time_fight_begin_min = fightTime[1]
	self.time_fight_begin_max = fightTime[2]
	self.time_fight_end_min = fightTime[3]
	self.time_fight_end_max = fightTime[4]
end

-- 初始化跑动时间序列
function BotCtrl:initRunTime(runTime)
	self.time_run_min = runTime[1]
	self.time_run_max = runTime[2]
end


-- 向同一地图的玩家广播数据
function BotCtrl:sendMsg2Map( 序号, 内容, 地图)
	for n, v in pairs(地图处理类.地图玩家[地图]) do
		发送数据(玩家数据[n].连接id,序号,内容)
	end

	-- 地图处理类:发送数据(999999999, 序号, 内容, 地图)
end

-- 向单一玩家发送所有机器人信息
function BotCtrl:sendBotList2User( botArr ,id,userid,isTeam)
		if isTeam then
			local a = self.waitAloneBot[userid]
			local b = botArr
			local c = {}
		    for k,v in pairs(a) do
				flag = false
				for key,value in pairs(c) do
					if value == v then
						flag = true
					end
				end
				if flag == false then
					table.insert(c,v)
				end
			end

			for k,v in pairs(b) do
				flag = false
				for key,value in pairs(c) do
					if value == v then
						flag = true
					end
				end
				if flag == false then
					table.insert(c,v)
				end
			end
			self.waitAloneBot[userid] = c
		else
			self.waitAloneBot[userid] = botArr
		end
end
function BotCtrl:mapMsgLoop()
	for i,v in pairs(self.waitAloneBot) do
		if self.waitAloneBot[i] ~= nil and #self.waitAloneBot[i] ~= 0 then
			local arr = self.waitAloneBot[i]
			arr[1].x = arr[1].地图数据.x
			arr[1].y = arr[1].地图数据.y
			发送数据(玩家数据[i].连接id,1006,arr[1])
			table.remove(arr, 1)
		end
	end
end

function BotCtrl:userLeave(userid )
	self.waitAloneBot[userid] = nil
	-- table.remove(self.waitAloneBot, userid)
end

function BotCtrl:sendBot(map,cid,userid)
	-- 发送单独的假人
	BotDb:sendBotList2User(map,cid,userid)
	-- 发送组队的假人
	BotDb:sendTeamBotList2User(map,cid,userid)
end



return BotCtrl