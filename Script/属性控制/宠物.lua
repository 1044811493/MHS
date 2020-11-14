--======================================================================--

--======================================================================--
--local dx = {
--	{"高级神佑复生","高级夜战","高级必杀","高级感知","高级连击","高级防御","高级强力","高级反震","高级再生","高级敏捷","高级反击","高级飞行","嗜血追击","剑荡四方","驱怪"},
--	{"高级慧根","高级魔之心","幸运","高级幸运","高级法术暴击","高级法术连击","高级感知","魔之心","招架","高级招架","高级驱鬼","法术暴击","慧根","高级慧根","高级法术抵抗"}
--}
local floor = math.floor
local ceil  = math.ceil
local bbs = 取宝宝
local jnsss = require("script/角色处理类/技能类")
local insert = table.insert
local cfs    = 删除重复
local rand   = 取随机小数
local 五行_ = {"金","木","水","火","土"}
local 属性类型={"体质","魔力","力量","耐力","敏捷"}
local 内存类_宝宝 = class()
function 内存类_宝宝:初始化()

end


function 内存类_宝宝:取存档数据()
	local 返回数据={}
	for n, v in pairs(self) do
		if type(n)~="function" and type(n)~="运行父函数" and n~="返回数据" then
			if type(n)=="table" then ----------
				返回数据[n]=table.loadstring(table.tostring(v))
			else
				返回数据[n]=v
			end
		end
	end
   return 返回数据
end

function 内存类_宝宝:取差异属性(sxb)
	local sx1 = self.最大气血
	local sx2 = self.最大魔法
	local sx3 = self.伤害
	local sx4 = self.防御
	local sx5 = self.速度
	local sx6 = self.灵力
	local 体质 = self.体质 + self.装备属性.体质 + sxb.体质
	local 魔力 = self.魔力 + self.装备属性.魔力 + sxb.魔力
	local 力量 = self.力量 + self.装备属性.力量 + sxb.力量
	local 耐力 = self.耐力 + self.装备属性.耐力 + sxb.耐力
	local 敏捷 = self.敏捷 + self.装备属性.敏捷 + sxb.敏捷
	local 最大气血 = ceil(self.等级*self.体力资质/1000+体质*self.成长*6) + self.装备属性.气血
	local 最大魔法 = ceil(self.等级*self.法力资质/500+魔力*self.成长*3) + self.装备属性.魔法
	local 伤害1 = ceil(self.等级*self.攻击资质*(self.成长+1.4)/750+力量*self.成长) + self.装备属性.伤害
	local 防御1 = ceil(self.等级*self.防御资质*(self.成长+1.4)/1143+耐力*(self.成长-1/253)*253/190)+ self.装备属性.防御
	local 速度1 = ceil(self.速度资质 * 敏捷/1000)  + self.装备属性.速度
	local 灵力1 = ceil(self.等级*(self.法力资质+1666)/3333+魔力*0.7+力量*0.4+体质*0.3+耐力*0.2) + self.装备属性.灵力
	return {气血=最大气血-sx1,魔法=最大魔法-sx2,伤害=伤害1-sx3,防御=防御1-sx4,速度=速度1-sx5,灵力=灵力1-sx6}
end

function 内存类_宝宝:取指定技能(名称)
	for n=1,#self.技能 do
		if self.技能[n]==名称 then
			return true
		end
	end
	return false
end

return 内存类_宝宝