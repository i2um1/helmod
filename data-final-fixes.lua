local data_entity = {}

-- recherche tout les types item
for type,elements in pairs(data.raw) do
  if type =="item" then
    for _,element in pairs(elements) do
      local entity = {}
      entity.type = element.type
      data_entity[element.name] = entity
    end
  end
end
-- recherche des attributs non visible pour les items precedents
for type,elements in pairs(data.raw) do
  if type ~="item" then
    for _,element in pairs(elements) do
      if element.name ~= nil and element.type ~= "recipe" then
        local entity = data_entity[element.name]
        if entity ~= nil then
          -- util pour le generation de list
          if element.type == "generator" then
            entity.classification = "generator"
            if element.fluid_usage_per_tick ~= nil then entity.fluid_usage = element.fluid_usage_per_tick end
            if element.effectivity ~= nil then entity.effectivity = element.effectivity end
            if element.maximum_temperature ~= nil then entity.maximum_temperature = element.maximum_temperature end
          end
          if element.type == "solar-panel" then 
            entity.classification = "solar-panel"
            if element.production ~= nil then entity.production = element.production end
          end
          if element.type == "boiler" then
            entity.classification = "boiler"
            if element.energy_consumption ~= nil then entity.energy_consumption = element.energy_consumption end
            -- necessaire pour le calcul de puissance
            if element.target_temperature ~= nil then entity.target_temperature = element.target_temperature end
            if element.energy_source ~= nil and element.energy_source.effectivity ~= nil then entity.effectivity = element.energy_source.effectivity end
          end
          
          if element.type == "accumulator" then
            entity.classification = "accumulator"
            if element.energy_source ~= nil and element.energy_source.buffer_capacity ~= nil then entity.buffer_capacity = element.energy_source.buffer_capacity end
            if element.energy_source ~= nil and element.energy_source.input_flow_limit ~= nil then entity.input_flow_limit = element.energy_source.input_flow_limit end
            if element.energy_source ~= nil and element.energy_source.output_flow_limit ~= nil then entity.output_flow_limit = element.energy_source.output_flow_limit end
          end
          -- proprietes pour les usines
          if element.distribution_effectivity ~= nil then entity.efficiency = element.distribution_effectivity end
        end
      end
    end
  end
end

-- @see https://mods.factorio.com/mods/Earendel/data-raw-prototypes

local chunk_suffix = "_"
local function save_chunk (name, string)
    data:extend({{
      type = "flying-text",
      name = name,
      time_to_live = 0,
      speed = 1,
      order = string
    }})
end

local function chunkify(string)
    local chunkSize = 200
    local s = {}
    for i=1, #string, chunkSize do
        s[#s+1] = string:sub(i,i+chunkSize - 1)
    end
    return s
end

local function save_string (name, string)
    local chunks = chunkify(string)
    for i, chunk in ipairs(chunks) do
        save_chunk(name..chunk_suffix..i, chunk)
    end
end

save_string("data_entity", serpent.dump(data_entity))