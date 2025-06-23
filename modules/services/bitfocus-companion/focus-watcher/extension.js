/* extension.js
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * SPDX-License-Identifier: GPL-2.0-or-later
 */
import {Extension} from 'resource:///org/gnome/shell/extensions/extension.js';
const Soup         = imports.gi.Soup;
const Shell        = imports.gi.Shell;
const GLib   = imports.gi.GLib;

export default class PlainExampleExtension extends Extension {
    constructor() {
        super(...arguments);
        this._signalId = 0;
        this._session  = new Soup.Session();
        this._tracker  = Shell.WindowTracker.get_default();
    }

    enable() {
        // Whenever the focused window changes…
        this._signalId = global.display.connect(
            'notify::focus-window',
            this._onFocusChanged.bind(this)
        );
    }

    disable() {
        if (this._signalId) {
            global.display.disconnect(this._signalId);
            this._signalId = 0;
        }
    }

    _onFocusChanged() {
        // Grab the newly focused Meta.Window
        let win = global.display.focus_window;

        // Map it to its Shell.App (may be null if no window)
        let app = win ? this._tracker.get_window_app(win) : null;

        // Get an identifier (e.g. com.github.gnome.Terminal.desktop)
        let appId = app ? app.get_id() : 'none';

        // Fire off your network request
        this._sendNetworkRequest(appId);
    }

    _sendNetworkRequest(windowId) {
        console.warn(windowId)
        // Build your GET URL however you need
        let uri = `http://127.0.0.1:8000/api/custom-variable/active_application/value?value=${encodeURIComponent(windowId)}`;
        let message = Soup.Message.new('POST', uri);

        // Async send — errors get logged to looking glass
        this._session.send_async(message, GLib.PRIORITY_DEFAULT, null, null, null);
    }
}
