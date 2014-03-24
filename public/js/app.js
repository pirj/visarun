window.addEventListener('load', function() {
  window.html = HTML.query.bind(HTML)

  html('#price .button a').each(function(button) {
    button.addEventListener('click', function() {
      html('#price').classList.add('chosen')

    })
  })

})
