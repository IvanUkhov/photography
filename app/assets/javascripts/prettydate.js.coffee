class window.PrettyDate
  @months = ['January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December']

  @format = (date) ->
    "#{@months[date.getMonth()]} #{date.getFullYear()}"
