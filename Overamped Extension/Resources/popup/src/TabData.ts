export interface TabData {
  ignoredHostnames: string[]
  permittedOrigins: string[] | undefined
  readonly currentTab: browser.tabs.Tab
  readonly canonicalURL: string | undefined
}

export interface GoogleTabData extends TabData {
  readonly replacedLinksCount: number
}

export function dataIsGoogleTabData(data: TabData): data is GoogleTabData {
  return Object.prototype.hasOwnProperty.call(data, "replacedLinksCount")
}
