window.addEventListener('load', function() {
  window.html = HTML.query.bind(HTML)

  html('#price .button a').each(function(button) {
    button.addEventListener('click', function() {
      button.parentElement.parentElement.classList.add('selected')
      html('#price').classList.add('selected')
      html('#contacts').classList.remove('invisible')
    })
  })

  html('#proceed').addEventListener('click', function() {

    html('#proceed').classList.add('invisible')
    html('#payment').classList.remove('invisible')

    var selected = html('#price .selected')
    var price = parseInt(selected.query('.price span').innerText)
    var name = selected.querySelector('h3').innerText
    var number = selected.querySelector('p.hidden').innerText
    var locale = html('#locale span').innerText
    var group_size = parseInt(html("#contacts input:checked").value)

    var attrs = {name: 'Visa run ' + name, number: number, amount: price, currency: 'THB', quantity: group_size, locale: locale, button: 'buynow'}
    var script = html('#payment .row').add('script')

    for(var name in attrs) {
      script.dataset[name] = attrs[name]
    }

    script.src = "/js/paypal-button.js?merchant=AC65H947H7QAU"
  })
})
