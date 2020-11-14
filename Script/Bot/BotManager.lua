-- @作者: CoderM
-- @邮箱:  coderm@qq.com
-- @创建时间:   2020-05-26 22:05:33
-- @最后修改来自: CoderM
-- @Last Modified time: 2020-08-29 00:19:52
-- 这里是机器人的管理类,用于管理机器人的数据

-- 其实已经用不到单例了,这里在main.lua中引用的时候已经被放到一个全局的变量里了

local BotManager = class()


-- 构造函数
function BotManager:初始化()

	__S服务:输出("=======================假人加载=====================")
	-- 从这里开始进行加载

	-- 加载聊天配置
	local chatBotCfg = table.loadstring(读入文件("tysj/Bot/ChatBot.txt"))
	-- ==========================喊话开始=========================
	-- 增加世界喊话列表
	ChatDb:initWordChatList(chatBotCfg.wordChat)
	-- 设置基础世界喊话
	ChatDb:setWordChatBase(chatBotCfg.wordChatBase)
	-- 增加系统喊话内容
	ChatDb:initSystemList(chatBotCfg.systemChat)
	-- 增加奖励道具列表
	ChatDb:initItemList(chatBotCfg.itemList)
	-- 增加喊话名字
	ChatDb:initNameList(chatBotCfg.nameList)

	-- 设置世界喊话时间
	ChatCtrl:initWordChatTime(chatBotCfg.wordTime)
	-- 设置系统喊话时间
	ChatCtrl:initSysChatTime(chatBotCfg.systemTime)

	-- ==========================喊话结束=========================

	-- ==========================机器人开始=========================
	local ftxt = 读入文件("tysj/Bot/FightBot.txt")
	local fightBotCfg = table.loadstring(ftxt)
	-- 初始化单独假人
	BotDb:initAloneDb(fightBotCfg.botList)
	-- 初始化队伍假人
	BotDb:initTeamDb(fightBotCfg.teamList)
	-- 初始化时间控制
	BotCtrl:initFightTime(fightBotCfg.fightTime)
	BotCtrl:initRunTime(fightBotCfg.runTime)
	-- 初始化线性增长
	BotCtrl:initShowNumberCtrl(fightBotCfg.botAddTime)

	-- ==========================机器人结束=========================
	local itemtxt = 读入文件("tysj/Bot/ItemTable.txt")
	local itemCfg = table.loadstring(itemtxt)

	BoothDb:initItemTable(itemCfg)

	local bbtxt = 读入文件("tysj/Bot/BBTable.txt")
	local bbCfg = table.loadstring(bbtxt)
	BoothDb:initBBTable(bbCfg)

	local boothbottxt = 读入文件("tysj/Bot/BoothBot.txt")
	local boothBotCfg = table.loadstring(boothbottxt)
	BoothCtrl:initAddTime(boothBotCfg.addTime)
	BoothDb:addBoothBot(boothBotCfg.boothList)

	-- ==========================摆摊结束=========================
	__S服务:输出("=======================假人完成=====================")
end


function BotManager:mapMsgLoop()
	-- 战斗机器人的时间循环处理
	BotCtrl:mapMsgLoop()
	-- 摆摊假人的时间循环处理
	BoothCtrl:mapMsgLoop()
end

-- 有玩家进入地图了
function BotManager:onPlayerJoin(mapid,cid,userid)
	BotCtrl:sendBot(mapid,cid,userid)
	BoothCtrl:sendBoothBot(mapid,cid,userid)
	-- syslog("=====================================onPlayerJoin")
end

-- 有玩家离开了地图
function BotManager:onPlayerLeave( userid )
	BotCtrl:userLeave(userid)
	BoothCtrl:userLeave(userid)
end

-- 基于秒的循环处理
function BotManager:secondLoop()
	-- 喊话的时间循环处理
	ChatCtrl:timeLoop()
	-- 战斗机器人的时间循环处理
	BotCtrl:timeLoop()
	-- 摆摊假人的时间循环处理
	BoothCtrl:timeLoop()
end



return BotManager