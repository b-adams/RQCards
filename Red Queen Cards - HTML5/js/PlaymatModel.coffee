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

  setCell: (newValue, type, colIndex) ->

    if colIndex>=NUMBER_OF_PLAYABLE_COLUMNS then alert "Column #{colIndex} too high"

    theColumn = @_columns[colIndex];

    switch type
      when TYPE_FEATURE   then theColumn._MAMP = newValue
      when TYPE_DETECTOR  then theColumn._PRR = newValue
      when TYPE_EFFECTOR  then theColumn._Effectors[arguments[3]] = newValue
      when TYPE_ALARM     then theColumn._RProteins[arguments[3]] = newValue
      else alert "Unknown cell type: #{type}"

    this.updateActivityInColumn colIndex

    this.updateStatesAfterChanging(type);

    variant = if (arguments.length < 4) then "" else arguments[3]
    console.log "Set #{type}#{variant} in column #{colIndex} to #{newValue}"


  toggleCell: (type, colIndex, theVariant...) ->
    theColumn = @_columns[colIndex];

    switch type
      when TYPE_FEATURE   then theNewValue = !theColumn._MAMP
      when TYPE_DETECTOR  then theNewValue = !theColumn._PRR
      when TYPE_EFFECTOR  then theNewValue = !theColumn._Effectors[arguments[2]]
      when TYPE_ALARM     then theNewValue = !theColumn._RProteins[arguments[2]]
      else alert "Unknown cell type: #{type}"

    this.setCell theNewValue, type, colIndex, theVariant...

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

  isCellActive: (type, colIndex, theVariant...) ->
    if colIndex>=NUMBER_OF_PLAYABLE_COLUMNS then alert "Too many columns: #{colIndex}"
    theColumn = @_columns[colIndex];

    switch type
      when TYPE_FEATURE   then return theColumn._MAMP
      when TYPE_DETECTOR  then return theColumn._PRR
      when TYPE_EFFECTOR
        if arguments.length<3 then alert "Effector variant not specified"
        return theColumn._Effectors[arguments[2]]
      when TYPE_ALARM
        if arguments.length<3 then alert "Alarm variant not specified"
        return theColumn._RProteins[arguments[2]]
      else alert "Unknown cell type: #{type}"
    return -1

# Interaction state queries

  isPlantETIActive: -> @stateOfETI

  isPlantMTIActive: -> @stateOfMTI

  isPathogenVirulent: -> not (@stateOfETI or @stateOfMTI)

  updateETIState: ->
    @stateOfETI = @_columnActivities.some (actSet)->
      actSet._EffectorsDetected[0] or actSet._EffectorsDetected[1]

  updateMTIState: ->
    @stateOfMTI = @_columnActivities.filter((actSet) -> actSet._DetectorTriggered).length >= MAMP_MATCHES_TO_TRIGGER_MTI

# Cell state queries

  updateActivityInColumn: (colIndex) ->
    theColumn = @_columns[colIndex]
    theList = @_columnActivities[colIndex]
    for slot in [0..1]
      theList._EffectorsDisabling[slot] = (theColumn._PRR and theColumn._Effectors[slot])
      theList._EffectorsDetected[slot]  = (theColumn._Effectors[slot] and theColumn._RProteins[slot])
    theList._DetectorDisabled  = (theList._EffectorsDisabling[0] or theList._EffectorsDisabling[1])
    theList._DetectorTriggered = (theColumn._MAMP and theColumn._PRR and not theList._DetectorDisabled)

  triggeredDetectors: ->
    return @_columnActivities.filter (actSet) -> actSet._DetectorTriggered

  disabledDetectors: ->
    return @_columnActivities.filter (actSet) -> actSet._DetectorDisabled

  disablingEffectors: ->
    return @_columnActivities.filter (actSet) -> (actSet._EffectorsDisabling[0] or actSet._EffectorsDisabling[1])

  triggeredAlarms: ->
    return @_columnActivities.filter (actSet) -> (actSet._EffectorsDetected[0] or actSet._EffectorsDetected[1])
