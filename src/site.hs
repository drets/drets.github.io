--------------------------------------------------------------------------------
{-# LANGUAGE OverloadedStrings #-}
module Main where

import           Control.Exception
import qualified Control.Monad.State as St
import           Data.Either (either)
import           Data.Function ((&))
import           Data.List (sortBy)
import           Data.Maybe (fromMaybe, listToMaybe)
import           Data.Monoid ((<>))
import           Data.Ord (comparing)
import           Data.String (fromString)
import qualified Github.Auth as G
import qualified Github.Issues as G
import           Hakyll
import           System.FilePath (takeFileName, (-<.>), (</>))
import           System.IO
import           Text.Highlighting.Kate (styleToCss, tango)
import           Text.Pandoc.Definition
import           Text.Pandoc.Options
import           Text.Pandoc.Options
import           Text.Read (readMaybe)

import qualified Scripts as Scr

--------------------------------------------------------------------------------
hakyllConfig :: Configuration
hakyllConfig = defaultConfiguration
    { providerDirectory = "src"
    , deploySite = Scr.deploy siteBuilders
    }
    where
    siteBuilders = Scr.SiteBuilders
        { Scr.theSiteRules = theSite
        , Scr.ghIssuesRules = ghIssues
        }

ourPandocWriterOptions :: WriterOptions
ourPandocWriterOptions = defaultHakyllWriterOptions{ writerHtml5 = True }

tocPandocWriterOptions :: WriterOptions
tocPandocWriterOptions = ourPandocWriterOptions
    { writerTableOfContents = True
    , writerTemplate = "$toc$\n$body$"
    , writerStandalone = True
    }

processWithPandoc :: Item String -> Compiler (Item String)
processWithPandoc = processWithPandoc' False

processWithPandoc' :: Bool -> Item String -> Compiler (Item String)
processWithPandoc' withToc =
    renderPandocWith defaultHakyllReaderOptions
        (if withToc then tocPandocWriterOptions else ourPandocWriterOptions)

pandocCompilerOfOursWithTransform :: Compiler (Item String)
pandocCompilerOfOursWithTransform = do
  pandocCompilerWithTransform
    defaultHakyllReaderOptions
    ourPandocWriterOptions
    ourTransform

pandocCompilerOfOurs :: Compiler (Item String)
pandocCompilerOfOurs = do
  pandocCompilerWith
    defaultHakyllReaderOptions
    ourPandocWriterOptions

ourTransform :: Pandoc -> Pandoc
ourTransform p@(Pandoc meta blocks) = (Pandoc meta (ert:blocks))
  where
    ert = Para [ SmallCaps [ Str $ timeEstimateString p, Str $ " read"] ]

timeEstimateString :: Pandoc -> String
timeEstimateString = toClockString . timeEstimateSeconds

toClockString :: Int -> String
toClockString i
    | i >= 60 * 60 = show hours ++ "hour " ++ show minutes ++ "min " ++ show seconds ++ "sec"
    | i >= 60      = show minutes ++ "min " ++ show seconds ++ "sec"
    | otherwise    = show seconds ++ "sec"
  where
    hours   = i `quot` (60*60)
    minutes = (i `rem` (60*60)) `quot` 60
    seconds = i `rem` 60

timeEstimateSeconds :: Pandoc -> Int
timeEstimateSeconds = (`quot` 5) . nrWords

nrWords :: Pandoc -> Int
nrWords = (`quot` 5) . nrLetters

nrLetters :: Pandoc -> Int
nrLetters (Pandoc _ bs) = sum $ map cb bs
  where
    cbs = sum . map cb
    cbss = sum . map cbs
    cbsss = sum . map cbss

    cb :: Block -> Int
    cb (Plain is) = cis is
    cb (Para is) = cis is
    cb (CodeBlock _ s) = length s
    cb (RawBlock _ s) = length s
    cb (BlockQuote bs) = cbs bs
    cb (OrderedList _ bss) = cbss bss
    cb (BulletList bss) = cbss bss
    cb (DefinitionList ls) = sum $ map (\(is, bss) -> cis is + cbss bss) ls
    cb (Header _ _ is) = cis is
    cb HorizontalRule = 0
    cb (Table is _ _ tc tcs) = cis is + cbss tc + cbsss tcs
    cb (Div _ bs) = cbs bs
    cb Null = 0

    cis = sum . map ci
    ciss = sum . map cis

    ci :: Inline -> Int
    ci (Str s) = length s
    ci (Emph is) = cis is
    ci (Strong is) = cis is
    ci (Strikeout is) = cis is
    ci (Superscript is) = cis is
    ci (Subscript is) = cis is
    ci (SmallCaps is) = cis is
    ci (Quoted _ is) = cis is
    ci (Cite _ is) = cis is
    ci (Code _ s) = length s
    ci Space = 1
    ci SoftBreak = 1
    ci LineBreak = 1
    ci (Math _ s) = length s
    ci (RawInline _ s) = length s
    ci (Link _ is (_, s)) = cis is + length s
    ci (Image _ is (_, s)) = cis is + length s
    ci (Note bs) = cbs bs


rssConfig :: FeedConfiguration
rssConfig = FeedConfiguration
    { feedTitle = "drets"
    , feedDescription = "For λ calculus"
    , feedAuthorName = "Dmytro Rets"
    , feedAuthorEmail = "" -- Not used by RSS.
    , feedRoot = "https://drets.life"
    }

--------------------------------------------------------------------------------
postDateCtx :: Context String
postDateCtx = dateField "date" "%Y-%m-%d"

postItemCtx :: Context String
postItemCtx = postDateCtx <> baseCtx

redditCtx :: Context String
redditCtx = field "reddit-button" $ \it -> do
    redd <- itemIdentifier it `getMetadataField` "reddit"
    maybe (return "") (const $ loadBody "fragments/reddit.html") redd

ghCommentsCtx :: Context String
ghCommentsCtx = field "gh-comments-button" $ \it -> do
    mGhi <- itemIdentifier it `getMetadataField` "gh-issue"
    maybe (return "") commentFragment mGhi
    where
    issueBasePath = "https://github.com/drets/drets.github.io/issues/"
    commentFragment ghi = fmap itemBody $
        load "fragments/gh-comments.html"
        >>= applyAsTemplate (issueLinkCtx ghi)
    issueLink ghi = issueBasePath ++ ghi
    issueLinkCtx ghi = constField "gh-issue-link" $ issueLink ghi

teaserCtx :: Context String
teaserCtx = teaserField "teaser" "content" <> postItemCtx

postCtx :: Context String
postCtx = postDateCtx
    <> ghCommentsCtx <> redditCtx
    <> baseCtx

baseCtx :: Context String
baseCtx = defaultContext

--------------------------------------------------------------------------------
plainPosts, literatePosts, hiddenPosts, allPosts :: Pattern
plainPosts = "posts/*.md"
literatePosts = "posts/*.lhs"
hiddenPosts = "posts/_*"
allPosts = (plainPosts .||. literatePosts)
    .&&. complement hiddenPosts

--------------------------------------------------------------------------------
main :: IO ()
main = hakyllWith hakyllConfig theSite

theSite :: Rules ()
theSite = do
    match "images/**" $ do
        route   idRoute
        compile copyFileCompiler

    match "extras/**" $ do
        route   idRoute
        compile copyFileCompiler

    match "favicon.ico" $ do
        route   idRoute
        compile copyFileCompiler

    match "css/*" $ do
        route   idRoute
        compile compressCssCompiler

    match "about.md" $ do
        route $ setExtension ".html"
        compile $ do
            pandocCompilerOfOurs
                >>= loadAndApplyTemplate
                    "templates/default.html" baseCtx
                >>= relativizeUrls

    tags <- buildTags "posts/*" (fromCapture "tags/*.html")

    tagsRules tags $ \tag pattern -> do
        let title = "Posts tagged as \"" ++ tag ++ "\""
        route idRoute
        compile $ do
            posts <- recentFirst =<< loadAll pattern
            let ctx = constField "title" title
                    <> listField "posts" postCtx (return posts)
                    <> defaultContext
                    <> constField "amount" (show $ length posts - 1)
            makeItem ""
                >>= loadAndApplyTemplate "templates/tag.html" ctx
                >>= loadAndApplyTemplate "templates/default.html" ctx
                >>= relativizeUrls

    match "index.html" $ do
        route $ idRoute
        compile $ do
            posts <- recentFirst =<< loadAll allPosts
            getResourceBody
                >>= applyAsTemplate
                     ((listField "posts" postItemCtx (return posts)) <>
                     constField "amount" (show $ length posts - 1))
                >>= loadAndApplyTemplate
                    "templates/default.html" baseCtx
                >>= relativizeUrls

    match "tags.html" $ do
        route $ idRoute
        compile $ do
            getResourceBody
                >>= applyAsTemplate (tagCloudField "cloud" 100 300 tags)
                >>= loadAndApplyTemplate
                    "templates/default.html" baseCtx
                >>= relativizeUrls

    match allPosts $ do
        route   $ setExtension "html"
        compile $ do
            pandocCompilerOfOursWithTransform
                >>= saveSnapshot "content"
                >>= loadAndApplyTemplate
                    "templates/post.html" postCtx
                >>= loadAndApplyTemplate
                    "templates/post-wrapper.html" (tagsField "tags" tags `mappend` postItemCtx)
                >>= loadAndApplyTemplate
                    "templates/default.html" baseCtx
                >>= relativizeUrls

    match "repo/*" $ do
        route   $ customRoute $ takeFileName . toFilePath
        compile   copyFileCompiler

    create [".nojekyll"] $ do
        route     idRoute
        compile $ makeItem ("" :: String)

    create ["css/syntax.css"] $ do
        route   $ idRoute
        compile $ makeItem (compressCss . styleToCss $ tango)

    create ["rss.xml"] $ do
        route idRoute
        compile $ do
            let feedCtx = bodyField "description"
                    <> baseCtx

                processRssItem :: Item String -> Compiler (Item String)
                processRssItem it = do
                    let id' = itemIdentifier it
                    baseRoute <- getRoute id'
                    let toRssCtx = constField "reddit-alt"
                                (fromMaybe "" baseRoute)
                            <> postCtx
                    return it
                        >>= loadAndApplyTemplate
                            "templates/post.html" toRssCtx
                        >>= relativizeUrls

            barePosts <- mapM processRssItem
                =<< fmap (take 12) . recentFirst
                =<< loadAllSnapshots allPosts "content"
            renderRss rssConfig feedCtx barePosts

    match "templates/*" $ compile templateCompiler

    match "fragments/*" $ compile getResourceBody

-- TODO: Make these rules less ugly.
ghIssues :: Rules ()
ghIssues = do
    -- For testing purposes, switch to plainPosts .||. literatePosts
    let withIssues = allPosts

    match withIssues . version "gh-issue" $
        compile $ do
            ident <- getUnderlying
            let postPath = toFilePath ident
            title <- ident `getMetadataField'` "title"
            mIssue <- ident `getMetadataField` "gh-issue"
            case mIssue of
                Nothing -> makeItem ()
                Just issue -> case readMaybe issue :: Maybe Int of
                    Nothing -> error $ "ghIssues: Malformed issue for "
                        ++ postPath -- TODO: bail out more gracefully.
                    Just nIssue
                        | nIssue < 1 -> error $ "ghIssues: Issue < 1 for "
                            ++ postPath
                        | otherwise -> do
                            potIss <- makeItem $
                                Scr.PotentialIssue
                                    { Scr.potentialIssueNumber = nIssue
                                    , Scr.potentialIssueTitle = title
                                    , Scr.potentialIssuePath = postPath
                                    }
                            saveSnapshot "potential-issue" potIss
                            makeItem ()

    create ["virtual/gh-issues"] $
        compile $ do
            potIssues <- sortBy (comparing $
                    Scr.potentialIssueNumber . itemBody)
                <$> loadAllSnapshots withIssues "potential-issue"
            emLastIssue <- fmap (fmap listToMaybe) . unsafeCompiler $
                G.issuesForRepo "drets" "drets.github.io" [G.PerPage 1]
            unsafeCompiler $ emLastIssue & either
                (error . ("ghIssues: Last issue request failed: " ++) . show)
                (\mLastIssue -> do
                    let nLastIssue = fromMaybe 0 $
                            G.issueNumber <$> mLastIssue
                    auth <- G.GithubBasicAuth
                        <$> (putStrLn "GitHub username:"
                            *> fmap fromString getLine)
                        <*> fmap fromString getPassword
                    -- Creates GitHub issues for each potIss, but only if the
                    -- issue numbers are sensible (that is, they increase by
                    -- one, starting from the last existing issue number).
                    flip St.evalStateT nLastIssue $
                        St.forM_ potIssues $ \(Item ident potIss) -> do
                            curN <- St.get
                            let potN = Scr.potentialIssueNumber potIss
                                nextN = curN + 1
                                title = Scr.potentialIssueTitle potIss
                            eOldIssue <- St.liftIO $ G.issue
                                "drets" "drets.github.io" potN
                            eOldIssue & flip either
                                (St.liftIO . putStrLn
                                . (("Issue " ++ show potN ++ " for "
                                    ++ toFilePath ident ++ " already taken "
                                    ++ "by: ") ++)
                                . G.issueTitle)
                                (const $ do -- TODO: Analyse the error.
                                    St.unless (potN == nextN) $
                                        error ("ghIssues: Requested issue number for "
                                            ++ toFilePath ident ++ " is " ++ show potN
                                            ++ ", expected " ++ show nextN)
                                    eNewIss <- St.liftIO $ G.createIssue auth
                                        "drets" "drets.github.io"
                                        (G.newIssue title)
                                            -- TODO: Duplicates the post route.
                                            { G.newIssueBody = Just $
                                                "Comment thread for ["
                                                ++ title ++ "]("
                                                ++ relativizeUrlsWith
                                                    "https://drets.github.io/"
                                                    (toFilePath ident -<.> "html")
                                                ++ ")."
                                            , G.newIssueLabels = Just
                                                ["comment-thread"]
                                            }
                                    eNewIss & either
                                        (error . (("ghIssues: Issue creation failed "
                                                ++ "for " ++ toFilePath ident ++ ": ")
                                            ++) . show)
                                        (\newIss -> let newN = G.issueNumber newIss
                                            in if newN /= potN
                                                then error $
                                                    "ghIssues: New issue number for "
                                                        ++ toFilePath ident ++ " is "
                                                        ++ show newN ++ ", expected "
                                                        ++ show potN
                                                else (St.liftIO . putStrLn $
                                                        "Created issue " ++ show newN
                                                        ++ " for " ++ toFilePath ident)
                                                    *> St.put newN)
                                    )
                    )
            makeItem ()

-- Qv. http://stackoverflow.com/q/4064378
getPassword :: IO String
getPassword = do
  putStr "Password: "
  hFlush stdout
  pass <- withEcho False getLine
  putChar '\n'
  return pass

withEcho :: Bool -> IO a -> IO a
withEcho echo action = do
  old <- hGetEcho stdin
  bracket_ (hSetEcho stdin echo) (hSetEcho stdin old) action
--------------------------------------------------------------------------------
