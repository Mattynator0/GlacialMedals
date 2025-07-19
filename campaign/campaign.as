

class Campaign
{
    string name;

    array<Map@> maps;
    bool maps_loaded = false;
    bool medals_loaded = false;
    dictionary mapuid_to_maps_array_index;

    uint map_records_coroutines_running = 0;

    Campaign(Json::Value@ data_json)
    {
        this.name = data_json["campaign"]["name"];
    }

    void LoadMedalTimes(Json::Value@ medals_json)
    {
        for (uint i = 0; i < medals_json.Length; i++) 
        {
            uint index;
            mapuid_to_maps_array_index.Get(medals_json[i]['mapUID'], index);
            Map@ map = maps[index];
            map.medals[MedalType::Author] = medals_json[i]['authorTime'];
            map.medals[MedalType::Glacial] = medals_json[i]['glacialTime'];
            map.medals[MedalType::Challenge] = medals_json[i]['challengeTime'];
        }
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

    bool MapExists(const string&in uid) {
        return mapuid_to_maps_array_index.Exists(uid);
    }

    Map@ GetMapByUid(const string&in uid) {
        uint index;
        mapuid_to_maps_array_index.Get(uid, index);
        return maps[index];
    }
}