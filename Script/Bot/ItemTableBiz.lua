-- @作者: CoderM
-- @邮箱:  coderm@qq.com
-- @创建时间:   2020-05-31 00:40:46
-- @最后修改来自: CoderM
-- @Last Modified time: 2020-05-31 19:15:23

local ItemTableBiz = class()


function ItemTableBiz:初始化(source)
	self.item = source
	-- 最后刷新时间
	self.refreshTime = os.time()
end

-- 查看道具栏是否被更新过
function ItemTableBiz:isNew(time)
	if time <= self.refreshTime then
		return false
	end
	return true
end

function ItemTableBiz:refresh()
	self.refreshTime = os.time()
end

return ItemTableBiz