// https://github.com/harthur/kittydar/blob/master/training/features.js

var hog = require("hog-descriptor"),
    utils = require("kittydar/utils");

var size = 48;

exports.extractFeatures = function(canvas, params) {
  canvas = utils.resizeCanvas(canvas, size, size);

  var descriptor = hog.extractHOG(canvas, params);
  return descriptor;
}