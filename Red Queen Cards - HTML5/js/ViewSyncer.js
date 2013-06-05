/**
 * Created with JetBrains WebStorm.
 * User: badams
 * Date: 6/1/13
 * Time: 9:24 PM
 * To change this template use File | Settings | File Templates.
 */

var theModel = new PlayMat();
var boardState = "Uninitialized";
var NUMBER_OF_FEATURES = 8;
var NUMBER_OF_DETECTORS = 8;
var NUMBER_OF_EFFECTORS = 16;
var NUMBER_OF_ALARMS = 16;
var EFFECTORS_PER_DETECTOR = 2;

//$("#wrap").append($.zc("#test>.ing>ul>(li>{!for:n:data!})*4", {data: [1,2,3,5]}));

function getElement(type, colIndex)
{
    var selector = "#board > #c"+(colIndex+1)+" > .";
    switch(type)
    {
        case TYPE_ALARM:
            selector+="a"+(arguments[2]+1);
            break;
        case TYPE_DETECTOR:
            selector+="detector";
            break;
        case TYPE_EFFECTOR:
            selector+="e"+(arguments[2]+1);
            break;
        case TYPE_FEATURE:
            selector+="feature";
            break;
        default:
            alert("Bad element request");
            selector="";
            break;
    }
    return $(selector);
}

function connectElement(type, colIndex)
{
    var theFeature;
    if(arguments.length<3)
    {

        theFeature = getElement(type, colIndex);
        theFeature.click(function(){ doPlay(theFeature, type, colIndex)});
    } else {
        var theVariant = arguments[2];
        theFeature = getElement(type, colIndex, theVariant);
        theFeature.click(function(){ doPlay(theFeature, type, colIndex, theVariant)});
    }
    theFeature.css("border-style", "dashed");
}


function setElementActivity(active, theElement)
{
    if (active)
    {
        theElement.css("border-style", "solid");
        theElement.css("border-width", "2px");
        theElement.css("-webkit-animation", "select 1s");
        theElement.css("-webkit-transform", "rotateX(0deg)");
        theElement.css("opacity", "1");
    } else {
        theElement.css("border-style", "dashed");
        theElement.css("border-width", "1px");
        theElement.css("-webkit-animation", "deselect 1s");
        theElement.css("-webkit-transform", "rotateX(180deg)");
        theElement.css("opacity", "0.5");
    }
}
function updateBoardState()
{
    if (theModel.isPlantETIActive())         boardState = "ETI";
    else if (theModel.isPlantMTIActive())    boardState = "MTI";
    else                                    boardState = "Virulence";
    console.log("Board: " + boardState);
    window.document.title = ("Current state: " + boardState);
}
function doSet(theElement, newValue, type, colIndex)
{
    var wide = (arguments.length < 5);
    var currentValue;
    if(wide)
    {
        currentValue = theModel.isCellActive(type, colIndex);
        if(currentValue!=newValue)
        {
            theModel.setCell(newValue, type, colIndex);
            updateBoardState();
            if(!theElement) theElement = getElement(type, colIndex);
            setElementActivity(newValue, theElement);
        }
    }
    else
    {
        currentValue = theModel.isCellActive(type, colIndex, arguments[4]);
        if(currentValue!=newValue)
        {
            theModel.setCell(newValue, type, colIndex, arguments[4]);
            updateBoardState();
            if(!theElement) theElement = getElement(type, colIndex, arguments[4]);
            setElementActivity(newValue, theElement);
        }
    }
}
function doPlay(theElement, type, colIndex)
{
    var wide = (arguments.length < 4);
    var active;

    if(wide)
    {
        active = theModel.toggleCell(type, colIndex);
        if(!theElement) theElement = getElement(type, colIndex);
    }
    else
    {
        active = theModel.toggleCell(type, colIndex, arguments[3]);
        if(!theElement) theElement = getElement(type, colIndex, arguments[3]);
    }
    updateBoardState();
    setElementActivity(active, theElement);
}

function randomSelectionArray(picks, total)
{
    var picklist = [];
    for(var i=0; i<picks; i+=1) picklist[i] = true;
    for(var i=picks; i<total; i+=1) picklist[i] = false;
    var randIndex;
    for(var i=0; i<total; i+=1)
    {
        randIndex = Math.floor(i+(Math.random()*(total-i)));
        if(picklist[i]) //Rather than storing an extra temporary variable
        {
            picklist[i] = picklist[randIndex];
            picklist[randIndex] = true;
        }
        else
        {
            picklist[i] = picklist[randIndex];
            picklist[randIndex] = false;
        }

    }
    return picklist;
}
function doRandomize(features, detectors, effectors, alarms)
{
    if(!features) features=4;
    if(!detectors) detectors=4;
    if(!effectors) effectors=4;
    if(!alarms) alarms=4;

    var randList;
    var i;
    var v;

    console.log("RANDOMIZING----------------------------------");
    randList = randomSelectionArray(features, NUMBER_OF_FEATURES);
    for(i=0; i<NUMBER_OF_FEATURES; i+=1)
        doSet(0, randList[i], TYPE_FEATURE, i);

    randList = randomSelectionArray(detectors, NUMBER_OF_DETECTORS);
    for(i=0; i<NUMBER_OF_DETECTORS; i+=1)
        doSet(0, randList[i], TYPE_DETECTOR, i);

    randList = randomSelectionArray(effectors, NUMBER_OF_EFFECTORS);
    for( i=0; i<NUMBER_OF_EFFECTORS/EFFECTORS_PER_DETECTOR; i+=1)
        for(var v=0; v<2; v+=1)
            doSet(0, randList[2*i+v], TYPE_EFFECTOR, i, v);

    randList = randomSelectionArray(effectors, NUMBER_OF_ALARMS);
    for( i=0; i<NUMBER_OF_ALARMS/EFFECTORS_PER_DETECTOR; i+=1)
        for(var v=0; v<2; v+=1)
            doSet(0, randList[2*i+v], TYPE_ALARM, i, v);
}

function doQuiz()
{
    var passedQuiz = false;
    while(!passedQuiz)
    {
        passedQuiz = doQuizLevel1();
    }
}

function doQuizLevel1()
{
    doRandomize(4, 4, 0, 0);

    var response = prompt("Does the board currently show MTI or Virulence?\n"+boardState);

    if(response==null || response=="")
    {
        console.log("User pressed cancel");
        return true;
    }
    if(response.toUpperCase()==boardState.toUpperCase())
    {
        console.log("User got it right! Next.")
        alert("Correct! The board currently shows "+response);
        return true;
    } else {
        console.log("User provided wrong answer");
        alert("'"+response+"' is not correct. The board currently shows "+boardState);
        return false;
    }
}

$(document).ready(function(){
    boardState="Ready for input";
    for(var i=0; i<NUMBER_OF_PLAYABLE_COLUMNS; i+=1)
    {
        connectElement(TYPE_FEATURE, i);
        connectElement(TYPE_DETECTOR, i);
        connectElement(TYPE_EFFECTOR, i, 0);
        connectElement(TYPE_EFFECTOR, i, 1);
        connectElement(TYPE_ALARM, i, 0);
        connectElement(TYPE_ALARM, i, 1);
    }
    var randomButton = $("#Randomizer");
    randomButton.click(function(){ doRandomize(4,4,4,4);});
    //$("#board > #c1 > .feature").click(function(){ alert("Clicky"); });
});

