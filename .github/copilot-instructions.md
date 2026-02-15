---
applyTo: '**'
---
# Copilot / Assistant Instructions

- Applies to all edits made by an automated assistant working in this repository.

## Big Picture idea of this project
This project is an Arma 3 mod that allows Players to manage their Acre Radio settings. This includes showing all radios currently in the player's inventory and change settings for each radio like
- what ear is the radio on
- what channel is the radio on
- what volume is the radio on

It should also be possible to save and load radio presets as well as reload the last used settings.

This is purely a client-side mod.

## Must follow
- Ensure that each display and control element in the dialogs.hpp file is correctly referenced in the DEVELOPMENT.md documentation.
- Each function created in the functions/ directory must have a corresponding entry in the config.cpp file.
- Each function must always include a short description comment at the start of the file explaining its purpose. The comment should be in the following format:
```
/*
 * Author: Eludage
 * Opens the Acre Radio Manager dialog [short description of what the function does].
 *
 * Arguments:
 * None
 *
 * Return Value:
 * Boolean: true on success, false on failure
 *
 * Example:
 * [] call AcreRadioManager_fnc_openRadioSettings;
 */
 ```
- When assigining colors or sizes, always use makros or defined constants at the beginning of the function.
- Each namespace and variable used in it must be defined in the DEVELOPMENT.md file.

## Style & formatting
- SQF files: use tabs for indentation and keep existing file style.
- Keep edits minimal and focused; prefer multiple small PRs over big changes.
- Never exit a function with an empty body instead return a boolean that indicates success.

## Safety & privacy
- Never add secrets, tokens, or credentials to the repo.
- Avoid publishing sensitive data.

## How to behave
- When in doubt, ask the repo owner before making invasive changes.
- Provide short progress updates after batches of edits and before long-running operations.
- When creating or editing files, include a concise explanation of the change in the commit message or PR description.

## Location
- This file lives at `.github/copilot-instructions.md` to be picked up by tools and agent integrations.