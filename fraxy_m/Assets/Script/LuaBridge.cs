using System;
using UnityEngine;
using System.Collections.Generic;

public class LuaBridge : MonoBehaviour
{
	public bool enableDebug = true;

	public static LuaBridge current;
	public static lua.Lua luaState;

	void Awake()
	{
		Debug.Assert(current == null);
		DontDestroyOnLoad(gameObject);

		lua.Lua.typeLoader = TypeLoader;
		luaState = new lua.Lua();
		lua.LuaBehaviour.SetLua(luaState);

		if (enableDebug)
		{
			lua.LuaDebugging.StartDebugging();
		}

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

	const float kCollectDuration = 15f;
	float collectTime = 0;
	void Update()
	{
		if (Time.realtimeSinceStartup > collectTime)
		{
			lua.LuaFunction.CollectActionPool();
			collectTime = Time.realtimeSinceStartup + kCollectDuration;
		}
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
