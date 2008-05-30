module CLL where

import Control.Monad
import Data.List
import Data.Maybe
import Directory
import Data.Function
import Text.Regex
import Text.XHtml.Strict

type Chapter   = (ChapterNo,String,[String],[FilePath])
type Contents  = [Chapter]
type ChapterNo = Int
type SectionNo = Int

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

ahref :: HTML a => String -> a -> Html
ahref url = (tag "a" ! [href url] <<)

grabChapters :: IO Contents
grabChapters = mapM getChapter [1..21]
