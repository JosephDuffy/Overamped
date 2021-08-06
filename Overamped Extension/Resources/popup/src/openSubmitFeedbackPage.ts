export default function openSubmitFeedbackPage(currentTabURL?: string): void {
  const feedbackURL = new URL("overamped:feedback")

  if (currentTabURL) {
    feedbackURL.searchParams.append("url", currentTabURL)
  }

  window.open(feedbackURL.toString())
}
