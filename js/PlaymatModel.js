// Generated by CoffeeScript 1.6.3
/*
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


(function() {
  var PlayMat,
    __slice = [].slice;

  window.PlayMat = PlayMat = (function() {
    function PlayMat() {
      this.clearBoard();
      return this;
    }

    PlayMat.prototype.clearBoard = function() {
      var i, _i, _results;
      this.stateOfETI = false;
      this.stateOfMTI = false;
      this._columns = [];
      this._columnActivities = [];
      _results = [];
      for (i = _i = 0; 0 <= NUMBER_OF_PLAYABLE_COLUMNS ? _i < NUMBER_OF_PLAYABLE_COLUMNS : _i > NUMBER_OF_PLAYABLE_COLUMNS; i = 0 <= NUMBER_OF_PLAYABLE_COLUMNS ? ++_i : --_i) {
        this._columns[i] = {
          _MAMP: false,
          _PRR: false,
          _Effectors: [false, false],
          _RProteins: [false, false]
        };
        _results.push(this._columnActivities[i] = {
          _DetectorTriggered: false,
          _DetectorDisabled: false,
          _EffectorsDisabling: [false, false],
          _EffectorsDetected: [false, false]
        });
      }
      return _results;
    };

    PlayMat.prototype.setCell = function(newValue, type, colIndex) {
      var theColumn, variant;
      if (colIndex >= NUMBER_OF_PLAYABLE_COLUMNS) {
        alert("Column " + colIndex + " too high");
      }
      theColumn = this._columns[colIndex];
      switch (type) {
        case TYPE_FEATURE:
          theColumn._MAMP = newValue;
          break;
        case TYPE_DETECTOR:
          theColumn._PRR = newValue;
          break;
        case TYPE_EFFECTOR:
          theColumn._Effectors[arguments[3]] = newValue;
          break;
        case TYPE_ALARM:
          theColumn._RProteins[arguments[3]] = newValue;
          break;
        default:
          alert("Unknown cell type: " + type);
      }
      this.updateActivityInColumn(colIndex);
      this.updateStatesAfterChanging(type);
      variant = arguments.length < 4 ? "" : arguments[3];
      return console.log("Set " + type + variant + " in column " + colIndex + " to " + newValue);
    };

    PlayMat.prototype.toggleCell = function() {
      var colIndex, theColumn, theNewValue, theVariant, type;
      type = arguments[0], colIndex = arguments[1], theVariant = 3 <= arguments.length ? __slice.call(arguments, 2) : [];
      theColumn = this._columns[colIndex];
      switch (type) {
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
        default:
          alert("Unknown cell type: " + type);
      }
      this.setCell.apply(this, [theNewValue, type, colIndex].concat(__slice.call(theVariant)));
      return theNewValue;
    };

    PlayMat.prototype.updateStatesAfterChanging = function(type) {
      switch (type) {
        case TYPE_FEATURE:
          return this.updateMTIState();
        case TYPE_DETECTOR:
          return this.updateMTIState();
        case TYPE_ALARM:
          return this.updateETIState();
        case TYPE_EFFECTOR:
          this.updateMTIState();
          return this.updateETIState();
        default:
          return alert("Unknown cell type: " + type);
      }
    };

    PlayMat.prototype.isCellActive = function() {
      var colIndex, theColumn, theVariant, type;
      type = arguments[0], colIndex = arguments[1], theVariant = 3 <= arguments.length ? __slice.call(arguments, 2) : [];
      if (colIndex >= NUMBER_OF_PLAYABLE_COLUMNS) {
        alert("Too many columns: " + colIndex);
      }
      theColumn = this._columns[colIndex];
      switch (type) {
        case TYPE_FEATURE:
          return theColumn._MAMP;
        case TYPE_DETECTOR:
          return theColumn._PRR;
        case TYPE_EFFECTOR:
          if (arguments.length < 3) {
            alert("Effector variant not specified");
          }
          return theColumn._Effectors[arguments[2]];
        case TYPE_ALARM:
          if (arguments.length < 3) {
            alert("Alarm variant not specified");
          }
          return theColumn._RProteins[arguments[2]];
        default:
          alert("Unknown cell type: " + type);
      }
      return -1;
    };

    PlayMat.prototype.isDetectorDisabled = function(colIndex) {
      var theColumn;
      if (colIndex >= NUMBER_OF_PLAYABLE_COLUMNS) {
        alert("Too many columns: " + colIndex);
      }
      theColumn = this._columns[colIndex];
      return theColumn._Effectors[0] || theColumn._Effectors[1];
    };

    PlayMat.prototype.countActiveCellsOfType = function(type) {
      var actives, theColumn, _i, _j, _k, _l, _len, _len1, _len2, _len3, _ref, _ref1, _ref2, _ref3;
      actives = 0;
      switch (type) {
        case TYPE_FEATURE:
          _ref = this._columns;
          for (_i = 0, _len = _ref.length; _i < _len; _i++) {
            theColumn = _ref[_i];
            if (theColumn._MAMP) {
              actives += 1;
            }
          }
          break;
        case TYPE_DETECTOR:
          _ref1 = this._columns;
          for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
            theColumn = _ref1[_j];
            if (theColumn._PRR) {
              actives += 1;
            }
          }
          break;
        case TYPE_ALARM:
          _ref2 = this._columns;
          for (_k = 0, _len2 = _ref2.length; _k < _len2; _k++) {
            theColumn = _ref2[_k];
            if (theColumn._RProteins[0]) {
              actives += 1;
            }
            if (theColumn._RProteins[1]) {
              actives += 1;
            }
          }
          break;
        case TYPE_EFFECTOR:
          _ref3 = this._columns;
          for (_l = 0, _len3 = _ref3.length; _l < _len3; _l++) {
            theColumn = _ref3[_l];
            if (theColumn._Effectors[0]) {
              actives += 1;
            }
            if (theColumn._Effectors[1]) {
              actives += 1;
            }
          }
          break;
        default:
          alert("Unknown cell type: " + type);
      }
      return actives;
    };

    PlayMat.prototype.isPlantETIActive = function() {
      return this.stateOfETI;
    };

    PlayMat.prototype.isPlantMTIActive = function() {
      return this.stateOfMTI;
    };

    PlayMat.prototype.isPathogenVirulent = function() {
      return !(this.stateOfETI || this.stateOfMTI);
    };

    PlayMat.prototype.updateETIState = function() {
      return this.stateOfETI = this._columnActivities.some(function(actSet) {
        return actSet._EffectorsDetected[0] || actSet._EffectorsDetected[1];
      });
    };

    PlayMat.prototype.updateMTIState = function() {
      return this.stateOfMTI = this._columnActivities.filter(function(actSet) {
        return actSet._DetectorTriggered;
      }).length >= MAMP_MATCHES_TO_TRIGGER_MTI;
    };

    PlayMat.prototype.updateActivityInColumn = function(colIndex) {
      var slot, theColumn, theList, _i;
      theColumn = this._columns[colIndex];
      theList = this._columnActivities[colIndex];
      for (slot = _i = 0; _i <= 1; slot = ++_i) {
        theList._EffectorsDisabling[slot] = theColumn._PRR && theColumn._Effectors[slot];
        theList._EffectorsDetected[slot] = theColumn._Effectors[slot] && theColumn._RProteins[slot];
      }
      theList._DetectorDisabled = theList._EffectorsDisabling[0] || theList._EffectorsDisabling[1];
      return theList._DetectorTriggered = theColumn._MAMP && theColumn._PRR && !theList._DetectorDisabled;
    };

    PlayMat.prototype.triggeredDetectors = function() {
      return this._columnActivities.filter(function(actSet) {
        return actSet._DetectorTriggered;
      });
    };

    PlayMat.prototype.disabledDetectors = function() {
      return this._columnActivities.filter(function(actSet) {
        return actSet._DetectorDisabled;
      });
    };

    PlayMat.prototype.disablingEffectors = function() {
      return this._columnActivities.filter(function(actSet) {
        return actSet._EffectorsDisabling[0] || actSet._EffectorsDisabling[1];
      });
    };

    PlayMat.prototype.triggeredAlarms = function() {
      return this._columnActivities.filter(function(actSet) {
        return actSet._EffectorsDetected[0] || actSet._EffectorsDetected[1];
      });
    };

    return PlayMat;

  })();

}).call(this);
