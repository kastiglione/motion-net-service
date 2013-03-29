class NetServiceBrowser
  def initialize(search_type, options={})
    default_options = {
      search_type: search_type,
      domain: ""
    }
    @options = options.merge(default_options)

    @net_service_browser = NSNetServiceBrowser.alloc.init
    @net_service_browser.setDelegate(self)
  end

  [
    :on_will_search,
    :on_did_find_domain, :on_did_remove_domain, :on_did_find_service, :on_did_remove_service,
    :on_did_not_search, :on_did_stop_search
  ].each do |callback|
    define_method callback do |&block|
      instance_variable_set("@#{callback}", block)
    end
  end

  def search
    @net_service_browser.searchForServicesOfType @options[:search_type], inDomain: @options[:domain]
  end

  def netServiceBrowser(netServiceBrowser, didFindService: service, moreComing: moreComing)
    @on_did_find_service.call(NetService.from_ns_net_service(service), moreComing) if @on_did_find_service
  end

  def netServiceBrowser(netServiceBrowser, didNotSearch: errorInfo)
    p errorInfo
  end
end