CreateConVar("horde_max_wave", 5, SERVER_CAN_EXECUTE, "Max waves." )
CreateConVar("horde_difficulty", 0, SERVER_CAN_EXECUTE, "Difficulty.")
CreateConVar("horde_break_time", 60, SERVER_CAN_EXECUTE, "Break time between waves.")
CreateConVar("horde_enable_shop", 1, SERVER_CAN_EXECUTE, "Enables shop menu or not.")
CreateConVar("horde_enable_respawn", 0, SERVER_CAN_EXECUTE, "Players can respawn after death during a wave.")
CreateConVar("horde_max_spawn_distance", 2000, SERVER_CAN_EXECUTE, "Maximum enenmy respawn distance.")
CreateConVar("horde_min_spawn_distance", 500, SERVER_CAN_EXECUTE, "Minimum enenmy respawn distance.")
CreateConVar("horde_start_money", 1000, SERVER_CAN_EXECUTE, "Money given at start.")

HORDE = {}
HORDE.__index = HORDE
HORDE.color_crimson = Color(220, 20, 60)
HORDE.start_game = false
HORDE.total_enemies_per_wave = {10, 40, 60, 80, 100}
HORDE.total_enemies_this_wave = 0
HORDE.alive_enemies_this_wave = 0
HORDE.killed_enemies_this_wave = 0
HORDE.current_wave = 0
HORDE.total_break_time = math.max(10, GetConVarNumber("horde_break_time"))
HORDE.first_break_time = 10
HORDE.current_break_time = HORDE.first_break_time
HORDE.max_spawn_distance = math.max(100, GetConVarNumber("horde_max_spawn_distance"))
HORDE.min_spawn_distance = math.max(100, GetConVarNumber("horde_min_spawn_distance"))
HORDE.max_enemies_alive = 20
HORDE.spawned_enemies = {}
HORDE.ai_nodes = {}
HORDE.found_ai_nodes = false
HORDE.enemy_spawn_z = 15
HORDE.player_ready = {}
HORDE.max_waves = math.min(10, math.max(1, GetConVarNumber("horde_max_wave")))
HORDE.difficulty = math.min(2, math.max(0, GetConVarNumber("horde_difficulty")))
HORDE.enable_shop = GetConVarNumber("horde_enable_shop")
HORDE.start_money = math.max(0, GetConVarNumber("horde_start_money"))

-- Economy variables
HORDE.items = {}

HORDE.CreateItem = function (category, name, class, price, weight, description, whitelist, ammo_price)
    if category == nil or name == nil or class == nil or price == nil or weight == nil or description == nil then return end
    if category ~= "Melee" and category ~= "Pistol" and category ~= "SMG" and category ~= "MG" and category ~= "Shotgun" and category ~= "Rifle" and category ~= "Explosive" and category ~= "Special" and category ~= "Equipment" then return end
    if string.len(name) <= 0 or string.len(class) <= 0 then return end
    if price < 0 or weight < 0 then return end
    local item = {}
    item.category = category
    item.name = name
    item.class = class
    item.price = price
    item.weight = weight
    item.description = description
    item.whitelist = whitelist
    item.ammo_price = ammo_price
    HORDE.items[item.class] = item
    SetItemsData()
end

function SetItemsData()
	if not file.IsDir('horde', 'DATA') then
		file.CreateDir('horde')
	end
	
	file.Write('horde/items.txt', util.TableToJSON(HORDE.items))
end

function GetItemsData()
    if not file.IsDir('horde', 'DATA') then
		file.CreateDir('horde')
        return
	end
    
    if file.Read('horde/items.txt', 'DATA') then
        HORDE.items = util.JSONToTable(file.Read('horde/items.txt', 'DATA'))
    end
end

GetItemsData()

HORDE.max_weight = 15
HORDE.default_ammo_price = 10

-- Class
HORDE.classes = {}
HORDE.CreateClass = function (name, description, max_hp, movespd, sprintspd)
    local class = {}
    class.name = name
    class.description = description
    class.max_hp = max_hp
    class.movespd = movespd
    class.sprintspd = sprintspd
    HORDE.classes[class.name] = class
end
-- Only allow 1 change per wave
HORDE.player_class_changed = {}

-- Enemies
HORDE.enemies = {}
HORDE.enemies_normalized = {}
HORDE.CreateEnemy = function (class, weight, wave)
    if class == nil then return end
    local enemy = {}
    enemy.class = class
    enemy.weight = math.min(1,weight)
    enemy.wave = math.max(1,wave)
    HORDE.enemies[tostring(enemy.class) .. tostring(enemy.wave)] = enemy
end

HORDE.FinalizeEnemies = function ()
    if table.IsEmpty(HORDE.enemies) then return end
    -- Normalize
    for wave = 1, HORDE.max_waves do
        HORDE.enemies_normalized[wave] = {}
        local total_weight = 0
        for _, enemy in pairs(HORDE.enemies) do
            if enemy.wave == wave then
                total_weight = total_weight + enemy.weight
            end
        end
        for _, enemy in pairs(HORDE.enemies) do
            if enemy.wave == wave then
                HORDE.enemies_normalized[wave][enemy.class] = enemy.weight / total_weight
            end
        end
    end
    PrintTable(HORDE.enemies_normalized)
    SetEnemiesData()
end

function SetEnemiesData()
	if not file.IsDir('horde', 'DATA') then
		file.CreateDir('horde')
	end
	
	file.Write('horde/enemies.txt', util.TableToJSON(HORDE.enemies))
end

function GetEnemiesData()
    if not file.IsDir('horde', 'DATA') then
		file.CreateDir('horde')
        return
	end
    
    if file.Read('horde/enemies.txt', 'DATA') then
        HORDE.enemies = util.JSONToTable(file.Read('horde/enemies.txt', 'DATA'))
        HORDE.FinalizeEnemies()
    end
end

GetEnemiesData()