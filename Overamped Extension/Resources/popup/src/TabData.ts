export interface TabData {
  readonly ignoredHostnames: string[]
  readonly currentTab: browser.tabs.Tab
}

export interface GoogleTabData extends TabData {
  readonly replacedLinksCount: number
}

export function dataIsGoogleTabData(data: TabData): data is GoogleTabData {
  return Object.prototype.hasOwnProperty.call(data, "replacedLinksCount")
}
