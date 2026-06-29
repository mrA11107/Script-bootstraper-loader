-- ========================================================
-- mrA Hub — Safe Custom Key Gateway (Auto-Login)
-- ========================================================

local CoreGui = game:GetService("CoreGui")
local LOOTLABS_LINK = "https://ads.luarmor.net/get_key?for=mrAs_checkpoint-XUglkDZkjcPu"
local KEY_FILE = "mra_hub_key.txt"
local LUARMOR_LOADER = "https://api.luarmor.net/files/v4/loaders/68446446b71a27c44974258a58424e4c.lua"

-- 1. Create the UI Core
local guiName = "mrA_Hub_Bootstrapper"
if CoreGui:FindFirstChild(guiName) then CoreGui[guiName]:Destroy() end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = guiName
ScreenGui.Parent = CoreGui

local MainFrame = Instance.new("Frame")
local TitleLabel = Instance.new("TextLabel")
local KeyInput = Instance.new("TextBox")
local GetKeyBtn = Instance.new("TextButton")
local SubmitBtn = Instance.new("TextButton")
local UIListLayout = Instance.new("UIListLayout")
local UICorner = Instance.new("UICorner")

MainFrame.Parent = ScreenGui
MainFrame.Size = UDim2.new(0, 320, 0, 240)
MainFrame.Position = UDim2.new(0.5, -160, 0.5, -120)
MainFrame.BackgroundColor3 = Color3.fromRGB(24, 24, 32)
MainFrame.BorderSizePixel = 0
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = MainFrame

UIListLayout.Parent = MainFrame
UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 12)

TitleLabel.Size = UDim2.new(1, 0, 0, 45)
TitleLabel.Text = "mrA Hub — Authentication"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextSize = 18
TitleLabel.Parent = MainFrame

KeyInput.Size = UDim2.new(0, 280, 0, 40)
KeyInput.PlaceholderText = "Paste your key string here..."
KeyInput.Text = ""
KeyInput.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
KeyInput.TextColor3 = Color3.fromRGB(255, 255, 255)
KeyInput.Font = Enum.Font.Gotham
KeyInput.TextSize = 14
KeyInput.Parent = MainFrame
Instance.new("UICorner", KeyInput).CornerRadius = UDim.new(0, 6)

GetKeyBtn.Size = UDim2.new(0, 280, 0, 35)
GetKeyBtn.Text = "Get Key (Copy Link)"
GetKeyBtn.BackgroundColor3 = Color3.fromRGB(230, 126, 34)
GetKeyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
GetKeyBtn.Font = Enum.Font.GothamBold
GetKeyBtn.TextSize = 14
GetKeyBtn.Parent = MainFrame
Instance.new("UICorner", GetKeyBtn).CornerRadius = UDim.new(0, 6)

SubmitBtn.Size = UDim2.new(0, 280, 0, 35)
SubmitBtn.Text = "Verify & Load Script"
SubmitBtn.BackgroundColor3 = Color3.fromRGB(46, 204, 113)
SubmitBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
SubmitBtn.Font = Enum.Font.GothamBold
SubmitBtn.TextSize = 14
SubmitBtn.Parent = MainFrame
Instance.new("UICorner", SubmitBtn).CornerRadius = UDim.new(0, 6)

-- 2. Clean Verification Engine
local function verifyKey(enteredKey)
    SubmitBtn.Text = "Loading mrA Hub..."
    SubmitBtn.BackgroundColor3 = Color3.fromRGB(41, 128, 185)
    
    -- Save the key for next time
    if writefile then
        pcall(function() writefile(KEY_FILE, enteredKey) end)
    end
    
    -- Inject the key so Luarmor sees it
    getgenv().script_key = enteredKey
    
    -- Hide our custom UI
    ScreenGui:Destroy()
    
    -- Execute Luarmor safely
    task.spawn(function()
        local success, err = pcall(function()
            loadstring(game:HttpGet(LUARMOR_LOADER))()
        end)
        
        -- If they put in a completely fake/wrong key, Luarmor will natively handle it 
        -- and popup its own "Invalid Key" message without crashing the game.
        if not success then
            warn("[mrA Hub Bootstrapper] Failed to load Luarmor script: " .. tostring(err))
        end
    end)
end

-- 3. Click Event Handlers
GetKeyBtn.MouseButton1Click:Connect(function()
    if setclipboard then
        setclipboard(LOOTLABS_LINK)
        GetKeyBtn.Text = "Link Copied!"
        task.wait(1.5)
        GetKeyBtn.Text = "Get Key (Copy Link)"
    else
        GetKeyBtn.Text = "Error: Executor blocked clipboard"
        task.wait(1.5)
        GetKeyBtn.Text = "Get Key (Copy Link)"
    end
end)

SubmitBtn.MouseButton1Click:Connect(function()
    local enteredKey = KeyInput.Text:match("^%s*(.-)%s*$")
    if enteredKey and enteredKey ~= "" then
        verifyKey(enteredKey)
    end
end)

-- 4. Auto-Load Setup
if isfile and readfile and isfile(KEY_FILE) then
    local savedKey = ""
    pcall(function() savedKey = readfile(KEY_FILE):match("^%s*(.-)%s*$") end)
    
    if savedKey and savedKey ~= "" then
        KeyInput.Text = savedKey
        -- Automatically try to load if a key is already saved
        verifyKey(savedKey)
    end
end
