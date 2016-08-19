
// Clear any selected text.
function clearSelection() {
  if ( document.selection ) {
    document.selection.empty();
  } else if ( window.getSelection ) {
    window.getSelection().removeAllRanges();
  }
}

// Really simple way of determining if mousedown.
var mouseDown = false;
document.addEventListener('mousedown', function(e) {
  mouseDown = true;
}, false);
document.addEventListener('mouseup', function(e) {
  mouseDown = false;
  addOrRemove = '';
}, false);

// Handle highlighting of rows.
var addOrRemove = '';
function highlightRow(inputObj) {
  var trObj = inputObj.parentElement;
  if (mouseDown) {
    var cls = 'highlight';
    if (addOrRemove == '') {
      if (trObj.classList.contains(cls)) {
        addOrRemove = 'remove';
      } else {
        addOrRemove = 'add';
      }
    }
    if (addOrRemove == 'remove') {
      trObj.classList.remove(cls);
    } else {
      trObj.classList.add(cls);
    }
    clearSelection();
  }
}
function highlightRowClick(inputObj) {
  var trObj = inputObj.parentElement;
  var cls = 'highlight';
  if (trObj.classList.contains(cls)) {
    trObj.classList.remove(cls);
  } else {
    trObj.classList.add(cls);
  }
}
