Panel = {
	visible = false,
	selectedPlayer = false,
	lastCoords = false,

	init = function(self)
		RegisterNUICallback("spectate", function(...)
			self:spectate(...)
		end)

		RegisterNUICallback("kick", function(...)
			self:kick(...)
		end)

		RegisterNUICallback("close", function(...)
			self:close(...)
		end)

		RegisterNUICallback("update", function()
			self:update(false)
		end)

		RegisterNUICallback("spectateoff", function()
			self:spectateoff()
		end)
	end,

	open = function(self, players)
		self.visible = true
		self:update(players)
		SetNuiFocus(true, true)
		SendNUIMessage({
			visible = true,
		})
	end,

	close = function(self)
		self.visible = false
		SetNuiFocus(false, false)
		SendNUIMessage({
			visible = false,
		})
	end,

	update = function(self, players)
		if not players or type(players) == "boolean" then
			ESX.TriggerServerCallback("requestServerPlayers", function(players)
				if not players then
					return self:close()
				end

				SendNUIMessage({
					players = players,
				})
			end)
			return
		end

		SendNUIMessage({
			players = players,
		})
	end,

	spectate = function(self, data, cb)
		if self.selectedPlayer then
			return
		end

		local localPed = PlayerPedId()
		self.lastCoords = GetEntityCoords(localPed)

		local serverId = tonumber(data.player.serverId)
		if serverId == GetPlayerServerId(PlayerId()) then
			return TriggerEvent("chat:addMessage", {
				args = { "Server", "You can't spectate yourself." },
				color = { 0, 255, 0 },
			})
		end

		self.selectedPlayer = serverId

		ESX.TriggerServerCallback("requestPlayerCoords", function(coords)
			if not coords then
				self.lastCoords = false
				self.selectedPlayer = false
				return
			end
			CreateThread(updatePlayerInfo)

			RequestCollisionAtCoord(coords)
			SetEntityVisible(localPed, false)
			SetEntityCoords(localPed, coords + vector3(0, 0, 10))
			FreezeEntityPosition(localPed, true)
			Wait(1500)
			SetEntityCoords(localPed, coords - vector3(0, 0, 10))

			local targetPed = GetPlayerPed(GetPlayerFromServerId(serverId))
			NetworkSetInSpectatorMode(true, targetPed)
		end, serverId)

		self:close()
	end,

	kick = function(self, data, cb)
		ESX.TriggerServerCallback("kickPlayerSpectate", function(players)
			if not players then
				return self:close()
			end
			self:update(players)
		end, tonumber(data.player.serverId))
	end,

	spectateoff = function(self)
		self.selectedPlayer = false

		if self.lastCoords then
			local localPed = PlayerPedId()

			RequestCollisionAtCoord(self.lastCoords)
			NetworkSetInSpectatorMode(false, localPed)
			FreezeEntityPosition(localPed, false)
			SetEntityCoords(localPed, self.lastCoords)
			SetEntityVisible(localPed, true)
		end

		SendNUIMessage({
			playerInfo = false,
		})
	end,
}
Panel.__index = Panel
Panel:init()

RegisterNetEvent("openSpectateMenu", function(players)
	if Panel.visible then
		return
	end

	Panel:open(players)
end)

function updatePlayerInfo()
	while Panel.selectedPlayer do
		local playerId = GetPlayerFromServerId(Panel.selectedPlayer)
		local targetPed = GetPlayerPed(playerId)

		SendNUIMessage({
			playerInfo = {
				"GodMode: "
					.. (GetPlayerInvincible(Panel.selectedPlayer) and RED .. "Enabled" or GREEN .. "Disabled")
					.. "</span>",
				"AntiRagdoll: "
					.. (not CanPedRagdoll(targetPed) and RED .. "Enabled" or GREEN .. "Disabled")
					.. "</span>",
				"Health: " .. GetEntityHealth(targetPed) .. "/" .. GetEntityMaxHealth(targetPed),
				"Armor: " .. GetPedArmour(targetPed) .. "/" .. GetPlayerMaxArmour(playerId),
			},
		})

		Wait(1000)
	end
end

RegisterCommand("spectateoff", function()
	if Panel.selectedPlayer then
		TriggerEvent("chat:addMessage", {
			args = { "Server", "Spectate turned off" },
			color = { 0, 255, 0 },
		})
		Panel:spectateoff()
	end
end)
RegisterKeyMapping("spectateoff", "Spectate Kikapcsolas", "keyboard", "e")

exports('spectatePlayer', function(serverId)
	Panel:spectate({player = { serverId = serverId }})
end)

exports("isActive", function()
	return Panel.selectedPlayer
end)