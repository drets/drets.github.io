{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE LambdaCase #-}
{-# LANGUAGE DeriveGeneric #-}
module Scripts
    ( deploy
    , SiteBuilders(..)
    , PotentialIssue(..)
    ) where

import qualified Hakyll as H
import System.Environment (withArgs)
import GHC.Generics (Generic)
import Data.Binary (Binary)
import Control.Monad.Managed (with)
import Turtle

deploy :: SiteBuilders -> H.Configuration -> IO ExitCode
deploy builders conf =
    echoOK "Rebuilding and deploying site...\n"
    -- Automated issue-thread creation. It already works, and will be
    -- enabled once it gets some extra polish.
    -- .&&. withArgs ["build"] (ghIssuesRules builders & H.hakyllWithExitCode conf)
    .&&. withArgs ["rebuild"]
        (theSiteRules builders & H.hakyllWithExitCode conf)
    .&&. shell "rsync -avc --delete --exclude '.git' _site/ ../master/" empty
    .&&. shell "cp .travis.yml ../master/.travis.yml" empty
    .&&. cd "../master"
        *> shell "git rev-parse --git-dir > /dev/null" empty
    .&&. ( fold (inshell "git status --porcelain" empty) countLines
        >>= \case
            0 -> return ExitSuccess
            _ -> echoOK "\nAdding and committing the following changes:"
                .&&. shell "git status" empty
                .&&. shell "git add ." empty
                .&&. with (shell "git commit" empty & fork) wait )
    .&&. echoOK "\nPushing pending commits, if any."
    .&&. with (shell "git push gh master" empty & fork) wait

echoOK :: MonadIO io => Text -> io ExitCode
echoOK txt = echo txt *> pure ExitSuccess

data SiteBuilders = SiteBuilders
    { theSiteRules :: H.Rules ()
    , ghIssuesRules :: H.Rules ()
    }

data PotentialIssue = PotentialIssue
    { potentialIssueNumber :: Int
    , potentialIssueTitle :: String
    , potentialIssuePath :: String
    } deriving (Show, Generic)

instance Binary PotentialIssue
