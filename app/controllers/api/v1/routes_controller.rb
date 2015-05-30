class Api::V1::RoutesController < Api::V1::BaseApiController
  include JsonCollectionPagination
  include DownloadableCsv

  before_action :set_route, only: [:show]

  def index
    @routes = Route.where('')

    if params[:identifier].present?
      @routes = @routes.with_identifier_or_name(params[:identifier])
    end
    if params[:operatedBy].present?
      @routes = @routes.operated_by(params[:operatedBy])
    end
    if params[:bbox].present? && params[:bbox].split(',').length == 4
      bbox_coordinates = params[:bbox].split(',')
      @routes = @routes.where{geometry.op('&&', st_makeenvelope(bbox_coordinates[0], bbox_coordinates[1], bbox_coordinates[2], bbox_coordinates[3], Route::GEOFACTORY.srid))}
    end
    if params[:onestop_id].present?
      @routes = @routes.where(onestop_id: params[:onestop_id])
    end
    if params[:tag_key].present? && params[:tag_value].present?
      @routes = @routes.with_tag(params[:tag_key], params[:tag_value])
    end

    per_page = params[:per_page].blank? ? Route::PER_PAGE : params[:per_page].to_i

    respond_to do |format|
      format.json do
        render paginated_json_collection(
          @routes,
          Proc.new { |params| api_v1_routes_url(params) },
          params[:offset],
          per_page
        )
      end
      format.csv do
        return_downloadable_csv(@routes, 'routes')
      end
    end
  end

  def show
    respond_to do |format|
      format.json { render json: @route }
    end
  end

  private

  def set_route
    @route = Route.find_by_onestop_id!(params[:id])
  end
end
