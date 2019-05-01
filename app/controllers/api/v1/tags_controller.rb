class Api::V1::TagsController < Api::V1::BaseController
  before_action :load_tag, only: [:show, :update, :destroy]

  def index
    render json: Tag.active, include: 'tasks'
  end

  def create
    @tag = Tag.new(tag_params)
    if @tag.save
      render json: @tag, status: :created, include: 'tasks'
    else
      render json: @tag.errors.full_messages, status: :unprocessable_entity
    end
  end

  def show
    render json: @tag, include: 'tasks'
  end

  def update
    @tag.assign_attributes(tag_params)
    if @tag.save
      render json: @tag, include: 'tasks'
    else
      render json: @tag.errors.full_messages, status: :unprocessable_entity
    end
  end

  def destroy
    @tag.mark_as_deleted!
    render json: "200", status: :ok
  end

  private

  def tag_params
    params[:data][:attributes].permit(:title, tasks: [])
  end

  def load_tag
    @tag = Tag.active.find_by(id: params[:id]) or not_found
  end
end
