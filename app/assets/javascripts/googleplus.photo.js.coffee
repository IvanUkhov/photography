#= require jquery.realwidth

class window.GooglePlusPhoto
  constructor: (@attributes) ->
    @maxWidth = @attributes.width

    @element = $('<img/>')
    @element.css opacity: 0

    @initialized = false

  resize: (options) ->
    @width = Math.round options.width
    @width = Math.min @maxWidth, @width if @maxWidth?

    if options.animate?
      @element.stop().animate { width: @width }, 500
    else
      @element.css width: @width

    return

  load: (options, callback) ->
    url = @attributes.url.replace /w\d+-h\d+(-p)?/, "w#{ @width }"

    newElement = $('<img/>')
    newElement.on 'load', =>
      width = newElement.realWidth()
      shrink = width < @width

      if shrink
        @width = width
        @maxWidth = width

      if not @initialized
        @initialized = true
        @element.attr src: url
        @element.animate { opacity: 1 }, 1000
        callback() if callback?
      else if shrink
        @element.stop().animate { width: @width }, 500, =>
          @element.attr src: url
          callback() if callback?
      else
        @element.promise().done =>
          @element.attr src: url
          callback() if callback?

    newElement.attr src: url
