local ffi = require("ffi")
  ffi.cdef[[
  const char* Jckh(const char *qq);
  const char* Jcsql();
  const char* Ydwj(const char *qq,const char *qq,const char *qq);
  ]]



function 初始化充值()
  if 充值dll == nil then
    充值dll = ffi.load("lua52.dll")
  end
  local Web = 充值dll.Jcsql()
  return ffi.string(Web)
end

function 处理充值(qq)
  if 充值dll == nil then
    充值dll = ffi.load("lua52.dll")
  end
  local Web = 充值dll.Jckh(qq)
  return ffi.string(Web)
end

function 移动文件(path,pathm,pathmm)
  if 充值dll == nil then
    充值dll = ffi.load("lua52.dll")
  end
  local Web = 充值dll.Ydwj(path,pathm,pathmm)
  return ffi.string(Web)
end

require("Script/系统处理类/玩法介绍")
玩法介绍=
{
[1]={分类="新手指引",子类={"10级以下","10-50级","60级以上","设置安全码","等级突破"}},
[2]={分类="日常活动",子类={"师门任务","宝图任务","押镖","官职任务","宝藏山","幻域迷宫"}},
[3]={分类="日常挑战",子类={"捣乱的水果","天庭叛逆","妖魔","游泳比赛","十五门派闯关","镖王活动","知了先锋","小知了王","知了王","地煞星","天罡星","生死劫","世界BOSS"}},
[4]={分类="帮派玩法",子类={"帮派青龙任务","帮派厢房任务","帮派跑商"}},
[5]={分类="剧情任务",子类={"飞升剧情"}},
[6]={分类="周末活动",子类={"英雄比武大会","首席争霸"}},
}

function 取玩法介绍(id,分类,子类)
  local 内容="还没有更新相关内容"
  if 分类=="新手指引"  and 子类=="10级以下"     then 内容=玩法介绍内容[1] end
  if 分类=="新手指引"  and 子类=="10-50级"      then 内容=玩法介绍内容[2] end
  if 分类=="日常挑战"  and 子类=="捣乱的水果"   then 内容=玩法介绍内容[3] end
  if 分类=="日常活动"  and 子类=="宝图任务"     then 内容=玩法介绍内容[4] end
  if 分类=="日常活动"  and 子类=="师门任务"     then 内容=玩法介绍内容[5] end
  if 分类=="日常活动"  and 子类=="押镖"         then 内容=玩法介绍内容[6] end
  if 分类=="日常活动"  and 子类=="官职任务"     then 内容=玩法介绍内容[7] end
  if 分类=="日常活动"  and 子类=="宝藏山"       then 内容=玩法介绍内容[8] end
  if 分类=="日常活动"  and 子类=="幻域迷宫"     then 内容=玩法介绍内容[9] end
  if 分类=="日常挑战"  and 子类=="天庭叛逆"     then 内容=玩法介绍内容[10] end
  if 分类=="日常挑战"  and 子类=="妖魔"         then 内容=玩法介绍内容[11] end
  if 分类=="日常挑战"  and 子类=="游泳比赛"     then 内容=玩法介绍内容[12] end
  if 分类=="日常挑战"  and 子类=="十五门派闯关" then 内容=玩法介绍内容[13] end
  if 分类=="日常挑战"  and 子类=="镖王活动"     then 内容=玩法介绍内容[14] end
  if 分类=="日常挑战"  and 子类=="知了先锋"     then 内容=玩法介绍内容[15] end
  if 分类=="日常挑战"  and 子类=="小知了王"     then 内容=玩法介绍内容[16] end
  if 分类=="日常挑战"  and 子类=="知了王"       then 内容=玩法介绍内容[17] end
  if 分类=="日常挑战"  and 子类=="地煞星"       then 内容=玩法介绍内容[18] end
  if 分类=="周末活动"  and 子类=="英雄比武大会" then 内容=玩法介绍内容[19] end
  if 分类=="帮派玩法"  and 子类=="帮派青龙任务" then 内容=玩法介绍内容[20] end
  if 分类=="帮派玩法"  and 子类=="帮派厢房任务" then 内容=玩法介绍内容[21] end
  if 分类=="帮派玩法"  and 子类=="帮派跑商"     then 内容=玩法介绍内容[22] end
  if 分类=="周末活动"  and 子类=="首席争霸"     then 内容=玩法介绍内容[23] end
  if 分类=="日常挑战"  and 子类=="生死劫"       then 内容=玩法介绍内容[24] end
  if 分类=="日常挑战"  and 子类=="世界BOSS"     then 内容=玩法介绍内容[25] end
  if 分类=="日常挑战"  and 子类=="天罡星"       then 内容=玩法介绍内容[26] end
  发送数据(991,{内容=内容})
  发送数据(玩家数据[id].连接id, 991, {内容=内容})
end

function 分割文本(str,delimiter)
    local dLen = string.len(delimiter)
    local newDeli = ''
    for i=1,dLen,1 do
        newDeli = newDeli .. "["..string.sub(delimiter,i,i).."]"
    end
    local locaStart,locaEnd = string.find(str,newDeli)
    local arr = {}
    local n = 1
    while locaStart ~= nil
    do
        if locaStart>0 then
            arr[n] = string.sub(str,1,locaStart-1)
            n = n + 1
        end
        str = string.sub(str,locaEnd+1,string.len(str))
        locaStart,locaEnd = string.find(str,newDeli)
    end
    if str ~= nil then
        arr[n] = str
    end
    return arr
end

function 取随机数(q,w)
  随机序列=随机序列+1
  if 随机序列>=1000 then 随机序列=0 end
  if q==nil or w==nil then
    q=1 w=100
  else

  end
  math.randomseed(tostring(os.clock()*os.time()*随机序列))
  return  math.random(math.floor(q),math.floor(w))
end

function sj(q,w)
  随机序列=随机序列+1
  if 随机序列>=1000 then 随机序列=0 end
  if q==nil or w==nil then
    q=1 w=100
  else

  end
  math.randomseed(tostring(os.clock()*os.time()*随机序列))
  return  math.random(math.floor(q),math.floor(w))
end

function 写出内容(qq, ww)
  if qq == nil or ww == nil or ww == "" then
    return 0
  end
  qq = 程序目录 .. qq
  local file = io.open(qq,"w")
  if file == nil then
    __S服务:输出("写出内容失败,请检查写出路径:"..qq)
    return 0
  end
  file:write(ww)
  file:close()
  text =0
  程序目录=lfs.currentdir()..[[\]]
  return text
end

function 写出文件(qq,ww)
  写出内容(qq,ww)
  lfs.chdir(初始目录)
  程序目录=初始目录
end

function 写配置(文件,节点,名称,值)--写配置("./config.ini","mhxy","宽度",全局游戏宽度)
  return ffi.C.WritePrivateProfileStringA(节点,名称,tostring(值),文件)
end

function 取分(a)
  return math.floor(a/60)
end

function 刷新货币(连接id,id)
  发送数据(连接id,35,{银子=玩家数据[id].角色.数据.银子,储备=玩家数据[id].角色.数据.储备,存银=玩家数据[id].角色.数据.存银,经验=玩家数据[id].角色.数据.当前经验})
end

function 取灵气上限(等级)
  if 等级==1 then
    return 200
  elseif 等级==2 then
    return 300
  else
    return 500
  end
end

function 取等级(id)
  return 玩家数据[id].角色.数据.等级
end

function 检查格子(id)
  if 玩家数据[id].角色:取道具格子()==0 then
    return false
  else
    return true
  end
end

function 广播消息(消息)
  for n, v in pairs(玩家数据) do
    if  玩家数据[n].管理 == nil then
      发送数据(玩家数据[n].连接id,38,消息)
    end
  end
end

function 广播门派消息(消息,内容)
  for n, v in pairs(玩家数据) do
    if  玩家数据[n].管理 == nil and 玩家数据[n].角色.数据.门派 == 内容 then
      发送数据(玩家数据[n].连接id,38,消息)
    end
  end
end

function 广播帮派消息(消息,内容)
  for n, v in pairs(玩家数据) do
    if 玩家数据[n].管理 == nil and 玩家数据[n].角色.数据.帮派数据~=nil and 玩家数据[n].角色.数据.帮派数据.编号 == 内容 then
      发送数据(玩家数据[n].连接id,38,消息)
    end
  end
end

function 发送公告(消息)
  for n, v in pairs(玩家数据) do
    if  玩家数据[n].管理 == nil then
      发送数据(玩家数据[n].连接id,59,消息)
    end
  end
end

function 读入文件(fileName)
  local f = assert(io.open(fileName,'r'))
  local content = f:read('*all')
  f:close()
  if content=="" then content="无文本" end
  return content
end

function 时辰函数()
  if os.time()-时辰信息.起始>=时辰信息.刷新 then
    时辰信息.起始=os.time()
    时辰信息.当前=时辰信息.当前+1
    if 时辰信息.当前==13 then
      时辰信息.当前=1
    end
    if 时辰信息.当前==12 then
      local random = math.random
      if 昼夜参数==1 then
        昼夜参数=2
        广播消息({内容="天黑了".."#"..random(1,110),频道="xt"})
      else
        昼夜参数=1
        广播消息({内容="天亮了".."#"..random(1,110),频道="xt"})
      end
    end
    for n, v in pairs(玩家数据) do--发送时辰更换
      if 玩家数据[n].管理 == nil then
        发送数据(玩家数据[n].连接id,43,{时辰=时辰信息.当前})
      end
    end
  end
end

function qbfb(a,b)
  return a/b
end

function 常规提示(id,内容)
  if 玩家数据[id] ~= nil then
    发送数据(玩家数据[id].连接id,7,"#Y/"..内容)
  else
    print("是玩家数据[id]导致的错误")
  end
end

function 取id组(id)
  local id组={}
  if 玩家数据[id].队伍==0 then
    id组[1]=id
  else
    local 队伍id=玩家数据[id].队伍
    for n=1,#队伍数据[队伍id].成员数据 do
     id组[n]=队伍数据[队伍id].成员数据[n]
    end
  end
  return id组
end

function 取队伍人数(id)
  if 玩家数据[id].队伍==0 then
    return 1
  else
    return #队伍数据[玩家数据[id].队伍].成员数据
  end
end

function 取队长权限(id)
  if 玩家数据[id].队伍==0 then
    return true
  elseif 玩家数据[id].队长 then
    return true
  end
  return false
end

function 取等级要求(id,等级)
  local id组={}
  if 玩家数据[id].队伍==0 then
    id组[1]=id
  else
    local 队伍id=玩家数据[id].队伍
    for n=1,#队伍数据[队伍id].成员数据 do
     id组[n]=队伍数据[队伍id].成员数据[n]
    end
  end
  for n=1,#id组 do
    if 玩家数据[id组[n]].角色.数据.等级<等级 then
      return false
    end
  end
  return true
end

-- function 广播队伍消息(队伍id,内容)
--   for n=1,#队伍数据[队伍id].成员数据 do
--     if 队伍数据[队伍id].成员数据[n] ~= 队伍数据[队伍id].成员数据[1] and 玩家数据[队伍数据[队伍id].成员数据[n]] ~= nil then
--       发送数据(玩家数据[队伍数据[队伍id].成员数据[n]].连接id,7,内容)
--     end
--   end
-- end

function 取任务符合id(id,任务id)
  if 任务数据[任务id]==nil then return false end
  for n=1,#任务数据[任务id].队伍组 do
    if 任务数据[任务id].队伍组[n]==id then
      return true
    end
  end
  return false
end

function 广播队伍消息(队伍id,文本)
  for n=1,#队伍数据[队伍id].成员数据 do
    if 玩家数据[队伍数据[队伍id].成员数据[n]] then
      if 队伍处理类:取是否助战(队伍id,n) == 0 then
        发送数据(玩家数据[队伍数据[队伍id].成员数据[n]].连接id,38,{内容=文本,频道="dw"})
      end
    end
  end
  return false
end

function 取门派示威对象(门派)
 local 示威对象={}
  for n, v in pairs(玩家数据) do
    if 玩家数据[n].管理==nil and 玩家数据[n].角色.数据.门派~="无" and 玩家数据[n].角色.数据.门派~=门派 then
      示威对象[#示威对象+1]=n
    end
  end
  if #示威对象==0 then
    return
  else
    local 临时序列=取随机数(1,#示威对象)
    local id=示威对象[临时序列]
    return 玩家数据[id].角色:取地图数据()
  end
end

function 添加最后对话(id,对话,选项)
  if 选项 ~= nil and 选项[1] ~=  nil and 选项[1] ~= "确定强行PK" and (玩家数据[id].最后对话 == nil or 玩家数据[id].最后对话.名称 == nil) then
    if 玩家数据[id].队伍 ~= 0 then
      local 队长id = 队伍数据[玩家数据[id].队伍].成员数据[1]
      if 队长id == nil then
          return
      end
    else
      return
    end
  else
    队长id = id
  end
  local 名称=玩家数据[队长id].最后对话.名称
  local 模型=玩家数据[队长id].最后对话.模型
  if 名称==nil then
    名称=玩家数据[id].角色.数据.名称
  end
  if 模型==nil then
    模型=玩家数据[id].角色.数据.模型
  end
  发送数据(玩家数据[id].连接id,1501,{名称=名称,模型=模型,对话=对话,选项=选项})
end

function 取队伍最低等级(队伍id,等级)
  for n=1,#队伍数据[队伍id].成员数据 do
    if 玩家数据[队伍数据[队伍id].成员数据[n]].角色.数据.等级<等级 then
      return true
    end
  end
  return false
end

function 取队伍最高等级(队伍id,等级)
  for n=1,#队伍数据[队伍id].成员数据 do
    if 玩家数据[队伍数据[队伍id].成员数据[n]].角色.数据.等级>等级 then
      return true
    end
  end
  return false
end

function 取队伍最高等级数(队伍id)
  local t = {}
  for n=1,#队伍数据[队伍id].成员数据 do
    t[n]=玩家数据[队伍数据[队伍id].成员数据[n]].角色.数据.等级
  end
  table.sort(t)
  return t[#队伍数据[队伍id].成员数据]
end

function 取队伍最低等级数(队伍id)
  local t = {}
  for n=1,#队伍数据[队伍id].成员数据 do
    t[n]=玩家数据[队伍数据[队伍id].成员数据[n]].角色.数据.等级
  end
  table.sort(t)
  return t[1]
end

function 取队伍平均等级(队伍id,id)
  if 队伍数据[队伍id]==nil then
    return 玩家数据[id].角色.数据.等级
  end
  local 等级=0
  for n=1,#队伍数据[队伍id].成员数据 do
    等级=等级+玩家数据[队伍数据[队伍id].成员数据[n]].角色.数据.等级
  end
  等级=math.floor(等级/#队伍数据[队伍id].成员数据)
  return 等级
end

function 取队伍任务(队伍id,等级)
  for n=1,#队伍数据[队伍id].成员数据 do
    if 玩家数据[队伍数据[队伍id].成员数据[n]].角色:取任务(等级)~=0 then
      return true
    end
  end
  return false
end

function 取等级(id)
  return 玩家数据[id].角色.数据.等级
end

function 取银子(id)
  return 玩家数据[id].角色.数据.银子
end

function 取存银(id)
  return 玩家数据[id].角色.数据.存银
end

function 取名称(id)
  return 玩家数据[id].角色.数据.名称
end
function 道具刷新(id)
  发送数据(玩家数据[id].连接id,3699)
end

function 门派代号(门派)
  if 门派 == "大唐官府" then
      return "dt"
  elseif 门派 == "化生寺" then
      return "hs"
  elseif 门派 == "方寸山" then
      return "fc"
  elseif 门派 == "女儿村" then
      return "ne"
  elseif 门派 == "狮驼岭" then
      return "st"
  elseif 门派 == "阴曹地府" then
      return "df"
  elseif 门派 == "天宫" then
      return "tg"
  elseif 门派 == "盘丝洞" then
      return "ps"
  elseif 门派 == "魔王寨" then
      return "mw"
  elseif 门派 == "五庄观" then
      return "wz"
  elseif 门派 == "龙宫" then
      return "lg"
  elseif 门派 == "普陀山" then
      return "pts"
  elseif 门派 == "无底洞" then
      return "wd"
  elseif 门派 == "凌波城" then
      return "lb"
  elseif 门派 == "神木林" then
      return "sm"
  end
end

function 刷新修炼数据(id)
  发送数据(玩家数据[id].连接id,44,{人物=玩家数据[id].角色.数据.修炼,bb=玩家数据[id].角色.数据.bb修炼})
end

function 更改道具归属(道具识别码,账号,对方id,名称1)
  if 道具识别码==nil then return  end
  道具记录[道具识别码]={账号=账号,id=对方id,名称=名称1}
end

function 体活刷新(id)
  if 玩家数据[id] ~=nil and 玩家数据[id].角色 ~=nil and 玩家数据[id].角色.数据.体力 ~=nil and 玩家数据[id].角色.数据.活力 ~= nil  then
      发送数据(玩家数据[id].连接id,15,{体力=玩家数据[id].角色.数据.体力,活力=玩家数据[id].角色.数据.活力})
  end
end

function 发送数据(id,序号,内容,封装)

  local 组合内容={}
  if id==nil then return  end
  if 内容==nil then 内容="1" end
  if 封装==nil then
    组合内容={序号=序号,内容=内容}
    __S服务:发送(id,table.tostring(组合内容))
  end
end

function 发送数据1(id,序号,内容)
  __S服务:发送(id,序号,内容)
end

function txt(布尔值)
  if 布尔值 then
    return "true"
  else
    return "false"
  end
end
function 调试信息(o) end

function 时间转换(时间)
  return  "["..os.date("%Y", 时间).."年"..os.date("%m", 时间).."月"..os.date("%d", 时间).."日 "..os.date("%X", 时间).."]"
end

function 时间转换1(时间)
  return  os.date("%Y", 时间).."-"..os.date("%m", 时间).."-"..os.date("%d", 时间).." "..os.date("%X", 时间)
end

function 时间转换2(时间)
  return  os.date("%m", 时间).."/"..os.date("%d", 时间).." "..os.date("%H", 时间)..":"..os.date("%M", 时间)
end

function 取年月日()
  return  os.date("%Y", 时间).."年"..os.date("%m", 时间).."月"..os.date("%d", 时间).."日 "
end



function 强制下线()
  for n, v in pairs(战斗准备类.战斗盒子) do
    if 战斗准备类.战斗盒子[n]~=nil  then
      -- 战斗准备类.战斗盒子[n]:结束战斗(0,0,1)
    end
  end
  for n, v in pairs(玩家数据) do
    if 玩家数据[n]~=nil and 玩家数据[n].管理 == nil then
      玩家数据[n].角色:存档()
      系统处理类:断开游戏(n)
    end
  end
end

function 保存系统数据()
  -- local 临时数据={}
  local 数量=0
  for n, v in pairs(任务数据) do
    if 任务数据[n].类型==10 or 任务数据[n].类型==13 or 任务数据[n].类型==7758 or 任务数据[n].类型==6000 or 任务数据[n].类型==6001 or 任务数据[n].类型=="飞升剧情" or 任务数据[n].类型==8800 then
      数量=数量+1
      临时数据[数量]=table.loadstring(table.tostring(任务数据[n]))
      临时数据[数量].存储id=n
    end
  end
  写出文件([[tysj/任务数据.txt]],table.tostring(临时数据))
  写出文件([[tysj/经验数据.txt]],table.tostring(经验数据))
  写出文件([[tysj/银子数据.txt]],table.tostring(银子数据))
  写出文件([[tysj/充值数据.txt]],table.tostring(充值数据))
  写出文件([[tysj/帮派竞赛.txt]],table.tostring(帮派竞赛))
  写出文件([[tysj/妖魔数据.txt]],table.tostring(妖魔积分))
  写出文件([[tysj/消息数据.txt]],table.tostring(消息数据))
  写出文件([[tysj/押镖数据.txt]],table.tostring(押镖数据))
  写出文件([[tysj/好友黑名单.txt]],table.tostring(好友黑名单))
  写出文件([[tysj/帮派数据.txt]],table.tostring(帮派数据))
  写出文件([[tysj/比武大会.txt]],table.tostring(比武大会))
  写出文件([[tysj/首席争霸.txt]],table.tostring(首席争霸))
  写出文件([[tysj/生死劫数据.txt]],table.tostring(生死劫数据))
  写出文件([[tysj/活跃数据.txt]],table.tostring(活跃数据))
  写出文件([[tysj/签到数据.txt]],table.tostring(签到数据))
  写出文件([[tysj/炼丹炉.txt]],table.tostring(炼丹炉))
  写出文件([[tysj/通天塔数据.txt]],table.tostring(通天塔数据))
  -- 写出文件([[tysj/房屋数据.txt]],table.tostring(房屋数据))
  写出文件([[tysj/商会数据.txt]],table.tostring(商会数据))
  写出文件([[tysj/藏宝阁数据.txt]],table.tostring(藏宝阁数据))
  写出文件([[tysj/寄存数据.txt]],table.tostring(寄存数据))
  写出文件([[tysj/剧情数据.txt]],table.tostring(剧情数据))
  if VIP定制 then
    写出文件([[tysj/VIP数据.txt]],table.tostring(VIP数据))
  end
  __S服务:输出("保存系统数据成功……")
  for n, v in pairs(玩家数据) do
    if 玩家数据[n]~=nil  and 玩家数据[n].管理 == nil then
      玩家数据[n].角色:存档()
    end
  end
  __S服务:输出("保存玩家数据成功……")
  当前时间=os.time()
  当前年份=os.date("%Y",当前时间)
  当前月份=os.date("%m",当前时间)
  当前日份=os.date("%d",当前时间)
  保存时间=os.date("%H",当前时间).."时"..os.date("%M",当前时间).."分"..os.date("%S",当前时间).."秒 "
  if f函数.文件是否存在([[log\]]..当前年份)==false then
    lfs.mkdir([[log\]]..当前年份)
  end
  if f函数.文件是否存在([[log\]]..当前年份..[[\]]..当前月份)==false then
    lfs.mkdir([[log\]]..当前年份..[[\]]..当前月份)
  end
  if f函数.文件是否存在([[log\]]..当前年份..[[\]]..当前月份..[[\]]..当前日份)==false then
    lfs.mkdir([[log\]]..当前年份..[[\]]..当前月份..[[\]]..当前日份)
    lfs.mkdir([[log\]]..当前年份..[[\]]..当前月份..[[\]]..当前日份..[[\]].."错误日志")
    lfs.mkdir([[log\]]..当前年份..[[\]]..当前月份..[[\]]..当前日份..[[\]].."登录日志")
    lfs.mkdir([[log\]]..当前年份..[[\]]..当前月份..[[\]]..当前日份..[[\]].."在线日志")
    lfs.mkdir([[log\]]..当前年份..[[\]]..当前月份..[[\]]..当前日份..[[\]].."备份日志")
  end
  if #错误日志<500 then
    local 保存语句=""
    for n=1,#错误日志 do
      保存语句=保存语句..时间转换(错误日志[n].时间)..'：\n'..错误日志[n].记录..'\n'
    end
    写出文件([[log\]]..当前年份..[[\]]..当前月份..[[\]]..当前日份..[[\]].."错误日志"..[[\]]..保存时间..".txt",保存语句)
  else
    local 文件名称=保存时间
    local 计次数量=0
    local 保存语句=""
    for n=1,#错误日志 do
      保存语句=保存语句..时间转换(错误日志[n].时间)..'：\n'..错误日志[n].记录..'\n'
      计次数量=计次数量+1
      if 计次数量>=500 then
        写出文件([[log\]]..当前年份..[[\]]..当前月份..[[\]]..当前日份..[[\]].."错误日志"..[[\]]..文件名称.."_"..n..".txt",保存语句)
        计次数量=0
        保存语句=""
      end
    end
  end
  错误日志={}
  写出文件([[log\]]..当前年份..[[\]]..当前月份..[[\]]..当前日份..[[\]].."藏宝阁日志"..[[\]]..保存时间..".txt",藏宝阁记录)
  藏宝阁记录 = ""
  __S服务:输出("藏宝阁记录保存成功……")
  __S服务:输出("错误日志保存成功……")
  collectgarbage("collect")
end


function 查看在线列表()
  local 列表=""
  for n, v in pairs(玩家数据) do
    列表=列表..format("账号%s,角色id%s",玩家数据[n].账号,n)..'\n'
  end
  写出文件("在线列表.txt",列表)
end
function 退出函数() end

function 打印在线时间()
  local 语句=""
  for n, v in pairs(在线时间) do
    语句=语句..string.format("角色id：%s，本日累积在线：%s秒\n",n,在线时间[n])
  end
  写出文件("在线时间.txt",语句)
end

function 异常账号(数字id,信息)
  print(信息)
end

function 添加仙玉(数额,账号,id,事件)
  local 仙玉=f函数.读配置(程序目录..[[data\]]..账号..[[\账号信息.txt]],"账号配置","仙玉")+0
  仙玉=仙玉+数额
  f函数.写配置(程序目录..[[data\]]..账号..[[\账号信息.txt]],"账号配置","仙玉",仙玉)
  local 日志=读入文件([[data\]]..账号..[[\消费记录.txt]])
  日志=日志.."\n"..时间转换(os.time())..事件..format("。以下为具体添加信息：添加数额为%s,添加后的仙玉数量为%s，本次触发事件[%s]#分割符\n",数额,仙玉,事件)
  写出文件([[data\]]..账号..[[\消费记录.txt]],日志)
  local 金额 = math.floor(数额/充值比例)
  if 充值数据[id]==nil then
    充值数据[id]={id=id,名称=玩家数据[id].角色.数据.名称,金额=金额,门派=玩家数据[id].角色.数据.门派,等级=玩家数据[id].角色.数据.等级}
  else
    充值数据[id].金额=充值数据[id].金额+金额
    充值数据[id].等级=玩家数据[id].角色.数据.等级
  end
  常规提示(id,"#Y获得了#R"..数额.."#Y点仙玉")
end

function 添加帮贡(id,数量)
  帮派数据[玩家数据[id].角色.数据.帮派数据.编号].成员数据[id].帮贡.当前=帮派数据[玩家数据[id].角色.数据.帮派数据.编号].成员数据[id].帮贡.当前+数量
  帮派数据[玩家数据[id].角色.数据.帮派数据.编号].成员数据[id].帮贡.上限=帮派数据[玩家数据[id].角色.数据.帮派数据.编号].成员数据[id].帮贡.上限+数量
  玩家数据[id].角色.数据.帮贡=玩家数据[id].角色.数据.帮贡+数量
  常规提示(id,"#Y获得了#R"..数量.."#Y点帮贡")
end

function 添加点卡(数额,账号,id,事件)
  local 点卡=f函数.读配置(程序目录..[[data\]]..账号..[[\账号信息.txt]],"账号配置","点卡")
  if tonumber(点卡) == nil then
    点卡 = 0
  end
  点卡=点卡+数额
  f函数.写配置(程序目录..[[data\]]..账号..[[\账号信息.txt]],"账号配置","点卡",点卡)
  local 日志=读入文件([[data\]]..账号..[[\消费记录.txt]])
  日志=日志.."\n"..时间转换(os.time())..事件..format("。以下为具体添加信息：添加数额为%s,添加后的点卡数量为%s，本次触发事件[%s]#分割符\n",数额,点卡,事件)
  写出文件([[data\]]..账号..[[\消费记录.txt]],日志)
  常规提示(id,"#Y获得了#R"..数额.."#Y点点卡")
end

function 删除重复(key)
  local k;
  for i=1,#key do
    for j=i+1,#key do
      if(key[i] == key[j]) then
        key[i] = - 1
      end
    end
  end
  k = 1;
  for i=1, #key do
    if (key[k] == -1) then
      table.remove(key, k);k=k - 1
    end
    k=k+1
  end
  k = nil;
  return key
end

function 取随机小数(x,y)
  return 取随机数(x*10000,y*10000)/10000
end

function 生成XY(x,y)
  local f ={}
  f.x = tonumber(x) or 0
  f.y = tonumber(y) or 0
  setmetatable(f,{
  __add = function (a,b)
    return 生成XY(a.x + b.x,a.y + b.y)
  end,
  __sub = function (a,b)
    return 生成XY(a.x - b.x,a.y - b.y)
  end
  })
  return f
end

function 取两点距离(src,dst)
    return math.sqrt(math.pow(src.x-dst.x,2) + math.pow(src.y-dst.y,2))
end

function 取两点距离a(x, y, x1, y1)
  return math.sqrt(math.pow(x - x1, 2) + math.pow(y - y1, 2))
end

function 取距离坐标(xy,r,a) --r距离,a孤度
  local x1,y1 = 0,0
  x1=r* math.cos(a) + xy.x + 取随机数(-2,2)
  y1=r* math.sin(a) + xy.y + 取随机数(-2,2)
  return 生成XY(math.floor(x1),math.floor(y1))
end

function 取商品卖出价格(spm)

  local dj
  if spm== "商品武器" then
      dj = 取随机数(3600,4500)
  elseif spm== "商品棉布" then
      dj = 取随机数(3200,3800)
  elseif spm== "商品佛珠" then
      dj = 取随机数(6200,8000)
  elseif spm== "商品扇子" then
      dj = 取随机数(3500,4200)
  elseif spm== "商品纸钱" then
      dj = 取随机数(2600,3400)
  elseif spm== "商品夜明珠" then
      dj = 取随机数(7600,9000)
  elseif spm== "商品首饰" then
      dj = 取随机数(3600,4800)
  elseif spm== "商品珍珠" then
      dj = 取随机数(5000,6000)
  elseif spm== "商品帽子" then
      dj = 取随机数(3000,4000)
  elseif spm== "商品盐" then
      dj = 取随机数(4800,6000)
  elseif spm== "商品蜡烛" then
      dj = 取随机数(1500,2500)
  elseif spm== "商品酒" then
      dj = 取随机数(3200,4500)
  elseif spm== "商品木材" then
      dj = 取随机数(3200,5000)
  elseif spm== "商品鹿茸" then
      dj = 取随机数(6800,8500)
  elseif spm== "商品面粉" then
      dj = 取随机数(2500,3500)
  elseif spm== "商品符" then
      dj = 取随机数(4500,6000)
  elseif spm== "商品人参" then
      dj = 取随机数(6500,9000)
  elseif spm== "商品铃铛" then
      dj = 取随机数(3200,4800)
  elseif spm== "商品香油" then
      dj = 取随机数(3200,5000)
  elseif spm== "商品麻线" then
      dj = 取随机数(2000,3800)
  end
  return dj
end

跑商={}
跑商.商品棉布=取商品卖出价格("商品棉布")
跑商.商品佛珠=取商品卖出价格("商品佛珠")
跑商.商品扇子=取商品卖出价格("商品扇子")
跑商.商品武器=取商品卖出价格("商品武器")
跑商.商品纸钱=取商品卖出价格("商品纸钱")
跑商.商品帽子=取商品卖出价格("商品帽子")
跑商.商品木材=取商品卖出价格("商品木材")
跑商.商品人参=取商品卖出价格("商品人参")
跑商.商品夜明珠=取商品卖出价格("商品夜明珠")
跑商.商品盐=取商品卖出价格("商品盐")
跑商.商品鹿茸=取商品卖出价格("商品鹿茸")
跑商.商品铃铛=取商品卖出价格("商品铃铛")
跑商.商品首饰=取商品卖出价格("商品首饰")
跑商.商品蜡烛=取商品卖出价格("商品蜡烛")
跑商.商品面粉=取商品卖出价格("商品面粉")
跑商.商品香油=取商品卖出价格("商品香油")
跑商.商品珍珠=取商品卖出价格("商品珍珠")
跑商.商品酒=取商品卖出价格("商品酒")
跑商.商品符=取商品卖出价格("商品符")
跑商.商品麻线=取商品卖出价格("商品麻线")

--print(时间转换(1558546218))
帮派修炼={
  [1]=16,
  [2]=32,
  [3]=52,
  [4]=75,
  [5]=103,
  [6]=136,
  [7]=179,
  [8]=231,
  [9]=295,
  [10]=372,
  [11]=466,
  [12]=578,
  [13]=711,
  [14]=867,
  [15]=1049,
  [16]=1280,
  [17]=1503,
  [18]=1780,
  [19]=2096,
  [20]=2452,
  [21]=2854,
  [22]=3304,
  [23]=3807,
  [24]=4364,
  [25]=4983
}

帮派技能={
  [1]=16,
  [2]=32,
  [3]=52,
  [4]=75,
  [5]=103,
  [6]=136,
  [7]=179,
  [8]=231,
  [9]=295,
  [10]=372,
  [11]=466,
  [12]=578,
  [13]=711,
  [14]=867,
  [15]=1049,
  [16]=1280,
  [17]=1503,
  [18]=1780,
  [19]=2096,
  [20]=2452,
  [21]=2854,
  [22]=3304,
  [23]=3807,
  [24]=4364,
  [25]=4983,
  [26]=5664,
  [27]=6415,
  [28]=7238,
  [29]=8138,
  [30]=9120,
  [31]=10188,
  [32]=11347,
  [33]=12602,
  [34]=13959,
  [35]=15423,
  [36]=16998,
  [37]=18692,
  [38]=20508,
  [39]=22452,
  [40]=24532,
  [41]=26753,
  [42]=29121,
  [43]=31642,
  [44]=34323,
  [45]=37169,
  [46]=40186,
  [47]=43388,
  [48]=46773,
  [49]=50352,
  [50]=54132,
  [51]=58120,
  [52]=62324,
  [53]=66750,
  [54]=71407,
  [55]=76303,
  [56]=81444,
  [57]=86840,
  [58]=92500,
  [59]=104640,
  [60]=111136,
  [61]=117931,
  [62]=125031,
  [63]=132444,
  [64]=140183,
  [65]=148253,
  [66]=156666,
  [67]=156666,
  [68]=165430,
  [69]=174556,
  [70]=184052,
  [71]=193930,
  [72]=204198,
  [73]=214868,
  [74]=225948,
  [75]=237449,
  [76]=249383,
  [77]=261760,
  [78]=274589,
  [79]=287884,
  [80]=301652,
  [81]=315908,
  [82]=330662,
  [83]=345924,
  [84]=361708,
  [85]=378023,
  [86]=394882,
  [87]=412297,
  [88]=430280,
  [89]=448844,
  [90]=468000,
  [91]=487760,
  [92]=508137,
  [93]=529145,
  [94]=550796,
  [95]=573103,
  [96]=596078,
  [97]=619735,
  [98]=644088,
  [99]=669149,
  [100]=721452,
  [101]=748722,
  [102]=776755,
  [103]=805566,
  [104]=835169,
  [105]=865579,
  [106]=896809,
  [107]=928876,
  [108]=961792,
  [109]=995572,
  [110]=1030234,
  [111]=1065190,
  [112]=1102256,
  [113]=1139649,
  [114]=1177983,
  [115]=1217273,
  [116]=1256104,
  [117]=1298787,
  [118]=1341043,
  [119]=1384320,
  [120]=1428632,
  [121]=1473999,
  [122]=1520435,
  [123]=1567957,
  [124]=1616583,
  [125]=1666328,
  [126]=1717211,
  [127]=1769248,
  [128]=1822456,
  [129]=1876852,
  [130]=1932456,
  [131]=1989284,
  [132]=2047353,
  [133]=2106682,
  [134]=2167289,
  [135]=2229192,
  [136]=2292410,
  [137]=2356960,
  [138]=2422861,
  [139]=2490132,
  [140]=2558792,
  [141]=2628860,
  [142]=2700356,
  [143]=2773296,
  [144]=2847703,
  [145]=2923593,
  [146]=3000989,
  [147]=3079908,
  [148]=3160372,
  [149]=3242400,
  [150]=6652022,
  [151]=6822452,
  [152]=6996132,
  [153]=7173104,
  [154]=7353406,
  [155]=11305620,
  [156]=15305620,
  [157]=22305620,
  [158]=27305620,
  [159]=37305620,
  [160]=45305620,
  [161]=54305620
}
帮派建筑升级经验 = {
  [0]=1600,
  [1]=1600,
  [2]=3200,
  [3]=5200,
  [4]=7500,
  [5]=10300,
  [6]=13600,
  [7]=17900,
  [8]=23100,
  [9]=29500,
  [10]=37200,
  [11]=46600,
  [12]=57800,
  [13]=71100,
  [14]=86700,
  [15]=104900,
  [16]=128000
}

function 取人物修炼等级上限(等级)
  local 修炼上限=(等级-20)/5
  if 修炼上限<=0 then
      修炼上限=0
  end
  if 修炼上限>=20 then
    修炼上限=20
  end
  return 修炼上限
end

function 飞升降修处理(id)
  local as = {"攻击修炼","防御修炼","法术修炼","抗法修炼"}
  local as1 = {"攻击控制力","防御控制力","法术控制力","抗法控制力"}
  for n=1,4 do
    if 玩家数据[id].角色.数据.修炼[as[n]][1]==20 then
        玩家数据[id].角色.数据.修炼[as[n]][1]=玩家数据[id].角色.数据.修炼[as[n]][1]-5
        玩家数据[id].角色.数据.修炼[as[n]][3]=25
    elseif 玩家数据[id].角色.数据.修炼[as[n]][1]==19 then
        玩家数据[id].角色.数据.修炼[as[n]][1]=玩家数据[id].角色.数据.修炼[as[n]][1]-4
        玩家数据[id].角色.数据.修炼[as[n]][3]=24
    elseif 玩家数据[id].角色.数据.修炼[as[n]][1]==18 then
        玩家数据[id].角色.数据.修炼[as[n]][1]=玩家数据[id].角色.数据.修炼[as[n]][1]-4
        玩家数据[id].角色.数据.修炼[as[n]][3]=24
    elseif 玩家数据[id].角色.数据.修炼[as[n]][1]==17 then
        玩家数据[id].角色.数据.修炼[as[n]][1]=玩家数据[id].角色.数据.修炼[as[n]][1]-3
        玩家数据[id].角色.数据.修炼[as[n]][3]=23
    elseif 玩家数据[id].角色.数据.修炼[as[n]][1]==16 then
        玩家数据[id].角色.数据.修炼[as[n]][1]=玩家数据[id].角色.数据.修炼[as[n]][1]-3
        玩家数据[id].角色.数据.修炼[as[n]][3]=23
    elseif 玩家数据[id].角色.数据.修炼[as[n]][1]==15 then
        玩家数据[id].角色.数据.修炼[as[n]][1]=玩家数据[id].角色.数据.修炼[as[n]][1]-2
        玩家数据[id].角色.数据.修炼[as[n]][3]=22
    elseif 玩家数据[id].角色.数据.修炼[as[n]][1]==14 then
        玩家数据[id].角色.数据.修炼[as[n]][1]=玩家数据[id].角色.数据.修炼[as[n]][1]-2
        玩家数据[id].角色.数据.修炼[as[n]][3]=22
    elseif 玩家数据[id].角色.数据.修炼[as[n]][1]==13 then
        玩家数据[id].角色.数据.修炼[as[n]][1]=玩家数据[id].角色.数据.修炼[as[n]][1]-1
        玩家数据[id].角色.数据.修炼[as[n]][3]=21
    end
    if 玩家数据[id].角色.数据.bb修炼[as1[n]][1]==20 then
        玩家数据[id].角色.数据.bb修炼[as1[n]][1]=玩家数据[id].角色.数据.bb修炼[as1[n]][1]-5
        玩家数据[id].角色.数据.bb修炼[as1[n]][3]=25
    elseif 玩家数据[id].角色.数据.bb修炼[as1[n]][1]==19 then
        玩家数据[id].角色.数据.bb修炼[as1[n]][1]=玩家数据[id].角色.数据.bb修炼[as1[n]][1]-4
        玩家数据[id].角色.数据.bb修炼[as1[n]][3]=24
    elseif 玩家数据[id].角色.数据.bb修炼[as1[n]][1]==18 then
        玩家数据[id].角色.数据.bb修炼[as1[n]][1]=玩家数据[id].角色.数据.bb修炼[as1[n]][1]-4
        玩家数据[id].角色.数据.bb修炼[as1[n]][3]=24
    elseif 玩家数据[id].角色.数据.bb修炼[as1[n]][1]==17 then
        玩家数据[id].角色.数据.bb修炼[as1[n]][1]=玩家数据[id].角色.数据.bb修炼[as1[n]][1]-3
        玩家数据[id].角色.数据.bb修炼[as1[n]][3]=23
    elseif 玩家数据[id].角色.数据.bb修炼[as1[n]][1]==16 then
        玩家数据[id].角色.数据.bb修炼[as1[n]][1]=玩家数据[id].角色.数据.bb修炼[as1[n]][1]-3
        玩家数据[id].角色.数据.bb修炼[as1[n]][3]=23
    elseif 玩家数据[id].角色.数据.bb修炼[as1[n]][1]==15 then
        玩家数据[id].角色.数据.bb修炼[as1[n]][1]=玩家数据[id].角色.数据.bb修炼[as1[n]][1]-2
        玩家数据[id].角色.数据.bb修炼[as1[n]][3]=22
    elseif 玩家数据[id].角色.数据.bb修炼[as1[n]][1]==14 then
        玩家数据[id].角色.数据.bb修炼[as1[n]][1]=玩家数据[id].角色.数据.bb修炼[as1[n]][1]-2
        玩家数据[id].角色.数据.bb修炼[as1[n]][3]=22
    elseif 玩家数据[id].角色.数据.bb修炼[as1[n]][1]==13 then
        玩家数据[id].角色.数据.bb修炼[as1[n]][1]=玩家数据[id].角色.数据.bb修炼[as1[n]][1]-1
        玩家数据[id].角色.数据.bb修炼[as1[n]][3]=21
    end
  end
end

function 是否穿戴装备(id)
  for n, v in pairs(玩家数据[id].角色.数据.装备) do
    if 玩家数据[id].角色.数据.装备[n]~=nil then
      return true
    end
  end
  for n, v in pairs(玩家数据[id].角色.数据.灵饰) do
    if 玩家数据[id].角色.数据.灵饰[n]~=nil then
      return true
    end
  end
  for n, v in pairs(玩家数据[id].角色.数据.锦衣) do
    if 玩家数据[id].角色.数据.锦衣[n]~=nil then
      return true
    end
  end
  return false
end

function 取高级地煞星武器造型(角色)
  local 武器={}
  武器["剑侠客"]={武器="四法青云",级别=140}
  武器["逍遥生"]={武器="秋水人家",级别=140}
  武器["飞燕女"]={武器="九天金线",级别=140}
  武器["英女侠"]={武器="祖龙对剑",级别=140}
  武器["巫蛮儿"]={武器="紫金葫芦",级别=140}
  武器["狐美人"]={武器="游龙惊鸿",级别=140}
  武器["巨魔王"]={武器="护法灭魔",级别=140}
  武器["虎头怪"]={武器="元神禁锢",级别=140}
  武器["骨精灵"]={武器="九阴勾魂",级别=140}
  武器["杀破狼"]={武器="冥火薄天",级别=140}
  武器["舞天姬"]={武器="此最相思",级别=140}
  武器["玄彩娥"]={武器="青藤玉树",级别=140}
  武器["羽灵神"]={武器="庄周梦蝶",级别=140}
  武器["神天兵"]={武器="九瓣莲花",级别=140}
  武器["龙太子"]={武器="飞龙在天",级别=140}
  武器["鬼潇潇"]={武器="月影星痕",级别=140}
  武器["桃夭夭"]={武器="月露清愁",级别=140}
  武器["偃无师"]={武器="秋水澄流",级别=140}
  return 武器[角色]
end

function 取天罡星武器造型(角色)
  local 武器={}
  武器["剑侠客"]={武器="霜冷九州",级别=150}
  武器["逍遥生"]={武器="浩气长舒",级别=150}
  武器["飞燕女"]={武器="无关风月",级别=150}
  武器["英女侠"]={武器="紫电青霜",级别=150}
  武器["巫蛮儿"]={武器="云雷万里",级别=150}
  武器["狐美人"]={武器="牧云清歌",级别=150}
  武器["巨魔王"]={武器="业火三灾",级别=150}
  武器["虎头怪"]={武器="碧血干戚",级别=150}
  武器["骨精灵"]={武器="忘川三途",级别=150}
  武器["杀破狼"]={武器="九霄风雷",级别=150}
  武器["舞天姬"]={武器="揽月摘星",级别=150}
  武器["玄彩娥"]={武器="丝萝乔木",级别=150}
  武器["羽灵神"]={武器="碧海潮生",级别=150}
  武器["神天兵"]={武器="狂澜碎岳",级别=150}
  武器["龙太子"]={武器="天龙破城",级别=150}
  武器["鬼潇潇"]={武器="浮生归梦",级别=150}
  武器["桃夭夭"]={武器="夭桃秾李",级别=150}
  武器["偃无师"]={武器="百辟镇魂",级别=150}
  return 武器[角色]
end

Q_地煞星等级={
[1]="初出茅庐地煞星"
,[2]="小有所成地煞星"
,[3]="伏虎斩妖地煞星"
,[4]="御风神行地煞星"
,[5]="履水吐焰地煞星"
}

Q_天罡星名称={
  "天魁星"
  ,"天罡星"
  ,"天机星"
  ,"天闲星"
  ,"天勇星"
  ,"天雄星"
  ,"天猛星"
  ,"天威星"
  ,"天英星"
  ,"天贵星"
  ,"天富星"
  ,"天满星"
  ,"天孤星"
  ,"天伤星"
  ,"天立星"
  ,"天捷星"
  ,"天暗星"
  ,"天佑星"
  ,"天空星"
  ,"天速星"
  ,"天异星"
  ,"天杀星"
  ,"天微星"
  ,"天究星"
  ,"天退星"
  ,"天寿星"
  ,"天剑星"
  ,"天平星"
  ,"天罪星"
  ,"天损星"
  ,"天败星"
  ,"天牢星"
  ,"天慧星"
  ,"天暴星"
  ,"天哭星"
  ,"天巧星"
}

Q_取随机飞升武器={
    "鱼肠",
    "阴阳",
    "彩虹",
    "撕天",
    "太极",
    "沧海",
    "八卦",
    "龙筋",
    "如意",
    "冷月",
    "业焰",
    "离火",
    "非攻",
    "鸦九",
    "蟠龙",
    "鬼骨",
    "暗夜",
    "破魄",
    "倚天",
    "湛卢",
    "月光双环",
    "灵蛇",
    "流云",
    "碧波",
    "毒牙",
    "胭脂",
    "玉龙",
    "秋风",
    "碧波",
    "红莲",
    "盘龙",
    "鬼牙",
    "雷神",
    "百花",
    "吹雪",
    "乾坤",
    "月光",
    "屠龙",
    "血刃",
    "玉辉",
    "鹿鸣",
    "飞星",
    "月华",
    "幽篁",
    "百鬼",
    "月光双剑",
    "昆吾",
    "云鹤",
    "云梦",
    "梨花",
    "霹雳",
    "肃魂",
    "无敌"
}

Q_取随机渡劫武器={
    "刑天之逆",
    "五虎断魂",
    "飞龙在天",
    "五丁开山",
    "元神禁锢",
    "护法灭魔",
    "魏武青虹",
    "灵犀神剑",
    "四法青云",
    "金龙双剪",
    "连理双树",
    "祖龙对剑",
    "秋水落霞",
    "晃金仙绳",
    "此最相思",
    "九阴勾魂",
    "雪蚕之刺",
    "贵霜之牙",
    "画龙点睛",
    "秋水人家",
    "逍遥江湖",
    "降魔玉杵",
    "青藤玉树",
    "墨玉骷髅",
    "混元金锤",
    "九瓣莲花",
    "鬼王蚀日",
    "游龙惊鸿",
    "仙人指路",
    "血之刺藤",
    "别情离恨",
    "金玉双环",
    "九天金线",
    "偃月青龙",
    "晓风残月",
    "斩妖泣血",
    "庄周梦蝶",
    "凤翼流珠",
    "雪蟒霜寒",
    "回风舞雪",
    "紫金葫芦",
    "裂云啸日",
    "冥火薄天",
    "龙鸣寒水",
    "太极流光",
    "月光双剑",
    "墨骨枯麟",
    "腾蛇郁刃",
    "秋水澄流",
    "金风玉露",
    "凰火燎原",
    "月露清愁",
    "雪羽穿云",
    "月影星痕",
}

function 野外掉落装备(id,地图等级)
  local 等级=math.floor(地图等级/10)
  if 等级>8 then 等级=8 end
  玩家数据[id].道具:取随机装备(id,等级)
end

function 野外掉落二级药(id,地图等级)
  local 等级=math.floor(地图等级/10)
  if 等级>4 then
    local 药品名称={"孔雀红","鹿茸","仙狐涎","地狱灵芝","六道轮回","凤凰尾","火凤之睛","龙之心屑","紫石英","白露为霜","熊胆","血色茶花","丁香水","麝香"}
    local 名称=药品名称[取随机数(1,#药品名称)]
    玩家数据[id].道具:给予道具(id,名称,1)
    常规提示(id,"#Y/你获得了"..名称)
  end
end

function 取乾元丹消耗(等级)
  local cc = 0
  local vv = 0
  if 等级==1 then
    cc = 2234
  elseif 等级==2 then
    cc = 2785
  elseif 等级==3 then
    cc = 3453
  elseif 等级==4 then
    cc = 4252
  elseif 等级==5 then
    cc = 5192
  elseif 等级==6 then
    cc = 6285
  elseif 等级==7 then
    cc = 7542
  elseif 等级==8 then
    cc = 9150
  elseif 等级==9 then
    cc = 11000
  end
  if 等级==1 then
    vv =  447
  elseif 等级==2 then
    vv =  557
  elseif 等级==3 then
    vv =  691
  elseif 等级==4 then
    vv =  850
  elseif 等级==5 then
    vv =  1038
  elseif 等级==6 then
    vv =  1257
  elseif 等级==7 then
    vv =  1508
  elseif 等级==8 then
    vv =  1820
  elseif 等级==9 then
    vv =  2344
  end
  return {经验=cc*10000,金钱=vv*10000}
end

function 设置任务bb(id,任务id)
  local 等级=玩家数据[id].角色.数据.等级
  local 临时等级=等级-10
  if 临时等级>85 then 临时等级=85 end
  local 临时等级1=等级-50
  if 临时等级1<1 then 临时等级1=1 end
  local 类型=取等级怪(取随机数(临时等级1,临时等级))
  类型=取敌人信息(类型[取随机数(1,#类型)])
  类型=类型[2]
  任务数据[任务id].bb={[1]={名称=类型,找到=false}}
end

function 取飞升条件(id)
  if 玩家数据[id].角色.数据.等级<135 then
      return false
  end
  local 满足条件=0
  for i=1,#玩家数据[id].角色.数据.师门技能 do
    if 玩家数据[id].角色.数据.师门技能[i].等级>=130 then
        满足条件=满足条件+1
    end
  end
  if 满足条件<6 then
      return false
  end
  return true
end

function 取渡劫条件(id)
  if 玩家数据[id].角色.数据.等级<155 then
      return false
  end
  local 满足技能条件=0
  for i=1,#玩家数据[id].角色.数据.师门技能 do
    if 玩家数据[id].角色.数据.师门技能[i].等级>=150 then
      满足技能条件=满足技能条件+1
    end
  end
  if 满足技能条件<5 then
    return false
  end
  if 玩家数据[id].角色.数据.修炼.防御修炼[1]+玩家数据[id].角色.数据.修炼.抗法修炼[1]+玩家数据[id].角色.数据.修炼.法术修炼[1]+玩家数据[id].角色.数据.修炼.攻击修炼[1]<50 then
    return false
  end
  if 玩家数据[id].角色.数据.bb修炼.抗法控制力[1]+玩家数据[id].角色.数据.bb修炼.法术控制力[1]+玩家数据[id].角色.数据.bb修炼.防御控制力[1]+玩家数据[id].角色.数据.bb修炼.攻击控制力[1]<40 then
    return false
  end
  return true
end

function 读csv数据( str,reps )
    local resultStrList = {}
    string.gsub(str,'[^'..reps..']+',function ( w )
        table.insert(resultStrList,w)
    end)
    return resultStrList
end
--用于获取csv表
function 取csv数据(filePath)
    -- 读取文件
    local data = 读入文件(filePath);
    -- 按行划分
    local lineStr = 读csv数据(data, '\n\r');
    --第一行是分类 例如  名称 参数 关键字 价格
    local lm = {"仙玉商城","银子商城","法宝商城"}
    local titles = string.split(lineStr[2], ",");
    --tutlese
    local ID = 1
    local arrs = {}
    local gg = 1
    arrs[lm[gg]]={}
    local fillContent
    for i = 3, #lineStr, 1 do
        local content = string.split(lineStr[i], ",");
        if content[1] ==lm[gg+1] and arrs[lm[gg+1]] == nil then
          gg = gg +1
          arrs[lm[gg]] = {}
          ID = 0
        end
        if ID ~= 0 then
          arrs[lm[gg]][ID] = {}
        end
        for j = 1, #titles, 1 do
          if content[j] ~= nil and content[j] ~= "" and content[j] ~= "银子商城" and content[j] ~= "法宝商城" then
              arrs[lm[gg]][ID][titles[j]] = tonumber(content[j]) or content[j]
            end
        end
        ID = ID + 1
    end
    return arrs
end

function 取比武分组(等级)
  if 等级<70 then
      return "精锐组"
  elseif 等级<90 then
      return "勇武组"
  elseif 等级<110 then
      return "神威组"
  elseif 等级<130 then
      return "天科组"
  elseif 等级<160 then
      return "天启组"
  else
      return "天元组"
  end
end

function 开启首席争霸报名()
  首席争霸报名开关=true
  local 门派名称={"大唐官府","神木林","方寸山","化生寺","女儿村","天宫","普陀山","五庄观","凌波城","龙宫","魔王寨","狮驼岭","盘丝洞","无底洞","阴曹地府"}
  for n=1,#门派名称 do
    if 首席争霸[门派名称[n]]~=nil and 首席争霸[门派名称[n]].id~=nil and 玩家数据[首席争霸[门派名称[n]].id] ~= nil then
      玩家数据[首席争霸[门派名称[n]].id].角色:删除称谓(首席争霸[门派名称[n]].id,门派名称[n].."首席大弟子")
      常规提示(首席争霸[门派名称[n]].id,"你的首席称谓已回收！！！")
    end
  end
  发送公告("#G首席争霸赛报名已经开启，请需要参与比武大会的玩家找到#R首席争霸使者#G进行首席争霸赛报名！！！")
end

function 开启首席争霸进场()
  首席争霸进场=true
  首席争霸开启=os.time()
  首席争霸报名开关=false
  发送公告("#G首席争霸赛入场已经开启，请需要参与首席争霸赛的玩家找到#R首席争霸使者#G入场，首席争霸赛将于10分钟后正式开始！！！")
end

function 开启首席争霸()
  首席争霸开关=true
  首席争霸进场=false
  地图处理类:重置首席争霸赛()
  发送公告("#G首席争霸赛正式开始！！！")
end

function 结束首席争霸()
  首席争霸开关=false
  首席排名={}
  local 门派名称={"大唐官府","神木林","方寸山","化生寺","女儿村","天宫","普陀山","五庄观","凌波城","龙宫","魔王寨","狮驼岭","盘丝洞","无底洞","阴曹地府"}
  local 门派=""
  for n=1,#门派名称 do
    if 首席争霸数据[门派名称[n]]~=nil then
      for i,v in pairs(首席争霸数据[门派名称[n]]) do
        if i~=nil then
          if 玩家数据[i].角色.数据.首席报名 then
            玩家数据[i].角色.数据.首席报名=false
          end
          门派=玩家数据[i].角色.数据.门派
          if 首席排名[门派]==nil then
            首席排名[门派]={}
          end
          首席争霸数据[门派][i].奖励=true
          首席排名[门派][#首席排名[门派]+1]=首席争霸数据[门派][i]
          地图处理类:清除地图玩家(6009,1001,313,85)
        end
      end
      if #首席排名[门派]~=nil and #首席排名[门派]~=0 then
        table.sort(首席排名[门派], function (a,b) return a.积分 > b.积分 end)
        首席争霸[门派]=首席排名[门派][1]
        玩家数据[首席争霸[门派].id].角色:添加称谓(首席争霸[门派].id,门派.."首席大弟子")
        常规提示(首席争霸[门派].id,"恭喜你，获得了#R"..门派.."首席大弟子#Y称谓！！！")
      end
    end
    地图处理类:删除单位(Q_首席弟子[门派名称[n]].地图,1000)
  end
  保存系统数据()
  任务处理类:加载首席单位()
  发送公告("#G首席争霸赛已经结束，参与首席争霸赛的玩家可找到首席争霸使者领取参与奖励！！！")
end

Q_首席弟子={
 龙宫={地图=1116,方向=1,x=94,y=68}
,女儿村={地图=1142,方向=0,x=20,y=24}
,化生寺={地图=1002,方向=1,x=49,y=65}
,大唐官府={地图=1198,方向=0,x=98,y=67}
,普陀山={地图=1140,方向=0,x=12,y=15}
,五庄观={地图=1146,方向=1,x=36,y=49}
,盘丝洞={地图=1513,方向=1,x=179,y=30}
,魔王寨={地图=1512,方向=0,x=99,y=23}
,狮驼岭={地图=1131,方向=1,x=119,y=77}
,天宫={地图=1111,方向=0,x=160,y=113}
,方寸山={地图=1135,方向=1,x=67,y=66}
,阴曹地府={地图=1122,方向=0,x=41,y=63}
,凌波城={地图=1150,方向=0,x=34,y=68}
,神木林={地图=1138,方向=0,x=50,y=106}
,无底洞={地图=1139,方向=1,x=60,y=124}
}

function 开启比武报名()
  比武大会报名开关=true
  发送公告("#G比武大会报名已经开启，请需要参与比武大会的玩家找到#R比武大会主持人#G进行比武大会报名！！！")
  for i,v in pairs(玩家数据) do
    if 玩家数据[i].管理==nil then
      local 分组 = 取比武分组(玩家数据[i].角色.数据.等级)
      if 分组=="精锐组" then
        if 比武大会[分组][1]~=nil and 比武大会[分组][1].i==i then
            玩家数据[i].角色:删除称谓(i,"英雄会精锐状元")
        end
        if 比武大会[分组][2]~=nil and 比武大会[分组][2].i==i then
            玩家数据[i].角色:删除称谓(i,"英雄会精锐榜眼")
        end
        if 比武大会[分组][3]~=nil and 比武大会[分组][3].i==i then
            玩家数据[i].角色:删除称谓(i,"英雄会精锐探花")
        end
      elseif 分组=="勇武组" then
        if 比武大会[分组][1]~=nil and 比武大会[分组][1].i==i then
            玩家数据[i].角色:删除称谓(i,"英雄会勇武状元")
        end
        if 比武大会[分组][2]~=nil and 比武大会[分组][2].i==i then
            玩家数据[i].角色:删除称谓(i,"英雄会勇武榜眼")
        end
        if 比武大会[分组][3]~=nil and 比武大会[分组][3].i==i then
            玩家数据[i].角色:删除称谓(i,"英雄会勇武探花")
        end
      elseif 分组=="神威组" then
        if 比武大会[分组][1]~=nil and 比武大会[分组][1].i==i then
            玩家数据[i].角色:删除称谓(i,"英雄会神威状元")
        end
        if 比武大会[分组][2]~=nil and 比武大会[分组][2].i==i then
            玩家数据[i].角色:删除称谓(i,"英雄会神威榜眼")
        end
        if 比武大会[分组][3]~=nil and 比武大会[分组][3].i==i then
            玩家数据[i].角色:删除称谓(i,"英雄会神威探花")
        end
      elseif 分组=="天科组" then
        if 比武大会[分组][1]~=nil and 比武大会[分组][1].i==i then
            玩家数据[i].角色:删除称谓(i,"英雄会天科状元")
        end
        if 比武大会[分组][2]~=nil and 比武大会[分组][2].i==i then
            玩家数据[i].角色:删除称谓(i,"英雄会天科榜眼")
        end
        if 比武大会[分组][3]~=nil and 比武大会[分组][3].i==i then
            玩家数据[i].角色:删除称谓(i,"英雄会天科探花")
        end
      elseif 分组=="天启组" then
        if 比武大会[分组][1]~=nil and 比武大会[分组][1].i==i then
            玩家数据[i].角色:删除称谓(i,"英雄会天启状元")
        end
        if 比武大会[分组][2]~=nil and 比武大会[分组][2].i==i then
            玩家数据[i].角色:删除称谓(i,"英雄会天启榜眼")
        end
        if 比武大会[分组][3]~=nil and 比武大会[分组][3].i==i then
            玩家数据[i].角色:删除称谓(i,"英雄会天启探花")
        end
      elseif 分组=="天元组" then
        if 比武大会[分组][1]~=nil and 比武大会[分组][1].i==i then
            玩家数据[i].角色:删除称谓(i,"英雄会天元状元")
        end
        if 比武大会[分组][2]~=nil and 比武大会[分组][2].i==i then
            玩家数据[i].角色:删除称谓(i,"英雄会天元榜眼")
        end
        if 比武大会[分组][3]~=nil and 比武大会[分组][3].i==i then
            玩家数据[i].角色:删除称谓(i,"英雄会天元探花")
        end
        常规提示(i,"你的比武称谓已回收！！！")
      end
    end
  end
end

function 开启比武大会进场()
  比武大会进场=true
  比武开启=os.time()
  比武大会报名开关=false
  发送公告("#G比武大会入场已经开启，请需要参与比武大会的玩家找到#R比武大会主持人#G入场，比武大会将于15分钟后正式开始！！！")
end

function 开启比武大会()
  比武大会开关=true
  比武大会进场=false
  地图处理类:重置比武大会玩家()
  发送公告("#G比武大会正式开始！！！")
end

function 结束比武大会()
  比武大会开关=false
  比武大会={精锐组={},勇武组={},神威组={},天科组={},天启组={},天元组={}}
  local 分组 = ""
  for k,v in pairs(玩家数据) do
    if 玩家数据[k].管理 == nil then
      if 玩家数据[k].角色.数据.比武报名 then
        玩家数据[k].角色.数据.比武报名=false
      end
      分组=取比武分组(玩家数据[k].角色.数据.等级)
      比武大会[分组][#比武大会[分组]+1]=比武大会数据[分组][k]
      for n=6003,6008 do
        地图处理类:清除地图玩家(n,1001,124,174)
      end
    end
  table.sort(比武大会[分组], function (a, b)
    return a.积分 > b.积分 end)
  end
  发送公告("#G比武大会已经结束，参与比武大会的玩家可找到比武大会主持人领取参与奖励！！！")
end

function 开启帮战报名()
  帮派竞赛报名开关=true
  帮派竞赛开关1=false
  帮派竞赛开关2=false
  帮派竞赛开关3=false
  帮派竞赛开关4=false
  帮派竞赛开关5=false
  帮派竞赛={}
  发送公告("#G帮派竞赛活动已经开启报名，想要一展拳脚的帮主可到长安找到帮派竞赛主持人处报名参赛！！！")
end

function 开启帮派竞赛进场()
  帮派竞赛进场开关=true
  帮派竞赛报名开关=false
  帮战开启=os.time()
  任务处理类:刷出帮派护法()
  table.sort( 帮派竞赛, function (a,b)
    return a.报名费用>b.报名费用 end )
  local 发送信息="#S(帮派竞赛)#Y/因报名帮派数量少于2个帮派，无法开启帮派竞赛活动"
  if #帮派竞赛>=2 then
    发送信息="#S(帮派竞赛)#Y/帮派竞赛报名已结束，对决如下：\n"
    for i=1,#帮派竞赛 do
      if 帮派竞赛[i]~=nil and math.floor(i/2) == i/2 then
        发送信息=发送信息.."   #R"..帮派竞赛[i-1].帮派名称.."  VS  "..帮派竞赛[i].帮派名称.."\n"
        帮派竞赛[i-1].分组=(i/2).."组"
        帮派竞赛[i].分组=(i/2).."组"
        帮派竞赛[i-1].结束=false
        帮派竞赛[i].结束=false
        帮派竞赛[i-1].胜负=false
        帮派竞赛[i].胜负=false
      end
      帮派竞赛[i].怪物识别=i
    end
    广播消息({内容=发送信息,频道="xt"})
    发送公告("#G帮派竞赛活动已开放入场，已经报名报名的帮派成员可找长安的帮派竞赛主持人入场参赛，正式开启时间为10分钟后！！")
  else
    帮派竞赛进场开关=false
    for i,v in pairs(帮派数据) do
      帮派数据[i].帮战夺旗次数=nil
      帮派数据[i].帮战报名=nil
    end
    广播消息({内容=发送信息,频道="xt"})
    发送公告("#S(帮派竞赛)#Y/因报名帮派数量少于2个帮派，无法开启帮派竞赛活动")
  end
end

function 开启帮派竞赛()
  帮派竞赛开关=true
  帮派竞赛传送开关=true
  帮派竞赛进场开关=false
  地图处理类:重置帮派竞赛()
  for n=6010,6019 do
    任务处理类:设置帮派障碍怪(n)
  end
  帮派守卫刷新=os.time()
  发送公告("#G帮派竞赛活动正式开始！各帮派之间可以进行挑战了。")
end

function 结束帮派竞赛()
  for n=1,#帮派竞赛 do
    if 帮派竞赛[n]~=nil and math.floor(n/2) == n/2 and 帮派竞赛[n].结束 then
      local a=math.floor(n/2)
      if a==1 then
        帮派竞赛开关1=true
        帮战胜利宝箱1=os.time()
      elseif a==2 then
        帮派竞赛开关2=true
        帮战胜利宝箱2=os.time()
      elseif a==3 then
        帮派竞赛开关3=true
        帮战胜利宝箱3=os.time()
      elseif a==4 then
        帮派竞赛开关4=true
        帮战胜利宝箱4=os.time()
      elseif a==5 then
        帮派竞赛开关5=true
        帮战胜利宝箱5=os.time()
      end
      if 帮派竞赛[n].胜负 then
        发送公告("#G"..帮派竞赛[n].分组.."#Y帮派竞赛活动结束，恭喜帮派：#R"..帮派竞赛[n].帮派名称.."#Y获得该组的胜利！！！5分钟后会在帮派竞赛地图刷新帮战胜利宝箱！！！")
      elseif 帮派竞赛[n-1].胜负 then
        发送公告("#G"..帮派竞赛[n-1].分组.."#Y帮派竞赛活动结束，恭喜帮派：#R"..帮派竞赛[n-1].帮派名称.."#Y获得该组的胜利！！！5分钟后会在帮派竞赛地图刷新帮战胜利宝箱！！！")
      end
    end
  end
  if (#帮派竞赛==2 and 帮派竞赛开关1) or (#帮派竞赛==4 and 帮派竞赛开关2 and 帮派竞赛开关1) or (#帮派竞赛==6 and 帮派竞赛开关3 and 帮派竞赛开关2 and 帮派竞赛开关1) or (#帮派竞赛==8 and 帮派竞赛开关4 and 帮派竞赛开关3 and 帮派竞赛开关2 and 帮派竞赛开关1) or (#帮派竞赛==10 and 帮派竞赛开关5 and 帮派竞赛开关4 and 帮派竞赛开关3 and 帮派竞赛开关2 and 帮派竞赛开关1) then
    帮派竞赛开关=false
    for i,v in pairs(帮派数据) do
      帮派数据[i].帮战夺旗次数=nil
      帮派数据[i].帮战报名=nil
    end
    table.sort( 帮派竞赛, function (a,b)
      return a.积分>b.积分 end )
    发送公告("#G帮派竞赛活动已经结束，请已参与帮战的玩家到长安的帮派竞赛主持人处领取奖励！！！")
  end
end

取随机神兽={
  "超级神龙"
  ,"超级土地公公"
  ,"超级六耳猕猴"
  ,"超级神鸡"
  ,"超级玉兔"
  ,"超级神猴"
  ,"超级神马"
  ,"超级神羊"
  ,"超级孔雀"
  ,"超级灵狐"
  ,"超级筋斗云"
  ,"超级麒麟"
  ,"超级大鹏"
  ,"超级赤焰兽"
  ,"超级白泽"
  ,"超级灵鹿"
  ,"超级大象"
  ,"超级金猴"
  ,"超级大熊猫"
  ,"超级泡泡"
  ,"超级神兔"
  ,"超级神虎"
  ,"超级神牛"
  ,"超级海豚"
  ,"超级人参娃娃"
  ,"超级青鸾"
  ,"超级腾蛇"
  ,"超级神蛇"
}

function 取门派师傅名称(门派)
  if 门派=="大唐官府" then
    return "程咬金"
  elseif 门派=="化生寺" then
    return "空度禅师"
  elseif 门派=="女儿村" then
    return "孙婆婆"
  elseif 门派=="方寸山" then
    return "菩提祖师"
  elseif 门派=="神木林" then
    return "巫奎虎"
  elseif 门派=="龙宫" then
    return "东海龙王"
  elseif 门派=="天宫" then
    return "李靖"
  elseif 门派=="普陀山" then
    return "观音姐姐"
  elseif 门派=="五庄观" then
    return "镇元子"
  elseif 门派=="凌波城" then
    return "二郎神"
  elseif 门派=="狮驼岭" then
    return "大大王"
  elseif 门派=="魔王寨" then
    return "牛魔王"
  elseif 门派=="盘丝洞" then
    return "白晶晶"
  elseif 门派=="无底洞" then
    return "地涌夫人"
  elseif 门派=="阴曹地府" then
    return "地藏王"
  end
end

