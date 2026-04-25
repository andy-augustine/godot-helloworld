## LineEdit <- Control

LineEdit provides an input field for editing a single line of text. - When the LineEdit control is focused using the keyboard arrow keys, it will only gain focus and not enter edit mode. - To enter edit mode, click on the control with the mouse, see also `keep_editing_on_text_submit`. - To exit edit mode, press `ui_text_submit` or `ui_cancel` (by default [kbd]Escape[/kbd]) actions. - Check `edit`, `unedit`, `is_editing`, and `editing_toggled` for more information. While entering text, it is possible to insert special characters using Unicode, OEM or Windows alt codes: - To enter Unicode codepoints, hold [kbd]Alt[/kbd] and type the codepoint on the numpad. For example, to enter the character `á` (U+00E1), hold [kbd]Alt[/kbd] and type [kbd]+E1[/kbd] on the numpad (the leading zeroes can be omitted). - To enter OEM codepoints, hold [kbd]Alt[/kbd] and type the code on the numpad. For example, to enter the character `á` (OEM 160), hold [kbd]Alt[/kbd] and type `160` on the numpad. - To enter Windows codepoints, hold [kbd]Alt[/kbd] and type the code on the numpad. For example, to enter the character `á` (Windows 0225), hold [kbd]Alt[/kbd] and type [kbd]0[/kbd], [kbd]2[/kbd], [kbd]2[/kbd], [kbd]5[/kbd] on the numpad. The leading zero here must **not** be omitted, as this is how Windows codepoints are distinguished from OEM codepoints. **Important:** - Focusing the LineEdit with `ui_focus_next` (by default [kbd]Tab[/kbd]) or `ui_focus_prev` (by default [kbd]Shift + Tab[/kbd]) or `Control.grab_focus` still enters edit mode (for compatibility). LineEdit features many built-in shortcuts that are always available ([kbd]Ctrl[/kbd] here maps to [kbd]Cmd[/kbd] on macOS): - [kbd]Ctrl + C[/kbd]: Copy - [kbd]Ctrl + X[/kbd]: Cut - [kbd]Ctrl + V[/kbd] or [kbd]Ctrl + Y[/kbd]: Paste/"yank" - [kbd]Ctrl + Z[/kbd]: Undo - [kbd]Ctrl + ~[/kbd]: Swap input direction. - [kbd]Ctrl + Shift + Z[/kbd]: Redo - [kbd]Ctrl + U[/kbd]: Delete text from the caret position to the beginning of the line - [kbd]Ctrl + K[/kbd]: Delete text from the caret position to the end of the line - [kbd]Ctrl + A[/kbd]: Select all text - [kbd]Up Arrow[/kbd]/[kbd]Down Arrow[/kbd]: Move the caret to the beginning/end of the line On macOS, some extra keyboard shortcuts are available: - [kbd]Cmd + F[/kbd]: Same as [kbd]Right Arrow[/kbd], move the caret one character right - [kbd]Cmd + B[/kbd]: Same as [kbd]Left Arrow[/kbd], move the caret one character left - [kbd]Cmd + P[/kbd]: Same as [kbd]Up Arrow[/kbd], move the caret to the previous line - [kbd]Cmd + N[/kbd]: Same as [kbd]Down Arrow[/kbd], move the caret to the next line - [kbd]Cmd + D[/kbd]: Same as [kbd]Delete[/kbd], delete the character on the right side of caret - [kbd]Cmd + H[/kbd]: Same as [kbd]Backspace[/kbd], delete the character on the left side of the caret - [kbd]Cmd + A[/kbd]: Same as [kbd]Home[/kbd], move the caret to the beginning of the line - [kbd]Cmd + E[/kbd]: Same as [kbd]End[/kbd], move the caret to the end of the line - [kbd]Cmd + Left Arrow[/kbd]: Same as [kbd]Home[/kbd], move the caret to the beginning of the line - [kbd]Cmd + Right Arrow[/kbd]: Same as [kbd]End[/kbd], move the caret to the end of the line **Note:** Caret movement shortcuts listed above are not affected by `shortcut_keys_enabled`.

**Props:**
- alignment: int (HorizontalAlignment) = 0
- backspace_deletes_composite_character_enabled: bool = false
- caret_blink: bool = false
- caret_blink_interval: float = 0.65
- caret_column: int = 0
- caret_force_displayed: bool = false
- caret_mid_grapheme: bool = false
- clear_button_enabled: bool = false
- context_menu_enabled: bool = true
- deselect_on_focus_loss_enabled: bool = true
- drag_and_drop_selection_enabled: bool = true
- draw_control_chars: bool = false
- editable: bool = true
- emoji_menu_enabled: bool = true
- expand_to_text_length: bool = false
- flat: bool = false
- focus_mode: int (Control.FocusMode) = 2
- icon_expand_mode: int (LineEdit.ExpandMode) = 0
- keep_editing_on_text_submit: bool = false
- language: String = ""
- max_length: int = 0
- middle_mouse_paste_enabled: bool = true
- mouse_default_cursor_shape: int (Control.CursorShape) = 1
- placeholder_text: String = ""
- right_icon: Texture2D
- right_icon_scale: float = 1.0
- secret: bool = false
- secret_character: String = "•"
- select_all_on_focus: bool = false
- selecting_enabled: bool = true
- shortcut_keys_enabled: bool = true
- structured_text_bidi_override: int (TextServer.StructuredTextParser) = 0
- structured_text_bidi_override_options: Array = []
- text: String = ""
- text_direction: int (Control.TextDirection) = 0
- virtual_keyboard_enabled: bool = true
- virtual_keyboard_show_on_focus: bool = true
- virtual_keyboard_type: int (LineEdit.VirtualKeyboardType) = 0

**Methods:**
- apply_ime() - Applies text from the (IME) and closes the IME if it is open.
- cancel_ime() - Closes the (IME) if it is open.
- clear() - Erases the LineEdit's `text`.
- delete_char_at_caret() - Deletes one character at the caret's current position (equivalent to pressing [kbd]Delete[/kbd]).
- delete_text(from_column: int, to_column: int) - Deletes a section of the `text` going from position `from_column` to `to_column`.
- deselect() - Clears the current selection.
- edit(hide_focus: bool = false) - Allows entering edit mode whether the LineEdit is focused or not.
- get_menu() -> PopupMenu - Returns the PopupMenu of this LineEdit.
- get_next_composite_character_column(column: int) -> int - Returns the correct column at the end of a composite character like ❤️‍🩹 (mending heart; Unicode: `U+2764 U+FE0F U+200D U+1FA79`) which is comprised of more than one Unicode code point, if the caret is at the start of the composite character.
- get_previous_composite_character_column(column: int) -> int - Returns the correct column at the start of a composite character like ❤️‍🩹 (mending heart; Unicode: `U+2764 U+FE0F U+200D U+1FA79`) which is comprised of more than one Unicode code point, if the caret is at the end of the composite character.
- get_scroll_offset() -> float - Returns the scroll offset due to `caret_column`, as a number of characters.
- get_selected_text() -> String - Returns the text inside the selection.
- get_selection_from_column() -> int - Returns the selection begin column.
- get_selection_to_column() -> int - Returns the selection end column.
- has_ime_text() -> bool - Returns `true` if the user has text in the (IME).
- has_redo() -> bool - Returns `true` if a "redo" action is available.
- has_selection() -> bool - Returns `true` if the user has selected text.
- has_undo() -> bool - Returns `true` if an "undo" action is available.
- insert_text_at_caret(text: String) - Inserts `text` at the caret.
- is_editing() -> bool - Returns whether the LineEdit is being edited.
- is_menu_visible() -> bool - Returns whether the menu is visible.
- menu_option(option: int) - Executes a given action as defined in the `MenuItems` enum.
- select(from: int = 0, to: int = -1) - Selects characters inside LineEdit between `from` and `to`.
- select_all() - Selects the whole String.
- unedit() - Allows exiting edit mode while preserving focus.

**Signals:**
- editing_toggled(toggled_on: bool)
- text_change_rejected(rejected_substring: String)
- text_changed(new_text: String)
- text_submitted(new_text: String)

**Enums:**
**MenuItems:** MENU_CUT=0, MENU_COPY=1, MENU_PASTE=2, MENU_CLEAR=3, MENU_SELECT_ALL=4, MENU_UNDO=5, MENU_REDO=6, MENU_SUBMENU_TEXT_DIR=7, MENU_DIR_INHERITED=8, MENU_DIR_AUTO=9, ...
**VirtualKeyboardType:** KEYBOARD_TYPE_DEFAULT=0, KEYBOARD_TYPE_MULTILINE=1, KEYBOARD_TYPE_NUMBER=2, KEYBOARD_TYPE_NUMBER_DECIMAL=3, KEYBOARD_TYPE_PHONE=4, KEYBOARD_TYPE_EMAIL_ADDRESS=5, KEYBOARD_TYPE_PASSWORD=6, KEYBOARD_TYPE_URL=7
**ExpandMode:** EXPAND_MODE_ORIGINAL_SIZE=0, EXPAND_MODE_FIT_TO_TEXT=1, EXPAND_MODE_FIT_TO_LINE_EDIT=2

