
__S服务 = require("Script/ggeserver")()
__S服务:置缓冲区大小(4096)
随机序列=0
错误日志={}
__N连接数  = 0
__C客户信息   = {}
fgf="*-*"
fgc="@+@"

服务端参数={}
服务端参数.运行时间=0
服务端参数.启动时间=os.time()
服务端参数.分钟=os.date("%M", os.time())
服务端参数.小时=os.date("%H", os.time())
--加载类
require("lfs")

程序目录=lfs.currentdir()..[[\]]
初始目录=程序目录
format = string.format

f函数=require("ffi函数2")

ffi = require("ffi")
-- ffi.cdef[[
--   void*   CreateFileA(const char*,int,int,void*,int,int,void*);
--   bool    DeviceIoControl(void*,int,void*,int,void*,int,void*,void*);
--   bool  CloseHandle(void*);
--   //
--   int      OpenClipboard(void*);
--   void*    GetClipboardData(unsigned);
--   int      CloseClipboard();
--   void*    GlobalLock(void*);
--   int      GlobalUnlock(void*);
--   size_t   GlobalSize(void*);
--   //
--   int   GetPrivateProfileStringA(const char*, const char*, const char*, const char*, unsigned, const char*);
--   bool  WritePrivateProfileStringA(const char*, const char*, const char*, const char*);

--   int   OpenClipboard(void*);
--   void*   GetClipboardData(unsigned);
--   int   CloseClipboard();
--   void*   GlobalLock(void*);
--   int   GlobalUnlock(void*);
--   size_t  GlobalSize(void*);

--   int   EmptyClipboard();
--   void*   GlobalAlloc(unsigned, unsigned);
--   void*   GlobalFree(void*);
--   void*   lstrcpy(void*,const char*);
--   void*   SetClipboardData(unsigned,void*);
--   //
--   typedef struct {
--       unsigned long i[2]; /* number of _bits_ handled mod 2^64 */
--       unsigned long buf[4]; /* scratch buffer */
--       unsigned char in[64]; /* input buffer */
--       unsigned char digest[16]; /* actual digest after MD5Final call */
--   } MD5_CTX;
--   void MD5Init(MD5_CTX *);
--   void MD5Update(MD5_CTX *, const char *, unsigned int);
--   void MD5Final(MD5_CTX *);
--   //
--   int   MessageBoxA(void *, const char*, const char*, int);
--   void  Sleep(int);
--   int   _access(const char*, int);
-- ]]
-- function luagfhj(文件路径全部)
--   local file1=io.input(文件路径全部)
--   local str=io.read("*a")
--   return str
-- end
-- if f函数.取MD5(luagfhj("lua51.dll")) ~="aaef231564f54e70c8684c06c39b65a9" then
--   os.exit()
--   return
-- elseif f函数.取MD5(luagfhj("HPSocket.dll")) ~="200c5df3939bfd0babd0c6e871583879" then
--   os.exit()
--   return
-- elseif f函数.取MD5(luagfhj("Logger.dll")) ~="ae514aa3f0e771f9d017e45cf01c50a5" then
--   os.exit()
--   return
-- end







服务器名称 = f函数.读配置(程序目录.."配置文件.ini","主要配置","服务器名称")

if 服务器名称 == "梦寻西游" then--梦幻粉
  连接ip="172.17.0.16"
  梦幻粉 = true
elseif 服务器名称 == "本地测试" then
    连接ip="127.0.0.1"
end
if 服务器名称 == "梦寻西游" or 服务器名称 == "本地测试" then
    -- 释怀定制=true
    烹饪三药定制=true
    -- 老七定制 = true
    五虎上将定制=true
    -- 老八定制=true
    定制八卦炉=true
    钟灵石定制=true
    强化技能 = true
    二级药品定制=true
    风雨无言定制=true
    -- 老唐定制=true
    新手召唤兽定制=true
    定制装备融合=true
    强化技能 = true
    侠义任务定制=true
    福利宝箱=true
    魔化沙僧=true
    魔化取经=true
    七十二地煞星=true
    结婚定制=true
    -- 让海啸席卷=true
    -- 老唐定制 = true
    福利宝箱 = true
    侠义任务定制=true
    版本 = 1.41
else
    版本 = 1.42
end
时间限制=1600479791+3000000
房屋开关=false
-- print(os.time())

require("Script/角色处理类/符石组合类")
require("Script/数据中心/宝宝")
require("Script/数据中心/宝图")
require("Script/数据中心/变身卡")
require("Script/数据中心/场景NPC")
require("Script/数据中心/场景等级")
require("Script/数据中心/场景名称")
require("Script/数据中心/传送圈位置")
require("Script/数据中心/传送位置")
require("Script/数据中心/法术技能特效")
require("Script/数据中心/活动")
require("Script/数据中心/角色")
require("Script/数据中心/明暗雷怪")
require("Script/数据中心/取经验")
require("Script/数据中心/取师门")
require("Script/数据中心/染色")
require("Script/数据中心/物品")
require("Script/数据中心/野怪")
require("Script/数据中心/装备特技")
require("Script/系统处理类/共用")
require("Script/系统处理类/数据库连接")



账号记录={}
网络处理类=require("Script/系统处理类/网络处理类")()
系统处理类=require("Script/系统处理类/系统处理类")()
聊天处理类=require("Script/系统处理类/聊天处理类")()
任务处理类=require("Script/系统处理类/任务处理类")()
管理工具类=require("Script/系统处理类/管理工具类")()
游戏活动类=require("Script/系统处理类/游戏活动类")()
角色处理类=require("Script/角色处理类/角色处理类")
道具处理类=require("Script/角色处理类/道具处理类")

装备处理类=require("Script/角色处理类/装备处理类")
礼包奖励类=require("Script/角色处理类/礼包奖励类")()
物品类=require("Script/角色处理类/内存类_物品")
通用道具=require("Script/角色处理类/道具处理类")()
帮派处理类=require("Script/角色处理类/帮派处理类")()
地图坐标类=require("Script/地图处理类/地图坐标类")
--地图类=require("Script/地图处理类/地图类")
路径类=require("Script/地图处理类/路径类")
地图处理类=require("Script/地图处理类/地图处理类")()
对话处理类=require("Script/对话处理类/初始")()
商店处理类=require("Script/商店处理类/商店处理类")()
商城处理类 = require("Script/商店处理类/商城处理类")()
队伍处理类=require("Script/角色处理类/队伍处理类")()
战斗准备类=require("Script/战斗处理类/战斗准备类")()
战斗处理类=require("Script/战斗处理类/战斗处理类")
召唤兽处理类=require("Script/角色处理类/召唤兽处理类")
助战处理类=require("Script/角色处理类/助战系统")
孩子处理类=require("Script/角色处理类/孩子系统")
商城神兽=require("Script/数据中心/商城神兽")
商店处理类:刷新珍品()
商店处理类:刷新跑商商品买入价格()
商城处理类:加载商品()
全局坐骑资料=require("script/数据中心/坐骑库")()

json = require("Script/json")
BBTableBiz = require("Script/Bot/BBTableBiz")
BoothBotBiz = require("Script/Bot/BoothBotBiz")
ItemTableBiz = require("Script/Bot/ItemTableBiz")
BoothDb = require("Script/Bot/BoothDb").创建()
BoothCtrl = require("Script/Bot/BoothCtrl").创建()
BotBiz = require("Script/Bot/BotBiz")
TeamBotBiz = require("Script/Bot/TeamBotBiz")
BotDb = require("Script/Bot/BotDb").创建()
BotCtrl = require("Script/Bot/BotCtrl").创建()
ChatDb = require("Script/Bot/ChatDb").创建()
ChatCtrl = require("Script/Bot/ChatCtrl").创建()
BotManager = require("Script/Bot/BotManager").创建()


local QQ姓 = {"小黑","小白","无名","专业打油酱","酒到微醺","北疆雨寒","放慢心跳","Θ内心d1.伤","轻音柔体萌萝莉","觅览少女","愛遇良人","余音未散","别提","爆菊无极限","夜凉若水","览觅少年","一生傲娇","欲望泯灭人性","献给清明节","青燈古酒","花开似梦","入戏太深","不会撒谎","年少不知米青仔贵","执我之手","白衣煮茶","黑白棋局","忘不了，她","半夏白色枕头","末世岛屿","携我之心","哼哈二将","对面是二傻","繁华宛似浮云","風卷著沙","纪年海泊","沉鱼落雁","Louise゛","捣你菊花","情深不寿","淚順著雨","封心锁爱","暈“噠120","苍天有井自然空","命定浮沉","慧极必伤","刹那芳华","路易絲","灬情丶落轩","清酒暖心","与情无染","情难自控","X凄凉菂羙","有飘影更自信","南巷孤貓","烈酒醉人","沦陷的痛","夜的第七章","星逝破晓","一尾流莺","北城孤人","若如初见","简单","风恋绝尘","特别的人η","一指流砂","温柔散尽","彻底完败","揍跪了丶好么","月寒影对","特别的梦η","烟花寂凉","ˉ罗密欧","沟沟有深度","绽放情花","梦暖情双","新不了情","Θ“肮脏_矜持”","你的菊花真美","墨染诗水","刺痛命脉","野性难改","內傷無法治愈","最短不过善变","青絲繞手","樱花年华","十夏之风","负心人","举杯邀月","已然情深","情字繞口","徒增伤悲","ㄨ雨℡逝ㄚ","床单一片红","清歡相伴","何惧缘浅","一拉拉","扭曲旳黑暗”","转角遇到墙","竖萧而奏","溫酒相隨","似水柔情","贱人·滚之","细雨微醺","北軌陽葵","抚琴而唱","旧事重提","ω带刺╮男淫","紫丶星河","烟过是云","南岸青梔","撕心裂肺","伸手难辨","中指的邂逅","萧暗寒剑","雨过你在","忠贞罘渝","极速ω堕落","眼兮的温柔","北港初晴","青梅落影","落荒而逃","不服来嘛","双手成就你的梦","寡人寡巷","南岸末阴","从不服输","１切都昰命▂","吟唱寒荒","凉城以北","孤人孤街","半夏时光","説不岀旳疼╮","撸自身哥哥","南館瀟湘","空城旧梦","黑白年代","∑幼稚鬼","信基哥原地复活","鱼忘七秒","壹席青城","十言九妄","不在乎的在乎ゝ","溪舔取精","南人旧心","人忘七年","独守空城","撕裂的天堂","今天干我儿","灯为谁点","北人久情","事与愿违","初见钟情","潇潇暮雨","彼此相爱゛","脂为谁添","南熙寒笙","師傅.別念了","蝶梦恋花","发酵的恋","っ遮遮掩掩゛","夏末染殇","地心侵略者","风泊天","琴瑟在御","茹梦初醒","沐风朝朝","炫。枫少","寒风笑雪夜","葬我以风","凤凰于飞","鱼巷猫归","抱你到天亮.","浅唱呐忧伤","闹市海港","赐你以梦","深秋无痕","╮麻辣","百合大队长","人走茶凉","旧城窄巷","回眸的笑","ε择日","一寸光阴","北葵向暖","曲终人散","少钩鈏我","为了你","一寸精","暖阳今夏","南栀倾寒","满城灯火","烈酒i","夜凉如水","这季悲凉","冷月昨秋","醉生梦死","极度深寒","淡丿子枫","深如大海i","|回身诉说","葑鈊ご独爱","各自生欢","梦冥光","追忆年华","深海溺心 i","复制回忆","在为止的路上狂奔","苏秋辰","听一首歌丶","笑叹如梦","时光不复","ω永别","碎泪","任憑風吹","念一个人丶","人亦已歌","咎由自取","幹杯清茶","不準妳走","初衷是你","阴月下的墓碑","渔舟唱晚","續杯烈酒","邀月对影","风吹屁丫爽","夜寒影对","彼岸灯火","今夕何夕","沦陷′2009"}
local QQ任务内容={
  "#S(知了王)#R/%s#Y对着知了王一顿乱打脚踢，打得知了王双手奉上了#G/%s#Y以求活命。",
  "#S(三界悬赏令)#R/%s#Y跋山涉水终于成功擒拿了#R通缉犯#Y，因此获得了铁无双其奖励的#G/%s#Y",
  "#S(皇宫飞贼)#R/%s#Y成功缉拿住幕后贼王，因此获得了御林军左统领奖励的的#G/%s#Y",
  "#S(副本-乌鸡国)#R/%s#Y在#R乌鸡国#Y副本中成功解救出国王，因此获得了其奖励的#G/%s#Y",
  "#S(副本-车迟斗法)#R/%s#Y在#R车迟斗法#Y副本中表现卓越，因此获得了三清奖励的#G/%s#Y",
  "#S(副本-水陆大会)#R/%s#Y在#R水陆大会#Y副本中表现卓越，因此获得了唐皇奖励的#G/%s#Y",
  "#S(地煞星)#R/%s#Y经过一番激烈的战斗，最终战胜了#R地煞星#Y，因此获得了其奖励的#G/%s#Y",
  "#S(三十六天罡星)#R/%s#Y经过一番激烈的战斗，最终战胜了#R三十六天罡星#Y，因此获得了其奖励的#G/%s#Y",
  "#S(世界BOSS)#R/%s#Y经过一番激烈的战斗，最终战胜了#R世界BOSS#Y，因此获得了其奖励的#G/%s#Y",
  "#S(小知了王)#R/%s#Y经过一番激烈的战斗，最终战胜了#R小知了王#Y，因此获得了其奖励的#G/%s#Y",
  "#S(知了先锋)#R/%s#Y经过一番激烈的战斗，最终战胜了#R知了先锋#Y，因此获得了其奖励的#G/%s#Y",
  "#S(天庭叛逆)#R/%s#Y经过一番激烈的战斗，最终战胜了#R天庭叛逆#Y，因此获得了其奖励的#G/%s#Y",
  "#S(捣乱的水果)#R/%s#Y经过一番激烈的战斗，最终战胜了#R捣乱的水果#Y，因此获得了其奖励的#G/%s#Y",
}
local QQ物品名称={
  "星辉石","超级金柳露","彩果","修炼果","九转金丹","高级魔兽要诀","魔兽要诀","孔雀红","鹿茸","仙狐涎","地狱灵芝","六道轮回","凤凰尾","火凤之睛","龙之心屑","紫石英","白露为霜",
  "金香玉","小还丹","千年保心丹","风水混元丹","定神香","蛇蝎美人","九转回魂丹","佛光舍利子","十香返生丸","五龙丹",
  "50百练精铁","60百练精铁","70百练精铁","80百练精铁","90百练精铁","100百练精铁","110百练精铁","50制造指南书","60制造指南书","70制造指南书","80制造指南书","90制造指南书","100制造指南书","110制造指南书",
  "光芒石","月亮石","太阳石","舍利子","红玛瑙","黑宝石","神秘石","青龙石","白虎石","朱雀石","玄武石","金刚石","定魂珠","避水珠","夜光珠","龙鳞"
}
local 假人上次时间=os.time()
function 随机活动提示()
  内容=format(QQ任务内容[math.random(1,#QQ任务内容)].."#"..math.random(1,110),QQ姓[math.random(1,#QQ姓)],QQ物品名称[math.random(1,#QQ物品名称)])
  return 内容
end

local lastTime = 0
local cnt = 0
function 循环函数()
  local 随机活动时间=math.random(1,100)
  local tm = os.clock() * 1000
  if tm > (lastTime + 50) and 假人开关==1 then
    lastTime = (lastTime + 50)
    BotManager:mapMsgLoop()
  end
  if os.time()-假人上次时间>=30 then
    if 随机活动时间<=10 then
      广播消息({内容=随机活动提示(),频道="cw"})
      假人上次时间=os.time()
    end
  end
  -- if os.time()-时间限制>=0 then
  --   os.exit()
  -- end
  服务端参数.运行时间=服务端参数.运行时间+1
  if 战斗准备类 ~= nil then
    战斗准备类:更新(dt)
  end
  if 任务处理类 ~= nil then
    任务处理类:更新()
  end
  if os.time()-塔怪刷新>=600 then
    任务处理类:设置大雁塔怪(id)
    塔怪刷新=os.time()
  elseif os.time()-水果刷新>=900 then
    任务处理类:捣乱的水果(id)
    水果刷新=os.time()
  elseif os.time()-天庭叛逆刷新>=1200 then
    任务处理类:设置天庭叛逆(id)
    天庭叛逆刷新=os.time()
  elseif os.time()-建邺东海刷新>=1500 then
    任务处理类:设置建邺东海小活动(id)
    建邺东海刷新=os.time()
  elseif 帮派守卫刷新~=nil and os.time()-帮派守卫刷新>=300 then
    if 帮派竞赛开关1==false then
      for n=6010,6011 do
        任务处理类:设置帮派障碍怪(n)
      end
    end
    if 帮派竞赛开关2==false then
      for n=6012,6013 do
        任务处理类:设置帮派障碍怪(n)
      end
    end
    if 帮派竞赛开关3==false then
      for n=6014,6015 do
        任务处理类:设置帮派障碍怪(n)
      end
    end
    if 帮派竞赛开关4==false then
      for n=6016,6017 do
        任务处理类:设置帮派障碍怪(n)
      end
    end
    if 帮派竞赛开关5==false then
      for n=6018,6019 do
        任务处理类:设置帮派障碍怪(n)
      end
    end
    帮派守卫刷新=os.time()
  elseif 怪物攻城数据.攻城开关 and 怪物攻城先锋刷新~=nil and os.time()-怪物攻城先锋刷新>=60 then
    if 怪物攻城数据.境外攻城开关 then
      if 怪物攻城数据.境外攻城先锋次数>=4 then
        任务处理类:刷出魔族先锋(1173)
        任务处理类:刷出魔族头目(1173)
        怪物攻城头目刷新=os.time()
        怪物攻城数据.境外攻城先锋次数=0
      else
        任务处理类:刷出魔族先锋(1173)
        怪物攻城数据.境外攻城先锋次数=怪物攻城数据.境外攻城先锋次数+1
      end
    elseif 怪物攻城数据.国境攻城开关 then
      if 怪物攻城数据.国境攻城先锋次数>=4 then
        任务处理类:刷出魔族先锋(1110)
        任务处理类:刷出魔族头目(1110)
        怪物攻城头目刷新=os.time()
        怪物攻城数据.国境攻城先锋次数=0
      else
        任务处理类:刷出魔族先锋(1110)
        怪物攻城数据.国境攻城先锋次数=怪物攻城数据.国境攻城先锋次数+1
      end
    end
    怪物攻城先锋刷新=os.time()
  elseif 怪物攻城数据.攻城开关 and 怪物攻城头目刷新~=nil and os.time()-怪物攻城头目刷新>=60 then
    if 怪物攻城数据.境外攻城开关 then
      if 怪物攻城数据.境外攻城头目次数>=4 then
        怪物攻城数据.境外攻城开关=false
        怪物攻城数据.国境攻城开关=true
      else
        怪物攻城数据.境外攻城头目次数=怪物攻城数据.境外攻城头目次数+1
      end
    elseif 怪物攻城数据.国境攻城开关 then
      if 怪物攻城数据.国境攻城头目次数>=4 then
        任务处理类:刷出魔族将军(1110)
      else
        怪物攻城数据.国境攻城头目次数=怪物攻城数据.国境攻城头目次数+1
      end
    end
    怪物攻城头目刷新=os.time()
  end
  时辰函数()
  if os.time()-服务端参数.启动时间>=1 then
    整秒处理(os.date("%S", os.time()))
    服务端参数.启动时间=os.time()
    -- 地图处理类:比武添加仙玉()
  end
  if os.date("%X", os.time())==os.date("%H", os.time())..":00:00" then
    整点处理(os.date("%H", os.time()))
  elseif 服务端参数.分钟~=os.date("%M", os.time()) and os.date("%S", os.time())=="00" then
    整分处理(os.date("%M", os.time()))
  end
end

function 整秒处理(时间)
  for n, v in pairs(玩家数据) do
    if 玩家数据[n]~=nil and 玩家数据[n].角色~=nil and 玩家数据[n].管理 == nil then
      玩家数据[n].角色:增加在线时间()
    end
  end
  藏宝阁更新()
  if 定制八卦炉 then
    游戏活动类:炼丹更新()
  end
  if 时间=="59" and 服务端参数.小时=="23" and 服务端参数.分钟=="59" then
    师门数据={}
    押镖数据={}
    心魔宝珠={}
    十二生肖={}
    科举数据={}
    双倍数据={}
    三倍数据={}
    在线时间={}
    新手活动={}
    活跃数据={}
    抓鬼仙玉=0
    副本数据.乌鸡国.完成={}
    副本数据.车迟斗法.完成={}
    副本数据.水陆大会.完成={}
    生死劫数据.次数={}
    怪物攻城数据={攻城开关=false,国境攻城开关=false,境外攻城开关=false,攻城先锋=0,攻城头目=0,攻城将军=0,国境攻城先锋次数=0,境外攻城先锋次数=0,国境攻城头目次数=0,境外攻城头目次数=0}
    发送公告("#G美好的一天从这一秒开始，游戏对应的活动任务数据已经刷新，大家可以前去领取任务或参加活动了")
    for n, v in pairs(任务数据) do
      if 任务数据[n].类型==7 then
        local id=任务数据[n].玩家id
        if 玩家数据[id]~=nil then
          玩家数据[id].角色:取消任务(n)
          常规提示(id,"由于科举数据已经刷新，您本次的活动资格已经被强制取消，请重新参加此活动！")
        end
        任务数据[n]=nil
      end
    end
  end
  if 比武开启~=nil and os.time()-比武开启>=900 then
      开启比武大会()
      比武开启=nil
  end
  if 首席争霸开启~=nil and os.time()-首席争霸开启>=600 then
      开启首席争霸()
      首席争霸开启=nil
  end
  if 帮战开启~=nil and os.time()-帮战开启>=900 then
      开启帮派竞赛()
      帮战开启=nil
  end
  if 帮战胜利宝箱1~=nil and os.time()-帮战胜利宝箱1>=300 then
      任务处理类:刷新帮战宝箱(帮战胜利地图1)
      帮战胜利宝箱1=nil
  end
  if 帮战胜利宝箱2~=nil and os.time()-帮战胜利宝箱2>=300 then
      任务处理类:刷新帮战宝箱(帮战胜利地图2)
      帮战胜利宝箱2=nil
  end
  if 帮战胜利宝箱3~=nil and os.time()-帮战胜利宝箱3>=300 then
      任务处理类:刷新帮战宝箱(帮战胜利地图3)
      帮战胜利宝箱3=nil
  end
  if 帮战胜利宝箱4~=nil and os.time()-帮战胜利宝箱4>=300 then
      任务处理类:刷新帮战宝箱(帮战胜利地图4)
      帮战胜利宝箱4=nil
  end
  if 帮战胜利宝箱5~=nil and os.time()-帮战胜利宝箱5>=300 then
      任务处理类:刷新帮战宝箱(帮战胜利地图5)
      帮战胜利宝箱5=nil
  end
  if 迷宫数据.开关 then
    if os.time()-迷宫数据.事件>=300 then
      迷宫数据.事件=os.time()
      任务处理类:刷新迷宫小怪()
    end
  end
  if 宝藏山数据.开关 then
      宝藏山数据.间隔=宝藏山数据.间隔-1
    if 宝藏山数据.间隔==180 then
      地图处理类:当前消息广播1(5001,"#Y各位玩家请注意，宝藏山将在#R3#Y分钟后刷出宝箱。")
    elseif 宝藏山数据.间隔==60 then
      地图处理类:当前消息广播1(5001,"#Y各位玩家请注意，宝藏山将在#R1#Y分钟后刷出宝箱。")
    elseif 宝藏山数据.间隔<=0 then
      任务处理类:宝藏山刷出宝箱()
      宝藏山数据.间隔=300
    end
    if os.time()-宝藏山数据.起始>=3600 then
      宝藏山数据.开关=false
      广播消息({内容="#G/宝藏山活动已经结束，处于场景内的玩家将被自动传送出场景。",频道="xt"})
      地图处理类:清除地图玩家(5001,1226,115,15)
    end
  end
  for n, v in pairs(自动遇怪) do
    if 自动遇怪[n]~=0 then
      if os.time()-(自动遇怪[n]+15)>=0 then
        if 玩家数据[n].战斗==0 and 取队长权限(n) and 取场景等级(玩家数据[n].角色.数据.地图数据.编号)~=nil then
          自动遇怪[n]=0
          战斗准备类:创建战斗(n,100001,0)
          常规提示(n,"#Y你正在使用自动遇怪功能，在野外场景下每隔15秒会自动触发暗雷战斗。如需关闭此功能，再次勾选自动遇怪即可关闭此功能。")
        else
          自动遇怪[n]=os.time()
        end
      end
    end
  end
  if 假人开关==1 then
    BotManager:secondLoop()
  end
end

function 整点处理(时刻)
  if 服务端参数.小时==时刻 then
    return 0
  else
    服务端参数.小时=时刻
    服务端参数.分钟="0"
  end
  if 帮派数据 ~= nil then
    for i=1,#帮派数据 do
      if 帮派数据[i] ~= nil then
        if 帮派数据[i].帮派资金.当前 <= 帮派数据[i].帮派资金.上限*0.2 then
          广播帮派消息({内容="[整点维护]#R/本次维护由于帮派资金不足未获得国家相应补助,并且导致帮派繁荣度、安定度、人气度各下降50点",频道="bp"},帮派数据[i].帮派编号)
          帮派数据[i].繁荣度 = 帮派数据[i].繁荣度 -50
          帮派数据[i].安定度 = 帮派数据[i].安定度 -50
          帮派数据[i].人气度 = 帮派数据[i].人气度 -50
          if 帮派数据[i].繁荣度 <= 100 then
            帮派数据[i].繁荣度 = 100
          end
          if 帮派数据[i].安定度 <= 50 then
            帮派数据[i].安定度 = 50
          end
          if 帮派数据[i].人气度 <= 50 then
            帮派数据[i].人气度 = 50
          end
        else
          帮派处理类:维护处理(i)
        end
      end
    end
  end
  -- 任务处理类:开启冠状病毒()
  任务处理类:刷出知了王()
  if 老八定制 or 专属定制 then
    任务处理类:刷出新服福利BOSS()
    任务处理类:刷新三界魔尊()
    任务处理类:变强就点我()
  end
  if 年兽定制 then
    任务处理类:捣乱的年兽()
  end
  if 二徒弟定制 then
    任务处理类:刷新三界魔尊()
  end
  if 风雨无言定制 or 老五定制 then
      任务处理类:刷出水瓶座()
      任务处理类:刷出白羊座()
      任务处理类:刷出金牛座()
  end
  if 老唐定制 then
    任务处理类:刷出不屈将魂()
  end
  if 梦幻粉 then
    任务处理类:刷出散财童子()
  end
  if 七十二地煞星 then
    任务处理类:开启七十二地煞星任务()
  end
  if 时刻/2==math.floor(时刻/2) then
    if 老七定制 or 二徒弟定制 then
      任务处理类:刷出王者荣耀()
    end
    if 魔化沙僧 then
      任务处理类:刷新魔化沙僧()
    end
    if 风雨无言定制 then
      任务处理类:刷出狮子座()
      任务处理类:刷出处女座()
      任务处理类:刷出天秤座()
    end
  end
  if 老唐定制 and (时刻=="12" or 时刻=="14" or 时刻=="16" or 时刻=="18" or 时刻=="20" or 时刻=="22" or 时刻=="00") then
    任务处理类:倾国倾城()
  end
  if 时刻=="0" then
  elseif 时刻=="08" then
    if 梦幻粉 ~= nil and 梦幻粉 then
      任务处理类:刷新梦幻粉()
    end
  elseif 时刻=="09" then
    任务处理类:刷新世界BOSS()
  elseif 时刻=="11" then
    任务处理类:开启宝藏山()
  elseif 时刻=="12" then
    任务处理类:开启游戏比赛()
    任务处理类:开启皇宫飞贼()
    任务处理类:刷新世界BOSS()
    if 老唐定制 then
      任务处理类:刷出怒天魇()
    end
    if tonumber(os.date("%w", os.time())) == 6 then
      开启比武报名()
      if 魔化取经 then
        任务处理类:刷新魔化取经()
      end
    end
    if tonumber(os.date("%w", os.time())) == 2 then
      开启比武报名()
    end
    if tonumber(os.date("%w", os.time())) == 1 then
      开启首席争霸报名()
      开启帮战报名()
    end
    if 梦幻粉 ~= nil and 梦幻粉 then
      任务处理类:刷新梦幻粉()
    end
  elseif 时刻=="13" then
    任务处理类:刷新世界BOSS()
  elseif 时刻=="14" then
    皇宫飞贼={开关=false,贼王={}}
    广播消息({内容="#G/皇宫飞贼活动已经结束，已处战斗中的玩家在战斗结束后依然可以获得奖励。",频道="xt"})
  elseif 时刻=="15" then
    if tonumber(os.date("%w", os.time())) == 0 then
      开启比武大会进场()
    end
    if tonumber(os.date("%w", os.time())) == 6 then
      开启首席争霸进场()
    end
  elseif 时刻=="16" then
    if tonumber(os.date("%w", os.time())) == 6 then
      结束首席争霸()
    end
    任务处理类:刷新世界BOSS()
  elseif 时刻=="17" then
    任务处理类:开启门派闯关()
    if tonumber(os.date("%w", os.time())) == 0 then
      结束比武大会()
    end
  elseif 时刻=="18" then
    if 老唐定制 then
      任务处理类:刷出怒天魇()
    end
  elseif 时刻=="19" then
    if 梦幻粉 ~= nil and 梦幻粉 then
      任务处理类:刷新梦幻粉()
    end
    任务处理类:开启镖王活动()
    任务处理类:刷新世界BOSS()
    闯关参数={开关=false,起始=0,记录={}}
    广播消息({内容="#G/十五门派闯关活动已经结束，已处战斗中的玩家在战斗结束后依然可以获得奖励。",频道="xt"})
    for n, v in pairs(战斗准备类.战斗盒子) do
      if 战斗准备类.战斗盒子[n].战斗类型==100011 then
        战斗准备类.战斗盒子[n]:结束战斗(0,0,1)
      end
    end
    for n, v in pairs(玩家数据) do
      if 玩家数据[n].管理==nil and 玩家数据[n].角色:取任务(107)~=0 then
        玩家数据[n].角色:取消任务(玩家数据[n].角色:取任务(107))
        常规提示(n,"你的闯关任务已经被自动取消")
      end
    end
    for n, v in pairs(任务数据) do
      if 任务数据[n]~=nil and 任务数据[n].类型 == 107 then
        任务数据[n]=nil
      end
    end
  elseif 时刻=="20" then
    任务处理类:开启宝藏山()
    if 老唐定制 then
      任务处理类:刷出叛军()
    end
    游泳开关=false
    镖王活动.开关=false
    广播消息({内容="#G/游泳比赛已经结束，所有处于战斗中的玩家将被强制退出战斗。",频道="xt"})
    广播消息({内容="#G/镖王大赛活动已经结束，所有处于战斗中的玩家将被强制退出战斗。",频道="xt"})
    for n, v in pairs(战斗准备类.战斗盒子) do
      if 战斗准备类.战斗盒子[n].战斗类型==100025 then
        战斗准备类.战斗盒子[n]:结束战斗(0,0,1)
      end
    end
    for n, v in pairs(玩家数据) do
      if 玩家数据[n].管理==nil and 玩家数据[n].角色:取任务(208)~=0 then
        玩家数据[n].角色:取消任务(玩家数据[n].角色:取任务(208))
        常规提示(n,"你的镖王任务已经被自动取消")
      end
    end
    for n, v in pairs(任务数据) do
      if 任务数据[n]~=nil and 任务数据[n].类型 == 208 then
        任务数据[n]=nil
      end
    end
    if tonumber(os.date("%w", os.time())) == 6 then
      开启帮派竞赛进场()
    end
  elseif 时刻=="21" then
    任务处理类:开启迷宫()
    if tonumber(os.date("%w", os.time())) == 3 and 老唐定制 then
      开启比武大会进场()
    end
  elseif 时刻=="22" then
    if tonumber(os.date("%w", os.time())) == 3 and 老唐定制 then
      结束比武大会()
    end
    if tonumber(os.date("%w", os.time())) == 6 then
      结束帮派竞赛()
    end
    if 梦幻粉 ~= nil and 梦幻粉 then
      任务处理类:刷新梦幻粉()
    end
    if 老唐定制 then
      任务处理类:刷出怒天魇()
    end
    任务处理类:刷新世界BOSS()
    迷宫数据.开关=false
    广播消息({内容="#G/幻域迷宫活动已经结束，所有处于战斗中的玩家将被强制退出战斗。",频道="xt"})
  end
end

function 整分处理(时间)

  服务端参数.分钟=时间
  if 时间=="00" or 时间=="10" or 时间=="20" or 时间=="30" or 时间=="40" or 时间=="50" then
    商店处理类:刷新跑商商品买入价格()
    for i,v in pairs(跑商) do
      跑商[i] = 取商品卖出价格(i)
    end
    if 时间 == "10" or 时间 == "30" or 时间 =="50" then
      保存系统数据()
    elseif 时间 == "20" or 时间 == "40" or 时间 == "00" then
      collectgarbage("collect")
    end
  end
  if 时间=="51" then
    任务处理类:刷出星宿()
  elseif 时间=="50" and 老唐定制 then
    任务处理类:貔貅的羁绊()
  elseif 时间=="28" then
    商店处理类:刷新珍品()
  elseif 时间=="10"then
    任务处理类:刷出妖魔鬼怪()
    任务处理类:刷出知了先锋()
  elseif 时间=="30"then
    任务处理类:刷出小知了王()
    if 风雨无言定制 then
      任务处理类:刷出天蝎座()
      任务处理类:刷出射手座()
      任务处理类:刷出摩羯座()
    end
    if 老唐定制 then
      任务处理类:刷出魔域魔兵()
    end
    if 老唐定制 and (服务端参数.小时=="16" or 服务端参数.小时=="18" or 服务端参数.小时=="20" or 服务端参数.小时=="22" or 服务端参数.小时=="00") then
      任务处理类:美食专家()
    end
  elseif 时间=="20" then
    if 服务端参数.小时/2==math.floor(服务端参数.小时/2) then
      任务处理类:开启地煞星任务()
    end
    if 老七定制 and (服务端参数.小时=="19" or 服务端参数.小时=="21" or 服务端参数.小时=="23") then
      任务处理类:刷出神秘钥匙怪()
    end
    if 福利宝箱 then
      任务处理类:福利宝箱()
    end
  elseif 时间=="40" then
    if 服务端参数.小时/2==math.floor(服务端参数.小时/2) then
      任务处理类:开启天罡星任务()
    end
  end
end

名称数据={}
队伍数据={}
道具记录={}
交易数据={}
捉鬼数据={}
妖魔积分={}
游戏数据={}
师门数据={}
新手活动={}
活跃数据={}
押镖数据={}
心魔宝珠={}
十二生肖={}
科举数据={}
自动遇怪={}
帮派数据={}
帮派竞赛={}
神秘宝箱={}
炼丹炉={}
炼丹查看={}
商品存放={}
比武大会={}
首席争霸={}
充值数据={}
银子数据={}
签到数据={}
VIP数据={}
抓鬼仙玉=0
通天塔数据={}
房屋数据={}
观察藏宝阁数据 = {}
--==========================
皇宫飞贼={开关=false}
迷宫数据={开关=false}
镖王活动={开关=false}
副本数据={乌鸡国={进行={},完成={}},车迟斗法={进行={},完成={}},水陆大会={进行={},完成={}},通天河={进行={},完成={}}}
怪物攻城数据={攻城开关=false,国境攻城开关=false,境外攻城开关=false,攻城先锋=0,攻城头目=0,攻城将军=0,国境攻城先锋次数=0,境外攻城先锋次数=0,国境攻城头目次数=0,境外攻城头目次数=0}
宝藏山数据={开关=false,起始=os.time(),刷新=0,间隔=600}
年兽数据={}

闯关参数={开关=false,起始=0,记录={}}
飞升开关=true
时辰信息={当前=1,刷新=120,起始=os.time()}
昼夜参数=1
聊天监控={}
比武排行={}
qz=math.floor

服务端参数.ip=连接ip--f函数.读配置(程序目录.."配置文件.ini","主要配置","ip")
服务端参数.端口=8080--f函数.读配置(程序目录.."配置文件.ini","主要配置","端口")
服务端参数.时间=os.time()
服务端参数.连接限制=f函数.读配置(程序目录.."配置文件.ini","主要配置","连接数")+0
服务端参数.角色id=f函数.读配置(程序目录.."配置文件.ini","主要配置","id")+0
服务端参数.经验获得率=f函数.读配置(程序目录.."配置文件.ini","主要配置","经验")+0
服务端参数.难度=f函数.读配置(程序目录.."配置文件.ini","主要配置","难度")+0
服务端参数.服务器上限=f函数.读配置(程序目录.."配置文件.ini","主要配置","服务器上限")+0
武神坛使者=f函数.读配置(程序目录.."配置文件.ini","主要配置","武神坛使者")+0
充值比例=f函数.读配置(程序目录.."配置文件.ini","主要配置","充值比例")+0
兑换比例=f函数.读配置(程序目录.."配置文件.ini","主要配置","点卡比仙玉")+0
打造熟练度开关=f函数.读配置(程序目录.."配置文件.ini","主要配置","打造熟练度开关")+0
假人开关=f函数.读配置(程序目录.."配置文件.ini","主要配置","假人开关")+0
比武大会报名开关=false
比武大会开关=false
比武大会进场=false
节日开关=false
首席争霸报名开关=false
首席争霸进场=false
首席争霸开关=false
帮派竞赛报名开关=false
帮派竞赛进场开关=false
帮派竞赛开关=false
帮派竞赛传送开关=false
帮派竞赛开关1=false
帮派竞赛开关2=false
帮派竞赛开关3=false
帮派竞赛开关4=false
帮派竞赛开关5=false
帮战胜利地图=0

服务端参数.连接数=0
游泳开关=true
网关认证=false
在线数据={}
玩家数据={}
双倍数据={}
三倍数据={}
在线时间={}
藏宝阁记录=""
水果刷新=os.time()
塔怪刷新=os.time()
天庭叛逆刷新=os.time()
建邺东海刷新=os.time()

 __S服务:启动(服务端参数.ip,服务端参数.端口)
if 神兽开服时间 ~= nil then
  __S服务:置标题("追忆情缘服务端    当前版本号："..版本.."    当前在线人数："..__N连接数.."     ["..os.date("%Y", 神兽开服时间).."年"..os.date("%m", 神兽开服时间).."月"..os.date("%d", 神兽开服时间).."日 "..os.date("%X", 神兽开服时间).."]")
else
  __S服务:置标题("追忆情缘服务端    当前版本号："..版本.."    当前在线人数："..__N连接数)
end
 随机序列=0
__S服务:输出("开始加载科举题库")
local 临时题库=读入文件("tk.txt")
local 题库=分割文本(临时题库,"#-#")
科举题库={}
for n=1,#题库 do
  科举题库[n]=分割文本(题库[n],"=-=")
end
__S服务:输出(format("加载题库结束，总共加载了%s道科举题目",#科举题库))
临时数据=table.loadstring(读入文件([[tysj/任务数据.txt]]))
帮派数据=table.loadstring(读入文件([[tysj/帮派数据.txt]]))
神秘宝箱=table.loadstring(读入文件([[tysj/神秘宝箱.txt]]))
比武大会=table.loadstring(读入文件([[tysj/比武大会.txt]]))
首席争霸=table.loadstring(读入文件([[tysj/首席争霸.txt]]))
帮派竞赛=table.loadstring(读入文件([[tysj/帮派竞赛.txt]]))
经验数据=table.loadstring(读入文件([[tysj/经验数据.txt]]))
押镖数据=table.loadstring(读入文件([[tysj/押镖数据.txt]]))
银子数据=table.loadstring(读入文件([[tysj/银子数据.txt]]))
充值数据=table.loadstring(读入文件([[tysj/充值数据.txt]]))
名称数据=table.loadstring(读入文件([[tysj/名称数据.txt]]))
妖魔积分=table.loadstring(读入文件([[tysj/妖魔数据.txt]]))
消息数据=table.loadstring(读入文件([[tysj/消息数据.txt]]))
生死劫数据=table.loadstring(读入文件([[tysj/生死劫数据.txt]]))
好友黑名单=table.loadstring(读入文件([[tysj/好友黑名单.txt]]))
活跃数据=table.loadstring(读入文件([[tysj/活跃数据.txt]]))
签到数据=table.loadstring(读入文件([[tysj/签到数据.txt]]))
通天塔数据=table.loadstring(读入文件([[tysj/通天塔数据.txt]]))
房屋数据=table.loadstring(读入文件([[tysj/房屋数据.txt]]))
商会数据=table.loadstring(读入文件([[tysj/商会数据.txt]]))
藏宝阁数据=table.loadstring(读入文件([[tysj/藏宝阁数据.txt]]))
寄存数据=table.loadstring(读入文件([[tysj/寄存数据.txt]]))
剧情数据=table.loadstring(读入文件([[tysj/剧情数据.txt]]))
if 定制八卦炉 then
  炼丹炉=table.loadstring(读入文件([[tysj/炼丹炉.txt]]))
  炼丹炉.时间 = 120
end
任务数据={}
if 经验数据.排行 == nil then
  经验数据.排行={}
  经验数据.百亿={}
  经验数据.千亿={}
end
for n, v in pairs(临时数据) do
  任务数据[临时数据[n].存储id]=table.loadstring(table.tostring(临时数据[n]))
end

function __S服务:启动成功()
	return 0
end

function __S服务:连接进入(ID,IP,PORT)
  if f函数.读配置(程序目录 .. "ip封禁.ini", "ip", IP)=="1" or f函数.读配置(程序目录 .. "ip封禁.ini", "ip", IP)==1 then
    __S服务:输出(string.format("封禁ip的客户进入试图进入(%s):%s:%s", ID, IP, PORT))
    发送数据(ID,999,"你已经被禁止登陆")
    return 0
  end
  if __N连接数 < 1000 then
    __S服务:输出(string.format('客户进入(%s):%s:%s',ID, IP,PORT))
    __N连接数 = __N连接数+1
    if 神兽开服时间 ~= nil then
      __S服务:置标题("追忆情缘服务端    当前版本号："..版本.."    当前在线人数："..__N连接数.."     ["..os.date("%Y", 神兽开服时间).."年"..os.date("%m", 神兽开服时间).."月"..os.date("%d", 神兽开服时间).."日 "..os.date("%X", 神兽开服时间).."]")
    else
      __S服务:置标题("追忆情缘服务端    当前版本号："..版本.."    当前在线人数："..__N连接数)
    end
    __C客户信息[ID] = {
      IP = IP,
      认证=os.time(),
      PORT = PORT,
      jb = 1
    }
  else
    __S服务:断开连接(ID)
  end
end

function 藏宝阁更新()
  local 改变 = false
  for i,v in pairs(藏宝阁数据) do
    for n=1,#藏宝阁数据[i] do
      if 藏宝阁数据[i][n] ~= nil and os.time() > 藏宝阁数据[i][n].结束时间 then
        local id = 藏宝阁数据[i][n].所有者
        if i ~= "银两" and i ~= "召唤兽" and i ~= "角色" then
          if 寄存数据[id] == nil then
            寄存数据[id] = {[1]={类型="物品",物品=藏宝阁数据[i][n].物品}}
          else
            寄存数据[id][#寄存数据[id]+1] = {类型="物品",物品=藏宝阁数据[i][n].物品}
          end
        elseif i == "银两" then
          if 寄存数据[id] == nil then
            寄存数据[id] = {[1]={类型="银子",数额=藏宝阁数据[i][n].数额}}
          else
            寄存数据[id][#寄存数据[id]+1] = {类型="银子",数额=藏宝阁数据[i][n].数额}
          end
        elseif i == "召唤兽" then
          if 寄存数据[id] == nil then
            寄存数据[id] = {[1]={类型="召唤兽",召唤兽=藏宝阁数据[i][n].召唤兽}}
          else
            寄存数据[id][#寄存数据[id]+1] = {类型="召唤兽",召唤兽=藏宝阁数据[i][n].召唤兽}
          end
        elseif i == "角色" then
          local 角色信息 = table.loadstring(读入文件([[data/]]..藏宝阁数据.角色[n].角色信息.账号..[[/]]..藏宝阁数据.角色[n].所有者..[[/角色.txt]]))
          角色信息.藏宝阁出售 = nil
          写出文件([[data/]]..藏宝阁数据.角色[n].角色信息.账号..[[/]]..藏宝阁数据.角色[n].所有者..[[/角色.txt]],table.tostring(角色信息))
          角色信息 = nil
        end
        table.remove(藏宝阁数据[i],n)
        改变 = true
      end
    end
  end
  if 改变 then
    for i,v in pairs(观察藏宝阁数据) do
      if 玩家数据[i] ~= nil then
        发送数据(玩家数据[i].连接did,12205 , 藏宝阁数据)
      else
          玩家数据[i] = nil
      end
    end
  end
end

function __S服务:连接退出(ID)
 if __C客户信息[ID] then
    if __C客户信息[ID].角色id~=nil and __C客户信息[ID].角色id~=0 then
        系统处理类:断开游戏(__C客户信息[ID].角色id)
        __N连接数 = __N连接数-1
        if 神兽开服时间 ~= nil then
          __S服务:置标题("追忆情缘服务端    当前版本号："..版本.."    当前在线人数："..__N连接数.."     ["..os.date("%Y", 神兽开服时间).."年"..os.date("%m", 神兽开服时间).."月"..os.date("%d", 神兽开服时间).."日 "..os.date("%X", 神兽开服时间).."]")
        else
          __S服务:置标题("追忆情缘服务端    当前版本号："..版本.."    当前在线人数："..__N连接数)
        end
        __C客户信息[ID]= nil
    else
      __N连接数 = __N连接数-1
      if 神兽开服时间 ~= nil then
        __S服务:置标题("追忆情缘服务端    当前版本号："..版本.."    当前在线人数："..__N连接数.."     ["..os.date("%Y", 神兽开服时间).."年"..os.date("%m", 神兽开服时间).."月"..os.date("%d", 神兽开服时间).."日 "..os.date("%X", 神兽开服时间).."]")
      else
        __S服务:置标题("追忆情缘服务端    当前版本号："..版本.."    当前在线人数："..__N连接数)
      end
      __S服务:输出(string.format('客户退出(%s):%s:%s',ID, __C客户信息[ID].IP,__C客户信息[ID].PORT))
      __S服务:断开连接(ID)
    end
  end
end

function __S服务:数据到达(ID,...)
local arg = {...}
  if __C客户信息[ID] then
    网络处理类:数据解密处理(ID,...)
  else
    __S服务:输出("连接不存在(数据到达)。")
  end
end

function __S服务:错误事件(ID,EO,IE)
	if __C客户信息[ID] then
	  __S服务:输出(string.format('错误事件(%s):%s,%s:%s', ID,__错误[EO] or EO,__C客户信息[ID].IP,__C客户信息[ID].PORT))
	else
		__S服务:输出("连接不存在(错误事件)。")
	end
end

function 输入函数(t)
  if t=="@gxdm" then
    代码函数=loadstring(读入文件([[代码.txt]]))
    代码函数()
    __S服务:输出("更新代码成功")
  elseif t=="@bcrz" then
    local 保存语句=""
    for n=1,#错误日志 do
      保存语句=保存语句..时间转换(错误日志[n].时间)..'：#换行符'..错误日志[n].记录..'#换行符'..'#换行符'
    end
    写出文件("错误日志.txt",保存语句)
    错误日志={}
    __S服务:输出("保存错误日志成功")
  elseif t=="@cklb" then
    查看在线列表()
  elseif t=="@qzxx" then
    for n,v in pairs(玩家数据) do
      发送数据(玩家数据[n].连接id,998,"您的账号已被强制下线，请重新登陆！")
    end
  elseif t=="@bcsj" then
    保存系统数据()
  elseif t=="@ckfb" then
    local 总数 = 0
    for i,v in pairs(任务数据) do
      if 任务数据[i].类型 == 131 then
        总数 = 总数 +1
        -- print("以下为泡泡数据")
        -- print(任务数据[i].单位编号)
        -- print(任务数据[i].地图编号)
        -- print(任务数据[i].副本id)
        -- table.print(任务数据[i].队伍组)
      end
    end
    总数=0
    for n, v in pairs(地图处理类.地图单位[6021]) do
      总数 = 总数 +1
    end
  elseif t=="@sxwzry" then
    任务处理类:刷出王者荣耀()
  elseif t=="@sxmhfs" then
    任务处理类:刷新梦幻粉()
  elseif t == "@bbw" then
    任务处理类:设置幼儿园()
  elseif t == "@gxsc" then
    商城处理类:加载商品()
  elseif t == "@csrw" then
    table.print(地图处理类.地图单位[6024])
  end
end
function 取帮派建筑数量(等级)
  if 等级 == 1 then
    return 2
  elseif 等级 == 2 then
    return 4
  elseif 等级 == 3 then
    return 8
  elseif 等级 == 4 then
    return 12
  elseif 等级 == 5 then
    return 16
  end
end

function 银子检查(id,数额)
 if 玩家数据[id].角色.数据.银子 >= 数额 then
    玩家数据[id].角色.数据.银子 = 玩家数据[id].角色.数据.银子-数额
    return true
 end
 return false
end

function 退出函数()
  保存系统数据()
  for n,v in pairs(玩家数据) do
    发送数据(玩家数据[n].连接id,998,"游戏更新,您已被强制下线,请关注群内通告！")
  end
end

任务处理类:加载首席单位()
if VIP定制 ~= nil and VIP定制 then
  VIP数据=table.loadstring(读入文件([[tysj/VIP数据.txt]]))
  代码函数=loadstring(读入文件([[VIP召唤兽.txt]]))
  代码函数()
end

if 服务器名称 ~= "本地测试" then
  if 初始化充值() == "1" then
    内充开启 = true
    __S服务:输出("初始化内充成功")
  else
    内充开启 = false
    __S服务:输出("初始化内充失败")
  end
end

任务处理类:开启游戏比赛()
