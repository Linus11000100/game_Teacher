local module = {}

local status = game.ReplicatedStorage:WaitForChild("Status")

function module.Intermission(length)
	for i = length,0,-1 do
		status.Value = "Next start in "..i.."Sekunden"
		wait(1)
	end
end

function module.SelectChapter()
	
	local Votes = {}
	
	game.ReplicatedStorage.ToggleMapVote:FireAllClients(true)
	
	for i, v in pairs(game.ReplicatedStorage.Chapters:GetChildren()) do
		Votes[v.Name] = {}
	end
	
	local placeVoteConnection = game.ReplicatedStorage.PlaceVote.OnServerEvent:Connect(function(player,mapName)
		if Votes[mapName] then
			
			for i, playerVotesTab in pairs(Votes) do
				for x, playerName in pairs(playerVotesTab) do
					if playerName == player.Name then
						table.remove(playerVotesTab,x)
						break
					end
				end
			end
			
			table.insert(Votes[mapName],player.Name)
			
			game.ReplicatedStorage.UpdateVoteCount:FireAllClients(Votes)
			
		end	
	end)
	
	game.ReplicatedStorage.MapVoting.Value = true
	
	wait(15)
	
	game.ReplicatedStorage.MapVoting.Value = false
	
	game.ReplicatedStorage.ToggleMapVote:FireAllClients(false)
	
	placeVoteConnection:Disconnect()
	
	local mostVotes = nil
	local mostVoted = nil
	
	
	for i, mapTable in pairs(Votes) do
		
		local votes = #mapTable
		
		if mostVotes == nil then
			mostVotes = votes
			mostVoted = i
			
		else
			if votes >= mostVotes then
				mostVotes = votes
				mostVoted = i
			end
		end
		
	end
	local chosenChapter
	
	if mostVotes == nil or mostVoted == nil then
		chosenChapter = game.ReplicatedStorage.Chapters:GetChildren()[math.random(1,#game.ReplicatedStorage.Chapters:GetChildren())]
	else
		chosenChapter = game.ReplicatedStorage.Chapters[mostVoted]
		
	end
	
	status.Value = chosenChapter.Name.." has been selected with "..tostring(mostVotes)
	
	wait(5)
	return chosenChapter
	
	
end

function module.ChooseTeacher(players)

	local RandomOBJ =Random.new()

	local chosenTeacher = players[RandomOBJ:NextInteger(1,#players)]

	return chosenTeacher

end

function module.DressTeacher(teacher)
	
	local character
	
	if piggy.EquippedSkin.Value ~= "" then
		if game.ReplicatedStorage.Skins:FindFirstChild(piggy.EquippedSkin.Value) then
			character = game.ReplicatedStorage.Skins[teacher.EquippedSkin.Value]:Clone()
		end
	else
		character = game.ReplicatedStorage.Skins.Piggy:Clone()
		
	end	
		
	
	character.Name = teacher.Name

	teacher.Character = character

	character.Parent = workspace
end

function module.TeleportTeacher(player)
	if player.Character then

		player.Character.Humanoid.WalkSpeed = 14

		local bat = game.ServerStorage.Tools.TeacherBat:Clone()
		bat.Parent = player.Character

		if player.Character:FindFirstChild("HumanoidRootPart") then
			player.Character.HumanoidRootPart.CFrame = game.Workspace.WaitingRoom.TeacherWaitingSpawn.CFrame + Vector3.new(0,5,0)
		end

		local TrapCount = Instance.new("IntValue")
		TrapCount.Name = "TrapCount"
		TrapCount.Value = 5
		TrapCount.Parent = player

		game.ReplicatedStorage.ToggleTrap:FireClient(player,true)



	end
end

function module.TeleportPlayers(players, mapSpawns)



	for i, player in pairs(players) do
		if player.Character then
			local character = player.Character

			if character:FindFirstChild("HumanoidRootPart") then

				player.Character.Humanoid.WalkSpeed = 16

				local rand = Random.new()
				player.Character.HumanoidRootPart.CFrame = mapSpawns[rand:NextInteger(1,#mapSpawns)].CFrame + Vector3.new(0,10,0)

				local hitboxClone = game.ServerStorage.Hitbox:Clone()
				hitboxClone.CFrame = character.HumanoidRootPart.CFrame

				local weld = Instance.new("Weld")
				weld.Part1 = character.HumanoidRootPart
				weld.Part0 = hitboxClone
				weld.Parent = character

				hitboxClone.Parent = player.Character

			end
		end
	end

end


function module.InsertTag(contestants,tagName)
	for i, player in pairs(contestants) do
		local Tag = Instance.new("StringValue")
		Tag.Name = tagName
		Tag.Parent = player
	end
end

local function toMS(s)
	return ("%02i:%02i"):format(s/60%60, s%60)
end

function module.StartRound(length,teacher,chapterMap)

	local outcome

	game.ServerStorage.GameValues.GameInProgress.Value = true


	for i = length,0,-1 do

		if i == (length - 20) then
			module.TeleportPlayers({teacher},chapterMap.PlayerSpawns:GetChildren())
			status.Value = "Der Lehrer ist da"
			wait(2)
		end

		local contestants ={}

		local isTeacherHere =false

		local Escapees = 0

		for i, player in pairs(game.Players:GetPlayers()) do

			if player:FindFirstChild("Contestant") then
				table.insert(contestants,player)
			elseif player:FindFirstChild("Teacher") then
				isTeacherHere = true
			end

			if player:FindFirstChild("Escaped") then
				Escapees = Escapees + 1
			end

		end

		if Escapees > 0 then
			outcome ="escaped"
			break
		end

		if not isPiggyHere then
			outcome = "Teacher-left"
			break
		end

		if #contestants == 0 then
			outcome = "Teacher-killed-everyone"
			break
		end

		if i == 0 then
			outcome= "time-up"
			break
		end

		status.Value = toMS(i)
		wait(1)
	end

	if outcome == "Teacher-killed-everyone" then
		status.Value = "Der Lehrer macht alle Kalt"
	elseif outcome == "time-up" then
		status.Value = "Time Up"
	elseif outcome == "Teacher-left" then
		status.Value ="Der Lehrer ist weg"
	elseif outcome == "escaped" then
		status.Value = "Die Tür ist auf und der erste raus"
		wait(5)

		status.Value ="Beeilt euch befor es zu spät ist "
		wait(30)

	end



	wait(5)

end

function module.RemoveTags()

	game.ServerStorage.GameValues.GameInProgress.Value = false

	game.ReplicatedStorage.ToggleCrouch:FireAllClients(false)

	for i, v in pairs(game.Players:GetPlayers()) do
		if v:FindFirstChild("Teacher") then
			v.Teacher:Destroy()

			if v.Backpack:FindFirstChild("TeacherBat") then v.Backpack.TeacherBat:Destroy() end
			if v.Character:FindFirstChild("TeacherBat") then v.Character.TeacherBat:Destroy() end

			if v:FindFirstChild("TrapCount") then
				v.TrapCount:Destroy()
			end

			game.ReplicatedStorage.ToggleTrap:FireClient(v,false)

			v:LoadCharacter()

		elseif v:FindFirstChild("Contestant") then
			v.Contestant:Destroy()

			for _, p in pairs(v.Backpack:GetChildren()) do
				if p:IsA("Tool") then
					p:Destroy()
				end
			end

			for _, p in pairs(v.Character:GetChildren()) do
				if p:IsA("Tool") then
					p:Destroy()
				end
			end

		end
	end



end

return module
