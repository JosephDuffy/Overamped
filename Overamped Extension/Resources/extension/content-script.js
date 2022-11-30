"use strict";
(() => {
  // pageTypeForURL.ts
  function pageTypeForURL(url) {
    const pageHostname = url.hostname;
    const currentGoogleDomain = googleDomains.find((googleDomain) => {
      return pageHostname === googleDomain || pageHostname.endsWith(`.${googleDomain}`);
    });
    if (currentGoogleDomain !== void 0) {
      if (pageHostname.startsWith("news.")) {
        return PageType.GoogleNews;
      } else if (url.pathname === "/search") {
        return PageType.GoogleSearch;
      } else if (url.pathname.startsWith("/amp/s/")) {
        return PageType.GoogleAMPCache;
      }
    }
    if (pageHostname === "search.yahoo.co.jp" && url.pathname === "/search") {
      return PageType.YahooJAPANSearch;
    }
    if (pageHostname.endsWith(".turbopages.org")) {
      return PageType.YandexTurboCache;
    }
    if (pageHostname === "overamped.app" && url.pathname === "/install-checker") {
      return PageType.InstallChecker;
    }
    return PageType.Unknown;
  }
  var PageType = /* @__PURE__ */ ((PageType2) => {
    PageType2[PageType2["GoogleNews"] = 0] = "GoogleNews";
    PageType2[PageType2["GoogleSearch"] = 1] = "GoogleSearch";
    PageType2[PageType2["GoogleAMPCache"] = 2] = "GoogleAMPCache";
    PageType2[PageType2["YahooJAPANSearch"] = 3] = "YahooJAPANSearch";
    PageType2[PageType2["YandexTurboCache"] = 4] = "YandexTurboCache";
    PageType2[PageType2["InstallChecker"] = 5] = "InstallChecker";
    PageType2[PageType2["Unknown"] = 6] = "Unknown";
    return PageType2;
  })(PageType || {});
  var googleDomains = [
    "google.com",
    "google.ad",
    "google.ae",
    "google.com.af",
    "google.com.ag",
    "google.com.ai",
    "google.al",
    "google.am",
    "google.co.ao",
    "google.com.ar",
    "google.as",
    "google.at",
    "google.com.au",
    "google.az",
    "google.ba",
    "google.com.bd",
    "google.be",
    "google.bf",
    "google.bg",
    "google.com.bh",
    "google.bi",
    "google.bj",
    "google.com.bn",
    "google.com.bo",
    "google.com.br",
    "google.bs",
    "google.bt",
    "google.co.bw",
    "google.by",
    "google.com.bz",
    "google.ca",
    "google.cd",
    "google.cf",
    "google.cg",
    "google.ch",
    "google.ci",
    "google.co.ck",
    "google.cl",
    "google.cm",
    "google.cn",
    "google.com.co",
    "google.co.cr",
    "google.com.cu",
    "google.cv",
    "google.com.cy",
    "google.cz",
    "google.de",
    "google.dj",
    "google.dk",
    "google.dm",
    "google.com.do",
    "google.dz",
    "google.com.ec",
    "google.ee",
    "google.com.eg",
    "google.es",
    "google.com.et",
    "google.fi",
    "google.com.fj",
    "google.fm",
    "google.fr",
    "google.ga",
    "google.ge",
    "google.gg",
    "google.com.gh",
    "google.com.gi",
    "google.gl",
    "google.gm",
    "google.gr",
    "google.com.gt",
    "google.gy",
    "google.com.hk",
    "google.hn",
    "google.hr",
    "google.ht",
    "google.hu",
    "google.co.id",
    "google.ie",
    "google.co.il",
    "google.im",
    "google.co.in",
    "google.iq",
    "google.is",
    "google.it",
    "google.je",
    "google.com.jm",
    "google.jo",
    "google.co.jp",
    "google.co.ke",
    "google.com.kh",
    "google.ki",
    "google.kg",
    "google.co.kr",
    "google.com.kw",
    "google.kz",
    "google.la",
    "google.com.lb",
    "google.li",
    "google.lk",
    "google.co.ls",
    "google.lt",
    "google.lu",
    "google.lv",
    "google.com.ly",
    "google.co.ma",
    "google.md",
    "google.me",
    "google.mg",
    "google.mk",
    "google.ml",
    "google.com.mm",
    "google.mn",
    "google.ms",
    "google.com.mt",
    "google.mu",
    "google.mv",
    "google.mw",
    "google.com.mx",
    "google.com.my",
    "google.co.mz",
    "google.com.na",
    "google.com.ng",
    "google.com.ni",
    "google.ne",
    "google.nl",
    "google.no",
    "google.com.np",
    "google.nr",
    "google.nu",
    "google.co.nz",
    "google.com.om",
    "google.com.pa",
    "google.com.pe",
    "google.com.pg",
    "google.com.ph",
    "google.com.pk",
    "google.pl",
    "google.pn",
    "google.com.pr",
    "google.ps",
    "google.pt",
    "google.com.py",
    "google.com.qa",
    "google.ro",
    "google.ru",
    "google.rw",
    "google.com.sa",
    "google.com.sb",
    "google.sc",
    "google.se",
    "google.com.sg",
    "google.sh",
    "google.si",
    "google.sk",
    "google.com.sl",
    "google.sn",
    "google.so",
    "google.sm",
    "google.sr",
    "google.st",
    "google.com.sv",
    "google.td",
    "google.tg",
    "google.co.th",
    "google.com.tj",
    "google.tl",
    "google.tm",
    "google.tn",
    "google.to",
    "google.com.tr",
    "google.tt",
    "google.com.tw",
    "google.co.tz",
    "google.com.ua",
    "google.co.ug",
    "google.co.uk",
    "google.com.uy",
    "google.co.uz",
    "google.com.vc",
    "google.co.ve",
    "google.vg",
    "google.co.vi",
    "google.com.vn",
    "google.vu",
    "google.ws",
    "google.rs",
    "google.co.za",
    "google.co.zm",
    "google.co.zw",
    "google.cat"
  ];

  // SettingsPayload.ts
  function objectIsSettingsPayload(object) {
    return Object.prototype.hasOwnProperty.call(object, "settings");
  }
  function settingsPayloadHasRedirectOnlySetting(object) {
    return Object.prototype.hasOwnProperty.call(object.settings, "redirectOnly") && typeof object.settings.redirectOnly === "boolean";
  }
  function settingsPayloadHasIgnoredHostnamesSetting(object) {
    return Object.prototype.hasOwnProperty.call(object.settings, "ignoredHostnames") && Array.isArray(object.settings.ignoredHostnames);
  }

  // NativeAppCommunicator.ts
  var NativeAppCommunicator = class {
    async appSettings() {
      const response = await browser.runtime.sendMessage({
        request: "settings",
        payload: {
          settings: ["redirectOnly", "ignoredHostnames"]
        }
      });
      console.debug("Loaded app settings", response);
      if (!objectIsSettingsPayload(response)) {
        throw "Malformed response to settings request";
      }
      if (!settingsPayloadHasRedirectOnlySetting(response)) {
        throw "Invalid redirect only setting returned";
      }
      if (!settingsPayloadHasIgnoredHostnamesSetting(response)) {
        throw "Invalid ignored hostnames setting returned";
      }
      return {
        ignoredHostnames: response.settings.ignoredHostnames,
        redirectOnly: response.settings.redirectOnly
      };
    }
    async ignoredHostnames() {
      const response = await browser.runtime.sendMessage({
        request: "settings",
        payload: {
          settings: ["ignoredHostnames"]
        }
      });
      console.debug("Loaded ignoredHostnames settings", response);
      if (!objectIsSettingsPayload(response)) {
        throw "Malformed response to settings request";
      }
      if (!Object.prototype.hasOwnProperty.call(
        response.settings,
        "ignoredHostnames"
      ) || !Array.isArray(response.settings.ignoredHostnames)) {
        throw "Invalid ignored hostnames setting returned";
      }
      return response.settings.ignoredHostnames;
    }
    async ignoreHostname(hostname) {
      try {
        const response = await browser.runtime.sendMessage({
          request: "ignoreHostname",
          payload: {
            hostname
          }
        });
        if (response !== void 0 && response["ignoredHostnames"] !== null) {
          console.log(
            "Hostname has been ignored. New list:",
            response["ignoredHostnames"]
          );
          return response["ignoredHostnames"];
        } else {
          const error = new Error(
            "Response to ignoreHostname did not contain ignored hostnames list"
          );
          console.error(error, response);
          throw error;
        }
      } catch (error) {
        console.error(`Failed to ignore hostname ${hostname}`, error);
        throw error;
      }
    }
    async removeIgnoredHostname(hostname) {
      try {
        const response = await browser.runtime.sendMessage({
          request: "removeIgnoredHostname",
          payload: {
            hostname
          }
        });
        if (response !== void 0 && response["ignoredHostnames"] !== null) {
          console.log(
            "Ignored hostname has been removed. New list:",
            response["ignoredHostnames"]
          );
          return response["ignoredHostnames"];
        } else {
          const error = new Error(
            "Response to removeIgnoredHostname did not contain ignored hostnames list"
          );
          console.error(error, response);
          throw error;
        }
      } catch (error) {
        console.error(`Failed to remove ignored hostname ${hostname}`, error);
        throw error;
      }
    }
    migrateIgnoredHostnames(hostnames) {
      return new Promise((resolve, reject) => {
        browser.runtime.sendMessage({
          request: "migrateIgnoredHostnames",
          payload: {
            ignoredHostnames: hostnames
          }
        }).then(() => {
          console.debug(`Migrated ignored hostnames ${hostnames}`);
          resolve();
        }).catch((error) => {
          console.error(
            `Failed to migrate ignored hostnames ${hostnames}`,
            error
          );
          reject(error);
        });
      });
    }
    async logReplacedLinks(urls) {
      if (urls.length === 0) {
        return;
      }
      const replacedHostnames = urls.map((url) => url.hostname);
      try {
        await browser.runtime.sendMessage({
          request: "logReplacedLinks",
          payload: {
            replacedLinks: replacedHostnames
          }
        });
        console.debug(`Logged replaced hostnames ${replacedHostnames}`);
      } catch (error) {
        console.error(
          `Failed to log replaced hostnames ${replacedHostnames}`,
          error
        );
        throw error;
      }
    }
    async logRedirectedLink(contentType, fromURL, toURL) {
      try {
        await browser.runtime.sendMessage({
          request: "logRedirectedLink",
          payload: {
            contentType,
            fromURL,
            toURL
          }
        });
        console.debug(`Logged redirection from ${fromURL} to ${toURL}`);
      } catch (error) {
        console.error(
          `Failed to log redirection from ${fromURL} to ${toURL}`,
          error
        );
        throw error;
      }
    }
  };

  // ExtensionApplicator.ts
  var ExtensionApplicator = class {
    #document;
    #thunk;
    #nativeAppCommunicator;
    #readyStateChangeListener;
    #ignoredHostnames;
    #state;
    constructor(document2, thunk, listedForDOMNodeInserted, ignoredHostnames) {
      this.#document = document2;
      this.#thunk = thunk;
      this.#state = "idle";
      this.#nativeAppCommunicator = new NativeAppCommunicator();
      this.applyIgnoredHostnames(ignoredHostnames);
      browser.storage.onChanged.addListener(this.localStorageChanged.bind(this));
      this.migrateIgnoredHostnames();
      if (listedForDOMNodeInserted) {
        this.#document.addEventListener(
          "DOMNodeInserted",
          this.handleDOMNodeInserted.bind(this)
        );
      }
    }
    async ignoreHostname(hostname) {
      try {
        const ignoredHostnames = await this.#nativeAppCommunicator.ignoreHostname(
          hostname
        );
        console.log("Hostname has been ignored. New list:", ignoredHostnames);
        this.applyIgnoredHostnames(ignoredHostnames);
        browser.storage.local.set({
          cachedIgnoredHostnames: ignoredHostnames
        }).then(() => {
          console.log("New ignored hostnames have been cached");
        }).catch((error) => {
          console.error("Failed to cache ignored hostnames", error);
        });
      } catch (error) {
        console.error(`Failed to ignore hostname ${hostname}`, error);
      }
    }
    async removeIgnoredHostname(hostname) {
      try {
        const ignoredHostnames = await this.#nativeAppCommunicator.removeIgnoredHostname(hostname);
        console.log(
          "Ignored hostname has been removed. New list:",
          ignoredHostnames
        );
        this.applyIgnoredHostnames(ignoredHostnames);
        browser.storage.local.set({
          cachedIgnoredHostnames: ignoredHostnames
        }).then(() => {
          console.log("New ignored hostnames have been cached");
        }).catch((error) => {
          console.error("Failed to cache ignored hostnames", error);
        });
      } catch (error) {
        console.error(`Failed to ignore hostname ${hostname}`, error);
      }
    }
    applyIgnoredHostnames(ignoredHostnames) {
      this.#ignoredHostnames = ignoredHostnames;
      if (this.#document.readyState === "loading") {
        console.debug(
          "Ignore list has been loaded but the webpage is still loading"
        );
        if (this.#readyStateChangeListener) {
          this.#document.removeEventListener(
            "readystatechange",
            this.#readyStateChangeListener
          );
        }
        this.#readyStateChangeListener = () => {
          this.applyIgnoredHostnames(ignoredHostnames);
        };
        this.#document.addEventListener(
          "readystatechange",
          this.#readyStateChangeListener
        );
        return;
      }
      this.callThunk(ignoredHostnames);
    }
    handleDOMNodeInserted() {
      if (this.#document.readyState !== "loading") {
        this.callThunk(this.#ignoredHostnames ?? []);
      }
    }
    callThunk(ignoredHostnames) {
      console.debug("Calling thunk with ignored hostnames");
      if (this.#state === "idle") {
        this.#state = "applying";
        this.#thunk(ignoredHostnames).catch((error) => {
          console.error("Thunk threw error", error);
        }).finally(() => {
          this.checkState();
        });
      } else {
        this.#state = {
          pending: () => {
            return this.#thunk(ignoredHostnames);
          }
        };
      }
    }
    checkState() {
      if (this.#state === "applying") {
        this.#state = "idle";
      } else if (this.#state !== "idle") {
        const pendingPromise = this.#state.pending;
        this.#state = "applying";
        pendingPromise().catch((error) => {
          console.error("Thunk threw error", error);
        }).finally(() => {
          this.checkState();
        });
      }
    }
    localStorageChanged(changes, areaName) {
      console.debug(`Storage has changed in ${areaName}:`, changes);
      if (areaName !== "local") {
        return;
      }
      if ("cachedIgnoredHostnames" in changes) {
        const cachedIgnoredHostnames = changes["cachedIgnoredHostnames"];
        const newIgnoredHostnames = cachedIgnoredHostnames.newValue;
        if (newIgnoredHostnames && Array.isArray(newIgnoredHostnames)) {
          this.applyIgnoredHostnames(newIgnoredHostnames);
        }
      }
    }
    async migrateIgnoredHostnames() {
      try {
        const storage = await browser.storage.local.get("ignoredHostnames");
        const ignoredHostnames = storage["ignoredHostnames"];
        if (ignoredHostnames !== void 0) {
          await this.#nativeAppCommunicator.migrateIgnoredHostnames(
            ignoredHostnames
          );
          await browser.storage.local.remove("ignoredHostnames");
        }
      } catch (error) {
        console.error("Failed to load ignored hostnames for migration", error);
      }
    }
  };

  // openURL.ts
  function openURL(url, ignoredHostnames, logEvent, contentType, action) {
    const globallyIgnoredHostnames = [
      "www.thegate.ca",
      "www.student.si",
      "thehustle.co",
      "www.bobbakermazda.com"
    ];
    if (globallyIgnoredHostnames.includes(url.hostname)) {
      console.info(
        `Not redirecting to ${url} because ${url.hostname} is in the globally ignored hostnames`
      );
      return false;
    } else if (ignoredHostnames.includes(url.hostname)) {
      console.info(
        `Not redirecting to ${url} because ${url.hostname} is in the ignored hostnames`
      );
      return false;
    } else if (window.location.toString() === url.toString()) {
      console.info(
        `Not redirecting to ${url} because it is the same as the current page`
      );
      return false;
    } else {
      console.log(
        `Redirecting ${document.location.toString()} to ${url.toString()}`
      );
      if (logEvent) {
        new NativeAppCommunicator().logRedirectedLink(
          contentType,
          new URL(window.location.href),
          url
        );
      }
      switch (action) {
        case "push":
          window.location.assign(url.toString());
          break;
        case "replace":
          window.location.replace(url.toString());
          break;
      }
      return true;
    }
  }

  // generic-amp-content.ts
  function redirectToCanonicalVersion(ignoredHostnames) {
    const documentAttributes = document.documentElement.attributes;
    if (!Object.prototype.hasOwnProperty.call(documentAttributes, "amp") && !Object.prototype.hasOwnProperty.call(documentAttributes, "\u26A1")) {
      return Promise.resolve();
    }
    const canonicalElement = document.head.querySelector(
      "link[rel~='canonical'][href]"
    );
    if (!canonicalElement) {
      console.debug("Couldn't find canonical URL to redirect to");
      return Promise.resolve();
    }
    const canonicalURL = new URL(canonicalElement.href);
    if (canonicalURL.toString() === document.referrer || document.referrer === document.location.toString()) {
      console.info(
        "Not redirecting to AMP page due to recursive redirect; redirecting this page would redirect back to this AMP page"
      );
      return Promise.resolve();
    }
    openURL(canonicalURL, ignoredHostnames, true, "AMP", "replace");
    return Promise.resolve();
  }

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
  function overrideAMPArticles(ignoredHostnames) {
    const ampArticles = Array.from(
      document.querySelectorAll("article")
    ).compactMap((article) => {
      console.debug("Searching article for AMP icon", article);
      console.log(article.querySelectorAll("span"));
      const spans = Array.from(article.querySelectorAll("span"));
      const ampSpanIndex = spans.findIndex((span) => {
        return span.innerText == "amp";
      });
      if (ampSpanIndex === -1) {
        console.debug("Didn't find an AMP icon in", spans);
        return [article, void 0];
      } else {
        return [article, spans[ampSpanIndex]];
      }
    });
    if (ampArticles.length === 0) {
      console.debug("Found no AMP articles");
    }
    ampArticles.forEach((article) => {
      const articleAnchor = article[0].querySelector("a");
      console.log("Found article anchor", articleAnchor);
      if (!articleAnchor) {
        console.debug("Article does not have a link");
        return;
      }
      if (article[1]) {
        article[1].style.display = "none";
      }
      articleAnchor.onclick = (event) => {
        console.log("Article anchor clicked", articleAnchor);
        if (openURL(
          new URL(articleAnchor.href),
          ignoredHostnames,
          true,
          "AMP",
          "push"
        )) {
          event.stopImmediatePropagation();
          event.preventDefault();
          return false;
        } else {
          return true;
        }
      };
    });
    return Promise.resolve();
  }

  // deAMPURL.ts
  function deAMPURL(finalURL) {
    const finalSearchParams = new URLSearchParams();
    finalURL.searchParams.forEach((value, key) => {
      if (value != "amp" && key != "amp") {
        finalSearchParams.append(key, value);
      } else {
        console.debug(`Removing ${key}=${value} from final URL`);
      }
    });
    finalURL.search = finalSearchParams.toString();
    if (finalURL.hostname === "amp.abc.net.au") {
      finalURL.hostname = "www.abc.net.au";
      finalURL.pathname = finalURL.pathname.replace("article", "news");
    } else if (finalURL.pathname.startsWith("/amp/")) {
      console.debug("Removing amp/ prefix");
      finalURL.pathname = finalURL.pathname.substring(4);
    } else if (finalURL.pathname.endsWith("/amp/")) {
      console.debug("Removing amp/ postfix");
      finalURL.pathname = finalURL.pathname.substring(
        0,
        finalURL.pathname.length - "amp/".length
      );
    } else if (finalURL.pathname.endsWith(".amp")) {
      console.debug("Removing .amp postfix");
      finalURL.pathname = finalURL.pathname.substring(
        0,
        finalURL.pathname.length - ".amp".length
      );
    } else if (finalURL.hostname.startsWith("amp.") && finalURL.hostname.split(".").length > 2) {
      console.debug("Removing amp subdomain");
      finalURL.hostname = finalURL.hostname.substring("amp.".length);
    }
    return finalURL;
  }

  // google-amp-content.ts
  async function redirectGoogleAMPContent(ignoredHostnames) {
    const canonicalAnchor = document.querySelector("a.amp-canurl");
    if (canonicalAnchor) {
      const canonicalURL = new URL(canonicalAnchor.href);
      openURL(canonicalURL, ignoredHostnames, true, "AMP", "replace");
    } else if (document.readyState === "complete") {
      const canonicalElement = document.head.querySelector("link[rel~='canonical'][href]");
      if (!canonicalElement) {
        console.debug("Couldn't find canonical URL to redirect to");
        return Promise.resolve();
      }
      const canonicalURL = new URL(canonicalElement.href);
      const { canAccess: canAccessURL } = await browser.runtime.sendMessage({
        request: "canAccessURL",
        payload: {
          url: canonicalURL.toString()
        }
      });
      if (canAccessURL) {
        openURL(canonicalURL, ignoredHostnames, false, "AMP", "replace");
      } else {
        const deAMPedURL = deAMPURL(canonicalURL);
        console.debug(`De-AMPed URL: ${deAMPedURL}`);
        openURL(canonicalURL, ignoredHostnames, true, "AMP", "replace");
      }
    }
    return Promise.resolve();
  }

  // yahoo-jp-search-content.ts
  var anchorOnclickListeners = {};
  function findAMPLogoRelativeToAnchor(anchor) {
    const childLogo = anchor.querySelector("div.sw-Cite__icon--amp");
    if (childLogo) {
      return childLogo;
    }
    console.debug("Failed to find corresponding AMP logo <span> for", anchor);
    return null;
  }
  async function replaceYahooJPAMPLinks(ignoredHostnames) {
    const ampAnchor = document.body.querySelectorAll("a[data-amp-cur]");
    console.debug(`Found ${ampAnchor.length} AMP links`);
    const modifyAnchorPromises = Array.from(ampAnchor).map((element) => {
      const anchor = element;
      return modifyAnchorIfRequired(anchor, ignoredHostnames);
    });
    const modifiedURLs = await Promise.all(modifyAnchorPromises);
    const newlyReplacedURLs = modifiedURLs.compactMap((element) => {
      return element;
    });
    new NativeAppCommunicator().logReplacedLinks(newlyReplacedURLs);
    console.info(
      `A total of ${Object.keys(anchorOnclickListeners).length} AMP links have been replaced`
    );
    document.body.dataset.overampedReplacedLinksCount = `${Object.keys(anchorOnclickListeners).length}`;
  }
  async function modifyAnchorIfRequired(anchor, ignoredHostnames) {
    console.debug("Checking anchor", anchor);
    if (!anchor.dataset.ylk) {
      console.debug("Missing ylk data on anchor", anchor);
      return;
    }
    const ylk = anchor.dataset.ylk;
    const anchorURLString = anchor.dataset.ampCur;
    if (!anchorURLString) {
      console.debug(`Failed to get final URL from anchor`, anchor);
      return;
    }
    let anchorURL = new URL(anchorURLString);
    console.debug(`URL from attribute: ${anchorURL.toString()}`);
    const ampIcon = findAMPLogoRelativeToAnchor(anchor);
    let modifiedAnchor = anchorOnclickListeners[ylk];
    const { canAccess: canAccessURL } = await browser.runtime.sendMessage({
      request: "canAccessURL",
      payload: {
        url: anchorURL.toString()
      }
    });
    if (!canAccessURL) {
      anchorURL = deAMPURL(anchorURL);
      console.debug(`De-AMPed URL: ${anchorURL}`);
    }
    if (ignoredHostnames.includes(anchorURL.hostname)) {
      console.debug(
        `Not modifying anchor; ${anchorURL.hostname} is in ignore list`,
        anchorOnclickListeners
      );
      if (modifiedAnchor) {
        unmodifyAnchor(anchor, modifiedAnchor, ampIcon);
      }
      return;
    } else if (modifiedAnchor) {
      console.debug("Not modifying anchor; it has already been modified");
      return;
    }
    const originalHREF = anchor.href;
    anchor.href = anchorURL.toString();
    function interceptAMPLink(event) {
      if (openURL(anchorURL, ignoredHostnames, !canAccessURL, "AMP", "push")) {
        event.preventDefault();
        event.stopImmediatePropagation();
        return false;
      } else {
        return true;
      }
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
    anchorOnclickListeners[ylk] = modifiedAnchor;
    return new URL(anchor.href);
  }
  function unmodifyAnchor(anchor, modifiedAnchor, ampIcon) {
    console.debug("Anchor has been modified; reverting to", modifiedAnchor);
    anchor.href = modifiedAnchor.originalHREF;
    anchor.removeEventListener("click", modifiedAnchor.listener);
    if (ampIcon && modifiedAnchor.ampIconDisplay !== void 0) {
      ampIcon.style.display = modifiedAnchor.ampIconDisplay;
    }
    if (anchor.dataset.ylk) {
      delete anchorOnclickListeners[anchor.dataset.ylk];
    }
  }

  // yandex-turbo-cache.ts
  function redirectYandexTurboCache(ignoredHostnames) {
    const canonicalElement = document.head.querySelector(
      "link[rel~='canonical'][href]"
    );
    if (!canonicalElement) {
      console.debug("Couldn't find canonical URL to redirect to");
      return Promise.resolve();
    }
    const canonicalURL = new URL(canonicalElement.href);
    openURL(canonicalURL, ignoredHostnames, true, "Yandex Turbo", "replace");
    return Promise.resolve();
  }

  // install-checker.ts
  function redirectInstallChecker(ignoredHostnames) {
    return new Promise((resolve) => {
      const checkTokenElement = document.head.querySelector(
        "meta[name='overamped-check-token'][content]"
      );
      const checkToken = checkTokenElement?.content;
      const pageURL = new URL(window.location.toString());
      if (!checkToken) {
        console.debug("Couldn't find overamped-check-token data attribute");
        resolve();
        return;
      }
      const redirectURL = pageURL;
      redirectURL.searchParams.append("checkToken", checkToken);
      openURL(redirectURL, ignoredHostnames, true, "Install Checker", "replace");
      resolve();
    });
  }

  // content-script.ts
  (async () => {
    const pageURL = new URL(location.toString());
    console.debug(`Webpage hostname: ${pageURL.hostname}`);
    const pageType = pageTypeForURL(pageURL);
    if (pageType == 5 /* InstallChecker */) {
      new ExtensionApplicator(document, redirectInstallChecker, false, []);
      return;
    }
    const nativeAppCommunicator = new NativeAppCommunicator();
    const appSettings = await nativeAppCommunicator.appSettings();
    if (appSettings.redirectOnly) {
      console.debug("User has requested to only use generic AMP handler");
      new ExtensionApplicator(
        document,
        redirectToCanonicalVersion,
        false,
        appSettings.ignoredHostnames
      );
      return;
    }
    switch (pageType) {
      case 0 /* GoogleNews */:
        console.debug("Loading Google News Article handler");
        new ExtensionApplicator(
          document,
          overrideAMPArticles,
          true,
          appSettings.ignoredHostnames
        );
        break;
      case 1 /* GoogleSearch */:
        console.debug(
          "Not loading Google Search handler due to bug with handling Google Images; loading generic AMP hander"
        );
        new ExtensionApplicator(
          document,
          redirectToCanonicalVersion,
          false,
          appSettings.ignoredHostnames
        );
        break;
      case 2 /* GoogleAMPCache */:
        console.debug("Loading Google AMP Content handler");
        new ExtensionApplicator(
          document,
          redirectGoogleAMPContent,
          false,
          appSettings.ignoredHostnames
        );
        break;
      case 3 /* YahooJAPANSearch */:
        console.debug("Loading Yahoo JAPAN! Search handler");
        new ExtensionApplicator(
          document,
          replaceYahooJPAMPLinks,
          true,
          appSettings.ignoredHostnames
        );
        break;
      case 4 /* YandexTurboCache */:
        console.debug("Loading Yandex Turbo Cache handler");
        new ExtensionApplicator(
          document,
          redirectYandexTurboCache,
          false,
          appSettings.ignoredHostnames
        );
        break;
      case 6 /* Unknown */:
        console.debug("Falling back to generic AMP handler");
        new ExtensionApplicator(
          document,
          redirectToCanonicalVersion,
          false,
          appSettings.ignoredHostnames
        );
        break;
    }
  })();
})();
