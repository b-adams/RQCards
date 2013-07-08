/**
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
 */

//"use strict"; // http://ejohn.org/blog/ecmascript-5-strict-mode-json-and-more/


function PlayMat()
{
    this.clearBoard();
    return this;
}

/* Data setup */

PlayMat.prototype.clearBoard = function()
{
    this.stateOfETI = false;
    this.stateOfMTI = false;

    this._columns = [];
    this._columnActivities = [];
    for(var i=0; i<NUMBER_OF_PLAYABLE_COLUMNS; i+=1)
    {
        this._columns[i] = {
            _MAMP: false,
            _PRR: false,
            _Effectors: [false, false],
            _RProteins: [false, false]
        };
        this._columnActivities[i] = {
//            _FeatureDetected: false,
            _DetectorTriggered: false,
            _DetectorDisabled: false,
            _EffectorsDisabling: [false, false],
//           _AlarmsTriggered: [false, false],
            _EffectorsDetected: [false, false]
        };
    }
};

/* Inputs */

PlayMat.prototype.setCell = function(newValue, type, colIndex)
{
    if(colIndex>=NUMBER_OF_PLAYABLE_COLUMNS) alert("Column "+colIndex+" too high");
    var theColumn = this._columns[colIndex];
    var wide = (arguments.length < 4);

    switch(type)
    {
        case TYPE_FEATURE:
            theColumn._MAMP = newValue;
            break;
        case TYPE_DETECTOR:
            theColumn._PRR = newValue;
            break;
        case TYPE_EFFECTOR:
            if(wide) alert("Effector variant not specified");
            theColumn._Effectors[arguments[3]] = newValue;
            break;
        case TYPE_ALARM:
            if(wide) alert("Alarm variant not specified");
            theColumn._RProteins[arguments[3]] = newValue;
            break;
        default:
            alert("Unknown cell type: "+type);
    }

    this.updateActivityInColumn(colIndex);

    this.updateStatesAfterChanging(type);

    if(wide) console.log("Set "+type+" in column "+colIndex+" to "+newValue);
    else     console.log("Set "+type+arguments[3]+" in column "+colIndex+" to "+newValue);
};
PlayMat.prototype.toggleCell = function(type, colIndex)
{
    var theColumn = this._columns[colIndex];
    var wide = (arguments.length < 3);
    var theNewValue;

    switch(type)
    {
        case TYPE_FEATURE:
            theNewValue = !theColumn._MAMP;
            break;
        case TYPE_DETECTOR:
            theNewValue = !theColumn._PRR;
            break;
        case TYPE_EFFECTOR:
            theNewValue = !theColumn._Effectors[arguments[2]];
            break;
        case TYPE_ALARM:
            theNewValue = !theColumn._RProteins[arguments[2]];
            break;
    }

    if(wide) this.setCell(theNewValue, type, colIndex);
    else     this.setCell(theNewValue, type, colIndex, arguments[2]);

    return theNewValue;
};

PlayMat.prototype.updateStatesAfterChanging = function (type) {
    switch (type) {
        case TYPE_FEATURE:
            this.updateMTIState();
            break;
        case TYPE_DETECTOR:
            this.updateMTIState();
            break;
        case TYPE_EFFECTOR:
            this.updateMTIState();
            this.updateETIState();
            break;
        case TYPE_ALARM:
            this.updateETIState();
            break;
        default:
            alert("Unknown cell type: " + type);
    }
};
/* Board state queries */

PlayMat.prototype.isCellActive = function (type, colIndex)
{
    if(colIndex>=NUMBER_OF_PLAYABLE_COLUMNS) alert("Too many columns:" +colIndex);
    var theColumn = this._columns[colIndex];

    switch(type)
    {
        case "Feature":
            return theColumn._MAMP;
            break;
        case "Detector":
            return theColumn._PRR;
            break;
        case "Effector":
            if(arguments.length<3) alert("Effector variant not specified");
            return theColumn._Effectors[arguments[2]];
            break;
        case "Alarm":
            if(arguments.length<3) alert("Alarm variant not specified");
            return theColumn._RProteins[arguments[2]];
            break;
        default:
            alert("Unknown cell type: "+type);
    }
    return -1;
};

/* Interaction state queries */

PlayMat.prototype.isPlantETIActive = function()
{
    return this.stateOfETI;
};
PlayMat.prototype.updateETIState = function()
{
    this.stateOfETI = this._columnActivities.some(function(actSet) {
        return (actSet._EffectorsDetected[0] || actSet._EffectorsDetected[1]) });
};

PlayMat.prototype.isPlantMTIActive = function()
{
    return this.stateOfMTI;
};
PlayMat.prototype.updateMTIState = function()
{
    this.stateOfMTI = this._columnActivities.filter(function(actSet) {
        return actSet._DetectorTriggered;
    }).length >= MAMP_MATCHES_TO_TRIGGER_MTI;
};

PlayMat.prototype.isPathogenVirulent = function()
{
    return !(this.stateOfETI || this.stateOfMTI);
};

/* Cell state query */

PlayMat.prototype.updateActivityInColumn = function(colIndex)
{
    var theColumn = this._columns[colIndex];
    var theList = this._columnActivities[colIndex];

    for(var slot=0; slot<2; slot+=1)
    {
        theList._EffectorsDisabling[slot] = theColumn._PRR && theColumn._Effectors[slot];
        theList._EffectorsDetected[slot] = theColumn._Effectors[slot] && theColumn._RProteins[slot];
//      theActivityList._AlarmsTriggered[slot] = theActivityList._EffectorsDetected[slot];
    }

    theList._DetectorDisabled = theList._EffectorsDisabling[0] || theList._EffectorsDisabling[1];
    theList._DetectorTriggered = theColumn._MAMP && theColumn._PRR && !theList._DetectorDisabled;
//  result._FeatureDetected = result._DetectorTriggered;
};

PlayMat.prototype.triggeredDetectors = function()
{
    return this._columnActivities.filter(function(anActivitySet) {
        return anActivitySet._DetectorTriggered; });
};

PlayMat.prototype.disabledDetectors = function()
{
    return this._columnActivities.filter(function(anActivitySet) {
        return anActivitySet._DetectorDisabled; });
};

PlayMat.prototype.disablingEffectors = function()
{
    return this._columnActivities.filter(function(actSet) {
        return (actSet._EffectorsDisabling[0] || actSet._EffectorsDisabling[1])});
};
PlayMat.prototype.triggeredAlarms = function()
{
    return this._columnActivities.filter(function(actSet) {
        return (actSet._EffectorsDetected[0] || actSet._EffectorsDetected[1])});
};