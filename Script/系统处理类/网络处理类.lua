--======================================================================--
-- @作者: GGE研究群: 342119466
-- @创建时间:   2018-03-03 02:34:19
-- @Last Modified time: 2020-08-28 23:13:50
-- 梦幻西游游戏资源破解 baidwwy@vip.qq.com(313738139) 老毕   和 C++PrimerPlus 717535046 这俩位大神破解所以资源
--======================================================================--
local 网络处理类 = class()
function 网络处理类:初始化() end

function 网络处理类:数据解密处理(id,内容)
  内容 =self:jm1(内容)
  if 内容==nil or 内容=="" then
    -- self:断开连接(id,"通讯密码错误")
    return
  end
  self.数据=分割文本(内容,fgf)
  if self.数据=="" or self.数据==nil then
    return
  end
  self.数据[1]=self.数据[1]+0
  if self.数据[1]==1  or self.数据[1] == 1.1 or self.数据[1] == 1.2 then --版本验证
    self.临时数据=分割文本(self.数据[2],fgc)
    if (self.数据[1] == 1 or self.数据[1] == 1.1) and self.临时数据[1]+0~= 版本 then
      print(id)
      发送数据(id,999,"您的客户端版本过低，请先升级客户端")
      return
    elseif f函数.读配置(程序目录..[[data\]]..self.临时数据[2]..[[\账号信息.txt]],"账号配置","封禁") == "1" then
      发送数据(id,999,"该账号已经被封禁！")
    else
      if self.临时数据[5]~=nil then
        self:数据处理(id,table.tostring({序号=-1,内容={账号=self.临时数据[2],密码=self.临时数据[3],qq=self.临时数据[4],硬盘=self.临时数据[5],ip=__C客户信息[id].IP}}))
      else
        __C客户信息[id].账号 = self.临时数据[2]
        self:数据处理(id,table.tostring({序号=self.数据[1],内容={账号=self.临时数据[2],密码=self.临时数据[3],硬盘=self.临时数据[4],ip=__C客户信息[id].IP}}))
      end
    end
  elseif self.数据[1]==2 then
      self:数据处理(id,table.tostring({序号=self.数据[1],内容={账号=__C客户信息[id].账号}}))
  elseif self.数据[1]==3 then
      self:数据处理(id,table.tostring({序号=self.数据[1],内容={账号=__C客户信息[id].账号,模型=self.数据[2],名称=self.数据[3],染色ID=self.数据[4],ip=__C客户信息[id].IP}}))
  elseif self.数据[1]==4 or self.数据[1]==4.1 then
      __C客户信息[id].数字id=self.数据[2]
      self:数据处理(id,table.tostring({序号=self.数据[1],内容={账号=__C客户信息[id].账号,id=self.数据[2],ip=__C客户信息[id].IP}}))
  elseif self.数据[1]==4.2 then
    local 虚拟管理id = id..1000010086
    __C客户信息[id].数字id=虚拟管理id
    self:数据处理(id,table.tostring({序号=self.数据[1],内容={账号=__C客户信息[id].账号,id=虚拟管理id,ip=__C客户信息[id].IP}}))
  elseif self.数据[1]==34 then --版本验证
    self.临时数据=分割文本(self.数据[2],fgc)
    if self.临时数据[1]+0~=版本 then
      发送数据(id,999,"您的客户端版本过低，请先升级客户端")
    else
      __C客户信息[id].账号=self.临时数据[2]
      self:数据处理(id,table.tostring({序号=self.数据[1],内容={账号=self.临时数据[2],密码=self.临时数据[3],硬盘=self.临时数据[4],ip=__C客户信息[id].IP}}))
    end
  else
    self.临时数据=table.loadstring(self.数据[2])
    if self.临时数据==nil or self.临时数据=="" then return  end
    self.临时数据.ip=__C客户信息[id].IP
    self.临时数据.序号=self.数据[1]
    self.临时数据.数字id=__C客户信息[id].数字id
    self:数据处理(id,table.tostring(self.临时数据))
  end
end

function 网络处理类:数据处理(id,源)
  self.数据=table.loadstring(源)
  local 序号=self.数据.序号+0
  if 序号<=5 or 序号==34 then
    系统处理类:数据处理(id,序号,self.数据.内容)
  elseif 序号<=1000 then
    self.数据.数字id=self.数据.数字id+0
    系统处理类:数据处理(id,序号,self.数据)
  elseif 序号>1000 and 序号<=1500 then --地图事件
  	地图处理类:数据处理(id,序号,self.数据.数字id+0,self.数据)
  elseif 序号>1500 and 序号<=2000 then --对话事件
  	对话处理类:数据处理(id,序号,self.数据.数字id+0,self.数据)
  elseif 序号>3500 and 序号<=4000 then --道具事件
  	玩家数据[self.数据.数字id+0].道具:数据处理(id,序号,self.数据.数字id+0,self.数据)
  elseif 序号>4000 and 序号<=4500 then --道具事件
  	队伍处理类:数据处理(id,序号,self.数据.数字id+0,self.数据)
  elseif 序号>4500 and 序号<=5000 then --道具事件
  	玩家数据[self.数据.数字id+0].装备:数据处理(id,序号,self.数据.数字id+0,self.数据)
  elseif 序号>5000 and 序号<=5500 then --道具事件
    玩家数据[self.数据.数字id+0].召唤兽:数据处理(id,序号,self.数据.数字id+0,self.数据)
  elseif 序号>5500 and 序号<=6000 then --道具事件
    战斗准备类:数据处理(self.数据.数字id+0,序号,self.数据)
    --玩家数据[self.数据.数字id+0].召唤兽:数据处理(id,序号,self.数据.数字id+0,self.数据)
  elseif 序号>6000 and 序号<=6100 then --道具事件
    聊天处理类:数据处理(self.数据.数字id+0,序号,self.数据)
  elseif 序号>6100 and 序号<=6200 then --帮派处理
    帮派处理类:数据处理(self.数据.数字id+0,序号,self.数据)
  elseif 序号>6200 and 序号 <=6300 then
    管理工具类:数据处理(self.数据.数字id+0,序号,self.数据)
  elseif  序号==99997 then
    服务端参数.连接数=self.数据.人数
  elseif  序号==99998 then

  elseif  序号==99999 then

  end
end
function 网络处理类:更新(dt) end
function 网络处理类:显示(x,y) end

function 网络处理类:断开处理(id,内容)
  if 内容 == nil then
    内容 = "未知"
  end
  发送数据(id,998,内容)
end
function 网络处理类:更新(dt)
end
function 网络处理类:显示(x,y)
end


function 网络处理类:encodeBase641(source_str)
  local b64chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
  local s64 = ''
  local str = source_str
  while #str > 0 do
      local bytes_num = 0
      local buf = 0

      for byte_cnt=1,3 do
          buf = (buf * 256)
          if #str > 0 then
              buf = buf + string.byte(str, 1, 1)
              str = string.sub(str, 2)
              bytes_num = bytes_num + 1
          end
      end

      for group_cnt=1,(bytes_num+1) do
          local b64char = math.fmod(math.floor(buf/262144),64) + 1
          s64 = s64 .. string.sub(b64chars, b64char, b64char)
          buf = buf * 64
      end

      for fill_cnt=1,(3-bytes_num) do
          s64 = s64 .. '='
      end
  end
  return s64
end

function 网络处理类:decodeBase641(str64)
  local b64chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
  local temp={}
  for i=1,64 do
      temp[string.sub(b64chars,i,i)] = i
  end
  temp['=']=0
  local str=""
  for i=1,#str64,4 do
      if i>#str64 then
          break
      end
      local data = 0
      local str_count=0
      for j=0,3 do
          local str1=string.sub(str64,i+j,i+j)
          if not temp[str1] then
              return
          end
          if temp[str1] < 1 then
              data = data * 64
          else
              data = data * 64 + temp[str1]-1
              str_count = str_count + 1
          end
      end
      for j=16,0,-8 do
          if str_count > 0 then
              str=str..string.char(math.floor(data/math.pow(2,j)))
              data=math.mod(data,math.pow(2,j))
              str_count = str_count - 1
          end
      end
  end
  local last = tonumber(string.byte(str, string.len(str), string.len(str)))
  if last == 0 then
      str = string.sub(str, 1, string.len(str) - 1)
  end
  return str
end

kemy={}
mab = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/*=.，'
key={["B"]="6b,",["S"]="9W,",["5"]="BZ,",["D"]="wO,",["c"]="wu,",["E"]="cj,",["b"]="vt,",["3"]="Iv,",["s"]="jO,",["N"]="2l,",["d"]="mP,",["6"]="wd,",["7"]="5R,",["e"]="ET,",["t"]="nB,",["8"]="8v,",["4"]="yP,",["W"]="j3,",["9"]="Wa,",["H"]="Dl,",["G"]="Ve,",["g"]="JA,",["I"]="Au,",["X"]="NR,",["m"]="DG,",["w"]="Cx,",["Y"]="Qi,",["V"]="es,",["F"]="pF,",["z"]="CO,",["K"]="XC,",["f"]="aW,",["J"]="DT,",["x"]="S9,",["y"]="xi,",["v"]="My,",["L"]="PW,",["u"]="Aa,",["k"]="Yx,",["M"]="qL,",["j"]="ab,",["r"]="fN,",["q"]="0W,",["T"]="de,",["l"]="P8,",["0"]="q6,",["n"]="Hu,",["O"]="A2,",["1"]="VP,",["i"]="hY,",["h"]="Uc,",["C"]="cK,",["A"]="f4,",["P"]="is,",["U"]="u2,",["o"]="m9,",["Q"]="vd,",["R"]="gZ,",["2"]="Zu,",["Z"]="Pf,",["a"]="Lq,",["p"]="Sw,"}

function 网络处理类:jm(数据)
  数据=self:encodeBase641(数据)
  local jg=""
  for n=1,#数据 do
    local z=string.sub(数据,n,n)
    if z~="" then
      if key[z]==nil then
        jg=jg..z
      else
        jg=jg..key[z]
      end
    end
  end
  return jg
end

function 网络处理类:jm1(数据)
  local jg=数据
  for n=1,#mab do
    local z=string.sub(mab,n,n)
    if key[z]~=nil then
       jg=string.gsub(jg,key[z],z)
    end
  end
  return self:decodeBase641(jg)
end



return 网络处理类