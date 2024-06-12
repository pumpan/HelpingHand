  local modEnabled = false
  local hasAskedEnable = false
  local saidno = false
  local WbWhereEnabled = false
  local lastMessageTime = 0 -- For cooldown mechanism
  local messageCooldown = 10 -- 10 seconds cooldown
  WorldBosses = {}
  WorldBosses2 = {
      name = "WorldBosses",
      bestTimeEver = HelpingHand_SavedVariables.Settings and HelpingHand_SavedVariables.Settings.WorldBossesbestTime or 0,
      bestTimeEverShow = HelpingHand_SavedVariables.Settings and HelpingHand_SavedVariables.Settings.WorldBossesbestTimeShow or { minutes = 0, seconds = 0 },



  }

  WorldBosses.LethonCombatStartTime = nil
  WorldBosses.LordKazzakDeathTime = nil
  WorldBosses.HealthNotified = {
      ["Lethon"] = { ["80"] = false, ["55"] = false, ["30"] = false },
      ["Ysondre"] = { ["80"] = false, ["55"] = false, ["30"] = false },
      ["Taerar"] = { ["80"] = false, ["55"] = false, ["30"] = false },
      -- Add other bosses here if needed
  }
  local WorldbossHealthFrame = CreateFrame("Frame", nil, UIParent)
  function EnableWorldBossesWhereFeatures(enable)
      WbWhereEnabled = enable
  end
  function EnableWBTimerFrameFeatures(enable)
          if enable then
        WBTimerFrame = 1
      else 
        WBTimerFrame = 0
      end
  end
  -- Function to encapsulate World Bosses features
  function EnableWorldBossesFeatures(enable)
      if enable then

          -- Create the main frame for the addon
          local frame = CreateFrame("Frame")
          frame:RegisterEvent("CHAT_MSG_COMBAT_HOSTILE_DEATH")
          frame:RegisterEvent("PLAYER_TARGET_CHANGED")
          frame:RegisterEvent("CHAT_MSG_MONSTER_YELL")
          frame:RegisterEvent("CHAT_MSG_RAID")
          frame:RegisterEvent("CHAT_MSG_RAID_LEADER")

          -- Create the confirmation frame
          local confirmationFrame = CreateFrame("Frame", "WorldBossConfirmationFrame", UIParent)
          confirmationFrame:SetWidth(250)
          confirmationFrame:SetHeight(100)
          confirmationFrame:SetPoint("CENTER", UIParent, "CENTER")
          confirmationFrame:SetBackdrop({
              bgFile = "Interface/Tooltips/UI-Tooltip-Background",
              edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
              tile = true, tileSize = 16, edgeSize = 16,
              insets = { left = 4, right = 4, top = 4, bottom = 4 }
          })
          confirmationFrame:SetBackdropColor(0, 0, 0, 1)
          confirmationFrame:SetMovable(true)
          confirmationFrame:EnableMouse(true)
          confirmationFrame:RegisterForDrag("LeftButton")
          confirmationFrame:SetScript("OnDragStart", confirmationFrame.StartMoving)
          confirmationFrame:SetScript("OnDragStop", confirmationFrame.StopMovingOrSizing)
          confirmationFrame:Hide()

      -- Add header background texture
      confirmationFrame.header = confirmationFrame:CreateTexture(nil, 'ARTWORK')
      confirmationFrame.header:SetWidth(250)
      confirmationFrame.header:SetHeight(64)
      confirmationFrame.header:SetPoint('TOP', confirmationFrame, 0, 18)
      confirmationFrame.header:SetTexture("Interface\\DialogFrame\\UI-DialogBox-Header")
      confirmationFrame.header:SetVertexColor(.2, .2, .2)

      -- Add header text
      confirmationFrame.headerText = confirmationFrame:CreateFontString(nil, 'ARTWORK', 'GameFontHighlight')
      confirmationFrame.headerText:SetPoint('TOP', confirmationFrame.header, 0, -14)
      confirmationFrame.headerText:SetText('Start WorldBoss Mod?')



          local confirmationMainText = confirmationFrame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
          confirmationMainText:SetPoint("TOP", confirmationFrame, "TOP", 0, -20)
          confirmationMainText:SetText("If enabled in /hhand this will: \n1.Allow timer to start. \n2.Announce boss abilities \n3. activate where function.")

          -- Setup buttons
          local yesButton = CreateFrame("Button", nil, confirmationFrame, "UIPanelButtonTemplate")
          yesButton:SetPoint("BOTTOMLEFT", confirmationFrame, "BOTTOMLEFT", 10, 10)
          yesButton:SetWidth(100)
          yesButton:SetHeight(20)
          yesButton:SetText("Yes")

          local noButton = CreateFrame("Button", nil, confirmationFrame, "UIPanelButtonTemplate")
          noButton:SetPoint("BOTTOMRIGHT", confirmationFrame, "BOTTOMRIGHT", -10, 10)
          noButton:SetWidth(100)
          noButton:SetHeight(20)
          noButton:SetText("No")

          -- Function to hide the confirmation frame
          local function HideFrame()
              confirmationFrame:Hide()
          end

          -- Setup the button scripts
          yesButton:SetScript("OnClick", function()
              SendChatMessage("HelpingHand 1.0.1: GLHF with WorldBosses", "SAY")
              modEnabled = true
              HideFrame()
          end)

          noButton:SetScript("OnClick", function()
              modEnabled = false
              saidno = true
              HideFrame()
          end)

          -- Check if player is raid leader or assistant
          local function isPlayerRaidLeaderOrAssistant()
              local playerName = UnitName("player")
              for i = 1, 40 do
                  local name, rank = GetRaidRosterInfo(i)
                  if name == playerName then
                      if rank == 2 then
                          return true
                      elseif rank == 1 then
                          return true
                      else
                          return false
                      end
                  end
              end
              return false
          end

          -- Tracking variables
          local hasTargetedEmeriss = false
          local hasTargetedYsondre = false
          local hasTargetedTaerar = false
          local hasTargetedLethon = false
          local hasTargetedAzuregos = false
          local hasTargetedLordKazzak = false
          local EmerissIsDead = false
          local YsondreIsDead = false
          local TaerarIsDead = false
          local LethonIsDead = false
          local AzuregosIsDead = false
          local numTaerarDeaths = 0 -- added for Taerar spawning dragons named Taerar		
          local hasAskedWhere = {}

      local reflectionStartTime = 0	
          frame:SetScript("OnUpdate", function()
              if not isPlayerRaidLeaderOrAssistant() then
                  return
              end

              if GameTooltip:IsVisible() then
                  local isLethonFound = false
                  for i = 1, GameTooltip:NumLines() do
                      local line = getglobal("GameTooltipTextLeft" .. i)
                      if line and line:GetText() == "Lethon" then -- add for debugging-> or line:GetText() == "Plate Ogre" 
                          isLethonFound = true
                          if not hasAskedEnable and not modEnabled and not saidno then
                              confirmationFrame:Show()
                              hasAskedEnable = true
                          end
                          break
                      end
                  end
                  if not isLethonFound then
                      hasAskedEnable = false
                  end
              else
                  hasAskedEnable = false
              end
          end)

      local WBbossHealthFrame = CreateFrame("Frame", nil, UIParent)
      local bossNames = { "Ysondre", "Lethon", "Taerar" }
      local updateDelay = 1 -- Delay in seconds between updates
      local delayTimer = GetTime() + updateDelay
          local function OnEvent()
              if not isPlayerRaidLeaderOrAssistant() then
                  return
              end


        local function CheckWorldbossHealth(bossName)
        local health, maxHealth, healthPerc

        -- Check if player is in a raid
        if GetNumRaidMembers() > 0 then
          for i = 1, GetNumRaidMembers() do
            local unit = "raid" .. i .. "target"
            if UnitExists(unit) and UnitName(unit) == bossName and UnitName(unit) ~= "Shade of Taerar"  then
              health = UnitHealth(unit)
              maxHealth = UnitHealthMax(unit)
              healthPerc = (health / maxHealth) * 100
              --print("Raid member targeting boss detected:" .. UnitName(unit) .. "Health Percentage:" .. healthPerc)
              NotifyWorldBossHealth(bossName, healthPerc)
              return
            end	
          end

        -- Check if player is in a party
        elseif GetNumPartyMembers() > 0 then
          for i = 1, GetNumPartyMembers() do
            local unit = "party" .. i .. "target"
            if UnitExists(unit) and UnitName(unit) == bossName and UnitName(unit) ~= "Shade of Taerar" then
              health = UnitHealth(unit)
              maxHealth = UnitHealthMax(unit)
              healthPerc = (health / maxHealth) * 100
              NotifyWorldBossHealth(bossName, healthPerc)
              return
            end
          end
        end
      end

      WBbossHealthFrame:SetScript("OnUpdate", function(self, elapsed)
        if GetTime() >= delayTimer then
          for _, bossName in ipairs(bossNames) do
            CheckWorldbossHealth(bossName)
          end
          delayTimer = GetTime() + updateDelay -- Reset the delay timer
        end
      end)
      local check = 0	
        function NotifyWorldBossHealth(bossName, healthPerc)
          -- Notifications for Lethon
          if bossName == "Lethon" then
          --if healthPerc == 100 and check == 0 then
          --print("0")
          --SendChatMessage("hello", "SAY")
          --check = 1
              if healthPerc <= 80 and not WorldBosses.HealthNotified[bossName]["80"] then
                  SendChatMessage("Lethon 80% BRACE FOR FREEZE!", "RAID_WARNING")
                  WorldBosses.HealthNotified[bossName]["80"] = true
              elseif healthPerc <= 55 and not WorldBosses.HealthNotified[bossName]["55"] then
                  SendChatMessage("Lethon 55% BRACE FOR FREEZE!", "RAID_WARNING")
                  WorldBosses.HealthNotified[bossName]["55"] = true
              elseif healthPerc <= 30 and not WorldBosses.HealthNotified[bossName]["30"] then
                  SendChatMessage("Lethon 30% BRACE FOR FREEZE!", "RAID_WARNING")
                  WorldBosses.HealthNotified[bossName]["30"] = true

              end
          end

          -- Notifications for Taerar
          if bossName == "Taerar" then
              if healthPerc <= 80 and not WorldBosses.HealthNotified[bossName]["80"] then
                  SendChatMessage("Taerar at 80% spawning a dragon soon..", "RAID_WARNING")
                  WorldBosses.HealthNotified[bossName]["80"] = true
              elseif healthPerc <= 55 and not WorldBosses.HealthNotified[bossName]["55"] then
                  SendChatMessage("Taerar at 55% spawning a dragon soon..", "RAID_WARNING")
                  WorldBosses.HealthNotified[bossName]["55"] = true
              elseif healthPerc <= 30 and not WorldBosses.HealthNotified[bossName]["30"] then
                  SendChatMessage("Taerar at 30% spawning a dragon soon..", "RAID_WARNING")
                  WorldBosses.HealthNotified[bossName]["30"] = true
              end
          end

          -- Notifications for Ysondre
          if bossName == "Ysondre" then
              if healthPerc <= 80 and not WorldBosses.HealthNotified[bossName]["80"] then
                  SendChatMessage("Ysondre 80% Get ready to AOE/KILL the adds!", "RAID_WARNING")
                  WorldBosses.HealthNotified[bossName]["80"] = true
              elseif healthPerc <= 55 and not WorldBosses.HealthNotified[bossName]["55"] then
                  SendChatMessage("Ysondre 55% Get ready to AOE/KILL the adds!", "RAID_WARNING")
                  WorldBosses.HealthNotified[bossName]["55"] = true
              elseif healthPerc <= 30 and not WorldBosses.HealthNotified[bossName]["30"] then
                  SendChatMessage("Ysondre 30% Get ready to AOE/KILL the adds!", "RAID_WARNING")
                  WorldBosses.HealthNotified[bossName]["30"] = true
              end
          end
        end

        WorldbossHealthFrame:SetScript("OnEvent", function()
          CheckWorldbossHealth("Emeriss")
          CheckWorldbossHealth("Ysondre")
          CheckWorldbossHealth("Lethon")
          -- Add other bosses here if needed
        end)

        WorldbossHealthFrame:RegisterEvent("PLAYER_TARGET_CHANGED")
        WorldbossHealthFrame:RegisterEvent("UNIT_HEALTH")



              if event == "PLAYER_TARGET_CHANGED" and modEnabled then
                  local targetName = UnitName("target")
                  if targetName == "Lethon" and not hasTargetedLethon then  -- add for debugging --> or targetName == "Plate Ogre" 
                      SendChatMessage("Lethon heals at 75% 50% 25% to full hp.", "RAID_WARNING")
                      hasTargetedLethon = true
                  elseif targetName == "Taerar" and not hasTargetedTaerar then
                      SendChatMessage("Taerar: Watch out for knockbacks, staying at the portal is safe for range dps",
                          "RAID_WARNING")
                      hasTargetedTaerar = true
                  elseif targetName == "Emeriss" and not hasTargetedEmeriss then
                      SendChatMessage("Emeriss has no special abilities", "RAID_WARNING")
                      hasTargetedEmeriss = true
                  elseif targetName == "Ysondre" and not hasTargetedYsondre then
                      SendChatMessage("Lethon spawns Druids at 75% 50% and 25% AOE THEM! MELEE CAN ALSO HELP!",
                          "RAID_WARNING")
                      hasTargetedYsondre = true
                  elseif targetName == "Azuregos" and not hasTargetedAzuregos then
                      SendChatMessage("Azuregos: 1. Stay behind boss 2. Dispell tank 3. Watch out for spell reflect! 4. Mana users get out of Blizzard (drains mana)"
                          , "RAID_WARNING")
                      hasTargetedAzuregos = true
                  elseif targetName == "Lord Kazzak" and not hasTargetedLordKazzak then
                      SendChatMessage("Lord Kazzak: 1. Decurse and dispel (or WE will wipe) 2. DONT run out of mana (or you will explode in the raid)"
                          , "RAID_WARNING")
                      hasTargetedLordKazzak = true
                  end
              elseif event == "CHAT_MSG_MONSTER_YELL" then
                  if arg1 == "I can sense the SHADOW on your hearts. There can be no rest for the wicked!" and
                      arg2 == "Lethon" then
                      --if UnitName("target") == "Emeriss" then -- timers wont start if emeriss isnt targeted may remove this line
                          WorldBosses.LethonCombatStartTime = GetTime()
                          print("World bosses timer started")
              startTime = GetTime()
                        if WBTimerFrame == 1 then 

              if not WBDurationTimerFrame then
                WBDurationTimerFrame = CreateFrame("Frame", "WBDurationTimerFrame", UIParent)
                WBDurationTimerFrame:SetPoint("TOP", 0, -50) -- Adjust position as needed
                WBDurationTimerFrame:SetWidth(150)
                WBDurationTimerFrame:SetHeight(25)
                WBDurationTimerFrame:SetBackdrop({
                  bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
                  edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
                  tile = true,
                  tileSize = 1,
                  edgeSize = 1,
                  insets = { left = 1, right = 1, top = 1, bottom = 1 }
      })					
                WBDurationTimerFrame.text = WBDurationTimerFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
                WBDurationTimerFrame.tooltipText = "Rightclick to report elapsed time."
                WBDurationTimerFrame.text:SetPoint("CENTER", 0, 0)
                WBDurationTimerFrame:SetMovable(true)
                WBDurationTimerFrame:EnableMouse(true)					
                WBDurationTimerFrame:RegisterForDrag("LeftButton")
                WBDurationTimerFrame:SetScript("OnDragStart", WBDurationTimerFrame.StartMoving)
                WBDurationTimerFrame:SetScript("OnDragStop", WBDurationTimerFrame.StopMovingOrSizing)
                local position = HelpingHand_SavedVariables.Settings.timerFramePosition
                if position then
                  WBDurationTimerFrame:SetPoint(position[1], UIParent, position[2], position[3], position[4])
                end
                WBDurationTimerFrame:SetScript("OnMouseDown", function()
                  if arg1 == "LeftButton" and not this.isMoving then
                  this:StartMoving();
                  this.isMoving = true;
                  end
                end)
                WBDurationTimerFrame:SetScript("OnMouseUp", function()
                  if arg1 == "LeftButton" and this.isMoving then
                  this:StopMovingOrSizing();
                  this.isMoving = false;
                  SaveTimerFramePosition()
                  elseif arg1 == "RightButton" then
                  local elapsedTimeReport = math.floor(GetTime() - startTime)
                    SendChatMessage("Worldbosses duration: " .. SecondsToTime(elapsedTimeReport), "SAY")
                  end
                end)
                SetupTooltip(WBDurationTimerFrame, WBDurationTimerFrame.tooltipText)
              end



                          -- Start updating the timer frame
                          WBDurationTimerFrame:SetScript("OnUpdate", function()
                            local elapsedTime = math.floor(GetTime() - startTime)
                            WBDurationTimerFrame.text:SetText("Duration: " .. SecondsToTime(elapsedTime))
                          end)

                        end
              if HelpingHand_SavedVariables.Settings and HelpingHand_SavedVariables.Settings.WorldBossesbestTimeShow then
                  DEFAULT_CHAT_FRAME:AddMessage("Best time Ever: " .. string.format("%02d:%02d", HelpingHand_SavedVariables.Settings.WorldBossesbestTimeShow.minutes, HelpingHand_SavedVariables.Settings.WorldBossesbestTimeShow.seconds), 1.0, 1.0, 0.0)
                          end
                      --end
                  end
              elseif event == "CHAT_MSG_COMBAT_HOSTILE_DEATH" and modEnabled then
                  local delayTimer = 0
                  local delayDuration = 2

                  if arg1 and string.find(arg1, "Lethon dies") then -- add for debugging --> or string.find(arg1, "Plate Ogre dies")
                      --WorldBosses.LethonCombatStartTime = GetTime() --> should not be needed any more since it starts on CHAT_MSG_MONSTER_YELL
                      local message = "Port to DEW"
                      WBDelayedMessage(message, delayDuration)
                      LethonIsDead = true
                      hasAskedWhere = {}
                  elseif arg1 and string.find(arg1, "Taerar dies") and LethonIsDead then
                  -- Increment the number of Taerar deaths
                      numTaerarDeaths = numTaerarDeaths + 1
                      -- Check if this is the last Taerar death (4th)
					--print("Number of Taerar deaths: " .. numTaerarDeaths)
                      if numTaerarDeaths == 4 then
						  local message = "Port to ZG"
						  WBDelayedMessage(message, delayDuration)
						  TaerarIsDead = true
						  hasAskedWhere = {}
                      end
                  elseif arg1 and string.find(arg1, "Emeriss dies") and TaerarIsDead then
                      local message = "Use a portal to ORGRIMMAR in Hyjal or by a Mage"
                      WBDelayedMessage(message, delayDuration)
                      EmerissIsDead = true
                      hasAskedWhere = {}
                  elseif arg1 and string.find(arg1, "Ysondre dies") then
                      local message = "DONT PORT! We are riding to AZSHARA!"
                      WBDelayedMessage(message, delayDuration)
                      YsondreIsDead = true
                      hasAskedWhere = {}
                  elseif arg1 and string.find(arg1, "Azuregos dies") then
                      local message = "Port to HIGHLORD AND DOOMGUARD"
                      WBDelayedMessage(message, delayDuration)
                      AzuregosIsDead = true
                      hasAskedWhere = {}
                  elseif arg1 and string.find(arg1, "Lord Kazzak dies") then -- add for debugging --> or string.find(arg1, "Red Ogre Puncher dies")
                      hasAskedWhere = {}
                      WorldBosses.LordKazzakDeathTime = GetTime()
                      if WorldBosses.LethonCombatStartTime and WorldBosses.LordKazzakDeathTime then
                          local durationInSeconds = WorldBosses.LordKazzakDeathTime - WorldBosses.LethonCombatStartTime
                          local durationInMinutes = math.floor(durationInSeconds / 60)
                          local seconds = durationInSeconds - durationInMinutes * 60
                          if seconds < 0 then
                              seconds = seconds * -1 
                          end
                          -- Stop and hide the timer when kazzak dies
                          if WBDurationTimerFrame then
                              WBDurationTimerFrame:SetScript("OnUpdate", nil) -- Stop updating the timer frame
                          WBDurationTimerFrame:Hide()
                          end
                          if HelpingHand_SavedVariables.Settings and HelpingHand_SavedVariables.Settings.WorldBossesbestTimeShow then
                              if WorldBosses2.bestTimeEver == 0 or durationInSeconds < WorldBosses2.bestTimeEver or durationInSeconds < WorldBosses2.bestTimeEver then


                              WorldBosses2.bestTimeEver = durationInSeconds
                              WorldBosses2.bestTimeEverShow = { minutes = durationInMinutes, seconds = seconds }

                              HelpingHand_SavedVariables.Settings[WorldBosses2.name .. "bestTime"] = durationInSeconds
                              HelpingHand_SavedVariables.Settings[WorldBosses2.name .. "bestTimeShow"] = { minutes = durationInMinutes, seconds = seconds }

                              local message = "New RECORD for " .. WorldBosses2.name .. " : " .. durationInMinutes .. " minutes " .. string.format("%02d", seconds) .. " seconds"
                              WBDelayedMessage(message, delayDuration)
                              elseif durationInSeconds > WorldBosses2.bestTimeEver then
                              local message = "Not a Record Time " .. WorldBosses2.name .. ": " .. durationInMinutes .. " min " .. string.format("%02d", seconds) .. " sec. Record is: " .. WorldBosses2.bestTimeEverShow.minutes .. " min " .. string.format("%02d", WorldBosses2.bestTimeEverShow.seconds) .. " sec."

                              WBDelayedMessage(message, delayDuration)
                              end
                          end
                      else
                          UIErrorsFrame:AddMessage("No Time recorded you probably joined late", 1.0, 0.0, 0.0)

                      end
                  end

              elseif (event == "CHAT_MSG_RAID" or event == "CHAT_MSG_RAID_LEADER") and modEnabled and WbWhereEnabled then
                  local msg, author = arg1, arg2
                  local lowerMsg = string.lower(msg)
          if string.find(lowerMsg, "%f[%a]where%f[%A]") and not (string.find(lowerMsg, "%f[%a]where is%f[%A]") and not string.find(lowerMsg, "%f[%a]where is%s*next%f[%A]")) then



                      local currentTime = GetTime()
            local numRaidMembers = GetNumRaidMembers()
            local _, instanceType = IsInInstance()
            if numRaidMembers >= 1 and not (instanceType == "pvp" or instanceType == "arena") then
              if currentTime >= (lastMessageTime + messageCooldown) and (not hasAskedWhere[author] or hasAskedWhere[author] == nil) then
                if not LethonIsDead then
                SendChatMessage("Port to Mal Desolace!", "RAID")

                elseif LethonIsDead and not TaerarIsDead then
                SendChatMessage("Use Questporter to DEW!", "RAID")
                elseif TaerarIsDead and not EmerissIsDead then
                SendChatMessage("Use Raid Teleporter to ZG and ride to DUSKWOOD!", "RAID")
                elseif EmerissIsDead and not YsondreIsDead then
                SendChatMessage("Use a PORTAL to ORGRIMMAR! Hyjal>Portal to orgrimmar", "RAID")
                elseif YsondreIsDead and not AzuregosIsDead then
                SendChatMessage("DONT PORT! We are riding to AZSHARA!", "RAID")
                elseif AzuregosIsDead then
                SendChatMessage("Use Questporter to HIGHLORD AND DOOMGUARD!", "RAID")
                else
                SendChatMessage("I'm here", "RAID") -- this is not realy for anything
                end
                hasAskedWhere[author] = true
                lastMessageTime = currentTime

              end
            end	
                  end
              end

          end

          frame:SetScript("OnEvent", OnEvent)
      end
  end
  function WBDelayedMessage(message, delay)
      local delayFrame = CreateFrame("Frame")
      local delayTimer = GetTime() + delay
      delayFrame:SetScript("OnUpdate", function(self, elapsed)
          if GetTime() >= delayTimer then
               SendChatMessage(message, "RAID_WARNING")
               delayFrame:SetScript("OnUpdate", nil) 
          end
      end)
  end

local AzuregosShieldDown = "Reflection fades from Azuregos."
local AzuregosShieldUp = "^Azuregos gains Reflection"

local AzuregosFrame = CreateFrame("Frame")
AzuregosFrame:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_OTHER")
AzuregosFrame:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_CREATURE_BUFFS")

AzuregosFrame:SetScript("OnEvent", function()
    if event == "CHAT_MSG_SPELL_AURA_GONE_OTHER" then
       -- print("Argument:" .. arg1)
        if string.find(arg1, AzuregosShieldDown) then
            SendChatMessage("--- Magic Shield down! ---", "RAID")
        end
    elseif event == "CHAT_MSG_SPELL_PERIODIC_CREATURE_BUFFS" then
        if string.find(arg1, AzuregosShieldUp) then
            SendChatMessage("+++ Magic Shield up! +++", "RAID")
        end
    end
end)



  function ResetWorldBossesRecords()
      if HelpingHand_SavedVariables then
          HelpingHand_SavedVariables.Settings.WorldBossesbestTime = 0
          HelpingHand_SavedVariables.Settings.WorldBossesbestTimeShow = { minutes = 0, seconds = 0 }
          DEFAULT_CHAT_FRAME:AddMessage("World Bosses timers reset.")
      else
          DEFAULT_CHAT_FRAME:AddMessage("Saved variables not found or loaded.", 1.0, 0.0, 0.0)
      end
  end

  function SaveTimerFramePosition()
      local point, _, relativePoint, xOfs, yOfs = WBDurationTimerFrame:GetPoint()
      HelpingHand_SavedVariables.Settings.timerFramePosition = {point, relativePoint, xOfs, yOfs}
  end

  SLASH_WB1 = "/wb"
  SlashCmdList["WB"] = function(cmd)
      if cmd == "reset" then
          -- Reset WorldBosses records
          ResetWorldBossesRecords()
      elseif cmd == "show" then
          -- Display current WorldBosses timer data
          if HelpingHand_SavedVariables.Settings and HelpingHand_SavedVariables.Settings.WorldBossesbestTimeShow then
              DEFAULT_CHAT_FRAME:AddMessage("Best time Ever: " .. string.format("%02d:%02d", HelpingHand_SavedVariables.Settings.WorldBossesbestTimeShow.minutes, HelpingHand_SavedVariables.Settings.WorldBossesbestTimeShow.seconds), 1.0, 1.0, 0.0)
          else
              DEFAULT_CHAT_FRAME:AddMessage("WorldBosses data not available.", 1.0, 0.0, 0.0)
          end
      else
          DEFAULT_CHAT_FRAME:AddMessage("Invalid command. Usage: /wb reset to reset records, /wb show to display current records.", 1.0, 0.0, 0.0)
      end
  end

