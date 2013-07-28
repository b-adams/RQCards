
window.createPlaymat = (controlSelector, boardSelector, licenseSelector) ->
  boardElement = $('#'+boardSelector)
  controlElement = $('#'+controlSelector)
  licenseElement = $('#'+licenseSelector)

  if boardElement and controlElement and licenseElement
    console.log "Found elements"
    createControls controlElement
    createBoard boardElement
    createCopyright licenseElement
    $('head').append('<link rel="stylesheet" href="css/board.css" type="text/css" />')
  else
    console.log "Elements not apparent"


createBoard = (inElement) ->
  boardDiv = $(document.createElement('div')).attr("id", "board").appendTo inElement
  for i in [1..8]
    aColumn = $(document.createElement('div')).attr("class", "column").attr("id","c"+i).appendTo boardDiv
    $(document.createElement('div')).attr("class", "feature").text("Feature "+i).appendTo aColumn
    $(document.createElement('div')).attr("class", "detector").text("Detector "+i).appendTo aColumn
    $(document.createElement('div')).attr("class", "effector e1").text("Effector 1").appendTo aColumn
    $(document.createElement('div')).attr("class", "effector e2").text("Effector 2").appendTo aColumn
    $(document.createElement('div')).attr("class", "alarm e1").text("Alarm 1").appendTo aColumn
    $(document.createElement('div')).attr("class", "alarm e2").text("Alarm 2").appendTo aColumn

createControls = (inElement) ->
  theTable = $(document.createElement('table')).attr("style", "width:100%").appendTo inElement

  firstRow = $(document.createElement('tr')).appendTo theTable
  secondRow = $(document.createElement('tr')).appendTo theTable

  aTD = $(document.createElement('td')).attr("style", "width:20%").appendTo firstRow
  selector = $(document.createElement('select')).attr("style", "width:100%").attr("id", "comboBoard").appendTo aTD
  $(document.createElement('option')).attr("value", "").text("Select current board state").appendTo selector
  $(document.createElement('option')).attr("value", "ETI").text("ETI (Alarm matches Effector)").appendTo selector
  $(document.createElement('option')).attr("value", "MTI").text("MTI (Two active detectors match features)").appendTo selector
  $(document.createElement('option')).attr("value", "Virulence").text("Virulence (None of the above)").appendTo selector

  for i in [1..3]
    aTD = $(document.createElement('td')).appendTo firstRow
    $(document.createElement('div')).attr("id", "Quiz"+i).html("Level "+i+"<br>Answers: 0 Correct: 0<br>ETI:0 MTI:0 Virulence:0").appendTo aTD

  aTD = $(document.createElement('td')).appendTo secondRow
  for i in [0..4]
    $(document.createElement('button')).attr("id", "cheatyFace"+(i+1)).attr("type", "button").text("10^"+i).appendTo aTD

  aTD = $(document.createElement('td')).attr("colspan", 3).appendTo secondRow
  $(document.createElement('div')).attr("id", "ClearBoardButton").text("Clear Board").appendTo aTD

createCopyright = (inElement) ->
  agplLogo = $(document.createElement('img')).attr("src", "agplv3-88x31.png")
  agplURL = $(document.createElement('href')).attr("href", "http://www.gnu.org/licenses/agpl.html").append(agplLogo)
  inElement.html('<a href="https://github.com/b-adams/RQCards">Source</a> for this project available under the <a href="http://www.gnu.org/licenses/agpl.html">AGPLv3</a>')
  inElement.prepend(agplURL)
