#if DEPENDENCY_ULTIMATEMEDALSEXTENDED

class UMEGlacialMedal : UltimateMedalsExtended::IMedal {
    UltimateMedalsExtended::Config GetConfig() override {
        UltimateMedalsExtended::Config c;
        c.defaultName = "Glacial";
        c.icon = "\\$29b" + Icons::Circle;
        return c;
    }

    void UpdateMedal(const string &in uid) override {}

    bool HasMedalTime(const string &in uid) override {
        return CampaignManager::glacial_campaign.MapExists(uid);
    }

    uint GetMedalTime() override {
        auto app = cast<CGameManiaPlanet>(GetApp());
        if (app.RootMap is null)
            return 0;

        const string uid = app.RootMap.EdChallengeId;
        Map@ map = CampaignManager::glacial_campaign.GetMapByUid(uid);
        return map.GetMedalTime(MedalType::Glacial);
    }
}

class UMEChallengeMedal : UltimateMedalsExtended::IMedal {
    UltimateMedalsExtended::Config GetConfig() override {
        UltimateMedalsExtended::Config c;
        c.defaultName = "Challenge";
        c.icon = "\\$049" + Icons::Circle;
        return c;
    }

    void UpdateMedal(const string &in uid) override {}

    bool HasMedalTime(const string &in uid) override {
        return CampaignManager::glacial_campaign.MapExists(uid);
    }

    uint GetMedalTime() override {
        auto app = cast<CGameManiaPlanet>(GetApp());
        if (app.RootMap is null)
            return 0;

        const string uid = app.RootMap.EdChallengeId;
        Map@ map = CampaignManager::glacial_campaign.GetMapByUid(uid);
        return map.GetMedalTime(MedalType::Challenge);
    }
}

void RegisterUME() {
    UltimateMedalsExtended::AddMedal(UMEGlacialMedal());
    UltimateMedalsExtended::AddMedal(UMEChallengeMedal());
}

void OnDestroyedUME() {
    UltimateMedalsExtended::RemoveMedal("Glacial");
    UltimateMedalsExtended::RemoveMedal("Challenge");
}

#endif