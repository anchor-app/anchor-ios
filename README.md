# Anchor 

## Overview

## Development Environment

### Parse Setup
The build process reads the Parse configuration from a `.env` file you place in the root directory with this format:
```
PARSE_APPLICATION_ID=<your application ID>
PARSE_CLIENT_KEY=<your client key>
PARSE_SERVER=<your server URL>
```

Be sure to set up this file before attempting to build.

### Local Parse Setup

If you want to have your app hit a local Parse server, then set `PARSE_SERVER` and `PARSE_APPLICATION_ID` as you configured it on your Parse server. Put whatever you want for `PARSE_CLIENT_KEY`, it doesn't matter.

You'll also need to tell iOS that it's ok for it to hit non-HTTPS endpoints. Open `Info.plist` and add this to the primary `<dict>`:
```
       <key>NSAppTransportSecurity</key>
       <dict>
               <key>NSAllowsArbitraryLoads</key>
               <true/>
       </dict>
```

Please don't commit this as it makes the app less secure.

## Usage

### Connecting to FullContact
Anchor works with FullContact to manage your contacts. You need both a user account at FullContact and an API v3 application registered with them. See https://api.fullcontact.com/v3/docs/ for information about how to register an application and receive a client ID and client secret.

To connect your FullContact app to Anchor:
* Tap on the Settings gear.
* Tap on Manage Integrations
* Type your client ID and client secret into the text boxes.
* Tap Authorize FullContact.
* This will open a web browser and prompt you to log in to FullContact. Do so.
* If you have the FullContact app installed, you will be prompted to open the app. Do so.
* Now you will appear to be at a dead end, since the FullContact app will just sit there. Ignore this and go back to Safari.
* You will be presented with a choice of whether to authorize FullContact. Tap the Authorize button.* Finally, you'll be prompted to return to Anchor. Do so.
* You should see a green confirmation dialog at the top of the Anchor screen.

You probably should explicitly sync your contacts at this point, using the Sync Contacts button on the same Manage Integrations screen.

### Editing Contacts

I made an explicit choice to not allow editing names, emails, etc. of contact
objects and having those edits synced by to FullContact. You should use
FullContact for that. I did this because keeping all the data in sync is kind
of pain and this app should not be reimplementing FullContact functionality.

## Pattterns (or iOS 101)

Because this app will be built upon and maintained by non-iOS developers, let
me add some color about the various patterns used in the codebase in hopes of
shortening ramp-up time.

### Threading

You should only make UI modifications in iOS on the main thread. This includes
pretty much everything you can do to a view, including reloading all the data
in a table view, `[tableView reloadData]`. Because of this, you'll often see
async callbacks dispatch UI code to the main thread like this:

```
dispatch_async(dispatch_get_main_queue(), ^{
  doSomeUIWork();
});
```

The other frequent use of `dispatch_async` (which is part of a family of
concurrency products called Grand Central Dispatch or GCD) is as a simple way
to enforce serialization of data access to a shared resource, as a replacement
for any kind of traditional locking scheme. If a class author makes it a
convention to access a particular data structure on a particular queue (i.e.,
thread, though there may not be a 1:1 mapping between queues and threads), then
all accesses are guaranteed to be mutually exclusive, though not guaranteed to
be in a particular order.

### Delegates

A frequently used pattern in iOS is delegation via protocolized objects. In its
most frequently seen form, it's just callbacks without having to tightly couple
the types of the objects involved. For example, when the UI that showsn an
annotation's key and value, called `ARKeyValueTableViewCell`, receives a tap on
the dropdown that allows changes to the key, it doesn't make sense for it to
handle displaying the key selection view---that's too much coupling. Instead,
it delegates that action by calling a callback,
`(void)cell:(ARKeyValueTableViewCell *)cell
didTapKeySelectorForViewModel:(ARKeyValueViewModel *)viewModel`, on whatever
object is in its `delegate` property.

This pattern is frequently used across the codebase to decouple views from
controllers.

### Data Sources

`UITableView` is the bread and butter of an iOS developer: it's what displays a
vertical list of stuff, like the schedule view and the contact detail view and
the search results view and the setting screen and the ... basically
everything. `UITableView` works by calling a data source and delegate object to
ask it questions like, how many sections are there, how many rows in each
section, what is the `UITableViewCell` (the actual view) for this row, etc.
Answering all these questions in one class gets really nasty: you'd be mixing
all the settings code together for example, or all the notes and annotation
code together for the Contact detail view.

Instead, you can capture those questions in one controller and distribute them
to different "data source" objects, one per section you want to display. In the
Contact detail example, we capture those questions in
`ARContactDetailViewController` and have a data source for the header (to
display the name, etc.), and a data source for the notes section and one for
the annotations section.

To make things easier, I'm currently assuming each data source object only
provides one table view section. This simplifies math since rows are specified
in `{ section, row }` tuples (called `NSIndexPath` objects). In a big project,
I would write some kind of aggregated data source class that supports multiple
sections and does the math to map real table view sections to these shadow data
source sections. Whatevs.

## Security

You should familiarize yourself with Parse's security model by reading the blog articles starting at http://blog.parse.com/learn/engineering/parse-security-i-are-you-the-key-master/

Objects created inside Anchor are only visible to the user that created them and that user's team, identified by the user's `teamId` field. This is achieved via Parse's roles functionality, where `teamId` is the role identifier.

When you're ready to take this app into production, you should...
* Disable the creation of new classes.
* Disable the Add Fields permission on all classes, so users cannot create enew columns in the database.

Read more about how to do these operations at http://blog.parse.com/learn/engineering/parse-security-ii-class-hysteria/
