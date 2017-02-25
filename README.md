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
