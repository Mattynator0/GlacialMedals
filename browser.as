[Setting hidden]
bool show_browser_window = true;

class Browser
{
	vec4 base_color = vec4(0.105, 0.488, 0.645, 1.0);
	vec4 brighter_color = vec4(0.145, 0.588, 0.745, 1.0);
	vec4 brightest_color = vec4(0.185, 0.688, 0.845, 1.0);
	string base_circle_glacial = "\\$29b" + Icons::Circle + "\\$fff ";
	string base_circle_author = "\\$174" + Icons::Circle + "\\$fff ";
	string base_circle_challenge = "\\$049" + Icons::Circle + "\\$fff ";

	bool show_only_unbeaten_medals = false;

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
    	if (UI::MenuItem(base_circle_glacial + "Glacial Medals", "", show_browser_window)) {
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
		//    |   Medal      |  Map1  m  pb |
		//    |   selection  |  Map2  m  pb |
		//    |              |  Map3  m  pb |
		//    |              |  ...         |
		//    |______________|______________|
		//
		//  m - chosen medal
		//  pb - personal best

		UI::PushStyleColor(UI::Col::Separator, base_color);
		UI::PushStyleColor(UI::Col::SeparatorHovered, brighter_color);
		UI::PushStyleColor(UI::Col::SeparatorActive, brightest_color);
		UI::PushStyleColor(UI::Col::Button, base_color);
		UI::PushStyleColor(UI::Col::ButtonHovered, brighter_color);
		UI::PushStyleColor(UI::Col::ButtonActive, brightest_color);

		UI::SetNextWindowSize(window_w, window_h);
		UI::Begin(base_circle_glacial + "Glacial Medals", show_browser_window, UI::WindowFlags::NoCollapse | UI::WindowFlags::NoScrollbar);
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
		
		DrawMedalInfo();

		DrawMapsInfo();

		UI::EndChild(); // "RightContainer"
		UI::End(); // "Glacial Medals"
		UI::PopStyleColor(6); // Separator and Button
	}
	
	void DrawTitle()
	{
		UI::BeginChild("TitleWrapper", vec2(-1, 250));
		
		if (UI::BeginTable("TitleTable", 2)) 
		{
			UI::TableSetupColumn("##Medal", UI::TableColumnFlags::WidthFixed);
			UI::TableSetupColumn("##TitleText", UI::TableColumnFlags::WidthStretch);
	
			UI::TableNextColumn();
			uint padding = 25;
			uint medal_x = 150;
			uint medal_y = 150;
			uint medal_y_offset = 15;
			UI::BeginChild("MedalWrapper", vec2(medal_x + 2 * padding, medal_y + padding + medal_y_offset));
			UI::SetCursorPos(UI::GetCursorPos() + vec2(padding, padding + medal_y_offset));
			UI::Image(logo, vec2(medal_x, medal_y));
			UI::EndChild(); // "MedalWrapper"
	
			UI::TableNextColumn();
			UI::BeginChild("TitleTextWrapper");
			UI::PushFont(base_large_font);
			CenterText(base_circle_glacial + " Glacial Medals", vec2(0, -20));
			UI::PopFont();
	
			string medal_counter_text = base_circle_glacial + " " + CampaignManager::GetMedalsAchievedOverall() + 
										" / " + CampaignManager::GetMedalsTotalOverall();
			UI::PushFont(base_normal_font);
			CenterText(medal_counter_text, vec2(0, 80));
			UI::SameLine();
			UI::PushFont(base_small_font);
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

		if (!CampaignManager::glacial_campaign.medals_loaded)
		{
			UI::Text("Loading...");
			return;
		}
		
		UI::PushStyleColor(UI::Col::TableRowBg, vec4(.25, .25, .25, .2));
		UI::PushFont(base_normal_font);
		if (UI::BeginTable("CampaignsTableList", 4, UI::TableFlags::RowBg | UI::TableFlags::ScrollY | UI::TableFlags::PadOuterX))
		{
			UI::TableSetupColumn("Name", UI::TableColumnFlags::WidthStretch);
			UI::TableSetupColumn("##achieved", UI::TableColumnFlags::WidthFixed);
			UI::TableSetupColumn("Progress   ", UI::TableColumnFlags::WidthFixed);
			UI::TableSetupColumn("##info", UI::TableColumnFlags::WidthFixed);
			UI::TableSetupScrollFreeze(4, 1);

			UI::TableHeadersRow();

			for (uint i = 0; i < MedalType::Count; i++)
			{
				UI::TableNextRow(UI::TableRowFlags::None, 30);
				Campaign@ campaign = CampaignManager::glacial_campaign;
				MedalType medal_type = MedalType(i);

				UI::TableNextColumn(); // "Name"
				UI::AlignTextToFramePadding();
				UI::Text(CampaignManager::medal_names_full[medal_type]);

				UI::TableNextColumn(); // "##achieved"
				if (CampaignManager::medals_achieved[medal_type] == CampaignManager::medals_total[medal_type])
					UI::Text(GetBaseCircle(MedalType(i)));

				UI::TableNextColumn(); // "Progress"
				UI::Text(tostring(" " + CampaignManager::GetMedalsAchieved(medal_type)) + " / " + CampaignManager::GetMedalsTotal(medal_type));

				UI::TableNextColumn(); // "##info"
				UI::PushFont(base_small_font);
				UI::PushID("CampaignInfoButton" + tostring(i));
				if (UI::Button(Icons::InfoCircle))
					CampaignManager::SelectMedalType(MedalType(i));
				UI::PopID();
				UI::PopFont(); // small
			}

			UI::EndTable(); // "CampaignsTableList"
		}
		UI::PopFont(); // normal
		UI::PopStyleColor(); // TableRowBg
		UI::PopStyleColor(3);
	}

	string GetBaseCircle(const MedalType&in medal_type)
	{
		switch (medal_type) {
			case MedalType::Author:
				return base_circle_author;
			case MedalType::Challenge:
				return base_circle_challenge;
			default:
				return base_circle_glacial;
		}
	}

	void DrawMedalInfo()
	{
		if (!user_has_permissions)
			UI::Text("You don't have permissions to play maps locally.\n\nThe \"Play\" buttons will be disabled.");
		UI::BeginChild("MedalInfo", vec2(-1, 150));
		if (UI::BeginTable("MedalInfoTable", 2))
		{
			UI::TableSetupColumn("##name", UI::TableColumnFlags::WidthStretch);
			UI::TableSetupColumn("##progress", UI::TableColumnFlags::WidthStretch);
			
			UI::PushFont(base_large_font);

			UI::TableNextColumn();
			UI::BeginChild("MedalName");
			// center the text
			vec2 container_size = UI::GetContentRegionAvail();
			vec2 campaignname_text_size = Draw::MeasureString(CampaignManager::GetMedalName());
			UI::SetCursorPos((container_size - campaignname_text_size) * 0.5f + vec2(20, 0));
			UI::Text(CampaignManager::GetMedalName()); // full campaign name
			UI::EndChild(); // "MedalName"
			
			UI::TableNextColumn();
			UI::BeginChild("MedalCounter");
			string medalcounter_text = GetBaseCircle(CampaignManager::GetSelectedMedalType())
								+ " " + tostring(CampaignManager::GetMedalsAchieved(CampaignManager::GetSelectedMedalType())) 
								+ " / " + tostring(CampaignManager::GetMedalsTotal(CampaignManager::GetSelectedMedalType()));
			container_size = UI::GetContentRegionAvail();
			vec2 medalcounter_text_size = Draw::MeasureString(medalcounter_text);
			UI::SetCursorPos((container_size - medalcounter_text_size) * 0.5f);
			UI::Text(medalcounter_text);
			UI::EndChild(); // "MedalCounter"

			UI::PopFont(); // large
			UI::EndTable(); // "MedalInfoTable"
		}
		UI::EndChild(); // "MedalInfo"
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
				if (show_only_unbeaten_medals && map.MedalAchieved(CampaignManager::GetSelectedMedalType()))
					continue;

				UI::TableNextRow(UI::TableRowFlags::None, 30);

				UI::TableNextColumn(); // "Name"
				UI::AlignTextToFramePadding();
				UI::Text(Text::OpenplanetFormatCodes(map.name));

				UI::TableNextColumn(); // "##padding"
				UI::TableNextColumn(); // "Medal"
				UI::Text(Time::Format(map.GetMedalTime(CampaignManager::GetSelectedMedalType())));

				UI::TableNextColumn(); // "##achieved"
				if (map.MedalAchieved(CampaignManager::GetSelectedMedalType()))
					UI::Text(GetBaseCircle(CampaignManager::GetSelectedMedalType()));

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
