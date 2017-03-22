function Print(text, isError)
	if isError then
		print('<font color=\'#0099FF\'><b>[PewPacketLib]</b> </font> <font color=\'#FF0000\'>'..text..'</font>')
		return
	end
	print('<font color=\'#0099FF\'><b>[PewPacketLib]</b> </font> <font color=\'#FF6600\'>'..text..'</font>')
end

class "PewLibUpdate"
local version = 7.6
function PewLibUpdate:__init(LocalVersion,UseHttps, Host, VersionPath, ScriptPath, SavePath, CallbackUpdate, CallbackNoUpdate, CallbackNewVersion,CallbackError)
  self.LocalVersion = version
  self.Host = 'raw.githubusercontent.com'
  self.VersionPath = '/BoL/TCPUpdater/GetScript5.php?script='..self:Base64Encode(self.Host..'/PewPewPew2/BoL/master/Versions/PewPacketLib.version')..'&rand='..math.random(99999999)
  self.ScriptPath = '/BoL/TCPUpdater/GetScript5.php?script='..self:Base64Encode(self.Host..'/PewPewPew2/BoL/master/PewPacketLib.lua')..'&rand='..math.random(99999999)
  self.SavePath = LIB_PATH..'\\PewPacketLib.lua'
	self.CallbackUpdate = function() Print('Update complete, please reload (F9 F9)', true) end
	self.CallbackNoUpdate = function() return end
	self.CallbackNewVersion = function() Print('New version found, downloading now...', true) end
	self.CallbackError = function() Print('Error during download.', true) end
  self:CreateSocket(self.VersionPath)
  self.DownloadStatus = 'Connect to Server for VersionInfo'
  AddTickCallback(function() self:GetOnlineVersion() end)
end

function PewLibUpdate:CreateSocket(url)
    if not self.LuaSocket then
        self.LuaSocket = require("socket")
    else
        self.Socket:close()
        self.Socket = nil
        self.Size = nil
        self.RecvStarted = false
    end
    self.LuaSocket = require("socket")
    self.Socket = self.LuaSocket.tcp()
    self.Socket:settimeout(0, 'b')
    self.Socket:settimeout(99999999, 't')
    self.Socket:connect('sx-bol.eu', 80)
    self.Url = url
    self.Started = false
    self.LastPrint = ""
    self.File = ""
end

function PewLibUpdate:Base64Encode(data)
    local b='ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
    return ((data:gsub('.', function(x)
        local r,b='',x:byte()
        for i=8,1,-1 do r=r..(b%2^i-b%2^(i-1)>0 and '1' or '0') end
        return r;
    end)..'0000'):gsub('%d%d%d?%d?%d?%d?', function(x)
        if (#x < 6) then return '' end
        local c=0
        for i=1,6 do c=c+(x:sub(i,i)=='1' and 2^(6-i) or 0) end
        return b:sub(c+1,c+1)
    end)..({ '', '==', '=' })[#data%3+1])
end

function PewLibUpdate:GetOnlineVersion()
    if self.GotScriptVersion then return end

    self.Receive, self.Status, self.Snipped = self.Socket:receive(1024)
    if self.Status == 'timeout' and not self.Started then
        self.Started = true
        self.Socket:send("GET "..self.Url.." HTTP/1.1\r\nHost: sx-bol.eu\r\n\r\n")
    end
    if (self.Receive or (#self.Snipped > 0)) and not self.RecvStarted then
        self.RecvStarted = true
        self.DownloadStatus = 'Downloading VersionInfo (0%)'
    end

    self.File = self.File .. (self.Receive or self.Snipped)
    if self.File:find('</s'..'ize>') then
        if not self.Size then
            self.Size = tonumber(self.File:sub(self.File:find('<si'..'ze>')+6,self.File:find('</si'..'ze>')-1))
        end
        if self.File:find('<scr'..'ipt>') then
            local _,ScriptFind = self.File:find('<scr'..'ipt>')
            local ScriptEnd = self.File:find('</scr'..'ipt>')
            if ScriptEnd then ScriptEnd = ScriptEnd - 1 end
            local DownloadedSize = self.File:sub(ScriptFind+1,ScriptEnd or -1):len()
            self.DownloadStatus = 'Downloading VersionInfo ('..math.round(100/self.Size*DownloadedSize,2)..'%)'
        end
    end
    if self.File:find('</scr'..'ipt>') then
        self.DownloadStatus = 'Downloading VersionInfo (100%)'
        local a,b = self.File:find('\r\n\r\n')
        self.File = self.File:sub(a,-1)
        self.NewFile = ''
        for line,content in ipairs(self.File:split('\n')) do
            if content:len() > 5 then
                self.NewFile = self.NewFile .. content
            end
        end
        local HeaderEnd, ContentStart = self.File:find('<scr'..'ipt>')
        local ContentEnd, _ = self.File:find('</sc'..'ript>')
        if not ContentStart or not ContentEnd then
            if self.CallbackError and type(self.CallbackError) == 'function' then
                self.CallbackError()
            end
        else
            self.OnlineVersion = (Base64Decode(self.File:sub(ContentStart + 1,ContentEnd-1)))
            self.OnlineVersion = tonumber(self.OnlineVersion)
            if self.OnlineVersion > self.LocalVersion then
                if self.CallbackNewVersion and type(self.CallbackNewVersion) == 'function' then
                    self.CallbackNewVersion(self.OnlineVersion,self.LocalVersion)
                end
                self:CreateSocket(self.ScriptPath)
                self.DownloadStatus = 'Connect to Server for ScriptDownload'
                AddTickCallback(function() self:DownloadUpdate() end)
            else
                if self.CallbackNoUpdate and type(self.CallbackNoUpdate) == 'function' then
                    self.CallbackNoUpdate(self.LocalVersion)
                end
            end
        end
        self.GotScriptVersion = true
    end
end

function PewLibUpdate:DownloadUpdate()
    if self.GotScriptUpdate then return end
    self.Receive, self.Status, self.Snipped = self.Socket:receive(1024)
    if self.Status == 'timeout' and not self.Started then
        self.Started = true
        self.Socket:send("GET "..self.Url.." HTTP/1.1\r\nHost: sx-bol.eu\r\n\r\n")
    end
    if (self.Receive or (#self.Snipped > 0)) and not self.RecvStarted then
        self.RecvStarted = true
        self.DownloadStatus = 'Downloading Script (0%)'
    end

    self.File = self.File .. (self.Receive or self.Snipped)
    if self.File:find('</si'..'ze>') then
        if not self.Size then
            self.Size = tonumber(self.File:sub(self.File:find('<si'..'ze>')+6,self.File:find('</si'..'ze>')-1))
        end
        if self.File:find('<scr'..'ipt>') then
            local _,ScriptFind = self.File:find('<scr'..'ipt>')
            local ScriptEnd = self.File:find('</scr'..'ipt>')
            if ScriptEnd then ScriptEnd = ScriptEnd - 1 end
            local DownloadedSize = self.File:sub(ScriptFind+1,ScriptEnd or -1):len()
            self.DownloadStatus = 'Downloading Script ('..math.round(100/self.Size*DownloadedSize,2)..'%)'
        end
    end
    if self.File:find('</scr'..'ipt>') then
        self.DownloadStatus = 'Downloading Script (100%)'
        local a,b = self.File:find('\r\n\r\n')
        self.File = self.File:sub(a,-1)
        self.NewFile = ''
        for line,content in ipairs(self.File:split('\n')) do
            if content:len() > 5 then
                self.NewFile = self.NewFile .. content
            end
        end
        local HeaderEnd, ContentStart = self.NewFile:find('<sc'..'ript>')
        local ContentEnd, _ = self.NewFile:find('</scr'..'ipt>')
        if not ContentStart or not ContentEnd then
            if self.CallbackError and type(self.CallbackError) == 'function' then
                self.CallbackError()
            end
        else
            local newf = self.NewFile:sub(ContentStart+1,ContentEnd-1)
            local newf = newf:gsub('\r','')
            if newf:len() ~= self.Size then
                if self.CallbackError and type(self.CallbackError) == 'function' then
                    self.CallbackError()
                end
                return
            end
            local newf = Base64Decode(newf)
            if type(load(newf)) ~= 'function' then
                if self.CallbackError and type(self.CallbackError) == 'function' then
                    self.CallbackError()
                end
            else
                local f = io.open(self.SavePath,"w+b")
                f:write(newf)
                f:close()
                if self.CallbackUpdate and type(self.CallbackUpdate) == 'function' then
                    self.CallbackUpdate(self.OnlineVersion,self.LocalVersion)
                end
            end
        end
        self.GotScriptUpdate = true
    end
end

if PewUpdate then  
  PewUpdate(version, 
    LIB_PATH..'/PewPacketLib.lua', 
    'raw.githubusercontent.com', 
    '/PewPewPew2/BoL/master/Versions/PewPacketLib.version', 
    nil,
    '/PewPewPew2/BoL/master/PewPacketLib.lua', 
    function() return end, 
    function() Print('New version found, downloading now...', true) end, 
    function() Print('Update complete, please reload (F9 F9)', true) end,
    function() Print('Error during download.', true) end
  ) 
else  
  PewLibUpdate()
end

local GameVersion = GetGameVersion():sub(1,4)

function GetAggroPacketData()
	local _data = {
		['7.5.'] = {
			['GainAggro'] = { ['Header'] = 0x012C, ['targetPos'] = 52, },
			['LoseAggro'] = { ['Header'] = 0x003E, },		
			['table'] = {[0x00] = 0x4C, [0x01] = 0xCD, [0x02] = 0xF9, [0x03] = 0x53, [0x04] = 0xF8, [0x05] = 0x79, [0x06] = 0x04, [0x07] = 0x5E, [0x08] = 0x6A, [0x09] = 0x7B, [0x0A] = 0x56, [0x0B] = 0xA6, [0x0C] = 0xAE, [0x0D] = 0x15, [0x0E] = 0x09, [0x0F] = 0xB4, [0x10] = 0x40, [0x11] = 0x0C, [0x12] = 0xA1, [0x13] = 0xC6, [0x14] = 0x7A, [0x15] = 0x3C, [0x16] = 0xA4, [0x17] = 0x1D, [0x18] = 0xB7, [0x19] = 0x98, [0x1A] = 0xB5, [0x1B] = 0x6B, [0x1C] = 0xD0, [0x1D] = 0xBC, [0x1E] = 0x7C, [0x1F] = 0xAF, [0x20] = 0xD1, [0x21] = 0x0D, [0x22] = 0xEF, [0x23] = 0xEE, [0x24] = 0x63, [0x25] = 0x0E, [0x26] = 0xD5, [0x27] = 0xA5, [0x28] = 0x46, [0x29] = 0xAA, [0x2A] = 0xB6, [0x2B] = 0x96, [0x2C] = 0x5B, [0x2D] = 0xD4, [0x2E] = 0xC1, [0x2F] = 0xE1, [0x30] = 0xC0, [0x31] = 0x44, [0x32] = 0x85, [0x33] = 0x4B, [0x34] = 0xFD, [0x35] = 0xD2, [0x36] = 0xF1, [0x37] = 0x92, [0x38] = 0x74, [0x39] = 0x60, [0x3A] = 0x54, [0x3B] = 0x99, [0x3C] = 0x27, [0x3D] = 0x68, [0x3E] = 0x77, [0x3F] = 0xCA, [0x40] = 0x41, [0x41] = 0x33, [0x42] = 0x8E, [0x43] = 0xE3, [0x44] = 0x28, [0x45] = 0x9D, [0x46] = 0x58, [0x47] = 0x9E, [0x48] = 0xF3, [0x49] = 0x20, [0x4A] = 0xBD, [0x4B] = 0x2F, [0x4C] = 0x13, [0x4D] = 0xC7, [0x4E] = 0xFC, [0x4F] = 0xC2, [0x50] = 0xA2, [0x51] = 0x87, [0x52] = 0x05, [0x53] = 0xFF, [0x54] = 0xF5, [0x55] = 0x90, [0x56] = 0xEA, [0x57] = 0x51, [0x58] = 0xC5, [0x59] = 0x91, [0x5A] = 0x88, [0x5B] = 0x43, [0x5C] = 0x59, [0x5D] = 0x7E, [0x5E] = 0xE2, [0x5F] = 0xDB, [0x60] = 0x12, [0x61] = 0x67, [0x62] = 0xDD, [0x63] = 0x1A, [0x64] = 0xB2, [0x65] = 0x31, [0x66] = 0x3E, [0x67] = 0x8C, [0x68] = 0x89, [0x69] = 0x39, [0x6A] = 0x32, [0x6B] = 0x16, [0x6C] = 0xF0, [0x6D] = 0x1C, [0x6E] = 0x80, [0x6F] = 0x0F, [0x70] = 0xF4, [0x71] = 0xF2, [0x72] = 0x86, [0x73] = 0x6C, [0x74] = 0x37, [0x75] = 0xB3, [0x76] = 0x2C, [0x77] = 0x0A, [0x78] = 0xED, [0x79] = 0x52, [0x7A] = 0xBE, [0x7B] = 0x2B, [0x7C] = 0xF6, [0x7D] = 0x61, [0x7E] = 0x14, [0x7F] = 0x93, [0x80] = 0x30, [0x81] = 0x02, [0x82] = 0x11, [0x83] = 0xA9, [0x84] = 0xB0, [0x85] = 0xCC, [0x86] = 0xB1, [0x87] = 0xB8, [0x88] = 0xE8, [0x89] = 0xDE, [0x8A] = 0xC8, [0x8B] = 0x1B, [0x8C] = 0xCE, [0x8D] = 0x57, [0x8E] = 0x64, [0x8F] = 0xDF, [0x90] = 0x2D, [0x91] = 0xAB, [0x92] = 0x6D, [0x93] = 0xD7, [0x94] = 0xFA, [0x95] = 0x26, [0x96] = 0xDC, [0x97] = 0x8B, [0x98] = 0xA7, [0x99] = 0x66, [0x9A] = 0xFB, [0x9B] = 0x83, [0x9C] = 0xE9, [0x9D] = 0xDA, [0x9E] = 0x50, [0x9F] = 0x1F, [0xA0] = 0x8D, [0xA1] = 0xE5, [0xA2] = 0x72, [0xA3] = 0x5A, [0xA4] = 0xE6, [0xA5] = 0x42, [0xA6] = 0x10, [0xA7] = 0x78, [0xA8] = 0x9C, [0xA9] = 0x8A, [0xAA] = 0xD3, [0xAB] = 0x21, [0xAC] = 0x94, [0xAD] = 0x6E, [0xAE] = 0xD6, [0xAF] = 0xBB, [0xB0] = 0x81, [0xB1] = 0x00, [0xB2] = 0xAD, [0xB3] = 0x55, [0xB4] = 0x97, [0xB5] = 0x9A, [0xB6] = 0x08, [0xB7] = 0x29, [0xB8] = 0x9B, [0xB9] = 0x4A, [0xBA] = 0x36, [0xBB] = 0x3F, [0xBC] = 0xC3, [0xBD] = 0x7D, [0xBE] = 0xC4, [0xBF] = 0xEC, [0xC0] = 0x22, [0xC1] = 0x35, [0xC2] = 0x17, [0xC3] = 0x2E, [0xC4] = 0xD9, [0xC5] = 0x8F, [0xC6] = 0xBF, [0xC7] = 0x06, [0xC8] = 0x45, [0xC9] = 0x95, [0xCA] = 0x73, [0xCB] = 0xEB, [0xCC] = 0xA3, [0xCD] = 0xB9, [0xCE] = 0xCB, [0xCF] = 0x0B, [0xD0] = 0x18, [0xD1] = 0x5F, [0xD2] = 0x1E, [0xD3] = 0x76, [0xD4] = 0x5C, [0xD5] = 0x23, [0xD6] = 0x82, [0xD7] = 0xBA, [0xD8] = 0x34, [0xD9] = 0x5D, [0xDA] = 0x24, [0xDB] = 0x19, [0xDC] = 0x01, [0xDD] = 0xE0, [0xDE] = 0x4E, [0xDF] = 0x2A, [0xE0] = 0x7F, [0xE1] = 0x3B, [0xE2] = 0xE4, [0xE3] = 0x69, [0xE4] = 0x3A, [0xE5] = 0xA0, [0xE6] = 0xF7, [0xE7] = 0x3D, [0xE8] = 0x38, [0xE9] = 0xCF, [0xEA] = 0x25, [0xEB] = 0xD8, [0xEC] = 0x75, [0xED] = 0x62, [0xEE] = 0x84, [0xEF] = 0xFE, [0xF0] = 0x71, [0xF1] = 0xE7, [0xF2] = 0x49, [0xF3] = 0x48, [0xF4] = 0x6F, [0xF5] = 0xA8, [0xF6] = 0x4F, [0xF7] = 0x47, [0xF8] = 0x03, [0xF9] = 0xAC, [0xFA] = 0x07, [0xFB] = 0xC9, [0xFC] = 0x70, [0xFD] = 0x4D, [0xFE] = 0x65, [0xFF] = 0x9F, },
		},
		['7.6.'] = {
			['GainAggro'] = { ['Header'] = 0x007C, ['targetPos'] = 30, },
			['LoseAggro'] = { ['Header'] = 0x000B, },		
			['table'] = {[0x00] = 0x58, [0x01] = 0x48, [0x02] = 0x46, [0x03] = 0x54, [0x04] = 0x5C, [0x05] = 0x4C, [0x06] = 0x40, [0x07] = 0x56, [0x08] = 0x5E, [0x09] = 0x4E, [0x0A] = 0x44, [0x0B] = 0xD2, [0x0C] = 0xDA, [0x0D] = 0xCA, [0x0E] = 0xE2, [0x0F] = 0xF0, [0x10] = 0xF8, [0x11] = 0xE8, [0x12] = 0xE6, [0x13] = 0xF4, [0x14] = 0xFC, [0x15] = 0xEC, [0x16] = 0xE0, [0x17] = 0xF6, [0x18] = 0xFE, [0x19] = 0xEE, [0x1A] = 0xE4, [0x1B] = 0x13, [0x1C] = 0x1B, [0x1D] = 0x0B, [0x1E] = 0x83, [0x1F] = 0x91, [0x20] = 0x99, [0x21] = 0x89, [0x22] = 0x87, [0x23] = 0x95, [0x24] = 0x9D, [0x25] = 0x8D, [0x26] = 0x81, [0x27] = 0x97, [0x28] = 0x9F, [0x29] = 0x8F, [0x2A] = 0x85, [0x2B] = 0x12, [0x2C] = 0x1A, [0x2D] = 0x0A, [0x2E] = 0x03, [0x2F] = 0x11, [0x30] = 0x19, [0x31] = 0x09, [0x32] = 0x07, [0x33] = 0x15, [0x34] = 0x1D, [0x35] = 0x0D, [0x36] = 0x01, [0x37] = 0x17, [0x38] = 0x1F, [0x39] = 0x0F, [0x3A] = 0x05, [0x3B] = 0x93, [0x3C] = 0x9B, [0x3D] = 0x8B, [0x3E] = 0x02, [0x3F] = 0x10, [0x40] = 0x18, [0x41] = 0x08, [0x42] = 0x06, [0x43] = 0x14, [0x44] = 0x1C, [0x45] = 0x0C, [0x46] = 0x00, [0x47] = 0x16, [0x48] = 0x1E, [0x49] = 0x0E, [0x4A] = 0x04, [0x4B] = 0x92, [0x4C] = 0x9A, [0x4D] = 0x8A, [0x4E] = 0xC2, [0x4F] = 0xD0, [0x50] = 0xD8, [0x51] = 0xC8, [0x52] = 0xC6, [0x53] = 0xD4, [0x54] = 0xDC, [0x55] = 0xCC, [0x56] = 0xC0, [0x57] = 0xD6, [0x58] = 0xDE, [0x59] = 0xCE, [0x5A] = 0xC4, [0x5B] = 0x73, [0x5C] = 0x7B, [0x5D] = 0x6B, [0x5E] = 0xE3, [0x5F] = 0xF1, [0x60] = 0xF9, [0x61] = 0xE9, [0x62] = 0xE7, [0x63] = 0xF5, [0x64] = 0xFD, [0x65] = 0xED, [0x66] = 0xE1, [0x67] = 0xF7, [0x68] = 0xFF, [0x69] = 0xEF, [0x6A] = 0xE5, [0x6B] = 0x72, [0x6C] = 0x7A, [0x6D] = 0x6A, [0x6E] = 0x63, [0x6F] = 0x71, [0x70] = 0x79, [0x71] = 0x69, [0x72] = 0x67, [0x73] = 0x75, [0x74] = 0x7D, [0x75] = 0x6D, [0x76] = 0x61, [0x77] = 0x77, [0x78] = 0x7F, [0x79] = 0x6F, [0x7A] = 0x65, [0x7B] = 0xF3, [0x7C] = 0xFB, [0x7D] = 0xEB, [0x7E] = 0x62, [0x7F] = 0x70, [0x80] = 0x78, [0x81] = 0x68, [0x82] = 0x66, [0x83] = 0x74, [0x84] = 0x7C, [0x85] = 0x6C, [0x86] = 0x60, [0x87] = 0x76, [0x88] = 0x7E, [0x89] = 0x6E, [0x8A] = 0x64, [0x8B] = 0xF2, [0x8C] = 0xFA, [0x8D] = 0xEA, [0x8E] = 0x82, [0x8F] = 0x90, [0x90] = 0x98, [0x91] = 0x88, [0x92] = 0x86, [0x93] = 0x94, [0x94] = 0x9C, [0x95] = 0x8C, [0x96] = 0x80, [0x97] = 0x96, [0x98] = 0x9E, [0x99] = 0x8E, [0x9A] = 0x84, [0x9B] = 0x33, [0x9C] = 0x3B, [0x9D] = 0x2B, [0x9E] = 0xA3, [0x9F] = 0xB1, [0xA0] = 0xB9, [0xA1] = 0xA9, [0xA2] = 0xA7, [0xA3] = 0xB5, [0xA4] = 0xBD, [0xA5] = 0xAD, [0xA6] = 0xA1, [0xA7] = 0xB7, [0xA8] = 0xBF, [0xA9] = 0xAF, [0xAA] = 0xA5, [0xAB] = 0x32, [0xAC] = 0x3A, [0xAD] = 0x2A, [0xAE] = 0x23, [0xAF] = 0x31, [0xB0] = 0x39, [0xB1] = 0x29, [0xB2] = 0x27, [0xB3] = 0x35, [0xB4] = 0x3D, [0xB5] = 0x2D, [0xB6] = 0x21, [0xB7] = 0x37, [0xB8] = 0x3F, [0xB9] = 0x2F, [0xBA] = 0x25, [0xBB] = 0xB3, [0xBC] = 0xBB, [0xBD] = 0xAB, [0xBE] = 0x22, [0xBF] = 0x30, [0xC0] = 0x38, [0xC1] = 0x28, [0xC2] = 0x26, [0xC3] = 0x34, [0xC4] = 0x3C, [0xC5] = 0x2C, [0xC6] = 0x20, [0xC7] = 0x36, [0xC8] = 0x3E, [0xC9] = 0x2E, [0xCA] = 0x24, [0xCB] = 0xB2, [0xCC] = 0xBA, [0xCD] = 0xAA, [0xCE] = 0xA2, [0xCF] = 0xB0, [0xD0] = 0xB8, [0xD1] = 0xA8, [0xD2] = 0xA6, [0xD3] = 0xB4, [0xD4] = 0xBC, [0xD5] = 0xAC, [0xD6] = 0xA0, [0xD7] = 0xB6, [0xD8] = 0xBE, [0xD9] = 0xAE, [0xDA] = 0xA4, [0xDB] = 0x53, [0xDC] = 0x5B, [0xDD] = 0x4B, [0xDE] = 0xC3, [0xDF] = 0xD1, [0xE0] = 0xD9, [0xE1] = 0xC9, [0xE2] = 0xC7, [0xE3] = 0xD5, [0xE4] = 0xDD, [0xE5] = 0xCD, [0xE6] = 0xC1, [0xE7] = 0xD7, [0xE8] = 0xDF, [0xE9] = 0xCF, [0xEA] = 0xC5, [0xEB] = 0x52, [0xEC] = 0x5A, [0xED] = 0x4A, [0xEE] = 0x43, [0xEF] = 0x51, [0xF0] = 0x59, [0xF1] = 0x49, [0xF2] = 0x47, [0xF3] = 0x55, [0xF4] = 0x5D, [0xF5] = 0x4D, [0xF6] = 0x41, [0xF7] = 0x57, [0xF8] = 0x5F, [0xF9] = 0x4F, [0xFA] = 0x45, [0xFB] = 0xD3, [0xFC] = 0xDB, [0xFD] = 0xCB, [0xFE] = 0x42, [0xFF] = 0x50, },
		},
		['7.4.'] = {
			['GainAggro'] = { ['Header'] = 0x017F, ['targetPos'] = 43, },
			['LoseAggro'] = { ['Header'] = 0x0069, },		
			['table'] = {[0x00] = 0x17, [0x01] = 0x57, [0x02] = 0x37, [0x03] = 0x77, [0x04] = 0x27, [0x05] = 0x67, [0x06] = 0x47, [0x07] = 0x87, [0x08] = 0x1F, [0x09] = 0x5F, [0x0A] = 0x3F, [0x0B] = 0x7F, [0x0C] = 0x2F, [0x0D] = 0x6F, [0x0E] = 0x4F, [0x0F] = 0x8F, [0x10] = 0x13, [0x11] = 0x53, [0x12] = 0x33, [0x13] = 0x73, [0x14] = 0x23, [0x15] = 0x63, [0x16] = 0x43, [0x17] = 0x83, [0x18] = 0x1B, [0x19] = 0x5B, [0x1A] = 0x3B, [0x1B] = 0x7B, [0x1C] = 0x2B, [0x1D] = 0x6B, [0x1E] = 0x4B, [0x1F] = 0x8B, [0x20] = 0x15, [0x21] = 0x55, [0x22] = 0x35, [0x23] = 0x75, [0x24] = 0x25, [0x25] = 0x65, [0x26] = 0x45, [0x27] = 0x85, [0x28] = 0x1D, [0x29] = 0x5D, [0x2A] = 0x3D, [0x2B] = 0x7D, [0x2C] = 0x2D, [0x2D] = 0x6D, [0x2E] = 0x4D, [0x2F] = 0x8D, [0x30] = 0x11, [0x31] = 0x51, [0x32] = 0x31, [0x33] = 0x71, [0x34] = 0x21, [0x35] = 0x61, [0x36] = 0x41, [0x37] = 0x81, [0x38] = 0x19, [0x39] = 0x59, [0x3A] = 0x39, [0x3B] = 0x79, [0x3C] = 0x29, [0x3D] = 0x69, [0x3E] = 0x49, [0x3F] = 0x89, [0x40] = 0x16, [0x41] = 0x56, [0x42] = 0x36, [0x43] = 0x76, [0x44] = 0x26, [0x45] = 0x66, [0x46] = 0x46, [0x47] = 0x86, [0x48] = 0x1E, [0x49] = 0x5E, [0x4A] = 0x3E, [0x4B] = 0x7E, [0x4C] = 0x2E, [0x4D] = 0x6E, [0x4E] = 0x4E, [0x4F] = 0x8E, [0x50] = 0x12, [0x51] = 0x52, [0x52] = 0x32, [0x53] = 0x72, [0x54] = 0x22, [0x55] = 0x62, [0x56] = 0x42, [0x57] = 0x82, [0x58] = 0x1A, [0x59] = 0x5A, [0x5A] = 0x3A, [0x5B] = 0x7A, [0x5C] = 0x2A, [0x5D] = 0x6A, [0x5E] = 0x4A, [0x5F] = 0x8A, [0x60] = 0x14, [0x61] = 0x54, [0x62] = 0x34, [0x63] = 0x74, [0x64] = 0x24, [0x65] = 0x64, [0x66] = 0x44, [0x67] = 0x84, [0x68] = 0x1C, [0x69] = 0x5C, [0x6A] = 0x3C, [0x6B] = 0x7C, [0x6C] = 0x2C, [0x6D] = 0x6C, [0x6E] = 0x4C, [0x6F] = 0x8C, [0x70] = 0x10, [0x71] = 0x50, [0x72] = 0x30, [0x73] = 0x70, [0x74] = 0x20, [0x75] = 0x60, [0x76] = 0x40, [0x77] = 0x80, [0x78] = 0x18, [0x79] = 0x58, [0x7A] = 0x38, [0x7B] = 0x78, [0x7C] = 0x28, [0x7D] = 0x68, [0x7E] = 0x48, [0x7F] = 0x88, [0x80] = 0x97, [0x81] = 0xD7, [0x82] = 0xB7, [0x83] = 0xF7, [0x84] = 0xA7, [0x85] = 0xE7, [0x86] = 0xC7, [0x87] = 0x07, [0x88] = 0x9F, [0x89] = 0xDF, [0x8A] = 0xBF, [0x8B] = 0xFF, [0x8C] = 0xAF, [0x8D] = 0xEF, [0x8E] = 0xCF, [0x8F] = 0x0F, [0x90] = 0x93, [0x91] = 0xD3, [0x92] = 0xB3, [0x93] = 0xF3, [0x94] = 0xA3, [0x95] = 0xE3, [0x96] = 0xC3, [0x97] = 0x03, [0x98] = 0x9B, [0x99] = 0xDB, [0x9A] = 0xBB, [0x9B] = 0xFB, [0x9C] = 0xAB, [0x9D] = 0xEB, [0x9E] = 0xCB, [0x9F] = 0x0B, [0xA0] = 0x95, [0xA1] = 0xD5, [0xA2] = 0xB5, [0xA3] = 0xF5, [0xA4] = 0xA5, [0xA5] = 0xE5, [0xA6] = 0xC5, [0xA7] = 0x05, [0xA8] = 0x9D, [0xA9] = 0xDD, [0xAA] = 0xBD, [0xAB] = 0xFD, [0xAC] = 0xAD, [0xAD] = 0xED, [0xAE] = 0xCD, [0xAF] = 0x0D, [0xB0] = 0x91, [0xB1] = 0xD1, [0xB2] = 0xB1, [0xB3] = 0xF1, [0xB4] = 0xA1, [0xB5] = 0xE1, [0xB6] = 0xC1, [0xB7] = 0x01, [0xB8] = 0x99, [0xB9] = 0xD9, [0xBA] = 0xB9, [0xBB] = 0xF9, [0xBC] = 0xA9, [0xBD] = 0xE9, [0xBE] = 0xC9, [0xBF] = 0x09, [0xC0] = 0x96, [0xC1] = 0xD6, [0xC2] = 0xB6, [0xC3] = 0xF6, [0xC4] = 0xA6, [0xC5] = 0xE6, [0xC6] = 0xC6, [0xC7] = 0x06, [0xC8] = 0x9E, [0xC9] = 0xDE, [0xCA] = 0xBE, [0xCB] = 0xFE, [0xCC] = 0xAE, [0xCD] = 0xEE, [0xCE] = 0xCE, [0xCF] = 0x0E, [0xD0] = 0x92, [0xD1] = 0xD2, [0xD2] = 0xB2, [0xD3] = 0xF2, [0xD4] = 0xA2, [0xD5] = 0xE2, [0xD6] = 0xC2, [0xD7] = 0x02, [0xD8] = 0x9A, [0xD9] = 0xDA, [0xDA] = 0xBA, [0xDB] = 0xFA, [0xDC] = 0xAA, [0xDD] = 0xEA, [0xDE] = 0xCA, [0xDF] = 0x0A, [0xE0] = 0x94, [0xE1] = 0xD4, [0xE2] = 0xB4, [0xE3] = 0xF4, [0xE4] = 0xA4, [0xE5] = 0xE4, [0xE6] = 0xC4, [0xE7] = 0x04, [0xE8] = 0x9C, [0xE9] = 0xDC, [0xEA] = 0xBC, [0xEB] = 0xFC, [0xEC] = 0xAC, [0xED] = 0xEC, [0xEE] = 0xCC, [0xEF] = 0x0C, [0xF0] = 0x90, [0xF1] = 0xD0, [0xF2] = 0xB0, [0xF3] = 0xF0, [0xF4] = 0xA0, [0xF5] = 0xE0, [0xF6] = 0xC0, [0xF7] = 0x00, [0xF8] = 0x98, [0xF9] = 0xD8, [0xFA] = 0xB8, [0xFB] = 0xF8, [0xFC] = 0xA8, [0xFD] = 0xE8, [0xFE] = 0xC8, [0xFF] = 0x08, },
		},
	}
	return _data[GameVersion]
end

function GetLoseVisionPacketData()
	local _data = {
		['7.4.'] = {
			['Header'] = 0x00C2,
			['Pos'] = 2,	
		},
		['7.5.'] = {
			['Header'] = 0x0178,
			['Pos'] = 2,
		},
		['7.6.'] = {
			['Header'] = 0x0023, 
			['Pos'] = 2,	
		},
	}
	return _data[GameVersion]
end

function GetGainVisionPacketData()
	local _data = {
		['7.4.'] = {
			['Header'] = 0x001E, 
			['pos'] = 2,
		},
		['7.5.'] = { 
			['Header'] = 0x0052, 
			['pos'] = 2,
		},
		['7.6.'] = {
			['Header'] = 0x003E, 
			['pos'] = 2,	
		},
	}
	return _data[GameVersion]
end

function GetMasteryEmoteData()
	local cVersion = GetGameVersion()
	if cVersion:find('7.4.176.9828') then
		return {
			['Header'] = 0x0058,
			['vTable'] = 0x10B9D60,
			['hash'] = 0xE8E8E8E8,
		}
	elseif cVersion:find('7.6.180.6903') then
		return {
			['Header'] = 0x007B,
			['vTable'] = 0xFA22AC,
			['hash'] = 0xBEBEBEBE,
		}
	elseif cVersion:find('7.5.178.6069') then
		return {
			['Header'] = 0x012F,
			['vTable'] = 0xF6F754,
			['hash'] = 0xAFAFAFAF,
		}
	end
end
