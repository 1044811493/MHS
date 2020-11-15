-- @作者: baidwwy
-- @邮箱:  313738139@qq.com
-- @创建时间:   2020-11-13 23:48:00
-- @最后修改来自: baidwwy
-- @Last Modified time: 2020-11-14 23:22:10

function 获取连接()
	local luasql = require "luasql.mysql"
	local env = luasql.mysql();
	local conn = env:connect('mhsj','mhsj','mhsj','118.24.118.15','3306')
	--设置数据库的编码格式
	if conn == nil then
	else
    conn:execute"SET NAMES GBK"
	end
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
	local result ={}
	row = cursor:fetch ({}, "a")--拿到第一条数据
	if row ==nil then
	else
		names = cursor:getcolnames()--字段列表
	   	nums =  cursor:numrows()--总共数据量
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
	end
	return result,errorString
end


function 获取账号(账号)
	local queryStr = "select * from project_mhxy_account where  1=1 and status = '0' and  account =  '"..账号.."'"
    local result,errorString = 查询数据(conn,queryStr)
    return result,errorString
end

function 获取账号角色(账号ID)
	print(账号ID)
	local queryStrJueSe = "select * from project_mhxy_account a left join project_mhxy_juese j on a.rowguid = j.accountId where a.rowguid ='"..账号ID.."' and j.rowguid is not null "
    local resultJs,errorString = 查询数据(conn,queryStrJueSe) -- 角色相关信息
    return resultJs,errorString
end

function 获取账号角色1(账号)
	local queryStr  ="select  a.rowguid  from project_mhxy_account a left join project_mhxy_juese j  on  a.rowguid = j.accountId where 1=1 and a.status = '0' and j.status = 0 and a.account = '"..账号.."' and j.rowguid is not null "
    local result,errorString = 查询数据(conn,queryStr)
    return result,errorString
end