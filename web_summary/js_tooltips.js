/****************************************************************************
* JavaScript Tool-Tips by lobo235 - www.netlobo.com
*
* This script allows you to add javascript tool-tips to your pages in a very
* unobtrusive manner. To learn more about using this script please visit
* http://www.netlobo.com/javascript_tooltips.html for usage examples.
****************************************************************************/

// Empty Variables to hold the mouse position and the window size
var mousePos = null;
var winSize = null;

// Set events to catch mouse position and window size
document.onmousemove = mouseMove;
window.onresize = windowResize;

// The mouseMove and mouseCoords function track the mouse position for us
function mouseMove(ev)
{
	ev = ev || window.event;
	mousePos = mouseCoords(ev);
}
function mouseCoords(ev)
{
	if(ev.pageX || ev.pageY){
		return {x:ev.pageX, y:ev.pageY};
	}
	return {
		x:ev.clientX + document.body.scrollLeft - document.body.clientLeft,
		y:ev.clientY + document.body.scrollTop  - document.body.clientTop
	};
}

// The windowResize function keeps track of the window size for us
function windowResize( )
{
	winSize = {
		x: ( document.body.clientWidth ) ? document.body.clientWidth : window.innerWidth ,
		y: ( document.body.clientHeight ) ? document.body.clientHeight : window.innerHeight
	}
}

// This function shows our tool-tips
function showTip(myid,content)
{
	//var tip = document.getElementById('t'+this.id);
	var tip = document.getElementById('t'+myid);
	tip.style.position = "absolute";
	var newTop = mousePos.y - tip.clientHeight - 10;
	var newLeft = mousePos.x - ( tip.clientWidth / 2 );
	if( newTop < 0 )
		newTop = mousePos.y + 20;
	if( newLeft < 0 )
		newLeft = 0;
	//if( ( mousePos.x + ( tip.clientWidth / 2 ) ) >= winSize.x - 1 )
	//	newLeft = winSize.x - tip.clientWidth - 2;
	tip.style.top = newTop + "px";
	tip.style.left = newLeft + "px";
	tip.style.display = "block";
	tip.innerHTML = content;
}

// This function moves the tool-tips when our mouse moves
function moveTip(myid)
{
	var tip = document.getElementById('t'+myid);
	var newTop = mousePos.y - tip.clientHeight - 10;
	var newLeft = mousePos.x - ( tip.clientWidth / 2 );
	if( newTop < 0 )
		newTop = mousePos.y + 20;
	if( newLeft < 0 )
		newLeft = 0;
	//if( ( mousePos.x + ( tip.clientWidth / 2 ) ) >= winSize.x - 1 )
	//	newLeft = winSize.x - tip.clientWidth - 2;
	tip.style.top = newTop + "px";
	tip.style.left = newLeft + "px";
}

// This function hides the tool-tips
function hideTip(myid)
{
	var tip = document.getElementById('t'+myid);
	tip.style.display = "none";
}

// This function allows us to reference elements using their class attributes
document.getElementsByClassName = function(clsName){
	var retVal = new Array();
	var elements = document.getElementsByTagName("*");
	for(var i = 0;i < elements.length;i++){
		if(elements[i].className.indexOf(" ") >= 0){
			var classes = elements[i].className.split(" ");
			for(var j = 0;j < classes.length;j++){
				if(classes[j] == clsName)
					retVal.push(elements[i]);
			}
		}
		else if(elements[i].className == clsName)
		retVal.push(elements[i]);
	}
	return retVal;
}

// This is what runs when the page loads to set everything up
window.onload = function(){
	var ttips = document.getElementsByClassName('ttip');
	for( var i = 0; i < ttips.length; i++ )
	{
		ttips[i].onmouseover = showTip;
		ttips[i].onmouseout = hideTip;
		ttips[i].onmousemove = moveTip;
	}
	windowResize( );
}
