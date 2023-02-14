local sChatLog = "";
tChatLogs = {};

function onTabletopInit()
		local tButton = {
			sIcon = "icon-chatlog",
			tooltipres = "sidebar_tooltip_chatlog",
			class = "ChatlogExplorer",
		}

		DesktopManager.registerSidebarToolButton(tButton, false)
end

function parseChatLogs()
	local sCampaignFolder = File.getCampaignFolder();
	sChatLog = File.openTextFile(sCampaignFolder .. "chatlog.html");

	local tLines = {};
	sChatLog = string.gsub(sChatLog, "<br />", "");
	for s in sChatLog:gmatch("[^\r\n]+") do
		if string.len(s) > 0 then
			table.insert(tLines, s);
		end
	end
	local sMatch = nil;
	local nCurSession = 0;
	local sSessionDate = "";
	for _, v in ipairs(tLines) do
		sMatch = nil;
		sMatch = string.match(v, "<b>Session started at ");
		if sMatch then
			nCurSession = nCurSession + 1;
			nDate, nHour, nMin =string.match(v, "Session started at (%d%d%d%d%-%d%d%-%d%d) / (%d%d):(%d%d)</b>$");
			sSessionDate = tostring(nDate.."-"..nHour.."-"..nMin);
			nLineNum = 1;
			tChatLogs[nCurSession] = {};
			table.insert(tChatLogs[nCurSession], sSessionDate);
		else
			if tChatLogs[nCurSession] then
				table.insert(tChatLogs[nCurSession], v);
			end
		end
	end
end

