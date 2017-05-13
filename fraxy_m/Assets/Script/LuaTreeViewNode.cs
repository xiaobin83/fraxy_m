using UnityEngine;
using System.Collections;
using UnityEngine.Events;

public class LuaTreeViewNode : MonoBehaviour {

	[System.Serializable]
	public class ItemCreateEvent : UnityEvent<string, ui.TreeView<lua.LuaTable>.Node> { };

	public ItemCreateEvent onItemCreated;

	[System.Serializable]
	public class ItemEvent : UnityEvent<string> { }
	public ItemEvent onItemEvent;

	void OnItemCreated(ui.TreeView<lua.LuaTable>.Node item)
	{
		if (onItemCreated != null)
		{
			onItemCreated.Invoke("OnItemCreated", item);
		}
	}

	void OnItemSelected()
	{
		if (onItemEvent != null)
		{
			onItemEvent.Invoke("OnItemSelected");
		}
	}

	void OnItemDeselected()
	{
		if (onItemEvent != null)
		{
			onItemEvent.Invoke("OnItemDeselected");
		}
	}

	void OnItemExpanded()
	{
		if (onItemEvent != null)
		{
			onItemEvent.Invoke("OnItemExpanded");
		}
	}

	void OnItemCollapsed()
	{
		if (onItemEvent != null)
		{
			onItemEvent.Invoke("OnItemCollapsed");
		}
	}


}
