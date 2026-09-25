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

## Slider — ปรับให้มือถือใช้ง่ายขึ้น + สมูท

สิ่งที่แก้จากต้นฉบับ:

| ปัญหาเดิม | ที่แก้ |
|---|---|
| จุดจับเล็กมาก (14×14 px) มือถือกดยาก | เพิ่ม **พื้นที่แตะโปร่งใสสูง 26px** ทับรางทั้งเส้น |
| ต้องลากจากจุดเท่านั้น | **แตะที่รางเพื่อกระโดดค่า** ไปตำแหน่งที่แตะได้เลย |
| ลากแล้ว ScrollingFrame ของแท็บแย่งท่าทาง (กึ่งหนึ่งของอาการ "ไม่ติด") | **ล็อกการสครอลล์** ตอนที่ลากแนวนอน ปล่อยนิ้วแล้วปลดล็อก |
| ถ้าปัดแนวตั้งจะถูกล็อกค้าง | ตรวจจับทิศทาง: ขยับแนวนอน > 5px = ลากสไลเดอร์, แนวตั้ง > 14px = ปล่อยให้สครอลล์ |
| จับจุดแล้วกระโดดหนี | จำตำแหน่งที่กดจับ (grab offset) จุดจะไม่กระโดด |
| หยุดลากด้วย `SliderDot.InputEnded` → นิ้วหลุดจากจุดแล้วไม่ fire | ใช้ `UserInputService.InputEnded` แทน (จบทุกกรณี) |
| ค่ากระโดดเป็นขั้นหยาบ (เช่น Min 0 / Max 10 จะกระโดดทีละ 15px) | ตอนลาก จุด+แถบขยับ **ต่อเนื่อง** แต่ค่าที่รายงานยังปัดตาม `Rounding` |
| เซ็ตค่าจากโค้ดแล้วกระตุก | เซ็ตค่าจากโค้ด/แตะ → **ทวีน 0.12 วิ** (ดูนุ่มนวล) |

```lua
Tab:AddSlider("WalkSpeed", {
    Title = "Walk Speed",
    Min = 16, Max = 200, Default = 16, Rounding = 0,
    Smooth = true,        -- ค่าเริ่มต้นคือ true ใส่ false เพื่อปิดการทวีน
    Callback = function(v) end
})
```

---

## แก้ "วงกลมภาพแตก" ของ Slider / Toggle / Colorpicker

ของเดิมใช้ `ImageLabel` โหลดรูปวงกลมจากลิงก์รูปแบบเก่า:

```
http://www.roblox.com/asset/?id=12266946128   <- รูปวงกลม 14x14
```

ลิงก์แบบนี้ในหลาย executor / บนมือถือ **โหลดไม่ได้** → เห็นเป็นรูปแตก สี่เหลี่ยมขาว หรือเบลอ ๆ

วิธีแก้: **เลิกใช้รูป แล้ววาดวงกลมด้วย `Frame` + `UICorner` (CornerRadius = 1,0)** แทน
ไม่ต้องโหลด asset ใด ๆ คมชัดทุกขนาด และยังเข้ากับธีมตามปกติ
แก้ให้ครบทุกจุดที่ใช้รูปนี้: **จุดของ Slider**, **วงกลมของ Toggle**, **วงกลมใน Colorpicker** (ทั้งตัวเลือกสีและแถบความโปร่งใส)

---

## Responsive — หน้าต่างใหญ่ตามจอ ไม่ย่อตัวอักษร

เวอร์ชันก่อนหน้าใช้ `UIScale` ย่อทั้ง UI เหลือ 75% แล้วไปชนกับระบบจัดวางของ Fluent
อาการที่เจอ: **หน้าต่างเล็ก, คอลัมน์ซ้าย/ขวาไม่แยก, องค์ประกอบทับกัน**

ตอนนี้เลิกใช้ `UIScale` แล้ว ตัวอักษรอยู่ที่ขนาดปกติเสมอ และหน้าต่างถูกจัดด้วยพิกเซลจริง:

1. **จอใหญ่ (PC)** — ขยายหน้าต่างได้ถึงประมาณ 1.85 เท่าของขนาดที่ออกแบบ (ไม่เกินจอ)
2. **จอเล็ก (มือถือ)** — ยืดให้เกือบเต็มจอ ทั้งกว้างและสูง ไม่เหลือกล่องเล็ก ๆ กลางจอ
3. จัดกึ่งกลาง และทำใหม่เมื่อหมุนจอ / ย่อขยายหน้าต่าง Roblox
4. บนจอแคบ แถบแท็บด้านซ้ายจะย้ายไปเป็น **แถบเลื่อนด้านบน** เพื่อให้พื้นที่เนื้อหากว้างพอจะวาง 2 คอลัมน์ได้

```lua
local Window = Fluent:CreateWindow({
    Title = "My Hub",
    Size  = UDim2.fromOffset(720, 480), -- ขนาดตอนออกแบบ
    AutoFit = true,   -- default true
    -- MaxScale = 1.4, -- ใส่เมื่ออยากจำกัดการขยายบนจอใหญ่ (ต้องมากกว่า 1)
    -- FitMargin = 8,  -- เว้นขอบจอ (px) default 8
    ...
})
```

> อย่าใส่ `MaxScale = 1` หรือ `MinScale = 0.75` จากตัวอย่างเก่า — ค่านั้นทำให้หน้าต่างเล็ก
> ถ้าไม่อยากให้ปรับขนาดอัตโนมัติเลย ให้ใส่ `AutoFit = false`

### คอลัมน์ซ้าย / ขวา ไม่ทับกัน

คอลัมน์ถูกจัดตำแหน่งเอง (ไม่พึ่ง `UIListLayout` แนวนอน ซึ่งเป็นสาเหตุที่ของเดิมซ้อนทับกัน)
แต่ละฝั่งกว้างครึ่งหนึ่ง ห่างกัน 12px มีเส้นแบ่งบาง ๆ ตรงกลาง

บนมือถือที่คอลัมน์แคบ กล่องกว้าง ๆ (Dropdown / Input) จะ **ย้ายไปอยู่ใต้ชื่อ** แทนที่จะคลุมข้อความ
พอกลับไปจอใหญ่ จะกลับไปอยู่ขวาของแถวเหมือนเดิม

---

## รายละเอียดพฤติกรรม

- **Backward compatible 100%** — ถ้าไม่ส่ง `Side` เลย ทุกอย่างเหมือน Fluent เดิมทุกประการ
  (คอลัมน์จะถูกสร้างก็ต่อเมื่อมีการระบุ `Side` ครั้งแรกเท่านั้น)
- เมื่อสร้างคอลัมน์แล้ว element ที่ไม่ระบุ `Side` จะไปอยู่ **คอลัมน์ซ้าย** อัตโนมัติ
- แต่ละคอลัมน์กว้างครึ่งหนึ่งของพื้นที่เนื้อหา ห่างกัน 12px สูงอัตโนมัติ (scroll อิงคอลัมน์ที่สูงกว่า)
- แนะนำ `Size = UDim2.fromOffset(720, 480)` เป็นขนาดตอนออกแบบ — จอใหญ่จะขยายให้เอง

---

## แก้ปัญหา

| อาการ | สาเหตุ | วิธีแก้ |
|---|---|---|
| error `attempt to index nil with 'Title'` / `Button - Missing Title` | ส่งแค่ตาราง config ให้ `AddToggle/AddSlider/...` | เพิ่มชื่อ Flag: `AddToggle("Flag", { ... })` |
| error เดียวกันทั้งที่ส่งครบ | พิมพ์ `title` ตัวเล็ก | ต้องเป็น `Title` (ตัว T ใหญ่) |
| ทุกอย่างไปอยู่ฝั่งซ้ายหมด | ไม่ได้ส่ง `Side` หรือพิมพ์ผิด (เช่น `"right"`) | ใช้ `AddSection("ชื่อ", "Right")` หรือ `Side = "Right"` |
| ซ้ายกับขวาทับกัน | ใช้ไฟล์เวอร์ชันเก่า (มี UIScale) | โหลด `main.lua` ใหม่ เติม `?t=` ต่อท้ายลิงก์กัน cache |
| หน้าต่างเล็กมาก | ใส่ `MaxScale = 1` / `MinScale = 0.75` จากตัวอย่างเก่า | ลบสองบรรทัดนั้นออก แล้วรันใหม่ |
| Slider error `Missing rounding value.` | ลืม `Rounding` | ใส่ `Rounding = 0` (หรือ 1, 2) |

---

## แก้ตรงไหนบ้าง (สำหรับคนอยากรู้)

แพตช์ 3 จุดใน bundle ที่ถูก minify ไว้ (ดูได้ใน `../build_patch.py`):

1. **`Components/Tab`**
   - เพิ่ม `Tab:CreateColumns()` → สร้าง `Frame` หลัก (แนวนอน) ที่มีคอลัมน์ `Left` / `Right`
     (แต่ละคอลัมน์มี `UIListLayout` แนวตั้ง + signal `AbsoluteContentSize` เพื่อปรับความสูงอัตโนมัติ)
   - เปลี่ยน `Tab:AddSection(Title)` → `Tab:AddSection(Title, Side)` (`Side = "Left" | "Right"`)
   - เพิ่ม `Tab:AddLeftGroupbox(Title)` / `Tab:AddRightGroupbox(Title)`

2. **`MainModule` (Elements `__namecall`)**
   - ทุก `Add*` อ่านฟิลด์ `Side` จากตาราง config (รองรับทั้งแบบ `(Config)` และ `(Idx, Config)`)
     แล้วเลือก parent ให้เอง

3. **`Elements/Slider`**
   - เพิ่ม hit area สูง 26px, แตะเพื่อกระโดดค่า, ล็อกสครอลล์ตอนลากแนวนอน,
     ตรวจจับทิศทางนิ้ว, ใช้ `UIS.InputEnded` แทน `SliderDot.InputEnded`,
     ค่าภาพต่อเนื่องตอนลาก + ทวีน 0.12 วิ (`Smooth`)

4. **`Elements/Slider` + `Elements/Toggle` + `Elements/Colorpicker`**
   - วงกลมทุกจุดเปลี่ยนจาก `ImageLabel` (โหลดรูป asset เก่า) เป็น `Frame` + `UICorner`
     → แก้อาการภาพแตก/เบลอ

5. **`Components/Window`** — ขนาดตามจอ โดยไม่ใช้ `UIScale`
   - `Window:Fit()` ขยายหน้าต่างบนจอใหญ่ และยืดเต็มจอบนมือถือ
     ขับผ่าน Flipper motor (ไม่งั้นตำแหน่ง/ขนาดจะเด้งกลับ)
   - จอแคบกว่า 640px ย้ายแถบแท็บไปด้านบน เพื่อให้คอลัมน์ซ้าย/ขวามีที่

6. **`Components/Tab`** — คอลัมน์ไม่ทับกัน
   - วางซ้าย/ขวาด้วยพิกเซลตรง ๆ (ไม่ใช้ `UIListLayout` แนวนอน)
   - คอลัมน์แคบกว่า 230px จะย้าย Dropdown/Input ไปไว้ใต้ชื่อ ไม่ให้คลุมข้อความ

ทดสอบแล้วด้วยการจำลองสภาพแวดล้อม Roblox (ดูโฟลเดอร์ `../testbed`):
คอลัมน์ไม่ทับกัน, สไลเดอร์, รูปวงกลม, และขนาดตามจอ (PC / มือถือ / แท็บเล็ต) ผ่านทั้งหมด
และแท็บแบบเดิม (ไม่ใช้ Side) ให้ผลเหมือนไฟล์ต้นฉบับทุกประการ
