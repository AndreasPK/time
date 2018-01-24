module Test.Format.ISO8601(testISO8601) where

import Data.Ratio
import Data.Time
import Data.Time.Format.ISO8601
import Test.QuickCheck.Property
import Test.Tasty
import Test.Tasty.HUnit
import Test.Tasty.QuickCheck hiding (reason)
import Test.TestUtil
import Test.Arbitrary()


readShowProperty :: (Eq a,Show a) => Format a -> a -> Property
readShowProperty fmt val = case formatShowM fmt val of
    Nothing -> property Discard
    Just str -> let
        found = formatParseM fmt str
        expected = Just val
        in property $ if expected == found then succeeded else
            failed {reason = show str ++ ": expected " ++ (show expected) ++ ", found " ++ (show found)}

readBoth :: NameTest t => (FormatExtension -> t) -> [TestTree]
readBoth fmts =
    [
        nameTest "extended" $ fmts ExtendedFormat,
        nameTest "basic" $ fmts BasicFormat
    ]

readShowProperties :: (Eq a,Show a,Arbitrary a) => (FormatExtension -> Format a) -> [TestTree]
readShowProperties fmts = readBoth $ \fe -> readShowProperty $ fmts fe

newtype Durational t = MkDurational t

instance Show t => Show (Durational t) where
    show (MkDurational t) = show t

instance Arbitrary (Durational CalendarDiffDays) where
    arbitrary = do
        mm <- choose (-10000,10000)
        dd <- choose (-40,40)
        return $ MkDurational $ CalendarDiffDays mm dd

instance Arbitrary (Durational CalendarDiffTime) where
    arbitrary = let
        limit = 40 * 86400
        picofactor = 10 ^ (12 :: Int)
        in do
            mm <- choose (-10000,10000)
            ss <- choose (negate limit * picofactor, limit * picofactor)
            return $ MkDurational $ CalendarDiffTime mm $ fromRational $ ss % picofactor

testReadShowFormat :: TestTree
testReadShowFormat = nameTest "read-show format"
    [
        nameTest "calendarFormat" $ readShowProperties $ calendarFormat,
        nameTest "yearMonthFormat" $ readShowProperty $ yearMonthFormat,
        nameTest "yearFormat" $ readShowProperty $ yearFormat,
        nameTest "centuryFormat" $ readShowProperty $ centuryFormat,
        nameTest "expandedCalendarFormat" $ readShowProperties $ expandedCalendarFormat 6,
        nameTest "expandedYearMonthFormat" $ readShowProperty $ expandedYearMonthFormat 6,
        nameTest "expandedYearFormat" $ readShowProperty $ expandedYearFormat 6,
        nameTest "expandedCenturyFormat" $ readShowProperty $ expandedCenturyFormat 4,
        nameTest "ordinalDateFormat" $ readShowProperties $ ordinalDateFormat,
        nameTest "expandedOrdinalDateFormat" $ readShowProperties $ expandedOrdinalDateFormat 6,
        nameTest "weekDateFormat" $ readShowProperties $ weekDateFormat,
        nameTest "yearWeekFormat" $ readShowProperties $ yearWeekFormat,
        nameTest "expandedWeekDateFormat" $ readShowProperties $ expandedWeekDateFormat 6,
        nameTest "expandedYearWeekFormat" $ readShowProperties $ expandedYearWeekFormat 6,
        nameTest "timeOfDayFormat" $ readShowProperties $ timeOfDayFormat,
        nameTest "hourMinuteFormat" $ readShowProperties $ hourMinuteFormat,
        nameTest "hourFormat" $ readShowProperty $ hourFormat,
        nameTest "withTimeDesignator" $ readShowProperties $ \fe -> withTimeDesignator $ timeOfDayFormat fe,
        nameTest "withUTCDesignator" $ readShowProperties $ \fe -> withUTCDesignator $ timeOfDayFormat fe,
        nameTest "timeOffsetFormat" $ readShowProperties $ timeOffsetFormat,
        nameTest "timeOfDayAndOffsetFormat" $ readShowProperties $ timeOfDayAndOffsetFormat,
        nameTest "localTimeFormat" $ readShowProperties $ \fe -> localTimeFormat (calendarFormat fe) (timeOfDayFormat fe),
        nameTest "dayAndTimeFormat" $ readShowProperties $ \fe -> dayAndTimeFormat (calendarFormat fe) (timeOfDayFormat fe),
        nameTest "timeAndOffsetFormat" $ readShowProperties $ \fe -> timeAndOffsetFormat (timeOfDayFormat fe) fe,
        nameTest "durationDaysFormat" $ readShowProperty $ durationDaysFormat,
        nameTest "durationTimeFormat" $ readShowProperty $ durationTimeFormat,
        nameTest "alternativeDurationDaysFormat" $ readBoth $ \fe (MkDurational t) -> readShowProperty (alternativeDurationDaysFormat fe) t,
        nameTest "alternativeDurationTimeFormat" $ readBoth $ \fe (MkDurational t) -> readShowProperty (alternativeDurationTimeFormat fe) t,
        nameTest "intervalFormat" $ readShowProperties $ \fe -> intervalFormat (localTimeFormat (calendarFormat fe) (timeOfDayFormat fe)) durationTimeFormat,
        nameTest "recurringIntervalFormat" $ readShowProperties $ \fe -> recurringIntervalFormat (localTimeFormat (calendarFormat fe) (timeOfDayFormat fe)) durationTimeFormat
    ]

testShowFormat :: String -> Format t -> String -> t -> TestTree
testShowFormat name fmt str t = nameTest (name ++ ": " ++ str) $
    assertEqual "" (Just str) $ formatShowM fmt t

testShowFormats :: TestTree
testShowFormats = nameTest "show format"
    [
        testShowFormat "durationDaysFormat" durationDaysFormat "P0D" $ CalendarDiffDays 0 0,
        testShowFormat "durationDaysFormat" durationDaysFormat "P4Y" $ CalendarDiffDays 48 0,
        testShowFormat "durationDaysFormat" durationDaysFormat "P7M" $ CalendarDiffDays 7 0,
        testShowFormat "durationDaysFormat" durationDaysFormat "P5D" $ CalendarDiffDays 0 5,
        testShowFormat "durationDaysFormat" durationDaysFormat "P2Y3M81D" $ CalendarDiffDays 27 81,
        testShowFormat "durationTimeFormat" durationTimeFormat "P0D" $ CalendarDiffTime 0 0,
        testShowFormat "durationTimeFormat" durationTimeFormat "P4Y" $ CalendarDiffTime 48 0,
        testShowFormat "durationTimeFormat" durationTimeFormat "P7M" $ CalendarDiffTime 7 0,
        testShowFormat "durationTimeFormat" durationTimeFormat "P5D" $ CalendarDiffTime 0 $ 5 * nominalDay,
        testShowFormat "durationTimeFormat" durationTimeFormat "P2Y3M81D" $ CalendarDiffTime 27 $ 81 * nominalDay,
        testShowFormat "durationTimeFormat" durationTimeFormat "PT2H" $ CalendarDiffTime 0 $ 7200,
        testShowFormat "durationTimeFormat" durationTimeFormat "PT3M" $ CalendarDiffTime 0 $ 180,
        testShowFormat "durationTimeFormat" durationTimeFormat "PT12S" $ CalendarDiffTime 0 $ 12,
        testShowFormat "durationTimeFormat" durationTimeFormat "PT1M18.77634S" $ CalendarDiffTime 0 $ 78.77634,
        testShowFormat "durationTimeFormat" durationTimeFormat "PT2H1M18.77634S" $ CalendarDiffTime 0 $ 7278.77634,
        testShowFormat "durationTimeFormat" durationTimeFormat "P5DT2H1M18.77634S" $ CalendarDiffTime 0 $ 5 * nominalDay + 7278.77634,
        testShowFormat "durationTimeFormat" durationTimeFormat "P7Y10M5DT2H1M18.77634S" $ CalendarDiffTime 94 $ 5 * nominalDay + 7278.77634,
        testShowFormat "durationTimeFormat" durationTimeFormat "P7Y10MT2H1M18.77634S" $ CalendarDiffTime 94 $ 7278.77634,
        testShowFormat "durationTimeFormat" durationTimeFormat "P8YT2H1M18.77634S" $ CalendarDiffTime 96 $ 7278.77634,
        testShowFormat "alternativeDurationDaysFormat" (alternativeDurationDaysFormat ExtendedFormat) "P0001-00-00" $ CalendarDiffDays 12 0,
        testShowFormat "alternativeDurationTimeFormat" (alternativeDurationTimeFormat ExtendedFormat) "P0000-00-01T00:00:00" $ CalendarDiffTime 0 86400
    ]

testISO8601 :: TestTree
testISO8601 = nameTest "ISO8601"
    [
        testShowFormats,
        testReadShowFormat
    ]
