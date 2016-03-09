class AppDelegate
  def applicationDidFinishLaunching(notification)
    app_name = "ApolloStatus"
    unless NSWorkspace.sharedWorkspace.launchApplication(app_name)
      NSLog "Failed to launch #{app_name} app"
    end
    NSApp.performSelector("terminate:", withObject: nil, afterDelay: 0.0)
  end
end
