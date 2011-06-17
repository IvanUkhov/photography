class Circle
  speed: 2
  rotationSpeed: Math.PI / 180
  uncertainRegion: 10 * Math.PI / 180

  colorBlindRegion: 300
  sadColor: [ 0x33, 0x33, 0x33 ]
  happyColor: [ 0xad, 0xce, 0x53 ]

  element: null

  x: null
  y: null

  targetX: null
  targetY: null

  offset: null
  angle: null

  constructor: (element)->
    x = element.offset().left
    y = element.offset().top

    width = element.width()
    height = element.height()

    @element = element.clone()
    @element.css({
      'position': 'absolute',
      'left': x, 'top': y,
      'width': width, 'height': height,
      'display': 'block'
    }).appendTo('body')

    @x = x
    @y = y
    @offset = width / 2

  focus: (x, y) ->
    @targetX = x
    @targetY = y

  tick: ->
    return if @targetX == null || @targetY == null

    dy = @targetY - (@y + @offset)
    dx = @targetX - (@x + @offset)

    angle = @.computeAngle(dy, dx)
    angle = @angle + @.computeTilt(@angle, angle) if @angle != null
    angle += 2 * Math.PI if angle < 0
    angle -= 2 * Math.PI if angle > 2 * Math.PI
    @angle = angle

    @x += @speed * Math.cos(@angle)
    @y += @speed * Math.sin(@angle)

    distance = Math.sqrt(dx * dx + dy * dy)

    @element.css({
      'left': Math.round(@x),
      'top': Math.round(@y),
      'background-color': @.computeColor(distance)
    })

  computeAngle: (dy, dx) ->
    angle = Math.abs(Math.atan(dy / dx))

    if dx < 0 && dy > 0
      angle = Math.PI - angle
    else if dx < 0 && dy < 0
      angle = Math.PI + angle
    else if dx > 0 && dy < 0
      angle = 2 * Math.PI - angle

    angle

  computeTilt: (oldAngle, newAngle) ->
    if newAngle > oldAngle
      distanceOne = newAngle - oldAngle
      distanceTwo = 2 * Math.PI - distanceOne
    else
      distanceTwo = oldAngle - newAngle
      distanceOne = 2 * Math.PI - distanceTwo

    if Math.abs(distanceOne - distanceTwo) < @uncertainRegion
      (if Math.random() < 0.5 then 1 else -1) * @rotationSpeed
    else if distanceOne < distanceTwo
      +@rotationSpeed
    else
      -@rotationSpeed

  computeColor: (distance) ->
    weight = Math.min(1, distance / @colorBlindRegion)

    r = Math.round(((1 - weight) * @happyColor[0] + weight * @sadColor[0]))
    g = Math.round(((1 - weight) * @happyColor[1] + weight * @sadColor[1]))
    b = Math.round(((1 - weight) * @happyColor[2] + weight * @sadColor[2]))

    'rgb(' + r + ',' + g + ',' + b + ')'

circles = []

$(document).ready ->
  $('.each-letter').each ->
    _this = $(this)
    _this.html(_this.html().replace(/\b([a-z])([a-z]+)?\b/gim, "<div class='first-letter'>$1</div>$2"))

  setInterval (() => circle.tick() for circle in circles), 10

  lastX = 0
  lastY = 0
  distance = 0

  $(document).mousemove (e)->
    distance += Math.sqrt(
      (e.pageX - lastX) * (e.pageX - lastX) +
      (e.pageY - lastY) * (e.pageY - lastY))

    lastX = e.pageX
    lastY = e.pageY

    if distance > 1000
      distance = 0
      circles.push(new Circle($('#circle')))

    circle.focus e.pageX, e.pageY for circle in circles
