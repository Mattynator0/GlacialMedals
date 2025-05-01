namespace MyJson
{
    Campaign@ campaign = CampaignManager::glacial_campaign;
    dictionary map_uid_to_handle;

    // -----------------------------------------------------------------------------------------------
    // ------------------------------------- MAPS INITIALIZATION -------------------------------------
    // -----------------------------------------------------------------------------------------------

    string GetMapUidsAsString()
    {
        string result = "";
        Json::Value@ json = CampaignManager::glacial_campaign_json["campaign"]["playlist"];

        uint n_maps = json.Length;
        for (uint i = 0; i < n_maps - 1; i++)
        {
            result += json[i]["mapUid"];
            result += ",";
        }
        result += json[n_maps - 1]["mapUid"];
        return result;
    }

    void LoadMapsData(Json::Value@ maps_info)
    {
        campaign.maps.Resize(0);
        for (uint i = 0; i < maps_info["mapList"].Length; i++)
        {
            Map map;
            map.name = maps_info["mapList"][i]["name"];
            map.uid = maps_info["mapList"][i]["uid"];
            map.id = maps_info["mapList"][i]["mapId"];
            campaign.mapid_to_maps_array_index.Set(map.id, i);
            map.download_url = maps_info["mapList"][i]["downloadUrl"];
            @map.campaign = campaign;
            campaign.maps.InsertLast(map);

            map_uid_to_handle.Set(map.uid, @map);
        }
    }
    
    void LoadRecordsForSingleMap(Map@ map, Json::Value@ map_times)
    {
        if (map_times.GetType() == Json::Type::Object && map_times.HasKey("message")) {
            error("LoadMapRecords: API request returned an error message: " + string(map_times["message"]));
            return;
        }

        for (uint i = 0; i < map_times.Length; i++)
        {
            map.pb_time = map_times[i]["recordScore"]["time"];
        }
    }
}