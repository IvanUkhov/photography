#= require googleplus.photo
#= require googleplus.reader
#= require googleplus.photoreader
#= require prettydate
#= require photostream

class Application
  constructor: ->
    @reader = new GooglePlus.PhotoReader
      id: '103064709795548297840',
      key: 'AIzaSyCQTW4nkz-TvGn0cIdpAnyUAirISQbk2gA'

    @stream = new PhotoStream('#stream')
    @busy = false

    id = window.location.hash.substr(1)
    if !!id
      @find(id)
    else
      @next(5)
      $window = $(window)
      $document = $(document)
      $window.on 'scroll', =>
        limit = $document.height() - 1.5 * $window.height()
        @next(5) if $window.scrollTop() > limit
        return

  find: (id) ->
    return if @busy
    @busy = true

    @reader.find(id).done (photos) =>
      promises = (@stream.append(photo) for photo in photos)
      $.when(promises).always =>
        @busy = false
        return

      return

    return

  next: (count) ->
    return if @busy
    @busy = true

    @reader.next(count).done (photos) =>
      promises = (@stream.append(photo) for photo in photos)
      $.when(promises).always =>
        @busy = false
        return

      return

    return

new Application()
