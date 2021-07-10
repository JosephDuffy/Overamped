export {}

declare global {
  interface Array<T> {
    compactMap<U>(
      callbackfn: (value: T, index: number, array: T[]) => U | null | undefined,
    ): Array<U>
  }
}

Array.prototype.compactMap = function compactMap<U, T>(
  callbackfn: (value: T, index: number, array: T[]) => U | null | undefined,
) {
  const mappedArray: U[] = []

  this.forEach((value, index, array) => {
    const mappedValue = callbackfn(value, index, array)

    if (mappedValue !== undefined && mappedValue !== null) {
      mappedArray.push(mappedValue)
    }
  })

  return mappedArray
}
