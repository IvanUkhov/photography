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
    @maxWidth = attributes.width
    @maxHeight = attributes.height

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
      if not item.hasOwnProperty('object') then continue

      post = item.object

      if not post.hasOwnProperty('attachments') then continue

      for attachment in post.attachments
        if not attachment.hasOwnProperty('objectType') then continue
        if not attachment.objectType is 'photo' then continue
        if not attachment.hasOwnProperty('image') then continue
        if not attachment.hasOwnProperty('fullImage') then continue

        @collection.push new Photo \
          url: attachment.image.url,
          width: attachment.fullImage.width,
          height: attachment.fullImage.height

    return

Window = $(window)
Document = $(document)

class Gallery
  constructor: (selector) ->
    @container = $(selector)

    windowWidth = Window.width()
    @photoWidth = windowWidth * 3 / 4

    widthIncrement = Math.round 3 * windowWidth / 4
    containerWidth = windowWidth + widthIncrement
    @container.width containerWidth

    Window.on 'scroll', =>
      newWidth = Document.scrollLeft() + Window.width() + 2 * widthIncrement
      console.log newWidth
      containerWidth = Math.max containerWidth, newWidth
      @container.width containerWidth

      return

  append: (photos) ->
    for photo in photos
      photo.resize width: @photoWidth

      wrapper = $('<section></section>')
      wrapper.data id: @container.length
      wrapper.append photo.element

      @container.append wrapper
      @distribute photo

      photo.load()

    return

  distribute: (photo) ->
    return

reader = new PhotoReader '103064709795548297840', 'AIzaSyCQTW4nkz-TvGn0cIdpAnyUAirISQbk2gA'
gallery = new Gallery '#gallery'

reader.next 10, (photos) ->
  gallery.append photos

  return
