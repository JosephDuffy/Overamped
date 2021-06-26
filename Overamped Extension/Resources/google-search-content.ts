console.log("Searching for AMP anchors");

document.body.querySelectorAll("a[data-amp-cur]").forEach((element) => {
  const anchor = element as HTMLAnchorElement;

  const finalURL = (() => {
    // eslint-disable-next-line @typescript-eslint/no-non-null-assertion
    const ampCur = anchor.dataset.ampCur!;

    if (ampCur.length > 0) {
      return ampCur;
    }

    console.debug("ampCur was empty; possibly a news link");

    const ampURL = anchor.dataset.cur ?? anchor.href;

    console.info("AMP URL", ampURL);

    if (ampURL.endsWith("/amp/")) {
      // These are often news links.
      return ampURL.substring(0, ampURL.length - "amp/".length);
    } else {
      return ampURL;
    }
  })();

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
