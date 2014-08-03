define 'application', ['jquery', 'googleplus.photoreader', 'photostream'], ($, PhotoReader, PhotoStream) ->
  class
    constructor: ->
      @reader = new PhotoReader
        id: '103064709795548297840',
        key: 'AIzaSyCQTW4nkz-TvGn0cIdpAnyUAirISQbk2gA'

      @stream = new PhotoStream('#stream')
      @busy = false

      @extend(5)

      $window = $(window)
      $document = $(document)
      $window.on 'scroll', =>
        limit = $document.height() - 1.5 * $window.height()
        @extend(5) if $window.scrollTop() > limit
        return

    extend: (count) ->
      return if @busy
      @busy = true

      @reader.next(count).done (photos) =>
        promises = (@stream.append(photo) for photo in photos)
        $.when(promises).always =>
          @busy = false
          return

        return

      return
