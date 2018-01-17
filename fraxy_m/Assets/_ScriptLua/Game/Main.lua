local Main = {}

require 'unity.Debug'
require 'Game.Proto'

local cur

function Main:Awake()
	cur = self



end

function Main:OnDestroy()
	cur = nil
end

--


return Main