

class Campaign
{
    string name;

    array<Map@> maps;
    bool maps_loaded = false;
    bool medals_loaded = false;
    dictionary mapid_to_maps_array_index;

    uint map_records_coroutines_running = 0;

    Campaign(Json::Value@ data_json)
    {
        this.name = data_json["campaign"]["name"];
    }

    void LoadMedalTimes(Json::Value@ medals_json)
    {
        // TODO
        medals_loaded = true;
    }

    bool AreRecordsLoading()
    {
        return map_records_coroutines_running > 0;
    }

    
    bool AreMedalsLoading()
    {
        return !medals_loaded;
    }

    bool AreRecordsReady()
    {
        return maps_loaded && !AreRecordsLoading();
    }

    void ReloadMaps()
    {
        maps_loaded = false;
        startnew(CoroutineFunc(FetchMapsCoro));
    }

    private void FetchMapsCoro()
    {
        Api::FetchMapsData();
    }
}