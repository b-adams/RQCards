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

class PlayMatController
  constructor: ->
    @theModel = new PlayMat()
    @boardState = "Uninitialized"
    @currentLevel = 0
    @attempts = [
      "Level results"
      {correct: 0, incorrect: 0}
      {correct: 0, incorrect: 0}
      {correct: 0, incorrect: 0}
    ]

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
    theFeature.click -> self.doPlay theFeature, type, colIndex, theVariant...
    theFeature.css "border-style", "dashed"

  setElementActivity: (active, theElement) ->
      theElement.css "border-style",      if active then "solid"          else "dashed"
      theElement.css "border-width",      if active then "2px"            else "1px"
      theElement.css "-webkit-animation", if active then "select 1s"      else "deselect 1s"
      theElement.css "-webkit-transform", if active then "rotateX(0deg)"  else "rotateX(180deg)"
      theElement.css "opacity",           if active then "1"              else "0.25"

  updateBoardState: ->
    @boardState = switch
      when @theModel.isPlantETIActive() then "ETI"
      when @theModel.isPlantMTIActive() then "MTI"
      else                                   "Virulence"
    console.log "Board: " + @boardState
    window.document.title = "Current state: " + @boardState

  doSet: (theElement, newValue, type, colIndex, theVariety...) ->
    self = this
    oldValue = @theModel.isCellActive type, colIndex, theVariety...
    if oldValue isnt newValue
      theElement ?= self.getElement type, colIndex, theVariety...
      @theModel.setCell newValue, type, colIndex, theVariety...
      self.updateBoardState()
      self.setElementActivity newValue, theElement
    return newValue


  doPlay: (theElement, type, colIndex, theVariety...) ->
    self = this
    theElement ?= self.getElement type, colIndex, theVariety...
    active = @theModel.toggleCell type, colIndex, theVariety...
    self.updateBoardState()
    self.setElementActivity active, theElement
    return active

  randomSelectionArray: (picks, total) ->
    picklist = (true for n in [0...picks]).concat (false for n in [picks...total])
    for i in [0...total]
      randIndex = Math.floor(i+(Math.random()*(total-i)))
      [picklist[i], picklist[randIndex]] = [picklist[randIndex], picklist[i]]
    return picklist

  doRandomize: (features=4, detectors=4, effectors=4, alarms=4) ->
    self = this
    console.log "RANDOMIZING----------------------------------"

    randList = self.randomSelectionArray features, NUMBER_OF_FEATURES
    self.doSet null, randVal, TYPE_FEATURE, i for randVal,i in randList

    randList = self.randomSelectionArray detectors, NUMBER_OF_DETECTORS
    self.doSet null, randVal, TYPE_DETECTOR, i for randVal,i in randList

    randList = self.randomSelectionArray effectors, NUMBER_OF_EFFECTORS
    self.doSet null, randVal, TYPE_EFFECTOR, i>>1, i%2 for randVal,i in randList

    randList = self.randomSelectionArray alarms, NUMBER_OF_ALARMS
    self.doSet null, randVal, TYPE_ALARM, i>>1, i%2 for randVal,i in randList

    console.log "RANDOMIZED-----------------------------------"

  wrongSelectionInfoPopup: (suppliedAnswer, correctAnswer) ->
    return if suppliedAnswer is correctAnswer #Nothing wrong here
    return if not suppliedAnswer? #No answer provided
    diagnosis = "Incorrect.\nYou selected "+suppliedAnswer

    switch suppliedAnswer
      when "ETI"
        note = " but there are no effector-alarm matches."
        switch correctAnswer
          when "MTI"        then hint = note+"\nLook at the feature-detector row."
          when "Virulence"  then hint = note+"\nWere you looking at detector-effector disablements?"
          else "ERROR: How is "+correctAnswer+" possible?"
      when "MTI" then switch correctAnswer
          when "ETI"        then hint = ".\nKeep in mind that effector-alarm matches trump feature-detector ones."
          when "Virulence"  then hint = " but there are not enough *non-disabled* feature-detector matches."
          else "ERROR: How is "+correctAnswer+" possible?"
      when "Virulence" then switch correctAnswer
          when "MTI"        then hint = ".\nCheck again for active feature-detector matches."
          when "ETI"        then hint = ".\nCheck again for effector-alarmmatches."
          else "ERROR: How is "+correctAnswer+" possible?"
      else
        "ERROR: invalid answer"

    alert diagnosis+hint

  setupLevel: (whichLevel) ->
    self = this
    switch whichLevel
      when 1 then self.doRandomize 4,4,0,0
      when 2 then self.doRandomize 4,4,4,0
      when 3 then self.doRandomize 4,4,4,4
      else
        alert "Invalid level " + whichLevel
        return
    @currentLevel = whichLevel

  updateQuizLabels: (whichLevel) ->
    quizBox = $ "#Quiz"+whichLevel
    right = @attempts[whichLevel]["correct"]
    wrong = @attempts[whichLevel]["incorrect"]
    quizBox.html "Level #{whichLevel}<br>Answers: #{right+wrong} Correct: #{right}"
    return


$(document).ready ->
  window.boardState = "Ready for input"
  window.controller = new PlayMatController()
  control = window.controller

  for i in [0...NUMBER_OF_PLAYABLE_COLUMNS]
    control.connectElement(TYPE_FEATURE,  i)
    control.connectElement(TYPE_DETECTOR, i)
    control.connectElement(TYPE_EFFECTOR, i, 0)
    control.connectElement(TYPE_EFFECTOR, i, 1)
    control.connectElement(TYPE_ALARM,    i, 0)
    control.connectElement(TYPE_ALARM,    i, 1)

  $("#comboBoard").change ->
    answer = $(this).val();
    return if not answer?                         # Switched to empty
    if answer is control.boardState
      control.attempts[control.currentLevel]["correct"] += 1      # Note success
      control.setupLevel control.currentLevel                     # Reset current level
      $(this).val("")                             # Reset answer box
    else
      control.attempts[control.currentLevel]["incorrect"] += 1    # Note failure
      control.wrongSelectionInfoPopup answer, control.boardState  # Pop up a hint

    control.updateQuizLabels control.currentLevel                 # Update correct/incorrect display

  $("#ClearBoardButton").click -> control.doRandomize(0,0,0,0)

  $("#Quiz1").click -> control.setupLevel 1
  $("#Quiz2").click -> control.setupLevel 2
  $("#Quiz3").click -> control.setupLevel 3
  $("#Quiz4").click -> alert "Not yet implemented"
