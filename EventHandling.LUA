local keyModule =require(script.Parent:WaitForChild("Game Logic").KeyModule)

local roundModule = require(script.Parent:WaitForChild("Game Logic").RoundModule)


game.Players.PlayerAdded:Connect(function(player)




	local piggyTokens = Instance.new("IntValue")
	piggyTokens.Name = "Tokens"
	piggyTokens.Value = 1000
	piggyTokens.Parent = player

	local trapInventory = Instance.new("Folder")
	trapInventory.Name = "TrapInventory"
	trapInventory.Parent = player

	local skinInventory = Instance.new("Folder")
	skinInventory.Name = "SkinInventory"
	skinInventory.Parent = player

	local equippedTrap = Instance.new("StringValue")
	equippedTrap.Name = "EquippedTrap"
	equippedTrap.Parent = player

	local equippedSkin = Instance.new("StringValue")
	equippedSkin.Name = "EquippedSkin"
	equippedSkin.Parent = player


	local inMenu =Instance.new("BoolValue")
	inMenu.Name = "InMenu"
	inMenu.Parent = player

	player.CharacterAdded:Connect(function(char)
		char.Humanoid.Died:Connect(function()


			if char:FindFirstChild("HumanoidRootPart") then
				keyModule.DropTools(player,game.Workspace.Map,char.HumanoidRootPart.Position)
				print("Tools dropped")
			end

			if player:FindFirstChild("Contestant") then
				player.Contestant:Destroy()
			elseif player:FindFirstChild("teacher") then
				player.Teacher:Destroy()
			end
		end)
	end)

end)

local trapDebounce = false

game.ReplicatedStorage.PlaceTrap.OnServerEvent:Connect(function(player)
	if player:FindFirstChild("Teacher") then
		if player:FindFirstChild("TrapCount")then
			if not trapDebounce then
				trapDebounce = true

				if player.TrapCount.Value > 0 then
					if game.Workspace:FindFirstChild("Map") then
						player.TrapCount.Value = player.TrapCount.Value -1

						local trap

						if player.EquippedTrap.Value ~= "" then
							if game.ReplicatedStorage.Traps:FindFirstChild(player.EquippedTrap.Value) then
								trap = game.ReplicatedStorage.Traps[player.EquippedTrap.Value]:Clone()
							end
						else
							trap = game.ReplicatedStorage.Traps["Noob Trap"]:Clone()
						end



						trap.CFrame = player.Character.HumanoidRootPart.CFrame - Vector3.new(0,3.5,0)
						trap.Parent = game.Workspace:FindFirstChild("Map")

					end
				end



				wait(5)

				trapDebounce = false


			end
		end
	end
end)

--für die lobby
game.ReplicatedStorage.MenuPlay.OnServerEvent:Connect(function(player)
	if player:FindFirstChild("InMenu") then

		player.InMenu:Destroy()
	end


	if game.ServerStorage.GameValues.GameInProgress.Value == true then
		local constant = Instance.new("BoolValue")
		constant.Name = "Contestant"
		constant.Parent = player

		game.ReplicatedStorage.ToggleCrouch:FireClient(player,true)

		roundModule.TeleportPlayers({player},game.Workspace:FindFirstChild("Map").PlayerSpawns:GetChildren())

	end


end)


game.ReplicatedStorage.BuyItem.OnServerInvoke = function(player,itemName,itemType)
	local item
	local inInventory
	if itemType == "skin" then

		item = game.ReplicatedStorage.Skins:FindFirstChild(itemName)

		if player.SkinInventory:FindFirstChild(itemName) then
			inInventory = true
		end

	elseif itemType == "trap" then

		item = game.ReplicatedStorage.Traps:FindFirstChild(itemName)

		if player.TrapInventory:FindFirstChild(itemName) then
			inInventory = true
		end
	end

	if item then
		if item:FindFirstChild("Cost") then
			if not	inInventory then
				if item.Cost.Value <= player.Tokens.Value then
					print("You can Buy this")

					player.Tokens.Value = player.Tokens.Value - item.Cost.Value

					local stringValue = Instance.new("StringValue")
					stringValue.Name = item.Name

					if itemType == "skin" then
						stringValue.Parent = player.SkinInventory
					elseif itemType == "trap" then
						stringValue.Parent = player.TrapInventory

					end

					return "bought"

				else
					return "failed"

				end
			else
				print("Youalready own this item")
				if itemType == "skin" then
					player.EquippedSkin.Value = itemName
				elseif itemType == "trap" then
					player.EquippedTrap.Value = itemName
				end
				return "equipped"

			end
		end
	else
		print("No skin/trap of such name found")
		return "failed"
	end

end
