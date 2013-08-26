
window.createTrainingPlaymat = (controlSelector, boardSelector, licenseSelector) ->
  boardElement = $('#'+boardSelector)
  controlElement = $('#'+controlSelector)
  licenseElement = $('#'+licenseSelector)

  if boardElement and controlElement and licenseElement
    console.log "Found elements"
    createTrainingControls controlElement
    createBoard boardElement
    createCopyright licenseElement
    $('head').append('<link rel="stylesheet" href="css/board.css" type="text/css" />')
  else
    console.log "Elements not apparent"

window.createSolitairePlaymat = (controlSelector, boardSelector, licenseSelector) ->
  boardElement = $('#'+boardSelector)
  controlElement = $('#'+controlSelector)
  licenseElement = $('#'+licenseSelector)

  if boardElement and controlElement and licenseElement
    console.log "Found elements"
    createSolitaireControls controlElement
    createBoard boardElement
    createCopyright licenseElement
    $('head').append('<link rel="stylesheet" href="css/board.css" type="text/css" />')
  else
    console.log "Elements not apparent"


createBoard = (inElement) ->
  boardDiv = $(document.createElement('div')).attr("id", "board").appendTo inElement
  for i in [1..8]
    letter = String.fromCharCode("A".charCodeAt(0) + i - 1)
    aColumn = $(document.createElement('div')).attr("class", "column").attr("id","c#{i}").appendTo boardDiv
    $(document.createElement('div')).attr("class", "feature").text("Feature #{letter}").appendTo aColumn
    $(document.createElement('div')).attr("class", "detector").text("Detector #{letter}").appendTo aColumn
    $(document.createElement('div')).attr("class", "effector e1").text("Effector #{letter}1").appendTo aColumn
    $(document.createElement('div')).attr("class", "effector e2").text("Effector #{letter}2").appendTo aColumn
    $(document.createElement('div')).attr("class", "alarm a1").text("Alarm #{letter}1").appendTo aColumn
    $(document.createElement('div')).attr("class", "alarm a2").text("Alarm #{letter}2").appendTo aColumn

createSolitaireControls = (inElement) ->
  theTable = $(document.createElement('table')).attr("style", "width:100%").attr("border", 1).appendTo inElement
  theRow = $(document.createElement('tr')).attr("style", "width:100%; border: 1px solid black").appendTo theTable
  $(document.createElement('td')).attr("colspan", 2).text("PLANT").appendTo theRow
  $(document.createElement('td')).attr("colspan", 2).text("PATHOGEN").appendTo theRow

  theRow = $(document.createElement('tr')).appendTo theTable
  $(document.createElement('td')).text("Victories: 0").attr("id", ID_PLANT_VICTORY).appendTo theRow
  $(document.createElement('td')).text("Pressure: 2").attr("id", ID_PLANT_PRESSURE).appendTo theRow
  $(document.createElement('td')).text("Victories: 0").attr("id", ID_PATHO_VICTORY).appendTo theRow
  $(document.createElement('td')).text("Pressure: 2").attr("id", ID_PATHO_PRESSURE).appendTo theRow


  theRow = $(document.createElement('tr')).appendTo theTable
  plantControls = $(document.createElement('td')).appendTo theRow
  $(document.createElement('span')).html("Cost: X").attr("id", ID_PLANT_COST).appendTo plantControls

  plantControls = $(document.createElement('td')).appendTo theRow
  selector = $(document.createElement('select')).attr("style", "width:80%").attr("id", ID_PLANT_ACTIONS).appendTo plantControls
  $(document.createElement('option')).attr("value", "").text("Select Plant Action").appendTo selector
  $(document.createElement('option')).attr("value", ACTION_DISCARD).text(ACTION_DISCARD).appendTo selector
  $(document.createElement('option')).attr("value", ACTION_REPLACE).text(ACTION_REPLACE).appendTo selector
  $(document.createElement('option')).attr("value", ACTION_DRAW_D).text(ACTION_DRAW_D).appendTo selector
  $(document.createElement('option')).attr("value", ACTION_DRAW_A).text(ACTION_DRAW_A).appendTo selector
  $(document.createElement('button')).attr("type", "button").attr("id", ID_PLANT_ENGAGE).attr("style", "width:20%").text("Plant Go").appendTo plantControls

  pathoControls = $(document.createElement('td')).appendTo theRow
  $(document.createElement('span')).html("Cost: Y").attr("id", ID_PATHO_COST).appendTo pathoControls

  pathoControls = $(document.createElement('td')).appendTo theRow
  selector = $(document.createElement('select')).attr("style", "width:80%").attr("id", ID_PATHO_ACTIONS).appendTo pathoControls
  $(document.createElement('option')).attr("value", "").text("Select Pathogen Action").appendTo selector
  $(document.createElement('option')).attr("value", ACTION_DISCARD).text(ACTION_DISCARD).appendTo selector
  $(document.createElement('option')).attr("value", ACTION_REPLACE).text(ACTION_REPLACE).appendTo selector
  $(document.createElement('option')).attr("value", ACTION_DRAW_F).text(ACTION_DRAW_F).appendTo selector
  $(document.createElement('option')).attr("value", ACTION_DRAW_E).text(ACTION_DRAW_E).appendTo selector
  $(document.createElement('button')).attr("type", "button").attr("id", ID_PATHO_ENGAGE).attr("style", "width:20%").text("Pathogen Go").appendTo pathoControls



createTrainingControls = (inElement) ->
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
    $(document.createElement('div')).attr("id", "Quiz#{i}").html("Training #{i}<br>Answers: 0 Correct: 0<br>ETI:0 MTI:0 Virulence:0").appendTo aTD

  aTD = $(document.createElement('td')).appendTo secondRow
  for i in [0..4]
    $(document.createElement('button')).attr("id", "cheatyFace#{i+1}").attr("type", "button").text("10^#{i}").appendTo aTD

  aTD = $(document.createElement('td')).attr("colspan", 3).appendTo secondRow
  $(document.createElement('div')).attr("id", "ClearBoardButton").text("Clear Board").appendTo aTD

createCopyright = (inElement) ->
  agplLogo = $(document.createElement('img')).attr("src", "agplv3-88x31.png")
  agplURL = $(document.createElement('href')).attr("href", "http://www.gnu.org/licenses/agpl.html").append(agplLogo)
  inElement.html('<a href="https://github.com/b-adams/RQCards">Source</a> for this project available under the <a href="http://www.gnu.org/licenses/agpl.html">AGPLv3</a>')
  inElement.prepend(agplURL)
