module WriteMenus where

import CLL

import Control.Monad
import Data.List
import Text.XHtml.Strict

writeMenus :: IO ()
writeMenus = grabChapters >>= format

format :: Contents -> IO ()
format = foldM_ write Nothing . tails . contFlatten where
    write p (c@(ch,_,_):n) = do 
      putStrLn $ prettyHtmlFragment $ 
               showPrevious p +++ showCurChap ch +++ showNext n
      return $ Just c
    write p _ = return $ Nothing

showCurChap :: String -> Html
showCurChap = (h2 <<)

showPrevious :: Maybe (String,String,FilePath) -> Html
showPrevious (Just (_,title,url)) = p << (ahref url "Previous" +++ title)
showPrevious _ = noHtml

showNext :: [(String,String,FilePath)] -> Html
showNext ((_,title,url):_) = p << (ahref url "Next" +++ title)
showNext _ = noHtml

contFlatten :: Contents -> [(String,String,FilePath)]
contFlatten = concatMap flatten where
    flatten (_,t,_,[f]) = [(t,t,f)]
    flatten (_,t,ss,fs)  = map addTitle $ zip ss (tail fs)
        where addTitle (s,f) = (t,s,f)
