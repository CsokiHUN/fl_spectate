function getPlayerList()
	local players = {}
	for _, serverId in pairs(GetPlayers()) do
		local xPlayer = ESX.GetPlayerFromId(serverId)
		if xPlayer then
			local job = xPlayer.getJob()
			local jobText = job.label .. " - " .. job.grade_label

			table.insert(players, {
				serverId = serverId,
				name = xPlayer.getName() .. " (" .. GetPlayerName(serverId) .. ")",
				group = xPlayer.getGroup(),
				jobText = jobText,
			})
		end
	end

	return players
end

ESX.RegisterServerCallback("requestServerPlayers", function(source, cb)
	local xSource = ESX.GetPlayerFromId(source)

	if not xSource or not ALLOWED_GROUPS[xSource.getGroup()] then
		return cb(false)
	end

	cb(getPlayerList())
end)

ESX.RegisterServerCallback("requestPlayerCoords", function(source, cb, serverId)
	local xSource = ESX.GetPlayerFromId(source)

	if not xSource then
		return cb(false)
	end

	local targetPed = GetPlayerPed(serverId)
	if targetPed <= 0 or not ALLOWED_GROUPS[xSource.getGroup()] then
		return cb(false)
	end

	cb(GetEntityCoords(targetPed))
end)

ESX.RegisterServerCallback("kickPlayerSpectate", function(source, cb, target, reason)
	local xSource = ESX.GetPlayerFromId(source)
	if not xSource or not ALLOWED_GROUPS[xSource.getGroup()] then
		return
	end

	DropPlayer(target, ("Kicked from the server.\nReason: %s\nAdmin: %s"):format(GetPlayerName(source), reason))

	cb(getPlayerList())
end)

RegisterCommand("spectate", function(player)
	local xPlayer = ESX.GetPlayerFromId(player)
	if not xPlayer or not ALLOWED_GROUPS[xPlayer.getGroup()] then
		return
	end

	TriggerClientEvent("openSpectateMenu", player, getPlayerList())
end)
