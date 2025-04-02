# mate-markers



# Valid Input data
```lua
DEFAULT_MARKER = {
     streamDistance = 10,
     typ            = 1,
     scale          = vector3(0.8, 0.8, 0.8),
     upDown         = false,
     rotate         = false,
     color          = { 255, 165, 0, 150 },
     pos            = vector3(0, 0, 70),
}
```

```lua
OPTIONAL_MARKER = {
     ---@return boolean Statement function: Allow infopanel to be visible.
     markerWhere = function() 
          return true -- Default value
     end,

     txdKey = "", -- Draw icon into the marker.
     txdVal = "", -- Draw icon into the marker.

     secondaryColor = { r= 255, g = 255, b=255, a?=number} -- IconMarker color

     ---@return boolean Statement function: Can interact with the marker !
     canInteract = function()
          return true -- Default value
     end,

     ---@return nil
     onInteract = function()
          print("[E] is pressed !")
     end,
}
```

# Functions

```lua
     local Marker = exports["mate-markers"]

     Marker:AddMarker({
          --- Everything from DEFAULT_MARKER if not overrwritten.
          id = "uniqueId",
          pos = vec3(0.0,0.0,0.0)
     })
```

```lua
     local Marker = exports["mate-markers"]

     Marker:RemoveMarker("Marker_ID")
```

```lua
     local Marker = exports["mate-markers"]

     local newpos = vec3(1.0,1.0,1.0)
     Marker:MoveMarker("Marker_ID", vec3(newpos.x,newpos.y,newpos.z))
```

```lua
     local Marker = exports["mate-markers"]

     Marker:UpdateMarkerData("Marker_Id", "scale", vec3(1.0,1.0,1.0))
     Marker:UpdateMarkerData("Marker_Id", "color", {r=255,g=0,b=155})
```
