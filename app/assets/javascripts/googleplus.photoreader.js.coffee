#= require googleplus.reader
#= require googleplus.photo

class PhotoReader extends GooglePlus.Reader
  append: (items) ->
    for item in items
      continue unless item.hasOwnProperty('verb')
      continue unless item.verb is 'post'

      date = null
      date = new Date item.published if item.published?

      continue unless item.object?

      post = item.object

      continue unless post.attachments?

      for attachment in post.attachments
        continue unless attachment.objectType?

        if attachment.objectType is 'photo'
          continue unless attachment.image?

          if attachment.fullImage?
            @collection.push new GooglePlus.Photo \
              url: attachment.image.url,
              width: attachment.fullImage.width,
              date: date
          else
            @collection.push new GooglePlus.Photo \
              url: attachment.image.url,
              width: null,
              date: date

        else if attachment.objectType is 'album'
          continue unless attachment.thumbnails?

          for thumbnail in attachment.thumbnails
            continue unless thumbnail.image?

            @collection.push new GooglePlus.Photo \
              url: thumbnail.image.url,
              width: null,
              date: date

    return

window.GooglePlus ||= {}
window.GooglePlus.PhotoReader = PhotoReader
