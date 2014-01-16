function hidePreviousPage(){
  html('.current').each(function(el){ el.classList.remove('current')})
}

function reveal(page){
  return function(){
    html(page).each(function(el){ el.classList.add('current')})
  }
}

window.addEventListener('load', function() {
  window.html = HTML.query.bind(HTML)

  Path.map("/dashboard/home").to(reveal('.dashboard')).enter(hidePreviousPage)
  Path.map("/dashboard/settings").to(reveal('.settings')).enter(hidePreviousPage)
  Path.map("/dashboard/reports").to(reveal('.reports')).enter(hidePreviousPage)

  Path.root("/")

  Path.rescue(function(){
    console.log(404)
  })

  Path.history.listen(true)
  html("a").each(function(a){
    if(!a.classList.contains('sync'))
      a.addEventListener('click', function(event){
        event.preventDefault()
        Path.history.pushState({}, "", this.pathname)
      })
  })
})
