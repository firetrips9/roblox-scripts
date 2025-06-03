local weaponSystem = require(game:service'ReplicatedStorage'.WeaponsSystem.Libraries.BaseWeapon)

local client = game:GetService('Players').LocalPlayer;

local oldFire = weaponSystem.fire;
local oldGetConfigValue = weaponSystem.getConfigValue
local oldUseAmmo = weaponSystem.useAmmo;
local oldGetAmmo = weaponSystem.getAmmoInWeapon

local function getClosestPlayer()
    local final = nil
    local maxRange = math.huge;

    for i, player in next, game:GetService('Players'):GetPlayers() do
        if player == client then continue end
        if (not player.Character) then continue end

        local humanoid = player.Character:FindFirstChild('Humanoid');
        local head = player.Character:FindFirstChild('Head');

        if (not head) or (not humanoid) then continue end
        if (humanoid.Health <= 0) then continue end

        local vector, visible = workspace.CurrentCamera:WorldToViewportPoint(head.Position);
        if (not visible) then continue end

        local cursorPosition = game:GetService('UserInputService'):GetMouseLocation();
        local screenPosition = Vector2.new(vector.X, vector.Y);

        local difference = math.floor((screenPosition - cursorPosition).magnitude);
        if (difference < maxRange) then
            maxRange = difference
            final = head;
        end
    end
    return final;
end

function weaponSystem.getAmmoInWeapon(self, ...)
    local arguments = {...}
    if _G.infiniteAmmo then return 9e9 end
    return oldGetAmmo(self, unpack(arguments))
end

function weaponSystem.fire(self, ...)
    local arguments = {...};

    if _G.silentAim then
        local t = getClosestPlayer()
        if t then
            arguments[2] = (t.Position - arguments[1]).unit;
            arguments[3] = 1;
        end
    end

    return oldFire(self, unpack(arguments))
end

function weaponSystem.getConfigValue(self, ...)
    local arguments = {...}

    if _G.fastFire and arguments[1] == 'ShotCooldown' then
        return 0.01
    elseif _G.autoGuns and arguments[1] == 'FireMode' then
        return 'Automatic'
    elseif _G.noRecoil and (arguments[1] == 'RecoilMin' or arguments[1] == 'RecoilMax') then
        return 0
    elseif _G.noSpread and (arguments[1] == 'MinSpread' or arguments[1] == 'MaxSpread') then
        return 0
    end

    return oldGetConfigValue(self, unpack(arguments))
end

function weaponSystem.useAmmo(self, ...)
    local arguments = {...}
    if _G.infiniteAmmo then
        if (self.ammoInWeaponValue) then
            return 1;
        end
    end
    return oldUseAmmo(self, unpack(arguments))
end
