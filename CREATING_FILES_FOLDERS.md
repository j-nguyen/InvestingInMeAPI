# Creating Files & Folders on Vapor

## Method 1 - Terminal

I prefer terminal, when I have to create both folders, and files, however you can separate them.

### Files

For files, just use the `touch` command to create the file. For example, if I want to have a file in the Models folder I would do:

`touch Sources/App/Models/MyModelName.swift`, where your modelName is whatever you like your file to be called.

Once that's complete, run `vapor xcode -y` to regenerate the files

### Folders

For folders, it's very similar to files, except you're using the `mkdir` command instead of `touch`. If I want to create a folder in `Sources/App`, I would do:

`mkdir Sources/App/MyFolder` Where `MyFolder` is the folder name you'd like to call it.

## Method 2 - XCode

XCode has an awful way of getting folders, since they used to be referenced, but I don't think that's the case anymore (Not sure).

### Files

For files, just right-click on the folder you want, and click on create a new file, and make sure it's a swift file. Make sure you set the target as `App`. If you forget, you can open up the side-bar on the right, and you can set the target membership like so.

### Folders

Sometimes this is a bit glitchy. However, to create a folder, right-click on where you'd like the folder to be saved. For example, if I want my folder in `App`, I would right click `App` and create a new group. Change the naming to what you would like.

Sometimes, this does not work, and it'll stay as `New Group`. What you need to do is open up Finder and rename that folder right there, and repoint the path to that file again back in XCode. I **do not** recommend doing it this way, and would prefer to create the folder through terminal