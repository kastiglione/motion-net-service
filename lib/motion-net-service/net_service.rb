class NetService
  def initialize(options = {})
    default_options = {
      domain: "",
      search_type: "_http._tcp.",
    }
    options.merge!(default_options)

    if options[:net_service]
      @net_service = options[:net_service]
    else
      @net_service = NSNetService.alloc.initWithDomain(
        options[:domain],
        type: options[:search_type],
        name: options[:name],
        port: options[:port]
      )
    end

    @net_service.setDelegate(self)
  end

  def self.from_ns_net_service(ns_net_service)
    new(:net_service => ns_net_service)
  end

  def publish
    @net_service.publish
  end

  def resolve(timeout = 1, &block)
    on_did_resolve_address(&block) if block
    @net_service.resolveWithTimeout(timeout)
  end

  [
    :on_will_publish, :on_did_not_publish, :on_did_publish, :on_will_resolve, :on_did_not_resolve,
    :on_did_resolve_address, :on_did_update_txt_record_data, :on_did_stop
  ].each do |callback|
    define_method callback do |&block|
      instance_variable_set("@#{callback}", block)
    end
  end

  def method_missing(method, *args)
    if @net_service.respond_to? method
      @net_service.send(method, *args)
    else
      super
    end
  end

protected
  def netServiceWillPublish(sender)
    @on_publish.call if @on_publish
  end

  def netService(sender, didNotPublish:errors)
    @on_did_not_publish.call(errors) if @on_did_not_publish
  end

  def netServiceDidPublish(sender)
    @on_did_publish.call if @on_did_publish
  end

  def netServiceWillResolve(sender)
    @on_will_resolve.call if @on_will_resolve
  end

  def netService(sender, didNotResolve:errors)
    @on_did_not_resolve.call(errors) if @on_did_not_resolve
  end

  def netServiceDidResolveAddress(sender)
    @on_did_resolve_address.call if @on_did_resolve_address
  end

  def netServiceDidStop(sender)
    @on_did_stop.call if @on_did_stop
  end
end
