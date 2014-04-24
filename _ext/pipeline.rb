require 'bootstrap-sass'
require 'netease-projects'
require 'netease-transform'

Awestruct::Extensions::Pipeline.new do
  extension Awestruct::Extensions::Posts.new '/news'
  extension Netease::Projects.new
  extension Awestruct::Extensions::Indexifier.new
  # Indexifier *must* come before Atomizer
  extension Awestruct::Extensions::Atomizer.new :posts, '/feed.atom'

  helper Awestruct::Extensions::Partial

  transformer Netease::Transform.new
end
