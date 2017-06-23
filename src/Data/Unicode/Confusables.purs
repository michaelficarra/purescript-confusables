module Data.Unicode.Confusables
  ( isConfusableWith
  , isSingleScriptConfusableWith
  , isMixedScriptConfusableWith
  , isWholeScriptConfusableWith
  ) where

import Prelude (map, not, (<<<), (==), (&&), (<>))
import Data.String.CodePoints (CodePoint(), singleton, joinWith, toCodePointArray)

foreign import normalise :: String -> String
foreign import getExemplar_ :: String -> String
foreign import isSingleScript_ :: Array CodePoint -> Boolean

getExemplar :: CodePoint -> String
getExemplar = getExemplar_ <<< singleton

isSingleScript :: String -> Boolean
isSingleScript = isSingleScript_ <<< toCodePointArray


skeleton :: String -> String
skeleton = joinWith "" <<< map getExemplar <<< toCodePointArray


isConfusableWith :: String -> String -> Boolean
isConfusableWith a b = normalise (skeleton (normalise a)) == normalise (skeleton (normalise b))

isSingleScriptConfusableWith :: String -> String -> Boolean
isSingleScriptConfusableWith a b = isConfusableWith a b && isSingleScript (a <> b)

isMixedScriptConfusableWith :: String -> String -> Boolean
isMixedScriptConfusableWith a b = isConfusableWith a b && not (isSingleScript (a <> b))

isWholeScriptConfusableWith :: String -> String -> Boolean
isWholeScriptConfusableWith a b = isMixedScriptConfusableWith a b && isSingleScript a && isSingleScript b
