export interface SettingsPayload {
  readonly settings: Record<string, unknown>
}

export interface RedirectOnlySettingsPayload extends SettingsPayload {
  readonly settings: Record<string, unknown> & { redirectOnly: boolean }
}

export interface IgnoredHostnamesSettingsPayload extends SettingsPayload {
  readonly settings: Record<string, unknown> & { ignoredHostnames: string[] }
}

export function objectIsSettingsPayload(
  // eslint-disable-next-line @typescript-eslint/ban-types
  object: object,
): object is SettingsPayload {
  return Object.prototype.hasOwnProperty.call(object, "settings")
}

export function settingsPayloadHasRedirectOnlySetting(
  object: SettingsPayload,
): object is RedirectOnlySettingsPayload {
  return (
    Object.prototype.hasOwnProperty.call(object.settings, "redirectOnly") &&
    typeof object.settings.redirectOnly === "boolean"
  )
}

export function settingsPayloadHasIgnoredHostnamesSetting(
  object: SettingsPayload,
): object is IgnoredHostnamesSettingsPayload {
  return (
    Object.prototype.hasOwnProperty.call(object.settings, "ignoredHostnames") &&
    Array.isArray(object.settings.ignoredHostnames)
  )
}
