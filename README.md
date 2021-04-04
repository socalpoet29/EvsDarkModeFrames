World of Warcraft addon that paints a dark mode skin on the standard Blizzard Raid Frames UI. I couldn't find any existing addon that did this.

### Notice:
- Might cause weird interactions with RaidFaidMore or other addons that affect the Blizzard Default Raid Frames
- This is an alpha release and has not been tested in all enounters or for any length of time. Also my first significant addon and Lua project!
- Currently there is no UI for changing options, must be done directly through Lua

### Dependency: 
FrameXML\CompactUnitFrame.lua

### Special Thanks:
Ketho (EU-Boulderfist), author of the RaidFadeMore addon, which I studied and used as the basis for this addon (and in the end removing all of the original functionality)

## Known Issues Scratch Sheet

| Reproducable | Description |
| --- | --- |
| Sometimes | Tank frames, pets, fail to be skinned |
| Sometimes | Fails to skin when "Keep Groups Together" is disabled |
| Yes | Power bars get covered by health bar |
| Sometimes | Occasional lua errors/wonkiness when messing around a bunch with profile or settings |
| Sometimes | Sometimes damage bar briefly displays to right of frame |
| Sometimes | Dead players have small health bar |
| Yes | Raid icons fail to display, usually on OoR units, or tanks |
| No | Skin fails to display on individual unit(s)|
| Yes | Using tank frames causing a ton of refreshes when tank has a target |
| N/A | Seems to have more issues when group is in flux, i.e. people coming and going |
| N/A | Need to investigate possible sources of large amounts of Role events (i.e. init); queue for raid finder seems to be one |
| N/A | Clearer display for OoR, dead, raid debuff (i.e. miasma, artificer mc) |
| N/A | Hide OoF inc heals |
| Sometimes | Wonks out until reload |

showed OoR for player who joined late??

Forgeborne Reveries, Possession

Looks bad with border