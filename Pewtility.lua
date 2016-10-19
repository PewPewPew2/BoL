local lshift, rshift, band, bxor = bit32.lshift, bit32.rshift, bit32.band, bit32.bxor
local floor, ceil, huge, cos, sin, pi, pi2, abs, sqrt = math.floor, math.ceil, math.huge, math.cos, math.sin, math.pi, math.pi*2, math.abs, math.sqrt
local clock, pairs, ipairs, tostring = os.clock, pairs, ipairs, tostring
local TEAM_ENEMY, TEAM_ALLY
local COLOR_WHITE, COLOR_GREEN, COLOR_RED, COLOR_YELLOW, COLOR_TRANS_WHITE, COLOR_GREY = ARGB(0xFF,0xFF,0xFF,0xFF), ARGB(0xFF,0x00,170,0x00), ARGB(0xFF,0xFF,0x00,0x00), ARGB(0xFF,0xFF,0xFF,0x00), ARGB(0xAA,0xFF,0xFF,0xFF), ARGB(255,128,128,128) 
local COLOR_TRANS_GREEN, COLOR_TRANS_RED, COLOR_TRANS_YELLOW, COLOR_ORANGE, COLOR_BLACK = ARGB(0x96,0x00,0xFF,0x00), ARGB(0x96,0xFF,0x00,0x00), ARGB(0x96,0xFF,0xFF,0x00), ARGB(255,255,125,000), ARGB(255,0,0,000)
local MainMenu, GlobalAnchors = nil, {}
local menuKey = (GetSave('scriptConfig') and GetSave('scriptConfig')['Menu']) and GetSave('scriptConfig')['Menu']['menuKey'] or 16

_G.PewtilityHPBars = {Active = false, Addon = {},}

local _Game, _Map, _HUD

local function GetGame2()
    if not _Game then
        _Game = {
			['Map'] = {
				['Name'] = 'unknown',
				['Min'] = { ['x'] = 0, ['y'] = 0 },
				['Max'] = { ['x'] = 0, ['y'] = 0 },
				['x'] = 1,
				['y'] = 1,
			}
		}
        for i = 1, objManager.maxObjects do
            local object = objManager:getObject(i)
            if object and object.valid then
                if object.type == 'obj_Shop' and object.team == 100 then
                    if math.floor(object.x) == 232 and math.floor(object.y) == 163 and math.floor(object.z) == 1277 then --all wrong??
                        _Game.Map = { 
							['Name'] = 'SummonerRift', 
							['Min'] = { ['x'] = 80, ['y'] = 140 }, 
							['Max'] = { ['x'] = 14279, ['y'] = 14527 }, 
							['x'] = 14817, 
							['y'] = 14692, 
						}
                        break
                    elseif math.floor(object.x) == 1313 and math.floor(object.y) == 123 and math.floor(object.z) == 8005 then
						_Game.Map = { 
							['Name'] = 'TwistedTreeline', 
							['Min'] = { ['x'] = 150, y = 250}, 
							['Max'] = { ['x'] = 14120, y = 13877 }, 
							['x'] = 15116, 
							['y'] = 15116, 
						}
                        break
                    elseif math.floor(object.x) == 16 and math.floor(object.y) == 168 and math.floor(object.z) == 4452 then
					    _Game.Map = { 
							['Name'] = 'CrystalScar', 
							['Min'] = { ['x'] = 52, ['y'] = 150 }, 
							['Max'] = { ['x'] = 13911, ['y'] = 13703 }, 
							['x'] = 13911, 
							['y'] = 13703, 
						}
                        break
                    elseif math.floor(object.x) == 497 and math.floor(object.y) == -40 and math.floor(object.z) == 1932 then
						_Game.Map = { 
							['Name'] = 'HowlingAbyss', 
							['Min'] = { ['x'] = -20, ['y'] = 40 }, 
							['Max'] = { ['x'] = 12820, ['y'] = 12839 }, 
							['x'] = 12876, 
							['y'] = 12877, 
						}
                        break
                    elseif math.floor(object.x) == 497 and math.floor(object.y) == -180 and math.floor(object.z) == 1932 then
						_Game.Map = { 
							['Name'] = 'ButchersBridge', 
							['Min'] = { ['x'] = -20, ['y'] = 40 }, 
							['Max'] = { ['x'] = 12820, ['y'] = 12839 }, 
							['x'] = 12876, 
							['y'] = 12877, 
						}
                        break
                    end
                end
            end
        end
    end
    return _Game
end

local function GetHUDSettings()
	if not _HUD then
		_HUD = ReadIni(GAME_PATH .. "\\DATA\\menu\\hud\\hud" .. WINDOW_W .. "x" .. WINDOW_H .. ".ini")
	end
	return _HUD
end

local function _Map_Load()
    if not _Map then
		local Ratio, Flip, Settings = 1, false, GetGameSettings()
		if Settings and Settings.General and Settings.General.Width and Settings.General.Height then
			Ratio = (Settings.HUD and Settings.HUD.MinimapScale) and (WINDOW_H / 1080) * (0.75 + (Settings.HUD.MinimapScale * 0.25)) or WINDOW_H / 1080
			Flip = Settings.HUD and Settings.HUD.FlipMiniMap and Settings.HUD.FlipMiniMap == 1
		end
		local Map = GetGame2().Map
		_Map = {
			['Step'] = { 
				['x'] = (257 * Ratio) / Map.x, 
				['y'] = (-253 * Ratio) / Map.y 
			},
		}
		_Map.x = Flip and (20 + Ratio) - _Map.Step.x * Map.Min.x or WINDOW_W - (Ratio * 266) - _Map.Step.x * Map.Min.x
		_Map.y = WINDOW_H - 15 + ((1-Ratio) * 10) - _Map.Step.y * Map.Min.y
    end 
    return _Map ~= nil
end

local function GetMinimap(v)
	_Map_Load()
	return _Map_Load() and D3DXVECTOR2(_Map.x + (_Map.Step.x * v.x), _Map.y + (_Map.Step.y * v.z)) or D3DXVECTOR2(-100, -100)
end

local function GetScale(int, scl)
	return floor((scl / 100) * int)
end

local function GetScale2(int, scl)
	return (scl / 100) * int
end

-- AddDrawCallback(function()
	-- local v = GetMinimap(myHero)
	-- DrawLine(v.x-10,v.y,v.x+10,v.y,1,ARGB(255,255,255,255))
	-- DrawLine(v.x,v.y-10,v.x,v.y+10,1,ARGB(255,255,255,255))
-- end)

AddLoadCallback(function()
	local Version = 7.08
	TEAM_ALLY, TEAM_ENEMY = myHero.team, 300-myHero.team
  -- TEAM_ENEMY = myHero.team
	MainMenu = scriptConfig('Pewtility', 'Pewtility')
	MainMenu:addParam('update', 'Enable AutoUpdate', SCRIPT_PARAM_ONOFF, true)
	if FileExist(LIB_PATH..'\\Saves\\Pewtility.save') then
		local file = io.open(LIB_PATH ..'Saves\\Pewtility.save', 'r')
		if file then
			local content = file:read('*all')
			if content and content:sub(1, 6) ~= 'return' then
				local SaveTable = JSON:decode(content)
				if SaveTable and type(SaveTable) == 'table' then
					GlobalAnchors = SaveTable
				end
			end
		end
	end
	local function SaveAnchors()
		local savefile = io.open(LIB_PATH..'\\Saves\\Pewtility.save', 'w')
		local content = JSON:encode(GlobalAnchors)
		savefile:write(content)
		savefile:close()
	end
	AddBugsplatCallback(SaveAnchors)
	AddUnloadCallback(SaveAnchors)
	AddExitCallback(SaveAnchors)
	
	WARD()
	MISS()
	TIMERS()
	TRINKET()
	OTHER()
	MAGWARDS()
	SKILLS()
	AwareUpdate(
		Version,
		'raw.githubusercontent.com', 
		'/PewPewPew2/BoL/master/Versions/Pewtility.version', 
		'/PewPewPew2/BoL/master/Pewtility.lua', 
		SCRIPT_PATH.._ENV.FILE_NAME, 
		function() Print('Update Complete. Reload(F9 F9)') end, 
		function() Print('Load Complete') end, 
		function() Print(MainMenu.update and 'New Version Found, please wait...' or 'New Version found please download manually or enable AutoUpdate') end, 
		function() Print('An Error Occured in Update.') end
	)
end)

class 'AwareUpdate'
  
function AwareUpdate:__init(LocalVersion, Host, VersionPath, ScriptPath, SavePath, CallbackUpdate, CallbackNoUpdate, CallbackNewVersion, CallbackError)	
	self.LocalVersion = LocalVersion
	self.Host = Host
	self.VersionPath = '/BoL/TCPUpdater/GetScript5.php?script='..self:Base64Encode(self.Host..VersionPath)..'&rand='..math.random(99999999)
	self.ScriptPath = '/BoL/TCPUpdater/GetScript5.php?script='..self:Base64Encode(self.Host..ScriptPath)..'&rand='..math.random(99999999)
	self.SavePath = SavePath
	self.CallbackUpdate = CallbackUpdate
	self.CallbackNoUpdate = CallbackNoUpdate
	self.CallbackNewVersion = CallbackNewVersion
	self.CallbackError = CallbackError
	self:CreateSocket(self.VersionPath)
	self.DownloadStatus = 'Connect to Server for VersionInfo'
	AddTickCallback(function() self:GetOnlineVersion() end)
end

function AwareUpdate:OnDraw()
	local bP = {['x1'] = WINDOW_W - (WINDOW_W - 390),['x2'] = WINDOW_W - (WINDOW_W - 20),['y1'] = WINDOW_H / 2,['y2'] = (WINDOW_H / 2) + 20,}
	local text = 'Download Status: '..(self.DownloadStatus or 'Unknown')
	DrawLine(bP.x1, bP.y1 + 10, bP.x2,  bP.y1 + 10, 18, ARGB(0x7D,0xE1,0xE1,0xE1))
	local xOff
	if self.File and self.Size then
		local c = math.round(100/self.Size*self.File:len(),2)/100
		xOff = c < 1 and math.ceil(370 * c) or 370
	else
		xOff = 0
	end
	DrawLine(bP.x2 + xOff, bP.y1 + 10, bP.x2, bP.y1 + 10, 18, ARGB(0xC8,0xE1,0xE1,0xE1))
	DrawLines2({D3DXVECTOR2(bP.x1, bP.y1),D3DXVECTOR2(bP.x2, bP.y1),D3DXVECTOR2(bP.x2, bP.y2),D3DXVECTOR2(bP.x1, bP.y2),D3DXVECTOR2(bP.x1, bP.y1),}, 3, ARGB(0xB9, 0x0A, 0x0A, 0x0A))
	DrawText(text, 16, WINDOW_W - (WINDOW_W - 205) - (GetTextArea(text, 16).x / 2), bP.y1 + 2, ARGB(0xB9,0x0A,0x0A,0x0A))
end

function AwareUpdate:CreateSocket(url)
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

function AwareUpdate:Base64Encode(data)
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

function AwareUpdate:GetOnlineVersion()
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
        local ContentEnd, _ = self.File:find('</scr'..'ipt>')
        if not ContentStart or not ContentEnd then
            if self.CallbackError and type(self.CallbackError) == 'function' then
                self.CallbackError()
            end
        else
            self.OnlineVersion = (Base64Decode(self.File:sub(ContentStart + 1,ContentEnd-1)))
            self.OnlineVersion = tonumber(self.OnlineVersion)
            if self.OnlineVersion and self.OnlineVersion > self.LocalVersion then
                if self.CallbackNewVersion and type(self.CallbackNewVersion) == 'function' then
                    self.CallbackNewVersion(self.OnlineVersion,self.LocalVersion)
                end
				if not MainMenu.update then return end
				AddDrawCallback(function() self:OnDraw() end)
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

function AwareUpdate:DownloadUpdate()
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
        local HeaderEnd, ContentStart = self.NewFile:find('<scr'..'ipt>')
        local ContentEnd, _ = self.NewFile:find('</scr'..'ipt>')
        if not ContentStart or not ContentEnd then
            if self.CallbackError and type(self.CallbackError) == 'function' then
				print('Error1')
				self.CallbackError()
            end
        else
            local newf = self.NewFile:sub(ContentStart+1,ContentEnd-1)
            local newf = newf:gsub('\r','')
            if newf:len() ~= self.Size then
                if self.CallbackError and type(self.CallbackError) == 'function' then
					print('Error2')
                    self.CallbackError()
                end
                return
            end
            local newf = Base64Decode(newf)
            if not self.isSprite and type(load(newf)) ~= 'function' then
                if self.CallbackError and type(self.CallbackError) == 'function' then
					print('Error2')
                    self.CallbackError()
                end
            else
                local f = io.open(self.SavePath,"w+b")
				if f then
					f:write(newf)
					f:close()
					if self.CallbackUpdate and type(self.CallbackUpdate) == 'function' then
						self.CallbackUpdate(self.OnlineVersion,self.LocalVersion)
					end
				end
            end
        end
        self.GotScriptUpdate = true
    end
end

function Print(text, isError)
	if isError then
		print('<font color=\'#0099FF\'>[Pewtility] </font> <font color=\'#FF0000\'>'..text..'</font>')
		return
	end
	print('<font color=\'#0099FF\'>[Pewtility] </font> <font color=\'#FF6600\'>'..text..'.</font>')
end

class 'WARD'

function WARD:__init()
	self.Types = {
		['YellowTrinket'] 	= { ['color'] = COLOR_YELLOW,			 	    ['duration'] = 60,   ['isWard'] = true,  },
		['BlueTrinket'] 		= { ['color'] = 0xFF0000BB,			 		    ['duration'] = huge, ['isWard'] = false, },
		['SightWard'] 			= { ['color'] = ARGB(255,0,255,0),			['duration'] = 150,  ['isWard'] = true,  },
		['VisionWard']  		= { ['color'] = ARGB(255, 255, 50, 255),['duration'] = huge, ['isWard'] = true,  },
		['TeemoMushroom'] 	= { ['color'] = COLOR_RED,					    ['duration'] = 600,  ['isWard'] = false, },
		['ShacoBox'] 			  = { ['color'] = COLOR_RED,					    ['duration'] = 60, 	 ['isWard'] = false, },
	}
	self.OnSpell = {
		['trinkettotemlvl1'] 	= { ['color'] = COLOR_YELLOW,			 	    ['duration'] = 60,   ['isWard'] = true,  },
		['trinketorblvl3'] 		= { ['color'] = 0xFF0000BB,			 		    ['duration'] = huge, ['isWard'] = false, },
		['itemghostward'] 		= { ['color'] = ARGB(255,0,255,0),			['duration'] = 150,  ['isWard'] = true,  },
		['visionward']  		  = { ['color'] = ARGB(255, 255, 50, 255),['duration'] = huge, ['isWard'] = true,  },
		['bantamtrap'] 		 	  = { ['color'] = COLOR_RED,					    ['duration'] = 600,  ['isWard'] = false, },
		['jackinthebox'] 		  = { ['color'] = COLOR_RED,					    ['duration'] = 60, 	 ['isWard'] = false, },
	}
	
	self.BGColor = ARGB(100, 0, 0, 0)
	self.Anchor = {
		['x'] = GlobalAnchors.WardTracker and GlobalAnchors.WardTracker.x or 40,
		['y'] = GlobalAnchors.WardTracker and GlobalAnchors.WardTracker.y or WINDOW_H - 72,
	}
	self.Hex = {D3DXVECTOR2(0,0),D3DXVECTOR2(0,0),D3DXVECTOR2(0,0),D3DXVECTOR2(0,0),D3DXVECTOR2(0,0),D3DXVECTOR2(0,0),D3DXVECTOR2(0,0)}
	self.MyWards = {}
	self.Active = {}
	self.Known = {}
	self.Last_LBUTTONDOWN = 0
	self:CreateMenu()	
	self.Packet = GetGameVersion():sub(1,4)=='6.21' and {
		['Header'] = 0x0137,
		['sourcePos'] = 6,
		['stringPos'] = 11,
		['bytes'] = {[0x00] = 0xA7, [0x01] = 0xF2, [0x02] = 0x03, [0x03] = 0xB1, [0x04] = 0x30, [0x05] = 0x5C, [0x06] = 0x8F, [0x07] = 0xFE, [0x08] = 0x16, [0x09] = 0x0D, [0x0A] = 0xEC, [0x0B] = 0x04, [0x0C] = 0x62, [0x0D] = 0x98, [0x0E] = 0xAE, [0x0F] = 0x7D, [0x10] = 0x2B, [0x11] = 0xC9, [0x12] = 0xF9, [0x13] = 0xE7, [0x14] = 0xEA, [0x15] = 0xD0, [0x16] = 0x82, [0x17] = 0xBC, [0x18] = 0x73, [0x19] = 0xBF, [0x1A] = 0xD6, [0x1B] = 0xA3, [0x1C] = 0xE2, [0x1D] = 0x44, [0x1E] = 0xA0, [0x1F] = 0x3E, [0x20] = 0xA5, [0x21] = 0x40, [0x22] = 0x7E, [0x23] = 0xAB, [0x24] = 0x14, [0x25] = 0xB4, [0x26] = 0x67, [0x27] = 0xF1, [0x28] = 0x12, [0x29] = 0x6C, [0x2A] = 0xBE, [0x2B] = 0x74, [0x2C] = 0x06, [0x2D] = 0xD8, [0x2E] = 0xAF, [0x2F] = 0xC3, [0x30] = 0x32, [0x31] = 0x15, [0x32] = 0xB9, [0x33] = 0xC1, [0x34] = 0x5A, [0x35] = 0x1E, [0x36] = 0x4C, [0x37] = 0x59, [0x38] = 0xF3, [0x39] = 0x1C, [0x3A] = 0x8D, [0x3B] = 0x8B, [0x3C] = 0x33, [0x3D] = 0x3B, [0x3E] = 0xD9, [0x3F] = 0x65, [0x40] = 0xC0, [0x41] = 0xE6, [0x42] = 0x00, [0x43] = 0x38, [0x44] = 0xFB, [0x45] = 0xA6, [0x46] = 0xB2, [0x47] = 0x63, [0x48] = 0x79, [0x49] = 0x34, [0x4A] = 0xAC, [0x4B] = 0x97, [0x4C] = 0x83, [0x4D] = 0xB5, [0x4E] = 0x6F, [0x4F] = 0xE4, [0x50] = 0x0A, [0x51] = 0x41, [0x52] = 0xDC, [0x53] = 0x35, [0x54] = 0x3F, [0x55] = 0xE5, [0x56] = 0x31, [0x57] = 0x20, [0x58] = 0x01, [0x59] = 0xAD, [0x5A] = 0xF4, [0x5B] = 0x52, [0x5C] = 0x11, [0x5D] = 0x81, [0x5E] = 0x45, [0x5F] = 0x94, [0x60] = 0x18, [0x61] = 0x85, [0x62] = 0x91, [0x63] = 0x55, [0x64] = 0x08, [0x65] = 0x7F, [0x66] = 0x88, [0x67] = 0x46, [0x68] = 0xF7, [0x69] = 0x95, [0x6A] = 0x07, [0x6B] = 0x61, [0x6C] = 0xD5, [0x6D] = 0x9D, [0x6E] = 0x5D, [0x6F] = 0x87, [0x70] = 0xF8, [0x71] = 0x49, [0x72] = 0x21, [0x73] = 0xA8, [0x74] = 0x75, [0x75] = 0x6B, [0x76] = 0xD2, [0x77] = 0x76, [0x78] = 0x6D, [0x79] = 0x17, [0x7A] = 0x3D, [0x7B] = 0x90, [0x7C] = 0x50, [0x7D] = 0xC4, [0x7E] = 0x84, [0x7F] = 0xD7, [0x80] = 0x1A, [0x81] = 0x0F, [0x82] = 0xC6, [0x83] = 0xE1, [0x84] = 0xEB, [0x85] = 0x2E, [0x86] = 0x60, [0x87] = 0x29, [0x88] = 0x71, [0x89] = 0x92, [0x8A] = 0x4F, [0x8B] = 0x36, [0x8C] = 0xFA, [0x8D] = 0x42, [0x8E] = 0x54, [0x8F] = 0x9C, [0x90] = 0x37, [0x91] = 0xBA, [0x92] = 0x22, [0x93] = 0xF5, [0x94] = 0xDF, [0x95] = 0x48, [0x96] = 0x9E, [0x97] = 0x9A, [0x98] = 0xBB, [0x99] = 0x2A, [0x9A] = 0xA9, [0x9B] = 0xDA, [0x9C] = 0xA2, [0x9D] = 0x6E, [0x9E] = 0x3C, [0x9F] = 0x70, [0xA0] = 0xC8, [0xA1] = 0xF6, [0xA2] = 0xE3, [0xA3] = 0xCD, [0xA4] = 0xE8, [0xA5] = 0xED, [0xA6] = 0x8C, [0xA7] = 0x7B, [0xA8] = 0x39, [0xA9] = 0xE0, [0xAA] = 0x6A, [0xAB] = 0x68, [0xAC] = 0x0B, [0xAD] = 0x25, [0xAE] = 0xB6, [0xAF] = 0x7A, [0xB0] = 0xFF, [0xB1] = 0xD3, [0xB2] = 0x1B, [0xB3] = 0x80, [0xB4] = 0x9B, [0xB5] = 0x13, [0xB6] = 0xB8, [0xB7] = 0x77, [0xB8] = 0x27, [0xB9] = 0x2F, [0xBA] = 0xB0, [0xBB] = 0x89, [0xBC] = 0x51, [0xBD] = 0xCC, [0xBE] = 0x43, [0xBF] = 0x3A, [0xC0] = 0xD4, [0xC1] = 0x56, [0xC2] = 0x4D, [0xC3] = 0x5B, [0xC4] = 0x78, [0xC5] = 0x02, [0xC6] = 0xB7, [0xC7] = 0x66, [0xC8] = 0x1D, [0xC9] = 0x53, [0xCA] = 0xCA, [0xCB] = 0x05, [0xCC] = 0xE9, [0xCD] = 0x19, [0xCE] = 0xDB, [0xCF] = 0x8A, [0xD0] = 0x5E, [0xD1] = 0x93, [0xD2] = 0xFC, [0xD3] = 0x86, [0xD4] = 0xDE, [0xD5] = 0x9F, [0xD6] = 0x4A, [0xD7] = 0xCF, [0xD8] = 0x72, [0xD9] = 0x8E, [0xDA] = 0x5F, [0xDB] = 0x7C, [0xDC] = 0xEF, [0xDD] = 0xB3, [0xDE] = 0x2C, [0xDF] = 0xA1, [0xE0] = 0x10, [0xE1] = 0xF0, [0xE2] = 0x2D, [0xE3] = 0xFD, [0xE4] = 0xC5, [0xE5] = 0xAA, [0xE6] = 0x4E, [0xE7] = 0xCB, [0xE8] = 0xCE, [0xE9] = 0x28, [0xEA] = 0x99, [0xEB] = 0xDD, [0xEC] = 0xEE, [0xED] = 0x57, [0xEE] = 0xC7, [0xEF] = 0x1F, [0xF0] = 0xA4, [0xF1] = 0x24, [0xF2] = 0x4B, [0xF3] = 0xC2, [0xF4] = 0x23, [0xF5] = 0x09, [0xF6] = 0x69, [0xF7] = 0xD1, [0xF8] = 0x26, [0xF9] = 0x0E, [0xFA] = 0x96, [0xFB] = 0x47, [0xFC] = 0xBD, [0xFD] = 0x58, [0xFE] = 0x0C, [0xFF] = 0x64, }
	} or GetGameVersion():sub(1,4)=='6.20' and {
		['Header'] = 0x0137,
		['sourcePos'] = 6,
		['stringPos'] = 11,
		['bytes'] = {[0x00] = 0xA7, [0x01] = 0xF2, [0x02] = 0x03, [0x03] = 0xB1, [0x04] = 0x30, [0x05] = 0x5C, [0x06] = 0x8F, [0x07] = 0xFE, [0x08] = 0x16, [0x09] = 0x0D, [0x0A] = 0xEC, [0x0B] = 0x04, [0x0C] = 0x62, [0x0D] = 0x98, [0x0E] = 0xAE, [0x0F] = 0x7D, [0x10] = 0x2B, [0x11] = 0xC9, [0x12] = 0xF9, [0x13] = 0xE7, [0x14] = 0xEA, [0x15] = 0xD0, [0x16] = 0x82, [0x17] = 0xBC, [0x18] = 0x73, [0x19] = 0xBF, [0x1A] = 0xD6, [0x1B] = 0xA3, [0x1C] = 0xE2, [0x1D] = 0x44, [0x1E] = 0xA0, [0x1F] = 0x3E, [0x20] = 0xA5, [0x21] = 0x40, [0x22] = 0x7E, [0x23] = 0xAB, [0x24] = 0x14, [0x25] = 0xB4, [0x26] = 0x67, [0x27] = 0xF1, [0x28] = 0x12, [0x29] = 0x6C, [0x2A] = 0xBE, [0x2B] = 0x74, [0x2C] = 0x06, [0x2D] = 0xD8, [0x2E] = 0xAF, [0x2F] = 0xC3, [0x30] = 0x32, [0x31] = 0x15, [0x32] = 0xB9, [0x33] = 0xC1, [0x34] = 0x5A, [0x35] = 0x1E, [0x36] = 0x4C, [0x37] = 0x59, [0x38] = 0xF3, [0x39] = 0x1C, [0x3A] = 0x8D, [0x3B] = 0x8B, [0x3C] = 0x33, [0x3D] = 0x3B, [0x3E] = 0xD9, [0x3F] = 0x65, [0x40] = 0xC0, [0x41] = 0xE6, [0x42] = 0x00, [0x43] = 0x38, [0x44] = 0xFB, [0x45] = 0xA6, [0x46] = 0xB2, [0x47] = 0x63, [0x48] = 0x79, [0x49] = 0x34, [0x4A] = 0xAC, [0x4B] = 0x97, [0x4C] = 0x83, [0x4D] = 0xB5, [0x4E] = 0x6F, [0x4F] = 0xE4, [0x50] = 0x0A, [0x51] = 0x41, [0x52] = 0xDC, [0x53] = 0x35, [0x54] = 0x3F, [0x55] = 0xE5, [0x56] = 0x31, [0x57] = 0x20, [0x58] = 0x01, [0x59] = 0xAD, [0x5A] = 0xF4, [0x5B] = 0x52, [0x5C] = 0x11, [0x5D] = 0x81, [0x5E] = 0x45, [0x5F] = 0x94, [0x60] = 0x18, [0x61] = 0x85, [0x62] = 0x91, [0x63] = 0x55, [0x64] = 0x08, [0x65] = 0x7F, [0x66] = 0x88, [0x67] = 0x46, [0x68] = 0xF7, [0x69] = 0x95, [0x6A] = 0x07, [0x6B] = 0x61, [0x6C] = 0xD5, [0x6D] = 0x9D, [0x6E] = 0x5D, [0x6F] = 0x87, [0x70] = 0xF8, [0x71] = 0x49, [0x72] = 0x21, [0x73] = 0xA8, [0x74] = 0x75, [0x75] = 0x6B, [0x76] = 0xD2, [0x77] = 0x76, [0x78] = 0x6D, [0x79] = 0x17, [0x7A] = 0x3D, [0x7B] = 0x90, [0x7C] = 0x50, [0x7D] = 0xC4, [0x7E] = 0x84, [0x7F] = 0xD7, [0x80] = 0x1A, [0x81] = 0x0F, [0x82] = 0xC6, [0x83] = 0xE1, [0x84] = 0xEB, [0x85] = 0x2E, [0x86] = 0x60, [0x87] = 0x29, [0x88] = 0x71, [0x89] = 0x92, [0x8A] = 0x4F, [0x8B] = 0x36, [0x8C] = 0xFA, [0x8D] = 0x42, [0x8E] = 0x54, [0x8F] = 0x9C, [0x90] = 0x37, [0x91] = 0xBA, [0x92] = 0x22, [0x93] = 0xF5, [0x94] = 0xDF, [0x95] = 0x48, [0x96] = 0x9E, [0x97] = 0x9A, [0x98] = 0xBB, [0x99] = 0x2A, [0x9A] = 0xA9, [0x9B] = 0xDA, [0x9C] = 0xA2, [0x9D] = 0x6E, [0x9E] = 0x3C, [0x9F] = 0x70, [0xA0] = 0xC8, [0xA1] = 0xF6, [0xA2] = 0xE3, [0xA3] = 0xCD, [0xA4] = 0xE8, [0xA5] = 0xED, [0xA6] = 0x8C, [0xA7] = 0x7B, [0xA8] = 0x39, [0xA9] = 0xE0, [0xAA] = 0x6A, [0xAB] = 0x68, [0xAC] = 0x0B, [0xAD] = 0x25, [0xAE] = 0xB6, [0xAF] = 0x7A, [0xB0] = 0xFF, [0xB1] = 0xD3, [0xB2] = 0x1B, [0xB3] = 0x80, [0xB4] = 0x9B, [0xB5] = 0x13, [0xB6] = 0xB8, [0xB7] = 0x77, [0xB8] = 0x27, [0xB9] = 0x2F, [0xBA] = 0xB0, [0xBB] = 0x89, [0xBC] = 0x51, [0xBD] = 0xCC, [0xBE] = 0x43, [0xBF] = 0x3A, [0xC0] = 0xD4, [0xC1] = 0x56, [0xC2] = 0x4D, [0xC3] = 0x5B, [0xC4] = 0x78, [0xC5] = 0x02, [0xC6] = 0xB7, [0xC7] = 0x66, [0xC8] = 0x1D, [0xC9] = 0x53, [0xCA] = 0xCA, [0xCB] = 0x05, [0xCC] = 0xE9, [0xCD] = 0x19, [0xCE] = 0xDB, [0xCF] = 0x8A, [0xD0] = 0x5E, [0xD1] = 0x93, [0xD2] = 0xFC, [0xD3] = 0x86, [0xD4] = 0xDE, [0xD5] = 0x9F, [0xD6] = 0x4A, [0xD7] = 0xCF, [0xD8] = 0x72, [0xD9] = 0x8E, [0xDA] = 0x5F, [0xDB] = 0x7C, [0xDC] = 0xEF, [0xDD] = 0xB3, [0xDE] = 0x2C, [0xDF] = 0xA1, [0xE0] = 0x10, [0xE1] = 0xF0, [0xE2] = 0x2D, [0xE3] = 0xFD, [0xE4] = 0xC5, [0xE5] = 0xAA, [0xE6] = 0x4E, [0xE7] = 0xCB, [0xE8] = 0xCE, [0xE9] = 0x28, [0xEA] = 0x99, [0xEB] = 0xDD, [0xEC] = 0xEE, [0xED] = 0x57, [0xEE] = 0xC7, [0xEF] = 0x1F, [0xF0] = 0xA4, [0xF1] = 0x24, [0xF2] = 0x4B, [0xF3] = 0xC2, [0xF4] = 0x23, [0xF5] = 0x09, [0xF6] = 0x69, [0xF7] = 0xD1, [0xF8] = 0x26, [0xF9] = 0x0E, [0xFA] = 0x96, [0xFB] = 0x47, [0xFC] = 0xBD, [0xFD] = 0x58, [0xFE] = 0x0C, [0xFF] = 0x64, }
	}
	AddDrawCallback(function() self:Draw() end)
	AddProcessSpellCallback(function(u, s) self:ProcessSpell(u, s) end)
	AddDeleteObjCallback(function(o) self:DeleteObj(o) end)
	AddMsgCallback(function(m,k) self:WndMsg(m,k) end)
	if self.Packet then
		AddRecvPacketCallback2(function(p) self:RecvPacket(p) end)
	end
end

function WARD:CreateMenu()
	MainMenu:addSubMenu('Ward Tracker', 'WardTracker')
	self.Menu = MainMenu.WardTracker
	self.Menu:addParam('EnableEnemy', 'Enable Ward Timers', SCRIPT_PARAM_ONOFF, true)
	self.Menu:addParam('EnableSelf', 'Enable Self Ward Tracker', SCRIPT_PARAM_ONOFF, true)
	self.Menu:addParam('Scale', 'Self Ward Tracker Scale', SCRIPT_PARAM_SLICE, 100, 50 , 100)
	self.Menu:addParam('Type', 'Timer Type', SCRIPT_PARAM_LIST, 1, { 'Seconds', 'Minutes' })
	self.Menu:addParam('DrawHex', 'Draw Hexagon on Timers', SCRIPT_PARAM_ONOFF, true)
	self.Menu:addParam('Size', 'Text Size', SCRIPT_PARAM_SLICE, 12, 2, 24)
	self.Menu:addParam('MapSize', 'Minimap Marker Size', SCRIPT_PARAM_SLICE, 12, 2, 24)
	self.Menu:addParam('MapType', 'Minimap Marker Type', SCRIPT_PARAM_LIST, 1, { 'Marker', 'Timer' })
	self.Menu:addParam('DrawRange', 'Draw Ward Vision Radius', SCRIPT_PARAM_ONKEYDOWN, false, ('G'):byte())
	self.Menu:addParam('Info1', '', SCRIPT_PARAM_INFO, '')
	self.Menu:addParam('Info2', 'Double Click a ward to manually remove it.', SCRIPT_PARAM_INFO, '')
end

function WARD:DeleteObj(o)
	if o.valid and o.type == 'obj_AI_Minion' and self.Types[o.charName] then
		for i, ward in ipairs(self.Known) do
			if ward.wardID == o.networkID then
				table.remove(self.Known, i)
				return
			end
		end	
	end
end

function WARD:Draw()
	if self.Menu.EnableEnemy then 
		for i, ward in ipairs(self.Known) do
			if ward.pos then
				if ward.isWard and self.Menu.DrawRange then
					local wts = WorldToScreen(D3DXVECTOR3(ward.pos.x, ward.pos.y, ward.pos.z))
					local d32 = D3DXVECTOR2(wts.x,wts.y)
					if d32.x > 0 and d32.x < WINDOW_W and d32.y > 0 and d32.y < WINDOW_W then
						local vision = {}
						for theta = 0, (pi2+(pi2/30)), (pi2/30) do
							local p
							for i=20, 1100, 20 do
								local p2 = D3DXVECTOR3(ward.pos.x+(i*cos(theta)), ward.pos.y, ward.pos.z-(i*sin(theta)))
								if IsWall(p2) or i==1100 then
									p = p2
									break
								end
							end
							local tS = WorldToScreen(p)
							vision[#vision + 1] = D3DXVECTOR2(tS.x, tS.y)
						end
						DrawLines2(vision,2,ward.color)
					end
				end
				local text, mapText
				if ward.endTime == huge then
					mapText = 'o'
					text = ward.charName
				else
					local timer = ward.endTime-clock()
					if self.Menu.Type == 1 then
						mapText = ('%d'):format(timer)
						text = mapText..'\n'..ward.charName
					else
						mapText = ('%d:%.2d'):format(timer/60, timer%60)
						text = mapText..'\n'..ward.charName
					end
				end	
				DrawText3D(text, ward.pos.x, ward.pos.y+85, ward.pos.z+10, self.Menu.Size, ward.color, true)
				local c = GetTextArea(mapText, self.Menu.MapSize)
				DrawText(mapText, self.Menu.MapSize, ward.mapPos.x - (c.x / 2), ward.mapPos.y - (c.y / 2), ward.color)
				if self.Menu.DrawHex then
					self:DrawHex(ward.pos.x, ward.pos.y, ward.pos.z, ward.color)
				end
				if ward.endTime < clock() then
					table.remove(self.Known, i)
					return
				end
			elseif ward.wardID then
				local o = objManager:GetObjectByNetworkId(ward.wardID)
				if o and o.valid then 
					for i, ward2 in ipairs(self.Known) do
						if ward2 and ward2.pos and GetDistanceSqr(ward2.pos, o) < 50000 then
							table.remove(self.Known, i)
							break
						end
					end
					ward['pos'] = Vector(o.pos)
					ward['mapPos'] = GetMinimap(Vector(o.pos))
					DelayAction(function()
						ward['endTime'] = ward.endTime==huge and huge or o.mana+clock()
					end, .15)
				end
			end
		end
	end
	if self.Menu.EnableSelf then
		local isMenuOpen = IsKeyDown(menuKey) 
		DrawLine( --Background
			self.Anchor.x - GetScale(8, self.Menu.Scale) - 2, 
			self.Anchor.y, 
			self.Anchor.x + GetScale(181, self.Menu.Scale) + 2, 
			self.Anchor.y, 
			GetScale(95, self.Menu.Scale) + 4, 
			0x55FFFFFF
		)
		DrawLine( --Background
			self.Anchor.x - GetScale(8, self.Menu.Scale), 
			self.Anchor.y, 
			self.Anchor.x + GetScale(181, self.Menu.Scale), 
			self.Anchor.y, 
			GetScale(95, self.Menu.Scale), 
			isMenuOpen and ARGB(255, 85,85,85) or ARGB(100, 0, 0, 0)
		)
		for k=1, 3 do
			local v = self.Active[k]
			if v then
				if v.object then
					local t = v.endTime - clock()
					if t < 1 or not v.object or not v.object.valid or v.object.dead then
						table.remove(self.Active, k)
						return
					else
						DrawText(
							isMenuOpen and 'Ward Position' or k..(' - %d:%.2d'):format(t / 60, t % 60), 
							GetScale(26, self.Menu.Scale), 
							self.Anchor.x, 
							self.Anchor.y + GetScale(42 - (k * 22), self.Menu.Scale), 
							COLOR_TRANS_GREEN
						)
					end
				elseif v.wardID then
					v.object = objManager:GetObjectByNetworkId(v.wardID)
				end
			else
				DrawText(
					isMenuOpen and 'Ward Position' or k..' - Not Active', 
					GetScale(26, self.Menu.Scale), 
					self.Anchor.x, 
					self.Anchor.y + GetScale(42 - (k * 22), self.Menu.Scale), 
					COLOR_ORANGE
				)		
			end
		end
		if self.Active['Pink'] then
			if type(self.Active['Pink'])=='number' then
				local o = objManager:GetObjectByNetworkId(self.Active['Pink'])
				if o and o.valid then self.Active['Pink'] = o end
			elseif self.Active['Pink'].valid and not self.Active['Pink'].dead then
				DrawText(
					isMenuOpen and 'Ward Position' or 'Pink - Active', 
					GetScale(26, self.Menu.Scale), 
					self.Anchor.x, 
					self.Anchor.y - GetScale(46, self.Menu.Scale),  
					ARGB(200, 255, 50, 255)
				)
			else
				self.Active['Pink'] = nil
			end
		else
			DrawText(
				isMenuOpen and 'Ward Position' or 'Pink - Not Active', 
				GetScale(26, self.Menu.Scale),
				self.Anchor.x, 
				self.Anchor.y - GetScale(46, self.Menu.Scale),  
				COLOR_TRANS_RED
			)
		end	
		if self.IsMoving then
			local CursorPos = GetCursorPos()
			self.Anchor.x = CursorPos.x-self.MovingOffset.x
			self.Anchor.y = CursorPos.y-self.MovingOffset.y
			GlobalAnchors.WardTracker = {
				['x'] = self.Anchor.x,
				['y'] = self.Anchor.y,
			}
		end
	end
end

function WARD:WndMsg(m,k)
	if m==WM_LBUTTONDBLCLK then
		for i, ward in ipairs(self.Known) do
			if GetDistanceSqr(mousePos, ward.pos) < 15625 then
				table.remove(self.Known, i)
				return
			end			
		end	
	end
	if m==WM_LBUTTONDOWN and IsKeyDown(menuKey) then
		local CursorPos = GetCursorPos()
		if CursorPos.x > self.Anchor.x - GetScale(8, self.Menu.Scale) and CursorPos.x < self.Anchor.x + GetScale(181, self.Menu.Scale) then
			if CursorPos.y > self.Anchor.y - GetScale(47.5, self.Menu.Scale) and CursorPos.y < self.Anchor.y + GetScale(47.5, self.Menu.Scale) then
				self.IsMoving = true
				self.MovingOffset = {x=CursorPos.x-self.Anchor.x, y=CursorPos.y-self.Anchor.y,}
			end
		end
	end
	if m==WM_LBUTTONUP and self.IsMoving then
		self.IsMoving=false
	end
end

function WARD:ProcessSpell(u, s)
	if u.valid and self.OnSpell[s.name:lower()] then
		local name = s.name:lower()
		if u.team == TEAM_ENEMY then
			local duration = name == 'trinkettotemlvl1' and 56.5 + (u.level * 3.5) or self.OnSpell[name].duration
			self.Known[#self.Known+1] = {
				['pos'] 	 = Vector(s.endPos),
				['mapPos']   = GetMinimap(Vector(s.endPos)),
				['color'] 	 = self.OnSpell[name].color,
				['endTime']  = clock()+duration,
				['charName'] = u.charName or 'Unknown',
				['isWard']   = self.OnSpell[name].isWard,
			}
		end
	end
end

function WARD:RecvPacket(p)
	if p.header == self.Packet.Header then
		p.pos=2
		local wardID = p:DecodeF()
		p.pos=self.Packet.sourcePos
		local bytes = {}
		for i=4, 1, -1 do
			bytes[i] = self.Packet.bytes[p:Decode1()]
		end
		local netID = bxor(lshift(band(bytes[1],0xFF),24),lshift(band(bytes[2],0xFF),16),lshift(band(bytes[3],0xFF),8),band(bytes[4],0xFF))
		local source = objManager:GetObjectByNetworkId(DwordToFloat(netID))
		if source and source.valid then
			p.pos=self.Packet.stringPos
			local str = ''
			for i=p.pos, p.size do
				local d1 = p:Decode1()
				if not self.Types[str] then
					str=str..string.char(d1)
				end
			end
			if self.Types[str] then
				if source.isMe and self.Types[str].isWard then
					if self.Types[str].duration then								
						if self.Types[str].duration ~= huge then
							local duration = str == 'YellowTrinket' and 56.5 + (source.level * 3.5) or self.Types[str].duration
							table.insert(self.Active, 1, {
								['wardID'] = wardID,
								['endTime'] = clock() + duration,
								['startTime'] = clock(),
							})
							if self.Active[4] then table.remove(self.Active, 4) end
						else
							self.Active['Pink'] = wardID
						end
					end
				elseif source.team == TEAM_ENEMY then
					local duration = str == 'YellowTrinket' and 56.5 + (source.level * 3.5) or self.Types[str].duration
					self.Known[#self.Known + 1] = {
						['color']	 = self.Types[str].color, 
						['endTime']	 = self.Types[str].duration == huge and huge or clock() + duration,
						['charName'] = source.charName,
						['isWard']   = self.Types[str].isWard,
						['wardID']	 = wardID,
					}					
				end
			end
		end
	end
end

function WARD:DrawHex(x, y, z, c)
	local p1 = WorldToScreen(D3DXVECTOR3(x+75, y, z))
	if p1.x > -100 and p1.x < WINDOW_W+100 and p1.y < WINDOW_H+100 and p1.y > -100 then
		local count = 1
		self.Hex[count].x, self.Hex[count].y = p1.x, p1.y
		for theta = (pi2/6), pi2, (pi2/6) do
			count=count+1
			local tS = WorldToScreen(D3DXVECTOR3(x+(75*cos(theta)), y, z-(75*sin(theta))))
			self.Hex[count].x, self.Hex[count].y = tS.x, tS.y
		end
		DrawLines2(self.Hex, 1, c)
	end
end

class 'MISS'

function MISS:__init()
	if not FileExist(SPRITE_PATH..'Pewtility\\CharacterIcons\\'..myHero.charName..'.png') then
		Print('Minimap Sprites Not Found!!! Please Download from forum')
		if not FileExist(SPRITE_PATH..'Generic.png') then
			SxWebResulter(
				'i.imgur.com', 
				'/6dSBvc1.png', 
				function(file)
					local f = io.open(SPRITE_PATH..'Generic.png', 'w+b')
					f:write(file)
					f:close()
					Print('Sprite Download complete', true)
				end, 
				function() Print('An error occured downloading sprite') end
			)
		end
	end
	self.missing = {}
	self.VisibleSince = {}
	self.ActiveRecalls = {}
	self.Sprites = {}	
	for i=0, objManager.maxObjects do
		local o = objManager:getObject(i)
		if o and o.name and o.name:find('__Spawn_T') and o.team == TEAM_ENEMY then
			self.recallEndPos = GetMinimap(Vector(o.pos))
		end
	end
	self.recallTimes = {
		['recall'] = 7.9,
		['odinrecall'] = 4.4,
		['odinrecallimproved'] = 3.9,
		['recallimproved'] = 6.9,
		['superrecall'] = 3.9,
		['teleport'] = 4.45,
	}
	self.Allies = {}
	self.Enemies = {}
	local DefaultAnchor = GetMinimap(Vector(0, 0, 25000))
	self.Anchor = {
		['x'] = GlobalAnchors.RecallBar and GlobalAnchors.RecallBar.x or DefaultAnchor.x,
		['x2'] = WINDOW_W - 10 - DefaultAnchor.x,
		['y'] = GlobalAnchors.RecallBar and GlobalAnchors.RecallBar.y or DefaultAnchor.y,
	}
	self.Anchor2 = {
		['x'] = GlobalAnchors.JungleTracker and GlobalAnchors.JungleTracker.x or ceil(WINDOW_W/2),
		['y'] = GlobalAnchors.JungleTracker and GlobalAnchors.JungleTracker.y or ceil(WINDOW_H/8),
	}
	for i=1, heroManager.iCount do
		local hero = heroManager:getHero(i)
		if hero.team == TEAM_ENEMY then
			self.Enemies[#self.Enemies + 1] = hero
			self.VisibleSince[hero.networkID] = clock()
			self.missing[hero.networkID] = nil
			if FileExist(SPRITE_PATH..'Pewtility\\CharacterIcons\\'..hero.charName..'.png') then
				self.Sprites[hero.networkID] = createSprite(SPRITE_PATH..'Pewtility\\CharacterIcons\\'..hero.charName..'.png')			
			else
				self.Sprites[hero.networkID] = createSprite('Generic.png')
			end
            self.Sprites[hero.networkID]:SetScale(0.45, 0.45)
			self.Sprites[hero.networkID].scale = 0.45
		else
			self.Allies[#self.Allies + 1] = hero
		end
	end
	for k, v in pairs(self.Sprites) do
		v:SetScale(0.45, 0.45)
		v.scale = 0.45
	end
	self.Packets = GetGameVersion():sub(1, 4) == '6.21' and {
		['LoseVision'] = { ['Header'] = 0x0109, ['pos'] = 2, },
		['GainVision'] = { ['Header'] = 0x013A, ['pos'] = 2, },
		['Recall'] = { 
			['Header'] = 0x0065, 
			['pos'] = 31, 
			['stringPos'] = 6, 
			['tpPos'] = 22, 
			['isTP'] = 0x08, 
			['bytes'] = {
				[0x9C] = 0x00,
				[0x9D] = 0x40,
				[0x04] = 0x1A,
				[0x00] = 0x1B,
				[0x0C] = 0x1C,
				[0x08] = 0x1D,
				[0x14] = 0x1E,
				[0x10] = 0x1F,
				[0x1C] = 0x20,
				[0x18] = 0x21,
				[0xE5] = 0x22,
				[0xE1] = 0x23,
				[0x5D] = 0x11,
				[0x24] = 0x12,
				[0x20] = 0x13,
				[0x2C] = 0x14,
				[0x28] = 0x15,
				[0x34] = 0x16,
			},
		},
		['Reset'] = { ['Header'] = 0x0061, ['pos'] = 2, ['pos2'] = 11, },
		['Aggro'] = { ['Header'] = 0X00CB, ['pos'] = 2, },
		['AggroUpdate'] = { ['Header'] = 0x00F3, ['pos'] = 2, },
		['Missile'] = { ['Header'] = 0x009D, ['pos'] = 2, },
		['JunglePos'] = {
      [0x25279B5A] = { ['pos'] = GetMinimap(Vector(7800, 60, 4000)),  ['name'] = 'SRU_RedMini4.1.3',         ['text'] = 'Bot Red'      },
      [0xA6DE14EF] = { ['pos'] = GetMinimap(Vector(7800, 60, 4000)),  ['name'] = 'SRU_RedMini4.1.2',         ['text'] = 'Bot Red'      },
      [0x2536CE6B] = { ['pos'] = GetMinimap(Vector(7800, 60, 4000)),  ['name'] = 'SRU_Red4.1.1',             ['text'] = 'Bot Red'      },
      [0xC6EEC439] = { ['pos'] = GetMinimap(Vector(7000, 60, 5400)),  ['name'] = 'SRU_RazorbeakMini3.1.2',   ['text'] = 'Bot Raptors'  },
      [0x268738BA] = { ['pos'] = GetMinimap(Vector(7000, 60, 5400)),  ['name'] = 'SRU_Razorbeak3.1.1',       ['text'] = 'Bot Raptors'  },
      [0x2520B7BA] = { ['pos'] = GetMinimap(Vector(7000, 60, 5400)),  ['name'] = 'SRU_RazorbeakMini3.1.3',   ['text'] = 'Bot Raptors'  },
      [0x26273DDF] = { ['pos'] = GetMinimap(Vector(7000, 60, 5400)),  ['name'] = 'SRU_RazorbeakMini3.1.4',   ['text'] = 'Bot Raptors'  },
      [0x26A77DA4] = { ['pos'] = GetMinimap(Vector(10950, 60, 7030)), ['name'] = 'SRU_BlueMini27.1.3',       ['text'] = 'Top Blue',    },
      [0x26FE4603] = { ['pos'] = GetMinimap(Vector(10950, 60, 7030)), ['name'] = 'SRU_BlueMini7.1.2',        ['text'] = 'Top Blue',    },
      [0x26526360] = { ['pos'] = GetMinimap(Vector(10950, 60, 7030)), ['name'] = 'SRU_Blue7.1.1',            ['text'] = 'Top Blue',    },
      [0x261678F5] = { ['pos'] = GetMinimap(Vector(11000, 60, 8400)), ['name'] = 'SRU_Murkwolf8.1.1',        ['text'] = 'Top Wolves'   },
      [0x262E178B] = { ['pos'] = GetMinimap(Vector(11000, 60, 8400)), ['name'] = 'SRU_MurkwolfMini8.1.2',    ['text'] = 'Top Wolves'   },
      [0x267ABD98] = { ['pos'] = GetMinimap(Vector(11000, 60, 8400)), ['name'] = 'SRU_MurkwolfMini8.1.3',    ['text'] = 'Top Wolves'   },
      [0x252E26FC] = { ['pos'] = GetMinimap(Vector(3800, 60, 6500)),  ['name'] = 'SRU_Murkwolf2.1.1',        ['text'] = 'Bot Wolves'   },
      [0x251AC0DC] = { ['pos'] = GetMinimap(Vector(3800, 60, 6500)),  ['name'] = 'SRU_MurkwolfMini2.1.3',    ['text'] = 'Bot Wolves'   },
      [0x25E64A4A] = { ['pos'] = GetMinimap(Vector(3800, 60, 6500)),  ['name'] = 'SRU_MurkwolfMini2.1.2',    ['text'] = 'Bot Wolves'   },
      [0x262714F9] = { ['pos'] = GetMinimap(Vector(2200, 60, 8500)),  ['name'] = 'SRU_Gromp13.1.1',          ['text'] = 'Bot Gromp'    },
      [0xC51446D6] = { ['pos'] = GetMinimap(Vector(3850, 60, 7880)),  ['name'] = 'SRU_BlueMini21.1.3',       ['text'] = 'Bot Blue',    },
      [0x25976EB4] = { ['pos'] = GetMinimap(Vector(3850, 60, 7880)),  ['name'] = 'SRU_BlueMini1.1.2',        ['text'] = 'Bot Blue',    },
      [0x25B635BE] = { ['pos'] = GetMinimap(Vector(3850, 60, 7880)),  ['name'] = 'SRU_Blue1.1.1',            ['text'] = 'Bot Blue',    },
      [0xA6DD88B0] = { ['pos'] = GetMinimap(Vector(7850, 60, 9500)),  ['name'] = 'SRU_RazorbeakMini9.1.2',   ['text'] = 'Top Raptors'  },
      [0x25C7376B] = { ['pos'] = GetMinimap(Vector(7850, 60, 9500)),  ['name'] = 'SRU_Razorbeak9.1.1',       ['text'] = 'Top Raptors'  },
      [0xC50852A0] = { ['pos'] = GetMinimap(Vector(7850, 60, 9500)),  ['name'] = 'SRU_RazorbeakMini9.1.4',   ['text'] = 'Top Raptors'  },
      [0x26DEDB48] = { ['pos'] = GetMinimap(Vector(7850, 60, 9500)),  ['name'] = 'SRU_RazorbeakMini9.1.3',   ['text'] = 'Top Raptors'  },
      [0x254C5FB3] = { ['pos'] = GetMinimap(Vector(7100, 60, 10900)), ['name'] = 'SRU_RedMini10.1.2',        ['text'] = 'Top Red'       },
      [0x2627CA11] = { ['pos'] = GetMinimap(Vector(7100, 60, 10900)), ['name'] = 'SRU_RedMini10.1.3',        ['text'] = 'Top Red'      },
      [0x26B0DFCE] = { ['pos'] = GetMinimap(Vector(7100, 60, 10900)), ['name'] = 'SRU_Red10.1.1',            ['text'] = 'Top Red'      },
      [0x26B85159] = { ['pos'] = GetMinimap(Vector(6400, 60, 12250)), ['name'] = 'SRU_Krug11.1.1',           ['text'] = 'Top Krugs'    },
      [0xC53DA93A] = { ['pos'] = GetMinimap(Vector(6400, 60, 12250)), ['name'] = 'SRU_KrugMini11.1.2',       ['text'] = 'Top Krugs'    },
      [0xA50C7481] = { ['pos'] = GetMinimap(Vector(8400, 60, 2700)),  ['name'] = 'SRU_KrugMini5.1.2',        ['text'] = 'Bot Krugs'    },
      [0xC67D6827] = { ['pos'] = GetMinimap(Vector(8400, 60, 2700)),  ['name'] = 'SRU_Krug5.1.1',            ['text'] = 'Bot Krugs'    },
		},	
	} or GetGameVersion():sub(1, 4) == '6.20' and {
		['LoseVision'] = { ['Header'] = 0x0109, ['pos'] = 2, },
		['GainVision'] = { ['Header'] = 0x013A, ['pos'] = 2, },
		['Recall'] = { 
			['Header'] = 0x0065, 
			['pos'] = 31, 
			['stringPos'] = 6, 
			['tpPos'] = 22, 
			['isTP'] = 0x08, 
			['bytes'] = {
				[0x9C] = 0x00,
				[0x9D] = 0x40,
				[0x04] = 0x1A,
				[0x00] = 0x1B,
				[0x0C] = 0x1C,
				[0x08] = 0x1D,
				[0x14] = 0x1E,
				[0x10] = 0x1F,
				[0x1C] = 0x20,
				[0x18] = 0x21,
				[0xE5] = 0x22,
				[0xE1] = 0x23,
				[0x5D] = 0x11,
				[0x24] = 0x12,
				[0x20] = 0x13,
				[0x2C] = 0x14,
				[0x28] = 0x15,
				[0x34] = 0x16,
			},
		},
		['Reset'] = { ['Header'] = 0x0061, ['pos'] = 2, ['pos2'] = 11, },
		['Aggro'] = { ['Header'] = 0X00CB, ['pos'] = 2, },
		['AggroUpdate'] = { ['Header'] = 0x00F3, ['pos'] = 2, },
		['Missile'] = { ['Header'] = 0x009D, ['pos'] = 2, },
		['JunglePos'] = {
      [0x25279B5A] = { ['pos'] = GetMinimap(Vector(7800, 60, 4000)),  ['name'] = 'SRU_RedMini4.1.3',         ['text'] = 'Bot Red'      },
      [0xA6DE14EF] = { ['pos'] = GetMinimap(Vector(7800, 60, 4000)),  ['name'] = 'SRU_RedMini4.1.2',         ['text'] = 'Bot Red'      },
      [0x2536CE6B] = { ['pos'] = GetMinimap(Vector(7800, 60, 4000)),  ['name'] = 'SRU_Red4.1.1',             ['text'] = 'Bot Red'      },
      [0xC6EEC439] = { ['pos'] = GetMinimap(Vector(7000, 60, 5400)),  ['name'] = 'SRU_RazorbeakMini3.1.2',   ['text'] = 'Bot Raptors'  },
      [0x268738BA] = { ['pos'] = GetMinimap(Vector(7000, 60, 5400)),  ['name'] = 'SRU_Razorbeak3.1.1',       ['text'] = 'Bot Raptors'  },
      [0x2520B7BA] = { ['pos'] = GetMinimap(Vector(7000, 60, 5400)),  ['name'] = 'SRU_RazorbeakMini3.1.3',   ['text'] = 'Bot Raptors'  },
      [0x26273DDF] = { ['pos'] = GetMinimap(Vector(7000, 60, 5400)),  ['name'] = 'SRU_RazorbeakMini3.1.4',   ['text'] = 'Bot Raptors'  },
      [0x26A77DA4] = { ['pos'] = GetMinimap(Vector(10950, 60, 7030)), ['name'] = 'SRU_BlueMini27.1.3',       ['text'] = 'Top Blue',    },
      [0x26FE4603] = { ['pos'] = GetMinimap(Vector(10950, 60, 7030)), ['name'] = 'SRU_BlueMini7.1.2',        ['text'] = 'Top Blue',    },
      [0x26526360] = { ['pos'] = GetMinimap(Vector(10950, 60, 7030)), ['name'] = 'SRU_Blue7.1.1',            ['text'] = 'Top Blue',    },
      [0x261678F5] = { ['pos'] = GetMinimap(Vector(11000, 60, 8400)), ['name'] = 'SRU_Murkwolf8.1.1',        ['text'] = 'Top Wolves'   },
      [0x262E178B] = { ['pos'] = GetMinimap(Vector(11000, 60, 8400)), ['name'] = 'SRU_MurkwolfMini8.1.2',    ['text'] = 'Top Wolves'   },
      [0x267ABD98] = { ['pos'] = GetMinimap(Vector(11000, 60, 8400)), ['name'] = 'SRU_MurkwolfMini8.1.3',    ['text'] = 'Top Wolves'   },
      [0x252E26FC] = { ['pos'] = GetMinimap(Vector(3800, 60, 6500)),  ['name'] = 'SRU_Murkwolf2.1.1',        ['text'] = 'Bot Wolves'   },
      [0x251AC0DC] = { ['pos'] = GetMinimap(Vector(3800, 60, 6500)),  ['name'] = 'SRU_MurkwolfMini2.1.3',    ['text'] = 'Bot Wolves'   },
      [0x25E64A4A] = { ['pos'] = GetMinimap(Vector(3800, 60, 6500)),  ['name'] = 'SRU_MurkwolfMini2.1.2',    ['text'] = 'Bot Wolves'   },
      [0x262714F9] = { ['pos'] = GetMinimap(Vector(2200, 60, 8500)),  ['name'] = 'SRU_Gromp13.1.1',          ['text'] = 'Bot Gromp'    },
      [0xC51446D6] = { ['pos'] = GetMinimap(Vector(3850, 60, 7880)),  ['name'] = 'SRU_BlueMini21.1.3',       ['text'] = 'Bot Blue',    },
      [0x25976EB4] = { ['pos'] = GetMinimap(Vector(3850, 60, 7880)),  ['name'] = 'SRU_BlueMini1.1.2',        ['text'] = 'Bot Blue',    },
      [0x25B635BE] = { ['pos'] = GetMinimap(Vector(3850, 60, 7880)),  ['name'] = 'SRU_Blue1.1.1',            ['text'] = 'Bot Blue',    },
      [0xA6DD88B0] = { ['pos'] = GetMinimap(Vector(7850, 60, 9500)),  ['name'] = 'SRU_RazorbeakMini9.1.2',   ['text'] = 'Top Raptors'  },
      [0x25C7376B] = { ['pos'] = GetMinimap(Vector(7850, 60, 9500)),  ['name'] = 'SRU_Razorbeak9.1.1',       ['text'] = 'Top Raptors'  },
      [0xC50852A0] = { ['pos'] = GetMinimap(Vector(7850, 60, 9500)),  ['name'] = 'SRU_RazorbeakMini9.1.4',   ['text'] = 'Top Raptors'  },
      [0x26DEDB48] = { ['pos'] = GetMinimap(Vector(7850, 60, 9500)),  ['name'] = 'SRU_RazorbeakMini9.1.3',   ['text'] = 'Top Raptors'  },
      [0x254C5FB3] = { ['pos'] = GetMinimap(Vector(7100, 60, 10900)), ['name'] = 'SRU_RedMini10.1.2',        ['text'] = 'Top Red'       },
      [0x2627CA11] = { ['pos'] = GetMinimap(Vector(7100, 60, 10900)), ['name'] = 'SRU_RedMini10.1.3',        ['text'] = 'Top Red'      },
      [0x26B0DFCE] = { ['pos'] = GetMinimap(Vector(7100, 60, 10900)), ['name'] = 'SRU_Red10.1.1',            ['text'] = 'Top Red'      },
      [0x26B85159] = { ['pos'] = GetMinimap(Vector(6400, 60, 12250)), ['name'] = 'SRU_Krug11.1.1',           ['text'] = 'Top Krugs'    },
      [0xC53DA93A] = { ['pos'] = GetMinimap(Vector(6400, 60, 12250)), ['name'] = 'SRU_KrugMini11.1.2',       ['text'] = 'Top Krugs'    },
      [0xA50C7481] = { ['pos'] = GetMinimap(Vector(8400, 60, 2700)),  ['name'] = 'SRU_KrugMini5.1.2',        ['text'] = 'Bot Krugs'    },
      [0xC67D6827] = { ['pos'] = GetMinimap(Vector(8400, 60, 2700)),  ['name'] = 'SRU_Krug5.1.1',            ['text'] = 'Bot Krugs'    },
		},	
	}
  
	self.JungleTracker = {}
	self:CreateMenu()
	if not self.Packets then
		Print('Missing Enemies packets are outdated!!', true)
		return
	end
	if GetGame().map.shortName == 'summonerRift' then
		AddRecvPacketCallback2(function(p) self:JunglePackets(p) end)
	end
	AddRecvPacketCallback2(function(p) self:RecvPacket(p) end)
	AddDrawCallback(function() self:Draw() end)
	AddMsgCallback(function(m,k) self:WndMsg(m,k) end)
end

function MISS:CreateMenu()
	MainMenu:addSubMenu('Missing Enemies', 'MissTracker')
	self.Menu = MainMenu.MissTracker
	self.Menu:addParam('Enable', 'Enable Missing Timers', SCRIPT_PARAM_ONOFF, true)
	self.Menu:addParam('TextSize', 'Text Size', SCRIPT_PARAM_SLICE, 12, 2, 24)
	self.Menu:addParam('SpriteSize', 'Sprite Size', SCRIPT_PARAM_SLICE, 45, 1, 100)
	self.Menu:addParam('EnableRecall', 'Display Recall Status', SCRIPT_PARAM_ONOFF, true)
	self.Menu:addParam('RecallScale', 'Recall Bar Scale', SCRIPT_PARAM_SLICE, 100, 50, 100)
	self.Menu:addParam('EnableJungle', 'Display Jungle Tracker', SCRIPT_PARAM_ONOFF, true)
	self.Menu:addParam('JungleScale', 'Jungle Tracker Bar Scale', SCRIPT_PARAM_SLICE, 75, 50, 100)
	self.LastCheck = self.Menu.SpriteSize
	AddTickCallback(function()
		if self.Menu.SpriteSize ~= self.LastCheck then
			for k, v in pairs(self.Sprites) do
				v:SetScale(self.Menu.SpriteSize / 100, self.Menu.SpriteSize / 100)
				v.scale = self.Menu.SpriteSize / 100
			end			
		end
	end)
end

function MISS:RecvPacket(p)
	if p.header == self.Packets.LoseVision.Header then
		p.pos=self.Packets.LoseVision.pos
		local o = objManager:GetObjectByNetworkId(p:DecodeF())
		if o and o.valid and o.type == 'AIHeroClient' and o.team == TEAM_ENEMY then
			if o.dead then
				self.missing[o.networkID] = {
					['pos'] = self.recallEndPos,
					['name'] = o.charName, 
					['mTime'] = clock(),
				}			
			else
				self.missing[o.networkID] = {
					['pos'] = GetMinimap(Vector(o.pos)),
					['pos2'] = Vector(o.pos),
					['name'] = o.charName, 
					['mTime'] = clock(),
					['unit'] = o,
				}
				if GetDistance(o, o.endPath) > 100 then
					self.missing[o.networkID].direction = GetMinimap(Vector(o) + (Vector(o.endPath) - Vector(o)):normalized() * 1200)
				end
				return
			end
		end	
	end
	if p.header == self.Packets.GainVision.Header then
		p.pos=self.Packets.GainVision.pos
		local o = objManager:GetObjectByNetworkId(p:DecodeF())
		if o and o.valid and o.type == 'AIHeroClient' and o.team == TEAM_ENEMY then
			self.missing[o.networkID] = nil
			self.VisibleSince[o.networkID] = clock()
			return
		end
	end
	if p.header == self.Packets.Recall.Header then
		p.pos = self.Packets.Recall.pos
		local bytes = {}
		for i=4, 1, -1 do
			bytes[i] = self.Packets.Recall.bytes[p:Decode1()] or 0
		end
		local netID = bxor(lshift(band(bytes[1],0xFF),24),lshift(band(bytes[2],0xFF),16),lshift(band(bytes[3],0xFF),8),band(bytes[4],0xFF))
		local o = objManager:GetObjectByNetworkId(DwordToFloat(netID))
		if o and o.valid and o.type == 'AIHeroClient' and o.team == TEAM_ENEMY then
			p.pos = self.Packets.Recall.tpPos
			local isTP = p:Decode1() == self.Packets.Recall.isTP
			local str = ''
			if not isTP then
				p.pos=self.Packets.Recall.stringPos
				for i=1, p.size do
					local b = p:Decode1()
					if b == 0 then break end
					str=str..string.char(b)
				end
			else
				str = 'teleport'
			end
			if self.recallTimes[str:lower()] then
				self.ActiveRecalls[o.networkID] = {
					name = o.charName,
					startT = clock(),
					duration = self.recallTimes[str:lower()],
					endT = clock() + self.recallTimes[str:lower()],	
					isTP = isTP
				}
				return			
			elseif self.ActiveRecalls[o.networkID] then
				if self.ActiveRecalls[o.networkID].endT > clock() then
					self.ActiveRecalls[o.networkID] = nil
					return
				else
					if not self.ActiveRecalls[o.networkID].isTP then
						self.missing[o.networkID] = {pos = self.recallEndPos, name = o.charName, mTime = clock(),}
					end
					self.ActiveRecalls[o.networkID].complete = clock() + 3
					return
				end
			end
		end
	end
end

function MISS:WndMsg(m,k)
	if m==WM_LBUTTONDOWN and IsKeyDown(menuKey) then
		local CursorPos = GetCursorPos()
		if CursorPos.x > self.Anchor.x and CursorPos.x < self.Anchor.x + GetScale(self.Anchor.x2, self.Menu.RecallScale) then
			if CursorPos.y < self.Anchor.y and CursorPos.y > self.Anchor.y - GetScale(128, self.Menu.RecallScale) then
				self.IsMoving = true
				self.MovingOffset = {x=CursorPos.x-self.Anchor.x, y=CursorPos.y-self.Anchor.y,}
			end
		end
		if CursorPos.x > self.Anchor2.x - GetScale(100, self.Menu.JungleScale) and CursorPos.x < self.Anchor2.x + GetScale(100, self.Menu.JungleScale) then
			if CursorPos.y < self.Anchor2.y + GetScale(25, self.Menu.JungleScale) and CursorPos.y > self.Anchor2.y - GetScale(25, self.Menu.JungleScale) then		
				self.IsMoving2 = true
				self.MovingOffset2 = {x=CursorPos.x-self.Anchor2.x, y=CursorPos.y-self.Anchor2.y,}
			end			
		end
	end
	if m==WM_LBUTTONUP and (self.IsMoving or self.IsMoving2) then
		self.IsMoving=false
		self.IsMoving2=false
	end
end

function MISS:JunglePackets(p)
	if p.header == self.Packets.Reset.Header then
		p.pos=self.Packets.Reset.pos
		local o = objManager:GetObjectByNetworkId(p:DecodeF())
		if (not o) or (o.valid and not o.visible) then
			p.pos=self.Packets.Reset.pos2
			local d4 = p:Decode4()
			if self.Packets.JunglePos[d4] then
				for i, camp in ipairs(self.JungleTracker) do
					if camp.pos.x == self.Packets.JunglePos[d4].pos.x then 
						return 
					end
				end
				if o then
					for i, ally in ipairs(self.Allies) do
						if ally.valid and GetDistanceSqr(ally.pos, o.pos) < 2250000 then
							return
						end
					end
				end
				self.JungleTracker[#self.JungleTracker + 1] = { ['pos'] = self.Packets.JunglePos[d4].pos, ['endTime'] = os.clock() + 10, ['text'] = self.Packets.JunglePos[d4].text, }
			end
		end
	elseif p.header == self.Packets.Aggro.Header then
		p.pos=self.Packets.Aggro.pos
		local o = objManager:GetObjectByNetworkId(p:DecodeF())
		if o and o.valid and not o.visible and o.name:find('Dragon') then
			for i, camp in ipairs(self.JungleTracker) do
				if camp.isDragon then
					return 
				end
			end
			for i, ally in ipairs(self.Allies) do
				if ally.valid and GetDistanceSqr(ally.pos, o.pos) < 2250000 then
					return
				end
			end
			self.JungleTracker[#self.JungleTracker + 1] = { 
				['pos'] = GetMinimap(Vector(9866, 60, 4414)), 
				['endTime'] = os.clock() + 10, 
				['text'] = 'Dragon', 
			}
		end
	elseif p.header == self.Packets.Missile.Header or p.header == self.Packets.AggroUpdate.Header then
		p.pos=self.Packets.Missile.pos
		local o = objManager:GetObjectByNetworkId(p:DecodeF())
		if o and o.valid and o.team == 300 and not o.visible then
			local index
			for i, info in pairs(self.Packets.JunglePos) do
				if info.name == o.name then
					index = i
					break
				end
			end
			if index then
				for i, camp in ipairs(self.JungleTracker) do
					if camp.pos.x == self.Packets.JunglePos[index].pos.x then 
						return 
					end
				end
				for i, ally in ipairs(self.Allies) do
					if ally.valid and GetDistanceSqr(ally.pos, o.pos) < 2250000 then
						return
					end
				end
				self.JungleTracker[#self.JungleTracker + 1] = { ['pos'] = self.Packets.JunglePos[index].pos, ['endTime'] = os.clock() + 10, ['text'] = self.Packets.JunglePos[index].text, }
			end
		end		
	end
end

function MISS:Draw()
	if not self.Menu.Enable then return end
	local isMenuOpen = IsKeyDown(menuKey)
	local mCount = 1
	for _, info in pairs(self.missing) do
		if info then
			local scale = (self.Sprites[_].scale * self.Sprites[_].width) * 0.5
			if info.direction then
				DrawLine(info.direction.x,info.direction.y,info.pos.x,info.pos.y,3,COLOR_RED)
			end
			self.Sprites[_]:SetScale(self.Menu.SpriteSize * 0.01, self.Menu.SpriteSize * 0.01)
			self.Sprites[_]:Draw(info.pos.x-scale, info.pos.y-scale, 255)
			local t = ('%d'):format(clock()-info.mTime)
			local ta = GetTextArea(t, self.Menu.TextSize)
			DrawText(t, self.Menu.TextSize, info.pos.x-(ta.x*0.5), info.pos.y-(ta.y*0.5)+scale, COLOR_RED)
			if info.pos2 then
				local wts = WorldToScreen(D3DXVECTOR3(info.pos2.x,info.pos2.y,info.pos2.z))
				if wts.x>-100 and wts.x<WINDOW_W+100 and wts.y>-100 and wts.y<WINDOW_H+100 then
					self.Sprites[_]:SetScale(1, 1)
					self.Sprites[_]:Draw(wts.x, wts.y, 255)
					local curHP = info.unit.charName == 'Kled' and info.unit.health + info.unit.mountHealth or info.unit.health
					local maxHP = info.unit.charName == 'Kled' and info.unit.maxHealth + info.unit.mountMaxHealth or info.unit.maxHealth
					local text = ('%u / %u'):format(curHP, maxHP)
					local textArea = GetTextArea(text, 16).x * 0.5
					DrawLine(wts.x+23-textArea,wts.y+62,wts.x+31+textArea,wts.y+62,18,0x99888888)
					local width = (wts.x+31+textArea) - (wts.x+23-textArea)
					DrawLine(wts.x+24-textArea,wts.y+62,wts.x+23-textArea + (width * (curHP / maxHP))-1,wts.y+62,16,0x99008800)
					DrawText(text,16,wts.x+27-textArea,wts.y+54,0xFFFFFFFF)
					DrawText(t, 30, wts.x+27-(GetTextArea(t, 30).x * 0.5), wts.y-12, 0xFFFF0000)					
				end
			end
		end
	end
	if self.Menu.EnableRecall then		
		local Scale0 = GetScale(12, self.Menu.RecallScale)
		local Scale1 = GetScale(8, self.Menu.RecallScale)
		local Scale2 = GetScale(2, self.Menu.RecallScale)
		local Scale3 = GetScale(self.Anchor.x2, self.Menu.RecallScale)
		if isMenuOpen then
			for i=0, 4 do 
				local Scale4 = GetScale(i * 30, self.Menu.RecallScale)
				DrawLine(
					self.Anchor.x-2, 
					self.Anchor.y - Scale4, 
					self.Anchor.x + Scale3 + 2, 
					self.Anchor.y - Scale4, 
					GetScale(16, self.Menu.RecallScale) + 4, 
					0x77FFFFFF
				)
				DrawText(
					'Recall Bar Position', 
					Scale0, 
					self.Anchor.x + (Scale3 / 2) - (GetTextArea('Recall Bar Position', Scale0).x / 2), 
					self.Anchor.y - GetScale(6, self.Menu.RecallScale) - Scale4, 
					COLOR_WHITE
				)	
			end
			if self.IsMoving then
				local CursorPos = GetCursorPos()
				self.Anchor.x = CursorPos.x-self.MovingOffset.x
				self.Anchor.y = CursorPos.y-self.MovingOffset.y
				GlobalAnchors.RecallBar = {
					['x'] = self.Anchor.x,
					['y'] = self.Anchor.y,
				}
			end
		else
			local RecallCount = 0
			for _, info in pairs(self.ActiveRecalls) do
				local Scale4 = GetScale(RecallCount * 30, self.Menu.RecallScale)
				local percent = (info.endT - clock()) / info.duration
				local x2 = self.Anchor.x + (Scale3 * (percent < 1 and percent or 1))
				DrawLine(
					self.Anchor.x-2, 
					self.Anchor.y - Scale4, 
					self.Anchor.x + Scale3 + 2, 
					self.Anchor.y - Scale4, 
					GetScale(16, self.Menu.RecallScale) + 4, 
					info.isTP and 0x770099FF or 0x77FFFFFF
				)
				DrawLine(
					self.Anchor.x, 
					self.Anchor.y - Scale4, 
					(x2 > self.Anchor.x+1 and x2 or self.Anchor.x), 
					self.Anchor.y - Scale4, 
					GetScale(16, self.Menu.RecallScale), 
					ARGB(255, 255 * percent, 255 - (255 * percent), 0)
				)
				if info.complete and info.complete < clock() then
					self.ActiveRecalls[_] = nil
					return
				end
				local text = info.complete and info.name..' Completed.' or info.isTP and info.name..': Teleport '..ceil(percent * 100)..'%' or info.name..' '..ceil(percent * 100)..'%'
				DrawText(
					text, 
					Scale0, 
					self.Anchor.x + (Scale3 / 2) - (GetTextArea(text, Scale0).x / 2), 
					self.Anchor.y - GetScale(6, self.Menu.RecallScale) - Scale4, 
					COLOR_WHITE
				)	
				RecallCount = RecallCount + 1
			end
		end
	end
	if self.Menu.EnableJungle then		
		local Scale0 = GetScale(100, self.Menu.JungleScale)
		local Scale1 = Scale0 * 0.25
		if isMenuOpen then			
			DrawLine(self.Anchor2.x - Scale0-2, self.Anchor2.y, self.Anchor2.x + Scale0+2, self.Anchor2.y, (Scale0 * 0.5) + 4, 0x77FFFFFF)
			DrawLine(self.Anchor2.x - Scale0, self.Anchor2.y, self.Anchor2.x + Scale0, self.Anchor2.y, Scale0 * 0.5, COLOR_TRANS_RED)
			DrawText(
				'Position', 
				(Scale0 * 0.32), 
				self.Anchor2.x - (GetTextArea('Position', (Scale0 * 0.32)).x / 2), 
				self.Anchor2.y - (Scale0 * 0.1), 
				COLOR_TRANS_WHITE
			)
			DrawText(
				'Jungle Tracker',
				Scale0 * 0.16,
				self.Anchor2.x - (Scale0 * 0.45),
				self.Anchor2.y - Scale1,
				COLOR_TRANS_WHITE
			)
			if self.IsMoving2 then
				local CursorPos = GetCursorPos()
				self.Anchor2.x = CursorPos.x-self.MovingOffset2.x
				self.Anchor2.y = CursorPos.y-self.MovingOffset2.y
				GlobalAnchors.JungleTracker = {
					['x'] = self.Anchor2.x,
					['y'] = self.Anchor2.y,
				}
			end
		else
			for i, camp in ipairs(self.JungleTracker) do
				if camp.endTime < os.clock() then
					table.remove(self.JungleTracker, i)
					return
				end
        
        if not self.Size then self.Size = 15 end
        
        local p, p2 = {}, {}
        for theta = 0, pi2, (pi2/36) do
          local c, s = cos(theta), sin(theta)
          p[#p+1] = D3DXVECTOR2(camp.pos.x+(self.Size*c),camp.pos.y+(self.Size*s))
          if self.Size < 12 then
            local sz = self.Size+3
            p2[#p2+1] = D3DXVECTOR2(camp.pos.x+(sz*c),camp.pos.y+(sz*s))
          end
        end
        DrawLines2(p, 1, COLOR_RED)
        DrawLines2(p2, 1, COLOR_RED)
        self.Size=self.Size-.25
        if self.Size < 3 then self.Size=15 end
			end
			if #self.JungleTracker == 1 then
				DrawLine(self.Anchor2.x - Scale0-2, self.Anchor2.y, self.Anchor2.x + Scale0+2, self.Anchor2.y, (Scale0 * 0.5) + 4, 0x77FFFFFF)
				DrawLine(self.Anchor2.x - Scale0, self.Anchor2.y, self.Anchor2.x + Scale0, self.Anchor2.y, Scale0 * 0.5, COLOR_TRANS_RED)
				DrawText(
					self.JungleTracker[1].text, 
					(Scale0 * 0.32), 
					self.Anchor2.x - (GetTextArea(self.JungleTracker[1].text, (Scale0 * 0.32)).x / 2), 
					self.Anchor2.y - (Scale0 * 0.1), 
					COLOR_TRANS_WHITE
				)
				DrawText(
					'Jungle Tracker',
					Scale0 * 0.16,
					self.Anchor2.x - (Scale0 * 0.45),
					self.Anchor2.y - Scale1,
					COLOR_TRANS_WHITE
				)
			end
		end
	end 
end

class 'SKILLS'

function SKILLS:__init()
	CreateDirectory(SPRITE_PATH..'Pewtility/')
	local pngChecks = {
		['barTemplate_r2.png'] = {
			['localPath'] = SPRITE_PATH..'/Pewtility/barTemplate_r2.png',
			['url'] = '/7ktM3ej.png',
		},
		['summonerbarrier.png'] = {
			['localPath'] = SPRITE_PATH..'/Pewtility/summonerbarrier.png',
			['url'] = '/68VUJSl.png',
		},
		['summonerboost.png'] = {
			['localPath'] = SPRITE_PATH..'/Pewtility/summonerboost.png',
			['url'] = '/CAVVQ9B.png',
		},
		['summonerclairvoyance.png'] = {
			['localPath'] = SPRITE_PATH..'/Pewtility/summonerclairvoyance.png',
			['url'] = '/gvYFTpu.png',
		},
		['summonerdot.png'] = {
			['localPath'] = SPRITE_PATH..'/Pewtility/summonerdot.png',
			['url'] = '/kCD3WjZ.png',
		},
		['summonerexhaust.png'] = {
			['localPath'] = SPRITE_PATH..'/Pewtility/summonerexhaust.png',
			['url'] = '/8EsF90W.png',
		},
		['summonerflash.png'] = {
			['localPath'] = SPRITE_PATH..'/Pewtility/summonerflash.png',
			['url'] = '/LhnU93g.png',
		},
		['summonerhaste.png'] = {
			['localPath'] = SPRITE_PATH..'/Pewtility/summonerhaste.png',
			['url'] = '/K4fmF83.png',
		},
		['summonerheal.png'] = {
			['localPath'] = SPRITE_PATH..'/Pewtility/summonerheal.png',
			['url'] = '/yTwLorm.png',
		},
		['summonermana.png'] = {
			['localPath'] = SPRITE_PATH..'/Pewtility/summonermana.png',
			['url'] = '/Rt0i7HR.png',
		},
		['summonerodingarrison.png'] = {
			['localPath'] = SPRITE_PATH..'/Pewtility/summonerodingarrison.png',
			['url'] = '/nCHmZra.png',
		},
		['summonersmite.png'] = {
			['localPath'] = SPRITE_PATH..'/Pewtility/summonersmite.png',
			['url'] = '/j6XAgXK.png',
		},
		['summonersnowball.png'] = {
			['localPath'] = SPRITE_PATH..'/Pewtility/summonersnowball.png',
			['url'] = '/D5TIXXe.png',
		},
		['summonerteleport.png'] = {
			['localPath'] = SPRITE_PATH..'/Pewtility/summonerteleport.png',
			['url'] = '/uY8WKfV.png',
		},
	}
	for k, v in pairs(pngChecks) do
		if not FileExist(v.localPath) then
			SxWebResulter(
				'i.imgur.com', 
				v.url, 
				function(file)
					local f = io.open(SPRITE_PATH..'Pewtility/'..k, 'w+b')
					f:write(file)
					f:close()
					Print('Sprite Download complete', true)
				end, 
				function() Print('An error occured downloading sprite') end
			)			
		end
	end
	self.SkillText = {
		['summonerdot']      		= 'Ignite',
		['summonerexhaust']  		= 'Exhaust',
		['summonerflash']    		= 'Flash',
		['summonerheal']     		= 'Heal',
		['summonersmite']    		= 'Smite',
		['summonerbarrier']  		= 'Barrier',
		['summonerclairvoyance']    = 'Clairvoyance',
		['summonermana']     		= 'Clarity',
		['summonerteleport']     	= 'Teleport',
		['summonerrevive']     		= 'Revive',
		['summonerhaste']     		= 'Ghost',
		['summonerboost']     		= 'Cleanse',
	}
	self.Heroes = {}
	for i=1, heroManager.iCount do
		local hero = heroManager:getHero(i)
		if not hero.isMe then
			self.Heroes[#self.Heroes+1] = {
				['hero'] = hero,
				['sum1'] = createSprite('Pewtility/'..hero:GetSpellData(SUMMONER_1).name..'.png'),
				['sum2'] = createSprite('Pewtility/'..hero:GetSpellData(SUMMONER_2).name..'.png'),
				['t1'] = self.SkillText[hero:GetSpellData(SUMMONER_1).name:lower()],
				['t2'] = self.SkillText[hero:GetSpellData(SUMMONER_2).name:lower()],
			}
		end
	end
	self.xOffsets = {
		['AniviaEgg'] = -0.1,
		['Annie'] = 0.05,
		['Darius'] = -0.05,
		['Jhin'] = 0.05,
		['Renekton'] = -0.05,
		['Sion'] = -0.05,
		['Thresh'] = -0.03,
	}
	self.yOffsets = {['Annie'] = 19, ['Jhin'] = 22,}
	self.ParTypes = {['Ashe'] = 0xFF00AAFF, ['Caitlyn'] = 0xFF00AAFF, ['Corki'] = 0xFF00AAFF, ['Draven'] = 0xFF00AAFF, ['Ezreal'] = 0xFF00AAFF, ['Graves'] = 0xFF00AAFF, ['Jayce'] = 0xFF00AAFF, ['Jinx'] = 0xFF00AAFF, ['Kalista'] = 0xFF00AAFF, ['Kindred'] = 0xFF00AAFF, ['KogMaw'] = 0xFF00AAFF, ['Kled'] = 0xFF555555, ['Lucian'] = 0xFF00AAFF, ['MasterYi'] = 0xFF00AAFF, ['MissFortune'] = 0xFF00AAFF, ['Pantheon'] = 0xFF00AAFF, ['Quinn'] = 0xFF00AAFF,['Shaco'] = 0xFF00AAFF, ['Sivir'] = 0xFF00AAFF, ['Talon'] = 0xFF00AAFF, ['Tristana'] = 0xFF00AAFF, ['Twitch'] = 0xFF00AAFF, ['Urgot'] = 0xFF00AAFF, ['Varus'] = 0xFF00AAFF, ['Vayne'] = 0xFF00AAFF, ['Fiora'] = 0xFF00AAFF, ['Annie'] = 0xFF00AAFF, ['Ahri'] = 0xFF00AAFF, ['Azir'] = 0xFF00AAFF, ['Bard'] = 0xFF00AAFF, ['Anivia'] = 0xFF00AAFF, ['Brand'] = 0xFF00AAFF, ['Cassiopeia'] = 0xFF00AAFF, ['Diana'] = 0xFF00AAFF, ['Ekko'] = 0xFF00AAFF, ['Evelynn'] = 0xFF00AAFF, ['FiddleSticks'] = 0xFF00AAFF, ['Fizz'] = 0xFF00AAFF, ['Heimerdinger'] = 0xFF00AAFF, ['Illaoi'] = 0xFF00AAFF, ['Karthus'] = 0xFF00AAFF, ['Kassadin'] = 0xFF00AAFF, ['Kayle'] = 0xFF00AAFF, ['Leblanc'] = 0xFF00AAFF, ['Lissandra'] = 0xFF00AAFF, ['Lux'] = 0xFF00AAFF, ['Malzahar'] = 0xFF00AAFF, ['Morgana'] = 0xFF00AAFF, ['Nidalee'] = 0xFF00AAFF,	['Orianna'] = 0xFF00AAFF, ['Ryze'] = 0xFF00AAFF, ['Swain'] = 0xFF00AAFF, ['Syndra'] = 0xFF00AAFF, ['Teemo'] = 0xFF00AAFF, ['TwistedFate'] = 0xFF00AAFF, ['Veigar'] = 0xFF00AAFF, ['Viktor'] = 0xFF00AAFF,['Xerath'] = 0xFF00AAFF, ['Ziggs'] = 0xFF00AAFF, ['Zyra'] = 0xFF00AAFF, ['Velkoz'] = 0xFF00AAFF, ['Zilean'] = 0xFF00AAFF, ['Alistar'] = 0xFF00AAFF, ['Blitzcrank'] = 0xFF00AAFF, ['Braum'] = 0xFF00AAFF, ['Galio'] = 0xFF00AAFF, ['Janna'] = 0xFF00AAFF, ['Karma'] = 0xFF00AAFF, ['Leona'] = 0xFF00AAFF, ['Lulu'] = 0xFF00AAFF, ['Nami'] = 0xFF00AAFF, ['Nunu'] = 0xFF00AAFF, ['Sona'] = 0xFF00AAFF, ['Soraka'] = 0xFF00AAFF, ['TahmKench'] = 0xFF00AAFF, ['Taric'] = 0xFF00AAFF, ['Thresh'] = 0xFF00AAFF, ['Darius'] = 0xFF00AAFF, ['Elise'] = 0xFF00AAFF, ['Gangplank'] = 0xFF00AAFF, ['Gragas'] = 0xFF00AAFF, ['Irelia'] = 0xFF00AAFF, ['JarvanIV'] = 0xFF00AAFF, ['Jax'] = 0xFF00AAFF, ['Khazix'] = 0xFF00AAFF, ['Nocturne'] = 0xFF00AAFF, ['Olaf'] = 0xFF00AAFF, ['Poppy'] = 0xFF00AAFF, ['RekSai'] = 0xFF00AAFF, ['Trundle'] = 0xFF00AAFF, ['Udyr'] = 0xFF00AAFF, ['Vi'] = 0xFF00AAFF, ['MonkeyKing'] = 0xFF00AAFF, ['XinZhao'] = 0xFF00AAFF, ['Amumu'] = 0xFF00AAFF, ['Chogath'] = 0xFF00AAFF,['Hecarim'] = 0xFF00AAFF, ['Malphite'] = 0xFF00AAFF, ['Maokai'] = 0xFF00AAFF, ['Nasus'] = 0xFF00AAFF, ['Rammus'] = 0xFF00AAFF, ['Sejuani'] = 0xFF00AAFF, ['Nautilus'] = 0xFF00AAFF, ['Sion'] = 0xFF00AAFF, ['Singed'] = 0xFF00AAFF, ['Skarner'] = 0xFF00AAFF, ['Volibear'] = 0xFF00AAFF, ['Warwick'] = 0xFF00AAFF, ['Yorick'] = 0xFF00AAFF, ['Vladimir'] = 0xFF000000, ['Katarina'] = 0xFF000000, ['Garen'] = 0xFF000000, ['Riven'] = 0xFF000000, ['DrMundo'] = 0xFF000000, ['Zac'] = 0xFF000000, ['Zed'] = 0xFFFFBB00, ['Akali'] = 0xFFFFBB00, ['Kennen'] = 0xFFFFBB00, ['LeeSin'] = 0xFFFFBB00, ['Shen'] = 0xFFFFBB00, ['Mordekaiser'] = 0xFF555555, ['Tryndamere'] = 0xFFFF3300,}
	self.SpecialParTypes = {
		['Aatrox'] = function(unit) return unit.mana == 100 and 0xFFFF3300 or 0xFF555555 end, 
		['Gnar'] = function(unit) return myHero.range == 410.5 and 0xFF555555 or 0xFFFF3300 end, 
		['Renekton'] = function(unit) return unit.mana > 50 and 0xFFFF3300 or 0xFF555555 end, 
		['Rengar'] = function(unit) return unit.mana < 5 and 0xFF555555 or 0xFFFF3300 end,
		['Rumble'] = function(unit) return unit.mana < 50 and 0xFF555555 or unit.mana < 100 and 0xFFFF9900 end,
		['Shyvana'] = function(unit) return unit.mana == 100 and 0xFFFF3300 or 0xFFFF9900 end,
		['Yasuo'] = function(unit) return unit.mana==unit.maxMana and 0xFFFF3300 or 0xFF555555 end, 
	}
	self:CreateMenu()
	self.Sprite = createSprite('Pewtility/barTemplate_r2.png')
	
	self.Sprite:SetScale(0.3,0.3)
	
	AddDrawCallback(function() self[self.Menu.UseOld and 'DrawOLD' or 'Draw'](self) end)
	--[[
	self.CallTimers = {}
	AddMsgCallback(function(m,k)
		if m==513 and k==1 then
			if self.Menu.Key then
				local cursor = GetCursorPos()
				for k, v in pairs(self.CallTimers) do
					if cursor.x > v.x and cursor.x < v.x + 44 and cursor.y > v.y and cursor.y < v.y+12 then
						print(k:lower():sub(1,4)..' '..v.text:lower():gsub('summoner', '')..' '..('%d %.2d'):format(v.t/60, v.t%60))
					end
				end
			end
		end
	end)
	--]]
	-- AddProcessSpellCallback(function(unit,spell)
		-- if unit.valid and self.SkillText[spell.name:lower()] then
			
		-- end
	-- end)
end

function SKILLS:CreateMenu()
	MainMenu:addSubMenu('Cooldown Tracker', 'CooldownTracker2')
	self.Menu = MainMenu.CooldownTracker2
	self.Menu:addParam('Enemy', 'Enable Enemy Cooldown Tracker', SCRIPT_PARAM_ONOFF, true)
	self.Menu:addParam('Ally', 'Enable Ally Cooldown Tracker', SCRIPT_PARAM_ONOFF, true)
	self.Menu:addParam('Scale', 'HP Bar Scale', SCRIPT_PARAM_SLICE, 75, 75, 100)
	self.Menu:addParam('Text', 'Draw Text (Timers)', SCRIPT_PARAM_ONOFF, true)
	self.Menu:addParam('SPACE', '', SCRIPT_PARAM_INFO, '')
	self.Menu:addParam('UseOld', 'Use Old', SCRIPT_PARAM_ONOFF, false)
	--sM:addParam('Key', 'Chat Summoner Cooldowns', SCRIPT_PARAM_ONKEYDOWN, false, ('N'):byte())
end

function SKILLS:Draw()
	PewtilityHPBars.Active = true
	local s = self.Menu.Scale
	self.Sprite:SetScale(GetScale2(0.3, s), GetScale2(0.3, s))
	local AddonText = {}
	for _, info in ipairs(self.Heroes) do
		if info.hero.valid and info.hero.visible and not info.hero.dead and ((info.hero.team == myHero.team and self.Menu.Ally) or (info.hero.team ~= myHero.team and self.Menu.Enemy)) then
			local barX, barY = self:BarData(info.hero)
			local barX, barY = barX - GetScale(100, s), barY+GetScale(15, s)
			if barX > -100 and barX < WINDOW_W + 100 and barY > -100 and barY < WINDOW_H + 100 then
				--HP
				local curHP = info.hero.charName == 'Kled' and info.hero.health + info.hero.mountHealth or info.hero.health
				local maxHP = info.hero.charName == 'Kled' and info.hero.maxHealth + info.hero.mountMaxHealth or info.hero.maxHealth
				
				local hpMidX = barX + GetScale(102 + (187 * curHP / (maxHP+info.hero.shield)), s)
				local hpY = GetScale(17, s)
				local hpFS = GetScale(30,s)
				local baseHP = barX + GetScale(102,s)
				DrawLine(baseHP, barY + hpY, hpMidX, barY + hpY,hpFS,info.hero.team==TEAM_ALLY and 0xFF0088FF or 0xFFFF4400)
				
				if PewtilityHPBars.Addon[info.hero.networkID] then
					local xOffset = hpMidX
					for i, barInfo in ipairs(PewtilityHPBars.Addon[info.hero.networkID]) do
						local damageOffset = GetScale(187 - (187 * (info.hero.maxHealth-barInfo.damage) / (info.hero.maxHealth+info.hero.shield)), s)
						local newOffset = xOffset - damageOffset
						if newOffset < baseHP then
							newOffset = baseHP - 1
							table.insert(AddonText, {
								text = PewtilityHPBars.Addon[info.hero.networkID].bMana and 'Can Kill!' or 'Not enough Mana!',
								size = GetScale(16, s),
								x = baseHP,
								y = barY - GetScale(10, s)
							})	
						end						
						DrawLine(xOffset,barY + hpY,newOffset,barY + hpY,hpFS,barInfo.color)
						if barInfo.text then
							table.insert(AddonText, {
								text = barInfo.text,
								size = GetScale(13, s),
								x = newOffset+2,
								y = barY + GetScale(6, s)
							})
						end
						if newOffset < baseHP then break end
						xOffset = newOffset
					end	
					PewtilityHPBars.Addon[info.hero.networkID] = nil
				end
				
				if info.hero.shield > 0 then
					local shieldMidX = hpMidX + GetScale(187 * info.hero.shield / maxHP, s)
					DrawLine(hpMidX, barY + hpY, shieldMidX,barY + hpY,hpFS,0xFFCCCCCC)
					hpMidX = shieldMidX
				end
				local slopeI=0
				for i=1, (curHP+info.hero.shield)*0.01 do
					local x = barX + GetScale(102 + (187 * (100*i) / (maxHP+info.hero.shield)), s)
					local l, w = 12, 1
					if x<barX+GetScale(158,s) then
						l=22
						slopeI = 3
					elseif x<barX+GetScale(164,s) then
						l=l+GetScale(2.25*slopeI,s)
						slopeI = math.max(slopeI - 1, 0)						
					end
					if i==10 or i==20 or i==30 or i==40 or i==50 then
						l, w = 28, 2
					end
					local l = GetScale(l, s)
					DrawLine(x,barY+2,x,barY+l,w,0xFF000000)
				end
				DrawLine(hpMidX, barY + hpY, barX + GetScale(288,s),barY + hpY,hpFS,0xFF000000)
				
				--MP
				local mpMid = barX + GetScale(172 + (info.hero.maxMana~=0 and 90 * info.hero.mana / info.hero.maxMana or 0), s)
				local mpColor = self.ParTypes[info.hero.charName] or self.SpecialParTypes[info.hero.charName] and self.SpecialParTypes[info.hero.charName](info.hero) or 0xFF00AAFF
				local mpY = GetScale(33, s)
				DrawLine(barX + GetScale(172, s),barY + mpY, mpMid,barY + mpY,hpY,mpColor)
				DrawLine(mpMid,barY + mpY, barX + GetScale(264, s),barY + mpY,hpY,0xFF000000)
		
				--Spells
				for i=_Q, _R do
					local d = info.hero:GetSpellData(i)
					local color = d.level == 0 and 0xFF000000 or 0==d.currentCd and 0xFF00AA00 or 0xFFAA0000
					local cd = DwordToFloat(ReadDWORD(GetPtrS(d)+0x3C))
					local h = (d.level == 0 or 0==d.currentCd) and 24 or 24*(cd>0 and d.currentCd/cd or 0)
					local cdMid = barY+GetScale(29-h, s)
					local cdX = GetScale(68+(i*7.5), s)
					local cdFS = GetScale(7,s)
					DrawLine(barX+cdX,barY+GetScale(29, s),barX+cdX,cdMid,cdFS,color)
					DrawLine(barX+cdX,cdMid,barX+cdX,barY+GetScale(5,s),cdFS,0xFF000000)
					-- for k=1, d.level do
						-- local y = barY+GetScale(29-((i==_R and 8 or 5)*k), s)
						-- DrawLine(barX+cdX-3, y, barX+cdX+3, y, 1, 0xFF000000)
					-- end
				end
		
				--Summoners
				info.sum1:SetScale(GetScale2(0.411,s), GetScale2(0.43,s))
				info.sum1:Draw(barX+GetScale(7,s), barY+GetScale(4,s), 255)
				local sum1Cd = info.hero:GetSpellData(SUMMONER_1).currentCd
				local sumFS = GetScale(14,s)
				local CP = GetCursorPos()
				if sum1Cd~=0 then
					local mText = ('%u'):format(sum1Cd)
					local mTextArea = GetTextArea(mText, sumFS)
					DrawLine(barX+GetScale(20.5,s)-(mTextArea.x*0.5)-3,barY+GetScale(24,s),barX+GetScale(20.5,s)+(mTextArea.x*0.5)+3,barY+GetScale(24,s),mTextArea.y,0xFF000000)
					DrawText(mText,sumFS,barX+GetScale(20.5,s)-(mTextArea.x*0.5),barY+GetScale(24,s)-(mTextArea.y*0.5),0xFFFFFFFF)
				end
				info.sum2:SetScale(GetScale2(0.411,s), GetScale2(0.43,s))
				info.sum2:Draw(barX+GetScale(33,s), barY+GetScale(4,s), 255)
				local sum2Cd = info.hero:GetSpellData(SUMMONER_2).currentCd
				if sum2Cd~=0 then
					local mText = ('%u'):format(sum2Cd)
					local mTextArea = GetTextArea(mText, sumFS)
					DrawLine(barX+GetScale(46.5,s)-(mTextArea.x*0.5)-3,barY+GetScale(24,s),barX+GetScale(46.5,s)+(mTextArea.x*0.5)+3,barY+GetScale(24,s),mTextArea.y,0xFF000000)
					DrawText(mText,sumFS,barX+GetScale(46.5,s)-(mTextArea.x*0.5),barY+GetScale(24,s)-(mTextArea.y*0.5),0xFFFFFFFF)
				end
				
				self.Sprite:Draw(barX, barY, 255)				
				-- self.Sprite:DrawEx(Rect(0,0,1025,151), D3DXVECTOR3(0, 0, 0), D3DXVECTOR3(barX+1025, barY+151, 0), 0xFF)
				
				for _, tDraw in ipairs(AddonText) do
					DrawText(tDraw.text,tDraw.size,tDraw.x,tDraw.y,0xFFFFFFFF)					
				end
				
				if self.Menu.Text then
					local hText = ('%u / %u'):format(info.hero.health + info.hero.shield, info.hero.maxHealth)
					local hTextArea = GetTextArea(hText, hpY)
					DrawText(hText,hpY,barX+GetScale(146,s)-(hTextArea.x*0.5),barY+GetScale(18,s)-(hTextArea.y*0.5),0xFFFFFFFF)
					
					local mText = ('%u / %u'):format(info.hero.mana, info.hero.maxMana)
					local mpFS = GetScale(14, s)
					local mTextArea = GetTextArea(mText, mpFS)
					DrawText(mText,mpFS,barX+GetScale(218,s)-(mTextArea.x*0.5),barY+GetScale(34-(mTextArea.y*0.5),s),0xFFFFFFFF)
				end				
				DrawText(info.hero.level..'',GetScale(16,s),barX+GetScale(283,s),barY+GetScale(26,s),0xFFFFFFFF)
			end
		end
	end
end

function SKILLS:DrawOLD()
	PewtilityHPBars.Active = false
	for _, info in ipairs(self.Heroes) do
		if info.hero.valid and info.hero.visible and not info.hero.dead and ((info.hero.team == myHero.team and self.Menu.Ally) or (info.hero.team ~= myHero.team and self.Menu.Enemy)) then
			local barX, barY = self:BarData(info.hero)
			if barX > -100 and barX < WINDOW_W + 100 and barY > -100 and barY < WINDOW_H + 100 then
				barX, barY = ceil(barX), ceil(barY)
				DrawLine(barX-29,barY+51,barX+62,barY+51,29,info.hero.team == myHero.team and ARGB(220, 114, 213, 242) or ARGB(220, 204, 126, 114))
				for i=_Q, _R do
					local data = info.hero:GetSpellData(i)
					local x = barX-27+(i*22)
					local y = barY+44
					if data.level > 0 then
						if data.currentCd ~= 0 then
							local cda = DwordToFloat(ReadDWORD(GetPtrS(data)+0x3C))
							cda=cda>0 and cda or 0
							local cd = cda-(cda-data.currentCd)
							DrawLine(x, y, x+((cd / cda) * 21), y, 12, COLOR_ORANGE)
							DrawLine(x+((cd / cda) * 21), y, x+21, y, 12, COLOR_GREY)
							if self.Menu.Text then
								local text = ('%i'):format(cd)
								local tA = GetTextArea(text, 14)
								DrawText(text, 14, x + 11 - (tA.x / 2), y - (tA.y / 2), COLOR_WHITE)
							end
						else
							DrawLine(x,y,x+21,y,12,COLOR_GREEN)							
						end
					else
						DrawLine(x,y,x+21,y,12,COLOR_GREY)							
					end
				end
				for i=SUMMONER_1, SUMMONER_2 do
					local data = info.hero:GetSpellData(i)					
					local x = barX-27+((i-4)*42) + ((i-4)*2.5)
					local y = barY+47
					local text = info['t'..(i-3)]
					if data.currentCd ~= 0 then
						local cda = DwordToFloat(ReadDWORD(GetPtrS(data)+0x3C))
						cda=cda>0 and cda or 0
						local cd = cda-(cda-data.currentCd)
						DrawLine(x, y+11, x+((cd / cda) * 42), y+11, 12, COLOR_ORANGE)
						DrawLine(x+((cd / cda) * 42), y+11, x+42, y+11, 12, COLOR_GREY)
						--self.CallTimers[enemy.charName] = {x=x, y=y+5,t=floor(data.currentCd+GetInGameTimer()), text=text}
					else
						DrawLine(x, y+11, x+42, y+11, 12, COLOR_GREEN)								
					end
					if self.Menu.Text then
						local tA = GetTextArea(text, 11)
						DrawText(text, 11, x + 22 - (tA.x / 2), y + 11 - (tA.y / 2), COLOR_WHITE)
					end
				end
			end
		end
	end
end

function SKILLS:BarData(enemy)
	local barPos = GetUnitHPBarPos(enemy)
	local barOff = GetUnitHPBarOffset(enemy)
	
	return barPos.x + ((self.xOffsets[enemy.charName] or 0) * 140) - 38, barPos.y + (barOff.y * 53) - 22 - (self.yOffsets[enemy.charName] or 0)
end

class 'TIMERS'

function TIMERS:__init()
	self.map = GetGame2().Map.Name
	self.Packets = GetGameVersion():sub(1,4) == '6.21' and {
		['Jungle'] = { ['Header'] = 0x0122, ['campPos'] = 6, ['idPos'] = 10, ['idZero'] = 0x02020202, }, --size 24 
		['Inhibitor'] = { ['Header'] = 0x00A3, ['pos'] = 2, },  --pick the one that is size 19
		['SummonerRift'] = {
			[0x09] = { ['pos'] = Vector(3850, 60, 7880),  ['time'] = 300, ['mapPos'] = GetMinimap(Vector(3850, 60, 7880)),  }, --Blue Side Blue Buff
			[0xEF] = { ['pos'] = Vector(3800, 60, 6500),  ['time'] = 100, ['mapPos'] = GetMinimap(Vector(3800, 60, 6500)),  }, --Blue Side Wolves
			[0x47] = { ['pos'] = Vector(7000, 60, 5400),  ['time'] = 100, ['mapPos'] = GetMinimap(Vector(7000, 60, 5400)),  }, --Blue Side Raptors
			[0xEB] = { ['pos'] = Vector(7800, 60, 4000),  ['time'] = 300, ['mapPos'] = GetMinimap(Vector(7800, 60, 4000)),  }, --Blue Side Red Buff
			[0x68] = { ['pos'] = Vector(8400, 60, 2700),  ['time'] = 100, ['mapPos'] = GetMinimap(Vector(8400, 60, 2700)),  }, --Blue Side Krugs
			[0xDD] = { ['pos'] = Vector(9866, 60, 4414),  ['time'] = 360, ['mapPos'] = GetMinimap(Vector(9866, 60, 4414)),  ['isDragon'] = true, }, --Dragon
			[0xF4] = { ['pos'] = Vector(10950, 60, 7030), ['time'] = 300, ['mapPos'] = GetMinimap(Vector(10950, 60, 7030)), }, --Red Side Blue Buff
			[0x14] = { ['pos'] = Vector(11000, 60, 8400), ['time'] = 100, ['mapPos'] = GetMinimap(Vector(11000, 60, 8400)), }, --Red Side Wolves	
			[0xB5] = { ['pos'] = Vector(7850, 60, 9500),  ['time'] = 100, ['mapPos'] = GetMinimap(Vector(7850, 60, 9500)),  }, --Red Side Raptors
			[0x44] = { ['pos'] = Vector(7100, 60, 10900), ['time'] = 300, ['mapPos'] = GetMinimap(Vector(7100, 60, 10900)), }, --Red Side Red Buff
			[0xA4] = { ['pos'] = Vector(6400, 60, 12250), ['time'] = 100, ['mapPos'] = GetMinimap(Vector(6400, 60, 12250)), }, --Red Side Krugs
			[0xA0] = { ['pos'] = Vector(4950, 60, 10400), ['time'] = 420, ['mapPos'] = GetMinimap(Vector(4950, 60, 10400)), }, --Baron
			[0x96] = { ['pos'] = Vector(2200, 60, 8500),  ['time'] = 100, ['mapPos'] = GetMinimap(Vector(2200, 60, 8500)),  }, --Blue Side Gromp
			[0xE0] = { ['pos'] = Vector(12600, 60, 6400), ['time'] = 100, ['mapPos'] = GetMinimap(Vector(12600, 60, 6400)), }, --Red Side Gromp
			[0x84] = { ['pos'] = Vector(10500, 60, 5170), ['time'] = 180, ['mapPos'] = GetMinimap(Vector(10500, 60, 5170)), }, --Dragon Crab
			[0xA9] = { ['pos'] = Vector(4400, 60, 9600),  ['time'] = 180, ['mapPos'] = GetMinimap(Vector(4400, 60, 9600)),  }, --Baron Crab
			[0xFFD23C3E] = { ['pos'] = Vector(1170, 90, 3570),   ['time'] = 300, ['mapPos'] = GetMinimap(Vector(1170, 91, 3570)),   }, --Blue Top Inhibitor
			[0xFF4A20F1] = { ['pos'] = Vector(3203, 92, 3208),   ['time'] = 300, ['mapPos'] = GetMinimap(Vector(3203, 92, 3208)),   }, --Blue Middle Inhibitor
			[0xFF9303E1] = { ['pos'] = Vector(3452, 89, 1236),   ['time'] = 300, ['mapPos'] = GetMinimap(Vector(3452, 89, 1236)),   }, --Blue Bottom Inhibitor
			[0xFF6793D0] = { ['pos'] = Vector(11261, 88, 13676), ['time'] = 300, ['mapPos'] = GetMinimap(Vector(11261, 88, 13676)), }, --Red Top Inhibitor
			[0xFFFF8F1F] = { ['pos'] = Vector(11598, 89, 11667), ['time'] = 300, ['mapPos'] = GetMinimap(Vector(11598, 89, 11667)), }, --Red Middle Inhibitor
			[0xFF26AC0F] = { ['pos'] = Vector(13604, 89, 11316), ['time'] = 300, ['mapPos'] = GetMinimap(Vector(13604, 89, 11316)), }, --Red Bottom Inhibitor				
		},
		['TwistedTreeline'] = {
			[0x09] = { ['pos'] =  Vector(4414, 60, 5774), ['time'] =  75, ['mapPos'] = GetMinimap(Vector(4414, 60, 5774)),  },
			[0xEF] = { ['pos'] =  Vector(5088, 60, 8065), ['time'] =  75, ['mapPos'] = GetMinimap(Vector(5088, 60, 8065)),  },
			[0x47] = { ['pos'] =  Vector(6148, 60, 5993), ['time'] =  75, ['mapPos'] = GetMinimap(Vector(6148, 60, 5993)),  },
			[0xEB] = { ['pos'] = Vector(11008, 60, 5775), ['time'] =  75, ['mapPos'] = GetMinimap(Vector(11008, 60, 5775)), },
			[0x68] = { ['pos'] = Vector(10341, 60, 8084), ['time'] =  75, ['mapPos'] = GetMinimap(Vector(10341, 60, 8084)), },
			[0xDD] = { ['pos'] =  Vector(9239, 60, 6022), ['time'] =  75, ['mapPos'] = GetMinimap(Vector(9239, 60, 6022)),  },
			[0xF4] = { ['pos'] =  Vector(7711, 60, 6722), ['time'] =  90, ['mapPos'] = GetMinimap(Vector(7711, 60, 6722)),  },
			[0x14] = { ['pos'] = Vector(7711, 60, 10080), ['time'] = 360, ['mapPos'] = GetMinimap(Vector(7711, 60, 10080)), },
			[0xFFD303E1] = { ['pos'] = Vector(2126, 11, 6146),   ['time'] = 240, ['mapPos'] = GetMinimap(Vector(2126, 11, 6146)),   }, --Left Bottom Inhibitor
			[0xFFD23C3E] = { ['pos'] = Vector(2146, 11, 8420),   ['time'] = 240, ['mapPos'] = GetMinimap(Vector(2146, 11, 8420)),   }, --Left Top Inhibitor
			[0xFF26AC0F] = { ['pos'] = Vector(13285, 17, 6124),  ['time'] = 240, ['mapPos'] = GetMinimap(Vector(13285, 17, 6124)),  }, --Right Bottom Inhibitor
			[0xFF6793D0] = { ['pos'] = Vector(13275, 17, 8416),  ['time'] = 240, ['mapPos'] = GetMinimap(Vector(13275, 17, 8416)),  }, --Right Top Inhibitor			
		},
		['HowlingAbyss'] = {
			[0x09] = { ['pos'] = Vector(7582, -100, 6785), ['time'] =  60, ['mapPos'] = GetMinimap(Vector(7582, -100, 6785)), },
			[0xEF] = { ['pos'] = Vector(5929, -100, 5190), ['time'] =  60, ['mapPos'] = GetMinimap(Vector(5929, -100, 5190)), },
			[0x47] = { ['pos'] = Vector(8893, -100, 7889), ['time'] =  60, ['mapPos'] = GetMinimap(Vector(8893, -100, 7889)), },
			[0xEB] = { ['pos'] = Vector(4790, -100, 3934), ['time'] =  60, ['mapPos'] = GetMinimap(Vector(4790, -100, 3934)), },
			[0xFF4A20F1] = { ['pos'] = Vector(3110, -201, 3189), ['time'] = 300, ['mapPos'] = GetMinimap(Vector(3110, -201, 3189)), }, --Bottom Inhibitor
			[0xFFFF8F1F] = { ['pos'] = Vector(9689, -190, 9524), ['time'] = 300, ['mapPos'] = GetMinimap(Vector(9689, -190, 9524)), }, --Top Inhibitor			
		},
	} or GetGameVersion():sub(1,4) == '6.20' and {
		['Jungle'] = { ['Header'] = 0x0122, ['campPos'] = 6, ['idPos'] = 10, ['idZero'] = 0x02020202, }, --size 24 
		['Inhibitor'] = { ['Header'] = 0x00A3, ['pos'] = 2, },  --pick the one that is size 19
		['SummonerRift'] = {
			[0x09] = { ['pos'] = Vector(3850, 60, 7880),  ['time'] = 300, ['mapPos'] = GetMinimap(Vector(3850, 60, 7880)),  }, --Blue Side Blue Buff
			[0xEF] = { ['pos'] = Vector(3800, 60, 6500),  ['time'] = 100, ['mapPos'] = GetMinimap(Vector(3800, 60, 6500)),  }, --Blue Side Wolves
			[0x47] = { ['pos'] = Vector(7000, 60, 5400),  ['time'] = 100, ['mapPos'] = GetMinimap(Vector(7000, 60, 5400)),  }, --Blue Side Raptors
			[0xEB] = { ['pos'] = Vector(7800, 60, 4000),  ['time'] = 300, ['mapPos'] = GetMinimap(Vector(7800, 60, 4000)),  }, --Blue Side Red Buff
			[0x68] = { ['pos'] = Vector(8400, 60, 2700),  ['time'] = 100, ['mapPos'] = GetMinimap(Vector(8400, 60, 2700)),  }, --Blue Side Krugs
			[0xDD] = { ['pos'] = Vector(9866, 60, 4414),  ['time'] = 360, ['mapPos'] = GetMinimap(Vector(9866, 60, 4414)),  ['isDragon'] = true, }, --Dragon
			[0xF4] = { ['pos'] = Vector(10950, 60, 7030), ['time'] = 300, ['mapPos'] = GetMinimap(Vector(10950, 60, 7030)), }, --Red Side Blue Buff
			[0x14] = { ['pos'] = Vector(11000, 60, 8400), ['time'] = 100, ['mapPos'] = GetMinimap(Vector(11000, 60, 8400)), }, --Red Side Wolves	
			[0xB5] = { ['pos'] = Vector(7850, 60, 9500),  ['time'] = 100, ['mapPos'] = GetMinimap(Vector(7850, 60, 9500)),  }, --Red Side Raptors
			[0x44] = { ['pos'] = Vector(7100, 60, 10900), ['time'] = 300, ['mapPos'] = GetMinimap(Vector(7100, 60, 10900)), }, --Red Side Red Buff
			[0xA4] = { ['pos'] = Vector(6400, 60, 12250), ['time'] = 100, ['mapPos'] = GetMinimap(Vector(6400, 60, 12250)), }, --Red Side Krugs
			[0xA0] = { ['pos'] = Vector(4950, 60, 10400), ['time'] = 420, ['mapPos'] = GetMinimap(Vector(4950, 60, 10400)), }, --Baron
			[0x96] = { ['pos'] = Vector(2200, 60, 8500),  ['time'] = 100, ['mapPos'] = GetMinimap(Vector(2200, 60, 8500)),  }, --Blue Side Gromp
			[0xE0] = { ['pos'] = Vector(12600, 60, 6400), ['time'] = 100, ['mapPos'] = GetMinimap(Vector(12600, 60, 6400)), }, --Red Side Gromp
			[0x84] = { ['pos'] = Vector(10500, 60, 5170), ['time'] = 180, ['mapPos'] = GetMinimap(Vector(10500, 60, 5170)), }, --Dragon Crab
			[0xA9] = { ['pos'] = Vector(4400, 60, 9600),  ['time'] = 180, ['mapPos'] = GetMinimap(Vector(4400, 60, 9600)),  }, --Baron Crab
			[0xFFD23C3E] = { ['pos'] = Vector(1170, 90, 3570),   ['time'] = 300, ['mapPos'] = GetMinimap(Vector(1170, 91, 3570)),   }, --Blue Top Inhibitor
			[0xFF4A20F1] = { ['pos'] = Vector(3203, 92, 3208),   ['time'] = 300, ['mapPos'] = GetMinimap(Vector(3203, 92, 3208)),   }, --Blue Middle Inhibitor
			[0xFF9303E1] = { ['pos'] = Vector(3452, 89, 1236),   ['time'] = 300, ['mapPos'] = GetMinimap(Vector(3452, 89, 1236)),   }, --Blue Bottom Inhibitor
			[0xFF6793D0] = { ['pos'] = Vector(11261, 88, 13676), ['time'] = 300, ['mapPos'] = GetMinimap(Vector(11261, 88, 13676)), }, --Red Top Inhibitor
			[0xFFFF8F1F] = { ['pos'] = Vector(11598, 89, 11667), ['time'] = 300, ['mapPos'] = GetMinimap(Vector(11598, 89, 11667)), }, --Red Middle Inhibitor
			[0xFF26AC0F] = { ['pos'] = Vector(13604, 89, 11316), ['time'] = 300, ['mapPos'] = GetMinimap(Vector(13604, 89, 11316)), }, --Red Bottom Inhibitor				
		},
		['TwistedTreeline'] = {
			[0x09] = { ['pos'] =  Vector(4414, 60, 5774), ['time'] =  75, ['mapPos'] = GetMinimap(Vector(4414, 60, 5774)),  },
			[0xEF] = { ['pos'] =  Vector(5088, 60, 8065), ['time'] =  75, ['mapPos'] = GetMinimap(Vector(5088, 60, 8065)),  },
			[0x47] = { ['pos'] =  Vector(6148, 60, 5993), ['time'] =  75, ['mapPos'] = GetMinimap(Vector(6148, 60, 5993)),  },
			[0xEB] = { ['pos'] = Vector(11008, 60, 5775), ['time'] =  75, ['mapPos'] = GetMinimap(Vector(11008, 60, 5775)), },
			[0x68] = { ['pos'] = Vector(10341, 60, 8084), ['time'] =  75, ['mapPos'] = GetMinimap(Vector(10341, 60, 8084)), },
			[0xDD] = { ['pos'] =  Vector(9239, 60, 6022), ['time'] =  75, ['mapPos'] = GetMinimap(Vector(9239, 60, 6022)),  },
			[0xF4] = { ['pos'] =  Vector(7711, 60, 6722), ['time'] =  90, ['mapPos'] = GetMinimap(Vector(7711, 60, 6722)),  },
			[0x14] = { ['pos'] = Vector(7711, 60, 10080), ['time'] = 360, ['mapPos'] = GetMinimap(Vector(7711, 60, 10080)), },
			[0xFFD303E1] = { ['pos'] = Vector(2126, 11, 6146),   ['time'] = 240, ['mapPos'] = GetMinimap(Vector(2126, 11, 6146)),   }, --Left Bottom Inhibitor
			[0xFFD23C3E] = { ['pos'] = Vector(2146, 11, 8420),   ['time'] = 240, ['mapPos'] = GetMinimap(Vector(2146, 11, 8420)),   }, --Left Top Inhibitor
			[0xFF26AC0F] = { ['pos'] = Vector(13285, 17, 6124),  ['time'] = 240, ['mapPos'] = GetMinimap(Vector(13285, 17, 6124)),  }, --Right Bottom Inhibitor
			[0xFF6793D0] = { ['pos'] = Vector(13275, 17, 8416),  ['time'] = 240, ['mapPos'] = GetMinimap(Vector(13275, 17, 8416)),  }, --Right Top Inhibitor			
		},
		['HowlingAbyss'] = {
			[0x09] = { ['pos'] = Vector(7582, -100, 6785), ['time'] =  60, ['mapPos'] = GetMinimap(Vector(7582, -100, 6785)), },
			[0xEF] = { ['pos'] = Vector(5929, -100, 5190), ['time'] =  60, ['mapPos'] = GetMinimap(Vector(5929, -100, 5190)), },
			[0x47] = { ['pos'] = Vector(8893, -100, 7889), ['time'] =  60, ['mapPos'] = GetMinimap(Vector(8893, -100, 7889)), },
			[0xEB] = { ['pos'] = Vector(4790, -100, 3934), ['time'] =  60, ['mapPos'] = GetMinimap(Vector(4790, -100, 3934)), },
			[0xFF4A20F1] = { ['pos'] = Vector(3110, -201, 3189), ['time'] = 300, ['mapPos'] = GetMinimap(Vector(3110, -201, 3189)), }, --Bottom Inhibitor
			[0xFFFF8F1F] = { ['pos'] = Vector(9689, -190, 9524), ['time'] = 300, ['mapPos'] = GetMinimap(Vector(9689, -190, 9524)), }, --Top Inhibitor			
		},
	}
	self.activeTimers = {}
	self.checkLastDragon = false
	self.checkLastBaron = false
	self.tM = self:Menu()
	if not self.Packets then
		Print('Object Timers packets are outdated!!', true)
		return
	end
	AddDrawCallback(function() self:Draw() end)
	AddRecvPacketCallback2(function(p) self:RecvPacket(p) end)
	AddMsgCallback(function(m,k) self:WndMsg(m,k) end)
end

function TIMERS:Menu()
	MainMenu:addSubMenu('Object Timers', 'ObjectTimers')
	local tM = MainMenu.ObjectTimers
	tM:addParam('draw', 'Enable Object Timers', SCRIPT_PARAM_ONOFF, true)
	tM:addParam('type', 'Timer Type', SCRIPT_PARAM_LIST, 1, { 'Seconds', 'Minutes' })
	tM:addParam('size', 'Text Size', SCRIPT_PARAM_SLICE, 12, 2, 24)
	tM:addParam('RGB', 'Text Color', SCRIPT_PARAM_COLOR, {255,255,255,255})	
	tM:addParam('mapsize', 'Minimap Text Size', SCRIPT_PARAM_SLICE, 12, 2, 24)
	tM:addParam('mapRGB', 'Minimap Text Color', SCRIPT_PARAM_COLOR, {255,255,255,255})
	tM:addParam('modKey', 'Modifier Key(Default: Alt)', SCRIPT_PARAM_ONKEYDOWN, false, 18)
	tM:addParam('', 'ModKey+LeftClick a camp to start a timer.', SCRIPT_PARAM_INFO, '')
	return tM
end

function TIMERS:Draw()
	-- for k, v in pairs(self.Packets.SummonerRift) do
		-- DrawText3D(('0x%02X'):format(k),v.pos.x,v.pos.y,v.pos.z,22,ARGB(255,255,255,255))
	-- end
	
	if not self.tM.draw then return end
	for i, info in ipairs(self.activeTimers) do
		local timer = info.spawnTime-clock()
		local text = (self.tM.type == 1) and ('%d'):format(timer) or ('%d:%.2d'):format(timer/60, timer%60)
		DrawText3D(text, info.pos.x, info.pos.y, (info.pos.z-50), self.tM.size, ARGB(self.tM.RGB[1], self.tM.RGB[2], self.tM.RGB[3], self.tM.RGB[4]))
		DrawText(text, self.tM.mapsize, info.minimap.x-5, info.minimap.y-5, ARGB(self.tM.mapRGB[1], self.tM.mapRGB[2], self.tM.mapRGB[3], self.tM.mapRGB[4]))
		if timer <= 1 then 
			table.remove(self.activeTimers,i)
		end
	end
end

function TIMERS:RecvPacket(p)
	if p.header == self.Packets.Jungle.Header then
		p.pos = self.Packets.Jungle.campPos
		local camp = p:Decode1()
		-- print(('0x%02X'):format(camp))
		
		if self.Packets[self.map][camp] then
			p.pos = self.Packets.Jungle.idPos
			if p:Decode4() ~= self.Packets.Jungle.idZero then
				for i, timer in ipairs(self.activeTimers) do
					if timer.pos == self.Packets[self.map][camp].pos then
						table.remove(self.activeTimers, i)
					end
				end
				local respawnTime = (self.Packets[self.map][camp].isDragon and GetInGameTimer() > 2100) and 600 or self.Packets[self.map][camp].time
				self.activeTimers[#self.activeTimers + 1] = {
					['spawnTime'] = clock()+respawnTime, 
					['pos'] = self.Packets[self.map][camp].pos, 
					['minimap'] = self.Packets[self.map][camp].mapPos,
					['valid'] = true,
				}
			end
		end
		return
	end
	if p.header == self.Packets.Inhibitor.Header then
		p.pos=self.Packets.Inhibitor.pos
		local inhib = p:Decode4()
		if self.Packets[self.map][inhib] then
			self.activeTimers[#self.activeTimers + 1] = {
				['spawnTime'] = clock()+self.Packets[self.map][inhib].time, 
				['pos'] = self.Packets[self.map][inhib].pos, 
				['minimap'] = self.Packets[self.map][inhib].mapPos,
			}
		end
		return
	end
end

function TIMERS:WndMsg(m,k)
	if m == WM_LBUTTONDOWN and IsKeyDown(self.tM._param[7].key) then --17 ctrl
		local cP = GetCursorPos()
		for _, info in pairs(self.Packets[self.map]) do
			if _ <= 0xFF then
				local miniMap = info.mapPos
				if abs(cP.x-miniMap.x) < 17 and abs(cP.y-miniMap.y) < 17 then
					for i, timer in ipairs(self.activeTimers) do
						if timer.pos == info.pos then
							if timer.valid then return end
							table.remove(self.activeTimers, i)					
						end
					end
					self.activeTimers[#self.activeTimers + 1] = {
						['spawnTime'] = clock()+info.time, 
						['pos'] = info.pos, 
						['minimap'] = info.mapPos,
						['valid'] = false,
					}
					return
				end
			end
		end
	end
end

class 'OTHER'

function OTHER:__init()
	self.Turrets = {}
	for i=1, objManager.maxObjects do
		local obj = objManager:getObject(i)
		if obj and obj.valid and obj.type == 'obj_AI_Turret' and obj.name:find('Shrine') == nil then
			self.Turrets[#self.Turrets+1] = obj
		end
	end
	
	self.TurretRange = GetGame2().Map.Name == 'TwistedTreeline' and 775 + myHero.boundingRadius or 850 + myHero.boundingRadius
	self.Enemies = {}
	for i=1, heroManager.iCount do
		local h = heroManager:getHero(i)
		if h.team == TEAM_ENEMY then
			self.Enemies[#self.Enemies+1] = h	
		end
	end
	self:CreateMenu()
	AddDrawCallback(function() self:Draw() end)
	-- print(GetGameVersion())
	for i=1, heroManager.iCount do
		local h = heroManager:getHero(i)
		if h.team == TEAM_ALLY and not h.isMe and h.charName == 'Thresh' then
			self.Packets = GetGameVersion():find('6.21.162.906') and {
				['Header'] = 0x0108,
				['vTable'] = 0xF2C744,
				['bytes'] = {[0x00] = 0x1A, [0x01] = 0x8B, [0x02] = 0xB5, [0x03] = 0xCE, [0x04] = 0x94, [0x05] = 0x24, [0x06] = 0xDD, [0x07] = 0x23, [0x08] = 0x34, [0x09] = 0x36, [0x0A] = 0xDC, [0x0B] = 0x0E, [0x0C] = 0xF4, [0x0D] = 0xB4, [0x0E] = 0x2C, [0x0F] = 0x8E, [0x10] = 0x62, [0x11] = 0xC3, [0x12] = 0x4B, [0x13] = 0x8F, [0x14] = 0xE8, [0x15] = 0xBB, [0x16] = 0x16, [0x17] = 0xF0, [0x18] = 0xB1, [0x19] = 0x20, [0x1A] = 0xDA, [0x1B] = 0x71, [0x1C] = 0x8C, [0x1D] = 0xEB, [0x1E] = 0x31, [0x1F] = 0x02, [0x20] = 0x7D, [0x21] = 0x76, [0x22] = 0xEA, [0x23] = 0xA2, [0x24] = 0xB8, [0x25] = 0xFB, [0x26] = 0x89, [0x27] = 0xFF, [0x28] = 0x51, [0x29] = 0x43, [0x2A] = 0x3B, [0x2B] = 0xC9, [0x2C] = 0x40, [0x2D] = 0x7A, [0x2E] = 0x0A, [0x2F] = 0xF8, [0x30] = 0x25, [0x31] = 0x15, [0x32] = 0x90, [0x33] = 0x1B, [0x34] = 0x2D, [0x35] = 0x0F, [0x36] = 0x87, [0x37] = 0xB3, [0x38] = 0x64, [0x39] = 0x12, [0x3A] = 0x06, [0x3B] = 0xA8, [0x3C] = 0x7E, [0x3D] = 0x38, [0x3E] = 0xBF, [0x3F] = 0x7B, [0x40] = 0xED, [0x41] = 0xD3, [0x42] = 0x81, [0x43] = 0x13, [0x44] = 0x32, [0x45] = 0x70, [0x46] = 0x75, [0x47] = 0x19, [0x48] = 0xBC, [0x49] = 0xE4, [0x4A] = 0x59, [0x4B] = 0x18, [0x4C] = 0xB7, [0x4D] = 0x9D, [0x4E] = 0xE2, [0x4F] = 0x82, [0x50] = 0x11, [0x51] = 0x68, [0x52] = 0x4E, [0x53] = 0xC7, [0x54] = 0xBA, [0x55] = 0x17, [0x56] = 0x45, [0x57] = 0xD9, [0x58] = 0xC0, [0x59] = 0xE6, [0x5A] = 0x73, [0x5B] = 0x6C, [0x5C] = 0x49, [0x5D] = 0x4F, [0x5E] = 0xAB, [0x5F] = 0x85, [0x60] = 0x3A, [0x61] = 0xF6, [0x62] = 0x69, [0x63] = 0xAC, [0x64] = 0x03, [0x65] = 0x21, [0x66] = 0x4C, [0x67] = 0x1C, [0x68] = 0x05, [0x69] = 0xE9, [0x6A] = 0x7C, [0x6B] = 0x61, [0x6C] = 0x28, [0x6D] = 0x8D, [0x6E] = 0x1D, [0x6F] = 0xBD, [0x70] = 0x2A, [0x71] = 0xCB, [0x72] = 0x08, [0x73] = 0x56, [0x74] = 0x39, [0x75] = 0xD4, [0x76] = 0x6A, [0x77] = 0xEC, [0x78] = 0xD0, [0x79] = 0x9E, [0x7A] = 0xD5, [0x7B] = 0xDE, [0x7C] = 0x9C, [0x7D] = 0xA6, [0x7E] = 0x63, [0x7F] = 0xFE, [0x80] = 0x07, [0x81] = 0xE7, [0x82] = 0x8A, [0x83] = 0x60, [0x84] = 0x3D, [0x85] = 0x52, [0x86] = 0x77, [0x87] = 0xAD, [0x88] = 0x65, [0x89] = 0xFD, [0x8A] = 0x1F, [0x8B] = 0x30, [0x8C] = 0xCD, [0x8D] = 0x44, [0x8E] = 0x6F, [0x8F] = 0xEF, [0x90] = 0x26, [0x91] = 0xC2, [0x92] = 0xF9, [0x93] = 0xEE, [0x94] = 0x78, [0x95] = 0x7F, [0x96] = 0xB0, [0x97] = 0x84, [0x98] = 0xC5, [0x99] = 0x72, [0x9A] = 0xBE, [0x9B] = 0x5F, [0x9C] = 0x79, [0x9D] = 0xA9, [0x9E] = 0x0C, [0x9F] = 0x67, [0xA0] = 0x29, [0xA1] = 0x6B, [0xA2] = 0x42, [0xA3] = 0x88, [0xA4] = 0x33, [0xA5] = 0xC4, [0xA6] = 0x86, [0xA7] = 0x93, [0xA8] = 0xB6, [0xA9] = 0x6D, [0xAA] = 0xC6, [0xAB] = 0xAF, [0xAC] = 0x22, [0xAD] = 0xA3, [0xAE] = 0x04, [0xAF] = 0x5B, [0xB0] = 0x53, [0xB1] = 0xE1, [0xB2] = 0x14, [0xB3] = 0x27, [0xB4] = 0x3E, [0xB5] = 0x91, [0xB6] = 0xFA, [0xB7] = 0x2F, [0xB8] = 0x5A, [0xB9] = 0xC8, [0xBA] = 0x99, [0xBB] = 0xFC, [0xBC] = 0x2B, [0xBD] = 0x46, [0xBE] = 0x3F, [0xBF] = 0xB2, [0xC0] = 0x55, [0xC1] = 0x00, [0xC2] = 0xCC, [0xC3] = 0x3C, [0xC4] = 0x98, [0xC5] = 0xF7, [0xC6] = 0xCA, [0xC7] = 0xCF, [0xC8] = 0x47, [0xC9] = 0xAE, [0xCA] = 0x57, [0xCB] = 0xA1, [0xCC] = 0x35, [0xCD] = 0x83, [0xCE] = 0xF3, [0xCF] = 0xD2, [0xD0] = 0xAA, [0xD1] = 0x92, [0xD2] = 0xD7, [0xD3] = 0x09, [0xD4] = 0x58, [0xD5] = 0x50, [0xD6] = 0x5D, [0xD7] = 0x74, [0xD8] = 0x9B, [0xD9] = 0x97, [0xDA] = 0x66, [0xDB] = 0x0B, [0xDC] = 0x6E, [0xDD] = 0x2E, [0xDE] = 0xA5, [0xDF] = 0x96, [0xE0] = 0x1E, [0xE1] = 0xC1, [0xE2] = 0xD1, [0xE3] = 0xD6, [0xE4] = 0x0D, [0xE5] = 0x9F, [0xE6] = 0xD8, [0xE7] = 0x10, [0xE8] = 0xB9, [0xE9] = 0xDB, [0xEA] = 0xF1, [0xEB] = 0x41, [0xEC] = 0x54, [0xED] = 0x9A, [0xEE] = 0xE5, [0xEF] = 0xF2, [0xF0] = 0xDF, [0xF1] = 0xA4, [0xF2] = 0xA7, [0xF3] = 0x5E, [0xF4] = 0x5C, [0xF5] = 0x48, [0xF6] = 0x01, [0xF7] = 0x4D, [0xF8] = 0x4A, [0xF9] = 0xE3, [0xFA] = 0x80, [0xFB] = 0xE0, [0xFC] = 0x37, [0xFD] = 0xA0, [0xFE] = 0x95, [0xFF] = 0xF5, },
			} or GetGameVersion():find('6.20.160.7699') and {
				['Header'] = 0x0108,
				['vTable'] = 0xE3A59C,
				['bytes'] = {[0x00] = 0x1A, [0x01] = 0x8B, [0x02] = 0xB5, [0x03] = 0xCE, [0x04] = 0x94, [0x05] = 0x24, [0x06] = 0xDD, [0x07] = 0x23, [0x08] = 0x34, [0x09] = 0x36, [0x0A] = 0xDC, [0x0B] = 0x0E, [0x0C] = 0xF4, [0x0D] = 0xB4, [0x0E] = 0x2C, [0x0F] = 0x8E, [0x10] = 0x62, [0x11] = 0xC3, [0x12] = 0x4B, [0x13] = 0x8F, [0x14] = 0xE8, [0x15] = 0xBB, [0x16] = 0x16, [0x17] = 0xF0, [0x18] = 0xB1, [0x19] = 0x20, [0x1A] = 0xDA, [0x1B] = 0x71, [0x1C] = 0x8C, [0x1D] = 0xEB, [0x1E] = 0x31, [0x1F] = 0x02, [0x20] = 0x7D, [0x21] = 0x76, [0x22] = 0xEA, [0x23] = 0xA2, [0x24] = 0xB8, [0x25] = 0xFB, [0x26] = 0x89, [0x27] = 0xFF, [0x28] = 0x51, [0x29] = 0x43, [0x2A] = 0x3B, [0x2B] = 0xC9, [0x2C] = 0x40, [0x2D] = 0x7A, [0x2E] = 0x0A, [0x2F] = 0xF8, [0x30] = 0x25, [0x31] = 0x15, [0x32] = 0x90, [0x33] = 0x1B, [0x34] = 0x2D, [0x35] = 0x0F, [0x36] = 0x87, [0x37] = 0xB3, [0x38] = 0x64, [0x39] = 0x12, [0x3A] = 0x06, [0x3B] = 0xA8, [0x3C] = 0x7E, [0x3D] = 0x38, [0x3E] = 0xBF, [0x3F] = 0x7B, [0x40] = 0xED, [0x41] = 0xD3, [0x42] = 0x81, [0x43] = 0x13, [0x44] = 0x32, [0x45] = 0x70, [0x46] = 0x75, [0x47] = 0x19, [0x48] = 0xBC, [0x49] = 0xE4, [0x4A] = 0x59, [0x4B] = 0x18, [0x4C] = 0xB7, [0x4D] = 0x9D, [0x4E] = 0xE2, [0x4F] = 0x82, [0x50] = 0x11, [0x51] = 0x68, [0x52] = 0x4E, [0x53] = 0xC7, [0x54] = 0xBA, [0x55] = 0x17, [0x56] = 0x45, [0x57] = 0xD9, [0x58] = 0xC0, [0x59] = 0xE6, [0x5A] = 0x73, [0x5B] = 0x6C, [0x5C] = 0x49, [0x5D] = 0x4F, [0x5E] = 0xAB, [0x5F] = 0x85, [0x60] = 0x3A, [0x61] = 0xF6, [0x62] = 0x69, [0x63] = 0xAC, [0x64] = 0x03, [0x65] = 0x21, [0x66] = 0x4C, [0x67] = 0x1C, [0x68] = 0x05, [0x69] = 0xE9, [0x6A] = 0x7C, [0x6B] = 0x61, [0x6C] = 0x28, [0x6D] = 0x8D, [0x6E] = 0x1D, [0x6F] = 0xBD, [0x70] = 0x2A, [0x71] = 0xCB, [0x72] = 0x08, [0x73] = 0x56, [0x74] = 0x39, [0x75] = 0xD4, [0x76] = 0x6A, [0x77] = 0xEC, [0x78] = 0xD0, [0x79] = 0x9E, [0x7A] = 0xD5, [0x7B] = 0xDE, [0x7C] = 0x9C, [0x7D] = 0xA6, [0x7E] = 0x63, [0x7F] = 0xFE, [0x80] = 0x07, [0x81] = 0xE7, [0x82] = 0x8A, [0x83] = 0x60, [0x84] = 0x3D, [0x85] = 0x52, [0x86] = 0x77, [0x87] = 0xAD, [0x88] = 0x65, [0x89] = 0xFD, [0x8A] = 0x1F, [0x8B] = 0x30, [0x8C] = 0xCD, [0x8D] = 0x44, [0x8E] = 0x6F, [0x8F] = 0xEF, [0x90] = 0x26, [0x91] = 0xC2, [0x92] = 0xF9, [0x93] = 0xEE, [0x94] = 0x78, [0x95] = 0x7F, [0x96] = 0xB0, [0x97] = 0x84, [0x98] = 0xC5, [0x99] = 0x72, [0x9A] = 0xBE, [0x9B] = 0x5F, [0x9C] = 0x79, [0x9D] = 0xA9, [0x9E] = 0x0C, [0x9F] = 0x67, [0xA0] = 0x29, [0xA1] = 0x6B, [0xA2] = 0x42, [0xA3] = 0x88, [0xA4] = 0x33, [0xA5] = 0xC4, [0xA6] = 0x86, [0xA7] = 0x93, [0xA8] = 0xB6, [0xA9] = 0x6D, [0xAA] = 0xC6, [0xAB] = 0xAF, [0xAC] = 0x22, [0xAD] = 0xA3, [0xAE] = 0x04, [0xAF] = 0x5B, [0xB0] = 0x53, [0xB1] = 0xE1, [0xB2] = 0x14, [0xB3] = 0x27, [0xB4] = 0x3E, [0xB5] = 0x91, [0xB6] = 0xFA, [0xB7] = 0x2F, [0xB8] = 0x5A, [0xB9] = 0xC8, [0xBA] = 0x99, [0xBB] = 0xFC, [0xBC] = 0x2B, [0xBD] = 0x46, [0xBE] = 0x3F, [0xBF] = 0xB2, [0xC0] = 0x55, [0xC1] = 0x00, [0xC2] = 0xCC, [0xC3] = 0x3C, [0xC4] = 0x98, [0xC5] = 0xF7, [0xC6] = 0xCA, [0xC7] = 0xCF, [0xC8] = 0x47, [0xC9] = 0xAE, [0xCA] = 0x57, [0xCB] = 0xA1, [0xCC] = 0x35, [0xCD] = 0x83, [0xCE] = 0xF3, [0xCF] = 0xD2, [0xD0] = 0xAA, [0xD1] = 0x92, [0xD2] = 0xD7, [0xD3] = 0x09, [0xD4] = 0x58, [0xD5] = 0x50, [0xD6] = 0x5D, [0xD7] = 0x74, [0xD8] = 0x9B, [0xD9] = 0x97, [0xDA] = 0x66, [0xDB] = 0x0B, [0xDC] = 0x6E, [0xDD] = 0x2E, [0xDE] = 0xA5, [0xDF] = 0x96, [0xE0] = 0x1E, [0xE1] = 0xC1, [0xE2] = 0xD1, [0xE3] = 0xD6, [0xE4] = 0x0D, [0xE5] = 0x9F, [0xE6] = 0xD8, [0xE7] = 0x10, [0xE8] = 0xB9, [0xE9] = 0xDB, [0xEA] = 0xF1, [0xEB] = 0x41, [0xEC] = 0x54, [0xED] = 0x9A, [0xEE] = 0xE5, [0xEF] = 0xF2, [0xF0] = 0xDF, [0xF1] = 0xA4, [0xF2] = 0xA7, [0xF3] = 0x5E, [0xF4] = 0x5C, [0xF5] = 0x48, [0xF6] = 0x01, [0xF7] = 0x4D, [0xF8] = 0x4A, [0xF9] = 0xE3, [0xFA] = 0x80, [0xFB] = 0xE0, [0xFC] = 0x37, [0xFD] = 0xA0, [0xFE] = 0x95, [0xFF] = 0xF5, },
			}
			if not self.Packets then
				Print('Thresh Lantern packets are outdated!!', true)
				return
			end
			Print('Ally Thresh detected, AutoLantern loaded')
			self.Menu:addParam('LanternKey', 'Thresh Lantern Key', SCRIPT_PARAM_ONKEYDOWN, false, 32)
			self.Menu:addParam('LanternHealth', 'Lantern if Health Less than (%)', SCRIPT_PARAM_SLICE, 25, 0, 100)
			self.Menu:addParam('LanternDelay', 'Lantern Humanizer Delay (ms)', SCRIPT_PARAM_SLICE, 250, 0, 1000)
			self.ReversedBytes = {}
			for i=0, 255 do self.ReversedBytes[self.Packets.bytes[i]] = i end
			self.LanternPacket = CLoLPacket(self.Packets.Header)
			self.LanternPacket.vTable = self.Packets.vTable
			self.LanternPacket:EncodeF(myHero.networkID)
			self.LanternPacket:Encode4(0x00000000)
			self.EncodePacket = CLoLPacket(0x0001)
			AddCreateObjCallback(function(o)
				if o.valid and o.team == TEAM_ALLY and o.name == 'ThreshLantern' then
					self.Lantern = o
					self.LanternDelay = clock() + (self.Menu.LanternDelay / 1000)
				end
			end)
			AddTickCallback(function()
				if self.Lantern and self.Lantern.valid and GetDistanceSqr(self.Lantern) < 105625 and self.LanternDelay < clock() then
					if self.Menu.LanternKey or (myHero.health * 100) / myHero.maxHealth <= self.Menu.LanternHealth then
						self.EncodePacket.pos=2
						self.EncodePacket:EncodeF(self.Lantern.networkID)
						self.EncodePacket.pos=2
						for i=1, 4 do self.LanternPacket:Replace1(self.ReversedBytes[self.EncodePacket:Decode1()], 5+i) end
						SendPacket(self.LanternPacket)
					end
				end
			end)
			break
		end
	end
end

function OTHER:CreateMenu()
	MainMenu:addSubMenu('Other Stuff', 'Other')
	self.Menu = MainMenu.Other
	self.Menu:addParam('path', 'Draw Enemy Paths', SCRIPT_PARAM_ONOFF, true)
	self.Menu:addParam('type', 'Path Draw Type', SCRIPT_PARAM_LIST, 1, { 'Lines', 'End Position', })
	self.Menu:addParam('turret', 'Draw Turret Ranges', SCRIPT_PARAM_ONOFF, true)
	self.Menu:addParam('AllyTurret', 'Draw Ally Turret Ranges', SCRIPT_PARAM_ONOFF, false)
end

function OTHER:Draw()
	if self.Menu.turret then
		for i, turret in ipairs(self.Turrets) do
			if turret and turret.valid and not turret.dead then
				local d = GetDistance(turret)
				if d < self.TurretRange+500 then
					local t = d-self.TurretRange
					if turret.team == TEAM_ENEMY then
						DrawCircle3D(turret.x,turret.y,turret.z,self.TurretRange,1, ARGB(t>0 and 255 * ((500-t) / 500) or 255, 255, 0, 0))
					elseif self.Menu.AllyTurret then
						local p = t>0 and ((500-t) / 500) or 1
						DrawCircle3D(turret.x,turret.y,turret.z,self.TurretRange,1, ARGB(t>0 and 255 * ((500-t) / 500) or 255, 255, 120, 120))
					end
				end
			else
				table.remove(self.Turrets, i)
			end
		end
	end	
	if self.Menu.path then
		for _, e in ipairs(self.Enemies) do
			if e and e.valid and not e.dead and e.visible and e.hasMovePath then
				local points = {}
				local eC = WorldToScreen(D3DXVECTOR3(e.x, 50, e.z))
				points[1] = D3DXVECTOR2(eC.x, eC.y)
				local pathLength = 0
				for i=e.pathIndex, e.pathCount do
					local p1 = e:GetPath(i)
					local p2 = e:GetPath(i-1)
					if p1 then
						local c = WorldToScreen(D3DXVECTOR3(p1.x, 50, p1.z))
						points[#points + 1] = D3DXVECTOR2(c.x, c.y)
						if p2 then
							if (i==e.pathIndex) then
								pathLength = pathLength + GetDistanceSqr(p1, e.pos)
							else
								pathLength = pathLength + GetDistanceSqr(p1, p2)
							end
						end
					end
				end			
				if self.Menu.type == 1 then
					local draw = false
					for i, point in ipairs(points) do
						if point.x > 0 and point.x < WINDOW_W and point.y > 0 and point.y < WINDOW_H then
							draw = true
							break
						end
					end
					if draw then
						DrawLines2(points, 1, COLOR_RED)
						local x, y = points[#points].x, points[#points].y
						DrawText(('%.2f'):format(sqrt(pathLength)/(e.ms))..'\n'..e.charName,12,x,y,COLOR_WHITE)
					end
				else
					local x, y = points[#points].x, points[#points].y
					if x > 0 and x < WINDOW_W and y > 0 and y < WINDOW_H then
						DrawText(('%.2f'):format(sqrt(pathLength)/(e.ms))..'\n'..e.charName,12,x,y,COLOR_WHITE)
					end
				end
			end
		end
	end
end

class 'TRINKET'

function TRINKET:__init()
	if GetGame().map.shortName ~= 'summonerRift' then return end
	self.trinketID = {
		['TrinketTotemLvl1'] = 3340,
		['TrinketSweeperLvl1'] = 3341,
		['TrinketOrbLvl3'] = 3363,
		['TrinketSweeperLvl3'] = 3364,
	}
	self.Packet = GetGameVersion():sub(1, 4) == '6.20' and {
		['Header'] = 0x0171, ['pos'] = 13, ['ssID'] = 0x12121A22,
	} or GetGameVersion():sub(1,4) == '6.21' and {
		['Header'] = 0x0171, ['pos'] = 13, ['ssID'] = 0x12121A22,
	}
	if not self.Packet then 
		Print('Trinket Utiltity packet is outdated!!', true)
		return
	end
	self.Menu = self:Menu()
	AddRecvPacketCallback2(function(p) self:RecvPacket(p) end)
end

function TRINKET:Menu()
	MainMenu:addSubMenu('Trinket Helper', 'Trinket')
	local Menu = MainMenu.Trinket
	Menu:addParam('Sweeper', 'Enable Sweeper Purchase', SCRIPT_PARAM_ONOFF, true)
	Menu:addParam('Timer', 'Buy Sweeper after x Minutes', SCRIPT_PARAM_SLICE, 10, 1, 60)
	Menu:addParam('Upgrade', 'Upgrade Trinket after Lvl 9', SCRIPT_PARAM_ONOFF, true)
	Menu:addParam('Sightstone', 'Buy Sweeper on Sightstone', SCRIPT_PARAM_ONOFF, true)
	return Menu
end

function TRINKET:RecvPacket(p)
	if p.header == self.Packet.Header then
		if p:DecodeF() == myHero.networkID then
			p.pos=self.Packet.pos
			local isSightStone = p:Decode4() == self.Packet.ssID
			local currentTrinket = myHero:GetSpellData(ITEM_7)
			if not currentTrinket then return end
			local gameTime = GetInGameTimer()/60
			if self.Menu.Sweeper and self.trinketID[currentTrinket.name] == 3340 and gameTime >= self.Menu.Timer then
				BuyItem(3341)
				return
			end
			if self.Menu.Sightstone and isSightStone then
				if self.trinketID[currentTrinket.name] == 3340 then
					BuyItem(3341)
					return
				end
			end
			if myHero.level >= 9 and self.Menu.Upgrade then
				if currentTrinket.name == 'TrinketTotemLvl1' then
					BuyItem(3363)
				elseif currentTrinket.name == 'TrinketSweeperLvl1' then
					BuyItem(3364)
				end
			end
		end
	end
end

class 'MAGWARDS'

function MAGWARDS:__init()
	if GetGame().map.shortName ~= 'summonerRift' then return end	
	self:CreateMenu()
	self.Positions = {
		{['x']=6550, ['y']=49, ['z']=4789},
		{['x']=6609, ['y']=51, ['z']=3081},
		{['x']=5476, ['y']=52, ['z']=3535},
		{['x']=7890, ['y']=53, ['z']=3455},
		{['x']=8591, ['y']=53, ['z']=4877},
		{['x']=10446, ['y']=52, ['z']=3142},
		{['x']=11720, ['y']=-70, ['z']=4074},
		{['x']=10111, ['y']=-71, ['z']=4734},
		{['x']=10547, ['y']=-62, ['z']=5100},
		{['x']=9315, ['y']=-71, ['z']=5725},
		{['x']=10016, ['y']=49, ['z']=6608},
		{['x']=10079, ['y']=52, ['z']=7754},
		{['x']=11615, ['y']=52, ['z']=7057},
		{['x']=4692, ['y']=51, ['z']=7210},
		{['x']=3248, ['y']=52, ['z']=7843},
		{['x']=2875, ['y']=52, ['z']=8380},
		{['x']=11934, ['y']=52, ['z']=6572},
		{['x']=4419, ['y']=57, ['z']=11763},
		{['x']=6266, ['y']=55, ['z']=10118},
		{['x']=7041, ['y']=55, ['z']=11438},
		{['x']=7794, ['y']=57, ['z']=11880},
		{['x']=8281, ['y']=57, ['z']=11813},
		{['x']=9406, ['y']=53, ['z']=11418},
		{['x']=9136, ['y']=55, ['z']=11335},
		{['x']=8120, ['y']=53, ['z']=8106},
		{['x']=6576, ['y']=52, ['z']=6714},
		{['x']=5329, ['y']=51, ['z']=5593},
		{['x']=5763, ['y']=51, ['z']=1264},
		{['x']=4792, ['y']=-71, ['z']=10233},
		{['x']=4279, ['y']=-69, ['z']=9795},
		{['x']=8222, ['y']=50, ['z']=10218},
		{['x']=4835, ['y']=33, ['z']=8363},	
		{['x']=5364, ['y']=-71, ['z']=9139},	
		{['x']=3148, ['y']=-66, ['z']=10820},	
	}
	self.Jumps = {
		[1] = {
			['cast'] = {['x']=2031, ['y']=53, ['z']=10165},
			['pos'] = {['x']=1774, ['y']=52, ['z']=10756},
		},
		[2] = {
			['cast'] = {['x']=4006, ['y']=41, ['z']=11907},
			['pos'] = {['x']=3424, ['y']=-62, ['z']=11767},
		},
		[3] = {
			['cast'] = {['x']=10699, ['y']=48, ['z']=3036},
			['pos'] = {['x']=11252, ['y']=-68, ['z']=3248},
		},
		[4] = {
			['cast'] = {['x']=4627, ['y']=50, ['z']=11393},
			['pos'] = {['x']=4824, ['y']=-71, ['z']=10906},
		},
		[5] = {
			['cast'] = {['x']=8148, ['y']=52, ['z']=3426},
			['pos'] = {['x']=8372, ['y']=52, ['z']=2908},
		},
		[6] = {
			['cast'] = {['x']=8425, ['y']=51, ['z']=4598},
			['pos'] = {['x']=8008, ['y']=54, ['z']=4270},
		},
		[7] = {
			['cast'] = {['x']=5184, ['y']=51, ['z']=6936},
			['pos'] = {['x']=5500, ['y']=52, ['z']=6424},
		},
		[8] = {
			['cast'] = {['x']=4980, ['y']=51, ['z']=7168},
			['pos'] = {['x']=5392, ['y']=52, ['z']=7496},
		},
		[9] = {
			['cast'] = {['x']=6436, ['y']=52, ['z']=10387},
			['pos'] = {['x']=6874, ['y']=56, ['z']=10656},
		},
		[10] = {
			['cast'] = {['x']=9712, ['y']=52, ['z']=7756},
			['pos'] = {['x']=9186, ['y']=53, ['z']=7560},
		},
		[11] = {
			['cast'] = {['x']=12119, ['y']=-71, ['z']=4189},
			['pos'] = {['x']=12322, ['y']=52, ['z']=4558},
		},
		[12] = {
			['cast'] = {['x']=12777, ['y']=52, ['z']=4740},
			['pos'] = {['x']=13069, ['y']=52, ['z']=4237},
		},
		[13] = {
			['cast'] = {['x']=6690, ['y']=54, ['z']=11495},
			['pos'] = {['x']=6524, ['y']=57, ['z']=12006},
		},
		[14] = {
			['cast'] = {['x']=9543, ['y']=74, ['z']=8015},
			['pos'] = {['x']=9272, ['y']=52, ['z']=8506},
		},
		[15] = {
			['cast'] = {['x']=10288, ['y']=74, ['z']=3368},
			['pos'] = {['x']=10072, ['y']=52, ['z']=3908},
		},
	}
	self.Wards = {
		['sightward'] = true, 
		['VisionWard'] = true,
		['ItemGhostWard'] = true, 
		['TrinketTotemLvl2'] =  true,
		['TrinketTotemLvl1'] = true, 
		['TrinketTotemLvl3'] = true, 
		['TrinketTotemLvl3b'] = true, 
		['TrinketOrbLvl3'] = true,
	}
	AddCastSpellCallback(function(...) self:CastSpell(...) end)	
	AddMsgCallback(function(m,k) self:WndMsg(m,k) end)
	AddDrawCallback(function() self:Draw() end)
end

function MAGWARDS:CreateMenu()
	MainMenu:addSubMenu('Warding Helper (beta)', 'MagWards')
	self.Menu = MainMenu.MagWards
	self.Menu:addParam('info', 'Match these to ingame keybindings.', SCRIPT_PARAM_INFO, '')
	self.Menu:addParam('Item1', 'Item Slot 1', SCRIPT_PARAM_ONKEYDOWN, false, ('1'):byte())
	self.Menu:addParam('Item2', 'Item Slot 2', SCRIPT_PARAM_ONKEYDOWN, false, ('2'):byte())
	self.Menu:addParam('Item3', 'Item Slot 3', SCRIPT_PARAM_ONKEYDOWN, false, ('3'):byte())
	self.Menu:addParam('Item4', 'Item Slot 4', SCRIPT_PARAM_ONKEYDOWN, false, ('5'):byte())
	self.Menu:addParam('Item5', 'Item Slot 5', SCRIPT_PARAM_ONKEYDOWN, false, ('6'):byte())
	self.Menu:addParam('Item6', 'Item Slot 6', SCRIPT_PARAM_ONKEYDOWN, false, ('7'):byte())
	self.Menu:addParam('Item7', 'Trinket Slot', SCRIPT_PARAM_ONKEYDOWN, false, ('4'):byte())
	self.Menu:addParam('info', '', SCRIPT_PARAM_INFO, '')
	self.Menu:addParam('QuickCast', 'QuickCast', SCRIPT_PARAM_ONOFF, false)	
end

function MAGWARDS:Draw()
	if self.DrawSpots then
		for _, p in ipairs(self.Positions) do
			local c = WorldToScreen(D3DXVECTOR3(p.x,p.y,p.z))
			if c.x > -100 and c.x < WINDOW_W+100 and c.y > -100 and c.y < WINDOW_H+100 then
				local color = GetDistanceSqr(p, mousePos) < 6400 and RGB(0,0,255) or RGB(255,255,255)
				-- for i=1, 5 do DrawCircle(p.x, p.y, p.z, 75, color) end
				DrawCircle3D(p.x,p.y,p.z,75,2,color)
			end
		end
		for _, p in ipairs(self.Jumps) do
			local c = WorldToScreen(D3DXVECTOR3(p.pos.x,p.pos.y,p.pos.z))
			if c.x > -100 and c.x < WINDOW_W+100 and c.y > -100 and c.y < WINDOW_H+100 then
				local isHovered = GetDistanceSqr(mousePos, p.pos) < 6400 or GetDistanceSqr(mousePos, p.cast) < 6400
				local color = isHovered and RGB(0,0,255) or RGB(255,125,0)			
				-- for i=1, 5 do
					-- DrawCircle(p.pos.x, p.pos.y, p.pos.z, 75, color)
					-- DrawCircle(p.cast.x, p.cast.y, p.cast.z, 50, color)
				-- end
				-- DrawText3D(_..'',p.pos.x,p.pos.y,p.pos.z,20,color,true)
				DrawCircle3D(p.pos.x,p.pos.y,p.pos.z,75,2,color)
				DrawCircle3D(p.cast.x,p.cast.y,p.cast.z,50,2,color)
				local x, z = p.pos.x - p.cast.x, p.pos.z - p.cast.z
				local nLength  = sqrt(x * x + z * z)			
				DrawLine3D(
					p.pos.x + ((x / nLength) * -70), 
					p.pos.y, 
					p.pos.z + ((z / nLength) * -70),
					p.cast.x + ((x / nLength) * 50), 
					p.cast.y, 
					p.cast.z + ((z / nLength) * 50),
					2,
					isHovered and ARGB(100,0,0,255) or ARGB(100,175,225,0)
				)
			end
		end
	end
end

function MAGWARDS:WndMsg(m,k)
	if m==KEY_DOWN then
		for _, param in ipairs(self.Menu._param) do
			if param.pType == SCRIPT_PARAM_ONKEYDOWN and param.key == k then
				local slot = _G['ITEM_'..param.var:sub(#param.var, #param.var)]
				if self.Wards[myHero:GetSpellData(slot).name] then
					self.DrawSpots = slot
				end
				return
			end
		end
	elseif m==KEY_UP and self.DrawSpots and self.Menu.QuickCast then
		DelayAction(function() self.DrawSpots = nil end, 0.25)
	elseif (m==WM_LBUTTONDOWN or m==WM_RBUTTONDOWN) and not self.Menu.QuickCast then
		DelayAction(function() self.DrawSpots = nil end, 0.25)		
	end
end

function MAGWARDS:CastSpell(iSlot,startPos,endPos,target)
	if self.DrawSpots == iSlot then
		for _, p in ipairs(self.Positions) do
			if GetDistanceSqr(mousePos, p) < 6400 then
				endPos.x = p.x
				endPos.z = p.z
			end
		end
		for _, p in ipairs(self.Jumps) do
			local isHovered = GetDistanceSqr(mousePos, p.pos) < 6400 or GetDistanceSqr(mousePos, p.cast) < 6400
			if isHovered then
				endPos.x = p.cast.x
				endPos.z = p.cast.z
			end
		end
	end
end

class "SxWebResulter"

function SxWebResulter:__init(Host, Path, cbComplete, cbError)
    self.Host = Host
    self.Path = Path
    self.Callback = cbComplete
	self.Error = cbError
    self.LuaSocket = require("socket")

    self.Socket = self.LuaSocket.connect(Host, 80)
    self.Socket:send("GET "..self.Path.." HTTP/1.0\r\nHost: "..Host.."\r\n\r\n")
    self.Socket:settimeout(0, 'b')
    self.Socket:settimeout(99999999, 't')

    self.LastPrint = ""
    self.File = ""
    AddDrawCallback(function() self:GetResult() end)
end

function SxWebResulter:GetResult()
    if self.Status == 'closed' then return end
    self.Receive, self.Status, self.Snipped = self.Socket:receive(1024)
    if self.Receive then
        if self.LastPrint ~= self.Receive then
            self.LastPrint = self.Receive
            self.File = self.File .. self.Receive
        end
    end

    if self.Snipped ~= "" and self.Snipped then
        self.File = self.File .. self.Snipped
    end
    if self.Status == 'closed' then
        local HeaderEnd, ContentStart = self.File:find('\r\n\r\n')
        if HeaderEnd and ContentStart then
            self.Callback(self.File:sub(ContentStart + 1))
        else
            self.Error()
        end
    end
end

