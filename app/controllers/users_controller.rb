class UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_correct_user, only: [:update]

  def show
    @user = User.find(params[:id])
    @books = @user.books
    @book = Book.new

    #DM機能
    @currentUserEntry = Entry.where(user_id: current_user.id)  #Entriesテーブルに現在ログインしているユーザーを記録
    @userEntry = Entry.where(user_id: @user.id)  #Entriesテーブルに「チャットへ」を押されたユーザーを記録
    unless @user.id == current_user.id#unlessで条件分岐
      @currentUserEntry.each do |cu|
        @userEntry.each do |u|
          if cu.room_id == u.room_id then  #if文でroom_idが共通している場合の条件
            @isRoom = true  #room作成を許可？
            @roomId = cu.room_id  #共通したそれぞれのroom_idを変数で定義
          end
        end
      end
      if @isRoom
      else
        @room = Room.new
        @entry = Entry.new
      end
    end
  end

  def index
    @users = User.all
    @book = Book.new
  end


  def edit
    @user = User.find(params[:id])
    if @user != current_user
    redirect_to user_path(current_user)
    end
  end

  def update
    if @user.update(user_params)
      redirect_to user_path(@user), notice: "You have updated user successfully."
    else
      render "edit"
    end
  end

  private

  def user_params
    params.require(:user).permit(:name, :introduction, :profile_image)
  end

  def ensure_correct_user
    @user = User.find(params[:id])
    unless @user == current_user
      redirect_to user_path(current_user)
    end
  end
end
