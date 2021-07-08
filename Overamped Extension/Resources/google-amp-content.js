browser.storage.local.get("ignoredHostnames").then((storage) => {
  const ignoredHostnames = storage["ignoredHostnames"] ?? [];
  console.debug("Loaded ignored hostnames list", ignoredHostnames);
  const canonicalElement = document.head.querySelector("link[rel~='canonical'][href]");
  if (!canonicalElement) {
    console.debug("Couldn't find canonical URL to redirect to");
    return;
  }
  const canonicalLink = canonicalElement;
  const canonicalURL = new URL(canonicalElement.href);
  if (ignoredHostnames.includes(canonicalURL.hostname)) {
    console.info(`Not redirecting because ${canonicalElement.href.hostname} is in the ignored hostnames`);
  } else {
    console.log(`Redirecting AMP page to ${canonicalLink.href}`);
    window.location.replace(canonicalLink.href);
  }
}).catch((error) => {
  console.error("Failed to load ignoredHostnames setting", error);
});
