window.addEventListener('load', function() {
  window.html = HTML.query.bind(HTML)

  monster.remove('date')
  monster.remove('phone')
  monster.remove('name')

  var icon = L.icon({
    iconUrl: 'img/leaflet/marker-icon.png',
    iconRetinaUrl: 'img/leaflet/marker-icon-2x.png',
    iconAnchor: [12, 41],
    popupAnchor: [0, -41],
    shadowUrl: 'img/leaflet/marker-shadow.png'
  })

  function panToNearest(map, marker) {
    var selected = marker.getLatLng()
    var nearest = route_multiline
      .map(nearest_map(selected))
      .reduce(nearest_reduce(selected))

    marker.setLatLng(nearest)
    // TODO: snap to pick nearest point, pick two its neighbours, pick nearest. calculate mediana

    map.panTo(nearest)

    var txn_id = html('#txn_id').innerText
    var xhr = new XMLHttpRequest()
    xhr.open('post', 'pickup_location', true)
    var data = new FormData()
    data.append('txn_id', txn_id)
    data.append('lat', nearest.lat)
    data.append('lng', nearest.lng)
    xhr.send(data)
  }

  function show_map(lat, lng, zoom) {
    var map = new L.Map('map', {center: new L.LatLng(lat, lng), zoom: zoom, maxBounds: bounds})

    var osm = new L.TileLayer('http://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
      attribution: '© OpenStreetMap <a href="http://openstreetmap.org">OpenStreetMap</a> contributors',
      maxZoom: 17
    })
    map.addLayer(osm)

    var route = L.multiPolyline(route_multiline , {color: 'green', dashArray: "10, 10"})
      .addTo(map)

    var pickup = L.marker([lat, lng], {
      icon: icon,
      draggable: true
    })
      .addTo(map)
      .addEventListener('dragend', function() { panToNearest(map, pickup) })
      .bindPopup(document.getElementById('popup'), { closeButton: false })
        .openPopup()

    panToNearest(map, pickup)
  }

  navigator.geolocation.getCurrentPosition(function(position) {
    show_map(position.coords.latitude,  position.coords.longitude, 15)
  }, function(position) {
    show_map(7.822228, 98.340683, 12)
  })
})
