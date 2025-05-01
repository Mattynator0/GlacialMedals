class Map
{
    string uid;
    string id;
    string name;
    uint pb_time = uint(-1) - 1;
    array<uint> medals(MedalType::Count, uint(-1) - 2);
    string download_url;
    Campaign@ campaign;

    bool MedalAchieved(const MedalType&in medal_type)
    {
        return pb_time <= medals[medal_type];
    }

    bool PbExists()
    {
        return pb_time != uint(-1) - 1;
    }

    uint GetMedalTime(const MedalType&in medal_type)
    {
        return medals[medal_type];
    }

    void PlayCoroutine()
    {
        if(!Permissions::PlayLocalMap()) {
            user_has_permissions = false;
            return;
        }
        
		auto app = cast<CTrackMania>(GetApp());
        if (app.Network.PlaygroundClientScriptAPI.IsInGameMenuDisplayed) 
        {
            app.Network.PlaygroundInterfaceScriptHandler.CloseInGameMenu(CGameScriptHandlerPlaygroundInterface::EInGameMenuResult::Quit);
        }
        app.BackToMainMenu();
        while (!app.ManiaTitleControlScriptAPI.IsReady) yield();
		app.ManiaTitleControlScriptAPI.PlayMap(download_url, "", "");
    }
}