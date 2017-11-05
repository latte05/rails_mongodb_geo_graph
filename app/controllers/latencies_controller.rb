class LatenciesController < ApplicationController
  before_action :set_latency, only: [:show, :edit, :update, :destroy]

  def import
    Latency.import(params[:file])
    redirect_to latencies_path
    flash[:notice] = "successfully loaded pop info"
  end


  # GET /latencies
  # GET /latencies.json
  def index
    @latencies = Latency.all

  end

  # GET /latencies/1
  # GET /latencies/1.json
  def show

        #debugger
        #@start_at = @latency.history.find{2015-01-01}
        #@end_at = @latency.history.find{2015-12-01}
        #@categories = @start_at.upto(@end_at).to_a
        #@data = @start_at['raw_latency'].upto(@end_at['raw_latency']).to_a

#       @h = LazyHighCharts::HighChart.new("graph") do |f|
#        f.chart(:type => "line")
#        f.title(:text => "Latency: #{@latency.instance}" )
#        f.xAxis(:categories => @categories)
#       f.series(:name => "sample",
#                 :data => @data)
#      end
  end

  # GET /latencies/new
  def new
    @latency = Latency.new
  end

  # GET /latencies/1/edit
  def edit
  end

  # POST /latencies
  # POST /latencies.json
  def create
    @latency = Latency.new(latency_params)
    respond_to do |format|
      if @latency.save
        format.html { redirect_to @latency, notice: 'Latency was successfully created.' }
        format.json { render :show, status: :created, location: @latency }
      else
        format.html { render :new }
        format.json { render json: @latency.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /latencies/1
  # PATCH/PUT /latencies/1.json
  def update
    respond_to do |format|
      if @latency.update(latency_params)
        format.html { redirect_to @latency, notice: 'Latency was successfully updated.' }
        format.json { render :show, status: :ok, location: @latency }
      else
        format.html { render :edit }
        format.json { render json: @latency.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /latencies/1
  # DELETE /latencies/1.json
  def destroy
    @latency.destroy
    respond_to do |format|
      format.html { redirect_to latencies_url, notice: 'Latency was successfully destroyed.' }
      format.json { head :no_content }
  end

end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_latency
      @latency = Latency.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def latency_params
      params.require(:latency).permit(:instance, :node_from, :node_to, :raw_latency, :sla_threshold, :timestamps)
    end

end
