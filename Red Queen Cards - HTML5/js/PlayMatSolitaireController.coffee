###
* Created with JetBrains WebStorm.
* User: badams
* Date: 2013-07-07
* Time: 6:24 PM

Protype view controller code for quiz-style board interaction
Copyright (C) 2013 Bryant Adams

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU Affero General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License
along with this program.  If not, see http://www.gnu.org/licenses/.

###

class PlayMatSolitaireController
  constructor: ->
    alert "Solitaire Build 131015@1826"
    @theModel = new PlayMat()
    @boardState = "Uninitialized"
    @iteration = 0
    @sequentialLosses = 0
    @currentPlayer = "Uninitialized"
    @resultLog = {
      ETI: 0
      MTI: 0
      Virulence: 0
    }
    @distribution = {
      features: 4
      detectors: 4
      effectors: 4
      alarms: 4
    }
    @pressurePoints = {
      plant: 20
      pathogen: 20
    }
    @victoryPoints = {
      plant: 0
      pathogen: 0
    }
    @selectedElement = new Location(-1, -1, -1)
    @goButtons = {
      plant: null
      pathogen: null
    }
    @actionChoices = {
      plant: null
      pathogen: null
    }
    @pressureBoxen = {
      plant: null
      pathogen: null
    }
    @victoryBoxen = {
      plant: null
      pathogen: null
    }

  changePressure: (side, amount) ->
    @pressurePoints[side] += amount
    #console.log "Changing pressure for "+side+" by "+amount+". New total: "+@pressurePoints[side]


  getElement: (locWhere) ->
    selector = "#board > #c"+(locWhere.colIndex+1)+" > ."
    switch locWhere.cardtype
      when TYPE_FEATURE  then selector+="feature"
      when TYPE_DETECTOR then selector+="detector"
      when TYPE_EFFECTOR then selector+="e"+(locWhere.variety+1)
      when TYPE_ALARM    then selector+="a"+(locWhere.variety+1)
      else
        alert "PMSC Bad element request-- "+locWhere.toString()
        selector=""
    element = $ selector
    return element

  connectElement: (locWhere) ->
    theController = this
    theFeature = theController.getElement locWhere
    theFeature.click -> theController.doSelect locWhere
    theFeature.css "border-style", "dashed"

  setElementActivity: (active, theElement) ->
      theElement.css "border-style",      if active then "solid"          else "dashed"
      theElement.css "border-width",      if active then "2px"            else "1px"
      theElement.css "-webkit-animation", if active then "select 1s"      else "deselect 1s"
      theElement.css "-webkit-transform", if active then "rotateX(0deg)"  else "rotateX(180deg)"
      theElement.css "opacity",           if active then "1"              else "0.25"
      theElement.css "text-shadow",       "0 0 0em #87F"


  updateBoardState: ->
    @boardState = switch
      when @theModel.isPlantETIActive() then RESULT_ETI
      when @theModel.isPlantMTIActive() then RESULT_PTI
      else                                   RESULT_VIR

    #console.log "Game: " + @boardState
    #window.document.title = "Current state: " + @boardState

  updateGoButton: (whoseSide) ->
    @goButtons[whoseSide].removeAttr("disabled")
    actionType = @actionChoices[whoseSide].val()

    requiresSelection = actionType is ACTION_DISCARD or actionType is ACTION_REPLACE
    hasSelection = @selectedElement["element"] isnt null

    if requiresSelection and not hasSelection
      @goButtons[whoseSide].html("Selection Required")
      @goButtons[whoseSide].attr("disabled", "disabled")
      @goButtons[whoseSide].css "background", "red"
      return

    switch actionType
      when ACTION_DRAW
        elementType = @selectedElement["type"]
      when ACTION_DISCARD
        elementType = @selectedElement["type"]
      when ACTION_REPLACE
        elementType = @selectedElement["type"]
      when ACTION_DRAW_A
        actionType = ACTION_DRAW
        elementType = TYPE_ALARM
      when ACTION_DRAW_D
        actionType = ACTION_DRAW
        elementType = TYPE_DETECTOR
      when ACTION_DRAW_E
        actionType = ACTION_DRAW
        elementType = TYPE_EFFECTOR
      when ACTION_DRAW_F
        actionType = ACTION_DRAW
        elementType = TYPE_FEATURE
      when ACTION_RANDOM
        null
      else
        @goButtons[whoseSide].html("Action Required")
        @goButtons[whoseSide].attr("disabled", "disabled")
        @goButtons[whoseSide].css "background", "grey"
        return

    cost = this.costForAction actionType, elementType

    if cost < 0
      @goButtons[whoseSide].attr("disabled", "disabled")
      @goButtons[whoseSide].html("Disallowed")
      @goButtons[whoseSide].css "background", "orange"
      return
    if cost > @pressurePoints[whoseSide]
      #@goButtons[whoseSide].attr("disabled", "disabled")
      @goButtons[whoseSide].html("Need "+cost+"pp")
      @goButtons[whoseSide].css "background", "yellow"
      return

    @goButtons[whoseSide].html("Go (Spend: "+cost+"pp)")
    @goButtons[whoseSide].css "background", "green"


  moveToNextTurn: ->
    this.updateBoardState()
    firstPhaseFilter = if @iteration is 0 then 0 else 1
    message = "ERROR: Message not instantiated"
    rewards = this.rewardsForRound()

    @resultLog[@boardState] += 1

    switch @boardState
      when RESULT_ETI
        winner = SIDE_PLANT
        loser =  SIDE_PATHOGEN
        pressureForLoser = 25
        victoryForWinner = rewards[SIDE_PLANT]
      when RESULT_PTI
        winner = SIDE_PLANT
        loser =  SIDE_PATHOGEN
        pressureForLoser = 15
        victoryForWinner = rewards[SIDE_PLANT]
      else #RESULT_VIR
        winner = SIDE_PATHOGEN
        loser =  SIDE_PLANT
        pressureForLoser = 15
        victoryForWinner = rewards[SIDE_PATHOGEN]

    vpReason = rewards[winner+"_reason"]

    lostAgain = (@currentPlayer is loser)
    if lostAgain
      @sequentialLosses += 1
    else
      @currentPlayer = loser
      @sequentialLosses = 0

    if lostAgain
      winline = "#{winner} wins again (round #{@iteration} ,#{@boardState})"
    else
      winline = "#{winner} wins round #{@iteration} (#{@boardState})"

    vpLine =  "#{winner}: +#{victoryForWinner}vp"
    ppLine =   "#{loser}: +#{pressureForLoser}pp"
    if lostAgain
      ppLine += " (+"+@sequentialLosses+"pp for repeat loss)"
      pressureForLoser += @sequentialLosses

    message = winline + "\n" + vpLine + "\n" + vpReason + "\n" + ppLine;
    if victoryForWinner < 0
      message += "\nWARNING: Unsustainably costly win!"

    alert message if firstPhaseFilter isnt 0

    this.changePressure loser, pressureForLoser*firstPhaseFilter
    @victoryPoints[winner] += victoryForWinner*firstPhaseFilter
    @actionChoices[winner].hide()
    @actionChoices[loser].show()
    @goButtons[winner].hide()
    @goButtons[loser].show()

    etiWins = @resultLog[RESULT_ETI]+" "+RESULT_ETI
    ptiWins = @resultLog[RESULT_PTI]+" "+RESULT_PTI
    virWins = @resultLog[RESULT_VIR]+" "+RESULT_VIR
    @victoryBoxen[SIDE_PLANT].html("Victory: #{@victoryPoints[SIDE_PLANT]} (#{etiWins}, #{ptiWins})")
    @victoryBoxen[SIDE_PATHOGEN].html("Victory: #{@victoryPoints[SIDE_PATHOGEN]} (#{virWins})")
    @pressureBoxen[SIDE_PLANT].html("Pressure: #{@pressurePoints[SIDE_PLANT]}")
    @pressureBoxen[SIDE_PATHOGEN].html("Pressure: #{@pressurePoints[SIDE_PATHOGEN]}")

    document.title = "State: "+@boardState+" | Turn: "+@currentPlayer
    @iteration += 1
    #console.log "Moved to turn "+@iteration

  doDiscard: (locWhere) ->
    oldValue = @theModel.isCellActive locWhere
    if oldValue isnt true
      return false #No discarding cards you don't have
    else
      this.doSet false, locWhere
      switch locWhere.cardtype
        when TYPE_FEATURE  then @distribution["features"]  -= 1
        when TYPE_DETECTOR then @distribution["detectors"] -= 1
        when TYPE_ALARM    then @distribution["alarms"]    -= 1
        when TYPE_EFFECTOR then @distribution["effectors"] -= 1
      this.setElementActivity false, (this.getElement locWhere)
      #this.moveToNextTurn()
      return true #Discard successful

  doDiscardSelected: ->
    this.doDiscard @selectedElement

#  randomSelectionArray: (picks, total) ->
#    picklist = (true for n in [0...picks]).concat (false for n in [picks...total])
#    for i in [0...total]
#      randIndex = Math.floor(i+(Math.random()*(total-i)))
#      [picklist[i], picklist[randIndex]] = [picklist[randIndex], picklist[i]]
#    return picklist
  #This is a terrible method, but good enough for now. Use something based on above
  getRandomInactiveElementOfType: (type) ->
    #console.log "Searching for inactive "+type
    switch type
      when TYPE_FEATURE then upper = true
      when TYPE_DETECTOR then upper = true
      when TYPE_EFFECTOR then upper = false
      when TYPE_ALARM then upper = false
      #else return new Location()

    startCol = Math.floor Math.random()*NUMBER_OF_PLAYABLE_COLUMNS
    colIndex = startCol
    occupied = true
    looped = false
    theSpot = new Location()

    if upper
      while occupied and not looped
        theSpot = new Location(type, colIndex)
        occupied = @theModel.isCellActive theSpot
        #console.log "Col"+colIndex+" is "+(if occupied then "occupied" else "free")

        ## Increment to next Col option
        colIndex += 1
        colIndex = 0 if colIndex >= NUMBER_OF_PLAYABLE_COLUMNS
        looped = colIndex is startCol

    else
      startVar = Math.floor Math.random()*2 #TODO: Constant for Number of Varieties
      variety = startVar
      while occupied and not looped
        theSpot = new Location(type, colIndex, variety)
        occupied = @theModel.isCellActive theSpot
        #console.log "Col"+colIndex+" var"+variety+" is "+(if occupied then "occupied" else "free")

        ## Increment to next Col,Var option
        variety += 1
        if variety >= 2 #TODO: Constant for Number of Varieties
          variety = 0
          colIndex += 1
          colIndex = 0 if colIndex >= NUMBER_OF_PLAYABLE_COLUMNS
        looped = colIndex is startCol and variety is startVar

    if occupied
      alert "Could not find unoccupied cell"
      this.clearCurrentSelection()
      theSpot = new Location()

    return theSpot

  selectRandomInactiveElementOfType: (type) ->
    this.clearCurrentSelection()
    choice = this.getRandomInactiveElementOfType type
    @selectedElement = choice


  doDraw: (type) ->
    anElement = this.getRandomInactiveElementOfType type
    if anElement.isIllegalLocation() then return
    this.doSet true, anElement

  isTypeOnSideOf: (type, side) ->
    switch type
      when TYPE_ALARM    then return (side is SIDE_PLANT)
      when TYPE_DETECTOR then return (side is SIDE_PLANT)
      when TYPE_EFFECTOR then return (side is SIDE_PATHOGEN)
      when TYPE_FEATURE  then return (side is SIDE_PATHOGEN)
      else return false

  clearCurrentSelection: ->
    if @selectedElement.isIllegalLocation() isnt true
      oldState = @theModel.isCellActive @selectedElement
      this.setElementActivity oldState, (this.getElement @selectedElement)

    @selectedElement = new Location()
    this.updateGoButton @currentPlayer


  doSelect: (locWhere) ->
    #Reject if it's not for the right side

    this.clearCurrentSelection()

    if not this.isTypeOnSideOf locWhere.cardtype, @currentPlayer
#      alert "It is the "+@losingPlayer+" turn, and a "+type+" is not under "+@losingPlayer+" control."
      return

    selectionState = @theModel.isCellActive locWhere

    htmlCell = this.getElement locWhere

    # Don't bother selecting inactive elements, you can't discard or replace them
    if selectionState
      #console.log "Selecting "+theElement+": "+type+":"+colIndex+":"+theVariety
      #Set up new selected element
      htmlCell.css "border-style", "dotted"
      htmlCell.css "border-width", "3px"
      htmlCell.css "text-shadow",  "0 0 0.2em #FFF, 0 0 0.3em #FFF, 0 0 0.4em #FFF"
      htmlCell.css "opacity",      "1"

      #Remember for future use
      @selectedElement = locWhere

      this.updateGoButton @currentPlayer


  doSet: (newValue, locWhere) ->
    theElement = this.getElement locWhere
    console.log "doSet "+locWhere.cardtype+locWhere.colIndex+":"+theElement+" to "+newValue
    @theModel.setCell newValue, locWhere
    this.updateBoardState()
    this.setElementActivity newValue, theElement
    this.updateInteractionsAround locWhere
    return newValue

  updateInteractionsAt: (locWhere) ->
    if locWhere is null or locWhere.isIllegalLocation() then return
    theElement = this.getElement locWhere
    activeStates = @theModel.getStateCondidionsAt locWhere
    allStates = @theModel.getPossibleConditionsAt locWhere
    console.log "Active states: "+activeStates+ " out of: "+allStates
    for state in allStates
      if (0<= $.inArray(state, activeStates))
        theElement.addClass state
      else
        theElement.removeClass state

  updateInteractionsAround: (locWhere) ->
    console.log "Updating interactions for "+locWhere+" and neighbors"
    this.updateInteractionsAt locWhere
    above = locWhere.getLocationAbove()
    if not above.isIllegalLocation()
      this.updateInteractionsAt above
    for below in locWhere.getLocationsBelow()
      this.updateInteractionsAt below

  randomSelectionArray: (picks, total) ->
    picklist = (true for n in [0...picks]).concat (false for n in [picks...total])
    for i in [0...total]
      randIndex = Math.floor(i+(Math.random()*(total-i)))
      [picklist[i], picklist[randIndex]] = [picklist[randIndex], picklist[i]]
    return picklist

  doRandomize: ->
    #console.log "RANDOMIZING----------------------------------"

    randList = this.randomSelectionArray @distribution["features"], NUMBER_OF_FEATURES
    this.doSet randVal, new Location(TYPE_FEATURE, i) for randVal,i in randList

    randList = this.randomSelectionArray @distribution["detectors"], NUMBER_OF_DETECTORS
    this.doSet randVal, new Location(TYPE_DETECTOR, i) for randVal,i in randList

    randList = this.randomSelectionArray @distribution["effectors"], NUMBER_OF_EFFECTORS
    this.doSet randVal, new Location(TYPE_EFFECTOR, i>>1, i%2) for randVal,i in randList

    randList = this.randomSelectionArray @distribution["alarms"], NUMBER_OF_ALARMS
    this.doSet randVal, new Location(TYPE_ALARM, i>>1, i%2) for randVal,i in randList

    #console.log "RANDOMIZED-----------------------------------"

  rewardsForRound: ->
    existingAlarms = @theModel.countActiveCellsOfType TYPE_ALARM
    existingDetectors = @theModel.countActiveCellsOfType TYPE_DETECTOR

    existingFeatures = @theModel.countActiveCellsOfType TYPE_FEATURE
    existingEffectors = @theModel.countActiveCellsOfType TYPE_EFFECTOR

    #Plant rewards: -4 to 12, based on eschewing detectors
    plantRewards = 12
    plantExpenses = 2*existingDetectors #Having more than 5 detectors isn't worth it in the long run

    #Pathogen rewards: -4 to 12, based on collecting features
    pathoRewards = 2*(existingFeatures-2) #Having less than 3 features isn't worth it in the long run
    pathoExpenses = 0 #Expenses are intrinsic
    return {
      plant: plantRewards-plantExpenses
      pathogen: pathoRewards-pathoExpenses
      plant_reason: "12 income - 2*#{existingDetectors} expenses from #{existingDetectors} detectors"
      pathogen_reason: "2*(#{existingFeatures}-2) income based on #{existingFeatures} features"
    }

  costForAction: (actionType, elementType) ->
    detectionCostLimiter = 8
    existingAlarms = @theModel.countActiveCellsOfType TYPE_ALARM
    existingDetectors = @theModel.countActiveCellsOfType TYPE_DETECTOR
    excessDetectionTools = existingAlarms + existingDetectors - detectionCostLimiter

    existingFeatures = @theModel.countActiveCellsOfType TYPE_FEATURE
    existingEffectors = @theModel.countActiveCellsOfType TYPE_EFFECTOR
    roomForEffectors = existingEffectors < existingFeatures

    switch elementType
      when TYPE_ALARM
        drawCost = 10
        discardCost = 10
        replaceCost = 15 # < 20
        if excessDetectionTools > 0 then drawCost+=excessDetectionTools
      when TYPE_DETECTOR
        drawCost = 20
        discardCost = 10
        replaceCost = 25 # < 30
        if excessDetectionTools > 0 then drawCost+=excessDetectionTools
      when TYPE_FEATURE
        drawCost = 20
        discardCost = if roomForEffectors then 10 else 20
        replaceCost = 15 # < 30
        if existingFeatures <= 2 then discardCost = -1
      when TYPE_EFFECTOR
        drawCost = if roomForEffectors then 10 else 20
        discardCost = 10
        replaceCost = 15 # < 20

    #console.log "Draw cost: "+drawCost+" Discard cost: "+discardCost

    availablePoints = @pressurePoints[@currentPlayer]

    cost = switch actionType
      when ACTION_DISCARD then discardCost
      when ACTION_REPLACE then replaceCost
      when ACTION_DRAW then drawCost
      when ACTION_RANDOM then (if availablePoints < 5 then availablePoints else 5)
      else 0
    if cost < 0 then cost = -1

    #console.log "Cost of action "+actionType+" is "+cost
    return cost

  processAction: (whichSide) ->
    action = @actionChoices[whichSide].val()
    type = @selectedElement["type"]

    switch action
      when ACTION_DRAW_A
        type = TYPE_ALARM
        action = ACTION_DRAW
      when ACTION_DRAW_E
        type = TYPE_EFFECTOR
        action = ACTION_DRAW
      when ACTION_DRAW_F
        type = TYPE_FEATURE
        action = ACTION_DRAW
      when ACTION_DRAW_D
        type = TYPE_DETECTOR
        action = ACTION_DRAW
      when ACTION_RANDOM
        type = switch whichSide
          when SIDE_PLANT then (if Math.random() < 0.5 then TYPE_DETECTOR else TYPE_ALARM)
          when SIDE_PATHOGEN then (if Math.random() < 0.5 then TYPE_FEATURE else TYPE_EFFECTOR)


    switch action
      when ACTION_DISCARD
        this.doDiscardSelected()
      when ACTION_DRAW then this.doDraw type
      when ACTION_REPLACE
        this.doDraw type
        this.doDiscardSelected()
        #Draw before discard to prevent re-drawing the same card
      when ACTION_RANDOM
        this.doDraw type
        this.selectRandomInactiveElementOfType type
        this.doDiscardSelected()
    cost = this.costForAction action, type
    #console.log "Cost for "+action+"/"+type+": "+cost
    this.changePressure whichSide, -cost
    this.clearCurrentSelection()
    this.moveToNextTurn()

$(document).ready ->
  window.boardState = "Ready for input"
  window.controller = new PlayMatSolitaireController()
  control = window.controller

  for i in [0...NUMBER_OF_PLAYABLE_COLUMNS]
    control.connectElement new Location(TYPE_FEATURE,  i)
    control.connectElement new Location(TYPE_DETECTOR, i)
    control.connectElement new Location(TYPE_EFFECTOR, i, VARIETY_LEFT)
    control.connectElement new Location(TYPE_EFFECTOR, i, VARIETY_RIGHT)
    control.connectElement new Location(TYPE_ALARM,    i, VARIETY_LEFT)
    control.connectElement new Location(TYPE_ALARM,    i, VARIETY_RIGHT)

  control.goButtons[SIDE_PLANT] = $("#"+ID_PLANT_ENGAGE)
  control.actionChoices[SIDE_PLANT] = $("#"+ID_PLANT_ACTIONS)

  control.goButtons[SIDE_PATHOGEN] = $("#"+ID_PATHO_ENGAGE)
  control.actionChoices[SIDE_PATHOGEN] = $("#"+ID_PATHO_ACTIONS)

  control.pressureBoxen[SIDE_PLANT] = $("#"+ID_PLANT_PRESSURE)
  control.victoryBoxen[SIDE_PLANT] = $("#"+ID_PLANT_VICTORY)
  control.pressureBoxen[SIDE_PATHOGEN] = $("#"+ID_PATHO_PRESSURE)
  control.victoryBoxen[SIDE_PATHOGEN] = $("#"+ID_PATHO_VICTORY)


  control.goButtons[SIDE_PLANT].click ->
    control.processAction SIDE_PLANT

  control.goButtons[SIDE_PATHOGEN].click ->
    control.processAction SIDE_PATHOGEN

  control.actionChoices[SIDE_PATHOGEN].change ->
    control.updateGoButton SIDE_PATHOGEN

  control.actionChoices[SIDE_PLANT].change ->
    control.updateGoButton SIDE_PLANT

  control.doRandomize()
  control.moveToNextTurn()
  control.updateGoButton SIDE_PLANT
  control.updateGoButton SIDE_PATHOGEN

#  $("#comboBoard").change ->
#    answer = $(this).val();
#    gotItRight = control.processAnswer answer
#    if gotItRight then $(this).val("")  # Reset answer selection

