local BoothBot = class()
-- 这里存放地图对应索引下的假人ID



function BoothBot:初始化()
    self.open = false
    self.maplist = {
        [1001] = {},
        [1501] = {},
        [1092] = {},
        [1070] = {},
        [1040] = {},
        [1226] = {},
        [1208] = {}
    }
    self.npcUserList = {}
    __S服务:输出("BoothBot:初始化")
end

function BoothBot:addBoothNpc(数据源)
    count = 0
    tbl = {}
    for i = 1, #数据源 do
        count = count + 1
        假人 = 数据源[i]
        tbl = self.maplist[假人[1]]
        -- 这里将假人放到地图数据中
        table.insert(tbl, 假人)
        key = "" .. 假人[4]
        self.npcUserList[key] = 假人
    end
    print("CoderM:添加了[" .. count .. "]个摆摊假人")
end

-- 获取所有地图上的摆摊NPC数据
function BoothBot:getAllBoothNpcinMap(mapId)
    if (self.maplist[mapId] == nil) then
        return {}
    end
    return self.maplist[mapId]
end

-- 根据ID获取具体的假人信息
function BoothBot:getById(id)
    return self.npcUserList["" .. id]
end
function BoothBot:setOpen(open)
    self.open = open
end
-- 发送给玩家假人摊位列表
function BoothBot:sendBoothList(id, mapid,sendFunc)
if self.open ~= true then
    return
end
    mapBoothNpcs = self:getAllBoothNpcinMap(mapid)
    for i = 1, #mapBoothNpcs do
        ndata = mapBoothNpcs[i]
        -- {地图ID,x坐标,y坐标,假人ID,假人名称,摊位名称,模型名称}
        local ctx = {
            x = ndata[2],
            y = ndata[3],
            id = ndata[4],
            名称 = ndata[5],
            摊位名称 = ndata[6],
            模型 = ndata[7],
            战斗开关 = flase,
            染色组 = {},
            染色方案 = 0
        }
        -- {x=1021,名称="大萨达",y=2289,摊位名称="杂货摊位",战斗开关=false,id=4000131,染色组={},染色方案=0,模型="鬼潇潇"}
        发送数据(id,1006,ctx)

    end
end

function BoothBot:sendBotBooth(id,botId)
	local bot = self:getById(botId)
	if bot ~= nil then
		local ctx = {
            bb={},
            摊主名称=bot[5],
            物品= {},
            名称= bot[6],
            id = botId
        }
        发送数据(id,3521,ctx)
	end
	-- do local ret={序号=3521,内容={bb={},摊主名称="大萨达",物品={},名称="杂货摊位",id=4000131}} return ret end
end


return BoothBot