import openURL from "./openURL"

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
      // TODO: Read cookies, if `check-token` is not present but `checkToken` search parameter is redirect to url without search parameter
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
