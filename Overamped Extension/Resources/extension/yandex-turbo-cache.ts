import openURL from "./openURL"

export default function redirectYandexTurboCache(
  ignoredHostnames: string[],
): Promise<void> {
  const canonicalElement = document.head.querySelector(
    "link[rel~='canonical'][href]",
  ) as HTMLLinkElement | null

  if (!canonicalElement) {
    console.debug("Couldn't find canonical URL to redirect to")
    return Promise.resolve()
  }

  const canonicalURL = new URL(canonicalElement.href)

  openURL(canonicalURL, ignoredHostnames, true, "Yandex Turbo", "replace")

  return Promise.resolve()
}
