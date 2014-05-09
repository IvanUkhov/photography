#= require jquery.realwidth
#= require prettydate

class window.PhotoStream
  constructor: (selector) ->
    @container = $(selector)
    @photoWidth = 900
    @animationTime = 500
    @collection = []
    @current = null
    @container.on 'click', 'img', (event) => @onClick(event)

  onClick: (event) ->
    element = $(event.currentTarget)
    id = element.data 'id'

    if @current?
      current_id = @current.data 'id'

      height = @current.height()
      width = @current.width()

      @current.stop().animate width: @photoWidth, @animationTime
      @current = null

      return if current_id == id

      delta = height - @photoWidth / width * height
      if delta > 0 && current_id < id
        $('body, html').animate \
          scrollTop: $(window).scrollTop() - delta, @animationTime

    newWidth = Math.round 0.98 * $(window).width()
    return if newWidth < @photoWidth

    element.animate width: newWidth, @animationTime

    @collection[id].load width: newWidth, (newElement) =>
      realWidth = newElement.realWidth()
      if realWidth < newWidth
        element.stop().animate width: realWidth, @animationTime, ->
          element.attr src: newElement.attr('src')
      else
        element.attr src: newElement.attr('src')

    @current = element

    return

  append: (photo) ->
    if photo.attributes.date?
      date = PrettyDate.format photo.attributes.date
      unless date is @date
        $('<header></header>').
          text(date).
          appendTo(@container)
        @date = date

    id = @collection.length
    @collection.push photo

    section = $('<section></section>').
      appendTo(@container)

    photo.load { width: @photoWidth }, (element) ->
      element.
        data('id', id).
        css(opacity: 0).
        appendTo(section).
        animate(opacity: 1, 1000)
