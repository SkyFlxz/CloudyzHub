-- // ======================================================= //
-- //        CLOUDYZ HUB | PLS DONATE AUTOMATION            //
-- //                  Made by Skflz                         //
-- //              FINAL VERSION - ALL EXECUTORS             //
-- // ======================================================= //

if not game:IsLoaded() then game.Loaded:Wait() end

local Players = game:GetService("Players")
local player = Players.LocalPlayer or Players.PlayerAdded:Wait()
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local TextChatService = game:GetService("TextChatService")
local VirtualUser = game:GetService("VirtualUser")
local TweenService = game:GetService("TweenService")

local myName = "cloudyz"
local configFile = "cloudyz_hub_config.json"
local SCRIPT_URL = "https://pastebin.com/raw/xQkByENf"

-- GAME IDS - UPDATED
-- Main game has TWO separate Place IDs
local NORMAL_PLACE_ID = 8737602449      -- Normal servers
local VC_PLACE_ID = 8943822011          -- VC servers (separate place in same game universe)

-- STAND COORDINATES
local STAND_POINTS = {
    Vector3.new(138.152, 0.98, 382.785), Vector3.new(126.894, 0.98, 376.285),
    Vector3.new(115.635, 0.98, 369.785), Vector3.new(104.369, 0.98, 358.496),
    Vector3.new(97.869, 0.98, 347.237),  Vector3.new(91.369, 0.98, 335.979),
    Vector3.new(87.293, 0.98, 323.160),  Vector3.new(87.293, 0.98, 291.160),
    Vector3.new(91.401, 0.98, 279.169),  Vector3.new(97.901, 0.98, 267.910),
    Vector3.new(104.401, 0.98, 256.652), Vector3.new(115.689, 0.98, 245.386),
    Vector3.new(126.948, 0.98, 238.886), Vector3.new(138.206, 0.98, 232.386),
    Vector3.new(195.017, 0.98, 232.417), Vector3.new(206.275, 0.98, 238.917),
    Vector3.new(217.533, 0.98, 245.417), Vector3.new(228.799, 0.98, 256.706),
    Vector3.new(235.299, 0.98, 267.964), Vector3.new(241.799, 0.98, 279.223),
    Vector3.new(245.799, 0.98, 291.223), Vector3.new(245.799, 0.98, 323.223),
    Vector3.new(241.768, 0.98, 336.033), Vector3.new(235.268, 0.98, 347.292),
    Vector3.new(228.768, 0.98, 358.550), Vector3.new(217.479, 0.98, 369.816),
    Vector3.new(206.221, 0.98, 376.316), Vector3.new(194.962, 0.98, 382.816)
}

local DANCE_EMOTES = {"/e dance", "/e dance2", "/e dance3"}

local settings = {
    antiAfk = false,
    autoChat = false,
    autoChatInterval = 300,
    autoThanks = false,
    thanksMessage = "ty man appreciate",
    autoHop = false,
    hopInterval = 900,
    autoClaim = true,
    autoDance = false,
    danceInterval = 10,
    serverType = "normal",
    autoRejoinEnabled = false,
    minPlayersRejoin = 5,
    chatMessages = {
        "Anyone wanna buy premium coconut?",
        "Coconut Shop on My Booth!",
        "Thirsty? Coconut here as always!",
        "Cheap Coconut Here!!",
        "Always buy Coconut from the original Booth."
    },
    hasClaimedBooth = false
}

local lastChatMessage = ""
local statusLabel = nil
local MainFrame = nil
local MiniFrame = nil
local currentTab = "Main"
local tabFrames = {}
local isHopping = false

-- ============================================
-- CONFIG SYSTEM
-- ============================================
local function save()
    pcall(function()
        if writefile then
            writefile(configFile, HttpService:JSONEncode(settings))
        end
    end)
end

local function load()
    pcall(function()
        if isfile and isfile(configFile) then
            local d = HttpService:JSONDecode(readfile(configFile))
            for k,v in pairs(d) do
                settings[k] = v
            end
        end
    end)
end
load()

-- ============================================
-- UTILITY FUNCTIONS
-- ============================================
local function getRandomMessage()
    local available = {}
    for _, msg in ipairs(settings.chatMessages) do
        if msg ~= lastChatMessage then
            table.insert(available, msg)
        end
    end
    if #available == 0 then available = settings.chatMessages end
    local selected = available[math.random(1, #available)]
    lastChatMessage = selected
    return selected
end

local function say(msg)
    if not msg or msg == "" then return end
    pcall(function()
        if TextChatService.ChatVersion == Enum.ChatVersion.TextChatService then
            local ch = TextChatService.TextChannels:FindFirstChild("RBXGeneral")
            if ch then ch:SendAsync(msg) end
        else
            game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents.SayMessageRequest:FireServer(msg, "All")
        end
    end)
end

local function updateStatus(text)
    if statusLabel then
        statusLabel.Text = "Status: " .. text
    end
    print("📊 " .. text)
end

-- ============================================
-- UNIVERSAL DONATE FUNCTION (WORKS ON ALL EXECUTORS)
-- ============================================
local function fireButton(button)
    local fired = false
    
    -- Method 1: Try getconnections (Synapse, Script-Ware, etc)
    pcall(function()
        if getconnections then
            for _, connection in pairs(getconnections(button.MouseButton1Click)) do
                connection:Fire()
                fired = true
            end
        end
    end)
    
    -- Method 2: Try firesignal (some executors)
    if not fired then
        pcall(function()
            if firesignal then
                firesignal(button.MouseButton1Click)
                fired = true
            end
        end)
    end
    
    -- Method 3: Try direct VIM click (Xeno, Fluxus, etc)
    if not fired then
        pcall(function()
            local VIM = game:GetService("VirtualInputManager")
            local pos = button.AbsolutePosition
            local size = button.AbsoluteSize
            VIM:SendMouseButtonEvent(pos.X + size.X/2, pos.Y + size.Y/2, 0, true, game, 0)
            task.wait(0.1)
            VIM:SendMouseButtonEvent(pos.X + size.X/2, pos.Y + size.Y/2, 0, false, game, 0)
            fired = true
        end)
    end
    
    -- Method 4: Fallback - try calling the function directly
    if not fired then
        pcall(function()
            if button.Activated then
                button.Activated:Fire()
            end
        end)
    end
end

local function donateToOwner()
    updateStatus("Opening Gift Menu...")
    task.spawn(function()
        local success, err = pcall(function()
            local playerGui = player:WaitForChild("PlayerGui", 10)
            if not playerGui then 
                updateStatus("❌ PlayerGui not found!")
                return 
            end
            
            -- STEP 1: Find Gift Button
            updateStatus("Looking for Gift button...")
            local giftButton = nil
            
            -- Wait for MainGUI to load
            local mainGui = playerGui:WaitForChild("MainGUI", 5)
            if not mainGui then
                updateStatus("❌ MainGUI not found!")
                return
            end
            
            -- Wait for NavigationButtons
            local navButtons = mainGui:WaitForChild("NavigationButtons", 5)
            if not navButtons then
                updateStatus("❌ NavigationButtons not found!")
                return
            end
            
            -- Find Gift button by name or icon
            for _, child in pairs(navButtons:GetChildren()) do
                if child:IsA("ImageButton") or child:IsA("TextButton") then
                    local name = child.Name:lower()
                    if name:find("gift") or name == "gift" or name == "gifts" then
                        giftButton = child
                        break
                    end
                end
            end
            
            if not giftButton then
                updateStatus("❌ Gift button not found!")
                print("Available buttons in NavigationButtons:")
                for _, child in pairs(navButtons:GetChildren()) do
                    if child:IsA("GuiObject") then
                        print("  - " .. child.Name)
                    end
                end
                return
            end
            
            print("✅ Found Gift Button: " .. giftButton.Name)
            updateStatus("Clicking Gift button...")
            fireButton(giftButton)
            task.wait(2.5)
            
            -- STEP 2: Find username textbox
            updateStatus("Looking for username field...")
            local usernameBox = nil
            
            for attempt = 1, 10 do
                for _, gui in pairs(playerGui:GetDescendants()) do
                    if gui:IsA("TextBox") then
                        -- Check if visible (with pcall to avoid errors)
                        local isVisible = false
                        pcall(function()
                            isVisible = gui.Visible and gui.Parent and gui.Parent.Visible
                        end)
                        
                        if isVisible then
                            local placeholder = gui.PlaceholderText and gui.PlaceholderText:lower() or ""
                            
                            if placeholder:find("username") or placeholder:find("player") or placeholder:find("name") then
                                usernameBox = gui
                                break
                            end
                        end
                    end
                end
                if usernameBox then break end
                task.wait(0.5)
            end
            
            if not usernameBox then
                updateStatus("❌ Username field not found")
                print("Could not find username textbox - Gift menu might not be open")
                return
            end
            
            print("✅ Found Username Box: " .. usernameBox.Name)
            updateStatus("Entering username...")
            
            -- Clear and enter username
            usernameBox.Text = ""
            task.wait(0.1)
            usernameBox.Text = "iwantshidouplz"
            
            -- Try to trigger text changed events
            pcall(function()
                if getconnections then
                    for _, connection in pairs(getconnections(usernameBox:GetPropertyChangedSignal("Text"))) do
                        connection:Fire()
                    end
                end
            end)
            
            task.wait(1.5)
            
            -- STEP 3: Find GIFT send button
            updateStatus("Looking for GIFT button...")
            local giftSendButton = nil
            
            for _, btn in pairs(playerGui:GetDescendants()) do
                if btn:IsA("TextButton") or btn:IsA("ImageButton") then
                    -- Check visibility
                    local isVisible = false
                    pcall(function()
                        isVisible = btn.Visible and btn.Parent and btn.Parent.Visible
                    end)
                    
                    if isVisible then
                        local btnText = btn.Text and btn.Text:upper() or ""
                        local btnName = btn.Name:upper()
                        
                        -- Make sure it's NOT the navigation button
                        local isNavButton = false
                        pcall(function()
                            isNavButton = btn.Parent.Name == "NavigationButtons"
                        end)
                        
                        if (btnText == "GIFT" or btnName:find("GIFT")) and not isNavButton then
                            giftSendButton = btn
                            break
                        end
                    end
                end
            end
            
            if not giftSendButton then
                updateStatus("❌ GIFT send button not found")
                print("Could not find GIFT button - username might be invalid")
                return
            end
            
            print("✅ Found GIFT Send Button: " .. giftSendButton.Name)
            updateStatus("Clicking GIFT button...")
            fireButton(giftSendButton)
            
            task.wait(1)
            updateStatus("✅ Donate window ready! ❤️")
            print("💝 Thank you for supporting the creator!")
            print("💝 Now select amount and click confirm!")
        end)
        
        if not success then
            updateStatus("❌ Error: " .. tostring(err))
            print("Donate function error: " .. tostring(err))
        end
    end)
end

-- ============================================
-- FIXED SERVER HOP WITH CORRECT VC PLACE ID
-- ============================================
local function serverHop()
    if isHopping then return end
    isHopping = true
    
    settings.autoClaim = true
    settings.hasClaimedBooth = false
    save()
    
    local serverType = settings.serverType == "vc" and "VC" or "Normal"
    updateStatus("🔍 Searching for " .. serverType .. " server...")
    
    local targetPlaceId = settings.serverType == "vc" and VC_PLACE_ID or NORMAL_PLACE_ID
    
    local servers = {}
    local success = pcall(function()
        local url = "https://games.roblox.com/v1/games/" .. targetPlaceId .. "/servers/Public?sortOrder=Desc&limit=100"
        local response = game:HttpGet(url)
        local data = HttpService:JSONDecode(response).data
        
        for _, v in ipairs(data) do
            if v.maxPlayers > v.playing + 1 and v.id ~= game.JobId then
                table.insert(servers, v.id)
            end
        end
    end)
    
    if not success or #servers == 0 then
        updateStatus("❌ No " .. serverType .. " servers found, retrying...")
        isHopping = false
        task.wait(5)
        serverHop()
        return
    end
    
    if queue_on_teleport then
        local reExecuteScript = string.format([[
            task.wait(2)
            loadstring(game:HttpGet("%s"))()
        ]], SCRIPT_URL)
        queue_on_teleport(reExecuteScript)
    end
    
    local randomServer = servers[math.random(1, #servers)]
    print("🔄 Hopping to " .. serverType .. " server...")
    print("🔄 Place ID: " .. targetPlaceId)
    print("🔄 Server ID: " .. randomServer)
    TeleportService:TeleportToPlaceInstance(targetPlaceId, randomServer)
end

-- ============================================
-- BOOTH CLAIM SYSTEM
-- ============================================
local function checkIfPlayerHasBooth()
    local boothFolder = workspace:FindFirstChild("BoothModels")
    if not boothFolder then return false end
    
    for _, booth in pairs(boothFolder:GetChildren()) do
        local ownerId = booth:GetAttribute("OwnerId")
        if ownerId and ownerId == player.UserId then
            return true
        end
    end
    return false
end

local function pressAndHoldE(duration)
    pcall(function()
        local VIM = game:GetService("VirtualInputManager")
        VIM:SendKeyEvent(true, Enum.KeyCode.E, false, game)
        task.wait(duration or 3)
        VIM:SendKeyEvent(false, Enum.KeyCode.E, false, game)
    end)
end

local function autoClaimLogic()
    if not settings.autoClaim then return end
    if settings.hasClaimedBooth then return end
    if isHopping then return end
    
    if checkIfPlayerHasBooth() then
        settings.hasClaimedBooth = true
        settings.autoClaim = false
        save()
        updateStatus("✅ You already have a booth!")
        return
    end
    
    local boothFolder = workspace:FindFirstChild("BoothModels")
    if not boothFolder then return end
    
    local char = player.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    local closestBooth = nil
    local closestDistance = math.huge
    
    for _, booth in pairs(boothFolder:GetChildren()) do
        if not booth:GetAttribute("OwnerId") or booth:GetAttribute("OwnerId") == 0 then
            local boothPart = booth.PrimaryPart or booth:FindFirstChildWhichIsA("BasePart", true)
            
            if boothPart then
                for _, point in pairs(STAND_POINTS) do
                    if (boothPart.Position - point).Magnitude < 25 then
                        local distance = (hrp.Position - boothPart.Position).Magnitude
                        
                        if distance < closestDistance then
                            closestDistance = distance
                            closestBooth = booth
                        end
                        break
                    end
                end
            end
        end
    end
    
    if closestBooth then
        local boothPart = closestBooth.PrimaryPart or closestBooth:FindFirstChildWhichIsA("BasePart", true)
        
        if boothPart then
            updateStatus("Claiming booth...")
            
            hrp.CFrame = boothPart.CFrame * CFrame.new(0, 1.5, 3.5)
            task.wait(0.5)
            
            pressAndHoldE(3)
            task.wait(2)
            
            if checkIfPlayerHasBooth() then
                settings.hasClaimedBooth = true
                settings.autoClaim = false
                updateStatus("✅ Booth Claimed!")
                save()
                
                task.wait(1)
                if hrp and boothPart then
                    hrp.CFrame = boothPart.CFrame * CFrame.new(-5, 2, -5)
                end
                return
            end
        end
    end
end

-- ============================================
-- GUI CREATION
-- ============================================
if CoreGui:FindFirstChild("CloudyzHub") then 
    CoreGui.CloudyzHub:Destroy() 
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "CloudyzHub"
ScreenGui.Parent = CoreGui
ScreenGui.ResetOnSpawn = false

-- MINI UI
MiniFrame = Instance.new("Frame")
MiniFrame.Size = UDim2.new(0, 60, 0, 60)
MiniFrame.Position = UDim2.new(0, 20, 0.5, -30)
MiniFrame.BackgroundColor3 = Color3.fromRGB(25, 30, 40)
MiniFrame.BorderSizePixel = 0
MiniFrame.Active = true
MiniFrame.Visible = false
MiniFrame.Parent = ScreenGui

local MiniCorner = Instance.new("UICorner")
MiniCorner.CornerRadius = UDim.new(0, 15)
MiniCorner.Parent = MiniFrame

local MiniStroke = Instance.new("UIStroke")
MiniStroke.Color = Color3.fromRGB(100, 150, 255)
MiniStroke.Thickness = 2
MiniStroke.Transparency = 0.4
MiniStroke.Parent = MiniFrame

local MiniButton = Instance.new("TextButton")
MiniButton.Size = UDim2.new(1, 0, 1, 0)
MiniButton.BackgroundTransparency = 1
MiniButton.Text = "☁️"
MiniButton.TextSize = 32
MiniButton.TextColor3 = Color3.fromRGB(150, 200, 255)
MiniButton.Parent = MiniFrame

-- Dragging with boundaries
local dragging, dragInput, dragStart, startPos
local function updateMiniDrag(input)
    local delta = input.Position - dragStart
    local screenSize = workspace.CurrentCamera.ViewportSize
    local frameSize = MiniFrame.AbsoluteSize
    
    local finalX = math.clamp(startPos.X.Offset + delta.X, 0, screenSize.X - frameSize.X)
    local finalY = math.clamp(startPos.Y.Offset + delta.Y, 0, screenSize.Y - frameSize.Y)
    
    MiniFrame.Position = UDim2.new(0, finalX, 0, finalY)
end

MiniButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MiniFrame.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

MiniButton.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        updateMiniDrag(input)
    end
end)

MiniButton.MouseButton1Click:Connect(function()
    if not dragging then
        MiniFrame.Visible = false
        if MainFrame then
            MainFrame.Visible = true
        end
    end
end)

-- MAIN FRAME
MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 420, 0, 640)
MainFrame.Position = UDim2.new(0.5, -210, 0.5, -320)
MainFrame.BackgroundColor3 = Color3.fromRGB(18, 22, 30)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 16)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(100, 150, 255)
MainStroke.Thickness = 2
MainStroke.Transparency = 0.5
MainStroke.Parent = MainFrame

local Gradient = Instance.new("UIGradient")
Gradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(25, 30, 40)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(15, 18, 25))
}
Gradient.Rotation = 45
Gradient.Parent = MainFrame

local Watermark = Instance.new("TextLabel")
Watermark.Size = UDim2.new(1, 0, 0, 25)
Watermark.Position = UDim2.new(0, 0, 0, -30)
Watermark.BackgroundTransparency = 1
Watermark.Text = "Made by Skflz"
Watermark.TextColor3 = Color3.fromRGB(150, 200, 255)
Watermark.TextTransparency = 0.4
Watermark.Font = Enum.Font.GothamBold
Watermark.TextSize = 16
Watermark.Parent = MainFrame

local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 70)
Header.BackgroundColor3 = Color3.fromRGB(30, 35, 45)
Header.BorderSizePixel = 0
Header.Parent = MainFrame

local HeaderCorner = Instance.new("UICorner")
HeaderCorner.CornerRadius = UDim.new(0, 16)
HeaderCorner.Parent = Header

local CloudIcon = Instance.new("TextLabel")
CloudIcon.Size = UDim2.new(0, 60, 0, 60)
CloudIcon.Position = UDim2.new(0, 10, 0, 5)
CloudIcon.BackgroundTransparency = 1
CloudIcon.Text = "☁️"
CloudIcon.TextSize = 36
CloudIcon.Parent = Header

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -140, 0, 30)
Title.Position = UDim2.new(0, 75, 0, 10)
Title.BackgroundTransparency = 1
Title.Text = "CLOUDYZ HUB"
Title.TextColor3 = Color3.fromRGB(150, 200, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 24
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Header

local Subtitle = Instance.new("TextLabel")
Subtitle.Size = UDim2.new(1, -140, 0, 20)
Subtitle.Position = UDim2.new(0, 75, 0, 40)
Subtitle.BackgroundTransparency = 1
Subtitle.Text = "Pls Donate - Advanced"
Subtitle.TextColor3 = Color3.fromRGB(120, 140, 180)
Subtitle.Font = Enum.Font.Gotham
Subtitle.TextSize = 13
Subtitle.TextXAlignment = Enum.TextXAlignment.Left
Subtitle.Parent = Header

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 50, 0, 50)
CloseBtn.Position = UDim2.new(1, -60, 0, 10)
CloseBtn.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 20
CloseBtn.Parent = Header

local CloseBtnCorner = Instance.new("UICorner")
CloseBtnCorner.CornerRadius = UDim.new(0, 12)
CloseBtnCorner.Parent = CloseBtn

CloseBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
    MiniFrame.Visible = true
end)

local StatusBar = Instance.new("Frame")
StatusBar.Size = UDim2.new(1, -20, 0, 35)
StatusBar.Position = UDim2.new(0, 10, 0, 80)
StatusBar.BackgroundColor3 = Color3.fromRGB(25, 30, 40)
StatusBar.BorderSizePixel = 0
StatusBar.Parent = MainFrame

local StatusCorner = Instance.new("UICorner")
StatusCorner.CornerRadius = UDim.new(0, 10)
StatusCorner.Parent = StatusBar

statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, -20, 1, 0)
statusLabel.Position = UDim2.new(0, 10, 0, 0)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "Status: Ready"
statusLabel.TextColor3 = Color3.fromRGB(100, 255, 150)
statusLabel.Font = Enum.Font.GothamMedium
statusLabel.TextSize = 13
statusLabel.TextXAlignment = Enum.TextXAlignment.Left
statusLabel.Parent = StatusBar

-- TAB SYSTEM
local TabContainer = Instance.new("Frame")
TabContainer.Size = UDim2.new(1, -20, 0, 40)
TabContainer.Position = UDim2.new(0, 10, 0, 125)
TabContainer.BackgroundColor3 = Color3.fromRGB(25, 30, 40)
TabContainer.BorderSizePixel = 0
TabContainer.Parent = MainFrame

local TabContainerCorner = Instance.new("UICorner")
TabContainerCorner.CornerRadius = UDim.new(0, 10)
TabContainerCorner.Parent = TabContainer

local TabLayout = Instance.new("UIListLayout")
TabLayout.FillDirection = Enum.FillDirection.Horizontal
TabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
TabLayout.SortOrder = Enum.SortOrder.LayoutOrder
TabLayout.Padding = UDim.new(0, 5)
TabLayout.Parent = TabContainer

local ContentContainer = Instance.new("Frame")
ContentContainer.Size = UDim2.new(1, -20, 1, -180)
ContentContainer.Position = UDim2.new(0, 10, 0, 175)
ContentContainer.BackgroundTransparency = 1
ContentContainer.ClipsDescendants = true
ContentContainer.Parent = MainFrame

local function createTab(name, icon, order)
    local TabButton = Instance.new("TextButton")
    TabButton.Size = UDim2.new(0, 120, 1, -10)
    TabButton.Position = UDim2.new(0, 5, 0, 5)
    TabButton.BackgroundColor3 = name == "Main" and Color3.fromRGB(80, 150, 255) or Color3.fromRGB(40, 45, 55)
    TabButton.Text = icon .. " " .. name
    TabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    TabButton.Font = Enum.Font.GothamBold
    TabButton.TextSize = 13
    TabButton.LayoutOrder = order
    TabButton.Parent = TabContainer
    
    local TabBtnCorner = Instance.new("UICorner")
    TabBtnCorner.CornerRadius = UDim.new(0, 8)
    TabBtnCorner.Parent = TabButton
    
    local TabFrame = Instance.new("ScrollingFrame")
    TabFrame.Name = name .. "Tab"
    TabFrame.Size = UDim2.new(1, 0, 1, 0)
    TabFrame.Position = name == "Main" and UDim2.new(0, 0, 0, 0) or UDim2.new(1, 0, 0, 0)
    TabFrame.BackgroundTransparency = 1
    TabFrame.BorderSizePixel = 0
    TabFrame.ScrollBarThickness = 4
    TabFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    TabFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
    TabFrame.Visible = name == "Main"
    TabFrame.Parent = ContentContainer
    
    local TabFrameLayout = Instance.new("UIListLayout")
    TabFrameLayout.Padding = UDim.new(0, 10)
    TabFrameLayout.SortOrder = Enum.SortOrder.LayoutOrder
    TabFrameLayout.Parent = TabFrame
    
    tabFrames[name] = TabFrame
    
    TabButton.MouseButton1Click:Connect(function()
        if currentTab == name then return end
        
        for _, btn in pairs(TabContainer:GetChildren()) do
            if btn:IsA("TextButton") then
                btn.BackgroundColor3 = Color3.fromRGB(40, 45, 55)
            end
        end
        TabButton.BackgroundColor3 = Color3.fromRGB(80, 150, 255)
        
        local oldTab = tabFrames[currentTab]
        local newTab = tabFrames[name]
        
        local slideOut = TweenService:Create(oldTab, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Position = UDim2.new(-1, 0, 0, 0)
        })
        
        newTab.Position = UDim2.new(1, 0, 0, 0)
        newTab.Visible = true
        
        local slideIn = TweenService:Create(newTab, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Position = UDim2.new(0, 0, 0, 0)
        })
        
        slideOut:Play()
        slideIn:Play()
        
        slideOut.Completed:Connect(function()
            oldTab.Visible = false
        end)
        
        currentTab = name
    end)
    
    return TabFrame
end

local MainTab = createTab("Main", "🏠", 1)
local ChatTab = createTab("Auto Chat", "💬", 2)
local RejoinTab = createTab("Auto Rejoin", "🔄", 3)

-- GUI ELEMENT CREATORS
local function createToggle(parent, name, key, icon, order)
    local Toggle = Instance.new("Frame")
    Toggle.Size = UDim2.new(1, -5, 0, 50)
    Toggle.BackgroundColor3 = Color3.fromRGB(25, 30, 40)
    Toggle.BorderSizePixel = 0
    Toggle.LayoutOrder = order or 0
    Toggle.Parent = parent
    
    local ToggleCorner = Instance.new("UICorner")
    ToggleCorner.CornerRadius = UDim.new(0, 10)
    ToggleCorner.Parent = Toggle
    
    local IconLabel = Instance.new("TextLabel")
    IconLabel.Size = UDim2.new(0, 40, 1, 0)
    IconLabel.BackgroundTransparency = 1
    IconLabel.Text = icon or "⚙️"
    IconLabel.TextSize = 20
    IconLabel.Parent = Toggle
    
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -110, 1, 0)
    Label.Position = UDim2.new(0, 45, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = name
    Label.TextColor3 = Color3.fromRGB(200, 210, 230)
    Label.Font = Enum.Font.GothamMedium
    Label.TextSize = 14
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Toggle
    
    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(0, 55, 0, 30)
    Button.Position = UDim2.new(1, -65, 0.5, -15)
    Button.BackgroundColor3 = settings[key] and Color3.fromRGB(80, 150, 255) or Color3.fromRGB(50, 55, 65)
    Button.Text = settings[key] and "✓ ON" or "❌ OFF"
    Button.TextColor3 = Color3.fromRGB(255, 255, 255)
    Button.Font = Enum.Font.GothamBold
    Button.TextSize = 12
    Button.Parent = Toggle
    
    local ButtonCorner = Instance.new("UICorner")
    ButtonCorner.CornerRadius = UDim.new(0, 8)
    ButtonCorner.Parent = Button
    
    Button.MouseButton1Click:Connect(function()
        settings[key] = not settings[key]
        Button.Text = settings[key] and "✓ ON" or "❌ OFF"
        Button.BackgroundColor3 = settings[key] and Color3.fromRGB(80, 150, 255) or Color3.fromRGB(50, 55, 65)
        save()
    end)
    
    return Button
end

local function createSelector(parent, name, key, options, icon, order)
    local Selector = Instance.new("Frame")
    Selector.Size = UDim2.new(1, -5, 0, 50)
    Selector.BackgroundColor3 = Color3.fromRGB(25, 30, 40)
    Selector.BorderSizePixel = 0
    Selector.LayoutOrder = order or 0
    Selector.Parent = parent
    
    local SelectorCorner = Instance.new("UICorner")
    SelectorCorner.CornerRadius = UDim.new(0, 10)
    SelectorCorner.Parent = Selector
    
    local IconLabel = Instance.new("TextLabel")
    IconLabel.Size = UDim2.new(0, 40, 1, 0)
    IconLabel.BackgroundTransparency = 1
    IconLabel.Text = icon or "🎯"
    IconLabel.TextSize = 20
    IconLabel.Parent = Selector
    
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -170, 1, 0)
    Label.Position = UDim2.new(0, 45, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = name
    Label.TextColor3 = Color3.fromRGB(200, 210, 230)
    Label.Font = Enum.Font.GothamMedium
    Label.TextSize = 14
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Selector
    
    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(0, 110, 0, 30)
    Button.Position = UDim2.new(1, -120, 0.5, -15)
    Button.BackgroundColor3 = Color3.fromRGB(50, 55, 65)
    Button.Text = settings[key]:upper()
    Button.TextColor3 = Color3.fromRGB(255, 255, 255)
    Button.Font = Enum.Font.GothamBold
    Button.TextSize = 12
    Button.Parent = Selector
    
    local ButtonCorner = Instance.new("UICorner")
    ButtonCorner.CornerRadius = UDim.new(0, 8)
    ButtonCorner.Parent = Button
    
    local currentIndex = 1
    for i, opt in ipairs(options) do
        if opt == settings[key] then
            currentIndex = i
            break
        end
    end
    
    Button.MouseButton1Click:Connect(function()
        currentIndex = currentIndex + 1
        if currentIndex > #options then currentIndex = 1 end
        settings[key] = options[currentIndex]
        Button.Text = settings[key]:upper()
        save()
    end)
    
    return Button
end

local function createInput(parent, name, key, placeholder, isNumber, icon, order)
    local Input = Instance.new("Frame")
    Input.Size = UDim2.new(1, -5, 0, 70)
    Input.BackgroundColor3 = Color3.fromRGB(25, 30, 40)
    Input.BorderSizePixel = 0
    Input.LayoutOrder = order or 0
    Input.Parent = parent
    
    local InputCorner = Instance.new("UICorner")
    InputCorner.CornerRadius = UDim.new(0, 10)
    InputCorner.Parent = Input
    
    local IconLabel = Instance.new("TextLabel")
    IconLabel.Size = UDim2.new(0, 35, 0, 25)
    IconLabel.Position = UDim2.new(0, 8, 0, 5)
    IconLabel.BackgroundTransparency = 1
    IconLabel.Text = icon or "📝"
    IconLabel.TextSize = 16
    IconLabel.Parent = Input
    
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -50, 0, 25)
    Label.Position = UDim2.new(0, 45, 0, 5)
    Label.BackgroundTransparency = 1
    Label.Text = name
    Label.TextColor3 = Color3.fromRGB(200, 210, 230)
    Label.Font = Enum.Font.GothamMedium
    Label.TextSize = 13
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Input
    
    local TextBox = Instance.new("TextBox")
    TextBox.Size = UDim2.new(1, -20, 0, 30)
    TextBox.Position = UDim2.new(0, 10, 0, 35)
    TextBox.BackgroundColor3 = Color3.fromRGB(35, 40, 50)
    TextBox.Text = tostring(settings[key] or "")
    TextBox.PlaceholderText = placeholder
    TextBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    TextBox.PlaceholderColor3 = Color3.fromRGB(120, 130, 150)
    TextBox.Font = Enum.Font.Gotham
    TextBox.TextSize = 13
    TextBox.ClearTextOnFocus = false
    TextBox.Parent = Input
    
    local TextBoxCorner = Instance.new("UICorner")
    TextBoxCorner.CornerRadius = UDim.new(0, 8)
    TextBoxCorner.Parent = TextBox
    
    TextBox.FocusLost:Connect(function()
        if isNumber then
            settings[key] = tonumber(TextBox.Text) or settings[key]
            TextBox.Text = tostring(settings[key])
        else
            settings[key] = TextBox.Text ~= "" and TextBox.Text or settings[key]
        end
        save()
    end)
    
    return Input
end

local function createButton(parent, text, callback, color, icon, order)
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(1, -5, 0, 50)
    Btn.BackgroundColor3 = color or Color3.fromRGB(80, 150, 255)
    Btn.Text = (icon or "🚀") .. "  " .. text
    Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    Btn.Font = Enum.Font.GothamBold
    Btn.TextSize = 15
    Btn.LayoutOrder = order or 0
    Btn.Parent = parent
    
    local BtnCorner = Instance.new("UICorner")
    BtnCorner.CornerRadius = UDim.new(0, 10)
    BtnCorner.Parent = Btn
    
    local BtnStroke = Instance.new("UIStroke")
    BtnStroke.Color = Color3.fromRGB(255, 255, 255)
    BtnStroke.Thickness = 1
    BtnStroke.Transparency = 0.8
    BtnStroke.Parent = Btn
    
    Btn.MouseButton1Click:Connect(callback)
    
    return Btn
end

-- BUILD MAIN TAB
local order = 0
createToggle(MainTab, "Anti-AFK Protection", "antiAfk", "💤", order)
order = order + 1
createToggle(MainTab, "Auto Claim Booth", "autoClaim", "🏪", order)
order = order + 1
createSelector(MainTab, "Server Type", "serverType", {"normal", "vc"}, "🌐", order)
order = order + 1
createToggle(MainTab, "Auto Thank Donations", "autoThanks", "🙏", order)
order = order + 1
createInput(MainTab, "Thanks Message", "thanksMessage", "ty!", false, "💌", order)
order = order + 1
createButton(MainTab, "DONATE TO OWNER", donateToOwner, Color3.fromRGB(255, 100, 150), "💝", order)
order = order + 1
createButton(MainTab, "SERVER HOP NOW", serverHop, Color3.fromRGB(220, 80, 80), "🌐", order)

-- BUILD AUTO CHAT TAB
order = 0
createToggle(ChatTab, "Enable Auto Chat", "autoChat", "💬", order)
order = order + 1
createInput(ChatTab, "Chat Interval (Seconds)", "autoChatInterval", "300", true, "⏱️", order)
order = order + 1

for i = 1, 5 do
    local chatIndex = i
    local ChatInput = Instance.new("Frame")
    ChatInput.Size = UDim2.new(1, -5, 0, 70)
    ChatInput.BackgroundColor3 = Color3.fromRGB(25, 30, 40)
    ChatInput.BorderSizePixel = 0
    ChatInput.LayoutOrder = order
    ChatInput.Parent = ChatTab
    
    local ChatCorner = Instance.new("UICorner")
    ChatCorner.CornerRadius = UDim.new(0, 10)
    ChatCorner.Parent = ChatInput
    
    local IconLabel = Instance.new("TextLabel")
    IconLabel.Size = UDim2.new(0, 35, 0, 25)
    IconLabel.Position = UDim2.new(0, 8, 0, 5)
    IconLabel.BackgroundTransparency = 1
    IconLabel.Text = "💬"
    IconLabel.TextSize = 16
    IconLabel.Parent = ChatInput
    
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -50, 0, 25)
    Label.Position = UDim2.new(0, 45, 0, 5)
    Label.BackgroundTransparency = 1
    Label.Text = "Chat Message #" .. i
    Label.TextColor3 = Color3.fromRGB(200, 210, 230)
    Label.Font = Enum.Font.GothamMedium
    Label.TextSize = 13
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = ChatInput
    
    local TextBox = Instance.new("TextBox")
    TextBox.Size = UDim2.new(1, -20, 0, 30)
    TextBox.Position = UDim2.new(0, 10, 0, 35)
    TextBox.BackgroundColor3 = Color3.fromRGB(35, 40, 50)
    TextBox.Text = settings.chatMessages[i] or ""
    TextBox.PlaceholderText = "Enter chat message..."
    TextBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    TextBox.PlaceholderColor3 = Color3.fromRGB(120, 130, 150)
    TextBox.Font = Enum.Font.Gotham
    TextBox.TextSize = 13
    TextBox.ClearTextOnFocus = false
    TextBox.Parent = ChatInput
    
    local TextBoxCorner = Instance.new("UICorner")
    TextBoxCorner.CornerRadius = UDim.new(0, 8)
    TextBoxCorner.Parent = TextBox
    
    TextBox.FocusLost:Connect(function()
        if TextBox.Text ~= "" then
            settings.chatMessages[chatIndex] = TextBox.Text
            save()
        end
    end)
    
    order = order + 1
end

createToggle(ChatTab, "Auto Dance", "autoDance", "💃", order)
order = order + 1
createInput(ChatTab, "Dance Interval (Seconds)", "danceInterval", "10", true, "🕒", order)

-- BUILD AUTO REJOIN TAB
order = 0
createToggle(RejoinTab, "Enable Auto Rejoin", "autoRejoinEnabled", "🔄", order)
order = order + 1
createInput(RejoinTab, "Min Players to Rejoin", "minPlayersRejoin", "5", true, "👥", order)
order = order + 1
createToggle(RejoinTab, "Auto Server Hop", "autoHop", "🌐", order)
order = order + 1
createInput(RejoinTab, "Hop Interval (Seconds)", "hopInterval", "900", true, "⏰", order)
order = order + 1
createButton(RejoinTab, "REJOIN SERVER NOW", function()
    settings.autoClaim = true
    settings.hasClaimedBooth = false
    save()
    
    if queue_on_teleport then
        local reExecuteScript = string.format([[
            task.wait(2)
            loadstring(game:HttpGet("%s"))()
        ]], SCRIPT_URL)
        queue_on_teleport(reExecuteScript)
    end
    
    local targetPlaceId = settings.serverType == "vc" and VC_PLACE_ID or NORMAL_PLACE_ID
    TeleportService:Teleport(targetPlaceId)
end, Color3.fromRGB(100, 200, 100), "🔄", order)

-- ============================================
-- BACKGROUND LOOPS
-- ============================================

task.spawn(function()
    while task.wait(5) do
        if settings.autoChat then
            say(getRandomMessage())
            task.wait(settings.autoChatInterval - 5)
        end
    end
end)

task.spawn(function()
    while task.wait(5) do
        if not isHopping then
            if settings.autoClaim and not settings.hasClaimedBooth then
                autoClaimLogic()
            end
        end
    end
end)

task.spawn(function()
    local lastHop = tick()
    while task.wait(30) do
        if settings.autoHop and not isHopping then
            if (tick() - lastHop) > settings.hopInterval then
                lastHop = tick()
                serverHop()
            end
        end
    end
end)

task.spawn(function()
    while task.wait(settings.danceInterval) do
        if settings.autoDance then
            local randomDance = DANCE_EMOTES[math.random(1, #DANCE_EMOTES)]
            say(randomDance)
            task.wait(settings.danceInterval - 1)
        end
    end
end)

task.spawn(function()
    while task.wait(60) do
        if settings.autoRejoinEnabled and not isHopping then
            local playerCount = #Players:GetPlayers()
            if playerCount < settings.minPlayersRejoin then
                print("🔄 Low player count (" .. playerCount .. "), searching for new server...")
                serverHop()
            end
        end
    end
end)

player.Idled:Connect(function()
    if settings.antiAfk then
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end
end)

TextChatService.MessageReceived:Connect(function(m)
    local t = m.Text:lower()
    if settings.autoThanks and t:find("donated") and t:find(myName) then
        task.wait(1)
        say(settings.thanksMessage)
    end
end)

UserInputService.InputBegan:Connect(function(i, p)
    if not p and i.KeyCode == Enum.KeyCode.G then
        MainFrame.Visible = not MainFrame.Visible
        if not MainFrame.Visible then
            MiniFrame.Visible = true
        else
            MiniFrame.Visible = false
        end
    end
end)

print("☁️ ============================================")
print("☁️          CLOUDYZ HUB LOADED                ")
print("☁️ ============================================")
print("📺 Subscribe to Skflz on YouTube!")
print("🏪 Server Type: " .. settings.serverType:upper())
print("📌 Press G to toggle | Click X to minimize")
print("💝 Donate button: Support the creator!")
print("☁️ Normal Place ID: " .. NORMAL_PLACE_ID)
print("☁️ VC Place ID: " .. VC_PLACE_ID)
print("☁️ ============================================")

updateStatus("Ready!")
