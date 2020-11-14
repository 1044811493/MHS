-- @作者: baidwwy
-- @邮箱:  313738139@qq.com
-- @创建时间:   2020-11-13 23:48:00
-- @最后修改来自: baidwwy
-- @Last Modified time: 2020-11-14 00:11:45
local luasql = require "luasql.mysql"
local env = luasql.mysql(); --创建环境对象
--连接数据库
local conn = env:connect('mhsj','mhsj','mhsj','118.24.118.15','3306')
--设置数据库的编码格式
conn:execute"SET NAMES GB2312"
--执行数据库操作

function 日期转时间戳(时间)
  local strDate =时间
  local _, _, y, m, d, _hour, _min, _sec ,_hm= string.find(strDate, "(%d+)-(%d+)-(%d+)%s*(%d+):(%d+):(%d+)");
  --转化为时间戳
  local timestamp = os.time({year=y, month = m, day = d, hour = _hour, min = _min, sec = _sec});
  return timestamp
end

-- retrieve a cursor
local cur = assert (conn:execute"SELECT name, email,createTime from people")  --获取数据
-- print all rows
local row = cur:fetch ({}, "a") -- the rows will be indexed by field names  --显示出来

while row do

-- print(string.format("Name: %s, E-mail: %s，createTime：%s", row.name, row.email,row.createTime ))
-- print(日期转时间戳(row.createTime))

row = cur:fetch (row, "a") -- reusing the table of results
end
-- close everything
cur:close()
conn:close()
env:close()


-- for i, p in pairs (list) do                      --加入数据到people表
--   local res = assert (conn:execute(string.format([[
--     INSERT INTO people
--     VALUES ('%s', '%s')]], p.name, p.email)
--   ))
-- end