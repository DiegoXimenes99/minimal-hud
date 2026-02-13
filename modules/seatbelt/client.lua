local config = require("config.shared")
local logger = require("modules.utility.shared.logger")

local SeatbeltLogic = {}
SeatbeltLogic.__index = SeatbeltLogic

function SeatbeltLogic.new()
    if not config.useBuiltInSeatbeltLogic then
        logger.info("(SeatbeltLogic.new) Config.useBuiltInSeatbeltLogic is disabled.")
        return
    end

    local self = setmetatable({}, SeatbeltLogic)

    self.seatbeltState = false
    self.speedConversion = string.lower(config.speedUnit) == "mph" and 2.236936 or 3.6
    self.ejectVelocity = config.ejectMinSpeed / self.speedConversion
    self.unknownEjectVelocity = 1.0
    self.unknownModifier = 17.0
    self.minDamage = 10.0

    RegisterCommand("-toggle_seatbelt", function()
        local ped = PlayerPedId()
        logger.info("(SeatbeltLogic) Command -toggle_seatbelt triggered")

        if not IsPedInAnyVehicle(ped, false) or IsPedOnAnyBike(ped) then
            return logger.info("(SeatbeltLogic:toggle) Seatbelt is not available either due to the fact that the player is not in a vehicle or on a bike.")
        end

        self:toggle(not self.seatbeltState)
        logger.info("(commands:toggleSeatbelt) Toggled seatbelt to: ", self.seatbeltState)
    end, false)

    SetPedConfigFlag(PlayerPedId(), 32, true)
    SetFlyThroughWindscreenParams(self.ejectVelocity, self.unknownEjectVelocity, self.unknownModifier, self.minDamage)
    RegisterKeyMapping("-toggle_seatbelt", "Toggle Seatbelt", "keyboard", "B")
    
    -- Comando alternativo para teste
    RegisterCommand("testseatbelt", function()
        local ped = PlayerPedId()
        logger.info("(SeatbeltLogic) Test command triggered")
        
        if not IsPedInAnyVehicle(ped, false) or IsPedOnAnyBike(ped) then
            return logger.info("(SeatbeltLogic:test) Not in vehicle or on bike")
        end
        
        self:toggle(not self.seatbeltState)
        logger.info("(SeatbeltLogic:test) Toggled seatbelt to: ", self.seatbeltState)
    end, false)
    
    -- Adicionar mapeamento para tecla G também
    RegisterCommand("seatbelt", function()
        ExecuteCommand("-toggle_seatbelt")
    end, false)
    RegisterKeyMapping("seatbelt", "Toggle Seatbelt (G)", "keyboard", "G")

    return self
end

---@param state boolean
function SeatbeltLogic:toggle(state)
    logger.info("(SeatbeltLogic:toggle) Called with state: ", state)
    self.seatbeltState = state

    if state then
        logger.info("(SeatbeltLogic:toggle) Seatbelt ON - Setting windscreen params and disabling exit")
        SetFlyThroughWindscreenParams(10000.0, 10000.0, 17.0, 500.0)
        self:disableVehicleExitControlThread()
        return
    end

    logger.info("(SeatbeltLogic:toggle) Seatbelt OFF - Restoring windscreen params")
    SetFlyThroughWindscreenParams(self.ejectVelocity, self.unknownEjectVelocity, self.unknownModifier, self.minDamage)
end

function SeatbeltLogic:disableVehicleExitControlThread()
    Citizen.CreateThread(function()
        logger.info("(SeatbeltLogic:disableVehicleExitControlThread) Thread enabled.")
        while self.seatbeltState do
            DisableControlAction(0, 75, true) -- 75: INPUT_VEH_EXIT
            Wait(0)
        end
        logger.info("(SeatbeltLogic:disableVehicleExitControlThread) Thread disabled.")
    end)
end

function SeatbeltLogic:isSeatbeltOn()
    logger.info("(SeatbeltLogic:isSeatbeltOn) Returning: ", self.seatbeltState)

    return self.seatbeltState
end

return SeatbeltLogic
