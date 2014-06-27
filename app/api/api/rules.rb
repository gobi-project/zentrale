##
# REST-API for rules

module API
  ##
  # GET     /rules       => List of all rules
  # POST    /rules       => Create new rule
  # GET     /rules/:id   => Get data from rule
  # PATCH   /states/:id  => Change rule data
  # DELETE  /rules:id    => Delete rule
  class Rules < Grape::API
    namespace :rules do
      get '', rabl: 'rules.rabl' do
        @rules = TorfRule.all
      end

      params do
        requires :name, type: String
        optional :conditions
        requires :actions, type: Array
      end
      post '', rabl: 'rule.rabl' do
        @rule = nil
        begin
          @rule = RuleParser.parse_rule(permitted_params.to_json)
        rescue
          error({ error: 'Invalid json' }, 400)
        end
        error({ error: @rule.errors.messages }, 400) if @rule.nil?
      end

      route_param :rule_id, requirements: /[0-9]+/ do
        before do
          @rule = TorfRule.find_by_id(params[:rule_id])
          error('Not found', 404) unless options[:method].include?('DELETE') if @rule.nil?
        end
        get '', rabl: 'rule.rabl' do
          @rule
        end

        params do
          optional :name, type: String
          optional :conditions
          optional :actions, type: Array
          optional :enabled, type: Boolean
        end
        patch '' do
          Torf.update_rule_name(params[:rule_id], params[:name]) unless params[:name].nil?
          Torf.update_rule_actions(params[:rule_id], RuleParser.parse_actions(params[:actions])) unless params[:actions].nil?
          Torf.update_rule_conditions(params[:rule_id], RuleParser.parse_conditions(params[:conditions])) unless params[:conditions].nil?
          Torf.update_rule_enabled(params[:rule_id], params[:enabled]) unless params[:enabled].nil?
          status(204)
        end

        delete do
          @rule.destroy unless @rule.nil?
          status(204)
        end
      end
    end
  end
end
