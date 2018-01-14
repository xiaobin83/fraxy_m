local Unity = require 'unity.Unity'
local Global = require 'Game.Global'
local Console = require 'Game.UI.Console'
local Input = require 'Input'
local Unity = require 'unity.Unity'
local RB = Unity.Rigidbody2D
local Text = Unity.UI.Text
local Vector2U = Unity.Vector2
local CC = {}

function CC.Attach(part)
	part.controller = Input
	part.rb = part.gameObject:AddComponent(RB)
	part.rb.gravityScale = 0
	part.rb.drag = part.type.attr.drag
	part.var.accel = 0
	Console.AddText('CC', function(n, e) CC.UpdateStatus(n, e, part) end)
end

function CC.UpdateStatus(n, e, part)
	part.console = part.console or {}
	local ce = part.console[n]
	if not ce then
		-- cache
		local t = e.uiCtrl:GetComponent(Text)
		ce = {e, t}
		part.console[n] = ce
	end
	if ce[2] then
		local vel = part.rb.velocity
		ce[2].text = 'accel: ' .. part.var.accel .. ', velocity: (' .. tostring(vel) .. ')'
	end
end

function CC.Detach(part)
	Console.Remove('CC')
	part.controller = nil
end

function CC.Start(part)
	-- check parts

end

function CC.Stop(part)
	
end

function CC.Step(part)
	local c = part.controller
	if c then
		local v = c.Dir()
		local t = c.LT()		
		part.var.accel = math.max(0, t * part.type.attr.boost)
		part.rb:AddRelativeForce(Vector2U(0, part.var.accel))
		part.rb.angularVelocity = - v.x * part.type.attr.turn
	end
end

function CC.Reset(part)

end

function CC.OnInspectorGUI(part, inspector)
	part.var.name = inspector:InputField(part.var.name)
end

return CC
