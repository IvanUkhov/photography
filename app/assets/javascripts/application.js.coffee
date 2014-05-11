#= require googleplus.photoreader
#= require photostream

class Application
  constructor: () ->
    @reader = new GooglePlus.PhotoReader \
      id: '103064709795548297840',
      key: 'AIzaSyCQTW4nkz-TvGn0cIdpAnyUAirISQbk2gA'

    @stream = new PhotoStream '#stream'
    @busy = false

    @extend 5

    $window = $(window)
    $document = $(document)
    $window.on 'scroll', =>
      limit = $document.height() - 1.5 * $window.height()
      @extend 5 if $window.scrollTop() > limit
      return

  extend: (count) ->
    return if @busy
    @busy = true

    @reader.next count, (photos) =>
      @stream.append photo for photo in photos
      @busy = false
      return

    return

application = new Application
