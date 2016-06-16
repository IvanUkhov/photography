class window.PrettyDate
  @MONTHS = ['January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December']

  @format = (date) ->
    "#{@MONTHS[date.getMonth()]} #{date.getFullYear()}"
