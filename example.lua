--[[
    ตัวอย่างการใช้งาน Fluent แบบ "แยกฟังชั่นซ้าย-ขวา"
    Library: https://github.com/x9msms/Fluent-Split

    *** สำคัญมาก ***
    Element ที่บันทึกค่าได้ (Toggle / Slider / Dropdown / Input / Keybind / Colorpicker)
    ต้องส่ง 2 อาร์กิวเมนต์:  AddToggle("ชื่อFlag", { Title = "...", ... })
    ส่วน Button กับ Paragraph ส่งแค่ตาราง config:  AddButton({ Title = "...", ... })
    ถ้าส่งแค่ตาราง config ให้ AddToggle จะ error ทันที (หา Title ไม่เจอ)

    *** เกี่ยวกับหน้าตอ ***
    - พื้นหลังทึบสนิท ไม่ใส ไม่มี acrylic/blur (ตัวเลือก Acrylic ไม่มีผลแล้ว)
    - มุมเหลี่ยมทั้งหมด ไม่มีมุมโค้ง
    - UI ทั้งหมดย่อ/ขยาย *พร้อมกัน* กับหน้าต่าง (UIScale) ไม่มีของหลุด/ทับ/เงบ
      ปรับได้ด้วย MinScale / MaxScale / FitMargin ด้านล่าง
]]

local Fluent = loadstring(game:HttpGet("https://raw.githubusercontent.com/x9msms/Fluent-Split/main/main.lua"))()

-- (ไม่บังคับ) addons เดิมของ Fluent ใช้ร่วมกันได้ปกติ
-- local SaveManager      = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
-- local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

local Window = Fluent:CreateWindow({
    Title = "My Script Hub",
    SubTitle = "แยกซ้าย-ขวา",
    TabWidth = 160,
    Size = UDim2.fromOffset(720, 480), -- "ขนาดตอนออกแบบ" — ขนาดที่เห็นจริง = Size × scale

    AutoFit = true,    -- เปิดอยู่แล้วเป็นค่าเริ่มต้น: จอใหญ่ขยายขึ้น, มือถือย่อลง
    MaxScale = 1.6,    -- ขยายสูงสุดบนจอใหญ่ (ต้อง > 1)
    MinScale = 0.75,   -- ย่อต่ำสุด (0.2–1) ถ้าแคบกว่านี้จะลด design size แทน ไม่บีบ content
    FitMargin = 8,     -- เว้นขอบจอ (px)

    -- อย่าใส่ MaxScale = 1 / MinScale = 0.75 แบบตัวอย่างเก่า
    -- เดิมค่าทำให้หน้าต่างเล็กและทับกัน ตอนนี้ใช้ตัวเลขนี้ได้เลย (มีความหมายถูกต้องแล้ว)

    -- Acrylic = true,  -- ไม่มีผลแล้ว  UI ทึบหมดอยู่แล้ว
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl
})

local Tabs = {
    Main     = Window:AddTab({ Title = "Main",     Icon = "home" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
}

local Options = Fluent.Options   -- Options.AutoFarm.Value / Options.WalkSpeed.Value ...

Fluent:Notify({
    Title = "Fluent",
    Content = "โหลดแบบแยกซ้าย-ขวาแล้ว",
    Duration = 4
})

-------------------------------------------------------------------------------
-- แบบที่ 1: แบ่ง Section ซ้าย / ขวา  (แนะนำ)
-------------------------------------------------------------------------------
local Left  = Tabs.Main:AddSection("ฟาร์ม (ซ้าย)", "Left")
local Right = Tabs.Main:AddSection("ผู้เล่น (ขวา)", "Right")

-- Toggle / Slider / Dropdown ต้องส่งชื่อ Flag เป็นอาร์กิวเมนต์แรก
Left:AddToggle("AutoFarm", {
    Title = "Auto Farm",
    Description = "เปิด/ปิดการฟาร์มอัตโนมัติ",
    Default = false,
    Callback = function(Value)
        print("Auto Farm:", Value)
    end
})

Left:AddSlider("WalkSpeed", {
    Title = "Walk Speed",
    Min = 16,
    Max = 200,
    Default = 16,
    Rounding = 0,
    Smooth = true,   -- ทวีนตอนเซ็ตค่า/แตะ (ค่าเริ่มต้น true) มือถือลากได้ลื่นขึ้น
    Callback = function(Value)
        game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = Value
    end
})

-- Button / Paragraph ส่งแค่ตาราง config
Right:AddButton({
    Title = "Teleport to Spawn",
    Description = "วาร์ปกลับจุดเกิด",
    Callback = function()
        print("teleport")
    end
})

Right:AddDropdown("Weapon", {
    Title = "Weapon",
    Values = { "Sword", "Gun", "Bow" },
    Default = 1,
    Callback = function(Value)
        print("เลือกอาวุธ:", Value)
    end
})

Right:AddInput("Webhook", {
    Title = "Webhook",
    Placeholder = "https://discord.com/api/webhooks/...",
    Callback = function(v) print("webhook:", v) end
})

-------------------------------------------------------------------------------
-- แบบที่ 2: สไตล์ Linoria — AddLeftGroupbox / AddRightGroupbox
-------------------------------------------------------------------------------
local L = Tabs.Settings:AddLeftGroupbox("ทั่วไป")
local R = Tabs.Settings:AddRightGroupbox("ขั้นสูง")

L:AddToggle("AntiAFK", {
    Title = "Anti-AFK",
    Default = true,
    Callback = function(v) print("Anti-AFK:", v) end
})

L:AddColorpicker("AccentColor", {
    Title = "Accent Color",
    Default = Color3.fromRGB(96, 205, 255),
    Callback = function(v) print("สี:", v) end
})

R:AddKeybind("ToggleUI", {
    Title = "Toggle UI",
    Mode = "Toggle",
    Default = "LeftControl",
    Callback = function(v) print("keybind:", v) end
})

R:AddInput("PlayerName", {
    Title = "Player Name",
    Callback = function(v) print("name:", v) end
})

R:AddParagraph({
    Title = "ทิป",
    Content = "แถวนี้อยู่ฝั่งขวาอัตโนมัติเพราะอยู่ใน RightGroupbox"
})

-------------------------------------------------------------------------------
-- แบบที่ 3: ใส่ Side ให้ element โดยตรง (ไม่ต้องมี Section)
-------------------------------------------------------------------------------
Tabs.Main:AddParagraph({
    Title = "ทิป",
    Content = "อันนี้ไปอยู่ฝั่งขวา เพราะระบุ Side = 'Right'\nถ้าไม่ระบุ Side จะไปอยู่ฝั่งซ้ายอัตโนมัติ",
    Side = "Right"
})

Tabs.Settings:AddButton({
    Title = "Destroy UI",
    Side = "Right",
    Callback = function()
        Window:Destroy()
    end
})

-- อ่านค่าจาก Options ได้ตามปกติ
-- print(Options.AutoFarm.Value)

-- เลือกแท็บแรกเป็นแท็บตั้งต้น
-- หมายเหตุ: ใน v1.1.0 ฟังก์ชันนี้มีบั๊ก คือจะเลือกแท็บที่ 1 เสมอไม่ว่าจะส่งเลขอะไรไป
Window:SelectTab(1)
