#!/usr/bin/osascript -l JavaScript

const bookmarkletCode = "q=location.href;if(document.getSelection){d=document.getSelection();}else{d='';};p=document.title;void(open('https://pinboard.in/add?showtags=yes&url='+encodeURIComponent(q)+'&description='+encodeURIComponent(d)+'&title='+encodeURIComponent(p),'Pinboard','toolbar=no,scrollbars=yes,width=750,height=700'));"
const frontAppName = Application('System Events').applicationProcesses.where({ frontmost: true }).name()[0]
const frontApp = Application(frontAppName)

const webkitVariants = ["Safari", "Webkit", "Orion"]
const chromiumVariants = ["Google Chrome", "Chromium", "Opera", "Vivaldi", "Brave Browser", "Microsoft Edge", "Arc"]

if (webkitVariants.some(appName => frontAppName.startsWith(appName))) {
  frontApp.doJavaScript(bookmarkletCode, { in: frontApp.windows[0].currentTab })
} else if (chromiumVariants.some(appName => frontAppName.startsWith(appName))) {
  frontApp.windows[0].activeTab.execute({ javascript: bookmarkletCode })
} else {
  throw new Error(`${frontAppName} is not a supported browser: ${webkitVariants.concat(chromiumVariants).join(", ")}`)
}
