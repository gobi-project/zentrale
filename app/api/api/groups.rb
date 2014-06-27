##
# REST-API for groups

module API
  ##
  # GET     /groups                 => List of all groups
  # POST    /groups                 => Create new group
  # GET     /groups/:id             => Data from group
  # PATCH   /groups/:id             => Change group
  # DELETE  /groups/:id             => Delete group
  #
  # GET     /groups/:id/rules       => Get all rules from group
  # GET     /groups/:id/rules/:id   => Get dara from rule
  #
  # Plus all from /resources
  class Groups < Grape::API
    namespace :groups do
      get '', rabl: 'groups.rabl' do
        if params[:limit].nil?
          @groups = Group.all
        else
          limits = params[:limit].split(',')
          limits.each do |limit|
            error('Bad Request', 400) unless limit.match(/^[0-9]+$/)
          end

          if limits.size == 1
            @groups = Group.all.limit(limits[0])
          elsif limits.size == 2
            @groups = Group
                      .all
                      .offset(limits[0])
                      .limit(limits[1])
          else
            error('Bad Request', 400)
          end
        end
        @groups
      end

      params do
        requires :name, type: String
        optional :resources, type: Array[Integer], default: []
        optional :rules, type: Array[Integer], default: []
      end
      post '', rabl: 'group.rabl' do
        @group = Group.build(permitted_params)
        if @group.valid?
          @group.update_group(params)
        else
          error({ error: @group.errors.messages }, 400)
        end
      end

      route_param :group_id, requirements: /[0-9]+/ do
        before do
          @group = Group.find_by_id(params[:group_id])
          error('Group not found', 404) unless options[:method].include?('DELETE') if @group.nil?
        end

        get '', rabl: 'group.rabl' do
          @group
        end

        params do
          optional :name, type: String
          optional :resources, type: Array[Integer]
          optional :rules, type: Array[Integer]
        end
        patch do
          if @group.update_group(permitted_params)
            status(204)
          else
            error({ error: @group.errors.messages }, 400)
          end
        end

        delete do
          @group.destroy unless @group.nil?
          status(204)
        end

        # FIXME: Cannot mount module multiple times
        # https://github.com/intridea/grape/issues/570
        # mount API::Resources
        eval(IO.read("#{Rails.root}/app/api/api/resources.nested"))

        namespace :rules do
          get '', rabl: 'rules.rabl' do
            @rules = @group.rules
          end

          route_param :rule_id, requirements: /[0-9]+/ do
            get '', rabl: 'rule.rabl' do
              @rule = @group.rules.find_by_id(params[:rule_id])
              error('Not found', 404) if @rule.nil?
            end
          end
        end
      end
    end
  end
end
