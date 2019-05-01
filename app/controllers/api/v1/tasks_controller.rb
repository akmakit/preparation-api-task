class Api::V1::TasksController < Api::V1::BaseController
  before_action :load_task, only: [:show, :update, :destroy]

  def index
    render json: Task.active, include: 'tags'
  end

  def create
    @task = Task.new(task_params)
    if @task.save
      render json: @task, status: :created, include: 'tags'
    else
      render json: @task.errors.full_messages, status: :unprocessable_entity
    end
  end

  def show
    render json: @task, include: 'tags'
  end

  def update
    @task.assign_attributes(task_params)
    if @task.save
      render json: @task, include: 'tags'
    else
      render json: @task.errors.full_messages, status: :unprocessable_entity
    end
  end

  def destroy
    @task.mark_as_deleted!
    render json: "200", status: :ok
  end

  private

  def task_params
    params[:data][:attributes].permit(:title, tags: [])
  end

  def load_task
    @task = Task.active.find_by(id: params[:id]) or not_found
  end
end
