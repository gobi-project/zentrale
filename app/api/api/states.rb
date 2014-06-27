##
# REST-API for states

module API
  ##
  # GET     /states     => List of all states
  # POST    /states     => Create a new state
  # GET     /states/:id => Get data from state
  # PATCH   /states/:id => Change state data
  # DELETE  /states/:id => Delete state
  class States < Grape::API
    namespace :states do
      get '', rabl: 'states.rabl' do
        @states = TorfState.all
      end

      params do
        requires :name, type: String
        requires :conditions
      end
      post '', rabl: 'state.rabl' do
        @state = nil
        begin
          @state = RuleParser.parse_state(permitted_params.to_json)
        rescue => e
          error({ error: e.message }, 400)
        end
        @state
      end

      route_param :state_id, requirements: /[0-9]+/ do
        before do
          @state = TorfState.find_by_id(params[:state_id])
          error('Not found', 404) unless options[:method].include?('DELETE') if @state.nil?
        end
        get '', rabl: 'state.rabl' do
          @state
        end

        # FIXME: Torf does not support state updates
        # params do
        #   optional :name, type: String
        #   optional :conditions
        # end
        # patch ''  do
        #   Torf.update_state_name(params[:state_id], params[:name]) unless params[:name].nil?
        #   Torf.update_state_conditions(params[:state_id], RuleParser.parse_conditions(params[:conditions])) unless params[:conditions].nil?
        #   status(204)
        # end

        delete do
          @state.delete unless @state.nil?
          status(204)
        end
      end
    end
  end
end
