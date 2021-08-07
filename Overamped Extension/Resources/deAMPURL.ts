export default function deAMPURL(finalURL: URL): URL {
  const finalSearchParams = new URLSearchParams()

  finalURL.searchParams.forEach((value, key) => {
    if (value != "amp" && key != "amp") {
      finalSearchParams.append(key, value)
    } else {
      console.debug(`Removing ${key}=${value} from final URL`)
    }
  })

  finalURL.search = finalSearchParams.toString()

  if (finalURL.pathname.startsWith("/amp/")) {
    console.debug("Removing amp/ prefix")
    finalURL.pathname = finalURL.pathname.substring(4)
  } else if (finalURL.pathname.endsWith("/amp/")) {
    console.debug("Removing amp/ postfix")
    finalURL.pathname = finalURL.pathname.substring(
      0,
      finalURL.pathname.length - "amp/".length,
    )
  } else if (finalURL.pathname.endsWith(".amp")) {
    console.debug("Removing .amp postfix")
    finalURL.pathname = finalURL.pathname.substring(
      0,
      finalURL.pathname.length - ".amp".length,
    )
  } else if (
    finalURL.hostname.startsWith("amp.") &&
    finalURL.hostname.split(".").length > 2
  ) {
    console.debug("Removing amp subdomain")
    finalURL.hostname = finalURL.hostname.substring("amp.".length)
  }

  return finalURL
}
