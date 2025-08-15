#if DEPENDENCY_ULTIMATEMEDALSEXTENDED

class UMEGlacialMedal : UltimateMedalsExtended::IMedal {
    UltimateMedalsExtended::Config GetConfig() override {
        UltimateMedalsExtended::Config c;
        c.defaultName = "Glacial";
        c.icon = "\\$29b" + Icons::Circle;
        return c;
    }
    
    string uid;

    void UpdateMedal(const string &in uid) override {
        this.uid = uid;
    }

    bool HasMedalTime(const string &in uid) override {
        if (uid != this.uid) {return false;}
        return CampaignManager::glacial_campaign.MapExists(uid);
    }

    uint GetMedalTime() override {
        Map@ map = CampaignManager::glacial_campaign.GetMapByUid(this.uid);
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

    string uid;

    void UpdateMedal(const string &in uid) override {
        this.uid = uid;
    }

    bool HasMedalTime(const string &in uid) override {
        if (uid != this.uid) {return false;}
        return CampaignManager::glacial_campaign.MapExists(uid);
    }

    uint GetMedalTime() override {
        Map@ map = CampaignManager::glacial_campaign.GetMapByUid(this.uid);
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