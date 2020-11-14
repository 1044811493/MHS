-- @作者: CoderM
-- @邮箱:  coderm@qq.com
-- @创建时间:   2020-05-28 19:58:49
-- @最后修改来自: CoderM
-- @Last Modified time: 2020-06-05 15:41:15

local ChatCtrl = class()

function ChatCtrl:初始化( ... )
	-- 最小世界说话间隔
	self.wordMinTime = 0
	-- 最大世界说话间隔
	self.wordMaxTime = 0

	-- 最小系统广播间隔
	self.sysBroadMinTime = 0
	-- 最大系统广播间隔
	self.sysBroadMaxTime = 0

	-- 如果设置没有初始化成功,则喊话处理不会生效
	self.state_wordInited = false
	self.state_sysInited = false

	-- 用来标记世界聊天的时间指针
	self.timeCnt_word = 0
	-- 用来标记系统聊天的时间指针
	self.timeCnt_sys = 0

	-- 记录最终随机生成的聊天时间结果
	self.chat_target_word = -1
	self.chat_target_sys = -1
end

function ChatCtrl:initWordChatTime(cfgArr)
	self.wordMinTime = cfgArr[1]
	self.wordMaxTime = cfgArr[2]
	self.state_wordInited = true
	self.chat_target_word = 0
end

function ChatCtrl:initSysChatTime(cfgArr)
	self.sysBroadMinTime = cfgArr[1]
	self.sysBroadMaxTime = cfgArr[2]
	self.state_sysInited = true
	self.chat_target_sys = 0
end

-- 时间循环
function ChatCtrl:timeLoop()
	-- 增加计时
	self.timeCnt_sys = self.timeCnt_sys+1
	self.timeCnt_word = self.timeCnt_word+1
	if self.chat_target_sys == 0 then
		self.chat_target_sys = math.random(self.sysBroadMinTime,self.sysBroadMaxTime)
	end
	if self.chat_target_word == 0 then
		self.chat_target_word = math.random(self.wordMinTime,self.wordMaxTime)
	end
	self:checkTime()
end

function ChatCtrl:checkTime()
	if self.chat_target_word == self.timeCnt_word then
		self:sendWordChat()
		self.chat_target_word = 0
		self.timeCnt_word = 0
	end
	if self.chat_target_sys == self.timeCnt_sys then
		self:sendSysChat()
		self.chat_target_sys = 0
		self.timeCnt_sys = 0
	end
end

function ChatCtrl:sendWordChat()
	local nameArr = ChatDb:getRandomName(1)
	local str = ChatDb:getWordChatBase()
	local word = ChatDb:getRandomWordChat()
	-- local ctx = string.gsub(str, "ctx", word)
	local ctx = word
	for i=1,#nameArr do
		-- local t_ctx = string.gsub((ctx.." "), "name", nameArr[i])
	   广播消息({内容="["..nameArr[i].."]"..ctx,频道="sj"})
	end
end

function ChatCtrl:sendSysChat()
	local nameArr = ChatDb:getRandomName(math.random(0,10))
	local item = ChatDb:getRandomItemName()
	local str = ChatDb:getRandomSystemChat()
	local ctx = string.gsub(str, "ctx", item)
	for i=1,#nameArr do
		local t_ctx = string.gsub((ctx.." "), "name", nameArr[i])
		广播消息({内容=t_ctx,频道="xt"})
	end
end

return ChatCtrl