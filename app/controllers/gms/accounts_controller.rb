require_dependency "gms/application_controller"

#:nodoc:all
module Gms
  class AccountsController < ApplicationController
    before_action :set_account, only: [:show, :edit, :update, :destroy]

    # GET /accounts
    def index
      @accounts = Account.all
    end

    # GET /accounts/1
    def show
    end

    # GET /accounts/new
    def new
      @account = Account.new
    end

    # GET /accounts/1/edit
    def edit
    end

    # POST /accounts
    def create
      @account = Account.new(account_params)

      if @account.save
        redirect_to @account, notice: 'Account was successfully created.'
      else
        render action: 'new'
      end
    end

    # PATCH/PUT /accounts/1
    def update
      if @account.update(account_params)
        redirect_to @account, notice: 'Account was successfully updated.'
      else
        render action: 'edit'
      end
    end

    # DELETE /accounts/1
    def destroy
      @account.destroy
      redirect_to accounts_url, notice: 'Account was successfully destroyed.'
    end
  end
end
