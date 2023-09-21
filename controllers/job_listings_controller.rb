# app/controllers/job_listings_controller.rb

class JobListingsController < ApplicationController
    def index
      # Load all jobs by default
      @jobs = Job.all
    end
  
    def search
      @search_query = params[:q]
      @filter_location = params[:location]
      @filter_company = params[:company]
  
      # Build Elasticsearch query based on filters and search query
      search_definition = {
        query: build_query,
        highlight: {
          pre_tags: ['<strong>'],
          post_tags: ['</strong>'],
          fields: { title: {}, description: {} }
        },
        sort: build_sort
      }
  
      @search_results = Job.search(search_definition)
    end
  
    private
  
    def build_query
      query = { bool: { must: [] } }
  
      query[:bool][:must] << { multi_match: { query: @search_query, fields: ['title^3', 'description^2', 'company', 'location'] } } if @search_query.present?
  
      query[:bool][:must] << { match: { location: @filter_location } } if @filter_location.present?
      query[:bool][:must] << { match: { company: @filter_company } } if @filter_company.present?
  
      query
    end
  
    def build_sort
      sort = []
  
      # Sort by relevance score and then by created_at date (newest first)
      sort << { '_score' => { order: 'desc' } }
      sort << { created_at: { order: 'desc' } }
  
      sort
    end
  end
  