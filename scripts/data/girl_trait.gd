@tool
class_name GirlTrait
extends Resource
## One line about her on her contact card: her type, a tag, an ability...
## Add them in her girl file → Contact Card → Traits. Shown under her address when she
## gives you her number, one after another.
## (When tags and types exist as their own data, the card can list those instead.)

## The small coloured word on the left, like "mobile" and "home" above it: type, tag, ability...
@export var kind: String = "trait"
## The trait itself, e.g. "Punk". Shown in her font.
@export var title: String = ""
## Optional short line under it, e.g. what it does.
@export_multiline var description: String = ""
## Optional little picture at the start of the row (e.g. the tag's icon).
@export var icon: Texture2D
