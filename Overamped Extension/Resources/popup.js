const toggleAllowListButton = document.getElementById("toggleAllowListButton");
const currentPageDomainSpans = document.getElementsByClassName("currentPageDomain");
const toggleAllowListButtonExplanation = document.getElementById("toggleAllowListButtonExplanation");
const settingsPromise = browser.storage.local.get("ignoredHostnames");
const currentTabPromise = browser.tabs.getCurrent();
Promise.all([settingsPromise, currentTabPromise]).then(([settings, currentTab]) => {
  console.debug("Loaded initial settings", settings);
  configurePage(Array.isArray(settings["ignoredHostnames"]) ? settings["ignoredHostnames"] : [], currentTab);
  browser.storage.onChanged.addListener((changes) => {
    if (changes["ignoredHostnames"] && changes["ignoredHostnames"].newValue) {
      console.debug("Ignored hostnames setting changed", changes["ignoredHostnames"]);
      configurePage(Array.isArray(changes["ignoredHostnames"].newValue) ? changes["ignoredHostnames"].newValue : [], currentTab);
    }
  });
}).catch((error) => {
  console.error(error);
});
function configurePage(ignoredHostnames, currentTab) {
  if (!currentTab.url) {
    toggleAllowListButtonExplanation.innerText = "Overamped is not available for the current page.";
    toggleAllowListButton.hidden = true;
    return;
  }
  toggleAllowListButton.hidden = false;
  const currentURL = new URL(currentTab.url);
  Array.from(currentPageDomainSpans).forEach((span) => {
    span.innerText = currentURL.hostname;
  });
  if (ignoredHostnames.includes(currentURL.hostname)) {
    toggleAllowListButton.innerText = `Enable Overamped on ${currentURL.hostname}`;
    toggleAllowListButton.onclick = () => {
      toggleAllowListButton.disabled = true;
      const newIgnoredHostnames = ignoredHostnames.filter((ignoredHostname) => {
        ignoredHostname !== currentURL.hostname;
      });
      browser.storage.local.set({
        ignoredHostnames: newIgnoredHostnames
      }).then(() => {
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
      const newIgnoredHostnames = [...ignoredHostnames, currentURL.hostname];
      browser.storage.local.set({
        ignoredHostnames: newIgnoredHostnames
      }).then(() => {
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
