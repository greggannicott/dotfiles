# Web Apps

## About

This directory contains a series of scripts which open certain web pages in Chrome.

This method has been used rather than the built-in Web App functionality in Chrome as it does not support creating multiple web-apps on the same domain, which was required to use Notion in this way.

## Creating a new Web App

### Creating Shell Script

* Duplicate one of the existing scripts in this directory.
* Update the `--app` URL to match the page you want to open.
* Set a unique `--user-data-dir` to ensure that the web app has its own profile.
* Set the permissions on the new script to be executable:

```zsh
chmod +x <script_name>
```

### Making it into an App

We use Automator to create a new app which runs the shell script.

* Open Automator from your Applications folder
* Create a new document and select "Application" as the type
* Search for "Run Shell Script" in the actions library and drag it to the workflow area
* Configure the shell script action:
   * Shell: /bin/zsh
   * Pass input: as arguments
   * In the script area, enter the path to your script:
     ```
     /Users/greggannicott/web-apps/<script_name>
     ```
     (Replace with the absolute path to your script)
* Save the application somewhere convenient (like Applications folder)
* Optionally, you can add a custom icon by:
   * Finding an image you want to use
   * Selecting the Automator app you created in Finder
   * Press Cmd+I to open Info panel
   * Drag your image onto the icon in the top-left of the Info panel

