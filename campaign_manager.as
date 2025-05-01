enum MedalType
{
    Author = 0,
    Glacial = 1,
    Challenge = 2,
    Count = 3
}

namespace CampaignManager
{
	Campaign@ glacial_campaign;
	MedalType selected_medal_type = MedalType::Glacial;
    Json::Value glacial_campaign_json = Json::Object();

    string club_id;
    string campaign_id;

    array<string> medal_names_full = {"Author Time", "Glacial Medal", "Challenge Medal"};
    array<string> medal_names_first = {"Author", "Glacial", "Challenge"};
    array<uint> medals_achieved = {0, 0, 0, 0};
    array<uint> medals_total = {25, 25, 25, 75};

    void Init()
    {
        FetchCampaignData();
        FetchGlacialCampaign();
        FetchMedalsData();
    }

    void FetchCampaignData()
    {
        const string config_url = "https://openplanet.dev/plugin/glacialmedals/config/campaign_data";

        auto @config_req = Net::HttpGet(config_url);
        while (!config_req.Finished()) yield();
        auto config_json = config_req.Json();

        club_id = config_json["clubID"];
        campaign_id = config_json["campaignID"];
    }

    // fetches campaign data, then maps data
    void FetchGlacialCampaign() 
    {
        string req_url = "https://live-services.trackmania.nadeo.live/api/token/club/" +
                        string(club_id) + "/campaign/" + string(campaign_id);

        auto @req = NadeoServices::Get("NadeoLiveServices", req_url);
        Api::AddUserAgent(req);
        req.Start();
        while (!req.Finished()) yield();

        glacial_campaign_json = req.Json();
        @glacial_campaign = Campaign(glacial_campaign_json);
        Api::FetchMapsData();
    }

    // fetches a config file with medal times
    void FetchMedalsData()
    {
        const string config_url = "https://openplanet.dev/plugin/glacialmedals/config/medals_data";

        auto @config_req = Net::HttpGet(config_url);
        while (!config_req.Finished()) yield();
        auto config_json = config_req.Json();

        glacial_campaign.LoadMedalTimes(config_json);
    }

    void RecalculateMedalsCounts()
    {
        medals_achieved = {0, 0, 0, 0};
        
        for (uint i = 0; i < glacial_campaign.maps.Length; i++)
        {
            for (uint j = 0; j < MedalType::Count; j++)
            {
                if (glacial_campaign.maps[i].MedalAchieved(MedalType(j)))
                {
                    medals_achieved[j]++;
                    medals_achieved[3]++;
                }
            }
        }
    }

    void SelectMedalType(const MedalType&in medal_type)
    {
        selected_medal_type = medal_type;
    }

    string GetCampaignName()
    {
        return glacial_campaign.name;
    }

    Map GetMap(uint index)
    {
        return glacial_campaign.maps[index];
    }

    uint GetMapsCount()
    {
        return glacial_campaign.maps.Length;
    }

    MedalType GetSelectedMedalType()
    {
        return selected_medal_type;
    }

    bool AreRecordsLoading()
    {
        return glacial_campaign.AreRecordsLoading();
    }
    
    bool AreMedalsLoading()
    {
        return glacial_campaign.AreMedalsLoading();
    }

    uint GetMedalsAchieved(const MedalType&in medal_type)
    {
        return medals_achieved[medal_type];
    }

    uint GetMedalsTotal(const MedalType&in medal_type)
    {
        return medals_total[medal_type];
    }

    uint GetMedalsAchievedOverall()
    {
        return medals_achieved[3];
    }

    uint GetMedalsTotalOverall()
    {
        return medals_total[3];
    }

    string GetMedalName()
    {
        return medal_names_full[selected_medal_type];
    }
}