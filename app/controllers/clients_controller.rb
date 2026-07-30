class ClientsController < ApplicationController
  before_action :set_client, only: %i[edit update destroy]

  def index
    @clients = Client.alphabetical
    @summary = DashboardSummary.new(@clients)
  end

  def new
    @client = Client.new(approval_status: "sem_posts")
  end

  def create
    @client = Client.new(client_params)

    if @client.save
      redirect_to clients_path, notice: "#{@client.name} criado."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @client.update(client_params)
      redirect_to clients_path, notice: "#{@client.name} atualizado."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @client.destroy
    redirect_to clients_path, notice: "#{@client.name} removido.", status: :see_other
  end

  private

  def set_client
    @client = Client.find(params[:id])
  end

  def client_params
    params.require(:client).permit(
      :name, :approval_status, :approval_detail,
      :released_until, :scheduled_until, :notes
    )
  end
end
