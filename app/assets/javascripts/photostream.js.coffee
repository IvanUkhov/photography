class window.PhotoStream
  constructor: (selector, options = {}) ->
    @container = $(selector)
    @photoWidth = 900
    @resizeTime = 500
    @appearTime = 1000
    @collection = []
    @responsive = options.responsive
    @parsimonious = options.parsimonious

    @window = $(window)
    @container.on('click', 'img', (event) => @onClick(event)) if @responsive

  onClick: (event) ->
    target = $(event.currentTarget)

    activity_id = target.data('activity-id')
    window.location.hash = "##{activity_id}"

    currentWidth = target.width()
    currentHeight = target.height()

    if target.data('expanded')
      target.data('expanded', false)
      photoHeight = Math.round(@photoWidth / currentWidth * currentHeight)
      target
        .stop()
        .animate(width: @photoWidth, height: photoHeight, @resizeTime)
      return

    windowWidth = @window.width()

    newWidth = Math.round(0.98 * windowWidth)
    newHeight = Math.round(newWidth / currentWidth * currentHeight)

    return if newWidth < 1.1 * @photoWidth

    target.animate(width: newWidth, height: newHeight, @resizeTime)

    id = target.data('id')
    target.data('expanded', true)

    if @parsimonious
      promise = @collection[id].load(width: newWidth)
    else
      promise = @collection[id].load()

    promise.done (element) =>
      realWidth = element.get(0).width
      realHeight = element.get(0).height

      if realWidth < newWidth
        target
          .stop()
          .animate width: realWidth, height: realHeight, @resizeTime, ->
            target.attr(src: element.attr('src'))
            return

      else
        target.attr(src: element.attr('src'))

      return

    return

  append: (photo) ->
    if photo.attributes.date?
      date = PrettyDate.format(photo.attributes.date)
      unless date is @date
        $('<header></header>')
          .text(date)
          .appendTo(@container)
        @date = date

    id = @collection.length
    @collection.push(photo)

    section = $('<section></section>')
      .appendTo(@container)

    if @parsimonious
      promise = photo.load(width: @photoWidth)
    else
      promise = photo.load()

    promise.done (element) =>
      width = Math.min(@photoWidth, element.get(0).width)
      element
        .data('id': id, 'activity-id': photo.attributes.activity_id)
        .css(opacity: 0, width: "#{width}px")
        .appendTo(section)
        .animate(opacity: 1, @appearTime)
      return

    return
