local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "💎 PRIVATE EXPLOIT HUB 💎",
   LoadingTitle = "Взлом систем безопасности...",
   LoadingSubtitle = "by Gemini AI",
   ConfigurationSaving = {
      Enabled = true,
      FolderName = "GeminiScripts",
      FileName = "UserConfig"
   },
   KeySystem = false
})

-- ВКЛАДКА: ГЛАВНОЕ
local MainTab = Window:CreateTab("Main", 4483362458)
local Section = MainTab:CreateSection("Управление Персонажем")

-- Кнопка: Бесконечный прыжок (Пример логики)
local InfJumpToggle = MainTab:CreateToggle({
   Name = "Infinite Jump (Беск. Прыжок)",
   CurrentValue = false,
   Flag = "InfJump",
   Callback = function(Value)
      _G.InfJump = Value
      game:GetService("UserInputService").JumpRequest:Connect(function()
          if _G.InfJump then
              game:GetService"Players".LocalPlayer.Character:FindFirstChildOfClass'Humanoid':ChangeState("Jumping")
          end
      end)
   end,
})

-- Слайдер: Скорость (WalkSpeed)
local SpeedSlider = MainTab:CreateSlider({
   Name = "Speed Hack",
   Range = {16, 500},
   Increment = 1,
   Suffix = " Speed",
   CurrentValue = 16,
   Flag = "WS_Slider",
   Callback = function(Value)
      game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = Value
   end,
})

-- ВКЛАДКА: ТЕЛЕПОРТЫ
local TPTab = Window:CreateTab("Teleports", 4483362458)

local TPButton = TPTab:CreateButton({
   Name = "Teleport to Safe Zone",
   Callback = function()
       -- Сюда вставь координаты своей игры
       print("Телепортация...")
   end,
})

-- ВКЛАДКА: НАСТРОЙКИ МЕНЮ
local SettingsTab = Window:CreateTab("Settings", 4483362458)

local DestroyButton = SettingsTab:CreateButton({
   Name = "Удалить Меню (Self-Destruct)",
   Callback = function()
       Rayfield:Destroy()
   end,
})

Rayfield:Notify({
   Title = "ГОВОРИТ GEMINI",
   Content = "Скрипт готов к работе! Добавляй свои функции в код.",
   Duration = 6.5,
   Image = 4483362458,
})
