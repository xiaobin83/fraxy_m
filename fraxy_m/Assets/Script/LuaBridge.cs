using System;
using UnityEngine;
using System.Collections.Generic;

public class LuaBridge : MonoBehaviour
{
	public static LuaBridge current;
	public static lua.Lua luaState;

	void Awake()
	{
		Debug.Assert(current == null);
		DontDestroyOnLoad(gameObject);

		lua.Lua.typeLoader = TypeLoader;
		luaState = new lua.Lua();
		lua.LuaBehaviour.SetLua(luaState);

		current = this;
	}

	void OnDestroy()
	{
		current = null;
	}

	public GameObject LoadSprite(string spriteName)
	{
		var obj = Resources.Load<GameObject>(spriteName);
		return GameObject.Instantiate<GameObject>(obj);
	}

	static Dictionary<string, Type> cachedTypes = new Dictionary<string, Type>();

	[lua.LuaTypeLoader]
	public static Type TypeLoader(string typename)
	{
		typename = typename.Trim();
		Type type;
		if (cachedTypes.TryGetValue(typename, out type))
			return type;

		type = Type.GetType(typename);
		if (type == null)
			type = Type.GetType(typename + ",UnityEngine");
		if (type == null)
			type = Type.GetType(typename + ",UnityEngine.UI");
		if (type == null)
			type = Type.GetType(typename + ",Assembly-CSharp-firstpass");

		cachedTypes.Add(typename, type);

		return type;
	}

/* TODO:
	[lua.LuaScriptLoader]
	public static byte[] ScriptLoader(string scriptName, out string scriptPath)
	{
		scriptPath = scriptName;
		return null;
	}
*/

}
