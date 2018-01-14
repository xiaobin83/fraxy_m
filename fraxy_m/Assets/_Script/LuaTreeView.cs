using UnityEngine;
using System.Collections;
using lua;
using ui;

public class LuaTreeView : ui.TreeView<lua.LuaTable>
{
	public override Node Add(string name, LuaTable item, Node parent = null)
	{
		item.Retain();
		return base.Add(name, item, parent);
	}

	public override void Remove(Node target)
	{
		target.item.Dispose();
		base.Remove(target);
	}
}
