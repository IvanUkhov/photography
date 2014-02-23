Window = $(window)
Document = $(document)

class PrettyDate
  @months = [ 'January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December' ]

  @format = (date) ->
    @months[date.getMonth()] + ' ' + date.getFullYear()


class AbstractReader
  constructor: (id, key) ->
    @id = id
    @key = key
    @token = null
    @collection = []
    @position = 0

  next: (count, callback) ->
    nextPosition = @position + count

    if nextPosition <= @collection.length
      callback @collection.slice @position, nextPosition if callback?
      @position = nextPosition
      return

    @load =>
      nextPosition = Math.min nextPosition, @collection.length
      callback @collection.slice @position, nextPosition if callback?
      @position = nextPosition

    return

  load: (callback) ->
    url = "https://www.googleapis.com/plus/v1/people/#{ @id }/activities/public?key=#{ @key }&pageToken=#{ @token }"

    jQuery.ajax(url: url).done (result) =>
      @append result.items
      @token = result.nextPageToken
      callback() if callback?

  append: (items) ->
    @collection.push item for item in result.items


class Photo
  constructor: (attributes) ->
    @url = attributes.url
    @width = attributes.width
    @height = attributes.height
    @date = attributes.date

    @maxWidth = @width
    @maxHeight = @height

    @element = $('<img/>')
    @element.css visibility: 'hidden'

  resize: (options) ->
    if not options? then options = Object

    if options.width? and options.height?
      width = options.width
      height = options.height
    else if options.width? and not options.height?
      width = Math.min @maxWidth, options.width
      height = width / @maxWidth * @maxHeight
    else if not options.width? and options.height?
      height = Math.min @maxHeight, options.height
      width = height / @maxHeight * @maxWidth
    else
      width = @width
      height = @height

    @width = Math.round width
    @height = Math.round height

    if options.animate?
      @element.stop().animate { width: @width, height: @height }, 500
    else
      @element.css width: @width, height: @height

    return

  load: (options) ->
    newElement = $('<img/>')
    newElement.on 'load', =>
      if @element.css('visibility') is 'hidden'
        newElement.hide()
        @element.replaceWith newElement
        @element = newElement
        newElement.fadeIn 1000
      else
        @element.promise().done =>
          @element.replaceWith newElement
          @element = newElement

    newElement.css width: @width, height: @height
    newElement.attr src: @url.replace /w\d+-h\d+/, "w#{ @width }-h#{ @height }"

class PhotoReader extends AbstractReader
  append: (items) ->
    for item in items
      if not item.hasOwnProperty('verb') then continue
      if not (item.verb is 'post') then continue

      date = null
      date = new Date item.published if item.published?

      if not item.object? then continue

      post = item.object

      if not post.attachments? then continue

      for attachment in post.attachments
        if not attachment.objectType? then continue
        if not attachment.objectType is 'photo' then continue
        if not attachment.image? then continue
        if not attachment.fullImage? then continue

        @collection.push new Photo \
          url: attachment.image.url,
          width: attachment.fullImage.width,
          height: attachment.fullImage.height,
          date: date

    return

class Gallery
  constructor: (selector) ->
    @container = $(selector)
    @photoWidth = 900
    @collection = []
    @current = null

    @container.on 'click', 'img', (event) =>
      section = $(event.currentTarget).parent('section')
      id = section.data('id')

      if @current is id
        photo = @collection[@current]
        photo.resize width: @photoWidth, animate: true
        @current = null
        return

      if @current?
        photo = @collection[@current]
        delta = photo.height - @photoWidth / photo.width * photo.height
        photo.resize width: @photoWidth, animate: true

        if delta > 0 && @current < id
          $('body, html').animate { scrollTop: Window.scrollTop() - delta }, 500

      newWidth = Math.round 0.98 * Window.width()
      if newWidth < @photoWidth then return

      photo = @collection[id]
      photo.resize width: newWidth, animate: true
      photo.load()

      @current = id

      return

  append: (photos) ->
    for photo in photos
      if photo.date?
        date = PrettyDate.format photo.date
        if not (date is @date)
          @container.append $('<header></header>').text(date)
          @date = date

      photo.resize width: @photoWidth

      section = $('<section></section>')
      section.data id: @collection.length
      section.append photo.element

      @collection.push photo
      @container.append section

      photo.load()

    return

reader = new PhotoReader '103064709795548297840', \
  'AIzaSyCQTW4nkz-TvGn0cIdpAnyUAirISQbk2gA'
gallery = new Gallery '#gallery'

busy = false

extend = (count) ->
  if busy then return

  busy = true

  reader.next count, (photos) ->
    gallery.append photos
    busy = false

    return

  return

Window.on 'scroll', =>
  if Window.scrollTop() < Document.height() - 1.5 * Window.height() then return

  extend 5

  return

extend 5

$('#email').attr href: 'mailto:ivan.ukhov@gmail.com'
