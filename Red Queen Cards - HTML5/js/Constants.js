/**
 * Created with JetBrains PhpStorm.
 * User: badams
 * Date: 7/7/13
 * Time: 9:37 PM
 * To change this template use File | Settings | File Templates.
 */
var NUMBER_OF_FEATURES = 8;
var NUMBER_OF_DETECTORS = 8;
var NUMBER_OF_EFFECTORS = 16;
var NUMBER_OF_ALARMS = 16;
var EFFECTORS_PER_DETECTOR = 2;

var MAMP_MATCHES_TO_TRIGGER_MTI = 2;
var NUMBER_OF_PLAYABLE_COLUMNS = 8;

var TYPE_FEATURE = "Feature";
var TYPE_DETECTOR = "Detector";
var TYPE_EFFECTOR = "Effector";
var TYPE_ALARM = "Alarm";

var VARIETY_LEFT = 0
var VARIETY_RIGHT = 1
var VARIETY_NONE = -1

var STATE_DISABLED = "disabled"
var STATE_DISABLED_LEFT = STATE_DISABLED+VARIETY_LEFT
var STATE_DISABLED_RIGHT = STATE_DISABLED+VARIETY_RIGHT
var STATE_DISABLING = "disabling"
var STATE_DETECTED = "detected"
var STATE_DETECTING = "detecting"
var STATE_ALARMING = "alarming"
var STATE_ALARMED = "alarmed"
var STATE_ABSENT = "absent"
var STATE_PRESENT = "present"

var RESULT_PTI = "MTI"
var RESULT_ETI = "ETI"
var RESULT_VIR = "Virulence"

var ACTION_DISCARD = "Discard Selected"
var ACTION_REPLACE = "Replace Selected"
var ACTION_DRAW = "Draw Something"
var ACTION_DRAW_F = "Draw Feature"
var ACTION_DRAW_D = "Draw Detector"
var ACTION_DRAW_E = "Draw Effector"
var ACTION_DRAW_A = "Draw Alarm"
var ACTION_RANDOM = "Random action"

var ID_PLANT_ACTIONS = "plantAction"
var ID_PATHO_ACTIONS = "pathoAction"
var ID_PLANT_ENGAGE = "plantGo"
var ID_PATHO_ENGAGE = "pathoGo"
var ID_PLANT_VICTORY = "plantVicPts"
var ID_PLANT_PRESSURE = "plantPressPts"
var ID_PATHO_VICTORY = "pathoVicPts"
var ID_PATHO_PRESSURE = "pathoPressPts"

var SIDE_PLANT = "plant"
var SIDE_PATHOGEN = "pathogen"