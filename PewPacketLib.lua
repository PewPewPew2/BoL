function Print(text, isError)
	if isError then
		print('<font color=\'#0099FF\'><b>[PewPacketLib]</b> </font> <font color=\'#FF0000\'>'..text..'</font>')
		return
	end
	print('<font color=\'#0099FF\'><b>[PewPacketLib]</b> </font> <font color=\'#FF6600\'>'..text..'</font>')
end

class "PewLibUpdate"
local version = 7.2
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
		['7.2.'] = {
			['GainAggro'] = { ['Header'] = 0x0122, ['targetPos'] = 11, },
			['LoseAggro'] = { ['Header'] = 0x016C, },		
			['table'] = {[0x00] = 0xAF, [0x01] = 0x8F, [0x02] = 0xB7, [0x03] = 0x97, [0x04] = 0xA7, [0x05] = 0x87, [0x06] = 0xBF, [0x07] = 0x9F, [0x08] = 0xAB, [0x09] = 0x8B, [0x0A] = 0xB3, [0x0B] = 0x93, [0x0C] = 0xA3, [0x0D] = 0x83, [0x0E] = 0xBB, [0x0F] = 0x9B, [0x10] = 0x4C, [0x11] = 0x7C, [0x12] = 0x54, [0x13] = 0x6C, [0x14] = 0x44, [0x15] = 0x74, [0x16] = 0x5C, [0x17] = 0x64, [0x18] = 0x48, [0x19] = 0x78, [0x1A] = 0x50, [0x1B] = 0x68, [0x1C] = 0x40, [0x1D] = 0x70, [0x1E] = 0x58, [0x1F] = 0x60, [0x20] = 0xAE, [0x21] = 0x8E, [0x22] = 0xB6, [0x23] = 0x96, [0x24] = 0xA6, [0x25] = 0x86, [0x26] = 0xBE, [0x27] = 0x9E, [0x28] = 0xAA, [0x29] = 0x8A, [0x2A] = 0xB2, [0x2B] = 0x92, [0x2C] = 0xA2, [0x2D] = 0x82, [0x2E] = 0xBA, [0x2F] = 0x9A, [0x30] = 0xAD, [0x31] = 0x8D, [0x32] = 0xB5, [0x33] = 0x95, [0x34] = 0xA5, [0x35] = 0x85, [0x36] = 0xBD, [0x37] = 0x9D, [0x38] = 0xA9, [0x39] = 0x89, [0x3A] = 0xB1, [0x3B] = 0x91, [0x3C] = 0xA1, [0x3D] = 0x81, [0x3E] = 0xB9, [0x3F] = 0x99, [0x40] = 0x2F, [0x41] = 0x0F, [0x42] = 0x37, [0x43] = 0x17, [0x44] = 0x27, [0x45] = 0x07, [0x46] = 0x3F, [0x47] = 0x1F, [0x48] = 0x2B, [0x49] = 0x0B, [0x4A] = 0x33, [0x4B] = 0x13, [0x4C] = 0x23, [0x4D] = 0x03, [0x4E] = 0x3B, [0x4F] = 0x1B, [0x50] = 0xAC, [0x51] = 0x8C, [0x52] = 0xB4, [0x53] = 0x94, [0x54] = 0xA4, [0x55] = 0x84, [0x56] = 0xBC, [0x57] = 0x9C, [0x58] = 0xA8, [0x59] = 0x88, [0x5A] = 0xB0, [0x5B] = 0x90, [0x5C] = 0xA0, [0x5D] = 0x80, [0x5E] = 0xB8, [0x5F] = 0x98, [0x60] = 0x2E, [0x61] = 0x0E, [0x62] = 0x36, [0x63] = 0x16, [0x64] = 0x26, [0x65] = 0x06, [0x66] = 0x3E, [0x67] = 0x1E, [0x68] = 0x2A, [0x69] = 0x0A, [0x6A] = 0x32, [0x6B] = 0x12, [0x6C] = 0x22, [0x6D] = 0x02, [0x6E] = 0x3A, [0x6F] = 0x1A, [0x70] = 0x2D, [0x71] = 0x0D, [0x72] = 0x35, [0x73] = 0x15, [0x74] = 0x25, [0x75] = 0x05, [0x76] = 0x3D, [0x77] = 0x1D, [0x78] = 0x29, [0x79] = 0x09, [0x7A] = 0x31, [0x7B] = 0x11, [0x7C] = 0x21, [0x7D] = 0x01, [0x7E] = 0x39, [0x7F] = 0x19, [0x80] = 0xCF, [0x81] = 0xFF, [0x82] = 0xD7, [0x83] = 0xEF, [0x84] = 0xC7, [0x85] = 0xF7, [0x86] = 0xDF, [0x87] = 0xE7, [0x88] = 0xCB, [0x89] = 0xFB, [0x8A] = 0xD3, [0x8B] = 0xEB, [0x8C] = 0xC3, [0x8D] = 0xF3, [0x8E] = 0xDB, [0x8F] = 0xE3, [0x90] = 0x0C, [0x91] = 0x3C, [0x92] = 0x14, [0x93] = 0x2C, [0x94] = 0x04, [0x95] = 0x34, [0x96] = 0x1C, [0x97] = 0x24, [0x98] = 0x08, [0x99] = 0x38, [0x9A] = 0x10, [0x9B] = 0x28, [0x9C] = 0x00, [0x9D] = 0x30, [0x9E] = 0x18, [0x9F] = 0x20, [0xA0] = 0xCE, [0xA1] = 0xFE, [0xA2] = 0xD6, [0xA3] = 0xEE, [0xA4] = 0xC6, [0xA5] = 0xF6, [0xA6] = 0xDE, [0xA7] = 0xE6, [0xA8] = 0xCA, [0xA9] = 0xFA, [0xAA] = 0xD2, [0xAB] = 0xEA, [0xAC] = 0xC2, [0xAD] = 0xF2, [0xAE] = 0xDA, [0xAF] = 0xE2, [0xB0] = 0xCD, [0xB1] = 0xFD, [0xB2] = 0xD5, [0xB3] = 0xED, [0xB4] = 0xC5, [0xB5] = 0xF5, [0xB6] = 0xDD, [0xB7] = 0xE5, [0xB8] = 0xC9, [0xB9] = 0xF9, [0xBA] = 0xD1, [0xBB] = 0xE9, [0xBC] = 0xC1, [0xBD] = 0xF1, [0xBE] = 0xD9, [0xBF] = 0xE1, [0xC0] = 0x4F, [0xC1] = 0x7F, [0xC2] = 0x57, [0xC3] = 0x6F, [0xC4] = 0x47, [0xC5] = 0x77, [0xC6] = 0x5F, [0xC7] = 0x67, [0xC8] = 0x4B, [0xC9] = 0x7B, [0xCA] = 0x53, [0xCB] = 0x6B, [0xCC] = 0x43, [0xCD] = 0x73, [0xCE] = 0x5B, [0xCF] = 0x63, [0xD0] = 0xCC, [0xD1] = 0xFC, [0xD2] = 0xD4, [0xD3] = 0xEC, [0xD4] = 0xC4, [0xD5] = 0xF4, [0xD6] = 0xDC, [0xD7] = 0xE4, [0xD8] = 0xC8, [0xD9] = 0xF8, [0xDA] = 0xD0, [0xDB] = 0xE8, [0xDC] = 0xC0, [0xDD] = 0xF0, [0xDE] = 0xD8, [0xDF] = 0xE0, [0xE0] = 0x4E, [0xE1] = 0x7E, [0xE2] = 0x56, [0xE3] = 0x6E, [0xE4] = 0x46, [0xE5] = 0x76, [0xE6] = 0x5E, [0xE7] = 0x66, [0xE8] = 0x4A, [0xE9] = 0x7A, [0xEA] = 0x52, [0xEB] = 0x6A, [0xEC] = 0x42, [0xED] = 0x72, [0xEE] = 0x5A, [0xEF] = 0x62, [0xF0] = 0x4D, [0xF1] = 0x7D, [0xF2] = 0x55, [0xF3] = 0x6D, [0xF4] = 0x45, [0xF5] = 0x75, [0xF6] = 0x5D, [0xF7] = 0x65, [0xF8] = 0x49, [0xF9] = 0x79, [0xFA] = 0x51, [0xFB] = 0x69, [0xFC] = 0x41, [0xFD] = 0x71, [0xFE] = 0x59, [0xFF] = 0x61, },
		},
		['6.24'] = {
			['GainAggro'] = { ['Header'] = 0x009B, ['targetPos'] = 36, },
			['LoseAggro'] = { ['Header'] = 0x005D, },		
			['table'] = {[0x00] = 0xD6, [0x01] = 0xE6, [0x02] = 0x3D, [0x03] = 0xC8, [0x04] = 0x23, [0x05] = 0x03, [0x06] = 0x25, [0x07] = 0x7E, [0x08] = 0x7A, [0x09] = 0x0B, [0x0A] = 0x7D, [0x0B] = 0xBC, [0x0C] = 0xBF, [0x0D] = 0x38, [0x0E] = 0x3C, [0x0F] = 0xB4, [0x10] = 0xD1, [0x11] = 0x26, [0x12] = 0xA1, [0x13] = 0xFC, [0x14] = 0x1B, [0x15] = 0xD7, [0x16] = 0xB5, [0x17] = 0x87, [0x18] = 0xED, [0x19] = 0xB3, [0x1A] = 0xA4, [0x1B] = 0x6A, [0x1C] = 0xF0, [0x1D] = 0xF7, [0x1E] = 0x17, [0x1F] = 0xAF, [0x20] = 0xE0, [0x21] = 0x3A, [0x22] = 0x4F, [0x23] = 0x5F, [0x24] = 0x69, [0x25] = 0x2F, [0x26] = 0xE4, [0x27] = 0xA5, [0x28] = 0xDC, [0x29] = 0xBA, [0x2A] = 0xFD, [0x2B] = 0xBD, [0x2C] = 0x6B, [0x2D] = 0xF4, [0x2E] = 0xE1, [0x2F] = 0x41, [0x30] = 0xF1, [0x31] = 0xD5, [0x32] = 0x05, [0x33] = 0xCA, [0x34] = 0x3B, [0x35] = 0xF8, [0x36] = 0x40,[0x37] = 0x18, [0x38] = 0x74, [0x39] = 0x71, [0x3A] = 0xD4, [0x3B] = 0xA3, [0x3C] = 0x8C, [0x3D] = 0x72, [0x3E] = 0x0D, [0x3F] = 0xFA, [0x40] = 0xC1, [0x41] = 0x88, [0x42] = 0x1F, [0x43] = 0x49, [0x44] = 0x92, [0x45] = 0xA7, [0x46] = 0x73, [0x47] = 0xBE, [0x48] = 0x48, [0x49] = 0x91, [0x4A] = 0xE7, [0x4B] = 0x8F, [0x4C] = 0x30, [0x4D] = 0xEC, [0x4E] = 0x27, [0x4F] = 0xF9, [0x50] = 0xB9, [0x51] = 0x0C, [0x52] = 0x39, [0x53] = 0x36, [0x54] = 0x44, [0x55] = 0x10, [0x56] = 0x5A, [0x57] = 0xC0, [0x58] = 0xE5, [0x59] = 0x00, [0x5A] = 0x12, [0x5B] = 0xC9, [0x5C] = 0x63, [0x5D] = 0x1E, [0x5E] = 0x59, [0x5F] = 0x4B, [0x60] = 0x28, [0x61] = 0x6C, [0x62] = 0x47, [0x63] = 0x9B, [0x64] = 0xB8, [0x65] = 0x80, [0x66] = 0xDE, [0x67] = 0x16, [0x68] = 0x02, [0x69] = 0xC3, [0x6A] = 0x98, [0x6B] = 0x9D, [0x6C] = 0x50, [0x6D] = 0x97, [0x6E] = 0x11, [0x6F] = 0x37, [0x70] = 0x54, [0x71] = 0x58, [0x72] = 0x1C, [0x73] = 0x76, [0x74] = 0xCD, [0x75] = 0xA8, [0x76] = 0x96, [0x77] = 0x2A, [0x78] = 0x46, [0x79] = 0xD8, [0x7A] = 0xFE, [0x7B] = 0x8A, [0x7C] = 0x2D, [0x7D] = 0x61, [0x7E] = 0x24, [0x7F] = 0x08, [0x80] = 0x90, [0x81] = 0x29, [0x82] = 0x3F, [0x83] = 0xA2, [0x84] = 0xB0, [0x85] = 0xF6, [0x86] = 0xA0, [0x87] = 0xF3, [0x88] = 0x52, [0x89] = 0x5E, [0x8A] = 0xF2, [0x8B] = 0x8B, [0x8C] = 0xFF, [0x8D] = 0x6D, [0x8E] = 0x75, [0x8F] = 0x4E, [0x90] = 0x86, [0x91] = 0xAA, [0x92] = 0x66, [0x93] = 0x4D, [0x94] = 0x2B, [0x95] = 0x9C, [0x96] = 0x57, [0x97] = 0x0A, [0x98] = 0xAC, [0x99] = 0x7C, [0x9A] = 0x33, [0x9B] = 0x09, [0x9C] = 0x42, [0x9D] = 0x5B, [0x9E] = 0xD0, [0x9F] = 0x8E, [0xA0] = 0x06, [0xA1] = 0x45, [0xA2] = 0x78, [0xA3] = 0x7B, [0xA4] = 0x5C, [0xA5] = 0xD9, [0xA6] = 0x20, [0xA7] = 0x13, [0xA8] = 0xB7, [0xA9] = 0x1A, [0xAA] = 0xE8, [0xAB] = 0x81, [0xAC] = 0x14, [0xAD] = 0x7F, [0xAE] = 0x5D, [0xAF] = 0xEB, [0xB0] = 0x01, [0xB1] = 0x21, [0xB2] = 0xA6, [0xB3] = 0xC4, [0xB4] = 0xAD, [0xB5] = 0xBB, [0xB6] = 0x22, [0xB7] = 0x82, [0xB8] = 0xAB, [0xB9] = 0xDA, [0xBA] = 0xDD, [0xBB] = 0xCE, [0xBC] = 0xE9, [0xBD] = 0x07, [0xBE] = 0xF5, [0xBF] = 0x56, [0xC0] = 0x99, [0xC1] = 0x84, [0xC2] = 0x8D, [0xC3] = 0x9F, [0xC4] = 0x43, [0xC5] = 0x0F, [0xC6] = 0xEE, [0xC7] = 0x2C, [0xC8] = 0xC5, [0xC9] = 0x04, [0xCA] = 0x68, [0xCB] = 0x4A, [0xCC] = 0xA9, [0xCD] = 0xE3, [0xCE] = 0xEA, [0xCF] = 0x32, [0xD0] = 0x93, [0xD1] = 0x6E, [0xD2] = 0x9E, [0xD3] = 0x1D, [0xD4] = 0x77, [0xD5] = 0x89, [0xD6] = 0x19, [0xD7] = 0xFB, [0xD8] = 0x94, [0xD9] = 0x67, [0xDA] = 0x95, [0xDB] = 0x83, [0xDC] = 0x3E, [0xDD] = 0x51, [0xDE] = 0xDF, [0xDF] = 0x9A, [0xE0] = 0x0E, [0xE1] = 0xCB, [0xE2] = 0x55, [0xE3] = 0x62, [0xE4] = 0xDB, [0xE5] = 0xB1, [0xE6] = 0x35, [0xE7] = 0xC7, [0xE8] = 0xD3, [0xE9] = 0xEF, [0xEA] = 0x85, [0xEB] = 0x53, [0xEC] = 0x64, [0xED] = 0x79, [0xEE] = 0x15, [0xEF] = 0x2E, [0xF0] = 0x60, [0xF1] = 0x4C, [0xF2] = 0xC2, [0xF3] = 0xD2, [0xF4] = 0x6F, [0xF5] = 0xB2, [0xF6] = 0xCF, [0xF7] = 0xCC, [0xF8] = 0x31, [0xF9] = 0xB6, [0xFA] = 0x34, [0xFB] = 0xE2, [0xFC] = 0x70, [0xFD] = 0xC6, [0xFE] = 0x65, [0xFF] = 0xAE, },
		},
		['7.1.'] = {
			['GainAggro'] = { ['Header'] = 0x015D, ['targetPos'] = 18, },
			['LoseAggro'] = { ['Header'] = 0x0038, },		
			['table'] = {[0x00] = 0x06, [0x01] = 0x0E, [0x02] = 0x07, [0x03] = 0x0F, [0x04] = 0x26, [0x05] = 0x2E, [0x06] = 0x27, [0x07] = 0x2F, [0x08] = 0x02, [0x09] = 0x0A, [0x0A] = 0x03, [0x0B] = 0x0B, [0x0C] = 0x22, [0x0D] = 0x2A, [0x0E] = 0x23, [0x0F] = 0x2B, [0x10] = 0x86, [0x11] = 0x8E, [0x12] = 0x87, [0x13] = 0x8F, [0x14] = 0xA6, [0x15] = 0xAE, [0x16] = 0xA7, [0x17] = 0xAF, [0x18] = 0x82, [0x19] = 0x8A, [0x1A] = 0x83, [0x1B] = 0x8B, [0x1C] = 0xA2, [0x1D] = 0xAA, [0x1E] = 0xA3, [0x1F] = 0xAB, [0x20] = 0x16, [0x21] = 0x1E, [0x22] = 0x17, [0x23] = 0x1F, [0x24] = 0x36, [0x25] = 0x3E, [0x26] = 0x37, [0x27] = 0x3F, [0x28] = 0x12, [0x29] = 0x1A, [0x2A] = 0x13, [0x2B] = 0x1B, [0x2C] = 0x32, [0x2D] = 0x3A, [0x2E] = 0x33, [0x2F] = 0x3B, [0x30] = 0x96, [0x31] = 0x9E, [0x32] = 0x97, [0x33] = 0x9F, [0x34] = 0xB6, [0x35] = 0xBE, [0x36] = 0xB7, [0x37] = 0xBF, [0x38] = 0x92, [0x39] = 0x9A, [0x3A] = 0x93, [0x3B] = 0x9B, [0x3C] = 0xB2, [0x3D] = 0xBA, [0x3E] = 0xB3, [0x3F] = 0xBB, [0x40] = 0x04, [0x41] = 0x0C, [0x42] = 0x05, [0x43] = 0x0D, [0x44] = 0x24, [0x45] = 0x2C, [0x46] = 0x25, [0x47] = 0x2D, [0x48] = 0x00, [0x49] = 0x08, [0x4A] = 0x01, [0x4B] = 0x09, [0x4C] = 0x20, [0x4D] = 0x28, [0x4E] = 0x21, [0x4F] = 0x29, [0x50] = 0x84, [0x51] = 0x8C, [0x52] = 0x85, [0x53] = 0x8D, [0x54] = 0xA4, [0x55] = 0xAC, [0x56] = 0xA5, [0x57] = 0xAD, [0x58] = 0x80, [0x59] = 0x88, [0x5A] = 0x81, [0x5B] = 0x89, [0x5C] = 0xA0, [0x5D] = 0xA8, [0x5E] = 0xA1, [0x5F] = 0xA9, [0x60] = 0x14, [0x61] = 0x1C, [0x62] = 0x15, [0x63] = 0x1D, [0x64] = 0x34, [0x65] = 0x3C, [0x66] = 0x35, [0x67] = 0x3D, [0x68] = 0x10, [0x69] = 0x18, [0x6A] = 0x11, [0x6B] = 0x19, [0x6C] = 0x30, [0x6D] = 0x38, [0x6E] = 0x31, [0x6F] = 0x39, [0x70] = 0x94, [0x71] = 0x9C, [0x72] = 0x95, [0x73] = 0x9D, [0x74] = 0xB4, [0x75] = 0xBC, [0x76] = 0xB5, [0x77] = 0xBD, [0x78] = 0x90, [0x79] = 0x98, [0x7A] = 0x91, [0x7B] = 0x99, [0x7C] = 0xB0, [0x7D] = 0xB8, [0x7E] = 0xB1, [0x7F] = 0xB9, [0x80] = 0x46, [0x81] = 0x4E, [0x82] = 0x47, [0x83] = 0x4F, [0x84] = 0x66, [0x85] = 0x6E, [0x86] = 0x67, [0x87] = 0x6F, [0x88] = 0x42, [0x89] = 0x4A, [0x8A] = 0x43, [0x8B] = 0x4B, [0x8C] = 0x62, [0x8D] = 0x6A, [0x8E] = 0x63, [0x8F] = 0x6B, [0x90] = 0xC6, [0x91] = 0xCE, [0x92] = 0xC7, [0x93] = 0xCF, [0x94] = 0xE6, [0x95] = 0xEE, [0x96] = 0xE7, [0x97] = 0xEF, [0x98] = 0xC2, [0x99] = 0xCA, [0x9A] = 0xC3, [0x9B] = 0xCB, [0x9C] = 0xE2, [0x9D] = 0xEA, [0x9E] = 0xE3, [0x9F] = 0xEB, [0xA0] = 0x56, [0xA1] = 0x5E, [0xA2] = 0x57, [0xA3] = 0x5F, [0xA4] = 0x76, [0xA5] = 0x7E, [0xA6] = 0x77, [0xA7] = 0x7F, [0xA8] = 0x52, [0xA9] = 0x5A, [0xAA] = 0x53, [0xAB] = 0x5B, [0xAC] = 0x72, [0xAD] = 0x7A, [0xAE] = 0x73, [0xAF] = 0x7B, [0xB0] = 0xD6, [0xB1] = 0xDE, [0xB2] = 0xD7, [0xB3] = 0xDF, [0xB4] = 0xF6, [0xB5] = 0xFE, [0xB6] = 0xF7, [0xB7] = 0xFF, [0xB8] = 0xD2, [0xB9] = 0xDA, [0xBA] = 0xD3, [0xBB] = 0xDB, [0xBC] = 0xF2, [0xBD] = 0xFA, [0xBE] = 0xF3, [0xBF] = 0xFB, [0xC0] = 0x44, [0xC1] = 0x4C, [0xC2] = 0x45, [0xC3] = 0x4D, [0xC4] = 0x64, [0xC5] = 0x6C, [0xC6] = 0x65, [0xC7] = 0x6D, [0xC8] = 0x40, [0xC9] = 0x48, [0xCA] = 0x41, [0xCB] = 0x49, [0xCC] = 0x60, [0xCD] = 0x68, [0xCE] = 0x61, [0xCF] = 0x69, [0xD0] = 0xC4, [0xD1] = 0xCC, [0xD2] = 0xC5, [0xD3] = 0xCD, [0xD4] = 0xE4, [0xD5] = 0xEC, [0xD6] = 0xE5, [0xD7] = 0xED, [0xD8] = 0xC0, [0xD9] = 0xC8, [0xDA] = 0xC1, [0xDB] = 0xC9, [0xDC] = 0xE0, [0xDD] = 0xE8, [0xDE] = 0xE1, [0xDF] = 0xE9, [0xE0] = 0x54, [0xE1] = 0x5C, [0xE2] = 0x55, [0xE3] = 0x5D, [0xE4] = 0x74, [0xE5] = 0x7C, [0xE6] = 0x75, [0xE7] = 0x7D, [0xE8] = 0x50, [0xE9] = 0x58, [0xEA] = 0x51, [0xEB] = 0x59, [0xEC] = 0x70, [0xED] = 0x78, [0xEE] = 0x71, [0xEF] = 0x79, [0xF0] = 0xD4, [0xF1] = 0xDC, [0xF2] = 0xD5, [0xF3] = 0xDD, [0xF4] = 0xF4, [0xF5] = 0xFC, [0xF6] = 0xF5, [0xF7] = 0xFD, [0xF8] = 0xD0, [0xF9] = 0xD8, [0xFA] = 0xD1, [0xFB] = 0xD9, [0xFC] = 0xF0, [0xFD] = 0xF8, [0xFE] = 0xF1, [0xFF] = 0xF9, },
		},
	}
	return _data[GameVersion]
end

function GetLoseVisionPacketData()
	local _data = {
		['7.1.'] = {
			['Header'] = 0x001C,
			['Pos'] = 2,	
		},
		['7.2.'] = {
			['Header'] = 0x017D,
			['Pos'] = 2,
		},
		['6.24'] = {
			['Header'] = 0x015B, 
			['Pos'] = 2,	
		},
	}
	return _data[GameVersion]
end

function GetGainVisionPacketData()
	local _data = {
		['7.1.'] = {
			['Header'] = 0x002D, 
			['pos'] = 2,
		},
		['7.2.'] = { 
			['Header'] = 0x0125, 
			['pos'] = 2,
		},
		['6.24'] = {
			['Header'] = 0x00EB, 
			['pos'] = 2,	
		},
	}
	return _data[GameVersion]
end

function GetMasteryEmoteData()
	local cVersion = GetGameVersion()
	if cVersion:find('7.2.173.3544') then
		return {
			['Header'] = 0x0087,
			['vTable'] = 0xF67928,
			['hash'] = 0x85858585,
		}
	elseif cVersion:find('7.1.171.6847') then
		return {
			['Header'] = 0x0106,
			['vTable'] = 0xFBB400,
			['hash'] = 0xFEFEFEFE,
		}
	elseif cVersion:find('6.24.168.1268') then
		return {
			['Header'] = 0x000A,
			['vTable'] = 0x1075A14,
			['hash'] = 0x5D5D5D5D,
		}
	end
end
