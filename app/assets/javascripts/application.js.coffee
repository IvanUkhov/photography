#= require googleplus.photoreader

Window = $(window)
Document = $(document)

class PrettyDate
  @months = [ 'January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December' ]

  @format = (date) ->
    @months[date.getMonth()] + ' ' + date.getFullYear()

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
      if photo.attributes.date?
        date = PrettyDate.format photo.attributes.date
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

reader = new GooglePlusPhotoReader '103064709795548297840', \
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
