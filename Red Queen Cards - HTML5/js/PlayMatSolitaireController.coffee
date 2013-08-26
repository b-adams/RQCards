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
    @costBoxen = {
      plant: null
      pathogen: null
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

    console.log "Game: " + @boardState
    window.document.title = "Current state: " + @boardState

  updateForAction: (playerSide) ->
    actionType = @actionChoices[playerSide].val()
    elementType = @selectedElement["type"]
    switch actionType
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
    console.log "Preparing for "+actionType+"("+elementType+") action by "+playerSide

    cost = this.costForAction actionType, elementType
    @costBoxen[playerSide].html("Cost: "+cost)
    if cost > @pressurePoints[playerSide]
      @goButtons[playerSide].attr("disabled", "disabled")
    else
      @goButtons[playerSide].removeAttr("disabled")

  updateVictoryAndPressure: ->
    this.updateBoardState
    switch @boardState
      when "ETI"
        @pressurePoints[SIDE_PATHOGEN] += 2
        @victoryPoints[SIDE_PLANT] += 1
        alert "Plant wins (ETI).\nPathogen +2pp\nPlant +1vp"
        @actionChoices[SIDE_PLANT].attr("disabled", true)
        @actionChoices[SIDE_PLANT].hide()
        @actionChoices[SIDE_PATHOGEN].attr("disabled", false)
        @actionChoices[SIDE_PATHOGEN].show()
      when "MTI"
        @pressurePoints[SIDE_PATHOGEN] += 1
        @victoryPoints[SIDE_PLANT] += 1
        alert "Plant wins (MTI).\nPathogen +1pp\nPlant +1vp"
        @actionChoices[SIDE_PLANT].attr("disabled", true)
        @actionChoices[SIDE_PLANT].hide()
        @actionChoices[SIDE_PATHOGEN].attr("disabled", false)
        @actionChoices[SIDE_PATHOGEN].show()
      else #Virulence
        @pressurePoints[SIDE_PLANT] += 1
        @victoryPoints[SIDE_PATHOGEN] += 1
        alert "Pathogen wins (Virulence).\nPlant +1pp\nPathoven +1vp"
        @actionChoices[SIDE_PATHOGEN].attr("disabled", true)
        @actionChoices[SIDE_PATHOGEN].hide()
        @actionChoices[SIDE_PLANT].attr("disabled", false)
        @actionChoices[SIDE_PLANT].show()

    @victoryBoxen[SIDE_PLANT].html("Victory: "+@victoryPoints[SIDE_PLANT])
    @victoryBoxen[SIDE_PATHOGEN].html("Victory: "+@victoryPoints[SIDE_PATHOGEN])
    @pressureBoxen[SIDE_PLANT].html("Pressure: "+@pressurePoints[SIDE_PLANT])
    @pressureBoxen[SIDE_PATHOGEN].html("Pressure: "+@pressurePoints[SIDE_PATHOGEN])

    console.log "Pressure: " +@pressurePoints
    console.log "Victory: " +@victoryPoints

  doDiscard: (theElement, type, colIndex, theVariety...) ->
    self = this
    oldValue = @theModel.isCellActive type, colIndex, theVariety...
    if oldValue isnt true
      return false #No discarding cards you don't have
    else
      theElement ?= self.getElement type, colIndex, theVariety...
      @theModel.setCell false, type, colIndex, theVariety...
      this.updateVictoryAndPressure()
      switch type
        when TYPE_FEATURE  then @distribution["features"] -= 1
        when TYPE_DETECTOR then @distribution["detectors"] -= 1
        when TYPE_ALARM    then @distribution["alarms"] -= 1
        when TYPE_EFFECTOR then @distribution["effectors"] -= 1
      self.setElementActivity false, theElement
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
  selectInactiveElementOfType: (type) ->
    console.log "Searching for inactive "+type
    occupied = true
    colIndex = 0
    variety = 0
    while (occupied) and (colIndex <= NUMBER_OF_PLAYABLE_COLUMNS)
      variety += 1
      if variety > 1
        variety = 0
        colIndex += 1
      occupied = @theModel.isCellActive type, colIndex, variety
      console.log "Col"+colIndex+" var"+variety+" is "+(if occupied then "occupied" else "free")

    if occupied then alert "Could not find unoccupied cell"
    @selectedElement["element"] = this.getElement type, colIndex, variety
    @selectedElement["type"] = type
    @selectedElement["colIndex"] = colIndex
    @selectedElement["variety"] = variety

  doDraw: (type) ->
    this.selectInactiveElementOfType type
    this.doSet @selectedElement["element"], true, type, @selectedElement["colIndex"], @selectedElement["variety"]
    this.updateVictoryAndPressure()

  doSelect: (theElement, type, colIndex, theVariety...) ->
    #Reset current selected element
    if @selectedElement["element"] isnt null
      oldState = @theModel.isCellActive @selectedElement["type"], @selectedElement["colIndex"], @selectedElement["variety"]
      this.setElementActivity oldState, @selectedElement["element"]

    selectionState = @theModel.isCellActive type, colIndex, theVariety
    # Don't bother selecting inactive elements, you can't discard or replace them
    if selectionState
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
    else
      @selectedElement["element"] = null
      @selectedElement["type"] = -1
      @selectedElement["colIndex"] = -1
      @selectedElement["variety"] = -1


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
    console.log "RANDOMIZING----------------------------------"

    randList = self.randomSelectionArray @distribution["features"], NUMBER_OF_FEATURES
    self.doSet null, randVal, TYPE_FEATURE, i for randVal,i in randList

    randList = self.randomSelectionArray @distribution["detectors"], NUMBER_OF_DETECTORS
    self.doSet null, randVal, TYPE_DETECTOR, i for randVal,i in randList

    randList = self.randomSelectionArray @distribution["effectors"], NUMBER_OF_EFFECTORS
    self.doSet null, randVal, TYPE_EFFECTOR, i>>1, i%2 for randVal,i in randList

    randList = self.randomSelectionArray @distribution["alarms"], NUMBER_OF_ALARMS
    self.doSet null, randVal, TYPE_ALARM, i>>1, i%2 for randVal,i in randList

    console.log "RANDOMIZED-----------------------------------"

  costForAction: (actionType, elementType) ->
    existingAlarms = @theModel.countActiveCellsOfType TYPE_ALARM
    existingDetectors = @theModel.countActiveCellsOfType TYPE_DETECTOR
    existingFeatures = @theModel.countActiveCellsOfType TYPE_FEATURE
    existingEffectors = @theModel.countActiveCellsOfType TYPE_EFFECTOR
    roomForEffectors = existingEffectors < existingFeatures

    switch elementType
      when TYPE_ALARM
        drawCost = 1 * (1+existingAlarms) * (1+existingAlarms)
        discardCost = 1
      when TYPE_DETECTOR
        drawCost = 2 * (1+existingDetectors)
        discardCost = 2
      when TYPE_FEATURE
        drawCost = 1
        discardCost = if roomForEffectors then 1 else 2
        if existingFeatures is 2 then discardCost *= 3
        if existingFeatures < 2 then discardCost *= 100
      when TYPE_EFFECTOR
        drawCost = if roomForEffectors then 1 else 2
        discardCost = 1

    console.log "Draw cost: "+drawCost+" Discard cost: "+discardCost

    cost = switch actionType
      when ACTION_DISCARD then discardCost
      when ACTION_REPLACE then drawCost+discardCost
      when ACTION_DRAW then drawCost

    console.log "Cost of action "+actionType+" is "+cost
    return cost

  processAction: (whichSide) ->
    console.log "Processing action for "+whichSide
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

    @pressurePoints[whichSide] -= this.costForAction action, type

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

  control.costBoxen[SIDE_PLANT] = $("#"+ID_PLANT_COST)
  control.goButtons[SIDE_PLANT] = $("#"+ID_PLANT_ENGAGE)
  control.actionChoices[SIDE_PLANT] = $("#"+ID_PLANT_ACTIONS)

  control.costBoxen[SIDE_PATHOGEN] = $("#"+ID_PATHO_COST)
  control.goButtons[SIDE_PATHOGEN] = $("#"+ID_PATHO_ENGAGE)
  control.actionChoices[SIDE_PATHOGEN] = $("#"+ID_PATHO_ACTIONS)

  control.pressureBoxen[SIDE_PLANT] = $("#"+ID_PLANT_PRESSURE)
  control.victoryBoxen[SIDE_PLANT] = $("#"+ID_PLANT_VICTORY)
  control.pressureBoxen[SIDE_PATHOGEN] = $("#"+ID_PATHO_PRESSURE)
  control.victoryBoxen[SIDE_PATHOGEN] = $("#"+ID_PATHO_VICTORY)

  control.costBoxen[SIDE_PLANT].html "Cost: 0"
  control.costBoxen[SIDE_PATHOGEN].html "Cost: 0"

  control.goButtons[SIDE_PLANT].click ->
    control.processAction SIDE_PLANT

  control.goButtons[SIDE_PATHOGEN].click ->
    control.processAction SIDE_PATHOGEN

  control.actionChoices[SIDE_PATHOGEN].change ->
    control.updateForAction SIDE_PATHOGEN

  control.actionChoices[SIDE_PLANT].change ->
    control.updateForAction SIDE_PLANT

  control.doRandomize()
  control.updateVictoryAndPressure()

#  $("#comboBoard").change ->
#    answer = $(this).val();
#    gotItRight = control.processAnswer answer
#    if gotItRight then $(this).val("")  # Reset answer selection
