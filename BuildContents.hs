module BuildContents where

import Data.Maybe
import Text.Regex
import Directory
import Control.Monad
import Data.List
import Text.XHtml.Strict
import IO
import Data.Function

type Chapter   = (ChapterNo,String,[String])
type Contents  = [Chapter]
type ChapterNo = Int
type SectionNo = Int

outputContents :: IO ()
outputContents = do
  h <- openFile "index.html" WriteMode
  c <- mapM getChapter [1..21]
  hSetBuffering h NoBuffering
  hPutStr h $ showContents c
  hClose h

showContents :: Contents -> String
showContents = prettyHtml . template . ordList . map showChapter

showChapter :: Chapter -> Html
showChapter (c,title,[])    = ahref ("c"++show c++"/s.html") title
showChapter (c,title,sects) = title +++ ordList sections where
    sections = map (showSection c) $ zip [1..] sects
    showSection c (n,title) = ahref url title where
        url = "c" ++ show c ++ "/s" ++ show n ++ ".html"

ahref :: HTML a => String -> a -> Html
ahref url = (tag "a" ! [href url] <<)

template :: HTML a => a -> Html
template c = header << thetitle << title
             +++
             body << ((h1 << title) +++ c)
    where title = "The Lojban Reference Grammar"

getChapter :: ChapterNo -> IO Chapter
getChapter c = do
  f <- readFile chFilename
  secNames <- secFilenames c
  titles <- mapM (getSection . (ch++)) secNames
  return (c,getChapTitle f, catMaybes titles)
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
