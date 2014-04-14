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

 // FIXME: var
  map = new L.Map('map', {center: L.latLng(lat, lng), zoom: zoom, maxBounds: bounds})

  var osm = new L.TileLayer('http://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
    attribution: '© OpenStreetMap <a href="http://openstreetmap.org">OpenStreetMap</a> contributors',
    maxZoom: 15
  })
  map.addLayer(osm)

  var container = map.getContainer()

  var pane = L.DomUtil.create('div', 'leaflet-control-container', container)
  var legend = L.DomUtil.create('div', 'leaflet-top leaflet-right', pane)

  pickup_points
    .sort(function(a, b) { return b.lat - a.lat })
    .map(function(point) {
      point.item = L.DomUtil.create('div', 'item', legend)
      point.item.innerHTML = '<b class="badge">' + point.quantity + '</b> ' + point.leader + ', ' + point.phone
      return point
    }).map(function(point) {
      L.polyline([
          L.latLng(point.lat, point.lng)
        , map.containerPointToLatLng(L.point(legend.offsetLeft, point.item.offsetTop + point.item.offsetHeight / 2))
        ], {color: 'black'}).addTo(map)
    })
})
