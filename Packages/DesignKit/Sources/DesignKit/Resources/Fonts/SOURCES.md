# Bundled font sources

Google Fonts repository commit `02cac32590ff3531408c3d221673d7aa32a98c11`:

- Fira Sans: https://github.com/google/fonts/tree/02cac32590ff3531408c3d221673d7aa32a98c11/ofl/firasans
- Open Sans: https://github.com/google/fonts/tree/02cac32590ff3531408c3d221673d7aa32a98c11/ofl/opensans

Fira Sans files are unmodified upstream TTFs. Open Sans static instances were
created from `OpenSans[wdth,wght].ttf` with fontTools varLib.instancer, setting
`wdth=100` and `wght=400/500/700`, with `updateFontNames=True`.
Their PostScript names are `OpenSansRoman-Regular`, `OpenSansRoman-Medium`, and
`OpenSansRoman-Bold`. File names match the supplied design reference.

Both families use SIL Open Font License 1.1. The full licenses and copyright
notices are included as `FiraSans-OFL.txt` and `OpenSans-OFL.txt`.

Reproduce each Open Sans instance with fontTools:

```python
from fontTools.ttLib import TTFont
from fontTools.varLib.instancer import instantiateVariableFont

source = TTFont("OpenSans[wdth,wght].ttf")
result = instantiateVariableFont(
    source, {"wdth": 100, "wght": 500}, updateFontNames=True
)
result.save("OpenSans-Medium.ttf")
```
