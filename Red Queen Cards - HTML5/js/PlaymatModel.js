/**
 * Created with JetBrains WebStorm.
 * User: badams
 * Date: 5/31/13
 * Time: 9:34 PM
 * To change this template use File | Settings | File Templates.
 */
//Require InteractionColumn

var MAMP_MATCHES_TO_TRIGGER_MTI = 2;


function PlayMat()
{
    this._columns = [];
    for(var i=0; i<8; i+=1)
    {
        this._columns[i] = {
            _MAMP: false,
            _PRR: false,
            _Effectors: [false, false],
            _RProteins: [false, false]
        }
    }

    this.playFeature  = function(colIndex)          { this._columns[colIndex]._MAMP=true; }
    this.playDetector = function(colIndex)          { this._columns[colIndex]._PRR=true; }
    this.playEffector = function(colIndex, variant) { this._columns[colIndex]._Effectors[variant]=true; }
    this.playAlarm    = function(colIndex, variant) { this._columns[colIndex]._RProteins[variant]=true; }

    this.isPlantETIActive = function()
    {
        function columnActive(aColumn)
        {
            return ((aColumn._Effectors[0] && aColumn._RProteins[0])
                ||  (aColumn._Effectors[1] && aColumn._RProteins[1]));
        }
        return this._columns.some(columnActive);
    }

    this.isPlantMTIActive = function()
    {
        function columnActive(aColumn)
        {
            var disabled = aColumn._Effectors[0] || aColumn._Effectors[1];
            var triggered = aColumn._MAMP && aColumn._PRR;
            return triggered && !disabled;
        }
        return this._columns.filter(columnActive).length >= MAMP_MATCHES_TO_TRIGGER_MTI;
    }

    this.isPathogenVirulent = function()
    {
        return !(this.isPlantETIActive() || this.isPlantMTIActive());
    }
}
