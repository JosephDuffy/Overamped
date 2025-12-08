window.open("https://overamped.app/settings")

function showWithJSMessage() {
  const withJSMessage = document.getElementById("withJSMessage")

  if (withJSMessage) {
    withJSMessage.style.display = "revert"
  }
}

if (document.readyState === "loading") {
  document.addEventListener("DOMContentLoaded", showWithJSMessage)
} else {
  showWithJSMessage()
}
