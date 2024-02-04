local sChatLog = "";
tChatLogs = {};

function onTabletopInit()
    if Session.IsHost then
        local tButton = {
            sIcon = "icon-chatlog",
            tooltipres = "sidebar_tooltip_chatlog",
            class = "ChatlogExplorer",
        }
        DesktopManager.registerSidebarToolButton(tButton, false)
        if MenuManager then
            MenuManager.addMenuItem("ChatlogExplorer", "", "sidebar_tooltip_chatlog", "Chatlog Explorer");
        end
    end
    OptionsManager.registerOption2(
        "CHATLOGDATEFORMAT",
        false,
        "option_header_chatlog",
        "option_label_CHATLOGDATEFORMAT",
        "option_entry_cycler",
        {
            labels = "option_val_date2|option_val_date3|option_val_date4",
            values = "date2|date3|date4",
            baselabel = "option_val_date1",
            baseval = "date1",
            default = "date1"
        }
    );
end

function parseChatLogs()
    Debug.chat("parsing logs")
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
            nYear, nMonth, nDay, nHour, nMin = string.match(v,
                "Session started at (%d%d%d%d)%-(%d%d)%-(%d%d) / (%d%d):(%d%d)</b>$");
            sSessionDate = formatDate(nYear, nMonth, nDay, nHour, nMin)
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

function formatDate(nYear, nMonth, nDay, nHour, nMin)
    local sDateOption = OptionsManager.getOption("CHATLOGDATEFORMAT");
    if sDateOption == "date1" then
        return tostring(nYear .. "-" .. nMonth .. "-" .. nDay .. " " .. nHour .. ":" .. nMin)
    elseif sDateOption == "date2" then
        return tostring(nMonth .. "/" .. nDay .. "/" .. nYear .. " " .. nHour .. ":" .. nMin)
    elseif sDateOption == "date3" then
        return tostring(nDay .. "." .. nMonth .. "." .. nYear .. " " .. nHour .. ":" .. nMin)
    elseif sDateOption == "date4" then
        return tostring(nDay .. "-" .. nMonth .. "-" .. nYear .. " " .. nHour .. ":" .. nMin)
    else
        return tostring(nYear .. nMonth .. nDay .. nHour .. nMin)
    end
end

function fixhtml(str)
    local sFixedString = ""
    if str then
        sFixedString = string.gsub(str, "&amp;#62;", "&gt;")
        sFixedString = string.gsub(sFixedString, "&amp;#13;", "\r")
        sFixedString = string.gsub(sFixedString, "&amp;#10;", "\n")
        sFixedString = string.gsub(sFixedString, "&amp;#34;", '"')
        sFixedString = string.gsub(sFixedString, "&amp;#35;", "#")
        sFixedString = string.gsub(sFixedString, "&amp;#36;", "$")
        sFixedString = string.gsub(sFixedString, "&amp;#37;", "%")
        sFixedString = string.gsub(sFixedString, "&amp;#38;", "&amp;")
        sFixedString = string.gsub(sFixedString, "&amp;#39;", "'")
    end
    return sFixedString
end

function extractDetails(str)
    local sColor = ""
    local sText = ""
    local sText2 = ""
    local bLink = false
    local sURL = ""
    sColor = string.match(str, '&lt;font color="#+(%w+)')
    sURL = string.match(str, '&lt;a href="([^>]+)">')
    if sURL then
        bLink = true
    end
    if bLink then
        sText = sURL
    else
        sText, sText2 = string.match(str, '[^>]+>(.+)&lt;/font>(.*)')
    end
    if sText then
        sText = fixhtml(sText .. sText2)
    end
    return sColor, bLink, sText
end
