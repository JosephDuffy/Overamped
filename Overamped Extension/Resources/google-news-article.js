(() => {
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

  // ExtensionApplier.ts
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

  // Array+compactMap.ts
  Array.prototype.compactMap = function compactMap(callbackfn) {
    const mappedArray = [];
    this.forEach((value, index, array) => {
      const mappedValue = callbackfn(value, index, array);
      if (mappedValue !== void 0 && mappedValue !== null) {
        mappedArray.push(mappedValue);
      }
    });
    return mappedArray;
  };

  // google-news-article.ts
  new ExtensionApplicator(document, overrideAMPArticles);
  function overrideAMPArticles() {
    const ampArticles = Array.from(document.querySelectorAll("article")).compactMap((article) => {
      console.debug("Searching article for AMP icon", article);
      console.log(article.querySelectorAll("span"));
      const spans = Array.from(article.querySelectorAll("span"));
      const ampSpanIndex = spans.findIndex((span) => {
        return span.innerText == "amp";
      });
      if (ampSpanIndex === -1) {
        console.debug("Didn't find an AMP icon in", spans);
        return null;
      } else {
        return [article, spans[ampSpanIndex]];
      }
    });
    if (ampArticles.length === 0) {
      console.debug("Found no AMP articles");
    }
    ampArticles.forEach((article) => {
      const articleAnchor = article[0].querySelector("a");
      console.log("Found AMP article anchor", articleAnchor);
      if (!articleAnchor) {
        console.debug("Article does not have a link");
        return;
      }
      article[1].style.display = "none";
      articleAnchor.onclick = (event) => {
        console.log("Article anchor clicked", articleAnchor);
        event.preventDefault();
        window.location.assign(articleAnchor.href);
        return false;
      };
    });
  }
})();
