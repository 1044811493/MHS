--======================================================================--
-- @作者: GGE研究群: 342119466
-- @创建时间:   2018-03-03 02:34:19
-- @Last Modified time: 2019-08-27 12:53:43
-- 梦幻西游游戏资源破解 baidwwy@vip.qq.com(313738139) 老毕   和 C++PrimerPlus 717535046 这俩位大神破解所以资源
--======================================================================--
local ffi     = require("ffi")
local _bor    = bit.bor
local _lshift = bit.lshift
local _rshift = bit.rshift
local _band   = bit.band
local _copy   = ffi.copy
local _cast   = ffi.cast
local _new    = ffi.new
local _string = ffi.string

local function _修复图片(dst, src, slen)
    local s,d,dlen = 0,0,0
    while s<slen and src[s]==0xFF do
        dst[d]=0xFF;d=d+1;s=s+1
        if src[s]==0xD8 then
            dst[d]=src[s];
            d=d+1;s=s+1
        elseif src[s]==0xA0 then--删除FFA0
            d=d-1;s=s+1
        elseif src[s]==0xC0 or src[s]==0xC4 or src[s]==0xDB then
            dst[d]=src[s];
            d=d+1;s=s+1
            local len = _bor(_lshift(src[s], 8),src[s+1])--Intel顺序
            for i=1,len do
                dst[d]=src[s]
                d=d+1;s=s+1
            end
        elseif src[s]==0xDA then--00 09 为 00 0C  最后添加 00 3F 00
            dst[d]=0xDA;d=d+1
            dst[d]=0x00;d=d+1
            dst[d]=0x0C;d=d+1
            s=s+1
            local len = _bor(_lshift(src[s], 8),src[s+1])-2
            s=s+2
            for i=1,len do
                dst[d]=src[s]
                d=d+1;s=s+1
            end
            dst[d]=0x00;d=d+1
            dst[d]=0x3F;d=d+1
            dst[d]=0x00;d=d+1
            for i=1,slen-s do--循环处理0xFFDA到0xFFD9之间所有的0xFF替换为0xFF00
                if src[s] == 0xFF then
                    dst[d]=0xFF;d=d+1
                    dst[d]=0x00;d=d+1
                    s=s+1;dlen=dlen+1
                else
                    dst[d]=src[s];
                    d=d+1;s=s+1
                end
            end
            dst[d-2]=0xD9
            break
        end
    end
    return dlen+slen
end
local function _解压数据(ip,op)
    local t,o,i,m = 0,0,0,0
    local run = 1
    if ip[i]>17 then
        t=ip[i]-17;i=i+1
        if t<4 then
            repeat op[o]=ip[i];o=o+1;i=i+1;t=t-1 until t==0
            t=ip[i];i=i+1
            run = 0
        else
            repeat op[o]=ip[i];o=o+1;i=i+1;t=t-1 until t==0
            run = 2
        end

    end
    while true do
    ::continue::
        if run == 1 then
            t=ip[i];i=i+1
            if t<16 then
                if t==0 then
                    while ip[i]==0 do t=t+255;i=i+1 end
                    t=t+15+ip[i];i=i+1
                end
                t=t-1+4
                repeat op[o]=ip[i];o=o+1;i=i+1;t=t-1 until t==0
                run = 2
            end
        end
        if run == 2 then--first_literal_run
            run = 1
            t=ip[i];i=i+1
            if t<16 then
                m=o-0x0801-_rshift(t, 2)-_lshift(ip[i], 2);i=i+1
                op[o]=op[m];o=o+1;m=m+1
                op[o]=op[m];o=o+1;m=m+1
                op[o]=op[m];o=o+1;
                t=_band(ip[-2],3)
                if t==0 then goto continue;end
                repeat op[o]=ip[i];o=o+1;i=i+1;t=t-1 until t==0
                t=ip[i];i=i+1
            end
        else run = 1 end
        while true do
            if t>=64 then
                m=o-1-_band(_rshift(t,2),7)-_lshift(ip[i],3);i=i+1
                t=_rshift(t,5)+1
                repeat op[o]=op[m];o=o+1;m=m+1;t=t-1 until t==0
                goto match_done;
            elseif t>=32 then
                t=_band(t,31)
                if t==0 then
                    while ip[i]==0 do t=t+255;i=i+1 end
                    t=t+31+ip[i];i=i+1
                end
                m=o-1-_rshift(_bor(ip[i],_lshift(ip[i+1],8)),2);i=i+2--short

            elseif t>=16 then
                m=o-_lshift(_band(t,8),11)
                t=_band(t,7)
                if t==0 then
                    while ip[i]==0 do t=t+255;i=i+1 end
                    t=t+7+ip[i];i=i+1
                end
                m=m-_rshift(_bor(ip[i],_lshift(ip[i+1],8)),2);i=i+2--short
                if m==o then--结束
                    return o
                end
                m=m-0x4000
            else
                m=o-1-_rshift(t,2)-_lshift(ip[i],2);i=i+1
                op[o]=op[m];o=o+1;m=m+1
                op[o]=op[m];o=o+1;
                goto match_done;
            end
            t=t+2
            repeat op[o]=op[m];o=o+1;m=m+1;t=t-1 until t==0
            ::match_done::
            t=_band(ip[i-2],3)
            if t==0 then break end
            repeat op[o]=ip[i];o=o+1;i=i+1;t=t-1 until t==0
            t=ip[i];i=i+1
        end
    end
end
--[[local function _解压数据(inp,out)
    local op = _cast('unsigned char*',out)
    local ip = _cast('unsigned char*',inp)
    local t,o,i,m = 0,0,0,0
    local run = 1
    if ip[i]>17 then
        t=ip[i]-17;i=i+1
        if t<4 then
            repeat op[o]=ip[i];o=o+1;i=i+1;t=t-1 until t==0
            t=ip[i];i=i+1
            run = 0
        else
            repeat op[o]=ip[i];o=o+1;i=i+1;t=t-1 until t==0
            run = 2
        end
    end
    while true do
    ::continue::
        if run == 1 then
            t=ip[i];i=i+1
            if t<16 then
                if t==0 then
                    while ip[i]==0 do t=t+255;i=i+1 end
                    t=t+15+ip[i];i=i+1
                end
                t=t-1+4
                repeat op[o]=ip[i];o=o+1;i=i+1;t=t-1 until t==0
                run = 2
            end
        end
        if run == 2 then--first_literal_run
            run = 1
            t=ip[i];i=i+1
            if t<16 then
                m=o-0x0801-_rshift(t, 2)-_lshift(ip[i], 2);i=i+1
                op[o]=op[m];o=o+1;m=m+1
                op[o]=op[m];o=o+1;m=m+1
                op[o]=op[m];o=o+1;
                t=_band(ip[-2],3)
                if t==0 then goto continue;end
                repeat op[o]=ip[i];o=o+1;i=i+1;t=t-1 until t==0
                t=ip[i];i=i+1
            end
        else run = 1 end
        while true do
            if t>=64 then
                m=o-1-_band(_rshift(t,2),7)-_lshift(ip[i],3);i=i+1
                t=_rshift(t,5)+1
                repeat op[o]=op[m];o=o+1;m=m+1;t=t-1 until t==0
                goto match_done;
            elseif t>=32 then
                t=_band(t,31)
                if t==0 then
                    while ip[i]==0 do t=t+255;i=i+1 end
                    t=t+31+ip[i];i=i+1
                end
                m=o-1-_rshift(_bor(ip[i],_lshift(ip[i+1],8)),2);i=i+2--short
            elseif t>=16 then
                m=o-_lshift(_band(t,8),11)
                t=_band(t,7)
                if t==0 then
                    while ip[i]==0 do t=t+255;i=i+1 end
                    t=t+7+ip[i];i=i+1
                end
                m=m-_rshift(_bor(ip[i],_lshift(ip[i+1],8)),2);i=i+2--short
                if m==o then--结束
                    return o
                end
                m=m-0x4000
            else
                m=o-1-_rshift(t,2)-_lshift(ip[i],2);i=i+1
                op[o]=op[m];o=o+1;m=m+1
                op[o]=op[m];o=o+1;
                goto match_done;
            end
            t=t+2
            repeat op[o]=op[m];o=o+1;m=m+1;t=t-1 until t==0
            ::match_done::
            t=_band(ip[i-2],3)
            if t==0 then break end
            repeat op[o]=ip[i];o=o+1;i=i+1;t=t-1 until t==0
            t=ip[i];i=i+1
        end
    end
end]]

local map = class()
--local wls = require("gge纹理类")
--local jls = require("gge精灵类")
local 文件  = require("Script/文件类")
--local 空纹理 = wls():空白纹理(320,240)
local ceil  = math.ceil
local floor = math.floor
local insert = table.insert

function map:初始化(路径)
    self.int  = _new('uint32_t[1]')
    self.File = 文件(路径)
    self.File:读入数据(self.int)
    self.File:移动读写位置(0)
    self.Flag = _string(self.int,4)
    local head   = self.File:读入数据(_new("MAP_HEADER"))
    self.Height  = head.Height
    self.Width   = head.Width
    self.MapRowNum = ceil(head.Height/240)--行数
    self.MapColNum = ceil(head.Width/320)--列数
    self.MapNum    = self.MapRowNum*self.MapColNum
    self.MapList   = self.File:读入数据(_new("uint32_t[?]",self.MapNum))--图块偏移
    self.File:读入数据(self.int)--遮罩列表偏移
    self.File:移动读写位置(self.int[0])
    self.MaskNum = self.File:读入数据(self.int)[0]--遮罩数量
    if self.MaskNum>0 then
        self.MaskList = self.File:读入数据(_new("uint32_t[?]",self.MaskNum))--遮罩数据偏移
    end
    self.Block  = _new("BlockHead")
    self.MInfo  = _new("MaskInfo")
    self.Temp   = _new('unsigned char[1048576]')--1MB
    self.Temp2  = self.Temp+524288
    self.Mask   = _new('unsigned char[524288]')--0.5MB
    self.缓存   = {}
end


function map:取障碍()
    if self.Flag=='0.1M' then
        local Clen = (self.MapColNum-1)*16 --定位下一行
        local Blen = self.MapColNum*192 --定位块起始
        local n,w,c,Flag = 0
        local cell = _new('unsigned char[192]')
        local t1,int   = self.Temp,self.int
        for h=0,self.MapRowNum-1 do
            for l=0,self.MapColNum-1 do
                self.File:移动读写位置(self.MapList[n]);n=n+1
                self.File:读入数据(int)--附近遮罩数量
                if int[0]>0 then --(MAPX只记录数量)
                    self.File:移动读写位置(int[0]*4,self.File.SEEK_CUR)
                end
                repeat
                    self.File:读入数据(self.Block)
                    Flag = _string(self.Block.Flag,4)
                    if Flag == 'LLEC' then
                        self.File:读入数据(cell,self.Block.Size)
                        w = h*Blen+l*16
                        c = 0
                        for hh=1,12 do
                            for ll=1,16 do
                                t1[w]=cell[c]
                                w=w+1;c=c+1
                            end
                            w=w+Clen
                        end
                        break
                    elseif Flag == "\0\0\0\0" then
                        break
                    else
                        self.File:移动读写位置(self.Block.Size,self.File.SEEK_CUR)
                    end
                until false
            end
        end
        return ffi.getptr(t1),self.MapNum*192
    end
end


return map