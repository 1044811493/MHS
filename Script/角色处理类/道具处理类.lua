
local 道具处理类 = class()
local 书铁范围 = {"枪矛","斧钺","剑","双短剑","飘带","爪刺","扇","魔棒","锤","鞭","环圈","刀","法杖","弓弩","宝珠","巨剑","伞","灯笼","头盔","发钗","项链","女衣","男衣","腰带","鞋子"}
local 图策范围={"项圈","护腕","铠甲"}
local qz=math.floor
local floor=math.floor
local remove = table.remove
local 已存在=false
function 道具处理类:初始化(id)
  self.玩家id=id
  self.数据={}
  self.阵法名称={
    [3]="普通",
    [4]="风扬阵",
    [5]="虎翼阵",
    [6]="天覆阵",
    [7]="云垂阵",
    [8]="鸟翔阵",
    [9]="地载阵",
    [10]="龙飞阵",
    [11]="蛇蟠阵",
    [12]="鹰啸阵",
    [13]="雷绝阵",
  }
  self.飞行传送点={
    [1]={1001,336,217},
    [2]={1001,358,35},
    [3]={1501,65,112},
    [4]={1092,122,54},
    [5]={1070,106,158},
    [6]={1040,108,98},
    [7]={1226,117,48},
    [8]={1208,128,36},
  }
end

function 道具处理类:数据处理(连接id,序号,数字id,数据)
  if 假人开关==1 and BoothCtrl:MsgCtrl(连接id, 序号, 数字id, 数据) then
    return
  end
  if 玩家数据[数字id].摊位数据~=nil then
    if 序号~=3699 and 序号~=3700 and 序号~=3720 and 序号~=3721 and 序号~=3722 and 序号~=3723 and 序号~=3724 then
      常规提示(数字id,"#Y/摆摊状态下禁止此种行为")
      return
    end
  end
  if 序号==3699 then
     self:索要道具(连接id,数字id)
  elseif 序号==3700 then
    self:索要行囊(连接id,数字id)
  elseif 序号==3701 then
    self:道具格子互换(连接id,数字id,数据)
  elseif 序号==3701.1 then
    self:道具格子互换1(连接id,数字id,数据)
  elseif 序号==3702 then
    self:丢弃道具(连接id,数字id,数据)
  elseif 序号==3703 then
    self:佩戴装备(连接id,数字id,数据)
  elseif 序号==3704 then
    self:卸下装备(连接id,数字id,数据)
  elseif 序号==3705 then
    self:使用道具(连接id,数字id,数据)
  elseif 序号==3706 then
    self:飞行符传送(连接id,数字id,数据)
  elseif 序号==3707 then
    发送数据(连接id,14,玩家数据[数字id].道具:索要道具1(数字id))
  elseif 序号==3708 then
    self:佩戴bb装备(连接id,数字id,数据)
  elseif 序号==3709 then
    self:卸下bb装备(连接id,数字id,数据)
  elseif 序号==3710 then
    self:染色处理(连接id,数字id,数据)
  elseif 序号==3711 then
    玩家数据[数字id].角色:学习门派技能(连接id,数字id,数据.序列)
  elseif 序号==3712 then
    玩家数据[数字id].角色:学习生活技能(连接id,数字id,数据.序列)
  elseif 序号==3712.1 then
    if 强化技能 then
      玩家数据[数字id].角色:学习强化技能(连接id,数字id,数据.序列)
    end
  elseif 序号==3713 then
    self:烹饪处理(连接id,数字id,数据)
  elseif 序号==3714 then
    self:炼药处理(连接id,数字id,数据)
  elseif 序号==3715 then
    self:给予处理(连接id,数字id,数据)
  elseif 序号==3716 then --请求给予
    玩家数据[数字id].给予数据={类型=2,id=数据.id+0}
    发送数据(连接id,3507,{道具=self:索要道具1(数字id),名称=玩家数据[数据.id+0].角色.数据.名称,类型="玩家",等级=玩家数据[数据.id+0].角色.数据.等级})
   -- self:给予处理(连接id,数字id,数据)
  elseif 序号==3717 then
   self:设置交易数据(连接id,数字id,数据)
  elseif 序号==3718 then
   self:发起交易处理(连接id,数字id,数据.id)
  elseif 序号==3719 then
   self:取消交易(数字id)
  elseif 序号==3720 then --自己创建、索要摊位
    self:索要摊位数据(连接id,数字id,3515)
  elseif 序号==3721 then --更改招牌
    self:更改摊位招牌(连接id,数字id,数据.名称)
  elseif 序号==3722 then --上架
    self:摊位上架商品(连接id,数字id,数据)
  elseif 序号==3723 then --下架
    self:摊位下架商品(连接id,数字id,数据)
  elseif 序号==3724 then --收摊
    self:收摊处理(连接id,数字id)
  elseif 序号==3725 then --索取其他玩家摊位
    self:索要其他玩家摊位(连接id,数字id,数据.id,3521)
  elseif 序号==3726 then --购买摊位商品
   self:购买摊位商品(连接id,数字id,数据)
  elseif 序号==3727 then --购买摊位商品
   self:快捷加血(连接id,数字id,数据.类型)
  elseif 序号==3728 then --购买摊位商品
   self:快捷加蓝(连接id,数字id,数据.类型)
  elseif 序号==3729 then --购买摊位商品
    if 数据.序列>#玩家数据[数字id].角色.数据.道具仓库 then
      常规提示(数字id,"#Y/这已经是最后一页了")
      return
    elseif 数据.序列<1 then
      return
    end
    发送数据(连接id,3524,{道具=self:索要仓库道具(数字id,数据.序列),页数=数据.序列})
  elseif 序号==3730 then
    self:仓库存放事件(连接id,数字id,数据)
  elseif 序号==3731 then
    self:仓库取走事件(连接id,数字id,数据)
  elseif 序号==3732 then
   self:索要法宝(连接id,数字id)
  elseif 序号==3733 then
   self:修炼法宝(连接id,数字id,数据.序列)
  elseif 序号==3734 then
   self:卸下法宝(连接id,数字id,数据.序列)
  elseif 序号==3735 then
   self:替换法宝(连接id,数字id,数据.序列,数据.序列1)
  elseif 序号==3736 then
   self:使用法宝(连接id,数字id,数据.序列)
  elseif 序号==3737 then
   self:使用合成旗(连接id,数字id,数据.序列)
  elseif 序号==3738 then
   self:完成交易处理(数字id)
  elseif 序号 == 3739 then
   self:出售道具(连接id,数字id,数据)
  elseif 序号 == 3740 then
    if 数据.存入金额==nil then
        return
    end
    if 玩家数据[数字id].角色.数据.银子 < 数据.存入金额 then
        常规提示(数字id,"#Y你的现金貌似没有那么多哦")
        return
    end
    玩家数据[数字id].角色.数据.银子 = 玩家数据[数字id].角色.数据.银子 - 数据.存入金额
    玩家数据[数字id].角色.数据.存银 = 玩家数据[数字id].角色.数据.存银 + 数据.存入金额
    常规提示(数字id,"#Y当前已经将#R"..数据.存入金额.."#Y两银子存入到小金库了！")
    发送数据(数字id,72,{银子=玩家数据[数字id].角色.数据.银子,存银=玩家数据[数字id].角色.数据.存银})
  elseif 序号 == 3741 then
    if 数据.取出金额==nil then
        return
    end
    if 数据.取出金额 > 玩家数据[数字id].角色.数据.存银 then
        常规提示(数字id,"#Y你的存款貌似没有那么多哦")
        return
    end
    玩家数据[数字id].角色.数据.银子 = 玩家数据[数字id].角色.数据.银子 + 数据.取出金额
    玩家数据[数字id].角色.数据.存银 = 玩家数据[数字id].角色.数据.存银 - 数据.取出金额
    常规提示(数字id,"#Y你已经从小金库取出#R"..数据.取出金额.."#Y两银子！")
    发送数据(数字id,72,{银子=玩家数据[数字id].角色.数据.银子,存银=玩家数据[数字id].角色.数据.存银})
  elseif 序号 == 3742 then
    local 仓库上限 = 20
    if 取银子(数字id) < 5000000 then
        常规提示(数字id,"#Y你银子不够开启仓库哦！")
        return
    end
    if #玩家数据[数字id].角色.数据.道具仓库 >= 仓库上限 then
        常规提示(数字id,"#Y你当前仓库数量已达上限！")
        return
    end
    玩家数据[数字id].角色:扣除银子(5000000,0,0,"扩充仓库",1)
    玩家数据[数字id].角色.数据.道具仓库[#玩家数据[数字id].角色.数据.道具仓库 + 1]={}
    常规提示(数字id,"#Y仓库扩充成功，当前数量为#R"..#玩家数据[数字id].角色.数据.道具仓库.."#Y个，还可以扩充#R"..仓库上限-#玩家数据[数字id].角色.数据.道具仓库.."#Y个！")
  elseif 序号 == 3743 then
    self:帮派点修处理(连接id,数字id,数据)
  elseif 序号 == 3744 then
    玩家数据[数字id].角色:帮派学习生活技能(连接id,数字id,数据.序列)
  elseif 序号 == 3745 then
    self:武器染色处理(连接id,数字id,数据)
  elseif 序号==3746 then
    if 玩家数据[数字id].角色.数据.门派=="无门派" or 玩家数据[数字id].角色.数据.门派==nil then
      常规提示(数字id,"#Y你当前没有门派无法打开经脉系统！")
      return
    end
    发送数据(玩家数据[数字id].连接id, 77, 玩家数据[数字id].角色:经脉处理(数字id))
  elseif 序号==3747 then
    玩家数据[数字id].角色:清空奇经八脉(数字id)
  elseif 序号==3748 then
    self:符石合成处理(连接id,数字id,数据)
  elseif 序号==3749 then
    self:坐骑染色处理(连接id,数字id,数据)
  elseif 序号==3750 then
    self:穿戴饰品(连接id,数字id,数据)
  elseif 序号==3751 then
    self:坐骑饰品染色处理(连接id,数字id,数据)
  elseif 序号==3752 then
    玩家数据[数字id].角色:更改角色名字(数字id,数据)
  elseif 序号==3753 then
    self:卸下饰品(连接id,数字id,数据)
  elseif 序号==3754 then
    self:法宝合成(连接id,数字id,数据)
  elseif 序号==3755 then
    self:神秘宝箱处理(连接id,数字id,数据)
  elseif 序号==3756 then
    发送数据(玩家数据[数字id].连接id,3513,玩家数据[数字id].道具:索要道具2(数字id))
    发送数据(玩家数据[数字id].连接id,3523,{道具=玩家数据[数字id].道具:索要仓库道具(数字id,1),总数=#玩家数据[数字id].角色.数据.道具仓库})
  elseif 序号==3757 then
    self:仙玉神秘宝箱处理(连接id,数字id,数据)
  elseif 序号==3757.1 then
    神秘宝箱[数字id]=nil
  elseif 序号==3758 then
    self:钥匙神秘宝箱处理(连接id,数字id,数据)
  elseif 序号==3759 then
    self:老唐定制宝箱处理(连接id,数字id,数据)
  elseif 序号==3760 then --购买摊位商品
    if 数据.序列>#商会数据[数字id][1].店面 then
      常规提示(数字id,"#Y/这已经是最后一页了")
      return
    elseif 数据.序列<1 then
      return
    end
    发送数据(连接id,95.1,{道具=self:索要商会道具(数字id,数据.序列),页数=数据.序列,总数=#商会数据[数字id][1].店面,商会信息=商会数据[数字id][1]})
  elseif 序号==3761 then
    self:商会存放事件(连接id,数字id,数据)
  elseif 序号==3762 then
    self:商会取走事件(连接id,数字id,数据)
  elseif 序号==3763 then
    商会数据[数字id][1].店名=数据.名称
    发送数据(连接id,95.1,{道具=self:索要商会道具(数字id,数据.页数),页数=数据.页数,总数=#商会数据[数字id][1].店面,商会信息=商会数据[数字id][1]})
    发送数据(连接id,95.2)
    常规提示(数字id,"#Y商铺改名成功！")
  elseif 序号==3764 then
    if #商会数据[数字id][1].店面>=10 then
      常规提示(数字id,"#Y当前商铺最大可扩张柜台为10个，已达最大值")
      return
    end
    if 取银子(数字id) < 1000000 then
      常规提示(数字id,"#Y你银子不够开启仓库哦！")
      return
    end
    玩家数据[数字id].角色:扣除银子(1000000,0,0,"扩充仓库",1)
    商会数据[数字id][1].店面[#商会数据[数字id][1].店面+1]={}
    常规提示(数字id,"#Y商铺柜台扩张完毕！")
    发送数据(连接id,95.1,{道具=self:索要商会道具(数字id,数据.页数),页数=数据.页数,总数=#商会数据[数字id][1].店面,商会信息=商会数据[数字id][1]})
    发送数据(连接id,95.2)
  elseif 序号==3765 then
    if #商会数据[数字id][1].店面<=1 then
      常规提示(数字id,"#Y当前商铺最小可消减柜台为1个，已达最小值")
      return
    end
    商会数据[数字id][1].店面[#商会数据[数字id][1].店面]={}
    常规提示(数字id,"#Y商铺柜台消减完毕！")
    发送数据(连接id,95.1,{道具=self:索要商会道具(数字id,数据.页数),页数=数据.页数,总数=#商会数据[数字id][1].店面-1,商会信息=商会数据[数字id][1]})
    发送数据(连接id,95.2)
  elseif 序号==3766 then
    if 商会数据[数字id][1].店面[数据.页数][数据.物品]==nil then
      常规提示(数字id,"#Y该物品不存在或已经售出！")
      发送数据(连接id,95.1,{道具=self:索要商会道具(数字id,数据.页数),页数=数据.页数,总数=#商会数据[数字id][1].店面,商会信息=商会数据[数字id][1]})
      发送数据(连接id,95.2)
      return
    end
    if 数据.商品.专用~=nil then
      常规提示(数字id,"#Y该物品为专用道具，无法出售")
      发送数据(连接id,95.1,{道具=self:索要商会道具(数字id,数据.页数),页数=数据.页数,总数=#商会数据[数字id][1].店面,商会信息=商会数据[数字id][1]})
      发送数据(连接id,95.2)
      return
    end
    if 商会数据[数字id][1].店面[数据.页数][数据.物品].状态 then
      商会数据[数字id][1].店面[数据.页数][数据.物品].状态=false
      常规提示(数字id,"#Y物品下架成功！")
    else
      商会数据[数字id][1].刷新时间=os.time()
      商会数据[数字id][1].店面[数据.页数][数据.物品].状态=true
      商会数据[数字id][1].店面[数据.页数][数据.物品].价格=数据.价格+0
      常规提示(数字id,"#Y物品上架成功！")
    end
    发送数据(连接id,95.1,{道具=self:索要商会道具(数字id,数据.页数),页数=数据.页数,总数=#商会数据[数字id][1].店面,商会信息=商会数据[数字id][1]})
    发送数据(连接id,95.2)
  elseif 序号==3767 then
    self:商会营业状态(连接id,数字id,数据)
  elseif 序号==3768 then
    if 商会数据[数字id]==nil then
      常规提示(数字id,"#Y你似乎还没有商铺吧")
      return 0
    else
      if 取银子(数字id)<10000000 then
        常规提示(数字id,"#Y你没有那么多的银子可以存入")
        return 0
      else
        玩家数据[数字id].角色:扣除银子(10000000,0,0,"商会运营资金",1)
        商会数据[数字id][1].日常运营资金=商会数据[数字id][1].日常运营资金+"10000000"
        常规提示(数字id,"#Y银子存入商会成功！")
      end
    end
    发送数据(连接id,95.1,{道具=self:索要商会道具(数字id,数据.页数),页数=数据.页数,总数=#商会数据[数字id][1].店面,商会信息=商会数据[数字id][1]})
    发送数据(连接id,95.2)
  elseif 序号==3769 then
    if 商会数据[数字id]==nil then
      常规提示(数字id,"#Y你似乎还没有商铺吧")
      return 0
    else
      if 商会数据[数字id][1].日常运营资金<=0 then
        常规提示(数字id,"#Y你当前没有可取出的资金")
        return 0
      else
        玩家数据[数字id].角色:添加银子(商会数据[数字id][1].日常运营资金,"商会运营资金",1)
        商会数据[数字id][1].日常运营资金=0
        常规提示(数字id,"#Y取出资金成功")
      end
    end
    发送数据(连接id,95.1,{道具=self:索要商会道具(数字id,数据.页数),页数=数据.页数,总数=#商会数据[数字id][1].店面,商会信息=商会数据[数字id][1]})
    发送数据(连接id,95.2)
  elseif 序号==3770 then
    self:查看商会商铺信息(连接id,数字id,数据,1)
  elseif 序号==3771 then
    self:商会商铺物品购买(连接id,数字id,数据)
  elseif 序号==3772 then
    if 数据.店面>#商会数据[数据.商铺id][1].店面 then
      常规提示(数字id,"#Y/这已经是最后一页了")
      return
    elseif 数据.店面<1 then
      return
    end
    self:查看商会商铺信息(连接id,数据.商铺id,数据,2)
  elseif 序号==3773 then
    self:佩戴孩子装备(连接id,数字id,数据)
  elseif 序号==3774 then
    self:卸下孩子装备(连接id,数字id,数据)
  end
end

function 道具处理类:摊位下架商品(连接id,id,数据)

  if 玩家数据[id].摊位数据==nil then return end
  if 数据.bb==nil then --下架道具
    玩家数据[id].摊位数据.道具[数据.道具+0]=nil
    常规提示(id,"#Y/下架物品成功！")
  elseif 数据.道具==nil then
    local 编号=数据.bb+0
    玩家数据[id].摊位数据.bb[编号]=nil
    常规提示(id,"#Y/下架召唤兽成功！")
  end
  玩家数据[id].摊位数据.更新=os.time()
  self:索要摊位数据(连接id,id,3517)
end

function 道具处理类:使用合成旗(连接id,id,序列)
  --     玩家数据[id].最后操作="合成旗"
  if 玩家数据[id].道具操作==nil then return  end
  local 编号=玩家数据[id].道具操作.编号
  local 道具id=玩家数据[id].角色.数据[玩家数据[id].道具操作.类型][编号]
  if 道具id==nil or self.数据[道具id]==nil or self.数据[道具id].总类~=11 or self.数据[道具id].分类~=2 then
    常规提示(id,"#Y你没有这样的道具")
    return
  elseif self.数据[道具id].xy[序列]==nil then
    常规提示(id,"#Y错误的坐标选择点")
    return
  elseif self:取飞行限制(id) then
    return
  end
  self.数据[道具id].次数=self.数据[道具id].次数-1
  if self.数据[道具id].次数<=0 then
    玩家数据[id].角色.数据[玩家数据[id].道具操作.类型][编号]=nil
    常规提示(id,format("#Y你的%s已经用完了",self.数据[道具id].名称))
    self.数据[道具id]=nil
  else
    玩家数据[id].道具操作=nil
    道具刷新(id)
    地图处理类:跳转地图(id,self.数据[道具id].地图,self.数据[道具id].xy[序列].x,self.数据[道具id].xy[序列].y)
    常规提示(id,format("#Y你的%s还可以使用%s次",self.数据[道具id].名称,self.数据[道具id].次数))
  end
end

function 道具处理类:法宝合成(连接id,id,数据)
  local 道具id = 分割文本(数据.序列,",")
  local 临时id = {}
  local 找到内丹 = false
  local 合成费用 = 100000
  local 合成体力 = 100
  if 取银子(id) < 合成费用 then
      常规提示(id,"你没有那么多的银子")
      return
  end
  if 玩家数据[id].角色.数据.体力 < 合成体力 then
      常规提示(id,"你没有那么多的体力")
      return
  end
  for i=1,5 do
    道具id[i] = 道具id[i]+0
    临时id[i]=玩家数据[id].角色.数据.道具[道具id[i]]
    if self.数据[临时id[i]]~=nil and 道具id[i]~= 0 then
        if self.数据[临时id[i]].名称=="内丹" then
            找到内丹=true
        end
    end
  end
  if 找到内丹 then
      玩家数据[id].角色:扣除银子(合成费用,0,0,"法宝合成",1)
      玩家数据[id].角色.数据.体力=玩家数据[id].角色.数据.体力-合成体力
      for i=1,5 do
        道具id[i] = 道具id[i]+0
        临时id[i]=玩家数据[id].角色.数据.道具[道具id[i]]
        if self.数据[临时id[i]]~=nil and 道具id[i]~= 0 then
            self.数据[临时id[i]]=nil
        end
      end
      self:给予随机一级法宝(id)
      道具刷新(id)
  else
      常规提示(id,"缺少内丹材料，无法合成！")
      return
  end
end

function 道具处理类:武器染色处理(连接id,id,数据)
  local 道具id = 玩家数据[id].角色.数据.装备[3]
  local 武器染色费用 = 200000000
  if 取银子(id) < 武器染色费用 then
      添加最后对话(id,format("本次武器染色需要消耗#Y%s#W两银子，你似乎手头有点紧哟？",武器染色费用))
      return
  end
  玩家数据[id].角色:扣除银子(武器染色费用,0,0,"武器染色",1)
  if self.数据[道具id].染色方案==nil then
      self.数据[道具id].染色方案=0
  end
  if self.数据[道具id].染色组==nil then
      self.数据[道具id].染色组={}
  end
  self.数据[道具id].染色方案=数据.序列
  self.数据[道具id].染色组[1]=数据.序列1
  self.数据[道具id].染色组[2]=数据.序列2
  常规提示(id,"恭喜你，武器染色成功！快去看看武器的新造型吧！")
  发送数据(玩家数据[id].连接id,3504)
  地图处理类:更新武器(id,self.数据[玩家数据[id].角色.数据.装备[3]])
end

function 道具处理类:坐骑染色处理(连接id,id,数据)
  local 坐骑染色费用 = 100000000
  if 取银子(id) < 坐骑染色费用 then
      添加最后对话(id,format("本次坐骑染色需要消耗#Y%s#W两银子，你似乎手头有点紧哟？",坐骑染色费用))
      return
  end
  玩家数据[id].角色:扣除银子(坐骑染色费用,0,0,"坐骑染色",1)
  for i=1,#玩家数据[id].角色.数据.坐骑列表 do
      if 玩家数据[id].角色.数据.坐骑列表[i].认证码 == 数据.序列 then
        if 玩家数据[id].角色.数据.坐骑列表[i].染色方案==nil then
            玩家数据[id].角色.数据.坐骑列表[i].染色方案=0
        end
        if 玩家数据[id].角色.数据.坐骑列表[i].染色组==nil or 玩家数据[id].角色.数据.坐骑列表[i].染色组==0 then
            玩家数据[id].角色.数据.坐骑列表[i].染色组={}
        end
        if 玩家数据[id].角色.数据.坐骑.染色方案==nil then
            玩家数据[id].角色.数据.坐骑.染色方案=0
        end
        if 玩家数据[id].角色.数据.坐骑.染色组==nil or 玩家数据[id].角色.数据.坐骑.染色组==0 then
            玩家数据[id].角色.数据.坐骑.染色组={}
        end
        玩家数据[id].角色.数据.坐骑列表[i].染色方案=数据.序列1
        玩家数据[id].角色.数据.坐骑列表[i].染色组[1]=数据.序列2
        玩家数据[id].角色.数据.坐骑列表[i].染色组[2]=数据.序列3
        玩家数据[id].角色.数据.坐骑列表[i].染色组[3]=数据.序列4
        玩家数据[id].角色.数据.坐骑.染色方案=数据.序列1
        玩家数据[id].角色.数据.坐骑.染色组[1]=数据.序列2
        玩家数据[id].角色.数据.坐骑.染色组[2]=数据.序列3
        玩家数据[id].角色.数据.坐骑.染色组[3]=数据.序列4
        常规提示(id,"恭喜你！坐骑染色成功，快去看看你的坐骑的新颜色吧！")
        发送数据(玩家数据[id].连接id,60,玩家数据[id].角色.数据.坐骑)
        发送数据(玩家数据[id].连接id,61,玩家数据[id].角色.数据.坐骑列表)
        地图处理类:更新坐骑(id,玩家数据[id].角色.数据.坐骑)
    end
  end
end

function 道具处理类:坐骑饰品染色处理(连接id,id,数据)
  local 坐骑饰品染色费用 = 50000000
  if 取银子(id) < 坐骑饰品染色费用 then
      添加最后对话(id,format("本次坐骑饰品染色需要消耗#Y%s#W两银子，你似乎手头有点紧哟？",坐骑饰品染色费用))
      return
  end
  for i=1,#玩家数据[id].角色.数据.坐骑列表 do
      if 玩家数据[id].角色.数据.坐骑列表[i].认证码 == 数据.序列 then
        if 玩家数据[id].角色.数据.坐骑.饰品~=nil and 玩家数据[id].角色.数据.坐骑.饰品物件~=nil then
          玩家数据[id].角色:扣除银子(坐骑饰品染色费用,0,0,"坐骑饰品染色",1)
          if 玩家数据[id].角色.数据.坐骑列表[i].饰品物件.染色方案==nil then
              玩家数据[id].角色.数据.坐骑列表[i].染色方案=0
          end
          if 玩家数据[id].角色.数据.坐骑列表[i].饰品物件.染色组==nil or 玩家数据[id].角色.数据.坐骑列表[i].饰品物件.染色组==0 then
              玩家数据[id].角色.数据.坐骑列表[i].饰品物件.染色组={}
          end
          if 玩家数据[id].角色.数据.坐骑.饰品物件.染色方案==nil then
              玩家数据[id].角色.数据.坐骑.饰品物件.染色方案=0
          end
          if 玩家数据[id].角色.数据.坐骑.饰品物件.染色组==nil or 玩家数据[id].角色.数据.坐骑.饰品物件.染色组==0 then
              玩家数据[id].角色.数据.坐骑.饰品物件.染色组={}
          end
          玩家数据[id].角色.数据.坐骑列表[i].饰品物件.染色方案=数据.序列1
          玩家数据[id].角色.数据.坐骑列表[i].饰品物件.染色组[1]=数据.序列2
          玩家数据[id].角色.数据.坐骑列表[i].饰品物件.染色组[2]=数据.序列3
          玩家数据[id].角色.数据.坐骑列表[i].饰品物件.染色组[3]=数据.序列4
          玩家数据[id].角色.数据.坐骑.饰品物件.染色方案=数据.序列1
          玩家数据[id].角色.数据.坐骑.饰品物件.染色组[1]=数据.序列2
          玩家数据[id].角色.数据.坐骑.饰品物件.染色组[2]=数据.序列3
          玩家数据[id].角色.数据.坐骑.饰品物件.染色组[3]=数据.序列4
          常规提示(id,"恭喜你！坐骑饰品染色成功，快去看看你的坐骑的新颜色吧！")
          发送数据(玩家数据[id].连接id,60,玩家数据[id].角色.数据.坐骑)
          发送数据(玩家数据[id].连接id,61,玩家数据[id].角色.数据.坐骑列表)
          地图处理类:更新坐骑(id,玩家数据[id].角色.数据.坐骑)
        else
          常规提示(id,"少侠是来寻我开心的么？你要染色的坐骑饰品呢！")
          return
        end
      end
  end
end

function 道具处理类:给予暗器(id,等级)
  local 名称="飞刀"
  if 等级==1 then
    名称="飞刀"
  elseif 等级==10 then
    名称="顺逆神针"
  elseif 等级==2 then
    名称="飞蝗石"
  elseif 等级==3 then
    名称="铁蒺藜"
  elseif 等级==4 then
    名称="无影神针"
  elseif 等级==5 then
    名称="孔雀翎"
  elseif 等级==6 then
    名称="含沙射影"
  elseif 等级==7 then
    名称="回龙摄魂标"
  elseif 等级==8 then
    名称="寸阴若梦"
  elseif 等级==9 then
    名称="魔睛子"
  end
  常规提示(id,"#Y你获得了#R"..名称)
  self:给予道具(id,名称)
end

function 道具处理类:符石合成处理(连接id,id,数据)
  local 道具id=玩家数据[id].角色.数据.道具[数据.序列]
  local 道具id1=玩家数据[id].角色.数据.道具[数据.序列1]
  local 道具id2=玩家数据[id].角色.数据.道具[数据.序列2]
  local 道具id3=玩家数据[id].角色.数据.道具[数据.序列3]

  if self.数据[道具id].名称~="符石卷轴" and self.数据[道具id1].名称~="符石卷轴" and self.数据[道具id2].名称~="符石卷轴" and self.数据[道具id3].名称~="符石卷轴" then
      常规提示(id,"未找到符石卷轴")
      return
  end
  if (self.数据[道具id].名称=="符石卷轴" and self.数据[道具id1].名称=="符石卷轴") or (self.数据[道具id1].名称=="符石卷轴" and self.数据[道具id2].名称=="符石卷轴") or (self.数据[道具id2].名称=="符石卷轴" and self.数据[道具id3].名称=="符石卷轴") or (self.数据[道具id].名称=="符石卷轴" and self.数据[道具id2].名称=="符石卷轴") or (self.数据[道具id].名称=="符石卷轴" and self.数据[道具id3].名称=="符石卷轴") or (self.数据[道具id1].名称=="符石卷轴" and self.数据[道具id3].名称=="符石卷轴") then
      常规提示(id,"只能使用一个符石卷轴")
      return
  end
  if (self.数据[道具id].名称=="符石卷轴" and self.数据[道具id1].等级==self.数据[道具id2].等级 and self.数据[道具id1].等级==self.数据[道具id3].等级) or (self.数据[道具id1].名称=="符石卷轴" and self.数据[道具id].等级==self.数据[道具id2].等级 and self.数据[道具id].等级==self.数据[道具id3].等级) or (self.数据[道具id2].名称=="符石卷轴" and self.数据[道具id1].等级==self.数据[道具id].等级 and self.数据[道具id1].等级==self.数据[道具id3].等级) or (self.数据[道具id3].名称=="符石卷轴" and self.数据[道具id1].等级==self.数据[道具id2].等级 and self.数据[道具id1].等级==self.数据[道具id].等级) then
      local 合成几率=0
      local 符石等级=0
      if self.数据[道具id].等级~=nil or self.数据[道具id1].等级~=nil or self.数据[道具id2].等级~=nil or self.数据[道具id3].等级~=nil then
          if self.数据[道具id].等级==1 or self.数据[道具id1].等级==1 or self.数据[道具id2].等级==1 or self.数据[道具id3].等级==1 then
              合成几率=90
              符石等级=1
          end
          if self.数据[道具id].等级==2 or self.数据[道具id1].等级==2 or self.数据[道具id2].等级==2 or self.数据[道具id3].等级==2 then
              合成几率=80
              符石等级=2
          end
          if self.数据[道具id].等级==3 or self.数据[道具id1].等级==3 or self.数据[道具id2].等级==3 or self.数据[道具id3].等级==3 then
              合成几率=70
              符石等级=3
          end
      end
      if 取随机数(1,100) >=合成几率 then
          if self.数据[道具id].名称=="符石卷轴" then
              if 取随机数()<=30 then
                  self.数据[道具id1]=nil
                  self.数据[道具id2]=nil
              elseif 取随机数()<=60 then
                  self.数据[道具id1]=nil
                  self.数据[道具id3]=nil
              else
                  self.数据[道具id2]=nil
                  self.数据[道具id3]=nil
              end
          elseif self.数据[道具id1].名称=="符石卷轴" then
              if 取随机数()<=30 then
                  self.数据[道具id]=nil
                  self.数据[道具id2]=nil
              elseif 取随机数()<=60 then
                  self.数据[道具id]=nil
                  self.数据[道具id3]=nil
              else
                  self.数据[道具id2]=nil
                  self.数据[道具id3]=nil
              end
          elseif self.数据[道具id2].名称=="符石卷轴" then
              if 取随机数()<=30 then
                  self.数据[道具id]=nil
                  self.数据[道具id1]=nil
              elseif 取随机数()<=60 then
                  self.数据[道具id]=nil
                  self.数据[道具id3]=nil
              else
                  self.数据[道具id1]=nil
                  self.数据[道具id3]=nil
              end
          elseif self.数据[道具id3].名称=="符石卷轴" then
              if 取随机数()<=30 then
                  self.数据[道具id]=nil
                  self.数据[道具id1]=nil
              elseif 取随机数()<=60 then
                  self.数据[道具id]=nil
                  self.数据[道具id2]=nil
              else
                  self.数据[道具id1]=nil
                  self.数据[道具id2]=nil
              end
          end
          常规提示(id,"合成失败，你损失了俩块符石")
          return
      else
          local 符石名称 = 取符石(符石等级+1)
          self:给予道具(id,符石名称,1,55)
          self.数据[道具id]=nil
          self.数据[道具id1]=nil
          self.数据[道具id2]=nil
          self.数据[道具id3]=nil
          常规提示(id,"恭喜你，合成了更高等级的符石！")
      end
  else
      常规提示(id,"不同级别的符石无法合成！")
      return
  end

end

function 道具处理类:使用法宝(连接id,id,编号)
  local 道具id=玩家数据[id].角色.数据.法宝[编号]
  if 道具id==nil or self.数据[道具id]==nil then
    常规提示(id,"#Y你没有这件法宝")
    self:索要法宝(连接id,id)
    return
  end
  local 名称=self.数据[道具id].名称
  if 名称=="五色旗盒" then
    if self.数据[道具id].魔法<=0 then
      常规提示(id,"#Y你的法宝灵气不足")
      return
    elseif 玩家数据[id].角色.数据.等级<60 then
      常规提示(id,"#Y你的等级不足以使用此法宝")
      return
    end
    local aa ="请选择你要进行的操作："
    local xx={"合成导标旗","补充合成旗"}
    发送数据(连接id,1501,{名称="五色旗盒",对话=aa,选项=xx})
    玩家数据[id].最后操作="合成旗1"
    玩家数据[id].法宝id=编号
    return
  elseif 名称=="月光宝盒" then
    if self.数据[道具id].魔法<=0 then
      常规提示(id,"#Y你的法宝灵气不足")
      return
    end
    if 玩家数据[id].角色.数据.等级<60 then
      常规提示(id,"#Y你的等级不足以使用此法宝")
      return
    end
    local aa ="请选择你要进行的操作："
    local xx={"送我过去","在这里定标"}
    发送数据(连接id,1501,{名称="月光宝盒",对话=aa,选项=xx})
    玩家数据[id].最后操作="月光宝盒"
    玩家数据[id].法宝id=编号
    return
  end
  常规提示(id,"#Y此类型法宝当前不可用")
  return
end

function 道具处理类:替换法宝(连接id,id,编号,编号1)
  local 道具id=玩家数据[id].角色.数据.法宝[编号]
  if 玩家数据[id].角色.数据.等级<self.数据[道具id].特技 then
    常规提示(id,"#Y你当前的等级无法佩戴此类型的法宝")
    return
  end
  local 名称=self.数据[道具id].名称
  local 门派=玩家数据[id].角色.数据.门派
  if 名称=="天师符" and 门派~="方寸山" then
    常规提示(id,"#Y你的门派不允许你使用这样的法宝")
    return
  elseif 名称=="织女扇" and 门派~="女儿村" then
    常规提示(id,"#Y你的门派不允许你使用这样的法宝")
    return
  elseif 名称=="雷兽" and 门派~="天宫" then
    常规提示(id,"#Y你的门派不允许你使用这样的法宝")
    return
  elseif 名称=="定风珠" and 门派~="五庄观" then
    常规提示(id,"#Y你的门派不允许你使用这样的法宝")
    return
  elseif 名称=="七杀" and 门派~="大唐官府" then
    常规提示(id,"#Y你的门派不允许你使用这样的法宝")
    return
  elseif 名称=="罗汉珠" and 门派~="化生寺" then
    常规提示(id,"#Y你的门派不允许你使用这样的法宝")
    return
  elseif 名称=="天师符" and 门派~="方寸山" then
    常规提示(id,"#Y你的门派不允许你使用这样的法宝")
    return
  elseif 名称=="金刚杵" and 门派~="普陀山" then
    常规提示(id,"#Y你的门派不允许你使用这样的法宝")
    return
  elseif 名称=="兽王令" and 门派~="狮驼岭" then
    常规提示(id,"#Y你的门派不允许你使用这样的法宝")
    return
  elseif 名称=="摄魂" and 门派~="阴曹地府" then
    常规提示(id,"#Y你的门派不允许你使用这样的法宝")
    return
  elseif 名称=="干将莫邪" and 门派~="大唐官府" then
    常规提示(id,"#Y你的门派不允许你使用这样的法宝")
    return
  elseif 名称=="慈悲" and 门派~="化生寺" then
    常规提示(id,"#Y你的门派不允许你使用这样的法宝")
    return
  elseif 名称=="救命毫米" and 门派~="方寸山" then
    常规提示(id,"#Y你的门派不允许你使用这样的法宝")
    return
  elseif 名称=="伏魔天书" and 门派~="天宫" then
    常规提示(id,"#Y你的门派不允许你使用这样的法宝")
    return
  elseif 名称=="普渡" and 门派~="普陀山" then
    常规提示(id,"#Y你的门派不允许你使用这样的法宝")
    return
  elseif 名称=="镇海珠" and 门派~="龙宫" then
   常规提示(id,"#Y你的门派不允许你使用这样的法宝")
   return
  elseif 名称=="奇门五行令" and 门派~="五庄观" then
    常规提示(id,"#Y你的门派不允许你使用这样的法宝")
    return
  elseif 名称=="失心钹" and 门派~="狮驼岭" then
    常规提示(id,"#Y你的门派不允许你使用这样的法宝")
    return
  elseif 名称=="五火神焰印" and 门派~="魔王寨" then
    常规提示(id,"#Y你的门派不允许你使用这样的法宝")
    return
  elseif 名称=="九幽" and 门派~="阴曹地府" then
    常规提示(id,"#Y你的门派不允许你使用这样的法宝")
    return
  elseif 名称=="月影" and 门派~="神木林" then
    常规提示(id,"#Y你的门派不允许你使用这样的法宝")
    return
  end
  if 玩家数据[id].角色.数据.法宝佩戴[编号1]==nil then
    玩家数据[id].角色.数据.法宝佩戴[编号1]=玩家数据[id].角色.数据.法宝[编号]
    玩家数据[id].角色.数据.法宝[编号]=nil
  else
    local 临时编号=玩家数据[id].角色.数据.法宝[编号]
    玩家数据[id].角色.数据.法宝[编号]=玩家数据[id].角色.数据.法宝佩戴[编号1]
    玩家数据[id].角色.数据.法宝佩戴[编号1]=临时编号
  end
  self:索要法宝(连接id,id)
end

function 道具处理类:卸下法宝(连接id,id,编号)
  local 格子=玩家数据[id].角色:取法宝格子()
  if 格子==0 then
    常规提示(id,"#Y你的法宝栏已经满了")
    return
  end
  玩家数据[id].角色.数据.法宝[格子]=玩家数据[id].角色.数据.法宝佩戴[编号]
  玩家数据[id].角色.数据.法宝佩戴[编号]=nil
  self:索要法宝(连接id,id)
end

function 道具处理类:修炼法宝(连接id,id,编号)
  local 道具id=玩家数据[id].角色.数据.法宝[编号]
  if 道具id==nil or self.数据[道具id]==nil then
    常规提示(id,"#Y你没有这件法宝")
    self:索要法宝(连接id,id)
    return
  end
  local 上限=9
  if self.数据[道具id].分类==2 then
    上限=12
  elseif self.数据[道具id].分类==3 then
    上限=15
  elseif self.数据[道具id].分类==4 then
    上限=18
  end
  if self.数据[道具id].气血==上限 then
    常规提示(id,"#Y你的这件法宝已经满层了，无法再进行修炼")
    return
  end
  local 消耗经验=math.floor(self.数据[道具id].升级经验)
  -- if 消耗经验>10000000 then
  --   消耗经验=10000000
  -- end
  if 玩家数据[id].角色.数据.当前经验<消耗经验 then
    常规提示(id,"#Y本次修炼需要消耗#R"..消耗经验.."#Y点人物经验，您似乎没有那么多的经验哟")
    return
  end
  玩家数据[id].角色.数据.当前经验=玩家数据[id].角色.数据.当前经验-消耗经验
  玩家数据[id].角色:日志记录("修炼法宝["..self.数据[道具id].名称.."]消耗"..消耗经验.."点经验,剩余经验"..玩家数据[id].角色.数据.当前经验)
  常规提示(id,"#Y修炼成功,你消耗了#R"..消耗经验.."#Y了点人物经验")
  self.数据[道具id].当前经验=self.数据[道具id].当前经验+消耗经验
  if self.数据[道具id].当前经验>=self.数据[道具id].升级经验 then
    self.数据[道具id].气血=self.数据[道具id].气血+1
    self.数据[道具id].当前经验=self.数据[道具id].当前经验-self.数据[道具id].升级经验
    self.数据[道具id].魔法=取灵气上限(self.数据[道具id].分类)
    if self.数据[道具id].气血<上限 then
      self.数据[道具id].升级经验=法宝经验[self.数据[道具id].分类][self.数据[道具id].气血+1]
    end
    常规提示(id,"#Y你的法宝#R"..self.数据[道具id].名称.."#Y境界提升了")
  end
  发送数据(连接id,31,玩家数据[id].角色:取总数据())
  发送数据(连接id,3528,{id=编号,当前经验=self.数据[道具id].当前经验,升级经验=self.数据[道具id].升级经验,境界=self.数据[道具id].气血,灵气=self.数据[道具id].魔法})
end

function 道具处理类:仓库取走事件(连接id,id,数据)
  local 页数=数据.页数
  local 道具=数据.物品
  local 格子=玩家数据[id].角色:取道具格子()
  if 格子==0 then
    常规提示(id,"#Y/你身上的包裹没有足够的空间")
    return
  end
  玩家数据[id].角色.数据.道具[格子]=玩家数据[id].角色.数据.道具仓库[页数][道具]
  玩家数据[id].角色.数据.道具仓库[页数][道具] =nil
  道具刷新(id)
  发送数据(玩家数据[id].连接id,3513,玩家数据[id].道具:索要道具2(id))
  发送数据(连接id,3524,{道具=self:索要仓库道具(id,数据.页数),页数=数据.页数})
  发送数据(连接id,3525)
end

function 道具处理类:仓库存放事件(连接id,id,数据)
  local 页数=数据.页数
  local 道具=数据.物品
  local 格子=0
  for n=1,20 do
    if 玩家数据[id].角色.数据.道具仓库[页数][n]==nil and 格子==0 then
      格子=n
    end
  end
  if 格子==0 then
    常规提示(id,"#Y/你这个仓库已经无法存放更多的物品了")
    return
  end
  if 道具~=nil and 玩家数据[id].角色.数据.道具[道具]~=nil and self.数据[玩家数据[id].角色.数据.道具[道具]]~=nil and self.数据[玩家数据[id].角色.数据.道具[道具]].总类=="帮派银票" and self.数据[玩家数据[id].角色.数据.道具[道具]].名称=="帮派银票" then
      常规提示(id,"#Y/该物品无法存入到仓库")
      return
  end
  if 道具~=nil and 玩家数据[id].角色.数据.道具[道具]~=nil and self.数据[玩家数据[id].角色.数据.道具[道具]]~=nil and self.数据[玩家数据[id].角色.数据.道具[道具]].总类=="跑商商品" then
      常规提示(id,"#Y/该物品无法存入到仓库")
      return
  end
  if 道具~=nil and 玩家数据[id].角色.数据.道具[道具]~=nil and self.数据[玩家数据[id].角色.数据.道具[道具]]~=nil and self.数据[玩家数据[id].角色.数据.道具[道具]].总类==1001 then
      常规提示(id,"#Y/该物品无法存入到仓库")
      return
  end
  玩家数据[id].角色.数据.道具仓库[页数][格子]=玩家数据[id].角色.数据.道具[道具]
  玩家数据[id].角色.数据.道具[道具]=nil
  道具刷新(id)
  发送数据(玩家数据[id].连接id,3513,玩家数据[id].道具:索要道具2(id))
  发送数据(连接id,3524,{道具=self:索要仓库道具(id,数据.页数),页数=数据.页数})
  发送数据(连接id,3525)
end

function 道具处理类:商会取走事件(连接id,id,数据)
  local 页数=数据.页数
  local 道具=数据.物品
  local 格子=玩家数据[id].角色:取道具格子()
  if 格子==0 then
    常规提示(id,"#Y/你身上的包裹没有足够的空间")
    return
  end
  if 商会数据[id][1].店面[页数][道具].状态 then
    常规提示(id,"#Y/该物品已经上架出售，无法取回")
    return
  end
  玩家数据[id].角色.数据.道具[格子]=商会数据[id][1].店面[页数][道具].id
  商会数据[id][1].店面[页数][道具] =nil
  道具刷新(id)
  发送数据(玩家数据[id].连接id,3513,玩家数据[id].道具:索要道具2(id))
  发送数据(连接id,95.1,{道具=self:索要商会道具(id,数据.页数),页数=数据.页数,总数=#商会数据[id][1].店面,商会信息=商会数据[id][1]})
  发送数据(连接id,95.2)
end

function 道具处理类:商会存放事件(连接id,id,数据)
  local 页数=数据.页数
  local 道具=数据.物品
  local 格子=0
  for n=1,20 do
    if 商会数据[id][1].店面[页数][n]==nil and 格子==0 then
      格子=n
    end
  end
  if 格子==0 then
    常规提示(id,"#Y/你这个商铺已经无法存放更多的物品了")
    return
  end
  if 道具~=nil and 玩家数据[id].角色.数据.道具[道具]~=nil and self.数据[玩家数据[id].角色.数据.道具[道具]]~=nil and self.数据[玩家数据[id].角色.数据.道具[道具]].总类=="帮派银票" and self.数据[玩家数据[id].角色.数据.道具[道具]].名称=="帮派银票" then
      常规提示(id,"#Y/该物品无法存入到商会")
      return
  end
  if 道具~=nil and 玩家数据[id].角色.数据.道具[道具]~=nil and self.数据[玩家数据[id].角色.数据.道具[道具]]~=nil and self.数据[玩家数据[id].角色.数据.道具[道具]].总类=="跑商商品" then
      常规提示(id,"#Y/该物品无法存入到商会")
      return
  end
  if 道具~=nil and 玩家数据[id].角色.数据.道具[道具]~=nil and self.数据[玩家数据[id].角色.数据.道具[道具]]~=nil and self.数据[玩家数据[id].角色.数据.道具[道具]].总类==1001 then
      常规提示(id,"#Y/该物品无法存入到商会")
      return
  end
  商会数据[id][1].店面[页数][格子]={id=玩家数据[id].角色.数据.道具[道具],状态=false,价格=0}
  玩家数据[id].角色.数据.道具[道具]=nil
  道具刷新(id)
  发送数据(玩家数据[id].连接id,3513,玩家数据[id].道具:索要道具2(id))
  发送数据(连接id,95.1,{道具=self:索要商会道具(id,数据.页数),页数=数据.页数,总数=#商会数据[id][1].店面,商会信息=商会数据[id][1]})
  发送数据(连接id,95.2)
end

function 道具处理类:商会营业状态(连接id,id,数据)
  if 商会数据[id]==nil then
    常规提示(id,"#Y少侠视乎还没有商铺哦")
    return 0
  else
    if 商会数据[id][1].营业 then
      商会数据[id][1].刷新时间=os.time()
      商会数据[id][1].营业=false
      常规提示(id,"#Y你的这间商铺已经暂停营业了")
    else
      商会数据[id][1].营业=true
      常规提示(id,"#Y你的这间商铺已经开始营业了")
    end
    发送数据(连接id,95.1,{道具=self:索要商会道具(id,数据.页数),页数=数据.页数,总数=#商会数据[id][1].店面,商会信息=商会数据[id][1]})
    发送数据(连接id,95.2)
  end
end

function 道具处理类:获取商会商铺信息(id)
  self.发送内容={}
  for n, v in pairs(商会数据) do
    if 商会数据[n]~=nil and 商会数据[n][1].营业 then
      self.发送内容[#self.发送内容+1]={
        店名=商会数据[n][1].店名,
        宗旨=商会数据[n][1].宣言,
        店主名称=商会数据[n][1].店主名称,
        店主id=商会数据[n][1].店主id,
        创店日期=商会数据[n][1].创店日期,
        店面=#商会数据[n][1].店面,
        商铺id=n,
        类型=商会数据[n][1].类型
      }
    end
  end
  发送数据(玩家数据[id].连接id,95.3,table.tostring(self.发送内容))
end

function 道具处理类:查看商会商铺信息(连接id,id,数据,类型)
  self.发送信息={}
  local 出售id = 数据.商铺id
  local 序号 = 数据.店面
  for n=1,20 do
    if 商会数据[出售id][1].店面[序号][n]~=nil  then
      if 商会数据[出售id][1].店面[序号][n].状态 then
        self.发送信息[n]={道具=table.loadstring(table.tostring(玩家数据[出售id].道具.数据[商会数据[出售id][1].店面[序号][n].id])),状态=商会数据[出售id][1].店面[序号][n].状态,价格=商会数据[出售id][1].店面[序号][n].价格}
      end
    end
  end
  self.发送信息.类型=序号
  self.发送信息.店名=商会数据[出售id][1].店名
  self.发送信息.现金=玩家数据[id].角色.数据.银子
  self.发送信息.店主名称=商会数据[出售id][1].店主名称
  self.发送信息.店主id=商会数据[出售id][1].店主id
  self.发送信息.创店日期=商会数据[出售id][1].创店日期
  self.发送信息.店面=#商会数据[出售id][1].店面
  self.发送信息.商铺id=出售id
  玩家数据[id].入店时间=os.time()
  if 类型==1 then
    发送数据(连接id,95.4,table.tostring(self.发送信息))
  elseif 类型==2 then
    发送数据(连接id,95.5,table.tostring(self.发送信息))
  end

end

function 道具处理类:商会商铺物品购买(连接id,id,数据)
  if 玩家数据[id].入店时间<=商会数据[数据.商铺id][1].刷新时间 then
    常规提示(id,"#Y该店的商品信息已经发生变化，请重新查看")
    return 0
  elseif 商会数据[数据.商铺id][1].店面[数据.店面][数据.商品id]==nil then
    常规提示(id,"#Y这个商品已经被其他玩家买走了")
    return 0
  elseif 取银子(id)<商会数据[数据.商铺id][1].店面[数据.店面][数据.商品id].价格 then
    常规提示(id,"#Y你身上的现金不够哦")
    return 0
  else
    local 临时格子=玩家数据[id].角色:取道具格子()
    local 对方id=数据.商铺id
    local 名称=玩家数据[对方id].角色.数据.名称
    local 名称1=玩家数据[id].角色.数据.名称
    local 账号=玩家数据[对方id].账号
    local 账号1=玩家数据[id].账号
    if 临时格子==0 then
      常规提示(id,"#Y/请先整理下包裹吧！")
      return
    end
    玩家数据[id].角色:扣除银子(商会数据[数据.商铺id][1].店面[数据.店面][数据.商品id].价格,0,0,"商会购买物品",1)
    商会数据[数据.商铺id][1].日常运营资金=商会数据[数据.商铺id][1].日常运营资金+商会数据[数据.商铺id][1].店面[数据.店面][数据.商品id].价格
    local 道具id=self:取新编号()
    local 道具名称=玩家数据[对方id].道具.数据[商会数据[数据.商铺id][1].店面[数据.店面][数据.商品id].id].名称
    local 道具识别码=玩家数据[对方id].道具.数据[商会数据[数据.商铺id][1].店面[数据.店面][数据.商品id].id].识别码
    玩家数据[id].角色:日志记录(format("[商会系统-购买]购买道具[%s][%s]，花费%s两银子,出售者信息：[%s][%s][%s]",道具名称,道具识别码,价格,账号,对方id,名称))
    玩家数据[对方id].角色:日志记录(format("[商会系统-出售]出售道具[%s][%s]，花费%s两银子,购买者信息：[%s][%s][%s]",道具名称,道具识别码,价格,账号1,id,名称1))
    更改道具归属(道具识别码,账号,对方id,名称)
    常规提示(对方id,"#W/出售#R/"..道具名称.."#W/成功！")
    常规提示(id,"#W/购买#R/"..道具名称.."#W/成功！")
    self.数据[道具id]=table.loadstring(table.tostring(玩家数据[对方id].道具.数据[商会数据[数据.商铺id][1].店面[数据.店面][数据.商品id].id]))
    玩家数据[id].角色.数据.道具[临时格子]=道具id
    if 玩家数据[id].道具.数据[道具id].数量~=nil then
      玩家数据[id].道具.数据[道具id].数量=1
    end
    if 玩家数据[对方id].道具.数据[商会数据[数据.商铺id][1].店面[数据.店面][数据.商品id].id].数量==nil then
      商会数据[数据.商铺id][1].店面[数据.店面][数据.商品id]=nil
    else
      玩家数据[对方id].道具.数据[商会数据[数据.商铺id][1].店面[数据.店面][数据.商品id].id].数量=玩家数据[对方id].道具.数据[商会数据[数据.商铺id][1].店面[数据.店面][数据.商品id].id].数量-1
      if 玩家数据[对方id].道具.数据[商会数据[数据.商铺id][1].店面[数据.店面][数据.商品id].id].数量<=0 then
        商会数据[数据.商铺id][1].店面[数据.店面][数据.商品id]=nil
      end
    end
    道具刷新(id)
    道具刷新(对方id)
    self:查看商会商铺信息(连接id,数据.商铺id,数据,2)
  end
end

function 道具处理类:快捷加血(连接id,id,类型)
  if 玩家数据[id].战斗~=0 then return  end
  local 数值=0
  local 编号=0
  if 类型==1 then
    数值=玩家数据[id].角色.数据.最大气血-玩家数据[id].角色.数据.气血
  else
    编号=玩家数据[id].召唤兽:取编号(玩家数据[id].角色.数据.参战宝宝.认证码)
    数值=玩家数据[id].召唤兽.数据[编号].最大气血-玩家数据[id].召唤兽.数据[编号].气血
  end
  if 数值==0 then
    return
  end
  local 恢复=self:快捷加血1(id,数值)
  if 恢复==0 then
    return
  end
  self:加血处理(连接id,id,恢复,编号)
  道具刷新(id)
end

function 道具处理类:快捷加血1(id,数值)
  local 道具={"包子","四叶花"}
  local 恢复=0
  local 道具删除={}
  for n=1,20 do
    if 玩家数据[id].角色.数据.道具[n]~=nil then
      local 道具id=玩家数据[id].角色.数据.道具[n]
      local 符合=false
      for i=1,#道具 do
        if self.数据[道具id].名称==道具[i] then
          符合=true
        end
      end
      if 符合 then
        if 恢复<数值 and self:取加血道具1(self.数据[道具id].名称,道具id)*self.数据[道具id].数量>=数值 then --
          local 扣除数量=0
          for i=1,self.数据[道具id].数量 do
            if 恢复<数值 then
              恢复=恢复+self:取加血道具1(self.数据[道具id].名称,道具id)
              扣除数量=扣除数量+1
            end
          end
          道具删除[#道具删除+1]={格子=n,id=道具id,数量=扣除数量}
        elseif 恢复<数值 then
          恢复= self:取加血道具1(self.数据[道具id].名称,道具id)*self.数据[道具id].数量
          道具删除[#道具删除+1]={格子=n,id=道具id,数量=self.数据[道具id].数量}
        end
      end
    end
  end
  if 恢复~=0 then
    for n=1,#道具删除 do
      self.数据[道具删除[n].id].数量=self.数据[道具删除[n].id].数量-道具删除[n].数量
      if self.数据[道具删除[n].id].数量<=0 then
        玩家数据[id].角色.数据.道具[道具删除[n].格子]=nil
      end
    end
  end
  if 恢复>数值 then 恢复=数值 end
  return 恢复
end

function 道具处理类:快捷加蓝(连接id,id,类型)
  if 玩家数据[id].战斗~=0 then return  end
  local 数值=0
  local 编号=0
  if 类型==1 then
    数值=玩家数据[id].角色.数据.最大魔法-玩家数据[id].角色.数据.魔法
  else
    编号=玩家数据[id].召唤兽:取编号(玩家数据[id].角色.数据.参战宝宝.认证码)
    数值=玩家数据[id].召唤兽.数据[编号].最大魔法-玩家数据[id].召唤兽.数据[编号].魔法
  end
  if 数值==0 then
    return
  end
  local 恢复=self:快捷加蓝1(id,数值)
  if 恢复==0 then
    return
  end
  self:加魔处理(连接id,id,恢复,编号)
  道具刷新(id)
end

function 道具处理类:快捷加蓝1(id,数值)
 local 道具={"鬼切草","佛手","紫丹罗"}
 local 恢复=0
 local 道具删除={}
  for n=1,20 do
    if 玩家数据[id].角色.数据.道具[n]~=nil then
      local 道具id=玩家数据[id].角色.数据.道具[n]
      local 符合=false
      for i=1,#道具 do
        if self.数据[道具id].名称==道具[i] then
          符合=true
        end
      end
      if 符合 then
        if 恢复<数值 and self:取加魔道具1(self.数据[道具id].名称,道具id)*self.数据[道具id].数量>=数值 then --
          local 扣除数量=0
          for i=1,self.数据[道具id].数量 do
            if 恢复<数值 then
              恢复=恢复+self:取加魔道具1(self.数据[道具id].名称,道具id)
              扣除数量=扣除数量+1
            end
          end
          道具删除[#道具删除+1]={格子=n,id=道具id,数量=扣除数量}
        elseif 恢复<数值 then
          恢复= self:取加魔道具1(self.数据[道具id].名称,道具id)*self.数据[道具id].数量
          道具删除[#道具删除+1]={格子=n,id=道具id,数量=self.数据[道具id].数量}
        end
      end
    end
  end
  if 恢复~=0 then
    for n=1,#道具删除 do
      self.数据[道具删除[n].id].数量=self.数据[道具删除[n].id].数量-道具删除[n].数量
      if self.数据[道具删除[n].id].数量<=0 then
        玩家数据[id].角色.数据.道具[道具删除[n].格子]=nil
      end
    end
  end
  if 恢复>数值 then 恢复=数值 end
  return 恢复
end

function 道具处理类:摊位上架商品(连接id,id,数据)
  if 玩家数据[id].摊位数据==nil then return end
  if 数据.价格=="" or 数据.价格==nil or 数据.价格+0<=0 then
    数据.价格=1
  end
  local 价格=数据.价格+0
  if 数据.bb==nil then --上架道具
    local 编号=玩家数据[id].角色.数据.道具[数据.道具+0]
    if self.数据[编号].不可交易 then
      常规提示(id,"#Y/该物品不可转移给他人")
      return
    end
    玩家数据[id].摊位数据.道具[数据.道具+0]=table.loadstring(table.tostring(self.数据[编号]))
    玩家数据[id].摊位数据.道具[数据.道具+0].价格=价格
    常规提示(id,"#Y/上架物品成功！")
  elseif 数据.道具==nil then
    local 编号=数据.bb+0
    if 玩家数据[id].召唤兽.数据[编号].不可交易 then
      常规提示(id,"#Y/该召唤兽不可转移给他人")
      return
    elseif 玩家数据[id].召唤兽.数据[编号].统御 ~= nil then
      常规提示(id,"#Y/已被坐骑统御的召唤兽无法转移给他人")
      return
    end
    玩家数据[id].摊位数据.bb[编号]=table.loadstring(table.tostring(玩家数据[id].召唤兽.数据[编号]))
    玩家数据[id].摊位数据.bb[编号].价格=价格
    玩家数据[id].摊位数据.bb[编号].id=编号
    常规提示(id,"#Y/上架召唤兽成功！")
  end
  玩家数据[id].摊位数据.更新=os.time()
  self:索要摊位数据(连接id,id,3517)
end

function 道具处理类:收摊处理(连接id,id)
  玩家数据[id].摊位数据=nil
  常规提示(id,"#Y/收摊回家玩老婆去咯！")
  发送数据(连接id,3518)
  地图处理类:取消玩家摊位(id)
end

function 道具处理类:更改摊位招牌(连接id,id,名称)
  if 玩家数据[id].摊位数据==nil then return end
  if os.time()-玩家数据[id].摊位数据.更新<=5 then
    常规提示(id,"#Y/请不要频繁更换招牌")
    return
  end
  常规提示(id,"#Y/更新招牌成功")
  玩家数据[id].摊位数据.更新=os.time()
  玩家数据[id].摊位数据.名称=名称
  发送数据(连接id,3516,名称)
  地图处理类:设置玩家摊位(id,名称)
end

function 道具处理类:购买摊位商品(连接id,id,数据)
  local 对方id=玩家数据[id].摊位id
  if 对方id==nil or 玩家数据[对方id]==nil or 玩家数据[对方id].摊位数据==nil then
    常规提示(id,"#Y/这个摊位并不存在")
    return
  end
  if 玩家数据[id].摊位查看<玩家数据[对方id].摊位数据.更新 then
    常规提示(id,"#Y/这个摊位的数据已经发生了变化，请重新打开该摊位")
    return
  end
  --数据转移
  local 名称=玩家数据[对方id].角色.数据.名称
  local 名称1=玩家数据[id].角色.数据.名称
  local 账号=玩家数据[对方id].账号
  local 账号1=玩家数据[id].账号
  if 数据.bb==nil then --购买道具
    if  玩家数据[对方id].摊位数据.道具[数据.道具]==nil then
      常规提示(id,"#Y/这个商品并不存在")
      return
    end
    local 价格=玩家数据[对方id].摊位数据.道具[数据.道具].价格
    if 玩家数据[对方id].摊位数据.道具[数据.道具].可叠加==false or 玩家数据[对方id].摊位数据.道具[数据.道具].数量==nil then
        数据.数量 = 1
    elseif  数据.数量 > 玩家数据[对方id].摊位数据.道具[数据.道具].数量 then
        数据.数量 = 玩家数据[对方id].摊位数据.道具[数据.道具].数量
    end
    if 数据.数量 > 1 then
      价格=玩家数据[对方id].摊位数据.道具[数据.道具].价格*数据.数量
    end
    if math.floor(价格)  ~= 价格 then
      写配置("./ip封禁.ini","ip",玩家数据[id].ip,1)
      发送数据(玩家数据[id].连接id,998,"请注意你的角色异常！已经对你进行封IP")
      __S服务:断开连接(玩家数据[id].连接id)
      return 0
    end
    if 玩家数据[id].角色.数据.银子<价格 then
      常规提示(id,"#Y/你没有那么多的银子")
      return
    end
    local 临时格子=玩家数据[id].角色:取道具格子()
    if 临时格子==0 then
      常规提示(id,"#Y/请先整理下包裹吧！")
      return
    end
    玩家数据[id].角色:扣除银子(价格,0,0,"摊位购买",1)
    玩家数据[对方id].角色:添加银子(价格,"摊位出售",1)
    local 道具id=self:取新编号()
    local 道具名称=玩家数据[对方id].摊位数据.道具[数据.道具].名称
    local 道具识别码=玩家数据[对方id].摊位数据.道具[数据.道具].识别码
    玩家数据[id].角色:日志记录(format("[摊位系统-购买]购买道具[%s][%s]，花费%s两银子,出售者信息：[%s][%s][%s]",道具名称,道具识别码,价格,账号,对方id,名称))
    玩家数据[对方id].角色:日志记录(format("[摊位系统-出售]出售道具[%s][%s]，花费%s两银子,购买者信息：[%s][%s][%s]",道具名称,道具识别码,价格,账号1,id,名称1))
    更改道具归属(道具识别码,账号,对方id,名称)
    常规提示(对方id,"#W/出售#R/"..道具名称.."#W/成功！")
    常规提示(id,"#W/购买#R/"..道具名称.."#W/成功！")
    self.数据[道具id]=table.loadstring(table.tostring(玩家数据[对方id].摊位数据.道具[数据.道具]))
    玩家数据[id].角色.数据.道具[临时格子]=道具id
    if 玩家数据[对方id].摊位数据.道具[数据.道具].可叠加==false or 玩家数据[对方id].摊位数据.道具[数据.道具].数量==nil then
      玩家数据[对方id].道具.数据[玩家数据[对方id].角色.数据.道具[数据.道具]]=nil
      玩家数据[对方id].角色.数据.道具[数据.道具]=nil
      玩家数据[对方id].摊位数据.道具[数据.道具]=nil
    else
      self.数据[道具id].数量=数据.数量
      玩家数据[对方id].摊位数据.道具[数据.道具].数量=玩家数据[对方id].摊位数据.道具[数据.道具].数量-数据.数量
      if 玩家数据[对方id].摊位数据.道具[数据.道具].数量<=0 then
        玩家数据[对方id].道具.数据[玩家数据[对方id].角色.数据.道具[数据.道具]]=nil
        玩家数据[对方id].角色.数据.道具[数据.道具]=nil
        玩家数据[对方id].摊位数据.道具[数据.道具]=nil
      else
        玩家数据[对方id].道具.数据[玩家数据[对方id].角色.数据.道具[数据.道具]].数量=玩家数据[对方id].道具.数据[玩家数据[对方id].角色.数据.道具[数据.道具]].数量-数据.数量
      end
    end
    道具刷新(id)
    道具刷新(对方id)
  elseif 数据.道具==nil then
    if 玩家数据[对方id].摊位数据.bb[数据.bb]==nil then
      常规提示(id,"#Y/这只召唤兽不存在")
      return
    elseif #玩家数据[id].召唤兽.数据>=7 then
      常规提示(id,"#Y/你当前可携带的召唤兽数量已达上限！")
      return
    end
    local 价格=玩家数据[对方id].摊位数据.bb[数据.bb].价格
    if 玩家数据[id].角色.数据.银子<价格 then
      常规提示(id,"#Y/你没有那么多的银子")
      return
    end
    local 道具名称=玩家数据[对方id].摊位数据.bb[数据.bb].名称
    local 道具等级=玩家数据[对方id].摊位数据.bb[数据.bb].等级
    local 道具模型=玩家数据[对方id].摊位数据.bb[数据.bb].模型
    -- local 道具技能=#玩家数据[对方id].摊位数据.bb[数据.bb].技能
    local 道具识别码=玩家数据[对方id].摊位数据.bb[数据.bb].认证码
    玩家数据[id].角色:扣除银子(价格,0,0,"摊位购买",1)
    玩家数据[对方id].角色:添加银子(价格,"摊位出售",1)
    玩家数据[id].角色:日志记录(format("[摊位系统-购买]购买召唤兽[%s][%s][%s][%s]，花费%s两银子,出售者信息：[%s][%s][%s]",道具名称,道具模型,道具等级,道具识别码,价格,账号,对方id,名称))
    玩家数据[对方id].角色:日志记录(format("[摊位系统-出售]出售召唤兽[%s][%s][%s][%s]，花费%s两银子,购买者信息：[%s][%s][%s]",道具名称,道具模型,道具等级,道具识别码,价格,账号1,id,名称1))
    常规提示(对方id,"#W/出售#R/"..道具名称.."#W/成功！")
    常规提示(id,"#W/购买#R/"..道具名称.."#W/成功！")
    玩家数据[id].召唤兽.数据[#玩家数据[id].召唤兽.数据+1]=table.loadstring(table.tostring(玩家数据[对方id].召唤兽.数据[数据.bb]))
    玩家数据[id].召唤兽.数据[#玩家数据[id].召唤兽.数据].认证码 = id.."_"..os.time().."_"..服务端参数.运行时间.."_"..取随机数(111111111111,999999999999)
    玩家数据[对方id].摊位数据.bb[数据.bb] = nil
    玩家数据[对方id].召唤兽.数据[数据.bb] = nil
    --  1 2 3 4 5 6

    local 现有数据 = {}
    local 临时摆摊数据 = {}
    for n = 1, 7 do
      if 玩家数据[对方id].召唤兽.数据[n] ~= nil and 玩家数据[对方id].召唤兽.数据[n] ~= 0 then
        现有数据[#现有数据 + 1] = {
          bb = 玩家数据[对方id].召唤兽.数据[n],
          编号 = n --原本位置
        }
      end
    end

    玩家数据[对方id].召唤兽.数据 = {}
    for n = 1, #现有数据 do
      玩家数据[对方id].召唤兽.数据[n] = 现有数据[n].bb
      for i = 1, 7 do
        if 玩家数据[对方id].摊位数据.bb[i] ~= nil and 玩家数据[对方id].摊位数据.bb[i].id == 现有数据[n].编号 then
            临时摆摊数据[n] = {
              id = n,
              bb = 玩家数据[对方id].摊位数据.bb[i],
              价格 = 玩家数据[对方id].摊位数据.bb[i].价格
          }
        end
      end
    end
    玩家数据[对方id].摊位数据.bb = {}
    for n = 1, 7 do
      if 临时摆摊数据[n] ~= nil then
          玩家数据[对方id].摊位数据.bb[n] = 临时摆摊数据[n].bb
          玩家数据[对方id].摊位数据.bb[n].价格 = 临时摆摊数据[n].价格
          玩家数据[对方id].摊位数据.bb[n].id = 临时摆摊数据[n].id
      end
    end

    if 玩家数据[id].召唤兽.数据[#玩家数据[id].召唤兽.数据].参战信息~=nil then
      玩家数据[id].召唤兽.数据[#玩家数据[id].召唤兽.数据].参战信息=nil
      玩家数据[对方id].角色.参战信息=nil
      玩家数据[对方id].角色.数据.参战宝宝={}
      发送数据(玩家数据[对方id].连接id,18,玩家数据[对方id].角色.数据.参战宝宝)
    end
    发送数据(玩家数据[id].连接id,3512,玩家数据[id].召唤兽.数据)
    发送数据(玩家数据[对方id].连接id,3512,玩家数据[对方id].召唤兽.数据)
  end
  玩家数据[对方id].摊位数据.更新=os.time()
  玩家数据[id].摊位查看=os.time()
  self:索要其他玩家摊位(连接id,id,对方id,3522)
  self:索要摊位数据(玩家数据[对方id].连接id,对方id,3517)
end

function 道具处理类:索要其他玩家摊位(连接id,id,对方id,序号)
  -- if BoothBot:getById(对方id) ~= nil then
  --   发送数据(玩家数据[id].连接id,3520,玩家数据[id].角色.数据.银子)
  --   BoothBot:sendBotBooth(玩家数据[id].连接id,对方id,3517)
  --   return
  -- end
  if 玩家数据[对方id]==nil or 玩家数据[对方id].摊位数据==nil then
    常规提示(id,"#Y/这个摊位并不存在")
    return
  end
  玩家数据[id].摊位查看=os.time()
  玩家数据[id].摊位id=对方id
  发送数据(玩家数据[id].连接id,3520,玩家数据[id].角色.数据.银子)
  发送数据(玩家数据[id].连接id,序号,{bb=玩家数据[对方id].摊位数据.bb,物品=玩家数据[对方id].摊位数据.道具,id=对方id,摊主名称=玩家数据[对方id].角色.数据.名称,名称=玩家数据[对方id].摊位数据.名称})
end

function 道具处理类:索要摊位数据(连接id,id,序号)
  if 玩家数据[id].摊位数据==nil then --新建摊位
    if 玩家数据[id].队伍~=0 then
      常规提示(id,"#Y/组队状态下无法摆摊")
      return
    else
      local 地图=玩家数据[id].角色.数据.地图数据.编号
      if 地图~=1001 and 地图~=1501 and 地图~=1070 and 地图~=1092 and 地图~=1208 and 地图~=1226 and 地图~=1040 then
        常规提示(id,"#Y/该场景无法摆摊")
        return
      elseif 玩家数据[id].角色.数据.等级<30 then
        常规提示(id,"#Y/只有等级达到30级的玩家才可使用摆摊功能")
        return
      end
    end
    玩家数据[id].摊位数据={道具={},bb={},id=id,名称="杂货摊位",摊主=玩家数据[id].角色.数据.名称,更新=os.time()}
    地图处理类:设置玩家摊位(id,"杂货摊位")
  end
  发送数据(玩家数据[id].连接id,3512,玩家数据[id].召唤兽.数据)
  发送数据(玩家数据[id].连接id,3513,玩家数据[id].道具:索要道具2(id))
  --道具刷新(id)
  local bb={}
  for i = 1,7 do
    if 玩家数据[id].摊位数据.bb[i]~=nil then
      bb[i]=玩家数据[id].摊位数据.bb[i].价格
    end
  end
  local 道具={}
  for n=1,20 do
    if 玩家数据[id].摊位数据.道具[n]~=nil then
      道具[n]=玩家数据[id].摊位数据.道具[n].价格
    end
  end
  发送数据(连接id,序号,{bb=bb,物品=道具,id=id,摊主名称=玩家数据[id].角色.数据.名称,名称=玩家数据[id].摊位数据.名称})
end

function 道具处理类:取消交易(id)
  if 玩家数据[id].交易信息~=nil then
    if 玩家数据[玩家数据[id].交易信息.id]~=nil then
      发送数据(玩家数据[玩家数据[id].交易信息.id].连接id,3511)
      常规提示(玩家数据[id].交易信息.id,"#Y/对方取消了交易")
      玩家数据[玩家数据[id].交易信息.id].交易信息=nil
    end
    交易数据[玩家数据[id].交易信息.编号]=nil
    玩家数据[id].交易信息=nil
  end
end

function 道具处理类:取指定道具(编号)
  return table.loadstring(table.tostring(self.数据[编号]))
end

function 道具处理类:发起交易处理(连接id,id,id1)
  if 玩家数据[id1]==nil then
    常规提示(id,"#Y/对方并不在线")
    return
  elseif 地图处理类:比较距离(id,id1,500)==false then
    常规提示(id,"#Y/你们的距离太远了")
    return
  elseif 玩家数据[id1].交易信息~=nil or 玩家数据[id1].摊位数据~=nil then
    常规提示(id,"#Y/对方正忙，请稍后再试")
    return
  elseif 玩家数据[id].交易信息~=nil then
    常规提示(id,"#Y/你上次的交易还没有结束哟~")
    return
  elseif 玩家数据[id1].禁止交易 then
    常规提示(id,"#Y/对方没有打开交易开关")
    return
  end
  交易数据[id]={[id]={},[id1]={}}
  常规提示(id,"你正在和"..玩家数据[id1].角色.数据.名称.."进行交易")
  常规提示(id1,"你正在和"..玩家数据[id].角色.数据.名称.."进行交易")
  发送数据(玩家数据[id].连接id,3512,玩家数据[id].召唤兽.数据)
  发送数据(玩家数据[id1].连接id,3512,玩家数据[id1].召唤兽.数据)
  发送数据(玩家数据[id].连接id,3513,玩家数据[id].道具:索要道具2(id))
  发送数据(玩家数据[id1].连接id,3513,玩家数据[id1].道具:索要道具2(id1))
  发送数据(玩家数据[id].连接id,3514,{名称=玩家数据[id1].角色.数据.名称,等级=玩家数据[id1].角色.数据.等级})
  发送数据(玩家数据[id1].连接id,3514,{名称=玩家数据[id].角色.数据.名称,等级=玩家数据[id].角色.数据.等级})
  玩家数据[id1].交易信息={编号=id,id=id}
  玩家数据[id].交易信息={编号=id,id=id1}
end

function 道具处理类:完成交易处理(id)
  local 交易id=玩家数据[id].交易信息.编号
  local id1=玩家数据[id].交易信息.id
  if 交易数据[交易id][id].锁定 == nil or 交易数据[交易id][id].锁定 == false then
      常规提示(id,"#Y/请先锁定交易")
      return
  elseif 交易数据[交易id][id].锁定 and (交易数据[交易id][id1].锁定 == nil or 交易数据[交易id][id1].锁定 == false ) then
      常规提示(id,"#Y/请耐心等待对方锁定交易状态")
      return
  end
  if id == 交易id and 交易数据[交易id][id].确定 == nil or 交易数据[交易id][id].确定 == false then
      交易数据[交易id][id].确定 = true
  elseif id ~= 交易id and 交易数据[交易id][id1].确定 == nil or 交易数据[交易id][id1].确定 == false then
      交易数据[交易id][id1].确定 = true
  end
  if (id == 交易id  and 交易数据[交易id][id1].确定 ~= nil and 交易数据[交易id][id1].确定) or (id ~= 交易id and 交易数据[交易id][id].确定 ~= nil or 交易数据[交易id][id].确定)  then
    if 玩家数据[id].战斗~=0 or 玩家数据[id1].战斗~=0 then
      常规提示(id,"#Y/战斗中无法使用此功能")
      常规提示(id1,"#Y/战斗中无法使用此功能")
      发送数据(玩家数据[id].连接id,3511)
      发送数据(玩家数据[id1].连接id,3511)
      玩家数据[id1].交易信息=nil
      玩家数据[id].交易信息=nil
      交易数据[交易id]=nil
      return
    elseif 玩家数据[id1].摊位数据~=nil or 玩家数据[id].摊位数据~=nil then
      常规提示(id,"#Y/摆摊状态下无法使用此功能")
      常规提示(id1,"#Y/摆摊状态下无法使用此功能")
      发送数据(玩家数据[id].连接id,3511)
      发送数据(玩家数据[id1].连接id,3511)
      玩家数据[id1].交易信息=nil
      玩家数据[id].交易信息=nil
      交易数据[交易id]=nil
      return
    elseif 地图处理类:比较距离(id,id1,500)==false then
      常规提示(id,"#Y/你们的距离太远了")
      常规提示(id1,"#Y/你们的距离太远了")
      发送数据(玩家数据[id].连接id,3511)
      发送数据(玩家数据[id1].连接id,3511)
      玩家数据[id1].交易信息=nil
      玩家数据[id].交易信息=nil
      交易数据[交易id]=nil
      return
    end
    local 银子=交易数据[交易id][id].银子+0
    local 银子1=交易数据[交易id][id1].银子+0
    if 玩家数据[id].角色.数据.银子<银子 then
      常规提示(id,"#Y/你没有那么多的银子")
      常规提示(id1,"#Y/对方没有那么多的银子")
      发送数据(玩家数据[id].连接id,3511)
      发送数据(玩家数据[id1].连接id,3511)
      玩家数据[id1].交易信息=nil
      玩家数据[id].交易信息=nil
      交易数据[交易id]=nil
      return
    elseif 玩家数据[id1].角色.数据.银子<银子1 then
      常规提示(id1,"#Y/你没有那么多的银子")
      常规提示(id,"#Y/对方没有那么多的银子")
      发送数据(玩家数据[id].连接id,3511)
      发送数据(玩家数据[id1].连接id,3511)
      交易数据[交易id]=nil
      玩家数据[id1].交易信息=nil
      玩家数据[id].交易信息=nil
      return
    end
    --检查道具是否存在
    local 操作id=id
    local 对象id=id1
    for n=1,#交易数据[交易id][操作id].道具 do
      local 道具id=交易数据[交易id][操作id].道具[n].编号
      local 道具id1=玩家数据[操作id].角色.数据.道具[交易数据[交易id][操作id].道具[n].格子]
      if 道具id~=道具id1 or 玩家数据[操作id].道具.数据[道具id]==nil or 玩家数据[操作id].道具.数据[道具id1]==nil or 玩家数据[操作id].道具.数据[道具id1].识别码~=交易数据[交易id][操作id].道具[n].认证码 then
        常规提示(操作id,"#Y/你此次交易的道具数据与锁定前的数据不匹配，本次交易取消")
        常规提示(对象id,"#Y/对方此次交易的道具数据与锁定前的数据不匹配，本次交易取消")
        发送数据(玩家数据[操作id].连接id,3511)
        发送数据(玩家数据[对象id].连接id,3511)
        玩家数据[id1].交易信息=nil
        玩家数据[id].交易信息=nil
        交易数据[交易id]=nil
        return
      elseif 玩家数据[操作id].道具.数据[道具id1].不可交易 then
        常规提示(操作id,"#Y/该道具不可交易给他人，本次交易取消")
        常规提示(对象id,"#Y/对方此次交易存在无法交易的道具，本次交易取消")
        发送数据(玩家数据[操作id].连接id,3511)
        发送数据(玩家数据[对象id].连接id,3511)
        玩家数据[id1].交易信息=nil
        玩家数据[id].交易信息=nil
        交易数据[交易id]=nil
        return
      end
    end
    local 操作id=id1
    local 对象id=id
    for n=1,#交易数据[交易id][操作id].道具 do
      local 道具id=交易数据[交易id][操作id].道具[n].编号
      local 道具id1=玩家数据[操作id].角色.数据.道具[交易数据[交易id][操作id].道具[n].格子]
      if 道具id~=道具id1 or 玩家数据[操作id].道具.数据[道具id]==nil or 玩家数据[操作id].道具.数据[道具id1]==nil or 玩家数据[操作id].道具.数据[道具id1].识别码~=交易数据[交易id][操作id].道具[n].认证码 then
        常规提示(操作id,"#Y/你此次交易的道具数据与锁定前的数据不匹配，本次交易取消")
        常规提示(对象id,"#Y/对方此次交易的道具数据与锁定前的数据不匹配，本次交易取消")
        发送数据(玩家数据[操作id].连接id,3511)
        发送数据(玩家数据[对象id].连接id,3511)
        玩家数据[id1].交易信息=nil
        玩家数据[id].交易信息=nil
        交易数据[交易id]=nil
        return
      elseif 玩家数据[操作id].道具.数据[道具id1].不可交易 then
        常规提示(操作id,"#Y/该道具不可交易给他人，本次交易取消")
        常规提示(对象id,"#Y/对方此次交易存在无法交易的道具，本次交易取消")
        发送数据(玩家数据[操作id].连接id,3511)
        发送数据(玩家数据[对象id].连接id,3511)
        玩家数据[id1].交易信息=nil
        玩家数据[id].交易信息=nil
        交易数据[交易id]=nil
        return
      end
    end
    local 操作id=id
    local 对象id=id1
    for n=1,#交易数据[交易id][操作id].bb do
      local bb编号= 交易数据[交易id][操作id].bb[n].编号
      local 认证码=玩家数据[操作id].召唤兽.数据[bb编号].认证码
      if 认证码~=交易数据[交易id][操作id].bb[n].认证码 then
        常规提示(操作id,"#Y/你此次交易的召唤兽数据与锁定前的数据不匹配，本次交易取消")
        常规提示(对象id,"#Y/对方此次交易的召唤兽数据与锁定前的数据不匹配，本次交易取消")
        发送数据(玩家数据[操作id].连接id,3511)
        发送数据(玩家数据[对象id].连接id,3511)
        玩家数据[id1].交易信息=nil
        玩家数据[id].交易信息=nil
        交易数据[交易id]=nil
        return
      elseif 玩家数据[操作id].召唤兽.数据[bb编号].不可交易 then
        常规提示(操作id,"#Y/该召唤兽不可交易给他人，本次交易取消")
        常规提示(对象id,"#Y/对方此次交易存在无法交易的召唤兽，本次交易取消")
        发送数据(玩家数据[操作id].连接id,3511)
        发送数据(玩家数据[对象id].连接id,3511)
        交易数据[交易id]=nil
        return
      elseif 玩家数据[操作id].召唤兽.数据[bb编号].统御 ~= nil then
        常规提示(操作id,"#Y/已被统御的召唤兽无法进行交易，本次交易取消")
        常规提示(对象id,"#Y/对方此次交易存在无法交易的召唤兽，本次交易取消")
        发送数据(玩家数据[操作id].连接id,3511)
        发送数据(玩家数据[对象id].连接id,3511)
        交易数据[交易id]=nil
        return
      elseif 玩家数据[操作id].角色.参战信息~=nil then
        常规提示(操作id,"#Y/请先取消所有召唤兽参战状态，本次交易取消")
        常规提示(对象id,"#Y/对方尚未取消召唤兽参战状态，本次交易取消")
        发送数据(玩家数据[操作id].连接id,3511)
        发送数据(玩家数据[对象id].连接id,3511)
        玩家数据[id1].交易信息=nil
        玩家数据[id].交易信息=nil
        交易数据[交易id]=nil
        return
      end
    end
    local 操作id=id1
    local 对象id=id
    for n=1,#交易数据[交易id][操作id].bb do
      local bb编号= 交易数据[交易id][操作id].bb[n].编号
      local 认证码=玩家数据[操作id].召唤兽.数据[bb编号].认证码
      if 认证码~=交易数据[交易id][操作id].bb[n].认证码 then
        常规提示(操作id,"#Y/你此次交易的召唤兽数据与锁定前的数据不匹配，本次交易取消")
        常规提示(对象id,"#Y/对方此次交易的召唤兽数据与锁定前的数据不匹配，本次交易取消")
        发送数据(玩家数据[操作id].连接id,3511)
        发送数据(玩家数据[对象id].连接id,3511)
        玩家数据[id1].交易信息=nil
        玩家数据[id].交易信息=nil
        交易数据[交易id]=nil
        return
      elseif 玩家数据[操作id].召唤兽.数据[bb编号].不可交易 then
        常规提示(操作id,"#Y/该召唤兽不可交易给他人，本次交易取消")
        常规提示(对象id,"#Y/对方此次交易存在无法交易的召唤兽，本次交易取消")
        发送数据(玩家数据[操作id].连接id,3511)
        发送数据(玩家数据[对象id].连接id,3511)
        玩家数据[id1].交易信息=nil
        玩家数据[id].交易信息=nil
        交易数据[交易id]=nil
        return
      elseif 玩家数据[操作id].召唤兽.数据[bb编号].统御 ~= nil then
        常规提示(操作id,"#Y/已被坐骑统御的召唤兽不可交易给他人，本次交易取消")
        常规提示(对象id,"#Y/对方此次交易存在无法交易的召唤兽，本次交易取消")
        发送数据(玩家数据[操作id].连接id,3511)
        发送数据(玩家数据[对象id].连接id,3511)
        玩家数据[id1].交易信息=nil
        玩家数据[id].交易信息=nil
        交易数据[交易id]=nil
        return
      elseif 玩家数据[操作id].角色.参战信息~=nil then
        常规提示(操作id,"#Y/请先取消所有召唤兽参战状态，本次交易取消")
        常规提示(对象id,"#Y/对方尚未取消召唤兽参战状态，本次交易取消")
        发送数据(玩家数据[操作id].连接id,3511)
        发送数据(玩家数据[对象id].连接id,3511)
        玩家数据[id1].交易信息=nil
        玩家数据[id].交易信息=nil
        交易数据[交易id]=nil
        return
      end
    end
    local 道具数量=玩家数据[id].角色:取道具格子2()
    local 道具数量1=玩家数据[id1].角色:取道具格子2()
    if 道具数量<#交易数据[交易id][id1].道具 then
      常规提示(id,"#Y/你身上的空间不够")
      常规提示(id1,"#Y/对方身上的空间不够")
      发送数据(玩家数据[id].连接id,3511)
      发送数据(玩家数据[id1].连接id,3511)
      玩家数据[id1].交易信息=nil
      玩家数据[id].交易信息=nil
      交易数据[交易id]=nil
      return
    elseif 道具数量1<#交易数据[交易id][id].道具 then
      常规提示(id1,"#Y/你身上的空间不够")
      常规提示(id,"#Y/对方身上的空间不够")
      发送数据(玩家数据[id].连接id,3511)
      发送数据(玩家数据[id1].连接id,3511)
      玩家数据[id1].交易信息=nil
      玩家数据[id].交易信息=nil
      交易数据[交易id]=nil
      return
    end
    if #玩家数据[id].召唤兽.数据+#交易数据[交易id][id1].bb>7 then
      常规提示(id,"#Y/你可携带的召唤兽数量已达上限")
      常规提示(id1,"#Y/对方可携带的召唤兽数量已达上限")
      发送数据(玩家数据[id].连接id,3511)
      发送数据(玩家数据[id1].连接id,3511)
      玩家数据[id1].交易信息=nil
      玩家数据[id].交易信息=nil
      交易数据[交易id]=nil
      return
    elseif #玩家数据[id1].召唤兽.数据+#交易数据[交易id][id].bb>7 then
      常规提示(id1,"#Y/你可携带的召唤兽数量已达上限")
      常规提示(id,"#Y/对方可携带的召唤兽数量已达上限")
      发送数据(玩家数据[id].连接id,3511)
      发送数据(玩家数据[id1].连接id,3511)
      玩家数据[id1].交易信息=nil
      玩家数据[id].交易信息=nil
      交易数据[交易id]=nil
      return
    end
    --数据转移起始
    local 操作id=id
    local 对象id=id1
    local 账号=玩家数据[操作id].账号
    local 账号1=玩家数据[对象id].账号
    local 名称=玩家数据[操作id].角色.数据.名称
    local 名称1=玩家数据[对象id].角色.数据.名称
    if 交易数据[交易id][操作id].银子>0 then
      local 之前银子=玩家数据[操作id].角色.数据.银子
      玩家数据[操作id].角色.数据.银子 =玩家数据[操作id].角色.数据.银子 -  交易数据[交易id][操作id].银子
      玩家数据[操作id].角色:日志记录(format("[交易系统-扣除银子]给了[%s][%s][%s]银子,银子数额%s,之前数额%s,余额%s",账号1,对象id,名称1,交易数据[交易id][操作id].银子,之前银子,玩家数据[操作id].角色.数据.银子))
      local 之前银子=玩家数据[对象id].角色.数据.银子
      玩家数据[对象id].角色.数据.银子 =玩家数据[对象id].角色.数据.银子 +  交易数据[交易id][操作id].银子
      玩家数据[操作id].角色:日志记录(format("[交易系统-获得银子]获得[%s][%s][%s]银子,银子数额%s,之前数额%s,余额%s",账号,操作id,名称,交易数据[交易id][操作id].银子,之前银子,玩家数据[对象id].角色.数据.银子))
      常规提示(对象id,format("#Y/%s给了你%s两银子",名称,交易数据[交易id][操作id].银子))
      常规提示(操作id,format("#Y/你给了%s%s两银子",名称1,交易数据[交易id][操作id].银子))
    end
    for n=1,#交易数据[交易id][操作id].道具 do
      local 道具id=交易数据[交易id][操作id].道具[n].编号
      local 新格子=玩家数据[对象id].角色:取道具格子()
      local 新id=玩家数据[对象id].道具:取新编号()
      玩家数据[对象id].道具.数据[新id]=玩家数据[操作id].道具:取指定道具(道具id)
      玩家数据[对象id].角色.数据.道具[新格子]=新id
      玩家数据[操作id].道具.数据[道具id]=nil
      玩家数据[操作id].角色.数据.道具[交易数据[交易id][操作id].道具[n].格子]=nil
      local 道具识别码=玩家数据[对象id].道具.数据[新id].识别码
      local 道具名称=玩家数据[对象id].道具.数据[新id].名称
      更改道具归属(道具识别码,账号1,对象id,道具名称)
      玩家数据[操作id].角色:日志记录(format("[交易系统-扣除物品]给了[%s][%s][%s]物品,物品名称为%s,识别码为%s",账号1,对象id,名称1,道具名称,道具识别码))
      玩家数据[对象id].角色:日志记录(format("[交易系统-获得物品]获得[%s][%s][%s]物品,物品名称为%s,识别码为%s",账号,操作id,名称,道具名称,道具识别码))
      常规提示(对象id,format("#Y/%s给了你%s",名称,道具名称))
      常规提示(操作id,format("#Y/你给了%s%s",名称1,道具名称))
    end
    local 操作=false
    for n=1,#交易数据[交易id][操作id].bb do
      玩家数据[对象id].召唤兽.数据[#玩家数据[对象id].召唤兽.数据+1]=table.loadstring(table.tostring(玩家数据[操作id].召唤兽.数据[交易数据[交易id][操作id].bb[n].编号]))
      玩家数据[操作id].召唤兽.数据[交易数据[交易id][操作id].bb[n].编号]=nil
      local bb名称=玩家数据[对象id].召唤兽.数据[#玩家数据[对象id].召唤兽.数据].名称
      local bb模型=玩家数据[对象id].召唤兽.数据[#玩家数据[对象id].召唤兽.数据].模型
      local bb种类=玩家数据[对象id].召唤兽.数据[#玩家数据[对象id].召唤兽.数据].种类
      local bb等级=玩家数据[对象id].召唤兽.数据[#玩家数据[对象id].召唤兽.数据].等级
      local bb认证码=玩家数据[对象id].召唤兽.数据[#玩家数据[对象id].召唤兽.数据].认证码
      玩家数据[操作id].角色:日志记录(format("[交易系统-扣除bb]给了[%s][%s][%s]bb,名称为%s、模型为%s、种类为%s、等级为%s、认证码为%s",账号1,对象id,名称1,bb名称,bb模型,bb种类,bb等级,bb认证码))
      玩家数据[对象id].角色:日志记录(format("[交易系统-获得bb]获得[%s][%s][%s]bb,名称为%s、模型为%s、种类为%s、等级为%s、认证码为%s",账号,操作id,名称,bb名称,bb模型,bb种类,bb等级,bb认证码))
      操作=true
      常规提示(对象id,format("#Y/%s给了你%s",名称,bb名称))
      常规提示(操作id,format("#Y/你给了%s%s",名称1,bb名称))
    end
    local 临时bb={}
    if 操作 then
      for n,v in pairs(玩家数据[操作id].召唤兽.数据) do
        if 玩家数据[操作id].召唤兽.数据[n]~=nil then
          临时bb[#临时bb+1]=玩家数据[操作id].召唤兽.数据[n]
        end
      end
      玩家数据[操作id].召唤兽.数据={}
      玩家数据[操作id].召唤兽.数据=临时bb
      发送数据(玩家数据[操作id].连接id,3512,玩家数据[操作id].召唤兽.数据)
      发送数据(玩家数据[对象id].连接id,3512,玩家数据[操作id].召唤兽.数据)
    end
    --交换数据终止
    local 操作id=id1
    local 对象id=id
    local 账号=玩家数据[操作id].账号
    local 账号1=玩家数据[对象id].账号
    local 名称=玩家数据[操作id].角色.数据.名称
    local 名称1=玩家数据[对象id].角色.数据.名称
    if 交易数据[交易id][操作id].银子>0 then
      local 之前银子=玩家数据[操作id].角色.数据.银子
      玩家数据[操作id].角色.数据.银子 =玩家数据[操作id].角色.数据.银子 -  交易数据[交易id][操作id].银子
      玩家数据[操作id].角色:日志记录(format("[交易系统-扣除银子]给了[%s][%s][%s]银子,银子数额%s,之前数额%s,余额%s",账号1,对象id,名称1,交易数据[交易id][操作id].银子,之前银子,玩家数据[操作id].角色.数据.银子))
      local 之前银子=玩家数据[对象id].角色.数据.银子
      玩家数据[对象id].角色.数据.银子 =玩家数据[对象id].角色.数据.银子 +  交易数据[交易id][操作id].银子
      玩家数据[操作id].角色:日志记录(format("[交易系统-获得银子]获得[%s][%s][%s]银子,银子数额%s,之前数额%s,余额%s",账号,操作id,名称,交易数据[交易id][操作id].银子,之前银子,玩家数据[对象id].角色.数据.银子))
      常规提示(对象id,format("#Y/%s给了你%s两银子",名称,交易数据[交易id][操作id].银子))
      常规提示(操作id,format("#Y/你给了%s%s两银子",名称1,交易数据[交易id][操作id].银子))
    end
    for n=1,#交易数据[交易id][操作id].道具 do
      local 道具id=交易数据[交易id][操作id].道具[n].编号
      local 新格子=玩家数据[对象id].角色:取道具格子()
      local 新id=玩家数据[对象id].道具:取新编号()
      玩家数据[对象id].道具.数据[新id]=玩家数据[操作id].道具:取指定道具(道具id)
      玩家数据[对象id].角色.数据.道具[新格子]=新id
      玩家数据[操作id].道具.数据[道具id]=nil
      玩家数据[操作id].角色.数据.道具[交易数据[交易id][操作id].道具[n].格子]=nil
      local 道具识别码=玩家数据[对象id].道具.数据[新id].识别码
      local 道具名称=玩家数据[对象id].道具.数据[新id].名称
      更改道具归属(道具识别码,账号1,对象id,道具名称)
      玩家数据[操作id].角色:日志记录(format("[交易系统-扣除物品]给了[%s][%s][%s]物品,物品名称为%s,识别码为%s",账号1,对象id,名称1,道具名称,道具识别码))
      玩家数据[对象id].角色:日志记录(format("[交易系统-获得物品]获得[%s][%s][%s]物品,物品名称为%s,识别码为%s",账号,操作id,名称,道具名称,道具识别码))
      常规提示(对象id,format("#Y/%s给了你%s",名称,道具名称))
      常规提示(操作id,format("#Y/你给了%s%s",名称1,道具名称))
    end
    local 操作=false
    for n=1,#交易数据[交易id][操作id].bb do
      玩家数据[对象id].召唤兽.数据[#玩家数据[对象id].召唤兽.数据+1]=table.loadstring(table.tostring(玩家数据[操作id].召唤兽.数据[交易数据[交易id][操作id].bb[n].编号]))
      玩家数据[操作id].召唤兽.数据[交易数据[交易id][操作id].bb[n].编号]=nil
      玩家数据[对象id].召唤兽.数据[#玩家数据[对象id].召唤兽.数据].认证码 = 对象id.."_"..os.time().."_"..服务端参数.运行时间.."_"..取随机数(111111111111,999999999999)
      local bb名称=玩家数据[对象id].召唤兽.数据[#玩家数据[对象id].召唤兽.数据].名称
      local bb模型=玩家数据[对象id].召唤兽.数据[#玩家数据[对象id].召唤兽.数据].模型
      local bb种类=玩家数据[对象id].召唤兽.数据[#玩家数据[对象id].召唤兽.数据].种类
      local bb等级=玩家数据[对象id].召唤兽.数据[#玩家数据[对象id].召唤兽.数据].等级
      local bb认证码=玩家数据[对象id].召唤兽.数据[#玩家数据[对象id].召唤兽.数据].认证码
      玩家数据[操作id].角色:日志记录(format("[交易系统-扣除bb]给了[%s][%s][%s]bb,名称为%s、模型为%s、种类为%s、等级为%s、认证码为%s",账号1,对象id,名称1,bb名称,bb模型,bb种类,bb等级,bb认证码))
      玩家数据[对象id].角色:日志记录(format("[交易系统-获得bb]获得[%s][%s][%s]bb,名称为%s、模型为%s、种类为%s、等级为%s、认证码为%s",账号,操作id,名称,bb名称,bb模型,bb种类,bb等级,bb认证码))
      操作=true
      常规提示(对象id,format("#Y/%s给了你%s",名称,bb名称))
      常规提示(操作id,format("#Y/你给了%s%s",名称1,bb名称))
    end
    local 临时bb={}
    if 操作 then
      for n,v in pairs(玩家数据[操作id].召唤兽.数据) do
        if 玩家数据[操作id].召唤兽.数据[n]~=nil then
          临时bb[#临时bb+1]=玩家数据[操作id].召唤兽.数据[n]
        end
      end
      玩家数据[操作id].召唤兽.数据={}
      玩家数据[操作id].召唤兽.数据=临时bb
      发送数据(玩家数据[操作id].连接id,3512,玩家数据[操作id].召唤兽.数据)
      发送数据(玩家数据[对象id].连接id,3512,玩家数据[对象id].召唤兽.数据)
    end
    发送数据(玩家数据[id].连接id,3511,玩家数据[id].召唤兽.数据)
    发送数据(玩家数据[id1].连接id,3511,玩家数据[id1].召唤兽.数据)
    道具刷新(id)
    道具刷新(id1)
    交易数据[交易id]=nil
    玩家数据[id].交易信息=nil
    玩家数据[id1].交易信息=nil
  end
end

function 道具处理类:设置交易数据(连接id,id,数据)
  if 玩家数据[id].交易信息 == nil then
      常规提示(id,"#Y/交易信息错误，本次交易取消")
      发送数据(玩家数据[id].连接id,3511)
      玩家数据[id].交易信息=nil
      交易数据[id]=nil
      return
  end
  local 交易id=玩家数据[id].交易信息.编号
  local 对方id=玩家数据[id].交易信息.id
  if 交易数据[交易id][id].锁定 and 交易数据[交易id][对方id].锁定==nil then
    常规提示(id,"#Y/请耐心等待对方锁定交易状态")
    return
  end
  local 道具数据={}
  local bb数据={}
  local 银子数据=数据.银子
  交易数据[交易id][id].道具={}
  交易数据[交易id][id].bb={}
  交易数据[交易id][id].银子=银子数据+0
  交易数据[交易id][id].锁定=true
  for n=1,3 do
    local 道具格子=数据.道具[n]
    if 道具格子~=nil then
      道具id=玩家数据[id].角色.数据.道具[道具格子]
      道具数据[#道具数据+1]=self:取指定道具(道具id)
      交易数据[交易id][id].道具[#交易数据[交易id][id].道具+1]={认证码=道具数据[#道具数据].识别码,格子=道具格子,编号=道具id}
    end
  end
  for n=1,3 do
    local bb编号=数据.bb[n]
    if bb编号~=nil then
      bb数据[#bb数据+1]=table.loadstring(table.tostring(玩家数据[id].召唤兽.数据[bb编号]))
      交易数据[交易id][id].bb[#交易数据[交易id][id].bb+1]={认证码=bb数据[#bb数据].认证码,编号=bb编号}
    end
  end
  发送数据(连接id,3508)
  常规提示(id,"#Y/你已经锁定了交易状态，对方锁定交易状态后点击确定即可完成交易")
  常规提示(对方id,"#Y/对方已经锁定了交易状态，等你锁定交易状态后点击确定即可完成交易")
  发送数据(玩家数据[对方id].连接id,3510,{bb=bb数据,道具=道具数据,银子=银子数据})
end

function 道具处理类:系统给予处理(连接id,id,数据)
  local 事件=玩家数据[id].给予数据.事件
  -- print(数据.格子[1],玩家数据[id].角色.数据.道具[数据.格子[1]],self.数据[玩家数据[id].角色.数据.道具[数据.格子[1]]])
  -- if 数据.格子[1]==nil or 玩家数据[id].角色.数据.道具[数据.格子[1]]==nil or self.数据[玩家数据[id].角色.数据.道具[数据.格子[1]]]==nil then
  --   常规提示(id,"#Y/你没有这样的道具")
  --   return
  -- end
  if 事件=="打造角色装备" then
    local 任务id=玩家数据[id].角色:取任务(5)
    if 任务id==0 then
      常规提示(id,"#Y/你没有这样的任务")
      return
    end
    if 检查格子(id)==false then
      常规提示(id,"#Y/你身上没有足够的空间")
      return
    end
    local 道具id=玩家数据[id].角色.数据.道具[数据.格子[1]]
    if self.数据[道具id].名称~=任务数据[任务id].石头 then
      常规提示(id,"#Y/对方需要的不是这种物品")
      return
    end
    if 任务数据[任务id].数量>1 and self.数据[道具id].数量<任务数据[任务id].数量 then
      常规提示(id,"#Y/该物品的数量无法达到要求")
      return
    end
    if 任务数据[任务id].数量>1 then
      self.数据[道具id].数量=self.数据[道具id].数量-任务数据[任务id].数量
    end
    if self.数据[道具id].数量==nil or self.数据[道具id].数量<=0 then
      self.数据[道具id]=nil
      玩家数据[id].角色.数据.道具[数据.格子[1]]=nil
    end
    if 任务数据[任务id].打造类型=="装备" then
      玩家数据[id].装备:添加强化打造装备(id,任务id)
    elseif 任务数据[任务id].打造类型=="灵饰" then
      local 临时id=self:取新编号()
      local 临时格子=玩家数据[id].角色:取道具格子()
      local 道具 = 物品类()
      道具:置对象(任务数据[任务id].名称)
      道具.级别限制 = 任务数据[任务id].级别
      道具.幻化等级=0
      self.数据[临时id]=道具
      self.数据[临时id].部位类型=任务数据[任务id].部位
      self:灵饰处理(id,临时id,任务数据[任务id].级别,1,任务数据[任务id].部位)
      self.数据[临时id].灵饰=true
      self.数据[临时id].耐久=500
      self.数据[临时id].制造者 = 玩家数据[id].角色.数据.名称.."强化打造"
      玩家数据[id].角色.数据.道具[临时格子]=临时id
      常规提示(id,"#Y/你得到了#R/"..self.数据[临时id].名称)
      玩家数据[id].角色:取消任务(任务id)
      任务数据[任务id]=nil
    end
    道具刷新(id)
  elseif 事件=="孩子生活" then
    local 编号 = 玩家数据[id].给予数据.id
    local 道具id=玩家数据[id].角色.数据.道具[数据.格子[1]]
    if 玩家数据[id].孩子.数据[编号] == nil then
      常规提示(id,"#Y/该孩子好像不存在")
      return
    end
    local 时间 = math.ceil((os.time() - 玩家数据[id].孩子.数据[编号].出生日期)/86400)
    if 玩家数据[id].孩子.数据[编号].培养次数[时间] == nil then
      常规提示(id,"#Y/该孩子已经达到成年条件无法继续进行生活培养")
      return
    elseif 玩家数据[id].孩子.数据[编号].培养次数[时间] >= 10 then
      常规提示(id,"#Y/该孩子今日生活次数已经达到上限,每日可学习+生活10次")
      return
    elseif 时间 > 6 then
      常规提示(id,"#Y/该孩子已经达到成年条件,无法再进行生活培养")
      return
    end
    local 名称=self.数据[道具id].名称
    local 加成项目 = ""
    local 加成数值 = 0
    if 名称 == "红木短剑" then
      if 玩家数据[id].孩子.数据[编号].培养.武力 < 30 or 玩家数据[id].孩子.数据[编号].培养.武力 >= 70 then
        常规提示(id,"#Y/该孩子无法使用该物品,要求孩子武力>30或者<=70方可使用")
        return
      end
      加成项目 = "武力"
      加成数值 = 取随机数(3,6)
    elseif 名称 == "竹马" then
      if 玩家数据[id].孩子.数据[编号].培养.武力 > 30 then
        常规提示(id,"#Y/该孩子无法使用该物品,要求孩子武力<30方可使用")
        return
      end
      加成项目 = "武力"
      加成数值 = 取随机数(1,4)
    elseif 名称 == "瑶池蟠桃" then
      if 玩家数据[id].孩子.数据[编号].培养.根骨 < 40 or 玩家数据[id].孩子.数据[编号].培养.根骨 >= 70 then
        常规提示(id,"#Y/该孩子无法使用该物品,要求孩子根骨>40或<=70方可使用")
        return
      end
      加成项目 = "根骨"
      加成数值 = 取随机数(3,6)
    elseif 名称 == "玉灵果" then
      if 玩家数据[id].孩子.数据[编号].培养.根骨 > 40 then
        常规提示(id,"#Y/该孩子无法使用该物品,要求孩子根骨<40方可使用")
        return
      end
      加成项目 = "根骨"
      加成数值 = 取随机数(2,5)
    elseif 名称 == "超级金柳露" then
      if 取随机数() <= 50 then
        加成项目 = "根骨"
      else
        加成项目 = "灵敏"
      end
      if 玩家数据[id].孩子.数据[编号].培养[加成项目] > 70 then
        常规提示(id,"#Y/该孩子无法使用该物品,要求孩子"..加成项目.."<=70方可使用")
        return
      end
      加成数值 = 取随机数(2,5)
    elseif 名称 == "金柳露" then
      if 取随机数() <= 50 then
        加成项目 = "根骨"
      else
        加成项目 = "灵敏"
      end
      if 玩家数据[id].孩子.数据[编号].培养[加成项目] > 50 then
        常规提示(id,"#Y/该孩子无法使用该物品,要求孩子"..加成项目.."<=50方可使用")
        return
      end
      加成数值 = 取随机数(1,4)
    end
    if 加成数值 == 0 then
      常规提示(id,"#Y/孩子生活中无法使用该道具")
      return
    else
      玩家数据[id].孩子.数据[编号].培养[加成项目] = 玩家数据[id].孩子.数据[编号].培养[加成项目] + 加成数值
      self.数据[道具id]=nil
      玩家数据[id].角色.数据.道具[数据.格子[1]]=nil
      常规提示(id,"#Y/孩子在生活中获得无限乐于,竟然意外的提升了"..加成数值..加成项目.."成为天才儿童指日可待")
      玩家数据[id].孩子.数据[编号].培养次数[时间] = 玩家数据[id].孩子.数据[编号].培养次数[时间] + 1
      道具刷新(id)
      发送数据(玩家数据[id].连接id,96.2,{数据=玩家数据[id].孩子.数据[编号],编号=编号})
    end
  elseif 事件=="孤儿领养" then
    local 道具id=玩家数据[id].角色.数据.道具[数据.格子[1]]
    if self.数据[道具id].名称~="孤儿名册" then
      常规提示(id,"#Y/对方需要的不是这种物品")
      return
    elseif #玩家数据[id].孩子.数据 >= 2 then
      常规提示(id,"#Y/你可领养的孩子已经达到了上限")
      return
    else
      local 模型 = "小毛头"
      if 玩家数据[id].角色.数据.种族 == "人" then
        if 取随机数() <= 50 then
          模型 = "小毛头"
        else
          模型 = "小丫丫"
        end
      elseif 玩家数据[id].角色.数据.种族 == "仙" then
        if 取随机数() <= 50 then
          模型 = "小仙女"
        else
          模型 = "小仙灵"
        end
      elseif 玩家数据[id].角色.数据.种族 == "魔" then
        if 取随机数() <= 50 then
          模型 = "小魔头"
        else
          模型 = "小精灵"
        end
      end
      self.数据[道具id]=nil
      玩家数据[id].角色.数据.道具[数据.格子[1]]=nil
      玩家数据[id].孩子:新增孩子(模型)
      常规提示(id,"#Y/领取孤儿成功")
      return
    end
  elseif 事件=="孩子学习" then
    local 道具id=玩家数据[id].角色.数据.道具[数据.格子[1]]
    local 编号 = 玩家数据[id].给予数据.id
    if 玩家数据[id].孩子.数据[编号] == nil then
      常规提示(id,"#Y/该孩子好像不存在")
      return
    end
    local 名称=self.数据[道具id].名称
    local 时间 = math.ceil((os.time() - 玩家数据[id].孩子.数据[编号].出生日期)/86400)
    if 玩家数据[id].孩子.数据[编号].培养次数[时间] ~= nil and 玩家数据[id].孩子.数据[编号].培养次数[时间] >= 10 then
      常规提示(id,"#Y/该孩子今日学习次数已经达到上限,每日可学习+生活10次")
      return
    elseif 玩家数据[id].孩子.数据[编号].培养次数[时间] == nil and (名称 == "山海经" or 名称 == "论语" or 名称 == "搜神记") then
      常规提示(id,"#Y/该孩子已经达到成年条件,无法再进行学习山海经、论语、搜神记等书籍")
      return
    elseif 时间 > 6 and (名称 == "山海经" or 名称 == "论语" or 名称 == "搜神记") then
      常规提示(id,"#Y/该孩子已经达到成年条件,无法再进行学习山海经、论语、搜神记等书籍")
      return
    end
    local 加成项目 = ""
    local 加成数值 = 0
    local 魔兽要诀 = false
    local 特殊武学 = false
    if 管理工具类:取要诀(self.数据[道具id].附带技能) ~= "" or 名称 == "还魂秘术" or 名称 == "蚩尤武诀" or 名称 == "黄帝内经" or 名称 == "奇异果" or 名称 == "六艺修行"  then
      魔兽要诀 = true
    end
    if 魔兽要诀 == false then
      if 名称 == "搜神记" then
        if 玩家数据[id].孩子.数据[编号].培养.智力 < 30 or 玩家数据[id].孩子.数据[编号].培养.智力 >= 70 then
          常规提示(id,"#Y/该孩子无法使用该物品,要求孩子智力>30或者<=70方可使用")
          return
        end
        加成项目 = "智力"
        加成数值 = 取随机数(3,6)
      elseif 名称 == "山海经" then
        if 玩家数据[id].孩子.数据[编号].培养.智力 > 30 then
          常规提示(id,"#Y/该孩子无法使用该物品,要求孩子智力<30方可使用")
          return
        end
        加成项目 = "智力"
        加成数值 = 取随机数(1,5)
      elseif 名称 == "论语" then
        if 玩家数据[id].孩子.数据[编号].培养.定力 > 70 then
          常规提示(id,"#Y/该孩子无法使用该物品,要求孩子定力<70方可使用")
          return
        end
        加成项目 = "定力"
        加成数值 = 取随机数(2,6)
      end
      if 加成数值 == 0 then
        常规提示(id,"#Y/该物品不是儿童学习的道具啊")
        return
      else
        玩家数据[id].孩子.数据[编号].培养[加成项目] = 玩家数据[id].孩子.数据[编号].培养[加成项目] + 加成数值
        self.数据[道具id]=nil
        玩家数据[id].角色.数据.道具[数据.格子[1]]=nil
        常规提示(id,"#Y/孩子在生活中获得无限乐于,竟然意外的提升了"..加成数值..加成项目.."成为天才儿童指日可待")
        玩家数据[id].孩子.数据[编号].培养次数[时间] = 玩家数据[id].孩子.数据[编号].培养次数[时间] + 1
      end
    else
      玩家数据[id].孩子:洗练处理(玩家数据[id].连接id,id,{序列=数据.格子[1],序列1=编号})
    end
    道具刷新(id)
    发送数据(玩家数据[id].连接id,96.2,{数据=玩家数据[id].孩子.数据[编号],编号=编号})
  elseif 事件=="侠义任务物品" then
    local 任务id=玩家数据[id].角色:取任务(346)
    if 任务id==0 then
      常规提示(id,"#Y/你没有这样的任务")
      return
    end
    local 道具id=玩家数据[id].角色.数据.道具[数据.格子[1]]
    if self.数据[道具id] == nil then
      常规提示(id,"#Y/请检查你给予的物品是否存在")
      道具刷新(id)
      return
    end
    local 名称=self.数据[道具id].名称
    local 所需物品=任务数据[任务id].物品
    if 名称=="魔兽要诀" or 名称=="召唤兽内丹" then
      名称=self.数据[道具id].附带技能
    elseif 名称 == "怪物卡片" then
      名称 = self.数据[道具id].造型
    elseif 名称 == "鬼谷子" then
      名称 = self.数据[道具id].子类
    end
    if 名称~=所需物品 then
      常规提示(id,"#Y/对方需要的不是这种物品")
      道具刷新(id)
      return
    end
    if 名称==所需物品 then
      if 所需物品=="青龙石" or 所需物品=="白虎石" or 所需物品=="朱雀石" or 所需物品=="玄武石" then
        if self.数据[道具id].数量<10 then
          常规提示(id,"#Y/你给予的物品不满足条件，强化石需要数量为10个")
          道具刷新(id)
          return
        end
      end
      if self.数据[道具id]~=nil and self.数据[道具id].数量~=nil and self.数据[道具id].数量 >1 then
        if 所需物品=="青龙石" or 所需物品=="白虎石" or 所需物品=="朱雀石" or 所需物品=="玄武石" then
          self.数据[道具id].数量 = self.数据[道具id].数量 - 10
        else
          self.数据[道具id].数量 = self.数据[道具id].数量 - 1
        end
        任务处理类:完成侠义任务(任务id,id)
        道具刷新(id)
      else
        self.数据[道具id]=nil
        玩家数据[id].角色.数据.道具[数据.格子[1]]=nil
        任务处理类:完成侠义任务(任务id,id)
        道具刷新(id)
      end
    end
  elseif 事件=="熔合角色装备" then
    local 任务id=玩家数据[id].角色:取任务(7758)
    if 任务id==0 then
      常规提示(id,"#Y/你没有这样的任务")
      return
    elseif 检查格子(id)==false then
      常规提示(id,"#Y/你身上没有足够的空间")
      return
    end
    if not 任务数据[任务id].完成 then
      if 数据.格子[1] == nil or 数据.格子[2] == nil or 数据.格子[3] == nil then
        常规提示(id,"#Y/我需要3件物品你是不是少给了我一些物品啊")
        return
      end
      local 检测通过={[1]=0,[2]=0,[3]=0}
      for i=1,3 do
        local 道具id=玩家数据[id].角色.数据.道具[数据.格子[i]]
        if self.数据[道具id] == nil then
          常规提示(id,"#Y/请检查你给予的物品是否存在")
          道具刷新(id)
          return
        end
        local 名称 = self.数据[道具id].名称
        if self.数据[道具id].名称 == "高级魔兽要诀" then
          名称 = self.数据[道具id].附带技能
        elseif self.数据[道具id].名称 == "高级召唤兽内丹" then
          名称 = self.数据[道具id].附带技能
        elseif self.数据[道具id].名称 == "怪物卡片" then
          名称 = self.数据[道具id].造型
        end
        for n=1,3 do
          if 名称==任务数据[任务id].物品[n] and self.数据[道具id].数量 == nil then
            检测通过[i] = 1
            break
          elseif 名称==任务数据[任务id].物品[n] and self.数据[道具id].数量 ~= nil and self.数据[道具id].数量 >= 99 then
            检测通过[i] = 1
            break
          end
        end
      end
      for i=1,3 do
        if 检测通过[i] == 0 then
          常规提示(id,"#Y/请检查给予的物品是否是对方需要的物品,或则药品数量是否达到99个")
          return
        end
      end
      if 任务数据[任务id].分类 == 1 then
        玩家数据[id].装备:添加强化打造装备(id,任务id,1)
      else
        if 取随机数() <= 50 then
          玩家数据[id].装备:添加熔合装备属性(id,任务id)
        else
          发送数据(玩家数据[id].连接id,110,任务数据[任务id].星级)
          任务数据[任务id].完成 = true
        end
      end
      for i=1,3 do
        local 道具id=玩家数据[id].角色.数据.道具[数据.格子[i]]
        if self.数据[道具id].数量 ~= nil then
          self.数据[道具id].数量 = self.数据[道具id].数量 - 99
        end
        if self.数据[道具id].数量 == nil or self.数据[道具id].数量 <= 0 then
          self.数据[道具id] = nil
          玩家数据[id].角色.数据.道具[数据.格子[i]] = nil
        end
      end
    else
      if 任务数据[任务id].分类 == 1 then
        玩家数据[id].装备:添加强化打造装备(id,任务id,1)
      else
        玩家数据[id].装备:添加熔合装备属性(id,任务id)
      end
    end
    道具刷新(id)
  elseif 事件=="给予银票" then
    local 道具id=玩家数据[id].角色.数据.道具[数据.格子[1]]
    if self.数据[道具id].名称 ~= "帮派银票" then
        常规提示(id,"#Y/对方需要的不是这种物品")
        return
    end
    if self.数据[道具id].初始金额 < self.数据[道具id].完成金额 then
        常规提示(id,"#Y/还没赚够足够的银票，你这是糊弄我呢？")
        return
    end
    if 释怀定制 == nil or not 释怀定制 then
      if os.time() - 玩家数据[id].角色.数据.跑商时间 <= 120 or 玩家数据[id].角色.数据.跑商时间==nil then
        __S服务:输出("玩家"..id.." 疑似重复刷跑商任务!")
        写配置("./ip封禁.ini","ip",玩家数据[id].ip,1)
        写配置("./ip封禁.ini","ip",玩家数据[id].ip.." 疑似重复刷跑商任务,玩家ID:"..id,1)
        发送数据(玩家数据[id].连接id,998,"请注意你的角色异常！已经对你进行封IP")
        __S服务:断开连接(玩家数据[id].连接id)
        return
      elseif os.time() - 玩家数据[id].角色.数据.跑商时间 <= 180 then
        常规提示(id,"#Y/我这里正在忙着整理商品，请你稍后再来！(3分钟内仅可上交一次)")
        return
      end
    else
      if os.time() - 玩家数据[id].角色.数据.跑商时间 <= 15 or 玩家数据[id].角色.数据.跑商时间==nil then
        __S服务:输出("玩家"..id.." 疑似重复刷跑商任务!")
        写配置("./ip封禁.ini","ip",玩家数据[id].ip,1)
        写配置("./ip封禁.ini","ip",玩家数据[id].ip.." 疑似重复刷跑商任务,玩家ID:"..id,1)
        发送数据(玩家数据[id].连接id,998,"请注意你的角色异常！已经对你进行封IP")
        __S服务:断开连接(玩家数据[id].连接id)
        return
      elseif os.time() - 玩家数据[id].角色.数据.跑商时间 <= 30 then
        常规提示(id,"#Y/我这里正在忙着整理商品，请你稍后再来！(30秒内仅可上交一次)")
        return
      end
    end
    玩家数据[id].角色.数据.道具[数据.格子[1]]=nil
    玩家数据[id].角色.数据.跑商=nil
    玩家数据[id].角色.数据.跑商时间=nil
    local 帮派编号 = 玩家数据[id].角色.数据.帮派数据.编号
    帮派数据[帮派编号].成员数据[id].跑商 = 帮派数据[帮派编号].成员数据[id].跑商 + 1
    if 玩家数据[id].角色.数据.等级>=20 and 玩家数据[id].角色.数据.等级<=39 then
        玩家数据[id].角色:添加经验(50000,"帮派跑商",1)
        玩家数据[id].角色:添加银子(50000,"帮派跑商",1)
        玩家数据[id].角色.数据.帮贡 = 玩家数据[id].角色.数据.帮贡 + 12
        帮派数据[帮派编号].成员数据[id].帮贡.当前 = 帮派数据[帮派编号].成员数据[id].帮贡.当前 + 12
        帮派数据[帮派编号].成员数据[id].帮贡.上限 = 帮派数据[帮派编号].成员数据[id].帮贡.上限 + 12
        帮派数据[帮派编号].繁荣度 = 帮派数据[帮派编号].繁荣度 + 2
    elseif 玩家数据[id].角色.数据.等级>=40 and 玩家数据[id].角色.数据.等级<=59 then
        玩家数据[id].角色:添加经验(80000,"帮派跑商",1)
        玩家数据[id].角色:添加银子(80000,"帮派跑商",1)
        玩家数据[id].角色.数据.帮贡 = 玩家数据[id].角色.数据.帮贡 + 20
        帮派数据[帮派编号].成员数据[id].帮贡.当前 = 帮派数据[帮派编号].成员数据[id].帮贡.当前 + 20
        帮派数据[帮派编号].成员数据[id].帮贡.上限 = 帮派数据[帮派编号].成员数据[id].帮贡.上限 + 20
        帮派数据[帮派编号].繁荣度 = 帮派数据[帮派编号].繁荣度 + 3
    elseif 玩家数据[id].角色.数据.等级>=60 and 玩家数据[id].角色.数据.等级<=79 then
        玩家数据[id].角色:添加经验(120000,"帮派跑商",1)
        玩家数据[id].角色:添加银子(120000,"帮派跑商",1)
        玩家数据[id].角色.数据.帮贡 = 玩家数据[id].角色.数据.帮贡 + 30
        帮派数据[帮派编号].成员数据[id].帮贡.当前 = 帮派数据[帮派编号].成员数据[id].帮贡.当前 + 30
        帮派数据[帮派编号].成员数据[id].帮贡.上限 = 帮派数据[帮派编号].成员数据[id].帮贡.上限 + 30
        帮派数据[帮派编号].繁荣度 = 帮派数据[帮派编号].繁荣度 + 4
    elseif 玩家数据[id].角色.数据.等级>=80 and 玩家数据[id].角色.数据.等级<=99 then
        玩家数据[id].角色:添加经验(200000,"帮派跑商",1)
        玩家数据[id].角色:添加银子(200000,"帮派跑商",1)
        玩家数据[id].角色.数据.帮贡 = 玩家数据[id].角色.数据.帮贡 + 40
        帮派数据[帮派编号].成员数据[id].帮贡.当前 = 帮派数据[帮派编号].成员数据[id].帮贡.当前 + 40
        帮派数据[帮派编号].成员数据[id].帮贡.上限 = 帮派数据[帮派编号].成员数据[id].帮贡.上限 + 40
        帮派数据[帮派编号].繁荣度 = 帮派数据[帮派编号].繁荣度 + 5
    elseif 玩家数据[id].角色.数据.等级>=100 then
        玩家数据[id].角色:添加经验(300000,"帮派跑商",1)
        玩家数据[id].角色:添加银子(300000,"帮派跑商",1)
        玩家数据[id].角色.数据.帮贡 = 玩家数据[id].角色.数据.帮贡 + 60
        帮派数据[帮派编号].成员数据[id].帮贡.当前 = 帮派数据[帮派编号].成员数据[id].帮贡.当前 + 60
        帮派数据[帮派编号].成员数据[id].帮贡.上限 = 帮派数据[帮派编号].成员数据[id].帮贡.上限 + 60
        帮派数据[帮派编号].繁荣度 = 帮派数据[帮派编号].繁荣度 + 6
    end
    帮派数据[帮派编号].帮派资金.当前 = 帮派数据[帮派编号].帮派资金.当前 + self.数据[道具id].初始金额
    if 帮派数据[帮派编号].帮派资金.当前 > 帮派数据[帮派编号].帮派资金.上限 then
        帮派数据[帮派编号].帮派资金.当前 = 帮派数据[帮派编号].帮派资金.上限
    end
    广播帮派消息({内容="[帮派总管]#R/"..玩家数据[id].角色.数据.名称.."#Y/完成跑商任务，帮派资金增加了#R/"..self.数据[道具id].初始金额.."#Y/两。",频道="bp"},帮派编号)
    常规提示(id,"#Y/感谢少侠为帮派的发展做出的贡献！")
    道具刷新(id)
  elseif 事件=="给予金银锦盒" then
    local 道具id=玩家数据[id].角色.数据.道具[数据.格子[1]]
    if self.数据[道具id].名称 ~= "金银锦盒" then
        常规提示(id,"#Y/对方需要的不是这种物品")
        return
    end
    local 增加帮派资金=self.数据[道具id].数量*50000
    local 增加帮贡=self.数据[道具id].数量*10
    玩家数据[id].角色.数据.帮贡=玩家数据[id].角色.数据.帮贡+增加帮贡
    帮派数据[玩家数据[id].角色.数据.帮派数据.编号].成员数据[id].帮贡.当前=帮派数据[玩家数据[id].角色.数据.帮派数据.编号].成员数据[id].帮贡.当前+增加帮贡
    帮派数据[玩家数据[id].角色.数据.帮派数据.编号].成员数据[id].帮贡.上限=帮派数据[玩家数据[id].角色.数据.帮派数据.编号].成员数据[id].帮贡.上限+增加帮贡
    帮派数据[玩家数据[id].角色.数据.帮派数据.编号].帮派资金.当前=帮派数据[玩家数据[id].角色.数据.帮派数据.编号].帮派资金.当前+增加帮派资金
    self.数据[道具id]=nil
    玩家数据[id].角色.数据.道具[数据.格子[1]]=nil
    道具刷新(id)
    常规提示(id,"#Y/成功为帮派增加了#R/"..增加帮派资金.."#Y/两银子。获得了#R/"..增加帮贡.."#Y/点帮贡")
    广播帮派消息({内容="[金库总管]#G/"..玩家数据[id].角色.数据.名称.."#Y/上交金银锦盒为帮派增加了帮派资金#R/"..增加帮派资金.."#Y/万两银子。#93",频道="bp"},玩家数据[id].角色.数据.帮派数据.编号)
  elseif 事件=="精铁兑换打造熟练度" then
    local 道具id=玩家数据[id].角色.数据.道具[数据.格子[1]]
    if self.数据[道具id].名称~="百炼精铁" then
      常规提示(id,"#Y/对方需要的不是这种物品")
      return
    end
    if self.数据[道具id].子类 >70 then
        常规提示(id,"#Y/只有70级以下的精铁才能兑换熟练度")
        return
    end
    local 增加熟练度 = qz(self.数据[道具id].子类/10)
    if 增加熟练度 > 3 then
        增加熟练度 = 3
    end
    玩家数据[id].角色.数据.打造熟练度 = 玩家数据[id].角色.数据.打造熟练度 + 增加熟练度
    常规提示(id,"#Y/恭喜你增加了#R/"..增加熟练度.."#Y/点打造熟练度。当前熟练度为#R/"..玩家数据[id].角色.数据.打造熟练度)
    self.数据[道具id]=nil
    玩家数据[id].角色.数据.道具[数据.格子[1]]=nil
    道具刷新(id)
  elseif 事件=="装备鉴定" then
    local 道具id=玩家数据[id].角色.数据.道具[数据.格子[1]]
    if self.数据[道具id].总类~=2 then
      常规提示(id,"#Y/只有装备才能进行鉴定")
      return
    end
    if self.数据[道具id].鉴定~=false then
      常规提示(id,"#Y/该装备已经鉴定，无需再进行鉴定")
      return
    end
    local 鉴定消耗 = self.数据[道具id].级别限制*100000
    if 取银子(id) < 鉴定消耗 then
      常规提示(id,"#Y/少侠身上的银子不够哦")
      return
    end
    玩家数据[id].角色:扣除银子(鉴定消耗,0,0,"装备鉴定",1)
    if 取随机数()<=70 then
      常规提示(id,"#Y/鉴定失败！")
      return
    else
      self.数据[道具id].鉴定=true
      self.数据[道具id].耐久=500
      道具刷新(id)
      常规提示(id,"#Y/恭喜你，装备鉴定成功!")
    end
  elseif 事件=="上交魔兽残卷" then
    if 玩家数据[id].角色.数据.魔兽残卷 == nil then
      玩家数据[id].角色.数据.魔兽残卷 = 0
    end
    local 道具id=玩家数据[id].角色.数据.道具[数据.格子[1]]
    if self.数据[道具id].名称~="魔兽残卷" then
      常规提示(id,"#Y/你确定给我的是魔兽残卷么")
      return
    else
      local 欠缺 = 300 - 玩家数据[id].角色.数据.魔兽残卷
      if self.数据[道具id].数量 < 欠缺 then
        玩家数据[id].角色.数据.魔兽残卷 = 玩家数据[id].角色.数据.魔兽残卷 + self.数据[道具id].数量
        self.数据[道具id]=nil
        玩家数据[id].角色.数据.道具[数据.格子[1]]=nil
        道具刷新(id)
        常规提示(id,"#Y/上交魔兽残卷成功")
      else
        self.数据[道具id].数量 = self.数据[道具id].数量 - 欠缺
        玩家数据[id].角色.数据.魔兽残卷 = 0
        local 名称="高级魔兽要诀"
        local 技能=取特殊要诀()
        玩家数据[id].道具:给予道具(id,名称,nil,技能)
        玩家数据[id].角色.数据.千亿兽决 = 1
        常规提示(id,"#Y/你获得了"..名称)
        广播消息({内容=format("#S(魔兽残卷)#R/%s#Y累计收集了300份#R魔兽残卷#Y,受到#R唐王#Y大加赞赏,特赐下#G/特殊魔兽要诀-%s#Y以示褒奖！".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,技能),频道="xt"})
      end
    end

  elseif 事件=="上交心魔宝珠" then
    if 玩家数据[id].角色.数据.等级>=50 then
      常规提示(id,"#Y/你已经脱离了新手阶段，无法获得此种奖励")
      return
    elseif 玩家数据[id].角色.数据.等级<15 then
      常规提示(id,"#Y/只有等级达到15级的玩家才可获得此种奖励")
      return
    elseif 心魔宝珠[id]~=nil and 心魔宝珠[id]>=20 then
      常规提示(id,"#Y/请明天再来上交心魔宝珠")
      return
    end
    local 道具id=玩家数据[id].角色.数据.道具[数据.格子[1]]
    local 名称="心魔宝珠"
    local 数量=20
    if self.数据[道具id].名称~=名称 then
      常规提示(id,"#Y/对方需要的不是这种物品")
      return
    end
    if 数量>1 and self.数据[道具id].数量<数量 then
      常规提示(id,"#Y/该物品的数量无法达到要求")
      return
    end
    if 数量>1 then
      self.数据[道具id].数量=self.数据[道具id].数量-数量
    end
    if self.数据[道具id].数量==nil or self.数据[道具id].数量<=0 then
      self.数据[道具id]=nil
      玩家数据[id].角色.数据.道具[数据.格子[1]]=nil
    end
    local 等级=取等级(id)
    local 经验=等级*4000
    local 储备=等级*1000
    玩家数据[id].角色:添加经验(经验,"心魔宝珠奖励")
    玩家数据[id].角色:添加银子(储备,"心魔宝珠奖励",1)
    if 活跃数据[id]==nil then
      活跃数据[id]={活跃度=0,领取100活跃=false,领取200活跃=false,领取300活跃=false,领取400活跃=false,领取500活跃=false,师门次数=20,官职次数=30,鬼怪次数=25,封妖次数=3,游泳次数=1,镖王次数=1,押镖次数=50,水果次数=25,天庭叛逆次数=25,十二星宿次数=5,门派闯关次数=1,地煞星次数=5,天罡星次数=5,飞贼次数=5,知了先锋=20,小知了王=20,知了王=10,世界BOSS次数=2,抓鬼次数=50,初出江湖次数=20,帮派青龙次数=100,帮派玄武次数=100,妖王次数=3}
    end
    活跃数据[id].活跃度=活跃数据[id].活跃度+2
    玩家数据[id].角色.数据.累积活跃.当前积分=玩家数据[id].角色.数据.累积活跃.当前积分+活跃数据[id].活跃度
    玩家数据[id].角色.数据.累积活跃.总积分=玩家数据[id].角色.数据.累积活跃.总积分+活跃数据[id].活跃度
    if 心魔宝珠[id]==nil then
      心魔宝珠[id]=1
    else
      心魔宝珠[id]=心魔宝珠[id]+1
    end
    常规提示(id,format("#Y/你本日还可领取#R/%s#Y/次奖励",(20-心魔宝珠[id])))
    道具刷新(id)
 elseif 事件=="官职任务上交物品" then
    local 任务id=玩家数据[id].角色:取任务(110)
    if 任务id==0 or 任务数据[任务id]==nil then
      常规提示(id,"#Y/你没有这样的任务")
      return
    end
    local 道具id=玩家数据[id].角色.数据.道具[数据.格子[1]]
    local 名称="？？？"
    if 任务数据[任务id].分类==3 then
      名称="情报"
    elseif 任务数据[任务id].分类==4 then
      名称=任务数据[任务id].物品
    end
    if self.数据[道具id].名称~=名称 then
      常规提示(id,"#Y/对方需要的不是这种物品")
      return
    end
    self.数据[道具id]=nil
    玩家数据[id].角色.数据.道具[数据.格子[1]]=nil
    任务处理类:完成官职任务(id,任务数据[任务id].分类)
    道具刷新(id)
  elseif 事件=="门派任务上交物品" then
    local 任务id=玩家数据[id].角色:取任务(111)
    if 任务id==0 or 任务数据[任务id]==nil then
      常规提示(id,"#Y/你没有这样的任务")
      return
    end
    local 道具id=玩家数据[id].角色.数据.道具[数据.格子[1]]
    local 名称=任务数据[任务id].物品
    if self.数据[道具id].名称~=名称 then
      常规提示(id,"#Y/对方需要的不是这种物品")
      return
    end
    local 双倍
    if 任务数据[任务id].品质~=nil and self.数据[道具id].阶品>=任务数据[任务id].品质 then
      双倍=1
    end
    self.数据[道具id]=nil
    玩家数据[id].角色.数据.道具[数据.格子[1]]=nil
    任务处理类:完成门派任务(id,4,双倍)
    道具刷新(id)
  elseif 事件=="商人的鬼魂药材" then
    local 道具id=玩家数据[id].角色.数据.道具[数据.格子[1]]
    local 名称="赤叶甘草"
    if self.数据[道具id].名称~=名称 then
      常规提示(id,"#Y/对方需要的不是这种物品")
      return
    end
    self.数据[道具id]=nil
    玩家数据[id].角色.数据.道具[数据.格子[1]]=nil
    道具刷新(id)
    发送数据(玩家数据[id].连接id,1501,{名称="王大嫂",模型="女人_王大嫂",对话="真是辛苦少侠了。自从先夫去世，大家对我们孤儿寡母一直甚是照顾，我真是无以为报#52",选项={"其实，我也有事相求。听说，牛大胆说您做的红烧鱼特别好吃，非要让我向您讨一份儿#17"}})
  elseif 事件=="商人的鬼魂红烧鱼" then
    local 道具id=玩家数据[id].角色.数据.道具[数据.格子[1]]
    local 名称="红烧鱼"
    if self.数据[道具id].名称~=名称 then
      常规提示(id,"#Y/对方需要的不是这种物品")
      return
    end
    self.数据[道具id]=nil
    玩家数据[id].角色.数据.道具[数据.格子[1]]=nil
    道具刷新(id)
    发送数据(玩家数据[id].连接id,1501,{名称="牛大胆",模型="男人_道士",对话="吧唧吧唧，真好吃，要不是在减肥，真想再吃点啊#80",选项={"开心了吧，快点告诉我，你撞鬼的情形到底怎样嘛#113"}})
  elseif 事件=="商人的鬼魂药引" then
    local 道具id=玩家数据[id].角色.数据.道具[数据.格子[1]]
    local 名称="松风灵芝"
    if self.数据[道具id].名称~=名称 then
      常规提示(id,"#Y/对方需要的不是这种物品")
      return
    end
    self.数据[道具id]=nil
    玩家数据[id].角色.数据.道具[数据.格子[1]]=nil
    道具刷新(id)
    发送数据(玩家数据[id].连接id,1501,{名称="管家",模型="男人_店小二",对话="这下老爷有救了，谢谢少侠#52请少侠一道和我进去看看老爷吧"})
    剧情数据[id].商人的鬼魂.进程=剧情数据[id].商人的鬼魂.进程+1
    玩家数据[id].角色:刷新任务跟踪()
  elseif 事件=="枯萎的金莲包子" then
    local 道具id=玩家数据[id].角色.数据.道具[数据.格子[1]]
    local 名称="包子"
    if self.数据[道具id].名称~=名称 then
      常规提示(id,"#Y/对方需要的不是这种物品")
      return
    end
    if self.数据[道具id].数量<=1 then
      常规提示(id,"#Y/对方需要俩个包子哦")
      return
    end
    if self.数据[道具id]~=nil and self.数据[道具id].数量~=nil and self.数据[道具id].数量 >2 then
      self.数据[道具id].数量 = self.数据[道具id].数量 - 2
      道具刷新(id)
    else
      self.数据[道具id]=nil
      玩家数据[id].角色.数据.道具[数据.格子[1]]=nil
      道具刷新(id)
    end
    发送数据(玩家数据[id].连接id,1501,{名称="雷黑子",模型="小孩_雷黑子",对话="嗝……吃太多包子了，肚子好饱……算了，这次旺财就免费借给你吧，下次还有什么事情找我帮忙，记得带包子给我哦！谢谢啦，我这就去……啊，这狗怎么一溜烟就跑了？没关系，准是去了小花姐那边，你去看看吧。"})
    剧情数据[id].枯萎的金莲.进程=剧情数据[id].枯萎的金莲.进程+1
    玩家数据[id].角色:刷新任务跟踪()
  elseif 事件=="枯萎的金莲金莲" then
    local 道具id=玩家数据[id].角色.数据.道具[数据.格子[1]]
    local 名称="枯萎的金莲"
    if self.数据[道具id].名称~=名称 then
      常规提示(id,"#Y/对方需要的不是这种物品")
      return
    end
    self.数据[道具id]=nil
    玩家数据[id].角色.数据.道具[数据.格子[1]]=nil
    道具刷新(id)
    发送数据(玩家数据[id].连接id,1501,{名称="楚依恋",模型="普陀山_接引仙女",对话="你果真没有辜负我的期望，将金莲找来了！",选项={"我只找到一朵枯萎的金莲……"}})
  elseif 事件=="玄奘的身世百色花" then
    local 道具id=玩家数据[id].角色.数据.道具[数据.格子[1]]
    local 名称="百色花"
    if self.数据[道具id].名称~=名称 then
      常规提示(id,"#Y/对方需要的不是这种物品")
      return
    end
    if self.数据[道具id]~=nil and self.数据[道具id].数量~=nil and self.数据[道具id].数量 >1 then
      self.数据[道具id].数量 = self.数据[道具id].数量 - 1
      道具刷新(id)
    else
      self.数据[道具id]=nil
      玩家数据[id].角色.数据.道具[数据.格子[1]]=nil
      道具刷新(id)
    end
    发送数据(玩家数据[id].连接id,1501,{名称="南极仙翁",模型="南极仙翁",对话="金山寺玄奘乃是金蝉子转世，玄奘此生身世凄惨，少侠可前往看望。"})
    剧情数据[id].玄奘的身世.进程=剧情数据[id].玄奘的身世.进程+1
    玩家数据[id].角色:刷新任务跟踪()
  elseif 事件=="玄奘的身世餐风饮露" then
    local 道具id=玩家数据[id].角色.数据.道具[数据.格子[1]]
    local 名称="餐风饮露"
    if self.数据[道具id].名称~=名称 then
      常规提示(id,"#Y/对方需要的不是这种物品")
      return
    end
    if self.数据[道具id]~=nil and self.数据[道具id].数量~=nil and self.数据[道具id].数量 >1 then
      self.数据[道具id].数量 = self.数据[道具id].数量 - 1
      道具刷新(id)
    else
      self.数据[道具id]=nil
      玩家数据[id].角色.数据.道具[数据.格子[1]]=nil
      道具刷新(id)
    end
    发送数据(玩家数据[id].连接id,1501,{名称="猴医仙",模型="马猴",对话="不错不错，定神香已经炼制完成，少侠拿好！"})
    self:给予道具(id,"定神香",1,1)
    剧情数据[id].玄奘的身世.进程=剧情数据[id].玄奘的身世.进程+1
    玩家数据[id].角色:刷新任务跟踪()
  elseif 事件=="玄奘的身世定神香" then
    local 道具id=玩家数据[id].角色.数据.道具[数据.格子[1]]
    local 名称="定神香"
    if self.数据[道具id].名称~=名称 then
      常规提示(id,"#Y/对方需要的不是这种物品")
      return
    end
    self.数据[道具id]=nil
    玩家数据[id].角色.数据.道具[数据.格子[1]]=nil
    道具刷新(id)
    if 剧情数据[id].玄奘的身世.支线==1 then
      发送数据(玩家数据[id].连接id,1501,{名称="法明长老",模型="空度禅师",对话="感谢少侠，恳请少侠帮忙解决化生寺的危机。",选项={"义不容辞"}})
      剧情数据[id].玄奘的身世.进程=剧情数据[id].玄奘的身世.进程+1
    elseif 剧情数据[id].玄奘的身世.支线==2 then
      发送数据(玩家数据[id].连接id,1501,{名称="法明长老",模型="空度禅师",对话="玄奘是为我从小河中发现的，发现的时候他的身边还有封血书，少侠拿着血书交给玄奘吧！"})
      剧情数据[id].玄奘的身世.进程=20
      玩家数据[id].道具:给予道具(id,"血书",1)
      剧情数据[id].玄奘的身世.支线完成=true
    end
    玩家数据[id].角色:刷新任务跟踪()
  elseif 事件=="玄奘的身世舍利子" then
    local 道具id=玩家数据[id].角色.数据.道具[数据.格子[1]]
    local 名称="佛光舍利子"
    if self.数据[道具id].名称~=名称 then
      常规提示(id,"#Y/对方需要的不是这种物品")
      return
    end
    self.数据[道具id]=nil
    玩家数据[id].角色.数据.道具[数据.格子[1]]=nil
    道具刷新(id)
    发送数据(玩家数据[id].连接id,1501,{名称="空慈方丈",模型="男人_方丈",对话="感谢少侠为化生找回佛光舍利子，法明长老至今昏迷不醒，少侠快去看看法明长老吧"})
    剧情数据[id].玄奘的身世.进程=剧情数据[id].玄奘的身世.进程+1
    玩家数据[id].角色:刷新任务跟踪()
  elseif 事件=="玄奘的身世手镯" then
    local 道具id=玩家数据[id].角色.数据.道具[数据.格子[1]]
    local 名称="少女的手镯"
    if self.数据[道具id].名称~=名称 then
      常规提示(id,"#Y/对方需要的不是这种物品")
      return
    end
    self.数据[道具id]=nil
    玩家数据[id].角色.数据.道具[数据.格子[1]]=nil
    道具刷新(id)
    发送数据(玩家数据[id].连接id,1501,{名称="幽冥鬼",模型="巡游天神",对话="感谢少侠，文秀平安无事，我也可以安心的去投胎了！"})
    剧情数据[id].玄奘的身世.进程=剧情数据[id].玄奘的身世.进程+1
    玩家数据[id].角色:刷新任务跟踪()
  elseif 事件=="玄奘的身世九转回魂丹" then
    local 道具id=玩家数据[id].角色.数据.道具[数据.格子[1]]
    local 名称="九转回魂丹"
    if self.数据[道具id].名称~=名称 then
      常规提示(id,"#Y/对方需要的不是这种物品")
      return
    end
    self.数据[道具id]=nil
    玩家数据[id].角色.数据.道具[数据.格子[1]]=nil
    道具刷新(id)
    发送数据(玩家数据[id].连接id,1501,{名称="玄奘大师",模型="唐僧",对话="感谢少侠相助，少侠是否找到法明长老问明情况？",选项={"给玄奘血书"}})
    剧情数据[id].玄奘的身世.进程=剧情数据[id].玄奘的身世.进程+1
    玩家数据[id].角色:刷新任务跟踪()
  elseif 事件=="玄奘的身世血书" then
    local 道具id=玩家数据[id].角色.数据.道具[数据.格子[1]]
    local 名称="血书"
    if self.数据[道具id].名称~=名称 then
      常规提示(id,"#Y/对方需要的不是这种物品")
      return
    end
    self.数据[道具id]=nil
    玩家数据[id].角色.数据.道具[数据.格子[1]]=nil
    道具刷新(id)
    发送数据(玩家数据[id].连接id,1501,{名称="玄奘大师",模型="唐僧",对话="书云：此儿父讳陈光蕊，官除江州令，妾名殷温娇，亦为相门女，贼子刘洪杀父霸妾，冒官江州，妾恐贼加害此遗腹子，忍痛弃之江中，若蒙善人拾养，妾必感深恩，衔环以报……原来我身世中藏此深仇大恨，父母之仇不能报复，玄奘又何以为人？我，我，我要拿起屠刀，还俗复仇！",选项={"大师切勿冲动"}})
  elseif 事件=="玄奘的身世臭豆腐" then
    local 道具id=玩家数据[id].角色.数据.道具[数据.格子[1]]
    local 名称="臭豆腐"
    if self.数据[道具id].名称~=名称 then
      常规提示(id,"#Y/对方需要的不是这种物品")
      return
    end
    self.数据[道具id]=nil
    玩家数据[id].角色.数据.道具[数据.格子[1]]=nil
    道具刷新(id)
    发送数据(玩家数据[id].连接id,1501,{名称="山神",模型="雨师",对话="好吃好吃，若是再来壶梅花酒就更好了！",选项={"给予梅花酒","得寸进尺（需战斗）"}})
    剧情数据[id].玄奘的身世.进程=剧情数据[id].玄奘的身世.进程+1
    玩家数据[id].角色:刷新任务跟踪()
  elseif 事件=="玄奘的身世梅花酒" then
    local 道具id=玩家数据[id].角色.数据.道具[数据.格子[1]]
    local 名称="梅花酒"
    if self.数据[道具id].名称~=名称 then
      常规提示(id,"#Y/对方需要的不是这种物品")
      return
    end
    self.数据[道具id]=nil
    玩家数据[id].角色.数据.道具[数据.格子[1]]=nil
    道具刷新(id)
    发送数据(玩家数据[id].连接id,1501,{名称="山神",模型="雨师",对话="感谢少侠，这个避水珠少侠拿去吧"})
    剧情数据[id].玄奘的身世.进程=剧情数据[id].玄奘的身世.进程+1
    玩家数据[id].角色:刷新任务跟踪()
    self:给予道具(id,"避水珠",1)
  elseif 事件=="玄奘的身世定颜珠" then
    local 道具id=玩家数据[id].角色.数据.道具[数据.格子[1]]
    local 名称="定颜珠"
    if self.数据[道具id].名称~=名称 then
      常规提示(id,"#Y/对方需要的不是这种物品")
      return
    end
    self.数据[道具id]=nil
    玩家数据[id].角色.数据.道具[数据.格子[1]]=nil
    道具刷新(id)
    发送数据(玩家数据[id].连接id,1501,{名称="龟千岁",模型="龟丞相",对话="感谢少侠为我们寻回定颜珠，少侠是为陈光蕊而来么，这里有一封书信，少侠可拿给殷温娇自然会明白！"})
    剧情数据[id].玄奘的身世.进程=剧情数据[id].玄奘的身世.进程+1
    玩家数据[id].角色:刷新任务跟踪()
  elseif 事件=="玄奘的身世烤鸭" then
    local 道具id=玩家数据[id].角色.数据.道具[数据.格子[1]]
    local 名称="烤鸭"
    if self.数据[道具id].名称~=名称 then
      常规提示(id,"#Y/对方需要的不是这种物品")
      return
    end
    self.数据[道具id]=nil
    玩家数据[id].角色.数据.道具[数据.格子[1]]=nil
    道具刷新(id)
    发送数据(玩家数据[id].连接id,1501,{名称="婆婆",模型="女人_孟婆",对话="感谢少侠救了我！",选项={"要治好婆婆的眼睛必须得丁香水，龟千岁那里好像有"}})
    剧情数据[id].玄奘的身世.进程=剧情数据[id].玄奘的身世.进程+1
    玩家数据[id].角色:刷新任务跟踪()
  elseif 事件=="玄奘的身世丁香水" then
    local 道具id=玩家数据[id].角色.数据.道具[数据.格子[1]]
    local 名称="丁香水"
    if self.数据[道具id].名称~=名称 then
      常规提示(id,"#Y/对方需要的不是这种物品")
      return
    end
    self.数据[道具id]=nil
    玩家数据[id].角色.数据.道具[数据.格子[1]]=nil
    道具刷新(id)
    发送数据(玩家数据[id].连接id,1501,{名称="婆婆",模型="女人_孟婆",对话="我终于可以看见了，感谢少侠！",选项={"不用客气，应该的！"}})
    剧情数据[id].玄奘的身世.进程=剧情数据[id].玄奘的身世.进程+1
    玩家数据[id].角色:刷新任务跟踪()
  elseif 事件=="玄奘的身世金香玉" then
    local 道具id=玩家数据[id].角色.数据.道具[数据.格子[1]]
    local 名称="金香玉"
    if self.数据[道具id].名称~=名称 then
      常规提示(id,"#Y/对方需要的不是这种物品")
      return
    end
    self.数据[道具id]=nil
    玩家数据[id].角色.数据.道具[数据.格子[1]]=nil
    道具刷新(id)
    发送数据(玩家数据[id].连接id,1501,{名称="殷丞相",模型="考官2",对话="感谢少侠，我这里公务走不开，请求少侠帮忙去金銮殿帮忙请并剿贼。"})
    剧情数据[id].玄奘的身世.进程=剧情数据[id].玄奘的身世.进程+1
    玩家数据[id].角色:刷新任务跟踪()
  elseif 事件=="寻找四琉璃白琉璃碎片" then
    local 道具id=玩家数据[id].角色.数据.道具[数据.格子[1]]
    local 名称="白琉璃碎片"
    if self.数据[道具id].名称~=名称 then
      常规提示(id,"#Y/对方需要的不是这种物品")
      return
    end
    self.数据[道具id]=nil
    玩家数据[id].角色.数据.道具[数据.格子[1]]=nil
    道具刷新(id)
    发送数据(玩家数据[id].连接id,1501,{名称="卷帘大将",模型="沙僧",对话="这......这是白琉璃碎片，就因为打碎了琉璃盏，才被惩罚于此接受万箭穿心之痛，能否请少侠帮忙寻找剩余的琉璃盏碎片？好像女儿村那边遇到了点麻烦",选项={"乐意之至","我很忙"}})
    剧情数据[id].寻找四琉璃.进程=剧情数据[id].寻找四琉璃.进程+1
    玩家数据[id].角色:刷新任务跟踪()
  elseif 事件=="寻找四琉璃金琉璃碎片" then
    local 道具id=玩家数据[id].角色.数据.道具[数据.格子[1]]
    local 名称="金琉璃碎片"
    if self.数据[道具id].名称~=名称 then
      常规提示(id,"#Y/对方需要的不是这种物品")
      return
    end
    self.数据[道具id]=nil
    玩家数据[id].角色.数据.道具[数据.格子[1]]=nil
    道具刷新(id)
    发送数据(玩家数据[id].连接id,1501,{名称="卷帘大将",模型="沙僧",对话="这......少侠这么快就找到了金琉璃碎片，非常感谢"})
    剧情数据[id].寻找四琉璃.进程=剧情数据[id].寻找四琉璃.进程+1
    玩家数据[id].角色:刷新任务跟踪()
  elseif 事件=="寻找四琉璃青琉璃碎片" then
    local 道具id=玩家数据[id].角色.数据.道具[数据.格子[1]]
    local 名称="青琉璃碎片"
    if self.数据[道具id].名称~=名称 then
      常规提示(id,"#Y/对方需要的不是这种物品")
      return
    end
    self.数据[道具id]=nil
    玩家数据[id].角色.数据.道具[数据.格子[1]]=nil
    道具刷新(id)
    发送数据(玩家数据[id].连接id,1501,{名称="卷帘大将",模型="沙僧",对话="没想到少侠这么快就找到了三块琉璃碎片，还差最后一块碎片了，那我又可以回到天庭了，感谢少侠"})
    剧情数据[id].寻找四琉璃.进程=剧情数据[id].寻找四琉璃.进程+1
    玩家数据[id].角色:刷新任务跟踪()
  elseif 事件=="寻找四琉璃紫琉璃碎片" then
    local 道具id=玩家数据[id].角色.数据.道具[数据.格子[1]]
    local 名称="紫琉璃碎片"
    if self.数据[道具id].名称~=名称 then
      常规提示(id,"#Y/对方需要的不是这种物品")
      return
    end
    self.数据[道具id]=nil
    玩家数据[id].角色.数据.道具[数据.格子[1]]=nil
    道具刷新(id)
    发送数据(玩家数据[id].连接id,1501,{名称="卷帘大将",模型="沙僧",对话="感谢少侠帮忙找到了四琉璃碎片，还请少侠帮忙告知王母琉璃盏复原一事，请她信守承诺，让我官复原职。"})
    剧情数据[id].寻找四琉璃.进程=剧情数据[id].寻找四琉璃.进程+1
    玩家数据[id].角色:刷新任务跟踪()
  elseif 事件=="寻找四琉璃女儿红" then
    local 道具id=玩家数据[id].角色.数据.道具[数据.格子[1]]
    local 名称="女儿红"
    if self.数据[道具id].名称~=名称 then
      常规提示(id,"#Y/对方需要的不是这种物品")
      return
    end
    self.数据[道具id]=nil
    玩家数据[id].角色.数据.道具[数据.格子[1]]=nil
    道具刷新(id)
    发送数据(玩家数据[id].连接id,1501,{名称="卷帘大将",模型="沙僧",对话="没想到少侠还知道我好这一口，非常感谢少侠！","这个是阿紫姑娘让我送来的"})
    剧情数据[id].寻找四琉璃.进程=剧情数据[id].寻找四琉璃.进程+1
    玩家数据[id].角色:刷新任务跟踪()
  elseif 事件=="寻找四琉璃金香玉" then
    local 道具id=玩家数据[id].角色.数据.道具[数据.格子[1]]
    local 名称="金香玉"
    if self.数据[道具id].名称~=名称 then
      常规提示(id,"#Y/对方需要的不是这种物品")
      return
    end
    self.数据[道具id]=nil
    玩家数据[id].角色.数据.道具[数据.格子[1]]=nil
    道具刷新(id)
    发送数据(玩家数据[id].连接id,1501,{名称="青琉璃",模型="星灵仙子",对话="呼，多谢你，我伤势已无大碍。能除掉翻天怪我的心愿已了，我知道你是为什么人而来的，我现在就跟你回去。"})
    剧情数据[id].寻找四琉璃.进程=剧情数据[id].寻找四琉璃.进程+1
    玩家数据[id].角色:刷新任务跟踪()
    self:给予道具(id,"青琉璃碎片",1)
  elseif 事件=="大战心魔火凤之睛" then
    local 道具id=玩家数据[id].角色.数据.道具[数据.格子[1]]
    local 名称="火凤之睛"
    if self.数据[道具id].名称~=名称 then
      常规提示(id,"#Y/对方需要的不是这种物品")
      return
    end
    if self.数据[道具id]~=nil and self.数据[道具id].数量~=nil and self.数据[道具id].数量 >1 then
      self.数据[道具id].数量 = self.数据[道具id].数量 - 1
    else
      self.数据[道具id]=nil
      玩家数据[id].角色.数据.道具[数据.格子[1]]=nil
    end
    道具刷新(id)
    发送数据(玩家数据[id].连接id,1501,{名称="青莲仙女",模型="普陀_接引仙女",对话="不错，这个仙露拿去救治人参果树吧"})
    剧情数据[id].大战心魔.进程=剧情数据[id].大战心魔.进程+1
    玩家数据[id].角色:刷新任务跟踪()
    self:给予道具(id,"仙露",1)
  elseif 事件=="大战心魔仙露" then
    local 道具id=玩家数据[id].角色.数据.道具[数据.格子[1]]
    local 名称="仙露"
    if self.数据[道具id].名称~=名称 then
      常规提示(id,"#Y/对方需要的不是这种物品")
      return
    end
    if self.数据[道具id]~=nil and self.数据[道具id].数量~=nil and self.数据[道具id].数量 >1 then
      self.数据[道具id].数量 = self.数据[道具id].数量 - 1
    else
      self.数据[道具id]=nil
      玩家数据[id].角色.数据.道具[数据.格子[1]]=nil
    end
    道具刷新(id)
    发送数据(玩家数据[id].连接id,1501,{名称="清风",模型="男人_道童",对话="人参果树是救活了，但是拾取人参果的金击子还流落在外，少侠帮我寻回来我就把这妖怪还你"})
    剧情数据[id].大战心魔.进程=剧情数据[id].大战心魔.进程+1
    玩家数据[id].角色:刷新任务跟踪()
  elseif 事件=="大战心魔金击子" then
    local 道具id=玩家数据[id].角色.数据.道具[数据.格子[1]]
    local 名称="金击子"
    if self.数据[道具id].名称~=名称 then
      常规提示(id,"#Y/对方需要的不是这种物品")
      return
    end
    if self.数据[道具id]~=nil and self.数据[道具id].数量~=nil and self.数据[道具id].数量 >1 then
      self.数据[道具id].数量 = self.数据[道具id].数量 - 1
    else
      self.数据[道具id]=nil
      玩家数据[id].角色.数据.道具[数据.格子[1]]=nil
    end
    道具刷新(id)
    发送数据(玩家数据[id].连接id,1501,{名称="清风",模型="男人_道童",对话="感谢少侠，这个妖怪就交给少侠了！",选项={"呼！天心星算是归为了！"}})
    剧情数据[id].大战心魔.进程=剧情数据[id].大战心魔.进程+1
    玩家数据[id].角色:刷新任务跟踪()
  elseif 事件=="大战心魔醉生梦死" then
    local 道具id=玩家数据[id].角色.数据.道具[数据.格子[1]]
    local 名称="醉生梦死"
    if self.数据[道具id].名称~=名称 then
      常规提示(id,"#Y/对方需要的不是这种物品")
      return
    end
    if self.数据[道具id]~=nil and self.数据[道具id].数量~=nil and self.数据[道具id].数量 >1 then
      self.数据[道具id].数量 = self.数据[道具id].数量 - 1
    else
      self.数据[道具id]=nil
      玩家数据[id].角色.数据.道具[数据.格子[1]]=nil
    end
    道具刷新(id)
    发送数据(玩家数据[id].连接id,1501,{名称="守门天将",模型="天兵",对话="好酒好酒，来我们再喝",选项={"能否让我看看火尖枪","我们继续喝"}})
    剧情数据[id].大战心魔.进程=剧情数据[id].大战心魔.进程+1
    玩家数据[id].角色:刷新任务跟踪()
  elseif 事件=="大战心魔火尖枪" then
    local 道具id=玩家数据[id].角色.数据.道具[数据.格子[1]]
    local 名称="火尖枪"
    if self.数据[道具id].名称~=名称 then
      常规提示(id,"#Y/对方需要的不是这种物品")
      return
    end
    if self.数据[道具id]~=nil and self.数据[道具id].数量~=nil and self.数据[道具id].数量 >1 then
      self.数据[道具id].数量 = self.数据[道具id].数量 - 1
    else
      self.数据[道具id]=nil
      玩家数据[id].角色.数据.道具[数据.格子[1]]=nil
    end
    道具刷新(id)
    发送数据(玩家数据[id].连接id,1501,{名称="哪吒",模型="男人_哪吒",对话="感谢少侠，你可以去找我父亲了！"})
    剧情数据[id].大战心魔.进程=剧情数据[id].大战心魔.进程+1
    玩家数据[id].角色:刷新任务跟踪()
  elseif 事件=="含冤的小白龙高级宠物口粮" then
    local 道具id=玩家数据[id].角色.数据.道具[数据.格子[1]]
    local 名称="高级宠物口粮"
    if self.数据[道具id].名称~=名称 then
      常规提示(id,"#Y/对方需要的不是这种物品")
      return
    end
    if self.数据[道具id]~=nil and self.数据[道具id].数量~=nil and self.数据[道具id].数量 >1 then
      self.数据[道具id].数量 = self.数据[道具id].数量 - 1
    else
      self.数据[道具id]=nil
      玩家数据[id].角色.数据.道具[数据.格子[1]]=nil
    end
    道具刷新(id)
    发送数据(玩家数据[id].连接id,1501,{名称="毛驴张",模型="男人_老伯",对话="感谢少侠，这个鞭子就交给少侠处理了"})
    剧情数据[id].含冤的小白龙.进程=剧情数据[id].含冤的小白龙.进程+1
    玩家数据[id].角色:刷新任务跟踪()
    self:给予道具(id,"玄天铁鞭",1)
  elseif 事件=="含冤的小白龙玄天铁鞭" then
    local 道具id=玩家数据[id].角色.数据.道具[数据.格子[1]]
    local 名称="玄天铁鞭"
    if self.数据[道具id].名称~=名称 then
      常规提示(id,"#Y/对方需要的不是这种物品")
      return
    end
    if self.数据[道具id]~=nil and self.数据[道具id].数量~=nil and self.数据[道具id].数量 >1 then
      self.数据[道具id].数量 = self.数据[道具id].数量 - 1
    else
      self.数据[道具id]=nil
      玩家数据[id].角色.数据.道具[数据.格子[1]]=nil
    end
    道具刷新(id)
    发送数据(玩家数据[id].连接id,1501,{名称="大力战神",模型="风伯",对话="感谢少侠帮忙找回玄天铁鞭",选项={"要被行刑的是谁呢？"}})
    剧情数据[id].含冤的小白龙.进程=剧情数据[id].含冤的小白龙.进程+1
    玩家数据[id].角色:刷新任务跟踪()
  elseif 事件=="含冤的小白龙龙须草" then
    local 道具id=玩家数据[id].角色.数据.道具[数据.格子[1]]
    local 名称="龙须草"
    if self.数据[道具id].名称~=名称 then
      常规提示(id,"#Y/对方需要的不是这种物品")
      return
    end
    if self.数据[道具id]~=nil and self.数据[道具id].数量~=nil and self.数据[道具id].数量 >1 then
      self.数据[道具id].数量 = self.数据[道具id].数量 - 1
    else
      self.数据[道具id]=nil
      玩家数据[id].角色.数据.道具[数据.格子[1]]=nil
    end
    道具刷新(id)
    if 剧情数据[id].含冤的小白龙.进程==17 then
      发送数据(玩家数据[id].连接id,1501,{名称="万圣公主",模型="女人_万圣公主",对话="你这傻瓜，三言两语就被我骗过了，其实龙须草根本就不是什么龙宫祖传之物，九头精怪也根本没有逼我，这些只不过是我们夫妻二人的计划而已！你被我利用了！",选项={"好你个万圣公主（需战斗）","原来你们是这样的人"}})
    elseif 剧情数据[id].含冤的小白龙.进程==18 then
      发送数据(玩家数据[id].连接id,1501,{名称="王母娘娘",模型="女人_王母",对话="现在知道问题了吧，行了，你走吧！",选项={"感谢王母娘娘"}})
      剧情数据[id].含冤的小白龙.进程=剧情数据[id].含冤的小白龙.进程+1
      玩家数据[id].角色:刷新任务跟踪()
    end
  elseif 事件=="含冤的小白龙餐风饮露" then
    local 道具id=玩家数据[id].角色.数据.道具[数据.格子[1]]
    local 名称="餐风饮露"
    if self.数据[道具id].名称~=名称 then
      常规提示(id,"#Y/对方需要的不是这种物品")
      return
    end
    if self.数据[道具id]~=nil and self.数据[道具id].数量~=nil and self.数据[道具id].数量 >1 then
      self.数据[道具id].数量 = self.数据[道具id].数量 - 1
    else
      self.数据[道具id]=nil
      玩家数据[id].角色.数据.道具[数据.格子[1]]=nil
    end
    道具刷新(id)
    发送数据(玩家数据[id].连接id,1501,{名称="玉皇大帝",模型="男人_玉帝",对话="既然菩萨出面了，自然要给菩萨这个面子，这是镇塔之宝，拿去吧！"})
    剧情数据[id].含冤的小白龙.进程=剧情数据[id].含冤的小白龙.进程+1
    玩家数据[id].角色:刷新任务跟踪()
    self:给予道具(id,"镇塔之宝",1)
  elseif 事件=="含冤的小白龙镇塔之宝" then
    local 道具id=玩家数据[id].角色.数据.道具[数据.格子[1]]
    local 名称="镇塔之宝"
    if self.数据[道具id].名称~=名称 then
      常规提示(id,"#Y/对方需要的不是这种物品")
      return
    end
    if self.数据[道具id]~=nil and self.数据[道具id].数量~=nil and self.数据[道具id].数量 >1 then
      self.数据[道具id].数量 = self.数据[道具id].数量 - 1
    else
      self.数据[道具id]=nil
      玩家数据[id].角色.数据.道具[数据.格子[1]]=nil
    end
    道具刷新(id)
    发送数据(玩家数据[id].连接id,1501,{名称="镇塔之神",模型="男人_将军",对话="感谢少侠帮忙找回镇塔之宝，另外想请少侠帮忙把这个碧水青龙交给小白龙，告知他，他的冤情我已帮他洗清，天庭已经还他清白。"})
    剧情数据[id].含冤的小白龙.进程=剧情数据[id].含冤的小白龙.进程+1
    玩家数据[id].角色:刷新任务跟踪()
    self:给予道具(id,"碧水青龙",1)
  elseif 事件=="含冤的小白龙碧水青龙" then
    local 道具id=玩家数据[id].角色.数据.道具[数据.格子[1]]
    local 名称="碧水青龙"
    if self.数据[道具id].名称~=名称 then
      常规提示(id,"#Y/对方需要的不是这种物品")
      return
    end
    if self.数据[道具id]~=nil and self.数据[道具id].数量~=nil and self.数据[道具id].数量 >1 then
      self.数据[道具id].数量 = self.数据[道具id].数量 - 1
    else
      self.数据[道具id]=nil
      玩家数据[id].角色.数据.道具[数据.格子[1]]=nil
    end
    道具刷新(id)
    发送数据(玩家数据[id].连接id,1501,{名称="小白龙",模型="男人_小白龙",对话="多谢少侠，为我平刷冤屈，我愿变成龙马，西去取经，修得正果，造福世人！"})
    剧情数据[id].含冤的小白龙.完成=true
    玩家数据[id].角色.数据.剧情点=玩家数据[id].角色.数据.剧情点+13
    常规提示(id,"#Y恭喜你，完成了#G含冤的小白龙#Y剧情，获得了#R13点#Y剧情点。")
    玩家数据[id].角色:取消任务(玩家数据[id].角色:取任务(6000))
  elseif 事件=="青龙任务给予药品" then
    local 任务id=玩家数据[id].角色:取任务(301)
    if 任务id==0 or 任务数据[任务id]==nil then
      常规提示(id,"#Y/你没有这样的任务")
      return
    end
    local 道具id=玩家数据[id].角色.数据.道具[数据.格子[1]]
    local 名称=任务数据[任务id].药品
    if self.数据[道具id].名称~=名称 then
      常规提示(id,"#Y/对方需要的不是这种物品")
      return
    end
    if self.数据[道具id]~=nil and self.数据[道具id].数量~=nil and self.数据[道具id].数量 >1 then
      self.数据[道具id].数量 = self.数据[道具id].数量 - 1
      任务处理类:完成青龙任务(任务id,id,2)
      道具刷新(id)
    else
      self.数据[道具id]=nil
      玩家数据[id].角色.数据.道具[数据.格子[1]]=nil
      任务处理类:完成青龙任务(任务id,id,2)
      道具刷新(id)
    end
  elseif 事件=="青龙任务给予烹饪" then
    local 任务id=玩家数据[id].角色:取任务(301)
    if 任务id==0 or 任务数据[任务id]==nil then
      常规提示(id,"#Y/你没有这样的任务")
      return
    end
    local 道具id=玩家数据[id].角色.数据.道具[数据.格子[1]]
    local 名称=任务数据[任务id].烹饪
    if self.数据[道具id].名称~=名称 then
      常规提示(id,"#Y/对方需要的不是这种物品")
      return
    end
    if self.数据[道具id]~=nil and self.数据[道具id].数量~=nil and self.数据[道具id].数量 >1 then
      self.数据[道具id].数量 = self.数据[道具id].数量 - 1
      任务处理类:完成青龙任务(任务id,id,3)
      道具刷新(id)
    else
      self.数据[道具id]=nil
      玩家数据[id].角色.数据.道具[数据.格子[1]]=nil
      任务处理类:完成青龙任务(任务id,id,3)
      道具刷新(id)
    end
  elseif 事件=="玄武任务给予药品" then
    local 任务id=玩家数据[id].角色:取任务(302)
    if 任务id==0 or 任务数据[任务id]==nil then
      常规提示(id,"#Y/你没有这样的任务")
      return
    end
    local 道具id=玩家数据[id].角色.数据.道具[数据.格子[1]]
    local 名称=任务数据[任务id].药品
    if 道具id==nil or self.数据[道具id].名称==nil or self.数据[道具id].名称~=名称 then
      常规提示(id,"#Y/对方需要的不是这种物品")
      return
    end
    local id组 = 取id组(id)
    if self.数据[道具id]~=nil and self.数据[道具id].数量~=nil and self.数据[道具id].数量 >1 then
      self.数据[道具id].数量 = self.数据[道具id].数量 - 1
      任务处理类:完成玄武任务(任务id,id组,2)
      道具刷新(id)
    else
      self.数据[道具id]=nil
      玩家数据[id].角色.数据.道具[数据.格子[1]]=nil
      任务处理类:完成玄武任务(任务id,id组,2)
      道具刷新(id)
    end
  elseif 事件=="玄武任务给予烹饪" then
    local 任务id=玩家数据[id].角色:取任务(302)
    if 任务id==0 or 任务数据[任务id]==nil then
      常规提示(id,"#Y/你没有这样的任务")
      return
    end
    local 道具id=玩家数据[id].角色.数据.道具[数据.格子[1]]
    local 名称=任务数据[任务id].烹饪
    if self.数据[道具id].名称~=名称 then
      常规提示(id,"#Y/对方需要的不是这种物品")
      return
    end
    local id组 = 取id组(id)
    if self.数据[道具id]~=nil and self.数据[道具id].数量~=nil and self.数据[道具id].数量 >1 then
      self.数据[道具id].数量 = self.数据[道具id].数量 - 1
      任务处理类:完成玄武任务(任务id,id组,3)
      道具刷新(id)
    else
      self.数据[道具id]=nil
      玩家数据[id].角色.数据.道具[数据.格子[1]]=nil
      任务处理类:完成玄武任务(任务id,id组,3)
      道具刷新(id)
    end
  elseif 事件=="坐骑任务给予烹饪" then
    local 任务id=玩家数据[id].角色:取任务(307)
    if 任务id==0 or 任务数据[任务id]==nil then
      常规提示(id,"#Y/你没有这样的任务")
      return
    end
    local 道具id=玩家数据[id].角色.数据.道具[数据.格子[1]]
    local 名称=任务数据[任务id].烹饪
    if self.数据[道具id].名称~=名称 then
      常规提示(id,"#Y/对方需要的不是这种物品")
      return
    end
    if self.数据[道具id]~=nil and self.数据[道具id].数量~=nil and self.数据[道具id].数量 >1 then
        self.数据[道具id].数量 = self.数据[道具id].数量 - 1
        任务数据[任务id].分类=3
        发送数据(玩家数据[id].连接id,1501,{名称="太白金星",模型="太白金星",对话=format("天宫的千里眼能眼观天下，他也许知道天马的消息！"),选项={"我这就去"}})
        道具刷新(id)
        玩家数据[id].角色:刷新任务跟踪()
    else
        self.数据[道具id]=nil
        玩家数据[id].角色.数据.道具[数据.格子[1]]=nil
        任务数据[任务id].分类=3
        发送数据(玩家数据[id].连接id,1501,{名称="太白金星",模型="太白金星",对话=format("天宫的千里眼能眼观天下，他也许知道天马的消息！"),选项={"我这就去"}})
        道具刷新(id)
        玩家数据[id].角色:刷新任务跟踪()
    end
  elseif 事件=="坐骑任务给予药品" then
    local 任务id=玩家数据[id].角色:取任务(307)
    if 任务id==0 or 任务数据[任务id]==nil then
      常规提示(id,"#Y/你没有这样的任务")
      return
    end
    local 道具id=玩家数据[id].角色.数据.道具[数据.格子[1]]
    local 名称=任务数据[任务id].药品
    if self.数据[道具id].名称~=名称 then
      常规提示(id,"#Y/对方需要的不是这种物品")
      return
    end
    if self.数据[道具id]~=nil and self.数据[道具id].数量~=nil and self.数据[道具id].数量 >1 then
        self.数据[道具id].数量 = self.数据[道具id].数量 - 1
        任务数据[任务id].分类=12
        发送数据(玩家数据[id].连接id,1501,{名称="大大王",模型="大大王",对话=format("听说马儿跑了到建业一带，少侠可以去那里找找"),选项={"我这就去建业看看"}})
        道具刷新(id)
        玩家数据[id].角色:刷新任务跟踪()
    else
        self.数据[道具id]=nil
        玩家数据[id].角色.数据.道具[数据.格子[1]]=nil
        任务数据[任务id].分类=12
        发送数据(玩家数据[id].连接id,1501,{名称="大大王",模型="大大王",对话=format("听说马儿跑了到建业一带，少侠可以去那里找找"),选项={"我这就去建业看看"}})
        道具刷新(id)
        玩家数据[id].角色:刷新任务跟踪()
    end
  elseif 事件=="飞升任务给予药品" then
    local 任务id=玩家数据[id].角色:取任务("飞升剧情")
    if 任务id==0 or 任务数据[任务id]==nil then
      常规提示(id,"#Y/你没有这样的任务")
      return
    end
    local 道具id=玩家数据[id].角色.数据.道具[数据.格子[1]]
    if self.数据[道具id].名称~=任务数据[任务id].药品.药品.名称 and self.数据[道具id].名称~=任务数据[任务id].药品.药品1.名称 then
      常规提示(id,"#Y/对方需要的不是这种物品")
      return
    end
    if self.数据[道具id].名称==任务数据[任务id].药品.药品.名称 then
        任务数据[任务id].药品.药品.获得=true
    elseif self.数据[道具id].名称==任务数据[任务id].药品.药品1.名称 then
        任务数据[任务id].药品.药品1.获得=true
    end
    if self.数据[道具id]~=nil and self.数据[道具id].数量~=nil and self.数据[道具id].数量 >1 then
        self.数据[道具id].数量 = self.数据[道具id].数量 - 1
    else
        self.数据[道具id]=nil
        玩家数据[id].角色.数据.道具[数据.格子[1]]=nil
    end
    道具刷新(id)
    if 任务数据[任务id].药品.药品.获得 and 任务数据[任务id].药品.药品1.获得 then
      if 任务数据[任务id].进程==3 then
          任务数据[任务id].进程=4
          发送数据(玩家数据[id].连接id,1501,{名称="太上老君",模型="男人_太上老君",对话=format("嗯，你做的很好。看来你的确潜心向道。我要向玉皇大帝引见你，让你获得进行仙界的试练资格。")})
          发送数据(玩家数据[id].连接id,39)
          任务数据[任务id].药品=nil
          玩家数据[id].角色:刷新任务跟踪()
      elseif 任务数据[任务id].进程==5 and 任务数据[任务id].四法宝.炼金鼎==false then
          任务数据[任务id].四法宝.炼金鼎=true
          玩家数据[id].道具:给予道具(id,"炼金鼎",1,nil,nil,"专用")
          发送数据(玩家数据[id].连接id,39)
          发送数据(玩家数据[id].连接id,1501,{名称="镇元子",模型="镇元子",对话=format("嗯，好！这就是你要的炼金鼎！")})
          玩家数据[id].角色:刷新任务跟踪()
      end
    else
      if 任务数据[任务id].进程==3 then
          发送数据(玩家数据[id].连接id,1501,{名称="太上老君",模型="男人_太上老君",对话=format("还有一味药呢")})
      elseif 任务数据[任务id].进程==5 then
          发送数据(玩家数据[id].连接id,1501,{名称="镇元子",模型="镇元子",对话=format("还有一味药呢")})
      end
    end
  elseif 事件=="飞升任务给予武器" then
    local 任务id=玩家数据[id].角色:取任务("飞升剧情")
    if 任务id==0 or 任务数据[任务id]==nil then
      常规提示(id,"#Y/你没有这样的任务")
      return
    end
    local 道具id=玩家数据[id].角色.数据.道具[数据.格子[1]]
    local 名称=任务数据[任务id].所需武器
    if self.数据[道具id].名称~=名称 or self.数据[道具id].总类~=2 or self.数据[道具id].分类~=3 then
      常规提示(id,"#Y/对方需要的不是这种物品")
      return
    end
    self.数据[道具id]=nil
    玩家数据[id].角色.数据.道具[数据.格子[1]]=nil
    任务数据[任务id].四法宝.定海针=true
    任务数据[任务id].触发龙宫=nil
    玩家数据[id].道具:给予道具(id,"定海针",1,nil,nil,"专用")
    发送数据(玩家数据[id].连接id,39)
    发送数据(玩家数据[id].连接id,1501,{名称="东海龙王",模型="东海龙王",对话=format("这是镇海针，你要好好护送它到玉帝那！")})
    道具刷新(id)
    玩家数据[id].角色:刷新任务跟踪()
  elseif 事件=="飞升任务给予法器" then
    local 任务id=玩家数据[id].角色:取任务("飞升剧情")
    if 任务id==0 or 任务数据[任务id]==nil then
      常规提示(id,"#Y/你没有这样的任务")
      return
    end
    local 道具id=玩家数据[id].角色.数据.道具[数据.格子[1]]
    if self.数据[道具id].名称~="定海针" and self.数据[道具id].名称~="避火诀" and self.数据[道具id].名称~="修篁斧" and self.数据[道具id].名称~="炼金鼎" then
      常规提示(id,"#Y/对方需要的不是这种物品")
      return
    end
    self.数据[道具id]=nil
    玩家数据[id].角色.数据.道具[数据.格子[1]]=nil
    任务数据[任务id].四法宝.进度=任务数据[任务id].四法宝.进度+1
    if 任务数据[任务id].四法宝.进度==4 then
        发送数据(玩家数据[id].连接id,1501,{名称="玉皇大帝",模型="男人_玉帝",对话=format("要你找的这四样宝贝暗含四象之妙，可以激发你的潜力，如果再加上地藏王的不死壤，那么五行妙法就齐备了。可惜自从大禹治水后，就再也没有人见过不死壤了。天庭已经没有什么好教你的了，你再去人界修炼妙法吧。")})
        任务数据[任务id].进程=6
        玩家数据[id].角色:刷新任务跟踪()
    else
        发送数据(玩家数据[id].连接id,1501,{名称="玉皇大帝",模型="男人_玉帝",对话=format("剩余的几样东西呢？")})
    end
    发送数据(玩家数据[id].连接id,39)
    道具刷新(id)
  elseif 事件=="飞升任务给予烹饪" then
    local 任务id=玩家数据[id].角色:取任务("飞升剧情")
    if 任务id==0 or 任务数据[任务id]==nil then
      常规提示(id,"#Y/你没有这样的任务")
      return
    end
    local 道具id=玩家数据[id].角色.数据.道具[数据.格子[1]]
    local 名称=任务数据[任务id].烹饪
    if self.数据[道具id].名称~=名称 then
      常规提示(id,"#Y/对方需要的不是这种物品")
      return
    end
    if self.数据[道具id]~=nil and self.数据[道具id].数量~=nil and self.数据[道具id].数量 >1 then
        self.数据[道具id].数量 = self.数据[道具id].数量 - 1
    else
        self.数据[道具id]=nil
        玩家数据[id].角色.数据.道具[数据.格子[1]]=nil
    end
    任务数据[任务id].征求意见.春十三娘=true
    任务数据[任务id].触发春十三娘=nil
    常规提示(id,"获得春十三娘的同意")
    发送数据(玩家数据[id].连接id,1501,{名称="春十三娘",模型="春十三娘",对话=format("嗯，东西不错。我没什么意见了，反正不死壤我也没兴趣。")})
    道具刷新(id)
    玩家数据[id].角色:刷新任务跟踪()
  elseif 事件=="飞升任务给予兽诀" then
    local 任务id=玩家数据[id].角色:取任务("飞升剧情")
    if 任务id==0 or 任务数据[任务id]==nil then
      常规提示(id,"#Y/你没有这样的任务")
      return
    end
    local 道具id=玩家数据[id].角色.数据.道具[数据.格子[1]]
    local 名称=任务数据[任务id].所需兽诀
    if self.数据[道具id].附带技能~=名称 then
      常规提示(id,"#Y/对方需要的不是这种物品")
      return
    end
    if self.数据[道具id]~=nil and self.数据[道具id].数量~=nil and self.数据[道具id].数量 >1 then
        self.数据[道具id].数量 = self.数据[道具id].数量 - 1
    else
        self.数据[道具id]=nil
        玩家数据[id].角色.数据.道具[数据.格子[1]]=nil
    end
    任务数据[任务id].征求意见.大大王=true
    任务数据[任务id].触发大大王=nil
    任务数据[任务id].触发兽诀=nil
    常规提示(id,"获得大大王的同意")
    发送数据(玩家数据[id].连接id,1501,{名称="大大王",模型="大大王",对话=format("嗯，不错不错，我没意见了！")})
    道具刷新(id)
    玩家数据[id].角色:刷新任务跟踪()
  elseif 事件=="法宝任务给予药品" then
    local 任务id=玩家数据[id].角色:取任务(308)
    if 任务id==0 or 任务数据[任务id]==nil then
      常规提示(id,"#Y/你没有这样的任务")
      return
    end
    local 道具id=玩家数据[id].角色.数据.道具[数据.格子[1]]
    local 名称=任务数据[任务id].物品
    if self.数据[道具id].名称~=名称 then
      常规提示(id,"#Y/对方需要的不是这种物品")
      return
    end
    if self.数据[道具id]~=nil and self.数据[道具id].数量~=nil and self.数据[道具id].数量 >1 then
        self.数据[道具id].数量 = self.数据[道具id].数量 - 1
    else
        self.数据[道具id]=nil
        玩家数据[id].角色.数据.道具[数据.格子[1]]=nil
    end
    if 玩家数据[id].角色.法宝进程==1 then
        发送数据(玩家数据[id].连接id,1501,{名称="金童子",模型="男人_道童",对话=format("少侠已经集齐法宝合成的材料了，可以来天宫找我领取内丹任务进行法宝合成哦")})
    end
    任务处理类:完成法宝任务(任务id,id,2)
    道具刷新(id)
  elseif 事件=="法宝任务给予烹饪" then
    local 任务id=玩家数据[id].角色:取任务(308)
    if 任务id==0 or 任务数据[任务id]==nil then
      常规提示(id,"#Y/你没有这样的任务")
      return
    end
    local 道具id=玩家数据[id].角色.数据.道具[数据.格子[1]]
    local 名称=任务数据[任务id].物品
    if self.数据[道具id].名称~=名称 then
      常规提示(id,"#Y/对方需要的不是这种物品")
      return
    end
    if self.数据[道具id]~=nil and self.数据[道具id].数量~=nil and self.数据[道具id].数量 >1 then
        self.数据[道具id].数量 = self.数据[道具id].数量 - 1
    else
        self.数据[道具id]=nil
        玩家数据[id].角色.数据.道具[数据.格子[1]]=nil
    end
    if 玩家数据[id].角色.法宝进程==1 then
        发送数据(玩家数据[id].连接id,1501,{名称="金童子",模型="男人_道童",对话=format("少侠已经集齐法宝合成的材料了，可以来天宫找我领取内丹任务进行法宝合成哦")})
    end
    任务处理类:完成法宝任务(任务id,id,3)
    道具刷新(id)
  elseif 事件=="渡劫任务上交武器" then
    local 任务id=玩家数据[id].角色:取任务(8800)
    if 任务id==0 or 任务数据[任务id]==nil then
      常规提示(id,"#Y/你没有这样的任务")
      return
    end
    local 道具id=玩家数据[id].角色.数据.道具[数据.格子[1]]
    local 名称=任务数据[任务id].所需武器
    if self.数据[道具id].名称~=名称 and self.数据[道具id].总类~=2 and self.数据[道具id].分类~=3 then
      常规提示(id,"#Y/对方需要的不是这种物品")
      return
    end
    self.数据[道具id]=nil
    玩家数据[id].角色.数据.道具[数据.格子[1]]=nil
    发送数据(玩家数据[id].连接id,39)
    发送数据(玩家数据[id].连接id,1501,{名称="妄空妖魔",模型="海星",对话=format("很好，陷阱已经布置完成了，等待勇士们和天冷曰妄空的到来。")})
    道具刷新(id)
    剧情数据[id].渡劫.进程=13
    任务处理类:取渡劫任务(id)
    玩家数据[id].角色:刷新任务跟踪()
  elseif 事件=="门派任务上交乾坤袋" then
    local 任务id=玩家数据[id].角色:取任务(111)
    --print(任务id,任务数据[任务id])
    if 任务id==0 or 任务数据[任务id]==nil then
      常规提示(id,"#Y/你没有这样的任务")
      return
    end
    local 道具id=玩家数据[id].角色.数据.道具[数据.格子[1]]
    local 名称="乾坤袋"
    if self.数据[道具id].名称~=名称 then
      常规提示(id,"#Y/对方需要的不是这种物品")
      return
    elseif 任务数据[任务id].乾坤袋==nil then
      常规提示(id,"#Y/你似乎还没有完成这个任务哟~")
      return
    end
    self.数据[道具id]=nil
    玩家数据[id].角色.数据.道具[数据.格子[1]]=nil
    任务处理类:完成门派任务(id,7,双倍)
    道具刷新(id)
  elseif 事件=="偷偷怪上交物品" then
    local 道具id=玩家数据[id].角色.数据.道具[数据.格子[1]]
    local 名称=self.数据[道具id].名称
    if 玩家数据[id].角色.数据.五宝数据[名称]==nil then
      添加最后对话(id,"我要的是金刚石、龙鳞、定魂珠、避水珠、夜光珠，你给我的是个啥玩意？")
      return
    elseif 玩家数据[id].角色.数据.五宝数据[名称]~=0 then
      添加最后对话(id,"您可真是贵人多忘事，您不是已经给了我"..名称.."吗？这么快就忘记了？是到了要喝脑白金的年纪吗？")
      return
    end
    玩家数据[id].角色.数据.五宝数据[名称]=1
    self.数据[道具id]=nil
    玩家数据[id].角色.数据.道具[数据.格子[1]]=nil
    local 满足=true
    for n=1,#五宝名称 do
      if 玩家数据[id].角色.数据.五宝数据[五宝名称[n]]==0 then
        满足=false
      end
    end
    if 满足 then
      玩家数据[id].角色.数据.五宝数据={夜光珠=0,龙鳞=0,定魂珠=0,避水珠=0,金刚石=0}
      self:给予道具(id,"特赦令牌")
      添加最后对话(id,"这块特赦令牌你可收好了，要是给了那些在地狱里无法进入轮回的鬼怪，说不定可以得到什么好东西呢！")
      常规提示(id,"#Y你获得了#R特赦令牌")
    end
    道具刷新(id)
  elseif 事件=="无名野鬼上交物品" then
    local 道具id=玩家数据[id].角色.数据.道具[数据.格子[1]]
    local 名称="特赦令牌"
    if self.数据[道具id].名称~=名称 then
      添加最后对话(id,"我需要的是特赦令牌，你给我的这个能当饭吃吗？")
      return
    end
    self.数据[道具id]=nil
    玩家数据[id].角色.数据.道具[数据.格子[1]]=nil
    self:给予道具(id,"高级藏宝图")
    添加最后对话(id,"您可真是大好人啊，这块特赦令牌终于让我能离开这地狱了。我这里有一张高级藏宝图你拿去吧，就当你做好事的回报。")
    常规提示(id,"#Y你获得了#R高级藏宝图")
    道具刷新(id)
  elseif 事件=="点化装备" then
    local 道具id=玩家数据[id].角色.数据.道具[数据.格子[1]]
    if self.数据[道具id].总类~=2 or self.数据[道具id].灵饰 or self.数据[道具id].分类==9 then
      添加最后对话(id,"我这里目前只能点化人物装备，其它的我可没那么大的能耐。")
      return
    end
    local 银子=self.数据[道具id].级别限制*5000
    if 玩家数据[id].角色.数据.银子<银子 then
      添加最后对话(id,format("本次点化需要消耗#Y%s#W两银子，你似乎手头有点紧哟？",银子))
      return
    end
    玩家数据[id].角色:扣除银子(银子,0,0,"点化装备",1)
    local 套装类型={"附加状态","追加法术"}
    套装类型=套装类型[取随机数(1,#套装类型)]
    local 套装效果={
    附加状态={
      "金刚护法","金刚护体","生命之泉","炼气化神","普渡众生","定心术","碎星诀","变身"}
      ,追加法术={"横扫千军","善恶有报","惊心一剑","壁垒击破","满天花雨","浪涌","唧唧歪歪","五雷咒","龙卷雨击"}
    }
    self.数据[道具id].套装效果={套装类型,套装效果[套装类型][取随机数(1,#套装效果[套装类型])]}
    玩家数据[id].角色:取消任务(玩家数据[id].角色:取任务(14))
    玩家数据[id].角色:刷新任务跟踪()
    添加最后对话(id,format("点化装备成功,您本次点化后的套装效果为#Y%s：%s",self.数据[道具id].套装效果[1],self.数据[道具id].套装效果[2]),{"继续点化","告辞"})
  elseif 事件=="合成旗4" then --补充
    local 道具id=玩家数据[id].角色.数据.道具[数据.格子[1]]
    if self.数据[道具id].总类~=11 or  self.数据[道具id].分类~=2 then
      常规提示(id,"#Y我只可以为合成旗补充次数哟。")
      return
    elseif self.数据[道具id].次数>=140 then
      常规提示(id,"#Y你的这个合成旗次数已经满了")
      return
    end
    local 编号=玩家数据[id].法宝id
    if 玩家数据[id].角色.数据.法宝[编号]==nil or self.数据[玩家数据[id].角色.数据.法宝[编号]]==nil or self.数据[玩家数据[id].角色.数据.法宝[编号]].名称~="五色旗盒" then
      常规提示(id,"#Y你没有这样的法宝")
      return
    end
    local 灵气=140-self.数据[道具id].次数
    灵气=math.floor(灵气/5)
    if 灵气<1 then 灵气=1 end
    if 灵气>self.数据[玩家数据[id].角色.数据.法宝[编号]].魔法 then
      常规提示(id,"#Y本次补充需要消耗#R"..灵气.."#Y点法宝灵气，你的法宝没有那么多的灵气")
      return
    end
    self.数据[玩家数据[id].角色.数据.法宝[编号]].魔法=self.数据[玩家数据[id].角色.数据.法宝[编号]].魔法-灵气
    self.数据[道具id].次数=140
    发送数据(连接id,38,{内容="你的法宝#R/五色旗盒#W/灵气减少了"..灵气.."点"})
    常规提示(id,"#Y补充成功！你的这个合成旗可使用次数已经恢复到140次了")
    道具刷新(id)
  elseif 事件=="合成旗" then
    -- table.print(数据.格子)
    local 道具id={}
    for n=1,#数据.格子 do
      if 数据.格子[n]~=nil  then
        道具id[n]=数据.格子[n]
        local 临时id=玩家数据[id].角色.数据.道具[数据.格子[n]]
        if self.数据[临时id].总类~=11 and self.数据[临时id].分类~=1 then
          常规提示(id,"#Y只有导标旗才可以合成哟")
          return
        end
      end
    end
    if 玩家数据[id].合成旗序列==nil then
      玩家数据[id].合成旗序列={}
      for n=1,#道具id do
        local 临时id=玩家数据[id].角色.数据.道具[道具id[n]]
        for i=1,#道具id do
          local 临时id1=玩家数据[id].角色.数据.道具[道具id[i]]
          if i~=n and 临时id1==临时id then
            常规提示(id,"#Y合成的导标旗中存在重复导标旗")
            return
          elseif i~=n and self.数据[临时id].地图~=self.数据[临时id1].地图 then
            常规提示(id,"#Y合成的导标旗定标场景必须为同一个")
            return
          end
        end
      end
    else
      for n=1,#道具id do
        local 临时id=玩家数据[id].角色.数据.道具[道具id[n]]
        if 玩家数据[id].合成旗序列.地图~=nil and 玩家数据[id].合成旗序列.地图~=self.数据[临时id].地图 then
          常规提示(id,"#Y只有#R"..取地图名称(玩家数据[id].合成旗序列.地图).."#Y的导标旗才可合成")
          return
        end
        for i=1,#道具id do
          local 临时id1=玩家数据[id].角色.数据.道具[道具id[i]]
          if i~=n and 临时id1==临时id then
            常规提示(id,"#Y合成的导标旗中存在重复导标旗")
            return
          end
        end
        for i=1,#玩家数据[id].合成旗序列 do
          local 临时id1=玩家数据[id].角色.数据.道具[玩家数据[id].合成旗序列[i]]
          if  临时id1==临时id then
            常规提示(id,"#Y合成的导标旗中存在重复导标旗")
            return
          end
        end
      end
    end
    local 编号=玩家数据[id].法宝id
    if 玩家数据[id].角色.数据.法宝[编号]==nil or self.数据[玩家数据[id].角色.数据.法宝[编号]]==nil or self.数据[玩家数据[id].角色.数据.法宝[编号]].名称~="五色旗盒" then
      常规提示(id,"#Y你没有这样的法宝")
      return
    end
    local 上限=7
    if self.数据[玩家数据[id].角色.数据.法宝[编号]].气血<=0 then
      上限=3
    elseif self.数据[玩家数据[id].角色.数据.法宝[编号]].气血<=2 then
      上限=4
    elseif self.数据[玩家数据[id].角色.数据.法宝[编号]].气血<=5 then
      上限=5
    elseif self.数据[玩家数据[id].角色.数据.法宝[编号]].气血<=8 then
      上限=6
    elseif self.数据[玩家数据[id].角色.数据.法宝[编号]].气血<=9 then
      上限=7
    end
    for n=1,#道具id do
      if #玩家数据[id].合成旗序列<上限 then
        if 玩家数据[id].合成旗序列.地图==nil then
          玩家数据[id].合成旗序列.地图=self.数据[玩家数据[id].角色.数据.道具[道具id[n]]].地图
        end
        玩家数据[id].合成旗序列[#玩家数据[id].合成旗序列+1]=道具id[n]
      end
    end
    if #玩家数据[id].合成旗序列==上限 then
      local aa ="请选择超级合成旗的颜色："
      local xx={"绿色合成旗","蓝色合成旗","红色合成旗","白色合成旗","黄色合成旗",}
      发送数据(连接id,1501,{名称="五色旗盒",对话=aa,选项=xx})
      玩家数据[id].最后操作="合成旗3"
    else
      玩家数据[id].给予数据={类型=1,id=0,事件="合成旗"}
      发送数据(连接id,3507,{道具=玩家数据[id].道具:索要道具1(id),名称="五色旗盒",类型="法宝",等级="无"})
      玩家数据[id].最后操作="合成旗2"
      常规提示(id,format("#Y你已提交%s个导标旗，还需要提交%s个导标旗",#玩家数据[id].合成旗序列,上限-#玩家数据[id].合成旗序列))
    end
  elseif 事件=="装备出售" then
    local 道具id=玩家数据[id].角色.数据.道具[数据.格子[1]]
    if self.数据[道具id] == nil then
      return
    end
    if self.数据[道具id].总类~=2 or self.数据[道具id].灵饰 or self.数据[道具id].分类==9 then
      添加最后对话(id,"我这里只收购人物装备哟，其它的破铜烂铁我可是不收滴哟。")
      return
    end
    玩家数据[id].出售装备=数据.格子[1]
    玩家数据[id].最后操作="出售装备"
    添加最后对话(id,format("你的这件#Y%s#W我将以#R%s#W两银子进行收购，请确认是否出售该装备？",self.数据[道具id].名称,self:取装备价格(道具id)),{"确认出售","我不卖了"})
  elseif 事件=="法宝补充灵气" then
    local 道具id=玩家数据[id].角色.数据.法宝[数据.格子[1]]
    if self.数据[道具id].总类~=1000 then
      添加最后对话(id,"只有法宝才可以补充灵气哟，你这个是什么玩意？")
      return
    end
    local 价格=2000000
    if self.数据[道具id].分类==2 then
      价格=3500000
    elseif self.数据[道具id].分类==3 then
      价格=6000000
    end
    if 玩家数据[id].角色.数据.银子<价格 then
      添加最后对话(id,"本次补充法宝灵气需要消耗"..价格.."两银子，你身上没有那么多的现金哟。")
      return
    end
    玩家数据[id].角色:扣除银子(价格,0,0,"补充法宝扣除，法宝名称为"..self.数据[道具id].名称,1)
    self.数据[道具id].魔法=取灵气上限(self.数据[道具id].分类)
    添加最后对话(id,"补充法宝灵气成功！")
  elseif 事件=="宠修物品" then
    local 任务id=玩家数据[id].角色:取任务(13)
    if 任务id==0 then
      添加最后对话(id,"你没有这个任务！")
      return
    end
    local 道具id=玩家数据[id].角色.数据.道具[数据.格子[1]]
    if self.数据[道具id].名称~=任务数据[任务id].物品  then
      添加最后对话(id,"我拿这个玩意用来干啥？")
      return
    end
    if self.数据[道具id].数量~=nil and self.数据[道具id].数量>0 then
      self.数据[道具id].数量=self.数据[道具id].数量-1
      if self.数据[道具id].数量<=0 then
        self.数据[道具id]=nil
        玩家数据[id].角色.数据.道具[数据.格子[1]]=nil
      end
    else
      self.数据[道具id]=nil
      玩家数据[id].角色.数据.道具[数据.格子[1]]=nil
    end
    道具刷新(id)
    任务处理类:完成宠修任务(id,任务id)
  elseif 事件=="任务链物品" then
    local 任务id=玩家数据[id].角色:取任务(15)
    if 任务id==0 then
      添加最后对话(id,"你没有这个任务！")
      return
    end
    local 道具id=玩家数据[id].角色.数据.道具[数据.格子[1]]
    if self.数据[道具id].名称~=任务数据[任务id].物品  then
      添加最后对话(id,"我拿这个玩意用来干啥？")
      return
    end
    if self.数据[道具id].数量~=nil and self.数据[道具id].数量>0 then
      self.数据[道具id].数量=self.数据[道具id].数量-1
      if self.数据[道具id].数量<=0 then
        self.数据[道具id]=nil
        玩家数据[id].角色.数据.道具[数据.格子[1]]=nil
      end
    else
      self.数据[道具id]=nil
      玩家数据[id].角色.数据.道具[数据.格子[1]]=nil
    end
    道具刷新(id)
    任务处理类:完成任务链任务(id,任务id)
  elseif 事件=="枪矛" or 事件=="斧钺" or 事件=="剑" or 事件=="双短剑" or 事件=="飘带" or 事件=="爪刺" or 事件=="扇" or 事件=="魔棒" or 事件=="锤" or 事件=="鞭" or 事件=="环圈" or 事件=="刀" or 事件=="法杖" or 事件=="弓弩" or 事件=="宝珠" or 事件=="巨剑" or 事件=="伞" or 事件=="灯笼" or 事件=="头盔" or 事件=="发钗" or 事件=="女衣" or 事件=="男衣" then
    local 道具id = 玩家数据[id].角色.数据.道具[数据.格子[1]]
    if self.数据[道具id].总类~=2 then
        添加最后对话(id,"只有装备才能进行转换")
        return
    end
    local 子类=self:取武器类型(事件)
    玩家数据[id].角色:转换武器操作(id,self.数据[道具id],子类)
  elseif 事件=="道观建设" then
    local 道具id = 玩家数据[id].角色.数据.道具[数据.格子[1]]
    if self.数据[道具id].总类~=21 then
      添加最后对话(id,"只能上交木材")
      return
    end
    local 任务id=玩家数据[id].角色:取任务(130)
    local 副本id=任务数据[任务id].副本id
    local 增加进度=self.数据[道具id].数量*8
    任务数据[任务id].道观建设=任务数据[任务id].道观建设+增加进度
    副本数据.车迟斗法.进行[副本id].道观建设=副本数据.车迟斗法.进行[副本id].道观建设+增加进度
    if 任务数据[任务id].道观建设>= 任务数据[任务id].建设要求 then --
      地图处理类:当前消息广播1(6021,"#Y当前道观建设已满，速去找有个和尚")
      副本数据.车迟斗法.进行[副本id].进程=2
      任务处理类:设置车迟斗法副本(副本id)
    end
    local 等级=取等级(id)
    local 经验=等级*240
    local 银子=等级*50+5000
    玩家数据[id].角色:添加经验(经验,"道观建设",1)
    玩家数据[id].角色:添加银子(银子,"道观建设",1)
    local 奖励参数=取随机数()
    if 奖励参数<=50 then
    elseif 奖励参数<=55 then
      local 名称="金银锦盒"
      玩家数据[id].道具:给予道具(id,名称,1)
      常规提示(id,"#Y/你获得了"..名称)
      广播消息({内容=format("#S(副本-车迟斗法)#R/%s#Y在#R车迟斗法#Y副本中表现卓越，因此获得了三清奖励的#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,名称),频道="xt"})
    elseif 奖励参数<=60 then
      local 名称="九转金丹"
      玩家数据[id].道具:给予道具(id,名称,1,50)
      常规提示(id,"#Y/你获得了"..名称)
      广播消息({内容=format("#S(副本-车迟斗法)#R/%s#Y在#R车迟斗法#Y副本中表现卓越，因此获得了三清奖励的#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,名称),频道="xt"})
    elseif 奖励参数<=65 then
      local 名称="修炼果"
      玩家数据[id].道具:给予道具(id,名称,2)
      常规提示(id,"#Y/你获得了"..名称)
      广播消息({内容=format("#S(副本-车迟斗法)#R/%s#Y在#R车迟斗法#Y副本中表现卓越，因此获得了三清奖励的#G/%s*2#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,名称),频道="xt"})
    elseif 奖励参数<=70 then
      local 名称=取宝石()
      玩家数据[id].道具:给予道具(id,名称,取随机数(2,3))
      常规提示(id,"#Y/你获得了"..名称)
      广播消息({内容=format("#S(副本-车迟斗法)#R/%s#Y在#R车迟斗法#Y副本中表现卓越，因此获得了三清奖励的#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,名称),频道="xt"})
    elseif 奖励参数<=75 then
      local 名称=取强化石()
      玩家数据[id].道具:给予道具(id,名称,1)
      常规提示(id,"#Y/你获得了"..名称)
      广播消息({内容=format("#S(副本-车迟斗法)#R/%s#Y在#R车迟斗法#Y副本中表现卓越，因此获得了三清奖励的#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,名称),频道="xt"})
    end
    常规提示(id,"#Y你上交了#R"..self.数据[道具id].数量.."#Y个木材，为道观增加了#R"..增加进度.."#Y建设度。")
    self.数据[道具id]=nil
    玩家数据[id].角色.数据.道具[数据.格子[1]]=nil
    道具刷新(id)
  end
end

function 道具处理类:回收物品(连接id,id)
  if 玩家数据[id].回收物品==nil then
    添加最后对话(id,"你没有这样的物品。")
    return
  elseif 玩家数据[id].角色.数据.道具[玩家数据[id].回收物品]==nil then
    添加最后对话(id,"你没有这样的物品。")
    return
  end
  local 道具id=玩家数据[id].角色.数据.道具[玩家数据[id].回收物品]
  if self.数据[道具id]==nil then
    添加最后对话(id,"你没有这样的物品。")
    return
  end
  local 价格=self:取回收价格(道具id)
  if 价格.价格==0  then
    添加最后对话(id,"此类物品不在回收列表上。")
    return
  end
  local 名称=self.数据[道具id].名称
  local 数量=self.数据[道具id].数量
  if 数量==nil then 数量=1 end
  local 识别码=self.数据[道具id].识别码
  if 识别码==nil then 识别码="无法识别" end
  if self.数据[道具id].数量~=nil and self.数据[道具id].数量>0 then
    价格.价格=价格.价格*self.数据[道具id].数量
  end
  self.数据[道具id]=nil
  玩家数据[id].角色.数据.道具[玩家数据[id].回收物品]=nil
  玩家数据[id].回收物品=nil
  if 价格.类型==1 then
    玩家数据[id].角色:添加银子(价格.价格,format("回收物品:%s,%s,%s",名称,数量,识别码),1)
    添加最后对话(id,format("回收物品成功，你获得了%s两银子",价格.价格))
  end
  道具刷新(id)
end

function 道具处理类:取回收价格(id)
  local 名称=self.数据[id].名称
  local 价格=0
  local 类型=1
  if 名称=="魔兽要诀" then
   价格=150000
  elseif 名称=="高级魔兽要诀" then
   价格=500000
  elseif 名称=="龙鳞" then
   价格=30000
  elseif 名称=="避水珠" then
   价格=5000
  elseif 名称=="夜光珠" then
   价格=80000
  elseif 名称=="金刚石" then
   价格=300000
  elseif 名称=="定魂珠" then
   价格=300000
  elseif 名称=="金柳露" then
   价格=10000
  elseif 名称=="超级金柳露" then
   价格=30000
  elseif 名称=="鬼谷子" then
   价格=200000
  elseif 名称=="修炼果" then
   价格=300000
  elseif 名称=="九转金丹" then
   价格=self.数据[id].阶品*8000
  elseif 名称=="彩果" then
   价格=50000
  elseif 名称=="藏宝图" then
   价格=50000
  elseif 名称=="高级藏宝图" then
   价格=1000000
  elseif 名称=="特赦令牌" then
   价格=800000
  elseif self.数据[id].总类==2 and  self.数据[id].分类~=9 and self.数据[id].灵饰==nil  then
   local 等级=self.数据[id].级别限制
    if self.数据[id].专用~=nil or self.数据[id].不可转移 then
      价格=1
    elseif 等级==60 then
     价格=50000
    elseif 等级==70 then
     价格=100000
    elseif 等级>=80 then
     价格=150000
    end
  elseif 名称=="星辉石" then
   价格=self.数据[id].级别限制*80000
  elseif 名称=="红玛瑙" or 名称=="太阳石" or 名称=="舍利子" or 名称=="黑宝石" or 名称=="月亮石" or 名称=="光芒石" or 名称=="神秘石" then
   价格=self.数据[id].级别限制*50000
  end
  return {价格=价格,类型=类型}
end

function 道具处理类:出售装备(连接id,id)
  if 玩家数据[id].出售装备==nil or 玩家数据[id].角色.数据.道具[玩家数据[id].出售装备]==nil then
    添加最后对话(id,"该装备不存在！")
    return
  end
  local 道具id=玩家数据[id].角色.数据.道具[玩家数据[id].出售装备]
  if self.数据[道具id].总类~=2 or self.数据[道具id].灵饰 or self.数据[道具id].分类==9 then
    添加最后对话(id,"该物品无法被我收购")
    return
  end
  local 银子=self:取装备价格(道具id)
  玩家数据[id].角色:添加银子(银子,format("出售装备:%s,%s",self.数据[道具id].名称,self.数据[道具id].识别码),1)
  self.数据[道具id]=nil
  玩家数据[id].角色.数据.道具[玩家数据[id].出售装备]=nil
  玩家数据[id].出售装备=nil
  添加最后对话(id,"出售装备成功，你获得了"..银子.."两银子")
  道具刷新(id)
  return
end

function 道具处理类:取装备价格(道具id)
  local 等级=self.数据[道具id].级别限制
  local 价格=150
  if  等级<=10 then
    价格=30
  elseif  等级<=20 then
    价格=50
  elseif 等级<=30 then
   价格=100
  elseif 等级<=40 then

   价格=150
  elseif 等级<=60 then
   价格=300
  elseif 等级<=70 then
   价格=500
  elseif 等级<=80 then
   价格=700
  else
   价格=1000
  end
  if self.数据[道具id].专用~=nil then
    价格=1
    等级=1
  end
  return 价格*等级
end

function 道具处理类:生成合成旗(连接id,id,名称)
  if 玩家数据[id].合成旗序列==nil or #玩家数据[id].合成旗序列<=0 then
    常规提示(id,"#Y未找到已提交的导标旗，请重新使用法宝进行合成")
    玩家数据[id].合成旗序列=nil
    return
  end
  local 编号=玩家数据[id].法宝id
  if 玩家数据[id].角色.数据.法宝[编号]==nil or self.数据[玩家数据[id].角色.数据.法宝[编号]]==nil or self.数据[玩家数据[id].角色.数据.法宝[编号]].名称~="五色旗盒" then
    常规提示(id,"#Y你没有这样的法宝")
    return
  elseif self.数据[玩家数据[id].角色.数据.法宝[编号]].魔法<=0 then
    常规提示(id,"#Y你的法宝灵气不足")
    return
  end
  self.数据[玩家数据[id].角色.数据.法宝[编号]].魔法=self.数据[玩家数据[id].角色.数据.法宝[编号]].魔法-1
  local 次数=0
  for n=1,#玩家数据[id].合成旗序列 do
    local 临时id=玩家数据[id].角色.数据.道具[玩家数据[id].合成旗序列[n]]
    if 临时id==nil or self.数据[临时id]==nil or self.数据[临时id].总类~=11 or self.数据[临时id].分类~=1 or self.数据[临时id].地图~=玩家数据[id].合成旗序列.地图 or self.数据[临时id].次数==nil then
      常规提示(id,"#Y您的物品数据已经发生变化，请重新使用法宝进行合成")
      玩家数据[id].合成旗序列=nil
      return
    end
    次数=次数+self.数据[临时id].次数
  end
  local 临时id=玩家数据[id].角色.数据.道具[玩家数据[id].合成旗序列[1]]
  self.数据[临时id].名称=名称
  self.数据[临时id].分类=2
  self.数据[临时id].次数=次数
  self.数据[临时id].xy={}
  for n=1,#玩家数据[id].合成旗序列 do
    local 临时id1=玩家数据[id].角色.数据.道具[玩家数据[id].合成旗序列[n]]
    self.数据[临时id].xy[n]={x=self.数据[临时id1].x,y=self.数据[临时id1].y}
    if n~=1 then
      玩家数据[id].角色.数据.道具[玩家数据[id].合成旗序列[n]]=nil
      self.数据[临时id1]=nil
    end
  end
  玩家数据[id].合成旗序列=nil
  玩家数据[id].法宝id=nil
  玩家数据[id].最后操作=nil
  发送数据(连接id,38,{内容="你的法宝#R/五色旗盒#W/灵气减少了1点"})
  常规提示(id,"#Y您获得了#R"..名称)
  道具刷新(id)
end

function 道具处理类:给予处理(连接id,id,数据)
  if 玩家数据[id].给予数据==nil  then
    return
  elseif 玩家数据[id].给予数据.类型==1 then --npc给予
    self:系统给予处理(连接id,id,数据)
    return
  end
  local 对方id=玩家数据[id].给予数据.id
  if 玩家数据[对方id]==nil then
    常规提示(id,"#Y/对方并不在线")
    return
  end
  if 地图处理类:比较距离(id,对方id,500)==false then
    常规提示(id,"#Y/你们的距离太远了")
    return
  end
  -- 给予银子
  local 银子=0
  local 银子来源=数据.银子
  local 名称=玩家数据[id].角色.数据.名称
  local 名称1=玩家数据[对方id].角色.数据.名称
  if 银子来源=="" or 银子来源==nil then
    银子=0
  else
    银子=数据.银子+0
  end
  if 银子<0 then
    return
  end
  if 玩家数据[id].角色.数据.银子<银子 then
    常规提示(id,"#Y/你没有那么多的银子")
    return
  end
  -- print(银子,数据.银子)
  if 银子>0 then
    local 之前银子=玩家数据[id].角色.数据.银子
    玩家数据[id].角色.数据.银子=玩家数据[id].角色.数据.银子-银子
    玩家数据[id].角色:日志记录(format("[给予系统-发起]接受账号为[%s][%s][%s]角色%s两银子，初始银子为%s，余额为%s两银子",玩家数据[对方id].账号,对方id,玩家数据[对方id].角色.数据.名称,银子,之前银子,玩家数据[id].角色.数据.银子))
    local 之前银子=玩家数据[对方id].角色.数据.银子
    玩家数据[对方id].角色.数据.银子=玩家数据[对方id].角色.数据.银子+银子
    玩家数据[对方id].角色:日志记录(format("[给予系统-接受]发起账号为[%s][%s][%s]角色%s两银子，初始银子为%s，余额为%s两银子",玩家数据[id].账号,id,玩家数据[id].角色.数据.名称,银子,之前银子,玩家数据[对方id].角色.数据.银子))
    常规提示(id,format("#Y/你给了%s%s两银子",名称1,银子))
    常规提示(对方id,format("#Y/%s给了你%s两银子",名称,银子))
  end
  for n=1,3 do
    if 数据.格子[n]~=nil then
      local 格子=数据.格子[n]
      if 格子~=nil then
        local 道具id=玩家数据[id].角色.数据.道具[数据.格子[n]]
        if 道具id~=nil and 玩家数据[id].道具.数据[道具id]~=nil then
          if 玩家数据[id].道具.数据[道具id].绑定 or 玩家数据[id].道具.数据[道具id].不可交易 then
            常规提示(id,"#Y/该物品无法交易或给予给他人")
          else
            local 对方格子=玩家数据[对方id].角色:取道具格子()
            if 对方格子==0 then
              常规提示(id,"#Y/对方身上没有足够的空间")
            else
              local 对方道具=玩家数据[对方id].道具:取新编号()
              local 道具名称=玩家数据[id].道具.数据[道具id].名称
              local 道具识别码=玩家数据[id].道具.数据[道具id].识别码
              玩家数据[对方id].道具.数据[对方道具]=table.loadstring(table.tostring(玩家数据[id].道具.数据[道具id]))
              玩家数据[对方id].角色.数据.道具[对方格子]=对方道具
              玩家数据[id].道具.数据[道具id]=nil
              玩家数据[id].角色.数据.道具[数据.格子[n]]=nil
              常规提示(id,"#Y/你给了"..名称1..玩家数据[对方id].道具.数据[对方道具].名称)
              常规提示(对方id,"#Y/"..名称.."给了你"..玩家数据[对方id].道具.数据[对方道具].名称)
              玩家数据[id].角色:日志记录(format("[给予系统-发起]物品名称%s、识别码%s,对方信息[%s][%s][%s]",道具名称,道具识别码,玩家数据[对方id].账号,对方id,名称1))
              玩家数据[对方id].角色:日志记录(format("[给予系统-接受]物品名称%s、识别码%s,对方信息[%s][%s][%s]",道具名称,道具识别码,玩家数据[id].账号,id,名称))
              更改道具归属(道具识别码,玩家数据[对方id].账号,对方id,名称1)
            end
          end
        end
      end
    end
  end
  道具刷新(id)
  道具刷新(对方id)
  玩家数据[id].给予数据=nil
end

function 道具处理类:开启宝藏山小宝箱(id,任务id)
  if 任务数据[任务id]==nil then
    常规提示(id,"#Y这个宝箱已经被其他玩家开启过了")
    return
  elseif 宝藏山数据[id].小宝箱>=30 then
    常规提示(id,"#Y你在本次活动中开启的小宝箱数量已达30个，无法再开启更多的小宝箱了")
    return
  end
  地图处理类:删除单位(任务数据[任务id].地图编号,任务数据[任务id].单位编号)
  任务数据[任务id]=nil
  宝藏山数据[id].小宝箱=宝藏山数据[id].小宝箱+1
  宝藏山数据.小宝箱=宝藏山数据.小宝箱-1
  地图处理类:当前消息广播1(5001,format("#G当前场景内小宝箱剩余数量为：#R%s#G个",宝藏山数据.小宝箱))
  常规提示(id,"#Y你在本次活动中还可以开启#R"..(30-宝藏山数据[id].小宝箱).."个小宝箱")
  local 奖励参数=取随机数(1,200)
  if 奖励参数<=10 then
   local 名称=取强化石()
   玩家数据[id].道具:给予道具(id,名称,1)
   常规提示(id,"#Y你获得了#R"..名称)
  elseif 奖励参数<=30 then
   local 名称="月华露"
   玩家数据[id].道具:给予道具(id,名称,1,100)
   常规提示(id,"#Y你获得了#R"..名称)
  elseif 奖励参数<=60 then
   local 名称=self:给予书铁(id,{2,6})
   常规提示(id,"#Y你获得了#R"..名称[1])
  elseif 奖励参数<=110 then
   local 银子=取随机数(10000,50000)
   玩家数据[id].角色:添加银子(银子,"宝藏山小箱子",1)
  elseif 奖励参数<=130 then
   local 名称="金柳露"
   玩家数据[id].道具:给予道具(id,名称)
   常规提示(id,"#Y你获得了#R"..名称)
  else
   local 等级=玩家数据[id].角色.数据.等级
   local 经验=(等级*150+等级*等级)
   经验=取随机数(经验,经验*2)
   玩家数据[id].角色:添加经验(经验,"宝藏山小箱子",1)
  end
end

function 道具处理类:开启宝藏山大宝箱(id,任务id)
  if 任务数据[任务id]==nil then
    常规提示(id,"#Y这个宝箱已经被其他玩家开启过了")
    return
  elseif 宝藏山数据[id].大宝箱>=10 then
    常规提示(id,"#Y你在本次活动中开启的大宝箱数量已达10个，无法再开启更多的大宝箱了")
    return
  end
  地图处理类:删除单位(任务数据[任务id].地图编号,任务数据[任务id].单位编号)
  任务数据[任务id]=nil
  宝藏山数据[id].大宝箱=宝藏山数据[id].大宝箱+1
  宝藏山数据.大宝箱=宝藏山数据.大宝箱-1
  地图处理类:当前消息广播1(5001,format("#G当前场景内大宝箱剩余数量为：#R%s#G个",宝藏山数据.大宝箱))
  常规提示(id,"#Y你在本次活动中还可以开启#R"..(10-宝藏山数据[id].大宝箱).."个大宝箱")
  local 银子=取随机数(10000,50000)
  玩家数据[id].角色:添加银子(银子,"宝藏山大箱子",1)
  local 奖励参数=取随机数(1,200)
  if 奖励参数<=10 then
    local 名称="魔兽要诀"
    玩家数据[id].道具:给予道具(id,名称)
    常规提示(id,"#Y/你获得了"..名称)
    广播消息({内容=format("#S(宝藏山)#R/%s#Y在宝藏山四处搜寻宝箱，皇天不负有心人，终于发现了一个大宝箱，打开一瞧，里面的宝藏居然是#G/%s#Y",玩家数据[id].角色.数据.名称,名称),频道="xt"})
  elseif 奖励参数<=30 then
   local 名称="月华露"
    玩家数据[id].道具:给予道具(id,名称,1,1500)
    常规提示(id,"#Y/你获得了"..名称)
    广播消息({内容=format("#S(宝藏山)#R/%s#Y在宝藏山四处搜寻宝箱，皇天不负有心人，终于发现了一个大宝箱，打开一瞧，里面的宝藏居然是#G/%s#Y",玩家数据[id].角色.数据.名称,名称),频道="xt"})
  elseif 奖励参数<=120 then
   local 名称=self:取五宝()
   玩家数据[id].道具:给予道具(id,名称)
   常规提示(id,"#Y/你获得了"..名称)
   广播消息({内容=format("#S(宝藏山)#R/%s#Y在宝藏山四处搜寻宝箱，皇天不负有心人，终于发现了一个大宝箱，打开一瞧，里面的宝藏居然是#G/%s#Y",玩家数据[id].角色.数据.名称,名称),频道="xt"})
  elseif 奖励参数<=150 then
    local 名称="超级金柳露"
    玩家数据[id].道具:给予道具(id,名称)
    常规提示(id,"#Y/你获得了"..名称)
    广播消息({内容=format("#S(宝藏山)#R/%s#Y在宝藏山四处搜寻宝箱，皇天不负有心人，终于发现了一个大宝箱，打开一瞧，里面的宝藏居然是#G/%s#Y",玩家数据[id].角色.数据.名称,名称),频道="xt"})
  elseif 奖励参数<=151 and 让海啸席卷 then
    local 名称="高级魔兽要诀"
    local 技能=取特殊要诀()
    玩家数据[id].道具:给予道具(id,名称,nil,技能)
    常规提示(id,"#Y/你获得了"..名称)
    广播消息({内容=format("#S(宝藏山)#R/%s#Y在宝藏山四处搜寻宝箱，皇天不负有心人，终于发现了一个大宝箱，打开一瞧，里面的宝藏居然是#G/%s#Y",玩家数据[id].角色.数据.名称,名称),频道="xt"})
  elseif 奖励参数<=156 and 让海啸席卷 then
    local 名称="仙玉"
    添加仙玉(取随机数(20,50),玩家数据[id].账号,id,"宝藏山")
    常规提示(id,"#Y/你获得了"..名称)
    广播消息({内容=format("#S(宝藏山)#R/%s#Y在宝藏山四处搜寻宝箱，皇天不负有心人，终于发现了一个大宝箱，打开一瞧，里面的宝藏居然是#G/%s#Y",玩家数据[id].角色.数据.名称,名称),频道="xt"})
  else
   local 等级=玩家数据[id].角色.数据.等级
   local 经验=(等级*150+等级*等级)
   经验=取随机数(经验*2,经验*5)
   玩家数据[id].角色:添加经验(经验,"宝藏山大箱子",1)
  end
end

function 道具处理类:开启帮战小宝箱(id,任务id)
  if 任务数据[任务id]==nil then
    常规提示(id,"#Y这个宝箱已经被其他玩家开启过了")
    return
  end
  地图处理类:删除单位(任务数据[任务id].地图编号,任务数据[任务id].单位编号)
  任务数据[任务id]=nil
  地图处理类:跳转地图(id,1001,333,182)
  local 奖励参数=取随机数(1,200)
  if 奖励参数<=10 then
    local 名称=取强化石()
    玩家数据[id].道具:给予道具(id,名称,1)
    常规提示(id,"#Y你获得了#R"..名称)
  elseif 奖励参数<=30 then
    local 名称="月华露"
    玩家数据[id].道具:给予道具(id,名称,1,100)
    常规提示(id,"#Y你获得了#R"..名称)
    广播消息({内容=format("#S(帮派竞赛)#R/%s#Y在帮派竞赛地图四处搜寻宝箱，皇天不负有心人，终于发现了一个小宝箱，打开一瞧，里面的宝藏居然是#G/%s#Y",玩家数据[id].角色.数据.名称,名称),频道="xt"})
  elseif 奖励参数<=60 then
    local 名称=self:给予书铁(id,{6,10})
    常规提示(id,"#Y你获得了#R"..名称[1])
    广播消息({内容=format("#S(帮派竞赛)#R/%s#Y在帮派竞赛地图四处搜寻宝箱，皇天不负有心人，终于发现了一个小宝箱，打开一瞧，里面的宝藏居然是#G/%s#Y",玩家数据[id].角色.数据.名称,名称[1]),频道="xt"})
  elseif 奖励参数<=110 then
    local 银子=取随机数(100000,500000)
    玩家数据[id].角色:添加银子(银子,"帮战小箱子",1)
    广播消息({内容=format("#S(帮派竞赛)#R/%s#Y在帮派竞赛地图四处搜寻宝箱，皇天不负有心人，终于发现了一个小宝箱，打开一瞧，里面的宝藏居然是#G/%s两银子#Y",玩家数据[id].角色.数据.名称,银子),频道="xt"})
  elseif 奖励参数<=130 then
    local 名称="金柳露"
    玩家数据[id].道具:给予道具(id,名称)
    常规提示(id,"#Y你获得了#R"..名称)
    广播消息({内容=format("#S(帮派竞赛)#R/%s#Y在帮派竞赛地图四处搜寻宝箱，皇天不负有心人，终于发现了一个小宝箱，打开一瞧，里面的宝藏居然是#G/%s#Y",玩家数据[id].角色.数据.名称,名称),频道="xt"})
  else
    local 等级=玩家数据[id].角色.数据.等级
    local 经验=(等级*150+等级*等级)
    经验=取随机数(经验,经验*2)
    玩家数据[id].角色:添加经验(经验,"帮战小箱子",1)
  end
end

function 道具处理类:开启帮战大宝箱(id,任务id)
  if 任务数据[任务id]==nil then
    常规提示(id,"#Y这个宝箱已经被其他玩家开启过了")
    return
  end
  地图处理类:删除单位(任务数据[任务id].地图编号,任务数据[任务id].单位编号)
  任务数据[任务id]=nil
  地图处理类:跳转地图(id,1001,333,182)
  local 银子=取随机数(100000,500000)
  玩家数据[id].角色:添加银子(银子,"帮战大箱子",1)
  local 奖励参数=取随机数()
  if 奖励参数<=10 then
    local 名称="魔兽要诀"
    玩家数据[id].道具:给予道具(id,名称)
    常规提示(id,"#Y/你获得了"..名称)
    广播消息({内容=format("#S(帮派竞赛)#R/%s#Y在帮派竞赛地图四处搜寻宝箱，皇天不负有心人，终于发现了一个大宝箱，打开一瞧，里面的宝藏居然是#G/%s#Y",玩家数据[id].角色.数据.名称,名称),频道="xt"})
  elseif 奖励参数<=30 then
   local 名称="月华露"
    玩家数据[id].道具:给予道具(id,名称,1,1500)
    常规提示(id,"#Y/你获得了"..名称)
    广播消息({内容=format("#S(帮派竞赛)#R/%s#Y在帮派竞赛地图四处搜寻宝箱，皇天不负有心人，终于发现了一个大宝箱，打开一瞧，里面的宝藏居然是#G/%s#Y",玩家数据[id].角色.数据.名称,名称),频道="xt"})
  elseif 奖励参数<=120 then
    local 名称=self:取五宝()
    玩家数据[id].道具:给予道具(id,名称)
    常规提示(id,"#Y/你获得了"..名称)
    广播消息({内容=format("#S(帮派竞赛)#R/%s#Y在帮派竞赛地图四处搜寻宝箱，皇天不负有心人，终于发现了一个大宝箱，打开一瞧，里面的宝藏居然是#G/%s#Y",玩家数据[id].角色.数据.名称,名称),频道="xt"})
  elseif 奖励参数<=150 then
    local 名称="超级金柳露"
    玩家数据[id].道具:给予道具(id,名称)
    常规提示(id,"#Y/你获得了"..名称)
    广播消息({内容=format("#S(帮派竞赛)#R/%s#Y在帮派竞赛地图四处搜寻宝箱，皇天不负有心人，终于发现了一个大宝箱，打开一瞧，里面的宝藏居然是#G/%s#Y",玩家数据[id].角色.数据.名称,名称),频道="xt"})
  else
    local 等级=玩家数据[id].角色.数据.等级
    local 经验=(等级*150+等级*等级)
    经验=取随机数(经验*2,经验*5)
    玩家数据[id].角色:添加经验(经验,"帮战大箱子",1)
  end
end

function 道具处理类:开启福利宝箱(id,任务id)
  if 任务数据[任务id]==nil then
    常规提示(id,"#Y这个宝箱已经被其他玩家开启过了")
    return
  end
  地图处理类:删除单位(任务数据[任务id].地图编号,任务数据[任务id].单位编号)
  任务数据[任务id]=nil
  local 奖励参数=取随机数()
  if 奖励参数<=40 then
    local 名称="2W银子"
    玩家数据[id].角色:添加银子(20000,"福利宝箱",1)
    广播消息({内容=format("#S(福利宝箱)#R/%s#Y福来缘深，拾取福利宝箱获得#G/%s#Y",玩家数据[id].角色.数据.名称,名称),频道="xt"})
  elseif 奖励参数<=50 then
    local 名称="10点仙玉"
    添加仙玉(10,玩家数据[id].账号,id,"福利宝箱")
    常规提示(id,"#Y你获得了#R"..名称)
    广播消息({内容=format("#S(福利宝箱)#R/%s#Y福来缘深，拾取福利宝箱获得#G/%s#Y",玩家数据[id].角色.数据.名称,名称),频道="xt"})
  elseif 奖励参数<=55 then
    local 物品表={"金香玉","小还丹","千年保心丹","风水混元丹","定神香","蛇蝎美人","九转回魂丹","佛光舍利子","十香返生丸","五龙丹"}
    local 临时物品=物品表[取随机数(1,#物品表)]
    local 临时品质=100
    常规提示(id,"#W/你获得了#R/"..临时物品)
    self:给予道具(id,临时物品,1,临时品质)
    广播消息({内容=format("#S(福利宝箱)#R/%s#Y福来缘深，拾取福利宝箱获得#G/%s#Y",玩家数据[id].角色.数据.名称,临时物品),频道="xt"})
  else
    local 名称="3W经验"
    玩家数据[id].角色:添加经验(30000,"福利宝箱",1)
    广播消息({内容=format("#S(福利宝箱)#R/%s#Y福来缘深，拾取福利宝箱获得#G/%s#Y",玩家数据[id].角色.数据.名称,名称),频道="xt"})
  end
end

function 道具处理类:开启车迟福利宝箱(id,任务id)
  if 任务数据[任务id]==nil then
    常规提示(id,"#Y这个宝箱已经被其他玩家开启过了")
    return
  end
  地图处理类:删除单位(任务数据[任务id].地图编号,任务数据[任务id].单位编号)
  任务数据[任务id]=nil
  local 奖励参数=取随机数()
  if 奖励参数<=15 then
    local 名称="高级魔兽要诀"
    玩家数据[id].道具:给予道具(id,名称)
    常规提示(id,"#Y/你获得了"..名称)
    广播消息({内容=format("#S(副本-车迟斗法)#R/%s#Y在#R车迟斗法#Y副本中表现卓越，因此获得了三清奖励的#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,名称),频道="xt"})
  elseif 奖励参数<=30 then
    local 名称="九转金丹"
    玩家数据[id].道具:给予道具(id,名称,1,50)
    常规提示(id,"#Y/你获得了"..名称)
    广播消息({内容=format("#S(副本-车迟斗法)#R/%s#Y在#R车迟斗法#Y副本中表现卓越，因此获得了三清奖励的#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,名称),频道="xt"})
  elseif 奖励参数<=40 then
    local 名称="修炼果"
    玩家数据[id].道具:给予道具(id,名称,2)
    常规提示(id,"#Y/你获得了"..名称)
    广播消息({内容=format("#S(副本-车迟斗法)#R/%s#Y在#R车迟斗法#Y副本中表现卓越，因此获得了三清奖励的#G/%s*2#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,名称),频道="xt"})
  elseif 奖励参数<=60 then
    local 名称=取宝石()
    玩家数据[id].道具:给予道具(id,名称,取随机数(2,3))
    常规提示(id,"#Y/你获得了"..名称)
    广播消息({内容=format("#S(副本-车迟斗法)#R/%s#Y在#R车迟斗法#Y副本中表现卓越，因此获得了三清奖励的#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,名称),频道="xt"})
  elseif 奖励参数<=70 then
    local 名称="初级神魂丹"
    玩家数据[id].道具:给予道具(id,名称,1)
    常规提示(id,"#Y/你获得了"..名称)
    广播消息({内容=format("#S(副本-车迟斗法)#R/%s#Y在#R车迟斗法#Y副本中表现卓越，因此获得了三清奖励的#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,名称),频道="xt"})
  elseif 奖励参数<=90 then
    local 名称="金银锦盒"
    玩家数据[id].道具:给予道具(id,名称,1)
    常规提示(id,"#Y/你获得了"..名称)
    广播消息({内容=format("#S(副本-车迟斗法)#R/%s#Y在#R车迟斗法#Y副本中表现卓越，因此获得了三清奖励的#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,名称),频道="xt"})
  else
    local 名称=取强化石()
    玩家数据[id].道具:给予道具(id,名称,10)
    常规提示(id,"#Y/你获得了"..名称)
    广播消息({内容=format("#S(副本-车迟斗法)#R/%s#Y在#R车迟斗法#Y副本中表现卓越，因此获得了三清奖励的#G/%s*10#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,名称),频道="xt"})
  end
end

function 道具处理类:开启车迟胜利宝箱(id,任务id)
  if 任务数据[任务id]==nil then
    常规提示(id,"#Y这个宝箱已经被其他玩家开启过了")
    return
  end
  地图处理类:删除单位(任务数据[任务id].地图编号,任务数据[任务id].单位编号)
  任务数据[任务id]=nil
  local 银子=取随机数(100000,500000)
  玩家数据[id].角色:添加银子(银子,"车迟斗法绑定宝箱",1)
  local 奖励参数=取随机数()
  if 奖励参数<=15 then
    local 名称="高级魔兽要诀"
    玩家数据[id].道具:给予道具(id,名称)
    常规提示(id,"#Y/你获得了"..名称)
    广播消息({内容=format("#S(副本-车迟斗法)#R/%s#Y在#R车迟斗法#Y副本中表现卓越，因此获得了三清奖励的#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,名称),频道="xt"})
  elseif 奖励参数<=30 then
   local 名称="九转金丹"
    玩家数据[id].道具:给予道具(id,名称,1,50)
    常规提示(id,"#Y/你获得了"..名称)
    广播消息({内容=format("#S(副本-车迟斗法)#R/%s#Y在#R车迟斗法#Y副本中表现卓越，因此获得了三清奖励的#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,名称),频道="xt"})
  elseif 奖励参数<=40 then
    local 名称="修炼果"
    玩家数据[id].道具:给予道具(id,名称,2)
    常规提示(id,"#Y/你获得了"..名称)
    广播消息({内容=format("#S(副本-车迟斗法)#R/%s#Y在#R车迟斗法#Y副本中表现卓越，因此获得了三清奖励的#G/%s*2#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,名称),频道="xt"})
  elseif 奖励参数<=60 then
    local 名称=取宝石()
    玩家数据[id].道具:给予道具(id,名称,取随机数(2,3))
    常规提示(id,"#Y/你获得了"..名称)
    广播消息({内容=format("#S(副本-车迟斗法)#R/%s#Y在#R车迟斗法#Y副本中表现卓越，因此获得了三清奖励的#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,名称),频道="xt"})
  elseif 奖励参数<=70 then
    local 名称="初级神魂丹"
    玩家数据[id].道具:给予道具(id,名称,1)
    常规提示(id,"#Y/你获得了"..名称)
    广播消息({内容=format("#S(副本-车迟斗法)#R/%s#Y在#R车迟斗法#Y副本中表现卓越，因此获得了三清奖励的#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,名称),频道="xt"})
  elseif 奖励参数<=73 then
    local 名称="高级魔兽要诀"
    local 技能=取特殊要诀()
    玩家数据[id].道具:给予道具(id,名称,nil,技能)
    常规提示(id,"#Y/你获得了"..名称)
    广播消息({内容=format("#S(副本-车迟斗法)#R/%s#Y在#R车迟斗法#Y副本中表现卓越，因此获得了三清奖励的#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,名称),频道="xt"})
  elseif 奖励参数<=90 then
    local 名称="金银锦盒"
    玩家数据[id].道具:给予道具(id,名称,1)
    常规提示(id,"#Y/你获得了"..名称)
    广播消息({内容=format("#S(副本-车迟斗法)#R/%s#Y在#R车迟斗法#Y副本中表现卓越，因此获得了三清奖励的#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,名称),频道="xt"})
  else
    local 名称=取强化石()
    玩家数据[id].道具:给予道具(id,名称,10)
    常规提示(id,"#Y/你获得了"..名称)
    广播消息({内容=format("#S(副本-车迟斗法)#R/%s#Y在#R车迟斗法#Y副本中表现卓越，因此获得了三清奖励的#G/%s*10#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,名称),频道="xt"})
  end
end

function 道具处理类:发放在线奖励(id)
  local 奖励参数=取随机数(1,620)
  if 奖励参数<=100 then
   local 名称=取宝石()
   玩家数据[id].道具:给予道具(id,名称,取随机数(2,3))
   常规提示(id,"#Y/你获得了"..名称)
   广播消息({内容=format("#S(在线奖励)#R/%s#Y本日在线时间已经达到3小时，因此获得了游戏管理员赠送的#G/%s#Y",玩家数据[id].角色.数据.名称,名称),频道="xt"})
  elseif 奖励参数<=200 then
  local 名称="九转金丹"
   玩家数据[id].道具:给予道具(id,名称,1,100)
   常规提示(id,"#Y/你获得了"..名称)
   广播消息({内容=format("#S(在线奖励)#R/%s#Y本日在线时间已经达到3小时，因此获得了游戏管理员赠送的#G/%s#Y",玩家数据[id].角色.数据.名称,名称),频道="xt"})
  elseif 奖励参数<=300 then
   local 名称="修炼果"
   玩家数据[id].道具:给予道具(id,名称,1)
   常规提示(id,"#Y/你获得了"..名称)
   广播消息({内容=format("#S(在线奖励)#R/%s#Y本日在线时间已经达到3小时，因此获得了游戏管理员赠送的#G/%s#Y",玩家数据[id].角色.数据.名称,名称),频道="xt"})
  elseif 奖励参数<=400 then
  local 名称="特赦令牌"
   玩家数据[id].道具:给予道具(id,名称)
   常规提示(id,"#Y/你获得了"..名称)
   广播消息({内容=format("#S(在线奖励)#R/%s#Y本日在线时间已经达到3小时，因此获得了游戏管理员赠送的#G/%s#Y",玩家数据[id].角色.数据.名称,名称),频道="xt"})
  elseif 奖励参数<=500 then
  local 名称="高级魔兽要诀"
   玩家数据[id].道具:给予道具(id,名称)
   常规提示(id,"#Y/你获得了"..名称)
   广播消息({内容=format("#S(在线奖励)#R/%s#Y本日在线时间已经达到3小时，因此获得了游戏管理员赠送的#G/%s#Y",玩家数据[id].角色.数据.名称,名称),频道="xt"})
  elseif 奖励参数<=600 then
   local 名称="500万储备"
   玩家数据[id].角色:添加储备(5000000,"在线奖励",1)
   广播消息({内容=format("#S(在线奖励)#R/%s#Y本日在线时间已经达到3小时，因此获得了游戏管理员赠送的#G/%s#Y",玩家数据[id].角色.数据.名称,名称),频道="xt"})
  else
    local 名称=玩家数据[id].角色:取随机法宝()
    玩家数据[id].道具:给予法宝(id,名称)
    广播消息({内容=format("#S(在线奖励)#R/%s#Y本日在线时间已经达到3小时，因此获得了游戏管理员赠送的#G/%s#Y",玩家数据[id].角色.数据.名称,名称),频道="xt"})
  end
end

function 道具处理类:迷宫奖励(id)
  if 迷宫数据[id]~=nil  then
    添加最后对话(id,"你不是已经领取过奖励了吗？")
    return
  end
  迷宫数据[id]=true
  local 等级=玩家数据[id].角色.数据.等级
  local 经验=等级*等级*100
  local 银子=等级*等级*30
  if 让海啸席卷 then
    经验=经验*2
    银子=银子*2
  end
  玩家数据[id].角色:添加经验(经验,"幻域迷宫")
  玩家数据[id].角色:添加银子(银子,"幻域迷宫",1)
  if 活跃数据[id]==nil then
    活跃数据[id]={活跃度=0,领取100活跃=false,领取200活跃=false,领取300活跃=false,领取400活跃=false,领取500活跃=false,师门次数=20,官职次数=30,鬼怪次数=25,封妖次数=3,游泳次数=1,镖王次数=1,押镖次数=50,水果次数=25,天庭叛逆次数=25,十二星宿次数=5,门派闯关次数=1,地煞星次数=5,天罡星次数=5,飞贼次数=5,知了先锋=20,小知了王=20,知了王=10,世界BOSS次数=2,抓鬼次数=50,初出江湖次数=20,帮派青龙次数=100,帮派玄武次数=100,妖王次数=3}
  end
  if 活跃数据[id].迷宫次数==nil then
    活跃数据[id].迷宫次数=1
  end
  if 活跃数据[id].迷宫次数>0 then
    活跃数据[id].活跃度=活跃数据[id].活跃度+30
    玩家数据[id].角色.数据.累积活跃.当前积分=玩家数据[id].角色.数据.累积活跃.当前积分+活跃数据[id].活跃度
    玩家数据[id].角色.数据.累积活跃.总积分=玩家数据[id].角色.数据.累积活跃.总积分+活跃数据[id].活跃度
    活跃数据[id].迷宫次数=活跃数据[id].迷宫次数-1
  end
  if 老唐定制 then
    local 奖励参数=取随机数(1,100)
    if 奖励参数<=55 then
      if 取随机数()<=50 then
        self:给予道具(id,"灵饰指南书",{6,8,10,12,14})
        常规提示(id,"#Y/你获得了一本灵饰指南书")
        广播消息({内容=format("#S(幻域迷宫)#R/%s#Y以惊人的速度率先通过了所有迷宫，获得了迷宫守卫额外奖励的#G/%s#Y",玩家数据[id].角色.数据.名称,"灵饰指南书"),频道="xt"})
      else
        self:给予道具(id,"元灵晶石",{6,8,10,12,14})
        常规提示(id,"#Y/你获得了元灵晶石")
        广播消息({内容=format("#S(幻域迷宫)#R/%s#Y以惊人的速度率先通过了所有迷宫，获得了迷宫守卫额外奖励的#G/%s#Y",玩家数据[id].角色.数据.名称,"元灵晶石"),频道="xt"})
      end
    elseif 奖励参数<=65 then
      local 名称="彩果"
      玩家数据[id].道具:给予道具(id,名称)
      常规提示(id,"#Y/你获得了"..名称)
      广播消息({内容=format("#S(幻域迷宫)#R/%s#Y成功通过了所有迷宫，因此获得了迷宫守卫奖励的#G/%s#Y",玩家数据[id].角色.数据.名称,名称),频道="xt"})
    elseif 奖励参数<=95 then
      local 名称="星辉石"
      玩家数据[id].道具:给予道具(id,名称,取随机数(1,4))
      常规提示(id,"#Y/你获得了"..名称)
      广播消息({内容=format("#S(幻域迷宫)#R/%s#Y成功通过了所有迷宫，因此获得了迷宫守卫奖励的#G/%s#Y",玩家数据[id].角色.数据.名称,名称),频道="xt"})
    else
      local 随机装备={100,110,120,130}
      礼包奖励类:随机装备(id,随机装备[取随机数(1,#随机装备)],"无级别限制")
    end
  else
    local 奖励参数=取随机数(1,500)
    if 奖励参数<=100 then
      local 名称=取宝石()
      玩家数据[id].道具:给予道具(id,名称,取随机数(3,5))
      常规提示(id,"#Y/你获得了"..名称)
      广播消息({内容=format("#S(幻域迷宫)#R/%s#Y成功通过了所有迷宫，因此获得了迷宫守卫奖励的#G/%s#Y",玩家数据[id].角色.数据.名称,名称),频道="xt"})
    elseif 奖励参数<=110 then
      local 名称="高级魔兽要诀"
      玩家数据[id].道具:给予道具(id,名称)
      常规提示(id,"#Y/你获得了"..名称)
      广播消息({内容=format("#S(幻域迷宫)#R/%s#Y成功通过了所有迷宫，因此获得了迷宫守卫奖励的#G/%s#Y",玩家数据[id].角色.数据.名称,名称),频道="xt"})
    elseif 奖励参数<=150 and 让海啸席卷 then
      local 名称="附魔宝珠"
      玩家数据[id].道具:给予道具(id,名称)
      常规提示(id,"#Y/你获得了"..名称)
      广播消息({内容=format("#S(幻域迷宫)#R/%s#Y成功通过了所有迷宫，因此获得了迷宫守卫奖励的#G/%s#Y",玩家数据[id].角色.数据.名称,名称),频道="xt"})
    elseif 奖励参数<=200 and 让海啸席卷 then
      local 名称="一级未激活符石"
      玩家数据[id].道具:给予道具(id,名称)
      常规提示(id,"#Y/你获得了"..名称)
      广播消息({内容=format("#S(幻域迷宫)#R/%s#Y成功通过了所有迷宫，因此获得了迷宫守卫奖励的#G/%s#Y",玩家数据[id].角色.数据.名称,名称),频道="xt"})
    elseif 奖励参数<=250 then
      local 名称="修炼果"
      玩家数据[id].道具:给予道具(id,名称,1)
      常规提示(id,"#Y/你获得了"..名称)
      广播消息({内容=format("#S(幻域迷宫)#R/%s#Y成功通过了所有迷宫，因此获得了迷宫守卫奖励的#G/%s#Y",玩家数据[id].角色.数据.名称,名称),频道="xt"})
    elseif 奖励参数<=300 then
      local 名称="九转金丹"
      玩家数据[id].道具:给予道具(id,名称,1,40)
      常规提示(id,"#Y/你获得了"..名称)
      广播消息({内容=format("#S(幻域迷宫)#R/%s#Y成功通过了所有迷宫，因此获得了迷宫守卫奖励的#G/%s#Y",玩家数据[id].角色.数据.名称,名称),频道="xt"})
    elseif 奖励参数<=350 and 让海啸席卷 then
      local 名称="一倍经验丹"
      玩家数据[id].道具:给予道具(id,名称)
      常规提示(id,"#Y/你获得了"..名称)
      广播消息({内容=format("#S(幻域迷宫)#R/%s#Y成功通过了所有迷宫，因此获得了迷宫守卫奖励的#G/%s#Y",玩家数据[id].角色.数据.名称,名称),频道="xt"})
    elseif 奖励参数<=400 and 让海啸席卷 then
      local 名称="高级召唤兽内丹"
      玩家数据[id].道具:给予道具(id,名称)
      常规提示(id,"#Y/你获得了"..名称)
      广播消息({内容=format("#S(幻域迷宫)#R/%s#Y成功通过了所有迷宫，因此获得了迷宫守卫奖励的#G/%s#Y",玩家数据[id].角色.数据.名称,名称),频道="xt"})
    elseif 奖励参数<=450 and 让海啸席卷 then
      local 名称="仙玉"
      添加仙玉(取随机数(20,50),玩家数据[id].账号,id,"幻域迷宫")
      常规提示(id,"#Y/你获得了"..名称)
      广播消息({内容=format("#S(幻域迷宫)#R/%s#Y成功通过了所有迷宫，因此获得了迷宫守卫奖励的#G/%s#Y",玩家数据[id].角色.数据.名称,名称),频道="xt"})
    else
      local 名称="星辉石"
      玩家数据[id].道具:给予道具(id,名称,1)
      常规提示(id,"#Y/你获得了"..名称)
      广播消息({内容=format("#S(幻域迷宫)#R/%s#Y成功通过了所有迷宫，因此获得了迷宫守卫奖励的#G/%s#Y",玩家数据[id].角色.数据.名称,名称),频道="xt"})
    end
    if 迷宫数据.奖励<5 then
      迷宫数据.奖励=迷宫数据.奖励+1
      if 取随机数()<=50 then
        self:给予道具(id,"灵饰指南书",{6,8})
        常规提示(id,"#Y/你获得了一本灵饰指南书")
        广播消息({内容=format("#S(幻域迷宫)#R/%s#Y以惊人的速度率先通过了所有迷宫，获得了迷宫守卫额外奖励的#G/%s#Y",玩家数据[id].角色.数据.名称,"灵饰指南书"),频道="xt"})
      else
        self:给予道具(id,"元灵晶石",{6,8,10})
        常规提示(id,"#Y/你获得了元灵晶石")
        广播消息({内容=format("#S(幻域迷宫)#R/%s#Y以惊人的速度率先通过了所有迷宫，获得了迷宫守卫额外奖励的#G/%s#Y",玩家数据[id].角色.数据.名称,"元灵晶石"),频道="xt"})
      end
    end
  end
  道具刷新(id)
end

function 道具处理类:高级藏宝图处理(id)
  if 老唐定制 then
    local 奖励参数=取随机数()
    if 奖励参数<=6 then
      任务处理类:设置幼儿园(id)
    elseif 奖励参数<=36 then
      常规提示(id,"#Y/你一锄头挖下去，似乎触碰到了一个奇形怪状的物体")
      任务处理类:开启妖王(id)
    elseif 奖励参数<=66 then
      常规提示(id,"#Y/你获得了一本妖怪遗留下来的秘籍")
      self:给予道具(id,"高级魔兽要诀")
    elseif 奖励参数<=96 then
      local 名称="高级召唤兽内丹"
      self:给予道具(id,名称,1)
      常规提示(id,"#Y/你获得了"..名称)
    else
      local 名称="高级魔兽要诀"
      local 临时特殊要诀 = {"壁垒击破","灵能激发","善恶有报","力劈华山","惊心一剑","嗜血追击","上古灵符"}
      local 技能=临时特殊要诀[取随机数(1,#临时特殊要诀)]
      self:给予道具(id,名称,nil,技能)
      常规提示(id,"#Y你得到了#R"..技能)
      广播消息({内容=format("#S(高级藏宝图)#R/#Y据说#R%s#Y拿着高级藏宝图到野外挖到了一本#G/%s",玩家数据[id].角色.数据.名称,技能),频道="xt"})
    end
  elseif 老八定制 then
    local 奖励参数=取随机数()
    if 奖励参数<=10 then
      任务处理类:设置幼儿园(id)
    elseif 奖励参数<=15 then
      常规提示(id,"#Y/你一锄头挖下去，似乎触碰到了一个奇形怪状的物体")
      任务处理类:开启妖王(id)
    elseif 奖励参数<=35 then
      local 名称="九转金丹"
      self:给予道具(id,名称,1)
      常规提示(id,"#Y/你获得了"..名称)
    elseif 奖励参数<=55 then
      常规提示(id,"#Y/你获得了一本妖怪遗留下来的秘籍")
      self:给予道具(id,"高级魔兽要诀")
    elseif 奖励参数<=70 then
      local 名称="修炼果"
      self:给予道具(id,名称,1)
      常规提示(id,"#Y/你获得了"..名称)
    else
      self:取随机装备(id,取随机数(6,8))
      常规提示(id,"#Y/你得到了妖怪遗留下来的宝物")
    end
  else
    local 奖励参数=取随机数(1,120)
    --奖励参数=100
    if 奖励参数<=20 then
     self:取随机装备(id,取随机数(6,8))
     常规提示(id,"#Y/你得到了妖怪遗留下来的宝物")
    elseif 奖励参数<=30 then
     常规提示(id,"#Y/你获得了一本妖怪遗留下来的秘籍")
     self:给予道具(id,"高级魔兽要诀")
    elseif 奖励参数<=40 then
     self:给予道具(id,"灵饰指南书",{6,8,10})
     常规提示(id,"#Y/你获得了一本灵饰指南书")
    elseif 奖励参数<=50 then
      self:给予道具(id,"元灵晶石",{6,8,10})
     常规提示(id,"#Y/你获得了元灵晶石")
    elseif 奖励参数<=60 then
      self:给予道具(id,"彩果",取随机数(1,2))
     常规提示(id,"#Y/你获得了#R/彩果")
    elseif 奖励参数<=75 then
      常规提示(id,"#Y/你一锄头挖下去，似乎触碰到了一个奇形怪状的物体")
      任务处理类:开启妖王(id)
    elseif 奖励参数<=90 then
      self:给予道具(id,"神兜兜",1)
      常规提示(id,"#Y/你获得了神兜兜")
    else
      任务处理类:设置幼儿园(id)
    end
  end
end

function 道具处理类:低级藏宝图处理(id)
  local 奖励参数=取随机数(1,220)
  if 奖励参数<=20 then
    玩家数据[id].角色:添加银子(取随机数(3000,8000),"挖宝",1)
  elseif 奖励参数<=40 then
    if 老唐定制 then
      self:取随机装备(id,取随机数(6,8))
    else
      self:取随机装备(id,取随机数(2,8))
    end
    常规提示(id,"#Y/你得到了妖怪遗留下来的宝物")
  elseif 奖励参数<=50 then
    local 临时名称=""
    if 老唐定制 then
      临时名称=self:给予书铁(id,{6,8})
    else
      临时名称=self:给予书铁(id,{1,8})
    end
    常规提示(id,"#Y/你获得了"..临时名称[1])
  elseif 奖励参数<=70 then
    常规提示(id,"#Y/你获得了传说中的金柳露")
    self:给予道具(id,"金柳露")
  elseif 奖励参数<=90 then --设置
    local 名称=self:取五宝()
    self:给予道具(id,名称)
    常规提示(id,"#Y/你好像得到了点什么")
  elseif 奖励参数<=100 then
    常规提示(id,"#Y/你获得了一本妖怪遗留下来的秘籍")
    self:给予道具(id,"魔兽要诀")
  elseif 奖励参数<=130 then
    常规提示(id,"#Y/你一锄头挖下去挖出了一团瘴气，等你醒来的时候已经身受重伤了")
    玩家数据[id].角色.数据.气血=math.floor(玩家数据[id].角色.数据.气血*0.5)
    发送数据(玩家数据[id].连接id,5506,{玩家数据[id].角色:取气血数据()})
  elseif 奖励参数<=160 then
    战斗准备类:创建战斗(id+0,100003)
  elseif 奖励参数<=170 then
    常规提示(id,"#Y/你一锄头挖下去，似乎触碰到了一个奇形怪状的物体")
    任务处理类:开启妖王(id)
  elseif 奖励参数<=190 and 老唐定制 then
    local 名称="召唤兽内丹"
    self:给予道具(id,名称,1)
    常规提示(id,"#Y/你获得了"..名称)
  elseif 奖励参数<=180 and  让海啸席卷 then
    self:给予道具(id,"神兜兜",1)
    常规提示(id,"#Y/你获得了神兜兜")
  else
    任务处理类:设置封妖任务(id)
  end
end

function 道具处理类:妖魔积分兑换(连接id,id)
  if 妖魔积分[id]==nil then
    local 对话="你还没有获得妖魔积分，请先去降服一些妖魔鬼怪后再来吧。"
    发送数据(连接id,1501,{名称="袁天罡",模型="袁天罡",对话=对话,选项=xx})
    return
  elseif 妖魔积分[id].当前<3 then
    local 对话="本次操作需要消耗3点妖魔积分。"
    发送数据(连接id,1501,{名称="袁天罡",模型="袁天罡",对话=对话,选项=xx})
    return
  end
  妖魔积分[id].当前=妖魔积分[id].当前-3
  妖魔积分[id].使用=妖魔积分[id].使用+3
  local 奖励参数=取随机数()
  if 奖励参数<=15 then
    self:给予道具(id,"魔兽要诀")
    常规提示(id,"#Y/你获得了一本魔兽要诀")
    发送数据(玩家数据[id].连接id,38,{内容="你得到了#R/".."魔兽要诀"})
  elseif 奖励参数<=20 then
    local 名称=取强化石()
    self:给予道具(id,名称,取随机数(3,5))
    发送数据(玩家数据[id].连接id,38,{内容="你得到了#R/"..名称})
    常规提示(id,"#Y/你获得了"..名称)
  elseif 奖励参数<=40 then
    local 名称=取宝石()
    self:给予道具(id,名称,取随机数(1,2))
    发送数据(玩家数据[id].连接id,38,{内容="你得到了#R/"..名称})
    常规提示(id,"#Y/你获得了"..名称)
  elseif 奖励参数<=50 then
    local 名称="彩果"
    self:给予道具(id,名称,1)
    发送数据(玩家数据[id].连接id,38,{内容="你得到了#R/"..名称})
    常规提示(id,"#Y/你获得了"..名称)
  elseif 奖励参数<=70 then
    local 名称="超级金柳露"
   self:给予道具(id,名称)
   发送数据(玩家数据[id].连接id,38,{内容="你得到了#R/"..名称})
   常规提示(id,"#Y/你获得了"..名称)
  else
    玩家数据[id].角色:添加银子(200000,"妖魔鬼怪兑换奖励",1)
  end
end

function 道具处理类:完成宝图遇怪(id)
  local 奖励参数=取随机数()
  if 奖励参数<=100 then
    local 名称=取宝石()
    self:给予道具(id,名称,取随机数(1,2))
    发送数据(玩家数据[id].连接id,38,{内容="你得到了#R/"..名称})
  elseif 奖励参数<=40 then
    self:取随机装备(id,取随机数(2,8))
  end
  local 临时经验=取等级(id)*50+1000
  玩家数据[id].角色:添加经验(临时经验,"挖图遇怪",1)
end

function 道具处理类:取五宝()
  return 五宝名称[取随机数(1,5)]
end

function 道具处理类:灵饰处理(id,道具id,等级,强化,类型)
  self.幻化id=道具id
  --self.数据[self.幻化id]={幻化等级=0}
  self.数据[self.幻化id].幻化属性={附加={},}
  self.数据[self.幻化id].识别码=id.."_"..os.time().."_"..取随机数(1000,9999999).."_"..随机序列
  随机序列=随机序列+1
  -- print(id,道具id,等级,强化,类型)
  self.临时属性=灵饰属性[类型].主属性[取随机数(1,#灵饰属性[类型].主属性)]
  self.临时数值=灵饰属性.基础[self.临时属性][等级].b
  self.临时下限=灵饰属性.基础[self.临时属性][等级].a
  self.临时数值=取随机数(self.临时下限,self.临时数值)
  local 上限数量=3
  if 强化==1 then
    self.临时数值=math.floor(self.临时数值*1.1)
    上限数量=4
  end
  self.数据[self.幻化id].幻化属性.基础={类型=self.临时属性,数值=self.临时数值,强化=0}
  for n=1,取随机数(1,上限数量) do
    self.临时属性=灵饰属性[类型].副属性[取随机数(1,#灵饰属性[类型].副属性)]
    self.临时数值=灵饰属性.基础[self.临时属性][等级].b
    self.临时下限=灵饰属性.基础[self.临时属性][等级].a
    self.临时数值=取随机数(self.临时下限,self.临时数值)
    for i=1,#self.数据[self.幻化id].幻化属性.附加 do
      if self.数据[self.幻化id].幻化属性.附加[i].类型==self.临时属性 then
        self.临时数值=self.数据[self.幻化id].幻化属性.附加[i].数值
      end
    end
    self.数据[self.幻化id].幻化属性.附加[n]={类型=self.临时属性,数值=self.临时数值,强化=0}
  end
end

function 道具处理类:烹饪处理(连接id,数字id,数据)
  local 临时等级=玩家数据[数字id].角色:取生活技能等级("烹饪技巧")
  local 临时消耗=math.floor(临时等级)+10
  if 玩家数据[数字id].角色.数据.活力<临时消耗 then
    常规提示(数字id,"本次操作需要消耗"..临时消耗.."点活力")
    return
  end
  local 物品表={}
  玩家数据[数字id].角色.数据.活力= 玩家数据[数字id].角色.数据.活力-临时消耗
  体活刷新(数字id)
  if 临时等级<=4 then
   物品表={"包子"}
  elseif 临时等级<=9 then
   物品表={"包子","包子","佛跳墙","包子"}
  elseif 临时等级<=14 then
   物品表={"包子","包子","佛跳墙","包子","烤鸭"}
  elseif 临时等级<=19 then
   物品表={"包子","珍露酒","佛跳墙","烤鸭","佛跳墙","佛跳墙","包子","烤鸭"}
  elseif 临时等级<=24 then
   物品表={"包子","珍露酒","佛跳墙","佛跳墙","佛跳墙","烤鸭","包子","烤鸭","虎骨酒","佛跳墙","佛跳墙","包子","女儿红"}
  elseif 临时等级<=29 then
   物品表={"包子","珍露酒","豆斋果","佛跳墙","烤鸭","包子","佛跳墙","佛跳墙","烤鸭","虎骨酒","烤鸭","包子","女儿红"}
 elseif 临时等级<=34 then
   物品表={"包子","佛跳墙","佛跳墙","佛跳墙","珍露酒","烤鸭","烤鸭","豆斋果","烤鸭","臭豆腐","佛跳墙","包子","烤鸭","虎骨酒","包子","女儿红"}
  elseif 临时等级<=39 then
   物品表={"烤肉","桂花丸","佛跳墙","佛跳墙","佛跳墙","珍露酒","烤鸭","烤鸭","豆斋果","烤鸭","臭豆腐","佛跳墙","包子","烤鸭","虎骨酒","包子","女儿红"}
  elseif 临时等级<=44 then
   物品表={"烤肉","翡翠豆腐","桂花丸","佛跳墙","佛跳墙","佛跳墙","珍露酒","烤鸭","烤鸭","豆斋果","烤鸭","臭豆腐","佛跳墙","包子","烤鸭","虎骨酒","包子","女儿红"}
  elseif 临时等级<=49 then
   物品表={"烤肉","长寿面","翡翠豆腐","桂花丸","佛跳墙","佛跳墙","佛跳墙","珍露酒","烤鸭","烤鸭","豆斋果","烤鸭","臭豆腐","佛跳墙","包子","烤鸭","虎骨酒","包子","女儿红"}
  elseif 临时等级<=54 then
   物品表={"烤肉","梅花酒","长寿面","翡翠豆腐","桂花丸","佛跳墙","佛跳墙","佛跳墙","珍露酒","烤鸭","烤鸭","豆斋果","烤鸭","臭豆腐","佛跳墙","包子","烤鸭","虎骨酒","包子","女儿红"}
  elseif 临时等级<=59 then
   物品表={"烤肉","百味酒","梅花酒","长寿面","翡翠豆腐","桂花丸","佛跳墙","佛跳墙","佛跳墙","珍露酒","烤鸭","烤鸭","豆斋果","烤鸭","臭豆腐","佛跳墙","包子","烤鸭","虎骨酒","包子","女儿红"}
  elseif 临时等级<=64 then
   物品表={"烤肉","蛇胆酒","百味酒","梅花酒","长寿面","翡翠豆腐","桂花丸","佛跳墙","佛跳墙","佛跳墙","珍露酒","烤鸭","烤鸭","豆斋果","烤鸭","臭豆腐","佛跳墙","包子","烤鸭","虎骨酒","包子","女儿红"}
  else
   物品表={"烤肉","醉生梦死","蛇胆酒","百味酒","梅花酒","长寿面","翡翠豆腐","桂花丸","佛跳墙","佛跳墙","佛跳墙","珍露酒","烤鸭","烤鸭","豆斋果","烤鸭","臭豆腐","佛跳墙","包子","烤鸭","虎骨酒","包子","女儿红"}
  end
  local 临时物品=物品表[取随机数(1,#物品表)]
  local 临时品质=0
  if 临时物品~="包子" then
    临时品质=取随机数(math.floor(临时等级*0.5),临时等级)
  end
  常规提示(数字id,"#W/经过一阵忙碌，你烹制出了#R/"..临时物品)
  self:给予道具(数字id,临时物品,1,临时品质)
  发送数据(连接id,3699)
  道具刷新(数字id)
end

function 道具处理类:炼药处理(连接id,数字id,数据)
  local 临时等级=玩家数据[数字id].角色:取生活技能等级("中药医理")
  local 临时消耗=math.floor(临时等级)+10
  if 玩家数据[数字id].角色.数据.活力<临时消耗 then
   常规提示(数字id,"本次操作需要消耗"..临时消耗.."点活力")
   return
  elseif 临时等级<10 then
   常规提示(数字id,"您的中药医理技能尚未达到10级，无法进行炼药操作")
   return
  elseif 玩家数据[数字id].角色.数据.银子<5000 then
    常规提示(数字id,"炼药需要消耗5000两银子")
    return
  end
  玩家数据[数字id].角色:扣除银子(5000,0,0,"炼药消耗",1)
  玩家数据[数字id].角色.数据.活力= 玩家数据[数字id].角色.数据.活力-临时消耗
  体活刷新(数字id)
  local 物品表={}
  物品表={"金创药","金创药","金创药","金香玉","金创药","金创药","小还丹","金创药","金创药","千年保心丹","金创药","金创药","风水混元丹","金创药","金创药","定神香","金创药","金创药","蛇蝎美人","金创药","金创药","九转回魂丹","金创药","金创药","佛光舍利子","金创药","金创药","十香返生丸","金创药","金创药","金创药","金创药","五龙丹"}
  local 临时物品=物品表[取随机数(1,#物品表)]
  local 临时品质=0
  临时品质=取随机数(math.floor(临时等级*0.5),临时等级)
  常规提示(数字id,"#W/恭喜你成功炼制出了#R/"..临时物品)
  self:给予道具(数字id,临时物品,1,临时品质)
  发送数据(连接id,3699)
  道具刷新(数字id)
end

function 道具处理类:染色处理(连接id,id,数据)
  local 彩果数量=0
  for n=1,#数据 do
    彩果数量=彩果数量+数据[n]
  end
  local 扣除数据={}
  local 已扣除=0
  for n=1,20 do
    if 玩家数据[id].角色.数据.道具[n]~=nil and self.数据[玩家数据[id].角色.数据.道具[n]]~=nil and self.数据[玩家数据[id].角色.数据.道具[n]].名称=="彩果" and 已扣除<彩果数量 then
      if self.数据[玩家数据[id].角色.数据.道具[n]].数量>=彩果数量-已扣除 then
        扣除数据[#扣除数据+1]={格子=n,id=玩家数据[id].角色.数据.道具[n],数量=彩果数量-已扣除}
        已扣除=已扣除+(彩果数量-已扣除)
      else
        已扣除=已扣除+self.数据[玩家数据[id].角色.数据.道具[n]].数量
        扣除数据[#扣除数据+1]={格子=n,id=玩家数据[id].角色.数据.道具[n],数量=self.数据[玩家数据[id].角色.数据.道具[n]].数量}
      end
    end
  end
  if 已扣除<彩果数量 then
    常规提示(id,"你没有那么多的彩果")
    return
  else
    for n=1,#扣除数据 do
      self.数据[扣除数据[n].id].数量=self.数据[扣除数据[n].id].数量-扣除数据[n].数量
      if self.数据[扣除数据[n].id].数量<=0 then
        self.数据[扣除数据[n].id]=nil
        玩家数据[id].角色.数据.道具[扣除数据[n].格子]=nil
      end
    end
    常规提示(id,"染色成功！")
    玩家数据[id].角色.数据.染色组=数据
    发送数据(连接id,30,数据)
    发送数据(连接id,3699)
    道具刷新(id)
    地图处理类:更改染色(id,数据,玩家数据[id].角色.数据.染色方案)
  end
end

function 道具处理类:神秘宝箱处理(连接id,id,数据)
  if 神秘宝箱[id]==nil then
    常规提示(id,"数据异常！")
    return
  end
  local 序号=神秘宝箱[id].中奖
  local 名称=神秘宝箱[id][序号].名称
  local 随机数=取随机数(1,100)
  if 名称=="红玛瑙" or 名称=="太阳石" or 名称=="舍利子" or 名称=="黑宝石" or 名称=="月亮石" or 名称=="光芒石" then
    if 随机数<=60 then
       玩家数据[id].道具:给予道具(id,名称,取随机数(11,13))
    else
        玩家数据[id].道具:给予道具(id,名称,取随机数(14,16))
    end
    常规提示(id,"#Y你获得了#R"..名称)
  elseif 名称=="星辉石" then
    if 随机数<=60 then
       玩家数据[id].道具:给予道具(id,名称,取随机数(11,12))
    else
        玩家数据[id].道具:给予道具(id,名称,取随机数(13,14))
    end
    常规提示(id,"#Y你获得了#R"..名称)
  elseif 名称=="高级兽决" then
    local 物品名称="高级魔兽要诀"
    local 技能=取高级要诀()
    常规提示(id,"#Y/你获得了"..名称)
    if 随机数<=60 then
        玩家数据[id].道具:给予道具(id,物品名称,nil,技能)
    else
        技能=取特殊要诀1()
        玩家数据[id].道具:给予道具(id,物品名称,nil,技能)
    end
    常规提示(id,"#Y你获得了#R"..物品名称)
  elseif 名称=="随机法宝" then
    self:给予随机一级法宝(id)
    道具刷新(id)
  elseif 名称=="武器" then
    礼包奖励类:取随机武器(id,160,"无级别限制")
  elseif 名称=="高级武器" then
    礼包奖励类:取随机高级武器(id,160,"无级别限制")
  elseif 名称=="装备" then
    礼包奖励类:取随机装备(id,160,"无级别限制")
  elseif 名称=="高级装备" then
    礼包奖励类:取随机高级装备(id,160,"无级别限制")
  elseif 名称=="30点卡" then
    添加点卡(30,玩家数据[id].账号,id,"武神坛抽奖")
    常规提示(id,"#Y你获得了#R"..名称)
  elseif 名称=="50点卡" then
    添加点卡(50,玩家数据[id].账号,id,"武神坛抽奖")
    常规提示(id,"#Y你获得了#R"..名称)
  elseif 名称=="80点卡" then
    添加点卡(80,玩家数据[id].账号,id,"武神坛抽奖")
    常规提示(id,"#Y你获得了#R"..名称)
  elseif 名称=="100点卡" then
    添加点卡(100,玩家数据[id].账号,id,"武神坛抽奖")
    常规提示(id,"#Y你获得了#R"..名称)
  elseif 名称=="120点卡" then
    添加点卡(120,玩家数据[id].账号,id,"武神坛抽奖")
    常规提示(id,"#Y你获得了#R"..名称)
  elseif 名称=="200点卡" then
    添加点卡(200,玩家数据[id].账号,id,"武神坛抽奖")
    常规提示(id,"#Y你获得了#R"..名称)
  elseif 名称=="500点卡" then
    添加点卡(500,玩家数据[id].账号,id,"武神坛抽奖")
    常规提示(id,"#Y你获得了#R"..名称)
  elseif 名称=="1000点卡" then
    添加点卡(1000,玩家数据[id].账号,id,"武神坛抽奖")
    常规提示(id,"#Y你获得了#R"..名称)
  elseif 名称=="2000点卡" then
    添加点卡(2000,玩家数据[id].账号,id,"武神坛抽奖")
    常规提示(id,"#Y你获得了#R"..名称)
  elseif 名称=="金砖" then
      玩家数据[id].角色:添加银子(100000000,"神秘宝箱",1)
  elseif 名称=="仙丹" then
      玩家数据[id].角色:添加经验(100000000,"神秘宝箱",1)
  end
end

function 道具处理类:仙玉神秘宝箱处理(连接id,id,数据)
  if 神秘宝箱[id]==nil then
    常规提示(id,"数据异常！")
    return
  end
  local 序号=神秘宝箱[id].中奖
  local 名称=神秘宝箱[id][序号].名称
  local 随机数=取随机数(1,100)
  if 名称=="红玛瑙" or 名称=="太阳石" or 名称=="舍利子" or 名称=="黑宝石" or 名称=="月亮石" or 名称=="光芒石" then
    if 让海啸席卷 then
      玩家数据[id].道具:给予道具(id,名称,取随机数(5,12))
    else
      if 随机数<=60 then
        玩家数据[id].道具:给予道具(id,名称,取随机数(11,13))
      else
        玩家数据[id].道具:给予道具(id,名称,取随机数(14,16))
      end
    end
    常规提示(id,"#Y你获得了#R"..名称)
    广播消息({内容=format("#S(武神坛转盘)#R/%s#Y在武神坛使者处获得了#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,名称),频道="xt"})
  elseif 名称=="星辉石" then
    if 让海啸席卷 then
      玩家数据[id].道具:给予道具(id,名称,取随机数(5,12))
    else
      if 随机数<=60 then
        玩家数据[id].道具:给予道具(id,名称,取随机数(11,12))
      else
        玩家数据[id].道具:给予道具(id,名称,取随机数(13,14))
      end
    end
    常规提示(id,"#Y你获得了#R"..名称)
    广播消息({内容=format("#S(武神坛转盘)#R/%s#Y在武神坛使者处获得了#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,名称),频道="xt"})
  elseif 名称=="高级兽决" then
      local 物品名称="高级魔兽要诀"
      local 技能=取高级要诀()
      常规提示(id,"#Y/你获得了"..名称)
      if 随机数<=60 then
        玩家数据[id].道具:给予道具(id,物品名称,nil,技能)
      else
        技能=取特殊要诀1()
        玩家数据[id].道具:给予道具(id,物品名称,nil,技能)
      end
      常规提示(id,"#Y你获得了#R"..物品名称)
      广播消息({内容=format("#S(武神坛转盘)#R/%s#Y在武神坛使者处获得了#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,物品名称),频道="xt"})
  elseif 名称=="随机法宝" then
      self:给予随机一级法宝(id)
      道具刷新(id)
      广播消息({内容=format("#S(武神坛转盘)#R/%s#Y在武神坛使者处获得了#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,"一级法宝"),频道="xt"})
  elseif 名称=="武器" then
    礼包奖励类:取随机武器(id,160,"无级别限制")
    广播消息({内容=format("#S(武神坛转盘)#R/%s#Y在武神坛使者处获得了#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,"160级武器"),频道="xt"})
  elseif 名称=="高级武器" then
    礼包奖励类:取随机高级武器(id,160,"无级别限制")
    广播消息({内容=format("#S(武神坛转盘)#R/%s#Y在武神坛使者处获得了#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,"160级武器"),频道="xt"})
  elseif 名称=="装备" then
    礼包奖励类:取随机装备(id,160,"无级别限制")
    广播消息({内容=format("#S(武神坛转盘)#R/%s#Y在武神坛使者处获得了#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,"160级装备"),频道="xt"})
  elseif 名称=="高级装备" then
    礼包奖励类:取随机高级装备(id,160,"无级别限制")
    广播消息({内容=format("#S(武神坛转盘)#R/%s#Y在武神坛使者处获得了#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,"160级装备"),频道="xt"})
  elseif 名称=="储备" then
    玩家数据[id].角色:添加储备(100000000,"神秘宝箱",1)
    广播消息({内容=format("#S(武神坛转盘)#R/%s#Y在武神坛使者处获得了#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,"一亿储备"),频道="xt"})
  elseif 名称=="超级金柳露" then
    self:给予道具(id,名称,1)
    常规提示(id,"#Y你获得了#R"..名称)
    广播消息({内容=format("#S(武神坛转盘)#R/%s#Y在武神坛使者处获得了#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,名称),频道="xt"})
  elseif 名称=="百炼精铁" then
    self:给予书铁(id,{14,14})
    常规提示(id,"#Y你获得了#R随机140书铁")
    广播消息({内容=format("#S(武神坛转盘)#R/%s#Y在武神坛使者处获得了#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,"140级随机书铁"),频道="xt"})
  elseif 名称=="制造指南书" then
    self:给予书铁(id,{15,15})
    常规提示(id,"#Y你获得了#R随机150书铁")
    广播消息({内容=format("#S(武神坛转盘)#R/%s#Y在武神坛使者处获得了#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,"150级随机书铁"),频道="xt"})
  elseif 名称=="神兜兜" then
    if 取随机数()<=90 then
      self:给予道具(id,名称,1)
      常规提示(id,"#Y你获得了一个#R"..名称)
      广播消息({内容=format("#S(武神坛转盘)#R/%s#Y在武神坛使者处获得了#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,名称),频道="xt"})
    else
      self:给予道具(id,名称,99)
      常规提示(id,"#Y你获得了99个#R"..名称)
      广播消息({内容=format("#S(武神坛转盘)#R/%s#Y在武神坛使者处获得了#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,"99个神兜兜"),频道="xt"})
    end
  elseif 名称=="魔兽残卷" then
    self:给予道具(id,名称,3)
    常规提示(id,"#Y你获得了3个#R"..名称)
    广播消息({内容=format("#S(武神坛转盘)#R/%s#Y在武神坛使者处获得了#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,名称),频道="xt"})
  elseif 名称=="10点卡" then
    添加点卡(10,玩家数据[id].账号,id,"武神坛抽奖")
    常规提示(id,"#Y你获得了#R"..名称)
    广播消息({内容=format("#S(武神坛转盘)#R/%s#Y在武神坛使者处获得了#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,名称),频道="xt"})
  elseif 名称=="20点卡" then
    添加点卡(20,玩家数据[id].账号,id,"武神坛抽奖")
    常规提示(id,"#Y你获得了#R"..名称)
    广播消息({内容=format("#S(武神坛转盘)#R/%s#Y在武神坛使者处获得了#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,名称),频道="xt"})
  elseif 名称=="30点卡" then
    添加点卡(30,玩家数据[id].账号,id,"武神坛抽奖")
    常规提示(id,"#Y你获得了#R"..名称)
    广播消息({内容=format("#S(武神坛转盘)#R/%s#Y在武神坛使者处获得了#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,名称),频道="xt"})
  elseif 名称=="40点卡" then
    添加点卡(40,玩家数据[id].账号,id,"武神坛抽奖")
    常规提示(id,"#Y你获得了#R"..名称)
    广播消息({内容=format("#S(武神坛转盘)#R/%s#Y在武神坛使者处获得了#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,名称),频道="xt"})
  elseif 名称=="50点卡" then
    添加点卡(50,玩家数据[id].账号,id,"武神坛抽奖")
    常规提示(id,"#Y你获得了#R"..名称)
    广播消息({内容=format("#S(武神坛转盘)#R/%s#Y在武神坛使者处获得了#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,名称),频道="xt"})
  elseif 名称=="100点卡" then
    添加点卡(100,玩家数据[id].账号,id,"武神坛抽奖")
    常规提示(id,"#Y你获得了#R"..名称)
    广播消息({内容=format("#S(武神坛转盘)#R/%s#Y在武神坛使者处获得了#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,名称),频道="xt"})
  elseif 名称=="120点卡" then
    添加点卡(120,玩家数据[id].账号,id,"武神坛抽奖")
    常规提示(id,"#Y你获得了#R"..名称)
    广播消息({内容=format("#S(武神坛转盘)#R/%s#Y在武神坛使者处获得了#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,名称),频道="xt"})
  elseif 名称=="200点卡" then
    添加点卡(200,玩家数据[id].账号,id,"武神坛抽奖")
    常规提示(id,"#Y你获得了#R"..名称)
    广播消息({内容=format("#S(武神坛转盘)#R/%s#Y在武神坛使者处获得了#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,名称),频道="xt"})
  elseif 名称=="500点卡" then
    添加点卡(500,玩家数据[id].账号,id,"武神坛抽奖")
    常规提示(id,"#Y你获得了#R"..名称)
    广播消息({内容=format("#S(武神坛转盘)#R/%s#Y在武神坛使者处获得了#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,名称),频道="xt"})
  elseif 名称=="1000点卡" then
    添加点卡(1000,玩家数据[id].账号,id,"武神坛抽奖")
    常规提示(id,"#Y你获得了#R"..名称)
    广播消息({内容=format("#S(武神坛转盘)#R/%s#Y在武神坛使者处获得了#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,名称),频道="xt"})
  elseif 名称=="2000点卡" then
    添加点卡(2000,玩家数据[id].账号,id,"武神坛抽奖")
    常规提示(id,"#Y你获得了#R"..名称)
    广播消息({内容=format("#S(武神坛转盘)#R/%s#Y在武神坛使者处获得了#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,名称),频道="xt"})
  elseif 名称=="金砖" then
      玩家数据[id].角色:添加银子(50000000,"神秘宝箱",1)
      广播消息({内容=format("#S(武神坛转盘)#R/%s#Y在武神坛使者处获得了#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,名称),频道="xt"})
  elseif 名称=="仙丹" then
      玩家数据[id].角色:添加经验(100000000,"神秘宝箱",1)
      广播消息({内容=format("#S(武神坛转盘)#R/%s#Y在武神坛使者处获得了#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,名称),频道="xt"})
  end
end

function 道具处理类:钥匙神秘宝箱处理(连接id,id,数据)
  if 神秘宝箱[id]==nil then
    常规提示(id,"数据异常！")
    return
  end
  local 序号=神秘宝箱[id].中奖
  local 名称=神秘宝箱[id][序号].名称
  local 随机数=取随机数(1,100)
  if 名称=="红玛瑙" or 名称=="太阳石" or 名称=="舍利子" or 名称=="黑宝石" or 名称=="月亮石" or 名称=="光芒石" then
    if 随机数<=60 then
      玩家数据[id].道具:给予道具(id,名称,取随机数(4,8))
    else
      玩家数据[id].道具:给予道具(id,名称,取随机数(8,12))
    end
    常规提示(id,"#Y你获得了#R"..名称)
  elseif 名称=="星辉石" then
    if 随机数<=60 then
      玩家数据[id].道具:给予道具(id,名称,取随机数(3,6))
    else
      玩家数据[id].道具:给予道具(id,名称,取随机数(6,10))
    end
    常规提示(id,"#Y你获得了#R"..名称)
  elseif 名称=="高级兽决" then
    local 物品名称="高级魔兽要诀"
    常规提示(id,"#Y/你获得了"..物品名称)
    玩家数据[id].道具:给予道具(id,物品名称,1)
  elseif 名称=="随机法宝" then
    self:给予随机一级法宝(id)
    道具刷新(id)
  elseif 名称=="武器" then
    礼包奖励类:取随机武器(id,150,"无级别限制")
  elseif 名称=="高级武器" then
    礼包奖励类:取随机武器(id,160,"无级别限制")
  elseif 名称=="装备" then
    礼包奖励类:取随机装备(id,150,"无级别限制")
  elseif 名称=="高级装备" then
    礼包奖励类:取随机装备(id,160,"无级别限制")
  elseif 名称=="储备" then
    玩家数据[id].角色:添加储备(66666666,"神秘宝箱",1)
  elseif 名称=="超级金柳露" then
    self:给予道具(id,名称,1)
    常规提示(id,"#Y你获得了#R"..名称)
  elseif 名称=="200点卡" then
    添加仙玉(200,玩家数据[id].账号,id,"神秘宝箱")
    常规提示(id,"#Y你获得了#R"..名称)
  elseif 名称=="300点卡" then
    添加仙玉(300,玩家数据[id].账号,id,"神秘宝箱")
    常规提示(id,"#Y你获得了#R"..名称)
  elseif 名称=="400点卡" then
    添加仙玉(400,玩家数据[id].账号,id,"神秘宝箱")
    常规提示(id,"#Y你获得了#R"..名称)
  elseif 名称=="600点卡" then
    添加仙玉(600,玩家数据[id].账号,id,"神秘宝箱")
    常规提示(id,"#Y你获得了#R"..名称)
  elseif 名称=="1000点卡" then
    添加仙玉(1000,玩家数据[id].账号,id,"神秘宝箱")
    常规提示(id,"#Y你获得了#R"..名称)
  elseif 名称=="2500点卡" then
    添加仙玉(2500,玩家数据[id].账号,id,"神秘宝箱")
    常规提示(id,"#Y你获得了#R"..名称)
  elseif 名称=="金砖" then
    玩家数据[id].角色:添加银子(40000000,"神秘宝箱",1)
  elseif 名称=="仙丹" then
    玩家数据[id].角色:添加经验(40000000,"神秘宝箱",1)
  end
end

function 道具处理类:老唐定制宝箱处理(连接id,id,数据)
  if 神秘宝箱[id]==nil then
    常规提示(id,"数据异常！")
    return
  end
  local 序号=神秘宝箱[id].中奖
  local 名称=神秘宝箱[id][序号].名称
  local 随机数=取随机数(1,100)
  if 名称=="灵饰兑换卡" then
    玩家数据[id].道具:给予道具(id,名称,1)
    常规提示(id,"#Y你获得了#R"..名称)
    广播消息({内容=format("#S(神秘转盘)#Y恭喜玩家#R/%s#Y鸿运当头，使用神秘钥匙抽到了珍贵的#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,名称),频道="xt"})
  elseif 名称=="召唤兽装备兑换卡" then
    玩家数据[id].道具:给予道具(id,名称,1)
    常规提示(id,"#Y你获得了#R"..名称)
    广播消息({内容=format("#S(神秘转盘)#Y恭喜玩家#R/%s#Y鸿运当头，使用神秘钥匙抽到了珍贵的#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,名称),频道="xt"})
  elseif 名称=="高级兽决" then
    local 物品名称="高级魔兽要诀"
    常规提示(id,"#Y/你获得了"..物品名称)
    玩家数据[id].道具:给予道具(id,物品名称,1)
  elseif 名称=="召唤兽祈愿卡" then
    玩家数据[id].道具:给予道具(id,名称,1)
    常规提示(id,"#Y你获得了#R"..名称)
    广播消息({内容=format("#S(神秘转盘)#Y恭喜玩家#R/%s#Y鸿运当头，使用神秘钥匙抽到了珍贵的#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,名称),频道="xt"})
  elseif 名称=="高级召唤兽祈愿卡" then
    玩家数据[id].道具:给予道具(id,名称,1)
    常规提示(id,"#Y你获得了#R"..名称)
    广播消息({内容=format("#S(神秘转盘)#Y恭喜玩家#R/%s#Y鸿运当头，使用神秘钥匙抽到了珍贵的#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,名称),频道="xt"})
  elseif 名称=="160级装备礼包" then
    玩家数据[id].道具:给予道具(id,名称,1)
    常规提示(id,"#Y你获得了#R"..名称)
    广播消息({内容=format("#S(神秘转盘)#Y恭喜玩家#R/%s#Y鸿运当头，使用神秘钥匙抽到了珍贵的#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,名称),频道="xt"})
  elseif 名称=="150级装备礼包" then
    玩家数据[id].道具:给予道具(id,名称,1)
    常规提示(id,"#Y你获得了#R"..名称)
    广播消息({内容=format("#S(神秘转盘)#Y恭喜玩家#R/%s#Y鸿运当头，使用神秘钥匙抽到了珍贵的#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,名称),频道="xt"})
  elseif 名称=="星辉石" then
    玩家数据[id].道具:给予道具(id,名称,5)
    常规提示(id,"#Y你获得了#R"..名称)
  elseif 名称=="锦衣兑换卡" then
    玩家数据[id].道具:给予道具(id,名称,1)
    常规提示(id,"#Y你获得了#R"..名称)
    广播消息({内容=format("#S(神秘转盘)#Y恭喜玩家#R/%s#Y鸿运当头，使用神秘钥匙抽到了珍贵的#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,名称),频道="xt"})
  elseif 名称=="特殊兽诀" then
    local 物品名称="高级魔兽要诀"
    local 随机特殊={"上古灵符","叱咤风云","净台妙谛","须弥真言","天降灵葫","大快朵颐","死亡召唤","嗜血追击","灵能激发","龙魂","理直气壮"}
    local 技能=随机特殊[取随机数(1,#随机特殊)]
    常规提示(id,"#Y/你获得了"..物品名称)
    玩家数据[id].道具:给予道具(id,物品名称,nil,技能)
    广播消息({内容=format("#S(神秘转盘)#Y恭喜玩家#R/%s#Y鸿运当头，使用神秘钥匙抽到了珍贵的#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,物品名称),频道="xt"})
  elseif 名称=="九转金丹" then
    self:给予道具(id,名称,1,500)
    常规提示(id,"#Y你获得了#R"..名称)
  elseif 名称=="坐骑内丹" then
    玩家数据[id].道具:给予道具(id,名称,1)
    常规提示(id,"#Y你获得了#R"..名称)
   elseif 名称=="融合石" then
    玩家数据[id].道具:给予道具(id,名称,1)
    常规提示(id,"#Y你获得了#R"..名称)
  elseif 名称=="元灵晶石" then
    玩家数据[id].道具:给予道具(id,名称,{14})
    常规提示(id,"#Y你获得了#R"..名称)
  elseif 名称=="灵饰指南书" then
    玩家数据[id].道具:给予道具(id,名称,{14})
    常规提示(id,"#Y你获得了#R"..名称)
  elseif 名称=="观照万象" then
    常规提示(id,"#Y/你获得了"..名称)
    玩家数据[id].道具:给予道具(id,"高级魔兽要诀",nil,名称)
    广播消息({内容=format("#S(神秘转盘)#Y恭喜玩家#R/%s#Y鸿运当头，使用神秘钥匙抽到了珍贵的#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,名称),频道="xt"})
  elseif 名称=="附魔宝珠" then
    常规提示(id,"#Y/你获得了"..名称)
    玩家数据[id].道具:给予道具(id,名称,1)
  elseif 名称=="随机5级宝石" then
    local 名称=取宝石()
    常规提示(id,"#Y/你获得了"..名称)
    玩家数据[id].道具:给予道具(id,名称,5)
  elseif 名称=="储备" then
    玩家数据[id].角色:添加储备(66666666,"神秘宝箱",1)
  elseif 名称=="超级金柳露" then
    self:给予道具(id,名称,1)
    常规提示(id,"#Y你获得了#R"..名称)
  elseif 名称=="10点卡" then
    添加点卡(10,玩家数据[id].账号,id,"神秘宝箱")
    常规提示(id,"#Y你获得了#R"..名称)
  elseif 名称=="50点卡" then
    添加点卡(50,玩家数据[id].账号,id,"神秘宝箱")
    常规提示(id,"#Y你获得了#R"..名称)
  elseif 名称=="100点卡" then
    添加点卡(100,玩家数据[id].账号,id,"神秘宝箱")
    常规提示(id,"#Y你获得了#R"..名称)
  elseif 名称=="金砖1" then
    玩家数据[id].角色:添加银子(5000000,"神秘宝箱",1)
  elseif 名称=="金砖2" then
    玩家数据[id].角色:添加银子(10000000,"神秘宝箱",1)
  elseif 名称=="金砖3" then
    玩家数据[id].角色:添加银子(100000000,"神秘宝箱",1)
  elseif 名称=="仙丹" then
    玩家数据[id].角色:添加经验(40000000,"神秘宝箱",1)
  end
end

function 道具处理类:神树抽奖(id)
  local 获奖几率 = 取随机数(1,330)
  if 老八定制 then
    if 玩家数据[id].角色:扣除仙玉(300,"神树抽奖",id) == false then
        常规提示(id,"#Y你当前没有那么多仙玉进行抽奖哦，抽奖需要消耗300点仙玉。")
        return
    end
    获奖几率 = 取随机数(1,301)
    if 获奖几率<=30 then
      玩家数据[id].角色:添加经验(1000000,"神树抽奖",1)
    elseif 获奖几率<=60 then
      玩家数据[id].角色:添加银子(5000000,"神树抽奖",1)
    elseif 获奖几率<=90 then
      if 玩家数据[id].角色.数据.参战信息~=nil then
        玩家数据[id].召唤兽:获得经验(玩家数据[id].角色.数据.参战宝宝.认证码,5000000,id,"神树抽奖")
      else
        常规提示(id,"#Y当前没有参战召唤兽，所以无法获得召唤兽经验。")
        return
      end
    elseif 获奖几率<=120 then
      local 名称=取宝石()
      self:给予道具(id,名称,取随机数(1,5))
      常规提示(id,"#Y你获得了#R"..名称)
      广播消息({内容=format("#S(神树抽奖)#R/%s#Y感动上苍，因此在#R%s#Y获得了其奖励的#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,"神树抽奖活动",名称),频道="xt"})
    elseif 获奖几率<=180 then
      local 名称="高级魔兽要诀"
      local 技能=取高级要诀()
      self:给予道具(id,名称,nil,技能)
      常规提示(id,"#Y你获得了#R"..名称)
      广播消息({内容=format("#S(神树抽奖)#R/%s#Y感动上苍，因此在#R%s#Y获得了其奖励的#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,"神树抽奖活动",名称),频道="xt"})
    elseif 获奖几率<=230 then
      local 名称="魔兽要诀"
      self:给予道具(id,名称)
      常规提示(id,"#Y你获得了#R"..名称)
      广播消息({内容=format("#S(神树抽奖)#R/%s#Y感动上苍，因此在#R%s#Y获得了其奖励的#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,"神树抽奖活动",名称),频道="xt"})
    elseif 获奖几率<=260 then
      local 名称="一级未激活符石"
      self:给予道具(id,名称,1)
      常规提示(id,"#Y你获得了#R"..名称)
      广播消息({内容=format("#S(神树抽奖)#R/%s#Y感动上苍，因此在#R%s#Y获得了其奖励的#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,"神树抽奖活动",名称),频道="xt"})
    elseif 获奖几率<=280 then
      local 名称="二级未激活符石"
      self:给予道具(id,名称,1)
      常规提示(id,"#Y你获得了#R"..名称)
      广播消息({内容=format("#S(神树抽奖)#R/%s#Y感动上苍，因此在#R%s#Y获得了其奖励的#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,"神树抽奖活动",名称),频道="xt"})
    elseif 获奖几率<=300 then
      local 名称="三级未激活符石"
      self:给予道具(id,名称,1)
      常规提示(id,"#Y你获得了#R"..名称)
      广播消息({内容=format("#S(神树抽奖)#R/%s#Y感动上苍，因此在#R%s#Y获得了其奖励的#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,"神树抽奖活动",名称),频道="xt"})
    elseif 获奖几率<=301 then
      local 物品名称="高级魔兽要诀"
      local 技能=取特殊要诀1()
      self:给予道具(id,物品名称,nil,技能)
      常规提示(id,"#Y你获得了#R"..物品名称)
      广播消息({内容=format("#S(神树抽奖)#R/%s#Y感动上苍，因此在#R%s#Y获得了其奖励的#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,"神树抽奖活动",物品名称),频道="xt"})
    end
  elseif 二徒弟定制 then
    if 玩家数据[id].角色:扣除仙玉(500,"神树抽奖",id) == false then
        常规提示(id,"#Y你当前没有那么多仙玉进行抽奖哦，抽奖需要消耗500点仙玉。")
        return
    end
    if 获奖几率<=30 then
      玩家数据[id].角色:添加经验(5000000,"神树抽奖",1)
    elseif 获奖几率<=60 then
      玩家数据[id].角色:添加银子(10000000,"神树抽奖",1)
    elseif 获奖几率<=90 then
      if 玩家数据[id].角色.数据.参战信息~=nil then
        玩家数据[id].召唤兽:获得经验(玩家数据[id].角色.数据.参战宝宝.认证码,5000000,id,"神树抽奖")
      else
        常规提示(id,"#Y当前没有参战召唤兽，所以无法获得召唤兽经验。")
        return
      end
    elseif 获奖几率<=120 then
      local 名称=取宝石()
      self:给予道具(id,名称,取随机数(5,10))
      常规提示(id,"#Y你获得了#R"..名称)
      广播消息({内容=format("#S(神树抽奖)#R/%s#Y感动上苍，因此在#R%s#Y获得了其奖励的#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,"神树抽奖活动",名称),频道="xt"})
    elseif 获奖几率<=150 then
      local 名称="星辉石"
      self:给予道具(id,名称,取随机数(5,10))
      常规提示(id,"#Y你获得了#R"..名称)
      广播消息({内容=format("#S(神树抽奖)#R/%s#Y感动上苍，因此在#R%s#Y获得了其奖励的#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,"神树抽奖活动",名称),频道="xt"})
    elseif 获奖几率<=180 then
      local 名称="九转金丹"
      self:给予道具(id,名称,1,100)
      常规提示(id,"#Y你获得了#R"..名称)
      广播消息({内容=format("#S(神树抽奖)#R/%s#Y感动上苍，因此在#R%s#Y获得了其奖励的#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,"神树抽奖活动",名称),频道="xt"})
    elseif 获奖几率<=210 then
      local 物品名称="高级魔兽要诀"
      local 技能=取高级要诀()
      self:给予道具(id,物品名称,nil,技能)
      常规提示(id,"#Y你获得了#R"..物品名称)
      广播消息({内容=format("#S(神树抽奖)#R/%s#Y感动上苍，因此在#R%s#Y获得了其奖励的#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,"神树抽奖活动",物品名称),频道="xt"})
    elseif 获奖几率<=230 then
      local 名称="特赦令牌"
      self:给予道具(id,名称,1)
      常规提示(id,"#Y你获得了#R"..名称)
      广播消息({内容=format("#S(神树抽奖)#R/%s#Y感动上苍，因此在#R%s#Y获得了其奖励的#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,"神树抽奖活动",名称),频道="xt"})
    elseif 获奖几率<=280 then
      local 名称=取强化石()
      self:给予道具(id,名称,1)
      常规提示(id,"#Y你获得了#R"..名称)
      广播消息({内容=format("#S(神树抽奖)#R/%s#Y感动上苍，因此在#R%s#Y获得了其奖励的#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,"神树抽奖活动",名称),频道="xt"})
    elseif 获奖几率<=300 then
      local 名称="灵饰指南书"
      玩家数据[id].道具:给予道具(id,"灵饰指南书",{12,14})
      常规提示(id,"#Y/你获得了"..名称)
      广播消息({内容=format("#S(神树抽奖)#R/%s#Y感动上苍，因此在#R%s#Y获得了其奖励的#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,"神树抽奖活动",名称),频道="xt"})
    elseif 获奖几率<=320 then
      local 名称="元灵晶石"
      玩家数据[id].道具:给予道具(id,"元灵晶石",{12,14})
      常规提示(id,"#Y/你获得了"..名称)
      广播消息({内容=format("#S(神树抽奖)#R/%s#Y感动上苍，因此在#R%s#Y获得了其奖励的#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,"神树抽奖活动",名称),频道="xt"})
    elseif 获奖几率<=325 then
      礼包奖励类:随机装备(id,150)
      广播消息({内容=format("#S(神树抽奖)#R/%s#Y感动上苍，因此在#R%s#Y获得了其奖励的#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,"神树抽奖活动","150级随机装备一件"),频道="xt"})
    elseif 获奖几率<=330 then
      local 物品名称="高级魔兽要诀"
      local 技能=取特殊要诀1()
      self:给予道具(id,物品名称,nil,技能)
      常规提示(id,"#Y你获得了#R"..物品名称)
      广播消息({内容=format("#S(神树抽奖)#R/%s#Y感动上苍，因此在#R%s#Y获得了其奖励的#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,"神树抽奖活动",物品名称),频道="xt"})
    end
  else
    local 抽奖消耗 = 20000000
    if 让海啸席卷 then
      获奖几率 = 取随机数(1,508)
      抽奖消耗 = 30000000
    end
    if 取银子(id) < 抽奖消耗 then
        常规提示(id,"#Y你当前没有那么多银子进行抽奖哦，抽奖需要消耗"..抽奖消耗.."两银子。")
        return
    end
    玩家数据[id].角色:扣除银子(抽奖消耗,0,0,"神树抽奖",1)
    if 获奖几率<=30 then
      玩家数据[id].角色:添加经验(5000000,"神树抽奖",1)
    elseif 获奖几率<=60 then
      玩家数据[id].角色:添加银子(10000000,"神树抽奖",1)
    elseif 获奖几率<=90 then
      if 玩家数据[id].角色.数据.参战信息~=nil then
        玩家数据[id].召唤兽:获得经验(玩家数据[id].角色.数据.参战宝宝.认证码,5000000,id,"神树抽奖")
      else
        常规提示(id,"#Y当前没有参战召唤兽，所以无法获得召唤兽经验。")
        return
      end
    elseif 获奖几率<=120 then
      local 名称=取宝石()
      self:给予道具(id,名称,取随机数(5,10))
      常规提示(id,"#Y你获得了#R"..名称)
      广播消息({内容=format("#S(神树抽奖)#R/%s#Y感动上苍，因此在#R%s#Y获得了其奖励的#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,"神树抽奖活动",名称),频道="xt"})
    elseif 获奖几率<=150 then
      local 名称="星辉石"
      self:给予道具(id,名称,取随机数(5,10))
      常规提示(id,"#Y你获得了#R"..名称)
      广播消息({内容=format("#S(神树抽奖)#R/%s#Y感动上苍，因此在#R%s#Y获得了其奖励的#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,"神树抽奖活动",名称),频道="xt"})
    elseif 获奖几率<=180 then
      local 名称="九转金丹"
      self:给予道具(id,名称,1,100)
      常规提示(id,"#Y你获得了#R"..名称)
      广播消息({内容=format("#S(神树抽奖)#R/%s#Y感动上苍，因此在#R%s#Y获得了其奖励的#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,"神树抽奖活动",名称),频道="xt"})
    elseif 获奖几率<=210 then
      local 物品名称="高级魔兽要诀"
      local 技能=取高级要诀()
      self:给予道具(id,物品名称,nil,技能)
      常规提示(id,"#Y你获得了#R"..物品名称)
      广播消息({内容=format("#S(神树抽奖)#R/%s#Y感动上苍，因此在#R%s#Y获得了其奖励的#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,"神树抽奖活动",物品名称),频道="xt"})
    elseif 获奖几率<=230 then
      local 名称="特赦令牌"
      self:给予道具(id,名称,1)
      常规提示(id,"#Y你获得了#R"..名称)
      广播消息({内容=format("#S(神树抽奖)#R/%s#Y感动上苍，因此在#R%s#Y获得了其奖励的#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,"神树抽奖活动",名称),频道="xt"})
    elseif 获奖几率<=280 then
      local 名称=取强化石()
      self:给予道具(id,名称,1)
      常规提示(id,"#Y你获得了#R"..名称)
      广播消息({内容=format("#S(神树抽奖)#R/%s#Y感动上苍，因此在#R%s#Y获得了其奖励的#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,"神树抽奖活动",名称),频道="xt"})
    elseif 获奖几率<=300 then
      local 名称="灵饰指南书"
      玩家数据[id].道具:给予道具(id,"灵饰指南书",{12,14})
      常规提示(id,"#Y/你获得了"..名称)
      广播消息({内容=format("#S(神树抽奖)#R/%s#Y感动上苍，因此在#R%s#Y获得了其奖励的#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,"神树抽奖活动",名称),频道="xt"})
    elseif 获奖几率<=320 then
      local 名称="元灵晶石"
      玩家数据[id].道具:给予道具(id,"元灵晶石",{12,14})
      常规提示(id,"#Y/你获得了"..名称)
      广播消息({内容=format("#S(神树抽奖)#R/%s#Y感动上苍，因此在#R%s#Y获得了其奖励的#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,"神树抽奖活动",名称),频道="xt"})
    elseif 获奖几率<=325 then
      礼包奖励类:随机装备(id,150)
      广播消息({内容=format("#S(神树抽奖)#R/%s#Y感动上苍，因此在#R%s#Y获得了其奖励的#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,"神树抽奖活动","150级随机装备一件"),频道="xt"})
    elseif 获奖几率<=330 then
      local 物品名称="高级魔兽要诀"
      local 技能=取特殊要诀1()
      self:给予道具(id,物品名称,nil,技能)
      常规提示(id,"#Y你获得了#R"..物品名称)
      广播消息({内容=format("#S(神树抽奖)#R/%s#Y感动上苍，因此在#R%s#Y获得了其奖励的#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,"神树抽奖活动",物品名称),频道="xt"})
    elseif 获奖几率<=360 then
      self:给予道具(id,"神兜兜",1)
      常规提示(id,"#Y/你获得了神兜兜")
      广播消息({内容=format("#S(神树抽奖)#R/%s#Y感动上苍，因此在#R%s#Y获得了其奖励的#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,"神树抽奖活动","神兜兜"),频道="xt"})
    elseif 获奖几率<=385 then
     礼包奖励类:随机装备(id,100,"无级别限制")
      常规提示(id,"#Y/你获得了100级无级别装备")
      广播消息({内容=format("#S(神树抽奖)#R/%s#Y感动上苍，因此在#R%s#Y获得了其奖励的#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,"神树抽奖活动","100级无级别装备"),频道="xt"})
    elseif 获奖几率<=413 then
      礼包奖励类:随机装备(id,120,"无级别限制")
      常规提示(id,"#Y/你获得了120级无级别装备")
      广播消息({内容=format("#S(神树抽奖)#R/%s#Y感动上苍，因此在#R%s#Y获得了其奖励的#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,"神树抽奖活动","120级无级别装备"),频道="xt"})
    elseif 获奖几率<=433 then
      礼包奖励类:随机装备(id,130,"无级别限制")
      常规提示(id,"#Y/你获得了130级无级别装备")
      广播消息({内容=format("#S(神树抽奖)#R/%s#Y感动上苍，因此在#R%s#Y获得了其奖励的#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,"神树抽奖活动","130级无级别装备"),频道="xt"})
    elseif 获奖几率<=448 then
      local 名称="魔兽残卷"
      玩家数据[id].道具:给予道具(id,名称,1)
      常规提示(id,"#Y/你获得了"..名称)
      广播消息({内容=format("#S(神树抽奖)#R/%s#Y感动上苍，因此在#R%s#Y获得了其奖励的#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,"神树抽奖活动","魔兽残卷"),频道="xt"})
    elseif 获奖几率<=463 then
      local 临时名称=self:给予书铁(id,{10,10})
      常规提示(id,"#Y/你获得了"..临时名称[1])
      广播消息({内容=format("#S(神树抽奖)#R/%s#Y感动上苍，因此在#R%s#Y获得了其奖励的100级#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,"神树抽奖活动",临时名称[1]),频道="xt"})
    elseif 获奖几率<=483 then
      local 临时名称=self:给予书铁(id,{12,12})
      常规提示(id,"#Y/你获得了"..临时名称[1])
      广播消息({内容=format("#S(神树抽奖)#R/%s#Y感动上苍，因此在#R%s#Y获得了其奖励的120级#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,"神树抽奖活动",临时名称[1]),频道="xt"})
    elseif 获奖几率<=508 then
      local 临时名称=self:给予书铁(id,{13,13})
      常规提示(id,"#Y/你获得了"..临时名称[1])
      广播消息({内容=format("#S(神树抽奖)#R/%s#Y感动上苍，因此在#R%s#Y获得了其奖励的130级#G/%s#Y".."#"..取随机数(1,110),玩家数据[id].角色.数据.名称,"神树抽奖活动",临时名称[1]),频道="xt"})
    end
  end
end

function 道具处理类:卸下孩子装备(连接id,id,数据)
  local 角色=数据.角色
  local 类型=数据.类型
  local 道具=数据.道具
  --local 道具id=玩家数据[id].角色.数据[类型][道具]
  local bb=数据.编号
  local 道具格子=玩家数据[id].角色:取道具格子()
  if 道具格子==0 then
    常规提示(id,"您的道具栏物品已经满啦")
    return
  else
    local 临时id=self:取新编号()
    self.数据[临时id]=玩家数据[id].孩子.数据[bb].装备[道具]
    玩家数据[id].孩子:卸下装备(玩家数据[id].孩子.数据[bb].装备[道具],道具,bb)
    玩家数据[id].角色.数据.道具[道具格子]=临时id
    玩家数据[id].孩子.数据[bb].装备[道具]=nil
    发送数据(玩家数据[id].连接id,96.2,{数据=玩家数据[id].孩子.数据[bb],编号=bb})
    发送数据(连接id,3699)
    道具刷新(id)
    发送数据(连接id,28)
  end
end

function 道具处理类:佩戴孩子装备(连接id,id,数据)
  local 角色=数据.角色
  local 类型=数据.类型
  local 道具=数据.道具
  local 道具id=玩家数据[id].角色.数据[类型][道具]
  local bb=数据.编号
  if self.数据[道具id].分类>6 and self:召唤兽可装备(self.数据[道具id],self.数据[道具id].分类-6,玩家数据[id].孩子.数据[bb].等级,id) then
    local 装备格子=self.数据[道具id].分类 - 6
    if 玩家数据[id].孩子.数据[bb].装备[装备格子] ~= nil then
     local 临时道具=玩家数据[id].孩子.数据[bb].装备[装备格子]
     玩家数据[id].孩子:卸下装备(玩家数据[id].孩子.数据[bb].装备[装备格子],装备格子,bb)
     玩家数据[id].孩子.数据[bb].装备[装备格子] =nil
     玩家数据[id].孩子:穿戴装备(self.数据[道具id],装备格子,bb)
     self.数据[道具id] = 临时道具
     玩家数据[id].角色.数据[类型][道具]=道具id
    else
     玩家数据[id].孩子:穿戴装备(self.数据[道具id],装备格子,bb)
     self.数据[道具id]=nil
     玩家数据[id].角色.数据[类型][道具]=nil
    end
    发送数据(连接id,3699)
    道具刷新(id)
    发送数据(玩家数据[id].连接id,96.2,{数据=玩家数据[id].孩子.数据[bb],编号=bb})
    发送数据(连接id,28)
  end
end

function 道具处理类:卸下bb装备(连接id,id,数据)
  local 角色=数据.角色
  local 类型=数据.类型
  local 道具=数据.道具
  --local 道具id=玩家数据[id].角色.数据[类型][道具]
  local bb=数据.编号
  local 道具格子=玩家数据[id].角色:取道具格子()
  if 道具格子==0 then
    常规提示(id,"您的道具栏物品已经满啦")
    return
  else
    local 临时id=self:取新编号()
    self.数据[临时id]=玩家数据[id].召唤兽.数据[bb].装备[道具]
    玩家数据[id].召唤兽:卸下装备(玩家数据[id].召唤兽.数据[bb].装备[道具],道具,bb)
    玩家数据[id].角色.数据.道具[道具格子]=临时id
    玩家数据[id].召唤兽.数据[bb].装备[道具]=nil
    发送数据(连接id,3699)
    道具刷新(id)
    发送数据(连接id,20,玩家数据[id].召唤兽:取存档数据(bb))
    发送数据(连接id,28)
  end
end

function 道具处理类:佩戴bb装备(连接id,id,数据)
  local 角色=数据.角色
  local 类型=数据.类型
  local 道具=数据.道具
  local 道具id=玩家数据[id].角色.数据[类型][道具]
  local bb=数据.编号
  if self.数据[道具id].分类>6 and self:召唤兽可装备(self.数据[道具id],self.数据[道具id].分类-6,玩家数据[id].召唤兽.数据[bb].等级,id) then
    local 装备格子=self.数据[道具id].分类 - 6
    if 玩家数据[id].召唤兽.数据[bb].装备[装备格子] ~= nil then
     local 临时道具=玩家数据[id].召唤兽.数据[bb].装备[装备格子]
     玩家数据[id].召唤兽:卸下装备(玩家数据[id].召唤兽.数据[bb].装备[装备格子],装备格子,bb)
     玩家数据[id].召唤兽.数据[bb].装备[装备格子] =nil
     玩家数据[id].召唤兽:穿戴装备(self.数据[道具id],装备格子,bb)
     self.数据[道具id] = 临时道具
     玩家数据[id].角色.数据[类型][道具]=道具id
    else
     玩家数据[id].召唤兽:穿戴装备(self.数据[道具id],装备格子,bb)
     self.数据[道具id]=nil
     玩家数据[id].角色.数据[类型][道具]=nil
    end
    发送数据(连接id,3699)
    道具刷新(id)
    发送数据(连接id,20,玩家数据[id].召唤兽:取存档数据(bb))
    发送数据(连接id,28)
  end
end

function 道具处理类:穿戴饰品(连接id,id,数据)
  local 角色=数据.角色
  local 类型=数据.类型
  local 道具=数据.道具
  local 道具id=玩家数据[id].角色.数据[类型][道具]
  local 坐骑=数据.编号
  if self.数据[道具id].总类=="坐骑饰品" and self.数据[道具id].子类==玩家数据[id].角色.数据.坐骑列表[坐骑].模型 then
    local 物品=取物品数据(self.数据[道具id].名称)
    if 玩家数据[id].角色.数据.坐骑列表[坐骑].饰品==nil then
      玩家数据[id].角色.数据.坐骑列表[坐骑].饰品=self.数据[道具id].名称
      玩家数据[id].角色.数据.坐骑列表[坐骑].饰品物件=self.数据[道具id]
      玩家数据[id].角色.数据.坐骑列表[坐骑].饰品id = 玩家数据[id].角色.数据[类型][道具]
      玩家数据[id].角色.数据[类型][道具]=nil
    else
      local 道具id1=玩家数据[id].角色.数据.坐骑列表[坐骑].饰品id
      玩家数据[id].角色.数据.坐骑列表[坐骑].饰品=self.数据[道具id].名称
      玩家数据[id].角色.数据.坐骑列表[坐骑].饰品物件=self.数据[道具id]
      玩家数据[id].角色.数据.坐骑列表[坐骑].饰品id = 玩家数据[id].角色.数据[类型][道具]
      玩家数据[id].角色.数据[类型][道具]=nil
      玩家数据[id].角色.数据[类型][道具]=道具id1
    end
    发送数据(玩家数据[id].连接id,60,玩家数据[id].角色.数据.坐骑)
    发送数据(玩家数据[id].连接id,61,玩家数据[id].角色.数据.坐骑列表)
    地图处理类:更新坐骑(id,玩家数据[id].角色.数据.坐骑)
    地图处理类:更新坐骑(id,玩家数据[id].角色.数据.坐骑列表)
    发送数据(连接id,3699)
    发送数据(连接id,3531)
    道具刷新(id)
  else
    常规提示(id,"#Y/该饰品不适合该坐骑哦")
  end
end

function 道具处理类:卸下饰品(连接id,id,数据)

  local 道具格子=玩家数据[id].角色:取道具格子()
  local 坐骑 = 数据.编号
  if 道具格子==0 then
    常规提示(id,"您的道具栏物品已经满啦")
    return
  else
    local 临时id=self:取新编号()
    self.数据[临时id]=玩家数据[id].角色.数据.坐骑列表[坐骑].饰品物件
    玩家数据[id].角色.数据.道具[道具格子]=临时id
    玩家数据[id].角色.数据.坐骑列表[坐骑].饰品=nil
    玩家数据[id].角色.数据.坐骑列表[坐骑].饰品物件=nil
    发送数据(玩家数据[id].连接id,60,玩家数据[id].角色.数据.坐骑)
    发送数据(玩家数据[id].连接id,61,玩家数据[id].角色.数据.坐骑列表)
    地图处理类:更新坐骑(id,玩家数据[id].角色.数据.坐骑)
    地图处理类:更新坐骑(id,玩家数据[id].角色.数据.坐骑列表)
    发送数据(连接id,3699)
    发送数据(连接id,3531)
    道具刷新(id)
  end
end

function 道具处理类:召唤兽可装备(i1,i2,等级,id)
  if i1 ~= nil and i1.分类 - 6 == i2 then
    if (i1.级别限制 == 0 or (i1.特效~=nil and i1.特效 == "无级别限制") or 等级 >= i1.级别限制) or 风雨无言定制 then
      return true
    else
      if i1.级别限制 > 等级 then
        常规提示(id,"#Y/你的召唤兽等级不足哦")
      end
    end
  end
  return false
end

function 道具处理类:取随机装备(id,等级,返回)
  -- print(id,等级,返回)
  local 临时格子=玩家数据[id].角色:取道具格子()
  if 临时格子==0 then 常规提示(id,"#Y/你身上的空间不够，无法获得装备") return end
  local 临时等级=等级
  --local 临时种类=取随机数(1,#书铁范围)
  local 临时参数=取随机数(1,#书铁范围)
  local 临时序列=临时参数
  if 临时序列==25 then
    临时序列=23
  elseif 临时序列==24 then
    临时序列=22
  elseif 临时序列==23 or 临时序列==22 then
    临时序列=21
  elseif 临时序列==21 then
    临时序列=20
  elseif 临时序列==20 or 临时序列==19 then
    临时序列=19
  end
  -- local 临时等级=玩家数据[id].道具.数据[制造格子].子类/10
  -- 计算武器值
  --   print(临时序列,玩家数据[id].道具.数据[制造格子].子类,制造格子)
  if 临时序列<=18 and 临时等级>=9 then --是武器 10-12是普通光武
    临时等级=取随机数(10,12)
  else
    if 临时等级>=12 then
      临时等级=10
    end
  end
  local 临时类型=玩家数据[id].装备.打造物品[临时序列][临时等级+1]
  if type(临时类型)=="table" then
    if 临时参数 ==23 then
     临时类型=临时类型[2]
    elseif 临时参数 ==22 then
     临时类型=临时类型[1]
    elseif 临时参数 ==20 then
     临时类型=临时类型[2]
    elseif 临时参数 ==19 then
     临时类型=临时类型[1]
    else
      临时类型=临时类型[取随机数(1,2)]
    end
  end
  local 道具 = 物品类()
  道具:置对象(临时类型)
  道具.级别限制 = 临时等级
  local dz = 玩家数据[id].装备:打造公式(临时等级*10,临时序列)
  if dz[1] ~= nil then
    道具.命中 = dz[1]
  end
  if dz[2] ~= nil then
    道具.伤害 = dz[2]
  end
  if dz[3] ~= nil then
    道具.防御 = dz[3]
  end
  if dz[4] ~= nil then
    道具.魔法 = dz[4]
  end
  if dz[5] ~= nil then
    道具.灵力 = dz[5]
  end
  if dz[6] ~= nil then
    道具.气血 = dz[6]
  end
  if dz[7] ~= nil then
    道具.敏捷 = dz[7]
  end
  if dz[8] ~= nil then
    道具.体质 = dz[8]
  end
  if dz[9] ~= nil then
    道具.力量 = dz[9]
  end
  if dz[10] ~= nil then
    道具.耐力 = dz[10]
  end
  if dz[11] ~= nil then
    道具.魔力 = dz[11]
  end
  if dz[12] ~= nil then
    local 通用特效 = {"无级别限制","神佑","珍宝","必中","神农","简易","绝杀","专注","精致","再生"}
    if 道具.分类 == 5 then
      table.insert(通用特效,"愤怒")
      table.insert(通用特效,"暴怒")
    end
    道具.特效 = 通用特效[取随机数(1,#通用特效)]
    if 取随机数() <= 10 then
      道具.第二特效 = 通用特效[取随机数(1,#通用特效)]
    end
  end
  if dz[13] ~= nil then
    local 通用特技 = {"气疗术","心疗术","命疗术","凝气诀","凝神诀","气归术","命归术","四海升平","回魂咒","起死回生","水清诀","冰清诀","玉清诀","晶清诀","弱点击破","冥王爆杀","放下屠刀","河东狮吼","碎甲术","破甲术","破血狂攻"}
    道具.特技 = 通用特技[取随机数(1,#通用特技)]
  end
  local 道具id=self:取新编号()
  self.数据[道具id]=道具
  self.数据[道具id].级别限制=等级*10
  self.数据[道具id].鉴定=false
  if self.数据[道具id].级别限制<40 then self.数据[道具id].鉴定=true end
  self.数据[道具id].五行=取五行()
  self.数据[道具id].耐久=500
  self.数据[道具id].开运孔数 = {当前=0,上限=0}
  if 等级<=40 then
    self.数据[道具id].开运孔数 = {当前=0,上限=2}
  elseif 等级>40 and 等级<=80 then
    self.数据[道具id].开运孔数 = {当前=0,上限=3}
  elseif 等级>40 and 等级<=80 then
    self.数据[道具id].开运孔数 = {当前=0,上限=3}
  elseif 等级>80 and 等级<=120 then
    self.数据[道具id].开运孔数 = {当前=0,上限=4}
  elseif 等级>120 and 等级<=160 then
    self.数据[道具id].开运孔数 = {当前=0,上限=5}
  elseif 等级>160 and 等级<=180 then
    self.数据[道具id].开运孔数 = {当前=0,上限=6}
  end
  self.数据[道具id].符石={}
  self.数据[道具id].星位={}
  self.数据[道具id].符石组合 = {符石组合 = {},门派条件 ={},部位条件={},效果说明={}}
  self.数据[道具id].熔炼效果={}
  玩家数据[id].角色.数据.道具[临时格子]=道具id
  if 返回 then
    return self.数据[道具id].名称
  else
    发送数据(玩家数据[id].连接id,38,{内容="你得到了#R/"..self.数据[道具id].名称})
  end
  发送数据(玩家数据[id].连接id,3699)
  道具刷新(id)
end

function 道具处理类:取随机装备1(id,等级,名称)
  local 临时格子=玩家数据[id].角色:取道具格子()
  if 临时格子==0 then return end
  local 道具 = 物品类()
  道具:置对象(名称)
  道具.级别限制 = 等级*10
  local 道具id=self:取新编号()
  self.数据[道具id]=道具
  self.数据[道具id].级别限制=等级*10
  self.数据[道具id].鉴定=false
  self.数据[道具id].五行=取五行()
  self.数据[道具id].开运孔数 = {当前=0,上限=0}
  if 等级<=40 then
    self.数据[道具id].开运孔数 = {当前=0,上限=2}
  elseif 等级>40 and 等级<=80 then
    self.数据[道具id].开运孔数 = {当前=0,上限=3}
  elseif 等级>40 and 等级<=80 then
    self.数据[道具id].开运孔数 = {当前=0,上限=3}
  elseif 等级>80 and 等级<=120 then
    self.数据[道具id].开运孔数 = {当前=0,上限=4}
  elseif 等级>120 and 等级<=160 then
    self.数据[道具id].开运孔数 = {当前=0,上限=5}
  elseif 等级>160 and 等级<=180 then
    self.数据[道具id].开运孔数 = {当前=0,上限=6}
  end
  self.数据[道具id].符石={}
  self.数据[道具id].星位={}
  self.数据[道具id].符石组合 = {符石组合 = {},门派条件 ={},部位条件={},效果说明={}}
  self.数据[道具id].熔炼效果={}
  玩家数据[id].角色.数据.道具[临时格子]=道具id
end

function 道具处理类:给予书铁(id,等级,类型)
  if 类型==nil then  --随机获取
    self.临时随机=取随机数()
    --   print(self.临时随机,11)
    if self.临时随机<=50 then
      self.书铁名称="制造指南书"
    else
      self.书铁名称="百炼精铁"
    end
    local 书铁等级=取随机数(等级[1]*10,等级[2]*10)
    local 书铁种类=取随机数(1,#书铁范围)
    书铁等级=math.floor(书铁等级/10)*10
    self:给予道具(id,self.书铁名称,书铁等级,书铁种类)
    return {self.书铁名称,书铁等级,书铁种类}
  elseif 类型=="指南书" then
    self.书铁名称="制造指南书"
    local 书铁等级=取随机数(等级[1]*10,等级[2]*10)
    local 书铁种类=取随机数(1,#书铁范围)
    书铁等级=math.floor(书铁等级/10)*10
    self:给予道具(id,self.书铁名称,书铁等级,书铁种类)
    return {self.书铁名称,书铁等级,书铁种类}
  elseif 类型=="精铁" then
    self.书铁名称="百炼精铁"
    local 书铁等级=取随机数(等级[1]*10,等级[2]*10)
    local 书铁种类=取随机数(1,#书铁范围)
    书铁等级=math.floor(书铁等级/10)*10
    self:给予道具(id,self.书铁名称,书铁等级,书铁种类)
    return {self.书铁名称,书铁等级,书铁种类}
  end
end

function 道具处理类:取武器子类(子类)
  local n = {"枪矛","斧钺","剑","双短剑","飘带","爪刺","扇","魔棒","锤","鞭","环圈","刀","法杖","弓弩","宝珠","巨剑","伞","灯笼","头盔","发钗","项链","女衣","男衣","腰带","鞋子"}
  return n[子类]
end

function 道具处理类:取武器类型(子类)
  local n = {"枪矛","斧钺","剑","双短剑","飘带","爪刺","扇","魔棒","锤","鞭","环圈","刀","法杖","弓弩","宝珠","巨剑","伞","灯笼","头盔","发钗","项链","女衣","男衣","腰带","鞋子"}
  for i=1,#n do
    if n[i]==子类 then
        return i
    end
  end
end

function 道具处理类:飞行符传送(连接id,id,内容)
  local 传送序列=内容.序列
  if self:取飞行限制(id)==false then
    local 包裹类型=玩家数据[id].道具操作.类型
    local 道具格子=玩家数据[id].道具操作.编号
    local 道具id=玩家数据[id].角色.数据[包裹类型][道具格子]
    地图处理类:跳转地图(id,self.飞行传送点[传送序列][1],self.飞行传送点[传送序列][2],self.飞行传送点[传送序列][3])
    self:删除道具(连接id,id,包裹类型,道具id,道具格子,删除数量)
    发送数据(连接id,3699)
    道具刷新(id)
  end
end

function 道具处理类:取加血道具(名称)
  local 临时名称={"包子","烤鸭","翡翠豆腐","烤肉","臭豆腐","金创药","小还丹","千年保心丹","金香玉","包子","天不老","紫石英","血色茶花","熊胆","鹿茸","六道轮回","凤凰尾","硫磺草","龙之心屑","火凤之睛","四叶花","天青地白","七叶莲"}
  for n=1,#临时名称 do
    if 临时名称[n]==名称 then
      return true
    end
  end
  return false
end

function 道具处理类:取寿命道具(名称)
  local 临时名称={"桂花丸","长寿面","豆斋果"}
  for n=1,#临时名称 do
    if 临时名称[n]==名称 then
      return true
    end
  end
  return false
end

function 道具处理类:取寿命道具1(名称,道具id)
  local 品质=self.数据[道具id].阶品
  local 数值=0
  local 中毒=0
  if 名称=="桂花丸" then
    数值=品质*0.5
  elseif 名称=="豆斋果" then
    数值=品质*3
    中毒=3
  elseif 名称=="长寿面" then
    数值=品质*2+50
    中毒=3
  end
  return {数值=qz(数值),中毒=中毒}
end

function 道具处理类:取加魔道具(名称)
  local 临时名称={"翡翠豆腐","佛跳墙","蛇蝎美人","风水混元丹","定神香","十香返生丸","丁香水","月星子","仙狐涎","地狱灵芝","麝香","血珊瑚","餐风饮露","白露为霜","天龙水","孔雀红","紫丹罗","佛手","旋复花","龙须草","百色花","香叶","白玉骨头","鬼切草","灵脂","曼陀罗花"}
  for n=1,#临时名称 do
    if 临时名称[n]==名称 then
      return true
    end
  end
  return false
end

function 道具处理类:取加血道具1(名称,道具id)
  local 品质=self.数据[道具id].阶品
  local 数值=0
  if 名称=="包子" then
   数值=100
  elseif 名称=="烤鸭" then
   数值=品质*10+100
  elseif 名称=="烤肉" then
   数值=品质*10
  elseif 名称=="臭豆腐" then
   数值=品质*20+200
  elseif 名称=="翡翠豆腐" then
   数值=品质*15+150
  elseif 名称=="金创药" then
   数值=400
  elseif 名称=="小还丹" then
   数值=品质*8+100
  elseif 名称=="金香玉" then
   数值=品质*12+150
  elseif 名称=="千年保心丹" then
   数值=品质*4+200
  elseif 名称=="五龙丹" then
   数值=品质*3
  elseif 名称=="佛光舍利子" then
   数值=品质*3
  elseif 名称=="九转回魂丹" then
   数值=品质*5+100
  elseif 名称=="天不老" or 名称=="紫石英" then
   数值=100
  elseif 名称=="血色茶花" or 名称=="鹿茸" then
   数值= 150
  elseif 名称=="六道轮回" or 名称=="熊胆" then
   数值= 200
  elseif 名称=="凤凰尾" or 名称=="硫磺草" then
   数值= 250
  elseif 名称=="龙之心屑" or 名称=="火凤之睛" then
   数值= 300
  elseif 名称=="四叶花" then
   数值= 40
  elseif 名称=="天青地白" then
   数值= 80
  elseif 名称=="七叶莲" then
   数值= 60
  end
  return qz(数值)
end

function 道具处理类:取加魔道具1(名称,道具id)
  local 品质=self.数据[道具id].阶品
  local 数值=0
  if 名称=="佛跳墙" or 名称=="翡翠豆腐" then
   数值=品质*10+100
  elseif 名称=="定神香"  then
   数值=品质*5+50
  elseif 名称=="风水混元丹"  then
   数值=品质*3+50
  elseif 名称=="蛇蝎美人"  then
   数值=品质*5+100
  elseif 名称=="十香返生丸"  then
   数值=品质*3+50
  elseif 名称=="女儿红" or 名称=="虎骨酒"  then
   数值=20
  elseif 名称=="珍露酒"  then
   数值=品质*0.4+10
  elseif 名称=="梅花酒"  then
   数值=品质*0.6
  elseif 名称=="百味酒"  then
   数值=品质*0.7
  elseif 名称=="蛇胆酒"  then
   数值=品质*1
  elseif 名称=="醉生梦死"  then
   数值=品质*1
  elseif 名称=="丁香水" or 名称=="月星子"  then
   数值=75
  elseif 名称=="仙狐涎" or 名称=="地狱灵芝" or 名称=="麝香" or 名称=="血珊瑚" or 名称=="餐风饮露" or 名称=="白露为霜"  then
   数值=100
  elseif 名称=="天龙水" or 名称=="孔雀红"  then
   数值=150
  elseif 名称=="紫丹罗" or 名称=="佛手" or 名称=="旋复花"     then
   数值=20
  elseif 名称=="龙须草" or 名称=="百色花" or 名称=="香叶"  then
   数值=30
  elseif 名称=="白玉骨头" or 名称=="鬼切草" or 名称=="灵脂"  then
   数值=40
  elseif 名称=="曼陀罗花"  then
   数值=50
  end
  return qz(数值)
end

function 道具处理类:清空包裹(连接id,id)
  for n=1,20 do
    if 玩家数据[id].角色.数据.道具[n]~=nil then
      self.数据[玩家数据[id].角色.数据.道具[n]]=nil
      玩家数据[id].角色.数据.道具[n]=nil
    end
  end
  发送数据(连接id,3699)
  道具刷新(id)
end

function 道具处理类:佩戴法宝(连接id,id,类型,编号)
  if 玩家数据[id].角色.数据.法宝[编号] == nil then
    self:索要法宝(连接id,id)
    return
  end
  local 道具id=玩家数据[id].角色.数据.法宝[编号]
  if 道具id == nil or self.数据[道具id] == nil then
    self:索要法宝(连接id,id)
    return
  end
  if 玩家数据[id].角色.数据.等级<self.数据[道具id].特技 then
    常规提示(id,"#Y你当前的等级无法佩戴此类型的法宝")
    return
  end
  local 名称=self.数据[道具id].名称
  local 门派=玩家数据[id].角色.数据.门派
  if 名称=="天师符" and 门派~="方寸山" then
    常规提示(id,"#Y你的门派不允许你使用这样的法宝")
    return
  elseif 名称=="织女扇" and 门派~="女儿村" then
   常规提示(id,"#Y你的门派不允许你使用这样的法宝")
   return
  elseif 名称=="雷兽" and 门派~="天宫" then
   常规提示(id,"#Y你的门派不允许你使用这样的法宝")
   return
  elseif 名称=="定风珠" and 门派~="五庄观" then
   常规提示(id,"#Y你的门派不允许你使用这样的法宝")
   return
  elseif 名称=="七杀" and 门派~="大唐官府" then
   常规提示(id,"#Y你的门派不允许你使用这样的法宝")
   return
  elseif 名称=="罗汉珠" and 门派~="化生寺" then
   常规提示(id,"#Y你的门派不允许你使用这样的法宝")
   return
  elseif 名称=="天师符" and 门派~="方寸山" then
   常规提示(id,"#Y你的门派不允许你使用这样的法宝")
   return
  elseif 名称=="金刚杵" and 门派~="普陀山" then
   常规提示(id,"#Y你的门派不允许你使用这样的法宝")
   return
  elseif 名称=="兽王令" and 门派~="狮驼岭" then
   常规提示(id,"#Y你的门派不允许你使用这样的法宝")
   return
  elseif 名称=="摄魂" and 门派~="阴曹地府" then
   常规提示(id,"#Y你的门派不允许你使用这样的法宝")
   return
  elseif 名称=="干将莫邪" and 门派~="大唐官府" then
   常规提示(id,"#Y你的门派不允许你使用这样的法宝")
   return
  elseif 名称=="慈悲" and 门派~="化生寺" then
   常规提示(id,"#Y你的门派不允许你使用这样的法宝")
   return
  elseif 名称=="救命毫米" and 门派~="方寸山" then
   常规提示(id,"#Y你的门派不允许你使用这样的法宝")
   return
  elseif 名称=="伏魔天书" and 门派~="天宫" then
   常规提示(id,"#Y你的门派不允许你使用这样的法宝")
   return
  elseif 名称=="普渡" and 门派~="普陀山" then
   常规提示(id,"#Y你的门派不允许你使用这样的法宝")
   return
  elseif 名称=="镇海珠" and 门派~="龙宫" then
   常规提示(id,"#Y你的门派不允许你使用这样的法宝")
   return
  elseif 名称=="奇门五行令" and 门派~="五庄观" then
   常规提示(id,"#Y你的门派不允许你使用这样的法宝")
   return
  elseif 名称=="失心钹" and 门派~="狮驼岭" then
   常规提示(id,"#Y你的门派不允许你使用这样的法宝")
   return
  elseif 名称=="五火神焰印" and 门派~="魔王寨" then
   常规提示(id,"#Y你的门派不允许你使用这样的法宝")
   return
  elseif 名称=="九幽" and 门派~="阴曹地府" then
   常规提示(id,"#Y你的门派不允许你使用这样的法宝")
   return
  elseif 名称=="月影" and 门派~="神木林" then
   常规提示(id,"#Y你的门派不允许你使用这样的法宝")
   return
  end
  for n=1,3 do
    if 玩家数据[id].角色.数据.法宝佩戴[n] ~= nil then
      if 玩家数据[id].道具.数据[玩家数据[id].角色.数据.法宝佩戴[n]].名称 == 名称 and self.数据[道具id].特技>=100 then
        常规提示(id,"#Y此类型法宝只能同时佩戴一件")
        return
      end
    end
  end
  玩家数据[id].角色.数据.法宝[编号]=nil
  local 佩戴格子=0
  for n=1,3 do
    if 玩家数据[id].角色.数据.法宝佩戴[n]==nil then 佩戴格子=n end
  end
  if 佩戴格子==0 then
    玩家数据[id].角色.数据.法宝[编号]=玩家数据[id].角色.数据.法宝佩戴[3]
    佩戴格子=3
  end
  玩家数据[id].角色.数据.法宝佩戴[佩戴格子]=道具id
  self:索要法宝(连接id,id)
end

function 道具处理类:使用道具(连接id,id,内容)
  local 包裹类型=内容.类型
  local 道具格子=内容.编号
  local 删除数量=1
  local 加血对象=0
  if 内容.窗口=="召唤兽" then
    if 玩家数据[id].召唤兽.数据[内容.序列]==nil then
      常规提示(id,"该召唤兽不存在")
      return
    else
      加血对象=内容.序列
    end
  end
  if 包裹类型~="道具" then
    if 包裹类型=="法宝" then
      self:佩戴法宝(连接id,id,包裹类型,道具格子)
      return
    end
    常规提示(id,"只有道具栏的物品才可以使用")
    return
  elseif 道具格子==nil then
    return
  end
  local 道具id=玩家数据[id].角色.数据[包裹类型][道具格子]
  if 道具id==nil or self.数据[道具id]==nil then
    玩家数据[id].道具[道具格子]=nil
    发送数据(连接id,3699)
    道具刷新(id)
    return
  end
  local 名称=self.数据[道具id].名称
  local 道具使用=false
  if self:取加血道具(名称) then
    if 加血对象==0 and 玩家数据[id].角色.数据.气血>=玩家数据[id].角色.数据.最大气血  then
     常规提示(id,"您的气血已满，无法使用该物品")
     return
    elseif 加血对象~=0 and 玩家数据[id].召唤兽.数据[加血对象].气血>=玩家数据[id].召唤兽.数据[加血对象].最大气血 then
      常规提示(id,"您的这只召唤兽气血已满，无法使用该物品")
      return
    end
    道具使用=true
    local 加血数值=self:取加血道具1(名称,道具id)
    local 加魔数值=self:取加魔道具1(名称,道具id)
    if 名称=="翡翠豆腐" then
      self:加血处理(连接id,id,加血数值,加血对象)
      self:加魔处理(连接id,id,加魔数值,加血对象)
    else
      self:加血处理(连接id,id,加血数值,加血对象)
    end
  elseif self:取加魔道具(名称) then
    if 加血对象==0 and 玩家数据[id].角色.数据.魔法>=玩家数据[id].角色.数据.最大魔法  then
     常规提示(id,"您的魔法已满，无法使用该物品")
     return
    elseif 加血对象~=0 and 玩家数据[id].召唤兽.数据[加血对象].魔法>=玩家数据[id].召唤兽.数据[加血对象].最大魔法 then
      常规提示(id,"您的这只召唤兽魔法已满，无法使用该物品")
      return
    end
    道具使用=true
    local 加血数值=self:取加血道具1(名称,道具id)
    local 加魔数值=self:取加魔道具1(名称,道具id)
    if 名称=="翡翠豆腐" then
      self:加血处理(连接id,id,加血数值,加血对象)
      self:加魔处理(连接id,id,加魔数值,加血对象)
    else
      self:加魔处理(连接id,id,加魔数值,加血对象)
    end
  elseif self:取寿命道具(名称) then
    if 加血对象==0 then
      常规提示(id,"该物品只能对召唤兽使用")
      return
    elseif 玩家数据[id].召唤兽.数据[加血对象].神兽 then
      常规提示(id,"神兽无法使用此物品")
      return
    else
      local 加血数值=self:取寿命道具1(名称,道具id)
      玩家数据[id].召唤兽:加寿命处理(加血对象,加血数值.数值,加血数值.中毒,连接id,id)
      道具使用=true
    end
  elseif 名称=="鬼谷子" then  --
    if 玩家数据[id].角色.数据.阵法[self.数据[道具id].子类]==nil then
     玩家数据[id].角色.数据.阵法[self.数据[道具id].子类]=1
     常规提示(id,"恭喜你学会了如何使用#R/"..self.数据[道具id].子类)
     道具使用=true
    else
     常规提示(id,"你已经学过如何使用这个阵型了，请勿重复学习")
     return
    end
  elseif self.数据[道具id].总类==11 and self.数据[道具id].分类==2 then  --合成旗
    发送数据(玩家数据[id].连接id,3529,{地图=self.数据[道具id].地图,xy=self.数据[道具id].xy})
    玩家数据[id].道具操作={类型=包裹类型,编号=内容.编号,id=道具id}
    玩家数据[id].最后操作="合成旗"
    return
  elseif 名称=="摄妖香" then  --
    if 玩家数据[id].角色:取任务(9)~=0 then
      玩家数据[id].角色:取消任务(玩家数据[id].角色:取任务(9))
    end
    任务处理类:添加摄妖香(id)
    常规提示(id,"#Y/你使用了摄妖香")
    道具使用=true
  elseif 名称=="一倍经验丹" then
    if 玩家数据[id].角色:取任务(7756)~=0 then
      玩家数据[id].角色:取消任务(玩家数据[id].角色:取任务(7756))
    end
    任务处理类:添加一倍经验(id)
    常规提示(id,"#Y/你使用了一倍经验丹")
    道具使用=true
  elseif 名称=="双倍经验丹" then
    if 玩家数据[id].角色:取任务(7755)~=0 then
      玩家数据[id].角色:取消任务(玩家数据[id].角色:取任务(7755))
    end
    任务处理类:添加双倍经验(id)
    常规提示(id,"#Y/你使用了双倍经验丹")
    道具使用=true
  elseif 名称=="洞冥草" then
    if 玩家数据[id].角色:取任务(9)~=0 then
      玩家数据[id].角色:取消任务(玩家数据[id].角色:取任务(9))
      常规提示(id,"#Y/你解除了摄妖香的效果")
      道具使用=true
    end
  elseif 名称=="三界悬赏令" then
    if 玩家数据[id].角色:取任务(209)~=0 then
      常规提示(id,"#Y/你已经有个悬赏任务在进行了")
    else
      任务处理类:添加三界悬赏任务(id)
      常规提示(id,"#Y/你获得了三界悬赏任务")
      道具使用=true
    end
  elseif 名称=="贼王的线索" then
    if 玩家数据[id].角色:取任务(350)~=0 then
      常规提示(id,"#Y/你已经有个贼王任务在进行了")
    else
      任务处理类:添加贼王的线索任务(id)
      常规提示(id,"#Y/你获得了贼王的线索任务")
      道具使用=true
    end
  elseif 名称=="摇钱树苗" then
    if 玩家数据[id].角色:取任务(22)~=0 then
      常规提示(id,"#Y/你之前已经种下一棵摇钱树苗了")
    elseif 地图处理类.遇怪地图[玩家数据[id].角色.数据.地图数据.编号]==nil then
      常规提示(id,"#Y/本场景无法种植树苗")
    else
      local x=玩家数据[id].角色.数据.地图数据.x
      local y=玩家数据[id].角色.数据.地图数据.y
      local 通过=true
      for n, v in pairs(任务数据) do
        if 任务数据[n].类型==22 then
          if 取两点距离({x=任务数据[n].x,y=任务数据[n].y},{x=x,y=y})<=200 then
            通过=false
          end
        end
      end
      if 通过==false then
        常规提示(id,"#Y/这个区域已经有一颗摇钱树了，请换个地方再试试")
      else
        任务处理类:添加摇钱树任务(id)
        常规提示(id,"#Y/你种下了一颗摇钱树")
        道具使用=true
      end
    end
  elseif 名称=="仙玉锦囊" then
    添加仙玉(取随机数(1,500),玩家数据[id].账号,id,"使用仙玉锦囊")
    道具使用=true
  elseif 名称=="秘制红罗羹" then
    if 玩家数据[id].角色:取任务(10)~=0 then
      --玩家数据[id].角色:取消任务(玩家数据[id].角色:取任务(9))
      local 任务id=玩家数据[id].角色:取任务(10)
      任务数据[任务id].气血=任务数据[任务id].气血+100000
      常规提示(id,"#Y/你使用了秘制红罗羹")
      道具使用=true
      玩家数据[id].角色:刷新任务跟踪()
    else
      任务处理类:添加罗羹(id,100000,0)
      常规提示(id,"#Y/你使用了秘制红罗羹")
      道具使用=true
    end
 elseif 名称=="秘制绿罗羹" then  --
    if 玩家数据[id].角色:取任务(10)~=0 then
      --玩家数据[id].角色:取消任务(玩家数据[id].角色:取任务(9))
      local 任务id=玩家数据[id].角色:取任务(10)
      任务数据[任务id].魔法=任务数据[任务id].魔法+50000
      常规提示(id,"#Y/你使用了秘制绿罗羹")
      道具使用=true
      玩家数据[id].角色:刷新任务跟踪()
    else
      任务处理类:添加罗羹(id,0,50000)
      常规提示(id,"#Y/你使用了秘制绿罗羹")
      道具使用=true
    end
  elseif 名称=="白色导标旗" or 名称=="黄色导标旗" or 名称=="蓝色导标旗" or 名称=="绿色导标旗" or 名称=="红色导标旗"  then
    if self.数据[道具id].地图==nil then --定标
      local 地图=玩家数据[id].角色.数据.地图数据.编号
      if 地图~=1001 and 地图~=1070 and 地图~=1208 and 地图~=1092 then
        常规提示(id,"只有长安城、长寿村、傲来国、朱紫国这四个城市才可以定标哟！")
        return
      end
      local 等级=玩家数据[id].角色:取剧情技能等级("奇门遁甲")
      if 地图==1070 and 等级<1 then
        常规提示(id,"本场景定标需要您的奇门遁甲技能等级达到1级")
        return
      elseif 地图==1092 and 等级<2 then
        常规提示(id,"本场景定标需要您的奇门遁甲技能等级达到2级")
        return
      elseif 地图==1001 and 等级<1 then
        常规提示(id,"本场景定标需要您的奇门遁甲技能等级达到3级")
        return
      elseif 地图==1208 and 等级<2 then
        常规提示(id,"本场景定标需要您的奇门遁甲技能等级达到4级")
        return
      end
      self.数据[道具id].地图=玩家数据[id].角色.数据.地图数据.编号
      self.数据[道具id].x=math.floor(玩家数据[id].角色.数据.地图数据.x/20)
      self.数据[道具id].y=math.floor(玩家数据[id].角色.数据.地图数据.y/20)
      self.数据[道具id].次数=20
      发送数据(玩家数据[id].连接id,3699)
      道具刷新(id)
      常规提示(id,"定标成功！")
      return
    else
      发送数据(玩家数据[id].连接id,1501,{选项={"请送我过去","我再想想"},对话=format("请确认是否要传送至#G/%s(%s,%s)#W/处",取地图名称(self.数据[道具id].地图),self.数据[道具id].x,self.数据[道具id].y)})
      玩家数据[id].道具操作={类型=包裹类型,编号=内容.编号,id=道具id}
      玩家数据[id].最后操作="导标旗"
      return
    end
  elseif 名称=="逍遥镜" then
    if self.数据[道具id].绑定孩子 == nil then
      if #玩家数据[id].孩子.数据 == 0 then
        常规提示(id,"你没有可以带出的孩子！")
        return
      else
        local 选项 = {}
        for i=1,#玩家数据[id].孩子.数据 do
          选项[#选项+1] = 玩家数据[id].孩子.数据[i].名称
        end
        选项[#选项+1] = "我再想想"
        发送数据(玩家数据[id].连接id,1501,{选项=选项,对话="请选择你要带出的孩子"})
        玩家数据[id].携带孩子 = {道具id=道具id}
      end
    else
      常规提示(id,"你要带"..self.数据[道具id].绑定孩子.名称.."我去哪里呀")
    end
    return
  elseif 名称=="飞行符" then
    if self:取飞行限制(id)==false then
      玩家数据[id].道具操作={类型=包裹类型,编号=内容.编号,id=道具id}
      玩家数据[id].最后操作="飞行符"
      发送数据(连接id,13)
      return
    end
  elseif 名称=="神兵图鉴" or 名称=="灵宝图鉴" then
    玩家数据[id].道具操作={类型=包裹类型,编号=内容.编号,id=道具id,道具=玩家数据[id].道具:索要道具1(id)}
    发送数据(连接id,64,玩家数据[id].道具操作)
    return
  elseif 名称=="附魔宝珠" then
    玩家数据[id].道具操作={类型=包裹类型,编号=内容.编号,id=道具id,道具=玩家数据[id].道具:索要道具1(id)}
    发送数据(连接id,84,玩家数据[id].道具操作)
    return
  elseif 名称=="碎星锤" or 名称 == "超级碎星锤" then
    玩家数据[id].道具操作={类型=包裹类型,编号=内容.编号,id=道具id,道具=玩家数据[id].道具:索要道具1(id)}
    发送数据(连接id,84.1,玩家数据[id].道具操作)
    return
  elseif 名称=="灵箓" then
    玩家数据[id].道具操作={类型=包裹类型,编号=内容.编号,id=道具id,道具=玩家数据[id].道具:索要道具1(id)}
    发送数据(连接id,84.2,玩家数据[id].道具操作)
    return
  elseif 名称=="90级装备礼包" then
    local 道具格子=玩家数据[id].角色:取道具格子2()
    if 道具格子<6 then
      常规提示(id,"您的道具栏物品已经满啦")
      return 0
    end
    玩家数据[id].角色:购买装备礼包(90,id)
    self.临时id = 玩家数据[id].角色.数据.道具[内容.编号]
    玩家数据[id].角色.数据.道具[内容.编号]=nil
    玩家数据[id].道具.数据[self.临时id] = nil
    道具刷新(id)
    return
  elseif 名称=="100级装备礼包" then
    local 道具格子=玩家数据[id].角色:取道具格子2()
    if 道具格子<=5 then
      常规提示(id,"您的道具栏物品已经满啦")
      return 0
    end
    玩家数据[id].角色:购买装备礼包(100,id)
    self.临时id = 玩家数据[id].角色.数据.道具[内容.编号]
    玩家数据[id].角色.数据.道具[内容.编号]=nil
    玩家数据[id].道具.数据[self.临时id] = nil
    道具刷新(id)
    return
  elseif 名称=="110级装备礼包" then
    local 道具格子=玩家数据[id].角色:取道具格子2()
    if 道具格子<=5 then
      常规提示(id,"您的道具栏物品已经满啦")
      return 0
    end
    玩家数据[id].角色:购买装备礼包(110,id)
    self.临时id = 玩家数据[id].角色.数据.道具[内容.编号]
    玩家数据[id].角色.数据.道具[内容.编号]=nil
    玩家数据[id].道具.数据[self.临时id] = nil
    道具刷新(id)
    return
  elseif 名称=="120级装备礼包" then
    local 道具格子=玩家数据[id].角色:取道具格子2()
    if 道具格子<=5 then
      常规提示(id,"您的道具栏物品已经满啦")
      return 0
    end
    玩家数据[id].角色:购买装备礼包(120,id)
    self.临时id = 玩家数据[id].角色.数据.道具[内容.编号]
    玩家数据[id].角色.数据.道具[内容.编号]=nil
    玩家数据[id].道具.数据[self.临时id] = nil
    道具刷新(id)
    return
  elseif 名称=="130级装备礼包" then
    local 道具格子=玩家数据[id].角色:取道具格子2()
    if 道具格子<=5 then
      常规提示(id,"您的道具栏物品已经满啦")
      return 0
    end
    玩家数据[id].角色:购买装备礼包(130,id)
    self.临时id = 玩家数据[id].角色.数据.道具[内容.编号]
    玩家数据[id].角色.数据.道具[内容.编号]=nil
    玩家数据[id].道具.数据[self.临时id] = nil
    道具刷新(id)
    return
  elseif 名称=="140级装备礼包" then
    local 道具格子=玩家数据[id].角色:取道具格子2()
    if 道具格子<=5 then
      常规提示(id,"您的道具栏物品已经满啦")
      return 0
    end
    玩家数据[id].角色:购买装备礼包(140,id)
    self.临时id = 玩家数据[id].角色.数据.道具[内容.编号]
    玩家数据[id].角色.数据.道具[内容.编号]=nil
    玩家数据[id].道具.数据[self.临时id] = nil
    道具刷新(id)
    return
  elseif 名称=="150级装备礼包" then
    local 道具格子=玩家数据[id].角色:取道具格子2()
    if 道具格子<=5 then
      常规提示(id,"您的道具栏物品已经满啦")
      return 0
    end
    玩家数据[id].角色:购买装备礼包(150,id)
    self.临时id = 玩家数据[id].角色.数据.道具[内容.编号]
    玩家数据[id].角色.数据.道具[内容.编号]=nil
    玩家数据[id].道具.数据[self.临时id] = nil
    道具刷新(id)
    return
  elseif 名称=="160级装备礼包" then
    local 道具格子=玩家数据[id].角色:取道具格子2()
    if 道具格子<=5 then
      常规提示(id,"您的道具栏物品已经满啦")
      return 0
    end
    玩家数据[id].角色:购买装备礼包(160,id)
    self.临时id = 玩家数据[id].角色.数据.道具[内容.编号]
    玩家数据[id].角色.数据.道具[内容.编号]=nil
    玩家数据[id].道具.数据[self.临时id] = nil
    道具刷新(id)
    return
  elseif 名称=="160级高级装备礼包" then
    local 道具格子=玩家数据[id].角色:取道具格子2()
    if 道具格子<=5 then
      常规提示(id,"您的道具栏物品已经满啦")
      return 0
    end
    玩家数据[id].角色:购买高级装备礼包(160,id)
    self.临时id = 玩家数据[id].角色.数据.道具[内容.编号]
    玩家数据[id].角色.数据.道具[内容.编号]=nil
    玩家数据[id].道具.数据[self.临时id] = nil
    道具刷新(id)
    return
  elseif 名称=="神秘钥匙" and 老七定制 then
     local 道具格子=玩家数据[id].角色:取道具格子2()
     if 道具格子<=1 then
       常规提示(id,"您的道具栏物品已经满啦")
       return 0
      elseif 神秘宝箱[id] ~= nil then
       常规提示(id,"请等待当前结束后再次使用")
       return 0
     end
     商店处理类:设置钥匙神秘宝箱(id)
     发送数据(连接id,85,{道具=神秘宝箱[id]})
     self.临时id = 玩家数据[id].角色.数据.道具[内容.编号]
     if 玩家数据[id].道具.数据[self.临时id].数量>1 then
       玩家数据[id].道具.数据[self.临时id].数量=玩家数据[id].道具.数据[self.临时id].数量-1
     else
       玩家数据[id].角色.数据.道具[内容.编号]=nil
       玩家数据[id].道具.数据[self.临时id] = nil
     end
     道具刷新(id)
     return
  elseif 名称=="神秘钥匙" and 老唐定制 then
    local 道具格子=玩家数据[id].角色:取道具格子2()
    if 道具格子<=1 then
      常规提示(id,"您的道具栏物品已经满啦")
      return 0
    elseif 神秘宝箱[id] ~= nil then
      常规提示(id,"请等待当前结束后再次使用")
      return 0
    end
    商店处理类:设置老唐宝箱(id)
    发送数据(连接id,85,{道具=神秘宝箱[id]})
    self.临时id = 玩家数据[id].角色.数据.道具[内容.编号]
    if 玩家数据[id].道具.数据[self.临时id].数量>1 then
      玩家数据[id].道具.数据[self.临时id].数量=玩家数据[id].道具.数据[self.临时id].数量-1
    else
      玩家数据[id].角色.数据.道具[内容.编号]=nil
      玩家数据[id].道具.数据[self.临时id] = nil
    end
    道具刷新(id)
    return
  elseif 名称=="5级宝石礼包" then
    local 道具格子=玩家数据[id].角色:取道具格子2()
    if 道具格子<=6 then
      常规提示(id,"您的道具栏物品已经满啦")
      return 0
    end
    self:给予道具(id,"太阳石",5)
    self:给予道具(id,"光芒石",5)
    self:给予道具(id,"红玛瑙",5)
    self:给予道具(id,"月亮石",5)
    self:给予道具(id,"黑宝石",5)
    self:给予道具(id,"舍利子",5)
    道具使用=true
  elseif 名称=="7级宝石礼包" then
    local 道具格子=玩家数据[id].角色:取道具格子2()
    if 道具格子<=6 then
      常规提示(id,"您的道具栏物品已经满啦")
      return 0
    end
    self:给予道具(id,"太阳石",7)
    self:给予道具(id,"光芒石",7)
    self:给予道具(id,"红玛瑙",7)
    self:给予道具(id,"月亮石",7)
    self:给予道具(id,"黑宝石",7)
    self:给予道具(id,"舍利子",7)
    道具使用=true
  elseif 名称=="10级宝石礼包" then
    local 道具格子=玩家数据[id].角色:取道具格子2()
    if 道具格子<=6 then
      常规提示(id,"您的道具栏物品已经满啦")
      return 0
    end
    self:给予道具(id,"太阳石",10)
    self:给予道具(id,"光芒石",10)
    self:给予道具(id,"红玛瑙",10)
    self:给予道具(id,"月亮石",10)
    self:给予道具(id,"黑宝石",10)
    self:给予道具(id,"舍利子",10)
    道具使用=true
  elseif 名称=="跨服专属礼包" then
    local 道具格子=玩家数据[id].角色:取道具格子2()
    if 道具格子<2 then
      常规提示(id,"您的道具栏没有足够的空间")
      return 0
    end
    local 临时格子=玩家数据[id].角色:取道具格子()
    local 临时道具编号 = self:取新编号()
    self.数据[临时道具编号]=物品类()
    玩家数据[id].角色.数据.道具[临时格子]=临时道具编号
    local 临时名称=绑定等级物品()[26][1]
    local 物品数据=取物品数据(临时名称)
    玩家数据[id].道具.数据[临时道具编号]:置对象(临时名称)
    玩家数据[id].道具.数据[临时道具编号].级别限制 = 5
    玩家数据[id].道具.数据[临时道具编号].耐久=500
    玩家数据[id].道具.数据[临时道具编号]["防御"] =100
    玩家数据[id].道具.数据[临时道具编号]["气血"] =50000
    玩家数据[id].道具.数据[临时道具编号].不可交易=true
    临时格子=玩家数据[id].角色:取道具格子()
    临时名称 = 绑定等级物品()[22][17]
    临时道具编号 = self:取新编号()
    self.数据[临时道具编号]=物品类()
    玩家数据[id].角色.数据.道具[临时格子]=临时道具编号
    玩家数据[id].道具.数据[临时道具编号]:置对象(临时名称)
    玩家数据[id].道具.数据[临时道具编号].级别限制 = 160
    玩家数据[id].道具.数据[临时道具编号].鉴定=true
    玩家数据[id].道具.数据[临时道具编号].五行=取五行()
    玩家数据[id].道具.数据[临时道具编号].耐久=500
    玩家数据[id].道具.数据[临时道具编号].识别码=id.."_"..os.time().."_"..取随机数(1,999).."_"..id
    玩家数据[id].道具.数据[临时道具编号].专用=id
    玩家数据[id].道具.数据[临时道具编号].不可交易=true
    玩家数据[id].道具.数据[临时道具编号].特效 = "无级别限制"
    玩家数据[id].道具.数据[临时道具编号].防御 = 192
    玩家数据[id].道具.数据[临时道具编号].气血 = 25000
    常规提示(id,"您获得了专属道具")
    self.临时id = 玩家数据[id].角色.数据.道具[内容.编号]
    玩家数据[id].角色.数据.道具[内容.编号]=nil
    玩家数据[id].道具.数据[self.临时id] = nil
    道具刷新(id)
    return
  elseif 名称=="元宵" then
    self:元宵使用(连接id,id,内容)
    return
  elseif 名称=="炼兽真经" then
    self:炼兽真经使用(连接id,id,内容)
    return
  elseif 名称=="易经丹" then
    self:易经丹使用(连接id,id,内容)
    return
  elseif 名称=="清灵净瓶" then
    self:清灵净瓶处理(连接id,id,内容)
    return
  elseif 名称=="初级清灵仙露" or 名称=="中级清灵仙露" or 名称=="高级清灵仙露" then
    self:清灵仙露处理(连接id,id,内容)
    return
  elseif 名称=="玉葫灵髓" then
    self:玉葫灵髓使用(连接id,id,内容)
    return
  elseif 名称=="一级未激活符石" or 名称=="二级未激活符石" or 名称=="三级未激活符石" then
    self:符石激活处理(连接id,id,内容)
    return
  elseif 名称=="空白强化符" then
    if 玩家数据[id].角色.数据.师门技能 ~= nil then
        for n=1,#玩家数据[id].角色.数据.师门技能 do
            for i=1,#玩家数据[id].角色.数据.师门技能[n].包含技能 do
              if 玩家数据[id].角色.数据.师门技能[n].包含技能[i].名称 == "嗜血" or 玩家数据[id].角色.数据.师门技能[n].包含技能[i].名称 == "轻如鸿毛"
               or 玩家数据[id].角色.数据.师门技能[n].包含技能[i].名称 == "拈花妙指" or 玩家数据[id].角色.数据.师门技能[n].包含技能[i].名称 == "盘丝舞"
                or 玩家数据[id].角色.数据.师门技能[n].包含技能[i].名称 == "一气化三清" or 玩家数据[id].角色.数据.师门技能[n].包含技能[i].名称 == "浩然正气"
                 or 玩家数据[id].角色.数据.师门技能[n].包含技能[i].名称 == "龙附"  or 玩家数据[id].角色.数据.师门技能[n].包含技能[i].名称 == "神兵护法"
                  or 玩家数据[id].角色.数据.师门技能[n].包含技能[i].名称 == "魔王护持" or 玩家数据[id].角色.数据.师门技能[n].包含技能[i].名称 == "莲华妙法"
                   or 玩家数据[id].角色.数据.师门技能[n].包含技能[i].名称 == "神力无穷" or 玩家数据[id].角色.数据.师门技能[n].包含技能[i].名称 == "尸气漫天" then
                    if 玩家数据[id].角色.数据.师门技能[n].包含技能[i].等级 >=35 then
                      if 玩家数据[id].角色.数据.活力 >= 玩家数据[id].角色.数据.师门技能[n].包含技能[i].等级 then
                          玩家数据[id].角色.数据.活力 = 玩家数据[id].角色.数据.活力 - 玩家数据[id].角色.数据.师门技能[n].包含技能[i].等级
                          self:给予道具(id,"强化符",1,玩家数据[id].角色.数据.师门技能[n].包含技能[i].等级,玩家数据[id].角色.数据.师门技能[n].包含技能[i].名称)
                          道具使用 = true
                      else
                        常规提示(id,"#Y/你当前活力不足,无法使用该物品")
                        return
                      end
                    else
                      常规提示(id,"#Y/你还没学会制作强化符,无法使用该物品")
                      return
                end
            end
          end
        end
    else
        常规提示(id,"#Y/你还没门派,无法使用该物品")
    end
  elseif 名称=="强化符" then
    玩家数据[id].道具操作={类型=包裹类型,编号=内容.编号,id=道具id,道具=玩家数据[id].道具:索要道具1(id)}
    发送数据(连接id,65,玩家数据[id].道具操作)
    return
  elseif 名称=="天眼通符" then
    if 玩家数据[id].角色:取任务(8)~=0 then
      if 老唐定制 then
        地图处理类:跳转地图(id,任务数据[玩家数据[id].角色:取任务(8)].地图编号,任务数据[玩家数据[id].角色:取任务(8)].x,任务数据[玩家数据[id].角色:取任务(8)].y)
      else
        任务数据[玩家数据[id].角色:取任务(8)].显示x= 任务数据[玩家数据[id].角色:取任务(8)].x
        任务数据[玩家数据[id].角色:取任务(8)].显示y= 任务数据[玩家数据[id].角色:取任务(8)].y
      end
      道具使用=true
      常规提示(id,"#Y/你使用了天眼通符")
      玩家数据[id].角色:刷新任务跟踪()
    end
  elseif 名称=="海马" then
    玩家数据[id].角色.数据.体力 = 玩家数据[id].角色.数据.体力 + 150
    玩家数据[id].角色.数据.活力 = 玩家数据[id].角色.数据.活力 + 150
    if 玩家数据[id].角色.数据.体力 > 玩家数据[id].角色.数据.最大体力 then
        玩家数据[id].角色.数据.体力 = 玩家数据[id].角色.数据.最大体力
    end
    if 玩家数据[id].角色.数据.活力 > 玩家数据[id].角色.数据.最大活力 then
        玩家数据[id].角色.数据.活力 = 玩家数据[id].角色.数据.最大活力
    end
    常规提示(id,"#Y/你使用海马增加了150点体力和活力")
    道具使用 = true
  elseif 名称=="怪物卡片" then
    local 剧情等级=玩家数据[id].角色:取剧情技能等级("变化之术")
    if 剧情等级 <= 3 then
        if 剧情等级 + 1 <self.数据[道具id].等级 then
          常规提示(id,"#Y/你的变化之术等级太低了")
          return
        end
    elseif 剧情等级 == 4 then
        if 剧情等级 + 2 <self.数据[道具id].等级 then
          常规提示(id,"#Y/你的变化之术等级太低了")
          return
        end
    elseif 剧情等级 >= 5 then
        if 剧情等级 + 3 <self.数据[道具id].等级 then
          常规提示(id,"#Y/你的变化之术等级太低了")
          return
        end
    end
    if 玩家数据[id].角色:取任务(1)~=0 then
      任务数据[玩家数据[id].角色:取任务(1)]=nil
      玩家数据[id].角色:取消任务(1)
    end
    玩家数据[id].角色.数据.变身数据=self.数据[道具id].造型
    玩家数据[id].角色.数据.变异=false
    if 取随机数()>=0 then
        玩家数据[id].角色.数据.变异=true
    end
    道具使用=true
    玩家数据[id].角色:刷新信息()
    发送数据(连接id,37,{变身数据=玩家数据[id].角色.数据.变身数据,变异=玩家数据[id].角色.数据.变异})
    常规提示(id,"你使用了怪物卡片")
    发送数据(连接id,5506,{玩家数据[id].角色:取气血数据()})
    发送数据(玩家数据[id].连接id,12)
    任务处理类:添加变身(id,剧情等级)
    地图处理类:更改模型(id,{[1]=玩家数据[id].角色.数据.变身数据,[2]=玩家数据[id].角色.数据.变异},1)
  elseif 名称=="藏宝图" or 名称=="高级藏宝图" then
    if self:取队长权限(id)==false then
      常规提示(id,"#Y/你不是队长，无法使用此道具！")
      return
    elseif self.数据[道具id].地图编号~=玩家数据[id].角色.数据.地图数据.编号 then
      常规提示(id,"#Y/这里没有宝藏哟！")
      return
    elseif math.abs(self.数据[道具id].x-玩家数据[id].角色.数据.地图数据.x/20)>2 and math.abs(self.数据[道具id].y-玩家数据[id].角色.数据.地图数据.y/20)>2 then
      常规提示(id,"#Y/这里没有宝藏哟！")
      return
    end
    道具使用=true
    if 名称=="高级藏宝图" then
      self:高级藏宝图处理(id)
    else
      self:低级藏宝图处理(id)
    end
  elseif 名称=="九转金丹" then
    if 玩家数据[id].角色.数据.修炼[玩家数据[id].角色.数据.修炼.当前][1]>=玩家数据[id].角色.数据.修炼[玩家数据[id].角色.数据.修炼.当前][3] then
      常规提示(id,"#Y/你的此项修炼已经达上限")
      return
    end
    玩家数据[id].角色:添加人物修炼经验(id,math.floor(self.数据[道具id].阶品*0.5))
    道具使用=true
  elseif 名称=="修炼果" then
    if 玩家数据[id].角色.数据.bb修炼[玩家数据[id].角色.数据.bb修炼.当前][1]>=玩家数据[id].角色.数据.bb修炼[玩家数据[id].角色.数据.bb修炼.当前][3] then
      常规提示(id,"#Y/你的此项修炼已经达上限")
      return
    end
    玩家数据[id].角色:添加bb修炼经验(id,150)
    道具使用=true
  elseif 名称=="帮派银票" then
    常规提示(id,"#Y/"..id.."拥有的银票，存有"..self.数据[道具id].初始金额.."两银子")
    return
  elseif 名称=="月华露" then
    if 内容.窗口~="召唤兽" or 玩家数据[id].召唤兽.数据[内容.序列]==nil then
      常规提示(id,"请先选中一只召唤兽")
      return
    elseif 玩家数据[id].召唤兽.数据[内容.序列].等级 >= 玩家数据[id].角色.数据.等级 + 5 then
      常规提示(id,"该召唤兽已超过人物等级5级，无法使用该道具")
      return
    else
      local 临时等级=玩家数据[id].召唤兽.数据[内容.序列].等级
      if 临时等级==0 then
        临时等级=1
      end
      玩家数据[id].召唤兽:添加经验(连接id,id,内容.序列,self.数据[道具id].阶品*2*临时等级)
      道具使用=true
    end
  elseif 名称=="坐骑内丹" then
    if 内容.窗口~="坐骑" or 玩家数据[id].角色.数据.坐骑列表[内容.序列]==nil then
      常规提示(id,"请先选中一只坐骑")
      return
    else
      local 数量 = 取随机数(1,3)
      local 坐骑技能 = {}
      local ms = {"反震","吸血","反击","连击","飞行","感知","再生","冥思","慧根","必杀","幸运","神迹","招架","永恒","偷袭","毒","驱鬼","鬼魂术","魔之心","神佑复生","精神集中","法术连击","法术暴击","法术波动","土属性吸收","火属性吸收","水属性吸收"}
      for i=1,数量 do
        local 随机技能 = 取随机数(1,#ms)
          table.insert(坐骑技能,ms[随机技能])
          table.remove(ms,随机技能)
      end
      玩家数据[id].角色.数据.坐骑列表[内容.序列].技能 = 坐骑技能
      玩家数据[id].角色.数据.坐骑列表[内容.序列].技能等级={}
      玩家数据[id].角色.数据.坐骑列表[内容.序列].技能点 = math.ceil(玩家数据[id].角色.数据.坐骑列表[内容.序列].等级/20)
      常规提示(id,"你的坐骑重新领悟了技能，并且技能点已经重置")
      发送数据(玩家数据[id].连接id,61.1,{编号=内容.序列,数据=玩家数据[id].角色.数据.坐骑列表[内容.序列]})
      道具使用=true
    end
  elseif 名称=="翡翠琵琶" then
    if 玩家数据[id].角色.数据.炼丹灵气 == nil then
      玩家数据[id].角色.数据.炼丹灵气 = 5000
    else
      玩家数据[id].角色.数据.炼丹灵气 = 玩家数据[id].角色.数据.炼丹灵气 + 5000
    end
    常规提示(id,"你使用了翡翠琵琶,当前可用炼丹灵气为#R".. 玩家数据[id].角色.数据.炼丹灵气 .."#Y点")
    道具使用=true
  elseif 名称=="金砂丹" or 名称=="银砂丹" or 名称 == "铜砂丹" then
    local 银子 = 0
    if 名称=="金砂丹" then
      银子 = 1000000
    elseif 名称=="银砂丹" then
      银子 = 100000
    elseif 名称=="铜砂丹" then
      银子 = 10000
    end
    玩家数据[id].角色:添加银子(银子,"造化丹",1)
    道具使用=true
  elseif 名称=="初级神魂丹" or 名称=="中级神魂丹" or 名称=="高级神魂丹" then
    if self.数据[道具id].数量 == nil then
      self.数据[道具id].数量 = 1
    end
    if self.数据[道具id].数量 < 99 then
      常规提示(id,"必须集齐99个才可以使用哟")
      return
    end
    if 名称=="初级神魂丹" then
      玩家数据[id].道具:给予道具(id,"中级神魂丹",1)
      常规提示(id,"#Y/你获得了中级神魂丹")
    elseif 名称=="中级神魂丹" then
      玩家数据[id].道具:给予道具(id,"高级神魂丹",1)
      常规提示(id,"#Y/你获得了高级神魂丹")
    elseif 名称=="高级神魂丹" then
      玩家数据[id].道具:给予道具(id,"顶级神魂丹",1)
      常规提示(id,"#Y/你获得了顶级神魂丹")
    end
    删除数量=99
    道具使用=true
  elseif 名称=="神兜兜" then
    if 让海啸席卷 then
      常规提示(id,"#Y/集齐99个神兜兜后找GM兑换神兽一只")
    else
      if self.数据[道具id].数量 == nil then
        self.数据[道具id].数量 = 1
      end
      if self.数据[道具id].数量 < 99 then
        常规提示(id,"必须集齐99个才可以使用哟")
        return
      elseif #玩家数据[id].召唤兽.数据 >= 7 then
        常规提示(id,"你身上没有足够的位置携带神兽了。")
        return
      end
      local 模型库 = {"超级神龙","超级土地公公","超级六耳猕猴","超级神鸡","超级玉兔","超级神猴","超级神马","超级神羊","超级孔雀","超级灵狐","超级筋斗云","超级麒麟","超级大鹏","超级赤焰兽","超级白泽","超级灵鹿","超级大象","超级金猴","超级大熊猫","超级泡泡","超级神兔","超级神虎","超级神牛","超级人参娃娃","超级青鸾","超级腾蛇","超级神蛇"}
      local 模型 = 模型库[取随机数(1,#模型库)]
      local 物法 = "法系"
      if 取随机数()<=50 then
        物法 = nil
      end
      玩家数据[id].召唤兽:添加召唤兽(模型,nil,nil,true,0,物法)
      删除数量=99
      道具使用=true
      常规提示(id,"#Y/你获得了一个新的召唤兽"..模型)
    end
  end
  if 道具使用 then
    self:删除道具(连接id,id,包裹类型,道具id,道具格子,删除数量)
    道具刷新(id)
  else
    常规提示(id,"您无法使用这样的道具")
  end
end


 function 道具处理类:删除道具(连接id,id,包裹类型,道具id,道具格子,删除数量)
  if 删除数量==nil then 删除数量=1 end
  if self.数据[道具id].数量==nil and self.数据[道具id].名称~="怪物卡片" then
    self.数据[道具id]=nil
    玩家数据[id].角色.数据[包裹类型][道具格子]=nil
  elseif self.数据[道具id].名称=="怪物卡片" then
    self.数据[道具id].次数=self.数据[道具id].次数-1
    if  self.数据[道具id].次数<=0 then
      self.数据[道具id]=nil
      玩家数据[id].角色.数据[包裹类型][道具格子]=nil
    end
  else
    self.数据[道具id].数量=self.数据[道具id].数量-删除数量
    if self.数据[道具id].数量<=0 then
      self.数据[道具id]=nil
      玩家数据[id].角色.数据[包裹类型][道具格子]=nil
    end
  end
end

function 道具处理类:符石激活处理(连接id,id,内容)
  self.临时id = 玩家数据[id].角色.数据.道具[内容.编号]
  local 道具格子=玩家数据[id].角色:取道具格子()
  if 道具格子==0 then
    常规提示(id,"您的道具栏物品已经满啦")
    return
  end
  local 激活几率 = 0
  local 激活体力 = 0
  local 激活金钱 = 0
  local 激活经验 = 0
  if 玩家数据[id].道具.数据[self.临时id].名称 == "一级未激活符石" then
      激活几率 = 100
      激活体力 = 100
      激活金钱 = 50000
      激活经验 = 50000
  elseif 玩家数据[id].道具.数据[self.临时id].名称 == "二级未激活符石" then
      激活几率 = 90
      激活体力 = 150
      激活金钱 = 100000
      激活经验 = 100000
  elseif 玩家数据[id].道具.数据[self.临时id].名称 == "三级未激活符石" then
      激活几率 = 80
      激活体力 = 150
      激活金钱 = 150000
      激活经验 = 150000
  end
  if 激活金钱 > 取银子(id) then
      常规提示(id,"您没有那么多的银子")
      return
  elseif 激活体力 > 玩家数据[id].角色.数据.体力 then
      常规提示(id,"您当前没那么的体力")
      return
  elseif 激活经验 > 玩家数据[id].角色.数据.当前经验 then
      常规提示(id,"您当前没那么的经验")
      return
  end
  if 取随机数() <= 激活几率 then
      玩家数据[id].角色:扣除银子(激活金钱,0,0,"符石激活",1)
      玩家数据[id].角色.数据.体力=玩家数据[id].角色.数据.体力-激活体力
      玩家数据[id].角色.数据.当前经验=玩家数据[id].角色.数据.当前经验-激活经验
      local 符石名称 = 取符石(玩家数据[id].道具.数据[self.临时id].名称)
      self:给予道具(id,符石名称,1,55)
      玩家数据[id].道具.数据[self.临时id]=nil
      道具刷新(id)
      常规提示(id,"符石激活成功，获得了#R"..符石名称.."#Y符石，消耗了#R"..激活金钱.."两银子、"..激活体力.."点体力、"..激活经验.."点经验。")
  end
end

function 道具处理类:元宵使用(连接id,id,内容)
  self.临时id = 玩家数据[id].角色.数据.道具[内容.编号]
  local 元宵使用限制 = 100
  if 老唐定制 then
    元宵使用限制=200
  end
  if 内容.窗口~="召唤兽" or 玩家数据[id].召唤兽.数据[内容.序列]==nil then
      常规提示(id,"请先选中一只召唤兽")
      return
  elseif 玩家数据[id].道具.数据[self.临时id] == nil or 玩家数据[id].道具.数据[self.临时id].名称 ~= "元宵" then
      常规提示(id,"你的召唤兽无法使用该道具")
      return
  end
  if  玩家数据[id].召唤兽.数据[内容.序列].元宵 == nil then
     玩家数据[id].召唤兽.数据[内容.序列].元宵 = {}
  end
  local 食材 = 玩家数据[id].道具.数据[self.临时id].食材
  local 资质 = "攻击资质"
  if 食材 == "桂花酒酿" then
    资质 = "防御资质"
  elseif 食材 == "细磨豆沙" then
    资质 = "速度资质"
  elseif 食材 == "蜜糖腰果" then
    资质 = "躲闪资质"
  elseif 食材 == "山楂拔丝" then
    资质 = "体力资质"
  elseif 食材 == "滑玉莲蓉" then
    资质 = "法力资质"
  end
  if 玩家数据[id].召唤兽.数据[内容.序列].元宵[食材] == nil then
    玩家数据[id].召唤兽.数据[内容.序列].元宵[食材] = 1
  else
    if 玩家数据[id].召唤兽.数据[内容.序列].元宵[食材] >= 元宵使用限制 then
      常规提示(id,"该召唤兽可食用"..食材.."元宵数量已经达到了上限！")
      return
    end
    玩家数据[id].召唤兽.数据[内容.序列].元宵[食材] = 玩家数据[id].召唤兽.数据[内容.序列].元宵[食材] + 1
  end
  local 上限 = 玩家数据[id].召唤兽.数据[内容.序列][资质] *0.005
  local 下限 = 玩家数据[id].召唤兽.数据[内容.序列][资质] *0.002
  local 增加数值 = math.floor(取随机数(下限,上限))
  玩家数据[id].召唤兽.数据[内容.序列][资质] = 玩家数据[id].召唤兽.数据[内容.序列][资质] + 增加数值
  玩家数据[id].道具.数据[self.临时id].数量 = 玩家数据[id].道具.数据[self.临时id].数量 - 1
  if 玩家数据[id].道具.数据[self.临时id].数量 <= 0 then
    玩家数据[id].道具.数据[self.临时id].数量 = nil
    玩家数据[id].角色.数据.道具[内容.编号] = nil
  end
  常规提示(id,"恭喜你的召唤兽#R"..资质.."#W提升了#R"..增加数值.."#W点")
  常规提示(id,"食用元宵成功,该召唤兽还可以食用#R"..食材.."#W元宵"..(元宵使用限制-玩家数据[id].召唤兽.数据[内容.序列].元宵[食材]).."个")
  玩家数据[id].召唤兽:刷新信息(内容.序列)
  道具刷新(id)
end

function 道具处理类:炼兽真经使用(连接id,id,内容)
  self.临时id = 玩家数据[id].角色.数据.道具[内容.编号]
  local 炼兽真经使用限制=5
  if 老唐定制 then
    炼兽真经使用限制=50
  end
  if 内容.窗口~="召唤兽" or 玩家数据[id].召唤兽.数据[内容.序列]==nil then
    常规提示(id,"请先选中一只召唤兽")
    return
  elseif 玩家数据[id].道具.数据[self.临时id] == nil or 玩家数据[id].道具.数据[self.临时id].名称 ~= "炼兽真经" then
    常规提示(id,"你的召唤兽无法使用该道具")
    return
  end
  if 玩家数据[id].召唤兽.数据[内容.序列].炼兽真经~=nil and 玩家数据[id].召唤兽.数据[内容.序列].炼兽真经>=炼兽真经使用限制 then
    常规提示(id,"该召唤兽已经无法再使用炼兽真经")
    return
  end
  if 玩家数据[id].召唤兽.数据[内容.序列].炼兽真经 == nil then
     玩家数据[id].召唤兽.数据[内容.序列].炼兽真经 = 0
  end
  玩家数据[id].召唤兽.数据[内容.序列].炼兽真经=玩家数据[id].召唤兽.数据[内容.序列].炼兽真经+1
  玩家数据[id].召唤兽.数据[内容.序列].成长=玩家数据[id].召唤兽.数据[内容.序列].成长+0.02
  if 玩家数据[id].道具.数据[self.临时id].数量 == nil then
    玩家数据[id].道具.数据[self.临时id].数量 = 1
  end
  玩家数据[id].道具.数据[self.临时id].数量=玩家数据[id].道具.数据[self.临时id].数量-1
  if 玩家数据[id].道具.数据[self.临时id].数量 <= 0 then
    玩家数据[id].道具.数据[self.临时id] = nil
    玩家数据[id].角色.数据.道具[内容.编号] = nil
  end
  常规提示(id,"#Y恭喜你的召唤兽成长提升了#R0.02#Y点")
  常规提示(id,"#Y炼兽真经使用成长,该召唤兽还可以使用#R"..(炼兽真经使用限制-玩家数据[id].召唤兽.数据[内容.序列].炼兽真经).."#Y个炼兽真经")
  玩家数据[id].召唤兽:刷新信息(内容.序列)
  道具刷新(id)
end

function 道具处理类:易经丹使用(连接id,id,内容)
  self.临时id = 玩家数据[id].角色.数据.道具[内容.编号]
  if 内容.窗口~="召唤兽" or 玩家数据[id].召唤兽.数据[内容.序列]==nil then
      常规提示(id,"请先选中一只召唤兽")
      return
  end
  if 玩家数据[id].召唤兽.数据[内容.序列].种类 == "野怪" then
      常规提示(id,"该物品不能对野怪使用")
      return
  end
  if 玩家数据[id].召唤兽.数据[内容.序列].灵性 < 50 and (玩家数据[id].召唤兽.数据[内容.序列].参战等级 >= 45 or 玩家数据[id].召唤兽.数据[内容.序列].种类 == "神兽") then
      玩家数据[id].召唤兽.数据[内容.序列].灵性 = 玩家数据[id].召唤兽.数据[内容.序列].灵性 + 10
      常规提示(id,"你的召唤兽"..玩家数据[id].召唤兽.数据[内容.序列].名称.."服用了一个易经丹,神清气爽,仙气缭绕,修为增加！")
      if 玩家数据[id].召唤兽.数据[内容.序列].灵性 >= 50 then
          常规提示(id,"你的召唤兽"..玩家数据[id].召唤兽.数据[内容.序列].模型.."已经达到了进阶的条件,可以进阶改变造型了")
      end
      if 玩家数据[id].道具.数据[self.临时id].数量==nil then
          玩家数据[id].道具.数据[self.临时id].数量=1
      end
      if 玩家数据[id].道具.数据[self.临时id].数量 == 1 then
          玩家数据[id].道具.数据[self.临时id] = nil
      else
          玩家数据[id].道具.数据[self.临时id].数量 = 玩家数据[id].道具.数据[self.临时id].数量 - 1
      end
      道具刷新(id)
  elseif 玩家数据[id].召唤兽.数据[内容.序列].灵性 > 79 then
      local 随机特性={"复仇","自恋","灵刃","灵法","预知","灵动","瞬击","瞬法","抗法","抗物","阳护","识物","护佑","洞察","弑神","御风","顺势","怒吼","乖巧","力破","识药","争锋","灵断"}
      local a =随机特性[取随机数(1,#随机特性)]
      玩家数据[id].召唤兽.数据[内容.序列].特性 = a
      玩家数据[id].召唤兽.数据[内容.序列].特性几率 = 取随机数(1,5)
      常规提示(id,"你的召唤兽#R/"..玩家数据[id].召唤兽.数据[内容.序列].名称.."#Y/领悟了#R/"..a)
      if 玩家数据[id].道具.数据[self.临时id].数量==nil then
          玩家数据[id].道具.数据[self.临时id].数量=1
      end
      if 玩家数据[id].道具.数据[self.临时id].数量 == 1 then
          玩家数据[id].道具.数据[self.临时id] = nil
          玩家数据[id].角色.数据.道具[内容.编号] = nil
      else
          玩家数据[id].道具.数据[self.临时id].数量 = 玩家数据[id].道具.数据[self.临时id].数量 - 1
      end
      玩家数据[id].召唤兽:刷新信息(内容.序列)
      道具刷新(id)
  else
      常规提示(id,"你的召唤兽无法使用该道具")
      玩家数据[id].召唤兽:刷新信息(内容.序列)
  end
end

function 道具处理类:清灵净瓶处理(连接id,id,内容)
  self.临时id = 玩家数据[id].角色.数据.道具[内容.编号]
  local 道具格子=玩家数据[id].角色:取道具格子()
  if 道具格子==0 then
    常规提示(id,"您的道具栏物品已经满啦")
    return
  end
  if 玩家数据[id].道具.数据[self.临时id].数量 == 1 then
    玩家数据[id].道具.数据[self.临时id] = nil
  else
    玩家数据[id].道具.数据[self.临时id].数量 = 玩家数据[id].道具.数据[self.临时id].数量 - 1
  end
  local 随机瓶子={"高级清灵仙露","中级清灵仙露","初级清灵仙露"}
  local a =随机瓶子[取随机数(1,#随机瓶子)]
  self:给予道具(id,a)
  道具刷新(id)
end

function 道具处理类:清灵仙露处理(连接id,id,内容)
  self.临时id = 玩家数据[id].角色.数据.道具[内容.编号]
  if 内容.窗口~="召唤兽" or 玩家数据[id].召唤兽.数据[内容.序列]==nil then
      常规提示(id,"请先选中一只召唤兽")
      return
  end
  if 玩家数据[id].召唤兽.数据[内容.序列].种类 == "野怪" then
      常规提示(id,"该物品不能对野怪使用")
      return
  end
  local 临时灵性
  if 玩家数据[id].召唤兽.数据[内容.序列].灵性 > 100 then
      常规提示(id,"该召唤兽已无法再使用清灵仙露")
      return
  end
  if 玩家数据[id].召唤兽.数据[内容.序列].灵性 >= 50 and (玩家数据[id].召唤兽.数据[内容.序列].仙露上限 >0 or 追忆年华 ~= nil) then
      if 玩家数据[id].道具.数据[self.临时id].灵气 == 8 then
        if  取随机数() < 10 then
          临时灵性 = 取随机数(9,10)
        else
          临时灵性 = 玩家数据[id].道具.数据[self.临时id].灵气
        end
      else
        临时灵性 = 玩家数据[id].道具.数据[self.临时id].灵气
      end

      玩家数据[id].召唤兽.数据[内容.序列].潜力=玩家数据[id].召唤兽.数据[内容.序列].潜力+临时灵性*2
      玩家数据[id].召唤兽.数据[内容.序列].灵性 = 玩家数据[id].召唤兽.数据[内容.序列].灵性 + 临时灵性
      常规提示(id,"你的召唤兽"..玩家数据[id].召唤兽.数据[内容.序列].名称.."增加了#R/"..临时灵性.."#Y/点灵性")
      if 玩家数据[id].召唤兽.数据[内容.序列].灵性 >= 110 then
        玩家数据[id].召唤兽.数据[内容.序列].进阶属性.力量 = 取随机数(10,30)
        玩家数据[id].召唤兽.数据[内容.序列].进阶属性.魔力 = 取随机数(10,30)
        玩家数据[id].召唤兽.数据[内容.序列].进阶属性.体质 = 取随机数(10,30)
        玩家数据[id].召唤兽.数据[内容.序列].进阶属性.敏捷 = 取随机数(10,30)
        玩家数据[id].召唤兽.数据[内容.序列].进阶属性.耐力 = 取随机数(10,30)
        常规提示(id,"你的召唤兽"..玩家数据[id].召唤兽.数据[内容.序列].名称.."的进阶属性增加了")
      end
      if 玩家数据[id].道具.数据[self.临时id].数量 == 1 or 玩家数据[id].道具.数据[self.临时id].数量 == nil then
        玩家数据[id].道具.数据[self.临时id] = nil
      else
        玩家数据[id].道具.数据[self.临时id].数量 = 玩家数据[id].道具.数据[self.临时id].数量 - 1
      end
      玩家数据[id].召唤兽.数据[内容.序列].仙露上限 = 玩家数据[id].召唤兽.数据[内容.序列].仙露上限 - 1
      玩家数据[id].召唤兽:刷新信息(内容.序列)
      道具刷新(id)
  else
      if 玩家数据[id].召唤兽.数据[内容.序列].仙露上限 == 0 then
          常规提示(id,"该召唤兽已使用7瓶清灵仙露!")
      else
          常规提示(id,"你的召唤兽灵性必须达到50以上才能使用清灵仙露!")
      end
      玩家数据[id].召唤兽:刷新信息(内容.序列)
  end
end

function 道具处理类:玉葫灵髓使用(连接id,id,内容)
  self.临时id = 玩家数据[id].角色.数据.道具[内容.编号]
  local 超过灵性 = 玩家数据[id].召唤兽.数据[内容.序列].灵性-50
  if 内容.窗口~="召唤兽" or 玩家数据[id].召唤兽.数据[内容.序列]==nil then
      常规提示(id,"请先选中一只召唤兽")
      return
  end
  if 玩家数据[id].召唤兽.数据[内容.序列].种类 == "野怪" then
      常规提示(id,"该物品不能对野怪使用")
      return
  end
  if 玩家数据[id].召唤兽.数据[内容.序列].灵性 > 50 and (玩家数据[id].召唤兽.数据[内容.序列].参战等级 >= 45 or 玩家数据[id].召唤兽.数据[内容.序列].种类 == "神兽") then

      if 玩家数据[id].召唤兽.数据[内容.序列].种类=="神兽" then
          玩家数据[id].召唤兽.数据[内容.序列].体质=玩家数据[id].召唤兽.数据[内容.序列].等级+20
          玩家数据[id].召唤兽.数据[内容.序列].魔力=玩家数据[id].召唤兽.数据[内容.序列].等级+20
          玩家数据[id].召唤兽.数据[内容.序列].力量=玩家数据[id].召唤兽.数据[内容.序列].等级+20
          玩家数据[id].召唤兽.数据[内容.序列].耐力=玩家数据[id].召唤兽.数据[内容.序列].等级+20
          玩家数据[id].召唤兽.数据[内容.序列].敏捷=玩家数据[id].召唤兽.数据[内容.序列].等级+20
          玩家数据[id].召唤兽.数据[内容.序列].潜力=玩家数据[id].召唤兽.数据[内容.序列].等级*5
      elseif 玩家数据[id].召唤兽.数据[内容.序列].种类=="变异" then
          玩家数据[id].召唤兽.数据[内容.序列].体质=玩家数据[id].召唤兽.数据[内容.序列].等级+15
          玩家数据[id].召唤兽.数据[内容.序列].魔力=玩家数据[id].召唤兽.数据[内容.序列].等级+15
          玩家数据[id].召唤兽.数据[内容.序列].力量=玩家数据[id].召唤兽.数据[内容.序列].等级+15
          玩家数据[id].召唤兽.数据[内容.序列].耐力=玩家数据[id].召唤兽.数据[内容.序列].等级+15
          玩家数据[id].召唤兽.数据[内容.序列].敏捷=玩家数据[id].召唤兽.数据[内容.序列].等级+15
          玩家数据[id].召唤兽.数据[内容.序列].潜力=玩家数据[id].召唤兽.数据[内容.序列].等级*5
      elseif 玩家数据[id].召唤兽.数据[内容.序列].种类=="宝宝" then
          玩家数据[id].召唤兽.数据[内容.序列].体质=玩家数据[id].召唤兽.数据[内容.序列].等级+10
          玩家数据[id].召唤兽.数据[内容.序列].魔力=玩家数据[id].召唤兽.数据[内容.序列].等级+10
          玩家数据[id].召唤兽.数据[内容.序列].力量=玩家数据[id].召唤兽.数据[内容.序列].等级+10
          玩家数据[id].召唤兽.数据[内容.序列].耐力=玩家数据[id].召唤兽.数据[内容.序列].等级+10
          玩家数据[id].召唤兽.数据[内容.序列].敏捷=玩家数据[id].召唤兽.数据[内容.序列].等级+10
          玩家数据[id].召唤兽.数据[内容.序列].潜力=玩家数据[id].召唤兽.数据[内容.序列].等级*5
      end
      玩家数据[id].召唤兽:刷新信息(内容.序列)
      常规提示(id,"该召唤兽被重置了属性点！")
      玩家数据[id].召唤兽.数据[内容.序列].潜力 = 玩家数据[id].召唤兽.数据[内容.序列].潜力+100
      玩家数据[id].召唤兽.数据[内容.序列].灵性 = 50
      玩家数据[id].召唤兽.数据[内容.序列].进阶属性.力量 = 0
      玩家数据[id].召唤兽.数据[内容.序列].进阶属性.魔力 = 0
      玩家数据[id].召唤兽.数据[内容.序列].进阶属性.体质 = 0
      玩家数据[id].召唤兽.数据[内容.序列].进阶属性.敏捷 = 0
      玩家数据[id].召唤兽.数据[内容.序列].进阶属性.耐力 = 0
      玩家数据[id].召唤兽.数据[内容.序列].特性 = "无"
      玩家数据[id].召唤兽.数据[内容.序列].仙露上限 = 7
      常规提示(id,"你的召唤兽#R/"..玩家数据[id].召唤兽.数据[内容.序列].名称.."#Y/服用一个玉葫灵髓后,灵性已回归原始！")
      if 玩家数据[id].道具.数据[self.临时id].数量 == 1 then
        玩家数据[id].道具.数据[self.临时id] = nil
      else
        玩家数据[id].道具.数据[self.临时id].数量 = 玩家数据[id].道具.数据[self.临时id].数量 - 1
      end
      玩家数据[id].召唤兽:刷新信息(内容.序列)
      道具刷新(id)
  else
      常规提示(id,"召唤兽的灵性必须大于50才能使用玉葫灵髓")
      玩家数据[id].召唤兽:刷新信息(内容.序列)
  end
end

function 道具处理类:取队长权限(id)
  if 玩家数据[id].队伍==0 then
    return true
  elseif 玩家数据[id].队伍~=0 and 玩家数据[id].队长 then
    return true
  else
    return false
  end
end

function 道具处理类:加血处理(连接id,id,加血数值,加血对象,动画)
  if 动画==nil then
    动画="加血"
  end
  if 加血对象==0 then
    玩家数据[id].角色.数据.气血=玩家数据[id].角色.数据.气血+加血数值
    if 玩家数据[id].角色.数据.气血>玩家数据[id].角色.数据.最大气血 then
      玩家数据[id].角色.数据.气血=玩家数据[id].角色.数据.最大气血
    end
    发送数据(连接id,36,{动画=动画})
    发送数据(连接id,5506,{玩家数据[id].角色:取气血数据()})
    地图处理类:加入动画(id,玩家数据[id].角色.数据.地图数据.编号,玩家数据[id].角色.数据.地图数据.x,玩家数据[id].角色.数据.地图数据.y,动画)
  else
    玩家数据[id].召唤兽:加血处理(加血对象,加血数值,连接id,id)
  end
end

function 道具处理类:加魔处理(连接id,id,加血数值,加血对象)
  if 加血对象==0 then
    玩家数据[id].角色.数据.魔法=玩家数据[id].角色.数据.魔法+加血数值
    if 玩家数据[id].角色.数据.魔法>玩家数据[id].角色.数据.最大魔法 then
      玩家数据[id].角色.数据.魔法=玩家数据[id].角色.数据.最大魔法
    end
    发送数据(连接id,36,{动画="加蓝"})
    发送数据(连接id,5506,{玩家数据[id].角色:取气血数据()})
    地图处理类:加入动画(id,玩家数据[id].角色.数据.地图数据.编号,玩家数据[id].角色.数据.地图数据.x,玩家数据[id].角色.数据.地图数据.y,"加蓝")
  else
    玩家数据[id].召唤兽:加蓝处理(加血对象,加血数值,连接id,id)
  end
end

function 道具处理类:取飞行限制(id)
  if 玩家数据[id].队伍~=0 and 玩家数据[id].队长==false then
      常规提示(id,"只有队长才可以使用飞行道具")
      return true
  elseif self:取禁止飞行(id) then
    常规提示(id,"#Y/您当前无法使用飞行道具")
    return true
  elseif 玩家数据[id].角色.数据.等级<10 then
    常规提示(id,"#Y/您当前等级太低了无法使用飞行道具")
    return true
  elseif 玩家数据[id].队伍~=0 and 玩家数据[id].队长 then
    local 队伍id=玩家数据[id].队伍
    for n=1,#队伍数据[队伍id].成员数据 do
      if self:取禁止飞行(队伍数据[队伍id].成员数据[n]) then
        常规提示(id,format("#G/%s当前不能使用飞行道具",玩家数据[队伍数据[队伍id].成员数据[n]].角色.数据.名称))
        return true
      end
    end
  end
  return false
end

function 道具处理类:取禁止飞行(id)
  if 玩家数据[id].摊位数据~=nil then return true end
  local 任务id=玩家数据[id].角色:取任务(110)
  if 任务id~=0 and 任务数据[任务id].分类==2 then return true  end
  if 玩家数据[id].角色:取任务(208)~=0 or 玩家数据[id].角色:取任务(300)~=0 or 玩家数据[id].角色.数据.跑商 then return true end
  return false
 end



function 道具处理类:给予随机法宝(id)
  local 参数=取随机数()
  local 名称=""
  local 等级=0
  if 参数<=30 then
   名称={"碧玉葫芦","五色旗盒","飞剑","拭剑石","金甲仙衣","惊魂铃","嗜血幡","风袋","清心咒","九黎战鼓","盘龙壁","神行飞剑","汇灵盏","天师符","织女扇"}
   等级=1
  elseif 参数<=65 then
   名称={"发瘟匣","断线木偶","五彩娃娃","七杀","金刚杵","兽王令","摄魂","附灵玉"}
   等级=2
  else
   名称={"失心钹","五火神焰印","九幽","普渡","月影","鬼泣","月光宝盒","混元伞","无魂傀儡","苍白纸人","聚宝盆","乾坤玄火塔","无尘扇","无字经","干将莫邪","慈悲","救命毫毛","伏魔天书","镇海珠","奇门五行令"}
   等级=3
  end
  名称=名称[取随机数(1,#名称)]
  self:给予法宝(id,名称)
end

function 道具处理类:给予随机一级法宝(id)
  local 名称=""
  local 等级=0
  名称={"碧玉葫芦","五色旗盒","飞剑","拭剑石","金甲仙衣","惊魂铃","嗜血幡","风袋","清心咒","九黎战鼓","盘龙壁","神行飞剑","汇灵盏","天师符","织女扇"}
  等级=1
  名称=名称[取随机数(1,#名称)]
  self:给予法宝(id,名称)
end

function 道具处理类:给予法宝(id,名称)
  local 识别码=id.."_"..os.time().."_"..取随机数(1000,9999999).."_"..随机序列
  随机序列=随机序列+1
  local 道具格子=玩家数据[id].角色:取法宝格子()
  if 道具格子==0 then
    常规提示(id,"您的法宝栏已经满啦")
    return
  end
  道具id=self:取新编号()
  self.数据[道具id]=物品类()
  self.数据[道具id]:置对象(名称)
  self.数据[道具id].识别码=识别码
  玩家数据[id].角色.数据.法宝[道具格子]=道具id
  local 道具 = 取物品数据(名称)
  self.数据[道具id].总类=1000
  self.数据[道具id].分类=道具[3]
  self.数据[道具id].使用 = 道具[5]
  self.数据[道具id].特技 = 道具[6]
  self.数据[道具id].气血 = 0
  self.数据[道具id].魔法 = 取灵气上限(道具[3])
  self.数据[道具id].角色限制 = 道具[7] or 0
  self.数据[道具id].五行 = 取五行()
  self.数据[道具id].伤害 = 道具[8] or 0
  self.数据[道具id].当前经验=0
  self.数据[道具id].升级经验=法宝经验[self.数据[道具id].分类][1]
  玩家数据[id].角色:日志记录(format("获得新法宝：名称%s,识别码%s",名称,识别码))
  常规提示(id,"#Y你获得了新的法宝#R"..名称)
end

function 道具处理类:给予道具(id,名称,数量,参数,附加,专用)
  local 识别码=id.."_"..os.time().."_"..取随机数(1000,9999999).."_"..随机序列
  随机序列=随机序列+1
  local 道具格子=玩家数据[id].角色:取道具格子()
  if 道具格子==0 then
    常规提示(id,"您的道具栏物品已经满啦")
    return
  else
    local 重置id=0
    for n=1,20 do
      if 重置id==0 and 玩家数据[id].角色.数据.道具[n]~=nil and self.数据[玩家数据[id].角色.数据.道具[n]]~=nil and self.数据[玩家数据[id].角色.数据.道具[n]].名称==名称 and self.数据[玩家数据[id].角色.数据.道具[n]].数量~=nil and 名称 ~= "元宵" and 名称 ~= "九转金丹" and 名称 ~= "月华露" then
        if self.数据[玩家数据[id].角色.数据.道具[n]].数量+数量<=99 then
          数量=self.数据[玩家数据[id].角色.数据.道具[n]].数量+数量
          道具id=玩家数据[id].角色.数据.道具[n]
          识别码=self.数据[玩家数据[id].角色.数据.道具[n]].识别码
          重置id=1
        end
      end
    end
    if 重置id==0 then
      道具id=self:取新编号()
      self.数据[道具id]=物品类()
      self.数据[道具id]:置对象(名称)
      玩家数据[id].角色.数据.道具[道具格子]=道具id
    end
    临时道具 = 取物品数据(名称)
    临时道具.总类=临时道具[2]
    临时道具.子类=临时道具[4]
    临时道具.分类=临时道具[3]
    --print(临时道具.总类,临时道具.子类,临时道具.分类)
    if 名称=="鬼谷子" then
      self.数据[道具id].子类= self.阵法名称[取随机数(4,13)]
    elseif 名称=="钟灵石" and 钟灵石定制 then
      local 幻化类型 = {"心源","狂浪滔天","固若金汤","锐不可当","通真达灵","血气方刚","健步如飞"}
      if 参数 ~= nil then
        self.数据[道具id].附加特性 = 参数
      else
        self.数据[道具id].附加特性 = 幻化类型[取随机数(1,#幻化类型)]
      end
      if 数量 ~= nil then
        self.数据[道具id].级别限制 = 数量
      else
        self.数据[道具id].级别限制 = 1
      end
    elseif 名称=="精魄灵石" then
      local 特效 = {"伤害","气血","防御","速度","命中","灵力","躲避"}
      if 参数 ~= nil then
        self.数据[道具id].特效 = 参数
      else
        self.数据[道具id].特效 = 幻化类型[取随机数(1,#幻化类型)]
      end
      if 数量 ~= nil then
        self.数据[道具id].级别限制 = 数量
      else
        self.数据[道具id].级别限制 = 1
      end
    elseif 名称=="点化石" then
      if 参数~=nil then
        self.数据[道具id].附带技能=参数
      else
        if 取随机数()<=20 then
          self.数据[道具id].附带技能=取高级要诀()
        else
          self.数据[道具id].附带技能=取低级要诀()
        end
      end
    elseif 名称=="制造指南书" then
      self.数据[道具id].子类=数量
      self.数据[道具id].特效=参数
    elseif 名称=="灵饰指南书" then
      self.数据[道具id].子类=数量[取随机数(1,#数量)]*10
      if self.数据[道具id].子类>=160 then
        self.数据[道具id].子类 = 160
      elseif self.数据[道具id].子类 >= 140 then
        self.数据[道具id].子类 = 140
      end
      self.数据[道具id].特效=随机灵饰[取随机数(1,#随机灵饰)]
    elseif 名称=="元灵晶石" then
      self.数据[道具id].子类=数量[取随机数(1,#数量)]*10
      if self.数据[道具id].子类>=160 then
        self.数据[道具id].子类 = 160
      elseif self.数据[道具id].子类 >= 140 then
        self.数据[道具id].子类 = 140
      end
    elseif 名称=="灵宝图鉴" or 名称=="神兵图鉴" then
      self.数据[道具id].子类=参数
    elseif 名称=="强化符" then
      self.数据[道具id].等级=参数
      self.数据[道具id].类型=附加
    elseif self.数据[道具id].总类==2000 then
      self.数据[道具id].耐久=100
    elseif 名称=="百炼精铁" then
      self.数据[道具id].子类=数量
    elseif 名称=="初级清灵仙露" then
      self.数据[道具id].灵气=取随机数(0,4)
    elseif 名称=="中级清灵仙露" then
      self.数据[道具id].灵气=取随机数(2,6)
    elseif 名称=="高级清灵仙露" then
      self.数据[道具id].灵气=取随机数(4,8)
    elseif 名称=="召唤兽内丹" then
      self.数据[道具id].附带技能=取内丹()
    elseif 名称=="吸附石" then
      self.数据[道具id].五行=取五行()
    elseif 名称=="高级召唤兽内丹" then
      self.数据[道具id].附带技能=取内丹("高级")
    elseif 名称=="魔兽要诀" then
      self.数据[道具id].附带技能=取低级要诀()
    elseif 参数==55 then
      local 符石数据 = 取物品数据(名称)
      self.数据[道具id].颜色=符石数据[20]
      self.数据[道具id].耐久度=符石数据[17]
      self.数据[道具id].等级=符石数据[16]
      self.数据[道具id][符石数据[18]]=符石数据[19]
      if 符石数据[21]~=nil then
          self.数据[道具id][符石数据[21]]=符石数据[22]
      end
    elseif 名称=="高级魔兽要诀" then
     if 参数==nil then
       self.数据[道具id].附带技能=取高级要诀()
      else
       self.数据[道具id].附带技能=参数
      end
    elseif 名称=="帮派银票" then
      if 玩家数据[id].角色.数据.等级>=20 and 玩家数据[id].角色.数据.等级<=39 then
          self.数据[道具id].初始金额=20000
          self.数据[道具id].完成金额=50000
      elseif 玩家数据[id].角色.数据.等级>=40 and 玩家数据[id].角色.数据.等级<=59 then
          self.数据[道具id].初始金额=40000
          self.数据[道具id].完成金额=100000
      elseif 玩家数据[id].角色.数据.等级>=60 and 玩家数据[id].角色.数据.等级<=79 then
          self.数据[道具id].初始金额=50000
          self.数据[道具id].完成金额=150000
      elseif 玩家数据[id].角色.数据.等级>=80 and 玩家数据[id].角色.数据.等级<=99 then
          self.数据[道具id].初始金额=42000
          self.数据[道具id].完成金额=150000
      elseif 玩家数据[id].角色.数据.等级>=100 then
          self.数据[道具id].初始金额=52000
          self.数据[道具id].完成金额=180000
      end
      self.数据[道具id].专用="专用"
    elseif 名称=="月华露" or 名称=="九转金丹" or 名称=="修炼果" then
      self.数据[道具id].阶品=参数
      self.数据[道具id].数量=数量
    elseif 名称=="元宵" then
      local 食材 = {"芝麻沁香","桂花酒酿","细磨豆沙","蜜糖腰果","蜜糖腰果","蜜糖腰果","山楂拔丝","滑玉莲蓉"}
      self.数据[道具id].食材 = 食材[取随机数(1,#食材)]
      self.数据[道具id].数量 = 数量
    elseif 名称=="清灵净瓶" then
      self.数据[道具id].数量=数量
    elseif 名称=="藏宝图" or 名称=="高级藏宝图" then
      local 随机地图={1501,1506,1092,1091,1110,1142,1514,1174,1173,1146,1208}
      local 临时地图=随机地图[取随机数(1,#随机地图)]
      self.数据[道具id].地图名称=取地图名称(临时地图)
      self.数据[道具id].地图编号=临时地图
      local xy=地图处理类.地图坐标[临时地图]:取随机点()
      self.数据[道具id].x=xy.x
      self.数据[道具id].y=xy.y
    elseif 名称=="炼妖石" or 名称=="上古锻造图策" then
      self.数据[道具id].级别限制=数量[取随机数(1,#数量)]
      self.数据[道具id].种类=图策范围[取随机数(1,#图策范围)]
    elseif 名称=="珍珠" then
      self.数据[道具id].级别限制 = 数量
    elseif 名称=="怪物卡片" then
      if 变身卡数据[数量]==nil then
       self.数据[道具id].等级=数量
       self.数据[道具id].造型=变身卡范围[数量][取随机数(1,#变身卡范围[数量])]
      else
       self.数据[道具id].等级=变身卡数据[数量].等级
       self.数据[道具id].造型=数量
      end
      self.数据[道具id].类型=变身卡数据[self.数据[道具id].造型].类型
      self.数据[道具id].单独=变身卡数据[self.数据[道具id].造型].单独
      self.数据[道具id].正负=变身卡数据[self.数据[道具id].造型].正负
      self.数据[道具id].技能=变身卡数据[self.数据[道具id].造型].技能
      self.数据[道具id].属性=变身卡数据[self.数据[道具id].造型].属性
      self.数据[道具id].次数=self.数据[道具id].等级
    elseif 临时道具.总类==5 and  临时道具.分类==4 then
      self.数据[道具id].级别限制=数量
    elseif 临时道具.总类==5 and  临时道具.分类==6 then
      self.数据[道具id].级别限制=数量
    elseif 临时道具.总类==1 and 临时道具.子类==1 and 临时道具.分类==4 then
      self.数据[道具id].阶品=参数
    elseif 名称=="金创药" or 名称=="小还丹" or 名称=="千年保心丹" or 名称=="金香玉" or 名称=="风水混元丹" or 名称=="蛇蝎美人" or 名称=="定神香" or 名称=="佛光舍利子" or 名称=="九转回魂丹" or 名称=="五龙丹"   or 名称=="十香返生丸"     then
      self.数据[道具id].阶品=参数
    end
    if self.数据[道具id].可叠加 then
        self.数据[道具id].数量=数量
    end
  end
  self.数据[道具id].识别码=识别码
  if  self.数据[道具id].名称=="心魔宝珠" then
    self.数据[道具id].不可交易=true
  end
  if self.数据[道具id].总类==1001 then
      self.数据[道具id].不可交易=true
      self.数据[道具id].专用="专用"
  end
  if 专用~=nil then
    self.数据[道具id].专用=id
    self.数据[道具id].不可交易=true
  end
  --print(self.数据[道具id].识别码,666)
  发送数据(玩家数据[id].连接id,3699)
  道具刷新(id)
end

function 道具处理类:卸下灵饰(连接id,id,道具id,道具格子,数据)
  玩家数据[id].角色:卸下灵饰(self.数据[玩家数据[id].角色.数据.灵饰[数据.道具]])
  玩家数据[id].角色.数据[数据.类型][道具格子]=玩家数据[id].角色.数据.灵饰[数据.道具]
  玩家数据[id].角色.数据.灵饰[数据.道具]=nil
  self:刷新道具行囊(id,数据.类型)
  -- 发送数据(玩家数据[id].连接id,3699)
  -- 道具刷新(id)
  发送数据(玩家数据[id].连接id,3503,玩家数据[id].角色:取装备数据())
  发送数据(玩家数据[id].连接id,3506,玩家数据[id].角色:取灵饰数据())
  发送数据(连接id,5506,{玩家数据[id].角色:取气血数据()})
  发送数据(玩家数据[id].连接id,12)
end

function 道具处理类:卸下锦衣(连接id,id,道具id,道具格子,数据)
  玩家数据[id].角色.数据[数据.类型][道具格子]=玩家数据[id].角色.数据.锦衣[数据.道具]
  玩家数据[id].角色.数据.锦衣[数据.道具]=nil
  if self.数据[玩家数据[id].角色.数据[数据.类型][道具格子]].分类==15 then
      玩家数据[id].角色.数据.穿戴锦衣=nil
  elseif self.数据[玩家数据[id].角色.数据[数据.类型][道具格子]].分类==16 then
      玩家数据[id].角色.数据.穿戴足印=nil
  elseif self.数据[玩家数据[id].角色.数据[数据.类型][道具格子]].分类==17 then
      玩家数据[id].角色.数据.穿戴足迹=nil
  end
  玩家数据[id].角色:刷新信息()
  self:刷新道具行囊(id,数据.类型)
  -- 发送数据(玩家数据[id].连接id,3699)
  -- 道具刷新(id)
  发送数据(玩家数据[id].连接id,3530,玩家数据[id].角色:取锦衣数据())
  发送数据(玩家数据[id].连接id,12)
  地图处理类:更新锦衣(id,玩家数据[id].角色:取锦衣数据())

end

function 道具处理类:卸下装备(连接id,id,数据)
  local 道具格子=玩家数据[id].角色:取道具格子1(数据.类型)
  if 道具格子==0 then
    常规提示(id,"您的道具栏物品已经满啦")
    return 0
  end
  if 数据.灵饰 then
    self:卸下灵饰(连接id,id,道具id,道具格子,数据)
    return
  end
  if 数据.锦衣 then
    self:卸下锦衣(连接id,id,道具id,道具格子,数据)
    return
  end
  local 道具id=玩家数据[id].角色.数据.装备[数据.道具]
  if 道具id~=nil and self.数据[道具id]~=nil and self.数据[道具id].耐久 > 0 and self.数据[道具id].耐久 ~= nil then
      玩家数据[id].角色:卸下装备(self.数据[道具id],self.数据[道具id].分类,id)
  end
  玩家数据[id].角色.数据.装备[数据.道具]=nil
  玩家数据[id].角色.数据[数据.类型][道具格子]=道具id
  self:刷新道具行囊(id,数据.类型)
  -- 发送数据(玩家数据[id].连接id,3699)
  -- 道具刷新(id)
  发送数据(玩家数据[id].连接id,3503,玩家数据[id].角色:取装备数据())
  if 数据.道具==3 then
    发送数据(玩家数据[id].连接id,3505)
    地图处理类:更新武器(id)
  end
  发送数据(玩家数据[id].连接id,12)
end

function 道具处理类:佩戴灵饰(连接id,id,道具id,数据)
  local 物品=取物品数据(self.数据[道具id].名称)
  local 级别=物品[5]
  if 级别>玩家数据[id].角色.数据.等级 and self.数据[道具id].特效~="无级别限制" then
    常规提示(id,"#Y你当前的等级不足以佩戴这样的灵饰")
    return
  end
  if 玩家数据[id].角色.数据.灵饰[self.数据[道具id].子类]==nil then
    玩家数据[id].角色.数据.灵饰[self.数据[道具id].子类]=道具id
    玩家数据[id].角色:佩戴灵饰(self.数据[道具id])
    玩家数据[id].角色.数据[数据.类型][数据.道具]=nil
  else
    local 道具id1=玩家数据[id].角色.数据.灵饰[self.数据[道具id].子类]
    玩家数据[id].角色:卸下灵饰(self.数据[道具id1])
    玩家数据[id].角色.数据.灵饰[self.数据[道具id].子类]=道具id
    玩家数据[id].角色:佩戴灵饰(self.数据[道具id])
    玩家数据[id].角色.数据[数据.类型][数据.道具]=道具id1
  end
  self:刷新道具行囊(id,数据.类型)
  发送数据(玩家数据[id].连接id,3503,玩家数据[id].角色:取装备数据())
  发送数据(玩家数据[id].连接id,3506,玩家数据[id].角色:取灵饰数据())
  发送数据(连接id,5506,{玩家数据[id].角色:取气血数据()})
  发送数据(玩家数据[id].连接id,12)
end

function 道具处理类:佩戴锦衣(连接id,id,道具id,数据)
  local 物品=取物品数据(self.数据[道具id].名称)
  if 玩家数据[id].角色.数据.锦衣[self.数据[道具id].子类]==nil then
    玩家数据[id].角色.数据.锦衣[self.数据[道具id].子类]=道具id
    玩家数据[id].角色.数据[数据.类型][数据.道具]=nil
  else
    local 道具id1=玩家数据[id].角色.数据.锦衣[self.数据[道具id].子类]
    玩家数据[id].角色.数据.锦衣[self.数据[道具id].子类]=道具id
    玩家数据[id].角色.数据[数据.类型][数据.道具]=道具id1
  end
  -- 玩家数据[id].角色:穿戴锦衣(self.数据[道具id],self.数据[道具id].分类,id)
  if self.数据[道具id].分类 == 15 then
      玩家数据[id].角色.数据.穿戴锦衣=self.数据[道具id].名称
  elseif self.数据[道具id].分类 == 16 then
      玩家数据[id].角色.数据.穿戴足印=self.数据[道具id].名称
  elseif self.数据[道具id].分类 == 17 then
      玩家数据[id].角色.数据.穿戴足迹=self.数据[道具id].名称
  end
  玩家数据[id].角色:刷新信息()
  self:刷新道具行囊(id,数据.类型)
  发送数据(玩家数据[id].连接id,3530,玩家数据[id].角色:取锦衣数据())
  地图处理类:更新锦衣(id,玩家数据[id].角色:取锦衣数据())
  发送数据(玩家数据[id].连接id,3699)
  道具刷新(id)
  发送数据(玩家数据[id].连接id,12)
end

function 道具处理类:佩戴装备(连接id,id,数据)
  local 道具id=玩家数据[id].角色.数据[数据.类型][数据.道具]
  if self.数据[道具id]~= nil and self.数据[道具id].灵饰 ~= nil and self.数据[道具id].灵饰 then
    self:佩戴灵饰(连接id,id,道具id,数据)
    return
  end
  if self.数据[道具id]~= nil and self.数据[道具id].锦衣~=nil and self.数据[道具id].锦衣 then
      self:佩戴锦衣(连接id,id,道具id,数据)
      return
  end
  local 装备条件
  if self.数据[道具id] == nil or self.数据[道具id].分类 == nil then
    装备条件 =false
  else
  装备条件=self:可装备(self.数据[道具id],self.数据[道具id].分类,数据.角色,id)
  end
  if 装备条件~=true then
    常规提示(id,"#Y你当前的角色无法装备此装备")
    return 0
  else
  --检查是否有装备已经佩戴
    if 玩家数据[id].角色.数据.装备[self.数据[道具id].分类]~=nil then
      local 道具id1=玩家数据[id].角色.数据.装备[self.数据[道具id].分类]
      玩家数据[id].角色:卸下装备(self.数据[道具id1],self.数据[道具id1].分类,id)
      玩家数据[id].角色.数据.装备[self.数据[道具id].分类]= 道具id
      玩家数据[id].角色:穿戴装备(self.数据[道具id],self.数据[道具id].分类,id)
      玩家数据[id].角色.数据[数据.类型][数据.道具]=道具id1
    else
      玩家数据[id].角色.数据.装备[self.数据[道具id].分类]= 道具id
      玩家数据[id].角色:穿戴装备(self.数据[道具id],self.数据[道具id].分类,id)
      玩家数据[id].角色.数据[数据.类型][数据.道具]=nil
    end
  end
  self:刷新道具行囊(id,数据.类型)
  发送数据(玩家数据[id].连接id,3503,玩家数据[id].角色:取装备数据())
  if self.数据[道具id].分类==3 and 玩家数据[id].角色.数据.装备[3] ~= nil then
    发送数据(玩家数据[id].连接id,3504)
    地图处理类:更新武器(id,self.数据[玩家数据[id].角色.数据.装备[3]])
  end
  发送数据(玩家数据[id].连接id,12 )
end

function 道具处理类:可装备(i1,i2,类型,id)
  if i2 > 6 and 类型 == "主角" then
    return "#Y/该装备与你的种族不符"
  elseif i2 < 6 and 类型 == "召唤兽" then
    return "#Y/召唤兽不能穿戴该装备"
  end
  if i1.总类 ~= 2 then
    return "#Y/这个物品不可以装备"
  end
  if i1.专用~=nil and i1.专用~=id then
   return "#Y/你无法佩戴他人的专用装备"
  end
  if i1.鉴定==false then
      return "#Y/该装备未鉴定，无法佩戴"
  end
  if i1.耐久==nil then
      i1.耐久=500
  end
  if i1.耐久<=0 and i1.耐久~=nil then
      return "#Y/该装备耐久不足，无法穿戴"
  end
  if i1.修理失败~=nil and i1.修理失败==3 and i1.耐久<=0 then
      return "#Y/该装备因修理失败过度，而无法使用！"
  end
  if i1 ~= nil and i1.分类 == i2 then
    if i2 == 1 or i2 == 4 then
      if i1.性别限制 ~= 0 and i1.性别限制 == 玩家数据[id].角色.数据.性别 then
          if (i1.级别限制 == 0 or i1.特效 == "无级别限制" or 玩家数据[id].角色.数据.等级 >= i1.级别限制 or i1.第二特效 == "无级别限制") then
            return true
          elseif (i1.特效 == "简易" or i1.第二特效 == "简易") and 玩家数据[id].角色.数据.等级+5 >= i1.级别限制 then
            return true
          else
          if 玩家数据[id].角色.数据.等级 < i1.级别限制 then
            return "#Y/你的等级不够呀"
          end
        end
      else
        return "#Y/该装备您无法使用呀"
      end
    elseif i2 == 2 or i2 == 5 or i2 == 6 then
      if (i1.级别限制 == 0 or i1.特效 == "无级别限制" or 玩家数据[id].角色.数据.等级 >= i1.级别限制 or i1.第二特效 == "无级别限制") then
        return true
       elseif (i1.特效 == "简易" or i1.第二特效 == "简易") and 玩家数据[id].角色.数据.等级+5 >= i1.级别限制 then
            return true
      else
        if i1.级别限制 > tonumber(玩家数据[id].角色.数据.等级) then
          return "#Y/你的等级不够呀"
        end
      end
    elseif i2 == 3 then
      if i1.角色限制 ~= 0 and (i1.角色限制[1] == 玩家数据[id].角色.数据.模型 or i1.角色限制[2] == 玩家数据[id].角色.数据.模型) then
          if (i1.级别限制 == 0 or i1.特效 == "无级别限制" or 玩家数据[id].角色.数据.等级 >= i1.级别限制 or i1.第二特效 == "无级别限制") then
            return true
          elseif (i1.特效 == "简易" or i1.第二特效 == "简易") and 玩家数据[id].角色.数据.等级+5 >= i1.级别限制 then
            return true
          else
          if 玩家数据[id].角色.数据.等级 < i1.级别限制 then
            return "#Y/你的等级不够呀"
          end
        end
      else
        return "#Y/该装备您无法使用呀"
      end
    end
  end
  return false
end

function 道具处理类:加载数据(账号,数字id)
  self.数字id=数字id
  self.数据=table.loadstring(读入文件([[data/]]..账号..[[/]]..数字id..[[/道具.txt]]))
  for n, v in pairs(self.数据) do
    if self.数据[n].名称==nil then
      self.数据[n]=nil
    end
    if n~=nil and self.数据[n]~=nil and self.数据[n].名称~=nil and self.数据[n].名称=="帮派银票" then
      local 是否存在 = false
      for i=1,20 do
        if 玩家数据[数字id].角色.数据.道具[i] ~= nil and 玩家数据[数字id].角色.数据.道具[i] == n then
          是否存在 = true
        end
      end
      if 是否存在 == false then
        self.数据[n] = nil
      end
    end
  end
end

function 道具处理类:取新编号()
  for n, v in pairs(self.数据) do
    if self.数据[n]==nil then
      return n
    end
  end
  return #self.数据+1
end
function 道具处理类:更新(dt) end

function 道具处理类:丢弃道具(连接id,id,数据)
  local 丢弃类型=数据.类型
  if self.数据[玩家数据[id].角色.数据[数据.类型][数据.物品]].名称=="帮派银票" then
      常规提示(id,"#Y该物品无法丢弃")
      self:刷新道具行囊(id,数据.类型)
      return
  end
  if self.数据[玩家数据[id].角色.数据[数据.类型][数据.物品]].总类=="跑商商品" then
      常规提示(id,"#Y该物品无法丢弃")
      self:刷新道具行囊(id,数据.类型)
      return
  end
  if self.数据[玩家数据[id].角色.数据[数据.类型][数据.物品]].名称 == "逍遥镜" then
    if self.数据[玩家数据[id].角色.数据[数据.类型][数据.物品]].绑定孩子 ~= nil then
      local 编号=玩家数据[id].孩子:取编号(self.数据[玩家数据[id].角色.数据[数据.类型][数据.物品]].绑定孩子.认证码)
      if 编号 ~= 0 then
        玩家数据[id].孩子.数据[编号].已携带 = nil
        常规提示(id,"#Y该道具内的孩子以及被自动回到身上")
      end
    end
  end
  if self.数据[玩家数据[id].角色.数据[数据.类型][数据.物品]].识别码==nil then
    self.数据[玩家数据[id].角色.数据[数据.类型][数据.物品]].识别码="无法识别"
  end
  玩家数据[id].角色:日志记录("丢弃道具["..self.数据[玩家数据[id].角色.数据[数据.类型][数据.物品]].名称.."],道具识别码为"..self.数据[玩家数据[id].角色.数据[数据.类型][数据.物品]].识别码)
  self.数据[玩家数据[id].角色.数据[数据.类型][数据.物品]]=nil
  玩家数据[id].角色.数据[数据.类型][数据.物品]=nil
  --print(self.数据.类型,55)
  if 丢弃类型=="法宝" then
    self:索要法宝(连接id,id)
  else
    self:刷新道具行囊(id,数据.类型)
  end
end

function 道具处理类:出售道具(连接id,id,数据)
  if 玩家数据[id].角色.数据[数据.类型][数据.物品] == nil then
      常规提示(id,"#Y该物品不存在")
      return
  end
  local 物品名称 = self.数据[玩家数据[id].角色.数据[数据.类型][数据.物品]].名称
  local 物品数量 = 1
  local 出售价格 = 1
  local 出售总价 = 0
  if self.数据[玩家数据[id].角色.数据[数据.类型][数据.物品]].名称=="帮派银票" then
      常规提示(id,"#Y该物品无法出售")
      self:刷新道具行囊(id,数据.类型)
      return
  end
  if tonumber(f函数.读配置(程序目录.."Shopping.ini","自定义出售",物品名称)) == nil then
      常规提示(id,"#Y该物品无法出售")
      self:刷新道具行囊(id,数据.类型)
      return
  else
    出售价格 = tonumber(f函数.读配置(程序目录.."Shopping.ini","自定义出售",物品名称))
    if self.数据[玩家数据[id].角色.数据[数据.类型][数据.物品]].数量 ~= nil then
      物品数量 = self.数据[玩家数据[id].角色.数据[数据.类型][数据.物品]].数量
    end
    出售总价 = 出售价格*物品数量
    if self.数据[玩家数据[id].角色.数据[数据.类型][数据.物品]].识别码==nil then
      self.数据[玩家数据[id].角色.数据[数据.类型][数据.物品]].识别码="无法识别"
    end
    玩家数据[id].角色:添加银子(出售总价,"系统出售",1)
    玩家数据[id].角色:日志记录("出售道具["..self.数据[玩家数据[id].角色.数据[数据.类型][数据.物品]].名称.."],道具识别码为"..self.数据[玩家数据[id].角色.数据[数据.类型][数据.物品]].识别码)
    self.数据[玩家数据[id].角色.数据[数据.类型][数据.物品]]=nil
    玩家数据[id].角色.数据[数据.类型][数据.物品]=nil
    self:刷新道具行囊(id,数据.类型)
  end
end

function 道具处理类:刷新道具行囊(id,数据)
  if 数据=="道具" then
    self:索要道具(玩家数据[id].连接id,id)
  else
    self:索要行囊(玩家数据[id].连接id,id)
  end
  发送数据(玩家数据[id].连接id,3699)
  道具刷新(id)
end

function 道具处理类:道具格子互换(连接id,id,数据)
  if 数据.放置id == nil or 数据.抓取id == nil or 数据.放置类型 == nil or 数据.抓取类型 == nil then
    return
  end
  if 数据.放置类型==数据.抓取类型 and 数据.放置id==数据.抓取id then
    发送数据(连接id,3699)
    道具刷新(id)
    return
  end
  if 数据.放置类型~=数据.抓取类型 and self.数据[玩家数据[id].角色.数据[数据.抓取类型][数据.抓取id]].总类==1000 then
    if self.数据[玩家数据[id].角色.数据[数据.抓取类型][数据.抓取id]].分类~=1 then
      常规提示(id,"#Y只有一级法宝才可以移动")
      return
    end
  end
  if 数据.放置类型~=数据.抓取类型 and 数据.抓取类型=="法宝" and 玩家数据[id].角色.数据[数据.放置类型][数据.放置id] ~= nil and  self.数据[玩家数据[id].角色.数据[数据.放置类型][数据.放置id]].总类~= 1000 then
      常规提示(id,"#Y法宝栏只可以放入法宝哟")
      return
  end
  if 数据.放置类型~=数据.抓取类型 and 玩家数据[id].角色.数据[数据.放置类型][数据.放置id] ~= nil and  (self.数据[玩家数据[id].角色.数据[数据.放置类型][数据.放置id]].总类== "帮派银票" or  self.数据[玩家数据[id].角色.数据[数据.放置类型][数据.放置id]].总类== "跑商商品") then
      常规提示(id,"#Y该物品无法放入行囊")
      return
  end
  if 数据.放置类型~=数据.抓取类型 and 玩家数据[id].角色.数据[数据.抓取类型][数据.抓取id] ~= nil and  (self.数据[玩家数据[id].角色.数据[数据.抓取类型][数据.抓取id]].总类== "帮派银票" or  self.数据[玩家数据[id].角色.数据[数据.抓取类型][数据.抓取id]].总类== "跑商商品") then
      常规提示(id,"#Y该物品无法放入道具")
      return
  end
  if 数据.放置类型=="行囊" and self.数据[玩家数据[id].角色.数据[数据.抓取类型][数据.抓取id]].总类=="帮派银票" then
      常规提示(id,"#Y帮派银票无法放入行囊")
      return
  end
  if 数据.放置类型=="法宝" and self.数据[玩家数据[id].角色.数据[数据.抓取类型][数据.抓取id]].总类~=1000 then
    常规提示(id,"#Y法宝栏只可以放入法宝哟")
    return
  end
  if 玩家数据[id].角色.数据[数据.放置类型][数据.放置id]==nil then --没有道具
    玩家数据[id].角色.数据[数据.放置类型][数据.放置id]=玩家数据[id].角色.数据[数据.抓取类型][数据.抓取id]
    玩家数据[id].角色.数据[数据.抓取类型][数据.抓取id]=nil
  else
    self.允许互换=true
    local 放置id=玩家数据[id].角色.数据[数据.放置类型][数据.放置id]
    local 抓取id=玩家数据[id].角色.数据[数据.抓取类型][数据.抓取id]
    if 放置id~=nil and 抓取id~=nil and self.数据[抓取id].数量~=nil and self.数据[放置id].数量~=nil and self.数据[放置id].名称==self.数据[抓取id].名称 then
      if self.数据[抓取id].数量<99 and self.数据[放置id].数量<99 then
        if self.数据[抓取id].阶品~= nil and self.数据[放置id].阶品~=nil and self.数据[抓取id].阶品~=self.数据[放置id].阶品 then
          常规提示(id,"#Y不同阶品的物品，无法叠加")
          发送数据(连接id,3699)
          道具刷新(id)
          return
        elseif self.数据[抓取id].食材~= nil and self.数据[放置id].食材~=nil and self.数据[抓取id].食材~=self.数据[放置id].食材 then
          常规提示(id,"#Y不同食材的元宵，无法叠加")
          发送数据(连接id,3699)
          道具刷新(id)
          return
        end
        if self.数据[抓取id].数量+self.数据[放置id].数量<=99 then
          self.数据[放置id].数量=self.数据[放置id].数量+self.数据[抓取id].数量
          self.数据[抓取id]=nil
          玩家数据[id].角色.数据[数据.抓取类型][数据.抓取id]=nil
          self.允许互换=false
        else
          local 临时数量=self.数据[放置id].数量+self.数据[抓取id].数量-99
          self.数据[放置id].数量=99
          self.数据[抓取id].数量=临时数量
          self.允许互换=false
        end
      end
    end
    if self.允许互换 then
      玩家数据[id].角色.数据[数据.放置类型][数据.放置id]=玩家数据[id].角色.数据[数据.抓取类型][数据.抓取id]
      玩家数据[id].角色.数据[数据.抓取类型][数据.抓取id]=放置id
    end
  end
  if 数据.放置类型=="道具" then
    self:索要道具(连接id,id)
  elseif 数据.放置类型=="法宝" then
    self:索要法宝(连接id,id)
  else
    self:索要行囊(连接id,id)
  end
  发送数据(连接id,3699)
  道具刷新(id)
end


function 道具处理类:道具格子互换1(连接id,id,数据)
  local 放置id = 玩家数据[id].角色:取道具格子1(数据.放置类型)
  if 放置id  == 0 then
    常规提示(id,"#Y"..数据.放置类型.."已满！")
    道具刷新(id)
    return
  end
  if 数据.放置类型==数据.抓取类型 then
    发送数据(连接id,3699)
    return
  end
  if 玩家数据[id].角色.数据[数据.抓取类型] == nil or 玩家数据[id].角色.数据[数据.抓取类型][数据.抓取id] == nil or self.数据[玩家数据[id].角色.数据[数据.抓取类型][数据.抓取id]] == nil then
    发送数据(连接id,3699)
    return
  end
  if self.数据[玩家数据[id].角色.数据[数据.抓取类型][数据.抓取id]].总类==1000 and 数据.放置类型~=数据.抓取类型 then
    if self.数据[玩家数据[id].角色.数据[数据.抓取类型][数据.抓取id]].分类~=1 then
      发送数据(连接id,3699)
      常规提示(id,"#Y只有一级法宝才可以移动")
      return
    end
  end
  if 数据.放置类型~="道具" and 数据.放置类型~="行囊" and 数据.放置类型~="法宝" then
    发送数据(连接id,3699)
    return
  end
  if 数据.抓取类型~="道具" and 数据.抓取类型~="行囊" and 数据.抓取类型~="法宝" then
    发送数据(连接id,3699)
    return
  end
  if 数据.放置类型=="法宝" and self.数据[玩家数据[id].角色.数据[数据.抓取类型][数据.抓取id]].总类~=1000 then
    发送数据(连接id,3699)
    常规提示(id,"#Y法宝栏只可以放入法宝哟")
    return
  end
  if 数据.放置类型=="行囊" and (self.数据[玩家数据[id].角色.数据[数据.抓取类型][数据.抓取id]].总类=="帮派银票" or  self.数据[玩家数据[id].角色.数据[数据.抓取类型][数据.抓取id]].总类== "跑商商品") then
    发送数据(连接id,3699)
    常规提示(id,"#Y帮派银票以及跑商物品无法放入行囊")
    return
  end
  if 放置id~=0 then --没有道具
    玩家数据[id].角色.数据[数据.放置类型][放置id]=玩家数据[id].角色.数据[数据.抓取类型][数据.抓取id]
    玩家数据[id].角色.数据[数据.抓取类型][数据.抓取id]=nil
    if 数据.放置类型=="道具" then
      self:索要道具(连接id,id)
    elseif 数据.放置类型=="法宝" then
      self:索要法宝(连接id,id)
    else
      self:索要行囊(连接id,id)
    end
    发送数据(连接id,3699)
    道具刷新(id)
  end
end

function 道具处理类:索要法宝(连接id,id)
  self.发送数据={法宝={},佩戴={}}
  for n=1,20 do
    if 玩家数据[id].角色.数据.法宝[n]~=nil then
      if self.数据[玩家数据[id].角色.数据.法宝[n]]==nil then
        玩家数据[id].角色.数据.法宝[n]=nil
      else
        self.发送数据.法宝[n]=table.loadstring(table.tostring(self.数据[玩家数据[id].角色.数据.法宝[n]]))
      end
    end
  end
  for n=1,3 do
    if 玩家数据[id].角色.数据.法宝佩戴[n]~=nil then
      self.发送数据.佩戴[n]=table.loadstring(table.tostring(self.数据[玩家数据[id].角色.数据.法宝佩戴[n]]))
    end
  end
  发送数据(连接id,3527,self.发送数据)
end

function 道具处理类:索要道具(连接id,id)
  self.发送数据={道具={}}
  for n=1,20 do
    if 玩家数据[id].角色.数据.道具[n]~=nil then
      for i=1,20 do
        if i ~= n and 玩家数据[id].角色.数据.道具[i] ~= nil and 玩家数据[id].角色.数据.道具[i] == 玩家数据[id].角色.数据.道具[n] then
          玩家数据[id].角色.数据.道具[i] = nil
        end
      end
    end
  end
  for n=1,20 do
    if 玩家数据[id].角色.数据.道具[n]~=nil then
      if self.数据[玩家数据[id].角色.数据.道具[n]]==nil then
        玩家数据[id].角色.数据.道具[n]=nil
      else
        self.发送数据.道具[n]=table.loadstring(table.tostring(self.数据[玩家数据[id].角色.数据.道具[n]]))
      end
    end
  end
  self.发送数据.体力=玩家数据[id].角色.数据.体力
  self.发送数据.银子=玩家数据[id].角色.数据.银子
  self.发送数据.储备=玩家数据[id].角色.数据.储备
  self.发送数据.存银=玩家数据[id].角色.数据.存银
  发送数据(连接id,3501,self.发送数据)
end

function 道具处理类:索要道具1(id)
  self.发送数据={道具={}}
  for n=1,20 do
    if 玩家数据[id].角色.数据.道具[n]~=nil then
      if self.数据[玩家数据[id].角色.数据.道具[n]]==nil then
        玩家数据[id].角色.数据.道具[n]=nil
      else
        self.发送数据.道具[n]=table.loadstring(table.tostring(self.数据[玩家数据[id].角色.数据.道具[n]]))
      end
    end
  end
  self.发送数据.体力=玩家数据[id].角色.数据.体力
  self.发送数据.银子=玩家数据[id].角色.数据.银子
  self.发送数据.储备=玩家数据[id].角色.数据.储备
  self.发送数据.存银=玩家数据[id].角色.数据.存银
  return self.发送数据
end

function 道具处理类:索要道具2(id)
  self.发送数据={道具={}}
  for n=1,20 do
    if 玩家数据[id].角色.数据.道具[n]~=nil then
      if self.数据[玩家数据[id].角色.数据.道具[n]]==nil then
        玩家数据[id].角色.数据.道具[n]=nil
      else
        self.发送数据.道具[n]=table.loadstring(table.tostring(self.数据[玩家数据[id].角色.数据.道具[n]]))
      end
    end
  end
  return self.发送数据
end

function 道具处理类:索要道具3(id)
  self.发送数据 = {道具={}}
  for n = 1, 20 do
    if 玩家数据[id].角色.数据.道具[n] ~= nil and self.数据[玩家数据[id].角色.数据.道具[n]] ~= nil then
      self.发送数据.道具[n]=table.loadstring(table.tostring(self.数据[玩家数据[id].角色.数据.道具[n]]))
    end
  end
  self.发送数据.体力=玩家数据[id].角色.数据.体力
  self.发送数据.银子=玩家数据[id].角色.数据.银子
  self.发送数据.储备=玩家数据[id].角色.数据.储备
  self.发送数据.存银=玩家数据[id].角色.数据.存银

  return self.发送数据
end

function 道具处理类:重置法宝回合(id)
  for n=1,20 do
    if 玩家数据[id].角色.数据.法宝[n]~=nil then
      if self.数据[玩家数据[id].角色.数据.法宝[n]]==nil then
        玩家数据[id].角色.数据.法宝[n]=nil
      else
        self.数据[玩家数据[id].角色.数据.法宝[n]].回合=nil
      end
    end
  end
end

function 道具处理类:索要法宝2(id,回合)
  self.发送数据={道具={}}
  for n=1,20 do
    if 玩家数据[id].角色.数据.法宝[n]~=nil then
      if self.数据[玩家数据[id].角色.数据.法宝[n]]==nil then
        玩家数据[id].角色.数据.法宝[n]=nil
      else
        self.发送数据.道具[n]=table.loadstring(table.tostring(self.数据[玩家数据[id].角色.数据.法宝[n]]))
        if self.发送数据.道具[n].回合~=nil then
          if self.发送数据.道具[n].回合<=回合 then
            self.发送数据.道具[n].回合=nil
          else
            self.发送数据.道具[n].回合=self.发送数据.道具[n].回合-回合
          end
        end
      end
    end
  end
  self.发送数据.银子=玩家数据[id].角色.数据.银子
  self.发送数据.储备=玩家数据[id].角色.数据.储备
  self.发送数据.存银=玩家数据[id].角色.数据.存银
  return self.发送数据
end

function 道具处理类:索要法宝1(id,回合)
  self.发送数据={道具={}}
  for n=1,20 do
    if 玩家数据[id].角色.数据.法宝[n]~=nil then
      if self.数据[玩家数据[id].角色.数据.法宝[n]]==nil then
        玩家数据[id].角色.数据.法宝[n]=nil
      else
        self.发送数据.道具[n]=table.loadstring(table.tostring(self.数据[玩家数据[id].角色.数据.法宝[n]]))
        if self.发送数据.道具[n].回合~=nil then
          if self.发送数据.道具[n].回合<=回合 then
            self.发送数据.道具[n].回合=nil
          else
            self.发送数据.道具[n].回合=self.发送数据.道具[n].回合-回合
          end
        end
      end
    end
  end
  return self.发送数据
end

function 道具处理类:索要仓库道具(id,页)
  self.发送数据={道具={}}
  for n=1,20 do
    if 玩家数据[id].角色.数据.道具仓库[页][n]~=nil then
      if self.数据[玩家数据[id].角色.数据.道具仓库[页][n]]==nil then
        玩家数据[id].角色.数据.道具仓库[页][n]=nil
      else
        self.发送数据.道具[n]=table.loadstring(table.tostring(self.数据[玩家数据[id].角色.数据.道具仓库[页][n]]))
      end
    end
  end
  return self.发送数据
end

function 道具处理类:索要商会道具(id,页)
  self.发送数据={道具={}}
  for n=1,20 do
    if 商会数据[id][1].店面[页][n]~=nil then
      self.发送数据.道具[n]=table.loadstring(table.tostring(self.数据[商会数据[id][1].店面[页][n].id]))
    end
  end
  return self.发送数据
end

function 道具处理类:索要行囊(连接id,id)
 self.发送数据={道具={}}
  for n=1,20 do
    if 玩家数据[id].角色.数据.行囊[n]~=nil then
      if self.数据[玩家数据[id].角色.数据.行囊[n]]==nil then
        玩家数据[id].角色.数据.行囊[n]=nil
      else
        self.发送数据.道具[n]=table.loadstring(table.tostring(self.数据[玩家数据[id].角色.数据.行囊[n]]))
      end
    end
  end
  self.发送数据.银子=玩家数据[id].角色.数据.银子
  self.发送数据.储备=玩家数据[id].角色.数据.储备
  self.发送数据.存银=玩家数据[id].角色.数据.存银
  发送数据(连接id,3502,self.发送数据)
end

function 道具处理类:帮派点修处理(连接id,数字id,数据)
    local 消耗银子 = 0
    local 帮派编号 = 玩家数据[数字id].角色.数据.帮派数据.编号
    local 帮派资材 = 帮派数据[帮派编号].帮派资材.当前
    local 帮贡上限 = 帮派数据[帮派编号].成员数据[数字id].帮贡.上限
    if 数据.修炼项目 == "攻击修炼" or 数据.修炼项目 == "法术修炼" or 数据.修炼项目 == "猎术修炼" then
        消耗银子 = 30000
    else
        消耗银子 = 20000
    end
    if 风雨无言定制 then
      消耗银子 = 50000
    end
    if 数据.修炼项目 == nil then
      常规提示(数字id,"#Y/请选择你要提升的修炼")
      return
    end
    if 玩家数据[数字id].角色.数据.修炼[数据.修炼项目][1]>=玩家数据[数字id].角色.数据.修炼[数据.修炼项目][3] then
      常规提示(数字id,"#Y/你的此项修炼已经达上限")
      return
    end
    if 取银子(数字id) < 消耗银子 then
        常规提示(数字id,"#Y/你的当前的银子不够修炼哦")
        return
    end
    if 玩家数据[数字id].角色.数据.修炼[数据.修炼项目][1] > qz(帮贡上限/150) then
        常规提示(数字id,"#Y/当前的帮贡上限无法提升修炼等级")
        return
    end
    if 风雨无言定制 then
    else
      if 帮派资材 < 5 then
        常规提示(数字id,"#Y/贵帮当前的资材不足，无法进行帮派点修")
        return
      end
      帮派数据[帮派编号].帮派资材.当前 = 帮派数据[帮派编号].帮派资材.当前 -5
    end
    玩家数据[数字id].角色:扣除银子(消耗银子,0,0,"帮派点修",1)
    玩家数据[数字id].角色:帮派添加人物修炼经验(数字id,10,数据.修炼项目)
end

function 道具处理类:比武奖励(id,分组)
  if 比武大会数据[分组]==nil then
    常规提示(id,"你没有这样的奖励可以领取")
    return 0
  elseif 比武大会数据[分组][id]==nil then
    常规提示(id,"你没有这样的奖励可以领取")
    return 0
  elseif 比武大会数据[分组][id].奖励==false then
    常规提示(id,"你没有这样的奖励可以领取")
    return 0
  else
    local 书铁种类=取随机数(1,#书铁范围)
    比武大会数据[分组][id].奖励=false
    self.经验奖励=math.floor(玩家数据[id].角色.数据.等级*玩家数据[id].角色.数据.等级*玩家数据[id].角色.数据.等级)
    self.银子奖励=比武大会数据[分组][id].积分*20000+100000
    玩家数据[id].角色:添加经验(self.经验奖励,"比武大会奖励")
    玩家数据[id].角色:添加银子(self.银子奖励,"比武大会奖励",1)
    常规提示(id,"你领取了比武大会奖励")
    if 分组=="精锐组" then
      if 比武大会[分组][1]~=nil and 比武大会[分组][1].id==id then
          玩家数据[id].角色:添加称谓(id,"英雄会精锐状元")
          添加仙玉(500,玩家数据[id].账号,id,"英雄比武大会")
          self:给予道具(id,"灵饰指南书",{6})
          self:给予道具(id,"元灵晶石",{6})
          self:给予道具(id,"制造指南书",60,书铁种类)
          self:给予道具(id,"百炼精铁",60,书铁种类)
      end
      if 比武大会[分组][2]~=nil and 比武大会[分组][2].id==id then
          玩家数据[id].角色:添加称谓(id,"英雄会精锐榜眼")
          添加仙玉(400,玩家数据[id].账号,id,"英雄比武大会")
          self:给予道具(id,"灵饰指南书",{6})
          self:给予道具(id,"元灵晶石",{6})
      end
      if 比武大会[分组][3]~=nil and 比武大会[分组][3].id==id then
          玩家数据[id].角色:添加称谓(id,"英雄会精锐探花")
          添加仙玉(300,玩家数据[id].账号,id,"英雄比武大会")
          self:给予道具(id,"制造指南书",60,书铁种类)
          self:给予道具(id,"百炼精铁",60,书铁种类)
      end
    elseif 分组=="勇武组" then
      if 比武大会[分组][1]~=nil and 比武大会[分组][1].id==id then
          玩家数据[id].角色:添加称谓(id,"英雄会勇武状元")
          添加仙玉(600,玩家数据[id].账号,id,"英雄比武大会")
          self:给予道具(id,"灵饰指南书",{8})
          self:给予道具(id,"元灵晶石",{8})
          self:给予道具(id,"制造指南书",80,书铁种类)
          self:给予道具(id,"百炼精铁",80,书铁种类)
      end
      if 比武大会[分组][2]~=nil and 比武大会[分组][2].id==id then
          玩家数据[id].角色:添加称谓(id,"英雄会勇武榜眼")
          添加仙玉(500,玩家数据[id].账号,id,"英雄比武大会")
          self:给予道具(id,"灵饰指南书",{8})
          self:给予道具(id,"元灵晶石",{8})
      end
      if 比武大会[分组][3]~=nil and 比武大会[分组][3].id==id then
          玩家数据[id].角色:添加称谓(id,"英雄会勇武探花")
          添加仙玉(400,玩家数据[id].账号,id,"英雄比武大会")
          self:给予道具(id,"制造指南书",80,书铁种类)
          self:给予道具(id,"百炼精铁",80,书铁种类)
      end
    elseif 分组=="神威组" then
      if 比武大会[分组][1]~=nil and 比武大会[分组][1].id==id then
          玩家数据[id].角色:添加称谓(id,"英雄会神威状元")
          添加仙玉(700,玩家数据[id].账号,id,"英雄比武大会")
          self:给予道具(id,"灵饰指南书",{10})
          self:给予道具(id,"元灵晶石",{10})
          self:给予道具(id,"制造指南书",100,书铁种类)
          self:给予道具(id,"百炼精铁",100,书铁种类)
      end
      if 比武大会[分组][2]~=nil and 比武大会[分组][2].id==id then
          玩家数据[id].角色:添加称谓(id,"英雄会神威榜眼")
          添加仙玉(600,玩家数据[id].账号,id,"英雄比武大会")
          self:给予道具(id,"灵饰指南书",{10})
          self:给予道具(id,"元灵晶石",{10})
      end
      if 比武大会[分组][3]~=nil and 比武大会[分组][3].id==id then
          玩家数据[id].角色:添加称谓(id,"英雄会神威探花")
          添加仙玉(500,玩家数据[id].账号,id,"英雄比武大会")
          self:给予道具(id,"制造指南书",100,书铁种类)
          self:给予道具(id,"百炼精铁",100,书铁种类)
      end
    elseif 分组=="天科组" then
      if 比武大会[分组][1]~=nil and 比武大会[分组][1].id==id then
          玩家数据[id].角色:添加称谓(id,"英雄会天科状元")
          添加仙玉(800,玩家数据[id].账号,id,"英雄比武大会")
          self:给予道具(id,"灵饰指南书",{12})
          self:给予道具(id,"元灵晶石",{12})
          self:给予道具(id,"制造指南书",120,书铁种类)
          self:给予道具(id,"百炼精铁",120,书铁种类)
      end
      if 比武大会[分组][2]~=nil and 比武大会[分组][2].id==id then
          玩家数据[id].角色:添加称谓(id,"英雄会天科榜眼")
          添加仙玉(700,玩家数据[id].账号,id,"英雄比武大会")
          self:给予道具(id,"灵饰指南书",{12})
          self:给予道具(id,"元灵晶石",{12})
      end
      if 比武大会[分组][3]~=nil and 比武大会[分组][3].id==id then
          玩家数据[id].角色:添加称谓(id,"英雄会天科探花")
          添加仙玉(600,玩家数据[id].账号,id,"英雄比武大会")
          self:给予道具(id,"制造指南书",120,书铁种类)
          self:给予道具(id,"百炼精铁",120,书铁种类)
      end
    elseif 分组=="天启组" then
      if 比武大会[分组][1]~=nil and 比武大会[分组][1].id==id then
          玩家数据[id].角色:添加称谓(id,"英雄会天启状元")
          添加仙玉(900,玩家数据[id].账号,id,"英雄比武大会")
          self:给予道具(id,"灵饰指南书",{14})
          self:给予道具(id,"元灵晶石",{14})
          self:给予道具(id,"制造指南书",140,书铁种类)
          self:给予道具(id,"百炼精铁",140,书铁种类)
      end
      if 比武大会[分组][2]~=nil and 比武大会[分组][2].id==id then
          玩家数据[id].角色:添加称谓(id,"英雄会天启榜眼")
          添加仙玉(800,玩家数据[id].账号,id,"英雄比武大会")
          self:给予道具(id,"灵饰指南书",{14})
          self:给予道具(id,"元灵晶石",{14})
      end
      if 比武大会[分组][3]~=nil and 比武大会[分组][3].id==id then
          玩家数据[id].角色:添加称谓(id,"英雄会天启探花")
          添加仙玉(700,玩家数据[id].账号,id,"英雄比武大会")
          self:给予道具(id,"制造指南书",140,书铁种类)
          self:给予道具(id,"百炼精铁",140,书铁种类)
      end
    elseif 分组=="天元组" then
      if 比武大会[分组][1]~=nil and 比武大会[分组][1].id==id then
          玩家数据[id].角色:添加称谓(id,"英雄会天元状元")
          添加仙玉(1000,玩家数据[id].账号,id,"英雄比武大会")
          self:给予道具(id,"灵饰指南书",{14})
          self:给予道具(id,"元灵晶石",{14})
          self:给予道具(id,"制造指南书",150,书铁种类)
          self:给予道具(id,"百炼精铁",150,书铁种类)
      end
      if 比武大会[分组][2]~=nil and 比武大会[分组][2].id==id then
          玩家数据[id].角色:添加称谓(id,"英雄会天元榜眼")
          添加仙玉(900,玩家数据[id].账号,id,"英雄比武大会")
          self:给予道具(id,"灵饰指南书",{14})
          self:给予道具(id,"元灵晶石",{14})
      end
      if 比武大会[分组][3]~=nil and 比武大会[分组][3].id==id then
          玩家数据[id].角色:添加称谓(id,"英雄会天元探花")
          添加仙玉(800,玩家数据[id].账号,id,"英雄比武大会")
          self:给予道具(id,"制造指南书",150,书铁种类)
          self:给予道具(id,"百炼精铁",150,书铁种类)
      end
    end
    if 玩家数据[id].角色.数据.比武积分.总积分>=40 and 玩家数据[id].角色.数据.等级>=50 then
      玩家数据[id].角色:添加称谓(id,"江湖小虾")
    elseif 玩家数据[id].角色.数据.比武积分.总积分>=80 and 玩家数据[id].角色.数据.等级>=60 then
      玩家数据[id].角色:删除称谓(id,"江湖小虾")
      玩家数据[id].角色:添加称谓(id,"明日之星")
    elseif 玩家数据[id].角色.数据.比武积分.总积分>=140 and 玩家数据[id].角色.数据.等级>=70 then
      玩家数据[id].角色:删除称谓(id,"明日之星")
      玩家数据[id].角色:添加称谓(id,"武林高手")
    elseif 玩家数据[id].角色.数据.比武积分.总积分>=200 and 玩家数据[id].角色.数据.等级>=80 then
      玩家数据[id].角色:删除称谓(id,"武林高手")
      玩家数据[id].角色:添加称谓(id,"绝世奇才")
    elseif 玩家数据[id].角色.数据.比武积分.总积分>=280 and 玩家数据[id].角色.数据.等级>=90 then
      玩家数据[id].角色:删除称谓(id,"绝世奇才")
      玩家数据[id].角色:添加称谓(id,"威震三界")
    elseif 玩家数据[id].角色.数据.比武积分.总积分>=400 and 玩家数据[id].角色.数据.等级>=100 then
      玩家数据[id].角色:删除称谓(id,"威震三界")
      if 玩家数据[id].角色.数据.性别=="男" then
          玩家数据[id].角色:添加称谓(id,"盖世英雄")
      else
          玩家数据[id].角色:添加称谓(id,"绝代佳人")
      end
    elseif 玩家数据[id].角色.数据.比武积分.总积分>=3000 and 玩家数据[id].角色.数据.等级>=100 then
      if 玩家数据[id].角色.数据.性别=="男" then
        玩家数据[id].角色:删除称谓(id,"盖世英雄")
        玩家数据[id].角色:添加称谓(id,"气吞山河")
      else
        玩家数据[id].角色:删除称谓(id,"绝代佳人")
        玩家数据[id].角色:添加称谓(id,"绝世独立")
      end
    elseif 玩家数据[id].角色.数据.比武积分.总积分>=5000 and 玩家数据[id].角色.数据.等级>=155 then
      if 玩家数据[id].角色.数据.性别=="男" then
        玩家数据[id].角色:删除称谓(id,"气吞山河")
        玩家数据[id].角色:添加称谓(id,"战天斗地")
      else
        玩家数据[id].角色:删除称谓(id,"绝世独立")
        玩家数据[id].角色:添加称谓(id,"姑射神人")
      end
    end
  end
end

function 道具处理类:首席争霸奖励(id,门派)
  if 首席争霸数据[门派]==nil then
    常规提示(id,"你没有这样的奖励可以领取")
    return 0
  elseif 首席争霸数据[门派][id]==nil then
    常规提示(id,"你没有这样的奖励可以领取")
    return 0
  elseif 首席争霸数据[门派][id].奖励==false then
    常规提示(id,"你没有这样的奖励可以领取")
    return 0
  else
    local 书铁种类=取随机数(1,#书铁范围)
    local 书铁等级=6
    local 灵饰等级=60
    local 等级=玩家数据[id].角色.数据.等级
    local 获得仙玉=500
    if 等级<70 then
      书铁等级=6
      灵饰等级=60
      获得仙玉=300
    elseif 等级<90 then
      书铁等级=8
      灵饰等级=80
      获得仙玉=350
    elseif 等级<110 then
      书铁等级=10
      灵饰等级=100
      获得仙玉=400
    elseif 等级<130 then
      书铁等级=12
      灵饰等级=120
      获得仙玉=450
    elseif 等级<160 then
      书铁等级=14
      灵饰等级=140
      获得仙玉=500
    else
      书铁等级=15
      灵饰等级=140
      获得仙玉=600
    end
    首席争霸数据[门派][id].奖励=false
    self.经验奖励=math.floor(等级*等级*等级)
    self.银子奖励=首席争霸数据[门派][id].积分*20000+100000
    玩家数据[id].角色:添加经验(self.经验奖励,"首席争霸赛奖励")
    玩家数据[id].角色:添加银子(self.银子奖励,"首席争霸赛奖励",1)
    常规提示(id,"你领取了首席争霸赛奖励")
    if 首席争霸[门派]~=nil and 首席争霸[门派].id==id then
      添加仙玉(获得仙玉,玩家数据[id].账号,id,"首席争霸赛奖励")
      self:给予道具(id,"灵饰指南书",{书铁等级})
      self:给予道具(id,"元灵晶石",{书铁等级})
      self:给予道具(id,"制造指南书",灵饰等级,书铁种类)
      self:给予道具(id,"百炼精铁",灵饰等级,书铁种类)
    end
  end
end

function 道具处理类:帮派竞赛奖励(id,编号)
  if 帮派竞赛数据==nil or 帮派竞赛数据[编号]==nil then
    常规提示(id,"你没有这样的奖励可以领取")
    return 0
  elseif 帮派竞赛数据[编号][id]==nil then
    常规提示(id,"你没有这样的奖励可以领取")
    return 0
  elseif 帮派竞赛数据[编号][id].奖励==false then
    常规提示(id,"你没有这样的奖励可以领取")
    return 0
  else
    帮派竞赛数据[编号][id].奖励=false
    local 等级=玩家数据[id].角色.数据.等级
    self.经验奖励=math.floor(等级*等级*等级)
    self.银子奖励=帮派竞赛数据[编号][id].积分*20000+100000
    玩家数据[id].角色.数据.帮贡=玩家数据[id].角色.数据.帮贡+100
    帮派数据[编号].成员数据[id].帮贡.上限=帮派数据[编号].成员数据[id].帮贡.上限+100
    帮派数据[编号].成员数据[id].帮贡.当前=帮派数据[编号].成员数据[id].帮贡.当前+100
    玩家数据[id].角色:添加经验(self.经验奖励,"帮派竞赛奖励")
    玩家数据[id].角色:添加银子(self.银子奖励,"帮派竞赛奖励",1)
    常规提示(id,"你领取了帮派竞赛奖励")
  end
end

function 道具处理类:显示(x,y) end

return 道具处理类