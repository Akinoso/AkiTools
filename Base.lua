Aki = {}

Aki.version = GetAddOnMetadata('AkiTools', 'Version')

Aki.frame = CreateFrame('Frame', 'AkiFrame')
Aki.frame:Hide()
Aki.panel = CreateFrame('Frame', 'AkiPanel')
Aki.panel:Hide()
Aki.scrollFrame = CreateFrame("ScrollFrame", nil, UIParent, "UIPanelScrollFrameTemplate")
Aki.scrollFrame:Hide()