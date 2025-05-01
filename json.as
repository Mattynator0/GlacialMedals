namespace MyJson
{
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
        Campaign@ campaign = CampaignManager::glacial_campaign;
        campaign.maps.Resize(0);
        for (uint i = 0; i < maps_info["mapList"].Length; i++)
        {
            Map map;
            map.name = maps_info["mapList"][i]["name"];
            map.uid = maps_info["mapList"][i]["uid"];
            map.id = maps_info["mapList"][i]["mapId"];
            campaign.mapuid_to_maps_array_index.Set(map.uid, i);
            map.download_url = maps_info["mapList"][i]["downloadUrl"];
            @map.campaign = campaign;
            campaign.maps.InsertLast(map);

            map_uid_to_handle.Set(map.uid, @map);
        }
    }
}