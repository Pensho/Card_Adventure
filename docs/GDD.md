# Game Design Document — Card Adventure

**Status:** Draft v0.6
**Last updated:** 2026-04-22

---

## 1. Concept

A roguelike deckbuilder where a small party of characters descends into a dungeon that should not exist. Your deck is not built by drafting cards — it is built by equipping gear. Every weapon, piece of armour, and trinket your characters carry adds cards to your shared deck. Some equipment is safe; some is powerful but cursed, adding negative cards that can sabotage you at the worst moment. The world is non-conventional fantasy edging into cosmic horror: not frightening, but wrong. Uncomfortable. The dungeon does not follow the rules of a place that was built — it follows the logic of something that grew.

---

## 2. Genre & Inspiration

- **Genre:** Roguelike deckbuilder, dungeon crawler
- **Inspirations:**
  - *Slay the Spire* — card-based combat structure, run progression, clarity of information
  - *Inscryption (Act 1)* — disturbing atmosphere through contrast and shadow; the feeling that rules exist you don't fully understand; uncomfortable aesthetic choices
  - *Darkest Dungeon* — roster management (pick a party from a larger pool), psychological pressure, the sense that the dungeon is winning even when you are
- **Tone:** Cosmic horror-adjacent. Unsettling without being a horror game. The world is strange and wrong, but the gameplay is legible and strategic.
- **Story:** Lightweight but present. A grounded narrative delivered through encounters, room descriptions, and boss confrontations — not a meta-framing device.

---

## 3. Core Gameplay Loop

```
Start run → Choose 2 characters from roster
  → Descend into the dungeon
    → At each junction, choose between 2–3 unmarked passages
      → [Encounter] Play cards to defeat enemies, earn loot
      → [Loot] Equip gear → changes your deck immediately
      → [Discovery] Something happens; a choice must be made
      → [Merchant] Trade gear; remove curse cards
      → [Respite] Rest, repair gear, recover HP
    → Reach and defeat the depth's sentinel
  → Descend further (deeper, stranger)
→ Win by surviving to the final depth, or die and start over
```

**Key differentiator:** Deck changes happen through equipment decisions, not card drafts. Equipping new gear reshuffles your power immediately. Cursed and eldritch equipment adds powerful cards *and* strictly negative curse cards — the risk is baked into the item, not a separate choice.

---

## 4. Party System

### Composition
- Player picks **2 characters** from the roster at the start of each run
- Characters have individual HP — if a character is downed during combat, their cards leave the shared deck for the rest of that fight

### Character States
Rather than fixed positions (front/back), each character has an emergent **State** that changes during combat based on what happens to them. States are not chosen — they arise from play and create meaningful decisions around whether to trigger, maintain, or escape them.

| State | Triggered by | Effect |
|-------|-------------|--------|
| **Coiled** | Character has not yet acted this turn | First card played costs one less toll |
| **Wounded** | Character took damage this turn | Some cards are weaker; some class cards are stronger (Blood Mage thrives here) |
| **Committed** | Character played an aggressive card | Enemy preferentially targets this character next turn |
| **Braced** | Character played a defensive card | Reduces next instance of incoming damage |
| **Rattled** | Ally was downed, or specific enemy effects | Cards played by this character have a chance to misfire or cost an additional toll |
| **Severed** | The other character is downed | Surviving character plays alone; some cards become unavailable, others unlock |

States can stack or transition into one another. The Plague Doctor's Diagnosis can reveal which state an enemy is in, mirroring the mechanic on the player side.

### Revival
Mid-combat revival is possible but costly. It requires a **revival item** occupying one of the character's 4 equipment slots. When used, the downed character returns at low HP — but the revival item pays a price:

| Revival cost tier | Effect |
|-------------------|--------|
| **Disabled** | Item is inactive for the rest of combat; its cards are removed until the next room |
| **Damaged** | Item's cards are weakened permanently until repaired at a respite or merchant |
| **Destroyed** | Item and all its cards are removed from the run entirely |

Which tier applies depends on the item itself — revival items have their cost baked in. A cheap revival item is destroyed on use; a rare one may only disable.

Note: destroying a revival item also removes any curse cards it contributed. A cursed revival item used in desperation may be the only way to shed those curses mid-run — an intentional design interaction.

### Starter Characters
The first run begins with **Lancer and Jester** unlocked. Subject to change as the story develops — if the narrative establishes a more natural starting pair, these defaults will shift.

### Roster

Larger than the party size, giving meaningful run-to-run variety (Darkest Dungeon model). Target roster size: **5–7 characters** for v1.0, expandable. All classes are original — no conventional archetypes.

---

#### Blood Mage
Life force is not just a resource — it is a weapon and a currency. The Blood Mage's equipment blurs healing and harm: cards may cost HP instead of other tolls, deal damage scaled to missing health, or drain enemies to restore the party. Their equipment can be extremely powerful and deeply risky.

*Toll behaviour:* Many Blood Mage cards cost HP rather than exhausting other cards. The *Wounded* state amplifies rather than hinders them — some of their strongest cards are only playable while wounded.

*Thematic feel:* Sacrifice and control. Power that comes from paying a price you chose. Gets more dangerous the lower they go — and some builds lean into that deliberately.

---

#### Plague Doctor
Not a poisoner. A practitioner of wrong medicine in a place where bodies follow different rules. The Plague Doctor treats enemies and allies alike as subjects — diagnosing, extracting, experimenting. Their most powerful tools are procedures that should not work, and sometimes do not, and sometimes work on the wrong target.

*Secondary mechanic:* **Diagnosis** — a card or action that reveals an enemy's hidden state and intent icon for the rest of combat, unlocking stronger follow-up card effects. Some equipment generates cards that perform procedures: targeted debuffs, organ extractions that become one-use items mid-combat, experimental treatments with side effects.

*Cursed equipment adds:* Cards that apply the procedure to an ally instead of an enemy, or that require a party member to take damage as the "patient."

*Thematic feel:* Clinical detachment in a place that defies clinical logic. The doctor is calm. The dungeon is not. Their power comes from observation and exploitation of rules others cannot perceive.

---

#### Symbiote
Absorbs qualities from defeated enemies — gaining both their strengths and their failings as cards. Equipment for the Symbiote comes partly from enemies themselves: extracted essences, absorbed organs, grafted tissues. Their deck is the most unpredictable in the roster.

*Secondary mechanic — Absorption:* After defeating certain enemies, the Symbiote may choose to absorb a trait. Absorbing adds a positive card (the enemy's strength) and a curse card (their weakness or negative quality) to the deck permanently for the run — until the absorption is replaced.

The Symbiote has **one Absorption slot**. Replacing an existing absorption has consequences: the old positive card is immediately removed, but the old curse card **remains for 2 combats** before fading (the body takes time to reject what it has already taken).

Absorption is more powerful than standard equipment cards, but restricted by luck — the right enemy must appear and survive long enough to be a candidate. Not every enemy is absorbable; which ones are should feel slightly unpredictable.

*Thematic feel:* Something is wrong about a person who absorbs other things. The Symbiote's power is real, but so is what they are becoming.

---

#### Lancer
Momentum and commitment. The Lancer's cards are built around the physics of a charge — devastating when conditions are met, wasteful when they are not.

*Secondary mechanic:* **Momentum** — certain cards build Momentum stacks; others spend Momentum for amplified effects. The *Committed* state interacts with Momentum: being Committed while holding high Momentum unlocks the strongest Lancer effects, but also makes the Lancer a preferred target.

*Cursed lance equipment adds:* Cards that commit to an attack unconditionally — dealing large damage but also forcing the Lancer into the *Committed* state regardless.

*Thematic feel:* A weapon never meant for enclosed spaces, used in a dungeon that grows. The Lancer's power is directional, forward, committed — and the dungeon does not reward forward momentum the way an open field would.

---

#### Jester
Understands the absurdity of the situation better than anyone. The Jester's cards manipulate the order of events, alter card sequencing, and create situations other classes cannot. Their power comes from knowing what is about to happen and making it worse for the enemy.

*Secondary mechanic:* **Performance** — some cards build Performance stacks through a sequence of played cards (e.g. play 3 cards in a single turn to trigger a Performance effect). At high Performance, cards upgrade temporarily or unlock bonus effects. Missing the sequence resets the counter.

*Cursed jester equipment adds:* Cards that interrupt the Jester's own sequences — playing out of order, forcing shuffles, or triggering effects on the wrong target.

*Thematic feel:* The only one laughing. In a dungeon with cosmic horror logic, what it means to laugh at something is complicated.

---

### Roster Unlocks

Characters are not all available from the start. Three unlock routes:

| Route | How it works |
|-------|-------------|
| **Narrative** | A story event introduces the character; completing it adds them to the roster |
| **Merchant** | A character occasionally appears at a merchant between depths, offering to join for gold |
| **Reputation** | Reaching a milestone or performing a notable deed causes a character to seek you out |

The first run always begins with 2 characters already unlocked (Lancer + Jester by default). The full roster is discoverable across multiple runs.

### Party Synergies (examples)
| Pairing | Dynamic |
|---------|---------|
| Blood Mage + Symbiote | Volatile; high ceiling, high self-damage risk |
| Blood Mage + Plague Doctor | Methodical; life manipulation + wrong medicine |
| Plague Doctor + Symbiote | Absorbed conditions + wrong procedures; strange interactions |
| Lancer + Jester | Momentum + sequencing; high skill ceiling, rewarding to pilot |
| Lancer + Blood Mage | Commitment + sacrifice; hits hard, punishing when it fails |
| Jester + Symbiote | Chaos compounding chaos; unpredictable but potentially absurd power |

---

## 5. Equipment & Deck Building

### Core Mechanic
Every piece of equipment a character carries contributes cards to the shared deck. Equipping and unequipping is the primary form of deck building.

| Equipment Type | Cards Added | Risk |
|----------------|-------------|------|
| Standard item | 2–3 reliable cards | None |
| Cursed item | 1–2 powerful cards | Adds 1–2 Curse cards |
| Corrupted item | Strong cards with conditions | Adds negative-effect cards |
| Eldritch artefact | Rare, game-altering cards | Multiple curse cards; possible passive side effects |
| Symbiote absorption | Enemy ability as a card | Also absorbs enemy's negative trait as a curse card |

### Curse Cards
Negative cards that occupy deck and hand space. Most can be played, but doing so pays a toll for no benefit — or actively harms you.

Examples:
- **Wound** — costs a toll to play; does nothing
- **Tremor** — enemy gains Block when this is drawn
- **Unravelling** — take damage if this is in your hand at end of turn
- **Void** — auto-exhausts on draw; discards a random card from hand
- **Contagion** — triggers the *Rattled* state on a random party member when drawn
- **Haemorrhage** — deal damage to self equal to its toll when drawn
- **Misfire** — if played, deals half damage to a random ally instead of the intended target

Curse cards are removed by:
- Unequipping the source item
- Special respite actions
- Merchant purge services (at a cost)

### Equipment Slots (per character)
4 slots per character: **Weapon, Off-hand, Armour, Accessory** — 8 total active item slots across the party.

The Symbiote has an additional **Absorption slot** that operates outside the normal equipment system. Absorption cannot be purchased, found in chests, or sold — it is exclusively earned through combat choices.

---

## 6. Toll System

Cards do not share a universal energy cost. Each card declares its own **toll** — what must be paid to play it. Tolls vary by card and class, making each card's cost legible on the card itself rather than reduced to a number.

### Toll Types

| Toll | Description |
|------|-------------|
| **HP** | Pay life to play this card. Primary toll for Blood Mage cards. |
| **Exhaust** | Remove another card in your hand from the game (permanently) to play this. |
| **Discard** | Discard X cards from your hand to play this. |
| **Wound** | Add a Wound curse card to your discard pile to play this. |
| **Momentum** | Spend Momentum stacks (Lancer cards). |
| **Performance** | Spend Performance stacks (Jester cards). |
| **State** | Trigger a specific Character State as the cost (e.g. become *Committed*). |
| **Free** | No toll. Usually weak, situational, or carrying another hidden downside. |

A single card may have a combined toll (e.g. pay 3 HP *and* become *Committed*). Eldritch cards may have unusual or ambiguous tolls.

### Turn Limit
There is no separate energy counter. A player may play as many cards per turn as they can afford the tolls for. The tolls themselves are the limit — running out of HP to spend, Momentum to burn, or cards to exhaust naturally ends productive play. This makes deck composition and equipment choices the primary constraint, not an abstract number.

### Reversion Note
The Toll system is a design experiment. If playtesting reveals it produces confusion or imbalance that cannot be resolved, reverting to a conventional energy system remains an option.

---

## 7. Combat

### Turn Structure
1. Draw cards (~5 cards; exact hand size TBD)
2. Play cards by paying their tolls; character states update as cards are played
3. End turn → enemies execute their intent
4. Repeat until all enemies are dead or the party is wiped

### Enemy Intent
Enemies show **intent icons** each turn indicating their planned action — the icon communicates category and rough magnitude (attack, defend, debuff, deck interaction, etc.). Icons are designed to fit the game's aesthetic rather than using clean, clinical UI. Exact intent is visible; the Plague Doctor's Diagnosis ability may reveal additional hidden information beyond the base icon.

### Character State Interactions in Combat
States update at key moments:
- On taking damage → *Wounded*
- On playing an aggressive card → *Committed*
- On playing a defensive card → *Braced*
- On ending a turn without acting → *Coiled* carries into next draw
- On ally going down → *Rattled* / *Severed*

States clear at the start of the relevant character's next turn unless extended by equipment or card effects.

---

## 8. Dungeon Structure

### Unmarked Descent
There is no pre-revealed map. The dungeon is navigated junction by junction — at each point the party reaches a split and the player chooses between **2–3 passages**. Each passage has an environmental description: sounds, smells, visual detail visible from the threshold. These descriptions hint at what lies ahead, but never guarantee it. The deeper the party goes, the less reliable the clues become.

The player never sees the full structure of a depth. They learn to read the dungeon, not a UI panel.

### Depths
The dungeon is divided into **depths** — not floors in the architectural sense, but recognisable shifts in the dungeon's character. Each depth ends when the party encounters its **Sentinel**: a significant enemy or event that marks the threshold between one depth and the next. The Sentinel is not labelled as a boss — the party may not know what they are walking into.

| Depth | Character |
|-------|-----------|
| 1 | Almost normal; strangeness is in the details |
| 2 | Rules begin to shift; enemies are harder to categorise |
| 3+ | Spatial and logical coherence visibly degrades |
| Final | Does not present itself as a dungeon at all |

### Room Behaviour
Rooms do not have explicit type labels. What a room contains is discovered upon entry. Common room behaviours:

- **Encounter** — one or more enemies are present; combat resolves before anything else is possible
- **Respite** — the room offers some form of rest, recovery, or gear repair; may require something in return
- **Merchant** — a figure or mechanism that trades; may also be an enemy, or both
- **Discovery** — something is found, witnessed, or demanded; a choice with consequences
- **Empty** — nothing is immediately present; this is sometimes the most unsettling outcome

Rooms can combine behaviours (a merchant who is also hostile, a respite site that demands a toll). The deeper the descent, the more likely rooms are to behave unexpectedly.

---

## 9. UI / UX

### Screens
- Main Menu
- Character selection / Run start
- Dungeon junction view (passage choice)
- Battle scene
- Equipment screen (available at respite sites and merchants)
- Discovery / event screen
- Game Over / Victory screen

### Battle HUD
- Hand of cards at bottom
- Character portraits with HP and active State indicator
- Enemy intent icon display
- Deck / discard pile counters
- End turn button
- No energy counter (toll costs are on each card)

### Tone in UI
- UI should feel slightly wrong — not clean and friendly
- Typography, colours, and sound design reinforce unease without being obtrusive
- Intent icons are atmospheric in design, not clinical

---

## 10. Scope

### In Scope (v1.0)
- Roster of 5 characters; player picks 2 per run (Blood Mage, Plague Doctor, Symbiote, Lancer, Jester)
- Characters unlocked through play — not all available at the start
- Equipment system with card addition/removal; 4 slots per character
- Equipment tiers: standard, cursed, eldritch
- Curse cards as a distinct negative card type
- Symbiote Absorption slot with switching consequences
- Character State system (emergent, not chosen)
- Toll system replacing conventional energy
- Unmarked descent navigation (no pre-revealed map)
- Fluid room behaviour (no explicit type labels)
- 3 depths + final depth / Sentinel
- Room types: Encounter, Respite, Merchant, Discovery, Empty
- Roguelike run structure: death resets the run
- Lightweight story via discoveries and Sentinel encounters

### Out of Scope (v1.0)
- Persistent meta-progression between runs (unlocks persist; nothing else)
- Expanding roster beyond 5 characters
- Online features
- Voice acting
- More than one dungeon / biome

---

## 11. Open Questions

- [ ] **Rejection duration:** 2 combats for Symbiote absorption switching — tune in playtesting
- [ ] **Hand size:** ~5 cards feels right as a starting point; adjust in playtesting
- [ ] **Final Sentinel / win condition:** What is the thematic endpoint of the dungeon?
- [ ] **Persistent elements between runs:** Roster unlocks persist. Lore entries? Bestiary? Story state?
