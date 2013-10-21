###
* Created with JetBrains WebStorm.
* User: badams
* Date: 5/31/13
* Time: 9:34 PM

Data model for Red Queen playmat game mechanic
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

# "use strict"; // http://ejohn.org/blog/ecmascript-5-strict-mode-json-and-more/

window.PlayMat = class PlayMat
  constructor: ->
    this.clearBoard()
    #alert "Mat Build 131015@2341"
    return this

# Data setup

  clearBoard: ->
    @stateOfETI = false;
    @stateOfMTI = false;

    @_columns = [];
    @_columnActivities = [];
    for i in [0...NUMBER_OF_PLAYABLE_COLUMNS]
        @_columns[i] =
            _MAMP: false
            _PRR: false
            _Effectors: [false, false]
            _RProteins: [false, false]
        @_columnActivities[i] =
#           _FeatureDetected: false
            _DetectorTriggered: false
            _DetectorDisabled: false
            _EffectorsDisabling: [false, false]
#           _AlarmsTriggered: [false, false]
            _EffectorsDetected: [false, false]

# Inputs

  setCell: (newValue, locWhere) ->

    if locWhere.isIllegalLocation() then alert "Attempting to set illegal location #{locWhere}"

    theColumn = @_columns[locWhere.colIndex];

    switch locWhere.cardtype
      when TYPE_FEATURE   then theColumn._MAMP = newValue
      when TYPE_DETECTOR  then theColumn._PRR = newValue
      when TYPE_EFFECTOR  then theColumn._Effectors[locWhere.variety] = newValue
      when TYPE_ALARM     then theColumn._RProteins[locWhere.variety] = newValue
      else alert "Unknown cell type: #{locWhere.cardtype}"

    this.updateActivityInColumn locWhere.colIndex

    this.updateStatesAfterChanging(locWhere.cardtype)

    variant = locWhere.getVariantString()
    #console.log "Set #{locWhere.cardtype}#{variant} in column #{locWhere.colIndex} to #{newValue}"


  toggleCell: (type, locWhere) ->
    theColumn = @_columns[locWhere.colIndex];

    switch locWhere.cardtype
      when TYPE_FEATURE   then theNewValue = !theColumn._MAMP
      when TYPE_DETECTOR  then theNewValue = !theColumn._PRR
      when TYPE_EFFECTOR  then theNewValue = !theColumn._Effectors[locWhere.variety]
      when TYPE_ALARM     then theNewValue = !theColumn._RProteins[locWhere.variety]
      else alert "Unknown cell type: #{locWhere.cardtype}"

    this.setCell theNewValue, locWhere

    return theNewValue


  updateStatesAfterChanging: (type) ->
    switch type
      when TYPE_FEATURE   then this.updateMTIState()
      when TYPE_DETECTOR  then this.updateMTIState()
      when TYPE_ALARM     then this.updateETIState()
      when TYPE_EFFECTOR
        this.updateMTIState()
        this.updateETIState()
      else alert "Unknown cell type: #{type}"

#  Board state queries

  isCellActive: (locWhere) ->
    if locWhere.isIllegalLocation() then alert "Attempting to query illegal location #{locWhere}"
    theColumn = @_columns[locWhere.colIndex];

    switch locWhere.cardtype
      when TYPE_FEATURE   then return theColumn._MAMP
      when TYPE_DETECTOR  then return theColumn._PRR
      when TYPE_EFFECTOR  then return theColumn._Effectors[locWhere.variety]
      when TYPE_ALARM     then return theColumn._RProteins[locWhere.variety]
      else alert "Unknown cell type: #{locWhere.cardtype}"
    return -1

  isDetectorDisabled: (colIndex) ->
    if colIndex>=NUMBER_OF_PLAYABLE_COLUMNS then alert "Too many columns: #{colIndex}"
    theColumn = @_columns[colIndex];
    return theColumn._Effectors[VARIETY_LEFT] or theColumn._Effectors[VARIETY_RIGHT]

  countActiveCellsOfType: (type) ->
    actives = 0
    switch type
      when TYPE_FEATURE
        for theColumn in @_columns
          if theColumn._MAMP then actives += 1
      when TYPE_DETECTOR
        for theColumn in @_columns
          if theColumn._PRR then actives += 1
      when TYPE_ALARM
        for theColumn in @_columns
          if theColumn._RProteins[VARIETY_LEFT] then actives += 1
          if theColumn._RProteins[VARIETY_RIGHT] then actives += 1
      when TYPE_EFFECTOR
        for theColumn in @_columns
          if theColumn._Effectors[VARIETY_LEFT] then actives += 1
          if theColumn._Effectors[VARIETY_RIGHT] then actives += 1
      else alert "Unknown cell type: #{type}"
    return actives



# Interaction state queries

  isPlantETIActive: -> @stateOfETI

  isPlantMTIActive: -> @stateOfMTI

  isPathogenVirulent: -> not (@stateOfETI or @stateOfMTI)

  updateETIState: ->
    @stateOfETI = @_columnActivities.some (actSet)->
      actSet._EffectorsDetected[VARIETY_LEFT] or actSet._EffectorsDetected[VARIETY_RIGHT]

  updateMTIState: ->
    @stateOfMTI = @_columnActivities.filter((actSet) -> actSet._DetectorTriggered).length >= MAMP_MATCHES_TO_TRIGGER_MTI

# Cell state queries

  updateActivityInColumn: (colIndex) ->
    theColumn = @_columns[colIndex]
    theList = @_columnActivities[colIndex]
    for slot in [VARIETY_LEFT, VARIETY_RIGHT]
      theList._EffectorsDisabling[slot] = (theColumn._PRR and theColumn._Effectors[slot])
      theList._EffectorsDetected[slot]  = (theColumn._Effectors[slot] and theColumn._RProteins[slot])
    theList._DetectorDisabled  = (theList._EffectorsDisabling[VARIETY_LEFT] or theList._EffectorsDisabling[VARIETY_RIGHT])
    theList._DetectorTriggered = (theColumn._MAMP and theColumn._PRR and not theList._DetectorDisabled)

  triggeredDetectors: ->
    return @_columnActivities.filter (actSet) -> actSet._DetectorTriggered

  disabledDetectors: ->
    return @_columnActivities.filter (actSet) -> actSet._DetectorDisabled

  disablingEffectors: ->
    return @_columnActivities.filter (actSet) -> (actSet._EffectorsDisabling[VARIETY_LEFT] or actSet._EffectorsDisabling[VARIETY_RIGHT])

  triggeredAlarms: ->
    return @_columnActivities.filter (actSet) -> (actSet._EffectorsDetected[VARIETY_LEFT] or actSet._EffectorsDetected[VARIETY_RIGHT])

  getStateCondidionsAt: (locWhere) ->
    if not this.isCellActive locWhere
      return [STATE_ABSENT]

    states = [STATE_PRESENT]

    switch locWhere.cardtype
      when TYPE_FEATURE
        detectorLoc = locWhere.getLocationBelow()
        detected = (this.isCellActive detectorLoc) and not (this.isDetectorDisabled locWhere.colIndex)
        if detected then states.push STATE_DETECTED

      when TYPE_DETECTOR
        busted = false
        for effectorLoc,variant in locWhere.getLocationsBelow()
          disabled = this.isCellActive effectorLoc
          busted = busted or disabled
          if disabled then states.push (STATE_DISABLED+variant)

        if busted
          states.push STATE_DISABLED
        else
          featureLoc = locWhere.getLocationAbove()
          detecting = this.isCellActive featureLoc
          if detecting then states.push STATE_DETECTING

      when TYPE_EFFECTOR
        detectorLoc = locWhere.getLocationAbove()
        disabling = this.isCellActive detectorLoc
        if disabling then states.push STATE_DISABLING

        alarmLoc = locWhere.getLocationBelow()
        alarming = this.isCellActive alarmLoc
        if alarming then states.push STATE_ALARMING

      when TYPE_ALARM
        effectorLoc = locWhere.getLocationAbove()
        alarmed = this.isCellActive effectorLoc
        if alarmed then states.push STATE_ALARMED

    return states

  getPossibleConditionsAt: (locWhere) ->
    states = [STATE_ABSENT, STATE_PRESENT]
    switch locWhere.cardtype
      when TYPE_FEATURE then states.push STATE_DETECTED
      when TYPE_DETECTOR
        states.push STATE_DETECTING
        states.push STATE_DISABLED
        states.push STATE_DISABLED_LEFT
        states.push STATE_DISABLED_RIGHT
      when TYPE_EFFECTOR
        states.push STATE_DISABLING
        states.push STATE_ALARMING
      when TYPE_ALARM then states.push STATE_ALARMED
    return states

  getDetectedFeatures: ->
    detectedSet = []
    for theColumn, colNum in @_columns
      cardLoc = new Location(TYPE_FEATURE, colNum)
      thisCellActive = this.isCellActive cardLoc
      somethingDetectingMe = this.isCellActive cardLoc.getLocationBelow()
      detectorBusted = this.isDetectorDisabled cardLoc.colIndex
      detected = thisCellActive and somethingDetectingMe and not detectorBusted
      if detected then detectedSet.push cardLoc
    return detectedSet

  getDetectedEffectors: ->
    detectedSet = []
    for theColumn, colNum in @_columns
      for variety in [VARIETY_LEFT, VARIETY_RIGHT]
        cardLoc = new Location(TYPE_EFFECTOR, colNum, variety)
        thisCellActive = this.isCellActive cardLoc
        somethingDetectingMe = this.isCellActive cardLoc.getLocationBelow()
        detected = thisCellActive and somethingDetectingMe
        if detected then detectedSet.push cardLoc
    return detectedSet

  getPathogenEvolutionReplacementOptions: (lumpThemAllTogetherMode) ->
    effectors = this.getDetectedEffectors()
    features = this.getDetectedFeatures()
    if lumpThemAllTogetherMode
      return effectors.concat features
    else
      if effectors.length > 0
        return effectors
      else
        return features

  getUselessDetectors: ->
    uselessSet = []
    for theColumn, colNum in @_columns
      cardLoc = new Location(TYPE_DETECTOR, colNum)
      thisCellActive = this.isCellActive cardLoc
      somethingToDetect = this.isCellActive cardLoc.getLocationAbove()
      detectorBusted = this.isDetectorDisabled cardLoc.colIndex
      detecting = thisCellActive and somethingToDetect and not detectorBusted
      thisCellUseless = thisCellActive and not detecting
      if thisCellUseless then uselessSet.push cardLoc
    return uselessSet

  getUselessAlarms: ->
    uselessSet = []
    for theColumn, colNum in @_columns
      for variety in [VARIETY_LEFT, VARIETY_RIGHT]
        cardLoc = new Location(TYPE_ALARM, colNum, variety)
        thisCellActive = this.isCellActive cardLoc
        somethingToDetect = this.isCellActive cardLoc.getLocationAbove()
        detecting = thisCellActive and somethingToDetect
        thisCellUseless = thisCellActive and not detecting
        if thisCellUseless then uselessSet.push cardLoc
    return uselessSet

  getPlantEvolutionReplacementOptions: (lumpThemAllTogetherMode) ->
    detectors = this.getUselessDetectors()
    alarms = this.getUselessAlarms()
    if lumpThemAllTogetherMode
      return detectors.concat alarms
    else
      if alarms.length > 0
        return alarms
      else
        return detectors

  getRandomEvolutionReplacementLocation: (whichSide) ->
    switch whichSide
      when SIDE_PLANT then theOptions = this.getPlantEvolutionReplacementOptions true #select effectors and features equally
      when SIDE_PATHOGEN then theOptions = this.getPathogenEvolutionReplacementOptions false #select alarms before detectors
    numOptions = theOptions.length
    #console.log numOptions+" options: "+theOptions
    if numOptions > 0
      randomIndex = Math.floor(Math.random() * numOptions)
      chosenLocation = theOptions[randomIndex]
    else
      chosenLocation = new Location()
    return chosenLocation


window.Location = class Location
  constructor: (@cardtype=-1, @colIndex=-1, @variety=-1) ->
    return this

  isIllegalLocation: ->
    if @colIndex < 0 or @colIndex > NUMBER_OF_PLAYABLE_COLUMNS then return true
    switch @cardtype
      when TYPE_FEATURE   then (if @variety isnt -1 then return true)
      when TYPE_DETECTOR  then (if @variety isnt -1 then return true)
      when TYPE_EFFECTOR  then (if @variety < 0 or @variety > 1 then return true)
      when TYPE_ALARM     then (if @variety < 0 or @variety > 1 then return true)
      else return true
    return false

  getVariantString: ->
    if (@variety is VARIETY_NONE) then "" else @variety

  getLocationAbove: ->
    return switch @cardtype
      when TYPE_DETECTOR  then new Location(TYPE_FEATURE, @colIndex)
      when TYPE_EFFECTOR  then new Location(TYPE_DETECTOR, @colIndex)
      when TYPE_ALARM     then new Location(TYPE_EFFECTOR, @colIndex, @variety)
      else                     new Location()

  getLocationsBelow: ->
    return switch @cardtype
      when TYPE_FEATURE   then [new Location(TYPE_DETECTOR, @colIndex)]
      when TYPE_DETECTOR  then [new Location(TYPE_EFFECTOR, @colIndex, VARIETY_LEFT), new Location(TYPE_EFFECTOR, @colIndex, VARIETY_RIGHT)]
      when TYPE_EFFECTOR  then [new Location(TYPE_ALARM, @colIndex, @variety)]
      else []

  getLocationBelow: ->
    locations = this.getLocationsBelow()
    if locations.length is 1
      return locations[0]
    else
      alert "Location below is non-unique!"
      return null

  toString: ->
    if this.isIllegalLocation() then return "Illegal location "+@cardtype+"/"+@colIndex+"/"+@variety
    if @variety is -1 then return "Loc [Type="+@cardtype+", col="+@colIndex+"]"
    return "Loc [Type="+@cardtype+", col="+@colIndex+", var="+@variety+"]"


