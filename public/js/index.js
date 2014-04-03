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
    html('#contacts input').each(function(el) { el.disabled = true } )
    html('#payment').classList.remove('invisible')

    var selected = html('#price .selected')
    var price = parseInt(selected.query('.price span').innerText)
    var item = selected.querySelector('h3').innerText
    var number = selected.querySelector('p.hidden').innerText
    var locale = html('#locale span').innerText
    var group_size = parseInt(html("#contacts input:checked").value)

    var date = html("#contacts input#date").value
    var phone = html("#contacts input#phone").value
    var name = html("#contacts input#name").value

    var attrs = {name: 'Visa run ' + item + ' ' + date, number: number, amount: price, currency: 'THB', quantity: group_size, locale: locale, button: 'buynow'}
    var script = html('#payment .row').add('script')

    monster.set('date', date)
    monster.set('phone', phone)
    monster.set('name', name)

    for(var name in attrs) {
      script.dataset[name] = attrs[name]
    }

    script.src = "/js/paypal-button.js?merchant=AC65H947H7QAU"
  })
})
