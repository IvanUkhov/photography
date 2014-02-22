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

  resize: (dimensions) ->
    if not dimensions? then dimensions = Object

    if dimensions.width? and dimensions.height?
      width = dimensions.width
      height = dimensions.height
    else if dimensions.width? and not dimensions.height?
      width = Math.min @maxWidth, dimensions.width
      height = width / @maxWidth * @maxHeight
    else if not dimensions.width? and dimensions.height?
      height = Math.min @maxHeight, dimensions.height
      width = height / @maxHeight * @maxWidth
    else
      width = @width
      height = @height

    @width = Math.round width
    @height = Math.round height

    @element.attr width: @width, height: @height

    return

  load: ->
    newElement = $('<img/>')
    newElement.hide()
    newElement.on 'load', () => @onload(newElement)

    newElement.attr width: @width, height: @height, \
      src: @url.replace /w\d+-h\d+/, "w#{ @width }-h#{ @height }"

  onload: (newElement) ->
    @element.replaceWith newElement
    newElement.fadeIn 300


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
    @photoWidth = Window.width() * 3 / 4

  append: (photos) ->
    for photo in photos
      if photo.date?
        date = PrettyDate.format photo.date
        if not (date is @date)
          @container.append $('<header></header>').text(date)
          @date = date

      photo.resize width: @photoWidth

      section = $('<section></section>')
      section.append photo.element
      @container.append section

      photo.load()

    return

reader = new PhotoReader '103064709795548297840', \
  'AIzaSyCQTW4nkz-TvGn0cIdpAnyUAirISQbk2gA'
gallery = new Gallery '#gallery'

busy = false

extend = () ->
  if busy then return

  busy = true

  reader.next 5, (photos) ->
    gallery.append photos
    busy = false

    return

  return

extend()

Window.on 'scroll', =>
  if Window.scrollTop() < Document.height() - 1.5 * Window.height() then return

  extend()

  return

extend()

$('#email').attr href: 'mailto:ivan.ukhov@gmail.com'
