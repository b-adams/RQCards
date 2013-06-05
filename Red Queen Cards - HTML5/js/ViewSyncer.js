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
var currentLevel = 0;
var attempts = ["Level results",
                {correct: 0, incorrect: 0},
                {correct: 0, incorrect: 0},
                {correct: 0, incorrect: 0}];

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
        theElement.css("opacity", "0.25");
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
    if(arguments.length==0)
    {
        features=4;
        detectors=4;
        effectors=4;
        alarms=4;
    }

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

    randList = randomSelectionArray(alarms, NUMBER_OF_ALARMS);
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

function wrongSelectionInfoPopup(suppliedAnswer, correctAnswer)
{
    if(suppliedAnswer==correctAnswer) return; //Nothing wrong here
    if(suppliedAnswer==null || suppliedAnswer=="") return; //No answer
    var diagnosis = "Incorrect.\nYou selected "+suppliedAnswer;
    switch(suppliedAnswer)
    {
        case "ETI":
            diagnosis+=" but there are no effector-alarm matches.";
            switch(correctAnswer)
            {
                case "MTI":
                    diagnosis+="\nLook at the feature-detector row.";
                    break;
                case "Virulence":
                    diagnosis+="\nWere you looking at detector-effector disablements?";
                    break;
            }
            break;
        case "MTI":
            switch(correctAnswer)
            {
                case "ETI":
                    diagnosis+=".\nKeep in mind that effector-alarm matches trump feature-detector ones.";
                    break;
                case "Virulence":
                    diagnosis+=" but there are not enough *non-disabled* feature-detector matches.";
                    break;
            }
            break;
        case "Virulence":
            switch(correctAnswer)
            {
                case "MTI":
                    diagnosis+=".\nCheck again for active feature-detector matches.";
                    break;
                case "ETI":
                    diagnosis+=".\nCheck again for effector-alarmmatches.";
                    break;
            }
            break;
    }
    alert(diagnosis);
}
function setupLevel(whichLevel)
{
    if(whichLevel<1 || whichLevel>4)
    {
        alert("Invalid level "+whichLevel);
        return;
    }
    currentLevel = whichLevel;
    switch(currentLevel)
    {
        case 1: doRandomize(4,4,0,0); break;
        case 2: doRandomize(4,4,4,0); break;
        case 3: doRandomize(4,4,4,4); break;
        case 4: doRandomize(4,4,4,4); break;
    }
}
function updateQuizLabels(whichLevel)
{
    var quizBox = $("#Quiz"+whichLevel);
    var right = attempts[whichLevel]["correct"];
    var wrong = attempts[whichLevel]["incorrect"];
    quizBox.html("Level "+whichLevel+"<br>Answers: "+(right+wrong)+" Correct: "+right);

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
    $("#comboBoard").change(function(){
        var answer = $(this).val();
        if(answer==null || answer=="") return;
        if( answer == boardState)
        {
            //alert("Correct!");
            attempts[currentLevel]["correct"]+=1;
            setupLevel(currentLevel);
            $(this).val(""); //Reset box
        }
        else
        {
            attempts[currentLevel]["incorrect"]+=1;
            wrongSelectionInfoPopup(answer, boardState);
        }
        updateQuizLabels(currentLevel);

    });
    $("#ClearBoardButton").click(function(){ doRandomize(0,0,0,0);});

    $("#Quiz1").click(function(){ setupLevel(1); });
    $("#Quiz2").click(function(){ setupLevel(2); });
    $("#Quiz3").click(function(){ setupLevel(3); });
    $("#Quiz4").click(function(){
        setupLevel(4);
        //Ask user to disable problem spots
        //Refill randomly
    });
    //$("#board > #c1 > .feature").click(function(){ alert("Clicky"); });
});

