// Keep track of some UI elements
var overlayControls = document.getElementById('overlayControls');
var scaleTxt = document.getElementById('scaleTxt');
var offsetTxt = document.getElementById('offsetTxt');

// Track our overlays for re-use later
var overlays = [];

/** Responds to buttons
 * @param {string} name Item to show.
 */
function showOverlay(name) {
  hideAllOverlays();
  currentItem = name;
  setControlVisibility(true);
  overlays[currentItem].setVisible(true);
}

function setControlVisibility(val) {
  if (val) {
    overlayControls.style.visibility = 'visible';
  } else {
    overlayControls.style.visibility = 'hidden';
  }
}

/** For removing every overlay */
function hideAllOverlays() {
  for (var index in overlays) {
    overlays[index].setVisible(false);
  }
}

/** Initialize our constants, build the overlays */
function createOverlays() {
  var somebod = gapi.hangout.av.effects.createImageResource(
      'http://jean-robert.github.com/Hangout/somebod.png');
  overlays['somebod'] = topHat.createFaceTrackingOverlay(
      {'trackingFeature':
       gapi.hangout.av.effects.FaceTrackingFeature.NOSE_ROOT,
       'scaleWithFace': true,
       'rotateWithFace': true,
       'scale': 1.0});
}

createOverlays();

function onStateChanged(event) {
  try {
    console.log('State changed...');
    // If the shared state changes with an addition
    // or modification, make a noise.
    if (event.addedKeys.length > 0) {
      console.log('I say good day to you!');
    }
  } catch (e) {
    console.log('Fail state changed');
    console.log(e);
  }
}

function init() {
  gapi.hangout.onApiReady.add(function(eventObj) {
      if (eventObj.isApiReady) {
        gapi.hangout.data.onStateChanged.add(onStateChanged);
      }
    });
}

gadgets.util.registerOnLoadHandler(init);
