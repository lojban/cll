module BuildContents where

import Data.Maybe
import Text.Regex
import Directory
import Control.Monad
import Data.List
import Text.XHtml.Strict
import IO

type Chapter = (String,[String])
type Contents = [Chapter]
type ChapterNo = Int
type SectionNo = Int

outputContents :: IO ()
outputContents = do
  h <- openFile "index.html" WriteMode
  c <- getContents'
  hSetBuffering h NoBuffering
  hPutStr h $ showContents c
  hClose h

showContents :: Contents -> String
showContents = showHtml . template . ordList . map showChapter . zip [1..] where
    showChapter (c,(title,[]))       = (""+++hotlink url (primHtml title))
        where url = "c" ++ show c ++ "/s.html"
    showChapter (c,(title,sections)) = title +++ ordList (map (link c) $ zip [1..] sections)
    link c (s,title) = hotlink url (primHtml title)
        where url = "c" ++ show c ++ "/s" ++ show s ++ ".html"

template a = (header << (thetitle << title'))
              +++
             (body << ((h1 << title') +++ a))
    where title' = "The Lojban Reference Grammar"

getContents' :: IO Contents
getContents' = mapM getChapter [1..21]

getChapter :: ChapterNo -> IO Chapter
getChapter c = do
  f <- readFile chFilename
  secNames <- secFilenames c
  case secNames of
    []    -> return (getChapTitle f, [])
    names -> do titles <- mapM (getSection c) $ map (ch++) names
                return (getChapTitle f, catMaybes titles)
    where chFilename = ch ++ "s.html"
          ch = "c" ++ show c ++ "/"

secFilenames :: ChapterNo -> IO [String]
secFilenames = sanitize . getNames . show where
    getNames = getDirectoryContents . ("./c" ++)
    sanitize = liftM $ sortBy f . strip
    f a b | length a < length b = LT
          | length a > length b = GT
          | otherwise = compare a b
    strip = filter $ not . all (=='.')

getChapTitle :: String -> String
getChapTitle = head . fromJust . match . stripNewline where
    match = matchRegex regex
    regex = mkRegex "<h2>.*<br[ ]*/>(.*)</h2>"

getSection :: ChapterNo -> FilePath -> IO (Maybe String)
getSection c secFilename = do
  f <- readFile secFilename
  return $ getSecTitle f

getSecTitle :: String -> Maybe String
getSecTitle f = maybe Nothing (Just . head) match  where
    match = matchRegex regex (stripNewline f)
    regex = mkRegex "<h3>.*[0-9]+\\. ([^<]+).*?</h3>"

stripNewline = filter (/='\n')