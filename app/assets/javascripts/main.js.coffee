#= require configuration
#
#= require googleplus.photo
#= require googleplus.reader
#= require googleplus.photoreader
#
#= require prettydate
#= require photostream
#
#= require application

requirejs ['application'], (Application) ->
  new Application()
  return

requirejs ['typekit'], ->
  Typekit.load()
  return
