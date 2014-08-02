#= require prettydate

class window.PhotoStream
  constructor: (selector) ->
    @$ = jQuery

    @container = @$(selector)
    @photoWidth = 900
    @animationTime = 500
    @collection = []
    @container.on('click', 'img', (event) => @onClick(event))

  onClick: (event) ->
    element = @$(event.currentTarget)
    expanded = element.data('expanded')

    if expanded
      element.data('expanded', false)
      element.stop().animate(width: @photoWidth, @animationTime)
      return

    newWidth = Math.round(0.98 * @$(window).width())
    return if newWidth < @photoWidth

    element.animate(width: newWidth, @animationTime)

    id = element.data('id')
    element.data('expanded', true)

    @collection[id].load width: newWidth, (newElement) =>
      realWidth = newElement.get().width
      if realWidth < newWidth
        element.stop().animate width: realWidth, @animationTime, ->
          element.attr(src: newElement.attr('src'))
      else
        element.attr(src: newElement.attr('src'))

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

    photo.load { width: @photoWidth }, (element) ->
      element
        .data('id', id)
        .css(opacity: 0)
        .appendTo(section)
        .animate(opacity: 1, 1000)
