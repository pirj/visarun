// Heavily based on https://github.com/bgrins/TinyColor
hslToRgb = (function() {
  function hue2rgb(p, q, t){
    if(t < 0) t += 1
    if(t > 1) t -= 1
    if(t < 1/6) return p + (q - p) * 6 * t
    if(t < 1/2) return q
    if(t < 2/3) return p + (q - p) * (2/3 - t) * 6
    return p
  }

  function bound01(n, max) {
    n = Math.min(max, Math.max(0, n))
    if ((Math.abs(n - max) < 0.000001)) return 1
    return (n % max) / max
  }

  function pad2(c) {
    return c.length == 1 ? '0' + c : c
  }

  function rgbToHex(r, g, b) {
    return [
      "#",
      pad2(Math.round(r).toString(16)),
      pad2(Math.round(g).toString(16)),
      pad2(Math.round(b).toString(16))
    ].join("")
  }

  return function(h, s, l){
    var r, g, b

    h = bound01(h, 360)
    s = bound01(s, 100)
    l = bound01(l, 100)

    if(s === 0)
      r = g = b = l // achromatic
    else {
      var q = l < 0.5 ? l * (1 + s) : l + s - l * s
      var p = 2 * l - q
      r = hue2rgb(p, q, h + 1/3)
      g = hue2rgb(p, q, h)
      b = hue2rgb(p, q, h - 1/3)
    }

    return rgbToHex(r * 255, g * 255, b * 255)
  }
})()
