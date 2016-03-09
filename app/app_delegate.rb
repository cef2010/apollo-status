class AppDelegate
  attr_accessor :status_menu

  def applicationDidFinishLaunching(notification)
    #Sets up initial state of StatusBar Item
    @display_detailed = false
    @login_enabled = login_status == 1 ? true : false
    #Builds Apollo Icon
    @menu_icon = NSImage.imageNamed("apollo-icon")
    @menu_icon.setTemplate('YES')
    #Initializes Menu
    @status_menu = NSMenu.new
    #Builds StatusBar Item
    @status_item = NSStatusBar.systemStatusBar.statusItemWithLength(NSVariableStatusItemLength).init
    @status_item.setMenu(@status_menu)
    @status_item.setHighlightMode(true)
    #Sets Initial Display
    toggle_display
    #Builds Toggle Display Item
    @display_item = createMenuItem("Toggle Status Display", 'display_click')
    @display_item.checked = false
    #Builds Open On Login Item
    @open_on_login = createMenuItem("Open on login", "on_login_click")
    @open_on_login.checked = @login_enabled
    #Adds MenuItems to Menu
    @status_menu.addItem(@display_item)
    @status_menu.addItem(@open_on_login)
    @status_menu.addItem(NSMenuItem.separatorItem)
    @status_menu.addItem createMenuItem("Quit", 'terminate:')

  end

  def createMenuItem(name, action)
    NSMenuItem.alloc.initWithTitle(name, action: action, keyEquivalent: '')
  end

  def on_login_click
    change_login_status
    @open_on_login.checked = login_status == 1 ? true : false
    start_at_login(@open_on_login.checked)
  end

  def login_status #Returns 1 if saved pref openOnLogin is true : 0
    d = YAML.load(File.read("#{App.resources_path}/prefs.yml"))
    d['openOnLogin']
  end

  def change_login_status #Writes opposite status to prefs.yml
    d = YAML.load(File.read("#{App.resources_path}/prefs.yml"))
    d['openOnLogin'] = d['openOnLogin'] == 1 ? 0 : 1
    File.open("#{App.resources_path}/prefs.yml", 'w') {|f| f.write d.to_yaml }
  end

  def start_at_login(enabled) #Writes login status bool to OSX
    url = NSBundle.mainBundle.bundleURL.URLByAppendingPathComponent("Contents/Library/LoginItems/ApolloStatus-app-launcher.app") # path
    LSRegisterURL(url, true)
    unless SMLoginItemSetEnabled("com.your-name.ApolloStatus-app-launcher", enabled) # identifier
      NSLog "SMLoginItemSetEnabled failed!"
    end
  end

  def display_click
    @display_item.checked = !@display_item.checked
    toggle_display
  end

  def toggle_display
    kill_timer if @timer != nil
    if @display_detailed
      set_spotify_status
    else
      @status_item.setTitle(nil)
      @status_item.setImage(@menu_icon)
    end
    @display_detailed = !@display_detailed
  end

  def kill_timer
    @timer.invalidate()
    @timer = nil
  end

  def spotify_on
    check = "'if application \"Spotify\" is running then
        return 1
    else
        return 0
    end if'"
    `osascript -e #{check}`.to_i == 1 ? true : false
  end

  def spotify_playing
    `osascript -e 'tell application "Spotify" to player state'`.gsub("\n", "") == 'playing' ? true : false
  end

  def spotify_song_info
    info = `osascript -e 'tell application "Spotify" to artist of current track'` + ": " + `osascript -e 'tell application "Spotify" to name of current track'`
    info.gsub("\n", "")
  end

  def set_spotify_status
    begin
      if spotify_on
        @status_item.setTitle(spotify_playing ? spotify_song_info : "Paused")
        @status_item.setImage(nil)
      else
        @status_item.setTitle("Spotify is not running.")
        @status_item.setImage(nil)
      end
    ensure
      @timer = NSTimer.scheduledTimerWithTimeInterval(2,
        target: self,
        selector: 'set_spotify_status',
        userInfo: nil,
        repeats: false)
    end
  end
end
