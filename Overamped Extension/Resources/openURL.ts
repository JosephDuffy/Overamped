import NativeAppCommunicator from "./NativeAppCommunicator"

export default function openURL(
  url: URL,
  ignoredHostnames: string[],
  action: "push" | "replace",
): boolean {
  // An array of hostnames that Overamped will never redirect
  const globallyIgnoredHostnames = [
    "www.thegate.ca", // Redirects to AMP Version when opened on iOS
  ]
  if (globallyIgnoredHostnames.includes(url.hostname)) {
    console.info(
      `Not redirecting to ${url} because ${url.hostname} is in the globally ignored hostnames`,
    )

    return false
  } else if (ignoredHostnames.includes(url.hostname)) {
    console.info(
      `Not redirecting to ${url} because ${url.hostname} is in the ignored hostnames`,
    )

    return false
  } else if (window.location.toString() === url.toString()) {
    console.info(
      `Not redirecting to ${url} because it is the same as the current page`,
    )

    return false
  } else {
    console.log(`Redirecting page to ${url.toString()}`)

    new NativeAppCommunicator().logRedirectedLink(url)

    switch (action) {
      case "push":
        window.location.assign(url.toString())
        break
      case "replace":
        window.location.replace(url.toString())
        break
    }

    return true
  }
}
