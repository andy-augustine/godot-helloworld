## Container <- Control

Base class for all GUI containers. A Container automatically arranges its child controls in a certain way. This class can be inherited to make custom container types.

**Props:**
- accessibility_region: bool = false
- mouse_filter: int (Control.MouseFilter) = 1
- propagate_maximum_size: bool = true

**Methods:**
- fit_child_in_rect(child: Control, rect: Rect2) - Fit a child control in a given rect.
- queue_sort() - Queue resort of the contained children.

**Signals:**
- pre_sort_children
- sort_children

**Enums:**
**Constants:** NOTIFICATION_PRE_SORT_CHILDREN=50, NOTIFICATION_SORT_CHILDREN=51

