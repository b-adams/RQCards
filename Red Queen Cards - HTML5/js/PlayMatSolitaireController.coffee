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
    @theModel = new PlayMat()
    @boardState = "Uninitialized"
    @iteration = 0
    @currentPlayer = "Uninitialized"
    @distribution = {
      features: 4
      detectors: 4
      effectors: 4
      alarms: 4
    }
    @pressurePoints = {
      plant: 2
      pathogen: 2
    }
    @victoryPoints = {
      plant: 0
      pathogen: 0
    }
    @selectedElement = {
      element: null
      type: -1
      colIndex: -1
      variety: -1
    }
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
    console.log "Changing pressure for "+side+" by "+amount+". New total: "+@pressurePoints[side]


  getElement: (type, colIndex) ->
    selector = "#board > #c"+(colIndex+1)+" > ."
    switch type
      when TYPE_FEATURE  then selector+="feature"
      when TYPE_DETECTOR then selector+="detector"
      when TYPE_EFFECTOR then selector+="e"+(arguments[2]+1)
      when TYPE_ALARM    then selector+="a"+(arguments[2]+1)
      else
        alert "Bad element request"
        selector=""
    return $ selector

  connectElement: (type, colIndex, theVariant...) ->
    self = this
    theFeature = self.getElement type, colIndex, theVariant...
    theFeature.click -> self.doSelect theFeature, type, colIndex, theVariant...
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
      when @theModel.isPlantETIActive() then "ETI"
      when @theModel.isPlantMTIActive() then "MTI"
      else                                   "Virulence"

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
      else
        @goButtons[whoseSide].html("Action Required")
        @goButtons[whoseSide].attr("disabled", "disabled")
        @goButtons[whoseSide].css "background", "grey"
        return

    cost = this.costForAction actionType, elementType
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

    switch @boardState
      when "ETI"
        winner = SIDE_PLANT
        loser =  SIDE_PATHOGEN
        pressureForLoser = 2
        victoryForWinner = 1
        message = "Plant wins round "+@iteration+" (ETI).\nPathogen +2pp\nPlant +1vp"
      when "MTI"
        winner = SIDE_PLANT
        loser =  SIDE_PATHOGEN
        pressureForLoser = 1
        victoryForWinner = 1
        message = "Plant wins round "+@iteration+" (MTI).\nPathogen +1pp\nPlant +1vp"
      else #Virulence
        winner = SIDE_PATHOGEN
        loser =  SIDE_PLANT
        pressureForLoser = 1
        victoryForWinner = 1
        message = "Pathogen wins round "+@iteration+" (Virulence).\nPlant +1pp\nPathoven +1vp"

    @currentPlayer = loser
    alert message if firstPhaseFilter isnt 0
    this.changePressure loser, pressureForLoser*firstPhaseFilter
    @victoryPoints[winner] += victoryForWinner*firstPhaseFilter
    @actionChoices[winner].hide()
    @actionChoices[loser].show()
    @goButtons[winner].hide()
    @goButtons[loser].show()

    @victoryBoxen[SIDE_PLANT].html("Victory: "+@victoryPoints[SIDE_PLANT])
    @victoryBoxen[SIDE_PATHOGEN].html("Victory: "+@victoryPoints[SIDE_PATHOGEN])
    @pressureBoxen[SIDE_PLANT].html("Pressure: "+@pressurePoints[SIDE_PLANT])
    @pressureBoxen[SIDE_PATHOGEN].html("Pressure: "+@pressurePoints[SIDE_PATHOGEN])

    document.title = "State: "+@boardState+" | Turn: "+@currentPlayer
    @iteration += 1
    console.log "Moved to turn "+@iteration

  doDiscard: (theElement, type, colIndex, theVariety...) ->
    self = this
    oldValue = @theModel.isCellActive type, colIndex, theVariety...
    if oldValue isnt true
      return false #No discarding cards you don't have
    else
      theElement ?= self.getElement type, colIndex, theVariety...
      @theModel.setCell false, type, colIndex, theVariety...
      switch type
        when TYPE_FEATURE  then @distribution["features"] -= 1
        when TYPE_DETECTOR then @distribution["detectors"] -= 1
        when TYPE_ALARM    then @distribution["alarms"] -= 1
        when TYPE_EFFECTOR then @distribution["effectors"] -= 1
      self.setElementActivity false, theElement
      #this.moveToNextTurn()
      return true #Discard successful

  doDiscardSelected: ->
    this.doDiscard @selectedElement["element"], @selectedElement["type"], @selectedElement["colIndex"], @selectedElement["variety"]

#  randomSelectionArray: (picks, total) ->
#    picklist = (true for n in [0...picks]).concat (false for n in [picks...total])
#    for i in [0...total]
#      randIndex = Math.floor(i+(Math.random()*(total-i)))
#      [picklist[i], picklist[randIndex]] = [picklist[randIndex], picklist[i]]
#    return picklist
  #This is a terrible method, but good enough for now. Use something based on above
  getRandomInactiveElementOfType: (type) ->
    #console.log "Searching for inactive "+type
    startCol = Math.floor Math.random()*NUMBER_OF_PLAYABLE_COLUMNS
    startVar = Math.floor Math.random()*2 #TODO: Constant for Number of Varieties
    colIndex = startCol
    variety = startVar
    occupied = true
    notLooped = true
    while occupied and notLooped
      occupied = @theModel.isCellActive type, colIndex, variety
      #console.log "Col"+colIndex+" var"+variety+" is "+(if occupied then "occupied" else "free")

      ## Increment to next Col,Var option
      if occupied
        variety += 1
        if variety >= 2 #TODO: Constant for Number of Varieties
          variety = 0
          colIndex += 1
          if colIndex >= NUMBER_OF_PLAYABLE_COLUMNS
            colIndex = 0

      notLooped = colIndex isnt startCol or variety isnt startVar


    if occupied
      alert "Could not find unoccupied cell"
      this.clearCurrentSelection()
      return null

    else
      return {
        element: this.getElement type, colIndex, variety
        type: type
        colIndex: colIndex
        variety: variety
      }

  doDraw: (type) ->
    anElement = this.getRandomInactiveElementOfType type
    if anElement is null then return
    this.doSet anElement["element"], true, type, anElement["colIndex"], anElement["variety"]

  isTypeOnSideOf: (type, side) ->
    switch type
      when TYPE_ALARM    then return (side is SIDE_PLANT)
      when TYPE_DETECTOR then return (side is SIDE_PLANT)
      when TYPE_EFFECTOR then return (side is SIDE_PATHOGEN)
      when TYPE_FEATURE  then return (side is SIDE_PATHOGEN)
      else return false

  clearCurrentSelection: ->
    if @selectedElement["element"] isnt null
      oldState = @theModel.isCellActive @selectedElement["type"], @selectedElement["colIndex"], @selectedElement["variety"]
      this.setElementActivity oldState, @selectedElement["element"]

    @selectedElement["element"] = null
    @selectedElement["type"] = -1
    @selectedElement["colIndex"] = -1
    @selectedElement["variety"] = -1
    this.updateGoButton @currentPlayer


  doSelect: (theElement, type, colIndex, theVariety...) ->
    #Reject if it's not for the right side

    this.clearCurrentSelection()

    if not this.isTypeOnSideOf type, @currentPlayer
#      alert "It is the "+@losingPlayer+" turn, and a "+type+" is not under "+@losingPlayer+" control."
      return

    selectionState = @theModel.isCellActive type, colIndex, theVariety

    # Don't bother selecting inactive elements, you can't discard or replace them
    if selectionState
      #console.log "Selecting "+theElement+": "+type+":"+colIndex+":"+theVariety
      #Set up new selected element
      theElement.css "border-style", "dotted"
      theElement.css "border-width", "3px"
      theElement.css "text-shadow",  "0 0 0.2em #FFF, 0 0 0.3em #FFF, 0 0 0.4em #FFF"
      theElement.css "opacity",      "1"

      #Remember for future use
      @selectedElement["element"] = theElement
      @selectedElement["type"] = type
      @selectedElement["colIndex"] = colIndex
      @selectedElement["variety"] = theVariety

      this.updateGoButton @currentPlayer


  doSet: (theElement, newValue, type, colIndex, theVariety...) ->
    self = this
    oldValue = @theModel.isCellActive type, colIndex, theVariety...
    if oldValue isnt newValue
      theElement ?= self.getElement type, colIndex, theVariety...
      @theModel.setCell newValue, type, colIndex, theVariety...
      self.updateBoardState()
      self.setElementActivity newValue, theElement
    return newValue

  randomSelectionArray: (picks, total) ->
    picklist = (true for n in [0...picks]).concat (false for n in [picks...total])
    for i in [0...total]
      randIndex = Math.floor(i+(Math.random()*(total-i)))
      [picklist[i], picklist[randIndex]] = [picklist[randIndex], picklist[i]]
    return picklist

  doRandomize: ->
    self = this
    #console.log "RANDOMIZING----------------------------------"

    randList = self.randomSelectionArray @distribution["features"], NUMBER_OF_FEATURES
    self.doSet null, randVal, TYPE_FEATURE, i for randVal,i in randList

    randList = self.randomSelectionArray @distribution["detectors"], NUMBER_OF_DETECTORS
    self.doSet null, randVal, TYPE_DETECTOR, i for randVal,i in randList

    randList = self.randomSelectionArray @distribution["effectors"], NUMBER_OF_EFFECTORS
    self.doSet null, randVal, TYPE_EFFECTOR, i>>1, i%2 for randVal,i in randList

    randList = self.randomSelectionArray @distribution["alarms"], NUMBER_OF_ALARMS
    self.doSet null, randVal, TYPE_ALARM, i>>1, i%2 for randVal,i in randList

    #console.log "RANDOMIZED-----------------------------------"

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
        drawCost = 1
        discardCost = 1
        if excessDetectionTools > 0 then drawCost+=excessDetectionTools
      when TYPE_DETECTOR
        drawCost = 2
        discardCost = 1
        if excessDetectionTools > 0 then drawCost+=excessDetectionTools
      when TYPE_FEATURE
        drawCost = 1
        discardCost = if roomForEffectors then 1 else 2
        if existingFeatures is 2 then discardCost *= 3
        if existingFeatures < 2 then discardCost *= 100
      when TYPE_EFFECTOR
        drawCost = if roomForEffectors then 1 else 2
        discardCost = 1

    #console.log "Draw cost: "+drawCost+" Discard cost: "+discardCost

    cost = switch actionType
      when ACTION_DISCARD then discardCost
      when ACTION_REPLACE then drawCost+discardCost
      when ACTION_DRAW then drawCost
      else 0

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

    switch action
      when ACTION_DISCARD
        this.doDiscardSelected()
      when ACTION_DRAW then this.doDraw type
      when ACTION_REPLACE
        this.doDraw type
        this.doDiscardSelected()
        #Draw before discard to prevent re-drawing the same card
    cost = this.costForAction action, type
    console.log "Cost for "+action+"/"+type+": "+cost
    this.changePressure whichSide, -cost
    this.clearCurrentSelection()
    this.moveToNextTurn()

$(document).ready ->
  window.boardState = "Ready for input"
  window.controller = new PlayMatSolitaireController()
  control = window.controller

  for i in [0...NUMBER_OF_PLAYABLE_COLUMNS]
    control.connectElement(TYPE_FEATURE,  i)
    control.connectElement(TYPE_DETECTOR, i)
    control.connectElement(TYPE_EFFECTOR, i, 0)
    control.connectElement(TYPE_EFFECTOR, i, 1)
    control.connectElement(TYPE_ALARM,    i, 0)
    control.connectElement(TYPE_ALARM,    i, 1)

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
