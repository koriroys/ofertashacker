module Fetchers
  class JobFetcher
    def self.search(params)
      jobs = Job.filter_it(params[:filters])
      if params[:jobs_ids] 
        jobs = jobs.no_repeat(params[:jobs_ids]) 
      end
      if params[:location_type].present? 
        jobs = from_location(jobs, params[:location_id], params[:location_type])
      end
      if params[:keywords].present? 
        jobs = jobs.with_keywords(params[:keywords]) 
      end
      jobs.random(8)
    end

    private

    def self.from_location(jobs, id, type)
      jobs.send("from_#{type}", id)
    end
  end
end
