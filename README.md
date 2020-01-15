# AbstractHTTP

AbstractHTTP はHTTP通信とそれに付随する一連の処理を抽象化したライブラリです。

本ライブラリは大部分がプロトコルで構成されており、**通信の実装ではなく通信周りの設計を提供するものです**。


```
AbstractHTTP is abstract HTTP processing library.  
```

# プログラミングガイド (Programming guide)

## 基本の使い方 (Basic usages)

通信を行うためには `ConnectionSpec` プロトコル（またはRequestSpecとResponseSpecプロトコル）を実装したクラス（以下Specクラス）を作る必要があります。  
Specクラスは１つのAPIの仕様を表し、URLやパラメーターなどリクエストの詳細と、レスポンスのバリデーションとパース処理を記載します。  
REST APIであればURLとHTTPメソッドの組み合わせに対して１つSpecクラスを作成するのがおすすめです。

```swift
// シンプルなConnectionSpec実装
class SimplestSpec: ConnectionSpec {
    // 通信で受取るデータの型を定義する
    typealias ResponseModel = String

    // リクエスト先のURL 
    var url: String { return "https://www.google.com/" }
    
    // リクエストのHTTPメソッド
    var httpMethod: HTTPMethod { return .get }
    
    // 送信するリクエストヘッダー
    var headers: [String: String] { return [:] }
    
    // URLに付けるクエリパラメーター（URL末尾の`?`以降につけるkey=value形式のパラメーター）
    var urlQuery: URLQuery? { return nil }

    // ポストするデータ（リクエストボディ）。GET通信など不要な場合はnilにする
    func makePostData() -> Data? { return nil }
    
    // レスポンスデータのパース前のバリデーション
    func isValidResponse(response: Response) -> Bool { return true }

    // 通信レスポンスをデータモデルに変換する
    func parseResponse(response: Response) throws -> ResponseModel {
        if let string = String(bytes: response.data, encoding: .utf8) {
            return string
        }
        throw ConnectionErrorType.parse
    }
}
```

### リクエストの仕様定義

#### URL、HTTPメソッド

`url: String`、`httpMethod: HTTPMethod` プロパティでリクエストのURL、HTTPメソッドを決めます。

#### ヘッダー

`headers: [String: String]` プロパティでリクエストヘッダーを決めます。  

#### ポストデータ

`func makePostData()` でポストデータを決めます。  
ポストデータがない場合はこの関数で `nil` を返します。 

#### クエリパラメーター

`urlQuery: URLQuery?` プロパティでURLに付与するクエリパラメーターを決めます。  
`URLQuery` 型は `Dictionary` と同じ書き方で以下のように書くことができます。

```swift
var urlQuery: URLQuery? {
    return [
        "id": "123",
        "name": "john",
        "comment": "hello"
    ]
}
```

### レスポンスの仕様定義

#### レスポンスのバリデーション
`isValidResponse(response: Response) -> Bool` 関数でレスポンスのバリデーションを行います。ここでのバリデーションはレスポンスデータパース前の簡易なチェックを想定しています。  
典型的な例として以下のようにステータスコードのチェックを行うことができます。

```swift
func isValidResponse(response: Response) -> Bool {
    // ステータスコード200以外はエラー扱いにする
    return response.statusCode == 200
}
```

特にバリデーションが不要なら固定で `true` を返しても問題ありません。

#### パース

まずは受け取るレスポンスの型を `typealias ResponseModel` で指定します。  
次に `parseResponse(response: Response)` 関数でレスポンスデータを指定したレスポンスの型に変換して返します。  

`typealias ResponseModel` の型は任意に指定することができ、`String` や 特定のJSONデータを表すクラスなどを指定することが想定されます。  
`ResponseModel` を`Data` にしてレスポンスデータを変換せずそのまま返したり、`Void` にして何も返さないことも可能です。

パースに失敗した場合、この関数で何らかのエラーを`throw`すると呼び出し元でパースエラーとして扱われます。
 

### 通信の開始

通信の実行は `Connection` クラスを使って行います。  
実装したSpecクラスと通信成功時のコールバック関数をイニシャライザに指定して、`start()` 関数を呼ぶと通信を開始します。

```swift
let spec = SimplestSpec()
Connection(spec) { response in
    print(response)
}.start()
```

### ConnectionSpecをリクエスト仕様とレスポンス仕様に分割する

※ `ConnectionSpec`は`RequestSpec`、`ResponseSpec`２つのプロトコルを継承したプロトコルです。ConnectionSpecを作成する代わりに、RequestSpecを継承したクラスとResponseSpecを継承したクラスを、それぞれ別に作成することもできます。

## ConnectionTask (iOS only)

`Connection`はジェネリック型ですが、Swiftではジェネリック型を変数に保持したり、引数に渡すことができないため(*)
`Connection` の関数を外部から呼び出したい場合は、多くの場合 `ConnectionTask` プロトコルを使うことになります。

`ConnectionTask` は `Connection` からジェネリクスが関係しない関数や変数を切り出したプロトコルで、`Connection` は `ConnectionTask` プロトコルを実装しています。

```swift
class Connection<ResponseModel>: ConnectionTask
```

Kotlin (Java)にはそのような制約はなく、ワイルドカードでジェネリクスのパラメーターを指定して変数を作れるため、Android版のAbstractHTTPにはこのプロトコルはありません。

(*) 厳密には変数や引数もジェネリクスにすれば可能です

## 各種イベントの呼び出し順序

### 全体の流れ

1. ConnectionListener.onStart
2. (ネットワークエラーの場合 -> onNetworkErrorへ)
3. ConnectionResponseListener.onReceived (エラーの場合 -> onResponseErrorへ)
4. ResponseSpec.isValidResponse (エラーの場合 -> onResponseErrorへ)
5. ResponseSpec.parseResponse  (エラーの場合 -> onParseErrorへ)
6. ConnectionResponseListener.onReceivedModel (エラーの場合 -> onValidationErrorへ)
7. Connection.onSuccess
8. ConnectionResponseListener.afterSuccess
9. ConnectionListener.onEnd
10. Connection.onEnd

### エラー時の流れ

ConnectionErrorListenerの対応するエラー関数（onNetworkErrorなど）が呼び出された後、以下の順番でイベントが実行されます。

1. Connection.onError
2. ConnectionErrorListener.afterError
3. ConnectionListener.onEnd


## 最小構成の通信サンプル (The simplest example)

最小構成の通信サンプルを `Simplest` ディレクトリ内に内に実装しています。

## JSON形式のAPIの読み込み

JSON形式のAPIを読み込む実装例を`GetJSON` ディレクトリ内に内に実装しています。

## 複数のAPIで共通のリクエスト仕様を実装する

ほとんどのプロジェクトでは、API全体で共通のUser-Agentを指定するなど、複数のAPIに共通のリクエスト仕様があります。  
リクエスト仕様を共通化する一つの方法は `ConnectionSpec` の実装に共通の基底クラスを作り、基底クラスを継承して各APIを実装することです。

`CommonRequestSpec` ディレクトリ内にリクエスト仕様の共通化の例を実装しています。

## 複数の通信で共通のふるまいを実装する

ほとんどのプロジェクトでは、通信エラーが起こった場合にポップアップを表示するなど、複数の通信で共通して行うふるまいがあります。  
本ライブラリではそのような共通の振る舞いを通信処理のリスナーとして実装することができます。

リスナーには以下の3種類があります。

- ConnectionListener 通信の開始と終了をフックする
- ConnectionResponseListener レスポンスデータ、パース後のモデルの取得などをフックする
- ConnectionErrorListener ネットワークエラー、パースエラーなどのエラーをフックする

`Listener` ディレクトリ内に各種リスナーのサンプルを実装しています。

### ConnectionListener

`ConnectionListener` は通信の開始と終了をフックできます。  
通信インジケーターの表示/非表示切り替えなど、通信の開始と終了に共通して行う処理を実装することができます。

### ConnectionResponseListener

`ConnectionResponseListener` は通信データ受信後のいくつかのタイミングをフックし、レスポンスの内容を見てバリデーションエラーを発生させることもできます。

このプロトコルを使うことで複数のAPIに共通のバリデーションを実装したり、複数のAPIのレスポンスデータに対して共通の処理を実装することができます。

### ConnectionErrorListener

`ConnectionErrorListener` ネットワークエラー、バリデーションエラー、パースエラーなど様々なエラーをフックします。
また`ConnectionResponseListener`と併用すると、任意の条件でバリデーションエラーを発生させ、`ConnectionErrorListener`にエラー処理をさせることもできます。

このプロトコルを使うことで複数のAPIに共通のエラー処理を実装することができます。  


## 通信中にインジケーターを表示する

`ConnectionIndicator` クラスを使って、通信中に任意のインジケーターを表示することができます。  
このクラスは `ConnectionListener` プロトコルによりインジケーターの表示・非表示を行なっており、`ConnectionListener`プロトコルを使ってインジケーターの表示制御を独自実装することも可能です。

`ConnectionIndicator` は複数の通信で一つのインジケーターを表示するケースを想定し、単純な通信開始時と終了時の表示非表示切り替えでなく、実行中の通信が0件になったときにインジケーターを非表示にする参照カウント方式で表示制御を行います。

`Indicator` ディレクトリ内にインジケーター表示のサンプルを実装しています。

## リトライ

`ConnectionTask.restart(cloneRequest:, shouldNotify: )` 関数により通信をリトライすることができます。

リトライは `cloneRequest` 引数により、直前のリクエストのコピーを送信するか、もう一度リクエストを作り直すかを選べます。

例えばリクエストパラメーターに現在時刻を含める場合、`cloneRequest = true` ではリトライ時のリクエストパラメーターに前回と同じ時刻が含まれますが、`cloneRequest = false` の場合はリトライ時の現在時刻に変わります。

`Retry` ディレクトリ内にリトライのサンプルを実装しています。

## 通信実装のカスタマイズ（モック化）

本ライブラリには標準でURLSessionを使った通信実装 `DefaultHTTPConnector` が組み込まれていますが、`HTTPConnector` プロトコルを実装したクラスを作ることで通信処理を自由に実装することができます。

### 通信のモック化

`HTTPConnector` プロトコルを独自実装することで、API処理を実際には通信を行わないモックにすることもできます。  
これによりユニットテストで任意のレスポンスを返却したり、リクエストパラメーターのアサーションをしたりすることができます。

`Mock` ディレクトリ内に通信モックのサンプルを実装しています。


## ポーリング（自動更新）

`Polling` クラスを使って、通信のポーリング（定期的な自動更新）を行うことができます。  
このクラスは `ConnectionListener` プロトコルによりポーリングを行なっており、`ConnectionListener`プロトコルを使ってポーリングを独自実装することも可能です。

`Polling` クラスは通信成功またはネットワークエラー後、任意のインターバルの後にイニシャライザで指定したコールバックを呼び出すので、コールバック内で再度通信処理を実行することでポーリングを行うことができます。

このクラスがポーリングを継続する条件は、通信成功かネットワークエラーになることで、それ以外のバリデーションエラーやパースエラーが発生した場合ポーリングは停止します。

`Polling` ディレクトリ内に通信ポーリングのサンプルを実装しています。

## Connectionインスタンスのライフサイクル

Swiftではローカル変数が関数スコープを抜けると解放されてしまいますが、`Connection` のインスタンスは通信が終わるまで `ConnectionHolder` に保持されるため、スコープを抜けても解放されず残ります。

```swift
func request() {
    Connection(Spec()) { response in
        self.response = response
    }.start()
    // Connection インスタンスは関数を抜けても解放されない
}
```

ただし通信完了後には `Connection` が解放されてしまうので、通信完了後しばらく間を空けてからリトライするようなケースでは何らかの形で `Connection`インスタンスを保持しておく必要があります。

`ConnectionHolder` は標準では一つの共有オブジェクトが全ての `Connection` に対して使われますが、`Connection.holder` プロパティをセットすることで、任意のオブジェクトを使うこともできます。

## 通信のキャンセル

`Connection.cancel()` 関数で実行中の通信をキャンセルすることができます。  
この関数は `ConnectionTask` プロトコルからも呼び出すことができます。

また、`Connection`は`ConnectionHolder`に保持されるため、`ConnectionHolder`を通じてまとめて複数の通信をキャンセルすることもできます。

標準の `ConnectionHolder` の共有オブジェクトを使っている場合、以下のコードで画面離脱時に全ての通信をキャンセルすることができます。

```swift
override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    // 画面離脱時に全ての通信をキャンセルする
    ConnectionHolder.shared.cancelAll()
}
```

`Cancel` ディレクトリ内にキャンセルのサンプルを実装しています。

## 404エラーを正常系として扱う

レスポンスデータのパース処理は、多くの場合バイナリデータを文字列にしたりJSONデータをオブジェクトにマッピングしたりといった規則的なマッピングになりますが、実装内容は自由なので、特定の条件で例外的なパースを行うこともできます。

データリストを返すAPIがレスポンスが0件の場合に404エラーを返す仕様はたまにありますが、そのようなケースをエラーではなく0件の正常なレスポンスとして扱いたい場合、パース処理を以下のようにすることで実現できます。


```swift
func parseResponse(response: Response) throws -> ResponseModel {
    // 404エラーの場合は空配列にする
    if response.statusCode == 404 {
        return []
    }
    // それ以外はJSONをパースしてString配列を取り出す
    return try JSONDecoder().decode([String].self, from: response.data)
}
```

## 401エラーが発生したらアクセストークンをリフレッシュ

今まで説明した機能の組み合わせになりますが、通信で401エラーが発生したらアクセストークンのリフレッシュを行い、トークンリフレッシュに成功したら、全く同じ通信をリトライする実装を説明します。

これはOAuth2のクライアントで必要になることのあるフローです。

**TODO** 

## URLエンコード処理のカスタマイズ

本ライブラリには標準のURLエンコード実装、`DefaultURLEncoder` が組み込まれていますが、URLエンコードの方法をカスタマイズしたい場合 `URLEncoder` プロトコルを実装したカスタムクラスを作ることでカスタマイズすることができます。
