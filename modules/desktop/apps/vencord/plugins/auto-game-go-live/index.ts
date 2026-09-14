/*
 * AutoGameGoLive, a Vencord userplugin
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

import definePlugin from "@utils/types";

/*
 * On Wayland the capture source is chosen by the portal, not by Discord:
 * hyprland-game-share-picker (see modules/desktop/hyprland/share-picker) answers
 * xdg-desktop-portal-hyprland with the running game, so Discord's Go Live modal
 * comes up already holding exactly that source and the only thing left is its
 * confirm button.
 *
 * This is done in the DOM on purpose. Discord's stream-start action lives in
 * internal webpack modules that get renamed between builds; a missing selector
 * here just means the modal stays open and you press the button yourself, while
 * a missing webpack find means a broken client mod.
 */

const CONFIRM_LABEL = /^go live$/i;

// One shot per modal: after the click the modal unmounts, and a modal the user
// closed manually must not be re-confirmed.
const handled = new WeakSet<Element>();

let observer: MutationObserver | undefined;
let queued = false;

function findConfirmButton(dialog: Element): HTMLButtonElement | undefined {
    return Array.from(dialog.querySelectorAll("button")).find(button =>
        CONFIRM_LABEL.test((button.textContent ?? "").trim())
    );
}

function confirmOpenModals() {
    queued = false;

    for (const dialog of document.querySelectorAll('[role="dialog"]')) {
        if (handled.has(dialog)) continue;

        const confirm = findConfirmButton(dialog);
        if (!confirm) continue;

        // No source picked yet (more than one capturable thing, or the portal
        // dialog is still up). The observer runs again once Discord enables it.
        if (confirm.disabled || confirm.getAttribute("aria-disabled") === "true") continue;

        handled.add(dialog);
        confirm.click();
    }
}

function schedule() {
    if (queued) return;

    queued = true;
    requestAnimationFrame(confirmOpenModals);
}

export default definePlugin({
    name: "AutoGameGoLive",
    description:
        "Confirms Discord's Go Live modal for you, so clicking the screen share button starts streaming the source the portal picked",
    authors: [{ name: "tiebe", id: 0n }],

    start() {
        observer = new MutationObserver(schedule);
        observer.observe(document.body, {
            childList: true,
            subtree: true,
            attributes: true,
            attributeFilter: ["disabled", "aria-disabled"]
        });

        schedule();
    },

    stop() {
        observer?.disconnect();
        observer = undefined;
    }
});
