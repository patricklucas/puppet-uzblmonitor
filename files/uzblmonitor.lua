require "window"

window.init_funcs.blurp = function(w)
  w.sbar.layout:hide()
  w.sbar.hidden = true
end

require "rc"