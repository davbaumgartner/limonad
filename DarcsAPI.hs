-- Copyright (c) 2013, David Baumgartner <ch.davidbaumgartner@gmail.com>
-- 
-- All rights reserved.
-- Redistribution and use in source and binary forms, with or without
-- modification, are permitted provided that the following conditions are met:
 
-- * Redistributions of source code must retain the above copyright
--   notice, this list of conditions and the following disclaimer.
-- * Redistributions in binary form must reproduce the above copyright
--   notice, this list of conditions and the following disclaimer in the
--   documentation and/or other materials provided with the distribution.
-- * Neither the name of the David Baumgartner nor the
--   names of its contributors may be used to endorse or promote products
--   derived from this software without specific prior written permission.

-- THIS SOFTWARE IS PROVIDED BY THE REGENTS AND CONTRIBUTORS ``AS IS'' AND ANY
-- EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
-- WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
-- DISCLAIMED. IN NO EVENT SHALL THE REGENTS AND CONTRIBUTORS BE LIABLE FOR ANY
-- DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
-- (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
-- LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
-- ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
-- (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
-- SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 
module DarcsAPI (	showTags,
					showDate,
					showAuthor,
					showLastCommitDiff ) where
	import Darcs.Repository ( readRepo, withRepositoryDirectory, RepoJob(..) )
	import System.IO.Unsafe (unsafeDupablePerformIO)
	import Darcs.Patch.Set ( tags )
	import Darcs.Patch.Info
	import System.Time
	import System.Locale
	import Data.String.Utils (split)

	showTags :: String -> IO String
	showTags repository =
		withRepositoryDirectory [] repository $ RepoJob $ \repository -> do
			patches <- readRepo repository
			return $ head (map parseTags (tags patches))
		where
			parseTags :: PatchInfo -> String
			parseTags x = case piTag x of
					Just tag ->
						tag
					Nothing ->
						"There's no tag for this repository" 

	showDate :: String -> IO CalendarTime
	showDate repository =
		withRepositoryDirectory [] repository $ RepoJob $ \repository -> do
			patches <- readRepo repository
			return $ head (map parseTags (tags patches))
		where
			parseTags :: PatchInfo -> CalendarTime
			parseTags x = piDate x

	showLastCommitDiff :: String -> IO String
	showLastCommitDiff repository = 
		withRepositoryDirectory [] repository $ RepoJob $ \repository -> do
			patches <- readRepo repository
			return $ last (map parseTags (tags patches))
		where
			parseTags :: PatchInfo -> String
			parseTags x = formatTime $ timeDiffToString $ (diffClockTimes (unsafeDupablePerformIO getClockTime) (toClockTime $ piDate x)) 
			formatTime ftime
					| btime <= 0 = "just now"
					| btime <= 1 = "a second"
					| btime <= 59 = (show $ round btime) ++ " seconds"
					| btime <= 119 = "a minute"
					| btime <= 3540 = (show $ round (btime/60)) ++ " minutes"
					| btime <= 7100 = "an hour"
					| btime <= 82800 = (show $ round ((btime+99)/3600)) ++ " hours"
					| btime <= 172000 = "a day"
					| btime <= 518400 = (show $ round ((btime+800)/(60*60*24))) ++ " days"
					| btime <= 1036800 = "a week"
					| otherwise = (show $ round ((btime+180000)/(60*60*24*7))) ++ " weeks"
				where 
					btime = read (head (split " " ftime)) :: Float

	showAuthor :: String -> IO String
	showAuthor repository =
		withRepositoryDirectory [] repository $ RepoJob $ \repository -> do
			patches <- readRepo repository
			return $ last (map parseTags (tags patches))
		where
			parseTags :: PatchInfo -> String
			parseTags x = piAuthor x