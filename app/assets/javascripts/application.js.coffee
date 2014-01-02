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

  move: (targetX, targetY) ->
    dy = targetY - (@y + @offset)
    dx = targetX - (@x + @offset)

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

$('.each-letter').each ->
  _this = $(this)
  _this.html(_this.html().replace(
    /\b([a-z])([a-z]+)?\b/gim,
    "<span class='first-letter'>$1</span>$2"))

circles = []
distance = 0
targetX = 0
targetY = 0

$(document).on 'mousemove', (e) ->
  distance += Math.sqrt(
    (e.pageX - targetX) * (e.pageX - targetX) +
    (e.pageY - targetY) * (e.pageY - targetY))

  targetX = e.pageX
  targetY = e.pageY

  if distance > 2000
    distance = 0
    circles.push(new Circle($('#circle')))

$(document).on 'click touchstart', (e) ->
  targetX = e.pageX
  targetY = e.pageY

  distance = 0
  circles.push(new Circle($('#circle')))

setInterval (() => circle.move(targetX, targetY) for circle in circles), 10
