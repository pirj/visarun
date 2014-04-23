window.addEventListener('load', function() {
  window.html = HTML.query.bind(HTML)

  var lat = 7.822228,
      lng = 98.340683,
      zoom = 11

  var bounds = L.latLngBounds(
      L.latLng(7.700104531441816, 97.59017944335936),
      L.latLng(8.244110057549225, 99.19692993164061)
    )

  var map = L.map('map', {
    center: L.latLng(lat, lng),
    zoom: zoom,
    maxBounds: bounds,
    fullscreenControl: true
  })

  var osm = L.tileLayer('//{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
    attribution: '© <a href="http://openstreetmap.org">OpenStreetMap</a> contributors',
    maxZoom: 15
  })
  map.addLayer(osm)

  var route_layers = new L.FeatureGroup()
  map.addLayer(route_layers)

  // Initialise the draw control and pass it the FeatureGroup of editable layers
  var drawControl = new L.Control.Draw({
    draw: {
      polygon: false,
      rectangle: false,
      circle: false,
      marker: false,
      polyline: {
        // TODO: false fires stupid errors
        // allowIntersection: false,
        shapeOptions: {
          color: "#33a"
        }
      }
    },
    edit: {
      featureGroup: route_layers
    }
  })
  map.addControl(drawControl)

  // TODO: extract
  var next_color = (function() {
    var hue = 0
    return function() {
      hue += 40
      if(hue > 360) hue -= 360
      return hslToRgb(hue, 100, 50)
    }
  })()

  routes.map(function(route) {
    route_layers.addLayer(
      L.polyline(route.vertices, {color: next_color(), dashArray: "10, 10"})
    )
  })

  map.on('draw:created', function (e) {
    var layer = e.layer

    route_layers.addLayer(layer)
    layer.setStyle({color: next_color(), dashArray: "10, 10"})

    var xhr = new XMLHttpRequest()
    xhr.open('post', 'pickup/add', true)
    var data = new FormData()
    data.append('vertices', JSON.stringify( layer.getLatLngs() ))
    xhr.send(data)

    // TODO: display legend
    // TODO: pick a name in legend
  })

  map.on('draw:edited', function (e) {
    var layers = e.layers
    layers.eachLayer(function (layer) {
      //do whatever you want, most likely save back to db
    })
  })

  map.on('draw:deleted', function (layer) {
    console.log(e)
  })
})
