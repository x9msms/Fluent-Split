# Fluent — แยกฟังชั่นซ้าย / ขวา (Left / Right columns)

แก้ไขจาก `main.lua` ของ [dawid-scripts/Fluent](https://github.com/dawid-scripts/Fluent) release **v1.1.0**
ให้ Tab หนึ่ง ๆ สามารถแบ่งเนื้อหาเป็น **2 คอลัมน์ (ซ้าย / ขวา)** ได้

| ไฟล์ | ความหมาย |
|---|---|
| `main.lua` | ตัว library ที่แพตช์แล้ว (แทน main.lua เดิมได้เลย) |
| `example.lua` | ตัวอย่างสคริปต์ใช้งานแบบเต็ม |

โหลดด้วย:

```lua
local Fluent = loadstring(game:HttpGet("https://raw.githubusercontent.com/x9msms/Fluent-Split/main/main.lua"))()
```

---

## ⚠️ กฎการเรียก element (สำคัญมาก — พลาดตรงนี้บ่อยสุด)

บิลด์นี้ element แบ่งเป็น 2 กลุ่ม:

| กลุ่ม | วิธีเรียก | ตัว |
|---|---|---|
| **ต้องส่งชื่อ Flag (Idx) ก่อน** | `AddXxx("FlagName", { ... })` | `AddToggle` `AddSlider` `AddDropdown` `AddInput` `AddKeybind` `AddColorpicker` |
| **ส่งแค่ตาราง config** | `AddXxx({ ... })` | `AddButton` `AddParagraph` |

```lua
-- ✅ ถูก
Tab:AddToggle("AutoFarm", { Title = "Auto Farm", Default = false, Callback = function(v) end })
Tab:AddButton({ Title = "Click me", Callback = function() end })

-- ❌ ผิด -> error เกี่ยวกับ Title ทันที (เพราะตาราง config ไปตกในช่อง Idx)
Tab:AddToggle({ Title = "Auto Farm", Default = false })
```

ชื่อ Flag ใช้สำหรับ `Fluent.Options.AutoFarm.Value` และสำหรับ SaveManager

---

## วิธีแยกซ้าย-ขวา (3 แบบ เลือกแบบที่ถนัด)

### แบบที่ 1 — ระบุ `Side` ตอนสร้าง Section (แนะนำ)

```lua
local Left  = Tabs.Main:AddSection("ฟาร์ม", "Left")
local Right = Tabs.Main:AddSection("ผู้เล่น", "Right")

Left:AddToggle("AutoFarm", { Title = "Auto Farm", Default = false, Callback = function(v) end })
Left:AddSlider("Speed", { Title = "Speed", Min = 16, Max = 200, Default = 16, Rounding = 0, Callback = function() end })

Right:AddButton({ Title = "Teleport", Callback = function() end })
Right:AddDropdown("Weapon", { Title = "Weapon", Values = { "Sword", "Gun" }, Default = 1, Callback = function() end })
```

### แบบที่ 2 — ระบุ `Side` ใน element เลย (ไม่ต้องมี Section)

```lua
Tabs.Main:AddToggle("InfJump", { Title = "Infinite Jump", Side = "Right", Callback = function() end })
Tabs.Main:AddButton({ Title = "Reset", Side = "Left", Callback = function() end })
```

### แบบที่ 3 — สไตล์ Linoria

```lua
local L = Tabs.Main:AddLeftGroupbox("Combat")
local R = Tabs.Main:AddRightGroupbox("Player")
L:AddToggle("Aimbot", { Title = "Aimbot", Callback = function() end })
```

---

## รายละเอียดพฤติกรรม

- **Backward compatible 100%** — ถ้าไม่ส่ง `Side` เลย ทุกอย่างเหมือน Fluent เดิมทุกประการ
  (คอลัมน์จะถูกสร้างก็ต่อเมื่อมีการระบุ `Side` ครั้งแรกเท่านั้น)
- เมื่อสร้างคอลัมน์แล้ว element ที่ไม่ระบุ `Side` จะไปอยู่ **คอลัมน์ซ้าย** อัตโนมัติ
- แต่ละคอลัมน์กว้าง `50%` ห่างกัน 12px สูงอัตโนมัติ (scroll อิงคอลัมน์ที่สูงกว่า)
- แนะนำ `Size = UDim2.fromOffset(720, 480)` ให้หน้าต่างกว้างขึ้น

---

## แก้ปัญหา

| อาการ | สาเหตุ | วิธีแก้ |
|---|---|---|
| error `attempt to index nil with 'Title'` / `Button - Missing Title` | ส่งแค่ตาราง config ให้ `AddToggle/AddSlider/...` | เพิ่มชื่อ Flag: `AddToggle("Flag", { ... })` |
| error เดียวกันทั้งที่ส่งครบ | พิมพ์ `title` ตัวเล็ก | ต้องเป็น `Title` (ตัว T ใหญ่) |
| ทุกอย่างไปอยู่ฝั่งซ้ายหมด | พิมพ์ `Side` ผิด (เช่น `"right"`) | ใช้ `"Left"` / `"Right"` ให้ตรง |
| Slider error `Missing rounding value.` | ลืม `Rounding` | ใส่ `Rounding = 0` (หรือ 1, 2) |

---

## แก้ตรงไหนบ้าง (สำหรับคนอยากรู้)

แพตช์แค่ 2 จุดใน bundle ที่ถูก minify ไว้ (ดูได้ใน `../build_patch.py`):

1. **`Components/Tab`**
   - เพิ่ม `Tab:CreateColumns()` → สร้าง `Frame` หลัก (แนวนอน) ที่มีคอลัมน์ `Left` / `Right`
     (แต่ละคอลัมน์มี `UIListLayout` แนวตั้ง + signal `AbsoluteContentSize` เพื่อปรับความสูงอัตโนมัติ)
   - เปลี่ยน `Tab:AddSection(Title)` → `Tab:AddSection(Title, Side)` (`Side = "Left" | "Right"`)
   - เพิ่ม `Tab:AddLeftGroupbox(Title)` / `Tab:AddRightGroupbox(Title)`

2. **`MainModule` (Elements `__namecall`)**
   - ทุก `Add*` อ่านฟิลด์ `Side` จากตาราง config (รองรับทั้งแบบ `(Config)` และ `(Idx, Config)`)
     แล้วเลือก parent ให้เอง

ทดสอบแล้วด้วยการจำลองสภาพแวดล้อม Roblox (ดูโฟลเดอร์ `../testbed`):
17/17 checks ผ่าน และแท็บแบบเดิม (ไม่ใช้ Side) ให้ผลเหมือนไฟล์ต้นฉบับทุกประการ
