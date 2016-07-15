import forEach from 'lodash.foreach'
import { buildBaseAttributesAction } from './utils/common-actions'
import * as diffpatcher from './utils/diffpatcher'

function actionsBaseList () {
  return [
    { action: 'changeName', key: 'name' },
    { action: 'changeSlug', key: 'slug' },
    { action: 'setDescription', key: 'description' },
    { action: 'changeOrderHint', key: 'orderHint' },
    { action: 'setExternalId', key: 'externalId' },
  ]
}

function actionsMetaList () {
  return [
    { action: 'setMetaTitle', key: 'metaTitle' },
    { action: 'setMetaKeywords', key: 'metaKeywords' },
    { action: 'setMetaDescription', key: 'metaDescription' },
  ]
}

/**
 * SYNC FUNCTIONS
 */

export function actionsMapBase (diff, oldObj, newObj) {
  const actions = []

  forEach(actionsBaseList(), item => {
    const action = buildBaseAttributesAction(
      item, diff, oldObj, newObj, diffpatcher.patch
    )
    if (action) actions.push(action)
  })

  return actions
}

export function actionsMapReferences (diff, oldObj, newObj) {
  const actions = []
  if (!diff.parent) return actions

  actions.push({
    action: 'changeParent',
    parent: Array.isArray(diff.parent) ?
      diffpatcher.getDeltaValue(diff.parent) : newObj.parent,
  })
  return actions
}

export function actionsMapMeta (diff, oldObj, newObj) {
  const actions = []

  forEach(actionsMetaList(), item => {
    const action = buildBaseAttributesAction(
      item, diff, oldObj, newObj, diffpatcher.patch
    )
    if (action) actions.push(action)
  })

  return actions
}
