ChernarusProjection = ->
  @origin = new google.maps.LatLng(1.920978, 0.284574)
  @size = 14.524823
  @unitsPerDegree = 256 / @size
initDayZMap = ->
  a = new google.maps.ImageMapType(
    getTileUrl: (a, b) ->
      (if 0 > a.x or 0 > a.y or a.x > mapTileCounts[b].x or a.y > mapTileCounts[b].y then null else dayz_staticUrl + "tiles/" + b + "/" + a.x + "_" + a.y + ".png")

    tileSize: new google.maps.Size(256, 256)
    minZoom: 2
    maxZoom: 6
    name: "Chernarus"
  )
  a.projection = dayzProjection
  b = new google.maps.LatLng(7.5, 7)
  c = 3
  d = null
  e = location.hash.substr(1).split(";")
  f = 0

  while f < e.length
    if null isnt (d = /^(\d)\.(\d{3})\.(\d{3})$/.exec(e[f]))
      c = parseInt(d[1], 10)
      b = fromGpsToCoord(d[2])
      d = fromGpsToCoord(d[3])
      b = new google.maps.LatLng(d, b)
    else if null isnt (d = /^item=(.+)$/.exec(e[f]))
      d = decodeURIComponent(d[1])
      $("#mapsearch input").val(d)
      searchForItem(d)
    ++f
  c =
    minZoom: 2
    maxZoom: 6
    inPng: not 0
    mapTypeControl: not 1
    center: b
    streetViewControl: not 1
    draggableCursor: "default"
    zoom: c
    mapTypeControlOptions:
      mapTypeIds: ["custom", google.maps.MapTypeId.ROADMAP]
      style: google.maps.MapTypeControlStyle.DROPDOWN_MENU

  dayzMap = new google.maps.Map(document.getElementById("map"), c)
  dayzMap.mapTypes.set "chernarus", a
  dayzMap.setMapTypeId "chernarus"
  google.maps.event.addListener dayzMap, "mousemove", (a) ->
    $("#mapCoords").html fromLatLngToGps(a.latLng)

  google.maps.event.addListener dayzMap, "dragend", updateHash
  google.maps.event.addListener dayzMap, "zoom_changed", updateHash
  addMarkers()
fromCoordToGps = (a) ->
  b = (1E3 * a).toString()
  b = (if 0 > a then "000" else (if 1 > a then "00" + b.substr(0, 1) else (if 10 > a then "0" + b.substr(0, 2) else b.substr(0, 3))))
fromGpsToCoord = (a) ->
  0.1 * parseInt(a, 10)
fromLatLngToGps = (a) ->
  b = fromCoordToGps(a.lat())
  fromCoordToGps(a.lng()) + " " + b
updateTypeVisibility = (a) ->
  b = $("button.iconToggle[data-type=\"" + a + "\"]")
  (if "other" is a then dayzMarkerVisibility[a] = 5 is $("div.other-group input.iconToggle:checked").length else (if "vehicles" is a then dayzMarkerVisibility[a] = 12 is $("div.vehicles-group input.iconToggle:checked").length else dayzMarkerVisibility[a].all = 3 is $("input.iconToggle[data-type=\"" + a + "\"]:checked").length))
  (if ("other" is a or "vehicles" is a) and dayzMarkerVisibility[a] or dayzMarkerVisibility[a].all then b.addClass("active") else b.removeClass("active"))
transformMarkerData = (a, b) ->
  e = undefined
  c =
    type: a
    suffix: ""
    open: not 1
    value: not 1

  if markerTypes[a] and markerTypes[a].type
    e = c.type = markerTypes[a].type
    a = e
  if markerTypes[a].rated
    if b and buildingTypes[b]
      d = buildingTypes[b]
      c.open = not 0  if d.open
      (if d.lootSpawns >= markerValueThresholds[a][2] then (c.suffix = " (high value)"
      c.value = "high"
      ) else (if d.lootSpawns >= markerValueThresholds[a][1] then (c.suffix = " (medium value)"
      c.value = "med"
      ) else (c.suffix = " (low value)"
      c.value = "low"
      )))
    else
      c.value = "low"
  c
addMarker = (a, b, c, d, e, f, g) ->
  c = new google.maps.LatLng(c, d)
  f = transformMarkerData(f, g)
  e += f.suffix
  a = new google.maps.Marker(
    position: c
    map: a
    icon: markerIcons[f.type + ((if f.open then "-open" else "")) + ((if f.value then "-" + f.value else ""))]
    title: e
    zIndex: (if undefined isnt markerZIndex[f.value] then markerZIndex[f.value] else markerZIndex["default"])
  )
  a.markerId = b
  a.building = g
  a.markerType = f.type
  a.markerValue = f.value
  a.markerOpen = f.open
  shownBuildings and ((if -1 < shownBuildings.indexOf(g) then a.setVisible(not 0) else a.setVisible(not 1)))
  google.maps.event.addListener a, "click", onMarkerClick
  dayzMarkers.push a
  a
onMarkerClick = (a) ->
  a = this
  openMarkerTooltip()
  b = $("#sidebarTooltip")
  b.empty()
  b.append $("<button/>",
    class: "close"
    html: "&times;"
    click: ->
      closeMarkerTooltip()
  )
  if a.building and (b.append($("<div/>",
    class: "thumbnail"
  ).append($("<img/>",
    src: dayz_staticUrl + "icons/buildings/" + a.building + ".jpg"
  )))
  buildingTypes[a.building]
  )
    c = buildingTypes[a.building]
    d = buildingSets[c.type]
    e = buildingLoot[d.loot]
    f = $("<ul/>")
    f.append $("<li/>",
      class: "minimal"
      text: "Building: " + a.building
    )
    f.append $("<li/>",
      text: "Zombie chance: " + ((if c.zombieChance then c.zombieChance else d.zombieChance))
    )
    f.append $("<li/>",
      text: "Zombie count: " + ((if undefined isnt c.minRoaming then c.minRoaming else d.minRoaming)) + " - " + ((if undefined isnt c.maxRoaming then c.maxRoaming else d.maxRoaming))
    )
    f.append $("<li/>",
      text: "Loot chance: " + ((if c.lootChance then c.lootChance else d.lootChance))
    )
    f.append $("<li/>",
      text: "Loot spawns: " + ((if c.lootSpawns then c.lootSpawns else d.lootSpawns))
    )
    b.append f
    a = $("<table/>",
      class: "table table-condensed"
    )
    c = e.length
    d = 0
    while d < c
      g = e[d]
      if g.name
        f = (if lootNames[g.name] then lootNames[g.name] else g.name)
        a.append($("<tr/>").append($("<td/>").append($("<a/>",
          href: "/database/" + urlize(f)
          text: f
        ))).append($("<td/>",
          text: g.chance
        )))
      else if g.set
        a.append $("<tr/>").append($("<th/>").append($("<a/>",
          href: "javascript:;"
          html: lootSetNames[g.set]
          click: ->
            $(this).parent().parent().next().children().toggle()
        ))).append($("<th/>",
          text: g.chance
        ))
        j = $("<table/>",
          class: "table table-condensed"
        )
        g = lootSets[g.set]
        i = g.length
        h = 0

        while h < i
          k = g[h]
          f = (if lootNames[k.name] then lootNames[k.name] else k.name)
          j.append $("<tr/>").append($("<td/>").append($("<a/>",
            href: "/database/" + urlize(f)
            text: f
          ))).append($("<td/>",
            text: k.chance
          ))
          ++h
        a.append $("<tr/>").append($("<td/>",
          class: "sublist"
          colspan: 2
        ).append(j))
      ++d
    b.append a
openMarkerEditor = ->
  $("#sidebar").addClass "editor-open"
closeMarkerEditor = ->
  $("#sidebar").removeClass "editor-open"
openMarkerTooltip = ->
  $("#sidebar").addClass "tip-open"
  a = $("#sidebarButton")
  a.hasClass("closed") and a.click()
closeMarkerTooltip = ->
  $("#sidebar").removeClass "tip-open"
setMarkerVis = (a, b, c) ->
  d = 0

  while d < dayzMarkers.length
    dayzMarkers[d].markerType is a and (not b or b is dayzMarkers[d].markerValue) and dayzMarkers[d].setVisible(c)
    d++
  (if b then dayzMarkerVisibility[a][b] = c else dayzMarkerVisibility[a] = c)
addMarkers = ->
  for a of markerTypes
    if dayzMarkerData[a]
      b = dayzMarkerData[a]
      c = 0

      while c < b.length
        d = b[c]
        e = ""
        e = (if d.name then d.name else markerTypes[a].name)
        addMarker dayzMap, d.id, d.lat, d.lng, e, a, d.building
        ++c
lootNames =
  ItemBandage: "Bandage"
  ItemPainkiller: "Painkillers"
  ItemMorphine: "Morphine Auto-Injector"
  ItemEpinephrine: "Epi-Pen"
  ItemBloodbag: "Blood Bag"
  ItemAntibiotic: "Antibiotics"
  MedBox0: "Cardboard Box (Medical)"
  WeaponHolder_MeleeCrowbar: "Crowbar"
  WeaponHolder_MeleeHatchet: "Hatchet"
  WeaponHolder_ItemCrowbar: "Crowbar"
  WeaponHolder_ItemHatchet: "Hatchet"
  Crossbow: "Compound Crossbow"
  Makarov: "Makarov PM"
  Colt1911: "M1911"
  revolver_EP1: "Revolver"
  glock17_EP1: "G17"
  M9: "M9"
  M9SD: "M9 SD"
  MP5A5: "MP5A5"
  MP5SD: "MP5SD6"
  UZI_EP1: "PDW"
  bizon_silenced: "Bizon PP-19 SD"
  Winchester1866: "Winchester 1866"
  MR43: "Double-barreled Shotgun"
  M1014: "M1014"
  Remington870_lamp: "Remington 870 (Flashlight)"
  LeeEnfield: "Lee Enfield"
  M16A2: "M16A2"
  M16A2GL: "M16A2 M203"
  M16A4_ACG: "M16A4 ACOG"
  M4A1: "M4A1"
  M4A1_Aim: "M4A1 CCO"
  M4A1_AIM_SD_camo: "M4A1 Camo SD"
  M4A1_HWS_GL_camo: "M4A1 HWS M203"
  M4A3_CCO_EP1: "M4A3 CCO"
  FN_FAL: "FN FAL"
  FN_FAL_ANPVS4: "FN FAL AN/PVS-4"
  BAF_L85A2_RIS_CWS: "L85A2 AWS"
  AK_47_M: "AKM"
  AK_74: "AK-74"
  AKS_74_U: "AKS-74u"
  AKS_74_kobra: "AKS-74 Kobra"
  huntingrifle: "CZ550"
  DMR: "DMR"
  M14_EP1: "M14 AIM"
  M24: "M24"
  M107_DZ: "M107"
  BAF_AS50_scoped: "AS50"
  SVD_CAMO: "SVD Camo"
  M136: "M136 Launcher"
  M240_DZ: "M240"
  M249_DZ: "M249 SAW"
  Mk_48_DZ: "Mk 48 Mod 0"
  BoltSteel: "Steel Bolt"
  "8Rnd_9x18_Makarov": "Makarov Mag."
  "7Rnd_45ACP_1911": "M1911 Mag."
  "6Rnd_45ACP": ".45 ACP"
  "17Rnd_9x19_glock17": "G17 Mag."
  "15Rnd_9x19_M9SD": "M9SD Mag."
  "15Rnd_9x19_M9": "M9 Mag."
  "30Rnd_9x19_MP5": "MP5 Mag."
  "30Rnd_9x19_MP5SD": "MP5SD Mag."
  "15Rnd_W1866_Slug": "15Rnd. 1866 Slugs"
  "2Rnd_shotgun_74Slug": "2Rnd. Slugs"
  "2Rnd_shotgun_74Pellets": "2Rnd. Pellets"
  "8Rnd_B_Beneli_74Slug": "8Rnd. Slugs"
  "8Rnd_B_Beneli_Pellets": "8Rnd. Pellets"
  "10x_303": "Lee Enfield Mag."
  "30Rnd_556x45_Stanag": "30Rnd. STANAG"
  "30Rnd_556x45_StanagSD": "30Rnd. STANAG SD"
  "30Rnd_545x39_AK": "30Rnd. AK"
  "30Rnd_762x39_AK47": "AKM Mag."
  "5x_22_LR_17_HMR": "CZ550 Mag."
  "20Rnd_762x51_DMR": "DMR mag"
  "5Rnd_762x51_M24": "5Rnd. M24"
  "10Rnd_127x99_m107": "10Rnd. M107"
  "100Rnd_762x51_M240": "100Rnd. M240"
  "200Rnd_556x45_M249": "200Rnd. M249 Belt"
  "1Rnd_HE_M203": "M203 HE"
  "1Rnd_Smoke_M203": "M203 Smoke"
  FlareWhite_M203: "M203 Flare White"
  FlareGreen_M203: "M203 Flare Green"
  AmmoBoxSmall_556: "5.56 ammo box"
  AmmoBoxSmall_762: "7.62 ammo box"
  CZ_VestPouch_EP1: "Czech Vest Pouch"
  DZ_Patrol_Pack_EP1: "Patrol Pack (coyote)"
  DZ_Assault_Pack_EP1: "Assault Pack (ACU)"
  DZ_CivilBackpack_EP1: "Czech Backpack"
  DZ_ALICE_Pack_EP1: "ALICE Pack"
  DZ_Backpack_EP1: "Backpack (coyote)"
  HandGrenade_west: "M67 Frag Grenade"
  PipeBomb: "Satchel Charge"
  SmokeShell: "Smoke Grenade"
  SmokeShellRed: "Smoke Grenade (Red)"
  SmokeShellGreen: "Smoke Grenade (Green)"
  HandChemGreen: "Chemlight (Green)"
  HandChemBlue: "Chemlight (Blue)"
  HandChemRed: "Chemlight (Red)"
  ItemHeatPack: "Heatpack"
  PartWoodPile: "Wood Pile"
  HandRoadFlare: "Road Flare"
  ItemFlashlight: "Flashlight"
  ItemFlashlightRed: "Flashlight (Military)"
  ItemWatch: "Watch"
  ItemKnife: "Hunting Knife"
  ItemCompass: "Compass"
  ItemMatchbox: "Box of Matches"
  Binocular: "Binoculars"
  ItemMap: "Map"
  ItemGPS: "GPS"
  NVGoggles: "NV Goggles"
  Binocular_Vector: "Rangefinder"
  ItemHatchet: "Hatchet"
  ItemEtool: "Entrenching Tool"
  Skin_Camo1_DZ: "Camo Clothing"
  Skin_Sniper1_DZ: "Ghillie Suit"
  WeaponHolder_ItemTent: "Camping Tent"
  ItemSandbag: "Sandbags"
  ItemWire: "Wire Fencing Kit"
  ItemToolbox: "Toolbox"
  ItemTankTrap: "Tank Trap Kit"
  TrapBear: "Bear Trap"
  ItemSodaCoke: "Soda Can (Coke)"
  ItemSodaPepsi: "Soda Can (Pepsi)"
  ItemSodaMdew: "Soda Can (Mountain Dew)"
  FoodCanBakedBeans: "Can (Baked Beans)"
  FoodCanSardines: "Can (Sardines)"
  FoodCanFrankBeans: "Can (Frank & beans)"
  FoodCanPasta: "Can (Pasta)"
  ItemWaterbottle: "Water Bottle"
  ItemWaterbottleUnfilled: "Water Bottle (Empty)"
  WeaponHolder_PartWheel: "Car Wheel"
  WeaponHolder_PartGeneric: "Scrap Metal"
  WeaponHolder_PartGlass: "Windscreen Glass"
  WeaponHolder_ItemJerrycan: "Jerry Can"
  WeaponHolder_PartFueltank: "Fueltank Parts"
  WeaponHolder_PartEngine: "Engine Parts"
  WeaponHolder_PartVRotor: "Main Rotor Assembly"
  TrashTinCan: "Empty Tin Can"
  ItemSodaEmpty: "Empty Soda Can"
  TrashJackDaniels: "Empty Whiskey Bottle"

lootSets =
  trash: [
    name: "TrashTinCan"
    chance: "62.5"
  ,
    name: "ItemSodaEmpty"
    chance: "31.25"
  ,
    name: "TrashJackDaniels"
    chance: "6.25"
  ]
  civilian: [
    name: "ItemSodaCoke"
    chance: "11.76%"
  ,
    name: "TrashTinCan"
    chance: "8.82%"
  ,
    name: "TrashJackDaniels"
    chance: "8.82%"
  ,
    name: "ItemSodaEmpty"
    chance: "8.82%"
  ,
    name: "ItemSodaPepsi"
    chance: "8.82%"
  ,
    name: "8Rnd_9x18_Makarov"
    chance: "6.86%"
  ,
    name: "ItemBandage"
    chance: "5.88%"
  ,
    name: "ItemPainkiller"
    chance: "5.88%"
  ,
    name: "FoodCanBakedBeans"
    chance: "4.90%"
  ,
    name: "FoodCanSardines"
    chance: "4.90%"
  ,
    name: "FoodCanFrankBeans"
    chance: "4.90%"
  ,
    name: "FoodCanPasta"
    chance: "4.90%"
  ,
    name: "7Rnd_45ACP_1911"
    chance: "4.90%"
  ,
    name: "2Rnd_shotgun_74Slug"
    chance: "4.90%"
  ,
    name: "2Rnd_shotgun_74Pellets"
    chance: "4.90%"
  ]
  food: [
    name: "TrashTinCan"
    chance: "12.87%"
  ,
    name: "TrashJackDaniels"
    chance: "12.87%"
  ,
    name: "ItemSodaEmpty"
    chance: "12.87%"
  ,
    name: "ItemSodaPepsi"
    chance: "12.87%"
  ,
    name: "ItemSodaCoke"
    chance: "8.91%"
  ,
    name: "FoodCanBakedBeans"
    chance: "8.91%"
  ,
    name: "FoodCanSardines"
    chance: "8.91%"
  ,
    name: "FoodCanFrankBeans"
    chance: "8.91%"
  ,
    name: "FoodCanPasta"
    chance: "8.91%"
  ,
    name: "ItemBandage"
    chance: "3.96%"
  ]
  generic: [
    name: "ItemBandage"
    chance: "11.00%"
  ,
    name: "8Rnd_9x18_Makarov"
    chance: "9.00%"
  ,
    name: "HandRoadFlare"
    chance: "7.00%"
  ,
    name: "TrashTinCan"
    chance: "6.00%"
  ,
    name: "ItemSodaEmpty"
    chance: "6.00%"
  ,
    name: "ItemSodaCoke"
    chance: "6.00%"
  ,
    name: "2Rnd_shotgun_74Slug"
    chance: "5.00%"
  ,
    name: "2Rnd_shotgun_74Pellets"
    chance: "5.00%"
  ,
    name: "ItemSodaPepsi"
    chance: "4.00%"
  ,
    name: "TrashJackDaniels"
    chance: "4.00%"
  ,
    name: "10x_303"
    chance: "4.00%"
  ,
    name: "6Rnd_45ACP"
    chance: "4.00%"
  ,
    name: "BoltSteel"
    chance: "4.00%"
  ,
    name: "ItemHeatPack"
    chance: "4.00%"
  ,
    name: "7Rnd_45ACP_1911"
    chance: "3.00%"
  ,
    name: "HandChemBlue"
    chance: "3.00%"
  ,
    name: "HandChemRed"
    chance: "3.00%"
  ,
    name: "15Rnd_W1866_Slug"
    chance: "2.00%"
  ,
    name: "ItemPainkiller"
    chance: "2.00%"
  ,
    name: "FoodCanBakedBeans"
    chance: "1.00%"
  ,
    name: "FoodCanSardines"
    chance: "1.00%"
  ,
    name: "FoodCanFrankBeans"
    chance: "1.00%"
  ,
    name: "FoodCanPasta"
    chance: "1.00%"
  ,
    name: "ItemWaterbottleUnfilled"
    chance: "1.00%"
  ,
    name: "ItemWaterbottle"
    chance: "1.00%"
  ,
    name: "5x_22_LR_17_HMR"
    chance: "1.00%"
  ,
    name: "HandChemGreen"
    chance: "1.00%"
  ]
  medical: [
    name: "ItemBandage"
    chance: "43.48%"
  ,
    name: "ItemPainkiller"
    chance: "21.74%"
  ,
    name: "ItemMorphine"
    chance: "21.74%"
  ,
    name: "ItemEpinephrine"
    chance: "8.70%"
  ,
    name: "ItemHeatPack"
    chance: "4.35%"
  ]
  hospital: [
    name: "ItemBandage"
    chance: "42.57%"
  ,
    name: "ItemPainkiller"
    chance: "16.83%"
  ,
    name: "ItemBloodbag"
    chance: "16.83%"
  ,
    name: "ItemMorphine"
    chance: "12.87%"
  ,
    name: "ItemEpinephrine"
    chance: "8.91%"
  ,
    name: "ItemAntibiotic"
    chance: "1.98%"
  ]
  military: [
    name: "TrashTinCan"
    chance: "17.82%"
  ,
    name: "ItemSodaEmpty"
    chance: "8.91%"
  ,
    name: "17Rnd_9x19_glock17"
    chance: "4.95%"
  ,
    name: "ItemBandage"
    chance: "3.96%"
  ,
    name: "ItemPainkiller"
    chance: "3.96%"
  ,
    name: "30Rnd_556x45_Stanag"
    chance: "3.96%"
  ,
    name: "20Rnd_762x51_DMR"
    chance: "3.96%"
  ,
    name: "30Rnd_762x39_AK47"
    chance: "3.96%"
  ,
    name: "30Rnd_545x39_AK"
    chance: "3.96%"
  ,
    name: "8Rnd_B_Beneli_74Slug"
    chance: "3.96%"
  ,
    name: "SmokeShell"
    chance: "3.96%"
  ,
    name: "8Rnd_B_Beneli_Pellets"
    chance: "3.96%"
  ,
    name: "ItemHeatPack"
    chance: "3.96%"
  ,
    name: "15Rnd_9x19_M9"
    chance: "1.98%"
  ,
    name: "SmokeShellRed"
    chance: "1.98%"
  ,
    name: "SmokeShellGreen"
    chance: "1.98%"
  ,
    name: "30Rnd_9x19_MP5"
    chance: "1.98%"
  ,
    name: "HandChemGreen"
    chance: "1.98%"
  ,
    name: "HandChemBlue"
    chance: "1.98%"
  ,
    name: "HandChemRed"
    chance: "1.98%"
  ,
    name: "ItemSodaCoke"
    chance: "0.99%"
  ,
    name: "ItemSodaPepsi"
    chance: "0.99%"
  ,
    name: "ItemMorphine"
    chance: "0.99%"
  ,
    name: "15Rnd_9x19_M9SD"
    chance: "0.99%"
  ,
    name: "5Rnd_762x51_M24"
    chance: "0.99%"
  ,
    name: "10Rnd_127x99_m107"
    chance: "0.99%"
  ,
    name: "1Rnd_HE_M203"
    chance: "0.99%"
  ,
    name: "FlareWhite_M203"
    chance: "0.99%"
  ,
    name: "FlareGreen_M203"
    chance: "0.99%"
  ,
    name: "1Rnd_Smoke_M203"
    chance: "0.99%"
  ,
    name: "200Rnd_556x45_M249"
    chance: "0.99%"
  ,
    name: "HandGrenade_west"
    chance: "0.99%"
  ,
    name: "30Rnd_556x45_StanagSD"
    chance: "0.99%"
  ,
    name: "30Rnd_9x19_MP5SD"
    chance: "0.99%"
  ,
    name: "100Rnd_762x51_M240"
    chance: "0.99%"
  ]
  policeman: [
    name: "ItemBandage"
    chance: "31.25%"
  ,
    name: "7Rnd_45ACP_1911"
    chance: "25.00%"
  ,
    name: "8Rnd_B_Beneli_74Slug"
    chance: "15.63%"
  ,
    name: "6Rnd_45ACP"
    chance: "9.38%"
  ,
    name: "15Rnd_W1866_Slug"
    chance: "9.38%"
  ,
    name: "HandRoadFlare"
    chance: "9.38%"
  ]
  hunter: [
    name: "ItemBandage"
    chance: "27.78%"
  ,
    name: "BoltSteel"
    chance: "27.78%"
  ,
    name: "5x_22_LR_17_HMR"
    chance: "13.89%"
  ,
    name: "10x_303"
    chance: "13.89%"
  ,
    name: "7Rnd_45ACP_1911"
    chance: "5.56%"
  ,
    name: "ItemWaterbottleUnfilled"
    chance: "5.56%"
  ,
    name: "ItemHeatPack"
    chance: "5.56%"
  ]

lootSetNames =
  trash: "Trash loot"
  food: "Food loot"
  generic: "Generic loot"
  medical: "Medical loot"
  hospital: "Hospital loot"
  military: "Military loot"
  policeman: "Policeman loot"
  hunter: "Hunter loot"

buildingLoot =
  residential: [
    set: "generic"
    chance: "56.02%"
  ,
    set: "trash"
    chance: "14.01%"
  ,
    name: "ItemWatch"
    chance: "4.20%"
  ,
    name: "Makarov"
    chance: "3.64%"
  ,
    name: "ItemKnife"
    chance: "2.24%"
  ,
    name: "WeaponHolder_MeleeCrowbar"
    chance: "2.24%"
  ,
    name: "ItemMatchbox"
    chance: "1.68%"
  ,
    name: "LeeEnfield"
    chance: "1.68%"
  ,
    name: "Binocular"
    chance: "1.68%"
  ,
    name: "PartWoodPile"
    chance: "1.68%"
  ,
    name: "ItemCompass"
    chance: "1.40%"
  ,
    name: "Colt1911"
    chance: "1.40%"
  ,
    name: "revolver_EP1"
    chance: "1.12%"
  ,
    name: "ItemMap"
    chance: "0.84%"
  ,
    name: "ItemFlashlight"
    chance: "0.84%"
  ,
    name: "DZ_CivilBackpack_EP1"
    chance: "0.84%"
  ,
    name: "DZ_ALICE_Pack_EP1"
    chance: "0.84%"
  ,
    set: "military"
    chance: "0.84%"
  ,
    name: "MR43"
    chance: "0.84%"
  ,
    name: "ItemSodaMdew"
    chance: "0.28%"
  ,
    name: "CZ_VestPouch_EP1"
    chance: "0.28%"
  ,
    name: "Winchester1866"
    chance: "0.28%"
  ,
    name: "WeaponHolder_ItemTent"
    chance: "0.28%"
  ,
    name: "Crossbow"
    chance: "0.28%"
  ,
    name: "Skin_Camo1_DZ"
    chance: "0.28%"
  ,
    name: "Skin_Sniper1_DZ"
    chance: "0.28%"
  ]
  industrial: [
    set: "trash"
    chance: "28.43%"
  ,
    set: "generic"
    chance: "17.65%"
  ,
    name: "WeaponHolder_MeleeHatchet"
    chance: "10.78%"
  ,
    name: "ItemKnife"
    chance: "6.86%"
  ,
    name: "ItemWire"
    chance: "5.88%"
  ,
    name: "WeaponHolder_PartWheel"
    chance: "4.90%"
  ,
    set: "military"
    chance: "3.92%"
  ,
    name: "WeaponHolder_PartGeneric"
    chance: "3.92%"
  ,
    name: "WeaponHolder_PartGlass"
    chance: "3.92%"
  ,
    name: "WeaponHolder_ItemJerrycan"
    chance: "3.92%"
  ,
    name: "ItemTankTrap"
    chance: "3.92%"
  ,
    name: "WeaponHolder_PartFueltank"
    chance: "1.96%"
  ,
    name: "ItemToolbox"
    chance: "1.96%"
  ,
    name: "WeaponHolder_PartEngine"
    chance: "0.98%"
  ,
    name: "WeaponHolder_PartVRotor"
    chance: "0.98%"
  ]
  farm: [
    set: "generic"
    chance: "27.45%"
  ,
    set: "trash"
    chance: "21.57%"
  ,
    name: "WeaponHolder_ItemHatchet"
    chance: "16.67%"
  ,
    name: "PartWoodPile"
    chance: "10.78%"
  ,
    name: "WeaponHolder_ItemJerrycan"
    chance: "5.88%"
  ,
    name: "MR43"
    chance: "5.88%"
  ,
    name: "LeeEnfield"
    chance: "3.92%"
  ,
    name: "Winchester1866"
    chance: "2.94%"
  ,
    name: "Crossbow"
    chance: "2.94%"
  ,
    name: "huntingrifle"
    chance: "0.98%"
  ,
    name: "TrapBear"
    chance: "0.98%"
  ]
  supermarket: [
    set: "food"
    chance: "28.30%"
  ,
    name: "ItemWatch"
    chance: "14.15%"
  ,
    set: "trash"
    chance: "14.15%"
  ,
    name: "ItemMap"
    chance: "4.72%"
  ,
    name: "ItemFlashlight"
    chance: "4.72%"
  ,
    name: "ItemMatchbox"
    chance: "4.72%"
  ,
    set: "generic"
    chance: "4.72%"
  ,
    name: "Binocular"
    chance: "4.72%"
  ,
    name: "DZ_ALICE_Pack_EP1"
    chance: "2.83%"
  ,
    name: "Makarov"
    chance: "1.89%"
  ,
    name: "Colt1911"
    chance: "1.89%"
  ,
    name: "ItemKnife"
    chance: "1.89%"
  ,
    name: "DZ_CivilBackpack_EP1"
    chance: "1.89%"
  ,
    name: "PartWoodPile"
    chance: "1.89%"
  ,
    name: "ItemCompass"
    chance: "0.94%"
  ,
    name: "LeeEnfield"
    chance: "0.94%"
  ,
    name: "revolver_EP1"
    chance: "0.94%"
  ,
    name: "CZ_VestPouch_EP1"
    chance: "0.94%"
  ,
    name: "Winchester1866"
    chance: "0.94%"
  ,
    name: "WeaponHolder_ItemTent"
    chance: "0.94%"
  ,
    name: "Crossbow"
    chance: "0.94%"
  ,
    name: "MR43"
    chance: "0.94%"
  ]
  helicrash: [
    set: "military"
    chance: "43.48%"
  ,
    set: "medical"
    chance: "21.74%"
  ,
    name: "DMR"
    chance: "4.35%"
  ,
    name: "MedBox0"
    chance: "4.35%"
  ,
    name: "AmmoBoxSmall_556"
    chance: "4.35%"
  ,
    name: "AmmoBoxSmall_762"
    chance: "4.35%"
  ,
    name: "Skin_Camo1_DZ"
    chance: "3.48%"
  ,
    name: "bizon_silenced"
    chance: "2.17%"
  ,
    name: "M14_EP1"
    chance: "2.17%"
  ,
    name: "M249_DZ"
    chance: "2.17%"
  ,
    name: "Skin_Sniper1_DZ"
    chance: "2.17%"
  ,
    name: "Mk_48_DZ"
    chance: "1.30%"
  ,
    name: "FN_FAL"
    chance: "0.87%"
  ,
    name: "FN_FAL_ANPVS4"
    chance: "0.87%"
  ,
    name: "BAF_AS50_scoped"
    chance: "0.87%"
  ,
    name: "M107_DZ"
    chance: "0.43%"
  ,
    name: "BAF_L85A2_RIS_CWS"
    chance: "0.43%"
  ,
    name: "NVGoggles"
    chance: "0.43%"
  ]
  hospital: [
    set: "hospital"
    chance: "41.67%"
  ,
    name: "MedBox0"
    chance: "41.67%"
  ,
    set: "trash"
    chance: "16.67%"
  ]
  military: [
    set: "military"
    chance: "47.80%"
  ,
    set: "generic"
    chance: "19.12%"
  ,
    name: "AK_47_M"
    chance: "3.82%"
  ,
    name: "AK_74"
    chance: "2.87%"
  ,
    name: "M1014"
    chance: "1.91%"
  ,
    name: "glock17_EP1"
    chance: "1.91%"
  ,
    name: "ItemFlashlightRed"
    chance: "1.91%"
  ,
    name: "ItemKnife"
    chance: "1.91%"
  ,
    set: "medical"
    chance: "1.91%"
  ,
    name: "AKS_74_kobra"
    chance: "1.53%"
  ,
    name: "Remington870_lamp"
    chance: "1.53%"
  ,
    name: "Binocular"
    chance: "1.15%"
  ,
    name: "DZ_Assault_Pack_EP1"
    chance: "1.15%"
  ,
    name: "M9"
    chance: "0.96%"
  ,
    name: "M16A2"
    chance: "0.96%"
  ,
    name: "AKS_74_U"
    chance: "0.96%"
  ,
    name: "AK_47_M"
    chance: "0.96%"
  ,
    name: "UZI_EP1"
    chance: "0.96%"
  ,
    name: "ItemMap"
    chance: "0.96%"
  ,
    name: "ItemEtool"
    chance: "0.96%"
  ,
    name: "MP5A5"
    chance: "0.76%"
  ,
    name: "DZ_Patrol_Pack_EP1"
    chance: "0.76%"
  ,
    name: "M9SD"
    chance: "0.38%"
  ,
    name: "M4A1"
    chance: "0.38%"
  ,
    name: "MP5SD"
    chance: "0.38%"
  ,
    name: "DZ_Backpack_EP1"
    chance: "0.38%"
  ,
    name: "ItemSandbag"
    chance: "0.38%"
  ,
    name: "M16A2GL"
    chance: "0.19%"
  ,
    name: "M4A1_Aim"
    chance: "0.19%"
  ,
    name: "M24"
    chance: "0.19%"
  ,
    name: "DMR"
    chance: "0.19%"
  ,
    name: "M14_EP1"
    chance: "0.19%"
  ,
    name: "M4A3_CCO_EP1"
    chance: "0.19%"
  ,
    name: "ItemGPS"
    chance: "0.19%"
  ]
  militaryspecial: [
    set: "military"
    chance: "57.47%"
  ,
    set: "generic"
    chance: "11.49%"
  ,
    set: "medical"
    chance: "3.45%"
  ,
    name: "AK_47_M"
    chance: "2.30%"
  ,
    name: "M1014"
    chance: "2.30%"
  ,
    name: "UZI_EP1"
    chance: "2.30%"
  ,
    name: "glock17_EP1"
    chance: "2.30%"
  ,
    name: "ItemKnife"
    chance: "1.72%"
  ,
    name: "M16A2"
    chance: "1.15%"
  ,
    name: "AK_74"
    chance: "1.15%"
  ,
    name: "AKS_74_kobra"
    chance: "1.15%"
  ,
    name: "AKS_74_U"
    chance: "1.15%"
  ,
    name: "AK_47_M"
    chance: "1.15%"
  ,
    name: "M4A1"
    chance: "1.15%"
  ,
    name: "Remington870_lamp"
    chance: "1.15%"
  ,
    name: "Binocular"
    chance: "1.15%"
  ,
    name: "M4A3_CCO_EP1"
    chance: "0.92%"
  ,
    name: "M16A2GL"
    chance: "0.57%"
  ,
    name: "M16A4_ACG"
    chance: "0.57%"
  ,
    name: "ItemFlashlightRed"
    chance: "0.57%"
  ,
    name: "M4A1_AIM_SD_camo"
    chance: "0.46%"
  ,
    name: "AmmoBoxSmall_556"
    chance: "0.46%"
  ,
    name: "M14_EP1"
    chance: "0.34%"
  ,
    name: "ItemMap"
    chance: "0.34%"
  ,
    name: "DZ_Patrol_Pack_EP1"
    chance: "0.34%"
  ,
    name: "M9SD"
    chance: "0.23%"
  ,
    name: "M4A1_Aim"
    chance: "0.23%"
  ,
    name: "DMR"
    chance: "0.23%"
  ,
    name: "M4A1_HWS_GL_camo"
    chance: "0.23%"
  ,
    name: "AmmoBoxSmall_762"
    chance: "0.23%"
  ,
    name: "DZ_Assault_Pack_EP1"
    chance: "0.23%"
  ,
    name: "DZ_Backpack_EP1"
    chance: "0.23%"
  ,
    name: "M249_DZ"
    chance: "0.11%"
  ,
    name: "M136"
    chance: "0.11%"
  ,
    name: "M24"
    chance: "0.11%"
  ,
    name: "SVD_CAMO"
    chance: "0.11%"
  ,
    name: "M107_DZ"
    chance: "0.11%"
  ,
    name: "M240_DZ"
    chance: "0.11%"
  ,
    name: "Mk_48_DZ"
    chance: "0.11%"
  ,
    name: "NVGoggles"
    chance: "0.11%"
  ,
    name: "ItemGPS"
    chance: "0.11%"
  ,
    name: "Binocular_Vector"
    chance: "0.11%"
  ,
    name: "PipeBomb"
    chance: "0.11%"
  ]

buildingSets =
  residential:
    zombieChance: "30%"
    minRoaming: 0
    maxRoaming: 2
    lootChance: "40%"
    loot: "residential"

  office:
    zombieChance: "30%"
    minRoaming: 0
    maxRoaming: 3
    lootChance: "40%"
    loot: "residential"

  church:
    zombieChance: "30%"
    minRoaming: 1
    maxRoaming: 3
    lootChance: "40%"
    loot: "residential"

  industrial:
    zombieChance: "40%"
    minRoaming: 0
    maxRoaming: 2
    lootChance: "30%"
    loot: "industrial"

  farm:
    zombieChance: "30%"
    minRoaming: 0
    maxRoaming: 3
    lootChance: "50%"
    loot: "farm"

  supermarket:
    zombieChance: "30%"
    minRoaming: 2
    maxRoaming: 6
    lootChance: "60%"
    loot: "supermarket"

  helicrash:
    zombieChance: "0%"
    minRoaming: 0
    maxRoaming: 2
    lootChance: "50%"
    loot: "helicrash"

  hospital:
    zombieChance: "40%"
    minRoaming: 2
    maxRoaming: 6
    lootChance: "100%"
    loot: "hospital"

  military:
    zombieChance: "30%"
    minRoaming: 0
    maxRoaming: 6
    lootChance: "40%"
    loot: "military"

  militaryspecial:
    zombieChance: "40%"
    minRoaming: 2
    maxRoaming: 6
    lootChance: "40%"
    loot: "militaryspecial"

buildingTypes =
  land_housev_1i4:
    type: "residential"
    lootSpawns: 3
    open: not 0

  land_kulna:
    type: "residential"
    lootSpawns: 2

  land_ind_workshop01_01:
    type: "industrial"
    lootSpawns: 3
    open: not 0

  land_ind_garage01:
    type: "industrial"
    lootSpawns: 4
    open: not 0

  land_ind_workshop01_02:
    type: "industrial"
    lootSpawns: 3
    open: not 0

  land_ind_workshop01_04:
    type: "industrial"
    lootSpawns: 7
    open: not 0

  land_ind_workshop01_l:
    type: "industrial"
    lootSpawns: 7
    open: not 0

  land_hangar_2:
    type: "industrial"
    lootSpawns: 7
    open: not 0

  land_hut06:
    type: "residential"
    lootSpawns: 2
    open: not 0

  land_stodola_old_open:
    type: "farm"
    lootSpawns: 12
    open: not 0

  land_a_fuelstation_build:
    type: "industrial"
    lootSpawns: 4
    lootChance: "50%"
    open: not 0

  land_a_generalstore_01a:
    type: "supermarket"
    lootSpawns: 24
    open: not 0

  land_a_generalstore_01:
    type: "supermarket"
    lootSpawns: 23
    open: not 0

  land_farm_cowshed_a:
    type: "farm"
    lootSpawns: 7
    open: not 0

  land_stodola_open:
    type: "farm"
    lootSpawns: 4
    open: not 0

  land_barn_w_01:
    type: "farm"
    lootSpawns: 6
    open: not 0

  land_hlidac_budka:
    type: "residential"
    lootSpawns: 3
    open: not 0

  land_housev2_02_interier:
    type: "residential"
    lootSpawns: 8
    open: not 0

  land_a_stationhouse:
    type: "military"
    lootSpawns: 10
    lootChance: "30%"
    open: not 0

  land_mil_controltower:
    type: "military"
    lootSpawns: 6
    lootChance: "40%"
    open: not 0

  land_ss_hangar:
    type: "military"
    lootSpawns: 3
    maxRoaming: 3
    open: not 0

  land_a_pub_01:
    type: "residential"
    lootSpawns: 20
    open: not 0

  land_houseb_tenement:
    type: "office"
    lootSpawns: 5

  land_a_hospital:
    type: "hospital"
    lootSpawns: 12
    lootChance: "90%"
    open: not 0

  land_panelak:
    type: "office"
    lootSpawns: 13
    open: not 0

  land_panelak2:
    type: "office"
    lootSpawns: 12
    open: not 0

  land_shed_ind02:
    type: "industrial"
    lootSpawns: 5
    open: not 0

  land_shed_wooden:
    type: "residential"
    lootSpawns: 2

  land_misc_powerstation:
    type: "industrial"
    lootSpawns: 2

  land_houseblock_a1_1:
    type: "residential"
    lootSpawns: 2

  land_shed_w01:
    type: "industrial"
    lootSpawns: 1

  land_housev_1i1:
    type: "residential"
    lootSpawns: 1

  land_tovarna2:
    type: "industrial"
    lootSpawns: 23
    open: not 0

  land_rail_station_big:
    type: "office"
    lootSpawns: 9

  land_ind_vysypka:
    type: "industrial"
    lootSpawns: 9
    open: not 0

  land_a_municipaloffice:
    type: "residential"
    lootSpawns: 14
    lootChance: "40%"
    minRoaming: 3
    maxRoaming: 9
    zombieChance: "0%"
    open: not 0

  land_a_office01:
    type: "office"
    lootSpawns: 31
    open: not 0

  land_a_office02:
    type: "office"
    lootSpawns: 2

  land_a_buildingwip:
    type: "industrial"
    lootSpawns: 29
    lootChance: "50%"
    open: not 0

  land_church_01:
    type: "church"
    lootSpawns: 1

  land_church_03:
    type: "church"
    lootSpawns: 12
    open: not 0

  land_church_02:
    type: "church"
    lootSpawns: 0
    maxRoaming: 2

  land_church_02a:
    type: "church"
    lootSpawns: 0
    maxRoaming: 2

  land_church_05r:
    type: "church"
    lootSpawns: 0
    maxRoaming: 2

  land_mil_barracks_i:
    type: "militaryspecial"
    lootSpawns: 12
    open: not 0

  land_a_tvtower_base:
    type: "industrial"
    lootSpawns: 3
    open: not 0

  land_mil_house:
    type: "military"
    lootSpawns: 3

  land_misc_cargo1ao:
    type: "industrial"
    lootSpawns: 3

  land_misc_cargo1bo:
    type: "industrial"
    lootSpawns: 3

  land_nav_boathouse:
    type: "industrial"
    lootSpawns: 9
    open: not 0

  land_ruin_01:
    type: "residential"
    lootSpawns: 4

  land_wagon_box:
    type: "industrial"
    lootSpawns: 3

  land_housev2_04_interier:
    type: "residential"
    lootSpawns: 7
    open: not 0

  land_housev2_01a:
    type: "residential"
    lootSpawns: 2

  land_psi_bouda:
    type: "residential"
    lootSpawns: 1

  land_kbud:
    type: "residential"
    lootSpawns: 1
    maxRoaming: 0
    zombieChance: "0%"

  land_a_castle_bergfrit:
    type: "residential"
    lootSpawns: 12
    open: not 0

  land_a_castle_stairs_a:
    type: "residential"
    lootSpawns: 3

  land_a_castle_gate:
    type: "residential"
    lootSpawns: 5
    lootChance: "70%"
    open: not 0

  land_mil_barracks:
    type: "military"
    lootSpawns: 0

  land_mil_barracks_l:
    type: "military"
    lootSpawns: 0

  land_barn_w_02:
    type: "farm"
    lootSpawns: 6
    open: not 0

  land_sara_domek_zluty:
    type: "residential"
    lootSpawns: 9
    maxRoaming: 1
    open: not 0

  land_housev_3i4:
    type: "residential"
    lootSpawns: 0
    maxRoaming: 3

  land_shed_w4:
    type: "residential"
    lootSpawns: 0
    maxRoaming: 3

  land_housev_3i1:
    type: "residential"
    lootSpawns: 0
    maxRoaming: 3

  land_housev_1l2:
    type: "residential"
    lootSpawns: 0
    maxRoaming: 3

  land_housev_1t:
    type: "residential"
    lootSpawns: 0
    maxRoaming: 3

  land_telek1:
    type: "industrial"
    lootSpawns: 0
    maxRoaming: 3

  land_rail_house_01:
    type: "industrial"
    lootSpawns: 3

  land_housev_2i:
    type: "residential"
    lootSpawns: 0
    maxRoaming: 3

  land_misc_deerstand:
    type: "military"
    lootSpawns: 2
    lootChance: "50%"
    zombieChance: "0%"
    maxRoaming: 3

  camp:
    type: "military"
    lootSpawns: 2
    maxRoaming: 1

  campeast:
    type: "military"
    lootSpawns: 2
    maxRoaming: 1
    open: not 0

  campeast_ep1:
    type: "military"
    lootSpawns: 3
    maxRoaming: 1
    open: not 0

  mash:
    type: "hospital"
    lootSpawns: 2
    lootChance: "40%"
    maxRoaming: 1

  mash_ep1:
    type: "hospital"
    lootSpawns: 2
    lootChance: "40%"
    maxRoaming: 1

  uh1wreck_dz:
    type: "helicrash"
    lootSpawns: 0
    lootChance: "0%"
    zombieChance: "0%"
    minRoaming: 4
    maxRoaming: 8

  usmc_warfarebfieldhhospital:
    type: "hospital"
    lootSpawns: 5
    lootChance: "40%"
    minRoaming: 1
    maxRoaming: 3
    open: not 0

  land_ind_shed_02_main:
    type: "industrial"
    lootSpawns: 0
    zombieChance: "0%"
    maxRoaming: 3

  houseroaming:
    type: "residential"
    lootSpawns: 0
    lootChance: "0%"
    zombieChance: "0%"
    maxRoaming: 2

  farmroaming:
    type: "farm"
    lootSpawns: 0
    lootChance: "0%"
    zombieChance: "0%"
    maxRoaming: 2

  land_shed_w03:
    type: "residential"
    lootSpawns: 0
    lootChance: "0%"
    zombieChance: "0%"
    maxRoaming: 2

  land_housev_1i3:
    type: "residential"
    lootSpawns: 0
    lootChance: "0%"
    zombieChance: "0%"
    maxRoaming: 2

  land_housev_1l1:
    type: "residential"
    lootSpawns: 0
    lootChance: "0%"
    zombieChance: "0%"
    maxRoaming: 2

  land_housev_1i2:
    type: "residential"
    lootSpawns: 0
    lootChance: "0%"
    zombieChance: "0%"
    maxRoaming: 2

  land_housev_2l:
    type: "residential"
    lootSpawns: 0
    lootChance: "0%"
    zombieChance: "0%"
    maxRoaming: 2

  land_housev_2t1:
    type: "residential"
    lootSpawns: 0
    lootChance: "0%"
    zombieChance: "0%"
    maxRoaming: 2

  land_housev_2t2:
    type: "residential"
    lootSpawns: 0
    lootChance: "0%"
    zombieChance: "0%"
    maxRoaming: 2

  land_housev_3i2:
    type: "residential"
    lootSpawns: 0
    lootChance: "0%"
    zombieChance: "0%"
    maxRoaming: 2

  land_housev_3i3:
    type: "residential"
    lootSpawns: 0
    lootChance: "0%"
    zombieChance: "0%"
    maxRoaming: 2

  land_houseblock_a1:
    type: "residential"
    lootSpawns: 0
    lootChance: "0%"
    zombieChance: "0%"
    maxRoaming: 2

  land_houseblock_a1_2:
    type: "residential"
    lootSpawns: 0
    lootChance: "0%"
    zombieChance: "0%"
    maxRoaming: 2

  land_houseblock_a2:
    type: "residential"
    lootSpawns: 0
    lootChance: "0%"
    zombieChance: "0%"
    maxRoaming: 2

  land_houseblock_a2_1:
    type: "residential"
    lootSpawns: 0
    lootChance: "0%"
    zombieChance: "0%"
    maxRoaming: 2

  land_houseblock_a3:
    type: "residential"
    lootSpawns: 0
    lootChance: "0%"
    zombieChance: "0%"
    maxRoaming: 2

  land_houseblock_b1:
    type: "residential"
    lootSpawns: 0
    lootChance: "0%"
    zombieChance: "0%"
    maxRoaming: 2

  land_houseblock_b2:
    type: "residential"
    lootSpawns: 0
    lootChance: "0%"
    zombieChance: "0%"
    maxRoaming: 2

  land_houseblock_b3:
    type: "residential"
    lootSpawns: 0
    lootChance: "0%"
    zombieChance: "0%"
    maxRoaming: 2

  land_houseblock_b4:
    type: "residential"
    lootSpawns: 0
    lootChance: "0%"
    zombieChance: "0%"
    maxRoaming: 2

  land_houseblock_b5:
    type: "residential"
    lootSpawns: 0
    lootChance: "0%"
    zombieChance: "0%"
    maxRoaming: 2

  land_houseblock_b6:
    type: "residential"
    lootSpawns: 0
    lootChance: "0%"
    zombieChance: "0%"
    maxRoaming: 2

  land_houseblock_c1:
    type: "residential"
    lootSpawns: 0
    lootChance: "0%"
    zombieChance: "0%"
    maxRoaming: 2

  land_houseblock_c2:
    type: "residential"
    lootSpawns: 0
    lootChance: "0%"
    zombieChance: "0%"
    maxRoaming: 2

  land_houseblock_c3:
    type: "residential"
    lootSpawns: 0
    lootChance: "0%"
    zombieChance: "0%"
    maxRoaming: 2

  land_houseblock_c4:
    type: "residential"
    lootSpawns: 0
    lootChance: "0%"
    zombieChance: "0%"
    maxRoaming: 2

  land_houseblock_c5:
    type: "residential"
    lootSpawns: 0
    lootChance: "0%"
    zombieChance: "0%"
    maxRoaming: 2

  land_housev2_01b:
    type: "residential"
    lootSpawns: 0
    lootChance: "0%"
    zombieChance: "0%"
    maxRoaming: 2

  land_misc_cargo1d:
    type: "residential"
    lootSpawns: 0
    lootChance: "0%"
    zombieChance: "0%"
    maxRoaming: 2

  land_housev2_03:
    type: "residential"
    lootSpawns: 0
    lootChance: "0%"
    zombieChance: "0%"
    maxRoaming: 2

  land_ind_shed_01_end:
    type: "residential"
    lootSpawns: 0
    lootChance: "0%"
    zombieChance: "0%"
    maxRoaming: 2

  land_a_statue01:
    type: "residential"
    lootSpawns: 0
    lootChance: "0%"
    zombieChance: "0%"
    minRoaming: 2
    maxRoaming: 8

  land_shed_w02:
    type: "farm"
    lootSpawns: 0
    lootChance: "0%"
    zombieChance: "0%"
    maxRoaming: 2

mapTileCounts =
  2:
    x: 3
    y: 3

  3:
    x: 7
    y: 6

  4:
    x: 15
    y: 13

  5:
    x: 31
    y: 26

  6:
    x: 63
    y: 53

dayzMap = undefined
dayzMarkers = []
dayzSidebar = not 0
dayzEditMode = not 1
ChernarusProjection::fromLatLngToPoint = (a) ->
  b = (a.lng() - @origin.lng()) * @unitsPerDegree
  a = (a.lat() - @origin.lat()) * @unitsPerDegree
  new google.maps.Point(b, a)

ChernarusProjection::fromPointToLatLng = (a, b) ->
  c = a.x
  d = (if 0 > a.y then 0 else a.y)
  d = ((if 256 < d then 256 else d)) / @unitsPerDegree + @origin.lat()
  c = c / @unitsPerDegree + @origin.lng()
  new google.maps.LatLng(d, c, b)

dayzProjection = new ChernarusProjection
updateHash = ->
  a = dayzMap.getCenter()
  a = "#" + dayzMap.getZoom() + "." + fromCoordToGps(a.lng()) + "." + fromCoordToGps(a.lat())
  searchedItem and (a += ";item=" + encodeURIComponent(searchedItem))
  location.replace a

linkToThis = ->
  prompt "Copy and paste the following URL to link to this map:", location.href

dayzMarkerVisibility =
  residential:
    low: not 0
    med: not 0
    high: not 0
    all: not 0

  military:
    low: not 0
    med: not 0
    high: not 0
    all: not 0

  farm:
    low: not 0
    med: not 0
    high: not 0
    all: not 0

  industrial:
    low: not 0
    med: not 0
    high: not 0
    all: not 0

  supermarket: not 0
  deerstand: not 0
  helicrash: not 0
  hospital: not 0
  pump: not 0
  fuel: not 0
  vehicles: not 0
  other: not 0
  helicopter: not 0
  motorcycle: not 0
  bicycle: not 0
  car: not 0
  boat: not 0
  atv: not 0
  bigtruck: not 0
  truck: not 0
  bus: not 0
  pbx: not 0
  tractor: not 0
  uaz: not 0

$(document).ready ->
  initDayZMap()
  $("#sidebarButton").click ->
    $(this).toggleClass "closed"
    $("#sidebar").toggle()
    $("#mapContainer").toggleClass "expanded"
    google.maps.event.trigger dayzMap, "resize"

  $("button.iconToggle").click ->
    a = $(this).attr("data-type")
    b = undefined
    updateHash()
    (if "other" is a or "vehicles" is a then (b = not dayzMarkerVisibility[a]
    $("div." + a + "-group input.iconToggle").each(->
      a = $(this).attr("data-type")
      (if b then $(this).attr("checked", not 0) else $(this).removeAttr("checked"))
      dayzMarkerVisibility[a] isnt b and setMarkerVis(a, not 1, b)
    )
    dayzMarkerVisibility[a] = b
    ) else (b = not dayzMarkerVisibility[a].all
    $("input.iconToggle[data-type=\"" + a + "\"]").each(->
      c = $(this).attr("data-value")
      (if b then $(this).attr("checked", not 0) else $(this).removeAttr("checked"))
      dayzMarkerVisibility[a][c] isnt b and setMarkerVis(a, c, b)
    )
    dayzMarkerVisibility[a].all = b
    ))

  $("input.iconToggle").change ->
    a = $(this)
    b = a.attr("data-type")
    a = a.attr("data-value")
    c = undefined
    updateHash()
    (if a then (c = not dayzMarkerVisibility[b][a]
    setMarkerVis(b, a, c)
    updateTypeVisibility(b)
    ) else (c = not dayzMarkerVisibility[b]
    setMarkerVis(b, not 1, c)
    updateTypeVisibility("vehicles")
    updateTypeVisibility("other")
    ))

  $(".dropdown-menu input, .dropdown-menu label").click (a) ->
    a.stopPropagation()


findItemBuildings = (a) ->
  b = {}
  c = undefined
  for c of lootSets
    d = lootSets[c]
    e = undefined
    for e of d
      if d[e].name is a
        b[c] = not 0
        break
  d = {}
  for c of buildingLoot
    f = buildingLoot[c]
    for e of f
      if f[e].set and b[f[e].set]
        d[c] = not 0
        break
      else if f[e].name and f[e].name is a
        d[c] = not 0
        break
  a = {}
  for c of buildingSets
    d[buildingSets[c].loot] and (a[c] = not 0)
  b = []
  for c of buildingTypes
    a[buildingTypes[c].type] and b.push(c)
  b

showOnlyBuildings = (a) ->
  b = dayzMarkers.length
  c = a.length
  d = 0

  while d < b
    e = not 1
    f = 0

    while f < c
      dayzMarkers[d].building is a[f] and (e = not 0)
      ++f
    dayzMarkers[d].setVisible e
    ++d
  $("button.iconToggleAll").removeClass "active"
  $("button.iconToggle").removeClass "active"
  $("input.iconToggle").removeAttr "checked"
  dayzMarkerVisibility.residential =
    low: not 1
    med: not 1
    high: not 1
    all: not 1

  dayzMarkerVisibility.industrial =
    low: not 1
    med: not 1
    high: not 1
    all: not 1

  dayzMarkerVisibility.military =
    low: not 1
    med: not 1
    high: not 1
    all: not 1

  dayzMarkerVisibility.farm =
    low: not 1
    med: not 1
    high: not 1
    all: not 1

  for g of dayzMarkerVisibility
    not 0 is dayzMarkerVisibility[g] and (dayzMarkerVisibility[g] = not 1)

searchedItem = not 1
shownBuildings = not 1
searchForItem = (a) ->
  b = not 1
  c = undefined
  for c of lootNames
    if lootNames[c] is a
      b = c
      break
  b and (shownBuildings = findItemBuildings(b)
  showOnlyBuildings(shownBuildings)
  searchedItem = a
  )

$(document).ready ->
  $("#mapsearch").submit (a) ->
    a.preventDefault()
    a = $("#mapsearch input").val()
    searchForItem a
    updateHash()

  $("#mapsearch input").typeahead
    source: lootNames
    matcher: (a) ->
      @scores = {}  unless @scores
      b = LiquidMetal.score(a, @query)
      @scores[a] = b
      0 < b

    sorter: (a) ->
      b = @scores
      a.sort (a, d) ->
        (if b[a] > b[d] then -1 else (if b[a] < b[d] then 1 else (if a > d then 1 else (if a < d then -1 else 0))))

      @scores = {}
      a


markerTypes =
  deerstand:
    name: "Deer Stand"

  barn:
    name: "Barn"
    type: "farm"

  hospital:
    name: "Hospital"

  supermarket:
    name: "Supermarket"

  atc:
    name: "ATC Tower"
    type: "military"

  barracks:
    name: "Barracks"
    type: "military"

  pump:
    name: "Water Pump"

  church:
    name: "Church"
    type: "residential"

  castle:
    name: "Castle"
    type: "residential"

  firestation:
    name: "Fire Station"
    type: "military"

  residential:
    name: "Residential"
    rated: not 0

  farm:
    name: "Farm"
    rated: not 0

  industrial:
    name: "Industrial"
    rated: not 0

  military:
    name: "Military"
    rated: not 0

  fuel:
    name: "Fuel Pump"

  helicrash:
    name: "Helicopter Crash"

  helicopter:
    name: "Helicopter"

  motorcycle:
    name: "Motorcycle"

  bicycle:
    name: "Bicycle"

  car:
    name: "Car"

  boat:
    name: "Boat"

  atv:
    name: "ATV"

  bigtruck:
    name: "Big Truck"

  truck:
    name: "Truck"

  bus:
    name: "Bus"

  pbx:
    name: "PBX"

  tractor:
    name: "Tractor"

  uaz:
    name: "UAZ"

  vehicle:
    name: "Vehicle"
    type: "car"

markerIcons =
  "residential-low": new google.maps.MarkerImage(dayz_staticUrl + "img/markers2/residential-low.png", new google.maps.Size(10, 10), new google.maps.Point(0, 0), new google.maps.Point(5, 5))
  "residential-med": new google.maps.MarkerImage(dayz_staticUrl + "img/markers2/residential-med.png", new google.maps.Size(13, 13), new google.maps.Point(0, 0), new google.maps.Point(7, 7))
  "residential-high": new google.maps.MarkerImage(dayz_staticUrl + "img/markers2/residential-high.png", new google.maps.Size(18, 18), new google.maps.Point(0, 0), new google.maps.Point(9, 9))
  "farm-low": new google.maps.MarkerImage(dayz_staticUrl + "img/markers2/farm-low.png", new google.maps.Size(10, 10), new google.maps.Point(0, 0), new google.maps.Point(5, 5))
  "farm-med": new google.maps.MarkerImage(dayz_staticUrl + "img/markers2/farm-med.png", new google.maps.Size(13, 13), new google.maps.Point(0, 0), new google.maps.Point(7, 7))
  "farm-high": new google.maps.MarkerImage(dayz_staticUrl + "img/markers2/farm-high.png", new google.maps.Size(18, 18), new google.maps.Point(0, 0), new google.maps.Point(9, 9))
  "military-low": new google.maps.MarkerImage(dayz_staticUrl + "img/markers2/military-low.png", new google.maps.Size(10, 10), new google.maps.Point(0, 0), new google.maps.Point(5, 5))
  "military-med": new google.maps.MarkerImage(dayz_staticUrl + "img/markers2/military-med.png", new google.maps.Size(13, 13), new google.maps.Point(0, 0), new google.maps.Point(7, 7))
  "military-high": new google.maps.MarkerImage(dayz_staticUrl + "img/markers2/military-high.png", new google.maps.Size(18, 18), new google.maps.Point(0, 0), new google.maps.Point(9, 9))
  "industrial-low": new google.maps.MarkerImage(dayz_staticUrl + "img/markers2/industrial-low.png", new google.maps.Size(10, 10), new google.maps.Point(0, 0), new google.maps.Point(5, 5))
  "industrial-med": new google.maps.MarkerImage(dayz_staticUrl + "img/markers2/industrial-med.png", new google.maps.Size(13, 13), new google.maps.Point(0, 0), new google.maps.Point(7, 7))
  "industrial-high": new google.maps.MarkerImage(dayz_staticUrl + "img/markers2/industrial-high.png", new google.maps.Size(18, 18), new google.maps.Point(0, 0), new google.maps.Point(9, 9))
  "residential-open-low": new google.maps.MarkerImage(dayz_staticUrl + "img/markers2/residential-open-low.png", new google.maps.Size(10, 10), new google.maps.Point(0, 0), new google.maps.Point(5, 5))
  "residential-open-med": new google.maps.MarkerImage(dayz_staticUrl + "img/markers2/residential-open-med.png", new google.maps.Size(13, 13), new google.maps.Point(0, 0), new google.maps.Point(7, 7))
  "residential-open-high": new google.maps.MarkerImage(dayz_staticUrl + "img/markers2/residential-open-high.png", new google.maps.Size(18, 18), new google.maps.Point(0, 0), new google.maps.Point(9, 9))
  "farm-open-low": new google.maps.MarkerImage(dayz_staticUrl + "img/markers2/farm-open-low.png", new google.maps.Size(10, 10), new google.maps.Point(0, 0), new google.maps.Point(5, 5))
  "farm-open-med": new google.maps.MarkerImage(dayz_staticUrl + "img/markers2/farm-open-med.png", new google.maps.Size(13, 13), new google.maps.Point(0, 0), new google.maps.Point(7, 7))
  "farm-open-high": new google.maps.MarkerImage(dayz_staticUrl + "img/markers2/farm-open-high.png", new google.maps.Size(18, 18), new google.maps.Point(0, 0), new google.maps.Point(9, 9))
  "military-open-low": new google.maps.MarkerImage(dayz_staticUrl + "img/markers2/military-open-low.png", new google.maps.Size(10, 10), new google.maps.Point(0, 0), new google.maps.Point(5, 5))
  "military-open-med": new google.maps.MarkerImage(dayz_staticUrl + "img/markers2/military-open-med.png", new google.maps.Size(13, 13), new google.maps.Point(0, 0), new google.maps.Point(7, 7))
  "military-open-high": new google.maps.MarkerImage(dayz_staticUrl + "img/markers2/military-open-high.png", new google.maps.Size(18, 18), new google.maps.Point(0, 0), new google.maps.Point(9, 9))
  "industrial-open-low": new google.maps.MarkerImage(dayz_staticUrl + "img/markers2/industrial-open-low.png", new google.maps.Size(10, 10), new google.maps.Point(0, 0), new google.maps.Point(5, 5))
  "industrial-open-med": new google.maps.MarkerImage(dayz_staticUrl + "img/markers2/industrial-open-med.png", new google.maps.Size(13, 13), new google.maps.Point(0, 0), new google.maps.Point(7, 7))
  "industrial-open-high": new google.maps.MarkerImage(dayz_staticUrl + "img/markers2/industrial-open-high.png", new google.maps.Size(18, 18), new google.maps.Point(0, 0), new google.maps.Point(9, 9))
  deerstand: new google.maps.MarkerImage(dayz_staticUrl + "img/markers2/deerstand.png", new google.maps.Size(18, 19), new google.maps.Point(0, 0), new google.maps.Point(9, 9))
  hospital: new google.maps.MarkerImage(dayz_staticUrl + "img/markers2/hospital.png", new google.maps.Size(19, 18), new google.maps.Point(0, 0), new google.maps.Point(9, 9))
  supermarket: new google.maps.MarkerImage(dayz_staticUrl + "img/markers2/supermarket.png", new google.maps.Size(22, 17), new google.maps.Point(0, 0), new google.maps.Point(9, 8))
  pump: new google.maps.MarkerImage(dayz_staticUrl + "img/markers2/waterpump.png", new google.maps.Size(17, 19), new google.maps.Point(0, 0), new google.maps.Point(8, 9))
  fuel: new google.maps.MarkerImage(dayz_staticUrl + "img/markers2/fuelpump.png", new google.maps.Size(20, 19), new google.maps.Point(0, 0), new google.maps.Point(10, 9))
  helicrash: new google.maps.MarkerImage(dayz_staticUrl + "img/markers2/helicrash.png", new google.maps.Size(30, 14), new google.maps.Point(0, 0), new google.maps.Point(15, 7))
  helicopter: new google.maps.MarkerImage(dayz_staticUrl + "img/markers2/helicopter.png", new google.maps.Size(30, 14), new google.maps.Point(0, 0), new google.maps.Point(15, 7))
  motorcycle: new google.maps.MarkerImage(dayz_staticUrl + "img/markers2/motorcycle.png", new google.maps.Size(29, 18), new google.maps.Point(0, 0), new google.maps.Point(14, 9))
  bicycle: new google.maps.MarkerImage(dayz_staticUrl + "img/markers2/bike.png", new google.maps.Size(28, 17), new google.maps.Point(0, 0), new google.maps.Point(14, 8))
  car: new google.maps.MarkerImage(dayz_staticUrl + "img/markers2/car.png", new google.maps.Size(27, 17), new google.maps.Point(0, 0), new google.maps.Point(13, 8))
  boat: new google.maps.MarkerImage(dayz_staticUrl + "img/markers2/boat.png", new google.maps.Size(34, 16), new google.maps.Point(0, 0), new google.maps.Point(17, 8))
  atv: new google.maps.MarkerImage(dayz_staticUrl + "img/markers2/atv.png", new google.maps.Size(26, 16), new google.maps.Point(0, 0), new google.maps.Point(13, 8))
  bigtruck: new google.maps.MarkerImage(dayz_staticUrl + "img/markers2/bigtruck.png", new google.maps.Size(34, 19), new google.maps.Point(0, 0), new google.maps.Point(17, 9))
  truck: new google.maps.MarkerImage(dayz_staticUrl + "img/markers2/truck.png", new google.maps.Size(34, 16), new google.maps.Point(0, 0), new google.maps.Point(17, 8))
  bus: new google.maps.MarkerImage(dayz_staticUrl + "img/markers2/bus.png", new google.maps.Size(39, 17), new google.maps.Point(0, 0), new google.maps.Point(14, 8))
  pbx: new google.maps.MarkerImage(dayz_staticUrl + "img/markers2/pbx.png", new google.maps.Size(34, 14), new google.maps.Point(0, 0), new google.maps.Point(17, 7))
  tractor: new google.maps.MarkerImage(dayz_staticUrl + "img/markers2/tractor.png", new google.maps.Size(26, 21), new google.maps.Point(0, 0), new google.maps.Point(13, 10))
  uaz: new google.maps.MarkerImage(dayz_staticUrl + "img/markers2/uaz.png", new google.maps.Size(30, 17), new google.maps.Point(0, 0), new google.maps.Point(15, 8))

markerZIndex =
  high: 120
  med: 60
  low: 100
  pump: 110
  supermarket: 140
  default: 80

markerValueThresholds =
  farm: [0, 6, 12]
  residential: [0, 8, 16]
  industrial: [0, 7, 16]
  military: [0, 6, 12]

dayzDirtyMarkers = {}
dayzNewMarkers = []
dayzDeletedMarkers = []
dayzEditingMarker = not 1
$(document).ready ->
  $("#markerEditForm").submit (a) ->
    a.preventDefault()
    b = $("#markerLatInput").val()
    c = $("#markerLngInput").val()
    a = $("#markerNameInput").val()
    d = $("#markerTypeInput").val()
    e = $("#markerBuildingInput").val()
    if dayzEditingMarker
      (if dayzEditingMarker.markerId then dayzDirtyMarkers[dayzEditingMarker.markerId] =
        id: dayzEditingMarker.markerId
        lat: b
        lng: c
        name: a
        type: d
        building: e
       else dayzNewMarkers.push(
        lat: b
        lng: c
        name: a
        type: d
        building: e
      ))
      dayzEditingMarker.building = e
      dayzEditingMarker.markerType = d
      b = transformMarkerData(d, e)
      dayzEditingMarker.markerValue = b.value
      dayzEditingMarker.markerOpen = b.open
      dayzEditingMarker.setTitle(a)
    dayzEditingMarker = not 1
    clearMarkerEditForm()

  $("#markerTypeInput").change ->
    a = $(this).val()
    b = $("#markerBuildingInput").val()
    a = transformMarkerData(a, b)
    a = a.type + ((if a.open then "-open" else "")) + ((if a.value then "-" + a.value else ""))
    dayzEditingMarker and dayzEditingMarker.setIcon(markerIcons[a])


newMarker = ->
  google.maps.event.addListener dayzMap, "click", onNewMarker

onNewMarker = (a) ->
  google.maps.event.clearListeners dayzMap, "click"
  dayzEditingMarker = addMarker(dayzMap, 0, a.latLng.lat(), a.latLng.lng(), "", "hospital", not 1)
  dayzEditingMarker.setDraggable not 0
  google.maps.event.addListener dayzEditingMarker, "dragend", onMarkerDrag
  google.maps.event.clearListeners dayzEditingMarker, "click"
  google.maps.event.addListener dayzEditingMarker, "click", onMarkerClickEdit
  google.maps.event.trigger dayzEditingMarker, "click"

deleteMarker = ->
  if dayzEditingMarker
    dayzEditingMarker.setMap null
    if 0 < dayzEditingMarker.markerId
      dayzDeletedMarkers.push dayzEditingMarker.markerId
    else
      a = dayzNewMarkers.length
      b = dayzEditingMarker.position.lat()
      c = dayzEditingMarker.position.lng()
      d = 0

      while d < a
        if dayzNewMarkers[d].lat is b and dayzNewMarkers[d].lng is c
          dayzNewMarkers.splice d, 1
          break
        ++d
    dayzEditingMarker = not 1
    clearMarkerEditForm()

saveMarkers = ->
  a = {}
  b = 0
  c = undefined
  for c of dayzDirtyMarkers
    b++
  0 < b and (a.dirty = JSON.stringify(dayzDirtyMarkers))
  0 < dayzNewMarkers.length and (a["new"] = JSON.stringify(dayzNewMarkers))
  0 < dayzDeletedMarkers.length and (a.deleted = JSON.stringify(dayzDeletedMarkers))
  (if 0 is b and 0 is dayzNewMarkers.length and 0 is dayzDeletedMarkers.length then alert("Nothing to save.") else $.ajax("/savemarkers",
    type: "POST"
    data: a
    success: (a) ->
      (if a.error then alert("Error saving: " + a.error) else (alert("Markers saved!")
      dayzDirtyMarkers = {}
      dayzNewMarkers = []
      dayzDeletedMarkers = []
      ))

    error: (a, b, c) ->
      alert "Error saving: " + c
  ))

clearMarkerEditForm = ->
  $("#markerLatInput").val ""
  $("#markerLngInput").val ""
  $("#markerNameInput").val ""
  $("#markerBuildingInput").val ""

toggleEditMarkers = ->
  dayzEditMode = not dayzEditMode
  toggleEditableMarkers()
  (if dayzEditMode then openMarkerEditor() else closeMarkerEditor())

toggleEditableMarkers = ->
  a = dayzMarkers.length
  b = 0

  while b < a
    dayzMarkers[b].setDraggable(dayzEditMode)
    (if dayzEditMode then (google.maps.event.addListener(dayzMarkers[b], "dragend", onMarkerDrag)
    google.maps.event.clearListeners(dayzMarkers[b], "click")
    google.maps.event.addListener(dayzMarkers[b], "click", onMarkerClickEdit)
    ) else (google.maps.event.clearListeners(dayzMarkers[b], "dragend")
    google.maps.event.clearListeners(dayzMarkers[b], "click")
    google.maps.event.addListener(dayzMarkers[b], "click", onMarkerClick)
    ))
    ++b

onMarkerDrag = ->
  a = dayzDirtyMarkers[@markerId]
  (if undefined is a then (@position.lat()
  @position.lng()
  ) else (a.lat = @position.lat()
  a.lng = @position.lng()
  ))
  dayzEditingMarker and dayzEditingMarker.markerId and dayzEditingMarker.markerId is @markerId and ($("#markerLatInput").val(@position.lat())
  $("#markerLngInput").val(@position.lng())
  )

onMarkerClickEdit = ->
  dayzEditingMarker = this
  $("#markerNameInput").val @title
  $("#markerTypeInput").val @markerType
  $("#markerBuildingInput").val @building
  $("#markerLatInput").val @position.lat()
  $("#markerLngInput").val @position.lng()

LiquidMetal = ->
  a = (a, c, d, e) ->
    while d < e
      a[d] = c
      d++
    a
  lastScore: null
  lastScoreArray: null
  score: (a, c) ->
    return 0.8  if 0 is c.length
    return 0  if c.length > a.length
    d = []
    e = a.toLowerCase()
    c = c.toLowerCase()
    @_scoreAll a, e, c, -1, 0, [], d
    return 0  if 0 is d.length
    e = 0
    f = []
    g = 0

    while g < d.length
      j = d[g]
      i = 0
      h = 0

      while h < a.length
        i += j[h]
        h++
      i > e and (e = i
      f = j
      )
      g++
    @lastScore = e /= a.length
    @lastScoreArray = f
    e

  _scoreAll: (b, c, d, e, f, g, j) ->
    unless f is d.length
      i = d.charAt(f)
      f++
      h = c.indexOf(i, e)
      unless -1 is h
        k = e

        while -1 isnt (h = c.indexOf(i, e + 1))
          (if -1 isnt " \t_-".indexOf(b.charAt(h - 1)) then (g[h - 1] = 1
          a(g, 0.85, k + 1, h - 1)
          ) else (e = b.charAt(h)
          (if "A" <= e and "Z" >= e then a(g, 0.85, k + 1, h) else a(g, 0, k + 1, h))
          ))
          g[h] = 1
          e = h
          @_scoreAll(b, c, d, e, f, g, j)
()
