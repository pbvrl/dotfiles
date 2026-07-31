config.load_autoconfig(True)
c.colors.statusbar.normal.bg = "#222828"
c.colors.statusbar.normal.fg = "#a8a8a8"
c.colors.statusbar.url.fg = "#a8a8a8"
c.colors.statusbar.url.success.https.fg = "#a8a8a8"
c.colors.tabs.bar.bg = "#222828"
c.colors.tabs.even.bg = "#222828"
c.colors.tabs.even.fg = "#a8a8a8"
c.colors.tabs.odd.bg = "#222828"
c.colors.tabs.odd.fg = "#a8a8a8"
c.colors.tabs.selected.even.bg = "#222828"
c.colors.tabs.selected.even.fg = "#00ff00"
c.colors.tabs.selected.odd.bg = "#222828"
c.colors.tabs.selected.odd.fg = "#00ff00"
c.colors.tabs.pinned.even.bg = "#222828"
c.colors.tabs.pinned.even.fg = "#a8a8a8"
c.colors.tabs.pinned.odd.bg = "#222828"
c.colors.tabs.pinned.odd.fg = "#a8a8a8"
c.colors.tabs.pinned.selected.even.bg = "#222828"
c.colors.tabs.pinned.selected.even.fg = "#00ff00"
c.colors.tabs.pinned.selected.odd.bg = "#222828"
c.colors.tabs.pinned.selected.odd.fg = "#00ff00"
c.colors.webpage.darkmode.enabled = False
c.content.canvas_reading = False
c.content.geolocation = False
c.content.headers.accept_language = "en-US,en;q=0.5"
c.content.headers.custom = {
    "accept": "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8"
}
c.content.headers.user_agent = "Mozilla/5.0 ({os_info}) AppleWebKit/{webkit_version} (KHTML, like Gecko) {upstream_browser_key}/{upstream_browser_version_short} Safari/{webkit_version}"
c.content.javascript.clipboard = "access"
c.content.pdfjs = True
c.content.webgl = True
c.content.webrtc_ip_handling_policy = "default-public-interface-only"
c.editor.command = ["hx", "{file}"]
c.fonts.statusbar = "9pt default_family"
c.fonts.tabs.selected = "12pt default_family"
c.fonts.tabs.unselected = "12pt default_family"
c.hints.leave_on_load = True
c.qt.args = ["--disable-gpu"]
c.scrolling.smooth = False
c.statusbar.padding = {"top": 5, "bottom": 5, "left": 0, "right": 0}
c.statusbar.position = "top"
c.statusbar.show = "always"
c.statusbar.widgets = ["search_match", "url", "progress"]
c.tabs.favicons.scale = 1.2
c.tabs.indicator.width = 0
c.tabs.padding = {"top": 12, "bottom": 12, "left": 2, "right": 0}
c.tabs.position = "left"
c.tabs.title.format = "{audio} {current_title}"
c.tabs.width = "12%"
c.url.default_page = "about:blank"
c.url.searchengines = {"DEFAULT": "https://www.google.com/search?q={}"}
c.url.start_pages = ["about:blank"]
c.window.hide_decoration = True
