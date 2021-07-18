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

  // NativeAppCommunicator.ts
  var NativeAppCommunicator = class {
    ignoredHostnames() {
      return new Promise((resolve, reject) => {
        browser.runtime.sendMessage({
          request: "ignoredHostnames"
        }).then((response) => {
          console.debug("Loaded ignored hostnames list", response);
          if (response["ignoredHostnames"] === null) {
            resolve([]);
          } else {
            resolve(response["ignoredHostnames"]);
          }
        }).catch((error) => {
          console.error("Failed to load ignoredHostnames setting", error);
          reject(error);
        });
      });
    }
    ignoreHostname(hostname) {
      return new Promise((resolve, reject) => {
        browser.runtime.sendMessage({
          request: "ignoreHostname",
          payload: {
            hostname
          }
        }).then(() => {
          console.debug(`Ignored hostname ${hostname}`);
          resolve();
        }).catch((error) => {
          console.error(`Failed to ignore hostname ${hostname}`, error);
          reject(error);
        });
      });
    }
    removeIgnoredHostname(hostname) {
      return new Promise((resolve, reject) => {
        browser.runtime.sendMessage({
          request: "removeIgnoredHostname",
          payload: {
            hostname
          }
        }).then(() => {
          console.debug(`Removed ignored hostname ${hostname}`);
          resolve();
        }).catch((error) => {
          console.error(`Failed to remove ignored hostname ${hostname}`, error);
          reject(error);
        });
      });
    }
  };

  // ExtensionApplicator.ts
  var ExtensionApplicator = class {
    #document;
    #thunk;
    #nativeAppCommunicator;
    #readyStateChangeListener;
    #ignoredHostnames;
    constructor(document2, thunk) {
      this.#document = document2;
      this.#thunk = thunk;
      this.#nativeAppCommunicator = new NativeAppCommunicator();
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
      this.#nativeAppCommunicator.ignoredHostnames().then((ignoredHostnames) => {
        console.debug("Loaded ignored hostnames list", ignoredHostnames);
        this.applyIgnoredHostnames(ignoredHostnames);
      }).catch((error) => {
        console.error("Failed to load ignoredHostnames setting", error);
      });
    }
  };

  // google-amp-content.ts
  function redirectToCanonicalVersion(ignoredHostnames) {
    const canonicalElement = document.head.querySelector("link[rel~='canonical'][href]");
    if (!canonicalElement) {
      console.debug("Couldn't find canonical URL to redirect to");
      return;
    }
    const canonicalURL = new URL(canonicalElement.href);
    const finalURL = deampURL(canonicalURL);
    if (ignoredHostnames.includes(finalURL.hostname)) {
      console.info(`Not redirecting because ${finalURL.hostname} is in the ignored hostnames`);
    } else {
      console.log(`Redirecting AMP page to ${finalURL.toString()}`);
      window.location.replace(finalURL.toString());
    }
  }
  new ExtensionApplicator(document, redirectToCanonicalVersion);
})();
