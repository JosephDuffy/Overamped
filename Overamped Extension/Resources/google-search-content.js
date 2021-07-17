(() => {
  // deampURL.ts
  function deampURL(finalURL) {
    const finalSearchParams = new URLSearchParams();
    finalURL.searchParams.forEach((value, key) => {
      if (value != "amp" && key != "amp") {
        finalSearchParams.append(key, value);
      } else {
        console.debug(`Removing ${key}=${value} from final URL`);
      }
    });
    finalURL.search = finalSearchParams.toString();
    if (finalURL.pathname.startsWith("/amp/")) {
      console.debug("Removing amp/ prefix");
      finalURL.pathname = finalURL.pathname.substring(4);
    } else if (finalURL.pathname.endsWith("/amp/")) {
      console.debug("Removing amp/ postfix");
      finalURL.pathname = finalURL.pathname.substring(0, finalURL.pathname.length - "amp/".length);
    } else if (finalURL.pathname.endsWith(".amp")) {
      console.debug("Removing .amp postfix");
      finalURL.pathname = finalURL.pathname.substring(0, finalURL.pathname.length - ".amp".length);
    } else if (finalURL.hostname.startsWith("amp.")) {
      console.debug("Removing amp subdomain");
      finalURL.hostname = finalURL.hostname.substring("amp.".length);
    }
    return finalURL;
  }

  // ExtensionApplier.ts
  var ExtensionApplier = class {
    #document;
    #thunk;
    #readyStateChangeListener;
    #ignoredHostnames;
    constructor(document2, thunk) {
      this.#document = document2;
      this.#thunk = thunk;
      this.loadIgnoredHostnames();
    }
    applyIgnoredHostnames(ignoredHostnames) {
      this.#ignoredHostnames = ignoredHostnames;
      if (this.#document.readyState == "loading") {
        console.debug("Ignore list has been loaded but the webpage is still loading");
        if (this.#readyStateChangeListener) {
          this.#document.removeEventListener("readystatechange", this.#readyStateChangeListener);
        }
        this.#readyStateChangeListener = () => {
          this.applyIgnoredHostnames(ignoredHostnames);
        };
        this.#document.addEventListener("readystatechange", this.#readyStateChangeListener);
        return;
      }
      this.#document.removeEventListener("DOMNodeInserted", this.handleDOMNodeInserted.bind(this));
      this.#document.addEventListener("DOMNodeInserted", this.handleDOMNodeInserted.bind(this));
      this.#thunk(ignoredHostnames);
    }
    handleDOMNodeInserted() {
      this.#thunk(this.#ignoredHostnames ?? []);
    }
    loadIgnoredHostnames() {
      browser.runtime.sendMessage({
        request: "ignoredHostnames"
      }).then((response) => {
        console.debug("Loaded ignored hostnames list", response);
        this.applyIgnoredHostnames(response["ignoredHostnames"]);
      }).catch((error) => {
        console.error("Failed to load ignoredHostnames setting", error);
      });
    }
  };

  // google-search-content.ts
  var anchorOnclickListeners = {};
  function findAMPLogoRelativeToAnchor(anchor) {
    const childLogo = anchor.querySelector("span[aria-label='AMP logo']");
    if (childLogo) {
      return childLogo;
    }
    if (anchor.dataset.ampHlt) {
      console.debug(`Anchor is from a "Featured Snippet"; searching parent for container`);
      let parent = anchor.parentElement;
      while (parent && !parent.classList.contains("card-section")) {
        parent = parent.parentElement;
      }
      if (parent) {
        console.debug("Found card section parent", parent);
        return parent.querySelector("span[aria-label='AMP logo']");
      }
    }
    console.debug("Failed to find corresponding AMP logo <span> for", anchor);
    return null;
  }
  function replaceAMPLinks(ignoredHostnames) {
    const ampAnchor = document.body.querySelectorAll("a[data-ved]");
    console.debug(`Found ${ampAnchor.length} AMP links`);
    ampAnchor.forEach((element) => {
      const anchor = element;
      console.debug("Checking AMP anchor", anchor);
      const ved = anchor.dataset.ved;
      const anchorURLString = (() => {
        const ampCur = anchor.dataset.ampCur;
        if (ampCur && ampCur.length > 0) {
          return ampCur;
        }
        return anchor.dataset.cur ?? anchor.href;
      })();
      if (!anchorURLString) {
        console.debug(`Failed to get final URL from anchor`, anchor);
        return;
      }
      const anchorURL = new URL(anchorURLString);
      console.debug(`URL from attribute: ${anchorURL.toString()}`);
      const finalURL = deampURL(anchorURL);
      const ampIcon = findAMPLogoRelativeToAnchor(anchor);
      let modifiedAnchor = anchorOnclickListeners[ved];
      if (ignoredHostnames.includes(finalURL.hostname)) {
        console.debug(`Not modifying anchor; ${finalURL.hostname} is in ignore list`, anchorOnclickListeners);
        if (modifiedAnchor) {
          console.debug("Anchor has been modified; reverting to", modifiedAnchor);
          anchor.href = modifiedAnchor.originalHREF;
          anchor.removeEventListener("click", modifiedAnchor.listener);
          if (ampIcon && modifiedAnchor.ampIconDisplay !== void 0) {
            ampIcon.style.display = modifiedAnchor.ampIconDisplay;
          }
          delete anchorOnclickListeners[ved];
        }
        return;
      } else if (modifiedAnchor) {
        return;
      }
      const finalURLString = finalURL.toString();
      console.info(`De-AMPed URL: ${finalURLString}`);
      const originalHREF = anchor.href;
      anchor.href = finalURLString;
      function interceptAMPLink(event) {
        event.stopImmediatePropagation();
        console.debug("Pushing non-AMP URL");
        window.location.assign(finalURLString);
        return false;
      }
      anchor.addEventListener("click", interceptAMPLink);
      modifiedAnchor = {
        listener: interceptAMPLink,
        originalHREF
      };
      if (ampIcon) {
        modifiedAnchor.ampIconDisplay = ampIcon.style.display;
        ampIcon.style.display = "none";
      }
      anchorOnclickListeners[ved] = modifiedAnchor;
    });
    document.body.dataset.overampedReplacedLinksCount = `${Object.keys(anchorOnclickListeners).length}`;
  }
  new ExtensionApplier(document, replaceAMPLinks);
})();
