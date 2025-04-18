# Jasmine Studio architecture notes

## Initial design goals

### Primary

* Provide a nice UI for running tests that have lengthy failure output. For
  example, testing-library failure messages can include hundreds of lines of
  pretty-printed DOM. Reading the raw ConsoleReporter output of those is
  tedious and error-prone. It's very easy to scroll past the top or bottom of
  one failure and into the next.
* Provide an easy way to run subsets of the overall suite without manually
  adding fit/fdescribe, e.g.:
  * Run a particular spec or suite
  * Repeat the last run
  * Re-run failed specs
  * Run a broader subset than the last run
* Fit, and be usable, in approximately the same width as an 80 column terminal.
* Native Mac OS UI, or close enough that I can't tell the difference.
* Low maintenance cost. In particular, Jasmine Studio shouldn't be tied to
  dependencies that require frequent or difficult updates. Minimizing ongoing
  maintenance cost, *especially* the kind that's unpredictable and can't be
  deferred, is more important than minimizing initial development effort.

### Nice to have

* Potential for future porting to other operating systems
* Good performance with large and/or slow test suites. In particular, you
  shouldn't have to wait for a full run before being able to run a subset.

### Out of scope, at least for now

* Actually porting to anything other than Mac OS.
* Actually porting to Mac OS versions older than Sequoia (15.x).
* Compatibility with anything but the latest versions of the jasmine and
  jasmine-core packages.
* Support for running specs in a browser. An enhanced version of the
  jasmine-core HTML reporter would probably be a better way to meet the same
  UX goals in a browser envirionment.
* Debugger support.
* Attracting contributions from other developers.

## Platform choices

### UI toolkit

A Cocoa/AppKit application seems like a good fit for those goals. Using the
native toolkit seems like the easiest way to deliver a UI that truly looks and
feels native. It also opens up the possibility of porting to Linux and Windows
later on via GNUStep. (Not a certainty, though: GNUStep documentation about
Cocoa compatibility is sparse and extremely out of date, so it would be easy to
depend on something newer that GNUStep doesn't provide.) Using SwiftUI would
eliminate that possibility. Additionally, experience reports from developers I
know who have recently worked with SwiftUI have not been positive. It appears
to still be in a very rough state. Building something like Jasmine Studio in
SwiftUI would be possible, but not high on my list of things to do for fun in
my free time. Cocoa/Appkit also has drawbacks -- in particular, the more recent
iterations are very poorly documented -- but the body of quality third party
documentation and working example code is much larger.

### Objective-C or Swift

As of 2021 nobody was working on Swift interop for GNUStep, and I can find no
more recent discussion. So using Swift + Cocoa would rule out porting to
anything other than Mac OS for the foreseeable future. Objective-C's major
drawbacks are its relative unpopularity, lack of type safety, and lack of
compile-time null safety. Popularity is a non-issue in this case. Swift's
compile-time null safety is highly desirable feature in general, but it
provides relatively little benefit in a Cocoa application that's mostly GUI and
little underlying business logic.

I don't have a strong personal preference for one language over the other, so
it seems worth going with Objective-C even if only to preserve the possibility
of porting later on.
