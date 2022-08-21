class List < Array
  undef_method *%w(inject map size at index select reject detect all? any? one? none? min max minmax take_while grep include? partition group_by count join assoc zip reverse values_at compact take flat_map product)

  def inject(m, &blk)
    return m if empty?
    # yield(m, first) で { |m,x| m + x} を処理している。その返り値を次のinjectのmに格納している。
    # つまりブロックの評価を次のinjectの引数として利用している。
    # 最終的に、drop 1 の返り値が[]空配列になるので, n回目のinjectのempty?がtrueになり、引数mを最終的に返す
    (drop 1).inject(yield(m, first), &blk)
  end

  def map
    # mは初期値の[]
    # mにはループごとに、各要素に対するブロックの処理結果を追加する
    inject([]){ |m,x| m << yield(x) }
  end

  def size
    inject(0) { |m, x| m + 1 }
  end

  def at(index)
    # 初期値をindexとして扱う方針。
    # indexは0からはじまるので、初期値を0にしている。
    # blockの評価がmに入り（最初以外）、xは配列の次の値が入る。
    inject(0) do |m,x|
      return x if m == index
      m+1
    end
    nil
  end

  def index(value = nil)
    inject(0) do |m,x|
      # valueではなくblockが与えられているか？ の三項演算子
      return m if (value.nil? && block_given?) ? yield(x) : x == value
      m+1
    end
    nil
  end

  def select
    inject([]) do |m,x|
      # ifが成立しないときはnilが返される。なので、mを最後に指定しておく。
      # そうしないと次のブロック処理時に、m = nil << x if ... となり、undefined method `<<' for nil:NilClass (NoMethodError)となってしまう。
      m << x if yield(x)
      m
    end
  end
  # List[1,2,3,4,5].select { |x| x.odd? }

  def reject
    inject([]) do |m, x|
      m << x unless yield(x)
    end
  end
  # List[1,2,3,4,5].reject { |x| x.odd? }

  def detect
    inject(nil) do |m,x|
      return x if yield(x)
      m
    end
  end
  # List[1,2,3,4,5].detect{ |x| x%3 == 7 }

  def all?
    # trueを渡すところまではいけた、、、
    inject(true) do |m,x|
      m = m && yield(x)
    end
  end

  def any?
    inject(false) do |m,x|
      return true if yield(x)
      m
    end
    # こっちのほうがクール。演算子の使い方を反省。
    # inject(false) { |m, x| m || yield(x) }
  end

  # injectの返り値を比較対象にする発想がなかった、、、
  def one?
    count = inject(0) do |m,x|
      if block_given?
        yield(x) ? m+1 : m
      else
        x.present? ? m+1 : m
      end
    end
    count == 1
  end

  def none?
    count = inject(0) do |m,x|
      if block_given?
        yield(x) ? m+1 : m
      else
        x.present? ? m+1 : m
      end
    end
    count == 0
  end
end