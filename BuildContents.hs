module BuildContents where

import Data.Maybe
import Text.Regex
import Directory
import Control.Monad
import Data.List
import Text.XHtml.Strict
import IO
import Data.Function

type Chapter   = (ChapterNo,String,[String],[FilePath])
type Contents  = [Chapter]
type ChapterNo = Int
type SectionNo = Int

outputContents :: IO ()
outputContents = do
  h <- openFile "index.html" WriteMode
  c <- grabContents
  hSetBuffering h NoBuffering
  hPutStr h $ showContents c
  hClose h

grabContents :: IO Contents
grabContents = mapM getChapter [1..21]

format :: Contents -> IO ()
format = foldM_ write Nothing . tails . drop 200 . contFlatten where
    write p []             = return $ Nothing
    write p (c@(ch,_,_):n) = do 
      putStrLn $ prettyHtmlFragment $ 
               showPrevious p +++ showCurChap ch +++ showNext n
      return $ Just c

showCurChap :: String -> Html
showCurChap = (h2 <<)

showPrevious :: Maybe (String,String,FilePath) -> Html
showPrevious Nothing = noHtml
showPrevious (Just (_,title,url)) = p << (ahref url "Previous" +++ title)

showNext :: [(String,String,FilePath)] -> Html
showNext ((_,title,url):_) = p << (ahref url "Next" +++ title)
showNext _                 = noHtml

contFlatten :: Contents -> [(String,String,FilePath)]
contFlatten = concatMap flatten where
    flatten (_,t,_,[f]) = [(t,t,f)]
    flatten (_,t,ss,fs)  = map addTitle $ zip ss (tail fs)
        where addTitle (s,f) = (t,s,f)

showContents :: Contents -> String
showContents = showHtml . template . ordList . map showChapter

showChapter :: Chapter -> Html
showChapter (c,title,[],_)    = ahref ("c"++show c++"/s.html") title
showChapter (c,title,sects,_) = title +++ ordList sections where
    sections = map (showSection c) $ zip [1..] sects

showSection :: ChapterNo -> (SectionNo,String) -> Html
showSection c (n,title) = ahref url title where
    url = "c" ++ show c ++ "/s" ++ show n ++ ".html"

ahref :: HTML a => String -> a -> Html
ahref url = (tag "a" ! [href url] <<)

template :: HTML a => a -> Html
template c = header << thetitle << title
             +++
             body << (h1 << title +++ c)
    where title = "The Lojban Reference Grammar"

getChapter :: ChapterNo -> IO Chapter
getChapter c = do
  f <- readFile chFilename
  secNames <- liftM (map (ch++)) $ secFilenames c
  titles <- mapM getSection secNames
  return (c,getChapTitle f, catMaybes titles,secNames)
  where chFilename = ch ++ "s.html"
        ch = "c" ++ show c ++ "/"

secFilenames :: ChapterNo -> IO [String]
secFilenames = sanitize . getNames . show where
    getNames = getDirectoryContents . ("./c" ++)
    sanitize = liftM $ sortBy sorter . strip
    sorter a b | length a /= length b = on compare length a b
               | otherwise            = compare a b
    strip = filter $ not . all (=='.')

getChapTitle :: String -> String
getChapTitle = head . fromJust . getTitle "<h2>.*<br[ ]*/>(.*)</h2>"

getSection :: FilePath -> IO (Maybe String)
getSection = liftM getSecTitle . readFile

getSecTitle :: String -> Maybe String
getSecTitle = maybe Nothing (Just . head) . getTitle "<h3>.*[0-9]+\\. ([^<]+).*?</h3>"

getTitle :: String -> String -> Maybe [String]
getTitle r = matchRegex (mkRegex r) . filter (/='\n')
