/*

 welcome.js: first-run page Javascript for Epichrome apps

 Copyright (C) 2020 David Marmor.

 https://github.com/dmarmor/epichrome

 This program is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.

 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.

 You should have received a copy of the GNU General Public License
 along with this program.  If not, see <http://www.gnu.org/licenses/>.

*/


function checkParams () {

    // for loop counter
    var i;
    
    // get URL parameters
    var urlParams = new URLSearchParams(window.location.search);

    // default to new app message
    var messageClass = null;

    // default to no user changes
    var hasUserChanges = false;
    
    // app has been updated
    var oldVersion = urlParams.get('u');
    if (oldVersion) {
	messageClass = 'update';
	document.getElementById('oldversion').innerHTML = oldVersion;
    }
    
    // engine has changed
    var oldEngine = urlParams.get('oe');
    var newEngine = urlParams.get('ne');
    if (oldEngine || newEngine) {
	if (!messageClass) { messageClass = 'change'; }
	if (oldEngine) {
	    document.getElementById('oldengine').innerHTML = oldEngine;
	    setDisplay(document.getElementById('hasoldengine'), 'inline');
	}
	if (newEngine) {
	    document.getElementById('newengine').innerHTML = newEngine;
	    setDisplay(document.getElementById('hasnewengine'), 'inline');
	}

	// show engine-change message
	setDisplay(document.getElementById('change_engine'), 'list-item');
	hasUserChanges = true;
	
	// show password-import action item
	setDisplay(document.getElementById('passwords'), 'flex');

	// show deleted extensions
	var extensions = urlParams.getAll('x');
	if (extensions.length > 0) {

	    // create regex for parsing extension
	    const regexpSize = new RegExp('^(.+),(.*)$');
	    const regexpIcon = new RegExp('dummy');
	    
	    // create list of extensions
	    var extNode = document.getElementById('extension_dummy');
	    var extListNode = extNode.parentNode;
	    var extIconTemplate = extNode.getElementsByClassName('extension_icon')[0].dataset.template;
	    extListNode.removeChild(extNode);
	    extNode.removeAttribute('id');
	    
	    // add extensions to list
	    for (i = 0; i < extensions.length; i++) {
		
		// parse extension ID & name
		var curExt = extensions[i];
		var curMatch = curExt.match(regexpSize);
		if (curMatch) {
		    var curExtID = curMatch[1];
		    var curExtName = curMatch[2];
		    if (! curExtName) { curExtName = curExtID; }
		} else {

		    // unable to parse extension
		    console.log('Unable to parse extension string "' + curExt + '"');
		    continue;
		}
		
		// create list item with parsed extension info
		var curNode = extNode.cloneNode(true);
		curNode.getElementsByClassName('extension_icon')[0].src = extIconTemplate.replace(regexpIcon, curExtID);
		curNode.getElementsByClassName('extension_name')[0].innerHTML = curExtName;
		var curInstall = curNode.getElementsByClassName('install')[0];
		curInstall.href += curExtID;
		extListNode.appendChild(curNode);
	    }
	    
	    // show extension-reinstall action item
	    setDisplay(document.getElementById('extensions'), 'flex');
	}
    }
    
    // show appropriate messages
    if (messageClass) {
	setDisplay(document.getElementsByClassName('new'), 'none');
	setDisplay(document.getElementsByClassName(messageClass), 'flex');
    }

    // show user changes if needed
    if (hasUserChanges) {
	setDisplay(document.getElementById('changes_user'), 'flex');
    }

    // renumber actions list
    var actionsList = document.getElementById('actions_list').getElementsByClassName('item');
    var nextNum = 1;
    var lastItemNum = null;
    for (i = 0; i < actionsList.length; i++) {
	var curAction = actionsList[i];

	// check if this action is visible
	if (curAction.offsetParent != null) {

	    // update item number
	    var curItemNum = curAction.getElementsByClassName('itemnum')[0];
	    curItemNum.innerHTML = nextNum;
	    nextNum++;
	    lastItemNum = curItemNum;
	}
    }

    // special case: only one visible, so hide number
    if (nextNum == 2) { lastItemNum.style.display = 'none'; }
    
    // console.log(urlParams.getAll('action')); // ["edit"]
    // alert("Params = '" + urlParams.toString() + "'"); // "?post=1234&action=edit"
    // console.log(urlParams.append('active', '1')); // "?post=1234&action=edit&active=1"
}

function setDisplay(nodes, displayMode) {
    var nodeArray;
    if (nodes instanceof Node) {
	nodeArray = [ nodes ];
    } else {
	nodeArray = Array.from(nodes);
    }
    for (var i = 0; i < nodeArray.length; i++) {
	nodeArray[i].style.display = displayMode;
    }
}
