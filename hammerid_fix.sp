#include <sourcemod>
#include <sdktools>
#include <dhooks>

#pragma newdecls required
#pragma semicolon 1

#define PLUGIN_VERSION "1.0.0"
#define DEBUG 0

public Plugin myinfo =
{
    name        = "[v34] hammerid fix",
    author      = "DeepSeek",
    description = "Fixes game_player_equip treating hammerid as a weapon name",
    version     = PLUGIN_VERSION,
    url         = ""
};

DHookSetup g_hKeyValue = null;

public void OnPluginStart()
{
    GameData gameconf = new GameData("hammerid_fix.games");
    if (gameconf == null)
        SetFailState("Failed to find hammerid_fix.games.txt");

    g_hKeyValue = DHookCreateFromConf(gameconf, "CGamePlayerEquip::KeyValue");
    if (g_hKeyValue == null)
        SetFailState("Failed to create detour \"CGamePlayerEquip::KeyValue\"");

    if (!DHookEnableDetour(g_hKeyValue, false, Detour_KeyValue))
        SetFailState("Error enabling detour \"CGamePlayerEquip::KeyValue\"");

    gameconf.Close();

#if DEBUG
    PrintToServer("[hammerid-fix] Detour installed for CGamePlayerEquip::KeyValue");
#endif
}

public void OnPluginEnd()
{
    if (g_hKeyValue != null)
    {
        DHookDisableDetour(g_hKeyValue, false, Detour_KeyValue);
    }
}

public MRESReturn Detour_KeyValue(DHookReturn hReturn, DHookParam hParams)
{
    char szKeyName[128];
    hParams.GetString(1, szKeyName, sizeof(szKeyName));

#if DEBUG
    PrintToServer("[hammerid-fix] KeyValue key='%s'", szKeyName);
#endif

    if (StrEqual(szKeyName, "hammerid", false))
    {
#if DEBUG
        PrintToServer("[hammerid-fix] Ignoring 'hammerid' (returning true)");
#endif
        hReturn.Value = 1;   // вернуть true, не вызывая оригинал
        return MRES_Supercede;
    }

    return MRES_Ignored;
}