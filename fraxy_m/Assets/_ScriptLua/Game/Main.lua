local Main = {}

require 'unity.Debug'
require 'Game.Proto'

local Unity = require 'unity.Unity'
local _R = require 'Utils.ResMgr'

local cur

function Main:Awake()
	cur = self

	local go = _R('gameobject', 'P_Game')
	go:SetActive(true)
	self.game = assert(Unity.lua.GetLBT(go))
end

function Main:OnDestroy()
	cur = nil
	Unity.GameObject.Destroy(self.game.gameObject)
end

--



return Main
