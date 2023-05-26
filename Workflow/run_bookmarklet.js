#!/usr/bin/osascript -l JavaScript

const bookmarkletCode = "q=location.href;if(document.getSelection){d=document.getSelection();}else{d='';};p=document.title;void(open('https://pinboard.in/add?showtags=yes&url='+encodeURIComponent(q)+'&description='+encodeURIComponent(d)+'&title='+encodeURIComponent(p),'Pinboard','toolbar=no,scrollbars=yes,width=750,height=700'));"
const frontmostAppName = Application('System Events').applicationProcesses.where({ frontmost: true }).name()[0]
const frontmostApp = Application(frontmostAppName)

const chromiumVariants = ["Google Chrome", "Chromium", "Opera", "Vivaldi", "Brave Browser", "Microsoft Edge", "Arc"]
const webkitVariants = ["Safari", "Webkit", "Orion"]

if (chromiumVariants.some(appName => frontmostAppName.startsWith(appName))) {
  frontmostApp.windows[0].activeTab.execute({ javascript: bookmarkletCode })
} else if (webkitVariants.some(appName => frontmostAppName.startsWith(appName))) {
  frontmostApp.doJavaScript(bookmarkletCode, { in: frontmostApp.windows[0].currentTab })
} else {
  throw new Error("You need a supported browser as your frontmost app")
}
