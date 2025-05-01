enum MedalType
{
    Author = 0,
    Glacial = 1,
    Challenge = 2,
    Count = 3
}

namespace CampaignManager
{
    bool initialized = false;

	Campaign@ glacial_campaign;
	MedalType selected_medal_type;
    Json::Value glacial_campaign_json = Json::Object();

    array<string> medal_names = {"Author Time", "Glacial Medal", "Challenge Medal"};
    array<uint> medals_achieved = {0, 0, 0, 0};
    array<uint> medals_total = {25, 25, 25, 75};

    void Init()
    {
        FetchGlacialCampaign();
        FetchConfigFile();
        initialized = true; // FIXME check if init still works
    }

    // fetches campaign data, then maps data
    void FetchGlacialCampaign() 
    {
        const string club_id = "383";          // FIXME test values, change later!
        const string campaign_id = "92460";    // FIXME test values, change later!

        string req_url = "https://live-services.trackmania.nadeo.live/api/token/club/" +
                        string(club_id) + "/campaign/" + string(campaign_id);

        auto @req = NadeoServices::Get("NadeoLiveServices", req_url);
        Api::AddUserAgent(req);
        req.Start();
        while (!req.Finished()) yield();

        glacial_campaign_json = req.Json();
        @glacial_campaign = Campaign(glacial_campaign_json);
        FetchMapsData();
    }

    void FetchMapsData()
    {
        Api::FetchMapsData();
    }

    // fetches a config file with medal times
    void FetchConfigFile()
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

    uint GetMedalsAchieved()
    {
        return medals_achieved[3];
    }

    uint GetMedalsTotal()
    {
        return medals_total[3];
    }
}