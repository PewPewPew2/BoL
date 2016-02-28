--[[
      Require PewPacketLib (Must be downloaded manually)
      
      -Displays cooldown on Thunderlords Decree
      -Displays stack expiration time on enemies
--]]

local Cooldown, Targets, pi2, cos, sin = 0, {}, 2*math.pi, math.cos, math.sin

AddLoadCallback(function()
	print('<font color=\'#FFFFFF\'>Thunderlord\'s Decree</font>')
end)

AddApplyBuffCallback(function(source,unit,buff)
	if unit and unit.valid and unit.isMe and buff.name:lower() == 'masterylordsdecreecooldown' then
		Cooldown = buff.endTime
		Targets = {}
	end
end)

AddDamageCallback(function(source,target,damage)
	if source and target and source.valid and target.valid and Cooldown < GetGameTimer() then
		if source.isMe and target.type == 'AIHeroClient' and target.team ~= myHero.team then
			if Targets[target.networkID] and Targets[target.networkID].time > os.clock() then
				Targets[target.networkID].stacks = Targets[target.networkID].stacks + 1
				Targets[target.networkID].time = os.clock() + 5
			else
				Targets[target.networkID] = {
					stacks = 1,
					time = os.clock() + 5,
					object = target,
				}
			end			
		end
	end
end)

AddDrawCallback(function()
	local x, y =  GetBarPos()
	DrawLine(x,y,x+107,y,10,0xAAAAAAAA)
	local time = Cooldown-GetGameTimer()
	local text = time < 0 and 'READY' or ('%.2f'):format(time)
	if time > 0 then
		DrawLine(x,y,x + (107 * (time * 0.05)),y,10,0xAAAAAAAA)
	end
	DrawText(text,11,x+54-(GetTextArea(text, 11).x * 0.5),y-6,0xFFFFFFFF)
	for k, v in pairs(Targets) do
		if v.time > os.clock() and v.stacks < 3 then
			DrawCircleSector(v.object, v.stacks, v.time-os.clock())
		end
	end
end)

function GetBarPos()
	local barPos = GetUnitHPBarPos(myHero)
	local barOff = GetUnitHPBarOffset(myHero)
	return barPos.x-43, math.floor(barPos.y + (barOff.y * 53) - 19)
end

function DrawCircleSector(pos, stacks, time)
	local c = WorldToScreen(D3DXVECTOR3(pos.x, pos.y or 0, pos.z))
	if c.x < WINDOW_W+200 and c.y < WINDOW_H+200 and c.x > -200 and c.y > -200 then
		local points = {}
		for theta = 0, (pi2+(pi2/64)) * (time / 5), (pi2/64) do
			local tS = WorldToScreen(D3DXVECTOR3(pos.x+(80*cos(theta)), pos.y or 0, pos.z-(80*sin(theta))))
			points[#points + 1] = D3DXVECTOR2(tS.x, tS.y)
		end
		if stacks == 2 then
			DrawLines2(points, 8, 0xFF000F85)			
		end
		DrawLines2(points, 3, 0xFF00FF00)
	end
end
