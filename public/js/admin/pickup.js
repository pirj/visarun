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
      return hslToRgb(hue, 100, 45)
    }
  })()

  routes.map(function(route) {
    route_layers.addLayer(
      L.polyline(route.vertices, {id: route.id, title: route.title, opacity: 1, color: next_color(), dashArray: "10, 10"})
    )
  })

  // TODO: display legend and pick a name in legend

  map.on('draw:created', function (e) {
    var layer = e.layer

    route_layers.addLayer(layer)
    layer.setStyle({opacity: 1, color: next_color(), dashArray: "10, 10"})

    var xhr = new XMLHttpRequest()
    xhr.open('post', 'pickup/add', true)
    var data = new FormData()
    data.append('vertices', JSON.stringify( layer.getLatLngs() ))
    xhr.send(data)

    // TODO: add to legend
  })

  map.on('draw:edited', function (e) {
    var layers = e.layers.getLayers().map(function(layer) {
      return {id: layer.options.id, vertices: layer.getLatLngs()}
    })

    var xhr = new XMLHttpRequest()
    xhr.open('post', 'pickup/update', true)
    var data = new FormData()
    data.append('routes', JSON.stringify( layers ))
    xhr.send(data)
  })

  map.on('draw:deleted', function (e) {
    var layers = e.layers.getLayers().map(function(layer) {
      return layer.options.id
    })

    var xhr = new XMLHttpRequest()
    xhr.open('delete', 'pickup', true)
    var data = new FormData()
    data.append('routes', JSON.stringify( layers ))
    xhr.send(data)
  })
})
