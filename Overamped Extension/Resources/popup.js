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
          console.error(`Failed to migrate ignored hostnames ${hostnames}`, error);
          reject(error);
        });
      });
    }
  };

  // popup.ts
  var toggleAllowListButton = document.getElementById("toggleAllowListButton");
  var googleContentContainer = document.getElementById("googleContent");
  var nonGoogleContentContainer = document.getElementById("nonGoogleContent");
  var currentPageDomainSpans = document.getElementsByClassName("currentPageDomain");
  var replacedLinksCountSpans = document.getElementsByClassName("replacedLinksCount");
  var toggleAllowListButtonExplanation = document.getElementById("toggleAllowListButtonExplanation");
  var submitFeedbackButton = document.getElementById("submitFeedback");
  var nativeAppCommunicator = new NativeAppCommunicator();
  var settingsPromise = nativeAppCommunicator.ignoredHostnames();
  var currentTabPromise = browser.tabs.getCurrent();
  Promise.all([settingsPromise, currentTabPromise]).then(([ignoredHostnames, currentTab]) => {
    console.debug("Loaded ignored hostnames", ignoredHostnames);
    configurePage(ignoredHostnames, currentTab);
  }).catch((error) => {
    console.error(error);
    alert(error);
  });
  function configurePage(ignoredHostnames, currentTab) {
    const currentTabURL = currentTab.url;
    if (!currentTabURL) {
      toggleAllowListButtonExplanation.innerText = "Overamped is not available for the current page.";
      toggleAllowListButton.hidden = true;
      googleContentContainer.hidden = true;
      return;
    }
    submitFeedbackButton.onclick = () => {
      openSubmitFeedbackPage(currentTabURL);
      return false;
    };
    if (currentTab.id) {
      browser.tabs.executeScript(currentTab.id, {
        code: `document.body.dataset.overampedReplacedLinksCount`
      }).then((result) => {
        console.log("result", result);
        if (result.length === 1, typeof result[0] === "string") {
          const replacedLinksCount = parseInt(result[0]);
          showGoogleUI(replacedLinksCount);
        } else {
          showNonGoogleUI(ignoredHostnames, currentTabURL);
        }
      }).catch((error) => {
        console.error("Failed to execute script", error);
      });
    } else {
      showNonGoogleUI(ignoredHostnames, currentTabURL);
    }
  }
  function openSubmitFeedbackPage(currentTabURL) {
    const feedbackURL = new URL("overamped:feedback");
    if (currentTabURL) {
      feedbackURL.searchParams.append("url", currentTabURL);
    }
    browser.tabs.create({ url: feedbackURL.toString() });
  }
  function showGoogleUI(replacedLinksCount) {
    googleContentContainer.hidden = false;
    nonGoogleContentContainer.hidden = true;
    Array.from(replacedLinksCountSpans).forEach((span) => {
      span.innerText = `${replacedLinksCount}`;
    });
  }
  function showNonGoogleUI(ignoredHostnames, currentTabURL) {
    toggleAllowListButton.hidden = false;
    googleContentContainer.hidden = true;
    nonGoogleContentContainer.hidden = false;
    const currentURL = new URL(currentTabURL);
    Array.from(currentPageDomainSpans).forEach((span) => {
      span.innerText = currentURL.hostname;
    });
    if (ignoredHostnames.includes(currentURL.hostname)) {
      toggleAllowListButton.innerText = `Enable Overamped on ${currentURL.hostname}`;
      toggleAllowListButton.onclick = () => {
        toggleAllowListButton.disabled = true;
        nativeAppCommunicator.removeIgnoredHostname(currentURL.hostname).then(() => {
          console.info(`${currentURL.hostname} has been removed from ignore list`);
        }).catch((error) => {
          console.error("Failed to save settings", error);
        }).finally(() => {
          toggleAllowListButton.disabled = false;
        });
        return false;
      };
    } else {
      toggleAllowListButton.innerText = `Disable Overamped on ${currentURL.hostname}`;
      toggleAllowListButton.onclick = () => {
        toggleAllowListButton.disabled = true;
        nativeAppCommunicator.ignoreHostname(currentURL.hostname).then(() => {
          console.info(`${currentURL.hostname} has been added to ignore list`);
        }).catch((error) => {
          console.error("Failed to save settings", error);
        }).finally(() => {
          toggleAllowListButton.disabled = false;
        });
        return false;
      };
    }
  }
  Array.from(document.querySelectorAll("a")).forEach((anchor) => {
    anchor.onclick = () => {
      browser.tabs.create({ url: anchor.href });
      return false;
    };
  });
})();
