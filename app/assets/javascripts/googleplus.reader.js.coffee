class window.GooglePlusReader
  constructor: (options) ->
    @id = options.id
    @key = options.key
    @token = null
    @collection = []
    @position = 0

  next: (count, callback) ->
    nextPosition = @position + count

    if nextPosition <= @collection.length
      callback @collection.slice(@position, nextPosition) if callback?
      @position = nextPosition
      return

    @load =>
      nextPosition = Math.min nextPosition, @collection.length
      callback @collection.slice(@position, nextPosition) if callback?
      @position = nextPosition

    return

  load: (callback) ->
    url = "https://www.googleapis.com/plus/v1/people/#{ @id }/activities/public?key=#{ @key }"
    url = "#{ url }&pageToken=#{ @token }" if @token

    jQuery.ajax(url: url).done (result) =>
      @append result.items
      @token = result.nextPageToken
      callback() if callback?

  append: (items) ->
    @collection.push item for item in items
