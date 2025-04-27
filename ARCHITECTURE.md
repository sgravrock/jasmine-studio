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

## Project configuration

To run Jasmine, several pieces of information are needed:

* The path to the Node executable
* The path to the project root directory (the one that paths in the Jasmine
  config file will be evaluated relative to)
* The path to the Jasmine config file
* The path to the Jasmine executable

The path to the Node executable is needed because it's typically installed in a
nonstandard path, often via a version manager like nvm that allows the user to
switch between versions of Node. In a coommand line application that could be
handled by `execvp`, running `which node`, or other mechanisms that rely on the
`PATH` environment variable. But that won't work because GUI applications don't
inherit the user's shell environment. So it's necessary to ask the user.

The three Jasmine-related properties can be reduced to one: the path to the 
project root directory. That won't work in valid but unusual setups such as
multi-project monorepos and config files in nonstandard locations, but it's
probably fine to ignore those for the foreseeable future.

That leaves two pieces of information needed: the project root dir and the path
to Node. Jasmine Studio should interactively prompt for both of those at
startup. A command line launcher that takes a project root dir (or assumes the
current working dir), finds Node via `PATH`, and invokes Jasmine Studio might
also be a nice addition.

That suggests a startup sequence like this:

1. AppDelegate opens a project setup window.
2. Project setup window gives the user a chance to enter the project base dir
   and Node path.
3. When the user clicks OK, the paths are validated. If correct, the setup
   window is closed and the main window is opened.


## Runner UI structure

The runner UI will consist of a window with a toolbar, a tree view
(NSOutlineView), and a detail view for showing the output of individual specs.
The user will be able to run the entire suite or subsets of it by clicking
toolbar buttons or via a context menu on individual specs/suites. The basic
structure of Cocoa imposes a relatively large minimum set of UI
related objects:

* A window and associated controller (which could just be NSWindowController)
* A split view controller (master/detail)
* An outline view and controller
* An outline view data source (which might be one of the above objects)
* An outline view delegate (which might be one of the above objects)
* A detail view and controller

There are a couple of unusual things. Context menus don't follow the delegate/
data source pattern. Instead, they're implemented by subclassing the view they
originate from (in this case NSOutlineView). [Apple's example](https://developer.apple.com/documentation/appkit/navigating-hierarchical-data-using-outline-and-split-views?language=objc)
uses a custom delegate protocol to route the context menu construction to a 
controller. That makes sense and is reasonably tidy, although keeping the menu
construction in the view and invoking a delegate method when an item is clicked
would also be reasonable. Apple's sample also departs from a "by the book"
architecture in one other way: Toolbars are owned by windows and would normally
be managed by an NSWindowController subclass, Apple's example does it in the
window's root view controller instead. This cuts down on plumbing and 
indirection and does away with the need for a custom window controller.

Apple's example uses a mix of NSNotification and delegates to communicate among
the various controllers. The use of NSNotification removes some indirection, but
it would probably make it harder to have multiple windows running different
suites than if everything used delegates.

A reasonable design might look like:

* Stock NSWindowController
* Root view controller that handles:
  * initialization
  * showing the toolbar and responding to toolbar events
  * telling the detail view controller what to show in response to outline
    view events
  * initiating test runs in response to outline view and toolbar events
* Custom NSOutlineView subclass that implements context menus via a delegate
* Tree view controller that acts as delegate, data source, and context menu
  delegate for the outline view
* Detail view controller that shows results/output for the selected spec

