class BooksController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_correct_user, only: [:edit, :update, :destroy]

# findメソッドでモデルと紐づくテーブルのDBからbookのレコードを1つ取得
# newメソッドでbookコメントを作成
  def show
    @book = Book.find(params[:id])
    @book_comment = BookComment.new
    @book_detail = Book.find(params[:id])

    #閲覧数
    unless ViewCount.find_by(user_id: current_user.id, book_id: @book_detail.id)
      current_user.view_counts.create(book_id: @book_detail.id)
    end
  end

# allメソッドでモデルと紐づくbookのすべてのレコードを取得
# newメソッドでbookを作成(bookクラスをインスタンス化)

  def index
     @book_detail = Book.find(params[:id])
    unless ViewCount.find_by(user_id: current_user.id, book_id: @book_detail.id)
      current_user.view_counts.create(book_id: @book_detail.id)
    end
    to = Time.current.at_end_of_day             #Time.currentで現在の日時を取得
    from = (to - 6.day).at_beginning_of_day     #[ to(変数) - 6.day(期間) ]で一週間を定義
    @books = Book.includes(:favorited_users).

      sort_by {|x|
        x.favorited_users.includes(:favorites).where(created_at: from...to).size
      }.reverse
    @book = Book.new
  end

# newメソッドでbookクラスをインスタンス化(カラムを引数として渡す)
# user_id = current_user.idでログインしている本人かどうか確認
# saveメソッドでbook作成
# renderはコントローラーを介さず直接viewを表示させるため表示先の変数を表記
  def create
    @book = Book.new(book_params)
    @book.user_id = current_user.id
    if @book.save
      redirect_to book_path(@book), notice: "You have created book successfully."
    else
      @books = Book.all
      render 'index'
    end
  end


  def edit
    @book = Book.find(params[:id])
    @user = User.new
    if @book.user.id != current_user.id
      redirect_to books_path
    end
  end

  def update
    @book = Book.find(params[:id])
    if @book.update(book_params)
      redirect_to book_path(@book), notice: "You have updated book successfully."
    else
      render "edit"
    end
  end

  def destroy
    @book.destroy
    redirect_to books_path
  end

  private

  def book_params
    params.require(:book).permit(:title, :body)
  end

  def ensure_correct_user
    @book = Book.find(params[:id])
    unless @book.user == current_user
      redirect_to books_path
    end
  end
end