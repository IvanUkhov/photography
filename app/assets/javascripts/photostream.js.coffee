class window.PhotoStream
  PHOTO_WIDTH: 900
  RESIZE_TIME: 500
  APPEAR_TIME: 1000
  EXPANSION_FRACTION: 0.98
  EXPANSION_THRESHOLD: 1.1
  REFERENCE_THRESHOLD: 0.9

  constructor: (selector, options = {}) ->
    @container = $(selector)
    @collection = []
    @responsive = options.responsive
    @parsimonious = options.parsimonious

    @window = $(window)
    @container.on('click', 'img', (event) => @onClick(event)) if @responsive

  onClick: (event) ->
    target = $(event.currentTarget)

    offset = target.offset();
    x = (event.pageX - offset.left) / target.width();
    y = (event.pageY - offset.top) / target.height();
    if x > @REFERENCE_THRESHOLD and y > @REFERENCE_THRESHOLD
      activity_id = target.data('activity-id')
      window.location.hash = "##{activity_id}"

    currentWidth = target.width()
    currentHeight = target.height()

    if target.data('expanded')
      target.data('expanded', false)
      photoHeight = Math.round(@PHOTO_WIDTH / currentWidth * currentHeight)
      target
        .stop()
        .animate(width: @PHOTO_WIDTH, height: photoHeight, @RESIZE_TIME)
      return

    windowWidth = @window.width()

    newWidth = Math.round(@EXPANSION_FRACTION * windowWidth)
    newHeight = Math.round(newWidth / currentWidth * currentHeight)

    return if newWidth < @EXPANSION_THRESHOLD * @PHOTO_WIDTH

    target.animate(width: newWidth, height: newHeight, @RESIZE_TIME)

    id = target.data('id')
    target.data('expanded', true)

    photo = @collection[id]
    if @parsimonious || not photo.attributes.width?
      promise = photo.load(width: newWidth)
    else
      promise = photo.load(width: photo.attributes.width)

    promise.done (element) =>
      realWidth = element.get(0).width
      realHeight = element.get(0).height

      if realWidth < newWidth
        target
          .stop()
          .animate width: realWidth, height: realHeight, @RESIZE_TIME, ->
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

    section = $('<section></section>')
      .appendTo(@container)

    id = @collection.length
    @collection.push(photo)

    if @parsimonious || not photo.attributes.width?
      promise = photo.load(width: @PHOTO_WIDTH)
    else
      promise = photo.load(width: photo.attributes.width)

    promise.done (element) =>
      width = Math.min(@PHOTO_WIDTH, element.get(0).width)
      element
        .data('id': id, 'activity-id': photo.attributes.activity_id)
        .css(opacity: 0, width: "#{width}px")
        .appendTo(section)
        .animate(opacity: 1, @APPEAR_TIME)
      return
