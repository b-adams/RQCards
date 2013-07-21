// Generated by CoffeeScript 1.6.3
/*
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
*/


(function() {
  var PlayMatController,
    __slice = [].slice;

  PlayMatController = (function() {
    function PlayMatController() {
      this.theModel = new PlayMat();
      this.boardState = "Uninitialized";
      this.currentLevel = 0;
      this.attempts = [
        "Level results", {
          correct: 0,
          incorrect: 0
        }, {
          correct: 0,
          incorrect: 0
        }, {
          correct: 0,
          incorrect: 0
        }
      ];
    }

    PlayMatController.prototype.getElement = function(type, colIndex) {
      var selector;
      selector = "#board > #c" + (colIndex + 1) + " > .";
      switch (type) {
        case TYPE_FEATURE:
          selector += "feature";
          break;
        case TYPE_DETECTOR:
          selector += "detector";
          break;
        case TYPE_EFFECTOR:
          selector += "e" + (arguments[2] + 1);
          break;
        case TYPE_ALARM:
          selector += "a" + (arguments[2] + 1);
          break;
        default:
          alert("Bad element request");
          selector = "";
      }
      return $(selector);
    };

    PlayMatController.prototype.connectElement = function() {
      var colIndex, self, theFeature, theVariant, type;
      type = arguments[0], colIndex = arguments[1], theVariant = 3 <= arguments.length ? __slice.call(arguments, 2) : [];
      self = this;
      theFeature = self.getElement.apply(self, [type, colIndex].concat(__slice.call(theVariant)));
      theFeature.click(function() {
        return self.doPlay.apply(self, [theFeature, type, colIndex].concat(__slice.call(theVariant)));
      });
      return theFeature.css("border-style", "dashed");
    };

    PlayMatController.prototype.setElementActivity = function(active, theElement) {
      theElement.css("border-style", active ? "solid" : "dashed");
      theElement.css("border-width", active ? "2px" : "1px");
      theElement.css("-webkit-animation", active ? "select 1s" : "deselect 1s");
      theElement.css("-webkit-transform", active ? "rotateX(0deg)" : "rotateX(180deg)");
      return theElement.css("opacity", active ? "1" : "0.25");
    };

    PlayMatController.prototype.updateBoardState = function() {
      this.boardState = (function() {
        switch (false) {
          case !this.theModel.isPlantETIActive():
            return "ETI";
          case !this.theModel.isPlantMTIActive():
            return "MTI";
          default:
            return "Virulence";
        }
      }).call(this);
      console.log("Board: " + this.boardState);
      return window.document.title = "Current state: " + this.boardState;
    };

    PlayMatController.prototype.doSet = function() {
      var colIndex, newValue, oldValue, self, theElement, theVariety, type, _ref, _ref1;
      theElement = arguments[0], newValue = arguments[1], type = arguments[2], colIndex = arguments[3], theVariety = 5 <= arguments.length ? __slice.call(arguments, 4) : [];
      self = this;
      oldValue = (_ref = this.theModel).isCellActive.apply(_ref, [type, colIndex].concat(__slice.call(theVariety)));
      if (oldValue !== newValue) {
        if (theElement == null) {
          theElement = self.getElement.apply(self, [type, colIndex].concat(__slice.call(theVariety)));
        }
        (_ref1 = this.theModel).setCell.apply(_ref1, [newValue, type, colIndex].concat(__slice.call(theVariety)));
        self.updateBoardState();
        self.setElementActivity(newValue, theElement);
      }
      return newValue;
    };

    PlayMatController.prototype.doPlay = function() {
      var active, colIndex, self, theElement, theVariety, type, _ref;
      theElement = arguments[0], type = arguments[1], colIndex = arguments[2], theVariety = 4 <= arguments.length ? __slice.call(arguments, 3) : [];
      self = this;
      if (theElement == null) {
        theElement = self.getElement.apply(self, [type, colIndex].concat(__slice.call(theVariety)));
      }
      active = (_ref = this.theModel).toggleCell.apply(_ref, [type, colIndex].concat(__slice.call(theVariety)));
      self.updateBoardState();
      self.setElementActivity(active, theElement);
      return active;
    };

    PlayMatController.prototype.randomSelectionArray = function(picks, total) {
      var i, n, picklist, randIndex, _i, _ref;
      picklist = ((function() {
        var _i, _results;
        _results = [];
        for (n = _i = 0; 0 <= picks ? _i < picks : _i > picks; n = 0 <= picks ? ++_i : --_i) {
          _results.push(true);
        }
        return _results;
      })()).concat((function() {
        var _i, _results;
        _results = [];
        for (n = _i = picks; picks <= total ? _i < total : _i > total; n = picks <= total ? ++_i : --_i) {
          _results.push(false);
        }
        return _results;
      })());
      for (i = _i = 0; 0 <= total ? _i < total : _i > total; i = 0 <= total ? ++_i : --_i) {
        randIndex = Math.floor(i + (Math.random() * (total - i)));
        _ref = [picklist[randIndex], picklist[i]], picklist[i] = _ref[0], picklist[randIndex] = _ref[1];
      }
      return picklist;
    };

    PlayMatController.prototype.doRandomize = function(features, detectors, effectors, alarms) {
      var i, randList, randVal, self, _i, _j, _k, _l, _len, _len1, _len2, _len3;
      if (features == null) {
        features = 4;
      }
      if (detectors == null) {
        detectors = 4;
      }
      if (effectors == null) {
        effectors = 4;
      }
      if (alarms == null) {
        alarms = 4;
      }
      self = this;
      console.log("RANDOMIZING----------------------------------");
      randList = self.randomSelectionArray(features, NUMBER_OF_FEATURES);
      for (i = _i = 0, _len = randList.length; _i < _len; i = ++_i) {
        randVal = randList[i];
        self.doSet(null, randVal, TYPE_FEATURE, i);
      }
      randList = self.randomSelectionArray(detectors, NUMBER_OF_DETECTORS);
      for (i = _j = 0, _len1 = randList.length; _j < _len1; i = ++_j) {
        randVal = randList[i];
        self.doSet(null, randVal, TYPE_DETECTOR, i);
      }
      randList = self.randomSelectionArray(effectors, NUMBER_OF_EFFECTORS);
      for (i = _k = 0, _len2 = randList.length; _k < _len2; i = ++_k) {
        randVal = randList[i];
        self.doSet(null, randVal, TYPE_EFFECTOR, i >> 1, i % 2);
      }
      randList = self.randomSelectionArray(alarms, NUMBER_OF_ALARMS);
      for (i = _l = 0, _len3 = randList.length; _l < _len3; i = ++_l) {
        randVal = randList[i];
        self.doSet(null, randVal, TYPE_ALARM, i >> 1, i % 2);
      }
      return console.log("RANDOMIZED-----------------------------------");
    };

    PlayMatController.prototype.wrongSelectionInfoPopup = function(suppliedAnswer, correctAnswer) {
      var diagnosis, hint, note;
      if (suppliedAnswer === correctAnswer) {
        return;
      }
      if (suppliedAnswer == null) {
        return;
      }
      diagnosis = "Incorrect.\nYou selected " + suppliedAnswer;
      switch (suppliedAnswer) {
        case "ETI":
          note = " but there are no effector-alarm matches.";
          switch (correctAnswer) {
            case "MTI":
              hint = note + "\nLook at the feature-detector row.";
              break;
            case "Virulence":
              hint = note + "\nWere you looking at detector-effector disablements?";
              break;
            default:
              "ERROR: How is " + correctAnswer + " possible?";
          }
          break;
        case "MTI":
          switch (correctAnswer) {
            case "ETI":
              hint = ".\nKeep in mind that effector-alarm matches trump feature-detector ones.";
              break;
            case "Virulence":
              hint = " but there are not enough *non-disabled* feature-detector matches.";
              break;
            default:
              "ERROR: How is " + correctAnswer + " possible?";
          }
          break;
        case "Virulence":
          switch (correctAnswer) {
            case "MTI":
              hint = ".\nCheck again for active feature-detector matches.";
              break;
            case "ETI":
              hint = ".\nCheck again for effector-alarmmatches.";
              break;
            default:
              "ERROR: How is " + correctAnswer + " possible?";
          }
          break;
        default:
          "ERROR: invalid answer";
      }
      return alert(diagnosis + hint);
    };

    PlayMatController.prototype.setupLevel = function(whichLevel) {
      var self;
      self = this;
      switch (whichLevel) {
        case 1:
          self.doRandomize(4, 4, 0, 0);
          break;
        case 2:
          self.doRandomize(4, 4, 4, 0);
          break;
        case 3:
          self.doRandomize(4, 4, 4, 4);
          break;
        default:
          alert("Invalid level " + whichLevel);
          return;
      }
      return this.currentLevel = whichLevel;
    };

    PlayMatController.prototype.updateQuizLabels = function(whichLevel) {
      var quizBox, right, wrong;
      quizBox = $("#Quiz" + whichLevel);
      right = this.attempts[whichLevel]["correct"];
      wrong = this.attempts[whichLevel]["incorrect"];
      quizBox.html("Level " + whichLevel + "<br>Answers: " + (right + wrong) + " Correct: " + right);
    };

    return PlayMatController;

  })();

  $(document).ready(function() {
    var control, i, _i;
    window.boardState = "Ready for input";
    window.controller = new PlayMatController();
    control = window.controller;
    for (i = _i = 0; 0 <= NUMBER_OF_PLAYABLE_COLUMNS ? _i < NUMBER_OF_PLAYABLE_COLUMNS : _i > NUMBER_OF_PLAYABLE_COLUMNS; i = 0 <= NUMBER_OF_PLAYABLE_COLUMNS ? ++_i : --_i) {
      control.connectElement(TYPE_FEATURE, i);
      control.connectElement(TYPE_DETECTOR, i);
      control.connectElement(TYPE_EFFECTOR, i, 0);
      control.connectElement(TYPE_EFFECTOR, i, 1);
      control.connectElement(TYPE_ALARM, i, 0);
      control.connectElement(TYPE_ALARM, i, 1);
    }
    $("#comboBoard").change(function() {
      var answer;
      answer = $(this).val();
      if (answer == null) {
        return;
      }
      if (answer === control.boardState) {
        control.attempts[control.currentLevel]["correct"] += 1;
        control.setupLevel(control.currentLevel);
        $(this).val("");
      } else {
        control.attempts[control.currentLevel]["incorrect"] += 1;
        control.wrongSelectionInfoPopup(answer, control.boardState);
      }
      return control.updateQuizLabels(control.currentLevel);
    });
    $("#ClearBoardButton").click(function() {
      return control.doRandomize(0, 0, 0, 0);
    });
    $("#Quiz1").click(function() {
      return control.setupLevel(1);
    });
    $("#Quiz2").click(function() {
      return control.setupLevel(2);
    });
    $("#Quiz3").click(function() {
      return control.setupLevel(3);
    });
    return $("#Quiz4").click(function() {
      return alert("Not yet implemented");
    });
  });

}).call(this);
