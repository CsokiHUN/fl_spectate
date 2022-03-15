function getPlayerList()
	local players = {}
	for _, serverId in pairs(GetPlayers()) do
		local xPlayer = ESX.GetPlayerFromId(serverId)

		local job = xPlayer.getJob()
		local jobText = job.label .. " - " .. job.grade_label

		table.insert(players, {
			serverId = serverId,
			name = xPlayer.getName() .. " (" .. GetPlayerName(serverId) .. ")",
			group = xPlayer.getGroup(),
			jobText = jobText,
		})
	end

	return players
end

ESX.RegisterServerCallback("requestServerPlayers", function(source, cb)
	local xSource = ESX.GetPlayerFromId(source)

	if not ALLOWED_GROUPS[xSource.getGroup()] then
		return cb(false)
	end

	cb(getPlayerList())
end)

ESX.RegisterServerCallback("requestPlayerCoords", function(source, cb, serverId)
	local xSource = ESX.GetPlayerFromId(source)

	local targetPed = GetPlayerPed(serverId)
	if targetPed <= 0 or not ALLOWED_GROUPS[xSource.getGroup()] then
		return cb(false)
	end

	cb(GetEntityCoords(targetPed))
end)

ESX.RegisterServerCallback("kickPlayerSpectate", function(source, cb, target)
	local xSource = ESX.GetPlayerFromId(source)
	if not ALLOWED_GROUPS[xSource.getGroup()] then
		return
	end

	DropPlayer(target, "Spectate menu ~ Admin: " .. GetPlayerName(source))
	cb(getPlayerList())
end)

RegisterCommand("spectate", function(player, args, cmd)
	local xPlayer = ESX.GetPlayerFromId(player)
	if not ALLOWED_GROUPS[xPlayer.getGroup()] then
		return
	end

	TriggerClientEvent("openSpectateMenu", player, getPlayerList())
end)
