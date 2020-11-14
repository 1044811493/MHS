--======================================================================--
-- @作者: GGE研究群: 342119466
-- @创建时间:   2018-03-03 02:34:19
-- @Last Modified time: 2020-04-20 11:15:36
-- 梦幻西游游戏资源破解 baidwwy@vip.qq.com(313738139) 老毕   和 C++PrimerPlus 717535046 这俩位大神破解所以资源
--======================================================================--
local 场景类_对话帮派商业栏 = class()
local format = string.format
local insert = table.insert
local ceil = math.ceil
local floor = math.floor
local wps = 取物品数据
local typ = type
local 五行_ = {"金","木","水","火","土"}
function 场景类_对话帮派商业栏:初始化() end

function 场景类_对话帮派商业栏:购买商品(连接id,id,序号,内容)
  self.商品匹配=false

  if type(玩家数据[id].商品列表)~="table" then
    异常账号(id,"未触发商品界面却触发购买请求。请求购买的商品数据为："..内容.商品)
    return 0
  else
    self.组合商品=""
    for n=1,#玩家数据[id].商品列表 do
      self.组合商品=self.组合商品..玩家数据[id].商品列表[n]
      if 玩家数据[id].商品列表[n]==内容.商品 then
        self.商品匹配=true
      end
    end
    if self.商品匹配==false then
      异常账号(id,"所购买的商品不再列表之类。商品列表为"..self.组合商品.."购买商品为"..内容.商品)
      return 0
    end
  end

  if 内容.数量==nil then
    内容.数量=""
  end
  if type(内容.数量)~="number" or 内容.数量<=0 or 内容.数量>99 then
    异常账号(id,"所购买的商品数量异常，提交的商品数量为"..内容.数量)
    return 0
  end
  --先获取一次格子
  local 道具格子=玩家数据[id].角色:取道具格子()
  if 道具格子==0 then
    常规提示(id,"您的道具栏物品已经满啦")
    return 0
  end
  local 商品分割=分割文本(内容.商品,"*")
  local 商品名称=商品分割[1]
  local 商品单价=商品分割[2]
  local 商品数量=内容.数量
  local 商品道具=物品类()
  local 道具格子=0
  local 临时id=0
  local 找到id=0
  商品道具:置对象(商品名称)
  --先计算是否可重叠

  if 商品道具.可叠加 == nil or 商品道具.可叠加 == false then

  else
    local 总价格=商品数量*商品单价
    道具格子=玩家数据[id].角色:取道具格子()
    if 道具格子==0 then
      常规提示(id,"您的道具栏物品已经满啦")
      return 0
    end
    local 检测通过 = false
    for i=1,20 do
      临时id = 玩家数据[id].角色.数据.道具[i]
      if 玩家数据[id].道具.数据[临时id] ~= nil then
        if 玩家数据[id].道具.数据[临时id].名称 == "帮派银票" then
          if 玩家数据[id].道具.数据[临时id].初始金额  >= 玩家数据[id].道具.数据[临时id].完成金额 then
            常规提示(id,"您的银票已经达到了上交要求,请及时前去完成任务！")
            return 0
          end
          if 玩家数据[id].道具.数据[临时id].初始金额 < 总价格 then
            常规提示(id,"您身上的帮派银票似乎不够哟")
            return 0
          end
          检测通过 = true
          找到id=临时id
        end
      end
    end
    道具格子=玩家数据[id].角色:取道具格子()
    if 道具格子==0 then
      常规提示(id,"您的道具栏物品已经满啦")
      return 0
    elseif 检测通过 == false then
      常规提示(id,"你身上的银票跑到哪里去了")
      return 0
    end
    玩家数据[id].道具.数据[找到id].初始金额 = 玩家数据[id].道具.数据[找到id].初始金额 - 总价格
    道具编号=玩家数据[id].道具:取新编号()
    玩家数据[id].道具.数据[道具编号]=复制物品(商品道具)
    玩家数据[id].道具.数据[道具编号].数量=商品数量
    玩家数据[id].道具.数据[道具编号].单价 = 跑商[商品名称]
    玩家数据[id].角色.数据.道具[道具格子]=道具编号
    常规提示(id,"您花费"..总价格.."两帮派银子购买了"..商品名称.."*"..商品数量)
    道具刷新(id)
  end
end

function 场景类_对话帮派商业栏:出售商品(连接id,id,序号,内容)
  local 临时id = 玩家数据[id].角色.数据.道具[内容.物品]
  local 跑商商品 = 玩家数据[id].道具.数据[临时id]
  if 跑商商品 == nil then
      常规提示(id,"请确认下身上是否有该商品！")
      return 0
  elseif 跑商商品.总类 ~= "跑商商品" then
      常规提示(id,"该物品无法在这里出售")
      return 0
  elseif 内容.数量 == 0 then
      常规提示(id,"你要出售的物品呢")
      return 0
  elseif 内容.数量 > 跑商商品.数量 then
      常规提示(id,"你没有那么多的商品出售")
      return 0
  end
  local 总价格 = 内容.单价 * 内容.数量
  玩家数据[id].道具.数据[临时id].数量 = 玩家数据[id].道具.数据[临时id].数量 - 内容.数量
  if 玩家数据[id].道具.数据[临时id].数量 <= 0 then
     玩家数据[id].道具.数据[临时id] =nil
  end
  for i=1,20 do
      self.临时id = 玩家数据[id].角色.数据.道具[i]
      if 玩家数据[id].道具.数据[self.临时id] ~= nil then
          if 玩家数据[id].道具.数据[self.临时id].名称 == "帮派银票" then
              玩家数据[id].道具.数据[self.临时id].初始金额 = 玩家数据[id].道具.数据[self.临时id].初始金额 + 总价格
              if 玩家数据[id].道具.数据[self.临时id].初始金额 >= 玩家数据[id].道具.数据[self.临时id].完成金额 then
                  常规提示(id,"你已经完成了跑商任务，快去找金库总管领取奖励吧！")
              end
          end
      end
  end
  常规提示(id,"卖出"..跑商商品.名称.."*"..内容.数量.."获得了"..总价格.."两帮派银子")

  道具刷新(id)
end

function 场景类_对话帮派商业栏:更新(dt)end
function 场景类_对话帮派商业栏:显示(x,y)end

return 场景类_对话帮派商业栏