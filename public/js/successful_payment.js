window.addEventListener('load', function() {
  window.html = HTML.query.bind(HTML)

  monster.remove('date')
  monster.remove('phone')
  monster.remove('name')

  var bounds = L.latLngBounds(
      L.latLng(7.700104531441816, 97.59017944335936),
      L.latLng(8.244110057549225, 99.19692993164061)
    )

  function nearest_map(selected) {
    return function(latLngs) {
      return latLngs.reduce(nearest_reduce(selected))
    }
  }

  function nearest_reduce(selected) {
    return function(min, current) {
      return selected.distanceTo(min) < selected.distanceTo(current) ? min : current
    }
  }

  var icon = L.icon({
    iconUrl: '/img/leaflet/marker-icon.png',
    iconRetinaUrl: '/img/leaflet/marker-icon-2x.png',
    iconAnchor: [12, 41],
    popupAnchor: [0, -41],
    shadowUrl: '/img/leaflet/marker-shadow.png'
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
    var map = L.map('map', {center: L.latLng(lat, lng), zoom: zoom, maxBounds: bounds})

    var osm = L.tileLayer('//{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
      attribution: '© <a href="http://openstreetmap.org">OpenStreetMap</a> contributors',
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

// TODO: show warning to allow or deny map!
  navigator.geolocation.getCurrentPosition(function(position) {
    show_map(position.coords.latitude,  position.coords.longitude, 15)
  }, function(position) {
    // TODO: if pickup point is defined already, use it. use chalong ring otherwise
    show_map(7.822228, 98.340683, 12)
  })
})

// TODO: http://makinacorpus.github.io/Leaflet.Snap/
// TODO: http://leaflet.github.io/Leaflet.fullscreen/
