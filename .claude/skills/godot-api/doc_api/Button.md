## Button <- BaseButton

Button is the standard themed button. It can contain text and an icon, and it will display them according to the current Theme. **Example:** Create a button and connect a method that will be called when the button is pressed: See also BaseButton which contains common properties and methods associated with this node. **Note:** Buttons support multitouch via touch input, allowing multiple buttons to be pressed at the same time. Otherwise, mouse input is used, limiting interaction to one button press at a time.

**Props:**
- alignment: int (HorizontalAlignment) = 1
- autowrap_mode: int (TextServer.AutowrapMode) = 0
- autowrap_trim_flags: int (TextServer.LineBreakFlag) = 128
- clip_text: bool = false
- expand_icon: bool = false
- flat: bool = false
- icon: Texture2D
- icon_alignment: int (HorizontalAlignment) = 0
- language: String = ""
- text: String = ""
- text_direction: int (Control.TextDirection) = 0
- text_overrun_behavior: int (TextServer.OverrunBehavior) = 0
- vertical_icon_alignment: int (VerticalAlignment) = 1

