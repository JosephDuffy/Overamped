console.log("Searching for AMP anchors");
document.body.querySelectorAll("a[data-amp-cur]").forEach((element) => {
  const anchor = element;
  const finalURL = anchor.dataset.ampCur;
  anchor.href = finalURL;
  console.debug("Adding onclick handler to AMP anchor", anchor);
  anchor.onclick = (event) => {
    event.stopImmediatePropagation();
    if (window.location.pathname.startsWith("/amp/s/")) {
      console.log("Replacing loaded AMP URL");
      window.location.replace(finalURL);
    } else {
      console.log("Pushing non-AMP URL");
      window.location.assign(finalURL);
    }
    return false;
  };
  const ampIcon = anchor.querySelector("span[aria-label='AMP logo']");
  ampIcon?.remove();
});
