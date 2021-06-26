// eslint-disable-next-line @typescript-eslint/no-non-null-assertion
const pageURLElement = document.getElementById("currentPage")!;

browser.tabs.getCurrent().then((currentTab) => {
  if (currentTab.url) {
    pageURLElement.innerText = currentTab.url;
  } else {
    pageURLElement.innerText = "Failed to load URL";
  }
});
