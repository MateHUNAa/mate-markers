local ped = PlayerPedId()


local markers = {}
local streamed = {}
local isRendering = false
local markerPanelShow = false
local txd = CreateRuntimeTxd("markers-txd")

local currentDim = 0
local loadedTxd = {}

RegisterNetEvent("rime-dimensions->Update" , function(newDim)
   currentDim = newDim
 end) 

local function registerTXD(key, path)
     CreateRuntimeTextureFromImage(txd, key, path)
     loadedTxd[key] = true
end

registerTXD("garage_impound", "icons/garage_impound.png")
registerTXD("garage_normal", "icons/garage_normal.png")
registerTXD("garage_faction", "icons/garage_faction.png")
registerTXD("faction_impound", "icons/faction_impound.png")
registerTXD("door", "icons/door.png")
registerTXD("robbery", "icons/robbery.png")


DEFAULT_MARKER = {
     streamDistance = 10,
     typ            = 1,
     scale          = vector3(0.8, 0.8, 0.8),
     upDown         = false,
     rotate         = false,
     color          = { 255, 165, 0, 150 },
     pos            = vector3(0, 0, 70),
}

---@class marker_props
---@field id string The unique identifier for the marker
---@field pos vector3 The position of the marker
---@field typ number The type of the marker
---@field scale vector3 The scale of the marker.
---@field color table The color of the marker in `{r, g, b, a}` format.
---@field streamDistance number The maximum distance at which the marker is visible
---@field upDown boolean The marker bobs up/down
---@field rotate boolean Rotate marker
---@field invoker string The script invoker

---@class Marker
---@field AddMarker fun(props: marker_props) Adds a new marker.
---@field RemoveMarker fun(id: string) Remove's a marker.
---@field MoveMarker fun(id: string, newPos: vector3) Set's a new position to the marker
---@field UpdateMarkerData fun(id: string, key: string, val: any) Updates a specific prop of the marker

---@param props marker_props
function AddMarker(props)
     local invoker <const> = GetInvokingResource() or GetCurrentResourceName()
     local id = invoker .. props.id

     for key, value in pairs(DEFAULT_MARKER) do
          if not props[key] then
               props[key] = value
          end
     end

     props.invoker = invoker
     markers[id]   = props
end

exports("AddMarker", AddMarker)


---@param id string Marker identifier
function RemoveMarker(id)
     local invoker <const> = GetInvokingResource() or GetCurrentResourceName()
     id                    = invoker .. id

     markers[id]           = nil
end

---@param id string Marker identifier
---@param pos vector3 New Position in a vec3
function MoveMarker(id, pos)
     local invoker <const> = GetInvokingResource() or GetCurrentResourceName()
     id                    = invoker .. id

     markers[id].pos       = vec3(pos.x, pos.y, pos.z)
end

exports("RemoveMarker", RemoveMarker)
exports("MoveMarker", MoveMarker)

---@param id string marker identifier
---@param key string propKey
---@param val any value
function UpdateMarkerData(id, key, val)
     local invoker <const> = GetInvokingResource() or GetCurrentResourceName()
     id                    = invoker .. id

     if markers[id] then
          markers[id][key] = val
     end
end

exports("UpdateMarkerData", UpdateMarkerData)


AddEventHandler("onResourceStop", (function(res)
     for id, props in pairs(markers) do
          if (props.invoker or "") == res then
               markers[id] = nil
          end
     end
end))


function ShouldShowMarker(factionID)
     return true
end

local function render()
     isRendering = true

     while next(streamed) do
          local housingOpenedNow

          for id, props in pairs(streamed) do
               if not markers[id] then
                    streamed[id] = nil
                    goto continue
               end

               if props.factionID and not ShouldShowMarker(props.factionID) then
                    goto continue
               end

               if not props.markerWhere or props.markerWhere() then
                    local dist = #(props.pos - GetEntityCoords(ped))
                    local color = props.color
                    local secondaryColor = props.secondaryColor or { r = 255, g = 255, b = 255 }
                    local alpha = (color[4] or 255) * (1 - (dist / props.streamDistance))

                    DrawMarker(
                         props.typ or 1,
                         props.pos,
                         vec3(0, 0, 0),
                         vec3(0, 0, 0),
                         props.scale or vec3(0.8, 0.8, 0.8),
                         color[1], color[2], color[3],
                         math.floor(alpha),
                         props.upDown or false,
                         false,
                         0,
                         props.rotate or false
                    )

                    if props.txdKey and props.txdVal then
                         if not loadedTxd[props.txdVal] then return print(props.txdKey .. " - " .. props.txdVal .. " | Not loaded !") end
                         DrawMarker(
                              43,
                              props.pos + vector(0, 0, 0.85),
                              vector3(0, 0, 0),
                              vector3(-89.9, 0, 180),
                              vector3(0.45, 0.45, 0),
                              secondaryColor.r or 255,
                              secondaryColor.g or 255,
                              secondaryColor.b or 255,
                              math.floor(alpha),
                              props.upDown or false,
                              true,
                              0,
                              props.rotate or false,
                              props.txdKey,
                              props.txdVal,
                              false
                         )
                    end
               end

               if props.inMarker then
                    if props.help then
                         local where = props.helpWhere or function()
                              return true
                         end

                         if where() then
                              exports["mate-infopanel"]:show(props.help, props.helpImage or nil, 3000, true)
                         end
                    end
                    if props.onInteract then
                         local canInteract = props.canInteract or function()
                              return true
                         end

                         if canInteract() then
                              if IsControlJustPressed(0, 38) then
                                   CreateThread(function()
                                        props.onInteract()
                                   end)
                              end
                         end
                    end
               end

               ::continue::
          end

          Wait(1)
     end


     isRendering = false
end
exports("getCurrentMarker", (function()
     for id, props in pairs(streamed) do
          if props.inMarker then
               return {
                    id    = id,
                    props = props,
               }
          end
     end
     return nil
end))

local function hideMarkerPanel()
     if markerPanelShow then
          exports["mate-infopanel"]:hide()
          markerPanelShow = false
     end
end

CreateThread(function()
     while true do
          ped = PlayerPedId()
          local playerPos <const> = GetEntityCoords(ped)

          streamed = {}

          local inMarker = false

          for id, props in pairs(markers) do
               local pos <const> = props.pos
               local dist <const> = #(pos.xy - playerPos.xy)

               if dist <= props.streamDistance and IsSphereVisible(pos.x, pos.y, pos.z, props.scale.z) then
                    props.inMarker = dist <= props.scale.z
                    if props.inMarker then
                         local where = props.helpWhere or function()
                              return true
                         end
                         if where() then
                              inMarker = true
                              markerPanelShow = true
                         end
                    end
                    streamed[id] = props
               end
          end

          if next(streamed) and not isRendering then
               CreateThread(render)
          end

          if not inMarker then
               hideMarkerPanel()
          end

          Wait(250)
     end
end)
