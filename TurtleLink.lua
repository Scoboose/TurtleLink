-- Create main frame to handle events
local f = CreateFrame("Frame", "ItemIDCopyFrame")
local copyFrame = nil

-- Function to get item ID from tooltip
local function GetItemIDFromTooltip()
    if GameTooltip.itemLink then
        local _, _, itemID = string.find(GameTooltip.itemLink, "item:(%d+):%d+:%d+:%d+")
        return itemID
    end
    return nil
end

-- Function to show the copy window with an item ID
local function ShowCopyWindow(itemID)
    if not copyFrame:IsShown() then
        copyFrame:Show()
    end
    local editBox = getglobal("ItemIDCopyEditBox")
    editBox:SetText("|cff00ccffhttps://database.turtle-wow.org/?item=|r|cffffffff"..itemID.."|r")
    editBox:HighlightText()
end

-- Initialize variables
local function Initialize()
    copyFrame = CreateFrame("Frame", "ItemIDCopyCopyFrame", UIParent)
    copyFrame:SetWidth(400)  -- Increased from 200
    copyFrame:SetHeight(60) -- Increased from 100
    copyFrame:SetPoint("CENTER", UIParent, "CENTER")
    copyFrame:SetBackdrop({
        bgFile = "Interface/Tooltips/UI-Tooltip-Background",
        edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
        tile = true,
        tileSize = 16,
        edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 }
    })
    copyFrame:SetBackdropColor(0, 0, 0, 0.8)
    copyFrame:Hide()
    copyFrame:EnableKeyboard(true)
    
    -- Create title text
    local titleText = copyFrame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    titleText:SetPoint("TOP", copyFrame, "TOP", 0, -8)
    titleText:SetText("Turtle Link")
    
    -- Create editbox
    local editBox = CreateFrame("EditBox", "ItemIDCopyEditBox", copyFrame)
    editBox:SetPoint("TOP", titleText, "BOTTOM", 0, -5)
    editBox:SetWidth(360)    -- Increased from 160
    editBox:SetHeight(20)
    editBox:SetAutoFocus(true)
    editBox:SetFontObject(ChatFontNormal)
    editBox:SetScript("OnEscapePressed", function() copyFrame:Hide() end)
    
    -- Create background for editbox
    local editBoxBackground = copyFrame:CreateTexture(nil, "BACKGROUND")
    editBoxBackground:SetTexture(0, 0, 0, 0.5)
    editBoxBackground:SetPoint("TOPLEFT", editBox, "TOPLEFT", -5, 5)
    editBoxBackground:SetPoint("BOTTOMRIGHT", editBox, "BOTTOMRIGHT", 5, -5)
    
    -- Create close button
    local closeButton = CreateFrame("Button", "ItemIDCopyCloseButton", copyFrame, "UIPanelCloseButton")
    closeButton:SetPoint("TOPRIGHT", copyFrame, "TOPRIGHT", 2, 2)
    closeButton:SetScript("OnClick", function() copyFrame:Hide() end)
    
    -- Create keyboard capture frame
    local keyboardFrame = CreateFrame("Frame", "TurtleLinkKeyboardFrame", UIParent)
    keyboardFrame.OnKeyDown = function()
        if arg1 == "C" and IsControlKeyDown() and GameTooltip:IsShown() then
            local itemID = GetItemIDFromTooltip()
            if itemID then
                ShowCopyWindow(itemID)
            end
        end
    end
    keyboardFrame:SetScript("OnKeyDown", keyboardFrame.OnKeyDown)

    -- Hook GameTooltip using old style hooks
    local oldGameTooltipOnShow = GameTooltip:GetScript("OnShow")
    GameTooltip:SetScript("OnShow", function()
        if oldGameTooltipOnShow then oldGameTooltipOnShow() end
        keyboardFrame:EnableKeyboard(true)
    end)

    local oldGameTooltipOnHide = GameTooltip:GetScript("OnHide")
    GameTooltip:SetScript("OnHide", function()
        if oldGameTooltipOnHide then oldGameTooltipOnHide() end
        keyboardFrame:EnableKeyboard(false)
    end)
end

function TurtleLink_OnLoad()
    this:RegisterEvent("ADDON_LOADED")
end

function TurtleLink_OnEvent(event, arg1, arg2, arg3)
    if event == "ADDON_LOADED" and arg1 == "TurtleLink" then
        Initialize()
        DEFAULT_CHAT_FRAME:AddMessage("|cff00ccff[TurtleLink]|r: Initialized. |cffffffffUse Ctrl+C while hovering over items.|r")
    end
end