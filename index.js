var m = require('./output/Data.Unicode.Confusables/index.js');

module.exports = {
  isConfusableWith: function (a, b) {
    return m.isConfusableWith(a)(b);
  },
  isSingleScriptConfusableWith: function (a, b) {
    return m.isSingleScriptConfusableWith(a)(b);
  },
  isMixedScriptConfusableWith: function (a, b) {
    return m.isMixedScriptConfusableWith(a)(b);
  },
  isWholeScriptConfusableWith: function (a, b) {
    return m.isWholeScriptConfusableWith(a)(b);
  },
};
