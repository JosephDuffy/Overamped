import openURL from "./openURL"
import Cookies from "universal-cookie"

export default function redirectInstallChecker(
  ignoredHostnames: string[],
): Promise<void> {
  return new Promise((resolve) => {
    const checkTokenElement = document.head.querySelector(
      "meta[name='overamped-check-token'][content]",
    ) as HTMLMetaElement | null

    const checkToken = checkTokenElement?.content

    const pageURL = new URL(window.location.toString())

    if (!checkToken) {
      const checkTokenSearchParam = pageURL.searchParams.get("checkToken")

      if (checkTokenSearchParam !== null) {
        const cookies = new Cookies()
        const checkTokenCookie = cookies.get("check-token")
        if (checkTokenCookie === undefined) {
          // We're on the final page, which is usually redirected to below, but the user has refreshed
          // the page so the cookie is no longer available. Redirecting back to the start page will trigger
          // a fresh install check.
          const redirectURL = pageURL
          redirectURL.searchParams.delete("checkToken")

          window.location.replace(redirectURL.toString())

          resolve()
          return
        }
      }

      console.debug("Couldn't find overamped-check-token data attribute")
      resolve()
      return
    }

    const redirectURL = pageURL
    redirectURL.searchParams.append("checkToken", checkToken)

    openURL(redirectURL, ignoredHostnames, true, "Install Checker", "replace")

    resolve()
  })
}
