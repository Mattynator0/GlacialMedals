[Setting hidden]
bool show_browser_window = true;

class Browser
{
	vec4 base_color = vec4(0.105, 0.488, 0.645, 1.0);
	vec4 brighter_color = vec4(0.145, 0.588, 0.745, 1.0);
	vec4 brightest_color = vec4(0.185, 0.688, 0.845, 1.0);
	string base_circle = "\\$29b" + Icons::Circle + "\\$fff "; // TODO different colors for AT and Challenge Medal

	bool show_only_unbeaten_medals = false;
	bool tiles_display = true;

	uint window_w = 900;
	uint window_h = 600;

	UI::Texture@ logo;
	UI::Font@ base_large_font;
	UI::Font@ base_normal_font;
	UI::Font@ base_small_font;

	Browser()
	{
		@logo = UI::LoadTexture("logo.png");

		@base_large_font = UI::LoadFont("DroidSans.ttf", 26, -1, -1 , true, true, true);
		@base_normal_font = UI::LoadFont("DroidSans.ttf", 20, -1, -1 , true, true, true);
		@base_small_font = UI::LoadFont("DroidSans.ttf", 16, -1, -1 , true, true, true);

		CampaignManager::Init();
	}

	void RenderMenu() 
	{
    	if (UI::MenuItem(base_circle + "Glacial Medals", "", show_browser_window)) {
        	show_browser_window = !show_browser_window;
    	}
	}

	void Draw()
	{
		if (!show_browser_window) return;

		//     _____________________________
		//    |              |              |
		//    |   O  Title   |   Campaign   |
		//    |              |     info     |
		//    |              |              |
		//    |   Campaign   |  Map1  sm pb |
		//    |   selection  |  Map2  sm pb |
		//    |              |  Map3  sm pb |
		//    |              |  ...         |
		//    |______________|______________|
		//
		//  sm - s314ke medal
		//  pb - personal best

		UI::PushStyleColor(UI::Col::Separator, base_color);
		UI::PushStyleColor(UI::Col::SeparatorHovered, brighter_color);
		UI::PushStyleColor(UI::Col::SeparatorActive, brightest_color);
		UI::PushStyleColor(UI::Col::Button, base_color);
		UI::PushStyleColor(UI::Col::ButtonHovered, brighter_color);
		UI::PushStyleColor(UI::Col::ButtonActive, brightest_color);

		UI::SetNextWindowSize(window_w, window_h);
		UI::Begin(base_circle + "Glacial Medals", show_browser_window, UI::WindowFlags::NoCollapse | UI::WindowFlags::NoScrollbar);
		UI::Columns(2);

		// ------------------------------------------------ LEFT SIDE ------------------------------------------------
		UI::BeginChild("LeftContainer");
		
		DrawTitle();

		DrawCampaignSelectionMenu();

		UI::EndChild(); // "LeftContainer"
		UI::NextColumn();
		
		// ------------------------------------------------ RIGHT SIDE ------------------------------------------------
		
		// leave the right side empty until a campaign is chosen
		if (CampaignManager::glacial_campaign is null)
		{
			UI::End(); // "Glacial Medals"
			UI::PopStyleColor(6); // Separator and Button
			return;
		}

		if (!CampaignManager::glacial_campaign.maps_loaded)
		{
			UI::Text("Loading...");
			UI::End(); // "Glacial Medals"
			UI::PopStyleColor(6); // Separator and Button
			return;
		}

		UI::BeginChild("RightContainer");
		
		DrawCampaignInfo();

		DrawMapsInfo();

		UI::EndChild(); // "RightContainer"
		UI::End(); // "Glacial Medals"
		UI::PopStyleColor(6); // Separator and Button
	}
	
	void DrawTitle()
	{
		UI::BeginChild("TitleWrapper", vec2(-1, 200));
		
		if (UI::BeginTable("TitleTable", 2)) 
		{
			UI::TableSetupColumn("##Medal", UI::TableColumnFlags::WidthFixed);
			UI::TableSetupColumn("##TitleText", UI::TableColumnFlags::WidthStretch);
	
			UI::TableNextColumn();
			uint padding = 25;
			uint medal_x = 150;
			uint medal_y = 150;
			UI::BeginChild("MedalWrapper", vec2(medal_x + 2 * padding, medal_y + padding));
			UI::SetCursorPos(UI::GetCursorPos() + vec2(padding, padding));
			UI::Image(logo, vec2(medal_x, medal_y));
			UI::EndChild(); // "MedalWrapper"
	
			UI::TableNextColumn();
			UI::BeginChild("TitleTextWrapper");
			UI::PushFont(base_large_font);
			CenterText(base_circle + " Glacial Medals", vec2(0, -20));
			UI::PopFont();
	
			string medal_counter_text = base_circle + " " + CampaignManager::GetMedalsAchieved() + 
										" / " + CampaignManager::GetMedalsTotal();
			UI::PushFont(base_normal_font);
			CenterText(medal_counter_text, vec2(-20, 70));
			UI::SameLine();
			UI::PushFont(base_small_font);
			if (UI::Button(Icons::Refresh)) {
				CampaignManager::FetchMapsData();
			}
			UI::PopFont(); // small
			if (CampaignManager::AreRecordsLoading()) {
				CenterText("Loading...", vec2(0, 125));
			}
			UI::PopFont(); // normal

			UI::EndChild(); // "TitleTextWrapper"
			UI::EndTable(); // "TitleTable"
		}
		UI::SetWindowSize(vec2(UI::GetWindowContentRegionMax().x, 200));
		UI::EndChild(); // "TitleWrapper"
	}

	void DrawCampaignSelectionMenu()
	{
		UI::PushStyleColor(UI::Col::Tab, base_color);
		UI::PushStyleColor(UI::Col::TabHovered, brightest_color);
		UI::PushStyleColor(UI::Col::TabActive, brighter_color);

		string checkbox_label;
		if (tiles_display) 
			checkbox_label = " Tiles";
		else checkbox_label = " List";

		if (tiles_display)
		{
			if (UI::Button(Icons::Bars))
				tiles_display = false;
		}
		else
		{
			if (UI::Button(Icons::ThLarge))
				tiles_display = true;
		}

		if (tiles_display)
			DrawCampaignSelectionMenuTiles();
		else DrawCampaignSelectionMenuList();

		UI::PopStyleColor(3);
	}

	void DrawCampaignSelectionMenuList()
	{
		if (!CampaignManager::glacial_campaign.medals_loaded)
		{
			UI::Text("Loading...");
			return;
		}
		
		UI::PushStyleColor(UI::Col::TableRowBg, vec4(.25, .25, .25, .2));
		UI::PushFont(base_normal_font);
		if (UI::BeginTable("CampaignsTableList", 5, UI::TableFlags::RowBg | UI::TableFlags::ScrollY | UI::TableFlags::PadOuterX))
		{
			UI::TableSetupColumn("Name", UI::TableColumnFlags::WidthStretch);
			UI::TableSetupColumn("##achieved", UI::TableColumnFlags::WidthFixed);
			UI::TableSetupColumn("Progress   ", UI::TableColumnFlags::WidthFixed);
			UI::TableSetupColumn("##info", UI::TableColumnFlags::WidthFixed);
			UI::TableSetupColumn("##refresh", UI::TableColumnFlags::WidthFixed);
			UI::TableSetupScrollFreeze(5, 1);

			UI::TableHeadersRow();

			for (uint i = 0; i < MedalType::Count; i++)
			{
				UI::TableNextRow(UI::TableRowFlags::None, 30);
				Campaign@ campaign = CampaignManager::glacial_campaign;
				MedalType@ medal_type = CampaignManager::GetSelectedMedalType();

				UI::TableNextColumn(); // "Name"
				UI::AlignTextToFramePadding();
				UI::Text(CampaignManager::medal_names[medal_type]);

				UI::TableNextColumn(); // "##achieved"
				if (CampaignManager::medals_achieved[medal_type] == CampaignManager::medals_total[medal_type])
					UI::Text(base_circle);

				UI::TableNextColumn(); // "Progress"
				UI::Text(tostring(CampaignManager::GetMedalsAchieved()) + " / " + CampaignManager::GetMedalsTotal());

				UI::TableNextColumn(); // "##info"
				UI::PushFont(base_small_font);
				UI::PushID("CampaignInfoButton" + tostring(i));
				if (UI::Button(Icons::InfoCircle))
					CampaignManager::SelectMedalType(i);
				UI::PopID();
				UI::PopFont(); // small

				UI::TableNextColumn(); // "##refresh"
				UI::PushFont(base_small_font);
				UI::PushID("CampaignRefreshButton" + tostring(i));
				if (UI::Button(Icons::Refresh))
					CampaignManager::FetchMapsData();
				UI::PopID();
				UI::PopFont(); // small
			}

			UI::EndTable(); // "CampaignsTableList"
		}
		UI::PopFont(); // normal
		UI::PopStyleColor(); // TableRowBg
	}
	void DrawCampaignSelectionMenuTiles()
	{
		const vec2 button_size = vec2(80, 80);
		const float button_padding = 5; // also the minimum value of 'b', for context look at the diagram below
		const uint buttons_per_row = Math::Max(1, uint(UI::GetWindowSize().x / (button_size.x + 2 * button_padding)));

		UI::BeginChild("TableWrapper", vec2(), false, UI::WindowFlags::NoScrollbar);
		if (CampaignManager::AreMedalsLoading())
		{
			UI::Text("Loading...");
			UI::EndChild(); // "TableWrapper"
			return;
		}
		if (UI::BeginTable("CampaignsTableTiles", buttons_per_row))
		{
			UI::PushStyleVar(UI::StyleVar::FrameRounding, 10);

			// button spacing (value of 'a' is fixed)
			//  
			// |    __      __      __    |
			// |   |__|    |__|    |__|   |
			// |                          |
			//      a       a       a
			//  <-><--><--><--><--><--><->
			//   b      2b      2b      b
			// 
			for (uint i = 0; i < MedalType::Count; i++)
			{
				UI::TableNextColumn();
				UI::Dummy(vec2(0, 2 * button_padding));
					
				float whole_width = UI::GetWindowSize().x;

				// look at the figure above to understand what 'a' and 'b' are
				float a = button_size.x;
				float b = (whole_width - a * buttons_per_row) / (buttons_per_row * 2);
				UI::SetCursorPos(UI::GetCursorPos() + vec2(b, 0)); // center button

				UI::PushID("CampaignButton" + tostring(i));
				if (UI::Button("", button_size))
				{
					CampaignManager::SelectMedalType(i);
				}
				UI::PopID();
				
				UI::PushFont(base_large_font);
				if (Draw::MeasureString(CampaignManager::medal_names[i]).x > button_size.x - 14) {
					UI::PopFont();
					UI::PushFont(base_normal_font);
				}
				if (Draw::MeasureString(CampaignManager::medal_names[i]).x > button_size.x - 14) {
					UI::PopFont();
					UI::PushFont(base_small_font);
				}
				vec2 text_size = Draw::MeasureString(CampaignManager::medal_names[i]);
				float move_short_name_x = (button_size.x - text_size.x) * 0.5f;
				float additional_offset = 1.0; // for some reason the text is slightly off center without this
				UI::SetCursorPos(UI::GetCursorPos() + vec2(b + move_short_name_x + additional_offset, -35 - (text_size.y))); // center text
				UI::Text(CampaignManager::medal_names[i]);
				UI::PopFont();
			}
			UI::PopStyleVar();

			UI::EndTable(); // "CampaignsTable"
		}
		UI::EndChild(); // "TableWrapper"
	}

	void DrawCampaignInfo()
	{
		if (!user_has_permissions)
			UI::Text("You don't have permissions to play maps locally.\n\nThe \"Play\" buttons will be disabled.");
		UI::BeginChild("CampaignInfo", vec2(-1, 150));
		if (UI::BeginTable("CampaignInfoTable", 2))
		{
			UI::TableSetupColumn("##name", UI::TableColumnFlags::WidthStretch);
			UI::TableSetupColumn("##progress", UI::TableColumnFlags::WidthStretch);
			
			UI::PushFont(base_large_font);

			UI::TableNextColumn();
			UI::BeginChild("CampaignName");
			// center the text
			vec2 container_size = UI::GetContentRegionAvail();
			vec2 campaignname_text_size = Draw::MeasureString(CampaignManager::GetCampaignName());
			UI::SetCursorPos((container_size - campaignname_text_size) * 0.5f);
			UI::Text(CampaignManager::GetCampaignName()); // full campaign name
			UI::EndChild(); // "CampaignName"
			
			UI::TableNextColumn();
			UI::BeginChild("CampaignMedalCounter");
			string medalcounter_text = base_circle + " " + tostring(CampaignManager::GetMedalsAchieved()) 
							   + " / " + tostring(CampaignManager::GetMedalsTotal());
			container_size = UI::GetContentRegionAvail();
			vec2 medalcounter_text_size = Draw::MeasureString(medalcounter_text);
			UI::SetCursorPos((container_size - medalcounter_text_size) * 0.5f + vec2(-10, 0)); // -10 to account for the refresh button
			UI::Text(medalcounter_text);
			UI::SameLine();
			UI::PushFont(base_small_font);
			if (!CampaignManager::AreRecordsLoading() && UI::Button(Icons::Refresh)) {
				CampaignManager::FetchMapsData();
			}
			UI::PopFont(); // small
			UI::EndChild(); // "CampaignMedalCounter"

			UI::PopFont(); // large
			UI::EndTable(); // "CampaignInfoTable"
		}
		UI::EndChild(); // "CampaignInfo"
	}

	void DrawMapsInfo()
	{
		UI::BeginChild("Maps", vec2(), false, UI::WindowFlags::NoScrollbar);
		UI::PushStyleColor(UI::Col::CheckMark, brightest_color);
		UI::PushStyleColor(UI::Col::FrameBg, vec4(.35, .35, .35, .3));
		UI::PushStyleColor(UI::Col::FrameBgHovered, base_color);
		UI::PushStyleColor(UI::Col::FrameBgActive, brighter_color);
		// a single whitespace at the beginning of the checkbox label is intentional and used as padding
		show_only_unbeaten_medals = UI::Checkbox(" Only show maps with an unachieved medal", show_only_unbeaten_medals);
		UI::PushStyleColor(UI::Col::TableRowBg, vec4(.25, .25, .25, .2));
		UI::PushFont(base_small_font);

		uint n_columns = 6;
		if (UI::BeginTable("MapsTable", n_columns, UI::TableFlags::RowBg | UI::TableFlags::ScrollY | UI::TableFlags::PadOuterX))
		{
			UI::TableSetupColumn("Name", UI::TableColumnFlags::WidthStretch, 2);
			UI::TableSetupColumn("##padding", UI::TableColumnFlags::WidthFixed);
			UI::TableSetupColumn("Medal", UI::TableColumnFlags::WidthStretch);
			UI::TableSetupColumn("##achieved", UI::TableColumnFlags::WidthFixed);
			UI::TableSetupColumn("PB", UI::TableColumnFlags::WidthStretch);
			UI::TableSetupColumn("##button", UI::TableColumnFlags::WidthFixed);
			UI::TableSetupScrollFreeze(n_columns, 1);

			UI::TableHeadersRow();

			for (uint i = 0; i < CampaignManager::GetMapsCount(); i++)
			{
				Map map = CampaignManager::GetMap(i);
				// skip if checkbox is ticked AND (medal is achieved OR doesn't exist)
				if (show_only_unbeaten_medals && map.MedalAchieved())
					continue;

				UI::TableNextRow(UI::TableRowFlags::None, 30);

				UI::TableNextColumn(); // "Name"
				UI::AlignTextToFramePadding();
				UI::Text(Text::OpenplanetFormatCodes(map.name));

				UI::TableNextColumn(); // "##padding"
				UI::TableNextColumn(); // "Medal"
				UI::Text(Time::Format(map.GetMedalTime(i)));

				UI::TableNextColumn(); // "##achieved"
				if (map.MedalAchieved())
					UI::Text(base_circle);

				UI::TableNextColumn(); // "PB"
				if (map.PbExists())
					UI::Text(Time::Format(map.pb_time));

				UI::TableNextColumn(); // "##button"
				UI::PushID("Play" + i);
				UI::BeginDisabled(!user_has_permissions);
				if (UI::Button("Play"))
				{
					startnew(CoroutineFunc(map.PlayCoroutine));
				}
				UI::EndDisabled();
				UI::PopID(); // "Play" + i
			}
			UI::EndTable(); // "MapsTable"
		}
		UI::PopFont();
		UI::PopStyleColor(5); // TableRowBg, Frame, Checkmark
		UI::EndChild(); // "Maps"
	}

	void CenterText(const string&in text, const vec2 additional_offset = vec2(0,0))
	{
		vec2 container_size = UI::GetContentRegionAvail();
		vec2 text_size = Draw::MeasureString(text);
		UI::SetCursorPos((container_size - text_size) * 0.5f + additional_offset);
		UI::Text(text);
	}
}
