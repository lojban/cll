module BuildContents where

import CLL

import Text.XHtml.Strict
import IO

outputContents :: IO ()
outputContents = do
  h <- openFile "index.html" WriteMode
  c <- grabChapters
  hSetBuffering h NoBuffering
  hPutStr h $ showContents c
  hClose h

showContents :: Contents -> String
showContents = showHtml . template . ordList . map showChapter

showChapter :: Chapter -> Html
showChapter (c,title,[],_)    = ahref ("c"++show c++"/s.html") title
showChapter (c,title,sects,_) = title +++ ordList sections where
    sections = map (showSection c) $ zip [1..] sects

showSection :: ChapterNo -> (SectionNo,String) -> Html
showSection c (n,title) = ahref url title where
    url = "c" ++ show c ++ "/s" ++ show n ++ ".html"

template :: HTML a => a -> Html
template c = header << thetitle << title
             +++
             body << (h1 << title +++ c)
    where title = "The Lojban Reference Grammar"

