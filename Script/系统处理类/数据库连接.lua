-- @作者: baidwwy
-- @邮箱:  313738139@qq.com
-- @创建时间:   2020-11-13 23:48:00
-- @最后修改来自: baidwwy
-- @Last Modified time: 2020-11-14 15:57:39

--"CREATE TABLE people ( name varchar(50) DEFAULT NULL, email varchar(50) DEFAULT NULL,
--createTime timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP)"
function 获取连接()
	local luasql = require "luasql.mysql"
	local env = luasql.mysql();
	local conn = env:connect('mhsj','mhsj','mhsj','118.24.118.15','3306')
	--设置数据库的编码格式
	conn:execute"SET NAMES GB2312"
	return env,conn
end

function 关闭连接(env,conn)
	conn:close()
	env:close()
end
function 建表(conn,str)
 	status,errorString = conn:execute(str)
	return status,errorString
end
--"insert into people(name,email,createTime) values('中文','10444',STR_TO_DATE('2020-11-04 11:09:12','%Y-%m-%d %k:%i:%s'))"
function 写数据(conn,str)
 	status,errorString = conn:execute(str)
	return status,errorString
end
function 更新数据(conn,str)
 	status,errorString = conn:execute(str)
	return status,errorString
end
function 删除数据(conn,str)
 	status,errorString = conn:execute(str)
	return status,errorString
end

function 查询数据(conn,str)
	cursor,errorString = conn:execute(str)
	row = cursor:fetch ({}, "a")--拿到第一条数据
  	names = cursor:getcolnames()--字段列表
   	nums =  cursor:numrows()--总共数据量
    local result ={}
    for int = 1 ,nums do
    	local hashmap = map:new()
    	for i=1,#names do
      		local value = names[i]
      		local str = row[value]
    	 	hashmap:insert(value,str)
        end
     	table.insert(result,hashmap)
     	row = cursor:fetch (row, "a")
    end
	cursor:close()
	return result,errorString
end
