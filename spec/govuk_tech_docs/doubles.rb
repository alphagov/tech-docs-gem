def create_resource_double(**kwargs)
  resource = instance_double(Middleman::Sitemap::Resource, **kwargs)
  allow(resource).to receive(:is_a?).with(Middleman::Sitemap::Resource).and_return(true)
  resource
end
