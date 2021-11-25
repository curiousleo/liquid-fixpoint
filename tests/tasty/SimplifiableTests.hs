module SimplifiableTests (tests) where

import Arbitrary (subexprs)
import qualified Data.HashMap.Strict as M
import qualified Data.HashSet as S
import GHC.IO (unsafePerformIO)
import Language.Fixpoint.Types.Refinements (Bop (Minus), Constant (I), Expr (..))
import qualified SimplifyInterpreter
import qualified SimplifyPLE
import Test.Tasty
  ( TestTree,
    localOption,
    testGroup,
  )
import Test.Tasty.QuickCheck
  ( QuickCheckMaxSize (..),
    testProperty,
  )

tests :: TestTree
tests =
  localOption
    (QuickCheckMaxSize 4)
    ( testGroup
        "simplify does not increase expression size"
        [ testProperty "PLE" (prop_no_increase SimplifyPLE.simplify'),
          testProperty "Interpreter" (prop_no_increase SimplifyInterpreter.simplify')
        ]
    )

prop_no_increase :: (Expr -> Expr) -> Expr -> Bool
prop_no_increase f e = exprSize (f e) <= exprSize e

exprSize :: Expr -> Int
-- Undo the removal of ENeg in @simplify@ so it does not count as increasing the size of the expression.
exprSize (EBin Minus (ECon (I 0)) e) = exprSize (ENeg e)
exprSize e = 1 + sum (exprSize <$> subexprs e)
