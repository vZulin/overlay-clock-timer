# Time Format Display Contract

## Scope

This contract defines user-visible Clock, Timer, latest Loop, and preference
behavior for the time format toggle.

## Formats

- Standard format: `HH:mm:ss.SSS`.
- Epoch milliseconds format:
  - Clock mode: 13 decimal digits representing milliseconds since the Unix
    epoch.
  - Timer mode: 13 decimal digits representing elapsed milliseconds from zero,
    left-zero-padded when shorter than 13 digits.
- Epoch milliseconds strings do not contain `.`, `:`, spaces, signs, grouping
  separators, or locale-specific digits.

## Clock Display

- Default format is `HH:mm:ss.SSS`.
- When epoch milliseconds is selected, Clock mode displays current system time
  as epoch milliseconds.
- Switching format does not change the system clock source.
- System clock changes are reflected in Clock mode using the selected format.

## Timer Display

- Reset Timer in standard format displays `00:00:00.000`.
- Reset Timer in epoch milliseconds format displays `0000000000000`.
- Running Timer in epoch milliseconds format displays elapsed milliseconds as a
  13-digit value.
- Switching format while the timer runs must not pause, reset, restart, or
  delay the timer.
- Switching format while paused must not start the timer.
- Stop/Reset clears elapsed state and latest loop state exactly as before.

## Latest Loop Display

- Latest loop stores the captured elapsed moment.
- Format switching may reformat the visible latest loop string.
- Format switching must not change the captured elapsed value.

## Preference Behavior

- The selected format persists across app relaunches.
- Missing, corrupted, or unknown persisted values fall back to standard format.
- The format preference is local to the Mac.

## Acceptance Checks

- Clock can switch from `HH:mm:ss.SSS` to 13-digit epoch milliseconds and back.
- Timer can switch formats while reset, running, and paused.
- During a 60-second timer run with at least 10 format switches, final elapsed
  time remains within the existing 50 ms timer accuracy target.
- Old input logging rows and log lines are not part of this display contract;
  they are covered by the logging contract.
