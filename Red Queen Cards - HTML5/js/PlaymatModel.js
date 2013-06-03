/**
 * Created with JetBrains WebStorm.
 * User: badams
 * Date: 5/31/13
 * Time: 9:34 PM
 * To change this template use File | Settings | File Templates.
 */

//"use strict"; // http://ejohn.org/blog/ecmascript-5-strict-mode-json-and-more/

var MAMP_MATCHES_TO_TRIGGER_MTI = 2;
var NUMBER_OF_PLAYABLE_COLUMNS = 8;
var TYPE_FEATURE = "Feature";
var TYPE_DETECTOR = "Detector";
var TYPE_EFFECTOR = "Effector";
var TYPE_ALARM = "Alarm";

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
    for(var i=0; i<NUMBER_OF_PLAYABLE_COLUMNS; i+=1)
    {
        this._columns[i] = {
            _MAMP: false,
            _PRR: false,
            _Effectors: [false, false],
            _RProteins: [false, false]
        }
    }
};

/* Inputs */

PlayMat.prototype.toggleCell = function(type, colIndex)
{
    if(colIndex>=NUMBER_OF_PLAYABLE_COLUMNS) alert("Column "+colIndex+" too high");

    var theColumn = this._columns[colIndex];
    var theNewValue;

    switch(type)
    {
        case TYPE_FEATURE:
            theNewValue = !theColumn._MAMP;
            theColumn._MAMP = theNewValue;
            this.updateMTIState();
            break;
        case TYPE_DETECTOR:
            theNewValue = !theColumn._PRR;
            theColumn._PRR = theNewValue;
            this.updateMTIState();
            break;
        case TYPE_EFFECTOR:
            if(arguments.length<3) alert("Effector variant not specified");
            theNewValue = !theColumn._Effectors[arguments[2]];
            theColumn._Effectors[arguments[2]] = theNewValue;
            this.updateMTIState();
            this.updateETIState();
            break;
        case TYPE_ALARM:
            if(arguments.length<3) alert("Alarm variant not specified");
            theNewValue = !theColumn._RProteins[arguments[2]];
            theColumn._RProteins[arguments[2]] = theNewValue;
            this.updateETIState();
            break;
        default:
            alert("Unknown cell type: "+type);
    }

    if(arguments.length<3)
        console.log("Toggled "+type+" in column "+colIndex+" to "+theNewValue);
    else
        console.log("Toggled "+type+arguments[2]+" in column "+colIndex+" to "+theNewValue);
    return theNewValue;
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
}
PlayMat.prototype.updateETIState = function()
{
    function columnActive(aColumn)
    {
        return ((aColumn._Effectors[0] && aColumn._RProteins[0])
            ||  (aColumn._Effectors[1] && aColumn._RProteins[1]));
    }

    this.stateOfETI = this._columns.some(columnActive);
};

PlayMat.prototype.isPlantMTIActive = function()
{
    return this.stateOfMTI;
}
PlayMat.prototype.updateMTIState = function()
{
    function columnActive(aColumn)
    {
        var disabled = aColumn._Effectors[0] || aColumn._Effectors[1];
        var triggered = aColumn._MAMP && aColumn._PRR;
        return triggered && !disabled;
    }
    this.stateOfMTI = this._columns.filter(columnActive).length >= MAMP_MATCHES_TO_TRIGGER_MTI;
};

PlayMat.prototype.isPathogenVirulent = function()
{
    return !(this.stateOfETI || this.stateOfMTI);
};

