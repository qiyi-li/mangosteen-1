class Api::V1::ItemsController < ApplicationController
    def index
        items = Item.page(params[:page]).per(params[:num])
        render json:{
            resources:items,
            pager:{
                page:params[:page],
                num:params[:num],
                count:Item.count
            }
        }, status:200
    end
    def create
        item = Item.new amount:params[:amount]
        if item.save
            render json:{resource:item}

        else 
            render json:{errors:item.errors}
        end
    end
end 
