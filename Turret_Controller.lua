
local turrets = {}
for address,_ in component.list("os_energyturret") do
    local turret = component.proxy(address)
    table.insert(turrets, turret)
end

for _,turret in pairs(turrets) do
    turret.powerOn()
    turret.setArmed(true)
end

function fireTurrets()
    for _,turret in pairs(turrets) do
        if turret.isOnTarget() then
            turret.fire()
        end
    end
end
