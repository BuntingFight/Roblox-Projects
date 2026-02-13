local is_pathfinding = false
local PathfindingService = game:GetService("PathfindingService")
local Players = game:GetService("Players")
local player = Players.LocalPlayer

local function MODEL_(model)
    if not model then
        return {Type = "AllModels"}
    end
    return {Type = "Model", Instance = model}
end

local function PART_(part)
    if not part then
        return function(name)
            return {Type = "PartByName", Name = name}
        end
    end
    return {Type = "Part", Instance = part}
end

local function get_all_parts(instance)
    local parts = {}
    if instance:IsA("BasePart") then
        table.insert(parts, instance)
    end
    for _, child in ipairs(instance:GetDescendants()) do
        if child:IsA("BasePart") then
            table.insert(parts, child)
        end
    end
    return parts
end

local function get_all_models()
    local models = {}
    for _, descendant in ipairs(workspace:GetDescendants()) do
        if descendant:IsA("Model") then
            table.insert(models, descendant)
        end
    end
    return models
end

local function get_parts_by_name(name)
    local parts = {}
    for _, descendant in ipairs(workspace:GetDescendants()) do
        if descendant:IsA("BasePart") and descendant.Name == name then
            table.insert(parts, descendant)
        end
    end
    return parts
end

local function process_ignore_list(ignore_list)
    local parts_to_ignore = {}
    for _, entry in ipairs(ignore_list) do
        if type(entry) == "table" then
            if entry.Type == "Model" and entry.Instance then
                for _, part in ipairs(get_all_parts(entry.Instance)) do
                    table.insert(parts_to_ignore, part)
                end
            elseif entry.Type == "AllModels" then
                for _, model in ipairs(get_all_models()) do
                    for _, part in ipairs(get_all_parts(model)) do
                        table.insert(parts_to_ignore, part)
                    end
                end
            elseif entry.Type == "Part" and entry.Instance then
                table.insert(parts_to_ignore, entry.Instance)
            elseif entry.Type == "PartByName" and entry.Name then
                for _, part in ipairs(get_parts_by_name(entry.Name)) do
                    table.insert(parts_to_ignore, part)
                end
            end
        elseif type(entry) == "function" then
            local result = entry
            if type(result) == "table" then
                for _, part in ipairs(process_ignore_list({result})) do
                    table.insert(parts_to_ignore, part)
                end
            end
        end
    end
    return parts_to_ignore
end

local function pathfind(target_position, ignore_list)
    if is_pathfinding then
        warn("Pathfinding already in progress")
        return false
    end

    is_pathfinding = true
    local character = player.Character or player.CharacterAdded:Wait()
    local humanoid = character:WaitForChild("Humanoid")
    local root_part = character:WaitForChild("HumanoidRootPart")
    local speed = 45
    local waypoint_distance = 0.1
    local height_offset = 5
    local climb_force = 50
    humanoid.AutoRotate = false
    local attachment = Instance.new("Attachment")
    attachment.Parent = root_part
    local linear_velocity = Instance.new("LinearVelocity")
    linear_velocity.Attachment0 = attachment
    linear_velocity.MaxForce = math.huge
    linear_velocity.VectorVelocity = Vector3.zero
    linear_velocity.Parent = root_part
    local align_orientation = Instance.new("AlignOrientation")
    align_orientation.Attachment0 = attachment
    align_orientation.MaxTorque = math.huge
    align_orientation.Responsiveness = 40
    align_orientation.Parent = root_part
    local body_gyro = Instance.new("BodyGyro")
    body_gyro.MaxTorque = Vector3.zero
    body_gyro.Parent = root_part

    local function cleanup()
        if linear_velocity then
            linear_velocity.VectorVelocity = Vector3.zero
        end
        task.wait(0.1)
        if linear_velocity then
            linear_velocity:Destroy()
        end
        if align_orientation then
            align_orientation:Destroy()
        end
        if attachment then
            attachment:Destroy()
        end
        if body_gyro then
            body_gyro:Destroy()
        end
        humanoid.AutoRotate = true
        humanoid:ChangeState(Enum.HumanoidStateType.Physics)
        task.wait(0.1)
        humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
        is_pathfinding = false
    end

    local settings = {
        AgentRadius = 2,
        AgentHeight = 5,
        AgentCanJump = true,
        AgentCanClimb = true,
        WaypointSpacing = 3,
        Costs = {}
    }

    if ignore_list then
        local parts_to_ignore = process_ignore_list(ignore_list)
        for _, part in ipairs(parts_to_ignore) do
            settings.Costs[part.Material] = math.huge
        end
    end

    local path = PathfindingService:CreatePath(settings)

    local success = pcall(function()
        path:ComputeAsync(root_part.Position, target_position)
    end)

    if not success or path.Status ~= Enum.PathStatus.Success then
        warn("Pathfinding failed")
        cleanup()
        return false
    end

    local waypoints = path:GetWaypoints()
    for index, waypoint in ipairs(waypoints) do
        local target = waypoint.Position + Vector3.new(0, height_offset, 0)
        if waypoint.Action == Enum.PathWaypointAction.Jump then
            humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
        local height_difference = 0
        if index < #waypoints then
            height_difference = waypoints[index + 1].Position.Y - waypoint.Position.Y
        end
        local is_climbing = height_difference > 5
        while (target - root_part.Position).Magnitude > waypoint_distance do
            local direction = (target - root_part.Position).Unit
            local velocity = direction * speed
            if is_climbing then
                local current_height = root_part.Position.Y
                local target_height = waypoint.Position.Y + height_offset
                if current_height < target_height then
                    velocity = velocity + Vector3.new(0, climb_force, 0)
                end
            end
            linear_velocity.VectorVelocity = velocity
            local flat_direction = Vector3.new(direction.X, 0, direction.Z)
            if flat_direction.Magnitude < 0.01 then
                flat_direction = root_part.CFrame.LookVector
            end
            align_orientation.CFrame = CFrame.new(root_part.Position, root_part.Position + flat_direction)
            task.wait()
        end
    end

    cleanup()
    return true
end

local ignore_list = {}

pathfind(Vector3.new(), ignore_list)
