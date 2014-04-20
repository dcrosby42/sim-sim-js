module.exports = (num,n=3) ->
  if n == 3
    Math.round( num * 1000 ) / 1000
  else
    mult = Math.pow(10,n)
    Math.round( num * mult ) / mult
