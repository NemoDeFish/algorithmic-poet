--  File       : Proj2.hs
--  Author     : Lim Si Yong
--  Purpose    : Implementation of functions for generating distinct poems and 
--               haikus from given wordlist based on specified syllable counts.
--
--  The purpose of this file is to create poems and haikus using a specified
--  list of words. By leveraging syllable counts, it ensures that the generated
--  poems meet traditional poetic structures while maintaining distinction in
--  words. This is done by first filling the poems based on the syllable counts
--  using the fillInPoem function, which takes a list of words and a 
--  corresponding list of syllable counts. It generates all possible 
--  combinations of words where each word matches the exact syllable 
--  requirement. Next, this function is then used to generate all haikus from 
--  the provided wordlist, where a traditional haiku consists of three lines 
--  with a syllable pattern of 5-7-5. This function explores all combinations 
--  of words to create valid haikus that adhere to this structure.

module Proj2 
  (fillInPoem, generateAllHaikus)
where

import ProblemSetup (Poem, PoemMetric(..), PoemScore)
import Words (syllables)
import Data.Maybe (fromJust)
import Data.List (subsequences, nub, permutations, uncons, (\\))
import qualified Data.Map as M

-- | Takes a list of words and a corresponding list of syllable counts. It
-- generates all possible combinations of words where each word matches the 
-- exact syllable requirement.
-- @param wordlist      : The list of words to draw from.
--        wordSyllables : The corresponding list of syllable counts.
-- @return : All possible combinations of words that match the syllables.
fillInPoem :: [String] -> [Int] -> [Poem]
fillInPoem wordlist wordSyllables =
    -- We first generate buckets of words from the wordlist.
    -- Then we pass in the required parameters to generate all combinations.
    -- Initially, the number of words used in the poem is an empty list [].
    generateCombinations wordSyllables (bucketWords wordlist) []

-- | Generates all possible unused word combinations based on syllable pattern
-- @param (n:ns)   : The corresponding list of syllable counts.
--        buckets  : The list of tuples of syllable count to words.
--        used     : The list of already used words.
-- @return : All possible combinations of words where each word matches each
--           syllable requirement.
generateCombinations :: [Int] -> [(Int, [String])] -> [String] -> [[String]]
-- Base case: if no syllable counts, return a list with empty combination.
generateCombinations [] _ _ = [[]]
generateCombinations (n:ns) buckets used =
    [ word:combo |
    -- Find words with the current syllable count 'n' that haven't been used.
    word <- findWordsBySyllable n buckets used,
    -- Recursively generate combinations for the remaining syllable counts.
    combo <- generateCombinations ns buckets (word:used)]

-- | Finds words by syllable count, excluding already used words.
-- @param n        : The required syllable count.
--        buckets  : The list of tuples of syllable count to words.
--        used     : The list of already-used words.
-- @return : A list of unused words from that specific syllable bucket.
findWordsBySyllable :: Int -> [(Int, [String])] -> [String] -> [String]
findWordsBySyllable n buckets used =
    [word |
    (syllables, allWords) <- buckets,  -- Extract the buckets
    syllables == n,                    -- Find bucket of syllable count
    word <- allWords,                  -- Extract all words from bucket
    word `notElem` used]               -- Eliminate used words

-- | Buckets words from a wordlist by their syllable counts.
-- @param wordlist : The list of words to draw from.
-- @return : The list of tuples of syllable count to words.
bucketWords :: [String] -> [(Int, [String])]
-- Use M.toList to convert from a map to a list of tuples so that it
-- is easier to work with in later stages.
bucketWords wordlist = M.toList $ foldr insertWord M.empty wordlist
    where insertWord word accumulator =
              -- Use 'maybe' to remove the Maybe wrapper in the case where the
              -- word is not found in dictionary. In the case where it meets a
              -- Nothing, it will just default to the accumulator.
              maybe accumulator
              -- Add each newly-inserted word into the existing map
              -- 'accumulator' as a list containing the current word.
              (\syllable -> M.insertWith (++) syllable [word] accumulator)
              (syllables word)

-- | Generates all possible combainations of valid haikus from the provided
--   wordlist with a syllable pattern of 5-7-5.
-- @param wordlist : The list of words to draw from.
-- @return : A list of poems of all possible combainations of valid haikus.
generateAllHaikus :: [String] -> [Poem]
-- Use foldr to recursively feed each of the tailPattern and use the combined 
-- result on the next syllable count.
generateAllHaikus wordlist = foldl (findComb wordlist) base tailPattern
    where pattern = [5, 7, 5]
          -- Separate the required pattern into the head and the tail to 
          -- compute the base case separately.
          Just (headPattern, tailPattern) = uncons pattern
          -- Compute the base case for foldr
          base = concatMap (fillInPoem wordlist) partition
          partition = partitions (syllableCount wordlist) headPattern

-- | Generates all distinct permutations of subsets of countList that sum to
--   the given target.
-- @param countList : A list of integers to find subsets from.
--        target    : The target sum for the subsets.
-- @return : A list of distinct permutations of subsets that sum to 'target'.
partitions :: [Int] -> Int -> [[Int]]
partitions countList target =
    let subsets = combinationsSumTo target countList
        permutedSubsets = concatMap permutations subsets
    in distinctElements permutedSubsets

-- | Gets the distinct elements
-- @param  : The intial duplicated list.
-- @return : The list of distinct elements.
distinctElements :: (Eq a) => [a] -> [a]
distinctElements = nub

-- | Finds all combinations that sum to a specific target.
-- @param target    : The target sum.
--        countList : The list of syllables of the wordlist.
-- @return : The list of tuples of syllable count to words.
combinationsSumTo :: (Eq a, Num a) => a -> [a] -> [[a]]
combinationsSumTo target countList = 
    filter ((== target) . sum) (subsequences countList)

-- | Maps a list of words to their corresponding syllables.
-- @param : The list of words to draw from.
-- @return : The list of syllable counts.
syllableCount :: [String] -> [Int]
syllableCount = map (fromJust . syllables)

-- | Helper function for generateAllHaikus to find the remaining unused words 
--   in the wordlist, and for each unused word, we compute the possible 
--   combinations of the required syllable.Then combines the two lists.
-- @param wordlist : The list of words to draw from.
--        lineX    : A list of words in the first line.
--        count    : An integer of the syllable count for lineY.
-- @return : a combined list from the processing of lineX and lineY.
findComb :: [String] -> [Poem] -> Int -> [Poem]
findComb wordlist lineX count = combineLists lineX lineY
          -- Find all the words in the wordlist that are unused in lineX.
    where notLineX = map (wordlist \\) lineX
          -- For each of the unused words, we generate all the possible
          -- combinations based on the syllable count.
          lineY = map (\x -> concatMap (fillInPoem x) 
              $ partitions (syllableCount x) count) notLineX

-- | Combines two lists of lists of strings element-wise and produces a single 
--   list of lists of strings by concatenating corresponding elements.
-- @param xs : A list of lists of strings.
--        ys : A list of list of lists of strings.
-- @return : A list of lists of strings resulting from the element-wise
--           combination of the input lists.
combineLists :: [[String]] -> [[[String]]] -> [[String]]
-- For each pair of lists from the first and second input lists, concatenate
-- the first list's sublist with each element of the corresponding sublist in
-- the second list. Continues recursively until all elements of the first list
-- have been processed.
combineLists (x:xs) (y:ys) = [x ++ elem | elem <- y] ++ combineLists xs ys
-- Base case: if either inputs is an empty list, return an empty list
combineLists _ _ = [] 