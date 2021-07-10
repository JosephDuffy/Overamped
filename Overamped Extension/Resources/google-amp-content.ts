// TODO: Wait for document to be in ready state, allow to run as document_start
browser.storage.local
  .get("ignoredHostnames")
  .then((storage) => {
    const ignoredHostnames =
      (storage["ignoredHostnames"] as string[] | undefined) ?? []

    console.debug("Loaded ignored hostnames list", ignoredHostnames)

    const canonicalElement: HTMLLinkElement | null =
      document.head.querySelector("link[rel~='canonical'][href]")

    if (!canonicalElement) {
      console.debug("Couldn't find canonical URL to redirect to")
      return
    }

    const canonicalURL = new URL(canonicalElement.href)

    if (ignoredHostnames.includes(canonicalURL.hostname)) {
      console.info(
        `Not redirecting because ${canonicalURL.hostname} is in the ignored hostnames`,
      )
    } else {
      console.log(`Redirecting AMP page to ${canonicalElement.href}`)

      window.location.replace(canonicalElement.href)
    }
  })
  .catch((error) => {
    console.error("Failed to load ignoredHostnames setting", error)
  })
