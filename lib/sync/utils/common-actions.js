import clone from './clone'

export function buildBaseAttributesAction (
  item, diff, oldObj, newObj, patchFn
) {
  const key = item.key // e.g.: name, description, ...
  const delta = diff[key]
  const before = oldObj[key]
  const now = newObj[key]

  if (!delta) return undefined

  if (!now && !before) return undefined

  if (now && !before) // no value previously set
    return { action: item.action, [key]: now }

  if (!now && !newObj.hasOwnProperty(key)) // no new value
    return undefined

  if (!now && newObj.hasOwnProperty(key)) // value unset
    return { action: item.action }

  // We need to clone `before` as `patch` will mutate it
  const patched = patchFn(clone(before), delta)
  return { action: item.action, [key]: patched }
}

export function actionsMapCustom (diff, oldObj, newObj, patchFn) {
  let actions = []
  if (!diff.custom) return actions

  if (diff.custom.type && diff.custom.type.id)
    actions.push({
      action: 'setCustomType',
      type: {
        typeId: 'type',
        id: Array.isArray(diff.custom.type.id)
          ? patchFn.getDeltaValue(diff.custom.type.id)
          : newObj.custom.type.id,
      },
      fields: Array.isArray(diff.custom.fields) ?
        patchFn.getDeltaValue(diff.custom.fields) : newObj.custom.fields,
    })
  else if (diff.custom.fields) {
    const customFieldsActions = Object.keys(diff.custom.fields).map(name => ({
      action: 'setCustomField',
      name,
      value: Array.isArray(diff.custom.fields[name])
        ? patchFn.getDeltaValue(diff.custom.fields[name])
        : newObj.custom.fields[name],
    }))
    actions = actions.concat(customFieldsActions)
  }

  return actions
}
