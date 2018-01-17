local PerfScale = {}
local Unity = require 'Unity'


PerfScale.supportAR = false
PerfScale.rtScale = 1

local configLow = {
	QualityTier = 'Good',
	VSyncCount =  2,
	TargetFPS = 30,
	LodBias = 2.5,
	ShadowProjection = 0,
	ShadowDistance = 210,
	ShadowResolution = 2,
	Terrain_BillboardStart = 0, -- all billboards
	Terrain_PixelError = 150,
	Terrain_BasemapDist = 150,
	ExtraRtScale = 1,
}

local configHigh = {
	QualityTier = 'Fantastic',
	VSyncCount = 2,
	TargetFPS = 30,
	LodBias = 2.5,
	ShadowProjection = 0,
	ShadowDistance = 300,
	ShadowResolution = 2,
	Terrain_BillboardStart = 100,
	Terrain_PixelError = 150,
	Terrain_BasemapDist = 150,
	ExtraRtScale = 1,
}

PerfScale.config = configLow

local CollectInfo = function()
	if _UNITY['IOS'] then
		local DeviceGeneration = csharp.checked_import('UnityEngine.iOS.DeviceGeneration') 
		local low = DeviceGeneration.iPhone6
		local high = DeviceGeneration.iPhone6S 
		local gen = 0
		if _UNITY['EDITOR'] then
			gen = high 
		else
			local Device = csharp.checked_import('UnityEngine.iOS.Device')
			gen = Device.generation
		end
		if gen < high then
			PerfScale.config = configLow
			PerfScale.supportAR = false
		else
			if _UNITY['EDITOR'] then
				PerfScale.supportAR = true
			else
				local Config = csharp.checked_import('UnityEngine.XR.iOS.ARKitWorldTrackingSessionConfiguration')
				PerfScale.supportAR = Config.IsSupported
			end
			PerfScale.config = configHigh 
		end
	else
		-- editor
		PerfScale.config = configHigh
		PerfScale.supportAR = true
	end

end


function PerfScale.UpdatePerfScale()

	CollectInfo()

	local QS = csharp.checked_import('UnityEngine.QualitySettings')
	local names = QS.names	
	local level = 0
	for i = 0, names.Length - 1 do
		if names[i] == PerfScale.config.QualityTier then
			level = i
			break
		end
	end
	QS.SetQualityLevel(level)
	
	local App = csharp.checked_import('UnityEngine.Application')
	App.targetFrameRate = PerfScale.config.TargetFPS 
	QS.vSyncCount = PerfScale.config.VSyncCount
	
	QS.lodBias = PerfScale.config.LodBias 
	QS.shadowDistance = PerfScale.config.ShadowDistance
	QS.shadowProjection = PerfScale.config.ShadowProjection
	QS.shadowResolution = PerfScale.config.ShadowResolution 

	-- to fixed resoluation if screen too large
	if Unity.Screen.width > 1334 then
		PerfScale.rtScale = 1334 / Unity.Screen.width
	else
		PerfScale.rtScale = 1
	end
	PerfScale.rtScale = PerfScale.rtScale * PerfScale.config.ExtraRtScale
	local RTS = csharp.checked_import('common.RenderToSamllRtThenUpSample')
	RTS.scale = PerfScale.rtScale
end



return PerfScale
