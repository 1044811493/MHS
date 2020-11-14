--======================================================================--

--======================================================================--
local 召唤兽处理类 = class()
local 资质范围={"攻击资质","防御资质","体力资质","法力资质","速度资质","躲闪资质",}
local 属性范围={"体质","魔力","力量","耐力","敏捷"}
local bbs = 取宝宝
local rand   = 取随机小数
local cfs    = 删除重复
local ceil  = math.ceil
local insert = table.insert
local remove = table.remove
local floor = math.floor
local 五行_ = {"金","木","水","火","土"}

require("Script/数据中心/梦战召唤兽模型")
function 召唤兽处理类:初始化(id)
  -- self.数据={}
end

function 召唤兽处理类:数据处理(连接id,序号,id,内容)
  if 玩家数据[id].摊位数据~=nil and 序号~=5001 then
    常规提示(id,"#Y/摆摊状态下禁止此种行为")
    return
  end
  if 序号==5001 then
    发送数据(连接id,17,self.数据)
  elseif 序号==5002 then
    self:参战处理(连接id,序号,id,内容.序列)
  elseif 序号==5003 then
    self:改名处理(连接id,序号,id,内容.序列,内容.名称)
  elseif 序号==5004 then
    self:加点处理(连接id,序号,id,内容)
  elseif 序号==5005 then
    self:放生处理(连接id,序号,id,内容)
  elseif 序号==5006 then
    发送数据(连接id,22,玩家数据[id].角色.数据.宠物)
  elseif 序号==5007 then
    发送数据(连接id,16,self.数据)
    发送数据(连接id,23,玩家数据[id].道具:索要道具2(id))
  elseif 序号==5008 then
    self:洗练处理(连接id,序号,id,内容)
  elseif 序号==5009 then
    self:合宠处理(连接id,序号,id,内容)
  elseif 序号==5010 then
    self:炼化处理(连接id,序号,id,内容)
  elseif 序号==5011 then
    self:召唤兽染色(连接id,序号,id,内容)
  elseif 序号==5012 then
    self:商会购买召唤兽处理(连接id,序号,id,内容)
  end
end

function 召唤兽处理类:加载数据(账号,数字id)
  self.数字id=数字id
  self.数据=table.loadstring(读入文件([[data/]]..账号..[[/]]..数字id..[[/召唤兽.txt]]))
  for i=1,#self.数据 do
    if self.数据[i].统御属性 == nil then
      self.数据[i].统御属性={体质=0,魔力=0,力量=0,耐力=0,敏捷=0}
    end
    if 玩家数据[数字id].角色.数据.参战宝宝.认证码  ~= nil and self.数据[i].认证码==玩家数据[数字id].角色.数据.参战宝宝.认证码 then
      if 玩家数据[数字id].角色.数据.参战宝宝.等级-10 > 玩家数据[数字id].角色.数据.等级+0 then
        玩家数据[数字id].角色.数据.参战宝宝={}
        self.数据[i].参战信息= nil
        玩家数据[数字id].角色.数据.参战信息=nil
      else
        玩家数据[数字id].角色.数据.参战宝宝={}
        玩家数据[数字id].角色.数据.参战宝宝=self.数据[i]
        玩家数据[数字id].角色.数据.参战信息=1
        self.数据[i].参战信息=1
      end
    end
  end
end

function 召唤兽处理类:添加召唤兽(造型,宝宝,变异,神兽,等级,物法,位置,vip)
  local 编号
  if 宝宝 == "宝宝" or 宝宝 == "变异" then
    宝宝 = true
    if 变异 == "变异" then
      变异 = true
    else
      变异 = false
    end
  elseif 宝宝 == "野怪" then
    宝宝 = false
  end
  if 位置 == nil then
    self.数据[#self.数据+1]={
      模型 = 造型,
      名称 = 造型,
      忠诚 = 100,
      等级 = 等级 or 0,
      潜力 = 等级*5 or 0,
      装备 = {},
      染色组 = {},
      装备属性 = {
        气血 = 0,
        魔法 = 0,
        命中 = 0,
        伤害 = 0,
        防御 = 0,
        速度 = 0,
        躲避 = 0,
        灵力 = 0,
        体质 = 0,
        魔力 = 0,
        力量 = 0,
        耐力 = 0,
        敏捷 = 0,
      },
      灵性 = 0,
      进阶 = false,
      仙露上限 = 7,
      特性 = "无",
      特性几率 = 0,
      进阶属性 = {
        力量 = 0,
        敏捷 = 0,
        耐力 = 0,
        魔力 = 0,
        体质 = 0,
      },
      统御属性 = {
        力量 = 0,
        敏捷 = 0,
        耐力 = 0,
        魔力 = 0,
        体质 = 0,
      },
      当前经验 = 0,
      寿命=5000,
      五行 = 五行_[取随机数(1,5)]
    }
    编号 = #self.数据
  else
    self.数据[位置]={
      模型 = 造型,
      名称 = 造型,
      忠诚 = 100,
      等级 = 等级 or 0,
      潜力 = 等级*5 or 0,
      装备 = {},
      染色组 = {},
      装备属性 = {
        气血 = 0,
        魔法 = 0,
        命中 = 0,
        伤害 = 0,
        防御 = 0,
        速度 = 0,
        躲避 = 0,
        灵力 = 0,
        体质 = 0,
        魔力 = 0,
        力量 = 0,
        耐力 = 0,
        敏捷 = 0,
      },
      灵性 = 0,
      进阶 = false,
      仙露上限 = 7,
      特性 = "无",
      特性几率 = 0,
      进阶属性 = {
        力量 = 0,
        敏捷 = 0,
        耐力 = 0,
        魔力 = 0,
        体质 = 0,
      },
      统御属性 = {
        力量 = 0,
        敏捷 = 0,
        耐力 = 0,
        魔力 = 0,
        体质 = 0,
      },
      当前经验 = 0,
      寿命=5000,
      五行 = 五行_[取随机数(1,5)]
    }
    编号 = 位置
  end
  if 神兽 then
    local qss
    if vip==nil then
      qss = 取神兽资质(造型,物法)
    else
      qss = 取VIP召唤兽(造型)
    end
    self.数据[编号].种类 = "神兽"
    for i=1,#资质范围 do
      self.数据[编号][资质范围[i]] = qss[i] or 0
    end
    self.数据[编号].技能 = qss[8]
    self.数据[编号].成长 = qss[7]
    self.数据[编号].参战等级 = 0
    self.数据[编号].内丹 = {内丹上限=6,可用内丹=6}
    self.数据[编号].潜力 = 0
    for i=1,#属性范围 do
      self.数据[编号][属性范围[i]] = qss[9][i+1] or 0
    end
    self.数据[编号].认证码=self.数字id.."_"..os.time().."_"..服务端参数.运行时间.."_"..取随机数(111111111111,999999999999)
  else
    local n = bbs(造型)
    local 类型
    local 是否变异 = 变异
    local 波动上限 = 1
    local 能力 = 0
    local 五维总值 = 0
    if 宝宝 then
      类型 = "宝宝"
      能力 = 0.925
      self.数据[编号].体质 = 10
      self.数据[编号].魔力 = 10
      self.数据[编号].力量 = 10
      self.数据[编号].耐力 = 10
      self.数据[编号].敏捷 = 10
      self.数据[编号].种类 = "宝宝"
      if 是否变异 then
        能力 = 1.105
        self.数据[编号].体质 = 15
        self.数据[编号].魔力 = 15
        self.数据[编号].力量 = 15
        self.数据[编号].耐力 = 15
        self.数据[编号].敏捷 = 15
        n[2] = n[2] + 80
        n[3] = n[3] + 80
        n[4] = n[4] + 80
        n[5] = n[5] + 80
        n[6] = n[6] + 80
        n[7] = n[7] + 80
        self.数据[编号].变异=true
        self.数据[编号].种类 = "变异"
        self.数据[编号].名称 = "变异"..造型
        if 染色信息[造型] ~= nil  then
          self.数据[编号].染色方案 = 染色信息[造型].id
          for i=1,3 do
            if 染色信息[造型].方案[i] ~= nil then
               self.数据[编号].染色组[i] = 染色信息[造型].方案[i]
            end
          end
        end
      end
    else
      类型 = "野怪"
      self.数据[编号].潜力 = 0
      self.数据[编号].种类 = "野怪"
      能力 = 0.725
      五维总值 = 45 + 等级 * 5 + 取随机数(-10,20)
    end
    self.数据[编号].参战等级 = n[1]
    if 类型 == "野怪" then
      local s1,s2,s3,s4,s5,s6
      while true do
        s1 = 取随机数(五维总值/10,ceil(五维总值/3))
        s2 = 取随机数(五维总值/10,ceil(五维总值/3))
        s3 = 取随机数(五维总值/10,ceil(五维总值/3))
        s4 = 取随机数(五维总值/10,ceil(五维总值/3))
        s5 = 取随机数(五维总值/10,ceil(五维总值/3))
        if (s1+s2+s3+s4+s5==五维总值) then
          self.数据[编号].体质 = s1--+等级
          self.数据[编号].魔力 = s2--+等级
          self.数据[编号].力量 = s3--+等级
          self.数据[编号].耐力 = s4--+等级
          self.数据[编号].敏捷 = s5
          break
        end
      end
    end
    self.数据[编号].攻击资质= ceil(n[2]*rand(能力,波动上限))
    self.数据[编号].防御资质= ceil(n[3]*rand(能力,波动上限))
    self.数据[编号].体力资质= ceil(n[4]*rand(能力,波动上限))
    self.数据[编号].法力资质= ceil(n[5]*rand(能力,波动上限))
    self.数据[编号].速度资质= ceil(n[6]*rand(能力,波动上限))
    self.数据[编号].躲闪资质= ceil(n[7]*rand(能力,波动上限))
    local cz1 = 取随机数(1,100)
    if cz1 < 30 then
      self.数据[编号].成长 = n[8][1]
    elseif cz1 > 30  and cz1 < 60 then
      self.数据[编号].成长 = n[8][2]
    elseif cz1 > 60  and cz1 < 80 then
      self.数据[编号].成长 = n[8][3]
    elseif cz1 > 80  and cz1 < 95 then
      self.数据[编号].成长 = n[8][4]
    elseif cz1 > 95  and cz1 < 100 then
      self.数据[编号].成长 = n[8][5]
    end
    if self.数据[编号].成长 == nil or self.数据[编号].成长 == 0 then
      self.数据[编号].成长 = n[8][1]
    end
    local jn = n[9]
    local jn0 = {}
    for q=1,#jn do
      insert(jn0, jn[取随机数(1,#jn)])
    end
    jn0 = cfs(jn0)
    self.数据[编号].技能 = jn0
    self.数据[编号].内丹 = {内丹上限=floor(self.数据[编号].参战等级 / 35)+1,可用内丹=floor(self.数据[编号].参战等级 / 35)+1}
    self.数据[编号].认证码=self.数字id.."_"..os.time().."_"..服务端参数.运行时间.."_"..取随机数(111111111111,999999999999)
  end

  self:刷新信息(编号,"1")
  发送数据(玩家数据[self.数字id].连接id,17.1,self.数据)
end

function 召唤兽处理类:刷新信息(编号,是否)
  self.数据[编号].最大气血 = ceil(self.数据[编号].等级*self.数据[编号].体力资质/1000+(self.数据[编号].体质+self.数据[编号].进阶属性.体质+self.数据[编号].统御属性.体质)*self.数据[编号].成长*6) + self.数据[编号].装备属性.气血
  self.数据[编号].最大魔法 = ceil(self.数据[编号].等级*self.数据[编号].法力资质/500+(self.数据[编号].魔力+self.数据[编号].进阶属性.魔力+self.数据[编号].统御属性.魔力)*self.数据[编号].成长*3) + self.数据[编号].装备属性.魔法
  self.数据[编号].伤害 = ceil(self.数据[编号].等级*self.数据[编号].攻击资质*(self.数据[编号].成长+1.4)/750+(self.数据[编号].力量+self.数据[编号].进阶属性.力量+self.数据[编号].统御属性.力量)*self.数据[编号].成长 + self.数据[编号].装备属性.命中/4+(self.数据[编号].体质+self.数据[编号].进阶属性.体质)*0.3) + self.数据[编号].装备属性.伤害
  self.数据[编号].防御 = ceil(self.数据[编号].等级*self.数据[编号].防御资质*(self.数据[编号].成长+1.4)/1143+(self.数据[编号].耐力+self.数据[编号].进阶属性.耐力+self.数据[编号].统御属性.耐力)*(self.数据[编号].成长-1/253)*253/190)+ self.数据[编号].装备属性.防御
  self.数据[编号].速度 = ceil(self.数据[编号].速度资质 * (self.数据[编号].敏捷+self.数据[编号].进阶属性.敏捷+self.数据[编号].统御属性.敏捷)/1000)  + self.数据[编号].装备属性.速度
  self.数据[编号].灵力 = ceil(self.数据[编号].等级*(self.数据[编号].法力资质+1666)/3333+(self.数据[编号].魔力+self.数据[编号].进阶属性.魔力+self.数据[编号].统御属性.魔力)*self.数据[编号].成长+(self.数据[编号].力量+self.数据[编号].进阶属性.力量+self.数据[编号].统御属性.力量)*0.4+(self.数据[编号].体质+self.数据[编号].进阶属性.体质+self.数据[编号].统御属性.体质)*0.3+(self.数据[编号].耐力+self.数据[编号].进阶属性.耐力+self.数据[编号].统御属性.耐力)*0.2) + self.数据[编号].装备属性.灵力
  if  self.数据[编号].等级 <= 185 then
    self.数据[编号].最大经验 = self:取经验(2,self.数据[编号].等级)
  end
  if self.数据[编号].内丹 ~= nil then
  for i=1,#self.数据[编号].内丹 do
    if self.数据[编号].内丹[i].技能=="迅敏" then
        self.数据[编号].伤害=self.数据[编号].内丹[i].等级*20+self.数据[编号].伤害
        self.数据[编号].速度=self.数据[编号].内丹[i].等级*10+self.数据[编号].速度
      end
      if self.数据[编号].内丹[i].技能=="静岳" then
        self.数据[编号].灵力=self.数据[编号].内丹[i].等级*32+self.数据[编号].灵力
        self.数据[编号].最大气血=self.数据[编号].内丹[i].等级*80+self.数据[编号].最大气血
      end
      if self.数据[编号].内丹[i].技能=="矫健" then
        self.数据[编号].最大气血=self.数据[编号].内丹[i].等级*120+self.数据[编号].最大气血
        self.数据[编号].速度=self.数据[编号].内丹[i].等级*15+self.数据[编号].速度
      end
      if self.数据[编号].内丹[i].技能=="玄武躯" then
        self.数据[编号].最大气血=self.数据[编号].内丹[i].等级*30+self.数据[编号].最大气血
      end
      if self.数据[编号].内丹[i].技能=="龙胄铠" then
        self.数据[编号].防御=self.数据[编号].内丹[i].等级*20+self.数据[编号].防御
      end
    end
  end
  if 是否 == "1" then
    self.数据[编号].气血 = self.数据[编号].最大气血
    self.数据[编号].魔法 = self.数据[编号].最大魔法
  end
  if self.数据[编号].气血 > self.数据[编号].最大气血 then
    self.数据[编号].气血 = self.数据[编号].最大气血
  end
  if self.数据[编号].魔法 > self.数据[编号].最大魔法 then
    self.数据[编号].魔法 = self.数据[编号].最大魔法
  end
  if self:取指定技能(编号,"高级隐身") then
    self.数据[编号].伤害=self.数据[编号].伤害-math.floor(self.数据[编号].伤害*0.2)
  elseif self:取指定技能(编号,"隐身") then
    self.数据[编号].伤害=self.数据[编号].伤害-math.floor(self.数据[编号].伤害*0.2)
  end
  if self:取指定技能(编号,"高级强力") then
    self.数据[编号].伤害=self.数据[编号].伤害+math.floor(self.数据[编号].等级*0.715)
  elseif self:取指定技能(编号,"强力") then
    self.数据[编号].伤害=self.数据[编号].伤害+math.floor(self.数据[编号].等级*0.52)
  end
  if self:取指定技能(编号,"高级防御") then
    self.数据[编号].防御=self.数据[编号].防御+math.floor(self.数据[编号].等级*0.8)
  elseif self:取指定技能(编号,"防御") then
    self.数据[编号].防御=self.数据[编号].防御+math.floor(self.数据[编号].等级*0.6)
  end
  if self:取指定技能(编号,"高级敏捷") then
    self.数据[编号].速度=self.数据[编号].速度+math.floor(self.数据[编号].速度*0.1)
  elseif self:取指定技能(编号,"敏捷") then
    self.数据[编号].速度=self.数据[编号].速度+math.floor(self.数据[编号].速度*0.2)
  end
  if self:取指定技能(编号,"迟钝") then
    self.数据[编号].速度=self.数据[编号].速度-math.floor(self.数据[编号].速度*0.2)
  end

end

function 召唤兽处理类:穿戴装备(装备,格子,编号)
  if 装备.气血 ~= nil then
    self.数据[编号].装备属性.气血 = self.数据[编号].装备属性.气血 + (装备.气血 or 0)
  end
  if 装备.魔法 ~= nil then
    self.数据[编号].装备属性.魔法 = self.数据[编号].装备属性.魔法 + (装备.魔法 or 0)
  end
  if 装备.命中 ~= nil then
    self.数据[编号].装备属性.命中 = self.数据[编号].装备属性.命中 + (装备.命中 or 0)
  end
  if 装备.伤害 ~= nil then
    self.数据[编号].装备属性.伤害 = self.数据[编号].装备属性.伤害 + (装备.伤害 or 0)
  end
  if 装备.防御 ~= nil then
    self.数据[编号].装备属性.防御 = self.数据[编号].装备属性.防御 + (装备.防御 or 0)
  end
  if 装备.速度 ~= nil then
    self.数据[编号].装备属性.速度 = self.数据[编号].装备属性.速度 + (装备.速度 or 0)
  end
  if 装备.躲避 ~= nil then
    self.数据[编号].装备属性.躲避 = self.数据[编号].装备属性.躲避 + (装备.躲避 or 0)
  end
  if 装备.灵力 ~= nil then
    self.数据[编号].装备属性.灵力 = self.数据[编号].装备属性.灵力 + (装备.灵力 or 0)
  end
  if 装备.体质 ~= nil then
    self.数据[编号].装备属性.体质 = self.数据[编号].装备属性.体质 + (装备.体质 or 0)
    self.数据[编号].装备属性.气血 = self.数据[编号].装备属性.气血 + (装备.体质 or 0)*5
  end
  if 装备.魔力 ~= nil then
    self.数据[编号].装备属性.魔力 = self.数据[编号].装备属性.魔力 + (装备.魔力 or 0)
    self.数据[编号].装备属性.魔法 = self.数据[编号].装备属性.魔法 + (装备.魔力 or 0)*5
    self.数据[编号].装备属性.灵力 = self.数据[编号].装备属性.灵力 + floor(((装备.魔力 or 0)*1.5))
  end
  if 装备.力量 ~= nil then
    self.数据[编号].装备属性.力量 = self.数据[编号].装备属性.力量 + (装备.力量 or 0)
    self.数据[编号].装备属性.伤害 = self.数据[编号].装备属性.伤害 + floor(((装备.力量 or 0)*3.5))
  end
  if 装备.耐力 ~= nil then
    self.数据[编号].装备属性.耐力 = self.数据[编号].装备属性.耐力 + (装备.耐力 or 0)
    self.数据[编号].装备属性.防御 = self.数据[编号].装备属性.防御 + floor(((装备.耐力 or 0)*2.3))
  end
  if 装备.敏捷 ~= nil then
    self.数据[编号].装备属性.敏捷 = self.数据[编号].装备属性.敏捷 + (装备.敏捷 or 0)
    self.数据[编号].装备属性.速度 = self.数据[编号].装备属性.速度 + floor(((装备.敏捷 or 0)*2.3))
  end
  self.数据[编号].装备[格子] = 装备
  if 装备.套装效果 ~= nil then
    local sl = {}
    local ab = true
    self.数据[编号].套装 = self.数据[编号].套装 or {}
    for i=1,#self.数据[编号].套装 do
      if self.数据[编号].套装[i][1] == 装备.套装效果[1] and self.数据[编号].套装[i][2] == 装备.套装效果[2] then
        local abc = false
        local abd = true
        for s=1,#self.数据[编号].套装[i][4] do
          if self.数据[编号].套装[i][4][s] == 格子 then
              abd = false
              break
          end
        end
        if abd then
          insert(self.数据[编号].套装[i][4],格子)
          abc = true
        end
        if abc then
          self.数据[编号].套装[i][3] = (self.数据[编号].套装[i][3] or 0) + 1
        end
        ab = false
        break
      end
    end
    if ab then
      insert(self.数据[编号].套装,{装备.套装效果[1],装备.套装效果[2],1,{格子}})
    end
  end
  self:刷新信息(编号)
end

function 召唤兽处理类:卸下装备(装备,格子,编号)
  if 装备.气血 ~= nil then
    self.数据[编号].装备属性.气血 = self.数据[编号].装备属性.气血 - (装备.气血 or 0)
  end
  if 装备.魔法 ~= nil then
    self.数据[编号].装备属性.魔法 = self.数据[编号].装备属性.魔法 - (装备.魔法 or 0)
  end
  if 装备.命中 ~= nil then
    self.数据[编号].装备属性.命中 = self.数据[编号].装备属性.命中 - (装备.命中 or 0)
  end
  if 装备.伤害 ~= nil then
    self.数据[编号].装备属性.伤害 = self.数据[编号].装备属性.伤害 - (装备.伤害 or 0)
  end
  if 装备.防御 ~= nil then
    self.数据[编号].装备属性.防御 = self.数据[编号].装备属性.防御 - (装备.防御 or 0)
  end
  if 装备.速度 ~= nil then
    self.数据[编号].装备属性.速度 = self.数据[编号].装备属性.速度 - (装备.速度 or 0)
  end
  if 装备.躲避 ~= nil then
    self.数据[编号].装备属性.躲避 = self.数据[编号].装备属性.躲避 - (装备.躲避 or 0)
  end
  if 装备.灵力 ~= nil then
    self.数据[编号].装备属性.灵力 = self.数据[编号].装备属性.灵力 - (装备.灵力 or 0)
  end
  if 装备.体质 ~= nil then
    self.数据[编号].装备属性.体质 = self.数据[编号].装备属性.体质 - (装备.体质 or 0)
    self.数据[编号].装备属性.气血 = self.数据[编号].装备属性.气血 - (装备.体质 or 0)*5
  end
  if 装备.魔力 ~= nil then
    self.数据[编号].装备属性.魔力 = self.数据[编号].装备属性.魔力 - (装备.魔力 or 0)
    self.数据[编号].装备属性.魔法 = self.数据[编号].装备属性.魔法 - (装备.魔力 or 0)*5
    self.数据[编号].装备属性.灵力 = self.数据[编号].装备属性.灵力 - floor(((装备.魔力 or 0)*1.5))
  end
  if 装备.力量 ~= nil then
    self.数据[编号].装备属性.力量 = self.数据[编号].装备属性.力量 - (装备.力量 or 0)
    self.数据[编号].装备属性.伤害 = self.数据[编号].装备属性.伤害 - floor(((装备.力量 or 0)*3.5))
  end
  if 装备.耐力 ~= nil then
    self.数据[编号].装备属性.耐力 = self.数据[编号].装备属性.耐力 - (装备.耐力 or 0)
    self.数据[编号].装备属性.防御 = self.数据[编号].装备属性.防御 - floor(((装备.耐力 or 0)*2.3))
  end
  if 装备.敏捷 ~= nil then
    self.数据[编号].装备属性.敏捷 = self.数据[编号].装备属性.敏捷 - (装备.敏捷 or 0)
    self.数据[编号].装备属性.速度 = self.数据[编号].装备属性.速度 - floor(((装备.敏捷 or 0)*2.3))
  end
  if 装备.套装效果 ~= nil then
    local sl = {}
    local ab = false
    self.数据[编号].套装 = self.数据[编号].套装 or {}
    for i=1,#self.数据[编号].套装 do
      if self.数据[编号].套装[i][1] == 装备.套装效果[1] and self.数据[编号].套装[i][2] == 装备.套装效果[2] then
        local abc = false
        local abd = true
        for s=1,#self.数据[编号].套装[i][4] do
          if self.数据[编号].套装[i][4][s] == 格子 then
            abd = true
            break
          end
        end
        if abd then
          remove(self.数据[编号].套装[i][4],格子)
          abc = true
        end
        if abc then
          self.数据[编号].套装[i][3] = (self.数据[编号].套装[i][3] or 0) - 1
        end
        if self.数据[编号].套装[i][3]==0 then
          ab = true
          break
        end
      end
    end
    if ab then
      self.数据[编号].套装={}
    end
  end
  self:刷新信息(编号)
end

function 召唤兽处理类:重置等级(等级,编号)
  for n=1,5 do
    self.数据[编号][属性范围[n]]=self.数据[编号][属性范围[n]]+等级
  end
  self.数据[编号].潜力=等级*5+self.数据[编号].灵性*2
  self.数据[编号].等级=等级
  self:刷新信息(编号,"1")
end

function 召唤兽处理类:取指定技能(编号,名称)
  for n=1,#self.数据[编号].技能 do
    if self.数据[编号].技能[n]==名称 then
      return true
    end
  end
  return false
end


function 召唤兽处理类:取存档数据(编号)
  if 编号 ~= nil then
    return self.数据[编号]
  end
  return self.数据
end

function 召唤兽处理类:获取指定数据(编号)
  return table.tostring(self.数据[编号])
end

function 召唤兽处理类:放生处理(连接id,序号,id,点数)
  local 临时编号=self:取编号(点数.序列)
  if 临时编号==0 then
    常规提示(id,"你没有这只召唤兽")
    return
  elseif self:是否有装备(临时编号) then
    常规提示(id,"请先卸下召唤兽所穿戴的装备")
    return
  elseif  self.数据[临时编号].统御 ~= nil then
    常规提示(id,"该召唤兽处于统御状态,请解除统御后再进行此操作")
    return
  else--先判断是否有bb装备
    --       self.数据[临时编号]=nil
    table.remove(self.数据,临时编号) --先抹去参战信息
    if 点数.序列==玩家数据[id].角色.数据.参战宝宝.认证码 then
      玩家数据[id].角色.数据.参战宝宝={}
      发送数据(连接id,18,玩家数据[id].角色.数据.参战宝宝)
    end
    常规提示(id,"你的这只召唤兽从你的眼前消失了~~")
    发送数据(连接id,21,临时编号)
  end
end

function 召唤兽处理类:删除处理(id,临时编号)
  --local 临时编号=self:取编号(点数.序列)
  if 临时编号==0 then
    常规提示(id,"你没有这只召唤兽")
    return
  else--先判断是否有bb装备
    --       self.数据[临时编号]=nil
    if self.数据[临时编号].认证码==玩家数据[id].角色.数据.参战宝宝.认证码 then
      玩家数据[id].角色.数据.参战宝宝={}
      发送数据(玩家数据[id].连接id,18,玩家数据[id].角色.数据.参战宝宝)
    end
    table.remove(self.数据,临时编号)--先抹去参战信息
    发送数据(玩家数据[id].连接id,45,临时编号)
  end
end

function 召唤兽处理类:是否有装备(编号)
  if self.数据[编号]==nil then
    return false
  end
  for n=1,3 do
    if  self.数据[编号].装备[n]~=nil then
      return true
    end
  end
  return false
end

function 召唤兽处理类:是否有统御()
  for i=1,#self.数据 do
    if self.数据[i].统御 ~= nil then
      return true
    end
  end
  return false
end

function 召唤兽处理类:耐久处理(id,认证码)
  local 编号 = self:取编号(认证码)
  if self:是否有装备(编号) then
    for n=1,3 do
      if self.数据[编号].装备[n]~=nil and self.数据[编号].装备[n].耐久~=nil then
        self.数据[编号].装备[n].耐久 = self.数据[编号].装备[n].耐久 - 0.0125
        if self.数据[编号].装备[n].耐久 <= 0 then
            self.数据[编号].装备[n].耐久 = 0
            发送数据(玩家数据[id].连接id,7,"#y/你的#r/"..self.数据[编号].装备[n].名称.."#y/因耐久度过低已无法使用")
        end
      end
    end
  end
end

function 召唤兽处理类:取气血差()
  local 数值=0
  for n=1,#self.数据 do
    数值=数值+(self.数据[n].最大气血-self.数据[n].气血)
  end
  return 数值
end

function 召唤兽处理类:取魔法差()
  local 数值=0
  for n=1,#self.数据 do
    数值=数值+(self.数据[n].最大魔法-self.数据[n].魔法)
  end
  return 数值
end

function 召唤兽处理类:取忠诚差()
  local 数值=0
  for n=1,#self.数据 do
    数值=数值+(100-self.数据[n].忠诚)
  end
  return 数值
end

function 召唤兽处理类:合宠处理(连接id,序号,id,内容)
  local bb1=内容.序列
  local bb2=内容.序列1
  local 随机类型=""
  if self.数据[bb1]==nil or self.数据[bb2]==nil then
    return
  elseif self.数据[bb1].等级<30 or self.数据[bb2].等级<30 then
    常规提示(id,"要炼妖的召唤兽等级未达到30级!")
    return
  elseif self.数据[bb1].种类=="神兽" or self.数据[bb2].种类=="神兽" then
    常规提示(id,"神兽不可进行此操作")
    return
  elseif 玩家数据[id].角色.数据.参战信息~=nil then
    常规提示(id,"请先取消所有召唤兽的参战状态")
    return
  elseif self:是否有装备(bb1) or self:是否有装备(bb2) then
    常规提示(id,"请先卸下召唤兽所穿戴的装备")
    return
  elseif  self.数据[bb1].统御 ~= nil or self.数据[bb2].统御 ~= nil  then
    常规提示(id,"召唤兽处于统御状态,请解除统御后再进行此操作")
    return
  elseif  self.数据[bb1].进阶 or  self.数据[bb2].进阶 then
    常规提示(id,"进阶的召唤兽无法进行此操作")
    return
  else
    --检查装备 等级
    if self.数据[bb1].神兽 or self.数据[bb2].神兽 then
      return
    end
    随机类型=self.数据[bb1].模型
    local 随机数值=取随机数()
    local 特殊合宠=false
    if 随机数值<=2 then
      特殊合宠=true
      随机类型="泡泡"
    elseif 随机数值<=5 then
      特殊合宠=true
      随机类型="大海龟"
    elseif 随机数值<=20 then
      随机类型=self.数据[bb2].模型
    else
      随机类型=self.数据[bb1].模型
    end
    if 特殊合宠 then
      self:添加召唤兽(随机类型,"宝宝",false,false,0,nil,bb1)
    else
      self.数据[bb1].模型=随机类型
      local a=0
      local b=0
      for n=1,#资质范围 do
        if self.数据[bb1][资质范围[n]]>self.数据[bb2][资质范围[n]] then
          a=self.数据[bb1][资质范围[n]]
          b=self.数据[bb2][资质范围[n]]
        else
          a=self.数据[bb2][资质范围[n]]
          b=self.数据[bb1][资质范围[n]]
        end
        self.数据[bb1][资质范围[n]] =math.floor(取随机数(a*1000,b*1000)/1000)
      end
      --计算成长
      if self.数据[bb1].成长>self.数据[bb2].成长 then
        a=self.数据[bb1].成长
        b=self.数据[bb2].成长
      else
        a=self.数据[bb2].成长
        b=self.数据[bb1].成长
      end
      self.数据[bb2].成长=取随机小数(a,b)
     --计算技能
      local 技能表={}
      for n=1,#self.数据[bb2].技能 do
        技能表[#技能表+1]=self.数据[bb2].技能[n]
      end
      for n=1,#self.数据[bb1].技能 do
        技能表[#技能表+1]=self.数据[bb1].技能[n]
      end
      技能表=删除重复(技能表)
      for n=1,#技能表 do
        技能表[n]={名称=技能表[n],排列=取随机数(1,10000)}
      end
      table.sort(技能表,function(a,b) return a.排列>b.排列 end )
      local 技能总数=取随机数(1,#技能表)
      self.数据[bb1].技能={}
      if 技能表~={} then
        for n=1,技能总数 do
          local 成功几率=100-#self.数据[bb1].技能*5
          if 取随机数()<=成功几率 then
            self.数据[bb1].技能[#self.数据[bb1].技能+1]=技能表[n].名称
          end
        end
      end
      --计算等级
      local 等级总数=math.floor(((self.数据[bb1].等级+self.数据[bb2].等级)/2*0.5))
      if 等级总数<0 then
        等级总数=0
      end
      self.数据[bb1].等级=等级总数
      self.数据[bb1].当前经验=0
      self.数据[bb1].最大经验=self:取经验(2,self.数据[bb1].等级)
      --计算属性点
      local 生成类型=""
      local 随机点数=""
      local 种类="野怪"
      if self.数据[bb1].种类=="变异" and self.数据[bb2].种类=="变异" then
        种类="变异"
      elseif self.数据[bb1].种类=="宝宝" and self.数据[bb2].种类=="宝宝" then
        种类="宝宝"
      elseif self.数据[bb1].种类=="宝宝" and self.数据[bb2].种类=="变异" or self.数据[bb1].种类=="变异" and self.数据[bb2].种类=="宝宝" then
        if 取随机数()<=50 then
            种类="宝宝"
        else
            种类="变异"
        end
      end
      self.数据[bb1].种类=种类
      if  self.数据[bb1].种类~="野怪" then
        for n=1,#属性范围 do
          if self.数据[bb1].种类 == "变异" then
              self.数据[bb1][属性范围[n]]=self.数据[bb1].等级+15
          else
              self.数据[bb1][属性范围[n]]=self.数据[bb1].等级+10
          end
          self.数据[bb1].潜力=self.数据[bb1].等级*5
        end
      else
        self.数据[bb1].潜力=0
        for n=1,#属性范围 do
          self.数据[bb1][属性范围[n]]=self.数据[bb1].等级+10
        end
        if self.数据[bb1].等级~=0 then
          for n=1,self.数据[bb1].等级*10 do
            随机点数=属性范围[取随机数(1,#属性范围)]
            self.数据[bb1][随机点数]=self.数据[bb1][随机点数]+1
          end
        end
      end
    end
    self.数据[bb1].饰品 = nil
    self.数据[bb1].饰品2 = nil
    self.数据[bb1].寿命= 取随机数(4000,7000)
    self.数据[bb1].自动指令=nil
    self.数据[bb1].名称=self.数据[bb1].模型
    local mx参战等级 =bbs(self.数据[bb1].模型)
    self.数据[bb1].参战等级 = mx参战等级[1]
    table.remove(self.数据,bb2)
    常规提示(id,"恭喜你合出了一只#R/"..随机类型)
    发送数据(连接id,16,self.数据)
    发送数据(连接id,26)
  end
end

function 召唤兽处理类:取野外等级差(地图等级,玩家等级)
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

function 召唤兽处理类:获得经验(认证码,经验,id,类型,地图等级)
  local 编号=self:取编号(认证码)
  if 编号==0 or self.数据[编号]==nil then return  end
  if self.数据[编号].等级>=玩家数据[id].角色.数据.等级+5 then
    发送数据(玩家数据[id].连接id,38,{内容="你的召唤兽当前等级已经超过人物等级+5，目前已经无法再获得更多的经验了。"})
    return
  end
  local 临时经验=经验*0.4
  if 类型=="野外" then
    local 临时参数=self:取野外等级差(self.数据[编号].等级,地图等级)
    临时经验=临时经验*临时参数
  end
  local 倍率=服务端参数.经验获得率
  if 类型=="野外" or 类型=="捉鬼" or 类型=="官职" or 类型=="封妖战斗" or 类型=="种族" then
    if 玩家数据[id].角色:取任务(2)~=0 then
      倍率=倍率+1
    end
    if 玩家数据[id].角色:取任务(3)~=0 then
      倍率=倍率+1
    end
  end
  临时经验=math.floor(临时经验*倍率)
  self:添加经验(玩家数据[id].连接id,id,编号,临时经验)
end

function 召唤兽处理类:升级(编号,id)
  self.数据[编号].等级 = self.数据[编号].等级 + 1
  self.数据[编号].体质 = self.数据[编号].体质 + 1
  self.数据[编号].魔力 = self.数据[编号].魔力 + 1
  self.数据[编号].力量 = self.数据[编号].力量 + 1
  self.数据[编号].耐力 = self.数据[编号].耐力 + 1
  self.数据[编号].敏捷 = self.数据[编号].敏捷 + 1
  self.数据[编号].潜力 = self.数据[编号].潜力 + 5
  self.数据[编号].当前经验 = self.数据[编号].当前经验 - self.数据[编号].最大经验
  self:刷新信息(编号,"1")
end

function 召唤兽处理类:降级(级数,编号)
  self.数据[编号].等级 = self.数据[编号].等级 - 级数
    self.数据[编号].体质=0
    self.数据[编号].魔力=0
    self.数据[编号].力量=0
    self.数据[编号].耐力=0
    self.数据[编号].敏捷=0
    self.数据[编号].潜力=0
  if self.数据[编号].种类=="神兽" then
      self.数据[编号].体质=self.数据[编号].等级+20
      self.数据[编号].魔力=self.数据[编号].等级+20
      self.数据[编号].力量=self.数据[编号].等级+20
      self.数据[编号].耐力=self.数据[编号].等级+20
      self.数据[编号].敏捷=self.数据[编号].等级+20
      self.数据[编号].潜力=self.数据[编号].等级*5+self.数据[编号].灵性*2
  elseif self.数据[编号].种类=="变异" then
      self.数据[编号].体质=self.数据[编号].等级+15
      self.数据[编号].魔力=self.数据[编号].等级+15
      self.数据[编号].力量=self.数据[编号].等级+15
      self.数据[编号].耐力=self.数据[编号].等级+15
      self.数据[编号].敏捷=self.数据[编号].等级+15
      self.数据[编号].潜力=self.数据[编号].等级*5+self.数据[编号].灵性*2
  elseif self.数据[编号].种类=="宝宝" then
      self.数据[编号].体质=self.数据[编号].等级+10
      self.数据[编号].魔力=self.数据[编号].等级+10
      self.数据[编号].力量=self.数据[编号].等级+10
      self.数据[编号].耐力=self.数据[编号].等级+10
      self.数据[编号].敏捷=self.数据[编号].等级+10
      self.数据[编号].潜力=self.数据[编号].等级*5+self.数据[编号].灵性*2
  end
  self:刷新信息(编号,"1")
end

function 召唤兽处理类:添加技能(名称,编号)
  self.数据[编号].技能[#self.数据[编号].技能+1] = 名称
end
function 召唤兽处理类:替换技能(名称,编号)
  self.数据[编号].技能[取随机数(1,#self.数据[编号].技能)] = 名称
end

function 召唤兽处理类:添加经验(连接id,id,编号,数额)
  if self.数据[编号].等级>180 then --
    return
  end
  if self.数据[编号].等级>=玩家数据[id].角色.数据.等级+10 then
    发送数据(玩家数据[id].连接id,38,{内容="你的召唤兽当前等级已经超过人物等级+10，目前已经无法再获得更多的经验了。"})
    return
  end
  local 实际数额=数额
  self.数据[编号].当前经验=self.数据[编号].当前经验+实际数额
  发送数据(连接id,27,{文本="#W/你的"..self.数据[编号].名称.."#W/获得了"..实际数额.."点经验",频道="xt"})
  while(self.数据[编号].当前经验>=self.数据[编号].最大经验) do
    if self.数据[编号].等级>=玩家数据[id].角色.数据.等级+9 then
      break
    end
    self:升级(编号,id)
    发送数据(连接id,27,{文本="#W/你的#R/"..self.数据[编号].名称.."#W/等级提升到了#R/"..self.数据[编号].等级.."#W/级",频道="xt"})
  end
  发送数据(连接id,20,self:取存档数据(编号))
  if self.数据[编号].认证码==玩家数据[id].角色.数据.参战宝宝.认证码 then
    玩家数据[id].角色.数据.参战宝宝={}
    玩家数据[id].角色.数据.参战宝宝=table.loadstring(table.tostring(self:取存档数据(编号)))
    玩家数据[id].角色.数据.参战信息=1
    self.数据[编号].参战信息=1
    发送数据(连接id,18,玩家数据[id].角色.数据.参战宝宝)
  end
end

function 召唤兽处理类:加寿命处理(编号,数额,中毒,连接id,id)
  self.数据[编号].寿命=self.数据[编号].寿命+数额
  常规提示(id,"该召唤兽寿命增加了#R/"..数额.."点")
  if 中毒~=nil and 中毒~=0 and 中毒>=取随机数() then
    local 减少类型=""
    local 减少数量=0
    local 随机参数=取随机数(1,6)
    if 随机参数==1 then
      减少类型="攻击资质"
      减少数量=取随机数(1,5)
    elseif 随机参数==2 then
      减少类型="防御资质"
      减少数量=取随机数(1,5)
    elseif 随机参数==3 then
      减少类型="体力资质"
      减少数量=取随机数(5,20)
    elseif 随机参数==4 then
      减少类型="法力资质"
      减少数量=取随机数(3,10)
    elseif 随机参数==5 then
      减少类型="躲闪资质"
      减少数量=取随机数(1,5)
    elseif 随机参数==6 then
      减少类型="速度资质"
      减少数量=取随机数(1,5)
    end
    self.数据[编号][减少类型]=self.数据[编号][减少类型]-减少数量
    常规提示(id,"#W/你的召唤兽出现了中毒现象从而导致#G/"..减少类型.."#W/减少了#R/"..减少数量.."#W/点")
  end
  发送数据(连接id,20,self:取存档数据(编号))
end

function 召唤兽处理类:加血处理(编号,数额,连接id,id)
  self.数据[编号].气血=self.数据[编号].气血+数额
  if self.数据[编号].气血>self.数据[编号].最大气血 then
    self.数据[编号].气血=self.数据[编号].最大气血
  end
  发送数据(连接id,20,self:取存档数据(编号))
  if self.数据[编号].认证码==玩家数据[id].角色.数据.参战宝宝.认证码 then
    玩家数据[id].角色.数据.参战宝宝={}
    玩家数据[id].角色.数据.参战宝宝=table.loadstring(table.tostring(self:取存档数据(编号)))
    玩家数据[id].角色.数据.参战信息=1
    self.数据[编号].参战信息=1
    发送数据(连接id,18,玩家数据[id].角色.数据.参战宝宝)
  end
end

function 召唤兽处理类:加蓝处理(编号,数额,连接id,id)
  self.数据[编号].魔法=self.数据[编号].魔法+数额
  if self.数据[编号].魔法>self.数据[编号].最大魔法 then
    self.数据[编号].魔法=self.数据[编号].最大魔法
  end
  发送数据(连接id,20,self:取存档数据(编号))
  if self.数据[编号].认证码==玩家数据[id].角色.数据.参战宝宝.认证码 then
    玩家数据[id].角色.数据.参战宝宝={}
    玩家数据[id].角色.数据.参战宝宝=table.loadstring(table.tostring(self:取存档数据(编号)))
    玩家数据[id].角色.数据.参战信息=1
    self.数据[编号].参战信息=1
    发送数据(连接id,18,玩家数据[id].角色.数据.参战宝宝)
  end
end

function 召唤兽处理类:召唤兽染色(连接id,序号,id,内容)
  local 编号=self:取编号(内容.序列)
  local 染色银子消耗 = 100000000
  if 取银子(id) < 染色银子消耗 then
      常规提示(id,"你身上的银子不够染色哦，染色一次需要花费2亿的银两")
      return
  end
  玩家数据[id].角色:扣除银子(染色银子消耗,0,0,"召唤兽染色",1)
  if self.数据[编号].染色方案==nil then
      self.数据[编号].染色方案=0
  end
  if self.数据[编号].染色组==nil then
      self.数据[编号].染色组={}
  end
  self.数据[编号].染色方案 = 内容.序列1
  self.数据[编号].染色组={}
  self.数据[编号].染色组[1] = 内容.序列2
  self.数据[编号].染色组[2] = 内容.序列3
  self.数据[编号].染色组[3] = 内容.序列4
  常规提示(id,"#Y恭喜你，召唤兽染色成功！换个颜色换个心情")
  发送数据(连接id,16,self.数据)
  发送数据(连接id,20,self:取存档数据(编号))
end

function 召唤兽处理类:商会购买召唤兽处理(连接id,序号,id,内容)
  local 购买商会召唤兽价格=内容.价格
  if #self.数据 >= 7 then
    常规提示(id,"#Y您当前无法携带更多的召唤兽了")
    return
  end
  if 取银子(id) < 购买商会召唤兽价格 then
    常规提示(id,"你身上的银子不够购买召唤兽")
    return
  end
  玩家数据[id].角色:扣除银子(购买商会召唤兽价格,0,0,"商会购买召唤兽",1)
  self:添加召唤兽(内容.名称,"野怪",nil,nil,内容.等级,nil,nil,nil)
  常规提示(id,"#Y恭喜你，商会购买召唤兽成功！")
end

function 召唤兽处理类:炼化处理(连接id,序号,id,内容)
  local 物品=内容.序列
  local bb=内容.序列1
  local 物品名称=玩家数据[id].道具.数据[玩家数据[id].角色.数据.道具[物品]].名称
  if 物品名称==nil or self.数据[bb]==nil  then
    return
  elseif self.数据[bb].参战信息~=nil then
    常规提示(id,"请先取消召唤兽的参战状态")
    return
  elseif 物品名称~="炼妖石" then
    常规提示(id,"炼化的物品必须为炼妖石")
    return
  else--检查银子和体力
    local 临时等级=玩家数据[id].道具.数据[玩家数据[id].角色.数据.道具[物品]].级别限制
    local 临时灵气=math.floor(self.数据[bb].等级/10)
    local 成功几率=25+math.floor(self.数据[bb].等级/10)
    if self.数据[bb].种类=="宝宝" then
      成功几率=成功几率*2
    end
    if 成功几率>=取随机数() then
      玩家数据[id].道具.数据[玩家数据[id].角色.数据.道具[物品]].名称="天眼珠"
      玩家数据[id].道具.数据[玩家数据[id].角色.数据.道具[物品]].灵气=临时灵气+取随机数(20,80)
      玩家数据[id].道具.数据[玩家数据[id].角色.数据.道具[物品]].分类=11
      if 玩家数据[id].道具.数据[玩家数据[id].角色.数据.道具[物品]].灵气>100 then
        玩家数据[id].道具.数据[玩家数据[id].角色.数据.道具[物品]].灵气=100
      end
      常规提示(id,"炼化成功！")
    else
      常规提示(id,"很遗憾，本次炼化失败了！！！")
    end
    table.remove(self.数据,bb)
    发送数据(连接id,16,self.数据)
    发送数据(连接id,24,玩家数据[id].道具:索要道具2(id))
    发送数据(连接id,3699)
    发送数据(连接id,26)
  end
end

function 召唤兽处理类:进阶造型处理(id)
  local 参战召唤兽 = 0
  for i=1,#玩家数据[id].召唤兽.数据 do
    if 玩家数据[id].召唤兽.数据[i].参战信息 ~=nil then
        参战召唤兽 = i
    end
  end
  if 参战召唤兽==0 then
      常规提示(id,"请先将要更改造型的召唤兽设置为参战！")
      return
  elseif 玩家数据[id].召唤兽.数据[参战召唤兽].灵性 < 50 then
      常规提示(id,"该召唤兽没有达到更改造型的要求")
      return
  elseif 玩家数据[id].召唤兽.数据[参战召唤兽].进阶 then
      常规提示(id,"该召唤兽已经改变造型了，你是来寻我开心的吗？")
      return
  end
  玩家数据[id].召唤兽.数据[参战召唤兽].模型 = "进阶"..玩家数据[id].召唤兽.数据[参战召唤兽].模型
  玩家数据[id].召唤兽.数据[参战召唤兽].名称 = 玩家数据[id].召唤兽.数据[参战召唤兽].模型
  玩家数据[id].召唤兽.数据[参战召唤兽].进阶 = true
  常规提示(id,"恭喜你，该召唤兽更改为新的造型了")
end

function 召唤兽处理类:洗练处理(连接id,序号,id,内容)
  local 物品=内容.序列
  local bb=内容.序列1
  if 玩家数据[id].角色.数据.道具[物品] == nil then
      常规提示(id,"该物品不存在，炼妖时请不要移动物品")
      return
  end
  local 物品名称=玩家数据[id].道具.数据[玩家数据[id].角色.数据.道具[物品]].名称
  local 携带技能 = 玩家数据[id].道具.数据[玩家数据[id].角色.数据.道具[物品]].附带技能
  local 格子编号=0
  if 物品名称==nil or self.数据[bb]==nil  then
    return
  elseif 物品名称=="金柳露" or 物品名称=="超级金柳露" then
    if 物品名称=="金柳露" and self.数据[bb].变异 then
      常规提示(id,"金柳露不用作用于这种召唤兽身上")
      return
    elseif 物品名称=="超级金柳露" and self.数据[bb].变异==nil then
      常规提示(id,"超级金柳露不用作用于这种召唤兽身上")
      return
    elseif self.数据[bb].种类=="神兽" then
      常规提示(id,"金柳露不用作用于神兽身上")
      return
    elseif self.数据[bb].进阶 then
      常规提示(id,"金柳露不用作用于进阶召唤兽身上")
      return
    elseif self:是否有装备(bb) then
      常规提示(id,"请先卸下召唤兽所穿戴的装备")
      return
    elseif  self.数据[bb].统御 ~= nil then
      常规提示(id,"该召唤兽处于统御状态,请解除统御后再进行此操作")
      return
    elseif self.数据[bb].内丹.可用内丹 == 0 then
      常规提示(id,"有内丹的召唤兽无法使用")
      return
    end
    local 变异=false
    if 物品名称=="金柳露" and 取随机数()<=10 then
        变异=true
        常规提示(id,"恭喜你，该召唤兽发生了变异")
    elseif 物品名称=="超级金柳露" then
        变异=true
    end
    self:添加召唤兽(self.数据[bb].模型,true,变异,false,0,nil,bb)
    self.数据[bb].当前经验=0
    玩家数据[id].道具.数据[玩家数据[id].角色.数据.道具[物品]]=nil
    玩家数据[id].角色.数据.道具[物品]=nil
    发送数据(连接id,16,self.数据)
    发送数据(连接id,24,玩家数据[id].道具:索要道具2(id))
    发送数据(连接id,25)
    发送数据(连接id,3699)
    常规提示(id,"使用"..物品名称.."成功")
    return
  elseif 物品名称=="魔兽要诀" or 物品名称=="高级魔兽要诀" then--打书
    self.数据[bb].自动指令=nil
    local 技能重复 = 0
    if self.数据[bb].技能==nil or self.数据[bb].技能==0 then
        self.数据[bb].技能[1]=携带技能
    end
    for n=1,#self.数据[bb].技能 do
      if self.数据[bb].技能[n] == 携带技能 then
          技能重复 = n
      end
    end
    if 技能重复 == 0 then
      if self:打书概率(#self.数据[bb].技能) then
        格子编号=#self.数据[bb].技能+1
        常规提示(id,"你的这只召唤兽学会了新技能#R/"..携带技能)
      else
        格子编号=取随机数(1,#self.数据[bb].技能)
        常规提示(id,"你的这只召唤兽学会了新技能#R/"..携带技能.."#Y/ 但是遗忘了#R/ "..self.数据[bb].技能[格子编号])
      end
      self.数据[bb].技能[格子编号]=携带技能
      玩家数据[id].道具.数据[玩家数据[id].角色.数据.道具[物品]]=nil
      玩家数据[id].角色.数据.道具[物品]=nil
      发送数据(连接id,16,self.数据)
      发送数据(连接id,24,玩家数据[id].道具:索要道具2(id))
      发送数据(连接id,25)
      发送数据(连接id,3699)
    else
      常规提示(id,"你的这只召唤兽已学会该技能,无法再学习")
    end
  elseif 物品名称 == "吸附石" then
    if #self.数据[bb].技能<=0 then
      常规提示(id,"该召唤兽身上无可吸附技能")
      return
    end
    local 获得几率=取随机数()
    if 获得几率>=80 then
      常规提示(id,"很遗憾，吸附失败！")
      常规提示(id,"你的这只召唤兽从你的眼前消失了~~")
    else
      local 随机技能=self.数据[bb].技能[取随机数(1,#self.数据[bb].技能)]
      玩家数据[id].道具:给予道具(id,"点化石",1,随机技能)
      常规提示(id,"#Y你成功的从召唤兽身上吸取到#R"..随机技能.."#Y技能")
    end
    local 验证码 = self.数据[bb].认证码
    table.remove(self.数据,bb) --先抹去参战信息
    if 验证码==玩家数据[id].角色.数据.参战宝宝.认证码 then
      玩家数据[id].角色.数据.参战宝宝={}
      发送数据(连接id,18,玩家数据[id].角色.数据.参战宝宝)
    end
    玩家数据[id].道具.数据[玩家数据[id].角色.数据.道具[物品]]=nil
    玩家数据[id].角色.数据.道具[物品]=nil
    发送数据(连接id,16,self.数据)
    发送数据(连接id,24,玩家数据[id].道具:索要道具2(id))
    发送数据(连接id,25)
    发送数据(连接id,3699)
  elseif 物品名称 == "召唤兽内丹" or 物品名称 == "高级召唤兽内丹" then
    self.数据[bb].自动指令 = nil
    local 内丹属性 = self.数据[bb].内丹
    if #内丹属性 >= 1 then
        for n=1,#内丹属性 do
          if 内丹属性[n].技能 == 携带技能 then
            if 内丹属性[n].等级 == 5 then
                常规提示(id,"该内丹已学满")
                return
            else
                self.数据[bb].内丹[n].等级 = self.数据[bb].内丹[n].等级 + 1
                玩家数据[id].角色.数据.道具[物品]=nil
                常规提示(id,"恭喜你的"..self.数据[bb].名称.."#R/"..内丹属性[n].技能.."#Y/升到第#R/"..self.数据[bb].内丹[n].等级.."#Y/层")
                self:刷新信息(bb)
                发送数据(连接id,24,玩家数据[id].道具:索要道具2(id))
                发送数据(连接id,25)
                发送数据(连接id,3699)
                return
            end
          elseif 内丹属性[n+1] == nil then
            if 内丹属性.可用内丹 > 0 then
                self.数据[bb].内丹[n+1] = {}
                self.数据[bb].内丹[n+1].技能 = 携带技能
                self.数据[bb].内丹[n+1].等级 = 1
                self.数据[bb].内丹.可用内丹 = self.数据[bb].内丹.可用内丹 - 1
                玩家数据[id].角色.数据.道具[物品]=nil
                常规提示(id,"恭喜你的"..self.数据[bb].名称.."学会了#R/"..携带技能)
                self:刷新信息(bb)
                发送数据(连接id,24,玩家数据[id].道具:索要道具2(id))
                发送数据(连接id,25)
                发送数据(连接id,3699)
            else
              self.随机位置 = 取随机数(1,#self.数据[bb].内丹)
              if 携带技能 ~= 内丹属性[n].技能 then
                常规提示(id,"你的召唤兽"..self.数据[bb].名称.."遗忘了#R/"..self.数据[bb].内丹[self.随机位置].技能)
                self.数据[bb].内丹[self.随机位置] = {}
                self.数据[bb].内丹[self.随机位置].技能 = 携带技能
                self.数据[bb].内丹[self.随机位置].等级 = 1
                玩家数据[id].角色.数据.道具[物品]=nil
                常规提示(id,"恭喜你的"..self.数据[bb].名称.."学会了#R/"..携带技能)
                self:刷新信息(bb)
                发送数据(连接id,24,玩家数据[id].道具:索要道具2(id))
                发送数据(连接id,25)
                发送数据(连接id,3699)
              else
                if self.数据[bb].内丹[self.随机位置].等级 == 5 then
                  常规提示(id,"该内丹已学满")
                  return
                else
                  self.数据[bb].内丹[self.随机位置].等级 = self.数据[bb].内丹[self.随机位置].等级 + 1
                  玩家数据[id].角色.数据.道具[物品]=nil
                  常规提示(id,"恭喜你的"..self.数据[bb].名称.."#R/"..self.数据[bb].内丹[self.随机位置].技能.."#Y/升到第#R/"..self.数据[bb].内丹[self.随机位置].等级.."#Y/层")
                  self:刷新信息(bb)
                  发送数据(连接id,24,玩家数据[id].道具:索要道具2(id))
                  发送数据(连接id,25)
                  发送数据(连接id,3699)
                  return
                end
              end
            end
          end
        end
    else
        self.数据[bb].内丹[1] = {}
        self.数据[bb].内丹[1].技能 = 携带技能
        self.数据[bb].内丹[1].等级 = 1
        self.数据[bb].内丹.可用内丹 = self.数据[bb].内丹.可用内丹 - 1
        玩家数据[id].角色.数据.道具[物品]=nil
        常规提示(id,"恭喜你的"..self.数据[bb].名称.."学会了#R/"..携带技能)
        self:刷新信息(bb)
        发送数据(连接id,24,玩家数据[id].道具:索要道具2(id))
        发送数据(连接id,25)
        发送数据(连接id,3699)
    end
  end
end

function 召唤兽处理类:法术认证(连接id,id)
  if 玩家数据[id].角色.数据.参战信息==nil then
    常规提示(id,"请将要法术认证的召唤兽参战")
    return
  end
  local 认证法术={}
  local 临时选项={}
  for n=1,#self.数据 do
    if self.数据[n].参战信息 ~= nil and #self.数据[n].技能~=nil then
      if self:是否有装备(n) then
        常规提示(id,"请先卸下召唤兽所穿戴的装备")
        return
      elseif  self.数据[n].统御 ~= nil then
        常规提示(id,"该召唤兽处于统御状态,请解除统御后再进行此操作")
        return
      end
      for i=1,#self.数据[n].技能 do
        if self.数据[n].技能[i]=="雷击" or self.数据[n].技能[i]=="水攻" or self.数据[n].技能[i]=="烈火" or self.数据[n].技能[i]=="落岩" or self.数据[n].技能[i]=="奔雷咒" or self.数据[n].技能[i]=="水漫金山" or self.数据[n].技能[i]=="地狱烈火" or self.数据[n].技能[i]=="泰山压顶" then
          认证法术[#认证法术+1]=self.数据[n].技能[i]
        end
      end
    end
  end
  if #认证法术>=1 then
    for i=1,#认证法术 do
      临时选项[i]=认证法术[i]
      临时选项[#认证法术+1]="不认证了"
      发送数据(连接id,1501,{名称="老马猴",模型="马猴",对话=format("少侠要对该召唤兽的哪个技能进行认证呢？"),选项=临时选项})
    end
  else
    添加最后对话(id,"该召唤兽没有可认证的法术哦")
  end
end

function 召唤兽处理类:法术认证处理(连接id,id,事件)
  if 玩家数据[id].角色.数据.参战信息==nil then
    常规提示(id,"请将要法术认证的召唤兽参战")
    return
  end
  local 随机技能=取认证法术()
  local 技能重复=0
  for n=1,#self.数据 do
    if self.数据[n].参战信息 ~= nil and #self.数据[n].技能~=nil then
      if self:是否有装备(n) then
        常规提示(id,"请先卸下召唤兽所穿戴的装备")
        return
      elseif  self.数据[n].统御 ~= nil then
        常规提示(id,"该召唤兽处于统御状态,请解除统御后再进行此操作")
        return
      end
      for i=1,#self.数据[n].技能 do
        if self.数据[n].技能[i]==事件 then
          if self.数据[n].技能[i] == 随机技能 then
            技能重复 = n
          end
          if 技能重复==0 then
            self.数据[n].技能[i]=随机技能
            self.数据[n].法术认证={}
            self.数据[n].法术认证[1]=事件
            self.数据[n].法术认证[2]=随机技能
            添加最后对话(id,"少侠的召唤兽法术认证成功")
          else
            随机技能=取认证法术()
          end
        end
      end
      self:刷新信息(n)
    end
  end
end

function 召唤兽处理类:洗点处理(连接id,id)
  if 玩家数据[id].角色.数据.参战信息==nil then
      常规提示(id,"请将要洗点的召唤兽参战")
      return
  end
  if 取银子(id) < 5000000 then
      常规提示(id,"你身上的银子不够洗点哦！")
      return
  end
  for n=1,#self.数据 do
    if self.数据[n].参战信息 ~= nil then
      if self:是否有装备(n) then
          常规提示(id,"请先卸下召唤兽所穿戴的装备")
          return
      elseif  self.数据[n].统御 ~= nil then
        常规提示(id,"该召唤兽处于统御状态,请解除统御后再进行此操作")
        return
      end
      玩家数据[id].角色:扣除银子(5000000,0,0,"召唤兽洗点",1)
      if self.数据[n].种类=="神兽" then
          self.数据[n].体质=self.数据[n].等级+20
          self.数据[n].魔力=self.数据[n].等级+20
          self.数据[n].力量=self.数据[n].等级+20
          self.数据[n].耐力=self.数据[n].等级+20
          self.数据[n].敏捷=self.数据[n].等级+20
          self.数据[n].潜力=self.数据[n].等级*5+self.数据[n].灵性*2
      elseif self.数据[n].种类=="变异" then
          self.数据[n].体质=self.数据[n].等级+15
          self.数据[n].魔力=self.数据[n].等级+15
          self.数据[n].力量=self.数据[n].等级+15
          self.数据[n].耐力=self.数据[n].等级+15
          self.数据[n].敏捷=self.数据[n].等级+15
          self.数据[n].潜力=self.数据[n].等级*5+self.数据[n].灵性*2
      elseif self.数据[n].种类=="宝宝" then
          self.数据[n].体质=self.数据[n].等级+10
          self.数据[n].魔力=self.数据[n].等级+10
          self.数据[n].力量=self.数据[n].等级+10
          self.数据[n].耐力=self.数据[n].等级+10
          self.数据[n].敏捷=self.数据[n].等级+10
          self.数据[n].潜力=self.数据[n].等级*5+self.数据[n].灵性*2
      end
      self:刷新信息(n)
      常规提示(id,"召唤兽洗点成功！")
    end
  end
end

function 召唤兽处理类:洗点处理1(编号)
  if self:是否有装备(编号) then
    return false
  end
  if self.数据[编号].种类=="神兽" then
      self.数据[编号].体质=self.数据[编号].等级+20
      self.数据[编号].魔力=self.数据[编号].等级+20
      self.数据[编号].力量=self.数据[编号].等级+20
      self.数据[编号].耐力=self.数据[编号].等级+20
      self.数据[编号].敏捷=self.数据[编号].等级+20
      self.数据[编号].潜力=self.数据[编号].等级*5+self.数据[编号].灵性*2
  elseif self.数据[编号].种类=="变异" then
      self.数据[编号].体质=self.数据[编号].等级+15
      self.数据[编号].魔力=self.数据[编号].等级+15
      self.数据[编号].力量=self.数据[编号].等级+15
      self.数据[编号].耐力=self.数据[编号].等级+15
      self.数据[编号].敏捷=self.数据[编号].等级+15
      self.数据[编号].潜力=self.数据[编号].等级*5+self.数据[编号].灵性*2
  elseif self.数据[编号].种类=="宝宝" then
      self.数据[编号].体质=self.数据[编号].等级+10
      self.数据[编号].魔力=self.数据[编号].等级+10
      self.数据[编号].力量=self.数据[编号].等级+10
      self.数据[编号].耐力=self.数据[编号].等级+10
      self.数据[编号].敏捷=self.数据[编号].等级+10
      self.数据[编号].潜力=self.数据[编号].等级*5+self.数据[编号].灵性*2
  end
  self:刷新信息(编号)
  return true
end

function 召唤兽处理类:加点处理(连接id,序号,id,点数)
  local 临时编号=self:取编号(点数.序列)
  local 监控开关 = false
  if 临时编号==0 then
    常规提示(id,"你没有这只召唤兽")
    return
  else
    local 总数点=0
    总数点=点数.力量+点数.体质+点数.耐力+点数.魔力+点数.敏捷
    if 总数点>self.数据[临时编号].潜力 then
      常规提示(id,"该召唤兽没有那么多的可分配属性点")
      return
    end
    if 点数.力量<0 or 点数.魔力<0 or 点数.耐力<0 or 点数.体质<0 or 点数.敏捷<0 or  点数.力量>self.数据[临时编号].潜力 or 点数.魔力>self.数据[临时编号].潜力 or 点数.耐力>self.数据[临时编号].潜力 or 点数.体质>self.数据[临时编号].潜力 or 点数.敏捷>self.数据[临时编号].潜力 then
      监控开关 = true
    end
    if 监控开关 then
      发送数据(玩家数据[id].连接id,998,"请注意你的角色异常！已经对你进行封IP")
      __S服务:输出("玩家"..id.." 非法修改数据警告!属性修改")
      写配置("./ip封禁.ini","ip",玩家数据[id].ip,1)
      写配置("./ip封禁.ini","ip",玩家数据[id].ip.." 非法修改数据警告!修改宠物属性,玩家ID:"..id,1)
      __S服务:断开连接(玩家数据[id].连接id)
      return 0
    end
    self.数据[临时编号].力量=self.数据[临时编号].力量+点数.力量
    self.数据[临时编号].魔力=self.数据[临时编号].魔力+点数.魔力
    self.数据[临时编号].耐力=self.数据[临时编号].耐力+点数.耐力
    self.数据[临时编号].体质=self.数据[临时编号].体质+点数.体质
    self.数据[临时编号].敏捷=self.数据[临时编号].敏捷+点数.敏捷
    self.数据[临时编号].潜力=self.数据[临时编号].潜力-总数点
    self:刷新信息(临时编号,"1")
    发送数据(连接id,20,self:取存档数据(临时编号))
    if self.数据[临时编号].认证码==玩家数据[id].角色.数据.参战宝宝.认证码 then
      玩家数据[id].角色.数据.参战宝宝={}
      玩家数据[id].角色.数据.参战宝宝=table.loadstring(table.tostring(self:取存档数据(临时编号)))
      玩家数据[id].角色.数据.参战信息=1
      self.数据[临时编号].参战信息=1
      发送数据(连接id,18,玩家数据[id].角色.数据.参战宝宝)
    end
  end
end

function 召唤兽处理类:改名处理(连接id,序号,id,序列,名称)
  local 临时编号=self:取编号(序列)
  if 临时编号==0 then
    常规提示(id,"你没有这只召唤兽")
    return
  elseif 名称=="" then
    常规提示(id,"名称不能为空")
    return
  elseif #名称>12 then
    常规提示(id,"名称太长了，换个试试！")
    return
  else
    self.数据[临时编号].名称=名称
    常规提示(id,"召唤兽名称修改成功！")
    发送数据(连接id,19,{序列=临时编号,名称=名称})
  end
end

function 召唤兽处理类:参战处理(连接id,序号,id,序列)
  local 临时编号=self:取编号(序列)
  if 临时编号==0 then
    常规提示(id,"你没有这只召唤兽")
    return
  elseif 玩家数据[id].角色.数据.等级+10 < self.数据[临时编号].等级 then
    常规提示(id,"你目前的等级小于该召唤兽10级以上,不允许参战")
    return
  elseif self.数据[临时编号].寿命 <= 50 then
    常规提示(id,"该召唤兽的寿命低于50无法参战")
    return
  else
    if 玩家数据[id].角色.数据.参战宝宝.认证码==self.数据[临时编号].认证码 then
      玩家数据[id].角色.数据.参战宝宝={}
      self.数据[临时编号].参战信息=nil
      玩家数据[id].角色.数据.参战信息=nil
    else
      for n=1,#self.数据 do
        if self.数据[n].认证码==玩家数据[id].角色.数据.参战宝宝.认证码 then
          self.数据[n].参战信息=nil
        end
      end
      玩家数据[id].角色.数据.参战宝宝={}
      玩家数据[id].角色.数据.参战宝宝=self.数据[临时编号]
      玩家数据[id].角色.数据.参战信息=1
      self.数据[临时编号].参战信息=1
    end
    发送数据(连接id,18,玩家数据[id].角色.数据.参战宝宝)
  end
end
function 召唤兽处理类:死亡处理(认证码)
  local 编号=self:取编号(认证码)
  if self.数据[编号].种类 ~= "神兽" then
    self.数据[编号].寿命 = self.数据[编号].寿命 - 25
    if self.数据[编号].寿命<=0 then
        self.数据[编号].寿命 = 0
    end
  end
  if self.数据[编号].寿命 <= 50 then
    -- table.remove(self.数据,编号)
    self.数据[编号].参战信息=nil
    常规提示(玩家数据[self.数字id].连接id,"该召唤兽寿命过低，无法参加战斗")
  end
end

function 召唤兽处理类:刷新信息1(认证码,参数)
  local 编号=self:取编号(认证码)
  self:刷新信息(编号,参数)
  if self.数据[编号].参战信息~=nil then
    玩家数据[self.数字id].角色.数据.参战宝宝=self.数据[编号]
    发送数据(玩家数据[self.数字id].连接id,18,玩家数据[self.数字id].角色.数据.参战宝宝)
  end
end

function 召唤兽处理类:取编号(认证码)
  for n=1,#self.数据 do
    if self.数据[n].认证码==认证码 then
      return n
    end
  end
  return 0
end

function 召唤兽处理类:飞升降级处理(id)
  for n=1,#self.数据 do
    if self.数据[n].等级>=玩家数据[id].角色.数据.等级+10 then
        self.降低等级=self.数据[n].等级-10-玩家数据[id].角色.数据.等级
        self:降级(self.降低等级,n)
    end
  end
end

function 召唤兽处理类:更新(dt) end
function 召唤兽处理类:显示(x,y) end

function 召唤兽处理类:打书概率(v)
  local g = 取随机数(1,5)
  if v == 1 then
    if g == 1 then
      return true
    end
  elseif v == 2 then
    g = 取随机数(1,10)
    if g == 1 then
      return true
    end
  elseif v == 3 then
    g = 取随机数(1,15)
    if g == 1 then
      return true
    end
  elseif v == 4 then
    g = 取随机数(1,240)
    if g <= 10 then
      return true
    end
  elseif v == 5 then
    g = 取随机数(1,350)
    if g <= 10 then
      return true
    end
  elseif v == 6 then
    g = 取随机数(1,400)
    if g <= 10 then
      return true
    end
  elseif v == 7 then
    g = 取随机数(1,450)
    if g <= 10 then
      return true
    end
  elseif v == 8 then
    g = 取随机数(1,500)
    if g <= 10 then
      return true
    end
  elseif v == 9 then
    g = 取随机数(1,550)
    if g <= 10 then
      return true
    end
  elseif v == 10 then
    g = 取随机数(1,600)
    if g <= 10 then
      return true
    end
  elseif v == 11 then
    g = 取随机数(1,650)
    if g <= 10 then
      return true
    end
  elseif v == 12 then
    g = 取随机数(1,700)
    if g <= 10 then
      return true
    end
  elseif v > 12 and v <= 24 then
    g = 取随机数(1,24000)
    if g <= 5 then
      return true
    end
  end
  return false
end

function 召唤兽处理类:取经验(id,lv)
  local exp={}
  if id==1 then
    exp={
      40,110,237,450,779,1252,1898,2745,3822,5159,6784,8726,11013,13674,16739,20236,24194,28641,33606,39119,45208,
      51902,55229,67218,75899,85300,95450,106377,118110,130679,144112,158438,173685,189882,207059,225244,244466,264753,
      286134,308639,332296,357134,383181,410466,439019,468868,500042,532569,566478,601799,638560,676790,716517,757770,
      800579,844972,890978,938625,987942,1038959,1091704,1146206,1202493,1260594,1320539,1382356,1446074,1511721,1579326,
      1648919,1720528,1794182,1869909,1947738,2027699,2109820,2194130,2280657,2369431,2460479,2553832,2649518,2747565,
      2848003,2950859,3056164,3163946,3274233,3387055,3502439,3620416,3741014,3864261,3990187,4118819,4250188,4384322,
      4521249,4660999,4803599,4998571,5199419,5406260,5619213,5838397,6063933,6295941,6534544,6779867,7032035,7291172,
      7557407,7830869,8111686,8399990,8695912,8999586,9311145,9630726,9958463,10294496,10638964,10992005,11353761,11724374,
      12103988,12492748,12890799,13298287,13715362,14142172,14578867,15025600,15482522,15949788,16427552,16915970,17415202,
      17925402,18446732,18979354,19523428,20079116,20646584,21225998,43635044,44842648,46075148,47332886,48616200,74888148,
      76891401,78934581,81018219,83142835,85308969,87977421,89767944,92061870,146148764,150094780,154147340,158309318,
      162583669,166973428,171481711,176111717,180866734,185780135,240602904,533679362,819407100,1118169947, 1430306664,
      1756161225,2096082853
    }
  else
    exp={
      50,200,450,800,1250,1800,2450,3250,4050,5000,6050,7200,8450,9800,11250,12800,14450,16200,18050,20000,22050,24200,
      26450,28800,31250,33800,36450,39200,42050,45000,48050,51200,54450,57800,61250,64800,68450,72200,76050,80000,84050,
      88200,92450,96800,101250,105800,110450,115200,120050,125000,130050,135200,140450,145800,151250,156800,162450,
      168200,174050,180000,186050,192200,198450,204800,211250,217800,224450,231200,238050,245000,252050,259200,266450,
      273800,281250,288800,296450,304200,312050,320000,328050,336200,344450,352800,361250,369800,378450,387200,396050,
      405000,414050,423200,432450,441800,451250,460800,470450,480200,490050,500000,510050,520200,530450,540800,551250,
      561800,572450,583200,594050,605000,616050,627200,638450,649800,661250,672800,684450,696200,708050,720000,732050,
      744200,756450,768800,781250,793800,806450,819200,832050,845000,858050,871200,884450,897800,911250,924800,938450,
      952200,966050,980000,994050,1008200,1022450,1036800,1051250,1065800,1080450,1095200,1110050,1125000,1140050,1155200,
      1170450,1185800,1201250,1216800,1232450,1248200,1264050,1280000,1300000,1340000,1380000,1420000,1460000,1500000,1540000,
      1580000,1700000,1780000,1820000,1940000,2400000,2880000,3220000,4020000,4220000,4420000,4620000,5220000,5820000,6220000,
      7020000,8020000,9020000
    }
  end
  return exp[lv+1]
end
return 召唤兽处理类