/**
 * Created with JetBrains WebStorm.
 * User: badams
 * Date: 6/1/13
 * Time: 9:24 PM
 * To change this template use File | Settings | File Templates.
 */

var theModel = new PlayMat();
var boardState = "Uninitialized";

function getElement(type, colIndex)
{
    var selector = ".board > #c"+(colIndex+1)+" > .";
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
    if(wide)  active = theModel.toggleCell(type, colIndex);
    else      active = theModel.toggleCell(type, colIndex, arguments[3]);

    if(theModel.isPlantETIActive())         boardState="ETI";
    else if(theModel.isPlantMTIActive())    boardState="MTI";
    else                                    boardState="Virulence";
    console.log("Setting board state to "+boardState);
    //theElement.append(":\n"+boardState);

    if(active)
    {
        theElement.css("border-style", "solid");
        theElement.css("border-width", "2px");
        theElement.css("-webkit-animation", "rectify 2s");
    } else {
        theElement.css("border-style", "dashed");
        theElement.css("border-width", "1px");
        theElement.css("-webkit-animation", "");
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
    //$(".board > #c1 > .feature").click(function(){ alert("Clicky"); });
});