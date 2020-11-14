local 战斗处理类 = class()
local jhf = string.format
local qz=math.floor
function 战斗处理类:初始化()end

function 战斗处理类:设置断线玩家(id)
  for n=1,#self.参战玩家 do
    if self.参战玩家[n].id==id then
      self.参战玩家[n].断线=true
    end
  end
end

function 战斗处理类:设置重连玩家(id)
  local 编号=0
  for n=1,#self.参战玩家 do
    if self.参战玩家[n].id==id then
      self.参战玩家[n].断线=false
      self.参战玩家[n].断线等待=true
      self.参战玩家[n].连接id=玩家数据[id].连接id
      编号=n
    end
  end
  if 编号==0 then
    玩家数据[id].战斗=0
    return
  end
  发送数据(self.参战玩家[编号].连接id,5501,{id=self.参战玩家[编号].队伍,音乐=nil,总数=#self.参战单位})
  local x待发送数据 = {}
  for i=1,#self.参战单位 do
    x待发送数据[i]=self:取加载信息(i)
  end
  发送数据(self.参战玩家[编号].连接id,5515,x待发送数据)--5502
  x待发送数据={}
  self.参战玩家[编号].重连加载=true
  --print(self.回合进程,#self.参战玩家,66)
  if self.回合进程=="执行" then
    if #self.参战玩家==1 then
      -- self.执行等待=os.time()+10
    end
  end
  if self.执行等待==0 then
    self.执行等待=os.time()+5
    发送数据(self.参战玩家[编号].连接id,38,{内容=format("#G你已经重新加入战斗，预计将在#Y%s#G秒后同步战斗操作。",self.执行等待-os.time()),频道="xt"})
  else
    发送数据(self.参战玩家[编号].连接id,38,{内容=format("#G你已经重新加入战斗，预计将在#Y%s#G秒后可以下达战斗指令。当其他玩家进入下达命令回合时，您将提前结束等待。",self.执行等待-os.time()),频道="xt"})
  end
end

function 战斗处理类:设置断线重连(id)
  local 编号 = 0
  for n=1,#self.参战玩家 do
    if self.参战玩家[n].id==id then
      self.参战玩家[n].断线=false
      self.参战玩家[n].断线等待=true
      self.参战玩家[n].连接id=玩家数据[id].连接id
    end
    编号 = n
  end

  local 死亡计算={0,0}
  for n=1,#self.参战单位 do
    self.参战单位[n].磐石=nil
    if self.参战单位[n].气血<=0 or self.参战单位[n].捕捉 or self.参战单位[n].逃跑 then
      if self.参战单位[n].队伍==self.队伍区分[1] then
        死亡计算[1]=死亡计算[1]+1
      else
        死亡计算[2]=死亡计算[2]+1
      end
    end
  end

  if 死亡计算[1]==self.队伍数量[1] then
    self.回合进程="结束回合"
    self:结束战斗(self.队伍区分[2],self.队伍区分[1])
     return
  elseif 死亡计算[2]==self.队伍数量[2] then
    self.回合进程="结束回合"
    self:结束战斗(self.队伍区分[1],self.队伍区分[2])
    return
  end
  self.参战玩家[编号].重连加载=true
  if self.执行等待==0 then
    self.执行等待=os.time()+5
    发送数据(self.参战玩家[编号].连接id,38,{内容=format("#G你已经重新加入战斗，预计将在#Y%s#G秒后同步战斗操作。",self.执行等待-os.time()),频道="xt"})
  else
    发送数据(self.参战玩家[编号].连接id,38,{内容=format("#G你已经重新加入战斗，预计将在#Y%s#G秒后可以下达战斗指令。当其他玩家进入下达命令回合时，您将提前结束等待。",self.执行等待-os.time()),频道="xt"})
  end
end

function 战斗处理类:设置观战玩家(观战id,id)
  local 编号=0
  for n=1,#self.参战玩家 do
    if self.参战玩家[n].id==观战id then
      编号=n
    end
  end
  发送数据(玩家数据[id].连接id,5501,{id=self.参战玩家[编号].队伍,音乐=nil,总数=#self.参战单位})
  local x待发送数据 = {}
  for i=1,#self.参战单位 do
    x待发送数据[i]=self:取加载信息(i)
  end
  发送数据(玩家数据[id].连接id,5516,x待发送数据)--5502
  self.观战玩家[id]={数字id=id,连接id=玩家数据[id].连接id}
  if self.执行等待==0 then
    self.执行等待=os.time()+5
    发送数据(玩家数据[id].连接id,38,{内容=format("#G你已经进入观战，预计将在#Y%s#G秒后同步观战方战斗操作。",self.执行等待-os.time()),频道="xt"})
  else
    发送数据(玩家数据[id].连接id,38,{内容=format("#G你已经进入观战，预计将在#Y%s#G秒后同步观战方战斗操作。",self.执行等待-os.time()),频道="xt"})
  end
end

function 战斗处理类:删除观战玩家(观战id)
  self.观战玩家[观战id] = nil
end


function 战斗处理类:进入战斗(玩家id,序号,任务id,地图)
  self.战斗类型=序号
  self.任务id=任务id
  self.玩家胜利=true
  self.战斗发言数据={}
  self.战斗失败=false
  self.观战玩家={}
  self.中断计算=false
  self.参战单位={}
  self.参战玩家={}
  self.进入战斗玩家id=玩家id
  self.飞升序号=0
  self.战斗计时=os.time()
  self.加载等待=7
  self.回合进程="加载回合"
  self.等待时间={初始=30,延迟=2}
  self.队伍数量={[1]=0,[2]=0}
  self.观战方=玩家id
  self.对战方=任务id
  self.防卡战斗={回合=0,时间=os.time(),执行=false}
  self.pk战斗=false
  self.阵法使用=true
  self.结束等待=0
  self.战斗地图=玩家数据[玩家id].角色.数据.地图数据.编号
  self.加载数量=0
  self.等待起始=0
  self.战斗类型=序号
  self.执行等待=0
  self.回合数=0
  self.同门死亡=false
  if 玩家数据[玩家id].队伍==0 then
    self.发起id=玩家id
  else
    self.发起id=玩家数据[玩家id].队伍
  end
  self.队伍区分={[1]=self.发起id,[2]=0}
  --加载队伍数量
  self.玩家数据={}
    if 玩家数据[玩家id].队伍==0 then
      self.玩家数据[1]={id=玩家id,队伍=玩家id,位置=1}
    else
      local 临时队伍=玩家数据[玩家id].队伍
      for n=1,#队伍数据[临时队伍].成员数据 do
        if 队伍处理类:取是否助战(玩家数据[玩家id].队伍,n) == 0 then
          self.玩家数据[#self.玩家数据+1]={id=队伍数据[临时队伍].成员数据[n],队伍=临时队伍,位置=n}
          local 我的id=队伍数据[临时队伍].成员数据[n]
          for i=n,#队伍数据[临时队伍].成员数据 do
            local 你的id=队伍数据[临时队伍].成员数据[i]
            if 我的id~=你的id then
              for a=1,#玩家数据[我的id].角色.数据.好友数据.好友 do
                if 玩家数据[我的id].角色.数据.好友数据.好友[a].id==你的id then
                  for w=1,#玩家数据[你的id].角色.数据.好友数据.好友 do
                    if 玩家数据[你的id].角色.数据.好友数据.好友[w].id==我的id then
                      if 玩家数据[你的id].角色.数据.好友数据.好友[w].好友度==nil then
                        玩家数据[你的id].角色.数据.好友数据.好友[w].好友度=1
                      else
                        玩家数据[你的id].角色.数据.好友数据.好友[w].好友度=玩家数据[你的id].角色.数据.好友数据.好友[w].好友度+1
                      end
                      if 玩家数据[我的id].角色.数据.好友数据.好友[a].好友度==nil then
                        玩家数据[我的id].角色.数据.好友数据.好友[a].好友度=1
                      else
                        玩家数据[我的id].角色.数据.好友数据.好友[a].好友度=玩家数据[我的id].角色.数据.好友数据.好友[a].好友度+1
                      end
                    end
                  end
                end
              end
            end
          end
        end
      end
    end
    if 序号>=200000 then --PK
      self.挑战id=任务id--4000130
      self.队伍区分[2] = self.挑战id
      if 玩家数据[self.挑战id].队伍==0 then
        self.玩家数据[#self.玩家数据+1]={id=self.挑战id,队伍=self.挑战id,位置=1}
      else
        for n=1,#队伍数据[玩家数据[self.挑战id].队伍].成员数据 do
          if 队伍处理类:取是否助战(玩家数据[self.挑战id].队伍,n) == 0 then
            self.玩家数据[#self.玩家数据+1]={id=队伍数据[玩家数据[self.挑战id].队伍].成员数据[n],队伍=self.挑战id,位置=n}
            local 我的id=队伍数据[玩家数据[self.挑战id].队伍].成员数据[n]
            for i=n,#队伍数据[玩家数据[self.挑战id].队伍].成员数据 do
                local 你的id=队伍数据[玩家数据[self.挑战id].队伍].成员数据[i]
                if 我的id~=你的id then
                  for a=1,#玩家数据[我的id].角色.数据.好友数据.好友 do
                    if 玩家数据[我的id].角色.数据.好友数据.好友[a].id==你的id then
                      for w=1,#玩家数据[你的id].角色.数据.好友数据.好友 do
                        if 玩家数据[你的id].角色.数据.好友数据.好友[w].id==我的id then
                          if 玩家数据[你的id].角色.数据.好友数据.好友[w].好友度==nil then
                            玩家数据[你的id].角色.数据.好友数据.好友[w].好友度=1
                          else
                            玩家数据[你的id].角色.数据.好友数据.好友[w].好友度=玩家数据[你的id].角色.数据.好友数据.好友[w].好友度+1
                          end
                          if 玩家数据[我的id].角色.数据.好友数据.好友[a].好友度==nil then
                            玩家数据[我的id].角色.数据.好友数据.好友[a].好友度=1
                          else
                            玩家数据[我的id].角色.数据.好友数据.好友[a].好友度=玩家数据[我的id].角色.数据.好友数据.好友[a].好友度+1
                          end
                        end
                      end
                    end
                  end
                end
              end
          end
        end
      end
    end
  --设定发起方单位
  self.加载数量=#self.玩家数据
  for n,v in pairs(self.玩家数据) do
    self.参战玩家[#self.参战玩家+1]={队伍=self.玩家数据[n].队伍,id=self.玩家数据[n].id,连接id=玩家数据[self.玩家数据[n].id].连接id,断线=false,退出=false}
    self:加载单个玩家(self.玩家数据[n].id,self.玩家数据[n].位置)
  end

  if 序号<200000 then
    if 序号==100001 then --野外单位
      self:加载野外单位()
    elseif 序号==100007 then
      self:加载野外单位1()
    else
      self:加载指定单位(地图,任务id)  --
    end
  end
  self:重置单位属性()
  for n=1,#self.参战玩家 do
    发送数据(self.参战玩家[n].连接id,5501,{id=self.参战玩家[n].队伍,音乐=nil,总数=#self.参战单位})
    for i=1,#self.参战单位 do
      发送数据(self.参战玩家[n].连接id,5502,self:取加载信息(i))
    end
  end
end

function 战斗处理类:添加bb法宝属性(编号,id)
  local 主人=self:取参战编号(id,"角色")
  if 主人==nil then
    return
  end
  for n=1,#self.参战单位[主人].法宝佩戴 do
    local 名称=self.参战单位[主人].法宝佩戴[n].名称
    local 境界=self.参战单位[主人].法宝佩戴[n].境界
    if 主人~=nil and n~=nil then
      if 名称=="九黎战鼓" and  self:扣除法宝灵气(主人,n,1) then
        self.参战单位[编号].伤害=self.参战单位[编号].伤害+qz(境界*5)
      elseif 名称=="盘龙壁" and  self:扣除法宝灵气(主人,n,1) then
        self.参战单位[编号].防御=self.参战单位[编号].防御+qz(境界*3)
      elseif 名称=="神行飞剑" and  self:扣除法宝灵气(主人,n,1) then
        self.参战单位[编号].速度=self.参战单位[编号].速度+qz(境界*2)
      elseif 名称=="汇灵盏" and  self:扣除法宝灵气(主人,n,1) then
        self.参战单位[编号].灵力=self.参战单位[编号].灵力+qz(境界*3)
      elseif 名称=="兽王令" and  self:扣除法宝灵气(主人,n,1) then
        self.参战单位[编号].伤害=self.参战单位[编号].伤害+qz(境界*2.5)
        self.参战单位[编号].防御=self.参战单位[编号].防御+qz(境界*1.5)
        self.参战单位[编号].速度=self.参战单位[编号].速度+qz(境界*1)
        self.参战单位[编号].灵力=self.参战单位[编号].灵力+qz(境界*1.5)
      end
    end
  end
end

function 战斗处理类:取指定法宝(编号,法宝,数额,扣除)
  if self.参战单位[编号]==nil or self.参战单位[编号].类型~="角色" then
    return false
  end
  local 是否有 = false
  local id=self.参战单位[编号].玩家id
  for n=1,#self.参战单位[编号].法宝佩戴 do
      if self.参战单位[编号].法宝佩戴[n].名称==法宝 and not 是否有 then
        if 扣除~=nil then
          return true
        else
          if 名称=="金甲仙衣" and self.参战单位[编号].法宝佩戴[n].境界*3<取随机数() then
            是否有=true
            return false
          elseif 名称=="降魔斗篷" and self.参战单位[编号].法宝佩戴[n].境界*3<取随机数() then
            是否有=true
            return false
          elseif 名称=="嗜血幡" and self.参战单位[编号].法宝佩戴[n].境界*5<取随机数()  then
            是否有=true
            return false
          end
          local 扣除id=self.参战单位[编号].法宝佩戴[n].序列
          if 玩家数据[id].道具.数据[扣除id]==nil then
            return false
          elseif 玩家数据[id].道具.数据[扣除id].魔法<数额 then
            return false
          elseif self.参战单位[编号].法宝已扣 ~= nil and self.参战单位[编号].法宝已扣[法宝] ~= nil then
            return true
          else
            玩家数据[id].道具.数据[扣除id].魔法=玩家数据[id].道具.数据[扣除id].魔法-数额
            发送数据(玩家数据[id].连接id,38,{内容="你的法宝["..玩家数据[id].道具.数据[扣除id].名称.."]灵气减少了"..数额.."点"})
            if self.参战单位[编号].法宝已扣 == nil then
              self.参战单位[编号].法宝已扣 = {}
            end
            self.参战单位[编号].法宝已扣[法宝] = true
            return true
          end
        end
      end
    end
  return false
end

function 战斗处理类:取奇经八脉是否有(编号,名称)
  if self.参战单位[编号].奇经八脉~=nil and self.参战单位[编号].奇经八脉[名称] ~= nil and self.参战单位[编号].奇经八脉[名称] == 1 then
    return true
  end
  return false
end

function 战斗处理类:直接取角色取奇经八脉是否有(编号,名称)
  if 玩家数据[编号].角色.数据.奇经八脉~=nil and 玩家数据[编号].角色.数据.奇经八脉[名称] ~= nil and 玩家数据[编号].角色.数据.奇经八脉[名称] == 1 then
    return true
  end
  return false
end

function 战斗处理类:取指定法宝境界(编号,法宝)
  if self.参战单位[编号].类型~="角色" then
    return false
  end
  local id=self.参战单位[编号].玩家id
  for n=1,#self.参战单位[编号].法宝佩戴 do
    if self.参战单位[编号].法宝佩戴[n].名称==法宝 then
      return self.参战单位[编号].法宝佩戴[n].境界
    end
  end
  return false
end

function 战斗处理类:扣除法宝灵气(编号,序列,数额,类型)
  local 扣除id=self.参战单位[编号].法宝佩戴[序列].序列
  local id=self.参战单位[编号].玩家id
  if 编号~=nil and self:取奇经八脉是否有(编号,"神念") then
      self.参战单位[编号].愤怒=self.参战单位[编号].愤怒+10
      if self.参战单位[编号].愤怒 > 150 then
        self.参战单位[编号].愤怒 = 150
      end
  end
  if 类型==nil then
    if 玩家数据[id].道具.数据[扣除id].魔法<数额 then
      return false
    else
      玩家数据[id].道具.数据[扣除id].魔法=玩家数据[id].道具.数据[扣除id].魔法-数额
      发送数据(玩家数据[id].连接id,38,{内容="你的法宝["..玩家数据[id].道具.数据[扣除id].名称.."]灵气减少了"..数额.."点"})
      return true
    end
    else
    if 玩家数据[id].道具.数据[扣除id].魔法<取灵气上限(玩家数据[id].道具.数据[扣除id].分类) then
      玩家数据[id].道具.数据[扣除id].魔法=玩家数据[id].道具.数据[扣除id].魔法+数额
      发送数据(玩家数据[id].连接id,38,{内容="你的法宝["..玩家数据[id].道具.数据[扣除id].名称.."]灵气增加了"..数额.."点"})
    else
      发送数据(玩家数据[id].连接id,38,{内容="你的法宝["..玩家数据[id].道具.数据[扣除id].名称.."]灵气已经满了，无法再获得灵气"})
    end
  end
end

function 战斗处理类:加载奇经八脉(编号,id)
  if 玩家数据[id].角色.数据.奇经八脉~=nil then
    self.参战单位[编号].奇经八脉=玩家数据[id].角色.数据.奇经八脉
  end
end

function 战斗处理类:加载法宝(编号,id)
  for n=1,3 do
    local 符合=false
    if 玩家数据[id].角色.数据.法宝佩戴[n]~=nil then
      local 道具id=玩家数据[id].角色.数据.法宝佩戴[n]
      if 玩家数据[id].道具.数据[道具id]~=nil then
        local 名称=玩家数据[id].道具.数据[道具id].名称
        local 境界=玩家数据[id].道具.数据[道具id].气血
        local 灵气=玩家数据[id].道具.数据[道具id].魔法
        local 临时数据=取物品数据(名称)
        self.参战单位[编号].法宝佩戴[#self.参战单位[编号].法宝佩戴+1]={名称=名称,境界=境界,玩家id=id,序列=玩家数据[id].角色.数据.法宝佩戴[n]}
        local 法宝序列=#self.参战单位[编号].法宝佩戴
        if 编号~=nil and 法宝序列~= nil then
            if 名称=="飞剑" and self:扣除法宝灵气(编号,法宝序列,1) then
              self.参战单位[编号].命中=self.参战单位[编号].命中+qz(境界*10)
            elseif 名称=="拭剑石" and self:扣除法宝灵气(编号,法宝序列,1) then
              self.参战单位[编号].伤害=self.参战单位[编号].伤害+qz(境界*10)
            elseif 名称=="七杀" and self:扣除法宝灵气(编号,法宝序列,1) then
              self.参战单位[编号].伤害=self.参战单位[编号].伤害+qz(境界*5+100)
            elseif 名称=="风袋" and self:扣除法宝灵气(编号,法宝序列,1) then
              self.参战单位[编号].速度=self.参战单位[编号].速度+qz(境界*3)+10
            elseif 名称=="五火神焰印" and self:扣除法宝灵气(编号,法宝序列,1) then
              self.参战单位[编号].法暴=self.参战单位[编号].法暴+qz(境界*2+3)
            elseif 名称=="附灵玉" and self:扣除法宝灵气(编号,法宝序列,1) then
              self.参战单位[编号].灵力=self.参战单位[编号].灵力+qz(境界*3+10)
            elseif 名称=="月影" and self:扣除法宝灵气(编号,法宝序列,1) then
              if self.参战单位[编号].法连==nil then
                self.参战单位[编号].法连=0
              end
              self.参战单位[编号].法连=self.参战单位[编号].法连+qz(境界+10)
            elseif 名称=="流影云笛" and self:扣除法宝灵气(编号,法宝序列,1) then
              if self.参战单位[编号].法术伤害==nil then
                self.参战单位[编号].法术伤害=0
              end
              self.参战单位[编号].法术伤害=self.参战单位[编号].法术伤害+qz(境界*2+10)
            elseif 名称=="宿幕星河" and self:扣除法宝灵气(编号,法宝序列,1) then
              if self.参战单位[编号].法暴==nil then
                self.参战单位[编号].法暴=0
              end
              self.参战单位[编号].法暴=self.参战单位[编号].法暴+qz(境界*2+3)
            elseif 名称=="蟠龙玉璧" and self:扣除法宝灵气(编号,法宝序列,1) then
              self.参战单位[编号].防御=self.参战单位[编号].防御+qz(境界*5+100)
              self.参战单位[编号].法防=self.参战单位[编号].法防+qz(境界*5+100)
            elseif 名称=="落星飞鸿" and self:扣除法宝灵气(编号,法宝序列,1) then
              self.参战单位[编号].伤害=self.参战单位[编号].伤害+qz(境界*5+100)
            elseif 名称=="千斗金樽" and self:扣除法宝灵气(编号,法宝序列,1) then
              if self.参战单位[编号].必杀==nil then
                self.参战单位[编号].必杀=0
              end
              self.参战单位[编号].必杀=self.参战单位[编号].必杀+qz(境界+5)
            elseif 名称=="归元圣印" and self:扣除法宝灵气(编号,法宝序列,1) then
              if self.参战单位[编号].治疗能力==nil then
                self.参战单位[编号].治疗能力=0
              end
              self.参战单位[编号].治疗能力=self.参战单位[编号].治疗能力+(境界*10+100)
            elseif 名称=="碧玉葫芦" and self:扣除法宝灵气(编号,法宝序列,1) then
              if self.参战单位[编号].治疗能力==nil then
                self.参战单位[编号].治疗能力=0
              end
              self.参战单位[编号].治疗能力=self.参战单位[编号].治疗能力+(境界*10+10)
            elseif 名称=="天师符" and self:扣除法宝灵气(编号,法宝序列,1)  then
              if self.参战单位[编号].封印命中等级==nil then
                self.参战单位[编号].封印命中等级=0
              end
              self.参战单位[编号].封印命中等级=self.参战单位[编号].封印命中等级+(境界*5+100)
            end
          end
      end
    end
  end
end

function 战斗处理类:重置单位属性()
  self.战斗流程={}
  for n=1,#self.参战单位 do
    self.参战单位[n].法术状态={}
    self.参战单位[n].奇经八脉={}
    self.参战单位[n].追加法术={}
    self.参战单位[n].附加状态={}
    if self.参战单位[n].主动技能==nil then
      self.参战单位[n].主动技能={}
    end
    self.参战单位[n].特技技能={}
    self.参战单位[n].战意=0
    self.参战单位[n].法暴=0
    self.参战单位[n].法防=0
    self.参战单位[n].必杀=1
    self.参战单位[n].溅射=0
    self.参战单位[n].驱怪=0
    self.参战单位[n].夜战=0
    self.参战单位[n].百步穿杨=0
    self.参战单位[n].福泽天下=0
    self.参战单位[n].行云流水=0
    self.参战单位[n].索命无常=0
    self.参战单位[n].烟雨飘摇=0
    self.参战单位[n].天雷地火=0
    self.参战单位[n].石破天惊=0
    self.参战单位[n].网罗乾坤=0
    self.参战单位[n].云随风舞=0
    self.参战单位[n].心随我动=0
    self.参战单位[n].隔山打牛=0
    self.参战单位[n].天降大任=0
    self.参战单位[n].飞檐走壁=0
    self.参战单位[n].慈悲效果=0
    self.参战单位[n].攻击修炼=0
    self.参战单位[n].法术修炼=0
    self.参战单位[n].怒击效果=false
    self.参战单位[n].防御修炼=0
    self.参战单位[n].抗法修炼=0
    self.参战单位[n].猎术修炼=0
    self.参战单位[n].毫毛次数=0
    self.参战单位[n].法宝佩戴={}
    self.参战单位[n].攻击五行=""
    self.参战单位[n].防御五行=""
    self.参战单位[n].修炼数据={法修=0,抗法=0,攻击=0,法防=0,猎术=0}
    if self.参战单位[n].命中==nil then
      self.参战单位[n].命中=self.参战单位[n].伤害
    end
    for i=1,#灵饰战斗属性 do
      self.参战单位[n][灵饰战斗属性[i]]=0
    end
    if self.参战单位[n].队伍~=0 and self.参战单位[n].系统队友==nil then
      if self.参战单位[n].类型=="角色" and  self.参战单位[n].助战编号 == nil then
        self.参战单位[n].攻击修炼=玩家数据[self.参战单位[n].玩家id].角色.数据.修炼.攻击修炼[1]
        self.参战单位[n].法术修炼=玩家数据[self.参战单位[n].玩家id].角色.数据.修炼.法术修炼[1]
        self.参战单位[n].防御修炼=玩家数据[self.参战单位[n].玩家id].角色.数据.修炼.防御修炼[1]
        self.参战单位[n].抗法修炼=玩家数据[self.参战单位[n].玩家id].角色.数据.修炼.抗法修炼[1]
        self.参战单位[n].猎术修炼=玩家数据[self.参战单位[n].玩家id].角色.数据.修炼.猎术修炼[1]
        if self.参战单位[n].通真达灵 ~= nil then
          self.参战单位[n].法术防御 = self.参战单位[n].法术防御 * (1+self.参战单位[n].通真达灵/100)
        end
        local 特技=玩家数据[self.参战单位[n].玩家id].角色:取特技()
        for i=1,#特技 do
          self.参战单位[n].特技技能[i]={名称=特技[i],等级=0}
        end
        if self.参战单位[n].类型=="角色" and self.参战单位[n].门派 =="花果山" then
          self.参战单位[n].溅射 = 0.3
        end
      --检查符石效果
        for i,v in pairs(玩家数据[self.参战单位[n].玩家id].角色.数据.装备) do
          if v ~= nil and 玩家数据[self.参战单位[n].玩家id].道具.数据[v] ~= nil then
            if (玩家数据[self.参战单位[n].玩家id].道具.数据[v].特效 ~= nil and 玩家数据[self.参战单位[n].玩家id].道具.数据[v].特效 == "神佑") or (玩家数据[self.参战单位[n].玩家id].道具.数据[v].第二特效 ~= nil and 玩家数据[self.参战单位[n].玩家id].道具.数据[v].第二特效 == "神佑") then
              self.参战单位[n].神佑 = 10
            end
            if i == 5 then
              if (玩家数据[self.参战单位[n].玩家id].道具.数据[v].特效 ~= nil and 玩家数据[self.参战单位[n].玩家id].道具.数据[v].特效 == "愤怒") or (玩家数据[self.参战单位[n].玩家id].道具.数据[v].第二特效 ~= nil and 玩家数据[self.参战单位[n].玩家id].道具.数据[v].第二特效 == "愤怒") then
                self.参战单位[n].愤怒腰带 = 1
              end
              if (玩家数据[self.参战单位[n].玩家id].道具.数据[v].特效 ~= nil and 玩家数据[self.参战单位[n].玩家id].道具.数据[v].特效 == "暴怒") or (玩家数据[self.参战单位[n].玩家id].道具.数据[v].第二特效 ~= nil and 玩家数据[self.参战单位[n].玩家id].道具.数据[v].第二特效 == "暴怒") then
                self.参战单位[n].暴怒腰带 = 1
              end
            end
          end
          if v ~= nil and 玩家数据[self.参战单位[n].玩家id].道具.数据[v] ~= nil and 玩家数据[self.参战单位[n].玩家id].道具.数据[v].临时附魔 ~= nil then
            玩家数据[self.参战单位[n].玩家id].角色:附魔装备刷新(self.参战单位[n].玩家id,v)
            if i+0 == 5 and 玩家数据[self.参战单位[n].玩家id].道具.数据[v].临时附魔.愤怒 ~= nil and 玩家数据[self.参战单位[n].玩家id].道具.数据[v].临时附魔.愤怒.数值 > 0 then
              self.参战单位[n].愤怒=self.参战单位[n].愤怒+玩家数据[self.参战单位[n].玩家id].道具.数据[v].临时附魔.愤怒.数值
              if self.参战单位[n].愤怒>=150 then
                self.参战单位[n].愤怒=150
              end
            elseif i+0 == 2 and 玩家数据[self.参战单位[n].玩家id].道具.数据[v].临时附魔.法术防御 ~= nil and 玩家数据[self.参战单位[n].玩家id].道具.数据[v].临时附魔.法术防御.数值 > 0 then
              self.参战单位[n].法术防御=self.参战单位[n].法术防御+玩家数据[self.参战单位[n].玩家id].道具.数据[v].临时附魔.法术防御.数值
            elseif i+0 == 2 and 玩家数据[self.参战单位[n].玩家id].道具.数据[v].临时附魔.法术伤害 ~= nil and 玩家数据[self.参战单位[n].玩家id].道具.数据[v].临时附魔.法术伤害.数值 > 0 then
              self.参战单位[n].法术伤害=self.参战单位[n].法术伤害+玩家数据[self.参战单位[n].玩家id].道具.数据[v].临时附魔.法术伤害.数值
            end
          end
          if v~=nil and 玩家数据[self.参战单位[n].玩家id].道具.数据[v]~=nil and 玩家数据[self.参战单位[n].玩家id].道具.数据[v].符石组合 ~= nil then
            if 玩家数据[self.参战单位[n].玩家id].道具.数据[v].符石组合.符石组合 == "无心插柳" then
              if 玩家数据[self.参战单位[n].玩家id].道具.数据[v].符石组合.等级 == 1 then
                  self.参战单位[n].溅射 = 0.15
              elseif 玩家数据[self.参战单位[n].玩家id].道具.数据[v].符石组合.等级 == 2 then
                  self.参战单位[n].溅射 = 0.2
              elseif 玩家数据[self.参战单位[n].玩家id].道具.数据[v].符石组合.等级 == 3 then
                  self.参战单位[n].溅射 = 0.25
              elseif 玩家数据[self.参战单位[n].玩家id].道具.数据[v].符石组合.等级 == 4 then
                  self.参战单位[n].溅射 = 0.3
              end
            elseif 玩家数据[self.参战单位[n].玩家id].道具.数据[v].符石组合.符石组合 == "飞檐走壁" then
              if 玩家数据[self.参战单位[n].玩家id].道具.数据[v].符石组合.等级 == 1 then
                  self.参战单位[n].飞檐走壁 = 0.08
              elseif 玩家数据[self.参战单位[n].玩家id].道具.数据[v].符石组合.等级 == 2 then
                  self.参战单位[n].飞檐走壁 = 0.12
              elseif 玩家数据[self.参战单位[n].玩家id].道具.数据[v].符石组合.等级 == 3 then
                  self.参战单位[n].飞檐走壁 = 0.16
              end
            elseif 玩家数据[self.参战单位[n].玩家id].道具.数据[v].符石组合.符石组合 == "百步穿杨" then
              if 玩家数据[self.参战单位[n].玩家id].道具.数据[v].符石组合.等级 == 1 then
                  self.参战单位[n].百步穿杨 = 200
              elseif 玩家数据[self.参战单位[n].玩家id].道具.数据[v].符石组合.等级 == 2 then
                  self.参战单位[n].百步穿杨 = 450
              elseif 玩家数据[self.参战单位[n].玩家id].道具.数据[v].符石组合.等级 == 3 then
                  self.参战单位[n].百步穿杨 = 600
              elseif 玩家数据[self.参战单位[n].玩家id].道具.数据[v].符石组合.等级 == 4 then
                  self.参战单位[n].百步穿杨 = 800
              end
            elseif 玩家数据[self.参战单位[n].玩家id].道具.数据[v].符石组合.符石组合 == "天降大任" then
              if 玩家数据[self.参战单位[n].玩家id].道具.数据[v].符石组合.等级 == 1 then
                  self.参战单位[n].天降大任 = 0.05
              elseif 玩家数据[self.参战单位[n].玩家id].道具.数据[v].符石组合.等级 == 2 then
                  self.参战单位[n].天降大任 = 0.1
              elseif 玩家数据[self.参战单位[n].玩家id].道具.数据[v].符石组合.等级 == 3 then
                  self.参战单位[n].天降大任 = 0.15
              end
            elseif 玩家数据[self.参战单位[n].玩家id].道具.数据[v].符石组合.符石组合 == "风卷残云" then
              self.驱鬼几率 = 取随机数(1,100)
              if 玩家数据[self.参战单位[n].玩家id].道具.数据[v].符石组合.等级 == 1 then
                if self.驱鬼几率 >= 95 then
                    self.参战单位[n].驱鬼=2
                else
                  self.参战单位[n].驱鬼 = nil
                end
              elseif 玩家数据[self.参战单位[n].玩家id].道具.数据[v].符石组合.等级 == 2 then
                if self.驱鬼几率 >= 90 then
                    self.参战单位[n].驱鬼=2
                else
                  self.参战单位[n].驱鬼 = nil
                end
              elseif 玩家数据[self.参战单位[n].玩家id].道具.数据[v].符石组合.等级 == 3 then
                if self.驱鬼几率 >= 85 then
                    self.参战单位[n].驱鬼=2
                else
                  self.参战单位[n].驱鬼 = nil
                end
              elseif 玩家数据[self.参战单位[n].玩家id].道具.数据[v].符石组合.等级 ==4 then
                if self.驱鬼几率 >= 80 then
                    self.参战单位[n].驱鬼=2
                else
                  self.参战单位[n].驱鬼 = nil
                end
              end
            elseif 玩家数据[self.参战单位[n].玩家id].道具.数据[v].符石组合.符石组合 =="隔山打牛" then
              if 玩家数据[self.参战单位[n].玩家id].道具.数据[v].符石组合.等级 == 1 then
                self.参战单位[n].灵力 = self.参战单位[n].灵力 + 20
              elseif  玩家数据[self.参战单位[n].玩家id].道具.数据[v].符石组合.等级== 2 then
                self.参战单位[n].灵力 = self.参战单位[n].灵力 + 30
              elseif  玩家数据[self.参战单位[n].玩家id].道具.数据[v].符石组合.等级== 3 then
                self.参战单位[n].灵力 = self.参战单位[n].灵力 + 50
              elseif  玩家数据[self.参战单位[n].玩家id].道具.数据[v].符石组合.等级==4 then
                self.参战单位[n].灵力 = self.参战单位[n].灵力 + 70
              end
            elseif 玩家数据[self.参战单位[n].玩家id].道具.数据[v].符石组合.符石组合 =="心随我动" then
              if 玩家数据[self.参战单位[n].玩家id].道具.数据[v].符石组合.等级 == 1 then
                self.参战单位[n].心随我动=250
              elseif  玩家数据[self.参战单位[n].玩家id].道具.数据[v].符石组合.等级== 2 then
                self.参战单位[n].心随我动=400
              elseif  玩家数据[self.参战单位[n].玩家id].道具.数据[v].符石组合.等级== 3 then
                self.参战单位[n].心随我动=700
              elseif  玩家数据[self.参战单位[n].玩家id].道具.数据[v].符石组合.等级==4 then
                self.参战单位[n].心随我动=900
              end
            elseif 玩家数据[self.参战单位[n].玩家id].道具.数据[v].符石组合.符石组合 =="云随风舞" then
              if 玩家数据[self.参战单位[n].玩家id].道具.数据[v].符石组合.等级 == 1 then
                self.参战单位[n].云随风舞=200
              elseif  玩家数据[self.参战单位[n].玩家id].道具.数据[v].符石组合.等级== 2 then
                self.参战单位[n].云随风舞=400
              elseif  玩家数据[self.参战单位[n].玩家id].道具.数据[v].符石组合.等级== 3 then
                self.参战单位[n].云随风舞=700
              elseif  玩家数据[self.参战单位[n].玩家id].道具.数据[v].符石组合.等级==4 then
                self.参战单位[n].云随风舞=800
              end
            elseif 玩家数据[self.参战单位[n].玩家id].道具.数据[v].符石组合.符石组合 =="网罗乾坤" then
              if 玩家数据[self.参战单位[n].玩家id].道具.数据[v].符石组合.等级 == 1 then
                self.参战单位[n].网罗乾坤=math.floor(self.参战单位[n].等级/2)
              elseif  玩家数据[self.参战单位[n].玩家id].道具.数据[v].符石组合.等级== 2 then
                self.参战单位[n].网罗乾坤=math.floor(self.参战单位[n].等级/1.5)
              elseif  玩家数据[self.参战单位[n].玩家id].道具.数据[v].符石组合.等级== 3 then
                self.参战单位[n].网罗乾坤=self.参战单位[n].等级
              end
            elseif 玩家数据[self.参战单位[n].玩家id].道具.数据[v].符石组合.符石组合 =="石破天惊" then
              if 玩家数据[self.参战单位[n].玩家id].道具.数据[v].符石组合.等级 == 1 then
                self.参战单位[n].石破天惊=math.floor(self.参战单位[n].等级/2)
              elseif  玩家数据[self.参战单位[n].玩家id].道具.数据[v].符石组合.等级== 2 then
                self.参战单位[n].石破天惊=math.floor(self.参战单位[n].等级/1.5)
              elseif  玩家数据[self.参战单位[n].玩家id].道具.数据[v].符石组合.等级== 3 then
                self.参战单位[n].石破天惊=self.参战单位[n].等级
              end
            elseif 玩家数据[self.参战单位[n].玩家id].道具.数据[v].符石组合.符石组合 =="天雷地火" then
              if 玩家数据[self.参战单位[n].玩家id].道具.数据[v].符石组合.等级 == 1 then
                self.参战单位[n].天雷地火=math.floor(self.参战单位[n].等级/2)
              elseif  玩家数据[self.参战单位[n].玩家id].道具.数据[v].符石组合.等级== 2 then
                self.参战单位[n].天雷地火=math.floor(self.参战单位[n].等级/1.5)
              elseif  玩家数据[self.参战单位[n].玩家id].道具.数据[v].符石组合.等级== 3 then
                self.参战单位[n].天雷地火=self.参战单位[n].等级
              end
            elseif 玩家数据[self.参战单位[n].玩家id].道具.数据[v].符石组合.符石组合 =="烟雨飘摇" then
              if 玩家数据[self.参战单位[n].玩家id].道具.数据[v].符石组合.等级 == 1 then
                self.参战单位[n].烟雨飘摇=math.floor(self.参战单位[n].等级/2)
              elseif  玩家数据[self.参战单位[n].玩家id].道具.数据[v].符石组合.等级== 2 then
                self.参战单位[n].烟雨飘摇=math.floor(self.参战单位[n].等级/1.5)
              elseif  玩家数据[self.参战单位[n].玩家id].道具.数据[v].符石组合.等级== 3 then
                self.参战单位[n].烟雨飘摇=self.参战单位[n].等级
              end
            elseif 玩家数据[self.参战单位[n].玩家id].道具.数据[v].符石组合.符石组合 =="索命无常" then
              if 玩家数据[self.参战单位[n].玩家id].道具.数据[v].符石组合.等级 == 1 then
                self.参战单位[n].索命无常=math.floor(self.参战单位[n].等级/2)
              elseif  玩家数据[self.参战单位[n].玩家id].道具.数据[v].符石组合.等级== 2 then
                self.参战单位[n].索命无常=math.floor(self.参战单位[n].等级/1.5)
              elseif  玩家数据[self.参战单位[n].玩家id].道具.数据[v].符石组合.等级== 3 then
                self.参战单位[n].索命无常=self.参战单位[n].等级
              end
            elseif 玩家数据[self.参战单位[n].玩家id].道具.数据[v].符石组合.符石组合 =="行云流水" then
              if 玩家数据[self.参战单位[n].玩家id].道具.数据[v].符石组合.等级 == 1 then
                self.参战单位[n].行云流水=math.floor(self.参战单位[n].等级/2)
              elseif  玩家数据[self.参战单位[n].玩家id].道具.数据[v].符石组合.等级== 2 then
                self.参战单位[n].行云流水=math.floor(self.参战单位[n].等级/1.5)
              elseif  玩家数据[self.参战单位[n].玩家id].道具.数据[v].符石组合.等级== 3 then
                self.参战单位[n].行云流水=self.参战单位[n].等级
              end
            elseif 玩家数据[self.参战单位[n].玩家id].道具.数据[v].符石组合.符石组合 =="福泽天下" then
              if 玩家数据[self.参战单位[n].玩家id].道具.数据[v].符石组合.等级 == 1 then
                self.参战单位[n].福泽天下=math.floor(self.参战单位[n].等级/2)
              elseif  玩家数据[self.参战单位[n].玩家id].道具.数据[v].符石组合.等级== 2 then
                self.参战单位[n].福泽天下=math.floor(self.参战单位[n].等级/1.5)
              elseif  玩家数据[self.参战单位[n].玩家id].道具.数据[v].符石组合.等级== 3 then
                self.参战单位[n].福泽天下=self.参战单位[n].等级
              end
            elseif 玩家数据[self.参战单位[n].玩家id].道具.数据[v].符石组合.符石组合 =="暗度陈仓" then
              if self.参战单位[n].物伤减免==0 or self.参战单位[n].物伤减免==nil then
                  self.参战单位[n].物伤减免 = 0
              else
                  self.参战单位[n].物伤减免 = self.参战单位[n].物伤减免-0.03
              end
            elseif 玩家数据[self.参战单位[n].玩家id].道具.数据[v].符石组合.符石组合 =="点石成金" then
              if self.参战单位[n].物伤减免==0 or self.参战单位[n].物伤减免==nil then
                self.参战单位[n].物伤减免 = 0
              end
              self.参战单位[n].物伤减免 = self.参战单位[n].物伤减免+0.03
            elseif 玩家数据[self.参战单位[n].玩家id].道具.数据[v].符石组合.符石组合 =="化敌为友" then
              if self.参战单位[n].法伤减免==0 or self.参战单位[n].法伤减免==nil then
                self.参战单位[n].法伤减少 = 0.97
              else
                self.参战单位[n].法伤减少 = self.参战单位[n].法伤减少+0.97
              end
            end
          end
        end
      --检查套装效果
        local 临时套装={}
        for w, v in pairs(玩家数据[self.参战单位[n].玩家id].角色.数据.装备) do
           if v~=nil and 玩家数据[self.参战单位[n].玩家id].道具.数据[v]~=nil and 玩家数据[self.参战单位[n].玩家id].道具.数据[v].套装效果~=nil then
             临时套装[#临时套装+1]={玩家数据[self.参战单位[n].玩家id].道具.数据[v].套装效果[1],玩家数据[self.参战单位[n].玩家id].道具.数据[v].套装效果[2]}
           end
        end

        if #临时套装>0 then
          for i=1,#临时套装 do
            local 重复=false
            local 数量=1
            for a=1,#self.参战单位[n][临时套装[i][1]] do
              if self.参战单位[n][临时套装[i][1]][a].名称==临时套装[i][2] then
                重复=true
              end
            end
            if 重复==false then
              for a=1,#临时套装 do
                if a~=i then
                  if 临时套装[a][1]==临时套装[i][1] and 临时套装[a][2]==临时套装[i][2] then
                   数量=数量+1
                  end
                end
              end
              if 数量>=3 then
                self.参战单位[n].套装追加概率 = 0
                local 等级=self.参战单位[n].等级
                if 数量>=5 then
                  等级=等级+10
                  self.参战单位[n].套装追加概率 = 20
                end
                self.参战单位[n][临时套装[i][1]][#self.参战单位[n][临时套装[i][1]]+1]={名称=临时套装[i][2],等级=等级}
              end
            end
          end
        end
        self.参战单位[n].变身数据=玩家数据[self.参战单位[n].玩家id].角色.数据.变身数据
        if self.参战单位[n].变身数据~=nil and 变身卡数据[self.参战单位[n].变身数据]~=nil and 变身卡数据[self.参战单位[n].变身数据].技能~="" then
          self:添加技能属性(self.参战单位[n],{变身卡数据[self.参战单位[n].变身数据].技能})
        end
        for i=1,#灵饰战斗属性 do
          self.参战单位[n][灵饰战斗属性[i]]=玩家数据[self.参战单位[n].玩家id].角色.数据[灵饰战斗属性[i]]
        end
          self:加载法宝(n,self.参战单位[n].玩家id)
          self:加载奇经八脉(n,self.参战单位[n].玩家id)
        if self.参战单位[n].经脉有无 ~= nil and self.参战单位[n].经脉有无 then
          self:经脉属性处理(n)
        end
        for i=1,#玩家数据[self.参战单位[n].玩家id].角色.数据.剧情技能 do
          if 玩家数据[self.参战单位[n].玩家id].角色.数据.剧情技能[i].名称=="妙手空空" then
            if self.战斗类型~=100001 or self.战斗类型~=100007  then
              self.参战单位[n].主动技能[#self.参战单位[n].主动技能+1]={名称=玩家数据[self.参战单位[n].玩家id].角色.数据.剧情技能[i].名称,等级=玩家数据[self.参战单位[n].玩家id].角色.数据.剧情技能[i].等级}
            end
          end
        end
        if 玩家数据[self.参战单位[n].玩家id].角色.数据.门派~=nil then
          if 玩家数据[self.参战单位[n].玩家id].角色.数据.门派=="凌波城" then
            self.参战单位[n].战意=2
          end
          for i=1,#玩家数据[self.参战单位[n].玩家id].角色.数据.师门技能 do
            for s=1,#玩家数据[self.参战单位[n].玩家id].角色.数据.师门技能[i].包含技能 do
              self.参战单位[n].师门技能[i]={名称=self.参战单位[n].师门技能[i],等级=玩家数据[self.参战单位[n].玩家id].角色.数据.师门技能[i].等级}
              if self.参战单位[n].师门技能[i].名称=="破浪诀" and self.参战单位[n].师门技能[i].等级>=self.参战单位[n].等级 and self:取经脉(n,"龙宫","踏涛") then
                self.参战单位[n].灵力= self.参战单位[n].灵力+60
              end
              if 玩家数据[self.参战单位[n].玩家id].角色.数据.师门技能[i].包含技能[s].学会 then
                local 名称=玩家数据[self.参战单位[n].玩家id].角色.数据.师门技能[i].包含技能[s].名称
                if self:取飞升技能(名称) == false or (self:取飞升技能(名称) and 剧情数据[self.参战单位[n].玩家id]~=nil and 剧情数据[self.参战单位[n].玩家id].飞升 ~= nil and 剧情数据[self.参战单位[n].玩家id].飞升.完成 ) then
                  if 名称 == "舍生取义" then
                    名称 = "舍身取义"
                    玩家数据[self.参战单位[n].玩家id].角色.数据.师门技能[i].包含技能[s].名称 = "舍身取义"
                    for i=1,#玩家数据[self.参战单位[n].玩家id].角色.数据.人物技能 do
                      if 玩家数据[self.参战单位[n].玩家id].角色.数据.人物技能[i].名称 == "舍生取义" then
                        玩家数据[self.参战单位[n].玩家id].角色.数据.人物技能[i].名称 = "舍身取义"
                      end
                    end
                  end
                  if (self:恢复技能(名称) or self:法攻技能(名称) or self:物攻技能(名称) or self:封印技能(名称) or self:减益技能(名称) or self:增益技能(名称)) and 玩家数据[self.参战单位[n].玩家id].角色.数据.门派~="花果山" then
                    self.参战单位[n].主动技能[#self.参战单位[n].主动技能+1]={名称=名称,等级=玩家数据[self.参战单位[n].玩家id].角色.数据.师门技能[i].等级}
                  end
                end
              end
            end
          end
        end

        if 玩家数据[self.参战单位[n].玩家id].角色.数据.门派 == nil or 玩家数据[self.参战单位[n].玩家id].角色.数据.门派 == "无" or  玩家数据[self.参战单位[n].玩家id].角色.数据.门派 == "无门派"then
          self.参战单位[n].主动技能[#self.参战单位[n].主动技能+1]={名称="牛刀小试",等级=玩家数据[self.参战单位[n].玩家id].角色.数据.等级}
        end
        if self:取奇经八脉是否有(n,"翩鸿一击") then
          self.参战单位[n].主动技能[#self.参战单位[n].主动技能+1]={名称="翩鸿一击",等级=self.参战单位[n].等级}
        end
        if self:取奇经八脉是否有(n,"长驱直入") then
          self.参战单位[n].主动技能[#self.参战单位[n].主动技能+1]={名称="长驱直入",等级=self.参战单位[n].等级}
        end
        if self:取奇经八脉是否有(n,"妙悟") then
          self.参战单位[n].主动技能[#self.参战单位[n].主动技能+1]={名称="妙悟",等级=self.参战单位[n].等级}
        end
        if self:取奇经八脉是否有(n,"诸天看护") then
          self.参战单位[n].主动技能[#self.参战单位[n].主动技能+1]={名称="诸天看护",等级=self.参战单位[n].等级}
        end
        if self:取奇经八脉是否有(n,"渡劫金身") then
          self.参战单位[n].主动技能[#self.参战单位[n].主动技能+1]={名称="渡劫金身",等级=self.参战单位[n].等级}
        end
        if self:取奇经八脉是否有(n,"碎玉弄影") then
          self.参战单位[n].主动技能[#self.参战单位[n].主动技能+1]={名称="碎玉弄影",等级=self.参战单位[n].等级}
        end
        if self:取奇经八脉是否有(n,"鸿渐于陆") then
          self.参战单位[n].主动技能[#self.参战单位[n].主动技能+1]={名称="鸿渐于陆",等级=self.参战单位[n].等级}
        end
        if self:取奇经八脉是否有(n,"飞符炼魂") then
          self.参战单位[n].主动技能[#self.参战单位[n].主动技能+1]={名称="飞符炼魂",等级=self.参战单位[n].等级}
        end
        if self:取奇经八脉是否有(n,"顺势而为") then
          self.参战单位[n].主动技能[#self.参战单位[n].主动技能+1]={名称="顺势而为",等级=self.参战单位[n].等级}
        end
        if self:取奇经八脉是否有(n,"钟馗论道") then
          self.参战单位[n].主动技能[#self.参战单位[n].主动技能+1]={名称="钟馗论道",等级=self.参战单位[n].等级}
        end
        if self:取奇经八脉是否有(n,"莲花心音") then
          self.参战单位[n].主动技能[#self.参战单位[n].主动技能+1]={名称="莲花心音",等级=self.参战单位[n].等级}
        end
        if self:取奇经八脉是否有(n,"波澜不惊") then
          self.参战单位[n].主动技能[#self.参战单位[n].主动技能+1]={名称="波澜不惊",等级=self.参战单位[n].等级}
        end
        if self:取奇经八脉是否有(n,"五行制化") then
          self.参战单位[n].主动技能[#self.参战单位[n].主动技能+1]={名称="五行制化",等级=self.参战单位[n].等级}
        end
        if self:取奇经八脉是否有(n,"莲心剑意") then
          self.参战单位[n].主动技能[#self.参战单位[n].主动技能+1]={名称="莲心剑意",等级=self.参战单位[n].等级}
        end
        if self:取奇经八脉是否有(n,"亢龙归海") then
          self.参战单位[n].主动技能[#self.参战单位[n].主动技能+1]={名称="亢龙归海",等级=self.参战单位[n].等级}
        end
        if self:取奇经八脉是否有(n,"雷浪穿云") then
          self.参战单位[n].主动技能[#self.参战单位[n].主动技能+1]={名称="雷浪穿云",等级=self.参战单位[n].等级}
        end
        if self:取奇经八脉是否有(n,"画地为牢") then
          self.参战单位[n].主动技能[#self.参战单位[n].主动技能+1]={名称="画地为牢",等级=self.参战单位[n].等级}
        end
        if self:取奇经八脉是否有(n,"风雷韵动") then
          self.参战单位[n].主动技能[#self.参战单位[n].主动技能+1]={名称="风雷韵动",等级=self.参战单位[n].等级}
        end
        if self:取奇经八脉是否有(n,"心随意动") then
           --self.参战单位[n].主动技能[#self.参战单位[n].主动技能+1]={名称="心随意动",等级=self.参战单位[n].等级}
        end
        if self:取奇经八脉是否有(n,"天命剑法") then
          self.参战单位[n].主动技能[#self.参战单位[n].主动技能+1]={名称="天命剑法",等级=self.参战单位[n].等级}
        end
        if self:取奇经八脉是否有(n,"魔焰滔天") then
          self.参战单位[n].主动技能[#self.参战单位[n].主动技能+1]={名称="魔焰滔天",等级=self.参战单位[n].等级}
        end
        if self:取奇经八脉是否有(n,"烈焰真诀") then
          self.参战单位[n].主动技能[#self.参战单位[n].主动技能+1]={名称="烈焰真诀",等级=self.参战单位[n].等级}
        end
        if self:取奇经八脉是否有(n,"百爪狂杀") then
          self.参战单位[n].主动技能[#self.参战单位[n].主动技能+1]={名称="百爪狂杀",等级=self.参战单位[n].等级}
        end
        if self:取奇经八脉是否有(n,"魑魅缠身") then
          self.参战单位[n].主动技能[#self.参战单位[n].主动技能+1]={名称="魑魅缠身",等级=self.参战单位[n].等级}
        end
        if self:取奇经八脉是否有(n,"落花成泥") then
          self.参战单位[n].主动技能[#self.参战单位[n].主动技能+1]={名称="落花成泥",等级=self.参战单位[n].等级}
        end
        if self:取奇经八脉是否有(n,"偷龙转凤") then
          self.参战单位[n].主动技能[#self.参战单位[n].主动技能+1]={名称="偷龙转凤",等级=self.参战单位[n].等级}
        end
        if self:取奇经八脉是否有(n,"风卷残云") then
          self.参战单位[n].主动技能[#self.参战单位[n].主动技能+1]={名称="风卷残云",等级=self.参战单位[n].等级}
        end
        if self:取奇经八脉是否有(n,"凋零之歌") then
          self.参战单位[n].主动技能[#self.参战单位[n].主动技能+1]={名称="凋零之歌",等级=self.参战单位[n].等级}
        end
        if self:取奇经八脉是否有(n,"真君显灵") then
          self.参战单位[n].主动技能[#self.参战单位[n].主动技能+1]={名称="真君显灵",等级=self.参战单位[n].等级}
        end
        if self:取奇经八脉是否有(n,"由己渡人") then
          self.参战单位[n].主动技能[#self.参战单位[n].主动技能+1]={名称="由己渡人",等级=self.参战单位[n].等级}
        end
        if self:取奇经八脉是否有(n,"同舟共济") then
          self.参战单位[n].主动技能[#self.参战单位[n].主动技能+1]={名称="同舟共济",等级=self.参战单位[n].等级}
        end
        if self:取奇经八脉是否有(n,"妖风四起") then
          self.参战单位[n].主动技能[#self.参战单位[n].主动技能+1]={名称="妖风四起",等级=self.参战单位[n].等级}
        end
      elseif self.参战单位[n].类型=="角色" and  self.参战单位[n].助战编号 ~= nil then
        self.参战单位[n].攻击修炼=玩家数据[self.参战单位[n].玩家id].助战.数据[self.参战单位[n].助战编号].修炼.攻击修炼
        self.参战单位[n].法术修炼=玩家数据[self.参战单位[n].玩家id].助战.数据[self.参战单位[n].助战编号].修炼.法术修炼
        self.参战单位[n].防御修炼=玩家数据[self.参战单位[n].玩家id].助战.数据[self.参战单位[n].助战编号].修炼.防御修炼
        self.参战单位[n].抗法修炼=玩家数据[self.参战单位[n].玩家id].助战.数据[self.参战单位[n].助战编号].修炼.抗法修炼
        self.参战单位[n].猎术修炼=0
        local 特技=玩家数据[self.参战单位[n].玩家id].助战.数据[self.参战单位[n].助战编号].特殊技能
        for i=1,#特技 do
          self.参战单位[n].特技技能[i]={名称=特技[i],等级=0}
        end
        for i,v in pairs(玩家数据[self.参战单位[n].玩家id].助战.数据[self.参战单位[n].助战编号].装备) do
          if v ~= nil and 玩家数据[self.参战单位[n].玩家id].道具.数据[v] ~= nil and 玩家数据[self.参战单位[n].玩家id].道具.数据[v].临时附魔 ~= nil then
            玩家数据[self.参战单位[n].玩家id].助战:附魔装备刷新(self.参战单位[n].助战编号,v)
            if v+0 == 5 and 玩家数据[self.参战单位[n].玩家id].道具.数据[v].临时附魔.愤怒 ~= nil and 玩家数据[self.参战单位[n].玩家id].道具.数据[v].临时附魔.愤怒.数值 > 0 then
              self.参战单位[n].愤怒=self.参战单位[n].愤怒+玩家数据[self.参战单位[n].玩家id].道具.数据[v].临时附魔.愤怒.数值
              if self.参战单位[n].愤怒>=150 then
                self.参战单位[n].愤怒=150
              end
            elseif v+0 == 2 and 玩家数据[self.参战单位[n].玩家id].道具.数据[v].临时附魔.法术防御 ~= nil and 玩家数据[self.参战单位[n].玩家id].道具.数据[v].临时附魔.法术防御.数值 > 0 then
              self.参战单位[n].法术防御=self.参战单位[n].法术防御+玩家数据[self.参战单位[n].玩家id].道具.数据[v].临时附魔.法术防御.数值
            elseif v+0 == 2 and 玩家数据[self.参战单位[n].玩家id].道具.数据[v].临时附魔.法术伤害 ~= nil and 玩家数据[self.参战单位[n].玩家id].道具.数据[v].临时附魔.法术伤害.数值 > 0 then
              self.参战单位[n].法术伤害=self.参战单位[n].法术伤害+玩家数据[self.参战单位[n].玩家id].道具.数据[v].临时附魔.法术伤害.数值
            end
          end

          if v~=nil and 玩家数据[self.参战单位[n].玩家id].道具.数据[v]~=nil and 玩家数据[self.参战单位[n].玩家id].道具.数据[v].符石组合 ~= nil then
            if 玩家数据[self.参战单位[n].玩家id].道具.数据[v].符石组合.符石组合 == "无心插柳" then
              if 玩家数据[self.参战单位[n].玩家id].道具.数据[v].符石组合.等级 == 1 then
                  self.参战单位[n].溅射 = 0.15
              elseif 玩家数据[self.参战单位[n].玩家id].道具.数据[v].符石组合.等级 == 2 then
                  self.参战单位[n].溅射 = 0.2
              elseif 玩家数据[self.参战单位[n].玩家id].道具.数据[v].符石组合.等级 == 3 then
                  self.参战单位[n].溅射 = 0.25
              elseif 玩家数据[self.参战单位[n].玩家id].道具.数据[v].符石组合.等级 == 4 then
                  self.参战单位[n].溅射 = 0.3
              end

            elseif 玩家数据[self.参战单位[n].玩家id].道具.数据[v].符石组合.符石组合 == "飞檐走壁" then
              if 玩家数据[self.参战单位[n].玩家id].道具.数据[v].符石组合.等级 == 1 then
                  self.参战单位[n].飞檐走壁 = 0.08
              elseif 玩家数据[self.参战单位[n].玩家id].道具.数据[v].符石组合.等级 == 2 then
                  self.参战单位[n].飞檐走壁 = 0.12
              elseif 玩家数据[self.参战单位[n].玩家id].道具.数据[v].符石组合.等级 == 3 then
                  self.参战单位[n].飞檐走壁 = 0.16
              end
            elseif 玩家数据[self.参战单位[n].玩家id].道具.数据[v].符石组合.符石组合 == "百步穿杨" then
              if 玩家数据[self.参战单位[n].玩家id].道具.数据[v].符石组合.等级 == 1 then
                  self.参战单位[n].百步穿杨 = 200
              elseif 玩家数据[self.参战单位[n].玩家id].道具.数据[v].符石组合.等级 == 2 then
                  self.参战单位[n].百步穿杨 = 450
              elseif 玩家数据[self.参战单位[n].玩家id].道具.数据[v].符石组合.等级 == 3 then
                  self.参战单位[n].百步穿杨 = 600
              elseif 玩家数据[self.参战单位[n].玩家id].道具.数据[v].符石组合.等级 == 4 then
                  self.参战单位[n].百步穿杨 = 800
              end
            elseif 玩家数据[self.参战单位[n].玩家id].道具.数据[v].符石组合.符石组合 == "天降大任" then
              if 玩家数据[self.参战单位[n].玩家id].道具.数据[v].符石组合.等级 == 1 then
                  self.参战单位[n].天降大任 = 0.05
              elseif 玩家数据[self.参战单位[n].玩家id].道具.数据[v].符石组合.等级 == 2 then
                  self.参战单位[n].天降大任 = 0.1
              elseif 玩家数据[self.参战单位[n].玩家id].道具.数据[v].符石组合.等级 == 3 then
                  self.参战单位[n].天降大任 = 0.15
              end
            elseif 玩家数据[self.参战单位[n].玩家id].道具.数据[v].符石组合.符石组合 == "风卷残云" then
              self.驱鬼几率 = 取随机数(1,100)
              if 玩家数据[self.参战单位[n].玩家id].道具.数据[v].符石组合.等级 == 1 then
                if self.驱鬼几率 >= 95 then
                    self.参战单位[n].驱鬼=2
                else
                  self.参战单位[n].驱鬼 = nil
                end
              elseif 玩家数据[self.参战单位[n].玩家id].道具.数据[v].符石组合.等级 == 2 then
                if self.驱鬼几率 >= 90 then
                    self.参战单位[n].驱鬼=2
                else
                  self.参战单位[n].驱鬼 = nil
                end
              elseif 玩家数据[self.参战单位[n].玩家id].道具.数据[v].符石组合.等级 == 3 then
                if self.驱鬼几率 >= 85 then
                    self.参战单位[n].驱鬼=2
                else
                  self.参战单位[n].驱鬼 = nil
                end
              elseif 玩家数据[self.参战单位[n].玩家id].道具.数据[v].符石组合.等级 ==4 then
                if self.驱鬼几率 >= 80 then
                    self.参战单位[n].驱鬼=2
                else
                  self.参战单位[n].驱鬼 = nil
                end
              end
            elseif 玩家数据[self.参战单位[n].玩家id].道具.数据[v].符石组合.符石组合 =="隔山打牛" then
              if 玩家数据[self.参战单位[n].玩家id].道具.数据[v].符石组合.等级 == 1 then
                self.参战单位[n].灵力 = self.参战单位[n].灵力 + 20
              elseif  玩家数据[self.参战单位[n].玩家id].道具.数据[v].符石组合.等级== 2 then
                self.参战单位[n].灵力 = self.参战单位[n].灵力 + 30
              elseif  玩家数据[self.参战单位[n].玩家id].道具.数据[v].符石组合.等级== 3 then
                self.参战单位[n].灵力 = self.参战单位[n].灵力 + 50
              elseif  玩家数据[self.参战单位[n].玩家id].道具.数据[v].符石组合.等级==4 then
                self.参战单位[n].灵力 = self.参战单位[n].灵力 + 70
              end
            elseif 玩家数据[self.参战单位[n].玩家id].道具.数据[v].符石组合.符石组合 =="心随我动" then
              if 玩家数据[self.参战单位[n].玩家id].道具.数据[v].符石组合.等级 == 1 then
                self.参战单位[n].心随我动=250
              elseif  玩家数据[self.参战单位[n].玩家id].道具.数据[v].符石组合.等级== 2 then
                self.参战单位[n].心随我动=400
              elseif  玩家数据[self.参战单位[n].玩家id].道具.数据[v].符石组合.等级== 3 then
                self.参战单位[n].心随我动=700
              elseif  玩家数据[self.参战单位[n].玩家id].道具.数据[v].符石组合.等级==4 then
                self.参战单位[n].心随我动=900
              end
            elseif 玩家数据[self.参战单位[n].玩家id].道具.数据[v].符石组合.符石组合 =="云随风舞" then
              if 玩家数据[self.参战单位[n].玩家id].道具.数据[v].符石组合.等级 == 1 then
                self.参战单位[n].云随风舞=200
              elseif  玩家数据[self.参战单位[n].玩家id].道具.数据[v].符石组合.等级== 2 then
                self.参战单位[n].云随风舞=400
              elseif  玩家数据[self.参战单位[n].玩家id].道具.数据[v].符石组合.等级== 3 then
                self.参战单位[n].云随风舞=700
              elseif  玩家数据[self.参战单位[n].玩家id].道具.数据[v].符石组合.等级==4 then
                self.参战单位[n].云随风舞=800
              end
            elseif 玩家数据[self.参战单位[n].玩家id].道具.数据[v].符石组合.符石组合 =="网罗乾坤" then
              if 玩家数据[self.参战单位[n].玩家id].道具.数据[v].符石组合.等级 == 1 then
                self.参战单位[n].网罗乾坤=math.floor(self.参战单位[n].等级/2)
              elseif  玩家数据[self.参战单位[n].玩家id].道具.数据[v].符石组合.等级== 2 then
                self.参战单位[n].网罗乾坤=math.floor(self.参战单位[n].等级/1.5)
              elseif  玩家数据[self.参战单位[n].玩家id].道具.数据[v].符石组合.等级== 3 then
                self.参战单位[n].网罗乾坤=self.参战单位[n].等级
              end
            elseif 玩家数据[self.参战单位[n].玩家id].道具.数据[v].符石组合.符石组合 =="石破天惊" then
              if 玩家数据[self.参战单位[n].玩家id].道具.数据[v].符石组合.等级 == 1 then
                self.参战单位[n].石破天惊=math.floor(self.参战单位[n].等级/2)
              elseif  玩家数据[self.参战单位[n].玩家id].道具.数据[v].符石组合.等级== 2 then
                self.参战单位[n].石破天惊=math.floor(self.参战单位[n].等级/1.5)
              elseif  玩家数据[self.参战单位[n].玩家id].道具.数据[v].符石组合.等级== 3 then
                self.参战单位[n].石破天惊=self.参战单位[n].等级
              end
            elseif 玩家数据[self.参战单位[n].玩家id].道具.数据[v].符石组合.符石组合 =="天雷地火" then
              if 玩家数据[self.参战单位[n].玩家id].道具.数据[v].符石组合.等级 == 1 then
                self.参战单位[n].天雷地火=math.floor(self.参战单位[n].等级/2)
              elseif  玩家数据[self.参战单位[n].玩家id].道具.数据[v].符石组合.等级== 2 then
                self.参战单位[n].天雷地火=math.floor(self.参战单位[n].等级/1.5)
              elseif  玩家数据[self.参战单位[n].玩家id].道具.数据[v].符石组合.等级== 3 then
                self.参战单位[n].天雷地火=self.参战单位[n].等级
              end
            elseif 玩家数据[self.参战单位[n].玩家id].道具.数据[v].符石组合.符石组合 =="烟雨飘摇" then
              if 玩家数据[self.参战单位[n].玩家id].道具.数据[v].符石组合.等级 == 1 then
                self.参战单位[n].烟雨飘摇=math.floor(self.参战单位[n].等级/2)
              elseif  玩家数据[self.参战单位[n].玩家id].道具.数据[v].符石组合.等级== 2 then
                self.参战单位[n].烟雨飘摇=math.floor(self.参战单位[n].等级/1.5)
              elseif  玩家数据[self.参战单位[n].玩家id].道具.数据[v].符石组合.等级== 3 then
                self.参战单位[n].烟雨飘摇=self.参战单位[n].等级
              end
            elseif 玩家数据[self.参战单位[n].玩家id].道具.数据[v].符石组合.符石组合 =="索命无常" then
              if 玩家数据[self.参战单位[n].玩家id].道具.数据[v].符石组合.等级 == 1 then
                self.参战单位[n].索命无常=math.floor(self.参战单位[n].等级/2)
              elseif  玩家数据[self.参战单位[n].玩家id].道具.数据[v].符石组合.等级== 2 then
                self.参战单位[n].索命无常=math.floor(self.参战单位[n].等级/1.5)
              elseif  玩家数据[self.参战单位[n].玩家id].道具.数据[v].符石组合.等级== 3 then
                self.参战单位[n].索命无常=self.参战单位[n].等级
              end
            elseif 玩家数据[self.参战单位[n].玩家id].道具.数据[v].符石组合.符石组合 =="行云流水" then
              if 玩家数据[self.参战单位[n].玩家id].道具.数据[v].符石组合.等级 == 1 then
                self.参战单位[n].行云流水=math.floor(self.参战单位[n].等级/2)
              elseif  玩家数据[self.参战单位[n].玩家id].道具.数据[v].符石组合.等级== 2 then
                self.参战单位[n].行云流水=math.floor(self.参战单位[n].等级/1.5)
              elseif  玩家数据[self.参战单位[n].玩家id].道具.数据[v].符石组合.等级== 3 then
                self.参战单位[n].行云流水=self.参战单位[n].等级
              end
            elseif 玩家数据[self.参战单位[n].玩家id].道具.数据[v].符石组合.符石组合 =="福泽天下" then
              if 玩家数据[self.参战单位[n].玩家id].道具.数据[v].符石组合.等级 == 1 then
                self.参战单位[n].福泽天下=math.floor(self.参战单位[n].等级/2)
              elseif  玩家数据[self.参战单位[n].玩家id].道具.数据[v].符石组合.等级== 2 then
                self.参战单位[n].福泽天下=math.floor(self.参战单位[n].等级/1.5)
              elseif  玩家数据[self.参战单位[n].玩家id].道具.数据[v].符石组合.等级== 3 then
                self.参战单位[n].福泽天下=self.参战单位[n].等级
              end
            elseif 玩家数据[self.参战单位[n].玩家id].道具.数据[v].符石组合.符石组合 =="暗度陈仓" then
              if self.参战单位[n].物伤减免==0 or self.参战单位[n].物伤减免==nil then
                  self.参战单位[n].物伤减免 = 0
              else
                  self.参战单位[n].物伤减免 = self.参战单位[n].物伤减免-0.03
              end
            elseif 玩家数据[self.参战单位[n].玩家id].道具.数据[v].符石组合.符石组合 =="点石成金" then
              if self.参战单位[n].物伤减免==0 or self.参战单位[n].物伤减免==nil then
                self.参战单位[n].物伤减免 = 0
              end
              self.参战单位[n].物伤减免 = self.参战单位[n].物伤减免+0.03
            elseif 玩家数据[self.参战单位[n].玩家id].道具.数据[v].符石组合.符石组合 =="化敌为友" then
              if self.参战单位[n].法伤减免==0 or self.参战单位[n].法伤减免==nil then
                self.参战单位[n].法伤减少 = 0.97
              else
                self.参战单位[n].法伤减少 = self.参战单位[n].法伤减少+0.97
              end
            end
          end
          local 临时套装={}
          if v~=nil and 玩家数据[self.参战单位[n].玩家id].道具.数据[v]~=nil and 玩家数据[self.参战单位[n].玩家id].道具.数据[v].套装效果~=nil then
             临时套装[#临时套装+1]={玩家数据[self.参战单位[n].玩家id].道具.数据[v].套装效果[1],玩家数据[self.参战单位[n].玩家id].道具.数据[v].套装效果[2]}
          end
          if #临时套装>0 then
            for i=1,#临时套装 do
              local 重复=false
              local 数量=1
              for a=1,#self.参战单位[n][临时套装[i][1]] do
                if self.参战单位[n][临时套装[i][1]][a].名称==临时套装[i][2] then
                  重复=true
                end
              end
              if 重复==false then
                for a=1,#临时套装 do
                  if a~=i then
                    if 临时套装[a][1]==临时套装[i][1] and 临时套装[a][2]==临时套装[i][2] then
                     数量=数量+1
                    end
                  end
                end
                if 数量>=3 then
                  self.参战单位[n].套装追加概率 = 0
                  local 等级=self.参战单位[n].等级
                  if 数量>=5 then
                    等级=等级+10
                    self.参战单位[n].套装追加概率 = 20
                  end
                  self.参战单位[n][临时套装[i][1]][#self.参战单位[n][临时套装[i][1]]+1]={名称=临时套装[i][2],等级=等级}
                end
              end
            end
          end
        end
        self.参战单位[n].变身数据=玩家数据[self.参战单位[n].玩家id].助战.数据[self.参战单位[n].助战编号].变身数据
        if self.参战单位[n].变身数据~=nil and 变身卡数据[self.参战单位[n].变身数据]~=nil and 变身卡数据[self.参战单位[n].变身数据].技能~="" then
          self:添加技能属性(self.参战单位[n],{变身卡数据[self.参战单位[n].变身数据].技能})
        end
        for i=1,#灵饰战斗属性 do
          self.参战单位[n][灵饰战斗属性[i]]=玩家数据[self.参战单位[n].玩家id].助战.数据[self.参战单位[n].助战编号][灵饰战斗属性[i]]
        end
        if 玩家数据[self.参战单位[n].玩家id].助战.数据[self.参战单位[n].助战编号].门派~=nil then
          if 玩家数据[self.参战单位[n].玩家id].助战.数据[self.参战单位[n].助战编号].门派=="凌波城" then
            self.参战单位[n].战意=2
          end
          for i=1,#玩家数据[self.参战单位[n].玩家id].助战.数据[self.参战单位[n].助战编号].技能 do
            local 名称=玩家数据[self.参战单位[n].玩家id].助战.数据[self.参战单位[n].助战编号].技能[i]
            if self:恢复技能(名称) or self:法攻技能(名称) or self:物攻技能(名称) or self:封印技能(名称) or self:减益技能(名称) or self:增益技能(名称) then
              self.参战单位[n].主动技能[#self.参战单位[n].主动技能+1]={名称=名称,等级=self.参战单位[n].等级+10}
            end
          end
        end
        if 玩家数据[self.参战单位[n].玩家id].助战.数据[self.参战单位[n].助战编号].门派 == nil or 玩家数据[self.参战单位[n].玩家id].助战.数据[self.参战单位[n].助战编号].门派 == "无" or  玩家数据[self.参战单位[n].玩家id].助战.数据[self.参战单位[n].助战编号].门派 == "无门派"then
          self.参战单位[n].主动技能[#self.参战单位[n].主动技能+1]={名称="牛刀小试",等级=self.参战单位[n].等级+1}
        end
      end
    end
    if self.参战单位[n].类型~="角色" and self.参战单位[n].类型~="系统角色" and self.参战单位[n].类型 == "bb" then
      self:添加技能属性(self.参战单位[n],self.参战单位[n].技能)
      if self.参战单位[n].法术认证~=nil then
        self:添加认证法术属性(self.参战单位[n],self.参战单位[n].法术认证)
      end
      if self.参战单位[n].队伍~=0 then
        self.参战单位[n].攻击修炼=玩家数据[self.参战单位[n].玩家id].角色.数据.bb修炼.攻击控制力[1]
        self.参战单位[n].法术修炼=玩家数据[self.参战单位[n].玩家id].角色.数据.bb修炼.法术控制力[1]
        self.参战单位[n].防御修炼=玩家数据[self.参战单位[n].玩家id].角色.数据.bb修炼.防御控制力[1]
        self.参战单位[n].抗法修炼=玩家数据[self.参战单位[n].玩家id].角色.数据.bb修炼.抗法控制力[1]
      end
      if self.参战单位[n].内丹 ~= nil then
          self:添加内丹属性(self.参战单位[n],self.参战单位[n].内丹)
      end
      self:添加bb法宝属性(n,self.参战单位[n].玩家id)
      if self.参战单位[n].特性 ~= nil and  self.参战单位[n].特性=="御风" then
        self:添加状态特性(n)
      end
      if self.参战单位[n].统御 ~= nil then
        local 坐骑编号 = self.参战单位[n].统御
        local 玩家id = self.参战单位[n].玩家id
        if 玩家数据[玩家id].角色.数据.坐骑列表[坐骑编号] ~= nil then
          if 玩家数据[玩家id].角色.数据.坐骑列表[坐骑编号].忠诚 <= 50 and 玩家数据[玩家id].角色.数据.坐骑列表[坐骑编号].忠诚 > 2 then
            玩家数据[玩家id].角色.数据.坐骑列表[坐骑编号].忠诚 = 玩家数据[玩家id].角色.数据.坐骑列表[坐骑编号].忠诚 - 2
            发送数据(玩家数据[玩家id].连接id,38,{内容="你的坐骑#R"..玩家数据[玩家id].角色.数据.坐骑列表[坐骑编号].名称.."#W减少了2点饱食度"})
          elseif 玩家数据[玩家id].角色.数据.坐骑列表[坐骑编号].忠诚 > 50 then
            玩家数据[玩家id].角色.数据.坐骑列表[坐骑编号].忠诚 = 玩家数据[玩家id].角色.数据.坐骑列表[坐骑编号].忠诚 - 1
            发送数据(玩家数据[玩家id].连接id,38,{内容="你的坐骑#R"..玩家数据[玩家id].角色.数据.坐骑列表[坐骑编号].名称.."#W减少了1点饱食度"})
          end
          if 玩家数据[玩家id].角色.数据.坐骑列表[坐骑编号].忠诚 <= 0 then
            玩家数据[玩家id].角色:坐骑刷新(坐骑编号)
            发送数据(玩家数据[玩家id].连接id,38,{内容="你的坐骑#R"..玩家数据[玩家id].角色.数据.坐骑列表[坐骑编号].名称.."#W已经饥饿难耐无法给予统御召唤兽加成了"})
          else
            self:添加技能属性(self.参战单位[n],玩家数据[玩家id].角色.数据.坐骑列表[坐骑编号].技能)
          end
        end
      end
    end
    if #self.参战单位[n].附加状态>0 then
      for i=1,#self.参战单位[n].附加状态 do
        self.参战单位[n].指令={}
        self.参战单位[n].指令.参数=self.参战单位[n].附加状态[i].名称
        self.参战单位[n].指令.目标=n
        self:法术计算(n)
      end
    end
    if self.参战单位[n].隐身~=nil then
      self.参战单位[n].指令={目标=n}
      self:增益技能计算(n,"修罗隐身",self.参战单位[n].等级)
      if self.参战单位[n].法术状态.修罗隐身~=nil then
        self.参战单位[n].法术状态.修罗隐身.回合=self.参战单位[n].隐身
      end
    end
    if 昼夜参数==1 and self.参战单位[n].夜战==nil and self.参战单位[n].夜战==0 and self.参战单位[n].门派~="阴曹地府" then
        self.参战单位[n].伤害=math.floor(self.参战单位[n].伤害*0.85)
        self.参战单位[n].防御=math.floor(self.参战单位[n].防御*0.85)
        self.参战单位[n].法防=math.floor(self.参战单位[n].法防*0.85)
    end
    if 昼夜参数==1 then
      if 编号~=nil and self:取奇经八脉是否有(n,"夜行") then
        self.参战单位[n].伤害=self.参战单位[n].伤害+40
        self.参战单位[n].速度=self.参战单位[n].速度+40
        self.参战单位[n].固定伤害=self.参战单位[n].固定伤害+50
      end
      if 编号~=nil and self:取奇经八脉是否有(n,"夜之王者") then
        self.参战单位[n].必杀=self.参战单位[n].必杀+10
        self.参战单位[n].固定伤害=math.floor(self.参战单位[n].固定伤害+self.参战单位[n]*0.6)
      end
    end
  end
end

function 战斗处理类:取飞升技能(技能)
  local n = {"破釜沉舟","安神诀","分身术","碎甲符","舍生取义","舍身取义","佛法无边","一笑倾城","飞花摘叶","还阳术","黄泉之息","火甲术","摇头摆尾","天魔解体","魔息术","幻镜术","瘴气","雷霆万钧","金刚镯"
,"天地同寿","乾坤妙法","二龙戏珠","神龙摆尾","灵动九天","颠倒五行","蜜润","血雨","镇魂诀","腾雷","金身舍利","摧心术"}
  for i=1,#n do
      if n[i] == 技能 then
        return true
      end
  end
  return false
end

function 战斗处理类:取加载信息(id)
  local 显示饰品2 = false
  if self.战斗类型==100032 or self.战斗类型==100033 and 任务数据[self.任务id]~=nil and 任务数据[self.任务id].显示饰品~=nil and 任务数据[self.任务id].显示饰品 then
    显示饰品2 = true
  end
  local 临时数据={
    气血=self.参战单位[id].气血,
    最大气血=self.参战单位[id].最大气血,
    魔法=self.参战单位[id].魔法,
    最大魔法=self.参战单位[id].最大魔法,
    愤怒=self.参战单位[id].愤怒,
    名称=self.参战单位[id].名称,
    模型=self.参战单位[id].模型,
    队伍=self.参战单位[id].队伍,
    位置=self.参战单位[id].位置,
    染色方案=self.参战单位[id].染色方案,
    染色组=self.参战单位[id].染色组,
    武器染色方案=self.参战单位[id].武器染色方案,
    武器染色组=self.参战单位[id].武器染色组,
    武器=self.参战单位[id].武器,
    变异=self.参战单位[id].变异,
    变身=self.参战单位[id].变身造型,
    类型=self.参战单位[id].类型,
    附加阵法=self.参战单位[id].附加阵法,
    主动技能=self.参战单位[id].主动技能,
    特技技能=self.参战单位[id].特技技能,
    战意=self.参战单位[id].战意,
    自动指令=self.参战单位[id].自动指令,
    自动战斗=self.参战单位[id].自动战斗,
    id=self.参战单位[id].玩家id,
    变身数据=self.参战单位[id].变身数据,
    显示饰品=显示饰品2,
    锦衣数据=self.参战单位[id].锦衣,
    战斗类型 = self.战斗类型,
    助战编号 = self.参战单位[id].助战编号,
  }
  if self.参战单位[id].类型=="角色" then
    local 玩家id=self.参战单位[id].玩家id
    if self.参战单位[id].队伍~=0 and self.参战单位[id].助战编号 == nil then
      if self.参战单位[id].装备[3]~=nil and 玩家数据[玩家id] ~= nil and  玩家数据[玩家id].角色 ~= nil and 玩家数据[玩家id].角色.数据.装备 ~= nil and 玩家数据[玩家id].角色.数据.装备[3] ~= nil then
        local 装备id=玩家数据[玩家id].角色.数据.装备[3]
        临时数据.武器={名称=玩家数据[玩家id].道具.数据[装备id].名称,子类=玩家数据[玩家id].道具.数据[装备id].子类,级别限制=玩家数据[玩家id].道具.数据[装备id].级别限制,染色方案=玩家数据[玩家id].道具.数据[装备id].染色方案,染色组=玩家数据[玩家id].道具.数据[装备id].染色组}
      end
    elseif self.参战单位[id].队伍~=0 and self.参战单位[id].助战编号 ~= nil then
      if self.参战单位[id].装备[3]~=nil then
        临时数据.武器={名称=self.参战单位[id].装备[3].名称,子类=self.参战单位[id].装备[3].子类,级别限制=self.参战单位[id].装备[3].级别限制,染色方案=self.参战单位[id].装备[3].染色方案,染色组=self.参战单位[id].装备[3].染色组}
      end
    end
  elseif self.参战单位[id].类型=="系统角色" then
    临时数据.武器=self.参战单位[id].武器
  end
  return 临时数据
end

function 战斗处理类:增加阵法属性(编号,名称,位置,阵法加成)
  local 临时队伍id = self.参战单位[编号].队伍
  if 队伍数据[临时队伍id]~=nil and #队伍数据[临时队伍id].成员数据==5 then
    local x阵法加成 = 1
    if 阵法加成~=nil then
      x阵法加成=1+阵法加成
    end
    if 名称=="天覆阵" then
      self.参战单位[编号].速度=qz(self.参战单位[编号].速度*0.9*x阵法加成)
      self.参战单位[编号].伤害=qz(self.参战单位[编号].伤害*1.2*x阵法加成)
      self.参战单位[编号].灵力=qz(self.参战单位[编号].灵力*1.2*x阵法加成)
    elseif 名称=="风扬阵" then
      if 位置==1 then
        self.参战单位[编号].伤害=qz(self.参战单位[编号].伤害*1.2*x阵法加成)
        self.参战单位[编号].灵力=qz(self.参战单位[编号].灵力*1.2*x阵法加成)
        self.参战单位[编号].速度=qz(self.参战单位[编号].速度*1.05*x阵法加成)
      elseif 位置==2 or 位置==3 then
        self.参战单位[编号].伤害=qz(self.参战单位[编号].伤害*1.1*x阵法加成)
        self.参战单位[编号].灵力=qz(self.参战单位[编号].灵力*1.1*x阵法加成)
      else
       self.参战单位[编号].速度=qz(self.参战单位[编号].速度*1.1*x阵法加成)
      end
    elseif 名称=="虎翼阵" then
      if 位置==1 then
        self.参战单位[编号].伤害=qz(self.参战单位[编号].伤害*1.25*x阵法加成)
        self.参战单位[编号].灵力=qz(self.参战单位[编号].灵力*1.25*x阵法加成)
      elseif 位置==2 or 位置==3 then
        self.参战单位[编号].防御=qz(self.参战单位[编号].防御*1.2*x阵法加成)
        self.参战单位[编号].法防=qz(self.参战单位[编号].法防*1.2*x阵法加成)
      else
       self.参战单位[编号].伤害=qz(self.参战单位[编号].伤害*1.2*x阵法加成)
      end
    elseif 名称=="云垂阵" then
     if 位置==1 then
        self.参战单位[编号].防御=qz(self.参战单位[编号].防御*1.25*x阵法加成)
        self.参战单位[编号].法防=qz(self.参战单位[编号].法防*1.25*x阵法加成)
        self.参战单位[编号].速度=qz(self.参战单位[编号].速度*0.85*x阵法加成)
      elseif 位置==2 then
        self.参战单位[编号].防御=qz(self.参战单位[编号].防御*1.1*x阵法加成)
      elseif 位置==3 then
        self.参战单位[编号].伤害=qz(self.参战单位[编号].伤害*1.2*x阵法加成)
        self.参战单位[编号].灵力=qz(self.参战单位[编号].灵力*1.2*x阵法加成)
     else
       self.参战单位[编号].速度=qz(self.参战单位[编号].速度*1.1*x阵法加成)
       end
    elseif 名称=="鸟翔阵" then
     if 位置==1 then
        self.参战单位[编号].速度=qz(self.参战单位[编号].速度*1.2*x阵法加成)
      elseif 位置==2 or 位置==3 then
        self.参战单位[编号].速度=qz(self.参战单位[编号].速度*1.1*x阵法加成)
     else
       self.参战单位[编号].速度=qz(self.参战单位[编号].速度*1.15*x阵法加成)
       end
    elseif 名称=="地载阵" then
     if 位置==1 or 位置==3 or 位置==4 then
        self.参战单位[编号].防御=qz(self.参战单位[编号].防御*1.15*x阵法加成)
        self.参战单位[编号].法防=qz(self.参战单位[编号].法防*1.15*x阵法加成)
      elseif 位置==2 then
        self.参战单位[编号].伤害=qz(self.参战单位[编号].伤害*1.15*x阵法加成)
        self.参战单位[编号].灵力=qz(self.参战单位[编号].灵力*1.15*x阵法加成)
     else
       self.参战单位[编号].速度=qz(self.参战单位[编号].速度*1.1*x阵法加成)
       end
    elseif 名称=="龙飞阵" then
     if 位置==1 then
        self.参战单位[编号].法防=qz(self.参战单位[编号].法防*1.2*x阵法加成)
      elseif 位置==2 then
        self.参战单位[编号].法防=qz(self.参战单位[编号].法防*1.2*x阵法加成)
      elseif 位置==3 then
         self.参战单位[编号].法防=qz(self.参战单位[编号].法防*1.2*x阵法加成)
       elseif 位置==4 then
         self.参战单位[编号].伤害=qz(self.参战单位[编号].伤害*1.1*x阵法加成)
       self.参战单位[编号].灵力=qz(self.参战单位[编号].灵力*1.1*x阵法加成)
     else
       self.参战单位[编号].伤害=qz(self.参战单位[编号].伤害*1.1*x阵法加成)
       self.参战单位[编号].灵力=qz(self.参战单位[编号].灵力*1.1*x阵法加成)
       end
    elseif 名称=="鹰啸阵" then
      if 位置==1 then
        self.参战单位[编号].防御=qz(self.参战单位[编号].防御*1.1*x阵法加成)
      elseif 位置==2 then
        self.参战单位[编号].速度=qz(self.参战单位[编号].速度*1.15*x阵法加成)
      elseif 位置==3 then
        self.参战单位[编号].速度=qz(self.参战单位[编号].速度*1.15*x阵法加成)
      elseif 位置==4 then
        self.参战单位[编号].伤害=qz(self.参战单位[编号].伤害*1.15*x阵法加成)
        self.参战单位[编号].灵力=qz(self.参战单位[编号].灵力*1.15*x阵法加成)
      else
        self.参战单位[编号].伤害=qz(self.参战单位[编号].伤害*1.1*x阵法加成)
        self.参战单位[编号].灵力=qz(self.参战单位[编号].灵力*1.1*x阵法加成)
      end
    elseif 名称=="雷绝阵" then
      if 位置==1 then
        self.参战单位[编号].固伤加成=1.2
        self.参战单位[编号].bb伤害加成=1.1
        self.参战单位[编号].bb灵力加成=1.1
      elseif 位置==2 then
        self.参战单位[编号].固伤加成=1.2
        self.参战单位[编号].bb伤害加成=1.1
        self.参战单位[编号].bb灵力加成=1.1
      elseif 位置==3 then
        self.参战单位[编号].固伤加成=1.2
        self.参战单位[编号].bb伤害加成=1.1
        self.参战单位[编号].bb灵力加成=1.1
      elseif 位置==4 then
        self.参战单位[编号].固伤加成=1.1
        self.参战单位[编号].bb伤害加成=1.1
        self.参战单位[编号].bb灵力加成=1.1
      else
        self.参战单位[编号].固伤加成=1.1
        self.参战单位[编号].bb伤害加成=1.1
        self.参战单位[编号].bb灵力加成=1.1
      end
    end
  end
end

function 战斗处理类:加载单个玩家(id,位置)
  self.参战单位[#self.参战单位+1]={}
  self.参战单位[#self.参战单位]=table.loadstring(table.tostring(玩家数据[id].角色:取总数据()))
  local 队伍id=玩家数据[id].队伍
  self.参战单位[#self.参战单位].附加阵法="普通"
  if 队伍数据[队伍id]~=nil and #队伍数据[队伍id].成员数据==5 then
    self.参战单位[#self.参战单位].附加阵法=队伍数据[队伍id].阵型
  end
  if 队伍id==0 then
      队伍id=id
  else
      self.参战单位[#self.参战单位].附加阵法=队伍数据[队伍id].阵型
  end
  self.参战玩家[#self.参战玩家].队伍=队伍id
  self.参战单位[#self.参战单位].队伍=队伍id
  self.参战单位[#self.参战单位].位置=位置
  self.参战单位[#self.参战单位].类型="角色"
  self.参战单位[#self.参战单位].玩家id=id
  self.参战单位[#self.参战单位].召唤兽=nil
  self.参战单位[#self.参战单位].法防=qz(self.参战单位[#self.参战单位].魔力*0.4+self.参战单位[#self.参战单位].等级)
  self.参战单位[#self.参战单位].躲闪=0
  self.参战单位[#self.参战单位].已加技能={}
  self.参战单位[#self.参战单位].主动技能={}
  self.参战单位[#self.参战单位].召唤数量={}
  if 玩家数据[id].角色.数据.自动战斗 then
    self.参战单位[#self.参战单位].自动战斗=true
  end
  self:设置队伍区分(队伍id)
  if 玩家数据[id].角色.数据.奇经八脉.开启奇经八脉~=nil and 玩家数据[id].角色.数据.奇经八脉.开启奇经八脉 then
      self.参战单位[#self.参战单位].经脉有无=玩家数据[id].角色.数据.奇经八脉.开启奇经八脉
  end
  if self.参战单位[#self.参战单位].附加阵法~="普通" then
    if 玩家数据[id].队伍~=nil and self:直接取角色取奇经八脉是否有(玩家数据[id].队伍,"扶阵") then
      self:增加阵法属性(#self.参战单位,self.参战单位[#self.参战单位].附加阵法,位置,0.03)
    else
      self:增加阵法属性(#self.参战单位,self.参战单位[#self.参战单位].附加阵法,位置)
    end
  end
  if self.参战单位[#self.参战单位].参战信息~=nil and 玩家数据[id].召唤兽.数据[玩家数据[id].召唤兽:取编号(玩家数据[id].角色.数据.参战宝宝.认证码)]~=nil then
    --计算召唤兽参战条件
    local 临时bb=玩家数据[id].召唤兽.数据[玩家数据[id].召唤兽:取编号(玩家数据[id].角色.数据.参战宝宝.认证码)]
    if 临时bb~=nil and 临时bb.忠诚<=80 and 取随机数()>=50 then
      常规提示(id,"你的召唤兽由于忠诚过低，不愿意参战")
      return
    end
    if 临时bb~=nil and 临时bb.种类~="神兽" and 临时bb.寿命<=50 then
      常规提示(id,"你的召唤兽由于寿命过低，不愿意参战")
      return
    end
    if 临时bb~=nil and 临时bb.种类~="神兽" then
        玩家数据[id].召唤兽.数据[玩家数据[id].召唤兽:取编号(玩家数据[id].角色.数据.参战宝宝.认证码)].寿命=玩家数据[id].召唤兽.数据[玩家数据[id].召唤兽:取编号(玩家数据[id].角色.数据.参战宝宝.认证码)].寿命-1
    end
    self.参战单位[#self.参战单位+1]={}
    self.参战单位[#self.参战单位]=table.loadstring(玩家数据[id].召唤兽:获取指定数据(玩家数据[id].召唤兽:取编号(玩家数据[id].角色.数据.参战宝宝.认证码)))
    self.参战单位[#self.参战单位].队伍=队伍id
    self.参战单位[#self.参战单位].位置=位置+5
    self.参战单位[#self.参战单位].主人=#self.参战单位-1
    self.参战单位[#self.参战单位].类型="bb"
    self.参战单位[#self.参战单位].玩家id=id
    self.参战单位[#self.参战单位].附加阵法=self.参战单位[#self.参战单位-1].附加阵法
    self.参战单位[#self.参战单位].法防=qz(self.参战单位[#self.参战单位].魔力*0.4+self.参战单位[#self.参战单位].等级)
    self.参战单位[#self.参战单位].命中=self.参战单位[#self.参战单位].伤害
    self.参战单位[#self.参战单位].躲闪=0
    self.参战单位[#self.参战单位].法暴=0
    self.参战单位[#self.参战单位].夜战=0
    self.参战单位[#self.参战单位-1].召唤兽=#self.参战单位
    self.参战单位[#self.参战单位].自动战斗=self.参战单位[#self.参战单位-1].自动战斗
    self.参战单位[#self.参战单位].已加技能={}
    self.参战单位[#self.参战单位].主动技能={}
    self.参战单位[#self.参战单位-1].召唤数量[1]=玩家数据[id].召唤兽:取编号(玩家数据[id].角色.数据.参战宝宝.认证码)

    --套装效果
    local 触发=true
    local 套装技能=""
    if self.参战单位[#self.参战单位].装备[1]~=nil and self.参战单位[#self.参战单位].装备[1].套装效果~=nil then
      套装技能=self.参战单位[#self.参战单位].装备[1].套装效果[2]
      for q=2,3 do
        if self.参战单位[#self.参战单位].装备[q]==nil or self.参战单位[#self.参战单位].装备[q].套装效果==nil or self.参战单位[#self.参战单位].装备[q].套装效果[2]~=套装技能 then
          触发=false
        end
      end
      for i=1,#self.参战单位[#self.参战单位].技能 do
        if self.参战单位[#self.参战单位].技能[i]==套装技能 then
          触发=false
        end
      end
    end
    if 触发 then
      self.参战单位[#self.参战单位].技能[#self.参战单位[#self.参战单位].技能+1]=套装技能
    end

    if self.参战单位[#self.参战单位-1].bb伤害加成~=nil then
      self.参战单位[#self.参战单位].伤害=qz(self.参战单位[#self.参战单位].伤害*self.参战单位[#self.参战单位-1].bb伤害加成)
    end
    if self.参战单位[#self.参战单位-1].bb灵力加成~=nil then
      self.参战单位[#self.参战单位].灵力=qz(self.参战单位[#self.参战单位].灵力*self.参战单位[#self.参战单位-1].bb灵力加成)
    end
    if self.参战单位[#self.参战单位].内丹 ~= nil then
        self:添加内丹属性(self.参战单位[#self.参战单位],self.参战单位[#self.参战单位].内丹)
    end
    if 编号~=nil and self:取奇经八脉是否有(#self.参战单位-1,"御兽") and self.参战单位[#self.参战单位].速度>=self.参战单位[#self.参战单位].等级*3 then
        self.参战单位[#self.参战单位-1].速度=self.参战单位[#self.参战单位-1].速度+qz(self.参战单位[#self.参战单位].等级*1.6)
    end
    if 编号~=nil and self:取奇经八脉是否有(#self.参战单位-1,"国色") then
        self.参战单位[#self.参战单位].速度=self.参战单位[#self.参战单位].速度*1.12
    end
    if 编号~=nil and self:取奇经八脉是否有(#self.参战单位-1,"驭兽") then
        self.参战单位[#self.参战单位].伤害 =self.参战单位[#self.参战单位].伤害*1.12
        self.参战单位[#self.参战单位].防御 =self.参战单位[#self.参战单位].防御*1.12
        self.参战单位[#self.参战单位].灵力 =self.参战单位[#self.参战单位].灵力*1.12
    end
    if 编号~=nil and self:取奇经八脉是否有(#self.参战单位-1,"肝胆") then
        self.参战单位[#self.参战单位].伤害 =self.参战单位[#self.参战单位].伤害+self.参战单位[#self.参战单位-1].伤害*0.1
        self.参战单位[#self.参战单位].防御 =self.参战单位[#self.参战单位].伤害+self.参战单位[#self.参战单位-1].防御*0.1
        self.参战单位[#self.参战单位].灵力 =self.参战单位[#self.参战单位].伤害+self.参战单位[#self.参战单位-1].灵力*0.1
        self.参战单位[#self.参战单位-1].伤害 =self.参战单位[#self.参战单位-1].伤害+self.参战单位[#self.参战单位].伤害*0.1
        self.参战单位[#self.参战单位-1].防御 =self.参战单位[#self.参战单位-1].防御+self.参战单位[#self.参战单位].防御*0.1
        self.参战单位[#self.参战单位-1].灵力 =self.参战单位[#self.参战单位-1].灵力+self.参战单位[#self.参战单位].灵力*0.1
    end
    local 临时技能={}
    self:设置队伍区分(队伍id)
  end
  self:添加召唤兽特性(#self.参战单位)
  if 玩家数据[id].队伍 ~= 0 and 玩家数据[id].队长 then
    local 父编号 = self:取参战编号(id,"角色")
    for i=1,#队伍数据[玩家数据[id].队伍].成员数据 do
      if 队伍处理类:取是否助战(玩家数据[id].队伍,i) ~= 0 then
        local 助战编号 = 队伍处理类:取助战编号(玩家数据[id].队伍,i)
        if self.参战单位[父编号].助战明细 == nil then
          self.参战单位[父编号].助战明细={}
        end
        self.参战单位[父编号].助战明细[#self.参战单位[父编号].助战明细+1] = #self.参战单位+1
        self.参战单位[#self.参战单位+1]={}
        self.参战单位[#self.参战单位]=table.loadstring(table.tostring(玩家数据[id].助战:取总数据(助战编号)))
        self.参战单位[#self.参战单位].附加阵法="普通"
        if #队伍数据[玩家数据[id].队伍].成员数据==5 then
          self.参战单位[#self.参战单位].附加阵法=队伍数据[玩家数据[id].队伍].阵型
        end
        self.参战单位[#self.参战单位].队伍=队伍id
        self.参战单位[#self.参战单位].位置=i
        self.参战单位[#self.参战单位].类型="角色"
        self.参战单位[#self.参战单位].玩家id=id
        self.参战单位[#self.参战单位].助战编号=助战编号
        self.参战单位[#self.参战单位].召唤兽=nil
        self.参战单位[#self.参战单位].主人 = 父编号
        self.参战单位[#self.参战单位].法防=qz(self.参战单位[#self.参战单位].魔力*0.4+self.参战单位[#self.参战单位].等级)
        self.参战单位[#self.参战单位].躲闪=0
        self.参战单位[#self.参战单位].已加技能={}
        self.参战单位[#self.参战单位].主动技能={}
        self.参战单位[#self.参战单位].自动战斗=self.参战单位[父编号].自动战斗
        self:设置队伍区分(队伍id)
        if self.参战单位[#self.参战单位].附加阵法~="普通" then
          if 玩家数据[id].队伍~=nil and self:直接取角色取奇经八脉是否有(玩家数据[id].队伍,"扶阵") then
            self:增加阵法属性(#self.参战单位,self.参战单位[#self.参战单位].附加阵法,i,0.03)
          else
            self:增加阵法属性(#self.参战单位,self.参战单位[#self.参战单位].附加阵法,i)
          end
        end
        if self.参战单位[父编号].参战信息~=nil and 玩家数据[id].召唤兽.数据[玩家数据[id].召唤兽:取编号(玩家数据[id].角色.数据.参战宝宝.认证码)]~=nil then
          local 临时bb=玩家数据[id].召唤兽.数据[玩家数据[id].召唤兽:取编号(玩家数据[id].角色.数据.参战宝宝.认证码)]
          if 临时bb~=nil and 临时bb.忠诚<=80 and 取随机数()>=50 then
            常规提示(id,"你的召唤兽由于忠诚过低，不愿意参战")
            return
          end
          if 临时bb~=nil and 临时bb.种类~="神兽" and 临时bb.寿命<=50 then
            常规提示(id,"你的召唤兽由于寿命过低，不愿意参战")
            return
          end
          if 临时bb~=nil and 临时bb.种类~="神兽" then
              玩家数据[id].召唤兽.数据[玩家数据[id].召唤兽:取编号(玩家数据[id].角色.数据.参战宝宝.认证码)].寿命=玩家数据[id].召唤兽.数据[玩家数据[id].召唤兽:取编号(玩家数据[id].角色.数据.参战宝宝.认证码)].寿命-1
          end
          self.参战单位[#self.参战单位+1]={}
          self.参战单位[#self.参战单位]=table.loadstring(玩家数据[id].召唤兽:获取指定数据(玩家数据[id].召唤兽:取编号(玩家数据[id].角色.数据.参战宝宝.认证码)))
          self.参战单位[#self.参战单位].队伍=队伍id
          self.参战单位[#self.参战单位].位置=i+5
          self.参战单位[#self.参战单位].主人=父编号
          self.参战单位[#self.参战单位].类型="bb"
          self.参战单位[#self.参战单位].助战宝宝=#self.参战单位
          self.参战单位[#self.参战单位].玩家id=id
          self.参战单位[#self.参战单位].附加阵法=self.参战单位[父编号].附加阵法
          self.参战单位[#self.参战单位].法防=qz(self.参战单位[#self.参战单位].魔力*0.4+self.参战单位[#self.参战单位].等级)
          self.参战单位[#self.参战单位].命中=self.参战单位[#self.参战单位].伤害
          self.参战单位[#self.参战单位].躲闪=0
          self.参战单位[#self.参战单位].法暴=0
          self.参战单位[#self.参战单位].夜战=0
          self.参战单位[#self.参战单位-1].召唤兽=#self.参战单位
          self.参战单位[#self.参战单位].自动战斗=self.参战单位[父编号].自动战斗
          self.参战单位[#self.参战单位].已加技能={}
          self.参战单位[#self.参战单位].主动技能={}
          local 随机模型={"超级神狗","贪狼","进阶谛听","超级神鼠","超级神猪","超级小白龙","超级猪小戒","进阶狐不归","进阶花灵","进阶涂山雪","进阶月魅","进阶月影仙","进阶云游火","超级白泽兽","日游神","蚩尤童子","赤胆忠魂","雪精灵","大浪淘沙"}
          local 随机造型=随机模型[取随机数(1,#随机模型)]
          self.参战单位[#self.参战单位].模型=随机造型
          self.参战单位[#self.参战单位].名称=随机造型
          --套装效果
          local 触发=true
          local 套装技能=""
          if self.参战单位[#self.参战单位].装备[1]~=nil and self.参战单位[#self.参战单位].装备[1].套装效果~=nil then
            套装技能=self.参战单位[#self.参战单位].装备[1].套装效果[2]
            for q=2,3 do
              if self.参战单位[#self.参战单位].装备[q]==nil or self.参战单位[#self.参战单位].装备[q].套装效果==nil or self.参战单位[#self.参战单位].装备[q].套装效果[2]~=套装技能 then
                触发=false
              end
            end
            for i=1,#self.参战单位[#self.参战单位].技能 do
              if self.参战单位[#self.参战单位].技能[i]==套装技能 then
                触发=false
              end
            end
          end
          if 触发 then
            self.参战单位[#self.参战单位].技能[#self.参战单位[#self.参战单位].技能+1]=套装技能
          end
          if self.参战单位[父编号].bb伤害加成~=nil then
            self.参战单位[#self.参战单位].伤害=qz(self.参战单位[#self.参战单位].伤害*self.参战单位[父编号].bb伤害加成)
          end
          if self.参战单位[父编号].bb灵力加成~=nil then
            self.参战单位[#self.参战单位].灵力=qz(self.参战单位[#self.参战单位].灵力*self.参战单位[父编号].bb灵力加成)
          end
          if self.参战单位[#self.参战单位].内丹 ~= nil then
              self:添加内丹属性(self.参战单位[#self.参战单位],self.参战单位[#self.参战单位].内丹)
          end
          if 编号~=nil and self:取奇经八脉是否有(父编号,"御兽") and self.参战单位[#self.参战单位].速度>=self.参战单位[#self.参战单位].等级*3 then
              self.参战单位[父编号].速度=self.参战单位[父编号].速度+qz(self.参战单位[#self.参战单位].等级*1.6)
          end
          if 编号~=nil and self:取奇经八脉是否有(父编号,"国色") then
              self.参战单位[#self.参战单位].速度=self.参战单位[#self.参战单位].速度*1.12
          end
          if 编号~=nil and self:取奇经八脉是否有(父编号,"驭兽") then
              self.参战单位[#self.参战单位].伤害 =self.参战单位[#self.参战单位].伤害*1.12
              self.参战单位[#self.参战单位].防御 =self.参战单位[#self.参战单位].防御*1.12
              self.参战单位[#self.参战单位].灵力 =self.参战单位[#self.参战单位].灵力*1.12
          end
          if 编号~=nil and self:取奇经八脉是否有(父编号,"肝胆") then
              self.参战单位[#self.参战单位].伤害 =self.参战单位[#self.参战单位].伤害+self.参战单位[父编号].伤害*0.1
              self.参战单位[#self.参战单位].防御 =self.参战单位[#self.参战单位].伤害+self.参战单位[父编号].防御*0.1
              self.参战单位[#self.参战单位].灵力 =self.参战单位[#self.参战单位].伤害+self.参战单位[父编号].灵力*0.1
              self.参战单位[父编号].伤害 =self.参战单位[父编号].伤害+self.参战单位[#self.参战单位].伤害*0.1
              self.参战单位[父编号].防御 =self.参战单位[父编号].防御+self.参战单位[#self.参战单位].防御*0.1
              self.参战单位[父编号].灵力 =self.参战单位[父编号].灵力+self.参战单位[#self.参战单位].灵力*0.1
          end
          local 临时技能={}
          self:设置队伍区分(队伍id)
        end
        self:添加召唤兽特性(#self.参战单位)
      end
    end
  end
  if self.战斗类型==100017 then
    self.参战单位[#self.参战单位+1]={}
    self.参战单位[#self.参战单位].名称="苦战中的同门"
    self.参战单位[#self.参战单位].模型=任务数据[self.任务id].模型
    self.参战单位[#self.参战单位].等级=100
    self.参战单位[#self.参战单位].变异=false
    self.参战单位[#self.参战单位].队伍=队伍id
    self.参战单位[#self.参战单位].位置=3
    self.参战单位[#self.参战单位].类型="系统角色"
    self.参战单位[#self.参战单位].法防=0
    self.参战单位[#self.参战单位].武器=nil
    self.参战单位[#self.参战单位].玩家id=0
    self.参战单位[#self.参战单位].分类="野怪"
    self.参战单位[#self.参战单位].附加阵法="普通"
    self.参战单位[#self.参战单位].伤害=1
    self.参战单位[#self.参战单位].命中=1
    self.参战单位[#self.参战单位].防御=1
    self.参战单位[#self.参战单位].速度=1
    self.参战单位[#self.参战单位].灵力=1
    self.参战单位[#self.参战单位].躲闪=1
    self.参战单位[#self.参战单位].气血=1500
    self.参战单位[#self.参战单位].最大气血=1500
    self.参战单位[#self.参战单位].魔法=1
    self.参战单位[#self.参战单位].最大魔法=1
    self.参战单位[#self.参战单位].躲闪=1
    self.参战单位[#self.参战单位].技能={}
    self.参战单位[#self.参战单位].同门单位=true
    self.参战单位[#self.参战单位].系统队友=true
    self.参战单位[#self.参战单位].主动技能={}
    self:设置队伍区分(队伍id)
  end
end
function 战斗处理类:添加召唤兽特性(编号)
  if self.参战单位[编号].特性~=nil then
    local 特性=self.参战单位[编号].特性
    local 几率=self.参战单位[编号].特性几率
    if 特性=="预知" then --OOOOOOOK
      self.参战单位[编号].预知特性=几率
      self.参战单位[编号].预知次数=0
      self.参战单位[编号].伤害=qz(self.参战单位[编号].伤害*0.95)
      self.参战单位[编号].防御=qz(self.参战单位[编号].防御*0.95)
      self.参战单位[编号].灵力=qz(self.参战单位[编号].灵力*0.95)
      self.参战单位[编号].速度=qz(self.参战单位[编号].速度*0.95)
      self.参战单位[编号].法防=qz(self.参战单位[编号].法防*0.95)
    elseif 特性=="灵动" then --OOOOOOOK
      self.参战单位[编号].灵动特性=几率
      self.参战单位[编号].灵动次数=0
      self.参战单位[编号].伤害=qz(self.参战单位[编号].伤害*0.95)
      self.参战单位[编号].防御=qz(self.参战单位[编号].防御*0.95)
      self.参战单位[编号].灵力=qz(self.参战单位[编号].灵力*0.95)
      self.参战单位[编号].速度=qz(self.参战单位[编号].速度*0.95)
      self.参战单位[编号].法防=qz(self.参战单位[编号].法防*0.95)
    elseif 特性=="识物" then
      self.参战单位[编号].识物特性=几率
      self.参战单位[编号].伤害=qz(self.参战单位[编号].伤害*0.95)
      self.参战单位[编号].防御=qz(self.参战单位[编号].防御*0.95)
      self.参战单位[编号].灵力=qz(self.参战单位[编号].灵力*0.95)
      self.参战单位[编号].速度=qz(self.参战单位[编号].速度*0.95)
      self.参战单位[编号].法防=qz(self.参战单位[编号].法防*0.95)
    elseif 特性=="抗法" then --OOOOOOOK
      self.参战单位[编号].抗法特性=几率
    elseif 特性=="抗物" then --OOOOOOOK
      self.参战单位[编号].抗物特性=几率
    elseif 特性=="洞察" then --OOOOOOOK
      self.参战单位[编号].洞察特性=几率
      self.参战单位[编号].伤害=qz(self.参战单位[编号].伤害*0.95)
      self.参战单位[编号].防御=qz(self.参战单位[编号].防御*0.95)
      self.参战单位[编号].灵力=qz(self.参战单位[编号].灵力*0.95)
      self.参战单位[编号].速度=qz(self.参战单位[编号].速度*0.95)
      self.参战单位[编号].法防=qz(self.参战单位[编号].法防*0.95)
    elseif 特性=="弑神" then --OOOOOOOK
      self.参战单位[编号].弑神特性=几率
    elseif 特性=="顺势" then --OOOOOOOK
      self.参战单位[编号].顺势特性=几率
    elseif 特性=="复仇" then --OOOOOOOK
      self.参战单位[编号].复仇特性=几率
      self.参战单位[编号].复仇次数=0
    elseif 特性=="自恋" then --OOOOOOOK
      self.参战单位[编号].自恋特性=几率
    elseif 特性=="暗劲" then
      self.参战单位[编号].暗劲特性=几率
    elseif 特性=="识药" then --OOOOOOOK
      self.参战单位[编号].识药特性=几率
    elseif 特性=="吮魔" then
      self.参战单位[编号].吮魔特性=几率
    elseif 特性=="争锋" then --OOOOOOOK
      self.参战单位[编号].争锋特性=几率
    elseif 特性=="力破" then --OOOOOOOK
      self.参战单位[编号].力破特性=几率
    elseif 特性=="巧劲" then
      self.参战单位[编号].巧劲特性=几率
    end
  end
end

function 战斗处理类:添加状态特性(编号)
  local 特性=self.参战单位[编号].特性
  local 几率=self.参战单位[编号].特性几率
  if 特性=="御风" then --OOOOOOOK
    self:添加状态(特性,self.参战单位[self.参战单位[编号].主人],self.参战单位[编号],0,编号)
  elseif 特性=="灵刃" then
    local 触发=0
    if 几率==1 then
      触发=33
    elseif 几率==2 then
      触发=50
    elseif 几率==3 then
      触发=66
    elseif 几率==4 then
      触发=83
    elseif 几率==5 then
      触发=100
    end
    if 触发>=取随机数() then
      local 气血=qz(self.参战单位[编号].气血*0.3)
      self.战斗流程[#self.战斗流程+1]={流程=102,攻击方=编号,气血=0,挨打方={},击退=1}
      self.战斗流程[#self.战斗流程].死亡=self:减少气血(编号,气血)
      self.战斗流程[#self.战斗流程].气血=气血
      self:添加状态("灵刃",self.参战单位[编号],self.参战单位[编号],0,编号)
    end
  elseif 特性=="灵法" then
    self:添加状态("灵法",self.参战单位[编号],self.参战单位[编号],几率,编号)
    self:添加状态("灵法1",self.参战单位[编号],self.参战单位[编号],几率,编号)
  elseif 特性=="阳护" then
    local 触发=0
    if 几率==1 then
      触发=33
    elseif 几率==2 then
      触发=50
    elseif 几率==3 then
      触发=66
    elseif 几率==4 then
      触发=83
    elseif 几率==5 then
      触发=100
    end
    if 触发>=取随机数() then
      for i=1,#self.参战单位 do
        if i ~= 编号 and  self.参战单位[i]~= nil and self.参战单位[i].队伍 == self.参战单位[编号].队伍 and self.参战单位[编号].法术状态.死亡召唤 then
          self.参战单位[编号].法术状态.死亡召唤.回合 = self.参战单位[编号].法术状态.死亡召唤.回合 - 2
          if self.参战单位[编号].法术状态.死亡召唤.回合 <= 0 then
            self.参战单位[编号].法术状态.死亡召唤.回合 = 1
          end
        end
      end
    end
  elseif 特性=="护佑" then
    if 取随机数(1,10) <几率 then
      self:添加状态(特性,self.参战单位[self:取我方气血最低(编号)],self.参战单位[编号],几率,编号)
    end
  elseif 特性=="怒吼" then
    if 取随机数(1,10) <几率 then
      self.参战单位[编号].防御=qz(self.参战单位[编号].防御*0.9)
      self:添加状态(特性,self.参战单位[self:取我方伤害最高(编号)],self.参战单位[编号],0,编号)
      self:添加状态("怒吼1",self.参战单位[self:取我方伤害最高(编号)],self.参战单位[编号],0,编号)
    end
  elseif 特性=="灵断" then
    local 触发=0
    if 几率==1 then
      触发=33
    elseif 几率==2 then
      触发=50
    elseif 几率==3 then
      触发=66
    elseif 几率==4 then
      触发=83
    elseif 几率==5 then
      触发=100
    end
    if 触发>=取随机数() then
      local 气血=qz(self.参战单位[编号].气血*0.3)
      self.战斗流程[#self.战斗流程+1]={流程=102,攻击方=编号,气血=0,挨打方={},击退=1}
      self.战斗流程[#self.战斗流程].死亡=self:减少气血(编号,气血)
      self.战斗流程[#self.战斗流程].气血=气血
      self:添加状态("灵断",self.参战单位[编号],self.参战单位[编号],0,编号)
    end
  elseif 特性=="瞬击" then
    local 触发=0
    local 防御=10
    if 几率==1 then
      触发=33
    elseif 几率==2 then
      触发=50
    elseif 几率==3 then
      触发=66
      防御=5
    elseif 几率==4 then
      触发=83
      防御=5
    elseif 几率==5 then
      触发=100
      防御=5
    end
    if 触发>=取随机数() then
      self.参战单位[编号].防御=qz(self.参战单位[编号].防御*(1-防御/100))
      self.参战单位[编号].指令.目标=self:取单个敌方目标(编号)
      self:普通攻击计算(编号,1)
    end
  elseif 特性=="瞬法" then
    local 防御=10
    if 几率==1 then
      触发=33
    elseif 几率==2 then
      触发=50
    elseif 几率==3 then
      触发=66
      防御=5
    elseif 几率==4 then
      触发=83
      防御=5
    elseif 几率==5 then
      触发=100
      防御=5
    end
    local 名称=self:取召唤兽可用法术(编号)
    if 触发>=取随机数() and 名称~=nil then
      self.参战单位[编号].最大气血=qz(self.参战单位[编号].最大气血*(1-防御/100))
      if self.参战单位[编号].气血>self.参战单位[编号].最大气血 then
        self.参战单位[编号].气血=self.参战单位[编号].最大气血
      end
      self.参战单位[编号].指令.目标=self:取单个敌方目标(编号)
      self:法攻技能计算(编号,名称,self:取技能等级(编号,名称),1)
    end
  end

end
function 战斗处理类:取召唤兽可用法术(编号)
  local 法术名称={"水攻","烈火","雷击","落岩","奔雷咒","水漫金山","地狱烈火","泰山压顶"}
  local 技能组={}
  for n=1,#self.参战单位[编号].主动技能 do
    for i=1,#法术名称 do
      if 法术名称[i]==self.参战单位[编号].主动技能[n].名称 then
        技能组[#技能组+1]=法术名称[i]
      end
    end
  end
  if #技能组==0 then
    return
  else
    return 技能组[取随机数(1,#技能组)]
  end
end
function 战斗处理类:取我方气血最低(编号)

  local 目标组={}
  local 伤害={id=0,伤害=999999}
  for n=1,#self.参战单位 do
    if self.参战单位[n].队伍==self.参战单位[编号].队伍 and self:取目标状态(编号,n,1) then
      if self.参战单位[n].气血<伤害.伤害 then
        伤害.伤害=self.参战单位[n].气血
        伤害.id=n
      end
    end
  end
  if 伤害.id==0 then
    return 编号
  else
    return 伤害.id
  end

end
function 战斗处理类:取难度系数(任务id)
  local 难度系数 = {}
  if self.战斗类型 == 100008 then --抓鬼难度
    难度系数[1] = f函数.读配置(程序目录.."定制难度.ini","常规任务","抓鬼难度气血")
    难度系数[2] = f函数.读配置(程序目录.."定制难度.ini","常规任务","抓鬼难度伤害")
    难度系数[3] = f函数.读配置(程序目录.."定制难度.ini","常规任务","抓鬼难度防御")
    难度系数[4] = f函数.读配置(程序目录.."定制难度.ini","常规任务","抓鬼难度灵力")
    难度系数[5] = f函数.读配置(程序目录.."定制难度.ini","常规任务","抓鬼难度速度")
    难度系数[6] = f函数.读配置(程序目录.."定制难度.ini","常规任务","抓鬼难度法防")
  elseif self.战斗类型 == 100009 then --星宿难度
    难度系数[1] = f函数.读配置(程序目录.."定制难度.ini","常规任务","星宿难度气血")
    难度系数[2] = f函数.读配置(程序目录.."定制难度.ini","常规任务","星宿难度伤害")
    难度系数[3] = f函数.读配置(程序目录.."定制难度.ini","常规任务","星宿难度防御")
    难度系数[4] = f函数.读配置(程序目录.."定制难度.ini","常规任务","星宿难度灵力")
    难度系数[5] = f函数.读配置(程序目录.."定制难度.ini","常规任务","星宿难度速度")
    难度系数[6] = f函数.读配置(程序目录.."定制难度.ini","常规任务","星宿难度法防")
  elseif self.战斗类型 == 100010 then --妖魔鬼怪难度
    难度系数[1] = f函数.读配置(程序目录.."定制难度.ini","常规任务","妖魔鬼怪难度气血")
    难度系数[2] = f函数.读配置(程序目录.."定制难度.ini","常规任务","妖魔鬼怪难度伤害")
    难度系数[3] = f函数.读配置(程序目录.."定制难度.ini","常规任务","妖魔鬼怪难度防御")
    难度系数[4] = f函数.读配置(程序目录.."定制难度.ini","常规任务","妖魔鬼怪难度灵力")
    难度系数[5] = f函数.读配置(程序目录.."定制难度.ini","常规任务","妖魔鬼怪难度速度")
    难度系数[6] = f函数.读配置(程序目录.."定制难度.ini","常规任务","妖魔鬼怪难度法防")
  elseif self.战斗类型 == 100011 then --门派闯关难度
    难度系数[1] = f函数.读配置(程序目录.."定制难度.ini","常规任务","门派闯关难度气血")
    难度系数[2] = f函数.读配置(程序目录.."定制难度.ini","常规任务","门派闯关难度伤害")
    难度系数[3] = f函数.读配置(程序目录.."定制难度.ini","常规任务","门派闯关难度防御")
    难度系数[4] = f函数.读配置(程序目录.."定制难度.ini","常规任务","门派闯关难度灵力")
    难度系数[5] = f函数.读配置(程序目录.."定制难度.ini","常规任务","门派闯关难度速度")
    难度系数[6] = f函数.读配置(程序目录.."定制难度.ini","常规任务","门派闯关难度法防")
  elseif self.战斗类型 == 100012 then --游泳难度
    难度系数[1] = f函数.读配置(程序目录.."定制难度.ini","常规任务","游泳难度气血")
    难度系数[2] = f函数.读配置(程序目录.."定制难度.ini","常规任务","游泳难度伤害")
    难度系数[3] = f函数.读配置(程序目录.."定制难度.ini","常规任务","游泳难度防御")
    难度系数[4] = f函数.读配置(程序目录.."定制难度.ini","常规任务","游泳难度灵力")
    难度系数[5] = f函数.读配置(程序目录.."定制难度.ini","常规任务","游泳难度速度")
    难度系数[6] = f函数.读配置(程序目录.."定制难度.ini","常规任务","游泳难度法防")
  elseif self.战斗类型 == 100013 or self.战斗类型 == 100014 then --官职难度
    难度系数[1] = f函数.读配置(程序目录.."定制难度.ini","常规任务","官职难度气血")
    难度系数[2] = f函数.读配置(程序目录.."定制难度.ini","常规任务","官职难度伤害")
    难度系数[3] = f函数.读配置(程序目录.."定制难度.ini","常规任务","官职难度防御")
    难度系数[4] = f函数.读配置(程序目录.."定制难度.ini","常规任务","官职难度灵力")
    难度系数[5] = f函数.读配置(程序目录.."定制难度.ini","常规任务","官职难度速度")
    难度系数[6] = f函数.读配置(程序目录.."定制难度.ini","常规任务","官职难度法防")
  elseif self.战斗类型 == 100015 or self.战斗类型 == 100016 or self.战斗类型 == 100017 or self.战斗类型 == 100018 then --师门难度
    难度系数[1] = f函数.读配置(程序目录.."定制难度.ini","常规任务","师门任务难度气血")
    难度系数[2] = f函数.读配置(程序目录.."定制难度.ini","常规任务","师门任务难度伤害")
    难度系数[3] = f函数.读配置(程序目录.."定制难度.ini","常规任务","师门任务难度防御")
    难度系数[4] = f函数.读配置(程序目录.."定制难度.ini","常规任务","师门任务难度灵力")
    难度系数[5] = f函数.读配置(程序目录.."定制难度.ini","常规任务","师门任务难度速度")
    难度系数[6] = f函数.读配置(程序目录.."定制难度.ini","常规任务","师门任务难度法防")
  elseif self.战斗类型 == 100019 then --迷宫小怪难度
    难度系数[1] = f函数.读配置(程序目录.."定制难度.ini","常规任务","迷宫小怪难度气血")
    难度系数[2] = f函数.读配置(程序目录.."定制难度.ini","常规任务","迷宫小怪难度伤害")
    难度系数[3] = f函数.读配置(程序目录.."定制难度.ini","常规任务","迷宫小怪难度防御")
    难度系数[4] = f函数.读配置(程序目录.."定制难度.ini","常规任务","迷宫小怪难度灵力")
    难度系数[5] = f函数.读配置(程序目录.."定制难度.ini","常规任务","迷宫小怪难度速度")
    难度系数[6] = f函数.读配置(程序目录.."定制难度.ini","常规任务","迷宫小怪难度法防")
  elseif self.战斗类型 == 100020 then --妖王难度
    难度系数[1] = f函数.读配置(程序目录.."定制难度.ini","常规任务","妖王难度气血")
    难度系数[2] = f函数.读配置(程序目录.."定制难度.ini","常规任务","妖王难度伤害")
    难度系数[3] = f函数.读配置(程序目录.."定制难度.ini","常规任务","妖王难度防御")
    难度系数[4] = f函数.读配置(程序目录.."定制难度.ini","常规任务","妖王难度灵力")
    难度系数[5] = f函数.读配置(程序目录.."定制难度.ini","常规任务","妖王难度速度")
    难度系数[6] = f函数.读配置(程序目录.."定制难度.ini","常规任务","妖王难度法防")
  elseif self.战斗类型 == 100021 then --江湖大盗
    难度系数[1] = f函数.读配置(程序目录.."定制难度.ini","常规任务","江湖大盗难度气血")
    难度系数[2] = f函数.读配置(程序目录.."定制难度.ini","常规任务","江湖大盗难度伤害")
    难度系数[3] = f函数.读配置(程序目录.."定制难度.ini","常规任务","江湖大盗难度防御")
    难度系数[4] = f函数.读配置(程序目录.."定制难度.ini","常规任务","江湖大盗难度灵力")
    难度系数[5] = f函数.读配置(程序目录.."定制难度.ini","常规任务","江湖大盗难度速度")
    难度系数[6] = f函数.读配置(程序目录.."定制难度.ini","常规任务","江湖大盗难度法防")
  elseif self.战斗类型 == 100022 then --皇宫飞贼难度
    难度系数[1] = f函数.读配置(程序目录.."定制难度.ini","常规任务","皇宫飞贼难度气血")
    难度系数[2] = f函数.读配置(程序目录.."定制难度.ini","常规任务","皇宫飞贼难度伤害")
    难度系数[3] = f函数.读配置(程序目录.."定制难度.ini","常规任务","皇宫飞贼难度防御")
    难度系数[4] = f函数.读配置(程序目录.."定制难度.ini","常规任务","皇宫飞贼难度灵力")
    难度系数[5] = f函数.读配置(程序目录.."定制难度.ini","常规任务","皇宫飞贼难度速度")
    难度系数[6] = f函数.读配置(程序目录.."定制难度.ini","常规任务","皇宫飞贼难度法防")
  elseif self.战斗类型 == 100023 then --皇宫贼王难度
    难度系数[1] = f函数.读配置(程序目录.."定制难度.ini","常规任务","皇宫贼王难度气血")
    难度系数[2] = f函数.读配置(程序目录.."定制难度.ini","常规任务","皇宫贼王难度伤害")
    难度系数[3] = f函数.读配置(程序目录.."定制难度.ini","常规任务","皇宫贼王难度防御")
    难度系数[4] = f函数.读配置(程序目录.."定制难度.ini","常规任务","皇宫贼王难度灵力")
    难度系数[5] = f函数.读配置(程序目录.."定制难度.ini","常规任务","皇宫贼王难度速度")
    难度系数[6] = f函数.读配置(程序目录.."定制难度.ini","常规任务","皇宫贼王难度法防")
  elseif self.战斗类型 == 100024 then --世界BOOS难度
    if 任务数据[任务id].等级==60 then
      难度系数[1] = f函数.读配置(程序目录.."定制难度.ini","常规任务","60BOOS难度气血")
      难度系数[2] = f函数.读配置(程序目录.."定制难度.ini","常规任务","60BOOS难度伤害")
      难度系数[3] = f函数.读配置(程序目录.."定制难度.ini","常规任务","60BOOS难度防御")
      难度系数[4] = f函数.读配置(程序目录.."定制难度.ini","常规任务","60BOOS难度灵力")
      难度系数[5] = f函数.读配置(程序目录.."定制难度.ini","常规任务","60BOOS难度速度")
      难度系数[6] = f函数.读配置(程序目录.."定制难度.ini","常规任务","60BOOS难度法防")
    elseif 任务数据[任务id].等级==100 then
      难度系数[1] = f函数.读配置(程序目录.."定制难度.ini","常规任务","100BOOS难度气血")
      难度系数[2] = f函数.读配置(程序目录.."定制难度.ini","常规任务","100BOOS难度伤害")
      难度系数[3] = f函数.读配置(程序目录.."定制难度.ini","常规任务","100BOOS难度防御")
      难度系数[4] = f函数.读配置(程序目录.."定制难度.ini","常规任务","100BOOS难度灵力")
      难度系数[5] = f函数.读配置(程序目录.."定制难度.ini","常规任务","100BOOS难度速度")
      难度系数[6] = f函数.读配置(程序目录.."定制难度.ini","常规任务","100BOOS难度法防")
    else
      难度系数[1] = f函数.读配置(程序目录.."定制难度.ini","常规任务","150BOOS难度气血")
      难度系数[2] = f函数.读配置(程序目录.."定制难度.ini","常规任务","150BOOS难度伤害")
      难度系数[3] = f函数.读配置(程序目录.."定制难度.ini","常规任务","150BOOS难度防御")
      难度系数[4] = f函数.读配置(程序目录.."定制难度.ini","常规任务","150BOOS难度灵力")
      难度系数[5] = f函数.读配置(程序目录.."定制难度.ini","常规任务","150BOOS难度速度")
      难度系数[6] = f函数.读配置(程序目录.."定制难度.ini","常规任务","150BOOS难度法防")
    end
  elseif self.战斗类型 == 100025 then --镖王难度
    难度系数[1] = f函数.读配置(程序目录.."定制难度.ini","常规任务","镖王难度气血")
    难度系数[2] = f函数.读配置(程序目录.."定制难度.ini","常规任务","镖王难度伤害")
    难度系数[3] = f函数.读配置(程序目录.."定制难度.ini","常规任务","镖王难度防御")
    难度系数[4] = f函数.读配置(程序目录.."定制难度.ini","常规任务","镖王难度灵力")
    难度系数[5] = f函数.读配置(程序目录.."定制难度.ini","常规任务","镖王难度速度")
    难度系数[6] = f函数.读配置(程序目录.."定制难度.ini","常规任务","镖王难度法防")
  elseif self.战斗类型 == 100026 then --三界悬赏令难度
    难度系数[1] = f函数.读配置(程序目录.."定制难度.ini","常规任务","三界悬赏令难度气血")
    难度系数[2] = f函数.读配置(程序目录.."定制难度.ini","常规任务","三界悬赏令难度伤害")
    难度系数[3] = f函数.读配置(程序目录.."定制难度.ini","常规任务","三界悬赏令难度防御")
    难度系数[4] = f函数.读配置(程序目录.."定制难度.ini","常规任务","三界悬赏令难度灵力")
    难度系数[5] = f函数.读配置(程序目录.."定制难度.ini","常规任务","三界悬赏令难度速度")
    难度系数[6] = f函数.读配置(程序目录.."定制难度.ini","常规任务","三界悬赏令难度法防")
  elseif self.战斗类型 == 100027 then --知了王难度
    难度系数[1] = f函数.读配置(程序目录.."定制难度.ini","常规任务","知了王难度气血")
    难度系数[2] = f函数.读配置(程序目录.."定制难度.ini","常规任务","知了王难度伤害")
    难度系数[3] = f函数.读配置(程序目录.."定制难度.ini","常规任务","知了王难度防御")
    难度系数[4] = f函数.读配置(程序目录.."定制难度.ini","常规任务","知了王难度灵力")
    难度系数[5] = f函数.读配置(程序目录.."定制难度.ini","常规任务","知了王难度速度")
    难度系数[6] = f函数.读配置(程序目录.."定制难度.ini","常规任务","知了王难度法防")
  elseif self.战斗类型 == 100028 then --副本芭蕉难度
    难度系数[1] = f函数.读配置(程序目录.."定制难度.ini","常规任务","副本芭蕉难度气血")
    难度系数[2] = f函数.读配置(程序目录.."定制难度.ini","常规任务","副本芭蕉难度伤害")
    难度系数[3] = f函数.读配置(程序目录.."定制难度.ini","常规任务","副本芭蕉难度防御")
    难度系数[4] = f函数.读配置(程序目录.."定制难度.ini","常规任务","副本芭蕉难度灵力")
    难度系数[5] = f函数.读配置(程序目录.."定制难度.ini","常规任务","副本芭蕉难度速度")
    难度系数[6] = f函数.读配置(程序目录.."定制难度.ini","常规任务","副本芭蕉难度法防")
  elseif self.战斗类型 == 100029 then --副本三妖难度
    难度系数[1] = f函数.读配置(程序目录.."定制难度.ini","常规任务","副本三妖难度气血")
    难度系数[2] = f函数.读配置(程序目录.."定制难度.ini","常规任务","副本三妖难度伤害")
    难度系数[3] = f函数.读配置(程序目录.."定制难度.ini","常规任务","副本三妖难度防御")
    难度系数[4] = f函数.读配置(程序目录.."定制难度.ini","常规任务","副本三妖难度灵力")
    难度系数[5] = f函数.读配置(程序目录.."定制难度.ini","常规任务","副本三妖难度速度")
    难度系数[6] = f函数.读配置(程序目录.."定制难度.ini","常规任务","副本三妖难度法防")
  elseif self.战斗类型 == 100030 then --鬼祟小怪难度
    难度系数[1] = f函数.读配置(程序目录.."定制难度.ini","常规任务","鬼祟小怪难度气血")
    难度系数[2] = f函数.读配置(程序目录.."定制难度.ini","常规任务","鬼祟小怪难度伤害")
    难度系数[3] = f函数.读配置(程序目录.."定制难度.ini","常规任务","鬼祟小怪难度防御")
    难度系数[4] = f函数.读配置(程序目录.."定制难度.ini","常规任务","鬼祟小怪难度灵力")
    难度系数[5] = f函数.读配置(程序目录.."定制难度.ini","常规任务","鬼祟小怪难度速度")
    难度系数[6] = f函数.读配置(程序目录.."定制难度.ini","常规任务","鬼祟小怪难度法防")
  elseif self.战斗类型 == 100031 then --副本国王难度
    难度系数[1] = f函数.读配置(程序目录.."定制难度.ini","常规任务","副本国王难度气血")
    难度系数[2] = f函数.读配置(程序目录.."定制难度.ini","常规任务","副本国王难度伤害")
    难度系数[3] = f函数.读配置(程序目录.."定制难度.ini","常规任务","副本国王难度防御")
    难度系数[4] = f函数.读配置(程序目录.."定制难度.ini","常规任务","副本国王难度灵力")
    难度系数[5] = f函数.读配置(程序目录.."定制难度.ini","常规任务","副本国王难度速度")
    难度系数[6] = f函数.读配置(程序目录.."定制难度.ini","常规任务","副本国王难度法防")
  elseif self.战斗类型 == 100032 then --天庭叛逆难度
    难度系数[1] = f函数.读配置(程序目录.."定制难度.ini","常规任务","天庭叛逆难度气血")
    难度系数[2] = f函数.读配置(程序目录.."定制难度.ini","常规任务","天庭叛逆难度伤害")
    难度系数[3] = f函数.读配置(程序目录.."定制难度.ini","常规任务","天庭叛逆难度防御")
    难度系数[4] = f函数.读配置(程序目录.."定制难度.ini","常规任务","天庭叛逆难度灵力")
    难度系数[5] = f函数.读配置(程序目录.."定制难度.ini","常规任务","天庭叛逆难度速度")
    难度系数[6] = f函数.读配置(程序目录.."定制难度.ini","常规任务","天庭叛逆难度法防")
  elseif self.战斗类型 == 100033 then --捣乱的水果难度
    难度系数[1] = f函数.读配置(程序目录.."定制难度.ini","常规任务","捣乱的水果难度气血")
    难度系数[2] = f函数.读配置(程序目录.."定制难度.ini","常规任务","捣乱的水果难度伤害")
    难度系数[3] = f函数.读配置(程序目录.."定制难度.ini","常规任务","捣乱的水果难度防御")
    难度系数[4] = f函数.读配置(程序目录.."定制难度.ini","常规任务","捣乱的水果难度灵力")
    难度系数[5] = f函数.读配置(程序目录.."定制难度.ini","常规任务","捣乱的水果难度速度")
    难度系数[6] = f函数.读配置(程序目录.."定制难度.ini","常规任务","捣乱的水果难度法防")
  elseif self.战斗类型 == 100034 then --青龙巡逻难度
    难度系数[1] = f函数.读配置(程序目录.."定制难度.ini","常规任务","青龙巡逻难度气血")
    难度系数[2] = f函数.读配置(程序目录.."定制难度.ini","常规任务","青龙巡逻难度伤害")
    难度系数[3] = f函数.读配置(程序目录.."定制难度.ini","常规任务","青龙巡逻难度防御")
    难度系数[4] = f函数.读配置(程序目录.."定制难度.ini","常规任务","青龙巡逻难度灵力")
    难度系数[5] = f函数.读配置(程序目录.."定制难度.ini","常规任务","青龙巡逻难度速度")
    难度系数[6] = f函数.读配置(程序目录.."定制难度.ini","常规任务","青龙巡逻难度法防")
  elseif self.战斗类型 == 100035 then --玄武巡逻难度
    难度系数[1] = f函数.读配置(程序目录.."定制难度.ini","常规任务","玄武巡逻难度气血")
    难度系数[2] = f函数.读配置(程序目录.."定制难度.ini","常规任务","玄武巡逻难度伤害")
    难度系数[3] = f函数.读配置(程序目录.."定制难度.ini","常规任务","玄武巡逻难度防御")
    难度系数[4] = f函数.读配置(程序目录.."定制难度.ini","常规任务","玄武巡逻难度灵力")
    难度系数[5] = f函数.读配置(程序目录.."定制难度.ini","常规任务","玄武巡逻难度速度")
    难度系数[6] = f函数.读配置(程序目录.."定制难度.ini","常规任务","玄武巡逻难度法防")
  elseif self.战斗类型 == 100036 then --冠状病毒难度
    难度系数[1] = f函数.读配置(程序目录.."定制难度.ini","常规任务","冠状病毒难度气血")
    难度系数[2] = f函数.读配置(程序目录.."定制难度.ini","常规任务","冠状病毒难度伤害")
    难度系数[3] = f函数.读配置(程序目录.."定制难度.ini","常规任务","冠状病毒难度防御")
    难度系数[4] = f函数.读配置(程序目录.."定制难度.ini","常规任务","冠状病毒难度灵力")
    难度系数[5] = f函数.读配置(程序目录.."定制难度.ini","常规任务","冠状病毒难度速度")
    难度系数[6] = f函数.读配置(程序目录.."定制难度.ini","常规任务","冠状病毒难度法防")
  elseif self.战斗类型 == 100037 then --地煞难度
    难度系数[1] = f函数.读配置(程序目录.."定制难度.ini","常规任务","地煞难度气血")
    难度系数[2] = f函数.读配置(程序目录.."定制难度.ini","常规任务","地煞难度伤害")
    难度系数[3] = f函数.读配置(程序目录.."定制难度.ini","常规任务","地煞难度防御")
    难度系数[4] = f函数.读配置(程序目录.."定制难度.ini","常规任务","地煞难度灵力")
    难度系数[5] = f函数.读配置(程序目录.."定制难度.ini","常规任务","地煞难度速度")
    难度系数[6] = f函数.读配置(程序目录.."定制难度.ini","常规任务","地煞难度法防")
  elseif self.战斗类型 == 100038 then --知了先锋难度
    难度系数[1] = f函数.读配置(程序目录.."定制难度.ini","常规任务","知了先锋难度气血")
    难度系数[2] = f函数.读配置(程序目录.."定制难度.ini","常规任务","知了先锋难度伤害")
    难度系数[3] = f函数.读配置(程序目录.."定制难度.ini","常规任务","知了先锋难度防御")
    难度系数[4] = f函数.读配置(程序目录.."定制难度.ini","常规任务","知了先锋难度灵力")
    难度系数[5] = f函数.读配置(程序目录.."定制难度.ini","常规任务","知了先锋难度速度")
    难度系数[6] = f函数.读配置(程序目录.."定制难度.ini","常规任务","知了先锋难度法防")
  elseif self.战斗类型 == 100039 then --知了小王难度
    难度系数[1] = f函数.读配置(程序目录.."定制难度.ini","常规任务","知了小王难度气血")
    难度系数[2] = f函数.读配置(程序目录.."定制难度.ini","常规任务","知了小王难度伤害")
    难度系数[3] = f函数.读配置(程序目录.."定制难度.ini","常规任务","知了小王难度防御")
    难度系数[4] = f函数.读配置(程序目录.."定制难度.ini","常规任务","知了小王难度灵力")
    难度系数[5] = f函数.读配置(程序目录.."定制难度.ini","常规任务","知了小王难度速度")
    难度系数[6] = f函数.读配置(程序目录.."定制难度.ini","常规任务","知了小王难度法防")
  elseif self.战斗类型 == 100040 then --大力神灵难度
    难度系数[1] = f函数.读配置(程序目录.."定制难度.ini","常规任务","大力神灵难度气血")
    难度系数[2] = f函数.读配置(程序目录.."定制难度.ini","常规任务","大力神灵难度伤害")
    难度系数[3] = f函数.读配置(程序目录.."定制难度.ini","常规任务","大力神灵难度防御")
    难度系数[4] = f函数.读配置(程序目录.."定制难度.ini","常规任务","大力神灵难度灵力")
    难度系数[5] = f函数.读配置(程序目录.."定制难度.ini","常规任务","大力神灵难度速度")
    难度系数[6] = f函数.读配置(程序目录.."定制难度.ini","常规任务","大力神灵难度法防")
  elseif self.战斗类型 == 100041 then --妖魔亲信难度
    难度系数[1] = f函数.读配置(程序目录.."定制难度.ini","常规任务","妖魔亲信难度气血")
    难度系数[2] = f函数.读配置(程序目录.."定制难度.ini","常规任务","妖魔亲信难度伤害")
    难度系数[3] = f函数.读配置(程序目录.."定制难度.ini","常规任务","妖魔亲信难度防御")
    难度系数[4] = f函数.读配置(程序目录.."定制难度.ini","常规任务","妖魔亲信难度灵力")
    难度系数[5] = f函数.读配置(程序目录.."定制难度.ini","常规任务","妖魔亲信难度速度")
    难度系数[6] = f函数.读配置(程序目录.."定制难度.ini","常规任务","妖魔亲信难度法防")
  elseif self.战斗类型 == 100042 then --蜃妖元神难度
    难度系数[1] = f函数.读配置(程序目录.."定制难度.ini","常规任务","蜃妖元神难度气血")
    难度系数[2] = f函数.读配置(程序目录.."定制难度.ini","常规任务","蜃妖元神难度伤害")
    难度系数[3] = f函数.读配置(程序目录.."定制难度.ini","常规任务","蜃妖元神难度防御")
    难度系数[4] = f函数.读配置(程序目录.."定制难度.ini","常规任务","蜃妖元神难度灵力")
    难度系数[5] = f函数.读配置(程序目录.."定制难度.ini","常规任务","蜃妖元神难度速度")
    难度系数[6] = f函数.读配置(程序目录.."定制难度.ini","常规任务","蜃妖元神难度法防")
  elseif self.战斗类型 == 100043 then --周猎户难度
    难度系数[1] = f函数.读配置(程序目录.."定制难度.ini","常规任务","周猎户难度气血")
    难度系数[2] = f函数.读配置(程序目录.."定制难度.ini","常规任务","周猎户难度伤害")
    难度系数[3] = f函数.读配置(程序目录.."定制难度.ini","常规任务","周猎户难度防御")
    难度系数[4] = f函数.读配置(程序目录.."定制难度.ini","常规任务","周猎户难度灵力")
    难度系数[5] = f函数.读配置(程序目录.."定制难度.ini","常规任务","周猎户难度速度")
    难度系数[6] = f函数.读配置(程序目录.."定制难度.ini","常规任务","周猎户难度法防")
  elseif self.战斗类型 == 100044 then --法宝战斗难度
    难度系数[1] = f函数.读配置(程序目录.."定制难度.ini","常规任务","法宝战斗难度气血")
    难度系数[2] = f函数.读配置(程序目录.."定制难度.ini","常规任务","法宝战斗难度伤害")
    难度系数[3] = f函数.读配置(程序目录.."定制难度.ini","常规任务","法宝战斗难度防御")
    难度系数[4] = f函数.读配置(程序目录.."定制难度.ini","常规任务","法宝战斗难度灵力")
    难度系数[5] = f函数.读配置(程序目录.."定制难度.ini","常规任务","法宝战斗难度速度")
    难度系数[6] = f函数.读配置(程序目录.."定制难度.ini","常规任务","法宝战斗难度法防")
  elseif self.战斗类型 == 100045 then --法宝内丹难度
    难度系数[1] = f函数.读配置(程序目录.."定制难度.ini","常规任务","法宝内丹难度气血")
    难度系数[2] = f函数.读配置(程序目录.."定制难度.ini","常规任务","法宝内丹难度伤害")
    难度系数[3] = f函数.读配置(程序目录.."定制难度.ini","常规任务","法宝内丹难度防御")
    难度系数[4] = f函数.读配置(程序目录.."定制难度.ini","常规任务","法宝内丹难度灵力")
    难度系数[5] = f函数.读配置(程序目录.."定制难度.ini","常规任务","法宝内丹难度速度")
    难度系数[6] = f函数.读配置(程序目录.."定制难度.ini","常规任务","法宝内丹难度法防")
  elseif self.战斗类型 == 100046 then --霸道的土匪难度
    难度系数[1] = f函数.读配置(程序目录.."定制难度.ini","常规任务","霸道的土匪难度气血")
    难度系数[2] = f函数.读配置(程序目录.."定制难度.ini","常规任务","霸道的土匪难度伤害")
    难度系数[3] = f函数.读配置(程序目录.."定制难度.ini","常规任务","霸道的土匪难度防御")
    难度系数[4] = f函数.读配置(程序目录.."定制难度.ini","常规任务","霸道的土匪难度灵力")
    难度系数[5] = f函数.读配置(程序目录.."定制难度.ini","常规任务","霸道的土匪难度速度")
    难度系数[6] = f函数.读配置(程序目录.."定制难度.ini","常规任务","霸道的土匪难度法防")
  elseif self.战斗类型 == 100047 then --飞升心魔难度
    难度系数[1] = f函数.读配置(程序目录.."定制难度.ini","常规任务","飞升心魔难度气血")
    难度系数[2] = f函数.读配置(程序目录.."定制难度.ini","常规任务","飞升心魔难度伤害")
    难度系数[3] = f函数.读配置(程序目录.."定制难度.ini","常规任务","飞升心魔难度防御")
    难度系数[4] = f函数.读配置(程序目录.."定制难度.ini","常规任务","飞升心魔难度灵力")
    难度系数[5] = f函数.读配置(程序目录.."定制难度.ini","常规任务","飞升心魔难度速度")
    难度系数[6] = f函数.读配置(程序目录.."定制难度.ini","常规任务","飞升心魔难度法防")
  elseif self.战斗类型 == 100048 then --飞升小妖难度
    难度系数[1] = f函数.读配置(程序目录.."定制难度.ini","常规任务","飞升小妖难度气血")
    难度系数[2] = f函数.读配置(程序目录.."定制难度.ini","常规任务","飞升小妖难度伤害")
    难度系数[3] = f函数.读配置(程序目录.."定制难度.ini","常规任务","飞升小妖难度防御")
    难度系数[4] = f函数.读配置(程序目录.."定制难度.ini","常规任务","飞升小妖难度灵力")
    难度系数[5] = f函数.读配置(程序目录.."定制难度.ini","常规任务","飞升小妖难度速度")
    难度系数[6] = f函数.读配置(程序目录.."定制难度.ini","常规任务","飞升小妖难度法防")
  elseif self.战斗类型 == 100049 then --飞升小宝箱难度
    难度系数[1] = f函数.读配置(程序目录.."定制难度.ini","常规任务","飞升小宝箱难度气血")
    难度系数[2] = f函数.读配置(程序目录.."定制难度.ini","常规任务","飞升小宝箱难度伤害")
    难度系数[3] = f函数.读配置(程序目录.."定制难度.ini","常规任务","飞升小宝箱难度防御")
    难度系数[4] = f函数.读配置(程序目录.."定制难度.ini","常规任务","飞升小宝箱难度灵力")
    难度系数[5] = f函数.读配置(程序目录.."定制难度.ini","常规任务","飞升小宝箱难度速度")
    难度系数[6] = f函数.读配置(程序目录.."定制难度.ini","常规任务","飞升小宝箱难度法防")
  elseif self.战斗类型 == 100050 then --飞升阵法1难度
    难度系数[1] = f函数.读配置(程序目录.."定制难度.ini","常规任务","飞升阵法1难度气血")
    难度系数[2] = f函数.读配置(程序目录.."定制难度.ini","常规任务","飞升阵法1难度伤害")
    难度系数[3] = f函数.读配置(程序目录.."定制难度.ini","常规任务","飞升阵法1难度防御")
    难度系数[4] = f函数.读配置(程序目录.."定制难度.ini","常规任务","飞升阵法1难度灵力")
    难度系数[5] = f函数.读配置(程序目录.."定制难度.ini","常规任务","飞升阵法1难度速度")
    难度系数[6] = f函数.读配置(程序目录.."定制难度.ini","常规任务","飞升阵法1难度法防")
  elseif self.战斗类型 == 100051 then --飞升阵法2难度
    难度系数[1] = f函数.读配置(程序目录.."定制难度.ini","常规任务","飞升阵法2难度气血")
    难度系数[2] = f函数.读配置(程序目录.."定制难度.ini","常规任务","飞升阵法2难度伤害")
    难度系数[3] = f函数.读配置(程序目录.."定制难度.ini","常规任务","飞升阵法2难度防御")
    难度系数[4] = f函数.读配置(程序目录.."定制难度.ini","常规任务","飞升阵法2难度灵力")
    难度系数[5] = f函数.读配置(程序目录.."定制难度.ini","常规任务","飞升阵法2难度速度")
    难度系数[6] = f函数.读配置(程序目录.."定制难度.ini","常规任务","飞升阵法2难度法防")
  elseif self.战斗类型 == 100052 then --飞升阵法3难度
    难度系数[1] = f函数.读配置(程序目录.."定制难度.ini","常规任务","飞升阵法3难度气血")
    难度系数[2] = f函数.读配置(程序目录.."定制难度.ini","常规任务","飞升阵法3难度伤害")
    难度系数[3] = f函数.读配置(程序目录.."定制难度.ini","常规任务","飞升阵法3难度防御")
    难度系数[4] = f函数.读配置(程序目录.."定制难度.ini","常规任务","飞升阵法3难度灵力")
    难度系数[5] = f函数.读配置(程序目录.."定制难度.ini","常规任务","飞升阵法3难度速度")
    难度系数[6] = f函数.读配置(程序目录.."定制难度.ini","常规任务","飞升阵法3难度法防")
  elseif self.战斗类型 == 100053 then --飞升阵法4难度
    难度系数[1] = f函数.读配置(程序目录.."定制难度.ini","常规任务","飞升阵法4难度气血")
    难度系数[2] = f函数.读配置(程序目录.."定制难度.ini","常规任务","飞升阵法4难度伤害")
    难度系数[3] = f函数.读配置(程序目录.."定制难度.ini","常规任务","飞升阵法4难度防御")
    难度系数[4] = f函数.读配置(程序目录.."定制难度.ini","常规任务","飞升阵法4难度灵力")
    难度系数[5] = f函数.读配置(程序目录.."定制难度.ini","常规任务","飞升阵法4难度速度")
    难度系数[6] = f函数.读配置(程序目录.."定制难度.ini","常规任务","飞升阵法4难度法防")
  elseif self.战斗类型 == 100054 then --飞升阵法5难度
    难度系数[1] = f函数.读配置(程序目录.."定制难度.ini","常规任务","飞升阵法5难度气血")
    难度系数[2] = f函数.读配置(程序目录.."定制难度.ini","常规任务","飞升阵法5难度伤害")
    难度系数[3] = f函数.读配置(程序目录.."定制难度.ini","常规任务","飞升阵法5难度防御")
    难度系数[4] = f函数.读配置(程序目录.."定制难度.ini","常规任务","飞升阵法5难度灵力")
    难度系数[5] = f函数.读配置(程序目录.."定制难度.ini","常规任务","飞升阵法5难度速度")
    难度系数[6] = f函数.读配置(程序目录.."定制难度.ini","常规任务","飞升阵法5难度法防")
  elseif self.战斗类型 == 100055 then --生死劫难度
    if 生死劫数据[self.进入战斗玩家id] == 1 then
      难度系数[1] = f函数.读配置(程序目录.."定制难度.ini","常规任务","生死劫1难度气血")
      难度系数[2] = f函数.读配置(程序目录.."定制难度.ini","常规任务","生死劫1难度伤害")
      难度系数[3] = f函数.读配置(程序目录.."定制难度.ini","常规任务","生死劫1难度防御")
      难度系数[4] = f函数.读配置(程序目录.."定制难度.ini","常规任务","生死劫1难度灵力")
      难度系数[5] = f函数.读配置(程序目录.."定制难度.ini","常规任务","生死劫1难度速度")
      难度系数[6] = f函数.读配置(程序目录.."定制难度.ini","常规任务","生死劫1难度法防")
    elseif 生死劫数据[self.进入战斗玩家id] == 2 then
      难度系数[1] = f函数.读配置(程序目录.."定制难度.ini","常规任务","生死劫2难度气血")
      难度系数[2] = f函数.读配置(程序目录.."定制难度.ini","常规任务","生死劫2难度伤害")
      难度系数[3] = f函数.读配置(程序目录.."定制难度.ini","常规任务","生死劫2难度防御")
      难度系数[4] = f函数.读配置(程序目录.."定制难度.ini","常规任务","生死劫2难度灵力")
      难度系数[5] = f函数.读配置(程序目录.."定制难度.ini","常规任务","生死劫2难度速度")
      难度系数[6] = f函数.读配置(程序目录.."定制难度.ini","常规任务","生死劫3难度法防")
    elseif 生死劫数据[self.进入战斗玩家id] == 3 then
      难度系数[1] = f函数.读配置(程序目录.."定制难度.ini","常规任务","生死劫3难度气血")
      难度系数[2] = f函数.读配置(程序目录.."定制难度.ini","常规任务","生死劫3难度伤害")
      难度系数[3] = f函数.读配置(程序目录.."定制难度.ini","常规任务","生死劫3难度防御")
      难度系数[4] = f函数.读配置(程序目录.."定制难度.ini","常规任务","生死劫3难度灵力")
      难度系数[5] = f函数.读配置(程序目录.."定制难度.ini","常规任务","生死劫3难度速度")
      难度系数[6] = f函数.读配置(程序目录.."定制难度.ini","常规任务","生死劫3难度法防")
    elseif 生死劫数据[self.进入战斗玩家id] == 4 then
      难度系数[1] = f函数.读配置(程序目录.."定制难度.ini","常规任务","生死劫4难度气血")
      难度系数[2] = f函数.读配置(程序目录.."定制难度.ini","常规任务","生死劫4难度伤害")
      难度系数[3] = f函数.读配置(程序目录.."定制难度.ini","常规任务","生死劫4难度防御")
      难度系数[4] = f函数.读配置(程序目录.."定制难度.ini","常规任务","生死劫4难度灵力")
      难度系数[5] = f函数.读配置(程序目录.."定制难度.ini","常规任务","生死劫4难度速度")
      难度系数[6] = f函数.读配置(程序目录.."定制难度.ini","常规任务","生死劫4难度法防")
    elseif 生死劫数据[self.进入战斗玩家id] == 5 then
      难度系数[1] = f函数.读配置(程序目录.."定制难度.ini","常规任务","生死劫5难度气血")
      难度系数[2] = f函数.读配置(程序目录.."定制难度.ini","常规任务","生死劫5难度伤害")
      难度系数[3] = f函数.读配置(程序目录.."定制难度.ini","常规任务","生死劫5难度防御")
      难度系数[4] = f函数.读配置(程序目录.."定制难度.ini","常规任务","生死劫5难度灵力")
      难度系数[5] = f函数.读配置(程序目录.."定制难度.ini","常规任务","生死劫5难度速度")
      难度系数[6] = f函数.读配置(程序目录.."定制难度.ini","常规任务","生死劫5难度法防")
    elseif 生死劫数据[self.进入战斗玩家id] == 6 then
      难度系数[1] = f函数.读配置(程序目录.."定制难度.ini","常规任务","生死劫6难度气血")
      难度系数[2] = f函数.读配置(程序目录.."定制难度.ini","常规任务","生死劫6难度伤害")
      难度系数[3] = f函数.读配置(程序目录.."定制难度.ini","常规任务","生死劫6难度防御")
      难度系数[4] = f函数.读配置(程序目录.."定制难度.ini","常规任务","生死劫6难度灵力")
      难度系数[5] = f函数.读配置(程序目录.."定制难度.ini","常规任务","生死劫6难度速度")
      难度系数[6] = f函数.读配置(程序目录.."定制难度.ini","常规任务","生死劫6难度法防")
    elseif 生死劫数据[self.进入战斗玩家id] == 7 then
      难度系数[1] = f函数.读配置(程序目录.."定制难度.ini","常规任务","生死劫7难度气血")
      难度系数[2] = f函数.读配置(程序目录.."定制难度.ini","常规任务","生死劫7难度伤害")
      难度系数[3] = f函数.读配置(程序目录.."定制难度.ini","常规任务","生死劫7难度防御")
      难度系数[4] = f函数.读配置(程序目录.."定制难度.ini","常规任务","生死劫7难度灵力")
      难度系数[5] = f函数.读配置(程序目录.."定制难度.ini","常规任务","生死劫7难度速度")
      难度系数[6] = f函数.读配置(程序目录.."定制难度.ini","常规任务","生死劫7难度法防")
    elseif 生死劫数据[self.进入战斗玩家id] == 8 then
      难度系数[1] = f函数.读配置(程序目录.."定制难度.ini","常规任务","生死劫8难度气血")
      难度系数[2] = f函数.读配置(程序目录.."定制难度.ini","常规任务","生死劫8难度伤害")
      难度系数[3] = f函数.读配置(程序目录.."定制难度.ini","常规任务","生死劫8难度防御")
      难度系数[4] = f函数.读配置(程序目录.."定制难度.ini","常规任务","生死劫8难度灵力")
      难度系数[5] = f函数.读配置(程序目录.."定制难度.ini","常规任务","生死劫8难度速度")
      难度系数[6] = f函数.读配置(程序目录.."定制难度.ini","常规任务","生死劫8难度法防")
    elseif 生死劫数据[self.进入战斗玩家id] == 9 then
      难度系数[1] = f函数.读配置(程序目录.."定制难度.ini","常规任务","生死劫9难度气血")
      难度系数[2] = f函数.读配置(程序目录.."定制难度.ini","常规任务","生死劫9难度伤害")
      难度系数[3] = f函数.读配置(程序目录.."定制难度.ini","常规任务","生死劫9难度防御")
      难度系数[4] = f函数.读配置(程序目录.."定制难度.ini","常规任务","生死劫9难度灵力")
      难度系数[5] = f函数.读配置(程序目录.."定制难度.ini","常规任务","生死劫9难度速度")
      难度系数[6] = f函数.读配置(程序目录.."定制难度.ini","常规任务","生死劫9难度法防")
    end
  elseif self.战斗类型 == 100056 then --天罡星信息难度
    难度系数[1] = f函数.读配置(程序目录.."定制难度.ini","常规任务","天罡星难度气血")
    难度系数[2] = f函数.读配置(程序目录.."定制难度.ini","常规任务","天罡星难度伤害")
    难度系数[3] = f函数.读配置(程序目录.."定制难度.ini","常规任务","天罡星难度防御")
    难度系数[4] = f函数.读配置(程序目录.."定制难度.ini","常规任务","天罡星难度灵力")
    难度系数[5] = f函数.读配置(程序目录.."定制难度.ini","常规任务","天罡星难度速度")
    难度系数[6] = f函数.读配置(程序目录.."定制难度.ini","常规任务","天罡星难度法防")
  elseif self.战斗类型 == 100057 then --天蝎座难度
    难度系数[1] = f函数.读配置(程序目录.."定制难度.ini","定制任务","天蝎座难度气血")
    难度系数[2] = f函数.读配置(程序目录.."定制难度.ini","定制任务","天蝎座难度伤害")
    难度系数[3] = f函数.读配置(程序目录.."定制难度.ini","定制任务","天蝎座难度防御")
    难度系数[4] = f函数.读配置(程序目录.."定制难度.ini","定制任务","天蝎座难度灵力")
    难度系数[5] = f函数.读配置(程序目录.."定制难度.ini","定制任务","天蝎座难度速度")
    难度系数[6] = f函数.读配置(程序目录.."定制难度.ini","定制任务","天蝎座难度法防")
  elseif self.战斗类型 == 100058 then --射手座难度
    难度系数[1] = f函数.读配置(程序目录.."定制难度.ini","定制任务","射手座难度气血")
    难度系数[2] = f函数.读配置(程序目录.."定制难度.ini","定制任务","射手座难度伤害")
    难度系数[3] = f函数.读配置(程序目录.."定制难度.ini","定制任务","射手座难度防御")
    难度系数[4] = f函数.读配置(程序目录.."定制难度.ini","定制任务","射手座难度灵力")
    难度系数[5] = f函数.读配置(程序目录.."定制难度.ini","定制任务","射手座难度速度")
    难度系数[6] = f函数.读配置(程序目录.."定制难度.ini","定制任务","射手座难度法防")
  elseif self.战斗类型 == 100059 then --摩羯座难度
    难度系数[1] = f函数.读配置(程序目录.."定制难度.ini","定制任务","摩羯座难度气血")
    难度系数[2] = f函数.读配置(程序目录.."定制难度.ini","定制任务","摩羯座难度伤害")
    难度系数[3] = f函数.读配置(程序目录.."定制难度.ini","定制任务","摩羯座难度防御")
    难度系数[4] = f函数.读配置(程序目录.."定制难度.ini","定制任务","摩羯座难度灵力")
    难度系数[5] = f函数.读配置(程序目录.."定制难度.ini","定制任务","摩羯座难度速度")
    难度系数[6] = f函数.读配置(程序目录.."定制难度.ini","定制任务","摩羯座难度法防")
  elseif self.战斗类型 == 100060 then --福利BOOS难度
    难度系数[1] = f函数.读配置(程序目录.."定制难度.ini","定制任务","福利BOOS难度气血")
    难度系数[2] = f函数.读配置(程序目录.."定制难度.ini","定制任务","福利BOOS难度伤害")
    难度系数[3] = f函数.读配置(程序目录.."定制难度.ini","定制任务","福利BOOS难度防御")
    难度系数[4] = f函数.读配置(程序目录.."定制难度.ini","定制任务","福利BOOS难度灵力")
    难度系数[5] = f函数.读配置(程序目录.."定制难度.ini","定制任务","福利BOOS难度速度")
    难度系数[6] = f函数.读配置(程序目录.."定制难度.ini","定制任务","福利BOOS难度法防")
  elseif self.战斗类型 == 100061 then --帮派侍卫难度
    难度系数[1] = f函数.读配置(程序目录.."定制难度.ini","常规任务","帮派侍卫难度气血")
    难度系数[2] = f函数.读配置(程序目录.."定制难度.ini","常规任务","帮派侍卫难度伤害")
    难度系数[3] = f函数.读配置(程序目录.."定制难度.ini","常规任务","帮派侍卫难度防御")
    难度系数[4] = f函数.读配置(程序目录.."定制难度.ini","常规任务","帮派侍卫难度灵力")
    难度系数[5] = f函数.读配置(程序目录.."定制难度.ini","常规任务","帮派侍卫难度速度")
    难度系数[6] = f函数.读配置(程序目录.."定制难度.ini","常规任务","帮派侍卫难度法防")
  elseif self.战斗类型 == 100062 then --帮派护法难度
    难度系数[1] = f函数.读配置(程序目录.."定制难度.ini","常规任务","帮派护法难度气血")
    难度系数[2] = f函数.读配置(程序目录.."定制难度.ini","常规任务","帮派护法难度伤害")
    难度系数[3] = f函数.读配置(程序目录.."定制难度.ini","常规任务","帮派护法难度防御")
    难度系数[4] = f函数.读配置(程序目录.."定制难度.ini","常规任务","帮派护法难度灵力")
    难度系数[5] = f函数.读配置(程序目录.."定制难度.ini","常规任务","帮派护法难度速度")
    难度系数[6] = f函数.读配置(程序目录.."定制难度.ini","常规任务","帮派护法难度法防")
  elseif self.战斗类型 == 100063 then --水瓶座难度
    难度系数[1] = f函数.读配置(程序目录.."定制难度.ini","定制任务","水瓶座难度气血")
    难度系数[2] = f函数.读配置(程序目录.."定制难度.ini","定制任务","水瓶座难度伤害")
    难度系数[3] = f函数.读配置(程序目录.."定制难度.ini","定制任务","水瓶座难度防御")
    难度系数[4] = f函数.读配置(程序目录.."定制难度.ini","定制任务","水瓶座难度灵力")
    难度系数[5] = f函数.读配置(程序目录.."定制难度.ini","定制任务","水瓶座难度速度")
    难度系数[6] = f函数.读配置(程序目录.."定制难度.ini","定制任务","水瓶座难度法防")
  elseif self.战斗类型 == 100064 then --白羊座难度
    难度系数[1] = f函数.读配置(程序目录.."定制难度.ini","定制任务","白羊座难度气血")
    难度系数[2] = f函数.读配置(程序目录.."定制难度.ini","定制任务","白羊座难度伤害")
    难度系数[3] = f函数.读配置(程序目录.."定制难度.ini","定制任务","白羊座难度防御")
    难度系数[4] = f函数.读配置(程序目录.."定制难度.ini","定制任务","白羊座难度灵力")
    难度系数[5] = f函数.读配置(程序目录.."定制难度.ini","定制任务","白羊座难度速度")
    难度系数[6] = f函数.读配置(程序目录.."定制难度.ini","定制任务","白羊座难度法防")
  elseif self.战斗类型 == 100065 then --金牛座难度
    难度系数[1] = f函数.读配置(程序目录.."定制难度.ini","定制任务","金牛座难度气血")
    难度系数[2] = f函数.读配置(程序目录.."定制难度.ini","定制任务","金牛座难度伤害")
    难度系数[3] = f函数.读配置(程序目录.."定制难度.ini","定制任务","金牛座难度防御")
    难度系数[4] = f函数.读配置(程序目录.."定制难度.ini","定制任务","金牛座难度灵力")
    难度系数[5] = f函数.读配置(程序目录.."定制难度.ini","定制任务","金牛座难度速度")
    难度系数[6] = f函数.读配置(程序目录.."定制难度.ini","定制任务","金牛座难度法防")
  elseif self.战斗类型 == 100066 then --车迟贡品难度
    难度系数[1] = f函数.读配置(程序目录.."定制难度.ini","常规任务","车迟贡品难度气血")
    难度系数[2] = f函数.读配置(程序目录.."定制难度.ini","常规任务","车迟贡品难度伤害")
    难度系数[3] = f函数.读配置(程序目录.."定制难度.ini","常规任务","车迟贡品难度防御")
    难度系数[4] = f函数.读配置(程序目录.."定制难度.ini","常规任务","车迟贡品难度灵力")
    难度系数[5] = f函数.读配置(程序目录.."定制难度.ini","常规任务","车迟贡品难度速度")
    难度系数[6] = f函数.读配置(程序目录.."定制难度.ini","常规任务","车迟贡品难度法防")
  elseif self.战斗类型 == 100067 then --车迟三清难度
    难度系数[1] = f函数.读配置(程序目录.."定制难度.ini","常规任务","车迟三清难度气血")
    难度系数[2] = f函数.读配置(程序目录.."定制难度.ini","常规任务","车迟三清难度伤害")
    难度系数[3] = f函数.读配置(程序目录.."定制难度.ini","常规任务","车迟三清难度防御")
    难度系数[4] = f函数.读配置(程序目录.."定制难度.ini","常规任务","车迟三清难度灵力")
    难度系数[5] = f函数.读配置(程序目录.."定制难度.ini","常规任务","车迟三清难度速度")
    难度系数[6] = f函数.读配置(程序目录.."定制难度.ini","常规任务","车迟三清难度法防")
  elseif self.战斗类型 == 100068 then --车迟求雨难度
    难度系数[1] = f函数.读配置(程序目录.."定制难度.ini","常规任务","车迟求雨难度气血")
    难度系数[2] = f函数.读配置(程序目录.."定制难度.ini","常规任务","车迟求雨难度伤害")
    难度系数[3] = f函数.读配置(程序目录.."定制难度.ini","常规任务","车迟求雨难度防御")
    难度系数[4] = f函数.读配置(程序目录.."定制难度.ini","常规任务","车迟求雨难度灵力")
    难度系数[5] = f函数.读配置(程序目录.."定制难度.ini","常规任务","车迟求雨难度速度")
    难度系数[6] = f函数.读配置(程序目录.."定制难度.ini","常规任务","车迟求雨难度法防")
  elseif self.战斗类型 == 100069 then --车迟不动难度
    难度系数[1] = f函数.读配置(程序目录.."定制难度.ini","常规任务","车迟不动难度气血")
    难度系数[2] = f函数.读配置(程序目录.."定制难度.ini","常规任务","车迟不动难度伤害")
    难度系数[3] = f函数.读配置(程序目录.."定制难度.ini","常规任务","车迟不动难度防御")
    难度系数[4] = f函数.读配置(程序目录.."定制难度.ini","常规任务","车迟不动难度灵力")
    难度系数[5] = f函数.读配置(程序目录.."定制难度.ini","常规任务","车迟不动难度速度")
    难度系数[6] = f函数.读配置(程序目录.."定制难度.ini","常规任务","车迟不动难度法防")
  elseif self.战斗类型 == 100070 then --车迟妖怪难度
    难度系数[1] = f函数.读配置(程序目录.."定制难度.ini","常规任务","车迟妖怪难度气血")
    难度系数[2] = f函数.读配置(程序目录.."定制难度.ini","常规任务","车迟妖怪难度伤害")
    难度系数[3] = f函数.读配置(程序目录.."定制难度.ini","常规任务","车迟妖怪难度防御")
    难度系数[4] = f函数.读配置(程序目录.."定制难度.ini","常规任务","车迟妖怪难度灵力")
    难度系数[5] = f函数.读配置(程序目录.."定制难度.ini","常规任务","车迟妖怪难度速度")
    难度系数[6] = f函数.读配置(程序目录.."定制难度.ini","常规任务","车迟妖怪难度法防")
  elseif self.战斗类型 == 100071 then --倔强青铜难度
    难度系数[1] = f函数.读配置(程序目录.."定制难度.ini","定制任务","倔强青铜难度气血")
    难度系数[2] = f函数.读配置(程序目录.."定制难度.ini","定制任务","倔强青铜难度伤害")
    难度系数[3] = f函数.读配置(程序目录.."定制难度.ini","定制任务","倔强青铜难度防御")
    难度系数[4] = f函数.读配置(程序目录.."定制难度.ini","定制任务","倔强青铜难度灵力")
    难度系数[5] = f函数.读配置(程序目录.."定制难度.ini","定制任务","倔强青铜难度速度")
    难度系数[6] = f函数.读配置(程序目录.."定制难度.ini","定制任务","倔强青铜难度法防")
  elseif self.战斗类型 == 100072 then --秩序白银难度
    难度系数[1] = f函数.读配置(程序目录.."定制难度.ini","定制任务","秩序白银难度气血")
    难度系数[2] = f函数.读配置(程序目录.."定制难度.ini","定制任务","秩序白银难度伤害")
    难度系数[3] = f函数.读配置(程序目录.."定制难度.ini","定制任务","秩序白银难度防御")
    难度系数[4] = f函数.读配置(程序目录.."定制难度.ini","定制任务","秩序白银难度灵力")
    难度系数[5] = f函数.读配置(程序目录.."定制难度.ini","定制任务","秩序白银难度速度")
    难度系数[6] = f函数.读配置(程序目录.."定制难度.ini","定制任务","秩序白银难度法防")
  elseif self.战斗类型 == 100073 then --荣耀黄金难度
    难度系数[1] = f函数.读配置(程序目录.."定制难度.ini","定制任务","荣耀黄金难度气血")
    难度系数[2] = f函数.读配置(程序目录.."定制难度.ini","定制任务","荣耀黄金难度伤害")
    难度系数[3] = f函数.读配置(程序目录.."定制难度.ini","定制任务","荣耀黄金难度防御")
    难度系数[4] = f函数.读配置(程序目录.."定制难度.ini","定制任务","荣耀黄金难度灵力")
    难度系数[5] = f函数.读配置(程序目录.."定制难度.ini","定制任务","荣耀黄金难度速度")
    难度系数[6] = f函数.读配置(程序目录.."定制难度.ini","定制任务","荣耀黄金难度法防")
  elseif self.战斗类型 == 100074 then --永恒钻石难度
    难度系数[1] = f函数.读配置(程序目录.."定制难度.ini","定制任务","永恒钻石难度气血")
    难度系数[2] = f函数.读配置(程序目录.."定制难度.ini","定制任务","永恒钻石难度伤害")
    难度系数[3] = f函数.读配置(程序目录.."定制难度.ini","定制任务","永恒钻石难度防御")
    难度系数[4] = f函数.读配置(程序目录.."定制难度.ini","定制任务","永恒钻石难度灵力")
    难度系数[5] = f函数.读配置(程序目录.."定制难度.ini","定制任务","永恒钻石难度速度")
    难度系数[6] = f函数.读配置(程序目录.."定制难度.ini","定制任务","永恒钻石难度法防")
  elseif self.战斗类型 == 100075 then --至尊星耀难度
    难度系数[1] = f函数.读配置(程序目录.."定制难度.ini","定制任务","至尊星耀难度气血")
    难度系数[2] = f函数.读配置(程序目录.."定制难度.ini","定制任务","至尊星耀难度伤害")
    难度系数[3] = f函数.读配置(程序目录.."定制难度.ini","定制任务","至尊星耀难度防御")
    难度系数[4] = f函数.读配置(程序目录.."定制难度.ini","定制任务","至尊星耀难度灵力")
    难度系数[5] = f函数.读配置(程序目录.."定制难度.ini","定制任务","至尊星耀难度速度")
    难度系数[6] = f函数.读配置(程序目录.."定制难度.ini","定制任务","至尊星耀难度法防")
  elseif self.战斗类型 == 100076 then --最强王者难度
    难度系数[1] = f函数.读配置(程序目录.."定制难度.ini","定制任务","最强王者难度气血")
    难度系数[2] = f函数.读配置(程序目录.."定制难度.ini","定制任务","最强王者难度伤害")
    难度系数[3] = f函数.读配置(程序目录.."定制难度.ini","定制任务","最强王者难度防御")
    难度系数[4] = f函数.读配置(程序目录.."定制难度.ini","定制任务","最强王者难度灵力")
    难度系数[5] = f函数.读配置(程序目录.."定制难度.ini","定制任务","最强王者难度速度")
    难度系数[6] = f函数.读配置(程序目录.."定制难度.ini","定制任务","最强王者难度法防")
  elseif self.战斗类型 == 100077 then --梦幻粉难度
    难度系数[1] = f函数.读配置(程序目录.."定制难度.ini","定制任务","梦幻粉难度气血")
    难度系数[2] = f函数.读配置(程序目录.."定制难度.ini","定制任务","梦幻粉难度伤害")
    难度系数[3] = f函数.读配置(程序目录.."定制难度.ini","定制任务","梦幻粉难度防御")
    难度系数[4] = f函数.读配置(程序目录.."定制难度.ini","定制任务","梦幻粉难度灵力")
    难度系数[5] = f函数.读配置(程序目录.."定制难度.ini","定制任务","梦幻粉难度速度")
    难度系数[6] = f函数.读配置(程序目录.."定制难度.ini","定制任务","梦幻粉难度法防")
  elseif self.战斗类型 == 100078 then --蚩尤元神难度
   if 任务数据[任务id].等级==60 then
      难度系数[1] = f函数.读配置(程序目录.."定制难度.ini","定制任务","60蚩尤元神难度气血")
      难度系数[2] = f函数.读配置(程序目录.."定制难度.ini","定制任务","60蚩尤元神难度伤害")
      难度系数[3] = f函数.读配置(程序目录.."定制难度.ini","定制任务","60蚩尤元神难度防御")
      难度系数[4] = f函数.读配置(程序目录.."定制难度.ini","定制任务","60蚩尤元神难度灵力")
      难度系数[5] = f函数.读配置(程序目录.."定制难度.ini","定制任务","60蚩尤元神难度速度")
      难度系数[6] = f函数.读配置(程序目录.."定制难度.ini","定制任务","60蚩尤元神难度法防")
    elseif 任务数据[任务id].等级==100 then
      难度系数[1] = f函数.读配置(程序目录.."定制难度.ini","定制任务","100蚩尤元神难度气血")
      难度系数[2] = f函数.读配置(程序目录.."定制难度.ini","定制任务","100蚩尤元神难度伤害")
      难度系数[3] = f函数.读配置(程序目录.."定制难度.ini","定制任务","100蚩尤元神难度防御")
      难度系数[4] = f函数.读配置(程序目录.."定制难度.ini","定制任务","100蚩尤元神难度灵力")
      难度系数[5] = f函数.读配置(程序目录.."定制难度.ini","定制任务","100蚩尤元神难度速度")
      难度系数[6] = f函数.读配置(程序目录.."定制难度.ini","定制任务","100蚩尤元神难度法防")
    else
      难度系数[1] = f函数.读配置(程序目录.."定制难度.ini","定制任务","150蚩尤元神难度气血")
      难度系数[2] = f函数.读配置(程序目录.."定制难度.ini","定制任务","150蚩尤元神难度伤害")
      难度系数[3] = f函数.读配置(程序目录.."定制难度.ini","定制任务","150蚩尤元神难度防御")
      难度系数[4] = f函数.读配置(程序目录.."定制难度.ini","定制任务","150蚩尤元神难度灵力")
      难度系数[5] = f函数.读配置(程序目录.."定制难度.ini","定制任务","150蚩尤元神难度速度")
      难度系数[6] = f函数.读配置(程序目录.."定制难度.ini","定制任务","150蚩尤元神难度法防")
    end
  elseif self.战斗类型 == 100079 then --子鼠难度
    难度系数[1] = f函数.读配置(程序目录.."定制难度.ini","定制任务","子鼠难度气血")
    难度系数[2] = f函数.读配置(程序目录.."定制难度.ini","定制任务","子鼠难度伤害")
    难度系数[3] = f函数.读配置(程序目录.."定制难度.ini","定制任务","子鼠难度防御")
    难度系数[4] = f函数.读配置(程序目录.."定制难度.ini","定制任务","子鼠难度灵力")
    难度系数[5] = f函数.读配置(程序目录.."定制难度.ini","定制任务","子鼠难度速度")
    难度系数[6] = f函数.读配置(程序目录.."定制难度.ini","定制任务","子鼠难度法防")
  elseif self.战斗类型 == 100080 then --狮子座难度
    难度系数[1] = f函数.读配置(程序目录.."定制难度.ini","定制任务","狮子座难度气血")
    难度系数[2] = f函数.读配置(程序目录.."定制难度.ini","定制任务","狮子座难度伤害")
    难度系数[3] = f函数.读配置(程序目录.."定制难度.ini","定制任务","狮子座难度防御")
    难度系数[4] = f函数.读配置(程序目录.."定制难度.ini","定制任务","狮子座难度灵力")
    难度系数[5] = f函数.读配置(程序目录.."定制难度.ini","定制任务","狮子座难度速度")
    难度系数[6] = f函数.读配置(程序目录.."定制难度.ini","定制任务","狮子座难度法防")
  elseif self.战斗类型 == 100081 then --处女座难度
    难度系数[1] = f函数.读配置(程序目录.."定制难度.ini","定制任务","处女座难度气血")
    难度系数[2] = f函数.读配置(程序目录.."定制难度.ini","定制任务","处女座难度伤害")
    难度系数[3] = f函数.读配置(程序目录.."定制难度.ini","定制任务","处女座难度防御")
    难度系数[4] = f函数.读配置(程序目录.."定制难度.ini","定制任务","处女座难度灵力")
    难度系数[5] = f函数.读配置(程序目录.."定制难度.ini","定制任务","处女座难度速度")
    难度系数[6] = f函数.读配置(程序目录.."定制难度.ini","定制任务","处女座难度法防")
  elseif self.战斗类型 == 100082 then --天秤座难度
    难度系数[1] = f函数.读配置(程序目录.."定制难度.ini","定制任务","天秤座难度气血")
    难度系数[2] = f函数.读配置(程序目录.."定制难度.ini","定制任务","天秤座难度伤害")
    难度系数[3] = f函数.读配置(程序目录.."定制难度.ini","定制任务","天秤座难度防御")
    难度系数[4] = f函数.读配置(程序目录.."定制难度.ini","定制任务","天秤座难度灵力")
    难度系数[5] = f函数.读配置(程序目录.."定制难度.ini","定制任务","天秤座难度速度")
    难度系数[6] = f函数.读配置(程序目录.."定制难度.ini","定制任务","天秤座难度法防")
  elseif self.战斗类型 == 100083 then --丑牛难度
    难度系数[1] = f函数.读配置(程序目录.."定制难度.ini","定制任务","丑牛难度气血")
    难度系数[2] = f函数.读配置(程序目录.."定制难度.ini","定制任务","丑牛难度伤害")
    难度系数[3] = f函数.读配置(程序目录.."定制难度.ini","定制任务","丑牛难度防御")
    难度系数[4] = f函数.读配置(程序目录.."定制难度.ini","定制任务","丑牛难度灵力")
    难度系数[5] = f函数.读配置(程序目录.."定制难度.ini","定制任务","丑牛难度速度")
    难度系数[6] = f函数.读配置(程序目录.."定制难度.ini","定制任务","丑牛难度法防")
  elseif self.战斗类型 == 100084 then --散财童子难度
    难度系数[1] = f函数.读配置(程序目录.."定制难度.ini","常规任务","散财童子难度气血")
    难度系数[2] = f函数.读配置(程序目录.."定制难度.ini","常规任务","散财童子难度伤害")
    难度系数[3] = f函数.读配置(程序目录.."定制难度.ini","常规任务","散财童子难度防御")
    难度系数[4] = f函数.读配置(程序目录.."定制难度.ini","常规任务","散财童子难度灵力")
    难度系数[5] = f函数.读配置(程序目录.."定制难度.ini","常规任务","散财童子难度速度")
    难度系数[6] = f函数.读配置(程序目录.."定制难度.ini","常规任务","散财童子难度法防")
  elseif self.战斗类型 == 100085 then --神秘妖怪难度
    难度系数[1] = f函数.读配置(程序目录.."定制难度.ini","常规任务","神秘妖怪难度气血")
    难度系数[2] = f函数.读配置(程序目录.."定制难度.ini","常规任务","神秘妖怪难度伤害")
    难度系数[3] = f函数.读配置(程序目录.."定制难度.ini","常规任务","神秘妖怪难度防御")
    难度系数[4] = f函数.读配置(程序目录.."定制难度.ini","常规任务","神秘妖怪难度灵力")
    难度系数[5] = f函数.读配置(程序目录.."定制难度.ini","常规任务","神秘妖怪难度速度")
    难度系数[6] = f函数.读配置(程序目录.."定制难度.ini","常规任务","神秘妖怪难度法防")
  elseif self.战斗类型 == 100086 then --妄空曰天冷难度
    难度系数[1] = f函数.读配置(程序目录.."定制难度.ini","常规任务","妄空曰天冷难度气血")
    难度系数[2] = f函数.读配置(程序目录.."定制难度.ini","常规任务","妄空曰天冷难度伤害")
    难度系数[3] = f函数.读配置(程序目录.."定制难度.ini","常规任务","妄空曰天冷难度防御")
    难度系数[4] = f函数.读配置(程序目录.."定制难度.ini","常规任务","妄空曰天冷难度灵力")
    难度系数[5] = f函数.读配置(程序目录.."定制难度.ini","常规任务","妄空曰天冷难度速度")
    难度系数[6] = f函数.读配置(程序目录.."定制难度.ini","常规任务","妄空曰天冷难度法防")
  elseif self.战斗类型 == 100087 or self.战斗类型 == 100089 then --妄空曰天冷2难度
    难度系数[1] = f函数.读配置(程序目录.."定制难度.ini","常规任务","妄空曰天冷2难度气血")
    难度系数[2] = f函数.读配置(程序目录.."定制难度.ini","常规任务","妄空曰天冷2难度伤害")
    难度系数[3] = f函数.读配置(程序目录.."定制难度.ini","常规任务","妄空曰天冷2难度防御")
    难度系数[4] = f函数.读配置(程序目录.."定制难度.ini","常规任务","妄空曰天冷2难度灵力")
    难度系数[5] = f函数.读配置(程序目录.."定制难度.ini","常规任务","妄空曰天冷2难度速度")
    难度系数[6] = f函数.读配置(程序目录.."定制难度.ini","常规任务","妄空曰天冷2难度法防")
  elseif self.战斗类型 == 100088 then --渡劫师傅难度
    难度系数[1] = f函数.读配置(程序目录.."定制难度.ini","常规任务","渡劫师傅难度气血")
    难度系数[2] = f函数.读配置(程序目录.."定制难度.ini","常规任务","渡劫师傅难度伤害")
    难度系数[3] = f函数.读配置(程序目录.."定制难度.ini","常规任务","渡劫师傅难度防御")
    难度系数[4] = f函数.读配置(程序目录.."定制难度.ini","常规任务","渡劫师傅难度灵力")
    难度系数[5] = f函数.读配置(程序目录.."定制难度.ini","常规任务","渡劫师傅难度速度")
    难度系数[6] = f函数.读配置(程序目录.."定制难度.ini","常规任务","渡劫师傅难度法防")
  elseif self.战斗类型 == 100090 then --蚩尤幻影难度
    难度系数[1] = f函数.读配置(程序目录.."定制难度.ini","常规任务","蚩尤幻影难度气血")
    难度系数[2] = f函数.读配置(程序目录.."定制难度.ini","常规任务","蚩尤幻影难度伤害")
    难度系数[3] = f函数.读配置(程序目录.."定制难度.ini","常规任务","蚩尤幻影难度防御")
    难度系数[4] = f函数.读配置(程序目录.."定制难度.ini","常规任务","蚩尤幻影难度灵力")
    难度系数[5] = f函数.读配置(程序目录.."定制难度.ini","常规任务","蚩尤幻影难度速度")
    难度系数[6] = f函数.读配置(程序目录.."定制难度.ini","常规任务","蚩尤幻影难度法防")
  elseif self.战斗类型 == 100091 then --神秘钥匙怪难度
    难度系数[1] = f函数.读配置(程序目录.."定制难度.ini","定制任务","神秘钥匙怪难度气血")
    难度系数[2] = f函数.读配置(程序目录.."定制难度.ini","定制任务","神秘钥匙怪难度伤害")
    难度系数[3] = f函数.读配置(程序目录.."定制难度.ini","定制任务","神秘钥匙怪难度防御")
    难度系数[4] = f函数.读配置(程序目录.."定制难度.ini","定制任务","神秘钥匙怪难度灵力")
    难度系数[5] = f函数.读配置(程序目录.."定制难度.ini","定制任务","神秘钥匙怪难度速度")
    难度系数[6] = f函数.读配置(程序目录.."定制难度.ini","定制任务","神秘钥匙怪难度法防")
  elseif self.战斗类型 == 100092 then --寅虎难度
    难度系数[1] = f函数.读配置(程序目录.."定制难度.ini","定制任务","寅虎难度气血")
    难度系数[2] = f函数.读配置(程序目录.."定制难度.ini","定制任务","寅虎难度伤害")
    难度系数[3] = f函数.读配置(程序目录.."定制难度.ini","定制任务","寅虎难度防御")
    难度系数[4] = f函数.读配置(程序目录.."定制难度.ini","定制任务","寅虎难度灵力")
    难度系数[5] = f函数.读配置(程序目录.."定制难度.ini","定制任务","寅虎难度速度")
    难度系数[6] = f函数.读配置(程序目录.."定制难度.ini","定制任务","寅虎难度法防")
  elseif self.战斗类型 == 100093 then --怒天魇难度
    难度系数[1] = f函数.读配置(程序目录.."定制难度.ini","定制任务","怒天魇难度气血")
    难度系数[2] = f函数.读配置(程序目录.."定制难度.ini","定制任务","怒天魇难度伤害")
    难度系数[3] = f函数.读配置(程序目录.."定制难度.ini","定制任务","怒天魇难度防御")
    难度系数[4] = f函数.读配置(程序目录.."定制难度.ini","定制任务","怒天魇难度灵力")
    难度系数[5] = f函数.读配置(程序目录.."定制难度.ini","定制任务","怒天魇难度速度")
    难度系数[6] = f函数.读配置(程序目录.."定制难度.ini","定制任务","怒天魇难度法防")
  elseif self.战斗类型 == 100094 then --叛军难度
    难度系数[1] = f函数.读配置(程序目录.."定制难度.ini","定制任务","叛军难度气血")
    难度系数[2] = f函数.读配置(程序目录.."定制难度.ini","定制任务","叛军难度伤害")
    难度系数[3] = f函数.读配置(程序目录.."定制难度.ini","定制任务","叛军难度防御")
    难度系数[4] = f函数.读配置(程序目录.."定制难度.ini","定制任务","叛军难度灵力")
    难度系数[5] = f函数.读配置(程序目录.."定制难度.ini","定制任务","叛军难度速度")
    难度系数[6] = f函数.读配置(程序目录.."定制难度.ini","定制任务","叛军难度法防")
  elseif self.战斗类型 == 100095 then
    难度系数[1] = f函数.读配置(程序目录.."定制难度.ini","定制任务","变强就点我难度气血")
    难度系数[2] = f函数.读配置(程序目录.."定制难度.ini","定制任务","变强就点我难度伤害")
    难度系数[3] = f函数.读配置(程序目录.."定制难度.ini","定制任务","变强就点我难度防御")
    难度系数[4] = f函数.读配置(程序目录.."定制难度.ini","定制任务","变强就点我难度灵力")
    难度系数[5] = f函数.读配置(程序目录.."定制难度.ini","定制任务","变强就点我难度速度")
    难度系数[6] = f函数.读配置(程序目录.."定制难度.ini","定制任务","变强就点我难度法防")
  elseif self.战斗类型 == 100096 then
    难度系数[1] = f函数.读配置(程序目录.."定制难度.ini","定制任务","不屈将魂难度气血")
    难度系数[2] = f函数.读配置(程序目录.."定制难度.ini","定制任务","不屈将魂难度伤害")
    难度系数[3] = f函数.读配置(程序目录.."定制难度.ini","定制任务","不屈将魂难度防御")
    难度系数[4] = f函数.读配置(程序目录.."定制难度.ini","定制任务","不屈将魂难度灵力")
    难度系数[5] = f函数.读配置(程序目录.."定制难度.ini","定制任务","不屈将魂难度速度")
    难度系数[6] = f函数.读配置(程序目录.."定制难度.ini","定制任务","不屈将魂难度法防")
  elseif self.战斗类型 == 100097 then
    难度系数[1] = f函数.读配置(程序目录.."定制难度.ini","定制任务","马超难度气血")
    难度系数[2] = f函数.读配置(程序目录.."定制难度.ini","定制任务","马超难度伤害")
    难度系数[3] = f函数.读配置(程序目录.."定制难度.ini","定制任务","马超难度防御")
    难度系数[4] = f函数.读配置(程序目录.."定制难度.ini","定制任务","马超难度灵力")
    难度系数[5] = f函数.读配置(程序目录.."定制难度.ini","定制任务","马超难度速度")
    难度系数[6] = f函数.读配置(程序目录.."定制难度.ini","定制任务","马超难度法防")
  elseif self.战斗类型 == 100098 then
    难度系数[1] = f函数.读配置(程序目录.."定制难度.ini","定制任务","黄忠难度气血")
    难度系数[2] = f函数.读配置(程序目录.."定制难度.ini","定制任务","黄忠难度伤害")
    难度系数[3] = f函数.读配置(程序目录.."定制难度.ini","定制任务","黄忠难度防御")
    难度系数[4] = f函数.读配置(程序目录.."定制难度.ini","定制任务","黄忠难度灵力")
    难度系数[5] = f函数.读配置(程序目录.."定制难度.ini","定制任务","黄忠难度速度")
    难度系数[6] = f函数.读配置(程序目录.."定制难度.ini","定制任务","黄忠难度法防")
  elseif self.战斗类型 == 100099 then
    难度系数[1] = f函数.读配置(程序目录.."定制难度.ini","定制任务","张飞难度气血")
    难度系数[2] = f函数.读配置(程序目录.."定制难度.ini","定制任务","张飞难度伤害")
    难度系数[3] = f函数.读配置(程序目录.."定制难度.ini","定制任务","张飞难度防御")
    难度系数[4] = f函数.读配置(程序目录.."定制难度.ini","定制任务","张飞难度灵力")
    难度系数[5] = f函数.读配置(程序目录.."定制难度.ini","定制任务","张飞难度速度")
    难度系数[6] = f函数.读配置(程序目录.."定制难度.ini","定制任务","张飞难度法防")
  elseif self.战斗类型 == 100100 then
    难度系数[1] = f函数.读配置(程序目录.."定制难度.ini","定制任务","关羽难度气血")
    难度系数[2] = f函数.读配置(程序目录.."定制难度.ini","定制任务","关羽难度伤害")
    难度系数[3] = f函数.读配置(程序目录.."定制难度.ini","定制任务","关羽难度防御")
    难度系数[4] = f函数.读配置(程序目录.."定制难度.ini","定制任务","关羽难度灵力")
    难度系数[5] = f函数.读配置(程序目录.."定制难度.ini","定制任务","关羽难度速度")
    难度系数[6] = f函数.读配置(程序目录.."定制难度.ini","定制任务","关羽难度法防")
  elseif self.战斗类型 == 100101 then
    难度系数[1] = f函数.读配置(程序目录.."定制难度.ini","定制任务","赵云难度气血")
    难度系数[2] = f函数.读配置(程序目录.."定制难度.ini","定制任务","赵云难度伤害")
    难度系数[3] = f函数.读配置(程序目录.."定制难度.ini","定制任务","赵云难度防御")
    难度系数[4] = f函数.读配置(程序目录.."定制难度.ini","定制任务","赵云难度灵力")
    难度系数[5] = f函数.读配置(程序目录.."定制难度.ini","定制任务","赵云难度速度")
    难度系数[6] = f函数.读配置(程序目录.."定制难度.ini","定制任务","赵云难度法防")
  elseif self.战斗类型 == 100102 then
    难度系数[1] = f函数.读配置(程序目录.."定制难度.ini","定制任务","魔化沙僧难度气血")
    难度系数[2] = f函数.读配置(程序目录.."定制难度.ini","定制任务","魔化沙僧难度伤害")
    难度系数[3] = f函数.读配置(程序目录.."定制难度.ini","定制任务","魔化沙僧难度防御")
    难度系数[4] = f函数.读配置(程序目录.."定制难度.ini","定制任务","魔化沙僧难度灵力")
    难度系数[5] = f函数.读配置(程序目录.."定制难度.ini","定制任务","魔化沙僧难度速度")
    难度系数[6] = f函数.读配置(程序目录.."定制难度.ini","定制任务","魔化沙僧难度法防")
  elseif self.战斗类型 == 100103 then
    难度系数[1] = f函数.读配置(程序目录.."定制难度.ini","定制任务","魔化孙悟空难度气血")
    难度系数[2] = f函数.读配置(程序目录.."定制难度.ini","定制任务","魔化孙悟空难度伤害")
    难度系数[3] = f函数.读配置(程序目录.."定制难度.ini","定制任务","魔化孙悟空难度防御")
    难度系数[4] = f函数.读配置(程序目录.."定制难度.ini","定制任务","魔化孙悟空难度灵力")
    难度系数[5] = f函数.读配置(程序目录.."定制难度.ini","定制任务","魔化孙悟空难度速度")
    难度系数[6] = f函数.读配置(程序目录.."定制难度.ini","定制任务","魔化孙悟空难度法防")
  elseif self.战斗类型 == 100104 then
    if 任务数据[任务id].难度 == 1 then
      难度系数[1] = f函数.读配置(程序目录.."定制难度.ini","定制任务","七十二地煞星1气血")
      难度系数[2] = f函数.读配置(程序目录.."定制难度.ini","定制任务","七十二地煞星1伤害")
      难度系数[3] = f函数.读配置(程序目录.."定制难度.ini","定制任务","七十二地煞星1防御")
      难度系数[4] = f函数.读配置(程序目录.."定制难度.ini","定制任务","七十二地煞星1灵力")
      难度系数[5] = f函数.读配置(程序目录.."定制难度.ini","定制任务","七十二地煞星1速度")
      难度系数[6] = f函数.读配置(程序目录.."定制难度.ini","定制任务","七十二地煞星1法防")
    elseif 任务数据[任务id].难度 == 2 then
      难度系数[1] = f函数.读配置(程序目录.."定制难度.ini","定制任务","七十二地煞星2气血")
      难度系数[2] = f函数.读配置(程序目录.."定制难度.ini","定制任务","七十二地煞星2伤害")
      难度系数[3] = f函数.读配置(程序目录.."定制难度.ini","定制任务","七十二地煞星2防御")
      难度系数[4] = f函数.读配置(程序目录.."定制难度.ini","定制任务","七十二地煞星2灵力")
      难度系数[5] = f函数.读配置(程序目录.."定制难度.ini","定制任务","七十二地煞星2速度")
      难度系数[6] = f函数.读配置(程序目录.."定制难度.ini","定制任务","七十二地煞星2法防")
    elseif 任务数据[任务id].难度 == 3 then
      难度系数[1] = f函数.读配置(程序目录.."定制难度.ini","定制任务","七十二地煞星3气血")
      难度系数[2] = f函数.读配置(程序目录.."定制难度.ini","定制任务","七十二地煞星3伤害")
      难度系数[3] = f函数.读配置(程序目录.."定制难度.ini","定制任务","七十二地煞星3防御")
      难度系数[4] = f函数.读配置(程序目录.."定制难度.ini","定制任务","七十二地煞星3灵力")
      难度系数[5] = f函数.读配置(程序目录.."定制难度.ini","定制任务","七十二地煞星3速度")
      难度系数[6] = f函数.读配置(程序目录.."定制难度.ini","定制任务","七十二地煞星3法防")
    elseif 任务数据[任务id].难度 == 4 then
      难度系数[1] = f函数.读配置(程序目录.."定制难度.ini","定制任务","七十二地煞星4气血")
      难度系数[2] = f函数.读配置(程序目录.."定制难度.ini","定制任务","七十二地煞星4伤害")
      难度系数[3] = f函数.读配置(程序目录.."定制难度.ini","定制任务","七十二地煞星4防御")
      难度系数[4] = f函数.读配置(程序目录.."定制难度.ini","定制任务","七十二地煞星4灵力")
      难度系数[5] = f函数.读配置(程序目录.."定制难度.ini","定制任务","七十二地煞星4速度")
      难度系数[6] = f函数.读配置(程序目录.."定制难度.ini","定制任务","七十二地煞星4法防")
    elseif 任务数据[任务id].难度 == 5 then
      难度系数[1] = f函数.读配置(程序目录.."定制难度.ini","定制任务","七十二地煞星5气血")
      难度系数[2] = f函数.读配置(程序目录.."定制难度.ini","定制任务","七十二地煞星5伤害")
      难度系数[3] = f函数.读配置(程序目录.."定制难度.ini","定制任务","七十二地煞星5防御")
      难度系数[4] = f函数.读配置(程序目录.."定制难度.ini","定制任务","七十二地煞星5灵力")
      难度系数[5] = f函数.读配置(程序目录.."定制难度.ini","定制任务","七十二地煞星5速度")
      难度系数[6] = f函数.读配置(程序目录.."定制难度.ini","定制任务","七十二地煞星5法防")
    elseif 任务数据[任务id].难度 == 6 then
      难度系数[1] = f函数.读配置(程序目录.."定制难度.ini","定制任务","七十二地煞星6气血")
      难度系数[2] = f函数.读配置(程序目录.."定制难度.ini","定制任务","七十二地煞星6伤害")
      难度系数[3] = f函数.读配置(程序目录.."定制难度.ini","定制任务","七十二地煞星6防御")
      难度系数[4] = f函数.读配置(程序目录.."定制难度.ini","定制任务","七十二地煞星6灵力")
      难度系数[5] = f函数.读配置(程序目录.."定制难度.ini","定制任务","七十二地煞星6速度")
      难度系数[6] = f函数.读配置(程序目录.."定制难度.ini","定制任务","七十二地煞星6法防")
    elseif 任务数据[任务id].难度 == 7 then
      难度系数[1] = f函数.读配置(程序目录.."定制难度.ini","定制任务","七十二地煞星7气血")
      难度系数[2] = f函数.读配置(程序目录.."定制难度.ini","定制任务","七十二地煞星7伤害")
      难度系数[3] = f函数.读配置(程序目录.."定制难度.ini","定制任务","七十二地煞星7防御")
      难度系数[4] = f函数.读配置(程序目录.."定制难度.ini","定制任务","七十二地煞星7灵力")
      难度系数[5] = f函数.读配置(程序目录.."定制难度.ini","定制任务","七十二地煞星7速度")
      难度系数[6] = f函数.读配置(程序目录.."定制难度.ini","定制任务","七十二地煞星7法防")
    elseif 任务数据[任务id].难度 == 8 then
      难度系数[1] = f函数.读配置(程序目录.."定制难度.ini","定制任务","七十二地煞星8气血")
      难度系数[2] = f函数.读配置(程序目录.."定制难度.ini","定制任务","七十二地煞星8伤害")
      难度系数[3] = f函数.读配置(程序目录.."定制难度.ini","定制任务","七十二地煞星8防御")
      难度系数[4] = f函数.读配置(程序目录.."定制难度.ini","定制任务","七十二地煞星8灵力")
      难度系数[5] = f函数.读配置(程序目录.."定制难度.ini","定制任务","七十二地煞星8速度")
      难度系数[6] = f函数.读配置(程序目录.."定制难度.ini","定制任务","七十二地煞星8法防")
    elseif 任务数据[任务id].难度 == 9 then
      难度系数[1] = f函数.读配置(程序目录.."定制难度.ini","定制任务","七十二地煞星9气血")
      难度系数[2] = f函数.读配置(程序目录.."定制难度.ini","定制任务","七十二地煞星9伤害")
      难度系数[3] = f函数.读配置(程序目录.."定制难度.ini","定制任务","七十二地煞星9防御")
      难度系数[4] = f函数.读配置(程序目录.."定制难度.ini","定制任务","七十二地煞星9灵力")
      难度系数[5] = f函数.读配置(程序目录.."定制难度.ini","定制任务","七十二地煞星9速度")
      难度系数[6] = f函数.读配置(程序目录.."定制难度.ini","定制任务","七十二地煞星9法防")
    elseif 任务数据[任务id].难度 == 10 then
      难度系数[1] = f函数.读配置(程序目录.."定制难度.ini","定制任务","七十二地煞星10气血")
      难度系数[2] = f函数.读配置(程序目录.."定制难度.ini","定制任务","七十二地煞星10伤害")
      难度系数[3] = f函数.读配置(程序目录.."定制难度.ini","定制任务","七十二地煞星10防御")
      难度系数[4] = f函数.读配置(程序目录.."定制难度.ini","定制任务","七十二地煞星10灵力")
      难度系数[5] = f函数.读配置(程序目录.."定制难度.ini","定制任务","七十二地煞星10速度")
      难度系数[6] = f函数.读配置(程序目录.."定制难度.ini","定制任务","七十二地煞星10法防")
    elseif 任务数据[任务id].难度 == 11 then
      难度系数[1] = f函数.读配置(程序目录.."定制难度.ini","定制任务","七十二地煞星11气血")
      难度系数[2] = f函数.读配置(程序目录.."定制难度.ini","定制任务","七十二地煞星11伤害")
      难度系数[3] = f函数.读配置(程序目录.."定制难度.ini","定制任务","七十二地煞星11防御")
      难度系数[4] = f函数.读配置(程序目录.."定制难度.ini","定制任务","七十二地煞星11灵力")
      难度系数[5] = f函数.读配置(程序目录.."定制难度.ini","定制任务","七十二地煞星11速度")
      难度系数[6] = f函数.读配置(程序目录.."定制难度.ini","定制任务","七十二地煞星11法防")
    elseif 任务数据[任务id].难度 == 12 then
      难度系数[1] = f函数.读配置(程序目录.."定制难度.ini","定制任务","七十二地煞星12气血")
      难度系数[2] = f函数.读配置(程序目录.."定制难度.ini","定制任务","七十二地煞星12伤害")
      难度系数[3] = f函数.读配置(程序目录.."定制难度.ini","定制任务","七十二地煞星12防御")
      难度系数[4] = f函数.读配置(程序目录.."定制难度.ini","定制任务","七十二地煞星12灵力")
      难度系数[5] = f函数.读配置(程序目录.."定制难度.ini","定制任务","七十二地煞星12速度")
      难度系数[6] = f函数.读配置(程序目录.."定制难度.ini","定制任务","七十二地煞星12法防")
    elseif 任务数据[任务id].难度 == 13 then
      难度系数[1] = f函数.读配置(程序目录.."定制难度.ini","定制任务","七十二地煞星13气血")
      难度系数[2] = f函数.读配置(程序目录.."定制难度.ini","定制任务","七十二地煞星13伤害")
      难度系数[3] = f函数.读配置(程序目录.."定制难度.ini","定制任务","七十二地煞星13防御")
      难度系数[4] = f函数.读配置(程序目录.."定制难度.ini","定制任务","七十二地煞星13灵力")
      难度系数[5] = f函数.读配置(程序目录.."定制难度.ini","定制任务","七十二地煞星13速度")
      难度系数[6] = f函数.读配置(程序目录.."定制难度.ini","定制任务","七十二地煞星13法防")
    end
  elseif self.战斗类型 == 100105 then
    难度系数[1] = f函数.读配置(程序目录.."定制难度.ini","定制任务","福利宝箱怪气血")
    难度系数[2] = f函数.读配置(程序目录.."定制难度.ini","定制任务","福利宝箱怪伤害")
    难度系数[3] = f函数.读配置(程序目录.."定制难度.ini","定制任务","福利宝箱怪防御")
    难度系数[4] = f函数.读配置(程序目录.."定制难度.ini","定制任务","福利宝箱怪灵力")
    难度系数[5] = f函数.读配置(程序目录.."定制难度.ini","定制任务","福利宝箱怪速度")
    难度系数[6] = f函数.读配置(程序目录.."定制难度.ini","定制任务","福利宝箱怪法防")
  elseif self.战斗类型 == 100106 then
    难度系数[1] = f函数.读配置(程序目录.."定制难度.ini","定制任务","倾国倾城气血")
    难度系数[2] = f函数.读配置(程序目录.."定制难度.ini","定制任务","倾国倾城伤害")
    难度系数[3] = f函数.读配置(程序目录.."定制难度.ini","定制任务","倾国倾城防御")
    难度系数[4] = f函数.读配置(程序目录.."定制难度.ini","定制任务","倾国倾城灵力")
    难度系数[5] = f函数.读配置(程序目录.."定制难度.ini","定制任务","倾国倾城速度")
    难度系数[6] = f函数.读配置(程序目录.."定制难度.ini","定制任务","倾国倾城法防")
  elseif self.战斗类型 == 100107 then
    难度系数[1] = f函数.读配置(程序目录.."定制难度.ini","定制任务","美食专家气血")
    难度系数[2] = f函数.读配置(程序目录.."定制难度.ini","定制任务","美食专家伤害")
    难度系数[3] = f函数.读配置(程序目录.."定制难度.ini","定制任务","美食专家防御")
    难度系数[4] = f函数.读配置(程序目录.."定制难度.ini","定制任务","美食专家灵力")
    难度系数[5] = f函数.读配置(程序目录.."定制难度.ini","定制任务","美食专家速度")
    难度系数[6] = f函数.读配置(程序目录.."定制难度.ini","定制任务","美食专家法防")
  elseif self.战斗类型 == 100108 then
    难度系数[1] = f函数.读配置(程序目录.."定制难度.ini","常规任务","通天塔气血")
    难度系数[2] = f函数.读配置(程序目录.."定制难度.ini","常规任务","通天塔伤害")
    难度系数[3] = f函数.读配置(程序目录.."定制难度.ini","常规任务","通天塔防御")
    难度系数[4] = f函数.读配置(程序目录.."定制难度.ini","常规任务","通天塔灵力")
    难度系数[5] = f函数.读配置(程序目录.."定制难度.ini","常规任务","通天塔速度")
    难度系数[6] = f函数.读配置(程序目录.."定制难度.ini","常规任务","通天塔法防")
  elseif self.战斗类型 == 100109 then
    难度系数[1] = f函数.读配置(程序目录.."定制难度.ini","定制任务","贼王的线索气血")
    难度系数[2] = f函数.读配置(程序目录.."定制难度.ini","定制任务","贼王的线索伤害")
    难度系数[3] = f函数.读配置(程序目录.."定制难度.ini","定制任务","贼王的线索防御")
    难度系数[4] = f函数.读配置(程序目录.."定制难度.ini","定制任务","贼王的线索灵力")
    难度系数[5] = f函数.读配置(程序目录.."定制难度.ini","定制任务","贼王的线索速度")
    难度系数[6] = f函数.读配置(程序目录.."定制难度.ini","定制任务","贼王的线索法防")
  elseif self.战斗类型 == 100110 then
    难度系数[1] = f函数.读配置(程序目录.."定制难度.ini","定制任务","貔貅气血")
    难度系数[2] = f函数.读配置(程序目录.."定制难度.ini","定制任务","貔貅伤害")
    难度系数[3] = f函数.读配置(程序目录.."定制难度.ini","定制任务","貔貅防御")
    难度系数[4] = f函数.读配置(程序目录.."定制难度.ini","定制任务","貔貅灵力")
    难度系数[5] = f函数.读配置(程序目录.."定制难度.ini","定制任务","貔貅速度")
    难度系数[6] = f函数.读配置(程序目录.."定制难度.ini","定制任务","貔貅法防")
  elseif self.战斗类型 == 100111 then --卯兔难度
    难度系数[1] = f函数.读配置(程序目录.."定制难度.ini","定制任务","卯兔难度气血")
    难度系数[2] = f函数.读配置(程序目录.."定制难度.ini","定制任务","卯兔难度伤害")
    难度系数[3] = f函数.读配置(程序目录.."定制难度.ini","定制任务","卯兔难度防御")
    难度系数[4] = f函数.读配置(程序目录.."定制难度.ini","定制任务","卯兔难度灵力")
    难度系数[5] = f函数.读配置(程序目录.."定制难度.ini","定制任务","卯兔难度速度")
    难度系数[6] = f函数.读配置(程序目录.."定制难度.ini","定制任务","卯兔难度法防")
  elseif self.战斗类型 == 100112 then --水陆桃木虫
    难度系数[1] = f函数.读配置(程序目录.."定制难度.ini","常规任务","水陆桃木虫气血")
    难度系数[2] = f函数.读配置(程序目录.."定制难度.ini","常规任务","水陆桃木虫伤害")
    难度系数[3] = f函数.读配置(程序目录.."定制难度.ini","常规任务","水陆桃木虫防御")
    难度系数[4] = f函数.读配置(程序目录.."定制难度.ini","常规任务","水陆桃木虫灵力")
    难度系数[5] = f函数.读配置(程序目录.."定制难度.ini","常规任务","水陆桃木虫速度")
    难度系数[6] = f函数.读配置(程序目录.."定制难度.ini","常规任务","水陆桃木虫法防")
  elseif self.战斗类型 == 100113 then --水陆泼猴
    难度系数[1] = f函数.读配置(程序目录.."定制难度.ini","常规任务","水陆泼猴气血")
    难度系数[2] = f函数.读配置(程序目录.."定制难度.ini","常规任务","水陆泼猴伤害")
    难度系数[3] = f函数.读配置(程序目录.."定制难度.ini","常规任务","水陆泼猴防御")
    难度系数[4] = f函数.读配置(程序目录.."定制难度.ini","常规任务","水陆泼猴灵力")
    难度系数[5] = f函数.读配置(程序目录.."定制难度.ini","常规任务","水陆泼猴速度")
    难度系数[6] = f函数.读配置(程序目录.."定制难度.ini","常规任务","水陆泼猴法防")
  elseif self.战斗类型 == 100116 then --水陆翼虎
    难度系数[1] = f函数.读配置(程序目录.."定制难度.ini","常规任务","水陆翼虎气血")
    难度系数[2] = f函数.读配置(程序目录.."定制难度.ini","常规任务","水陆翼虎伤害")
    难度系数[3] = f函数.读配置(程序目录.."定制难度.ini","常规任务","水陆翼虎防御")
    难度系数[4] = f函数.读配置(程序目录.."定制难度.ini","常规任务","水陆翼虎灵力")
    难度系数[5] = f函数.读配置(程序目录.."定制难度.ini","常规任务","水陆翼虎速度")
    难度系数[6] = f函数.读配置(程序目录.."定制难度.ini","常规任务","水陆翼虎法防")
  elseif self.战斗类型 == 100117 then --水陆蝰蛇
    难度系数[1] = f函数.读配置(程序目录.."定制难度.ini","常规任务","水陆蝰蛇气血")
    难度系数[2] = f函数.读配置(程序目录.."定制难度.ini","常规任务","水陆蝰蛇伤害")
    难度系数[3] = f函数.读配置(程序目录.."定制难度.ini","常规任务","水陆蝰蛇防御")
    难度系数[4] = f函数.读配置(程序目录.."定制难度.ini","常规任务","水陆蝰蛇灵力")
    难度系数[5] = f函数.读配置(程序目录.."定制难度.ini","常规任务","水陆蝰蛇速度")
    难度系数[6] = f函数.读配置(程序目录.."定制难度.ini","常规任务","水陆蝰蛇法防")
  elseif self.战斗类型 == 100118 then --水陆三怪
    if 任务数据[任务id].名称=="巡山小妖" then
      难度系数[1] = f函数.读配置(程序目录.."定制难度.ini","常规任务","水陆巡山小妖气血")
      难度系数[2] = f函数.读配置(程序目录.."定制难度.ini","常规任务","水陆巡山小妖伤害")
      难度系数[3] = f函数.读配置(程序目录.."定制难度.ini","常规任务","水陆巡山小妖防御")
      难度系数[4] = f函数.读配置(程序目录.."定制难度.ini","常规任务","水陆巡山小妖灵力")
      难度系数[5] = f函数.读配置(程序目录.."定制难度.ini","常规任务","水陆巡山小妖速度")
      难度系数[6] = f函数.读配置(程序目录.."定制难度.ini","常规任务","水陆巡山小妖法防")
    elseif 任务数据[任务id].名称=="上古妖兽头领" then
      难度系数[1] = f函数.读配置(程序目录.."定制难度.ini","常规任务","水陆上古妖兽头领气血")
      难度系数[2] = f函数.读配置(程序目录.."定制难度.ini","常规任务","水陆上古妖兽头领伤害")
      难度系数[3] = f函数.读配置(程序目录.."定制难度.ini","常规任务","水陆上古妖兽头领防御")
      难度系数[4] = f函数.读配置(程序目录.."定制难度.ini","常规任务","水陆上古妖兽头领灵力")
      难度系数[5] = f函数.读配置(程序目录.."定制难度.ini","常规任务","水陆上古妖兽头领速度")
      难度系数[6] = f函数.读配置(程序目录.."定制难度.ini","常规任务","水陆上古妖兽头领法防")
    elseif 任务数据[任务id].名称=="妖将军" then
      难度系数[1] = f函数.读配置(程序目录.."定制难度.ini","常规任务","水陆妖将军气血")
      难度系数[2] = f函数.读配置(程序目录.."定制难度.ini","常规任务","水陆妖将军伤害")
      难度系数[3] = f函数.读配置(程序目录.."定制难度.ini","常规任务","水陆妖将军防御")
      难度系数[4] = f函数.读配置(程序目录.."定制难度.ini","常规任务","水陆妖将军灵力")
      难度系数[5] = f函数.读配置(程序目录.."定制难度.ini","常规任务","水陆妖将军速度")
      难度系数[6] = f函数.读配置(程序目录.."定制难度.ini","常规任务","水陆妖将军法防")
    else
      难度系数[1] = f函数.读配置(程序目录.."定制难度.ini","常规任务","水陆魑魅魍魉气血")
      难度系数[2] = f函数.读配置(程序目录.."定制难度.ini","常规任务","水陆魑魅魍魉伤害")
      难度系数[3] = f函数.读配置(程序目录.."定制难度.ini","常规任务","水陆魑魅魍魉防御")
      难度系数[4] = f函数.读配置(程序目录.."定制难度.ini","常规任务","水陆魑魅魍魉灵力")
      难度系数[5] = f函数.读配置(程序目录.."定制难度.ini","常规任务","水陆魑魅魍魉速度")
      难度系数[6] = f函数.读配置(程序目录.."定制难度.ini","常规任务","水陆魑魅魍魉法防")
    end
  elseif self.战斗类型 == 100119 then --水陆毒虫
    难度系数[1] = f函数.读配置(程序目录.."定制难度.ini","常规任务","水陆毒虫气血")
    难度系数[2] = f函数.读配置(程序目录.."定制难度.ini","常规任务","水陆毒虫伤害")
    难度系数[3] = f函数.读配置(程序目录.."定制难度.ini","常规任务","水陆毒虫防御")
    难度系数[4] = f函数.读配置(程序目录.."定制难度.ini","常规任务","水陆毒虫灵力")
    难度系数[5] = f函数.读配置(程序目录.."定制难度.ini","常规任务","水陆毒虫速度")
    难度系数[6] = f函数.读配置(程序目录.."定制难度.ini","常规任务","水陆毒虫法防")
  elseif self.战斗类型 == 100121 then --魔域魔兵
    难度系数[1] = f函数.读配置(程序目录.."定制难度.ini","定制任务","魔域魔兵气血")
    难度系数[2] = f函数.读配置(程序目录.."定制难度.ini","定制任务","魔域魔兵伤害")
    难度系数[3] = f函数.读配置(程序目录.."定制难度.ini","定制任务","魔域魔兵防御")
    难度系数[4] = f函数.读配置(程序目录.."定制难度.ini","定制任务","魔域魔兵灵力")
    难度系数[5] = f函数.读配置(程序目录.."定制难度.ini","定制任务","魔域魔兵速度")
    难度系数[6] = f函数.读配置(程序目录.."定制难度.ini","定制任务","魔域魔兵法防")
  elseif self.战斗类型 == 100122 then --捣乱的年兽
    难度系数[1] = f函数.读配置(程序目录.."定制难度.ini","定制任务","捣乱的年兽气血")
    难度系数[2] = f函数.读配置(程序目录.."定制难度.ini","定制任务","捣乱的年兽伤害")
    难度系数[3] = f函数.读配置(程序目录.."定制难度.ini","定制任务","捣乱的年兽防御")
    难度系数[4] = f函数.读配置(程序目录.."定制难度.ini","定制任务","捣乱的年兽灵力")
    难度系数[5] = f函数.读配置(程序目录.."定制难度.ini","定制任务","捣乱的年兽速度")
    难度系数[6] = f函数.读配置(程序目录.."定制难度.ini","定制任务","捣乱的年兽法防")
  elseif self.战斗类型 == 100123 then --年兽王
    难度系数[1] = f函数.读配置(程序目录.."定制难度.ini","定制任务","年兽王气血")
    难度系数[2] = f函数.读配置(程序目录.."定制难度.ini","定制任务","年兽王伤害")
    难度系数[3] = f函数.读配置(程序目录.."定制难度.ini","定制任务","年兽王防御")
    难度系数[4] = f函数.读配置(程序目录.."定制难度.ini","定制任务","年兽王灵力")
    难度系数[5] = f函数.读配置(程序目录.."定制难度.ini","定制任务","年兽王速度")
    难度系数[6] = f函数.读配置(程序目录.."定制难度.ini","定制任务","年兽王法防")
  elseif self.战斗类型 == 100124 then --邪恶年兽
    难度系数[1] = f函数.读配置(程序目录.."定制难度.ini","定制任务","邪恶年兽气血")
    难度系数[2] = f函数.读配置(程序目录.."定制难度.ini","定制任务","邪恶年兽伤害")
    难度系数[3] = f函数.读配置(程序目录.."定制难度.ini","定制任务","邪恶年兽防御")
    难度系数[4] = f函数.读配置(程序目录.."定制难度.ini","定制任务","邪恶年兽灵力")
    难度系数[5] = f函数.读配置(程序目录.."定制难度.ini","定制任务","邪恶年兽速度")
    难度系数[6] = f函数.读配置(程序目录.."定制难度.ini","定制任务","邪恶年兽法防")
  end
  if 难度系数[1] == nil or 难度系数[1] == "空" or  tonumber(难度系数[1]) == nil or 难度系数[1] == "" then
    难度系数[1] = 1
  end
  if 难度系数[2] == nil or 难度系数[1] == "空" or  tonumber(难度系数[2]) == nil or 难度系数[1] == "" then
    难度系数[2] = 1
  end
  if 难度系数[3] == nil or 难度系数[1] == "空" or  tonumber(难度系数[3]) == nil or 难度系数[1] == "" then
    难度系数[3] = 1
  end
  if 难度系数[4] == nil or 难度系数[1] == "空" or  tonumber(难度系数[4]) == nil or 难度系数[1] == "" then
    难度系数[4] = 1
  end
  if 难度系数[5] == nil or 难度系数[1] == "空" or  tonumber(难度系数[5]) == nil or 难度系数[1] == "" then
    难度系数[5] = 1
  end
  if 难度系数[6] == nil or 难度系数[1] == "空" or  tonumber(难度系数[6]) == nil or 难度系数[1] == "" then
    难度系数[6] = 1
  end
  return 难度系数
end


function 战斗处理类:加载指定单位(单位组,任务id)
  local 难度系数 = self:取难度系数(任务id)
  local 临时气血 = 难度系数[1]
  local 临时伤害 = 难度系数[2]
  local 临时防御 = 难度系数[3]
  local 临时灵力 = 难度系数[4]
  local 临时速度 = 难度系数[5]
  local 临时法防 = 难度系数[6]
  for n=1,#单位组 do
    self.参战单位[#self.参战单位+1]={}
    self.参战单位[#self.参战单位].名称=单位组[n].名称
    self.参战单位[#self.参战单位].模型=单位组[n].模型
    self.参战单位[#self.参战单位].等级=单位组[n].等级
    self.参战单位[#self.参战单位].变异=单位组[n].变异
    self.参战单位[#self.参战单位].捉鬼变异=单位组[n].捉鬼变异
    self.参战单位[#self.参战单位].队伍=0
    self.参战单位[#self.参战单位].位置=n
    self.参战单位[#self.参战单位].真实编号=#self.参战单位
    self.参战单位[#self.参战单位].类型="bb"
    self.参战单位[#self.参战单位].法防=单位组[n].法防*服务端参数.难度*临时法防
    self.参战单位[#self.参战单位].武器=单位组[n].武器
    self.参战单位[#self.参战单位].染色方案=单位组[n].染色方案
    self.参战单位[#self.参战单位].染色组=单位组[n].染色组
    self.参战单位[#self.参战单位].锦衣=单位组[n].锦衣
    self.参战单位[#self.参战单位].武器染色方案=单位组[n].武器染色方案
    self.参战单位[#self.参战单位].武器染色组=单位组[n].武器染色组
    self.参战单位[#self.参战单位].行走开关=单位组[n].行走开关
    self.参战单位[#self.参战单位].玩家id=0
    self.参战单位[#self.参战单位].分类="野怪"
    self.参战单位[#self.参战单位].附加阵法=单位组[1].附加阵法 or "普通"
    self.参战单位[#self.参战单位].伤害=单位组[n].伤害*服务端参数.难度*临时伤害
    self.参战单位[#self.参战单位].命中=单位组[n].伤害*服务端参数.难度
    self.参战单位[#self.参战单位].防御=单位组[n].防御*服务端参数.难度*临时防御
    self.参战单位[#self.参战单位].速度=单位组[n].速度*服务端参数.难度*临时速度
    self.参战单位[#self.参战单位].灵力=单位组[n].灵力*服务端参数.难度*临时灵力
    self.参战单位[#self.参战单位].躲闪=单位组[n].躲闪*服务端参数.难度
    self.参战单位[#self.参战单位].气血=math.floor(单位组[n].气血*服务端参数.难度*临时气血)
    self.参战单位[#self.参战单位].最大气血=math.floor(单位组[n].气血*服务端参数.难度*临时气血)
    self.参战单位[#self.参战单位].魔法=单位组[n].魔法
    self.参战单位[#self.参战单位].愤怒=单位组[n].愤怒
    self.参战单位[#self.参战单位].最大魔法=单位组[n].魔法
    self.参战单位[#self.参战单位].技能=单位组[n].技能
    self.参战单位[#self.参战单位].物伤减少=单位组[n].物伤减少
    self.参战单位[#self.参战单位].法伤减少=单位组[n].法伤减少
    self.参战单位[#self.参战单位].躲避减少=单位组[n].躲避减少
    self.参战单位[#self.参战单位].不可封印=单位组[n].不可封印
    if self.参战单位[#self.参战单位].捉鬼变异 then
      self.战斗发言数据[#self.战斗发言数据+1]={id=#self.参战单位,内容="其实我内心是很善良得，你们可千万不要错杀好鬼呀#52"}
    end
    if self.参战单位[#self.参战单位].名称=="灵感分身" then
      self.战斗发言数据[#self.战斗发言数据+1]={id=#self.参战单位,内容="别以为你们人多，看我分身大法"}
    end
    self.参战单位[#self.参战单位].主动技能={}
    if 单位组[n].角色 then
      self.参战单位[#self.参战单位].类型="系统角色"
    end
    if self.战斗类型==100005 then
      if 单位组[n].变异 then
        self.参战单位[#self.参战单位].分类="变异"
      else
        self.参战单位[#self.参战单位].分类="宝宝"
      end
    elseif self.战斗类型==100018 then
      self.参战单位[#self.参战单位].乾坤袋=true
    end
    for i=1,#单位组[n].主动技能 do
      self.参战单位[#self.参战单位].主动技能[i]={名称=单位组[n].主动技能[i],等级=单位组[n].等级+10}
    end
    self.参战单位[#self.参战单位].已加技能={}
    self:设置队伍区分(0)
    -- self.参战单位[#self.参战单位].伤害=1
  end
end

function 战斗处理类:取阵法克制(攻击方,挨打方)
  local 攻击阵法 = self.参战单位[攻击方].附加阵法
  local 挨打阵法 = self.参战单位[挨打方].附加阵法
  local 阵法克制 = 0
  if 挨打阵法 == "普通" then
    if 攻击阵法 == "普通" then
      阵法克制 = 0
    elseif 攻击阵法 == "天覆阵" then
      阵法克制 = 0.05
    elseif 攻击阵法 == "地载阵" then
      阵法克制 = -0.05
    elseif 攻击阵法 == "风扬阵" then
      阵法克制 = 0.05
    elseif 攻击阵法 == "云垂阵" then
      阵法克制 = -0.05
    elseif 攻击阵法 == "龙飞阵" then
      阵法克制 = 0.05
    elseif 攻击阵法 == "虎翼阵" then
      阵法克制 = -0.05
    elseif 攻击阵法 == "鸟翔阵" then
      阵法克制 = 0.05
    elseif 攻击阵法 == "蛇蟠阵" then
      阵法克制 = -0.05
    elseif 攻击阵法 == "鹰啸阵" then
      阵法克制 = 0.05
    elseif 攻击阵法 == "雷绝阵" then
      阵法克制 = -0.05
    end
  elseif 挨打阵法 == "天覆阵" then
    if 攻击阵法 == "普通" then
      阵法克制 = -0.05
    elseif 攻击阵法 == "天覆阵" then
      阵法克制 = 0
    elseif 攻击阵法 == "地载阵" then
      阵法克制 = -0.1
    elseif 攻击阵法 == "风扬阵" then
      阵法克制 = 0.1
    elseif 攻击阵法 == "云垂阵" then
      阵法克制 = 0.05
    elseif 攻击阵法 == "龙飞阵" then
      阵法克制 = -0.1
    elseif 攻击阵法 == "虎翼阵" then
      阵法克制 = 0.05
    elseif 攻击阵法 == "鸟翔阵" then
      阵法克制 = -0.05
    elseif 攻击阵法 == "蛇蟠阵" then
      阵法克制 = 0.1
    elseif 攻击阵法 == "鹰啸阵" then
      阵法克制 = -0.05
    elseif 攻击阵法 == "雷绝阵" then
      阵法克制 = 0.05
    end
  elseif 挨打阵法 == "地载阵" then
    if 攻击阵法 == "普通" then
      阵法克制 = 0.05
    elseif 攻击阵法 == "天覆阵" then
      阵法克制 = 0.1
    elseif 攻击阵法 == "地载阵" then
      阵法克制 = 0
    elseif 攻击阵法 == "风扬阵" then
      阵法克制 = -0.1
    elseif 攻击阵法 == "云垂阵" then
      阵法克制 = -0.05
    elseif 攻击阵法 == "龙飞阵" then
      阵法克制 = 0.05
    elseif 攻击阵法 == "虎翼阵" then
      阵法克制 = -0.1
    elseif 攻击阵法 == "鸟翔阵" then
      阵法克制 = 0.1
    elseif 攻击阵法 == "蛇蟠阵" then
      阵法克制 = -0.05
    elseif 攻击阵法 == "鹰啸阵" then
      阵法克制 = 0.1
    elseif 攻击阵法 == "雷绝阵" then
      阵法克制 = -0.1
    end
  elseif 挨打阵法 == "风扬阵" then
    if 攻击阵法 == "普通" then
      阵法克制 = -0.05
    elseif 攻击阵法 == "天覆阵" then
      阵法克制 = -0.1
    elseif 攻击阵法 == "地载阵" then
      阵法克制 = 0.1
    elseif 攻击阵法 == "风扬阵" then
      阵法克制 = 0
    elseif 攻击阵法 == "云垂阵" then
      阵法克制 = 0.05
    elseif 攻击阵法 == "龙飞阵" then
      阵法克制 = 0.05
    elseif 攻击阵法 == "虎翼阵" then
      阵法克制 = 0.1
    elseif 攻击阵法 == "鸟翔阵" then
      阵法克制 = -0.1
    elseif 攻击阵法 == "蛇蟠阵" then
      阵法克制 = -0.05
    elseif 攻击阵法 == "鹰啸阵" then
      阵法克制 = -0.1
    elseif 攻击阵法 == "雷绝阵" then
      阵法克制 = 0.1
    end
  elseif 挨打阵法 == "云垂阵" then
    if 攻击阵法 == "普通" then
      阵法克制 = 0.05
    elseif 攻击阵法 == "天覆阵" then
      阵法克制 = -0.05
    elseif 攻击阵法 == "地载阵" then
      阵法克制 = 0.05
    elseif 攻击阵法 == "风扬阵" then
      阵法克制 = -0.05
    elseif 攻击阵法 == "云垂阵" then
      阵法克制 = 0
    elseif 攻击阵法 == "龙飞阵" then
      阵法克制 = 0.1
    elseif 攻击阵法 == "虎翼阵" then
      阵法克制 = 0.1
    elseif 攻击阵法 == "鸟翔阵" then
      阵法克制 = -0.1
    elseif 攻击阵法 == "蛇蟠阵" then
      阵法克制 = -0.1
    elseif 攻击阵法 == "鹰啸阵" then
      阵法克制 = -0.1
    elseif 攻击阵法 == "雷绝阵" then
      阵法克制 = 0.1
    end
  elseif 挨打阵法 == "龙飞阵" then
    if 攻击阵法 == "普通" then
      阵法克制 = -0.05
    elseif 攻击阵法 == "天覆阵" then
      阵法克制 = 0.1
    elseif 攻击阵法 == "地载阵" then
      阵法克制 = -0.05
    elseif 攻击阵法 == "风扬阵" then
      阵法克制 = -0.05
    elseif 攻击阵法 == "云垂阵" then
      阵法克制 = -0.1
    elseif 攻击阵法 == "龙飞阵" then
      阵法克制 = 0
    elseif 攻击阵法 == "虎翼阵" then
      阵法克制 = 0.05
    elseif 攻击阵法 == "鸟翔阵" then
      阵法克制 = 0.05
    elseif 攻击阵法 == "蛇蟠阵" then
      阵法克制 = 0.05
    elseif 攻击阵法 == "鹰啸阵" then
      阵法克制 = 0.1
    elseif 攻击阵法 == "雷绝阵" then
      阵法克制 = -0.1
    end
  elseif 挨打阵法 == "虎翼阵" then
    if 攻击阵法 == "普通" then
      阵法克制 = 0.05
    elseif 攻击阵法 == "天覆阵" then
      阵法克制 = -0.05
    elseif 攻击阵法 == "地载阵" then
      阵法克制 = 0.1
    elseif 攻击阵法 == "风扬阵" then
      阵法克制 = -0.1
    elseif 攻击阵法 == "云垂阵" then
      阵法克制 = -0.1
    elseif 攻击阵法 == "龙飞阵" then
      阵法克制 = -0.05
    elseif 攻击阵法 == "虎翼阵" then
      阵法克制 = 0
    elseif 攻击阵法 == "鸟翔阵" then
      阵法克制 = 0.1
    elseif 攻击阵法 == "蛇蟠阵" then
      阵法克制 = 0.05
    elseif 攻击阵法 == "鹰啸阵" then
      阵法克制 = 0.05
    elseif 攻击阵法 == "雷绝阵" then
      阵法克制 = -0.05
    end
  elseif 挨打阵法 == "鸟翔阵" then
    if 攻击阵法 == "普通" then
      阵法克制 = -0.05
    elseif 攻击阵法 == "天覆阵" then
      阵法克制 = 0.05
    elseif 攻击阵法 == "地载阵" then
      阵法克制 = -0.1
    elseif 攻击阵法 == "风扬阵" then
      阵法克制 = 0.1
    elseif 攻击阵法 == "云垂阵" then
      阵法克制 = 0.1
    elseif 攻击阵法 == "龙飞阵" then
      阵法克制 = -0.05
    elseif 攻击阵法 == "虎翼阵" then
      阵法克制 = -0.1
    elseif 攻击阵法 == "鸟翔阵" then
      阵法克制 = 0
    elseif 攻击阵法 == "蛇蟠阵" then
      阵法克制 = 0.05
    elseif 攻击阵法 == "鹰啸阵" then
      阵法克制 = -0.05
    elseif 攻击阵法 == "雷绝阵" then
      阵法克制 = 0.05
    end
  elseif 挨打阵法 == "蛇蟠阵" then
    if 攻击阵法 == "普通" then
      阵法克制 = 0.05
    elseif 攻击阵法 == "天覆阵" then
      阵法克制 = -0.1
    elseif 攻击阵法 == "地载阵" then
      阵法克制 = 0.05
    elseif 攻击阵法 == "风扬阵" then
      阵法克制 = 0.05
    elseif 攻击阵法 == "云垂阵" then
      阵法克制 = 0.1
    elseif 攻击阵法 == "龙飞阵" then
      阵法克制 = -0.05
    elseif 攻击阵法 == "虎翼阵" then
      阵法克制 = -0.05
    elseif 攻击阵法 == "鸟翔阵" then
      阵法克制 = -0.05
    elseif 攻击阵法 == "蛇蟠阵" then
      阵法克制 = 0
    elseif 攻击阵法 == "鹰啸阵" then
      阵法克制 = 0.05
    elseif 攻击阵法 == "雷绝阵" then
      阵法克制 = -0.05
    end
  elseif 挨打阵法 == "鹰啸阵" then
    if 攻击阵法 == "普通" then
      阵法克制 = -0.05
    elseif 攻击阵法 == "天覆阵" then
      阵法克制 = 0.05
    elseif 攻击阵法 == "地载阵" then
      阵法克制 = -0.1
    elseif 攻击阵法 == "风扬阵" then
      阵法克制 = 0.1
    elseif 攻击阵法 == "云垂阵" then
      阵法克制 = 0.1
    elseif 攻击阵法 == "龙飞阵" then
      阵法克制 = -0.1
    elseif 攻击阵法 == "虎翼阵" then
      阵法克制 = -0.05
    elseif 攻击阵法 == "鸟翔阵" then
      阵法克制 = 0.05
    elseif 攻击阵法 == "蛇蟠阵" then
      阵法克制 = -0.05
    elseif 攻击阵法 == "鹰啸阵" then
      阵法克制 = 0
    elseif 攻击阵法 == "雷绝阵" then
      阵法克制 = -0.05
    end
  elseif 挨打阵法 == "雷绝阵" then
    if 攻击阵法 == "普通" then
      阵法克制 = 0.05
    elseif 攻击阵法 == "天覆阵" then
      阵法克制 = -0.05
    elseif 攻击阵法 == "地载阵" then
      阵法克制 = 0.1
    elseif 攻击阵法 == "风扬阵" then
      阵法克制 = -0.1
    elseif 攻击阵法 == "云垂阵" then
      阵法克制 = -0.1
    elseif 攻击阵法 == "龙飞阵" then
      阵法克制 = 0.1
    elseif 攻击阵法 == "虎翼阵" then
      阵法克制 = 0.05
    elseif 攻击阵法 == "鸟翔阵" then
      阵法克制 = -0.05
    elseif 攻击阵法 == "蛇蟠阵" then
      阵法克制 = 0.05
    elseif 攻击阵法 == "鹰啸阵" then
      阵法克制 = -0.05
    elseif 攻击阵法 == "雷绝阵" then
      阵法克制 = 0
    end
  end
  return 阵法克制
  -- body
end

function 战斗处理类:加载野外单位()
  local 加载数量=0
  if 玩家数据[self.发起id].队伍==0 then
    加载数量=取随机数(2,3)
  else
    local 队伍数量=#队伍数据[玩家数据[self.发起id].队伍].成员数据
    加载数量=取随机数(队伍数量+1,队伍数量*2+1)
    if 加载数量>10 then
      加载数量=10
    end
  end
  --加载数量=10
  local 临时信息=取野怪(self.战斗地图)
  local 队伍id=0
  local 临时等级=0
  local 临时等级1=0
  临时等级,临时等级1=取场景等级(self.战斗地图)
  self.等级上限=临时等级1
  self.等级下限=临时等级
  self.地图等级=qz((self.等级下限+self.等级上限)/2)
  self.精灵数量=0
  self.头领数量=0
  self.敌人数量=加载数量
  --加载数量=10
  for n=1,加载数量 do
    local 临时野怪=取敌人信息(临时信息[取随机数(1,#临时信息)])
    self.地图等级=取随机数(self.等级上限-5,self.等级上限)--新加
    self.生成等级= self.地图等级
    self.临时等级=取随机数(self.等级下限,self.等级上限)
    local 变异=false
    if 取随机数(1,1000)<=5 then 变异=true end
    local 宝宝=false
    if 取随机数(1,1000)<=10 then 宝宝=true end
    if 变异 or 宝宝 then
      self.临时等级=0
      self.生成等级=1
    end
    self.参战单位[#self.参战单位+1]={}
    self.参战单位[#self.参战单位].名称=临时野怪[2]
    if 变异 then
      self.参战单位[#self.参战单位].名称="变异"..临时野怪[2]
    end
    self.参战单位[#self.参战单位].模型=临时野怪[2]
    self.参战单位[#self.参战单位].等级=self.临时等级
    self.参战单位[#self.参战单位].参战等级=临时野怪[3]
    self.参战单位[#self.参战单位].队伍=队伍id
    self.参战单位[#self.参战单位].位置=n
    self.参战单位[#self.参战单位].变异=变异
    self.参战单位[#self.参战单位].类型="bb"
    self.参战单位[#self.参战单位].法防=math.floor(self.生成等级 * 2.5)-- 0.5) --调用08伤害数据
    self.参战单位[#self.参战单位].玩家id=0
    self.参战单位[#self.参战单位].分类="野怪"
    self.参战单位[#self.参战单位].附加阵法="普通"
    self.参战单位[#self.参战单位].伤害=math.floor(self.生成等级* 6.8)--4.8)
    self.参战单位[#self.参战单位].命中=self.参战单位[#self.参战单位].伤害
    self.参战单位[#self.参战单位].防御=math.floor(self.生成等级*2.5)
    self.参战单位[#self.参战单位].速度=math.floor(self.生成等级*1.5)
    self.参战单位[#self.参战单位].灵力=math.floor(self.生成等级* 4.85)--0.8)
    self.参战单位[#self.参战单位].躲闪=math.floor(self.生成等级*1.5)
    self.参战单位[#self.参战单位].气血=math.floor(self.生成等级* 17.5) + 10--17.5)--08是12.5
    self.参战单位[#self.参战单位].最大气血=math.floor(self.生成等级* 17.5) + 10--17.5)
    self.参战单位[#self.参战单位].魔法=math.floor(self.生成等级*7.5)+10
    self.参战单位[#self.参战单位].最大魔法=math.floor(self.生成等级*7.5)+10
    self.参战单位[#self.参战单位].魔力=self.参战单位[#self.参战单位].参战等级*2
    self.参战单位[#self.参战单位].躲闪=0
    self.参战单位[#self.参战单位].技能={}
    self.参战单位[#self.参战单位].已加技能={}
    if 变异 then
      self.参战单位[#self.参战单位].分类="变异"
      self.战斗发言数据[#self.战斗发言数据+1]={id=#self.参战单位,内容="诶啊..我..我..我什么变态了,不对是换色了,你们别抓我呀!#52"}
    elseif 宝宝 then
      self.参战单位[#self.参战单位].分类="宝宝"
      self.参战单位[#self.参战单位].名称=self.参战单位[#self.参战单位].模型.."宝宝"
      self.战斗发言数据[#self.战斗发言数据+1]={id=#self.参战单位,内容="其实我一个小小的宝宝,你们别抓我呀!#52"}
    end
    --   local 测试技能={"弱点雷","弱点火","弱点水","弱点土","高级水属性吸收","高级火属性吸收","高级雷属性吸收","高级土属性吸收"}
    local 临时技能=临时野怪[14]
    for i=1,#临时技能 do
      if 取随机数()<=45 then
        self.参战单位[#self.参战单位].技能[#self.参战单位[#self.参战单位].技能+1]=临时技能[n]
        if 取随机数()<=30 then
        end
      end
    end
    if self.精灵数量==0 and 取随机数()<=3 then
      self.精灵数量=1
      self.参战单位[#self.参战单位].精灵=true
      self.参战单位[#self.参战单位].不可封印=true
      self.参战单位[#self.参战单位].技能={"自爆"}
      self.参战单位[#self.参战单位].气血= self.参战单位[#self.参战单位].气血*3
      self.参战单位[#self.参战单位].名称=self.参战单位[#self.参战单位].模型.."精灵"
      self.参战单位[#self.参战单位].速度=0
      self.战斗发言数据[#self.战斗发言数据+1]={id=#self.参战单位,内容="我是一只小精灵,小啊小精灵!#52"}
    elseif 变异==false and 宝宝==false and 取随机数()<=20 then
      self.参战单位[#self.参战单位].名称=self.参战单位[#self.参战单位].模型.."头领"
      self.头领数量=self.头领数量+1
      self.参战单位[#self.参战单位].气血=qz(self.参战单位[#self.参战单位].气血* 1.25)
      self.参战单位[#self.参战单位].防御=qz(self.参战单位[#self.参战单位].防御* 1.15)--1.2) --08伤害数据
      self.参战单位[#self.参战单位].伤害=qz(self.参战单位[#self.参战单位].伤害* 1.05)--1.25)
      self.参战单位[#self.参战单位].灵力=qz(self.参战单位[#self.参战单位].灵力* 1.15)--1.25)
    end
    -- self.参战单位[#self.参战单位].技能[#self.参战单位[#self.参战单位].技能+1]="高级神佑复生"
    --self:添加技能属性(self.参战单位[#self.参战单位],self.参战单位[#self.参战单位].技能)
    self:设置队伍区分(队伍id)
  end
end

function 战斗处理类:加载野外单位1()
  local 加载数量=0
  if 玩家数据[self.发起id].队伍==0 then
    加载数量=取随机数(2,3)
  else
    local 队伍数量=#队伍数据[玩家数据[self.发起id].队伍].成员数据
    加载数量=取随机数(队伍数量+1,队伍数量*2+1)
    if 加载数量>10 then
      加载数量=10
    end
  end
  local 临时信息=取野怪(self.战斗地图)
  local 队伍id=0
  local 临时等级=0
  local 临时等级1=0
  临时等级,临时等级1=取场景等级(self.战斗地图)
  self.等级上限=临时等级1
  self.等级下限=临时等级
  self.地图等级=qz((self.等级下限+self.等级上限)/2)
  self.精灵数量=0
  self.头领数量=0
  self.敌人数量=加载数量
  --加载数量=10
  for n=1,加载数量 do
    local 临时野怪=取敌人信息(临时信息[取随机数(1,#临时信息)])
    --local 临时野怪={}
    --临时野怪[2]=临时信息[取随机数(1,#临时信息)]
    if n==1 then
      -- 临时野怪[2]=任务数据[self.任务id].模型
      for i=1,#临时信息 do
        local 序列数据=取敌人信息(临时信息[i])
        if 序列数据[2]==任务数据[self.任务id].模型 then
          临时野怪=取敌人信息(临时信息[i])
        end
      end
    end
    self.地图等级=取随机数(self.等级上限-5,self.等级上限)--新加
    self.生成等级= self.地图等级
    self.临时等级=取随机数(self.等级下限,self.等级上限)
    local 变异=false
    if 取随机数()<=1 then 变异=true end
    local 宝宝=false
    if 取随机数()<=5 then 宝宝=true end
    if 变异 or 宝宝 then
      self.临时等级=0
      self.生成等级=1
    end
    self.参战单位[#self.参战单位+1]={}
    self.参战单位[#self.参战单位].名称=临时野怪[2]
    if 变异 then
      self.参战单位[#self.参战单位].名称="变异"..临时野怪[2]
    end
    self.参战单位[#self.参战单位].模型=临时野怪[2]
    self.参战单位[#self.参战单位].等级=self.临时等级
    self.参战单位[#self.参战单位].队伍=队伍id
    self.参战单位[#self.参战单位].位置=n
    self.参战单位[#self.参战单位].变异=变异
    self.参战单位[#self.参战单位].类型="bb"
    self.参战单位[#self.参战单位].法防=math.floor(self.生成等级 * 2.5)-- 0.5) --调用08伤害数据
    self.参战单位[#self.参战单位].玩家id=0
    self.参战单位[#self.参战单位].分类="野怪"
    self.参战单位[#self.参战单位].附加阵法="普通"
    self.参战单位[#self.参战单位].伤害=math.floor(self.生成等级* 6.8)--4.8)
    self.参战单位[#self.参战单位].命中=self.参战单位[#self.参战单位].伤害
    self.参战单位[#self.参战单位].防御=math.floor(self.生成等级*2.5)
    self.参战单位[#self.参战单位].速度=math.floor(self.生成等级*1.5)
    self.参战单位[#self.参战单位].灵力=math.floor(self.生成等级* 4.85)--0.8)
    self.参战单位[#self.参战单位].躲闪=math.floor(self.生成等级*1.5)
    self.参战单位[#self.参战单位].气血=math.floor(self.生成等级* 17.5) + 10--17.5)--08是12.5
    self.参战单位[#self.参战单位].最大气血=math.floor(self.生成等级* 17.5) + 10--17.5)
    self.参战单位[#self.参战单位].魔法=math.floor(self.生成等级*7.5)+10
    self.参战单位[#self.参战单位].最大魔法=math.floor(self.生成等级*7.5)+10
    self.参战单位[#self.参战单位].躲闪=0
    self.参战单位[#self.参战单位].技能={}
    self.参战单位[#self.参战单位].魔力=self.临时等级*2
    self.参战单位[#self.参战单位].已加技能={}
    if 变异 then
      self.参战单位[#self.参战单位].分类="变异"
      self.战斗发言数据[#self.战斗发言数据+1]={id=#self.参战单位,内容="诶啊..我..我..我什么变态了,不对是换色了,你们别抓我呀!#52"}
    elseif 宝宝 then
      self.参战单位[#self.参战单位].分类="宝宝"
      self.参战单位[#self.参战单位].名称=self.参战单位[#self.参战单位].模型.."宝宝"
      self.战斗发言数据[#self.战斗发言数据+1]={id=#self.参战单位,内容="其实我一个小小的宝宝,你们别抓我呀!#52"}
    end
    --   local 测试技能={"弱点雷","弱点火","弱点水","弱点土","高级水属性吸收","高级火属性吸收","高级雷属性吸收","高级土属性吸收"}
    local 临时技能=临时野怪[14]
    for i=1,#临时技能 do
      if 取随机数()<=45 then
        self.参战单位[#self.参战单位].技能[#self.参战单位[#self.参战单位].技能+1]=临时技能[n]
        if 取随机数()<=30 then
        end
      end
    end
    if self.精灵数量==0 and 取随机数()<=3 then
      self.精灵数量=1
      self.参战单位[#self.参战单位].精灵=true
      self.参战单位[#self.参战单位].不可封印=true
      self.参战单位[#self.参战单位].技能={"自爆"}
      self.参战单位[#self.参战单位].气血= self.参战单位[#self.参战单位].气血*3
      self.参战单位[#self.参战单位].名称=self.参战单位[#self.参战单位].模型.."精灵"
      self.参战单位[#self.参战单位].速度=0
      self.战斗发言数据[#self.战斗发言数据+1]={id=#self.参战单位,内容="我是一只小精灵,小啊小精灵!#52"}
    elseif 变异==false and 宝宝==false and 取随机数()<=20 then
      self.参战单位[#self.参战单位].名称=self.参战单位[#self.参战单位].模型.."头领"
      self.头领数量=self.头领数量+1
      self.参战单位[#self.参战单位].气血=qz(self.参战单位[#self.参战单位].气血*1.25)
      self.参战单位[#self.参战单位].防御=qz(self.参战单位[#self.参战单位].防御* 1.15)--1.2) --08伤害数据
      self.参战单位[#self.参战单位].伤害=qz(self.参战单位[#self.参战单位].伤害* 1.05)--1.25)
      self.参战单位[#self.参战单位].灵力=qz(self.参战单位[#self.参战单位].灵力* 1.15)--1.25)
    end
    -- self.参战单位[#self.参战单位].技能[#self.参战单位[#self.参战单位].技能+1]="高级神佑复生"
    --self:添加技能属性(self.参战单位[#self.参战单位],self.参战单位[#self.参战单位].技能)
    self:设置队伍区分(队伍id)
  end
end

function 战斗处理类:添加内丹属性(单位,内丹1)
  local 内丹={}
  for n=1,#内丹1 do
     内丹[n]=内丹1[n]
  end
  for i=1,#内丹 do
      local 等级 = 内丹[i].等级
      local 技能 = 内丹[i].技能
      if 技能 == "深思" then
        if self:取技能重复(单位,"高级冥思") then
          单位.冥思 = 等级 *5 + 单位.冥思
        end
      end
      if 技能 == "淬毒" then
        if self:取技能重复(单位,"毒") or self:取技能重复(单位,"高级毒") then
          单位.毒= math.floor(等级 *5 /100)+单位.毒
        end
      end
      if 技能 == "连环" then
        if self:取技能重复(单位,"连击") or self:取技能重复(单位,"高级连击") then
          单位.连击= math.floor(等级 *2 /100)+单位.连击
        end
      end
      if 技能 == "灵光" then
          单位.灵力= math.floor((等级 *30 +单位.魔力/80)*0.7)+单位.灵力
      end
      if 技能 == "舍身击" then
          单位.伤害= math.floor(等级*30+单位.力量/80)+单位.伤害
      end
      if 技能 == "圣洁" then
         if self:取技能重复(单位,"驱鬼") or self:取技能重复(单位,"高级驱鬼") then
          单位.驱鬼= math.floor(等级 *10 /100)+单位.驱鬼
        end
      end
      if 技能 == "狙刺" then
          单位.灵力= math.floor((等级 *35 +单位.等级/3)*0.7)+单位.灵力
      end
      if 技能 == "狂怒" then
          if 单位.狂怒==nil then
              单位.狂怒=0
          end
          单位.狂怒= 等级*80 +单位.狂怒
      end
      if 技能 == "阴伤" then
          if 单位.阴伤==nil then
              单位.阴伤=0
          end
          单位.阴伤= 等级*50 +单位.阴伤
      end
      if 技能 == "擅咒" then
          单位.灵力 = 单位.灵力+ math.floor(单位.灵力 * (等级*2/100))
      end
      if 技能 == "钢化" then
         if  self:取技能重复(单位,"高级防御") or  self:取技能重复(单位,"防御") then
              单位.防御=单位.防御+等级*20
         end
      end
      if 技能 == "生死决" then
        单位.伤害= 单位.伤害 + math.floor(单位.等级*等级/4)
        单位.防御= 单位.防御 + math.floor(单位.等级*等级/6)
      end
      if 技能 == "碎甲刃" then
        单位.伤害= 单位.伤害 + math.floor(单位.等级*(等级-1)/4+50)
      end
      if 技能 == "撞击" then
        单位.伤害= 单位.伤害 + 等级*20
      end
      if 技能 == "催心浪" then
          if 单位.法波 ~= nil and 单位.法波 ~=0 then
              单位.法波=单位.法波 + 等级*2
          end
      end
      if 技能 == "通灵法" then
        单位.灵力 = 单位.灵力+ math.floor(单位.灵力 * (等级*4/100))
      end
      if 技能 == "隐匿击" then
        if  self:取技能重复(单位,"高级隐身") or  self:取技能重复(单位,"隐身") then
         单位.伤害 =  单位.伤害 + math.floor(单位.伤害*(等级*2/100))
        end
      end
      if 技能 == "灵身" then
          单位.灵力 = 单位.灵力+ math.floor(单位.灵力 * (等级*2/100))
      end
      if 技能 == "腾挪劲" then
          单位.防御 = 单位.防御 + 等级*10
      end
      if 技能 == "电魂闪" then
          单位.驱怪 = 1    ----小法
      end
      if 技能 == "坚甲" then
         if self:取技能重复(单位,"高级反震") or  self:取技能重复(单位,"反震") then
              单位.反震=单位.反震+等级*2
         end
      end
      if 技能 == "双星爆" then
         if  self:取技能重复(单位,"高级法术连击") or  self:取技能重复(单位,"法术连击") then
              单位.法连=单位.法连+等级*2
              单位.灵力 =单位.灵力+ math.floor(单位.灵力 * (等级*2/100))
         end
      end
   end
end

function 战斗处理类:添加认证法术属性(单位,技能组)
  for n=1,#技能组 do
    local 名称=技能组[n]
    if 名称=="上古灵符" or 名称=="月光" or 名称=="死亡召唤" or 名称=="水攻" or 名称=="落岩" or 名称=="雷击" or 名称=="烈火" or 名称=="地狱烈火" or 名称=="奔雷咒" or 名称=="水漫金山" or 名称=="泰山压顶" or 名称=="善恶有报" or 名称=="壁垒击破" or 名称=="惊心一剑" or 名称=="夜舞倾城" or 名称=="力劈华山" then
      单位.主动技能[#单位.主动技能+1]={名称=名称,等级=单位.等级}
    end
  end
end

function 战斗处理类:添加技能属性(单位,技能组)
  for n=1,#技能组 do
    local 名称=技能组[n]
    if 名称 =="后发制人" or 名称 =="推拿" or 名称 =="楚楚可怜" or 名称 =="定身符" or 名称 =="天雷斩" or 名称 =="杨柳甘露" or 名称 =="龙卷雨击" or 名称 =="烟雨剑法" or 名称 =="仙人指路" or 名称 =="潜能激发"or 名称 =="还魂咒"  or 名称 =="蚩尤之搏" or 名称 =="黄帝内经" or 名称 =="四面埋伏" or 名称 =="极度疯狂" or 名称 =="三昧真火" or 名称 =="修罗隐身" or 名称 =="勾魂" or 名称=="上古灵符" or 名称=="月光" or 名称=="死亡召唤" or 名称=="法术防御" or 名称=="剑荡四方" or 名称=="天降灵葫" or 名称=="八凶法阵" or 名称=="观照万象" or 名称=="叱咤风云" or 名称=="自爆" or 名称=="水攻" or 名称=="落岩" or 名称=="雷击" or 名称=="烈火" or 名称=="地狱烈火" or 名称=="奔雷咒" or 名称=="水漫金山" or 名称=="泰山压顶" or 名称=="善恶有报" or 名称=="壁垒击破" or 名称=="惊心一剑" or 名称=="夜舞倾城" or 名称=="力劈华山" then
      单位.主动技能[#单位.主动技能+1]={名称=名称,等级=单位.等级}
      if 名称 == "叱咤风云" then
        if 单位.法连 == nil then
          单位.法连=10
        else
          单位.法连=单位.法连+10
        end
      end
    elseif 名称=="浮云神马" then
      self:添加状态(名称,单位)
      self:添加状态(名称,self.参战单位[单位.主人])
    elseif 名称=="龙魂" then
      单位.龙魂=0
    elseif 名称=="千钧一怒" then
      单位.千钧一怒=1
    elseif 名称=="从天而降" then
      单位.从天而降=1
    elseif 名称=="大快朵颐" then
      if 单位.连击 == nil then
        单位.连击=10
      else
        单位.连击=单位.连击+10
      end
      if 单位.必杀 == nil then
        单位.必杀=10
      else
        单位.必杀=单位.必杀+10
      end
    elseif 名称=="反击" or 名称=="高级反击" then
      if 名称=="反击" then
        if self:取技能重复(单位,"高级反击")==false then
          单位.反击=0.5
          单位.已加技能[#单位.已加技能+1]=名称
        end
      else
        单位.反击=1
        单位.已加技能[#单位.已加技能+1]="高级反击"
      end
    elseif 名称=="净台妙谛" then
      单位.最大气血 = 单位.最大气血 + 单位.体质*单位.成长*2
      单位.气血 = 单位.最大气血
      local 血量数据 = {}
      血量数据={气血=单位.气血,最大气血=单位.最大气血,魔法=单位.魔法,最大魔法=单位.最大魔法,愤怒=单位.愤怒}
      发送数据(玩家数据[单位.玩家id].连接id,5517,血量数据)
      单位.已加技能[#单位.已加技能+1]=名称
    elseif 名称=="理直气壮" then
      单位.理直气壮 = 1
      单位.已加技能[#单位.已加技能+1]=名称
    elseif 名称=="灵能激发" then
      单位.法术伤害 = 单位.法术伤害 + 100 + 单位.魔力*0.5
      单位.已加技能[#单位.已加技能+1]=名称
    elseif 名称=="灵山禅语" then
      单位.法术防御 = 单位.法术防御 + 单位.魔力*(单位.成长-0.3)
      单位.已加技能[#单位.已加技能+1]=名称
    elseif 名称=="高级法术抵抗" then
      if 单位.法伤减少==nil then
        单位.法伤减少 = 0.9
      else
          单位.法伤减少 = 单位.法伤减少-0.1
          if 单位.法伤减少 <= 0 then
            单位.法伤减少 = 0.7
          end
      end
      单位.已加技能[#单位.已加技能+1]=名称
    elseif 名称=="驱怪" then
      单位.驱怪=1
    elseif 名称=="苍鸾怒击" then
      单位.怒击效果=true
    elseif 名称=="反震" or 名称=="高级反震" then
      if 名称=="反震" then
        if self:取技能重复(单位,"高级反震")==false then
          单位.反震=0.25
          单位.已加技能[#单位.已加技能+1]=名称
        end
      else
        单位.反震=0.5
        单位.已加技能[#单位.已加技能+1]="高级反震"
      end
    elseif 名称=="吸血" or 名称=="高级吸血" then
      if 名称=="吸血" then
        if self:取技能重复(单位,"高级吸血")==false then
          单位.吸血=0.25
          单位.已加技能[#单位.已加技能+1]=名称
        end
      else
        单位.吸血=0.3
        单位.已加技能[#单位.已加技能+1]="高级吸血"
      end
    elseif 名称=="连击" or 名称=="高级连击" then
      if 名称=="连击" then
        if self:取技能重复(单位,"高级连击")==false then
          if 单位.连击 == nil then
            单位.连击=45
          else
            单位.连击 = 单位.连击 +45
          end
          单位.已加技能[#单位.已加技能+1]=名称
        end
      else
        if 单位.连击 == nil then
          单位.连击=55
        else
          单位.连击 = 单位.连击 +55
        end
        单位.已加技能[#单位.已加技能+1]="高级连击"
      end
    elseif 名称=="飞行" or 名称=="高级飞行" then
      if 名称=="飞行" then
        if self:取技能重复(单位,"高级飞行")==false then
          单位.命中=qz(单位.命中*1.2)
          单位.躲闪=qz(单位.躲闪*1.2)
          单位.暗器伤害=1.3
          单位.已加技能[#单位.已加技能+1]=名称
        end
      else
        单位.命中=qz(单位.命中*1.3)
        单位.躲闪=qz(单位.躲闪*1.3)
        单位.已加技能[#单位.已加技能+1]="高级飞行"
      end
    elseif 名称=="夜战" or 名称=="高级夜战" then
      if 名称=="夜战" then
        if self:取技能重复(单位,"高级夜战")==false then
          单位.夜战=1
          单位.已加技能[#单位.已加技能+1]=名称
        end
      else
        单位.夜战=2
        单位.已加技能[#单位.已加技能+1]="高级夜战"
      end
    elseif 名称=="隐身" or 名称=="高级隐身" then
      if 名称=="隐身" then
        if self:取技能重复(单位,"高级隐身")==false then
          单位.隐身=3
          单位.已加技能[#单位.已加技能+1]=名称
        end
      else
        单位.隐身=4
        单位.已加技能[#单位.已加技能+1]="高级隐身"
      end
    elseif 名称=="感知" or 名称=="高级感知" then
      if 名称=="感知" then
        if self:取技能重复(单位,"高级感知")==false then
          单位.感知=0.45
          单位.已加技能[#单位.已加技能+1]=名称
        end
      else
        单位.感知=0.55
        单位.躲闪=qz(单位.躲闪*1.1)
        单位.已加技能[#单位.已加技能+1]="高级感知"
      end
    elseif 名称=="再生" or 名称=="高级再生" then
      if 名称=="再生" then
        if self:取技能重复(单位,"高级再生")==false then
          单位.再生=qz(单位.等级*0.5)
          单位.已加技能[#单位.已加技能+1]=名称
        end
      else
        单位.再生=单位.等级
        单位.已加技能[#单位.已加技能+1]="高级再生"
      end
    elseif 名称=="冥思" or 名称=="高级冥思" then
      if 名称=="冥思" then
        if self:取技能重复(单位,"高级冥思")==false then
          单位.冥思=qz(单位.等级*0.25)
          单位.已加技能[#单位.已加技能+1]=名称
        end
      else
        单位.冥思=qz(单位.等级*0.5)
        单位.已加技能[#单位.已加技能+1]="高级冥思"
      end
    elseif 名称=="慧根" or 名称=="高级慧根" then
      if 名称=="慧根" then
        if self:取技能重复(单位,"高级慧根")==false then
          单位.慧根=0.75
          单位.已加技能[#单位.已加技能+1]=名称
        end
      else
        单位.慧根=0.5
        单位.已加技能[#单位.已加技能+1]="高级慧根"
      end
    elseif 名称=="必杀" or 名称=="高级必杀" then
      if 名称=="必杀" then
        if self:取技能重复(单位,"高级必杀")==false then
          单位.必杀=单位.必杀+10
          单位.已加技能[#单位.已加技能+1]=名称
        end
      else
        单位.必杀=单位.必杀+20
        单位.已加技能[#单位.已加技能+1]="高级必杀"
      end
    elseif 名称=="幸运" or 名称=="高级幸运" then
      if 名称=="幸运" then
        if self:取技能重复(单位,"高级幸运")==false then
          单位.幸运=1
          单位.已加技能[#单位.已加技能+1]=名称
        end
      else
        单位.幸运=1
        单位.已加技能[#单位.已加技能+1]="高级幸运"
      end
    elseif 名称=="永恒" or 名称=="高级永恒" then
      if 名称=="永恒" then
        if self:取技能重复(单位,"高级永恒")==false then
          单位.永恒=2
          单位.已加技能[#单位.已加技能+1]=名称
        end
      else
        单位.永恒=4
        单位.已加技能[#单位.已加技能+1]="高级永恒"
      end
    elseif 名称=="神迹" or 名称=="高级神迹" then
      if 名称=="神迹" then
        if self:取技能重复(单位,"高级神迹")==false then
          单位.神迹=1
          单位.已加技能[#单位.已加技能+1]=名称
        end
      else
        单位.神迹=2
        单位.已加技能[#单位.已加技能+1]="高级神迹"
      end
    elseif 名称=="招架" or 名称=="高级招架" then
      if 名称=="招架" then
        if self:取技能重复(单位,"高级招架")==false then
          单位.招架=15
          单位.已加技能[#单位.已加技能+1]=名称
        end
      else
        单位.招架=20
        单位.已加技能[#单位.已加技能+1]="高级招架"
      end
    elseif 名称=="偷袭" or 名称=="高级偷袭" then
      if 名称=="偷袭" then
        if self:取技能重复(单位,"高级偷袭")==false then
          单位.偷袭=1
          单位.已加技能[#单位.已加技能+1]=名称
        end
      else
        单位.偷袭=1
        单位.伤害=qz(单位.伤害*1.1)
        单位.已加技能[#单位.已加技能+1]="高级偷袭"
      end
    elseif 名称=="毒" or 名称=="高级毒" then
      if 名称=="毒" then
        if self:取技能重复(单位,"高级毒")==false then
          单位.毒=15
          单位.已加技能[#单位.已加技能+1]=名称
        end
      else
        单位.毒=20
        单位.已加技能[#单位.已加技能+1]="高级毒"
      end
    elseif 名称=="驱鬼" or 名称=="高级驱鬼" then
      if 名称=="驱鬼" then
        if self:取技能重复(单位,"高级驱鬼")==false then
          单位.驱鬼=1.5
          单位.已加技能[#单位.已加技能+1]=名称
        end
      else
        单位.驱鬼=2
        单位.已加技能[#单位.已加技能+1]="高级驱鬼"
      end
    elseif 名称=="鬼魂术" or 名称=="高级鬼魂术" then
      if 名称=="鬼魂术" then
        if self:取技能重复(单位,"高级鬼魂术")==false then
          单位.鬼魂=5
          单位.已加技能[#单位.已加技能+1]=名称
        end
      else
        单位.鬼魂=5
        单位.已加技能[#单位.已加技能+1]="高级鬼魂术"
      end
    elseif 名称=="魔之心" or 名称=="高级魔之心" then
      if 名称=="魔之心" then
        if self:取技能重复(单位,"高级魔之心")==false then
          单位.魔之心=1.1
          单位.已加技能[#单位.已加技能+1]=名称
        end
      else
        单位.魔之心=1.2
        单位.已加技能[#单位.已加技能+1]="高级魔之心"
      end
    elseif 名称=="神佑复生" or 名称=="高级神佑复生" then
      if 名称=="神佑复生" then
        if self:取技能重复(单位,"高级神佑复生")==false then
          单位.神佑=15
          单位.已加技能[#单位.已加技能+1]=名称
        end
      else
        单位.神佑=30
        单位.已加技能[#单位.已加技能+1]="高级神佑复生"
      end
    elseif 名称=="精神集中" or 名称=="高级精神集中" then
      if 名称=="精神集中" then
        if self:取技能重复(单位,"高级精神集中")==false then
          单位.精神=0.75
          单位.伤害=qz(单位.伤害*0.8)
          单位.已加技能[#单位.已加技能+1]=名称
        end
      else
        单位.精神=0.5
        单位.已加技能[#单位.已加技能+1]="高级精神集中"
        单位.伤害=qz(单位.伤害*0.8)
        单位.躲闪=qz(单位.躲闪*1.1)
      end
    elseif 名称=="否定信仰" or 名称=="高级否定信仰" then
      if 名称=="否定信仰" then
        if self:取技能重复(单位,"高级否定信仰")==false then
          单位.信仰=2
          单位.已加技能[#单位.已加技能+1]=名称
        end
      else
        单位.信仰=2
        单位.已加技能[#单位.已加技能+1]="高级否定信仰"
      end
    elseif 名称=="法术暴击" or 名称=="高级法术暴击" then
      if 名称=="法术暴击" then
        if self:取技能重复(单位,"高级法术暴击")==false then
          单位.法暴=15
          单位.已加技能[#单位.已加技能+1]=名称
        end
      else
        单位.法暴=25
        单位.已加技能[#单位.已加技能+1]="高级法术暴击"
      end
    elseif 名称=="法术连击" or 名称=="高级法术连击" then
      if 名称=="法术连击" then
        if self:取技能重复(单位,"高级法术连击")==false then
          单位.法连=35
          单位.已加技能[#单位.已加技能+1]=名称
        end
      else
        单位.法连=45
        单位.已加技能[#单位.已加技能+1]="高级法术连击"
      end
    elseif 名称=="法术波动" or 名称=="高级法术波动" then
      if 名称=="法术波动" then
        if self:取技能重复(单位,"高级法术波动")==false then
          单位.法波=110
          单位.已加技能[#单位.已加技能+1]=名称
        end
      else
        单位.法波=120
        单位.已加技能[#单位.已加技能+1]="高级法术波动"
      end
    elseif 名称=="水属性吸收" or 名称=="高级水属性吸收" then
      if 名称=="水属性吸收" then
        if self:取技能重复(单位,"高级水属性吸收")==false then
          单位.水吸=1
          单位.已加技能[#单位.已加技能+1]=名称
        end
      else
        单位.水吸=2
        单位.已加技能[#单位.已加技能+1]="高级水属性吸收"
      end
    elseif 名称=="开门见山" then
      单位.已加技能[#单位.已加技能+1]=名称
    elseif 名称=="张弛有道" then
      self:添加状态(名称,单位)
    elseif 名称=="峰回路转" then
      单位.已加技能[#单位.已加技能+1]=名称
    elseif 名称=="雷属性吸收" or 名称=="高级雷属性吸收" then
      if 名称=="雷属性吸收" then
        if self:取技能重复(单位,"高级雷属性吸收")==false then
          单位.雷吸=1
          单位.已加技能[#单位.已加技能+1]=名称
        end
      else
        单位.雷吸=2
        单位.已加技能[#单位.已加技能+1]="高级雷属性吸收"
      end
    elseif 名称=="火属性吸收" or 名称=="高级火属性吸收" then
      if 名称=="火属性吸收" then
        if self:取技能重复(单位,"高级火属性吸收")==false then
          单位.火吸=1
          单位.已加技能[#单位.已加技能+1]=名称
        end
      else
        单位.火吸=2
        单位.已加技能[#单位.已加技能+1]="高级火属性吸收"
      end
    elseif 名称=="土属性吸收" or 名称=="高级土属性吸收" then
      if 名称=="土属性吸收" then
        if self:取技能重复(单位,"高级土属性吸收")==false then
          单位.土吸=1
          单位.已加技能[#单位.已加技能+1]=名称
        end
      else
        单位.土吸=2
        单位.已加技能[#单位.已加技能+1]="高级土属性吸收"
      end
    elseif 名称=="弱点雷"  then
      单位.弱点雷=1
    elseif 名称=="弱点火"  then
      单位.弱点火=1
    elseif 名称=="弱点水"  then
      单位.弱点水=1
    elseif 名称=="弱点土"  then
      单位.弱点土=1
    elseif 名称=="嗜血追击"  then
      单位.嗜血追击=1
    elseif 名称 == "须弥真言" then
      单位.灵力 = 单位.灵力 + qz(单位.魔力*0.4)
    end
  end
end

function 战斗处理类:取技能重复(单位,技能)
  for n=1,#单位.已加技能 do
    if 单位.已加技能[n]==技能 then return true end
  end
  return false
end

function 战斗处理类:设置队伍区分(id)
  if self.队伍区分[1]==id then
    self.队伍数量[1]=self.队伍数量[1]+1
  else
    self.队伍数量[2]=self.队伍数量[2]+1
    self.队伍区分[2]=id
  end
end

function 战斗处理类:结算处理()
  local 死亡计算={0,0}
  for n=1,#self.参战单位 do
    if self.参战单位[n].气血<=0 or self.参战单位[n].捕捉 or self.参战单位[n].逃跑 then
      if self.参战单位[n].队伍==self.队伍区分[1] then
        死亡计算[1]=死亡计算[1]+1
      else
        死亡计算[2]=死亡计算[2]+1
      end
    end
  end
  if 死亡计算[1]==self.队伍数量[1] then
    self.回合进程="结束回合"
    self:结束战斗(self.队伍区分[2],self.队伍区分[1])
    return
  elseif 死亡计算[2]==self.队伍数量[2] then
    self.回合进程="结束回合"
    self:结束战斗(self.队伍区分[1],self.队伍区分[2])
    return
  end
  --检查状态
  for n=1,#self.参战单位 do
      if self.参战单位[n].法术状态 == nil then
        self.参战单位[n].法术状态 = {}
      end
      if self.参战单位[n].法宝已扣 ~= nil then
        self.参战单位[n].法宝已扣 = {}
      end
      if self.参战单位[n].法术状态["偷龙转凤"]~=nil then
        self:增加魔法(n,qz(self.参战单位[n].最大魔法*0.1))
      end
      for i, v in pairs(self.参战单位[n].法术状态) do
        self.参战单位[n].法术状态[i].回合=self.参战单位[n].法术状态[i].回合-1
        if self.参战单位[n].法术状态[i].回合<=0 then
            if i~="复活" then
              for w=1,#self.参战玩家 do
                  发送数据(self.参战玩家[w].连接id,5507,{id=n,名称=i})
              end
              self:取消状态(i,self.参战单位[n])
            end
            if i=="渡劫金身" and self.参战单位[n].气血>0 then
              local 恢复气血=qz((self.参战单位[n].最大气血-self.参战单位[n].气血)*0.8)
              for w=1,#self.参战玩家 do
                发送数据(self.参战玩家[w].连接id,5515,{id=n,气血=恢复气血})
                观战状态[#观战状态+1]={id=n,气血=恢复气血,序号=5515}
                self.参战单位[n].气血=self.参战单位[n].气血+恢复气血
              end
            end
            if i=="复活" then
              for w=1,#self.参战玩家 do
                发送数据(self.参战玩家[w].连接id,5508,{id=n,气血=self.参战单位[n].最大气血})
                self.参战单位[n].气血=self.参战单位[n].最大气血
                self.参战单位[n].法术状态[i]=nil
              end
            end
        elseif i=="分身术" then
          self.参战单位[n].法术状态[i].破解=nil
        elseif i=="无尘扇" and self.参战单位[n].愤怒~=nil then
          local 愤怒=qz(self.参战单位[n].愤怒*0.1)
          if self.参战单位[n].愤怒~=nil then self.参战单位[n].愤怒=self.参战单位[n].愤怒-愤怒 end
          if self.参战单位[n].愤怒<0 then self.参战单位[n].愤怒=0 end
        elseif i=="乾坤玄火塔" then
          local 愤怒=qz(150*(qz(self.参战单位[n].法术状态[i].境界/5)*0.02+0.02))
          if self.参战单位[n].愤怒~=nil then self.参战单位[n].愤怒=self.参战单位[n].愤怒+愤怒 end
          if self.参战单位[n].愤怒>150 then self.参战单位[n].愤怒=150 end
        end
      end
      if self.参战单位[n].气血<=0 and  self.参战单位[n].类型=="角色" and  self.参战单位[n].毫毛次数<3 and self:取指定法宝(n,"救命毫毛",1) and self:取指定法宝境界(n,"救命毫毛")>=取随机数(1,60) then
        for w=1,#self.参战玩家 do
          发送数据(self.参战玩家[w].连接id,5508,{id=n,气血=qz(self.参战单位[n].最大气血*0.2)})
        end
        self.参战单位[n].气血=qz(self.参战单位[n].最大气血*0.2)
        self.参战单位[n].毫毛次数=self.参战单位[n].毫毛次数+1
      end
  end
  for n=1,#self.参战玩家 do
    self.参战玩家[n].断线等待=nil
  end
  self:设置命令回合()
end

function 战斗处理类:数据处理(玩家id,序号,内容,参数)
  if 序号==5506 then
    self:逃跑事件处理(玩家id)
    return
  end
  if 序号 == 5510 then
    if 玩家数据[玩家id].观战 ~= nil and self.观战玩家[玩家id] ~= nil then
      if 自动遇怪[玩家id]~=nil then
        自动遇怪[玩家id]=os.time()
      end
      发送数据(玩家数据[玩家id].连接id,5505)
      玩家数据[玩家id].战斗=0
      玩家数据[玩家id].观战=nil
      玩家数据[玩家id].遇怪时间=os.time()+取随机数(10,20)
    end
    self.观战玩家[玩家id] = nil
    return
  end
  if self.回合进程=="加载回合" then
    if 序号==5501 then
      self.加载数量=self.加载数量-1
      if self.加载数量<=0 then
        if self.战斗流程~=nil and #self.战斗流程==0 then
          self:设置命令回合()
        else
          self:发送加载流程()
        end
      end
    end
  elseif self.回合进程=="命令回合" then
    if 序号==5502 then
      self.加载数量=self.加载数量-1
      local 编号=self:取参战编号(玩家id,"角色")
      local 目标={编号}
      if self.参战单位[编号].召唤兽~=nil then
        目标[2]=self.参战单位[编号].召唤兽
      end
      if self.参战单位[编号].助战明细 ~= nil then
        for i=1,#self.参战单位[编号].助战明细 do
            目标[#目标+1] = self.参战单位[编号].助战明细[i]
        end
      end
      for n=1,#内容 do
        self.参战单位[目标[n]].指令=内容[n]
        self.参战单位[目标[n]].指令.下达=true
        self.参战单位[目标[n]].自动指令=table.loadstring(table.tostring(内容[n]))
        if self.参战单位[目标[n]].类型=="角色" and self.参战单位[目标[n]].助战编号 == nil then
          玩家数据[self.参战单位[目标[n]].玩家id].角色.数据.自动指令=table.loadstring(table.tostring(内容[n]))
        elseif self.参战单位[目标[n]].类型=="角色" and self.参战单位[目标[n]].助战编号 ~= nil then
          玩家数据[self.参战单位[目标[n]].玩家id].助战.数据[self.参战单位[目标[n]].助战编号].自动指令 = table.loadstring(table.tostring(内容[n]))
        else
          if self.参战单位[目标[n]].是否孩子 == nil then
            local bb编号=玩家数据[self.参战单位[目标[n]].玩家id].召唤兽:取编号(self.参战单位[目标[n]].认证码)
            玩家数据[self.参战单位[目标[n]].玩家id].召唤兽.数据[bb编号].自动指令=table.loadstring(table.tostring(内容[n]))
          else
            local bb编号=玩家数据[self.参战单位[目标[n]].玩家id].孩子:取编号(self.参战单位[目标[n]].认证码)
            玩家数据[self.参战单位[目标[n]].玩家id].孩子.数据[bb编号].自动指令=table.loadstring(table.tostring(内容[n]))
          end
        end
        if self.参战单位[目标[n]].指令.类型=="攻击" and self.参战单位[目标[n]].指令.目标==0 then
          self.参战单位[目标[n]].指令.目标= self:取单个敌方目标(n)
        end
      end
      if self.参战单位[编号].助战明细 ~= nil and self.参战单位[编号].召唤兽~=nil then
        for i=1,#self.参战单位[编号].助战明细  do
          local 临时目标 = self.参战单位[编号].助战明细[i] + 1
          if 临时目标 ~= nil and self.参战单位[临时目标] ~= nil then
            self.参战单位[临时目标].指令=内容[2]
            self.参战单位[临时目标].指令.下达=true
            self.参战单位[临时目标].自动指令=table.loadstring(table.tostring(内容[2]))
            if self.参战单位[临时目标].指令.类型=="攻击" and self.参战单位[临时目标].指令.目标==0 then
              self.参战单位[临时目标].指令.目标= self:取单个敌方目标(n)
            end
          end
        end
      end
      if self.加载数量<=0 then  --走这里
        self.回合进程="计算回合"
        self:设置执行回合()
      end
    elseif 序号==5504 then
      local 编号=self:取参战编号(玩家id,"角色")
      self.参战单位[编号].道具类型="道具"
      发送数据(玩家数据[玩家id].连接id,5509,玩家数据[玩家id].道具:索要道具2(玩家id))
    elseif 序号==5508 then
      local 编号=self:取参战编号(玩家id,"角色")
      self.参战单位[编号].道具类型="法宝"
      发送数据(玩家数据[玩家id].连接id,5509,玩家数据[玩家id].道具:索要法宝1(玩家id,self.回合数))
    elseif 序号==5505 then --取召唤数据
      local 编号=0
      for n=1,#self.参战单位 do
        if self.参战单位[n].类型=="角色" and self.参战单位[n].玩家id==玩家id and self.参战单位[n].助战编号 == nil then
          编号=n
        end
      end
      if 编号==0 then
        return
      end
      发送数据(玩家数据[玩家id].连接id,5510,{玩家数据[玩家id].召唤兽.数据,self.参战单位[编号].召唤数量})
    elseif 序号==5507 then --设置自动战斗
      local 更改内容={}
      local 指令内容={}
      if 玩家数据[玩家id].角色.数据.自动战斗 then
        for n=1,#self.参战单位 do
          if self.参战单位[n].玩家id==玩家id  then
            self.参战单位[n].自动战斗=nil
            更改内容[#更改内容+1]={id=n,自动=self.参战单位[n].自动战斗}
          end
        end
        常规提示(玩家id,"#Y/你取消了自动战斗")
        玩家数据[玩家id].角色.数据.自动战斗=nil
        发送数据(玩家数据[玩家id].连接id,5514,更改内容)
      else
        玩家数据[玩家id].角色.数据.自动战斗=true
        local 更改=false
        for n=1,#self.参战单位 do
          if self.参战单位[n].玩家id==玩家id  then
            self.参战单位[n].自动战斗=true
            if  self.参战单位[n].指令~=nil and self.参战单位[n].指令.下达==false then
              self.参战单位[n].指令.下达=true
              更改=true
              if self.参战单位[n].自动指令~=nil then
                self.参战单位[n].指令=table.loadstring(table.tostring(self.参战单位[n].自动指令))
              else
                self.参战单位[n].指令.类型="攻击"
                self.参战单位[n].指令.目标= self:取单个敌方目标(n)
              end
              更改内容[#更改内容+1]={id=n,自动=self.参战单位[n].自动战斗}
              指令内容[#指令内容+1]={id=n,自动=self.参战单位[n].自动指令}
            end
          end
        end
        常规提示(玩家id,"#Y/你开启了自动战斗")
        发送数据(玩家数据[玩家id].连接id,5511)
        发送数据(玩家数据[玩家id].连接id,5513,指令内容)
        发送数据(玩家数据[玩家id].连接id,5514,更改内容)
        if 更改 then
          self.加载数量=self.加载数量-1
          if self.加载数量<=0 then
            self.回合进程="计算回合"
            self:设置执行回合()
          end
        end
      end
    end
  elseif self.回合进程=="执行回合" then
    if 序号==5503 then
      self.加载数量=self.加载数量-1
      self.执行等待=os.time()+10
      local 断线数量=0
      for n=1,#self.参战玩家 do
        if self.参战玩家[n].断线等待 then
          断线数量=断线数量+1
        end
      end
      if self.加载数量<=0 and self.回合进程~="结束回合" then
        self.回合进程="结束回合"
        self:结算处理()
      elseif self.加载数量<=断线数量 and self.回合进程~="结束回合" then
        self.回合进程="结束回合"
        self:结算处理()
      end
    elseif 序号==5507 then --设置自动战斗
      local 更改内容={}
      local 指令内容={}
      if 玩家数据[玩家id].角色.数据.自动战斗 then
        for n=1,#self.参战单位 do
          if self.参战单位[n].玩家id==玩家id then
            self.参战单位[n].自动战斗=nil
            更改内容[#更改内容+1]={id=n,自动=self.参战单位[n].自动战斗}
          end
        end
        常规提示(玩家id,"#Y/你取消了自动战斗")
        玩家数据[玩家id].角色.数据.自动战斗=nil
        发送数据(玩家数据[玩家id].连接id,5514,更改内容)
      else
        玩家数据[玩家id].角色.数据.自动战斗=true
        for n=1,#self.参战单位 do
          if self.参战单位[n].玩家id==玩家id then
            self.参战单位[n].自动战斗=true
            更改内容[#更改内容+1]={id=n,自动=self.参战单位[n].自动战斗}
            指令内容[#指令内容+1]={id=n,自动=self.参战单位[n].自动指令}
          end
        end
        常规提示(玩家id,"#Y/你开启了自动战斗")
        发送数据(玩家数据[玩家id].连接id,5513,指令内容)
        发送数据(玩家数据[玩家id].连接id,5514,更改内容)
      end
    end
  end
end

function 战斗处理类:设置执行回合()  --走这里
  local 临时速度={}
  self.执行对象={}
  for n=1,#self.参战单位 do
    if self.参战单位[n].经脉有无 ~= nil and self.参战单位[n].经脉有无 then
        self:经脉回合开始处理(n)
    end
    if self.参战单位[n].法术状态.张弛有道 ~= nil and self.参战单位[n].张弛有道加成 == nil then
      self.参战单位[n].张弛有道加成 = qz(self.参战单位[n].灵力*0.1)
      self.参战单位[n].灵力 = self.参战单位[n].灵力 + self.参战单位[n].张弛有道加成
    end
    if self.参战单位[n].洞察特性 ~= nil and 取随机数() <= self.参战单位[n].洞察特性*5  and self:取玩家战斗() and self.参战单位[n].主人 ~= nil and self.参战单位[self.参战单位[n].主人]~=nil then
      local 临时敌人 = self:取单个敌方目标(n)
      local 关键字 = "气血"
      if 取随机数(1,2) == 1 then
        关键字 = "魔法"
      end
      常规提示(self.参战单位[self.参战单位[n].主人].玩家id,"#Y/你的召唤兽发现#G/"..self.参战单位[临时敌人].名称.."#Y/当前#G/"..关键字.."#Y/剩余#G/"..self.参战单位[临时敌人][关键字].."点")
    elseif self.参战单位[n].灵动特性 ~= nil and self.参战单位[n].灵动次数 <3 and 取随机数() <= self.参战单位[n].灵动特性*5 then
      self.参战单位[n].灵动次数=self.参战单位[n].灵动次数+1
      local 临时友方 = self:取单个友方目标(n)
      self.战斗发言数据[#self.战斗发言数据+1]={id=n,内容=self.参战单位[临时友方].名称.."提拉米苏你睡觉了么#24"}
    end
    --print("-------------------执行回合 指令",1,self.参战单位[n].名称,self.参战单位[n].指令.类型)
    临时速度[n]={速度=self.参战单位[n].速度,编号=n}
    if self.参战单位[n].指令==nil  then
      self.参战单位[n].指令={下达=false,类型="",目标=0,敌我=0,参数="",附加=""}
    end
    if self.参战单位[n].指令.下达==false then
      self.参战单位[n].指令.下达=true
      self.参战单位[n].指令.类型="攻击"
      self.参战单位[n].指令.目标= self:取单个敌方目标(n)
    end
    if self.参战单位[n].队伍==0 then
      if self.参战单位[n].主动技能~=nil and #self.参战单位[n].主动技能>0 and 取随机数()>=30 then
        self.参战单位[n].指令.类型="法术"
        self.参战单位[n].指令.参数=self.参战单位[n].主动技能[取随机数(1,#self.参战单位[n].主动技能)].名称
        local 临时技能=取法术技能(self.参战单位[n].指令.参数)
        if 临时技能[3]==4 then
          self.参战单位[n].指令.目标= self:取单个敌方目标(n)
        else
          self.参战单位[n].指令.目标= self:取单个友方目标(n)
        end
      end
      if self.战斗类型==100017 and self.参战单位[n].队伍==0 then
        local 同门编号=0
        for i=1,#self.参战单位 do
          if self.参战单位[i].同门单位 then
            同门编号=i
            self.参战单位[i].指令.类型=""
          end
        end
        if 同门编号==0 then
          同门编号=self:取单个敌方目标(n)
        end
        -- --print("同门编号:"..同门编号)
        self.参战单位[n].指令.类型="同门飞镖"
        self.参战单位[n].指令.目标=同门编号
      end
    end
    if self.参战单位[n].队伍==0 and self.参战单位[n].精灵 and self.回合数==2 then
      self.参战单位[n].指令.下达=true
      self.参战单位[n].指令.类型="法术"
      self.参战单位[n].指令.目标= self:取单个敌方目标(n)
      self.参战单位[n].指令.参数="自爆"
    elseif self.参战单位[n].队伍==0 and self.参战单位[n].捉鬼变异 and self.回合数==2 then
      self.参战单位[n].指令.下达=true
      self.参战单位[n].指令.类型="逃跑"
      self.参战单位[n].指令.目标= 0
      self.参战单位[n].指令.参数=""
    elseif self.参战单位[n].队伍==0 and self.战斗类型==100096 and self.参战单位[n].名称=="红颜知己" and  self:取封印状态(n)then
      local 是否封印 = self:取封印状态(n,1)
      if 是否封印 ~= false and self.参战单位[n].红颜发言 ~= nil then
        self.参战单位[n].指令.下达=true
        self.参战单位[n].指令.类型="逃跑"
        self.参战单位[n].指令.目标= 0
        self.参战单位[n].指令.参数=""
        self.参战单位[n].红颜发言=nil
      end
    elseif self.参战单位[n].队伍==0 and self.战斗类型==100096 and self.参战单位[n].名称=="红颜知己" and self:取封印状态(n) == false then
      self.参战单位[n].指令.下达=true
      self.参战单位[n].指令.类型="法术"
      self.参战单位[n].指令.目标= self:取单个敌方目标(n)
      self.参战单位[n].指令.参数="反间之计"
    elseif self.参战单位[n].队伍==0 and self.战斗类型==100004 and  self.参战单位[n].变异 and self.回合数==3 then
      self.参战单位[n].指令.下达=true
      self.参战单位[n].指令.类型="逃跑"
      self.参战单位[n].指令.目标= 0
      self.参战单位[n].指令.参数=""
    end
  end
  table.sort(临时速度,function(a,b) return a.速度>b.速度 end )
  for n=1,#临时速度 do
    self.执行对象[n]=临时速度[n].编号
  end
  self.战斗流程={}
  self.执行等待=0
  self:执行计算()
  self.执行等待=self.执行等待+os.time()
  for i=1,#self.参战玩家 do
    local 血量数据={}
    for n=1,#self.参战单位 do
      if self.参战单位[n].气血<0 then self.参战单位[n].气血=0 end
      if self.参战单位[n].魔法<0 then self.参战单位[n].魔法=0 end
      if self.参战单位[n].玩家id==self.参战玩家[i].id then
        if self.参战单位[n].类型=="角色" and self.参战单位[n].助战编号==nil then
          血量数据[1]={气血=self.参战单位[n].气血,最大气血=self.参战单位[n].最大气血,魔法=self.参战单位[n].魔法,最大魔法=self.参战单位[n].最大魔法,愤怒=self.参战单位[n].愤怒}
        elseif self.参战单位[n].逃跑==nil and self.参战单位[n].类型=="bb" then
          血量数据[2]={气血=self.参战单位[n].气血,最大气血=self.参战单位[n].最大气血,魔法=self.参战单位[n].魔法,最大魔法=self.参战单位[n].最大魔法}
        end
      end
    end
    发送数据(self.参战玩家[i].连接id,5506,血量数据)
    发送数据(self.参战玩家[i].连接id,5504,self.战斗流程)
  end
  for i,v in pairs(self.观战玩家) do
    if 玩家数据[i] ~= nil then
      发送数据(玩家数据[i].连接id,5504,self.战斗流程)
    end
  end
  self.加载数量=#self.参战玩家
  self.执行等待=os.time()+10+#self.战斗流程*30
  self.回合进程="执行回合"
end

function 战斗处理类:发送加载流程()
  for i=1,#self.参战玩家 do
    local 血量数据={}
    for n=1,#self.参战单位 do
      -- --print(n,self.参战单位[n].玩家id,self.参战玩家[i].id)
      if self.参战单位[n].玩家id==self.参战玩家[i].id then
        if self.参战单位[n].类型=="角色" and self.参战单位[n].助战编号==nil  then
          血量数据[1]={气血=self.参战单位[n].气血,最大气血=self.参战单位[n].最大气血,魔法=self.参战单位[n].魔法,最大魔法=self.参战单位[n].最大魔法,愤怒=self.参战单位[n].愤怒}
        elseif self.参战单位[n].类型=="bb" then
          血量数据[2]={气血=self.参战单位[n].气血,最大气血=self.参战单位[n].最大气血,魔法=self.参战单位[n].魔法,最大魔法=self.参战单位[n].最大魔法}
        end
      end
    end
    发送数据(self.参战玩家[i].连接id,5504,self.战斗流程)
    发送数据(self.参战玩家[i].连接id,5506,血量数据)
  end
  self.执行等待=self.执行等待+os.time()
  self.加载数量=#self.参战玩家
  self.回合进程="执行回合"
end

function 战斗处理类:执行计算()
  for n=1,#self.参战单位 do
     if self.参战单位[n] ~= nil and self.参战单位[n].法术状态 ~= nil and self.参战单位[n].法术状态.生命之泉~=nil then
         if self:取目标状态(n,n,2) then
            local 气血 = 0
            if 释怀定制 then
              气血=self.参战单位[n].法术状态.生命之泉.等级*5*2+15
            else
              气血=self.参战单位[n].法术状态.生命之泉.等级+15
            end

             气血=self:取恢复气血(self.参战单位[n].法术状态.生命之泉.编号,n,气血)
             self.战斗流程[#self.战斗流程+1]={流程=100,攻击方=n,气血=气血,挨打方={}}
             self:增加气血(n,气血)
           end
       end
      if self.参战单位[n] ~= nil and self.参战单位[n].法术状态 ~=nil and self.参战单位[n].法术状态.普渡众生~=nil then
         if self:取目标状态(n,n,2) then
          local 气血 = 0
          if 释怀定制 then
            气血=self.参战单位[n].法术状态.普渡众生.等级*7*3+150
          else
            气血=self.参战单位[n].法术状态.普渡众生.等级*2+150
          end
            气血=self:取恢复气血(self.参战单位[n].法术状态.普渡众生.编号,n,气血)
            self.战斗流程[#self.战斗流程+1]={流程=100,攻击方=n,气血=气血,挨打方={}}
            self:增加气血(n,气血)
          end
       end
        if self.参战单位[n].再生~=nil then
          if self:取目标状态(n,n,2) then
            local 气血=self.参战单位[n].再生
            气血=self:取恢复气血(n,n,气血)
            self.战斗流程[#self.战斗流程+1]={流程=100,攻击方=n,气血=气血,挨打方={}}
            self:增加气血(n,气血)
          end
        end
        if self.参战单位[n].法术状态.炼气化神~=nil then
          if self:取目标状态(n,n,2) then
            self:增加魔法(n,qz(self.参战单位[n].法术状态.炼气化神.等级/2))
          end
        end
        if self.参战单位[n].冥思~=nil then
          if self:取目标状态(n,n,2) then
            self:增加魔法(n,qz(self.参战单位[n].冥思))
          end
        end
        if self.参战单位[n].气血<=0 and  self.参战单位[n].类型=="角色" and 玩家数据[self.参战单位[n].玩家id].角色.数据.门派=="花果山" and 取随机数()<=qz(self:取技能等级(n,"九幽除名")*0.1) then
          for w=1,#self.参战玩家 do
            发送数据(self.参战玩家[w].连接id,5508,{id=n,气血=qz(self.参战单位[n].最大气血*0.2)})
          end
          self.参战单位[n].气血=qz(self.参战单位[n].最大气血*0.2)
        end
        if self.参战单位[n].法术状态.尸腐毒~=nil then
          if self:取目标状态(n,n,2) then
            -- self:增加魔法(n,qz(self.参战单位[n].法术状态.炼气化神.等级/2))
            local 气血=qz(self.参战单位[n].气血*0.1)
            if 气血>self.参战单位[n].法术状态.尸腐毒.等级*15 then
               气血=self.参战单位[n].法术状态.尸腐毒.等级*15
            end
            self.战斗流程[#self.战斗流程+1]={流程=102,攻击方=n,气血=0,挨打方={}}
            self.战斗流程[#self.战斗流程].死亡=self:减少气血(n,气血)
            self.战斗流程[#self.战斗流程].气血=气血
            local 编号=self.参战单位[n].法术状态.尸腐毒.攻击编号
            if self:取指定法宝(编号,"九幽",1) then
              if self:取指定法宝境界(编号,"九幽")>=0 then
                local 目标=self:取多个友方目标(编号,编号,10,"尸腐毒")
                if #目标 == 0 then
                  return
                end
                local 目标数 = #目标
                self.战斗流程[#self.战斗流程].受益方 = {}
                for i=1,目标数 do
                  local 气血=0
                  local 法宝层数 = self:取指定法宝境界(编号,"九幽") + 1
                  if 释怀定制 then
                    self.战斗流程[#self.战斗流程].受益方[i]={受益方=目标[i],伤害=qz(self.参战单位[目标[i]].气血*0.03+self.战斗流程[#self.战斗流程].气血*0.003)*2}
                    气血=qz(self.参战单位[目标[i]].气血*0.03+self.战斗流程[#self.战斗流程].气血*0.003)*2
                  else
                    self.战斗流程[#self.战斗流程].受益方[i]={受益方=目标[i],伤害=qz(self.参战单位[目标[i]].气血*0.03+self.战斗流程[#self.战斗流程].气血*0.003)}
                    气血=qz(self.参战单位[目标[i]].气血*0.01+self.战斗流程[#self.战斗流程].气血*0.002*法宝层数)
                  end
                  气血=self:取恢复气血(编号,目标[i],气血)
                  self:增加气血(目标[i],气血)
                end
            end
          end
        end
      end
      if self.参战单位[n].法术状态.紧箍咒~=nil then
        if self:取目标状态(n,n,2) then
          -- self:增加魔法(n,qz(self.参战单位[n].法术状态.炼气化神.等级/2))
          local 气血=self.参战单位[n].法术状态.紧箍咒.等级*5
          self.战斗流程[#self.战斗流程+1]={流程=102,攻击方=n,气血=0,挨打方={}}
          self.战斗流程[#self.战斗流程].死亡=self:减少气血(n,气血)
          self.战斗流程[#self.战斗流程].气血=气血
        end
      end
      if self.参战单位[n].法术状态.雾杀~=nil then
        if self:取目标状态(n,n,2) then
          local 气血=qz(self.参战单位[n].法术状态.雾杀.等级*7.5)
          self.战斗流程[#self.战斗流程+1]={流程=102,攻击方=n,气血=0,挨打方={}}
          self.战斗流程[#self.战斗流程].死亡=self:减少气血(n,气血)
          self.战斗流程[#self.战斗流程].气血=气血
        end
      end
      if self.参战单位[n].法术状态.毒~=nil then
        if self:取目标状态(n,n,2) then
            -- self:增加魔法(n,qz(self.参战单位[n].法术状态.炼气化神.等级/2))
          local 气血=qz(self.参战单位[n].气血*0.1)
          if 气血<1 then
            气血=1
          elseif 气血>self.参战单位[n].法术状态.毒.等级*20 then
            气血=self.参战单位[n].法术状态.毒.等级*20
          end
          local 魔法=qz(self.参战单位[n].魔法*0.05)
          if 魔法<1 then
            魔法=0
          end
          self.参战单位[n].魔法=self.参战单位[n].魔法-魔法
          if self.参战单位[n].魔法<=0 then
            self.参战单位[n].魔法=0
          end
          self.战斗流程[#self.战斗流程+1]={流程=102,攻击方=n,气血=0,挨打方={}}
          self.战斗流程[#self.战斗流程].死亡=self:减少气血(n,气血)
          self.战斗流程[#self.战斗流程].气血=气血
        end
      end
    end
  for n=1,#self.参战单位 do
    if self.参战单位[n].队伍==0 and self.参战单位[n].气血>=1 then
      if self.战斗类型==100009 then
        if self:取阵营数量(0)<=5 and self.参战单位[n].名称~="喽啰"  then
          self:执行怪物召唤(n,1,0,5-self:取阵营数量(0))
        end
      elseif self.战斗类型==100125 then
        if self:取阵营数量(0)<=5 then
          self:执行怪物召唤(n,5,0,5-self:取阵营数量(0))
        end
      end
    end
  end
  self:执行计算1()
end

function 战斗处理类:取阵营数量(队伍)
  local 数量=0
  for n=1,#self.参战单位 do
    if self.参战单位[n].队伍==队伍 and self.参战单位[n].气血>=1 and self.参战单位[n].捕捉==nil and self.参战单位[n].逃跑==nil then
      数量=数量+1
    end
  end
  return 数量
end

function 战斗处理类:加载召唤单位(单位组,id,队伍)
  local 位置=0
  local 起始={}
  local 数量=0
  for n=1,#self.参战单位 do
    if self.参战单位[n].队伍==队伍 then
      起始[#起始+1]=n
    end
  end
  for n=1,#起始 do
    if 起始[n]==id then
       位置=n
    end
  end
  if 位置==0 then
    位置=#起始+1
  end
   self.参战单位[id]={}
   self.参战单位[id].名称=单位组.名称
   self.参战单位[id].模型=单位组.模型
   self.参战单位[id].等级=单位组.等级
   self.参战单位[id].变异=单位组.变异
   self.参战单位[id].队伍=队伍
   self.参战单位[id].位置=位置
   self.参战单位[id].参战等级=单位组.参战等级
   self.参战单位[id].类型="bb"
   self.参战单位[id].法防=单位组.法防
   self.参战单位[id].玩家id=0
   self.参战单位[id].分类="野怪"
   self.参战单位[id].附加阵法="普通"
   self.参战单位[id].伤害=单位组.伤害
   self.参战单位[id].命中=单位组.伤害
   self.参战单位[id].防御=单位组.防御
   self.参战单位[id].速度=单位组.速度
   self.参战单位[id].灵力=单位组.灵力
   self.参战单位[id].躲闪=单位组.躲闪
   self.参战单位[id].气血=单位组.气血
   self.参战单位[id].武器=单位组.武器
   self.参战单位[id].染色方案=单位组.染色方案
   self.参战单位[id].染色组=单位组.染色组
   self.参战单位[id].锦衣=单位组.锦衣
   self.参战单位[id].武器染色方案=单位组.武器染色方案
   self.参战单位[id].武器染色组=单位组.武器染色组
   self.参战单位[id].最大气血=单位组.气血
   self.参战单位[id].魔法=单位组.魔法
   self.参战单位[id].最大魔法=单位组.魔法
   self.参战单位[id].躲闪=单位组.躲闪
   self.参战单位[id].技能=单位组.技能
   self.参战单位[id].物伤减少=单位组.物伤减少
   self.参战单位[id].法伤减少=单位组.法伤减少
   self.参战单位[id].躲避减少=单位组.躲避减少
   self.参战单位[id].主动技能={}
   if 单位组.角色 then
      self.参战单位[id].类型="系统角色"
   end
   for i=1,#单位组.主动技能 do
      self.参战单位[id].主动技能[i]={名称=单位组.主动技能[i],等级=单位组.等级+10}
   end
     self.参战单位[id].已加技能={}
     self.参战单位[id].法术状态={}
     self.参战单位[id].奇经八脉={}
     self.参战单位[id].追加法术={}
     self.参战单位[id].附加状态={}
     if self.参战单位[id].主动技能==nil then
          self.参战单位[id].主动技能={}
     end
     self.参战单位[id].特技技能={}
     self.参战单位[id].战意=0
     self.参战单位[id].法暴=0
     self.参战单位[id].法防=0
     self.参战单位[id].必杀=1
     self.参战单位[id].特技技能={}
     self.参战单位[id].战意=0
     self.参战单位[id].法防=0
     self.参战单位[id].驱怪=0
     self.参战单位[id].慈悲效果=0
     self.参战单位[id].攻击修炼=0
     self.参战单位[id].法术修炼=0
     self.参战单位[id].怒击效果=false
     self.参战单位[id].防御修炼=0
     self.参战单位[id].抗法修炼=0
     self.参战单位[id].猎术修炼=0
     self.参战单位[id].毫毛次数=0
     self.参战单位[id].法宝佩戴={}
     self.参战单位[id].攻击五行=""
     self.参战单位[id].防御五行=""
     self.参战单位[id].攻击五行=""
     self.参战单位[id].防御五行=""
     self.参战单位[id].修炼数据={法修=0,抗法=0,攻击=0,法防=0,猎术=0}
     if self.参战单位[id].命中==nil then self.参战单位[id].命中=self.参战单位[id].伤害 end
     for i=1,#灵饰战斗属性 do
         self.参战单位[id][灵饰战斗属性[i]]=0
     end
  self:添加技能属性(self.参战单位[id],self.参战单位[id].技能)
  self.参战单位[id].指令={下达=false,类型="",目标=0,敌我=0,参数="",附加=""}
end

function 战斗处理类:执行怪物召唤(编号,类型,队伍,次数)
  local id组=self:取阵亡id组(队伍)
  if 类型==1 then --星宿战斗召唤
    for n=1,次数 do
      local 临时id=id组[n]
      if 临时id==nil then --新增位置
        临时id=#self.参战单位+1
      end
      local 临时数据=self:召唤数据设置(1,self.参战单位[编号].等级,编号)
      self.执行等待=self.执行等待+5
      self:加载召唤单位(临时数据,临时id,队伍)
      if id组[n]==nil then
        self:设置队伍区分(队伍)
      end
      self.战斗流程[#self.战斗流程+1]={流程=607,攻击方=编号,挨打方={{挨打方=临时id,队伍=队伍,数据=self:取加载信息(临时id)}}}
    end
  elseif 类型==2 then
    for n=1,次数 do
      local 临时id=id组[n]
      if 临时id==nil then --新增位置
        临时id=#self.参战单位+1
      end
      local 临时数据=self:召唤数据设置(2,self.参战单位[编号].等级,编号)
      self.执行等待=self.执行等待+5
      self:加载召唤单位(临时数据,临时id,队伍)
      if id组[n]==nil then
        self:设置队伍区分(队伍)
      end
      self.战斗流程[#self.战斗流程+1]={流程=607,攻击方=编号,挨打方={{挨打方=临时id,队伍=队伍,数据=self:取加载信息(临时id)}}}
    end
  elseif 类型==3 then
    for n=1,次数 do
      local 临时id=id组[n]
      if 临时id==nil then --新增位置
        临时id=#self.参战单位+1
      end
      local 临时数据=self:召唤数据设置(3,self.参战单位[编号].等级,编号)
      self.执行等待=self.执行等待+5
      self:加载召唤单位(临时数据,临时id,队伍)
      if id组[n]==nil then
        self:设置队伍区分(队伍)
      end
      self.战斗流程[#self.战斗流程+1]={流程=607,攻击方=编号,挨打方={{挨打方=临时id,队伍=队伍,数据=self:取加载信息(临时id)}}}
    end
  elseif 类型==4 then
    for n=1,次数 do
      local 临时id=id组[n]
      if 临时id==nil then --新增位置
        临时id=#self.参战单位+1
      end
      local 临时数据=self:召唤数据设置(4,self.参战单位[编号].等级,编号)
      self.执行等待=self.执行等待+5
      self:加载召唤单位(临时数据,临时id,队伍)
      if id组[n]==nil then
        self:设置队伍区分(队伍)
      end
      self.战斗流程[#self.战斗流程+1]={流程=607,攻击方=编号,挨打方={{挨打方=临时id,队伍=队伍,数据=self:取加载信息(临时id)}}}
    end
  elseif 类型==5 then
    for n=1,次数 do
      local 临时id=id组[n]
      if 临时id==nil then --新增位置
        临时id=#self.参战单位+1
      end
      local 临时数据=self:召唤数据设置(5,self.参战单位[编号].等级,编号)
      self.执行等待=self.执行等待+5
      self:加载召唤单位(临时数据,临时id,队伍)
      if id组[n]==nil then
        self:设置队伍区分(队伍)
      end
      self.战斗流程[#self.战斗流程+1]={流程=607,攻击方=编号,挨打方={{挨打方=临时id,队伍=队伍,数据=self:取加载信息(临时id)}}}
    end
  end
end

function 战斗处理类:取阵亡id组(队伍)
  local 队伍表={}
  for n=1,#self.参战单位 do
    if self.参战单位[n].队伍==队伍 and self.参战单位[n].法术状态.复活==nil and (self.参战单位[n].气血<=0 or self.参战单位[n].逃跑~=nil or self.参战单位[n].捕捉~=nil) then
      队伍表[#队伍表+1]=n
    end
  end
  return 队伍表
end

function 战斗处理类:召唤数据设置(类型,等级,编号)
  if 类型==1 then --星宿的天兵
    return self:取召唤类型1(等级,编号)
  elseif 类型==2 then
    return self:取召唤类型2(等级,编号)
  elseif 类型==3 then
    return self:取召唤类型3(等级,编号)
  elseif 类型==4 then
    return self:取召唤类型4(等级,编号)
  elseif 类型==5 then
    return self:取召唤类型5(等级,编号)
  end
end

function 战斗处理类:取召唤类型1(等级,编号)
  等级=等级-5
  if 等级<1 then 等级=1 end
  local 召唤单位={
    名称="喽啰"
    ,模型="天兵"
    ,伤害=等级*10
    ,气血=等级*等级+500
    ,灵力=等级*5
    ,速度=等级*3
    ,防御=等级*2
    ,法防=等级*0.6
    ,躲闪=等级*2
    ,魔法=200
    ,等级=等级
    ,技能={}
    ,主动技能=取随机法术(3)
  }
  return 召唤单位
end

function 战斗处理类:取召唤类型2(等级,编号)
  等级=等级-5
  if 等级<1 then 等级=1 end
  local 召唤单位={
    名称="怨灵"
    ,模型="进阶幽灵"
    ,伤害=等级*5
    ,气血=等级*等级
    ,灵力=等级*5
    ,速度=等级*3
    ,防御=等级*2
    ,法防=等级*0.6
    ,躲闪=等级*2
    ,魔法=200
    ,等级=等级
    ,技能={}
    ,主动技能={}
  }
  if 编号~=nil and self:取奇经八脉是否有(编号,"腐蚀") then
    召唤单位.伤害=qz(召唤单位.伤害*1.1)
  end
  if 编号~=nil and self:取奇经八脉是否有(编号,"焕然") then
    召唤单位.气血=qz(召唤单位.气血*1.15)
  end
  return 召唤单位
end

function 战斗处理类:取召唤类型3(等级,编号)
  等级=等级-5
  if 等级<1 then 等级=1 end
  local 召唤单位={
    名称="幻魔"
    ,模型="巴蛇"
    ,伤害=等级*10
    ,气血=等级*等级+500
    ,灵力=等级*5
    ,速度=等级*3
    ,防御=等级*2
    ,法防=等级*0.6
    ,躲闪=等级*2
    ,魔法=200
    ,等级=等级
    ,技能={}
    ,主动技能={}
  }
  if 编号~=nil and self:取奇经八脉是否有(编号,"腐蚀") then
    召唤单位.伤害=qz(召唤单位.伤害*1.1)
  end
  return 召唤单位
end

function 战斗处理类:取召唤类型4(等级,编号)
  等级=等级-5
  if 等级<1 then 等级=1 end
  local 召唤单位={
    名称="猴子猴孙"
    ,模型="巨力神猿"
    ,伤害=1--等级*10
    ,气血=等级*等级+500
    ,灵力=等级*5
    ,速度=等级*3
    ,防御=等级*2
    ,法防=等级*0.6
    ,躲闪=等级*2
    ,魔法=200
    ,等级=等级
    ,技能={}
    ,主动技能={}
  }
  return 召唤单位
end

function 战斗处理类:取召唤类型5(等级,编号)
  等级=等级-5
  if 等级<1 then 等级=1 end
  local 召唤单位={
    名称="灵感分身"
  ,模型="神天兵"
  ,角色=true
  ,武器=取武器数据("雷神",100)
  ,伤害=等级*12+500
  ,气血=等级*1000
  ,灵力=等级*7+500
  ,速度=等级*4.5
  ,防御=等级*4
  ,法防=等级*0.8
  ,躲闪=等级*4
  ,魔法=200
  ,等级=等级
  ,技能={"高级感知"}
  ,主动技能=取随机法术(5)
  }
  return 召唤单位
end

function 战斗处理类:执行计算1()
  --检查一遍后发制人
  for n=1,#self.执行对象 do
    local 编号=self.执行对象[n]
    if self.参战单位[编号].法术状态.后发制人~=nil then
      self.参战单位[编号].指令.类型=""
      self:物攻技能计算(编号,"后发制人",self:取技能等级(编号,"后发制人"))
    end
    if self.参战单位[编号].观照万象 ~= nil then
      self.参战单位[编号].观照万象 = self.参战单位[编号].观照万象 -1
      if self.参战单位[编号].观照万象 <= 0 then
        self.参战单位[编号].观照万象 = nil
      end
    end
  end
  for n=1,#self.执行对象 do
    if self.全局结束==nil and self:取行动状态(self.执行对象[n]) then
      local 编号=self.执行对象[n]
      if self.参战单位[编号].指令.下达 then
        if self.参战单位[编号].法术状态.疯狂 or self.参战单位[编号].法术状态.错乱 then
          if self.参战单位[编号].指令.类型~="防御" then
            self.参战单位[编号].指令.类型="攻击"
            self.参战单位[编号].指令.目标=self:取单个敌方目标(编号)
          end
        end
        if self.参战单位[编号].法术状态.反间之计~=nil  then
          self.参战单位[编号].指令.类型="攻击"
          self.参战单位[编号].指令.目标=self:取单个友方目标(编号)
        end
        if self.参战单位[编号].法术状态.锋芒毕露~=nil  then
          self.参战单位[编号].指令.目标=self.参战单位[编号].法术状态.目标id
        end
        if self.参战单位[编号].法术状态.诱袭~=nil  then
          self.参战单位[编号].指令.类型="攻击"
          self.参战单位[编号].指令.目标=self.参战单位[编号].法术状态.目标id
        end
        if self.参战单位[编号].指令.类型=="攻击" then--普通攻击
          local 怒击=false
          local 目标1=self.参战单位[self.执行对象[n]].指令.目标
          if self:取攻击状态(self.执行对象[n]) then
            if self.参战单位[self.参战单位[self.执行对象[n]].指令.目标]~=nil and self.参战单位[self.执行对象[n]].法术状态.反间之计 == nil and self.参战单位[self.参战单位[self.执行对象[n]].指令.目标].队伍==self.参战单位[编号].队伍 then
              self.参战单位[self.执行对象[n]].指令.目标= self:取单个敌方目标(编号)
              目标1=self.参战单位[self.执行对象[n]].指令.目标
            end
            if self:取目标状态(self.执行对象[n],目标1,1) == false then
              self.参战单位[self.执行对象[n]].指令.目标= self:取单个敌方目标(编号)
            end
            if  self.参战单位[目标1]~=nil and self.参战单位[编号].理直气壮~=nil and 取随机数()<=40 then
              self.参战单位[编号].指令.参数="理直气壮"
              self:法术计算(self.执行对象[n],1)
              if self.参战单位[编号].怒击效果 and self:取攻击状态(self.执行对象[n]) then
                self.参战单位[self.执行对象[n]].指令.目标= self:取单个敌方目标(编号)
                self:普通攻击计算(self.执行对象[n],1)
                self.参战单位[编号].怒击触发 = nil
              end
            elseif self.参战单位[目标1]~=nil and self.参战单位[编号].连击~=nil and self.参战单位[编号].连击>=取随机数() then
              self.参战单位[编号].指令.参数="高级连击"
              self:法术计算(self.执行对象[n],1)
              if self.参战单位[编号].怒击效果 and self:取攻击状态(self.执行对象[n]) then
                self.参战单位[self.执行对象[n]].指令.目标= self:取单个敌方目标(编号)
                self:普通攻击计算(self.执行对象[n],1)
                self.参战单位[编号].怒击触发 = nil
              end
            else
              怒击=self:普通攻击计算(self.执行对象[n],1)
              if self.参战单位[编号].怒击效果 and 怒击 and self:取攻击状态(self.执行对象[n]) then
                self.参战单位[self.执行对象[n]].指令.目标= self:取单个敌方目标(编号)
                self:普通攻击计算(self.执行对象[n],1)
              end
            end
            if (self.参战单位[编号].嗜血追击~=nil or (self:取指定法宝境界(编号,"嗜血幡")~=false and (取随机数(1,1)<=self:取指定法宝境界(编号,"嗜血幡")*1.7) and self:取指定法宝(编号,"嗜血幡",1,1))) and self:取行动状态(self.执行对象[n]) and self:取目标状态(self.执行对象[n],目标1,1) and self:取奇经八脉是否有(编号,"逐胜")~=true then
              目标=self:取单个敌方目标(编号)
              if 目标~=0 then
                self.参战单位[self.执行对象[n]].指令.目标=目标
                if 编号~=nil and self.参战单位[编号].法宝佩戴~=nil and #self.参战单位[编号].法宝佩戴~=nil and self.参战单位[编号].类型=="角色" then
                    local 序列 = 0
                    for i=1,#self.参战单位[编号].法宝佩戴 do
                      if self.参战单位[编号].法宝佩戴[i].名称=="嗜血幡" then
                        序列=i
                      end
                    end
                    self:扣除法宝灵气(编号,序列,1)
                end
                怒击=self:普通攻击计算(self.执行对象[n],1)
                if 怒击 and self.参战单位[编号].怒击效果 then
                  目标=self:取单个敌方目标(编号)
                  self.参战单位[self.执行对象[n]].指令.目标=目标
                  if self:取目标状态(self.执行对象[n],目标,1) and self:取行动状态(self.执行对象[n])  then
                    self:普通攻击计算(self.执行对象[n],1)
                    self.参战单位[self.执行对象[n]].指令.目标=目标1
                  end
                end
              end
            end
            if 编号~=nil and self:取奇经八脉是否有(编号,"风刃") then
              目标=self:取单个敌方目标(编号)
              if 目标~=0 then
                if self:取目标状态(编号,目标,1) then
                  self:物理同时多个攻击(编号,self.参战单位[编号].等级*3,3,名称)--编号,伤害,数量,名称)
                end
              end
            end
            if 编号~=nil and self:取奇经八脉是否有(编号,"逐胜") then
              目标=self:取单个敌方目标(编号)
              if 目标~=0 then
                self.参战单位[self.执行对象[n]].指令.目标=目标
                if self:取目标状态(self.执行对象[n],目标,1) and self:取行动状态(self.执行对象[n])  then
                  self:普通攻击计算(self.执行对象[n],1)
                  self.参战单位[self.执行对象[n]].指令.目标=目标1
                end
              end
            end
            if self.参战单位[编号].溅射~=nil and self.参战单位[编号].溅射~=0 and self:取奇经八脉是否有(编号,"逐胜") == false  then
                  目标=self:取单个敌方目标(编号)
                  if 目标~=0 then
                    if self:取目标状态(编号,目标,1) then
                      self.溅射伤害 = self:取基础物理伤害(编号,目标)
                      self.溅射最终伤害 = self:取最终物理伤害(编号,目标,self.溅射伤害)
                      self.溅射伤害值 =self:取伤害结果(编号,目标,self.溅射最终伤害.伤害,self.溅射最终伤害.暴击,保护)
                      self.伤害输出 = self.溅射伤害值.伤害 * self.参战单位[编号].溅射
                      self:物理同时多个攻击(编号,self.伤害输出,5,名称)--编号,伤害,数量,名称)
                    end
                  end
            end
            if self.参战单位[编号].套装追加概率 == nil then
              self.参战单位[编号].套装追加概率 = 0
            end
            if #self.参战单位[编号].追加法术>0 and 取随机数()<=30+self.参战单位[编号].套装追加概率 and self:取攻击状态(self.执行对象[n]) and self:取奇经八脉是否有(编号,"逐胜") == false then
              self.参战单位[编号].指令.类型="法术"
              self.参战单位[编号].指令.参数=self.参战单位[编号].追加法术[取随机数(1,#self.参战单位[编号].追加法术)].名称
              self:法术计算(self.执行对象[n],1)
            end
          end
        elseif self.参战单位[编号].指令.类型=="法术" then--法术攻击
          local 允许执行 = true
          if 装备特技[self.参战单位[编号].指令.参数]==nil and self:取法术状态(self.执行对象[n]) or (装备特技[self.参战单位[编号].指令.参数]~=nil and self:取特技状态(self.执行对象[n])) then
            local 名称=self.参战单位[编号].指令.参数
            if 名称=="狮搏" or 名称=="鹰击" or 名称=="连环击" or 名称=="象形" then
              if self.参战单位[编号].法术状态.变身==nil then
                if self.参战单位[编号].队伍==0 then
                  self.参战单位[编号].指令.参数="变身"
                end
                允许执行=false
              end
            end
            if 名称=="观照万象" then
              if 老唐定制 and self:取玩家战斗() and self.参战单位[编号].观照万象==nil then
                self.参战单位[编号].观照万象 = 10
              end
              if self.参战单位[编号].观照万象 ~= nil then
                常规提示(self.参战单位[编号].玩家id,"#Y/该技能当前处于冷却中还需："..self.参战单位[编号].观照万象.."回合后才可使用")
              elseif #self.参战单位[编号].主动技能 <= 0 then
                常规提示(self.参战单位[编号].玩家id,"#Y/该召唤兽没有可以释放的主动技能")
              elseif 老五定制 and self:取玩家战斗() then
                常规提示(self.参战单位[编号].玩家id,"#Y/该技能无法在玩家战斗之间使用")
              else
                for i=1,#self.参战单位[编号].主动技能 do
                  if self.参战单位[编号].主动技能[i].名称 ~= "观照万象" then --and self:法攻技能(self.参战单位[编号].主动技能[i].名称)
                    if self.参战单位[编号].主动技能[i].名称 == "法术防御" then
                      self.参战单位[编号].指令.目标=编号
                    end
                    self.参战单位[编号].指令.参数=self.参战单位[编号].主动技能[i].名称
                    self:法术计算(self.执行对象[n],1)
                  end
                end
                self.参战单位[编号].观照万象 = 10
              end
            elseif 允许执行 then
              self:法术计算(self.执行对象[n],1)
              if self.参战单位[编号].指令.参数=="月光" then
                for i=1,取随机数(1,3) do
                  self:法攻技能计算(编号,self.参战单位[编号].指令.参数,self:取技能等级(编号,self.参战单位[编号].指令.参数),1,1)
                end
              end
              if self:取是否物攻技能(名称) and((名称=="破釜沉舟" and self:取奇经八脉是否有(编号,"干将") and 取随机数(1,100)<=20) or  (self:取指定法宝境界(编号,"嗜血幡")~=false and (取随机数(1,100)<=self:取指定法宝境界(编号,"嗜血幡")*1.7) and self:取指定法宝(编号,"嗜血幡",1))) and self:取行动状态(self.执行对象[n]) and self:取目标状态(self.执行对象[n],目标,1)==false then
                目标=self:取单个敌方目标(编号)
                if 目标~=0 then
                  self.参战单位[self.执行对象[n]].指令.目标=目标
                  怒击=self:普通攻击计算(self.执行对象[n],1)
                  if 怒击 and self.参战单位[编号].怒击效果 then
                    目标=self:取单个敌方目标(编号)
                    self.参战单位[self.执行对象[n]].指令.目标=目标
                    if self:取目标状态(self.执行对象[n],目标,1) and self:取行动状态(self.执行对象[n])  then
                      self:普通攻击计算(self.执行对象[n],1)
                      self.参战单位[self.执行对象[n]].指令.目标=目标1
                    end
                  end
                end
              end
            end
          end
        elseif self.参战单位[编号].指令.类型=="道具" and self.参战单位[编号].法术状态.煞气诀==nil and self.参战单位[编号].陌宝==nil  then
          self:道具计算(self.执行对象[n],1)
        elseif self.参战单位[编号].指令.类型=="同门飞镖" then
          local 目标=self.参战单位[编号].指令.目标
          if self:取目标状态(编号,目标,1) then
            self:飞镖计算(编号,{[1]={id=目标,伤害=500}})
          end
        elseif self.参战单位[编号].指令.类型=="特技" then
          if self:取特技状态(self.执行对象[n]) then
            self:法术计算(self.执行对象[n],1)
          end
        elseif self.参战单位[编号].指令.类型=="捕捉" and self.参战单位[编号].类型=="角色" and   self.参战单位[编号].助战编号 == nil then
          self:捕捉计算(self.执行对象[n])
        elseif self.参战单位[编号].指令.类型=="召唤" and self.参战单位[编号].类型=="角色" and   self.参战单位[编号].助战编号 == nil then
          self:召唤计算(self.执行对象[n])
        elseif self.参战单位[编号].指令.类型=="逃跑"  then
          if self.参战单位[编号].类型 == "角色" and self.参战单位[编号].助战明细 ~= nil and #self.参战单位[编号].助战明细 > 0 then
            for i=1,#self.参战单位[编号].助战明细 do
              self.参战单位[self.参战单位[编号].助战明细[i]].指令.类型="逃跑"
            end
          end
          self:逃跑计算(self.执行对象[n])
        end
      end
    end
  end
  for n=1,#self.执行对象 do
    local 编号=self.执行对象[n]
    if self.参战单位[编号].复仇标记 ~= nil and self:取目标状态(self.执行对象[n],self.参战单位[编号].复仇标记,1)  then
        self.参战单位[self.执行对象[n]].指令.目标=self.参战单位[编号].复仇标记
       self:普通攻击计算(self.执行对象[n],1)
    end
  end
end

function 战斗处理类:物理同时多个攻击(编号,伤害,数量,名称)
  if 数量==nil then 数量=1 end
  if 伤害==nil then 伤害=1 end
  self.战斗流程[#self.战斗流程+1]={流程=613,攻击方=编号,挨打方={}}
  self.执行等待=0
  local x挨打 = 0
  local x挨打过的ID={}
  local 是否可攻击 = true
  for i=1,数量 do
    x挨打 = #self.战斗流程[#self.战斗流程].挨打方+1
    目标=self:取单个敌方目标(编号)
    是否可攻击 = true
    if 目标~=0 then
      for n=1,#x挨打过的ID do
        if x挨打过的ID[n]~=nil and x挨打过的ID[n]==目标 then
          是否可攻击 = false
        end
      end
      if 是否可攻击 then
        x挨打过的ID[i]=目标
        self.战斗流程[#self.战斗流程].挨打方[x挨打]={挨打方=目标,伤害=伤害}
        self.战斗流程[#self.战斗流程].挨打方[x挨打].死亡=self:减少气血(目标,伤害,编号,名称)
      end
    end
  end
end

function 战斗处理类:法宝计算(编号)
  local 目标=self.参战单位[编号].指令.目标
  local 道具=self.参战单位[编号].指令.参数
  local id=self.参战单位[编号].玩家id
  local 道具1=玩家数据[id].角色.数据.法宝[道具]
  local 名称=玩家数据[id].道具.数据[道具1].名称
  if 玩家数据[id].道具.数据[道具1].回合~=nil then
    if 玩家数据[id].道具.数据[道具1].回合>self.回合数 then
      self:添加提示(self.参战单位[编号].玩家id,编号,"#Y/该法宝在当前回合无法使用")
      return
    end
  elseif self.参战单位[目标].气血<0 then
    self:添加提示(self.参战单位[编号].玩家id,编号,"#Y/目标已处于死亡状态，无法对其使用法宝")
    return
  elseif self.参战单位[目标].队伍==0 then
    self:添加提示(self.参战单位[编号].玩家id,编号,"#Y/你无法对这样的目标使用法宝")
    return
  elseif 名称=="断线木偶" and self.参战单位[目标].类型=="角色" then
    self:添加提示(self.参战单位[编号].玩家id,编号,"#Y/你无法对这样的目标使用法宝")
    return
  elseif 名称=="无魂傀儡" and self.参战单位[目标].类型~="角色" then
    self:添加提示(self.参战单位[编号].玩家id,编号,"#Y/你无法对这样的目标使用法宝")
    return
  elseif 名称=="无尘扇" and self.参战单位[目标].类型~="角色" then
    self:添加提示(self.参战单位[编号].玩家id,编号,"#Y/你无法对这样的目标使用法宝")
    return
  end
  local 临时物品=取物品数据(玩家数据[id].道具.数据[道具1].名称)
  if 玩家数据[id].角色.数据.等级<临时物品[6] then
    self:添加提示(self.参战单位[编号].玩家id,编号,"#Y/以你目前的等级还无法使用此法宝")
    return
  end
  self.执行等待=self.执行等待+10
  玩家数据[id].道具.数据[道具1].回合=self.回合数+临时物品[8]
  玩家数据[id].道具.数据[道具1].魔法=玩家数据[id].道具.数据[道具1].魔法-1
  发送数据(玩家数据[id].连接id,38,{内容="你的法宝减少了1点灵气"})
  if 名称=="干将莫邪" or 名称=="苍白纸人" or 名称=="五彩娃娃" or 名称=="混元伞" or 名称=="乾坤玄火塔"  then
    self:增益技能计算(编号,名称,0,nil,1,1,玩家数据[id].道具.数据[道具1].气血)
  elseif 名称=="断线木偶" or 名称=="无魂傀儡" or 名称=="无尘扇" then
    self:增益技能计算(编号,名称,0,nil,1,nil,玩家数据[id].道具.数据[道具1].气血)
  elseif 名称=="惊魂铃" or 名称=="鬼泣" or 名称=="摄魂"  or 名称=="无字经" or 名称=="断线木偶" or 名称=="无魂傀儡" or 名称=="发瘟匣" or 名称=="七杀" then
    self:单体封印技能计算(编号,名称,玩家数据[id].道具.数据[道具1].气血,true)
  elseif 名称=="清心咒" then
    self:恢复技能计算(编号,名称,玩家数据[id].道具.数据[道具1].气血,true)
  end
end

function 战斗处理类:道具计算(编号)
  if self.参战单位[编号].道具类型=="法宝" then self:法宝计算(编号) return  end
  local 目标=self.参战单位[编号].指令.目标
  local 道具=self.参战单位[编号].指令.参数
  local id=self.参战单位[编号].玩家id
  local 道具1=玩家数据[id].角色.数据.道具[道具]
  if 道具1==nil or 玩家数据[id].道具.数据[道具1]==nil then
    self:添加提示(self.参战单位[编号].玩家id,编号,"#Y/你没有这样的道具")
    return
  end
  local 道具数据=table.loadstring(table.tostring(玩家数据[id].道具.数据[道具1]))
  local 名称=道具数据.名称
  local 使用=false
  local 加血道具={"金创药","小还丹","千年保心丹","金香玉","五龙丹","天不老","紫石英","血色茶花","熊胆","鹿茸","六道轮回","凤凰尾","硫磺草","龙之心屑","火凤之睛","四叶花","天青地白","七叶莲"}
  local 加魔道具={"翡翠豆腐","佛跳墙","蛇蝎美人","风水混元丹","定神香","十香返生丸","丁香水","月星子","仙狐涎","地狱灵芝","麝香","血珊瑚","餐风饮露","白露为霜","天龙水","孔雀红","紫丹罗","佛手","旋复花","龙须草","百色花","香叶","白玉骨头","鬼切草","灵脂","曼陀罗花"}
  local 复活道具={"佛光舍利子","九转回魂丹"}
  local 酒类道具={"珍露酒","虎骨酒","女儿红","蛇胆酒","醉生梦死","梅花酒","百味酒"}
  local 使用类型=nil
  for n=1,#加血道具 do
    if 加血道具[n]==名称 then
      使用类型=1
    end
  end
  for n=1,#加魔道具 do
    if 加魔道具[n]==名称 then
      使用类型=2
    end
  end
  for n=1,#复活道具 do
    if 复活道具[n]==名称 then
      使用类型=3
    end
  end
  for n=1,#酒类道具 do
    if 酒类道具[n]==名称 then
      使用类型=4
    end
  end
  if 名称=="逍遥镜" then
    使用类型=7
  end
  if 名称=="乾坤袋" then
    使用类型=5
  end
  if 道具数据.总类==2000 then
    使用类型=6
  end
  if 使用类型==nil then self:添加提示(self.参战单位[编号].玩家id,编号,"#Y/此类道具无法在战斗中使用")
    return
  end
  self.执行等待=self.执行等待+8
  if 使用类型==1 then
    local 临时数值=玩家数据[id].道具:取加血道具1(名称,道具1)
    if 编号~=nil and self:取奇经八脉是否有(编号,"安抚") then
      临时数值=qz(临时数字*1.15)
    end
    if 编号~=nil and self:取奇经八脉是否有(编号,"不坏") and self.参战单位[编号].气血<=qz(self.参战单位[编号].最大气血*0.3) then
      临时数值=qz(临时数字*1.3)
    end
    if self.参战单位[目标].法术状态.魔音摄魂 or self.参战单位[目标].气血<=0 then
      return
    else
      self.战斗流程[#self.战斗流程+1]={流程=60,攻击方=编号,挨打方={{挨打方=目标,解除状态={},特效={"加血"}}},提示={允许=true,类型="法术",名称=self.参战单位[编号].名称.."使用了加血"}}
      local 气血=self:取恢复气血(编号,目标,临时数值)
      if self.参战单位[目标].识药特性~=nil then
        气血=qz(气血*(1+self.参战单位[目标].识药特性*0.05))
      end
      self:增加气血(目标,气血)
      self.战斗流程[#self.战斗流程].挨打方[1].恢复气血=气血
      使用=true
      if 名称=="五龙丹" then
          self.战斗流程[#self.战斗流程].挨打方[1].解除状态=self:解除状态结果(self.参战单位[目标],self:取异常状态法术())
        if #self.战斗流程[#self.战斗流程].挨打方[1].解除状态==0 then
          self:添加状态("催眠符",self.参战单位[目标],self.参战单位[编号],150,编号)
          self.参战单位[目标].法术状态.催眠符.回合=5
          self.战斗流程[#self.战斗流程].挨打方[1].添加状态="催眠符"
        end
      end
    end
  elseif 使用类型==2 then
    local 临时数值=玩家数据[id].道具:取加魔道具1(名称,道具1)
    if self.参战单位[目标].识药特性~=nil then
      临时数值=qz(临时数值*(1+self.参战单位[目标].识药特性*0.05))
    end
    if 编号~=nil and self:取奇经八脉是否有(编号,"安抚") then
      临时数值=qz(临时数字*1.15)
    end
    if self.参战单位[目标].法术状态.魔音摄魂 or self.参战单位[目标].气血<=0 then
      return
    else
      self.战斗流程[#self.战斗流程+1]={流程=60,攻击方=编号,挨打方={{挨打方=目标,解除状态={},特效={"加蓝"}}},提示={允许=true,类型="法术",名称=self.参战单位[编号].名称.."使用了加血"}}
      self.参战单位[目标].魔法=self.参战单位[目标].魔法+临时数值
    if self.参战单位[目标].魔法>self.参战单位[目标].最大魔法 then self.参战单位[目标].魔法=self.参战单位[目标].最大魔法 end
      使用=true
    end
  elseif 使用类型==3 then
    local 临时数值=玩家数据[id].道具:取加血道具1(名称,道具1)
    if 编号~=nil and self:取奇经八脉是否有(编号,"安抚") then
      临时数值=qz(临时数字*1.15)
    end
    if self.参战单位[目标].类型~="角色" or self.参战单位[目标].法术状态.魔音摄魂 or self.参战单位[目标].法术状态.死亡召唤 or self.参战单位[目标].气血>0 then
      return
    else
      self.战斗流程[#self.战斗流程+1]={流程=60,攻击方=编号,挨打方={{挨打方=目标,解除状态={},特效={"加血"}}},提示={允许=true,类型="法术",名称=self.参战单位[编号].名称.."使用了加血"}}
      local 气血=self:取恢复气血(编号,目标,临时数值)
    if self.参战单位[目标].识药特性~=nil then
      气血=qz(气血*(1+self.参战单位[目标].识药特性*0.05))
    end
    self:增加气血(目标,气血)
    self.战斗流程[#self.战斗流程].挨打方[1].恢复气血=气血
    self.战斗流程[#self.战斗流程].挨打方[1].复活=true
    使用=true
    end
  elseif 使用类型==4 then
    临时数值=玩家数据[id].道具:取加魔道具1(名称,道具1)
    if 编号~=nil and self:取奇经八脉是否有(编号,"安抚") then
      临时数值=qz(临时数字*1.15)
    end
    if self.参战单位[目标].类型~="角色" or self.参战单位[目标].法术状态.魔音摄魂 or self.参战单位[目标].气血<=0 then
      return
    else
    --self.战斗流程[#self.战斗流程+1]={流程=60,攻击方=编号,挨打方={{挨打方=目标,解除状态={},特效={"加蓝"}}},提示={允许=true,类型="法术",名称=self.参战单位[编号].名称.."使用了加血"}}
      self.参战单位[目标].愤怒=self.参战单位[目标].愤怒+临时数值
      if self.参战单位[目标].愤怒>150 then self.参战单位[目标].愤怒=150 end
      使用=true
      if 名称=="女儿红" or 名称=="梅花酒"  then
        self.战斗流程[#self.战斗流程+1]={流程=207,攻击方=编号,挨打方={{挨打方=目标,增加状态="催眠符",特效={"加血"}}}}
        self:添加状态("催眠符",self.参战单位[目标],self.参战单位[编号],150,编号)
        self.参战单位[目标].法术状态.催眠符.回合=取随机数(2,3)
        self.战斗流程[#self.战斗流程].挨打方[1].添加状态="催眠符"
      elseif 名称=="蛇胆酒" then
        self.参战单位[目标].防御=self.参战单位[目标].防御-qz(临时数值*1.5)
      elseif 名称=="百味酒" then
        if 取随机数()<=50 then
          self.战斗流程[#self.战斗流程+1]={流程=207,攻击方=编号,挨打方={{挨打方=目标,增加状态="催眠符",特效={"加血"}}}}
          self:添加状态("催眠符",self.参战单位[目标],self.参战单位[编号],150,编号)
          self.参战单位[目标].法术状态.催眠符.回合=取随机数(2,3)
          self.战斗流程[#self.战斗流程].挨打方[1].添加状态="催眠符"
        else
          self.战斗流程[#self.战斗流程+1]={流程=207,攻击方=编号,挨打方={{挨打方=目标,增加状态="毒",特效={"加血"}}}}
          self:添加状态("毒",self.参战单位[目标],self.参战单位[编号],150,编号)
          self.参战单位[目标].法术状态.毒.回合=5
          self.战斗流程[#self.战斗流程].挨打方[1].添加状态="毒"
        end
      elseif 名称=="醉生梦死" or 名称=="虎骨酒"  then
      self.战斗流程[#self.战斗流程+1]={流程=207,攻击方=编号,挨打方={{挨打方=目标,增加状态="疯狂",特效={"加血"}}}}
      self:添加状态("疯狂",self.参战单位[目标],self.参战单位[编号],150,编号)
      self.参战单位[目标].法术状态.疯狂.回合=取随机数(2,3)
      -- self.战斗流程[#self.战斗流程].挨打方[1].添加状态="疯狂"
      end
    end
  elseif 使用类型==5 then
    if self.参战单位[目标].乾坤袋==nil then
      self:添加提示(self.参战单位[编号].玩家id,编号,"#Y/你无法对此类目标使用乾坤袋")
      return
    elseif self.参战单位[编号].类型~="角色" then
      self:添加提示(self.参战单位[编号].玩家id,编号,"#Y/只有角色才可以使用此道具")
      return
    else
      self.战斗流程[#self.战斗流程+1]={流程=56,攻击方=编号,挨打方={},提示={允许=true,类型="法术",名称=self.参战单位[编号].名称.."使用了"..名称}}
      self.战斗流程[#self.战斗流程].挨打方[1]={挨打方=目标,特效={"水遁"}}
      local 百分比=qz(100-self.参战单位[编号].气血/self.参战单位[编号].最大气血*100)
      百分比=百分比+20
      if 百分比>=取随机数() then
        self.战斗流程[#self.战斗流程].挨打方[1].气血=self.参战单位[目标].气血
        self.战斗流程[#self.战斗流程].挨打方[1].死亡=self:减少气血(目标,self.参战单位[目标].气血,编号)
        任务数据[self.任务id].乾坤袋=true
        玩家数据[self.参战单位[编号].玩家id].角色:刷新任务跟踪()
      end
    end
  elseif 使用类型==6 then
    local 等级=self:取技能等级(编号,"满天花雨")
    local 人数=1
    local 等级伤害=0
    local 伤害=道具数据.分类
    local 暗器伤害=0
    人数 = math.floor(等级/25)+1
    if 等级 == 0 then
      等级 = 30
    end
    等级伤害 = math.floor(等级/4)*伤害
    暗器伤害=math.floor(玩家数据[self.参战单位[编号].玩家id].角色:取生活技能等级("暗器技巧")*5)

    local 目标组=self:取多个敌方目标(编号,目标,人数)
    伤害=伤害+暗器伤害+等级伤害

    if self.参战单位[编号].固定伤害 ~= nil then
      伤害 = 伤害 + self.参战单位[编号].固定伤害
    end
    if self:取玩家战斗() then
      伤害 = math.floor(伤害*0.2)
    else
      local 女儿数量 = 0
      for i=1,#self.参战玩家 do
        if 玩家数据[self.参战玩家[i].id].角色.数据.门派 == "女儿村" then
          女儿数量 = 女儿数量 +1
        end
      end
      if 女儿数量 >=2 then
        伤害 = math.floor(伤害*0.5)
      end
    end

    if #目标组>0 then
      self.战斗流程[#self.战斗流程+1]={流程=611,攻击方=编号,挨打方={},提示={允许=true,类型="法术",名称=self.参战单位[编号].名称.."使用了"..名称}}
      for n=1,#目标组 do
        self.战斗流程[#self.战斗流程].挨打方[n]={挨打方=目标组[n],伤害=self:取固伤结果(编号,伤害,目标组[n])}
        self.战斗流程[#self.战斗流程].挨打方[n].死亡=self:减少气血(目标组[n],self.战斗流程[#self.战斗流程].挨打方[n].伤害,编号,名称)
        if 等级 > 30 and 取随机数()<=20 then
          self:添加状态("毒",self.参战单位[目标组[n]],self.参战单位[编号],等级,编号)
          self.战斗流程[#self.战斗流程].挨打方[n].增加状态="毒"
        end
      end
      玩家数据[id].道具.数据[道具1].耐久=玩家数据[id].道具.数据[道具1].耐久-0.5
      if 玩家数据[id].道具.数据[道具1].耐久<=0 then
        玩家数据[id].道具.数据[道具1]=nil
        玩家数据[id].角色.数据.道具[道具]=nil
      end
      return
    end
  elseif 使用类型==7 then
    if self.参战单位[编号].类型~="角色" then
      self:添加提示(self.参战单位[编号].玩家id,编号,"#Y/只有角色才可以使用此道具")
      return
    elseif 道具数据.绑定孩子 == nil then
      self:添加提示(self.参战单位[编号].玩家id,编号,"#Y/该道具内没有孩子存在")
      return
    elseif self.参战单位[编号].孩子召唤 ~= nil then
      self:添加提示(self.参战单位[编号].玩家id,编号,"#Y/一场战斗中只能召唤一只孩子出战")
      return
    else
      local 临时目标 = 玩家数据[id].孩子:取编号(道具数据.绑定孩子.认证码)
      if 临时目标 == 0 then
        self:添加提示(self.参战单位[编号].玩家id,编号,"#Y/该孩子不存在")
        return
      else
        self.参战单位[编号].指令={下达=true,类型="召唤",目标=临时目标,敌我=0,参数="",附加=""}
        self:召唤计算(编号,true)
        self.参战单位[编号].孩子召唤 = 1
      end
    end
  end
  if 使用 then
    if 道具数据.数量~=nil then
      玩家数据[id].道具.数据[道具1].数量=玩家数据[id].道具.数据[道具1].数量-1
    end
      if 玩家数据[id].道具.数据[道具1].数量==nil or 玩家数据[id].道具.数据[道具1].数量<=0 then
        玩家数据[id].道具.数据[道具1]=nil
        玩家数据[id].角色.数据.道具[道具]=nil
      end
    end
  end

function 战斗处理类:逃跑计算(编号)
  local 成功=true
  local 几率=50
  if self.参战单位[编号].队伍==0 or self.参战单位[编号].助战编号~= nil then
    几率=100
  end
  if 取随机数()<=几率 then
    成功=true
  end
  self.执行等待=self.执行等待+10
  local 结束=false
  if 成功 and self.参战单位[编号].类型=="角色" then
    结束=true
    if #self.参战玩家==1 then
      self.全局结束=true
    end --不再执行动作
  end
  if 成功 then
    self.参战单位[编号].逃跑=true
  end
  if self.参战单位[编号].队伍==0  then
    self.战斗流程[#self.战斗流程+1]={流程=601,攻击方=编号,id=0,挨打方={{挨打方=1}},成功=成功,结束=结束}
    if self.参战单位[编号].捉鬼变异 then
      任务数据[self.任务id].变异奖励=true
    end
    return
  else
    self.战斗流程[#self.战斗流程+1]={流程=601,攻击方=编号,id=self.参战单位[编号].玩家id,挨打方={{挨打方=1}},成功=成功,结束=结束}
  end
  --计算召唤兽
  if 成功 then
    local id=self.参战单位[编号].玩家id
    local 临时编号=0
    if self.参战单位[编号].类型~="角色"  then
      if self.参战单位[编号].是否孩子 == nil then
        for n=1,#玩家数据[id].召唤兽.数据 do
          if 玩家数据[id].召唤兽.数据[n].认证码==玩家数据[id].角色.数据.参战宝宝.认证码 then
            玩家数据[id].召唤兽.数据[n].参战信息=nil
            临时编号=n
          end
        end
        玩家数据[id].角色.数据.参战宝宝={}
        玩家数据[id].角色.数据.参战信息=nil
        发送数据(玩家数据[id].连接id,18,玩家数据[id].角色.数据.参战宝宝)
      end
    else
      if self.参战单位[编号].召唤兽~=nil and self.参战单位[self.参战单位[编号].召唤兽]~=nil then
        -- self.战斗流程[#self.战斗流程].追加={[1]=self.参战单位[编号].召唤兽}
        self.战斗流程[#self.战斗流程].追加=self.参战单位[编号].召唤兽
        self.参战单位[self.参战单位[编号].召唤兽].逃跑=true
      end
      -- if self.参战单位[编号].助战明细 ~= nil and #self.参战单位[编号].助战明细>0 then
      --   for i=1,#self.参战单位[编号].助战明细 do
      --     if self.参战单位[self.参战单位[编号].助战明细[i]] ~= nil then
      --       self.战斗流程[#self.战斗流程+1]={流程=601,攻击方=编号,id=self.参战单位[编号].玩家id,挨打方={{挨打方=1}},成功=成功,结束=结束}
      --       self.参战单位[self.参战单位[编号].助战明细[i]].逃跑=true
      --     end
      --   end
      -- end
    end
  end
end

function 战斗处理类:召唤计算(编号,孩子)
  local id=self.参战单位[编号].召唤兽
  local 目标=self.参战单位[编号].指令.目标
  local 玩家id=self.参战单位[编号].玩家id
  if id~=nil and self.参战单位[id].法术状态.复活~=nil then
    self:添加提示(self.参战单位[编号].玩家id,编号,"#Y/你有召唤兽尚在复活中，暂时无法召唤新的召唤兽")
    return
  elseif #self.参战单位[编号].召唤数量>=5 then
    self:添加提示(self.参战单位[编号].玩家id,编号,"#Y/你在本次战斗中可召唤的数量已达上限")
    return
  elseif 孩子 == nil and 玩家数据[玩家id].召唤兽.数据[目标].等级 > 玩家数据[玩家id].角色.数据.等级+10 then
    self:添加提示(self.参战单位[编号].玩家id,编号,"#Y/以你目前的实力还无法驾驭该等级的召唤兽")
    return
  end
  if 孩子 == nil then
    for n=1,#self.参战单位[编号].召唤数量 do
      if self.参战单位[编号].召唤数量[n]==目标 then
        self:添加提示(self.参战单位[编号].玩家id,编号,"#Y/这只召唤兽已经出战过了")
        return
      end
    end
  end
  self.执行等待=self.执行等待+2
  if id==nil then
    self:设置队伍区分(self.参战单位[编号].队伍)
    id=#self.参战单位+1
  end
  self.参战单位[id]={}
  if 孩子 == nil then
    self.参战单位[id]=table.loadstring(玩家数据[玩家id].召唤兽:获取指定数据(目标))
  else
    self.参战单位[id]=table.loadstring(玩家数据[玩家id].孩子:获取指定数据(目标))
  end
  self.参战单位[id].队伍=self.参战单位[编号].队伍
  self.参战单位[id].位置=self.参战单位[编号].位置+5
  self.参战单位[id].类型="bb"
  self.参战单位[id].是否孩子=孩子
  self.参战单位[id].主人=编号
  self.参战单位[id].玩家id=玩家id
  self.参战单位[id].附加阵法=self.参战单位[编号].附加阵法
  self.参战单位[id].法防=qz(self.参战单位[id].魔力*0.4+self.参战单位[id].等级)
  self.参战单位[id].命中=self.参战单位[id].伤害
  self.参战单位[id].躲闪=0
  self.参战单位[id].自动战斗=self.参战单位[编号].自动战斗
  self.参战单位[编号].召唤兽=id
  self.参战单位[id].已加技能={}
  self.参战单位[id].主动技能={}
  if 孩子 == nil then
    self.参战单位[编号].召唤数量[#self.参战单位[编号].召唤数量+1]=目标
  end
  self.参战单位[id].指令={下达=false,类型="",目标=0,敌我=0,参数="",附加=""}
  self.参战单位[id].攻击修炼=玩家数据[self.参战单位[id].玩家id].角色.数据.bb修炼.攻击控制力[1]
  self.参战单位[id].法术修炼=玩家数据[self.参战单位[id].玩家id].角色.数据.bb修炼.法术控制力[1]
  self.参战单位[id].防御修炼=玩家数据[self.参战单位[id].玩家id].角色.数据.bb修炼.防御控制力[1]
  self.参战单位[id].抗法修炼=玩家数据[self.参战单位[id].玩家id].角色.数据.bb修炼.抗法控制力[1]
  self.参战单位[id].法术状态={}
  self.参战单位[id].奇经八脉={}
  self.参战单位[id].追加法术={}
  self.参战单位[id].附加状态={}
  self.参战单位[id].驱怪=0
  self.参战单位[id].慈悲效果=0
  self.参战单位[id].怒击效果=false
  self.参战单位[id].猎术修炼=0
  self.参战单位[id].毫毛次数=0
  self.参战单位[id].法宝佩戴={}
  self.参战单位[id].攻击五行=""
  self.参战单位[id].防御五行=""
  self.参战单位[id].攻击五行=""
  self.参战单位[id].防御五行=""
  self:添加bb法宝属性(id,玩家id)
  local 临时技能={}
  for n=1,#玩家数据[玩家id].召唤兽.数据 do
    if 玩家数据[玩家id].角色.数据.参战宝宝 ~= nil and 玩家数据[玩家id].召唤兽.数据[n].认证码==玩家数据[玩家id].角色.数据.参战宝宝.认证码 then
      玩家数据[玩家id].召唤兽.数据[n].参战信息=nil
    end
  end
  玩家数据[玩家id].角色.数据.参战宝宝={}
  if 孩子==nil then
    玩家数据[玩家id].角色.数据.参战宝宝=table.loadstring(table.tostring(玩家数据[玩家id].召唤兽:取存档数据(目标)))
    玩家数据[玩家id].召唤兽.数据[目标].参战信息=1
  else
    玩家数据[玩家id].角色.数据.参战宝宝=table.loadstring(table.tostring(玩家数据[玩家id].孩子:取存档数据(目标)))
    玩家数据[玩家id].孩子.数据[目标].参战信息=1
  end
  玩家数据[玩家id].角色.数据.参战信息=1
  发送数据(玩家数据[玩家id].连接id,18,玩家数据[玩家id].角色.数据.参战宝宝)
  self.战斗流程[#self.战斗流程+1]={流程=600,攻击方=编号,挨打方={{挨打方=id,队伍=self.参战单位[编号].队伍,数据=self:取加载信息(id)}}}
  self:单独重置属性(id)
  if self.参战单位[id].隐身~=nil then
    self.参战单位[id].指令={目标=id}
    self:增益技能计算(id,"修罗隐身",self.参战单位[id].等级)
    if self.参战单位[id].法术状态.修罗隐身~=nil then
      self.参战单位[id].法术状态.修罗隐身.回合=self.参战单位[id].隐身
    end
  end
  if self.回合数>=2 then
    if self.参战单位[id].特性 ~= nil then
      self:添加状态特性(id)
    end
    if self:取技能重复(self.参战单位[id],"开门见山") then
      self.参战单位[id].指令.目标=self:取单个敌方目标(id)
      self:普通攻击计算(id,1)
    elseif self.回合数>=5 and self:取技能重复(self.参战单位[id],"峰回路转") then
          self.参战单位[id].指令.目标=self:取单个友方目标(id)
          self:恢复技能计算(编号,"峰回路转",self.参战单位[id].等级,1)
    end
  end
  for i=1,#self.参战单位 do
    if self.参战单位[i].队伍 == self.参战单位[id].队伍 and self.参战单位[i].助战宝宝 ~= nil then
      local 位置 = self.参战单位[i].位置
      local id = i
      self.执行等待=self.执行等待+2
      self.参战单位[id]={}
      self.参战单位[id]=table.loadstring(玩家数据[玩家id].召唤兽:获取指定数据(目标))
      self.参战单位[id].队伍=self.参战单位[编号].队伍
      self.参战单位[id].位置=位置
      self.参战单位[id].类型="bb"
      self.参战单位[id].主人=编号
      self.参战单位[id].玩家id=玩家id
      self.参战单位[id].附加阵法=self.参战单位[编号].附加阵法
      self.参战单位[id].法防=qz(self.参战单位[id].魔力*0.4+self.参战单位[id].等级)
      self.参战单位[id].命中=self.参战单位[id].伤害
      self.参战单位[id].躲闪=0
      self.参战单位[id].自动战斗=self.参战单位[编号].自动战斗
      self.参战单位[编号].召唤兽=id
      self.参战单位[id].已加技能={}
      self.参战单位[id].主动技能={}
      self.参战单位[编号].召唤数量[#self.参战单位[编号].召唤数量+1]=目标
      self.参战单位[id].指令={下达=false,类型="",目标=0,敌我=0,参数="",附加=""}
      self.参战单位[id].攻击修炼=玩家数据[self.参战单位[id].玩家id].角色.数据.bb修炼.攻击控制力[1]
      self.参战单位[id].法术修炼=玩家数据[self.参战单位[id].玩家id].角色.数据.bb修炼.法术控制力[1]
      self.参战单位[id].防御修炼=玩家数据[self.参战单位[id].玩家id].角色.数据.bb修炼.防御控制力[1]
      self.参战单位[id].抗法修炼=玩家数据[self.参战单位[id].玩家id].角色.数据.bb修炼.抗法控制力[1]
      self.参战单位[id].法术状态={}
      self.参战单位[id].奇经八脉={}
      self.参战单位[id].追加法术={}
      self.参战单位[id].附加状态={}
      self.参战单位[id].驱怪=0
      self.参战单位[id].慈悲效果=0
      self.参战单位[id].怒击效果=false
      self.参战单位[id].猎术修炼=0
      self.参战单位[id].毫毛次数=0
      self.参战单位[id].法宝佩戴={}
      self.参战单位[id].攻击五行=""
      self.参战单位[id].防御五行=""
      self.参战单位[id].攻击五行=""
      self.参战单位[id].防御五行=""
      self:添加bb法宝属性(id,玩家id)
      local 临时技能={}
      for n=1,#玩家数据[玩家id].召唤兽.数据 do
        if 玩家数据[玩家id].召唤兽.数据[n].认证码==玩家数据[玩家id].角色.数据.参战宝宝.认证码 then
          玩家数据[玩家id].召唤兽.数据[n].参战信息=nil
        end
      end
      if 孩子 == nil then
        玩家数据[玩家id].角色.数据.参战宝宝={}
        玩家数据[玩家id].角色.数据.参战宝宝=table.loadstring(table.tostring(玩家数据[玩家id].召唤兽:取存档数据(目标)))
        玩家数据[玩家id].召唤兽.数据[目标].参战信息=1
      else
        玩家数据[玩家id].角色.数据.参战宝宝={}
        玩家数据[玩家id].角色.数据.参战宝宝=table.loadstring(table.tostring(玩家数据[玩家id].孩子:取存档数据(目标)))
        玩家数据[玩家id].孩子.数据[目标].参战信息=1
      end
      玩家数据[玩家id].角色.数据.参战信息=1
      发送数据(玩家数据[玩家id].连接id,18,玩家数据[玩家id].角色.数据.参战宝宝)
      self.战斗流程[#self.战斗流程+1]={流程=600,攻击方=编号,挨打方={{挨打方=id,队伍=self.参战单位[编号].队伍,数据=self:取加载信息(id)}}}
      self:单独重置属性(id)
      if self.参战单位[id].隐身~=nil then
        self.参战单位[id].指令={目标=id}
        self:增益技能计算(id,"修罗隐身",self.参战单位[id].等级)
        if self.参战单位[id].法术状态.修罗隐身~=nil then
          self.参战单位[id].法术状态.修罗隐身.回合=self.参战单位[id].隐身
        end
      end
      if self.回合数>=2 then
        if self.参战单位[id].特性 ~= nil then
          self:添加状态特性(id)
        end
        if self:取技能重复(self.参战单位[id],"开门见山") then
          self.参战单位[id].指令.目标=self:取单个敌方目标(id)
          self:普通攻击计算(id,1)
        elseif self.回合数>=5 and self:取技能重复(self.参战单位[id],"峰回路转") then
          self.参战单位[id].指令.目标=self:取单个友方目标(id)
          self:恢复技能计算(编号,"峰回路转",self.参战单位[id].等级,1)
        end
      end
    end
  end
end

function 战斗处理类:单独重置属性(n)
  self.参战单位[n].法术状态={}
  self.参战单位[n].奇经八脉={}
  self.参战单位[n].追加法术={}
  self.参战单位[n].附加状态={}
  self.参战单位[n].攻击修炼=0
  self.参战单位[n].法术修炼=0
  self.参战单位[n].防御修炼=0
  self.参战单位[n].抗法修炼=0
  self.参战单位[n].猎术修炼=0
  if self.参战单位[n].主动技能==nil then
    self.参战单位[n].主动技能={}
  end
  self.参战单位[n].特技技能={}
  self.参战单位[n].战意=0
  self.参战单位[n].法暴=0
  self.参战单位[n].法防=0
  self.参战单位[n].必杀=1
  self.参战单位[n].攻击五行=""
  self.参战单位[n].防御五行=""
  self.参战单位[n].修炼数据={法修=0,抗法=0,攻击=0,法防=0,猎术=0}
  if self.参战单位[n].命中==nil then self.参战单位[n].命中=self.参战单位[n].伤害 end
  for i=1,#灵饰战斗属性 do
    self.参战单位[n][灵饰战斗属性[i]]=0
  end
  if self.参战单位[n].类型~="角色" then
    self:添加技能属性(self.参战单位[n],self.参战单位[n].技能)
    if self.参战单位[n].是否孩子 == nil then
      self:添加内丹属性(self.参战单位[n],self.参战单位[n].内丹)
    end
    self.参战单位[n].攻击修炼=玩家数据[self.参战单位[n].玩家id].角色.数据.bb修炼.攻击控制力[1]
    self.参战单位[n].法术修炼=玩家数据[self.参战单位[n].玩家id].角色.数据.bb修炼.法术控制力[1]
    self.参战单位[n].防御修炼=玩家数据[self.参战单位[n].玩家id].角色.数据.bb修炼.防御控制力[1]
    self.参战单位[n].抗法修炼=玩家数据[self.参战单位[n].玩家id].角色.数据.bb修炼.抗法控制力[1]
  end
end

function 战斗处理类:捕捉计算(编号)
  if self.战斗类型~=100001 and self.战斗类型~=100005 and self.战斗类型~=100007  then
    return
  end
  local 目标=self.参战单位[编号].指令.目标

  if self:取目标状态(攻击,目标,1)==false then
    self:添加提示(self.参战单位[编号].玩家id,编号,"#Y/目标当前无法被捕获")
    return
  elseif self.参战单位[目标].类型=="角色" or self.参战单位[目标].类型=="召唤" then
    self:添加提示(self.参战单位[编号].玩家id,编号,"#Y/非法修改数据已做警告!")
    __S服务:输出("#Y/玩家"..self.参战单位[编号].玩家id.." 非法修改数据警告!抓捕召唤兽")
    return
  elseif self.参战单位[目标].精灵 then
    self:添加提示(self.参战单位[编号].玩家id,编号,"#Y/你无法捕获这样的目标")
    return
  elseif self.参战单位[目标].参战等级~=nil and self.参战单位[目标].参战等级 > self.参战单位[编号].等级 then
    self:添加提示(self.参战单位[编号].玩家id,编号,"#Y/你目前等级无法捕获这样的目标")
    return
  elseif self.参战单位[编号].魔法<qz(self.参战单位[目标].等级*0.5+20) then
    self:添加提示(self.参战单位[编号].玩家id,编号,"#Y/你没有足够的魔法")
    return
  elseif 玩家数据[self.参战单位[编号].玩家id].角色:取新增宝宝数量()==false then
    self:添加提示(self.参战单位[编号].玩家id,编号,"#Y/你当前无法携带更多的召唤兽")
    return
  end
  self.执行等待=self.执行等待+15
  self.参战单位[编号].魔法=self.参战单位[编号].魔法-qz(self.参战单位[目标].等级*0.5+20)
  self.战斗流程[#self.战斗流程+1]={流程=300,攻击方=编号,挨打方={{挨打方=目标}}}
  local 初始几率=20
  初始几率=初始几率+qz(self.参战单位[目标].最大气血/self.参战单位[目标].气血)*10+qz(self.参战单位[目标].猎术修炼*3)
  self.战斗流程[#self.战斗流程].宝宝=玩家数据[self.参战单位[编号].玩家id].角色.数据.宠物.模型
  self.战斗流程[#self.战斗流程].名称=玩家数据[self.参战单位[编号].玩家id].角色.数据.宠物.名称
  if 取随机数()<=初始几率 then
    self.战斗流程[#self.战斗流程].捕捉成功=true
    玩家数据[self.参战单位[编号].玩家id].召唤兽:添加召唤兽(self.参战单位[目标].模型,self.参战单位[目标].分类,self.参战单位[目标].分类,false,self.参战单位[目标].等级)
    self.参战单位[目标].气血=0
    self.参战单位[目标].捕捉=true
    self:添加提示(self.参战单位[编号].玩家id,编号,"#Y/你成功捕获了#R/"..self.参战单位[目标].名称)
  end
end

function 战斗处理类:法术计算(编号)
  local 名称=self.参战单位[编号].指令.参数
  local 目标=self.参战单位[编号].指令.目标
  local 等级=self:取技能等级(编号,名称)
  if 名称=="高级连击" or 名称 == "理直气壮" or 名称 == "牛刀小试" then
    等级=self.参战单位[编号].等级
    if 等级 == 0 then
      等级=10
    end
  end
  if 等级==0 and 装备特技[名称]==nil then
    return
  end
  if self:物攻技能(名称) or 名称=="当头一棒" or 名称=="神针撼海" or 名称=="杀威铁棒" or 名称=="泼天乱棒" then
    self:物攻技能计算(编号,名称,等级)
  elseif self:封印技能(名称) then
    self:单体封印技能计算(编号,名称,等级)
  elseif self:增益技能(名称) then
    self:增益技能计算(编号,名称,等级)
  elseif self:减益技能(名称) then
    self:减益技能计算(编号,名称,等级)
  elseif self:法攻技能(名称) then
    self:法攻技能计算(编号,名称,等级,1)
    if self.参战单位[编号].法连~=nil and self.参战单位[编号].法连>=取随机数() then
      self:法攻技能计算(编号,名称,等级,0.5)
    end
  elseif self:恢复技能(名称) then
    self:恢复技能计算(编号,名称,等级)
  elseif 名称=="妙手空空" then
    self:妙手空空计算(编号,名称,等级)
  end
end

function 战斗处理类:添加提示(id,攻击方,内容)
  if self.参战单位[攻击方].队伍==0 then return  end
  self.战斗流程[#self.战斗流程+1]={流程=900,攻击方=攻击方,id=id,内容=内容}
end

function 战斗处理类:添加提示1(id,攻击方,内容)
  self.战斗流程[#self.战斗流程+1]={流程=901,攻击方=攻击方,id=id,内容=内容}
  if self.参战单位[攻击方].队伍==0 then return  end
end

function 战斗处理类:飞镖计算(编号,id组)
  self.战斗流程[#self.战斗流程+1]={流程=611,攻击方=编号,挨打方={}}
  self.执行等待=self.执行等待+10
  --print(#id组)
  for n=1,#id组 do
    --print(self:取目标状态(编号,id组[n].id,1),id组[n].id)
    if self:取目标状态(编号,id组[n].id,1) then
      self.战斗流程[#self.战斗流程].挨打方[#self.战斗流程[#self.战斗流程].挨打方+1]={挨打方=id组[n].id,伤害=id组[n].伤害}
      self.战斗流程[#self.战斗流程].挨打方[#self.战斗流程[#self.战斗流程].挨打方].死亡=self:减少气血(id组[n].id,id组[n].伤害,编号,名称)
    end
  end
end

function 战斗处理类:妙手空空计算(编号,名称,等级)
  local 目标=self.参战单位[编号].指令.目标
  if 目标==nil or self.参战单位[目标].气血<=0 then
    self:添加提示(self.参战单位[编号].玩家id,编号,"#Y/对方已经死了，你忍心从尸体上偷东西？")
    return
  elseif self.战斗类型~=100001 and self.战斗类型~=100007  then
    return
  elseif self.参战单位[目标].偷盗 then
    self:添加提示(self.参战单位[编号].玩家id,编号,"#Y/对方身上已经没有宝物了")
    return
  elseif self:技能消耗(self.参战单位[编号],self.参战单位[目标].等级,名称,编号)==false then
    self:添加提示(self.参战单位[编号].玩家id,编号,"#Y/你当前状态无法使用该技能")
    return
  end
  self.执行等待=self.执行等待+1
  local id=self.参战单位[编号].玩家id
  if  self.参战单位[目标].精灵==nil then
    if 等级*10>=取随机数() then
      local 随机金钱=取随机数(10,100)
      玩家数据[id].角色:添加银子(随机金钱,"[战斗]妙手空空从"..self.参战单位[目标].名称.."、"..self.参战单位[目标].模型.."身上盗取")
      self:添加提示1(self.参战单位[编号].玩家id,编号,"你得到了"..随机金钱.."金钱")
      self.参战单位[目标].偷盗=true
      return
    else
      self:添加提示1(self.参战单位[编号].玩家id,编号,"对方发觉了你这个行为，机灵地躲过去了！")
    end
  elseif self.参战单位[目标].精灵 then
    if 等级*10>=取随机数() then
      local 奖励参数=取随机数(1,100)
      if  奖励参数<=40 then
        local 随机金钱=取随机数(500,10000)
        玩家数据[id].角色:添加银子(随机金钱,"[战斗]妙手空空从"..self.参战单位[目标].名称.."、"..self.参战单位[目标].模型.."身上盗取")
        self:添加提示1(self.参战单位[编号].玩家id,编号,"你得到了"..随机金钱.."金钱")
      elseif 奖励参数<=60 then
        玩家数据[id].道具:给予道具(id,"金柳露")
        self:添加提示1(self.参战单位[编号].玩家id,编号,"你得到了#R/金柳露")
      elseif 奖励参数<=80 then
        local 临时等级=math.floor(self.参战单位[目标].等级/10)
        if 临时等级>8 then 临时等级=8 end
        if 临时等级>2 then
          临时等级=取随机数(临时等级-1,临时等级)
        end
        local 临时名称=玩家数据[id].道具:取随机装备(id,临时等级,true)
        self:添加提示1(self.参战单位[编号].玩家id,编号,"你得到了#R/"..临时名称)

      else
        if 变身卡数据[self.参战单位[目标].模型]~=nil then
          玩家数据[id].道具:给予道具(id,"怪物卡片",self.参战单位[目标].模型)
          self:添加提示1(self.参战单位[编号].玩家id,编号,"你得到了#R/怪物卡片")
        else
          local 随机金钱=取随机数(500,10000)
          玩家数据[id].角色:添加银子(随机金钱,"[战斗]妙手空空从"..self.参战单位[目标].名称.."、"..self.参战单位[目标].模型.."身上盗取")
          self:添加提示1(self.参战单位[编号].玩家id,编号,"你得到了"..随机金钱.."金钱")
        end
      end
      self.参战单位[目标].偷盗=true
      return
    else
      self:添加提示1(self.参战单位[编号].玩家id,编号,"对方发觉了你这个行为，机灵地躲过去了！")
    end
  end
end

function 战斗处理类:恢复技能计算(编号,名称,等级)
  local 目标=self.参战单位[编号].指令.目标
  local 目标数=0
  if 名称=="清心咒" or 名称=="归元咒" or 名称=="乾天罡气" or 名称=="气归术" or 名称=="命归术" or 名称=="凝神诀" or 名称=="凝气诀" then
      目标=编号
  end
  if 名称~="我佛慈悲" and 名称 ~= "慈航普渡"  and 名称~="杨柳甘露" and 名称~="还魂咒" and 名称~="起死回生" and 名称~="回魂咒" and 名称~="还阳术" and 名称~="莲花心音" and 名称~="由己渡人" then
      目标数=self:取目标数量(self.参战单位[编号],名称,等级,编号)
      目标=self:取多个友方目标(编号,目标,目标数,名称)
  elseif 名称 == "慈航普渡" then
      目标=self:取多个友方目标(编号,目标,5,名称)
      for i=1,#目标 do
        if self.参战单位[目标[i]].气血>0 or (self.参战单位[目标[i]].法术状态.死亡召唤~=nil and self.参战单位[目标[i]].法术状态.死亡召唤) or self.参战单位[目标[i]].类型 ~= "角色" then
          table.remove(目标,i)
        end
      end
  else
    if self.参战单位[目标] == nil or self.参战单位[目标].气血 ==nil or self.参战单位[目标].气血>0 or self.参战单位[目标].法术状态 == nil or self.参战单位[目标].法术状态.死亡召唤 or self.参战单位[目标].类型 ~= "角色" then
      return
    else
      if 名称=="莲花心音" then
        if self.参战单位[目标].类型=="角色" or self.参战单位[目标].法术状态.鬼魂==nil then
          return
        end
      end
      目标={目标}
    end
  end
  if 名称=="妙悟" and self.参战单位[编号].妙悟回合~=nil and self.回合数-self.参战单位[编号].妙悟回合<5 then
    self:添加提示(self.参战单位[编号].玩家id,编号,"#Y/该技能必须等待#R/"..(5-(self.回合数-self.参战单位[编号].妙悟回合)).."#Y/回合后才可使用")
    return
  end
  for i=1,#目标 do
    if self.参战单位[目标[i]] == nil then
      table.remove(目标,i)
    end
  end
  if #目标==0 then return end
  目标数=#目标
  if self:技能消耗(self.参战单位[编号],目标数,名称,编号)==false then  self:添加提示(self.参战单位[编号].玩家id,编号,"#Y/你当前状态无法使用该技能")return  end
   self.战斗流程[#self.战斗流程+1]={流程=60,攻击方=编号,挨打方={}}
  self.执行等待=self.执行等待+10
  local 气血=0
  for n=1,目标数 do
      local 状态名称={}
      self.战斗流程[#self.战斗流程].挨打方[n]={挨打方=目标[n],特效={名称}}
      if 名称=="驱尸" or 名称=="解毒" or 名称=="清心" or 名称=="百毒不侵" then
         状态名称=self:解除状态结果(self.参战单位[目标[n]],{"尸腐毒","毒","雾杀"})
         if 名称=="百毒不侵" then
             self:添加状态(名称,self.参战单位[目标[n]],self.参战单位[编号],等级,编号)
             self.战斗流程[#self.战斗流程].挨打方[n].添加状态=名称
           end
        elseif 名称=="无穷妙道" then
         状态名称=self:解除状态结果(self.参战单位[目标[n]],self:取门派封印法术("无底洞"))
         --self:添加状态(名称,self.参战单位[目标[n]],self.参战单位[编号],等级,编号)
          self.战斗流程[#self.战斗流程].挨打方[n].添加状态=名称
        elseif 名称=="寡欲令" then
         状态名称=self:解除状态结果(self.参战单位[目标[n]],self:取门派封印法术("盘丝洞"))
         self:添加状态(名称,self.参战单位[目标[n]],self.参战单位[编号],等级,编号)
         self.战斗流程[#self.战斗流程].挨打方[n].添加状态=名称
        elseif 名称=="解封" or 名称=="宁心" then
         状态名称=self:解除状态结果(self.参战单位[目标[n]],self:取门派封印法术("女儿村"))
          if 名称=="宁心" then
             self:添加状态(名称,self.参战单位[目标[n]],self.参战单位[编号],等级,编号)
             self.战斗流程[#self.战斗流程].挨打方[n].添加状态=名称
           end
        elseif 名称=="水清诀" or 名称=="玉清诀"  then
         状态名称=self:解除状态结果(self.参战单位[目标[n]],self:取异常状态法术())
         -- self.战斗流程[#self.战斗流程].挨打方[n].添加状态=名称
        elseif 名称=="冰清诀"  then
         状态名称=self:解除状态结果(self.参战单位[目标[n]],self:取异常状态法术())
         -- self.战斗流程[#self.战斗流程].挨打方[n].添加状态=名称
          气血=qz(self.参战单位[目标[n]].最大气血*0.25)
          气血=self:取恢复气血(编号,目标[n],气血)
          self:增加气血(目标[n],气血)
          self.战斗流程[#self.战斗流程].挨打方[n].恢复气血=气血
        elseif 名称=="仙人指路"  then
          状态名称=self:解除状态结果(self.参战单位[目标[n]],self:取异常状态法术())
         -- self.战斗流程[#self.战斗流程].挨打方[n].添加状态=名称
          气血=qz(self.参战单位[目标[n]].最大气血*0.25)
          气血=self:取恢复气血(编号,目标[n],气血)
          self:增加气血(目标[n],气血)
          self.战斗流程[#self.战斗流程].挨打方[n].恢复气血=气血
        elseif 名称=="净世煌火"  then
          状态名称=self:解除状态结果(self.参战单位[目标[n]],self:取异常状态法术())
         -- self.战斗流程[#self.战斗流程].挨打方[n].添加状态=名称
          气血=qz(self.参战单位[目标[n]].最大气血*0.25)
          气血=self:取恢复气血(编号,目标[n],气血)
          self:增加气血(目标[n],气血)
          self.战斗流程[#self.战斗流程].挨打方[n].恢复气血=气血
        elseif 名称=="晶清诀"  then
          状态名称=self:解除状态结果(self.参战单位[目标[n]],self:取异常状态法术())
          气血=qz(self.参战单位[目标[n]].最大气血*0.15)
          气血=self:取恢复气血(编号,目标[n],气血)
          self:增加气血(目标[n],气血)
          self.战斗流程[#self.战斗流程].挨打方[n].恢复气血=气血
        elseif 名称=="气疗术"  then
          气血=qz(self.参战单位[目标[n]].最大气血*0.03+200)
          气血=self:取恢复气血(编号,目标[n],气血)
          self:增加气血(目标[n],气血)
          self.战斗流程[#self.战斗流程].挨打方[n].恢复气血=气血
        elseif 名称=="心疗术"  then
          气血=qz(self.参战单位[目标[n]].最大气血*0.06+400)
          气血=self:取恢复气血(编号,目标[n],气血)
          self:增加气血(目标[n],气血)
          self.战斗流程[#self.战斗流程].挨打方[n].恢复气血=气血
       elseif 名称=="命疗术"  then
          气血=qz(self.参战单位[目标[n]].最大气血*0.09+600)
          气血=self:取恢复气血(编号,目标[n],气血)
          self:增加气血(目标[n],气血)
          self.战斗流程[#self.战斗流程].挨打方[n].恢复气血=气血
        elseif 名称=="气归术" or 名称=="四海升平"  then
          气血=qz(self.参战单位[目标[n]].最大气血*0.25)
          气血=self:取恢复气血(编号,目标[n],气血)
          self:增加气血(目标[n],气血)
          self.战斗流程[#self.战斗流程].挨打方[n].恢复气血=气血
        elseif 名称=="命归术"  then
          气血=qz(self.参战单位[目标[n]].最大气血*0.5)
          气血=self:取恢复气血(编号,目标[n],气血)
          self:增加气血(目标[n],气血)
          self.战斗流程[#self.战斗流程].挨打方[n].恢复气血=气血
        elseif 名称=="驱魔" then
         状态名称=self:解除状态结果(self.参战单位[目标[n]],self:取门派封印法术("方寸山"))
         self:添加状态(名称,self.参战单位[目标[n]],self.参战单位[编号],等级,编号)
         self.战斗流程[#self.战斗流程].挨打方[n].添加状态=名称
        elseif 名称=="推拿" then
          if 释怀定制 then
            气血=(等级*4+100)*5
          else
            气血=等级*4+100
          end
          气血=self:取恢复气血(编号,目标[n],气血,名称)
          if 编号~=nil and self:取奇经八脉是否有(编号,"归气") then
              气血=qz(气血*1.08)
          end
          if 编号~=nil and self:取奇经八脉是否有(编号,"渡劫金身") and 取随机数()<=10 then
              气血=气血*2
          elseif 编号~=nil and self:取奇经八脉是否有(编号,"渡劫金身") then
              气血=qz(气血*1.15)
          end
          self:增加气血(目标[n],气血)
          self.战斗流程[#self.战斗流程].挨打方[n].恢复气血=气血
        elseif 名称=="黄帝内经" then
          气血=等级*4+100
          气血=self:取恢复气血(编号,目标[n],气血,名称)
          self:增加气血(目标[n],气血)
          self.战斗流程[#self.战斗流程].挨打方[n].恢复气血=气血
        elseif 名称=="妙悟" then
          if 释怀定制 then
            气血=(等级*2+50)*5
          else
            气血=等级*2+50
          end
          气血=self:取恢复气血(编号,目标[n],气血,名称)
          self:增加气血(目标[n],气血)
          self.战斗流程[#self.战斗流程].挨打方[n].恢复气血=气血
          self.参战单位[编号].妙悟回合=self.回合数
        elseif 名称=="活血" then
          if 释怀定制 then
            气血=(等级*6+100)*5
          else
            气血=等级*6+100
          end
          气血=self:取恢复气血(编号,目标[n],气血,名称)

          if 编号~=nil and self:取奇经八脉是否有(编号,"佛誉") and 取随机数()<=20 then
              气血=qz(气血*2)
          elseif 编号~=nil and self:取奇经八脉是否有(编号,"佛誉") then
              气血=qz(气血*1.2)
          end
          if 编号~=nil and self:取奇经八脉是否有(编号,"归气") then
              气血=qz(气血*1.08)
          end
          if 编号~=nil and self:取奇经八脉是否有(编号,"渡劫金身") and 取随机数()<=10 then
              气血=气血*2
          elseif 编号~=nil and self:取奇经八脉是否有(编号,"渡劫金身") then
              气血=qz(气血*1.15)
          end
          self:增加气血(目标[n],气血)
          self.战斗流程[#self.战斗流程].挨打方[n].恢复气血=气血
        elseif 名称=="星月之惠" then
          if 释怀定制 then
            气血=(等级*6+50)*5
          else
            气血=等级*6+50
          end
          气血=self:取恢复气血(编号,编号,气血)
          if 编号~=nil and self:取奇经八脉是否有(编号,"月影") then
              气血=气血*1.2
          end
          self:增加气血(编号,气血)
          self.战斗流程[#self.战斗流程].挨打方[n].挨打方=编号
          self.战斗流程[#self.战斗流程].挨打方[n].恢复气血=气血
        elseif 名称=="推气过宫" then
          if 释怀定制 then
            气血=qz((等级*2+200)*(1-目标数*0.02)*5)
          elseif 风雨无言定制 then
            气血=qz((等级*2+200)*(1-目标数*0.02)*2)
          else
            气血=qz((等级*2+200)*(1-目标数*0.02))
          end
          气血=self:取恢复气血(编号,目标[n],气血,名称)
          if 编号~=nil and self:取奇经八脉是否有(编号,"归气") then
              气血=qz(气血*1.08)
          end
          if 编号~=nil and self:取奇经八脉是否有(编号,"佛显") then
              气血=qz(气血*1.1)
          end
          if 编号~=nil and self:取奇经八脉是否有(编号,"渡劫金身") and 取随机数()<=10 then
              气血=气血*2
          elseif 编号~=nil and self:取奇经八脉是否有(编号,"渡劫金身") then
              气血=qz(气血*1.15)
          end
          if 编号~=nil and self:取奇经八脉是否有(编号,"心韧") and 取随机数()<=15 then
              气血=qz(气血*2)
              self.参战单位[编号].魔法=self.参战单位[编号].魔法-150
              if self.参战单位[编号].魔法<=0 then
                  self.参战单位[编号].魔法=0
              end
          end
          self:增加气血(目标[n],气血)
          self.战斗流程[#self.战斗流程].挨打方[n].恢复气血=气血
        elseif 名称=="峰回路转" then
          气血=qz((等级*2+200)*(1-目标数*0.02))
          气血=self:取恢复气血(编号,目标[n],气血,名称)
          self:增加气血(目标[n],气血)
          self.战斗流程[#self.战斗流程].挨打方[n].恢复气血=气血
        elseif 名称=="匠心·蓄锐" then
          气血=qz((等级*2+200)*(1-目标数*0.02))
          气血=self:取恢复气血(编号,目标[n],气血,名称)
          self:增加气血(目标[n],气血)
          self.战斗流程[#self.战斗流程].挨打方[n].恢复气血=气血
        elseif 名称=="地涌金莲" then
          if 释怀定制 then
            气血=qz((等级*2+100)*(1-目标数*0.15)*5*3)
          else
            气血=qz((等级*2+100)*(1-目标数*0.15))
          end
          if 编号~=nil and self:取奇经八脉是否有(编号,"化莲") then
              气血=气血+qz(self.参战单位[编号].装备属性.伤害*0.3)
          end
          if 编号~=nil and self:取奇经八脉是否有(编号,"自愈") then
              气血=qz(气血*1.5)
          end
          气血=self:取恢复气血(编号,目标[n],气血)
          self:增加气血(目标[n],气血)
          self.战斗流程[#self.战斗流程].挨打方[n].恢复气血=气血
        elseif 名称=="归元咒" then
          气血=qz(等级*1.5+10)
          if 编号~=nil and self:取奇经八脉是否有(编号,"吐纳") then
              气血=气血+qz(self.参战单位[编号].最大气血*0.2)
              self.参战单位[编号].魔法=self.参战单位[编号].魔法-qz(气血*0.25)
              if self.参战单位[编号].魔法<=0 then
                  self.参战单位[编号].魔法=0
              end
          end
          气血=self:取恢复气血(编号,目标[n],气血)
          self:增加气血(目标[n],气血)
          self.战斗流程[#self.战斗流程].挨打方[n].恢复气血=气血
        elseif 名称=="乾天罡气" then
          气血=qz(等级*0.5)
          self:增加魔法(编号,气血)
          self.参战单位[编号].气血=self.参战单位[编号].气血-20
          self.战斗流程[#self.战斗流程].扣除气血=20
        elseif 名称=="凝气诀" then
          气血=qz(self.参战单位[目标[n]].最大魔法*0.15+200)
          self:增加魔法(编号,气血)
        elseif 名称=="凝神诀" then
          气血=qz(self.参战单位[目标[n]].最大魔法*0.15+400)
          self:增加魔法(编号,气血)
        elseif 名称=="我佛慈悲" then
          if 释怀定制 then
            气血=qz(等级*6+100)*5
          else
            气血=qz(等级*6+100)
          end
          气血=self:取恢复气血(编号,目标[n],气血,1)
          if 编号~=nil and self:取奇经八脉是否有(编号,"归气") then
              气血=qz(气血*1.08)
          end
          if 编号~=nil and self:取奇经八脉是否有(编号,"渡劫金身") and 取随机数()<=10 then
              气血=气血*2
          elseif 编号~=nil and self:取奇经八脉是否有(编号,"渡劫金身") then
              气血=qz(气血*1.15)
          end
          self:增加气血(目标[n],气血)
          self.战斗流程[#self.战斗流程].挨打方[n].恢复气血=气血
          self.战斗流程[#self.战斗流程].挨打方[n].复活=true
          if 编号~=nil and self:取奇经八脉是否有(编号,"慈针") then
              self.参战单位[编号].愤怒=self.参战单位[编号].愤怒+30
              if self.参战单位[编号].愤怒>=150 then
                  self.参战单位[编号].愤怒=150
              end
          end
          if 编号~=nil and self:取奇经八脉是否有(编号,"佛性") and self.参战单位[目标[n]].佛性==nil then
            if self.参战单位[目标[n]].佛性==nil then
                self.参战单位[目标[n]].防御=qz(self.参战单位[目标[n]].防御+80)
                self.参战单位[目标[n]].法防=qz(self.参战单位[目标[n]].法防+80)
                self.参战单位[目标[n]].佛性=true
            end
          end
        elseif 名称=="由己渡人" then
          气血 = qz(等级*18)
          气血=self:取恢复气血(编号,目标[n],气血,1)
          self:增加气血(目标[n],气血)
          self.战斗流程[#self.战斗流程].挨打方[n].恢复气血=气血
          self.战斗流程[#self.战斗流程].挨打方[n].复活=true
          self:添加状态(名称,self.参战单位[目标[n]],self.参战单位[编号],等级,编号)
        elseif 名称=="慈航普渡" then
          气血=self.参战单位[目标[n]].最大气血
          self:增加气血(目标[n],气血)
          self.战斗流程[#self.战斗流程].挨打方[n].恢复气血=气血
          self.战斗流程[#self.战斗流程].挨打方[n].复活=true
          self.战斗流程[#self.战斗流程].扣除气血 = self.参战单位[编号].气血-1
          self.参战单位[编号].魔法=1
          self:减少气血(编号,self.战斗流程[#self.战斗流程].扣除气血)
        elseif 名称=="舍身取义" then
          气血=self.参战单位[目标[n]].最大气血
          if 编号~=nil and self:取奇经八脉是否有(编号,"归气") then
              气血=qz(气血*1.08)
          end
          if 编号~=nil and self:取奇经八脉是否有(编号,"天照") and 取随机数()<=20 then
              self.参战单位[编号].魔法=self.参战单位[编号].魔法+75
              self:减少气血(编号,75)
          end
          if 编号~=nil and self:取奇经八脉是否有(编号,"渡劫金身") and 取随机数()<=10 then
              气血=气血*2
          elseif 编号~=nil and self:取奇经八脉是否有(编号,"渡劫金身") then
              气血=qz(气血*1.15)
          end
          self:增加气血(目标[n],气血)
          self.战斗流程[#self.战斗流程].挨打方[n].恢复气血=气血
          self.参战单位[编号].防御=qz(self.参战单位[编号].防御*0.95)
          self.参战单位[编号].灵力=qz(self.参战单位[编号].灵力*0.97)
          if 编号~=nil and self:取奇经八脉是否有(编号,"感念") and self.参战单位[目标[n]].感念==nil then
            if self.参战单位[目标[n]].感念==nil then
                self.参战单位[目标[n]].防御=qz(self.参战单位[目标[n]].防御*1.1)
                self.参战单位[目标[n]].法防=qz(self.参战单位[目标[n]].法防*1.1)
                self.参战单位[目标[n]].感念=true
            end
          end
        elseif 名称=="杨柳甘露" then
          if 释怀定制 then
            气血=qz(等级*3+200)*5*3
          else
            气血=qz(等级*3+200)
          end
          气血=self:取恢复气血(编号,目标[n],气血,1)
          self:增加气血(目标[n],气血)
          self.战斗流程[#self.战斗流程].挨打方[n].恢复气血=气血
          self.战斗流程[#self.战斗流程].挨打方[n].复活=true
          if 编号~=nil and self:取奇经八脉是否有(编号,"甘露") and 取随机数() <=50 then
              self:添加状态("普渡众生",self.参战单位[目标[n]],self.参战单位[编号],90,编号)
          end
        elseif 名称=="还魂咒" then
          气血=qz(等级*3+200)*3
          气血=self:取恢复气血(编号,目标[n],气血,1)
          self:增加气血(目标[n],气血)
          self.战斗流程[#self.战斗流程].挨打方[n].恢复气血=气血
          self.战斗流程[#self.战斗流程].挨打方[n].复活=true
        elseif 名称=="起死回生" then
          气血=qz(self.参战单位[目标[n]].最大气血*0.5)
          if 气血>self.参战单位[目标[n]].等级*20 then
             气血=self.参战单位[目标[n]].等级*20
             end
          气血=self:取恢复气血(编号,目标[n],气血,1)
          self:增加气血(目标[n],气血)
          self.战斗流程[#self.战斗流程].挨打方[n].恢复气血=气血
          self.战斗流程[#self.战斗流程].挨打方[n].复活=true
        elseif 名称=="还阳术" then
          if 释怀定制 then
            气血=qz(self.参战单位[目标[n]].最大气血*0.5)*5
          else
            气血=qz(self.参战单位[目标[n]].最大气血*0.5)
          end
          if 气血>self.参战单位[目标[n]].等级*20 then
             气血=self.参战单位[目标[n]].等级*20
             end
          气血=self:取恢复气血(编号,目标[n],气血,1)
          self:增加气血(目标[n],气血)
          self.战斗流程[#self.战斗流程].挨打方[n].恢复气血=气血
          self.战斗流程[#self.战斗流程].挨打方[n].复活=true
         elseif 名称=="回魂咒" then
          气血=150
          气血=self:取恢复气血(编号,目标[n],气血,1)
          self:增加气血(目标[n],气血)
          self.战斗流程[#self.战斗流程].挨打方[n].恢复气血=气血
          self.战斗流程[#self.战斗流程].挨打方[n].复活=true
         end
      self.战斗流程[#self.战斗流程].挨打方[n].解除状态=状态名称
     end
end

function 战斗处理类:取异常状态法术()
  return {"日月乾坤","毒","尸腐毒","雾杀","威慑","夺魄令","煞气诀","锋芒毕露","诱袭","反间之计","失心","一笑倾城","百万神兵","错乱","镇妖","催眠符","失心符","落魄符","失忆符","追魂符","离魂符","失魂符","定身符","莲步轻舞","如花解语","似玉生香","含情脉脉","魔音摄魂","天罗地网"}
end

function 战斗处理类:取门派封印法术(门派)
  if 门派=="方寸山" then
    return {"催眠符","失心符","落魄符","失忆符","追魂符","离魂符","失魂符","定身符","顺势而为"}
  elseif  门派=="女儿村" then
    return {"莲步轻舞","如花解语","似玉生香","一笑倾城"}
  elseif  门派=="盘丝洞" then
    return {"含情脉脉","魔音摄魂","天罗地网"}
  elseif  门派=="无底洞" then
    return {"夺魄令","煞气诀","惊魂掌","摧心术"}
  end
end

function 战斗处理类:取法宝封印状态(编号)
  local 临时名称={"无字经","无尘扇","摄魂","无魂傀儡","断线木偶","鬼泣","惊魂铃","发瘟匣"}
  for i, v in pairs(self.参战单位[编号].法术状态) do
    for n=1,#临时名称 do
      if 临时名称[n]==i then return true end
    end
  end
  return false
end

function 战斗处理类:取法宝异常法术()
  return {"无字经","无尘扇","摄魂","无魂傀儡","断线木偶","鬼泣","惊魂铃","发瘟匣"}
end

function 战斗处理类:解除状态结果(单位,名称)
  local 解除={}
  for n=1,#名称 do
    if 单位.法术状态[名称[n]]~=nil then
      self:取消状态(名称[n],单位)
      解除[#解除+1]=名称[n]
    end
  end
  return 解除
end

function 战斗处理类:法攻技能计算(编号,名称,等级,伤害系数,消耗)
  local 目标=self.参战单位[编号].指令.目标
  local 目标数=self:取目标数量(self.参战单位[编号],名称,等级,编号)
  local 目标=self:取多个敌方目标(编号,目标,目标数)
  local 名称1
  if 名称=="摇头摆尾" then
    名称1=名称
    if 取随机数()<=50 then
      名称="三昧真火"
    else
      名称="飞砂走石"
    end
  elseif 名称=="上古灵符" then
    local 灵符随机={"上古灵符(怒雷)","上古灵符(流沙)","上古灵符(心火)"}
    名称=灵符随机[取随机数(1,#灵符随机)]
  end
  if 消耗==nil then
    if 名称=="亢龙归海" and self.参战单位[编号].亢龙回合~=nil and self.回合数-self.参战单位[编号].亢龙回合<6 then
      self:添加提示(self.参战单位[编号].玩家id,编号,"#Y/该技能必须等待#R/"..(6-(self.回合数-self.参战单位[编号].亢龙回合)).."#Y/回合后才可使用")
      return
    elseif 名称=="魔焰滔天" and self.参战单位[编号].魔焰回合~=nil and self.回合数-self.参战单位[编号].魔焰回合<6 then
      self:添加提示(self.参战单位[编号].玩家id,编号,"#Y/该技能必须等待#R/"..(6-(self.回合数-self.参战单位[编号].魔焰回合)).."#Y/回合后才可使用")
      return
    elseif 名称=="风卷残云" and self.参战单位[编号].风卷回合~=nil and self.回合数-self.参战单位[编号].风卷回合<5 then
      self:添加提示(self.参战单位[编号].玩家id,编号,"#Y/该技能必须等待#R/"..(5-(self.回合数-self.参战单位[编号].风卷回合)).."#Y/回合后才可使用")
      return
    elseif 名称=="五行制化" and self.参战单位[编号].五行回合~=nil and self.回合数-self.参战单位[编号].五行回合<6 then
      self:添加提示(self.参战单位[编号].玩家id,编号,"#Y/该技能必须等待#R/"..(5-(self.回合数-self.参战单位[编号].五行回合)).."#Y/回合后才可使用")
      return
    elseif 名称=="飞符炼魂" and self.参战单位[编号].飞符回合~=nil and self.回合数-self.参战单位[编号].飞符回合<5 then
      self:添加提示(self.参战单位[编号].玩家id,编号,"#Y/该技能必须等待#R/"..(5-(self.回合数-self.参战单位[编号].飞符回合)).."#Y/回合后才可使用")
      return
    end
  end
  if #目标==0 then return end
  for n=1,#目标 do
    if self.参战单位[目标[n]].法术状态.分身术~=nil and self.参战单位[目标[n]].法术状态.分身术.破解==nil then
      self.参战单位[目标[n]].法术状态.分身术.破解=1
      table.remove(目标,n)
      return
    end
  end
  if #目标==0 then return end
  目标数=#目标
  if 消耗==nil and self:技能消耗(self.参战单位[编号],目标数,名称,编号)==false then
    self:添加提示(self.参战单位[编号].玩家id,编号,"#Y/你当前状态无法使用该技能")
    return
  end
  local 返回=nil
  local 重复攻击=false
  local 起始伤害=1
  local 叠加伤害=0
  local 重复提示=false
  local 允许保护=true
  local 增加伤害=0
  local 伤害参数=0
  local 结尾气血=0
  local 防御减少=0
  if 名称=="五行制化" then
    local 随机法术={"苍茫树","靛沧海","日光华","巨岩破"}
    名称=随机法术[取随机数(1,#随机法术)]
    伤害系数=1.3
    self.参战单位[编号].五行回合=self.回合数
  end
  self.战斗流程[#self.战斗流程+1]={流程=200,攻击方=编号,挨打方={},提示={允许=true,类型="法术",名称=self.参战单位[编号].名称.."使用了"..名称}}
  for n=1,目标数 do
    self:法攻技能计算1(编号,名称,等级,目标[n],目标数,n,伤害系数)
    if 名称1=="摇头摆尾" then
      self:添加状态(名称1,self.参战单位[目标[n]],self.参战单位[编号],self:取技能等级(编号,名称1),编号)
    end
  end
  if 名称=="自爆" then
    self.战斗流程[#self.战斗流程].流程=500
    self.战斗流程[#self.战斗流程].伤害=self.参战单位[编号].气血
    self.参战单位[编号].气血=0
  end
  if self.参战单位[编号].龙魂~= nil and self.参战单位[编号].法术状态.龙魂==nil then
    self.参战单位[编号].龙魂 = self.参战单位[编号].龙魂+1
    if self.参战单位[编号].龙魂 >= 3 then
      self.参战单位[编号].龙魂 = 0
      self:添加状态("龙魂",self.参战单位[编号])
    end
  end
end

function 战斗处理类:取固伤结果(编号,伤害)
  if self.参战单位[编号].固伤加成~=nil then
    伤害=伤害*self.参战单位[编号].固伤加成
  end
  if self.参战单位[编号].队伍==0 then
    伤害=伤害*0.75
  elseif self:取玩家战斗()==false then
    伤害=伤害*2
  end
  if self.参战单位[编号].行云流水~=nil and self.参战单位[编号].行云流水 ~= 0 and 玩家数据[self.参战单位[编号].玩家id].角色.数据.门派 == "普陀山" then
      伤害 = 伤害 + self.参战单位[编号].行云流水
  end
  if self.参战单位[编号].索命无常~=nil and self.参战单位[编号].索命无常 ~= 0 and 玩家数据[self.参战单位[编号].玩家id].角色.数据.门派 == "阴曹地府" then
      伤害 = 伤害 + self.参战单位[编号].索命无常
  end
  return math.floor(伤害)
end

function 战斗处理类:法攻技能计算1(编号,名称,等级,目标,目标数,执行数,伤害系数)
  self.战斗流程[#self.战斗流程].挨打方[执行数]={特效={},挨打方=目标}
  local 基础伤害=self:取灵力伤害(self.参战单位[编号],self.参战单位[目标],编号)+等级
  local 法伤系数=1
  local 增加伤害=0
  local 结尾气血=0
  local 重复攻击=false
  local 附加状态=nil
  local 吸收=nil
  local 弱点=nil
  if 编号~=nil and self:取奇经八脉是否有(编号,"波澜不惊") then
    if self.参战单位[编号].法连==nil then
        self.参战单位[编号].法连=0
    end
    self.参战单位[编号].法连=self.参战单位[编号].法连+20
  end
  self.执行等待=self.执行等待+10
  if 名称=="唧唧歪歪" then
      法伤系数=0.7
      if 编号~=nil and self:取奇经八脉是否有(编号,"销武") then
          基础伤害=基础伤害+qz(self.参战单位[编号].等级)
      end
  elseif 名称=="飞花摘叶" then
    基础伤害=基础伤害+qz(self.参战单位[目标].气血*0.2)
    if 编号~=nil and self:取奇经八脉是否有(编号,"鸿渐于陆") then
        基础伤害=基础伤害+qz(self.参战单位[编号].装备属性.伤害*1.3)
        self:添加状态("毒",self.参战单位[目标],self.参战单位[编号],self.参战单位[编号].等级,编号)
    end
  elseif 名称=="五雷咒" then
      法伤系数=0.8
      if self.参战单位[目标].鬼魂~=nil then
        法伤系数=2
      end
      if 编号~=nil and self:取奇经八脉是否有(编号,"奔雷") then
          基础伤害=qz(基础伤害*1.1)
      end
      if 编号~=nil and self:取奇经八脉是否有(编号,"鬼怮") and self.参战单位[目标].法术状态.鬼魂术~=nil then
          基础伤害=qz(基础伤害*1.3)
      end
  elseif 名称=="落雷符" then
    法伤系数=0.6-目标数*0.05
    if self.参战单位[编号].石破天惊 ~= 0 then
        法伤系数 = 0.7 - 目标数*0.05
    end
    if self.参战单位[目标].鬼魂~=nil then
      法伤系数=法伤系数*2
    end
    if 编号~=nil and self:取奇经八脉是否有(编号,"飞符炼魂") and 取随机数() <= 70 then
        附加状态="失魂符"
        self:添加状态("失魂符",self.参战单位[目标],self.参战单位[编号],self.参战单位[编号].等级,编号)
    end
    if 编号~=nil and self:取奇经八脉是否有(编号,"雷动") then
        基础伤害=基础伤害+100
    end
  elseif 名称=="黄泉之息" then
    local 黄泉伤害=等级*5+self.参战单位[编号].武器伤害*2
    if self:取经脉(编号,"阴曹地府","泉爆") and self.参战单位[目标].黄泉触发==nil then
      黄泉伤害=黄泉伤害*4
      local 速度减少=qz(self.参战单位[目标].速度-等级*0.5)
      if self:取经脉(编号,"阴曹地府","黄泉")  then
        速度减少=qz(速度减少*1.5)
      end
      self.参战单位[目标].速度=速度减少
      self.参战单位[目标].黄泉触发=1
    end
  elseif 名称=="飞符炼魂" then
    法伤系数=0.5
    self.参战单位[编号].飞符回合=self.回合数
    if self.参战单位[目标].鬼魂~=nil then
      基础伤害=基础伤害+self.参战单位[目标].气血
    end
  elseif 名称=="孔雀明王经" then
      基础伤害=qz(self.参战单位[目标].气血*0.1)
      self.参战单位[目标].魔法=qz(self.参战单位[目标].魔法*0.95)
  elseif 名称=="雨落寒沙" then
    基础伤害=self:取固伤结果(编号,等级*3+self.参战单位[编号].固定伤害)
    if 编号~=nil and self:取奇经八脉是否有(编号,"杏花") and 取随机数()<=4 then
        self:添加状态("毒",self.参战单位[目标],self.参战单位[编号],self.参战单位[编号].等级,编号)
    end
  elseif 名称=="五雷轰顶" then
    if 取随机数()<=50 then
      基础伤害=self.参战单位[目标].气血*0.1
    else
      基础伤害=self.参战单位[目标].气血*0.01
    end
    if 基础伤害>=等级*200 then
      基础伤害=等级*200
    end
    if self:取指定法宝(编号,"伏魔天书",1) then
      基础伤害=基础伤害+self:取指定法宝境界(编号,"伏魔天书")*取随机数(20,30)
    end
    if 编号~=nil and self:取奇经八脉是否有(编号,"威吓") then
        基础伤害=qz(基础伤害*1.08)
    end
    if 编号~=nil and self:取奇经八脉是否有(编号,"轰鸣") and self.参战单位[编号].轰鸣==nil then
        self.参战单位[目标].防御=self.参战单位[目标].防御-240
    end
  elseif 名称=="雷霆万钧" then
    法伤系数=1.5-目标数*0.1
    if self:取指定法宝(编号,"伏魔天书",1) then
      基础伤害=基础伤害+self:取指定法宝境界(编号,"伏魔天书")*取随机数(20,30)
    end
    if self.参战单位[编号].天雷地火 ~= 0 then
        基础伤害 = 基础伤害 + self.参战单位[编号].天雷地火
    end
    if 编号~=nil and self:取奇经八脉是否有(编号,"雷波") then
        for i=1,目标数 do
          if i==1 then
              基础伤害=基础伤害*1.08
          end
        end
    end
    if 编号~=nil and self:取奇经八脉是否有(编号,"电芒") then
        基础伤害=基础伤害*1.3
    end
  elseif 名称=="龙腾" then
    法伤系数=1.3
    if 编号~=nil and self:取奇经八脉是否有(编号,"波涛") then
        基础伤害=基础伤害+qz(self.参战单位[编号].等级*1.5)
    end
  elseif 名称=="荆棘舞" then
    法伤系数=1.25
    if 编号~=nil and self:取奇经八脉是否有(编号,"鞭挞") then
        基础伤害=基础伤害+qz(self.参战单位[编号].等级*3)
    end
    if 编号~=nil and self:取奇经八脉是否有(编号,"蔓延") then
        基础伤害=基础伤害+qz(self.参战单位[编号].等级*1.5)
    end
  elseif 名称=="尘土刃" then
    法伤系数=0.85
    if 编号~=nil and self:取奇经八脉是否有(编号,"追击") and 取随机数()<=50 then
        重复攻击=true
    end
  elseif 名称=="冰川怒" then
    法伤系数=0.65
    if 编号~=nil and self:取奇经八脉是否有(编号,"冰锥") then
        法伤系数=0.85
    end
  elseif 名称=="月光" then
    法伤系数=取随机数(20,40)/100
  elseif 名称=="龙卷雨击" then
    法伤系数=1.1-目标数*0.035
    if 编号~=nil and self:取奇经八脉是否有(编号,"逐浪") then
        基础伤害=基础伤害+qz(self.参战单位[编号].等级*0.5)
    end
    if 编号~=nil and self:取奇经八脉是否有(编号,"云霄") then
        基础伤害=基础伤害+100
    end
    self.战斗流程[#self.战斗流程].流程=205
  elseif 名称=="落叶萧萧" then
    法伤系数=1.2-目标数*0.035
    if 编号~=nil and self:取奇经八脉是否有(编号,"风卷残云") then
        基础伤害=基础伤害+500
    end
    if 编号~=nil and self:取奇经八脉是否有(编号,"灵能") and 取随机数()<=30 then
        基础伤害=基础伤害+qz(self.参战单位[编号].灵力/self.参战单位[编号].等级*5)
    end
  elseif 名称=="龙吟" then
    基础伤害=等级+15
    基础伤害=self:取固伤结果(编号,基础伤害)
    if 编号~=nil and self:取奇经八脉是否有(编号,"清吟") then
        self:减少气血(目标,取随机数(50,100))
    end
    self.战斗流程[#self.战斗流程].流程=205
  elseif 名称=="腾雷" then
    法伤系数=1.35
    if 编号~=nil and self:取奇经八脉是否有(编号,"雷附") then
      法伤系数=1.55
    end
  elseif 名称=="亢龙归海" then
    法伤系数=1.25
    self.参战单位[编号].亢龙回合=self.回合数
  elseif 名称=="二龙戏珠" then
    法伤系数=1.2-目标数*0.035
    if 编号~=nil and self:取奇经八脉是否有(编号,"汹涌") then
        if self.参战单位[目标].法伤减少~=nil then
            self.参战单位[目标].法伤减少=qz(self.参战单位[目标].法伤减少*0.92)
        end
    end
  elseif 名称=="风卷残云" then
    名称="落叶萧萧"
    法伤系数=1.35-目标数*0.035
    法伤系数=法伤系数*2
    self.参战单位[编号].风卷回合=self.回合数
    if 编号~=nil and self:取奇经八脉是否有(编号,"灵能") and 取随机数()<=30 then
      基础伤害=基础伤害+50
    end
    基础伤害=基础伤害+qz(self.参战单位[编号].武器伤害*0.3)+等级*1.5
  elseif 名称=="自爆" then
    基础伤害=等级*5+self.参战单位[目标].气血*0.1
  elseif 名称=="靛沧海" then
    基础伤害=等级*4+self.参战单位[编号].固定伤害
    if self:取五行克制("水",self.参战单位[目标].防御五行)  then
       基础伤害=基础伤害*1.5
    end
    if self:取指定法宝(编号,"金刚杵",1) then
      基础伤害=qz((1+self:取指定法宝境界(编号,"金刚杵")*0.05)*基础伤害)
    end
    if 编号~=nil and self:取奇经八脉是否有(编号,"秘术") then
        基础伤害=基础伤害+150
    end
    if 编号~=nil and self:取奇经八脉是否有(编号,"法咒") and 取随机数()<=20 then
        基础伤害=qz(基础伤害*1.5)
    end
    self.战斗流程[#self.战斗流程].流程=200
    基础伤害=self:取固伤结果(编号,基础伤害)
  elseif 名称=="日光华" then
    基础伤害=等级*4+self.参战单位[编号].固定伤害
    if self:取五行克制("金",self.参战单位[目标].防御五行)  then
       基础伤害=基础伤害*1.5
    end
    if self:取指定法宝(编号,"金刚杵",1) then
      基础伤害=qz(1+self:取指定法宝境界(编号,"金刚杵")*0.05*基础伤害)
    end
    if 编号~=nil and self:取奇经八脉是否有(编号,"秘术") then
        基础伤害=基础伤害+150
    end
    if 编号~=nil and self:取奇经八脉是否有(编号,"法咒") and 取随机数()<=20 then
        基础伤害=qz(基础伤害*1.5)
    end
    self.战斗流程[#self.战斗流程].流程=200
    基础伤害=self:取固伤结果(编号,基础伤害)
  elseif 名称=="地裂火" then
    基础伤害=等级*4+self.参战单位[编号].固定伤害
    if self:取五行克制("火",self.参战单位[目标].防御五行)  then
       基础伤害=基础伤害*1.5
    end
    if self:取指定法宝(编号,"金刚杵",1) then
      基础伤害=qz(1+self:取指定法宝境界(编号,"金刚杵")*0.05*基础伤害)
    end
    if 编号~=nil and self:取奇经八脉是否有(编号,"秘术") then
        基础伤害=基础伤害+150
    end
    if 编号~=nil and self:取奇经八脉是否有(编号,"法咒") and 取随机数()<=20 then
        基础伤害=qz(基础伤害*1.5)
    end
    基础伤害=self:取固伤结果(编号,基础伤害)
    self.战斗流程[#self.战斗流程].流程=200
  elseif 名称=="匠心·破击" then
    基础伤害=等级*4+self.参战单位[编号].固定伤害
    基础伤害=self:取固伤结果(编号,基础伤害)
    if 编号~=nil and self:取奇经八脉是否有(编号,"精奇") and (self.参战单位[编号].力量>=self.参战单位[编号].等级*3 or self.参战单位[编号].敏捷>=self.参战单位[编号].等级*3) then
      基础伤害=基础伤害+self.参战单位[编号].武器伤害
    end
    self.参战单位[编号].速度=qz(self.参战单位[编号].速度*1.2)
    self.战斗流程[#self.战斗流程].流程=200
  elseif 名称=="云暗天昏" then
    基础伤害=等级*4+self.参战单位[编号].固定伤害
    基础伤害=self:取固伤结果(编号,基础伤害)
    self.战斗流程[#self.战斗流程].流程=200
  elseif 名称=="苍茫树" then
    基础伤害=等级*4+self.参战单位[编号].固定伤害
    if self:取五行克制("木",self.参战单位[目标].防御五行)  then
       基础伤害=基础伤害*1.5
    end
    if self:取指定法宝(编号,"金刚杵",1) then
      基础伤害=qz(1+self:取指定法宝境界(编号,"金刚杵")*0.05*基础伤害)
    end
    if 编号~=nil and self:取奇经八脉是否有(编号,"秘术") then
        基础伤害=基础伤害+150
    end
    if 编号~=nil and self:取奇经八脉是否有(编号,"法咒") and 取随机数()<=20 then
        基础伤害=qz(基础伤害*1.5)
    end
    self.战斗流程[#self.战斗流程].流程=200
    基础伤害=self:取固伤结果(编号,基础伤害)
  elseif 名称=="巨岩破" then
    基础伤害=等级*4+self.参战单位[编号].固定伤害
    if self:取五行克制("土",self.参战单位[目标].防御五行)  then
       基础伤害=基础伤害*1.5
    end
    if self:取指定法宝(编号,"金刚杵",1) then
      基础伤害=qz(1+self:取指定法宝境界(编号,"金刚杵")*0.05*基础伤害)
    end
    if 编号~=nil and self:取奇经八脉是否有(编号,"秘术") then
        基础伤害=基础伤害+150
    end
    if 编号~=nil and self:取奇经八脉是否有(编号,"法咒") and 取随机数()<=20 then
        基础伤害=qz(基础伤害*1.5)
    end
    self.战斗流程[#self.战斗流程].流程=200
    基础伤害=self:取固伤结果(编号,基础伤害)
  elseif 名称=="三昧真火" then
    法伤系数=1.5
    if 编号~=nil and self:取奇经八脉是否有(编号,"赤暖") and 取随机数() <= 50 then
        self:增加气血(编号,基础伤害/50)
    end
    if 编号~=nil and self:取奇经八脉是否有(编号,"神炎") then
        基础伤害=基础伤害+(1-self.参战单位[编号].气血/self.参战单位[编号].最大气血)*1000
    end
  elseif 名称=="飞砂走石" then
    法伤系数=1.2-目标数*0.025
    if 编号~=nil and self:取奇经八脉是否有(编号,"火神") then
        基础伤害=基础伤害+qz(self.参战单位[编号].等级*1.5)
    end
    if 编号~=nil and self:取奇经八脉是否有(编号,"神焰") then
        基础伤害=基础伤害+(1-self.参战单位[编号].气血/self.参战单位[编号].最大气血)*1000
    end
    self.战斗流程[#self.战斗流程].流程=205
  elseif 名称=="血雨" then
    法伤系数=1.8
    if 编号~=nil and self:取奇经八脉是否有(编号,"血契") and 取随机数()<=50 then
      目标数=2
      重复攻击=true
      结尾气血=qz(self.参战单位[编号].最大气血*0.15)
    else
      目标数=1
      结尾气血=qz(self.参战单位[编号].最大气血*0.3)
      附加状态="血雨"
      self:添加状态(名称,self.参战单位[目标],self.参战单位[编号],等级,编号)
    end
    self:减少气血(编号,结尾气血)
  elseif 名称=="天罗地网" then
    基础伤害=等级*3+self.参战单位[编号].伤害*0.45
    if self.参战单位[编号].网罗乾坤 ~= 0 then
        基础伤害 = 基础伤害 + self.参战单位[编号].网罗乾坤
    end
    if self:取封印成功(名称,等级,self.参战单位[编号],self.参战单位[目标],编号) then
        附加状态="天罗地网"
        self:添加状态(名称,self.参战单位[目标],self.参战单位[编号],等级,编号)
    end
    if 编号~=nil and self:取奇经八脉是否有(编号,"落花成泥") then
        self.参战单位[目标].防御=qz(self.参战单位[目标].防御*0.85)
        self.参战单位[目标].法防=qz(self.参战单位[目标].法防*0.85)
    end
    if 编号~=nil and self:取奇经八脉是否有(编号,"粘附") then
        基础伤害=基础伤害+qz(self.参战单位[编号].装备属性.伤害*0.18)
    end
  elseif 名称=="阎罗令" then
    基础伤害=等级*5+self.参战单位[编号].固定伤害
    基础伤害=self:取固伤结果(编号,基础伤害)
    法伤系数=1-目标数*0.05
   elseif 名称=="夺命咒" then
    基础伤害=等级*4+self.参战单位[编号].固定伤害
    基础伤害=self:取固伤结果(编号,基础伤害)
    法伤系数=1-目标数*0.03
    if 编号~=nil and self:取奇经八脉是否有(编号,"追魂") and self.参战单位[编号].敏捷>=qz(self.参战单位[编号].等级*2.2) then
        基础伤害=基础伤害+self.参战单位[编号].等级
    end
    if 编号~=nil and self:取奇经八脉是否有(编号,"内伤") then
        基础伤害=基础伤害+50+qz(self.参战单位[编号].等级*1.5)
    end
    if 编号~=nil and self:取奇经八脉是否有(编号,"陷阱") and self.参战单位[编号].法术状态.夺魄咒==nil then
        local 气血=self.参战单位[编号].等级
        if self.参战单位[编号].气血<=qz(self.参战单位[编号].最大气血*0.5) then
            气血=气血*2
        end
        self:增加气血(编号,气血)
    end
  elseif 名称=="判官令" then
    基础伤害=等级*8.5+self.参战单位[编号].固定伤害
    基础伤害=self:取固伤结果(编号,基础伤害)
    if 编号~=nil and self:取奇经八脉是否有(编号,"判官") then
        基础伤害=qz(基础伤害*1.1)
    end
    if 编号~=nil and self:取奇经八脉是否有(编号,"毒印") and self.参战单位[目标].法术状态.尸腐毒~=nil then
        基础伤害=qz(基础伤害*1.1)
    end
  elseif 名称=="炽火流离" then
    法伤系数=0.65
    local 等级=self:取技能等级(编号,名称)
    local 气血=等级*6+50
    self:增加气血(编号,气血)
    self.战斗流程[#self.战斗流程].吸血伤害=气血
  elseif 名称=="誓血之祭" then
    法伤系数=1.2
    self:添加状态(名称,self.参战单位[编号],nil,nil,编号)
    self:添加状态("诅咒",self.参战单位[目标],nil,nil,目标)
    self.战斗流程[#self.战斗流程].添加状态=名称
    if 编号~=nil and self:取奇经八脉是否有(编号,"咒怨") then
        基础伤害=qz(基础伤害*1.2)
    end
  elseif 名称=="焚魔烈焰" then
    法伤系数=0.8
  elseif 名称=="天降灵葫" then
    法伤系数=1-目标数*0.1
    self.战斗流程[#self.战斗流程].流程=205
  elseif 名称=="八凶法阵" then
    法伤系数=1-目标数*0.1
    self.战斗流程[#self.战斗流程].流程=205
  elseif 名称=="叱咤风云" then
    法伤系数=1-目标数*0.1
    self.战斗流程[#self.战斗流程].流程=205
  elseif 名称=="泰山压顶" then
    法伤系数=1-目标数*0.1
    self.战斗流程[#self.战斗流程].流程=205
    吸收="土"
    弱点="土"
  elseif 名称=="奔雷咒" then
    法伤系数=0.9-目标数*0.1
    self.战斗流程[#self.战斗流程].流程=205
    吸收="雷"
    弱点="雷"
  elseif 名称=="水漫金山" then
    法伤系数=0.9-目标数*0.1
    self.战斗流程[#self.战斗流程].流程=205
    吸收="水"
    弱点="水"
  elseif 名称=="地狱烈火" then
    法伤系数=0.9-目标数*0.1
    吸收="火"
    弱点="火"
   self.战斗流程[#self.战斗流程].流程=205
  elseif 名称=="烈火" then
    法伤系数=1.2
    吸收="火"
    弱点="火"
  elseif 名称=="雷击" then
    法伤系数=1.2
    吸收="雷"
    弱点="雷"
  elseif 名称=="水攻" then
    法伤系数=1.2
    吸收="水"
    弱点="水"
  elseif 名称=="落岩" then
    法伤系数=1.2
    吸收="土"
    弱点="土"
  elseif 名称=="上古灵符(怒雷)" then
    法伤系数=1.65
    吸收="雷"
    弱点="雷"
  elseif 名称=="上古灵符(流沙)" then
    法伤系数=1.65
    吸收="土"
    弱点="土"
  elseif 名称=="上古灵符(心火)" then
    法伤系数=1.65
    吸收="火"
    弱点="火"
  end
  if 重复攻击 then
    local 临时目标=目标[1]
    for n=1,目标数 do
      目标[n]=临时目标
    end
  end
  if 编号~=nil and self:取奇经八脉是否有(编号,"魔冥") then
      self:增加魔法(编号,qz(self.参战单位[编号].最大魔法*0.05))
  end
  if 编号~=nil and self:取奇经八脉是否有(编号,"崩摧") and 取随机数()<=5 then
      self.参战单位[目标].法防=qz(self.参战单位[目标].法防*0.9)
  end
  伤害=qz(基础伤害*法伤系数*伤害系数)
  if 编号~=nil and self:取奇经八脉是否有(编号,"魔心") and 取随机数()<=10 then
    伤害=伤害*2
  end
  if 编号~=nil and self:取奇经八脉是否有(编号,"伤魂") and self.参战单位[目标].法术状态.尸腐毒~=nil then
      伤害=伤害+80
  end
  if 编号~=nil and self:取奇经八脉是否有(编号,"灵压") then
      伤害=qz(伤害*1.08)
  end
  if 编号~=nil and self:取奇经八脉是否有(编号,"凋零之歌") then
      伤害=qz(伤害*1.5)
  end
  if 服务器名称 == "测试专区" then
      伤害=qz(伤害*0.65)
  elseif 服务器名称 == "零氪2020仿官" then
      伤害=qz(伤害*1.35)
  else
      伤害=qz(伤害*0.65)
  end
  if self.参战单位[编号].法术状态.谜毒之缚~=nil then
    伤害=qz(伤害*0.65*0.8)
  end
  if 伤害<1 then 伤害=1 end
  local 法爆=0
  local 法爆成功=nil
  local 法爆几率=(self.参战单位[编号].法术暴击等级-self.参战单位[目标].抗法术暴击等级)*0.1
  if self.参战单位[编号].法暴+法爆几率>=取随机数() then
      法爆成功=true
      伤害=伤害*2
  end
  if self.参战单位[编号].法波~=nil then
    伤害=qz(伤害*取随机数(90,self.参战单位[编号].法波)/100)
  end
  --伤害=self:取伤害结果(攻击方,挨打方,伤害,暴击,保护)
  local 伤害类型=1
  if 弱点~=nil then
    if 弱点=="土" and self.参战单位[目标].弱点土~=nil then
      伤害=qz(伤害*1.5)
    elseif 弱点=="雷" and self.参战单位[目标].弱点雷~=nil then
      伤害=qz(伤害*1.5)
    elseif 弱点=="火" and self.参战单位[目标].弱点火~=nil then
      伤害=qz(伤害*1.5)
    elseif 弱点=="水" and self.参战单位[目标].弱点水~=nil then
      伤害=qz(伤害*1.5)
    end
  end
  if 吸收~=nil then
    local 触发=nil
    if 吸收=="土" and self.参战单位[目标].土吸~=nil then
      触发=self.参战单位[目标].土吸
    elseif 吸收=="水" and self.参战单位[目标].水吸~=nil then
      触发=self.参战单位[目标].水吸
    elseif 吸收=="火" and self.参战单位[目标].火吸~=nil then
      触发=self.参战单位[目标].火吸
    elseif 吸收=="雷" and self.参战单位[目标].雷吸~=nil then
      触发=self.参战单位[目标].雷吸
    end
    if 触发~=nil then
      if 取随机数()<=30 then
        伤害=qz(伤害*0.3)
        if 伤害<=1 then 伤害=1 end
        伤害类型=2
      else
        伤害=qz(伤害*0.7)
        if 伤害<=1 then 伤害=1 end
      end
    end
  end
  if 名称=="天外飞剑" then
    if 取随机数()<=30 then
      伤害=0
    else
      伤害=math.floor(self.参战单位[目标].气血*0.1)
    end
  end
  if 伤害类型==1 then
    伤害=self:取伤害结果(编号,目标,伤害,法爆成功,nil,名称)
    伤害类型=伤害.类型
    伤害=伤害.伤害
  else
    伤害类型=2
  end
  self.战斗流程[#self.战斗流程].挨打方[执行数].伤害=伤害
  self.战斗流程[#self.战斗流程].挨打方[执行数].类型=伤害类型
  self.战斗流程[#self.战斗流程].挨打方[执行数].特效[1]=名称
  self.战斗流程[#self.战斗流程].挨打方[执行数].状态=附加状态
  self.战斗流程[#self.战斗流程].结尾气血=结尾气血
  if 法爆成功 and 伤害类型~=2 then
    self.战斗流程[#self.战斗流程].挨打方[执行数].特效[2]="暴击"
    self.战斗流程[#self.战斗流程].挨打方[执行数].类型=3
  end
  if self:取指定法宝(目标,"降魔斗篷",1) then
    伤害=qz(伤害*0.45)
    self.战斗流程[#self.战斗流程].挨打方[执行数].伤害=伤害
    self.战斗流程[#self.战斗流程].挨打方[执行数].特效[#self.战斗流程[#self.战斗流程].挨打方[执行数].特效+1]="降魔斗篷"
  end
  if 伤害类型==2 then --恢复状态
    self:增加气血(目标,伤害)
  else
    self.战斗流程[#self.战斗流程].挨打方[执行数].死亡=self:减少气血(目标,伤害,编号,名称)
    if self.参战单位[目标].法术状态.催眠符 then
      self:取消状态("催眠符",self.参战单位[目标])
      self.战斗流程[#self.战斗流程].挨打方[执行数].取消状态="催眠符"
    end
  end
  if self.参战单位[编号].气血>0 and self.参战单位[目标].法术状态.混元伞~=nil then
    local 反弹伤害=qz(self.战斗流程[#self.战斗流程].挨打方[执行数].伤害*(self.参战单位[目标].法术状态.混元伞.境界*0.03+0.1))
    self.战斗流程[#self.战斗流程+1]={流程=104,气血=反弹伤害,攻击方=目标,挨打方={挨打方=编号,特效={},死亡=self:减少气血(编号,反弹伤害,目标)},提示={允许=false}}
  end
  if self.参战单位[编号].法术状态.诡蝠之刑~=nil then
    if self:取目标状态(编号,编号,2) then
      local 气血=qz(伤害值.伤害*0.1)
      if 气血<=1 then
        气血=1
      end
      self.战斗流程[#self.战斗流程+1]={流程=102,攻击方=编号,气血=0,挨打方={}}
      self.战斗流程[#self.战斗流程].死亡=self:减少气血(编号,气血)
      self.战斗流程[#self.战斗流程].气血=气血
    end
  end
end

function 战斗处理类:取五行克制(攻击,挨打)
 if 挨打=="木" and 攻击=="金" then
      return true
   elseif 挨打=="土" and 攻击=="木" then
      return true
    elseif 挨打=="水" and 攻击=="土" then
      return true
    elseif 挨打=="火" and 攻击=="水" then
      return true
    elseif 挨打=="金" and 攻击=="火" then
      return true
   end
  return false
end

function 战斗处理类:增益技能计算(编号,名称,等级,附加,消耗,指定,境界)
  local 目标=self.参战单位[编号].指令.目标
  if 指定~=nil or 名称=="变身" or 名称=="楚楚可怜" or 名称=="潜能激发" or 名称=="灵刃" or 名称=="混元伞" or 名称=="干将莫邪" or 名称=="五彩娃娃" or 名称=="烈焰真诀" or 名称=="炎护" or 名称=="修罗隐身" or 名称=="分身术" or 名称=="不动如山" or 名称=="幻镜术" or 名称=="魔王回首" or 名称=="极度疯狂" or 名称=="神龙摆尾" or 名称=="杀气诀" or 名称=="安神诀" or 名称=="定心术" or 名称=="天魔解体" or 名称=="神龙摆尾" or 名称=="牛劲" then
    目标=编号
  end
  if 名称=="真君显灵" and self.参战单位[编号].战意<3 then
    return
  end
  local 目标数=self:取目标数量(self.参战单位[编号],名称,等级,编号)
  目标=self:取多个友方目标(编号,目标,目标数,名称)
  if #目标==0 then return end
  目标数=#目标
  if 名称=="偷龙转凤" then
    if self.参战单位[编号].偷龙限制~=nil and self.回合数-self.参战单位[编号].偷龙限制>=8 then
      self:添加提示(self.参战单位[编号].玩家id,编号,"#Y/该技能必须等待#R/"..(8-(self.回合数-self.参战单位[编号].偷龙限制)).."#Y/回合后才可使用")
      return
    end
  end
  if 名称=="同舟共济" then
    if self.参战单位[编号].同舟限制~=nil and self.回合数-self.参战单位[编号].同舟限制>=5 then
      self:添加提示(self.参战单位[编号].玩家id,编号,"#Y/该技能必须等待#R/"..(5-(self.回合数-self.参战单位[编号].同舟限制)).."#Y/回合后才可使用")
      return
    end
  end
  if 消耗==nil and self:技能消耗(self.参战单位[编号],目标数,名称,编号)==false then self:添加提示(self.参战单位[编号].玩家id,编号,"#Y/你当前状态无法使用该技能") return  end
  if 名称=="真君显灵 " then
    self.参战单位[编号].战意=self.参战单位[编号].战意-3
  end
  self.战斗流程[#self.战斗流程+1]={流程=53,攻击方=编号,挨打方={},提示={允许=true,类型="法术",名称=self.参战单位[编号].名称.."使用了"..名称}}
  self.执行等待=self.执行等待+10
  if 名称=="不动如山" then
    self:添加状态("强袭",self.参战单位[编号],self.参战单位[编号],self.参战单位[编号].等级,编号)
  end
  for n=1,目标数 do
      self.战斗流程[#self.战斗流程].挨打方[n]={挨打方=目标[n],特效={名称}}
      if 名称=="后发制人" then
          self:添加状态(名称,self.参战单位[编号],self.参战单位[编号],等级,编号)
          self.参战单位[编号].法术状态.后发制人.目标=目标[n]
          self.战斗流程[#self.战斗流程].挨打方[n].挨打方=编号
      elseif 名称=="炎护" then
         self:添加状态(名称,self.参战单位[编号],self.参战单位[编号],等级,编号)
         self.战斗流程[#self.战斗流程].挨打方[n].挨打方=编号
      elseif 名称=="同舟共济" then
        self:添加状态(名称,self.参战单位[编号],self.参战单位[编号],等级,编号)
        self.战斗流程[#self.战斗流程].挨打方[n].挨打方=编号
        self.战斗流程[#self.战斗流程].攻击掉血=qz(self.参战单位[编号].气血*0.2)
        self.参战单位[编号].气血=qz(self.参战单位[编号].气血*0.8)
      elseif 名称=="偷龙转凤" then
        self.参战单位[编号].偷龙限制=self.回合数
        self:添加状态(名称,self.参战单位[目标[n]],self.参战单位[编号],等级,编号,境界)
        self.战斗流程[#self.战斗流程].挨打方[n].魔法=0
      else
          self:添加状态(名称,self.参战单位[目标[n]],self.参战单位[编号],等级,编号,境界)
      end
      if 名称=="生命之泉" then
        local 气血=0
        if 释怀定制 then
          气血=(等级+15)*5*2
        else
          气血=等级+15
        end
        气血=self:取恢复气血(编号,目标[n],气血)
        if 编号~=nil and self:取奇经八脉是否有(编号,"体恤") and self.参战单位[目标[n]].气血<=qz(self.参战单位[目标[n]].最大气血) then
          气血=气血+150
        end
        self:增加气血(目标[n],气血)
        self.战斗流程[#self.战斗流程].挨打方[n].恢复气血=气血
      elseif 名称=="普渡众生" then
        local 气血=0
        if 释怀定制 then
          气血=(等级*2+150)*5*3
        elseif 风雨无言定制 then
          气血=(等级*2+150)*2
        else
          气血=等级*2+150
        end
        if 编号~=nil and self:取奇经八脉是否有(编号,"普渡") then
          气血=气血*1.12
        end
        气血=self:取恢复气血(编号,目标[n],气血,名称)
        self:增加气血(目标[n],气血)
        self.战斗流程[#self.战斗流程].挨打方[n].恢复气血=气血
      elseif 名称=="炼气化神" then
          self:增加魔法(目标[n],qz(等级/2))
      elseif 名称=="火甲术" then
          if 编号~=nil and self:取奇经八脉是否有(编号,"返火") then
              --do
          end
      elseif 名称=="魔息术" then
          if 编号~=nil and self:取奇经八脉是否有(编号,"魔息") then
              --do
          end
      elseif 名称=="分身术" then
          if 编号~=nil and self:取奇经八脉是否有(编号,"化身") then
              self.参战单位[编号].法术状态.分身术.回合=self.参战单位[编号].法术状态.分身术.回合+1
          end
          if 编号~=nil and self:取奇经八脉是否有(编号,"批亢") then
              self.参战单位[编号].防御=qz(self.参战单位[编号].防御*1.15)
              self.参战单位[编号].法防=qz(self.参战单位[编号].法防*1.15)
          end
      elseif 名称=="灵动九天" then
          self.参战单位[目标[n]].灵力=self.参战单位[目标[n]].灵力+self.参战单位[编号].等级
          if 编号~=nil and self:取奇经八脉是否有(编号,"灵动") and self.参战单位[目标[n]].灵动~=nil then
              if self.参战单位[目标[n]].灵动==nil then
                  self.参战单位[目标[n]].灵力=self.参战单位[目标[n]].灵力+30
                  self.参战单位[目标[n]].灵动=true
              end
          end
      elseif 名称=="天地同寿" then
          if 编号~=nil and self:取奇经八脉是否有(编号,"同辉") then
              if self.参战单位[目标[n]].法术状态.天地同寿~=nil then
                  self.参战单位[目标[n]].防御=qz(self.参战单位[目标[n]].防御*0.75)
              end
          end
      elseif 名称=="安神诀" then
          if 编号~=nil and self:取奇经八脉是否有(编号,"历战") then
              self.参战单位[目标[n]].法防=self.参战单位[目标[n]].法防*2
          end
      elseif 名称=="神龙摆尾" then
          self.参战单位[目标[n]].法防=self.参战单位[目标[n]].法防*1.2
          self.参战单位[目标[n]].防御=self.参战单位[目标[n]].防御*1.2
          if 编号~=nil and self:取奇经八脉是否有(编号,"傲翔") then
              self.参战单位[目标[n]].法术状态.神龙摆尾.回合=self.参战单位[目标[n]].法术状态.神龙摆尾.回合+1
              self.参战单位[目标[n]].法防=self.参战单位[目标[n]].法防*1.1
              self.参战单位[目标[n]].防御=self.参战单位[目标[n]].防御*1.1
          end
      elseif 名称=="幽冥鬼眼" then
          if 编号~=nil and self:取奇经八脉是否有(编号,"魑魅缠身") then
              self.参战单位[目标[n]].伤害=self.参战单位[目标[n]].伤害*1.15
          end
      elseif 名称=="日月乾坤" then
          if 编号~=nil and self:取奇经八脉是否有(编号,"归本") then

          end
      elseif 名称=="天神护体" then
          self.参战单位[目标[n]].灵力=self.参战单位[目标[n]].灵力+self.参战单位[编号].等级
          if 编号~=nil and self:取奇经八脉是否有(编号,"神律") then
            self.参战单位[目标[n]].法防=self.参战单位[目标[n]].法防*2
            self.参战单位[目标[n]].速度=self.参战单位[目标[n]].速度+qz(self.参战单位[编号].等级*0.3)
          end
      elseif 名称=="牛劲" then
          self.参战单位[目标[n]].灵力=self.参战单位[目标[n]].灵力+self.参战单位[编号].等级
          if 编号~=nil and self:取奇经八脉是否有(编号,"威吓") then
            self.参战单位[目标[n]].灵力=self.参战单位[目标[n]].灵力+qz(self.参战单位[编号].灵力*0.12)
          end
          if 编号~=nil and self:取奇经八脉是否有(编号,"连营") then
            self.参战单位[目标[n]].法术状态.牛劲.回合=self.参战单位[目标[n]].法术状态.牛劲.回合+1
          end
          if 编号~=nil and self:取奇经八脉是否有(编号,"炙烤") then
            if self.参战单位[目标[n]].感知==nil then
                self.参战单位[目标[n]].感知=0.3
            else
                self.参战单位[目标[n]].感知=self.参战单位[目标[n]].感知*1.03
            end
          end
      end
    end
end

function 战斗处理类:减益技能计算(编号,名称,等级)
 local 目标=self.参战单位[编号].指令.目标
  if 目标==0  then
     目标=self:取单个敌方目标(编号)
  elseif self:取目标状态(编号,目标,1)==false then
     目标=self:取单个敌方目标(编号)
  elseif self.参战单位[编号].指令.取消 then
     return
  end
 if 目标==0 then
     return
   end
 if 名称=="尸腐毒" or 名称=="紧箍咒" then
      if self.参战单位[目标].法术状态[名称]~=nil then
          return
       elseif self.参战单位[目标].鬼魂~=nil or self.参战单位[目标].精神~=nil or self.参战单位[目标].信仰~=nil then
         return
         end
   end
  if self.参战单位[目标].法术状态.分身术~=nil and self.参战单位[目标].法术状态.分身术.破解==nil then
      self.参战单位[目标].法术状态.分身术.破解=1
      return
   end
 if self:技能消耗(self.参战单位[编号],1,名称,编号)==false then self:添加提示(self.参战单位[编号].玩家id,编号,"#Y/你当前状态无法使用该技能") return  end
  self.执行等待=self.执行等待+10
   self.战斗流程[#self.战斗流程+1]={流程=56,攻击方=编号,挨打方={},提示={允许=true,类型="法术",名称=self.参战单位[编号].名称.."使用了"..名称}}
     self.战斗流程[#self.战斗流程].挨打方[1]={挨打方=目标,特效={名称}}
      if 名称=="尸腐毒" then
        local 气血=qz(self.参战单位[目标].气血*0.1)
        if 气血>等级*10 then
          气血=等级*10
        end
        self.战斗流程[#self.战斗流程].挨打方[1].死亡=self:减少气血(目标,气血,编号)
        self.战斗流程[#self.战斗流程].挨打方[1].气血=气血
        self.战斗流程[#self.战斗流程].挨打方[1].状态=名称
        self:添加状态(名称,self.参战单位[目标],self.参战单位[编号],等级,编号)
        if self:取指定法宝(编号,"九幽",1) then
          if self:取指定法宝境界(编号,"九幽")>=0 then
            local 目标=self:取多个友方目标(编号,编号,10,"尸腐毒")
            if #目标 == 0 then
              return
            end
            local 目标数 = #目标
            self.战斗流程[#self.战斗流程].受益方 = {}
            for i=1,目标数 do
              local 气血 = 0
              local 法宝层数 = self:取指定法宝境界(编号,"九幽")
              if 释怀定制 then
                self.战斗流程[#self.战斗流程].受益方[i]={受益方=目标[i],伤害=qz(self.参战单位[目标[i]].气血*0.03+self.战斗流程[#self.战斗流程].挨打方[1].气血*0.003)*2}
                气血=qz(self.参战单位[目标[i]].气血*0.03+self.战斗流程[#self.战斗流程].挨打方[1].气血*0.003)*2
              else
                self.战斗流程[#self.战斗流程].受益方[i]={受益方=目标[i],伤害=qz(self.参战单位[目标[i]].气血*0.03+self.战斗流程[#self.战斗流程].挨打方[1].气血*0.003)}
                气血=qz(self.参战单位[目标[i]].气血*0.01+self.战斗流程[#self.战斗流程].挨打方[1].气血*0.002*法宝层数)
              end
              气血=self:取恢复气血(编号,目标[i],气血)
              self:增加气血(目标[i],气血)
            end
          end
        end

      elseif 名称=="紧箍咒" then
         local 气血=qz(等级*5)
         if 编号~=nil and self:取奇经八脉是否有(编号,"默诵") then
             气血=气血*2
         end
         self.战斗流程[#self.战斗流程].挨打方[1].死亡=self:减少气血(目标,气血,编号)
         self.战斗流程[#self.战斗流程].挨打方[1].气血=气血
         self.战斗流程[#self.战斗流程].挨打方[1].状态=名称
         self:添加状态(名称,self.参战单位[目标],self.参战单位[编号],等级,编号)
      elseif 名称=="雾杀" then
         local 气血=qz(等级*7.5)
         self.战斗流程[#self.战斗流程].挨打方[1].死亡=self:减少气血(目标,气血,编号)
         self.战斗流程[#self.战斗流程].挨打方[1].气血=气血
         self.战斗流程[#self.战斗流程].挨打方[1].状态=名称
         self:添加状态(名称,self.参战单位[目标],self.参战单位[编号],等级,编号)
      elseif 名称=="勾魂" and 取随机数()<=40 then
         local 气血=qz(等级*3+self.参战单位[目标].气血*0.05)
         self.战斗流程[#self.战斗流程].挨打方[1].死亡=self:减少气血(目标,气血,编号)
         self.战斗流程[#self.战斗流程].挨打方[1].气血=气血
         local 恢复气血=qz(气血*0.5)
         self:增加气血(编号,恢复气血)
         self.战斗流程[#self.战斗流程].增加气血=恢复气血
      elseif 名称=="谜毒之缚" then
        self:添加状态(名称,self.参战单位[目标],self.参战单位[编号],等级,编号)
      elseif 名称=="诡蝠之刑" then
        self:添加状态(名称,self.参战单位[目标],self.参战单位[编号],等级,编号)
      elseif 名称=="摄魄" and self.参战单位[目标].魔法>=1 and 取随机数()<=40  then
         local 气血=qz(等级*3+self.参战单位[目标].魔法*0.05)
         self.参战单位[目标].魔法=self.参战单位[目标].魔法-气血
         if self.参战单位[目标].魔法<=0 then self.参战单位[目标].魔法=0 end
         if 编号~=nil and self:取奇经八脉是否有(编号,"倾情") then
             if self.参战单位[目标].魔法==0 and 取随机数()<=45 then
                 self:添加状态("含情脉脉",self.参战单位[目标],self.参战单位[编号],等级,编号)
             end
         end
         self.战斗流程[#self.战斗流程].挨打方[1].击退=true
         local 恢复气血=qz(气血*0.5)
          self:增加魔法(目标,气血)
      end
end

function 战斗处理类:取恢复气血(编号,目标,气血,名称)
  local 法修=1
  -- if 名称=="推拿" or 名称=="推气过宫" or 名称=="普渡众生" then
    法修=1+self.参战单位[编号].法术修炼*0.02
  -- end
  if self.参战单位[编号].治疗能力==nil then
    self.参战单位[编号].治疗能力=0
  end
  if self.参战单位[目标].气血回复效果==nil then
    self.参战单位[目标].气血回复效果=0
  end
  local 效果=qz((self.参战单位[编号].治疗能力+self.参战单位[目标].气血回复效果+气血)*法修)
  if self:取指定法宝(编号,"慈悲",1) then
    效果=(1+self:取指定法宝境界(编号,"慈悲")*0.05)*效果
    if self:取指定法宝境界(编号,"慈悲")>=取随机数(1,60) then
      效果=效果*2
    end
  end
  if 编号~=nil and self:取奇经八脉是否有(编号,"同舟共济") and 取随机数()<=30 then
      --do
  end
  if 编号~=nil and self:取奇经八脉是否有(编号,"劳心") and self.参战单位[编号].气血<=qz(self.参战单位[编号].最大气血*0.3) then
      效果=效果*2
  end
  if self.参战单位[编号].队伍==0 then
    if self.参战单位[编号].名称=="长生" then
      效果=效果*3
    elseif self.参战单位[编号].名称=="长生无界" then
      效果=效果*7
    end
  end
  if self.参战单位[目标].法术状态.谜毒之缚~=nil then
    效果=math.floor(效果*0.8)
  end
  return 效果
end

function 战斗处理类:单体封印技能计算(编号,名称,等级)
 local 目标=self.参战单位[编号].指令.目标
  if self:取目标状态(编号,目标,1)==false then
    目标=self:取单个敌方目标(编号)
  end
  if 目标==0 then
    return
  end
  if 法宝~=nil and self:取法宝封印状态(目标) then
    return
  elseif self:取封印状态(目标) then
    return
  end
  if self.参战单位[目标].法术状态.分身术~=nil and self.参战单位[目标].法术状态.分身术.破解==nil then
    self.参战单位[目标].法术状态.分身术.破解=1
    return
  end
  if 名称=="碎玉弄影" then
    if self.参战单位[编号].碎玉限制~=nil and self.回合数-self.参战单位[编号].碎玉限制>=4 then
      self:添加提示(self.参战单位[编号].玩家id,编号,"#Y/该技能必须等待#R/"..(4-(self.回合数-self.参战单位[编号].碎玉限制)).."#Y/回合后才可使用")
      return
    else
      self.参战单位[编号].碎玉限制=self.回合数
    end
  end
  if 名称=="顺势而为" then
    if self.参战单位[编号].顺势限制~=nil and self.回合数-self.参战单位[编号].顺势限制>=6 then
      self:添加提示(self.参战单位[编号].玩家id,编号,"#Y/该技能必须等待#R/"..(6-(self.回合数-self.参战单位[编号].顺势限制)).."#Y/回合后才可使用")
      return
    else
      self.参战单位[编号].顺势限制=self.回合数
    end
  end
  if 名称=="妖风四起" then
    if self.参战单位[编号].妖风限制~=nil and self.回合数-self.参战单位[编号].妖风限制>=6 then
      self:添加提示(self.参战单位[编号].玩家id,编号,"#Y/该技能必须等待#R/"..(6-(self.回合数-self.参战单位[编号].妖风限制)).."#Y/回合后才可使用")
      return
    else
      self.参战单位[编号].妖风限制=self.回合数
    end
  end
  if self:技能消耗(self.参战单位[编号],1,名称,编号)==false then self:添加提示(self.参战单位[编号].玩家id,编号,"#Y/你当前状态无法使用该技能") return  end
  if 名称=="碎玉弄影" then 名称="似玉生香" end
  self.战斗流程[#self.战斗流程+1]={流程=50,攻击方=编号,挨打方={[1]={挨打方=目标,特效={名称},提示={允许=true,类型="法术",名称=self.参战单位[编号].名称.."使用了"..名称}}}}
  self.执行等待=self.执行等待+10
  if self:取封印成功(名称,等级,self.参战单位[编号],self.参战单位[目标],编号) then
    self:添加状态(名称,self.参战单位[目标],self.参战单位[编号],等级)
    self.战斗流程[#self.战斗流程].挨打方[1].添加状态=名称
    if 编号~=nil and self:取奇经八脉是否有(编号,"机巧") and (名称=="如花解语" or 名称=="似玉生香" or 名称=="莲步轻舞") then
        self:添加状态("毒",self.参战单位[目标],self.参战单位[编号],self.参战单位[编号].等级,编号)
        self.战斗流程[#self.战斗流程].挨打方[1].添加状态="毒"
        self.参战单位[目标].法术状态.毒.回合=4
    end
    if 编号~=nil and self:取奇经八脉是否有(编号,"不灭") and 取随机数() <=15 then
        self:恢复技能计算(编号,"归元咒",self.参战单位[编号].等级)
        self.参战单位[编号].防御=self.参战单位[编号].防御*1.1
        self.参战单位[编号].灵力=self.参战单位[编号].灵力*1.1
    end
    if 编号~=nil and self:取奇经八脉是否有(编号,"毒雾") then
        self:添加状态("毒",self.参战单位[目标],self.参战单位[编号],self.参战单位[编号].等级,编号)
        self.战斗流程[#self.战斗流程].挨打方[1].添加状态="毒"
        self.参战单位[目标].法术状态.毒.回合=4
    end
    if 编号~=nil and self:取奇经八脉是否有(编号,"迷瘴") then
         self.参战单位[编号].防御=self.参战单位[编号].防御+qz(self.参战单位[目标].防御*0.04)
    end
    if 编号~=nil and self:取奇经八脉是否有(编号,"意乱") then
        if self.参战单位[目标].意乱==nil then
            self.参战单位[目标].意乱=true
        end
    end
    if 名称=="瘴气" and self:取奇经八脉是否有(编号,"情劫") then
        self.参战单位[目标[1]].法术状态.瘴气.回合=self.参战单位[目标[1]].法术状态.瘴气.回合+3
    end
    if 名称=="锋芒毕露" then
      self:添加状态("锋芒毕露",self.参战单位[目标],self.参战单位[编号],self:取技能等级(编号,"锋芒毕露"),编号)
    end
    if 名称=="诱袭" then
      self:添加状态("诱袭",self.参战单位[目标],self.参战单位[编号],self:取技能等级(编号,"诱袭"),编号)
    end
  end
end

function 战斗处理类:取封印成功(名称,等级,攻击方,挨打方,编号)
  if 名称=="飞花摘叶" or  名称=="画地为牢" or 名称=="风雷韵动" then return true end
  if 名称=="金刚镯" then return true end
  if 名称=="瘴气" then return true end
  if 名称=="摧心术" then return true end
  if 挨打方.队伍==0 and self.战斗类型==100096 and 挨打方.名称=="红颜知己" and 挨打方.真实编号 ~= nil then
    self.战斗发言数据[#self.战斗发言数据+1]={id=挨打方.真实编号,内容="卧槽，有神封，我跑#24"}
    挨打方.红颜发言 = 1
    return true
  end
  if 挨打方.法术状态.乾坤妙法~=nil then return false end
  if 挨打方.不可封印 or 挨打方.鬼魂 or 挨打方.精神 or 挨打方.信仰 then
    return false
  end
  if 编号~=nil and self:取奇经八脉是否有(编号,"忍辱") then
    挨打方.愤怒=挨打方.愤怒+6
    if 挨打方.愤怒>=150 then
      挨打方.愤怒=150
    end
  end
  if 名称=="惊魂铃" or 名称=="鬼泣" or 名称=="断线木偶" then
    if 挨打方.队伍~=0 and 挨打方.类型~="角色" then
      return true
    else
      return false
    end
  end
  if 名称=="发瘟匣" or 名称=="七杀" or 名称=="无魂傀儡" or 名称=="无魂傀儡" or 名称=="无尘扇" or 名称=="无字经"  then
    if 挨打方.队伍~=0 and 挨打方.类型~="角色" then
      if 等级>=取随机数(1,18) then
        return true
      else
        return false
      end
    else
      return false
    end
  end
  if 挨打方.鬼魂 and self:取奇经八脉是否有(编号,"鬼念")==false then
    return false
  end
  if 名称=="尸腐毒" and 挨打方.法术状态.百毒不侵 then
      return false
     end
   if 名称=="毒" and 挨打方.法术状态.百毒不侵 then
      return false
     end
    if 名称=="雾杀" and 挨打方.法术状态.百毒不侵 then
      return false
     end
  if 名称=="顺势而为" or 名称=="雷浪穿云" or 名称=="落花成泥" or 名称=="凋零之歌" then return true end
  if 名称=="似玉生香" or 名称=="莲步轻舞" or 名称=="如花解语" then
     if 挨打方.法术状态.宁心 then
         return false
      end
    end
   if 名称=="含情脉脉" or 名称=="魔音摄魂" or 名称=="瘴气"  then
      if 名称=="瘴气" and self:取奇经八脉是否有(编号,"媚态") then
          if 挨打方.法术状态.寡欲令~=nil then
              self:取消状态("寡欲令",挨打方)
          end
      end
     if 挨打方.法术状态.寡欲令 then
         return false
       end
     end
   if 名称=="催眠符" or 名称=="失心符" or 名称=="落魄符" or 名称=="失忆符" or 名称=="追魂符" or 名称=="离魂符" or 名称=="定身符"   then
     if 挨打方.法术状态.驱魔 then
         return false
       end
     end
     if (名称=="勾魂" or 名称=="摄魄") and self:取奇经八脉是否有(编号,"媚态") then
         return true
     end
  if 名称~="日月乾坤" and 挨打方.神迹==2 then
     return false
  elseif 名称=="威慑" and 挨打方.类型=="角色" then
     return false
  elseif 名称=="反间之计" and 挨打方.类型=="角色" and (self.战斗类型==200003 or self.战斗类型==200004 or self.战斗类型==200005 or self.战斗类型==200006 or self.战斗类型==200007 or self.战斗类型==200008) then
     return false
  end
  if 编号~=nil and self:取奇经八脉是否有(编号,"回敬") and 攻击方.气血<=qz(攻击方.最大气血*0.5) then
      攻击方.封印命中等级=攻击方.封印命中等级+qz(150*(1-攻击方.气血/攻击方.最大气血))
  end
  if 编号~=nil and self:取奇经八脉是否有(编号,"鼓乐") and 名称=="魔音摄魂" then
      攻击方.封印命中等级=攻击方.封印命中等级+200
  end
  if 编号~=nil and self:取奇经八脉是否有(编号,"不倦") and 名称=="催眠符" then
      攻击方.封印命中等级=攻击方.封印命中等级+200
  end
  if 编号~=nil and self:取奇经八脉是否有(编号,"忘川") and 名称=="含情脉脉" and 挨打方.力量 ~= nil and 挨打方.魔力 ~= nil and (挨打方.力量>挨打方.等级*4 or 挨打方.魔力>挨打方.等级*4)  then
      攻击方.封印命中等级=攻击方.封印命中等级+80
  end
  local 等级影响=等级-挨打方.等级+qz(攻击方.封印命中等级/100)
  local 基础几率=30+等级影响
  if 攻击方.队伍==0 and self.战斗类型==100096 and 攻击方.名称=="红颜知己" then
    基础几率 = 基础几率 + 15
  end
  if 让海啸席卷 and 名称 ~= "反间之计" and 攻击方.类型 == "角色" then
    基础几率 = 基础几率 + 40
  end
  if 基础几率>=60 then
      基础几率=60
  end
  if 名称=="一笑倾城" then 基础几率=基础几率*0.5 end
  if 编号~=nil and self:取奇经八脉是否有(编号,"嫣然") and (名称=="似玉生香" or 名称=="一笑倾城") then
      基础几率=基础几率+12
  end
  if 编号 ~= nil and 攻击方.法术状态.四面埋伏~=nil then
    基础几率=基础几率+10
  end
  if 编号~=nil and self:取奇经八脉是否有(编号,"陌宝") and 名称=="日月乾坤" then
      if 挨打方.陌宝==nil then
          挨打方.陌宝=true
      end
      基础几率=基础几率+2
      攻击方.伤害=qz(攻击方.伤害*0.85)
  end
  if 基础几率>=取随机数() then
     return true
    else
     return false
     end
end
function 战斗处理类:取是否物攻技能(名称)
  if 名称=="断岳势"  then
    return true
  elseif 名称=="天崩地裂"  then
    return true
  elseif 名称=="惊涛怒"  then
    return true
  elseif 名称=="翻江搅海" then
    return true
  elseif 名称=="裂石" then
    return true
  elseif 名称=="浪涌" then
    return true
  elseif 名称=="烟雨剑法" then
    return true
  elseif 名称=="牛刀小试" then
    return true
  elseif 名称=="连环击" then
    return true
  elseif 名称=="剑荡四方" then
    return true
  elseif 名称=="横扫千军" or 名称=="高级连击" or 名称=="理直气壮" then
    return true
  elseif 名称=="后发制人" then
    return true
  elseif 名称=="裂石" then
    return true
  elseif 名称=="断岳势" then
    return true
  elseif 名称=="天崩地裂" then
    return true
  elseif 名称=="满天花雨" then
    return true
  elseif 名称=="狮搏" then
    return true
  elseif 名称=="鹰击" then
    return true
  elseif 名称=="壁垒击破" then
    return true
  elseif 名称=="破血狂攻" then
    return true
  elseif 名称=="剑荡四方" then
    return true
  elseif 名称=="裂石" then
    return true
  elseif 名称=="断岳势" or 名称=="天崩地裂" then
    return true
  elseif 名称=="象形" then
    return true
  elseif 名称=="后发制人" then
    return true
  elseif 名称=="壁垒击破" or 名称=="弱点击破" or 名称=="蚩尤之搏" then
    return true
  elseif 名称=="满天花雨" then
    return true
  elseif 名称=="威震凌霄" or 名称=="当头一棒" or 名称=="神针撼海" or 名称=="杀威铁棒" or 名称=="泼天乱棒" then
    return true
  end
  return false
end

function 战斗处理类:物攻技能计算(编号,名称,等级)
  if 名称=="后发制人" then
    if self:取行动状态(编号)==false or self:取目标状态(编号,self.参战单位[编号].法术状态.后发制人.目标,1)==false then
      self:取消状态(名称,self.参战单位[编号])
      self.战斗流程[#self.战斗流程+1]={流程=610,攻击方=编号,状态="后发制人",挨打方={{挨打方=1}}}
      return
    else
      self.参战单位[编号].指令.目标=self.参战单位[编号].法术状态.后发制人.目标
    end
  end
  local 目标=self.参战单位[编号].指令.目标
  local 目标数=self:取目标数量(self.参战单位[编号],名称,等级,编号)
  local 目标=self:取多个敌方目标(编号,目标,目标数)
  local 战意提示=false
  for n=1,#目标 do
    if self.参战单位[目标[n]].法术状态.分身术~=nil and self.参战单位[目标[n]].法术状态.分身术.破解==nil then
      self.参战单位[目标[n]].法术状态.分身术.破解=1
      table.remove(目标,n)
      return
    end
  end
  if #目标==0 then return end
  目标数=#目标
  if 名称=="断岳势" and self.参战单位[编号].战意<1 then
    self:添加提示(self.参战单位[编号].玩家id,编号,"#Y/你当前可使用的战意为#R/"..self.参战单位[编号].战意.."#Y/点，无法使用"..名称)
    return
  elseif 名称=="天崩地裂" and self.参战单位[编号].战意<3 then
    self:添加提示(self.参战单位[编号].玩家id,编号,"#Y/你当前可使用的战意为#R/"..self.参战单位[编号].战意.."#Y/点，无法使用"..名称)
    return
  elseif 名称=="惊涛怒" and self.参战单位[编号].战意<1 then
    self:添加提示(self.参战单位[编号].玩家id,编号,"#Y/你当前可使用的战意为#R/"..self.参战单位[编号].战意.."#Y/点，无法使用"..名称)
    return
  elseif 名称=="翻江搅海" and self.参战单位[编号].战意<3 then
    self:添加提示(self.参战单位[编号].玩家id,编号,"#Y/你当前可使用的战意为#R/"..self.参战单位[编号].战意.."#Y/点，无法使用"..名称)
    return
  elseif 名称=="翩鸿一击" and self.参战单位[编号].翩鸿回合~=nil and self.回合数-self.参战单位[编号].翩鸿回合<5 then
    self:添加提示(self.参战单位[编号].玩家id,编号,"#Y/该技能必须等待#R/"..(5-(self.回合数-self.参战单位[编号].翩鸿回合)).."#Y/回合后才可使用")
    return
  elseif 名称=="长驱直入" and self.参战单位[编号].长驱回合~=nil and self.回合数-self.参战单位[编号].长驱回合<4 then
    self:添加提示(self.参战单位[编号].玩家id,编号,"#Y/该技能必须等待#R/"..(4-(self.回合数-self.参战单位[编号].长驱回合)).."#Y/回合后才可使用")
    return
  elseif 名称=="鸿渐于陆" and self.参战单位[编号].鸿渐回合~=nil and self.回合数-self.参战单位[编号].鸿渐回合<4 then
     self:添加提示(self.参战单位[编号].玩家id,编号,"#Y/该技能必须等待#R/"..(4-(self.回合数-self.参战单位[编号].鸿渐回合)).."#Y/回合后才可使用")
     return
  elseif 名称=="天命剑法" and self.参战单位[编号].天命回合~=nil and self.回合数-self.参战单位[编号].天命回合<5 then
    self:添加提示(self.参战单位[编号].玩家id,编号,"#Y/该技能必须等待#R/"..(5-(self.回合数-self.参战单位[编号].天命回合)).."#Y/回合后才可使用")
    return
  end
  if 编号~=nil and self:取奇经八脉是否有(编号,"魂聚") then
      self.参战单位[编号].愤怒=self.参战单位[编号].愤怒+6
      if self.参战单位[编号].愤怒 > 150 then
        self.参战单位[编号].愤怒 = 150
      end
  end
  if self:技能消耗(self.参战单位[编号],目标数,名称,编号)==false then self:添加提示(self.参战单位[编号].玩家id,编号,"#Y/你当前状态无法使用该技能") return  end
    if 名称=="断岳势" and self.参战单位[编号].战意>=1 then
       self.参战单位[编号].战意=self.参战单位[编号].战意-1
       战意提示=true
    elseif 名称=="天崩地裂" and self.参战单位[编号].战意>=3 then
        self.参战单位[编号].战意=self.参战单位[编号].战意-3
        战意提示=true
    elseif 名称=="惊涛怒" and self.参战单位[编号].战意>=1 then
        self.参战单位[编号].战意=self.参战单位[编号].战意-1
        战意提示=true
    elseif 名称=="翻江搅海" and self.参战单位[编号].战意>=3 then
        self.参战单位[编号].战意=self.参战单位[编号].战意-3
        战意提示=true
    elseif 名称=="裂石" then
        self.参战单位[编号].战意=self.参战单位[编号].战意+1
        战意提示=true
    elseif 名称=="浪涌" then
        self.参战单位[编号].战意=self.参战单位[编号].战意+1
        战意提示=true
    end
    if 战意提示 then
        self:添加提示(self.参战单位[编号].玩家id,编号,"#Y/你当前可使用的战意为#R/"..self.参战单位[编号].战意.."#Y/点")
    end
    local 返回=nil
    local 重复攻击=false
    local 起始伤害=1
    local 叠加伤害=0
    local 重复提示=false
    local 允许保护=true
    local 增加伤害=0
    local 伤害参数=0
    local 结尾气血=0
    local 防御减少=0
    if 编号~=nil and self:取奇经八脉是否有(编号,"强袭") and self.参战单位[编号].法术状态.不动如山~=nil then
      起始伤害=起始伤害*1.2
    end
    if 名称=="烟雨剑法" then
      目标数=2
      if 编号~=nil and self:取奇经八脉是否有(编号,"天命剑法") then
          目标数=取随机数(2,5)
      end
      起始伤害=0.35
      叠加伤害=0.35
      重复攻击=true
      伤害参数=1.5
      if self.参战单位[编号].烟雨飘摇 ~= 0 then
          增加伤害 = self.参战单位[编号].烟雨飘摇
      end
      for i=1,目标数 do
        if i==2 then
          if 编号~=nil and self:取奇经八脉是否有(编号,"雨杀") then
            self.参战单位[编号].必杀=self.参战单位[编号].必杀+20
          end
        end
      end
    elseif 名称=="连环击" then
      目标数=math.floor(等级/35)+2
      if 编号~=nil and self:取奇经八脉是否有(编号,"乱击") then
          目标数=目标数+1
      end
      重复攻击=true
      伤害参数=1
      起始伤害=0.8
      叠加伤害=-0.15
      if 编号~=nil and self:取奇经八脉是否有(编号,"乱破") and 取随机数()<=45 then
          增加伤害=增加伤害+qz(self.参战单位[编号].等级)
      end
    elseif 名称=="猛击" then
      目标数=2
      重复攻击=true
      伤害参数=3
      起始伤害=1.25
    elseif 名称=="鸿渐于陆" then
      起始伤害=1.65
      增加伤害=qz(self.参战单位[编号].武器伤害*1.3)
      if 增加伤害<1 then 增加伤害=1 end
      self.参战单位[编号].鸿渐回合=self.回合数
    elseif 名称=="剑荡四方" then
      起始伤害=0.65
      叠加伤害=-0.15
      结尾气血=qz(self.参战单位[编号].气血*0.01)
      self:减少气血(编号,结尾气血)
    elseif 名称=="横扫千军" then
      起始伤害=0.35
      叠加伤害=0.35
      重复攻击=true
      伤害参数=1.5
      if 编号~=nil and self:取奇经八脉是否有(编号,"勇念") then
        增加伤害=qz(self.参战单位[目标[1]].防御*0.1)
      end
      if 编号~=nil and self:取奇经八脉是否有(编号,"无敌") then
        目标数=4
        结尾气血=qz(self.参战单位[编号].最大气血*0.2)
      else
        目标数=3
        结尾气血=qz(self.参战单位[编号].最大气血*0.1)
      end
      if 编号~=nil and self:取奇经八脉是否有(编号,"破军") then
        for i=1,目标数 do
          增加伤害=qz(self.参战单位[目标[1]].最大气血*0.01*i)+200
        end
      end
      self:减少气血(编号,结尾气血)
    elseif 名称=="破釜沉舟" then
      if 编号~=nil and self:取奇经八脉是否有(编号,"破空") then
          增加伤害=增加伤害+qz(self.参战单位[目标].防御*0.3)
      end
    elseif 名称=="天雷斩" then
      if 编号~=nil and self:取奇经八脉是否有(编号,"疾雷") then
          增加伤害=增加伤害+qz((self.参战单位[编号].敏捷-self.参战单位[编号].等级)*0.6)
      end
    elseif 名称=="高级连击" then
      起始伤害=0.8
      叠加伤害=-0.1
      目标数=2
      重复攻击=true
    elseif 名称=="理直气壮" then
      起始伤害=0.8
      叠加伤害=-0.1
      目标数=3
      重复攻击=true
    elseif 名称=="后发制人" then
      if 编号~=nil and self:取奇经八脉是否有(编号,"勇武") then
        结尾气血=qz(self.参战单位[编号].气血*0.15)
        self:增加气血(编号,结尾气血)
        增加伤害=qz(self.参战单位[编号].防御*0.4)
      else
        结尾气血=qz(self.参战单位[编号].气血*0.05)
        self:减少气血(编号,结尾气血)
      end
    elseif 名称=="裂石" then
     self.参战单位[编号].必杀=self.参战单位[编号].必杀+qz(等级/100)*3
    elseif 名称=="断岳势" then
     目标数=2
     重复攻击=true
     伤害参数=2
     起始伤害=0.7
     叠加伤害=-0.1
     伤害参数=1.3
     if 编号~=nil and self:取奇经八脉是否有(编号,"再战") then
         起始伤害=0.8
     end
     self.参战单位[编号].必杀=self.参战单位[编号].必杀+qz(等级/100)*2
    elseif 名称=="天崩地裂" then
     目标数=3
     重复攻击=true
     伤害参数=2
     起始伤害=0.6
     叠加伤害=-0.1
     if 编号~=nil and self:取奇经八脉是否有(编号,"天神怒斩") then
         目标数=4
     end
     if 编号~=nil and self:取奇经八脉是否有(编号,"力战") then
        for i=1,目标数 do
          if i==目标数 then
              增加伤害=增加伤害+360
          end
        end
     end
      if 编号~=nil and self:取奇经八脉是否有(编号,"山破") then
          local 气血=qz(self.参战单位[编号].最大气血*0.05)
          self:增加气血(编号,气血)
      end
     self.参战单位[编号].必杀=self.参战单位[编号].必杀+qz(等级/100)*2
  elseif 名称=="满天花雨" then
     起始伤害=1.35
  elseif 名称=="狮搏" then
     伤害参数=3
     if 编号~=nil and self:取奇经八脉是否有(编号,"狮吼") then
         起始伤害=1.15
     end
  elseif 名称=="鹰击" then
    if 编号~=nil and self:取奇经八脉是否有(编号,"翼展") then
        增加伤害=增加伤害+qz(self.参战单位[编号].等级*1.2)
    end
    if 编号~=nil and self:取奇经八脉是否有(编号,"鹰啸") then
        增加伤害=增加伤害+qz(self.参战单位[编号].等级*1.15)
    end
    if 编号~=nil and self:取奇经八脉是否有(编号,"死地") then
        增加伤害=增加伤害+qz(self.参战单位[编号].等级*1.15)
    end
     重复提示=true
     返回=true
  elseif 名称=="壁垒击破" then
    防御减少=qz(self.参战单位[目标[1]].防御*0.3)
    self.参战单位[目标[1]].防御=self.参战单位[目标[1]].防御-防御减少
    if self.参战单位[目标[1]].指令.类型=="防御" then
      增加伤害=qz(self.参战单位[编号].伤害*1.5)
    end
    伤害参数=0
  elseif 名称=="翩鸿一击" then
    起始伤害=1.55
    if self:取奇经八脉是否有(编号,"目空") then
        增加伤害=增加伤害+self.参战单位[目标[1]].防御*0.1
    end
    self.参战单位[编号].翩鸿回合=self.回合数
  elseif 名称=="长驱直入" then
    起始伤害=1.1
    if 取随机数()<=60 then
        起始伤害=2
    end
    self.参战单位[编号].长驱回合=self.回合数
  elseif 名称=="针锋相对" then
    起始伤害=1.1
    if 编号~=nil and self:取奇经八脉是否有(编号,"善工") then
      起始伤害=1.2
    end
  elseif 名称=="百爪狂杀" then
    重复提示=true
    返回=true
    起始伤害=1.25-(目标数-1)*0.1
    if self:取奇经八脉是否有(编号,"百炼") then
      增加伤害=self.参战单位[编号].武器伤害
    end
  elseif 名称=="威震凌霄" then
    起始伤害=1.1
  elseif 名称=="当头一棒" then
    起始伤害=1.1
    if self.参战单位[目标[1]].气血>=qz(self.参战单位[目标[1]].最大气血*0.6) and self.参战单位[目标[1]].气血>=qz(self.参战单位[目标[1]].最大气血*0.7) then
      起始伤害=起始伤害*2
    end
    if 编号~=nil and self:取奇经八脉是否有(编号,"闹天") then
      起始伤害=qz(起始伤害*1.15)
    end
  elseif 名称=="神针撼海" then
    起始伤害=1.1
    if 编号~=nil and self:取奇经八脉是否有(编号,"搅海") and 取随机数()>=90 then
      起始伤害=qz(起始伤害*2)
    end
  elseif 名称=="杀威铁棒" then
    起始伤害=1.1
    self.参战单位[编号].防御=qz(self.参战单位[编号].防御*1.2)
  elseif 名称=="泼天乱棒" then
    起始伤害=1.1
  elseif 名称=="破血狂攻" then
    目标[2]=目标[1]
    目标数=#目标
    if 编号~=nil and self:取奇经八脉是否有(编号,"目空") then
      增加伤害=qz(self.参战单位[目标[1]].防御*0.1)
    end
    起始伤害=1.2
    if 编号~=nil and self:取奇经八脉是否有(编号,"强击") then
      起始伤害=1.5
    end
  elseif 名称=="破碎无双" then
    if 编号~=nil and self:取奇经八脉是否有(编号,"强击") then
      起始伤害=1.2
    end
  elseif 名称=="弱点击破" then
    防御减少=qz(self.参战单位[目标[1]].防御*0.65)
    self.参战单位[目标[1]].防御=self.参战单位[目标[1]].防御-防御减少
    if 编号~=nil and self:取奇经八脉是否有(编号,"目空") then
      增加伤害=qz(self.参战单位[目标[1]].防御*0.1)
    end
    if 编号~=nil and self:取奇经八脉是否有(编号,"火眼") then
      基础伤害=qz(基础伤害*1.5)
    end
  elseif 名称=="蚩尤之搏" then
    防御减少=qz(self.参战单位[目标[1]].防御*0.65)
    self.参战单位[目标[1]].防御=self.参战单位[目标[1]].防御-防御减少
  elseif 名称=="牛刀小试" then
      目标数=3
  else
      伤害参数=3
  end
  if 编号~=nil and self:取奇经八脉是否有(编号,"兽王") and self.参战单位[编号].法术状态.变身~=nil then
      增加伤害=增加伤害+self.参战单位[编号].等级*2
  end
  if 编号~=nil and self:取奇经八脉是否有(编号,"煞气") then
      增加伤害=增加伤害+100
  end
  if 编号~=nil and self:取奇经八脉是否有(编号,"怒涛") and 取随机数()<=70 then
      self.参战单位[编号].防御=qz(self.参战单位[编号].防御-self.参战单位[编号].等级*0.5)
  end
  if 增加伤害==nil then
      增加伤害=0
  end
    增加伤害=增加伤害+伤害参数*等级
    self.参战单位[编号].伤害=self.参战单位[编号].伤害+增加伤害
    if 重复攻击 == true then
      local 临时目标=目标[1]
      for n=1,目标数 do
        目标[n]=临时目标
      end
    end
  --计算流程
    local 战斗终止=false
    for n=1,目标数 do
      if 战斗终止==false  then
        self:物攻技能计算1(编号,目标[n],起始伤害,叠加伤害,返回,允许保护,n,名称)--
        local 提示内容x = ""
        if 名称~= "高级连击" and 名称~="理直气壮" then
          提示内容x = self.参战单位[编号].名称.."使用了"..名称
        end
        self.战斗流程[#self.战斗流程].提示={类型="法术",名称=提示内容x,允许=true}
        if n>1 and 重复提示==false then
          self.战斗流程[#self.战斗流程].提示.允许=false
        end
        if n==目标数 then
          self.战斗流程[#self.战斗流程].返回=true
        elseif self:取目标状态(编号,目标[n+1],1)==false or self:取行动状态(编号)==false then
          self.战斗流程[#self.战斗流程].返回=true
          战斗终止=true
        end
      end
    end
    self.参战单位[编号].伤害=self.参战单位[编号].伤害-增加伤害
    if 名称=="横扫千军" or 名称=="鹰击" or 名称=="连环击" then
      self:添加状态(名称,self.参战单位[编号],nil,nil,编号)
      self.战斗流程[#self.战斗流程].添加状态=名称
      if 名称=="横扫千军" then
        self.战斗流程[#self.战斗流程].结尾气血=结尾气血
      end
      if 名称=="连环击" then
        self.战斗流程[#self.战斗流程].取消状态="变身"
      end
    elseif 名称=="天命剑法" then
      self.战斗流程[#self.战斗流程].结尾气血=结尾气血
      self:添加状态("横扫千军",self.参战单位[编号])
      self.战斗流程[#self.战斗流程].添加状态="横扫千军"
    elseif 名称=="剑荡四方" then
      self.战斗流程[#self.战斗流程].结尾气血=结尾气血
    elseif 名称=="裂石" then
      self.参战单位[编号].必杀=self.参战单位[编号].必杀-qz(等级/100)*3
    elseif 名称=="威震凌霄" then
      self:添加状态("威震凌霄",self.参战单位[目标[1]],self.参战单位[编号],self:取技能等级(编号,"威震凌霄"),编号)
    elseif 名称=="断岳势" or 名称=="天崩地裂" then
       self.参战单位[编号].必杀=self.参战单位[编号].必杀-qz(等级/100)*2
    elseif 名称=="象形" then
      self.战斗流程[#self.战斗流程].挨打方[1].添加状态=名称
      self.战斗流程[#self.战斗流程].取消状态="变身"
      self:添加状态(名称,self.参战单位[目标[1]])
      self:添加状态(名称,self.参战单位[编号],nil,nil,编号)
      self:取消状态("变身",self.参战单位[编号])
      self.战斗流程[#self.战斗流程].添加状态=名称
    elseif 名称=="死亡召唤" and 取随机数()<=100 then
      self.战斗流程[#self.战斗流程].挨打方[1].添加状态=名称
      self:添加状态(名称,self.参战单位[目标[1]])
    elseif 名称=="后发制人" then
      self.战斗流程[#self.战斗流程].取消状态="后发制人"
      self:取消状态("后发制人",self.参战单位[编号])
    elseif 名称=="壁垒击破" or 名称=="弱点击破" then
      self.参战单位[目标[1]].防御=self.参战单位[目标[1]].防御+防御减少
    elseif 名称=="满天花雨" then
      self.战斗流程[#self.战斗流程].流程=400
      if  30>=取随机数() and self:取封印成功("毒",self.参战单位[编号].等级,self.参战单位[编号],self.参战单位[目标[1]],编号) then
          self:添加状态("毒",self.参战单位[目标[1]],self.参战单位[编号],self.参战单位[编号].等级,编号)
          self.战斗流程[#self.战斗流程].挨打方[1].添加状态="毒"
          self.参战单位[目标[1]].法术状态.毒.回合=3
      end
    end

end

function 战斗处理类:添加状态(名称,攻击方,挨打方,等级,攻击编号,境界)
  if 名称=="莲心剑意" and 攻击方.法术状态[名称]~=nil then
    攻击方.法术状态[名称]=nil
    return
  end
  if 攻击方.法术状态[名称]~=nil then
    return
  elseif 名称=="碎星诀" and 攻击方.法术状态["镇魂诀"]~=nil then
    return
  elseif 名称=="镇魂诀" and 攻击方.法术状态["碎星诀"]~=nil then
    return
  end
  攻击方.法术状态[名称]={攻击编号=攻击编号,境界=境界}
  local 伤害1=攻击方.伤害
  local 防御1=攻击方.防御
  local 速度1=攻击方.速度
  local 法防1=攻击方.法防
  local 躲闪1=攻击方.躲闪
  local 命中1=攻击方.命中
  local 灵力1=攻击方.灵力
  local 回合=2
  local 伤害=0
  local 防御=0
  local 速度=0
  local 法防=0
  local 躲闪=0
  local 类型=1
  local 命中=0
  local 灵力=0
  local 编号=攻击编号
  if 名称=="横扫千军" then
    if 攻击编号~=nil and self:取奇经八脉是否有(攻击编号,"连破") and 取随机数(1,100)<=18 then
      回合=1
    else
      回合=2
    end
    if 攻击编号~=nil and self:取奇经八脉是否有(攻击编号,"静岳") then
      防御=qz(防御1*0.7)+150
      法防=qz(法防1*0.7)+150
    else
      防御=qz(防御1*0.7)
      法防=qz(法防1*0.7)
    end
  elseif 名称=="强袭" or 名称=="蚀天" then
    回合=3
  elseif 名称=="轰鸣" then
    回合=3
    防御=qz(攻击方.等级*1.6)
  elseif 名称=="电芒" or 名称=="真君显灵" or 名称=="妖风四起" or 名称=="同舟共济" then
    回合=3
  elseif 名称=="亢龙归海" then
    回合=2
  elseif 名称=="乾坤妙法" or 名称=="画地为牢" or 名称=="风雷韵动" then
    回合=2
  elseif 名称=="一笑倾城" then
    回合=2
  elseif 名称=="惊魂铃" or 名称=="鬼泣" or 名称=="摄魂" then
    回合=2
    攻击方.法术状态[名称].等级=等级
  elseif 名称=="七杀" then
    回合=4
    防御=qz(等级*20)
  elseif 名称=="雾杀1" or 名称=="失心" then
    回合=1
  elseif 名称=="莲心剑意"  then
    回合=999
  elseif 名称=="波澜不惊"  then
    回合=2
  elseif 名称=="凋零之歌"  then
    回合=2
  elseif 名称=="雷浪穿云" then
    回合=5
  elseif 名称=="魑魅缠身" then
    回合=5
  elseif 名称=="冰锥" then
    回合=1
  elseif 名称=="烈焰真诀" then
    回合=4
  elseif 名称=="御风" then
    回合=3
    速度=qz(挨打方.特性几率*5)
    类型=2
  elseif 名称=="张弛有道" then
    回合=9999
  elseif 名称=="浮云神马" then
    回合=5
    速度=qz(速度1*0.1)
    类型=2
  elseif 名称=="龙魂" then
    回合=2
  elseif 名称=="灵刃" then
    回合=4
    防御=qz(防御1*0.2)
    法防=qz(法防1*0.2)
  elseif 名称=="灵断" then
    回合=4
  elseif 名称=="灵法1" then
    回合=4
    防御=qz(防御1*0.1)
  elseif 名称=="灵法" then
    回合=4
    灵力=qz(攻击方.气血*(攻击方.特性几率*5/100))
    类型=2
  elseif 名称=="怒吼" then
    回合=2
    伤害=qz(伤害1*0.2)
    类型=2
  elseif 名称=="怒吼1" then
    回合=2
    灵力=qz(灵力1*0.1)
  elseif 名称=="护佑" then
    回合=3
    灵力=qz(灵力1*0.1)
    境界=挨打方.特性几率
  elseif 名称=="后发制人" then
    回合=qz(等级/30)+1
    if 攻击编号~=nil and self:取奇经八脉是否有(攻击编号,"静岳") then
      防御=qz(等级*3.5)+150
      法防=qz(等级*0.4)+150
    else
      防御=qz(等级*3.5)
      法防=qz(等级*0.4)
    end
    伤害=qz(等级*10)
    类型=2
  elseif 名称=="变身"  then
    回合=qz(等级/30)+2
    if 攻击编号~=nil and self:取奇经八脉是否有(攻击编号,"宁息") then
        回合=回合+2
    end
  elseif 名称=="反间之计"  then
    回合=qz(等级/30)+2
  elseif 名称=="移魂化骨"  then
    回合=qz(等级/20)+1
    攻击方.法术状态[名称].等级=等级
  elseif 名称=="催眠符" then
    回合=qz(等级/50)+2
    if 攻击编号~=nil and self:取奇经八脉是否有(攻击编号,"黄粱") then
        回合=回合+1
    end
  elseif 名称=="炎护" then
    回合=qz(等级/50)+1
  elseif 名称=="失心符" then
    回合=qz(等级/40)+3
    法防=法防1-等级
    if 攻击编号~=nil and self:取奇经八脉是否有(攻击编号,"苦缠") then
        法防=qz(法防*0.97)
    end
  elseif 名称=="落魄符" then
    回合=qz(等级/20)+1
  elseif 名称=="失忆符" then
    回合=qz(等级/20)+1
   elseif 名称=="追魂符" then
    回合=qz(等级/20)+1
    防御=防御1-等级*2
   elseif 名称=="离魂符" then
    回合=qz(等级/20)+1
    躲闪=躲闪1-等级
  elseif 名称=="天罗地网" or 名称=="百毒不侵" or 名称=="宁心" or 名称=="驱魔" or 名称=="寡欲令" then
    回合=qz(等级/30)+2
  elseif 名称=="失魂符" then
    回合=qz(等级/20)+1
    防御=防御1-等级
    if 攻击编号~=nil and self:取奇经八脉是否有(攻击编号,"苦缠") then
        法防=qz(法防*0.97)
    end
  elseif 名称=="定身符" then
    回合=qz(等级/20)+1
    防御=防御1-qz(等级*0.5)
    法防=法防1-qz(等级*0.5)
    if 攻击编号~=nil and self:取奇经八脉是否有(攻击编号,"苦缠") then
        法防=qz(法防*0.97)
        防御=qz(防御*0.97)
    end
  elseif 名称=="莲步轻舞" then
    回合=qz(等级/20)+2
  elseif 名称=="如花解语" then
    回合=qz(等级/20)+2
  elseif 名称=="似玉生香" then
    回合=qz(等级/35)+1
  elseif 名称=="娉婷嬝娜" then
    回合=qz(等级/40)+1
  elseif 名称=="日月乾坤" then
    回合=qz(等级/35)+2
  elseif 名称=="镇妖" then
    回合=qz(等级/35)+1
  elseif 名称=="错乱" then
    回合=qz(等级/35)+1
  elseif 名称=="百万神兵" then
    回合=qz(等级/35)+1
  elseif 名称=="威慑" then
    回合=qz(等级/25)+2
  elseif 名称=="含情脉脉" then
    回合=qz(等级/20)+2
  elseif 名称=="魔音摄魂" then
    回合=qz(等级/15)+2
  elseif 名称=="夺魄令" then
    回合=qz(等级/20)+1
  elseif 名称=="惊魂掌" then
    回合=qz(等级/35)+1
  elseif 名称=="煞气诀" then
    回合=qz(等级/20)+1
  elseif 名称=="杀气诀" then
    回合=qz(等级/30)+1
    命中=等级
    类型=2
  elseif 名称=="潜能激发" then
    回合 = 4
    伤害 = qz(伤害1*0.1)
    防御 = qz(防御1*0.1)
    速度 = qz(速度1*0.1)
    法防 = qz(法防1*0.1)
    躲闪 = qz(躲闪1*0.1)
    命中 = qz(命中1*0.1)
    灵力 = qz(灵力1*0.1)
    类型=2
  elseif 名称=="牛劲" then
    回合=qz(等级/30)+1
    灵力=qz(等级*1.5)
    类型=2
  elseif 名称=="安神诀" then
    回合=qz(等级/30)+1
    法防=法防+等级
    类型=2
  elseif 名称=="由己渡人" then
    回合=qz(等级/40)+1
    法防=法防+等级
    防御=防御+等级
    类型=2
  elseif 名称=="达摩护体" then
    回合=qz(等级/40)+1
    气血=等级*2
    类型=2
  elseif 名称=="金刚护法" then
    回合=qz(等级/30)+1
    伤害=等级*2
    类型=2
    if 攻击编号~=nil and self:取奇经八脉是否有(攻击编号,"流刚") then
        伤害=qz(伤害*1.2)
    end
    if 攻击编号~=nil and self:取奇经八脉是否有(攻击编号,"佛屠") then
        伤害=伤害+qz(攻击方.装备属性.伤害*1.09)
    end
  elseif 名称=="金刚护体" then
    回合=qz(等级/30)+1
    防御=等级
    类型=2
    if 攻击编号~=nil and self:取奇经八脉是否有(攻击编号,"流刚") then
        防御=qz(防御*1.2)
    end
    if 攻击编号~=nil and self:取奇经八脉是否有(攻击编号,"诸天看护") then
        防御=qz(防御*1.2)
        法防=qz(法防*1.2)
    end
  elseif 名称=="罗汉金钟" then
    回合=4
  elseif 名称=="顺势而为" then
    回合=2
  elseif 名称=="钟馗论道" then
    回合=5
  elseif 名称=="渡劫金身" then
    回合=2
  elseif 名称=="诸天看护" then
    回合=1
  elseif 名称=="圣灵之甲" then
    回合=999
    防御=防御1*0.05
    类型=2
  elseif 名称=="魔兽之印" then
    回合=999
    伤害=伤害1*0.05
    类型=2
  elseif 名称=="光辉之甲" then
    回合=999
    防御=防御1*0.1
    类型=2
  elseif 名称=="法术防御" then
    回合=5
  elseif 名称=="太极护法" then
    回合=4
  elseif 名称=="死亡召唤" then
    回合=10
  elseif 名称=="野兽之力" then
    回合=999
    伤害=伤害1*0.1
    类型=2
  elseif 名称=="明光宝烛" then
    回合=qz(等级/35)+1
    防御=qz(等级*1.5)
    类型=2
  elseif 名称=="韦陀护法" then
    回合=qz(等级/30)+1
    伤害=等级
    类型=2
  elseif 名称=="翩鸿一击" then
    回合=2
    速度=qz(攻击方.速度*0.1)
    类型=2
  elseif 名称=="一苇渡江" then
    回合=qz(等级/30)+1
    速度=qz(等级*0.5)
    类型=2
    if 攻击编号~=nil and self:取奇经八脉是否有(攻击编号,"流刚") then
        速度=qz(速度*1.2)
    end
  elseif 名称=="佛法无边" then
    回合=qz(等级/40)+1
   elseif 名称=="楚楚可怜" then
    回合=qz(等级/30)+1
  elseif 名称=="天神护法" then
    回合=qz(等级/30)+1
  elseif 名称=="乘风破浪" then
    回合=qz(等级/30)+1
    躲闪=qz(等级*1.5)
    类型=2
  elseif 名称=="神龙摆尾" then
    回合=qz(等级/40)+1
  elseif 名称=="生命之泉" then
    回合=qz(等级/30)+1
    攻击方.法术状态[名称].等级=等级
    攻击方.法术状态[名称].编号=攻击编号
  elseif 名称=="毒" then
    回合=5
    攻击方.法术状态[名称].等级=等级
    攻击方.法术状态[名称].编号=攻击编号
  elseif 名称=="炼气化神" then
    回合=qz(等级/30)+1
    攻击方.法术状态[名称].等级=等级
    攻击方.法术状态[名称].编号=攻击编号
  elseif 名称=="普渡众生" then
    回合=qz(等级/30)+1
    攻击方.法术状态[名称].等级=等级
    攻击方.法术状态[名称].编号=攻击编号
  elseif 名称=="天地同寿"  then
    回合=qz(等级/30)+1
  elseif 名称=="乾坤妙法" then
    回合=qz(等级/30)+1
  elseif 名称=="灵动九天" then
    回合=qz(等级/30)+1
    灵力=qz(等级*3)
    类型=2
  elseif 名称=="颠倒五行" then
    回合=qz(等级/50)+1
  elseif 名称=="幽冥鬼眼" then
    回合=qz(等级/50)+1
  elseif 名称=="修罗隐身" then
    回合=qz(等级/25)+1
  elseif 名称=="火甲术" then
    回合=qz(等级/30)+1
  elseif 名称=="魔王回首" then
    回合=qz(等级/30)+1
  elseif 名称=="定心术" then
    回合=qz(等级/30)+1
    灵力=qz(等级*2)
    类型=2
  elseif 名称=="干将莫邪" then
    回合=3
    伤害=qz(境界*20)
    类型=2
  elseif 名称=="乾坤玄火塔" then
    回合=5
    local 愤怒=qz(150*(qz(境界/5)*0.02+0.02))
    if self.参战单位[攻击编号].愤怒~=nil then self.参战单位[攻击编号].愤怒=self.参战单位[攻击编号].愤怒+愤怒 end
    if self.参战单位[攻击编号].愤怒>150 then self.参战单位[攻击编号].愤怒=150 end
  elseif 名称=="混元伞" or 名称=="苍白纸人" then
    回合=3
  elseif 名称=="无尘扇" then
    回合=3
  elseif 名称=="无魂傀儡" then
    回合=2
  elseif 名称=="断线木偶" or 名称=="五彩娃娃" then
    回合=2
  elseif 名称=="极度疯狂" then
    回合=qz(等级/30)+1
  elseif 名称=="魔息术" then
    回合=qz(等级/30)+1
    攻击方.法术状态[名称].等级=等级
   elseif 名称=="尸腐毒" then
    回合=qz(等级/20)+1
    攻击方.法术状态[名称].等级=等级
    elseif 名称=="紧箍咒" then
    回合=qz(等级/20)+1
    攻击方.法术状态[名称].等级=等级
  elseif 名称=="雾杀" then
    回合=qz(等级/20)+1
    攻击方.法术状态[名称].等级=等级
  elseif 名称=="天魔解体" then
    回合=qz(等级/30)+1
   -- 类型=2
    防御=qz(防御1*0.5)
    攻击方.法术状态[名称].附加伤害=qz(防御*0.1)
    攻击方.伤害=攻击方.伤害+攻击方.法术状态[名称].附加伤害
  elseif 名称=="盘丝阵" then
    回合=qz(等级/20)+1
    防御=等级
    类型=2
    if 攻击编号~=nil and self:取奇经八脉是否有(攻击编号,"结阵") then
        防御=防御*4
        回合=回合-3
    end
  elseif 名称=="金刚镯" then
    回合=qz(等级/40)
    伤害=等级*2
  elseif 名称=="幻境术" then
    回合=qz(等级/30)+1
  elseif 名称=="四面埋伏" then
    回合=qz(等级/30)+1
  elseif 名称=="不动如山" then
    回合=qz(等级/30)+1
    防御=等级*3
    法防=等级*2
    类型=2
  elseif 名称=="碎星诀"  then
    回合=qz(等级/30)+1
    伤害=等级
    类型=2
    if 攻击编号~=nil and self:取奇经八脉是否有(攻击编号,"斩魔") then
        伤害=qz(伤害*1.12)
    end
    if 攻击编号~=nil and self:取奇经八脉是否有(攻击编号,"战诀") and 攻击方.战诀==nil then
        攻击方.必杀=qz(攻击方.必杀*1.1)
        攻击方.战诀=true
    end
  elseif 名称=="镇魂诀"  then
    回合=qz(等级/30)+1
    攻击方.法术状态[名称].必杀=qz(等级/10)*2+1
    攻击方.必杀=攻击方.必杀+攻击方.法术状态[名称].必杀
    if 攻击编号~=nil and self:取奇经八脉是否有(攻击编号,"斩魔") then
        攻击方.必杀=qz(攻击方.必杀*1.12)
    end
    if 攻击编号~=nil and self:取奇经八脉是否有(攻击编号,"战诀") and 攻击方.战诀==nil then
        攻击方.必杀=qz(攻击方.必杀*1.1)
        攻击方.战诀=true
    end
  elseif 名称=="炎护"  then
    回合=qz(等级/50)+1
  elseif 名称=="蜜润"  then
    回合=qz(等级/40)+1
    灵力=qz(等级*1.5)
    if 攻击编号~=nil and self:取奇经八脉是否有(攻击编号,"滋养") then
        self:增加魔法(攻击编号,灵力)
    end
    类型=2
  elseif 名称=="谜毒之缚" then
    回合=qz(等级/40)+1
    攻击方.法术状态[名称].等级=等级
  elseif 名称=="诡蝠之刑" then
    回合=qz(等级/40)+1
    攻击方.法术状态[名称].等级=等级
    攻击方.法术状态[名称].编号=攻击编号
  elseif 名称=="唤灵·魂火" then
    local 次数=qz(self:取技能等级(攻击编号,"唤灵·魂火")/125)+2
    if 攻击编号~=nil and self:取奇经八脉是否有(攻击编号,"异兆") and 取随机数()>=50 then
      次数=次数+1
    end
    self:执行怪物召唤(攻击编号,2,攻击方.队伍,次数)
    回合=0
  elseif 名称=="唤魔·堕羽" then
    self:执行怪物召唤(攻击编号,3,攻击方.队伍,1)
    回合=0
  elseif 名称=="唤魔·毒魅" then
    self:执行怪物召唤(攻击编号,3,攻击方.队伍,1)
    回合=0
  elseif 名称=="唤灵·焚魂" then
    self:执行怪物召唤(攻击编号,2,攻击方.队伍,6)
    回合=0
  elseif 名称=="锋芒毕露" then
    回合=qz(等级/40)+1
    攻击方.法术状态[名称].目标id=攻击编号
    if 攻击编号~=nil and self:取奇经八脉是否有(攻击编号,"断矶") then
      攻击方.伤害=qz(攻击方.伤害*0.8)
      攻击方.灵力=qz(攻击方.灵力*0.8)
    end
  elseif 名称=="诱袭" then
    攻击方.法术状态[名称].目标id=攻击编号
    if 攻击编号~=nil and self:取奇经八脉是否有(攻击编号,"巧偃") then
      攻击方.防御=qz(攻击方.防御*0.9)
      攻击方.灵力=qz(攻击方.灵力*0.9)
    end
  elseif 名称=="匠心·削铁" then
    回合=1
    伤害=等级*2
    类型=2
    if 攻击编号~=nil and self:取奇经八脉是否有(攻击编号,"催锋") then
      伤害=伤害+等级
    end
  elseif 名称=="匠心·固甲" then
    回合=1
    防御=等级
    类型=2
    if 攻击编号~=nil and self:取奇经八脉是否有(攻击编号,"催锋") then
      伤害=伤害+等级
    end
  elseif 名称=="威震凌霄" then
    攻击方.物理暴击等级=攻击方.物理暴击等级-15
    攻击方.法术暴击等级=攻击方.法术暴击等级-15
    if 攻击方.物理暴击等级<=0 then
      攻击方.物理暴击等级=0
    end
    if 攻击方.法术暴击等级<=0 then
      攻击方.法术暴击等级=0
    end
  elseif 名称=="气慑天军" then
    if 攻击方.抗物理暴击等级==nil then
      攻击方.抗物理暴击等级=0
    end
    if 攻击方.抗法术暴击等级==nil then
      攻击方.抗法术暴击等级=0
    end
    攻击方.抗物理暴击等级=攻击方.抗物理暴击等级+30
    攻击方.抗法术暴击等级=攻击方.抗法术暴击等级+30
  elseif 名称=="铜头铁臂" then
    回合=qz(等级/30)+1
    伤害=等级*1.5
    类型=2
  elseif 名称=="无所遁形" then
    回合=qz(等级/30)+1
    攻击方.必杀=qz(攻击方.必杀*1.2)
    挨打方.防御=qz(挨打方.防御*0.8)
    类型=2
  elseif 名称=="呼子唤孙" then
    self:执行怪物召唤(攻击编号,4,攻击方.队伍,1)
    if 攻击方.呼子唤孙==nil then
      攻击方.呼子唤孙=0
    end
    攻击方.呼子唤孙=攻击方.呼子唤孙+1
    回合=0
  end
  攻击方.法术状态[名称].伤害=伤害
  攻击方.法术状态[名称].防御=防御
  攻击方.法术状态[名称].速度=速度
  攻击方.法术状态[名称].法防=法防
  攻击方.法术状态[名称].躲闪=躲闪
  攻击方.法术状态[名称].回合=回合
  if 攻击编号~=nil and self:取奇经八脉是否有(攻击编号,"嫣然") and (名称=="似玉生香" or 名称=="一笑倾城") and 取随机数() <= 60 then
      攻击方.法术状态[名称].回合=回合 + 1
  end
  攻击方.法术状态[名称].命中=命中
  攻击方.法术状态[名称].类型=类型
  攻击方.法术状态[名称].灵力=灵力
  if 类型==1 then
    攻击方.伤害=攻击方.伤害-伤害
    攻击方.防御=攻击方.防御-防御
    攻击方.速度=攻击方.速度-速度
    攻击方.法防=攻击方.法防-法防
    攻击方.躲闪=攻击方.躲闪-躲闪
    攻击方.命中=攻击方.命中-命中
    攻击方.灵力=攻击方.灵力-灵力
  else
    攻击方.伤害=攻击方.伤害+伤害
    攻击方.防御=攻击方.防御+防御
    攻击方.速度=攻击方.速度+速度
    攻击方.法防=攻击方.法防+法防
    攻击方.躲闪=攻击方.躲闪+躲闪
    攻击方.命中=攻击方.命中+命中
    攻击方.灵力=攻击方.灵力+灵力
  end
end

function 战斗处理类:取消状态(名称,攻击方)
  if 攻击方.法术状态[名称]==nil then
     return
  end
  if 攻击方.法术状态[名称].类型==2 then

      攻击方.伤害=攻击方.伤害-攻击方.法术状态[名称].伤害
      攻击方.防御=攻击方.防御-攻击方.法术状态[名称].防御
      攻击方.速度=攻击方.速度-攻击方.法术状态[名称].速度
      攻击方.法防=攻击方.法防-攻击方.法术状态[名称].法防
      攻击方.躲闪=攻击方.躲闪-攻击方.法术状态[名称].躲闪
      攻击方.命中=攻击方.命中-攻击方.法术状态[名称].命中
      攻击方.灵力=攻击方.灵力-攻击方.法术状态[名称].灵力

    else
      攻击方.伤害=攻击方.伤害+攻击方.法术状态[名称].伤害
      攻击方.防御=攻击方.防御+攻击方.法术状态[名称].防御
      攻击方.速度=攻击方.速度+攻击方.法术状态[名称].速度
      攻击方.法防=攻击方.法防+攻击方.法术状态[名称].法防
      攻击方.躲闪=攻击方.躲闪+攻击方.法术状态[名称].躲闪
      攻击方.命中=攻击方.命中+攻击方.法术状态[名称].命中
      攻击方.灵力=攻击方.灵力+攻击方.法术状态[名称].灵力
   end
  if 攻击方.法术状态[名称].附加伤害~=nil then
     攻击方.伤害=攻击方.伤害-攻击方.法术状态[名称].附加伤害
  elseif 攻击方.法术状态[名称].必杀~=nil then
     攻击方.必杀=攻击方.必杀-攻击方.法术状态[名称].必杀
  elseif 攻击方.法术状态[名称].法暴~=nil then
      攻击方.法暴=攻击方.法暴-攻击方.法术状态[名称].法暴
  end
 攻击方.法术状态[名称]=nil
end

function 战斗处理类:物攻技能计算1(编号,目标,起始伤害,叠加伤害,返回,允许保护,次数,技能名称)
 self.战斗流程[#self.战斗流程+1]={流程=1,攻击方=编号,挨打方={[1]={挨打方=目标,特效={}}}}
 if 装备特技[技能名称]~=nil then
      self.战斗流程[#self.战斗流程].特技名称=技能名称
   end
 if 返回 then
    self.执行等待=self.执行等待+10
  else
    self.执行等待=self.执行等待+5
   end
  local  保护=false
  local  保护编号=0
  for n=1,#self.参战单位 do
    if 技能名称~="长驱直入" and 保护编号==0 and self:取行动状态(n) and self.参战单位[目标].法术状态.惊魂掌==nil and self.参战单位[n].指令.类型=="保护" and  self.参战单位[n].队伍==self.参战单位[目标].队伍 and  self.参战单位[n].指令.目标==目标 then
      保护编号=n
      保护=true
      self.参战单位[n].指令.类型=""
      self.执行等待=self.执行等待+5
    end
  end
  local  必杀=false
  local  躲避=false
  local  防御=false
  local  反震=false
  local  反击=false
  local  伤害=self:取基础物理伤害(编号,目标)*(起始伤害+叠加伤害*次数)
  if 技能名称=="浪涌" or 技能名称=="惊涛怒" or 技能名称=="翻江搅海" or 技能名称=="天崩地裂" or 技能名称=="断岳势" then
      伤害=伤害+qz(self.参战单位[目标].防御*0.2)
      if 技能名称=="翻江搅海" or 技能名称=="天崩地裂" then
        if 编号~=nil and self:取奇经八脉是否有(编号,"神诀") then
          if self.参战单位[编号].神诀==nil or self.参战单位[编号].神诀>100 then
            if self.参战单位[编号].神诀==nil then
                self.参战单位[编号].神诀=0
            end
            if 取随机数()<=50 then
              if self.参战单位[编号].法术状态.碎星诀~=nil then
                  self.参战单位[编号].法术状态.碎星诀.回合=qz(self.参战单位[编号].等级/30)+1
              end
            else
              if self.参战单位[编号].法术状态.镇魂诀~=nil then
                  self.参战单位[编号].法术状态.镇魂诀.回合=qz(self.参战单位[编号].等级/30)+1
              end
            end
            伤害=qz(伤害*1.25)
            self.参战单位[编号].神诀=self.参战单位[编号].神诀+25
          end
        end
      end
  end
  if 技能名称=="天雷阵" then
    if self:取指定法宝(编号,"伏魔天书",1) then
     伤害=伤害+self:取指定法宝境界(编号,"伏魔天书")*取随机数(20,30)
      end
    end
    local  最终伤害=self:取最终物理伤害(编号,目标,伤害)
    if (技能名称 == "高级连击" or 技能名称 == "理直气壮") and 最终伤害.暴击~=nil and self.参战单位[编号].怒击效果 then
      self.参战单位[编号].怒击触发 = 1
    elseif (技能名称 == "高级连击" or 技能名称 == "理直气壮") and not 最终伤害.暴击~=nil and self.参战单位[编号].怒击触发 ~= nil then
      self.参战单位[编号].怒击触发 = nil
    end
   if 保护 then
     local 保护伤害=math.floor(伤害*0.5)
     if 保护伤害<1 then 保护伤害=1 end
     local 保护死亡=self:减少气血(保护编号,保护伤害)
      伤害=math.floor(伤害*0.3)
     if 保护伤害<1 then 保护伤害=1 end
      self.战斗流程[#self.战斗流程].保护数据={编号=保护编号,伤害=保护伤害,死亡=保护死亡}
      end
  local 伤害值=self:取伤害结果(编号,目标,最终伤害.伤害,最终伤害.暴击,保护)
  if 服务器名称 == "测试专区" then
      伤害值.伤害=qz(伤害值.伤害*0.65)
  elseif 服务器名称 == "零氪2020仿官" then
      伤害值.伤害=qz(伤害值.伤害*1.35)
  else
      伤害值.伤害=qz(伤害值.伤害*0.65)
  end
  if self.参战单位[编号].法术状态.谜毒之缚~=nil then
    伤害值.伤害=qz(伤害值.伤害*0.65*0.8)
  end
  if 伤害值.伤害<1 then 伤害值.伤害=1 end
  if 技能名称=="善恶有报"  then
    if 取随机数()>=60 then
        伤害值.类型=2
    elseif 伤害值.类型~=2 then
       伤害值.伤害=qz(伤害值.伤害*1.5)
    end
  end
  -- if 编号~=nil and self:取奇经八脉是否有(编号,"不舍") and 伤害值.伤害>qz(self.参战单位[编号].最大气血*0.2) then
  --     self:恢复技能计算(编号,"归元咒",self.参战单位[编号].等级)
  -- end
  if 伤害值.类型==2 then --恢复状态
     self:增加气血(目标,伤害值.伤害)
    else
      self.战斗流程[#self.战斗流程].挨打方[1].死亡=self:减少气血(目标,伤害值.伤害,编号)
       if self.参战单位[目标].法术状态.催眠符 then
         self:取消状态("催眠符",self.参战单位[目标])
         self.战斗流程[#self.战斗流程].挨打方[1].取消状态="催眠符"
         end
      if 技能名称=="惊心一剑" then
          self.参战单位[目标].魔法=self.参战单位[目标].魔法-qz(伤害值.伤害*0.2)
          if self.参战单位[目标].魔法<=0 then
             self.参战单位[目标].魔法=0
             end
       elseif 技能名称=="破碎无双" then
          self.参战单位[目标].魔法=self.参战单位[目标].魔法-qz(伤害值.伤害)
          if self.参战单位[目标].魔法<=0 then
             self.参战单位[目标].魔法=0
             end
         end
     end
  self.战斗流程[#self.战斗流程].挨打方[1].动作=最终伤害.动作
  self.战斗流程[#self.战斗流程].挨打方[1].特效=最终伤害.特效
  self.战斗流程[#self.战斗流程].伤害=最终伤害.攻击伤害
  if #最终伤害.特效==0 then
    --self.战斗流程[#self.战斗流程].挨打方[1].特效={"被击中"}
  end
  if 技能名称~="后发制人" then
    self.战斗流程[#self.战斗流程].挨打方[1].特效[#self.战斗流程[#self.战斗流程].挨打方[1].特效+1]=技能名称
  end
  local 吸血=self.参战单位[编号].吸血
  if 吸血==nil and self.参战单位[编号].法术状态.移魂化骨~=nil then
     吸血=self.参战单位[编号].法术状态.移魂化骨.等级/250
  end
  if 吸血~=nil and self.参战单位[目标].鬼魂==nil  then
    local 吸血伤害=math.floor(伤害值.伤害*吸血)
    if 吸血伤害<=0 then
      吸血伤害=1
    end
    self:增加气血(编号,吸血伤害)
    self.战斗流程[#self.战斗流程].吸血伤害=吸血伤害
  end
  local 反震=self.参战单位[编号].反震
  local 反击=self:取是否反击(编号,目标)
  --local 反击=1
  --local 反震=0.25
  if self.参战单位[编号].偷袭==nil and 反震~=nil and 取随机数()<=30 and 保护==false then --触发反震 有保护的情况下不会触发反震、反击
    local 反震伤害=math.floor(伤害值.伤害*反震)
    if 反震伤害<=0 then
      反震伤害=1
    end
    self.战斗流程[#self.战斗流程].反震伤害=反震伤害
    self.战斗流程[#self.战斗流程].反震死亡=self:减少气血(编号,反震伤害,目标)
    self.战斗流程[#self.战斗流程].挨打方[1].特效[#self.战斗流程[#self.战斗流程].挨打方[1].特效+1]="反震"
    self.执行等待=self.执行等待+3
  elseif 反击~=nil and 反击~=false and self:取行动状态(目标) and self.参战单位[编号].偷袭==nil and  保护==false then
    local 反击伤害=math.floor(self:取基础物理伤害(目标,编号)*反击)
    if 反击伤害<1 then 反击伤害=1 end
    self.战斗流程[#self.战斗流程].反击伤害=反击伤害
    self.战斗流程[#self.战斗流程].反击死亡=self:减少气血(编号,反击伤害,目标)
  end
  if self.参战单位[编号].气血>0 and self.参战单位[目标].法术状态.混元伞~=nil then
    local 反弹伤害=qz(伤害值.伤害*(self.参战单位[目标].法术状态.混元伞.境界*0.03+0.1))
    if self.战斗流程[#self.战斗流程].反震伤害==nil then
      self.战斗流程[#self.战斗流程].反震伤害=反弹伤害
    else
      self.战斗流程[#self.战斗流程].反震伤害=self.战斗流程[#self.战斗流程].反震伤害+反弹伤害
    end
      self.战斗流程[#self.战斗流程].反震死亡=self:减少气血(编号,反弹伤害,目标)
  end
  self.战斗流程[#self.战斗流程].挨打方[1].伤害=伤害值.伤害
  self.战斗流程[#self.战斗流程].挨打方[1].伤害类型=伤害值.类型
  self.战斗流程[#self.战斗流程].返回=返回
  if self.参战单位[编号].法术状态.诡蝠之刑~=nil then
    if self:取目标状态(编号,编号,2) then
      local 气血=qz(伤害值.伤害*0.1)
      if 气血<=1 then
        气血=1
      end
      self.战斗流程[#self.战斗流程+1]={流程=102,攻击方=编号,气血=0,挨打方={}}
      self.战斗流程[#self.战斗流程].死亡=self:减少气血(编号,气血)
      self.战斗流程[#self.战斗流程].气血=气血
    end
  end
end

function 战斗处理类:魔法消耗(攻击方,数值,数量)
 local 临时消耗=math.floor(数值*数量)
 --self.临时消耗=math.floor(数值*数量*攻击方.慧根)
 --print(攻击方.属性.魔法,self.临时消耗)
  if 攻击方.慧根~=nil then
      临时消耗=qz(临时消耗*攻击方.慧根)
     end
  if 攻击方.飞檐走壁 ~= nil then
    临时消耗 = qz(临时消耗-临时消耗*攻击方.飞檐走壁)
  end
 if 攻击方.魔法<临时消耗 then
   return false
  else
    攻击方.魔法=攻击方.魔法-临时消耗
    return true
   end
end

function 战斗处理类:愤怒消耗(数值,攻击方,编号,名称)
  local 消耗=数值
  if 攻击方.愤怒腰带~=nil then
    消耗=qz(消耗*0.8)
  end
  if 编号~=nil and self:取奇经八脉是否有(编号,"慈心") and 名称=="慈航普渡" then
    消耗=消耗-40
  end
  if 编号~=nil and self:取奇经八脉是否有(编号,"傲娇") then
    消耗=消耗-5
    if 名称=="笑里藏刀" then
        消耗=消耗-6
    end
  end
  if 编号~=nil and self:取奇经八脉是否有(编号,"显圣") then
    if 名称=="晶清诀" or 名称=="罗汉金钟" then
        消耗=消耗-8
    end
  end
  if 编号~=nil and self:取奇经八脉是否有(编号,"慈心") and (名称=="水清诀" or 名称=="冰清诀" or 名称=="晶清诀" or 名称=="玉清诀") then
    消耗=消耗-8
  end
  if 攻击方.愤怒<消耗 then
    if 编号~=nil and self:取奇经八脉是否有(编号,"修心") then
      if 名称~="慈航普渡" and 攻击方.魔法<消耗*20 then
          return false
      else
          攻击方.魔法=攻击方.魔法-消耗*20
          if 攻击方.魔法<=0 then
              攻击方.魔法=0
          end
          if 编号~=nil and self:取奇经八脉是否有(编号,"鬼火") then
              攻击方.愤怒=攻击方.愤怒+10
              if 攻击方.愤怒 > 150 then
                攻击方.愤怒 = 150
              end
          end
          return true
      end
    else
        return false
    end
  else
     攻击方.愤怒=攻击方.愤怒-消耗
     if 编号~=nil and self:取奇经八脉是否有(编号,"鬼火") then
        攻击方.愤怒=攻击方.愤怒+10
        if 攻击方.愤怒 > 150 then
          攻击方.愤怒 = 150
        end
     end
     return true
  end

  if 消耗>=60 and self:取奇经八脉是否有(编号,"聚气") and 取随机数() <= 20 then
      self:添加状态("不动如山",攻击方,攻击方,攻击方.等级,编号)
  end
end

function 战斗处理类:技能消耗(攻击方,数量,名称,编号)
  if 装备特技[名称]~=nil then
    return self:愤怒消耗(装备特技[名称].消耗,攻击方,编号,名称)
  end
  if 数量==nil then 数量=1 end
  self.技能名称=名称
  if self.技能名称=="自爆" then
    return true
  end
  local 烟雨气血消耗 = qz(攻击方.最大气血*0.7)
  if 编号~=nil and self:取奇经八脉是否有(编号,"雨杀") then
    烟雨气血消耗 = qz(攻击方.最大气血*0.7*0.5)
  end
  if self.技能名称=="唤魔·堕羽" then
    local 怨灵存在=0
    local 怨灵id=0
    local 幻魔存在=0
    for n=1,#self.参战单位 do
      if self.参战单位[n].名称=="怨灵" then
        怨灵存在=怨灵存在+1
        if 怨灵id<2 then
          self.参战单位[n].气血=0
        end
        怨灵id=怨灵id+1
      end
      if self.参战单位[n].名称=="幻魔" then
        幻魔存在=幻魔存在+1
      end
    end
    if 怨灵存在>=2 and 幻魔存在<=1 then
      return self:魔法消耗(攻击方,50,1)
    end
  elseif self.技能名称=="唤魔·毒魅" then
    local bb存在=0
    local bbid=0
    for n=1,#self.参战单位 do
      if self.参战单位[n].类型=="bb" then
        bb存在=bb存在+1
        if bbid<1 then
          self.参战单位[n].气血=0
        end
        bbid=bbid+1
      end
    end
    if bb存在>=1 then
      return self:魔法消耗(攻击方,100,1)
    end
  elseif self.技能名称=="唤灵·焚魂" then
    local bb存在=0
    local bbid=0
    for n=1,#self.参战单位 do
      if self.参战单位[n].类型=="bb" then
        bb存在=bb存在+1
        if bbid<1 then
          self.参战单位[n].气血=0
        end
        bbid=bbid+1
      end
    end
    if bb存在>=1 then
      return self:魔法消耗(攻击方,100,1)
    end
  elseif self.技能名称=="净世煌火" then
    local 怨灵存在=0
    local 怨灵id=0
    for n=1,#self.参战单位 do
      if self.参战单位[n].名称=="怨灵" then
        怨灵存在=怨灵存在+1
        if 怨灵id<1 then
          self.参战单位[n].气血=0
        end
        怨灵id=怨灵id+1
      end
    end
    if 怨灵存在>=1 then
      return self:魔法消耗(攻击方,50,1)
    end
  elseif self.技能名称=="焚魔烈焰" then
    local 怨灵存在=0
    local 怨灵id=0
    for n=1,#self.参战单位 do
      if self.参战单位[n].名称=="怨灵" then
        怨灵存在=怨灵存在+1
        if 怨灵id<1 then
          self.参战单位[n].气血=0
        end
        怨灵id=怨灵id+1
      end
    end
    if 怨灵存在>=1 then
      return self:魔法消耗(攻击方,50,3)
    end
  elseif self.技能名称=="呼子唤孙" then
    if 攻击方.呼子唤孙==nil then
      攻击方.呼子唤孙=0
    end
    if 攻击方.呼子唤孙<5 then
      return self:魔法消耗(攻击方,100,1)
    end
  end
  -- if 攻击方.队伍==0 and 名称~="横扫千军" then return true end
  if self.技能名称=="横扫千军" and 攻击方.气血>=攻击方.最大气血*0.5 then
    return true
  elseif self.技能名称=="破釜沉舟" and 攻击方.气血>=攻击方.最大气血*0.5 then
    return true
  elseif self.技能名称=="誓血之祭" and 攻击方.气血>=攻击方.最大气血*0.5 then
    return true
  elseif self.技能名称=="剑荡四方" and 攻击方.气血>=1 then
    return true
  elseif self.技能名称=="移魂化骨" and 攻击方.气血>=攻击方.最大气血*0.3 then
    return true
  elseif self.技能名称=="血雨" and 攻击方.气血>=攻击方.最大气血*0.3 then
    return true
  elseif self.技能名称=="碎玉弄影" or  self.技能名称=="落花成泥" or  self.技能名称=="妖风四起" then
    return self:愤怒消耗(40,攻击方,编号,self.技能名称)
  elseif self.技能名称=="飞符炼魂" or self.技能名称=="顺势而为" or self.技能名称=="魑魅缠身" or self.技能名称=="风雷韵动" or self.技能名称=="画地为牢" then
    return self:愤怒消耗(60,攻击方,编号,self.技能名称)
  elseif self.技能名称=="偷龙转凤" then
    return self:愤怒消耗(80,攻击方,编号,self.技能名称)
  elseif self.技能名称=="烟雨剑法" and 攻击方.气血>=烟雨气血消耗 then
    return self:魔法消耗(攻击方,50,1)
  elseif self.技能名称=="妙手空空" then
   return self:魔法消耗(攻击方,4,数量)
  elseif self.技能名称=="长驱直入" or self.技能名称=="黄帝内经" or self.技能名称=="翩鸿一击" or self.技能名称=="妙悟" or self.技能名称=="烈焰真诀" or self.技能名称=="蚩尤之搏" then
    return self:魔法消耗(攻击方,50,1)
  elseif self.技能名称=="后发制人" then
  -- 攻击方.气血=math.floor(攻击方.气血*0.95)
    return true
  elseif self.技能名称=="高级连击" or self.技能名称=="理直气壮" then
    return true
  elseif self.技能名称=="杀气诀" or self.技能名称=="推拿" or self.技能名称=="落魄符" then
    return self:魔法消耗(攻击方,40,1)
  elseif self.技能名称=="活血" then
    return self:魔法消耗(攻击方,70,1)
  elseif self.技能名称=="莲心剑意" or self.技能名称=="夺魄令" or self.技能名称=="瘴气" or self.技能名称=="魔息术" or self.技能名称=="安神诀" or self.技能名称=="反间之计" or self.技能名称=="定身符" or self.技能名称=="龙吟" or self.技能名称=="连环击" then
    return self:魔法消耗(攻击方,30,1)
  elseif self.技能名称=="推气过宫" then
    return self:魔法消耗(攻击方,45,数量)
  elseif self.技能名称=="峰回路转" then
    return true
  elseif self.技能名称=="雨落寒沙" then
    return self:魔法消耗(攻击方,10,数量)
  elseif self.技能名称=="牛刀小试" then
    return self:魔法消耗(攻击方,20,数量)
  elseif self.技能名称=="夺命蛛丝" then
    return self:魔法消耗(攻击方,150,数量)
  elseif self.技能名称=="月光" then
    return self:魔法消耗(攻击方,100,数量)
  elseif self.技能名称=="鸿渐于陆" then
    return self:魔法消耗(攻击方,100,数量)
  elseif self.技能名称=="天魔解体" then
    if 攻击方.魔法<攻击方.最大魔法*0.8 then
      return false
    else
       return self:魔法消耗(攻击方,math.floor(攻击方.最大魔法*0.8),数量)
    end
  elseif self.技能名称=="夺命咒" or self.技能名称=="苍茫树" or self.技能名称=="地裂火" or self.技能名称=="日光华" or self.技能名称=="靛沧海" or self.技能名称=="巨岩破" then
    return self:魔法消耗(攻击方,20,数量)
  elseif self.技能名称=="金刚护法" then
    return self:魔法消耗(攻击方,40,数量)
  elseif self.技能名称=="炼气化神" and 攻击方.气血>=30 then
    攻击方.气血=攻击方.气血-30
    return true
  elseif self.技能名称=="明光宝烛" or self.技能名称=="气慑天军" or self.技能名称=="匠心·削铁" or self.技能名称=="匠心·固甲" or self.技能名称=="威震凌霄" then
    return self:魔法消耗(攻击方,100,1)
  elseif   self.技能名称=="天崩地裂" or  self.技能名称=="断岳势" or self.技能名称=="裂石" or  self.技能名称=="地涌金莲" then
    return self:魔法消耗(攻击方,50,1)
  elseif self.技能名称=="翻江搅海" or self.技能名称=="惊涛怒" or self.技能名称=="浪涌" then
    return self:魔法消耗(攻击方,20,数量)
  elseif self.技能名称=="生命之泉" then
    return self:魔法消耗(攻击方,15,数量)
  elseif self.技能名称=="蜜润" then
    return self:魔法消耗(攻击方,15,数量)
  elseif self.技能名称=="二龙戏珠" then
    return self:魔法消耗(攻击方,70,数量)
  elseif self.技能名称=="摧心术" or self.技能名称=="神龙摆尾" then
    return self:魔法消耗(攻击方,100,数量)
  elseif self.技能名称=="还魂咒" or self.技能名称=="仙人指路" or self.技能名称=="潜能激发" or self.技能名称=="四面埋伏" then
    return self:魔法消耗(攻击方,150,数量)
  elseif self.技能名称=="一笑倾城" or self.技能名称=="分身术" or self.技能名称=="颠倒五行"  then
    return self:魔法消耗(攻击方,80,数量)
  elseif self.技能名称=="一苇渡江" or self.技能名称=="匠心·破击" or self.技能名称=="达摩护体" or self.技能名称=="灵动九天" or self.技能名称=="飞花摘叶" or self.技能名称=="韦陀护法" or self.技能名称=="唤灵·魂火" or self.技能名称=="金刚护体" or self.技能名称=="唧唧歪歪" or self.技能名称=="天雷斩" or self.技能名称=="八凶法阵" or self.技能名称=="鹰击" or self.技能名称=="连环击" or self.技能名称=="泰山压顶" or self.技能名称=="奔雷咒" or self.技能名称=="地狱烈火" or self.技能名称=="水漫金山" then
    return self:魔法消耗(攻击方,30,数量)
  elseif self.技能名称=="娉婷嬝娜" or self.技能名称=="似玉生香" or self.技能名称=="乘风破浪" or self.技能名称=="五雷轰顶" or self.技能名称=="判官令" then
    return self:魔法消耗(攻击方,40,数量)
  elseif self.技能名称=="如花解语" or self.技能名称=="雷霆万钧" then
    return self:魔法消耗(攻击方,35,数量)
  elseif self.技能名称=="惊魂掌" or self.技能名称=="锋芒毕露" or self.技能名称=="煞气诀" or self.技能名称=="失忆符" or self.技能名称=="摇头摆尾" or self.技能名称=="天地同寿" or self.技能名称=="乾坤妙法" or self.技能名称=="金刚镯" or self.技能名称=="碎甲符" or self.技能名称=="我佛慈悲" or self.技能名称=="阎罗令" or self.技能名称=="杨柳甘露" or self.技能名称=="水攻" or self.技能名称=="落岩" or self.技能名称=="烈火" or self.技能名称=="雷击" then
    return self:魔法消耗(攻击方,50,数量)
  elseif self.技能名称=="炎护" or self.技能名称=="冰川怒" or self.技能名称=="尘土刃" or self.技能名称=="荆棘舞" or self.技能名称=="落叶萧萧" or self.技能名称=="莲步轻舞" or self.技能名称=="变身" then
    return self:魔法消耗(攻击方,30,数量)
  elseif self.技能名称=="满天花雨" or self.技能名称=="镇妖"  then
    return self:魔法消耗(攻击方,45,数量)
  elseif self.技能名称=="炎护" or self.技能名称=="楚楚可怜" or self.技能名称=="百毒不侵" or self.技能名称=="普渡众生" or self.技能名称=="天罗地网" then
    return self:魔法消耗(攻击方,30,数量)
  elseif self.技能名称=="星月之惠" or self.技能名称=="誓血之祭" or self.技能名称=="雾杀" or self.技能名称=="黄泉之息" or self.技能名称=="勾魂" or  self.技能名称=="摄魄" or self.技能名称=="尸腐毒" or self.技能名称=="五雷咒" or self.技能名称=="龙腾" or self.技能名称=="百万神兵" or self.技能名称=="狮搏" or self.技能名称=="含情脉脉" then
    return self:魔法消耗(攻击方,50,数量)
  elseif self.技能名称=="谜毒之缚" or self.技能名称=="诡蝠之刑" or self.技能名称=="怨怖之泣" then
    return self:魔法消耗(攻击方,30,10*数量)
  elseif self.技能名称=="火甲术" or self.技能名称=="失心符" or self.技能名称=="失魂符" or self.技能名称=="错乱" or self.技能名称=="三昧真火"  then
    if self.技能名称=="三昧真火" then
       --if 攻击方.命令数据.参数.摇头摆尾~=nil then
        -- 攻击方.命令数据.参数.摇头摆尾=nil
        -- return self:魔法消耗(攻击方,50,1)
        --else
      return self:魔法消耗(攻击方,60,数量)
      --end
    end
    return self:魔法消耗(攻击方,60,数量)
  elseif self.技能名称=="碎星诀" or self.技能名称=="天神护法" or self.技能名称=="宁心" or self.技能名称=="落雷符" or self.技能名称=="定身符" or self.技能名称=="紧箍咒" then
    return self:魔法消耗(攻击方,30,数量)
  elseif   self.技能名称=="金身舍利" or  self.技能名称=="明光宝烛" or  self.技能名称=="善恶有报" or  self.技能名称=="死亡召唤" or  self.技能名称=="夜舞倾城" or    self.技能名称=="惊心一剑" or  self.技能名称=="壁垒击破"  then
    return self:魔法消耗(攻击方,100,数量)
  elseif self.技能名称=="催眠符" or self.技能名称=="镇妖" or self.技能名称=="九天玄火" then
    return self:魔法消耗(攻击方,45,数量)
  elseif self.技能名称=="大闹天宫" or self.技能名称=="天神护体" or self.技能名称=="离魂符" or self.技能名称=="失忆符" or self.技能名称=="日月乾坤" or self.技能名称=="定心术" then
    return self:魔法消耗(攻击方,50,数量)
  elseif self.技能名称=="蜜润" or self.技能名称=="龙卷雨击" then
    return self:魔法消耗(攻击方,25,数量)
  elseif self.技能名称=="飞砂走石" then
   -- if 攻击方.命令数据.参数.摇头摆尾~=nil then
     --攻击方.命令数据.参数.摇头摆尾=nil
    -- return self:魔法消耗(攻击方,50,1)
    --else
    return self:魔法消耗(攻击方,30,数量)
      --end
  elseif self.技能名称=="不动如山" or  self.技能名称=="还阳术" or self.技能名称=="我佛慈悲" or self.技能名称=="舍身取义" or self.技能名称=="佛法无边" then
    return self:魔法消耗(攻击方,150,数量)
  elseif self.技能名称=="杨柳甘露" then
    return self:魔法消耗(攻击方,150,数量)
  elseif self.技能名称=="乾天罡气" then
    if 攻击方.气血>20 then return true else return false end
  elseif self.技能名称=="力劈华山" then
    return self:魔法消耗(攻击方,150,数量)
  elseif self.技能名称=="归元咒" then
    return self:魔法消耗(攻击方,20,数量)
  elseif self.技能名称=="寡欲令" or self.技能名称=="针锋相对" or self.技能名称=="幻境术" or self.技能名称=="煞气诀" or self.技能名称=="惊魂掌" or self.技能名称=="追魂符" or self.技能名称=="裂石" or self.技能名称=="断岳势"  or self.技能名称=="天崩地裂"  then
    return self:魔法消耗(攻击方,50,数量)
  elseif self.技能名称=="解毒" then
    return self:魔法消耗(攻击方,40,数量)
  elseif self.技能名称=="解封" or self.技能名称=="无穷妙道" then
    return self:魔法消耗(攻击方,60,数量)
  elseif self.技能名称=="碎星诀" or self.技能名称=="清心" or self.技能名称=="炽火流离" then
    return self:魔法消耗(攻击方,30,数量)
  elseif self.技能名称=="镇魂诀" then
    return true
  elseif self.技能名称=="飘渺式" then
    return self:魔法消耗(攻击方,30,数量)
  elseif self.技能名称=="驱魔" then
    return self:魔法消耗(攻击方,45,数量)
  elseif self.技能名称=="浪涌" or self.技能名称=="惊涛怒" or self.技能名称=="翻江搅海" then
    return self:魔法消耗(攻击方,20,数量)
  elseif self.技能名称=="驱尸" then
    return self:魔法消耗(攻击方,40,数量)
  elseif self.技能名称=="不动如山" or self.技能名称=="修罗隐身" then
    return self:魔法消耗(攻击方,150,数量)
  elseif self.技能名称=="幽冥鬼眼" then
    return self:魔法消耗(攻击方,20,数量)
  elseif self.技能名称=="牛劲" then
    return self:魔法消耗(攻击方,20,数量)
  elseif self.技能名称=="魔王回首" then
    return self:魔法消耗(攻击方,30,数量)
  elseif self.技能名称=="极度疯狂" then
    return self:魔法消耗(攻击方,30,数量)
  elseif self.技能名称=="威慑" then
    return self:魔法消耗(攻击方,20,数量)
  elseif self.技能名称=="定心术" then
    return self:魔法消耗(攻击方,40,数量)
  elseif self.技能名称=="象形" or self.技能名称=="反间之计" or self.技能名称=="夺魄令" then
    return self:魔法消耗(攻击方,30,数量)
  elseif self.技能名称=="魔音摄魂" then
    return self:魔法消耗(攻击方,40,数量)
  elseif self.技能名称=="复苏" then
    return self:魔法消耗(攻击方,60,数量)
  elseif self.技能名称=="盘丝阵" then
    return self:魔法消耗(攻击方,40,数量)
  elseif self.技能名称=="凋零之歌" or self.技能名称=="真君显灵" or self.技能名称=="由己渡人"  then
    return self:魔法消耗(攻击方,100,数量)
  elseif self.技能名称=="百爪狂杀" then
    return self:魔法消耗(攻击方,35,数量)
  elseif self.技能名称=="五行制化" or self.技能名称=="诱袭" then
    return self:魔法消耗(攻击方,70,数量)
  elseif self.技能名称=="上古灵符" or self.技能名称=="上古灵符(怒雷)" or self.技能名称=="上古灵符(流沙)" or self.技能名称=="上古灵符(心火)"  then
    return self:魔法消耗(攻击方,100,数量)
  elseif self.技能名称=="观照万象" then
    return self:魔法消耗(攻击方,200,数量)
  elseif self.技能名称=="天降灵葫" or self.技能名称=="叱咤风云" or self.技能名称=="法术防御" then
    return self:魔法消耗(攻击方,100,数量)
  elseif self.技能名称=="风卷残云" then
    return self:魔法消耗(攻击方,150,数量)
  elseif self.技能名称=="雷浪穿云" or self.技能名称=="魔焰滔天" then
    return self:魔法消耗(攻击方,60,数量)
  elseif self.技能名称=="钟馗论道" then
    return self:魔法消耗(攻击方,80,数量)
  elseif self.技能名称=="匠心·蓄锐" then
    return self:魔法消耗(攻击方,80,1)
  elseif self.技能名称=="当头一棒" or self.技能名称=="神针撼海" or self.技能名称=="杀威铁棒" or self.技能名称=="泼天乱棒" or self.技能名称=="九幽除名" or self.技能名称=="云暗天昏" or self.技能名称=="铜头铁臂" or self.技能名称=="无所遁形" then
    return self:魔法消耗(攻击方,75,1)
  elseif self.技能名称=="九幽除名" or self.技能名称=="云暗天昏" or self.技能名称=="铜头铁臂" or self.技能名称=="无所遁形" then
    return self:魔法消耗(攻击方,75,1)
  else
    return false
  end
end

function 战斗处理类:取多个友方目标(编号,目标,数量,名称)
  if self.参战单位[目标] == nil or self.参战单位[目标].队伍 ~= self.参战单位[编号].队伍 then
    目标 = self:取单个友方目标(编号)
  end
  local 目标组={目标}
  if self:取目标状态(编号,目标,2)==false then
     目标组={}
  end
  if 名称 == "慈航普渡" or 名称 == "推气过宫" or 名称 == "地涌金莲" then
    目标组={}
  end
  if #目标组>=数量 then
     return 目标组
  end
  if 名称~="推气过宫" and 名称~="地涌金莲" and 名称 ~= "慈航普渡" then
    for n=1,#self.参战单位 do
      if  #目标组<数量 and self.参战单位[n].队伍==self.参战单位[编号].队伍 and self:取目标状态(编号,n,1) and self.参战单位[n].法术状态[名称]==nil   then
        local 添加=true
        for i=1,#目标组 do
          if 目标组[i]==n then
            添加=false
          end
        end
        if 添加 then
          目标组[#目标组+1]=n
        end
      end
    end
  elseif 名称 == "慈航普渡" then
    for n=1,#self.参战单位 do
      if  #目标组<数量 and n ~= 编号 and self.参战单位[n].类型=="角色" and self.参战单位[n].队伍==self.参战单位[编号].队伍 and not self:取目标状态(编号,n,1) then
        local 添加=true
        for i=1,#目标组 do
          if 目标组[i]==n then
            添加=false
          end
        end
        if 添加 then
          目标组[#目标组+1]=n
        end
      end
    end
  else
    for n=1,#self.参战单位 do
      if self.参战单位[n].队伍==self.参战单位[编号].队伍 and self:取目标状态(编号,n,1) and self.参战单位[n].法术状态[名称]==nil then
        local 添加=true
        for i=1,#目标组 do
          if 目标组[i]==n then 添加=false end
        end
        if 添加 then
          目标组[#目标组+1]=n
        end
      end
    end
    local 排序组={}
    for n=1,#目标组 do
      排序组[n]={气血=self.参战单位[目标组[n]].气血/self.参战单位[目标组[n]].最大气血*100,id=目标组[n]}
    end
    table.sort(排序组,function(a,b) return a.气血<b.气血 end )
    目标组={}
    for n=1,#排序组 do
      if #目标组<数量 then
        目标组[n]=排序组[n].id
      end
    end
    local 重复 = false
    for n=1,#目标组 do
      if 目标组[n] == 目标 then
        重复 = true
      end
    end
    if 重复 == false and  self.参战单位[目标] ~= nil and self.参战单位[目标].队伍==self.参战单位[编号].队伍 and self:取目标状态(编号,目标,1) and self.参战单位[目标].法术状态[名称]==nil then
      目标组[#目标组]=目标
    end
 end
 return 目标组
end

function 战斗处理类:取多个敌方目标(编号,目标,数量)
  local 目标组={目标}
  if self:取目标状态(编号,目标,1)==false then
     目标组={}
   elseif self.参战单位[目标].队伍==self.参战单位[编号].队伍 then
     目标组={}
     end
  if #目标组>=数量 then
     return 目标组
     end
  for n=1,#self.参战单位 do
     if  #目标组<数量 and self.参战单位[n].队伍~=self.参战单位[编号].队伍 and self:取目标状态(编号,n,1) then
          --目标组[#目标组+1]=n
           local 添加=true
           for i=1,#目标组 do
              if 目标组[i]==n then 添加=false end
              end
          if 添加 then
             目标组[#目标组+1]=n
             end
         end
     end
 return 目标组
end

function 战斗处理类:取玩家战斗()
    if self.战斗类型==200001 or self.战斗类型==200002 or self.战斗类型==200003 or self.战斗类型==200004 or self.战斗类型==200005 or self.战斗类型==200006 or self.战斗类型==200003 or self.战斗类型==200007 or self.战斗类型==200008 then
        return true
    else
        return false
    end
end

function 战斗处理类:取目标数量(攻击方,技能名称,等级,编号)
  if self.战斗开始==false or self.回合进程=="加载回合" then return 1 end --附加状态的人数
  self.临时等级=等级
  self.临时人数=1
  if 技能名称=="推气过宫" or 技能名称=="幽冥鬼眼"  then
    self.临时人数=math.floor(self.临时等级/30)+1
    if (攻击方.名称=="天罡星" or 攻击方.名称=="蜘蛛女王") and 攻击方.队伍==0 then
      self.临时人数=10
    end
  elseif 技能名称=="峰回路转" then
    self.临时人数=10
  elseif 技能名称=="鹰击" then
    self.临时人数=math.floor(self.临时等级/25)+2
    if self.临时人数>=6 then self.临时人数=6 end
  elseif 技能名称=="落雷符" then
    self.临时人数=math.floor(self.临时等级/30)+1
    if self.临时人数>3 then self.临时人数=3 end
    if self:取玩家战斗() then self.临时人数=1 end
  elseif 技能名称=="月光" then
    self.临时人数=取随机数(1,4)
  elseif 技能名称=="夺命咒" then
    self.临时人数=math.floor(self.临时等级/35)+1
    if self.临时人数>5 then self.临时人数=5 end
    if self:取玩家战斗() then self.临时人数=1 end
  elseif 技能名称=="普渡众生" then
    self.临时人数=1
    if self:取指定法宝(编号,"普渡",1) then
      if self:取指定法宝境界(编号,"普渡")>=取随机数(1,60) then
        self.临时人数=2
      end
    end
    if 编号~=nil and self:取奇经八脉是否有(编号,"道衍") then
        self.临时人数=self.临时人数+2
    end
  elseif 技能名称=="尸腐毒" then
   self.临时人数=1
    if self:取指定法宝(编号,"九幽",1) then
     if self:取指定法宝境界(编号,"九幽")>=取随机数(1,60) then
       self.临时人数=2
       end
      end
  elseif 技能名称=="天外飞剑" then
     self.临时人数=5
  elseif 技能名称=="浪涌" then
   self.临时人数=math.floor(self.临时等级/35)+1
    if self.临时人数>3 then self.临时人数=3 end
    if self:取玩家战斗() then self.临时人数=1 end
    if 攻击方.名称=="初出茅庐地煞星" or 攻击方.名称=="小有所成地煞星" or 攻击方.名称=="伏虎斩妖地煞星" or 攻击方.名称=="御风神行地煞星" or 攻击方.名称=="履水吐焰地煞星" or 攻击方.名称=="知了王" or 攻击方.名称=="知了先锋" or 攻击方.名称=="小知了王" then
        self.临时人数=1
    end
  elseif 技能名称=="惊涛怒" then
   self.临时人数=math.floor(self.临时等级/40)+2
   if self.临时人数>6 then self.临时人数=6 end
  elseif 技能名称=="惊涛怒" then
   self.临时人数=math.floor(self.临时等级/35)+1
   if self.临时人数>3 then self.临时人数=3 end
  elseif 技能名称=="金刚护法" or 技能名称=="一苇渡江" then
   self.临时人数=math.floor((self.临时等级-40)/30)+2
   if 编号~=nil and self:取奇经八脉是否有(编号,"映法") and 取随机数() <=50 then
       self.临时人数=10
   end
   elseif 技能名称=="金刚护体" or 技能名称=="韦陀护法" then
   self.临时人数=math.floor((self.临时等级-50)/30)+2
   if 技能名称=="金刚护体" then
      if 编号~=nil and self:取奇经八脉是否有(编号,"映法") and 取随机数() <=50 then
          self.临时人数=10
      end
   end
  elseif 技能名称=="雨落寒沙" or 技能名称=="飞花摘叶" or 技能名称=="唧唧歪歪" or 技能名称=="龙卷雨击" or 技能名称=="阎罗令" or 技能名称=="飞砂走石" or 技能名称=="生命之泉" then
   self.临时人数=math.floor(self.临时等级/25)+1
    if 技能名称=="飞花摘叶" and self.临时人数>=4 then
        self.临时人数=4
    end
    if 技能名称=="飞砂走石" and self.临时人数>=5 then
        self.临时人数=5
    end
    if 技能名称=="龙卷雨击" and self:取奇经八脉是否有(编号,"龙魄") and 取随机数()<=10 then
        self.临时人数=self.临时人数+3
    end
    if 技能名称=="飞花摘叶" and self:取奇经八脉是否有(编号,"花殇") and 取随机数()<=10 then
        self.临时人数=self.临时人数+3
    end
    if 技能名称=="飞砂走石" and 编号~=nil and self:取奇经八脉是否有(编号,"震怒") and 取随机数()<=10 then
       self.临时人数=self.临时人数+1
    end
    if self:取玩家战斗() and 技能名称=="阎罗令" then self.临时人数=1 end
  elseif 技能名称=="炽火流离" then
    self.临时人数=1
  elseif 技能名称=="焚魔烈焰" then
    self.临时人数=3
    if 编号~=nil and self:取奇经八脉是否有(编号,"怒火") then
      self.临时人数=4
    end
  elseif 技能名称=="碎星诀" or 技能名称=="镇魂诀"   then
   self.临时人数=math.floor(self.临时等级/35)+1
  elseif 技能名称=="九天玄火"  then
   self.临时人数=math.floor(self.临时等级/30)+1
   if self.临时人数>4 then self.临时人数=4 end
  elseif  技能名称=="苍茫树" or 技能名称=="地裂火" or 技能名称=="靛沧海" or 技能名称=="日光华" or 技能名称=="巨岩破"  then
   self.临时人数=math.floor(self.临时等级/40)+2
   if 编号~=nil and self:取奇经八脉是否有(编号,"五行制化") and 取随机数()<=20 then
      self.临时人数=10
      攻击方.固定伤害=攻击方.固定伤害+300
   end
   if self:取玩家战斗() then self.临时人数=1 end
  elseif 技能名称=="云暗天昏" or 技能名称=="匠心·破击" then
    self.临时人数=math.floor(self.临时等级/35)+2
    if self.临时人数>6 then self.临时人数=6 end
  elseif 技能名称=="天雷斩" then
    self.临时人数=math.floor(self.临时等级/30)+1
    if self.临时人数>3 then self.临时人数=3 end
    if self:取玩家战斗() then self.临时人数=1 end
    if 攻击方.名称=="初出茅庐地煞星" or 攻击方.名称=="小有所成地煞星" or 攻击方.名称=="伏虎斩妖地煞星" or 攻击方.名称=="御风神行地煞星" or 攻击方.名称=="履水吐焰地煞星" or 攻击方.名称=="知了王" or 攻击方.名称=="知了先锋" or 攻击方.名称=="小知了王" or 攻击方.名称=="乾坤" or 攻击方.名称=="乾坤无行" then
        self.临时人数=1
    end
  elseif 技能名称=="天罗地网"  then
    self.临时人数=math.floor(self.临时等级/30)+1
    if self.临时人数>3 then self.临时人数=3 end
    if self:取玩家战斗() then self.临时人数=1 end
  elseif 技能名称=="落叶萧萧" or 名称=="明光宝烛" then
    self.临时人数=math.floor(self.临时等级/35)+1
    if self.临时人数>5 then self.临时人数=5 end
    if 编号~=nil and self:取奇经八脉是否有(编号,"法身") then
      self.临时人数=self.临时人数+1
    end
  elseif 技能名称=="风卷残云" then
    self.临时等级=self:取技能等级(编号,"落叶萧萧")
    self.临时人数=math.floor(self.临时等级/35)+1
    if self.临时人数>5 then self.临时人数=5 end
    if 技能名称=="落叶萧萧" and self:取奇经八脉是否有(编号,"法身") then
      self.临时人数=self.临时人数+1
    end
  elseif 技能名称=="剑荡四方" or 技能名称=="破釜沉舟" or 技能名称=="雷霆万钧"   then
    self.临时人数=3
  elseif 技能名称=="二龙戏珠" or 技能名称=="摧心术"  then
    self.临时人数=2
    if 编号~=nil and self:取奇经八脉是否有(编号,"龙珠") and 取随机数()<=8 then
      self.临时人数=3
    end
  elseif 技能名称=="地涌金莲" then
    self.临时人数=1
    if self:取奇经八脉是否有(编号,"金莲")   then
      self.临时人数=2
    end
  elseif 技能名称=="百爪狂杀" then
    self.临时人数=4
  elseif 技能名称=="飘渺式"   then
    self.临时人数=math.floor(self.临时等级/30)+1
    if self.临时人数>3 then self.临时人数=3 end
    if self:取玩家战斗() then self.临时人数=1 end
  elseif 技能名称=="针锋相对" then
    self.临时人数=取随机数(1,3)
  elseif 技能名称=="锋芒毕露" or 技能名称=="匠心·削铁" or 技能名称=="匠心·固甲" or 技能名称=="匠心·蓄锐" then
    self.临时人数=取随机数(1,5)
  elseif 技能名称=="牛刀小试" or 技能名称=="妙悟" then
    self.临时人数=3
  elseif 技能名称=="翻江搅海" then
    if self.临时等级>=45 then
      self.临时人数=5
    elseif self.临时等级>=125 then
      self.临时人数=6
    else
      self.临时人数=math.floor(self.临时等级/40)+2
    end
    if self.临时人数>6 then self.临时人数=6 end
  elseif 技能名称=="蜜润" or 技能名称=="炎护"   then
   self.临时人数=math.floor(self.临时等级/40)+2
   if self.临时人数>6 then self.临时人数=6 end
  elseif 名称=="一笑倾城" then
    self.临时人数=3
  elseif 技能名称=="惊涛怒" then
   self.临时人数=math.floor(self.临时等级/35)+1
   if self.临时人数>3 then self.临时人数=3 end
  elseif 技能名称=="自爆" or 技能名称=="龙吟" or 技能名称=="四海升平" or 技能名传== "罗汉金钟" or 技能名称 == "圣灵之甲" or 技能名称 == "魔兽之印" or 技能名称=="玉清诀" or 技能名称=="晶清诀" or 技能名称=="魔兽之印" or 技能名称=="圣灵之甲" or 技能名称=="罗汉金钟"  then
   self.临时人数=10
  elseif 技能名称=="八凶法阵" then
    self.临时人数=4
  elseif 技能名称=="天降灵葫" then
    self.临时人数=取随机数(1,5)
  elseif 技能名称=="叱咤风云" then
    self.临时人数=3
  elseif 技能名称=="泰山压顶" or 技能名称=="水漫金山" or 技能名称=="地狱烈火" or 技能名称=="奔雷咒" then
   self.临时人数=math.floor(self.临时等级/30)+1
    if self.临时人数>3 then self.临时人数=3 end
  elseif 技能名称=="谜毒之缚" or 技能名称=="诡蝠之刑" or 技能名称=="怨怖之泣" then
    self.临时人数=math.floor(self.临时等级/40)+1
    if self.临时人数>=5 then self.临时人数=5 end
    if 编号~=nil and self:取奇经八脉是否有(编号,"灵诅") then
      self.临时人数=self.临时人数+1
    end
  elseif 技能名称=="神针撼海" then
    self.临时人数=math.floor(self.临时等级/35)+1
    if self.临时人数>=5 then self.临时人数=5 end
  else
   self.临时人数=1
  end
 return self.临时人数
end

function 战斗处理类:恢复技能(名称)
  local 临时名称={"起死回生","回魂咒","仙人指路","还魂咒","黄帝内经","无穷妙道","还阳术","舍身取义","活血","慈航普渡","地涌金莲","莲花心音","妙悟","星月之惠","玉清诀","净世煌火","晶清诀","冰清诀","水清诀","四海升平","命归术","气归术","凝神诀","凝气诀","命疗术","心疗术","气疗术","归元咒","乾天罡气","我佛慈悲","杨柳甘露","推拿","匠心·蓄锐","推气过宫","解毒","百毒不侵","宁心","解封","清心","驱魔","驱尸","寡欲令","复苏","由己渡人"}
 for n=1,#临时名称 do
     if 临时名称[n]==名称 then return true end
   end
 return false
end

function 战斗处理类:法攻技能(名称)
  local 临时名称={"天外飞剑","上古灵符","叱咤风云","天降灵葫","月光","八凶法阵","飞符炼魂","五行制化","孔雀明王经","摇头摆尾","黄泉之息","焚魔烈焰","腾雷","飞花摘叶","风卷残云","魔焰滔天","亢龙归海","天罗地网","夺命咒","血雨","飞花摘叶","落叶萧萧","荆棘舞","尘土刃","冰川怒","誓血之祭","自爆","唧唧歪歪","五雷咒","落雷符","雨落寒沙","五雷轰顶","雷霆万钧","龙卷雨击","炽火流离","龙吟","二龙戏珠","龙腾","云暗天昏","匠心·破击","苍茫树","靛沧海","日光华","地裂火","巨岩破","三昧真火","飞砂走石","判官令","阎罗令","水攻","烈火","落岩","雷击","泰山压顶","水漫金山","地狱烈火","奔雷咒"}
 for n=1,#临时名称 do
     if 临时名称[n]==名称 then return true end
   end
 return false
end

function 战斗处理类:物攻技能(名称)
  local 临时名称={"剑荡四方","翻江搅海","蚩尤之搏","破釜沉舟","惊涛怒","浪涌","猛击","百爪狂杀","鸿渐于陆","翩鸿一击","天命剑法","长驱直入","牛刀小试","天崩地裂","断岳势","裂石","满天花雨","破血狂攻","破碎无双","弱点击破","善恶有报","惊心一剑","壁垒击破","威震凌霄","横扫千军","狮搏","象形","连环击","鹰击","烟雨剑法","飘渺式","针锋相对","天雷斩","裂石","断岳势","天崩地裂","浪涌","惊涛怒","力劈华山","死亡召唤","夜舞倾城","高级连击","理直气壮"}
  for n=1,#临时名称 do
    if 临时名称[n]==名称 then return true end
  end
  return false
end

function 战斗处理类:封印技能(名称)
 local 临时名称={"摧心术","惊魂掌","瘴气","煞气诀","夺魄令","锋芒毕露","诱袭","反间之计","催眠符","画地为牢","金刚镯","一笑倾城","碎甲符","风雷韵动","妖风四起","凋零之歌","落花成泥","雷浪穿云","顺势而为","碎玉弄影","失心符","落魄符","失忆符","追魂符","离魂符","失魂符","定身符","莲步轻舞","如花解语","似玉生香","娉婷嬝娜","镇妖","错乱","百万神兵","日月乾坤","威慑","含情脉脉","魔音摄魂","夺魄令","惊魂掌","煞气诀","象形"}
 for n=1,#临时名称 do
     if 临时名称[n]==名称 then return true end
   end
 return false
end

function 战斗处理类:减益技能(名称)
local 临时名称={"尸腐毒","紧箍咒","勾魂","摄魄","雾杀","谜毒之缚","诡蝠之刑","怨怖之泣"}
 for n=1,#临时名称 do
     if 临时名称[n]==名称 then return true end
   end
 return false
end

function 战斗处理类:增益技能(名称)
 local 临时名称={"潜能激发","四面埋伏","变身","御风","幻镜术","颠倒五行","碎星诀","不动如山","气慑天军","匠心·固甲","匠心·削铁","明光宝烛","法术防御","罗汉金钟","光辉之甲","同舟共济","真君显灵","偷龙转凤","魑魅缠身","烈焰真诀","莲心剑意","波澜不惊","钟馗论道","诸天看护","渡劫金身","太极护法","野兽之力","圣灵之甲","魔兽之印","天神护体","移魂化骨","蜜润","炎护","后发制人","杀气诀","安神诀","分身术","达摩护体","呼子唤孙","唤灵·焚魂","唤魔·毒魅","唤魔·堕羽","唤灵·魂火","铜头铁臂","无所遁形","金刚护法","金刚护体","韦陀护法","一苇渡江","佛法无边","楚楚可怜","天神护法","乘风破浪","神龙摆尾","生命之泉","炼气化神","天地同寿","乾坤妙法","普渡众生","灵动九天","幽冥鬼眼","修罗隐身","火甲术","魔王回首","牛劲","定心术","极度疯狂","魔息术","天魔解体","盘丝阵","幻境术","不动如山","碎星诀","镇魂诀","明光宝烛","金身舍利","炎护","蜜润"}
 for n=1,#临时名称 do
     if 临时名称[n]==名称 then return true end
   end
 return false
end

function 战斗处理类:取封印状态(编号,是否)
 local 临时名称={"反间之计","诱袭","锋芒毕露","催眠符","失心符","落魄符","失忆符","追魂符","离魂符","失魂符","定身符","莲步轻舞","如花解语","似玉生香","娉婷嬝娜","镇妖","错乱","百万神兵","日月乾坤","威慑","含情脉脉","魔音摄魂","夺魄令","惊魂掌","煞气诀"}
 for i, v in pairs(self.参战单位[编号].法术状态) do
    for n=1,#临时名称 do
          if 临时名称[n]==i then
            if 是否 ~= nil then
              return i
            end
            return true
          end
        end
   end
 return false
end

function 战斗处理类:取技能等级(编号,名称)
  -- if self.参战单位[编号].队伍==0 then
  --   return self.参战单位[编号].等级+10
  -- end
  for n=1,#self.参战单位[编号].主动技能 do
    if self.参战单位[编号].主动技能[n].名称==名称 then
      return self.参战单位[编号].主动技能[n].等级
    end
  end
  for n=1,#self.参战单位[编号].附加状态 do
    if self.参战单位[编号].附加状态[n].名称==名称 then
      return self.参战单位[编号].附加状态[n].等级
    end
  end
  for n=1,#self.参战单位[编号].追加法术 do
    if self.参战单位[编号].追加法术[n].名称==名称 then
      return self.参战单位[编号].追加法术[n].等级
    end
  end
  return 0
end

function 战斗处理类:取行动状态(编号)
  if self.参战单位[编号].气血<=0 or self.参战单位[编号].捕捉 or self.参战单位[编号].逃跑 then
    return false
  elseif self.参战单位[编号].法术状态.横扫千军~=nil then
    return false
  elseif self.参战单位[编号].法术状态.誓血之祭~=nil then
    return false
  elseif self.参战单位[编号].法术状态.破釜沉舟~=nil then
    return false
  elseif self.参战单位[编号].法术状态.乾坤妙法~=nil then
    return false
  elseif self.参战单位[编号].法术状态.失心~=nil then
    return false
  elseif self.参战单位[编号].法术状态.落花成泥~=nil and 取随机数()<=70 then
    return false
  elseif self.参战单位[编号].法术状态.亢龙归海~=nil then
    return false
  elseif self.参战单位[编号].法术状态.血雨~=nil then
    return false
  elseif self.参战单位[编号].法术状态.催眠符~=nil and self.参战单位[编号].指令.类型~="召唤" then
    return false
  elseif self.参战单位[编号].精灵 and self.回合数==1 then
    return false
  end
 return true
end

function 战斗处理类:取攻击状态(编号)
  local 技能名称={"煞气诀","天罗地网","象形","横扫千军","誓血之祭","连环击","鹰击","催眠符","追魂符","定身符","如花解语","似玉生香","百万神兵","日月乾坤","威慑","含情脉脉","煞气诀"}
  for n=1,#技能名称 do
     if self.参战单位[编号].法术状态[技能名称[n]]~=nil then
         return false
       end
     end
 return true
end

function 战斗处理类:取法术状态(编号)
   local 技能名称={"反间之计","诱袭","锋芒毕露","修罗隐身","象形","血雨","楚楚可怜","一笑倾城","妖风四起","顺势而为","誓血之祭","横扫千军","连环击","鹰击","催眠符","失心符","落魄符","离魂符","失魂符","莲步轻舞","似玉生香","错乱","日月乾坤","威慑","含情脉脉","夺魄令","煞气诀"}
  for n=1,#技能名称 do
     if self.参战单位[编号].法术状态[技能名称[n]]~=nil then
         return false
       end
     end
 return true
end

function 战斗处理类:取特技状态(编号)
   local 技能名称={"反间之计","诱袭","锋芒毕露","煞气诀","象形","血雨","横扫千军","鹰击","连环击","催眠符","失忆符","日月乾坤","誓血之祭"}
  for n=1,#技能名称 do
     if self.参战单位[编号].法术状态[技能名称[n]]~=nil then
         return false
       end
     end
 return true
end

function 战斗处理类:普通攻击计算(编号,伤害比)
  local 目标=self.参战单位[编号].指令.目标
  if 目标==0 or 目标==nil then
    目标=self:取单个敌方目标(编号)
  elseif self:取目标状态(编号,目标,1)==false then
    目标=self:取单个敌方目标(编号)
  elseif self.参战单位[编号].指令.取消 then
    return
  end
  if 目标==0 then
    return
  end
  if self.参战单位[目标].法术状态.分身术~=nil and self.参战单位[目标].法术状态.分身术.破解==nil then
    self.参战单位[目标].法术状态.分身术.破解=1
    return
  end
  self.战斗流程[#self.战斗流程+1]={流程=1,攻击方=编号,挨打方={[1]={挨打方=目标,特效={}}}}
 local  躲避=false
 if self.参战单位[目标].躲避减少~=nil and 取随机数()<=self.参战单位[目标].躲避减少 then
     躲避=true
   end
  if 躲避 then
     self.战斗流程[#self.战斗流程].躲避=true
     self.战斗流程[#self.战斗流程].返回=true
     return
     end
 self.执行等待=self.执行等待+10
  local  保护=false
  local  保护编号=0
  for n=1,#self.参战单位 do
     if 保护编号==0 and self:取行动状态(n) and self.参战单位[目标].法术状态.惊魂掌==nil and self.参战单位[n].指令.类型=="保护" and  self.参战单位[n].队伍==self.参战单位[目标].队伍 and  self.参战单位[n].指令.目标==目标 then
          保护编号=n
          保护=true
          self.参战单位[n].指令.类型=""
           self.执行等待=self.执行等待+3
       end
     end
  local  必杀=false
  local  躲避=false
  local  防御=false
  local  反震=false
  local  反击=false
  local  伤害=self:取基础物理伤害(编号,目标)
  local  最终伤害=self:取最终物理伤害(编号,目标,伤害)
  if 保护 then
    local 保护伤害=math.floor(伤害*0.5)
    if 保护伤害<1 then
      保护伤害=1
    end
    local 保护死亡=self:减少气血(保护编号,保护伤害)
    伤害=math.floor(伤害*0.3)
    if 保护伤害<1 then
      保护伤害=1
    end
    self.战斗流程[#self.战斗流程].保护数据={编号=保护编号,伤害=保护伤害,死亡=保护死亡}
  end
  local  伤害值=self:取伤害结果(编号,目标,最终伤害.伤害,最终伤害.暴击,保护)
  if 编号~=nil and self:取奇经八脉是否有(编号,"六道无量") then
    伤害值.伤害=伤害值.伤害+qz(self:取技能等级(编号,"六道轮回")*0.6)
  end
  if 服务器名称 == "测试专区" then
      伤害值.伤害=伤害值.伤害*0.7
  elseif 服务器名称 == "零氪2020仿官" then
      伤害值.伤害=qz(伤害值.伤害*1.3)
  else
      伤害值.伤害=伤害值.伤害*0.7
  end
  if self.参战单位[编号].法术状态.谜毒之缚~=nil then
    伤害值.伤害=qz(伤害值.伤害*0.7*0.8)
  end
  if 伤害值.伤害<1 then
    伤害值.伤害=1
  end
  if 伤害值.伤害 >= self.参战单位[目标].最大气血*0.1 and self.参战单位[编号].千钧一怒 ~= nil and self.参战单位[编号].类型 == "bb" and self.参战单位[编号].主人 ~= nil and self.参战单位[self.参战单位[编号].主人] ~= nil then
    self.参战单位[self.参战单位[编号].主人].愤怒 = self.参战单位[self.参战单位[编号].主人].愤怒+10
    if self.参战单位[self.参战单位[编号].主人].愤怒 > 150 then
      self.参战单位[self.参战单位[编号].主人].愤怒 = 150
    end
  end
  if 伤害值.类型==2 then --恢复状态
    self:增加气血(目标,伤害值.伤害)
  else
    self.战斗流程[#self.战斗流程].挨打方[1].死亡=self:减少气血(目标,伤害值.伤害,编号)
    if self.参战单位[目标].气血<=0 then
      if self.参战单位[编号].自恋特性~=nil and self.参战单位[编号].自恋次数==nil and self.参战单位[编号].自恋特性*20>=取随机数() then
        self.参战单位[编号].自恋次数=1
        self.战斗发言数据[#self.战斗发言数据+1]={id=编号,内容="呔,你个258万,让你知道花儿为什么这样红#24"}
      end
    end
    if self.参战单位[目标].法术状态.催眠符 then
      self:取消状态("催眠符",self.参战单位[目标])
      self.战斗流程[#self.战斗流程].挨打方[1].取消状态="催眠符"
    end
  end
  self.战斗流程[#self.战斗流程].挨打方[1].动作=最终伤害.动作
  self.战斗流程[#self.战斗流程].挨打方[1].特效=最终伤害.特效
  self.战斗流程[#self.战斗流程].伤害=最终伤害.伤害
  if #最终伤害.特效==0 then
    self.战斗流程[#self.战斗流程].挨打方[1].特效={"被击中"}
  end
  local 吸血=self.参战单位[编号].吸血
  if 吸血==nil and self.参战单位[编号].法术状态.移魂化骨~=nil then
     吸血=self.参战单位[编号].法术状态.移魂化骨.等级/250
     if 编号~=nil and self:取奇经八脉是否有(编号,"移魂化骨") then
         吸血=qz(吸血*1.3)
     end
  end
 if 吸血~=nil and self.参战单位[目标].鬼魂==nil  then
      local 吸血伤害=math.floor(伤害值.伤害*吸血)
      if 吸血伤害<=0 then
         吸血伤害=1
         end
      self:增加气血(编号,吸血伤害)
      self.战斗流程[#self.战斗流程].吸血伤害=吸血伤害
   end
 local 反震=self.参战单位[目标].反震
 local 反击=self:取是否反击(编号,目标)
 --local 反击=1
 --local 反震=0.25
  if self.参战单位[编号].偷袭==nil and 反震~=nil and 取随机数()<=30 and 保护==false then --触发反震 有保护的情况下不会触发反震、反击
      local 反震伤害=math.floor(伤害值.伤害*反震)
      if 反震伤害<=0 then
         反震伤害=1
         end
       self.战斗流程[#self.战斗流程].反震伤害=反震伤害
       self.战斗流程[#self.战斗流程].反震死亡=self:减少气血(编号,反震伤害,目标)
       self.战斗流程[#self.战斗流程].挨打方[1].特效[#self.战斗流程[#self.战斗流程].挨打方[1].特效+1]="反震"
       self.执行等待=self.执行等待+2
  elseif 反击~=nil and self:取行动状态(目标) and self.参战单位[编号].偷袭==nil and 保护==false then
    local 反击伤害=math.floor(self:取基础物理伤害(目标,编号)*反击)
    if 反击伤害<1 then 反击伤害=1 end
    self.战斗流程[#self.战斗流程].反击伤害=反击伤害
    self.战斗流程[#self.战斗流程].反击死亡=self:减少气血(编号,反击伤害,目标)
    self.执行等待=self.执行等待+2
    end
    if self.战斗流程[#self.战斗流程].伤害==nil then --计算反震 如果出现法爆减伤 则不触发反震和反击
  end
 --计算是否触发毒
 if self.参战单位[编号].毒~=nil and self.参战单位[编号].毒>=取随机数() and self:取封印成功(名称,self.参战单位[编号].等级,self.参战单位[编号],self.参战单位[目标],编号) then
     self:添加状态("毒",self.参战单位[目标],self.参战单位[编号],self.参战单位[编号].等级,编号)
     self.战斗流程[#self.战斗流程].挨打方[1].增加状态="毒"
  end
 self.战斗流程[#self.战斗流程].挨打方[1].伤害=伤害值.伤害
 self.战斗流程[#self.战斗流程].挨打方[1].伤害类型=伤害值.类型
 self.战斗流程[#self.战斗流程].返回=true
  if self.参战单位[编号].气血>0 and self.参战单位[目标].法术状态.混元伞~=nil then
   local 反弹伤害=qz(self.战斗流程[#self.战斗流程].挨打方[1].伤害*(self.参战单位[目标].法术状态.混元伞.境界*0.03+0.1))
   self.战斗流程[#self.战斗流程+1]={流程=104,气血=反弹伤害,攻击方=目标,挨打方={挨打方=编号,特效={},死亡=self:减少气血(编号,反弹伤害,目标)},提示={允许=false}}
    end
  if 最终伤害.暴击 ~= nil then
    必杀 = true
  end
  if 必杀 and self:取奇经八脉是否有(编号,"傲视") then
    self.参战单位[编号].封印命中等级=20
  end
  if 必杀 and self.参战单位[编号].怒击效果 then
    return true
  end
  if self.参战单位[编号].法术状态.诡蝠之刑~=nil then
    if self:取目标状态(编号,编号,2) then
      local 气血=qz(伤害值.伤害*0.1)
      if 气血<=1 then
        气血=1
      end
      self.战斗流程[#self.战斗流程+1]={流程=102,攻击方=编号,气血=0,挨打方={}}
      self.战斗流程[#self.战斗流程].死亡=self:减少气血(编号,气血)
      self.战斗流程[#self.战斗流程].气血=气血
    end
  end
end

function 战斗处理类:取是否反击(编号,目标)
  if self.参战单位[目标].法术状态.魔王回首~=nil or self.参战单位[编号].法术状态.诱袭~=nil or  self.参战单位[目标].法术状态.极度疯狂~=nil or (self.参战单位[目标].反击 ~= nil and 取随机数()<=self.参战单位[目标].反击) then
    return 1
  elseif self.参战单位[目标].法术状态.不动如山~=nil and self:取奇经八脉是否有(目标,"抗击") then
    return 1
  else
    return nil
  end
end

function 战斗处理类:增加魔法(编号,数额)
  if self.参战单位[编号].法术状态.魔音摄魂~=nil and self.参战单位[编号].意乱~=nil then
      常规提示(self.参战单位[编号].id,"你当前状态无法恢复魔法！")
      return
  end
  self.参战单位[编号].魔法=self.参战单位[编号].魔法+数额
  if self.参战单位[编号].魔法>self.参战单位[编号].最大魔法 then
     self.参战单位[编号].魔法=self.参战单位[编号].最大魔法
  end
end

function 战斗处理类:增加气血(编号,数额)
  self.参战单位[编号].气血=self.参战单位[编号].气血+数额
  if self.参战单位[编号].气血>self.参战单位[编号].最大气血 then
    self.参战单位[编号].气血=self.参战单位[编号].最大气血
  end
end
function 战斗处理类:添加危险发言(编号,类型)
  if self.参战单位[编号].队伍~=0 then
    local 已发言=false
    for n=1,#self.参战单位 do
      if 已发言==false and self.参战单位[n].队伍==self.参战单位[编号].队伍 then
        if self.参战单位[n].预知特性~=nil  then
          if self.参战单位[n].预知次数<3 and self.参战单位[n].预知特性*7>=取随机数() then
            self.参战单位[n].预知次数=self.参战单位[n].预知次数+1
            self.战斗发言数据[#self.战斗发言数据+1]={id=n,内容=self:取危险发言内容(self.参战单位[编号].名称,类型)}
            已发言=true
          end
        end
      end
    end
    for n=1,#self.参战玩家 do
      for i=1,#self.战斗发言数据 do
        发送数据(self.参战玩家[n].连接id,5512,{id=self.战斗发言数据[i].id,文本=self.战斗发言数据[i].内容})
      end
    end
    self.战斗发言数据 = {}
  end

end

function 战斗处理类:取危险发言内容(名称,类型)
  local 发言内容={}
  if 类型==1 then --死亡
    发言内容={format("#G/%s#W我的直觉告诉我你活不过本回合#74",名称),format("让我们高歌欢舞恭送#G/%s#83",名称),format("唢呐吹起来，锣鼓敲起来，我们的#G/%s#W/倒下来#42",名称)}
  elseif 类型==2 then --重伤
    发言内容={format("#G/%s#W看起来伤势很重啊#52",名称),format("#G/%s#W你再不注意加血，当心我在你坟头上蹦迪哈#24",名称),format("#G/%s#W/你是长相有问题还是内心太黑暗呢#55",名称)}
  end
  return 发言内容[取随机数(1,#发言内容)]
end

function 战斗处理类:减少气血(编号,数额,攻击,名称)
    self.参战单位[编号].气血=self.参战单位[编号].气血-数额
    if self.参战单位[编号].气血<=self.参战单位[编号].最大气血*0.2 then
      self:添加危险发言(编号,2)
    end
    if self.参战单位[编号].类型=="角色" then
      local 临时愤怒=qz(数额/self.参战单位[编号].最大气血*0.5*100)
      if self.参战单位[编号].暴怒腰带 ~= nil then
        临时愤怒=临时愤怒 + math.floor(临时愤怒*0.25)
      end
      if 临时愤怒>10 and self:取奇经八脉是否有(编号,"怒火") then
         临时愤怒=临时愤怒+5
      end
      self.参战单位[编号].愤怒=self.参战单位[编号].愤怒+临时愤怒
      if self.参战单位[编号].愤怒>150 then
        self.参战单位[编号].愤怒=150
      end
    end
    if self.参战单位[编号].气血<=0 then
      self:添加危险发言(编号,1)
      self.执行等待=self.执行等待+5
      self.参战单位[编号].气血=0
      if  self.参战单位[编号].同门单位 then
        self.同门死亡=true
      end
      if self.参战单位[编号].类型=="角色" then
        self:设置复仇对象(编号,攻击)
        self.参战单位[编号].愤怒=0
        return 2
      else
        if self.参战单位[编号].鬼魂==nil then
          return 1
        else
        if 攻击==nil and 名称==nil then
          self.参战单位[编号].法术状态.复活={回合=self.参战单位[编号].鬼魂}
          return 2
        elseif self.参战单位[攻击].法术状态.灵断~=nil then
          return 1
        elseif 名称=="五雷咒" or 名称=="落雷符" then
          return 1
        elseif 攻击==nil then
          self.参战单位[编号].法术状态.复活={回合=self.参战单位[编号].鬼魂}
          return 2
        elseif self.参战单位[攻击].驱鬼~=nil then
          return 1
        else
          self.参战单位[编号].法术状态.复活={回合=self.参战单位[编号].鬼魂}
         return 2
        end
      end
    end
  else
    return
  end
end
function 战斗处理类:设置复仇对象(编号,攻击)
  local id=self.参战单位[编号].召唤兽
  if id==nil or id==0 or self.参战单位[id]==nil then
    return
  elseif self.参战单位[id].复仇特性~=nil and  self.参战单位[id].复仇特性*20>=取随机数(1,10) then
    self.参战单位[id].复仇标记=攻击
  end

end

function 战斗处理类:取可否防御(挨打方)
 if self.参战单位[挨打方].法术状态.横扫千军~=nil or self.参战单位[挨打方].法术状态.催眠符~=nil or self.参战单位[挨打方].法术状态.楚楚可怜~=nil then
     return false
    else
     return true
   end
end

function 战斗处理类:取最终物理伤害(攻击方,挨打方,伤害)
 local 特效={}
 local 动作="挨打"
 local 暴击 = nil
 --计算防御

  if self.参战单位[挨打方].指令.类型=="防御" and self:取行动状态(挨打方) and self:取可否防御(挨打方) then
      伤害=伤害*0.5
      if 编号~=nil and self:取奇经八脉是否有(攻击方,"击破") then
          伤害=伤害*3
      end
      动作="防御"
      特效[#特效+1]="防御"
  end
 if self.参战单位[挨打方].幸运==nil then
      local 必杀几率=5
      if self.参战单位[攻击方].必杀~=nil then
          必杀几率=必杀几率+self.参战单位[攻击方].必杀
      end
      必杀几率=必杀几率+(self.参战单位[攻击方].物理暴击等级-self.参战单位[挨打方].抗物理暴击等级)*0.1
      if 必杀几率>=取随机数() then
          if 编号~=nil and self:取奇经八脉是否有(攻击方,"杀意") then
              伤害=伤害*1.2
          end
          伤害=伤害*2
          特效[#特效+1]="暴击"
          暴击=true
         end
   end
 if self.参战单位[挨打方].鬼魂~=nil and self.参战单位[攻击方].驱鬼 then
       伤害=伤害*1.5
   end
  伤害=伤害-self.参战单位[挨打方].格挡值
  if self.参战单位[挨打方].物伤减少~=nil then
      伤害=伤害*self.参战单位[挨打方].物伤减少
     end
  local 境界=self:取指定法宝境界(挨打方,"金甲仙衣") or 0
    if 境界 then
      local 触发几率=境界*2+10 --9层:28%
      if 取随机数(1,100) <= 触发几率 then
        if self:取指定法宝(挨打方,"金甲仙衣",1) then
          local 境界=self:取指定法宝境界(挨打方,"金甲仙衣")
          local 减伤效果=0.9-境界*0.05
          伤害=qz(伤害*减伤效果)
          特效[#特效+1]="金甲仙衣"
        end
      end
    end
  if self.参战单位[攻击方]~=nil and self.参战单位[攻击方].数字id~=nil and self.参战单位[攻击方].类型=="角色" then
      玩家数据[self.参战单位[攻击方].数字id].角色:耐久处理(self.参战单位[攻击方].数字id,1)
  end
  if self.参战单位[挨打方]~=nil and self.参战单位[挨打方].数字id~=nil and self.参战单位[挨打方].类型=="角色" then
      玩家数据[self.参战单位[挨打方].数字id].角色:耐久处理(self.参战单位[挨打方].数字id,2)
  end
  if self.参战单位[挨打方]~=nil and self.参战单位[挨打方].玩家id~=nil and self.参战单位[挨打方].玩家id~=0 and self.参战单位[挨打方].类型=="bb" and self.参战单位[挨打方].分类~="野怪" then
      玩家数据[self.参战单位[挨打方].玩家id].召唤兽:耐久处理(self.参战单位[挨打方].玩家id,self.参战单位[挨打方].认证码)
  end
 return {伤害=qz(伤害),动作=动作,特效=特效,暴击=暴击}
end

function 战斗处理类:取灵力伤害(攻击方,挨打方,编号)
  local 法防参数=0
  local 法伤参数=0
  if self:取指定法宝(编号,"镇海珠",1) then
    法伤参数=self:取指定法宝境界(编号,"镇海珠")*0.01
  end
  local 装备伤害=0
  if 攻击方.装备~=nil then --装备
    for i=1,6 do
      if 攻击方.装备[i]~=nil and 攻击方.装备[i].伤害~=nil then
        装备伤害=装备伤害+攻击方.装备[i].伤害/3
      end
    end
  end
  if 攻击方.灵饰~=nil then
    for i=1,4 do
      if 攻击方.灵饰[i]~=nil and 攻击方.灵饰[i].伤害~=nil then
        装备伤害=装备伤害+攻击方.灵饰[i].伤害/3
      end
    end
  end
  local 伤害=0
  if 攻击方.法术伤害<=0 then
    攻击方.法术伤害=0
  end
  if 释怀定制 and 攻击方.类型 == "角色" then
    伤害=(((攻击方.灵力-挨打方.灵力)+攻击方.灵力*0.1+攻击方.法术伤害+装备伤害)*(1+攻击方.法术修炼*0.03-挨打方.抗法修炼*0.02+法伤参数))-挨打方.法防-挨打方.法术防御
  else
    伤害=(((攻击方.灵力-挨打方.灵力)+攻击方.灵力*0.1+攻击方.法术伤害+装备伤害)*(1+攻击方.法术修炼*0.02-挨打方.抗法修炼*0.02+法伤参数))-挨打方.法防-挨打方.法术防御
  end
  伤害=qz(伤害*self:取抗法特性(挨打方.队伍))
  if 挨打方.抗物特性~=nil then
    伤害=qz(伤害*(1+(挨打方.抗物特性*4+14)/100))
  end
  if 攻击方.弑神特性~=nil and 挨打方.神佑效果~=nil then
    伤害=qz(伤害*(1+(攻击方.弑神特性*4+5)/100))
  end
  if 攻击方.顺势特性~=nil  then
    if  挨打方.气血<=挨打方.最大气血*0.7 then
      伤害=qz(伤害*(1+(攻击方.顺势特性*30+60)/1000))
    else
      伤害=qz(伤害*0.9)
    end
  end
  if 伤害<=0 then
    伤害=取随机数(1,5)
  end
  if 攻击方.队伍~=0 then
    伤害=伤害*2
  end
  if 攻击方.法伤~=nil then
    伤害=伤害+攻击方.法伤*8
  end
  if 攻击方.法术状态.灵法~=nil then
    if 攻击方.特性几率 ~= nil then
      伤害=伤害 + 伤害*(攻击方.特性几率*5/100)
    end
  end
  if 攻击方.魔之心~=nil then
    伤害=伤害*攻击方.魔之心
  end
  if 攻击方.须弥~=nil then
    伤害=伤害*1.3
  end
  if 挨打方.鬼魂~=nil and 攻击方.驱鬼 then
    伤害=伤害*1.5
  end
  伤害=伤害+攻击方.法术伤害结果
  if 挨打方.法伤减少~=nil then
    伤害=伤害*挨打方.法伤减少
  end
  if 攻击方.法术状态.龙魂 ~= nil then
    伤害=伤害*1.2
  end
  if 挨打方.法术状态.罗汉金钟 ~= nil or 挨打方.法术状态.太极护法 ~= nil then
    伤害=伤害*0.5
  elseif 挨打方.法术状态.法术防御 then
    伤害=伤害*0.4
  end
  if self:取玩家战斗() and 让海啸席卷 then
    if 攻击方.类型 == "角色" then
      伤害=qz(伤害*0.7)
    else
      伤害=qz(伤害*0.35)
    end
  end
  if 攻击方.法术状态.张弛有道 ~= nil and 攻击方.张弛有道加成 ~= nil then
    攻击方.灵力 = 攻击方.灵力 - 攻击方.张弛有道加成
    攻击方.张弛有道加成 = nil
  end
  return qz(伤害*取随机数(90,110)/100)
end

function 战斗处理类:取伤害结果(攻击方,挨打方,伤害,暴击,保护) --如果保护存在 不触发神佑效果
  local 类型=1
  if self.参战单位[攻击方].队伍==0 then
     -- 伤害=math.floor(伤害*0.75)
  end
  if 伤害<1 then
      伤害=1
  end
  if 暴击~=nil then
      类型=3
  end
  if self.参战单位[攻击方].百步穿杨~=nil and self.参战单位[攻击方].百步穿杨~=0 and 20>取随机数() then
      伤害=伤害+self.参战单位[攻击方].百步穿杨
  end
  if self.参战单位[挨打方].云随风舞~=nil and self.参战单位[挨打方].云随风舞~=0 and 25>取随机数() then
      伤害=伤害-self.参战单位[挨打方].云随风舞
  end
  if self.参战单位[挨打方].心随我动~=nil and self.参战单位[挨打方].心随我动~=0 and 25>取随机数() then
      伤害=伤害-self.参战单位[挨打方].心随我动
  end
  if (保护==false or 保护==false) and self.参战单位[挨打方].鬼魂==nil and  self.参战单位[挨打方].神佑~=nil and 伤害>=self.参战单位[挨打方].气血  and self.参战单位[攻击方].法术状态.灵断==nil then
      if self.参战单位[挨打方].神佑>=取随机数() then
         伤害=self.参战单位[挨打方].最大气血-self.参战单位[挨打方].气血
         类型=2
         self.参战单位[挨打方].神佑效果=true
      end
  end
  if 类型~=2 then
    if self.参战单位[挨打方].法术状态.炎护~=nil then
      local 临时伤害=qz(伤害*0.5)
      if 临时伤害>1 then
        if self.参战单位[挨打方].魔法>临时伤害 then
          self.参战单位[挨打方].魔法=self.参战单位[挨打方].魔法-临时伤害
          临时伤害=0
        else
          临时伤害=临时伤害-self.参战单位[挨打方].魔法
          self.参战单位[挨打方].魔法=0
        end
        伤害=qz(伤害*0.5)+临时伤害
      end
    end
    if self.参战单位[挨打方].法术状态.苍白纸人~=nil then
      伤害=qz(伤害*(1-self.参战单位[挨打方].法术状态.苍白纸人.境界*0.05))
    elseif self.参战单位[挨打方].法术状态.五彩娃娃~=nil then
      伤害=qz(伤害*(1-self.参战单位[挨打方].法术状态.五彩娃娃.境界*0.025))
    end
    if self.参战单位[挨打方].法术状态.护佑 ~= nil then
      伤害=qz(伤害*0.5)
    end
    if self:取指定法宝(挨打方,"奇门五行令",1,1) then
      local 境界=self:取指定法宝境界(挨打方,"奇门五行令")
      local 伤害比=0.35+self.参战单位[挨打方].气血/self.参战单位[挨打方].最大气血
      伤害比=伤害比+(0.6-0.04*境界)
      伤害=qz(伤害*伤害比)
    elseif self:取指定法宝(挨打方,"失心钹",1,1) and self.参战单位[攻击方].队伍~=0 and self.参战单位[攻击方].类型~="角色" then
      local 境界=self:取指定法宝境界(挨打方,"失心钹")
      伤害=伤害-境界*15
    end
    if self.参战单位[攻击方].法术状态.灵刃~=nil then
      if self.参战单位[挨打方].鬼魂~=nil or self.参战单位[挨打方].神佑~=nil then
        伤害=qz(伤害*1.1)
      else
        伤害=qz(伤害*1.5)
      end
    end
  end
  if self:取玩家战斗() and 让海啸席卷 then
    if self.参战单位[攻击方].类型 == "角色" then
      伤害=qz(伤害*0.4)
    else
      伤害=qz(伤害*0.3)
    end
  end
  if self.参战单位[挨打方].类型=="角色" and 攻击方~=nil and self:取奇经八脉是否有(攻击方,"噬魔") then
    伤害=qz(伤害*1.1)
  end
  local 怨灵存在=0
  local 怨灵id=0
  for n=1,#self.参战单位 do
    if self.参战单位[n].名称=="怨灵" then
      怨灵存在=怨灵存在+1
      if 怨灵id<1 then
        self.参战单位[n].气血=0
      end
      怨灵id=怨灵id+1
    end
  end
  if 怨灵存在>=1 and 攻击方~=nil and self:取奇经八脉是否有(攻击方,"狂焰") then
    伤害=qz(伤害*1.03)
  end
  if self.参战单位[攻击方].心源 ~= nil and 取随机数()<= self.参战单位[攻击方].心源 then
    伤害 = 伤害 * 3
  end
  if 攻击方~=nil and self.参战单位[攻击方].气血>self.参战单位[挨打方].气血 and self:取奇经八脉是否有(攻击方,"纯青") then
    伤害 = 伤害*1.1
  end
  if 攻击方~=nil and self:取奇经八脉是否有(攻击方,"攻云") then
    伤害=qz(伤害*1.4)
  end
  if 攻击方~=nil and self:取奇经八脉是否有(攻击方,"愈勇") then
    伤害=qz(伤害*1.02)
    self.参战单位[攻击方].防御=qz(self.参战单位[攻击方].防御*1.02)
  end
  if 攻击方~=nil and self:取奇经八脉是否有(攻击方,"斗志") then
    伤害=qz(伤害*1.06)
  end
  if 攻击方~=nil and self:取奇经八脉是否有(攻击方,"伏妖") then
    伤害=qz(伤害+self.参战单位[攻击方].力量*0.1+40)
  end
  if 攻击方~=nil and self:取奇经八脉是否有(攻击方,"战神") then
    伤害=qz(伤害*1.08)
  end
  伤害 = 伤害*(1+self:取阵法克制(攻击方,挨打方))
  if 伤害<1 then 伤害=1 end
  return {伤害=伤害,类型=类型}
end

function 战斗处理类:取基础物理伤害(攻击方,挨打方)

  local 防御基数=1
  local 防御=(self.参战单位[挨打方].防御*(1+self.参战单位[挨打方].防御修炼*0.02))-self.参战单位[攻击方].穿刺等级
  if self:取指定法宝(攻击方,"七杀",1,1) then
    防御=self:取指定法宝境界(攻击方,"七杀")*0.02*防御
  end
  if self.参战单位[攻击方].力破特性~=nil  then
    if self.参战单位[挨打方].类型=="角色" then
      防御=防御-(self.参战单位[攻击方].力破特性*40+40)
      if 防御 <= 0 then
        防御 = 0
      end
    else
        防御 = qz(防御*1.05)
    end
  end
  local 伤害=self.参战单位[攻击方].伤害*(1+self.参战单位[攻击方].攻击修炼*0.02)
  local 误差=防御-伤害
  if 误差<=100 then
      防御基数=0.7
  elseif 误差<=200 then
      防御基数=0.8
  elseif 误差<=300 then
      防御基数=0.9
  end
  if self.参战单位[攻击方].狂暴等级>=取随机数(1,2000) then
    伤害=伤害*1.5
  end
  local 结果=伤害-防御*防御基数
  if 结果 <= 0 then
    结果 = 1
  end
  结果=结果+结果*结果/4500
  结果=qz(结果*self:取抗物特性(self.参战单位[挨打方].队伍))
  if self.参战单位[挨打方].抗法特性~=nil then
    结果=qz(结果*(1+(self.参战单位[挨打方].抗法特性*4+14)/100))
  end
  if self.参战单位[攻击方].驱怪~=0 then
    结果=结果*1.1
  end
  if self.参战单位[攻击方].争锋特性~=nil  then
    if self.参战单位[挨打方].类型~="角色" then
      结果=qz(结果*(self.参战单位[攻击方].争锋特性*0.08+1))
    else
      结果=qz(结果*0.9)
    end
  end
  if self.参战单位[攻击方].从天而降 ~= nil and 取随机数() <= 50 then
    结果=qz(结果*1.3)
  end
  return math.floor(结果*取随机数(90,110)/100)

end

function 战斗处理类:取抗法特性(队伍)
  if 队伍==0 then
    return 1
  end
  local 基础抗性=1
  for n=1,#self.参战单位 do
    if self.参战单位[n].抗法特性~=nil then
      local 基础=3+self.参战单位[n].特性几率*5
      基础=1-基础/100
      if 基础<基础抗性 then 基础抗性=基础 end
    end
  end
  return 基础抗性
end

function 战斗处理类:取抗物特性(队伍)
  if 队伍==0 then
    return 1
  end
  local 基础抗性=1
  for n=1,#self.参战单位 do
    if self.参战单位[n].抗物特性~=nil then
      local 基础=3+self.参战单位[n].抗物特性*5
      基础=1-基础/100
      if 基础<基础抗性 then
        基础抗性=基础
      end
    end
  end
  return 基础抗性
end

function 战斗处理类:取单个敌方目标(编号)
  local 目标组={}
  for n=1,#self.参战单位 do
     if  self.参战单位[n].队伍~=self.参战单位[编号].队伍 and self:取目标状态(编号,n,1) then
         目标组[#目标组+1]=n
     end
     end
  if #目标组==0 then
     return 0
    else
     return 目标组[取随机数(1,#目标组)]
  end
end

function 战斗处理类:取单个友方目标(编号,是否)
  local 目标组={}
  for n=1,#self.参战单位 do
    if 是否 ~= nil then
       if self.参战单位[n].队伍==self.参战单位[编号].队伍 and self:取目标状态(编号,n,1) then
           目标组[#目标组+1]=n
       end
    else
       if n~=编号 and self.参战单位[n].队伍==self.参战单位[编号].队伍 and self:取目标状态(编号,n,1) then
           目标组[#目标组+1]=n
       end
    end
  end
  if #目标组==0 then
     return 0
  else
     return 目标组[取随机数(1,#目标组)]
  end
end

function 战斗处理类:取目标状态(攻击,挨打,类型)  --类型=1 为敌方正常 2为队友 3为复活队友
 --print(攻击,挨打,类型)
  if self.参战单位[挨打]==nil or self.参战单位[挨打].法术状态==nil then return false end
  if 类型==1 then
    if 让海啸席卷 then
      if self.参战单位[挨打].气血<=0 or self.参战单位[挨打].捕捉 or self.参战单位[挨打].逃跑  then
        return false
      elseif self.参战单位[挨打].法术状态.修罗隐身~=nil and self.参战单位[攻击].法术状态.幽冥鬼眼==nil and self.参战单位[攻击].感知==nil then
        return false
      end
    else
      if self.参战单位[挨打].气血<=0 or self.参战单位[挨打].捕捉 or self.参战单位[挨打].逃跑  then
        return false
      elseif self.参战单位[挨打].法术状态.楚楚可怜~=nil and self.参战单位[攻击].感知==nil then
        return false
      elseif self.参战单位[挨打].法术状态.修罗隐身~=nil and self.参战单位[攻击].法术状态.幽冥鬼眼==nil and self.参战单位[攻击].感知==nil then
        return false
      end
    end
  elseif 类型==2 then
    if self.参战单位[挨打].气血<=0 or self.参战单位[挨打].捕捉 or self.参战单位[挨打].逃跑 then
       return false
    end
  end
 return true
end

function 战斗处理类:设置命令回合()
 self.回合数=self.回合数+1
 for n=1,#self.参战玩家 do
      for i=1,#self.战斗发言数据 do
        发送数据(self.参战玩家[n].连接id,5512,{id=self.战斗发言数据[i].id,文本=self.战斗发言数据[i].内容})
      end
      self.战斗发言数据={}
      local 编号=self:取参战编号(self.参战玩家[n].id,"角色")
      local 目标={编号}
      if self.参战单位[编号].召唤兽~=nil then
        目标[2]=self.参战单位[编号].召唤兽
      end
      if self.参战单位[编号].助战明细 ~= nil then
        for i=1,#self.参战单位[编号].助战明细 do
            目标[#目标+1] = self.参战单位[编号].助战明细[i]
        end
      end
      for i=1,#目标 do
        self.参战单位[目标[i]].指令={下达=false,类型="",目标=0,敌我=0,参数="",附加="",编号=目标[i]}
      end
      if 玩家数据[self.参战玩家[n].id]~=nil and 玩家数据[self.参战玩家[n].id].角色.数据.自动战斗 then
        -- 常规提示(self.参战玩家[n].id,"#Y/您正在使用自动战斗功能，系统将自动执行上一次指令。您可以在每回合开始前的5秒内点击自动以取消自动战斗功能")
      end
      发送数据(self.参战玩家[n].连接id,5503,目标)
   end
  --清空一次怪物单位
  for n=1,#self.参战单位 do
    if self.参战单位[n].门派=="花果山" then
      self.参战单位[n].主动技能={}
      self.随机神通={"当头一棒","神针撼海","杀威铁棒","泼天乱棒"}
      self.参战单位[n].随机神通=self.随机神通[取随机数(1,#self.随机神通)]
      for i=1,#玩家数据[self.参战单位[n].玩家id].角色.数据.师门技能 do
        for s=1,#玩家数据[self.参战单位[n].玩家id].角色.数据.师门技能[i].包含技能 do
          if 玩家数据[self.参战单位[n].玩家id].角色.数据.师门技能[i].包含技能[s].学会 then
            self.参战单位[n].师门技能[i]={名称=self.参战单位[n].师门技能[i],等级=玩家数据[self.参战单位[n].玩家id].角色.数据.师门技能[i].等级}
            local 名称=玩家数据[self.参战单位[n].玩家id].角色.数据.师门技能[i].包含技能[s].名称
            if self:恢复技能(名称) or self:法攻技能(名称) or self:物攻技能(名称) or self:封印技能(名称) or self:减益技能(名称) or self:增益技能(名称) or 名称==self.参战单位[n].随机神通 then
              self.参战单位[n].主动技能[#self.参战单位[n].主动技能+1]={名称=名称,等级=玩家数据[self.参战单位[n].玩家id].角色.数据.师门技能[i].等级}
            end
          end
        end
      end
      发送数据(玩家数据[self.参战单位[n].玩家id].连接id,5518,{id=n,主动技能=self.参战单位[n].主动技能})
    end
    if self.参战单位[n].队伍==0  then
      self.参战单位[n].指令={下达=false,类型="",目标=0,敌我=0,参数="",附加=""}
    else
      if self.参战单位[n].指令~=nil then
        self.参战单位[n].指令={下达=false,类型="",目标=0,敌我=0,参数="",附加="",编号=self.参战单位[n].指令.编号}
      else
        self.参战单位[n].指令={下达=false,类型="",目标=0,敌我=0,参数="",附加="",编号=n}
      end
    end
  end
  self.加载数量=#self.参战玩家
  self.等待起始=os.time()
  self.回合进程="命令回合"
end

function 战斗处理类:取参战编号(id,类型)
 for n=1,#self.参战单位 do
      if self.参战单位[n].类型==类型 and self.参战单位[n].玩家id==id and self.参战单位[n].助战编号 == nil then
        return n
      end
   end
end

function 战斗处理类:逃跑事件处理(id)
  if #self.参战玩家==1 then --只有一个玩家时直接结束战斗
    self.回合进程="结束回合"
    if self.任务id~=nil and 任务数据[self.任务id] ~= nil then

      任务数据[self.任务id].战斗=nil
    end
    self:还原指定单位属性(id)
    self:失败处理(id,"逃跑")
    self:发送退出信息()
    self.参战玩家={}
    self.结束条件=true
    玩家数据[id].角色.数据.战斗开关=false
    return
  else
    local 编号=0
    for n=1,#self.参战玩家 do
      if self.参战玩家[n].id==id then
        地图处理类:设置战斗开关(self.参战玩家[n].id)
        table.remove(self.参战玩家,n)
        break
      end
    end
    self:还原指定单位属性(id)
    玩家数据[id].战斗=0
    玩家数据[id].角色.数据.战斗开关=nil
    玩家数据[id].道具:重置法宝回合(id)
    队伍处理类:退出队伍(id)
    玩家数据[id].遇怪时间=os.time()+取随机数(10,20)
    发送数据(玩家数据[id].连接id,5505)
  end
end

function 战斗处理类:结束战斗(胜利id,失败id,系统) --系统为不计算失败惩罚
  self:还原单位属性()
  if 系统==nil then
     self:胜利处理(胜利id,失败id)
     self:失败处理(失败id,nil,胜利id)
  end
  self:发送退出信息()
end

function 战斗处理类:胜利处理(胜利id,失败id)
  local id组={}
  for n=1,#self.参战玩家 do
      if self.参战玩家[n].队伍==胜利id and 玩家数据[self.参战玩家[n].id]~=nil then
          self:奖励事件(self.参战玩家[n].id)
          id组[#id组+1]=self.参战玩家[n].id
      end
  end
  if 胜利id~=0 then
     self.玩家胜利=true
     self.战斗胜利=true
      if self.战斗类型==100004 then
          任务处理类:完成封妖任务(self.任务id,id组)
      elseif self.战斗类型==100005 or self.战斗类型==100007 or self.战斗类型==100061 or self.战斗类型==100008 or self.战斗类型==100009 or self.战斗类型==100010 then
        地图处理类:删除单位(任务数据[self.任务id].地图编号,任务数据[self.任务id].单位编号)
        任务数据[self.任务id]=nil
        if self.战斗类型 == 100008 and 老八定制 then
          抓鬼仙玉 = 抓鬼仙玉 +1
          广播消息({内容=format("#S(捉鬼任务)#Y每日前100轮抓鬼奖励仙玉获得还剩下#R%s#Y轮".."#"..取随机数(1,110),(2000-抓鬼仙玉)),频道="xt"})
        end
       elseif self.战斗类型==100006 then
         游戏活动类:科举回答题目(玩家数据[self.进入战斗玩家id].连接id,self.进入战斗玩家id,答案,4)
       elseif self.战斗类型==100011 then
          local 任务id1=玩家数据[self.进入战斗玩家id].角色:取任务(107)
          local 对话门派=Q_门派编号[任务数据[任务id1].当前序列]
          self.对话数据={名称=任务数据[self.任务id].名称,模型=任务数据[self.任务id].模型}
          local 删除序列=0
          for n=1,#任务数据[任务id1].闯关序列 do
            if 任务数据[任务id1].闯关序列[n]==任务数据[任务id1].当前序列 then
              删除序列=n
            end
          end
         table.remove(任务数据[任务id1].闯关序列,删除序列)
         if #任务数据[任务id1].闯关序列==0 then
             self.对话数据.对话="恭喜你们完成了本轮门派闯关活动#1"
             local 队伍id=玩家数据[self.进入战斗玩家id].队伍
             for i=1,#队伍数据[队伍id].成员数据 do
                   玩家数据[队伍数据[队伍id].成员数据[i]].角色:取消任务(任务id1)
             end
          else
             任务数据[任务id1].当前序列=任务数据[任务id1].闯关序列[取随机数(1,#任务数据[任务id1].闯关序列)]
             self.对话数据.对话=format("你通过了本门派护法的考验，请继续前往下一关#Y/%s#W/接受考验。".."#"..取随机数(1,110),Q_门派编号[任务数据[任务id1].当前序列])
          end
        elseif self.战斗类型==100012 then
          任务数据[玩家数据[self.进入战斗玩家id].角色:取任务(109)].战斗=true
        elseif self.战斗类型==100013 then
          任务数据[self.任务id].战斗次数=任务数据[self.任务id].战斗次数+1
          地图处理类:删除单位(任务数据[self.任务id].地图编号,任务数据[self.任务id].单位编号)
          if 任务数据[self.任务id].战斗次数>=2 then
           任务处理类:完成官职任务(self.进入战斗玩家id,1)
          else
            local 地图范围={1001,1501,1092,1070,1040,1226,1208}
            local 地图=地图范围[取随机数(1,#地图范围)]
            local xy=地图处理类.地图坐标[地图]:取随机点()
            任务数据[self.任务id].地图编号=地图
            任务数据[self.任务id].地图名称=取地图名称(地图)
            任务数据[self.任务id].x=xy.x
            任务数据[self.任务id].y=xy.y
            玩家数据[self.进入战斗玩家id].战斗对话={名称="流氓",模型="赌徒",对话="打不过我还躲不过嘛，换个地方继续惹事#4"}
            地图处理类:添加单位(self.任务id)
            玩家数据[self.进入战斗玩家id].角色:刷新任务跟踪()
            end
       elseif self.战斗类型==100014 then
         if 玩家数据[self.进入战斗玩家id].角色:取道具格子()==0 then
           常规提示(self.进入战斗玩家id,"#Y/你的包裹已经满了，无法获得情报")
          elseif 取随机数()<=50 then
           玩家数据[self.进入战斗玩家id].道具:给予道具(self.进入战斗玩家id,"情报")
           常规提示(self.进入战斗玩家id,"#Y/你得到了#R/情报")
           任务数据[self.任务id].情报=true
           玩家数据[self.进入战斗玩家id].角色:刷新任务跟踪()
           end
       elseif self.战斗类型==100015 then
          任务数据[self.任务id].巡逻=任务数据[self.任务id].巡逻+1
          if 任务数据[self.任务id].巡逻==2 then
            任务处理类:完成门派任务(self.进入战斗玩家id,2)
          else
            常规提示(self.进入战斗玩家id,"#Y/换个地方我继续捣乱，嘿嘿！")
          end
        elseif self.战斗类型==100016 then
           地图处理类:删除单位(任务数据[self.任务id].地图编号,任务数据[self.任务id].单位编号)
           任务处理类:完成门派任务(self.进入战斗玩家id,5)
        elseif self.战斗类型==100017 then
          地图处理类:删除单位(任务数据[self.任务id].地图编号,任务数据[self.任务id].单位编号)
          if self.同门死亡 then
            常规提示(self.进入战斗玩家id,"#Y/你的师门援助任务失败了")
            玩家数据[self.进入战斗玩家id].角色:取消任务(self.任务id)
            任务数据[self.任务id]=nil
            玩家数据[self.进入战斗玩家id].角色.数据.师门次数=0
          else
            任务处理类:完成门派任务(self.进入战斗玩家id,6)
          end
       elseif self.战斗类型==100018 then
         地图处理类:删除单位(任务数据[self.任务id].地图编号,任务数据[self.任务id].单位编号)
         if 任务数据[self.任务id].乾坤袋 then
        else
            local xy=地图处理类.地图坐标[任务数据[self.任务id].地图编号]:取随机点()
            任务数据[self.任务id].x,任务数据[self.任务id].y=xy.x,xy.y
            玩家数据[self.进入战斗玩家id].角色:刷新任务跟踪()
            地图处理类:添加单位(self.任务id)
          end
        elseif self.战斗类型==100019 or self.战斗类型==100020 or self.战斗类型==100071 or self.战斗类型==100072 or self.战斗类型==100073 or self.战斗类型==100074 or self.战斗类型==100075 or self.战斗类型==100076 or self.战斗类型==100077 or self.战斗类型==100021 or self.战斗类型==100022 or self.战斗类型==100024 or self.战斗类型==100026 or self.战斗类型==100027 then
          if self.战斗类型==100026 then
            玩家数据[self.进入战斗玩家id].角色:取消任务(self.任务id)
            玩家数据[self.进入战斗玩家id].角色:刷新任务跟踪()
          end
         地图处理类:删除单位(任务数据[self.任务id].地图编号,任务数据[self.任务id].单位编号)
         任务数据[self.任务id]=nil
        elseif self.战斗类型==100028 then
         地图处理类:删除单位(任务数据[self.任务id].地图编号,任务数据[self.任务id].单位编号)
         local 副本id=任务数据[self.任务id].副本id
         任务数据[self.任务id]=nil
         副本数据.乌鸡国.进行[副本id].数量=副本数据.乌鸡国.进行[副本id].数量-1
          for n=1,#队伍数据[玩家数据[self.进入战斗玩家id].队伍].成员数据 do
            玩家数据[队伍数据[玩家数据[self.进入战斗玩家id].队伍].成员数据[n]].角色:刷新任务跟踪()
          end
          if 副本数据.乌鸡国.进行[副本id].数量<=0 then
            副本数据.乌鸡国.进行[副本id].进程=2
            任务处理类:设置乌鸡国副本(副本id)
            for n=1,#队伍数据[玩家数据[self.进入战斗玩家id].队伍].成员数据 do
              if 队伍处理类:取是否助战(玩家数据[self.进入战斗玩家id].队伍,n) == 0 then
                常规提示(队伍数据[玩家数据[self.进入战斗玩家id].队伍].成员数据[n],"#Y您的副本进度已经更新")
                玩家数据[队伍数据[玩家数据[self.进入战斗玩家id].队伍].成员数据[n]].角色:刷新任务跟踪()
              end
            end
          end
        elseif self.战斗类型==100029 then
          地图处理类:删除单位(任务数据[self.任务id].地图编号,任务数据[self.任务id].单位编号)
          local 副本id=任务数据[self.任务id].副本id
          副本数据.乌鸡国.进行[副本id].序列[任务数据[self.任务id].序列]=true
          任务数据[self.任务id]=nil
          local 通过=0
          for n=1,3 do
            if  副本数据.乌鸡国.进行[副本id].序列[n] then 通过=通过+1 end
          end
          for n=1,#队伍数据[玩家数据[self.进入战斗玩家id].队伍].成员数据 do
            玩家数据[队伍数据[玩家数据[self.进入战斗玩家id].队伍].成员数据[n]].角色:刷新任务跟踪()
          end
          if 通过>=3 then
            副本数据.乌鸡国.进行[副本id].进程=4
            任务处理类:设置乌鸡国副本(副本id)
            for n=1,#队伍数据[玩家数据[self.进入战斗玩家id].队伍].成员数据 do
              if 队伍处理类:取是否助战(玩家数据[self.进入战斗玩家id].队伍,n) == 0 then
                常规提示(队伍数据[玩家数据[self.进入战斗玩家id].队伍].成员数据[n],"#Y您的副本进度已经更新")
                玩家数据[队伍数据[玩家数据[self.进入战斗玩家id].队伍].成员数据[n]].角色:刷新任务跟踪()
              end
            end
          end
        elseif self.战斗类型==100030 then
          地图处理类:删除单位(任务数据[self.任务id].地图编号,任务数据[self.任务id].单位编号)
          local 副本id=任务数据[self.任务id].副本id
          任务数据[self.任务id]=nil
          副本数据.乌鸡国.进行[副本id].数量=副本数据.乌鸡国.进行[副本id].数量-1
          for n=1,#队伍数据[玩家数据[self.进入战斗玩家id].队伍].成员数据 do
            玩家数据[队伍数据[玩家数据[self.进入战斗玩家id].队伍].成员数据[n]].角色:刷新任务跟踪()
          end
          if 副本数据.乌鸡国.进行[副本id].数量<=0 then
            副本数据.乌鸡国.进行[副本id].进程=5
            任务处理类:设置乌鸡国副本(副本id)
            for n=1,#队伍数据[玩家数据[self.进入战斗玩家id].队伍].成员数据 do
              if 队伍处理类:取是否助战(玩家数据[self.进入战斗玩家id].队伍,n) == 0 then
                常规提示(队伍数据[玩家数据[self.进入战斗玩家id].队伍].成员数据[n],"#Y您的副本进度已经更新")
                玩家数据[队伍数据[玩家数据[self.进入战斗玩家id].队伍].成员数据[n]].角色:刷新任务跟踪()
              end
            end
          end
        elseif self.战斗类型==100031 then
          地图处理类:删除单位(任务数据[self.任务id].地图编号,任务数据[self.任务id].单位编号)
          local 副本id=任务数据[self.任务id].副本id
          if 任务数据[self.任务id].真假 then
            for n=1,#队伍数据[玩家数据[self.进入战斗玩家id].队伍].成员数据 do
              if 队伍处理类:取是否助战(玩家数据[self.进入战斗玩家id].队伍,n) == 0 then
                if 玩家数据[队伍数据[玩家数据[self.进入战斗玩家id].队伍].成员数据[n]].角色.数据.副本积分==nil then
                  玩家数据[队伍数据[玩家数据[self.进入战斗玩家id].队伍].成员数据[n]].角色.数据.副本积分=0
                end
                玩家数据[队伍数据[玩家数据[self.进入战斗玩家id].队伍].成员数据[n]].角色.数据.副本积分=玩家数据[队伍数据[玩家数据[self.进入战斗玩家id].队伍].成员数据[n]].角色.数据.副本积分+5
                常规提示(队伍数据[玩家数据[self.进入战斗玩家id].队伍].成员数据[n],"#Y恭喜你完成了乌鸡国副本获得5点副本积分")
                玩家数据[队伍数据[玩家数据[self.进入战斗玩家id].队伍].成员数据[n]].角色:取消任务(玩家数据[队伍数据[玩家数据[self.进入战斗玩家id].队伍].成员数据[n]].角色:取任务(120))
                副本数据.乌鸡国.完成[队伍数据[玩家数据[self.进入战斗玩家id].队伍].成员数据[n]]=true
                local id=队伍数据[玩家数据[self.进入战斗玩家id].队伍].成员数据[n]
                local 奖励参数=取随机数()
                if 活跃数据[id]==nil then
                  活跃数据[id]={活跃度=0,领取100活跃=false,领取200活跃=false,领取300活跃=false,领取400活跃=false,领取500活跃=false,师门次数=20,官职次数=30,鬼怪次数=25,封妖次数=3,游泳次数=1,镖王次数=1,押镖次数=50,水果次数=25,天庭叛逆次数=25,十二星宿次数=5,门派闯关次数=1,地煞星次数=5,天罡星次数=5,飞贼次数=5,知了先锋=20,小知了王=20,知了王=10,世界BOSS次数=2,抓鬼次数=50,初出江湖次数=20,帮派青龙次数=100,帮派玄武次数=100,妖王次数=3}
                end
                活跃数据[id].活跃度=活跃数据[id].活跃度+50
                玩家数据[id].角色.数据.累积活跃.当前积分=玩家数据[id].角色.数据.累积活跃.当前积分+活跃数据[id].活跃度
                玩家数据[id].角色.数据.累积活跃.总积分=玩家数据[id].角色.数据.累积活跃.总积分+活跃数据[id].活跃度
                if 奖励参数<=10 then
                  local 名称="高级魔兽要诀"
                  玩家数据[id].道具:给予道具(id,名称)
                  常规提示(id,"#Y/你获得了"..名称)
                  广播消息({内容=format("#S(副本-乌鸡国)#R/%s#Y在#R乌鸡国#Y副本中成功解救出国王，因此获得了其奖励的#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,名称),频道="xt"})
                elseif 奖励参数<=15 then
                  local 名称="九转金丹"
                  玩家数据[id].道具:给予道具(id,名称,1,50)
                  常规提示(id,"#Y/你获得了"..名称)
                  广播消息({内容=format("#S(副本-乌鸡国)#R/%s#Y在#R乌鸡国#Y副本中成功解救出国王，因此获得了其奖励的#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,名称),频道="xt"})
                elseif 奖励参数<=40 then
                  local 名称="金银锦盒"
                  玩家数据[id].道具:给予道具(id,名称,1)
                  常规提示(id,"#Y/你获得了"..名称)
                  广播消息({内容=format("#S(副本-乌鸡国)#R/%s#Y在#R乌鸡国#Y副本中成功解救出国王，因此获得了其奖励的#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,名称),频道="xt"})
                elseif 奖励参数<=50 then
                  local 名称="修炼果"
                  玩家数据[id].道具:给予道具(id,名称,2)
                  常规提示(id,"#Y/你获得了"..名称)
                  广播消息({内容=format("#S(副本-乌鸡国)#R/%s#Y在#R乌鸡国#Y副本中成功解救出国王，因此获得了其奖励的#G/%s*2#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,名称),频道="xt"})
                elseif 奖励参数<=60 then
                  local 名称=取宝石()
                  玩家数据[id].道具:给予道具(id,名称,取随机数(2,3))
                  常规提示(id,"#Y/你获得了"..名称)
                  广播消息({内容=format("#S(副本-乌鸡国)#R/%s#Y在#R乌鸡国#Y副本中成功解救出国王，因此获得了其奖励的#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,名称),频道="xt"})
                elseif 奖励参数<=70 then
                  local 名称="星辉石"
                  玩家数据[id].道具:给予道具(id,名称,取随机数(1,2))
                  常规提示(id,"#Y/你获得了"..名称)
                  广播消息({内容=format("#S(副本-乌鸡国)#R/%s#Y在#R乌鸡国#Y副本中成功解救出国王，因此获得了其奖励的#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,名称),频道="xt"})
                elseif 奖励参数<=90 then
                  local 名称="仙玉"
                  添加仙玉(取随机数(5,15),玩家数据[id].账号,id,"乌鸡国副本")
                  常规提示(id,"#Y/你获得了"..名称)
                else
                  local 名称=取强化石()
                  玩家数据[id].道具:给予道具(id,名称,10)
                  常规提示(id,"#Y/你获得了"..名称)
                  广播消息({内容=format("#S(副本-乌鸡国)#R/%s#Y在#R乌鸡国#Y副本中成功解救出国王，因此获得了其奖励的#G/%s*10#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,名称),频道="xt"})
                end
                if 取随机数(1,100)>=70 then
                  任务处理类:添加点化任务(id)
                  常规提示(id,"#Y/五行大师好像找你有事，去找他看看，说不定有意外的惊喜！")
                end
              end
            end
            副本数据.乌鸡国.进行[副本id]=nil
          end
    elseif self.战斗类型==100025 then
      if 任务数据[self.任务id].序列==6 then
        任务处理类:完成镖王活动(self.任务id,self.进入战斗玩家id)
      else
        任务数据[self.任务id].序列=任务数据[self.任务id].序列+1
        任务数据[self.任务id].地图=镖王数据[任务数据[self.任务id].序列].地图
        任务数据[self.任务id].y=镖王数据[任务数据[self.任务id].序列].y
        任务数据[self.任务id].x=镖王数据[任务数据[self.任务id].序列].x
        任务数据[self.任务id].地图名称=取地图名称(镖王数据[任务数据[self.任务id].序列].地图)
        table.remove(任务数据[self.任务id].完成,任务数据[self.任务id].战斗序列)
        for n=1,#队伍数据[玩家数据[self.进入战斗玩家id].队伍].成员数据 do
          常规提示(队伍数据[玩家数据[self.进入战斗玩家id].队伍].成员数据[n],"#Y恭喜你们通过了本镖师考验，请立即前往下一个镖师处")
          玩家数据[队伍数据[玩家数据[self.进入战斗玩家id].队伍].成员数据[n]].角色:刷新任务跟踪()
        end
      end
    elseif self.战斗类型==100032 or self.战斗类型==100033 then
      地图处理类:删除单位(任务数据[self.任务id].地图编号,任务数据[self.任务id].单位编号)
      任务数据[self.任务id]=nil
    elseif self.战斗类型==100034 then
      任务数据[self.任务id].巡逻=任务数据[self.任务id].巡逻+1
      if 任务数据[self.任务id].巡逻==2 then
         任务处理类:完成青龙任务(self.任务id,self.进入战斗玩家id,4)
      else
         常规提示(self.进入战斗玩家id,"#Y/换个地方我继续捣乱，嘿嘿！")
      end
    elseif self.战斗类型==100035 then
      任务数据[self.任务id].巡逻=任务数据[self.任务id].巡逻+1
      if 任务数据[self.任务id].巡逻==2 then
         任务处理类:完成玄武任务(self.任务id,id组,4)
      else
         常规提示(self.进入战斗玩家id,"#Y/换个地方我继续捣乱，嘿嘿！")
      end
    elseif self.战斗类型==100036 then
      任务处理类:完成冠状病毒(self.任务id,id组)
    elseif self.战斗类型==100037 then
      任务处理类:完成地煞星任务(self.任务id,id组)
    elseif self.战斗类型==100038 then
      任务处理类:完成知了先锋任务(self.任务id,id组)
    elseif self.战斗类型==100039 then
      任务处理类:完成小知了王任务(self.任务id,id组)
    elseif self.战斗类型==100040 then
      任务数据[self.任务id].分类=5
      发送数据(玩家数据[胜利id].连接id,1501,{名称="大力神灵",模型="风伯",对话=format("跟你开了个小小的玩笑，千里眼刚已经找到相关的消息了，少侠可以去找他问问"),选项={"我这就去"}})
    elseif self.战斗类型==100041 then
      任务数据[self.任务id].分类=8
      发送数据(玩家数据[胜利id].连接id,1501,{名称="妖魔亲信",模型="蝴蝶仙子",对话=format("少侠饶命！少侠饶命！我这就送少侠去找我们老大"),选项={"速速送我过去","待我准备准备"}})
    elseif self.战斗类型==100042 then
      任务数据[self.任务id].分类=9
      发送数据(玩家数据[胜利id].连接id,1501,{名称="蜃妖元神",模型="炎魔神",对话=format("少侠饶命！少侠饶命！其实天马早就跑了，具体跑哪去了，我也不知道"),选项={"再敢出来吓唬人，看我不收了你"}})
    elseif self.战斗类型==100043 then
      任务数据[self.任务id].分类=13
      发送数据(玩家数据[胜利id].连接id,1501,{名称="周猎户",模型="男人_兰虎",对话=format("少侠饶命！少侠饶命！我这就把马儿还回去"),选项={"终于找到马儿，可以去找百兽王复命了"}})
    elseif self.战斗类型==100044 then
      if 任务数据[self.任务id].分类==4 and self.任务id==玩家数据[胜利id].角色:取任务(308) then
        任务处理类:完成法宝任务(self.任务id,胜利id)
      end
    elseif self.战斗类型==100045 then
      任务处理类:完成法宝内丹任务(self.任务id,胜利id)
    elseif self.战斗类型==100046 then
      任务数据[self.任务id].进度=任务数据[self.任务id].进度+1
      添加最后对话(胜利id,format("少侠饶命！我再也不敢了"))
      地图处理类:删除单位(任务数据[self.任务id].地图编号,任务数据[self.任务id].单位编号)
    elseif self.战斗类型==100047 then
      任务数据[self.任务id].进度=任务数据[self.任务id].进度+1
      地图处理类:删除单位(任务数据[self.任务id].地图编号,任务数据[self.任务id].单位编号)
    elseif self.战斗类型==100048 then
      任务数据[self.任务id].征求意见.牛魔王=true
      常规提示(胜利id,"获得牛魔王的同意")
      发送数据(玩家数据[胜利id].连接id,1501,{名称="牛魔王",模型="牛魔王",对话=format("精彩精彩！（鼓蹄子）心情好多了，趁俺高兴，同意了。")})
      玩家数据[胜利id].角色:刷新任务跟踪()
    elseif self.战斗类型==100049 then
      任务数据[self.任务id].进程=12
      常规提示(胜利id,"获得了不死壤")
      添加最后对话(胜利id,format("少侠功夫了得，这里是不死壤，拿去吧！"))
      玩家数据[胜利id].角色:刷新任务跟踪()
    elseif self.战斗类型==100054 then
      if 玩家数据[胜利id].队伍==0 or 玩家数据[胜利id].队伍==胜利id then
        if 剧情数据[胜利id]~=nil and 剧情数据[胜利id].飞升~=nil and 剧情数据[胜利id].飞升.完成==false and 任务数据[self.任务id]~=0 then
          任务数据[self.任务id].进程=13
          剧情数据[胜利id].飞升.完成=true
          玩家数据[胜利id].角色:刷新任务跟踪()
          添加最后对话(胜利id,format("不错，你已经有资格入于化境了，去找吴刚吧！"))
        end
      end
    elseif self.战斗类型==200004 then
      游戏活动类:比武大会战斗处理(胜利id,失败id)
    elseif self.战斗类型==200005 then
      游戏活动类:首席争霸战斗处理(胜利id,失败id)
    elseif self.战斗类型==200006 then
      游戏活动类:帮派竞赛处理(胜利id,失败id)
    elseif self.战斗类型==200008 then
      if 玩家数据[胜利id].队伍 == 0 or 玩家数据[胜利id].队长 then
        玩家数据[胜利id].角色.数据.强P开关 = nil
        发送数据(玩家数据[胜利id].连接id,94)
        地图处理类:更改强PK(胜利id)
        if 玩家数据[胜利id].角色.数据.PK开关 ~= nil then
          发送数据(玩家数据[胜利id].连接id,93,{开关=true})
          地图处理类:更改PK(胜利id,true)
        end
      end
    elseif self.战斗类型==100055 then
      if 胜利id==self.进入战斗玩家id then
          任务处理类:完成生死劫挑战(胜利id)
      end
    elseif self.战斗类型==100056 then
      任务处理类:完成天罡星任务(self.任务id,id组)
    elseif self.战斗类型==100057 then
      任务处理类:完成天蝎座(self.任务id,id组)
    elseif self.战斗类型==100058 then
      任务处理类:完成射手座(self.任务id,id组)
    elseif self.战斗类型==100059 then
      任务处理类:完成摩羯座(self.任务id,id组)
    elseif self.战斗类型==100060 then
      任务处理类:完成新服福利BOSS(self.任务id,id组)
    elseif self.战斗类型==100062 then--帮派护法
      local 编号=玩家数据[胜利id].角色.数据.帮派数据.编号
      玩家数据[胜利id].角色.数据.帮贡=玩家数据[胜利id].角色.数据.帮贡+200
      帮派数据[编号].成员数据[胜利id].帮贡.上限=帮派数据[编号].成员数据[胜利id].帮贡.上限+200
      帮派数据[编号].成员数据[胜利id].帮贡.当前=帮派数据[编号].成员数据[胜利id].帮贡.当前+200
      任务数据[self.任务id].战斗=nil
      if 帮派数据[编号].帮战夺旗次数==nil then
        帮派数据[编号].帮战夺旗次数=0
      end
      if 玩家数据[胜利id].队长 then
        玩家数据[胜利id].角色.数据.帮战夺旗=1
        地图处理类:当前消息广播1(玩家数据[胜利id].角色.数据.地图数据.编号,format("#G神勇无比，玩家#R%s#G带领队伍夺旗了对方帮派的战旗#G大家帮忙去护送他哦，对战帮的玩家可组织队伍去阻击拿回战旗！！！",玩家数据[胜利id].角色.数据.名称))
      end
      常规提示(胜利id,"#Y/恭喜你夺得了对方帮派的旗子，赶快交给本帮的裁判吧！")
    elseif self.战斗类型==100063 then
      任务处理类:完成水瓶座(self.任务id,id组)
    elseif self.战斗类型==100064 then
      任务处理类:完成白羊座(self.任务id,id组)
    elseif self.战斗类型==100065 then
      任务处理类:完成金牛座(self.任务id,id组)
    elseif self.战斗类型==100066 then
      local 副本id=任务数据[self.任务id].副本id
      副本数据.车迟斗法.进行[副本id].数量=副本数据.车迟斗法.进行[副本id].数量-1
      for n=1,#队伍数据[玩家数据[self.进入战斗玩家id].队伍].成员数据 do
        if 队伍处理类:取是否助战(玩家数据[self.进入战斗玩家id].队伍,n) == 0 then
          玩家数据[队伍数据[玩家数据[self.进入战斗玩家id].队伍].成员数据[n]].角色:刷新任务跟踪()
          local id=队伍数据[玩家数据[self.进入战斗玩家id].队伍].成员数据[n]
          local 奖励参数=取随机数()
          if 风雨无言定制 then
            if 奖励参数<=40 then
            elseif 奖励参数<=50 then
              local 名称="金银锦盒"
              玩家数据[id].道具:给予道具(id,名称,1)
              常规提示(id,"#Y/你获得了"..名称)
              广播消息({内容=format("#S(副本-车迟斗法)#R/%s#Y在#R车迟斗法#Y副本中表现卓越，最终战胜了#R%s#Y，因此获得了三清奖励的#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,任务数据[self.任务id].名称,名称),频道="xt"})
            elseif 奖励参数<=60 then
              local 名称="九转金丹"
              玩家数据[id].道具:给予道具(id,名称,1,50)
              常规提示(id,"#Y/你获得了"..名称)
              广播消息({内容=format("#S(副本-车迟斗法)#R/%s#Y在#R车迟斗法#Y副本中表现卓越，最终战胜了#R%s#Y，因此获得了三清奖励的#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,任务数据[self.任务id].名称,名称),频道="xt"})
            elseif 奖励参数<=70 then
              local 名称="修炼果"
              玩家数据[id].道具:给予道具(id,名称,2)
              常规提示(id,"#Y/你获得了"..名称)
              广播消息({内容=format("#S(副本-车迟斗法)#R/%s#Y在#R车迟斗法#Y副本中表现卓越，最终战胜了#R%s#Y，因此获得了三清奖励的#G/%s*2#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,任务数据[self.任务id].名称,名称),频道="xt"})
            elseif 奖励参数<=80 then
              local 名称=取宝石()
              玩家数据[id].道具:给予道具(id,名称,取随机数(2,3))
              常规提示(id,"#Y/你获得了"..名称)
              广播消息({内容=format("#S(副本-车迟斗法)#R/%s#Y在#R车迟斗法#Y副本中表现卓越，最终战胜了#R%s#Y，因此获得了三清奖励的#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,任务数据[self.任务id].名称,名称),频道="xt"})
            elseif 奖励参数<=90 then
              local 名称=取强化石()
              玩家数据[id].道具:给予道具(id,名称,10)
              常规提示(id,"#Y/你获得了"..名称)
              广播消息({内容=format("#S(副本-车迟斗法)#R/%s#Y在#R车迟斗法#Y副本中表现卓越，最终战胜了#R%s#Y，因此获得了三清奖励的#G/%s*10#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,任务数据[self.任务id].名称,名称),频道="xt"})
            end
          else
            if 奖励参数<=15 then
              local 名称="金银锦盒"
              玩家数据[id].道具:给予道具(id,名称,1)
              常规提示(id,"#Y/你获得了"..名称)
              广播消息({内容=format("#S(副本-车迟斗法)#R/%s#Y在#R车迟斗法#Y副本中表现卓越，最终战胜了#R%s#Y，因此获得了三清奖励的#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,任务数据[self.任务id].名称,名称),频道="xt"})
            -- elseif 奖励参数<=20 then
            --   local 名称="修炼果"
            --   玩家数据[id].道具:给予道具(id,名称,1)
            --   常规提示(id,"#Y/你获得了"..名称)
            --   广播消息({内容=format("#S(副本-车迟斗法)#R/%s#Y在#R车迟斗法#Y副本中表现卓越，最终战胜了#R%s#Y，因此获得了三清奖励的#G/%s*2#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,任务数据[self.任务id].名称,名称),频道="xt"})

            -- elseif 奖励参数<=25 then
            --   local 名称="九转金丹"
            --   玩家数据[id].道具:给予道具(id,名称,1,50)
            --   常规提示(id,"#Y/你获得了"..名称)
            --   广播消息({内容=format("#S(副本-车迟斗法)#R/%s#Y在#R车迟斗法#Y副本中表现卓越，最终战胜了#R%s#Y，因此获得了三清奖励的#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,任务数据[self.任务id].名称,名称),频道="xt"})
            elseif 奖励参数<=90 then
              local 名称=取宝石()
              玩家数据[id].道具:给予道具(id,名称,取随机数(2,3))
              常规提示(id,"#Y/你获得了"..名称)
              广播消息({内容=format("#S(副本-车迟斗法)#R/%s#Y在#R车迟斗法#Y副本中表现卓越，最终战胜了#R%s#Y，因此获得了三清奖励的#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,任务数据[self.任务id].名称,名称),频道="xt"})
            else
              local 名称=取强化石()
              玩家数据[id].道具:给予道具(id,名称,10)
              常规提示(id,"#Y/你获得了"..名称)
              广播消息({内容=format("#S(副本-车迟斗法)#R/%s#Y在#R车迟斗法#Y副本中表现卓越，最终战胜了#R%s#Y，因此获得了三清奖励的#G/%s*10#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,任务数据[self.任务id].名称,名称),频道="xt"})
            end
          end
        end
      end
      地图处理类:删除单位(任务数据[self.任务id].地图编号,任务数据[self.任务id].单位编号)
      任务数据[self.任务id]=nil
    elseif self.战斗类型==100067 then
      添加最后对话(胜利id,format("哎哟别打了，我不敢搞事了！"))
      local 副本id=任务数据[self.任务id].副本id
      副本数据.车迟斗法.进行[副本id].序列[任务数据[self.任务id].序列]=true
      local 通过=0
      for n=1,3 do
        if  副本数据.车迟斗法.进行[副本id].序列[n] then 通过=通过+1 end
      end
      for n=1,#队伍数据[玩家数据[self.进入战斗玩家id].队伍].成员数据 do
        玩家数据[队伍数据[玩家数据[self.进入战斗玩家id].队伍].成员数据[n]].角色:刷新任务跟踪()
      end
      if 通过>=3 then
        副本数据.车迟斗法.进行[副本id].进程=5
        任务处理类:设置车迟斗法副本(副本id)
        for n=1,#队伍数据[玩家数据[self.进入战斗玩家id].队伍].成员数据 do
          if 队伍处理类:取是否助战(玩家数据[self.进入战斗玩家id].队伍,n) == 0 then
            常规提示(队伍数据[玩家数据[self.进入战斗玩家id].队伍].成员数据[n],"#Y您的副本进度已经更新")
            玩家数据[队伍数据[玩家数据[self.进入战斗玩家id].队伍].成员数据[n]].角色:刷新任务跟踪()
            local id=队伍数据[玩家数据[self.进入战斗玩家id].队伍].成员数据[n]
            local 奖励参数=取随机数()
            if 风雨无言定制 then
              if 奖励参数<=40 then
              elseif 奖励参数<=50 then
                local 名称="金银锦盒"
                玩家数据[id].道具:给予道具(id,名称,1)
                常规提示(id,"#Y/你获得了"..名称)
                广播消息({内容=format("#S(副本-车迟斗法)#R/%s#Y在#R车迟斗法#Y副本中表现卓越，最终战胜了#R%s#Y，因此获得了三清奖励的#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,任务数据[self.任务id].名称,名称),频道="xt"})
              elseif 奖励参数<=55 then
                local 名称="九转金丹"
                玩家数据[id].道具:给予道具(id,名称,1,50)
                常规提示(id,"#Y/你获得了"..名称)
                广播消息({内容=format("#S(副本-车迟斗法)#R/%s#Y在#R车迟斗法#Y副本中表现卓越，最终战胜了#R%s#Y，因此获得了三清奖励的#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,任务数据[self.任务id].名称,名称),频道="xt"})
              elseif 奖励参数<=60 then
                local 名称="修炼果"
                玩家数据[id].道具:给予道具(id,名称,2)
                常规提示(id,"#Y/你获得了"..名称)
                广播消息({内容=format("#S(副本-车迟斗法)#R/%s#Y在#R车迟斗法#Y副本中表现卓越，最终战胜了#R%s#Y，因此获得了三清奖励的#G/%s*2#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,任务数据[self.任务id].名称,名称),频道="xt"})
              elseif 奖励参数<=65 then
                local 名称=取宝石()
                玩家数据[id].道具:给予道具(id,名称,取随机数(2,3))
                常规提示(id,"#Y/你获得了"..名称)
                广播消息({内容=format("#S(副本-车迟斗法)#R/%s#Y在#R车迟斗法#Y副本中表现卓越，最终战胜了#R%s#Y，因此获得了三清奖励的#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,任务数据[self.任务id].名称,名称),频道="xt"})
              elseif 奖励参数<=70 then
                local 名称="初级神魂丹"
                玩家数据[id].道具:给予道具(id,名称,1)
                常规提示(id,"#Y/你获得了"..名称)
                广播消息({内容=format("#S(副本-车迟斗法)#R/%s#Y在#R车迟斗法#Y副本中表现卓越，最终战胜了#R%s#Y，因此获得了三清奖励的#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,任务数据[self.任务id].名称,名称),频道="xt"})
              elseif 奖励参数<=80 then
                local 名称=取强化石()
                玩家数据[id].道具:给予道具(id,名称,10)
                常规提示(id,"#Y/你获得了"..名称)
                广播消息({内容=format("#S(副本-车迟斗法)#R/%s#Y在#R车迟斗法#Y副本中表现卓越，最终战胜了#R%s#Y，因此获得了三清奖励的#G/%s*10#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,任务数据[self.任务id].名称,名称),频道="xt"})
              end
            else
              if 奖励参数<=15 then
                local 名称="金银锦盒"
                玩家数据[id].道具:给予道具(id,名称,1)
                常规提示(id,"#Y/你获得了"..名称)
                广播消息({内容=format("#S(副本-车迟斗法)#R/%s#Y在#R车迟斗法#Y副本中表现卓越，最终战胜了#R%s#Y，因此获得了三清奖励的#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,任务数据[self.任务id].名称,名称),频道="xt"})
              -- elseif 奖励参数<=20 then
              --   local 名称="九转金丹"
              --   玩家数据[id].道具:给予道具(id,名称,1,50)
              --   常规提示(id,"#Y/你获得了"..名称)
              --   广播消息({内容=format("#S(副本-车迟斗法)#R/%s#Y在#R车迟斗法#Y副本中表现卓越，最终战胜了#R%s#Y，因此获得了三清奖励的#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,任务数据[self.任务id].名称,名称),频道="xt"})
              -- elseif 奖励参数<=25 then
              --   local 名称="修炼果"
              --   玩家数据[id].道具:给予道具(id,名称,1)
              --   常规提示(id,"#Y/你获得了"..名称)
              --   广播消息({内容=format("#S(副本-车迟斗法)#R/%s#Y在#R车迟斗法#Y副本中表现卓越，最终战胜了#R%s#Y，因此获得了三清奖励的#G/%s*2#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,任务数据[self.任务id].名称,名称),频道="xt"})
              elseif 奖励参数<=60 then
                local 名称=取宝石()
                玩家数据[id].道具:给予道具(id,名称,取随机数(2,3))
                常规提示(id,"#Y/你获得了"..名称)
                广播消息({内容=format("#S(副本-车迟斗法)#R/%s#Y在#R车迟斗法#Y副本中表现卓越，最终战胜了#R%s#Y，因此获得了三清奖励的#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,任务数据[self.任务id].名称,名称),频道="xt"})
              elseif 奖励参数<=70 then
                local 名称="初级神魂丹"
                玩家数据[id].道具:给予道具(id,名称,1)
                常规提示(id,"#Y/你获得了"..名称)
                广播消息({内容=format("#S(副本-车迟斗法)#R/%s#Y在#R车迟斗法#Y副本中表现卓越，最终战胜了#R%s#Y，因此获得了三清奖励的#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,任务数据[self.任务id].名称,名称),频道="xt"})
              else
                local 名称=取强化石()
                玩家数据[id].道具:给予道具(id,名称,10)
                常规提示(id,"#Y/你获得了"..名称)
                广播消息({内容=format("#S(副本-车迟斗法)#R/%s#Y在#R车迟斗法#Y副本中表现卓越，最终战胜了#R%s#Y，因此获得了三清奖励的#G/%s*10#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,任务数据[self.任务id].名称,名称),频道="xt"})
              end
            end
          end
        end
      end
      地图处理类:删除单位(任务数据[self.任务id].地图编号,任务数据[self.任务id].单位编号)
      任务数据[self.任务id]=nil
    elseif self.战斗类型==100068 then
      添加最后对话(胜利id,format("幸亏少侠帮忙，不然我们就促成大错了！！！"))
      local 副本id=任务数据[self.任务id].副本id
      副本数据.车迟斗法.进行[副本id].序列[任务数据[self.任务id].序列]=true
      local 通过=0
      for n=1,3 do
        if 副本数据.车迟斗法.进行[副本id].序列[n] then 通过=通过+1 end
      end
      for n=1,#队伍数据[玩家数据[self.进入战斗玩家id].队伍].成员数据 do
        玩家数据[队伍数据[玩家数据[self.进入战斗玩家id].队伍].成员数据[n]].角色:刷新任务跟踪()
      end
      if 通过>=3 then
        副本数据.车迟斗法.进行[副本id].进程=8
        任务处理类:设置车迟斗法副本(副本id)
        for n=1,#队伍数据[玩家数据[self.进入战斗玩家id].队伍].成员数据 do
          if 队伍处理类:取是否助战(玩家数据[self.进入战斗玩家id].队伍,n) == 0 then
            常规提示(队伍数据[玩家数据[self.进入战斗玩家id].队伍].成员数据[n],"#Y您的副本进度已经更新")
            玩家数据[队伍数据[玩家数据[self.进入战斗玩家id].队伍].成员数据[n]].角色:刷新任务跟踪()
            local id=队伍数据[玩家数据[self.进入战斗玩家id].队伍].成员数据[n]
            local 奖励参数=取随机数()
            if 风雨无言定制 then
              if 奖励参数<=40 then
              elseif 奖励参数<=45 then
                local 名称="高级魔兽要诀"
                玩家数据[id].道具:给予道具(id,名称)
                常规提示(id,"#Y/你获得了"..名称)
                广播消息({内容=format("#S(副本-车迟斗法)#R/%s#Y在#R车迟斗法#Y副本中表现卓越，最终战胜了#R%s#Y，因此获得了三清奖励的#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,任务数据[self.任务id].名称,名称),频道="xt"})
              elseif 奖励参数<=50 then
                local 名称="九转金丹"
                玩家数据[id].道具:给予道具(id,名称,1,50)
                常规提示(id,"#Y/你获得了"..名称)
                广播消息({内容=format("#S(副本-车迟斗法)#R/%s#Y在#R车迟斗法#Y副本中表现卓越，最终战胜了#R%s#Y，因此获得了三清奖励的#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,任务数据[self.任务id].名称,名称),频道="xt"})
              elseif 奖励参数<=55 then
                local 名称="修炼果"
                玩家数据[id].道具:给予道具(id,名称,2)
                常规提示(id,"#Y/你获得了"..名称)
                广播消息({内容=format("#S(副本-车迟斗法)#R/%s#Y在#R车迟斗法#Y副本中表现卓越，最终战胜了#R%s#Y，因此获得了三清奖励的#G/%s*2#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,任务数据[self.任务id].名称,名称),频道="xt"})
              elseif 奖励参数<=60 then
                local 名称=取宝石()
                玩家数据[id].道具:给予道具(id,名称,取随机数(2,3))
                常规提示(id,"#Y/你获得了"..名称)
                广播消息({内容=format("#S(副本-车迟斗法)#R/%s#Y在#R车迟斗法#Y副本中表现卓越，最终战胜了#R%s#Y，因此获得了三清奖励的#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,任务数据[self.任务id].名称,名称),频道="xt"})
              elseif 奖励参数<=65 then
                local 名称="初级神魂丹"
                玩家数据[id].道具:给予道具(id,名称,1)
                常规提示(id,"#Y/你获得了"..名称)
                广播消息({内容=format("#S(副本-车迟斗法)#R/%s#Y在#R车迟斗法#Y副本中表现卓越，最终战胜了#R%s#Y，因此获得了三清奖励的#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,任务数据[self.任务id].名称,名称),频道="xt"})
              elseif 奖励参数<=70 then
                local 名称="金银锦盒"
                玩家数据[id].道具:给予道具(id,名称,1)
                常规提示(id,"#Y/你获得了"..名称)
                广播消息({内容=format("#S(副本-车迟斗法)#R/%s#Y在#R车迟斗法#Y副本中表现卓越，最终战胜了#R%s#Y，因此获得了三清奖励的#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,任务数据[self.任务id].名称,名称),频道="xt"})
              elseif 奖励参数<=80 then
                local 名称=取强化石()
                玩家数据[id].道具:给予道具(id,名称,10)
                常规提示(id,"#Y/你获得了"..名称)
                广播消息({内容=format("#S(副本-车迟斗法)#R/%s#Y在#R车迟斗法#Y副本中表现卓越，最终战胜了#R%s#Y，因此获得了三清奖励的#G/%s*10#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,任务数据[self.任务id].名称,名称),频道="xt"})
              end
            else
              if 奖励参数<=15 then
                local 名称="高级魔兽要诀"
                玩家数据[id].道具:给予道具(id,名称)
                常规提示(id,"#Y/你获得了"..名称)
                广播消息({内容=format("#S(副本-车迟斗法)#R/%s#Y在#R车迟斗法#Y副本中表现卓越，最终战胜了#R%s#Y，因此获得了三清奖励的#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,任务数据[self.任务id].名称,名称),频道="xt"})
              -- elseif 奖励参数<=20 then
              --   local 名称="九转金丹"
              --   玩家数据[id].道具:给予道具(id,名称,1,50)
              --   常规提示(id,"#Y/你获得了"..名称)
              --   广播消息({内容=format("#S(副本-车迟斗法)#R/%s#Y在#R车迟斗法#Y副本中表现卓越，最终战胜了#R%s#Y，因此获得了三清奖励的#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,任务数据[self.任务id].名称,名称),频道="xt"})
              -- elseif 奖励参数<=25 then
              --   local 名称="修炼果"
              --   玩家数据[id].道具:给予道具(id,名称,1)
              --   常规提示(id,"#Y/你获得了"..名称)
              --   广播消息({内容=format("#S(副本-车迟斗法)#R/%s#Y在#R车迟斗法#Y副本中表现卓越，最终战胜了#R%s#Y，因此获得了三清奖励的#G/%s*2#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,任务数据[self.任务id].名称,名称),频道="xt"})
              elseif 奖励参数<=60 then
                local 名称=取宝石()
                玩家数据[id].道具:给予道具(id,名称,取随机数(2,3))
                常规提示(id,"#Y/你获得了"..名称)
                广播消息({内容=format("#S(副本-车迟斗法)#R/%s#Y在#R车迟斗法#Y副本中表现卓越，最终战胜了#R%s#Y，因此获得了三清奖励的#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,任务数据[self.任务id].名称,名称),频道="xt"})
              elseif 奖励参数<=70 then
                local 名称="初级神魂丹"
                玩家数据[id].道具:给予道具(id,名称,1)
                常规提示(id,"#Y/你获得了"..名称)
                广播消息({内容=format("#S(副本-车迟斗法)#R/%s#Y在#R车迟斗法#Y副本中表现卓越，最终战胜了#R%s#Y，因此获得了三清奖励的#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,任务数据[self.任务id].名称,名称),频道="xt"})
              elseif 奖励参数<=90 then
                local 名称="金银锦盒"
                玩家数据[id].道具:给予道具(id,名称,1)
                常规提示(id,"#Y/你获得了"..名称)
                广播消息({内容=format("#S(副本-车迟斗法)#R/%s#Y在#R车迟斗法#Y副本中表现卓越，最终战胜了#R%s#Y，因此获得了三清奖励的#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,任务数据[self.任务id].名称,名称),频道="xt"})
              else
                local 名称=取强化石()
                玩家数据[id].道具:给予道具(id,名称,10)
                常规提示(id,"#Y/你获得了"..名称)
                广播消息({内容=format("#S(副本-车迟斗法)#R/%s#Y在#R车迟斗法#Y副本中表现卓越，最终战胜了#R%s#Y，因此获得了三清奖励的#G/%s*10#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,任务数据[self.任务id].名称,名称),频道="xt"})
              end
            end
          end
        end
      end
      地图处理类:删除单位(任务数据[self.任务id].地图编号,任务数据[self.任务id].单位编号)
      任务数据[self.任务id]=nil
    elseif self.战斗类型==100069 then
      添加最后对话(胜利id,format("你输了，你先动的，先动的是王八！！！"))
      local 副本id=任务数据[self.任务id].副本id
      副本数据.车迟斗法.进行[副本id].序列[任务数据[self.任务id].序列]=true
      local 通过=0
      for n=1,3 do
        if 副本数据.车迟斗法.进行[副本id].序列[n] then 通过=通过+1 end
      end
      for n=1,#队伍数据[玩家数据[self.进入战斗玩家id].队伍].成员数据 do
        玩家数据[队伍数据[玩家数据[self.进入战斗玩家id].队伍].成员数据[n]].角色:刷新任务跟踪()
      end
      if 通过>=3 then
        副本数据.车迟斗法.进行[副本id].进程=8
        任务处理类:设置车迟斗法副本(副本id)
        for n=1,#队伍数据[玩家数据[self.进入战斗玩家id].队伍].成员数据 do
          if 队伍处理类:取是否助战(玩家数据[self.进入战斗玩家id].队伍,n) == 0 then
            常规提示(队伍数据[玩家数据[self.进入战斗玩家id].队伍].成员数据[n],"#Y您的副本进度已经更新")
            玩家数据[队伍数据[玩家数据[self.进入战斗玩家id].队伍].成员数据[n]].角色:刷新任务跟踪()
            local id=队伍数据[玩家数据[self.进入战斗玩家id].队伍].成员数据[n]
            local 奖励参数=取随机数()
            if 风雨无言定制 then
              if 奖励参数<=40 then
              elseif 奖励参数<=45 then
                local 名称="高级魔兽要诀"
                玩家数据[id].道具:给予道具(id,名称)
                常规提示(id,"#Y/你获得了"..名称)
                广播消息({内容=format("#S(副本-车迟斗法)#R/%s#Y在#R车迟斗法#Y副本中表现卓越，最终战胜了#R%s#Y，因此获得了三清奖励的#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,任务数据[self.任务id].名称,名称),频道="xt"})
              elseif 奖励参数<=50 then
               local 名称="九转金丹"
                玩家数据[id].道具:给予道具(id,名称,1,50)
                常规提示(id,"#Y/你获得了"..名称)
                广播消息({内容=format("#S(副本-车迟斗法)#R/%s#Y在#R车迟斗法#Y副本中表现卓越，最终战胜了#R%s#Y，因此获得了三清奖励的#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,任务数据[self.任务id].名称,名称),频道="xt"})
              elseif 奖励参数<=55 then
                local 名称="修炼果"
                玩家数据[id].道具:给予道具(id,名称,2)
                常规提示(id,"#Y/你获得了"..名称)
                广播消息({内容=format("#S(副本-车迟斗法)#R/%s#Y在#R车迟斗法#Y副本中表现卓越，最终战胜了#R%s#Y，因此获得了三清奖励的#G/%s*2#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,任务数据[self.任务id].名称,名称),频道="xt"})
              elseif 奖励参数<=60 then
                local 名称=取宝石()
                玩家数据[id].道具:给予道具(id,名称,取随机数(2,3))
                常规提示(id,"#Y/你获得了"..名称)
                广播消息({内容=format("#S(副本-车迟斗法)#R/%s#Y在#R车迟斗法#Y副本中表现卓越，最终战胜了#R%s#Y，因此获得了三清奖励的#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,任务数据[self.任务id].名称,名称),频道="xt"})
              elseif 奖励参数<=65 then
                local 名称="初级神魂丹"
                玩家数据[id].道具:给予道具(id,名称,1)
                常规提示(id,"#Y/你获得了"..名称)
                广播消息({内容=format("#S(副本-车迟斗法)#R/%s#Y在#R车迟斗法#Y副本中表现卓越，最终战胜了#R%s#Y，因此获得了三清奖励的#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,任务数据[self.任务id].名称,名称),频道="xt"})
              elseif 奖励参数<=70 then
                local 名称="金银锦盒"
                玩家数据[id].道具:给予道具(id,名称,1)
                常规提示(id,"#Y/你获得了"..名称)
                广播消息({内容=format("#S(副本-车迟斗法)#R/%s#Y在#R车迟斗法#Y副本中表现卓越，最终战胜了#R%s#Y，因此获得了三清奖励的#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,任务数据[self.任务id].名称,名称),频道="xt"})
              elseif 奖励参数<=80 then
                local 名称=取强化石()
                玩家数据[id].道具:给予道具(id,名称,10)
                常规提示(id,"#Y/你获得了"..名称)
                广播消息({内容=format("#S(副本-车迟斗法)#R/%s#Y在#R车迟斗法#Y副本中表现卓越，最终战胜了#R%s#Y，因此获得了三清奖励的#G/%s*10#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,任务数据[self.任务id].名称,名称),频道="xt"})
              end
            else
              if 奖励参数<=15 then
                local 名称="高级魔兽要诀"
                玩家数据[id].道具:给予道具(id,名称)
                常规提示(id,"#Y/你获得了"..名称)
                广播消息({内容=format("#S(副本-车迟斗法)#R/%s#Y在#R车迟斗法#Y副本中表现卓越，最终战胜了#R%s#Y，因此获得了三清奖励的#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,任务数据[self.任务id].名称,名称),频道="xt"})
              elseif 奖励参数<=25 then
               local 名称="九转金丹"
                玩家数据[id].道具:给予道具(id,名称,1,50)
                常规提示(id,"#Y/你获得了"..名称)
                广播消息({内容=format("#S(副本-车迟斗法)#R/%s#Y在#R车迟斗法#Y副本中表现卓越，最终战胜了#R%s#Y，因此获得了三清奖励的#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,任务数据[self.任务id].名称,名称),频道="xt"})
              elseif 奖励参数<=30 then
                local 名称="修炼果"
                玩家数据[id].道具:给予道具(id,名称,1)
                常规提示(id,"#Y/你获得了"..名称)
                广播消息({内容=format("#S(副本-车迟斗法)#R/%s#Y在#R车迟斗法#Y副本中表现卓越，最终战胜了#R%s#Y，因此获得了三清奖励的#G/%s*2#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,任务数据[self.任务id].名称,名称),频道="xt"})
              elseif 奖励参数<=60 then
                local 名称=取宝石()
                玩家数据[id].道具:给予道具(id,名称,取随机数(2,3))
                常规提示(id,"#Y/你获得了"..名称)
                广播消息({内容=format("#S(副本-车迟斗法)#R/%s#Y在#R车迟斗法#Y副本中表现卓越，最终战胜了#R%s#Y，因此获得了三清奖励的#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,任务数据[self.任务id].名称,名称),频道="xt"})
              elseif 奖励参数<=70 then
                local 名称="初级神魂丹"
                玩家数据[id].道具:给予道具(id,名称,1)
                常规提示(id,"#Y/你获得了"..名称)
                广播消息({内容=format("#S(副本-车迟斗法)#R/%s#Y在#R车迟斗法#Y副本中表现卓越，最终战胜了#R%s#Y，因此获得了三清奖励的#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,任务数据[self.任务id].名称,名称),频道="xt"})
              elseif 奖励参数<=90 then
                local 名称="金银锦盒"
                玩家数据[id].道具:给予道具(id,名称,1)
                常规提示(id,"#Y/你获得了"..名称)
                广播消息({内容=format("#S(副本-车迟斗法)#R/%s#Y在#R车迟斗法#Y副本中表现卓越，最终战胜了#R%s#Y，因此获得了三清奖励的#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,任务数据[self.任务id].名称,名称),频道="xt"})
              else
                local 名称=取强化石()
                玩家数据[id].道具:给予道具(id,名称,10)
                常规提示(id,"#Y/你获得了"..名称)
                广播消息({内容=format("#S(副本-车迟斗法)#R/%s#Y在#R车迟斗法#Y副本中表现卓越，最终战胜了#R%s#Y，因此获得了三清奖励的#G/%s*10#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,任务数据[self.任务id].名称,名称),频道="xt"})
              end
            end
          end
        end
      end
      地图处理类:删除单位(任务数据[self.任务id].地图编号,任务数据[self.任务id].单位编号)
      任务数据[self.任务id]=nil
    elseif self.战斗类型==100070 then
      添加最后对话(胜利id,format("少侠饶命！我再也不敢了"))
      地图处理类:删除单位(任务数据[self.任务id].地图编号,任务数据[self.任务id].单位编号)
      local 副本id=任务数据[self.任务id].副本id
      副本数据.车迟斗法.进行[副本id].进程=11
      local 副本任务id = 玩家数据[self.进入战斗玩家id].角色:取任务(130)
      任务处理类:设置车迟斗法副本(副本id,副本任务id)
      for n=1,#队伍数据[玩家数据[self.进入战斗玩家id].队伍].成员数据 do
        if 队伍处理类:取是否助战(玩家数据[self.进入战斗玩家id].队伍,n) == 0 then
          if 玩家数据[队伍数据[玩家数据[self.进入战斗玩家id].队伍].成员数据[n]].角色.数据.副本积分==nil then
            玩家数据[队伍数据[玩家数据[self.进入战斗玩家id].队伍].成员数据[n]].角色.数据.副本积分=0
          end
          if 活跃数据[队伍数据[玩家数据[self.进入战斗玩家id].队伍].成员数据[n]]==nil then
            活跃数据[队伍数据[玩家数据[self.进入战斗玩家id].队伍].成员数据[n]]={活跃度=0,领取100活跃=false,领取200活跃=false,领取300活跃=false,领取400活跃=false,领取500活跃=false,师门次数=20,官职次数=30,鬼怪次数=25,封妖次数=3,游泳次数=1,镖王次数=1,押镖次数=50,水果次数=25,天庭叛逆次数=25,十二星宿次数=5,门派闯关次数=1,地煞星次数=5,天罡星次数=5,飞贼次数=5,知了先锋=20,小知了王=20,知了王=10,世界BOSS次数=2,抓鬼次数=50,初出江湖次数=20,帮派青龙次数=100,帮派玄武次数=100,妖王次数=3}
          end
          活跃数据[队伍数据[玩家数据[self.进入战斗玩家id].队伍].成员数据[n]].活跃度=活跃数据[队伍数据[玩家数据[self.进入战斗玩家id].队伍].成员数据[n]].活跃度+50
          玩家数据[队伍数据[玩家数据[self.进入战斗玩家id].队伍].成员数据[n]].角色.数据.累积活跃.当前积分=玩家数据[队伍数据[玩家数据[self.进入战斗玩家id].队伍].成员数据[n]].角色.数据.累积活跃.当前积分+活跃数据[队伍数据[玩家数据[self.进入战斗玩家id].队伍].成员数据[n]].活跃度
          玩家数据[队伍数据[玩家数据[self.进入战斗玩家id].队伍].成员数据[n]].角色.数据.累积活跃.总积分=玩家数据[队伍数据[玩家数据[self.进入战斗玩家id].队伍].成员数据[n]].角色.数据.累积活跃.总积分+活跃数据[队伍数据[玩家数据[self.进入战斗玩家id].队伍].成员数据[n]].活跃度
          玩家数据[队伍数据[玩家数据[self.进入战斗玩家id].队伍].成员数据[n]].角色.数据.副本积分=玩家数据[队伍数据[玩家数据[self.进入战斗玩家id].队伍].成员数据[n]].角色.数据.副本积分+10
          常规提示(队伍数据[玩家数据[self.进入战斗玩家id].队伍].成员数据[n],"#Y恭喜你完成了车迟副本获得了10点副本积分")
          local id=队伍数据[玩家数据[self.进入战斗玩家id].队伍].成员数据[n]
          local 奖励参数=取随机数()
          if 风雨无言定制 then
            if 奖励参数<=40 then
            elseif 奖励参数<=45 then
              local 名称="高级魔兽要诀"
              玩家数据[id].道具:给予道具(id,名称)
              常规提示(id,"#Y/你获得了"..名称)
              广播消息({内容=format("#S(副本-车迟斗法)#R/%s#Y在#R车迟斗法#Y副本中表现卓越，最终战胜了#R%s#Y，因此获得了三清奖励的#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,任务数据[self.任务id].名称,名称),频道="xt"})
            elseif 奖励参数<=50 then
              local 名称="九转金丹"
              玩家数据[id].道具:给予道具(id,名称,1,50)
              常规提示(id,"#Y/你获得了"..名称)
              广播消息({内容=format("#S(副本-车迟斗法)#R/%s#Y在#R车迟斗法#Y副本中表现卓越，最终战胜了#R%s#Y，因此获得了三清奖励的#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,任务数据[self.任务id].名称,名称),频道="xt"})
            elseif 奖励参数<=55 then
              local 名称="修炼果"
              玩家数据[id].道具:给予道具(id,名称,2)
              常规提示(id,"#Y/你获得了"..名称)
              广播消息({内容=format("#S(副本-车迟斗法)#R/%s#Y在#R车迟斗法#Y副本中表现卓越，最终战胜了#R%s#Y，因此获得了三清奖励的#G/%s*2#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,任务数据[self.任务id].名称,名称),频道="xt"})
            elseif 奖励参数<=60 then
              local 名称=取宝石()
              玩家数据[id].道具:给予道具(id,名称,取随机数(2,3))
              常规提示(id,"#Y/你获得了"..名称)
              广播消息({内容=format("#S(副本-车迟斗法)#R/%s#Y在#R车迟斗法#Y副本中表现卓越，最终战胜了#R%s#Y，因此获得了三清奖励的#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,任务数据[self.任务id].名称,名称),频道="xt"})
            elseif 奖励参数<=65 then
              local 名称="初级神魂丹"
              玩家数据[id].道具:给予道具(id,名称,1)
              常规提示(id,"#Y/你获得了"..名称)
              广播消息({内容=format("#S(副本-车迟斗法)#R/%s#Y在#R车迟斗法#Y副本中表现卓越，最终战胜了#R%s#Y，因此获得了三清奖励的#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,任务数据[self.任务id].名称,名称),频道="xt"})
            elseif 奖励参数<=66 then
              local 名称="高级魔兽要诀"
              local 技能=取特殊要诀()
              玩家数据[id].道具:给予道具(id,名称,nil,技能)
              常规提示(id,"#Y/你获得了"..名称)
              广播消息({内容=format("#S(副本-车迟斗法)#R/%s#Y在#R车迟斗法#Y副本中表现卓越，最终战胜了#R%s#Y，因此获得了三清奖励的#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,任务数据[self.任务id].名称,名称),频道="xt"})
            elseif 奖励参数<=75 then
              local 名称="金银锦盒"
              玩家数据[id].道具:给予道具(id,名称,1)
              常规提示(id,"#Y/你获得了"..名称)
              广播消息({内容=format("#S(副本-车迟斗法)#R/%s#Y在#R车迟斗法#Y副本中表现卓越，最终战胜了#R%s#Y，因此获得了三清奖励的#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,任务数据[self.任务id].名称,名称),频道="xt"})
            elseif 奖励参数<=80 then
              local 名称=取强化石()
              玩家数据[id].道具:给予道具(id,名称,10)
              常规提示(id,"#Y/你获得了"..名称)
              广播消息({内容=format("#S(副本-车迟斗法)#R/%s#Y在#R车迟斗法#Y副本中表现卓越，最终战胜了#R%s#Y，因此获得了三清奖励的#G/%s*10#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,任务数据[self.任务id].名称,名称),频道="xt"})
            end
          else
            if 奖励参数<=10 then
              local 名称="高级魔兽要诀"
              玩家数据[id].道具:给予道具(id,名称)
              常规提示(id,"#Y/你获得了"..名称)
              广播消息({内容=format("#S(副本-车迟斗法)#R/%s#Y在#R车迟斗法#Y副本中表现卓越，最终战胜了#R%s#Y，因此获得了三清奖励的#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,任务数据[self.任务id].名称,名称),频道="xt"})
            elseif 奖励参数<=25 then
              local 名称="九转金丹"
              玩家数据[id].道具:给予道具(id,名称,1,50)
              常规提示(id,"#Y/你获得了"..名称)
              广播消息({内容=format("#S(副本-车迟斗法)#R/%s#Y在#R车迟斗法#Y副本中表现卓越，最终战胜了#R%s#Y，因此获得了三清奖励的#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,任务数据[self.任务id].名称,名称),频道="xt"})
            elseif 奖励参数<=30 then
              local 名称="修炼果"
              玩家数据[id].道具:给予道具(id,名称,2)
              常规提示(id,"#Y/你获得了"..名称)
              广播消息({内容=format("#S(副本-车迟斗法)#R/%s#Y在#R车迟斗法#Y副本中表现卓越，最终战胜了#R%s#Y，因此获得了三清奖励的#G/%s*2#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,任务数据[self.任务id].名称,名称),频道="xt"})
            elseif 奖励参数<=60 then
              local 名称=取宝石()
              玩家数据[id].道具:给予道具(id,名称,取随机数(2,3))
              常规提示(id,"#Y/你获得了"..名称)
              广播消息({内容=format("#S(副本-车迟斗法)#R/%s#Y在#R车迟斗法#Y副本中表现卓越，最终战胜了#R%s#Y，因此获得了三清奖励的#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,任务数据[self.任务id].名称,名称),频道="xt"})
            elseif 奖励参数<=70 then
              local 名称="初级神魂丹"
              玩家数据[id].道具:给予道具(id,名称,1)
              常规提示(id,"#Y/你获得了"..名称)
              广播消息({内容=format("#S(副本-车迟斗法)#R/%s#Y在#R车迟斗法#Y副本中表现卓越，最终战胜了#R%s#Y，因此获得了三清奖励的#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,任务数据[self.任务id].名称,名称),频道="xt"})
            elseif 奖励参数<=71 then
              local 名称="高级魔兽要诀"
              local 技能=取特殊要诀()
              玩家数据[id].道具:给予道具(id,名称,nil,技能)
              常规提示(id,"#Y/你获得了"..名称)
              广播消息({内容=format("#S(副本-车迟斗法)#R/%s#Y在#R车迟斗法#Y副本中表现卓越，最终战胜了#R%s#Y，因此获得了三清奖励的#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,任务数据[self.任务id].名称,名称),频道="xt"})
            elseif 奖励参数<=90 then
              local 名称="金银锦盒"
              玩家数据[id].道具:给予道具(id,名称,1)
              常规提示(id,"#Y/你获得了"..名称)
              广播消息({内容=format("#S(副本-车迟斗法)#R/%s#Y在#R车迟斗法#Y副本中表现卓越，最终战胜了#R%s#Y，因此获得了三清奖励的#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,任务数据[self.任务id].名称,名称),频道="xt"})
            else
              local 名称=取强化石()
              玩家数据[id].道具:给予道具(id,名称,10)
              常规提示(id,"#Y/你获得了"..名称)
              广播消息({内容=format("#S(副本-车迟斗法)#R/%s#Y在#R车迟斗法#Y副本中表现卓越，最终战胜了#R%s#Y，因此获得了三清奖励的#G/%s*10#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,任务数据[self.任务id].名称,名称),频道="xt"})
            end
            if 奖励参数>=80 and 神兽定制 then
              local 名称="仙玉"
              添加仙玉(取随机数(10,100),玩家数据[id].账号,id,"车迟斗法")
              常规提示(id,"#Y/你获得了"..名称)
            end
          end
        end
      end
      地图处理类:当前消息广播1(6023,format("#G恭喜少侠完成了车迟斗法副本，地图上刷出奖励宝箱，请少侠快去领取！！！"))
    elseif self.战斗类型==100079 then
      任务处理类:完成子鼠(self.任务id,id组)
    elseif self.战斗类型==100078 then
      任务处理类:完成三界魔尊(self.任务id,id组)
    elseif self.战斗类型==100080 then
      任务处理类:完成狮子座(self.任务id,id组)
    elseif self.战斗类型==100081 then
      任务处理类:完成处女座(self.任务id,id组)
    elseif self.战斗类型==100082 then
      任务处理类:完成天秤座(self.任务id,id组)
    elseif self.战斗类型==100083 then
      任务处理类:完成丑牛(self.任务id,id组)
    elseif self.战斗类型==100084 then
      任务处理类:完成散财童子(self.任务id,id组)
    elseif self.战斗类型==100085 then
      local 玩家id=任务数据[self.任务id].玩家id
      添加最后对话(玩家id,"#Y可恶，披着人皮的妖怪居然蒙骗勇士，少侠，小心那个带头人。")
      玩家数据[玩家id].战斗=0
      地图处理类:跳转地图(玩家id,1187,53,30)
      剧情数据[玩家id].渡劫.进程=3
      任务处理类:取渡劫任务(玩家id)
      地图处理类:删除单位(任务数据[self.任务id].地图编号,任务数据[self.任务id].单位编号)
      玩家数据[玩家id].角色:刷新任务跟踪()
    elseif self.战斗类型==100086 then
      local 玩家id=任务数据[self.任务id].玩家id
      添加最后对话(玩家id,"#Y哈哈，大阵已经松动，我的任务也算完成了")
      地图处理类:删除单位(任务数据[self.任务id].地图编号,任务数据[self.任务id].单位编号)
      地图处理类:删除单位(任务数据[self.任务id].地图编号,任务数据[self.任务id].单位编号-1)
      剧情数据[玩家id].渡劫.进程=5
      任务处理类:取渡劫任务(玩家id)
      玩家数据[玩家id].角色:刷新任务跟踪()
    elseif self.战斗类型==100087 then
      local 玩家id=任务数据[self.任务id].玩家id
      添加最后对话(玩家id,"妖怪逃跑了，大家快追！")
      for i=1,14 do
        地图处理类:删除单位(任务数据[self.任务id].地图编号,任务数据[self.任务id].单位编号+(i-1))
      end
      剧情数据[玩家id].渡劫.进程=8
      任务处理类:取渡劫任务(玩家id)
      玩家数据[玩家id].角色:刷新任务跟踪()
    elseif self.战斗类型==100088 then
      local 玩家id=任务数据[self.任务id].玩家id
      剧情数据[玩家id].渡劫.进程=10
      任务处理类:取渡劫任务(玩家id)
      玩家数据[玩家id].角色:刷新任务跟踪()
    elseif self.战斗类型==100089 then
      local 玩家id=任务数据[self.任务id].玩家id
      添加最后对话(玩家id,"别再执迷不悟了")
      for i=1,15 do
        地图处理类:删除单位(任务数据[self.任务id].地图编号,任务数据[self.任务id].单位编号+(i-1))
      end
      剧情数据[玩家id].渡劫.进程=11
      任务处理类:取渡劫任务(玩家id)
      玩家数据[玩家id].角色:刷新任务跟踪()
    elseif self.战斗类型==100090 then
      local 玩家id=任务数据[self.任务id].玩家id
      local 任务id=玩家数据[玩家id].角色:取任务(8800)
      添加最后对话(玩家id,"不要高兴的太早，吾还会再回来的")
      for i=1,6 do
        地图处理类:删除单位(任务数据[self.任务id].地图编号,任务数据[self.任务id].单位编号+(i-1))
      end
      for i=1,13 do
        地图处理类:删除单位(1042,1000+(i-1))
      end
      玩家数据[玩家id].角色:取消任务(任务id)
      剧情数据[玩家id].渡劫.完成=true
      玩家数据[玩家id].角色.数据.剧情点=玩家数据[玩家id].角色.数据.剧情点+20
      玩家数据[玩家id].角色:添加称谓(玩家id,"超凡入圣")
      常规提示(玩家id,"#Y恭喜你完成渡劫，获得了20点剧情点")
      玩家数据[玩家id].战斗=0
      地图处理类:跳转地图(玩家id,1001,380,50)
      广播消息({内容=format("#S(出神入化)#R/%s#Y经过一番激烈的战斗，最终战胜了#R%s#Y，成功步入化境，粉碎了蚩尤的阴谋，造福三界；让我们为英雄欢呼吧".."#"..取随机数(84,84),玩家数据[玩家id].角色.数据.名称,"蚩尤幻影"),频道="xt"})
      发送公告(format("#S(出神入化)#R/%s#Y经过一番激烈的战斗，最终战胜了#R%s#Y，成功步入化境，粉碎了蚩尤的阴谋，造福三界；让我们为英雄欢呼吧",玩家数据[玩家id].角色.数据.名称,"蚩尤幻影"))
    elseif self.战斗类型==100091 then
      任务处理类:完成神秘钥匙怪(self.任务id,胜利id)
    elseif self.战斗类型==100092 then
      任务处理类:完成寅虎(self.任务id,id组)
    elseif self.战斗类型==100093 then
      任务处理类:完成怒天魇(self.任务id,id组)
    elseif self.战斗类型==100094 then
      任务处理类:完成叛军(self.任务id,id组)
    elseif self.战斗类型==100095 then
      任务处理类:完成变强就点我(self.任务id,id组)
    elseif self.战斗类型==100096 then
      任务处理类:完成不屈将魂(self.任务id,id组)
    elseif self.战斗类型==100097 then
      玩家数据[胜利id].角色.数据.五虎上将 = 1
      玩家数据[胜利id].角色.数据.潜力 = 玩家数据[胜利id].角色.数据.潜力 + 10
      添加最后对话(胜利id,"你的实力真是令人惊叹！你的潜能增加了")
      广播消息({内容=format("#S(五虎上将)#R/%s#Y与#R马超#Y奋战数百回合，竟然意外激发自身潜能,实力得到了进一步的提升。".."#"..取随机数(1,110),玩家数据[胜利id].角色.数据.名称),频道="xt"})
    elseif self.战斗类型==100098 then
      玩家数据[胜利id].角色.数据.五虎上将 = 2
      玩家数据[胜利id].角色.数据.潜力 = 玩家数据[胜利id].角色.数据.潜力 + 20
      添加最后对话(胜利id,"你的实力真是令人惊叹！你的潜能增加了")
      广播消息({内容=format("#S(五虎上将)#R/%s#Y与#R黄忠#Y奋战数百回合，竟然意外激发自身潜能,实力得到了进一步的提升。".."#"..取随机数(1,110),玩家数据[胜利id].角色.数据.名称),频道="xt"})
    elseif self.战斗类型==100099 then
      玩家数据[胜利id].角色.数据.五虎上将 = 3
      玩家数据[胜利id].角色.数据.潜力 = 玩家数据[胜利id].角色.数据.潜力 + 30
      添加最后对话(胜利id,"你的实力真是令人惊叹！你的潜能增加了")
      广播消息({内容=format("#S(五虎上将)#R/%s#Y与#R张飞#Y奋战数百回合，竟然意外激发自身潜能,实力得到了进一步的提升。".."#"..取随机数(1,110),玩家数据[胜利id].角色.数据.名称),频道="xt"})
    elseif self.战斗类型==100100 then
      玩家数据[胜利id].角色.数据.五虎上将 = 4
      玩家数据[胜利id].角色.数据.潜力 = 玩家数据[胜利id].角色.数据.潜力 + 40
      添加最后对话(胜利id,"你的实力真是令人惊叹！你的潜能增加了")
      广播消息({内容=format("#S(五虎上将)#R/%s#Y与#R关羽#Y奋战数百回合，竟然意外激发自身潜能,实力得到了进一步的提升。".."#"..取随机数(1,110),玩家数据[胜利id].角色.数据.名称),频道="xt"})
    elseif self.战斗类型==100101 then
      玩家数据[胜利id].角色.数据.五虎上将 = 5
      玩家数据[胜利id].角色:刷新信息("1")
      添加最后对话(胜利id,"你的实力真是令人惊叹！你的潜能增加了)")
      广播消息({内容=format("#S(五虎上将)#R/%s#Y与#R赵云#Y奋战数百回合，竟然意外激发自身潜能,实力得到了进一步的提升。".."#"..取随机数(1,110),玩家数据[胜利id].角色.数据.名称),频道="xt"})
    elseif self.战斗类型==100102 then
      任务处理类:完成魔化沙僧(self.任务id,id组)
    elseif self.战斗类型==100103 then
      任务处理类:完成魔化取经(self.任务id,id组)
    elseif self.战斗类型==100104 then
      任务处理类:完成七十二地煞星(self.任务id,id组)
    elseif self.战斗类型==100105 then
      任务处理类:完成福利宝箱(self.任务id,id组)
    elseif self.战斗类型==100106 then
      任务处理类:完成倾国倾城(self.任务id,id组)
    elseif self.战斗类型==100107 then
      任务处理类:完成美食专家(self.任务id,id组)
    elseif self.战斗类型==100108 then
      任务处理类:完成通天塔(self.任务id,id组)
    elseif self.战斗类型==100109 then
      任务处理类:完成贼王的线索(self.任务id,id组)
    elseif self.战斗类型==100110 then
      任务处理类:完成貔貅的羁绊(self.任务id,id组)
    elseif self.战斗类型==100111 then
      任务处理类:完成卯兔(self.任务id,id组)
    elseif self.战斗类型==100112 then
      local 任务id = 玩家数据[胜利id].角色:取任务(150)
      local 副本id = 任务数据[任务id].副本id
      local 等级=玩家数据[胜利id].角色.数据.等级
      玩家数据[胜利id].角色:添加银子(等级*200,"水陆大会采摘木材银子",1)
      玩家数据[胜利id].角色:添加经验(等级*500,"水陆大会采摘木材经验",1)
      任务数据[任务id].装潢=任务数据[任务id].装潢+1
      玩家数据[胜利id].采摘木材=nil
      副本数据.水陆大会.进行[副本id].装潢=副本数据.水陆大会.进行[副本id].装潢+1
      常规提示(胜利id,"#Y完成了采摘木材，装潢任务进度+1")
      if 副本数据.水陆大会.进行[副本id].装潢>=10 and 副本数据.水陆大会.进行[副本id].邀请>=10 then
        for i,v in pairs(地图处理类.地图单位[6024]) do
          if 地图处理类.地图单位[6024][i].名称 == "蟠桃树" and 任务数据[地图处理类.地图单位[6024][i].id].副本id == 副本id then
            地图处理类:删除单位(6024,i)
            break
          end
        end
        副本数据.水陆大会.进行[副本id].进程=2
        任务处理类:设置水陆大会副本(副本id)
        发送数据(玩家数据[胜利id].连接id,1501,{名称="道场督僧",模型="男人_方丈",对话="感谢少侠为水陆大会建设做出的贡献，道场已经建设完毕"})
      end
      玩家数据[胜利id].角色:刷新任务跟踪()
    elseif self.战斗类型==100113 then
      local 任务id = 玩家数据[胜利id].角色:取任务(150)
      local 副本id=任务数据[任务id].副本id
      local 等级=玩家数据[胜利id].角色.数据.等级
      玩家数据[胜利id].角色:添加银子(等级*200,"水陆大会驱逐泼猴银子",1)
      玩家数据[胜利id].角色:添加经验(等级*500,"水陆大会驱逐泼猴经验",1)
      任务数据[任务id].装潢=任务数据[任务id].装潢+1
      玩家数据[胜利id].驱逐泼猴=nil
      副本数据.水陆大会.进行[副本id].装潢=副本数据.水陆大会.进行[副本id].装潢+1
      地图处理类:删除单位(任务数据[self.任务id].地图编号,任务数据[self.任务id].单位编号)
      玩家数据[胜利id].角色:取消任务(玩家数据[胜利id].角色:取任务(352))
      常规提示(胜利id,"#Y完成了驱逐泼猴，装潢任务进度+1")
      if 副本数据.水陆大会.进行[副本id].装潢>=10 and 副本数据.水陆大会.进行[副本id].邀请>=10 then
        for i,v in pairs(地图处理类.地图单位[6024]) do
          if 地图处理类.地图单位[6024][i].名称 == "蟠桃树" and 任务数据[地图处理类.地图单位[6024][i].id].副本id == 副本id then
            地图处理类:删除单位(6024,i)
            break
          end
        end
        副本数据.水陆大会.进行[副本id].进程=2
        任务处理类:设置水陆大会副本(副本id)
        发送数据(玩家数据[胜利id].连接id,1501,{名称="道场督僧",模型="男人_方丈",对话="感谢少侠为水陆大会建设做出的贡献，道场已经建设完毕"})
      end
      玩家数据[胜利id].角色:刷新任务跟踪()
    elseif self.战斗类型==100116 then
      local 任务id = 玩家数据[胜利id].角色:取任务(150)
      local 副本id=任务数据[任务id].副本id
      副本数据.水陆大会.进行[副本id].击败翼虎=true
      任务数据[self.任务id].战斗=nil
      地图处理类:删除单位(任务数据[self.任务id].地图编号,任务数据[self.任务id].单位编号)
      if 副本数据.水陆大会.进行[副本id].击败翼虎 and 副本数据.水陆大会.进行[副本id].击败蝰蛇 then
        副本数据.水陆大会.进行[副本id].进程=6
        任务处理类:设置水陆大会副本(副本id)
      end
      玩家数据[胜利id].角色:刷新任务跟踪()
    elseif self.战斗类型==100117 then
      local 任务id = 玩家数据[胜利id].角色:取任务(150)
      local 副本id=任务数据[任务id].副本id
      副本数据.水陆大会.进行[副本id].击败蝰蛇=true
      任务数据[self.任务id].战斗=nil
      地图处理类:删除单位(任务数据[self.任务id].地图编号,任务数据[self.任务id].单位编号)
      if 副本数据.水陆大会.进行[副本id].击败翼虎 and 副本数据.水陆大会.进行[副本id].击败蝰蛇 then
        副本数据.水陆大会.进行[副本id].进程=6
        任务处理类:设置水陆大会副本(副本id)
      end
      玩家数据[胜利id].角色:刷新任务跟踪()
    elseif self.战斗类型==100118 then
      local 任务id = 玩家数据[胜利id].角色:取任务(150)
      local 副本id=任务数据[任务id].副本id
      if 任务数据[self.任务id].名称=="巡山小妖" then
        副本数据.水陆大会.进行[副本id].击败小妖=副本数据.水陆大会.进行[副本id].击败小妖+1
      elseif 任务数据[self.任务id].名称=="上古妖兽头领" then
        副本数据.水陆大会.进行[副本id].击败头领=副本数据.水陆大会.进行[副本id].击败头领+1
      elseif 任务数据[self.任务id].名称=="妖将军" then
        副本数据.水陆大会.进行[副本id].击败将军=副本数据.水陆大会.进行[副本id].击败将军+1
      else
        if 任务数据[self.任务id].名称=="魑魅" then
          副本数据.水陆大会.进行[副本id].击败魑魅=true
        else
          副本数据.水陆大会.进行[副本id].击败魍魉=true
        end
      end
      地图处理类:删除单位(任务数据[self.任务id].地图编号,任务数据[self.任务id].单位编号)
      if 副本数据.水陆大会.进行[副本id].击败魑魅 and 副本数据.水陆大会.进行[副本id].击败魍魉 then
        副本数据.水陆大会.进行[副本id].进程=8
        任务处理类:设置水陆大会副本(副本id)
      end
      玩家数据[胜利id].角色:刷新任务跟踪()
    elseif self.战斗类型==100121 then
      任务处理类:完成魔域魔兵(self.任务id,id组)
    elseif self.战斗类型==100122 then
      任务处理类:完成捣乱的年兽(self.任务id,id组)
    elseif self.战斗类型==100123 then
      任务处理类:完成年兽王(self.任务id,id组)
    elseif self.战斗类型==100124 then
      任务处理类:完成邪恶年兽(self.任务id,id组)
    elseif self.战斗类型==100125 then
      地图处理类:删除单位(任务数据[self.任务id].地图编号,任务数据[self.任务id].单位编号)
      local 任务id = 玩家数据[胜利id].角色:取任务(160)
      local 副本id=任务数据[任务id].副本id
      副本数据.通天河.进行[副本id].进程=4
      任务处理类:设置通天河副本(副本id)
      玩家数据[胜利id].角色:刷新任务跟踪()
    elseif self.战斗类型==100126 then
      地图处理类:删除单位(任务数据[self.任务id].地图编号,任务数据[self.任务id].单位编号)
      local 副本id=任务数据[self.任务id].副本id
      副本数据.通天河.进行[副本id].河妖=副本数据.通天河.进行[副本id].河妖+1
      if 副本数据.通天河.进行[副本id].河妖>=1 then
        玩家数据[胜利id].战斗=0
        地图处理类:跳转地图(胜利id,6028,27,22)
        副本数据.通天河.进行[副本id].进程=6
        任务处理类:设置通天河副本(副本id)
      end
      玩家数据[胜利id].角色:刷新任务跟踪()
    elseif self.战斗类型==100127 then
      地图处理类:删除单位(任务数据[self.任务id].地图编号,任务数据[self.任务id].单位编号)
      local 副本id=任务数据[self.任务id].副本id
      副本数据.通天河.进行[副本id].散财童子=true
      if 副本数据.通天河.进行[副本id].散财童子 and 副本数据.通天河.进行[副本id].黑熊精 then
        副本数据.通天河.进行[副本id].进程=7
        任务处理类:设置通天河副本(副本id)
      end
      玩家数据[胜利id].角色:刷新任务跟踪()
    elseif self.战斗类型==100128 then
      地图处理类:删除单位(任务数据[self.任务id].地图编号,任务数据[self.任务id].单位编号)
      local 副本id=任务数据[self.任务id].副本id
      副本数据.通天河.进行[副本id].黑熊精=true
      if 副本数据.通天河.进行[副本id].散财童子 and 副本数据.通天河.进行[副本id].黑熊精 then
        副本数据.通天河.进行[副本id].进程=7
        任务处理类:设置通天河副本(副本id)
      end
      玩家数据[胜利id].角色:刷新任务跟踪()
    elseif self.战斗类型==100129 then
      地图处理类:删除单位(任务数据[self.任务id].地图编号,任务数据[self.任务id].单位编号)
      local 副本id=任务数据[self.任务id].副本id
      副本数据.通天河.进行[副本id].五色竹条=副本数据.通天河.进行[副本id].五色竹条+1
      if 副本数据.通天河.进行[副本id].五色竹条>=50 then
        玩家数据[胜利id].战斗=0
        地图处理类:跳转地图(胜利id,6029,103,59)
        副本数据.通天河.进行[副本id].进程=9
        任务处理类:设置通天河副本(副本id)
      end
      玩家数据[胜利id].角色:刷新任务跟踪()
    elseif self.战斗类型==100134 then
      地图处理类:删除单位(任务数据[self.任务id].地图编号,任务数据[self.任务id].单位编号)
      local 副本id=任务数据[self.任务id].副本id
      玩家数据[胜利id].战斗=0
      地图处理类:跳转地图(胜利id,6030,106,38)
      副本数据.通天河.进行[副本id].进程=10
      任务处理类:设置通天河副本(副本id)
      玩家数据[胜利id].角色:刷新任务跟踪()
    elseif self.战斗类型==100135 then
      地图处理类:删除单位(任务数据[self.任务id].地图编号,任务数据[self.任务id].单位编号)
      local 副本id=任务数据[self.任务id].副本id
      for n=1,#队伍数据[玩家数据[self.进入战斗玩家id].队伍].成员数据 do
        if 队伍处理类:取是否助战(玩家数据[self.进入战斗玩家id].队伍,n) == 0 then
          if 玩家数据[队伍数据[玩家数据[self.进入战斗玩家id].队伍].成员数据[n]].角色.数据.副本积分==nil then
            玩家数据[队伍数据[玩家数据[self.进入战斗玩家id].队伍].成员数据[n]].角色.数据.副本积分=0
          end
          玩家数据[队伍数据[玩家数据[self.进入战斗玩家id].队伍].成员数据[n]].角色.数据.副本积分=玩家数据[队伍数据[玩家数据[self.进入战斗玩家id].队伍].成员数据[n]].角色.数据.副本积分+20
          常规提示(队伍数据[玩家数据[self.进入战斗玩家id].队伍].成员数据[n],"#Y恭喜你完成了通天河副本获得20点副本积分")
          玩家数据[队伍数据[玩家数据[self.进入战斗玩家id].队伍].成员数据[n]].角色:取消任务(玩家数据[队伍数据[玩家数据[self.进入战斗玩家id].队伍].成员数据[n]].角色:取任务(160))
          副本数据.通天河.完成[队伍数据[玩家数据[self.进入战斗玩家id].队伍].成员数据[n]]=true
        end
      end
      副本数据.通天河.进行[副本id]=nil
      地图处理类:跳转地图(胜利id,1070,52,74)
    elseif self.战斗类型==100136 then
      地图处理类:删除单位(任务数据[self.任务id].地图编号,任务数据[self.任务id].单位编号)
      怪物攻城数据.攻城先锋=怪物攻城数据.攻城先锋+1
    elseif self.战斗类型==100137 then
      地图处理类:删除单位(任务数据[self.任务id].地图编号,任务数据[self.任务id].单位编号)
      怪物攻城数据.攻城头目=怪物攻城数据.攻城头目+1
    elseif self.战斗类型==100138 then
      地图处理类:删除单位(任务数据[self.任务id].地图编号,任务数据[self.任务id].单位编号)
      怪物攻城数据.攻城将军=怪物攻城数据.攻城将军+1
      if 怪物攻城数据.攻城先锋>=100 and 怪物攻城数据.攻城头目>=50 and 怪物攻城数据.攻城将军>=5 then
        任务处理类:刷出魔族BOSS()
        怪物攻城数据.境外攻城开关=false
        怪物攻城数据.国境攻城开关=false
      end
    elseif self.战斗类型==100139 then
      地图处理类:删除单位(任务数据[self.任务id].地图编号,任务数据[self.任务id].单位编号)
      怪物攻城数据={攻城开关=false,国境攻城开关=false,境外攻城开关=false,攻城先锋=0,攻城头目=0,攻城将军=0,国境攻城先锋次数=0,境外攻城先锋次数=0,国境攻城头目次数=0,境外攻城头目次数=0}
    elseif self.战斗类型==100140 then
      if 玩家数据[self.进入战斗玩家id].队伍~=0 then
        发送数据(玩家数据[玩家数据[self.进入战斗玩家id].队伍].连接id,1501,{名称="商人的鬼魂",模型="野鬼",对话="少侠，你可要救救我呀#52",选项={"你……这是怎么了？"}})
        剧情数据[玩家数据[self.进入战斗玩家id].队伍].商人的鬼魂.进程=剧情数据[玩家数据[self.进入战斗玩家id].队伍].商人的鬼魂.进程+1
        玩家数据[玩家数据[self.进入战斗玩家id].队伍].角色:刷新任务跟踪()
      else
        发送数据(玩家数据[胜利id].连接id,1501,{名称="商人的鬼魂",模型="野鬼",对话="少侠，你可要救救我呀#52",选项={"你……这是怎么了？"}})
        剧情数据[胜利id].商人的鬼魂.进程=剧情数据[胜利id].商人的鬼魂.进程+1
        玩家数据[胜利id].角色:刷新任务跟踪()
      end
    elseif self.战斗类型==100141 then
      if 玩家数据[self.进入战斗玩家id].队伍~=0 then
        发送数据(玩家数据[玩家数据[self.进入战斗玩家id].队伍].连接id,1501,{名称="妖风",模型="吸血鬼",对话="咳咳咳……竟然有仙灵相助……莫非你就是……传说中的……",选项={"我是什么？"}})
        剧情数据[玩家数据[self.进入战斗玩家id].队伍].商人的鬼魂.进程=剧情数据[玩家数据[self.进入战斗玩家id].队伍].商人的鬼魂.进程+1
        玩家数据[玩家数据[self.进入战斗玩家id].队伍].角色:刷新任务跟踪()
      else
        发送数据(玩家数据[胜利id].连接id,1501,{名称="妖风",模型="吸血鬼",对话="咳咳咳……竟然有仙灵相助……莫非你就是……传说中的……",选项={"我是什么？"}})
        剧情数据[胜利id].商人的鬼魂.进程=剧情数据[胜利id].商人的鬼魂.进程+1
        玩家数据[胜利id].角色:刷新任务跟踪()
      end
    elseif self.战斗类型==100142 then
      if 玩家数据[self.进入战斗玩家id].队伍~=0 then
        剧情数据[玩家数据[self.进入战斗玩家id].队伍].枯萎的金莲.进程=剧情数据[玩家数据[self.进入战斗玩家id].队伍].枯萎的金莲.进程+1
        玩家数据[玩家数据[self.进入战斗玩家id].队伍].角色:刷新任务跟踪()
      else
        剧情数据[胜利id].枯萎的金莲.进程=剧情数据[胜利id].枯萎的金莲.进程+1
        玩家数据[胜利id].角色:刷新任务跟踪()
      end
      地图处理类:删除单位(任务数据[self.任务id].地图编号,任务数据[self.任务id].单位编号)
    elseif self.战斗类型==100143 then
      if 玩家数据[self.进入战斗玩家id].队伍~=0 then
        发送数据(玩家数据[胜利id].连接id,1501,{名称="白鹿精",模型="赌徒",对话="玉面妹妹救我！！！"})
        剧情数据[玩家数据[self.进入战斗玩家id].队伍].玄奘的身世.进程=剧情数据[玩家数据[self.进入战斗玩家id].队伍].玄奘的身世.进程+1
        玩家数据[玩家数据[self.进入战斗玩家id].队伍].角色:刷新任务跟踪()
      else
        发送数据(玩家数据[胜利id].连接id,1501,{名称="白鹿精",模型="赌徒",对话="玉面妹妹救我！！！"})
        剧情数据[胜利id].玄奘的身世.进程=剧情数据[胜利id].玄奘的身世.进程+1
        玩家数据[胜利id].角色:刷新任务跟踪()
      end
    elseif self.战斗类型==100144 then
      if 玩家数据[self.进入战斗玩家id].队伍~=0 then
        发送数据(玩家数据[胜利id].连接id,1501,{名称="白鹿精",模型="赌徒",对话="别打了，我这就跟你回去，放过玉面妹妹"})
        剧情数据[玩家数据[self.进入战斗玩家id].队伍].玄奘的身世.进程=剧情数据[玩家数据[self.进入战斗玩家id].队伍].玄奘的身世.进程+1
        玩家数据[玩家数据[self.进入战斗玩家id].队伍].角色:刷新任务跟踪()
      else
        发送数据(玩家数据[胜利id].连接id,1501,{名称="白鹿精",模型="赌徒",对话="别打了，我这就跟你回去，放过玉面妹妹"})
        剧情数据[胜利id].玄奘的身世.进程=剧情数据[胜利id].玄奘的身世.进程+1
        玩家数据[胜利id].角色:刷新任务跟踪()
      end
    elseif self.战斗类型==100145 then
      if 玩家数据[self.进入战斗玩家id].队伍~=0 then
        发送数据(玩家数据[胜利id].连接id,1501,{名称="酒肉和尚",模型="雨师",对话="别打了，别打了，玄奘就在佛像的后面"})
        剧情数据[玩家数据[self.进入战斗玩家id].队伍].玄奘的身世.进程=剧情数据[玩家数据[self.进入战斗玩家id].队伍].玄奘的身世.进程+1
        玩家数据[玩家数据[self.进入战斗玩家id].队伍].角色:刷新任务跟踪()
      else
        发送数据(玩家数据[胜利id].连接id,1501,{名称="酒肉和尚",模型="雨师",对话="别打了，别打了，玄奘就在佛像的后面"})
        剧情数据[胜利id].玄奘的身世.进程=剧情数据[胜利id].玄奘的身世.进程+1
        玩家数据[胜利id].角色:刷新任务跟踪()
      end
    elseif self.战斗类型==100146 then
      if 玩家数据[self.进入战斗玩家id].队伍~=0 then
        发送数据(玩家数据[胜利id].连接id,1501,{名称="守门天将",模型="天兵",对话="原来少侠是为了白琉璃而来，白琉璃本为王母的琉璃盏，后因卷帘大将不小心打碎而流落人间的，你可去大唐国境寻找。"})
        剧情数据[玩家数据[self.进入战斗玩家id].队伍].玄奘的身世.进程=剧情数据[玩家数据[self.进入战斗玩家id].队伍].玄奘的身世.进程+1
        玩家数据[玩家数据[self.进入战斗玩家id].队伍].角色:刷新任务跟踪()
      else
        发送数据(玩家数据[胜利id].连接id,1501,{名称="守门天将",模型="天兵",对话="原来少侠是为了白琉璃而来，白琉璃本为王母的琉璃盏，后因卷帘大将不小心打碎而流落人间的，你可去大唐国境寻找。"})
        剧情数据[胜利id].玄奘的身世.进程=剧情数据[胜利id].玄奘的身世.进程+1
        玩家数据[胜利id].角色:刷新任务跟踪()
      end
    elseif self.战斗类型==100147 then
      if 玩家数据[self.进入战斗玩家id].队伍~=0 then
        发送数据(玩家数据[胜利id].连接id,1501,{名称="白琉璃",模型="星灵仙子",对话="不就是个舍利子么，给你就是了！"})
        剧情数据[玩家数据[self.进入战斗玩家id].队伍].玄奘的身世.进程=剧情数据[玩家数据[self.进入战斗玩家id].队伍].玄奘的身世.进程+1
        玩家数据[玩家数据[self.进入战斗玩家id].队伍].角色:刷新任务跟踪()
        玩家数据[玩家数据[self.进入战斗玩家id].队伍].道具:给予道具(玩家数据[self.进入战斗玩家id].队伍,"佛光舍利子",1,1)
      else
        发送数据(玩家数据[胜利id].连接id,1501,{名称="白琉璃",模型="星灵仙子",对话="不就是个舍利子么，给你就是了！"})
        剧情数据[胜利id].玄奘的身世.进程=剧情数据[胜利id].玄奘的身世.进程+1
        玩家数据[胜利id].角色:刷新任务跟踪()
        玩家数据[胜利id].道具:给予道具(胜利id,"佛光舍利子",1,1)
      end
    elseif self.战斗类型==100148 then
      if 玩家数据[self.进入战斗玩家id].队伍~=0 then
        发送数据(玩家数据[胜利id].连接id,1501,{名称="酒肉和尚",模型="雨师",对话="少侠我知道错了，但是我也没解药，需要服用仙家灵药九转回魂丹才能康复。"})
        剧情数据[玩家数据[self.进入战斗玩家id].队伍].玄奘的身世.进程=剧情数据[玩家数据[self.进入战斗玩家id].队伍].玄奘的身世.进程+1
        玩家数据[玩家数据[self.进入战斗玩家id].队伍].角色:刷新任务跟踪()
      else
        发送数据(玩家数据[胜利id].连接id,1501,{名称="酒肉和尚",模型="雨师",对话="少侠我知道错了，但是我也没解药，需要服用仙家灵药九转回魂丹才能康复。"})
        剧情数据[胜利id].玄奘的身世.进程=剧情数据[胜利id].玄奘的身世.进程+1
        玩家数据[胜利id].角色:刷新任务跟踪()
      end
    elseif self.战斗类型==100149 then
      if 玩家数据[self.进入战斗玩家id].队伍~=0 then
        发送数据(玩家数据[胜利id].连接id,1501,{名称="幽冥鬼",模型="巡游天神",对话="少侠若是帮我寻找到文秀，她若安好，我就放心的去转世投胎！"})
        剧情数据[玩家数据[self.进入战斗玩家id].队伍].玄奘的身世.进程=剧情数据[玩家数据[self.进入战斗玩家id].队伍].玄奘的身世.进程+1
        玩家数据[玩家数据[self.进入战斗玩家id].队伍].角色:刷新任务跟踪()
      else
        发送数据(玩家数据[胜利id].连接id,1501,{名称="幽冥鬼",模型="巡游天神",对话="少侠若是帮我寻找到文秀，她若安好，我就放心的去转世投胎！"})
        剧情数据[胜利id].玄奘的身世.进程=剧情数据[胜利id].玄奘的身世.进程+1
        玩家数据[胜利id].角色:刷新任务跟踪()
      end
    elseif self.战斗类型==100150 then
      if 玩家数据[self.进入战斗玩家id].队伍~=0 then
        发送数据(玩家数据[胜利id].连接id,1501,{名称="衙门守卫",模型="男人_衙役",对话="少侠饶命，我再也不敢了，请进！请进！"})
        剧情数据[玩家数据[self.进入战斗玩家id].队伍].玄奘的身世.进程=剧情数据[玩家数据[self.进入战斗玩家id].队伍].玄奘的身世.进程+1
        玩家数据[玩家数据[self.进入战斗玩家id].队伍].角色:刷新任务跟踪()
      else
        发送数据(玩家数据[胜利id].连接id,1501,{名称="衙门守卫",模型="男人_衙役",对话="少侠饶命，我再也不敢了，请进！请进！"})
        剧情数据[胜利id].玄奘的身世.进程=剧情数据[胜利id].玄奘的身世.进程+1
        玩家数据[胜利id].角色:刷新任务跟踪()
      end
    elseif self.战斗类型==100151 then
      if 玩家数据[self.进入战斗玩家id].队伍~=0 then
        发送数据(玩家数据[胜利id].连接id,1501,{名称="虾兵",模型="虾兵",对话="少侠饶命，我再也不敢了，宝贝给你！"})
        剧情数据[玩家数据[self.进入战斗玩家id].队伍].玄奘的身世.进程=剧情数据[玩家数据[self.进入战斗玩家id].队伍].玄奘的身世.进程+1
        玩家数据[玩家数据[self.进入战斗玩家id].队伍].角色:刷新任务跟踪()
        玩家数据[玩家数据[self.进入战斗玩家id].队伍].道具:给予道具(胜利id,"定颜珠",1)
      else
        发送数据(玩家数据[胜利id].连接id,1501,{名称="虾兵",模型="虾兵",对话="少侠饶命，我再也不敢了，宝贝给你！"})
        剧情数据[胜利id].玄奘的身世.进程=剧情数据[胜利id].玄奘的身世.进程+1
        玩家数据[胜利id].角色:刷新任务跟踪()
        玩家数据[胜利id].道具:给予道具(胜利id,"定颜珠",1)
      end
    elseif self.战斗类型==100152 then
      if 玩家数据[self.进入战斗玩家id].队伍~=0 then
        发送数据(玩家数据[胜利id].连接id,1501,{名称="山神",模型="雨师",对话="跟少侠开个玩笑，这个就是避水珠，少侠拿好"})
        剧情数据[玩家数据[self.进入战斗玩家id].队伍].玄奘的身世.进程=剧情数据[玩家数据[self.进入战斗玩家id].队伍].玄奘的身世.进程+1
        玩家数据[玩家数据[self.进入战斗玩家id].队伍].角色:刷新任务跟踪()
        玩家数据[玩家数据[self.进入战斗玩家id].队伍].道具:给予道具(胜利id,"避水珠",1)
      else
        发送数据(玩家数据[胜利id].连接id,1501,{名称="山神",模型="雨师",对话="跟少侠开个玩笑，这个就是避水珠，少侠拿好"})
        剧情数据[胜利id].玄奘的身世.进程=剧情数据[胜利id].玄奘的身世.进程+1
        玩家数据[胜利id].角色:刷新任务跟踪()
        玩家数据[胜利id].道具:给予道具(胜利id,"避水珠",1)
      end
    elseif self.战斗类型==100153 then
      if 玩家数据[self.进入战斗玩家id].队伍~=0 then
        发送数据(玩家数据[胜利id].连接id,1501,{名称="蟹将军",模型="蟹将",对话="误会少侠了，龟千岁正在为定颜珠的是发愁，少侠快去吧"})
        剧情数据[玩家数据[self.进入战斗玩家id].队伍].玄奘的身世.进程=剧情数据[玩家数据[self.进入战斗玩家id].队伍].玄奘的身世.进程+1
        玩家数据[玩家数据[self.进入战斗玩家id].队伍].角色:刷新任务跟踪()
      else
        发送数据(玩家数据[胜利id].连接id,1501,{名称="蟹将军",模型="蟹将",对话="误会少侠了，龟千岁正在为定颜珠的是发愁，少侠快去吧"})
        剧情数据[胜利id].玄奘的身世.进程=剧情数据[胜利id].玄奘的身世.进程+1
        玩家数据[胜利id].角色:刷新任务跟踪()
      end
    elseif self.战斗类型==100154 then
      if 玩家数据[self.进入战斗玩家id].队伍~=0 then
        发送数据(玩家数据[胜利id].连接id,1501,{名称="刘洪",模型="男人_马副将",对话="少侠饶命，真的刘洪已经跟李彪跑了"})
        剧情数据[玩家数据[self.进入战斗玩家id].队伍].玄奘的身世.进程=剧情数据[玩家数据[self.进入战斗玩家id].队伍].玄奘的身世.进程+1
        玩家数据[玩家数据[self.进入战斗玩家id].队伍].角色:刷新任务跟踪()
      else
        发送数据(玩家数据[胜利id].连接id,1501,{名称="刘洪",模型="男人_马副将",对话="少侠饶命，真的刘洪已经跟李彪跑了"})
        剧情数据[胜利id].玄奘的身世.进程=剧情数据[胜利id].玄奘的身世.进程+1
        玩家数据[胜利id].角色:刷新任务跟踪()
      end
    elseif self.战斗类型==100155 then
      if 玩家数据[self.进入战斗玩家id].队伍~=0 then
        发送数据(玩家数据[胜利id].连接id,1501,{名称="李彪",模型="骷髅怪",对话="小小喽啰也来坏我的好事，找死！",选项={"妖孽休要猖狂（需战斗）","路过，路过"}})
        剧情数据[玩家数据[self.进入战斗玩家id].队伍].玄奘的身世.进程=剧情数据[玩家数据[self.进入战斗玩家id].队伍].玄奘的身世.进程+1
        玩家数据[玩家数据[self.进入战斗玩家id].队伍].角色:刷新任务跟踪()
      else
        发送数据(玩家数据[胜利id].连接id,1501,{名称="李彪",模型="骷髅怪",对话="小小喽啰也来坏我的好事，找死！",选项={"妖孽休要猖狂（需战斗）","路过，路过"}})
        剧情数据[胜利id].玄奘的身世.进程=剧情数据[胜利id].玄奘的身世.进程+1
        玩家数据[胜利id].角色:刷新任务跟踪()
      end
    elseif self.战斗类型==100156 then
      if 玩家数据[self.进入战斗玩家id].队伍~=0 then
        发送数据(玩家数据[胜利id].连接id,1501,{名称="李彪",模型="骷髅怪",对话="我不甘心啊！"})
        剧情数据[玩家数据[self.进入战斗玩家id].队伍].玄奘的身世.进程=剧情数据[玩家数据[self.进入战斗玩家id].队伍].玄奘的身世.进程+1
        玩家数据[玩家数据[self.进入战斗玩家id].队伍].角色:刷新任务跟踪()
      else
        发送数据(玩家数据[胜利id].连接id,1501,{名称="李彪",模型="骷髅怪",对话="我不甘心啊！"})
        剧情数据[胜利id].玄奘的身世.进程=剧情数据[胜利id].玄奘的身世.进程+1
        玩家数据[胜利id].角色:刷新任务跟踪()
      end
    elseif self.战斗类型==100157 then
      if 玩家数据[self.进入战斗玩家id].队伍~=0 then
        发送数据(玩家数据[玩家数据[self.进入战斗玩家id].队伍].连接id,1501,{名称="天兵飞剑",模型="天兵",对话="哼，你们等着，我这就禀报玉帝！"})
        剧情数据[玩家数据[self.进入战斗玩家id].队伍].大战心魔.进程=剧情数据[玩家数据[self.进入战斗玩家id].队伍].大战心魔.进程+1
        玩家数据[玩家数据[self.进入战斗玩家id].队伍].角色:刷新任务跟踪()
      else
        发送数据(玩家数据[胜利id].连接id,1501,{名称="天兵飞剑",模型="天兵",对话="哼，你们等着，我这就禀报玉帝！"})
        剧情数据[胜利id].大战心魔.进程=剧情数据[胜利id].大战心魔.进程+1
        玩家数据[胜利id].角色:刷新任务跟踪()
      end
    elseif self.战斗类型==100158 then
      if 玩家数据[self.进入战斗玩家id].队伍~=0 then
        发送数据(玩家数据[玩家数据[self.进入战斗玩家id].队伍].连接id,1501,{名称="卷帘大将",模型="沙僧",对话="啊~头好痛！杀~杀~杀",选项={"醒醒，卷帘大将（需战斗）","我该怎么办！"}})
        剧情数据[玩家数据[self.进入战斗玩家id].队伍].大战心魔.进程=剧情数据[玩家数据[self.进入战斗玩家id].队伍].大战心魔.进程+1
        玩家数据[玩家数据[self.进入战斗玩家id].队伍].角色:刷新任务跟踪()
      else
        发送数据(玩家数据[胜利id].连接id,1501,{名称="卷帘大将",模型="沙僧",对话="啊~头好痛！杀~杀~杀",选项={"醒醒，卷帘大将（需战斗）","我该怎么办！"}})
        剧情数据[胜利id].大战心魔.进程=剧情数据[胜利id].大战心魔.进程+1
        玩家数据[胜利id].角色:刷新任务跟踪()
      end
    elseif self.战斗类型==100160 then
      if 玩家数据[self.进入战斗玩家id].队伍~=0 then
        发送数据(玩家数据[玩家数据[self.进入战斗玩家id].队伍].连接id,1501,{名称="路人甲",模型="穷汉",对话="别打了，别打了，这破东西给你了"})
        剧情数据[玩家数据[self.进入战斗玩家id].队伍].大战心魔.进程=剧情数据[玩家数据[self.进入战斗玩家id].队伍].大战心魔.进程+1
        玩家数据[玩家数据[self.进入战斗玩家id].队伍].角色:刷新任务跟踪()
        玩家数据[玩家数据[self.进入战斗玩家id].队伍].道具:给予道具(玩家数据[self.进入战斗玩家id].队伍,"金击子",1)
      else
        发送数据(玩家数据[胜利id].连接id,1501,{名称="路人甲",模型="穷汉",对话="别打了，别打了，这破东西给你了"})
        剧情数据[胜利id].大战心魔.进程=剧情数据[胜利id].大战心魔.进程+1
        玩家数据[胜利id].角色:刷新任务跟踪()
        玩家数据[胜利id].道具:给予道具(胜利id,"金击子",1)
      end
    elseif self.战斗类型==100161 then
      if 玩家数据[self.进入战斗玩家id].队伍~=0 then
        发送数据(玩家数据[玩家数据[self.进入战斗玩家id].队伍].连接id,1501,{名称="哪吒",模型="男人_哪吒",对话="少侠好功夫，前段时间我和守门天将打赌把火尖枪输掉了，少侠是否能帮我拿回来？",选项={"没问题"}})
        剧情数据[玩家数据[self.进入战斗玩家id].队伍].大战心魔.进程=剧情数据[玩家数据[self.进入战斗玩家id].队伍].大战心魔.进程+1
        玩家数据[玩家数据[self.进入战斗玩家id].队伍].角色:刷新任务跟踪()
      else
        发送数据(玩家数据[胜利id].连接id,1501,{名称="哪吒",模型="男人_哪吒",对话="少侠好功夫，前段时间我和守门天将打赌把火尖枪输掉了，少侠是否能帮我拿回来？",选项={"没问题"}})
        剧情数据[胜利id].大战心魔.进程=剧情数据[胜利id].大战心魔.进程+1
        玩家数据[胜利id].角色:刷新任务跟踪()
      end
    elseif self.战斗类型==100162 then
      if 玩家数据[self.进入战斗玩家id].队伍~=0 then
        剧情数据[玩家数据[self.进入战斗玩家id].队伍].大战心魔.进程=剧情数据[玩家数据[self.进入战斗玩家id].队伍].大战心魔.进程+1
        玩家数据[玩家数据[self.进入战斗玩家id].队伍].角色:刷新任务跟踪()
        玩家数据[玩家数据[self.进入战斗玩家id].队伍].道具:给予道具(玩家数据[self.进入战斗玩家id].队伍,"火尖枪",1)
      else
        剧情数据[胜利id].大战心魔.进程=剧情数据[胜利id].大战心魔.进程+1
        玩家数据[胜利id].角色:刷新任务跟踪()
        玩家数据[胜利id].道具:给予道具(胜利id,"火尖枪",1)
      end
    elseif self.战斗类型==100163 then
      if 玩家数据[self.进入战斗玩家id].队伍~=0 then
        发送数据(玩家数据[玩家数据[self.进入战斗玩家id].队伍].连接id,1501,{名称="龙孙",模型="男人_小白龙",对话="哼，害死我爷爷，我不会善罢甘休的"})
        剧情数据[玩家数据[self.进入战斗玩家id].队伍].大战心魔.进程=剧情数据[玩家数据[self.进入战斗玩家id].队伍].大战心魔.进程+1
        玩家数据[玩家数据[self.进入战斗玩家id].队伍].角色:刷新任务跟踪()
      else
        发送数据(玩家数据[胜利id].连接id,1501,{名称="龙孙",模型="男人_小白龙",对话="哼，害死我爷爷，我不会善罢甘休的"})
        剧情数据[胜利id].大战心魔.进程=剧情数据[胜利id].大战心魔.进程+1
        玩家数据[胜利id].角色:刷新任务跟踪()
      end
    elseif self.战斗类型==100164 then
      if 玩家数据[self.进入战斗玩家id].队伍~=0 then
        发送数据(玩家数据[玩家数据[self.进入战斗玩家id].队伍].连接id,1501,{名称="小龙女",模型="小龙女",对话="原来事情是这样的，我可以原谅他，但是少侠一定要帮我找到天衡星出口气",选项={"放心，一定会帮你出口气"}})
        剧情数据[玩家数据[self.进入战斗玩家id].队伍].大战心魔.进程=剧情数据[玩家数据[self.进入战斗玩家id].队伍].大战心魔.进程+1
        玩家数据[玩家数据[self.进入战斗玩家id].队伍].角色:刷新任务跟踪()
      else
        发送数据(玩家数据[胜利id].连接id,1501,{名称="小龙女",模型="小龙女",对话="原来事情是这样的，我可以原谅他，但是少侠一定要帮我找到天衡星出口气",选项={"放心，一定会帮你出口气"}})
        剧情数据[胜利id].大战心魔.进程=剧情数据[胜利id].大战心魔.进程+1
        玩家数据[胜利id].角色:刷新任务跟踪()
      end
    elseif self.战斗类型==100165 then
      if 玩家数据[self.进入战斗玩家id].队伍~=0 then
        发送数据(玩家数据[玩家数据[self.进入战斗玩家id].队伍].连接id,1501,{名称="卷帘大将",模型="沙僧",对话="感谢少侠助我脱离心魔的控制，仙神又如何，从此我皈依佛门，改名为沙悟净，静候取经人的到来。"})
        剧情数据[玩家数据[self.进入战斗玩家id].队伍].大战心魔.完成=true
        玩家数据[玩家数据[self.进入战斗玩家id].队伍].角色.数据.剧情点=玩家数据[玩家数据[self.进入战斗玩家id].队伍].角色.数据.剧情点+7
        常规提示(玩家数据[self.进入战斗玩家id].队伍,"#Y恭喜你，完成了#G大战心魔#Y剧情，获得了#R7点#Y剧情点。")
        玩家数据[玩家数据[self.进入战斗玩家id].队伍].角色:取消任务(玩家数据[玩家数据[self.进入战斗玩家id].队伍].角色:取任务(6000))
      else
        发送数据(玩家数据[胜利id].连接id,1501,{名称="卷帘大将",模型="沙僧",对话="感谢少侠助我脱离心魔的控制，仙神又如何，从此我皈依佛门，改名为沙悟净，静候取经人的到来。"})
        剧情数据[胜利id].大战心魔.完成=true
        玩家数据[胜利id].角色.数据.剧情点=玩家数据[胜利id].角色.数据.剧情点+7
        常规提示(胜利id,"#Y恭喜你，完成了#G大战心魔#Y剧情，获得了#R7点#Y剧情点。")
        玩家数据[胜利id].角色:取消任务(玩家数据[胜利id].角色:取任务(6000))
      end
    elseif self.战斗类型==100166 then
      if 玩家数据[self.进入战斗玩家id].队伍~=0 then
        发送数据(玩家数据[玩家数据[self.进入战斗玩家id].队伍].连接id,1501,{名称="女妖",模型="芙蓉仙子",对话="我确实不知女孩儿失踪一事，这可能是盘丝洞逆徒金琉璃干的。"})
        剧情数据[玩家数据[self.进入战斗玩家id].队伍].寻找四琉璃.进程=剧情数据[玩家数据[self.进入战斗玩家id].队伍].寻找四琉璃.进程+1
        玩家数据[玩家数据[self.进入战斗玩家id].队伍].角色:刷新任务跟踪()
      else
        发送数据(玩家数据[胜利id].连接id,1501,{名称="女妖",模型="芙蓉仙子",对话="我确实不知女孩儿失踪一事，这可能是盘丝洞逆徒金琉璃干的。"})
        剧情数据[胜利id].寻找四琉璃.进程=剧情数据[胜利id].寻找四琉璃.进程+1
        玩家数据[胜利id].角色:刷新任务跟踪()
      end
    elseif self.战斗类型==100167 then
      if 玩家数据[self.进入战斗玩家id].队伍~=0 then
        发送数据(玩家数据[玩家数据[self.进入战斗玩家id].队伍].连接id,1501,{名称="金琉璃",模型="如意仙子",对话="为什么，为什么我就不能修炼成仙？"})
        剧情数据[玩家数据[self.进入战斗玩家id].队伍].寻找四琉璃.进程=剧情数据[玩家数据[self.进入战斗玩家id].队伍].寻找四琉璃.进程+1
        玩家数据[玩家数据[self.进入战斗玩家id].队伍].角色:刷新任务跟踪()
        玩家数据[玩家数据[self.进入战斗玩家id].队伍].道具:给予道具(玩家数据[self.进入战斗玩家id].队伍,"金琉璃碎片",1)
      else
        发送数据(玩家数据[胜利id].连接id,1501,{名称="金琉璃",模型="如意仙子",对话="为什么，为什么我就不能修炼成仙？"})
        剧情数据[胜利id].寻找四琉璃.进程=剧情数据[胜利id].寻找四琉璃.进程+1
        玩家数据[胜利id].角色:刷新任务跟踪()
        玩家数据[胜利id].道具:给予道具(胜利id,"金琉璃碎片",1)
      end
    elseif self.战斗类型==100168 then
      if 玩家数据[self.进入战斗玩家id].队伍~=0 then
        发送数据(玩家数据[玩家数据[self.进入战斗玩家id].队伍].连接id,1501,{名称="翻天怪",模型="地狱战神",对话="少侠饶命，我再也不敢祸害一方了，一定本分修炼。"})
        剧情数据[玩家数据[self.进入战斗玩家id].队伍].寻找四琉璃.进程=剧情数据[玩家数据[self.进入战斗玩家id].队伍].寻找四琉璃.进程+1
        玩家数据[玩家数据[self.进入战斗玩家id].队伍].角色:刷新任务跟踪()
      else
        发送数据(玩家数据[胜利id].连接id,1501,{名称="翻天怪",模型="地狱战神",对话="少侠饶命，我再也不敢祸害一方了，一定本分修炼。"})
        剧情数据[胜利id].寻找四琉璃.进程=剧情数据[胜利id].寻找四琉璃.进程+1
        玩家数据[胜利id].角色:刷新任务跟踪()
      end
    elseif self.战斗类型==100169 then
      if 玩家数据[self.进入战斗玩家id].队伍~=0 then
        发送数据(玩家数据[玩家数据[self.进入战斗玩家id].队伍].连接id,1501,{名称="姚太尉",模型="天兵",对话="二郎神君的好事也敢破坏，你们等着！"})
        剧情数据[玩家数据[self.进入战斗玩家id].队伍].寻找四琉璃.进程=剧情数据[玩家数据[self.进入战斗玩家id].队伍].寻找四琉璃.进程+1
        玩家数据[玩家数据[self.进入战斗玩家id].队伍].角色:刷新任务跟踪()
      else
        发送数据(玩家数据[胜利id].连接id,1501,{名称="姚太尉",模型="天兵",对话="二郎神君的好事也敢破坏，你们等着！"})
        剧情数据[胜利id].寻找四琉璃.进程=剧情数据[胜利id].寻找四琉璃.进程+1
        玩家数据[胜利id].角色:刷新任务跟踪()
      end
    elseif self.战斗类型==100170 then
      if 玩家数据[self.进入战斗玩家id].队伍~=0 then
        发送数据(玩家数据[玩家数据[self.进入战斗玩家id].队伍].连接id,1501,{名称="王母娘娘",模型="女人_王母",对话="既然敢伤害我的凤凰，这个琉璃盏让它继续碎，什么卷帘大将，永远不用回天庭了！"})
        剧情数据[玩家数据[self.进入战斗玩家id].队伍].寻找四琉璃.进程=剧情数据[玩家数据[self.进入战斗玩家id].队伍].寻找四琉璃.进程+1
        玩家数据[玩家数据[self.进入战斗玩家id].队伍].角色:刷新任务跟踪()
      else
        发送数据(玩家数据[胜利id].连接id,1501,{名称="王母娘娘",模型="女人_王母",对话="既然敢伤害我的凤凰，这个琉璃盏让它继续碎，什么卷帘大将，永远不用回天庭了！"})
        剧情数据[胜利id].寻找四琉璃.进程=剧情数据[胜利id].寻找四琉璃.进程+1
        玩家数据[胜利id].角色:刷新任务跟踪()
      end
    elseif self.战斗类型==100171 then
      if 玩家数据[self.进入战斗玩家id].队伍~=0 then
        发送数据(玩家数据[玩家数据[self.进入战斗玩家id].队伍].连接id,1501,{名称="小白龙",模型="男人_小白龙",对话="我是被冤枉的，那个明珠也不是我烧毁的，少侠能否帮个忙，帮我找镇塔之神帮忙，找寻真相。",选项={"乐意之至"}})
        剧情数据[玩家数据[self.进入战斗玩家id].队伍].含冤的小白龙.进程=剧情数据[玩家数据[self.进入战斗玩家id].队伍].含冤的小白龙.进程+1
        玩家数据[玩家数据[self.进入战斗玩家id].队伍].角色:刷新任务跟踪()
      else
        发送数据(玩家数据[胜利id].连接id,1501,{名称="小白龙",模型="男人_小白龙",对话="我是被冤枉的，那个明珠也不是我烧毁的，少侠能否帮个忙，帮我找镇塔之神帮忙，找寻真相。",选项={"乐意之至"}})
        剧情数据[胜利id].含冤的小白龙.进程=剧情数据[胜利id].含冤的小白龙.进程+1
        玩家数据[胜利id].角色:刷新任务跟踪()
      end
    elseif self.战斗类型==100172 then
      if 玩家数据[self.进入战斗玩家id].队伍~=0 then
        发送数据(玩家数据[玩家数据[self.进入战斗玩家id].队伍].连接id,1501,{名称="梦之魅",模型="僵尸",对话="我会安分守己的，不会再捣乱了"})
        剧情数据[玩家数据[self.进入战斗玩家id].队伍].含冤的小白龙.进程=剧情数据[玩家数据[self.进入战斗玩家id].队伍].含冤的小白龙.进程+1
        玩家数据[玩家数据[self.进入战斗玩家id].队伍].角色:刷新任务跟踪()
      else
        发送数据(玩家数据[胜利id].连接id,1501,{名称="梦之魅",模型="僵尸",对话="我会安分守己的，不会再捣乱了"})
        剧情数据[胜利id].含冤的小白龙.进程=剧情数据[胜利id].含冤的小白龙.进程+1
        玩家数据[胜利id].角色:刷新任务跟踪()
      end
    elseif self.战斗类型==100173 then
      if 玩家数据[self.进入战斗玩家id].队伍~=0 then
        发送数据(玩家数据[玩家数据[self.进入战斗玩家id].队伍].连接id,1501,{名称="血之魅",模型="僵尸",对话="我会安分守己的，不会再捣乱了"})
        剧情数据[玩家数据[self.进入战斗玩家id].队伍].含冤的小白龙.进程=剧情数据[玩家数据[self.进入战斗玩家id].队伍].含冤的小白龙.进程+1
        玩家数据[玩家数据[self.进入战斗玩家id].队伍].角色:刷新任务跟踪()
      else
        发送数据(玩家数据[胜利id].连接id,1501,{名称="血之魅",模型="僵尸",对话="我会安分守己的，不会再捣乱了"})
        剧情数据[胜利id].含冤的小白龙.进程=剧情数据[胜利id].含冤的小白龙.进程+1
        玩家数据[胜利id].角色:刷新任务跟踪()
      end
    elseif self.战斗类型==100174 then
      if 玩家数据[self.进入战斗玩家id].队伍~=0 then
        发送数据(玩家数据[玩家数据[self.进入战斗玩家id].队伍].连接id,1501,{名称="森之魅",模型="僵尸",对话="我会安分守己的，不会再捣乱了"})
        剧情数据[玩家数据[self.进入战斗玩家id].队伍].含冤的小白龙.进程=剧情数据[玩家数据[self.进入战斗玩家id].队伍].含冤的小白龙.进程+1
        玩家数据[玩家数据[self.进入战斗玩家id].队伍].角色:刷新任务跟踪()
      else
        发送数据(玩家数据[胜利id].连接id,1501,{名称="森之魅",模型="僵尸",对话="我会安分守己的，不会再捣乱了"})
        剧情数据[胜利id].含冤的小白龙.进程=剧情数据[胜利id].含冤的小白龙.进程+1
        玩家数据[胜利id].角色:刷新任务跟踪()
      end
    elseif self.战斗类型==100175 then
      if 玩家数据[self.进入战斗玩家id].队伍~=0 then
        发送数据(玩家数据[玩家数据[self.进入战斗玩家id].队伍].连接id,1501,{名称="奔波儿灞",模型="蛤蟆精",对话="我叫奔波儿灞，是乱世山碧波潭万圣龙王手下的蛤蟆精。我家万圣公主照得一个驸马唤做九头精怪，神通广大。日前显法力下了一阵血雨，借机偷了镇塔之宝。驸马偷宝之后怕人发觉，故差我在此看守，这是公主赐给我的白剑。"})
        剧情数据[玩家数据[self.进入战斗玩家id].队伍].含冤的小白龙.进程=剧情数据[玩家数据[self.进入战斗玩家id].队伍].含冤的小白龙.进程+1
        玩家数据[玩家数据[self.进入战斗玩家id].队伍].角色:刷新任务跟踪()
      else
        发送数据(玩家数据[胜利id].连接id,1501,{名称="奔波儿灞",模型="蛤蟆精",对话="我叫奔波儿灞，是乱世山碧波潭万圣龙王手下的蛤蟆精。我家万圣公主照得一个驸马唤做九头精怪，神通广大。日前显法力下了一阵血雨，借机偷了镇塔之宝。驸马偷宝之后怕人发觉，故差我在此看守，这是公主赐给我的白剑。"})
        剧情数据[胜利id].含冤的小白龙.进程=剧情数据[胜利id].含冤的小白龙.进程+1
        玩家数据[胜利id].角色:刷新任务跟踪()
      end
    elseif self.战斗类型==100176 then
      if 玩家数据[self.进入战斗玩家id].队伍~=0 then
        剧情数据[玩家数据[self.进入战斗玩家id].队伍].含冤的小白龙.进程=剧情数据[玩家数据[self.进入战斗玩家id].队伍].含冤的小白龙.进程+1
        玩家数据[玩家数据[self.进入战斗玩家id].队伍].角色:刷新任务跟踪()
      else
        剧情数据[胜利id].含冤的小白龙.进程=剧情数据[胜利id].含冤的小白龙.进程+1
        玩家数据[胜利id].角色:刷新任务跟踪()
      end
    elseif self.战斗类型==100177 then
      if 玩家数据[self.进入战斗玩家id].队伍~=0 then
        剧情数据[玩家数据[self.进入战斗玩家id].队伍].含冤的小白龙.进程=剧情数据[玩家数据[self.进入战斗玩家id].队伍].含冤的小白龙.进程+1
        玩家数据[玩家数据[self.进入战斗玩家id].队伍].角色:刷新任务跟踪()
      else
        剧情数据[胜利id].含冤的小白龙.进程=剧情数据[胜利id].含冤的小白龙.进程+1
        玩家数据[胜利id].角色:刷新任务跟踪()
      end
    elseif self.战斗类型==100178 then
      if 玩家数据[self.进入战斗玩家id].队伍~=0 then
        剧情数据[玩家数据[self.进入战斗玩家id].队伍].含冤的小白龙.进程=剧情数据[玩家数据[self.进入战斗玩家id].队伍].含冤的小白龙.进程+1
        玩家数据[玩家数据[self.进入战斗玩家id].队伍].角色:刷新任务跟踪()
        玩家数据[玩家数据[self.进入战斗玩家id].队伍].道具:给予道具(玩家数据[self.进入战斗玩家id].队伍,"龙须草",1)
      else
        剧情数据[胜利id].含冤的小白龙.进程=剧情数据[胜利id].含冤的小白龙.进程+1
        玩家数据[胜利id].角色:刷新任务跟踪()
        玩家数据[胜利id].道具:给予道具(胜利id,"龙须草",1)
      end
    elseif self.战斗类型==100179 then
      if 玩家数据[self.进入战斗玩家id].队伍~=0 then
        发送数据(玩家数据[玩家数据[self.进入战斗玩家id].队伍].连接id,1501,{名称="万圣公主",模型="女人_万圣公主",对话="我夫君去魔王寨赴宴了，等他回来看他怎么收拾你！",选项={"（先把龙须草还给王母娘娘，再去找九头精怪算帐）"}})
        剧情数据[玩家数据[self.进入战斗玩家id].队伍].含冤的小白龙.进程=剧情数据[玩家数据[self.进入战斗玩家id].队伍].含冤的小白龙.进程+1
        玩家数据[玩家数据[self.进入战斗玩家id].队伍].角色:刷新任务跟踪()
        玩家数据[玩家数据[self.进入战斗玩家id].队伍].道具:给予道具(玩家数据[self.进入战斗玩家id].队伍,"龙须草",1)
      else
        发送数据(玩家数据[胜利id].连接id,1501,{名称="万圣公主",模型="女人_万圣公主",对话="我夫君去魔王寨赴宴了，等他回来看他怎么收拾你！",选项={"（先把龙须草还给王母娘娘，再去找九头精怪算帐）"}})
        剧情数据[胜利id].含冤的小白龙.进程=剧情数据[胜利id].含冤的小白龙.进程+1
        玩家数据[胜利id].角色:刷新任务跟踪()
        玩家数据[胜利id].道具:给予道具(胜利id,"龙须草",1)
      end
    elseif self.战斗类型==100180 then
      if 玩家数据[self.进入战斗玩家id].队伍~=0 then
        剧情数据[玩家数据[self.进入战斗玩家id].队伍].含冤的小白龙.进程=剧情数据[玩家数据[self.进入战斗玩家id].队伍].含冤的小白龙.进程+1
        玩家数据[玩家数据[self.进入战斗玩家id].队伍].角色:刷新任务跟踪()
      else
        剧情数据[胜利id].含冤的小白龙.进程=剧情数据[胜利id].含冤的小白龙.进程+1
        玩家数据[胜利id].角色:刷新任务跟踪()
      end
    elseif self.战斗类型==100181 then
      if 玩家数据[self.进入战斗玩家id].队伍~=0 then
        发送数据(玩家数据[玩家数据[self.进入战斗玩家id].队伍].连接id,1501,{名称="九头精怪",模型="九头精怪",对话="镇塔之宝我已经献给了玉帝！"})
        剧情数据[玩家数据[self.进入战斗玩家id].队伍].含冤的小白龙.进程=剧情数据[玩家数据[self.进入战斗玩家id].队伍].含冤的小白龙.进程+1
        玩家数据[玩家数据[self.进入战斗玩家id].队伍].角色:刷新任务跟踪()
      else
        发送数据(玩家数据[胜利id].连接id,1501,{名称="九头精怪",模型="九头精怪",对话="镇塔之宝我已经献给了玉帝！"})
        剧情数据[胜利id].含冤的小白龙.进程=剧情数据[胜利id].含冤的小白龙.进程+1
        玩家数据[胜利id].角色:刷新任务跟踪()
      end
    elseif self.战斗类型==100182 then
      if 玩家数据[self.进入战斗玩家id].队伍~=0 then
        发送数据(玩家数据[玩家数据[self.进入战斗玩家id].队伍].连接id,1501,{名称="玉皇大帝",模型="男人_玉帝",对话="想要镇塔之宝，想都不要想！"})
        剧情数据[玩家数据[self.进入战斗玩家id].队伍].含冤的小白龙.进程=剧情数据[玩家数据[self.进入战斗玩家id].队伍].含冤的小白龙.进程+1
        玩家数据[玩家数据[self.进入战斗玩家id].队伍].角色:刷新任务跟踪()
      else
        发送数据(玩家数据[胜利id].连接id,1501,{名称="玉皇大帝",模型="男人_玉帝",对话="想要镇塔之宝，想都不要想！"})
        剧情数据[胜利id].含冤的小白龙.进程=剧情数据[胜利id].含冤的小白龙.进程+1
        玩家数据[胜利id].角色:刷新任务跟踪()
      end
    elseif self.战斗类型==100183 then
      if 玩家数据[self.进入战斗玩家id].队伍~=0 then
        发送数据(玩家数据[玩家数据[self.进入战斗玩家id].队伍].连接id,1501,{名称="千年怨鬼",模型="幽灵",对话="竟然被你识破了",选项={"快告诉我刑天在哪？"}})
        剧情数据[玩家数据[self.进入战斗玩家id].队伍].无名鬼域.进程=剧情数据[玩家数据[self.进入战斗玩家id].队伍].无名鬼域.进程+1
        玩家数据[玩家数据[self.进入战斗玩家id].队伍].角色:刷新任务跟踪()
      else
        发送数据(玩家数据[胜利id].连接id,1501,{名称="千年怨鬼",模型="幽灵",对话="竟然被你识破了",选项={"快告诉我刑天在哪？"}})
        剧情数据[胜利id].无名鬼域.进程=剧情数据[胜利id].无名鬼域.进程+1
        玩家数据[胜利id].角色:刷新任务跟踪()
      end
    elseif self.战斗类型==100184 then
      if 玩家数据[self.进入战斗玩家id].队伍~=0 then
        发送数据(玩家数据[玩家数据[self.进入战斗玩家id].队伍].连接id,1501,{名称="春十三娘",模型="春十三娘",对话="哼，你给我等着",选项={"不好，竟然让她跑了，先把事情告诉给小紫吧！"}})
        剧情数据[玩家数据[self.进入战斗玩家id].队伍].女娲神迹.进程=剧情数据[玩家数据[self.进入战斗玩家id].队伍].女娲神迹.进程+1
        玩家数据[玩家数据[self.进入战斗玩家id].队伍].角色:刷新任务跟踪()
      else
        发送数据(玩家数据[胜利id].连接id,1501,{名称="春十三娘",模型="春十三娘",对话="哼，你给我等着",选项={"不好，竟然让她跑了，先把事情告诉给小紫吧！"}})
        剧情数据[胜利id].女娲神迹.进程=剧情数据[胜利id].女娲神迹.进程+1
        玩家数据[胜利id].角色:刷新任务跟踪()
      end
    elseif self.战斗类型==100185 then
      if 玩家数据[self.进入战斗玩家id].队伍~=0 then
        发送数据(玩家数据[玩家数据[self.进入战斗玩家id].队伍].连接id,1501,{名称="康太尉",模型="天兵",对话="哼，敢破坏我家二郎神君的好事，你们等着"})
        剧情数据[玩家数据[self.进入战斗玩家id].队伍].八戒悟空.进程=剧情数据[玩家数据[self.进入战斗玩家id].队伍].八戒悟空.进程+1
        玩家数据[玩家数据[self.进入战斗玩家id].队伍].角色:刷新任务跟踪()
      else
        发送数据(玩家数据[胜利id].连接id,1501,{名称="康太尉",模型="天兵",对话="哼，敢破坏我家二郎神君的好事，你们等着"})
        剧情数据[胜利id].八戒悟空.进程=剧情数据[胜利id].八戒悟空.进程+1
        玩家数据[胜利id].角色:刷新任务跟踪()
      end
    elseif self.战斗类型==100186 then
      if 玩家数据[self.进入战斗玩家id].队伍~=0 then
        发送数据(玩家数据[玩家数据[self.进入战斗玩家id].队伍].连接id,1501,{名称="高翠兰",模型="少女",对话="我这么漂亮，那个呆子娶我很委屈吗？",选项={"高小姐三思而后行"}})
        剧情数据[玩家数据[self.进入战斗玩家id].队伍].八戒悟空.进程=剧情数据[玩家数据[self.进入战斗玩家id].队伍].八戒悟空.进程+1
        玩家数据[玩家数据[self.进入战斗玩家id].队伍].角色:刷新任务跟踪()
      else
        发送数据(玩家数据[胜利id].连接id,1501,{名称="高翠兰",模型="少女",对话="我这么漂亮，那个呆子娶我很委屈吗？",选项={"高小姐三思而后行"}})
        剧情数据[胜利id].八戒悟空.进程=剧情数据[胜利id].八戒悟空.进程+1
        玩家数据[胜利id].角色:刷新任务跟踪()
      end
    elseif self.战斗类型==100187 then
      if 玩家数据[self.进入战斗玩家id].队伍~=0 then
        发送数据(玩家数据[玩家数据[self.进入战斗玩家id].队伍].连接id,1501,{名称="冤魂",模型="僵尸",对话="少侠饶命，我再也不敢欺负土地了。"})
        剧情数据[玩家数据[self.进入战斗玩家id].队伍].八戒悟空.进程=剧情数据[玩家数据[self.进入战斗玩家id].队伍].八戒悟空.进程+1
        玩家数据[玩家数据[self.进入战斗玩家id].队伍].角色:刷新任务跟踪()
      else
        发送数据(玩家数据[胜利id].连接id,1501,{名称="冤魂",模型="僵尸",对话="少侠饶命，我再也不敢欺负土地了。"})
        剧情数据[胜利id].八戒悟空.进程=剧情数据[胜利id].八戒悟空.进程+1
        玩家数据[胜利id].角色:刷新任务跟踪()
      end
    elseif self.战斗类型==100188 then
      if 玩家数据[self.进入战斗玩家id].队伍~=0 then
        发送数据(玩家数据[玩家数据[self.进入战斗玩家id].队伍].连接id,1501,{名称="杨戬",模型="男人_杨戬",对话="哼，既然能打败我的哮天犬，有俩把刷子，绿烟石已经被我损坏丢到下界。"})
        剧情数据[玩家数据[self.进入战斗玩家id].队伍].八戒悟空.进程=剧情数据[玩家数据[self.进入战斗玩家id].队伍].八戒悟空.进程+1
        玩家数据[玩家数据[self.进入战斗玩家id].队伍].角色:刷新任务跟踪()
      else
        发送数据(玩家数据[胜利id].连接id,1501,{名称="杨戬",模型="男人_杨戬",对话="哼，既然能打败我的哮天犬，有俩把刷子，绿烟石已经被我损坏丢到下界。"})
        剧情数据[胜利id].八戒悟空.进程=剧情数据[胜利id].八戒悟空.进程+1
        玩家数据[胜利id].角色:刷新任务跟踪()
      end
    elseif self.战斗类型==100189 then
      if 玩家数据[self.进入战斗玩家id].队伍~=0 then
        发送数据(玩家数据[玩家数据[self.进入战斗玩家id].队伍].连接id,1501,{名称="龙神",模型="蛟龙",对话="罢了，既然是为了救人，那这个五龙丹给你就是"})
        剧情数据[玩家数据[self.进入战斗玩家id].队伍].八戒悟空.进程=剧情数据[玩家数据[self.进入战斗玩家id].队伍].八戒悟空.进程+1
        玩家数据[玩家数据[self.进入战斗玩家id].队伍].角色:刷新任务跟踪()
        玩家数据[玩家数据[self.进入战斗玩家id].队伍].道具:给予道具(玩家数据[self.进入战斗玩家id].队伍,"五龙丹",1,1)
      else
        发送数据(玩家数据[胜利id].连接id,1501,{名称="龙神",模型="蛟龙",对话="罢了，既然是为了救人，那这个五龙丹给你就是"})
        剧情数据[胜利id].八戒悟空.进程=剧情数据[胜利id].八戒悟空.进程+1
        玩家数据[胜利id].角色:刷新任务跟踪()
        玩家数据[胜利id].道具:给予道具(胜利id,"五龙丹",1,1)
      end
    elseif self.战斗类型==100190 then
      if 玩家数据[self.进入战斗玩家id].队伍~=0 then
        发送数据(玩家数据[玩家数据[self.进入战斗玩家id].队伍].连接id,1501,{名称="吊死鬼",模型="野鬼",对话="少侠别打了，我错了，白晶晶的鬼魂就在四层，我这就带少侠过去。"})
        剧情数据[玩家数据[self.进入战斗玩家id].队伍].八戒悟空.进程=剧情数据[玩家数据[self.进入战斗玩家id].队伍].八戒悟空.进程+1
        玩家数据[玩家数据[self.进入战斗玩家id].队伍].角色:刷新任务跟踪()
      else
        发送数据(玩家数据[胜利id].连接id,1501,{名称="吊死鬼",模型="野鬼",对话="少侠别打了，我错了，白晶晶的鬼魂就在四层，我这就带少侠过去。"})
        剧情数据[胜利id].八戒悟空.进程=剧情数据[胜利id].八戒悟空.进程+1
        玩家数据[胜利id].角色:刷新任务跟踪()
      end
    elseif self.战斗类型==100191 then
      if 玩家数据[self.进入战斗玩家id].队伍~=0 then
        发送数据(玩家数据[玩家数据[self.进入战斗玩家id].队伍].连接id,1501,{名称="青玄仙子",模型="星灵仙子",对话="拿去拿去，不就是一个破的定海珠么，给你就是了"})
        剧情数据[玩家数据[self.进入战斗玩家id].队伍].八戒悟空.进程=剧情数据[玩家数据[self.进入战斗玩家id].队伍].八戒悟空.进程+1
        玩家数据[玩家数据[self.进入战斗玩家id].队伍].角色:刷新任务跟踪()
      else
        发送数据(玩家数据[胜利id].连接id,1501,{名称="青玄仙子",模型="星灵仙子",对话="拿去拿去，不就是一个破的定海珠么，给你就是了"})
        剧情数据[胜利id].八戒悟空.进程=剧情数据[胜利id].八戒悟空.进程+1
        玩家数据[胜利id].角色:刷新任务跟踪()
      end
    end
  end
end

function 战斗处理类:取野外等级差(地图等级,玩家等级)
  local 等级=math.abs(地图等级-玩家等级)
  if 等级<=5 then
    return 1
  elseif 等级<=10 then
    return 0.8
  elseif 等级<=20 then
    return 0.5
  else
    return 0.2
  end
end

function 战斗处理类:奖励事件(id)
 if self.战斗类型==100001 or self.战斗类型==100007 then
     if self.地图等级<=0 then self.地图等级=1 end
     local 奖励经验=qz(self.地图等级*50*#self.参战玩家*(self.头领数量*0.1+1))
     local 奖励参数=self:取野外等级差(self.地图等级,玩家数据[id].角色.数据.等级)
     玩家数据[id].角色:添加经验(qz(奖励经验*奖励参数),"野外")
     玩家数据[id].角色:添加法宝灵气(id,1,self.等级下限,self.等级上限)
      if 玩家数据[id].角色.数据.参战信息~=nil then
         玩家数据[id].召唤兽:获得经验(玩家数据[id].角色.数据.参战宝宝.认证码,奖励经验,id,"野外",self.地图等级)
      end
      --心魔宝珠
      if 玩家数据[id].角色.数据.等级>=15 and 玩家数据[id].角色.数据.等级<50 then
        if 玩家数据[id].角色.数据.等级>=self.等级下限 and 玩家数据[id].角色.数据.等级<=self.等级上限 then
           玩家数据[id].道具:给予道具(id,"心魔宝珠",1)
        end
      end
      --野外装备掉落
      if 取随机数(1,100)>=95 then
        野外掉落装备(id,self.地图等级)
      end
      if 取随机数()<=20 then
          野外掉落二级药(id,self.地图等级)
      end
      if 玩家数据[id].角色.数据.等级>=self.等级下限 and 玩家数据[id].角色.数据.等级<=self.等级上限 and 取随机数(1,1000)<=20 then
        系统处理类:设置传说物品(id)
      end
      if 玩家数据[id].角色:取任务("飞升剧情")~=0 and 任务数据[玩家数据[id].角色:取任务("飞升剧情")].四法宝~=nil and 任务数据[玩家数据[id].角色:取任务("飞升剧情")].四法宝.修篁斧==false and 任务数据[玩家数据[id].角色:取任务("飞升剧情")].触发 then
        local 地图名称=取地图名称(玩家数据[id].角色.数据.地图数据.编号)
        local 任务id=玩家数据[id].角色:取任务("飞升剧情")
        if 地图名称=="普陀山" and 取随机数()<100 then
          任务数据[任务id].四法宝.修篁斧=true
          玩家数据[id].道具:给予道具(id,"修篁斧",1,nil,nil,"专用")
          广播消息({内容=format("你得到了修篁斧"),频道="xt"})
          常规提示(id,"#Y你获得了修篁斧")
          玩家数据[id].角色:刷新任务跟踪()
        end
      end
      -- 赵捕头的赏金任务
      if 玩家数据[id].角色:取任务(6)~=0 then
        local 地图名称=取地图名称(玩家数据[id].角色.数据.地图数据.编号)
        local 任务id=玩家数据[id].角色:取任务(6)
        if 地图名称=="江南野外" or 地图名称=="东海湾" or 地图名称=="东海海底" or 地图名称=="东海岩洞" or 地图名称=="海底沉船" then
          任务数据[任务id].数量=任务数据[任务id].数量-1
        end
        if 任务数据[任务id].数量<=0 then
            任务数据[任务id]=nil
            玩家数据[id].角色:取消任务(任务id)
            local 经验=0
            local 银子=0
            local 储备=0
            if 玩家数据[id].角色.数据.等级<=5 then
              经验=10000*3
              银子=1000
              储备=3000
            elseif 玩家数据[id].角色.数据.等级<=10 then
              经验=15000*3
              银子=2000
              储备=5000
            elseif 玩家数据[id].角色.数据.等级<=15 then
              经验=20000*3
              银子=3000
              储备=70000
            end
            玩家数据[id].角色:添加经验(经验,"建邺城赏金任务")
            玩家数据[id].道具:给予道具(id,"天眼通符")
            if 取随机数()<=30 then
                玩家数据[id].角色:添加银子(银子,"建邺城赏金任务",1)
            else
                玩家数据[id].角色:添加储备(银子,"建邺城赏金任务",1)
            end
            if 玩家数据[id].角色.数据.参战信息~=nil then
                玩家数据[id].召唤兽:获得经验(玩家数据[id].角色.数据.参战宝宝.认证码,qz(经验*0.35),id,"建邺城赏金任务",self.地图等级)
            end
            玩家数据[id].战斗对话={名称="赵捕头",模型="男人_衙役",对话="你是否需要继续领取赏金任务？".."#"..取随机数(1,110),选项={"是的，我要继续领取"}}
            玩家数据[id].赵捕头对话=1
          end
          玩家数据[id].角色:刷新任务跟踪()
        end
    elseif self.战斗类型==100061 then--帮战守卫
      local 编号=玩家数据[id].角色.数据.帮派数据.编号
      玩家数据[id].角色.数据.帮贡=玩家数据[id].角色.数据.帮贡+5
      帮派数据[编号].成员数据[id].帮贡.上限=帮派数据[编号].成员数据[id].帮贡.上限+5
      帮派数据[编号].成员数据[id].帮贡.当前=帮派数据[编号].成员数据[id].帮贡.当前+5
      常规提示(id,"#Y/你获得了5点帮贡")
    elseif self.战斗类型==100002 and id==任务数据[self.任务id].玩家id then --宝图强盗
      任务处理类:完成宝图任务(self.任务id)
    elseif self.战斗类型==100003 and id== self.进入战斗玩家id then --宝图强盗
      玩家数据[id].道具:完成宝图遇怪(id)
    elseif self.战斗类型==100008 and 取任务符合id(id,self.任务id) then
      local 等级1=玩家数据[id].角色.数据.等级
      local 等级=取队伍平均等级(玩家数据[id].队伍,id)
      local 奖励影响=self:取野外等级差(等级,等级1)
      local 经验=qz((等级*150*(玩家数据[id].角色.数据.捉鬼次数*0.2+1))+3000*奖励影响)
      local 银子=qz((等级*100*(玩家数据[id].角色.数据.捉鬼次数*0.1+1))*奖励影响)*2

      if 老唐定制 then
        玩家数据[id].角色:添加经验(50000,"捉鬼")
        玩家数据[id].角色:添加银子(30000,"捉鬼",1)
      else
        玩家数据[id].角色:添加经验(经验,"捉鬼")
        玩家数据[id].角色:添加银子(银子,"捉鬼",1)
      end
      if 活跃数据[id]==nil then
        活跃数据[id]={活跃度=0,领取100活跃=false,领取200活跃=false,领取300活跃=false,领取400活跃=false,领取500活跃=false,师门次数=20,官职次数=30,鬼怪次数=25,封妖次数=3,游泳次数=1,镖王次数=1,押镖次数=50,水果次数=25,天庭叛逆次数=25,十二星宿次数=5,门派闯关次数=1,地煞星次数=5,天罡星次数=5,飞贼次数=5,知了先锋=20,小知了王=20,知了王=10,世界BOSS次数=2,抓鬼次数=50,初出江湖次数=20,帮派青龙次数=100,帮派玄武次数=100,妖王次数=3}
      end
      if 活跃数据[id].抓鬼次数==nil then
        活跃数据[id].抓鬼次数=50
      end
      if 活跃数据[id].抓鬼次数>0 then
        活跃数据[id].活跃度=活跃数据[id].活跃度+2
        玩家数据[id].角色.数据.累积活跃.当前积分=玩家数据[id].角色.数据.累积活跃.当前积分+活跃数据[id].活跃度
        玩家数据[id].角色.数据.累积活跃.总积分=玩家数据[id].角色.数据.累积活跃.总积分+活跃数据[id].活跃度
        活跃数据[id].抓鬼次数=活跃数据[id].抓鬼次数-1
      end
      if 任务数据[self.任务id].变异奖励 then
        local 银子=取随机数(50000,500000)
        玩家数据[id].角色:添加银子(银子,"捉鬼触发变异",1)
        广播消息({内容=format("#S(捉鬼任务)#R/%s#Y在捉鬼任务中成功保护了#W%s#Y因此获得了其赠送的#G/%s#Y两银子".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,"善良的"..任务数据[self.任务id].模型,银子),频道="xt"})
      end
      if 老八定制 then
        if 抓鬼仙玉 <= 2000 then
          添加仙玉(5,玩家数据[id].账号,id,"抓鬼仙玉")
        end
        if 玩家数据[id].角色.数据.帮派数据~=nil then
          添加帮贡(id,5)
        end
      end
      if 玩家数据[id].角色.数据.参战信息~=nil then
        玩家数据[id].召唤兽:获得经验(玩家数据[id].角色.数据.参战宝宝.认证码,qz(经验*0.8),id,"捉鬼",self.地图等级)
      end
      玩家数据[id].角色:取消任务(self.任务id)
      if 玩家数据[id].角色.数据.捉鬼次数==10 then
        local 随机几率=取随机数()
        if 随机几率 <= 50 then
          玩家数据[id].道具:取随机装备(id,取随机数(5,8))
        elseif 随机几率 <= 70 then
          玩家数据[id].道具:给予道具(id,"分解符",1)
        else
          local 给予等级 = 5
          if 等级 <= 70 then
            给予等级 = 取随机数(1,7)
          else
            给予等级 = 取随机数(5,10)
          end
          玩家数据[id].道具:给予暗器(id,给予等级)
        end
        if 风雨无言定制 then
          local 名称=取宝石()
          玩家数据[id].道具:给予道具(id,名称,取随机数(1,5))
          广播消息({内容=format("#S(捉鬼任务)#R/%s#Y完成抓鬼任务中表现优异，#W%s#Y因此获得了其赠送的#G/%s".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,"钟馗",名称),频道="xt"})
        else
          local 名称=取宝石()
          玩家数据[id].道具:给予道具(id,名称,取随机数(1,3))
          广播消息({内容=format("#S(捉鬼任务)#R/%s#Y完成抓鬼任务中表现优异，#W%s#Y因此获得了其赠送的#G/%s".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,"钟馗",名称),频道="xt"})
        end
        if 取随机数()<=30 then
          local 名称="金银锦盒"
          玩家数据[id].道具:给予道具(id,名称,1)
          广播消息({内容=format("#S(捉鬼任务)#R/%s#Y完成抓鬼任务中表现优异，#W%s#Y因此获得了其赠送的#G/%s".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,"钟馗",名称),频道="xt"})
        end
      end
      if 老唐定制 then
        local 奖励参数 = 取随机数(1,1000)
        if 奖励参数<=10 then
          礼包奖励类:取随机装备(id,100,"无级别限制")
        elseif 奖励参数<=20 then
          礼包奖励类:取随机装备(id,110,"无级别限制")
        elseif 奖励参数<=30 then
          礼包奖励类:取随机装备(id,120,"无级别限制")
        elseif 奖励参数<=31 then
          礼包奖励类:取随机装备(id,130,"无级别限制")
        elseif 奖励参数<=81 then
          玩家数据[id].道具:给予道具(id,"三界悬赏令")
          常规提示(id,"#Y你获得了三界悬赏令")
        elseif 奖励参数<=101 then
          玩家数据[id].道具:给予道具(id,"贼王的线索")
          常规提示(id,"#Y你获得了贼王的线索")
        end
      end
      玩家数据[id].角色.数据.捉鬼次数=玩家数据[id].角色.数据.捉鬼次数+1
      if 玩家数据[id].角色.数据.捉鬼次数>10 then
        玩家数据[id].角色.数据.捉鬼次数=1
      end
      if id==self.进入战斗玩家id then
        玩家数据[id].战斗对话={名称="钟馗",模型="男人_钟馗",对话="少侠干得不错哟，如果你愿意继续协助我捉拿这些小鬼，我可以帮你直接传送回阴曹地府哟。".."#"..取随机数(1,110),选项={"请送我回阴曹地府","我不想协助你了"}}
        玩家数据[id].钟馗对话=1
      end
    elseif self.战斗类型==100009 then
      local 等级=取队伍平均等级(玩家数据[id].队伍,id)
      local 经验=等级*3000 + 150000
      local 银子=等级*300 + 100000
      if 让海啸席卷 then
        经验=经验*2
        银子=银子*2
      end
      玩家数据[id].角色:添加经验(经验,"二十八星宿")
      玩家数据[id].角色:添加银子(银子,"二十八星宿",1)
      if 玩家数据[id].角色.数据.参战信息~=nil then
        玩家数据[id].召唤兽:获得经验(玩家数据[id].角色.数据.参战宝宝.认证码,qz(经验*0.5),id,"二十八星宿",self.地图等级)
      end
      if 活跃数据[id]==nil then
        活跃数据[id]={活跃度=0,领取100活跃=false,领取200活跃=false,领取300活跃=false,领取400活跃=false,领取500活跃=false,师门次数=20,官职次数=30,鬼怪次数=25,封妖次数=3,游泳次数=1,镖王次数=1,押镖次数=50,水果次数=25,天庭叛逆次数=25,十二星宿次数=5,门派闯关次数=1,地煞星次数=5,天罡星次数=5,飞贼次数=5,知了先锋=20,小知了王=20,知了王=10,世界BOSS次数=2,抓鬼次数=50,初出江湖次数=20,帮派青龙次数=100,帮派玄武次数=100,妖王次数=3}
      end
      if 活跃数据[id].十二星宿次数==nil then
        活跃数据[id].十二星宿次数=5
      end
      if 活跃数据[id].十二星宿次数>0 then
        活跃数据[id].活跃度=活跃数据[id].活跃度+10
        玩家数据[id].角色.数据.累积活跃.当前积分=玩家数据[id].角色.数据.累积活跃.当前积分+活跃数据[id].活跃度
        玩家数据[id].角色.数据.累积活跃.总积分=玩家数据[id].角色.数据.累积活跃.总积分+活跃数据[id].活跃度
        活跃数据[id].十二星宿次数=活跃数据[id].十二星宿次数-1
      end
      local 奖励参数=取随机数()
      if 风雨无言定制 then
        if 奖励参数<=40 then
        elseif 奖励参数<=45 then
          玩家数据[id].道具:给予道具(id,"魔兽要诀")
          发送数据(玩家数据[id].连接id,38,{内容="你得到了#R/魔兽要诀"})
        elseif 奖励参数<=50 then
          玩家数据[id].道具:给予道具(id,"月华露",1,2000)
          发送数据(玩家数据[id].连接id,38,{内容="你得到了#R/月华露"})
        elseif 奖励参数<=55 then
          玩家数据[id].道具:给予道具(id,"超级金柳露")
          发送数据(玩家数据[id].连接id,38,{内容="你得到了#R/超级金柳露"})
        elseif 奖励参数<=60 then
          玩家数据[id].道具:给予道具(id,"金银锦盒",5)
          发送数据(玩家数据[id].连接id,38,{内容="你得到了#R/金银锦盒"})
        elseif 奖励参数<=65 then
          玩家数据[id].道具:给予道具(id,"修炼果",1)
          常规提示(id,"#Y/你获得了修炼果")
        elseif 奖励参数<=70 then
          玩家数据[id].道具:给予道具(id,"修炼果",2)
          常规提示(id,"#Y/你获得了修炼果")
        elseif 奖励参数<=75 then
          玩家数据[id].道具:给予道具(id,"附魔宝珠")
          常规提示(id,"#Y/你获得了附魔宝珠")
        elseif 奖励参数<=80 then
          玩家数据[id].道具:给予道具(id,"高级魔兽要诀")
          常规提示(id,"#Y/你获得了高级魔兽要诀")
        elseif 奖励参数<=85 then
          local 奖励数据=玩家数据[id].道具:给予书铁(id,{10,13})
          常规提示(id,"#Y你得到了#R"..奖励数据[1])
        elseif 奖励参数<=90 then
          玩家数据[id].道具:给予道具(id,"清灵净瓶",1)
          常规提示(id,"#Y/你获得了清灵净瓶")
        elseif 奖励参数<=95 then
          local 名称=取宝石()
          玩家数据[id].道具:给予道具(id,名称,2)
          发送数据(玩家数据[id].连接id,38,{内容="你得到了#R/"..名称})
        end
        if 取随机数()<=2 then
          玩家数据[id].道具:给予道具(id,"三界悬赏令")
          常规提示(id,"#Y你获得了三界悬赏令")
        end
      elseif 让海啸席卷 then
        if 奖励参数<=15 then
          local 名称="上古锻造图策"
          玩家数据[id].道具:给予道具(id,名称,{55,65,75,85,95})
          常规提示(id,"#Y/你获得了"..名称)
        elseif 奖励参数<=30 then
          local 名称="炼妖石"
          玩家数据[id].道具:给予道具(id,名称,{55,65,75,85,95})
          常规提示(id,"#Y/你获得了"..名称)
        elseif 奖励参数<=40 then
          local 名称="仙玉"
          添加仙玉(取随机数(20,50),玩家数据[id].账号,id,"二十八星宿")
        elseif 奖励参数<=45 then
          玩家数据[id].道具:给予道具(id,"魔兽要诀")
          发送数据(玩家数据[id].连接id,38,{内容="你得到了#R/魔兽要诀"})
        elseif 奖励参数<=50 then
          玩家数据[id].道具:给予道具(id,"月华露",1,2000)
          发送数据(玩家数据[id].连接id,38,{内容="你得到了#R/月华露"})
        elseif 奖励参数<=55 then
          玩家数据[id].道具:给予道具(id,"超级金柳露")
          发送数据(玩家数据[id].连接id,38,{内容="你得到了#R/超级金柳露"})
        elseif 奖励参数<=60 then
          玩家数据[id].道具:给予道具(id,"金银锦盒",5)
          发送数据(玩家数据[id].连接id,38,{内容="你得到了#R/金银锦盒"})
        elseif 奖励参数<=65 then
          玩家数据[id].道具:给予道具(id,"修炼果",1)
          常规提示(id,"#Y/你获得了修炼果")
        elseif 奖励参数<=70 then
          玩家数据[id].道具:给予道具(id,"修炼果",2)
          常规提示(id,"#Y/你获得了修炼果")
        elseif 奖励参数<=75 then
          玩家数据[id].道具:给予道具(id,"附魔宝珠")
          常规提示(id,"#Y/你获得了附魔宝珠")
        elseif 奖励参数<=80 then
          玩家数据[id].道具:给予道具(id,"高级魔兽要诀")
          常规提示(id,"#Y/你获得了高级魔兽要诀")
        elseif 奖励参数<=85 then
          local 奖励数据=玩家数据[id].道具:给予书铁(id,{10,13})
          常规提示(id,"#Y你得到了#R"..奖励数据[1])
        elseif 奖励参数<=90 then
          玩家数据[id].道具:给予道具(id,"清灵净瓶",1)
          常规提示(id,"#Y/你获得了清灵净瓶")
        elseif 奖励参数<=95 then
          local 名称=取宝石()
          玩家数据[id].道具:给予道具(id,名称,2)
          发送数据(玩家数据[id].连接id,38,{内容="你得到了#R/"..名称})
        end
        if 取随机数()<=2 then
          玩家数据[id].道具:给予道具(id,"三界悬赏令")
          常规提示(id,"#Y你获得了三界悬赏令")
        end
      else
        if 奖励参数<=15 then
          玩家数据[id].道具:给予道具(id,"魔兽要诀")
          发送数据(玩家数据[id].连接id,38,{内容="你得到了#R/魔兽要诀"})
        elseif 奖励参数<=30 then
          玩家数据[id].道具:给予道具(id,"月华露",1,2000)
          发送数据(玩家数据[id].连接id,38,{内容="你得到了#R/月华露"})
        elseif 奖励参数<=50 then
          玩家数据[id].道具:给予道具(id,"超级金柳露")
          发送数据(玩家数据[id].连接id,38,{内容="你得到了#R/超级金柳露"})
        elseif 奖励参数<=56 and 释怀定制 then
          添加点卡(10,玩家数据[id].账号,id,"二十八星宿")
        elseif 奖励参数<=59 and 释怀定制 then
          添加点卡(30,玩家数据[id].账号,id,"二十八星宿")
        elseif 奖励参数<=70 then
          玩家数据[id].道具:给予道具(id,"金银锦盒",1)
          发送数据(玩家数据[id].连接id,38,{内容="你得到了#R/金银锦盒"})
        elseif 奖励参数<=80 and 神兽定制 then
          local 名称="仙玉"
          添加仙玉(取随机数(10,100),玩家数据[id].账号,id,"二十八星宿")
          常规提示(id,"#Y/你获得了"..名称)
        else
          local 名称=取宝石()
          玩家数据[id].道具:给予道具(id,名称,2)
          发送数据(玩家数据[id].连接id,38,{内容="你得到了#R/"..名称})
        end
        if 取随机数()<=2 then
          玩家数据[id].道具:给予道具(id,"三界悬赏令")
          常规提示(id,"#Y你获得了三界悬赏令")
        end
      end
    elseif self.战斗类型==100010 then
      local 等级=取队伍平均等级(玩家数据[id].队伍,id)
      local 经验=等级*200+3000
      local 银子=50000
      if 让海啸席卷 then
        银子=银子*4
        经验=经验*4
      end
      玩家数据[id].角色:添加经验(经验,"妖魔鬼怪")
      玩家数据[id].角色:添加银子(银子,"妖魔鬼怪",1)
      if 让海啸席卷 and 取随机数()<=15 then
        添加仙玉(取随机数(1,5),玩家数据[id].账号,id,"妖魔鬼怪")
      end
      if 老八定制 and 玩家数据[id].角色.数据.帮派数据~=nil then
        添加帮贡(id,5)
      end
      if 玩家数据[id].角色.数据.参战信息~=nil then
        玩家数据[id].召唤兽:获得经验(玩家数据[id].角色.数据.参战宝宝.认证码,qz(经验*0.5),id,"妖魔鬼怪",self.地图等级)
      end
      if 妖魔积分[id]==nil then
         妖魔积分[id]={当前=0,总计=0,使用=0}
      end
      if 活跃数据[id]==nil then
        活跃数据[id]={活跃度=0,领取100活跃=false,领取200活跃=false,领取300活跃=false,领取400活跃=false,领取500活跃=false,师门次数=20,官职次数=30,鬼怪次数=25,封妖次数=3,游泳次数=1,镖王次数=1,押镖次数=50,水果次数=25,天庭叛逆次数=25,十二星宿次数=5,门派闯关次数=1,地煞星次数=5,天罡星次数=5,飞贼次数=5,知了先锋=20,小知了王=20,知了王=10,世界BOSS次数=2,抓鬼次数=50,初出江湖次数=20,帮派青龙次数=100,帮派玄武次数=100,妖王次数=3}
      end
      if 活跃数据[id].鬼怪次数==nil then
        活跃数据[id].鬼怪次数=25
      end
      if 活跃数据[id].鬼怪次数>0 then
        活跃数据[id].活跃度=活跃数据[id].活跃度+2
        玩家数据[id].角色.数据.累积活跃.当前积分=玩家数据[id].角色.数据.累积活跃.当前积分+活跃数据[id].活跃度
        玩家数据[id].角色.数据.累积活跃.总积分=玩家数据[id].角色.数据.累积活跃.总积分+活跃数据[id].活跃度
        活跃数据[id].鬼怪次数=活跃数据[id].鬼怪次数-1
      end
      妖魔积分[id].当前=妖魔积分[id].当前+1
      妖魔积分[id].总计=妖魔积分[id].总计+1
      常规提示(id,"#Y/你获得了1点妖魔积分，妖魔积分可在长安城袁天罡处兑换奖励")
      if 老八定制 then
        local 随机参数 = 取随机数()
        if 随机参数<=3  then
          local 名称="灵饰指南书"
          玩家数据[id].道具:给予道具(id,"灵饰指南书",{6,8})
          常规提示(id,"#Y/你获得了"..名称)
          广播消息({内容=format("#S(妖魔鬼怪)#R/%s#Y经过一番激烈的战斗，最终战胜了#R%s#Y，#Y因此获得了唐王奖励的#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,任务数据[self.任务id].名称,名称),频道="xt"})
        elseif 随机参数<=6  then
          local 名称="元灵晶石"
          玩家数据[id].道具:给予道具(id,"元灵晶石",{6,8})
          常规提示(id,"#Y/你获得了"..名称)
          广播消息({内容=format("#S(妖魔鬼怪)#R/%s#Y经过一番激烈的战斗，最终战胜了#R%s#Y，#Y因此获得了唐王奖励的#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,任务数据[self.任务id].名称,名称),频道="xt"})
        elseif 随机参数<=10 then
          local 名称="彩果"
          玩家数据[id].道具:给予道具(id,名称,1)
          常规提示(id,"#Y/你获得了"..名称)
          广播消息({内容=format("#S(妖魔鬼怪)#R/%s#Y经过一番激烈的战斗，最终战胜了#R%s#Y，#Y因此获得了唐王奖励的#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,任务数据[self.任务id].名称,名称),频道="xt"})
        end
      elseif 让海啸席卷 then
        local 随机参数 = 取随机数()
        if 随机参数<=20  then
          local 名称=取宝石()
          玩家数据[id].道具:给予道具(id,名称,取随机数(1,4))
          常规提示(id,"#Y/你获得了"..名称)
          广播消息({内容=format("#S(妖魔鬼怪)#R/%s#Y经过一番激烈的战斗，最终战胜了#R%s#Y，#Y因此获得了唐王奖励的#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,任务数据[self.任务id].名称,名称),频道="xt"})
        elseif 随机参数<=40 then
          local 名称="仙玉"
          添加仙玉(取随机数(20,50),玩家数据[id].账号,id,"妖魔鬼怪")
          常规提示(id,"#Y/你获得了"..名称)
          广播消息({内容=format("#S(妖魔鬼怪)#R/%s#Y经过一番激烈的战斗，最终战胜了#R%s#Y，#Y因此获得了唐王奖励的#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,任务数据[self.任务id].名称,名称),频道="xt"})
        end
      end
    elseif self.战斗类型==100011 then
      local 等级=取队伍平均等级(玩家数据[id].队伍,id)
      local 任务id1=玩家数据[id].角色:取任务(107)
      local 经验=qz((等级*330+25000)*(1+(15-#任务数据[任务id1].闯关序列)*0.05))
      local 银子=qz(等级*500)
      玩家数据[id].角色:添加经验(经验,"门派闯关")
      玩家数据[id].角色:添加银子(银子,"门派闯关",1)
      if 玩家数据[id].角色.数据.参战信息~=nil then
         玩家数据[id].召唤兽:获得经验(玩家数据[id].角色.数据.参战宝宝.认证码,qz(经验*0.5),id,"门派闯关",self.地图等级)
      end
      if 活跃数据[id]==nil then
        活跃数据[id]={活跃度=0,领取100活跃=false,领取200活跃=false,领取300活跃=false,领取400活跃=false,领取500活跃=false,师门次数=20,官职次数=30,鬼怪次数=25,封妖次数=3,游泳次数=1,镖王次数=1,押镖次数=50,水果次数=25,天庭叛逆次数=25,十二星宿次数=5,门派闯关次数=1,地煞星次数=5,天罡星次数=5,飞贼次数=5,知了先锋=20,小知了王=20,知了王=10,世界BOSS次数=2,抓鬼次数=50,初出江湖次数=20,帮派青龙次数=100,帮派玄武次数=100,妖王次数=3}
      end
      if 活跃数据[id].门派闯关次数==nil then
        活跃数据[id].门派闯关次数=1
      end
      if 活跃数据[id].门派闯关次数>0 then
        活跃数据[id].活跃度=活跃数据[id].活跃度+50
        玩家数据[id].角色.数据.累积活跃.当前积分=玩家数据[id].角色.数据.累积活跃.当前积分+活跃数据[id].活跃度
        玩家数据[id].角色.数据.累积活跃.总积分=玩家数据[id].角色.数据.累积活跃.总积分+活跃数据[id].活跃度
        活跃数据[id].门派闯关次数=活跃数据[id].门派闯关次数-1
      end
      if 老唐定制 then
          local 奖励参数=取随机数(1,80)
          if 奖励参数<=50 then
            local 药品名称={"孔雀红","鹿茸","仙狐涎","地狱灵芝","六道轮回","凤凰尾","火凤之睛","龙之心屑","紫石英","白露为霜"}
            local 名称=药品名称[取随机数(1,#药品名称)]
            玩家数据[id].道具:给予道具(id,名称,10)
            常规提示(id,"#Y/你获得了"..名称)
          elseif 奖励参数<=55 then
            local 名称="超级金柳露"
            玩家数据[id].道具:给予道具(id,名称)
            常规提示(id,"#Y/你获得了"..名称)
            广播消息({内容=format("#S(门派闯关)#R/%s#Y在门派闯关活动表现优异，获得了门派护法奖励的#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,名称),频道="xt"})
          elseif 奖励参数<=65 then
            local 名称=玩家数据[id].道具:取五宝()
            玩家数据[id].道具:给予道具(id,名称)
            常规提示(id,"#Y/你获得了"..名称)
            广播消息({内容=format("#S(门派闯关)#R/%s#Y在门派闯关活动表现优异，获得了门派护法奖励的#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,名称),频道="xt"})
          elseif 奖励参数<=70 then
            local 名称="九转金丹"
            玩家数据[id].道具:给予道具(id,名称,1,500)
            常规提示(id,"#Y/你获得了"..名称)
            广播消息({内容=format("#S(门派闯关)#R/%s#Y在门派闯关活动表现优异，获得了门派护法奖励的#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,名称),频道="xt"})
          elseif 奖励参数<=75 then
            local 名称="修炼果"
            玩家数据[id].道具:给予道具(id,名称,1)
            常规提示(id,"#Y/你获得了"..名称)
            广播消息({内容=format("#S(门派闯关)#R/%s#Y在门派闯关活动表现优异，获得了门派护法奖励的#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,名称),频道="xt"})
          elseif 奖励参数<=80 then
            local 名称="高级魔兽要诀"
            玩家数据[id].道具:给予道具(id,名称)
            常规提示(id,"#Y/你获得了"..名称)
            广播消息({内容=format("#S(门派闯关)#R/%s#Y在门派闯关活动表现优异，获得了门派护法奖励的#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,名称),频道="xt"})
          end
      elseif 风雨无言定制 then
        if 取随机数()<=40 then
          local 奖励参数=取随机数()
          if 奖励参数<=30 then --2级药
            local 药品名称={"孔雀红","鹿茸","仙狐涎","地狱灵芝","六道轮回","凤凰尾","火凤之睛","龙之心屑","紫石英","白露为霜"}
            local 名称=药品名称[取随机数(1,#药品名称)]
            玩家数据[id].道具:给予道具(id,名称,10)
            常规提示(id,"#Y/你获得了"..名称)
          else
            local 名称="金柳露"
            玩家数据[id].道具:给予道具(id,名称)
            常规提示(id,"#Y/你获得了"..名称)
          end
        else
          local 奖励参数=取随机数(1,1000)
          if 奖励参数<=300 then
          elseif 奖励参数<=450 then
            local 名称=取宝石()
            玩家数据[id].道具:给予道具(id,名称,取随机数(1,2))
            常规提示(id,"#Y/你获得了"..名称)
            广播消息({内容=format("#S(门派闯关)#R/%s#Y在门派闯关活动表现优异，获得了门派护法奖励的#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,名称),频道="xt"})
          elseif 奖励参数<=500 then
            local 名称="高级魔兽要诀"
            玩家数据[id].道具:给予道具(id,名称)
            常规提示(id,"#Y/你获得了"..名称)
            广播消息({内容=format("#S(门派闯关)#R/%s#Y在门派闯关活动表现优异，获得了门派护法奖励的#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,名称),频道="xt"})
          elseif 奖励参数<=550 then
            local 名称="魔兽要诀"
            玩家数据[id].道具:给予道具(id,名称)
            常规提示(id,"#Y/你获得了"..名称)
            广播消息({内容=format("#S(门派闯关)#R/%s#Y在门派闯关活动表现优异，获得了门派护法奖励的#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,名称),频道="xt"})
          elseif 奖励参数<=600 then
            local 名称="九转金丹"
            玩家数据[id].道具:给予道具(id,名称,1,40)
            常规提示(id,"#Y/你获得了"..名称)
            广播消息({内容=format("#S(门派闯关)#R/%s#Y在门派闯关活动表现优异，获得了门派护法奖励的#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,名称),频道="xt"})
          elseif 奖励参数<=650 then
            local 名称="超级金柳露"
            玩家数据[id].道具:给予道具(id,名称)
            常规提示(id,"#Y/你获得了"..名称)
            广播消息({内容=format("#S(门派闯关)#R/%s#Y在门派闯关活动表现优异，获得了门派护法奖励的#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,名称),频道="xt"})
          elseif 奖励参数<=700 then
            local 名称="金银锦盒"
            玩家数据[id].道具:给予道具(id,名称,5)
            常规提示(id,"#Y/你获得了"..名称)
            广播消息({内容=format("#S(门派闯关)#R/%s#Y在门派闯关活动表现优异，获得了门派护法奖励的#G/%s*5#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,名称),频道="xt"})
          elseif 奖励参数<=750 then
            local 名称=玩家数据[id].道具:取五宝()
            玩家数据[id].道具:给予道具(id,名称)
            常规提示(id,"#Y/你获得了"..名称)
            广播消息({内容=format("#S(门派闯关)#R/%s#Y在门派闯关活动表现优异，获得了门派护法奖励的#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,名称),频道="xt"})
          elseif 奖励参数>=800 then
            local 名称="星辉石"
            玩家数据[id].道具:给予道具(id,名称,1)
            常规提示(id,"#Y/你获得了"..名称)
            广播消息({内容=format("#S(门派闯关)#R/%s#Y在门派闯关活动表现优异，获得了门派护法奖励的#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,名称),频道="xt"})
          elseif 奖励参数>=850 then
            local 名称="修炼果"
            玩家数据[id].道具:给予道具(id,名称,1)
            常规提示(id,"#Y/你获得了"..名称)
            广播消息({内容=format("#S(门派闯关)#R/%s#Y在门派闯关活动表现优异，获得了门派护法奖励的#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,名称),频道="xt"})
          elseif 奖励参数>=900 then
            local 名称="修炼果"
            玩家数据[id].道具:给予道具(id,名称,5)
            常规提示(id,"#Y/你获得了"..名称)
            广播消息({内容=format("#S(门派闯关)#R/%s#Y在门派闯关活动表现优异，获得了门派护法奖励的#G/%s*5#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,名称),频道="xt"})
          elseif 奖励参数<=950 then
            local 名称="附魔宝珠"
            玩家数据[id].道具:给予道具(id,名称)
            常规提示(id,"#Y/你获得了"..名称)
            广播消息({内容=format("#S(门派闯关)#R/%s#Y在门派闯关活动表现优异，获得了门派护法奖励的#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,名称),频道="xt"})
          elseif 奖励参数<=980 then
            local 名称="附魔宝珠"
            玩家数据[id].道具:给予道具(id,名称)
            常规提示(id,"#Y/你获得了"..名称)
            广播消息({内容=format("#S(门派闯关)#R/%s#Y在门派闯关活动表现优异，获得了门派护法奖励的#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,名称),频道="xt"})
          elseif 奖励参数<=1000 then
            local 名称=玩家数据[临时id].道具:给予书铁(临时id,{10,13})
            常规提示(临时id,"#Y你得到了#R"..名称[1])
            广播消息({内容=format("#S(门派闯关)#R/%s#Y在门派闯关活动表现优异，获得了门派护法奖励的#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,名称[1]),频道="xt"})
          end
        end
      elseif 老八定制 then
        if 取随机数()<=50 then
          local 奖励参数=取随机数()
          if 奖励参数<=30 then --2级药
            local 药品名称={"孔雀红","鹿茸","仙狐涎","地狱灵芝","六道轮回","凤凰尾","火凤之睛","龙之心屑","紫石英","白露为霜"}
            local 名称=药品名称[取随机数(1,#药品名称)]
            玩家数据[id].道具:给予道具(id,名称,10)
            常规提示(id,"#Y/你获得了"..名称)
          elseif 奖励参数 <= 40 then
            local 名称="怪物卡片"
            玩家数据[id].道具:给予道具(id,名称,取随机数(5,8))
            常规提示(id,"#Y/你获得了"..名称)
            广播消息({内容=format("#S(门派闯关)#R/%s#Y在门派闯关活动表现优异，获得了门派护法奖励的#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,名称),频道="xt"})
          elseif 奖励参数 <= 50 then
            local 名称=取宝石()
            玩家数据[id].道具:给予道具(id,名称,1)
            常规提示(id,"#Y/你获得了"..名称)
            广播消息({内容=format("#S(门派闯关)#R/%s#Y在门派闯关活动表现优异，获得了门派护法奖励的#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,名称),频道="xt"})
          elseif 奖励参数 <= 70 then
            local 名称="金柳露"
            玩家数据[id].道具:给予道具(id,名称)
            常规提示(id,"#Y/你获得了"..名称)
          end
        else
          local 奖励参数=取随机数(1,1000)
          if 奖励参数<=100 then
            local 名称=取宝石()
            玩家数据[id].道具:给予道具(id,名称,取随机数(1,2))
            常规提示(id,"#Y/你获得了"..名称)
            广播消息({内容=format("#S(门派闯关)#R/%s#Y在门派闯关活动表现优异，获得了门派护法奖励的#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,名称),频道="xt"})
          elseif 奖励参数<=180 then
            local 名称="高级魔兽要诀"
            玩家数据[id].道具:给予道具(id,名称)
            常规提示(id,"#Y/你获得了"..名称)
            广播消息({内容=format("#S(门派闯关)#R/%s#Y在门派闯关活动表现优异，获得了门派护法奖励的#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,名称),频道="xt"})
          elseif 奖励参数<=250 then
            local 名称="魔兽要诀"
            玩家数据[id].道具:给予道具(id,名称)
            常规提示(id,"#Y/你获得了"..名称)
            广播消息({内容=format("#S(门派闯关)#R/%s#Y在门派闯关活动表现优异，获得了门派护法奖励的#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,名称),频道="xt"})
          elseif 奖励参数<=300 then
            local 名称="九转金丹"
            玩家数据[id].道具:给予道具(id,名称,1,40)
            常规提示(id,"#Y/你获得了"..名称)
            广播消息({内容=format("#S(门派闯关)#R/%s#Y在门派闯关活动表现优异，获得了门派护法奖励的#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,名称),频道="xt"})
          elseif 奖励参数<=500 then
            local 名称="超级金柳露"
            玩家数据[id].道具:给予道具(id,名称)
            常规提示(id,"#Y/你获得了"..名称)
            广播消息({内容=format("#S(门派闯关)#R/%s#Y在门派闯关活动表现优异，获得了门派护法奖励的#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,名称),频道="xt"})
          elseif 奖励参数<=700 then
            local 名称="金银锦盒"
            玩家数据[id].道具:给予道具(id,名称,1)
            常规提示(id,"#Y/你获得了"..名称)
            广播消息({内容=format("#S(门派闯关)#R/%s#Y在门派闯关活动表现优异，获得了门派护法奖励的#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,名称),频道="xt"})
          elseif 奖励参数<=800 then
            local 名称=玩家数据[id].道具:取五宝()
            玩家数据[id].道具:给予道具(id,名称)
            常规提示(id,"#Y/你获得了"..名称)
            广播消息({内容=format("#S(门派闯关)#R/%s#Y在门派闯关活动表现优异，获得了门派护法奖励的#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,名称),频道="xt"})
          elseif 奖励参数>=900 then
            local 名称="星辉石"
            玩家数据[id].道具:给予道具(id,名称,1)
            常规提示(id,"#Y/你获得了"..名称)
            广播消息({内容=format("#S(门派闯关)#R/%s#Y在门派闯关活动表现优异，获得了门派护法奖励的#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,名称),频道="xt"})
          end
          if 奖励参数>=800 and 神兽定制 then
            local 名称="仙玉"
            添加仙玉(取随机数(10,100),玩家数据[id].账号,id,"门派闯关")
            常规提示(id,"#Y/你获得了"..名称)
          end
        end
      elseif 让海啸席卷 then
        if 取随机数()<=50 then
          local 奖励参数=取随机数()
          if 奖励参数<=30 then --2级药
            local 药品名称={"孔雀红","鹿茸","仙狐涎","地狱灵芝","六道轮回","凤凰尾","火凤之睛","龙之心屑","紫石英","白露为霜"}
            local 名称=药品名称[取随机数(1,#药品名称)]
            玩家数据[id].道具:给予道具(id,名称,10)
            常规提示(id,"#Y/你获得了"..名称)
          else
            local 名称="金柳露"
            玩家数据[id].道具:给予道具(id,名称)
            常规提示(id,"#Y/你获得了"..名称)
          end
        else
          local 奖励参数=取随机数(1,1000)
          if 奖励参数<=100 then
            local 名称=取宝石()
            玩家数据[id].道具:给予道具(id,名称,取随机数(3,7))
            常规提示(id,"#Y/你获得了"..名称)
            广播消息({内容=format("#S(门派闯关)#R/%s#Y在门派闯关活动表现优异，获得了门派护法奖励的#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,名称),频道="xt"})
          elseif 奖励参数<=150 then
            local 名称="高级魔兽要诀"
            玩家数据[id].道具:给予道具(id,名称)
            常规提示(id,"#Y/你获得了"..名称)
            广播消息({内容=format("#S(门派闯关)#R/%s#Y在门派闯关活动表现优异，获得了门派护法奖励的#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,名称),频道="xt"})
          elseif 奖励参数<=200 then
            local 名称="魔兽要诀"
            玩家数据[id].道具:给予道具(id,名称)
            常规提示(id,"#Y/你获得了"..名称)
            广播消息({内容=format("#S(门派闯关)#R/%s#Y在门派闯关活动表现优异，获得了门派护法奖励的#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,名称),频道="xt"})
          elseif 奖励参数<=250 then
            local 名称="九转金丹"
            玩家数据[id].道具:给予道具(id,名称,1,40)
            常规提示(id,"#Y/你获得了"..名称)
            广播消息({内容=format("#S(门派闯关)#R/%s#Y在门派闯关活动表现优异，获得了门派护法奖励的#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,名称),频道="xt"})
          elseif 奖励参数<=300 then
            local 名称="仙玉"
            添加仙玉(取随机数(20,50),玩家数据[id].账号,id,"门派闯关")
            常规提示(id,"#Y/你获得了"..名称)
            广播消息({内容=format("#S(门派闯关)#R/%s#Y在门派闯关活动表现优异，获得了门派护法奖励的#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,名称),频道="xt"})
          elseif 奖励参数<=400 then
            local 名称="炼兽真经"
            玩家数据[id].道具:给予道具(id,名称,1)
            常规提示(id,"#Y/你获得了"..名称)
            广播消息({内容=format("#S(门派闯关)#R/%s#Y在门派闯关活动表现优异，获得了门派护法奖励的#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,名称),频道="xt"})
          elseif 奖励参数<=500 then
            local 名称="超级金柳露"
            玩家数据[id].道具:给予道具(id,名称)
            常规提示(id,"#Y/你获得了"..名称)
            广播消息({内容=format("#S(门派闯关)#R/%s#Y在门派闯关活动表现优异，获得了门派护法奖励的#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,名称),频道="xt"})
          elseif 奖励参数<=600 then
            local 名称="元宵"
            玩家数据[id].道具:给予道具(id,名称,1)
            常规提示(id,"#Y/你获得了"..名称)
            广播消息({内容=format("#S(门派闯关)#R/%s#Y在门派闯关活动表现优异，获得了门派护法奖励的#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,名称),频道="xt"})
          elseif 奖励参数<=700 then
            local 名称="金银锦盒"
            玩家数据[id].道具:给予道具(id,名称,1)
            常规提示(id,"#Y/你获得了"..名称)
            广播消息({内容=format("#S(门派闯关)#R/%s#Y在门派闯关活动表现优异，获得了门派护法奖励的#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,名称),频道="xt"})
          elseif 奖励参数<=800 then
            local 名称=玩家数据[id].道具:取五宝()
            玩家数据[id].道具:给予道具(id,名称)
            常规提示(id,"#Y/你获得了"..名称)
            广播消息({内容=format("#S(门派闯关)#R/%s#Y在门派闯关活动表现优异，获得了门派护法奖励的#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,名称),频道="xt"})
          elseif 奖励参数 <= 900 and 让海啸席卷 then
            local 名称="魔兽残卷"
            玩家数据[id].道具:给予道具(id,名称,1)
            常规提示(id,"#Y/你获得了"..名称)
            广播消息({内容=format("#S(门派闯关)#R/%s#Y在门派闯关活动表现优异，获得了门派护法奖励的#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,名称),频道="xt"})
          elseif 奖励参数>=900 then
            local 名称="星辉石"
            玩家数据[id].道具:给予道具(id,名称,1)
            常规提示(id,"#Y/你获得了"..名称)
            广播消息({内容=format("#S(门派闯关)#R/%s#Y在门派闯关活动表现优异，获得了门派护法奖励的#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,名称),频道="xt"})
          end
        end
      else
        if 取随机数()<=50 then
          local 奖励参数=取随机数()
          if 奖励参数<=30 then --2级药
            local 药品名称={"孔雀红","鹿茸","仙狐涎","地狱灵芝","六道轮回","凤凰尾","火凤之睛","龙之心屑","紫石英","白露为霜"}
            local 名称=药品名称[取随机数(1,#药品名称)]
            玩家数据[id].道具:给予道具(id,名称,10)
            常规提示(id,"#Y/你获得了"..名称)
          else
            local 名称="金柳露"
            玩家数据[id].道具:给予道具(id,名称)
            常规提示(id,"#Y/你获得了"..名称)
          end
        else
          local 奖励参数=取随机数(1,1000)
          if 奖励参数<=100 then
            local 名称=取宝石()
            玩家数据[id].道具:给予道具(id,名称,取随机数(1,2))
            常规提示(id,"#Y/你获得了"..名称)
            广播消息({内容=format("#S(门派闯关)#R/%s#Y在门派闯关活动表现优异，获得了门派护法奖励的#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,名称),频道="xt"})
          elseif 奖励参数<=120 then
            local 名称="高级魔兽要诀"
            玩家数据[id].道具:给予道具(id,名称)
            常规提示(id,"#Y/你获得了"..名称)
            广播消息({内容=format("#S(门派闯关)#R/%s#Y在门派闯关活动表现优异，获得了门派护法奖励的#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,名称),频道="xt"})
          elseif 奖励参数<=250 then
            local 名称="魔兽要诀"
            玩家数据[id].道具:给予道具(id,名称)
            常规提示(id,"#Y/你获得了"..名称)
            广播消息({内容=format("#S(门派闯关)#R/%s#Y在门派闯关活动表现优异，获得了门派护法奖励的#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,名称),频道="xt"})
          elseif 奖励参数<=300 then
            local 名称="九转金丹"
            玩家数据[id].道具:给予道具(id,名称,1,40)
            常规提示(id,"#Y/你获得了"..名称)
            广播消息({内容=format("#S(门派闯关)#R/%s#Y在门派闯关活动表现优异，获得了门派护法奖励的#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,名称),频道="xt"})
          elseif 奖励参数<=500 then
            local 名称="超级金柳露"
            玩家数据[id].道具:给予道具(id,名称)
            常规提示(id,"#Y/你获得了"..名称)
            广播消息({内容=format("#S(门派闯关)#R/%s#Y在门派闯关活动表现优异，获得了门派护法奖励的#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,名称),频道="xt"})
          elseif 奖励参数<=700 then
            local 名称="金银锦盒"
            玩家数据[id].道具:给予道具(id,名称,1)
            常规提示(id,"#Y/你获得了"..名称)
            广播消息({内容=format("#S(门派闯关)#R/%s#Y在门派闯关活动表现优异，获得了门派护法奖励的#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,名称),频道="xt"})
          elseif 奖励参数<=800 then
            local 名称=玩家数据[id].道具:取五宝()
            玩家数据[id].道具:给予道具(id,名称)
            常规提示(id,"#Y/你获得了"..名称)
            广播消息({内容=format("#S(门派闯关)#R/%s#Y在门派闯关活动表现优异，获得了门派护法奖励的#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,名称),频道="xt"})
          elseif 奖励参数>=900 then
            local 名称="星辉石"
            玩家数据[id].道具:给予道具(id,名称,1)
            常规提示(id,"#Y/你获得了"..名称)
            广播消息({内容=format("#S(门派闯关)#R/%s#Y在门派闯关活动表现优异，获得了门派护法奖励的#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,名称),频道="xt"})
          end
          if 奖励参数>=800 and 神兽定制 then
            local 名称="仙玉"
            添加仙玉(取随机数(10,100),玩家数据[id].账号,id,"门派闯关")
            常规提示(id,"#Y/你获得了"..名称)
          end
        end
      end
  elseif self.战斗类型==100020 then
    local 等级=取队伍平均等级(玩家数据[id].队伍,id)
    local 经验=qz(等级*等级*20*0.3+100000)
    local 银子=qz(等级*1000)
    玩家数据[id].角色:添加经验(经验,"妖王战斗")
    玩家数据[id].角色:添加银子(银子,"妖王战斗",1)
    if 玩家数据[id].角色.数据.参战信息~=nil then
      玩家数据[id].召唤兽:获得经验(玩家数据[id].角色.数据.参战宝宝.认证码,qz(经验*0.5),id,"妖王战斗",self.地图等级)
    end
    if 活跃数据[id]==nil then
      活跃数据[id]={活跃度=0,领取100活跃=false,领取200活跃=false,领取300活跃=false,领取400活跃=false,领取500活跃=false,师门次数=20,官职次数=30,鬼怪次数=25,封妖次数=3,游泳次数=1,镖王次数=1,押镖次数=50,水果次数=25,天庭叛逆次数=25,十二星宿次数=5,门派闯关次数=1,地煞星次数=5,天罡星次数=5,飞贼次数=5,知了先锋=20,小知了王=20,知了王=10,世界BOSS次数=2,抓鬼次数=50,初出江湖次数=20,帮派青龙次数=100,帮派玄武次数=100,妖王次数=3}
    end
    if 活跃数据[id].妖王次数==nil then
      活跃数据[id].妖王次数=3
    end
    if 活跃数据[id].妖王次数>0 then
      活跃数据[id].活跃度=活跃数据[id].活跃度+20
      玩家数据[id].角色.数据.累积活跃.当前积分=玩家数据[id].角色.数据.累积活跃.当前积分+活跃数据[id].活跃度
      玩家数据[id].角色.数据.累积活跃.总积分=玩家数据[id].角色.数据.累积活跃.总积分+活跃数据[id].活跃度
      活跃数据[id].妖王次数=活跃数据[id].妖王次数-1
    end
    local 奖励参数=取随机数(1,1500)
    if 奖励参数<=100 then
      local 名称=取宝石()
      玩家数据[id].道具:给予道具(id,名称,取随机数(1,2))
      常规提示(id,"#Y/你获得了"..名称)
    elseif 奖励参数<=110 then
      local 名称="魔兽要诀"
      玩家数据[id].道具:给予道具(id,名称)
      常规提示(id,"#Y/你获得了"..名称)
    elseif 奖励参数<=500 then
      local 名称="彩果"
      玩家数据[id].道具:给予道具(id,名称,1)
      常规提示(id,"#Y/你获得了"..名称)
    elseif 奖励参数<=900 then
      local 名称="金银锦盒"
      玩家数据[id].道具:给予道具(id,名称,1)
      常规提示(id,"#Y/你获得了"..名称)
    elseif 奖励参数<=1000 then
      local 名称=玩家数据[id].道具:取五宝()
      玩家数据[id].道具:给予道具(id,名称)
      常规提示(id,"#Y/你获得了"..名称)
    else
      local 名称="一级未激活符石"
      玩家数据[id].道具:给予道具(id,名称,1)
      常规提示(id,"#Y/你获得了"..名称)
    end
  elseif self.战斗类型==100021 then
    local 等级=玩家数据[id].角色.数据.等级
    local 经验=qz(等级*等级*15*(玩家数据[id].角色.数据.江湖次数*0.15+1)*0.3+20000)
    local 银子=qz(等级*1000)
    玩家数据[id].角色:添加经验(经验,"初出江湖")
    玩家数据[id].角色:添加储备(银子,"初出江湖",1)
    if 玩家数据[id].角色.数据.参战信息~=nil then
      玩家数据[id].召唤兽:获得经验(玩家数据[id].角色.数据.参战宝宝.认证码,qz(经验*0.5),id,"初出江湖",self.地图等级)
    end
    if 活跃数据[id]==nil then
      活跃数据[id]={活跃度=0,领取100活跃=false,领取200活跃=false,领取300活跃=false,领取400活跃=false,领取500活跃=false,师门次数=20,官职次数=30,鬼怪次数=25,封妖次数=3,游泳次数=1,镖王次数=1,押镖次数=50,水果次数=25,天庭叛逆次数=25,十二星宿次数=5,门派闯关次数=1,地煞星次数=5,天罡星次数=5,飞贼次数=5,知了先锋=20,小知了王=20,知了王=10,世界BOSS次数=2,抓鬼次数=50,初出江湖次数=20,帮派青龙次数=100,帮派玄武次数=100,妖王次数=3}
    end
    if 活跃数据[id].初出江湖次数==nil then
      活跃数据[id].初出江湖次数=20
    end
    if 活跃数据[id].初出江湖次数>0 then
      活跃数据[id].活跃度=活跃数据[id].活跃度+2
      玩家数据[id].角色.数据.累积活跃.当前积分=玩家数据[id].角色.数据.累积活跃.当前积分+活跃数据[id].活跃度
      玩家数据[id].角色.数据.累积活跃.总积分=玩家数据[id].角色.数据.累积活跃.总积分+活跃数据[id].活跃度
      活跃数据[id].初出江湖次数=活跃数据[id].初出江湖次数-1
    end
    if 玩家数据[id].角色.数据.江湖次数>=10 then
      玩家数据[id].角色.数据.江湖次数=0
      玩家数据[id].道具:给予书铁(id,{4,6})
      if 取随机数()<=40 then
        local 名称="金银锦盒"
        玩家数据[id].道具:给予道具(id,名称,1)
        常规提示(id,"#Y/你获得了"..名称)
      end
    end
    玩家数据[id].角色:取消任务(self.任务id)
  elseif self.战斗类型==100022 then
    local 等级=玩家数据[id].角色.数据.等级
    local 经验=qz(等级*等级*15*任务数据[self.任务id].分类*0.3)
    if 让海啸席卷 then
      经验=经验*2
    end
    玩家数据[id].角色:添加经验(经验,"皇宫飞贼")
    if 玩家数据[id].角色.数据.参战信息~=nil then
      玩家数据[id].召唤兽:获得经验(玩家数据[id].角色.数据.参战宝宝.认证码,qz(经验*0.5),id,"皇宫飞贼",self.地图等级)
    end
    玩家数据[id].角色:取消任务(self.任务id)
    if 皇宫飞贼[id]==nil then
      皇宫飞贼[id]=1
    end
    if 活跃数据[id]==nil then
      活跃数据[id]={活跃度=0,领取100活跃=false,领取200活跃=false,领取300活跃=false,领取400活跃=false,领取500活跃=false,师门次数=20,官职次数=30,鬼怪次数=25,封妖次数=3,游泳次数=1,镖王次数=1,押镖次数=50,水果次数=25,天庭叛逆次数=25,十二星宿次数=5,门派闯关次数=1,地煞星次数=5,天罡星次数=5,飞贼次数=5,知了先锋=20,小知了王=20,知了王=10,世界BOSS次数=2,抓鬼次数=50,初出江湖次数=20,帮派青龙次数=100,帮派玄武次数=100,妖王次数=3}
    end
    if 活跃数据[id].飞贼次数==nil then
      活跃数据[id].飞贼次数=5
    end
    if 活跃数据[id].飞贼次数>0 then
      活跃数据[id].活跃度=活跃数据[id].活跃度+10
      玩家数据[id].角色.数据.累积活跃.当前积分=玩家数据[id].角色.数据.累积活跃.当前积分+活跃数据[id].活跃度
      玩家数据[id].角色.数据.累积活跃.总积分=玩家数据[id].角色.数据.累积活跃.总积分+活跃数据[id].活跃度
      活跃数据[id].飞贼次数=活跃数据[id].飞贼次数-1
    end
    if 取随机数()<=30 then
      local 名称="金银锦盒"
      玩家数据[id].道具:给予道具(id,名称,1)
      常规提示(id,"#Y/你获得了"..名称)
    end
    皇宫飞贼[id]=任务数据[self.任务id].分类+1
    if 皇宫飞贼[id]==5 then
      皇宫飞贼[id]=1
      if 皇宫飞贼.贼王[id]==nil then
        皇宫飞贼.贼王[id]=0
      end
      皇宫飞贼.贼王[id]=皇宫飞贼.贼王[id]+1
    end
  elseif self.战斗类型==100023 then
     local 等级=玩家数据[id].角色.数据.等级
     local 经验=qz(等级*等级*40*1.5*0.3)
     if 让海啸席卷 then
       经验=经验*2
     end
     玩家数据[id].角色:添加经验(经验,"皇宫飞贼贼王")
     if 玩家数据[id].角色.数据.参战信息~=nil then
        玩家数据[id].召唤兽:获得经验(玩家数据[id].角色.数据.参战宝宝.认证码,qz(经验*0.5),id,"皇宫飞贼贼王",self.地图等级)
     end

      玩家数据[id].角色:取消任务(self.任务id)
      皇宫飞贼.贼王[id]=nil
      local 奖励参数=取随机数()
      if 奖励参数<=15 then
        local 名称="高级魔兽要诀"
        玩家数据[id].道具:给予道具(id,名称)
        常规提示(id,"#Y/你获得了"..名称)
        广播消息({内容=format("#S(皇宫飞贼)#R/%s#Y成功缉拿住幕后贼王，因此获得了御林军左统领奖励的的#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,名称),频道="xt"})
      elseif 奖励参数<=25 and 让海啸席卷 then
        local 名称="怪物卡片"
        玩家数据[id].道具:给予道具(id,名称,取随机数(2,3))
        常规提示(id,"#Y/你获得了"..名称)
        广播消息({内容=format("#S(皇宫飞贼)#R/%s#Y成功缉拿住幕后贼王，因此获得了御林军左统领奖励的的#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,名称),频道="xt"})
      elseif 奖励参数<=35 and 让海啸席卷 then
        local 名称="炼兽真经"
        玩家数据[id].道具:给予道具(id,名称,1)
        常规提示(id,"#Y/你获得了"..名称)
        广播消息({内容=format("#S(皇宫飞贼)#R/%s#Y成功缉拿住幕后贼王，因此获得了御林军左统领奖励的的#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,名称),频道="xt"})
      elseif 奖励参数<=45 and 让海啸席卷 then
        local 名称="元宵"
        玩家数据[id].道具:给予道具(id,名称,1)
        常规提示(id,"#Y/你获得了"..名称)
        广播消息({内容=format("#S(皇宫飞贼)#R/%s#Y成功缉拿住幕后贼王，因此获得了御林军左统领奖励的的#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,名称),频道="xt"})
      elseif 奖励参数<=55 then
        local 名称=取宝石()
        玩家数据[id].道具:给予道具(id,名称,取随机数(1,2))
        常规提示(id,"#Y/你获得了"..名称)
        广播消息({内容=format("#S(皇宫飞贼)#R/%s#Y成功缉拿住幕后贼王，因此获得了御林军左统领奖励的的#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,名称),频道="xt"})
      elseif 奖励参数<=70 and 让海啸席卷 then
        local 名称="召唤兽内丹"
        玩家数据[id].道具:给予道具(id,名称,1)
        常规提示(id,"#Y/你获得了"..名称)
        广播消息({内容=format("#S(皇宫飞贼)#R/%s#Y成功缉拿住幕后贼王，因此获得了御林军左统领奖励的的#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,名称),频道="xt"})
      elseif 奖励参数<=80 and 让海啸席卷 then
        local 名称="一级未激活符石"
        玩家数据[id].道具:给予道具(id,名称,1)
        常规提示(id,"#Y/你获得了"..名称)
        广播消息({内容=format("#S(皇宫飞贼)#R/%s#Y成功缉拿住幕后贼王，因此获得了御林军左统领奖励的的#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,名称),频道="xt"})
      elseif 奖励参数<=85 then
        local 名称="金银锦盒"
        玩家数据[id].道具:给予道具(id,名称,1)
        常规提示(id,"#Y/你获得了"..名称)
        广播消息({内容=format("#S(皇宫飞贼)#R/%s#Y成功缉拿住幕后贼王，因此获得了御林军左统领奖励的的#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,名称),频道="xt"})
      elseif 奖励参数<=90 then
        local 名称="九转金丹"
        玩家数据[id].道具:给予道具(id,名称,1,40)
        常规提示(id,"#Y/你获得了"..名称)
        广播消息({内容=format("#S(皇宫飞贼)#R/%s#Y成功缉拿住幕后贼王，因此获得了御林军左统领奖励的的#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,名称),频道="xt"})
      elseif 奖励参数<=95 and 让海啸席卷 then
        local 名称="仙玉"
        添加仙玉(取随机数(20,50),玩家数据[id].账号,id,"皇宫飞贼")
        常规提示(id,"#Y/你获得了"..名称)
        广播消息({内容=format("#S(皇宫飞贼)#R/%s#Y成功缉拿住幕后贼王，因此获得了御林军左统领奖励的的#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,名称),频道="xt"})
      else
        local 名称="星辉石"
        玩家数据[id].道具:给予道具(id,名称,1)
        常规提示(id,"#Y/你获得了"..名称)
        广播消息({内容=format("#S(皇宫飞贼)#R/%s#Y成功缉拿住幕后贼王，因此获得了御林军左统领奖励的的#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,名称),频道="xt"})
      end
    elseif self.战斗类型==100025 then
      local 经验加成=1
      local 银子加成=1
      if 任务数据[self.任务id].难度=="高级" then
        经验加成=2
        银子加成=1.25
      elseif 任务数据[self.任务id].难度=="珍贵" then
        经验加成=4
        银子加成=1.5
        end
     local 等级=玩家数据[id].角色.数据.等级
     local 经验=qz(等级*等级*40*经验加成*0.5)
     local 银子=qz(等级*等级*7*银子加成)
     玩家数据[id].角色:添加经验(经验,"镖王活动")
     玩家数据[id].角色:添加银子(银子,"镖王活动",1)
     if 玩家数据[id].角色.数据.参战信息~=nil then
        玩家数据[id].召唤兽:获得经验(玩家数据[id].角色.数据.参战宝宝.认证码,qz(经验*0.5),id,"镖王活动",self.地图等级)
     end
    elseif self.战斗类型==100026 then
      local 银子=200000
      玩家数据[id].角色:添加银子(银子,"三界悬赏令",1)
      if id==self.进入战斗玩家id then
        玩家数据[id].角色:添加银子(500000,"三界悬赏令",1)
      end
      local 奖励参数=取随机数()
      if 奖励参数<=30 then
        local 名称=取宝石()
        玩家数据[id].道具:给予道具(id,名称,取随机数(2,3))
        常规提示(id,"#Y/你获得了"..名称)
      elseif 奖励参数<=60 then
        local 名称="金银锦盒"
        玩家数据[id].道具:给予道具(id,名称,1)
        常规提示(id,"#Y/你获得了"..名称)
        广播消息({内容=format("#S(三界悬赏令)#R/%s#Y跋山涉水终于成功擒拿了#R%s#Y，因此获得了铁无双其奖励的#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,任务数据[self.任务id].名称,名称),频道="xt"})
      elseif 奖励参数<=80 then
        local 名称="修炼果"
        玩家数据[id].道具:给予道具(id,名称,2)
        常规提示(id,"#Y/你获得了"..名称)
        广播消息({内容=format("#S(三界悬赏令)#R/%s#Y跋山涉水终于成功擒拿了#R%s#Y，因此获得了铁无双其奖励的#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,任务数据[self.任务id].名称,名称),频道="xt"})
      else
        local 名称="星辉石"
        玩家数据[id].道具:给予道具(id,名称,取随机数(1,2))
        常规提示(id,"#Y/你获得了"..名称)
        广播消息({内容=format("#S(三界悬赏令)#R/%s#Y跋山涉水终于成功擒拿了#R%s#Y，因此获得了铁无双其奖励的#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,任务数据[self.任务id].名称,名称),频道="xt"})
     end
  elseif self.战斗类型==100027 then
    local 等级=取队伍平均等级(玩家数据[id].队伍,id)
    local 银子=等级*等级*取随机数(5,15)+150000
    local 经验=等级*3000+500000
    if 老唐定制 then
      银子=100000
    end
    if 让海啸席卷 then
      银子=银子*4
      经验=经验*4
    end
    玩家数据[id].角色:添加银子(银子,"知了王",1)
    玩家数据[id].角色:添加经验(经验,"知了王")
    if 让海啸席卷 and 取随机数()<=15 then
      添加仙玉(取随机数(90,110),玩家数据[id].账号,id,"知了王")
    end
    if 玩家数据[id].角色.数据.参战信息~=nil then
      玩家数据[id].召唤兽:获得经验(玩家数据[id].角色.数据.参战宝宝.认证码,qz(经验*0.5),id,"知了王",self.地图等级)
    end
    if 活跃数据[id]==nil then
      活跃数据[id]={活跃度=0,领取100活跃=false,领取200活跃=false,领取300活跃=false,领取400活跃=false,领取500活跃=false,师门次数=20,官职次数=30,鬼怪次数=25,封妖次数=3,游泳次数=1,镖王次数=1,押镖次数=50,水果次数=25,天庭叛逆次数=25,十二星宿次数=5,门派闯关次数=1,地煞星次数=5,天罡星次数=5,飞贼次数=5,知了先锋=20,小知了王=20,知了王=10,世界BOSS次数=2,抓鬼次数=50,初出江湖次数=20,帮派青龙次数=100,帮派玄武次数=100,妖王次数=3}
    end
    if 活跃数据[id].知了王==nil then
      活跃数据[id].知了王=10
    end
    if 活跃数据[id].知了王>0 then
      活跃数据[id].活跃度=活跃数据[id].活跃度+5
      玩家数据[id].角色.数据.累积活跃.当前积分=玩家数据[id].角色.数据.累积活跃.当前积分+活跃数据[id].活跃度
      玩家数据[id].角色.数据.累积活跃.总积分=玩家数据[id].角色.数据.累积活跃.总积分+活跃数据[id].活跃度
      活跃数据[id].知了王=活跃数据[id].知了王-1
    end
    local 奖励参数=取随机数()
    if 老唐定制 then
      if 奖励参数<=1 then
        礼包奖励类:随机装备(id,160,"无级别限制")
        local 名称="160级无级别装备"
        常规提示(id,"#Y/你获得了"..名称)
        广播消息({内容=format("#S(知了王)#R/%s#Y对着知了王一顿乱打脚踢，打得知了王双手奉上了#G/%s#Y以求活命。".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,名称),频道="xt"})
      elseif 奖励参数<=21 then
        local 名称="高级召唤兽内丹"
        玩家数据[id].道具:给予道具(id,名称,1)
        常规提示(id,"#Y/你获得了"..名称)
        广播消息({内容=format("#S(知了王)#R/%s#Y对着知了王一顿乱打脚踢，打得知了王双手奉上了#G/%s#Y以求活命。".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,名称),频道="xt"})
      elseif 奖励参数<=31 then
        local 名称="上古锻造图策"
        玩家数据[id].道具:给予道具(id,名称,{155})
        常规提示(id,"#Y/你获得了"..名称)
        广播消息({内容=format("#S(知了王)#R/%s#Y对着知了王一顿乱打脚踢，打得知了王双手奉上了#G/%s#Y以求活命。".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,名称),频道="xt"})
      elseif 奖励参数<=41 then
        local 名称="炼妖石"
        玩家数据[id].道具:给予道具(id,名称,{155})
        常规提示(id,"#Y/你获得了"..名称)
        广播消息({内容=format("#S(知了王)#R/%s#Y对着知了王一顿乱打脚踢，打得知了王双手奉上了#G/%s#Y以求活命。".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,名称),频道="xt"})
      elseif 奖励参数<=59 then
        local 名称="仙玉锦囊"
        玩家数据[id].道具:给予道具(id,名称,1)
        常规提示(id,"#Y/你获得了"..名称)
        广播消息({内容=format("#S(知了王)#R/%s#Y对着知了王一顿乱打脚踢，打得知了王双手奉上了#G/%s#Y以求活命。".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,名称),频道="xt"})
      elseif 奖励参数<=79 then
        local 名称="高级魔兽要诀"
        玩家数据[id].道具:给予道具(id,名称,1)
        常规提示(id,"#Y/你获得了"..名称)
        广播消息({内容=format("#S(知了王)#R/%s#Y对着知了王一顿乱打脚踢，打得知了王双手奉上了#G/%s#Y以求活命。".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,名称),频道="xt"})
      elseif 奖励参数<=80 then
        local 名称="高级魔兽要诀"
        local 技能=取特殊要诀1()
        玩家数据[id].道具:给予道具(id,名称,nil,技能)
        常规提示(id,"#Y/你获得了"..名称)
        广播消息({内容=format("#S(知了王)#R/%s#Y对着知了王一顿乱打脚踢，打得知了王双手奉上了#G/%s#Y以求活命。".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,名称),频道="xt"})
      else
        礼包奖励类:随机装备(id,150,"无级别限制")
        local 名称="150级无级别装备"
        常规提示(id,"#Y/你获得了"..名称)
        广播消息({内容=format("#S(知了王)#R/%s#Y对着知了王一顿乱打脚踢，打得知了王双手奉上了#G/%s#Y以求活命。".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,名称),频道="xt"})
      end
    elseif 风雨无言定制 then
      if 奖励参数<=40 then
      elseif 奖励参数<=45 then
        local 名称=取宝石()
        玩家数据[id].道具:给予道具(id,名称,取随机数(3,5))
        常规提示(id,"#Y/你获得了"..名称)
        广播消息({内容=format("#S(知了王)#R/%s#Y对着知了王一顿乱打脚踢，打得知了王双手奉上了#G/%s#Y以求活命。".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,名称),频道="xt"})
      elseif 奖励参数<=50 then
        local 名称="怪物卡片"
        玩家数据[id].道具:给予道具(id,名称,8)
        常规提示(id,"#Y/你获得了"..名称)
        广播消息({内容=format("#S(知了王)#R/%s#Y对着知了王一顿乱打脚踢，打得知了王双手奉上了#G/%s#Y以求活命。".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,名称),频道="xt"})
      elseif 奖励参数<=55 then
        local 名称="上古锻造图策"
        玩家数据[id].道具:给予道具(id,名称,{135,145,155})
        常规提示(id,"#Y/你获得了"..名称)
        广播消息({内容=format("#S(知了王)#R/%s#Y对着知了王一顿乱打脚踢，打得知了王双手奉上了#G/%s#Y以求活命。".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,名称),频道="xt"})
      elseif 奖励参数<=60 then
        local 名称="炼妖石"
        玩家数据[id].道具:给予道具(id,名称,{135,145,155})
        常规提示(id,"#Y/你获得了"..名称)
        广播消息({内容=format("#S(知了王)#R/%s#Y对着知了王一顿乱打脚踢，打得知了王双手奉上了#G/%s#Y以求活命。".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,名称),频道="xt"})
      elseif 奖励参数<=65 then
        local 名称="高级魔兽要诀"
        玩家数据[id].道具:给予道具(id,名称,1)
        常规提示(id,"#Y/你获得了"..名称)
        广播消息({内容=format("#S(知了王)#R/%s#Y对着知了王一顿乱打脚踢，打得知了王双手奉上了#G/%s#Y以求活命。".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,名称),频道="xt"})
      elseif 奖励参数<=70 then
        local 名称="三级未激活符石"
        玩家数据[id].道具:给予道具(id,名称,1)
        常规提示(id,"#Y/你获得了"..名称)
        广播消息({内容=format("#S(知了王)#R/%s#Y对着知了王一顿乱打脚踢，打得知了王双手奉上了#G/%s#Y以求活命。".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,名称),频道="xt"})
      elseif 奖励参数<=75 then
        local 名称="易经丹"
        玩家数据[id].道具:给予道具(id,名称,1)
        常规提示(id,"#Y/你获得了"..名称)
        广播消息({内容=format("#S(知了王)#R/%s#Y对着知了王一顿乱打脚踢，打得知了王双手奉上了#G/%s#Y以求活命。".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,名称),频道="xt"})
      elseif 奖励参数<=80 then
        local 名称="高级召唤兽内丹"
        玩家数据[id].道具:给予道具(id,名称,1)
        常规提示(id,"#Y/你获得了"..名称)
        广播消息({内容=format("#S(知了王)#R/%s#Y对着知了王一顿乱打脚踢，打得知了王双手奉上了#G/%s#Y以求活命。".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,名称),频道="xt"})
      elseif 奖励参数<=85 then
        local 名称="灵饰指南书"
        玩家数据[id].道具:给予道具(id,"灵饰指南书",{12,14})
        常规提示(id,"#Y/你获得了"..名称)
        广播消息({内容=format("#S(知了王)#R/%s#Y对着知了王一顿乱打脚踢，打得知了王双手奉上了#G/%s#Y以求活命。".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,名称),频道="xt"})
      elseif 奖励参数<=90 then
        local 名称="元灵晶石"
        玩家数据[id].道具:给予道具(id,"元灵晶石",{12,14})
        常规提示(id,"#Y/你获得了"..名称)
        广播消息({内容=format("#S(知了王)#R/%s#Y对着知了王一顿乱打脚踢，打得知了王双手奉上了#G/%s#Y以求活命。".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,名称),频道="xt"})
      elseif 奖励参数<=95 then
        local 名称="星辉石"
        玩家数据[id].道具:给予道具(id,名称,5)
        常规提示(id,"#Y/你获得了"..名称)
        广播消息({内容=format("#S(知了王)#R/%s#Y对着知了王一顿乱打脚踢，打得知了王双手奉上了#G/%s#Y以求活命。".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,名称),频道="xt"})
      end
    elseif 老八定制 then
      if 奖励参数<=10 then
        local 名称=取宝石()
        玩家数据[id].道具:给予道具(id,名称,取随机数(3,5))
        常规提示(id,"#Y/你获得了"..名称)
        广播消息({内容=format("#S(知了王)#R/%s#Y对着知了王一顿乱打脚踢，打得知了王双手奉上了#G/%s#Y以求活命。".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,名称),频道="xt"})
      elseif 奖励参数<=20 then
        local 名称="怪物卡片"
        玩家数据[id].道具:给予道具(id,名称,8)
        常规提示(id,"#Y/你获得了"..名称)
        广播消息({内容=format("#S(知了王)#R/%s#Y对着知了王一顿乱打脚踢，打得知了王双手奉上了#G/%s#Y以求活命。".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,名称),频道="xt"})
      elseif 奖励参数<=30 then
        local 名称="上古锻造图策"
        玩家数据[id].道具:给予道具(id,名称,{135,145,155})
        常规提示(id,"#Y/你获得了"..名称)
        广播消息({内容=format("#S(知了王)#R/%s#Y对着知了王一顿乱打脚踢，打得知了王双手奉上了#G/%s#Y以求活命。".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,名称),频道="xt"})
      elseif 奖励参数<=40 then
        local 名称="炼妖石"
        玩家数据[id].道具:给予道具(id,名称,{135,145,155})
        常规提示(id,"#Y/你获得了"..名称)
        广播消息({内容=format("#S(知了王)#R/%s#Y对着知了王一顿乱打脚踢，打得知了王双手奉上了#G/%s#Y以求活命。".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,名称),频道="xt"})
      elseif 奖励参数<=45 then
        local 名称="高级魔兽要诀"
        玩家数据[id].道具:给予道具(id,名称,1)
        常规提示(id,"#Y/你获得了"..名称)
        广播消息({内容=format("#S(知了王)#R/%s#Y对着知了王一顿乱打脚踢，打得知了王双手奉上了#G/%s#Y以求活命。".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,名称),频道="xt"})
      elseif 奖励参数<=50 then
        local 名称="三级未激活符石"
        玩家数据[id].道具:给予道具(id,名称,1)
        常规提示(id,"#Y/你获得了"..名称)
        广播消息({内容=format("#S(知了王)#R/%s#Y对着知了王一顿乱打脚踢，打得知了王双手奉上了#G/%s#Y以求活命。".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,名称),频道="xt"})
      elseif 奖励参数<=55 then
        local 名称="易经丹"
        玩家数据[id].道具:给予道具(id,名称,1)
        常规提示(id,"#Y/你获得了"..名称)
        广播消息({内容=format("#S(知了王)#R/%s#Y对着知了王一顿乱打脚踢，打得知了王双手奉上了#G/%s#Y以求活命。".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,名称),频道="xt"})
      elseif 奖励参数<=60 then
        local 名称="高级召唤兽内丹"
        玩家数据[id].道具:给予道具(id,名称,1)
        常规提示(id,"#Y/你获得了"..名称)
        广播消息({内容=format("#S(知了王)#R/%s#Y对着知了王一顿乱打脚踢，打得知了王双手奉上了#G/%s#Y以求活命。".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,名称),频道="xt"})
      elseif 奖励参数<=65 then
        local 名称="灵饰指南书"
        玩家数据[id].道具:给予道具(id,"灵饰指南书",{12,})
        常规提示(id,"#Y/你获得了"..名称)
        广播消息({内容=format("#S(知了王)#R/%s#Y对着知了王一顿乱打脚踢，打得知了王双手奉上了#G/%s#Y以求活命。".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,名称),频道="xt"})
      elseif 奖励参数<=70 then
        local 名称="元灵晶石"
        玩家数据[id].道具:给予道具(id,"元灵晶石",{12})
        常规提示(id,"#Y/你获得了"..名称)
        广播消息({内容=format("#S(知了王)#R/%s#Y对着知了王一顿乱打脚踢，打得知了王双手奉上了#G/%s#Y以求活命。".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,名称),频道="xt"})
      elseif 奖励参数<=75 then
        local 名称="修炼果"
        玩家数据[id].道具:给予道具(id,名称,1)
        常规提示(id,"#Y/你获得了"..名称)
        广播消息({内容=format("#S(知了王)#R/%s#Y对着知了王一顿乱打脚踢，打得知了王双手奉上了#G/%s#Y以求活命。".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,名称),频道="xt"})
      elseif 奖励参数<=80 then
        local 奖励数据=玩家数据[id].道具:给予书铁(id,{13,14})
        local 名称=奖励数据[1]
        常规提示(id,"#Y/你获得了"..名称)
        广播消息({内容=format("#S(知了王)#R/%s#Y对着知了王一顿乱打脚踢，打得知了王双手奉上了#G/%s#Y以求活命。".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,名称),频道="xt"})
      else
        local 名称="星辉石"
        玩家数据[id].道具:给予道具(id,名称,5)
        常规提示(id,"#Y/你获得了"..名称)
        广播消息({内容=format("#S(知了王)#R/%s#Y对着知了王一顿乱打脚踢，打得知了王双手奉上了#G/%s#Y以求活命。".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,名称),频道="xt"})
      end
    else
      if 奖励参数<=10 then
        local 名称=取宝石()
        if 让海啸席卷 then
          玩家数据[id].道具:给予道具(id,名称,取随机数(6,10))
        else
          玩家数据[id].道具:给予道具(id,名称,取随机数(3,5))
        end
        常规提示(id,"#Y/你获得了"..名称)
        广播消息({内容=format("#S(知了王)#R/%s#Y对着知了王一顿乱打脚踢，打得知了王双手奉上了#G/%s#Y以求活命。".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,名称),频道="xt"})
      elseif 奖励参数<=20 then
        local 名称="怪物卡片"
        玩家数据[id].道具:给予道具(id,名称,8)
        常规提示(id,"#Y/你获得了"..名称)
        广播消息({内容=format("#S(知了王)#R/%s#Y对着知了王一顿乱打脚踢，打得知了王双手奉上了#G/%s#Y以求活命。".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,名称),频道="xt"})
      elseif 奖励参数<=30 then
        local 名称="上古锻造图策"
        玩家数据[id].道具:给予道具(id,名称,{135,145,155})
        常规提示(id,"#Y/你获得了"..名称)
        广播消息({内容=format("#S(知了王)#R/%s#Y对着知了王一顿乱打脚踢，打得知了王双手奉上了#G/%s#Y以求活命。".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,名称),频道="xt"})
      elseif 奖励参数<=40 then
        local 名称="炼妖石"
        玩家数据[id].道具:给予道具(id,名称,{135,145,155})
        常规提示(id,"#Y/你获得了"..名称)
        广播消息({内容=format("#S(知了王)#R/%s#Y对着知了王一顿乱打脚踢，打得知了王双手奉上了#G/%s#Y以求活命。".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,名称),频道="xt"})
      elseif 奖励参数<=45 then
        local 名称="高级魔兽要诀"
        玩家数据[id].道具:给予道具(id,名称,1)
        常规提示(id,"#Y/你获得了"..名称)
        广播消息({内容=format("#S(知了王)#R/%s#Y对着知了王一顿乱打脚踢，打得知了王双手奉上了#G/%s#Y以求活命。".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,名称),频道="xt"})
      elseif 奖励参数<=60 then
        local 名称="三级未激活符石"
        玩家数据[id].道具:给予道具(id,名称,1)
        常规提示(id,"#Y/你获得了"..名称)
        广播消息({内容=format("#S(知了王)#R/%s#Y对着知了王一顿乱打脚踢，打得知了王双手奉上了#G/%s#Y以求活命。".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,名称),频道="xt"})
      elseif 奖励参数<=70 then
        local 名称="易经丹"
        玩家数据[id].道具:给予道具(id,名称,1)
        常规提示(id,"#Y/你获得了"..名称)
        广播消息({内容=format("#S(知了王)#R/%s#Y对着知了王一顿乱打脚踢，打得知了王双手奉上了#G/%s#Y以求活命。".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,名称),频道="xt"})
      elseif 奖励参数<=80 then
        local 名称="高级召唤兽内丹"
        玩家数据[id].道具:给予道具(id,名称,1)
        常规提示(id,"#Y/你获得了"..名称)
        广播消息({内容=format("#S(知了王)#R/%s#Y对着知了王一顿乱打脚踢，打得知了王双手奉上了#G/%s#Y以求活命。".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,名称),频道="xt"})
      elseif 奖励参数<=85 then
        local 名称="灵饰指南书"
        玩家数据[id].道具:给予道具(id,"灵饰指南书",{12,14})
        常规提示(id,"#Y/你获得了"..名称)
        广播消息({内容=format("#S(知了王)#R/%s#Y对着知了王一顿乱打脚踢，打得知了王双手奉上了#G/%s#Y以求活命。".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,名称),频道="xt"})
      elseif 奖励参数<=90 then
        local 名称="元灵晶石"
        玩家数据[id].道具:给予道具(id,"元灵晶石",{12,14})
        常规提示(id,"#Y/你获得了"..名称)
        广播消息({内容=format("#S(知了王)#R/%s#Y对着知了王一顿乱打脚踢，打得知了王双手奉上了#G/%s#Y以求活命。".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,名称),频道="xt"})
      elseif 奖励参数<=96 and 释怀定制 then
        local 名称="10点点卡"
        添加点卡(10,玩家数据[id].账号,id,"知了王")
        常规提示(id,"#Y/你获得了"..名称)
        广播消息({内容=format("#S(知了王)#R/%s#Y对着知了王一顿乱打脚踢，打得知了王双手奉上了#G/%s#Y以求活命。".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,名称),频道="xt"})
      elseif 奖励参数<=91 and 让海啸席卷 then
        if 取随机数() <= 50 then
          local 名称="高级魔兽要诀"
          local 技能=取特殊要诀1()
          玩家数据[id].道具:给予道具(id,名称,nil,技能)
          常规提示(id,"#Y/你获得了"..名称)
          广播消息({内容=format("#S(知了王)#R/%s#Y对着知了王一顿乱打脚踢，打得知了王双手奉上了#G/%s#Y以求活命。".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,名称),频道="xt"})
        end
      elseif 奖励参数<=92 and 让海啸席卷 then
        local 名称="神兜兜"
        玩家数据[id].道具:给予道具(id,名称,1)
        常规提示(id,"#Y/你获得了"..名称)
        广播消息({内容=format("#S(知了王)#R/%s#Y对着知了王一顿乱打脚踢，打得知了王双手奉上了#G/%s#Y以求活命。".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,名称),频道="xt"})
      elseif 奖励参数<=99 and 释怀定制 then
        local 名称="30点点卡"
        添加点卡(30,玩家数据[id].账号,id,"知了王")
        常规提示(id,"#Y/你获得了"..名称)
        广播消息({内容=format("#S(知了王)#R/%s#Y对着知了王一顿乱打脚踢，打得知了王双手奉上了#G/%s#Y以求活命。".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,名称),频道="xt"})
      elseif 奖励参数<= 98 and 让海啸席卷 then
        local 名称="魔兽残卷"
        玩家数据[id].道具:给予道具(id,名称,1)
        常规提示(id,"#Y/你获得了"..名称)
        广播消息({内容=format("#S(知了王)#R/%s#Y对着知了王一顿乱打脚踢，打得知了王双手奉上了#G/%s#Y以求活命。".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,名称),频道="xt"})
      else
        local 名称="星辉石"
        玩家数据[id].道具:给予道具(id,名称,5)
        常规提示(id,"#Y/你获得了"..名称)
        广播消息({内容=format("#S(知了王)#R/%s#Y对着知了王一顿乱打脚踢，打得知了王双手奉上了#G/%s#Y以求活命。".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,名称),频道="xt"})
      end
    end
  elseif self.战斗类型==100028 then
      local 等级=取队伍平均等级(玩家数据[id].队伍,id)
      local 经验=等级*400+30000
      local 银子=等级*等级*2
      玩家数据[id].角色:添加经验(经验,"乌鸡国芭蕉木妖")
      玩家数据[id].角色:添加银子(银子,"乌鸡国芭蕉木妖",1)
      if 玩家数据[id].角色.数据.参战信息~=nil then
         玩家数据[id].召唤兽:获得经验(玩家数据[id].角色.数据.参战宝宝.认证码,qz(经验*0.5),id,"乌鸡国副本",self.地图等级)
      end
      if 让海啸席卷 and  取随机数() <= 15 then
        添加仙玉(取随机数(1,50),玩家数据[id].账号,id,"乌鸡国")
      end
  elseif self.战斗类型==100029 then
      local 等级=取队伍平均等级(玩家数据[id].队伍,id)
      local 经验=(等级*500+3000)*3
      local 银子=(等级*等级*2)*5
      玩家数据[id].角色:添加经验(经验,"乌鸡国三妖")
      玩家数据[id].角色:添加银子(银子,"乌鸡国三妖",1)
      if 玩家数据[id].角色.数据.参战信息~=nil then
         玩家数据[id].召唤兽:获得经验(玩家数据[id].角色.数据.参战宝宝.认证码,qz(经验*0.5),id,"乌鸡国副本",self.地图等级)
      end
      if 让海啸席卷 and 取随机数() <= 15 then
        添加仙玉(取随机数(1,50),玩家数据[id].账号,id,"乌鸡国")
      end
  elseif self.战斗类型==100030 then
      local 等级=取队伍平均等级(玩家数据[id].队伍,id)
      local 经验=等级*500+30000
      local 银子=等级*等级*2
      玩家数据[id].角色:添加经验(经验,"乌鸡国鬼祟小妖")
      玩家数据[id].角色:添加银子(银子,"乌鸡国鬼祟小妖",1)
      if 玩家数据[id].角色.数据.参战信息~=nil then
         玩家数据[id].召唤兽:获得经验(玩家数据[id].角色.数据.参战宝宝.认证码,qz(经验*0.5),id,"乌鸡国副本",self.地图等级)
      end
      if 让海啸席卷 and  取随机数() <= 15 then
        添加仙玉(取随机数(1,50),玩家数据[id].账号,id,"乌鸡国")
      end
   elseif self.战斗类型==100031 then
      local 等级=取队伍平均等级(玩家数据[id].队伍,id)
      local 经验=(等级*500+3000)*6
      local 银子=(等级*等级*2)*20
      玩家数据[id].角色:添加经验(经验,"乌鸡国国王")
      玩家数据[id].角色:添加银子(银子,"乌鸡国国王",1)
      if 玩家数据[id].角色.数据.参战信息~=nil then
         玩家数据[id].召唤兽:获得经验(玩家数据[id].角色.数据.参战宝宝.认证码,qz(经验*0.5),id,"乌鸡国副本",self.地图等级)
      end
      if 让海啸席卷 then
        添加仙玉(300,玩家数据[id].账号,id,"乌鸡国")
      end
    elseif self.战斗类型==100024 then
      local 等级=任务数据[self.任务id].等级
      local 平均等级 = 取队伍平均等级(玩家数据[id].队伍,id)
      local 经验=平均等级*平均等级*100 + 500000
      if 等级==100 then
        经验=平均等级*平均等级*100 + 2000000
      elseif 等级==150 then
        经验=平均等级*平均等级*100 + 4000000
      end
      玩家数据[id].角色:添加经验(经验,任务数据[self.任务id].名称)
      if 活跃数据[id]==nil then
        活跃数据[id]={活跃度=0,领取100活跃=false,领取200活跃=false,领取300活跃=false,领取400活跃=false,领取500活跃=false,师门次数=20,官职次数=30,鬼怪次数=25,封妖次数=3,游泳次数=1,镖王次数=1,押镖次数=50,水果次数=25,天庭叛逆次数=25,十二星宿次数=5,门派闯关次数=1,地煞星次数=5,天罡星次数=5,飞贼次数=5,知了先锋=20,小知了王=20,知了王=10,世界BOSS次数=2,抓鬼次数=50,初出江湖次数=20,帮派青龙次数=100,帮派玄武次数=100,妖王次数=3}
      end
      if 活跃数据[id].世界BOSS次数>0 then
        活跃数据[id].活跃度=活跃数据[id].活跃度+50
        玩家数据[id].角色.数据.累积活跃.当前积分=玩家数据[id].角色.数据.累积活跃.当前积分+活跃数据[id].活跃度
        玩家数据[id].角色.数据.累积活跃.总积分=玩家数据[id].角色.数据.累积活跃.总积分+活跃数据[id].活跃度
        活跃数据[id].世界BOSS次数=活跃数据[id].世界BOSS次数-1
      end
      if 玩家数据[id].角色.数据.参战信息~=nil then
         玩家数据[id].召唤兽:获得经验(玩家数据[id].角色.数据.参战宝宝.认证码,qz(经验*0.5),id,"世界BOSS",self.地图等级)
      end
      local 奖励参数=取随机数()
      if 老唐定制 then
        if 等级==60 then
          if 奖励参数<=20 then
            礼包奖励类:随机装备(id,160,"无级别限制")
            local 名称="160级无级别装备"
            常规提示(id,"#Y/你获得了"..名称)
            广播消息({内容=format("#S(世界BOSS)#R/%s#Y经过一番激烈的战斗，最终战胜了#R%s#Y，因此获得了其奖励的#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,任务数据[self.任务id].名称,名称),频道="xt"})
          elseif 奖励参数<=40 then
            local 名称="高级魔兽要诀"
            玩家数据[id].道具:给予道具(id,名称)
            常规提示(id,"#Y/你获得了"..名称)
            广播消息({内容=format("#S(世界BOSS)#R/%s#Y经过一番激烈的战斗，最终战胜了#R%s#Y，因此获得了其奖励的#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,任务数据[self.任务id].名称,名称),频道="xt"})
          elseif 奖励参数<=60 then
            local 名称="高级召唤兽内丹"
            玩家数据[id].道具:给予道具(id,名称,1)
            常规提示(id,"#Y/你获得了"..名称)
            广播消息({内容=format("#S(世界BOSS)#R/%s#Y经过一番激烈的战斗，最终战胜了#R%s#Y，因此获得了其奖励的#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,任务数据[self.任务id].名称,名称),频道="xt"})
          elseif 奖励参数<=65 then
            local 名称="高级魔兽要诀"
            local 技能=取特殊要诀()
            玩家数据[id].道具:给予道具(id,名称,nil,技能)
            常规提示(id,"#Y/你获得了"..名称)
            广播消息({内容=format("#S(世界BOSS)#R/%s#Y经过一番激烈的战斗，最终战胜了#R%s#Y，因此获得了其奖励的#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,任务数据[self.任务id].名称,名称),频道="xt"})
          elseif 奖励参数<=80 then
            local 名称="钟灵石"
            local 特性=取钟灵石()
            玩家数据[id].道具:给予道具(id,名称,1,特性)
            常规提示(id,"#Y/你获得了"..名称)
            广播消息({内容=format("#S(世界BOSS)#R/%s#Y经过一番激烈的战斗，最终战胜了#R%s#Y，因此获得了其奖励的#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,任务数据[self.任务id].名称,名称),频道="xt"})
          else
            礼包奖励类:随机灵饰(id,80,"无级别限制")
            local 名称="80级无级别灵饰"
            常规提示(id,"#Y你得到了#R"..名称)
            广播消息({内容=format("#S(世界BOSS)#R/%s#Y经过一番激烈的战斗，最终战胜了#R%s#Y，因此获得了其奖励的#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,任务数据[self.任务id].名称,名称),频道="xt"})
          end
        elseif 等级==100 then
          if 奖励参数<=15 then
            local 名称="星辉石"
            玩家数据[id].道具:给予道具(id,名称,7)
            常规提示(id,"#Y/你获得了"..名称)
            广播消息({内容=format("#S(世界BOSS)#R/%s#Y经过一番激烈的战斗，最终战胜了#R%s#Y，因此获得了其奖励的#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,任务数据[self.任务id].名称,名称),频道="xt"})
          elseif 奖励参数<=45 then
            local 名称="高级魔兽要诀"
            玩家数据[id].道具:给予道具(id,名称)
            常规提示(id,"#Y/你获得了"..名称)
            广播消息({内容=format("#S(世界BOSS)#R/%s#Y经过一番激烈的战斗，最终战胜了#R%s#Y，因此获得了其奖励的#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,任务数据[self.任务id].名称,名称),频道="xt"})
          elseif 奖励参数<=60 then
            local 名称="九转金丹"
            玩家数据[id].道具:给予道具(id,名称,1,500)
            常规提示(id,"#Y/你获得了"..名称)
            广播消息({内容=format("#S(世界BOSS)#R/%s#Y经过一番激烈的战斗，最终战胜了#R%s#Y，因此获得了其奖励的#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,任务数据[self.任务id].名称,名称),频道="xt"})
          elseif 奖励参数<=75 then
            local 名称="修炼果"
            玩家数据[id].道具:给予道具(id,名称,10)
            常规提示(id,"#Y/你获得了"..名称)
            广播消息({内容=format("#S(世界BOSS)#R/%s#Y经过一番激烈的战斗，最终战胜了#R%s#Y，因此获得了其奖励的#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,任务数据[self.任务id].名称,名称),频道="xt"})
          elseif 奖励参数<=80 then
            local 名称="高级魔兽要诀"
            local 技能=取特殊要诀()
            玩家数据[id].道具:给予道具(id,名称,nil,技能)
            广播消息({内容=format("#S(世界BOSS)#R/%s#Y经过一番激烈的战斗，最终战胜了#R%s#Y，因此获得了其奖励的#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,任务数据[self.任务id].名称,技能),频道="xt"})
          elseif 奖励参数<=90 then
            玩家数据[id].道具:给予随机一级法宝(id)
            local 名称="一级法宝"
            常规提示(id,"#Y/你获得了"..名称)
            广播消息({内容=format("#S(世界BOSS)#R/%s#Y经过一番激烈的战斗，最终战胜了#R%s#Y，因此获得了其奖励的#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,任务数据[self.任务id].名称,名称),频道="xt"})
          else
            local 随机灵饰={60,80,100}
            local 随机等级=随机灵饰[取随机数(1,#随机灵饰)]
            礼包奖励类:随机灵饰(id,随机等级,"无级别限制")
            local 名称=随机等级.."级无级别灵饰"
            常规提示(id,"#Y你得到了#R"..名称)
            广播消息({内容=format("#S(世界BOSS)#R/%s#Y经过一番激烈的战斗，最终战胜了#R%s#Y，因此获得了其奖励的#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,任务数据[self.任务id].名称,名称),频道="xt"})
          end
        elseif 等级==150 then
          if 奖励参数<=15 then
            local 名称="星辉石"
            玩家数据[id].道具:给予道具(id,名称,7)
            常规提示(id,"#Y/你获得了"..名称)
            广播消息({内容=format("#S(世界BOSS)#R/%s#Y经过一番激烈的战斗，最终战胜了#R%s#Y，因此获得了其奖励的#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,任务数据[self.任务id].名称,名称),频道="xt"})
          elseif 奖励参数<=45 then
            local 名称="高级魔兽要诀"
            玩家数据[id].道具:给予道具(id,名称)
            常规提示(id,"#Y/你获得了"..名称)
            广播消息({内容=format("#S(世界BOSS)#R/%s#Y经过一番激烈的战斗，最终战胜了#R%s#Y，因此获得了其奖励的#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,任务数据[self.任务id].名称,名称),频道="xt"})
          elseif 奖励参数<=60 then
            local 名称="九转金丹"
            玩家数据[id].道具:给予道具(id,名称,1,500)
            常规提示(id,"#Y/你获得了"..名称)
            广播消息({内容=format("#S(世界BOSS)#R/%s#Y经过一番激烈的战斗，最终战胜了#R%s#Y，因此获得了其奖励的#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,任务数据[self.任务id].名称,名称),频道="xt"})
          elseif 奖励参数<=75 then
            local 名称="修炼果"
            玩家数据[id].道具:给予道具(id,名称,15)
            常规提示(id,"#Y/你获得了"..名称)
            广播消息({内容=format("#S(世界BOSS)#R/%s#Y经过一番激烈的战斗，最终战胜了#R%s#Y，因此获得了其奖励的#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,任务数据[self.任务id].名称,名称),频道="xt"})
          elseif 奖励参数<=80 then
            local 名称="高级魔兽要诀"
            local 技能=取特殊要诀()
            玩家数据[id].道具:给予道具(id,名称,nil,技能)
            广播消息({内容=format("#S(世界BOSS)#R/%s#Y经过一番激烈的战斗，最终战胜了#R%s#Y，因此获得了其奖励的#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,任务数据[self.任务id].名称,技能),频道="xt"})
          elseif 奖励参数<=90 then
            玩家数据[id].道具:给予随机一级法宝(id)
            local 名称="一级法宝"
            常规提示(id,"#Y/你获得了"..名称)
            广播消息({内容=format("#S(世界BOSS)#R/%s#Y经过一番激烈的战斗，最终战胜了#R%s#Y，因此获得了其奖励的#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,任务数据[self.任务id].名称,名称),频道="xt"})
          else
            local 随机灵饰={60,80,100,120}
            local 随机等级=随机灵饰[取随机数(1,#随机灵饰)]
            礼包奖励类:随机灵饰(id,随机等级,"无级别限制")
            local 名称=随机等级.."级无级别灵饰"
            常规提示(id,"#Y你得到了#R"..名称)
            广播消息({内容=format("#S(世界BOSS)#R/%s#Y经过一番激烈的战斗，最终战胜了#R%s#Y，因此获得了其奖励的#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,任务数据[self.任务id].名称,名称),频道="xt"})
          end
        end
      else
        if 等级==60 then
          if 奖励参数<=10 then
            local 名称="高级魔兽要诀"
            玩家数据[id].道具:给予道具(id,名称)
            常规提示(id,"#Y/你获得了"..名称)
            广播消息({内容=format("#S(世界BOSS)#R/%s#Y经过一番激烈的战斗，最终战胜了#R%s#Y，因此获得了其奖励的#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,任务数据[self.任务id].名称,名称),频道="xt"})
          elseif 奖励参数<=20 then
            local 名称="怪物卡片"
            玩家数据[id].道具:给予道具(id,名称,5)
            常规提示(id,"#Y/你获得了"..名称)
            广播消息({内容=format("#S(世界BOSS)#R/%s#Y经过一番激烈的战斗，最终战胜了#R%s#Y，因此获得了其奖励的#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,任务数据[self.任务id].名称,名称),频道="xt"})
          elseif 奖励参数<=30 then
            local 名称="九转金丹"
            玩家数据[id].道具:给予道具(id,名称,1,100)
            常规提示(id,"#Y/你获得了"..名称)
            广播消息({内容=format("#S(世界BOSS)#R/%s#Y经过一番激烈的战斗，最终战胜了#R%s#Y，因此获得了其奖励的#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,任务数据[self.任务id].名称,名称),频道="xt"})
          elseif 奖励参数<=40 then
            local 名称="召唤兽内丹"
            玩家数据[id].道具:给予道具(id,名称,1)
            常规提示(id,"#Y/你获得了"..名称)
            广播消息({内容=format("#S(世界BOSS)#R/%s#Y经过一番激烈的战斗，最终战胜了#R%s#Y，因此获得了其奖励的#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,任务数据[self.任务id].名称,名称),频道="xt"})
          elseif 奖励参数<=50 then
            local 名称="修炼果"
            玩家数据[id].道具:给予道具(id,名称,1)
            常规提示(id,"#Y/你获得了"..名称)
            广播消息({内容=format("#S(世界BOSS)#R/%s#Y经过一番激烈的战斗，最终战胜了#R%s#Y，因此获得了其奖励的#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,任务数据[self.任务id].名称,名称),频道="xt"})
          elseif 奖励参数<=60 then
            local 奖励数据=玩家数据[id].道具:给予书铁(id,{6,8})
            常规提示(id,"#Y你得到了#R"..奖励数据[1])
            广播消息({内容=format("#S(世界BOSS)#R/%s#Y经过一番激烈的战斗，最终战胜了#R%s#Y，因此获得了其奖励的#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,任务数据[self.任务id].名称,奖励数据[1]),频道="xt"})
          elseif 奖励参数<=70 then
            local 名称="星辉石"
            玩家数据[id].道具:给予道具(id,名称,取随机数(1,2))
            常规提示(id,"#Y/你获得了"..名称)
            广播消息({内容=format("#S(世界BOSS)#R/%s#Y经过一番激烈的战斗，最终战胜了#R%s#Y，因此获得了其奖励的#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,任务数据[self.任务id].名称,名称),频道="xt"})
          elseif 奖励参数<=80 then
            local 名称="一级未激活符石"
            玩家数据[id].道具:给予道具(id,名称,1)
            常规提示(id,"#Y/你获得了"..名称)
            广播消息({内容=format("#S(世界BOSS)#R/%s#Y经过一番激烈的战斗，最终战胜了#R%s#Y，因此获得了其奖励的#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,任务数据[self.任务id].名称,名称),频道="xt"})
          elseif 奖励参数<=83 then
            local 名称="高级魔兽要诀"
            local 技能=取特殊要诀()
            玩家数据[id].道具:给予道具(id,名称,nil,技能)
            广播消息({内容=format("#S(世界BOSS)#R/%s#Y经过一番激烈的战斗，最终战胜了#R%s#Y，因此获得了其奖励的#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,任务数据[self.任务id].名称,技能),频道="xt"})
          elseif 奖励参数<=90 and 释怀定制 then
            local 名称="20点点卡"
            添加点卡(20,玩家数据[id].账号,id,"世界BOSS")
            常规提示(id,"#Y/你获得了"..名称)
            广播消息({内容=format("#S(世界BOSS)#R/%s#Y经过一番激烈的战斗，最终战胜了#R%s#Y，因此获得了其奖励的#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,任务数据[self.任务id].名称,名称),频道="xt"})
          elseif 奖励参数<=95 and 释怀定制 then
            local 名称="40点点卡"
            添加点卡(40,玩家数据[id].账号,id,"世界BOSS")
            常规提示(id,"#Y/你获得了"..名称)
            广播消息({内容=format("#S(世界BOSS)#R/%s#Y经过一番激烈的战斗，最终战胜了#R%s#Y，因此获得了其奖励的#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,任务数据[self.任务id].名称,名称),频道="xt"})
          elseif 奖励参数<=95 and 神兽定制 then
            local 名称="仙玉"
            添加仙玉(取随机数(10,100),玩家数据[id].账号,id,"世界BOSS")
            常规提示(id,"#Y/你获得了"..名称)
            广播消息({内容=format("#S(世界BOSS)#R/%s#Y经过一番激烈的战斗，最终战胜了#R%s#Y，因此获得了其奖励的#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,任务数据[self.任务id].名称,名称),频道="xt"})
          elseif 奖励参数<=90 and 让海啸席卷 then
            local 名称="魔兽残卷"
            玩家数据[id].道具:给予道具(id,名称,1)
            常规提示(id,"#Y/你获得了"..名称)
            广播消息({内容=format("#S(世界BOSS)#R/%s#Y经过一番激烈的战斗，最终战胜了#R%s#Y，因此获得了其奖励的#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,任务数据[self.任务id].名称,名称),频道="xt"})
          elseif 奖励参数<=95 and 让海啸席卷 then
            local 名称="仙玉"
            添加仙玉(取随机数(20,120),玩家数据[id].账号.id,"世界BOSS")
            常规提示(id,"#Y/你获得了"..名称)
            广播消息({内容=format("#S(世界BOSS)#R/%s#Y经过一番激烈的战斗，最终战胜了#R%s#Y，因此获得了其奖励的#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,任务数据[self.任务id].名称,名称),频道="xt"})
          else
            local 名称=取宝石()
            玩家数据[id].道具:给予道具(id,名称,取随机数(1,3))
            常规提示(id,"#Y/你获得了"..名称)
            广播消息({内容=format("#S(世界BOSS)#R/%s#Y经过一番激烈的战斗，最终战胜了#R%s#Y，因此获得了其奖励的#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,任务数据[self.任务id].名称,名称),频道="xt"})
          end
        elseif 等级==100 then
          if 奖励参数<=10 then
            local 名称="高级魔兽要诀"
            玩家数据[id].道具:给予道具(id,名称)
            常规提示(id,"#Y/你获得了"..名称)
            广播消息({内容=format("#S(世界BOSS)#R/%s#Y经过一番激烈的战斗，最终战胜了#R%s#Y，因此获得了其奖励的#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,任务数据[self.任务id].名称,名称),频道="xt"})
          elseif 奖励参数<=20 then
            local 名称="怪物卡片"
            玩家数据[id].道具:给予道具(id,名称,7)
            常规提示(id,"#Y/你获得了"..名称)
            广播消息({内容=format("#S(世界BOSS)#R/%s#Y经过一番激烈的战斗，最终战胜了#R%s#Y，因此获得了其奖励的#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,任务数据[self.任务id].名称,名称),频道="xt"})
          elseif 奖励参数<=30 then
            local 名称="九转金丹"
            玩家数据[id].道具:给予道具(id,名称,1,150)
            常规提示(id,"#Y/你获得了"..名称)
            广播消息({内容=format("#S(世界BOSS)#R/%s#Y经过一番激烈的战斗，最终战胜了#R%s#Y，因此获得了其奖励的#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,任务数据[self.任务id].名称,名称),频道="xt"})
          elseif 奖励参数<=40 then
            local 名称="高级召唤兽内丹"
            玩家数据[id].道具:给予道具(id,名称,1)
            常规提示(id,"#Y/你获得了"..名称)
            广播消息({内容=format("#S(世界BOSS)#R/%s#Y经过一番激烈的战斗，最终战胜了#R%s#Y，因此获得了其奖励的#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,任务数据[self.任务id].名称,名称),频道="xt"})
          elseif 奖励参数<=50 then
            local 名称="修炼果"
            玩家数据[id].道具:给予道具(id,名称,1)
            常规提示(id,"#Y/你获得了"..名称)
            广播消息({内容=format("#S(世界BOSS)#R/%s#Y经过一番激烈的战斗，最终战胜了#R%s#Y，因此获得了其奖励的#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,任务数据[self.任务id].名称,名称),频道="xt"})
          elseif 奖励参数<=60 then
            local 奖励数据=玩家数据[id].道具:给予书铁(id,{8,12})
            常规提示(id,"#Y你得到了#R"..奖励数据[1])
            广播消息({内容=format("#S(世界BOSS)#R/%s#Y经过一番激烈的战斗，最终战胜了#R%s#Y，因此获得了其奖励的#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,任务数据[self.任务id].名称,奖励数据[1]),频道="xt"})
          elseif 奖励参数<=70 then
            local 名称="星辉石"
            玩家数据[id].道具:给予道具(id,名称,取随机数(3,4))
            常规提示(id,"#Y/你获得了"..名称)
            广播消息({内容=format("#S(世界BOSS)#R/%s#Y经过一番激烈的战斗，最终战胜了#R%s#Y，因此获得了其奖励的#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,任务数据[self.任务id].名称,名称),频道="xt"})
          elseif 奖励参数<=80 then
            local 名称="二级未激活符石"
            玩家数据[id].道具:给予道具(id,名称,1)
            常规提示(id,"#Y/你获得了"..名称)
            广播消息({内容=format("#S(世界BOSS)#R/%s#Y经过一番激烈的战斗，最终战胜了#R%s#Y，因此获得了其奖励的#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,任务数据[self.任务id].名称,名称),频道="xt"})
          elseif 奖励参数<=83 then
            local 名称="高级魔兽要诀"
            local 技能=取特殊要诀()
            玩家数据[id].道具:给予道具(id,名称,nil,技能)
            广播消息({内容=format("#S(世界BOSS)#R/%s#Y经过一番激烈的战斗，最终战胜了#R%s#Y，因此获得了其奖励的#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,任务数据[self.任务id].名称,技能),频道="xt"})
          elseif 奖励参数<=90 and 释怀定制 then
            local 名称="20点点卡"
            添加点卡(20,玩家数据[id].账号,id,"世界BOSS")
            常规提示(id,"#Y/你获得了"..名称)
            广播消息({内容=format("#S(世界BOSS)#R/%s#Y经过一番激烈的战斗，最终战胜了#R%s#Y，因此获得了其奖励的#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,任务数据[self.任务id].名称,名称),频道="xt"})
          elseif 奖励参数<=95 and 释怀定制 then
            local 名称="40点点卡"
            添加点卡(40,玩家数据[id].账号,id,"世界BOSS")
            常规提示(id,"#Y/你获得了"..名称)
            广播消息({内容=format("#S(世界BOSS)#R/%s#Y经过一番激烈的战斗，最终战胜了#R%s#Y，因此获得了其奖励的#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,任务数据[self.任务id].名称,名称),频道="xt"})
          elseif 奖励参数<=95 and 神兽定制 then
            local 名称="仙玉"
            添加仙玉(取随机数(10,100),玩家数据[id].账号,id,"世界BOSS")
            常规提示(id,"#Y/你获得了"..名称)
            广播消息({内容=format("#S(世界BOSS)#R/%s#Y经过一番激烈的战斗，最终战胜了#R%s#Y，因此获得了其奖励的#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,任务数据[self.任务id].名称,名称),频道="xt"})
          elseif 奖励参数<=90 and 让海啸席卷 then
            local 名称="魔兽残卷"
            玩家数据[id].道具:给予道具(id,名称,1)
            常规提示(id,"#Y/你获得了"..名称)
            广播消息({内容=format("#S(世界BOSS)#R/%s#Y经过一番激烈的战斗，最终战胜了#R%s#Y，因此获得了其奖励的#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,任务数据[self.任务id].名称,名称),频道="xt"})
          elseif 奖励参数<=95 and 让海啸席卷 then
            local 名称="仙玉"
            添加仙玉(取随机数(20,120),玩家数据[id].账号.id,"世界BOSS")
            常规提示(id,"#Y/你获得了"..名称)
            广播消息({内容=format("#S(世界BOSS)#R/%s#Y经过一番激烈的战斗，最终战胜了#R%s#Y，因此获得了其奖励的#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,任务数据[self.任务id].名称,名称),频道="xt"})
          else
            local 名称=取宝石()
            玩家数据[id].道具:给予道具(id,名称,取随机数(3,5))
            常规提示(id,"#Y/你获得了"..名称)
            广播消息({内容=format("#S(世界BOSS)#R/%s#Y经过一番激烈的战斗，最终战胜了#R%s#Y，因此获得了其奖励的#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,任务数据[self.任务id].名称,名称),频道="xt"})
          end
       elseif 等级==150 then
          if 奖励参数<=10 then
            local 名称=取宝石()
            玩家数据[id].道具:给予道具(id,名称,取随机数(3,5))
            常规提示(id,"#Y/你获得了"..名称)
            广播消息({内容=format("#S(世界BOSS)#R/%s#Y经过一番激烈的战斗，最终战胜了#R%s#Y，因此获得了其奖励的#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,任务数据[self.任务id].名称,名称),频道="xt"})
          elseif 奖励参数<=20 then
            local 名称="怪物卡片"
            玩家数据[id].道具:给予道具(id,名称,8)
            常规提示(id,"#Y/你获得了"..名称)
            广播消息({内容=format("#S(世界BOSS)#R/%s#Y经过一番激烈的战斗，最终战胜了#R%s#Y，因此获得了其奖励的#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,任务数据[self.任务id].名称,名称),频道="xt"})
          elseif 奖励参数<=30 then
            local 奖励数据=玩家数据[id].道具:给予书铁(id,{13,15})
            常规提示(id,"#Y你得到了#R"..奖励数据[1])
            广播消息({内容=format("#S(世界BOSS)#R/%s#Y经过一番激烈的战斗，最终战胜了#R%s#Y，因此获得了其奖励的#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,任务数据[self.任务id].名称,奖励数据[1]),频道="xt"})
          elseif 奖励参数<=50 then
            local 名称="高级魔兽要诀"
            玩家数据[id].道具:给予道具(id,名称,1)
            常规提示(id,"#Y/你获得了"..名称)
            广播消息({内容=format("#S(世界BOSS)#R/%s#Y经过一番激烈的战斗，最终战胜了#R%s#Y，因此获得了其奖励的#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,任务数据[self.任务id].名称,名称),频道="xt"})
          elseif 奖励参数<=60 then
            local 名称="三级未激活符石"
            玩家数据[id].道具:给予道具(id,名称,1)
            常规提示(id,"#Y/你获得了"..名称)
            广播消息({内容=format("#S(世界BOSS)#R/%s#Y经过一番激烈的战斗，最终战胜了#R%s#Y，因此获得了其奖励的#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,任务数据[self.任务id].名称,名称),频道="xt"})
          elseif 奖励参数<=70 then
            local 名称="高级召唤兽内丹"
            玩家数据[id].道具:给予道具(id,名称,1)
            常规提示(id,"#Y/你获得了"..名称)
            广播消息({内容=format("#S(世界BOSS)#R/%s#Y经过一番激烈的战斗，最终战胜了#R%s#Y，因此获得了其奖励的#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,任务数据[self.任务id].名称,名称),频道="xt"})
          elseif 奖励参数<=75 then
            local 名称="灵饰指南书"
            玩家数据[id].道具:给予道具(id,"灵饰指南书",{12,14})
            常规提示(id,"#Y/你获得了"..名称)
            广播消息({内容=format("#S(世界BOSS)#R/%s#Y经过一番激烈的战斗，最终战胜了#R%s#Y，因此获得了其奖励的#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,任务数据[self.任务id].名称,名称),频道="xt"})
          elseif 奖励参数<=80 then
            local 名称="元灵晶石"
            玩家数据[id].道具:给予道具(id,"元灵晶石",{12,14})
            常规提示(id,"#Y/你获得了"..名称)
            广播消息({内容=format("#S(世界BOSS)#R/%s#Y经过一番激烈的战斗，最终战胜了#R%s#Y，因此获得了其奖励的#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,任务数据[self.任务id].名称,名称),频道="xt"})
          elseif 奖励参数<=83 then
            local 名称="高级魔兽要诀"
            local 技能=取特殊要诀()
            玩家数据[id].道具:给予道具(id,名称,nil,技能)
            广播消息({内容=format("#S(世界BOSS)#R/%s#Y经过一番激烈的战斗，最终战胜了#R%s#Y，因此获得了其奖励的#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,任务数据[self.任务id].名称,技能),频道="xt"})
          elseif 奖励参数<=90 and 释怀定制 then
            local 名称="20点点卡"
            添加点卡(20,玩家数据[id].账号,id,"世界BOSS")
            常规提示(id,"#Y/你获得了"..名称)
            广播消息({内容=format("#S(世界BOSS)#R/%s#Y经过一番激烈的战斗，最终战胜了#R%s#Y，因此获得了其奖励的#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,任务数据[self.任务id].名称,名称),频道="xt"})
          elseif 奖励参数<=95 and 释怀定制 then
            local 名称="40点点卡"
            添加点卡(40,玩家数据[id].账号,id,"世界BOSS")
            常规提示(id,"#Y/你获得了"..名称)
            广播消息({内容=format("#S(世界BOSS)#R/%s#Y经过一番激烈的战斗，最终战胜了#R%s#Y，因此获得了其奖励的#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,任务数据[self.任务id].名称,名称),频道="xt"})
          elseif 奖励参数<=95 and 神兽定制 then
            local 名称="仙玉"
            添加仙玉(取随机数(10,100),玩家数据[id].账号,id,"世界BOSS")
            常规提示(id,"#Y/你获得了"..名称)
            广播消息({内容=format("#S(世界BOSS)#R/%s#Y经过一番激烈的战斗，最终战胜了#R%s#Y，因此获得了其奖励的#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,任务数据[self.任务id].名称,名称),频道="xt"})
          elseif 奖励参数<=90 and 让海啸席卷 then
            local 名称="魔兽残卷"
            玩家数据[id].道具:给予道具(id,名称,1)
            常规提示(id,"#Y/你获得了"..名称)
            广播消息({内容=format("#S(世界BOSS)#R/%s#Y经过一番激烈的战斗，最终战胜了#R%s#Y，因此获得了其奖励的#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,任务数据[self.任务id].名称,名称),频道="xt"})
          elseif 奖励参数<=95 and 让海啸席卷 then
            local 名称="仙玉"
            添加仙玉(取随机数(20,120),玩家数据[id].账号.id,"世界BOSS")
            常规提示(id,"#Y/你获得了"..名称)
            广播消息({内容=format("#S(世界BOSS)#R/%s#Y经过一番激烈的战斗，最终战胜了#R%s#Y，因此获得了其奖励的#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,任务数据[self.任务id].名称,名称),频道="xt"})
          else
            local 名称="星辉石"
            玩家数据[id].道具:给予道具(id,名称,5)
            常规提示(id,"#Y/你获得了"..名称)
            广播消息({内容=format("#S(世界BOSS)#R/%s#Y经过一番激烈的战斗，最终战胜了#R%s#Y，因此获得了其奖励的#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,任务数据[self.任务id].名称,名称),频道="xt"})
          end
        end
      end
  elseif self.战斗类型==100032 then--天庭叛逆
    local 等级=取队伍平均等级(玩家数据[id].队伍,id)
    local 经验=等级*500+3000
    local 银子=等级*等级*4
    local 奖励参数=取随机数()
    if 让海啸席卷 then
      银子=银子*4
      经验=经验*2
    end
    玩家数据[id].角色:添加经验(经验,"天庭叛逆")
    玩家数据[id].角色:添加储备(银子,任务数据[self.任务id].名称,1)
    if 让海啸席卷 and 取随机数()<=15 then
      添加仙玉(取随机数(3,7),玩家数据[id].账号,id,"天庭叛逆")
    end
    if 玩家数据[id].角色.数据.参战信息~=nil then
        玩家数据[id].召唤兽:获得经验(玩家数据[id].角色.数据.参战宝宝.认证码,qz(经验*0.5),id,"天庭叛逆",self.地图等级)
    end
    if 活跃数据[id]==nil then
      活跃数据[id]={活跃度=0,领取100活跃=false,领取200活跃=false,领取300活跃=false,领取400活跃=false,领取500活跃=false,师门次数=20,官职次数=30,鬼怪次数=25,封妖次数=3,游泳次数=1,镖王次数=1,押镖次数=50,水果次数=25,天庭叛逆次数=25,十二星宿次数=5,门派闯关次数=1,地煞星次数=5,天罡星次数=5,飞贼次数=5,知了先锋=20,小知了王=20,知了王=10,世界BOSS次数=2,抓鬼次数=50,初出江湖次数=20,帮派青龙次数=100,帮派玄武次数=100,妖王次数=3}
    end
    if 活跃数据[id].天庭叛逆次数==nil then
      活跃数据[id].天庭叛逆次数=25
    end
    if 活跃数据[id].天庭叛逆次数>0 then
      活跃数据[id].活跃度=活跃数据[id].活跃度+2
      玩家数据[id].角色.数据.累积活跃.当前积分=玩家数据[id].角色.数据.累积活跃.当前积分+活跃数据[id].活跃度
      玩家数据[id].角色.数据.累积活跃.总积分=玩家数据[id].角色.数据.累积活跃.总积分+活跃数据[id].活跃度
      活跃数据[id].天庭叛逆次数=活跃数据[id].天庭叛逆次数-1
    end
    if 奖励参数<=15 then
      local 名称="魔兽要诀"
      玩家数据[id].道具:给予道具(id,名称)
      常规提示(id,"#Y/你获得了"..名称)
      广播消息({内容=format("#S(天庭叛逆)#R/%s#Y经过一番激烈的战斗，最终战胜了叛逃的#R%s#Y，因此获得了其奖励的#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,任务数据[self.任务id].名称,名称),频道="xt"})
    elseif 奖励参数<=30 then
      local 名称="九转金丹"
      玩家数据[id].道具:给予道具(id,名称,1,20)
      常规提示(id,"#Y/你获得了"..名称)
      广播消息({内容=format("#S(天庭叛逆)#R/%s#Y经过一番激烈的战斗，最终战胜了叛逃的#R%s#Y，因此获得了其奖励的#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,任务数据[self.任务id].名称,名称),频道="xt"})
    elseif 奖励参数<=32 then
      local 名称="仙玉"
      添加仙玉(取随机数(2,5),玩家数据[id].账号,id,"天庭叛逆")
      常规提示(id,"#Y/你获得了"..名称)
      广播消息({内容=format("#S(天庭叛逆)#R/%s#Y经过一番激烈的战斗，最终战胜了叛逃的#R%s#Y，因此获得了其奖励的#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,任务数据[self.任务id].名称,名称),频道="xt"})
    elseif 奖励参数<=60 then
      local 名称=取宝石()
      if 让海啸席卷 then
        玩家数据[id].道具:给予道具(id,名称,取随机数(2,5))
      else
        玩家数据[id].道具:给予道具(id,名称,取随机数(2,3))
      end
      常规提示(id,"#Y/你获得了"..名称)
      广播消息({内容=format("#S(天庭叛逆)#R/%s#Y经过一番激烈的战斗，最终战胜了叛逃的#R%s#Y，因此获得了其奖励的#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,任务数据[self.任务id].名称,名称),频道="xt"})
    elseif 奖励参数<=70 then
      local 名称="星辉石"
      玩家数据[id].道具:给予道具(id,名称,取随机数(1,2))
      常规提示(id,"#Y/你获得了"..名称)
      广播消息({内容=format("#S(天庭叛逆)#R/%s#Y经过一番激烈的战斗，最终战胜了叛逃的#R%s#Y，因此获得了其奖励的#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,任务数据[self.任务id].名称,名称),频道="xt"})
    elseif 奖励参数<=73 and 老八定制 then
      local 奖励数据=玩家数据[id].道具:给予书铁(id,{10,12})
      local 名称=奖励数据[1]
      常规提示(id,"#Y你得到了#R"..名称)
      广播消息({内容=format("#S(天庭叛逆)#R/%s#Y经过一番激烈的战斗，最终战胜了叛逃的#R%s#Y，因此获得了其奖励的#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,任务数据[self.任务id].名称,名称),频道="xt"})
    elseif 奖励参数<=76 and 老八定制 then
      local 名称="二级未激活符石"
      玩家数据[id].道具:给予道具(id,名称,1)
      常规提示(id,"#Y/你获得了"..名称)
      广播消息({内容=format("#S(天庭叛逆)#R/%s#Y经过一番激烈的战斗，最终战胜了叛逃的#R%s#Y，因此获得了其奖励的#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,任务数据[self.任务id].名称,名称),频道="xt"})
    elseif 奖励参数<=82 and 老八定制 then
      local 名称="超级金柳露"
      玩家数据[id].道具:给予道具(id,名称)
      常规提示(id,"#Y/你获得了"..名称)
      广播消息({内容=format("#S(天庭叛逆)#R/%s#Y经过一番激烈的战斗，最终战胜了叛逃的#R%s#Y，因此获得了其奖励的#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,任务数据[self.任务id].名称,名称),频道="xt"})
    elseif 奖励参数 <= 86 and 老八定制  then
      local 名称=取宝石()
      玩家数据[id].道具:给予道具(id,名称,1)
      常规提示(id,"#Y/你获得了"..名称)
      广播消息({内容=format("#S(天庭叛逆)#R/%s#Y经过一番激烈的战斗，最终战胜了叛逃的#R%s#Y，因此获得了其奖励的#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,任务数据[self.任务id].名称,名称),频道="xt"})
    elseif 奖励参数<=88 and 老八定制  then
      local 名称="灵饰指南书"
      玩家数据[id].道具:给予道具(id,"灵饰指南书",{6,8})
      常规提示(id,"#Y/你获得了"..名称)
      广播消息({内容=format("#S(天庭叛逆)#R/%s#Y经过一番激烈的战斗，最终战胜了叛逃的#R%s#Y，因此获得了其奖励的#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,任务数据[self.任务id].名称,名称),频道="xt"})
    elseif 奖励参数<=88 and 让海啸席卷  then
      local 名称="附魔宝珠"
      玩家数据[id].道具:给予道具(id,名称,1)
      常规提示(id,"#Y/你获得了"..名称)
      广播消息({内容=format("#S(天庭叛逆)#R/%s#Y经过一番激烈的战斗，最终战胜了叛逃的#R%s#Y，因此获得了其奖励的#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,任务数据[self.任务id].名称,名称),频道="xt"})
    elseif 奖励参数<=90 and 老八定制  then
      local 名称="元灵晶石"
      玩家数据[id].道具:给予道具(id,"元灵晶石",{6,8})
      常规提示(id,"#Y/你获得了"..名称)
      广播消息({内容=format("#S(天庭叛逆)#R/%s#Y经过一番激烈的战斗，最终战胜了叛逃的#R%s#Y，因此获得了其奖励的#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,任务数据[self.任务id].名称,名称),频道="xt"})
    elseif 奖励参数<=75 and 释怀定制 then
      local 名称="5点点卡"
      添加点卡(5,玩家数据[id].账号,id,"天庭叛逆")
      常规提示(id,"#Y/你获得了"..名称)
      广播消息({内容=format("#S(天庭叛逆)#R/%s#Y经过一番激烈的战斗，最终战胜了叛逃的#R%s#Y，因此获得了其奖励的#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,任务数据[self.任务id].名称,名称),频道="xt"})
    elseif 奖励参数<=76 and 释怀定制 then
      local 名称="10点点卡"
      添加点卡(10,玩家数据[id].账号,id,"天庭叛逆")
      常规提示(id,"#Y/你获得了"..名称)
      广播消息({内容=format("#S(天庭叛逆)#R/%s#Y经过一番激烈的战斗，最终战胜了叛逃的#R%s#Y，因此获得了其奖励的#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,任务数据[self.任务id].名称,名称),频道="xt"})
    end

  elseif self.战斗类型==100033 then--捣乱的水果
    local 等级=取队伍平均等级(玩家数据[id].队伍,id)
    local 经验=等级*300+任务数据[self.任务id].等级*1000
    local 银子=等级*等级*3
    local 奖励参数=取随机数(1,50)
    玩家数据[id].角色:添加经验(经验,"捣乱的水果")
    玩家数据[id].角色:添加储备(银子,任务数据[self.任务id].名称,1)
    if 老八定制 and 玩家数据[id].角色.数据.帮派数据~=nil then
      添加帮贡(id,5)
    end
    if 活跃数据[id]==nil then
      活跃数据[id]={活跃度=0,领取100活跃=false,领取200活跃=false,领取300活跃=false,领取400活跃=false,领取500活跃=false,师门次数=20,官职次数=30,鬼怪次数=25,封妖次数=3,游泳次数=1,镖王次数=1,押镖次数=50,水果次数=25,天庭叛逆次数=25,十二星宿次数=5,门派闯关次数=1,地煞星次数=5,天罡星次数=5,飞贼次数=5,知了先锋=20,小知了王=20,知了王=10,世界BOSS次数=2,抓鬼次数=50,初出江湖次数=20,帮派青龙次数=100,帮派玄武次数=100,妖王次数=3}
    end
    if 活跃数据[id].水果次数>0 then
      活跃数据[id].活跃度=活跃数据[id].活跃度+2
      玩家数据[id].角色.数据.累积活跃.当前积分=玩家数据[id].角色.数据.累积活跃.当前积分+活跃数据[id].活跃度
      玩家数据[id].角色.数据.累积活跃.总积分=玩家数据[id].角色.数据.累积活跃.总积分+活跃数据[id].活跃度
      活跃数据[id].水果次数=活跃数据[id].水果次数-1
    end
    if 玩家数据[id].角色.数据.参战信息~=nil then
        玩家数据[id].召唤兽:获得经验(玩家数据[id].角色.数据.参战宝宝.认证码,qz(经验*0.5),id,"捣乱的水果",self.地图等级)
    end
    if 奖励参数<=4 then
      local 名称="九转金丹"
      玩家数据[id].道具:给予道具(id,名称,1,20)
      常规提示(id,"#Y/你获得了"..名称)
      广播消息({内容=format("#S(捣乱的水果)#R/%s#Y经过一番激烈的战斗，最终战胜了叛逃的#R%s#Y，因此获得了其奖励的#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,任务数据[self.任务id].名称,名称),频道="xt"})
    elseif 奖励参数<=8 then
      local 名称=取宝石()
      玩家数据[id].道具:给予道具(id,名称,取随机数(2,3))
      常规提示(id,"#Y/你获得了"..名称)
      广播消息({内容=format("#S(捣乱的水果)#R/%s#Y经过一番激烈的战斗，最终战胜了叛逃的#R%s#Y，因此获得了其奖励的#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,任务数据[self.任务id].名称,名称),频道="xt"})
    elseif 奖励参数<=13 and 老八定制 then
      local 奖励数据=玩家数据[id].道具:给予书铁(id,{8,10})
      local 名称=奖励数据[1]
      常规提示(id,"#Y你得到了#R"..名称)
      广播消息({内容=format("#S(捣乱的水果)#R/%s#Y经过一番激烈的战斗，最终战胜了#R%s#Y，因此获得了其奖励的#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,任务数据[self.任务id].名称,名称),频道="xt"})
    elseif 奖励参数<=13 and 释怀定制 then
      local 名称="5点点卡"
      添加点卡(5,玩家数据[id].账号,id,"捣乱的水果")
      常规提示(id,"#Y/你获得了"..名称)
      广播消息({内容=format("#S(捣乱的水果)#R/%s#Y经过一番激烈的战斗，最终战胜了#R%s#Y，因此获得了其奖励的#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,任务数据[self.任务id].名称,名称),频道="xt"})
    elseif 奖励参数<=14 and 释怀定制 then
      local 名称="10点点卡"
      添加点卡(10,玩家数据[id].账号,id,"捣乱的水果")
      常规提示(id,"#Y/你获得了"..名称)
      广播消息({内容=format("#S(捣乱的水果)#R/%s#Y经过一番激烈的战斗，最终战胜了#R%s#Y，因此获得了其奖励的#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,任务数据[self.任务id].名称,名称),频道="xt"})
    elseif 奖励参数<=13 then
      local 名称="仙玉"
      添加仙玉(取随机数(2,5),玩家数据[id].账号,id,"捣乱的水果")
      常规提示(id,"#Y/你获得了"..名称)
      广播消息({内容=format("#S(捣乱的水果)#R/%s#Y经过一番激烈的战斗，最终战胜了#R%s#Y，因此获得了其奖励的#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,任务数据[self.任务id].名称,名称),频道="xt"})
    elseif 奖励参数<=15 and 老八定制 then
      local 名称="一级未激活符石"
      玩家数据[id].道具:给予道具(id,名称,1)
      常规提示(id,"#Y/你获得了"..名称)
      广播消息({内容=format("#S(捣乱的水果)#R/%s#Y经过一番激烈的战斗，最终战胜了#R%s#Y，因此获得了其奖励的#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,任务数据[self.任务id].名称,名称),频道="xt"})
    elseif 奖励参数<=25 and 老八定制 then
      local 名称="金柳露"
      玩家数据[id].道具:给予道具(id,名称)
      常规提示(id,"#Y/你获得了"..名称)
      广播消息({内容=format("#S(捣乱的水果)#R/%s#Y经过一番激烈的战斗，最终战胜了#R%s#Y，因此获得了其奖励的#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,任务数据[self.任务id].名称,名称),频道="xt"})
    elseif 奖励参数<=22 and 让海啸席卷 then
      local 名称="魔兽要诀"
      玩家数据[id].道具:给予道具(id,名称)
      常规提示(id,"#Y/你获得了"..名称)
      广播消息({内容=format("#S(捣乱的水果)#R/%s#Y经过一番激烈的战斗，最终战胜了#R%s#Y，因此获得了其奖励的#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,任务数据[self.任务id].名称,名称),频道="xt"})
    elseif 奖励参数<=30 and 让海啸席卷 then
      local 奖励数据=玩家数据[id].道具:给予书铁(id,{6,6})
      local 名称=奖励数据[1]
      常规提示(id,"#Y你得到了#R"..名称)
      广播消息({内容=format("#S(捣乱的水果)#R/%s#Y经过一番激烈的战斗，最终战胜了#R%s#Y，因此获得了其奖励的#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,任务数据[self.任务id].名称,名称),频道="xt"})
    elseif 奖励参数<=40 and 让海啸席卷 then
      local 名称="金银锦盒"
      玩家数据[id].道具:给予道具(id,名称,1)
      常规提示(id,"#Y/你获得了"..名称)
      广播消息({内容=format("#S(捣乱的水果)#R/%s#Y经过一番激烈的战斗，最终战胜了#R%s#Y，因此获得了其奖励的#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,任务数据[self.任务id].名称,名称),频道="xt"})
    elseif 奖励参数<=43 and 让海啸席卷 then
      local 名称="初级神魂丹"
      玩家数据[id].道具:给予道具(id,名称,1)
      常规提示(id,"#Y/你获得了"..名称)
      广播消息({内容=format("#S(捣乱的水果)#R/%s#Y经过一番激烈的战斗，最终战胜了#R%s#Y，因此获得了其奖励的#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,任务数据[self.任务id].名称,名称),频道="xt"})
    elseif 奖励参数<=45 and 让海啸席卷 then
      local 名称="中级神魂丹"
      玩家数据[id].道具:给予道具(id,名称,1)
      常规提示(id,"#Y/你获得了"..名称)
      广播消息({内容=format("#S(捣乱的水果)#R/%s#Y经过一番激烈的战斗，最终战胜了#R%s#Y，因此获得了其奖励的#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,任务数据[self.任务id].名称,名称),频道="xt"})
    elseif 奖励参数<=46 and 让海啸席卷 then
      local 名称="高级神魂丹"
      玩家数据[id].道具:给予道具(id,名称,1)
      常规提示(id,"#Y/你获得了"..名称)
      广播消息({内容=format("#S(捣乱的水果)#R/%s#Y经过一番激烈的战斗，最终战胜了#R%s#Y，因此获得了其奖励的#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,任务数据[self.任务id].名称,名称),频道="xt"})
    end
  elseif self.战斗类型==100066 then
      local 等级=取队伍平均等级(玩家数据[id].队伍,id)
      local 经验=等级*400+30000
      local 银子=等级*等级*2
      玩家数据[id].角色:添加经验(经验,"车迟斗法贡品")
      玩家数据[id].角色:添加银子(银子,"车迟斗法贡品",1)
      if 玩家数据[id].角色.数据.参战信息~=nil then
        玩家数据[id].召唤兽:获得经验(玩家数据[id].角色.数据.参战宝宝.认证码,qz(经验*0.5),id,"车迟斗法",self.地图等级)
      end
      if 让海啸席卷 and  取随机数() <= 15 then
        添加仙玉(取随机数(1,50),玩家数据[id].账号,id,"车迟斗法")
      end
  elseif self.战斗类型==100067 then
      local 等级=取队伍平均等级(玩家数据[id].队伍,id)
      local 经验=(等级*500+3000)*10
      local 银子=(等级*等级*2)*10
      玩家数据[id].角色:添加经验(经验,"车迟斗法三清")
      玩家数据[id].角色:添加银子(银子,"车迟斗法三清",1)
      if 玩家数据[id].角色.数据.参战信息~=nil then
         玩家数据[id].召唤兽:获得经验(玩家数据[id].角色.数据.参战宝宝.认证码,qz(经验*0.5),id,"车迟斗法",self.地图等级)
      end
      if 让海啸席卷 and  取随机数() <= 15 then
        添加仙玉(取随机数(1,50),玩家数据[id].账号,id,"车迟斗法")
      end
  elseif self.战斗类型==100068 then
      local 等级=取队伍平均等级(玩家数据[id].队伍,id)
      local 经验=(等级*500+3000)*15
      local 银子=(等级*等级*2)*15
      玩家数据[id].角色:添加经验(经验,"车迟斗法求雨")
      玩家数据[id].角色:添加银子(银子,"车迟斗法求雨",1)
      if 玩家数据[id].角色.数据.参战信息~=nil then
         玩家数据[id].召唤兽:获得经验(玩家数据[id].角色.数据.参战宝宝.认证码,qz(经验*0.5),id,"车迟斗法",self.地图等级)
      end
      if 让海啸席卷 and  取随机数() <= 15 then
        添加仙玉(取随机数(1,50),玩家数据[id].账号,id,"车迟斗法")
      end
  elseif self.战斗类型==100069 then
      local 等级=取队伍平均等级(玩家数据[id].队伍,id)
      local 经验=(等级*500+3000)*15
      local 银子=(等级*等级*2)*15
      玩家数据[id].角色:添加经验(经验,"车迟斗法不动")
      玩家数据[id].角色:添加银子(银子,"车迟斗法不动",1)
      if 玩家数据[id].角色.数据.参战信息~=nil then
         玩家数据[id].召唤兽:获得经验(玩家数据[id].角色.数据.参战宝宝.认证码,qz(经验*0.5),id,"车迟斗法",self.地图等级)
      end
      if 让海啸席卷 and  取随机数() <= 15 then
        添加仙玉(取随机数(1,50),玩家数据[id].账号,id,"车迟斗法")
      end
  elseif self.战斗类型==100070 then
      local 等级=取队伍平均等级(玩家数据[id].队伍,id)
      local 经验=(等级*500+3000)*20
      local 银子=(等级*等级*2)*20
      玩家数据[id].角色:添加经验(经验,"车迟斗法BOSS")
      玩家数据[id].角色:添加银子(银子,"车迟斗法BOSS",1)
      if 玩家数据[id].角色.数据.参战信息~=nil then
         玩家数据[id].召唤兽:获得经验(玩家数据[id].角色.数据.参战宝宝.认证码,qz(经验*0.5),id,"车迟斗法",self.地图等级)
      end
      if 让海啸席卷 then
        添加仙玉(300,玩家数据[id].账号,id,"车迟斗法")
      end
  elseif self.战斗类型>= 100071 and self.战斗类型  <= 100076 then
      local 等级=取队伍平均等级(玩家数据[id].队伍,id)
      local 经验=qz((等级*150*2+3000))
      local 银子=qz((等级*100*3))
      玩家数据[id].角色:添加经验(经验,"王者荣耀")
      玩家数据[id].角色:添加银子(银子,"王者荣耀",1)
      local 奖励参数 = 取随机数(1,100)
      if self.战斗类型 == 100071 then
        if 奖励参数 <= 30 then
          添加仙玉(取随机数(1,4),玩家数据[id].账号,id,"倔强青铜")
          广播消息({内容=format("#S(倔强青铜)#R/%s#Y虐的#R倔强青铜幼儿园#Y哭的找妈妈,还抢走了他的#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,"仙玉"),频道="xt"})
        elseif 奖励参数 <=35 then
          local 名称=取强化石()
          玩家数据[id].道具:给予道具(id,名称,取随机数(1,3))
          常规提示(id,"#Y/你获得了"..名称)
          广播消息({内容=format("#S(倔强青铜)#R/%s#Y虐的#R倔强青铜幼儿园#Y哭的找妈妈,还抢走了他的#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,名称),频道="xt"})
        elseif 奖励参数 <= 42 then
          local 名称="魔兽要诀"
          玩家数据[id].道具:给予道具(id,名称)
          常规提示(id,"#Y/你获得了"..名称)
          广播消息({内容=format("#S(倔强青铜)#R/%s#Y虐的#R倔强青铜幼儿园#Y哭的找妈妈,还抢走了他的#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,名称),频道="xt"})
        elseif 奖励参数 <= 50 then
          local 名称="月华露"
          玩家数据[id].道具:给予道具(id,名称,1,500)
          常规提示(id,"#Y/你获得了"..名称)
          广播消息({内容=format("#S(倔强青铜)#R/%s#Y虐的#R倔强青铜幼儿园#Y哭的找妈妈,还抢走了他的#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,名称),频道="xt"})
        end
      elseif self.战斗类型 == 100072 then
        if 奖励参数 <= 30 then
          添加仙玉(取随机数(2,5),玩家数据[id].账号,id,"秩序白银")
          广播消息({内容=format("#S(秩序白银)#R/%s#Y虐的#R秩序白银小学生#Y哇哇直哭,还抢走了他的#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,"仙玉"),频道="xt"})
        elseif 奖励参数 <=36 then
          local 名称=取宝石()
          玩家数据[id].道具:给予道具(id,名称,取随机数(1,3))
          常规提示(id,"#Y/你获得了"..名称)
          广播消息({内容=format("#S(秩序白银)#R/%s#Y虐的#R秩序白银小学生#Y哇哇直哭,还抢走了他的#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,名称),频道="xt"})
        elseif 奖励参数 <= 51 then
          local 名称="魔兽要诀"
          玩家数据[id].道具:给予道具(id,名称)
          常规提示(id,"#Y/你获得了"..名称)
          广播消息({内容=format("#S(秩序白银)#R/%s#Y虐的#R秩序白银小学生#Y哇哇直哭,还抢走了他的#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,名称),频道="xt"})
        end
      elseif self.战斗类型 == 100073 then
        if 奖励参数 <= 30 then
          添加仙玉(取随机数(3,6),玩家数据[id].账号,id,"荣耀黄金")
          广播消息({内容=format("#S(荣耀黄金)#R/%s#Y打的#R荣耀黄金初中生#Y不敢去上学,还抢走了他的#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,"仙玉"),频道="xt"})
        elseif 奖励参数 <=36 then
          local 奖励数据=玩家数据[id].道具:给予书铁(id,{7,12})
          常规提示(id,"#Y你得到了#R"..奖励数据[1])
          广播消息({内容=format("#S(荣耀黄金)#R/%s#Y打的#R荣耀黄金初中生#Y不敢去上学,还抢走了他的#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,奖励数据[1]),频道="xt"})
        elseif 奖励参数 <= 42 then
          local 名称="高级魔兽要诀"
          玩家数据[id].道具:给予道具(id,名称)
          常规提示(id,"#Y/你获得了"..名称)
          广播消息({内容=format("#S(荣耀黄金)#R/%s#Y打的#R荣耀黄金初中生#Y不敢去上学,还抢走了他的#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,名称),频道="xt"})
        end
      elseif self.战斗类型 == 100074 then
        if 奖励参数 <= 30 then
          添加仙玉(取随机数(6,10),玩家数据[id].账号,id,"永和钻石")
          广播消息({内容=format("#S(永和钻石)#R/%s#Y打的#R永和钻石高中生#Y跪地求饶,乖乖的上交了#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,"仙玉"),频道="xt"})
        elseif 奖励参数 <=35 then
          local 名称="附魔宝珠"
          玩家数据[id].道具:给予道具(id,名称,1)
          常规提示(id,"#Y/你获得了"..名称)
          广播消息({内容=format("#S(永和钻石)#R/%s#Y打的#R永和钻石高中生#Y跪地求饶,乖乖的上交了#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,名称),频道="xt"})
        elseif 奖励参数 <= 40 then
          local 名称="高级魔兽要诀"
          玩家数据[id].道具:给予道具(id,名称)
          常规提示(id,"#Y/你获得了"..名称)
          广播消息({内容=format("#S(永和钻石)#R/%s#Y打的#R永和钻石高中生#Y跪地求饶,乖乖的上交了#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,名称),频道="xt"})
        end
      elseif self.战斗类型 == 100075 then
        if 奖励参数 <= 30 then
          添加仙玉(取随机数(11,20),玩家数据[id].账号,id,"至尊星耀")
          广播消息({内容=format("#S(至尊星耀)#R/%s#Y打的#R至尊星耀大学生#Y跪地求饶,乖乖的上交了#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,"仙玉"),频道="xt"})
        elseif 奖励参数 <= 38 then
          local 名称=取宝石()
          玩家数据[id].道具:给予道具(id,名称,取随机数(2,7))
          常规提示(id,"#Y/你获得了"..名称)
          广播消息({内容=format("#S(至尊星耀)#R/%s#Y打的#R至尊星耀大学生#Y跪地求饶,乖乖的上交了#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,名称),频道="xt"})
        elseif 奖励参数 <= 40 then
          local 名称="高级魔兽要诀"
          玩家数据[id].道具:给予道具(id,名称)
          常规提示(id,"#Y/你获得了"..名称)
          广播消息({内容=format("#S(至尊星耀)#R/%s#Y打的#R至尊星耀大学生#Y跪地求饶,乖乖的上交了#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,名称),频道="xt"})
        elseif 奖励参数 <=57 then
          local 奖励数据=玩家数据[id].道具:给予书铁(id,{12,15})
          常规提示(id,"#Y你得到了#R"..奖励数据[1])
          广播消息({内容=format("#S(至尊星耀)#R/%s#Y打的#R至尊星耀大学生#Y跪地求饶,乖乖的上交了#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,奖励数据[1]),频道="xt"})
        end
      elseif self.战斗类型 == 100076 then
        if 奖励参数 <= 30 then
          添加仙玉(取随机数(21,40),玩家数据[id].账号,id,"最强王者")
          广播消息({内容=format("#S(最强王者)#R/%s#Y挑战#R最强王者研究生#Y成功,并掠夺了他的#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,"仙玉"),频道="xt"})
        elseif 奖励参数 <= 38 then
          local 名称=取宝石()
          玩家数据[id].道具:给予道具(id,名称,取随机数(7,11))
          常规提示(id,"#Y/你获得了"..名称)
          广播消息({内容=format("#S(最强王者)#R/%s#Y挑战#R最强王者研究生#Y成功,并掠夺了他的#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,名称),频道="xt"})
        elseif 奖励参数 <= 58 then
          local 名称="高级魔兽要诀"
          玩家数据[id].道具:给予道具(id,名称)
          常规提示(id,"#Y/你获得了"..名称)
          广播消息({内容=format("#S(最强王者)#R/%s#Y挑战#R最强王者研究生#Y成功,并掠夺了他的#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,名称),频道="xt"})
        elseif 奖励参数 <=60 then
          local 奖励数据=玩家数据[id].道具:给予书铁(id,{14,15})
          常规提示(id,"#Y你得到了#R"..奖励数据[1])
          广播消息({内容=format("#S(最强王者)#R/%s#Y挑战#R最强王者研究生#Y成功,并掠夺了他的#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,奖励数据[1]),频道="xt"})
        elseif 奖励参数 <=62 then
          local 名称="高级魔兽要诀"
          local 技能=取特殊要诀()
          玩家数据[id].道具:给予道具(id,名称,nil,技能)
          常规提示(id,"#Y你得到了#R"..技能)
          广播消息({内容=format("#S(最强王者)#R/%s#Y挑战#R最强王者研究生#Y成功,并掠夺了他的#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,技能),频道="xt"})
        end
      end
  elseif self.战斗类型 == 100077 then
    local 等级=取队伍平均等级(玩家数据[id].队伍,id)
    local 经验=qz((等级*150*2+3000))
    local 银子=qz((等级*100*3))
    玩家数据[id].角色:添加经验(经验,"梦幻粉丝")
    玩家数据[id].角色:添加银子(银子,"梦幻粉丝",1)
    local 奖励参数 = 取随机数(1,300)
    if 奖励参数 <= 30 then
      添加仙玉(取随机数(10,30),玩家数据[id].账号,id,"梦幻粉丝")
      广播消息({内容=format("#S(梦幻粉丝)#R/%s#Y挑战#R梦幻粉丝#Y成功,并获得了他奖励的的#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,"仙玉"),频道="xt"})
    elseif 奖励参数 <= 45 then
      local 名称=取宝石()
      玩家数据[id].道具:给予道具(id,名称,取随机数(1,3))
      常规提示(id,"#Y/你获得了"..名称)
      广播消息({内容=format("#S(梦幻粉丝)#R/%s#Y挑战#R梦幻粉丝#Y成功,并获得了他奖励的的#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,名称),频道="xt"})
    elseif 奖励参数 <= 60 then
      local 名称="魔兽要诀"
      玩家数据[id].道具:给予道具(id,名称)
      常规提示(id,"#Y/你获得了"..名称)
      广播消息({内容=format("#S(梦幻粉丝)#R/%s#Y挑战#R梦幻粉丝#Y成功,并获得了他奖励的的#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,名称),频道="xt"})
    elseif 奖励参数 <=80 then
      local 奖励数据=玩家数据[id].道具:给予书铁(id,{7,12})
      常规提示(id,"#Y你得到了#R"..奖励数据[1])
      广播消息({内容=format("#S(梦幻粉丝)#R/%s#Y挑战#R梦幻粉丝#Y成功,并获得了他奖励的的#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,奖励数据[1]),频道="xt"})
    elseif 奖励参数 <=100 then
      local 名称=取强化石()
      玩家数据[id].道具:给予道具(id,名称,取随机数(1,3))
      常规提示(id,"#Y/你获得了"..名称)
      广播消息({内容=format("#S(梦幻粉丝)#R/%s#Y挑战#R梦幻粉丝#Y成功,并获得了他奖励的的#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,技能),频道="xt"})
    elseif 奖励参数 <=110 then
      local 名称="初级神魂丹"
      玩家数据[id].道具:给予道具(id,名称,1)
      常规提示(id,"#Y/你获得了"..名称)
      广播消息({内容=format("#S(梦幻粉丝)#R/%s#Y挑战#R梦幻粉丝#Y成功,并获得了他奖励的的#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,技能),频道="xt"})
    elseif 奖励参数 <=150 then
      local 名称="金银锦盒"
      玩家数据[id].道具:给予道具(id,名称,1)
      常规提示(id,"#Y/你获得了"..名称)
      广播消息({内容=format("#S(梦幻粉丝)#R/%s#Y挑战#R梦幻粉丝#Y成功,并获得了他奖励的的#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,技能),频道="xt"})
    elseif 奖励参数 <=170 then
      local 名称="九转金丹"
      玩家数据[id].道具:给予道具(id,名称,1,50)
      常规提示(id,"#Y/你获得了"..名称)
      广播消息({内容=format("#S(梦幻粉丝)#R/%s#Y挑战#R梦幻粉丝#Y成功,并获得了他奖励的的#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,技能),频道="xt"})
    elseif 奖励参数 <=200 then
      local 名称="修炼果"
      玩家数据[id].道具:给予道具(id,名称,1)
      常规提示(id,"#Y/你获得了"..名称)
      广播消息({内容=format("#S(梦幻粉丝)#R/%s#Y挑战#R梦幻粉丝#Y成功,并获得了他奖励的的#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,技能),频道="xt"})
    elseif 奖励参数 <=210 then
      local 名称="易经丹"
      玩家数据[id].道具:给予道具(id,名称,1)
      常规提示(id,"#Y/你获得了"..名称)
      广播消息({内容=format("#S(梦幻粉丝)#R/%s#Y挑战#R梦幻粉丝#Y成功,并获得了他奖励的的#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,技能),频道="xt"})
    elseif 奖励参数 <=220 then
      local 名称="玉葫灵髓"
      玩家数据[id].道具:给予道具(id,名称,1)
      常规提示(id,"#Y/你获得了"..名称)
      广播消息({内容=format("#S(梦幻粉丝)#R/%s#Y挑战#R梦幻粉丝#Y成功,并获得了他奖励的的#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,技能),频道="xt"})
    elseif 奖励参数 <=250 then
      local 名称="月华露"
      玩家数据[id].道具:给予道具(id,名称,1,500)
      常规提示(id,"#Y/你获得了"..名称)
      广播消息({内容=format("#S(梦幻粉丝)#R/%s#Y挑战#R梦幻粉丝#Y成功,并获得了他奖励的的#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,技能),频道="xt"})
    elseif 奖励参数 <=260 then
      local 名称="高级魔兽要诀"
      玩家数据[id].道具:给予道具(id,名称,1)
      常规提示(id,"#Y/你获得了"..名称)
      广播消息({内容=format("#S(梦幻粉丝)#R/%s#Y挑战#R梦幻粉丝#Y成功,并获得了他奖励的的#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,技能),频道="xt"})
    elseif 奖励参数 <=270 then
      local 名称="坐骑内丹"
      玩家数据[id].道具:给予道具(id,名称,1)
      常规提示(id,"#Y/你获得了"..名称)
      广播消息({内容=format("#S(梦幻粉丝)#R/%s#Y挑战#R梦幻粉丝#Y成功,并获得了他奖励的的#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,技能),频道="xt"})
    elseif 奖励参数 <=285 then
      local 名称="灵饰指南书"
      玩家数据[id].道具:给予道具(id,名称,{6})
      常规提示(id,"#Y/你获得了"..名称)
      广播消息({内容=format("#S(梦幻粉丝)#R/%s#Y挑战#R梦幻粉丝#Y成功,并获得了他奖励的的#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,技能),频道="xt"})
    elseif 奖励参数 <=300 then
      local 名称="元灵晶石"
      玩家数据[id].道具:给予道具(id,名称,{6})
      常规提示(id,"#Y/你获得了"..名称)
      广播消息({内容=format("#S(梦幻粉丝)#R/%s#Y挑战#R梦幻粉丝#Y成功,并获得了他奖励的的#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,技能),频道="xt"})
    end
  elseif self.战斗类型==100116 then
    local 等级=玩家数据[id].角色.数据.等级
    玩家数据[id].角色:添加银子(等级*300,"水陆大会翼虎将军银子",1)
    玩家数据[id].角色:添加经验(等级*600,"水陆大会翼虎将军经验",1)
    local 奖励参数=取随机数()
    if 奖励参数<=15 then
      local 名称="金银锦盒"
      玩家数据[id].道具:给予道具(id,名称,1)
      常规提示(id,"#Y/你获得了"..名称)
      广播消息({内容=format("#S(副本-水陆大会)#R/%s#Y在水陆大会上表现卓越，最终战胜了#R%s#Y，因此获得了唐王赠送的#G/%s".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,任务数据[self.任务id].名称,名称),频道="xt"})
    elseif 奖励参数<=30 then
      local 名称="九转金丹"
      玩家数据[id].道具:给予道具(id,名称,1,50)
      常规提示(id,"#Y/你获得了"..名称)
      广播消息({内容=format("#S(副本-水陆大会)#R/%s#Y在水陆大会上表现卓越，最终战胜了#R%s#Y，因此获得了唐王赠送的#G/%s".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,任务数据[self.任务id].名称,名称),频道="xt"})
    elseif 奖励参数<=40 then
      local 名称="修炼果"
      玩家数据[id].道具:给予道具(id,名称,2)
      常规提示(id,"#Y/你获得了"..名称)
      广播消息({内容=format("#S(副本-水陆大会)#R/%s#Y在水陆大会上表现卓越，最终战胜了#R%s#Y，因此获得了唐王奖励的#G/%s*2#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,任务数据[self.任务id].名称,名称),频道="xt"})
    elseif 奖励参数<=60 then
      local 名称=取宝石()
      玩家数据[id].道具:给予道具(id,名称,取随机数(2,3))
      常规提示(id,"#Y/你获得了"..名称)
      广播消息({内容=format("#S(副本-水陆大会)#R/%s#Y在水陆大会上表现卓越，最终战胜了#R%s#Y，因此获得了唐王赠送的#G/%s".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,任务数据[self.任务id].名称,名称),频道="xt"})
    elseif 奖励参数<=70 then
      local 名称="初级神魂丹"
      玩家数据[id].道具:给予道具(id,名称,1)
      常规提示(id,"#Y/你获得了"..名称)
      广播消息({内容=format("#S(副本-水陆大会)#R/%s#Y在水陆大会上表现卓越，最终战胜了#R%s#Y，因此获得了唐王赠送的#G/%s".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,任务数据[self.任务id].名称,名称),频道="xt"})
    else
      local 名称=取强化石()
      玩家数据[id].道具:给予道具(id,名称,10)
      常规提示(id,"#Y/你获得了"..名称)
      广播消息({内容=format("#S(副本-水陆大会)#R/%s#Y在#R水陆大会#Y副本中表现卓越，最终战胜了#R%s，#Y因此获得了唐王奖励的#G/%s*10#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,任务数据[self.任务id].名称,名称),频道="xt"})
    end
  elseif self.战斗类型==100117 then
    local 等级=玩家数据[id].角色.数据.等级
    玩家数据[id].角色:添加银子(等级*300,"水陆大会蝰蛇将军银子",1)
    玩家数据[id].角色:添加经验(等级*600,"水陆大会蝰蛇将军经验",1)
    local 奖励参数=取随机数()
    if 奖励参数<=15 then
      local 名称="金银锦盒"
      玩家数据[id].道具:给予道具(id,名称,1)
      常规提示(id,"#Y/你获得了"..名称)
      广播消息({内容=format("#S(副本-水陆大会)#R/%s#Y在水陆大会上表现卓越，最终战胜了#R%s#Y，因此获得了唐王赠送的#G/%s".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,任务数据[self.任务id].名称,名称),频道="xt"})
    elseif 奖励参数<=30 then
      local 名称="九转金丹"
      玩家数据[id].道具:给予道具(id,名称,1,50)
      常规提示(id,"#Y/你获得了"..名称)
      广播消息({内容=format("#S(副本-水陆大会)#R/%s#Y在水陆大会上表现卓越，最终战胜了#R%s#Y，因此获得了唐王赠送的#G/%s".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,任务数据[self.任务id].名称,名称),频道="xt"})
    elseif 奖励参数<=40 then
      local 名称="修炼果"
      玩家数据[id].道具:给予道具(id,名称,2)
      常规提示(id,"#Y/你获得了"..名称)
      广播消息({内容=format("#S(副本-水陆大会)#R/%s#Y在水陆大会上表现卓越，最终战胜了#R%s#Y，因此获得了唐王奖励的#G/%s*2#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,任务数据[self.任务id].名称,名称),频道="xt"})
    elseif 奖励参数<=60 then
      local 名称=取宝石()
      玩家数据[id].道具:给予道具(id,名称,取随机数(2,3))
      常规提示(id,"#Y/你获得了"..名称)
      广播消息({内容=format("#S(副本-水陆大会)#R/%s#Y在水陆大会上表现卓越，最终战胜了#R%s#Y，因此获得了唐王赠送的#G/%s".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,任务数据[self.任务id].名称,名称),频道="xt"})
    elseif 奖励参数<=70 then
      local 名称="初级神魂丹"
      玩家数据[id].道具:给予道具(id,名称,1)
      常规提示(id,"#Y/你获得了"..名称)
      广播消息({内容=format("#S(副本-水陆大会)#R/%s#Y在水陆大会上表现卓越，最终战胜了#R%s#Y，因此获得了唐王赠送的#G/%s".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,任务数据[self.任务id].名称,名称),频道="xt"})
    else
      local 名称=取强化石()
      玩家数据[id].道具:给予道具(id,名称,10)
      常规提示(id,"#Y/你获得了"..名称)
      广播消息({内容=format("#S(副本-水陆大会)#R/%s#Y在#R水陆大会#Y副本中表现卓越，最终战胜了#R%s，#Y因此获得了唐王奖励的#G/%s*10#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,任务数据[self.任务id].名称,名称),频道="xt"})
    end
  elseif self.战斗类型==100118 then
    local 等级=玩家数据[id].角色.数据.等级
    if 任务数据[self.任务id].名称=="巡山小妖" then
      玩家数据[id].角色:添加银子(等级*200,"水陆大会巡山小妖银子",1)
      玩家数据[id].角色:添加经验(等级*500,"水陆大会巡山小妖经验",1)
      local 奖励参数=取随机数()
      if 奖励参数<=15 then
        local 名称="金银锦盒"
        玩家数据[id].道具:给予道具(id,名称,1)
        常规提示(id,"#Y/你获得了"..名称)
        广播消息({内容=format("#S(副本-水陆大会)#R/%s#Y在水陆大会上表现卓越，最终战胜了#R%s#Y，因此获得了唐王赠送的#G/%s".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,任务数据[self.任务id].名称,名称),频道="xt"})
      elseif 奖励参数<=30 then
        local 名称="九转金丹"
        玩家数据[id].道具:给予道具(id,名称,1,50)
        常规提示(id,"#Y/你获得了"..名称)
        广播消息({内容=format("#S(副本-水陆大会)#R/%s#Y在水陆大会上表现卓越，最终战胜了#R%s#Y，因此获得了唐王赠送的#G/%s".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,任务数据[self.任务id].名称,名称),频道="xt"})
      elseif 奖励参数<=40 then
        local 名称="修炼果"
        玩家数据[id].道具:给予道具(id,名称,2)
        常规提示(id,"#Y/你获得了"..名称)
        广播消息({内容=format("#S(副本-水陆大会)#R/%s#Y在水陆大会上表现卓越，最终战胜了#R%s#Y，因此获得了唐王奖励的#G/%s*2#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,任务数据[self.任务id].名称,名称),频道="xt"})
      elseif 奖励参数<=60 then
        local 名称=取宝石()
        玩家数据[id].道具:给予道具(id,名称,取随机数(2,3))
        常规提示(id,"#Y/你获得了"..名称)
        广播消息({内容=format("#S(副本-水陆大会)#R/%s#Y在水陆大会上表现卓越，最终战胜了#R%s#Y，因此获得了唐王赠送的#G/%s".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,任务数据[self.任务id].名称,名称),频道="xt"})
      elseif 奖励参数<=70 then
        local 名称="初级神魂丹"
        玩家数据[id].道具:给予道具(id,名称,1)
        常规提示(id,"#Y/你获得了"..名称)
        广播消息({内容=format("#S(副本-水陆大会)#R/%s#Y在水陆大会上表现卓越，最终战胜了#R%s#Y，因此获得了唐王赠送的#G/%s".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,任务数据[self.任务id].名称,名称),频道="xt"})
      else
        local 名称=取强化石()
        玩家数据[id].道具:给予道具(id,名称,10)
        常规提示(id,"#Y/你获得了"..名称)
        广播消息({内容=format("#S(副本-水陆大会)#R/%s#Y在#R水陆大会#Y副本中表现卓越，最终战胜了#R%s，#Y因此获得了唐王奖励的#G/%s*10#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,任务数据[self.任务id].名称,名称),频道="xt"})
      end
    elseif 任务数据[self.任务id].名称=="上古妖兽头领" then
      玩家数据[id].角色:添加银子(等级*300,"水陆大会上古妖兽头领银子",1)
      玩家数据[id].角色:添加经验(等级*1000,"水陆大会上古妖兽头领经验",1)
      local 奖励参数 = 取随机数()
      if 奖励参数<=15 then
        local 名称="高级魔兽要诀"
        玩家数据[id].道具:给予道具(id,名称)
        常规提示(id,"#Y/你获得了"..名称)
        广播消息({内容=format("#S(副本-水陆大会)#R/%s#Y在水陆大会上表现卓越，最终战胜了#R%s#Y，因此获得了唐王赠送的#G/%s".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,任务数据[self.任务id].名称,名称),频道="xt"})
      elseif 奖励参数<=30 then
        local 名称="九转金丹"
        玩家数据[id].道具:给予道具(id,名称,1,50)
        常规提示(id,"#Y/你获得了"..名称)
        广播消息({内容=format("#S(副本-水陆大会)#R/%s#Y在水陆大会上表现卓越，最终战胜了#R%s#Y，因此获得了唐王赠送的#G/%s".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,任务数据[self.任务id].名称,名称),频道="xt"})
      elseif 奖励参数<=40 then
        local 名称="修炼果"
        玩家数据[id].道具:给予道具(id,名称,2)
        常规提示(id,"#Y/你获得了"..名称)
        广播消息({内容=format("#S(副本-水陆大会)#R/%s#Y在水陆大会上表现卓越，最终战胜了#R%s#Y，因此获得了唐王奖励的#G/%s*2#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,任务数据[self.任务id].名称,名称),频道="xt"})
      elseif 奖励参数<=60 then
        local 名称=取宝石()
        玩家数据[id].道具:给予道具(id,名称,取随机数(2,4))
        常规提示(id,"#Y/你获得了"..名称)
        广播消息({内容=format("#S(副本-水陆大会)#R/%s#Y在水陆大会上表现卓越，最终战胜了#R%s#Y，因此获得了唐王赠送的#G/%s".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,任务数据[self.任务id].名称,名称),频道="xt"})
      elseif 奖励参数<=70 then
        local 名称="初级神魂丹"
        玩家数据[id].道具:给予道具(id,名称,1)
        常规提示(id,"#Y/你获得了"..名称)
        广播消息({内容=format("#S(副本-水陆大会)#R/%s#Y在水陆大会上表现卓越，最终战胜了#R%s#Y，因此获得了唐王赠送的#G/%s".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,任务数据[self.任务id].名称,名称),频道="xt"})
      elseif 奖励参数<=90 then
        local 名称="金银锦盒"
        玩家数据[id].道具:给予道具(id,名称,1)
        常规提示(id,"#Y/你获得了"..名称)
        广播消息({内容=format("#S(副本-水陆大会)#R/%s#Y在水陆大会上表现卓越，最终战胜了#R%s#Y，因此获得了唐王赠送的#G/%s".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,任务数据[self.任务id].名称,名称),频道="xt"})
      else
        local 名称=取强化石()
        玩家数据[id].道具:给予道具(id,名称,10)
        常规提示(id,"#Y/你获得了"..名称)
        广播消息({内容=format("#S(副本-水陆大会)#R/%s#Y在#R水陆大会#Y副本中表现卓越，最终战胜了#R%s，#Y因此获得了唐王奖励的#G/%s*10#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,任务数据[self.任务id].名称,名称),频道="xt"})
      end
    elseif 任务数据[self.任务id].名称=="妖将军" then
      玩家数据[id].角色:添加银子(等级*400,"水陆大会妖将军银子",1)
      玩家数据[id].角色:添加经验(等级*1500,"水陆大会妖将军经验",1)
      local 奖励参数 = 取随机数()
      if 奖励参数<=15 then
        local 名称="高级魔兽要诀"
        玩家数据[id].道具:给予道具(id,名称)
        常规提示(id,"#Y/你获得了"..名称)
        广播消息({内容=format("#S(副本-水陆大会)#R/%s#Y在水陆大会上表现卓越，最终战胜了#R%s#Y，因此获得了唐王赠送的#G/%s".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,任务数据[self.任务id].名称,名称),频道="xt"})
      elseif 奖励参数<=30 then
        local 名称="九转金丹"
        玩家数据[id].道具:给予道具(id,名称,1,50)
        常规提示(id,"#Y/你获得了"..名称)
        广播消息({内容=format("#S(副本-水陆大会)#R/%s#Y在水陆大会上表现卓越，最终战胜了#R%s#Y，因此获得了唐王赠送的#G/%s".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,任务数据[self.任务id].名称,名称),频道="xt"})
      elseif 奖励参数<=40 then
        local 名称="修炼果"
        玩家数据[id].道具:给予道具(id,名称,2)
        常规提示(id,"#Y/你获得了"..名称)
        广播消息({内容=format("#S(副本-水陆大会)#R/%s#Y在水陆大会上表现卓越，最终战胜了#R%s#Y，因此获得了唐王奖励的#G/%s*2#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,任务数据[self.任务id].名称,名称),频道="xt"})
      elseif 奖励参数<=60 then
        local 名称=取宝石()
        玩家数据[id].道具:给予道具(id,名称,取随机数(2,4))
        常规提示(id,"#Y/你获得了"..名称)
        广播消息({内容=format("#S(副本-水陆大会)#R/%s#Y在水陆大会上表现卓越，最终战胜了#R%s#Y，因此获得了唐王赠送的#G/%s".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,任务数据[self.任务id].名称,名称),频道="xt"})
      elseif 奖励参数<=70 then
        local 名称="初级神魂丹"
        玩家数据[id].道具:给予道具(id,名称,1)
        常规提示(id,"#Y/你获得了"..名称)
        广播消息({内容=format("#S(副本-水陆大会)#R/%s#Y在水陆大会上表现卓越，最终战胜了#R%s#Y，因此获得了唐王赠送的#G/%s".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,任务数据[self.任务id].名称,名称),频道="xt"})
      elseif 奖励参数<=90 then
        local 名称="金银锦盒"
        玩家数据[id].道具:给予道具(id,名称,1)
        常规提示(id,"#Y/你获得了"..名称)
        广播消息({内容=format("#S(副本-水陆大会)#R/%s#Y在水陆大会上表现卓越，最终战胜了#R%s#Y，因此获得了唐王赠送的#G/%s".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,任务数据[self.任务id].名称,名称),频道="xt"})
      else
        local 名称=取强化石()
        玩家数据[id].道具:给予道具(id,名称,10)
        常规提示(id,"#Y/你获得了"..名称)
        广播消息({内容=format("#S(副本-水陆大会)#R/%s#Y在#R水陆大会#Y副本中表现卓越，最终战胜了#R%s，#Y因此获得了唐王奖励的#G/%s*10#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,任务数据[self.任务id].名称,名称),频道="xt"})
      end
    else
      玩家数据[id].角色:添加银子(等级*500+100000,"水陆大会魑魅魍魉银子",1)
      玩家数据[id].角色:添加经验(等级*3000,"水陆大会魑魅魍魉经验",1)
      local 奖励参数=取随机数()
      if 奖励参数<=15 then
        local 名称="高级魔兽要诀"
        玩家数据[id].道具:给予道具(id,名称)
        常规提示(id,"#Y/你获得了"..名称)
        广播消息({内容=format("#S(副本-水陆大会)#R/%s#Y在#R水陆大会#Y副本中表现卓越，因此获得了三清奖励的#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,名称),频道="xt"})
      elseif 奖励参数<=30 then
        local 名称="九转金丹"
        玩家数据[id].道具:给予道具(id,名称,1,50)
        常规提示(id,"#Y/你获得了"..名称)
        广播消息({内容=format("#S(副本-水陆大会)#R/%s#Y在水陆大会上表现卓越，最终战胜了#R%s#Y，因此获得了唐王赠送的#G/%s".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,任务数据[self.任务id].名称,名称),频道="xt"})
      elseif 奖励参数<=40 then
        local 名称="修炼果"
        玩家数据[id].道具:给予道具(id,名称,2)
        常规提示(id,"#Y/你获得了"..名称)
        广播消息({内容=format("#S(副本-水陆大会)#R/%s#Y在水陆大会上表现卓越，最终战胜了#R%s#Y，因此获得了唐王奖励的#G/%s*2#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,任务数据[self.任务id].名称,名称),频道="xt"})
      elseif 奖励参数<=60 then
        local 名称=取宝石()
        玩家数据[id].道具:给予道具(id,名称,取随机数(2,5))
        常规提示(id,"#Y/你获得了"..名称)
        广播消息({内容=format("#S(副本-水陆大会)#R/%s#Y在水陆大会上表现卓越，最终战胜了#R%s#Y，因此获得了唐王赠送的#G/%s".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,任务数据[self.任务id].名称,名称),频道="xt"})
      elseif 奖励参数<=70 then
        local 名称="初级神魂丹"
        玩家数据[id].道具:给予道具(id,名称,1)
        常规提示(id,"#Y/你获得了"..名称)
        广播消息({内容=format("#S(副本-水陆大会)#R/%s#Y在水陆大会上表现卓越，最终战胜了#R%s#Y，因此获得了唐王赠送的#G/%s".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,任务数据[self.任务id].名称,名称),频道="xt"})
      elseif 奖励参数<=71 then
        local 名称="高级魔兽要诀"
        local 技能=取特殊要诀()
        玩家数据[id].道具:给予道具(id,名称,nil,技能)
        常规提示(id,"#Y/你获得了"..名称)
        广播消息({内容=format("#S(副本-水陆大会)#R/%s#Y在水陆大会上表现卓越，最终战胜了#R%s#Y，因此获得了唐王赠送的#G/%s".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,任务数据[self.任务id].名称,名称),频道="xt"})
      elseif 奖励参数<=90 then
        local 名称="金银锦盒"
        玩家数据[id].道具:给予道具(id,名称,1)
        常规提示(id,"#Y/你获得了"..名称)
        广播消息({内容=format("#S(副本-水陆大会)#R/%s#Y在水陆大会上表现卓越，最终战胜了#R%s#Y，因此获得了唐王赠送的#G/%s".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,任务数据[self.任务id].名称,名称),频道="xt"})
      else
        local 名称=取强化石()
        玩家数据[id].道具:给予道具(id,名称,10)
        常规提示(id,"#Y/你获得了"..名称)
        广播消息({内容=format("#S(副本-水陆大会)#R/%s#Y在#R水陆大会#Y副本中表现卓越，最终战胜了#R%s，#Y因此获得了唐王奖励的#G/%s*10#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,任务数据[self.任务id].名称,名称),频道="xt"})
      end
    end
  elseif self.战斗类型==100119 then
    local 等级=玩家数据[id].角色.数据.等级
    玩家数据[id].角色:添加银子(等级*200,"水陆大会毒虫银子",1)
    玩家数据[id].角色:添加经验(等级*500,"水陆大会毒虫经验",1)
    地图处理类:删除单位(任务数据[self.任务id].地图编号,任务数据[self.任务id].单位编号)
    local 奖励参数=取随机数()
    if 奖励参数<=30 then
      local 名称=取宝石()
      玩家数据[id].道具:给予道具(id,名称,取随机数(1,5))
      常规提示(id,"#Y/你获得了#R/"..名称)
      广播消息({内容=format("#S(副本-水陆大会)#R/%s#Y在水陆大会上表现卓越，最终战胜了#R%s#Y，因此获得了唐王赠送的#G/%s".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,任务数据[self.任务id].名称,名称),频道="xt"})
    elseif 奖励参数<=60 then
      local 名称="怪物卡片"
      玩家数据[id].道具:给予道具(id,名称,取随机数(1,8))
      常规提示(id,"#Y/你获得了#R/"..名称)
      广播消息({内容=format("#S(副本-水陆大会)#R/%s#Y在水陆大会上表现卓越，最终战胜了#R%s#Y，因此获得了唐王赠送的#G/%s".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,任务数据[self.任务id].名称,名称),频道="xt"})
    else
      local 随机等级={100,110,120,130,140,150}
      local 珍珠等级=随机等级[取随机数(1,#随机等级)]
      local 名称="珍珠"
      玩家数据[id].道具:给予道具(id,名称,珍珠等级)
      常规提示(id,"#Y/你获得了#R/"..珍珠等级.."级珍珠")
      广播消息({内容=format("#S(副本-水陆大会)#R/%s#Y在水陆大会上表现卓越，最终战胜了#R%s#Y，因此获得了唐王赠送的#G/%s".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,任务数据[self.任务id].名称,珍珠等级.."级珍珠"),频道="xt"})
    end
  elseif self.战斗类型==100120 then
    local 主任务id = 任务数据[self.任务id].主任务
    if 任务数据[主任务id] ~= nil then
      if 任务数据[主任务id].阶段<=3 then
        任务数据[主任务id].成功操作 = 任务数据[主任务id].成功操作 + 1
      elseif 任务数据[主任务id].阶段 == 4 then
        任务数据[主任务id].次数 = 任务数据[主任务id].次数 + 1
      end
      任务数据[主任务id].刷出强盗 = nil
    end
    地图处理类:删除单位(任务数据[self.任务id].地图编号,任务数据[self.任务id].单位编号)
    玩家数据[id].角色:取消任务(self.任务id)
  end
end

function 战斗处理类:失败处理(失败id,是否逃跑,胜利id)
  if 失败id==0 then return  end
  local id组={}
  self.战斗失败=true
  for n=1,#self.参战玩家 do
      if self.参战玩家[n].队伍==失败id and 玩家数据[self.参战玩家[n].id]~=nil then
          if 是否逃跑==nil  and self.战斗类型~=200003 and self.战斗类型~=200004 and self.战斗类型~=200005 and self.战斗类型~=200006 and self.战斗类型~=100061 and self.战斗类型~=100062 and self.战斗类型~=100114 and self.战斗类型~=100115 and self.战斗类型~=100159 then
            if self.战斗类型 == 200008 then
              self:扣经验(self.参战玩家[n].id,0.25)
              self:扣银子(self.参战玩家[n].id,0.22)
            else
              self:扣经验(self.参战玩家[n].id,0.085)
              self:扣银子(self.参战玩家[n].id,0.075)
            end
          end
          id组[#id组+1]=self.参战玩家[n].id
      end
  end
  for i=1,#id组 do
    if 玩家数据[id组[i]]~=nil then
      if self.战斗类型==100006 then--科举
        游戏活动类:科举回答题目(玩家数据[self.进入战斗玩家id].连接id,self.进入战斗玩家id,答案,5)
        if 是否逃跑==nil then
          self:死亡对话(id组[i])
        end
      elseif self.战斗类型==100017 or self.战斗类型==100016  then
        地图处理类:删除单位(任务数据[self.任务id].地图编号,任务数据[self.任务id].单位编号)
        常规提示(self.进入战斗玩家id,"#Y/你的师门任务失败了")
        玩家数据[self.进入战斗玩家id].角色:取消任务(self.任务id)
        任务数据[self.任务id]=nil
        玩家数据[self.进入战斗玩家id].角色.数据.师门次数=0
        if 是否逃跑==nil then
          self:死亡对话(id组[i])
        end
      elseif self.战斗类型==100114 or self.战斗类型==100115 then
        常规提示(id组[i],"#Y/想要击败我必须找到观音的法宝，哈哈")
        local 副本id=任务数据[玩家数据[self.进入战斗玩家id].角色:取任务(150)].副本id
        if self.战斗类型==100114 then
          副本数据.水陆大会.进行[副本id].翼虎=true
          任务数据[self.任务id].战斗=nil
        else
          副本数据.水陆大会.进行[副本id].蝰蛇=true
          任务数据[self.任务id].战斗=nil
        end
        if 副本数据.水陆大会.进行[副本id].翼虎 and 副本数据.水陆大会.进行[副本id].蝰蛇 then
          副本数据.水陆大会.进行[副本id].进程=5
          任务处理类:设置水陆大会副本(副本id)
          玩家数据[self.进入战斗玩家id].角色:刷新任务跟踪()
        end
      elseif self.战斗类型==100159 then
        if 玩家数据[self.进入战斗玩家id].队伍~=0 then
          发送数据(玩家数据[失败id].连接id,1501,{名称="卷帘大将",模型="沙僧",对话="哈哈，现在的我多逍遥快活，何须回那狗屁天庭",选项={"糟糕，卷帘大将的心魔肆虐，得想办法制服心魔，袁天罡善于推算天机，去找他看看"}})
          剧情数据[玩家数据[self.进入战斗玩家id].队伍].大战心魔.进程=剧情数据[玩家数据[self.进入战斗玩家id].队伍].大战心魔.进程+1
          玩家数据[玩家数据[self.进入战斗玩家id].队伍].角色:刷新任务跟踪()
        else
          发送数据(玩家数据[失败id].连接id,1501,{名称="卷帘大将",模型="沙僧",对话="哈哈，现在的我多逍遥快活，何须回那狗屁天庭",选项={"糟糕，卷帘大将的心魔肆虐，得想办法制服心魔，袁天罡善于推算天机，去找他看看"}})
          剧情数据[失败id].大战心魔.进程=剧情数据[失败id].大战心魔.进程+1
          玩家数据[失败id].角色:刷新任务跟踪()
        end
      elseif self.战斗类型==100018  then--门派乾坤袋
        local xy=地图处理类.地图坐标[任务数据[self.任务id].地图编号]:取随机点()
        任务数据[self.任务id].x,任务数据[self.任务id].y=xy.x,xy.y
        玩家数据[self.进入战斗玩家id].角色:刷新任务跟踪()
        地图处理类:添加单位(self.任务id)
        if 是否逃跑==nil then
          self:死亡对话(id组[i])
        end
      elseif  self.战斗类型==100001 or self.战斗类型==100007 then--野外野怪死亡
        if 玩家数据[self.进入战斗玩家id].角色.数据.等级~=nil and 玩家数据[self.进入战斗玩家id].角色.数据.等级>10 then
          if 是否逃跑==nil then
            self:死亡对话(id组[i])
          end
        end
      elseif self.战斗类型~=100007 and self.战斗类型~=100001 and self.战斗类型~=200003 and self.战斗类型~=200004 and self.战斗类型~=200005 and self.战斗类型~=200006 and self.战斗类型~=100061 and self.战斗类型~=100062 and self.战斗类型>=100002 or self.战斗类型<=100010 then--前面活动
          if 是否逃跑==nil then
            self:死亡对话(id组[i])
          end
          if self.战斗类型 == 100027 then
            广播消息({内容=format("#R听说#G%s#R在挑战知了王时,被打的鼻青脸肿,连他妈都不认识了#24",玩家数据[id组[i]].角色.数据.名称),频道="cw"})
          elseif self.战斗类型 == 100037 then
            广播消息({内容=format("#R听说#G%s#R在挑战地煞星时,被打的抱头鼠窜,一时成为了三界笑谈#24",玩家数据[id组[i]].角色.数据.名称),频道="cw"})
          elseif self.战斗类型 == 200007 then
            local 胜利队长
            for n=1,#self.参战玩家 do
              if self.参战玩家[n].队伍==胜利id and 玩家数据[self.参战玩家[n].id]~=nil and (玩家数据[self.参战玩家[n].id].队长 or 玩家数据[self.参战玩家[n].id].队伍 == 0) then
                胜利队长 = self.参战玩家[n].id
              end
            end
            if 胜利队长 ~= nil and 玩家数据[胜利队长] ~= nil then
              广播消息({内容=format("#Y听说#G%s#Y在与#R%s#Ypk时,被打的头破血流,从此夹着尾巴做人！#24",玩家数据[id组[i]].角色.数据.名称,玩家数据[胜利队长].角色.数据.名称),频道="cw"})
            end
          elseif self.战斗类型 == 200008 then
            local 胜利队长
            for n=1,#self.参战玩家 do
              if self.参战玩家[n].队伍==胜利id and 玩家数据[self.参战玩家[n].id]~=nil and (玩家数据[self.参战玩家[n].id].队长 or 玩家数据[self.参战玩家[n].id].队伍 == 0) then
                胜利队长 = self.参战玩家[n].id
              end
            end
            if 玩家数据[id组[i]].角色.数据.强P开关 ~= nil then
              玩家数据[id组[i]].角色.数据.强P开关 = nil
              发送数据(玩家数据[id组[i]].连接id,94)
              地图处理类:更改强PK(id组[i])
              if 玩家数据[id组[i]].角色.数据.PK开关 ~= nil then
                发送数据(玩家数据[id组[i]].连接id,93,{开关=true})
                地图处理类:更改PK(id组[i],true)
              end
            end
            if 胜利队长 ~= nil and 玩家数据[胜利队长] ~= nil and (玩家数据[id组[i]].队伍 == 0 or 玩家数据[id组[i]].队长)  then
              广播消息({内容=format("#Y听说#G%s#Y被#R%s#Y强行XXXXX,从此结下了血海深仇！#24",玩家数据[id组[i]].角色.数据.名称,玩家数据[胜利队长].角色.数据.名称),频道="cw"})
            end
          end
      elseif self.战斗类型==200006 then
        if 玩家数据[id组[i]].队长 and 玩家数据[id组[i]].角色.数据.帮战夺旗~=nil and 玩家数据[id组[i]].角色.数据.帮战夺旗~=0 then
          玩家数据[id组[i]].角色.数据.帮战夺旗=nil
          帮派数据[玩家数据[id组[i]].角色.数据.编号].帮战夺旗次数=帮派数据[玩家数据[id组[i]].角色.数据.编号].帮战夺旗次数-1
        end
      end
    end
  end
  if self.任务id==nil or 任务数据[self.任务id]==nil then return  end
  任务数据[self.任务id].战斗=nil
end

function 战斗处理类:死亡对话(id)
  玩家数据[id].战斗=0
  if 玩家数据[id].队长 then

  else
    队伍处理类:退出队伍(id)
  end
  local wb={}
  wb[1] = "生死有命,请珍惜生命？"
  local xx = {}
  self.临时数据={"白无常","白无常",wb[取随机数(1,#wb)],xx}
  self.发送数据={}
  self.发送数据.模型=self.临时数据[1]
  self.发送数据.名称=self.临时数据[2]
  self.发送数据.对话=self.临时数据[3]
  self.发送数据.选项=self.临时数据[4]
  发送数据(玩家数据[id].连接id,1501,self.发送数据)
  地图处理类:跳转地图(id,1125,24,27)
end

function 战斗处理类:扣经验(失败id,倍率)
  if 倍率~=nil then
    self.扣除经验 = math.floor(玩家数据[失败id].角色.数据.当前经验 * 倍率)
  else
    self.扣除经验 = math.floor(玩家数据[失败id].角色.数据.当前经验 * 0.08)
  end
  if 玩家数据[失败id].角色.数据.当前经验>=self.扣除经验 then
    玩家数据[失败id].角色.数据.当前经验=玩家数据[失败id].角色.数据.当前经验-self.扣除经验
    发送数据(玩家数据[失败id].连接id,38,{内容="#Y/你因为死亡损失了" .. self.扣除经验 .. "点经验",频道="xt"})
    常规提示(失败id,"#Y/你因为死亡损失了" .. self.扣除经验 .. "点经验")
  end
end

function 战斗处理类:扣银子(失败id,倍率)
  if 倍率~=nil then
    self.扣除银子 = math.floor(玩家数据[失败id].角色.数据.银子 * 倍率)
  else
    self.扣除银子 = math.floor(玩家数据[失败id].角色.数据.银子 * 0.08)
  end
  if 玩家数据[失败id].角色.数据.银子>=self.扣除银子 then
    玩家数据[失败id].角色.数据.银子=玩家数据[失败id].角色.数据.银子-self.扣除银子
    发送数据(玩家数据[失败id].连接id,38,{内容="#Y/你因为死亡损失了" .. self.扣除银子 .. "两银子",频道="xt"})
    常规提示(失败id,"#Y/你因为死亡损失了" .. self.扣除银子 .. "两银子")
  end
end

function 战斗处理类:还原指定单位属性(id)
 for n=1,#self.参战单位 do
    if self.参战单位[n].气血<0 then self.参战单位[n].气血=0 end
    if self.参战单位[n].魔法<0 then self.参战单位[n].魔法=0 end
      if self.参战单位[n].队伍~=0 and self.参战单位[n].玩家id==id then
          if self.参战单位[n].类型=="角色" then
              if self.参战单位[n].气血<=0 then
                  玩家数据[self.参战单位[n].玩家id].角色:死亡处理()
                  玩家数据[self.参战单位[n].玩家id].角色:刷新信息("1")
                else
                 玩家数据[self.参战单位[n].玩家id].角色:刷新信息()
                 玩家数据[self.参战单位[n].玩家id].角色.数据.气血= self.参战单位[n].气血
                 玩家数据[self.参战单位[n].玩家id].角色.数据.魔法= self.参战单位[n].魔法
                 玩家数据[self.参战单位[n].玩家id].角色.数据.愤怒= self.参战单位[n].愤怒
                 end
              发送数据(玩家数据[self.参战单位[n].玩家id].连接id,33,玩家数据[self.参战单位[n].玩家id].角色:取总数据())
            else
              if self.参战单位[n].是否孩子 == nil then
                if self.参战单位[n].气血<=0 then
                  玩家数据[self.参战单位[n].玩家id].召唤兽:死亡处理(self.参战单位[n].认证码)
                  玩家数据[self.参战单位[n].玩家id].召唤兽:刷新信息1(self.参战单位[n].认证码,"1")
                else
                  玩家数据[self.参战单位[n].玩家id].召唤兽:刷新信息1(self.参战单位[n].认证码)
                  玩家数据[self.参战单位[n].玩家id].角色.数据.参战宝宝.气血= self.参战单位[n].气血
                  玩家数据[self.参战单位[n].玩家id].角色.数据.参战宝宝.魔法= self.参战单位[n].魔法
                end
              else
                玩家数据[self.参战单位[n].玩家id].孩子:刷新信息1(self.参战单位[n].认证码,"1")
              end
            end
         end
   end
end

function 战斗处理类:还原单位属性()
 for n=1,#self.参战单位 do
    if self.参战单位[n].气血<0 then self.参战单位[n].气血=0 end
    if self.参战单位[n].魔法<0 then self.参战单位[n].魔法=0 end
      if self.参战单位[n]~=nil and self.参战单位[n].队伍~=0 and self.参战单位[n].逃跑==nil and self.参战单位[n].系统队友==nil and 玩家数据[self.参战单位[n].玩家id]~=nil then
          if self.参战单位[n].类型=="角色" and self.参战单位[n].助战编号 == nil then
            if self.参战单位[n].气血<=0 then
              玩家数据[self.参战单位[n].玩家id].角色:死亡处理()
              玩家数据[self.参战单位[n].玩家id].角色:刷新信息("1")
            else
              玩家数据[self.参战单位[n].玩家id].角色.数据.气血= self.参战单位[n].气血
              玩家数据[self.参战单位[n].玩家id].角色.数据.魔法= self.参战单位[n].魔法
              玩家数据[self.参战单位[n].玩家id].角色.数据.愤怒= self.参战单位[n].愤怒
              玩家数据[self.参战单位[n].玩家id].角色:刷新信息()
            end
            if 玩家数据[self.参战单位[n].玩家id].角色:取任务(10)~=0 and self.战斗类型 ~= 100050 and self.战斗类型 ~= 100051 and self.战斗类型 ~= 100052 and self.战斗类型 ~= 100053 and self.战斗类型 ~= 100130 and self.战斗类型 ~= 100131 and self.战斗类型 ~= 100132 and self.战斗类型 ~= 100133 then
              local 恢复id=玩家数据[self.参战单位[n].玩家id].角色:取任务(10)
              if 玩家数据[self.参战单位[n].玩家id].角色.数据.气血<玩家数据[self.参战单位[n].玩家id].角色.数据.最大气血 then
                if 任务数据[恢复id].气血>0 then
                  if 任务数据[恢复id].气血>玩家数据[self.参战单位[n].玩家id].角色.数据.最大气血-玩家数据[self.参战单位[n].玩家id].角色.数据.气血 then
                    任务数据[恢复id].气血=任务数据[恢复id].气血-(玩家数据[self.参战单位[n].玩家id].角色.数据.最大气血-玩家数据[self.参战单位[n].玩家id].角色.数据.气血)
                    玩家数据[self.参战单位[n].玩家id].角色.数据.气血=玩家数据[self.参战单位[n].玩家id].角色.数据.最大气血
                  else
                    玩家数据[self.参战单位[n].玩家id].角色.数据.气血=玩家数据[self.参战单位[n].玩家id].角色.数据.气血+任务数据[恢复id].气血
                    任务数据[恢复id].气血=0
                  end
                  if 任务数据[恢复id].气血==0  and  任务数据[恢复id].魔法==0 then
                    玩家数据[self.参战单位[n].玩家id].角色:取消任务(恢复id)
                  end
                  玩家数据[self.参战单位[n].玩家id].角色:刷新任务跟踪()
                end
              end
              if 玩家数据[self.参战单位[n].玩家id].角色.数据.魔法<玩家数据[self.参战单位[n].玩家id].角色.数据.最大魔法 then
                if 任务数据[恢复id].魔法>0 then
                  if 任务数据[恢复id].魔法>玩家数据[self.参战单位[n].玩家id].角色.数据.最大魔法-玩家数据[self.参战单位[n].玩家id].角色.数据.魔法 then
                    任务数据[恢复id].魔法=任务数据[恢复id].魔法-(玩家数据[self.参战单位[n].玩家id].角色.数据.最大魔法-玩家数据[self.参战单位[n].玩家id].角色.数据.魔法)
                    玩家数据[self.参战单位[n].玩家id].角色.数据.魔法=玩家数据[self.参战单位[n].玩家id].角色.数据.最大魔法
                  else
                    玩家数据[self.参战单位[n].玩家id].角色.数据.魔法=玩家数据[self.参战单位[n].玩家id].角色.数据.魔法+任务数据[恢复id].魔法
                    任务数据[恢复id].魔法=0
                  end
                  if 任务数据[恢复id].气血==0  and  任务数据[恢复id].魔法==0 then
                    玩家数据[self.参战单位[n].玩家id].角色:取消任务(恢复id)
                  end
                  玩家数据[self.参战单位[n].玩家id].角色:刷新任务跟踪()
                end
              end
            end
            发送数据(玩家数据[self.参战单位[n].玩家id].连接id,33,玩家数据[self.参战单位[n].玩家id].角色:取总数据())
          elseif self.参战单位[n].类型=="角色" and self.参战单位[n].助战编号 ~= nil then
            local 助战编号 = self.参战单位[n].助战编号
            if self.参战单位[n].气血<=0 then
              玩家数据[self.参战单位[n].玩家id].助战:刷新信息(助战编号,1)
            else
              玩家数据[self.参战单位[n].玩家id].助战.数据[助战编号].气血= self.参战单位[n].气血
              玩家数据[self.参战单位[n].玩家id].助战.数据[助战编号].魔法= self.参战单位[n].魔法
              玩家数据[self.参战单位[n].玩家id].助战.数据[助战编号].愤怒= self.参战单位[n].愤怒
              玩家数据[self.参战单位[n].玩家id].助战:刷新信息(助战编号)
            end
            if 玩家数据[self.参战单位[n].玩家id].角色:取任务(10)~=0 and self.战斗类型 ~= 100050 and self.战斗类型 ~= 100051 and self.战斗类型 ~= 100052 and self.战斗类型 ~= 100053 and self.战斗类型 ~= 100130 and self.战斗类型 ~= 100131 and self.战斗类型 ~= 100132 and self.战斗类型 ~= 100133 then
              local 恢复id=玩家数据[self.参战单位[n].玩家id].角色:取任务(10)
              if 玩家数据[self.参战单位[n].玩家id].助战.数据[助战编号].气血 < 玩家数据[self.参战单位[n].玩家id].助战.数据[助战编号].最大气血 then
                if 任务数据[恢复id].气血>0 then
                  if 任务数据[恢复id].气血>玩家数据[self.参战单位[n].玩家id].助战.数据[助战编号].最大气血-玩家数据[self.参战单位[n].玩家id].助战.数据[助战编号].气血 then
                    任务数据[恢复id].气血=任务数据[恢复id].气血-(玩家数据[self.参战单位[n].玩家id].助战.数据[助战编号].最大气血-玩家数据[self.参战单位[n].玩家id].助战.数据[助战编号].气血)
                    玩家数据[self.参战单位[n].玩家id].助战.数据[助战编号].气血=玩家数据[self.参战单位[n].玩家id].助战.数据[助战编号].最大气血
                  else
                    玩家数据[self.参战单位[n].玩家id].助战.数据[助战编号].气血=玩家数据[self.参战单位[n].玩家id].助战.数据[助战编号].气血+任务数据[恢复id].气血
                    任务数据[恢复id].气血=0
                  end
                  if 任务数据[恢复id].气血==0  and  任务数据[恢复id].魔法==0 then
                    玩家数据[self.参战单位[n].玩家id].角色:取消任务(恢复id)
                  end
                  玩家数据[self.参战单位[n].玩家id].角色:刷新任务跟踪()
                end
              end
              if 玩家数据[self.参战单位[n].玩家id].助战.数据[助战编号].魔法<玩家数据[self.参战单位[n].玩家id].助战.数据[助战编号].最大魔法 then
                if 任务数据[恢复id].魔法>0 then
                  if 任务数据[恢复id].魔法>玩家数据[self.参战单位[n].玩家id].助战.数据[助战编号].最大魔法-玩家数据[self.参战单位[n].玩家id].助战.数据[助战编号].魔法 then
                    任务数据[恢复id].魔法=任务数据[恢复id].魔法-(玩家数据[self.参战单位[n].玩家id].助战.数据[助战编号].最大魔法-玩家数据[self.参战单位[n].玩家id].助战.数据[助战编号].魔法)
                    玩家数据[self.参战单位[n].玩家id].助战.数据[助战编号].魔法=玩家数据[self.参战单位[n].玩家id].助战.数据[助战编号].最大魔法
                  else
                    玩家数据[self.参战单位[n].玩家id].助战.数据[助战编号].魔法=玩家数据[self.参战单位[n].玩家id].助战.数据[助战编号].魔法+任务数据[恢复id].魔法
                    任务数据[恢复id].魔法=0
                  end
                  if 任务数据[恢复id].气血==0  and  任务数据[恢复id].魔法==0 then
                    玩家数据[self.参战单位[n].玩家id].角色:取消任务(恢复id)
                  end
                  玩家数据[self.参战单位[n].玩家id].角色:刷新任务跟踪()
                end
              end
            end
            发送数据(玩家数据[self.参战单位[n].玩家id].连接id,100,{编号=助战编号,数据= 玩家数据[self.参战单位[n].玩家id].助战:取指定数据(助战编号)})
          else
              if self.参战单位[n].是否孩子 == nil then
              if self.参战单位[n].气血<=0 then
                  玩家数据[self.参战单位[n].玩家id].召唤兽:死亡处理(self.参战单位[n].认证码)
                  玩家数据[self.参战单位[n].玩家id].召唤兽:刷新信息1(self.参战单位[n].认证码,"1")
              else
                  玩家数据[self.参战单位[n].玩家id].召唤兽:刷新信息1(self.参战单位[n].认证码)
                  玩家数据[self.参战单位[n].玩家id].角色.数据.参战宝宝.气血= self.参战单位[n].气血
                  玩家数据[self.参战单位[n].玩家id].角色.数据.参战宝宝.魔法= self.参战单位[n].魔法
              end
              if 玩家数据[self.参战单位[n].玩家id].角色.数据.参战宝宝.气血 > 玩家数据[self.参战单位[n].玩家id].角色.数据.参战宝宝.最大气血 then
                玩家数据[self.参战单位[n].玩家id].角色.数据.参战宝宝.气血 = 玩家数据[self.参战单位[n].玩家id].角色.数据.参战宝宝.最大气血
              end
              if 玩家数据[self.参战单位[n].玩家id].角色:取任务(10)~=0 and self.战斗类型 ~= 100050 and self.战斗类型 ~= 100051 and self.战斗类型 ~= 100052 and self.战斗类型 ~= 100053 and self.战斗类型 ~= 100130 and self.战斗类型 ~= 100131 and self.战斗类型 ~= 100132 and self.战斗类型 ~= 100133 then
                local 恢复id=玩家数据[self.参战单位[n].玩家id].角色:取任务(10)
                if 玩家数据[self.参战单位[n].玩家id].角色.数据.参战宝宝~=nil and 玩家数据[self.参战单位[n].玩家id].角色.数据.参战宝宝.气血<玩家数据[self.参战单位[n].玩家id].角色.数据.参战宝宝.最大气血 then
                  if 任务数据[恢复id].气血>0 then
                    if 任务数据[恢复id].气血>玩家数据[self.参战单位[n].玩家id].角色.数据.参战宝宝.最大气血-玩家数据[self.参战单位[n].玩家id].角色.数据.参战宝宝.气血 then
                        任务数据[恢复id].气血=任务数据[恢复id].气血-(玩家数据[self.参战单位[n].玩家id].角色.数据.参战宝宝.最大气血-玩家数据[self.参战单位[n].玩家id].角色.数据.参战宝宝.气血)
                        玩家数据[self.参战单位[n].玩家id].角色.数据.参战宝宝.气血=玩家数据[self.参战单位[n].玩家id].角色.数据.参战宝宝.最大气血
                    else
                        玩家数据[self.参战单位[n].玩家id].角色.数据.参战宝宝.气血=玩家数据[self.参战单位[n].玩家id].角色.数据.参战宝宝.气血+任务数据[恢复id].气血
                        任务数据[恢复id].气血=0
                    end
                    if 任务数据[恢复id].气血==0  and  任务数据[恢复id].魔法==0 then
                      玩家数据[self.参战单位[n].玩家id].角色:取消任务(恢复id)
                    end
                    玩家数据[self.参战单位[n].玩家id].角色:刷新任务跟踪()
                  end
                end
                if 玩家数据[self.参战单位[n].玩家id].角色.数据.参战宝宝.魔法<玩家数据[self.参战单位[n].玩家id].角色.数据.参战宝宝.最大魔法 then
                  if 任务数据[恢复id].魔法>0 then
                    if 任务数据[恢复id].魔法>玩家数据[self.参战单位[n].玩家id].角色.数据.参战宝宝.最大魔法-玩家数据[self.参战单位[n].玩家id].角色.数据.参战宝宝.魔法 then
                      任务数据[恢复id].魔法=任务数据[恢复id].魔法-(玩家数据[self.参战单位[n].玩家id].角色.数据.参战宝宝.最大魔法-玩家数据[self.参战单位[n].玩家id].角色.数据.参战宝宝.魔法)
                      玩家数据[self.参战单位[n].玩家id].角色.数据.参战宝宝.魔法=玩家数据[self.参战单位[n].玩家id].角色.数据.参战宝宝.最大魔法
                    else
                      玩家数据[self.参战单位[n].玩家id].角色.数据.参战宝宝.魔法=玩家数据[self.参战单位[n].玩家id].角色.数据.参战宝宝.魔法+任务数据[恢复id].魔法
                      任务数据[恢复id].魔法=0
                    end
                    if 任务数据[恢复id].气血==0  and  任务数据[恢复id].魔法==0 then
                      玩家数据[self.参战单位[n].玩家id].角色:取消任务(恢复id)
                    end
                    玩家数据[self.参战单位[n].玩家id].角色:刷新任务跟踪()
                  end
                end
              end
            else
              -- if self.参战单位[n].气血<=0 then
              --   玩家数据[self.参战单位[n].玩家id].召唤兽:死亡处理(self.参战单位[n].认证码)
              -- end
              玩家数据[self.参战单位[n].玩家id].孩子:刷新信息1(self.参战单位[n].认证码,"1")
            end
            发送数据(玩家数据[self.参战单位[n].玩家id].连接id,33,玩家数据[self.参战单位[n].玩家id].角色:取总数据())
           end
        end
   end
end

function 战斗处理类:经脉回合开始处理(编号)
  if self.参战单位[编号].奇经八脉 ~= nil then
    if 编号~=nil and self:取奇经八脉是否有(编号,"花舞") then
      self.参战单位[编号].速度 = self.参战单位[编号].速度 + self.参战单位[编号].速度*0.06
      if self.参战单位[编号].速度 >= 18888 then
        self.参战单位[编号].速度 = 18888
      end
    end
    if 编号~=nil and self:取奇经八脉是否有(编号,"意境") and self.参战单位[编号].愤怒 ~= nil then
      self.参战单位[编号].愤怒 = self.参战单位[编号].愤怒 + 1
      self:增加魔法(编号,24)
      if self.参战单位[编号].愤怒 >= 150 then
        self.参战单位[编号].愤怒 = 150
      end
    end
    if 编号~=nil and self:取奇经八脉是否有(编号,"回魔") and (self.参战单位[编号].最大魔法-self.参战单位[编号].灵力)>0 then
      self:增加魔法(编号,qz((self.参战单位[编号].最大魔法-self.参战单位[编号].灵力)*0.05))
    end
    if 编号~=nil and self:取奇经八脉是否有(编号,"心浪") and self.参战单位[编号].愤怒 ~= nil and self.参战单位[编号].愤怒 <= 50 then
      self.参战单位[编号].愤怒 = self.参战单位[编号].愤怒 + 取随机数(1,15)
       if self.参战单位[编号].愤怒 >= 150 then
        self.参战单位[编号].愤怒 = 150
      end
    end
    if 编号~=nil and self:取奇经八脉是否有(编号,"暗潮") and self.参战单位[编号].愤怒 <=90 then
      self.参战单位[编号].愤怒 = self.参战单位[编号].愤怒 + 4
       if self.参战单位[编号].愤怒 >= 150 then
        self.参战单位[编号].愤怒 = 150
      end
    end
    if 编号~=nil and self:取奇经八脉是否有(编号,"蚀天") and 取随机数() <=20 then
      self.参战单位[编号].法术伤害结果 = self.参战单位[编号].法术伤害结果 + 150
    end
    if 编号~=nil and self:取奇经八脉是否有(编号,"龙慑") then
      self.参战单位[编号].法术伤害结果 = self.参战单位[编号].法术伤害结果 + 100
    end
    if 编号~=nil and self:取奇经八脉是否有(编号,"突进") then
      if self.参战单位[编号].突进 ~= nil then
        self.参战单位[编号].伤害 = self.参战单位[编号].伤害 - self.参战单位[编号].突进
        self.参战单位[编号].突进 = nil
      end
      if self.参战单位[编号].突进 == nil and 取随机数() <= 40 then
        self.参战单位[编号].突进 = self.参战单位[编号].防御*0.08
        self.参战单位[编号].伤害 = self.参战单位[编号].伤害 + self.参战单位[编号].突进
      end
    end
    if 编号~=nil and self:取奇经八脉是否有(编号,"亢龙归海") then
      if self.参战单位[编号].亢龙归海 == nil or self.参战单位[编号].亢龙归海 < 25 then
        if self.参战单位[编号].亢龙归海  == nil then
          self.参战单位[编号].亢龙归海  = 0
        end
        self.参战单位[编号].灵力 = self.参战单位[编号].灵力*1.05
        self.参战单位[编号].亢龙归海 = self.参战单位[编号].亢龙归海  +5
        self.参战单位[编号].魔法 = self.参战单位[编号].魔法 - 100
      end
    end
    if 编号~=nil and self:取奇经八脉是否有(编号,"战魄") then
      self.参战单位[编号].愤怒 = self.参战单位[编号].愤怒+1
    end
    if 编号~=nil and self:取奇经八脉是否有(编号,"爪印") then
      if self.参战单位[编号].爪印 == nil or self.参战单位[编号].爪印 < 500 then
        if self.参战单位[编号].爪印  == nil then
          self.参战单位[编号].爪印  = 0
        end
        self.参战单位[编号].伤害 = self.参战单位[编号].伤害+20
        self.参战单位[编号].爪印 = self.参战单位[编号].爪印+20
      end
    end
    if 编号~=nil and self:取奇经八脉是否有(编号,"汲魂") then
      if self.参战单位[编号].汲魂 == nil or self.参战单位[编号].汲魂 < 500 then
        if self.参战单位[编号].汲魂  == nil then
          self.参战单位[编号].汲魂  = 0
        end
        self.参战单位[编号].伤害 = self.参战单位[编号].伤害+10
        self.参战单位[编号].汲魂 = self.参战单位[编号].汲魂  +20
      end
    end
    if 编号~=nil and self:取奇经八脉是否有(编号,"化怨") and self.参战单位[编号].气血<=self.参战单位[编号].最大气血 then
       self.参战单位[编号].法防 = qz(self.参战单位[编号].法防*1.25)
       self.参战单位[编号].防御 = qz(self.参战单位[编号].防御*1.25)
    end
    -- if 编号~=nil and self:取奇经八脉是否有(编号,"飞龙") and 取随机数()<=70  then
    --    self.参战单位[编号].法防 = qz(self.参战单位[编号].法防*1.25)
    --    self.参战单位[编号].防御 = qz(self.参战单位[编号].防御*1.25)
    -- end
    if 编号~=nil and self:取奇经八脉是否有(编号,"养生") and self.参战单位[编号].气血<=qz(self.参战单位[编号].最大气血*0.5) and self.参战单位[编号].法术状态.生命之泉==nil then
       self:添加状态("生命之泉",self.参战单位[编号],self.参战单位[编号],self.参战单位[编号].等级,编号)
    end
    if 编号~=nil and self:取奇经八脉是否有(编号,"养生") and self.参战单位[编号].气血<=qz(self.参战单位[编号].最大气血*0.5) and self.参战单位[编号].法术状态.生命之泉==nil then
       self:添加状态("金身舍利",self.参战单位[编号],self.参战单位[编号],self.参战单位[编号].等级,编号)
       self:添加状态("明光宝烛",self.参战单位[编号],self.参战单位[编号],self.参战单位[编号].等级,编号)
    end
    if 编号~=nil and self:取奇经八脉是否有(编号,"燃魂") then
      if self.参战单位[编号].燃魂 == nil then
        if self.参战单位[编号].法伤==nil then
            self.参战单位[编号].法伤=0
        end
          self.参战单位[编号].法伤 = self.参战单位[编号].法伤 + qz(self.参战单位[编号].魔法/self.参战单位[编号].最大魔法*0.5)
          self.参战单位[编号].燃魂 = qz(self.参战单位[编号].魔法/self.参战单位[编号].最大魔法*0.5)
      else
          self.参战单位[编号].法伤 = self.参战单位[编号].法伤 - self.参战单位[编号].燃魂
          self.参战单位[编号].法伤 = self.参战单位[编号].法伤 + qz(self.参战单位[编号].魔法/self.参战单位[编号].最大魔法*0.5)
          self.参战单位[编号].燃魂 = qz(self.参战单位[编号].魔法/self.参战单位[编号].最大魔法*0.5)
      end
    end

    if 编号~=nil and self:取奇经八脉是否有(编号,"补缺") and 取随机数() <=35 and self.参战单位[编号].魔法 <= self.参战单位[编号].最大魔法*0.3 then
      self:增加魔法(编号,self.参战单位[编号].最大魔法*0.1)
    end
    if 编号~=nil and self:取奇经八脉是否有(编号,"调息") and self.参战单位[编号].法术状态.分身术~=nil then
      self:增加魔法(编号,self.参战单位[编号].最大魔法*0.03)
    end
    if 编号~=nil and self:取奇经八脉是否有(编号,"狂月") then
      self:增加魔法(编号,self.参战单位[编号].最大魔法*0.1)
    end
    if 编号~=nil and self:取奇经八脉是否有(编号,"混元") and self.参战单位[编号].气血>=qz(self.参战单位[编号].最大气血*0.7) and self.参战单位[编号].混元==nil then
      if self.参战单位[编号].混元==nil then
          self.参战单位[编号].混元=0
      end
      self.参战单位[编号].伤害=qz(self.参战单位[编号].伤害*1.05)
      self.参战单位[编号].混元=true
    end
    if 编号~=nil and self:取奇经八脉是否有(编号,"神躯") and self.参战单位[编号].神躯==nil then
      if self.参战单位[编号].神躯==nil then
          self.参战单位[编号].神躯=0
      end
      self.参战单位[编号].防御=qz(self.参战单位[编号].防御*1.2)
      self.参战单位[编号].神躯=true
    end
    if 编号~=nil and self:取奇经八脉是否有(编号,"敛恨") and self.参战单位[编号].敛恨==nil then
      if self.参战单位[编号].敛恨==nil then
          self.参战单位[编号].敛恨=0
      end
      self.参战单位[编号].防御=qz(self.参战单位[编号].防御*1.2)
      self.参战单位[编号].敛恨=true
    end
    if 编号~=nil and self:取奇经八脉是否有(编号,"回旋") and self.参战单位[编号].回旋==nil then
      if self.参战单位[编号].回旋==nil then
          self.参战单位[编号].回旋=0
      end
      self.参战单位[编号].防御=qz(self.参战单位[编号].防御*1.05)
      self.参战单位[编号].法防=qz(self.参战单位[编号].法防*1.05)
      self.参战单位[编号].回旋=true
    end
    if 编号~=nil and self:取奇经八脉是否有(编号,"风墙") and self.参战单位[编号].风墙==nil then
      if self.参战单位[编号].风墙==nil then
          self.参战单位[编号].风墙=0
      end
      self.参战单位[编号].防御=qz(self.参战单位[编号].防御*1.16)
      self.参战单位[编号].法防=qz(self.参战单位[编号].法防*1.16)
      self.参战单位[编号].风墙=true
    end
    if 编号~=nil and self:取奇经八脉是否有(编号,"破浪") and self.参战单位[编号].破浪==nil and 取随机数()<=20 then
      if self.参战单位[编号].破浪==nil then
          self.参战单位[编号].破浪=0
      end
      self.参战单位[编号].法术伤害结果=self.参战单位[编号].法术伤害结果+100
      self.参战单位[编号].破浪=true
    end
    if 编号~=nil and self:取奇经八脉是否有(编号,"龙骇") and self.参战单位[编号].龙骇==nil then
      if self.参战单位[编号].龙骇==nil then
          self.参战单位[编号].龙骇=0
      end
      self.参战单位[编号].法术伤害结果=self.参战单位[编号].法术伤害结果+40
      self.参战单位[编号].龙骇=true
    end
    if 编号~=nil and self:取奇经八脉是否有(编号,"不惊") and self.参战单位[编号].不惊==nil then
      if self.参战单位[编号].不惊==nil then
          self.参战单位[编号].不惊=0
      end
      self.参战单位[编号].伤害=self.参战单位[编号].伤害+qz(self.参战单位[编号].防御*0.05)
      self.参战单位[编号].不惊=true
    end
  end
end

function 战斗处理类:经脉属性处理(编号)
  if self.参战单位[编号].奇经八脉 ~= nil then
    if 编号~=nil and self:取奇经八脉是否有(编号,"额外能力") then
        if self.参战单位[编号].门派 == "大唐官府" or self.参战单位[编号].门派 == "化生寺" or self.参战单位[编号].门派 == "方寸山" or self.参战单位[编号].门派 == "女儿村" or self.参战单位[编号].门派 == "神木林" or self.参战单位[编号].门派 == "天机城" then
          self.参战单位[编号].伤害 = self.参战单位[编号].伤害*1.08
          self.参战单位[编号].防御 = self.参战单位[编号].防御*1.08
          self.参战单位[编号].灵力 = self.参战单位[编号].灵力*1.08
          self.参战单位[编号].法防 = self.参战单位[编号].法防*1.08
          self.参战单位[编号].速度 = self.参战单位[编号].速度*1.08
        elseif self.参战单位[编号].门派 == "狮驼岭" or self.参战单位[编号].门派 == "魔王寨" or self.参战单位[编号].门派 == "阴曹地府" or self.参战单位[编号].门派 == "盘丝洞" or self.参战单位[编号].门派 == "无底洞" or self.参战单位[编号].门派 == "女魃墓" then
          self.参战单位[编号].伤害 = self.参战单位[编号].伤害*1.15
          self.参战单位[编号].防御 = self.参战单位[编号].防御*1.15
          self.参战单位[编号].灵力 = self.参战单位[编号].灵力*1.05
          self.参战单位[编号].法防 = self.参战单位[编号].法防*1.15
          self.参战单位[编号].速度 = self.参战单位[编号].速度*1.05
        else
          self.参战单位[编号].伤害 = self.参战单位[编号].伤害*1.05
          self.参战单位[编号].防御 = self.参战单位[编号].防御*1.15
          self.参战单位[编号].灵力 = self.参战单位[编号].灵力*1.15
          self.参战单位[编号].法防 = self.参战单位[编号].法防*1.15
          self.参战单位[编号].速度 = self.参战单位[编号].速度*1.05
        end
    end
    if 编号~=nil and self:取奇经八脉是否有(编号,"洞察") then
        self.参战单位[编号].伤害 = self.参战单位[编号].伤害+self.参战单位[编号].等级/2
        self.参战单位[编号].防御 = self.参战单位[编号].防御+self.参战单位[编号].等级/2
        self.参战单位[编号].灵力 = self.参战单位[编号].灵力+self.参战单位[编号].等级/2
        self.参战单位[编号].法防 = self.参战单位[编号].法防+self.参战单位[编号].等级/2
    end
    if 编号~=nil and self:取奇经八脉是否有(编号,"修身") then
        self.参战单位[编号].伤害 = self.参战单位[编号].伤害+14
        self.参战单位[编号].防御 = self.参战单位[编号].防御+14
        self.参战单位[编号].灵力 = self.参战单位[编号].灵力+14
        self.参战单位[编号].法防 = self.参战单位[编号].法防+14
    end
    if 编号~=nil and self:取奇经八脉是否有(编号,"聚魂") then
        self.参战单位[编号].伤害 = self.参战单位[编号].伤害+14
        self.参战单位[编号].防御 = self.参战单位[编号].防御+14
        self.参战单位[编号].灵力 = self.参战单位[编号].灵力+14
        self.参战单位[编号].法防 = self.参战单位[编号].法防+14
    end
    if 编号~=nil and self:取奇经八脉是否有(编号,"忘形") then
      if self.参战单位[编号].必杀==nil then
          self.参战单位[编号].必杀=0
      end
      if self.参战单位[编号].法暴==nil then
        self.参战单位[编号].法暴=0
      end
       self.参战单位[编号].必杀 = self.参战单位[编号].必杀+3
       self.参战单位[编号].法暴 = self.参战单位[编号].法暴+3
        --   self.参战单位[队伍数据].法暴 = self.参战单位[队伍数据].法暴+3
        -- for n=1,#队伍数据[self.参战单位[编号].队伍].成员数据 do
        --   local 队伍数据=队伍数据[self.参战单位[编号].队伍].成员数据[n]
        --   if self.参战单位[队伍数据].必杀==nil then
        --     self.参战单位[队伍数据].必杀=0
        --   end
        --   if self.参战单位[队伍数据].法暴==nil then
        --     self.参战单位[队伍数据].法暴=0
        --   end
        --   self.参战单位[队伍数据].必杀 = self.参战单位[队伍数据].必杀+3
        --   self.参战单位[队伍数据].法暴 = self.参战单位[队伍数据].法暴+3
        -- end
    end
    if 编号~=nil and self:取奇经八脉是否有(编号,"铁骨") then
        self.参战单位[编号].防御 = self.参战单位[编号].防御*1.2
    end
    if 编号~=nil and self:取奇经八脉是否有(编号,"豪胆") then
      if self.参战单位[编号].必杀==nil then
        self.参战单位[编号].必杀=0
      end
      self.参战单位[编号].必杀 = self.参战单位[编号].必杀+10
    end
    if 编号~=nil and self:取奇经八脉是否有(编号,"充沛") then
        self.参战单位[编号].气血 = self.参战单位[编号].气血*1.1
        self.参战单位[编号].最大气血 = self.参战单位[编号].最大气血*1.1
    end
    if 编号~=nil and self:取奇经八脉是否有(编号,"灵光") then
      self.参战单位[编号].灵力 = self.参战单位[编号].灵力+self.参战单位[编号].灵力*0.05
    end
    if 编号~=nil and self:取奇经八脉是否有(编号,"魔焰滔天") then
      self.参战单位[编号].法暴 = self.参战单位[编号].法暴+20
    end
    if 编号~=nil and self:取奇经八脉是否有(编号,"强击") then
      self.参战单位[编号].伤害=qz(self.参战单位[编号].伤害*1.1)
    end
    if 编号~=nil and self:取奇经八脉是否有(编号,"狂狷") then
        self.参战单位[编号].伤害 = self.参战单位[编号].伤害 + (self.参战单位[编号].力量/self.参战单位[编号].耐力)*0.16
    end
    if 编号~=nil and self:取奇经八脉是否有(编号,"烈焰真诀") then
        self.参战单位[编号].法暴 = self.参战单位[编号].法暴 + 10
    end
    if 编号~=nil and self:取奇经八脉是否有(编号,"鬼念") then
        self.参战单位[编号].防御 = qz(self.参战单位[编号].防御*1.15)
        self.参战单位[编号].法防 = qz(self.参战单位[编号].法防*1.15)
    end
    if 编号~=nil and self:取奇经八脉是否有(编号,"化戈") then
        if self.参战单位[编号].治疗能力==nil then
          self.参战单位[编号].治疗能力=0
        end
        self.参战单位[编号].治疗能力 = self.参战单位[编号].治疗能力 +self.参战单位[编号].装备属性.伤害*0.18
    end
    if 编号~=nil and self:取奇经八脉是否有(编号,"锤炼") then
        self.参战单位[编号].伤害 = self.参战单位[编号].伤害 +self.参战单位[编号].装备属性.伤害*0.03
    end
    if 编号~=nil and self:取奇经八脉是否有(编号,"借灵") then
        self.参战单位[编号].固定伤害 = self.参战单位[编号].固定伤害 +self.参战单位[编号].装备属性.伤害*0.24
    end
    if 编号~=nil and self:取奇经八脉是否有(编号,"真君显灵") then
        self.参战单位[编号].伤害 =  self.参战单位[编号].伤害*1.1
        self.参战单位[编号].防御 =  self.参战单位[编号].防御*0.9
    end
    if 编号~=nil and self:取奇经八脉是否有(编号,"驭意") then
        self.参战单位[编号].速度 = self.参战单位[编号].速度 + self.参战单位[编号].魔力*0.05
    end
    if 编号~=nil and self:取奇经八脉是否有(编号,"神凝") then
        if self.参战单位[编号].抵抗封印等级 == nil then
          self.参战单位[编号].抵抗封印等级 = 0
        end
        self.参战单位[编号].抵抗封印等级 = self.参战单位[编号].抵抗封印等级 + 100
    end
    if 编号~=nil and self:取奇经八脉是否有(编号,"破击") then
      self.参战单位[编号].必杀 = self.参战单位[编号].必杀 + 20
    end
    if 编号~=nil and self:取奇经八脉是否有(编号,"止戈") then
        if self.参战单位[编号].治疗能力==nil then
          self.参战单位[编号].治疗能力=0
        end
        self.参战单位[编号].治疗能力 = self.参战单位[编号].治疗能力 + self.参战单位[编号].装备属性.伤害*0.18
    end
    if 编号~=nil and self:取奇经八脉是否有(编号,"推衍") then
        if self.参战单位[编号].敏捷 >= qz(self.参战单位[编号].等级*2.2) then
            self.参战单位[编号].固定伤害 = self.参战单位[编号].固定伤害*1.21
        end
    end
    if 编号~=nil and self:取奇经八脉是否有(编号,"暗伤") then
        self.参战单位[编号].固定伤害 = self.参战单位[编号].固定伤害 + self.参战单位[编号].装备属性.伤害*0.18
    end
    if 编号~=nil and self:取奇经八脉是否有(编号,"倩影") then
        self.参战单位[编号].速度 = self.参战单位[编号].速度 + 50
    end
    if 编号~=nil and self:取奇经八脉是否有(编号,"风魂") then
        self.参战单位[编号].防御 = self.参战单位[编号].防御 *1.1
    end
    if 编号~=nil and self:取奇经八脉是否有(编号,"念心") then
       self.参战单位[编号].必杀 = self.参战单位[编号].必杀 *1.1
    end
    if 编号~=nil and self:取奇经八脉是否有(编号,"斗法") then
       self.参战单位[编号].封印命中等级 = self.参战单位[编号].封印命中等级 + 100
    end
    if 编号~=nil and self:取奇经八脉是否有(编号,"自矜") then
       self.参战单位[编号].封印命中等级 = self.参战单位[编号].封印命中等级 + 100
    end
    if 编号~=nil and self:取奇经八脉是否有(编号,"妖气") then
       self.参战单位[编号].封印命中等级 =self.参战单位[编号].封印命中等级 + self.参战单位[编号].装备属性.伤害*0.12
    end
    if 编号~=nil and self:取奇经八脉是否有(编号,"心随意动") then
       self.参战单位[编号].封印命中等级 = self.参战单位[编号].封印命中等级 + 100
       self.参战单位[编号].伤害 = self.参战单位[编号].伤害 + 100
    end
    if 编号~=nil and self:取奇经八脉是否有(编号,"神附") then
       self.参战单位[编号].伤害 = self.参战单位[编号].伤害 + self.参战单位[编号].力量*0.08
    end
    if 编号~=nil and self:取奇经八脉是否有(编号,"海沸") then
       self.参战单位[编号].伤害 = self.参战单位[编号].伤害 + self.参战单位[编号].力量*0.08
    end
    if 编号~=nil and self:取奇经八脉是否有(编号,"趁虚") then
       self.参战单位[编号].封印命中等级 = self.参战单位[编号].封印命中等级 + 80
    end
    if 编号~=nil and self:取奇经八脉是否有(编号,"月桂") then
       self.参战单位[编号].封印命中等级 = self.参战单位[编号].封印命中等级 + self.参战单位[编号].装备属性.伤害*0.12
    end
    if 编号~=nil and self:取奇经八脉是否有(编号,"顺势而为") then
       self.参战单位[编号].封印必中 = true
    end
    if 编号~=nil and self:取奇经八脉是否有(编号,"钟馗论道") then
       self.参战单位[编号].驱鬼 = 2
    end
    if 编号~=nil and self:取奇经八脉是否有(编号,"碎玉弄影") then
       self.参战单位[编号].防御 = self.参战单位[编号].防御*0.95
    end
    if 编号~=nil and self:取奇经八脉是否有(编号,"风灵") and self.参战单位[编号].门派 ~= nil and self.参战单位[编号].门派 == "神木林" then
       self.参战单位[编号].风灵 = 10
    end
    if 编号~=nil and self:取奇经八脉是否有(编号,"风魂") and self.参战单位[编号].门派 ~= nil and self.参战单位[编号].门派 == "神木林" then
       self.参战单位[编号].防御 = self.参战单位[编号].防御 + 100
    end
    if 编号~=nil and self:取奇经八脉是否有(编号,"磐石") then
       self.参战单位[编号].防御 = self.参战单位[编号].防御+50
       self.参战单位[编号].法防 = self.参战单位[编号].法防+50
    end
    if 编号~=nil and self:取奇经八脉是否有(编号,"纯净") then
       self.参战单位[编号].最大气血 = self.参战单位[编号].最大气血+self.参战单位[编号].等级
    end
    if 编号~=nil and self:取奇经八脉是否有(编号,"咒法") then
       self.参战单位[编号].法术伤害结果 = self.参战单位[编号].法术伤害结果 +60
    end
    if 编号~=nil and self:取奇经八脉是否有(编号,"踏涛") then
       self.参战单位[编号].法术伤害结果 = self.参战单位[编号].法术伤害结果 +60
    end
    if 编号~=nil and self:取奇经八脉是否有(编号,"天龙") then
       self.参战单位[编号].法术伤害结果 = self.参战单位[编号].法术伤害结果 +150
    end
    if 编号~=nil and self:取奇经八脉是否有(编号,"震天") then
       self.参战单位[编号].法术伤害结果 = self.参战单位[编号].法术伤害结果 +60
    end
    if 编号~=nil and self:取奇经八脉是否有(编号,"护佑") then
       self.参战单位[编号].防御 = self.参战单位[编号].防御+50
       self.参战单位[编号].法防 = self.参战单位[编号].法防+50
    end
    if 编号~=nil and self:取奇经八脉是否有(编号,"化血") then
       self.参战单位[编号].吸血=0.15
    end

  end
end

function 战斗处理类:发送退出信息()
  for n=1,#self.参战玩家 do
      if 自动遇怪[self.参战玩家[n].id]~=nil then
        自动遇怪[self.参战玩家[n].id]=os.time()
      end
      if 玩家数据[self.参战玩家[n].id]~=nil then
        发送数据(self.参战玩家[n].连接id,5505)
        玩家数据[self.参战玩家[n].id].战斗=0
        玩家数据[self.参战玩家[n].id].遇怪时间=os.time()+取随机数(10,20)
        玩家数据[self.参战玩家[n].id].道具:重置法宝回合(self.参战玩家[n].id)
        玩家数据[self.参战玩家[n].id].角色.数据.战斗开关=nil
        地图处理类:设置战斗开关(self.参战玩家[n].id)
        if 玩家数据[self.参战玩家[n].id].战斗对话~=nil then
          发送数据(玩家数据[self.参战玩家[n].id].连接id,1501,玩家数据[self.参战玩家[n].id].战斗对话)
          end
          if self.战斗类型==100011 then
            发送数据(玩家数据[self.参战玩家[n].id].连接id,1501,self.对话数据)
          end
          玩家数据[self.参战玩家[n].id].战斗对话=nil
          if self.参战玩家[n].断线 then
            系统处理类:断开游戏(self.参战玩家[n].id)
          end
        end
        if self.战斗类型==100019 and self.玩家胜利 and 取随机数()<=2 then
          local id=self.进入战斗玩家id
          if 玩家数据[id].角色.数据.地图数据.编号~=1620 then
            local 随机递增=取随机数(1,3)
            local 传送地图= 玩家数据[id].角色.数据.地图数据.编号+随机递增
            if 传送地图>1620 then
              传送地图=1620
            end
            local xy=地图处理类.地图坐标[传送地图]:取随机点()
            地图处理类:跳转地图(id,传送地图,xy.x,xy.y)
            常规提示(id,"#Y你击败了迷宫小怪后，意外地发现自己来到了#R"..取地图名称(传送地图))
          end
        end
  end
  for i,v in pairs(self.观战玩家) do
    if 玩家数据[i] ~= nil then
      if 自动遇怪[i]~=nil then
        自动遇怪[i]=os.time()
      end
      发送数据(玩家数据[i].连接id,5505)
      玩家数据[i].战斗=0
      玩家数据[i].观战=nil
      玩家数据[i].遇怪时间=os.time()+取随机数(10,20)
    end
  end
  self.结束条件=true
  if self.战斗类型==100050 and self.战斗失败==false then
    local id=self.进入战斗玩家id
    战斗准备类:创建战斗(id,100051,self.任务id)
  elseif self.战斗类型==100051 and self.战斗失败==false then
    local id=self.进入战斗玩家id
    战斗准备类:创建战斗(id,100052,self.任务id)
  elseif self.战斗类型==100052 and self.战斗失败==false then
    local id=self.进入战斗玩家id
    战斗准备类:创建战斗(id,100053,self.任务id)
  elseif self.战斗类型==100053 and self.战斗失败==false then
    local id=self.进入战斗玩家id
    战斗准备类:创建战斗(id,100054,self.任务id)
  end
  if self.战斗类型==100130 and self.战斗失败==false then
    local id=self.进入战斗玩家id
    战斗准备类:创建战斗(id,100131,self.任务id)
  elseif self.战斗类型==100131 and self.战斗失败==false then
    local id=self.进入战斗玩家id
    战斗准备类:创建战斗(id,100132,self.任务id)
  elseif self.战斗类型==100132 and self.战斗失败==false then
    local id=self.进入战斗玩家id
    战斗准备类:创建战斗(id,100133,self.任务id)
  elseif self.战斗类型==100133 and self.战斗失败==false then
    local id=self.进入战斗玩家id
    战斗准备类:创建战斗(id,100134,self.任务id)
  end
end

function 战斗处理类:更新(dt) --自动时间
  if self.回合进程=="命令回合" then
    if os.time()-self.等待起始>=3 then
      for n=1,#self.参战单位 do
        if self.参战单位[n].自动战斗 and self.参战单位[n].指令.下达==false then
          if self.参战单位[n].自动指令~=nil and 玩家数据[self.参战单位[n].玩家id]~=nil and 玩家数据[self.参战单位[n].玩家id].角色.数据.自动战斗 then
            self.参战单位[n].指令=table.loadstring(table.tostring(self.参战单位[n].自动指令))
            --重新计算
            if self.参战单位[n].指令.类型=="法术" then
              if self.参战单位[n].指令.参数=="" then
                self.参战单位[n].指令.类型="攻击"
                self.参战单位[n].指令.目标=self:取单个敌方目标(n)
              else
                local 临时技能=取法术技能(self.参战单位[n].指令.参数)
                if 临时技能[3]==4 then
                  self.参战单位[n].指令.目标=self:取单个敌方目标(n)
                else
                  self.参战单位[n].指令.目标=self:取单个友方目标(n)
                end
              end
            end
            if self.参战单位[self.参战单位[n].指令.目标]==nil and self.参战单位[n].指令.类型~="防御" then
              self.参战单位[n].指令.类型="攻击"
              self.参战单位[n].指令.目标=self:取单个敌方目标(n)
            end
          else
            self.参战单位[n].指令.类型="攻击"
            self.参战单位[n].指令.目标=self:取单个敌方目标(n)
          end
          self.参战单位[n].指令.下达=true
          发送数据(玩家数据[self.参战单位[n].玩家id].连接id,5511)
          if self.参战单位[n].队伍~=0 and self.参战单位[n].类型=="角色" and self.参战单位[n].助战编号==nil then
            self.加载数量=self.加载数量-1
          end
        end
      end
    end
    if self.加载数量<=0 then
      self.回合进程="计算回合"
      self:设置执行回合()
    end
    if os.time()-self.等待起始>=32 then
      self.回合进程="计算回合"
      self:设置执行回合()
    end
  elseif self.回合进程=="执行回合" then
      --检查是否有自动
     --[[local 断线数量=0
     for n=1,#self.参战玩家 do
       if self.参战玩家[n].断线等待 then
         断线数量=断线数量+1
         end
       end
     if 断线数量==#self.参战玩家  then
       --self.执行等待=os.time()+5
         for n=1,#self.参战玩家 do
            self.参战玩家[n].断线等待=nil
          end
       return
       end --]]
       --print(os.time(),self)
    if os.time()>=self.执行等待 and self.回合进程~="结束回合" then
      self.回合进程="结束回合"
      self:结算处理()
    end
  end
end
function 战斗处理类:显示(x,y)end
return 战斗处理类