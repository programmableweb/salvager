require_relative './lib/salvager'
require_relative './lib/transformer'

task :salvage do
  Salvager.run
end

task :transform do
  Transformer.run
end

task :salvage_transform do
  Salvager.run
  Transformer.run
end