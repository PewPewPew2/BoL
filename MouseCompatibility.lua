local o_AddMsgCallback = AddMsgCallback
local callbacks, lastTick = {}, {}
local namingKey, currentName, lastBlink, drawBlink = false, '', 0, false
_G.AddMsgCallback = function(f)
	table.insert(callbacks, f)
	o_AddMsgCallback(f)
end

local mc_Content = {}
function mc_Save()
	local file = io.open(LIB_PATH..'\\Saves\\mouseCompatibility.save', 'w+')
	local str = JSON:encode(mc_Content)
	file:write(str)
	file:close()
end
function mc_Load()
	local file = io.open(LIB_PATH..'\\Saves\\mouseCompatibility.save', 'r')
	if file then
		local content = file:read('*all')
		mc_Content = JSON:decode(content)
	else
		mc_Content = {
			keysAdded = {},
		}
	end
end
function keyExists(key)
	for _, v in pairs(mc_Content.keysAdded) do
		if v.key == key then return true end
	end
	return false
end

local o_txtKey = scriptConfig._txtKey
_G.scriptConfig._txtKey = function(self, key)
	for _, v in pairs(mc_Content.keysAdded) do
		if key == v.key then
			return v.name
		end
	end
	
	return o_txtKey(self, key)
end

AddLoadCallback(function()
	local b='ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
	local sText = 'Scanning'
	local blocks = {[1]=true, [2]=true, [8]=true, [16]=true, [18]=true, [32]=true, [160]=true, [162]=true, [164]=true}
	mc_Load()
	local Menu = scriptConfig('Mouse Compatibility', 'mouseCompatibility')
	Menu:addParam('isSetup', 'Setup Complete:', SCRIPT_PARAM_INFO, mc_Content.setupCompelte and 'YES' or 'NO')
	Menu:addParam('space', '', SCRIPT_PARAM_INFO, '')
	Menu:addParam('reset', 'Reset Setup', SCRIPT_PARAM_ONOFF, false)
	Menu:addParam('space', '', SCRIPT_PARAM_INFO, '')
	Menu:addParam('Added', 'Keys Added', SCRIPT_PARAM_INFO, '')
	for _, v in pairs(mc_Content.keysAdded) do			
		Menu:addParam('newKey'..v.key, v.name, SCRIPT_PARAM_INFO, tostring(v.key))
	end
	Menu.reset = false
	
	AddDrawCallback(function()
		if Menu.isSetup == 'NO' then
			DrawLine(WINDOW_W*.5-200,WINDOW_H*.5-100,WINDOW_W*.5+200,WINDOW_H*.5-100,125,0x88111111)
			DrawLine(WINDOW_W*.5-205,WINDOW_H*.5-100,WINDOW_W*.5+205,WINDOW_H*.5-100,135,0x88111111)
			
			local t = 'Mouse Compatibility Setup'
			local ta = GetTextArea(t, 22)
			DrawText(t, 22, WINDOW_W*.5-ta.x*.5,WINDOW_H*.5-155,0xFFAAAAAA)
			DrawLine(WINDOW_W*.5-ta.x*.5,WINDOW_H*.5-155+ta.y,WINDOW_W*.5+ta.x*.5,WINDOW_H*.5-155+ta.y,2,0xFFAAAAAA)
			
			local t = 'Hold Mouse Key Down: '
			sText = 'Scanning'
			for i=1, 900 do
				if IsKeyDown(i) and b:find(string.char(i))==nil and not blocks[i] and not keyExists(i) then
					sText = 'Key ID - '..i
					break
				end
			end
			
			DrawText(t..sText, 18, WINDOW_W*.5-125,WINDOW_H*.5-108,0xFFAAAAAA)
			if sText~='Scanning' then DrawText('Press Spacebar to Add Key', 18, WINDOW_W*.5-90,WINDOW_H*.5-90,0xFF11AA11) end
						
			local t = 'Save and Close'
			local ta = GetTextArea(t, 16)
			DrawLine(WINDOW_W*.5-ta.x*.5-2,WINDOW_H*.5-65+ta.y*.5,WINDOW_W*.5+ta.x*.5+2,WINDOW_H*.5-65+ta.y*.5,ta.y+4,0x99555555)
			DrawText(t, 16, WINDOW_W*.5-ta.x*.5,WINDOW_H*.5-65,0xFFAAAAAA)

			if namingKey then
				DrawLine(WINDOW_W*.5-100,WINDOW_H*.5,WINDOW_W*.5+100,WINDOW_H*.5,40,0x88111111)
				DrawLine(WINDOW_W*.5-105,WINDOW_H*.5,WINDOW_W*.5+105,WINDOW_H*.5,45,0x88111111)
				DrawText('Key Name: '..currentName, 13, WINDOW_W*.5-95,WINDOW_H*.5-5, 0xFFAAAAAA)
				local c = GetTextArea('Key Name: '..currentName, 13)
				if os.clock() > lastBlink then
					drawBlink = not drawBlink
					lastBlink = os.clock() + 0.25
				end
				if drawBlink then
					DrawLine(WINDOW_W*.5-95+c.x, WINDOW_H*.5-15, WINDOW_W*.5-95+c.x, WINDOW_H*.5+17, 2, ARGB(255,255,255,255))
				end	
			end
			
		end
		if Menu.reset then
			Menu.isSetup = 'NO'
			mc_Content.keysAdded = {}
			for i=#Menu._param, 1, -1 do
				if Menu._param[i].var:find('newKey') then
					table.remove(Menu._param, i)
				end
			end
			Menu.reset = false
		end		
	end)
	AddMsgCallback(function(m,k)
		if Menu.isSetup ~= 'NO' then return end
		if m==WM_LBUTTONDOWN then
			local t = 'Save and Close'
			local ta = GetTextArea(t, 16)
			local cp = GetCursorPos()
			if cp.x>WINDOW_W*.5-ta.x*.5-2 and cp.x<WINDOW_W*.5+ta.x*.5+2 and cp.y<WINDOW_H*.5-65+ta.y+2 and cp.y>WINDOW_H*.5-65-ta.y+2 then
				Menu.isSetup = 'YES'
				mc_Content.setupCompelte = true
				mc_Save()
			end			
		end
		if m==KEY_DOWN and k==32 and sText ~= 'Scanning' then
			local key = tonumber(sText:sub(#sText, #sText))
			namingKey = key
			currentName = ''
		end
		if namingKey and m==KEY_UP then
			local numpad = {
				[32]=' ',
				[96]='0',
				[97]='1',
				[98]='2',
				[99]='3',
				[100]='4',
				[101]='5',
				[102]='6',
				[103]='7',
				[104]='8',
				[105]='9',
			}
			if (k>47 and k<90) or numpad[k] then
				currentName = currentName..(numpad[k] or string.char(k))
			elseif k==8 and #currentName > 0 then
				currentName = currentName:sub(1, #currentName-1)				
			end
			
			if k==13 then
				for _, v in pairs(mc_Content.keysAdded) do
					if v.key == namingKey then
						v.name = currentName
					end
				end
				table.insert(mc_Content.keysAdded, {key = namingKey, name = currentName})
				print('Added Key: '..currentName)
				Menu:addParam('newKey'..namingKey, currentName, SCRIPT_PARAM_INFO, tostring(namingKey))
				Menu.reset = false
				namingKey = false
			end
		end
	end)
	AddTickCallback(function()
		for _, v in pairs(mc_Content.keysAdded) do
			if IsKeyDown(v.key) then
				for _, f in ipairs(callbacks) do
					f(256, v.key)
				end
				lastTick[v.key] = true
			elseif lastTick[v.key] then
				for _, f in ipairs(callbacks) do
					f(257, v.key)
				end
				lastTick[v.key] = false
			end
		end
	end)
end)
