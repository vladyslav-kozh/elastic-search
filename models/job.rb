# app/models/job.rb

require 'elasticsearch/model'

class Job < ApplicationRecord
  include Elasticsearch::Model
  include Elasticsearch::Model::Callbacks

  # Elasticsearch indexing settings and mappings
  settings index: { number_of_shards: 1, number_of_replicas: 0 } do
    mappings dynamic: 'false' do
      indexes :title, type: 'text', analyzer: 'english'
      indexes :description, type: 'text', analyzer: 'english'
      indexes :company, type: 'keyword'
      indexes :location, type: 'keyword'
    end
  end

  # Custom Elasticsearch query for searching jobs
  def self.search(query)
    __elasticsearch__.search(
      {
        query: {
          multi_match: {
            query: query,
            fields: ['title^3', 'description^2', 'company', 'location']
          }
        }
      }
    )
  end
end

# Create the Elasticsearch index for the Job model
Job.__elasticsearch__.create_index! force: true
