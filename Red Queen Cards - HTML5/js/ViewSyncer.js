/**
 * Created with JetBrains WebStorm.
 * User: badams
 * Date: 6/1/13
 * Time: 9:24 PM
 * To change this template use File | Settings | File Templates.
 */

var theModel = new PlayMat();
var boardState = "Uninitialized";

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

    if(theModel.isPlantETIActive())         boardState="ETI";
    else if(theModel.isPlantMTIActive())    boardState="MTI";
    else                                    boardState="Virulence";
    console.log("Setting board state to "+boardState);
    //theElement.append(":\n"+boardState);


    if(active)
    {
        theElement.css("border-style", "solid");
        theElement.css("border-width", "2px");
        theElement.css("-webkit-animation", "select 1s");
        theElement.css("opacity", "1");
    } else {
        theElement.css("border-style", "dashed");
        theElement.css("border-width", "1px");
        theElement.css("-webkit-animation", "deselect 1s");
        theElement.css("-webkit-transform", "rotateX(180deg)");
        theElement.css("opacity", "0.5");
    }
    window.document.title = ("Current state: "+boardState);
}

function doRandomize(features, detectors, effectors, alarms)
{
    if(!features) features=4;
    if(!detectors) detectors=4;
    if(!effectors) effectors=4;
    if(!alarms) alarms=4;

    var randPick;
    var pickedElement;
    for(var n=0; n<features; n+=1)
    {
        randPick = Math.floor((Math.random()*8));
        doPlay(0, TYPE_FEATURE, randPick);
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

