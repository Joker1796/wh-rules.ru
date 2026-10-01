// Share links for the 2.7.9 screenshot lists (see 2026-10-01-release-2.7.9.md).
// Run from the hub root: ORIGIN=https://wh-rules.ru node journal/active/2026-10-01-release-2.7.9.links.mjs
// Wargear picks are found by item name in wh11ed's generated roster data, so the links follow the
// data the checkout has — rebuild them after a data bump.
import { deflateRawSync } from 'node:zlib'
import path from 'node:path'

const ORIGIN = process.env.ORIGIN || 'http://localhost:5173'
const W = path.resolve('wh11ed/src/data/roster') + '/'
const items = (await import(W + 'items.js')).default.items
const key = (s) => String(s || '').toLowerCase().replace(/[’‘]/g, "'").replace(/\p{Pd}/gu, '-').trim()
const facs = {}
const fac = async (slug) => (facs[slug] ||= (await import(W + slug + '.js')).default)

function pick(def, item) {
  for (const [gi, g] of (def.gear || []).entries()) {
    for (const [oi, o] of (g.o || []).entries()) {
      if (JSON.stringify(o).match(/\d+/g)?.some((id) => key(items[id]) === key(item))) return [gi, oi]
    }
  }
  throw new Error(`${def.id} has no ${item}`)
}

let n = 0
async function unit(slug, id, size, picks = []) {
  const def = (await fac(slug)).units.find((u) => u.id === id)
  if (!def) throw new Error(`no unit ${id}`)
  return { uid: `u${++n}`, id, size, wg: picks.map(([it, c]) => [...pick(def, it), c]) }
}

async function list(name, slug, units) {
  const f = await fac(slug)
  const r = { v: 8, name, faction: slug, detachments: [f.detachments[0].name], battleSize: 'strike-force', notes: '', units }
  const payload = `1.${deflateRawSync(Buffer.from(JSON.stringify(r))).toString('base64url')}`
  console.log(`${name}\n${ORIGIN}/ru/roster/shared#r=${payload}\n`)
}

await list('Тест: щиты SM', 'space-marines', [
  await unit('space-marines', 'terminator-assault-squad', 1, [['Storm Shield', 3]]),
  await unit('space-marines', 'terminator-assault-squad', 0, [['Storm Shield', 5]]),
  await unit('space-marines', 'vanguard-veteran-squad-with-jump-packs', 0, [['Plasma pistol', 1]]),
  await unit('space-marines', 'captain', 0, [['Relic Shield', 1]]),
])
await list('Тест: Reavers', 'drukhari', [await unit('drukhari', 'reavers', 1, [['Grav-talon', 1]])])
await list('Тест: Mortifiers', 'adepta-sororitas', [await unit('adepta-sororitas', 'mortifiers', 1, [['Anchorite Sarcophagus', 1]])])
await list('Тест: Ridgerunners', 'genestealer-cults', [await unit('genestealer-cults', 'achilles-ridgerunners', 1, [['Spotter', 1], ['Heavy mortar', 1]])])
await list('Тест: Custodian Guard', 'adeptus-custodes', [await unit('adeptus-custodes', 'custodian-guard', 1, [['Praesidium Shield', 2]])])
