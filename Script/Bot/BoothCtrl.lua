-- @作者: CoderM
-- @邮箱:  coderm@qq.com
-- @创建时间:   2020-05-28 20:00:07
-- @最后修改来自: CoderM
-- @Last Modified time: 2020-08-29 00:21:08
local BoothCtrl = class()

function BoothCtrl:初始化( ... )
	-- 分钟计时
	self.minCnt = 0

	-- 秒钟计时
	self.timeCnt = 0

	-- 增加机器人的时间
	self.time_create = 0

	-- 单次增加多少个机器人
	self.create_num = 0

	-- 等待给玩家发送的单独假人
	self.waitAloneBot = {}
end

function BoothCtrl:minLoop( ... )
	self.minCnt = self.minCnt+1
	BoothDb:boothAdd(self.create_num)
end
function BoothCtrl:timeLoop( ... )
	self.timeCnt = self.timeCnt+1
	if self.timeCnt%60==0 then
		self:minLoop()
	end
end

-- 如果摆摊处理类里遇到的参数 是假人的数据,那么在这里进行处理,成功在此处理返回真,失败处理返回假
function BoothCtrl:MsgCtrl(id, msgIdx, arg, ctx)
	if msgIdx == 3725 then
		if not BoothDb:isBot(ctx.id) then return false end
		local bot = BoothDb:getBotById(ctx.id)
		发送数据(玩家数据[arg].连接id,3520,玩家数据[arg].角色.银子)
 		发送数据(玩家数据[arg].连接id,3521,{
 			bb=bot:getBBTable(),
 			物品=bot:getItemTable(),
 			id=arg,
 			摊主名称=bot.bot.摊位名称,
 			名称=bot.bot.名称
 		})
 		玩家数据[arg].摊位查看=os.time()
 		玩家数据[arg].摊位id=ctx.id
 		return true
	elseif msgIdx == 3726 then
		if not BoothDb:isBot(玩家数据[arg].摊位id) then return false end
		local bot = BoothDb:getBotById(玩家数据[arg].摊位id)
		if ctx.bb == nil then
			self:buyItem(id,arg,ctx.道具,ctx.数量)
		elseif ctx.道具==nil then
			self:buyBB(arg,ctx.bb)
		end
		玩家数据[arg].摊位查看 = os.time() + 1

		玩家数据[arg].摊位id = bot.bot.id

		发送数据(玩家数据[arg].连接id,3520,玩家数据[arg].角色.银子)
		发送数据(玩家数据[arg].连接id,3522,{
			bb=bot:getBBTable(),
			物品=bot:getItemTable(),
			id=bot.bot.id,
			摊主名称=bot.bot.摊位名称,
			名称=bot.bot.名称
		})
		syslog("buyOver")
		-- 发送数据(玩家数据[id].连接id,3517,{
		-- 	bb=bot:getBBTable(),
		-- 	物品=bot:getItemTable(),
		-- 	id=bot.bot.id,
		-- 	摊主名称=bot.bot.摊位名称,
		-- 	名称=bot.bot.名称
		-- })
	    return true
	end

	return false
end

-- 购买道具
function BoothCtrl:buyItem(id,userid,idx,num)

	local bot = BoothDb:getBotById(玩家数据[userid].摊位id)
	local lastTime = 玩家数据[userid].摊位查看

	-- 查看是不是最新的
	if not bot.itemTable:isNew(lastTime) then
		发送数据(id, 7,"#y/这个摊位的数据已经发生了变化，请重新打开该摊位")
		bot.itemTable:refresh()
		return
	end

	local item = bot:getItemTable()[idx]

	-- 查看商品是否存在
	if item == nil then
		发送数据(id, 7,"#Y/这个商品并不存在")
		bot.itemTable:refresh()
		return
	end

	-- 判断玩家身上包裹够不够
	local 临时格子=玩家数据[userid].角色:取道具格子()
	if 临时格子==0 then
		发送数据(id, 7,"#Y/请先整理下包裹吧！")
		return
	end

	-- 查看商品的数量是否足够
	if item.数量 == nil then
		item.数量 = 1
	end
	if num <= 0 or num > 99 or item.数量 < num then
		发送数据(id, 7, "#y/请输入正确的购买数量")
		return
	end

	-- 拿到物品的单价
	local price = item.价格 * num
	local userMoney = 玩家数据[userid].角色.银子
	-- 计算价格
	if userMoney < price then
		发送数据(id, 7, "#y/你没有那么多的银子")
		return
	end

	-- 开始购买
	玩家数据[userid].角色:扣除银子(price,0,0,"摊位购买",1)
	local 临时格子=玩家数据[userid].角色:取道具格子()
	local 道具id=玩家数据[userid].道具:取新编号()
	local 道具名称=item.名称
	local 道具识别码=item.识别码
	更改道具归属(道具识别码,"bot"..bot.bot.id,bot.bot.id,bot.bot.名称)
	玩家数据[userid].角色:日志记录(format("[摊位系统-购买]购买道具[%s][%s]，花费%s两银子,出售者信息：[%s][%s][%s]",道具名称,道具识别码,price,"bot"..bot.bot.id,bot.bot.id,bot.bot.名称))
	玩家数据[userid].道具.数据[道具id]=table.loadstring(table.tostring(item))
	玩家数据[userid].角色.道具[临时格子]=道具id

	发送数据(id, 7, "#W/购买#R/"..道具名称.."#W/成功！")
	if item.数量 == nil then
		bot:getItemTable()[idx] = nil
	else
	    bot:getItemTable()[idx].数量 = bot:getItemTable()[idx].数量 - num
	    if bot:getItemTable()[idx].数量 <=0 then
	    	bot:getItemTable()[idx] = nil
	    end
	end
	玩家数据[userid].摊位查看 = os.time() + 1
	bot.bbTable:refresh()
	道具刷新(userid)
end

-- 购买宝宝
function BoothCtrl:buyBB(id,idx)
	local bot = BoothDb:getBotById(玩家数据[id].摊位id)
	local lastTime = 玩家数据[id].摊位查看
	-- 查看是不是最新的
	if not bot.bbTable:isNew(lastTime) then
		发送数据(玩家数据[id].连接id, 7, "#y/该摊位商品发生了变化，请稍后再试")
		bot.bbTable:refresh()
		return
	end

	local bbTable = bot:getBBTable()[idx]
	-- 查看宝宝是否存在
	if bbTable == nil  then
		发送数据(玩家数据[id].连接id, 7, "#Y/这只召唤兽不存在")
		return
	end

	local price=bbTable.价格

	if #玩家数据[id].召唤兽.数据 >= 7 then
		发送数据(玩家数据[id].连接id, 7, "#y/您当前无法携带更多的召唤兽了")
		return 0
	end

	if 玩家数据[id].角色.银子<price then
		发送数据(玩家数据[id].连接id, 7, "#y/您没有那么多的银子")
		return 0
	end

	local 道具名称=bbTable.名称
	local 道具等级=bbTable.等级
	local 道具模型=bbTable.模型
	local 道具技能=#bbTable.技能

	local 道具识别码=bbTable.认证码
	玩家数据[id].角色:扣除银子(price,0,0,"摊位购买",1)
	玩家数据[id].角色:日志记录(format("[摊位系统-购买]购买道具[%s][%s]，花费%s两银子,出售者信息：[%s][%s][%s]",道具名称,道具识别码,price,"bot"..bot.bot.id,bot.bot.id,bot.bot.名称))
	发送数据(玩家数据[id].连接id,7, "#W/购买#R/"..道具名称.."#W/成功！")
	玩家数据[id].召唤兽.数据[#玩家数据[id].召唤兽.数据+1]=table.loadstring(table.tostring(bbTable))

	local 宝宝=宝宝类.创建()
	宝宝:加载数据(玩家数据[id].召唤兽.数据[#玩家数据[id].召唤兽.数据])
	玩家数据[id].召唤兽.数据[#玩家数据[id].召唤兽.数据]=宝宝
	bot:getBBTable()[idx]=nil
	发送数据(玩家数据[id].连接id,3512,玩家数据[id].召唤兽.数据)
	bot.bbTable:refresh()
end


function BoothCtrl:userLeave(userid )
	self.waitAloneBot[userid] = nil
	-- table.remove(self.waitAloneBot, userid)
end

-- 初始化增加机器人的时间
function BoothCtrl:initAddTime(arr)
	self.time_create = arr[1]
	self.create_num = arr[2]
end

function BoothCtrl:sendBoothBot(mapId,cid,userid)
	BoothDb:sendBoothBot(mapId,cid,userid)
end
function BoothCtrl:mapMsgLoop()
	for i,v in pairs(self.waitAloneBot) do
		if self.waitAloneBot[i] ~= nil and #self.waitAloneBot[i] ~= 0 then
			local arr = self.waitAloneBot[i]
			-- arr[1].x = arr[1].地图数据.x
			-- arr[1].y = arr[1].地图数据.y
			发送数据(玩家数据[i].连接id,1006,arr[1].bot)
			-- syslog(#arr)
			table.remove(arr, 1)
		end
	end
end
-- 向单一玩家发送所有机器人信息
function BoothCtrl:sendBotList2User( botArr ,id,userid)
		self.waitAloneBot[userid] = table.loadstring(table.tostring(botArr))
end

-- 向同一地图的玩家广播数据
function BoothCtrl:sendMsg2Map( 序号, 内容, 地图)
	for n, v in pairs(地图处理类.地图玩家[地图]) do
		发送数据(玩家数据[n].连接id,序号,内容)
	end
end

return BoothCtrl