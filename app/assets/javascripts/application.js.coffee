Window = $(window)
Document = $(document)
Body = $('body')


$.fn.realWidth = ->
  clone = @clone().css(visibility: 'hidden').appendTo(Body)
  width = clone.width()
  clone.remove()
  return width


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
    @maxWidth = attributes.width
    @date = attributes.date

    @element = $('<img/>')
    @element.css visibility: 'hidden'

  resize: (options) ->
    @width = Math.round options.width

    if @maxWidth?
      @width = Math.min @maxWidth, @width

    if options.animate?
      @element.stop().animate { width: @width }, 500
    else
      @element.css width: @width

    return

  load: (options, callback) ->
    newElement = $('<img/>')
    newElement.on 'load', =>
      width = newElement.realWidth()
      shrink = width < @width

      if shrink
        @width = width
        @maxWidth = width

      if @element.css('visibility') is 'hidden'
        newElement.hide()
        @element.replaceWith newElement
        @element = newElement
        newElement.fadeIn 1000
        if callback? then callback()

      else if shrink
        @element.stop().animate { width: @width }, 500, =>
          @element.replaceWith newElement
          @element = newElement
          if callback? then callback()

      else
        @element.promise().done =>
          @element.replaceWith newElement
          @element = newElement
          if callback? then callback()

    newElement.attr src: @url.replace /w\d+-h\d+(-p)?/, "w#{ @width }"

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

        if attachment.objectType is 'photo'
          if not attachment.image? then continue

          if attachment.fullImage?
            @collection.push new Photo \
              url: attachment.image.url,
              width: attachment.fullImage.width,
              date: date
          else
            @collection.push new Photo \
              url: attachment.image.url,
              width: null,
              date: date

        else if attachment.objectType is 'album'
          if not attachment.thumbnails? then continue

          for thumbnail in attachment.thumbnails
            if not thumbnail.image? then continue

            @collection.push new Photo \
              url: thumbnail.image.url,
              width: null,
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

      busy = section.data 'busy'
      if busy then return

      id = section.data 'id'

      if @current is id
        photo = @collection[@current]
        photo.resize width: @photoWidth, animate: true
        @current = null
        return

      if @current?
        photo = @collection[@current]

        height = photo.element.height()
        delta = height - @photoWidth / photo.width * height

        photo.resize width: @photoWidth, animate: true

        if delta > 0 && @current < id
          $('body, html').animate { scrollTop: Window.scrollTop() - delta }, 500

      newWidth = Math.round 0.98 * Window.width()
      if newWidth < @photoWidth then return

      photo = @collection[id]
      photo.resize width: newWidth, animate: true

      section.data busy: true
      photo.load {}, => section.data busy: false

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
  limit = Document.height() - 1.5 * Window.height()
  if Window.scrollTop() > limit then extend 5
  return

extend 5

$('#email').attr href: 'mailto:ivan.ukhov@gmail.com'
