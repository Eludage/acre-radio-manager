[h1]Acre Radio Manager: Radio Settings Management[/h1]

[b]Acre Radio Manager[/b] is a client-side mod for Arma 3 that gives players a single interface to manage all their ACRE radio settings without diving into individual radio menus.

[h2]Features[/h2]

[list]
[*][b]Inventory overview[/b] — all ACRE radios currently in your inventory displayed in a single panel with their key settings at a glance.
[*][b]PTT assignment[/b] — assign radios to Push-To-Talk keys 1, 2, or 3 with smart swapping logic that prevents duplicate PTT assignments.
[*][b]Ear assignment[/b] — switch any radio between left, center, and right ear output in one click.
[*][b]Channel control[/b] — change channels with +/- buttons or type a channel number directly (supported radios: AN/PRC-117F, AN/PRC-152). Two-digit input applies immediately.
[*][b]Volume control[/b] — set per-radio volume in 10% increments using +/- buttons or by typing a value directly.
[*][b]Immediate application[/b] — all changes take effect instantly, no Save button required.
[*][b]Radio preview panel[/b] — compare settings side by side with a live or savestate-loaded preview.
[*][b]Savestate system[/b] — save named radio configurations and restore them at any time. Savestates are matched to radios by type, not position, so they survive inventory reorders.
[*][b]Copy settings[/b] — copy settings from any preview radio directly onto a matching inventory radio.
[*][b]Last Presets auto-save[/b] — your radio configuration at dialog close is always preserved and reloadable. (Helpful after a game crash or after reloading your kit in the Arsenal)
[*][b]Client-side only[/b] — no server setup or other player requirements.
[/list]

[h2]Supported Radio Types[/h2]

All ACRE radios support PTT assignment, ear assignment, and volume control. Channel changing is supported on:
[list]
[*][b]AN/PRC-117F[/b] — full support including direct channel input
[*][b]AN/PRC-152[/b] — full support including direct channel input
[/list]
Other radio types (AN/PRC-343, AN/PRC-148, AN/PRC-77, Baofeng 888S, etc.) show a "Radio not supported" label in the channel section but remain fully functional for all other settings.

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
[*][b]Radio power state[/b] is read-only. The ACRE API does not expose a method to toggle radio power programmatically, so the power indicator in the UI is informational only. Savestates do not save or restore power state.
[*][b]Maximum 12 radios[/b] are shown in the inventory panel. If you carry more, a hint is displayed and only the first 12 are listed.
[*][b]Channel support[/b] is limited to AN/PRC-117F and AN/PRC-152. All other radios show a "Radio not supported" label in the channel field.
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