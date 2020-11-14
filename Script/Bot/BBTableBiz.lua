-- @作者: CoderM
-- @邮箱:  coderm@qq.com
-- @创建时间:   2020-05-31 00:40:56
-- @最后修改来自: CoderM
-- @Last Modified time: 2020-05-31 20:21:08

local BBTableBiz = class()


function BBTableBiz:初始化(source)
	self.bb = source
	self.refreshTime = os.time()
end

-- 查看道具栏是否被更新过
function BBTableBiz:isNew(time)
	if time <= self.refreshTime then
		return false
	end
	return true
end

function BBTableBiz:refresh()
	self.refreshTime = os.time()
end

return BBTableBiz