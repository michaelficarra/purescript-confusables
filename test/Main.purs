module Test.Main where

import Prelude (Unit, discard, map, not, show, ($), (<>), (<<<))
import Control.Monad.Eff (Eff)
import Control.Monad.Eff.Console (CONSOLE, log)
import Data.Array (uncons)
import Data.Foldable (for_)
import Data.Maybe (Maybe(Nothing, Just))
import Data.String.CodePoints (codePointToInt, toCodePointArray)
import Data.Tuple (Tuple(..))
import Test.Assert (ASSERT, assert')

import Data.Unicode.Confusables (isConfusableWith, isSingleScriptConfusableWith, isMixedScriptConfusableWith, isWholeScriptConfusableWith)

pairs :: forall a. Array a -> Array (Tuple a a)
pairs xs = case uncons xs of
  Just { head: x, tail } -> map (Tuple x) tail <> pairs tail
  Nothing -> []

explainString :: String -> String
explainString = show <<< map codePointToInt <<< toCodePointArray

type Descriptor = { description :: String, string :: String }

assert :: forall eff. (String -> String -> Boolean) -> Array Descriptor -> Eff (assert :: ASSERT | eff) Unit
assert assertion xs =
  for_ (pairs xs) $ \(Tuple { description: dA, string: a } { description: dB, string: b }) ->
    assert' (dA <> " (" <> explainString a <> ") / " <> dB <> " (" <> explainString b <> ")") $
      assertion a b

main :: forall eff. Eff (console :: CONSOLE, assert :: ASSERT | eff) Unit
main = do
  log "isConfusableWith"
  assert isConfusableWith $ [
    { description: "empty string", string: "" }
  ]
  assert (not <<< isConfusableWith) $ [
    { description: "a", string: "a" },
    { description: "b", string: "b" }
  ]
  assert isConfusableWith $ [
    { description: "all ASCII", string: "Circle" },
    { description: "all Cyrillic", string: "СігсӀе" },
    { description: "mixed Cyrillic and Latin", string: "Сirсlе" },
    { description: "ASCII with number", string: "Circ1e" },
    { description: "ASCII and high-Common", string: "C𝗂𝗋𝖼𝗅𝖾" },
    { description: "high-Common", string: "𝖢𝗂𝗋𝖼𝗅𝖾" }
  ]
  assert isConfusableWith $ [
    { description: "U+2CA5 COPTIC SMALL LETTER SIMA", string: "ⲥ" },
    { description: "U+03F2 GREEK LUNATE SIGMA SYMBOL", string: "ϲ" },
    { description: "U+0063 LATIN SMALL LETTER C", string: "c" }
  ]
  assert isConfusableWith $ [
    { description: "all ASCII", string: "Ruby??" },
    { description: "not ASCII", string: "ℜ𝘂ᖯʏ⁇" }
  ]
  assert isConfusableWith $ [
    { description: "with ligature", string: "ǉeto" },
    { description: "without ligature", string: "ljeto" }
  ]

  log "isSingleScriptConfusableWith"
  assert isSingleScriptConfusableWith $ [
    { description: "latin with ligature", string: "ǉeto" },
    { description: "latin without ligature", string: "ljeto" }
  ]
  assert (not <<< isSingleScriptConfusableWith) $ [
    { description: "all latin", string: "scope" },
    { description: "all Cyrillic", string: "ѕсоре" }
  ]
  assert (not <<< isSingleScriptConfusableWith) $ [
    { description: "all latin", string: "paypal" },
    { description: "mixed latin and Cyrillic", string: "pаypаl" }
  ]

  log "isMixedScriptConfusableWith"
  assert isMixedScriptConfusableWith $ [
    { description: "all latin", string: "paypal" },
    { description: "mixed latin and Cyrillic", string: "pаypаl" }
  ]

  log "isWholeScriptConfusableWith"
  assert isWholeScriptConfusableWith $ [
    { description: "all latin", string: "scope" },
    { description: "all Cyrillic", string: "ѕсоре" }
  ]
  assert (not <<< isWholeScriptConfusableWith) $ [
    { description: "all latin", string: "paypal" },
    { description: "mixed latin and Cyrillic", string: "pаypаl" }
  ]
