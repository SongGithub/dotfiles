# -*- encoding: utf-8 -*-

import sublime
import sublime_plugin

# disable miniMap by default

# https://forum.sublimetext.com/t/how-do-i-hide-the-minimap-by-default-in-st3/26737
# To disable miniMap by default, ensure that in `user-specific` settings of the Sublime Text, you have `"show_minimap": false,` set.
class MinimapSetting(sublime_plugin.EventListener):

    def on_activated(self, view):
        show_minimap = view.settings().get('show_minimap')
        if show_minimap:
            view.window().set_minimap_visible(True)
        elif show_minimap is not None:
            view.window().set_minimap_visible(False)