local AudioField = {}
local Unity = require 'unity.Unity'
local Math = require 'unity.Math'
local FU = Math.Vector3.FromUnity
local TU = Math.Vector3.ToUnity
local Native = csharp.checked_import('AudioField')

function AudioField.PlayAtPos(id, pos)
	return Native.PlayAtPos(id, TU(pos))
end

function AudioField.PlayAtPivot(id, pivot)
	return Native.PlayAtPivot(id, pivot)
end

function AudioField.Play(id)
	return Native.Play(id)
end

function AudioField.SetVolume(name, value)
	Native.SetVolume(name, value)
end

function AudioField.GetVolume(name)
	return Native:GetVolume(name)
end

local bgMusic
function AudioField.PlayInBackground(id)
	if bgMusic and bgMusic.config.id == id then return end
	local bg = AudioField.Play(id)
	if bgMusic then bgMusic:Stop(0.5) end
	bgMusic = bg
	return bgMusic
end

return AudioField