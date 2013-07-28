
boardDiv = $(document.createElement('div')).attr "id", "board"
for i in [1..8]
  aColumn = $(document.createElement('div')).attr("class", "column").attr("id","c"+i)
  aFeature = $(document.createElement('div')).attr("class", "feature").text("Feature "+i).appendTo(aColumn)
  aDetector = $(document.createElement('div')).attr("class", "detector").text("Detector "+i).appendTo(aColumn)
  aEffector = $(document.createElement('div')).attr("class", "effector e1").text("Effector 1").appendTo(aColumn)
  bEffector = $(document.createElement('div')).attr("class", "effector e2").text("Effector 2").appendTo(aColumn)
  aAlarm = $(document.createElement('div')).attr("class", "alarm e1").text("Alarm 1").appendTo(aColumn)
  bAlarm = $(document.createElement('div')).attr("class", "alarm e2").text("Alarm 2").appendTo(aColumn)
  aColumn.appendTo(boardDiv)

$('#boardWrapper').append(boardDiv)
$('head').append('<link rel="stylesheet" href="css/board.css" type="text/css" />')

