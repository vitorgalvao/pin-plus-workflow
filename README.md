# <img src='Workflow/icon.png' width='45' align='center' alt='icon'> Pin Plus Alfred Workflow

Interact with your Pinboard bookmarks

<a href='https://alfred.app/workflows/vitor/pin-plus'>⤓ Install From the Alfred Gallery</a>

## Usage

Add a new bookmark to your [Pinboard](https://pinboard.in) account via the Add New Keyword (default: `pa`).

![Add bookmark](Workflow/images/about/pa.png)

![Browser GUI to add bookmark](Workflow/images/about/gui.png)

Search all bookmarks with the Show All Keyword (default: `pin`) or only the unread ones via the Show Unread Keyword (default: `pun`). Actioning an unread bookmark can archive or delete it if the option is set in the [Workflow’s Configuration](https://www.alfredapp.com/help/workflows/user-configuration/).

![Showing bookmarks matching alfr](Workflow/images/about/pin.png)

* <kbd>⏎</kbd>: Open in web browser.
* <kbd>⇧</kbd><kbd>⏎</kbd>: Open on Pinboard’s website.
* <kbd>⌥</kbd><kbd>⏎</kbd>: Copy URL.
* <kbd>⌘</kbd><kbd>⏎</kbd>: Download the video on the page. Requires [DownMedia](https://alfred.app/workflows/vitor/download-media/).
* <kbd>⌃</kbd>: Show tags.
* <kbd>fn</kbd>: Show description.

Configure the [Hotkeys](https://www.alfredapp.com/help/workflows/triggers/hotkey/) as a shortcut to add bookmarks, add the current browser tab as an unread bookmark, or open a random unread bookmark.

Bookmarks are refetched if the local data is old. If necessary, an immediate cache rebuild can be forced with the `:pinplusforceupdate` keyword.
