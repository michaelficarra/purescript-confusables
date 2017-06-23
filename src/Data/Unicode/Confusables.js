var confusablesData = require('unicode-confusables-data');
var Scripts = require('unicode-10.0.0').Script_Extensions;
var ScriptExtensionLookupTables = Scripts.reduce(function (memo, s) {
  memo[s] = require('unicode-10.0.0/Script_Extensions/' + s + '/code-points.js');
  return memo;
}, {});

var Hanb = 'Han with Bopomofo', Jpan = 'Japanese', Kore = 'Korean';
function getAugmentedScriptSet(cp) {
  var ret = [];
  for (var i = 0; i < Scripts.length; ++i) {
    var script = Scripts[i];
    if (ScriptExtensionLookupTables[script].indexOf(cp) >= 0) {
      switch (script) {
        case 'Han':
          ret.push(Hanb, Jpan, Kore);
          break;
        case 'Hiragana':
        case 'Katakana':
          ret.push(Jpan);
          break;
        case 'Hangul':
          ret.push(Kore);
          break;
        case 'Bopomofo':
          ret.push(Hanb);
          break;
        case 'Common':
        case 'Inherited':
          return Scripts;
        default:
          ret.push(script);
      }
    }
  }
  return ret;
}

function intersectScriptSets(a, b) {
  var ret = [];
  for (var i = 0; i < a.length; ++i) {
    if (b.indexOf(a[i]) >= 0) {
      ret.push(a[i]);
    }
  }
  return ret;
}

exports.isSingleScript_ = function (cps) {
  return cps.length === 0  ||
    cps.map(getAugmentedScriptSet).reduce(intersectScriptSets).length > 0;
}

exports.getExemplar_ = function (x) {
  return {}.hasOwnProperty.call(confusablesData, x) ? confusablesData[x] : x;
};

exports.normalise = function (x) {
  return x.normalize('NFD');
};
