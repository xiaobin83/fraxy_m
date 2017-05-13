local Global = {}

Global.UI = {}
Global.UI.Text = csharp.checked_import('UnityEngine.UI.Text')
Global.UI.Image = csharp.checked_import('UnityEngine.UI.Image')
Global.UI.Button = csharp.checked_import('UnityEngine.UI.Button')

Global.GameObject = csharp.checked_import('UnityEngine.GameObject')
Global.Animator = csharp.checked_import('UnityEngine.Animator')

return Global