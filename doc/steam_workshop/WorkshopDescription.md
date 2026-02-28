[h1]Acre Radio Manager: Radio Settings Management[/h1]

[b]Acre Radio Manager[/b] is a client-side mod for Arma 3 that gives players a single interface to manage all their ACRE radio settings without diving into individual radio menus.

[h2]Features[/h2]

[list]
[*][b]Inventory overview[/b] — all ACRE radios currently in your inventory displayed in a single panel with their key settings at a glance.
[*][b]PTT assignment[/b] — assign radios to Push-To-Talk keys 1, 2, or 3 with smart swapping logic that prevents duplicate PTT assignments.
[*][b]Ear assignment[/b] — switch any radio between left, center, and right ear output in one click.
[*][b]Channel control[/b] — change channels with +/- buttons or type a channel number directly. Two-digit input applies immediately. See the radio support table below for per-type details.
[*][b]Volume control[/b] — set per-radio volume in 10% increments using +/- buttons or by typing a value directly.
[*][b]Immediate application[/b] — all changes take effect instantly, no Save button required.
[*][b]Radio preview panel[/b] — compare settings side by side with a live or savestate-loaded preview.
[*][b]Savestate system[/b] — save named radio configurations and restore them at any time. Savestates are matched to radios by type, not position, so they survive inventory reorders.
[*][b]Copy settings[/b] — copy settings from any preview radio directly onto a matching inventory radio.
[*][b]Last Presets auto-save[/b] — your radio configuration at dialog close is always preserved and reloadable. (Helpful after a game crash or after reloading your kit in the Arsenal)
[*][b]Client-side only[/b] — no server setup or other player requirements.
[/list]

[h2]Supported Radio Types[/h2]

All ACRE radios support PTT assignment, ear assignment, and volume control.

[table]
[tr][th]Radio[/th][th]Channel change[/th][th]Channel display[/th][/tr]
[tr][td]AN/PRC-117F[/td][td]+/- buttons and direct input[/td][td]N: Name[/td][/tr]
[tr][td]AN/PRC-152[/td][td]+/- buttons and direct input[/td][td]N: Name[/td][/tr]
[tr][td]AN/PRC-148[/td][td]+/- buttons only[/td][td]Gr X, Ch Y, Name[/td][/tr]
[tr][td]AN/PRC-343[/td][td]+/- buttons only[/td][td]Bl X, Ch Y, Name[/td][/tr]
[tr][td]Baofeng BF-888S[/td][td]+/- buttons only[/td][td]N: Name[/td][/tr]
[tr][td]AN/PRC-77[/td][td]Not supported[/td][td]—[/td][/tr]
[tr][td]SEM 52 SL[/td][td]Not supported[/td][td]—[/td][/tr]
[tr][td]SEM 70[/td][td]Not supported[/td][td]—[/td][/tr]
[/table]

Radios without channel support show a "Radio not supported" label in the channel field but are fully functional for all other settings. Power state is read-only for all radio types — the ACRE API does not expose a way to toggle it programmatically.

[h2]Installation[/h2]

[b]Acre Radio Manager[/b] is a client-side mod. Only players who want to use the radio management interface need to have it installed.

[olist]
[*]Subscribe to the mod on Steam Workshop
[*]Enable the mod in the Arma 3 Launcher
[*]Ensure ACRE2 and ACE3 are also enabled
[*]Launch Arma 3, join a mission with ACRE radios, and open the interface via the ACE Self-Interact menu: [b]ACRE → Manage Radio Settings[/b]
[/olist]

[b]Requirements:[/b]
[list]
[*]ACRE2
[*]ACE3
[*]CBA_A3
[/list]

[h2]Compatibility / Restrictions[/h2]

[list]
[*][b]Radio power state[/b] is read-only. See the supported radio types table above.
[*][b]Maximum 12 radios[/b] are shown in the inventory panel. If you carry more, a hint is displayed and only the first 12 are listed.
[*][b]Channel support[/b] varies by radio type — see the supported radio types table above.
[*][b]Display / interface size[/b] — the UI has been optimized and tested on [b]16:9[/b] and [b]21:9[/b] aspect ratios with [b]Small[/b] and [b]Normal[/b] interface sizes. Other aspect ratios or interface sizes are untested and may result in overlapping or cut-off UI elements.
[/list]

Other than that, there are currently no known issues.

[h2]License[/h2]

[list]
[*]You're [b]allowed[/b] to freely use this mod and/or change parts of it, although it's preferred if you create a Merge-Request in the [url=https://github.com/Eludage/acre-radio-manager]GitHub-Project[/url].
[*]You're [b]not allowed[/b] to reupload this mod without any meaningful modifications. If you're reuploading a modified version, you must give credit to this mod.
[/list]

[h2]Documentation[/h2]

All [b]Acre Radio Manager[/b] documentation is available in the mod's GitHub repository:
[list]
[*]Architecture and design decisions
[*]Development guidelines and control ID reference
[*]Namespace and variable documentation
[/list]

[h2]Issue Tracker / Bug Reports[/h2]

Please report bugs and issues on the dedicated [url=https://github.com/Eludage/acre-radio-manager/issues]GitHub issue tracker[/url].

[h2]Eludage's QoL Collection[/h2]

If you enjoy this mod, have a look at [url=https://steamcommunity.com/sharedfiles/filedetails/?id=3670450844]my other QoL mods[/url].

[h2]Credits[/h2]

[b]Author:[/b] Eludage

[b]Special Thanks:[/b]
[list]
[*]The ACRE2 team for their excellent radio simulation and public API
[*]The ACE3 team for the self-interact menu framework
[*]The Arma 3 modding community
[*][url=https://disboard.org/de/server/288446755219963914]Sigma Security Group[/url] (we're always looking for new members)
[/list]

[h2]Note on Title Image[/h2]

The title image for this workshop item is AI-generated. If you enjoy this mod and have artistic skills, feel free to create and contribute a replacement image! Contact the author or submit via the GitHub repository.

[hr][/hr]

[i]Acre Radio Manager is a community-made mod and is not affiliated with Bohemia Interactive or the ACRE2 team.[/i]