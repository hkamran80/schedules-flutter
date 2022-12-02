# Release Notes

## 1.0.4

**Unreleased**

- Switch to [`go_router`](https://pub.dev/packages/go_router) (#51)

## 1.0.3

**Released to iOS on November 22, Android on November 24, 2022**

- Sort schedules list alphabetically (#42)
- Add widget for schedule card (#43)
- Add location support (#44)
- Switch to rounded rectangle buttons (#45)
- Move import toasts to the bottom (#46)
- Add off day support (#47)
- Add override support (#48)
- Switch to the new `cfg-schedules.unisontech.org` configuration host

## 1.0.2

**Released to iOS on November 17, Android on November 20, 2022**

- Fix period loading system (#39)

## 1.0.1

**Released to iOS on November 17, Android on November 20, 2022**

- Fix schedule periods bug (periods would be incorrect for that day) (#31)
- Add schedule request form (#25)
- Changed feedback repository issues link to form (#5)
- Add a link to the Discord server (#29)
- Add padding to the bottom of the home and about screens
- Reduce text size for the header on the home screen (#26)

## 1.0.0

**Released to iOS on November 14, Android on November 15, 2022**

- Fix text selection interface (#16)
- Enable notification toggle in settings
- Add network timeout (five seconds)
- Switch to Lucide Icons (#10)
- Add a credit
- Add schedule variant support (#11)
- Improve period name widget generation with `Builder`
- Remove the What's New sheet
- Switch to a single source of truth model
- Add import/export functionality (#6)
- Load new period names immediately (#9)

## 0.2.1 (August 20, 2022)

- Add notifications (intervals, days, periods)
- Improve load time, fix default schedule bug
- Add custom period names support
- Update J. Quam's credit URL

## 0.2.0 (August 13, 2022)

- Add support for offline loading
- Add credits
- Switch timetable button to only show on valid days
- [BUG] Add default schedule support
- Switch to Material 3

## 0.1.0 (May 2, 2022)

- Add remote schedule loading
- Add the main period calculation
- Add the timetable
- Add Sentry.io for debugging (opt-in only) (please opt in)
