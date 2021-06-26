function replaceAMPLinks() {
  console.debug("Searching for AMP anchors");

  document.body.querySelectorAll("a[data-amp-cur]").forEach((element) => {
    const anchor = element as HTMLAnchorElement;

    const finalURL = new URL(
      (() => {
        // eslint-disable-next-line @typescript-eslint/no-non-null-assertion
        const ampCur = anchor.dataset.ampCur!;

        if (ampCur.length > 0) {
          return ampCur;
        }

        return anchor.dataset.cur ?? anchor.href;
      })()
    );

    console.debug(`URL from attribute: ${finalURL.toString()}`);

    const finalSearchParams = new URLSearchParams();

    finalURL.searchParams.forEach((value, key) => {
      if (value != "amp" && key != "amp") {
        console.debug(`Removing ${key}=${value} from final URL`);
        finalSearchParams.append(key, value);
      }
    });

    finalURL.search = finalSearchParams.toString();

    if (finalURL.pathname.startsWith("/amp/")) {
      console.debug("Removing amp/ prefix");
      finalURL.pathname = finalURL.pathname.substring(4);
    } else if (finalURL.pathname.endsWith("/amp/")) {
      console.debug("Removing amp/ postfix");
      finalURL.pathname = finalURL.pathname.substring(
        finalURL.pathname.length - "amp/".length
      );
    }

    const finalURLString = finalURL.toString();

    console.debug(`De-AMPed URL: ${finalURLString}`);

    anchor.href = finalURLString;

    console.debug("Adding onclick handler to AMP anchor", anchor);

    anchor.onclick = (event) => {
      event.stopImmediatePropagation();

      console.debug("Pushing non-AMP URL");
      window.location.assign(finalURLString);

      return false;
    };

    const ampIcon = anchor.querySelector("span[aria-label='AMP logo']");
    ampIcon?.remove();
  });
}

replaceAMPLinks();

// Support "More Results"
document.addEventListener("DOMNodeInserted", replaceAMPLinks, false);
