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
    var nearest = routes
      .map(nearest_map(selected))
      .reduce(nearest_reduce(selected))

    marker.setLatLng(nearest)
    // TODO: snap to pick nearest point, pick two its neighbours, pick nearest. calculate mediana

    map.panTo(nearest)

    var xhr = new XMLHttpRequest()
    xhr.open('post', 'pickup_location', true)
    var data = new FormData()
    data.append('txn_id', txn_id)
    data.append('lat', nearest[0])
    data.append('lng', nearest[1])
    xhr.send(data)
  }

  function show_map(lat, lng, zoom) {
    html('.location_warning').remove()

    var map = L.map('map', {
      center: L.latLng(lat, lng),
      zoom: zoom,
      maxBounds: bounds,
      fullscreenControl: true
    })

    var osm = L.tileLayer('//{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
      attribution: '© <a href="http://openstreetmap.org">OpenStreetMap</a> contributors',
      maxZoom: 17
    })
    map.addLayer(osm)

    var route_layers = new L.FeatureGroup()
    map.addLayer(route_layers)

    routes.map(function(route) {
      route_layers.addLayer(
        L.polyline(route, {color: 'blue', dashArray: "10, 10"})
      )
    })

    pickup = L.marker([lat, lng], {
      icon: icon,
      draggable: true
    })
      .addTo(map)
      .addEventListener('dragend', function() { panToNearest(map, pickup) })
      .bindPopup(document.getElementById('popup'), { closeButton: false })

    panToNearest(map, pickup)

    // TODO: hack. somehow popup does not open right away
    setTimeout(function() { pickup.openPopup() }, 1000)
  }

  if(pickup.lat && pickup.lng) {
    show_map(pickup.lat, pickup.lng, 13)
  } else {
    html('#skip_location').addEventListener('click', function(e) {
      show_map(7.822228, 98.340683, 10)
      e.preventDefault()
    })

    navigator.geolocation.getCurrentPosition(function(position) {
      show_map(position.coords.latitude,  position.coords.longitude, 13)
    }, function(position) {
      show_map(7.822228, 98.340683, 10)
    })
  }
})
