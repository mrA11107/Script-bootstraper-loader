-- ========================================================
-- mrA Hub — Custom Key Gateway with Metatable Kick-Shield
-- ========================================================

local LOOTLABS_LINK = "https://ads.luarmor.net/get_key?for=mrAs_checkpoint-XUglkDZkjcPu"
local KEY_FILE = "mra_hub_key.txt"

-- 1. Create the UI Core
local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local TitleLabel = Instance.new("TextLabel")
local KeyInput = Instance.new("TextBox")
local GetKeyBtn = Instance.new("TextButton")
local SubmitBtn = Instance.new("TextButton")
local UIListLayout = Instance.new("UIListLayout")
local UICorner = Instance.new("UICorner")

ScreenGui.Parent = game:GetService("CoreGui")
ScreenGui.Name = "mrA_Hub_Bootstrapper"

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

-- 2. Main Verification Engine
local function verifyKey(enteredKey)
    SubmitBtn.Text = "Checking database..."
    SubmitBtn.BackgroundColor3 = Color3.fromRGB(41, 128, 185)
    
    getgenv().script_key = enteredKey
    _G.script_key = enteredKey
    shared.script_key = enteredKey
    
    task.spawn(function()
        local rawCode
        pcall(function()
            rawCode = game:HttpGet("https://api.luarmor.net/files/v4/loaders/68446446b71a27c44974258a58424e4c.lua")
        end)
        
        if not rawCode then
            SubmitBtn.Text = "Connection Error"
            SubmitBtn.BackgroundColor3 = Color3.fromRGB(192, 41, 43)
            task.wait(2)
            SubmitBtn.Text = "Verify & Load Script"
            SubmitBtn.BackgroundColor3 = Color3.fromRGB(46, 204, 113)
            return
        end
        
        local compiledFunction = loadstring(rawCode)
        if compiledFunction then
            
            -- ====================================================
            -- ENGINE SHIELD: Global Metatable Interception
            -- ====================================================
            _G.mrA_BlockKick = true
            _G.mrA_KickTriggered = false
            
            local oldNamecall, oldIndex
            pcall(function()
                if hookmetamethod and newcclosure then
                    -- Intercept player:Kick() string queries
                    oldNamecall = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
                        local method = getnamecallmethod()
                        if (method == "Kick" or method == "kick") and _G.mrA_BlockKick then
                            _G.mrA_KickTriggered = true
                            return nil -- Absorbs and kills the call completely
                        end
                        return oldNamecall(self, ...)
                    end))
                    
                    -- Intercept player.Kick(player) functional queries
                    oldIndex = hookmetamethod(game, "__index", newcclosure(function(self, key)
                        if (key == "Kick" or key == "kick") and _G.mrA_BlockKick then
                            return newcclosure(function()
                                _G.mrA_KickTriggered = true
                                return nil
                            end)
                        end
                        return oldIndex(self, key)
                    end))
                end
            end)
            -- ====================================================
            
            -- Run the Luarmor verification script
            task.spawn(function()
                pcall(compiledFunction)
            end)
            
            -- Monitor validation state loop
            local checkTimer = 0
            while checkTimer < 2.5 do
                task.wait(0.1)
                checkTimer = checkTimer + 0.1
                if _G.mrA_KickTriggered then break end
            end
            
            -- Lower the safety shields immediately so normal game elements work safely
            _G.mrA_BlockKick = false
            
            if _G.mrA_KickTriggered then
                -- Key expired / over: Safe self-destruct sequence execution
                if isfile and delfile and isfile(KEY_FILE) then
                    delfile(KEY_FILE)
                end
                
                SubmitBtn.Text = "Invalid Key! Try Again."
                SubmitBtn.BackgroundColor3 = Color3.fromRGB(192, 41, 43)
                task.wait(2)
                SubmitBtn.Text = "Verify & Load Script"
                SubmitBtn.BackgroundColor3 = Color3.fromRGB(46, 204, 113)
            else
                -- Passed completely: Save the key profile configuration locally
                if writefile then
                    writefile(KEY_FILE, enteredKey)
                end
                
                SubmitBtn.Text = "Success!"
                task.wait(0.2)
                if ScreenGui then
                    ScreenGui:Destroy()
                end
            end
        else
            SubmitBtn.Text = "Compilation Error"
            task.wait(2)
            SubmitBtn.Text = "Verify & Load Script"
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
        GetKeyBtn.Text = "Clipboard function blocked"
    end
end)

SubmitBtn.MouseButton1Click:Connect(function()
    local enteredKey = KeyInput.Text:match("^%s*(.-)%s*$")
    if enteredKey and enteredKey ~= "" then
        verifyKey(enteredKey)
    end
end)

-- 4. Auto-Load Verification Setup Check on Boot
if isfile and readfile and isfile(KEY_FILE) then
    local savedKey = readfile(KEY_FILE):match("^%s*(.-)%s*$")
    if savedKey and savedKey ~= "" then
        KeyInput.Text = savedKey
        task.spawn(function()
            verifyKey(savedKey)
        end)
    end
end
