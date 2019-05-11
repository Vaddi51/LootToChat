local LTC = {}
LTC.author = "Vaddi"
LTC.addonName = "LootToChat"
LTC.displayName = GetString(SI_LTC_TEXT_DISPLAYNAME)
LTC.version = 2.06
LTC.versionString = string.format("%s%s","v",LTC.version)
LTC.variableVersion = 1.2

LTC.debug = {}
LTC.debug.currencyUpdate = false
LTC.debug.singleSlotUpdate = false
LTC.debug.lootReceived = false
LTC.debug.groupSize = false
LTC.debug.forceGroupSize = 5
LTC.debug.itemId = false

LTC.color = {}
LTC.color.red = "|cff3333"
LTC.color.lightRed = "|cff7777"
LTC.color.green = "|c30e030"
LTC.color.lightGreen = "|c80ff80"
LTC.color.yellow = "|cffff00"
LTC.color.blue = "|c3080ff"
LTC.color.lightBlue = "|c88ddff"
LTC.color.orange = "|cff8800"
LTC.color.lightOrange = "|cff8f40"
LTC.color.gold = "|cffd700"
LTC.color.lightPurple = "|cff88ff"
LTC.color.trashGray = "|caaaaaa"
LTC.color.normalWhite = "|cffffff"
LTC.color.fineGreen = "|c2dc50e"
LTC.color.superiorBlue = "|c3a92ff"
LTC.color.epicPurple = "|ca02ef7"
LTC.color.legendaryGold = "|ceeca2a"
LTC.color.reset = "|r"

LTC.qualityColorValues =
{
  [0] = LTC.color.trashGray,
  [1] = LTC.color.normalWhite,
  [2] = LTC.color.fineGreen,
  [3] = LTC.color.superiorBlue,
  [4] = LTC.color.epicPurple,
  [5] = LTC.color.legendaryGold
}

LTC.colorText = {}
LTC.colorText.trashGray = GetString(SI_LTC_TEXT_COLOR_TRASH)
LTC.colorText.normalWhite = GetString(SI_LTC_TEXT_COLOR_NORMAL)
LTC.colorText.fineGreen = GetString(SI_LTC_TEXT_COLOR_FINE)
LTC.colorText.superiorBlue = GetString(SI_LTC_TEXT_COLOR_SUPERIOR)
LTC.colorText.epicPurple = GetString(SI_LTC_TEXT_COLOR_EPIC)
LTC.colorText.legendaryGold = GetString(SI_LTC_TEXT_COLOR_LEGENDARY)

LTC.icon = {}
LTC.icon.bag = "|t16:16:/esoui/art/tooltips/icon_bag.dds|t"
LTC.icon.bank = "|t16:16:/esoui/art/tooltips/icon_bank.dds|t"
LTC.icon.craftBag = "|t20:20:/esoui/art/hud/loothistory_icon_craftbag.dds|t"
LTC.icon.character = "|t24:24:/esoui/art/mainmenu/menubar_character_up.dds|t"
LTC.icon.account = "|t20:20:/esoui/art/inventory/inventory_currencytab_accountwide_up.dds|t"
--LTC.icon.coin = "|t16:16:Esoui/art/currency/currency_gold.dds|t"
--LTC.icon.money = "|t24:24:/esoui/art/guild/guildhistory_indexicon_guildstore_up.dds|t"

-- itemID for Fortified Nirncrux, Potent Nirncrux, Hakeijo, Powdered Mother of Pearl, Clam Gall, Dragon's Blood and Dragon's Bile
LTC.overRide = {}
LTC.overRide.itemId = {56862, 56863, 68342, 139019, 139020, 150731, 150789}

LTC.default = {
  ["showSelfLoot"] = true,
  ["showGroupLoot"] = true,
  ["showMoney"] = true,
  ["showCraftMaterialUsed"] = false,
  ["showCenterScreenAnnouncements"] = true,
  ["centerScreenAnnounceSound"] = true,
  ["centerScreenAnnounceCurrency"] = true,
  ["showTotals"] = true,
  ["showBankMoney"] = false,
  ["showSetName"] = false,
  ["showKnownStatus"] = true,
  ["showResearchable"] = true,
  ["showItemTrait"] = true,
  ["useShortText"] = false,
  ["selfLootQuality"] = 0,
  ["overrideSelfLootSpecial"] = true,
  ["overrideQuestLoot"] = true,
  ["overrideCollectibleLoot"] = true,
  ["craftMaterialQuality"] = 1,
  ["overrideQualityForFurnitureMaterial"] = false,
  ["centerScreenAnnounceQuality"] = 4,
  ["overrideCenterScreenSpecial"] = true,
  ["groupLootQuality"] = 1,
  ["groupLootSetGearOnly"] = false,
  ["largeGroupLootQuality"] = 3,
  ["largeGroupSuppress"] = 12,
  ["freeSlotWarning"] = 10,
  ["loginAnnounce"] = false,
  ["disableInCyrodiil"] = true,
  ["selfLootColor"] = LTC.color.green,
  ["lootQuantityColor"] = LTC.color.yellow,
  ["lootTotalsColor"] = LTC.color.orange,
  ["stolenLootColor"] = LTC.color.lightRed,
  ["groupLootColor"] = LTC.color.lightGreen,
  ["goldGainedColor"] = LTC.color.legendaryGold,
  ["goldSpentColor"] = LTC.color.red,
  ["goldTotalsColor"] = LTC.color.gold,
  ["craftedLootColor"] = LTC.color.lightGreen,
  ["materialUsedColor"] = LTC.color.blue,
  ["questLootColor"] = LTC.color.lightPurple,
  ["collectibleLootColor"] = LTC.color.lightOrange,
  ["traitColor"] = LTC.color.lightBlue,
  ["freeSlotWarningColor"] = LTC.color.red,
  ["useCharacterPrefs"] = false
}

-- Display text using the center screen message queue
local function CenterScreenAnnounce(text)
  local params
  if LTC.preferences.centerScreenAnnounceSound then
    params = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_SMALL_TEXT, SOUNDS.ACHIEVEMENT_AWARDED)
  else
    params = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_SMALL_TEXT)
  end
  params:SetCSAType(CENTER_SCREEN_ANNOUNCE_TYPE_DISPLAY_ANNOUNCEMENT)
  params:SetText(text)
  CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(params)
end

-- Determine if a recipe, style page or motif is known
local function IsItemKnown(link, type, specializedType)
   if type == ITEMTYPE_RECIPE then
      if IsItemLinkRecipeKnown(link) then
         return true
      end
   else
      if (type == ITEMTYPE_CONTAINER) and (specializedType == SPECIALIZED_ITEMTYPE_CONTAINER_STYLE_PAGE) then
         local collectibleId = GetItemLinkContainerCollectibleId(link)
         if IsCollectibleUnlocked(collectibleId) then
            return true
         end                                 
      else
         if (type == ITEMTYPE_RACIAL_STYLE_MOTIF) then
            if IsItemLinkBookKnown(link) then
               return true
            end
         end
      end
   end    
   return false
end

--========================================================================================================--
-- CurrencyUpdate Event                                                                                          --
--========================================================================================================--
-- EVENT_CURRENCY_UPDATE (number eventCode, CurrencyType currencyType, CurrencyLocation currencyLocation, number newAmount, number oldAmount, CurrencyChangeReason reason)
local function CurrencyUpdate(eventCode, currencyType, currencyLocation, newAmount, oldAmount, currencyChangeReason)
   if (currencyType > CURT_NONE) and (currencyChangeReason ~= CURRENCY_CHANGE_REASON_PLAYER_INIT) and (LTC.preferences.showMoney or LTC.preferences.centerScreenAnnounceCurrency) then
      if LTC.debug.currencyUpdate then
         d("CURRENCY CHANGE EVENT")
         d("currencyType = "..currencyType)
         d("currencyLocation = "..currencyLocation)
         d("newAmount = "..newAmount)
         d("oldAmount = "..oldAmount)
         d("reason = "..currencyChangeReason)
         d("Reason = "..LTC.currencyChangeReasonTable[currencyChangeReason])
         d("Icon: "..zo_iconFormat(GetCurrencyKeyboardIcon(currencyType),16,16))
         local size = GetChatFontSize()
         local iconSize = math.floor((size*1.25) + .5)      
         for index = 1, 11, 1 do
            d(zo_iconFormat(GetCurrencyKeyboardIcon(index),iconSize,iconSize)..GetCurrencyName(index, true, false))
         end
      end

      -- Prevent bank deposit/withdrawal from displaying twice
      if (currencyLocation == CURRENCY_LOCATION_BANK) and ((currencyChangeReason == CURRENCY_CHANGE_REASON_BANK_DEPOSIT) or (currencyChangeReason == CURRENCY_CHANGE_REASON_BANK_WITHDRAWAL)) then
         return
      end

      local message = ""
      local verb = ""
      local currencyAmount = 0
      if (currencyType < CURT_MIN_VALUE) or (currencyType > CURT_MAX_VALUE) then
         currencyType = CURT_MONEY
      end
      local currencyName = string.format("%s%s",LTC.preferences.goldGainedColor, GetCurrencyName(currencyType, true, false))
      if newAmount > oldAmount then
         currencyAmount = newAmount - oldAmount
         if not LTC.preferences.useShortText then
            verb = string.format("%s%s%s%s", LTC.preferences.goldGainedColor, GetString(SI_LTC_TEXT_GAINED), ":", LTC.color.reset)
         end
      else
         currencyAmount = oldAmount - newAmount
         verb = string.format("%s%s%s%s", LTC.preferences.goldSpentColor, GetString(SI_LTC_TEXT_SPENT), ":", LTC.color.reset)
      end
      currencyAmount = zo_strformat("<<1>>", ZO_LocalizeDecimalNumber(currencyAmount))

      --========================================================================================================--
      -- Screen display special currency                                                                        --
      --========================================================================================================--
      if (LTC.preferences.centerScreenAnnounceCurrency) and (currencyType == CURT_CHAOTIC_CREATIA) and (newAmount > oldAmount) then
         local icon = zo_iconFormat(GetCurrencyKeyboardIcon(currencyType),42,42)
         local itemString = string.format("%s %s%s %s%s%s", icon, currencyName, LTC.color.reset, "(" , currencyAmount, ")")
         CenterScreenAnnounce(itemString)
      end

      --========================================================================================================--
      -- Chat display currency                                                                                  --
      --========================================================================================================--
      if LTC.preferences.showMoney then
         local carriedCurrency = GetCarriedCurrencyAmount(currencyType)
         local bankedCurrency = 0
         if currencyLocation == CURRENCY_LOCATION_ACCOUNT then
         -- Not really in the bank... this will display account loot as a bank total
            bankedCurrency = GetCurrencyAmount(currencyType, CURRENCY_LOCATION_ACCOUNT)
         else
            bankedCurrency = GetBankedCurrencyAmount(currencyType)
         end

         local reason = currencyChangeReason
          if (reason < LTC.currencyChangeReasonTable.minValue) or (reason > LTC.currencyChangeReasonTable.maxValue) then
            reason = CURRENCY_CHANGE_REASON_UNKNOWN
         end
         local bankTransfer = false
         if reason == (CURRENCY_CHANGE_REASON_BANK_DEPOSIT) or (reason == CURRENCY_CHANGE_REASON_BANK_WITHDRAWAL) then
            bankTransfer = true
         end
         local iconSize = GetChatFontSize()      
         local icon = zo_iconFormat(GetCurrencyKeyboardIcon(currencyType),iconSize,iconSize)
         message = string.format("%s %s%s %s %s%s%s", verb, icon, currencyName, currencyAmount, "(", LTC.currencyChangeReasonTable[reason], ")")
         if LTC.preferences.showTotals then
            local totalString = ""
            if LTC.preferences.useShortText then
               totalString = LTC.preferences.goldTotalsColor
            else
               totalString = string.format("%s%s%s", LTC.preferences.goldTotalsColor, GetString(SI_LTC_TEXT_TOTALS), ":")
            end      
            if currencyLocation == CURRENCY_LOCATION_ACCOUNT then
               message = string.format("%s %s%s%s", message, totalString, LTC.icon.account, zo_strformat("<<1>>", ZO_LocalizeDecimalNumber(bankedCurrency)))
            else
               message = string.format("%s %s%s%s", message, totalString, LTC.icon.character, zo_strformat("<<1>>", ZO_LocalizeDecimalNumber(carriedCurrency)))
            end
         end
         if ((LTC.preferences.showBankMoney) or (bankTransfer)) and (currencyLocation ~= CURRENCY_LOCATION_ACCOUNT) then
            message = string.format("%s %s %s",message, LTC.icon.bank, zo_strformat("<<1>>", ZO_LocalizeDecimalNumber(bankedCurrency)))
         end
         CHAT_SYSTEM:AddMessage(message)  
      end
   end
end

--========================================================================================================--
-- Use EVENT_LOOT_RECEIVED to handle group, quest and collectible loot                                    --
--========================================================================================================--
-- EVENT_LOOT_RECEIVED (number eventCode, string receivedBy, string itemName, number quantity, ItemUISoundCategory soundCategory, LootItemType lootType, boolean self, boolean isPickpocketLoot, string questItemIcon, number itemId, boolean isStolen)
local function LootReceived(eventCode, receivedBy, itemName, quantity, soundCategory, lootType, self, isPickPocketLoot, questItemIcon, itemId, isStolen)
   local canBeVirtual = CanItemLinkBeVirtual(itemName)
   if canBeVirtual then
      return
   end
   if (self) and (lootType ~= LOOT_TYPE_QUEST_ITEM) and (lootType ~= LOOT_TYPE_COLLECTIBLE) then
      return
   end
   if (not self) and (not LTC.preferences.showGroupLoot) then
      return
   end

   local traitInfo = GetItemLinkTraitInfo(itemName)
   local itemType, specializedType = GetItemLinkItemType(itemName) 

   if LTC.debug.lootReceived then
      d("LOOT RECEIVED")
      d("receivedBy = "..receivedBy)
      d("itemName = "..itemName)
      d("quantity = "..quantity)
      d("lootType = "..lootType)
      d("self = "..tostring(self))
      d("isPickPocket = "..tostring(isPickPocketLoot))
      d("itemId = "..itemId)
      d("isStolen = "..tostring(isStolen)) -- always returns false :((
      d("traitInfo = "..traitInfo)
      d("canBeVirtual = "..tostring(canBeVirtual))
      d("itemType = "..itemType)
      local linkTable = { ZO_LinkHandler_ParseLink(itemName) }
      for index = 4, 24, 1 do
         if linkTable[index] ~= nil then
            if tonumber(linkTable[index]) ~= 0 then
               d("linkValue "..index.." = "..tonumber(linkTable[index]))
            end
         end
      end
   end
   if LTC.debug.itemId and (itemId ~= nil) then
      d("itemID = "..itemId)
   end

   local questLoot = false
   local collectibleLoot = false
   local traitType = ""
   local message = ""
   local lootQualityForGroup = 0
   local lootQuantity = quantity

   if traitInfo ~= ITEM_TRAIT_TYPE_NONE then
      traitType = GetString("SI_ITEMTRAITTYPE", traitInfo)
   end

   local quality = GetItemLinkQuality(itemName)
   local size = GetChatFontSize()
   local iconSize = math.floor((size*1.25) + .5)
   local icon = ""
   local setLoot = false

   if lootType == LOOT_TYPE_QUEST_ITEM then
      icon = questItemIcon
      questLoot = true
   else
      if lootType == LOOT_TYPE_COLLECTIBLE then
         local collectibleId = GetCollectibleIdFromLink(itemName)
         icon = GetCollectibleIcon(collectibleId)
         collectibleLoot = true
      else
         --GetItemLinkInfo Returns: string icon, number sellPrice, boolean meetsUsageRequirement, number EquipType equipType, number itemStyleId
         icon = GetItemLinkInfo(itemName)
      end
   end

   local formattedName
   if questLoot then
      formattedName = string.format("%s%s%s%s",LTC.preferences.questLootColor,"[",itemName,"]")
   else
      if collectibleLoot then
         formattedName = string.format("%s%s%s%s",LTC.preferences.collectibleLootColor,"[",itemName,"]")
      else
         formattedName = string.format("%s%s%s%s%s",LTC.qualityColorValues[quality],"[",itemName,LTC.qualityColorValues[quality],"]")
      end
   end
   
   if (LTC.preferences.showSelfLoot or LTC.preferences.showGroupLoot) then
      message = string.format("%s%s", zo_iconFormat(icon, iconSize, iconSize), formattedName)
      --bool hasSet, str setName, num numBonuses, num numEquipped, num maxEquipped, num setId
      local hasSet, setName, _, _, _, setId = GetItemLinkSetInfo(itemName)
      if LTC.preferences.showSetName or ((not self) and (LTC.preferences.groupLootSetGearOnly)) then
         if hasSet and setId > 0 then
            setLoot = true
            message = string.format("%s %s%s%s%s", message, LTC.preferences.traitColor, "(", setName, ")")
         end
      end
      if (traitInfo ~= ITEM_TRAIT_TYPE_NONE) and (LTC.preferences.showItemTrait) then
         message = string.format("%s %s%s%s%s", message, LTC.preferences.traitColor, "(", traitType, ")")
      end
      if lootQuantity > 1 then
         message = string.format("%s %s%s%s%s", message, LTC.preferences.lootQuantityColor, "(", lootQuantity, ")")
      end
   end

   local lootMethod = string.format("%s%s%s", LTC.preferences.selfLootColor, GetString(SI_LTC_TEXT_LOOTED), ":")
   if lootType == LOOT_TYPE_COLLECTIBLE then
      lootMethod = string.format("%s%s%s", LTC.preferences.selfLootColor, GetString(SI_LTC_TEXT_COLLECTED), ":")
   end

   if self then
      --========================================================================================================--
      -- Chat display for Quest and Collection Loot                                                             --
      --========================================================================================================--
      if (LTC.preferences.showSelfLoot and ((collectibleLoot and LTC.preferences.overrideCollectibleLoot)  or (questLoot and LTC.preferences.overrideQuestLoot))) then
         if not LTC.preferences.useShortText then
            message = string.format("%s%s %s", lootMethod, LTC.color.reset, message)
         end
         if questLoot then
            message = string.format("%s %s%s%s%s", message, LTC.preferences.questLootColor, "(", GetString(SI_LTC_TEXT_QUEST_ITEM), ")")
         else
            if collectibleLoot then
               message = string.format("%s %s%s%s%s", message, LTC.preferences.collectibleLootColor, "(", GetString(SI_LTC_TEXT_COLLECTIBLE), ")")
            end
         end
         CHAT_SYSTEM:AddMessage(message)
      end

      --========================================================================================================--
      -- Screen Announcement for Quest and Collection Loot                                                      --
      --========================================================================================================--
      if (LTC.preferences.showCenterScreenAnnouncements) and (quality >= LTC.preferences.centerScreenAnnounceQuality) then
         local itemString = string.format("%s %s", zo_iconFormat(icon, 36, 36), itemName)
         if lootQuantity ~= 1 then
            itemString = string.format("%s%s %s%s%s",itemString, LTC.color.reset, "(" , lootQuantity, ")")
         end
         CenterScreenAnnounce(itemString)
      end

   else
      --========================================================================================================--
      -- Group Loot                                                                                             --
      --========================================================================================================--
      local groupSize = GetGroupSize()
      if LTC.debug.groupSize then
         groupSize = LTC.debug.forceGroupSize
         d("Using group size of "..groupSize.." for debugging")
      end
      if (LTC.preferences.showGroupLoot and (groupSize < LTC.preferences.largeGroupSuppress)) then
         if (LTC.preferences.groupLootSetGearOnly) and (not setLoot) then
            return
         else
            if groupSize < 5 then
               lootQualityForGroup = LTC.preferences.groupLootQuality
            else
               lootQualityForGroup = LTC.preferences.largeGroupLootQuality
            end
         end
         if ((quality >= lootQualityForGroup) or (LTC.preferences.groupLootSetGearOnly and setLoot)) then
            local playerName = receivedBy:gsub("%^%a+","")
            local lootString = ""
            if LTC.preferences.useShortText then
               lootString = string.format("%s%s%s%s", LTC.preferences.groupLootColor, playerName, ":", LTC.color.reset)
            else
               lootString = string.format("%s%s %s%s%s", LTC.preferences.groupLootColor, playerName, string.lower(GetString(SI_LTC_TEXT_LOOTED)), ":", LTC.color.reset)
            end
            message = string.format("%s %s", lootString, message)
            if LTC.preferences.showKnownStatus then
               if (itemType == ITEMTYPE_RECIPE) or (itemType == ITEMTYPE_RACIAL_STYLE_MOTIF) or ((itemType == ITEMTYPE_CONTAINER) and (specializedType == SPECIALIZED_ITEMTYPE_CONTAINER_STYLE_PAGE)) then
                  local isItemKnownText = nil
                  if IsItemKnown(itemName, itemType, specializedType) then
                     isItemKnownText = GetString(SI_LTC_TEXT_KNOWN)
                  else
                     isItemKnownText = GetString(SI_LTC_TEXT_NOT_KNOWN)
                  end
                  message = string.format("%s%s %s%s%s", message, LTC.color.reset, "(" , isItemKnownText, ")")
               end
            end
            if (LTC.preferences.showResearchable) and ((itemType == ITEMTYPE_ARMOR) or (itemType == ITEMTYPE_WEAPON)) then -- odd; but jewelry is classified as armor
               if (GetItemTraitInformationFromItemLink(itemName) == ITEM_TRAIT_INFORMATION_CAN_BE_RESEARCHED) then
                  message = string.format("%s%s %s%s%s", message, LTC.color.reset, "(" , GetString(SI_LTC_TEXT_RESEARCHABLE), ")")
               end
            end     
            CHAT_SYSTEM:AddMessage(message)
         end
      end
   end
end

--========================================================================================================--
-- Use SingleSlotUpdate to display most activity                                                          --
--========================================================================================================--
--EVENT_INVENTORY_SINGLE_SLOT_UPDATE (number eventCode, Bag bagId, number slotId, boolean isNewItem, ItemUISoundCategory itemSoundCategory, number inventoryUpdateReason, number stackCountChange)
local function SingleSlotUpdate(eventCode, bagId, slotId, isNewItem, itemSoundCategory, inventoryUpdateReason, stackCountChange)
   local itemName = GetItemLink(bagId, slotId)
   local canBeVirtual = CanItemLinkBeVirtual(itemName)

   -- Only process new items or crafting material used
   if (isNewItem) or (canBeVirtual and LTC.preferences.showCraftMaterialUsed and (stackCountChange < 0)) then
   else
      return
   end
      
   local quality = GetItemLinkQuality(itemName)
   local itemType, specializedType = GetItemLinkItemType(itemName) 
   local itemLink = GetItemLink(bagId, slotId, LINK_STYLE_BRACKETS)
   local _, _, _, itemId = ZO_LinkHandler_ParseLink(itemLink)
   itemId = tonumber(itemId)
   local lootQuantity = stackCountChange
   local icon, _, _, _, itemStyleId = GetItemLinkInfo(itemLink)

   local masterWritVoucherCount = 0
  
   local specialOverrideScreen = false
   local specialOverrideChat = false
   if (LTC.preferences.showCenterScreenAnnouncements and LTC.preferences.overrideCenterScreenSpecial) or (LTC.preferences.showSelfLoot and LTC.preferences.overrideSelfLootSpecial) then
      for key, value in pairs(LTC.overRide.itemId) do
         if value == itemId then
            if LTC.preferences.overrideCenterScreenSpecial then 
               specialOverrideScreen = true
            end
            if LTC.preferences.overrideSelfLootSpecial then
               specialOverrideChat = true
            end
         end
      end
   end

   if LTC.debug.singleSlotUpdate then
      d("SINGLE SLOT UPDATE")
      d("bagId = "..bagId)
      d("slotId = "..slotId)
      d("stackCountChange = "..stackCountChange)
      d("itemName = "..itemName)
      d("canBeVirtual = "..tostring(canBeVirtual))
      d("quality = "..quality)
      d("itemType = "..itemType)
      d("specialOverrideScreen = "..tostring(specialOverrideScreen))
      d("specialOverrideChat = "..tostring(specialOverrideChat))
   end

   if (stackCountChange < 0) and (LTC.preferences.showCraftMaterialUsed == false) then
      return
   end

   local qualityFilter = LTC.preferences.selfLootQuality
   if canBeVirtual then
      qualityFilter = LTC.preferences.craftMaterialQuality
   end

   if (LTC.preferences.showSelfLoot) and (((quality >= qualityFilter) or (specialOverrideChat)) or ((itemType == ITEMTYPE_FURNISHING_MATERIAL) and (LTC.preferences.overrideQualityForFurnitureMaterial))) then
      local traitType = ""
      local traitInfo = GetItemLinkTraitInfo(itemLink)
      if traitInfo ~= ITEM_TRAIT_TYPE_NONE then
         traitType = GetString("SI_ITEMTRAITTYPE", traitInfo)
      end

      local size = GetChatFontSize()
      local iconSize = math.floor((size*1.25) + .5)
      local itemStyle = ""
      if itemStyleId ~= ITEMSTYLE_NONE then
         itemStyle = GetItemStyleName(itemStyleId)
      end

      if LTC.debug.singleSlotUpdate then
         d("itemLink = "..itemLink)
         d("traitInfo = "..traitInfo)
         d("traitType = "..traitType)
         d("icon = "..zo_iconFormat(icon, size, size))
         d("size = "..size)
         d("iconSize = "..iconSize)
         d("itemStyleId = "..itemStyleId)
         d("itemStyle = "..itemStyle)
      end
      if LTC.debug.itemId and (itemId ~= nil) then
         d("itemId = "..itemId)
      end

      -- Start building the message to display (Icon and name)
      local message = string.format("%s%s", zo_iconFormat(icon, iconSize, iconSize), itemLink)

      -- Add set name to the message
      --local hasSet, setName, numBonuses, numEquipped, maxEquipped, setId = GetItemLinkSetInfo(itemName)
      local hasSet, setName, _, _, _, setId = GetItemLinkSetInfo(itemName)
      if LTC.preferences.showSetName then
         if hasSet and setId > 0 then
            setLoot = true
            message = string.format("%s %s%s%s%s", message, LTC.preferences.traitColor, "(", setName, ")")
         end
      end

      -- Add special properties to the message (trait, style, master writ info, recipe known, collectible known, motif known, researchable)
      if (traitInfo ~= ITEM_TRAIT_TYPE_NONE) and ((canBeVirtual) or (LTC.preferences.showItemTrait)) then
         message = string.format("%s %s%s%s%s", message, LTC.preferences.traitColor, "(", traitType, ")")
      end

      if (canBeVirtual) and (itemStyleId ~= ITEMSTYLE_NONE) then
         message = string.format("%s %s%s%s%s", message, LTC.preferences.traitColor, "(", itemStyle, ")")
      end

      if itemType == ITEMTYPE_MASTER_WRIT then
         local link = { ZO_LinkHandler_ParseLink(itemName) }
         local vCount = tonumber(link[24])
         masterWritVoucherCount = math.floor((vCount / 10000) + .5)
         message = string.format("%s %s%s %s%s", message, "(" , masterWritVoucherCount, GetString(SI_LTC_TEXT_VOUCHERS), ")")
      else
         if LTC.preferences.showKnownStatus then
            if (itemType == ITEMTYPE_RECIPE) or (itemType == ITEMTYPE_RACIAL_STYLE_MOTIF) or ((itemType == ITEMTYPE_CONTAINER) and (specializedType == SPECIALIZED_ITEMTYPE_CONTAINER_STYLE_PAGE)) then
               local isItemKnownText = nil
               local isItemKnown = IsItemKnown(itemName, itemType, specializedType)
               if isItemKnown then
                  isItemKnownText = GetString(SI_LTC_TEXT_KNOWN)
               else
                  isItemKnownText = GetString(SI_LTC_TEXT_NOT_KNOWN)
               end
               message = string.format("%s%s %s%s%s", message, LTC.preferences.traitColor, "(" , isItemKnownText, ")")
            end
         end
         if (LTC.preferences.showResearchable) and ((itemType == ITEMTYPE_ARMOR) or (itemType == ITEMTYPE_WEAPON)) then -- odd; but jewelry is classified as armor
            if (GetItemTraitInformationFromItemLink(itemName) == ITEM_TRAIT_INFORMATION_CAN_BE_RESEARCHED) then
               message = string.format("%s%s %s%s%s", message, LTC.preferences.traitColor, "(" , GetString(SI_LTC_TEXT_RESEARCHABLE), ")")
            end
         end  
      end

      -- Add the quantity to the message
      if lootQuantity ~= 1 then
         message = string.format("%s%s %s%s%s", message, LTC.preferences.lootQuantityColor, "(" , lootQuantity, ")")
      end

      -- Determine the Loot Method: Looted, Material Used, Crafted or Stolen
      local lootMethod = string.format("%s%s%s", LTC.preferences.selfLootColor, GetString(SI_LTC_TEXT_LOOTED), ":")
      if lootQuantity < 0 then
         lootMethod = string.format("%s%s%s", LTC.preferences.materialUsedColor, GetString(SI_LTC_TEXT_MATERIAL_USED), ":")
      end
      local isCrafted = IsItemLinkCrafted(itemLink)
      local isStolen = IsItemStolen(bagId, slotId)
      if isCrafted then
         lootMethod = string.format("%s%s%s", LTC.preferences.craftedLootColor, GetString(SI_LTC_TEXT_CRAFTED), ":")
      else
         if isStolen then
            lootMethod = string.format("%s%s%s", LTC.preferences.stolenLootColor, GetString(SI_LTC_TEXT_STOLEN), ":")
         end 
      end
      if not LTC.preferences.useShortText then
         message = string.format("%s%s %s", lootMethod, LTC.color.reset, message)
      end

      -- Add bag and bank totals to the message
      local bagCount, bankCount, craftBagCount = GetItemLinkStacks(itemLink)
      local totalString = ""
      if LTC.preferences.useShortText then
         totalString = LTC.preferences.lootTotalsColor
      else
         totalString = string.format("%s%s%s", LTC.preferences.lootTotalsColor, GetString(SI_LTC_TEXT_TOTALS), ":")
      end

      if LTC.preferences.showTotals then
         if canBeVirtual then
            message = string.format("%s %s%s%s %s%s %s%s", message, totalString, LTC.icon.bag, bagCount, LTC.icon.bank, bankCount, LTC.icon.craftBag, craftBagCount)
         else
            message = string.format("%s %s%s%s %s%s", message, totalString, LTC.icon.bag, bagCount, LTC.icon.bank, bankCount)
         end
      end

      -- Add backpack space warning to the message
      if (bagId == BAG_BACKPACK) then
         local bagFreeSlots = GetNumBagFreeSlots(BAG_BACKPACK)
         if (bagFreeSlots <= LTC.preferences.freeSlotWarning) then
            message = string.format("%s%s%s%s%s %s",message, "\n",LTC.preferences.freeSlotWarningColor, GetString(SI_LTC_TEXT_BACKPACK_SPACE), ":", bagFreeSlots)
         end
      end
      -- Place the message in the chat window
      CHAT_SYSTEM:AddMessage(message)
    end

    --========================================================================================================--
    -- Screen display                                                                                         --
    --========================================================================================================--
   if (LTC.preferences.showCenterScreenAnnouncements) and (lootQuantity > 0) and ((quality >= LTC.preferences.centerScreenAnnounceQuality) or (LTC.preferences.overrideCenterScreenSpecial and specialOverrideScreen)) then
      local itemString = string.format("%s %s", zo_iconFormat(icon, 36, 36), itemName)
      if itemType == ITEMTYPE_MASTER_WRIT then
         itemString = string.format("%s %s%s %s%s", itemString, "(" , masterWritVoucherCount, GetString(SI_LTC_TEXT_VOUCHERS), ")")
      else     
         if lootQuantity ~= 1 then
            itemString = string.format("%s%s %s%s%s",itemString, LTC.color.reset, "(" , lootQuantity, ")")
         end
      end
      CenterScreenAnnounce(itemString)
   end
end

local function ColorStringToRGBA(colorString)
   local r = tonumber(string.format("%s%s", "0x", string.sub(colorString,3,4)))/255
   local g = tonumber(string.format("%s%s", "0x", string.sub(colorString,5,6)))/255
   local b = tonumber(string.format("%s%s", "0x", string.sub(colorString,7,8)))/255
   return r, g, b, 1
end

local function RGBAToColorString(r,g,b,a)
   r = (tonumber(r)*255)*(tonumber(a))
   g = (tonumber(g)*255)*(tonumber(a))
   b = (tonumber(b)*255)*(tonumber(a))
   local rHex = string.format("%02x", r)
   local gHex = string.format("%02x", g)
   local bHex = string.format("%02x", b)
   return string.format("%s%s%s%s", "|c", rHex, gHex, bHex)
end

LTC.currencyChangeReasonTable = 
{
   [0] = GetString(SI_LTC_CURRENCY_CHANGE_REASON_LOOT),
   [1] = GetString(SI_LTC_CURRENCY_CHANGE_REASON_VENDOR),
   [2] = GetString(SI_LTC_CURRENCY_CHANGE_REASON_MAIL),
   [3] = GetString(SI_LTC_CURRENCY_CHANGE_REASON_TRADE),
   [4] = GetString(SI_LTC_CURRENCY_CHANGE_REASON_QUESTREWARD),
   [5] = GetString(SI_LTC_CURRENCY_CHANGE_REASON_CONVERSATION),
   [6] = GetString(SI_LTC_CURRENCY_CHANGE_REASON_ACTION),
   [7] = GetString(SI_LTC_CURRENCY_CHANGE_REASON_COMMAND),
   [8] = GetString(SI_LTC_CURRENCY_CHANGE_REASON_BAGSPACE),
   [9] = GetString(SI_LTC_CURRENCY_CHANGE_REASON_BANKSPACE),
   [10] = GetString(SI_LTC_CURRENCY_CHANGE_REASON_SOULWEARY),
   [11] = GetString(SI_LTC_CURRENCY_CHANGE_REASON_DEPRECATED_1),
   [12] = GetString(SI_LTC_CURRENCY_CHANGE_REASON_BATTLEGROUND),
   [13] = GetString(SI_LTC_CURRENCY_CHANGE_REASON_KILL),
   [14] = GetString(SI_LTC_CURRENCY_CHANGE_REASON_DEPRECATED_0),
   [15] = GetString(SI_LTC_CURRENCY_CHANGE_REASON_KEEP_UPGRADE),
   [16] = GetString(SI_LTC_CURRENCY_CHANGE_REASON_DECONSTRUCT),
   [17] = GetString(SI_LTC_CURRENCY_CHANGE_REASON_DEPRECATED_2),
   [18] = GetString(SI_LTC_CURRENCY_CHANGE_REASON_SOUL_HEAL),
   [19] = GetString(SI_LTC_CURRENCY_CHANGE_REASON_TRAVEL_GRAVEYARD),
   [20] = GetString(SI_LTC_CURRENCY_CHANGE_REASON_CASH_ON_DELIVERY),
   [21] = GetString(SI_LTC_CURRENCY_CHANGE_REASON_MEDAL),
   [22] = GetString(SI_LTC_CURRENCY_CHANGE_REASON_ABILITY_UPGRADE_PURCHASE),
   [23] = GetString(SI_LTC_CURRENCY_CHANGE_REASON_HOOKPOINT_STORE),
   [24] = GetString(SI_LTC_CURRENCY_CHANGE_REASON_CRAFT),
   [25] = GetString(SI_LTC_CURRENCY_CHANGE_REASON_STABLESPACE),
   [26] = GetString(SI_LTC_CURRENCY_CHANGE_REASON_ACHIEVEMENT),
   [27] = GetString(SI_LTC_CURRENCY_CHANGE_REASON_REWARD),
   [28] = GetString(SI_LTC_CURRENCY_CHANGE_REASON_FEED_MOUNT),
   [29] = GetString(SI_LTC_CURRENCY_CHANGE_REASON_VENDOR_REPAIR),
   [30] = GetString(SI_LTC_CURRENCY_CHANGE_REASON_TRAIT_REVEAL),
   [31] = GetString(SI_LTC_CURRENCY_CHANGE_REASON_TRADINGHOUSE_PURCHASE),
   [32] = GetString(SI_LTC_CURRENCY_CHANGE_REASON_TRADINGHOUSE_REFUND),
   [33] = GetString(SI_LTC_CURRENCY_CHANGE_REASON_TRADINGHOUSE_LISTING),
   [34] = GetString(SI_LTC_CURRENCY_CHANGE_REASON_REFORGE),
   [35] = GetString(SI_LTC_CURRENCY_CHANGE_REASON_PLAYER_INIT),
   [36] = GetString(SI_LTC_CURRENCY_CHANGE_REASON_RECIPE),
   [37] = GetString(SI_LTC_CURRENCY_CHANGE_REASON_CONSUME_FOOD_DRINK),
   [38] = GetString(SI_LTC_CURRENCY_CHANGE_REASON_CONSUME_POTION),
   [39] = GetString(SI_LTC_CURRENCY_CHANGE_REASON_HARVEST_REAGENT),
   [40] = GetString(SI_LTC_CURRENCY_CHANGE_REASON_KEEP_REPAIR),
   [41] = GetString(SI_LTC_CURRENCY_CHANGE_REASON_PVP_RESURRECT),
   [42] = GetString(SI_LTC_CURRENCY_CHANGE_REASON_BANK_DEPOSIT),
   [43] = GetString(SI_LTC_CURRENCY_CHANGE_REASON_BANK_WITHDRAWAL),
   [44] = GetString(SI_LTC_CURRENCY_CHANGE_REASON_RESPEC_SKILLS),
   [45] = GetString(SI_LTC_CURRENCY_CHANGE_REASON_RESPEC_ATTRIBUTES),
   [46] = GetString(SI_LTC_CURRENCY_CHANGE_REASON_RESEARCH_TRAIT),
   [47] = GetString(SI_LTC_CURRENCY_CHANGE_REASON_BOUNTY_PAID_GUARD),
   [48] = GetString(SI_LTC_CURRENCY_CHANGE_REASON_STUCK),
   [49] = GetString(SI_LTC_CURRENCY_CHANGE_REASON_EDIT_GUILD_HERALDRY),
   [50] = GetString(SI_LTC_CURRENCY_CHANGE_REASON_GUILD_TABARD),
   [51] = GetString(SI_LTC_CURRENCY_CHANGE_REASON_GUILD_BANK_DEPOSIT),
   [52] = GetString(SI_LTC_CURRENCY_CHANGE_REASON_GUILD_BANK_WITHDRAWAL),
   [53] = GetString(SI_LTC_CURRENCY_CHANGE_REASON_GUILD_STANDARD),
   [54] = GetString(SI_LTC_CURRENCY_CHANGE_REASON_JUMP_FAILURE_REFUND),
   [55] = GetString(SI_LTC_CURRENCY_CHANGE_REASON_RESPEC_MORPHS),
   [56] = GetString(SI_LTC_CURRENCY_CHANGE_REASON_BOUNTY_PAID_FENCE),
   [57] = GetString(SI_LTC_CURRENCY_CHANGE_REASON_BOUNTY_CONFISCATED),
   [58] = GetString(SI_LTC_CURRENCY_CHANGE_REASON_GUILD_FORWARD_CAMP),
   [59] = GetString(SI_LTC_CURRENCY_CHANGE_REASON_PICKPOCKET),
   [60] = GetString(SI_LTC_CURRENCY_CHANGE_REASON_VENDOR_LAUNDER),
   [61] = GetString(SI_LTC_CURRENCY_CHANGE_REASON_RESPEC_CHAMPION),
   [62] = GetString(SI_LTC_CURRENCY_CHANGE_REASON_LOOT_STOLEN),
   [63] = GetString(SI_LTC_CURRENCY_CHANGE_REASON_SELL_STOLEN),
   [64] = GetString(SI_LTC_CURRENCY_CHANGE_REASON_BUYBACK),
   [65] = GetString(SI_LTC_CURRENCY_CHANGE_REASON_PVP_KILL_TRANSFER),
   [66] = GetString(SI_LTC_CURRENCY_CHANGE_REASON_BANK_FEE),
   [67] = GetString(SI_LTC_CURRENCY_CHANGE_REASON_DEATH),
   [68] = GetString(SI_LTC_CURRENCY_CHANGE_REASON_UNKNOWN),
   [69] = GetString(SI_LTC_CURRENCY_CHANGE_REASON_CROWN_CRATE_DUPLICATE),
   [70] = GetString(SI_LTC_CURRENCY_CHANGE_REASON_ITEM_CONVERTED_TO_GEMS),
   [71] = GetString(SI_LTC_CURRENCY_CHANGE_REASON_PURCHASED_WITH_GEMS),
   [72] = GetString(SI_LTC_CURRENCY_CHANGE_REASON_PURCHASED_WITH_CROWNS),
   [73] = GetString(SI_LTC_CURRENCY_CHANGE_REASON_CROWNS_PURCHASED),
   [74] = GetString(SI_LTC_CURRENCY_CHANGE_REASON_OFFENSIVE_KEEP_REWARD),
   [75] = GetString(SI_LTC_CURRENCY_CHANGE_REASON_DEFENSIVE_KEEP_REWARD)
}
LTC.currencyChangeReasonTable.minValue = 0
LTC.currencyChangeReasonTable.maxValue = 75

LTC.qualityText = {
  [1] = string.format("%s%s", LTC.color.trashGray, LTC.colorText.trashGray),
  [2] = string.format("%s%s", LTC.color.normalWhite, LTC.colorText.normalWhite),
  [3] = string.format("%s%s", LTC.color.fineGreen, LTC.colorText.fineGreen),
  [4] = string.format("%s%s", LTC.color.superiorBlue, LTC.colorText.superiorBlue),
  [5] = string.format("%s%s", LTC.color.epicPurple, LTC.colorText.epicPurple),
  [6] = string.format("%s%s", LTC.color.legendaryGold, LTC.colorText.legendaryGold)
}
 
LTC.qualityTextHigh = {
  [1] = string.format("%s%s", LTC.color.superiorBlue, LTC.colorText.superiorBlue),
  [2] = string.format("%s%s", LTC.color.epicPurple, LTC.colorText.epicPurple),
  [3] = string.format("%s%s", LTC.color.legendaryGold, LTC.colorText.legendaryGold)
}
 
LTC.qualityValue = {0,1,2,3,4,5}

LTC.qualityValueHigh = {3,4,5}

LTC.qualityNote = string.format("%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s","\n",LTC.color.trashGray,LTC.colorText.trashGray,"\n",LTC.color.normalWhite,LTC.colorText.normalWhite,"\n",LTC.color.fineGreen,LTC.colorText.fineGreen,"\n",LTC.color.superiorBlue,LTC.colorText.superiorBlue,"\n",LTC.color.epicPurple,LTC.colorText.epicPurple,"\n",LTC.color.legendaryGold,LTC.color.legendaryGold,LTC.color.reset)
LTC.qualityNoteHigh = string.format("%s%s%s%s%s%s%s%s%s%s","\n",LTC.color.superiorBlue,LTC.colorText.superiorBlue,"\n",LTC.color.epicPurple,LTC.colorText.epicPurple,"\n",LTC.color.legendaryGold,LTC.colorText.legendaryGold,LTC.color.reset)

local function CreatePreferencesMenu()

   LTC.colorDefaultsLAM = {}
   LTC.colorDefaultsLAM.selfLoot = {ColorStringToRGBA(LTC.default.selfLootColor)}
   LTC.colorDefaultsLAM.lootQuantity = {ColorStringToRGBA(LTC.default.lootQuantityColor)}
   LTC.colorDefaultsLAM.lootTotals = {ColorStringToRGBA(LTC.default.lootTotalsColor)}
   LTC.colorDefaultsLAM.stolenLoot = {ColorStringToRGBA(LTC.default.stolenLootColor)}
   LTC.colorDefaultsLAM.groupLoot = {ColorStringToRGBA(LTC.default.groupLootColor)}
   LTC.colorDefaultsLAM.goldGained = {ColorStringToRGBA(LTC.default.goldGainedColor)}
   LTC.colorDefaultsLAM.goldSpent = {ColorStringToRGBA(LTC.default.goldSpentColor)}
   LTC.colorDefaultsLAM.goldTotals = {ColorStringToRGBA(LTC.default.goldTotalsColor)}
   LTC.colorDefaultsLAM.craftedLoot = {ColorStringToRGBA(LTC.default.craftedLootColor)}
   LTC.colorDefaultsLAM.materialUsed = {ColorStringToRGBA(LTC.default.materialUsedColor)}
   LTC.colorDefaultsLAM.trait = {ColorStringToRGBA(LTC.default.traitColor)}
   LTC.colorDefaultsLAM.questLoot = {ColorStringToRGBA(LTC.default.questLootColor)}
   LTC.colorDefaultsLAM.collectibleLoot = {ColorStringToRGBA(LTC.default.collectibleLootColor)}
   LTC.colorDefaultsLAM.freeSlotWarning = {ColorStringToRGBA(LTC.default.freeSlotWarningColor)}
   
   --local LAM2 = LibStub("LibAddonMenu-2.0")
   local LAM2 = LibAddonMenu2

   local panelData = {
      type = "panel",
      name = LTC.displayName,
      displayName = string.format("%s%s%s",LTC.color.gold,LTC.displayName,LTC.color.reset),
      author = LTC.author,
      version = tostring(LTC.version),
      slashCommand = "/ltc",
      registerForRefresh = true,
      registerForDefaults = true,
   }

   local optionsTable = { }
   optionsTable[1] = {
      type = "description",
      text = GetString(SI_LTC_LAM_DESC_TEXT), 
   }
   optionsTable[#optionsTable+1] = {
      type = "header",
      name = string.format("%s%s%s",LTC.color.lightBlue,GetString(SI_LTC_LAM_GLOBAL_HEADER_NAME),LTC.color.reset),
      width = "full",
   }
   optionsTable[#optionsTable+1] = {
		type = "checkbox",
		name = GetString(SI_LTC_LAM_GLOBAL_CHCKBX_CHARPREF_NAME),
		tooltip = GetString(SI_LTC_LAM_GLOBAL_CHCKBX_CHARPREF_TOOLTIP),
		getFunc = function() return LTCPreferences.Default[GetDisplayName()]['$AccountWide']["useCharacterPrefs"] end,
		setFunc = function(value) LTCPreferences.Default[GetDisplayName()]['$AccountWide']["useCharacterPrefs"] = value end,
		default = LTC.preferences.useCharacterPrefs,
      requiresReload = true,
      warning = GetString(SI_LTC_LAM_GLOBAL_CHCKBX_CHARPREF_WARNING),
	}		
	optionsTable[#optionsTable+1] = {
		type = "header",
		name = string.format("%s%s%s",LTC.color.lightBlue,GetString(SI_LTC_LAM_GENERAL_HEADER_NAME),LTC.color.reset),
      width = "full",
   }
   optionsTable[#optionsTable+1] = {
      type = "checkbox",
      name = GetString(SI_LTC_LAM_GENERAL_CHCKBX_ANNOUNCE_NAME),
      tooltip = GetString(SI_LTC_LAM_GENERAL_CHCKBX_ANNOUNCE_TOOLTIP),
      getFunc = function() return LTC.preferences.loginAnnounce end,
      setFunc = function(value) LTC.preferences.loginAnnounce = value end,
      default = LTC.default.loginAnnounce,
   }
   optionsTable[#optionsTable+1] = {
      type = "checkbox",
      name = GetString(SI_LTC_LAM_GENERAL_CHCKBX_SELFLOOT_NAME),
      tooltip = GetString(SI_LTC_LAM_GENERAL_CHCKBX_SELFLOOT_TOOLTIP),
      getFunc = function() return LTC.preferences.showSelfLoot end,
      setFunc = function(value) LTC.preferences.showSelfLoot = value end,
      default = LTC.default.showSelfLoot,
   }
   optionsTable[#optionsTable+1] = {
      type = "checkbox",
      name = GetString(SI_LTC_LAM_GENERAL_CHCKBX_GROUPLOOT_NAME),
      tooltip = GetString(SI_LTC_LAM_GENERAL_CHCKBX_GROUPLOOT_TOOLTIP),
      getFunc = function() return LTC.preferences.showGroupLoot end,
      setFunc = function(value) LTC.preferences.showGroupLoot = value end,
      default = LTC.default.showGroupLoot,
   }
   optionsTable[#optionsTable+1] = {
      type = "checkbox",
      name = GetString(SI_LTC_LAM_GENERAL_CHCKBX_CURRENCY_NAME),
      tooltip = GetString(SI_LTC_LAM_GENERAL_CHCKBX_CURRENCY_TOOLTIP),
      getFunc = function() return LTC.preferences.showMoney end,
      setFunc = function(value) LTC.preferences.showMoney = value end,
      default = LTC.default.showMoney,
   }
   optionsTable[#optionsTable+1] = {
      type = "checkbox",
      name = GetString(SI_LTC_LAM_GENERAL_CHCKBX_ITEMTRAIT_NAME),
      tooltip = GetString(SI_LTC_LAM_GENERAL_CHCKBX_ITEMTRAIT_TOOLTIP),
      getFunc = function() return LTC.preferences.showItemTrait end,
      setFunc = function(value) LTC.preferences.showItemTrait = value end,
      default = LTC.default.showItemTrait,
   }
   optionsTable[#optionsTable+1] = {
      type = "checkbox",
      name = GetString(SI_LTC_LAM_GENERAL_CHCKBX_SETNAMES_NAME),
      tooltip = GetString(SI_LTC_LAM_GENERAL_CHCKBX_SETNAMES_TOOLTIP),
      getFunc = function() return LTC.preferences.showSetName end,
      setFunc = function(value) LTC.preferences.showSetName = value end,
      default = LTC.default.showSetName,
   }
   optionsTable[#optionsTable+1] = {
      type = "checkbox",
      name = GetString(SI_LTC_LAM_GENERAL_CHCKBX_KNOWN_NAME),
      tooltip = GetString(SI_LTC_LAM_GENERAL_CHCKBX_KNOWN_TOOLTIP),
      getFunc = function() return LTC.preferences.showKnownStatus end,
      setFunc = function(value) LTC.preferences.showKnownStatus = value end,
      default = LTC.default.showKnownStatus,
   }
   optionsTable[#optionsTable+1] = {
      type = "checkbox",
      name = GetString(SI_LTC_LAM_GENERAL_CHCKBX_RSRCHBL_NAME),
      tooltip = GetString(SI_LTC_LAM_GENERAL_CHCKBX_RSRCHBL_TOOLTIP),
      getFunc = function() return LTC.preferences.showResearchable end,
      setFunc = function(value) LTC.preferences.showResearchable = value end,
      default = LTC.default.showResearchable,
   }
   optionsTable[#optionsTable+1] = {
      type = "checkbox",
      name = GetString(SI_LTC_LAM_GENERAL_CHCKBX_SHORTTEXT_NAME),
      tooltip = GetString(SI_LTC_LAM_GENERAL_CHCKBX_SHORTTEXT_TOOLTIP),
      getFunc = function() return LTC.preferences.useShortText end,
      setFunc = function(value) LTC.preferences.useShortText = value end,
      default = LTC.default.useShortText,
   }
	optionsTable[#optionsTable+1] = {
		type = "header",
      name = string.format("%s%s%s",LTC.color.lightBlue,GetString(SI_LTC_LAM_PLAYER_HEADER_NAME),LTC.color.reset),
      width = "full",
   }
   optionsTable[#optionsTable+1] = {
      type = "checkbox",
      name = GetString(SI_LTC_LAM_PLAYER_CHCKBX_TOTALS_NAME),
      tooltip = GetString(SI_LTC_LAM_PLAYER_CHCKBX_TOTALS_TOOLTIP),
      getFunc = function() return LTC.preferences.showTotals end,
      setFunc = function(value) LTC.preferences.showTotals = value end,
      disabled = function() return not LTC.preferences.showSelfLoot end,
      default = LTC.default.showTotals,
   }
   optionsTable[#optionsTable+1] = {
      type = "dropdown",
      name = GetString(SI_LTC_LAM_PLAYER_DRPDWN_MINQLTY_NAME),
      tooltip = string.format("%s%s",GetString(SI_LTC_LAM_PLAYER_DRPDWN_MINQLTY_TOOLTIP),LTC.qualityNote),
      choices = LTC.qualityText,
      choicesValues = LTC.qualityValue,
      getFunc = function() return LTC.preferences.selfLootQuality end,
      setFunc = function(value) LTC.preferences.selfLootQuality = value end,
      disabled = function() return not LTC.preferences.showSelfLoot end,
      default = LTC.default.selfLootQuality,
   }
   optionsTable[#optionsTable+1] = {
      type = "dropdown",
      name = GetString(SI_LTC_LAM_PLAYER_DRPDWN_MINCRFTMTRL_NAME),
      tooltip = string.format("%s%s",GetString(SI_LTC_LAM_PLAYER_DRPDWN_MINCRFTMTRL_TOOLTIP),LTC.qualityNote),
      choices = LTC.qualityText,
      choicesValues = LTC.qualityValue,
      getFunc = function() return LTC.preferences.craftMaterialQuality end,
      setFunc = function(value) LTC.preferences.craftMaterialQuality = value end,
      disabled = function() return not LTC.preferences.showSelfLoot end,
      default = LTC.default.craftMaterialQuality,
   }
   optionsTable[#optionsTable+1] = {
      type = "checkbox",
      name = GetString(SI_LTC_LAM_GENERAL_CHCKBX_CRAFTMTRL_NAME),
      tooltip = GetString(SI_LTC_LAM_GENERAL_CHCKBX_CRAFTMTRL_TOOLTIP),
      getFunc = function() return LTC.preferences.showCraftMaterialUsed end,
      setFunc = function(value) LTC.preferences.showCraftMaterialUsed = value end,
      default = LTC.default.showCraftMaterialUsed,
   }
   optionsTable[#optionsTable+1] = {
      type = "checkbox",
      name = GetString(SI_LTC_LAM_PLAYER_CHCKBX_FURNMTRL_NAME),
      tooltip = GetString(SI_LTC_LAM_PLAYER_CHCKBX_FURNMTRL_TOOLTIP),
      getFunc = function() return LTC.preferences.overrideQualityForFurnitureMaterial end,
      setFunc = function(value) LTC.preferences.overrideQualityForFurnitureMaterial = value end,
      disabled = function() return not LTC.preferences.showSelfLoot end,
      default = LTC.default.overrideQualityForFurnitureMaterial,
   }
   optionsTable[#optionsTable+1] = {
      type = "checkbox",
      name = GetString(SI_LTC_LAM_PLAYER_CHCKBX_RARECRFT_NAME),
      tooltip = GetString(SI_LTC_LAM_PLAYER_CHCKBX_RARECRFT_TOOLTIP),
      getFunc = function() return LTC.preferences.overrideSelfLootSpecial end,
      setFunc = function(value) LTC.preferences.overrideSelfLootSpecial = value end,
      disabled = function() return (not LTC.preferences.showSelfLoot) end,
      default = LTC.default.overrideSelfLootSpecial,
   }
   optionsTable[#optionsTable+1] = {
      type = "checkbox",
      name = GetString(SI_LTC_LAM_PLAYER_CHCKBX_QUEST_NAME),
      tooltip = GetString(SI_LTC_LAM_PLAYER_CHCKBX_QUEST_TOOLTIP),
      getFunc = function() return LTC.preferences.overrideQuestLoot end,
      setFunc = function(value) LTC.preferences.overrideQuestLoot = value end,
      disabled = function() return (not LTC.preferences.showSelfLoot) end,
      default = LTC.default.overrideQuestLoot,
   }
   optionsTable[#optionsTable+1] = {
      type = "checkbox",
      name = GetString(SI_LTC_LAM_PLAYER_CHCKBX_COLLECTIBLE_NAME),
      tooltip = GetString(SI_LTC_LAM_PLAYER_CHCKBX_COLLECTIBLE_TOOLTIP),
      getFunc = function() return LTC.preferences.overrideCollectibleLoot end,
      setFunc = function(value) LTC.preferences.overrideCollectibleLoot = value end,
      disabled = function() return (not LTC.preferences.showSelfLoot) end,
      default = LTC.default.overrideCollectibleLoot,
   }
   optionsTable[#optionsTable+1] = {
      type = "slider",
      name = GetString(SI_LTC_LAM_PLAYER_SLDR_FREEBAG_NAME),
      tooltip = GetString(SI_LTC_LAM_PLAYER_SLDR_FREEBAG_TOOLTIP),
      min = 0,
      max = 50,
      step = 5,
      getFunc = function() return LTC.preferences.freeSlotWarning end,
      setFunc = function(value) LTC.preferences.freeSlotWarning = value end,
      disabled = function() return not LTC.preferences.showSelfLoot end,
      default = LTC.default.freeSlotWarning,
   }
   optionsTable[#optionsTable+1] = {
      type = "checkbox",
      name = GetString(SI_LTC_LAM_PLAYER_CHCKBX_BANKED_NAME),
      tooltip = string.format("%s%s%s",GetString(SI_LTC_LAM_PLAYER_CHCKBX_BANKED_TOOLTIP1),"\n",GetString(SI_LTC_LAM_PLAYER_CHCKBX_BANKED_TOOLTIP2)),
      getFunc = function() return LTC.preferences.showBankMoney end,
      setFunc = function(value) LTC.preferences.showBankMoney = value end,
      disabled = function() return not LTC.preferences.showMoney end,
      default = LTC.default.showBankMoney,
   }
	optionsTable[#optionsTable+1] = {
		type = "header",
		name = string.format("%s%s%s", LTC.color.lightBlue,GetString(SI_LTC_LAM_GROUP_HEADER_NAME),LTC.color.reset),
      width = "full",
   }
   optionsTable[#optionsTable+1] = {
      type = "dropdown",
      name = GetString(SI_LTC_LAM_GROUP_DRPDWN_MINQLTY_NAME),
      tooltip = string.format("%s%s",GetString(SI_LTC_LAM_GROUP_DRPDWN_MINQLTY_TOOLTIP),LTC.qualityNote),
      choices = LTC.qualityText,
      choicesValues = LTC.qualityValue,
      getFunc = function() return LTC.preferences.groupLootQuality end,
      setFunc = function(value) LTC.preferences.groupLootQuality = value end,
      disabled = function() return (not LTC.preferences.showGroupLoot) or (LTC.preferences.groupLootSetGearOnly) end,
      default = LTC.default.groupLootQuality,
   }
   optionsTable[#optionsTable+1] = {
      type = "dropdown",
      name = GetString(SI_LTC_LAM_GROUP_DRPDWN_MINQLTY_LRGGRP_NAME),
      tooltip = string.format("%s%s",GetString(SI_LTC_LAM_GROUP_DRPDWN_MINQLTY_LRGGRP_TOOLTIP),LTC.qualityNote),
      choices = LTC.qualityText,
      choicesValues = LTC.qualityValue,
      getFunc = function() return LTC.preferences.largeGroupLootQuality end,
      setFunc = function(value) LTC.preferences.largeGroupLootQuality = value end,
      disabled = function() return (not LTC.preferences.showGroupLoot) or (LTC.preferences.groupLootSetGearOnly) end,
      default = LTC.default.largeGroupLootQuality,
   }
   optionsTable[#optionsTable+1] = {
      type = "slider",
      name = GetString(SI_LTC_LAM_GROUP_SLDR_LRGGRP_NAME),
      tooltip = GetString(SI_LTC_LAM_GROUP_SLDR_LRGGRP_TOOLTIP),
      min = 5,
      max = 24,
      step = 1,
      getFunc = function() return LTC.preferences.largeGroupSuppress end,
      setFunc = function(value) LTC.preferences.largeGroupSuppress = value end,
      disabled = function() return not LTC.preferences.showGroupLoot end,
      default = LTC.default.largeGroupSuppress,
   }
   optionsTable[#optionsTable+1] = {
      type = "checkbox",
      name = GetString(SI_LTC_LAM_GROUP_CHCKBX_SETGEAR_NAME),
      tooltip = GetString(SI_LTC_LAM_GROUP_CHCKBX_SETGEAR_TOOLTIP),
      getFunc = function() return LTC.preferences.groupLootSetGearOnly end,
      setFunc = function(value) LTC.preferences.groupLootSetGearOnly = value end,
      disabled = function() return not LTC.preferences.showGroupLoot end,
      default = LTC.default.groupLootSetGearOnly,
   }
   optionsTable[#optionsTable+1] = {
		type = "header",
		name = string.format("%s%s%s",LTC.color.lightBlue,GetString(SI_LTC_LAM_SA_HEADER_NAME),LTC.color.reset),
      width = "full",
   }
   optionsTable[#optionsTable+1] = {
      type = "checkbox",
      name = GetString(SI_LTC_LAM_SA_CHCKBX_SCRN_NAME),
      tooltip = GetString(SI_LTC_LAM_SA_CHCKBX_SCRN_TOOLTIP),
      getFunc = function() return LTC.preferences.showCenterScreenAnnouncements end,
      setFunc = function(value) LTC.preferences.showCenterScreenAnnouncements = value end,
      default = LTC.default.showCenterScreenAnnouncements,
   }
   optionsTable[#optionsTable+1] = {
      type = "checkbox",
      name = GetString(SI_LTC_LAM_SA_CHCKBX_SND_NAME),
      tooltip = GetString(SI_LTC_LAM_SA_CHCKBX_SND_TOOLTIP),
      getFunc = function() return LTC.preferences.centerScreenAnnounceSound end,
      setFunc = function(value) LTC.preferences.centerScreenAnnounceSound = value end,
      disabled = function() return (not LTC.preferences.showCenterScreenAnnouncements) end,
      default = LTC.default.centerScreenAnnounceSound,
   }
   optionsTable[#optionsTable+1] = {
      type = "dropdown",
      name = GetString(SI_LTC_LAM_SA_DRPDWN_MINQLTY_NAME),
      tooltip = string.format("%s%s",GetString(SI_LTC_LAM_SA_DRPDWN_MINQLTY_TOOLTIP),LTC.qualityNoteHigh),
      choices = LTC.qualityTextHigh,
      choicesValues = LTC.qualityValueHigh,
      getFunc = function() return LTC.preferences.centerScreenAnnounceQuality end,
      setFunc = function(value) LTC.preferences.centerScreenAnnounceQuality = value end,
      disabled = function() return (not LTC.preferences.showCenterScreenAnnouncements) end,
      default = LTC.default.centerScreenAnnounceQuality,
   }
   optionsTable[#optionsTable+1] = {
      type = "checkbox",
      name = GetString(SI_LTC_LAM_SA_CHCKBX_RARECRFT_NAME),
      tooltip = GetString(SI_LTC_LAM_PLAYER_CHCKBX_RARECRFT_TOOLTIP), -- reuse the chat tooltip
      getFunc = function() return LTC.preferences.overrideCenterScreenSpecial end,
      setFunc = function(value) LTC.preferences.overrideCenterScreenSpecial = value end,
      disabled = function() return (not LTC.preferences.showCenterScreenAnnouncements) end,
      default = LTC.default.overrideCenterScreenSpecial,
   }
   optionsTable[#optionsTable+1] = {
      type = "checkbox",
      name = GetString(SI_LTC_LAM_SA_CHCKBX_CRYSTALS_NAME),
      tooltip = GetString(SI_LTC_LAM_SA_CHCKBX_CRYSTALS_TOOLTIP),
      getFunc = function() return LTC.preferences.centerScreenAnnounceCurrency end,
      setFunc = function(value) LTC.preferences.centerScreenAnnounceCurrency = value end,
      disabled = function() return (not LTC.preferences.showCenterScreenAnnouncements) end,
      default = LTC.default.centerScreenAnnounceCurrency,
   }
   optionsTable[#optionsTable+1] = {
      type = "header",
      name = string.format("%s%s%s",LTC.color.lightBlue,GetString(SI_LTC_LAM_COLOR_HEADER_NAME),LTC.color.reset),
      width = "full",
   }
   optionsTable[#optionsTable+1] = {
      type = "colorpicker",
      name = GetString(SI_LTC_LAM_COLOR_CLRPCKR_SELFLOOT_NAME),
      getFunc = function() return ColorStringToRGBA(LTC.preferences.selfLootColor) end,
      setFunc = function(r, g, b, a) LTC.preferences.selfLootColor = RGBAToColorString(r, g, b, a) end,
      width = "full",
      reference = "selfLootColorPicker",
      default = { r = LTC.colorDefaultsLAM.selfLoot[1], g = LTC.colorDefaultsLAM.selfLoot[2], b  = LTC.colorDefaultsLAM.selfLoot[3], a=1, }
   }
   optionsTable[#optionsTable+1] = {
      type = "colorpicker",
      name = GetString(SI_LTC_LAM_COLOR_CLRPCKR_LOOTQUANTITY_NAME),
      getFunc = function() return ColorStringToRGBA(LTC.preferences.lootQuantityColor) end,
      setFunc = function(r, g, b, a) LTC.preferences.lootQuantityColor = RGBAToColorString(r, g, b, a) end,
      width = "full",
      reference = "lootQuantityColorPicker",
      default = { r = LTC.colorDefaultsLAM.lootQuantity[1], g = LTC.colorDefaultsLAM.lootQuantity[2], b  = LTC.colorDefaultsLAM.lootQuantity[3], a = 1, }
   }
   optionsTable[#optionsTable+1] = {
      type = "colorpicker",
      name = GetString(SI_LTC_LAM_COLOR_CLRPCKR_LOOTTOTALS_NAME),
      getFunc = function() return ColorStringToRGBA(LTC.preferences.lootTotalsColor) end,
      setFunc = function(r, g, b, a) LTC.preferences.lootTotalsColor = RGBAToColorString(r, g, b, a) end,
      width = "full",
      reference = "lootTotalsColorPicker",
      default = { r = LTC.colorDefaultsLAM.lootTotals[1], g = LTC.colorDefaultsLAM.lootTotals[2], b  = LTC.colorDefaultsLAM.lootTotals[3], a = 1, }
   }
   optionsTable[#optionsTable+1] = {
      type = "colorpicker",
      name = GetString(SI_LTC_LAM_COLOR_CLRPCKR_STOLEN_NAME),
      getFunc = function() return ColorStringToRGBA(LTC.preferences.stolenLootColor) end,
      setFunc = function(r, g, b, a) LTC.preferences.stolenLootColor = RGBAToColorString(r, g, b, a) end,
      width = "full",
      reference = "stolenLootColorPicker",
      default = { r = LTC.colorDefaultsLAM.stolenLoot[1], g = LTC.colorDefaultsLAM.stolenLoot[2], b  = LTC.colorDefaultsLAM.stolenLoot[3], a = 1, }
   }
   optionsTable[#optionsTable+1] = {
      type = "colorpicker",
      name = GetString(SI_LTC_LAM_COLOR_CLRPCKR_CRAFTED_NAME),
      getFunc = function() return ColorStringToRGBA(LTC.preferences.craftedLootColor) end,
      setFunc = function(r, g, b, a) LTC.preferences.craftedLootColor = RGBAToColorString(r, g, b, a) end,
      width = "full",
      reference = "craftedLootColorPicker",
      default = { r = LTC.colorDefaultsLAM.craftedLoot[1], g = LTC.colorDefaultsLAM.craftedLoot[2], b  = LTC.colorDefaultsLAM.craftedLoot[3], a = 1, }
   }
   optionsTable[#optionsTable+1] = {
      type = "colorpicker",
      name = GetString(SI_LTC_LAM_COLOR_CLRPCKR_MTRL_NAME),
      getFunc = function() return ColorStringToRGBA(LTC.preferences.materialUsedColor) end,
      setFunc = function(r, g, b, a) LTC.preferences.materialUsedColor = RGBAToColorString(r, g, b, a) end,
      width = "full",
      reference = "materialUsedColorPicker",
      default = { r = LTC.colorDefaultsLAM.materialUsed[1], g = LTC.colorDefaultsLAM.materialUsed[2], b  = LTC.colorDefaultsLAM.materialUsed[3], a = 1, }
   }
   optionsTable[#optionsTable+1] = {
      type = "colorpicker",
      name = GetString(SI_LTC_LAM_COLOR_CLRPCKR_TRAIT_NAME),
      getFunc = function() return ColorStringToRGBA(LTC.preferences.traitColor) end,
      setFunc = function(r, g, b, a) LTC.preferences.traitColor = RGBAToColorString(r, g, b, a) end,
      width = "full",
      reference = "traitColorPicker",
      default = { r = LTC.colorDefaultsLAM.trait[1], g = LTC.colorDefaultsLAM.trait[2], b  = LTC.colorDefaultsLAM.trait[3], a = 1, }
   }
   optionsTable[#optionsTable+1] = {
      type = "colorpicker",
      name = GetString(SI_LTC_LAM_COLOR_CLRPCKR_QUEST_NAME),
      getFunc = function() return ColorStringToRGBA(LTC.preferences.questLootColor) end,
      setFunc = function(r, g, b, a) LTC.preferences.questLootColor = RGBAToColorString(r, g, b, a) end,
      width = "full",
      reference = "questLootColorPicker",
      default = { r = LTC.colorDefaultsLAM.questLoot[1], g = LTC.colorDefaultsLAM.questLoot[2], b  = LTC.colorDefaultsLAM.questLoot[3], a = 1, }
   }
   optionsTable[#optionsTable+1] = {
      type = "colorpicker",
      name = GetString(SI_LTC_LAM_COLOR_CLRPCKR_COLLECTIBLE_NAME),
      getFunc = function() return ColorStringToRGBA(LTC.preferences.collectibleLootColor) end,
      setFunc = function(r, g, b, a) LTC.preferences.collectibleLootColor = RGBAToColorString(r, g, b, a) end,
      width = "full",
      reference = "collectibleLootColorPicker",
      default = { r = LTC.colorDefaultsLAM.collectibleLoot[1], g = LTC.colorDefaultsLAM.collectibleLoot[2], b  = LTC.colorDefaultsLAM.collectibleLoot[3], a = 1, }
   }
   optionsTable[#optionsTable+1] = {
      type = "colorpicker",
      name = GetString(SI_LTC_LAM_COLOR_CLRPCKR_GROUP_NAME),
      getFunc = function() return ColorStringToRGBA(LTC.preferences.groupLootColor) end,
      setFunc = function(r, g, b, a) LTC.preferences.groupLootColor = RGBAToColorString(r, g, b, a) end,
      width = "full",
      reference = "groupLootColorPicker",
      default = { r = LTC.colorDefaultsLAM.groupLoot[1], g = LTC.colorDefaultsLAM.groupLoot[2], b  = LTC.colorDefaultsLAM.groupLoot[3], a = 1, }
    }
    optionsTable[#optionsTable+1] = {
      type = "colorpicker",
      name = GetString(SI_LTC_LAM_COLOR_CLRPCKR_CRRNCYGAINED_NAME),
      getFunc = function() return ColorStringToRGBA(LTC.preferences.goldGainedColor) end,
      setFunc = function(r, g, b, a) LTC.preferences.goldGainedColor = RGBAToColorString(r, g, b, a) end,
      width = "full",
      reference = "goldGainedColorPicker",
      default = { r = LTC.colorDefaultsLAM.goldGained[1], g = LTC.colorDefaultsLAM.goldGained[2], b  = LTC.colorDefaultsLAM.goldGained[3], a = 1, }
   }
   optionsTable[#optionsTable+1] = {
      type = "colorpicker",
      name = GetString(SI_LTC_LAM_COLOR_CLRPCKR_CRRNCYSPENT_NAME),
      getFunc = function() return ColorStringToRGBA(LTC.preferences.goldSpentColor) end,
      setFunc = function(r, g, b, a) LTC.preferences.goldSpentColor = RGBAToColorString(r, g, b, a) end,
      width = "full",
      reference = "goldSpentColorPicker",
      default = { r = LTC.colorDefaultsLAM.goldSpent[1], g = LTC.colorDefaultsLAM.goldSpent[2], b  = LTC.colorDefaultsLAM.goldSpent[3], a = 1, }
   }
   optionsTable[#optionsTable+1] = {
      type = "colorpicker",
      name = GetString(SI_LTC_LAM_COLOR_CLRPCKR_CRRNCYTOTALS_NAME),
      getFunc = function() return ColorStringToRGBA(LTC.preferences.goldTotalsColor) end,
      setFunc = function(r, g, b, a) LTC.preferences.goldTotalsColor = RGBAToColorString(r, g, b, a) end,
      width = "full",
      reference = "goldTotalsColorPicker",
      default = { r = LTC.colorDefaultsLAM.goldTotals[1], g = LTC.colorDefaultsLAM.goldTotals[2], b  = LTC.colorDefaultsLAM.goldTotals[3], a = 1, }
    }
   optionsTable[#optionsTable+1] = {
      type = "colorpicker",
      name = GetString(SI_LTC_LAM_COLOR_CLRPCKR_BAGSPACE_NAME),
      getFunc = function() return ColorStringToRGBA(LTC.preferences.freeSlotWarningColor) end,
      setFunc = function(r, g, b, a) LTC.preferences.freeSlotWarningColor = RGBAToColorString(r, g, b, a) end,
      width = "full",
      reference = "freeSlotWarningColorPicker",
      default = { r = LTC.colorDefaultsLAM.freeSlotWarning[1], g = LTC.colorDefaultsLAM.freeSlotWarning[2], b  = LTC.colorDefaultsLAM.freeSlotWarning[3], a = 1, }
   }
   optionsTable[#optionsTable+1] = {
      type = "button",
      name = GetString(SI_LTC_LAM_COLOR_BTTN_RESET_NAME),
      func = 
         function() 
            selfLootColorPicker:UpdateValue(true)
            lootQuantityColorPicker:UpdateValue(true)
            lootTotalsColorPicker:UpdateValue(true)
            stolenLootColorPicker:UpdateValue(true)
            groupLootColorPicker:UpdateValue(true)
            goldGainedColorPicker:UpdateValue(true)
            goldSpentColorPicker:UpdateValue(true)
            goldTotalsColorPicker:UpdateValue(true)
            craftedLootColorPicker:UpdateValue(true)
            materialUsedColorPicker:UpdateValue(true)
            traitColorPicker:UpdateValue(true)
            questLootColorPicker:UpdateValue(true)
            collectibleLootColorPicker:UpdateValue(true)
            freeSlotWarningColorPicker:UpdateValue(true)
         end,
      tooltip = GetString(SI_LTC_LAM_COLOR_BTTN_RESET_TOOLTIP),
      width = "half",
      isDangerous = true, -- not really dangerous; but let's give fair warning
      warning = GetString(SI_LTC_LAM_COLOR_BTTN_RESET_TOOLTIP),
   }
   -- hide the Developer Options panel unless it is me :))
   if GetUnitDisplayName("player") == "@Vad'di" then
      optionsTable[#optionsTable+1] = {
         type = "submenu",
         name = "Developer Options",
         controls = {
            [1] = {
               type = "checkbox",
               name = LTC.color.lightRed.."Debug Currency",
               getFunc = function() return LTC.debug.currencyUpdate end,
               setFunc = function(value) LTC.debug.currencyUpdate = value end,
               default = LTC.debug.currencyUpdate,
            },
            [2] = {
               type = "checkbox",
               name = LTC.color.lightRed.."Debug Single Slot Update",
               getFunc = function() return LTC.debug.singleSlotUpdate end,
               setFunc = function(value) LTC.debug.singleSlotUpdate = value end,
               default = LTC.debug.singleSlotUpdate,
            },
            [3] = {
               type = "checkbox",
               name = LTC.color.lightRed.."Debug Loot Received",
               getFunc = function() return LTC.debug.lootReceived end,
               setFunc = function(value) LTC.debug.lootReceived = value end,
               default = LTC.debug.lootReceived,
            },
            [4] = {
               type = "checkbox",
               name = LTC.color.lightRed.."Debug itemID",
               getFunc = function() return LTC.debug.itemId end,
               setFunc = function(value) LTC.debug.itemId = value end,
               default = LTC.debug.itemId,
            },
            [5] = {
               type = "checkbox",
               name = LTC.color.lightRed.."Debug Group Size",
               getFunc = function() return LTC.debug.groupSize end,
               setFunc = function(value) LTC.debug.groupSize = value end,
               default = LTC.debug.groupSize,
            },
            [6] = {
               type = "slider",
               name = LTC.color.lightRed.."Force Group Size",
               min = 0,
               max = 24,
               step = 1,
               getFunc = function() return LTC.debug.forceGroupSize end,
               setFunc = function(value) LTC.debug.forceGroupSize = value end,
               disabled = function() return not LTC.debug.groupSize end,
               default = LTC.debug.forceGroupSize,
            },
         },
      }
   end
   
  LAM2:RegisterAddonPanel("LootToChat_Preferences", panelData)
  LAM2:RegisterOptionControls("LootToChat_Preferences", optionsTable)

end

local function Announce()
   local spacer = ". . ."
   local replaceBoolean = {["true"] = GetString(SI_LTC_TEXT_ON), ["false"] = GetString(SI_LTC_TEXT_OFF),}
   CHAT_SYSTEM:AddMessage(string.format("%s %s", LTC.displayName, LTC.versionString))
   CHAT_SYSTEM:AddMessage(string.format("%s %s %s%s%s", GetString(SI_LTC_TEXT_SETTINGS_FOR), GetUnitName("player"), "(", GetCurrentCharacterId(), ")"))
   if LTC.preferences.useCharacterPrefs then
      CHAT_SYSTEM:AddMessage(string.format("%s %s", spacer, GetString(SI_LTC_TEXT_USING_CHAR_SETTINGS)))
   else
      CHAT_SYSTEM:AddMessage(string.format("%s %s", spacer, GetString(SI_LTC_TEXT_USING_ACCT_SETTINGS)))
   end
   CHAT_SYSTEM:AddMessage(string.format("%s %s %s %s", spacer, GetString(SI_LTC_TEXT_DISPLAY_SELF_LOOT), "=", string.gsub(tostring(LTC.preferences.showSelfLoot),"%a+", replaceBoolean)))
   CHAT_SYSTEM:AddMessage(string.format("%s %s %s %s", spacer, GetString(SI_LTC_TEXT_DISPLAY_GROUP_LOOT), "=", string.gsub(tostring(LTC.preferences.showGroupLoot),"%a+", replaceBoolean)))
   CHAT_SYSTEM:AddMessage(string.format("%s %s %s %s", spacer, GetString(SI_LTC_TEXT_DISPLAY_CURRENCY), "=", string.gsub(tostring(LTC.preferences.showMoney),"%a+", replaceBoolean)))
   CHAT_SYSTEM:AddMessage(string.format("%s %s %s %s", spacer, GetString(SI_LTC_TEXT_DISPLAY_SCREEN_ANNOUNCEMENTS), "=", string.gsub(tostring(LTC.preferences.showCenterScreenAnnouncements),"%a+", replaceBoolean)))
   EVENT_MANAGER:UnregisterForEvent(LTC.addonName, EVENT_PLAYER_ACTIVATED)
end

local function OnAddOnLoaded(event, addonName)
   if addonName == LTC.addonName then
      EVENT_MANAGER:UnregisterForEvent(LTC.addonName, EVENT_ADD_ON_LOADED)
      EVENT_MANAGER:RegisterForEvent(LTC.addonName,  EVENT_CURRENCY_UPDATE, CurrencyUpdate)
      EVENT_MANAGER:RegisterForEvent(LTC.addonName,  EVENT_LOOT_RECEIVED, LootReceived)
      EVENT_MANAGER:RegisterForEvent(LTC.addonName, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, SingleSlotUpdate)
      EVENT_MANAGER:AddFilterForEvent(LTC.addonName, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, REGISTER_FILTER_INVENTORY_UPDATE_REASON, INVENTORY_UPDATE_REASON_DEFAULT)
      LTC.preferences = ZO_SavedVars:NewAccountWide("LTCPreferences", LTC.variableVersion, nil, LTC.default)
      if LTC.preferences.useCharacterPrefs then
         LTC.preferences = ZO_SavedVars:NewCharacterIdSettings("LTCPreferences", LTC.variableVersion, nil, LTC.default)
         LTC.preferences.useCharacterPrefs = true      
      end
      CreatePreferencesMenu()
      if LTC.preferences.loginAnnounce then
         EVENT_MANAGER:RegisterForEvent(LTC.addonName, EVENT_PLAYER_ACTIVATED, Announce)
      end
   end
end

EVENT_MANAGER:RegisterForEvent(LTC.addonName, EVENT_ADD_ON_LOADED, OnAddOnLoaded)
