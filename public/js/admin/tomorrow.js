window.addEventListener('load', function() {
  window.html = HTML.query.bind(HTML)

  var icon = L.icon({
    iconUrl: '/img/leaflet/marker-icon.png',
    iconRetinaUrl: '/img/leaflet/marker-icon-2x.png',
    iconAnchor: [12, 41],
    popupAnchor: [0, -41],
    shadowUrl: '/img/leaflet/marker-shadow.png'
  })

  var bounds = L.latLngBounds(
      L.latLng(7.700104531441816, 97.59017944335936),
      L.latLng(8.244110057549225, 99.19692993164061)
    )

  var lat = 7.822228,
      lng = 98.340683,
      zoom = 11

  var map = L.map('map', {center: L.latLng(lat, lng), zoom: zoom, maxBounds: bounds})

  var osm = L.tileLayer('//{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
    attribution: '© <a href="http://openstreetmap.org">OpenStreetMap</a> contributors',
    maxZoom: 15
  })
  map.addLayer(osm)


  function show_minimap(legend) {
    return function(point) {
      point.container = L.DomUtil.create('div', 'leaflet-minimap-container', legend)

      var center = L.latLng(point.lat, point.lng)
      var minimap = L.map(point.container, {center: center, zoom: 15, maxBounds: bounds})

      var osm = L.tileLayer('//{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
        // TODO: didn't work, had to hide in CSS
        attributionControl: false,
        zoomControl: false
      })
      minimap.addLayer(osm)

      L.marker(center, {icon: icon}).addTo(minimap)

      var minimap_label = L.DomUtil.create('div', 'leaflet-control-legend-label', minimap.getContainer())
      minimap_label.innerHTML = '<b class="badge">' + point.quantity + '</b> ' + point.leader + ', ' + point.phone + ' (' + point.locale + ', ' + point.residence + ')'

      return point
    }
  }

  // TODO: Refactor to an L.control, redraw polylines on zoom/pan
  function draw_connectors(legend, offset) {
    return function(point) {
      L.polyline([
          L.latLng(point.lat, point.lng)
        , map.containerPointToLatLng(L.point(offset, point.container.offsetTop + point.container.offsetHeight / 2))
        ], {color: 'black'}).addTo(map)
    }
  }

  var container = map.getContainer()

  // TODO: Refactor to L.control
  var pane = L.DomUtil.create('div', 'leaflet-control-container', container)
  var legend_right = L.DomUtil.create('div', 'leaflet-top leaflet-right', pane)
  var legend_left = L.DomUtil.create('div', 'leaflet-top leaflet-left', pane)

  var median = pickup_points.sort(function(a, b) { return b.lng - a.lng })[Math.floor(pickup_points.length / 2)].lng

  pickup_points.reduce(function(acc, point) {
    if(point.lng <= median) acc.unshift(point)
    return acc
  }, [])
    .sort(function(a, b) { return b.lat - a.lat })
    .map(show_minimap(legend_left))
    .map(draw_connectors(legend_left, legend_left.offsetLeft + legend_left.offsetWidth))

  pickup_points.reduce(function(acc, point) {
    if(point.lng > median) acc.unshift(point)
    return acc
  }, [])
    .sort(function(a, b) { return b.lat - a.lat })
    .map(show_minimap(legend_right))
    .map(draw_connectors(legend_right, legend_right.offsetLeft))
})
