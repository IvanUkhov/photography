#= require prettydate

class window.PhotoStream
  constructor: (selector) ->
    @$ = jQuery

    @container = @$(selector)
    @photoWidth = 900
    @animationTime = 500
    @collection = []

    @window = @$(window)
    @container.on('click', 'img', (event) => @onClick(event))

  onClick: (event) ->
    element = @$(event.currentTarget)

    currentWidth = element.width()
    currentHeight = element.height()

    if element.data('expanded')
      element.data('expanded', false)
      photoHeight = Math.round(@photoWidth / currentWidth * currentHeight)
      element
        .stop()
        .animate(width: @photoWidth, height: photoHeight, @animationTime)
      return

    windowWidth = @window.width()

    newWidth = Math.round(0.98 * windowWidth)
    newHeight = Math.round(newWidth / currentWidth * currentHeight)

    return if newWidth < 1.1 * @photoWidth

    element.animate(width: newWidth, height: newHeight, @animationTime)

    id = element.data('id')
    element.data('expanded', true)

    @collection[id].load(width: newWidth).done (newElement) =>
      realWidth = newElement.get(0).width
      realHeight = newElement.get(0).height

      if realWidth < newWidth
        element
          .stop()
          .animate width: realWidth, height: realHeight, @animationTime, ->
            element.attr(src: newElement.attr('src'))
            return
      else
        element.attr(src: newElement.attr('src'))

      return

    return

  append: (photo) ->
    if photo.attributes.date?
      date = PrettyDate.format(photo.attributes.date)
      unless date is @date
        @$('<header></header>')
          .text(date)
          .appendTo(@container)
        @date = date

    id = @collection.length
    @collection.push(photo)

    section = @$('<section></section>')
      .appendTo(@container)

    photo.load(width: @photoWidth).done (element) ->
      element
        .data('id', id)
        .css(opacity: 0)
        .appendTo(section)
        .animate(opacity: 1, 1000)
      return
