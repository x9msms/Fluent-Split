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
| **ต้องส่งชื่อ Flag (Idx) ก่อน** | `AddXxx("FlagName", { ... })` | `AddToggle``AddSlider``AddDropdown``AddInput``AddKeybind``AddColorpicker` |
| **ส่งแค่ตาราง config** | `AddXxx({ ... })` | `AddButton``AddParagraph` |

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

## หน้าต่างทึบ (ไม่ใส) + กรอบเหลี่ยมไม่โค้ง

### พื้นหลังทึบหมด

ของเดิมพื้นหลังหน้าต่างเป็น acrylice (กระจกฝ้า) ประกอบด้วยหลายชั้นโปร่งใสทับกัน —
`ImageLabel` เงา, `Frame` ขาวโปร่ง 0.4, รูป noise 2 ชั้น, พื้นที่ blur จริง,
แล้วก็มี `BackgroundTransparency = 0.45` และ `0.9` ทับอย่างละชั้น
ผลคือเห็นผ่านไปถึงฉากในเกม ตัวอักษรอ่านยาก บางเครื่องแล้ว acrylic มันกิน FPS

ตอนนี้:

- เลิกสร้าง acrylic blur (`DepthOfFieldEffect` + Part + SpecialMesh) ทั้งหมด
  ตัวเลือก `Acrylic` จึงไม่ส่งผลอะไรแล้ว ใส่หรือไม่ใส่ก็ทึบเท่ากัน
- `AcrylicPaint` เหลือแค่ `Frame` สีเดียวทึบสนิท (`BackgroundTransparency = 0`)
  และยังเก็บ child ชื่อ `Background` ไว้ตามเดิม เพื่อให้ `Fluent:ToggleTransparency()` ใช้ต่อได้
- ไม่มีรูปเงา / noise / gradient โปร่งใสอีกเลย

```lua
-- พื้นหลังทึบ ใช้ธีม AcrylicMain ( Dark = 51,51,51 )
-- ยังปรับได้ตามใจ:
Fluent:ToggleTransparency(false)  -- false = ทึบสนิท (ค่าเริ่มต้นของ UI ใหม่นี้)
Fluent:ToggleTransparency(true)   -- โปร่งเล็กน้อย (0.35) ถ้าอยากเห็นฉากหลัง
```

### มุมเหลี่ยม everywhere

`UICorner` ทุกตัวใน UI ถูกตั้งเป็น `CornerRadius = UDim.new(0, 0)` —
รวมถึงวงกลมของ Slider / Toggle / Colorpicker ที่เดิมใช้ `UDim.new(1, 0)` (กลมสนิท)
ตอนนี้เป็นสี่เหลี่ยมจัตุรัชหมด ทั้งนี้ยังใช้ `Frame` + `UICorner` ตามเดิม
แค่โค้งเป็น 0 จึงไม่ต้องโหลดรูป asset ใด ๆ （เดิมโหลดจาก `roblox.com/asset/?id=12266946128` ที่หลายเครื่องโหลดไม่ได้ → รูปแตก）

---

## Responsive — UI ย่อ/ขยาย **ตาม** หน้าต่าง (ไม่ย่อตัวอักษรเฉย ๆ)

หลักการ: หน้าต่างมี "ขนาดตอนออกแบบ" (design size) เป็นพิกเซลของตัวเองเสมอ
พอจริงบนจอกว้าง/แคบกว่า "ขนาดตอนออกแบบ" ระบบจะคำนวณ **scale ร่วม** แล้วนำไปวางที่ `UIScale`
บน `Window.Root` — ทุกอย่างข้างใน (ตัวอักษร, ปุ่ม, คอลัมน์, วงกลม) ย่อ/ขยายพร้อมกัน
จึงไม่มีกรณีที่ "หน้าต่างเล็กลงแต่ของข้างในไม่เล็อลง → เงบ / ทับ / เห็นไม่ครบ"

1. **จอใหญ่ (PC)** — ขยายได้ถึง `MaxScale` (ค่าเริ่มต้น **1.6**) เท่าของขนาดที่ออกแบบ ไม่เกินจอ
2. **จอเล็ก (มือถือ)** — ย่อลงจนเหลือ `MinScale` (ค่าเริ่มต้น **0.75**) เท่า
   ถ้าจอแคบกว่าจะให้ scale ต่ำกว่านั้น จะ**ลด "ขนาดตอนออกแบบ" แทน** เพื่อให้ layout เข้าโหมดแคบ (คอลัมน์ซ้อน / Dropdown ลงใต้ชื่อ)
   แทนที่จะบีบ content ที่มีขนาดพิกเซลตายตัวให้เหลือแคบ ๆ จนมองไม่เห็นฟังชั่น
3. **ลากมุมหน้าต่างเอง** — ย่อ/ขยายตามคำด้วย scale เดิม (ไม่เคยต่ำกว่า `MinScale`)
   ปล่อยมือแล้ววิ้งกลับมาตรงขนาด scale ใหม่ (ไม่งั้นของข้างในจะ "เด้ง" แล้วทับกัน)
4. จอที่สูงกว่ากว้าง (มือถือตั้ง) — ใช้ความสูงว่างเติมให้หน้าต่างยาวขึ้น ไม่เป็นแถบเล็ก ๆ ลอยกลางจอ
5. จัดกึ่งกลาง และทำใหม่เมื่อหมุนจอ / ย่อขยายหน้าต่าง Roblox
6. บนจอแคบกว่า 640px (วัดเป็นพิกเซลของหน้าต่าง) แถบแท็บด้านซ้ายจะเลื่อนไปเป็น **แถวด้านบน**

```lua
local Window = Fluent:CreateWindow({
    Title = "My Hub",
    SubTitle = "แยกซ้าย-ขวา",
    TabWidth = 160,
    Size  = UDim2.fromOffset(720, 480), -- ขนาดตอนออกแบบ (พิกเซลอ้างอิง)
    AutoFit  = true,   -- default true  ปิดถ้าไม่อยากให้ปรับเองเลย
    MaxScale = 1.6,    -- ขยายสูงสุดตอนจอใหญ่ (ต้อง > 1)
    MinScale = 0.75,   -- ย่อต่ำสุด (0.2 - 1)  ต่ำกว่านี้จะลด design size แทน
    FitMargin = 8,     -- เว้นขอบจอ (px)
    -- Acrylic = true, -- ไม่มีผลแล้ว  UI ทึบหมดอยู่แล้ว
    Theme = "Dark",
    MinimizeKey = Enum.Keycode.LeftControl
})
```

> `Size` คือ **พิกเซลตอนออกแบบ** ไม่ใช่ขนาดที่เห็นบนจอ
> ขนาดที่เห็นจริง = `Size × scale` และ scale คิดจาก `viewport` อัตโนมัติ

### คอลัมน์ซ้าย / ขวา ไม่ทับกัน

คอลัมน์ถูกจัดตำแหน่งเอง (ไม่พึ่ง `UIListLayout` แนวนอน ซึ่งเป็นสาเหตุที่ของเดิมซ้อนทับกัน)
แต่ละฝั่งกว้างครึ่งหนึ่ง ห่างกัน 12px มีเส้นแบ่งบาง ๆ ตรงกลาง
ทุกการวัดความกว้างคอลัมน์ใช้ **พิกเซลของหน้าต่าง** (หาร scale ออกก่อน) เพื่อให้การตัดสินใจ
"คอลัมน์แคบ → ยอด Dropdown ลงใต้ชื่อ" ยังตรงเวลาแม้หน้าต่างจะถูกลด scale อยู่

บนมือถือที่คอลัมน์แคบ กล่องกว้าง ๆ (Dropdown / Input) จะ **ยุดไปอยู่ใต้ชื่อ** แทนที่จะคลุมข้อความ
พอกลับไปจอใหญ่ จะกลับไปอยู่ขวาของแถวเหมือนเดิม

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

## รายละเอียดพฤติกรรม

- **Backward compatible 100%** — ถ้าไม่ส่ง `Side` เลย ทุกอย่างเหมือน Fluent เดิมทุกประการ
  (คอลัมน์จะถูกสร้างก็ต่อเมื่อมีการระบุ `Side` ครั้งแรกเท่านั้น)
- เมื่อสร้างคอลัมน์แล้ว element ที่ไม่ระบุ `Side` จะไปอยู่ **คอลัมน์ซ้าย** อัตโนมัติ
- แต่ละคอลัมน์กว้างครึ่งหนึ่งของพื้นที่เนื้อหา ห่างกัน 12px สูงอัตโนมัติ (scroll อิงคอลัมน์ที่สูงกว่า)
- แนะนำ `Size = UDim2.fromOffset(720, 480)` เป็นขนาดตอนออกแบบ — จอใหญ่จะขยายให้เอง
- `Window.Scale` = scale ที่ใช้อยู่ (อ่านได้ จาก `Window.UIScale.Scale` ก็ได้)
- `Window:Fit()` เรียกใหม่ได้ทุกเมื่อ (เช่น หลังจากเปลี่ยน `Size` เอง)

---

## แก้ปัญหา

| อาการ | สาเหตุ | วิธีแก้ |
|---|---|---|
| error `attempt to index nil with 'Title'` / `Button - Missing Title` | ส่งแค่ตาราง config ให้ `AddToggle/AddSlider/...` | เพิ่มชื่อ Flag: `AddToggle("Flag", { ... })` |
| error เดียวกันทั้งที่ส่งครบ | พิมพ์ `title` ตัวเล็ก | ต้องเป็น `Title` (ตัว T ใหญ่) |
| ทุกอย่างไปอยู่ฝั่งซ้ายหมด | ไม่ได้ส่ง `Side` หรือพิมพ์ผิด (เช่น `"right"`) | ใช้ `AddSection("ชื่อ", "Right")` หรือ `Side = "Right"` |
| ซ้ายกับขวาทับกัน | ใช้ไฟล์เวอร์ชันเก่า | โหลด `main.lua` ใหม่ เติม `?t=` ต่อท้ายลิงก์กัน cache |
| หน้าต่างเล็กเกิน / ใหญ่เกิน | scale ไม่ถูกใจ | ปรับ `MinScale` / `MaxScale` / `FitMargin` หรือใส่ `AutoFit = false` |
| อยากได้ขนาดตายตัว | ระบบปรับเองตลอด | ใส่ `AutoFit = false` แล้วกำหนด `Size` เอง |
| Slider error `Missing rounding value.` | ลืม `Rounding` | ใส่ `Rounding = 0` (หรือ 1, 2) |
| ตัวอักษรเล็กไปบนมือถือ | `MinScale` ต่ำเกินไป | เพิ่ม `MinScale` (เช่น `0.85`) — ระบบจะลด design size แทนแล้ว layout เข้าโหมดแคบเอง |
| ชื่อแท็บ (TabDisplay) ล้นออกนอกหน้าต่างข้างขวา | กล่อง `TextLabel` กว้าง `1,-16` แต่เริ่มที่ x=186 ของตัวต้นฉบับ | เป็นแค่กล่องโปร่งใส ตัวอักษรเรียงจากซ้าย จึงเห็นปกติ ไม่กระทบการใช้งาน |
| ตัวเลขค่า Slider (เช่น `16`) ดันออกนอกขอบซ้ายเวลาคอลัมน์ Narrow มาก | ป้ายค่าอยู่ซ้ายของราง ที่ถูก `UISizeConstraint` จำกัดไว้ 150px | ปล่อยไว้ได้ (เป็นเรื่องเดิมของต้นฉบับ และแย่กว่านี้เยอะบนไฟล์เดิม) หรือขยาย `MinScale` / ลดจำนวน element ต่อคอลัมน์ |

---

## แก้ตรงไหนบ้าง (สำหรับคนอยากรู้)

แพตช์ใน bundle ที่ถูก minify ไว้ (สคริปต์แพตช์อยู่ที่ `../patch.py`)

1. **`Components/Tab`** — คอลัมน์ซ้าย/ขวา
   - เพิ่ม `Tab:CreateColumns()` → สร้าง `Frame` หลัก (แนวนอน) ที่มีคอลัมน์ `Left` / `Right`
     (แต่ละคอลัมน์มี `UIListLayout` แนวตั้ง + signal `AbsoluteContentSize` เพื่อปรับความสูงอัตโนมัติ)
   - เปลี่ยน `Tab:AddSection(Title)` → `Tab:AddSection(Title, Side)` (`Side = "Left" | "Right"`)
   - เพิ่ม `Tab:AddLeftGroupbox(Title)` / `Tab:AddRightGroupbox(Title)`
   - คอลัมน์วางด้วยพิกเซลตรง ๆ (ไม่ใช้ `UIListLayout` แนวนอน) และทุกการวัดหาร `Window.Scale` ออกก่อน
     → คอลัมน์ไม่ทับกันแม้หน้าต่างจะถูกลด scale อยู่

2. **`MainModule` (Elements `__namecall`)**
   - ทุก `Add*` อ่านฟิลด์ `Side` จากตาราง config (รองรับทั้งแบบ `(Config)` และ `(Idx, Config)`)
     แล้วเลือก parent ให้เอง

3. **`Elements/Slider`**
   - เพิ่ม hit area สูง 26px, แตะเพื่อกระโดดค่า, ล็อกสครอลล์ตอนลากแนวนอน,
     ตรวจจับทิศทางนิ้ว, ใช้ `UIS.InputEnded` แทน `SliderDot.InputEnded`,
     ค่าภาพต่อเนื่องตอนลาก + ทวีน 0.12 วิ (`Smooth`)

4. **`Elements/Slider` + `Elements/Toggle` + `Elements/Colorpicker`**
   - วงกลมทุกจุดเปลี่ยนจาก `ImageLabel` (โหลดรูป asset เก่า) เป็น `Frame` + `UICorner`
     → แก้อาการภาพแตก/เบลอ และไม่ต้องโหลดอะไรจากเน็ตเลย

5. **`Components/Window`** — ทึบ + สเกลร่วม
   - `Acrylic` ถูกปิดทั้งหมด: `UseAcrylic = false` เสมอ, `AcrylicPaint` เหลือแค่ `Frame` ทึบชิ้นเดียว
     (ไม่สร้าง `DepthOfFieldEffect` / `Part` / `SpecialMesh` / รูปเงา / noise อีก)
   - เพิ่ม `UIScale` บน `Window.Root` → ทั้ง UI ย่อ/ขยายพร้อมกันกับหน้าต่าง
   - `Window:Fit()` คิด `SC = min(aw/designW, ah/designH)` เต็ม `[MinScale, MaxScale]`
     จากนั้นตั้ง `Root.Size` = design size (พิกเซลของหน้าต่าง) และ `UIScale.Scale = SC`
     จอสูงกว่ากว้างจะยืด design height ให้เต็มที่
   - Flipper motor ของขนาด (`G`) แบ่ง scale อัตโนมัติ → ลากมุมหน้าต่าง / ขยายหน้าต่างแล้วไม่เด้ง
   - ลากมุมหน้าต่าง: คิด scale ใหม่แบบ real-time (ค้างไว้ที่ `MinScale` ถ้าลากเล็กกว่านั้น)
   - จอแคบกว่า 640px ย้ายแถบแท็บไปด้านบน
   - `Dialog` วัดขนาดด้วยพิกเซลของหน้าต่าง (เพราะมันอยู่ข้างใน `Root` ที่ถูกลด scale)

6. **`Elements/Dropdown` + `Elements/Textbox`**
   - Dropdown popup หลุดานอก `Root` (ไม่ได้ถูกลด scale) จึงคูณ `TextBounds` ด้วย scale
     ไม่งั้นกล่องจะกว้างเกินจอ
   - Textbox เลื่อนเคอร์เซอร์: แปลง `TextBounds` เป็นพิกเซลจอก่อน

7. **`UICorner` ทุกตัว** → `CornerRadius = UDim.new(0, 0)` (เหลี่ยมหมด ไม่มีมุมโค้ง anywhere)

ทดสอบแล้วด้วยการจำลองสภาพแวดล้อม Roblox (โฟลเดอร์ `../testbed` — mock `Instance`/`UDim2`/`UIScale`/`UIListLayout`/`AutomaticSize`/`UISizeConstraint` + layout engine เต็มตัว)
ครอบคลุม: คอลัมน์ไม่ทับกัน, ไม่มี element ล้นคอลัมน์, ไม่มี element ทับกัน, มุมเหลี่ยมหมด,
พื้นหลังทึบ, สไลเดอร์, ลากมุมหน้าต่างจริง (ผ่าน `UserInputService`), และ scale ตรงกับขนาดที่แสดงจริง
ที่ความกว้าง 1920 / 1280 / 1024 / 844 / 390 / 640 / 360 px — ผ่านทั้งหมด 57 ช่องตรวจ
และแท็บแบบเดิม (ไม่ใช้ Side) ให้ผลเหมือนไฟล์ต้นฉบับทุกประการ
