local Unity = {}

Unity.UI = {}
Unity.UI.Text = csharp.checked_import('Unity.UI.Text')
Unity.UI.Image = csharp.checked_import('Unity.UI.Image')
Unity.UI.Button = csharp.checked_import('Unity.UI.Button')
Unity.UI.HorizontalLayoutGroup = csharp.checked_import('Unity.UI.HorizontalLayoutGroup')
Unity.UI.InputField = csharp.checked_import('Unity.UI.InputField')

Unity.GameObject = csharp.checked_import('Unity.GameObject')
Unity.Animator = csharp.checked_import('Unity.Animator')
Unity.Resources = csharp.checked_import('Unity.Resources')
Unity.Camera = csharp.checked_import('Unity.Camera')
Unity.Rigidbody2D = csharp.checked_import('Unity.Rigidbody2D')

return Unity