if myHero.charName ~= 'Ashe' then return end

function Print(text, isError)
	if isError then
		print('<font color=\'#0099FF\'>[PewAshe] </font> <font color=\'#FF0000\'>'..text..'</font>')	
		return
	end
	print('<font color=\'#0099FF\'>[PewAshe] </font> <font color=\'#FF6600\'>'..text..'</font>')
end

local HP, HP_W, Menu
local Enemies = {}
if FileExist(LIB_PATH..'/HPrediction.lua') then
	Print('Succesfully Loaded.')
	require('HPrediction')
	HP = HPrediction()
	HP_W = HPSkillshot({type = 'DelayLine', delay = 0.25, range = 1100, width = 40, speed = 1600, collisionM = true,})
	HP_R = HPSkillshot({type = 'DelayLine', delay = 0.25, range = 1100, width = 260, speed = 1500, })
else
	Print('HPrediction required, please download manually!', true)
	return
end

Menu = scriptConfig('PewAshe', 'PewAshe')
Menu:addParam('info', 'Uses Pewalks hotkeys.', SCRIPT_PARAM_INFO, '') 
Menu:addParam('space', '', SCRIPT_PARAM_INFO, '') 
Menu:addParam('info', '-Ranger\'s Focus-', SCRIPT_PARAM_INFO, '') 
Menu:addParam('CarryQ', 'Use in Carry Mode', SCRIPT_PARAM_ONOFF, true)
Menu:addParam('ClearQ', 'Use in Skill Lane Clear', SCRIPT_PARAM_ONOFF, true)

Menu:addParam('space', '', SCRIPT_PARAM_INFO, '') 
Menu:addParam('info', '-Volley-', SCRIPT_PARAM_INFO, '') 
Menu:addParam('CarryW', 'Use in Carry Mode', SCRIPT_PARAM_ONOFF, true)

Menu:addParam('space', '', SCRIPT_PARAM_INFO, '') 
Menu:addParam('info', '-Hawkshot-', SCRIPT_PARAM_INFO, '')
Menu:addParam('LoseVision', 'Use on lose vision of killable target.', SCRIPT_PARAM_ONOFF, true)
Menu:addParam('info', '(While in Carry Mode only!)', SCRIPT_PARAM_INFO, '')

Menu:addParam('space', '', SCRIPT_PARAM_INFO, '') 
Menu:addParam('info', '-Enchanted Crystal Arrow-', SCRIPT_PARAM_INFO, '')
Menu:addParam('CastR', 'Cast Key', SCRIPT_PARAM_ONKEYDOWN, false, ('C'):byte())
Menu:addParam('MaxRange', 'Max Target Range', SCRIPT_PARAM_SLICE, 1100, 3000, 500)


AddLoadCallback(function()
	for i=1, heroManager.iCount do
		local h = heroManager:getHero(i)
		if h and h.team~=myHero.team then
			Enemies[#Enemies+1] = h
		end
	end
	DelayAction(function()
		if _Pewalk.AddAfterAttackCallback then 
			_Pewalk.AddAfterAttackCallback(function(target)
				local AM = _Pewalk.GetActiveMode()
				if target.type == 'AIHeroClient' and AM.Carry and Menu.CarryQ then
					if myHero:CanUseSpell(_Q) == READY then
						CastSpell(_Q)
					end
				elseif target.type == 'obj_AI_Minion' and AM.SkillClear and Menu.ClearQ then
					if myHero:CanUseSpell(_Q) == READY then
						CastSpell(_Q)
					end					
				end
			end)
		else
			Print('Pewalk not found!', true)
		end
	end, 2)
end)

AddTickCallback(function()
	for i=1, #Enemies do
		if not Enemies[i].dead and not Enemies[i].visible and not Enemies[i].inFoW then
			Enemies[i].inFoW = os.clock()
		else
			Enemies[i].inFoW = nil
		end
	end

	if _Pewalk.GetActiveMode().Carry and _Pewalk.CanMove() then
		if Menu.CarryW and myHero:CanUseSpell(_W) == READY then
			local t = _Pewalk.GetTarget(1100,true)
			if t then
				local CP, HC = HP:GetPredict(HP_W, t, myHero)
				if CP and HC > 0.1 then
					CastSpell(_W, CP.x, CP.z)
				end
			end
		end
		if myHero:CanUseSpell(_E) == READY then
			for i=1, #Enemies do
				local e = Enemies[i]
				if not e.dead and not e.visible and e.inFoW and os.clock() - e.inFoW < 2 then
					if e.health / e.maxHealth < 0.4 and GetDistanceSqr(e) < 1440000 then
						CastSpell(_E, e.x, e.z)
					end
				end
			end
		end
		if myHero:CanUseSpell(_R) == READY and Menu.CastR then
			local t = _Pewalk.GetTarget(Menu.MaxRange)
			if t then
				local CP, HC = HP:GetPredict(HP_R, t, myHero)
				if CP and HC > 0.1 then
					CastSpell(_R, CP.x, CP.z)
				end			
			end
		end
	end
end)
