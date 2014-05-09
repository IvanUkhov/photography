$.fn.realWidth = ->
  clone = @clone().css(visibility: 'hidden').appendTo('body')
  width = clone.width()
  clone.remove()
  return width
