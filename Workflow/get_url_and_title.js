#!/usr/bin/osascript -l JavaScript

const frontAppName = Application("System Events").applicationProcesses.where({ frontmost: true }).name()[0]
const frontApp = Application(frontAppName)

const webkitVariants = ["Safari", "Webkit", "Orion"]
const chromiumVariants = ["Google Chrome", "Chromium", "Opera", "Vivaldi", "Brave Browser", "Microsoft Edge", "Arc"]

if (webkitVariants.some(appName => frontAppName.startsWith(appName))) {
  frontApp.windows[0].currentTab.url() + "\t" + frontApp.windows[0].currentTab.name()
} else if (chromiumVariants.some(appName => frontAppName.startsWith(appName))) {
  frontApp.windows[0].activeTab.url() + "\t" + frontApp.windows[0].activeTab.name()
} else {
  throw new Error(`${frontAppName} is not a supported browser: ${webkitVariants.concat(chromiumVariants).join(", ")}`)
}
