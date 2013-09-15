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
  var PlayMatSolitaireController,
    __slice = [].slice;

  PlayMatSolitaireController = (function() {
    function PlayMatSolitaireController() {
      this.theModel = new PlayMat();
      this.boardState = "Uninitialized";
      this.iteration = 0;
      this.sequentialLosses = 0;
      this.currentPlayer = "Uninitialized";
      this.resultLog = {
        ETI: 0,
        MTI: 0,
        Virulence: 0
      };
      this.distribution = {
        features: 4,
        detectors: 4,
        effectors: 4,
        alarms: 4
      };
      this.pressurePoints = {
        plant: 20,
        pathogen: 20
      };
      this.victoryPoints = {
        plant: 0,
        pathogen: 0
      };
      this.selectedElement = {
        element: null,
        type: -1,
        colIndex: -1,
        variety: -1
      };
      this.goButtons = {
        plant: null,
        pathogen: null
      };
      this.actionChoices = {
        plant: null,
        pathogen: null
      };
      this.pressureBoxen = {
        plant: null,
        pathogen: null
      };
      this.victoryBoxen = {
        plant: null,
        pathogen: null
      };
    }

    PlayMatSolitaireController.prototype.changePressure = function(side, amount) {
      return this.pressurePoints[side] += amount;
    };

    PlayMatSolitaireController.prototype.getElement = function(type, colIndex) {
      var element, selector;
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
      element = $(selector);
      return element;
    };

    PlayMatSolitaireController.prototype.connectElement = function() {
      var colIndex, self, theFeature, theVariant, type;
      type = arguments[0], colIndex = arguments[1], theVariant = 3 <= arguments.length ? __slice.call(arguments, 2) : [];
      self = this;
      theFeature = self.getElement.apply(self, [type, colIndex].concat(__slice.call(theVariant)));
      theFeature.click(function() {
        return self.doSelect.apply(self, [theFeature, type, colIndex].concat(__slice.call(theVariant)));
      });
      return theFeature.css("border-style", "dashed");
    };

    PlayMatSolitaireController.prototype.setElementActivity = function(active, theElement) {
      theElement.css("border-style", active ? "solid" : "dashed");
      theElement.css("border-width", active ? "2px" : "1px");
      theElement.css("-webkit-animation", active ? "select 1s" : "deselect 1s");
      theElement.css("-webkit-transform", active ? "rotateX(0deg)" : "rotateX(180deg)");
      theElement.css("opacity", active ? "1" : "0.25");
      return theElement.css("text-shadow", "0 0 0em #87F");
    };

    PlayMatSolitaireController.prototype.updateBoardState = function() {
      return this.boardState = (function() {
        switch (false) {
          case !this.theModel.isPlantETIActive():
            return RESULT_ETI;
          case !this.theModel.isPlantMTIActive():
            return RESULT_PTI;
          default:
            return RESULT_VIR;
        }
      }).call(this);
    };

    PlayMatSolitaireController.prototype.updateGoButton = function(whoseSide) {
      var actionType, cost, elementType, hasSelection, requiresSelection;
      this.goButtons[whoseSide].removeAttr("disabled");
      actionType = this.actionChoices[whoseSide].val();
      requiresSelection = actionType === ACTION_DISCARD || actionType === ACTION_REPLACE;
      hasSelection = this.selectedElement["element"] !== null;
      if (requiresSelection && !hasSelection) {
        this.goButtons[whoseSide].html("Selection Required");
        this.goButtons[whoseSide].attr("disabled", "disabled");
        this.goButtons[whoseSide].css("background", "red");
        return;
      }
      switch (actionType) {
        case ACTION_DRAW:
          elementType = this.selectedElement["type"];
          break;
        case ACTION_DISCARD:
          elementType = this.selectedElement["type"];
          break;
        case ACTION_REPLACE:
          elementType = this.selectedElement["type"];
          break;
        case ACTION_DRAW_A:
          actionType = ACTION_DRAW;
          elementType = TYPE_ALARM;
          break;
        case ACTION_DRAW_D:
          actionType = ACTION_DRAW;
          elementType = TYPE_DETECTOR;
          break;
        case ACTION_DRAW_E:
          actionType = ACTION_DRAW;
          elementType = TYPE_EFFECTOR;
          break;
        case ACTION_DRAW_F:
          actionType = ACTION_DRAW;
          elementType = TYPE_FEATURE;
          break;
        case ACTION_RANDOM:
          null;
          break;
        default:
          this.goButtons[whoseSide].html("Action Required");
          this.goButtons[whoseSide].attr("disabled", "disabled");
          this.goButtons[whoseSide].css("background", "grey");
          return;
      }
      cost = this.costForAction(actionType, elementType);
      if (cost < 0) {
        this.goButtons[whoseSide].attr("disabled", "disabled");
        this.goButtons[whoseSide].html("Disallowed");
        this.goButtons[whoseSide].css("background", "orange");
        return;
      }
      if (cost > this.pressurePoints[whoseSide]) {
        this.goButtons[whoseSide].html("Need " + cost + "pp");
        this.goButtons[whoseSide].css("background", "yellow");
        return;
      }
      this.goButtons[whoseSide].html("Go (Spend: " + cost + "pp)");
      return this.goButtons[whoseSide].css("background", "green");
    };

    PlayMatSolitaireController.prototype.moveToNextTurn = function() {
      var etiWins, firstPhaseFilter, loser, lostAgain, message, ppLine, pressureForLoser, ptiWins, rewards, victoryForWinner, virWins, vpLine, winline, winner;
      this.updateBoardState();
      firstPhaseFilter = this.iteration === 0 ? 0 : 1;
      message = "ERROR: Message not instantiated";
      rewards = this.rewardsForRound();
      this.resultLog[this.boardState] += 1;
      switch (this.boardState) {
        case RESULT_ETI:
          winner = SIDE_PLANT;
          loser = SIDE_PATHOGEN;
          pressureForLoser = 25;
          victoryForWinner = rewards[SIDE_PLANT];
          break;
        case RESULT_PTI:
          winner = SIDE_PLANT;
          loser = SIDE_PATHOGEN;
          pressureForLoser = 15;
          victoryForWinner = rewards[SIDE_PLANT];
          break;
        default:
          winner = SIDE_PATHOGEN;
          loser = SIDE_PLANT;
          pressureForLoser = 15;
          victoryForWinner = rewards[SIDE_PATHOGEN];
      }
      lostAgain = this.currentPlayer === loser;
      if (lostAgain) {
        this.sequentialLosses += 1;
      } else {
        this.currentPlayer = loser;
        this.sequentialLosses = 0;
      }
      if (lostAgain) {
        winline = "" + winner + " wins again (round " + this.iteration + " ," + this.boardState + ")";
      } else {
        winline = "" + winner + " wins round " + this.iteration + " (" + this.boardState + ")";
      }
      vpLine = "" + winner + ": +" + victoryForWinner + "vp";
      ppLine = "" + loser + ": +" + pressureForLoser + "pp";
      if (lostAgain) {
        ppLine += " (+" + this.sequentialLosses + "pp for repeat loss)";
        pressureForLoser += this.sequentialLosses;
      }
      message = winline + "\n" + vpLine + "\n" + ppLine;
      if (victoryForWinner < 0) {
        message += "\nWARNING: Unsustainably costly win!";
      }
      if (firstPhaseFilter !== 0) {
        alert(message);
      }
      this.changePressure(loser, pressureForLoser * firstPhaseFilter);
      this.victoryPoints[winner] += victoryForWinner * firstPhaseFilter;
      this.actionChoices[winner].hide();
      this.actionChoices[loser].show();
      this.goButtons[winner].hide();
      this.goButtons[loser].show();
      etiWins = this.resultLog[RESULT_ETI] + " " + RESULT_ETI;
      ptiWins = this.resultLog[RESULT_PTI] + " " + RESULT_PTI;
      virWins = this.resultLog[RESULT_VIR] + " " + RESULT_VIR;
      this.victoryBoxen[SIDE_PLANT].html("Victory: " + this.victoryPoints[SIDE_PLANT] + " (" + etiWins + ", " + ptiWins + ")");
      this.victoryBoxen[SIDE_PATHOGEN].html("Victory: " + this.victoryPoints[SIDE_PATHOGEN] + " (" + virWins + ")");
      this.pressureBoxen[SIDE_PLANT].html("Pressure: " + this.pressurePoints[SIDE_PLANT]);
      this.pressureBoxen[SIDE_PATHOGEN].html("Pressure: " + this.pressurePoints[SIDE_PATHOGEN]);
      document.title = "State: " + this.boardState + " | Turn: " + this.currentPlayer;
      return this.iteration += 1;
    };

    PlayMatSolitaireController.prototype.doDiscard = function() {
      var colIndex, oldValue, self, theElement, theVariety, type, _ref;
      theElement = arguments[0], type = arguments[1], colIndex = arguments[2], theVariety = 4 <= arguments.length ? __slice.call(arguments, 3) : [];
      self = this;
      oldValue = (_ref = this.theModel).isCellActive.apply(_ref, [type, colIndex].concat(__slice.call(theVariety)));
      if (oldValue !== true) {
        return false;
      } else {
        if (theElement == null) {
          theElement = self.getElement.apply(self, [type, colIndex].concat(__slice.call(theVariety)));
        }
        this.doSet.apply(this, [theElement, false, type, colIndex].concat(__slice.call(theVariety)));
        switch (type) {
          case TYPE_FEATURE:
            this.distribution["features"] -= 1;
            break;
          case TYPE_DETECTOR:
            this.distribution["detectors"] -= 1;
            break;
          case TYPE_ALARM:
            this.distribution["alarms"] -= 1;
            break;
          case TYPE_EFFECTOR:
            this.distribution["effectors"] -= 1;
        }
        self.setElementActivity(false, theElement);
        return true;
      }
    };

    PlayMatSolitaireController.prototype.doDiscardSelected = function() {
      return this.doDiscard(this.selectedElement["element"], this.selectedElement["type"], this.selectedElement["colIndex"], this.selectedElement["variety"]);
    };

    PlayMatSolitaireController.prototype.getRandomInactiveElementOfType = function(type) {
      var colIndex, notLooped, occupied, startCol, startVar, variety;
      startCol = Math.floor(Math.random() * NUMBER_OF_PLAYABLE_COLUMNS);
      startVar = Math.floor(Math.random() * 2);
      colIndex = startCol;
      variety = startVar;
      occupied = true;
      notLooped = true;
      while (occupied && notLooped) {
        occupied = this.theModel.isCellActive(type, colIndex, variety);
        if (occupied) {
          variety += 1;
          if (variety >= 2) {
            variety = 0;
            colIndex += 1;
            if (colIndex >= NUMBER_OF_PLAYABLE_COLUMNS) {
              colIndex = 0;
            }
          }
        }
        notLooped = colIndex !== startCol || variety !== startVar;
      }
      if (occupied) {
        alert("Could not find unoccupied cell");
        this.clearCurrentSelection();
        return null;
      } else {
        return {
          element: this.getElement(type, colIndex, variety),
          type: type,
          colIndex: colIndex,
          variety: variety
        };
      }
    };

    PlayMatSolitaireController.prototype.selectRandomInactiveElementOfType = function(type) {
      var choice;
      this.clearCurrentSelection();
      choice = this.getRandomInactiveElementOfType(type);
      this.selectedElement["element"] = choice["element"];
      this.selectedElement["type"] = choice["type"];
      this.selectedElement["colIndex"] = choice["colIndex"];
      return this.selectedElement["variety"] = choice["variety"];
    };

    PlayMatSolitaireController.prototype.doDraw = function(type) {
      var anElement;
      anElement = this.getRandomInactiveElementOfType(type);
      if (anElement === null) {
        return;
      }
      return this.doSet(anElement["element"], true, type, anElement["colIndex"], anElement["variety"]);
    };

    PlayMatSolitaireController.prototype.isTypeOnSideOf = function(type, side) {
      switch (type) {
        case TYPE_ALARM:
          return side === SIDE_PLANT;
        case TYPE_DETECTOR:
          return side === SIDE_PLANT;
        case TYPE_EFFECTOR:
          return side === SIDE_PATHOGEN;
        case TYPE_FEATURE:
          return side === SIDE_PATHOGEN;
        default:
          return false;
      }
    };

    PlayMatSolitaireController.prototype.clearCurrentSelection = function() {
      var oldState;
      if (this.selectedElement["element"] !== null) {
        oldState = this.theModel.isCellActive(this.selectedElement["type"], this.selectedElement["colIndex"], this.selectedElement["variety"]);
        this.setElementActivity(oldState, this.selectedElement["element"]);
      }
      this.selectedElement["element"] = null;
      this.selectedElement["type"] = -1;
      this.selectedElement["colIndex"] = -1;
      this.selectedElement["variety"] = -1;
      return this.updateGoButton(this.currentPlayer);
    };

    PlayMatSolitaireController.prototype.doSelect = function() {
      var colIndex, selectionState, theElement, theVariety, type, _ref;
      theElement = arguments[0], type = arguments[1], colIndex = arguments[2], theVariety = 4 <= arguments.length ? __slice.call(arguments, 3) : [];
      this.clearCurrentSelection();
      if (!this.isTypeOnSideOf(type, this.currentPlayer)) {
        return;
      }
      selectionState = (_ref = this.theModel).isCellActive.apply(_ref, [type, colIndex].concat(__slice.call(theVariety)));
      if (selectionState) {
        theElement.css("border-style", "dotted");
        theElement.css("border-width", "3px");
        theElement.css("text-shadow", "0 0 0.2em #FFF, 0 0 0.3em #FFF, 0 0 0.4em #FFF");
        theElement.css("opacity", "1");
        this.selectedElement["element"] = theElement;
        this.selectedElement["type"] = type;
        this.selectedElement["colIndex"] = colIndex;
        this.selectedElement["variety"] = theVariety.length > 0 ? theVariety[0] : -1;
        return this.updateGoButton(this.currentPlayer);
      }
    };

    PlayMatSolitaireController.prototype.doSet = function() {
      var colIndex, newValue, oldValue, self, theElement, theVariety, type, _ref, _ref1;
      theElement = arguments[0], newValue = arguments[1], type = arguments[2], colIndex = arguments[3], theVariety = 5 <= arguments.length ? __slice.call(arguments, 4) : [];
      console.log("doSet " + type + colIndex + ":" + theElement + " to " + newValue);
      self = this;
      oldValue = (_ref = this.theModel).isCellActive.apply(_ref, [type, colIndex].concat(__slice.call(theVariety)));
      if (theElement == null) {
        theElement = self.getElement.apply(self, [type, colIndex].concat(__slice.call(theVariety)));
      }
      (_ref1 = this.theModel).setCell.apply(_ref1, [newValue, type, colIndex].concat(__slice.call(theVariety)));
      self.updateBoardState();
      self.setElementActivity(newValue, theElement);
      this.updateInteractions.apply(this, [theElement, newValue, type, colIndex].concat(__slice.call(theVariety)));
      return newValue;
    };

    PlayMatSolitaireController.prototype.updateInteractions = function() {
      var aVariety, active, busted, colIndex, theElement, theVariety, triggerElement, triggerState, triggerType, type, _i, _len, _ref, _ref1, _ref2;
      theElement = arguments[0], active = arguments[1], type = arguments[2], colIndex = arguments[3], theVariety = 5 <= arguments.length ? __slice.call(arguments, 4) : [];
      console.log("Updating interactions for " + theElement);
      switch (type) {
        case TYPE_FEATURE:
          triggerType = TYPE_DETECTOR;
          triggerElement = this.getElement(triggerType, colIndex);
          triggerState = (this.theModel.isCellActive(triggerType, colIndex)) && !(this.theModel.isDetectorDisabled(colIndex));
          if (active && triggerState) {
            theElement.addClass("detected");
            return triggerElement.addClass("detecting");
          } else {
            theElement.removeClass("detected");
            return triggerElement.removeClass("detecting");
          }
          break;
        case TYPE_DETECTOR:
          triggerType = TYPE_EFFECTOR;
          busted = false;
          _ref = [0, 1];
          for (_i = 0, _len = _ref.length; _i < _len; _i++) {
            aVariety = _ref[_i];
            triggerElement = this.getElement(triggerType, colIndex, aVariety);
            triggerState = this.theModel.isCellActive(triggerType, colIndex, aVariety);
            if (active && triggerState) {
              theElement.addClass("disabled" + aVariety);
              triggerElement.addClass("disabling");
              busted = true;
            } else {
              theElement.removeClass("disabled" + aVariety);
              triggerElement.removeClass("disabling");
            }
          }
          if (busted) {
            active = false;
          }
          triggerType = TYPE_FEATURE;
          triggerElement = this.getElement(triggerType, colIndex);
          triggerState = this.theModel.isCellActive(triggerType, colIndex);
          if (active && triggerState) {
            triggerElement.addClass("detected");
            return theElement.addClass("detecting");
          } else {
            triggerElement.removeClass("detected");
            return theElement.removeClass("detecting");
          }
          break;
        case TYPE_EFFECTOR:
          triggerType = TYPE_DETECTOR;
          triggerElement = this.getElement(triggerType, colIndex);
          triggerState = this.theModel.isCellActive(triggerType, colIndex);
          this.updateInteractions(triggerElement, triggerState, triggerType, colIndex);
          triggerType = TYPE_ALARM;
          triggerElement = this.getElement.apply(this, [triggerType, colIndex].concat(__slice.call(theVariety)));
          triggerState = (_ref1 = this.theModel).isCellActive.apply(_ref1, [triggerType, colIndex].concat(__slice.call(theVariety)));
          if (active && triggerState) {
            theElement.addClass("alarming");
            return triggerElement.addClass("alarmed");
          } else {
            theElement.removeClass("alarming");
            return triggerElement.removeClass("alarmed");
          }
          break;
        case TYPE_ALARM:
          triggerType = TYPE_EFFECTOR;
          triggerElement = this.getElement.apply(this, [triggerType, colIndex].concat(__slice.call(theVariety)));
          triggerState = (_ref2 = this.theModel).isCellActive.apply(_ref2, [triggerType, colIndex].concat(__slice.call(theVariety)));
          if (active && triggerState) {
            triggerElement.addClass("alarming");
            return theElement.addClass("alarmed");
          } else {
            triggerElement.removeClass("alarming");
            return theElement.removeClass("alarmed");
          }
      }
    };

    PlayMatSolitaireController.prototype.randomSelectionArray = function(picks, total) {
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

    PlayMatSolitaireController.prototype.doRandomize = function() {
      var i, randList, randVal, self, _i, _j, _k, _l, _len, _len1, _len2, _len3, _results;
      self = this;
      randList = self.randomSelectionArray(this.distribution["features"], NUMBER_OF_FEATURES);
      for (i = _i = 0, _len = randList.length; _i < _len; i = ++_i) {
        randVal = randList[i];
        self.doSet(null, randVal, TYPE_FEATURE, i);
      }
      randList = self.randomSelectionArray(this.distribution["detectors"], NUMBER_OF_DETECTORS);
      for (i = _j = 0, _len1 = randList.length; _j < _len1; i = ++_j) {
        randVal = randList[i];
        self.doSet(null, randVal, TYPE_DETECTOR, i);
      }
      randList = self.randomSelectionArray(this.distribution["effectors"], NUMBER_OF_EFFECTORS);
      for (i = _k = 0, _len2 = randList.length; _k < _len2; i = ++_k) {
        randVal = randList[i];
        self.doSet(null, randVal, TYPE_EFFECTOR, i >> 1, i % 2);
      }
      randList = self.randomSelectionArray(this.distribution["alarms"], NUMBER_OF_ALARMS);
      _results = [];
      for (i = _l = 0, _len3 = randList.length; _l < _len3; i = ++_l) {
        randVal = randList[i];
        _results.push(self.doSet(null, randVal, TYPE_ALARM, i >> 1, i % 2));
      }
      return _results;
    };

    PlayMatSolitaireController.prototype.rewardsForRound = function() {
      var existingAlarms, existingDetectors, existingEffectors, existingFeatures, pathoExpenses, pathoRewards, plantExpenses, plantRewards;
      existingAlarms = this.theModel.countActiveCellsOfType(TYPE_ALARM);
      existingDetectors = this.theModel.countActiveCellsOfType(TYPE_DETECTOR);
      existingFeatures = this.theModel.countActiveCellsOfType(TYPE_FEATURE);
      existingEffectors = this.theModel.countActiveCellsOfType(TYPE_EFFECTOR);
      plantRewards = 12;
      plantExpenses = 2 * existingDetectors;
      pathoRewards = 2 * (existingFeatures - 2);
      pathoExpenses = 0;
      return {
        plant: plantRewards - plantExpenses,
        pathogen: pathoRewards - pathoExpenses
      };
    };

    PlayMatSolitaireController.prototype.costForAction = function(actionType, elementType) {
      var availablePoints, cost, detectionCostLimiter, discardCost, drawCost, excessDetectionTools, existingAlarms, existingDetectors, existingEffectors, existingFeatures, replaceCost, roomForEffectors;
      detectionCostLimiter = 8;
      existingAlarms = this.theModel.countActiveCellsOfType(TYPE_ALARM);
      existingDetectors = this.theModel.countActiveCellsOfType(TYPE_DETECTOR);
      excessDetectionTools = existingAlarms + existingDetectors - detectionCostLimiter;
      existingFeatures = this.theModel.countActiveCellsOfType(TYPE_FEATURE);
      existingEffectors = this.theModel.countActiveCellsOfType(TYPE_EFFECTOR);
      roomForEffectors = existingEffectors < existingFeatures;
      switch (elementType) {
        case TYPE_ALARM:
          drawCost = 10;
          discardCost = 10;
          replaceCost = 15;
          if (excessDetectionTools > 0) {
            drawCost += excessDetectionTools;
          }
          break;
        case TYPE_DETECTOR:
          drawCost = 20;
          discardCost = 10;
          replaceCost = 25;
          if (excessDetectionTools > 0) {
            drawCost += excessDetectionTools;
          }
          break;
        case TYPE_FEATURE:
          drawCost = 20;
          discardCost = roomForEffectors ? 10 : 20;
          replaceCost = 15;
          if (existingFeatures <= 2) {
            discardCost = -1;
          }
          break;
        case TYPE_EFFECTOR:
          drawCost = roomForEffectors ? 10 : 20;
          discardCost = 10;
          replaceCost = 15;
      }
      availablePoints = this.pressurePoints[this.currentPlayer];
      cost = (function() {
        switch (actionType) {
          case ACTION_DISCARD:
            return discardCost;
          case ACTION_REPLACE:
            return replaceCost;
          case ACTION_DRAW:
            return drawCost;
          case ACTION_RANDOM:
            if (availablePoints < 5) {
              return availablePoints;
            } else {
              return 5;
            }
          default:
            return 0;
        }
      })();
      if (cost < 0) {
        cost = 0;
      }
      return cost;
    };

    PlayMatSolitaireController.prototype.processAction = function(whichSide) {
      var action, cost, type;
      action = this.actionChoices[whichSide].val();
      type = this.selectedElement["type"];
      switch (action) {
        case ACTION_DRAW_A:
          type = TYPE_ALARM;
          action = ACTION_DRAW;
          break;
        case ACTION_DRAW_E:
          type = TYPE_EFFECTOR;
          action = ACTION_DRAW;
          break;
        case ACTION_DRAW_F:
          type = TYPE_FEATURE;
          action = ACTION_DRAW;
          break;
        case ACTION_DRAW_D:
          type = TYPE_DETECTOR;
          action = ACTION_DRAW;
          break;
        case ACTION_RANDOM:
          type = (function() {
            switch (whichSide) {
              case SIDE_PLANT:
                if (Math.random() < 0.5) {
                  return TYPE_DETECTOR;
                } else {
                  return TYPE_ALARM;
                }
              case SIDE_PATHOGEN:
                if (Math.random() < 0.5) {
                  return TYPE_FEATURE;
                } else {
                  return TYPE_EFFECTOR;
                }
            }
          })();
      }
      switch (action) {
        case ACTION_DISCARD:
          this.doDiscardSelected();
          break;
        case ACTION_DRAW:
          this.doDraw(type);
          break;
        case ACTION_REPLACE:
          this.doDraw(type);
          this.doDiscardSelected();
          break;
        case ACTION_RANDOM:
          this.doDraw(type);
          this.selectRandomInactiveElementOfType(type);
          this.doDiscardSelected();
      }
      cost = this.costForAction(action, type);
      this.changePressure(whichSide, -cost);
      this.clearCurrentSelection();
      return this.moveToNextTurn();
    };

    return PlayMatSolitaireController;

  })();

  $(document).ready(function() {
    var control, i, _i;
    window.boardState = "Ready for input";
    window.controller = new PlayMatSolitaireController();
    control = window.controller;
    for (i = _i = 0; 0 <= NUMBER_OF_PLAYABLE_COLUMNS ? _i < NUMBER_OF_PLAYABLE_COLUMNS : _i > NUMBER_OF_PLAYABLE_COLUMNS; i = 0 <= NUMBER_OF_PLAYABLE_COLUMNS ? ++_i : --_i) {
      control.connectElement(TYPE_FEATURE, i);
      control.connectElement(TYPE_DETECTOR, i);
      control.connectElement(TYPE_EFFECTOR, i, 0);
      control.connectElement(TYPE_EFFECTOR, i, 1);
      control.connectElement(TYPE_ALARM, i, 0);
      control.connectElement(TYPE_ALARM, i, 1);
    }
    control.goButtons[SIDE_PLANT] = $("#" + ID_PLANT_ENGAGE);
    control.actionChoices[SIDE_PLANT] = $("#" + ID_PLANT_ACTIONS);
    control.goButtons[SIDE_PATHOGEN] = $("#" + ID_PATHO_ENGAGE);
    control.actionChoices[SIDE_PATHOGEN] = $("#" + ID_PATHO_ACTIONS);
    control.pressureBoxen[SIDE_PLANT] = $("#" + ID_PLANT_PRESSURE);
    control.victoryBoxen[SIDE_PLANT] = $("#" + ID_PLANT_VICTORY);
    control.pressureBoxen[SIDE_PATHOGEN] = $("#" + ID_PATHO_PRESSURE);
    control.victoryBoxen[SIDE_PATHOGEN] = $("#" + ID_PATHO_VICTORY);
    control.goButtons[SIDE_PLANT].click(function() {
      return control.processAction(SIDE_PLANT);
    });
    control.goButtons[SIDE_PATHOGEN].click(function() {
      return control.processAction(SIDE_PATHOGEN);
    });
    control.actionChoices[SIDE_PATHOGEN].change(function() {
      return control.updateGoButton(SIDE_PATHOGEN);
    });
    control.actionChoices[SIDE_PLANT].change(function() {
      return control.updateGoButton(SIDE_PLANT);
    });
    control.doRandomize();
    control.moveToNextTurn();
    control.updateGoButton(SIDE_PLANT);
    return control.updateGoButton(SIDE_PATHOGEN);
  });

}).call(this);
