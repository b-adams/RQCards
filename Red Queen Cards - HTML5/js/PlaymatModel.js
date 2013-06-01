/**
 * Created with JetBrains WebStorm.
 * User: badams
 * Date: 5/31/13
 * Time: 9:34 PM
 * To change this template use File | Settings | File Templates.
 */

var MAMP_MATCHES_TO_TRIGGER_MTI = 2;
var NUMBER_OF_PLAYABLE_COLUMNS = 8;

function PlayMat()
{
    this.clearBoard();
    return this;
}

    /* Data setup */

PlayMat.prototype..clearBoard = function()
    {
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
    }

    /* Inputs */

PlayMat.prototype..playCell     = function(colIndex)
    {
        if(colIndex>=NUMBER_OF_PLAYABLE_COLUMNS) alert("Column "+colIndex+" too high");
        var theColumn = this._columns[colIndex];

        switch(type)
        {
            case "Feature":
                theColumn._MAMP = true;
                break;
            case "Detector":
                theColumn._PRR = true;
                break;
            case "Effector":
                if(arguments.length<3) alert("Effector variant not specified");
                theColumn._Effectors[arguments[2]] = true;
                break;
            case "Alarm":
                if(arguments.length<3) alert("Alarm variant not specified");
                theColumn._RProteins[arguments[2]] = true;
                break;
            default:
                alert("Unknown cell type: "+type);
        }
    }

    /* Board state queries */

PlayMat.prototype..isCellActive(type, colIndex)
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
    }

    /* Interaction state queries */

PlayMat.prototype..isPlantETIActive = function()
    {
        function columnActive(aColumn)
        {
            return ((aColumn._Effectors[0] && aColumn._RProteins[0])
                ||  (aColumn._Effectors[1] && aColumn._RProteins[1]));
        }
        return this._columns.some(columnActive);
    }

PlayMat.prototype..isPlantMTIActive = function()
    {
        function columnActive(aColumn)
        {
            var disabled = aColumn._Effectors[0] || aColumn._Effectors[1];
            var triggered = aColumn._MAMP && aColumn._PRR;
            return triggered && !disabled;
        }
        return this._columns.filter(columnActive).length >= MAMP_MATCHES_TO_TRIGGER_MTI;
    }

PlayMat.prototype..isPathogenVirulent = function()
    {
        return !(this.isPlantETIActive() || this.isPlantMTIActive());
    }

