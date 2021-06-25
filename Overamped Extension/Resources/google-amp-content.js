function redirectFromAMP() {
  const canonicalElement = document.head.querySelector("link[rel~='canonical'][href]");
  if (!canonicalElement) {
    console.debug("Couldn't find canonical URL to redirect to");
    return;
  }
  const canonicalLink = canonicalElement;
  console.log(`Redirecting AMP page to ${canonicalLink.href}`);
  window.location.replace(canonicalLink.href);
}
redirectFromAMP();
