-- @作者: CoderM
-- @邮箱:  coderm@qq.com
-- @创建时间:   2020-05-27 21:06:21
-- @最后修改来自: CoderM
-- @Last Modified time: 2020-08-29 00:39:30

-- 喊话专用
local ChatDb = class()

function ChatDb:初始化( ... )
	-- 基础喊话内容
	self.wordChatBase = ""

	-- 世界喊话内容
	self.wordChatList = {}

	-- 系统喊话奖励内容
	self.systemChatList = {}

	-- 系统奖励的物品列表
	self.itemList = {}

	-- 奖励的玩家名字
	self.nameList = {}
    math.randomseed(tostring(os.clock()):reverse():sub(1, 7))
end


-- 初始化世界喊话内容
function ChatDb:initWordChatList(arrSrc)
	local count = 0
    for i = 1, #arrSrc do
        count = count + 1
        self.wordChatList[count] = arrSrc[i]
    end
    __S服务:输出("CoderM:添加了[" .. count .. "]条世界喊话内容")
end

-- 初始化系统奖励
function ChatDb:initSystemList(arr)
	local count = 0
    for i = 1, #arr do
        count = count + 1
        self.systemChatList[count] = arr[i]
    end
    __S服务:输出("CoderM:添加了[" .. count .. "]条系统喊话内容")
end

-- 设置基础喊话内容
function ChatDb:setWordChatBase(chatBase)
	self.wordChatBase = chatBase
end

function ChatDb:getWordChatBase()
	-- 这里防止原始值被改掉,需要获取一个新的引用信息来返回
	return self.wordChatBase .. " "
end

-- 初始化名称列表
function ChatDb:initNameList(arrSrc)
	local count = 0
    for i = 1, #arrSrc do
        count = count + 1
        self.nameList[count] = arrSrc[i]
    end
    __S服务:输出("CoderM:添加了[" .. count .. "]条假人名称")
end

-- 初始化奖励道具列表
function ChatDb:initItemList(arrSrc)
	local count = 0
    for i = 1, #arrSrc do
        count = count + 1
        self.itemList[count] = arrSrc[i]
    end
    __S服务:输出("CoderM:添加了[" .. count .. "]个奖励道具")
end

-- 随机获取一句喊话内容
function ChatDb:getRandomWordChat()
	local idx = math.random(1,#self.wordChatList)
	return self.wordChatList[idx].. " ".."#"..math.random(1,110)
end

-- 随机获取一个活动的奖励喊话
function ChatDb:getRandomSystemChat()
	local idx = math.random(1,#self.systemChatList)
	return self.systemChatList[idx] .. " ".."#"..math.random(1,110)
end

-- 随机获取一个奖励物品字符串
function ChatDb:getRandomItemName()
	local idx = math.random(1,#self.itemList)
	return self.itemList[idx] .." "
end

-- 随机获取一个名称
function ChatDb:getRandomName(cnt)
    local count = 0
	if cnt >= 5 then
		count = 5
    else
        count = 1
    end
	local arr = {}
	self.nameList = self:shuffle(self.nameList)
	for i = 1,count do
	    arr[i] = self.nameList[i]
	end
	return arr
end

--将数组顺序随机打乱
function ChatDb:shuffle(t)
    if type(t)~="table" then
        return
    end
    local tab={}
    local index=1

    while #t~=0 do
        local n=math.random(0,#t)
        if t[n]~=nil then
            tab[index]=t[n]
            table.remove(t,n)
            index=index+1
        end
    end
    return tab
end

return ChatDb