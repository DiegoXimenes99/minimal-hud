return {
	isSeatbeltOn = function()
		if GetResourceState('jim-mechanic') == 'started' then
			return exports['jim-mechanic']:seatBeltOn()
		else
			return LocalPlayer.state.isSeatbeltOn or false -- Adjust based on your framework
		end
	end,
	getVehicleFuel = function(currentVehicle)
		if GetResourceState('ps-fuel') == 'started' then
			return exports['ps-fuel']:GetFuel(currentVehicle)
		elseif GetResourceState('cdn-fuel') == 'started' then
			return exports['cdn-fuel']:GetFuel(currentVehicle)
		elseif GetResourceState('LegacyFuel') == 'started' then
			return exports['LegacyFuel']:GetFuel(currentVehicle)
		elseif GetResourceState('ox_fuel') == 'started' then
			return Entity(currentVehicle).state.fuel
		else
			return GetVehicleFuelLevel(currentVehicle)
		end
	end,
	getNosLevel = function(currentVehicle) -- Integration with mri_qnitro
		if GetResourceState('mri_Qnitro') == 'started' then
			-- Try different export methods for mri_qnitro
			local success, nitroLevel = pcall(function()
				return exports['mri_Qnitro']:GetNitroLevel(currentVehicle)
			end)

			if success and nitroLevel then
				return math.floor(nitroLevel * 100) -- Convert to percentage (0-100)
			end

			-- Alternative method - try getting from vehicle state
			success, nitroLevel = pcall(function()
				return Entity(currentVehicle).state.nitro or 0
			end)

			if success and nitroLevel then
				return math.floor(nitroLevel)
			end

			-- Another alternative - try direct export call
			success, nitroLevel = pcall(function()
				return exports['mri_Qnitro']:getNitroLevel(currentVehicle)
			end)

			if success and nitroLevel then
				return math.floor(nitroLevel * 100)
			end
		end
		return 0
	end,
}
