function xhr(method, url, data, success, fail) {
  var xhr = new XMLHttpRequest()
  xhr.open(method, url, true)
  xhr.addEventListener("load", success, false)
  xhr.addEventListener("error", fail, false)
  xhr.send(data)
}

function remove_item(control, i) {
  var li = i.parentElement
  li.remove()
  xhr('delete', '/settings/' + control, i.nextElementSibling.textContent)
}

function add_item(control, input) {
  var els = html('#' + control + ' ul')
    .add('li')
      .add(['i.icon-trash', 'span'])

  els.only(0).each(function(i) {
    i.addEventListener('click', function() {
      remove_item(control, i)
    })
  })

  els.only(1).each(function(span) {
    span.textContent = input.value
  })

  xhr('post', '/settings/' + control, input.value)
  input.value = ''
}

window.addEventListener('load', function() {
  ['queries', 'ignored_domains'].forEach(function(control) {
    html('#' + control + ' .icon-trash').each(function(i){
      i.addEventListener('click', function() {
        remove_item(control, i)
      })
    })

    html('#' + control + ' p').each(function(p) {
      p.input.addEventListener('keydown', function(event) {
        if(event.keyCode == 13)
          add_item(control, p.input)
      })
      p.i.addEventListener('click', function() {
        add_item(control, p.input)
      })
    })
  });

  ['adwares', 'activity'].forEach(function(control) {
    html('#' + control + ' input').each(function(input) {
      input.addEventListener('click', function() {
        xhr('post', '/settings/' + control + '/' + input.name, input.checked)
      })
    })
  })

  html('#region input').each(function(input) {
    input.addEventListener('keydown', function(event) {
      if(event.keyCode == 13)
        xhr('post', '/settings/region' , input.value)
    })
    input.addEventListener('blur', function(event) {
      xhr('post', '/settings/region' , input.value)
    })
  })
})
