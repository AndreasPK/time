# Change Log

## [1.9]
- new DayOfWeek type
- new CalendarDiffDays type
- new addLocalTime, diffLocalTime
- formatting: %Ez and %EZ for ±HH:MM format
- parseTimeM: use MonadFail constraint when supported
- parsing: reject invalid (and empty) time-zones with %z and %Z
- parsing: reject invalid hour/minute/second specifiers

## [1.8.0.4]
- Fix "show minBound" bug
- haddock: example for parseTimeM

## [1.8.0.3]
- Add "Quick start" documentation

## [1.8.0.2]
- Fix behaviour of %Q in format

## [1.8.0.1]
- Get building on 32 bit machine

## [1.8]
- Added SystemTime
- Data.Time.Format: allow padding widths in specifiers for formatting (but not parsing)
- Test: use tasty, general clean-up
- Test: separate out UNIX-specific tests, so the others can be run on Windows
- Clean up haddock.

## [1.7.0.1]
- Fix bounds issue in .cabal file

## [1.7]
- Data.Time.Clock.TAI: change LeapSecondTable to LeapSecondMap with Maybe type; remove parseTAIUTCDATFile

## [1.6.0.1]
- Get building with earlier GHC versions
- Set lower bound of base correctly

## [1.6]

### Added
- FormatTime, ParseTime, Show and Read instances for UniversalTime
- diffTimeToPicoseconds
- this change log

### Changed
- Use clock_gettime where available
- Read and Show instances exported in the same module as their types
- Fixed bug in fromSundayStartWeekValid
- Parsing functions now reject invalid dates
- Various documentation fixes

## [1.5.0.1]
